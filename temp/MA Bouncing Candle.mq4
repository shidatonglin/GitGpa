//+------------------------------------------------------------------+
//|                                               Bouncing Candle.mq4|
//|                                                                  |
//+------------------------------------------------------------------+

// Profit $, D/D %

#property copyright "None"
#property link      "None"

#include <stdlib.mqh>
#include <stderror.mqh>

extern int Slippage=3;
extern int MagicNumber = 45243310;
extern int TimeFrame = 0;// Optimize per currency pair. current=0 , M1=1, M5=5, M15=15,
// M30=30, H1=60, H4=240, Daily=1440
//-------------------------------
extern bool MM=true;//Select true for automatic money management
extern double RiskPercent=1;//Update per your desired risk
extern double Lots=0.01;//Optimize per account balance
extern int MaxTrade=1;
//----------------------
extern bool TrailingAlls = true;
extern int Trail = 29;            //Optimize per currency pair and timeframe
extern int TrailStart = 1;       //Optimize per currencypair and timeframe
//----------------------
extern bool BreakEven = true;
extern int  BreakEvenTrigger = 13;
//------------------                              
extern int EMA_Period=17;
//-----------------------------
double Poin; // global variable declaration to fix the 6 Digit Forex Quotes
//issue for MetaTrader Expert Advisors
string EA_Name = "Bouncing Candle";
bool AlertOn = true;
datetime timeprev=0;//Working only after a new candle.

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+

int init()
{
 
 //Initialization to Check for unconventional Point digits number
 if (Point == 0.00001) Poin = 0.0001; //6 digits
 else if (Point == 0.001) Poin = 0.01; //3 digits (for Yen based pairs)
 else Poin = Point; //Normal for 5 & 3 Digit Forex Quotes

 return(0);
}

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+

int deinit()
{

 return(0);
}

//+------------------------------------------------------------------+
//|  Lot Optimization                                  |
//+------------------------------------------------------------------+

double LotsOptimized()
  {
   double lot=Lots;
//------ get broker's min/max
   double Min_Lots = NormalizeDouble((MarketInfo(Symbol(), MODE_MINLOT)),2);
   double Max_Lots = NormalizeDouble((MarketInfo(Symbol(), MODE_MAXLOT)),2);
//------ make lots automatically per broker's min/max
   if (lot < Min_Lots)
   lot=Min_Lots;
   if (lot > Max_Lots)
   lot=Max_Lots;
//------ automatically select lot size per MM
   if (MM==true) 
   //{
   lot=NormalizeDouble(MathFloor(AccountFreeMargin()*RiskPercent/100)/100,1);
   return(lot);
  }

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+

int start()

