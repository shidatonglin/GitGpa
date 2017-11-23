//+------------------------------------------------------------------+
//|                                           Arif Endro Nugroho.mq4 |
//|      Copyright © 2009, Arif Endro Nugroho <arif_endro@yahoo.com> |
//|                                         http://www.vectra.web.id |
//|  Last updated: 2009.09.10 19:30 GMT+7                            |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Arif E. Nugroho <arif_endro@yahoo.com>"
#property link      "http://www.vectra.web.id"

#property indicator_chart_window
//---- input parameters
extern int       corner=0;
extern int       xdis=5;
extern int       ydis=20;
extern string    Font="Lucida Console";
extern int       FontSize=8;
extern color     FontColor=Blue;
extern color     FontColorMarketOpen=Red;
extern int       timezone=7;
extern bool      back=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   ObjectDelete("Home");
   ObjectCreate("Home"  , OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("Home"  , OBJPROP_BACK, back);
   ObjectSet   ("Home"  , OBJPROP_CORNER, corner);
   ObjectSet   ("Home"  , OBJPROP_XDISTANCE, xdis);
   ObjectSet   ("Home"  , OBJPROP_YDISTANCE, ydis);
   
   ObjectDelete("Dollar");
   ObjectCreate("Dollar", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("Dollar", OBJPROP_BACK, back);
   ObjectSet   ("Dollar", OBJPROP_CORNER, corner);
   ObjectSet   ("Dollar", OBJPROP_XDISTANCE, xdis);
   ObjectSet   ("Dollar", OBJPROP_YDISTANCE, ydis + 10);
   
   ObjectDelete("Cable");
   ObjectCreate("Cable" , OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("Cable" , OBJPROP_BACK, back);
   ObjectSet   ("Cable" , OBJPROP_CORNER, corner);
   ObjectSet   ("Cable" , OBJPROP_XDISTANCE, xdis);
   ObjectSet   ("Cable" , OBJPROP_YDISTANCE, ydis + 20);
   
   ObjectDelete("Yen");
   ObjectCreate("Yen"   , OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("Yen"   , OBJPROP_BACK, back);
   ObjectSet   ("Yen"   , OBJPROP_CORNER, corner);
   ObjectSet   ("Yen"   , OBJPROP_XDISTANCE, xdis);
   ObjectSet   ("Yen"   , OBJPROP_YDISTANCE, ydis + 30);
   
   ObjectDelete("Aussie");
   ObjectCreate("Aussie", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("Aussie", OBJPROP_BACK, back);
   ObjectSet   ("Aussie", OBJPROP_CORNER, corner);
   ObjectSet   ("Aussie", OBJPROP_XDISTANCE, xdis);
   ObjectSet   ("Aussie", OBJPROP_YDISTANCE, ydis + 40);
   
   ObjectDelete("Server");
   ObjectCreate("Server", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("Server", OBJPROP_BACK, back);
   ObjectSet   ("Server", OBJPROP_CORNER, corner);
   ObjectSet   ("Server", OBJPROP_XDISTANCE, xdis);
   ObjectSet   ("Server", OBJPROP_YDISTANCE, ydis + 50);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("Home");
   ObjectDelete("Cable");
   ObjectDelete("Dollar");
   ObjectDelete("Yen");
   ObjectDelete("Aussie");
   ObjectDelete("Server");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();

   color  FontColorDayPercentGain = Silver;
   color  FontColorWeekPercentGain = Silver;
   color  FontColorMonthPercentGain = Silver;
   
// New York = GMT-5, London = GMT+0, Tokyo = GMT+9, Sydney = GMT+10
   string InfoHome   = "Home.....: " + TimeToStr(TimeLocal(), TIME_DATE | TIME_SECONDS);
   string InfoUSD    = "New York.: " + TimeToStr(TimeLocal() + ((- 4 - timezone) * 3600), TIME_DATE | TIME_SECONDS);
   string InfoGBP    = "London...: " + TimeToStr(TimeLocal() + ((  0 - timezone) * 3600), TIME_DATE | TIME_SECONDS);
   string InfoJPY    = "Tokyo....: " + TimeToStr(TimeLocal() + ((  9 - timezone) * 3600), TIME_DATE | TIME_SECONDS);
   string InfoAUD    = "Sydney...: " + TimeToStr(TimeLocal() + (( 11 - timezone) * 3600), TIME_DATE | TIME_SECONDS);
   string InfoServer = "Server...: " + TimeToStr(TimeCurrent(), TIME_DATE | TIME_SECONDS);

//----

// London local session...: 08.00 - 17.00
// New York local session.: 08.00 - 17.00
// Tokyo local session....: 09.00 - 18.00
// Sydney local session...: 08.00 - 17.00

   if (TimeHour(TimeLocal()) >= 8 && TimeHour(TimeLocal()) < 17 && TimeDayOfWeek(TimeLocal()) > 0 && TimeDayOfWeek(TimeLocal()) < 6 )
    ObjectSetText("Home"  , InfoHome, FontSize, Font, FontColorMarketOpen);
   else
    ObjectSetText("Home"  , InfoHome, FontSize, Font, FontColor);

   if (TimeHour(TimeLocal() + ((- 4 - timezone) * 3600)) >= 8 && TimeHour(TimeLocal() + ((- 4 - timezone) * 3600)) < 17 && TimeDayOfWeek(TimeLocal() + ((- 4 - timezone) * 3600)) > 0 && TimeDayOfWeek(TimeLocal() + ((- 4 - timezone) * 3600)) < 6 )
    ObjectSetText("Dollar", InfoUSD, FontSize, Font, FontColorMarketOpen);
   else
    ObjectSetText("Dollar", InfoUSD, FontSize, Font, FontColor);

   if (TimeHour(TimeLocal() + ((  0 - timezone) * 3600)) >= 8 && TimeHour(TimeLocal() + ((  0 - timezone) * 3600)) < 17 && TimeDayOfWeek(TimeLocal() + ((  0 - timezone) * 3600)) > 0 && TimeDayOfWeek(TimeLocal() + ((  0 - timezone) * 3600)) < 6 )
    ObjectSetText("Cable" , InfoGBP, FontSize, Font, FontColorMarketOpen);
   else
    ObjectSetText("Cable" , InfoGBP, FontSize, Font, FontColor);

   if (TimeHour(TimeLocal() + ((  9 - timezone) * 3600)) >= 9 && TimeHour(TimeLocal() + ((  9 - timezone) * 3600)) < 18 && TimeDayOfWeek(TimeLocal() + ((  9 - timezone) * 3600)) > 0 && TimeDayOfWeek(TimeLocal() + ((  9 - timezone) * 3600)) < 6 )
    ObjectSetText("Yen"   , InfoJPY, FontSize, Font, FontColorMarketOpen);
   else
    ObjectSetText("Yen"   , InfoJPY, FontSize, Font, FontColor);

   if (TimeHour(TimeLocal() + (( 11 - timezone) * 3600)) >= 8 && TimeHour(TimeLocal() + (( 11 - timezone) * 3600)) < 17 && TimeDayOfWeek(TimeLocal() + (( 11 - timezone) * 3600)) > 0 && TimeDayOfWeek(TimeLocal() + (( 11 - timezone) * 3600)) < 6 )
    ObjectSetText("Aussie", InfoAUD, FontSize, Font, FontColorMarketOpen);
   else
    ObjectSetText("Aussie", InfoAUD, FontSize, Font, FontColor);

    ObjectSetText("Server", InfoServer, FontSize, Font, FontColor);
//----
   return(0);
  }
//+------------------------------------------------------------------+  