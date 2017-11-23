//+------------------------------------------------------------------+
#define SIGNAL_NONE 0
#define SIGNAL_BUY   1
#define SIGNAL_SELL  2
#define SIGNAL_CLOSEBUY 3
#define SIGNAL_CLOSESELL 4

#property copyright "Ronald Raygun"

extern string Remark1 = "== Main Settings ==";
extern int MagicNumber = 0;
extern bool SignalsOnly = False;
extern bool Alerts = False;
extern bool SignalMail = False;
extern bool PlaySounds = False;
extern bool ECNBroker = False;
extern bool EachTickMode = True;
extern double Lots = 0;
extern bool MoneyManagement = False;
extern int Risk = 0;
extern int Slippage = 5;
extern  bool UseStopLoss = True;
extern bool UseFixedStopLoss = True;
extern int StopLoss = 100;
extern bool UseStopLossMultiplier = True;
extern double StopLossMultiplier = 3;
extern bool UseTakeProfit = False;
extern bool UseFixedTakeProfit = True;
extern int FixedTakeProfit = 60;
extern bool UseTakeProfitMultiplier = True;
extern double TakeProfitMultiplier = 3;
extern bool UseTrailingStop = False;
extern int TrailingStop = 30;
extern bool MoveStopOnce = False;
extern int MoveStopWhenPrice = 50;
extern int MoveStopTo = 1;
extern string Remark2 = "";
extern string Remark3 = "== Breakout Settings ==";
extern int DayStart = 0;
extern int BarsFromWeekStart = 1;
extern int BreakoutBuffer = 0;
extern int MaxTradesPerWeek = 10;
extern int MaxLongsPerWeek = 8;
extern int MaxShortsPerWeek = 8;
extern string Days = "Sunday is 0, Monday 1, Friday 5, etc";
extern bool UseCloseOnWeekEnd = False;
extern int ClosePositionsDay = 5;
extern string ClosePositionTime = "23:00";



//Version 2.01

int OpenBarCount;
int CloseBarCount;

int RemainingTrades;
int RemainingLongs; 
int RemainingShorts;

string BrokerType = "4-Digit Broker";
double BrokerMultiplier = 1;

int Current;
bool TickCheck = False;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() {
   OpenBarCount = Bars;
   CloseBarCount = Bars;
   
   if(Digits == 3 || Digits == 5)
      {
      BrokerType = "5-Digit Broker";
      BrokerMultiplier = 10;
      }

 
   if (EachTickMode) Current = 0; else Current = 1;

   return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() {

ObjectDelete("StartRange");
ObjectDelete("EndRange");
ObjectDelete("UpperRange");
ObjectDelete("LowerRange");
ObjectDelete("UpperEntry");
ObjectDelete("LowerEntry");

   return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start() 


{
   int Order = SIGNAL_NONE;
   int Total, Ticket;
   double StopLossLevel, TakeProfitLevel;



   if (EachTickMode && Bars != CloseBarCount) TickCheck = False;
   Total = OrdersTotal();
   Order = SIGNAL_NONE;

//Money Management sequence
 if (MoneyManagement)
   {
      if (Risk<1 || Risk>100)
      {
         Comment("Invalid Risk Value.");
         return(0);
      }
      else
      {
         Lots=MathFloor((AccountFreeMargin()*AccountLeverage()*Risk*Point*BrokerMultiplier*100)/(Ask*MarketInfo(Symbol(),MODE_LOTSIZE)*MarketInfo(Symbol(),MODE_MINLOT)))*MarketInfo(Symbol(),MODE_MINLOT);
      }
   }

   //+------------------------------------------------------------------+
   //| Variable Begin                                                   |
   //+------------------------------------------------------------------+

string CloseTime = "None";
if(UseCloseOnWeekEnd && TimeDayOfWeek(TimeCurrent()) >= ClosePositionsDay && TimeCurrent() >= StrToTime(ClosePositionTime)) CloseTime = "The week is over, enjoy your weekend.";


//Find start of range
bool StartBarFound = False;
int StartBarShift = BarsFromWeekStart;
int StartBarUsed = 0;

while(!StartBarFound)
   {
   if(TimeDayOfWeek(iTime(NULL, 0, StartBarShift + 1)) != DayStart && TimeDayOfWeek(iTime(NULL, 0, StartBarShift)) == DayStart)
      {
      StartBarFound = True;
      StartBarUsed = StartBarShift;
      }
      else
      {
      StartBarShift++;
      }
   }

int EndBarUsed = StartBarUsed - BarsFromWeekStart;

double UpperRange = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, StartBarUsed - EndBarUsed + 1, EndBarUsed));
double LowerRange = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, StartBarUsed - EndBarUsed + 1, EndBarUsed));
double TotalRange = UpperRange - LowerRange;

