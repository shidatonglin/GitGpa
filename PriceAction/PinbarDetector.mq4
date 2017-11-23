//+------------------------------------------------------------------+
//|                                                  Pinbar Detector |
//|                                  Copyright © 2011, EarnForex.com |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, EarnForex"
#property link      "http://www.earnforex.com"

/*

Pinbar Detector - detects Pinbars on charts.
Has two sets of predefined settings: common and strict.
Fully modifiable parameters of Pinbar pattern.
Usage instructions:
http://www.earnforex.com/forex-strategy/pinbar-trading-system

*/

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_width1 2
#property indicator_color2 Lime
#property indicator_width2 2

extern bool UseAlerts = true;
extern bool UseEmailAlerts = false; // Don't forget to configure SMTP parameters in Tools->Options->Emails
extern bool UseCustomSettings = false; // true = use below parameters
extern double CustomMaxNoseBodySize = 0.33; // Max. Body / Candle length ratio of the Nose Bar
extern double CustomNoseBodyPosition = 0.4; // Body position in Nose Bar (e.g. top/bottom 40%)
extern bool   CustomLeftEyeOppositeDirection = true; // true = Direction of Left Eye Bar should be opposite to pattern (bearish bar for bullish Pinbar pattern and vice versa)
extern bool   CustomNoseSameDirection = false; // true = Direction of Nose Bar should be the same as of pattern (bullish bar for bullish Pinbar pattern and vice versa)
extern bool   CustomNoseBodyInsideLeftEyeBody = false; // true = Nose Body should be contained inside Left Eye Body
extern double CustomLeftEyeMinBodySize = 0.1; // Min. Body / Candle length ratio of the Left Eye Bar
extern double CustomNoseProtruding = 0.5; // Minmum protrusion of Nose Bar compared to Nose Bar length
extern double CustomNoseBodyToLeftEyeBody = 1; // Maximum relative size of the Nose Bar Body to Left Eye Bar Body
extern double CustomNoseLengthToLeftEyeLength = 0; // Minimum relative size of the Nose Bar Length to Left Eye Bar Length
extern double CustomLeftEyeDepth = 0.1; // Minimum relative depth of the Left Eye to its length; depth is difference with Nose's back
 
// Indicator buffers
double Down[];
double Up[];

// Global variables
int LastBars = 0;
double MaxNoseBodySize = 0.33;
double NoseBodyPosition = 0.4;
bool   LeftEyeOppositeDirection = true;
bool   NoseSameDirection = false;
bool   NoseBodyInsideLeftEyeBody = false;
double LeftEyeMinBodySize = 0.1;
double NoseProtruding = 0.5;
double NoseBodyToLeftEyeBody = 1;
double NoseLengthToLeftEyeLength = 0;
double LeftEyeDepth = 0.2;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicator buffers mapping  
   SetIndexBuffer(0, Down);
   SetIndexBuffer(1, Up);  
//---- drawing settings
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 74);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 74);
//----
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);
//---- indicator labels
   SetIndexLabel(0, "Bearish Pinbar");
   SetIndexLabel(1, "Bullish Pinbar");
