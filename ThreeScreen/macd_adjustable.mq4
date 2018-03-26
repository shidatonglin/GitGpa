//+------------------------------------------------------------------+
//|                                         macd_adjustable1.mq4.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property  indicator_buffers 4
#property indicator_color1 DodgerBlue
#property indicator_color2 LightSalmon
#property  indicator_color3  White
#property  indicator_color4  Red
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 1
#property indicator_width4 2

//---- indicator parameters
extern int FastEMA=12;
extern int SlowEMA=24;
extern int SignalSMA=9;

extern int Histo_Size = 3;//1=Standard Lines & Histo
extern bool Show_MACDLine = true; 
extern bool Show_MACDSigLine = true;

//---- indicator buffers
double     ind_Buffer1[];
double     ind_Buffer2[];
double     ind_buffer3a[];
double     ind_buffer3b[];
double     ind_buffer4[];
double     ind_buffer5[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
      //---- 2 additional buffers are used for counting.
   IndicatorBuffers(6);
//---- drawing settings

   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexDrawBegin(0,SignalSMA);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexDrawBegin(1,SignalSMA);
  /* SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ind_Buffer1);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,ind_Buffer2);*/
   if(Show_MACDLine ==true){Show_MACDLine=DRAW_LINE; }
   else {Show_MACDLine=DRAW_NONE; }
   SetIndexBuffer(2,ind_Buffer1);
   SetIndexStyle(2,Show_MACDLine);
   
   if(Show_MACDSigLine ==true){Show_MACDSigLine=DRAW_LINE; }
   else {Show_MACDSigLine=DRAW_NONE; }
   SetIndexBuffer(3,ind_Buffer2);
   SetIndexStyle(3,Show_MACDSigLine);
   
   
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);
   
//---- 5 indicator buffers mapping
   SetIndexBuffer(0,ind_buffer3a);
      SetIndexBuffer(1,ind_buffer3b);
      SetIndexBuffer(2,ind_buffer4);      
      SetIndexBuffer(3,ind_buffer5);
      SetIndexBuffer(4,ind_Buffer1);      
      SetIndexBuffer(5,ind_Buffer2);
      //Print("cannot set indicator buffers!");
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD  ("+FastEMA+","+SlowEMA+","+SignalSMA+")");
//---- initialization done
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int limit;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- macd counted in the 1-st additional buffer
   for(int i=0; i<limit; i++)
      ind_buffer4[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)
                        -iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
//---- signal line counted in the 2-nd additional buffer
   for(int i=0; i<limit; i++)
      ind_buffer5[i]=iMAOnArray(ind_buffer4,Bars,SignalSMA,0,MODE_EMA,i);
//---- main loop
   double value=0;
   for(int i=0; i<limit; i++)
      {
         ind_buffer3a[i]=0.0;
         ind_buffer3b[i]=0.0;      
         value=ind_buffer4[i]-ind_buffer5[i];
         if (value>0) ind_buffer3a[i]=value*Histo_Size;
         if (value<0) ind_buffer3b[i]=value*Histo_Size;
      }   
//---- done
   //return(0);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
