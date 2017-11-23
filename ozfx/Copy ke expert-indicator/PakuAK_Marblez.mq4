//+------------------------------------------------------------------+
//|                                               Custom BB_MACD.mq4 |
//|                                     Copyright © 2005, adoleh2000 |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2005, adoleh2000"
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  Blue  //bbMacd up
#property  indicator_color2  Red  //bbMacd up
#property  indicator_color3  Blue  //Upperband
#property  indicator_color4  Red //Lowerband



//---- indicator parameters

extern int FastLen=12;
extern int SlowLen=26;
extern int Length=10;
extern double StDv=1;

int loopbegin;
int shift;

double zeroline;

//---- indicator buffers
//---- buffers
double ExtMapBuffer1[]; // bbMacd
double ExtMapBuffer2[]; // bbMacd
double ExtMapBuffer3[]; // Upperband Line
double ExtMapBuffer4[]; // Lowerband Line

double     bbMacd[];
double     bbMacdline;
double     Upperband[];
double     Lowerband[];
double     avg[];
double     sDev;
double     mean;
double     sumSqr;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  //---- 6 additional buffers are used for counting.
   IndicatorBuffers(8);   
//---- drawing settings
      
   SetIndexBuffer(0,ExtMapBuffer1);//bbMacd line
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,0);
   SetIndexArrow(0,108);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
   
   
   SetIndexBuffer(1,ExtMapBuffer2);//bbMacd line
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,0);
   SetIndexArrow(1,108);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
   
   SetIndexBuffer(2,ExtMapBuffer3); //Upperband line
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
   
   SetIndexBuffer(3,ExtMapBuffer4); //Lowerband line
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,1);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);

   
   
  SetIndexBuffer(4,bbMacd);
  SetIndexBuffer(5,Upperband);        
  SetIndexBuffer(6,Lowerband);
  SetIndexBuffer(7,avg);
   
      
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Marblez ("+FastLen+","+SlowLen+","+Length+")");
   SetIndexLabel(0,"bbMacd");
   SetIndexLabel(1,"Upperband");
   SetIndexLabel(2,"Lowerband");
   
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+

  int deinit()
{
//---- TODO: add your code here
// --------------------------
//----
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
      //loopbegin = Bars-1;
      //for(int i = loopbegin; i >= 0; i--)
      for(int i=0; i<limit; i++)
        bbMacd[i]=iMA(NULL,0,FastLen,0,MODE_EMA,PRICE_CLOSE,i) - iMA(NULL,0,SlowLen,0,MODE_EMA,PRICE_CLOSE,i);
      for(i=0; i<limit; i++)
      {
        avg[i]=iMAOnArray(bbMacd,0,Length,0,MODE_EMA,i);
         
       //Comment("avg[i]=",avg[i],"  bbMacd[i+1]=",bbMacd[i+1],"   bbMacd[i]=",bbMacd[i],"   Length=",Length,"  sDev=",sDev,"  Upperband=",Upperband[i],"  Lowerband=",Lowerband[i]);                  
        
        
        
        sDev = iStdDevOnArray(bbMacd,0,Length,MODE_EMA,0,i);  
        
               
        Upperband[i] = avg[i] + (StDv * sDev);
        Lowerband[i] = avg[i] - (StDv * sDev);
        

      
      ExtMapBuffer1[i]=bbMacd[i];   //Uptrend bbMacd
      ExtMapBuffer2[i]=bbMacd[i];   // downtrend bbMacd
      ExtMapBuffer3[i]=Upperband[i];// Upperband
      ExtMapBuffer4[i]=Lowerband[i];//Lowerband

      
      if (bbMacd[i]>bbMacd[i+1])
      {
      ExtMapBuffer2[i]=EMPTY_VALUE;
      }
      
      if (bbMacd[i]<bbMacd[i+1])
      {
      ExtMapBuffer1[i]=EMPTY_VALUE;
      }
      

   
    }

  
      
//---- done
   return(0);
  
  }
//+------------------------------------------------------------------+
 