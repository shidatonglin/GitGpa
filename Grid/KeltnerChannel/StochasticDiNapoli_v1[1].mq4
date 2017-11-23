//+------------------------------------------------------------------+
//|                                           StochasticDiNapoli.mq4 |
//|                           Copyright © 2006, TrendLaboratory Ltd. |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                       E-mail: igorad2004@list.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, TrendLaboratory Ltd."
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100

#property indicator_level1 20
#property indicator_level2 80
#property indicator_level3 50

#property indicator_buffers 2
#property indicator_color1 DodgerBlue
#property indicator_color2 Blue
//---- input parameters
extern int FastK=8;
extern int SlowK=3;
extern int SlowD=3;
//---- buffers
double StoBuffer[];
double SigBuffer[];
//double MdBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   
   SetIndexBuffer(0,StoBuffer);
   SetIndexBuffer(1,SigBuffer);
   
   //---- name for DataWindow and indicator subwindow label
   short_name="Stochastic DiNapoli("+FastK+","+SlowK+","+SlowD+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Stoch");
   SetIndexLabel(1,"Signal");
//----
   SetIndexDrawBegin(0,FastK);
   SetIndexDrawBegin(1,FastK);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Stochastic DiNapoli                                              |
//+------------------------------------------------------------------+
int start()
  {
   int i,counted_bars=IndicatorCounted();
   double high,low;
//----
   if(Bars<=FastK) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=FastK;i++) 
      {StoBuffer[Bars-i]=0.0;SigBuffer[Bars-i]=0.0;}
//----
   i=Bars-FastK-1;
   if(counted_bars>=FastK) i=Bars-counted_bars-1;
   while(i>=0)
   {
       low=Low[Lowest(NULL,0,MODE_LOW,FastK,i)]; 
       high=High[Highest(NULL,0,MODE_HIGH,FastK,i)];     
       double Fast=(Close[i]-low)/(high-low)*100;
       StoBuffer[i]=StoBuffer[i+1]+(Fast-StoBuffer[i+1])/SlowK;
       SigBuffer[i]=SigBuffer[i+1]+(StoBuffer[i]-SigBuffer[i+1])/SlowD;
   i--;
   }
   return(0);
  }
//+------------------------------------------------------------------+