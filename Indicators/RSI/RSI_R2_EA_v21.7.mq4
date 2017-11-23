//+------------------------------------------------------------------+
//|                                                                  |
//|             RSI-R2.mq4 - Ver 1.0 @ 03/22/2007 by Bluto           |
//|                                                                  |
//|  Changes by Rick Myers                                           |
//|  4/8/2007 Modified code to use MFI instead of MFI                |
//|  Changes by Robert Hill                                          |
//|  4/3/2007 added input for RSI_Period                             |
//|           Modified code for MagicNumber calculation              |
//|           Added function to set value for RSI_Period             |
//|           Set value of AssignRSI to false during optimization    |
//|           Use optimized value in function AssignRSI_Period       |
//|           Set value of AssignRSI to true when running live       |
//|  4/5/2007 Fixed bug that caused no more trades after a stoploss  |
//|           added 2 variable to hold pSar values to reduce calls   |
//|           Added GetLots as a function using MM code from start   |
//|  4/6/2007 Combined with RSI_R2_AnyTimeFrame_Optimzable.mq4       |
//|           Made more modular                                      |
//|           Added code for possible MA Angle filter                |
//|           Added 7 Trailing stop functions for testing            |
//|           Combined Bluots open trade code with mine              |
//| 4/15/2007 Added optimized values for RSI period from bluto       |
//|           Added change to moneymanagement from bluto             |
//| 4/16/2007 Added code to check RSI 4 bars back for confirmation   |
//|           Added new exit ideas from Gideon                       |
//|           Both are selectable by input switches.                 |
//| 4/27/2007 Added check to prevent another trade from opening      |
//|           on the same dat a trade is closed                      |
//| 5/6/2007  Added new exit strategies                              |
//|           RSI 14 as described by Loren                           |
//|           My idea to use CCI 50                                  |
//| 5/8/2007  Added use of MFI by selection                          |
//|           Changed input name useDefaultRSI_Period                |
//|           to useOptimizedRSI_Period                              |
//| 5/11/2007 Removed use of MFI and MA Angle for filter             |
//|           Added use of HMA3 for filter                           |
//|           Added code to only check signal once per completed bar |
//|           Made new exit methods selectable from menu for easier  |
//|           testing for best method                                |
//|                                                                  |
//|           Modifications suggested by Loren                       |
//|           Require daily RSI 14 weighted close >= 35 for long     |
//|           to correct the premature entry problem where price     |
//|           price continues to decline for an indeterminate period.|
//|           The reverse of this for shorts w/ RSI 14 <= 65.        |
//+------------------------------------------------------------------+


#property copyright "Bluto and Robert"
#property link      "None"
#include <stdlib.mqh>

// This makes code easier to read

// Exit Method
#define NONE 1
#define RSI_EXIT 2
#define CCI_EXIT 3

// Currency pair
#define AUDCAD 1
#define AUDJPY 2
#define AUDNZD 3
#define AUDUSD 4
#define CHFJPY 5
#define EURAUD 6
#define EURCAD 7
#define EURCHF 8
#define EURGBP 9
#define EURJPY 10
#define EURUSD 11
#define GBPCHF 12
#define GBPJPY 13
#define GBPUSD 14
#define NZDJPY 15
#define NZDUSD 16
#define USDCAD 17
#define USDCHF 18
#define USDJPY 19
#define UNEXPECTED 999

extern string  Expert_Name    = "---- RSI_R2_EA_v2.6 ----";
//+---------------------------------------------------+
//|Money Management                                   |
//+---------------------------------------------------+
extern double  LotSize=0.1;
extern double  RiskPercent=2.0;
extern bool    UseMoneyMgmt=false;
extern bool    BrokerPermitsFractionalLots = true;

//+---------------------------------------------------+
//|Indicator Variables                                |
//| Change these to try your own system               |
//| or add more if you like                           |
//+---------------------------------------------------+
extern string  mi="--Moving Average settings--";
extern int     MaTrend_Period = 200;

extern string  ri="--RSI settings--";
extern int     RSI_Period = 4;       // input value to be optimized
extern bool    UseOptimizedRSI_Period = false;
extern int     BuyWhenRsiBelow = 65;
extern int     SellWhenRsiAbove = 35;
extern double  RSI_Overbought_Value = 75.0; 
extern double  RSI_Oversold_Value = 25.0;
extern int     useTurnUpDown = 1;
extern string  l1="--RSI confirmation--";
extern int     useRSI_Confirmation = 1;
extern int     RSI_ConfirmPeriod = 14;
extern int     BuyConfirmLevel = 35;
extern int     SellConfirmLevel = 65;

// Added Blutos newest exit using Price close vs SMA 200
extern int     use200SMA_Exit = 1;
extern string  ex1="--Trade Exit Method--";
extern string  ex2=" 1. None";
extern string  ex3=" 2. RSI ";
extern string  ex4=" 3. CCI ";
extern int     ExitMethod = 2;
extern int     RSI_Exit_Period = 14;
extern int     RSI_BuyExitLevel = 50;
extern int     RSI_SellExitLevel = 50;

extern int     CCI_Exit_Period = 50;
extern int     CCI_BuyExitLevel = 0;
extern int     CCI_SellExitLevel = 0;

extern string  st1="--Signal_TimeFrame--";
extern int     Signal_TimeFrame = 0;

extern string  hd = " --Limit 1 trade per day --";
extern int     useDelay = 1;
extern int     MaxTrades = 1;

// Added this for possible filter for flat markets
extern string  ai="--HMA filter settings--";
extern string  a2=" Set switch to 1 to use filter";
extern int     useFilter = 1;
extern double  HMA_Period=200;
extern int     Separation = 1;
extern int     Filter_TimeFrame = 0;

//+---------------------------------------------------+
//|Profit controls                                    |
//+---------------------------------------------------+
extern string  st6 = "--Profit Controls--";
extern double  StopLoss=0;
extern double  TakeProfit=700;
extern int     Slippage=3;

extern string  tsp0 = "--Trailing Stop Types--";
extern string  tsp1 = " 1 = Trail immediately";
extern string  tsp2 = " 2 = Wait to trail";
extern string  tsp3 = " 3 = Uses 3 levels before trail";
extern string  tsp4 = " 4 = Breakeven + Lockin";
extern string  tsp5 = " 5 = Step trail";
extern string  tsp6 = " 6 = EMA trail";
extern string  tsp7 = " 7 = pSAR trail";
extern string  tsp8 = " 8 = Blutos pSar trail";
extern bool    UseTrailingStop = true;
extern int     TrailingStopType = 8;

