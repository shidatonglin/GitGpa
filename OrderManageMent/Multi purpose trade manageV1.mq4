//+------------------------------------------------------------------+
//|                                  Multi-purpose trade manager.mq4 |
//|                                  Copyright © 2008, Steve Hopwood |
//|                              http://www.hopwood3.freeserve.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Steve Hopwood"
#property link      "http://www.hopwood3.freeserve.co.uk"
#include <WinUser32.mqh>
#include <stdlib.mqh>
#define  NL    "\n"

/*
The Start function calls the MonitorTrades function. This cycles through the list of open orders,
checking to see which management style the user has chosen - by ticket number, magic number,
comment or all trades, regardelss of anything else etc. 

If an appropriate management style choice is found, the ManageTrade function is called. This in
turn calls functions that checks for action depending on the choice of facilities - breakeven, 
jumping stop etc.

The ea offers the option to close 50% of a profitable trade at a target 
set by the user (PartCloseOrder).

It offers a hedge-trade facility for when a trade starts to go wrong.

Thanks to the always-on code provided by gspe, start() calls main(). main() replaces the normal start().

main() then calls GlobalOrderClosure. If enabled, this routine closes all open orders at
a $profit or % of account balance.

main() then calls ShirtProtection, a routine that closes all open trades at a upl loss point
chosen by the user. "Losing your shirt" is a slang expression to describe losing everything - money,
home etc.

main() then call MonitorBasketTrades, a routine that calls all the funtions required to monitor
trading basketes from systems such as T101 and ES.

The order of program run is: Start calls MonitorTrades (calls ManageTrade that calls all the 
functions that actually do the work) then GlobalOrderClosure, then ShirtProtection, 
then MonitorBasketTrades.

Functions list:
int start()   holds the always on loop that calls main(), which was the original start()
int main()
void MonitorTrades()
void ManageTrade()
void ShirtProtection()
void BreakEvenStopLoss()
void JumpingStopLoss()
bool CheckForHiddenStopLossHit(int type, int iPipsAboveVisual, double stop )
bool PartCloseTradeFunction()
void TryPartCloseAgain()
void SetAGlobalTicketVariable()
int GetNextAvailableVariableNumber()
void TrailingStopLoss()
void InstantTrailingStopLoss()
void HiddenStopLoss()
void HiddenTakeProfit()
void GlobalOrderClosure()
bool ExtractPartCloseVariables()
void PartCloseOrder()
bool CheckForExistingHedge()
void HedgeTrade()
void DeleteOrphanHedgeGVs()
void DetermineTrendDirection(string symbol)
void MonitorBasketTrades()
void CloseBasketTrades()
void CalculateBasketPL()
bool ShouldBasketCloseAtSL()
void BasketTrailingStopManipulation()
bool ConfirmBasketClosure()
double getPipValue(double ord,int dir)
void checkStops(int pips,int ticket)
void moveStops(int ticket,int stopDiff)
void takeProfit(int pips, int ticket)
void CheckBasketTradesExpiry()
void BasketJumpingStopManipulation()
bool ShouldBasketCloseAtAutocalcTP()
double AutoPercentageBasketTp()
void InsertStopLoss()
void InsertTakeProfit()
void TightenStopLoss()

*/

// These allow the EA to run AlwaysOn even without any ticks
extern string	b10			= "===== AlwaysOn =====";
extern bool		AlwaysOn	= true;		// EA Run every delay (ms) (true) or every ticks (false)
extern int		delay		= 1000;		//====== Time (ms) restart adviser in AlwaysOn mode
// User can choose a variety of trade managment triggers.
// These are for use on a chart that controls the currency of that chart
extern string  ManagementStyle="You can select more than one option";
extern bool    ManageByMagicNumber=false;
extern int     MagicNumber=1;
extern bool    ManageByTradeComment=false;
extern string  TradeComment = "Fib";
extern bool    ManageByTickeNumber=false;
extern int     TicketNumber;
extern string  OverRide="ManageThisPairOnly will override all previous";
extern string  OverRide2="or can be used in combination with 1 of above";
extern bool    ManageThisPairOnly=false;
extern bool    ManageSpecifiedPairs=false;//############## ADDED BY CACUS
extern string  PairsToManage="AUDJPY,AUDUSD,CHFJPY,EURCHF,EURGBP,EURJPY,EURUSD,GBPCHF,GBPJPY,GBPUSD,NZDJPY,NZDUSD,USDCHF,USDJPY";//############## ADDED BY CACUS
// This allows the ea to manage all existing trades
extern string  OverRide1="ManageAllTrades will override all others";
extern bool    ManageAllTrades=false;
extern bool    ManagingNanningbobTrades=false;

// Now give user a variety of facilities
extern string  bl1="---------------------------------------------------------------------";
extern string  ManagementFacilities="Select the management facilities you want";
extern string  slf="----Stop Loss & Take Profit Manipulation----";
extern bool    DoNotOverload5DigitCriminals=false;
extern string  BE="Break even settings";
extern bool    BreakEven=false;
extern int     BreakEvenPips=10;
extern int     BreakEvenProfit=2;
extern bool    HideBreakEvenStop=false;
extern int     PipsAwayFromVisualBE=100;
extern string  JSL="Jumping stop loss settings";
extern bool    JumpingStop=false;
extern int     JumpingStopPips=50;
extern bool    AddBEP=false;
extern bool    JumpAfterBreakevenOnly=false;
extern bool    HideJumpingStop=false;
extern int     PipsAwayFromVisualJS=100;
extern string  pcbe="PartClose settings can be used in";
extern string  pcbe1="conjunction with Breakeven settings";
extern bool    PartCloseEnabled=false;
extern double  Close_Lots = 0.02;
extern double  Preserve_Lots=0.02;
extern string  TSL="Trailing stop loss settings";
extern bool    TrailingStop=false;
//If using TS, the user has the option of a normal trail or a candlestick trail.
extern bool    UseStandardTrail=true;
extern int     TrailingStopPips=30;
extern bool    UseCandlestickTrail=false;//Candlestick trailing stop
extern int     CandlestickTrailTimeFrame=60;//Candlestick time frame
extern int     CandleShift=1;
extern bool    HideTrailingStop=false;
extern int     PipsAwayFromVisualTS=100;
extern bool    TrailAfterBreakevenOnly=false;
extern bool    StopTrailAtPipsProfit=false;
extern int     StopTrailPips=0;
extern string  ITSL="Instant trailing stop loss settings";
extern bool    InstantTrailingStop=false;
extern int     InstantTrailingStopPips=30;
extern int     FiveDigitIncrement=0;
extern bool    StopInstantTrailAfterBreakEven=false;
extern bool    StopInstantTrailAtPipsProfit=false;
extern int     StopInstantTrailPips=0;
extern string  hsl1="Hidden stop loss settings";
extern bool    HideStopLossEnabled=false;
extern int     HiddenStopLossPips=200;
extern string  TSF="Tightening stop feature";
extern bool    UseTigheningStop=false;
extern int     TrailAt50Percent=300;
extern int     TrailAt80Percent=200;
extern string  MSLA="Add a missing Stop Loss";
extern bool    AddMissingStopLoss=false;
extern int     MissingStopLossPips=200;
extern bool    UseSlAtr=false;
extern int     AtrSlPeriod=20;
extern int     AtrSlTimeFrame=0;
extern double  AtrSlMultiplier=2;
extern string  MTPA="Add a missing Take Profit";
extern bool    AddMissingTakeProfit=false;
extern int     MissingTakeProfitPips=200;
extern bool    UseTpAtr=false;
extern int     AtrTpPeriod=20;
extern int     AtrTpTimeFrame=0;
extern double  AtrTpMultiplier=3;
extern string  htp="Hidden take profit settings";
extern bool    HideTakeProfitEnabled=false;
extern int     HiddenTakeProfitPips=200;

extern string  bl2="---------------------------------------------------------------------";
extern string  GOC="----Global order closure settings----";
extern bool    GlobalOrderClosureEnabled=false;
extern bool    IncludePendingOrdersInClosure=false;
extern bool    ProfitInDollars=false;
extern double  DollarProfit=100000;
extern bool    ProfitAsPercentageOfBalance=false;
extern double  PercentageProfit=10000;
extern bool    ProfitInPips=false;
extern int     PipsProfit=30;
extern bool    UseDynamicPipsProfit=false;
extern int     PipsPerTrade=5;

extern string  bl9="---------------------------------------------------------------------";
extern string  bin1="----Basket trade settings----";
extern string  bin2="Set ManageByMagicNumber or";
extern string  bin3="ManageByTradeComment to true";
extern string  bin4=" to use these features";
extern bool    ManageBasketTrades=false;
extern bool    AllTradesBelongToBasket=false;
extern bool    IncludePendingsAtClosure=false;
extern string  bin5="Basket take profit settings";
extern bool    BasketClosureTP=false;
extern bool    BasketTPinDollars=false;
extern double  BasketDollarTP=100000;
extern bool    BasketTPasPercent=false;
extern double  BasketTpPercentage=1;
extern bool    AutoCalcBasketTPasPercent=false;
extern double  FourToSevenTradesPercent=1;
extern double  EightToTwelveTradesPercent=2;
extern double  ThirteenPlusTradesPercent=3;
extern string  bin6="Basket stop loss settings";
extern bool    BasketClosureSL=false;
extern bool    BasketSLinDollars=false;
extern double  BasketDollarSL=100000;
extern bool    BasketSLasPercent=false;
extern double  BasketSLPercentage=1;
extern string  bin13="Basket jumping stop settings";
extern bool    BasketJumpingStop=false;
extern double  BasketJumpingStopProfit=1;
extern bool    BasketAddBEP=false;
extern double  BasketBreakEvenProfit=0.1;
extern bool    DisableBasketJumpStopAfterBE=false;
extern string  bin7="Basket trailing stop settings";
extern bool    BasketTrailingStop=false;
extern double  BasketTsAtProfit=1;
extern double  BasketTrailPercent=75;
extern string  bin8="Immediate basket closure setting. Use with care";
extern bool    BasketCloseImmediately=false;
extern string  bin9="Trade expiry settings";
extern bool    TradesWillExpire=false;
extern int     TradesWillExpireMins=210;

extern string  bl3="---------------------------------------------------------------------";
extern string  hs="----Hedge settings----";
extern bool    HedgeEnabled=false;
extern int     HedgeAtLossPips=40;
extern double  HedgeLotsPercent=200;
extern int     HedgingIncrementPips=500000;
extern int     HedgeTradeStopLoss=0;
extern int     HedgeTradeTakeProfit=0;
extern bool    CloseAtBreakEven=false;
extern bool    HedgingTheHedgeIsAllowed=false;
extern double  HedgeTheHedgeLotsPercent=200;
extern string  Ins14="Trend filter choices";
extern bool    UseEnvelopeTrendFilter=false;
extern int     LookBackBars=3;
extern bool    UseAdxTrendFilter=false;
extern int     AdxPeriod=14;
extern bool    UseCandleDirection=false;
extern int     LookBackCandleHours = 3;

extern string  bl5="---------------------------------------------------------------------";
extern string  sps="----Shirt-protection settings----";
extern string  spsi="Close all open trades at this $ loss";
extern bool    ShirtProtectionEnabled=false;
extern double  MaxLoss=-150;
extern bool    IncludePendingInClosure=false;

extern string  bl6="---------------------------------------------------------------------";
extern string  OtherStuff="----Other stuff----";
extern bool    ShowAlerts=true;
// Added by Robert for those who do not want the comments.
extern bool    ShowComments = true;
// Added by Robert for those who do not want the journal messages.
extern bool    PrintToJournal = true;

double         LockedProfit=-1;
int            cnt=0; //loop counter
double         bid, ask; // For storing the Bid\Ask so that one instance of the ea can manage all trades, if required
double         point, digits; // Saves the Point and Digits of an order
// Variables for part-close reoutine
double         TargetAsPrice, TargetAsPips;
bool           TrendUp=true;
bool           TrendDown=true;
bool           CloseBasket=false;
string         ScreenMessage;
double         BasketProfit;
bool           sl;
int            nextTP;
string         TicketName = "GlobalVariableTicketNo";// For storing ticket numbers in global vars for picking up failed part-closes
bool           GlobalVariablesExist=false;
int            NoOfBasketTrades;//Holds the no of basket trades open. Set in CalculateBasketPL()
//int            TrailingStopPipsStore;//Saves the trailing stop pips setting in int init()

int            OldHourlyBars;//Used to tell the manager it is a new day and prompt it to go looking for orphaned hedge gv's
int            Pips;//For pips target calculation

//############## ADDED BY CACUS
string            String;
int               PairsQty;
string suffix;
string ManagePair[20];
//############## ADDED BY CACUS

