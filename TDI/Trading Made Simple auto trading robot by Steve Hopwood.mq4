//+-------------------------------------------------------------------+
//|       Trading Made Simple auto trading robot by Steve Hopwood.mq4 |
//|                                  Copyright © 2009, Steve Hopwood  |
//|                              http://www.hopwood3.freeserve.co.uk  |
//+-------------------------------------------------------------------+
#property copyright "Copyright © 2009, Steve Hopwood"
#property link      "http://www.hopwood3.freeserve.co.uk"
#include <WinUser32.mqh>
#include <stdlib.mqh>
#define  NL    "\n"
#define  up "Up"
#define  down "Down"
#define  buy "Buy"
#define  sell "Sell"
#define  none "None"
#define  ranging "Ranging"
#define  confused "Confused, and so cannot trade"
#define  trending "Trending"
#define  opentrade "There is a trade open"
#define  stopped "Trading is stopped"



/*


FUNCTIONS LIST
int init()
int start()

----Trading----

void LookForTradingOpportunities()
bool BuyTrigger()
bool SellTrigger()
bool SendSingleTrade(int type, string comment, double lotsize, double price, double stop, double take)
bool DoesTradeExist()
void CountOpenTrades()
bool CloseTrade(int ticket)
void LookForTradeClosure()
bool CheckTradingTimes()

----Matt's Order Reliable library code
bool O_R_CheckForHistory(int ticket) Cheers Matt, You are a star.
void O_R_Sleep(double mean_time, double max_time)

----Indicator readings----
void ReadIndicatorValues()
void GetTdi()
void GetSma()



----Trade management module----
void TradeManagementModule()
void BreakEvenStopLoss()
bool CheckForHiddenStopLossHit(int type, int iPipsAboveVisual, double stop )
void JumpingStopLoss() 
void HiddenTakeProfit()
void HiddenStopLoss()
void TrailingStopLoss()
void CandlestickTrailingStop()

*/

extern string  gen="----General inputs----";
extern double  Lot=0.01;
extern int     TakeProfit=100;
//extern int     StopLoss=100;
extern int     MagicNumber=0;
extern string  TradeComment="";
extern bool    CriminalIsECN=false;
extern string  tt="----Trading hours----";
extern string  Trade_Hours= "Set Morning & Evening Hours";
extern string  Trade_Hoursi= "Use 24 hour, local time clock";
extern string  Trade_Hours_M= "Morning Hours 0-12";
extern  int    start_hourm = 0;
extern  int    end_hourm = 12;
extern string  Trade_Hours_E= "Evening Hours 12-24";
extern  int    start_houre = 12;
extern  int    end_houre = 24;
extern string  spt="----Specific time inputs----";
extern double  StartTime=12.15;
extern string  tmm="----Trade management module----";
extern string  cts="----Candlestick trailing stop----";
extern bool    UseCandlestickTrailingStop=true;
extern string  BE="Break even settings";
extern bool    BreakEven=false;
extern int     BreakEvenPips=25;
extern int     BreakEvenProfit=10;
extern bool    HideBreakEvenStop=false;
extern int     PipsAwayFromVisualBE=5;
extern string  JSL="Jumping stop loss settings";
extern bool    JumpingStop=false;
extern int     JumpingStopPips=50;
extern bool    AddBEP=true;
extern bool    JumpAfterBreakevenOnly=false;
extern bool    HideJumpingStop=false;
extern int     PipsAwayFromVisualJS=10;
extern string  TSL="Trailing stop loss settings";
extern bool    TrailingStop=false;
extern int     TrailingStopPips=50;
extern bool    HideTrailingStop=false;
extern int     PipsAwayFromVisualTS=10;
extern bool    TrailAfterBreakevenOnly=false;
extern bool    StopTrailAtPipsProfit=false;
extern int     StopTrailPips=0;
extern string  hsl1="Hidden stop loss settings";
extern bool    HideStopLossEnabled=false;
extern int     HiddenStopLossPips=20;
extern string  htp="Hidden take profit settings";
extern bool    HideTakeProfitEnabled=false;
extern int     HiddenTakeProfitPips=20;
extern string  mis="----Odds and ends----";
extern bool    ShowManagementAlerts=true;
extern int     DisplayGapSize=30;

//Matt's O-R stuff
int 	         O_R_Setting_max_retries 	= 10;
double 	      O_R_Setting_sleep_time 		= 4.0; /* seconds */
double 	      O_R_Setting_sleep_max 		= 15.0; /* seconds */

//Trading variables
int            TicketNo, OpenTrades;

//TDI
double         TdiGreen, PrevTdiGreen, TdiRed;

//SMA
double         SmaVal;

//Misc
string         Gap, ScreenMessage;
int            OldBars;//Used in candlestick ts function
string         PipDescription=" pips";

