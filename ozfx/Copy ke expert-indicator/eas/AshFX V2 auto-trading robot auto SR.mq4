//+------------------------------------------------------------------+
//|                  AshFX V2 auto-trading robot by SteveHopwood.mq4 |
//|                                  Copyright © 2009, Steve Hopwood |
//|                              http://www.hopwood3.freeserve.co.uk |
//+------------------------------------------------------------------+
//|  mods by macman 28/1/2010 to work with the Recent SR indicator   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Steve Hopwood"
#property link      "http://www.hopwood3.freeserve.co.uk"
#include <WinUser32.mqh>
#include <stdlib.mqh>
#include <OrderReliable_V1_1_0.mqh> //Added by macman
#define  NL    "\n"
#define GlobalPrefix "AshFX " //Used for prefixing all objects created by this EA.
//AO and AC colours
#define green "Green"
#define red "Red"
//Directions
#define up "Up"
#define down "Down"
//Trading status
#define pending "PSAR has flipped. Waiting for the new candle to see if a trade can be sent"
#define waiting "Waiting for a PSAR flip"
#define MonitoringLong "Monitoring Long trade"
#define MonitoringShort "Monitoring Short trade"
#define  hedge "Hedge"


/*
void DisplayUserFeedback()
int start()
int init()
int deinit()

--Trading functions--
bool SendSingleTrade(int type)
double GetStopLoss(int type)
void CheckForOpenTrade()
void CloseOpenTrade()
double GetStopLoss(int type)
void CalculateLotSize()

--Indi finding fundtions--
void GetColours()
void GetSthochastic()
void GetMarketDirection()
void GetTradingStatus()
void HasSarsChangedDirection()
void CalculateAverageCandleLength()
void CalculateCandleLength(int shift)
void GetSwingHiLo()

--Trade management functions--
void ManageTrade()
void PartCloseOpenTrade()
double CalculateBEP()
void JumpingStopLoss() 

--Hedging functions--
void Hedging() is the equivalent to start() in my LR hedging robot
void Hedging()
bool IsTradeAHedge()
void DoesTradeNeedHedging()
void ManageHedgedPosition()
void CountOpenTrades()

--Horizontal line s\r--
void GetHorizontalSRlines()
--Big number s\r--
void GetNextBigNumbers()

--Misc functions--
string SetupPendingString()
void DeleteOrphanHedgeGVs()

*/

//Externals
extern string     GVI="-----General trade inputs-----";
extern bool       TradeLong=true;
extern bool       TradeShort=true;
extern double     Lot=0.02;
extern int        MinStopLoss=2000;
extern string     TradeComment="AshFXV2 auto SR";
extern bool       CriminalIsECN=false;
extern bool       TradeSundayCandle=false;
extern string     mni="Min 5 digits for magic number";
extern int        MagicNumber=12345;
extern int        MaxSpreadAllowed=200;
extern string     mm="Money management";
extern bool       RobotCalulatesLotSize=false;
extern double     LotsPerCurrencyUnit=0.02;
extern double     CurrencyUnit=500;
extern string     his="----Hedging----";
extern bool       HedgeNotStopLoss=false;
extern int        StartHedgingAtLossPips=2000;
extern int        HedgingIncrementPips=2000;
extern double     BreakEvenProfitPercent=1;
extern string     clf="----Candle length and wick filters----";
extern int        CandleLengthLookBackBars=100;  
extern double     CandleLengthOverAverage=30;
extern double     AllowableWickPercentage=100;
extern string     mi="-----Open trade management inputs-----";
extern string     slf="----Stop Loss Manipulation----";
extern string     JSL="Jumping stop loss settings";
extern bool       JumpingStop=false;
extern int        JumpingStopPips=1000;
extern bool       JumpAfterBreakevenOnly=true;
extern string     pci="Part-close settings";
extern bool       PartCloseEnabled=true;
extern double     Close_Lots = 0.01;
extern double     Preserve_Lots=0.01;
extern double     BreakEvenProfit=100;
extern bool       AutoCalculatePartClose=true;
extern string     sr="----Support and resistance----";
extern string     hl="Horizontal lines";
extern bool       UseHorizontalLineSR=true;
extern color      SrLineColour=Indigo;
extern int        HlAllowablePipsAway=300;
extern string     bn="Big numbers";
extern bool       UseBigNumbers=true;
extern int        BnAllowablePipsAway=500;
extern string     bab="-----Odds and ends-----";
extern bool       ShowAlerts=true;
extern int        DisplayGapSize=30;
extern string     CurrencySymbol="£";


//AO and AC colours
string            AoColour;
string            AcColour;
//Current candle colour
string            CurrCandleColour;
//Stochastic
double            StochMain;
double            StochSignal;
string            StochDirection;

//Average candle length & length of current candle (i.e. the trading candle)
double            AverageCandleLength;
double            CurrentCandleLength;
double            TradeableCandleLength;//Av length plus CandleLengthOverAverage%
//Wick lengths and percentages of candle length
double            UpperWickLength;
double            UpperWickPercent;
double            LowerWickLength;
double            LowerWickPercent;

//Market direction according to psar
string            MarketDirection;

//Trading status
string            TradingStatus;

// Pending global variable name
string            GvPending;

//Trade direction
int               TradeDirection;// 0 for buy, 1 for sell

//Existing original open trade variables
bool              TradeExists = false;
int               OriginalTradeTicketNo;
bool              ForceFullTradeClosure;//Force the ea to close an open trade when an attempt to do so has failed
bool              ForcePartTradeClosure;//Force the ea to part-close an open trade when an attempt to do so has failed

//Hedging variables
string            HedgeGv="AshFX hedge gv "; //Hedging gv name - holds the next upl percent of balance at which to send a hedge trade
int               NextHedgePercentage;//Next point at which the ea should enter the close-hedge-open-new-hedge rpimd
bool              CloseHedgedPosition;//Set to true when a hedged position can be closed at be. to force retries if the close fails
int               CountedTrades;
int               BuysOpen;
int               SellsOpen;
double            OpenTradesUpl;
double            BuyTradesUpl;
double            SellTradesUpl;
bool              HedgeTradeExists;

//Horizontal line s\r
double            SrLineArray[];
double            NextResistanceLine;
double            NextSupportLine;

//Big number s\r
double            BigNumberHigh;
double            BigNumberLow;

//Swing hi-lo
double            SwingHi;
double            SwingLo;

//Misc
string            ScreenMessage, Gap;
bool              RobotDisabled=false;
int               OldBars;//For detecting a candle direction change
double            StopLoss;
string            GetPends;//Holds list of pending trades
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+

