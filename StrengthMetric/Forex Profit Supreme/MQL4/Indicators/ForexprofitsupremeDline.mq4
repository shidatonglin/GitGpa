#property copyright "Copyright © Forexprofitsupreme"
#property link      "www.Forexprofitsupreme.com"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  Lime    
#property  indicator_color2  Magenta 
#property  indicator_color3  Yellow    
#property  indicator_color4  Yellow     




extern int FastLen = 12;
extern int SlowLen = 26;
extern int Length = 10;
extern int barsCount = 400;
extern double StDv = 2.5;
extern double buff = 0.1;
extern bool alertsOn             = true;
extern bool alertsMessageBox     = true;
extern bool alertsSound          = false;
extern string alertsSoundFile    = "TP1M.wav";  
extern bool alertsEmail          = false;
extern bool alertsAfterBarClose  = true;
//----
int loopbegin;
int shift;
double zeroline;
//---- indicator buffers
double ExtMapBuffer1[];  
double ExtMapBuffer2[];  
double ExtMapBuffer3[];  // Upperband Line
double ExtMapBuffer4[];  // Lowerband Line
//---- buffers
double bbMacd[];
double Upperband[];
double Lowerband[];
double avg[];
double bbMacdline;
double sDev;
double mean;
double sumSqr;
double sslHup[];
double sslHdn[];
double hlv[];
double hlv2[];
double sslHup1[];
double sslHdn1[];
double hlv1[];
int levdr = 0;
double alertTag;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 6 additional buffers are used for counting.
   IndicatorBuffers(8);   
//---- drawing settings     
   SetIndexBuffer(0, ExtMapBuffer1); 
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 108);
   IndicatorDigits(Digits + 1);
//----
   SetIndexBuffer(1, ExtMapBuffer2); 
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 108);
   IndicatorDigits(Digits + 1);
//----   
   SetIndexBuffer (2,sslHup1); SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(2,108); SetIndexLabel(2,"cross");
  
   
   SetIndexBuffer(4, bbMacd);
   SetIndexBuffer(5, hlv1);        
   SetIndexBuffer(6, Lowerband);
   SetIndexBuffer(7, avg);    
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("ForexprofitsupremeDline(" + FastLen + "," + SlowLen + "," + Length+")");
   SetIndexLabel(0, "bbMacd");
   SetIndexLabel(1, "Upperband");
   SetIndexLabel(2, "Lowerband");  
//---- initialization done
   Comment("Copyright © http://www.forexprofitsupreme.com");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom ForexprofitsupremeDline                                                 |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
      if (barsCount > 0)
            limit = MathMin(Bars - counted_bars,barsCount);
      else  limit = Bars - counted_bars;
//----
   for(int i = 0; i < limit; i++)
       bbMacd[i] = iMA(NULL, 0, FastLen, 0, MODE_EMA, PRICE_CLOSE, i) - 
                   iMA(NULL, 0, SlowLen, 0, MODE_EMA, PRICE_CLOSE, i);
                   
         sslHup1[i] = iCustom(NULL,levdr,"",0, 3,i);                                 
         sslHdn1[i] = iCustom(NULL,levdr,"", 0, 4,i);
//----
   for(i = 0; i < limit; i++)
     {
       avg[i] = iMAOnArray(bbMacd, 0, Length, 0, MODE_EMA, i);
       sDev   = iStdDevOnArray(bbMacd, 0, Length, MODE_EMA, 0, i);  
       
       ExtMapBuffer1[i]=bbMacd[i];   
       ExtMapBuffer2[i]=bbMacd[i];     
       
       //----
       if(bbMacd[i] > 0)
           ExtMapBuffer2[i] = EMPTY_VALUE;
            
           
       //----
       if(bbMacd[i] < 0)
           ExtMapBuffer1[i] = EMPTY_VALUE;
           
         if (alertsOn==true && i==1 && bbMacd[i] > 0 && bbMacd[i+1] < 0 && alertTag!=Time[0]){
       Alert("ForexprofitsupremeDline crossing O on the upside on ",Symbol()," ",Period());
       alertTag = Time[0];
     }
     if (alertsOn==true && i==1 && bbMacd[i] < 0 && bbMacd[i+1] > 0 && alertTag!=Time[0]){
       Alert("ForexprofitsupremeDline crossing O on the downside on ",Symbol()," ",Period());
       alertTag = Time[0];
       
         }    
           
         sslHup1[i] = EMPTY_VALUE;
         }
         
   for(i=limit;i>=0;i--)
    {
       
      if((bbMacd[i+2] < 0 && bbMacd[i+1]>buff*Point) || (bbMacd[i+2] > 0 && bbMacd[i+1]<-buff*Point) || (bbMacd[i+2] < buff*Point && bbMacd[i+1]>buff*Point) || (bbMacd[i+2] > -buff*Point && bbMacd[i+1]<-buff*Point))  hlv1[i] =  1;
      else   hlv1[i] = - 1;
      
         
          
      
          if(hlv1[i] == -1) { sslHup1[i] = EMPTY_VALUE;  }
          if(hlv1[i] == 1)   {  sslHup1[i+1] = levdr; } 
          if(bbMacd[i+2] < 0 && bbMacd[i+1]>buff*Point) hlv[i] =  1;
          if(bbMacd[i+2] > 0 && bbMacd[i+1]<-buff*Point) hlv2[i] = 1;
        
        
           
     
     
    

}
//---- done
   return(0);
  }

