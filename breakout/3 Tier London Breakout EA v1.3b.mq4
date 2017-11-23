//+------------------------------------------------------------------+
//| 3 Tier London Breakout.mq4
//+------------------------------------------------------------------+

/*+------------------------------------------------------------------+
 *
 * Version history:
 *
 * V1.3b:
 *     - fixed the "zero divide" error: it was on 2/4-digits brokers only, due to typo in "pip" calculation :-((
 *       Thanks to sabooky for spotting this!
 *
 * V1.3a:
 *     - work-around the "zero divide" error that happens sometimes;
 *       However, this is NOT a fix, and it will only hide the error, and possibly change the EA's behaviour
 *       and prevent it trading that session.
 *       Refresh your charts and history data, that's all i can see so far...
 *
 * V1.3:
 *     - Option to trade 5 TP levels instead of 3:
 *        - added "TP5Factor"; when set to 0, Trades 4 & 5 are NOT used;
 *     - Added "MoveToBEFactor": move to BE when price has covered at least this ratio of TP1;
 *         - default is 1: move to BE when hit TP1;
 *         - example with 0.66: it will move to BE at 2/3 of TP1;
 *         - any value >1 will be taken as a fixed pip count instead of a factor of TP1;
 *     - when martingale is used: if trades are still open from the previous session,
 *        then open new trades with the PREVIOUS (lower) martingale multiplier instead of the same multiplier;
 *     - Added "MaxWinsAllowedPerSession" input;
 *     - Added "TFforReentry" input: 15(=M15) is the default, but can be changed to 1(M1) or 5(M5) to re-enter on shorter TF;
 *     - Added "Debug" input (more Print() when true)
 *     - fixed(hopefully!) "trade 2&3 not moving to BE when TP1 is hit";
 *
 * V1.2b:
 *     - fixed "StickBoxToLatestExtreme" option... box was always sticking to the highest price;
 *
 * V1.2a:
 *     - fixed "zero divide error" with Martingale code when limiting trades to only Trade 1 (when "TP3Factor" is set to 0);
 *
 * V1.2:
 *     - fixed ECN broker order sending (must send with both SL AND TP set to 0, then modify the order);
 *     - when "TP3Factor" is set to 0, Trades 2 & 3 will NOT be sent; only Trade 1 will be used.
 *     - Added "StickBoxToLatestExtreme" input (false);
 *       when true, the box will "stick" to the box high or low, whichever comes last;
 *       when false(default), the box will be centered on the EMA(box_time_range) value, as in previous versions;
 *       This extension is targeted at exploring and optimizing the box POSITION in PRICE, as suggested by JohnnyBSmart;
 *     - added "MaxSpread" input: trades will NOT be sent when the spread is higher than this value;
 *     - fixed session time calculation issues seen when running MT4 on Linux (thanks to xmph).
 *
 * V1.1: added ResetMartAtFirstProfit input;
 *
 * V1.0: original version by Squalou, posted on forexfactory.com
 *       (thread: http://www.forexfactory.com/showthread.php?t=247220)
 *     - "3 Tier London Breakout.mq4" indicator can be used for visual help;
 *
 *+------------------------------------------------------------------+
 */

#property copyright "by Squalou"
#property link      "http://www.forexfactory.com/showthread.php?t=247220"

#property show_inputs
#include <WinUser32.mqh>
#include <stdlib.mqh>
#include <stderror.mqh>


#define  EA_VERSION    "V1.3b"

//+------------------------------------------------------------------+

// "SendTrades": you must set this to true if you want the EA to place trades;
// by default, the EA will NOT send trades, but only show indicator's boxes and fibs (if "ShowBoxes" is true)
extern bool       SendTrades = false;

extern double     Lot  = 0.01;
extern double     MaxRisk = 0; // if 0 then use fixed Lots above
extern int        MagicNumber=0; // if 0 then will autocreate a unique MagicNumber

extern string     StartTime    = "06:00";    // time for start of price establishment window
extern string     EndTime      = "09:14";    // time for end of price establishment window
extern string     SessionEndTime= "02:00";   // end of daily session; tomorrow is another day!
extern int        MinBoxSizeInPips = 15;     // min tradable box size; when box is smaller than that, you should at least reduce your usual lot-size if you decide to trade it;
extern int        MaxBoxSizeInPips = 80;     // max tradable box size; don't trade when box is larger than that value
extern bool       LimitBoxToMaxSize = true;  // when true, a box larger than MaxBoxSizeInPips will be limited to MaxBoxSizeInPips.
extern bool       StickBoxToLatestExtreme = false;  // (applies when "LimitBoxToMaxSize" is true) when true, the box will "stick" to the box high or low, whichever comes last; else it will be centered on the EMA(box_time_range) value;
extern double     TP1Factor    = 1.000;      // if >=10, this will be taken as FIXED PIPs rather than a factor of the box size;
       double     TP2Factor; // set to half-way between TP1Factor and TP3Factor;
extern double     TP3Factor    = 2.618;      // if >=10, this will be taken as FIXED PIPs rather than a factor of the box size; if 0, Trades 2&3 will NOT be sent (only Trade 1);
       double     TP4Factor; // set to half-way between TP3Factor and TP5Factor;
extern double     TP5Factor    = 4.236;// TP4 and TP5 targets are OPTIONAL: set TP5Factor=0 to allow only up to TP3 target;
extern string     TP2_help     = "TP2 is half-way between TP1 and TP3";
extern string     TP4_help     = "TP4 is half-way between TP3 and TP5";
extern double     SLFactor     = 1.000;      // if >=10, this will be taken as FIXED PIPs rather than a factor of the box size;
       int        NumTradesToOpen = 3;        // number of trades to open: 3 when TP3Factor!=0, or only 1 when TP3Factor==0;
extern double     LevelsResizeFactor = 1.0;
extern int        TFforReentry = PERIOD_M15; // TF for re-entry: the last closed bar of this TF must close inside the box in order to allow opening new trades;

extern string     TradeComment="3 Tier London Breakout";
//extern string     _mta1="----MaxTradesAllowedPerSession = 0";
//extern string     _mta2="----means no limit on trades";
extern int        MaxTradesAllowedPerSession=0;
//extern string     _mla1="----MaxLossesAllowedPerSession = 0";
//extern string     _mla2="----means no limit on losses";
extern int        MaxLossesAllowedPerSession=0;
//extern string     _mwa1="----MaxWinsAllowedPerSession = 0";
//extern string     _mwa2="----means no limit on wins";
extern int        MaxWinsAllowedPerSession=0;
//extern string     _tm="----Trade management----";
//extern int        BreakEvenPips=0; // when >0, will move SL to BE+BreakEvenProfitInPips when price has reached BE+BreakEvenPips
extern int        BreakEvenProfitInPips=1;  // lock-in this amount of pips when HalfClose is hit;
//extern int        TrailingStopPips = 0;// Pips to trail the StopLoss; if 0 then no trailing stop
//extern int        TrailingStopStep = 1;// trailing SL jumping step in pips
extern double     MoveToBEFactor = 1.0;  // move to BE+ when price has covered at least this ratio of TP1;

extern string     _mart1="----MARTINGALE multipliers sequence:";
extern string     _mart2="----not used when first multiplier is 0:";
extern string     martingale_sequence="0,1,2,5,13,34,89,233,610,1597,4181";
extern bool       AutoMartingale=false;
extern bool       ResetMartAtFirstProfit=false; // when true, the Mart sequence is reset as soon as profitable trade is reached; else it will scale-in until recouped ALL losses;

extern int        Slippage  = 3; // pips
extern int        MaxSpread = 4; // pips; EA won't send trades if spread is higher than this value;
extern bool       brokerIsECN=false;

//indicator settings
extern bool       ShowBoxes    = true; // when true, will show boxes and fibs just like the Indicator would do; this avoids using the indicator AND the EA together;
extern color      BoxColorOK   = LightBlue;
extern color      BoxColorNOK  = Red;
extern color      BoxColorMAX  = Orange;
extern color      LevelColor   = Black;
extern color      SessionColor = Linen; // show Session periods with a different background color
extern int        FibLength    = 12;
extern bool       showProfitZone = true;
extern color      ProfitColor  = LightGreen;
extern string     objPrefix = "EA-LB2-";  // Prefixes of London Breakout Indicator objects;
//extern int    MinExtentInPips = 0; // actual box extent min limit for computing trade levels;
//extern int    MaxExtentInPips = 0; // actual box extent max limit for computing trade levels; 0 will default to MaxBoxSizeInPips;
extern string     Gap="          ";