//############## ADDED BY CACUS
int PairsQty()
{
   int i = 0;
   int j;
   int qty=0;
   
   while(i > -1)
      {
         i = StringFind(String, ",",j);
         if (i > -1)
         {
            qty ++;
            j = i+1;            
         }
      }
      return(qty);
}
//############## ADDED BY CACUS
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   //############## ADDED BY CACUS
   String=PairsToManage;
   if (StringSubstr(String, StringLen(String)-1) != ",") String = StringConcatenate(String,",");
   //############## ADDED BY CACUS
      
   //TrailingStopPipsStore=TrailingStopPips;
   
   //Make sure the basket sl is a negativ number
   if (BasketDollarSL > 0) BasketDollarSL = -BasketDollarSL;
   
   //Accommodate different quote sizes
   double multiplier;
   if(Digits == 2 || Digits == 4) multiplier = 1;
   if(Digits == 3 || Digits == 5) multiplier = 10;
   if(Digits == 6) multiplier = 100;   
   if(Digits == 7) multiplier = 1000;   
   BreakEvenPips*= multiplier;
   BreakEvenProfit*= multiplier;
   PipsAwayFromVisualBE*= multiplier;
   JumpingStopPips*= multiplier;
   PipsAwayFromVisualJS*= multiplier;
   TrailingStopPips*= multiplier;
   PipsAwayFromVisualTS*= multiplier;
   StopTrailPips*= multiplier;
   InstantTrailingStopPips*= multiplier;
   FiveDigitIncrement*= multiplier;
   StopInstantTrailPips*= multiplier;
   HiddenStopLossPips*= multiplier;
   TrailAt50Percent*= multiplier;
   TrailAt80Percent*= multiplier;
   MissingStopLossPips*= multiplier;
   MissingTakeProfitPips*= multiplier;
   HiddenTakeProfitPips*= multiplier;
   HedgeAtLossPips*= multiplier;
   HedgingIncrementPips*= multiplier;
   HedgeTradeStopLoss*= multiplier;
   HedgeTradeTakeProfit*= multiplier;
   PipsProfit*= multiplier;
   PipsPerTrade*= multiplier;
   
   //*= multiplier;
      
     return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
      Comment("");
      return(0);
  }
void MonitorTrades()
{

   bool ManageTrade; // tell the program when there is a trade to manage
   string ScreenMessage;
   
   
   for (cnt=OrdersTotal() - 1; cnt >= 0; cnt--)
   { 
      if (OrderSelect(cnt, SELECT_BY_POS) )
      {
         //If there are >1 trades open, then we must be into Recovery, and so do not want
         //indiidual trade management
         bool abort = false;
         if (ManagingNanningbobTrades)
         {
            int ticket = OrderTicket();
            string sSymbol = OrderSymbol();
            for (int cc = cnt - 1; cc >= 0; cc --)
            {
               if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
               if (OrderSymbol() == sSymbol)
               {
                  abort = true;
                  break;
               }//if (OrderSymbol() == sSymbol)                  
            }//for (int cc = cnt - 1; cc >= 0; cc --)
            OrderSelect(ticket, SELECT_BY_TICKET);
         }//if (ManagingNanningbobTrades)
         if (abort) continue;
         
         ManageTrade=false;
         ScreenMessage = "Managing by: ";
         // Set up bid and ask so the program can use them to calculate jumping stops, be's etc
         bid = MarketInfo(OrderSymbol(), MODE_BID);           
         ask = MarketInfo(OrderSymbol(), MODE_ASK);
         point = MarketInfo(OrderSymbol(), MODE_POINT);
         digits = MarketInfo(OrderSymbol(), MODE_DIGITS);
         
         // Test whether this individual trade needs managing
         // MagicNumber
         if (ManageByMagicNumber && OrderMagicNumber()==MagicNumber)
         {   
            ManageTrade=true;
            ScreenMessage=StringConcatenate(ScreenMessage, "Magic Number=", MagicNumber,"; ");
         }   
         if (ManageByMagicNumber && !OrderMagicNumber()==MagicNumber)
         {   
            ScreenMessage=StringConcatenate(ScreenMessage, "Magic Number=", MagicNumber,"; ");
         }   
         
         // TradeComment
         if (ManageByTradeComment && OrderComment()==TradeComment)
         {   
            ManageTrade=true;
            ScreenMessage=StringConcatenate(ScreenMessage, "Trade Comment=",TradeComment,"; ");
         }   
         if (ManageByTradeComment && !OrderComment()==TradeComment)
         {   
            ScreenMessage=StringConcatenate(ScreenMessage, "Trade Comment=",TradeComment,"; ");
         }   
         
         // ManageByTickeNumber
         if (ManageByTickeNumber && OrderTicket()==TicketNumber)
         {   
            ManageTrade=true;
            ScreenMessage=StringConcatenate(ScreenMessage, "Ticket Number=", TicketNumber, "; ");
         }
         if (ManageByTickeNumber && !OrderTicket()==TicketNumber)
         {   
            ScreenMessage=StringConcatenate(ScreenMessage, "Ticket Number=", TicketNumber, "; ");
         }
                                            
         if (ManageThisPairOnly && OrderSymbol()==Symbol())
         {   
            ManageTrade=true;
            ScreenMessage="Managing this pair only";
         }
         
         if (ManageThisPairOnly && !OrderSymbol()==Symbol())
         {   
            ManageTrade=false;
            ScreenMessage="Managing this pair only";
         }
        //############## ADDED BY CACUS
          if (ManageSpecifiedPairs)
         {   
            for (int d=0;d<PairsQty();d++) 
            {
               if (OrderSymbol()==ManagePair[d])
               {
                  ManageTrade=true;
                  ScreenMessage="Managing selected pairs only";
               }
            }
         }
         //############## ADDED BY CACUS
         
         // Allow for combinations of pair management
         if (ManageThisPairOnly && OrderSymbol()==Symbol())
            {
               if (ManageByMagicNumber) ScreenMessage=StringConcatenate(ScreenMessage, " by MagicNumber = ", MagicNumber);
               if (ManageByMagicNumber && !OrderMagicNumber()==MagicNumber)            
               {   
                  ManageTrade=false;
               }               
            }
         
         if (ManageThisPairOnly && OrderSymbol()==Symbol())
            {
               if (ManageByTradeComment) ScreenMessage=StringConcatenate(ScreenMessage, " by TradeComment = ", TradeComment);
               if (ManageByTradeComment && !OrderComment()==TradeComment)            
               {   
                  ManageTrade=false;
               }               
            }
        
        if (ManageThisPairOnly && OrderSymbol()==Symbol())
            {
               if (ManageByTickeNumber) ScreenMessage=StringConcatenate(ScreenMessage, " by TicketNumber = ", TicketNumber);
               if (ManageByTickeNumber && !OrderTicket()==TicketNumber)            
               {   
                  ManageTrade=false;
               }               
            }
         
         // ManageAllTrades
         if (ManageAllTrades)
         {   
            ManageTrade=true;
            ScreenMessage="Managing all open trades";
         }   
         
         
         
         // Is this trade being managed by the ea?
         if (ManageTrade) ManageTrade(); // The subroutine that calls the other working subroutines
         
      } // Close if (OrderSymbol()==Symbol())
      
   
   } // Close For loop
   
   // Set up some user feedback
   if (HideStopLossEnabled)
   {
     ScreenMessage = StringConcatenate(ScreenMessage, NL, "Hidden stop loss is enabled. Hidden stop = ", HiddenStopLossPips, "pips");
   }//if (HideStopLossEnabled)
   
   if (HideTakeProfitEnabled)
   {
     ScreenMessage = StringConcatenate(ScreenMessage, NL, "Hidden take profit is enabled. Hidden stop = ", HiddenTakeProfitPips, "pips");
   }//if (HideStopLossEnabled)
   
   
   
   if(BreakEven)
   {
      ScreenMessage = StringConcatenate(ScreenMessage, NL, "Break even set to ", BreakEvenPips, ". BreakEvenProfit is set to ", BreakEvenProfit, " pips");
   }
   else
   {
      ScreenMessage = StringConcatenate(ScreenMessage, NL, "Break even disabled");
   }
   
   if(JumpingStop==true)
   {
      ScreenMessage = StringConcatenate(ScreenMessage, NL, "Jumping stop set to ", JumpingStopPips);
      if (JumpAfterBreakevenOnly) ScreenMessage = StringConcatenate(ScreenMessage, " after breakeven is achieved");
      if (HideJumpingStop)  ScreenMessage = StringConcatenate(ScreenMessage, " (HideJumpingStop = true: PipsAwayFromVisualJS = ", PipsAwayFromVisualJS, ")");
      if(AddBEP==true)
      {
         ScreenMessage = StringConcatenate(ScreenMessage, ", also adding BreakEvenProfit (", BreakEvenProfit, " pips)");      
      }
      if (PartCloseEnabled)
      {
         ScreenMessage = StringConcatenate(ScreenMessage, NL, "Trade part-close is enabled. Closing ",Close_Lots, ": Preserving ", Preserve_Lots);
      }
   }
   else
   {
      ScreenMessage = StringConcatenate(ScreenMessage, NL, "Jumping stop disabled");
   }
   
   if(TrailingStop==true)
   {
      ScreenMessage = StringConcatenate(ScreenMessage, NL, "Trailing stop on and set to ", TrailingStopPips);
      if (HideTrailingStop)  ScreenMessage = StringConcatenate(ScreenMessage, " (HideTrailingStop = true: PipsAwayFromVisualTS = ", PipsAwayFromVisualTS, ")");
   }
   else
   {
      ScreenMessage = StringConcatenate(ScreenMessage, NL, "Trailing stop disabled");
   }
   
   if (InstantTrailingStop)
   {
      ScreenMessage = StringConcatenate(ScreenMessage, NL, "Instant trailing stop on and set to ", InstantTrailingStopPips);
      if (StopInstantTrailAfterBreakEven) ScreenMessage = StringConcatenate(ScreenMessage,
            ": Will disable after breakeven");
   }
   else
   {
      ScreenMessage = StringConcatenate(ScreenMessage, NL, "Instant trailing stop disabled");
   }
//extern int     TrailAt50Percent=20;
//extern int     TrailAt80Percent=10;
   
   if (UseTigheningStop)
   {
      ScreenMessage = StringConcatenate(ScreenMessage, NL, "Using the tightening stop feature");
      ScreenMessage = StringConcatenate(ScreenMessage, NL, "          50% = ",TrailAt50Percent," pips: 80% = ", TrailAt80Percent, " pips");
      
   }//if (UseTigheningStop)
      
   if (AddMissingStopLoss)
   {
      ScreenMessage = StringConcatenate(ScreenMessage, NL, "Adding missing Stop Loss at ", MissingStopLossPips, " pips");      
   }
   
   if (AddMissingTakeProfit)
   {
      ScreenMessage = StringConcatenate(ScreenMessage, NL, "Adding missing Tske Profit at ", MissingTakeProfitPips, " pips");      
   }
   
   // Include global profit closure
   if (GlobalOrderClosureEnabled)   
   {
      ScreenMessage = StringConcatenate(ScreenMessage, NL, "Global order closure enabled");
      if (IncludePendingOrdersInClosure) ScreenMessage = StringConcatenate(ScreenMessage, ", including pending orders");
      if (ProfitInPips) 
      {      
         ScreenMessage = StringConcatenate(ScreenMessage, NL, "      ", Pips, " pips or points. Target profit is ", PipsProfit);
      }//if (ProfitInPips) 
      
   }
   else ScreenMessage = StringConcatenate(ScreenMessage, NL, "Global order closure disabled");
   
/*
extern int     HedgeTradeStopLoss=0;
extern int     HedgeTradeTakeProfit=0;
extern bool    CloseAtBreakEven=false;
*/
   
   // HedgeEnabled
   if (HedgeEnabled)
   {
      ScreenMessage = StringConcatenate(ScreenMessage, NL, "Hedge trade enabled at ", HedgeAtLossPips, " pips loss");
      ScreenMessage = StringConcatenate(ScreenMessage, NL, "       HedgeLotsPercent = ", HedgeLotsPercent,
                                       ": HedgingIncrementPips = ", HedgingIncrementPips, NL, "       HedgeTradeStopLoss = ",HedgeTradeStopLoss,
                                       ": HedgeTradeTakeProfit = ", HedgeTradeTakeProfit);
      if (CloseAtBreakEven) ScreenMessage = StringConcatenate(ScreenMessage, ": Closing hedged pair at breakeven");
   }
   else
   {
      ScreenMessage = StringConcatenate(ScreenMessage, NL, "Hedge trade not enabled");
   }
         
   // Account protection
   if (ShirtProtectionEnabled)
   {
      ScreenMessage = StringConcatenate(ScreenMessage, NL, "Shirt protection enabled at ", MaxLoss, " dollars upl");
   }
   else
   {
      ScreenMessage = StringConcatenate(ScreenMessage, NL, "Shirt protection not enabled");
   }
   
   
   Comment(ScreenMessage); // User feedback
   
   
   
} // end of MonitorTrades

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

