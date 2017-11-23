//+------------------------------------------------------------------+
//|                                                EURFXmomentum.mq4 |
//|                                  Copyright 2016, FXmomentum Ltd. |
//|                                          https://www.eurfx.do.am |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, FXmomentum Ltd."
#property link      "https://www.eurfx.do.am"
#property version   "7.00"
//+---------------------------------------------------------
enum LotCalculator
  {
   FixedLot,
   MultiXLot,
   HistoryLot,
   MultiPlusLot,
   EURFX
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TFilter
  {
   TradeInFilter,
   TradeOutFilter
  };
extern LotCalculator     EURFX_MM=4;
extern bool    EmergencyStop=false;
extern bool    LRF=true;
extern double  Booster=2;
extern double  slip=3;
extern bool    UseLotIncrease=true;
extern int     IncreaseEvery=100;
extern double  Lots=0.01;
extern double  LotsDigits=2;
extern string  sTakeProfit = "take profit in points or $$, leave the other one at 0";
extern double  TakeProfit_points=0;
extern double  TakeProfit_dollars = 10;
extern double  Stoploss=500;
extern double  TrailStart=10;
extern double  TrailStop=10;
extern double  PipStep=150;
extern int     MaxTrades=7;
extern bool    UseEquityStop=false;
extern double  TotalEquityRisk=20;
extern bool    UseTrailingStop=false;
extern bool    UseTimeOut=false;
extern double  MaxTradeOpenHours=48;
extern string  Set="----Money Managment Setting----";
extern int     LossPercent=0;  //---- Loss Percentage Value of Equity to closed the position // No need to Change
extern int     LossValue=0;    //---- Loss Value Example -$300 USD, to closed the position // No need to Change 

extern string              stringspread="-----Spread Filter Setting-----";
extern bool                Use_SpreadFilter=true;
extern int                 Maximum_Spread=20;
//------------
// Day_Filter:
//------------

extern string         Day_Filter_Comment               = "-----Day Filter Setting-----";
extern TFilter        FilterType                       =TradeInFilter;
extern bool           BrokerTimeZone                   = true;
extern int            GmtOffset                        = 2;
extern int            AverageHoure                     = 23;

extern bool           Sunday=true;                // Allow to trade on Sunday 
extern string         TimeSunday="05-99-99";

extern bool           Monday=true;                 // Allow to trade on Monday
extern string         TimeMonday="05-99-99";

extern bool           Tuesday=true;                 // Allow to trade on Tuesday
extern string         TimeTuesday="05-99-99";

extern bool           Wednesday=true;                 // Allow to trade on Wednesday
extern string         TimeWednesday="05-99-99";

extern bool           Thursday=true;                 // Allow to trade on Thursday
extern string         TimeThursday="05-99-99";

extern bool           Friday=true;                 // Allow to trade on Friday
extern string         TimeFriday="05-99-99";

//----
int MagicNumber=100108;
double PriceTarget,StartEquity,BuyTarget,SellTarget;
double AveragePrice,SellLimit,BuyLimit;
double LastBuyPrice,LastSellPrice,ClosePrice,Spread;
int flag;
string EAName="FXmomentum";
datetime timeprev=0,expiration;
int NumOfTrades=0;
double iLots;
int cnt=0,total;
double Stopper=0;
bool TradeNow=false,LongTrade=false,ShortTrade=false;
int ticket;
bool NewOrdersPlaced=false;
double tick_pips;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   Spread=MarketInfo(Symbol(),MODE_SPREAD)*Point;
   if(Digits==3||Digits==5)tick_pips=0.01;else tick_pips=0.1;
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   FilterTime();
   CloseAll();
   if(UseTrailingStop)
     {
      TrailingAlls(TrailStart,TrailStop,AveragePrice);
     }
   if(UseTimeOut)
     {
      if(CurTime()>=expiration)
        {
         CloseThisSymbolAll();
         Print("Closed All due to TimeOut");
        }
     }
   if(timeprev==Time[0])
     {
      return(0);
     }
   timeprev=Time[0];
//----
   double CurrentPairProfit=CalculateProfit();
   if(UseEquityStop)
     {
      if(CurrentPairProfit<0 && MathAbs(CurrentPairProfit)>(TotalEquityRisk/100)*AccountEquityHigh())
        {
         CloseThisSymbolAll();
         Print("Closed All due to Stop Out");
         NewOrdersPlaced=false;
        }
     }
   total=CountTrades();
//----

   if(total==0)
     {
      flag=0;
     }
   double LastBuyLots;
   double LastSellLots;
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
     {// поиск последнего направления
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         if(OrderType()==OP_BUY)
           {
            LongTrade=true;
            ShortTrade=false;
            LastBuyLots=OrderLots();
            break;
           }
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         if(OrderType()==OP_SELL)
           {
            LongTrade=false;
            ShortTrade=true;
            LastSellLots=OrderLots();
            break;
           }
     }
   if(total>0 && total<=MaxTrades)
     {
      RefreshRates();
      LastBuyPrice=FindLastBuyPrice();
      LastSellPrice=FindLastSellPrice();
      if(LongTrade && (LastBuyPrice-Ask)>=(PipStep*Point))
        {
         TradeNow=true;
        }
      if(ShortTrade && (Bid-LastSellPrice)>=(PipStep*Point))
        {
         TradeNow=true;
        }
     }
   if(total<1)
     {
      ShortTrade=false;
      LongTrade=false;
      TradeNow=true;
      StartEquity=AccountEquity();
     }
   if(TradeNow && CheckSpread())
     {
      LastBuyPrice=FindLastBuyPrice();
      LastSellPrice=FindLastSellPrice();
      if(ShortTrade)
        {
         if(EmergencyStop)
           {
            fOrderCloseMarket(false,true);
            iLots=NormalizeDouble(Booster*LastSellLots,LotsDigits);
           }
         else
           {
            iLots=fGetLots(OP_SELL);
           }
         if(LRF)
           {
            NumOfTrades=total;
            if(iLots>0)
              {//#
               RefreshRates();
               ticket=OpenPendingOrder(OP_SELL,iLots,Bid,slip,Ask,0,0,EAName+"-"+NumOfTrades,MagicNumber,0,Orange);
               if(ticket<0){Print("Error: ",GetLastError()); return(0);}
               LastSellPrice=FindLastSellPrice();
               TradeNow=false;
               NewOrdersPlaced=true;
              }//#
           }
        }
      else if(LongTrade)
        {
         if(EmergencyStop)
           {
            fOrderCloseMarket(true,false);
            iLots=NormalizeDouble(Booster*LastBuyLots,LotsDigits);
           }
         else
           {
            iLots=fGetLots(OP_BUY);
           }
         if(LRF)
           {
            NumOfTrades=total;
            if(iLots>0)
              {//#
               ticket=OpenPendingOrder(OP_BUY,iLots,Ask,slip,Bid,0,0,EAName+"-"+NumOfTrades,MagicNumber,0,Blue);
               if(ticket<0)
                 {Print("Error: ",GetLastError()); return(0);}
               LastBuyPrice=FindLastBuyPrice();
               TradeNow=false;
               NewOrdersPlaced=true;
              }//#
           }
        }
     }
   if(TradeNow && total<1 && FilterTime() && CheckSpread())
     {
      double Candle4=iClose(Symbol(),0,4);
      double Candle3=iClose(Symbol(),0,3);
      double Candle2=iClose(Symbol(),0,2);
      double Candle1=iClose(Symbol(),0,1);
      SellLimit=Bid;
      BuyLimit=Ask;
      if(!ShortTrade)
        {
         NumOfTrades=total;
         if((Candle1>Candle2) && (Candle2>Candle3) && (Candle3>Candle4))
           {
            iLots=fGetLots(OP_SELL);
            if(iLots>0)
              {//#
               ticket=OpenPendingOrder(OP_SELL,iLots,SellLimit,slip,SellLimit,0,0,EAName+"-"+NumOfTrades,MagicNumber,0,Red);
               if(ticket<0)
                 {
                  Print(iLots,"Error: ",GetLastError()); return(0);
                 }
               LastBuyPrice=FindLastBuyPrice();
               NewOrdersPlaced=true;
              }//#
           }
         if(!LongTrade)
            NumOfTrades=total;
         if((Candle1<Candle2) && (Candle2<Candle3) && (Candle3<Candle4))
           {
            iLots=fGetLots(OP_BUY);
            if(iLots>0)
              {//#      
               ticket=OpenPendingOrder(OP_BUY,iLots,BuyLimit,slip,BuyLimit,0,0,EAName+"-"+NumOfTrades,MagicNumber,0,Lime);
               if(ticket<0){Print(iLots,"Error: ",GetLastError()); return(0);}
               LastSellPrice=FindLastSellPrice();
               NewOrdersPlaced=true;
              }//#
           }
        }
      if(ticket>0) expiration=CurTime()+MaxTradeOpenHours*60*60;
      TradeNow=false;
     }

//----------------------- CALCULATE AVERAGE OPENING PRICE
   total=CountTrades();
   AveragePrice=0;
   double Count=0;
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
     {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         if(OrderType()==OP_BUY || OrderType()==OP_SELL)
           {
            AveragePrice=AveragePrice+OrderOpenPrice()*OrderLots();
            Count=Count+OrderLots();
           }
     }
   if(total>0)
      AveragePrice=NormalizeDouble(AveragePrice/Count,Digits);
//----------------------- RECALCULATE STOPLOSS & PROFIT TARGET BASED ON AVERAGE OPENING PRICE
   if(NewOrdersPlaced)
      for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
        {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)
            continue;
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
            if(OrderType()==OP_BUY) // Calculate profit/stop target for long 
              {
               if(TakeProfit_points!=0)PriceTarget=AveragePrice+(TakeProfit_points*Point);
               if(TakeProfit_dollars!=0)PriceTarget=AveragePrice+(TakeProfit_dollars/(MarketInfo(Symbol(),MODE_TICKVALUE)*tick_pips));
               BuyTarget=PriceTarget;
               Stopper=AveragePrice-(Stoploss*Point);
               //      Stopper=0; 
               flag=1;
              }
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
            if(OrderType()==OP_SELL) // Calculate profit/stop target for short
              {
               if(TakeProfit_points!=0)PriceTarget=AveragePrice+(TakeProfit_points*Point);
               if(TakeProfit_dollars!=0)PriceTarget=AveragePrice+(TakeProfit_dollars/(MarketInfo(Symbol(),MODE_TICKVALUE)*tick_pips));
               
               SellTarget=PriceTarget;
               Stopper=AveragePrice+(Stoploss*Point);
               //      Stopper=0; 
               flag=1;
              }
        }
