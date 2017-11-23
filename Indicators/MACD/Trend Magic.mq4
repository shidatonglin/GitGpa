
//+------------------------------------------------------------------+
//|                                                   TrendMagic.mq4 |
//|                              Tidied up by TudorGirl  28 May 2009 |
//|                                              AnneTudor@ymail.com |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_width1 2
#property indicator_color2 Red
#property indicator_width2 2

//+------------------------------------------------------------------+

extern int CCI = 50;
extern int ATR = 5;

//+------------------------------------------------------------------+

double bufferUp[];
double bufferDn[];

//+------------------------------------------------------------------+

int init()
{
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexBuffer(0, bufferUp);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexBuffer(1, bufferDn);
   return (0);
}

//+------------------------------------------------------------------+

int deinit()
{
   return (0);
}

//+------------------------------------------------------------------+

int start()
{
   double thisCCI;
   double lastCCI;

   int counted_bars = IndicatorCounted();
   if (counted_bars < 0) return (-1);
   if (counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;

   for (int shift = limit; shift >= 0; shift--)
   {
      thisCCI = iCCI(NULL, 0, CCI, PRICE_TYPICAL, shift);
      lastCCI = iCCI(NULL, 0, CCI, PRICE_TYPICAL, shift + 1);

      if (thisCCI >= 0 && lastCCI < 0) bufferUp[shift + 1] = bufferDn[shift + 1];
      if (thisCCI <= 0 && lastCCI > 0) bufferDn[shift + 1] = bufferUp[shift + 1];

      if (thisCCI >= 0)
      {
         bufferUp[shift] = Low[shift] - iATR(NULL, 0, ATR, shift);
         if (bufferUp[shift] < bufferUp[shift + 1])
            bufferUp[shift] = bufferUp[shift + 1];
      }
      else
      {
         if (thisCCI <= 0)
         {
            bufferDn[shift] = High[shift] + iATR(NULL, 0, ATR, shift);
            if (bufferDn[shift] > bufferDn[shift + 1])
               bufferDn[shift] = bufferDn[shift + 1];
         }
      }
   }

   return (0);
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