void DisplayUserFeedback()
{
   
   if (IsTesting() && !IsVisualMode()) return;

   ScreenMessage = "";
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, TimeToStr(TimeLocal(), TIME_DATE|TIME_MINUTES|TIME_SECONDS), NL );
   /*
   //Code for time to bar-end display from Candle Time by Nick Bilak
   double i;
   int m,s,k;
   m=Time[0]+Period()*60-CurTime();
   i=m/60.0;
   s=m%60;
   m=(m-m%60)/60;
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, m + " minutes " + s + " seconds left to bar end", NL);
   */
      
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);      
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Lot size: ", Lot, NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Take profit: ", TakeProfit, PipDescription,  NL);
   //ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Stop loss: ", StopLoss, PipDescription,  NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Magic number: ", MagicNumber, NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Trade comment: ", TradeComment, NL);
   if (CriminalIsECN) ScreenMessage = StringConcatenate(ScreenMessage,Gap, "CriminalIsECN = true", NL);
   else ScreenMessage = StringConcatenate(ScreenMessage,Gap, "CriminalIsECN = false", NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Criminal's minimum lot size: ", MarketInfo(Symbol(), MODE_MINLOT), NL, NL );
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Trading hours", NL);
   if (start_hourm == 0 && end_hourm == 12 && start_houre && end_houre == 24) ScreenMessage = StringConcatenate(ScreenMessage,Gap, "            24H trading", NL);
   else
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "            start_hourm: ", DoubleToStr(start_hourm, 2), 
                      ": end_hourm: ", DoubleToStr(end_hourm, 2), NL);
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "            start_houre: ", DoubleToStr(start_houre, 2), 
                      ": end_houre: ", DoubleToStr(end_houre, 2), NL);
                      
   }//else
   
   
   
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Tdi Green: ", DoubleToStr(TdiGreen, Digits),
                   ": Previous Tdi Green: ", DoubleToStr(PrevTdiGreen, Digits), NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Tdi Red: ", DoubleToStr(TdiRed, Digits), NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "SMA: ", DoubleToStr(SmaVal, Digits), NL);
   

   ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);
   
   if (UseCandlestickTrailingStop)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Using candlestick trailing stop", NL);      
   }//if (UseCandlestickTrailingStop)
   else ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Not using candlestick trailing stop");   
   
   if (BreakEven)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Breakeven is set to ", BreakEvenPips, PipDescription);
      ScreenMessage = StringConcatenate(ScreenMessage,": BreakEvenProfit = ", BreakEvenProfit, PipDescription);
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL); 
   }//if (BreakEven)

   if (JumpingStop)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Jumping stop is set to ", JumpingStopPips, PipDescription);
      if (AddBEP) ScreenMessage = StringConcatenate(ScreenMessage,": BreakEvenProfit = ", BreakEvenProfit, PipDescription);
      if (JumpAfterBreakevenOnly) ScreenMessage = StringConcatenate(ScreenMessage, ": JumpAfterBreakevenOnly = true");
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);   
   }//if (JumpingStop)
   

   if (TrailingStop)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Trailing stop is set to ", TrailingStopPips, PipDescription);
      if (TrailAfterBreakevenOnly) ScreenMessage = StringConcatenate(ScreenMessage, ": TrailAfterBreakevenOnly = true");
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);   
   }//if (TrailingStop)

   if (HideStopLossEnabled)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Hidden stop loss enabled at ", HiddenStopLossPips, PipDescription, NL);
   }//if (HideStopLossEnabled)
   
   if (HideTakeProfitEnabled)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Hidden take profit enabled at ", HideTakeProfitEnabled, PipDescription, NL);
   }//if (HideTakeProfitEnabled)

   //ScreenMessage = StringConcatenate(ScreenMessage,Gap, "BB Upper line: ", DoubleToStr(BbUpper, Digits), NL);
   //ScreenMessage = StringConcatenate(ScreenMessage,Gap, "BB Middle line: ", DoubleToStr(BbMiddle, Digits), NL);
   //ScreenMessage = StringConcatenate(ScreenMessage,Gap, "BB Lower line: ", DoubleToStr(BbLower, Digits), NL);
   //ScreenMessage = StringConcatenate(ScreenMessage,Gap, "BB Lower line: ", DoubleToStr(BbLower, Digits), NL);
   
   Comment(ScreenMessage);


}//void DisplayUserFeedback()


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----

   //Adapt to x digit criminals
   int multiplier;
   if(Digits == 2 || Digits == 4) multiplier = 1;
   if(Digits == 3 || Digits == 5) multiplier = 10;
   if(Digits == 6) multiplier = 100;   
   if(Digits == 7) multiplier = 1000;   
   
   if (multiplier > 1) PipDescription = " points";
   
   TakeProfit*= multiplier;
   //StopLoss*= multiplier;
   BreakEvenPips*= multiplier;
   BreakEvenProfit*= multiplier;
   PipsAwayFromVisualBE*= multiplier;
   JumpingStopPips*= multiplier;
   PipsAwayFromVisualJS*= multiplier;
   TrailingStopPips*= multiplier;
   PipsAwayFromVisualTS*= multiplier;
   StopTrailPips*= multiplier;
   HiddenStopLossPips*= multiplier;
   HiddenTakeProfitPips*= multiplier;


   Gap="";
   if (DisplayGapSize >0)
   {
      for (int cc=0; cc< DisplayGapSize; cc++)
      {
         Gap = StringConcatenate(Gap, " ");
      }   
   }//if (DisplayGapSize >0)
   

   if (TradeComment == "") TradeComment = " ";
   //OldBars = Bars;
   ReadIndicatorValues();//For initial display in case user has turned of constant re-display
   DisplayUserFeedback();
   
   
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


////////////////////////////////////////////////////////////////////////////////////////////////
//TRADE MANAGEMENT MODULE

