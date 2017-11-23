//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2004, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
//---- indicator settings  // HELP DONE BY CJA
#property  indicator_chart_window
#property  indicator_buffers 6
#property  indicator_color1  clrBlue
#property  indicator_color2  clrRed
#property  indicator_color3  clrBlue
#property  indicator_color4  clrRed
#property  indicator_color5  clrDodgerBlue
#property  indicator_color6  clrMagenta
//---- indicator parameters
extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalSMA=9;
//---- indicator buffers
double     ind_buffer1[];
double     ind_buffer2[];
double     ind_buffer3[];
double     ind_buffer4[];

double     CrossUp[];
double     CrossDown[];

double macdnow, macd_signow, macdprevious, macd_sigprevious, macdafter, macd_sigafter;
double Range, AvgRange;
int counter;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexDrawBegin(1,SignalSMA);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
//---- indicator buffers mapping
   if(!SetIndexBuffer(0,ind_buffer1) && !SetIndexBuffer(1,ind_buffer2))
      Print("cannot set indicator buffers!");

   SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexArrow(2, 108);
   SetIndexBuffer(2, ind_buffer3);

   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexArrow(3, 108);
   SetIndexBuffer(3, ind_buffer4);
   
   SetIndexStyle(4, DRAW_ARROW, STYLE_SOLID, 1);
   SetIndexArrow(4, 217);
   SetIndexBuffer(4, CrossUp);

   SetIndexStyle(5, DRAW_ARROW, STYLE_SOLID, 1);
   SetIndexArrow(5, 218);
   SetIndexBuffer(5, CrossDown);
   
  
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- macd counted in the 1-st buffer

   for(int i=0; i<limit; i++)
      ind_buffer1[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
      
     //---- signal line counted in the 2-nd buffer
   for(i=0; i<limit; i++)
      ind_buffer2[i]=iMAOnArray(ind_buffer1,Bars,SignalSMA,0,MODE_SMA,i);
      
   for (i=0; i<limit; i++)
   {
      ind_buffer3[i] = EMPTY_VALUE; ind_buffer4[i] = EMPTY_VALUE; 
      if (ind_buffer1[i] > ind_buffer2[i] && ind_buffer1[i+1] < ind_buffer2[i+1])
         ind_buffer3[i] = Low[i] - 1 * Point;
         
      if (ind_buffer1[i] < ind_buffer2[i] && ind_buffer1[i+1] > ind_buffer2[i+1])
         ind_buffer4[i] = High[i] + 1 * Point;
       
   } 
   
   
    for(i = 0; i <= limit; i++) {
   
      counter=i;
      Range=0;
      AvgRange=0;
      for (counter=i ;counter<=i+9;counter++)
      {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10; //Range=AvgRange/10;
       
      macdnow = iMACD(Symbol(), Period(), FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, i);
      macdprevious = iMACD(Symbol(), Period(), FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, i+1);
      macdafter = iMACD(Symbol(), Period(), FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, i-1);
      

      macd_signow = iMACD(Symbol(), Period(), FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, i);
      macd_sigprevious = iMACD(Symbol(), Period(), FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, i+1);
      macd_sigafter = iMACD(Symbol(), Period(), FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, i-1);
      
           CrossUp[i] = EMPTY_VALUE; CrossDown[i] = EMPTY_VALUE;       
      if ((macdnow > macd_signow) && (macdprevious < macd_sigprevious) && (macdafter > macd_sigafter)) {
                   CrossUp[i] = Low[i]  - 1 * Point; //- Range*0.618;                  
           }
      else if ((macdnow < macd_signow) && (macdprevious > macd_sigprevious) && (macdafter < macd_sigafter)) {
                   CrossDown[i] = High[i] +  1 * Point; //Range*0.618;
           }
               
              	 
      }  
//---- done
   return(0);
  }
  
 