void DisplayUserFeedback()
{

   ScreenMessage = "";
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Lot size = ", Lot, NL);
   if (TradeLong) ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Trading long", NL);
   if (TradeShort) ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Trading short", NL);
   if (CriminalIsECN) ScreenMessage = StringConcatenate(ScreenMessage, Gap, "CriminalIsECN = true          ");
   else ScreenMessage = StringConcatenate(ScreenMessage, Gap, "CriminalIsECN = false          ");
   if (TradeSundayCandle) ScreenMessage = StringConcatenate(ScreenMessage, "Trading the Sunday candle", NL);
   else ScreenMessage = StringConcatenate(ScreenMessage, "Not trading the Sunday candle", NL);
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Management functions", NL);
   if (!PartCloseEnabled) ScreenMessage = StringConcatenate(ScreenMessage, Gap, "     Part close is not enabled. Part-closure is part of Ash's strategy, so you might like to think again about this", NL);
   if (PartCloseEnabled)
   {
      if (AutoCalculatePartClose) ScreenMessage = StringConcatenate(ScreenMessage, Gap, "     Part close is enabled. AutoCalculatePartClose is enabled. The robot will calculate Close_Lots for you.",NL);
      if (!AutoCalculatePartClose) ScreenMessage = StringConcatenate(ScreenMessage, Gap, "     Part close is enabled. Close_Lots = ", Close_Lots, ": Preserve_Lots = ", Preserve_Lots, NL);
   }
   if (!JumpingStop) ScreenMessage = StringConcatenate(ScreenMessage, Gap, "     Jumping stop is not enabled.", NL);
   if (JumpingStop) ScreenMessage = StringConcatenate(ScreenMessage, Gap, "     Jumping stop is enabled every ", JumpingStopPips, " pips", NL);
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Magic number = ", MagicNumber, NL);
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, "MaxSpreadAllowed = ", MaxSpreadAllowed, " (Current spread = ", MarketInfo(Symbol(), MODE_SPREAD), ")", NL);
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Long trades swap = ", MarketInfo(Symbol(), MODE_SWAPLONG), NL);
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Short trades swap = ", MarketInfo(Symbol(), MODE_SWAPSHORT), NL);
   if (HedgeNotStopLoss)
   {
      double bep = AccountBalance() * (BreakEvenProfitPercent / 100);
      ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Hedging is enabled.");
      ScreenMessage = StringConcatenate(ScreenMessage, "  BreakEvenProfitPercent = ",BreakEvenProfitPercent, " (", DoubleToStr(bep,2), ")",NL);
   }//if (HedgeNotStopLoss)
   else ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Swing high = ", DoubleToStr(SwingHi, Digits), ": Swing low = ", DoubleToStr(SwingLo,Digits), NL);

   ScreenMessage = StringConcatenate(ScreenMessage, NL);
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, "AO colour = ", AoColour, NL);
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Ac colour = ", AcColour, NL);
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Current candle colour = ", CurrCandleColour, NL);
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Stochastic direction = ", StochDirection, " (", StochMain, " ", StochSignal, ")",NL);
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Market direction = ", MarketDirection,NL);
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Average candle length = ", AverageCandleLength," (tradeable length = ",TradeableCandleLength, "): Current candle length = ", CurrentCandleLength, ": CandleLengthOverAverage = ", CandleLengthOverAverage, "%",NL);
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Allowable wick % = ", AllowableWickPercentage, "%: Candle wick upper length = ", UpperWickLength," (", DoubleToStr(UpperWickPercent,0), "%): Candle wick lower length = ", LowerWickLength, " (", DoubleToStr(LowerWickPercent,0), "%)", NL);
   if (UseHorizontalLineSR)
   {
      ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Using horizontal S\R lines");
      ScreenMessage = StringConcatenate(ScreenMessage, ": Resistance = ", DoubleToStr(NextResistanceLine, Digits), ": Support = ", DoubleToStr(NextSupportLine, Digits));
      ScreenMessage = StringConcatenate(ScreenMessage, ": HlAllowablePipsAway = ", HlAllowablePipsAway, NL);
   }//if (UseHorizontalLineSR)
   if (UseBigNumbers)
   {
      ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Using Big Number S\R");
      ScreenMessage = StringConcatenate(ScreenMessage, ": High = ", DoubleToStr(BigNumberHigh, Digits), ": Low = ", DoubleToStr(BigNumberLow, Digits));
      ScreenMessage = StringConcatenate(ScreenMessage, ": BnAllowablePipsAway = ", BnAllowablePipsAway, NL);
   
   }//if (UseBigNumbers)
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Trading status = ", TradingStatus,NL);
   
   ScreenMessage = StringConcatenate(ScreenMessage, NL, Gap, "Pending trades list: ");
   ScreenMessage = StringConcatenate(ScreenMessage, GetPends, NL);   

   //ScreenMessage = StringConcatenate(ScreenMessage, Gap, "--", NL);
   Comment(ScreenMessage);

}//void DisplayUserFeedback()

int init()
{
//----
   //Check magic number.
   if (!IsDemo() )
   {
      if (MagicNumber == 12345)
      {
         MessageBox("You cannot run this robot on a live account until you change the MagicNumber input from the default of 12345." + NL 
                    + "Please reload the robot with a new MagicNumber input.");
         Comment("                This robot can do nothing. Please reload it");
         RobotDisabled = true;
         return;
      }//if (MagicNumber == 12345)
   }//if (!IsDemo)
      
   //Insufficient length
   string mn = DoubleToStr(MagicNumber,0);
   if (StringLen(mn) < 5)
   {
      MessageBox("Your MagicNumber input needs to be at least 5 digits long, Your MagicNumber is " + mn + NL 
                 + "Please reload the robot with the MagicNumber input containing at least 5 digits - the more the better.");
      Comment("                This robot can do nothing. Please reload it");
      RobotDisabled = true;
      return;
   }//if (StringLen(mn) < 5)
   
   Gap="";
   if (DisplayGapSize >0)
   {
      for (int cc=0; cc< DisplayGapSize; cc++)
      {
         Gap = StringConcatenate(Gap, " ");
      }   
   }//if (DisplayGapSize >0)
   
   //Set up pending gv name
   GvPending = StringConcatenate(GlobalPrefix, "pending ", Symbol());
   
   //Set up hedge gv name
   HedgeGv = StringConcatenate(HedgeGv, Symbol());
   if (HedgeNotStopLoss) 
   {
      if (!GlobalVariableCheck(HedgeGv) ) GlobalVariableSet(HedgeGv, StartHedgingAtLossPips);//Reset the hedge pips setting
   }//if (HedgeNotStopLoss) 
   
   //Adjust incorrect lot sizes
   if (Lot < MarketInfo(Symbol(), MODE_MINLOT) )
   {
      Lot = MarketInfo(Symbol(), MODE_MINLOT) * 2;
      string message = StringConcatenate("Your lot size was too small for this broker.",NL, "It has been adjusted to ",Lot);
      MessageBox(message);
   }//if (Lot < MarketInfo(Symbol(), MODE_MINLOT) )
   
   if (Lot > MarketInfo(Symbol(), MODE_MAXLOT) )
   {
      Lot = MarketInfo(Symbol(), MODE_MAXLOT);
      message = StringConcatenate("Your lot size was too big for this broker.",NL, "It has been adjusted to ",Lot);
      MessageBox(message);
   }//if (Lot < MarketInfo(Symbol(), MODE_MAXLOT) )
   
   if (!HedgeNotStopLoss) GetSwingHiLo();
   
   OldBars = Bars;//Force the robot to wait for the start of a new candle
     
   /////////////////////////////////////////////////////////////////////////////////////////////////
   // Code block to display the status of the indicators, current candle, psar and trading status
   GetColours();//AO, AC and current candle colours
   GetSthochastic();
   GetMarketDirection();//Compares current market to PSAR
   GetTradingStatus();
   CalculateAverageCandleLength();
   CalculateCandleLength(0);
   //Horizontal line s\r
   if (UseHorizontalLineSR) 
   {
      GetHorizontalSRlines();//Calculates the next s\r points from the lines on screen
   }//if (UseHorizontalLineSR) 
   //Big number s\r
   if (UseBigNumbers) GetNextBigNumbers();
   
   if (RobotCalulatesLotSize) CalculateLotSize();
   
   DisplayUserFeedback();
   // End of code block to display the status of the indicators
   /////////////////////////////////////////////////////////////////////////////////////////////////

   
   //start();



//----
   return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//----
   Comment("");
//----
   return(0);
}

void GetSwingHiLo()
{
   //Gets the previous swing hi-lo
   
  
   bool done = false;
   
   //Swing low
   int cc = 1;
   SwingLo = Low[1];
   while (!done)
   {
      cc++;
      if (Low[cc] < SwingLo) SwingLo = Low[cc];
      else done = true;
   }//while (!done)

   //Swing high
   done = false;
   cc = 1;
   SwingHi = High[1];
   while (!done)
   {
      cc++;
      if (High[cc] > SwingHi) SwingHi = High[cc];
      else done = true;
   }//while (!done)
      
}//end void GetSwingHiLo()


void SetupPendingString()
{
   //Puts the list of pending trades into a string for display
   
   if (GlobalVariablesTotal() == 0) return("");//Nothing to do
   GetPends = "";
   
   for (int cc = GlobalVariablesTotal() - 1; cc >= 0; cc--)
   {
      string search = GlobalVariableName(cc);
      string ToFind = StringConcatenate(GlobalPrefix, "pending ");
      int index = StringFind(search, ToFind);
      if (index > -1) // Pending trade gv
      {
         string Sym = StringSubstr(search, 14);
         int type = GlobalVariableGet(search);
         if (type == 0) GetPends = StringConcatenate(GetPends, Sym, " Long: ");
         else GetPends = StringConcatenate(GetPends, Sym, " Short: ");
      
      }//if (index > -1) // Pending trade gv
   
   }//for (int cc = GlobalVariablesTotal() - 1; cc >= 0; cc--)
   
   
   
}//End void SetupPendingString()

