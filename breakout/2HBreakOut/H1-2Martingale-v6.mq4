//+------------------------------------------------------------------+
//|                                            H1-2Martingale-v6.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright     "Yordan Yordanov"
#property description   "H1 2 bars low or high breakout Martingaile Expert Advisor"
#property description   "To be used on 1 hour time frame"
#property description   "If used on multiple - pairs each chart should have different magic number"
#property description   "Avoid USD news time if account is less than 5000 USD per pair traded"
#property description   "Use on real account at your own risk"
#property copyright     "Andrew R. Young"
#property link          "http://www.expertadvisorbook.com"
#property description   "Trading classes and functions"
#property strict



//+------------------------------------------------------------------+
//| Includes and object initialization                               |
//+------------------------------------------------------------------+

#include <Trade.mqh>
CTrade Trade;
CCount Count;

#include <Timer.mqh>
CTimer Timer;
CNewBar NewBar;
#include <TrailingStop.mqh>


//+------------------------------------------------------------------+
//| Input variables                                                  |
//+------------------------------------------------------------------+

sinput string TradeSettings;    	// Trade Settings
input int MagicNumber          = 831210;
input string OrdComment        = "H12";
input int Slippage             = 10;
input bool TradeOnBarOpen      = true; 
input double StartingLotSize   = 0.01;
input int TakeProfit           = 50;
input int BuySellStopOffset    = 5;
input int MartingaleTakeProfit = 50;
input int StopLoss           = 0;
input int Distance           = 100;

sinput string TrailingStopSettings;
input bool UseTrailingStop   = false;
input int Trailing_Stop       = 120;
input int MinProfit          = 120;
input int Step               = 10;
input int TrailingTakeProfit = 0;

sinput string TimerSettings;			// Timer
input bool TradeAllowed      = true;
input bool UseTimer          = false;
input int StartHour          = 24;
input int StartMinute        = 0;
input int EndHour            = 8;
input int EndMinute          = 0;
input bool UseLocalTime      = false;


sinput string FFCNewsSetting;
input bool TradeNews         = false;
input int MinutesBeforeNews  = 120;
input int MinuteAfterNews    = 60;
input int NewsImpactLevel    = 3;  // 3: High, 2: Middle, 1: Low

//+------------------------------------------------------------------+
//| Global variable and indicators                                   |
//+------------------------------------------------------------------+

int gBuyTicket, gSellTicket;
double LastBuyPrice, LastSellPrice;

