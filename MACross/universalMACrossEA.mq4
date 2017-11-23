//+------------------------------------------------------------------+
//|                                           UniversalMACrossEA.mq4 |
//|                                  Copyright © 2006-2007, firedave | 
//|               Partial Function Copyright © 2006-2007, codersguru | 
//|                   Partial Function Copyright © 2006-2007, pengie |
//|                                        http://www.fx-review.com/ | 
//|                                        http://www.forex-tsd.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006-2007, firedave"
#property link      "http://www.fx-review.com"

/* 

   Discussion at Forex-TSD
   http://www.forex-tsd.com/expert-advisors-metatrader-4/1933-universal-ma-cross-ea.html 

   June 20, 2007 : revise all boolean condition check because of Build 206 bug
*/

//----------------------- INCLUDES
#include <stdlib.mqh>

//----------------------- EA PARAMETER
extern string           Expert_Name          = "---------- Universal MA Cross EA v8.1";
extern int              MagicNumber          = 1234;
extern double           StopLoss             = 100,
                        TakeProfit           = 200;
extern string           TrailingStop_Setting = "---------- Trailing Stop Setting";
extern int              TrailingStopType     = 1,
                        TrailingStop         = 40;
extern string           Indicator_Setting    = "---------- Indicator Setting";
extern int              FastMAPeriod         = 10,
                        FastMAType           = 1,    //0:SMA 1:EMA 2:SMMA 3:LWMA
                        FastMAPrice          = 0,    //0:Close 1:Open 2:High 3:Low 4:Median 5:Typical 6:Weighted
                        FastMAshift          = 0,
                        SlowMAPeriod         = 80,
                        SlowMAType           = 1,    //0:SMA 1:EMA 2:SMMA 3:LWMA
                        SlowMAPrice          = 0,    //0:Close 1:Open 2:High 3:Low 4:Median 5:Typical 6:Weighted
                        SlowMAshift          = 0;
extern string           CossDistance_Setting = "---------- Min Cross Distance Setting";
extern int              MinCrossDistance     = 0,    //Always positive, 0:disable
                        MaxLookUp            = 0;    //Number of bar to keep checking for the entry condition
extern string           Exit_Setting         = "---------- Exit Setting";
extern bool             StopAndReverse       = true,  // TURE:if signal change, exit and reverse order
                        PureSAR              = false,  // TRUE:no SL, no TP, no TS
                        ExitOnCross          = false;
extern string           ThirdEMA_Setting     = "---------- Third MA Setting";
extern bool             UseThirdMA           = false,
                        UseCounterTrend      = false,
                        OnlyCounterTrend     = false;
extern int              ThirdMAPeriod        = 100,
                        ThirdMAType          = 1,    //0:SMA 1:EMA 2:SMMA 3:LWMA
                        ThirdMAPrice         = 0,    //0:Close 1:Open 2:High 3:Low 4:Median 5:Typical 6:Weighted
                        ThirdMAshift         = 0,
                        CTStopLoss           = 0,
                        CTTakeProfit         = 0;
extern string           Pivot.Setting        = "---------- Pivot Filter Setting";
extern bool             Use.Pivot.Filter     = false;


/* reserve for future development
extern string           BGFilter_Setting     = "---------- BG Cross Filter Setting";
extern bool             UseBGFilter          = false;
extern int              BGFilter             = 20;                  
*/
       
extern string           Order_Setting        = "---------- Order Setting";
extern bool             ReverseCondition     = false, // TRUE:buy-sell , sell-buy
                        ConfirmedOnEntry     = true,  // TRUE:entry on the next signal bar
                        OneEntryPerBar       = true;
extern int              NumberOfTries        = 10,
                        Slippage             = 5;
extern string           OpenOrder_Setting    = "---------- Multiple Open Trade Setting";
extern int              MaxOpenTrade         = 1,
                        MinPriceDistance     = 5;
