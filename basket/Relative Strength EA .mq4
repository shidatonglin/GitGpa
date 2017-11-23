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
bool EachTickMode = True;
extern bool CloseOnOppositeSignal = True;
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
extern string Remark3 = "== CCFp Settings ==";
extern int MA_Method = 3;
extern int Price = 6;
extern int Fast = 3;
extern int Slow = 5;
extern int All_Bars = 1000;
extern bool TradeHighestOnly = False;
extern bool IdentifyHighestPair = False;
extern color Color = Blue;
extern int MinutesDelayStart = 5;
extern int MinutesDelayEnd = 10;
extern int TradeLevel = 4;
extern bool TradeReversals = True;
extern bool UseCurrent = False;


//Version 2.01

int BarCount;
int GlobalCount;
double EACount = 0;

int Current;
bool TickCheck = False;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() {
   BarCount = Bars;

   if (UseCurrent) Current = 0; else Current = 1;
   
   if(GlobalVariableCheck("RelativeStrengthCount")) {
      EACount = GlobalVariableGet("RelativeStrengthCount") + 1;
      GlobalVariableSet("RelativeStrengthCount", EACount);
      }
      else
      GlobalVariableSet("RelativeStrengthCount", 1);

if(Bars < All_Bars) {
Alert("WARNING: "+Symbol()+" only has "+Bars+" bars in its history");
return(0);
}

   return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() {

   if(GlobalVariableCheck("RelativeStrengthCount")) {
      EACount = GlobalVariableGet("RelativeStrengthCount") - 1;
      if(EACount <= 0) GlobalVariableDel("RelativeStrengthCount");
         else GlobalVariableSet("RelativeStrengthCount", EACount);
      }

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



   if (EachTickMode && Bars != BarCount) TickCheck = False;
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
   
//Reset GlobalCount
if(GlobalCount != Bars) {
GlobalVariableSet("TotalChangeRank", 0);
GlobalCount = Bars;
}



//EACounts
double EACounts = 0;
if(GlobalVariableCheck("RelativeStrengthCount")) EACounts = GlobalVariableGet("RelativeStrengthCount");
   else EACounts = 1;

//Determine Base and Counter Currency
string BaseCurrency = StringSubstr(Symbol(), 0, 3);
string CounterCurrency = StringSubstr(Symbol(), 3, 3);

//Establish Individual Currencies
double USD = iCustom(NULL, 0, "CCFp", MA_Method, Price, Fast, Slow, True, True, True, True, True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, All_Bars, 0, 0, Current + 0);
double USD1 = iCustom(NULL, 0, "CCFp", MA_Method, Price, Fast, Slow, True, True, True, True, True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, All_Bars, 0, 0, Current + 1);

double EUR = iCustom(NULL, 0, "CCFp", MA_Method, Price, Fast, Slow, True, True, True, True, True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, All_Bars, 0, 1, Current + 0);
double EUR1 = iCustom(NULL, 0, "CCFp", MA_Method, Price, Fast, Slow, True, True, True, True, True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, All_Bars, 0, 1, Current + 1);

double GBP = iCustom(NULL, 0, "CCFp", MA_Method, Price, Fast, Slow, True, True, True, True, True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, All_Bars, 0, 2, Current + 0);
double GBP1 = iCustom(NULL, 0, "CCFp", MA_Method, Price, Fast, Slow, True, True, True, True, True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, All_Bars, 0, 2, Current + 1);

double CHF = iCustom(NULL, 0, "CCFp", MA_Method, Price, Fast, Slow, True, True, True, True, True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, All_Bars, 0, 3, Current + 0);
double CHF1 = iCustom(NULL, 0, "CCFp", MA_Method, Price, Fast, Slow, True, True, True, True, True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, All_Bars, 0, 3, Current + 1);

double JPY = iCustom(NULL, 0, "CCFp", MA_Method, Price, Fast, Slow, True, True, True, True, True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, All_Bars, 0, 4, Current + 0);
double JPY1 = iCustom(NULL, 0, "CCFp", MA_Method, Price, Fast, Slow, True, True, True, True, True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, All_Bars, 0, 4, Current + 1);

double AUD = iCustom(NULL, 0, "CCFp", MA_Method, Price, Fast, Slow, True, True, True, True, True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, All_Bars, 0, 5, Current + 0);
double AUD1 = iCustom(NULL, 0, "CCFp", MA_Method, Price, Fast, Slow, True, True, True, True, True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, All_Bars, 0, 5, Current + 1);

double CAD = iCustom(NULL, 0, "CCFp", MA_Method, Price, Fast, Slow, True, True, True, True, True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, All_Bars, 0, 6, Current + 0);
double CAD1 = iCustom(NULL, 0, "CCFp", MA_Method, Price, Fast, Slow, True, True, True, True, True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, All_Bars, 0, 6, Current + 1);

double NZD = iCustom(NULL, 0, "CCFp", MA_Method, Price, Fast, Slow, True, True, True, True, True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, All_Bars, 0, 7, Current + 0);
double NZD1 = iCustom(NULL, 0, "CCFp", MA_Method, Price, Fast, Slow, True, True, True, True, True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, All_Bars, 0, 7, Current + 1);

//Match Base Currency
double Base = 0;
double Base1 = 0;

if(BaseCurrency == "USD") {
   Base = USD;
   Base1 = USD1;
   }

if(BaseCurrency == "EUR") {
   Base = EUR;
   Base1 = EUR1;
   }
   
if(BaseCurrency == "GBP") {
   Base = GBP;
   Base1 = GBP1;
   }

if(BaseCurrency == "CHF") {
   Base = CHF;
   Base1 = CHF1;
   }
   
if(BaseCurrency == "JPY") {
   Base = JPY;
   Base1 = JPY1;
   }
   
if(BaseCurrency == "AUD") {
   Base = AUD;
   Base1 = AUD1;
   }
   
if(BaseCurrency == "CAD") {
   Base = CAD;
   Base1 = CAD1;
   }
   
if(BaseCurrency == "NZD") {
   Base = NZD;
   Base1 = NZD1;
   }   
                  

//Match Counter Currency
double Counter = 0;
double Counter1 = 0;

if(CounterCurrency == "USD") {
   Counter = USD;
   Counter1 = USD1;
   }

if(CounterCurrency == "EUR") {
   Counter = EUR;
   Counter1 = EUR1;
   }
   
if(CounterCurrency == "GBP") {
   Counter = GBP;
   Counter1 = GBP1;
   }

if(CounterCurrency == "CHF") {
   Counter = CHF;
   Counter1 = CHF1;
   }
   
if(CounterCurrency == "JPY") {
   Counter = JPY;
   Counter1 = JPY1;
   }
   
if(CounterCurrency == "AUD") {
   Counter = AUD;
   Counter1 = AUD1;
   }
   
if(CounterCurrency == "CAD") {
   Counter = CAD;
   Counter1 = CAD1;
   }
   
if(CounterCurrency == "NZD") {
   Counter = NZD;
   Counter1 = NZD1;
   }   
      
//Determine Change
double BaseChange = Base - Base1;
double BaseScore1 = Lookup(NormalizeDouble((BaseChange * 10000), 0));
int BaseScore = MathAbs(BaseScore1);
double CounterChange = Counter - Counter1;      
double CounterScore1 = Lookup(NormalizeDouble((CounterChange * 10000), 0));
int CounterScore = MathAbs(CounterScore1);
double TotalChange = MathAbs(BaseChange - CounterChange);
int TotalScore = MathAbs(BaseScore1 - CounterScore1);      
      
//Establish Direction
string BaseDirection = "None";
if(BaseChange > 0) BaseDirection = "Long";
if(BaseChange < 0) BaseDirection = "Short";

string CounterDirection = "None";
if(CounterChange > 0) CounterDirection = "Long";
if(CounterChange < 0) CounterDirection = "Short";

//Determine Trade Type
string ReversePair = "Regular Trade";
if(TradeReversals && (BaseScore < TradeLevel || CounterScore < TradeLevel)) ReversePair = "Reverse Trade";

//Determine Rank
double TotalChangeCheck = 0;
if(GlobalVariableCheck("TotalChangeRank")) {
   TotalChangeCheck = GlobalVariableGet("TotalChangeRank");
   if(TotalScore > TotalChangeCheck) GlobalVariableSet("TotalChangeRank", TotalScore);
   }
   else {
   GlobalVariableSet("TotalChangeRank", TotalScore);
   TotalChangeCheck = GlobalVariableGet("TotalChangeRank");
   }
string CurrentRank = "Not Highest";
if(TradeHighestOnly && TotalChangeCheck == TotalChange) CurrentRank = "Highest";
if(!TradeHighestOnly) CurrentRank = "Not Used";

//Notification
if(CurrentRank == "Highest" && IdentifyHighestPair) {
if(ObjectFind("Notification") < 0) {
   ObjectCreate("Notification", OBJ_RECTANGLE, 0, TimeCurrent(), Close[0] + 100000, iTime(NULL, 0, Bars), Close[0] - 100000);
   ObjectSet("Notification", OBJPROP_COLOR, Color);
   }
}
if(CurrentRank != "Highest") {
   ObjectDelete("Notification");
}    
 



//Time Delay
string TimeDelay = "Outside Trading Times";
datetime BarOpen = Time[0];
datetime TradeStart = BarOpen + (MinutesDelayStart * 60);
datetime TradeEnd = BarOpen + (MinutesDelayEnd * 60);
if(TimeCurrent() >= TradeStart && TimeCurrent() < TradeEnd) TimeDelay = "Inside Trading Times";

string TradeTrigger = "None";
string NextTrade = "None";
if(CurrentRank != "Not Highest" && BaseDirection == "Long" && CounterDirection == "Short") {
   if(ReversePair == "Regular Trade") {
   if(TimeDelay == "Inside Trading Times") {TradeTrigger = "Open Long";}
   NextTrade = "Open Long";
   }
   if(ReversePair == "Reverse Trade") {
   if(TimeDelay == "Inside Trading Times") {TradeTrigger = "Open Short";}
   NextTrade = "Open Short";
   }
}
   
if(CurrentRank != "Not Highest" && BaseDirection == "Short" && CounterDirection == "Long") {
   if(ReversePair == "Regular Trade") {
   if(TimeDelay == "Inside Trading Times") TradeTrigger = "Open Short";
   NextTrade = "Open Short";
   }
   if(ReversePair == "Reverse Trade") {
   if(TimeDelay == "Inside Trading Times") TradeTrigger = "Open Long";
   NextTrade = "Open Long";
   }
}



Comment("EA Count: ", EACounts, "\n",
        "Trading Times: ", TimeDelay, "\n",
        "Current Rank: ", CurrentRank, "\n",
        "Base Currency: ", BaseCurrency, "\n",
        "Counter Currency: ", CounterCurrency, "\n",
        "Base Strength: ", BaseDirection, "\n",
        "Counter Strength: ", CounterDirection, "\n",
        "Base Change: ", BaseScore, ". Raw Values: ", NormalizeDouble((BaseChange * 10000), 0), ". Initial Change ", BaseChange, "\n",
        "Counter Change: ", CounterScore, ". Raw Values: ", NormalizeDouble((CounterChange * 10000), 0), ". Initial Change ", CounterChange, "\n",
        "Total Change: ", TotalScore, "\n",
        "Trade Level: ", TradeLevel, "\n",
        "Trade Type: ", ReversePair, "\n",
        "Next Trade: ", NextTrade, "\n",
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

if(CloseOnOppositeSignal && TradeTrigger == "Open Short") Order = SIGNAL_CLOSEBUY;  

            //+------------------------------------------------------------------+
            //| Signal End(Exit Buy)                                             |
            //+------------------------------------------------------------------+

            if (Order == SIGNAL_CLOSEBUY && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
               OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, MediumSeaGreen);
               if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + " Close Buy");
               if (!EachTickMode) BarCount = Bars;
               IsTrade = False;
               continue;
            }
            //MoveOnce
            if(MoveStopOnce && MoveStopWhenPrice > 0) {
               if(Bid - OrderOpenPrice() >= Point * MoveStopWhenPrice) {
                  if(OrderStopLoss() < OrderOpenPrice() + Point * MoveStopTo) {
                  OrderModify(OrderTicket(),OrderOpenPrice(), OrderOpenPrice() + Point * MoveStopTo, OrderTakeProfit(), 0, Red);
                     if (!EachTickMode) BarCount = Bars;
                     continue;
                  }
               }
            }
            //Trailing stop
            if(UseTrailingStop && TrailingStop > 0) {                 
               if(Bid - OrderOpenPrice() > Point * TrailingStop) {
                  if(OrderStopLoss() < Bid - Point * TrailingStop) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), Bid - Point * TrailingStop, OrderTakeProfit(), 0, MediumSeaGreen);
                     if (!EachTickMode) BarCount = Bars;
                     continue;
                  }
               }
            }
         } else {
        
            //Close

            //+------------------------------------------------------------------+
            //| Signal Begin(Exit Sell)                                          |
            //+------------------------------------------------------------------+

if(CloseOnOppositeSignal && TradeTrigger == "Open Long") Order = SIGNAL_CLOSESELL;  

            //+------------------------------------------------------------------+
            //| Signal End(Exit Sell)                                            |
            //+------------------------------------------------------------------+

            if (Order == SIGNAL_CLOSESELL && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
               OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, DarkOrange);
               if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + " Close Sell");
               if (!EachTickMode) BarCount = Bars;
               IsTrade = False;
               continue;
            }
            //MoveOnce
            if(MoveStopOnce && MoveStopWhenPrice > 0) {
               if(OrderOpenPrice() - Ask >= Point * MoveStopWhenPrice) {
                  if(OrderStopLoss() > OrderOpenPrice() - Point * MoveStopTo) {
                  OrderModify(OrderTicket(),OrderOpenPrice(), OrderOpenPrice() - Point * MoveStopTo, OrderTakeProfit(), 0, Red);
                     if (!EachTickMode) BarCount = Bars;
                     continue;
                  }
               }
            }
            //Trailing stop
            if(UseTrailingStop && TrailingStop > 0) {                 
               if((OrderOpenPrice() - Ask) > (Point * TrailingStop)) {
                  if((OrderStopLoss() > (Ask + Point * TrailingStop)) || (OrderStopLoss() == 0)) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), Ask + Point * TrailingStop, OrderTakeProfit(), 0, DarkOrange);
                     if (!EachTickMode) BarCount = Bars;
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
   if (Order == SIGNAL_BUY && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
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
         if (!EachTickMode) BarCount = Bars;
         return(0);
      }
   }

   //Sell
   if (Order == SIGNAL_SELL && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
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
         if (!EachTickMode) BarCount = Bars;
         return(0);
      }
   }

   if (!EachTickMode) BarCount = Bars;

   return(0);
}


int Lookup(double ratio)
{
int aTable[19] = {-90,-80,-70,-60,-50,-40,-30,-20,-10,0,10,20,30,40,50,60,70,80,90};
int index;

if (ratio <= aTable[0]) index = -10;
else if (ratio <= aTable[1]) index = -9;
else if (ratio <= aTable[2]) index = -8;
else if (ratio <= aTable[3]) index = -7;
else if (ratio <= aTable[4]) index = -6;
else if (ratio <= aTable[5]) index = -5;
else if (ratio <= aTable[6]) index = -4;
else if (ratio <= aTable[7]) index = -3;
else if (ratio <= aTable[8]) index = -2;
else if (ratio <= aTable[9]) index = -1;
else if (ratio <= aTable[10]) index = 1;
else if (ratio <= aTable[11]) index = 2;
else if (ratio <= aTable[12]) index = 3;
else if (ratio <= aTable[13]) index = 4;
else if (ratio <= aTable[14]) index = 5;
else if (ratio <= aTable[15]) index = 6;
else if (ratio <= aTable[16]) index = 7;
else if (ratio <= aTable[17]) index = 8;
else if (ratio <= aTable[18]) index = 9;
else index = 10;

return(index);
} 