extern string     _other_marts="---Other martingale sequences, in decreasing aggressivity(risk) order:";
extern string     aggressive_fibonacci_sequence="1,2,5,13,34,89,233,610,1597,4181"; // =every second term of fibonacci sequence;
extern string     powers_of_2_sequence="1,2,4,8,16,32,64,128,256,512,1024,2048,4096";
extern string     fibonacci_sequence="1,2,3,5,8,13,21,34,55,89,144,233,377,610,987,1597"; // F(n)=F(n-1)+F(n-2);
extern string     mild_fibonacci_sequence="1,2,3,4,6,9,13,19,28,41,60,88,129,189,277,406"; // F(n)=F(n-1)+F(n-3);

extern bool       Debug=false; // set to true to get additional debug Print() in the Journal logs;

//+------------------------------------------------------------------+

#define  NL    "\n"
#define  Status_initializing "????? I N I T I A L I Z I N G ?????"
#define  Status_initialized  "..... I N I T I A L I Z E D ....."
#define  Status_trading "+++++ T R A D I N G +++++"
#define  Status_not_trading "!!!!! N O T   T R A D I N G (Box size) !!!!!"
#define  Status_finished "----- F I N I S H E D   F O R   T O D A Y -----"

//breakout levels
//Entry, stop and tp
double BuyEntry,BuyTP1,BuyTP2,BuyTP3,BuyTP4,BuyTP5,BuySL;
double SellEntry,SellTP1,SellTP2,SellTP3,SellTP4,SellTP5,SellSL;
int SL_pips,TP1_pips,TP2_pips,TP3_pips,TP4_pips,TP5_pips,MoveToBE_pips;
double TP1FactorInput,TP2FactorInput,TP3FactorInput,TP4FactorInput,TP5FactorInput,SLFactorInput;
//box and session
datetime tBoxStart,tBoxEnd,tSessionStart,tSessionEnd,tLastComputedSessionStart,tLastComputedSessionEnd;
double boxHigh,boxLow,boxExtent,boxMedianPrice;

int magic1,magic2,magic3,magic4,magic5;

string symbol;

string            TradingStatus;

//Trading hours
bool              ClosedForFriday;
bool              ClosedForSaturday;
double            TradingStartHHMM,TradingEndHHMM;
bool              TradeHour = false, prev_TradeHour=false;


//Martingale globals:
int               LastOrderProfitable=false;
bool              UseMartingale=false;
double            MartFactor[],LastLotMultiplier=0;
int               MartDepth=0;
int               Mart_Idx=0;

//Aggregates
int               TradesOpen, TradesOpenThisSession, TradesWon, TradesLost, TradesTotal;

//Misc stuff
string            comment;
bool              RobotDisabled;
string            DisabledMessage;

// market info
int pipMult; // multiplier to convert pips to Points;
double pip,pipvalue;
int digits;
double minlot,lotstep;
int SLIPPAGE;

double previousAsk,currentAsk,previousBid,currentBid;

//Risk Management
int    maxSL;

string op_str[5] = { "BUY","SELL","BUYLIMIT","SELLLIMIT","BUYSTOP","SELLSTOP"};

//+------------------------------------------------------------------+
void DisplayUserFeedback()
//+------------------------------------------------------------------+
{
   static bool alreadyPrinted=false;
  
   if (IsTesting()&& !IsVisualMode() && alreadyPrinted) return; // saves cpu time when backtesting

   comment = Gap+WindowExpertName()+ " "+ EA_VERSION+ NL;
   if (MaxRisk <= 0) {
     comment = comment+Gap+ "Lot size = "+ Lot+ " (MaxRisk not used)"+ NL;
   } else {
     comment = comment+Gap+ "MaxRisk = "+ MaxRisk+ "% => "+ DoubleToStr(Lot,2)+ "Lots, AccountFreeMargin = "+ DoubleToStr(AccountFreeMargin(),0)+ AccountCurrency()+ NL;
   }
   comment = comment+Gap+ "Magic number = "+ MagicNumber+ NL
                    +Gap+ "Trading Hours: "+ DoubleToStr(TradingStartHHMM/100,2)+ " - "+ DoubleToStr(TradingEndHHMM/100,2)+ NL
                    +Gap+ "Box=["+StartTime+"-"+EndTime+"] Session ends at "+SessionEndTime+", Box min "+DoubleToStr(MinBoxSizeInPips,0)+"p,"+" max "+DoubleToStr(MaxBoxSizeInPips,0)+"p,"+NL
                    +Gap+ "OPENING "+ NumTradesToOpen + " TRADES each time" +NL
                    +Gap+ "Buy at "+ DoubleToStr(BuyEntry, Digits)+NL
                    +Gap+ "Sell at "+ DoubleToStr(SellEntry, Digits)+ NL
                    +Gap+ " SL="+DoubleToStr(SL_pips,0)+"p"+",TP1="+DoubleToStr(TP1_pips,0)+"p";
   if (TP2Factor>0) comment = comment+",TP2="+DoubleToStr(TP2_pips,0)+"p";
   if (TP3Factor>0) comment = comment+",TP3="+DoubleToStr(TP3_pips,0)+"p";
   if (TP4Factor>0) comment = comment+",TP4="+DoubleToStr(TP4_pips,0)+"p";
   if (TP5Factor>0) comment = comment+",TP5="+DoubleToStr(TP5_pips,0)+"p";
   comment = comment+NL+Gap+ "Moving to BE+"+BreakEvenProfitInPips+"p after "+MoveToBE_pips+"p"+ NL
                    +Gap+ "Local time: "+ TimeToStr(TimeLocal())+ " Broker time: "+ TimeToStr(TimeCurrent())+ " Current Bar time: "+ TimeToStr(Time[0])+ NL
                    ;
/*
    if (TrailingStopPips>0) {
      comment = comment+Gap+ "     Trailing stops at "+TrailingStopPips+" pips, by steps of "+TrailingStopStep+" pips"+ NL;
    }
*/

   if (UseMartingale) {
     if (AutoMartingale) {
        comment =comment+Gap+"     AUTO-MARTINGALE ENABLED"+NL;
     } else {
        comment =comment+Gap+"     MARTINGALE FACTORS: ";
        for (int i=0;i<MartDepth;i++) {
          if (i==Mart_Idx) comment=comment+" ->";
          comment=comment+DoubleToStr(MartFactor[i],0);
          if (i==Mart_Idx) comment=comment+"<- ";
          comment=comment+",";
        }
        comment=comment+NL;
     }
   } else {
     comment =comment+Gap+"     Martingale NOT used"+NL;
   }
   
   comment = comment+Gap+ EA_VERSION+ " " + TradingStatus+ NL;
   
   if (IsTesting() && !IsVisualMode()) {
      Print(comment);
      alreadyPrinted = true;
      return;
   }

   Comment(comment);
}//void DisplayUserFeedback()

//+------------------------------------------------------------------+
int init()
//+------------------------------------------------------------------+
{

  RobotDisabled = false;
  TradingStatus = Status_initializing;

  getpip(); // get pip multiplier and digit

  SLIPPAGE   = Slippage*pipMult;
  MaxSpread *= pipMult;

  symbol = Symbol(); // used throughout all functions

  //Create a MagicNumber if it is 0
  if (MagicNumber == 0) {
    MagicNumber = create_MagicNumber("");
  }

  //setup 3 different magic numbers to track each trade separately
  magic1 = MagicNumber;
  magic2 = MagicNumber+1;
  magic3 = MagicNumber+2;
  magic4 = MagicNumber+3;
  magic5 = MagicNumber+4;
  
  RemoveObjects(objPrefix);	

  if (Lot < minlot) {
    DisabledMessage = "Lot must be >= "+minlot+NL;
    RobotDisabled = true;
    _Alert (DisabledMessage);
    Comment("The robot is NOT trading because ", DisabledMessage);
    return;
  }

  //Check MaxRisk value
  if (MaxRisk > 100) {
    MessageBox("INVALID MaxRisk value " + MaxRisk + NL 
               + "Please reload the robot with valid MaxRisk.");
    DisabledMessage = "MaxRisk value ("+MaxRisk+") is INVALID";
    RobotDisabled = true;
    _Alert (DisabledMessage);
    Comment("The robot is NOT trading because ", DisabledMessage);
    return;
  }

  //compute once the trading session start/end hours
  TradingStartHHMM = roundup_hhmm_time_to_TF (time_string_to_int(EndTime), Period());
  TradingEndHHMM   = time_string_to_int(SessionEndTime);

  //save input Factors;
  TP1FactorInput = TP1Factor;
  TP3FactorInput = TP3Factor;
  TP5FactorInput = TP5Factor;
  SLFactorInput  = SLFactor;

  NumTradesToOpen = 1;
  if (TP3Factor>0) { // Trades 2&3 enabled
    NumTradesToOpen = 3;
  }
  if (TP5Factor>0) { // Trades 4&5 enabled
    NumTradesToOpen = 5;
  }

  // compute box values:
  compute_LB_Indi_LEVELS(TimeCurrent());

  //Check MartFactor and MartDepth for "Martigaling"
  if (AutoMartingale) {
    UseMartingale = true;
  } else {
    MartDepth = string_list_to_double_array(martingale_sequence, ",", MartFactor);
    if (MartFactor[0] != 0) {
      UseMartingale = true;
    }
  }

  if (SendTrades == false) {
    DisabledMessage = "SendTrades is set to FALSE"+NL;
    RobotDisabled = true;
  }


  TradingStatus = Status_initialized;
  DisplayUserFeedback();
  _Alert(TradingStatus);
  return(0);
}
  