extern string           Time_Parameters      = "---------- EA Active Time";
extern bool             UseHourTrade         = false;         
extern int              StartHour            = 10,
                        EndHour              = 11;
extern string           MM_Parameters        = "---------- Money Management";
extern double           Lots                 = 1;
extern bool             MM                   = false, //Use Money Management or not
                        AccountIsMicro       = false; //Use Micro-Account or not
extern int              Risk                 = 10; //10%
extern string           Alert_Setting        = "---------- Alert Setting";
extern bool             EnableAlert          = true;
extern string           SoundFilename        = "alert.wav";
extern string           Testing_Parameters= "---------- Back Test Parameter";
extern bool             PrintControl         = true,
                        Show_Settings        = true;

//----------------------- GLOBAL VARIABLE
static int              TimeFrame            = 0;
string                  TicketComment        = "UniversalMA v8.1",
                        LastTrade,
                        LastAlert,
                        TradeDirection       = "NONE",
                        PreviousDirection    = "NONE",
                        CurrentDirection     = "NONE";
datetime                CheckTime,
                        CheckEntryTime,
                        CrossTime;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{

//----------------------- GENERATE MAGIC NUMBER AND TICKET COMMENT
//----------------------- SOURCE : PENGIE
   MagicNumber    = subGenerateMagicNumber(MagicNumber, Symbol(), Period());
	TicketComment  = StringConcatenate(TicketComment, "-", Symbol(), "-", Period());

//----------------------- SET MinCrossDistance ALWAYS POSITIVE
   MinCrossDistance = MathAbs(MinCrossDistance);

//----------------------- SHOW EA SETTING ON THE CHART
//----------------------- SOURCE : CODERSGURU
   if(Show_Settings==true) subPrintDetails();
   else Comment("");
   
//----------------------- INITIALIZE PURE Stop And Reverse
//----------------------- NO STOP LOSS, NO TAKE PROFIT, NO TRAILING STOP
   if(PureSAR==true)
   {
      StopLoss       = 0;
      TakeProfit     = 0;
      TrailingStop   = 0;
      StopAndReverse = true;
   }

//----------------------- MaxTrade ALWAYS >= 1
   if(MaxOpenTrade<=0) MaxOpenTrade = 1;
   
//+------------------------------------------------------------------+
//| CHECK LAST OPEN TRADE                                            |
//+------------------------------------------------------------------+
   LastTrade = subCheckOpenTrade();
   Print("Last Trade : ",LastTrade);
}

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
 
//----------------------- PREVENT RE-COUNTING WHILE USER CHANGING TIME FRAME
//----------------------- SOURCE : CODERSGURU
   TimeFrame=Period(); 
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
   double FastMACurrent;
   double SlowMACurrent;
   double ThirdMAValue;
   double LastHigh;
   double LastLow;
   double LastClose;
   double P;
   double S1;
   double R1;
   double S2;
   double R2;
                   
   int cnt;
   int ticket;
   int total;
   int shiftCROSS;
   int Distance;
         
   bool BuyCondition = false;
   bool SellCondition = false;
   bool CounterTrend = false;

   string CrossDirection;         
         
//----------------------- TIME FILTER
   if (UseHourTrade==true)
   {
      if(!(Hour()>=StartHour && Hour()<=EndHour))
      {
         Comment("Non-Trading Hours!");
         return(0);
      }
      else{
         if(Show_Settings==true) subPrintDetails();
            else Comment("");

      }
   }

//----------------------- CHECK CHART NEED MORE THAN 100 BARS
   if(Bars<100)
   {
      Print("bars less than 100");
      return(0);  
   }

//----------------------- TRAILING STOP SECTION
   if(TrailingStop>0 && subTotalTrade()>0)
   {
      total = OrdersTotal();
      for(cnt=0;cnt<total;cnt++)
      {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderType()<=OP_SELL &&
            OrderSymbol()==Symbol() &&
            OrderMagicNumber()==MagicNumber)
         {
            subTrailingStop(OrderType());
         }
      }
   }            

