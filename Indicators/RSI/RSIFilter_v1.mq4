///+------------------------------------------------------------------
//|                                                 RSIFilter_v1.mq4 
//|                                  Copyright © 2006, Forex-TSD.com 
//|                         Written by IgorAD,igorad2003@yahoo.co.uk 
//|            http://finance.groups.yahoo.com/group/TrendLaboratory 
//+------------------------------------------------------------------

///+------------------------------------------------------------------
//|                                                edited by masemus 
//+------------------------------------------------------------------

#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 1
#property indicator_buffers 4
#property indicator_color1 DeepPink
#property indicator_color2 LightPink
#property indicator_color3 LightSkyBlue
#property indicator_color4 DodgerBlue

//---- input parameters
extern int TF=0;
extern int PeriodRSI=5;
//---- indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
string TimeFrameStr;
//+------------------------------------------------------------------

//| Custom indicator initialization function                         

//+------------------------------------------------------------------

int init()
  {
//---- indicators
  SetIndexStyle(0,DRAW_HISTOGRAM);
  SetIndexBuffer(0,ExtMapBuffer1);
  SetIndexStyle(1,DRAW_HISTOGRAM);
  SetIndexBuffer(1,ExtMapBuffer2);
  SetIndexStyle(2,DRAW_HISTOGRAM);
  SetIndexBuffer(2,ExtMapBuffer3);
  SetIndexStyle(3,DRAW_HISTOGRAM);
  SetIndexBuffer(3,ExtMapBuffer4);

switch(TF)
   {
      case 1 : TimeFrameStr="Period_M1"; break;
      case 5 : TimeFrameStr="Period_M5"; break;
      case 15 : TimeFrameStr="Period_M15"; break;
      case 30 : TimeFrameStr="Period_M30"; break;
      case 60 : TimeFrameStr="Period_H1"; break;
      case 240 : TimeFrameStr="Period_H4"; break;
      case 1440 : TimeFrameStr="Period_D1"; break;
      case 10080 : TimeFrameStr="Period_W1"; break;
      case 43200 : TimeFrameStr="Period_MN1"; break;
      default : TimeFrameStr="Current Timeframe"; TF=0;
   }
   IndicatorShortName("RSI Filter ("+PeriodRSI+","+TimeFrameStr+")");  

 
//----
   return(0);
  }

//+------------------------------------------------------------------

//| RSIFilter_v1                                                     

//+------------------------------------------------------------------
int start()
  {
   int    counted_bars=IndicatorCounted();
//----

for (int i = 0; i < 300; i++){
   ExtMapBuffer1[i]=0;
   ExtMapBuffer2[i]=0;
   ExtMapBuffer3[i]=0;
   ExtMapBuffer4[i]=0;

   double RSI0;
   
   RSI0=iRSI(NULL,TF,PeriodRSI,PRICE_CLOSE,i);
   	
	  if (RSI0>=60)ExtMapBuffer4[i]=1;
	  if (RSI0<=40)ExtMapBuffer1[i]=1;
	  if (RSI0>50 && RSI0<60)ExtMapBuffer3[i]=1;
	  if (RSI0<50 && RSI0>40){ExtMapBuffer2[i]=1;}
	  
	}
	return(0);	
 }




//+------------------------------------------------------------------+