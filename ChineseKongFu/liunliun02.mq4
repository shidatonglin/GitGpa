//+------------------------------------------------------------------+
//|                                                   liunliun01.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+



extern double lot = 0.1;
extern int SL = 500;
extern int TP = 200;
extern bool useTs = true;
extern int Ts = 100;
extern int maxOrders = 1;

extern bool disableNoTrend = true;

extern int Magic = -16973;


int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
void CloseAll()
  {

  int total = OrdersTotal();
  for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();

    bool result = false;
    
    switch(type)
    {    
      //Close opened long positions
      case OP_BUY       : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                          break;

      //Close pending orders
      case OP_BUYLIMIT  :
      case OP_BUYSTOP   : result = OrderDelete( OrderTicket() );
      
      //Close opened short positions
      case OP_SELL      : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
                          break;

      //Close pending orders
      case OP_SELLLIMIT :
      case OP_SELLSTOP  : result = OrderDelete( OrderTicket() );
    }
    
    if(result == false)
    {
      //Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
      //Sleep(3000);
    }  
  }  
  }  
void TrailingStop()
{
   int tip,Ticket;
   double StLo,OSL,OOP;
   for (int i=0; i<OrdersTotal(); i++) 
   {  if (OrderSelect(i, SELECT_BY_POS)==true)
      {  tip = OrderType();
         if (/*OrderSymbol()==symbol &&*/OrderMagicNumber()==Magic)
         {
            OSL   = NormalizeDouble(OrderStopLoss(),Digits);
            OOP   = NormalizeDouble(OrderOpenPrice(),Digits);
            Ticket = OrderTicket();
            if (tip==OP_BUY)             
            {
               StLo = NormalizeDouble(Bid-Ts*Point,Digits);
               if (StLo > OSL && StLo > OOP)
               {  if (!OrderModify(Ticket,OOP,StLo,OrderTakeProfit(),0,White))
                     Print("TrailingStop Error ",GetLastError()," buy SL ",OSL,"->",StLo);
               }
            }                                         
            if (tip==OP_SELL)        
            {
               StLo = NormalizeDouble(Ask+Ts*Point,Digits);
               if (StLo > OOP || StLo==0) continue;
               if (StLo < OSL || OSL==0 )
               {  if (!OrderModify(Ticket,OOP,StLo,OrderTakeProfit(),0,White))
                     Print("TrailingStop Error ",GetLastError()," sell SL ",OSL,"->",StLo);
               }
            } 
         }
      }
   }
} //+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
bool upTrend = false;
bool dnTrend = false;
bool noTrend = false;
bool noThing = false;




double prevAsk = -1;
double prevBid = -1;
void OnTick()
{
   if (useTs)
      TrailingStop();

   //---
   double white_10 = iCustom(Symbol(),Period(),"liun_interval_index", 1.0, 1.0, 1.2, 0.0, 8.0, 8.0, 1, 0);
   double white_11 = iCustom(Symbol(),Period(),"liun_interval_index",1.0, 1.0, 1.2, 0.0, 8.0, 8.0, 1, 1);
   
   double white_20 = iCustom(Symbol(),Period(),"liun_interval_index",1.0, 1.0, 1.2, 0.0, 8.0, 8.0, 0, 0);
   double white_21 = iCustom(Symbol(),Period(),"liun_interval_index",1.0, 1.0, 1.2, 0.0, 8.0, 8.0, 0, 1);
   
   double yellow_10 = iCustom(Symbol(),Period(),"liun_interval_trend", 0.0, 2.0, 3.0, 0.0, 20.0, 20.0, 0, 0);
   double yellow_11 = iCustom(Symbol(),Period(),"liun_interval_trend", 0.0, 2.0, 3.0, 0.0, 20.0, 20.0, 0, 1);
   
   double yellow_20 = iCustom(Symbol(),Period(),"liun_interval_trend", 0.0, 2.0, 3.0, 0.0, 20.0, 20.0, 1, 0);
   double yellow_21 = iCustom(Symbol(),Period(),"liun_interval_trend", 0.0, 2.0, 3.0, 0.0, 20.0, 20.0, 1, 1);

   
   upTrend = false;
   dnTrend = false;
   
   if (white_20 > yellow_10 && white_20 > white_21)
   {
      upTrend = true;
   }
   if (white_10 < yellow_20 && white_10 < white_11)
   {
      dnTrend = true;
   }
   
   noTrend = false;
   if (white_10 > yellow_20 && white_10 < yellow_10 &&  white_20 > yellow_20 &&  white_20 < yellow_10 && 
     ((white_10 > white_11  && white_20 > white_21  && yellow_10 < yellow_11 && yellow_20 < yellow_21) || 
      (white_10 < white_11  && white_20 < white_21  && yellow_10 > yellow_11 && yellow_20 > yellow_21)))
      noTrend = true;


   if ((white_20 > yellow_10 && white_20 < white_21) ||  // uptrend nothing
       (white_10 < yellow_20 && white_10 > white_11)) // dntrend nothing
    {
      noThing = true;
      CloseAll();
    }    

   
   
   if ((upTrend || (noTrend && !disableNoTrend)) && OrdersTotal() < maxOrders)
   {
      // look for touch of W2
      if ((Ask > white_20 && prevAsk <= white_20) || (Ask < white_20 && prevAsk >= white_20))
      {
         // open buy trade
         OrderSend(Symbol(), OP_BUY, lot, Ask, 3, Bid - SL*Point, Bid + TP*Point, "Uptrend trade", Magic, 0, 0);
         
      }
   }
   
   if ((dnTrend || (noTrend && !disableNoTrend)) && OrdersTotal() < maxOrders)
   {
      // look for touch of W2
      if ((Bid < white_10 && prevBid >= white_10) || (Bid > white_10 && prevBid <= white_10))
      {
         // open sell trade
         OrderSend(Symbol(), OP_SELL, lot, Bid, 3, Ask+ SL*Point, Ask - TP*Point, "Dntrend trade", Magic, 0, 0);
         
      }
   }  
   
   prevAsk = Ask;
   prevBid = Bid;

}
//+------------------------------------------------------------------+
/*
entry in notrend-short: first make sure you are in a notrend by the way i posted, then when price touch white1,here is the entry for short.
entry in notrend-long: first make sure you are in a notrend by the way i posted, then when price touch white2,here is the entry for long.
exit in notrend-long:if the uptrend become "nothing " you should close your trade
exit in notrend-short:if the downtrend become "nothing " you should close your trade

tp:20pips(if you are new in this system or you can choose 40pips)
sl:30pips


*/