extern string  ts2 = "Settings for Type 2";
extern double  TrailingStop = 15;      // Change to whatever number of pips you wish to trail your position with.

extern string  ts3 = "Settings for Type 3";
extern double  FirstMove = 20;        // Type 3  first level pip gain
extern double  FirstStopLoss = 50;    // Move Stop to Breakeven
extern double  SecondMove = 30;       // Type 3 second level pip gain
extern double  SecondStopLoss = 30;   // Move stop to lock is profit
extern double  ThirdMove = 40;        // type 3 third level pip gain
extern double  TrailingStop3 = 20;    // Move stop and trail from there

extern string  ts4 = "Settings for Type 4";
extern double  BreakEven = 30;
extern int     LockInPips = 1;        // Profit Lock in pips

extern string  ts5 = "Settings for Type 5";
extern int     eTrailingStop   = 10;
extern int     eTrailingStep   = 2;

extern string  ts6 = "Settings for Type 6";
extern int     EMATimeFrame    =  30;
extern int     Price           =  0;
extern int     EMAPeriod       = 13;
extern int     EMAShift        =  2;    
extern int     InitialStop     =  0;
 
extern string  ts7 = "Settings for Type 7";
extern string  pi="--pSAR settings--";
extern double  StepParabolic = 0.02;
extern double  MaxParabolic  = 0.2;
extern int     Interval      = 5;

extern string  ts8 = "Settings for Type 8";
extern string  pi2="--pSAR settings--";
extern double  SarStep = 0.02;
extern double  SarMax = 0.20;

//+---------------------------------------------------+
//|General controls                                   |
//+---------------------------------------------------+
int            MagicNumber=0;
string         setup;
int            TradesInThisSymbol = 0;
double         MM_OrderLotSize=0;
datetime       StopTime;                 // Time to wait after a trade is stopped out
bool           StoppedOut=false;
datetime       timeprev=0;

//+---------------------------------------------------+
//|  Indicator values for signals and filters         |
//|  Add or Change to test your system                |
//+---------------------------------------------------+
int            myRSI_Period = 2;     // Used by RSI indicator call

//+------------------------------------------------------------------+
//| Calculate MagicNumber, setup comment and assign RSI Period       |
//|                                                                  |
//+------------------------------------------------------------------+
int init()
{

	MagicNumber = 200000 + func_Symbol2Val(Symbol())*100 + func_TimeFrame_Const2Val(Period()); 
   setup=Expert_Name + Symbol() + "_" + func_TimeFrame_Val2String(func_TimeFrame_Const2Val(Period()));
   if (UseOptimizedRSI_Period) myRSI_Period = AssignRSI_Period(Symbol()); else  myRSI_Period = RSI_Period;
    
 return(0);
}

int deinit()
{
 return(0);
}



//+------------------------------------------------------------------+
//| AssignRSI_Period                                                 |
//| Returns the optimized value for RSI period based on symbol       |
//|                                                                  |
//| This function will be changed when new optimized values are      |
//| determined from backtest                                         |
//|                                                                  |
//+------------------------------------------------------------------+
int AssignRSI_Period(string symbol)
{

   int RSI = 0;
   int which = func_Symbol2Val(symbol);
   
   switch (which)
   {
        case AUDCAD : RSI = 5;
                      break;
        case AUDJPY : RSI = 7;
                      break;
        case AUDNZD : RSI = 6;
                      break;
        case AUDUSD : RSI = 4;
                      break;
        case CHFJPY : RSI = 4;
                      break;
        case EURAUD : RSI = 2;
                      break;
        case EURCAD : RSI = 3;
                      break;
        case EURCHF : RSI = 3;
                      break;
        case EURGBP : RSI = 2;
                      break;
        case EURJPY : RSI = 4;  // Optimized value
                      break;
        case EURUSD : RSI = 4;
                      break;
        case GBPCHF : RSI = 6;
                      break;
        case GBPJPY : RSI = 4;
                      break;
        case GBPUSD : RSI = 3;
                      break;
        case NZDJPY : RSI = 6;
                      break;
        case NZDUSD : RSI = 7;
                      break;
        case USDCAD : RSI = 2;
                      break;
        case USDCHF : RSI = 4;
                      break;
        case USDJPY : RSI = 4;
                      break;
        case UNEXPECTED : RSI = 4;
   }
   if (RSI == 0) RSI = 4;
   return (RSI);
}

//+------------------------------------------------------------------+
//| LastTradeStoppedOut                                              |
//| Check History to see if last trade stopped out                   |
//| Return Time for next trade                                       |
//+------------------------------------------------------------------+
  
//+------------------------------------------------------------------+
//| LastTradeClosedToday                                             |
//| Check History to see if last trade closed today                  |
//+------------------------------------------------------------------+
  
bool LastTradeClosedToday()
{
   int cnt, total;
   bool Closed;
   
   
   total = HistoryTotal();
   for (cnt = total - 1; cnt >= 0; cnt--)
   {
      OrderSelect (cnt, SELECT_BY_POS, MODE_HISTORY);
      
      if(OrderSymbol()!=Symbol()) continue;
      if (OrderMagicNumber() != MagicNumber) continue;

        Closed = false;
        if (OrderType() == OP_BUY)
        {
          if (TimeDay(OrderCloseTime()) == TimeDay(TimeCurrent()))
          {
             Closed = true;
          }
          cnt = 0;
        }
        if (OrderType() == OP_SELL)
        {
          if (TimeDay(OrderCloseTime()) == TimeDay(TimeCurrent()))
          {
             Closed = true;
          }
          cnt = 0;
        }

   }
   
   return (Closed);
}



