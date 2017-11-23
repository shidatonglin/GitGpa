//+-------------------------------------------------------------------+
//|                                      Multi Purpose Basket Manager |
//|                                     Copyright 2012, Steve Hopwood |
//|                               http://www.hopwood3.freeserve.co.uk |
//+-------------------------------------------------------------------+
#property copyright "Copyright 2012, Steve Hopwood"
#property link      "http://www.hopwood3.freeserve.co.uk"

#define  NL    "\n"

#define  version "v1.0.3"

//+------------------------------------------------------------------+
//| Release Notes                                                    |
//+------------------------------------------------------------------+
// v1.0.0, 7/20/12
// * Initial release
// v1.0.1, 7/27/12
// * Fixed non closing issue
// v1.0.2, 8/30/12
// * Added option to filter on trade comment
// v1.0.3, 11/7/12
// * Excluded pending orders

extern string  gen = "----- General inputs -----";
extern int     MagicNumber = 0;
extern string  TradeComment = "";
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
extern string  tpsl = "----- Take profit and stop loss -----";
extern string  tpi = "--- Take profit ---";
extern string  tpp = "Pips TP";
extern int     AdaptivePipsTakeProfit = 50; //Pips per open trade. A zero input will disable this.
extern int     PipsTakeProfit = 0; //Hard tp, overridden by AdaptivePipsTakeProfit
extern string  ctp = "Cash TP";
extern int     CashTakeProfit = 0; //integer declaration is deliberate - no need to muck around with pence
extern double  RewardPercentageTakeProfit = 0; //Percent of balance to use as cash tp. Zero to disable
extern string  sli = "--- Stop loss ---";
extern string  tsl = "Pips SL";
extern int     AdaptivePipsStopLoss = 75; //Pips per open trade. A zero input will disable this.
extern int     PipsStopLoss = 0; //Hard sl, overridden by AdaptivePipsStopLoss
extern string  csl = "Cash SL";
extern int     CashStopLoss = 0; //integer declaration is deliberate - no need to muck around with pence
extern double  RiskPercentageStopLoss = 0; //Percent of balance to use as sl. Zero to disable
extern string  bei = "Break even";
extern int     BreakEvenProfitPips = 200; //Set to zero to disable this function
extern int     BreakEvenProfitPipsLock = 20;
extern int     AdaptiveBreakEvenProfitPips = 25; //Set to zero to disable this function
extern int     AdaptiveBreakEvenProfitPipsLock = 10; //Pips per open trade. A zero input will disable this.
int            BreakEvenProfitCash = 0; //Set to zero to disable this function
int            BreakEvenProfitCashLock = 0;
extern string  jsli = "Jumping stop loss";
extern int     JumpingStopPips = 0; //Zero to disable
extern int     AdaptiveJumpingStopPips = 15; //Zero to disable

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
double         CashUpl;//For keeping track of the basket CashUpl
double         PipsUpl;//Basket CashUpl in pips
double         MaxPipsUpl;//Biggest ever pips upl
string         MaxDdGv;
string         PipDescription = " pips";
bool           BreakevenAchieved = false;
string         PipsTpGvName = "BJS Stop Loss Pips";
int            JslPips;//Holds breakeven for now. Later will hold the latest jumping stop.
string         CashTpGvName = "BJS Stop Loss Cash";
double         JslCash;//Holds breakeven and jumping stop.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


extern string  mis = "----Odds and ends----";
extern int     DisplayGapSize = 3;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
string         Gap, ScreenMessage;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int            OpenTrades;
bool           ForceClosure;
bool           CloseNeeded;

