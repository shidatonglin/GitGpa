//+------------------------------------------------------------------+
//|                                                   Supertrend.mq4 |
//|                   Copyright © 2005, Jason Robinson (jnrtrading). |
//|                                      http://www.jnrtrading.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Jason Robinson (jnrtrading)."
#property link      "http://www.jnrtrading.co.uk"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
//----
double TrendUp[];
double TrendDown[];
double NonTrend[];
int st=0;
int UpDownShift;
//----
extern int TrendCCI_Period=14;
extern bool Automatic_Timeframe_setting;
extern int M1_CCI_Period=14;
extern int M5_CCI_Period=14;
extern int M15_CCI_Period=14;
extern int M30_CCI_Period=14;
extern int H1_CCI_Period=14;
extern int H4_CCI_Period=14;
extern int D1_CCI_Period=14;
extern int W1_CCI_Period=14;
extern int MN_CCI_Period=14;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_LINE, 0, 2);
   SetIndexBuffer(0, TrendUp);
   SetIndexStyle(1, DRAW_LINE, 0, 2);
   SetIndexBuffer(1, TrendDown);
//----
     switch(Period()) 
     {
         case 1:     UpDownShift=3; break;
         case 5:     UpDownShift=5; break;
         case 15:    UpDownShift=7; break;
         case 30:    UpDownShift=9; break;
         case 60:    UpDownShift=20; break;
         case 240:   UpDownShift=35; break;
         case 1440:  UpDownShift=40; break;
         case 10080: UpDownShift=100; break;
         case 43200: UpDownShift=120; break;
        }
   //----
      return(0);
     }
         //+------------------------------------------------------------------+
         //| Custor indicator deinitialization function                       |
         //+------------------------------------------------------------------+
              int deinit()
           {
         //---- 
         //----
            return(0);
           }
         //+------------------------------------------------------------------+
         //| Custom indicator iteration function                              |
         //+------------------------------------------------------------------+
         int start()
           {
            int limit, i, cciPeriod;
            double cciTrendNow14, cciTrendPrevious14, cciTrendNow, cciTrendPrevious;
//----            
            int counted_bars=IndicatorCounted();
         //---- check for possible errors
            if(counted_bars < 0) return(-1);
         //---- last counted bar will be recounted
            if(counted_bars > 0) counted_bars--;
//----
            limit=Bars-counted_bars;
              if (Automatic_Timeframe_setting==true) 
              {
                 switch(Period()) 
                 {
                     case 1:     cciPeriod=M1_CCI_Period; break;
                     case 5:     cciPeriod=M5_CCI_Period; break;
                     case 15:    cciPeriod=M15_CCI_Period; break;
                     case 30:    cciPeriod=M30_CCI_Period; break;
                     case 60:    cciPeriod=H1_CCI_Period; break;
                     case 240:   cciPeriod=H4_CCI_Period; break;
                     case 1440:  cciPeriod=D1_CCI_Period; break;
                     case 10080: cciPeriod=W1_CCI_Period; break;
                     case 43200: cciPeriod=MN_CCI_Period; break;
                    }
                 }
                       else 
                       {
                        cciPeriod=TrendCCI_Period;
                       }
   /*switch(cciPeriod) {
      case 14:  break;
   }*/
                     //cciPeriod = TrendCCI_Period;
                     SetIndexLabel(0, ("TrendUp " + cciPeriod));
                     SetIndexLabel(1, ("TrendDown " + cciPeriod));
                       for(i=limit; i>=0; i--) 
                       {
//----
                        cciTrendNow=iCCI(NULL, 0, cciPeriod, PRICE_TYPICAL, i) + 70;
                        cciTrendPrevious=iCCI(NULL, 0, cciPeriod, PRICE_TYPICAL, i+1) + 70;
                        //cciTrendNow50 = iCCI(NULL, 0, 50, PRICE_TYPICAL, i) + 70;
                        //cciTrendPrevious50 = iCCI(NULL, 0, 50, PRICE_TYPICAL, i+1) + 70;
                          if (cciTrendNow > st && cciTrendPrevious < st) 
                          {
                           TrendUp[i+1]=TrendDown[i+1];
                           //TrendDown[i] = EMPTY_VALUE;
                          }
                          if (cciTrendNow < st && cciTrendPrevious > st) 
                          {
                           TrendDown[i+1]=TrendUp[i+1];
                           //TrendUp[i] = EMPTY_VALUE;
                          }
                          if (cciTrendNow > 0) 
                          {
                           TrendUp[i]=Low[i] - Point*UpDownShift;
                           TrendDown[i]=EMPTY_VALUE;
                             if (Close[i] < Open[i] && TrendDown[i+1]!=TrendUp[i+1]) 
                             {
                              TrendUp[i]=TrendUp[i+1];
                             }
                             if (TrendUp[i] < TrendUp[i+1] && TrendDown[i+1]!=TrendUp[i+1]) 
                             {
                              TrendUp[i]=TrendUp[i+1];
                             }
                             if (High[i] < High[i+1] && TrendDown[i+1]!=TrendUp[i+1]) 
                             {
                              TrendUp[i]=TrendUp[i+1];
                             }
                          }
                          else if (cciTrendNow < 0) 
                          {
                              TrendDown[i]=High[i] + Point*UpDownShift;
                              TrendUp[i]=EMPTY_VALUE;
                                if (Close[i] > Open[i] && TrendDown[i+1]!=TrendUp[i+1]) 
                                {
                                 TrendDown[i]=TrendDown[i+1];
                                }
                                if (TrendDown[i] > TrendDown[i+1] && TrendDown[i+1]!=TrendUp[i+1]) 
                                {
                                 TrendDown[i]=TrendDown[i+1];
                                }
                                if (Low[i] > Low[i+1] && TrendUp[i+1]!=TrendDown[i+1]) 
                                {
                                 TrendDown[i]=TrendDown[i+1];
                                }
                             }
                       }
                  //----
                     return(0);
                    }
//+------------------------------------------------------------------+