//+------------------------------------------------------------------+
//| CheckFilter                                                      |
//| Uses HMA3 custom indicator                                       |
//| Place trades only in the direction of Hull Moving Average        |
//| No trade is placed if HMA is too flat                            | 
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckFilter (int cmd)
{
   double MACurrent, MAPrevious;
   bool filter = false;
   
   MACurrent=iCustom(NULL,Filter_TimeFrame,"Hma3",HMA_Period,0,0,0,1);
   MAPrevious=iCustom(NULL,Filter_TimeFrame,"Hma3",HMA_Period,0,0,0,2);
   
   filter = false;
   switch (cmd)
   {
      case OP_BUY : if (MACurrent - MAPrevious >= Separation * Point) filter = true;
                    break;
      case OP_SELL : if (MAPrevious - MACurrent >= Separation * Point) filter = true;
   }
   return (filter);
   
}


//+------------------------------------------------------------------+
//| CheckRSI_Exit                                                    |
//| Exit buy when RSI crosses below buy exit level default 50        |
//| Exit sell when RSI crosses above sell exit level default 50      |
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckRSI_Exit(int cmd)
{

   double RSIcur, RSIprev;
   
   RSIcur = iRSI(Symbol(),Signal_TimeFrame, RSI_Exit_Period, PRICE_CLOSE, 1);
   RSIprev = iRSI(Symbol(),Signal_TimeFrame, RSI_Exit_Period, PRICE_CLOSE, 2);
   
   switch (cmd)
   {
     case OP_BUY  : if (RSIcur < RSI_BuyExitLevel && RSIprev > RSI_BuyExitLevel) return(true);
                    break;
     case OP_SELL : if (RSIcur > RSI_SellExitLevel && RSIprev < RSI_SellExitLevel) return(true);
   }
   
   return(false);
   
   
}

//+------------------------------------------------------------------+
//| CheckCCI_Exit                                                    |
//| Exit buy when CCI crosses below buy exit level default 0         |
//| Exit sell when CCI crosses above sell exit level default 0       |
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckCCI_Exit(int cmd)
{
   double CCIcur, CCIprev;
   
   CCIcur = iCCI(Symbol(), Signal_TimeFrame, CCI_Exit_Period, PRICE_CLOSE, 1);
   CCIprev = iCCI(Symbol(), Signal_TimeFrame, CCI_Exit_Period, PRICE_CLOSE, 2);
   
   switch (cmd)
   {
     case OP_BUY  : if (CCIcur < CCI_BuyExitLevel && CCIprev > CCI_BuyExitLevel) return(true);
                    break;
     case OP_SELL : if (CCIcur > CCI_SellExitLevel && CCIprev < CCI_SellExitLevel) return(true);
   }
   
   return(false);
   
   
}

//+------------------------------------------------------------------+
//| CheckExitCondition                                               |
//| Uses OP_BUY as cmd to check exit sell                            |
//| Uses OP_SELL as cmd to check exit buy                            |
//|                                                                  |
//| First checks for exit using SMA 200 cross                        |
//| If new exit ideas are selected those are then checked for exit   |
//| Finally use the original exit method                             |
//| Exit buy when RSI is overbought                                  |
//| Exit sell when RSI is oversold                                   |
//+------------------------------------------------------------------+
bool CheckExitCondition(int cmd)
{
   double RSI;
  
   RSI = iRSI(Symbol(), Signal_TimeFrame, myRSI_Period, PRICE_CLOSE, 1);
   
   switch (cmd)
   {
   case OP_BUY  : if (use200SMA_Exit == 1)
                  {
                     if (CheckMA(OP_SELL)) return(true);
                  }
                  switch (ExitMethod)
                  {
                   case NONE      : break;
                   case RSI_EXIT  : return (CheckRSI_Exit(cmd));
                                    break;
                   case CCI_EXIT  : return(CheckCCI_Exit(cmd));
                  }
                 
                 // Original Exit Strategies
                 
                  if ( RSI > RSI_Overbought_Value) return(true);
                  break;
   case OP_SELL : if (use200SMA_Exit == 1)
                  {
                     if (CheckMA(OP_BUY)) return(true);
                  }
                  switch (ExitMethod)
                  {
                   case NONE      : break;
                   case RSI_EXIT  : return (CheckRSI_Exit(cmd));
                                    break;
                   case CCI_EXIT  : return(CheckCCI_Exit(cmd));
                  }
                  
                 // Original Exit Strategies
                 
                   if (RSI < RSI_Oversold_Value) return(true);
   }
   
   return (false);
}

//+------------------------------------------------------------------+
//| CheckMA                                                          |
//| Buy if price closes above SMA 200                                |
//| Sell if price closes below SMA 200                               |
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckMA(int cmd)
{
  double SMA_Day3;
  
  SMA_Day3 = iMA(Symbol(),Signal_TimeFrame,MaTrend_Period, 0, MODE_SMA, PRICE_CLOSE, 1);
  switch (cmd)
  {
  case OP_BUY : if (iClose(Symbol(),Signal_TimeFrame,1) > SMA_Day3) return(true);
                break;
  case OP_SELL : if (iClose(Symbol(),Signal_TimeFrame,1) < SMA_Day3) return (true);
  }
  return(false);
}

//+------------------------------------------------------------------+
//| CheckRSI                                                         |
//| Buy when RSI is below buy level for 3 bars                       |
//| Sell when RSI is above sell level for 3 bars                     |
//| Optimized code for speed                                         |
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckRSI(int cmd)
{
  double RSI_Day_0 = 0, RSI_Day_1=0, RSI_Day_2=0, RSI_Day_3=0;

  RSI_Day_1 = iRSI(Symbol(), Signal_TimeFrame, myRSI_Period, PRICE_CLOSE, 3);
  
  switch (cmd)
  {
  case OP_BUY : if (RSI_Day_1 < BuyWhenRsiBelow)
                {
                   RSI_Day_2 = iRSI(Symbol(), Signal_TimeFrame, myRSI_Period, PRICE_CLOSE, 2);
                   if (RSI_Day_2 < RSI_Day_1)
                   {
                      RSI_Day_3 = iRSI(Symbol(), Signal_TimeFrame, myRSI_Period, PRICE_CLOSE, 1);
                      if (useTurnUpDown == 1)
                      {
                        if (RSI_Day_3 > RSI_Day_2) return(true);
                      }
                      else
                      {
                        if (RSI_Day_3 < RSI_Day_2) return(true);
                      }
                   }
                }
                break;
                
   
  case OP_SELL : if (RSI_Day_1 > SellWhenRsiAbove)
                 {
                    RSI_Day_2 = iRSI(Symbol(), Signal_TimeFrame, myRSI_Period, PRICE_CLOSE, 2);
                    if (RSI_Day_2 > RSI_Day_1)
                    {
                        RSI_Day_3 = iRSI(Symbol(), Signal_TimeFrame, myRSI_Period, PRICE_CLOSE, 1);
                        if (useTurnUpDown == 1)
                        {
                          if (RSI_Day_3 < RSI_Day_2) return(true);
                        }
                        else
                        {
                          if (RSI_Day_3 > RSI_Day_2) return(true);
                       }
                    }
                 }
  }
  
  return(false);
}

