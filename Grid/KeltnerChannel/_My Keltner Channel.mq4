//+------------------------------------------------------------------+
//|                                          _My Keltner Channel.mq4 |
//|                         Copyright © 2008, Winning Software Corp. |
//|                                   http://www.winningsoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Winning Software Corp."
#property link      "http://www.winningsoftware.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 LightGray
#property indicator_color2 White
#property indicator_color3 LightGray
//---- input parameters
extern int       TimeFrame = 0;
extern int       Length    = 21;
extern int       MA_Type   = 0;
extern int       Shift     = 0;
extern int       Price     = 0;
extern double    TimesATR  = 4.0;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle ( 0, DRAW_LINE, STYLE_DOT );
   SetIndexBuffer( 0, ExtMapBuffer1 );
   SetIndexStyle ( 1, DRAW_LINE, STYLE_DOT );
   SetIndexBuffer( 1, ExtMapBuffer2 );
   SetIndexStyle ( 2, DRAW_LINE, STYLE_DOT );
   SetIndexBuffer( 2, ExtMapBuffer3 );
   
   SetIndexLabel ( 0, Length + " KChanUp" );
   SetIndexLabel ( 1, Length + " KChanMid");
   SetIndexLabel ( 2, Length + " KChanLow");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars = IndicatorCounted();
   int    limit        = Bars - counted_bars;
   int    i = 0;
   
//----Check for possible errors
   if ( counted_bars < 0 ) return ( -1 );
      
//----Last counted bar will be recounted
   if ( counted_bars > 0 ) counted_bars-- ;
   
   double MA = 0;    
   double ATR =0; iATR ( NULL, TimeFrame, Length, i );
   
//---Main calculation Loop
   for (i = 0; i < limit; i++ )
      
       { 
         MA  = iMA ( NULL, TimeFrame, Length, Shift, MA_Type, Price, i );
         ATR = iATR( NULL, TimeFrame, Length, i );
              
         ExtMapBuffer1[i] = MA + ATR * TimesATR ;
         
         ExtMapBuffer2[i] = MA;
                                   
         ExtMapBuffer3[i] = MA - ATR * TimesATR ;
       }                         

   
   return(0);
  }
//+------------------------------------------------------------------+