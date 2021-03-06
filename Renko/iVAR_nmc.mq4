//+------------------------------------------------------------------+
//|                                                     iVAR_nmc.mq4 |
//|                                        (C)opyright © 2008, Ilnur |
//              mod by jaguar1637 @ yahoo.com                        |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

#property copyright "(C)opyright © 2008, Ilnur"
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
#property indicator_width1 2
#property indicator_level1 0.5
#property indicator_levelcolor Orange

extern int Periods = 5;

double ibuffer[];
double MathLog2, PeriodsML2,nWindow;

string signal,short_name,symbol;

int OnInit()
  {
   symbol = Symbol();
   
   MathLog2=MathLog(2.0);
   PeriodsML2=Periods*MathLog2;
   nWindow = MathPow(2,Periods);
   
   IndicatorDigits(Digits+7);
   IndicatorBuffers(1);
   
   SetIndexBuffer(0,ibuffer);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexDrawBegin(0,MathPow(2,Periods));
   SetIndexLabel(0,"iVAR_nmc");
   IndicatorShortName("iVAR_nmc("+Periods+")");
   
   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int i, j, k,  nTotal, nIntervalkj, ihigh, ilow, nInterval, nCountedBars = IndicatorCounted();
   double Delta, Xc, Yc, Sx, Sy, Sxx, Sxy;

   nTotal = Bars-nWindow;
   if(nCountedBars>nWindow) 
      nTotal = Bars-nCountedBars-1;

   for(j=nTotal; j>=0; j--)
   {
      Sx = 0; Sy = 0; Sxx = 0; Sxy = 0;
      
      for(i=0; i<=Periods; i++)
      {
         nInterval = MathPow(2,Periods-i);
         Delta=0;
         
         for(k=0; k<(MathPow(2,i)); k++)
         {
            nIntervalkj=nInterval*k+j;
         	ihigh = iHighest(symbol,0,MODE_HIGH,nInterval,nIntervalkj);
         	ilow = iLowest(symbol,0,MODE_LOW,nInterval,nIntervalkj);
         	Delta += High[ihigh]-Low[ilow];
         }
         Xc = PeriodsML2-i*MathLog2;
         Yc = MathLog(Delta);
         Sx += Xc; 
         Sy += Yc;
         Sxx += Xc*Xc; 
         Sxy += Xc*Yc;
      }
      ibuffer[j] = -(Sx*Sy-(Periods+1)*Sxy)/(Sx*Sx-(Periods+1)*Sxx);
   }
   if (ibuffer[0] < 0.49) 
      {
      signal = " Trend state of the market.";
      }
      else
         if (ibuffer[0] > 0.51)
            {
            signal = " Flat state of the market";
            }
            else
            {
            signal = " Undefined state of the market ";
            }
      short_name="iVAR_nmc" + signal;           
      IndicatorShortName(short_name);
 
}