//+------------------------------------------------------------------+
//| CheckRSI_Confirmation                                            |
//| Modifications suggested by Loren                                 |
//| Require daily RSI 14 weighted close >= 35 for long               |
//| to correct the premature entry problem where price               |
//| price continues to decline for an indeterminate period.          |
//| The reverse of this for shorts w/ RSI 14 <= 65.                  |
//+------------------------------------------------------------------+
bool CheckRSI_Confirmation(int cmd)
{
  double RSI_Confirm;

  RSI_Confirm = iRSI(Symbol(), Signal_TimeFrame, RSI_ConfirmPeriod, PRICE_WEIGHTED, 1);
  
  switch (cmd)
  {
   case OP_BUY : if (RSI_Confirm > BuyConfirmLevel) return(true);
                 break;
   case OP_SELL : if (RSI_Confirm < SellConfirmLevel) return(true);
  }
  
  return (false);
  
}

//+------------------------------------------------------------------+
//| CheckEntryCondition                                              |
//|                                                                  |
//| There are 3 possible rules for entry                             |
//| Rule 1 : Use SMA 200, buy when above, sell when below            |
//| Rule 2 : Use RSI                                                 |
//| Rule 3 : Place trade only if filter allows                       |
//| Rule 4 : Lorens idea for confirmation                            |
//+------------------------------------------------------------------+
bool CheckEntryCondition(int cmd)
{
   bool rule1, rule2, rule3, rule4;
   

   rule1 = true;
   rule2 = true;
   rule3 = true;
   rule4 = true;
   
   rule1 = CheckMA(cmd);
   if (rule1)
   {
      rule2 = CheckRSI(cmd);
      if(rule2)
      {
        if (useFilter == 1) rule3 = CheckFilter(cmd);
        if (rule3)
        {
           if (useRSI_Confirmation == 1) rule4 = CheckRSI_Confirmation(cmd);
           if (rule4)
           {
              return(true);
           }
        }
      }
      
   }
   return (false);
}
  
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Start                                                            |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int start()
{ 

// Only run once per completed bar

     if(timeprev==Time[0]) return(0);
     timeprev = Time[0];
     
//+------------------------------------------------------------------+
//| Check for Open Position                                          |
//+------------------------------------------------------------------+

     HandleOpenPositions();
     
// Check if any open positions were not closed

     TradesInThisSymbol = CheckOpenPositions();
  
// Only allow 1 trade per Symbol

     if(TradesInThisSymbol >= MaxTrades) {
       return(0);}
   
// Check if last trade stopped out

   if (useDelay == 1)
   {
       if (LastTradeClosedToday()) return(0);
   }

   MM_OrderLotSize = GetLots();        

	if(CheckEntryCondition(OP_BUY))
	{
		   OpenBuyOrder(MM_OrderLotSize, StopLoss,TakeProfit, Slippage, setup, MagicNumber, Green);
		   return(0);
	}

   
	if(CheckEntryCondition(OP_SELL))
	{
         OpenSellOrder(MM_OrderLotSize, StopLoss,TakeProfit, Slippage, setup, MagicNumber, Red);
	}

  return(0);
}

double GetLots()
{
// variables used for money management
double         MM_MinLotSize=0;
double         MM_MaxLotSize=0;
double         MM_LotStep=0;
double         MM_Decimals=0;
int            MM_AcctLeverage=0;
int            MM_CurrencyLotSize=0;

 double OrderLotSize;
 
//----- Money Management & Lot Sizing Stuff.

  MM_AcctLeverage = AccountLeverage();
  MM_MinLotSize = MarketInfo(Symbol(),MODE_MINLOT);
  MM_MaxLotSize = MarketInfo(Symbol(),MODE_MAXLOT);
  MM_LotStep = MarketInfo(Symbol(),MODE_LOTSTEP);
  MM_CurrencyLotSize = MarketInfo(Symbol(),MODE_LOTSIZE);

  if(MM_LotStep == 0.01) {MM_Decimals = 2;}
  if(MM_LotStep == 0.1) {MM_Decimals = 1;}

  if (UseMoneyMgmt == true)
   {
    OrderLotSize = AccountEquity() * (RiskPercent * 0.01) / (MM_CurrencyLotSize / MM_AcctLeverage);
    if(BrokerPermitsFractionalLots == true)
      OrderLotSize = StrToDouble(DoubleToStr(OrderLotSize,MM_Decimals));
    else
      OrderLotSize = MathRound(MM_OrderLotSize);
   }
   else
   {
    OrderLotSize = LotSize;
   }

  if (OrderLotSize < MM_MinLotSize) {OrderLotSize = MM_MinLotSize;}
  if (OrderLotSize > MM_MaxLotSize) {OrderLotSize = MM_MaxLotSize;}
  return(OrderLotSize);
  
}