void GetColours()
{
   //Gets the colour of the AO and AC indicators, and the current candle. Stores them in AoColour and AcColour.
   //Colours are set to Green if current >= previous, else Red.
   // red and green are defined in the general declarations section as "Red" and "Green"

   // AO
   if (iAO(Symbol(), 0, 0) >= iAO(Symbol(), 0, 1)) AoColour = green;
   else AoColour = red;

   // AC
   if (iAC(Symbol(), 0, 0) >= iAC(Symbol(), 0, 1)) AcColour = green;
   else AcColour = red;

   //Current candle
   if (Ask >= Open[0]) CurrCandleColour = green;
   //else CurrCandleColour = red;
   if (Bid <  Open[0]) CurrCandleColour = red;
}//End void GetColours()

void GetSthochastic()
{
   // Reads Stochastic,
   // Stores MainLine in StochMain, Signal line in StochSignal
   // Calculates the direction Stoch is heading and stores the direction in StochDirection

   StochMain = iStochastic(NULL, 0, 5, 3, 3, 0, 0, MODE_MAIN, 0);
   StochSignal = iStochastic(NULL, 0, 5, 3, 3, 0, 0, MODE_SIGNAL, 0);
   
   if (StochMain >= StochSignal) StochDirection = up;
   else StochDirection = down;

}//End void GetSthochastic()

void GetMarketDirection()
{
   //Reads current market direction and stores this in MarketDirection
   
   if (Ask > iSAR(NULL,0,0.05,0.2,0)) MarketDirection = up;
   if (Bid < iSAR(NULL,0,0.05,0.2,0)) MarketDirection = down;
   

}//End void GetMarketDirection()

void GetTradingStatus()
{
   //Reads the current trading status and stores this in the variable TradingStatus.
   //The status definitions are:
   //waiting "Waiting for a PSAR flip"
   //pending "PSAR has flipped. Waiting for the new candle to see if a trade can be sent"
   //MonitoringLong "Monitoring Long trade"
   //MonitoringShort "Monitoring Short trade"
   
   //Waiting for a psar flip
   if (!GlobalVariableCheck(GvPending) && !TradeExists)
   {
      TradingStatus = waiting;
      return;
   }//if (!GlobalVariableGet(GvPending) && !TradeExists)
   
   //Detect a pending trade gv
   if (GlobalVariableCheck(GvPending) )
   {
      TradeDirection = GlobalVariableGet(GvPending);
      TradingStatus = pending;      
   }//if (GlobalVariableGet(GvPending) )
   
   //Open trade
   if (TradeExists)
   {
      if (OrderType() == OP_BUY) TradingStatus = MonitoringLong;
      else  TradingStatus = MonitoringShort;
   }//if (TradeExists)
   

}//End void GetTradingStatus()

void HasSarsChangedDirection()
{
   // Sets a gv with the appropriate trade direction

   //Change long
   if (Ask > iSAR(NULL,0,0.05,0.2,0) && iClose(NULL,0,1) < iSAR(NULL,0,0.05,0.2,1) )
   {
      GlobalVariableSet(GvPending, 0); //0=buy
      TradingStatus = pending;
      DisplayUserFeedback();
      //Alert(Symbol(), " Long pending set");

   }//if (Ask > iSAR(NULL,0,0.05,0.2,0) && iClose(NULL,0,1) < iSAR(NULL,0,0.05,0.2,1))
   
   //Change short
   if (Bid < iSAR(NULL,0,0.05,0.2,0) && iClose(NULL,0,1) > iSAR(NULL,0,0.05,0.2,1) )
   {
      GlobalVariableSet(GvPending, 1); //1=sell
      TradingStatus = pending;
      DisplayUserFeedback();
      //Alert(Symbol(), " Short pending set");

   }//if (Bid < iSAR(NULL,0,0.05,0.2,0) && iClose(NULL,0,1) > iSAR(NULL,0,0.05,0.2,1))
   

}//End void HasSarsChangedDirection()

bool SendSingleTrade(int type)
{
   // Attempts to place a trade according to type, i.e.
   // 0 = OP_BUY
   // 1 = OP_SELL
   
    // Check spread
   if (MarketInfo(Symbol(), MODE_SPREAD) > MaxSpreadAllowed)
   {
      return(false);// Spread too large, so abort send
   }//if (MarketInfo(NULL, MODE_SPREAD) > MaxSpreadAllowed)

 
   // Calculate stoploss if user has not opted for hedging
   if (!HedgeNotStopLoss) StopLoss = GetStopLoss(type);
   
   RefreshRates();
   
   // Buy trade
   if (type == 0)
   {
      double TradePrice=Ask;
      int colour = 32768;//green
   }//if (type == 0)   
   
   
   // Sell trade
   if (type == 1)
   {
      TradePrice=Bid;      
      colour = 255;//red      
   }//if (type == 1)
   
   int slippage = 10;
   if (Digits == 3 || Digits == 5) slippage = 100;
   slippage*= Point;
   
   //Non ECN crook
   if (!CriminalIsECN) int ticket = OrderSendReliable(Symbol(),type, Lot, TradePrice, slippage, StopLoss, 0, TradeComment, MagicNumber,0, colour);
   
   //Is a 2 stage criminal
   if (CriminalIsECN)
   {
     ticket = OrderSendReliable(Symbol(),type, Lot, TradePrice, slippage, 0, 0, TradeComment, MagicNumber,0, colour);
	  if (StopLoss != 0)
	  {
		  if (ticket > 0)
			  bool result = OrderModifyReliable(ticket, OrderOpenPrice(),	StopLoss, 0, 0, CLR_NONE);
			  if (!result)
			  {
			      int err=GetLastError();
               Alert(Symbol(), " ", type," TP order modify failed with error(",err,"): ",ErrorDescription(err));
               Print("Order send failed with error(",err,"): ",ErrorDescription(err));      
			  }//if (!result)			  
	  }//if (Take != 0)
	  else Print("Skipping OrderModify because no SL or TP specified.");
      
   }//if (CriminalIsECN)

   //Error trapping for both
   if (ticket < 0)
   {
      err=GetLastError();
      Alert(Symbol(), " ", type," order send failed with error(",err,"): ",ErrorDescription(err));
      Print("Order send failed with error(",err,"): ",ErrorDescription(err));
      return(false);
   }//if (ticket < 0)
   else 
   {
      //If user wants the robot to automatically update the part close percentage, then
      //save the value of half the trade in a global variable
      if (AutoCalculatePartClose)
      {
         GlobalVariableSet(DoubleToStr(ticket,0), Lot / 2);
      }//if (AutoCalculatePartClose)
      
      return(true);
   }
   
}//End void SendSingleTrade(type)

void CheckForOpenTrade()
{
   //Only called if there are open trades
   //Checks to see if a trade already exists. If so:
   // Sets TradeExists to true
   // Saves the trade's ticket number
   // Sets up the screen display
   
   TradeExists=false;
   
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS, MODE_TRADES) ) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderCloseTime() == 0)
      {
         OriginalTradeTicketNo = OrderTicket();
         TradeExists = true;
         if (OrderType() == OP_BUY) TradingStatus = MonitoringLong;
         else  TradingStatus = MonitoringShort;
         return;
      }//if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)  
   }//for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   
}//End void CheckForOpenTrade()

void CloseOpenTrade()
{
   //Attenpts to close an open trade for whatever reason. Function aborts if there are no open trades
   //OriginalTradeTicketNo is already set when the trades is detected
   
   if (!TradeExists) 
   {
      ForceFullTradeClosure = false;
      return; //Nothing to do
   }//if (!TradeExists) 
   
   RefreshRates();
   bool result = OrderCloseReliable(OriginalTradeTicketNo, OrderLots(), OrderClosePrice(), 500, CLR_NONE);
   if (result) 
   {
      ForceFullTradeClosure = false;//Close has succeeded
      TradeExists=false;
   }//if (result) 
   
   if (!result) ForceFullTradeClosure = true;//Close failed, so force the ea to keep trying

}//void CloseOpenTrade()

