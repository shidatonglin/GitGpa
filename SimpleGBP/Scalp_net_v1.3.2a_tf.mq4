//+------------------------------------------------------------------+
//| This EA should be good for eurusd with default setting.          |
//|                For M1 timeframe only                             |
//|                                                                  |
//|                                                                  |
//|                                                                  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
//http://www.forexfactory.com/showthread.php?t=60052
#property copyright "newdigital // mod. http://forexBaron.net"
#property link      "http://www.forex-tsd.com"

extern bool LoadDefaultSettings = true;//loads defaults
extern int MagicNumber = 0;
extern bool EachTickMode = False;
extern double Lots = 0.1;
extern int Slippage = 3;
extern bool StopLossMode = True;
extern int StopLoss = 100;
extern bool TakeProfitMode = True;
extern int TakeProfit = 100;
extern bool TrailingStopMode = True;
extern int TrailingStop = 30;
extern double MaximumRisk       =0.15;
extern double DecreaseFactor    =3;
extern int MaxOrders = 3;
extern int FromHourTrade = 8;
extern int ToHourTrade = 18;
bool UseHourTrade = True;

#define SIGNAL_NONE 0
#define SIGNAL_BUY   1
#define SIGNAL_SELL  2
#define SIGNAL_CLOSEBUY 3
#define SIGNAL_CLOSESELL 4

int BarCount;
int Current;
bool TickCheck = False;