//----------------------- ADJUST LOTS IF USING MONEY MANAGEMENT
   if(MM==true) Lots = subLotSize();

//----------------------- SET VALUE FOR VARIABLE
   if(ConfirmedOnEntry==true)
   {
      if(CheckTime==iTime(NULL,TimeFrame,0)) return(0); else CheckTime = iTime(NULL,TimeFrame,0);
   
      FastMACurrent    = iMA(NULL,TimeFrame,FastMAPeriod,FastMAshift,FastMAType,FastMAPrice,1);
      SlowMACurrent    = iMA(NULL,TimeFrame,SlowMAPeriod,SlowMAshift,SlowMAType,SlowMAPrice,1);
   }
   else
   {
      FastMACurrent    = iMA(NULL,TimeFrame,FastMAPeriod,FastMAshift,FastMAType,FastMAPrice,0);
      SlowMACurrent    = iMA(NULL,TimeFrame,SlowMAPeriod,SlowMAshift,SlowMAType,SlowMAPrice,0);
   }
   
   CrossDirection = subCrossDirection(FastMACurrent,SlowMACurrent);

//----------------------- CONDITION CHECK
   if(ReverseCondition==false)
   {
//----------------------- BUY CONDITION   
      if(CrossDirection=="UP")
      {
         BuyCondition   = true;
         TradeDirection = "UP";
         CrossTime      = iTime(NULL,TimeFrame,0);
      }                       

//----------------------- SELL CONDITION   
      if(CrossDirection=="DOWN")
      {
         SellCondition  = true;
         TradeDirection = "DOWN";
         CrossTime      = iTime(NULL,TimeFrame,0);
      }
   }
   else
   {
//----------------------- SELL CONDITION   
      if(CrossDirection=="UP")
      {
         SellCondition  = true;
         TradeDirection = "UP";
         CrossTime      = iTime(NULL,TimeFrame,0);
      }                       

//----------------------- BUY CONDITION   
      if(CrossDirection=="DOWN")
      {
         BuyCondition   = true;
         TradeDirection = "DOWN";
         CrossTime      = iTime(NULL,TimeFrame,0);
      }
   }                        

   if(PrintControl==true)
   {
      if(BuyCondition==true)  Print("MA Cross BUY");
      if(SellCondition==true) Print("MA Cross SELL");
   }      

//----------------------- ALERT ON CROSS
   if(EnableAlert==true && ConfirmedOnEntry==true)
   {
      if(TradeDirection=="UP" && LastAlert!="UP")
      {
         subCrossAlert("UP");
         LastAlert = "UP";
      }            
      if(TradeDirection=="DOWN" && LastAlert!="DOWN")
      {
         subCrossAlert("DOWN");
         LastAlert ="DOWN";
      }
   }                        

//+------------------------------------------------------------------+
//| EXIT BASE ONLY ON MOVING AVERAGE CROSS                           |
//+------------------------------------------------------------------+
if(ExitOnCross==true && subTotalTrade()>0)
   {
      if((LastTrade=="BUY" && SellCondition==true) || (LastTrade=="SELL" && BuyCondition==true))
      {
         subCloseOrder();
         if(subTotalTrade()>0) subCloseOrder();
         if(subTotalTrade()>0) subCloseOrder();
         
         if(IsTesting() && PrintControl==true) Print("EXIT ON CROSS !");
      }
   }