double GetStopLoss(int type)
{
   //Returns the stop loss based on the previous swing high\low
   
   double ms = NormalizeDouble(MinStopLoss * Point, Digits);
   
   //Swing low for a long 
   if (type == 0)
   {
      double Sl = SwingLo;
      //Min stop level check, with a small extra margin
      if ( (Ask - Sl) < ms)
      {
         Sl = NormalizeDouble(Ask - ms, Digits);
      }//if ( (Ask - Sl) < StopLevel)
      
   }//if (type == 0)
      
   
   //Swing high for a short
   if (type == 1)
   {
      Sl = SwingHi;
      //Min stop level check, with a small extra margin
      if ( (Sl - Bid) < ms)
      {
         Sl = NormalizeDouble(Bid + ms, Digits);
      }//if ( (Bid + Sl) < StopLevel)
      
   }//if (type == 1)
   
   return(Sl);
   
}//End double GetStopLoss(int type)

double CalculateBEP()
{
//Calculates the profit to lock into the stop loss after a part-close

   double StopLevel = NormalizeDouble(MarketInfo(Symbol(), MODE_STOPLEVEL) * Point, Digits) ;
   double Sl;
   
   double ta = NormalizeDouble((BreakEvenProfit * Point), Digits);
   
   if (OrderType() == OP_BUY)
   {
      Sl = OrderOpenPrice() + ta;
      if ( (Ask - Sl) < StopLevel) Sl = OrderOpenPrice();//Can't lock in the profits required
   }//if (OrderType() == OP_BUY)
   
   if (OrderType() == OP_SELL)
   {
      Sl = OrderOpenPrice() - ta;
      if ( (Sl - Bid) < StopLevel) Sl = OrderOpenPrice();//Can't lock in the profits required
   }//if (OrderType() == OP_BUY)
   
   return(Sl);

}//End double CalculateBEP()