//+------------------------------------------------------------------+
int deinit()
//+------------------------------------------------------------------+
{
  if (!IsTesting()) RemoveObjects(objPrefix);	

  Comment("");

  return(0);

}
  
//+------------------------------------------------------------------+
int start()
//+------------------------------------------------------------------+
{

  GetRates();

  //-----------------------
  // compute box values:
  compute_LB_Indi_LEVELS(TimeCurrent());

  //show box and levels if required
  if (ShowBoxes == true) {
    show_boxes(TimeCurrent());
  }

  //-----------------------

  if (RobotDisabled)
  {
    Comment("The robot is NOT trading because ", DisabledMessage);
    return;
  }

  if (!IsTradeAllowed())
  {
    Comment("!!!!!!!!!!!!!!!!!!!!!!!!!\n"
           +"!!!!!!!!!!!!!!!!!!!!!!!!!\n"
           +"--- TRADING NOT ALLOWED YET---\n"
           +"!!!!!!!!!!!!!!!!!!!!!!!!!\n"
           +"!!!!!!!!!!!!!!!!!!!!!!!!!\n"
           );
    return;
  }//if (!IsTradeAllowed)

  //-----------------------
  //check Trading hours

  int now = TimeHour(Time[0])*100 + TimeMinute(Time[0]);
  prev_TradeHour = TradeHour;
  if (  (TradingStartHHMM <= TradingEndHHMM && (now >= TradingStartHHMM && now < TradingEndHHMM))
     || (TradingStartHHMM >  TradingEndHHMM && (now >= TradingStartHHMM || now < TradingEndHHMM)) ) {
    TradeHour = true;
  } else {
    TradeHour = false;
  }

  if (prev_TradeHour==false && TradeHour==true) {
    //new session starting now: display new levels
    Print ("New Session Starting: "+ TimeToStr(TimeLocal())+" ["+DoubleToStr(TradingStartHHMM/100,2)+ "-"+ DoubleToStr(TradingEndHHMM/100,2)+"]"+NL
          +"Box size "+DoubleToStr(boxExtent/pip,1)+  "p"+NL
          +"Buy  Entry: "+ DoubleToStr(BuyEntry, Digits)+  ", TP1: "+ DoubleToStr(BuyTP1, Digits)+  ", SL: "+ DoubleToStr(BuySL, Digits)+ NL
          +"Sell Entry: "+ DoubleToStr(SellEntry, Digits)+ ", TP1: "+ DoubleToStr(SellTP1, Digits)+ ", SL: "+ DoubleToStr(SellSL, Digits)+ NL);
  }

  //-----------------------

  // manage open trades even when outside trading hours;
  // however, we won't open new trades
  GetAggregatePosition();
  if (TradesOpen > 0) {
    //-----------------------
      ManageOpenTrades();
    //-----------------------
  }
    
  if (!TradeHour)
  {
     if (TradingStatus != Status_finished) {
       _Alert (Status_finished+" Session End at "+DoubleToStr(TradingEndHHMM/100,2));
     }
     TradingStatus = Status_finished;
     DisplayUserFeedback();
     return;
  }//if (!TradeHour)

  //-----------------------

  GetTradingStatus();
  if (TradingStatus == Status_not_trading)
  {
    DisplayUserFeedback();
    return;
  }

  //-----------------------

  // eventually recompute box and levels values, they may have been altered by ManageOpenTrades();
  compute_LB_Indi_LEVELS(TimeCurrent());

  // open new trades if conditions are met
  if (TradesOpenThisSession == 0) {
    //-----------------------
      CheckForOpen();
    //-----------------------
  }

  //-----------------------

  DisplayUserFeedback();
  return(0);

}//End start()

//+------------------------------------------------------------------+
void compute_LB_Indi_LEVELS(datetime now)
//+------------------------------------------------------------------+
{
  int boxStartShift,boxEndShift;

  if (tBoxEnd <= now && now < tBoxEnd+86400) return; // box is less than 24h in the past: it is up-to-date

//  if (now >= tSessionStart && now <= tSessionEnd) return; // box already up-to-date, no need to recompute

  //determine box and session times 
  tBoxStart = StrToTime(TimeToStr(now,TIME_DATE) + " "  + StartTime);
  tBoxEnd   = StrToTime(TimeToStr(now,TIME_DATE) + " "  + EndTime);
  if (tBoxStart > tBoxEnd) tBoxStart -= 86400; // midnight wrap fix
  if (now < tBoxEnd) { // consider the last PAST box
    tBoxStart -= 86400;
    tBoxEnd   -= 86400;
    while ((TimeDayOfWeek(tBoxStart)==0 || TimeDayOfWeek(tBoxStart)==6)
        && (TimeDayOfWeek(tBoxEnd)==0 || TimeDayOfWeek(tBoxEnd)==6) ) {
      // box on saturday or sunday: move back 24hours again
      tBoxStart -= 86400;
      tBoxEnd   -= 86400;
    }
  }

  tSessionStart = tBoxEnd;
  tSessionEnd = StrToTime(TimeToStr(tSessionStart,TIME_DATE) + " "  + SessionEndTime);
  if (tSessionStart > tSessionEnd) tSessionEnd = tSessionEnd + 86400; // midnight wrap fix
  //if session ends on saturday or sunday, then extend it to monday so it includes the monday morning candles
  if (TimeDayOfWeek(tSessionEnd)==6/*saturday*/) tSessionEnd += 2*86400;
  if (TimeDayOfWeek(tSessionEnd)==0/*sunday*/) tSessionEnd += 86400;
  // save the computed session start&end times to avoid recomputing them for each handled trade;
  tLastComputedSessionStart = tSessionStart;
  tLastComputedSessionEnd   = tSessionEnd;

  //determine hi/lo
  boxStartShift = iBarShift(NULL,0,tBoxStart);
  boxEndShift   = iBarShift(NULL,0,tBoxEnd);
  boxHigh = High[iHighest(NULL,0,MODE_HIGH,(boxStartShift-boxEndShift+1),boxEndShift)];
  boxLow  = Low[iLowest(NULL,0,MODE_LOW,(boxStartShift-boxEndShift+1),boxEndShift)];
  boxMedianPrice = (boxHigh+boxLow)/2;
  boxExtent = boxHigh - boxLow;

  if (boxExtent == 0) {
    _Alert("boxExtent is ZERO: remove the EA, refresh your chart and history data, then reload EA.");
    return; // no clue yet why this could ever be, but it happens sometimes!
  }

  if (boxExtent >= MaxBoxSizeInPips * pip && LimitBoxToMaxSize==true) { // box too large, but we allow to trade it at its max acceptable value
    if (StickBoxToLatestExtreme==true) {
      // adjust box parameters to "stick" it to the box high or box low, whichever comes last;
      // use M1 bars to maximize price precision
      int boxStartShiftM1 = iBarShift(NULL,PERIOD_M1,tBoxStart);
      int boxEndShiftM1   = iBarShift(NULL,PERIOD_M1,tBoxEnd);
      int boxHighShift    = iHighest(NULL,PERIOD_M1,MODE_HIGH,(boxStartShiftM1-boxEndShiftM1+1),boxEndShiftM1);
      int boxLowShift     = iLowest(NULL,PERIOD_M1,MODE_LOW,(boxStartShiftM1-boxEndShiftM1+1),boxEndShiftM1);
      boxExtent = MaxBoxSizeInPips * pip;

      if (boxHighShift <= boxLowShift) {
        // box high is more recent than box low: stick box to highest price
        boxMedianPrice = boxHigh - boxExtent/2;
      } else {
        // box low is more recent than box high: stick box to lowest price
        boxMedianPrice = boxLow + boxExtent/2;
      }
    } else {
      // adjust box parameters to recenter it on the EMA(box_time_range) value
      boxExtent      = MaxBoxSizeInPips * pip;
      boxMedianPrice = iMA(NULL,0,boxStartShift-boxEndShift,0,MODE_EMA,PRICE_MEDIAN,boxEndShift);
    }
  }
  
  //apply LevelsResizeFactor to the box extent
  boxExtent *= LevelsResizeFactor;
  //recompute box hi/lo prices based on adjusted median price and extent
  boxHigh = NormalizeDouble(boxMedianPrice + boxExtent/2,Digits);
  boxLow  = NormalizeDouble(boxMedianPrice - boxExtent/2,Digits);

  //restore input Factors;
  TP1Factor = TP1FactorInput;
  TP3Factor = TP3FactorInput;
  TP5Factor = TP5FactorInput;
  SLFactor  = SLFactorInput;

  //compute breakout levels
  BuyEntry  = boxHigh;
  SellEntry = boxLow;

  // when a Factor is >=10, it is considered as FIXED PIPs rather than a Factor of the box size;
  if (TP1Factor < 10) TP1_pips = boxExtent*TP1Factor/pip;
  else { TP1_pips = TP1Factor; TP1Factor = TP1_pips*pip/boxExtent; }
  BuyTP1  = NormalizeDouble(BuyEntry  + TP1_pips*pip,Digits);
  SellTP1 = NormalizeDouble(SellEntry - TP1_pips*pip,Digits);

  BuyTP2 = 0; SellTP2 = 0;
  BuyTP3 = 0; SellTP3 = 0;
  if (TP3Factor>0) { // Trades 2&3 enabled
    if (TP3Factor < 10) TP3_pips = boxExtent*TP3Factor/pip;
    else { TP3_pips = TP3Factor; TP3Factor = TP3_pips*pip/boxExtent; }
    BuyTP3  = NormalizeDouble(BuyEntry  + TP3_pips*pip,Digits);
    SellTP3 = NormalizeDouble(SellEntry - TP3_pips*pip,Digits);

    TP2Factor = (TP1Factor+TP3Factor)/2;
    if (TP2Factor < 10) TP2_pips = boxExtent*TP2Factor/pip;
    else { TP2_pips = TP2Factor; TP2Factor = TP2_pips*pip/boxExtent; }
    BuyTP2  = NormalizeDouble(BuyEntry  + TP2_pips*pip,Digits);
    SellTP2 = NormalizeDouble(SellEntry - TP2_pips*pip,Digits);
  }
  
  BuyTP4 = 0; SellTP4 = 0;
  BuyTP5 = 0; SellTP5 = 0;
  if (TP5Factor>0) { // Trades 4&5 enabled
    if (TP5Factor < 10) TP5_pips = boxExtent*TP5Factor/pip;
    else { TP5_pips = TP5Factor; TP5Factor = TP5_pips*pip/boxExtent; }
    BuyTP5  = NormalizeDouble(BuyEntry  + TP5_pips*pip,Digits);
    SellTP5 = NormalizeDouble(SellEntry - TP5_pips*pip,Digits);

    TP4Factor = (TP3Factor+TP5Factor)/2;
    if (TP4Factor < 10) TP4_pips = boxExtent*TP4Factor/pip;
    else { TP4_pips = TP4Factor; TP4Factor = TP4_pips*pip/boxExtent; }
    BuyTP4  = NormalizeDouble(BuyEntry  + TP4_pips*pip,Digits);
    SellTP4 = NormalizeDouble(SellEntry - TP4_pips*pip,Digits);
  }

  if (SLFactor < 10) SL_pips = boxExtent*SLFactor/pip;
  else { SL_pips = SLFactor; SLFactor = SL_pips*pip/boxExtent; }
  BuySL  = NormalizeDouble(BuyEntry  - SL_pips*pip,Digits);
  SellSL = NormalizeDouble(SellEntry + SL_pips*pip,Digits);

  if (MoveToBEFactor <= 1) MoveToBE_pips = MoveToBEFactor * TP1_pips;
  else MoveToBE_pips = MoveToBEFactor;

}//compute_LB_Indi_LEVELS