//added:
int Multiplier;
double pips2dbl;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() {
   if (LoadDefaultSettings) LoadDefaults();//load settings as specified in setfile
   
   BrokerDigitAdjust(Symbol()); //added
   
   BarCount = Bars;

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
int start() {
if (UseHourTrade){
      if (!(Hour()>=FromHourTrade && Hour()<=ToHourTrade)) {
         Comment("Time for trade has not come else!");
         
   }  
   }
   int Order = SIGNAL_NONE;
   int Total, Ticket;
   double StopLossLevel, TakeProfitLevel;

   int digit  = MarketInfo(Symbol(),MODE_DIGITS);

   if (EachTickMode && Bars != BarCount) EachTickMode = False;
   Total = OrdersTotal();
   Order = SIGNAL_NONE;
   
   //+------------------------------------------------------------------+
   //| Signal Begin                                                     |
   //+------------------------------------------------------------------+

      double Buy1_1 = iMA(NULL, 0, 55, 0, MODE_EMA, PRICE_CLOSE, Current + 1);
      double Buy1_2 = iMA(NULL, 0, 200, 0, MODE_EMA, PRICE_CLOSE, Current + 1);
      double Buy2_1 = iMA(NULL, 0, 55, 0, MODE_EMA, PRICE_CLOSE, Current + 0);
      double Buy2_2 = iMA(NULL, 0, 200, 0, MODE_EMA, PRICE_CLOSE, Current + 0);
      double Buy3_1 = iSAR(NULL, 0, 0.005, 0.05, Current + 1);
      double Buy3_2 = iSAR(NULL, 0, 0.005, 0.05, Current + 0);
      double Buy4_1 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, Current + 1);
      double Buy4_2 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, Current + 0);
      double Sell1_1 = iMA(NULL, 0, 55, 0, MODE_EMA, PRICE_CLOSE, Current + 1);
      double Sell1_2 = iMA(NULL, 0, 200, 0, MODE_EMA, PRICE_CLOSE, Current + 1);
      double Sell2_1 = iMA(NULL, 0, 55, 0, MODE_EMA, PRICE_CLOSE, Current + 0);
      double Sell2_2 = iMA(NULL, 0, 200, 0, MODE_EMA, PRICE_CLOSE, Current + 0);
      double Sell3_1 = iSAR(NULL, 0, 0.005, 0.05, Current + 1);
      double Sell3_2 = iSAR(NULL, 0, 0.005, 0.05, Current + 0);
      double Sell4_1 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, Current + 1);
      double Sell4_2 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, Current + 0);

      if (Buy1_1 < Buy1_2 && Buy2_1 >= Buy2_2 && Buy3_1 < Buy3_2 && Buy4_1 < Buy4_2 && Hour()>=FromHourTrade && Hour()<=ToHourTrade) Order = SIGNAL_BUY;
      if (Sell1_1 > Sell1_2 && Sell2_1 <= Sell2_2 && Sell3_1 > Sell3_2 && Sell4_1 > Sell4_2 && Hour()>=FromHourTrade && Hour()<=ToHourTrade) Order = SIGNAL_SELL;

   //+------------------------------------------------------------------+
   //| Signal End                                                       |
   //+------------------------------------------------------------------+

   //Buy
   if (Order == SIGNAL_BUY && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
      if(ScanTrades() < MaxOrders) {
         //Check free margin
         if (AccountFreeMargin() < (1000 * Lots)) {
            Print("We have no money. Free Margin = ", AccountFreeMargin());
            return(0);
         }

         StopLossLevel = Ask - StopLoss * pips2dbl;
         TakeProfitLevel = Ask + TakeProfit * pips2dbl;      
         //before: OrderSend ...
         Ticket = SendOrder(Symbol(), OP_BUY, LotsOptimized(), 
                            NormalizeDouble(Ask,digit), 
                            Slippage, 
                            NormalizeDouble(StopLossLevel,digit),  
                            NormalizeDouble(TakeProfitLevel,digit),  
                            "Buy(#" + MagicNumber + ")", MagicNumber, 0, DodgerBlue);
         if(Ticket > 0) {
            if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) Print("BUY order opened : ", OrderOpenPrice()); else Print("Error opening BUY order : ", GetLastError());
         }
         if (EachTickMode) TickCheck = True;
         if (!EachTickMode) BarCount = Bars;
         return(0);
      }
   }

   //Sell
   if (Order == SIGNAL_SELL && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
      if(ScanTrades() < MaxOrders) {
         //Check free margin
         if (AccountFreeMargin() < (1000 * Lots)) {
            Print("We have no money. Free Margin = ", AccountFreeMargin());
            return(0);
         }
         StopLossLevel = Bid + StopLoss * pips2dbl;
         TakeProfitLevel = Bid - TakeProfit * pips2dbl;
         //before: OrderSend
         Ticket = SendOrder(Symbol(), OP_SELL, LotsOptimized(), 
                            NormalizeDouble(Bid,digit), 
                            Slippage, 
                            NormalizeDouble(StopLossLevel,digit),  
                            NormalizeDouble(TakeProfitLevel,digit),  
                            "Sell(#" + MagicNumber + ")", MagicNumber, 0, DeepPink);
         
         
         
         if(Ticket > 0) {
            if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) Print("SELL order opened : ", OrderOpenPrice()); else Print("Error opening SELL order : ", GetLastError());
         }
         if (EachTickMode) TickCheck = True;
         if (!EachTickMode) BarCount = Bars;
         return(0);
      }
   }

   //Check position
   for (int i = 0; i < Total; i ++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderType() <= OP_SELL &&  OrderSymbol() == Symbol()) {
         if(OrderType() == OP_BUY && OrderMagicNumber()==MagicNumber ) {
            //Close
            if (Order == SIGNAL_CLOSEBUY && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
               OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, MediumSeaGreen);
               if (EachTickMode) TickCheck = True;
               if (!EachTickMode) BarCount = Bars;
               return(0);
            }
            //Trailing stop
            if(TrailingStopMode && TrailingStop > 0) {                 
               if(Bid - OrderOpenPrice() > pips2dbl * TrailingStop) {
                  if(OrderStopLoss() < Bid - pips2dbl * TrailingStop) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), Bid - pips2dbl * TrailingStop, OrderTakeProfit(), 0, MediumSeaGreen);
                     if (!EachTickMode) BarCount = Bars;
                     return(0);
                  }
               }
            }
         } else {
            if(OrderType()==OP_SELL && OrderMagicNumber()==MagicNumber)
            {
           
            //Close
            if (Order == SIGNAL_CLOSESELL && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) 
               {
               OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, DarkOrange);
               if (EachTickMode) TickCheck = True;
               if (!EachTickMode) BarCount = Bars;
               return(0);
               }
            //Trailing stop
            if (TrailingStopMode && TrailingStop > 0) 
               {                 
               if((OrderOpenPrice() - Ask) > (pips2dbl * TrailingStop)) {
                  if((OrderStopLoss() > (Ask + pips2dbl * TrailingStop)) || (OrderStopLoss() == 0)) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), Ask + pips2dbl * TrailingStop, OrderTakeProfit(), 0, DarkOrange);
                     if (!EachTickMode) BarCount = Bars;
                     return(0);
                  }
               }
            }
         }}
      }
   }

   if (!EachTickMode) BarCount = Bars;

   return(0);
}