void ShirtProtection()
{
   // Code for this routine is based on code in CloseTrades_After_Account_Loss_TooMuch.mq4
   // by Tradinator, so my appreciation to Tradinator.
   
   if (MaxLoss==0) return; // Idiotic user entry
   if (MaxLoss>0) 
   {
      Alert("ShirtProtection MaxLoss must be a negative number"); // In case user forgets to enter a negative figure
      return;
   }
   
   if (AccountProfit()<= MaxLoss)
   {
    for(int i=OrdersTotal()-1;i>=0;i--)
       {
       OrderSelect(i, SELECT_BY_POS);
       int ordertype   = OrderType();
               
       bool result = false;
              
       switch(ordertype)
       {
          //Close opened long positions
          case OP_BUY  : result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),10,CLR_NONE);
                         break;
               
          //Close opened short positions
          case OP_SELL : result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),10,CLR_NONE);
                         break;
                                        
          // Pending OrderSelect
          if (IncludePendingInClosure)
          {
            switch(ordertype)
            {
               case OP_BUYLIMIT : result = OrderDelete(OrderTicket());
                                  break;
               
               case OP_SELLLIMIT : result = OrderDelete(OrderTicket());
                                   break;
               case OP_BUYSTOP : result = OrderDelete(OrderTicket());
                                  break;
               
               case OP_SELLSTOP : result = OrderDelete(OrderTicket());
                                   break;
            }   
          }//if (IncludePendingInClosuree)
       }//switch(ordertype)
          
       if(result == false) // In case of problems like broker disconnection, trade context busy etc
          {
            Sleep(3000);
            i++;
          }  
       }//for(int i=OrdersTotal()-1;i>=0;i--)
      if (ShowAlerts) Alert("Disaster has happend. Your shirt protection loss point has been reached and all open orders have been closed.");
      Print ("All Open Trades Have Been Closed - Shirt protection loss point reached");
      return(0);
   }  
   
   
  return(0);
   

}//End of ShirtProtection()

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
            if (bid >= OrderOpenPrice () + (point*BreakEvenPips) && 
                OrderStopLoss()<OrderOpenPrice())
            {
               result = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+(BreakEvenProfit*point),OrderTakeProfit(),0,CLR_NONE);
               if (result && ShowAlerts==true) Alert("Breakeven set on ", OrderSymbol(), " ticket no ", OrderTicket());
               Print("Breakeven set on ", OrderSymbol(), " ticket no ", OrderTicket());
               if (!result)
               {
                  int err=GetLastError();
                  if (ShowAlerts==true) Alert("Setting of breakeven SL ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
                  Print("Setting of breakeven SL ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
               }//if !result && ShowAlerts)      
               if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
               {
                  bool PartCloseSuccess = PartCloseTradeFunction();
                  if (!PartCloseSuccess) SetAGlobalTicketVariable();
               }//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
            }
   	   }               			         
          
   if (OrderType()==OP_SELL)
         {
           if (ask <= OrderOpenPrice() - (point*BreakEvenPips) &&
              (OrderStopLoss()>OrderOpenPrice()|| OrderStopLoss()==0)) 
            {
               result = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-(BreakEvenProfit*point),OrderTakeProfit(),0,CLR_NONE);
               if (result && ShowAlerts==true) Alert("Breakeven set on ", OrderSymbol(), " ticket no ", OrderTicket());
               Print("Breakeven set on ", OrderSymbol(), " ticket no ", OrderTicket());
               if (!result && ShowAlerts)
               {
                  err=GetLastError();
                  if (ShowAlerts==true) Alert("Setting of breakeven SL ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
                  Print("Setting of breakeven SL ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
               }//if !result && ShowAlerts)      
              if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
               {
                  PartCloseSuccess = PartCloseTradeFunction();
                  if (!PartCloseSuccess) SetAGlobalTicketVariable();
               }//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
            }    
         }
      

} // End BreakevenStopLoss sub


bool PartCloseTradeFunction()
   {
      // Called when any attempt to part-close a long trade is needed.
      // Trade has already been selected 
      // Returns 'true' if succeeds, else false, after setting a global variable to tell
      // the basket monitoring function that a closure failed and needs to be attempted
      // again.
      
      double price;
      if (OrderType()==OP_BUY) price = bid;
      if (OrderType()==OP_SELL) price = ask;
      
            
      bool result=OrderClose(OrderTicket(), Close_Lots, price, 5, CLR_NONE);
      if (result)
      {
         if (ShowAlerts==true) Alert("Partial close of ", OrderSymbol(), " ticket no ", OrderTicket());
         return(true);
      }
      else
      {
         int err=GetLastError();
         if (ShowAlerts==true) Alert("Partial close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         Print("Partial close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         return(false);
      }                          
   
}// End bool PartCloseTradeFunction()
   
int GetNextAvailableVariableNumber()
   {
      // Called from the SetAGlobalTicketVariable() function.
      // Returns the first integer available.
      // The globla variable name consists of "GlobalVariableTicketNo" (stored in the 
      // string TicketName) and an integer.
            
      if (GlobalVariablesTotal()==0) return(1);
      
      for (int cc=1; cc > -1; cc++)
      {
         string ThisGlobalName = StringConcatenate(TicketName,DoubleToStr(cc,0));
         double v1 = GlobalVariableGet(ThisGlobalName);
         if(v1==0) return(cc);
         if (cc>100) return;
      }
      
   }//int GetNextAvailableVariableNumber()   
   
void SetAGlobalTicketVariable()
   {
      // Called whenever an attempt to part-close a trade fails.
      // This function finds the first available global variable name and sets up 
      // a gv with the ticket number of the offending trade. These gv's will consist of
      // the string TicketName ("GlobalVariableTicketNo") and an integer
      int cc = GetNextAvailableVariableNumber();
      string GlobalName=StringConcatenate(TicketName,DoubleToStr(cc,0));
      GlobalVariableSet(GlobalName, OrderTicket());
      GlobalVariablesExist=true;
      
   } // End void SetAGlobalTicketVariable();
   
bool CheckForHiddenStopLossHit(int type, int iPipsAboveVisual, double stop )
{
   //Reusable code that can be called by any of the stop loss manipulation routines except HiddenStopLoss().
   //Checks to see if the market has hit the hidden sl and attempts to close the trade if so. 
   //Returns true if trade closure is successful, else returns false
   
   //Check buy trade
   if (type == OP_BUY)
   {
      double sl = NormalizeDouble(stop + (iPipsAboveVisual * point), digits);
      if (bid <= sl)
      {
         bool result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
         if (result)
         {
            if (ShowAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket());      
         }//if (result)
         else
         {
            int err=GetLastError();
            if (ShowAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//else
      }//if (bid <= sl)  
   }//if (type = OP_BUY)
   
   //Check buy trade
   if (type == OP_SELL)
   {
      sl = NormalizeDouble(stop - (iPipsAboveVisual * point), digits);
      if (ask >= sl)
      {
         result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
         if (result)
         {
            if (ShowAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket());      
         }//if (result)
         else
         {
            err=GetLastError();
            if (ShowAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//else
      }//if (ask >= sl)  
   }//if (type = OP_SELL)
   
   return(result);


}//End bool CheckForHiddenStopLossHit(int type, int iPipsAboveVisual, double stop )

   
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
      if(OrderStopLoss()>OrderOpenPrice()) return(0);
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
         if (ask >= OrderOpenPrice() + (JumpingStopPips*point))
         {
            sl=OrderOpenPrice();
            if (AddBEP==true) sl=sl+(BreakEvenProfit*point); // If user wants to add a profit to the break even
            bool result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
            if (result)
            {
               if (ShowAlerts==true) Alert("Jumping stop set at breakeven ",sl, " ", OrderSymbol(), " ticket no ", OrderTicket());
               Print("Jumping stop set at breakeven: ", OrderSymbol(), ": SL ", sl, ": Ask ", ask);
               if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
               {
                  bool PartCloseSuccess = PartCloseTradeFunction();
                  if (!PartCloseSuccess) SetAGlobalTicketVariable();
               }//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
            }//if (result)
            if (!result)
            {
               int err=GetLastError();
               if (ShowAlerts) Alert(OrderSymbol(), " buy trade. Jumping stop function failed to set SL at breakeven, with error(",err,"): ",ErrorDescription(err));
               Print(OrderSymbol(), " buy trade. Jumping stop function failed to set SL at breakeven, with error(",err,"): ",ErrorDescription(err));
            }//if (!result)
             
            return(0);
         }//if (ask >= OrderOpenPrice() + (JumpingStopPips*point))
      } //close if (sl==0 || sl<OrderOpenPrice()

  
      // Increment sl by sl + JumpingStopPips.
      // This will happen when market price >= (sl + JumpingStopPips)
      if (bid>= sl + ((JumpingStopPips*2)*point) && sl>= OrderOpenPrice())      
      {
         sl=sl+(JumpingStopPips*point);
         result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
         if (result)
         {
            if (ShowAlerts==true) Alert("Jumping stop set at ",sl, " ", OrderSymbol(), " ticket no ", OrderTicket());
            Print("Jumping stop set: ", OrderSymbol(), ": SL ", sl, ": Ask ", ask);
            if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
            {
               PartCloseSuccess = PartCloseTradeFunction();
               if (!PartCloseSuccess) SetAGlobalTicketVariable();
            }//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
         }//if (result)
         if (!result)
         {
            err=GetLastError();
            if (ShowAlerts) Alert(OrderSymbol(), " buy trade. Jumping stop function failed with error(",err,"): ",ErrorDescription(err));
            Print(OrderSymbol(), " buy trade. Jumping stop function failed with error(",err,"): ",ErrorDescription(err));
         }//if (!result)
             
      }// if (bid>= sl + (JumpingStopPips*point) && sl>= OrderOpenPrice())      
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
         if (ask <= OrderOpenPrice() - (JumpingStopPips*point))
         {
            sl = OrderOpenPrice();
            if (AddBEP==true) sl=sl-(BreakEvenProfit*point); // If user wants to add a profit to the break even
            result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
            if (result)
            {
               if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
               {
                  PartCloseSuccess = PartCloseTradeFunction();
                  if (!PartCloseSuccess) SetAGlobalTicketVariable();
               }//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
            }//if (result)
            if (!result)
            {
               err=GetLastError();
               if (ShowAlerts) Alert(OrderSymbol(), " sell trade. Jumping stop function failed to set SL at breakeven, with error(",err,"): ",ErrorDescription(err));
               Print(OrderSymbol(), " sell trade. Jumping stop function failed to set SL at breakeven, with error(",err,"): ",ErrorDescription(err));
            }//if (!result)
             
            return(0);
         }//if (ask <= OrderOpenPrice() - (JumpingStopPips*point))
      } // if (sl==0 || sl>OrderOpenPrice()
   
      // Decrement sl by sl - JumpingStopPips.
      // This will happen when market price <= (sl - JumpingStopPips)
      if (bid<= sl - ((JumpingStopPips*2)*point) && sl<= OrderOpenPrice())      
      {
         sl=sl-(JumpingStopPips*point);
         result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
         if (result)
         {
            if (ShowAlerts==true) Alert("Jumping stop set at ",sl, " ", OrderSymbol(), " ticket no ", OrderTicket());
            Print("Jumping stop set: ", OrderSymbol(), ": SL ", sl, ": Ask ", ask);
            if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
            {
               PartCloseSuccess = PartCloseTradeFunction();
               if (!PartCloseSuccess) SetAGlobalTicketVariable();
            }//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
         }//if (result)          
         if (!result)
         {
            err=GetLastError();
            if (ShowAlerts) Alert(OrderSymbol(), " sell trade. Jumping stop function failed with error(",err,"): ",ErrorDescription(err));
            Print(OrderSymbol(), " sell trade. Jumping stop function failed with error(",err,"): ",ErrorDescription(err));
         }//if (!result)

      }// close if (bid>= sl + (JumpingStopPips*point) && sl>= OrderOpenPrice())         
   }//if (OrderType()==OP_SELL)

} //End of JumpingStopLoss sub

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
		   
		   //Subsequent to coding this, users have requested a candlestick trailing stop. The easiest way of adding this
		   //is to separate the two code snippets even though this leads to some duplication.
		   //Standard trail:
		   if (UseStandardTrail)
		   {
		       if (bid >= OrderOpenPrice() + (TrailingStopPips*point))
		       {
		           if (OrderStopLoss() == 0) sl = OrderOpenPrice();
		           if (bid > sl +  (TrailingStopPips*point))
		           {
		              sl= bid - (TrailingStopPips*point);
		              // Exit routine if user has chosen StopTrailAtPipsProfit and
		              // sl is past the profit point already
		              if (StopTrailAtPipsProfit && sl>= OrderOpenPrice() + (StopTrailPips*point)) return;
		              result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
                   if (result)
                   {
                      Print("Trailing stop updated: ", OrderSymbol(), ": SL ", sl, ": Ask ", ask);
                   }//if (result) 
                   else
                   {
                      int err=GetLastError();
                      Print(OrderSymbol(), " order modify failed with error(",err,"): ",ErrorDescription(err));
                   }//else
		           }//if (bid > sl +  (TrailingStopPips*point))
		       }//if (bid >= OrderOpenPrice() + (TrailingStopPips*point))
		   }//UseStandardTrail
		   
		   //Candlestick trail
		   if (UseCandlestickTrail)
		   {
		       double ClosePrice = NormalizeDouble(iClose(OrderSymbol(), CandlestickTrailTimeFrame, CandleShift), digits);
		       if (ClosePrice > OrderTakeProfit() )
		       {
		          //Min stop
		          double StopLevel = MarketInfo(OrderSymbol(), MODE_STOPLEVEL);
		          if (ClosePrice - OrderStopLoss() >= (StopLevel * point) )
		          {
		             sl = ClosePrice;
		             result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
                   if (result)
                   {
                      Print("Candlestick Trailing stop updated: ", OrderSymbol(), ": SL ", sl, ": Ask ", ask);
                   }//if (result) 
                   else
                   {
                      err=GetLastError();
                      Print(OrderSymbol(), " order modify failed with error(",err,"): ",ErrorDescription(err));
                   }//else
		          }//if (ClosePrice - OrderStopLoss() >= (StopLevel * point) )		          
		       }//if (ClosePrice > OrderTakeProfit() )
		   }//if (UseCandlestickTrail)
		   
		   
      }//if (OrderType()==OP_BUY) 

      if (OrderType()==OP_SELL) 
      {
		   
		   //Subsequent to coding this, users have requested a candlestick trailing stop. The easiest way of adding this
		   //is to separate the two code snippets even though this leads to some duplication.
		   //Standard trail:
		   if (UseStandardTrail)
		   {
		   
		       if (ask <= OrderOpenPrice() - (TrailingStopPips*point))
		       {
                 if (HideTrailingStop)
                 {
                    TradeClosed = CheckForHiddenStopLossHit(OP_SELL, PipsAwayFromVisualTS, OrderStopLoss() );
                    if (TradeClosed) return;//Trade has closed, so nothing else to do
                 }//if (HideJumpingStop)
		   
		           if (ask < sl -  (TrailingStopPips*point))
		           {
    		             if (OrderStopLoss() == 0) sl = OrderOpenPrice();
	                   sl= ask + (TrailingStopPips*point);
  	                   // Exit routine if user has chosen StopTrailAtPipsProfit and
		                // sl is past the profit point already
		                if (StopTrailAtPipsProfit && sl<= OrderOpenPrice() - (StopTrailPips*point)) return;
		                result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
                      if (result)
                      {
                         Print("Trailing stop updated: ", OrderSymbol(), ": SL ", sl, ": Bid ", bid);
                      }//if (result)
                      else
                      {
                         err=GetLastError();
                         if (PrintToJournal) Print(OrderSymbol(), " order modify failed with error(",err,"): ",ErrorDescription(err));
                      }//else    
		           }//if (ask < sl -  (TrailingStopPips*point))
		       }//if (ask <= OrderOpenPrice() - (TrailingStopPips*point))		   
		   }//if (UseStandardTrail)

		   //Candlestick trail
		   if (UseCandlestickTrail)
		   {
		       ClosePrice = NormalizeDouble(iClose(OrderSymbol(), CandlestickTrailTimeFrame, CandleShift), digits);
		       if (OrderTakeProfit() > ClosePrice)
		       {
		          //Min stop
		          StopLevel = MarketInfo(OrderSymbol(), MODE_STOPLEVEL);
		          if (OrderStopLoss() - ClosePrice >= (StopLevel * point) )
		          {
		             sl = ClosePrice;
		             result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
                   if (result)
                   {
                      Print("Candlestick Trailing stop updated: ", OrderSymbol(), ": SL ", sl, ": Ask ", ask);
                   }//if (result) 
                   else
                   {
                      err=GetLastError();
                      Print(OrderSymbol(), " order modify failed with error(",err,"): ",ErrorDescription(err));
                   }//else
		          }//if (OrderStopLoss() - ClosePrice >= (StopLevel * point) )
		       }//if (OrderTakeProfit() > ClosePrice)
		   }//if (UseCandlestickTrail)
		   
		   
		   
      }//if (OrderType()==OP_SELL) 

      //TrailingStopPips = TrailingStopPipsStore;
      
} // End of TrailingStopLoss sub
   
