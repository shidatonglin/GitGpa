//+------------------------------------------------------------------+
//|                                               FX5_Divergence.mq4 |
//|                                                              FX5 |
//|                                                    hazem@uk2.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, FX5"
#property link      "hazem@uk2.net"
//----
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 LimeGreen
#property indicator_color2 FireBrick
#property indicator_color3 Green
#property indicator_color4 Red
//---- input parameters
extern string separator1 = "*** OSMA Settings ***";
extern int    fastEMA = 12;
extern int    slowEMA = 26;
extern int    signal = 9;
extern string separator2 = "*** Indicator Settings";
extern double positiveSensitivity = 0.0001;
extern double negativeSensitivity = -0.0001;
extern double historyBarsCount = 0;
extern bool   drawDivergenceLines = true;
//---- buffers
double upOsMA[];
double downOsMA[];
double bullishDivergence[];
double bearishDivergence[];
double OsMA[];
double MACD[];
double Signal[];
static int chartBarsCount;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(7);
//----   
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexBuffer(0, upOsMA);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexBuffer(1, downOsMA);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexBuffer(2, bullishDivergence);
   SetIndexArrow(2, 233);
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexBuffer(3, bearishDivergence);
   SetIndexArrow(3, 234);
   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, OsMA);
// additional buffers   
   SetIndexBuffer(5, MACD);
   SetIndexBuffer(6, Signal);      
//----   
   SetIndexDrawBegin(0, signal);
   SetIndexDrawBegin(1, signal);
//----   
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS) + 2);
   IndicatorShortName("FX5_Divergence(" + fastEMA + "," + slowEMA + 
                      "," + signal + ")");
//----
   if(historyBarsCount <= 0 || historyBarsCount > Bars)
       chartBarsCount = Bars;
   else
       chartBarsCount = historyBarsCount;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
       string label = ObjectName(i);
       if(StringSubstr(label, 0, 14) != "DivergenceLine")
           continue;
       ObjectDelete(label);   
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int countedBars = IndicatorCounted();
   if(countedBars < 0)
       countedBars = 0;
