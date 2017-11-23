//+------------------------------------------------------------------+
//|                                                                  |
//|             RSI-R2.mq4 - Ver 1.0 @ 03/22/2007 by Bluto           |
//|                                                                  |
//+------------------------------------------------------------------+


#property copyright "Bluto"
#property link      "None"
#include <stderror.mqh>
#include <stdlib.mqh>

extern double LotSize=0.5;
extern int    Slippage=3;
extern double StopLoss=0;
extern double TakeProfit=700;
extern double RiskPercent=2.0;
extern bool   UseMoneyMgmt=false;
extern double RSI_Overbought_Value = 75.0; 
extern double RSI_Oversold_Value = 25.0; 
int           MagicNumber=0;
int           ticket;
int           OpenBuyOrders=0;
int           OpenSellOrders=0;
int           BuyCount=0,SellCount=0;
int           i;
bool          Buy_Mode=false, Sell_Mode=false;
double        RSI_Day_1=0, RSI_Day_2=0, RSI_Day_3=0, SMA200_Day3=0;
double        MM_MinLotSize=0;
double        MM_MaxLotSize=0;
double        MM_LotStep=0;
double        MM_Decimals=0;
double        MM_OrderLotSize=0;
int           MM_AcctLeverage=0;
int           MM_CurrencyLotSize=0;

//pair array ( Regular Symbols )
string pairs[] = { "EURUSD","USDJPY","GBPUSD","USDCHF","EURCHF","AUDUSD","USDCAD",
                   "NZDUSD","EURGBP","EURJPY","GBPJPY","CHFJPY","GBPCHF","EURAUD",
                   "EURCAD","AUDCAD","AUDJPY","NZDJPY","AUDNZD" };
string   TradeSymbol,CommentsPairs[];
int      Pair = -1;


int init()
{
   if (TradeSymbol=="AUDCADm" || TradeSymbol=="AUDCAD") {MagicNumber=200001;}
   if (TradeSymbol=="AUDJPYm" || TradeSymbol=="AUDJPY") {MagicNumber=200002;}
   if (TradeSymbol=="AUDNZDm" || TradeSymbol=="AUDNZD") {MagicNumber=200003;}
   if (TradeSymbol=="AUDUSDm" || TradeSymbol=="AUDUSD") {MagicNumber=200004;}
   if (TradeSymbol=="CHFJPYm" || TradeSymbol=="CHFJPY") {MagicNumber=200005;}
   if (TradeSymbol=="EURAUDm" || TradeSymbol=="EURAUD") {MagicNumber=200006;}
   if (TradeSymbol=="EURCADm" || TradeSymbol=="EURCAD") {MagicNumber=200007;}
   if (TradeSymbol=="EURCHFm" || TradeSymbol=="EURCHF") {MagicNumber=200008;}
   if (TradeSymbol=="EURGBPm" || TradeSymbol=="EURGBP") {MagicNumber=200009;}
   if (TradeSymbol=="EURJPYm" || TradeSymbol=="EURJPY") {MagicNumber=200010;}
   if (TradeSymbol=="EURUSDm" || TradeSymbol=="EURUSD") {MagicNumber=200011;}
   if (TradeSymbol=="GBPCHFm" || TradeSymbol=="GBPCHF") {MagicNumber=200012;}   
   if (TradeSymbol=="GBPJPYm" || TradeSymbol=="GBPJPY") {MagicNumber=200013;}
   if (TradeSymbol=="GBPUSDm" || TradeSymbol=="GBPUSD") {MagicNumber=200014;}
   if (TradeSymbol=="NZDJPYm" || TradeSymbol=="NZDJPY") {MagicNumber=200015;}
   if (TradeSymbol=="NZDUSDm" || TradeSymbol=="NZDUSD") {MagicNumber=200016;}
   if (TradeSymbol=="USDCHFm" || TradeSymbol=="USDCHF") {MagicNumber=200017;}
   if (TradeSymbol=="USDJPYm" || TradeSymbol=="USDJPY") {MagicNumber=200018;}
   if (TradeSymbol=="USDCADm" || TradeSymbol=="USDCAD") {MagicNumber=200019;}
   if (MagicNumber==0) {MagicNumber = 200999;}  

   if ( IsTesting() ) { if ( ArrayResize(pairs,1) != 0 )  pairs[0] = Symbol();   }  

   ArrayCopy (CommentsPairs, pairs);
 return(0); }