void InstantTrailingStopLoss()
/* This is the same as TrailingStopLoss, except that it moves the sl as soon as
 the market moves ion favour of the trade. 
 It will set an initial sl of market price +- InstantTrailingStopPips, depending on the type of trade,
 then move it every time the market moves in favour of the trade. It will therefore override
 any user set sl on the trade.
 Market price +- InstantTrailingStopPips will result in breakeven, and move into profit after that.
*/ 
{
   bool result;
   double sl=OrderStopLoss(); //Stop loss
   double BuyStop=0, SellStop=0;
   
   if (OrderType()==OP_BUY) 
      {
		   if (bid >= sl+((InstantTrailingStopPips*point) + (FiveDigitIncrement * point))) // Has to overcome the spread first
		   {
	         sl= bid - NormalizeDouble(((InstantTrailingStopPips*point) + (FiveDigitIncrement * point)),digits);
	         if (sl <= OrderStopLoss()) return(0);
	         if (StopInstantTrailAfterBreakEven && sl>OrderOpenPrice()) return(0); // cancel instant trail after breakeven
	         // Exit routine if user has chosen StopTrailAtPipsProfit and
            // sl is past the profit point already
            if (StopInstantTrailAtPipsProfit && sl>= OrderOpenPrice() + (StopInstantTrailPips*point)) return;
		          
	         result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
            if (result)
            {
               Print("Instant trailing stop updated: ", OrderSymbol(), ": SL ", sl, ": Ask ", ask);
            } 
		       return;
		    }//if (bid >= sl+((InstantTrailingStopPips*point) + (FiveDigitIncrement * point))) // Has to overcome the spread first
      }//if (OrderType()==OP_BUY)

      if (OrderType()==OP_SELL) 
      {
	       if ((ask <= sl - ((InstantTrailingStopPips*point) - (FiveDigitIncrement * point))) || sl==0)
	       {
	            sl= ask + NormalizeDouble(((InstantTrailingStopPips*point)) - (FiveDigitIncrement * point),digits);
   	         if (StopInstantTrailAfterBreakEven && sl<OrderOpenPrice()) return(0); // cancel instant trail after breakeven
               // Exit routine if user has chosen StopTrailAtPipsProfit and
	            // sl is past the profit point already
	            if (StopInstantTrailAtPipsProfit && sl<= OrderOpenPrice() - (StopInstantTrailPips*point)) return;
	            result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
               if (result)
               {
                  if (PrintToJournal) Print("Trailing stop updated: ", OrderSymbol(), ": SL ", sl, ": Bid ", bid);
               } 
               return;   
	       }//if ((ask <= sl - ((InstantTrailingStopPips*point) - (FiveDigitIncrement * point))) || sl==0)		   
      }//if (OrderType()==OP_SELL) 


} // End of InstantTrailingStopLoss() sub
   
void GlobalOrderClosure()
{
   bool CloseOrders=false;
   double ProfitPercentage=0;
   
   // First calculate whether the upl is >= the point at which the position is to close

   // Profit in dollars enabled
   if (ProfitInDollars)
   {
      if(AccountProfit()>=DollarProfit) CloseOrders=true;
   }
   
   // Profit as percentage of account balance enabled
   if (ProfitAsPercentageOfBalance)
   {
      ProfitPercentage=AccountBalance() * (PercentageProfit/100);
      if (AccountProfit()>= ProfitPercentage) CloseOrders=true;
   }


   //Profit in pips
   if (ProfitInPips)
   {
      Pips = CalculatePipsProfit();
      //Dynamic pips target
      if (UseDynamicPipsProfit)
      {
         PipsProfit = OrdersTotal() * PipsPerTrade;         
      }//if (UseDynamicPipsProfit)     
      
      if (Pips >= PipsProfit) CloseOrders=true;
   }//if (ProfitInPips)
   
   
   // Abort routine if profit has not hit the required level
   if (!CloseOrders) return(0);
   
   // Got this far, so orders are to be closed.
   // Code lifted from CloseAll-PL, so thanks to whoever wrote the ea. Ok, so I could
   // have written my own, buy why re-invent the wheel?
   
   int _total=OrdersTotal(); // number of lots or trades  ????
   int _ordertype;// order type   
   if (_total==0) {return;}  // if total==0
   int _ticket; // ticket number
   double _priceClose;// price to close orders;
   for(int _i=_total-1;_i>=0;_i--)
         {  //# for loop
         if (OrderSelect(_i,SELECT_BY_POS))
            { //# if 
            _ordertype=OrderType();
            _ticket=OrderTicket();
            switch(_ordertype)
               {  //# switch
          case OP_BUYLIMIT:
            if(IncludePendingOrdersInClosure) OrderDelete(OrderTicket());
          case OP_BUYSTOP:
            if(IncludePendingOrdersInClosure) OrderDelete(OrderTicket());
          case OP_BUY:
                  // close buy                
                  _priceClose=MarketInfo(OrderSymbol(),MODE_BID);
                  Print("Close on ",_i," position order with ticket ¹",_ticket);
                  OrderClose(_ticket,OrderLots(),_priceClose,10,Red);
                  break;
          case OP_SELLLIMIT:
            if(IncludePendingOrdersInClosure) OrderDelete(OrderTicket());
          case OP_SELLSTOP:
            if(IncludePendingOrdersInClosure) OrderDelete(OrderTicket());
          case OP_SELL:
                  // close sell
                  _priceClose=MarketInfo(OrderSymbol(),MODE_ASK);
                  Print("Close on ",_i," position order with ticket ¹",_ticket);
                  OrderClose(_ticket,OrderLots(),_priceClose,10,Red);
                  break;
               default:
                  // values from  1 to 5, deleting pending orders
   //               if (PrintToJournal) Print("Delete on ",_i," position order with ticket ¹",_ticket);
   //               OrderDelete(_ticket);  
                  break;
               }    //# switch
         }  // # if 
   }  // # for loop

   // User feedback
   if (ShowAlerts) Alert("Global profit hit your target, so all open trades should have been closed");
   
} //End of GlobalOrderClosure()

int CalculatePipsProfit()
{
   //Returns the pip value of the current position
   if (OrdersTotal() == 0) return(0);
   
   int multiplier, divisor;
   double pips;
   int pipstotal;
   
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS, MODE_TRADES) ) continue;
      if (OrderCloseTime() > 0) continue;
      if (MarketInfo(OrderSymbol(), MODE_DIGITS)== 2) {multiplier = 100; divisor = 1;}
      if (MarketInfo(OrderSymbol(), MODE_DIGITS)== 3) {multiplier = 1000; divisor = 10;}
      if (MarketInfo(OrderSymbol(), MODE_DIGITS)== 4) {multiplier = 10000; divisor = 1;}
      if (MarketInfo(OrderSymbol(), MODE_DIGITS)== 5) {multiplier = 100000; divisor = 10;}
      if (MarketInfo(OrderSymbol(), MODE_DIGITS)== 6) {multiplier = 1000000; divisor = 100;}//Not tested this one
      
      
      
      if (OrderType() == OP_BUY) pips = (MarketInfo(OrderSymbol(), MODE_BID) - OrderOpenPrice()) * multiplier;
      if (OrderType() == OP_SELL) pips = (OrderOpenPrice() - MarketInfo(OrderSymbol(), MODE_ASK)) * multiplier;
      
      if (OrderType() == OP_BUY || OrderType() == OP_SELL) pipstotal+= pips;      
   }//for (int cc = 0; cc < OrdersHistoryTotal(); cc++)
   
   //pipstotal/= divisor;
   return(pipstotal);
   //ScreenMessage = StringConcatenate("      ", Pips, " pips");
   //Comment(ScreenMessage);

}//int CalculatePipsProfit()


