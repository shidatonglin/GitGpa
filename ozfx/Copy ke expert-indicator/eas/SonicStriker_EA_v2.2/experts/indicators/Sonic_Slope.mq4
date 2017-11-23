
//+------------------------------------------------------------------+
//|                        Sonic Slope Directional Line              |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2008, SonicDeejay"
#property  link      ""
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  RoyalBlue
#property  indicator_color2  OrangeRed
#property  indicator_color3  LightSlateGray
#property  indicator_minimum 0
#property  indicator_maximum 1



//SLOPE Direction Line Setting
extern int period = 30;
extern int method = 3;
extern int price = 0;

//---- indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   
//---- drawing settings

   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,4,indicator_color1);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexLabel(0,"BuyZone");
   
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,4,indicator_color2);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexLabel(1,"SellZone");
   
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,4,indicator_color3);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexLabel(2,"NoTradeZone");   

//---- name for DataWindow and indicator subwindow label

   IndicatorShortName("Sonic Slope Directional");   
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Calculations                                    |
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
 
//---- main loop
   
for(int i=0; i<limit; i++)
{
ExtMapBuffer1[i] = 0; ExtMapBuffer2[i] = 0;ExtMapBuffer3[i] = 0;


double  SLDRED = iCustom( NULL,0,"Slope Direction Line",period,method,price,0, i); 
double  SLDBLU = iCustom( NULL,0,"Slope Direction Line",period,method,price,1, i); 
       

if (SLDBLU>SLDRED)ExtMapBuffer1[i]=2;
else if (SLDRED>SLDBLU)ExtMapBuffer2[i]=2;
else ExtMapBuffer3[i]=2;



}
return(0);
  }
//+------------------------------------------------------------------+