//+------------------------------------------------------------------+
//| CHECKING FOR MIN CROSS DISTANCE SEVERAL BAR AFTER THE CROSS      |
//+------------------------------------------------------------------+
   if(MaxLookUp>0 && MinCrossDistance>0)
   {
      BuyCondition  = false;
      SellCondition = false;
      shiftCROSS    = iBarShift(NULL,TimeFrame,CrossTime);
      Distance      = MathFloor(MathAbs((FastMACurrent-SlowMACurrent)/Point));
   
      if(shiftCROSS<=MaxLookUp && Distance>=MinCrossDistance)
      {
         if(ReverseCondition==false)
         {
            if(TradeDirection=="UP")   BuyCondition  = true;
            if(TradeDirection=="DOWN") SellCondition = true;
         }
         else
         {
            if(TradeDirection=="UP")   SellCondition = true;
            if(TradeDirection=="DOWN") BuyCondition  = true;
         }
      }
      
      if(PrintControl==true)
      {
         Print(TimeToStr(CrossTime,TIME_MINUTES)," - ",shiftCROSS," - ",Distance," - ",MinCrossDistance," - ",TradeDirection);
         if(BuyCondition==true ) Print("MinCrosDistance BUY");
         if(SellCondition==true) Print("MinCrosDistance SELL");
      }
   }

//+------------------------------------------------------------------+
//| ADDITIONAL FILTER                                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| THIRD MOVING AVERAGE                                             |
//+------------------------------------------------------------------+
   if(UseThirdMA==true)
   {
      ThirdMAValue = iMA(NULL,TimeFrame,ThirdMAPeriod,ThirdMAshift,ThirdMAType,ThirdMAPrice,0);

      if(UseCounterTrend==false)
      {      
         if(BuyCondition==true  && SlowMACurrent>ThirdMAValue) BuyCondition  = true; else BuyCondition  = false;
         if(SellCondition==true && SlowMACurrent<ThirdMAValue) SellCondition = true; else SellCondition = false;
      }
      else
      {
         if((BuyCondition==true && FastMACurrent<ThirdMAValue) ||
            (SellCondition==true && FastMACurrent>ThirdMAValue)) CounterTrend = true; else CounterTrend = false;

//+------------------------------------------------------------------+
//| DON'T ALLOW ANY TREND FOLLOWING ENTRY / ONLY COUNTER TREND       |
//+------------------------------------------------------------------+
         if(OnlyCounterTrend==true && CounterTrend==false)
         {
            BuyCondition  = false;
            SellCondition = false;
         }
      }
   }

//+------------------------------------------------------------------+
//| PIVOT FILTER                                                     |
//+------------------------------------------------------------------+
   if(Use.Pivot.Filter==true)
   {
      LastHigh  = iHigh (NULL,PERIOD_D1,1);
      LastLow   = iLow  (NULL,PERIOD_D1,1);
      LastClose = iClose(NULL,PERIOD_D1,1);
      P         = (LastHigh + LastLow+ LastClose)/3;
      R1        = (2*P)-LastLow;
      S1        = (2*P)-LastHigh;
      R2        = P+(LastHigh - LastLow);
      S2        = P-(LastHigh - LastLow);
      
      if(BuyCondition==true  && SlowMACurrent<=S1 && SlowMACurrent>=S2) BuyCondition  =  true; else BuyCondition  = false;
      if(SellCondition==true && SlowMACurrent>=R1 && SlowMACurrent<=R2) SellCondition =  true; else SellCondition = false;
   }

//+------------------------------------------------------------------+
//| STOP AND REVERSE                                                 |
//+------------------------------------------------------------------+
   if(StopAndReverse==true && subTotalTrade()>0)
   {
      if((LastTrade=="BUY" && SellCondition==true) || (LastTrade=="SELL" && BuyCondition==true))
      {
         subCloseOrder();
         if(subTotalTrade()>0) subCloseOrder();
         if(subTotalTrade()>0) subCloseOrder();

         if(IsTesting() && PrintControl==true) Print("STOP AND REVERSE !");
      }
   }

//----------------------- ENTRY
//----------------------- TOTAL ORDER BASE ON MAGICNUMBER AND SYMBOL
   total = subTotalTrade();