//----
   CalculateOsMA(countedBars);      
   CalculateDivergence(countedBars);   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateDivergence(int countedBars)
  {
   double arrowSeparation = 1 / MathPow(10, MarketInfo(Symbol(), 
                            MODE_DIGITS) + 2) * 50;
//----    
   for(int i = chartBarsCount - countedBars; i >= 0; i--)
     {
       bearishDivergence[i] = EMPTY_VALUE;
       bullishDivergence[i] = EMPTY_VALUE;
       //----   
       int firstPeakOrTroughShift = GetFirstPeakOrTrough(i);
       double firstPeakOrTroughOsMA = OsMA[firstPeakOrTroughShift];
       if(firstPeakOrTroughOsMA > 0)
         {
           int peak_0   = GetIndicatorLastPeak(i);
           int trough_0 = GetIndicatorLastTrough(peak_0);
           int peak_1   = GetIndicatorLastPeak(trough_0);
           int trough_1 = GetIndicatorLastTrough(peak_1);
         }
       else
         {        
           trough_0 = GetIndicatorLastTrough(i);
           peak_0   = GetIndicatorLastPeak(trough_0);
           trough_1 = GetIndicatorLastTrough(peak_0);         
           peak_1   = GetIndicatorLastPeak(trough_1);                       
         }
       //----  
       if(peak_0 == -1 || peak_1 == -1 || trough_0 == -1 || 
          trough_1 == -1)
           continue;
       //----          
       double indicatorLastPeak = OsMA[peak_0];
       double indicatorThePeakBefore = OsMA[peak_1];
       double indicatorLastTrough = OsMA[trough_0];
       double indicatorTheTroughBefore = OsMA[trough_1];
/*      
       int pricePeak_0 = GetPriceLastPeak(peak_0);
       int pricePeak_1 = GetPriceLastPeak(peak_1);
       int priceTrough_0 = GetPriceLastTrough(trough_0);
       int priceTrough_1 = GetPriceLastTrough(trough_1);
*/
       int pricePeak_0 = peak_0;
       int pricePeak_1 = peak_1;
       int priceTrough_0 = trough_0;
       int priceTrough_1 = trough_1;
       //----
       double priceLastPeak = High[pricePeak_0];
       double priceThePeakBefore = High[pricePeak_1];
       double priceLastTrough = Low[priceTrough_0];
       double priceTheTroughBefore = Low[priceTrough_1];
       // Bearish divergence condition         
       if((priceLastPeak > priceThePeakBefore && 
           indicatorLastPeak < indicatorThePeakBefore) ||
           (priceLastPeak < priceThePeakBefore && 
           indicatorLastPeak > indicatorThePeakBefore))
         {
           bearishDivergence[peak_0] = upOsMA[peak_0] + arrowSeparation;
           if(drawDivergenceLines)
             {
               PriceDrawLine(Time[pricePeak_0], Time[pricePeak_1], 
                             priceLastPeak, priceThePeakBefore, Red);
               IndicatorDrawLine(Time[peak_0], Time[peak_1], indicatorLastPeak, 
                                 indicatorThePeakBefore, Red);
             }
           continue;
         }
       // Bullish divergence condition           
       if((priceLastTrough < priceTheTroughBefore && 
           indicatorLastTrough > indicatorTheTroughBefore) ||
           (priceLastTrough > priceTheTroughBefore && 
           indicatorLastTrough < indicatorTheTroughBefore))
         {
           bullishDivergence[trough_0] = downOsMA[trough_0] - arrowSeparation;
           if(drawDivergenceLines)
             {
               PriceDrawLine(Time[priceTrough_0], Time[priceTrough_1], 
                             priceLastTrough, priceTheTroughBefore, Green);
               IndicatorDrawLine(Time[trough_0], Time[trough_1], indicatorLastTrough, 
                                 indicatorTheTroughBefore, Green);
             }
           continue;
         }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateOsMA(int countedBars)
  {
   for(int i = Bars - countedBars; i >= 0; i--)
     {
       MACD[i]=iMA(NULL, 0, fastEMA, 0, MODE_EMA, PRICE_CLOSE, i) -
               iMA(NULL, 0, slowEMA, 0, MODE_EMA, PRICE_CLOSE, i);
     }
   for(i = Bars - countedBars; i >= 0; i--)
     {
       Signal[i] = iMAOnArray(MACD, Bars, signal, 0, MODE_SMA, i);
       OsMA[i] = MACD[i] - Signal[i];
       //----
       if(OsMA[i] > 0)
         {
           upOsMA[i] = OsMA[i];
           downOsMA[i] = 0;
         }
       else 
           if(OsMA[i] < 0)
             {
               downOsMA[i] = OsMA[i];
               upOsMA[i] = 0;   
             }
           else
             {
               upOsMA[i] = 0;
               downOsMA[i] = 0;   
             }
     }            
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetPositiveRegionStart(int index)
  {
   int regionStart;
   for(int i = index + 1; i < Bars; i++)
     {
       if(OsMA[i] >= OsMA[i-1] && OsMA[i] >= OsMA[i+1] && 
          OsMA[i] >= OsMA[i+2] && OsMA[i] > positiveSensitivity)
           return(i);    
     }
   return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetNegativeRegionStart(int index)
  {
   for(int i = index + 1; i < Bars; i++)
     {
       if(OsMA[i] <= OsMA[i-1] && OsMA[i] <= OsMA[i+1] && 
          OsMA[i] <= OsMA[i+2] && OsMA[i] < negativeSensitivity)
           return(i);   
     }
   return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetFirstPeakOrTrough(int index)
  {
   for(int i = index + 1; i < Bars; i++)
     {
       if((OsMA[i] >= OsMA[i-1] && OsMA[i] >= OsMA[i+1] && 
          OsMA[i] >= OsMA[i+2] && OsMA[i] > positiveSensitivity) ||
          (OsMA[i] <= OsMA[i-1] && OsMA[i] <= OsMA[i+1] && 
          OsMA[i] <= OsMA[i+2] && OsMA[i] < negativeSensitivity))
           return(i);
     }
   return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastPeak(int index)
  {
   int regionStart = GetPositiveRegionStart(index);
   if(regionStart == -1)
       return(-1);
//----   
   int peakShift = 0;
   double peakValue = 0;
//----
   for(int i = regionStart; i < Bars; i++)
     {
       if(OsMA[i] > peakValue && OsMA[i] >= OsMA[i-1] && 
          OsMA[i] >= OsMA[i+1] && OsMA[i] >= OsMA[i+2] && 
          OsMA[i] > positiveSensitivity)
         {
           peakValue = OsMA[i];
           peakShift = i;
         }
       if(OsMA[i] < 0)
           break;  
     } 
   return(peakShift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastTrough(int index)
  {
   int regionStart = GetNegativeRegionStart(index);
   if(regionStart == -1)
       return(-1);
//----         
   int troughShift = 0;
   double troughValue = 0;
//----   
   for(int i = regionStart; i < Bars; i++)
     {
       if(OsMA[i] < troughValue && OsMA[i] <= OsMA[i-1] && 
          OsMA[i] <= OsMA[i+1] && OsMA[i] <= OsMA[i+2] && 
          OsMA[i] < negativeSensitivity)
         {
           troughValue = OsMA[i];
           troughShift = i;
         }   
       if(OsMA[i] > 0)
           break;  
     }  
   return(troughShift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PriceDrawLine(datetime x1, datetime x2, double y1, double y2, 
                   color lineColor)
  {
   string label = "DivergenceLine# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IndicatorDrawLine(datetime x1, datetime x2, double y1, double y2, 
                       color lineColor)
  {
   int indicatorWindow = WindowFind("FX5_Divergence(" + fastEMA + "," + 
                                    slowEMA + "," + signal + ")");
   if(indicatorWindow < 0)
       return;
//----      
   string label = "DivergenceLine$# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, indicatorWindow, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
  }
//+------------------------------------------------------------------+