int ScanTrades()
{   
   int total = OrdersTotal();
   int numords = 0;
      
   for(int cnt=0; cnt<total; cnt++) 
   {        
   OrderSelect(cnt, SELECT_BY_POS);            
   if(OrderSymbol() == Symbol() && OrderType()<=OP_SELLSTOP && OrderMagicNumber() == MagicNumber) 
   numords++;
   }
   return(numords);
}  

//bool ExistPositions() {
//	for (int i=0; i<OrdersTotal(); i++) {
//		if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
//			if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) {
//				return(True);
//			}
//		} 
//	} 
//	return(false);
//}

double LotsOptimized()
  {
   double lot=Lots;
   int    orders=HistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//---- select lot size
   if(MaximumRisk>0)lot=NormalizeDouble(Lots*AccountFreeMargin()*MaximumRisk/1000.0,1);
//---- calcuulate number of losses orders without a break
   if(DecreaseFactor>0)
     {
      for(int i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!"); break; }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) continue;
         //----
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
        }
      if(losses>1) lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
     }
//---- return lot size
   if(lot<0.1) lot=0.1;
   return(lot);
   }


//+------------------------------------------------------------------+



bool SendOrder(string symbol,int type,double lots,double price,int slippage,double sl,double tp,string ocomment,int magic,datetime expiry,color col) {

 while (IsTradeContextBusy()) Sleep(100);
 RefreshRates();
 int result=OrderSend(symbol,type,lots,price,slippage,sl,tp,ocomment,magic,expiry,col); 
  if (!OrderSelect(result, SELECT_BY_TICKET) ) return(false);
  result=ModifyOrderSLTP(OrderTicket(),OrderOpenPrice(),sl,tp,OrderExpiration(),CLR_NONE);
  
 return(result);
}

//added, adjusted:
bool ModifyOrderSLTP(int oTicket,double oPrice, double oSL, double oTP, int oExpiration, color oColor) {
 
bool result=false;

 if (OrderType()==OP_BUY) {
  if (oSL < OrderStopLoss() && OrderStopLoss()!=0) return(true); //no modify
 }//if (OrderType()...
 
 if (OrderType()==OP_SELL) {
  if (oSL > OrderStopLoss() && OrderStopLoss()!=0) return(true); //no modify 
 }//if (OrderType()...
 
 if (OrderType()<=OP_SELL) result = OrderModify(oTicket, oPrice, oSL, oTP, oExpiration, oColor);

return(result);
}//end bool ModifyOrder(int oTicket,double oPrice, double oSL, double oTP, int oExpiration, color oColor) {

void BrokerDigitAdjust(string symbol) {
 Multiplier = 1;
 if (MarketInfo(symbol,MODE_DIGITS) == 3 || MarketInfo(symbol,MODE_DIGITS) == 5) Multiplier = 10;
 if (MarketInfo(symbol,MODE_DIGITS) == 6) Multiplier = 100;   
 if (MarketInfo(symbol,MODE_DIGITS) == 7) Multiplier = 1000;
 pips2dbl = Multiplier*MarketInfo(symbol,MODE_POINT); 
}

void LoadDefaults() {

 MagicNumber=4080100;
 EachTickMode=0;
 StopLossMode=1;
 StopLoss=100;
 TakeProfitMode=1;
 TakeProfit=100;
 TrailingStopMode=1;
 TrailingStop=30;
 MaximumRisk=0.00000000;
 DecreaseFactor=3.00000000;
 MaxOrders=3;
 UseHourTrade=1;
 FromHourTrade=8;
 ToHourTrade=18;
}