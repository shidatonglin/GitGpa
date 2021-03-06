//+------------------------------------------------------------------+
//|                                                       tester.mq4 |
//|                                                Alexander Fedosov |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Alexander Fedosov"
#property strict
#include <trading.mqh>      //Support library for trade operations
//+------------------------------------------------------------------+
//| Parameters                                              |
//+------------------------------------------------------------------+
input int             SL = 40;               // Stop loss
input int             TP = 70;               // Take profit
input bool            Lot_perm=true;         // Lot of balance?
input double          lt=0.01;               // Lot
input double          risk = 2;              // Risk of deposit, %
input int             slippage= 5;           // Slippage
input int             magic=2356;            // Magic number
input int             period=8;              // RSI indicator period
input ENUM_TIMEFRAMES tf=PERIOD_CURRENT;     // Working timeframe
int dg,index_rsi,index_ac;
trading tr;
//+------------------------------------------------------------------+
//| Expert Advisor initialization function                           |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- determining variables for auxiliary class of trading functions
//--- language for displaying errors, Russian of by default.
   tr.ruErr=true;
   tr.Magic=magic;
   tr.slipag=slippage;
   tr.Lot_const=Lot_perm;
   tr.Lot=lt;
   tr.Risk=risk;
//--- number of attempts.
   tr.NumTry=5;
//--- determining decimal places on the current chart
   dg=tr.Dig();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Main calculation function                                          |
//+------------------------------------------------------------------+
void OnTick()
  {
   depth_trend();
   speed_ac();
//--- check for presence of open orders
   if(OrdersTotal()<1)
     {
      //--- check of buy conditions
      if(Buy())
         tr.OpnOrd(OP_BUY,tr.Lots(),Ask,SL*dg,TP*dg);
      //--- check of sell conditions
      if(Sell())
         tr.OpnOrd(OP_SELL,tr.Lots(),Bid,SL*dg,TP*dg);
     }
//--- are there open orders?
   if(OrdersTotal()>0)
     {
      //--- check and close sell orders which meet closing conditions.
      if(Sell_close())
         tr.ClosePosAll(OP_SELL);
      //--- check and close buy orders which meet closing conditions.
      if(Buy_close())
         tr.ClosePosAll(OP_BUY);
     }
  }
//+------------------------------------------------------------------+
//| Function for determining the trend depth                         |
//+------------------------------------------------------------------+
void depth_trend()
  {
//--- determining buy index
   double rsi=iRSI(Symbol(),tf,period,PRICE_CLOSE,0);
   index_rsi = 0;
   if(rsi>90.0) index_rsi=4;
   else if(rsi>80.0)
      index_rsi=3;
   else if(rsi>70.0)
      index_rsi=2;
   else if(rsi>60.0)
      index_rsi=1;
   else if(rsi<10.0)
      index_rsi=-4;
   else if(rsi<20.0)
      index_rsi=-3;
   else if(rsi<30.0)
      index_rsi=-2;
   else if(rsi<40.0)
      index_rsi=-1;
  }
//+------------------------------------------------------------------+
//| Function for determining the trend speed                         |
//+------------------------------------------------------------------+
void speed_ac()
  {
   double ac[];
   ArrayResize(ac,5);
   for(int i=0; i<5; i++)
      ac[i]=iAC(Symbol(),tf,i);
//---
   index_ac=0;
//--- buy signal
   if(ac[0]>ac[1])
      index_ac=1;
   else if(ac[0]>ac[1] && ac[1]>ac[2])
      index_ac=2;
   else if(ac[0]>ac[1] && ac[1]>ac[2] && ac[2]>ac[3])
      index_ac=3;
   else if(ac[0]>ac[1] && ac[1]>ac[2] && ac[2]>ac[3] && ac[3]>ac[4])
      index_ac=4;
//--- sell signal
   else if(ac[0]<ac[1])
      index_ac=-1;
   else if(ac[0]<ac[1] && ac[1]<ac[2])
      index_ac=-2;
   else if(ac[0]<ac[1] && ac[1]<ac[2] && ac[2]<ac[3])
      index_ac=-3;
   else if(ac[0]<ac[1] && ac[1]<ac[2] && ac[2]<ac[3] && ac[3]<ac[4])
      index_ac=-4;
  }
//+------------------------------------------------------------------+
//| Function for checking buy conditions                             |
//+------------------------------------------------------------------+
bool Buy()
  {
   bool res=false;
   if((index_rsi==2 && index_ac>=1) || (index_rsi==3 && index_ac==1))
      res=true;
   return (res);
  }
//+------------------------------------------------------------------+
//| Function for checking sell conditions                              |
//+------------------------------------------------------------------+
bool Sell()
  {
   bool res=false;
   if((index_rsi==-2 && index_ac<=-1) || (index_rsi==-3 && index_ac==-1))
      res=true;
   return (res);
  }
//+------------------------------------------------------------------+
//| Function for checking buy position closing conditions            |
//+------------------------------------------------------------------+
bool Buy_close()
  {
   bool res=false;
   if(index_rsi>2 && index_ac<0)
      res=true;
   return (res);
  }
//+------------------------------------------------------------------+
//| Function for checking sell position closing conditions             |
//+------------------------------------------------------------------+
bool Sell_close()
  {
   bool res=false;
   if(index_rsi<-2 && index_ac>0)
      res=true;
   return (res);
  }
//+------------------------------------------------------------------+