//----------------------- IF NUMBER TRADE LESS THAN MaxTrade
   if(total<MaxOpenTrade && (BuyCondition==true || SellCondition==true)) 
   {

//----------------------- ONE ENTRY PER BAR
      if(OneEntryPerBar==true)
      {
         if(CheckEntryTime==iTime(NULL,TimeFrame,0)) return(0); else CheckEntryTime = iTime(NULL,TimeFrame,0);
      }         

//----------------------- BUY CONDITION   
      if(BuyCondition==true)
      {
         if(MaxOpenTrade>1 && subHighestLowest("BUY")==false) return(0);
      
         if(CounterTrend==false)
         {
            ticket = subOpenOrder(OP_BUY,StopLoss,TakeProfit);
            if(ticket<=0) ticket = subOpenOrder(OP_BUY,StopLoss,TakeProfit);
            if(ticket<=0) ticket = subOpenOrder(OP_BUY,StopLoss,TakeProfit);
         }
         else
         {
            ticket = subOpenOrder(OP_BUY,CTStopLoss,CTTakeProfit);
            if(ticket<=0) ticket = subOpenOrder(OP_BUY,CTStopLoss,CTTakeProfit);
            if(ticket<=0) ticket = subOpenOrder(OP_BUY,CTStopLoss,CTTakeProfit);
         }
         subCheckError(ticket,"BUY");
         LastTrade = "BUY";
         return(0);
      }

//----------------------- SELL CONDITION   
      if(SellCondition==true)
      {
         if(MaxOpenTrade>1 && subHighestLowest("SELL")==false) return(0);
         
         if(CounterTrend==false)
         {
            ticket = subOpenOrder(OP_SELL,StopLoss,TakeProfit);
            if(ticket<=0) ticket = subOpenOrder(OP_SELL,StopLoss,TakeProfit);
            if(ticket<=0) ticket = subOpenOrder(OP_SELL,StopLoss,TakeProfit);
         }
         else
         {
            ticket = subOpenOrder(OP_SELL,CTStopLoss,CTTakeProfit);
            if(ticket<=0) ticket = subOpenOrder(OP_SELL,CTStopLoss,CTTakeProfit);
            if(ticket<=0) ticket = subOpenOrder(OP_SELL,CTStopLoss,CTTakeProfit);
         }
         subCheckError(ticket,"SELL");
         LastTrade = "SELL";
         return(0);
      }
      return(0);
   }
   
   return(0);
}

//----------------------- END PROGRAM

//+------------------------------------------------------------------+
//| FUNCTION DEFINITIONS
//+------------------------------------------------------------------+

//----------------------- MONEY MANAGEMENT FUNCTION  
//----------------------- SOURCE : CODERSGURU
double subLotSize()
{
     double lotMM = MathCeil(AccountFreeMargin() *  Risk / 1000) / 100;
	  
	  if(AccountIsMicro==false) //normal account
	  {
	     if(lotMM < 0.1)                  lotMM = Lots;
	     if((lotMM > 0.5) && (lotMM < 1)) lotMM = 0.5;
	     if(lotMM > 1.0)                  lotMM = MathCeil(lotMM);
	     if(lotMM > 100)                  lotMM = 100;
	  }
	  else //micro account
	  {
	     if(lotMM < 0.01)                 lotMM = Lots;
	     if(lotMM > 1.0)                  lotMM = MathCeil(lotMM);
	     if(lotMM > 100)                  lotMM = 100;
	  }
	  
	  return (lotMM);
}

//----------------------- NUMBER OF ORDER BASE ON SYMBOL AND MAGICNUMBER FUNCTION
int subTotalTrade()
{
   int cnt;
   int total = 0;

   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL &&
         OrderSymbol()==Symbol() &&
         OrderMagicNumber()==MagicNumber) total++;
   }
   return(total);
}

//+------------------------------------------------------------------+
//| FUNCTION : CHECK OPEN ORDER BASE ON SYMBOL AND MAGIC NUMBER      |
//| SOURCE   : n/a                                                   |
//| MODIFIED : FIREDAVE                                              |
//+------------------------------------------------------------------+
string subCheckOpenTrade()
{
   int cnt = 0;
   string lasttrade = "None";      

   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL &&
         OrderSymbol()==Symbol() &&
         OrderMagicNumber()==MagicNumber)
      {
         if(OrderType()==OP_BUY ) lasttrade = "BUY";
         if(OrderType()==OP_SELL) lasttrade = "SELL";
      }         
   }
   return(lasttrade);
}

