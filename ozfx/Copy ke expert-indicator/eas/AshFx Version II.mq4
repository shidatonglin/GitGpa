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
extern bool CloseOnOppositeSignal = True;
extern bool TradeSunday = False;
extern bool TradeMonday = True;
extern bool TradeTuesday = True;
extern bool TradeWednesday = True;
extern bool TradeThursday = True;
extern bool TradeFriday = True;
extern bool EachTickMode = True;
extern double Lots = 0;
extern bool MoneyManagement = False;
extern int Risk = 0;
extern int Slippage = 5;
extern bool UseStopLoss = True;
extern bool OverRideStopLoss = False;
extern int StopLoss = 100;
extern bool UseTakeProfit = False;
extern int TakeProfit = 60;
extern bool UseTrailingStop = False;
extern int TrailingStop = 30;
extern bool MoveStopOnce = False;
extern int MoveStopWhenPrice = 50;
extern int MoveStopTo = 1;




//Version 2.01

int OpenBarCount;
int CloseBarCount;
int TradesCount;

int Current;
bool TickCheck = False;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() {
   OpenBarCount = Bars;
   CloseBarCount = Bars;
   
   TradesCount = Bars;

   if (EachTickMode) Current = 0; else Current = 1;

   return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() {
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
         Lots=MathFloor((AccountFreeMargin()*AccountLeverage()*Risk*Point*100)/(Ask*MarketInfo(Symbol(),MODE_LOTSIZE)*MarketInfo(Symbol(),MODE_MINLOT)))*MarketInfo(Symbol(),MODE_MINLOT);
      }
   }

   //+------------------------------------------------------------------+
   //| Variable Begin                                                   |
   //+------------------------------------------------------------------+

string TradingDays = "Can Trade";
string TodayIs;

if(TimeDayOfWeek(TimeCurrent()) == 0) TodayIs = "Sunday";
if(TimeDayOfWeek(TimeCurrent()) == 1) TodayIs = "Monday";
if(TimeDayOfWeek(TimeCurrent()) == 2) TodayIs = "Tuesday";
if(TimeDayOfWeek(TimeCurrent()) == 3) TodayIs = "Wednesday";
if(TimeDayOfWeek(TimeCurrent()) == 4) TodayIs = "Thursday";
if(TimeDayOfWeek(TimeCurrent()) == 5) TodayIs = "Friday";

if(TodayIs == "Sunday" && !TradeSunday) TradingDays = "Cannot Trade";
if(TodayIs == "Monday" && !TradeMonday) TradingDays = "Cannot Trade";
if(TodayIs == "Tuesday" && !TradeTuesday) TradingDays = "Cannot Trade";
if(TodayIs == "Wednesday" && !TradeWednesday) TradingDays = "Cannot Trade";
if(TodayIs == "Thursday" && !TradeThursday) TradingDays = "Cannot Trade";
if(TodayIs == "Friday" && !TradeFriday) TradingDays = "Cannot Trade";

//Candle Direction
string CandleDirection = "None";
if(Open[1] < Close[1]) CandleDirection = "Long";
if(Open[1] > Close[1]) CandleDirection = "Short";

//AC Direction
string ACDirection = "None";
double AC1 = iAC(NULL, 0, 1);
double AC2 = iAC(NULL, 0, 2);

if(AC1 > AC2) ACDirection = "Green";
if(AC1 < AC2) ACDirection = "Red";

//AO Direction
string AODirection = "None";
double AO1 = iAO(NULL, 0, 1);
double AO2 = iAO(NULL, 0, 2);

if(AO1 > AO2) AODirection = "Green";
if(AO1 < AO2) AODirection = "Red";

//Stochastic Direction
string StochasticDirection = "None";
double StochasticMain = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);
double StochasticMain1 = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 2);
double StochasticSignal = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1);
double StochasticSignal1 = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 2);

