//+------------------------------------------------------------------+
//|                        Guppy Mulitple Moving Average (Long).mq4 |
//|                                  Code written by - Matt Trigwell |
//|                                                                  |
//+------------------------------------------------------------------+

// ***** INSTRUCTIONS *****
// Add the GMMA Short indicator and the GMMA Long indicator to your charts.
// This is the GMMA Long indicator

// ***** For information on how to use this fantastic indicator *****
// http://www.guppytraders.com/
// http://www.market-analyst.com/kb/article.php/Guppy_Multiple_Moving_Average
// http://tradermike.net/2004/05/another_look_at_multiple_moving_averages


#property copyright "Code written by - Matt Trigwell"

#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 DarkGray
#property indicator_color2 DarkGray
#property indicator_color3 DarkGray
#property indicator_color4 DarkGray
#property indicator_color5 DarkGray
#property indicator_color6 DarkGray

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE,EMPTY,1);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE,EMPTY,1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_LINE,EMPTY,1);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_LINE,EMPTY,1);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexStyle(4,DRAW_LINE,EMPTY,1);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexStyle(5,DRAW_LINE,EMPTY,1);
   SetIndexBuffer(5,ExtMapBuffer6);
//----
   return(0);
  }

int deinit()
  {
   return(0);
  }

int start()
  {
   int i,j,limit,counted_bars=IndicatorCounted();
   
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for(i=0; i<limit; i++){
      ExtMapBuffer1[i]=iMA(NULL,0,30,0,MODE_EMA,PRICE_CLOSE,i);
      ExtMapBuffer2[i]=iMA(NULL,0,35,0,MODE_EMA,PRICE_CLOSE,i);
      ExtMapBuffer3[i]=iMA(NULL,0,40,0,MODE_EMA,PRICE_CLOSE,i);
      ExtMapBuffer4[i]=iMA(NULL,0,45,0,MODE_EMA,PRICE_CLOSE,i);
      ExtMapBuffer5[i]=iMA(NULL,0,50,0,MODE_EMA,PRICE_CLOSE,i);
      ExtMapBuffer6[i]=iMA(NULL,0,60,0,MODE_EMA,PRICE_CLOSE,i);
   }
   

   return(0);
  }
//+------------------------------------------------------------------+