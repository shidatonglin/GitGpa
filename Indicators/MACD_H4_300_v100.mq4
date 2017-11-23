//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2007, Igor Morozov"
#property  link      "http://www.herbspirit.com/mql"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  Lime
#property  indicator_color2  Red
#property  indicator_color3  Silver
#property  indicator_style3  STYLE_DOT
#property  indicator_level1  45	
#property  indicator_level2  30	
#property  indicator_level3  15	
#property  indicator_level4  -15	
#property  indicator_level5  -30	
#property  indicator_level6  -45	
#property  indicator_levelcolor  Gray
#property  indicator_levelstyle  STYLE_DOT
//---- indicator parameters
extern int FastEMA=5;
extern int SlowEMA=13;
extern int SignalSMA=1;
//---- indicator buffers
double     MacdBuffer[];
double     MacdBufferUp[];
double     MacdBufferDn[];
double     SignalBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_LINE);
   SetLevelValue(0,45);
   SetLevelValue(1,30);
   SetLevelValue(2,15);
   SetLevelValue(3,-15);
   SetLevelValue(4,-30);
   SetLevelValue(5,-45);
   SetIndexDrawBegin(1,SignalSMA);
   IndicatorDigits(Point+1);
//---- indicator buffers mapping
   SetIndexBuffer(0,MacdBufferUp);
   SetIndexBuffer(1,MacdBufferDn);
   SetIndexBuffer(2,SignalBuffer);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD H4-300("+FastEMA+","+SlowEMA+","+SignalSMA+")");
   SetIndexLabel(0,"MACD UP");
   SetIndexLabel(1,"MACD DN");
   SetIndexLabel(2,"Signal");
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
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   int macdlimit=limit;
   if(macdlimit<Bars-5)
   	macdlimit+=5;
   ArrayResize(MacdBuffer,macdlimit);
   ArraySetAsSeries(MacdBuffer,true);
//---- macd counted in the 1-st buffer
   for(int i=0; i<macdlimit; i++) {
      MacdBuffer[i]=(iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-
      		iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i))/Point;
//      Print("MACDBUFFER=",MacdBuffer[i]);
   }
   for(i=0;i<limit;i++)
   {
   	int j=i+1;
   	while(MacdBuffer[i]==MacdBuffer[j]&&j-i<=5)
   		j++;
   	if(MacdBuffer[i]>MacdBuffer[j])
   	{
   		MacdBufferUp[i]=MacdBuffer[i];
   		MacdBufferDn[i]=0;
   	}
   	else
   	{
   		MacdBufferDn[i]=MacdBuffer[i];
   		MacdBufferUp[i]=0;
   	}
   }
//---- signal line counted in the 2-nd buffer
   for(i=0; i<limit; i++)
      SignalBuffer[i]=iMAOnArray(MacdBuffer,Bars,SignalSMA,0,MODE_SMA,i);
//---- done
   return(0);
  }
//+------------------------------------------------------------------+