bool CheckForHiddenStopLossHit(int type, int iPipsAboveVisual, double stop )
{
   //Reusable code that can be called by any of the stop loss manipulation routines except HiddenStopLoss().
   //Checks to see if the market has hit the hidden sl and attempts to close the trade if so. 
   //Returns true if trade closure is successful, else returns false
   
   //Check buy trade
   if (type == OP_BUY)
   {
      double sl = NormalizeDouble(stop + (iPipsAboveVisual * Point), Digits);
      if (Bid <= sl)
      {
         while(IsTradeContextBusy()) Sleep(100);
         bool result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
         if (result)
         {
            if (ShowManagementAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket());      
         }//if (result)
         else
         {
            int err=GetLastError();
            if (ShowManagementAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//else
      }//if (Bid <= sl)  
   }//if (type = OP_BUY)
   
   //Check buy trade
   if (type == OP_SELL)
   {
      sl = NormalizeDouble(stop - (iPipsAboveVisual * Point), Digits);
      if (Ask >= sl)
      {
         while(IsTradeContextBusy()) Sleep(100);
         result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
         if (result)
         {
            if (ShowManagementAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket());      
         }//if (result)
         else
         {
            err=GetLastError();
            if (ShowManagementAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//else
      }//if (Ask >= sl)  
   }//if (type = OP_SELL)
   

}//End bool CheckForHiddenStopLossHit(int type, int iPipsAboveVisual, double stop )


void BreakEvenStopLoss() // Move stop loss to breakeven
{

   //Check hidden BE for trade closure
   if (HideBreakEvenStop)
   {
      bool TradeClosed = CheckForHiddenStopLossHit(OrderType(), PipsAwayFromVisualBE, OrderStopLoss() );
      if (TradeClosed) return;//Trade has closed, so nothing else to do
   }//if (HideBreakEvenStop)


   bool result;

   if (OrderType()==OP_BUY)
         {
            if (Bid >= OrderOpenPrice () + (Point*BreakEvenPips) && 
                OrderStopLoss()<OrderOpenPrice())
            {
               while(IsTradeContextBusy()) Sleep(100);
               result = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()+(BreakEvenProfit*Point), Digits),OrderTakeProfit(),0,CLR_NONE);
               if (result && ShowManagementAlerts==true) Alert("Breakeven set on ", OrderSymbol(), " ticket no ", OrderTicket());
               Print("Breakeven set on ", OrderSymbol(), " ticket no ", OrderTicket());
               if (!result)
               {
                  int err=GetLastError();
                  if (ShowManagementAlerts==true) Alert("Setting of breakeven SL ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
                  Print("Setting of breakeven SL ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
               }//if !result && ShowManagementAlerts)      
               //if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
               //{
               //   bool PartCloseSuccess = PartCloseTradeFunction();
               //   if (!PartCloseSuccess) SetAGlobalTicketVariable();
               //}//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
            }
   	   }               			         
          
   if (OrderType()==OP_SELL)
         {
           if (Ask <= OrderOpenPrice() - (Point*BreakEvenPips) &&
              (OrderStopLoss()>OrderOpenPrice()|| OrderStopLoss()==0)) 
            {
               while(IsTradeContextBusy()) Sleep(100);
               result = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()-(BreakEvenProfit*Point), Digits),OrderTakeProfit(),0,CLR_NONE);
               if (result && ShowManagementAlerts==true) Alert("Breakeven set on ", OrderSymbol(), " ticket no ", OrderTicket());
               Print("Breakeven set on ", OrderSymbol(), " ticket no ", OrderTicket());
               if (!result && ShowManagementAlerts)
               {
                  err=GetLastError();
                  if (ShowManagementAlerts==true) Alert("Setting of breakeven SL ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
                  Print("Setting of breakeven SL ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
               }//if !result && ShowManagementAlerts)      
              //if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
              // {
              //    PartCloseSuccess = PartCloseTradeFunction();
              //    if (!PartCloseSuccess) SetAGlobalTicketVariable();
              // }//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
            }    
         }
      

} // End BreakevenStopLoss sub

void JumpingStopLoss() 
{
   // Jump sl by pips and at intervals chosen by user .
   // Also carry out partial closure if the user requires this

   // Abort the routine if JumpAfterBreakevenOnly is set to true and be sl is not yet set
   if (JumpAfterBreakevenOnly && OrderType()==OP_BUY)
   {
      if(OrderStopLoss()<OrderOpenPrice()) return(0);
   }
  
   if (JumpAfterBreakevenOnly && OrderType()==OP_SELL)
   {
      if(OrderStopLoss()>OrderOpenPrice() || OrderStopLoss() == 0 ) return(0);
   }
  
   double sl=OrderStopLoss(); //Stop loss

   if (OrderType()==OP_BUY)
   {
      //Check hidden js for trade closure
      if (HideJumpingStop)
      {
         bool TradeClosed = CheckForHiddenStopLossHit(OP_BUY, PipsAwayFromVisualJS, OrderStopLoss() );
         if (TradeClosed) return;//Trade has closed, so nothing else to do
      }//if (HideJumpingStop)
      
      // First check if sl needs setting to breakeven
      if (sl==0 || sl<OrderOpenPrice())
      {
         if (Ask >= OrderOpenPrice() + (JumpingStopPips*Point))
         {
            sl=OrderOpenPrice();
            if (AddBEP==true) sl=sl+(BreakEvenProfit*Point); // If user wants to add a profit to the break even
            while(IsTradeContextBusy()) Sleep(100);
            bool result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
            if (result)
            {
               if (ShowManagementAlerts==true) Alert("Jumping stop set at breakeven ",sl, " ", OrderSymbol(), " ticket no ", OrderTicket());
               Print("Jumping stop set at breakeven: ", OrderSymbol(), ": SL ", sl, ": Ask ", Bid);
               //if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
               //{
                  //bool PartCloseSuccess = PartCloseTradeFunction();
                  //if (!PartCloseSuccess) SetAGlobalTicketVariable();
               //}//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
            }//if (result)
            if (!result)
            {
               int err=GetLastError();
               if (ShowManagementAlerts) Alert(OrderSymbol(), "Ticket ", OrderTicket(), " buy trade. Jumping stop function failed to set SL at breakeven, with error(",err,"): ",ErrorDescription(err));
               Print(OrderSymbol(), " buy trade. Jumping stop function failed to set SL at breakeven, with error(",err,"): ",ErrorDescription(err));
            }//if (!result)
             
            return(0);
         }//if (Ask >= OrderOpenPrice() + (JumpingStopPips*Point))
      } //close if (sl==0 || sl<OrderOpenPrice()

  
      // Increment sl by sl + JumpingStopPips.
      // This will happen when market price >= (sl + JumpingStopPips)
      if (Bid>= sl + ((JumpingStopPips*2)*Point) && sl>= OrderOpenPrice())      
      {
         sl=sl+(JumpingStopPips*Point);
         while(IsTradeContextBusy()) Sleep(100);
         result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
         if (result)
         {
            if (ShowManagementAlerts==true) Alert("Jumping stop set at ",sl, " ", OrderSymbol(), " ticket no ", OrderTicket());
            Print("Jumping stop set: ", OrderSymbol(), ": SL ", sl, ": Ask ", Ask);
            //if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
            //{
               //PartCloseSuccess = PartCloseTradeFunction();
               //if (!PartCloseSuccess) SetAGlobalTicketVariable();
            //}//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
         }//if (result)
         if (!result)
         {
            err=GetLastError();
            if (ShowManagementAlerts) Alert(OrderSymbol(), " buy trade. Jumping stop function failed with error(",err,"): ",ErrorDescription(err));
            Print(OrderSymbol(), " buy trade. Jumping stop function failed with error(",err,"): ",ErrorDescription(err));
         }//if (!result)
             
      }// if (Bid>= sl + (JumpingStopPips*Point) && sl>= OrderOpenPrice())      
   }//if (OrderType()==OP_BUY)
   
   if (OrderType()==OP_SELL)
   {
      //Check hidden js for trade closure
      if (HideJumpingStop)
      {
         TradeClosed = CheckForHiddenStopLossHit(OP_SELL, PipsAwayFromVisualJS, OrderStopLoss() );
         if (TradeClosed) return;//Trade has closed, so nothing else to do
      }//if (HideJumpingStop)
            
      // First check if sl needs setting to breakeven
      if (sl==0 || sl>OrderOpenPrice())
      {
         if (Ask <= OrderOpenPrice() - (JumpingStopPips*Point))
         {
            sl = OrderOpenPrice();
            if (AddBEP==true) sl=sl-(BreakEvenProfit*Point); // If user wants to add a profit to the break even
            while(IsTradeContextBusy()) Sleep(100);
            result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
            if (result)
            {
               //if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
               //{
                 // PartCloseSuccess = PartCloseTradeFunction();
                  //if (!PartCloseSuccess) SetAGlobalTicketVariable();
               //}//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
            }//if (result)
            if (!result)
            {
               err=GetLastError();
               if (ShowManagementAlerts) Alert(OrderSymbol(), " sell trade. Jumping stop function failed to set SL at breakeven, with error(",err,"): ",ErrorDescription(err));
               Print(OrderSymbol(), " sell trade. Jumping stop function failed to set SL at breakeven, with error(",err,"): ",ErrorDescription(err));
            }//if (!result)
             
            return(0);
         }//if (Ask <= OrderOpenPrice() - (JumpingStopPips*Point))
      } // if (sl==0 || sl>OrderOpenPrice()
   
      // Decrement sl by sl - JumpingStopPips.
      // This will happen when market price <= (sl - JumpingStopPips)
      if (Bid<= sl - ((JumpingStopPips*2)*Point) && sl<= OrderOpenPrice())      
      {
         sl=sl-(JumpingStopPips*Point);
         while(IsTradeContextBusy()) Sleep(100);
         result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
         if (result)
         {
            if (ShowManagementAlerts==true) Alert("Jumping stop set at ",sl, " ", OrderSymbol(), " ticket no ", OrderTicket());
            Print("Jumping stop set: ", OrderSymbol(), ": SL ", sl, ": Ask ", Ask);
            //if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
            //{
              // PartCloseSuccess = PartCloseTradeFunction();
               //if (!PartCloseSuccess) SetAGlobalTicketVariable();
            //}//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
         }//if (result)          
         if (!result)
         {
            err=GetLastError();
            if (ShowManagementAlerts) Alert(OrderSymbol(), " sell trade. Jumping stop function failed with error(",err,"): ",ErrorDescription(err));
            Print(OrderSymbol(), " sell trade. Jumping stop function failed with error(",err,"): ",ErrorDescription(err));
         }//if (!result)

      }// close if (Bid>= sl + (JumpingStopPips*Point) && sl>= OrderOpenPrice())         
   }//if (OrderType()==OP_SELL)

} //End of JumpingStopLoss sub

void HiddenStopLoss()
{
   //Called from ManageTrade if HideStopLossEnabled = true


   //Should the order close because the stop has been passed?
   //Buy trade
   if (OrderType() == OP_BUY)
   {
      double sl = NormalizeDouble(OrderOpenPrice() - (HiddenStopLossPips * Point), Digits);
      if (Bid <= sl)
      {
         while(IsTradeContextBusy()) Sleep(100);
         bool result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
         if (result)
         {
            if (ShowManagementAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket());      
         }//if (result)
         else
         {
            int err=GetLastError();
            if (ShowManagementAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//else
      }//if (Bid <= sl)      
   }//if (OrderType() == OP_BUY)
   
   //Sell trade
   if (OrderType() == OP_SELL)
   {
      sl = NormalizeDouble(OrderOpenPrice() + (HiddenStopLossPips * Point), Digits);
      if (Ask >= sl)
      {
         while(IsTradeContextBusy()) Sleep(100);
         result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
         if (result)
         {
            if (ShowManagementAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket());      
         }//if (result)
         else
         {
            err=GetLastError();
            if (ShowManagementAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//else
      }//if (Ask >= sl)   
   }//if (OrderType() == OP_SELL)
   

}//End void HiddenStopLoss()

void HiddenTakeProfit()
{
   //Called from ManageTrade if HideStopLossEnabled = true


   //Should the order close because the stop has been passed?
   //Buy trade
   if (OrderType() == OP_BUY)
   {
      double tp = NormalizeDouble(OrderOpenPrice() + (HiddenTakeProfitPips * Point), Digits);
      if (Bid >= tp)
      {
         while(IsTradeContextBusy()) Sleep(100);
         bool result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
         if (result)
         {
            if (ShowManagementAlerts==true) Alert("Take profit hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket());      
         }//if (result)
         else
         {
            int err=GetLastError();
            if (ShowManagementAlerts==true) Alert("Take profit hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Take profit hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//else
      }//if (Ask >= tp)      
   }//if (OrderType() == OP_BUY)
   
   //Sell trade
   if (OrderType() == OP_SELL)
   {
      tp = NormalizeDouble(OrderOpenPrice() - (HiddenTakeProfitPips * Point), Digits);
      if (Ask <= tp)
      {
         while(IsTradeContextBusy()) Sleep(100);
         result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
         if (result)
         {
            if (ShowManagementAlerts==true) Alert("Take profit hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket());      
         }//if (result)
         else
         {
            err=GetLastError();
            if (ShowManagementAlerts==true) Alert("Take profit hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Take profit hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//else
      }//if (Bid <= tp)   
   }//if (OrderType() == OP_SELL)
   

}//End void HiddenTakeProfit()

void TrailingStopLoss()
{
      if (TrailAfterBreakevenOnly && OrderType()==OP_BUY)
      {
         if(OrderStopLoss()<OrderOpenPrice()) return(0);
      }
     
      if (TrailAfterBreakevenOnly && OrderType()==OP_SELL)
      {
         if(OrderStopLoss()>OrderOpenPrice()) return(0);
      }
     
   
   
   bool result;
   double sl=OrderStopLoss(); //Stop loss
   double BuyStop=0, SellStop=0;
   
   if (OrderType()==OP_BUY) 
      {
         if (HideTrailingStop)
         {
            bool TradeClosed = CheckForHiddenStopLossHit(OP_BUY, PipsAwayFromVisualTS, OrderStopLoss() );
            if (TradeClosed) return;//Trade has closed, so nothing else to do
         }//if (HideJumpingStop)
		   
		   if (Bid >= OrderOpenPrice() + (TrailingStopPips*Point))
		   {
		       if (OrderStopLoss() == 0) sl = OrderOpenPrice();
		       if (Bid > sl +  (TrailingStopPips*Point))
		       {
		          sl= Bid - (TrailingStopPips*Point);
		          // Exit routine if user has chosen StopTrailAtPipsProfit and
		          // sl is past the profit Point already
		          if (StopTrailAtPipsProfit && sl>= OrderOpenPrice() + (StopTrailPips*Point)) return;
		          while(IsTradeContextBusy()) Sleep(100);
		          result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
               if (result)
               {
                  Print("Trailing stop updated: ", OrderSymbol(), ": SL ", sl, ": Ask ", Ask);
               }//if (result) 
               else
               {
                  int err=GetLastError();
                  Print(OrderSymbol(), " order modify failed with error(",err,"): ",ErrorDescription(err));
               }//else
   
		       }//if (Bid > sl +  (TrailingStopPips*Point))
		   }//if (Bid >= OrderOpenPrice() + (TrailingStopPips*Point))
      }//if (OrderType()==OP_BUY) 

      if (OrderType()==OP_SELL) 
      {
		   if (Ask <= OrderOpenPrice() - (TrailingStopPips*Point))
		   {
             if (HideTrailingStop)
             {
                TradeClosed = CheckForHiddenStopLossHit(OP_SELL, PipsAwayFromVisualTS, OrderStopLoss() );
                if (TradeClosed) return;//Trade has closed, so nothing else to do
             }//if (HideJumpingStop)
		   
		       if (OrderStopLoss() == 0) sl = OrderOpenPrice();
		       if (Ask < sl -  (TrailingStopPips*Point))
		       {
	               sl= Ask + (TrailingStopPips*Point);
  	               // Exit routine if user has chosen StopTrailAtPipsProfit and
		            // sl is past the profit Point already
		            if (StopTrailAtPipsProfit && sl<= OrderOpenPrice() - (StopTrailPips*Point)) return;
		            while(IsTradeContextBusy()) Sleep(100);
		            result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
                  if (result)
                  {
                     Print("Trailing stop updated: ", OrderSymbol(), ": SL ", sl, ": Bid ", Bid);
                  }//if (result)
                  else
                  {
                     err=GetLastError();
                     Print(OrderSymbol(), " order modify failed with error(",err,"): ",ErrorDescription(err));
                  }//else
    
		       }//if (Ask < sl -  (TrailingStopPips*Point))
		   }//if (Ask <= OrderOpenPrice() - (TrailingStopPips*Point))
      }//if (OrderType()==OP_SELL) 

      
} // End of TrailingStopLoss sub

void CandlestickTrailingStop()
{
   if (OldBars == Bars) return;
   OldBars = Bars;
   bool result = false, modify = false;
   int err;
   double stop;
   
   if (OrderType() == OP_BUY)
   {
      if (Low[1] > OrderStopLoss() && OrderProfit() >= 0)
      {
         stop = NormalizeDouble(Low[1], Digits);
         modify = true;
      }//if (Close[1] > OrderStopLoss() && OrderProfit() >= 0)
   }//if (OrderType == OP_BUY)
   
   if (OrderType() == OP_SELL)
   {
      if ( (High[1] < OrderStopLoss() || OrderStopLoss() == 0) && OrderProfit() >= 0)
      {
         stop = NormalizeDouble(High[1], Digits);
         modify = true;
      }//if (Close[1] > OrderStopLoss() && OrderProfit() >= 0)
   }//if (OrderType() == OP_SELL)
   

   if (modify)
   {
      result = OrderModify(OrderTicket(), OrderOpenPrice(), stop, OrderTakeProfit(), OrderExpiration(), CLR_NONE);
      if (!result)
      {
         err = GetLastError();
         if (err != 130) OldBars = 0;//Retry the modify at the next tick unless the error is invalid stops
      }//if (!result)      
   }//if (modify)
   
   
}//End void CandlestickTrailingStop()


void TradeManagementModule()
{

   // Call the working subroutines one by one. 

   //Candlestick trailing stop
   if (UseCandlestickTrailingStop) CandlestickTrailingStop();
   
   // Hidden stop loss
   if (HideStopLossEnabled) HiddenStopLoss();

   // Hidden take profit
   if (HideTakeProfitEnabled) HiddenTakeProfit();

   // Breakeven
   if(BreakEven) BreakEvenStopLoss();

   // JumpingStop
   if(JumpingStop) JumpingStopLoss();

   //TrailingStop
   if(TrailingStop) TrailingStopLoss();

   

}//void TradeManagementModule()
//END TRADE MANAGEMENT MODULE
////////////////////////////////////////////////////////////////////////////////////////////////

bool SendSingleTrade(int type, string comment, double lotsize, double price, double stop, double take)
{
   
   
   int slippage = 10;
   if (Digits == 3 || Digits == 5) slippage = 100;
   
   color col = Red;
   if (type == OP_BUY || type == OP_BUYSTOP) col = Green;
   
   int expiry = 0;
   //if (SendPendingTrades) expiry = TimeCurrent() + (PendingExpiryMinutes * 60);

   if (!CriminalIsECN) int ticket = OrderSend(Symbol(),type, lotsize, price, slippage, stop, take, comment, MagicNumber, expiry, col);
   
   
   //Is a 2 stage criminal
   if (CriminalIsECN)
   {
      bool result;
      int err;
      ticket = OrderSend(Symbol(),type, lotsize, price, slippage, 0, 0, comment, MagicNumber, expiry, col);
      if (ticket > 0)
      {
	     
	     if (take > 0 && stop > 0)
        {
           while(IsTradeContextBusy()) Sleep(100);
           result = OrderModify(ticket, OrderOpenPrice(), stop, take, OrderExpiration(), CLR_NONE);
           if (!result)
           {
               err=GetLastError();
               Print(Symbol(), " SL/TP  order modify failed with error(",err,"): ",ErrorDescription(err));               
           }//if (!result)			  
        }//if (take > 0 && stop > 0)
      
	     if (take != 0 && stop == 0)
        {
           while(IsTradeContextBusy()) Sleep(100);
           result = OrderModify(ticket, OrderOpenPrice(), OrderStopLoss(), take, OrderExpiration(), CLR_NONE);
           if (!result)
           {
               err=GetLastError();
               Print(Symbol(), " SL  order modify failed with error(",err,"): ",ErrorDescription(err));               
           }//if (!result)			  
        }//if (take == 0 && stop != 0)

        if (take == 0 && stop != 0)
        {
           while(IsTradeContextBusy()) Sleep(100);
           result = OrderModify(ticket, OrderOpenPrice(), stop, OrderTakeProfit(), OrderExpiration(), CLR_NONE);
           if (!result)
           {
               err=GetLastError();
               Print(Symbol(), " SL  order modify failed with error(",err,"): ",ErrorDescription(err));               
           }//if (!result)			  
        }//if (take == 0 && stop != 0)

      }//if (ticket > 0)
        
      
      
   }//if (CriminalIsECN)
   
   //Error trapping for both
   if (ticket < 0)
   {
      string stype;
      if (type == OP_BUY) stype = "OP_BUY";
      if (type == OP_SELL) stype = "OP_SELL";
      if (type == OP_BUYLIMIT) stype = "OP_BUYLIMIT";
      if (type == OP_SELLLIMIT) stype = "OP_SELLLIMIT";
      if (type == OP_BUYSTOP) stype = "OP_BUYSTOP";
      if (type == OP_SELLSTOP) stype = "OP_SELLSTOP";
      err=GetLastError();
      Alert(Symbol(), " ", stype," order send failed with error(",err,"): ",ErrorDescription(err));
      Print(Symbol(), " ", stype," order send failed with error(",err,"): ",ErrorDescription(err));
      return(false);
   }//if (ticket < 0)  
   
   
   TicketNo = ticket;
   //Make sure the trade has appeared in the platform's history to avoid duplicate trades
   O_R_CheckForHistory(ticket); 
   
   //Got this far, so trade send succeeded
   return(true);
   
}//End bool SendSingleTrade(int type, string comment, double lotsize, double price, double stop, double take)

bool DoesTradeExist()
{
   
   TicketNo = -1;
   
   if (OrdersTotal() == 0) return(false);
   
   for (int cc = OrdersTotal() - 1; cc >= 0 ; cc--)
   {
      if (!OrderSelect(cc,SELECT_BY_POS)) continue;
      
      if (OrderMagicNumber()==MagicNumber && OrderSymbol() == Symbol() )      
      {
         TicketNo = OrderTicket();
         return(true);         
      }//if (OrderMagicNumber()==MagicNumber && OrderSymbol() == Symbol() )      
   }//for (int cc = OrdersTotal() - 1; cc >= 0 ; cc--)

   return(false);

}//End bool DoesTradeExist()

bool BuyTrigger()
{
   //Called by LookForTradingOpportunities().
   //Returns true if buy conditions are met, else false
   
   //Green/red cross
   if (TdiGreen < TdiRed) return(false);//Green below red
   if (TdiGreen > TdiRed && PrevTdiGreen > TdiRed) return(false);//No cross
   
   //Green angle
   if(PrevTdiGreen >= TdiGreen) return(false);
   
   //Current candle must be green
   if (Ask <= Open[0] ) return(false);
   
   //Prev candle must close above sma
   if (Close[1] < SmaVal) return(false);
   
   
   
   //Got this far, so conditions are good for the trade
   return(true);

}//bool BuyTrigger()

bool SellTrigger()
{
   //Called by LookForTradingOpportunities().
   //Returns true if sell conditions are met, else false
   
   //Green/red cross
   if (TdiGreen > TdiRed) return(false);//Green above red
   if (TdiGreen < TdiRed && PrevTdiGreen < TdiRed) return(false);//No cross
   
   //Green angle
   if(PrevTdiGreen <= TdiGreen) return(false);
   
   //Current candle must be green
   if (Bid >= Open[0] ) return(false);
   
   //Prev candle must close below sma
   if (Close[1] > SmaVal) return(false);
   
   
   
   //Got this far, so conditions are good for the trade
   return(true);

}//End bool SellTrigger()



void LookForTradingOpportunities()
{


   RefreshRates();
   double take, stop, price;
   int type;
   bool SendTrade;

   bool SendBuy = BuyTrigger();
   bool SendSell = SellTrigger();

   //Long 
   if (SendBuy)
   {
      if (TakeProfit > 0) take = NormalizeDouble(Ask + (TakeProfit * Point), Digits);
      //if (StopLoss > 0) stop = NormalizeDouble(Ask - (StopLoss * Point), Digits);
      stop = Low[2];
      type = OP_BUY;
      price = Ask;
      SendTrade = true;
   }//if (SendBuy)
   

   //Short
   if (SendSell)
   {
      if (TakeProfit > 0) take = NormalizeDouble(Bid - (TakeProfit * Point), Digits);
      //if (StopLoss > 0) stop = NormalizeDouble(Bid + (StopLoss * Point), Digits);
      stop = High[2];
      type = OP_SELL;
      price = Bid;
      SendTrade = true;      
   }//if (SendSell)
   

   if (SendTrade)
   {
      bool result = SendSingleTrade(type, TradeComment, Lot, price, stop, take);
   }//if (SendTrade)
   
   //Actions when trade send succeeds
   if (SendTrade && result)
   {
   
   }//if (result)
   
   //Actions when trade send fails
   if (SendTrade && !result)
   {
   
   }//if (!result)
   
   

}//void LookForTradingOpportunities()

bool CloseTrade(int ticket)
{   
   while(IsTradeContextBusy()) Sleep(100);
   bool result = OrderClose(ticket, OrderLots(), OrderClosePrice(), 1000, CLR_NONE);

   //Actions when trade send succeeds
   if (result)
   {
      return(true);
   }//if (result)
   
   //Actions when trade send fails
   if (!result)
   {
      return(false);
   }//if (!result)
   

}//End bool CloseTrade(ticket)

////////////////////////////////////////////////////////////////////////////////////////////////
//Indicator module

void GetTdi()
{
   
/*
extern int RSI_Period = 13;         //8-25
extern int RSI_Price = 0;           //0-6
extern int Volatility_Band = 34;    //20-40
extern int RSI_Price_Line = 2;      
extern int RSI_Price_Type = 0;      //0-3
extern int Trade_Signal_Line = 7;   
extern int Trade_Signal_Type = 0;   //0-3
*/   
   
   TdiGreen = iCustom(NULL, 0, "TDI Red Green", 13, 0, 34, 2, 0, 7, 0,  4, 0);
   PrevTdiGreen = iCustom(NULL, 0, "TDI Red Green", 13, 0, 34, 2, 0, 7, 0,  4, 1);
   TdiRed = iCustom(NULL, 0, "TDI Red Green", 13, 0, 34, 2, 0, 7, 0,  5, 0);

}//Endvoid GetTdi()

void GetSma()
{

   SmaVal = iMA(NULL, 0, 5, 1, MODE_SMA, PRICE_TYPICAL, 0);

}//End void GetSma()


void ReadIndicatorValues()
{

   GetTdi();
   GetSma();
   
}//End void ReadIndicatorValues()

//End Indicator module
////////////////////////////////////////////////////////////////////////////////////////////////

void LookForTradeClosure()
{
   //Close the trade if the new candle opens inside the bands
   
   if (!OrderSelect(TicketNo, SELECT_BY_TICKET) ) return;
   
   bool CloseTrade;
   
   if (OrderType() == OP_BUY)
   {
      if (Close[1] < SmaVal) CloseTrade = true;
   }//if (OrderType() == OP_BUY)
   
   
   if (OrderType() == OP_SELL)
   {
      if (Close[1] > SmaVal) CloseTrade = true;
   }//if (OrderType() == OP_SELL)
   
   if (CloseTrade)
   {
      bool result = CloseTrade(TicketNo);
      //Actions when trade send succeeds
      if (result)
      {
   
      }//if (result)
   
      //Actions when trade send fails
      if (!result)
      {
   
      }//if (!result)
   

   }//if (CloseTrade)
   
   
}//void LookForTradeClosure()


bool CheckTradingTimes()
{
   int hour = TimeHour(TimeLocal() );
   
   if (end_hourm < start_hourm)
	{
		end_hourm += 24;
	}
	

	if (end_houre < start_houre)
	{
		end_houre += 24;
	}
	
	bool ok2Trade = true;
	
	ok2Trade = (hour >= start_hourm && hour <= end_hourm) || (hour >= start_houre && hour <= end_houre);

	// adjust for past-end-of-day cases
	// eg in AUS, USDJPY trades 09-17 and 22-06
	// so, the above check failed, check if it is because of this condition
	if (!ok2Trade && hour < 12)
	{
 		hour += 24;
		ok2Trade = (hour >= start_hourm && hour <= end_hourm) || (hour >= start_houre && hour <= end_houre);		
		// so, if the trading hours are 11pm - 6am and the time is between  midnight to 11am, (say, 5am)
		// the above code will result in comparing 5+24 to see if it is between 23 (11pm) and 30(6+24), which it is...
	}


   // check for end of day by looking at *both* end-hours

   if (hour >= MathMax(end_hourm, end_houre))
   {      
      ok2Trade = false;
   }//if (hour >= MathMax(end_hourm, end_houre))

   return(ok2Trade);

}//bool CheckTradingTimes()

void CountOpenTrades()
{
   OpenTrades = 0;
   TicketNo = -1;
   

   if (OrdersTotal() == 0) return;
   
   for (int cc = 0; cc <= OrdersTotal(); cc++)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
      {
         OpenTrades++;
         TicketNo = OrderTicket();   
      }//if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
   }//for (int cc = 0; cc < OrdersTotal() - 1; cc++)
   
   
}//End void CountOpenTrades();

//=============================================================================
//                           O_R_CheckForHistory()
//
//  This function is to work around a very annoying and dangerous bug in MT4:
//      immediately after you send a trade, the trade may NOT show up in the
//      order history, even though it exists according to ticket number.
//      As a result, EA's which count history to check for trade entries
//      may give many multiple entries, possibly blowing your account!
//
//  This function will take a ticket number and loop until
//  it is seen in the history.
//
//  RETURN VALUE:
//     TRUE if successful, FALSE otherwise
//
//
//  FEATURES:
//     * Re-trying under some error conditions, sleeping a random
//       time defined by an exponential probability distribution.
//
//     * Displays various error messages on the log for debugging.
//
//  ORIGINAL AUTHOR AND DATE:
//     Matt Kennel, 2010
//
//=============================================================================
bool O_R_CheckForHistory(int ticket)
{
   //My thanks to Matt for this code. He also has the undying gratitude of all users of my trading robots
   
   int lastTicket = OrderTicket();

   int cnt = 0;
   int err = GetLastError(); // so we clear the global variable.
   err = 0;
   bool exit_loop = false;
   bool success=false;

   while (!exit_loop) {
      /* loop through open trades */
      int total=OrdersTotal();
      for(int c = 0; c < total; c++) {
         if(OrderSelect(c,SELECT_BY_POS,MODE_TRADES) == true) {
            if (OrderTicket() == ticket) {
               success = true;
               exit_loop = true;
            }
         }
      }
      if (cnt > 3) {
         /* look through history too, as order may have opened and closed immediately */
         total=OrdersHistoryTotal();
         for(c = 0; c < total; c++) {
            if(OrderSelect(c,SELECT_BY_POS,MODE_HISTORY) == true) {
               if (OrderTicket() == ticket) {
                  success = true;
                  exit_loop = true;
               }
            }
         }
      }

      cnt = cnt+1;
      if (cnt > O_R_Setting_max_retries) {
         exit_loop = true;
      }
      if (!(success || exit_loop)) {
         Print("Did not find #"+ticket+" in history, sleeping, then doing retry #"+cnt);
         O_R_Sleep(O_R_Setting_sleep_time, O_R_Setting_sleep_max);
      }
   }
   // Select back the prior ticket num in case caller was using it.
   if (lastTicket >= 0) {
      OrderSelect(lastTicket, SELECT_BY_TICKET, MODE_TRADES);
   }
   if (!success) {
      Print("Never found #"+ticket+" in history! crap!");
   }
   return(success);
}//End bool O_R_CheckForHistory(int ticket)

//=============================================================================
//                              O_R_Sleep()
//
//  This sleeps a random amount of time defined by an exponential
//  probability distribution. The mean time, in Seconds is given
//  in 'mean_time'.
//  This returns immediately if we are backtesting
//  and does not sleep.
//
//=============================================================================
void O_R_Sleep(double mean_time, double max_time)
{
   if (IsTesting()) {
      return;   // return immediately if backtesting.
   }

   double p = (MathRand()+1) / 32768.0;
   double t = -MathLog(p)*mean_time;
   t = MathMin(t,max_time);
   int ms = t*1000;
   if (ms < 10) {
      ms=10;
   }
   Sleep(ms);
}//End void O_R_Sleep(double mean_time, double max_time)



//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----

   static bool TradeExists;
   
   if (OrdersTotal() == 0)
   {
      TicketNo = -1;
   }//if (OrdersTotal() == 0)

   ReadIndicatorValues();

   
      
   ///////////////////////////////////////////////////////////////////////////////////////////////
   //Find open trades
   if (OrdersTotal() > 0)
   {
      CountOpenTrades();
      TradeExists = DoesTradeExist();
      if (TradeExists )
      {
         if (OrderProfit() > 0) TradeManagementModule();
         LookForTradeClosure();
      }//if (TradeExists)
   }//if (OrdersTotal() > 0)

   ///////////////////////////////////////////////////////////////////////////////////////////////
   
   
 
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //Trading times
   bool TradeTimeOk = CheckTradingTimes();
   if (!TradeTimeOk)
   {
      Comment("Outside trading hours\nstart_hourm-end_hourm: ", start_hourm, "-",end_hourm, "\nstart_houre-end_houre: ", start_houre, "-",end_houre);
      return;
   }//if (hour < start_hourm)
   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   ///////////////////////////////////////////////////////////////////////////////////////////////         
   //Trading
   if (TicketNo == -1)
   {
      LookForTradingOpportunities();
   }//if (TicketNo == -1)
   ///////////////////////////////////////////////////////////////////////////////////////////////      

   DisplayUserFeedback();
   
//----
   return(0);
}
//+------------------------------------------------------------------+