int deinit()   {  return(0);  }

int start() {

//Select Pair from Array
Pair = (Pair+1) % ArraySize(pairs);
TradeSymbol = pairs[Pair]; 

//Assign Symbol Bid/Ask & Point values
double bid=MarketInfo(TradeSymbol,MODE_BID);
double ask=MarketInfo(TradeSymbol,MODE_ASK);
double point=MarketInfo(TradeSymbol,MODE_POINT);

//----- Money Management & Lot Sizing Stuff.

  MM_AcctLeverage = AccountLeverage();
  MM_MinLotSize = MarketInfo(TradeSymbol,MODE_MINLOT);
  MM_MaxLotSize = MarketInfo(TradeSymbol,MODE_MAXLOT);
  MM_LotStep = MarketInfo(TradeSymbol,MODE_LOTSTEP);
  MM_CurrencyLotSize = MarketInfo(TradeSymbol,MODE_LOTSIZE);

  if(MM_LotStep == 0.01) {MM_Decimals = 2;}
  if(MM_LotStep == 0.1) {MM_Decimals = 1;}

  if (UseMoneyMgmt == true)
   {
    MM_OrderLotSize = AccountEquity() * (RiskPercent * 0.01) / (MM_CurrencyLotSize / MM_AcctLeverage);
    MM_OrderLotSize = StrToDouble(DoubleToStr(MM_OrderLotSize,MM_Decimals));
   }
    else
   {
    MM_OrderLotSize = LotSize;
   }

  if (MM_OrderLotSize < MM_MinLotSize) {MM_OrderLotSize = MM_MinLotSize;}
  if (MM_OrderLotSize > MM_MaxLotSize) {MM_OrderLotSize = MM_MaxLotSize;}
         

  SMA200_Day3 = iMA(TradeSymbol,PERIOD_D1,200, 0, MODE_SMA, PRICE_CLOSE, 1);

  RSI_Day_1 = iRSI(TradeSymbol, PERIOD_D1, 2, PRICE_CLOSE, 3);
  RSI_Day_2 = iRSI(TradeSymbol, PERIOD_D1, 2, PRICE_CLOSE, 2);
  RSI_Day_3 = iRSI(TradeSymbol, PERIOD_D1, 2, PRICE_CLOSE, 1);
  
  if (RSI_Day_1 < 65 && RSI_Day_2 < RSI_Day_1 && RSI_Day_3 < RSI_Day_2 && iClose(TradeSymbol,1440,1) > SMA200_Day3) 
   {
    Buy_Mode=true;
   } else {
    Buy_Mode=false;
   } 
   
   if (RSI_Day_1 > 35 && RSI_Day_2 > RSI_Day_1 && RSI_Day_3 > RSI_Day_2 && iClose(TradeSymbol,1440,1) < SMA200_Day3) 
   {
    Sell_Mode=true;
   } else {
    Sell_Mode=false;
   } 

  if (OpenBuyOrders == 1 && iRSI(TradeSymbol, PERIOD_D1, 2, PRICE_CLOSE, 1) > RSI_Overbought_Value)
   {
     CloseLongs(MagicNumber,bid);
     OpenBuyOrders = 0;
     BuyCount=0;   
   }
   
   if (OpenSellOrders == 1 && iRSI(TradeSymbol, PERIOD_D1, 2, PRICE_CLOSE, 1) < RSI_Oversold_Value)
   {
     CloseShorts(MagicNumber,ask);
     OpenSellOrders = 0;
     SellCount=0;   
   }
     
     
//----- Count number of existing open buy & sell orders; update trailing stops.
  
  OpenBuyOrders=0;
  OpenSellOrders=0; 
 

// Manage Paraolic SAR 

  for (i = 0; i <= OrdersTotal(); i++)
   {
    OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
    if ((OrderSymbol() == TradeSymbol) && (OrderMagicNumber() == MagicNumber))
     {
      if (OrderType() == OP_BUY)
       {
        OpenBuyOrders++;
        if ((iSAR(TradeSymbol,PERIOD_D1,0.02,0.2,1) > OrderStopLoss()) && (bid > iSAR(TradeSymbol,PERIOD_D1,0.02,0.2,1)) && (OrderOpenPrice() < iSAR(TradeSymbol,0,0.02,0.2,1)) && (iSAR(TradeSymbol,0,0.02,0.2,1) > iSAR(TradeSymbol,0,0.02,0.2,2)))
         {
          OrderModify(OrderTicket(),OrderOpenPrice(),iSAR(TradeSymbol,PERIOD_D1,0.02,0.2,1),OrderTakeProfit(),0,Blue);
          Print("Order # ",OrderTicket()," updated at ",Hour(),":",Minute(),":",Seconds());
          return(0);
         }
       }
      if (OrderType() == OP_SELL)
       {
        OpenSellOrders++;
        if ((iSAR(TradeSymbol,PERIOD_D1,0.02,0.2,1) < OrderStopLoss()) && (ask < iSAR(TradeSymbol,PERIOD_D1,0.02,0.2,1)) && (OrderOpenPrice() > iSAR(TradeSymbol,0,0.02,0.2,1)) && (iSAR(TradeSymbol,0,0.02,0.2,1) < iSAR(TradeSymbol,0,0.02,0.2,2)))
         {
          OrderModify(OrderTicket(),OrderOpenPrice(),iSAR(TradeSymbol,PERIOD_D1,0.02,0.2,1),OrderTakeProfit(),0,Blue);
          Print("Order # ",OrderTicket()," updated at ",Hour(),":",Minute(),":",Seconds());
          return(0);
         }
       }
     }
   }


//----- Generic order handler.
//----- If we have a new buy signal, close existing sell orders; if we have a new sell signal, close existing buy orders; reset order counters.
//----- Next, create new buy or sell order.
         
  if (Buy_Mode==true && BuyCount==0) 
   {
    if(OpenSellOrders > 0)
     {
      CloseShorts(MagicNumber,ask);
      OpenSellOrders = 0; 
     }
    SellCount=0; 
    if(OpenBuyOrders == 0)
     {  
      ticket = OpenPendingOrder(OP_BUY,MM_OrderLotSize,ask,Slippage,bid,StopLoss,TakeProfit,"RSI-R2 mp",MagicNumber,0,Lime);
      if(ticket<0)
       {
        Print("OrderSend failed with error #",GetLastError());
        return(0);
       }
      else
       {
        OpenBuyOrders++;
        BuyCount++;
       }    
     }
   }
   
  if (Sell_Mode==true && SellCount==0) 
   {
    if(OpenBuyOrders > 0)
     {
      CloseLongs(MagicNumber,bid);
      OpenBuyOrders = 0;
     }
    BuyCount=0;  
    if (OpenSellOrders == 0) 
     {
      ticket = OpenPendingOrder(OP_SELL,MM_OrderLotSize,bid,Slippage,ask,StopLoss,TakeProfit,"RSI-R2 mp",MagicNumber,0,HotPink);
      if(ticket<0)
       {
        Print("OrderSend failed with error #",GetLastError());
        return(0);
       }
      else
       {
        OpenSellOrders++;
        SellCount++;
       }    
     }
   }
  //Print(TradeSymbol); 
  CommentAll (SMA200_Day3, RSI_Day_1, RSI_Day_2, RSI_Day_3);
  return(0);   }