//----------------------- FIND LOWEST/HIGHEST BUY-SELL FUNCTION
bool subHighestLowest(string type)
{
   int cnt;
   int total = 0;
      
   double HighestBuy  = 0;
   double LowestBuy   = 10000;
   double HighestSell = 0;
   double LowestSell  = 10000;

   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL &&
         OrderSymbol()==Symbol() &&
         OrderMagicNumber()==MagicNumber)
      {
         if(OrderType()==OP_BUY)
         {
            if(OrderOpenPrice()<LowestBuy ) LowestBuy  = OrderOpenPrice();
            if(OrderOpenPrice()>HighestBuy) HighestBuy = OrderOpenPrice();
         }

         if(OrderType()==OP_SELL)
         {
            if(OrderOpenPrice()<LowestSell ) LowestSell  = OrderOpenPrice();
            if(OrderOpenPrice()>HighestSell) HighestSell = OrderOpenPrice();
         }

      }
   }
   
   if     (type=="BUY"  && (Ask<=LowestBuy -MinPriceDistance*Point || Ask>=HighestBuy +MinPriceDistance*Point)) return(true);
   else if(type=="SELL" && (Bid<=LowestSell-MinPriceDistance*Point || Bid>=HighestSell+MinPriceDistance*Point)) return(true);
   else return(false);
}

//+------------------------------------------------------------------+
//| FUNCTION : CHECK IS CROSS OR NOT                                 |
//| SOURCE   : CODERSGURU                                            |
//| MODIFIED : FIREDAVE                                              |
//+------------------------------------------------------------------+
string subCrossDirection(double fastMA, double slowMA)
{
        if(fastMA>slowMA) CurrentDirection = "UP";
   else if(fastMA<slowMA) CurrentDirection = "DOWN";
   
   if(PreviousDirection=="NONE")
   {
      PreviousDirection = CurrentDirection;
      return("NONE");
   }

   if(PrintControl==true) Print("Prev : ",PreviousDirection," - Curr : ",CurrentDirection);
   
   if(PreviousDirection!=CurrentDirection)
   {
      PreviousDirection = CurrentDirection;
      return(CurrentDirection);
   }
   else return("NONE");
}

//----------------------- OPEN ORDER FUNCTION
//----------------------- SOURCE   : CODERSGURU
//----------------------- SOURCE   : PENGIE
//----------------------- MODIFIED : FIREDAVE
int subOpenOrder(int type, int stoploss, int takeprofit)
{
   int
         ticket      = 0,
         err         = 0,
         c           = 0;
         
   double         
         aStopLoss   = 0,
         aTakeProfit = 0,
         bStopLoss   = 0,
         bTakeProfit = 0;

   if(stoploss!=0)
   {
      aStopLoss   = NormalizeDouble(Ask-stoploss*Point,4);
      bStopLoss   = NormalizeDouble(Bid+stoploss*Point,4);
   }
   
   if(takeprofit!=0)
   {
      aTakeProfit = NormalizeDouble(Ask+takeprofit*Point,4);
      bTakeProfit = NormalizeDouble(Bid-takeprofit*Point,4);
   }
   
   if(type==OP_BUY)
   {
      for(c=0;c<NumberOfTries;c++)
      {
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,aStopLoss,aTakeProfit,TicketComment,MagicNumber,0,Green);
         err=GetLastError();
         if(err==0)
         { 
            if(ticket>0) break;
         }
         else
         {
            if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
            {
               Sleep(5000);
               continue;
            }
            else //normal error
            {
               if(ticket>0) break;
            }  
         }
      }   
   }
   if(type==OP_SELL)
   {   
      for(c=0;c<NumberOfTries;c++)
      {
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,bStopLoss,bTakeProfit,TicketComment,MagicNumber,0,Red);
         err=GetLastError();
         if(err==0)
         { 
            if(ticket>0) break;
         }
         else
         {
            if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
            {
               Sleep(5000);
               continue;
            }
            else //normal error
            {
               if(ticket>0) break;
            }  
         }
      }   
   }  
   return(ticket);
}