double LongEntry = UpperRange + (BreakoutBuffer * Point);
double ShortEntry = LowerRange - (BreakoutBuffer * Point);


//Count # of trades since week's start. 

int TotalHistory = OrdersHistoryTotal();
int TotalTrades = 0;
int TotalLongs = 0;
int TotalShorts = 0;

for (int T = 0; T < TotalHistory; T++)
   {
   OrderSelect(T, SELECT_BY_POS, MODE_HISTORY);
   if(OrderType() <= OP_SELL &&  OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderOpenTime() >= Time[StartBarUsed]) 
      {
      TotalTrades++;
      if(OrderType() == OP_BUY) TotalLongs++;
      if(OrderType() == OP_SELL) TotalShorts++;
      }
   }

string TradeTrigger = "None";
if(CloseTime == "None" && EndBarUsed > 0 && (TotalTrades < MaxTradesPerWeek || MaxTradesPerWeek == 0) && (TotalLongs < MaxLongsPerWeek || MaxLongsPerWeek == 0) && (TotalShorts < MaxShortsPerWeek || MaxShortsPerWeek == 0) && Open[Current + 0] < LongEntry && Close[Current + 0] >= LongEntry) TradeTrigger = "Open Long";
if(CloseTime == "None" && EndBarUsed > 0 && (TotalTrades < MaxTradesPerWeek || MaxTradesPerWeek == 0) && (TotalLongs < MaxLongsPerWeek || MaxLongsPerWeek == 0) && (TotalShorts < MaxShortsPerWeek || MaxShortsPerWeek == 0) && Open[Current + 0] > ShortEntry && Close[Current + 0] <= ShortEntry) TradeTrigger = "Open Short";

string CloseTrigger = "None";
if(CloseTime != "None") CloseTrigger = "Close All";

Comment("Broker Type: ", BrokerType, "\n",
        "Week Status: ", CloseTime, "\n",
        "Total Trades: ", TotalTrades, "\n",
        "Total Longs: ", TotalLongs, "\n",
        "Total Shorts: ", TotalShorts, "\n",
        "Trade Trigger: ", TradeTrigger, "\n",
        "Close Trigger: ", CloseTrigger);
       
ObjectDelete("StartRange");
ObjectCreate("StartRange", OBJ_VLINE, 0, Time[StartBarUsed], 0);
ObjectSet("StartRange", OBJPROP_STYLE, STYLE_DASHDOT);
ObjectSet("StartRange", OBJPROP_BACK, True);
ObjectSet("StartRange", OBJPROP_COLOR, Yellow);

ObjectDelete("EndRange");
ObjectCreate("EndRange", OBJ_VLINE, 0, Time[EndBarUsed], 0);
ObjectSet("EndRange", OBJPROP_STYLE, STYLE_DASHDOTDOT);
ObjectSet("EndRange", OBJPROP_BACK, True);
ObjectSet("EndRange", OBJPROP_COLOR, Yellow);

ObjectDelete("UpperRange");
ObjectCreate("UpperRange", OBJ_HLINE, 0, 0, UpperRange);
ObjectSet("UpperRange", OBJPROP_STYLE, STYLE_DASH);
ObjectSet("UpperRange", OBJPROP_BACK, True);
ObjectSet("UpperRange", OBJPROP_COLOR, Yellow);

ObjectDelete("LowerRange");
ObjectCreate("LowerRange", OBJ_HLINE, 0, 0, LowerRange);
ObjectSet("LowerRange", OBJPROP_STYLE, STYLE_DASH);
ObjectSet("LowerRange", OBJPROP_BACK, True);
ObjectSet("LowerRange", OBJPROP_COLOR, Yellow);

ObjectDelete("UpperEntry");
ObjectCreate("UpperEntry", OBJ_HLINE, 0, 0, LongEntry);
ObjectSet("UpperEntry", OBJPROP_STYLE, STYLE_DASH);
ObjectSet("UpperEntry", OBJPROP_BACK, True);
ObjectSet("UpperEntry", OBJPROP_COLOR, Lime);