{

//+------------------------------------------------------------------+
//| Function calls                                            |
//+------------------------------------------------------------------+

   if (TrailingAlls) Trailingalls(TrailStart, Trail); 

//------------------------------------

   if (BreakEven)    Breakeven();

//+------------------------------------------------------------------+
//| indicators                                  |
//+------------------------------------------------------------------+

   double EMA_0 = iMA(NULL,TimeFrame,EMA_Period,0,MODE_SMA,PRICE_CLOSE,0);
   double EMA_1 = iMA(NULL,TimeFrame,EMA_Period,0,MODE_SMA,PRICE_CLOSE,1);
   double EMA_2 = iMA(NULL,TimeFrame,EMA_Period,0,MODE_SMA,PRICE_CLOSE,2);
   double EMA_3 = iMA(NULL,TimeFrame,EMA_Period,0,MODE_SMA,PRICE_CLOSE,3);
   double EMA_4 = iMA(NULL,TimeFrame,EMA_Period,0,MODE_SMA,PRICE_CLOSE,4);
   double EMA_5 = iMA(NULL,TimeFrame,EMA_Period,0,MODE_SMA,PRICE_CLOSE,5);
   double EMA_6 = iMA(NULL,TimeFrame,EMA_Period,0,MODE_SMA,PRICE_CLOSE,6);

   double Open_0 = iOpen(NULL,TimeFrame,0);
   double Open_1 = iOpen(NULL,TimeFrame,1);
   double Open_2 = iOpen(NULL,TimeFrame,2);
   double Open_3 = iOpen(NULL,TimeFrame,3);
   double Open_4 = iOpen(NULL,TimeFrame,4);

   double Close_0 = iClose(NULL,TimeFrame,0);
   double Close_1 = iClose(NULL,TimeFrame,1);
   double Close_2 = iClose(NULL,TimeFrame,2);
   double Close_3 = iClose(NULL,TimeFrame,3);
   double Close_4 = iClose(NULL,TimeFrame,4);

   double High_1 = iHigh(NULL,TimeFrame,1);
   double High_2 = iHigh(NULL,TimeFrame,2);
   double High_3 = iHigh(NULL,TimeFrame,3);
   double High_4 = iHigh(NULL,TimeFrame,4);

   double Low_1 = iLow(NULL,TimeFrame,1);
   double Low_2 = iLow(NULL,TimeFrame,2);
   double Low_3 = iLow(NULL,TimeFrame,3);
   double Low_4 = iLow(NULL,TimeFrame,4);

   double Highest_High = High[iHighest(NULL, TimeFrame, MODE_HIGH, 3, 1 )];
   double Lowest_Low = Low[iLowest(NULL, TimeFrame, MODE_LOW, 3, 1 )];
   double Range = Highest_High-Lowest_Low;

//+------------------------------------------------------------------+
//| calculating orders stoploss                                   |
//+------------------------------------------------------------------+
   
   //double LongStopLoss=NormalizeDouble(Low_2,Digits)-1*Poin;
   double LongStopLoss=NormalizeDouble(High_1,Digits)-15*Poin;
   
//-------------

   //double ShortStopLoss=NormalizeDouble(High_2,Digits)+1*Poin;
   double ShortStopLoss=NormalizeDouble(Low_1,Digits)+15*Poin;

//+------------------------------------------------------------------+
//| implementing exit signals                                  |
//+------------------------------------------------------------------+

//------------- Closing Buy --------------------
   
      if(Ask<Lowest_Low || Ask<EMA_1 || Ask<EMA_0)
      if(CountLongs()>0)
      {
      CloseLongs();
      {
      if (AlertOn)
      {
      Alert( " "+Symbol()+" M"+Period()+": Bouncing Candle. Signal to SELL. BUY order has been closed");
      AlertOn = false;
      }
      }
      }
      
//------------- Closing Sell --------------------
      
      if(Bid>Highest_High || Bid>EMA_1 || Bid>EMA_0)
      if(CountShorts()>0)
      {
      CloseShorts();
      {
      if (AlertOn)
      {
      Alert( " "+Symbol()+" M"+Period()+": Bouncing Candle. Signal to BUY. SELL order has been closed");
      AlertOn = false;
      }
      }
      }

//------------------------------------------------------------------+
//| Working only at a new candle rather than at every tick                                            |
//+------------------------------------------------------------------+

   if(timeprev==Time[0])//Time[0] is time of the cuurent bar
   return(0);
   timeprev=Time[0];
   //This means instead of working (ie moving TSL) after every tick, work only after
   //a new candle.
   //it makes testing faster and test profit results higher.
   //It means you can use your code only once for each bar, usually first tick.
   //Any other tick code doesn't work. Sometimes it is very usefull.
   //Any action in start function afer this code will be performed once within the Bars
   //regardless of the time you specify

//+------------------------------------------------------------------+
//| deleting unnecessary pending orders                                   |
//+------------------------------------------------------------------+

      int total2 = OrdersTotal()-1;

      for (int cnt3 = total2 ; cnt3 >= 0 ; cnt3--)
      {
      OrderSelect(cnt3,SELECT_BY_POS,MODE_TRADES);
      if (OrderMagicNumber() == MagicNumber)
      if(OrderSymbol()==Symbol())
      if(OrderType()!=OP_BUY || OrderType()!=OP_SELL)
      if(Hour()>=21 && Hour()<22) 
      {
      OrderDelete(OrderTicket());
      }
      }

//+------------------------------------------------------------------+
//| implementing entry signals                                  |
//+------------------------------------------------------------------+

//------------- Placing Buy --------------------
      
      //if(EMA_1>EMA_4 )//&& EMA_2>EMA_3 && EMA_3>EMA_4 && EMA_4>EMA_5 && EMA_5>EMA_6
      if(EMA_1<Close_1)
      if(EMA_2>=Low_2)
      //if(EMA_3<Close_3)
      if(Close_1>Open_1)
      //if(Close_2<Open_2)
      //if(Close_3>Open_3)
      //if(OrdersTotal()<MaxTrade)
      {
      OrderSend(Symbol(),OP_BUYSTOP,LotsOptimized(),NormalizeDouble(High_1,Digits)+(1*Poin),
      Slippage,LongStopLoss,0,EA_Name,MagicNumber,0,Blue);
      {
      if (AlertOn)
      {
      Alert( " "+Symbol()+" M"+Period()+": Bouncing Candle. Signal to BUY. BUYSTOP order has been placed");
      AlertOn = false;
      }
      }
      }

//------------- Placing Sell --------------------
      
      //if(EMA_1<EMA_4 )//&& EMA_2<EMA_3 && EMA_3<EMA_4 && EMA_4<EMA_5 && EMA_5<EMA_6
      if(EMA_1>Close_1)
      if(EMA_2<=High_2)
      //if(EMA_3>Close_3)
      if(Close_1<Open_1)
      //if(Close_2>Open_2)
      //if(Close_3<Open_3)
      //if(OrdersTotal()<MaxTrade)
      {
      OrderSend(Symbol(),OP_SELLSTOP, LotsOptimized(),NormalizeDouble(Low_1,Digits)-(1*Poin),
      Slippage,ShortStopLoss,0,EA_Name,MagicNumber,0,Red);
      {
      if (AlertOn)
      {
      Alert( " "+Symbol()+" M"+Period()+": Bouncing Candle. Signal to SELL. SELLSTOP order has been placed");
      AlertOn = false;
      }
      }
      }
      
//----------------------------
      
 return(0);
 } //End of Start function