void PartCloseOpenTrade()
{
   //Part close a profitable trade at the start of a new candle
   ForcePartTradeClosure = false;
   
   //If AutoCalculatePartClose = true, the robot sets a gv with the percentage of the trade to close.
   //Gv name is the trade ticket number
   if (AutoCalculatePartClose)
   {
      string gv = DoubleToStr(OrderTicket(),0);
      if (GlobalVariableCheck(gv) ) 
      {
         Close_Lots =  GlobalVariableGet(gv);
         Preserve_Lots = GlobalVariableGet(gv);
      }//if (GlobalVariableCheck(gv) ) 
         
   }//if (AutoCalculatePartClose)
   

   
   if (OrderLots() <= Preserve_Lots) return;//Nothing to do
   
   double price;
   if (OrderType()==OP_BUY) price = Bid;
   if (OrderType()==OP_SELL) price = Ask;
   
         
   bool result=OrderCloseReliable(OrderTicket(), Close_Lots, price, 5, CLR_NONE);
   if (result)
   {
      //Need to reset the ticket number
      Sleep(1000);
      CheckForOpenTrade();
      if (ShowAlerts==true) Alert("Partial close of ", OrderSymbol(), " ticket no ", OrderTicket() );
      //Move sl to be
      //Calculate the profit to lock in
      double Sl = CalculateBEP();
      result = OrderModifyReliable(OrderTicket(), OrderOpenPrice(), Sl, OrderTakeProfit(),OrderExpiration(), CLR_NONE);
      if (!result && ShowAlerts)
      {
         int err=GetLastError();
         if (ShowAlerts==true) Alert("Setting of SL ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         Print("Setting of SL ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
      }//if !result && ShowAlerts)      
   }
   else
   {
      err=GetLastError();
      //Invalid ticket error means the trade has closed
      if (err == 41080)
      {
         ForcePartTradeClosure = false;
         return;
      }//if (err == 41080
      
      if (ShowAlerts==true) Alert("Partial close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
      Print("Partial close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
      ForcePartTradeClosure=true;
   }                          


}//End void PartCloseOpenTrade()

void CalculateAverageCandleLength()
{
   //Calculates the average candle length
   //User can effectively turn off this filter by using the value of 0 for CandleLengthLookBackBars
   
   if (CandleLengthLookBackBars == 0) return;

   double phigh;
   double plow;
   double diff; 
   double total;
   
   for (int cc = 1; cc < CandleLengthLookBackBars; cc++)
   {
      phigh = High[cc];
      plow = Low[cc];
      diff = NormalizeDouble(MathAbs(phigh - plow),Digits);
      total+= diff;
   }   
   
   AverageCandleLength = total/CandleLengthLookBackBars;
   if (CandleLengthOverAverage > 0) TradeableCandleLength = AverageCandleLength + (AverageCandleLength * (CandleLengthOverAverage / 100));
   else TradeableCandleLength = AverageCandleLength;
   
}//End void CalculateAverageCandleLength()

void CalculateCandleLength(int shift)
{
   //Calculates the length of the candle indicated by shift.
   //This will be the current candle for display purposes, and the trading candle at the open of the new one.
   //Calculates the length of the upper and lower wicks, and their percentage of the candle length
   
   double Chigh = High[shift];
   double Clow = Low[shift];
   
   CurrentCandleLength = NormalizeDouble(MathAbs(Chigh - Clow), Digits);
   
   //Calculate wick lengths
   //Up candle
   if (CurrCandleColour == green)
   {
      UpperWickLength = Chigh - Ask;
      LowerWickLength = Open[shift] - Clow;   
   }//if (CurrCandleColour == green)
   
   //Down candle
   if (CurrCandleColour == red)
   {
      UpperWickLength = Chigh - Open[shift];
      LowerWickLength = Bid - Clow;   
   }//if (CurrCandleColour == green)

   //Calculate percentage of candle length is occupied by the wicks
   if (UpperWickLength > 0 && CurrentCandleLength > 0) UpperWickPercent = (UpperWickLength / CurrentCandleLength) * 100;
   if (LowerWickLength > 0 && CurrentCandleLength > 0) LowerWickPercent = (LowerWickLength / CurrentCandleLength) * 100;

   
  
}//void CalculateCandleLength(int shift)()

void ManageTrade()
{


   double Sl = CalculateBEP();
         
   //Deal with breakeven ordermodify failure
   if (OrderType() == OP_BUY) 
   {    
      if (OrderLots() < Lot && OrderProfit() > 0 && OrderStopLoss() < Sl)
      {
         bool result = OrderModifyReliable(OrderTicket(), OrderOpenPrice(), Sl, OrderTakeProfit(),OrderExpiration(), CLR_NONE);
         if (!result && ShowAlerts)
         {
            int err=GetLastError();
            if (ShowAlerts==true) Alert("Setting of SL ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Setting of SL ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//if !result && ShowAlerts)
      }//if (OrderLots() < Lot && OrderProfit() > 0)
   }//if (OrderType() == OP_BUY) 
   
   if (OrderType() == OP_SELL)
   {      
      if (OrderLots() < Lot && OrderProfit() > 0 && OrderStopLoss() > Sl)
      {
         result = OrderModifyReliable(OrderTicket(), OrderOpenPrice(), Sl, OrderTakeProfit(),OrderExpiration(), CLR_NONE);
         if (!result && ShowAlerts)
         {
            err=GetLastError();
            if (ShowAlerts==true) Alert("Setting of SL ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Setting of SL ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//if !result && ShowAlerts)
      }//if (OrderLots() < Lot && OrderProfit() > 0)
   }//if (OrderType() == OP_BUY) 
   
   
   // Call the working subroutines one by one. 
      
        
   // JumpingStop
   if(JumpingStop) JumpingStopLoss();
   
   
      
} // End of ManageTrade()


void JumpingStopLoss() 
{
   // Jump sl by pips and at intervals chosen by user .
  
   // Abort the routine if JumpAfterBreakevenOnly is set to true and be sl is not yet set
   if (JumpAfterBreakevenOnly && OrderType()==OP_BUY)
   {
      if(OrderStopLoss() < OrderOpenPrice() ) return(0);
   }
  
   if (JumpAfterBreakevenOnly && OrderType()==OP_SELL)
   {
      if(OrderStopLoss() > OrderOpenPrice() ) return(0);
   }

   
   bool result;
   double sl=OrderStopLoss(); //Stop loss

   if (OrderType()==OP_BUY)
   {
      // First check if sl needs setting to breakeven
      if (sl==0 || sl<OrderOpenPrice())
      {
         if (Ask >= OrderOpenPrice() + (JumpingStopPips*Point))
         {
            sl=OrderOpenPrice();
            if (OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE))
            {
               if (ShowAlerts==true) Alert("Jumping stop set at breakeven ",sl, " ", OrderSymbol(), " ticket no ", OrderTicket());
               Print("Jumping stop set at breakeven: ", OrderSymbol(), ": StopLoss ", sl, ": Ask ", Ask);
            }//if (OrderReliable(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE))                        
            return(0);
         }//if (Ask >= OrderOpenPrice() + (JumpingStopPips*Point))
      } //close if (sl==0 || sl<OrderOpenPrice()
   
      // Increment sl by sl + JumpingStopPips.
      // This will happen when market price >= (sl + JumpingStopPips)
      if (Bid>= sl + ((JumpingStopPips*2)*Point) && sl>= OrderOpenPrice())      
      {
         sl=sl+(JumpingStopPips*Point);
         if (OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE))
         {
            if (ShowAlerts==true) Alert("Jumping stop set at ",sl, " ", OrderSymbol(), " ticket no ", OrderTicket());
            Print("Jumping stop set: ", OrderSymbol(), ": StopLoss ", sl, ": Ask ", Ask);            
         }//if (OrderReliable(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE))
      }// if (Bid>= sl + (JumpingStopPips*Point) && sl>= OrderOpenPrice())      
   }//if (OrderType()==OP_BUY)
   
   if (OrderType()==OP_SELL)
   {
        // First check if sl needs setting to breakeven
      if (sl==0 || sl>OrderOpenPrice())
      {
         if (Ask <= OrderOpenPrice() - (JumpingStopPips*Point))
         {
            if (OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE))
            {
               
            }//if (OrderReliable(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE))

            sl=OrderOpenPrice();
            result = OrderModifyReliable(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
            if (result)
            {
               if (ShowAlerts==true) Alert("Jumping stop set at breakeven ",sl, " ", OrderSymbol(), " ticket no ", OrderTicket());
               Print("Jumping stop set at breakeven: ", OrderSymbol(), ": StopLoss ", sl, ": Ask ", Ask);
               
            }//if (result)            
            return(0);
         }//if (Ask <= OrderOpenPrice() - (JumpingStopPips*Point))
      } // if (sl==0 || sl>OrderOpenPrice()
   
      // Decrement sl by sl - JumpingStopPips.
      // This will happen when market price <= (sl - JumpingStopPips)
      if (Bid<= sl - ((JumpingStopPips*2)*Point) && sl<= OrderOpenPrice())      
      {
         sl=sl-(JumpingStopPips*Point);
         result = OrderModifyReliable(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
         if (result)
         {
            if (ShowAlerts==true) Alert("Jumping stop set at ",sl, " ", OrderSymbol(), " ticket no ", OrderTicket());
            Print("Jumping stop set: ", OrderSymbol(), ": StopLoss ", sl, ": Ask ", Ask);
            
         }//if (result)          
      }// close if (Bid>= sl + (JumpingStopPips*Point) && sl>= OrderOpenPrice())         
   }//if (OrderType()==OP_SELL)

} //End of JumpingStopLoss sub

bool IsTradeAHedge()
{
   //Checks whether a single trade is a hedge, is therefore an orphan and needs closing
   //Returns true if so, else false
   
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == hedge)
      {
         return(true);
      }//if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment == hedge)
      
   }//for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   
   return(false);

}//bool IsTradeAHedge()

void DoesTradeNeedHedging()
{
   //Checks if an open trade needs hedging.
   //Sends the hedge if so, and resets the hedge gv appropriately
   
   //Find the open trade
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() != hedge)
      {
         int TicketNo = OrderTicket();
         break;
      }//if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment == hedge)
      
   }//for (int cc = OrdersTotal() - 1; cc >= 0; cc--)

   
   if (OrderProfit() > 0) return; //Nothing to do
   if (TicketNo == 0) return; //Nothing to do
   
   double PipsLoss, market;
   int NextHedge = GlobalVariableGet(HedgeGv);
   if (NextHedge == 0) NextHedge = StartHedgingAtLossPips;
   
   
   if (OrderType() == OP_BUY)
   {
      market = Bid;
      int type = OP_SELL;
   }//if (OrderType() == OP_BUY)   
   else 
   {
      market = Ask;
      type = OP_BUY;
   }//else
   
   PipsLoss = MathAbs(OrderOpenPrice() - market);
   
   if (PipsLoss >= (NextHedge * Point) )
   {
      double SendLots = Lot / 2;
      int ticket = OrderSendReliable(Symbol(), type, SendLots, market, 50, 0, 0, hedge, MagicNumber, Magenta);
      if (ticket < 1)//Deal with trade failure - leave the ea to try again next tick
      {        
         int err=GetLastError();
         Alert(Symbol(), "Hedge ", type," order send failed with error(",err,"): ",ErrorDescription(err));
         return;
      }//if (ticket < 1)
      
      //Send succeeded, so update the HedgeGv val and remove the tp from the original trade
      if (ShowAlerts) Alert("Hedge trade sent for trade no ", TicketNo);
      Print("Hedge trade sent for trade no ", TicketNo);
      NextHedge+= HedgingIncrementPips;
      GlobalVariableSet(HedgeGv, NextHedge);
      //tp removal
      if (TicketNo > 0)
      {
         OrderSelect(OriginalTradeTicketNo, SELECT_BY_TICKET);//Not sure if the hedge send deselects the original trade, so make sure
         if (OrderTakeProfit() != 0)
         {
            bool result = false;
            while (!result)         
            {   
               result = OrderModifyReliable(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), 0, 0,CLR_NONE);
               if (!result)
               {
                  err=GetLastError();
                  Alert(Symbol(), " OrderModify failed with error(",err,"): ",ErrorDescription(err));
                  Print(Symbol(), " OrderModify failed with error(",err,"): ",ErrorDescription(err));      
                  Sleep(5000);
               }//if (!result)               
               if (OrderTakeProfit() == 0) result = true;
            }//while (!result)
         }//if (OrderTakeProfit() != 0)

      }//if (TicketNo > 0)
      
      CountOpenTrades();
      HedgeTradeExists=true;
   }//if (PipLoss >= NextHedge)
   
   

}//End void DoesTradeNeedHedging()


void ManageHedgedPosition()
{
   //Called when two trades are open, so must be a hedge position

   
   //Can the position be closed at be?
   double BreakEvenTarget = NormalizeDouble(AccountBalance() * BreakEvenProfitPercent / 100, 2);
   if (OpenTradesUpl >= BreakEvenTarget)
   {         
      //Attempt to close both trades. Abort if the first close fails
      for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
      {
         if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() != hedge)
         {
            bool result = OrderCloseReliable(OrderTicket(), OrderLots(), OrderClosePrice(), 50, CLR_NONE);
            if (!result) return;//Don't want to close the hedge if the original trade close failed
         }//if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment == hedge)      
      }//for (int cc = OrdersTotal() - 1; cc >= 0; cc--)

      //Original trade close succeeded, so attempt to close the hedge
      for (cc = OrdersTotal() - 1; cc >= 0; cc--)
      {
         if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == hedge)
         {
            result = OrderCloseReliable(OrderTicket(), OrderLots(), OrderClosePrice(), 50, CLR_NONE);
            if (result) HedgeTradeExists = false;
            return;//If the attempt failed, the ea will take care of the orphan.
         }//if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment == hedge)      
      }//for (int cc = OrdersTotal() - 1; cc >= 0; cc--)  
   }//if (OpenTradesUpl >= 0)
   
   
   //Has a hedge trade got to the next hedge point, and so can be closed
   for (cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == hedge)
      {
         if (OrderProfit() <= 0) return;//Clearly does not need closing
         //Calculate the pips profit
         double market;
         if (OrderType() == OP_BUY) market = Ask;
         else market = Bid;
         double PipsProfit = MathAbs(OrderOpenPrice() - market);
         double target = GlobalVariableGet(HedgeGv);
         target*= Point;
         if (PipsProfit >= target) 
         {
            double OrderSize = OrderLots();//For calculating the sl for the original trade
            result = OrderCloseReliable(OrderTicket(), OrderLots(), OrderClosePrice(), 50, CLR_NONE);
            if (result)//hedge closed successfully
            {
               //Set the next hedging point
               int NextHedge = GlobalVariableGet(HedgeGv);
               NextHedge+= HedgingIncrementPips;
               GlobalVariableSet(HedgeGv, NextHedge);
               
               //Modify the sl of the original trade
               //Find the original trade
               for (int dd = OrdersTotal() - 1; dd >=0; dd--)
               {
                  if (!OrderSelect(dd, SELECT_BY_POS) ) continue;
                  if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() != hedge)
                  {
                     result = false;
                     while (!result)
                     {
                        double pips;//Pips to subtract\add to open price to get sl
                        if (Digits == 3 || Digits == 5) pips = 2500 * Point;
                        else pips = 250 * Point;
                        double sl;//modified stop loss
                        if (OrderType() == OP_BUY) sl = Ask - pips;
                        else sl = Bid + pips;
                        if (OrderTakeProfit() != OrderOpenPrice())
                        {
                           result = OrderModifyReliable(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), OrderOpenPrice(),0,CLR_NONE);
                           if (!result)
                           {
                              int err=GetLastError();
                              Alert(Symbol(), " OrderModify failed with error(",err,"): ",ErrorDescription(err), "  SL = ",sl);
                              Print(Symbol(), " OrderModify failed with error(",err,"): ",ErrorDescription(err));      
                              Sleep(5000);
                           }//if (!result)
                        }//if (OrderTakeProfit() != OrderOpenPrice())
                        if (OrderTakeProfit() == OrderOpenPrice()) result = true;
                     }//while (!result)
                     break;
                  }//if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() != hedge)
                  
               
               }//for (int dd = OrdersTotal() - 1; dd >=0; dd--)
               
            
            }//if (result)
            
         }//if (PipsProfit >= target) 
            
         break;        
      }//if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment == hedge)      
   }//for (int cc = OrdersTotal() - 1; cc >= 0; cc--)  
  
}//End void ManageHedgedPosition()