if(StochasticMain > StochasticSignal && StochasticMain < 80) StochasticDirection = "Long";
if(StochasticMain < StochasticSignal && StochasticMain > 20) StochasticDirection = "Short";

//PSAR Direction
string PSARDirection = "None";
double PSAR = iSAR(NULL, 0, 0.05, 0.2, 1);
double PSAR1 = iSAR(NULL, 0, 0.05, 0.2, 2);

if(PSAR < Close[1] && PSAR1 > Close[2]) PSARDirection = "Cross Long";
if(PSAR > Close[1] && PSAR1 < Close[2]) PSARDirection = "Cross Short";

string PSARPosition = "None";
if(PSAR < Close[Current + 0]) PSARPosition = "Long";
if(PSAR > Close[Current + 0]) PSARPosition = "Short";

string TradeTrigger = "None";
if(TradesCount != Bars && CandleDirection == "Long" && ACDirection == "Green" && AODirection == "Green" && StochasticDirection == "Long" && PSARDirection == "Cross Long") TradeTrigger = "Open Long";
if(TradesCount != Bars && CandleDirection == "Short" && ACDirection == "Red" && AODirection == "Red" && StochasticDirection == "Short" && PSARDirection == "Cross Short") TradeTrigger = "Open Short";

//Determine Swing High/Swing Low

//SwingHigh
int SwingHighShift = 0;
string StringHighStatus = "False";
int SwingHigh = 0;

while (StringHighStatus == "False")
   {
   if(iFractals(NULL, 0, MODE_UPPER, SwingHighShift) == iHigh(NULL, 0, SwingHighShift) && iFractals(NULL, 0, MODE_UPPER, SwingHighShift) > Close[0])
      {
      StringHighStatus = "True";
      SwingHigh = SwingHighShift;
      ObjectDelete("SwingHigh");
      ObjectCreate("SwingHigh", OBJ_VLINE, 0, Time[SwingHigh], 0);
      ObjectSet("SwingHigh", OBJPROP_COLOR, Red);
      }
      else
      {
      SwingHighShift++;
      }
   }
   
//SwingLow
int SwingLowShift = 0;
string StringLowStatus = "False";
int SwingLow = 0;

while (StringLowStatus == "False")
   {
   if(iFractals(NULL, 0, MODE_LOWER, SwingLowShift) == iLow(NULL, 0, SwingLowShift) && iFractals(NULL, 0, MODE_LOWER, SwingLowShift) < Close[0])
      {
      StringLowStatus = "True";
      SwingLow = SwingLowShift;
      ObjectDelete("SwingLow");
      ObjectCreate("SwingLow", OBJ_VLINE, 0, Time[SwingLow], 0);
      ObjectSet("SwingLow", OBJPROP_COLOR, Green);
      }
      else
      {
      SwingLowShift++;
      }
   }   

Comment("Candle Direction: ", CandleDirection, "\n",
        "AC Direction: ", ACDirection, "\n",
        "AO Direction: ", AODirection, "\n",
        "Stochastic Direction: ", StochasticDirection, "\n",
        "PSAR Direction: ", PSARDirection, "\n",
        "Today Is: ", TodayIs, "\n",
        "Trade Trigger: ", TradeTrigger);


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


if(OrderComment() == "Buy(#" + MagicNumber + ") Trade #1" && iBarShift(NULL, 0, OrderOpenTime(), false) != 0 && CandleDirection == "Long" && OrderProfit() > 0) 
      {
      Order = SIGNAL_CLOSEBUY;
      }
if(OrderComment() == "Buy(#" + MagicNumber + ") Trade #2" && iBarShift(NULL, 0, OrderOpenTime(), false) != 0 && CandleDirection == "Long")
      {
      if(OrderStopLoss() < OrderOpenPrice() + Point * MoveStopTo) 
         {
         OrderModify(OrderTicket(),OrderOpenPrice(), OrderOpenPrice() + Point * MoveStopTo, OrderTakeProfit(), 0, Red);
         }
      }   