//----- Comments
void CommentAll (double SMA200_Day3, double RSI_Day_1, double RSI_Day_2, double RSI_Day_3) {
   string Comments = "";
   int i, next = (Pair+1) % ArraySize(pairs);
   
   CommentsPairs[Pair] = TradeSymbol+": "+"Last Close "+iClose(TradeSymbol,1440,1)+" 200SMA("+SMA200_Day3+") "+"RSI(1) "+RSI_Day_1+ 
                         " RSI(2)"+RSI_Day_2+" RSI(3)"+RSI_Day_3+" Pair Tick Count: "+iVolume(TradeSymbol,43200,0);

   CommentsPairs[next] = ">" + CommentsPairs[next];
   for (i=0; i < ArraySize(CommentsPairs); i++)
      Comments = Comments + "\n" + CommentsPairs[i];
   if ( ! IsTesting() )  Comment (/*CommentHeader,*/"Last Tick: ",TimeToStr(CurTime(),TIME_DATE|TIME_SECONDS),"\n", Comments);    }

//----- Order Processing Functions

void CloseLongs(int MagicNumber, double bid)
{
 int trade;
 for(trade=OrdersTotal()-1;trade>=0;trade--)
 {
  if(OrderSelect(trade,SELECT_BY_POS,MODE_TRADES)==false)
   continue;

  if(OrderSymbol()!=TradeSymbol||OrderMagicNumber()!=MagicNumber)
   continue;
   
  if(OrderSymbol()==TradeSymbol&&OrderMagicNumber()==MagicNumber)
  if(OrderType()==OP_BUY)
   OrderClose(OrderTicket(),OrderLots(),bid,Slippage,Blue);
 }//for
}