//----------------------- CLOSE ORDER FUNCTION
void subCloseOrder()
{
   int
         cnt, 
         total       = 0,
         ticket      = 0,
         err         = 0,
         c           = 0;

   total = OrdersTotal();
   for(cnt=total-1;cnt>=0;cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

      if(OrderSymbol()==Symbol() &&
         OrderMagicNumber()==MagicNumber)
      {
         switch(OrderType())
         {
            case OP_BUY      :
               for(c=0;c<NumberOfTries;c++)
               {
                  ticket=OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Violet);
                  err=GetLastError();
                  if(err==0)
                  { 
                     if(ticket>0) break;
                  }
                  else
                  {
                     if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
                     {
                        Sleep(5000);
                        continue;
                     }
                     else //normal error
                     {
                        if(ticket>0) break;
                     }  
                  }
               }   
               break;
               
            case OP_SELL     :
               for(c=0;c<NumberOfTries;c++)
               {
                  ticket=OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Violet);
                  err=GetLastError();
                  if(err==0)
                  { 
                     if(ticket>0) break;
                  }
                  else
                  {
                     if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
                     {
                        Sleep(5000);
                        continue;
                     }
                     else //normal error
                     {
                        if(ticket>0) break;
                     }  
                  }
               }   
               break;
               
            case OP_BUYLIMIT :
            case OP_BUYSTOP  :
            case OP_SELLLIMIT:
            case OP_SELLSTOP :
               OrderDelete(OrderTicket());
         }
      }
   }      
}


//----------------------- TRAILING STOP FUNCTION
//----------------------- SOURCE   : CODERSGURU
//----------------------- MODIFIED : FIREDAVE
void subTrailingStop(int Type)
{
   if(Type==OP_BUY)   // buy position is opened   
   {
      switch(TrailingStopType)
      {
//----------------------- AFTER PROFIT TRAILING STOP      
         case 1:
            if(Bid-OrderOpenPrice()>Point*TrailingStop &&
              OrderStopLoss()<Bid-Point*TrailingStop)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
               return(0);
            }
            break;
            
//----------------------- TRAILING STOP
         case 2:
            if(Bid>OrderOpenPrice() &&
              OrderStopLoss()<Bid-Point*TrailingStop)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
               return(0);
            }
            break;

//----------------------- DEFAULT : AFTER PROFIT TRAILING STOP      
         default:
            if(Bid-OrderOpenPrice()>Point*TrailingStop &&
              OrderStopLoss()<Bid-Point*TrailingStop)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
               return(0);
            }  
      }
   }

   if(Type==OP_SELL)   // sell position is opened   
   {
      switch(TrailingStopType)
      {
//----------------------- AFTER PROFIT TRAILING STOP      
         case 1:
            if(OrderOpenPrice()-Ask>Point*TrailingStop)
            {
            if(OrderStopLoss()>Ask+Point*TrailingStop || OrderStopLoss()==0)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
               return(0);
            }
            }
            break;
            
//----------------------- TRAILING STOP
         case 2:
            if(OrderOpenPrice()>Ask)
            {
            if(OrderStopLoss()>Ask+Point*TrailingStop || OrderStopLoss()==0)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
               return(0);
            }
            }
            break;

//----------------------- DEFAULT : AFTER PROFIT TRAILING STOP      
         default:
            if(OrderOpenPrice()-Ask>Point*TrailingStop)
            {
            if(OrderStopLoss()>Ask+Point*TrailingStop || OrderStopLoss()==0)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
               return(0);
            }
            }
      }
   }
}



