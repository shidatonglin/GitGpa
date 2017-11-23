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
extern bool EachTickMode = True;
extern double Lots = 0;
extern bool MoneyManagement = False;
extern int Risk = 0;
extern int Slippage = 5;
extern  bool UseStopLoss = True;
extern int StopLoss = 100;
extern bool UseTakeProfit = False;
extern int TakeProfit = 60;
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




//Version 2.01

int OpenBarCount;
int CloseBarCount;

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

double UpperRange = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, StartBarUsed - EndBarUsed, EndBarUsed));
double LowerRange = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, StartBarUsed - EndBarUsed, EndBarUsed));

double LongEntry = UpperRange + (BreakoutBuffer * Point);
double ShortEntry = LowerRange - (BreakoutBuffer * Point);

string TradeTrigger = "None";
if(Open[Current + 0] < LongEntry && Close[Current + 0] >= LongEntry) TradeTrigger = "Open Long";
if(Open[Current + 0] > ShortEntry && Close[Current + 0] <= ShortEntry) TradeTrigger = "Open Short";

Comment("Broker Type: ", BrokerType, "\n",
        "Trade Trigger: ", TradeTrigger);
       
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

         if (UseStopLoss) StopLossLevel = Ask - StopLoss * Point; else StopLossLevel = 0.0;
         if (UseTakeProfit) TakeProfitLevel = Ask + TakeProfit * Point; else TakeProfitLevel = 0.0;

         Ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, StopLossLevel, TakeProfitLevel, "Buy(#" + MagicNumber + ")", MagicNumber, 0, DodgerBlue);
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

         if (UseStopLoss) StopLossLevel = Bid + StopLoss * Point; else StopLossLevel = 0.0;
         if (UseTakeProfit) TakeProfitLevel = Bid - TakeProfit * Point; else TakeProfitLevel = 0.0;

         Ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, StopLossLevel, TakeProfitLevel, "Sell(#" + MagicNumber + ")", MagicNumber, 0, DeepPink);
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