//+------------------------------------------------------------------+
//| OpenBuyOrder                                                     |
//| If Stop Loss or TakeProfit are used the values are calculated    |
//| for each trade                                                   |
//+------------------------------------------------------------------+
int OpenBuyOrder(double mLots, double mStopLoss, double mTakeProfit, int mSlippage, string mComment, int mMagic, color mColor)
{
   int err,ticket, digits;
   double myPrice, myBid, myStopLoss = 0, myTakeProfit = 0;
   
   myPrice = MarketInfo(Symbol(), MODE_ASK);
   myBid = MarketInfo(Symbol(), MODE_BID);
   myStopLoss = StopLong(myBid,mStopLoss);
   myTakeProfit = TakeLong(myBid,mTakeProfit);
 // Normalize all price / stoploss / takeprofit to the proper # of digits.
   digits = MarketInfo(Symbol( ), MODE_DIGITS) ;
   if (digits > 0) 
   {
     myPrice = NormalizeDouble( myPrice, digits);
     myStopLoss = NormalizeDouble( myStopLoss, digits);
     myTakeProfit = NormalizeDouble( myTakeProfit, digits); 
   }
   ticket=OrderSend(Symbol(),OP_BUY,mLots,myPrice,mSlippage,myStopLoss,myTakeProfit,mComment,mMagic,0,mColor); 
   if (ticket > 0)
   {
    if (OrderSelect( ticket,SELECT_BY_TICKET, MODE_TRADES) ) 
     {
      Print("BUY order opened : ", OrderOpenPrice( ));
//      ModifyOrder(ticket,OrderOpenPrice( ), OrderStopLoss(), myTakeProfit);
     }
   }
   else
   {
      err = GetLastError();
      if(err==0)
      { 
         return(ticket);
      }
      else
      {
         if(err==4 || err==137 ||err==146 || err==136) //Busy errors
         {
            Sleep(5000);
         }
         else //normal error
         {
           Print("Error opening BUY order [" + setup + "]: (" + err + ") " + ErrorDescription(err)); 
         }  
      }
   }
   
   return(ticket);
}

//+------------------------------------------------------------------+
//| OpenSellOrder                                                    |
//| If Stop Loss or TakeProfit are used the values are calculated    |
//| for each trade                                                   |
//+------------------------------------------------------------------+
void OpenSellOrder(double mLots, double mStopLoss, double mTakeProfit, int mSlippage, string mComment, int mMagic, color mColor)
{
   int err, ticket, digits;
   double myPrice, myAsk, myStopLoss = 0, myTakeProfit = 0;
   
   myPrice = MarketInfo(Symbol( ), MODE_BID);
   myAsk = MarketInfo(Symbol( ), MODE_ASK);
   myStopLoss = StopShort(myAsk,mStopLoss);
   myTakeProfit = TakeShort(myAsk,mTakeProfit);
   
 // Normalize all price / stoploss / takeprofit to the proper # of digits.
   digits = MarketInfo(Symbol( ), MODE_DIGITS) ;
   if (digits > 0) 
   {
     myPrice = NormalizeDouble( myPrice, digits);
     myStopLoss = NormalizeDouble( myStopLoss, digits);
     myTakeProfit = NormalizeDouble( myTakeProfit, digits); 
   }
   ticket=OrderSend(Symbol(),OP_SELL,mLots,myPrice,mSlippage,myStopLoss,myTakeProfit,mComment,mMagic,0,mColor); 
   if (ticket > 0)
   {
     if (OrderSelect( ticket,SELECT_BY_TICKET, MODE_TRADES) ) 
     {
      Print("Sell order opened : ", OrderOpenPrice());
//      ModifyOrder(ticket,OrderOpenPrice( ), OrderStopLoss(), myTakeProfit);
     }
   }
   else
   {
      err = GetLastError();
      if(err==0)
      { 
         return(ticket);
      }
      else
      {
        if(err==4 || err==137 ||err==146 || err==136) //Busy errors
        {
           Sleep(5000);
        }
        else //normal error
        {
           Print("Error opening Sell order [" + mComment + "]: (" + err + ") " + ErrorDescription(err));
        }
      } 
   }
   
   return(ticket);
}


double StopLong(double price,int stop)
{
 if(stop==0)
  return(0);
 else
  return(price-(stop*Point));
}

double StopShort(double price,int stop)
{
 if(stop==0)
  return(0);
 else
  return(price+(stop*Point));
}

double TakeLong(double price,int take)
{
 if(take==0)
  return(0);
 else
  return(price+(take*Point));
}

double TakeShort(double price,int take)
{
 if(take==0)
  return(0);
 else
  return(price-(take*Point));
}

//+------------------------------------------------------------------+
//| Handle Open Positions                                            |
//| Check if any open positions need to be closed or modified        |
//+------------------------------------------------------------------+
int HandleOpenPositions()
{
   int cnt;
   
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
   {
      OrderSelect (cnt, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol() != Symbol()) continue;
      if ( OrderMagicNumber() != MagicNumber)  continue;
      
      if(OrderType() == OP_BUY)
      {
            
         if (CheckExitCondition(OP_BUY))
          {
              CloseOrder(OrderTicket(),OrderLots(),OP_BUY);
          }
          else
          {
            if (UseTrailingStop)
            {
               HandleTrailingStop(OP_BUY,OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit());
            }
          }
      }

      if(OrderType() == OP_SELL)
      {
          if (CheckExitCondition(OP_SELL))
          {
             CloseOrder(OrderTicket(),OrderLots(),OP_SELL);
          }
          else
          {
            if (UseTrailingStop)
            {
               HandleTrailingStop(OP_SELL,OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit());
            }
          }
      }
   }
}

//+------------------------------------------------------------------+
//| Check Open Position Controls                                     |
//+------------------------------------------------------------------+
  
int CheckOpenPositions()
{
   int cnt, total;
   int NumTrades;
   
   NumTrades = 0;
   total=OrdersTotal();
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
     {
      OrderSelect (cnt, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol() != Symbol()) continue;
      if ( OrderMagicNumber() != MagicNumber)  continue;
      
      if(OrderType() == OP_BUY )  NumTrades++;
      if(OrderType() == OP_SELL )  NumTrades++;
             
     }
     return (NumTrades);
  }
  
int CloseOrder(int ticket,double numLots,int cmd)
{
   int CloseCnt, err, digits;
   double myPrice;
   
   if (cmd == OP_BUY) myPrice = MarketInfo(Symbol( ), MODE_BID);
   if (cmd == OP_SELL) myPrice = MarketInfo(Symbol( ), MODE_ASK);
   digits = MarketInfo(Symbol( ), MODE_DIGITS) ;
   if (digits > 0)  myPrice = NormalizeDouble( myPrice, digits);
   // try to close 3 Times
      
    CloseCnt = 0;
    while (CloseCnt < 3)
    {
       if (!OrderClose(ticket,numLots,myPrice,Slippage,Violet))
       {
         err=GetLastError();
         Print(CloseCnt," Error closing order : (", err , ") " + ErrorDescription(err));
         if (err > 0) CloseCnt++;
       }
       else
       {
         CloseCnt = 3;
       }
    }
}

