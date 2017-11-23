//+------------------------------------------------------------------+
//|                                         smFisherTransform3nr.mq4 |
//|                                 Copyright © 2009.07.06, SwingMan |
//|                                                fxfariz@gmail,com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009.07.06, SwingMan"
#property link      ""
//--- try no repaint, nbars=200
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
//------------------------------------------------------------------*/

#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color2  Aqua
#property  indicator_color3  Red
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_width2 2
#property indicator_width3 2

//-------------------------------------------------------------------
extern int period=21;
extern bool alarm=false;
extern bool EhlersFormula = true;
extern int nBars=200;
//-------------------------------------------------------------------

double         ExtBuffer0[];
double         ExtBuffer1[];
double         ExtBuffer2[];
double alertBar;
double last;

int init()
  {
   
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   IndicatorDigits(Digits+1);

   SetIndexBuffer(0,ExtBuffer0);
   SetIndexBuffer(1,ExtBuffer1);
   SetIndexBuffer(2,ExtBuffer2);

   IndicatorShortName("smFisherTransform3nr" +" ("+period+")");
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);

   return(0);
  }


int start()
{
   int    limit;
//   int    counted_bars=IndicatorCounted();
   double prev,current,old;
   double Value=0,Value1=0,Value2=0,Fish=0,Fish1=0,Fish2=0;
   double price;
   double MinL=0;
   double MaxH=0;  
   

//   if(counted_bars>0) counted_bars--;
//   limit=Bars-counted_bars;

limit=nBars;
   //for(int i=0; i<Bars; i++)
   for(int i=0; i<limit; i++)
    {
      MaxH = High[Highest(NULL,0,MODE_HIGH,period,i)];
      MinL = Low[Lowest(NULL,0,MODE_LOW,period,i)];
      price = (High[i]+Low[i])/2;
      
      if (EhlersFormula == false) {      
         if(MaxH-MinL == 0) Value = 0.33*2*(0-0.5) + 0.67*Value1; 
         else Value = 0.33*2*((price-MinL)/(MaxH-MinL)-0.5) + 0.67*Value1;     
      }
      else
      {
         if(MaxH-MinL == 0) Value = 0.5*2*(0-0.5) + 0.5*Value1; 
         else Value = 0.25*2*((price-MinL)/(MaxH-MinL)-0.5) + 0.75*Value1;     
         //else Value = 0.5*2*((price-MinL)/(MaxH-MinL)-0.5) + 0.5*Value1; //original Ehlers
      }
      
      if (EhlersFormula == false)
         Value=MathMin(MathMax(Value,-0.999),0.999); 
      else
      if (EhlersFormula == true) {
         if (Value >  0.9999) Value =  0.9999;
         if (Value < -0.9999) Value = -0.9999;
         
      }
      
      if (EhlersFormula == false) {
         if(1-Value == 0) ExtBuffer0[i]=0.5+0.5*Fish1;
         else ExtBuffer0[i]=0.5*MathLog((1+Value)/(1-Value))+0.5*Fish1;
      }
      else
      {
         if(1-Value == 0) ExtBuffer0[i]=0.25+0.75*Fish1;
         else ExtBuffer0[i]=0.25*MathLog((1+Value)/(1-Value))+0.75*Fish1; //original Ehlers is 0.25/0.5...?
      }
      
      Value1=Value;
      Fish1=ExtBuffer0[i];
    }


   bool up=true;
   //for(i=Bars; i>=0; i--) {
   for(i=limit; i>=0; i--) {
      current=ExtBuffer0[i];
      prev=ExtBuffer0[i+1];
           
      if (((current<0)&&(prev>0))||(current<0))   up= false;   
      if (((current>0)&&(prev<0))||(current>0))   up= true;
     
      if(!up) {
         ExtBuffer2[i]=current;
         ExtBuffer1[i]=0.0;
         if (alarm == true) {
            if (i==0 && prev != 2 && ExtBuffer1[i] == 0 && Bars>alertBar) {
               Alert("ForexTrend Changing Down on ",Period()," ",Symbol());
               alertBar = Bars;
               last = 2;
            }
         }
      }
        
      else {
         ExtBuffer1[i]=current;
         ExtBuffer2[i]=0.0;
         if (alarm == true) {
            if (i==0 && last != 1 && ExtBuffer2[i] == 0 && Bars>alertBar) {
               Alert("ForexTrend Changing Up on ",Period()," ",Symbol());
               alertBar = Bars;
               last = 1;
            }
         }
      }
   }

   return(0);
}