int PreNewsTime;
int NextNewsTime;
bool NewsTime;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
{
   // Set magic number
   Trade.SetMagicNumber(MagicNumber);
   Trade.SetSlippage(Slippage);
   
   return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick()
{
   // Check timer
   bool tradeEnabled = true;
   if(UseTimer == true)
   {
      tradeEnabled = Timer.DailyTimer(StartHour,StartMinute,EndHour,EndMinute,UseLocalTime);
   }
   if(TradeAllowed == false) tradeEnabled = false;
   
   // Check for bar open
   bool newBar = true;
   int barShift = 0;
   
   if(TradeOnBarOpen == true)
   {
      newBar = NewBar.CheckNewBar(_Symbol,_Period);
      barShift = 1;
   }

   if(TradeNews && checkNews()){
      return(0);
   }

   // Trading
   if(tradeEnabled == false)
   {
      // If previous stop orders still active delete and then new ones
         if(Count.BuyStop() > 0){Trade.DeleteAllBuyStopOrders(); gBuyTicket = 0;}
         if(Count.SellStop() > 0){Trade.DeleteAllSellStopOrders(); gSellTicket = 0;}
         
         // Tailing single buy or sell order using else martingale exit
         if(Count.Buy() == 1 && UseTrailingStop == true)
         {
            SelectTicket();   
            bool result = TrailingStop(gBuyTicket, Trailing_Stop, MinProfit, Step);
         }
         if(Count.Sell() == 1 && UseTrailingStop == true)
         {
            SelectTicket();
            bool result = TrailingStop(gSellTicket, Trailing_Stop, MinProfit, Step);
         }
         
         // Martingale exit with Fibonacci lot size steps
         if(Count.Buy() > 0 && LastBuyPrice - NormalizeDouble(Ask,Digits) >= Distance*_Point && Bid < LastBuyPrice)
         {
            gBuyTicket = Trade.OpenBuyOrder(_Symbol,Fibo_Lot(StartingLotSize, Count.Buy()));
            if(OrderSelect(gBuyTicket,SELECT_BY_TICKET))LastBuyPrice = NormalizeDouble(OrderOpenPrice(),Digits);
            ModifyB_Oredrs(BrEv_Price(0));                        
         }
         if(Count.Sell() > 0 && NormalizeDouble(Bid,Digits) - LastSellPrice >= Distance*_Point && Bid > LastSellPrice)
         {
            gSellTicket = Trade.OpenSellOrder(_Symbol,Fibo_Lot(StartingLotSize, Count.Sell()));
            if(OrderSelect(gSellTicket,SELECT_BY_TICKET))LastSellPrice = NormalizeDouble(OrderOpenPrice(),Digits);
            ModifyS_Oredrs(BrEv_Price(1));                        
         }        

   }
   else
   {
      double LongEntry=0, ShortEntry=0;
      // Starting trade with pending Orders on every H1 bar
      if(newBar == true)
      {
         // If previous stop orders still active delete and then new ones
         if(Count.BuyStop() > 0){Trade.DeleteAllBuyStopOrders(); gBuyTicket = 0;}
         if(Count.SellStop() > 0){Trade.DeleteAllSellStopOrders(); gSellTicket = 0;}
         
         // New buy/sell stop orders when price breaks the high / low of last two bars
         if(Count.Buy() == 0)
         {
            double TP = 0;
            double SL = 0;
            double price = NormalizeDouble(High[iHighest(_Symbol,0,MODE_HIGH,2,1)] + MarketInfo(_Symbol,MODE_SPREAD)*_Point + BuySellStopOffset*_Point,Digits);
            if(MathAbs( Ask - price ) < MarketInfo( _Symbol, MODE_STOPLEVEL) * _Point){
               LongEntry = price;
            } else {
               gBuyTicket = Trade.OpenBuyStopOrder(_Symbol,StartingLotSize,price,0,0);
               if(OrderSelect(gBuyTicket,SELECT_BY_TICKET))LastBuyPrice = NormalizeDouble(OrderOpenPrice(),Digits);
               if(UseTrailingStop == false)TP = LastBuyPrice + TakeProfit*_Point;
               else if(UseTrailingStop == true && TrailingTakeProfit > 0 )TP = LastBuyPrice + TrailingTakeProfit*_Point;
               if(StopLoss > 0)SL = LastBuyPrice - StopLoss*_Point;
               ModifyOrder(gBuyTicket, LastBuyPrice, SL, TP);      
            }
         }
         //+-----------------------------------------------------------------------------------------------------------------+
         if(Count.Sell() == 0)
         {
            double TP = 0;
            double SL = 0;
            double price = NormalizeDouble(Low[iLowest(_Symbol,0,MODE_LOW,2,1)] - BuySellStopOffset*_Point,Digits);
            if(MathAbs( Bid - price ) < MarketInfo( _Symbol, MODE_STOPLEVEL) * _Point){
               ShortEntry = price;
            } else {
               gSellTicket = Trade.OpenSellStopOrder(_Symbol,StartingLotSize,price,0,0);
               if(OrderSelect(gSellTicket,SELECT_BY_TICKET))LastSellPrice = NormalizeDouble(OrderOpenPrice(),Digits);
               if(UseTrailingStop == false)TP = LastSellPrice - TakeProfit*_Point;
               else if(UseTrailingStop == true && TrailingTakeProfit > 0 ) TP = LastSellPrice - TrailingTakeProfit*_Point;
               if(StopLoss > 0)SL = LastSellPrice + StopLoss*_Point;
               ModifyOrder(gSellTicket, LastSellPrice, SL, TP);     
            }
         }
      }

      if(Count.BuyStop() == 0 && Count.Buy() == 0 && LongEntry > 0){
         if(Open[0] < LongEntry && Close[0] >= LongEntry){
            gBuyTicket = Trade.OpenBuyOrder(_Symbol,Fibo_Lot(StartingLotSize, Count.Buy()));
            if(OrderSelect(gBuyTicket,SELECT_BY_TICKET))LastBuyPrice = NormalizeDouble(OrderOpenPrice(),Digits);
            if(UseTrailingStop == false)TP = LastBuyPrice + TakeProfit*_Point;
            else if(UseTrailingStop == true && TrailingTakeProfit > 0 )TP = LastBuyPrice + TrailingTakeProfit*_Point;
            if(StopLoss > 0)SL = LastBuyPrice - StopLoss*_Point;
            ModifyOrder(gBuyTicket, LastBuyPrice, SL, TP);     
         }
      }

      if(Count.SellStop() == 0 && Count.Sell() == 0 && ShortEntry > 0){
         if(Open[0] > ShortEntry && Close[0] <= ShortEntry){
            gSellTicket = Trade.OpenSellOrder(_Symbol,Fibo_Lot(StartingLotSize, Count.Sell()));
            if(OrderSelect(gSellTicket,SELECT_BY_TICKET))LastSellPrice = NormalizeDouble(OrderOpenPrice(),Digits);
            if(UseTrailingStop == false)TP = LastSellPrice - TakeProfit*_Point;
            else if(UseTrailingStop == true && TrailingTakeProfit > 0 ) TP = LastSellPrice - TrailingTakeProfit*_Point;
            if(StopLoss > 0)SL = LastSellPrice + StopLoss*_Point;
            ModifyOrder(gSellTicket, LastSellPrice, SL, TP);   
         }
      }
         
         // Tailing single buy or sell order using else martingale exit
         if(Count.Buy() == 1 && UseTrailingStop == true)
         {
            SelectTicket();   
            bool result = TrailingStop(gBuyTicket, Trailing_Stop, MinProfit, Step);
         }
         if(Count.Sell() == 1 && UseTrailingStop == true)
         {
            SelectTicket();
            bool result = TrailingStop(gSellTicket, Trailing_Stop, MinProfit, Step);
         }
         
         // Martingale exit with Fibonacci lot size steps
         if(Count.Buy() > 0 && LastBuyPrice - NormalizeDouble(Ask,Digits) >= Distance*_Point && Bid < LastBuyPrice)
         {
            gBuyTicket = Trade.OpenBuyOrder(_Symbol,Fibo_Lot(StartingLotSize, Count.Buy()));
            if(OrderSelect(gBuyTicket,SELECT_BY_TICKET))LastBuyPrice = NormalizeDouble(OrderOpenPrice(),Digits);
            ModifyB_Oredrs(BrEv_Price(0)); // Modify break even + profit level on martingale orders                        
         }
         if(Count.Sell() > 0 && NormalizeDouble(Bid,Digits) - LastSellPrice >= Distance*_Point && Bid > LastSellPrice)
         {
            gSellTicket = Trade.OpenSellOrder(_Symbol,Fibo_Lot(StartingLotSize, Count.Sell()));
            if(OrderSelect(gSellTicket,SELECT_BY_TICKET))LastSellPrice = NormalizeDouble(OrderOpenPrice(),Digits);
            ModifyS_Oredrs(BrEv_Price(1)); // Modify break even + profit level on martingale orders                          
         }       
         
      }
          
}

void NewsHandling()
{
    static int PrevMinute = -1;

    if (Minute() != PrevMinute)
    {
        PrevMinute = Minute();
   
        int minutesSincePrevEvent =
            iCustom(NULL, 0, "FFCal", true, true, false, true, true, 1, 0);

        int minutesUntilNextEve nt =
            iCustom(NULL, 0, "FFCal", true, true, false, true, true, 1, 1);

        
    }
}//newshandling

bool checkNews(){
   NewsTime = false;
   static int EventMinute = -1, EventImpact = -1, PrevMinute = -1;
   if(NextNewsMins < 0){
      EventImpact = iCustom(
               NULL,            // symbol 
               0,               // timeframe 
               "FFC",           // path/name of the custom indicator compiled program 
               false,            // true/false: Active chart only 
               true,            // true/false: Include High impact
               true,            // true/false: Include Medium impact
               false,            // true/false: Include Low impact
               true,            // true/false: Include Speaks
               false,           // true/false: Include Holidays
               "",              // Find keyword (case-sensitive)
               "",              // Ignore keyword (case-sensitive)
               true,            // true/false: Allow Updates
               4,               // Update every (in hours)
               1,               // Buffers: (0) Minutes, (1) Impact
               0                // shift 
            );
      if(EventImpact >= NewsImpactLevel){
         EventMinute = iCustom(
               NULL,            // symbol 
               0,               // timeframe 
               "FFC",           // path/name of the custom indicator compiled program 
               false,            // true/false: Active chart only 
               true,            // true/false: Include High impact
               true,            // true/false: Include Medium impact
               false,            // true/false: Include Low impact
               true,            // true/false: Include Speaks
               false,           // true/false: Include Holidays
               "",              // Find keyword (case-sensitive)
               "",              // Ignore keyword (case-sensitive)
               true,            // true/false: Allow Updates
               4,               // Update every (in hours)
               0,               // Buffers: (0) Minutes, (1) Impact
               0                // shift 
            );

      }
   } else {
      if (Minute() != PrevMinute){
         PrevMinute = Minute();

         if(NextNewsMins > 0) {
            if(NextNewsMins <= MinutesBeforeNews){
               NewsTime = true;
            }
            NextNewsMins = NextNewsMins - 1;
         } else if(NextNewsMins = 0){
            NextNewsMins
         }

         
      }
       
   }
}

//+-----------------------------------------------------------------------------------------------------------------+
//| Fibonacci lot size calculation                                                                                  |
//+-----------------------------------------------------------------------------------------------------------------+

double Fibo_Lot(double ST_Lot, int cnt) // the cnt is buy or sell, count ST_Lot is starting Lot
{
   double First = ST_Lot;
   double Second = First*2;
   double Next = 0;
   
   if(cnt > 0)
   for(int i=0; i<cnt; i++)
   {
      Next = First + Second;
      First = Second;
      Second = Next;  
   }
   
   return First;
}

//+-----------------------------------------------------------------------------------------------------------------+
//| Break even + N pips profit algo                                                                                 |
//+-----------------------------------------------------------------------------------------------------------------+

double BrEv_Price(int BSType) // BSType -if 0 -> Buy - if 1 -> Sell
{
   //Lot(n)*Price(n) + Lot(n)*Price(n) ... = TotalLots * BreakEven Price
   // BreakEven Price = TotalLot / Lot(n)*Price(n) + Lot(n)*Price(n) ...
   // we neeed BreakEven Price + N pips - profit
   //--- an array that stores open price values
   double Price = 0;
   double BreakEvenPrice = 0;
   double sumLots = 0, sum = 0; // sums of lots and and sum of lots*prices
   double AlternativeProfit = 0;
   if(MartingaleTakeProfit > 0)AlternativeProfit = MartingaleTakeProfit*_Point;
   double P[2000]; // aray with open prices
   double L[2000]; // aray with active lots  
   ArrayInitialize(P,0);
   ArrayInitialize(L,0);  
   int cnt = 0;
   for(int order=0; order<OrdersTotal(); order++) // filing price and lot arrays
   {
      if(OrderSelect(order,SELECT_BY_POS,MODE_TRADES)==false) continue;
      if(OrderMagicNumber()==MagicNumber && OrderSymbol()==_Symbol && OrderType()==BSType)
      {
         P[cnt] = NormalizeDouble(OrderOpenPrice(),Digits);
         L[cnt] = OrderLots();
         cnt ++;  
      }
   }
   // calculating break even price
   for(int i=0;i<cnt;i++)
   {
      sum += L[i]*P[i]; // the sum of - Lot(n)*Price(n) + Lot(n)*Price(n) ...  
      sumLots += L[i]; // the sum of all Lots        
   }
   // BreakEven Price = Lot(n)*Price(n) + Lot(n)*Price(n) ... / TotalLots 
   BreakEvenPrice = sum / sumLots; 
   
   if(BSType == 0)Price = BreakEvenPrice + AlternativeProfit;//Buy
   if(BSType == 1)Price = BreakEvenPrice - AlternativeProfit;//Sell
   return NormalizeDouble(Price,Digits);
}

//+-----------------------------------------------------------------------------------------------------------------+
//| Modifying orders                                                                                                |
//+-----------------------------------------------------------------------------------------------------------------+

void ModifyB_Oredrs(double Btp) // Buy orders Btp = common price of martingale orders
{
   for(int order=OrdersTotal()-1;order>=0;order--)
   {
      if(OrderSelect(order,SELECT_BY_POS,MODE_TRADES)==false) continue;
         if(OrderMagicNumber()==MagicNumber && OrderSymbol()==_Symbol && OrderType()==OP_BUY)
         {   
            double BuyTakeProfit = Btp;         
	         int Bticket = OrderTicket();
	         
	         ModifyStopsByPrice(Bticket, 0, Btp);
	                    
         }
    }         
}

//+-----------------------------------------------------------------------------------------------------------------+

void ModifyS_Oredrs(double Btp) // Sell orders
{
   for(int order=OrdersTotal()-1;order>=0;order--)
   {
      if(OrderSelect(order,SELECT_BY_POS,MODE_TRADES)==false) continue;
         if(OrderMagicNumber()==MagicNumber && OrderSymbol()==_Symbol && OrderType()==OP_SELL)
         {   
            double BuyTakeProfit = Btp;         
	         int Sticket = OrderTicket();
	         
	         ModifyStopsByPrice(Sticket, 0, Btp);
	                    
         }
    }         
}

//+-----------------------------------------------------------------------------------------------------------------+

void SelectTicket() // makes sure the proper ticket is select
{
   for(int order=OrdersTotal()-1;order>=0;order--)
   {
      if(OrderSelect(order,SELECT_BY_POS,MODE_TRADES)==false) continue;
         if(OrderMagicNumber()==MagicNumber && OrderSymbol()==_Symbol)
         {
            if(Count.Buy() == 1 && OrderType()==OP_BUY)gBuyTicket = OrderTicket();
            if(Count.Sell() == 1 && OrderType()==OP_SELL)gSellTicket = OrderTicket();
         }
    }

}