ObjectDelete("LowerEntry");
ObjectCreate("LowerEntry", OBJ_HLINE, 0, 0, ShortEntry);
ObjectSet("LowerEntry", OBJPROP_STYLE, STYLE_DASH);
ObjectSet("LowerEntry", OBJPROP_BACK, True);
ObjectSet("LowerEntry", OBJPROP_COLOR, Lime);


   //+------------------------------------------------------------------+
   //| Variable End                                                     |
   //+------------------------------------------------------------------+

   //Check position
   bool IsTrade = False;

   for (int i = 0; i < Total; i ++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderType() <= OP_SELL &&  OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         IsTrade = True;
         if(OrderType() == OP_BUY) {
         
            
            //Close

            //+------------------------------------------------------------------+
            //| Signal Begin(Exit Buy)                                           |
            //+------------------------------------------------------------------+


  if(CloseTrigger == "Close All") Order = SIGNAL_CLOSEBUY;
            //+------------------------------------------------------------------+
            //| Signal End(Exit Buy)                                             |
            //+------------------------------------------------------------------+

            if (Order == SIGNAL_CLOSEBUY && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != CloseBarCount)))) {
               OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, MediumSeaGreen);
               if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + " Close Buy");
               if (!EachTickMode) CloseBarCount = Bars;
               IsTrade = False;
               continue;
            }
            //MoveOnce
            if(MoveStopOnce && MoveStopWhenPrice > 0) {
               if(Bid - OrderOpenPrice() >= Point * MoveStopWhenPrice) {
                  if(OrderStopLoss() < OrderOpenPrice() + Point * MoveStopTo) {
                  OrderModify(OrderTicket(),OrderOpenPrice(), OrderOpenPrice() + Point * MoveStopTo, OrderTakeProfit(), 0, Red);
                     if (!EachTickMode) CloseBarCount = Bars;
                     continue;
                  }
               }
            }
            //Trailing stop
            if(UseTrailingStop && TrailingStop > 0) {                 
               if(Bid - OrderOpenPrice() > Point * TrailingStop) {
                  if(OrderStopLoss() < Bid - Point * TrailingStop) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), Bid - Point * TrailingStop, OrderTakeProfit(), 0, MediumSeaGreen);
                     if (!EachTickMode) CloseBarCount = Bars;
                     continue;
                  }
               }
            }
         } else {
        
            //Close

            //+------------------------------------------------------------------+
            //| Signal Begin(Exit Sell)                                          |
            //+------------------------------------------------------------------+

if(CloseTrigger == "Close All") Order = SIGNAL_CLOSESELL;

            //+------------------------------------------------------------------+
            //| Signal End(Exit Sell)                                            |
            //+------------------------------------------------------------------+

            if (Order == SIGNAL_CLOSESELL && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != CloseBarCount)))) {
               OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, DarkOrange);
               if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + " Close Sell");
               if (!EachTickMode) CloseBarCount = Bars;
               IsTrade = False;
               continue;
            }
            //MoveOnce
            if(MoveStopOnce && MoveStopWhenPrice > 0) {
               if(OrderOpenPrice() - Ask >= Point * MoveStopWhenPrice) {
                  if(OrderStopLoss() > OrderOpenPrice() - Point * MoveStopTo) {
                  OrderModify(OrderTicket(),OrderOpenPrice(), OrderOpenPrice() - Point * MoveStopTo, OrderTakeProfit(), 0, Red);
                     if (!EachTickMode) CloseBarCount = Bars;
                     continue;
                  }
               }
            }
            //Trailing stop
            if(UseTrailingStop && TrailingStop > 0) {                 
               if((OrderOpenPrice() - Ask) > (Point * TrailingStop)) {
                  if((OrderStopLoss() > (Ask + Point * TrailingStop)) || (OrderStopLoss() == 0)) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), Ask + Point * TrailingStop, OrderTakeProfit(), 0, DarkOrange);
                     if (!EachTickMode) CloseBarCount = Bars;
                     continue;
                  }
               }
            }
         }
      }
   }

   //+------------------------------------------------------------------+
   //| Signal Begin(Entry)                                              |
   //+------------------------------------------------------------------+