void CountOpenTrades()
{
   //Called if there are open trades. Calculates how many belong to this ea
   
   CountedTrades=0;
   OpenTradesUpl=0;
   BuysOpen=0;
   BuyTradesUpl=0;
   SellsOpen=0;
   SellTradesUpl=0;
   
   
   for (int cc = OrdersTotal()-1; cc >=0; cc--)
   {
      if (!OrderSelect(cc,SELECT_BY_POS) ) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) 
      {
         CountedTrades++;
         OpenTradesUpl+= OrderProfit() + OrderSwap();     
         if (OrderType() == OP_BUY)
         {
            BuysOpen++;
            BuyTradesUpl+= OrderProfit() + OrderSwap();
         }//if (OrderType() == OP_BUY
         
         if (OrderType() == OP_SELL)
         {
            SellsOpen++;
            SellTradesUpl+= OrderProfit() + OrderSwap();
         }//if (OrderType() == OP_SELL
             
      }//if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)   
   
   }//for (int cc = OrdersTotal(); cc >=0; cc--)  
   

}//End void CountOpenTrades()

void Hedging()
{
   //This is effectively start() from my LR hedging robot. Only called if there is an open trade and
   //the user has opted for hedging, not stoploss
   
   
   //This function is only called if an open trade exists. Temp store the ticket number of the
   //open trade for reselecting the trade after all the functions here have been called. The robot needs
   //this for subsequent functions
   int TempTicketNo = OrderTicket();
   
   ///////////////////////////////////////////////////////////////////////////////////////////////////
   //CODE FROM LR HEDGING ROBOT
   CountOpenTrades();

   if (CountedTrades == 0)
   {
      GlobalVariableSet(HedgeGv, StartHedgingAtLossPips);//Reset the hedge pips setting
   }//if (CountedTrades == 0)

   //Work on open trades
   if (OrdersTotal() > 0)
   {
      if (CountedTrades > 0)
      {
         //Code to work on open trades
         
         //Is a single trade open
         if (CountedTrades == 1)
         {
            //Is it a hedge
            bool HedgeOnly = IsTradeAHedge();
            
            //If not then it is an original, so check for the need to hedge
            if (!HedgeOnly)
            {
               DoesTradeNeedHedging();
            }//if (!HedgeOnly)
            
            
            //If it is a hedge, then it is orphaned and needs closing         
            if (HedgeOnly)//Hedge trade needs closing. Already selected in the IsTradeAHedge() function
            {
               bool result = OrderCloseReliable(OrderTicket(), OrderLots(), OrderClosePrice(),50,CLR_NONE);
               if (result) HedgeTradeExists = false;
            }//if (HedgeOnly)
            
         }//if (CountedTrades == 1)
          

         //Are there two trades open? If so, this is a hedged position, so manage the pair
         if (CountedTrades == 2)
         {
            ManageHedgedPosition();
         }//if (CountedTrades == 2)
         
        
         
      }//if (CountedTrades > 0)
      
   }//if (OrdersTotal() > 0)
   ///////////////////////////////////////////////////////////////////////////////////////////////////
   //END OF CODE FROM LR HEDGING ROBOT

   //Restore the selected trade. Cancel TradeExists if this function has closed it
   if (!OrderSelect(TempTicketNo, SELECT_BY_TICKET) ) TradeExists = false;
   
}//void Hedging()

void GetHorizontalSRlines()
{
   //User can use horizontal lines to indicate support and resistance.
   //This function reads these lines, and sets up NextSupportLine & NextResistanceLine
   //for use in trading decisions.

   
   //Cycle through the list of objects and find the total no of appropriate horizontal lines
   int NoOfLines;
   if (ObjectsTotal() == 0) return;
   for (int cc = ObjectsTotal() - 1; cc >= 0; cc--)
   {
      string name = ObjectName(cc);
      int index=StringFind(name, "RecentSR");//looks for rectangles from Recent SR indi
      if (index>-1) 
      {
         color HorizontalLineColour = ObjectGet(name, OBJPROP_COLOR);
         if(HorizontalLineColour == SrLineColour) NoOfLines++;         
      }//if (index>-1)         
   }//for (int cc = ObjectsTotal - 1; cc >= 0; cc--)      
   
   //Cater for users forgetting to add lines, or too bone idle to read the user guide and just go with
   //default settings
   if (NoOfLines == 0) return;
   
   NextResistanceLine=0;
   NextSupportLine=0;
   
   //Resize the array
   int NewSize = NoOfLines;
   double array1 = ArrayResize(SrLineArray, NoOfLines);
   
   //Read the sr line values into the array
   int ArrCounter;
   for (cc = ObjectsTotal() - 1; cc >= 0; cc--)
   {
      name = ObjectName(cc);
      index=StringFind(name, "RecentSR");//looks for rectangles from Recent SR indi
      if (index>-1) 
      {
         HorizontalLineColour = ObjectGet(name, OBJPROP_COLOR);
         if(HorizontalLineColour == SrLineColour)
         {
            SrLineArray[ArrCounter] = ObjectGet(name, OBJPROP_PRICE1);
            ArrCounter++;
         }//if(HorizontalLineColour == SrLineColour)
      }//if (index>-1)         
   
   }//for (cc = ObjectsTotal() - 1; cc >= 0; cc--)
   
   //Sort the array into ascending order 
   ArraySort(SrLineArray,WHOLE_ARRAY,0,MODE_ASCEND);
   //Find the nearest support and resistance lines
   for (cc = 0; cc < ArrCounter; cc++)
   {
      if (Ask > SrLineArray[cc] && Ask < SrLineArray[cc + 1])
      {
         NextSupportLine = SrLineArray[cc];
         NextResistanceLine = SrLineArray[cc + 1];
         break;
      }//if (Bid > SrLineArray[cc] )      
   }//for (cc = 0; cc < ArrCounter; cc++)


}//End void GetHorizontalSRlines()


