
#property copyright "Copyright © Forexprofitsupreme"
#property link      "www.Forexprofitsupreme.com"

#property indicator_chart_window

extern color ClockColor = Fuchsia;
double gda_unused_80[];

int deinit() {
   ObjectDelete("time");
   return (0);
}

int init() {
   return (0);
}

int start() {
   int li_8 = Time[0] + 60 * Period() - TimeCurrent();
   double ld_0 = li_8 / 60.0;
   int li_12 = li_8 % 60;
   li_8 = (li_8 - li_8 % 60) / 60;
   Comment(li_8 + " minutes " + li_12 + " seconds left to bar end");
   ObjectDelete("time");
   if (ObjectFind("time") != 0) {
      ObjectCreate("time", OBJ_TEXT, 0, Time[0], Close[0] + 0.0005);
      ObjectSetText("time", "                  <" + li_8 + ":" + li_12, 8, "Arial", ClockColor);
   } else ObjectMove("time", 0, Time[0], Close[0] + 0.0005);
   return (0);
}