/*bool ExtractPartCloseVariables()
{
   
   This routine extracts the targets at which PartCloseOrder closes part of a position.
   Also tells PartCloseOrder whether the pair is enabled for part-closure.
   Written as a separate function because it is huge, so avoids clutter in PartCloseOrder
   
   
   bool PairEnabled=false;
   
   if (OrderSymbol()=="EURUSD" || OrderSymbol()=="EURUSDm") 
   {
      TargetAsPrice=EUTargetPrice;
      TargetAsPips=EUTargetPips;
      if(EU) PairEnabled=true;
   }
      
   if (OrderSymbol()=="GBPUSD" || OrderSymbol()=="GBPUSDm") 
   {
      TargetAsPrice=GUTargetPrice;
      TargetAsPips=GUTargetPips;
      if(GU) PairEnabled=true;
   }
      
   if (OrderSymbol()=="USDJPY" || OrderSymbol()=="USDJPYm") 
   {
      TargetAsPrice=UJTargetPrice;
      TargetAsPips=UJTargetPips;
      if(UJ) PairEnabled=true;
   }
      
   if (OrderSymbol()=="USDCHF" || OrderSymbol()=="USDCHFm") 
   {
      TargetAsPrice=UCTargetPrice;
      TargetAsPips=UCTargetPips;
      if(UC) PairEnabled=true;
   }
      
   if (OrderSymbol()=="USDCAD" || OrderSymbol()=="USDCADm") 
   {
      TargetAsPrice=UCadTargetPrice;
      TargetAsPips=UCadTargetPips;
      if(UCad) PairEnabled=true;
   }
      
   if (OrderSymbol()=="AUDUSD" || OrderSymbol()=="AUDUSDm") 
   {
      TargetAsPrice=AUTargetPrice;
      TargetAsPips=AUTargetPips;
      if(AU) PairEnabled=true;
   }
      
   if (OrderSymbol()=="NZDUSD" || OrderSymbol()=="NZDUSDm") 
   {
      TargetAsPrice=NUTargetPrice;
      TargetAsPips=NUTargetPips;
      if(NU) PairEnabled=true;
   }
      
   if (OrderSymbol()=="EURGBP" || OrderSymbol()=="EURGBPm") 
   {
      TargetAsPrice=EGTargetPrice;
      TargetAsPips=EGTargetPips;
      if(EG) PairEnabled=true;
   }
      
   if (OrderSymbol()=="EURJPY" || OrderSymbol()=="EURJPYm") 
   {
      TargetAsPrice=EJTargetPrice;
      TargetAsPips=EJTargetPips;
      if(EJ) PairEnabled=true;
   }
      
   if (OrderSymbol()=="EURCHF" || OrderSymbol()=="EURCHFm") 
   {
      TargetAsPrice=ECTargetPrice;
      TargetAsPips=ECTargetPips;
      if(EC) PairEnabled=true;
   }
      
   if (OrderSymbol()=="GBPJPY" || OrderSymbol()=="GBPJPYm") 
   {
      TargetAsPrice=GJTargetPrice;
      TargetAsPips=GJTargetPips;
      if(GJ) PairEnabled=true;
   }
      
   if (OrderSymbol()=="GBPCHF" || OrderSymbol()=="GBPCHFm") 
   {
      TargetAsPrice=GCTargetPrice;
      TargetAsPips=GCTargetPips;
      if(GC) PairEnabled=true;
   }
      
   if (OrderSymbol()=="AUDJPY" || OrderSymbol()=="AUDJPYm") 
   {
      TargetAsPrice=AJTargetPrice;
      TargetAsPips=AJTargetPips;
      if(AJ) PairEnabled=true;
   }
      
   if (OrderSymbol()=="CHFJPY" || OrderSymbol()=="CHFJPYm") 
   {
      TargetAsPrice=CJTargetPrice;
      TargetAsPips=CJTargetPips;
      if(CJ) PairEnabled=true;
   }
      
   if (OrderSymbol()=="EURCAD" || OrderSymbol()=="EURCADm") 
   {
      TargetAsPrice=ECadTargetPrice;
      TargetAsPips=ECadTargetPips;
      if(ECad) PairEnabled=true;
   }
      
   if (OrderSymbol()=="EURAUD" || OrderSymbol()=="EURAUDm") 
   {
      TargetAsPrice=EATargetPrice;
      TargetAsPips=EATargetPips;
      if(EA) PairEnabled=true;
   }

   if (OrderSymbol()=="AUDCAD" || OrderSymbol()=="AUDCADm") 
   {
      TargetAsPrice=ACTargetPrice;
      TargetAsPips=ACTargetPips;
      if(AC) PairEnabled=true;
   }
      
   if (OrderSymbol()=="AUDNZD" || OrderSymbol()=="AUDNZDm") 
   {
      TargetAsPrice=ANTargetPrice;
      TargetAsPips=ANTargetPips;
      if(AN) PairEnabled=true;
   }
      
   if (OrderSymbol()=="NZDJPY" || OrderSymbol()=="NZDJPYm") 
   {
      TargetAsPrice=NJTargetPrice;
      TargetAsPips=NJTargetPips;
      if(NJ) PairEnabled=true;
   }
      

   return (PairEnabled);

} // End ExtractPartCloseVariables 
*/


/*void PartCloseOrder()
{
            
///////////////////////////////////////////////////////////////////////////////////////////
// Previous code. Keot just in case
   int index=StringFind(OrderComment(), "split from");
   if (index>-1) return(0); // Order already part-closed
   // Extract the external part-close variables for this pairing.Put this into 
   //a separate routine to avoid clutter here. Ascertain if this pair is 
   // enabled for partial closure. 
   TargetAsPrice=0;
   TargetAsPips=0;
   bool PairEnabled=ExtractPartCloseVariables();   
   if (!PairEnabled) return(0); // Not wanted on this pair
   if(TargetAsPrice==0 && TargetAsPips==0) return(0); // User entry error

   // Got this far, so pair is enabled, trade is not already split and no user errors, so continue
   int ticket;
   double ProfitTarget;
   double LotsToClose=OrderLots()/2;
   if(!TargetAsPrice==0) ProfitTarget=TargetAsPrice;
   
            
   if (OrderType()==OP_BUY)
   {
      if(TargetAsPips>0) ProfitTarget=NormalizeDouble(OrderOpenPrice()+(TargetAsPips*point),digits);
      if (bid>=ProfitTarget)
      {         
         ticket=OrderClose(OrderTicket(), LotsToClose,bid,3,CLR_NONE);
         if (ticket>0)
         {
            if(ShowAlerts) Alert("Partial closure on ", OrderSymbol(), ": ticket no ",OrderTicket());
         } 

      }
   }
   
   if (OrderType()==OP_SELL)
   {
      if(TargetAsPips>0) ProfitTarget=NormalizeDouble(OrderOpenPrice()-(TargetAsPips*point),digits);
      if (ask<=ProfitTarget)
      {         
         ticket=OrderClose(OrderTicket(), LotsToClose,ask,3,CLR_NONE);
         if (ticket>0)
         {
            if(ShowAlerts) Alert("Partial closure on ", OrderSymbol(), ": ticket no ",OrderTicket());
         
         } 

      }
         
   }

//////////////////////////////////////////////////////////////////////////////////////////////////////
   
} // End of PartCloseOrder()*/

bool CheckForExistingHedge()
{
   int index;
   double ticketno=OrderTicket();
   string StringTicketNo=DoubleToStr(OrderTicket(),0);
   for (int cc=OrdersTotal() - 1; cc >+ 0; cc--)
   {
      OrderSelect(cc, SELECT_BY_POS);
      index=StringFind(OrderComment(),StringTicketNo);
      if (index>-1) return(true);
   }

   return(false);
   
} //End CheckForExistingHedge

bool AreHedgeAndOriginalAtBreakeven(int TempTicket)
{
   // The OrderSelect trade is a hedge, so extract the ticket number it is hedging
   string sComment=StringSubstr(OrderComment(),6);
   int TicketNo=StrToInteger(sComment);
   // Calculate to profit of the scalp and hedge trades
   double Profit=(OrderProfit() + OrderSwap());
   OrderSelect(TicketNo,SELECT_BY_TICKET);
   Profit = Profit + (OrderProfit() + OrderSwap());
   // Delete the trade if be has been reached
   if (Profit>=0 && CloseAtBreakEven)
   {
      int ordertype=OrderType();
      int result; 
      switch(ordertype)
      {
      //Close opened long positions
      case OP_BUY  : result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),10,CLR_NONE);                     
       
      //Close opened short positions
      case OP_SELL : result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),10,CLR_NONE);
                 
      }
      return(true);
   }
   else return(false);
   
}//AreHedgeAndOriginalAtBreakeven()

void HedgeTrade()
{
   if(HedgeAtLossPips==0) return(0); //Silly user choice
   
   // Check that order is not already hedged
   int TempTicket = OrderTicket(); // Temporary store for selected order ticket no
   int index; // If OrderComment includes "Hedge ";
   int HedgeTicket; // For ticket number of hedge trade
   bool BreakevenAchieved=false;
   
   
   
   // Is this trade a hedge trade?
   index = StringFind(OrderComment(), "Hedge ");
   if (index > -1) 
   {
      BreakevenAchieved=AreHedgeAndOriginalAtBreakeven(TempTicket); // The called function closes the original order if be is achieved
      if (BreakevenAchieved && CloseAtBreakEven)
      {
         OrderSelect(TempTicket, SELECT_BY_TICKET); //Re-select the current order               
         int ordertype=OrderType();
         int result; 
         switch(ordertype)
         {
            //Close opened long positions
            case OP_BUY  : result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),10,CLR_NONE);
                           break;

            //Close opened short positions
            case OP_SELL : result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),10,CLR_NONE);
        
        }
        return; // Let's do any more processing on the next tick. This is getting complicated
     }// close if (BreakevenAchieved && CloseAtBreakEven)
     else
     {   
         
         OrderSelect(TempTicket, SELECT_BY_TICKET); //Re-select the current order
         if (!HedgingTheHedgeIsAllowed) return;//Trade is already a hedge, so no further action needed if hedging hedges is not allowed
     }   
      
   }// Close if (index > -1) 
   
   bool HedgeOpen = CheckForExistingHedge();
   //If there is no hedge open, the trade is not itself a hedge trade, and is in upl loss, and has no tp, 
   //then it will need one.
   //If it has already been hedged and the hedge has itself closed
         
   if (!HedgeOpen && index == -1 && OrderProfit() < 0 && OrderTakeProfit() == 0 && OrdersHistoryTotal() > 0)
   {
      //Cycle through the history trades to find a closed hedge trade for this ticket
      for (int cc = OrdersHistoryTotal() - 1; cc >= 0; cc--)
      {
         string tick = DoubleToStr(TempTicket,0);
         OrderSelect(cc, SELECT_BY_POS, MODE_HISTORY);
         index = StringFind(OrderComment(), tick);
         if (index > -1) //A closed hedge trade
         {
            OrderSelect(TempTicket, SELECT_BY_TICKET);//Re-select the current order
            if (OrderTakeProfit() == 0)
            {
               result = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), OrderOpenPrice(), OrderExpiration(), CLR_NONE);
               if (!result)
               {
                  int err=GetLastError();
                  Alert(OrderTicket(), " TP move to BE failed with error(",err,"): ",ErrorDescription(err));
                  if (PrintToJournal) Print(OrderTicket(), " TP move to BE failed with error(",err,"): ",ErrorDescription(err));
               }//if (!result)
            }//if (OrderTakeProfit() == 0)
            break;
         }//if (index > -1) 
      }//for (cc = OrdersHistoryTotal() - 1; cc >= 0; cc--)
      
   }//if (!HedgeOpen && index == -1 && OrderProfit() < 0 && OrderTakeProfit() == 0 && OrdersHistoryTotal() > 0)
   OrderSelect(TempTicket, SELECT_BY_TICKET);//Re-select the current order
   
   
   // Does this order need hedging?
   string tn = DoubleToStr(TempTicket,0);
   double HedgePrice; 
   double NextHedge = GlobalVariableGet(tn);
   if (OrderType()==OP_BUY)
   {
      HedgePrice=NormalizeDouble(OrderOpenPrice()-(NextHedge * point),digits);
      if (ask >= HedgePrice) return; // Trade not failing sufficiently to need hedging
   }   

   if (OrderType()==OP_SELL)
   {
      HedgePrice=NormalizeDouble(OrderOpenPrice()+(NextHedge * point),digits);
      if (bid <= HedgePrice) return; // Trade not failing sufficiently to need hedging
    }
      
   // Got this far, so the trade needs a hedge.
   // Is it already hedged? CheckForExistingHedge returns true if so, false if not
   if (HedgeOpen)
   {
      OrderSelect(TempTicket, SELECT_BY_TICKET); //Re-select the current order
      return;
   }
   OrderSelect(TempTicket, SELECT_BY_TICKET);//Re-select the current order


   // Got this far, so send the hedge order.
   // Check trend direction first
   TrendUp=true;
   TrendDown=true;
   DetermineTrendDirection(OrderSymbol());
   bool AllowTrade=true;
   double takeprofit=0;
   double stoploss=0;
   int ticket;
   double Lots=OrderLots();
   
   //Make sure that there are not too many decimal plases in the result of the calculation
   double LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   int decimals;
   if (LotStep >0 && LotStep < 0.1) decimals = 2;//0.01
   if (LotStep >0.09 && LotStep < 1) decimals = 1;//0.1
   if (LotStep >0.9) decimals = 0;//1
