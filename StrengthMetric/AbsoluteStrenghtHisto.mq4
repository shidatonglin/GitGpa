//+------------------------------------------------------------------+
//|                                          AbsoluteStrength_v1.mq4 |
//|                           Copyright © 2006, TrendLaboratory Ltd. |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                       E-mail: igorad2004@list.ru |
//+------------------------------------------------------------------+
//| Modifications:                                                   |
//| - AbsoluteStrengthHisto_v1, 2006/06/26:                          |
//|   Put in Histogram form with 2 level lines                       |
//|   ph_bresson@yahoo.com                                           |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, TrendLaboratory Ltd."
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

#property indicator_separate_window
#property indicator_buffers   4
#property indicator_color1    Green
#property indicator_width1    2 
#property indicator_color2    Red
#property indicator_width2    2
#property indicator_color3    Blue
#property indicator_width3    2 
#property indicator_color4    Magenta
#property indicator_width4    2

//---- input parameters
extern int       Mode   =  0; // 0-RSI method; 1-Stoch method
extern int       Length =  7; // Period
extern int       Smooth =  7; // Period of smoothing
extern int       Signal =  4; // Period of Signal Line
extern int       Price  =  0; // Price mode : 0-Close,1-Open,2-High,3-Low,4-Median,5-Typical,6-Weighted
extern int       ModeMA =  1; // Mode of Moving Average
extern int       Mode_Histo  = 3; 
//---- buffers
double Bulls[];
double Bears[];
double AvgBulls[];
double AvgBears[];
double SmthBulls[];
double SmthBears[];
double SigBulls[];
double SigBears[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,2);
   SetIndexBuffer(0,SmthBulls);
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,2);
   SetIndexBuffer(1,SmthBears);

   SetIndexStyle(2,DRAW_LINE,EMPTY,2);
   SetIndexBuffer(2,SigBulls);
   SetIndexStyle(3,DRAW_LINE,EMPTY,2);
   SetIndexBuffer(3,SigBears);

   SetIndexBuffer(4,Bulls);
   SetIndexBuffer(5,Bears);
   SetIndexBuffer(6,AvgBulls);
   SetIndexBuffer(7,AvgBears);
//---- name for DataWindow and indicator subwindow label
   string short_name="AbsoluteStrengthHistogram("+Mode+","+Length+","+Smooth+","+Signal+",,"+ModeMA+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Bulls");
   SetIndexLabel(1,"Bears");
   SetIndexLabel(2,"Bulls");
   SetIndexLabel(3,"Bears");      

//----
   SetIndexDrawBegin(0,Length+Smooth+Signal);
   SetIndexDrawBegin(1,Length+Smooth+Signal);
   SetIndexDrawBegin(2,Length+Smooth+Signal);
   SetIndexDrawBegin(3,Length+Smooth+Signal);
 
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0);
   SetIndexEmptyValue(5,0.0);
   SetIndexEmptyValue(6,0.0);
   SetIndexEmptyValue(7,0.0);



   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int      shift, limit, counted_bars=IndicatorCounted();
   double   Price1, Price2, smax, smin;
//---- 
   if ( counted_bars < 0 ) return(-1);
   if ( counted_bars ==0 ) limit=Bars-Length+Smooth+Signal-1;
   if ( counted_bars < 1 ) 
   for(int i=1;i<Length+Smooth+Signal;i++) 
   {
   Bulls[Bars-i]=0;    
   Bears[Bars-i]=0;  
   AvgBulls[Bars-i]=0;    
   AvgBears[Bars-i]=0;  
   SmthBulls[Bars-i]=0;    
   SmthBears[Bars-i]=0;  
   SigBulls[Bars-i]=0;    
   SigBears[Bars-i]=0;  
   }
   
   
   
   if(counted_bars>0) limit=Bars-counted_bars;
   limit--;
   
   for( shift=limit; shift>=0; shift--)
      {
      Price1 = iMA(NULL,0,1,0,0,Price,shift);
      Price2 = iMA(NULL,0,1,0,0,Price,shift+1); 
      
         if (Mode==0)
         {
         Bulls[shift] = 0.5*(MathAbs(Price1-Price2)+(Price1-Price2));
         Bears[shift] = 0.5*(MathAbs(Price1-Price2)-(Price1-Price2));
         }
        
         if (Mode==1)
         {
         smax=High[Highest(NULL,0,MODE_HIGH,Length,shift)];
         smin=Low[Lowest(NULL,0,MODE_LOW,Length,shift)];
         
         Bulls[shift] = Price1 - smin;
         Bears[shift] = smax - Price1;
         }
      }
      
      for( shift=limit; shift>=0; shift--)
      {
      AvgBulls[shift]=iMAOnArray(Bulls,0,Length,0,ModeMA,shift);     
      AvgBears[shift]=iMAOnArray(Bears,0,Length,0,ModeMA,shift);
      }
      
      for( shift=limit; shift>=0; shift--)
      {
      SmthBulls[shift]=iMAOnArray(AvgBulls,0,Smooth,0,ModeMA,shift);     
      SmthBears[shift]=iMAOnArray(AvgBears,0,Smooth,0,ModeMA,shift);
      }

      if(Mode_Histo == 1)
      {
         for( shift=limit; shift>=0; shift--)
         {
            if(SmthBulls[shift]-SmthBears[shift]>0)
            {
               SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,5);
               SetIndexStyle(1,DRAW_LINE,EMPTY,2);
               SmthBears[shift]= SmthBears[shift]/Point;
               SmthBulls[shift]= SmthBulls[shift]/Point;
            }
            else
            {
               SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,5);
               SetIndexStyle(0,DRAW_LINE,EMPTY,2);
               SmthBears[shift]= SmthBears[shift]/Point;
               SmthBulls[shift]= SmthBulls[shift]/Point;
            }
         }  //end for( shift=limit; shift>=0; shift--)
      }     // end if(Mode_Histo == 1)
      else
      if(Mode_Histo == 2)
      {
         for( shift=limit; shift>=0; shift--)
         {
            if(SmthBulls[shift]-SmthBears[shift]>0)
            {
               SmthBears[shift]=-SmthBears[shift]/Point;
               SmthBulls[shift]= SmthBulls[shift]/Point;
            }
            else
            {
               SmthBulls[shift]=-SmthBulls[shift]/Point;
               SmthBears[shift]= SmthBears[shift]/Point;
            }
         }  //end for( shift=limit; shift>=0; shift--)      
      }     //end if(Mode_Histo == 2)
      else
      if(Mode_Histo == 3)
      {
         for( shift=limit; shift>=0; shift--)
         {
            SigBulls[shift]=  SmthBulls[shift];
            SigBears[shift]=  SmthBears[shift];            
            if(SmthBulls[shift]-SmthBears[shift]>0)
               SmthBears[shift]=0;
            else
               SmthBulls[shift]=0;  
         }  //end for( shift=limit; shift>=0; shift--)      
      }     //end if(Mode_Histo == 3)
      else
      if(Mode_Histo == 4)
      {
         for( shift=limit; shift>=0; shift--)
         {
            if(SmthBulls[shift]-SmthBears[shift]>0)
            {
               SigBears[shift]=  SmthBears[shift];
               SmthBears[shift]=0;
            }
            else
            {
               SigBulls[shift]=  SmthBulls[shift];
               SmthBulls[shift]=0;         
            }
         }  //end for( shift=limit; shift>=0; shift--)      
      }     //end if(Mode_Histo == 4)
      
   return(0);
  }
//+------------------------------------------------------------------+