//+------------------------------------------------------------------+
void show_boxes(datetime now)
//+------------------------------------------------------------------+
{
  // show session period with a different "background" color
  bool new_box = drawBoxOnce (objPrefix+"Session-"+TimeToStr(tSessionStart,TIME_DATE | TIME_SECONDS),tSessionStart,0,tSessionEnd,BuyEntry*2,SessionColor,1, STYLE_SOLID, true);

  // draw pre-breakout box blue/red once per Session:
  if (new_box == true) {
    // draw pre-breakout box blue/red:
    string boxName = objPrefix+"Box-"+TimeToStr(now,TIME_DATE)+"-"+StartTime+"-"+EndTime;
    if (boxExtent >= MaxBoxSizeInPips * pip) { // box too large: DON'T TRADE !
      if (LimitBoxToMaxSize==false) { // box too large, but we allow to trade it at its max acceptable value
        drawBox (boxName,tBoxStart,boxLow,tBoxEnd,boxHigh,BoxColorNOK,1, STYLE_SOLID, true);
        DrawLbl(objPrefix+"Lbl-"+TimeToStr(now,TIME_DATE)+"-"+StartTime+"-"+EndTime, "NO TRADE! ("+DoubleToStr(boxExtent/pip,0)+"p)", tBoxStart+(tBoxEnd-tBoxStart)/2,boxLow, 12, "Arial Black", LevelColor, 3);
      } else {
        drawBox (boxName,tBoxStart,boxLow,tBoxEnd,boxHigh,BoxColorMAX,1, STYLE_SOLID, true);
        DrawLbl(objPrefix+"Lbl-"+TimeToStr(now,TIME_DATE)+"-"+StartTime+"-"+EndTime, "MAX LIMIT! ("+DoubleToStr(boxExtent/pip,0)+"p)", tBoxStart+(tBoxEnd-tBoxStart)/2,boxLow, 12, "Arial Black", LevelColor, 3);
      }
    } else if (boxExtent >= MinBoxSizeInPips * pip) { // box OK
      drawBox (boxName,tBoxStart,boxLow,tBoxEnd,boxHigh,BoxColorOK,1, STYLE_SOLID, true);
      DrawLbl(objPrefix+"Lbl-"+TimeToStr(now,TIME_DATE)+"-"+StartTime+"-"+EndTime, DoubleToStr(boxExtent/pip,0)+"p", tBoxStart+(tBoxEnd-tBoxStart)/2,boxLow, 12, "Arial Black", LevelColor, 3);
    } else { // "Caution!" box
      drawBox (boxName,tBoxStart,boxLow,tBoxEnd,boxHigh,BoxColorNOK,1, STYLE_SOLID, true);
      DrawLbl(objPrefix+"Lbl-"+TimeToStr(now,TIME_DATE)+"-"+StartTime+"-"+EndTime, "Caution! ("+DoubleToStr(boxExtent/pip,0)+"p)", tBoxStart+(tBoxEnd-tBoxStart)/2,boxLow, 12, "Arial Black", BoxColorNOK, 3);
    }

    // draw profit/loss boxes for the session
    if (showProfitZone) {
      double UpperTP,LowerTP;
      if (TP5Factor>0) {// draw TP4 and TP5 optional targets
        UpperTP = BuyTP5;
        LowerTP = SellTP5;
      } else {// draw only up to TP3
        UpperTP = BuyTP3;
        LowerTP = SellTP3;
      }
      drawBox (objPrefix+"BuyProfitZone-" +TimeToStr(tSessionStart,TIME_DATE),tSessionStart,BuyTP1,tSessionEnd,UpperTP,ProfitColor,1, STYLE_SOLID, true);
      drawBox (objPrefix+"SellProfitZone-"+TimeToStr(tSessionStart,TIME_DATE),tSessionStart,SellTP1,tSessionEnd,LowerTP,ProfitColor,1, STYLE_SOLID, true);
    }

    // draw "fib" lines for entry+stop+TP levels:
    string objname = objPrefix+"Fibo-" + tBoxEnd;
    ObjectCreate(objname,OBJ_FIBO,0,tBoxStart,SellEntry,tBoxStart+FibLength*60*10,BuyEntry);
    ObjectSet(objname,OBJPROP_RAY,false);
    ObjectSet(objname,OBJPROP_LEVELCOLOR,LevelColor); 
    ObjectSet(objname,OBJPROP_FIBOLEVELS,12);
    ObjectSet(objname,OBJPROP_LEVELSTYLE,STYLE_SOLID);
    _SetFibLevel(objname,0,0.0,"Entry Buy= %$");  
    _SetFibLevel(objname,1,1.0,"Entry Sell= %$");
    _SetFibLevel(objname,2,-TP1Factor, "Buy Target 1= %$  (+"+DoubleToStr(TP1_pips,0)+"p)");
    _SetFibLevel(objname,3,1+TP1Factor,"Sell Target 1= %$  (+"+DoubleToStr(TP1_pips,0)+"p)");
    if (TP3Factor>0) {
      _SetFibLevel(objname,4,-TP2Factor, "Buy Target 2= %$  (+"+DoubleToStr(TP2_pips,0)+"p)");
      _SetFibLevel(objname,5,1+TP2Factor,"Sell Target 2= %$  (+"+DoubleToStr(TP2_pips,0)+"p)");
      _SetFibLevel(objname,6,-TP3Factor, "Buy Target 3= %$  (+"+DoubleToStr(TP3_pips,0)+"p)");
      _SetFibLevel(objname,7,1+TP3Factor,"Sell Target 3= %$  (+"+DoubleToStr(TP3_pips,0)+"p)");
    }
    if (TP5Factor>0) {// draw TP4 and TP5 optional targets
      _SetFibLevel(objname,8,-TP4Factor, "Buy Target 4= %$  (+"+DoubleToStr(TP4_pips,0)+"p)");
      _SetFibLevel(objname,9,1+TP4Factor,"Sell Target 4= %$  (+"+DoubleToStr(TP4_pips,0)+"p)");
      _SetFibLevel(objname,10,-TP5Factor, "Buy Target 5= %$  (+"+DoubleToStr(TP5_pips,0)+"p)");
      _SetFibLevel(objname,11,1+TP5Factor,"Sell Target 5= %$  (+"+DoubleToStr(TP5_pips,0)+"p)");
    }
  }

}//show_boxes()