//HedgeTheHedgeLotsPercent   
   if(HedgeEnabled && HedgeLotsPercent>0) Lots=NormalizeDouble(Lots * (HedgeLotsPercent / 100), decimals);
   // Is this trade a hedge trade re-check? Lots may need adjusting if so
   index = StringFind(OrderComment(), "Hedge ");
   if (index > -1) Lots=NormalizeDouble(OrderLots() * (HedgeTheHedgeLotsPercent / 100), decimals);
   
   int error;
   
   if (OrderType()==OP_BUY)
   {
      if(!HedgeTradeTakeProfit==0) takeprofit=NormalizeDouble(bid-(HedgeTradeTakeProfit*point),digits);
      
      if(!HedgeTradeStopLoss==0) stoploss=NormalizeDouble(ask+(HedgeTradeStopLoss*point),digits); 
      
      if(UseEnvelopeTrendFilter || UseAdxTrendFilter || UseCandleDirection)
      {
         if (!TrendUp && !TrendDown) return;// No trend, so no hedge   
         if(!TrendDown) AllowTrade=false;
      }
      if (AllowTrade)
      {
         ticket=OrderSend(OrderSymbol(),OP_SELL,Lots,MarketInfo(OrderSymbol(),MODE_BID),0,stoploss,takeprofit,"Hedge " + OrderTicket(),MagicNumber,0,CLR_NONE);
         if (ticket>0)
         {
            if(ShowAlerts) Alert("Sell hedge trade set for ", OrderSymbol(), " buy");
            NextHedge+= (HedgingIncrementPips);
            GlobalVariableSet(tn, NextHedge);
            //Reselect the original trade and set the sl to 0
            OrderSelect(TempTicket, SELECT_BY_TICKET);
            if (OrderStopLoss() != 0 || OrderTakeProfit() != 0)
            {
               result = OrderModify(OrderTicket(), OrderOpenPrice(), 0, 0, OrderExpiration(), CLR_NONE);
               if (!result)
               {
                  err=GetLastError();
                  Alert(OrderTicket(), " SL move to 0 failed with error(",err,"): ",ErrorDescription(err));
                  Print(OrderTicket(), " SL move to 0 failed with error(",err,"): ",ErrorDescription(err));
               }//if (!result)
            }//if (OrderStopLoss() != 0 || OrderTakeProfit() != 0)
            
         }//if (ticket>0) 
         else
         {
            error=GetLastError();
            Print("Error = ",ErrorDescription(error));
            return;
         }
      }      
   }

if (OrderType()==OP_SELL)
   {
      if(!HedgeTradeTakeProfit==0) takeprofit=NormalizeDouble(ask+(HedgeTradeTakeProfit*point),digits);
      
      if(!HedgeTradeStopLoss==0) stoploss=NormalizeDouble(bid-(HedgeTradeStopLoss*point),digits); 
      
      if(UseEnvelopeTrendFilter || UseAdxTrendFilter || UseCandleDirection)
      {
         if (!TrendUp && !TrendDown) return;// No trend, so no hedge   
         if(!TrendUp) AllowTrade=false;
      }
      if (AllowTrade)
      {      
         ticket=OrderSend(OrderSymbol(),OP_BUY,Lots,MarketInfo(OrderSymbol(),MODE_ASK),0,stoploss,takeprofit,"Hedge " + OrderTicket(),MagicNumber,0,CLR_NONE);
         if (ticket>0)
         {
            if(ShowAlerts) Alert("Buy hedge trade set for ", OrderSymbol(), " sell");
            NextHedge+= (HedgingIncrementPips);
            GlobalVariableSet(tn, NextHedge);
            //Reselect the original trade and set the sl to 0
            OrderSelect(TempTicket, SELECT_BY_TICKET);
            if (OrderStopLoss() != 0 || OrderTakeProfit() != 0)
            {
               result = OrderModify(OrderTicket(), OrderOpenPrice(), 0, 0, OrderExpiration(), CLR_NONE);
               if (!result)
               {
                  err=GetLastError();
                  Alert(OrderTicket(), " SL move to 0 failed with error(",err,"): ",ErrorDescription(err));
                  Print(OrderTicket(), " SL move to 0 failed with error(",err,"): ",ErrorDescription(err));
               }//if (!result)
            }//if (OrderStopLoss() != 0 || OrderTakeProfit() != 0)
         }//if (ticket>0) 
         else
         {
            error=GetLastError();
            Print("Error = ",ErrorDescription(error));
            return;
         }
      }
   }

} // End of HedgeTrade()

void DetermineTrendDirection(string symbol)
   {
      // Envelope trend filter
      if(UseEnvelopeTrendFilter)
      {
         if (LookBackBars==0) return;
         int BarCounter=iBars(OrderSymbol(), PERIOD_H1);
         double HigherBand, LowerBand, ClosePrice;
         string message;
         int shift=1;
         for (int i=BarCounter; i>BarCounter-LookBackBars; i--)
         {
            HigherBand=iEnvelopes(OrderSymbol(), 0, 64, MODE_LWMA,0,PRICE_CLOSE,0.05, MODE_UPPER,shift);
            LowerBand=iEnvelopes(OrderSymbol(), 0, 64, MODE_LWMA,0,PRICE_CLOSE,0.05, MODE_LOWER,shift);
            ClosePrice=iClose(OrderSymbol(), 0,shift);
            if (ClosePrice < HigherBand) TrendUp=false;
            if (ClosePrice > LowerBand) TrendDown=false;
            if (!TrendDown && !TrendUp) return; // No discernible trend, so nothing to do
            shift++;
         }//for
      }//if   
   
      //Trend determination using ADX
      if (UseAdxTrendFilter)
      {
         double AdxMain = iADX(OrderSymbol(),0,AdxPeriod,PRICE_CLOSE,MODE_MAIN,0);
         double PlusDI = iADX(OrderSymbol(),0,AdxPeriod,PRICE_CLOSE,MODE_PLUSDI,0);
         double MinusDI= iADX(OrderSymbol(),0,AdxPeriod,PRICE_CLOSE,MODE_MINUSDI,0);
      
         // Up trend
         if (PlusDI > MinusDI) TrendDown=false;
         // Down trend
         if (MinusDI > PlusDI) TrendUp=false;
         // Does ADX main line confirm the trend
         if (AdxMain < 20)
         {
            TrendDown=false;
            TrendUp=false;
         }
     }//if (UseAdxTrendFilter)
      
     //Trend determination using candlestick direction
     if (UseCandleDirection)
     {
         for (int cc = 1; cc < LookBackCandleHours +1; cc++)
         {
            //Check long trend
            if (iClose(symbol, PERIOD_H1, cc) < iClose(symbol, PERIOD_H1, cc + 1)) TrendUp = false;
            if (iClose(symbol, PERIOD_H1, cc) > iClose(symbol, PERIOD_H1, cc + 1)) TrendDown = false;         
         }//for (int cc = 1: cc < LookBackCandleHours; cc++)
         
     }//if (UseCandleDirection)
      
   } // End of void DetermineTrendDirection(string symbol)

void TightenStopLoss()
{
   // Moves the JumpingStopPips and TrailingStopPips at 50% and 80% of tp

   
   //Calculate the number of pips in the trade tp
   int Multiplier;
   if (digits == 5) Multiplier = 100000; //5 digits
   else if (digits == 3) Multiplier = 1000; //3 digits (for Yen based pairs)   
   else if (digits == 2) Multiplier = 100; //2 digits (for Yen based pairs)   
   else Multiplier = 10000; //4 digits
   int tp = (OrderTakeProfit()*Multiplier);
   int op = (OrderOpenPrice()*Multiplier);
   

   if (OrderType() == OP_BUY) int Tpips = tp - op;
   if (OrderType() == OP_SELL) Tpips = op - tp;

   
   //Tighten JumpingStopPips and TrailingStopPips if necessary
   if (OrderType() == OP_BUY)
   {
      double Target1 = NormalizeDouble(OrderOpenPrice() + ((Tpips * 50/100) * point),digits);
      double Target2 = NormalizeDouble(OrderOpenPrice() + ((Tpips * 80/100) * point),digits);
      if (bid >= Target1 && JumpingStopPips > TrailAt50Percent) JumpingStopPips = TrailAt50Percent;
      if (bid >= Target2 && JumpingStopPips > TrailAt80Percent) JumpingStopPips = TrailAt80Percent;
      if (bid >= Target1 && TrailingStopPips > TrailAt50Percent) TrailingStopPips = TrailAt50Percent;
      if (bid >= Target2 && TrailingStopPips > TrailAt80Percent) TrailingStopPips = TrailAt80Percent;   
   }//if (OrderType() == OP_BUY)
   
   if (OrderType() == OP_SELL)
   {
      Target1 = NormalizeDouble(OrderOpenPrice() - ((Tpips * 50/100) * point),digits);
      Target2 = NormalizeDouble(OrderOpenPrice() - ((Tpips * 80/100) * point),digits);
      if (ask <= Target1 && JumpingStopPips > TrailAt50Percent) JumpingStopPips = TrailAt50Percent;
      if (ask <= Target2 && JumpingStopPips > TrailAt80Percent) JumpingStopPips = TrailAt80Percent;
      if (ask <= Target1 && TrailingStopPips > TrailAt50Percent) TrailingStopPips = TrailAt50Percent;
      if (ask <= Target2 && TrailingStopPips > TrailAt80Percent) TrailingStopPips = TrailAt80Percent;   
   }//if (OrderType() == OP_SELL)
 
  
}//End void TightenStopLoss()



void InsertStopLoss()
{
   if (OrderType() != OP_BUY && OrderType() != OP_SELL) return;
   
   if (OrderStopLoss() != 0 || (MissingStopLossPips == 0 && !UseSlAtr) ) return; //Nothing to do
   
   double ConvertedMSLP = MissingStopLossPips;
   double spread = MarketInfo(OrderSymbol(), MODE_SPREAD);
   
  
   //There is the option for the user to use Atr to calculate the stop
   if (UseSlAtr) double AtrVal = iATR(OrderSymbol(), AtrSlTimeFrame, AtrSlPeriod, 0) * AtrSlMultiplier;
   
   // Buy trade
   if (OrderType() == OP_BUY)
   {
      double SL = NormalizeDouble(OrderOpenPrice() - (ConvertedMSLP * point),digits);    
      if (UseSlAtr) SL = NormalizeDouble(OrderOpenPrice() - AtrVal, digits);
   }//if (OrderType() == OP_BUY)
   
   
   // Sell trade
   if (OrderType() == OP_SELL)
   {
      SL = NormalizeDouble(OrderOpenPrice() + (ConvertedMSLP * point), digits);
      if (UseSlAtr) SL = NormalizeDouble(OrderOpenPrice() + AtrVal, digits);
   }//if (OrderType() == OP_BUY)
   
   bool result = OrderModify(OrderTicket(),OrderOpenPrice(), SL, OrderTakeProfit(), OrderExpiration(),CLR_NONE);
   if (!result)
   {
      int err=GetLastError();
      Alert(OrderSymbol(), " SL insertion failed with error(",err,"): ",ErrorDescription(err));
      Print(OrderSymbol(), " SL insertion failed with error(",err,"): ",ErrorDescription(err));
      return(false);
   }//if (!result)
   
}// End void InsertStopLoss()

void InsertTakeProfit()
{
   if (OrderType() != OP_BUY && OrderType() != OP_SELL) return;
   
   if (OrderTakeProfit() != 0 || (MissingTakeProfitPips == 0 && !UseSlAtr) ) return; //Nothing to do

   //There is the option for the user to use Atr to calculate the stop
   if (UseTpAtr) double AtrVal = iATR(OrderSymbol(), AtrTpTimeFrame, AtrTpPeriod, 0) * AtrTpMultiplier;
   
   // Buy trade
   if (OrderType() == OP_BUY)
   {
      double TP = NormalizeDouble(ask + (MissingTakeProfitPips * point),digits);
      if (UseSlAtr) TP = NormalizeDouble(OrderOpenPrice() + AtrVal, digits);
   }//if (OrderType() == OP_BUY)
   
   
   // Sell trade
   if (OrderType() == OP_SELL)
   {
      TP = NormalizeDouble(bid - (MissingTakeProfitPips * point), digits);
      if (UseSlAtr) TP = NormalizeDouble(OrderOpenPrice() - AtrVal, digits);
   }//if (OrderType() == OP_BUY)
   
   bool result = OrderModify(OrderTicket(),OrderOpenPrice(), OrderStopLoss(), TP, OrderExpiration(),CLR_NONE);
   if (!result)
   {
      int err=GetLastError();
      Alert(OrderSymbol(), " TP insertion failed with error(",err,"): ",ErrorDescription(err));
      Print(OrderSymbol(), " TP insertion failed with error(",err,"): ",ErrorDescription(err));
      return(false);
   }//if (ticket < 0)
   
}// End void InsertTakeProfit()

