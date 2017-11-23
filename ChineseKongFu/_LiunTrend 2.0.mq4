//+------------------------------------------------------------------+
//|                                             Multi Stochastic.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_buffers 5
#property indicator_color1 clrBlue
#property indicator_color2 clrRed
#property indicator_color3 clrGray
#property indicator_color4 clrSteelBlue
#property indicator_color5 clrIndianRed
#property indicator_separate_window
#property indicator_maximum   1
#property indicator_minimum	0
extern int History =5000;
double Buf_0[];
double Buf_1[];
double Buf_2[];
double Buf_3[];
double Buf_4[];
int Target=0;

 int init() 
 {
 
 SetIndexBuffer(0,Buf_0); 
 SetIndexStyle (0,DRAW_HISTOGRAM,0,5);
 SetIndexBuffer(1,Buf_1); 
 SetIndexStyle (1,DRAW_HISTOGRAM,0,5);
 SetIndexBuffer(2,Buf_2); 
 SetIndexStyle (2,DRAW_HISTOGRAM,0,5);
 SetIndexBuffer(3,Buf_3); 
 SetIndexStyle (3,DRAW_HISTOGRAM,0,5);
 SetIndexBuffer(4,Buf_4); 
 SetIndexStyle (4,DRAW_HISTOGRAM,0,5);
   
 return(0); 
 }
 
 int start() // Special function start()
 {
 int i,
 Counted_bars=IndicatorCounted(); // Number of counted bars
 i=Bars-Counted_bars-1; // Index of the first uncounted
 if (i>History-1) // If too many bars ..
 i=History-1;
 while(i>=0)
 {
 //Trend Setup
if(iCustom(NULL,0,"liun_interval_trend",0,2,3,0,20,20,0,i)<iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,0,i) && TrendChecker("Up",i)==true && IndexChecker("Up",i)==true && Low[i] <=iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,0,i) ) {Buf_0[i]=1;}
if(iCustom(NULL,0,"liun_interval_trend",0,2,3,0,20,20,1,i)>iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,1,i) && TrendChecker("Dn",i)==true && IndexChecker("Dn",i)==true && High[i]>=iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,1,i) ) {Buf_1[i]=1;} 

//NoTrend Setup
if(NoTrendChecker(i)==true && IndexChecker("Up",i)==true && TrendChecker("Up",i)==true && Low [i]<=iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,0,i)) {Buf_3[i]=1;} 
if(NoTrendChecker(i)==true && IndexChecker("Dn",i)==True && TrendChecker("Dn",i)==true && High[i]>=iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,1,i)) {Buf_4[i]=1;}  




if((Buf_0[i]==EMPTY_VALUE && Buf_1[i]==EMPTY_VALUE && Buf_3[i]==EMPTY_VALUE && Buf_4[i]==EMPTY_VALUE) || Buf_0[i+1]==1 || Buf_1[i+1]==1 || Buf_3[i+1]==1 || Buf_4[i+1]==1) {Buf_2[i]=1; Buf_0[i]=EMPTY_VALUE; Buf_1[i]=EMPTY_VALUE; Buf_3[i]=EMPTY_VALUE; Buf_4[i]=EMPTY_VALUE;}


 i--; // Calculating index of the next bar
 }
//---------------------------------------------------------------------------------------
 return(0); // Exit start()
 }
   bool TrendChecker(string TGT,double Index)
      {
      
      if(TGT=="Up")
      if(iCustom(NULL,0,"liun_interval_trend",0,2,3,0,20,20,0,Index+1)<iCustom(NULL,0,"liun_interval_trend",0,2,3,0,20,20,0,Index) && iCustom(NULL,0,"liun_interval_trend",0,2,3,0,20,20,1,Index+1)<iCustom(NULL,0,"liun_interval_trend",0,2,3,0,20,20,1,Index)) return(true);
      if(TGT=="Dn")
      if(iCustom(NULL,0,"liun_interval_trend",0,2,3,0,20,20,0,Index+1)>iCustom(NULL,0,"liun_interval_trend",0,2,3,0,20,20,0,Index) && iCustom(NULL,0,"liun_interval_trend",0,2,3,0,20,20,1,Index+1)>iCustom(NULL,0,"liun_interval_trend",0,2,3,0,20,20,1,Index)) return(true);
      
      return(false);
      }
      
   bool IndexChecker(string TGT,double Index)
      {
      
      if(TGT=="Up")
      if(iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,0,Index+1)<iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,0,Index) && iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,1,Index+1)<iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,1,Index)) return(true);
      if(TGT=="Dn")
      if(iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,0,Index+1)>iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,0,Index) && iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,1,Index+1)>iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,1,Index)) return(true);
      
      return(false);
      }
      
   bool NoTrendChecker(double Index)
      {
      
      if(iCustom(NULL,0,"liun_interval_trend",0,2,3,0,20,20,0,Index)>iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,1,Index) && iCustom(NULL,0,"liun_interval_trend",0,2,3,0,20,20,1,Index)<iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,0,Index)) return(true);

      return(false);
      }