//+------------------------------------------------------------------+
void _SetFibLevel(string objname, int level, double value, string description)
//+------------------------------------------------------------------+
{
    ObjectSet(objname,OBJPROP_FIRSTLEVEL+level,value);
    ObjectSetFiboDescription(objname,level,description);
}

//+------------------------------------------------------------------+
void CheckForOpen()
//+------------------------------------------------------------------+
{
  double lotsToTrade,TP_pips;

  //Max trades filter
  if (MaxTradesAllowedPerSession > 0)// 0 means unlimited trades
  {                
    if (TradesTotal >= MaxTradesAllowedPerSession) 
    {
      if (TradingStatus != Status_finished) {
        _Alert (Status_finished+"Reached Max Trades at "+TimeToStr(TimeCurrent(),TIME_SECONDS));
      }
      TradingStatus = Status_finished;
      return;
   }
  }

  //Max loss filter
  if (MaxLossesAllowedPerSession > 0)
  {
    if (TradesLost >= MaxLossesAllowedPerSession*NumTradesToOpen)
    {
      if (TradingStatus != Status_finished) {
        _Alert (Status_finished+"Reached MAX LOSSES at "+TimeToStr(TimeCurrent(),TIME_SECONDS));
      }
      TradingStatus = Status_finished;
      return;
    }
  }

  //Max win filter
  if (MaxWinsAllowedPerSession > 0)
  {
    if (TradesWon >= MaxWinsAllowedPerSession*NumTradesToOpen) 
    {
      if (TradingStatus != Status_finished) {
        _Alert (Status_finished+"Reached MAX WINS at "+TimeToStr(TimeCurrent(),TIME_SECONDS));
      }
      TradingStatus = Status_finished;
      return;
    }
  }


  if (IsTradeAllowed())
  {                    
    TradingStatus = Status_trading;
    
    switch (NumTradesToOpen) {
      case 1: TP_pips = TP1_pips; break;// only 1 trade per series
      case 3: TP_pips = 3*TP2_pips; break;// 3 trades per series
      default:TP_pips = 5*TP4_pips; break;// 5 trades per series
    }

    //buy(sell) on Buy(Sell)Entry crossup(down);
    //Strategy suggests to re-enter only once a (M15) candle closes inside the box.

    GetRates();
    //buy on BuyEntry crossup: (make sure price is still closer to Entry than TP1, to allow a minimum profit, and keep SL as low as possible)
    if (iClose(NULL,TFforReentry,1) <= BuyEntry && Ask >= BuyEntry && Ask < (BuyEntry+BuyTP1)/2) {
      lotsToTrade = get_lotsToTrade(magic1, TP_pips,SL_pips);
      _OrderSend(symbol,OP_BUY,lotsToTrade,Ask,SLIPPAGE,BuySL, BuyTP1,TradeComment,magic1,0,Blue);
      if (NumTradesToOpen>=2) {
        GetRates();
        _OrderSend(symbol,OP_BUY,lotsToTrade,Ask,SLIPPAGE,BuySL, BuyTP2,TradeComment,magic2,0,Blue);
      }
      if (NumTradesToOpen>=3) {
        GetRates();
        _OrderSend(symbol,OP_BUY,lotsToTrade,Ask,SLIPPAGE,BuySL, BuyTP3,TradeComment,magic3,0,Blue);
      }
      if (NumTradesToOpen>=4) {
        GetRates();
        _OrderSend(symbol,OP_BUY,lotsToTrade,Ask,SLIPPAGE,BuySL, BuyTP4,TradeComment,magic4,0,Blue);
      }
      if (NumTradesToOpen>=5) {
        GetRates();
        _OrderSend(symbol,OP_BUY,lotsToTrade,Ask,SLIPPAGE,BuySL, BuyTP5,TradeComment,magic5,0,Blue);
      }
    }
    else //sell on SellEntry crossdown:
    if (iClose(NULL,TFforReentry,1) >= SellEntry && Bid <= SellEntry && Bid > (SellEntry+SellTP1)/2) {
      lotsToTrade = get_lotsToTrade(magic1, TP_pips,SL_pips);
      _OrderSend(symbol,OP_SELL,lotsToTrade,Bid,SLIPPAGE,SellSL, SellTP1,TradeComment,magic1,0,Blue);
      if (NumTradesToOpen>=2) {
        GetRates();
        _OrderSend(symbol,OP_SELL,lotsToTrade,Bid,SLIPPAGE,SellSL, SellTP2,TradeComment,magic2,0,Blue);
      }
      if (NumTradesToOpen>=3) {
        GetRates();
        _OrderSend(symbol,OP_SELL,lotsToTrade,Bid,SLIPPAGE,SellSL, SellTP3,TradeComment,magic3,0,Blue);
      }
      if (NumTradesToOpen>=4) {
        GetRates();
        _OrderSend(symbol,OP_SELL,lotsToTrade,Bid,SLIPPAGE,SellSL, SellTP4,TradeComment,magic4,0,Blue);
      }
      if (NumTradesToOpen>=5) {
        GetRates();
        _OrderSend(symbol,OP_SELL,lotsToTrade,Bid,SLIPPAGE,SellSL, SellTP5,TradeComment,magic5,0,Blue);
      }
    }
  }

}//CheckForOpen

//+------------------------------------------------------------------+
void ManageOpenTrades()
//+------------------------------------------------------------------+
{
  int magic,cc,last_closed_ticket1=0;
  double initialSL;
  datetime last_closed_opentime1;

  //find last closed trade#1 in trades history; start from last history trade=latest
  for (cc = OrdersHistoryTotal()-1; cc >= 0; cc--)
  {      
    OrderSelect(cc, SELECT_BY_POS, MODE_HISTORY);
    if (OrderMagicNumber()==magic1 && OrderSymbol()==symbol && OrderType()<=OP_SELL) {
      last_closed_ticket1   = OrderTicket();
      last_closed_opentime1 = OrderOpenTime();
      break;
    }
  }

  // manage open trades
  for (cc = OrdersTotal() - 1; cc >=0; cc--)
  {
    if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
    magic = OrderMagicNumber();
    if (OrderSymbol() == symbol && OrderCloseTime() == 0)
    {
      if (OrderOpenTime() < tSessionStart || OrderOpenTime() > tSessionEnd) {
        // this trade belongs to a different box/session:
        // we must recompute the corresponding box and levels values to handle it properly
        compute_LB_Indi_LEVELS(OrderOpenTime());
      }

      // other trades will see their SL follow the TP levels each time a new TP level is hit:
      // when TP2 hit, move all SL to TP1+BEprofit, when TP3 is hit, move SL to TP2+BEprofit, etc.
      if (MoveSLwhenProfit(MoveToBE_pips, BreakEvenProfitInPips)) continue;
      if (MoveSLwhenProfit(TP2_pips, TP1_pips)) continue;
      if (MoveSLwhenProfit(TP3_pips, TP2_pips)) continue;
      if (MoveSLwhenProfit(TP4_pips, TP3_pips)) continue;
      if (MoveSLwhenProfit(TP5_pips, TP4_pips)) continue;
    }
  }

}//ManageOpenTrades()

