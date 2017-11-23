//+------------------------------------------------------------------+
//|                                           FX Sniper's T3 CCI.mq4 |
//|                                                        FX Sniper |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "FX Sniper:  T3-CCI :-)"
#property link      "http://dunno.com  :-)/"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property  indicator_color2  Green
#property  indicator_color3  Red
//----
extern int CCI_Period = 14;
extern int T3_Period = 5;
extern double b = 0.618;
//----
double e1, e2, e3, e4, e5, e6;
double c1, c2, c3, c4;
double n, w1, w2, b2, b3;
double cci[];
double cciHup[];
double cciHdn[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators setting
    SetIndexBuffer(0, cci);
    SetIndexBuffer(1, cciHup);
    SetIndexBuffer(2, cciHdn);
//----
    SetIndexStyle(0, DRAW_LINE);
    SetIndexStyle(1, DRAW_HISTOGRAM);
    SetIndexStyle(2, DRAW_HISTOGRAM); 
//----        
    IndicatorShortName("FXST3CCI(" + CCI_Period + ", " + T3_Period + ")");
    SetIndexLabel(0, "FXST3CCI");     
   SetIndexLabel(1, NULL);
   SetIndexLabel(2, NULL);   
//---- variable reset
    b2 = b*b;
    b3 = b2*b;
    c1 = -b3;
    c2 = (3*(b2 + b3));
    c3 = -3*(2*b2 + b + b3);
    c4 = (1 + 3*b + b3 + 3*b2);
    n = T3_Period;
//----
    if(n < 1) 
        n = 1;
    n = 1 + 0.5*(n - 1);
    w1 = 2 / (n + 1);
    w2 = 1 - w1;    
//----
    return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars = IndicatorCounted();
//---- check for possible errors
   if(counted_bars < 0) 
       return(-1);
//---- last counted bar will be recounted
   if(counted_bars > 0) 
       counted_bars--;
   limit = Bars - counted_bars;  
//---- indicator calculation
   for(int i = Bars - 1; i >= 0; i--)
     {   
       cci[i] = iCCI(NULL, 0, CCI_Period, PRICE_TYPICAL, i);
       e1 = w1*cci[i] + w2*e1;
       e2 = w1*e1 + w2*e2;
       e3 = w1*e2 + w2*e3;
       e4 = w1*e3 + w2*e4;
       e5 = w1*e4 + w2*e5;
       e6 = w1*e5 + w2*e6;    
       cci[i] = c1*e6 + c2*e5 + c3*e4 + c4*e3;  
       //----
       if(cci[i] >= 0)
           cciHup[i] = cci[i];
       else
           cciHup[i] = 0;   
       //----
       if(cci[i] < 0 )
           cciHdn[i] = cci[i];
       else
           cciHdn[i] = 0; 
     }   
//----
   return(0);
  }
//+------------------------------------------------------------------+