void DisplayUserFeedback()
{
   if ( IsTesting() && !IsVisualMode() ) return;

   ScreenMessage = "";
   ScreenMessage = StringConcatenate ( ScreenMessage, Gap, NL );
   ScreenMessage = StringConcatenate ( ScreenMessage, Gap, "Updates for this EA are to be found at http://www.stevehopwoodforex.com", NL );
   ScreenMessage = StringConcatenate ( ScreenMessage, Gap, "Feeling generous? Help keep the coder going with a small Paypal donation to pianodoodler@hotmail.com", NL );
   ScreenMessage = StringConcatenate ( ScreenMessage, Gap, TimeToStr ( TimeLocal(), TIME_DATE | TIME_SECONDS ), NL );
   ScreenMessage = StringConcatenate ( ScreenMessage, Gap, version, NL );

   ScreenMessage = StringConcatenate ( ScreenMessage, Gap, NL );

   ScreenMessage = StringConcatenate ( ScreenMessage, Gap, "Open trades ", OpenTrades, ": Upl = $", DoubleToStr ( CashUpl, 2 ),
                                       ": ", DoubleToStr ( PipsUpl, 0 ), PipDescription,
                                       ": Max pips drawdown ever = ", MaxPipsUpl, PipDescription,
                                       NL );
   if ( BreakevenAchieved ) ScreenMessage = StringConcatenate ( ScreenMessage, Gap, "Breakeven achieved", NL );

   ScreenMessage = StringConcatenate ( ScreenMessage, Gap, NL );
   ScreenMessage = StringConcatenate ( ScreenMessage, Gap, "Pips take profit ", PipsTakeProfit, PipDescription );
   ScreenMessage = StringConcatenate ( ScreenMessage, ":  Pips stop loss ", PipsStopLoss, PipDescription, NL );
   if ( CashTakeProfit > 0 ) ScreenMessage = StringConcatenate ( ScreenMessage, Gap, "Cash take profit ", DoubleToStr ( CashTakeProfit, 2 ), "  " );
   string tg = Gap;
   if ( CashTakeProfit > 0 ) tg = "";
   if ( CashStopLoss < 0 ) ScreenMessage = StringConcatenate ( ScreenMessage, tg, "Cash stop loss ", DoubleToStr ( CashStopLoss, 2 ) );
   ScreenMessage = StringConcatenate ( ScreenMessage, Gap, NL );
   if ( BreakEvenProfitCash > 0 ) ScreenMessage = StringConcatenate ( ScreenMessage, Gap,
            "Basket breakeven = ", DoubleToStr ( BreakEvenProfitCash, 2 ),
            ": Breakeven profit = ", DoubleToStr ( BreakEvenProfitCashLock, 2 ),
            NL );

   if ( BreakEvenProfitPips > 0 ) ScreenMessage = StringConcatenate ( ScreenMessage, Gap,
            "Basket breakeven = ", BreakEvenProfitPips, PipDescription,
            ": Breakeven profit = ", BreakEvenProfitPipsLock, PipDescription,
            NL );
   if ( JumpingStopPips > 0 ) ScreenMessage = StringConcatenate ( ScreenMessage, Gap, "Jumping stop ", JumpingStopPips, PipDescription, NL );
   if ( JslPips > 0 ) ScreenMessage = StringConcatenate ( ScreenMessage, Gap, "Locked in profit: ", JslPips, PipDescription, NL );
   if ( MagicNumber > 0 ) ScreenMessage = StringConcatenate ( ScreenMessage, Gap, "Magic number: ", MagicNumber );
   if ( TradeComment != "" ) ScreenMessage = StringConcatenate ( ScreenMessage, Gap, "Trade comment: ", TradeComment );

   Comment ( ScreenMessage );


}//void DisplayUserFeedback()

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
   while ( IsConnected() == false )
   {
      Comment ( "Waiting for MT4 connection..." );
      Sleep ( 1000 );
   }//while (IsConnected()==false)

   Gap = "";
   if ( DisplayGapSize > 0 )
   {
      for ( int cc = 0; cc < DisplayGapSize; cc++ )
      {
         Gap = StringConcatenate ( Gap, " " );
      }
   }//if (DisplayGapSize >0)

   //Cash stop loss needs to be a negative
   if ( CashStopLoss > 0 ) CashStopLoss = -CashStopLoss;
   if ( PipsStopLoss > 0 ) PipsStopLoss = -PipsStopLoss;

   //The value of the latest jumping stop is saved in a Global Variable, so check for the existence of this and set
   //JslPips
   if ( GlobalVariableCheck ( PipsTpGvName ) )
   {
      JslPips = GlobalVariableGet ( PipsTpGvName );
      BreakevenAchieved = true;
   }//if (GlobalVariableCheck(PipsTpGvName) )

   //JslCash
   if ( GlobalVariableCheck ( CashTpGvName ) )
   {
      JslCash = GlobalVariableGet ( CashTpGvName );
      BreakevenAchieved = true;
   }//if (GlobalVariableCheck(CashTpGvName) )

   while ( IsConnected() == false )
   {
      Comment ( "Waiting for MT4 connexion..." );
      Sleep ( 1000 );
   }//while (IsConnected()==false)

   MaxDdGv = WindowExpertName() + " max drawdown";
   MaxPipsUpl = GlobalVariableGet ( MaxDdGv );

   //Set up trading Times, read table etc
   CountOpenTrades();
   DisplayUserFeedback();
}


//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
   Comment ( "" );
}