//----
   if (UseCustomSettings)
   {
      MaxNoseBodySize = CustomMaxNoseBodySize;
      NoseBodyPosition = CustomNoseBodyPosition;
      LeftEyeOppositeDirection = CustomLeftEyeOppositeDirection;
      NoseSameDirection = CustomNoseSameDirection;
      LeftEyeMinBodySize = CustomLeftEyeMinBodySize;
      NoseProtruding = CustomNoseProtruding;
      NoseBodyToLeftEyeBody = CustomNoseBodyToLeftEyeBody;
      NoseLengthToLeftEyeLength = CustomNoseLengthToLeftEyeLength;
      LeftEyeDepth = CustomLeftEyeDepth;
   }
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int NeedBarsCounted;
   double NoseLength, NoseBody, LeftEyeBody, LeftEyeLength;

   if (LastBars == Bars) return(0);
   NeedBarsCounted = Bars - LastBars;
   LastBars = Bars;
   if (NeedBarsCounted == Bars) NeedBarsCounted--;

   for (int i = NeedBarsCounted; i >= 1; i--)
   {
      // Won't have Left Eye for the left-most bar
      if (i == Bars - 1) continue;
      
      // Left Eye and Nose bars's paramaters
      NoseLength = High[i] - Low[i];
      if (NoseLength == 0) NoseLength = Point;
      LeftEyeLength = High[i + 1] - Low[i + 1];
      if (LeftEyeLength == 0) LeftEyeLength = Point;
      NoseBody = MathAbs(Open[i] - Close[i]);
      if (NoseBody == 0) NoseBody = Point;
      LeftEyeBody = MathAbs(Open[i + 1] - Close[i + 1]);
      if (LeftEyeBody == 0) LeftEyeBody = Point;

      // Bearish Pinbar
      if (High[i] - High[i + 1] >= NoseLength * NoseProtruding) // Nose protrusion
      {
         if (NoseBody / NoseLength <= MaxNoseBodySize) // Nose body to candle length ratio
         {
            if (1 - (High[i] - MathMax(Open[i], Close[i])) / NoseLength < NoseBodyPosition) // Nose body position in bottom part of the bar
            {
               if ((!LeftEyeOppositeDirection) || (Close[i + 1] > Open[i + 1])) // Left Eye bullish if required
               {
                  if ((!NoseSameDirection) || (Close[i] < Open[i])) // Nose bearish if required
                  {
                     if (LeftEyeBody / LeftEyeLength  >= LeftEyeMinBodySize) // Left eye body to candle length ratio
                     {
                        if ((MathMax(Open[i], Close[i]) <= High[i + 1]) && (MathMin(Open[i], Close[i]) >= Low[i + 1])) // Nose body inside Left Eye bar
                        {
                           if (NoseBody / LeftEyeBody <= NoseBodyToLeftEyeBody) // Nose body to Left Eye body ratio
                           {
                              if (NoseLength / LeftEyeLength >= NoseLengthToLeftEyeLength) // Nose length to Left Eye length ratio
                              {
                                 if (Low[i] - Low[i + 1] >= LeftEyeLength * LeftEyeDepth)  // Left Eye low is low enough
                                 {
                                    if ((!NoseBodyInsideLeftEyeBody) || ((MathMax(Open[i], Close[i]) <= MathMax(Open[i + 1], Close[i + 1])) && (MathMin(Open[i], Close[i]) >= MathMin(Open[i + 1], Close[i + 1])))) // Nose body inside Left Eye body if required
                                    {
                                       Down[i] = High[i] + 5 * Point + NoseLength / 5;
                                       if (i == 1) SendAlert("Bearish"); // Send alerts only for the latest fully formed bar
                                    }
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      
      // Bullish Pinbar
      if (Low[i + 1] - Low[i] >= NoseLength * NoseProtruding) // Nose protrusion
      {
         if (NoseBody / NoseLength <= MaxNoseBodySize) // Nose body to candle length ratio
         {
            if (1 - (MathMin(Open[i], Close[i]) - Low[i]) / NoseLength < NoseBodyPosition) // Nose body position in top part of the bar
            {
               if ((!LeftEyeOppositeDirection) || (Close[i + 1] < Open[i + 1])) // Left Eye bearish if required
               {
                  if ((!NoseSameDirection) || (Close[i] > Open[i])) // Nose bullish if required
                  {
                     if (LeftEyeBody / LeftEyeLength >= LeftEyeMinBodySize) // Left eye body to candle length ratio
                     {
                        if ((MathMax(Open[i], Close[i]) <= High[i + 1]) && (MathMin(Open[i], Close[i]) >= Low[i + 1])) // Nose body inside Left Eye bar
                        {
                           if (NoseBody / LeftEyeBody <= NoseBodyToLeftEyeBody) // Nose body to Left Eye body ratio
                           {
                              if (NoseLength / LeftEyeLength >= NoseLengthToLeftEyeLength) // Nose length to Left Eye length ratio
                              {
                                 if (High[i + 1] - High[i] >= LeftEyeLength * LeftEyeDepth) // Left Eye high is high enough
                                 {
                                    if ((!NoseBodyInsideLeftEyeBody) || ((MathMax(Open[i], Close[i]) <= MathMax(Open[i + 1], Close[i + 1])) && (MathMin(Open[i], Close[i]) >= MathMin(Open[i + 1], Close[i + 1])))) // Nose body inside Left Eye body if required
                                    {
                                       Up[i] = Low[i] - 5 * Point - NoseLength / 5;
                                       if (i == 1) SendAlert("Bullish"); // Send alerts only for the latest fully formed bar
                                    }
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
   }
}

string TimeframeToString(int P)
{
   switch(P)
   {
      case PERIOD_M1:  return("M1");
      case PERIOD_M5:  return("M5");
      case PERIOD_M15: return("M15");
      case PERIOD_M30: return("M30");
      case PERIOD_H1:  return("H1");
      case PERIOD_H4:  return("H4");
      case PERIOD_D1:  return("D1");
      case PERIOD_W1:  return("W1");
      case PERIOD_MN1: return("MN1");
   }
}

void SendAlert(string dir)
{
   string per = TimeframeToString(Period());
   if (UseAlerts)
   {
      Alert(dir + " Pinbar on ", Symbol(), " @ ", per);
      PlaySound("alert.wav");
   }
   if (UseEmailAlerts)
      SendMail(Symbol() + " @ " + per + " - " + dir + " Pinbar", dir + " Pinbar on " + Symbol() + " @ " + per + " as of " + TimeToStr(TimeCurrent()));
}