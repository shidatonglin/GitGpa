//+------------------------------------------------------------------+
//|                                             Multi Stochastic.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Gray
#property indicator_separate_window
#property indicator_maximum   1
#property indicator_minimum	0
extern int History =5000;
double Buf_0[];
double Buf_1[];
double Buf_2[];
int Target=0;

 int init() 
 {
 
 SetIndexBuffer(0,Buf_0); 
 SetIndexStyle (0,DRAW_HISTOGRAM,0,5);
 SetIndexBuffer(1,Buf_1); 
 SetIndexStyle (1,DRAW_HISTOGRAM,0,5);
 SetIndexBuffer(2,Buf_2); 
 SetIndexStyle (2,DRAW_HISTOGRAM,0,5);
   
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
if(iCustom(NULL,0,"liun_interval_trend",0,2,3,0,20,20,0,i)<iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,0,i) && Low[i] <=iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,0,i) && Target==0) {Buf_0[i]=1;Target=1;}
if(iCustom(NULL,0,"liun_interval_trend",0,2,3,0,20,20,1,i)>iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,1,i) && High[i]>=iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,1,i) && Target==0) {Buf_1[i]=1;Target=1;}
if(iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,1,i)>iCustom(NULL,0,"liun_interval_trend",0,2,3,0,20,20,1,i) && iCustom(NULL,0,"liun_interval_index",1,1,1.2,0,8,8,0,i)<iCustom(NULL,0,"liun_interval_trend",0,2,3,0,20,20,0,i)) Target=0;
if(Buf_0[i]==EMPTY_VALUE && Buf_1[i]==EMPTY_VALUE) Buf_2[i]=1;

 i--; // Calculating index of the next bar
 }
//---------------------------------------------------------------------------------------
 return(0); // Exit start()
 }