//----------------------- CHECK ERROR CODE FUNCTION
//----------------------- SOURCE : CODERSGURU
void subCheckError(int ticket, string Type)
{
    if(ticket>0) 
    {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print(Type + " order opened : ",OrderOpenPrice());
    }
    else Print("Error opening " + Type + " order : (",GetLastError(),") ", ErrorDescription(GetLastError()));
}

//----------------------- GENERATE MAGIC NUMBER BASE ON SYMBOL AND TIME FRAME FUNCTION
//----------------------- SOURCE   : PENGIE
//----------------------- MODIFIED : FIREDAVE
int subGenerateMagicNumber(int MagicNumber, string symbol, int timeFrame)
{
   int isymbol = 0;
   if (symbol == "EURUSD")       isymbol = 1;
   else if (symbol == "GBPUSD")  isymbol = 2;
   else if (symbol == "USDJPY")  isymbol = 3;
   else if (symbol == "USDCHF")  isymbol = 4;
   else if (symbol == "AUDUSD")  isymbol = 5;
   else if (symbol == "USDCAD")  isymbol = 6;
   else if (symbol == "EURGBP")  isymbol = 7;
   else if (symbol == "EURJPY")  isymbol = 8;
   else if (symbol == "EURCHF")  isymbol = 9;
   else if (symbol == "EURAUD")  isymbol = 10;
   else if (symbol == "EURCAD")  isymbol = 11;
   else if (symbol == "GBPUSD")  isymbol = 12;
   else if (symbol == "GBPJPY")  isymbol = 13;
   else if (symbol == "GBPCHF")  isymbol = 14;
   else if (symbol == "GBPAUD")  isymbol = 15;
   else if (symbol == "GBPCAD")  isymbol = 16;
   else                          isymbol = 17;
   if(isymbol<10) MagicNumber = MagicNumber * 10;
   return (StrToInteger(StringConcatenate(MagicNumber, isymbol, timeFrame)));
}


//----------------------- PRINT COMMENT FUNCTION
//----------------------- SOURCE : CODERSGURU
void subPrintDetails()
{
   string sComment   = "";
   string sp         = "----------------------------------------\n";
   string NL         = "\n";

   sComment = sp;
   sComment = sComment + "TakeProfit=" + DoubleToStr(TakeProfit,0) + " | ";
   sComment = sComment + "TrailingStop=" + DoubleToStr(TrailingStop,0) + " | ";
   sComment = sComment + "StopLoss=" + DoubleToStr(StopLoss,0) + NL; 
   sComment = sComment + sp;
   sComment = sComment + "Reverse Entry Condition=" + subBoolToStr(ReverseCondition) + NL;
   sComment = sComment + "Confirmed On Entry=" + subBoolToStr(ConfirmedOnEntry) + NL;
   sComment = sComment + "Stop And Reverse=" + subBoolToStr(StopAndReverse) + NL;
   sComment = sComment + "Pure SAR=" + subBoolToStr(PureSAR) + NL;
   sComment = sComment + sp;
   sComment = sComment + "Lots=" + DoubleToStr(Lots,2) + " | ";
   sComment = sComment + "MM=" + subBoolToStr(MM) + " | ";
   sComment = sComment + "Risk=" + DoubleToStr(Risk,0) + "%" + NL;
   sComment = sComment + sp;
  
   Comment(sComment);
}


//----------------------- BOOLEN VARIABLE TO STRING FUNCTION
//----------------------- SOURCE : CODERSGURU
string subBoolToStr ( bool value)
{
   if(value==true) return ("True");
   else return ("False");
}

//----------------------- ALERT ON MA CROSS
//----------------------- SOURCE : FIREDAVE
void subCrossAlert(string type)
{
   string AlertComment;
   
   if(type=="UP")   AlertComment = "Moving Average Cross UP !";
   if(type=="DOWN") AlertComment = "Moving Average Cross DOWN !";
   
   Alert(AlertComment);
   PlaySound(SoundFilename);
}

//----------------------- END FUNCTION