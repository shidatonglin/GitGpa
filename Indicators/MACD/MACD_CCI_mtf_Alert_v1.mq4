//+------------------------------------------------------------------+
//|                                                     MACD_CCI.mq4 |
//|                                   Copyright © 2009, challenger78 |
//+------------------------------------------------------------------+
//mod mtf
//19.jun.2009 - Add Alert for change color to "RoyalBlue" or "Red" (okfar)
//22.jun.2009 - Add alert delay

#property  copyright "challenger78"

#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  RoyalBlue
#property  indicator_color2  Red
#property  indicator_color3  Orange

#property  indicator_minimum 0
#property  indicator_maximum 77

extern int TimeFrame=0;

extern int macdMAfast   =144;  //12
extern int macdMAslow   =233;  //26;
extern int macdSigMA    =21;   //9
extern int macdPrice    =0;
extern int macdLnMode   =0;

extern int CCIperiod = 50;
extern int CCIprice  = 5;

extern double BarLevl = 5;

//0main;1signal
extern string  MA_Method_Price = "SMA0 EMA1 SMMA2 LWMA3||0O,1C 2H3L,4Md 5Tp 6WghC: Md(HL/2)4,Tp(HLC/3)5,Wgh(HLCC/4)6||macdLnMode:0main 1sig";
extern string TimeFrames = "M1;5,15,30,60H1;240H4;1440D1;10080W1;43200MN|0-CurrentTF";

extern int alertSwitch = 1;  //0=OFF ,  1=ON 
extern int alertShift = 0;   // 0=change color current Bars, 1=chamge color previous Bar, ....

                             // 
double buffer1[], buffer2[], buffer3[];
int lastABar;



int init()
{
   SetIndexStyle(0,DRAW_ARROW);    SetIndexArrow(0,167);    SetIndexBuffer(0,buffer1);    SetIndexEmptyValue(0,EMPTY_VALUE); 
   SetIndexStyle(1,DRAW_ARROW);    SetIndexArrow(1,167);    SetIndexBuffer(1,buffer2);    SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexStyle(2,DRAW_ARROW);    SetIndexArrow(2,167);    SetIndexBuffer(2,buffer3);    SetIndexEmptyValue(2,EMPTY_VALUE); 
   
   
   TimeFrame=MathMax(TimeFrame,Period());  
   
   string name1= " macd: "+macdMAfast+","+macdMAslow+","+macdSigMA;
   string name2= " cci: " +CCIperiod;

   IndicatorShortName("MACDCCI"+name1+name2+" "+TimeFrame);  

   
   return(0);
}



int start()
{
   int i,limit;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
   limit = Bars - counted_bars;
         if(TimeFrame!=Period())
         limit = MathMax(limit,TimeFrame/Period());
   
   for (i=limit; i>= 0; i--)
   {
              int y =iBarShift(NULL,TimeFrame,Time[i]);
                  
      double  macd0 =iMACD(NULL,TimeFrame,macdMAfast,macdMAslow,macdSigMA,macdPrice,macdLnMode,y);
      double  macd1 =iMACD(NULL,TimeFrame,macdMAfast,macdMAslow,macdSigMA,macdPrice,macdLnMode,y+1);

      double  cci   =iCCI (NULL,TimeFrame,CCIperiod,CCIprice,y);
                
                
                         
      buffer1[i]=EMPTY_VALUE;    buffer2[i]=EMPTY_VALUE;      buffer3[i]=EMPTY_VALUE;    
      
      if (cci > 0 && macd0 > macd1 )   buffer1[i] = BarLevl;
          
      else 
      if (cci < 0 && macd0 < macd1 )   buffer2[i] = BarLevl;  
      else                             buffer3[i] = BarLevl;
   
   }
   if (alertSwitch == 1 && Bars > lastABar) {
      if (buffer1[alertShift] != EMPTY_VALUE && buffer1[alertShift+1] == EMPTY_VALUE) {
         Alert(Symbol(), " Indicator MCAD_CCI change color (bar-",alertShift,") to 'color0' (RoyalBlue)");
         lastABar = Bars;
      }
      if (buffer2[alertShift] != EMPTY_VALUE && buffer2[alertShift+1] == EMPTY_VALUE) {
         Alert(Symbol(), " Indicator MCAD_CCI change color (bar-",alertShift,") to 'color1' (Red)");
         lastABar = Bars;
      }
   }
            
   return(0);
}