void GetNextBigNumbers()
{
   //Finds the nearest big numbers to the market price.
   //Saves these in BigNumberHigh and BigNumberLow
   
   //Jpy pairs
      if (Digits == 2 || Digits == 3)
      {
         double CalcNumber = 400;
         for (int cc = 40; cc > 1; cc--)
         {
            CalcNumber-= 10;
            if (Ask >= CalcNumber)
            {
               BigNumberHigh = CalcNumber + 10;
               BigNumberLow = CalcNumber;
               break;
            }//if (Ask >= BigNumber)
         }//for (int cc = 0; cc < 30: cc++);
      
   }//if (Digits == 2 || Digits == 3)

   //non-Jpy pairs
      if (Digits == 4 || Digits == 5)
      {
         CalcNumber = 3.1;
         for (cc = 30; cc > 1; cc--)
         {
            CalcNumber-= 0.1;
            if (Ask >= CalcNumber)
            {
               BigNumberHigh = CalcNumber + 0.1;
               BigNumberLow = CalcNumber;
               break;
            }//if (Ask >= BigNumber)
         }//for (int cc = 0; cc < 30: cc++);
      
   }//if (Digits == 4 || Digits == 5)


}//End void GetNextBigNumbers()

void CalculateLotSize()
{
   //Called if RobotCalulatesLotSize=true. Auto calcs the lot size based on x lots per x units of currency


   if (Lot == MarketInfo(Symbol(), MODE_MAXLOT) ) return;//Can't go any bigger
   
   double LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   
   //Make sure that there are not too many decimal plases in the result of the calculation
   int decimals;
   if (LotStep >0 && LotStep < 0.1) decimals = 2;//0.01
   if (LotStep >0.09 && LotStep < 1) decimals = 1;//0.1
   if (LotStep >0.9) decimals = 0;//1
   
   
   if (LotsPerCurrencyUnit < LotStep) LotsPerCurrencyUnit = LotStep;
   Lot = NormalizeDouble((AccountBalance() / CurrencyUnit) * LotsPerCurrencyUnit,decimals);
   double MaxLots = MarketInfo(Symbol(), MODE_MAXLOT);

   //Adjust incorrect lot sizes
   if (Lot < MarketInfo(Symbol(), MODE_MINLOT) )
   {
      Lot = MarketInfo(Symbol(), MODE_MINLOT) * 2;
      string message = StringConcatenate("Your lot size was too small for this broker.",NL, "It has been adjusted to ",Lot);
      MessageBox(message);
   }//if (Lot < MarketInfo(Symbol(), MODE_MINLOT) )
   
   if (Lot > MarketInfo(Symbol(), MODE_MAXLOT) )
   {
      Lot = MarketInfo(Symbol(), MODE_MAXLOT);
      message = StringConcatenate("Your lot size was too big for this broker.",NL, "It has been adjusted to ",Lot);
      MessageBox(message);
   }//if (Lot < MarketInfo(Symbol(), MODE_MAXLOT) )


}//End void CalculateLotSize()

void DeleteOrphanHedgeGVs()
{
   //Called at the start of each day, or on loadup. Deletes orphan hedge gv's
   for (int cc = GlobalVariablesTotal() - 1; cc >=0; cc--)
   {
      string vname = GlobalVariableName(cc);
      int tnum = StrToDouble(vname);
      if (tnum > 0) //Is a ticket number
      {
         if (!OrderSelect(tnum, SELECT_BY_TICKET) || OrdersTotal() == 0 )
         {
            GlobalVariableDel(vname);
            cc++;
         }//if (!OrderSelect(tnum, SELECT_BY_TICKET) )
         
      }//if (tnum > 0)
      
   
   }//for (int cc = GlobalVariablesTotal() - 1; cc >=0; cc--)
   

}//End void DeleteOrphanHedgeGVs()