void CloseShorts(int MagicNumber, double ask)
{
 int trade;
 for(trade=OrdersTotal()-1;trade>=0;trade--)
 {
  if(OrderSelect(trade,SELECT_BY_POS,MODE_TRADES)==false)
   continue;

  if(OrderSymbol()!=TradeSymbol||OrderMagicNumber()!=MagicNumber)
   continue;
   
  if(OrderSymbol()==TradeSymbol&&OrderMagicNumber()==MagicNumber)
  if(OrderType()==OP_SELL)
   OrderClose(OrderTicket(),OrderLots(),ask,Slippage,Red);
 }//for
}

int OpenPendingOrder(int pType,double pLots,double pLevel,int sp,
    double pr, int sl, int tp,string pComment,int pMagic,datetime pExpiration,color pColor)
{
  double bid=MarketInfo(TradeSymbol,MODE_BID);
  double ask=MarketInfo(TradeSymbol,MODE_ASK);
  double point=MarketInfo(TradeSymbol,MODE_POINT);
  int ticket=0;
  int err=0;
  int c = 0;
  int NumberOfTries = 10;
  switch (pType)
  {
      case OP_BUY:
         for(c = 0 ; c < NumberOfTries ; c++)
         {  
            RefreshRates();
            ticket=OrderSend(TradeSymbol,OP_BUY,pLots,ask,sp,StopLong(bid,sl,point),TakeLong(bid,tp,point),pComment,pMagic,pExpiration,pColor);
            if (ticket > 0) break;
            err=GetLastError();
            if(err==0)
            { 
               break;
            }
            else
            {
               if(err==4 || err==137 ||err==146 || err==136) //Busy errors
               {
                  Sleep(5000);
                  continue;
               }
               else //normal error
               {
                  Print("Error Code= ", err);
                  break;
               }  
            }
         } 
         break;
      case OP_SELL:
         for(c = 0 ; c < NumberOfTries ; c++)
         {
            RefreshRates();
            ticket=OrderSend(TradeSymbol,OP_SELL,pLots,bid,sp,StopShort(ask,sl,point),TakeShort(ask,tp,point),pComment,pMagic,pExpiration,pColor);
            if (ticket > 0) break;
            err=GetLastError();
            if(err==0)
            { 
               break;
            }
            else
            {
               if(err==4 || err==137 ||err==146 || err==136) //Busy errors
               {
                  Sleep(5000);
                  continue;
               }
               else //normal error
               {
                  Print("Error Code= ", err);
                  break;
               }  
            }
         } 
         break;
  } 
  
  return(ticket);
}  

double StopLong(double price,int stop,double point)
{
 if(stop==0)
  return(0);
 else
  return(price-(stop*point));
}

double StopShort(double price,int stop,double point)
{
 if(stop==0)
  return(0);
 else
  return(price+(stop*point));
}

double TakeLong(double price,int take,double point)
{
 if(take==0)
  return(0);
 else
  return(price+(take*point));
}

double TakeShort(double price,int take,double point)
{
 if(take==0)
  return(0);
 else
  return(price-(take*point));
}