//+------------------------------------------------------------------+
bool MoveSLwhenProfit(int profit_pips_target, int pips_to_lock)
//+------------------------------------------------------------------+
{
  // returns true if SL was moved
  //Lock-in some profit after a minimum profit target is reached:
  double SL;

  if (profit_pips_target <= 0) return (false);
  if ( OrderType() == OP_BUY  && Bid >= OrderOpenPrice()+profit_pips_target*pip ) {
    SL = NormalizeDouble(OrderOpenPrice() + pips_to_lock*pip, Digits);
    if (SL>NormalizeDouble(OrderStopLoss(),Digits)) {
      _Alert(" #"+OrderTicket()+" ("+OrderMagicNumber()+") moving to BE+"+pips_to_lock+"pips");
      _OrderModify(OrderTicket(), OrderOpenPrice(), SL, OrderTakeProfit(), OrderExpiration(), Green);
      return (true);
    }
  }
  if ( OrderType() == OP_SELL && Ask <= OrderOpenPrice()-profit_pips_target*pip ) {
    SL = NormalizeDouble(OrderOpenPrice() - pips_to_lock*pip, Digits);
    if (SL<NormalizeDouble(OrderStopLoss(),Digits)) {
      _Alert(" #"+OrderTicket()+" ("+OrderMagicNumber()+") moving to BE+"+pips_to_lock+"pips");
      _OrderModify(OrderTicket(), OrderOpenPrice(), SL, OrderTakeProfit(), OrderExpiration(), Green);
      return (true);
    }
  }
  return (false);
}

//+------------------------------------------------------------------+
double get_lotsToTrade(int magic, int TP_pips, int SL_pips)
//+------------------------------------------------------------------+
{
  double lotsToTrade,profitpips=0,currentProfit=0,pips_to_recoup=0,factor=1,last_trade_profit=0;
  int last_ticket=0;

  if (!UseMartingale)
  {
    //adjust Lot based on MaxRisk and SL value
    if (MaxRisk > 0) return (MathMin(Lot,GetMaxLot(SL_pips,MaxRisk)));
    else return (Lot);
  }

  // if orders are still open, then use the same multiplier as the open trades
  // except for non-auto-martingale mode: use the PREVIOUS (lower) multiplier
  if (TradesOpen>0) {
    if (!AutoMartingale && MartDepth>0 && LastLotMultiplier>1) { 
      // non auto-martingale: use PREVIOUS multiplier
      for (Mart_Idx=0; Mart_Idx < MartDepth-1; Mart_Idx++) {
        if (MartFactor[Mart_Idx] >= LastLotMultiplier) break;// found current multiplier
      }
      Mart_Idx--; // use PREVIOUS multiplier
      Print ("### Trades still open, using PREVIOUS MartFactor=",MartFactor[Mart_Idx]);
      return (MartFactor[Mart_Idx] * Lot);
    } else {
      Print ("### Trades still open, using same MartFactor=",LastLotMultiplier);
      return (LastLotMultiplier * Lot);
    }
  }

  // No open trades;
  // Martingale is used: determine the martingale factor based on results of last trades
  //cumulate past profits/losses
  //search trade history for past trades, start from end of history(=newest trades)
  //if no past buy/sell trade can be found, then the mart factor will not change;
  for (int cc = OrdersHistoryTotal()-1; cc >= 0; cc--)
  {      
    OrderSelect(cc, SELECT_BY_POS, MODE_HISTORY);
    if (OrderMagicNumber()!=magic1 && OrderMagicNumber()!=magic2 && OrderMagicNumber()!=magic3 && OrderMagicNumber()!=magic4 && OrderMagicNumber()!=magic5) continue;
    if (OrderSymbol()!=symbol || OrderType()>OP_SELL) continue;
    if (last_ticket==0) {
      last_ticket = OrderTicket(); 
      factor = MathFloor(OrderLots()/Lot + 0.5); // compute nearest integer value to prevent division approximation
      last_trade_profit = OrderProfit();
    }
    profitpips = (OrderClosePrice()-OrderOpenPrice())/pip*OrderLots()/Lot;
    if (OrderType()==OP_SELL) profitpips = -profitpips;
    //OrderProfit()/pipvalue/Lot;
    currentProfit += profitpips;
    //if (maxProfit < currentProfit) maxProfit = currentProfit;
    if (Debug) Print ("   #",OrderTicket()," profit = ",DoubleToStr(OrderLots()/Lot,0)," x ",profitpips/(OrderLots()/Lot)," = ",profitpips,"pips, currentProfit=",currentProfit,"pips");
    // we stop scanning past trades when we have reached the first trade of the last series, ie the trade with a factor of 1
    if (OrderMagicNumber()==magic1 && OrderLots()==Lot) break;
  }

  // if no pips to recoup, then go back to initial Lot size
  if (currentProfit >= 0) {
    Print ("###  Current Profit=",currentProfit,"pips; No pips to recoup, MartFactor=1");
    Mart_Idx = 0;//reset mart sequence
    return (Lot);
  }

  // when ResetMartAtFirstProfit option is true, then reset the Mart sequence at the first profitable trade;
  if (ResetMartAtFirstProfit==true && last_trade_profit>=0) {
    Print ("###  Current Profit=",currentProfit,"pips; No pips to recoup, MartFactor=1");
    Mart_Idx = 0;//reset mart sequence
    return (Lot);
  }

  // there are pips to recoup, compute the next Mart factor
  pips_to_recoup = -currentProfit;

  if (AutoMartingale) { // auto-martingale: recoup past losses, and add current TP
    factor = (pips_to_recoup+TP_pips) / TP_pips;
    if (factor<2) factor = 2; // prevent using factor=1 when martingaling
    
  } else { // use fixed Martingale sequence: move to next mart factor

    // if the last "series" was in profit, then don't change the multiplier
    if (last_trade_profit>=0) {
      factor = MartFactor[Mart_Idx];
      Print ("### Last trade in profit, using same MartFactor=",factor);
    } else {
      // move to next multiplier
      for (Mart_Idx=0; Mart_Idx < MartDepth-1; Mart_Idx++) {
        if (MartFactor[Mart_Idx] > factor) break;
      }
      factor = MartFactor[Mart_Idx];
    }
  }

  if (AutoMartingale) {
    Print ("### AutoMartingale: ",pips_to_recoup," pips to recoup, +",TP_pips," pips TP => MartFactor is ", factor);
  } else {
    Print ("### ",pips_to_recoup," pips to recoup, now using MartFactor[",Mart_Idx,"]=",factor);
  }
  
  return (Lot*factor);

}//get_lotsToTrade()

//+------------------------------------------------------------------+
double GetMaxLot(int SL, double Risk)
//+------------------------------------------------------------------+
{
  double lotsize,tickvalue,pipvaluefor1lot,SLfor1lotfor1percent,maxLot;
  lotsize   = MarketInfo(Symbol(),MODE_LOTSIZE);
  tickvalue = MarketInfo(Symbol(),MODE_TICKVALUE);
  pipvaluefor1lot = lotsize*tickvalue*pip;
  maxLot    = NormalizeDouble(AccountFreeMargin()*Risk/100/pipvaluefor1lot/SL,2);
  return(maxLot);
}

//+------------------------------------------------------------------+
void GetAggregatePosition()
//+------------------------------------------------------------------+
{
  int magic;
   //returns the total trades for the pair - TradesOpen, TradesWon, TradesLost
   
   TradesOpen = 0;
   TradesOpenThisSession = 0;
   TradesWon = 0;
   TradesLost = 0;
   TradesTotal = 0;
   LastLotMultiplier = 0;
   
   //Count Open trades
   if (OrdersTotal() > 0)
   {
      for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
      {      
         if (!OrderSelect(cc, SELECT_BY_POS, MODE_TRADES) ) continue;
         magic = OrderMagicNumber();
         if ((magic==magic1 || magic==magic2 || magic==magic3 || magic==magic4 || magic==magic5) && OrderSymbol() == symbol && OrderCloseTime() == 0)
         {
            TradesOpen++;
            if (OrderOpenTime() >= tSessionStart) {
              TradesOpenThisSession++;
            }
            if (LastLotMultiplier == 0) LastLotMultiplier = OrderLots()/Lot;
         }
      }
   }
   
   //Count won/lost trades in the past 24 hours from trades History
   for (cc = OrdersHistoryTotal() - 1; cc >= 0; cc--)
   {      
      OrderSelect(cc, SELECT_BY_POS, MODE_HISTORY);
      magic = OrderMagicNumber();
      if ((magic==magic1 || magic==magic2 || magic==magic3 || magic==magic4 || magic==magic5) && OrderSymbol() == symbol)
      {
        if (OrderCloseTime()<tBoxEnd) break;// past 24 hours, stop counting;
        if (OrderProfit() < 0) TradesLost++;
        if (OrderProfit() > 0) TradesWon++;         
        if (LastLotMultiplier == 0) LastLotMultiplier = OrderLots()/Lot;
      }
   }
   
   TradesTotal = TradesOpen + TradesLost + TradesWon;
   if (LastLotMultiplier == 0) LastLotMultiplier = 1;

}//void GetAggregatePosition()