if(TradeTrigger == "Open Long") Order = SIGNAL_BUY;
if(TradeTrigger == "Open Short") Order = SIGNAL_SELL;

   //+------------------------------------------------------------------+
   //| Signal End                                                       |
   //+------------------------------------------------------------------+

   //Buy
   if (Order == SIGNAL_BUY && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != OpenBarCount)))) {
      if(SignalsOnly) {
         if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + "Buy Signal");
         if (Alerts) Alert("[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + "Buy Signal");
         if (PlaySounds) PlaySound("alert.wav");
     
      }
      
      if(!IsTrade && !SignalsOnly) {
         //Check free margin
         if (AccountFreeMargin() < (1000 * Lots)) {
            Print("We have no money. Free Margin = ", AccountFreeMargin());
            return(0);
         }

         if (UseStopLoss && UseFixedStopLoss) StopLossLevel = Ask - StopLoss * Point; 
         if (UseStopLoss && UseStopLossMultiplier && Ask - (TotalRange * StopLossMultiplier) > StopLossLevel && StopLossMultiplier != 0) StopLossLevel = Ask - (TotalRange * StopLossMultiplier);
         if (!UseStopLoss || (!UseFixedStopLoss && !UseStopLossMultiplier)) StopLossLevel = 0.0;
         
         if (UseTakeProfit && UseFixedTakeProfit) TakeProfitLevel = Ask + FixedTakeProfit * Point; 
         if (UseTakeProfit && UseTakeProfitMultiplier && Ask + (TotalRange * TakeProfitMultiplier) > TakeProfitLevel && TakeProfitMultiplier != 0) TakeProfitLevel = Ask + (TotalRange * TakeProfitMultiplier);
         if (!UseTakeProfit || (!UseFixedTakeProfit && !UseTakeProfitMultiplier)) TakeProfitLevel = 0.0;
         
         if(ECNBroker) Ticket = OrderModify(OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, 0, 0, "Buy(#" + MagicNumber + ")", MagicNumber, 0, DodgerBlue), OrderOpenPrice(), StopLossLevel, TakeProfitLevel, 0, CLR_NONE);
         if(!ECNBroker) Ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, StopLossLevel, TakeProfitLevel, "Buy(#" + MagicNumber + ")", MagicNumber, 0, DodgerBlue);
         if(Ticket > 0) {
            if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) {
				Print("BUY order opened : ", OrderOpenPrice());
                if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + "Buy Signal");
			       if (Alerts) Alert("[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + "Buy Signal");
                if (PlaySounds) PlaySound("alert.wav");
			} else {
				Print("Error opening BUY order : ", GetLastError());
			}
         }
         if (EachTickMode) TickCheck = True;
         if (!EachTickMode) OpenBarCount = Bars;
         return(0);
      }
   }

   //Sell
   if (Order == SIGNAL_SELL && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != OpenBarCount)))) {
      if(SignalsOnly) {
          if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + "Sell Signal");
          if (Alerts) Alert("[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + "Sell Signal");
          if (PlaySounds) PlaySound("alert.wav");
         }
      if(!IsTrade && !SignalsOnly) {
         //Check free margin
         if (AccountFreeMargin() < (1000 * Lots)) {
            Print("We have no money. Free Margin = ", AccountFreeMargin());
            return(0);
         }

         if (UseStopLoss && UseFixedStopLoss) StopLossLevel = Bid + StopLoss * Point; 
         if (UseStopLoss && UseStopLossMultiplier && ((Bid + (TotalRange * StopLossMultiplier) < StopLossLevel && StopLossMultiplier != 0) || (StopLossLevel == 0))) StopLossLevel = Bid + (TotalRange * StopLossMultiplier);
         if (!UseStopLoss || (!UseFixedStopLoss && !UseStopLossMultiplier)) StopLossLevel = 0.0;
         
         if (UseTakeProfit && UseFixedTakeProfit) TakeProfitLevel = Bid - FixedTakeProfit * Point; 
         if (UseTakeProfit && UseTakeProfitMultiplier && ((Bid - (TotalRange * TakeProfitMultiplier) < TakeProfitLevel && TakeProfitMultiplier != 0) || (TakeProfitLevel == 0))) TakeProfitLevel = Bid - (TotalRange * TakeProfitMultiplier);
         if (!UseTakeProfit || (!UseFixedTakeProfit && !UseTakeProfitMultiplier)) TakeProfitLevel = 0.0;

         Print("Takeprofit Level: "+ TakeProfitLevel);
         
         if(ECNBroker) Ticket = OrderModify(OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, 0, 0, "Sell(#" + MagicNumber + ")", MagicNumber, 0, DeepPink), OrderOpenPrice(), StopLossLevel, TakeProfitLevel, 0, CLR_NONE);
         if(!ECNBroker)Ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, StopLossLevel, TakeProfitLevel, "Sell(#" + MagicNumber + ")", MagicNumber, 0, DeepPink);
         if(Ticket > 0) {
            if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) {
				Print("SELL order opened : ", OrderOpenPrice());
                if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + "Sell Signal");
			       if (Alerts) Alert("[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + "Sell Signal");
                if (PlaySounds) PlaySound("alert.wav");
			} else {
				Print("Error opening SELL order : ", GetLastError());
			}
         }
         if (EachTickMode) TickCheck = True;
         if (!EachTickMode) OpenBarCount = Bars;
         return(0);
      }
   }

   if (!EachTickMode) CloseBarCount = Bars;

   return(0);
}