int ModifyOrder(int ord_ticket,double op, double price,double tp, color mColor)
{
    int CloseCnt, err;
    
    CloseCnt=0;
    while (CloseCnt < 3)
    {
       if (OrderModify(ord_ticket,op,price,tp,0,mColor))
       {
         CloseCnt = 3;
       }
       else
       {
          err=GetLastError();
          Print(CloseCnt," Error modifying order : (", err , ") " + ErrorDescription(err));
         if (err>0) CloseCnt++;
       }
    }
}

double ValidStopLoss(int type, double price, double SL)
{

   double minstop, pp;
   double newSL;
   
   pp = MarketInfo(Symbol(), MODE_POINT);
   minstop = MarketInfo(Symbol(),MODE_STOPLEVEL);
   newSL = SL;
   if (type == OP_BUY)
   {
		 if((price - SL) < minstop*pp) newSL = price - minstop*pp;
   }
   if (type == OP_SELL)
   {
       if((SL-price) < minstop*pp)  newSL = price + minstop*pp;  
   }

   return(newSL);   
}

//+------------------------------------------------------------------+
//| HandleTrailingStop                                               |
//| Type 1 moves the stoploss without delay.                         |
//| Type 2 waits for price to move the amount of the trailStop       |
//| before moving stop loss then moves like type 1                   |
//| Type 3 uses up to 3 levels for trailing stop                     |
//|      Level 1 Move stop to 1st level                              |
//|      Level 2 Move stop to 2nd level                              |
//|      Level 3 Trail like type 1 by fixed amount other than 1      |
//| Type 4 Move stop to breakeven + Lockin, no trail                 |
//| Type 5 uses steps for 1, every step pip move moves stop 1 pip    |
//| Type 6 Uses EMA to set trailing stop                             |
//| Type 7 Uses Paraboloc SAR                                        |
//| Type 8 Uses Parabolic SAR coded by bluto from original EA        |
//+------------------------------------------------------------------+
int HandleTrailingStop(int type, int ticket, double op, double os, double tp)
{
   switch (TrailingStopType)
   {
     case 1 : Immediate_TrailingStop (type, ticket, op, os, tp);
              break;
     case 2 : Delayed_TrailingStop (type, ticket, op, os, tp);
              break;
     case 3 : ThreeLevel_TrailingStop (type, ticket, op, os, tp);
              break;
     case 4 : BreakEven_TrailingStop (type, ticket, op, os, tp);
              break;
	  case 5 : eTrailingStop (type, ticket, op, os, tp);
              break;
	  case 6 : EMA_TrailingStop (type, ticket, op, os, tp);
              break;
	  case 7 : pSAR_TrailingStop (type, ticket, op, os, tp);
              break;
     case 8 : BlutoParabolicSAR (type, ticket, op, os, tp);
              break;
	}
   return(0);
}

//+------------------------------------------------------------------+
//|                                           BreakEvenExpert_v1.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
void BreakEven_TrailingStop(int type, int ticket, double op, double os, double tp)
{

   int digits;
   double pBid, pAsk, pp, BuyStop, SellStop;

   pp = MarketInfo(Symbol(), MODE_POINT);
   digits = MarketInfo(Symbol(), MODE_DIGITS);
   
  if (type==OP_BUY)
  {
    pBid = MarketInfo(Symbol(), MODE_BID);
    if ( pBid-op > pp*BreakEven ) 
    {
       BuyStop = op + LockInPips * pp;
       if (digits > 0) BuyStop = NormalizeDouble( BuyStop, digits);
		 BuyStop = ValidStopLoss(OP_BUY,pBid, BuyStop);   
       if (digits > 0) BuyStop = NormalizeDouble( BuyStop, digits);
       if (os < BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
		 return;
	 }
  }
  if (type==OP_SELL)
  {
    pAsk = MarketInfo(Symbol(), MODE_ASK);
    if ( op - pAsk > pp*BreakEven ) 
    {
       SellStop = op - LockInPips * pp;
       if (digits > 0) SellStop = NormalizeDouble( SellStop, digits);
       SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);  
       if (digits > 0) SellStop = NormalizeDouble( SellStop, digits);
       if (os > SellStop) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
		 return;
    }
  }   
}

//+------------------------------------------------------------------+
//|                                                   e-Trailing.mq4 |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//| 12.09.2005 Автоматический Trailing Stop всех открытых позиций    |
//|            Вешать только на один график                          |
//+------------------------------------------------------------------+
void eTrailingStop(int type, int ticket, double op, double os, double tp)
{

  int digits;
  double pBid, pAsk, pp, BuyStop, SellStop;

  pp = MarketInfo(Symbol(), MODE_POINT);
  digits = MarketInfo(Symbol(), MODE_DIGITS) ;
  if (type==OP_BUY)
  {
    pBid = MarketInfo(Symbol(), MODE_BID);
    if ((pBid-op)>eTrailingStop*pp)
    {
      if (os<pBid-(eTrailingStop+eTrailingStep-1)*pp)
      {
        BuyStop = pBid-eTrailingStop*pp;
        if (digits > 0) BuyStop = NormalizeDouble( BuyStop, digits);
		  BuyStop = ValidStopLoss(OP_BUY, pBid, BuyStop);   
        if (digits > 0) BuyStop = NormalizeDouble( BuyStop, digits);
        ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
        return;
      }
    }
  }
  if (type==OP_SELL)
  {
    pAsk = MarketInfo(Symbol(), MODE_ASK);
    if (op - pAsk > eTrailingStop*pp)
    {
      if (os > pAsk + (eTrailingStop + eTrailingStep-1)*pp || os==0)
      {
        SellStop = pAsk + eTrailingStop * pp;
        if (digits > 0) SellStop = NormalizeDouble( SellStop, digits);
        SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);  
        if (digits > 0) SellStop = NormalizeDouble( SellStop, digits);
        ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
        return;
      }
    }
  }
}