//+------------------------------------------------------------------+
void GetTradingStatus()
//+------------------------------------------------------------------+
{
   //The initial trade stops are the extent of the box
   
  if (MinBoxSizeInPips > 0 && boxExtent < MinBoxSizeInPips * pip) TradingStatus = Status_not_trading;
  if (LimitBoxToMaxSize==false && MaxBoxSizeInPips > 0 && boxExtent > MaxBoxSizeInPips * pip) TradingStatus = Status_not_trading;

}//End void GetTradingStatus()

/*
//+------------------------------------------------------------------+
bool BreakEvenStopLoss(int profit_pips_target, int pips_to_lock)
//+------------------------------------------------------------------+
{
  //Lock-in some profit after a minimum profit target is reached:
  //(move SL to BE+pips_to_lock)
  double SL;
   
  //Long
  if (OrderType() == OP_BUY && Bid >= OrderOpenPrice()+profit_pips_target*pip && OrderStopLoss() < OrderOpenPrice()) {
    SL = NormalizeDouble(OrderOpenPrice() + (pips_to_lock*pip), Digits);
    _Alert(" #"+OrderTicket()+" moving to BE+"+pips_to_lock+"pips");
    _OrderModify(OrderTicket(), OrderOpenPrice(), SL, OrderTakeProfit(), OrderExpiration(), Green);
    return(true);
  }
   
  //Short
  if (OrderType() == OP_SELL && Ask <= OrderOpenPrice()-profit_pips_target*pip && (OrderStopLoss() > OrderOpenPrice() || OrderStopLoss()==0)) {
    SL = NormalizeDouble(OrderOpenPrice() - (pips_to_lock*pip), Digits);
    _Alert(" #"+OrderTicket()+" moving to BE+"+pips_to_lock+"pips");
    _OrderModify(OrderTicket(), OrderOpenPrice(), SL, OrderTakeProfit(), OrderExpiration(), Green);
    return(true);
  }

  return(false);//did not move to BE
   
}//BreakEvenStopLoss()
*/

/*
//+------------------------------------------------------------------+
void Trail_order(int _TrailingStopPips, int _TrailingStopStep)
//+------------------------------------------------------------------+
{
  if (_TrailingStopPips<=0) return;
  if (_TrailingStopStep>_TrailingStopPips) return;
  if (MathAbs(OrderStopLoss()-OrderClosePrice()) > (_TrailingStopPips+_TrailingStopStep)*pip) {										    
    if (OrderType() == OP_BUY)  _OrderModify(OrderTicket(),OrderOpenPrice(),OrderClosePrice()-_TrailingStopPips*pip,OrderTakeProfit(),OrderExpiration(),Purple);
    if (OrderType() == OP_SELL) _OrderModify(OrderTicket(),OrderOpenPrice(),OrderClosePrice()+_TrailingStopPips*pip,OrderTakeProfit(),OrderExpiration(),Purple);
  }
}
*/

//+------------------------------------------------------------------+
bool GetRates()
//+------------------------------------------------------------------+
{
  bool ret = RefreshRates();
  //remember Ask/Bid changes -- used to detect levels crossing
  if (currentAsk != previousAsk || currentBid != previousBid) {
    previousAsk = currentAsk;
    previousBid = currentBid;
  }
  currentAsk = Ask; currentBid = Bid;
  return(ret);
}//GetRates()


//+------------------------------------------------------------------+
int _OrderSend(string symbol, int type, double lots, double price, int slippage, double stoploss, double takeprofit, string comment, int magic, datetime expiration, color arrow_color)
//+------------------------------------------------------------------+
{
#define MAX_RETRIES 10
//"reliable" version of OrderSend(): will retry 10 times before failing
  int i,j,err,ticket;
  
  // Make sure Spread is not too large
  if (MarketInfo(symbol, MODE_SPREAD) > MaxSpread) {
    _Alert("Order was NOT SENT because SPREAD is TOO HIGH ("+DoubleToStr(MarketInfo(symbol, MODE_SPREAD)/pipMult,1)+")");
    return(-1);
  }

  for (i=0;i<MAX_RETRIES;i++) {
    for (j=0;j<MAX_RETRIES && !IsTradeAllowed();j++) Sleep(500); // wait for Trade to be allowed(free context)
    if (j==MAX_RETRIES) {
      _Alert("OrderSend() FAILED: trade not allowed");
      return (-1);
    }

    // send order with 0 SL, then modify order to apply SL -- a common counter-ECN method found in SteveHopwood's bots...
    if (!brokerIsECN) {
      ticket = OrderSend(symbol, type, lots, price, slippage, stoploss, takeprofit, comment, magic, expiration, arrow_color);
      if (ticket != -1) return (ticket);
    } else {
      ticket = OrderSend(symbol, type, lots, price, slippage, 0/*stoploss*/, 0/*takeprofit*/, comment, magic, expiration, arrow_color);
      if (ticket != -1) {
        if (stoploss!=0 || takeprofit!=0) {
          Sleep(2000);//wait before modifying the open order
          _OrderModify(ticket, price, stoploss, takeprofit, expiration, arrow_color);
        }
        return(ticket);//success
      }
    }
    err = GetLastError();
    switch (err) {
      case ERR_INVALID_STOPS:        break;//130=invalid stops: SL or TP are set too close to open price;
      case ERR_INVALID_TRADE_VOLUME: break;//131=invalid trade volume: lot size is too small, or does not follow the LOTSTEP value (eg 0.12 lots for a 0.1 LOTSTEP account);
    }
  }
  _Alert("OrderSend() FAILED: "+DoubleToStr(lots,2)+" lots at "+DoubleToStr(price,Digits)+",SL="+DoubleToStr(stoploss,Digits)+",TP="+DoubleToStr(takeprofit,Digits)+",Ask="+DoubleToStr(Ask,Digits)+" ("+err+"): "+ErrorDescription(err));
  return(-1);
}

//+------------------------------------------------------------------+
bool _OrderModify(int ticket, double price, double stoploss, double takeprofit, datetime expiration, color arrow_color) 
//+------------------------------------------------------------------+
{
//"reliable" version of OrderModify(): will retry 10 times before failing
  int i,j,err,ret;
  
  for (i=0;i<MAX_RETRIES;i++) {
    for (j=0;j<MAX_RETRIES && !IsTradeAllowed();j++) Sleep(500); // wait for Trade to be allowed(free context)
    if (j==MAX_RETRIES) {
      _Alert("OrderModify(#"+ticket+") FAILED: trade not allowed");
      return(false);
    }

    ret = OrderModify(ticket, price, stoploss, takeprofit, expiration, arrow_color); 
    if (ret == true) return(true);//success
    err = GetLastError();
    switch (err) {
      case ERR_NO_RESULT:    // error 1 means OrderModify() was called with unchanged values
      case ERR_INVALID_STOPS:// error 130 "invalid stops" when SL is set too close to current price
      case ERR_INVALID_TRADE_VOLUME://131=invalid trade volume: lot size is too small, or does not follow the LOTSTEP value (eg 0.12 lots for a 0.1 LOTSTEP account);
        return(true);
    }
  }

  _Alert("OrderModify(#"+ticket+") FAILED ("+err+"): "+ErrorDescription(err));
  return(false);
}

/*
//+------------------------------------------------------------------+
bool _OrderClose( int ticket, double lots, double price, int slippage, color Color) 
//+------------------------------------------------------------------+
{
//"reliable" version of OrderClose(): will retry 10 times before failing
  int i,j,err;
  bool ret;
  
  for (i=0;i<MAX_RETRIES;i++) {
    for (j=0;j<MAX_RETRIES && !IsTradeAllowed();j++) Sleep(500); // wait for Trade to be allowed(free context)
    if (j==MAX_RETRIES) {
      _Alert("OrderClose(#"+ticket+") FAILED: trade not allowed");
      return(false);
    }

    ret = OrderClose(ticket, lots, price, slippage, Color);
    if (ret == true) return(true);//success
  }

  err = GetLastError();
  _Alert("OrderClose(#"+ticket+") FAILED ("+err+"): "+ErrorDescription(err));
  return(false);
}
*/