void CountOpenTrades()
{
   // Not all these will be needed. Which ones are depends on the individual EA.
   OpenTrades = 0;
   PipsUpl = 0;
   bool result;

   double OldCashUpl = CashUpl; // For KeepAliveHours
   CashUpl = 0; // Unrealised profit and loss for hedging/recovery basket closure decisions

   if ( OrdersTotal() == 0 ) return;

   // Iterating backwards through the orders list caters more easily for closed trades than iterating forwards
   for ( int cc = OrdersTotal() - 1; cc >= 0; cc-- )
   {
      //Ensure the trade is still open
      if ( !OrderSelect ( cc, SELECT_BY_POS ) ) continue;
      //Ensure the EA 'owns' this trade
      if ( OrderMagicNumber() != MagicNumber ) continue;
      if ( OrderComment() != TradeComment ) continue;
      //Exclude pending orders
      if ( OrderType() > OP_SELL ) continue;

      OpenTrades++;

      //Cash CashUpl
      CashUpl += ( OrderProfit() + OrderSwap() + OrderCommission() );
      double pips = CalculateTradeProfitInPips ( OrderType() );
      PipsUpl += pips;

   }//for (int cc = OrdersTotal() - 1; cc <= 0; c`c--)

   //Calculate stops etc
   //Adaptive tp/sl
   if ( AdaptivePipsStopLoss > 0 ) PipsStopLoss = AdaptivePipsStopLoss * OpenTrades;
   PipsStopLoss = -PipsStopLoss;
   if ( AdaptivePipsTakeProfit > 0 ) PipsTakeProfit = AdaptivePipsTakeProfit * OpenTrades;
   if ( AdaptiveBreakEvenProfitPips > 0 && JslPips == 0 )
   {
      BreakEvenProfitPips = AdaptiveBreakEvenProfitPips * OpenTrades;
      BreakEvenProfitPipsLock = AdaptiveBreakEvenProfitPipsLock * OpenTrades;
   }//if (AdaptiveBreakEvenProfitPips > 0)

   //Risk/reward tp/sl
   //TP
   if ( RewardPercentageTakeProfit > 0 )
   {
      CashTakeProfit = AccountBalance() * RewardPercentageTakeProfit / 100;
   }//if (RewardPercentageTakeProfit > )

   //SL
   if ( RiskPercentageStopLoss > 0 )
   {
      CashStopLoss = AccountBalance() * RiskPercentageStopLoss / 100;
      CashStopLoss = -CashStopLoss;
   }//if (RewardPercentageTakeProfit > )

   //Jumping stop.
   if ( AdaptiveJumpingStopPips > 0 ) JumpingStopPips = AdaptiveJumpingStopPips * OpenTrades;

   if ( PipsUpl < MaxPipsUpl )
   {
      MaxPipsUpl = PipsUpl;
      GlobalVariableSet ( MaxDdGv, MaxPipsUpl );
   }//if (PipsUpl > MaxPipsUpl)

}//End void CountOpenTrades();

double CalculateTradeProfitInPips ( int type )
{
   //Returns the pips Upl of the currently selected trade. Called by CountOpenTrades()
   double profit;
   // double point = BrokerPoint(OrderSymbol() ); // no real use
   double ask = MarketInfo ( OrderSymbol(), MODE_ASK );
   double bid = MarketInfo ( OrderSymbol(), MODE_BID );

   if ( OrderType() == OP_BUY )
   {
      profit = bid - OrderOpenPrice();
   }//if (OrderType() == OP_BUY)

   if ( OrderType() == OP_SELL )
   {
      profit = OrderOpenPrice() - ask;
   }//if (OrderType() == OP_SELL)
   profit *= PFactor ( OrderSymbol() ); // use PFactor instead of point.

   return ( profit ); // in real pips
}//double CalculateTradeProfitInPips(int type)


void CloseAllTrades()
{
   ForceClosure = false;
   
   if ( OrdersTotal() == 0 ) return;

   for ( int cc = OrdersTotal() - 1; cc >= 0; cc-- )
   {
      if ( !OrderSelect ( cc, SELECT_BY_POS ) ) continue;
      if ( OrderMagicNumber() != MagicNumber ) continue;
      if ( OrderComment() != TradeComment ) continue;
      while ( IsTradeContextBusy() ) Sleep ( 100 );
      bool result = OrderClose ( OrderTicket(), OrderLots(), OrderClosePrice(), 1000, CLR_NONE );
      if ( result )
      {
         cc++;
         OpenTrades--;
      }
      if ( !result ) ForceClosure = true;

   }//for (int cc = OrdersTotal() - 1; cc >= 0; cc--)

   //If full closure succeeded, then allow new trading
   if ( !ForceClosure )
   {
      OpenTrades = 0;
   }//if (!ForceClosure)

}//End void CloseAllTrades()

void LookForBreakeven()
{
   if ( BreakEvenProfitPips > 0 ) //Zero setting disables this feature
   {
      if ( !BreakevenAchieved && PipsUpl >= BreakEvenProfitPips )
      {
         BreakevenAchieved = true;
         JslPips = BreakEvenProfitPipsLock;
         GlobalVariableSet ( PipsTpGvName, JslPips );
      }//if (PipsUpl >= BreakEvenProfitPips)
   }//if (BreakEvenProfitPips > 0)

   if ( BreakEvenProfitCash > 0 ) //Zero setting disables this feature
   {
      if ( !BreakevenAchieved && CashUpl >= BreakEvenProfitCash )
      {
         BreakevenAchieved = true;
         JslCash = BreakEvenProfitCash;
         GlobalVariableSet ( CashTpGvName, JslCash );
      }//if (PipsUpl >= BreakEvenProfitPips)
   }//if (BreakEvenProfitPips > 0)

}//End void LookForBreakeven()