//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----
   
   static int DisplayUpdateBars;//For slowing down the rate at which various calculation routines are called
   int ChartBars = iBars(Symbol(), PERIOD_M1);
   
   if (RobotDisabled)
   {
      Comment("This robot is disabled and cannot trade");
      return;
   }//if (RobotDisabled)
   
   
   if (ForceFullTradeClosure) CloseOpenTrade();//In case a trade close failed
   if (ForcePartTradeClosure) PartCloseOpenTrade();//In case a trade part-close failed
   
   if (DisplayUpdateBars != ChartBars) CalculateCandleLength(0);//Length of current candle for display
   
   if (HedgeNotStopLoss && !TradeExists) Hedging();//In case the gv needs resetting
   
   if (DisplayUpdateBars != ChartBars) 
   {
      //Horizontal line s\r
      if (UseHorizontalLineSR) GetHorizontalSRlines();
      //Big number s\r
      if (UseBigNumbers) GetNextBigNumbers();
      //Pending trades display
      SetupPendingString();   
   
   }//if (DisplayUpdateBars != ChartBars) 
   
   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Code block to detect and monitor an open trade
   TradeExists = false;
   if (OrdersTotal() > 0)
   {
      CheckForOpenTrade();
      if (!TradeExists && HedgeTradeExists) Hedging();//Close the orphan trade
      if (TradeExists && !HedgeTradeExists) ManageTrade();
      //Hedging code is copied from the LR hedging robot, so put its start() into a separate function here
      //for readability
      if (HedgeNotStopLoss && TradeExists) Hedging();
      if (!TradeExists) ForceFullTradeClosure = false;
   }//if (OrdersTotal() > 0)
      if (OrdersTotal() == 0) ForceFullTradeClosure = false;
   //End of code block to detect and monitor an open trade
   /////////////////////////////////////////////////////////////////////////////////////////////////


   if (DisplayUpdateBars != ChartBars) HasSarsChangedDirection();
   
   /////////////////////////////////////////////////////////////////////////////////////////////////
   
   //Detect the Sunday candle
   if (!TradeSundayCandle && TimeDayOfWeek(TimeLocal())==0) 
   {
      ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Trading suspended - Sunday candle. Continuing to manage open trades.",NL);
      Comment(ScreenMessage);
      return;
   }//if (!TradeSundayCandle && TimeDayOfWeek(TimeCurrent())==0) 
   
   
   // Code block to detect the start of a new candle
   if (OldBars != Bars)
   {
      if (!HedgeNotStopLoss) GetSwingHiLo();
      if (RobotCalulatesLotSize) CalculateLotSize();
      //Delete orphan close_lot autocalculation gv's
      if (GlobalVariablesTotal() > 0) DeleteOrphanHedgeGVs();
      
      //Calculate the average candle length
      CalculateAverageCandleLength();
      CalculateCandleLength(1);//Length of previous candle for trade filter
      
      //Check to see if an open trade needs closing
      if (TradeExists && !HedgeTradeExists)
      {
         //Partial closure of successful trade
         if (PartCloseEnabled && OrderProfit() > 0)
         {
            PartCloseOpenTrade();
            if (ForcePartTradeClosure)
            {
               OldBars = 0;
               return;
            }//if (ForcePartTradeClosure)
            
         }//if (PartCloseEnabled && OrderProfit() > 0)
         
         bool CloseTrade=false;
         if (OrderType() == OP_BUY)
         {
            if (AoColour == red && !HedgeTradeExists) CloseTrade = true;
            if (CloseTrade) CloseOpenTrade();
            if (ForceFullTradeClosure)
            {
               OldBars = 0;
               return;
            }//if (ForceFullTradeClosure)
            
         }//if (OrderType() == OP_BUY)
          
         if (OrderType() == OP_SELL)
         {
            if (AoColour == green && !HedgeTradeExists)  CloseTrade = true;
            if (CloseTrade) CloseOpenTrade();
            if (ForceFullTradeClosure)
            {
               OldBars = 0;
               return;
            }//if (ForceFullTradeClosure)            
         }//if (OrderType() == OP_BUY)
         
         
      }//if (TradeExists && !HedgeTradeExists)
      
      //detect a pending trade GV and look at the other indicators to see if a trade can be sent.
      //cancel the pending trade if any indis are wrong.
      //indicator readings were taken at the last tick before the start of the new candle
      if (GlobalVariableCheck(GvPending) )
      {
         if (!HedgeTradeExists) CloseOpenTrade();
         if (ForceFullTradeClosure)
         {
            OldBars = 0;
            return;
         }//if (ForceFullTradeClosure)
         
         int TradeDirection = GlobalVariableGet(GvPending);
         double StochVal = iStochastic(NULL, 0, 5, 3, 3, 0, 0, MODE_SIGNAL, 0);
         bool TradeAllowed = true;
         
            
         //Check long trade
         if (TradeDirection == 0 && TradeAllowed)
         {
            //Candle length filter. User can turn this off by setting CandleLengthLookBackBars to 0
            string CancelReason=StringConcatenate(Symbol(), " Long cancelled: ");
            if (CurrentCandleLength > AverageCandleLength && CandleLengthLookBackBars > 0) 
            {
               TradeAllowed = false;
               CancelReason = StringConcatenate(CancelReason, "Trigger candle was too long ");
            }

            if (TradeAllowed && AoColour == red)
            {
               TradeAllowed = false; 
               CancelReason = StringConcatenate(CancelReason, "AoColour=red: ");
            }
            
            if (TradeAllowed && AcColour == red)
            {
               TradeAllowed = false; 
               CancelReason = StringConcatenate(CancelReason, "AoColour=red: ");
            }
            
            if (TradeAllowed&& CurrCandleColour == red)
            {
               TradeAllowed = false; 
               CancelReason = StringConcatenate(CancelReason, "Candle=red: ");
            }
            
            if (TradeAllowed&&StochDirection == down)
            {
               TradeAllowed = false; 
               CancelReason = StringConcatenate(CancelReason, "Stoch=down: ");
            }
            
            if (TradeAllowed && StochVal >= 80)
            {
               TradeAllowed = false; 
               CancelReason = StringConcatenate(CancelReason, "Stoch=over bought: ");
            }
            
            if (TradeAllowed && !TradeLong)
            {
               TradeAllowed = false; 
               CancelReason = StringConcatenate(CancelReason, "Long trades disallowed: ");
            }
            
            //Wick length filter. User can turn this off by setting AllowableWickPercentage to 100
            if (TradeAllowed&& UpperWickPercent > AllowableWickPercentage)
            {
               TradeAllowed = false; 
               CancelReason = StringConcatenate(CancelReason, "Upper wick too long: ");
            }
            
            if (TradeAllowed && UseHorizontalLineSR && NextResistanceLine > 0)
            {
               if (NextResistanceLine - Ask < (HlAllowablePipsAway * Point) ) 
               {
                  TradeAllowed = false; 
                  CancelReason = StringConcatenate(CancelReason, "Next resistance too close: ");
               }
            }//if (UseHorizontalLineSR)
            if (TradeAllowed && UseBigNumbers)
            {
               if (BigNumberHigh - Ask < (BnAllowablePipsAway * Point) ) 
               {
                  TradeAllowed = false; CancelReason = StringConcatenate(CancelReason, "Next big number too close: ");
               }
            }//if (UseBigNumbers)
            
         }//if (TradeDirection == 0)
      
         //Check short trade
         if (TradeDirection == 1 && TradeAllowed)
         {
            CancelReason=StringConcatenate(Symbol(), " Short cancelled: ");
            //Candle length filter. User can turn this off by setting CandleLengthLookBackBars to 0
            if (CurrentCandleLength > AverageCandleLength && CandleLengthLookBackBars > 0) 
            {
               TradeAllowed = false;
               CancelReason = StringConcatenate(CancelReason, "Trigger candle was too long ");
            }

            if (TradeAllowed && AoColour == green)
            {
               TradeAllowed = false; 
               CancelReason = StringConcatenate(CancelReason, "AoColour=green: ");
            }
            
            if (TradeAllowed && AcColour == green)
            {
               TradeAllowed = false; 
               CancelReason = StringConcatenate(CancelReason, "AoColour=red: ");
            }
            
            if (TradeAllowed && CurrCandleColour == green)
            {
               TradeAllowed = false; 
               CancelReason = StringConcatenate(CancelReason, "Candle=green: ");
            }
            
            if (TradeAllowed && StochDirection == up)
            {
               TradeAllowed = false; CancelReason = StringConcatenate(CancelReason, "Stoch=up: ");
            }
            
            if (TradeAllowed && StochVal <= 20)
            {
               TradeAllowed = false; 
               CancelReason = StringConcatenate(CancelReason, "Stoch=over sold: ");
            }
            
            if (TradeAllowed && !TradeShort)
            {
               TradeAllowed = false; 
               CancelReason = StringConcatenate(CancelReason, "Short trades disallowed: ");
            }
            
            //Wick length filter. User can turn this off by setting AllowableWickPercentage to 100
            if (TradeAllowed && LowerWickPercent > AllowableWickPercentage)
            {
               TradeAllowed = false; 
               CancelReason = StringConcatenate(CancelReason, "Upper wick too long: ");
            }
            
            if (TradeAllowed && UseHorizontalLineSR && NextSupportLine > 0)
            {
               if (Bid - NextSupportLine < (HlAllowablePipsAway * Point) ) 
               {
                  TradeAllowed = false; CancelReason = StringConcatenate(CancelReason, "Next support too close: ");
               }
            }//if (UseHorizontalLineSR)
            if (TradeAllowed && UseBigNumbers)
            {
               if (Bid - BigNumberLow < (BnAllowablePipsAway * Point) ) 
               {
                  TradeAllowed = false; 
                  CancelReason = StringConcatenate(CancelReason, "Next big number too close: ");
               }
            }//if (UseBigNumbers)
         }//if (TradeDirection == 1 && TradeAllowed)
         
         if (TradeExists) 
         {
            TradeAllowed = false;
            CancelReason = StringConcatenate(CancelReason, "Trade already open ");
         }
         
         if (!TradeAllowed) Alert(CancelReason);
         
         //send the trade if the indis line up.
         if (TradeAllowed) 
         {
            bool TradeSendSuccess = false;
            while (!TradeSendSuccess)
            {
               TradeSendSuccess = SendSingleTrade(TradeDirection);
               if (!TradeSendSuccess) Sleep(2000);//2 seconds
            }//while (!TradeSendSuccess)
            
            
            if (TradeSendSuccess)
            {
               GlobalVariableDel(GvPending);
            }//if (TradeSendSuccess)      
         }//if (TradeAllowed) 
         
         //cancel the trade if the indis do not line up.
         if (!TradeAllowed) 
         {
            GlobalVariableDel(GvPending);
            TradingStatus = waiting;
            DisplayUpdateBars = 0; //Force a re-display
         }//if (!TradeAllowed) 
            
      }//if (GlobalVariableCheck(GvPending) )

      OldBars = Bars;
   }//if (OldBars != Bars)
   
   // End of code block to detect the start of a new candle
   /////////////////////////////////////////////////////////////////////////////////////////////////
   
   
   /////////////////////////////////////////////////////////////////////////////////////////////////
   // Code block to display the status of the indicators, current candle, psar and trading status
   if (DisplayUpdateBars != ChartBars) 
   {
      GetColours();//AO, AC and current candle colours
      GetSthochastic();
      GetMarketDirection();//Compares current market to PSAR
      GetTradingStatus();
      HasSarsChangedDirection();
      DisplayUpdateBars = ChartBars;
   }//if (DisplayUpdateBars != ChartBars)    
   DisplayUserFeedback();
   // End of code block to display the status of the indicators
   /////////////////////////////////////////////////////////////////////////////////////////////////
   
   

//----
   return(0);
}
//+------------------------------------------------------------------+