if(OrderComment() == "Buy(#" + MagicNumber + ") Trade #2" && (PSARPosition == "Short" || AODirection == "Red"))
   {
   Order = SIGNAL_CLOSEBUY;
   }

if(CloseOnOppositeSignal && TradeTrigger == "Open Short") Order = SIGNAL_CLOSEBUY;


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

if(OrderComment() == "Sell(#" + MagicNumber + ") Trade #1" && iBarShift(NULL, 0, OrderOpenTime(), false) != 0 && CandleDirection == "Short" && OrderProfit() > 0) 
      {
      Order = SIGNAL_CLOSESELL;
      }
if(OrderComment() == "Sell(#" + MagicNumber + ") Trade #2" && iBarShift(NULL, 0, OrderOpenTime(), false) != 0 && CandleDirection == "Short")
      {
      if(OrderStopLoss() > OrderOpenPrice() - Point * MoveStopTo) 
         {
         OrderModify(OrderTicket(),OrderOpenPrice(), OrderOpenPrice() - Point * MoveStopTo, OrderTakeProfit(), 0, Red);
         }
      }   
if(OrderComment() == "Sell(#" + MagicNumber + ") Trade #2" && (PSARPosition == "Long" || AODirection == "Green"))
   {
   Order = SIGNAL_CLOSESELL;
   }

if(CloseOnOppositeSignal && TradeTrigger == "Open Long") Order = SIGNAL_CLOSESELL;



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

         if (UseStopLoss && OverRideStopLoss) StopLossLevel = Ask - StopLoss * Point;
         if (UseStopLoss && !OverRideStopLoss) StopLossLevel = iFractals(NULL, 0, MODE_LOWER, SwingLow);
         if (UseStopLoss && !OverRideStopLoss && StopLossLevel == 0) StopLossLevel = iLow(NULL, 0, 1);
         
         if (!UseStopLoss) StopLossLevel = 0;
                  
         if (UseTakeProfit) TakeProfitLevel = Ask + TakeProfit * Point; else TakeProfitLevel = 0.0;

         Ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, StopLossLevel, TakeProfitLevel, "Buy(#" + MagicNumber + ") Trade #1", MagicNumber, 0, DodgerBlue);
         Ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, StopLossLevel, TakeProfitLevel, "Buy(#" + MagicNumber + ") Trade #2", MagicNumber, 0, DodgerBlue);
         if(Ticket > 0) {
            if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) {
				Print("BUY order opened : ", OrderOpenPrice());
                if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + "Buy Signal");
			       if (Alerts) Alert("[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + "Buy Signal");
                if (PlaySounds) PlaySound("alert.wav");
                TradesCount = Bars;
               
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

         if (UseStopLoss && OverRideStopLoss) StopLossLevel = Bid + StopLoss * Point;
         if (UseStopLoss && !OverRideStopLoss) StopLossLevel = iFractals(NULL, 0, MODE_UPPER, SwingHigh);
         if (UseStopLoss && !OverRideStopLoss && StopLossLevel == 0) StopLossLevel = iHigh(NULL, 0, 1);
         if (!UseStopLoss) StopLossLevel = 0;
         
         if (UseTakeProfit) TakeProfitLevel = Bid - TakeProfit * Point; else TakeProfitLevel = 0.0;

         Ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, StopLossLevel, TakeProfitLevel, "Sell(#" + MagicNumber + ") Trade #1", MagicNumber, 0, DeepPink);
         Ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, StopLossLevel, TakeProfitLevel, "Sell(#" + MagicNumber + ") Trade #2", MagicNumber, 0, DeepPink);
         if(Ticket > 0) {
            if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) {
				Print("SELL order opened : ", OrderOpenPrice());
                if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + "Sell Signal");
			       if (Alerts) Alert("[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + "Sell Signal");
                if (PlaySounds) PlaySound("alert.wav");
                TradesCount = Bars;
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