//+------------------------------------------------------------------+
//| calculating orders breakeven                                   |
//+------------------------------------------------------------------+

void Breakeven()
   {
   int totalorders = OrdersTotal();
   for(int i=totalorders-1;i>=0;i--)
   {
   
   if(BreakEven== false)
   continue;   
   
   if(BreakEvenTrigger == 0)
   continue;   
   
   if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   continue;

   if(OrderSymbol()!=Symbol())
   continue;
   
   if(OrderMagicNumber()!=MagicNumber)
   continue;
   
   if(BreakEven== true)
   
   if(BreakEvenTrigger > 0)

   if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   
   if(OrderSymbol()==Symbol())
   
   if(OrderMagicNumber()==MagicNumber)
   {   
   
   if(OrderType() == OP_BUY)
   
   if(Ask<OrderOpenPrice())
   continue;

   if(OrderStopLoss()>OrderOpenPrice()) 
   continue;
     
   if(Ask>OrderOpenPrice())

   if(OrderStopLoss()<OrderOpenPrice() || OrderStopLoss()==0) 

   if(NormalizeDouble((Ask-OrderOpenPrice()),Digits)>=(BreakEvenTrigger*Poin))
   { 

   OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Green);
   Print( "Order moved to breakeven : ", OrderStopLoss());
   }
   
   if(OrderType() == OP_SELL)
   
   if(Bid>OrderOpenPrice())
   continue;

   if(OrderStopLoss()<OrderOpenPrice()) 
   continue;
     
   if(Bid<OrderOpenPrice())   
   
   if(OrderStopLoss()>OrderOpenPrice() || OrderStopLoss()==0) 
   
   if(NormalizeDouble((OrderOpenPrice()-Bid),Digits)>=(BreakEvenTrigger*Poin))
   { 
   
   OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Green);
   
   }
   }
   }
   return;
   }

//+------------------------------------------------------------------+
//| modifying orders trailing stop                                   |
//+------------------------------------------------------------------+
 
void Trailingalls(int start,int stop)
{
 int profit;
 double stoptrade;
 double stopcal;
 
 if(stop==0)
  return;
 
 int trade;
 for(trade=OrdersTotal()-1;trade>=0;trade--)
 {
  if(!OrderSelect(trade,SELECT_BY_POS,MODE_TRADES))
   continue;

  if(OrderSymbol()!=Symbol())
   continue;
  
  if(OrderMagicNumber()!=MagicNumber)
   continue;
   
  if(TrailingAlls== false)
  continue;   

  if(OrderSymbol()==Symbol())
  
  if(OrderMagicNumber()==MagicNumber)
  
  if(TrailingAlls== true)
   
  {
  if(OrderType()==OP_BUY)
  {
   profit=NormalizeDouble((Bid-OrderOpenPrice())/Poin,0);
   if(profit<start)
    continue;
    
   stoptrade=OrderStopLoss();
   stopcal=Bid-(stop*Poin);
   
   if(stoptrade==0||(stoptrade!=0 && stopcal>stoptrade))
      
      //RefreshRates();
      OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
  }
  
  if(OrderType()==OP_SELL)
  {
   profit=NormalizeDouble((OrderOpenPrice()-Ask)*Poin,0);
   if(profit<start)
    continue;
    
   stoptrade=OrderStopLoss();
   stopcal=Ask+(stop*Poin);
   
   if(stoptrade==0||(stoptrade!=0 && stopcal<stoptrade))
       //RefreshRates();
       OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
  }
  
 }
}
}
//+------------------------------------------------------------------+
//| closing orders                                   |
//+------------------------------------------------------------------+

void CloseLongs()
{
 int trade;
 for(trade=OrdersTotal()-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);

  if(OrderSymbol()!=Symbol()|| OrderMagicNumber()!=MagicNumber)
   continue;
   
  if(OrderType()==OP_BUY)
   OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,SkyBlue);
 }
}

//---------------------------

void CloseShorts()
{
 int trade;
 for(trade=OrdersTotal()-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);

  if(OrderSymbol()!=Symbol()|| OrderMagicNumber()!=MagicNumber)
   continue;

  if(OrderType()==OP_SELL)
   OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Orange);
 }
}

//+------------------------------------------------------------------+
//| counting open orders                                   |
//+------------------------------------------------------------------+

int CountLongs()
{
 int count=0;
 int trade;
 for(trade=OrdersTotal()-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol()|| OrderMagicNumber()!=MagicNumber)
   continue;
   
  if(OrderType()==OP_BUY)
   count++;
 }
 return(count);
}

//--------------------------------

int CountShorts()
{
 int count=0;
 int trade;
 for(trade=OrdersTotal()-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol()|| OrderMagicNumber()!=MagicNumber)
   continue;
   
  if(OrderType()==OP_SELL)
   count++;
 }
 return(count);
}

//+------------------------------------------------------------------+