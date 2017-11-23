//+------------------------------------------------------------------+
//|                                                     Laguerre.mq4 |
//|                                                     Emerald King |
//|                                     mailto:info@emerald-king.com |
//+------------------------------------------------------------------+
// Modified and simplified by ACS. 03-Oct-07. Added MA for Laguerre! 25-Oct-07. This code was released on 21-JUL-08 in FF.
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_minimum 0
#property indicator_maximum 1
#property indicator_width1 2
#property indicator_level1 0.85
#property indicator_level2 0.50
#property indicator_level3 0.15
//---- input parameters
extern double gamma=0.6;
extern int MaxBars=1000;
extern int MA = 2;

double L0 = 0, L1 = 0, L2 = 0, L3 = 0, L0A = 0, L1A = 0, L2A = 0, L3A = 0, LRSI = 0, CU = 0, CD = 0;
double Buffer1[], dummy[];
//+------------------------------------------------------------------+
int init() {
   IndicatorDigits(2);
   IndicatorBuffers(2); 
   SetIndexBuffer(0,Buffer1);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,dummy);
   SetIndexStyle(1,DRAW_NONE); SetIndexLabel(1,NULL); 
   string shortname="Laguerre-ACS("+DoubleToStr(gamma,2); if (MA < 2) shortname = shortname+")"; else shortname = shortname+"-MA"+MA+")";
   IndicatorShortName(shortname);
   SetIndexLabel(0,shortname+"-"+Period()+"M");
return(0); }
//+------------------------------------------------------------------+
int deinit() { return(0); }
//+------------------------------------------------------------------+
int start() {
   int i, j, counted_bars=IndicatorCounted(); double sum1=0;
   if (counted_bars < 0) return(-1);  if (counted_bars > 0) counted_bars--;
   if (MaxBars>Bars) MaxBars=Bars;
   SetIndexDrawBegin(0,Bars-MaxBars);

   for(i=MaxBars-1;i>=0;i--) { sum1=0;
      L0A = L0; L1A = L1; L2A = L2; L3A = L3;
      L0 = (1 - gamma)*Close[i] + gamma*L0A;
      L1 = - gamma *L0 + L0A + gamma *L1A;
      L2 = - gamma *L1 + L1A + gamma *L2A;
      L3 = - gamma *L2 + L2A + gamma *L3A;
      CU = 0; CD = 0;
      if (L0 >= L1) CU = L0 - L1; else CD = L1 - L0;
      if (L1 >= L2) CU = CU + L1 - L2; else CD = CD + L2 - L1;
      if (L2 >= L3) CU = CU + L2 - L3; else CD = CD + L3 - L2;
      if (CU + CD != 0) LRSI = CU / (CU + CD);
      dummy[i] = LRSI;
      if (MA < 2) Buffer1[i] = dummy[i]; else { for (j=i; j < i+MA; j++) sum1 += dummy[j]; Buffer1[i] = sum1/MA; } 
   }
return(0); }
//+------------------------------------------------------------------+