//+------------------------------------------------------------------+
//|                                           EMATrailingStop_v1.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
void EMA_TrailingStop(int type, int ticket, double op, double os, double tp)
{
   int digits;
   double pBid, pAsk, pp, BuyStop, SellStop, ema;

   pp = MarketInfo(Symbol(), MODE_POINT);
   digits = MarketInfo(Symbol(), MODE_DIGITS) ;
   ema = iMA(Symbol(),EMATimeFrame,EMAPeriod,0,MODE_EMA,Price,EMAShift);
   
   if (type==OP_BUY) 
   {
	   BuyStop = ema;
      pBid = MarketInfo(Symbol(),MODE_BID);
		if(os == 0 && InitialStop>0 ) BuyStop = pBid-InitialStop*pp;
		if (digits > 0) BuyStop = NormalizeDouble(SellStop, digits); 
		BuyStop = ValidStopLoss(OP_BUY, pBid, BuyStop);   
		if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits);
		Print("MA=",ema," BuyStop=",BuyStop);
		if ((op <= BuyStop && BuyStop > os) || os==0) 
		{
          ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
			 return;
      }
   }   

   if (type==OP_SELL)
   {
	   SellStop = ema;
      pAsk = MarketInfo(Symbol(),MODE_ASK);
      if (os==0 && InitialStop > 0) SellStop = pAsk+InitialStop*pp;
		if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
		SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);
		if (digits > 0) SellStop = NormalizeDouble(SellStop, digits);
      Print("MA=",ema," SellStop=",SellStop);   
      if( (op >= SellStop && os > SellStop) || os==0) 
      {
          ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
			 return;
      }
   }
}

//+------------------------------------------------------------------+
//|                                                b-TrailingSAR.mqh |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//|    21.11.2005  Библиотека функций трала по параболику.           |
//|  Для использования добавить строку в модуле start                |
//|  if (UseTrailing) TrailingPositions();                           |
//+------------------------------------------------------------------+
void pSAR_TrailingStop(int type, int ticket, double op, double os, double tp)
{
   int digits;
   double pBid, pAsk, pp, BuyStop, SellStop, spr;
   double sar1, sar2;
  
   pp = MarketInfo(Symbol(), MODE_POINT);
   digits = MarketInfo(Symbol(), MODE_DIGITS) ;
   pBid = MarketInfo(Symbol(), MODE_BID);
   pAsk = MarketInfo(Symbol(), MODE_ASK);
   sar1=iSAR(NULL, 0, StepParabolic, MaxParabolic, 1);
   sar2=iSAR(NULL, 0, StepParabolic, MaxParabolic, 2);
   spr = pAsk - pBid;
   if (digits > 0) spr = NormalizeDouble(spr, digits); 
   
   if (type==OP_BUY)
   {
     pBid = MarketInfo(Symbol(), MODE_BID);
     if (sar2 < sar1)
     {
        BuyStop = sar1-Interval*pp;
        if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits); 
	     BuyStop = ValidStopLoss(OP_BUY, pBid, BuyStop);   
        if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits); 
        if (os<BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
     }
   }
   if (type==OP_SELL)
   {
     if (sar2 > sar1)
     {
        SellStop = sar1 + Interval * pp + spr;
        if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
	     SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);   
        if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
        if (os>SellStop || os==0) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
     }
   }
}

// Manage Paraolic SAR 
void BlutoParabolicSAR(int type, int ticket, double op, double os, double tp)
{
   double pSar1 = 0, pSar2 = 0;
   int digits;
   double pt, pBid, pAsk, pp, BuyStop, SellStop;

   pp = MarketInfo(Symbol(), MODE_POINT);
   digits = MarketInfo(Symbol( ), MODE_DIGITS);
   
// Added pSar1 and pSar2 for faster backtesting
  pSar1 = iSAR(NULL,Signal_TimeFrame,SarStep,SarMax,1);
  pSar2 = iSAR(NULL,Signal_TimeFrame,SarStep,SarMax,2);

  if (type == OP_BUY)
  {
     pBid = MarketInfo(Symbol(), MODE_BID);
     if ( (pSar1> os) && (pBid > pSar1) && (op < pSar1) && (pSar1 > pSar2))
     {
         if (digits > 0)pSar1 = NormalizeDouble(pSar1, digits); 
         ModifyOrder(ticket,op,pSar1,tp,Blue);
         Print("Order # ",ticket," updated at ",Hour(),":",Minute(),":",Seconds());
         return(0);
     }
   }
   if (type == OP_SELL)
   {
      pAsk = MarketInfo(Symbol(), MODE_ASK);
      if ((pSar1 < os) && (pAsk < pSar1) && (op > pSar1) && (pSar1 < pSar2))
         {
          ModifyOrder(ticket,op,pSar1,tp,Blue);
          Print("Order # ",ticket," updated at ",Hour(),":",Minute(),":",Seconds());
          return(0);
         }
   }
}

//+------------------------------------------------------------------+
//|                                      ThreeLevel_TrailingStop.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by MrPip,robydoby314@yahoo.com   |   
//|                                                                  |
//| Uses up to 3 levels for trailing stop                            |
//|      Level 1 Move stop to 1st level                              |
//|      Level 2 Move stop to 2nd level                              |
//|      Level 3 Trail like type 1 by fixed amount other than 1      |
//+------------------------------------------------------------------+
void ThreeLevel_TrailingStop(int type, int ticket, double op, double os, double tp)
{

   int digits;
   double pBid, pAsk, pp, BuyStop, SellStop;

   pp = MarketInfo(Symbol(), MODE_POINT);
   digits = MarketInfo(Symbol(), MODE_DIGITS) ;

   if (type == OP_BUY)
   {
      pBid = MarketInfo(Symbol(), MODE_BID);
      if (pBid - op > FirstMove * pp)
      {
         BuyStop = op + FirstMove*pp - FirstStopLoss * pp;
         if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits); 
		   BuyStop = ValidStopLoss(OP_BUY, pBid, BuyStop);   
         if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits); 
         if (os < BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
      }
              
      if (pBid - op > SecondMove * pp)
      {
         BuyStop = op + SecondMove*pp - SecondStopLoss * pp;
         if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits); 
		   BuyStop = ValidStopLoss(OP_BUY, pBid, BuyStop);   
         if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits); 
         if (os < BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
      }
                
      if (pBid - op > ThirdMove * pp)
      {
         BuyStop = pBid  - ThirdMove*pp;
         if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits); 
		   BuyStop = ValidStopLoss(OP_BUY, pBid, BuyStop);   
         if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits); 
         if (os < BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
      }
   }
       
    if (type ==  OP_SELL)
    {
        pAsk = MarketInfo(Symbol(), MODE_ASK);
        if (op - pAsk > FirstMove * pp)
        {
           SellStop = op - FirstMove * pp + FirstStopLoss * pp;
           if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
		     SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);   
           if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
           if (os > SellStop) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
        }
        if (op - pAsk > SecondMove * pp)
        {
           SellStop = op - SecondMove * pp + SecondStopLoss * pp;
           if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
		     SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);   
           if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
           if (os > SellStop) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
        }
        if (op - pAsk > ThirdMove * pp)
        {
           SellStop = pAsk + ThirdMove * pp;               
           if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
		     SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);   
           if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
           if (os > SellStop) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
        }
    }

}

