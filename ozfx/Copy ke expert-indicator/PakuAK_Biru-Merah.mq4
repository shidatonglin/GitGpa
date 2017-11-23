//+------------------------------------------------------------------+
//|                                         OzFX_SqueezeMore_Ind.mq4 |
//|                                            Copyright © 2008, JS  |
//|                                          http://www.ozfx.com.au/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, JS"
#property link      "http://www.ozfx.com.au/"

#include <WinUser32.mqh>

#property indicator_separate_window
#property indicator_buffers 3

#property indicator_color2 Blue
#property indicator_color3 Red

#property indicator_width2 2
#property indicator_width3 2

#property indicator_minimum -1.1
#property indicator_maximum 1.1

extern bool PopupAlerts = true;
extern bool SoundAlerts = true;
extern bool EmailAlerts = true;
extern int AlertSleepMins = 60;

double OzFX_Squeeze[];
double OzFX_Squeeze_Long[];
double OzFX_Squeeze_Short[];

int last;
bool alertTriggered;
datetime lastAlertTime;

void init()
{
   IndicatorBuffers(3);
   SetIndexStyle(0, DRAW_NONE);
   SetIndexBuffer(0, OzFX_Squeeze);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(1, OzFX_Squeeze_Long);
   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexBuffer(2, OzFX_Squeeze_Short);
   last = 0;
   alertTriggered = false;
}

int start()
{
   for (int i = Bars; i >= 0; i--)
   {
      double stoch_t2 = iStochastic(NULL, 0, 5, 3, 4, MODE_SMA, 0, MODE_MAIN, i + 2);
      double stoch_t1 = iStochastic(NULL, 0, 5, 3, 4, MODE_SMA, 0, MODE_MAIN, i + 1);
      double stoch_t0 = iStochastic(NULL, 0, 5, 3, 4, MODE_SMA, 0, MODE_MAIN, i);
      double ac_t1 = iAC(NULL, 0, i + 1);
      double ac_t0 = iAC(NULL, 0, i);
      double ao_t1 = iAO(NULL, 0, i + 1);
      double ao_t0 = iAO(NULL, 0, i);
      
      bool ac_red = false; 
      bool ac_green = false;      

      if(ac_t0 < ac_t1)
         ac_red = true;
      if(ac_t0 > ac_t1)
         ac_green = true;

      // Initialize Latest Buffer Value
      OzFX_Squeeze[i] = 0.0;
      OzFX_Squeeze_Long[i] = 0.0;
      OzFX_Squeeze_Short[i] = 0.0;

      // Long Signal
      if (ac_green && stoch_t0 > 20 && (stoch_t1 < 20 || stoch_t2 < 20) )
      {
         if(last != 1)
         {
            OzFX_Squeeze[i] = 1;
            OzFX_Squeeze_Long[i] = 1;
         }
         last = 1;
      }
      // Short Signal
      else if (ac_red && stoch_t0 < 80 && (stoch_t1 > 80 || stoch_t2 > 80) )
      {
         if(last != -1)
         {
            OzFX_Squeeze[i] = -1;
            OzFX_Squeeze_Short[i] = -1;
         }
         last = -1;
      }
      
      // Reset last if neccesary
      if (ac_green && last == -1)
      {
         last = 0;
      }
      else if (ac_red && last == 1)
      {
         last = 0;
      }
   }
   

   // Trigger the Alert if Required
   string signal = "";
   if (OzFX_Squeeze[0] == 1)
      signal = "Long";
   else if (OzFX_Squeeze[0] == -1)
      signal = "Short";

   if (OzFX_Squeeze[0] != 0)
   {
      if (alertTriggered == false && lastAlertTime <= TimeCurrent() - AlertSleepMins * 60)
      {
         lastAlertTime = TimeCurrent();
         if (PopupAlerts == true)
            Alert(Symbol() + " " + signal + " signal alert");
         if (SoundAlerts == true)
            PlaySound("Alert.wav");
         if (EmailAlerts == true)
            SendMail(Symbol() + " " + signal + " signal alert",  "Stoch: " + stoch_t0 + "\n" 
                                                               + "AC Curr: " + ac_t0 + "\n" 
                                                               + "AC Prev: " + ac_t1 + "\n" 
                                                               + "AO Curr: " + ao_t0 + "\n" 
                                                               + "AO Prev: " + ao_t1 + "\n");
      }
      alertTriggered = true;
   }
   else 
      alertTriggered = false;
   
}