//----------------------- IF NEEDED CHANGE ALL OPEN ORDERS TO NEWLY CALCULATED PROFIT TARGET    
   if(NewOrdersPlaced)
      if(flag==1)// check if average has really changed
        {
         for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
           {
            //     PriceTarget=total;
            OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
            if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)
               continue;
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
               //      OrderModify(OrderTicket(),0,Stopper,PriceTarget,0,Yellow);// set all positions to averaged levels
               OrderModify(OrderTicket(),AveragePrice,OrderStopLoss(),PriceTarget,0,Yellow);// set all positions to averaged levels
            NewOrdersPlaced=false;
           }
        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ND(double v){return(NormalizeDouble(v,Digits));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fOrderCloseMarket(bool aCloseBuy=true,bool aCloseSell=true)
  {
   int tErr=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
           {
            if(OrderType()==OP_BUY && aCloseBuy)
              {
               RefreshRates();
               if(!IsTradeContextBusy())
                 {
                  if(!OrderClose(OrderTicket(),OrderLots(),ND(Bid),5,CLR_NONE))
                    {
                     Print("Error close BUY "+OrderTicket());//+" "+fMyErDesc(GetLastError())); 
                     tErr=-1;
                    }
                 }
               else
                 {
                  static int lt1=0;
                  if(lt1!=iTime(NULL,0,0))
                    {
                     lt1=iTime(NULL,0,0);
                     Print("Need close BUY "+OrderTicket()+". Trade Context Busy");
                    }
                  return(-2);
                 }
              }
            if(OrderType()==OP_SELL && aCloseSell)
              {
               RefreshRates();
               if(!IsTradeContextBusy())
                 {
                  if(!OrderClose(OrderTicket(),OrderLots(),ND(Ask),5,CLR_NONE))
                    {
                     Print("Error close SELL "+OrderTicket());//+" "+fMyErDesc(GetLastError())); 
                     tErr=-1;
                    }
                 }
               else
                 {
                  static int lt2=0;
                  if(lt2!=iTime(NULL,0,0))
                    {
                     lt2=iTime(NULL,0,0);
                     Print("Need close SELL "+OrderTicket()+". Trade Context Busy");
                    }
                  return(-2);
                 }
              }
           }
        }
     }
   return(tErr);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double fGetLots(int aTradeType)
  {
   double tLots;
   switch(EURFX_MM)
     {
      case 0:
         tLots=incLot();
         break;
      case 1:
         tLots=NormalizeDouble(incLot()*MathPow(Booster,NumOfTrades),LotsDigits);
         break;
      case 2:
         int LastClosedTime=0;
         tLots=incLot();
         for(int i=OrdersHistoryTotal()-1;i>=0;i--)
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
              {
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
                 {
                  if(LastClosedTime<OrderCloseTime())
                    {
                     LastClosedTime=OrderCloseTime();
                     if(OrderProfit()<0)
                       {
                        tLots=NormalizeDouble(OrderLots()*Booster,LotsDigits);
                       }
                     else
                       {
                        tLots=incLot();
                       }
                    }
                 }
              }
            else
              {
               return(-3);
              }
           }
         break;

      case 3:
         tLots=incLot();
         for(i=0;i<=OrdersTotal();i++)
           {
            bool OS0=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && (OrderType()==OP_BUY || OrderType()==OP_SELL))
              {
               if(OrderProfit()<0)
                 {
                  tLots=NormalizeDouble(OrderLots()+Lots,LotsDigits);
                 }
              }
           }
         break;

      case 4:
         tLots=incLot();
         double lot=0,lot2=0;
         double loss=0,loss2=0;

         for(i=0;i<=OrdersTotal()-1;i++)
           {
            bool OS1=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && (OrderType()==OP_BUY || OrderType()==OP_SELL))
              {
               lot=OrderLots(); loss=OrderProfit();
              }
           }
         for(int s=0;s<=OrdersTotal()-2;s++)
           {
            bool OS2=OrderSelect(s,SELECT_BY_POS,MODE_TRADES);
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && (OrderType()==OP_BUY || OrderType()==OP_SELL))
              {
               lot2=OrderLots(); loss2=OrderProfit();
              }
           }

         if(loss+loss2<0) tLots=lot+lot2;
         if(loss+loss2>0) tLots=incLot();

         break;
     }
   if(AccountFreeMarginCheck(Symbol(),aTradeType,tLots)<=0)
     {
      return(-1);
     }
   if(GetLastError()==134)
     {
      return(-2);
     }
   return(tLots);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades()
  {
   int count=0;
   int trade;
   double profit=0;
   for(trade=OrdersTotal()-1;trade>=0;trade--)
     {
      OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
      {
         if(OrderType()==OP_SELL || OrderType()==OP_BUY)
         {
            count++;  
            profit+= OrderProfit();
         }
      }
     }
     
   Print("account profit "+profit);
   if(TakeProfit_dollars!=0 && profit>=TakeProfit_dollars)
      CloseThisSymbolAll();
      
   return(count);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseThisSymbolAll()
  {
   int trade;
   for(trade=OrdersTotal()-1;trade>=0;trade--)
     {
      OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol())
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         if(OrderType()==OP_BUY)
            OrderClose(OrderTicket(),OrderLots(),Bid,slip,Blue);
         if(OrderType()==OP_SELL)
            OrderClose(OrderTicket(),OrderLots(),Ask,slip,Red);
        }
      Sleep(1000);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenPendingOrder(int pType,double pLots,double pLevel,int sp,double pr,int sl,int tp,string pComment,int pMagic,datetime pExpiration,color pColor)
  {
   int ticket=0;
   int err=0;
   int c=0;
   int NumberOfTries=100;
   switch(pType)
     {
      case OP_BUYLIMIT:
         for(c=0;c<NumberOfTries;c++)
           {
            ticket=OrderSend(Symbol(),OP_BUYLIMIT,pLots,pLevel,sp,StopLong(pr,sl),TakeLong(pLevel,tp),pComment,pMagic,pExpiration,pColor);
            err=GetLastError();
            if(err==0)
              {
               break;
              }
            else
              {
               if(err==4 || err==137 || err==146 || err==136) //Busy errors
                 {
                  Sleep(1000);
                  continue;
                 }
               else //normal error
                 {
                  break;
                 }
              }
           }
         break;
      case OP_BUYSTOP:
         for(c=0;c<NumberOfTries;c++)
           {
            ticket=OrderSend(Symbol(),OP_BUYSTOP,pLots,pLevel,sp,StopLong(pr,sl),TakeLong(pLevel,tp),pComment,pMagic,pExpiration,pColor);
            err=GetLastError();
            if(err==0)
              {
               break;
              }
            else
              {
               if(err==4 || err==137 || err==146 || err==136) //Busy errors
                 {
                  Sleep(5000);
                  continue;
                 }
               else //normal error
                 {
                  break;
                 }
              }
           }
         break;
      case OP_BUY:
         for(c=0;c<NumberOfTries;c++)
           {
            RefreshRates();
            ticket=OrderSend(Symbol(),OP_BUY,pLots,Ask,sp,StopLong(Bid,sl),TakeLong(Ask,tp),pComment,pMagic,pExpiration,pColor);
            err=GetLastError();
            if(err==0)
              {
               break;
              }
            else
              {
               if(err==4 || err==137 || err==146 || err==136) //Busy errors
                 {
                  Sleep(5000);
                  continue;
                 }
               else //normal error
                 {
                  break;
                 }
              }
           }
         break;
      case OP_SELLLIMIT:
         for(c=0;c<NumberOfTries;c++)
           {
            ticket=OrderSend(Symbol(),OP_SELLLIMIT,pLots,pLevel,sp,StopShort(pr,sl),TakeShort(pLevel,tp),pComment,pMagic,pExpiration,pColor);
            err=GetLastError();
            if(err==0)
              {
               break;
              }
            else
              {
               if(err==4 || err==137 || err==146 || err==136) //Busy errors
                 {
                  Sleep(5000);
                  continue;
                 }
               else //normal error
                 {
                  break;
                 }
              }
           }
         break;
      case OP_SELLSTOP:
         for(c=0;c<NumberOfTries;c++)
           {
            ticket=OrderSend(Symbol(),OP_SELLSTOP,pLots,pLevel,sp,StopShort(pr,sl),TakeShort(pLevel,tp),pComment,pMagic,pExpiration,pColor);
            err=GetLastError();
            if(err==0)
              {
               break;
              }
            else
              {
               if(err==4 || err==137 || err==146 || err==136) //Busy errors
                 {
                  Sleep(5000);
                  continue;
                 }
               else //normal error
                 {
                  break;
                 }
              }
           }
         break;
      case OP_SELL:
         for(c=0;c<NumberOfTries;c++)
           {
            ticket=OrderSend(Symbol(),OP_SELL,pLots,Bid,sp,StopShort(Ask,sl),TakeShort(Bid,tp),pComment,pMagic,pExpiration,pColor);
            err=GetLastError();
            if(err==0)
              {
               break;
              }
            else
              {
               if(err==4 || err==137 || err==146 || err==136) //Busy errors
                 {
                  Sleep(5000);
                  continue;
                 }
               else //normal error
                 {
                  break;
                 }
              }
           }
         break;
     }

   return(ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StopLong(double price,int stop)
  {
   if(stop==0)
      return(0);
   else
      return(price-(stop*Point));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StopShort(double price,int stop)
  {
   if(stop==0)
      return(0);
   else
      return(price+(stop*Point));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TakeLong(double price,int take)
  {
   if(take==0)
      return(0);
   else
      return(price+(take*Point));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TakeShort(double price,int take)
  {
   if(take==0)
      return(0);
   else
      return(price-(take*Point));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateProfit()
  {
   double Profit=0;
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
     {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         if(OrderType()==OP_BUY || OrderType()==OP_SELL)
           {
            Profit=Profit+OrderProfit();
           }
     }
   return(Profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingAlls(int start,int stop,double AvgPrice)
  {
   int profit;
   double stoptrade;
   double stopcal;
   if(stop==0)
      return;
   int trade;
   for(trade=OrdersTotal()-1;trade>=0;trade--)
     {
      if(!OrderSelect(trade,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)
         continue;
      if(OrderSymbol()==Symbol() || OrderMagicNumber()==MagicNumber)
        {
         if(OrderType()==OP_BUY)
           {
            profit=NormalizeDouble((Bid-AvgPrice)/Point,0);
            if(profit<start)
               continue;
            stoptrade=OrderStopLoss();
            stopcal=Bid-(stop*Point);
            if(stoptrade==0 || (stoptrade!=0 && stopcal>stoptrade))
               //     OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
               OrderModify(OrderTicket(),AvgPrice,stopcal,OrderTakeProfit(),0,Aqua);
           }//Long
         if(OrderType()==OP_SELL)
           {
            profit=NormalizeDouble((AvgPrice-Ask)/Point,0);
            if(profit<start)
               continue;
            stoptrade=OrderStopLoss();
            stopcal=Ask+(stop*Point);
            if(stoptrade==0 || (stoptrade!=0 && stopcal<stoptrade))
               //     OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
               OrderModify(OrderTicket(),AvgPrice,stopcal,OrderTakeProfit(),0,Red);
           }//Shrt
        }
      Sleep(1000);
     }//for
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AccountEquityHigh()
  {
   static double AccountEquityHighAmt,PrevEquity;
   if(CountTrades()==0) AccountEquityHighAmt=AccountEquity();
   if(AccountEquityHighAmt<PrevEquity) AccountEquityHighAmt=PrevEquity;
   else AccountEquityHighAmt=AccountEquity();
   PrevEquity=AccountEquity();
   return(AccountEquityHighAmt);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastBuyPrice()
  {
   double oldorderopenprice=0, orderprice;
   int cnt, oldticketnumber=0, ticketnumber;
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
     {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_BUY)
        {
         ticketnumber=OrderTicket();
         if(ticketnumber>oldticketnumber)
           {
            orderprice=OrderOpenPrice();
            oldorderopenprice=orderprice;
            oldticketnumber=ticketnumber;
           }
        }
     }
   return(orderprice);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastSellPrice()
  {
   double oldorderopenprice=0, orderprice;
   int cnt, oldticketnumber=0, ticketnumber;
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
     {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_SELL)
        {
         ticketnumber=OrderTicket();
         if(ticketnumber>oldticketnumber)
           {
            orderprice=OrderOpenPrice();
            oldorderopenprice=orderprice;
            oldticketnumber=ticketnumber;
           }
        }
     }
   return(orderprice);
  }
//+----------
void CloseAll()
  {
//---
   bool   Check=false;
   double PP=0;
   int    i=0;
//---
   if(LossPercent>0 && Profit()<0)
     {
      PP=MathAbs(Profit())/AccountBalance();
      PP=PP*100;
      if(PP>=LossPercent)
         for(i=0; i<=OrdersTotal(); i++)
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
               if(OrderType()<2  &&  OrderMagicNumber()==MagicNumber)
                  Check=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),4,clrLime);
     }
//---
   if(LossValue>0 && Profit()<0)
     {
      PP=MathAbs(Profit());
      if(PP>=LossValue)
         for(i=0; i<=OrdersTotal(); i++)
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
               if(OrderType()<2  &&  OrderMagicNumber()==MagicNumber)
                  Check=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),4,clrLime);
     }
//---
  }
//+----------
double Profit()
  {
//---
   double P=0;
//---
   for(int i=0; i<=OrdersTotal(); i++)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
         if(OrderType()<=1 && OrderMagicNumber()==MagicNumber)
            P+=OrderProfit();
//---
   return(P);
  }
//+----------

bool FilterTime()
  {
   bool tradeTime=true;
   int w=0;
   if(BrokerTimeZone)
     {
      w=TimeDayOfWeek(TimeCurrent());
     }
   else
     {
      w=TimeDayOfWeek(TimeLocal());
     }
   if(w == 0 && Sunday == false) tradeTime = false;
   if(w == 1 && Monday == false) tradeTime = false;
   if(w == 2 && Tuesday == false) tradeTime = false;
   if(w == 3 && Wednesday == false) tradeTime = false;
   if(w == 4 && Thursday == false) tradeTime = false;
   if(w == 5 && Friday == false) tradeTime = false;

// Check time
   if(tradeTime)
     {
      tradeTime=false;
      string timeZone="";
      string mycomment;
      if(w == 0 && Sunday == true) timeZone = TimeSunday;
      if(w == 1 && Monday == true) timeZone = TimeMonday;
      if(w == 2 && Tuesday == true) timeZone = TimeTuesday;
      if(w == 3 && Wednesday == true) timeZone = TimeWednesday;
      if(w == 4 && Thursday == true) timeZone = TimeThursday;
      if(w == 5 && Friday == true) timeZone = TimeFriday;

      if(timeZone=="00-00-00")
        {
         // tradeTime=true;
        }
      else
        {
         string time[];
         datetime dt1=0;
         datetime dt2 = 0;
         datetime dt3 = 0;
         switch(FilterType)
           {
            case TradeInFilter:

               SplitString(timeZone,"-",time);
               if(ArraySize(time)==3)
                 {

                  if(BrokerTimeZone)
                    {
                     dt1 = StringToTime(TimeToStr(TimeCurrent(),TIME_DATE) + " " + time[0])+(GmtOffset*3600);
                     dt2 = StringToTime(TimeToStr(TimeCurrent(),TIME_DATE) + " " + time[1])+(GmtOffset*3600);
                     dt3 = StringToTime(TimeToStr(TimeCurrent(),TIME_DATE) + " " + time[2])+(GmtOffset*3600);
                     if(TimeCurrent()+(GmtOffset*3600)>=dt1 && dt1+(AverageHoure*3600)>=TimeCurrent()+(GmtOffset*3600) && time[0]<24)
                       {
                        tradeTime=true;
                        mycomment=StringConcatenate(mycomment,"Broker Time +GmtOffset=",TimeToString(TimeCurrent()+(GmtOffset*3600),TIME_MINUTES)," | Trading Time is from ",TimeHour(dt1),":00 to ",TimeHour(dt1+(AverageHoure*3600)),":00"+ PrintInfo());
                        Comment(mycomment);
                       }
                     else if(TimeCurrent()+(GmtOffset*3600)>=dt2 && dt2+(AverageHoure*3600)>=TimeCurrent()+(GmtOffset*3600) && time[1]<24)
                       {
                        tradeTime=true;
                        mycomment=StringConcatenate(mycomment,"Broker Time +GmtOffset=",TimeToString(TimeCurrent()+(GmtOffset*3600),TIME_MINUTES)," | Trading Time is from ",TimeHour(dt2),":00 to ",TimeHour(dt2+(AverageHoure*3600)),":00"+ PrintInfo());
                        Comment(mycomment);
                       }
                     else if(TimeCurrent()+(GmtOffset*3600)>=dt3 && dt3+(AverageHoure*3600)>=TimeCurrent()+(GmtOffset*3600) && time[2]<24)
                       {
                        tradeTime=true;
                        mycomment=StringConcatenate(mycomment,"Broker Time +GmtOffset=",TimeToString(TimeCurrent()+(GmtOffset*3600),TIME_MINUTES)," | Trading Time is from ",TimeHour(dt3),":00 to ",TimeHour(dt3+(AverageHoure*3600)),":00"+ PrintInfo());
                        Comment(mycomment);
                       }
                     else if(tradeTime==false)
                       {
                        mycomment=StringConcatenate(mycomment,"Broker Time +GmtOffset=",TimeToString(TimeCurrent()+(GmtOffset*3600),TIME_MINUTES)," | Waiting for a trading time hours... | Trading Time is from ",TimeHour(dt1),":00 to ",TimeHour(dt1+(AverageHoure*3600)),":00 and from ",TimeHour(dt2),":00 to ",TimeHour(dt2+(AverageHoure*3600)),":00 and from ",TimeHour(dt3),":00 to ",TimeHour(dt3+(AverageHoure*3600)),":00"+PrintInfo());
                        Comment(mycomment);
                       }
                    }
                  else
                    {
                     dt1 = StringToTime(TimeToStr(TimeCurrent(),TIME_DATE) + " " + time[0])+(GmtOffset*3600);
                     dt2 = StringToTime(TimeToStr(TimeCurrent(),TIME_DATE) + " " + time[1])+(GmtOffset*3600);
                     dt3 = StringToTime(TimeToStr(TimeCurrent(),TIME_DATE) + " " + time[2])+(GmtOffset*3600);
                     if(TimeLocal()+(GmtOffset*3600)>=dt1 && dt1+(AverageHoure*3600)>=TimeLocal()+(GmtOffset*3600) && time[0]<24)
                       {
                        tradeTime=true;
                        mycomment=StringConcatenate(mycomment,"Local Time +GmtOffset=",TimeToString(TimeLocal()+(GmtOffset*3600),TIME_MINUTES),"| Trading Time is from ",TimeHour(dt1),":00 to ",TimeHour(dt1+(AverageHoure*3600)),":00"+ PrintInfo());
                        Comment(mycomment);
                       }
                     else if(TimeLocal()+(GmtOffset*3600)>=dt2 && dt2+(AverageHoure*3600)>=TimeLocal()+(GmtOffset*3600) && time[1]<24)
                       {
                        tradeTime=true;
                        mycomment=StringConcatenate(mycomment,"Local Time +GmtOffset=",TimeToString(TimeLocal()+(GmtOffset*3600),TIME_MINUTES),"| Trading Time is from ",TimeHour(dt2),":00 to ",TimeHour(dt2+(AverageHoure*3600)),":00"+ PrintInfo());
                        Comment(mycomment);
                       }
                     else if(TimeLocal()+(GmtOffset*3600)>=dt3 && dt3+(AverageHoure*3600)>=TimeLocal()+(GmtOffset*3600) && time[2]<24)
                       {
                        tradeTime=true;
                        mycomment=StringConcatenate(mycomment,"Local Time +GmtOffset=",TimeToString(TimeLocal()+(GmtOffset*3600),TIME_MINUTES),"| Trading Time is from ",TimeHour(dt3),":00 to ",TimeHour(dt3+(AverageHoure*3600)),":00"+ PrintInfo());
                        Comment(mycomment);
                       }
                     else if(tradeTime==false)
                       {
                        mycomment=StringConcatenate(mycomment,"Local Time +GmtOffset=",TimeToString(TimeLocal()+(GmtOffset*3600),TIME_MINUTES)," | Waiting for a trading time hours... | Trading Time is from ",TimeHour(dt1),":00 to ",TimeHour(dt1+(AverageHoure*3600)),":00 and from ",TimeHour(dt2),":00 to ",TimeHour(dt2+(AverageHoure*3600)),":00 and from ",TimeHour(dt3),":00 to ",TimeHour(dt3+(AverageHoure*3600)),":00"+PrintInfo());
                        Comment(mycomment);
                       }
                    }
                 }
               break;

            case TradeOutFilter:
               tradeTime=true;
               SplitString(timeZone,"-",time);
               if(ArraySize(time)==3)
                 {
                  dt1 = 0;
                  dt2 = 0;
                  dt3 = 0;
                  if(BrokerTimeZone)
                    {
                     dt1 = StringToTime(TimeToStr(TimeCurrent(),TIME_DATE) + " " + time[0])+(GmtOffset*3600);
                     dt2 = StringToTime(TimeToStr(TimeCurrent(),TIME_DATE) + " " + time[1])+(GmtOffset*3600);
                     dt3 = StringToTime(TimeToStr(TimeCurrent(),TIME_DATE) + " " + time[2])+(GmtOffset*3600);
                     if(TimeCurrent()+(GmtOffset*3600)>=dt1 && dt1+(AverageHoure*3600)>=TimeCurrent()+(GmtOffset*3600) && time[0]<24)
                       {
                        tradeTime=false;
                        mycomment=StringConcatenate(mycomment,"Broker Time +GmtOffset=",TimeToString(TimeCurrent()+(GmtOffset*3600),TIME_MINUTES)," | Time Filter is from ",TimeHour(dt1),":00 to ",TimeHour(dt1+(AverageHoure*3600)),":00"+ PrintInfo());
                        Comment(mycomment);
                       }
                     else if(TimeCurrent()+(GmtOffset*3600)>=dt2 && dt2+(AverageHoure*3600)>=TimeCurrent()+(GmtOffset*3600) && time[0]<24)
                       {
                        tradeTime=false;
                        mycomment=StringConcatenate(mycomment,"Broker Time +GmtOffset=",TimeToString(TimeCurrent()+(GmtOffset*3600),TIME_MINUTES)," | Time Filter is from ",TimeHour(dt2),":00 to ",TimeHour(dt2+(AverageHoure*3600)),":00"+ PrintInfo());
                        Comment(mycomment);
                       }
                     else if(TimeCurrent()+(GmtOffset*3600)>=dt3 && dt3+(AverageHoure*3600)>=TimeCurrent()+(GmtOffset*3600) && time[0]<24)
                       {
                        tradeTime=false;
                        mycomment=StringConcatenate(mycomment,"Broker Time +GmtOffset=",TimeToString(TimeCurrent()+(GmtOffset*3600),TIME_MINUTES)," | Time Filter is from ",TimeHour(dt3),":00 to ",TimeHour(dt3+(AverageHoure*3600)),":00"+ PrintInfo());
                        Comment(mycomment);
                       }
                     else if(tradeTime==true)
                       {
                        mycomment=StringConcatenate(mycomment,"Broker Time +GmtOffset=",TimeToString(TimeCurrent()+(GmtOffset*3600),TIME_MINUTES)," | In trading time hours... | Time Filter is from ",TimeHour(dt1),":00 to ",TimeHour(dt1+(AverageHoure*3600)),":00 and from ",TimeHour(dt2),":00 to ",TimeHour(dt2+(AverageHoure*3600)),":00 and from ",TimeHour(dt3),":00 to ",TimeHour(dt3+(AverageHoure*3600)),":00"+PrintInfo());
                        Comment(mycomment);
                       }
                    }
                  else
                    {
                     dt1 = StringToTime(TimeToStr(TimeCurrent(),TIME_DATE) + " " + time[0])+(GmtOffset*3600);
                     dt2 = StringToTime(TimeToStr(TimeCurrent(),TIME_DATE) + " " + time[1])+(GmtOffset*3600);
                     dt3 = StringToTime(TimeToStr(TimeCurrent(),TIME_DATE) + " " + time[2])+(GmtOffset*3600);
                     if(TimeLocal()+(GmtOffset*3600)>=dt1 && dt1+(AverageHoure*3600)>=TimeLocal()+(GmtOffset*3600) && time[0]<24)
                       {
                        tradeTime=false;
                        mycomment=StringConcatenate(mycomment,"Local Time +GmtOffset=",TimeToString(TimeLocal()+(GmtOffset*3600),TIME_MINUTES),"| Time Filter is from ",TimeHour(dt1),":00 to ",TimeHour(dt1+(AverageHoure*3600)),":00"+ PrintInfo());
                        Comment(mycomment);
                       }
                     else if(TimeLocal()+(GmtOffset*3600)>=dt2 && dt2+(AverageHoure*3600)>=TimeLocal()+(GmtOffset*3600) && time[0]<24)
                       {
                        tradeTime=false;
                        mycomment=StringConcatenate(mycomment,"Local Time +GmtOffset=",TimeToString(TimeLocal()+(GmtOffset*3600),TIME_MINUTES),"| Time Filter is from ",TimeHour(dt2),":00 to ",TimeHour(dt2+(AverageHoure*3600)),":00"+ PrintInfo());
                        Comment(mycomment);
                       }
                     else if(TimeLocal()+(GmtOffset*3600)>=dt3 && dt3+(AverageHoure*3600)>=TimeLocal()+(GmtOffset*3600) && time[0]<24)
                       {
                        tradeTime=false;
                        mycomment=StringConcatenate(mycomment,"Local Time +GmtOffset=",TimeToString(TimeLocal()+(GmtOffset*3600),TIME_MINUTES),"| Time Filter is from ",TimeHour(dt3),":00 to ",TimeHour(dt3+(AverageHoure*3600)),":00"+ PrintInfo());
                        Comment(mycomment);
                       }
                     else if(tradeTime==true)
                       {
                        mycomment=StringConcatenate(mycomment,"Local Time +GmtOffset=",TimeToString(TimeLocal()+(GmtOffset*3600),TIME_MINUTES)," | In Trading time hours... | Time Filter is from ",TimeHour(dt1),":00 to ",TimeHour(dt1+(AverageHoure*3600)),":00 and from ",TimeHour(dt2),":00 to ",TimeHour(dt2+(AverageHoure*3600)),":00 and from ",TimeHour(dt3),":00 to ",TimeHour(dt3+(AverageHoure*3600)),":00"+PrintInfo());
                        Comment(mycomment);
                       }
                    }
                 }
               break;
           }
        }
     }
   return (tradeTime);
  }
//+------------------------------------------------------------------+
bool SplitString(string stringValue,string separatorSymbol,string &results[],int expectedResultCount=0)
  {
//	 Alert("--SplitString--");
//	 Alert(stringValue);

   if(StringFind(stringValue,separatorSymbol)<0)
     {// No separators found, the entire string is the result.
      ArrayResize(results,1);
      results[0]=stringValue;
     }
   else
     {
      int separatorPos=0;
      int newSeparatorPos=0;
      int size=0;

      while(newSeparatorPos>-1)
        {
         size=size+1;
         newSeparatorPos=StringFind(stringValue,separatorSymbol,separatorPos);

         ArrayResize(results,size);
         if(newSeparatorPos>-1)
           {
            if(newSeparatorPos-separatorPos>0)
              {  // Evade filling empty positions, since 0 size is considered by the StringSubstr as entire string to the end.
               results[size-1]=StringSubstr(stringValue,separatorPos,newSeparatorPos-separatorPos);
              }
           }
         else
           {  // Reached final element.
            results[size-1]=StringSubstr(stringValue,separatorPos,0);
           }

         //Alert(results[size-1]);
         separatorPos=newSeparatorPos+1;
        }
     }

   if(expectedResultCount==0 || expectedResultCount==ArraySize(results))
     {  // Results OK.
      return (true);
     }
   else
     {  // Results are WRONG.
      Print("ERROR - size of parsed string not expected.",true);
      return (false);
     }
  }
//+------------------------------------------------------------------+
//| CheckSpread()                                                    |
//+------------------------------------------------------------------+
bool CheckSpread()
  {
   double spread=MarketInfo(_Symbol,MODE_SPREAD);
   if(Use_SpreadFilter)
     {
      if(spread>Maximum_Spread)
        {
         return (false);
        }
     }
   return(true);
  };
//+------------------------------------------------------------------+
//| PrintInfo()                                                      |
//+------------------------------------------------------------------+
string PrintInfo()
  {
   string temp="\neurfx.helpdesk@gmail.com\n"
               +"------------------------------------------------\n"
               +"ACCOUNT INFORMATION:\n"
               +"\n"
               +"AccountCompany:     "+AccountCompany()+"\n"
               +"Account Name:     "+AccountName()+"\n"
               +"AccountCurrency:     "+AccountCurrency()+"\n"
               +"Spread: "+DoubleToStr(MarketInfo(_Symbol,MODE_SPREAD),0)+"\n"
               +"Account Leverage:     "+DoubleToStr(AccountLeverage(),0)+"\n"
               +"Account Balance:     "+DoubleToStr(AccountBalance(),2)+"\n"
               +"Account Equity:     "+DoubleToStr(AccountEquity(),2)+"\n"
               +"Free Margin:     "+DoubleToStr(AccountFreeMargin(),2)+"\n"
               +"Used Margin:     "+DoubleToStr(AccountMargin(),2)+"\n"
               +"CurrentProfit:     "+DoubleToString(AccountProfit(),2)+"\n"
               +"------------------------------------------------\n";
   if(Use_SpreadFilter && !CheckSpread())
     {
      temp="\neurfx.helpdesk@gmail.com\n"
           +"------------------------------------------------\n"
           +"ACCOUNT INFORMATION:\n"
           +"\n"
           +"AccountCompany:     "+AccountCompany()+"\n"
           +"Account Name:     "+AccountName()+"\n"
           +"AccountCurrency:     "+AccountCurrency()+"\n"
           +"Spread: "+DoubleToStr(MarketInfo(_Symbol,MODE_SPREAD),0)+"\n"
           +"Account Leverage:     "+DoubleToStr(AccountLeverage(),0)+"\n"
           +"Account Balance:     "+DoubleToStr(AccountBalance(),2)+"\n"
           +"Account Equity:     "+DoubleToStr(AccountEquity(),2)+"\n"
           +"Free Margin:     "+DoubleToStr(AccountFreeMargin(),2)+"\n"
           +"Used Margin:     "+DoubleToStr(AccountMargin(),2)+"\n"
           +"CurrentProfit:     "+DoubleToString(AccountProfit(),2)+"\n"
           +"------------------------------------------------\n"
           +"Spread Larger than 2.0 is not permitted!";
     }
   return(temp);
  }
//+------------------------------------------------------------------+
double incLot()
  {
  double lt;
   if(UseLotIncrease)
     {
      int b=1;
      for(int cnt=0;cnt<AccountEquity();cnt++)
        {
         if(cnt==IncreaseEvery*b){b++;}
        }
      lt=NormalizeDouble(Lots*b,LotsDigits);
     }
     else{lt = Lots;}
     return(lt);
  }
//+------------------------------------------------------------------+
