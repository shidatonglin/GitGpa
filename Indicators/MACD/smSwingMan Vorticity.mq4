//+------------------------------------------------------------------+
//|                                         smSwingMan Vorticity.mq4 |
//|                                 Copyright © 2009.07.06, SwingMan |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009.07.06, SwingMan"
#property link      ""

// no repaint version: limit =200
/*--------------------------------------------------------------------
Source code:
//+------------------------------------------------------------------+
//|                                           fxfariz_scalpingM5.mq4 |
//|                                     fxfariz a.k.a warrior trader |
//|                                                fxfariz@gmail,com |
//+------------------------------------------------------------------+
#property copyright "fxfariz a.k.a warrior trader"
#property link      "fxfariz@gmail,com"

- Alert improvement: swissly, post #2258
http://www.forexfactory.com/showthread.php?t=165948&page=151
- Name from: TudorGirl_Vorticity
//------------------------------------------------------------------*/

#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Blue
#property  indicator_color2  Red
#property indicator_width1 2
#property indicator_width2 2
#property indicator_minimum 0.0
#property indicator_maximum 2.0

//-------------------------------------------------------------------
extern int period=8;
extern bool alarm=false;
extern int nBars = 200;
extern int arrowUP = 110;
extern int arrowDN = 110;
//-------------------------------------------------------------------

double         ExtBuffer0[];
double         ExtBuffer1[];
double         ExtBuffer2[];
double alertBar;
double last;

int init()
{  
   IndicatorDigits(0);
   IndicatorBuffers(3);

   SetIndexBuffer(0,ExtBuffer1); SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,arrowUP);
   SetIndexBuffer(1,ExtBuffer2); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,arrowDN);
   SetIndexBuffer(2,ExtBuffer0);

   IndicatorShortName("SwingMan Vorticity" +" ("+period+")");
   SetIndexLabel(0,"Trend UP");
   SetIndexLabel(1,"Trend DN");

   return(0);
  }


int start()
{
   int    limit;
//   int    counted_bars=IndicatorCounted();
   double prev=0,current;
   double Value=0,Fish1=0;
   double price;
   double MinL=0;
   double MaxH=0;  
   

//   if(counted_bars>0) counted_bars--;
//   limit=Bars-counted_bars;

limit = nBars;
   //for(int i=0; i<Bars; i++)
   for(int i=0; i<limit; i++) {
      MaxH = High[Highest(NULL,0,MODE_HIGH,period,i)];
      MinL = Low[Lowest(NULL,0,MODE_LOW,period,i)];
      price = (High[i]+Low[i])/2;
      
      if(MaxH-MinL == 0) Value = 0.33*2*(0-0.5) + 0.67*prev; 
      else Value = 0.33*2*((price-MinL)/(MaxH-MinL)-0.5) + 0.67*prev;     
      
      Value=MathMin(MathMax(Value,-0.999),0.999); 
      
      if(1-Value == 0) ExtBuffer0[i]=0.5+0.5*Fish1;
      else ExtBuffer0[i]=0.5*MathLog((1+Value)/(1-Value))+0.5*Fish1;
     
      prev=Value;
      Fish1=ExtBuffer0[i];
   }


   bool trendUP = TRUE;
   for (i = limit; i >= 0; i--) {
      current = ExtBuffer0[i];
      prev    = ExtBuffer0[i + 1];
      
      if ((current < 0.0 && prev > 0.0) || current < 0.0) trendUP = FALSE;
      if ((current > 0.0 && prev < 0.0) || current > 0.0) trendUP = TRUE;
      
      if (trendUP) {
         ExtBuffer1[i] = 1.0;
         ExtBuffer2[i] = EMPTY_VALUE;
         if (alarm == true) {
            if (i==0 && prev != 2 && ExtBuffer1[i] == 1.0 && Bars>alertBar) {
               Alert("(smVorti) Trend Changing Down on ",Period()," ",Symbol());
               alertBar = Bars;
               last = 2;
            }
         }
      } 
      
      else {
         ExtBuffer2[i] = 1.0;
         ExtBuffer1[i] = EMPTY_VALUE;
         if (alarm == true) {
            if (i==0 && last != 1 && ExtBuffer2[i] == 1.0 && Bars>alertBar) {
               Alert("(smVorti) Trend Changing Up on ",Period()," ",Symbol());
               alertBar = Bars;
               last = 1;
            }
         }
      }
   }
   return(0);
}