void HiddenStopLoss()
{
   //Called from ManageTrade if HideStopLossEnabled = true


   //Should the order close because the stop has been passed?
   //Buy trade
   if (OrderType() == OP_BUY)
   {
      double sl = NormalizeDouble(OrderOpenPrice() - (HiddenStopLossPips * point), digits);
      if (bid <= sl)
      {
         bool result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
         if (result)
         {
            if (ShowAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket());      
         }//if (result)
         else
         {
            int err=GetLastError();
            if (ShowAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//else
      }//if (bid <= sl)      
   }//if (OrderType() == OP_BUY)
   
   //Sell trade
   if (OrderType() == OP_SELL)
   {
      sl = NormalizeDouble(OrderOpenPrice() + (HiddenStopLossPips * point), digits);
      if (ask >= sl)
      {
         result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
         if (result)
         {
            if (ShowAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket());      
         }//if (result)
         else
         {
            err=GetLastError();
            if (ShowAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//else
      }//if (ask >= sl)   
   }//if (OrderType() == OP_SELL)
   

}//End void HiddenStopLoss()

void HiddenTakeProfit()
{
   //Called from ManageTrade if HideStopLossEnabled = true


   //Should the order close because the stop has been passed?
   //Buy trade
   if (OrderType() == OP_BUY)
   {
      double tp = NormalizeDouble(OrderOpenPrice() + (HiddenTakeProfitPips * point), digits);
      if (bid >= tp)
      {
         bool result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
         if (result)
         {
            if (ShowAlerts==true) Alert("Take profit hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket());      
         }//if (result)
         else
         {
            int err=GetLastError();
            if (ShowAlerts==true) Alert("Take profit hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Take profit hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//else
      }//if (ask >= tp)      
   }//if (OrderType() == OP_BUY)
   
   //Sell trade
   if (OrderType() == OP_SELL)
   {
      tp = NormalizeDouble(OrderOpenPrice() - (HiddenTakeProfitPips * point), digits);
      if (ask <= tp)
      {
         result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
         if (result)
         {
            if (ShowAlerts==true) Alert("Take profit hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket());      
         }//if (result)
         else
         {
            err=GetLastError();
            if (ShowAlerts==true) Alert("Take profit hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Take profit hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//else
      }//if (bid <= tp)   
   }//if (OrderType() == OP_SELL)
   

}//End void HiddenTakeProfit()


void ManageTrade()
{
     
   // Call the working subroutines one by one. 

   //Cut down 5 digit order modify calls for 5 digit crims, if required
   static int NoOfTicks = 9;
   int ndigits = MarketInfo(Symbol(), MODE_DIGITS);
   if (DoNotOverload5DigitCriminals && ( ndigits == 3 || ndigits == 5) )
   {
      NoOfTicks++;
   }//if (DoNotOverload5DigitCriminals && ( digits == 3 || digits == 5) )
   
   if (!DoNotOverload5DigitCriminals || ndigits == 2 || ndigits == 4)
   {
      NoOfTicks = 10;
   }//if (!DoNotOverload5DigitCriminals || digits == 2 || digits == 4)
   
   
   // Global variable to pick up on failed part-closes
   if (GlobalVariablesTotal()>0) GlobalVariablesExist=true;
   if (GlobalVariablesExist && GlobalVariablesTotal()>0) TryPartCloseAgain();
   if (GlobalVariablesExist && GlobalVariablesTotal()==0) GlobalVariablesExist=false;
   
   if (NoOfTicks >= 10)
   {
      NoOfTicks = 0;//Reset the counter
      
      // Hidden stop loss
      if (HideStopLossEnabled) HiddenStopLoss();
   
      // Hidden take profit
      if (HideTakeProfitEnabled) HiddenTakeProfit();
   
      // Tighten the stop loss
      if (UseTigheningStop) TightenStopLoss();
      
      // Breakeven
      if(BreakEven) BreakEvenStopLoss();
   
      // JumpingStop
      if(JumpingStop) JumpingStopLoss();
   
      // TrailingStop
      if(TrailingStop) TrailingStopLoss();

      // Trailing stop loss that moves as soon as the market moves in the direction of the trade.
      if (InstantTrailingStop) InstantTrailingStopLoss();
   }//if (NoOfTicks = 10)
   
   // Hedge trade
   if (HedgeEnabled)
   {
       string tn = DoubleToStr(OrderTicket(),0);
       if (!GlobalVariableCheck(tn) ) GlobalVariableSet(tn, HedgeAtLossPips);       
       HedgeTrade();
   }//if (HedgeEnabled)
   
   // Add missing Stop Loss
   if (AddMissingStopLoss) InsertStopLoss();
   
   // Add missing Take Profit
   if (AddMissingTakeProfit) InsertTakeProfit();
   
} // End of ManageTrade()

void CloseBasketTrades()
{
   CloseBasket=false;         
   if (OrdersTotal() == 0) return;
      
   for (int cc=0; cc<OrdersTotal(); cc++)
   {
      if (!OrderSelect(cc,SELECT_BY_POS) ) return;
      if ((ManageByMagicNumber && OrderMagicNumber()==MagicNumber) 
         || (ManageByTradeComment && OrderComment()==TradeComment) || AllTradesBelongToBasket)
      {
         if (OrderType()==OP_BUY || OrderType()==OP_SELL)
         {
            bool result=OrderClose(OrderTicket(),OrderLots(), OrderClosePrice(), 500,CLR_NONE);
            if (!result) CloseBasket=true;
            else cc--;
         }//if (OrderType()==OP_BUY || OrderType()==OP_SELL)
         
         if (OrderType()!=OP_BUY && OrderType()!=OP_SELL && IncludePendingsAtClosure)
         {
            result=OrderDelete(OrderTicket() );
            if (!result) CloseBasket=true;
            else cc--;
         }//if (OrderType()!=OP_BUY && OrderType()!=OP_SELL && IncludePendingsAtClosure)
         
         
         
      }//if (OrderMagicNumber()==MagicNumber)
   }//for (int cc=0; cc<OrdersTotal(); cc++)
   
}// end void CloseBasketTrades()

void CalculateBasketPL()
{
   BasketProfit=0;
   NoOfBasketTrades=0;
   for (int cc=0; cc < OrdersTotal(); cc++)
   {
      OrderSelect(cc, SELECT_BY_POS);
      if ((ManageByMagicNumber && OrderMagicNumber()==MagicNumber) || (ManageByTradeComment && OrderComment()==TradeComment) || AllTradesBelongToBasket)
      {
         BasketProfit=BasketProfit + OrderProfit() + OrderSwap() + OrderCommission();
         NoOfBasketTrades++;
      }//if (ManageByMagicNumber && OrderMagicNumber()==MagicNumber || ManageByTradeComment && OrderComment()==TradeComment)      
   }//for (int cc=0; cc < OrdersTotal(); cc++)
   ScreenMessage="";
   ScreenMessage = StringConcatenate(ScreenMessage, "Basket profit = ", BasketProfit, NL);
   if (LockedProfit > -1) ScreenMessage = StringConcatenate(ScreenMessage, "Locked profits = ", LockedProfit, NL);
   Comment(ScreenMessage);
   
   
}// end void CalculateBasketP&L()

bool ShouldBasketCloseAtTP()
{
   // Returns true if the basket upl >= chosen closure point, else returns false.
   // BasketProfit is already calculated   

   // Is the profit >= selected profit point
   double ProfitPercentage=0;

   // First calculate whether the upl is >= the point at which the position is to close
   
   // Profit in dollars enabled
   if (BasketTPinDollars)
   {
      if(BasketProfit>=BasketDollarTP)
      {
         Comment("Profit target hit. Closing trade basket now");
         return(true);
      } 
   }
   
   // Profit as percentage of account balance enabled
   if (BasketTPasPercent)
   {
      ProfitPercentage=NormalizeDouble(AccountBalance() * (BasketTpPercentage/100),2);
      if (BasketProfit>= ProfitPercentage)
      {
         Comment("Profit target hit. Closing trade basket now");
         return(true);
      }
   }


   ScreenMessage="";
   ScreenMessage = StringConcatenate(ScreenMessage, "Basket profit = ", BasketProfit, NL);
   Comment(ScreenMessage);
   return(false);
   
}// end bool ShouldBasketCloseAtTP()

bool ShouldBasketCloseAtSL()
{
   // Returns true if the basket upl >= chosen closure point, else returns false.
   // BasketProfit is already calculated   

   // Is the profit >= selected profit point
   double ProfitPercentage=0;

   // First calculate whether the upl is >= the point at which the position is to close
   
   // Profit in dollars enabled
   if (BasketSLinDollars)
   {
      double bld = BasketDollarSL;
      if(BasketProfit<=bld)
      {
         Comment("Stop loss hit. Closing trade basket now");
         return(true);
      } 
   }
   
   // Profit as percentage of account balance enabled
   if (BasketSLasPercent)
   {
      ProfitPercentage=AccountBalance() * (BasketSLPercentage/100);
      bld = BasketProfit;
      bld = -bld;
      if (bld>= ProfitPercentage)
      {
         Comment("Stop loss hit. Closing trade basket now");
         return(true);
      }
   }

}// end bool BasketClosure=ShouldBasketCloseAtSL()

void BasketTrailingStopManipulation()
{
   
   //Has the market moved far enough to trigger the trailing stop?
   if (LockedProfit==-1)
   {
      if (BasketProfit >= BasketTsAtProfit)
      {
         LockedProfit = BasketProfit * (BasketTrailPercent/100);
         Alert("Basket trailing stop initiated at $",LockedProfit);
         return;
      }//if (BasketProfit >= BasketTsAtProfit}
   }//if (LockedProfit==-1)
   
   // Has the trail kicked in, and if so has the profit retraced to it
   if (LockedProfit > -1 && BasketProfit <= LockedProfit)
   {
      LockedProfit=-1;
      Comment("Basket trailing stop hit. Closing trades.");
      Alert("Basket trailing stop hit. Closing trades.");
      CloseBasket = false;
      CloseBasketTrades();
      return;
   }
      
   
   // Does a trailing stop need updating?
   if (BasketProfit >= BasketTsAtProfit)
   {
      double Trail = BasketProfit * (BasketTrailPercent/100);
      if (Trail > LockedProfit)
      {
         LockedProfit = Trail;
      }//if (Trail > LockedProfit)
   }//if (BasketProfit >= BasketTsAtProfi
    
   // Got this far, so give the user some feedback
   ScreenMessage="";
   ScreenMessage = StringConcatenate(ScreenMessage, "Basket profit = ", BasketProfit, NL);
   if (LockedProfit > -1) ScreenMessage = StringConcatenate(ScreenMessage, "Locked profits = ", LockedProfit, NL);
   else ScreenMessage = StringConcatenate(ScreenMessage, "No locked profits yet", NL);
   Comment(ScreenMessage);
      
}// end void BasketTrailingStopManipulation()

bool ConfirmBasketClosure()
{
   // User has set BasketCloseImmediately to true, so confirm this choice.
   // Returns true if user confirms, else false
   
   int ret=MessageBox("Close all open trades monitored by this ea?","Question",MB_YESNO|MB_ICONQUESTION);
      if (ret==IDNO)
      {
         MessageBox("Remember to turn off BasketCloseImmediately.","Reminder");
         return(false);
      }
      
      return(true);   
   
}// End bool ConfirmBasketClosure()

void CheckBasketTradesExpiry()
   {
      // Checks the length of time basket trades have been open, and closes them all if any one has been open 
      // for longer than the user requires.
      //This function is only called if TradesWillExpire is set to true and there are open trades
      
      for (int cc = 0; cc<OrdersTotal(); cc++)
      {
         OrderSelect(cc,SELECT_BY_POS);
         if ((TimeCurrent() - OrderOpenTime() >= (TradesWillExpireMins*60)) && OrderMagicNumber()==MagicNumber)
         {
            if (ShowAlerts) Alert("Trade expiry time has been reached, so a;; baslet trades were closed");
            CloseBasket=true;//This will force basket trade closure on the next tick
            return;
         }
      }
         
   }//void CheckBasketTradesExpiry()
   
void BasketJumpingStopManipulation()
   {

      // Has the trail kicked in, and if so has the profit retraced to it
      if (LockedProfit > -1 && BasketProfit <= LockedProfit)
      {
         LockedProfit=-1;
         Comment("Basket jumping stop hit. Closing trades.");
         Alert("Basket jumping stop hit. Closing trades.");
         CloseBasket = false;
         CloseBasketTrades();
         return;
      }
      
      // Is jumping stop disabled after break even?
      if (LockedProfit > -1 && DisableBasketJumpStopAfterBE)
      {
         ScreenMessage="";
         ScreenMessage = StringConcatenate(ScreenMessage, "Basket profit = ", BasketProfit, NL);
         ScreenMessage = StringConcatenate(ScreenMessage, "Locked profits = ", LockedProfit, NL);
         Comment(ScreenMessage);   
      }
   
      // Set to breakeven the first time BasketProfit reaches\passes BasketJumpingStopProfit
      // Add BasketBEP later
      if (LockedProfit==-1)
      {
         if (BasketProfit >= BasketJumpingStopProfit)
         {
            LockedProfit=0;
            string JSmessage = "Basket jumping stop moved to breakeven ";
            if (BasketAddBEP) 
            {
               LockedProfit=LockedProfit + BasketBreakEvenProfit;
               JSmessage = StringConcatenate(JSmessage, "plus profit of $",LockedProfit);
            }//if (BasketAddBEP) 
            if (ShowAlerts) Alert(JSmessage);
         }//if (BasketProfit >= BasketJumpingStopProfit)         
      }//if (LockedProfit==-1)
   
      // Does a jumping stop need updating?
      if (BasketProfit >= LockedProfit + (BasketJumpingStopProfit*2)) 
      {
         LockedProfit = LockedProfit + BasketJumpingStopProfit;
         JSmessage= StringConcatenate("Basket trades jumping stop moved to $", LockedProfit);
         Alert(JSmessage);
      }
    
      // Got this far, so give the user some feedback
      ScreenMessage="";
      ScreenMessage = StringConcatenate(ScreenMessage, "Basket profit = ", BasketProfit, NL);
      if (LockedProfit > -1) ScreenMessage = StringConcatenate(ScreenMessage, "Locked profits = ", LockedProfit, NL);
      else ScreenMessage = StringConcatenate(ScreenMessage, "No locked profits yet", NL);
      Comment(ScreenMessage);
   
   
   
   }//End void BasketJumpingStopManipulation()   

void TryPartCloseAgain()
   {
      // Called if GlobalVariablesExist is set to true and global variables exist.
      // Attempts to part-close where a previous attempt failed
      
      string name;
      int index;
      int TicketNumber;
      for (int cc=0; cc < GlobalVariablesTotal(); cc++)
      {
         name = GlobalVariableName(cc);// Extract gv name
         index = StringFind(name,"GlobalVariableTicketNo",0);// Is it relevent to this function?
         if (index>-1)// If so, then retry the part-close
         {
            TicketNumber = GlobalVariableGet(name);
            //Make sure trade was not closed previously
            if (OrderSelect(TicketNumber, SELECT_BY_TICKET) && OrderCloseTime() == 0)
            {
               bool PartCloseSuccess = PartCloseTradeFunction();
               if (PartCloseSuccess)
               {
                  GlobalVariableDel(name);
                  cc--;
               }//if (PartCloseSuccess)
            }//if (OrderSelect(), TicketNumber, SELECT_BY_POS)
            else
            {
               GlobalVariableDel(name);
               cc--;
            }
         }//if (index>-1)
      }//for (int cc=0; cc < GlobalVariablesTotal(); cc++)
   }//void TryPartCloseAgain()

double AutoPercentageBasketTp()
   {

      // Calculates the basket tp based on the percentages of balance set in the three 
      // no-of-trade bands. Returns this figure for use in calculating whether the upl has reached the tp
      // and in screen feedback.
      
      double ProfitPercentage;
      
      if (NoOfBasketTrades < 8)
      {
         ProfitPercentage=NormalizeDouble(AccountBalance() * (FourToSevenTradesPercent/100),2);
      }
      
      if (NoOfBasketTrades > 7 && NoOfBasketTrades < 13)
      {
         ProfitPercentage=NormalizeDouble(AccountBalance() * (EightToTwelveTradesPercent/100),2);
      }
      
      if (NoOfBasketTrades > 12)
      {
         ProfitPercentage=NormalizeDouble(AccountBalance() * (ThirteenPlusTradesPercent/100),2);
      }
      
      return(ProfitPercentage);
   
   }//double AutoPercentageBasketTp()

bool ShouldBasketCloseAtAutocalcTP()
   {
      // Calls the function that calculates the basket tp based on the percentages of balance set in the three 
      // no-of-trade bands, then calculates whether this figure has been reached. Returns 'true' if so, else returns false.
  
      // Put the percentage calculation routine into a separate function so it can be called during the
      // on-screen user feedback routines.
      double Profit=AutoPercentageBasketTp();
      
      if (BasketProfit >= Profit) return(true);
      else return(false);
   
   }//bool ShouldBasketCloseAtAutocalcTP()
   
   
void MonitorBasketTrades()
{
   
   // CloseBasket is set to true by any routine that finds the basket should be closed.
   // The function deals with cancelling Closebasket. This only happens when all trades
   // have been closed successfully.
   if (CloseBasket) 
   {
      CloseBasket = false;
      CloseBasketTrades();
      return;//Nothing else to do
   }

   // User has chosen to close basket trades
   if (BasketCloseImmediately)
   {
      bool BasketClosure=ConfirmBasketClosure();
      if (BasketClosure) 
      {
         Comment("Closing basket trades");
         CloseBasket = false;
         CloseBasketTrades();
         return;
      }   
   }//if (BasketCloseImmediately)

   // Calculate the upl for the basket.
   // Also calculates the number of trades in the basket and stores this in  NoOfBasketTrades
   CalculateBasketPL();
   
   // Check to see if the basket has reached a pre-determined profit point
   if (BasketClosureTP && BasketProfit>0)
   {
      BasketClosure=ShouldBasketCloseAtTP(); // Retruns true if the basket upl >= chosen closure point
      if (BasketClosure) 
      {
         Alert("Basket TP hit, so the trades were closed");
         CloseBasket = false;
         CloseBasketTrades();
         return;
      }   
   }//if (BasketClosureTP && BasketProfit>0)
   
   // Check to see if the basket has hit a pre-determined stop loss
   if (BasketClosureSL && BasketProfit<0)
   {
      BasketClosure=ShouldBasketCloseAtSL(); // Retruns true if the basket upl >= chosen closure point
      if (BasketClosure) 
      {
         Alert("Basket SL hit, so the trades were closed");
         CloseBasket = false;
         CloseBasketTrades();
         return;
      }   
   }//if (BasketClosureSL&& BasketProfit<0)
   
   // Check to see if the basket has reached an auto-calculated percentage of balance profit
   if (AutoCalcBasketTPasPercent && BasketProfit>0)
   {
      BasketClosure=ShouldBasketCloseAtAutocalcTP(); // Retruns true if the basket upl >= chosen closure point
      if (BasketClosure) 
      {
         Alert("Basket TP hit, so the trades were closed");
         CloseBasket = false;
         CloseBasketTrades();
         return;
      }   
   }//if (AutoCalcBasketTPasPercent && BasketProfit<0)
   
   // Trailing stop
   if (BasketTrailingStop)
   {
      BasketTrailingStopManipulation();
   }
   
   //Jumping stop loss
   if (BasketJumpingStop) BasketJumpingStopManipulation();
   
   // Basket expiry
   if (TradesWillExpire && OrdersTotal()>0) CheckBasketTradesExpiry();
   
   
   // User feedback. Basket profit\loss is already displayed, so add details to ScreenMessage
   string SaveSM=ScreenMessage;
   ScreenMessage = StringConcatenate(ScreenMessage, "Managing basket trades by ");
   if (ManageByMagicNumber) ScreenMessage = StringConcatenate(ScreenMessage, "Magic Number = ",MagicNumber,NL);
   if (ManageByTradeComment) ScreenMessage = StringConcatenate(ScreenMessage, "Trade comment = ", TradeComment,NL);
   
   if (BasketClosureTP)
   {
      ScreenMessage = StringConcatenate(ScreenMessage, "Basket Closure Take Profit is enabled. ");
      if (BasketTPinDollars) ScreenMessage = StringConcatenate(ScreenMessage, "Taking profit at $", BasketDollarTP, " profit",NL);
      if (BasketTPasPercent) 
      {
         double ProfitPercentage=NormalizeDouble(AccountBalance() * (BasketTpPercentage/100),2);
         ScreenMessage = StringConcatenate(ScreenMessage, "Taking profit at ", BasketTpPercentage, "% profit = $",ProfitPercentage,NL);      
      }
   }//if (BasketClosureTP)
   
   if (!AutoCalcBasketTPasPercent && !BasketClosureTP) ScreenMessage = StringConcatenate(ScreenMessage, "Basket Closure Take Profit is disabled. ",NL);
   
   if (AutoCalcBasketTPasPercent)
   {
      double Profit=AutoPercentageBasketTp();
      ScreenMessage = StringConcatenate(ScreenMessage, "Auto-calculating bakset tp. Tp is $", Profit,NL);
   }
   
   if (BasketClosureSL)
   {
      ScreenMessage = StringConcatenate(ScreenMessage, "Basket Closure Stop Loss is enabled. ");
      if (BasketSLinDollars) ScreenMessage = StringConcatenate(ScreenMessage, "Stop loss is $", BasketDollarSL, " loss",NL);
      if (BasketSLasPercent) ScreenMessage = StringConcatenate(ScreenMessage, "Stop loss set to ", BasketSLPercentage, "% loss",NL);      
   
   }//if (BasketClosureSL)
   else ScreenMessage = StringConcatenate(ScreenMessage, "Basket Closure Stop Loss is disabled. ",NL);
      
   if (BasketTrailingStop)
   {
      ScreenMessage = StringConcatenate(ScreenMessage, "Basket Trailing Stop is enabled. Starting trail at +$", BasketTsAtProfit, " and trailing by ",BasketTrailPercent,"% of profit",NL);
      
   }//if (BasketTrailingStop)
  
   if (BasketJumpingStop)
   {
      ScreenMessage = StringConcatenate(ScreenMessage, "Basket jumping stop is enabled at $", BasketJumpingStopProfit,NL);
      if (BasketAddBEP) ScreenMessage = StringConcatenate(ScreenMessage, "Adding break even profit of $",BasketBreakEvenProfit,NL);
      if (DisableBasketJumpStopAfterBE)  ScreenMessage = StringConcatenate(ScreenMessage, "Disabling jumping stop after break even", NL);
      else  ScreenMessage = StringConcatenate(ScreenMessage, "Not disabling jumping stop after break even", NL);
   }//if (BasketJumpingStop)
     
   if (TradesWillExpire) ScreenMessage = StringConcatenate(ScreenMessage, "TradesWillExpire is enabled. The expiry period is ", TradesWillExpireMins, " minutes",NL);
   else ScreenMessage = StringConcatenate(ScreenMessage, "TradesWillExpire is not enabled",NL);
   
   if (!BasketJumpingStop) ScreenMessage = StringConcatenate(ScreenMessage, "Basket jumping stop is disabled",NL);

   if (ShowComments) Comment(ScreenMessage);
}// end void MonitorBasketTrades()

void main()
{
   //############## ADDED BY CACUS
   suffix = StringSubstr(Symbol(),6,4);
   int qty=PairsQty();
   
   
   int i = 0;int j = 0;
   for (int k = 0; k < qty; k ++)
   {
      i = StringFind(String, ",",j);
      if (i > -1)
      {
         ManagePair[k] = StringSubstr(String, j,i-j);
         ManagePair[k] = StringTrimLeft(ManagePair[k]);
         ManagePair[k] = StringTrimRight(ManagePair[k]);
         ManagePair[k] = StringConcatenate(ManagePair[k], suffix);
         j = i+1;         
      }
   }
   /*Print("PairsQty: ",qty); // Just to check....
   for (int s=1;s<=qty;s++){
   Print("Pair ",s,": ", ManagePair[s-1]);
   }
      */
   //############## ADDED BY CACUS   
    
   //At the start of each new hour, delete orphaned hedge global variables   
   if (OldHourlyBars != iBars(Symbol(), PERIOD_H1) )
   {
      if (GlobalVariablesTotal() > 0) DeleteOrphanHedgeGVs();
      OldHourlyBars = iBars(Symbol(), PERIOD_D1);
   }//if (OldHourlyBars != iBars(Symbol(), PERIOD_H1) )
   
   
   // Stop if there is nothing to do
   if (OrdersTotal()==0)
   {
      if (ShowComments) Comment("No trades to manage. I am bored witless.");
      return(0);
   }
   
   
   MonitorTrades(); // Stop loss adjusting, part closure etc
   
   if (GlobalOrderClosureEnabled) GlobalOrderClosure(); // Whole position closing at set profit level
   
   // Account protection in event of catastrophe
   if (ShirtProtectionEnabled) ShirtProtection();
   
   // Basket trading
   if (ManageBasketTrades) MonitorBasketTrades();


}//end void main()


//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start() 
{

	//The always on code is provided by gspe. Many thanks, Guiseppe
	if (AlwaysOn == true) 
	{
		while (IsExpertEnabled())	// Check if expert advisors are enabled for running
		{							// This is an infinite loop so the expert doesn't wait for ticks
			main();
			Sleep(delay);
			WindowRedraw();
		}
	} 
	else 
	{
		main(); 
	}
			 
	return(0);   
}//End int start() 