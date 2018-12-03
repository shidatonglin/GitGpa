
#property copyright "Copyright 2013 © Forexprofitsupreme"
#property link      "www.Forexprofitsupreme.com"

#property indicator_separate_window
#property indicator_minimum 0.0
#property indicator_maximum 1.0
#property indicator_buffers 2
#property indicator_color1 LimeGreen
#property indicator_color2 DarkOrange

extern string TimeFrame = "current time frame";
extern int SmoothPeriod = 5;
extern int SmoothPhase = 0;
extern bool alertsOn = FALSE;
extern bool alertsOnCurrent = FALSE;
extern bool alertsMessage = FALSE;
extern bool alertsSound = FALSE;
extern bool alertsEmail = FALSE;
double g_ibuf_112[];
double g_ibuf_116[];
double g_ibuf_120[];
int g_timeframe_124;
bool gi_128 = FALSE;
bool gi_132 = FALSE;
string gs_136;
string gs_nothing_144 = "nothing";
datetime g_time_152;
string gsa_156[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int gia_160[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};
double gda_164[][30];

int init() {
   IndicatorBuffers(3);
   SetIndexBuffer(0, g_ibuf_112);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(1, g_ibuf_116);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(2, g_ibuf_120);
   if (TimeFrame == "calculate") {
      gi_128 = TRUE;
      return (0);
   }
   if (TimeFrame == "getBarsCount") {
      gi_132 = TRUE;
      return (0);
   }
   g_timeframe_124 = f0_5(TimeFrame);
   gs_136 = WindowExpertName();
   IndicatorShortName(f0_1(g_timeframe_124) + "ForexprofitsupremeFilter");
   return (0);
}

int start() {
   double ld_0;
   double ld_8;
   double ld_16;
   int shift_24;
   int li_28 = IndicatorCounted();
   if (li_28 < 0) return (-1);
   if (li_28 > 0) li_28--;
   int li_32 = MathMin(Bars - li_28, Bars - 1);
   if (gi_132) {
      g_ibuf_112[0] = li_32 + 1;
      return (0);
   }
   if (gi_128 || g_timeframe_124 == Period()) {
      for (int li_36 = li_32; li_36 >= 0; li_36--) {
         ld_0 = f0_3(High[li_36 + 1], SmoothPeriod, SmoothPhase, li_36 + 1, 0);
         ld_8 = f0_3(Low[li_36 + 1], SmoothPeriod, SmoothPhase, li_36 + 1, 10);
         ld_16 = f0_3(Close[li_36], SmoothPeriod, SmoothPhase, li_36, 20);
         g_ibuf_116[li_36] = EMPTY_VALUE;
         g_ibuf_112[li_36] = EMPTY_VALUE;
         g_ibuf_120[li_36] = g_ibuf_120[li_36 + 1];
         if (ld_16 > ld_0) g_ibuf_120[li_36] = -1;
         if (ld_16 < ld_8) g_ibuf_120[li_36] = 1;
         if (g_ibuf_120[li_36] == 1.0) g_ibuf_116[li_36] = 1;
         if (g_ibuf_120[li_36] == -1.0) g_ibuf_112[li_36] = 1;
      }
      f0_2();
      return (0);
   }
   li_32 = MathMax(li_32, MathMin(Bars, iCustom(NULL, g_timeframe_124, gs_136, "getBarsCount", 0, 0) * g_timeframe_124 / Period()));
   for (li_36 = li_32; li_36 >= 0; li_36--) {
      shift_24 = iBarShift(NULL, g_timeframe_124, Time[li_36]);
      g_ibuf_116[li_36] = EMPTY_VALUE;
      g_ibuf_112[li_36] = EMPTY_VALUE;
      g_ibuf_120[li_36] = iCustom(NULL, g_timeframe_124, gs_136, "calculate", SmoothPeriod, SmoothPhase, 2, shift_24);
      if (g_ibuf_120[li_36] == 1.0) g_ibuf_116[li_36] = 1;
      if (g_ibuf_120[li_36] == -1.0) g_ibuf_112[li_36] = 1;
   }
   f0_2();
   return (0);
}

void f0_2() {
   int li_0;
   if ((!gi_128) && alertsOn) {
      if (alertsOnCurrent) li_0 = 0;
      else li_0 = 1;
      li_0 = iBarShift(NULL, 0, iTime(NULL, g_timeframe_124, li_0));
      if (g_ibuf_120[li_0] != g_ibuf_120[li_0 + 1]) {
         if (g_ibuf_120[li_0] == 1.0) {
            f0_6(li_0, "up");
            return;
         }
         f0_6(li_0, "down");
      }
   }
}

void f0_6(int ai_0, string as_4) {
   string str_concat_12;
   if (gs_nothing_144 != as_4 || g_time_152 != Time[ai_0]) {
      gs_nothing_144 = as_4;
      g_time_152 = Time[ai_0];
      str_concat_12 = StringConcatenate(Symbol(), " at ", TimeToStr(TimeLocal(), TIME_SECONDS), " ForexprofitsupremeFilter direction changed to", as_4);
      if (alertsMessage) Alert(str_concat_12);
      if (alertsEmail) SendMail(StringConcatenate(Symbol(), "ForexprofitsupremeFilter"), str_concat_12);
      if (alertsSound) PlaySound("alert2.wav");
   }
}

int f0_5(string as_0) {
   as_0 = f0_0(as_0);
   for (int li_8 = ArraySize(gia_160) - 1; li_8 >= 0; li_8--)
      if (as_0 == gsa_156[li_8] || as_0 == "" + gia_160[li_8]) return (MathMax(gia_160[li_8], Period()));
   return (Period());
}

string f0_1(int ai_0) {
   for (int li_4 = ArraySize(gia_160) - 1; li_4 >= 0; li_4--)
      if (ai_0 == gia_160[li_4]) return (gsa_156[li_4]);
   return ("");
}

string f0_0(string as_0) {
   int li_8;
   string ls_ret_12 = as_0;
   for (int li_20 = StringLen(as_0) - 1; li_20 >= 0; li_20--) {
      li_8 = StringGetChar(ls_ret_12, li_20);
      if ((li_8 > '`' && li_8 < '{') || (li_8 > 'ß' && li_8 < 256)) ls_ret_12 = StringSetChar(ls_ret_12, li_20, li_8 - 32);
      else
         if (li_8 > -33 && li_8 < 0) ls_ret_12 = StringSetChar(ls_ret_12, li_20, li_8 + 224);
   }
   return (ls_ret_12);
}

double f0_3(double ad_0, double ad_8, double ad_16, int ai_24, int ai_28 = 0) {
   double ld_32;
   double ld_40;
   if (ArrayRange(gda_164, 0) != Bars) ArrayResize(gda_164, Bars);
   int li_48 = Bars - ai_24 - 1;
   if (li_48 == 0) {
      for (int count_52 = 0; count_52 < 7; count_52++) gda_164[0][count_52 + ai_28] = ad_0;
      while (count_52 < 10) {
         gda_164[0][count_52 + ai_28] = 0;
         count_52++;
      }
      return (ad_0);
   }
   double ld_56 = MathMax(MathLog(MathSqrt((ad_8 - 1.0) / 2.0)) / MathLog(2.0) + 2.0, 0);
   double ld_64 = MathMax(ld_56 - 2.0, 0.5);
   double ld_72 = ad_0 - (gda_164[li_48 - 1][ai_28 + 5]);
   double ld_80 = ad_0 - (gda_164[li_48 - 1][ai_28 + 6]);
   gda_164[li_48][ai_28 + 7] = 0;
   if (MathAbs(ld_72) > MathAbs(ld_80)) gda_164[li_48][ai_28 + 7] = MathAbs(ld_72);
   if (MathAbs(ld_72) < MathAbs(ld_80)) gda_164[li_48][ai_28 + 7] = MathAbs(ld_80);
   gda_164[li_48][ai_28 + 8] = gda_164[li_48 - 1][ai_28 + 8] + (gda_164[li_48][ai_28 + 7] - (gda_164[li_48 - 10][ai_28 + 7])) / 10.0;
   double ld_88 = MathMin(MathMax(4.0 * ad_8, 30), 150);
   if (li_48 < ld_88) {
      ld_32 = gda_164[li_48][ai_28 + 8];
      for (count_52 = 1; count_52 < ld_88 && li_48 - count_52 >= 0; count_52++) ld_32 += gda_164[li_48 - count_52][ai_28 + 8];
      ld_32 /= count_52;
   } else ld_32 = ((gda_164[li_48 - 1][ai_28 + 9]) * ld_88 - (gda_164[li_48 - f0_4(ld_88)][ai_28 + 8]) + (gda_164[li_48][ai_28 + 8])) / ld_88;
   gda_164[li_48][ai_28 + 9] = ld_32;
   if (gda_164[li_48][ai_28 + 9] > 0.0) ld_40 = (gda_164[li_48][ai_28 + 7]) / (gda_164[li_48][ai_28 + 9]);
   else ld_40 = 0;
   if (ld_40 > MathPow(ld_56, 1.0 / ld_64)) ld_40 = MathPow(ld_56, 1.0 / ld_64);
   if (ld_40 < 1.0) ld_40 = 1.0;
   double ld_96 = MathPow(ld_40, ld_64);
   double ld_104 = MathSqrt((ad_8 - 1.0) / 2.0) * ld_56;
   double ld_112 = MathPow(ld_104 / (ld_104 + 1.0), MathSqrt(ld_96));
   if (ld_72 > 0.0) gda_164[li_48][ai_28 + 5] = ad_0;
   else gda_164[li_48][ai_28 + 5] = ad_0 - ld_112 * ld_72;
   if (ld_80 < 0.0) gda_164[li_48][ai_28 + 6] = ad_0;
   else gda_164[li_48][ai_28 + 6] = ad_0 - ld_112 * ld_80;
   double ld_120 = MathMax(MathMin(ad_16, 100), -100) / 100.0 + 1.5;
   double ld_128 = (ad_8 - 1.0) / 2.0 / ((ad_8 - 1.0) / 2.0 + 2.0);
   double ld_136 = MathPow(ld_128, ld_96);
   gda_164[li_48][ai_28 + 0] = ad_0 + ld_136 * (gda_164[li_48 - 1][ai_28 + 0] - ad_0);
   gda_164[li_48][ai_28 + 1] = (ad_0 - (gda_164[li_48][ai_28 + 0])) * (1 - ld_128) + ld_128 * (gda_164[li_48 - 1][ai_28 + 1]);
   gda_164[li_48][ai_28 + 2] = gda_164[li_48][ai_28 + 0] + ld_120 * (gda_164[li_48][ai_28 + 1]);
   gda_164[li_48][ai_28 + 3] = (gda_164[li_48][ai_28 + 2] - (gda_164[li_48 - 1][ai_28 + 4])) * MathPow(1 - ld_136, 2) + MathPow(ld_136, 2) * (gda_164[li_48 - 1][ai_28 +
      3]);
   gda_164[li_48][ai_28 + 4] = gda_164[li_48 - 1][ai_28 + 4] + (gda_164[li_48][ai_28 + 3]);
   return (gda_164[li_48][ai_28 + 4]);
}

int f0_4(double ad_0) {
   return (ad_0);
}