//+------------------------------------------------------------------+
//|                                       Immediate_TrailingStop.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by MrPip,robydoby314@yahoo.com   |
//|                                                                  |   
//| Moves the stoploss without delay.                                |
//+------------------------------------------------------------------+
void Immediate_TrailingStop(int type, int ticket, double op, double os, double tp)
{

   int digits;
   double pt, pBid, pAsk, pp, BuyStop, SellStop;

   pp = MarketInfo(Symbol(), MODE_POINT);
   digits = MarketInfo(Symbol( ), MODE_DIGITS);
   
   if (type==OP_BUY)
   {
     pBid = MarketInfo(Symbol(), MODE_BID);
     pt = StopLoss * pp;
     if(pBid-os > pt)
     {
       BuyStop = pBid - pt;
       if (digits > 0) BuyStop = NormalizeDouble( BuyStop, digits);
		 BuyStop = ValidStopLoss(OP_BUY,pBid, BuyStop);   
       if (digits > 0) BuyStop = NormalizeDouble( BuyStop, digits);
       if (os < BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
		 return;
	  }
   }
   if (type==OP_SELL)
   {
     pAsk = MarketInfo(Symbol(), MODE_ASK);
     pt = StopLoss * pp;
     if(os - pAsk > pt)
     {
       SellStop = pAsk + pt;
       if (digits > 0) SellStop = NormalizeDouble( SellStop, digits);
       SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);  
       if (digits > 0) SellStop = NormalizeDouble( SellStop, digits);
       if (os > SellStop) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
		 return;
     }
   }   
}

//+------------------------------------------------------------------+
//|                                         Delayed_TrailingStop.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by MrPip,robydoby314@yahoo.com   |
//|                                                                  |   
//| Waits for price to move the amount of the TrailingStop           |
//| Moves the stoploss pip for pip after delay.                      |
//+------------------------------------------------------------------+
void Delayed_TrailingStop(int type, int ticket, double op, double os, double tp)
{
   int digits;
   double pt, pBid, pAsk, pp, BuyStop, SellStop;

   pp = MarketInfo(Symbol(), MODE_POINT);
   pt = TrailingStop * pp;
   digits = MarketInfo(Symbol(), MODE_DIGITS);
   
   if (type==OP_BUY)
   {
     pBid = MarketInfo(Symbol(), MODE_BID);
     BuyStop = pBid - pt;
     if (digits > 0) BuyStop = NormalizeDouble( BuyStop, digits);
	  BuyStop = ValidStopLoss(OP_BUY,pBid, BuyStop);   
     if (digits > 0) BuyStop = NormalizeDouble( BuyStop, digits);
     if (pBid-op > pt && os < BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
	  return;
   }
   if (type==OP_SELL)
   {
     pAsk = MarketInfo(Symbol(), MODE_ASK);
     pt = TrailingStop * pp;
     SellStop = pAsk + pt;
     if (digits > 0) SellStop = NormalizeDouble( SellStop, digits);
     SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);  
     if (digits > 0) SellStop = NormalizeDouble( SellStop, digits);
     if (op - pAsk > pt && os > SellStop) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
	  return;
   }   
}

int func_Symbol2Val(string symbol)
 {
   string mySymbol = StringSubstr(symbol,0,6);
   
	if(mySymbol=="AUDCAD") return(1);
	if(mySymbol=="AUDJPY") return(2);
	if(mySymbol=="AUDNZD") return(3);
	if(mySymbol=="AUDUSD") return(4);
	if(mySymbol=="CHFJPY") return(5);
	if(mySymbol=="EURAUD") return(6);
	if(mySymbol=="EURCAD") return(7);
	if(mySymbol=="EURCHF") return(8);
	if(mySymbol=="EURGBP") return(9);
	if(mySymbol=="EURJPY") return(10);
	if(mySymbol=="EURUSD") return(11);
	if(mySymbol=="GBPCHF") return(12);
	if(mySymbol=="GBPJPY") return(13);
	if(mySymbol=="GBPUSD") return(14);
	if(mySymbol=="NZDJPY") return(15);
	if(mySymbol=="NZDUSD") return(16);
	if(mySymbol=="USDCAD") return(17);
	if(mySymbol=="USDCHF") return(18);
	if(mySymbol=="USDJPY") return(19);
   Comment("unexpected Symbol");
	return(999);
}

//+------------------------------------------------------------------+
//| Time frame interval appropriation  function                      |
//+------------------------------------------------------------------+

int func_TimeFrame_Const2Val(int Constant ) {
   switch(Constant) {
      case 1:  // M1
         return(1);
      case 5:  // M5
         return(2);
      case 15:
         return(3);
      case 30:
         return(4);
      case 60:
         return(5);
      case 240:
         return(6);
      case 1440:
         return(7);
      case 10080:
         return(8);
      case 43200:
         return(9);
   }
}

//+------------------------------------------------------------------+
//| Time frame string appropriation  function                               |
//+------------------------------------------------------------------+

string func_TimeFrame_Val2String(int Value ) {
   switch(Value) {
      case 1:  // M1
         return("PERIOD_M1");
      case 2:  // M1
         return("PERIOD_M5");
      case 3:
         return("PERIOD_M15");
      case 4:
         return("PERIOD_M30");
      case 5:
         return("PERIOD_H1");
      case 6:
         return("PERIOD_H4");
      case 7:
         return("PERIOD_D1");
      case 8:
         return("PERIOD_W1");
      case 9:
         return("PERIOD_MN1");
   	default: 
   		return("undefined " + Value);
   }
}





