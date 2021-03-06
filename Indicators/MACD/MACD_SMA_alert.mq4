//+------------------------------------------------------------------+
//|                                                     MACD_CCI.mq4 |
//|                                   Copyright � 2009, challenger78 |
//| 06/11/2009 klentz                                                |
//| CCI replaced by SMA since CCI was not really needed here         |
//+------------------------------------------------------------------+
#property  copyright "challenger78"

#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  DarkGreen
#property  indicator_color2  Crimson
#property  indicator_color3  Yellow

#property  indicator_minimum 0
#property  indicator_maximum 2

extern int FastLen = 144;
extern int SlowLen = 233;
extern int SMA = 21;
extern bool UseAlert = true;

double buffer1[], buffer2[], buffer3[];
int BARS;

int init()
{
   SetIndexStyle(0,DRAW_ARROW);    SetIndexArrow(0,110);    SetIndexBuffer(0,buffer1);    SetIndexEmptyValue(0,EMPTY_VALUE); 
   SetIndexStyle(1,DRAW_ARROW);    SetIndexArrow(1,110);    SetIndexBuffer(1,buffer2);    SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexStyle(2,DRAW_ARROW);    SetIndexArrow(2,110);    SetIndexBuffer(2,buffer3);    SetIndexEmptyValue(2,EMPTY_VALUE); 
   
   return(0);
}

int start()
{
   int limit;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
   limit = Bars - counted_bars;

   for(int i = 0; i < limit; i++)
   {
      double price_typical = (High[i] + Low[i] + Close[i]) / 3;   
      double sma_trend = price_typical - iMA(NULL, 0, SMA, 0, MODE_SMA, PRICE_TYPICAL, i);
      double ma_0 = iMA(NULL, 0, FastLen, 0, MODE_EMA, PRICE_CLOSE, i) - 
                     iMA(NULL, 0, SlowLen, 0, MODE_EMA, PRICE_CLOSE, i);
      double ma_1 = iMA(NULL, 0, FastLen, 0, MODE_EMA, PRICE_CLOSE, i + 1) - 
                     iMA(NULL, 0, SlowLen, 0, MODE_EMA, PRICE_CLOSE, i + 1);
                         
      buffer1[i]=EMPTY_VALUE;    buffer2[i]=EMPTY_VALUE;      buffer3[i]=EMPTY_VALUE;    
      
      if (sma_trend > 0 && ma_0 > ma_1) buffer1[i] = 1;  
      else if (sma_trend < 0 && ma_0 < ma_1) buffer2[i] = 1;
      else buffer3[i] = 1;
   }
   if(UseAlert == true && BARS != Bars)
   {
      if(buffer1[1] != EMPTY_VALUE && buffer1[2] == EMPTY_VALUE && buffer2[1] == EMPTY_VALUE && buffer3[1] == EMPTY_VALUE)
      {
         Alert(" An indicator changes its color to: GREEN\n");
         BARS = Bars;
      }
      else if (buffer1[1] == EMPTY_VALUE && buffer2[1] !=EMPTY_VALUE && buffer2[2] == EMPTY_VALUE && buffer3[1] == EMPTY_VALUE)
      {
         Alert(" An indicator changes its color to: RED\n");
         BARS = Bars;
      }
      else if(buffer1[1] == EMPTY_VALUE && buffer2[1] == EMPTY_VALUE && buffer3[1] != EMPTY_VALUE && buffer3[2] == EMPTY_VALUE)
      {
         Alert(" An indicator changes its color to: YELLOW\n");
         BARS = Bars;
      }
   }    
             
   return(0);
}