/*
//+------------------------------------------------------------------+
bool _OrderDelete(int ticket, color Color) 
//+------------------------------------------------------------------+
{
//"reliable" version of OrderDelete(): will retry 10 times before failing
  int i,j,err;
  bool ret;
  
  for (i=0;i<MAX_RETRIES;i++) {
    for (j=0;j<MAX_RETRIES && !IsTradeAllowed();j++) Sleep(500); // wait for Trade to be allowed(free context)
    if (j==MAX_RETRIES) {
      _Alert("OrderDelete(#"+ticket+") FAILED: trade not allowed");
      return(false);
    }

    ret = OrderDelete(ticket, Color);
    if (ret == true) return(true);//success
  }

  err = GetLastError();
  _Alert("OrderDelete(#"+ticket+") FAILED ("+err+"): "+ErrorDescription(err));
  return(false);
}
*/

//+------------------------------------------------------------------+
int create_MagicNumber(string s)
//+------------------------------------------------------------------+
{
  // create a magic number that is "unique" for a given {EA_name,Symbol,Period} combo
  int magic=0;
  s = s+WindowExpertName()+Symbol()+Period()+objPrefix;
  magic = hash_string(s);
  while (magic < 10000) {// magic number is not long enough, make another one
    s = s+magic;
    magic = hash_string(s);
  }
  return (magic);
}

//+------------------------------------------------------------------+
int hash_string(string s)
//+------------------------------------------------------------------+
{
  // this is the djb2 string hash algo
  int h = 5381, l = StringLen(s), i;
  for (i=0; i<l; i++) h = h * 33 + StringGetChar(s,i);
  return (h);
} /*hash_string()*/


//+------------------------------------------------------------------+
void getpip()
//+------------------------------------------------------------------+
{
  pipMult = (Digits==2||Digits==4)+10*(Digits==3||Digits==5)+100*(Digits==6);
  pip = pipMult*Point;
	digits = 4-2*(Digits==3||Digits==2);
	
	minlot   = MarketInfo(Symbol(),MODE_MINLOT);
	lotstep  = MarketInfo(Symbol(),MODE_LOTSTEP);
  pipvalue = pipValueFor1Lot();
	
} /* getpip*/

//+------------------------------------------------------------------+
double pipValueFor1Lot()
//+------------------------------------------------------------------+
{
  double lotsize,tickvalue;
  lotsize   = MarketInfo(Symbol(),MODE_LOTSIZE);
  tickvalue = MarketInfo(Symbol(),MODE_TICKVALUE);
  return (lotsize*tickvalue*pip);
}


//--------------------------------------------------------------------------------------
int time_string_to_int(string ts)
//--------------------------------------------------------------------------------------
// convert a time string "hh:mm" into an integer hhmm
{
  string HH=ts,MM="00";
  int FindDel = StringFind(ts,":",0);
  if (FindDel>=0) {
    HH = StringSubstr(ts, 0, FindDel);
    MM = StringSubstr(ts, FindDel+1, StringLen(ts));
  }
  return(StrToInteger(HH)*100+StrToInteger(MM));
}

//--------------------------------------------------------------------------------------
int roundup_hhmm_time_to_TF (int hhmm, double tf)
//--------------------------------------------------------------------------------------
{
  double t  = hhmm; // convert to double for divisions
  double hh = MathFloor(t/100);
  double mm = (t/100-hh)*100+0.9;//+0.9 to prevent division approximation when used with MathFloor()
  mm = (MathFloor(mm/tf)+1)*tf;
  return ( (hh+MathFloor(mm/60))*100 + mm-60*MathFloor(mm/60) );
}

//--------------------------------------------------------------------------------------
void _Alert(string text)
//--------------------------------------------------------------------------------------
{
  Alert ("LB EA: ", symbol, " ", text);
}

//+------------------------------------------------------------------+
int string_list_to_double_array(string list, string sep, double &array[])
//+------------------------------------------------------------------+
{
//create an array of double from a string containing the list of values
//ex: n = string_list_to_double_array ("1,2,3,5,8" , "," , &array);

   int i=0,j,k;
   string ls;

   while (true) {
   	j=StringFind(list,sep,i);
   	if (j<0) break;

 		ls=StringTrimRight(StringTrimLeft(StringSubstr(list,i,j-i)));
 		i=j+1;
 		k++;
 		ArrayResize(array,k);
 		array[k-1]=StrToDouble(ls);
  }
  //last element in the list:
	ls=StringTrimRight(StringTrimLeft(StringSubstr(list,i)));
	k++;
	ArrayResize(array,k);
	array[k-1]=StrToDouble(ls);

  return (ArraySize(array));
}//string_list_to_double_array

//--------------------------------------------------------------------------------------
// RemoveObjects
//--------------------------------------------------------------------------------------

void RemoveObjects(string Pref)
{   
   int i;
   string objname = "";

   for (i = ObjectsTotal(); i >= 0; i--) {
      objname = ObjectName(i);
      if (StringFind(objname, Pref, 0) == 0) ObjectDelete(objname);
   }
} /* RemoveObjects*/


//--------------------------------------------------------------------------------------
// drawBox
//--------------------------------------------------------------------------------------

void drawBox (
  string objname,
  datetime tStart, double vStart, 
  datetime tEnd,   double vEnd,
  color c, int width, int style, bool bg
)
{
  if (ObjectFind(objname) == -1) {
    ObjectCreate(objname, OBJ_RECTANGLE, 0, tStart,vStart,tEnd,vEnd);
  } else {
    ObjectSet(objname, OBJPROP_TIME1, tStart);
    ObjectSet(objname, OBJPROP_TIME2, tEnd);
    ObjectSet(objname, OBJPROP_PRICE1, vStart);
    ObjectSet(objname, OBJPROP_PRICE2, vEnd);
  }

  ObjectSet(objname,OBJPROP_COLOR, c);
  ObjectSet(objname, OBJPROP_BACK, bg);
  ObjectSet(objname, OBJPROP_WIDTH, width);
  ObjectSet(objname, OBJPROP_STYLE, style);
} /* drawBox */


//--------------------------------------------------------------------------------------
// drawBoxOnce: draw a Box only once; if it already exists, do nothing
//--------------------------------------------------------------------------------------

bool drawBoxOnce (
  string objname,
  datetime tStart, double vStart, 
  datetime tEnd,   double vEnd,
  color c, int width, int style, bool bg
)
{
  if (ObjectFind(objname) != -1) return(false);//box already exists
  
  ObjectCreate(objname, OBJ_RECTANGLE, 0, tStart,vStart,tEnd,vEnd);
  ObjectSet(objname,OBJPROP_COLOR, c);
  ObjectSet(objname, OBJPROP_BACK, bg);
  ObjectSet(objname, OBJPROP_WIDTH, width);
  ObjectSet(objname, OBJPROP_STYLE, style);
  return(true);//new box drawn
} /* drawBoxOnce */

/*
//--------------------------------------------------------------------------------------
void drawFixedLbl(string objname, string s, int Corner, int DX, int DY, int FSize, string Font, color c, bool bg)
//--------------------------------------------------------------------------------------
{
   if (ObjectFind(objname) < 0) ObjectCreate(objname, OBJ_LABEL, 0, 0, 0);
   
   ObjectSet(objname, OBJPROP_CORNER, Corner);
   ObjectSet(objname, OBJPROP_XDISTANCE, DX);
   ObjectSet(objname, OBJPROP_YDISTANCE, DY);
   ObjectSet(objname,OBJPROP_BACK, bg);      
   ObjectSetText(objname, s, FSize, Font, c);
} //drawFixedLbl
*/

//--------------------------------------------------------------------------------------
// DrawLbl
//--------------------------------------------------------------------------------------

void DrawLbl(string objname, string s, int LTime, double LPrice, int FSize, string Font, color c, int width)
{
  if (ObjectFind(objname) < 0) {
    ObjectCreate(objname, OBJ_TEXT, 0, LTime, LPrice);
  } else {
    if (ObjectType(objname) == OBJ_TEXT) {
      ObjectSet(objname, OBJPROP_TIME1, LTime);
      ObjectSet(objname, OBJPROP_PRICE1, LPrice);
    }
  }

  ObjectSet(objname, OBJPROP_FONTSIZE, FSize);
  ObjectSetText(objname, s, FSize, Font, c);
} /* DrawLbl*/

/*
//--------------------------------------------------------------------------------------
bool AreEqual(double a,double b)
//--------------------------------------------------------------------------------------
{
  return (NormalizeDouble(a, Digits) == NormalizeDouble(b, Digits));
}
*/
  
//end