void LookForPositionClosure()
{
   //Set CloseNeeded to true if any of the basket closure criteria are met. Calls the closure function if so.
   CloseNeeded = false;

   //Examine the criteria
   if ( CashTakeProfit > 0 )
   {
      if ( CashUpl > CashTakeProfit ) CloseNeeded = true;
      //GoToSleep = true;//Enable the post-closure sleep
   }//if (CashTakeProfit > 0)
   if ( CashStopLoss < 0 )
   {
      if ( CashUpl < CashStopLoss ) CloseNeeded = true;
      //GoToSleep = false;//Disable the post-closure sleep
   }//if (CashTakeProfit > 0)

   if ( PipsTakeProfit > 0 )
   {
      if ( PipsUpl > PipsTakeProfit ) CloseNeeded = true;
      //GoToSleep = true;//Enable the post-closure sleep
   }//if (PipsUpl > PipsTakeProfit) CloseNeeded = true;

   if ( PipsStopLoss < 0 )
   {
      if ( PipsUpl < PipsStopLoss ) CloseNeeded = true;
      //GoToSleep = false;//Disable the post-closure sleep
   }//if (PipsTakeProfit > 0)

   //Breakeven
   if ( BreakevenAchieved )
   {
      if ( JslPips > 0 )
      {
         if ( PipsUpl <= JslPips ) CloseNeeded = true;
      }//if (JslPips > 0)

      if ( JslCash > 0 )
      {
         if ( CashUpl <= JslCash ) CloseNeeded = true;
      }//if (JslCash > 0)
   }//if (BreakevenAchieved)

   //Close the basket if any of the closure targets been reached
   if ( CloseNeeded )
   {
      CloseAllTrades();
      //CloseAllTrades() sets ForceClosure to 'true' if an OrderClose() fails, else leaves it 'false'
      if ( ForceClosure )
      {
         CloseAllTrades();
         if ( ForceClosure ) return;
      }//if (ForceClosure)
      //Got this far, so the basket close succeeded, so send the bot to sleep for a while.
      //Reset the variables first
      BreakevenAchieved = false;
      GlobalVariableDel ( PipsTpGvName );
      GlobalVariableDel ( CashTpGvName );
      CloseNeeded = false;
      JslPips = 0;
      JumpingStopPips = 0;
   }//if (CloseNeeded)

}//void LookForPositionClosure()

void JumpingStopLoss()
{
   if ( PipsUpl >= JslPips + ( JumpingStopPips * 2 ) )
   {
      JslPips += JumpingStopPips;
      GlobalVariableSet ( PipsTpGvName, JslPips );
   }//if (PipsUpl > JslPips * 2)

}//End void JumpingStopLoss()

int PFactor ( string pair )
{
   int PipFactor = 10000; // correct factor for most pairs
   if ( StringFind ( pair, "JPY", 0 ) != -1 || StringFind ( pair, "XAG", 0 ) != -1 )
      PipFactor = 100; // if jpy or silver
   if ( StringFind ( pair, "XAU", 0 ) != -1 )
      PipFactor = 10; // if gold
   return ( PipFactor );
}//End int PFactor(string pair)

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
   if ( IsExpertEnabled() == false )
   {
      Comment ( Gap, "--------------EXPERTS DISABLED--------------" );
      while ( !IsExpertEnabled() ) Sleep ( 100 );
   }//if (IsExpertEnabled() == false)

   int OldOpenTrades = OpenTrades;
   CountOpenTrades();
   if ( OpenTrades == 0 )
   {
      BreakevenAchieved = false;
      GlobalVariableDel ( PipsTpGvName );
      GlobalVariableDel ( CashTpGvName );
      CloseNeeded = false;
      JslPips = 0;
      JumpingStopPips = 0;
   }//if (OpenTrades == 0)

   //Look for chance to move the basket stop loss to breakeven
   if ( OpenTrades > 0 )
   {
      LookForBreakeven();
   }//if (OpenTrades > 0)

   //Look for an opportunity to update the jumping stop loss
   if ( JumpingStopPips > 0 )
   {
      JumpingStopLoss();
   }//if (JumpingStopPips > 0)

   //Get stats on the open position, and close if necessary
   if ( OrdersTotal() > 0 )
   {
      LookForPositionClosure();
   }//if (OrdersTotal() > 0)

   DisplayUserFeedback();
}//End int start()