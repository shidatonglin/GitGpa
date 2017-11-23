
#property copyright "Mr. X"
#property link      "metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red

extern string Indicator_Name = "==== Buyers vs. Sellers =====";
extern string Options = "===== User Options =====";
extern int BvSPeriod = 9;
extern bool ShowHistogram = FALSE;
extern bool ShowDelta = FALSE;
extern color Label_Color = Silver;
extern color Buyers_Color = Lime;
extern color Sellers_Color = Red;
extern bool Top_Right_Corner = TRUE;
extern int Shift_Up_Down = 0;
extern int Shift_Left_Right = 0;
int g_color_144 = Silver;
int g_color_148 = Silver;
int g_color_152 = Silver;
int g_color_156 = Silver;
int g_color_160 = Silver;
int g_color_164 = Silver;
int g_color_168 = Silver;
double g_ibuf_172[];
double g_ibuf_176[];
string gs_null_180 = "NULL";
string gs_null_188 = "NULL";
string gs_null_196 = "NULL";
string gs_null_204 = "NULL";
string gs_null_212 = "NULL";
string gs_null_220 = "NULL";
string gs_null_228 = "NULL";
string gs_null_236 = "NULL";
string gs_null_244 = "NULL";
string gs_null_252 = "NULL";
string gs_null_260 = "NULL";
string gs_null_268 = "NULL";
string gs_null_276 = "NULL";
string gs_null_284 = "NULL";
string gs_null_292 = "NULL";
string gs_null_300 = "NULL";
string gs_null_308 = "NULL";
string gs_null_316 = "NULL";
string gs_null_324 = "NULL";
string gs_null_332 = "NULL";
string gs_null_340 = "NULL";

int init() {
   IndicatorBuffers(2);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS) + 2.0);
   SetIndexBuffer(0, g_ibuf_172);
   SetIndexBuffer(1, g_ibuf_176);
   IndicatorShortName("Buyers vs. Sellers v3 (" + BvSPeriod + ")");
   return (0);
}

int deinit() {
   ObjectDelete("BuyersLabel");
   ObjectDelete("SellersLabel");
   ObjectDelete("BuyersLabel5");
   ObjectDelete("SellersLabel5");
   ObjectDelete("wLabel");
   return (0);
}

int start() {
   double ld_12;
   double ld_20;
   double l_ivolume_28;
   double ld_36;
   double ld_44;
   double ld_52;
   double ld_60;
   double ld_68;
   double ld_76;
   double ld_84;
   double ld_92;
   double l_ivolume_100;
   double ld_108;
   double ld_116;
   double ld_124;
   double ld_132;
   double ld_140;
   double ld_148;
   double ld_156;
   double l_ivolume_164;
   double ld_172;
   double ld_180;
   double ld_188;
   double ld_196;
   double ld_204;
   double ld_212;
   double ld_220;
   double l_ivolume_228;
   double ld_236;
   double ld_244;
   double ld_252;
   double ld_260;
   double ld_268;
   double ld_276;
   double ld_284;
   double l_ivolume_292;
   double ld_300;
   double ld_308;
   double ld_316;
   double ld_324;
   double ld_332;
   double ld_340;
   double ld_348;
   double l_ivolume_356;
   double ld_364;
   double ld_372;
   double ld_380;
   double ld_388;
   double ld_396;
   double ld_404;
   double ld_412;
   double l_ivolume_420;
   double ld_428;
   double ld_436;
   double ld_444;
   double ld_452;
   double ld_460;
   double ld_468;
   double ld_476;
   double l_ivolume_484;
   double ld_492;
   double ld_500;
   double ld_508;
   double ld_516;
   double ld_524;
   string ls_unused_700;
   color l_color_708;
   color l_color_712;
   color l_color_716;
   color l_color_720;
   color l_color_724;
   color l_color_728;
   color l_color_732;
   
   
   
   int li_4 = IndicatorCounted();
   if (li_4 < 0) return (-1);
   if (li_4 > 0) li_4--;
   int li_8 = Bars - li_4 - 1;
   for (int li_0 = 0; li_0 < li_8; li_0++) {
      ld_12 = MathAbs(iBullsPower(NULL, 0, BvSPeriod, PRICE_CLOSE, li_0));
      ld_20 = MathAbs(iBearsPower(NULL, 0, BvSPeriod, PRICE_CLOSE, li_0));
      l_ivolume_28 = iVolume(NULL, 0, li_0);
      ld_36 = ld_12 * l_ivolume_28 / (ld_12 + ld_20);
      ld_44 = ld_20 * l_ivolume_28 / (ld_12 + ld_20);
      ld_52 = ld_36 - ld_44;
      ld_60 = ld_36 - ld_44;
      ld_68 = 100.0 * (ld_36 / (ld_36 + ld_44));
      ld_76 = 100.0 * (ld_44 / (ld_36 + ld_44));
      ld_84 = MathAbs(iBullsPower(NULL, PERIOD_M1, BvSPeriod, PRICE_CLOSE, li_0));
      ld_92 = MathAbs(iBearsPower(NULL, PERIOD_M1, BvSPeriod, PRICE_CLOSE, li_0));
      l_ivolume_100 = iVolume(NULL, PERIOD_M1, li_0);
      ld_108 = ld_84 * l_ivolume_100 / (ld_84 + ld_92);
      ld_116 = ld_92 * l_ivolume_100 / (ld_84 + ld_92);
      ld_124 = 100.0 * (ld_108 / (ld_108 + ld_116));
      ld_132 = 100.0 * (ld_116 / (ld_108 + ld_116));
      if (ld_108 > ld_116) {
         ld_140 = ld_124;
         g_color_144 = Buyers_Color;
      }
      if (ld_108 < ld_116) {
         ld_140 = ld_132;
         g_color_144 = Sellers_Color;
      }
      ld_148 = MathAbs(iBullsPower(NULL, PERIOD_M5, BvSPeriod, PRICE_CLOSE, li_0));
      ld_156 = MathAbs(iBearsPower(NULL, PERIOD_M5, BvSPeriod, PRICE_CLOSE, li_0));
      l_ivolume_164 = iVolume(NULL, PERIOD_M5, li_0);
      ld_172 = ld_148 * l_ivolume_164 / (ld_148 + ld_156);
      ld_180 = ld_156 * l_ivolume_164 / (ld_148 + ld_156);
      ld_188 = 100.0 * (ld_172 / (ld_172 + ld_180));
      ld_196 = 100.0 * (ld_180 / (ld_172 + ld_180));
      if (ld_172 > ld_180) {
         ld_204 = ld_188;
         g_color_148 = Buyers_Color;
      }
      if (ld_172 < ld_180) {
         ld_204 = ld_196;
         g_color_148 = Sellers_Color;
      }
      ld_212 = MathAbs(iBullsPower(NULL, PERIOD_M15, BvSPeriod, PRICE_CLOSE, li_0));
      ld_220 = MathAbs(iBearsPower(NULL, PERIOD_M15, BvSPeriod, PRICE_CLOSE, li_0));
      l_ivolume_228 = iVolume(NULL, PERIOD_M15, li_0);
      ld_236 = ld_212 * l_ivolume_228 / (ld_212 + ld_220);
      ld_244 = ld_220 * l_ivolume_228 / (ld_212 + ld_220);
      ld_252 = 100.0 * (ld_236 / (ld_236 + ld_244));
      ld_260 = 100.0 * (ld_244 / (ld_236 + ld_244));
      if (ld_236 > ld_244) {
         ld_268 = ld_252;
         g_color_152 = Buyers_Color;
      }
      if (ld_236 < ld_244) {
         ld_268 = ld_260;
         g_color_152 = Sellers_Color;
      }
      ld_276 = MathAbs(iBullsPower(NULL, PERIOD_M30, BvSPeriod, PRICE_CLOSE, li_0));
      ld_284 = MathAbs(iBearsPower(NULL, PERIOD_M30, BvSPeriod, PRICE_CLOSE, li_0));
      l_ivolume_292 = iVolume(NULL, PERIOD_M30, li_0);
      ld_300 = ld_276 * l_ivolume_292 / (ld_276 + ld_284);
      ld_308 = ld_284 * l_ivolume_292 / (ld_276 + ld_284);
      ld_316 = 100.0 * (ld_172 / (ld_300 + ld_308));
      ld_324 = 100.0 * (ld_308 / (ld_300 + ld_308));
      if (ld_300 > ld_308) {
         ld_332 = ld_316;
         g_color_156 = Buyers_Color;
      }
      if (ld_300 < ld_308) {
         ld_332 = ld_324;
         g_color_156 = Sellers_Color;
      }
      ld_340 = MathAbs(iBullsPower(NULL, PERIOD_H1, BvSPeriod, PRICE_CLOSE, li_0));
      ld_348 = MathAbs(iBearsPower(NULL, PERIOD_H1, BvSPeriod, PRICE_CLOSE, li_0));
      l_ivolume_356 = iVolume(NULL, PERIOD_H1, li_0);
      ld_364 = ld_340 * l_ivolume_356 / (ld_340 + ld_348);
      ld_372 = ld_348 * l_ivolume_356 / (ld_340 + ld_348);
      ld_380 = 100.0 * (ld_364 / (ld_364 + ld_372));
      ld_388 = 100.0 * (ld_372 / (ld_364 + ld_372));
      if (ld_364 > ld_372) {
         ld_396 = ld_380;
         g_color_160 = Buyers_Color;
      }
      if (ld_364 < ld_372) {
         ld_396 = ld_388;
         g_color_160 = Sellers_Color;
      }
      ld_404 = MathAbs(iBullsPower(NULL, PERIOD_H4, BvSPeriod, PRICE_CLOSE, li_0));
      ld_412 = MathAbs(iBearsPower(NULL, PERIOD_H4, BvSPeriod, PRICE_CLOSE, li_0));
      l_ivolume_420 = iVolume(NULL, PERIOD_H4, li_0);
      ld_428 = ld_404 * l_ivolume_420 / (ld_404 + ld_412);
      ld_436 = ld_412 * l_ivolume_420 / (ld_404 + ld_412);
      ld_444 = 100.0 * (ld_428 / (ld_428 + ld_436));
      ld_452 = 100.0 * (ld_436 / (ld_428 + ld_436));
      if (ld_428 > ld_436) {
         ld_460 = ld_444;
         g_color_164 = Buyers_Color;
      }
      if (ld_428 < ld_436) {
         ld_460 = ld_452;
         g_color_164 = Sellers_Color;
      }
      ld_468 = MathAbs(iBullsPower(NULL, PERIOD_D1, BvSPeriod, PRICE_CLOSE, li_0));
      ld_476 = MathAbs(iBearsPower(NULL, PERIOD_D1, BvSPeriod, PRICE_CLOSE, li_0));
      l_ivolume_484 = iVolume(NULL, PERIOD_D1, li_0);
      ld_492 = ld_468 * l_ivolume_484 / (ld_468 + ld_476);
      ld_500 = ld_476 * l_ivolume_484 / (ld_468 + ld_476);
      ld_508 = 100.0 * (ld_492 / (ld_492 + ld_500));
      ld_516 = 100.0 * (ld_500 / (ld_492 + ld_500));
      if (ld_492 > ld_500) {
         ld_524 = ld_508;
         g_color_168 = Buyers_Color;
      }
      if (ld_492 < ld_500) {
         ld_524 = ld_516;
         g_color_168 = Sellers_Color;
      }
      if (ShowHistogram == TRUE) {
         if (ShowDelta == TRUE) {
            if (ld_36 > ld_44) {
               g_ibuf_172[li_0] = ld_52;
               g_ibuf_176[li_0] = 0;
            }
            if (ld_36 < ld_44) {
               g_ibuf_176[li_0] = ld_60;
               g_ibuf_172[li_0] = 0;
            }
            if (ld_36 == ld_44) {
               g_ibuf_176[li_0] = ld_60;
               g_ibuf_172[li_0] = 0;
            }
         }
         if (!ShowDelta) {
            if (ld_36 > ld_44) {
               g_ibuf_172[li_0] = ld_36;
               g_ibuf_176[li_0] = 0;
            }
            if (ld_36 < ld_44) {
               g_ibuf_176[li_0] = ld_44;
               g_ibuf_172[li_0] = 0;
            }
            if (ld_36 == ld_44) {
               g_ibuf_176[li_0] = ld_44;
               g_ibuf_172[li_0] = 0;
            }
         }
      }
      if (!ShowHistogram) {
         if (ld_36 > ld_44) {
            g_ibuf_172[li_0] = 1;
            g_ibuf_176[li_0] = 0;
         }
         if (ld_36 < ld_44) {
            g_ibuf_176[li_0] = 1;
            g_ibuf_172[li_0] = 0;
         }
         if (ld_36 == ld_44) {
            g_ibuf_176[li_0] = 1;
            g_ibuf_172[li_0] = 0;
         }
      }
   }
   ObjectCreate("wLabel", OBJ_LABEL, WindowFind("Buyers vs. Sellers v3 (" + BvSPeriod + ")"), 0, 0);
   ObjectSetText("wLabel", "Buyers vs. Sellers", 10, "Arial Bold", DarkSlateGray);
   ObjectSet("wLabel", OBJPROP_YDISTANCE, 1);
   ObjectSet("wLabel", OBJPROP_XDISTANCE, 10);
   ObjectSet("wLabel", OBJPROP_CORNER, 1);
   if (Top_Right_Corner == 1) {
      ObjectCreate("Header", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("Header", "M1        M5       M15       M30       H1         H4         D1", 8, "Tahoma Narrow", Label_Color);
      ObjectSet("Header", OBJPROP_CORNER, Top_Right_Corner);
      ObjectSet("Header", OBJPROP_XDISTANCE, Shift_Left_Right + 32);
      ObjectSet("Header", OBJPROP_YDISTANCE, Shift_Up_Down + 15);
   }
   if (Top_Right_Corner == 0) {
      ObjectCreate("Header", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("Header", "D1        H4         H1        M30       M15       M5        M1", 8, "Tahoma Narrow", Label_Color);
      ObjectSet("Header", OBJPROP_CORNER, Top_Right_Corner);
      ObjectSet("Header", OBJPROP_XDISTANCE, Shift_Left_Right + 32);
      ObjectSet("Header", OBJPROP_YDISTANCE, Shift_Up_Down + 15);
   }
   double ld_532 = MathAbs(iBullsPower(NULL, PERIOD_M1, BvSPeriod, PRICE_CLOSE, 0));
   double ld_540 = MathAbs(iBearsPower(NULL, PERIOD_M1, BvSPeriod, PRICE_CLOSE, 0));
   double ld_548 = MathAbs(iBullsPower(NULL, PERIOD_M5, BvSPeriod, PRICE_CLOSE, 0));
   double ld_556 = MathAbs(iBearsPower(NULL, PERIOD_M5, BvSPeriod, PRICE_CLOSE, 0));
   double ld_564 = MathAbs(iBullsPower(NULL, PERIOD_M15, BvSPeriod, PRICE_CLOSE, 0));
   double ld_572 = MathAbs(iBearsPower(NULL, PERIOD_M15, BvSPeriod, PRICE_CLOSE, 0));
   double ld_580 = MathAbs(iBullsPower(NULL, PERIOD_M30, BvSPeriod, PRICE_CLOSE, 0));
   double ld_588 = MathAbs(iBearsPower(NULL, PERIOD_M30, BvSPeriod, PRICE_CLOSE, 0));
   double ld_596 = MathAbs(iBullsPower(NULL, PERIOD_H1, BvSPeriod, PRICE_CLOSE, 0));
   double ld_604 = MathAbs(iBearsPower(NULL, PERIOD_H1, BvSPeriod, PRICE_CLOSE, 0));
   double ld_612 = MathAbs(iBullsPower(NULL, PERIOD_H4, BvSPeriod, PRICE_CLOSE, 0));
   double ld_620 = MathAbs(iBearsPower(NULL, PERIOD_H4, BvSPeriod, PRICE_CLOSE, 0));
   double ld_628 = MathAbs(iBullsPower(NULL, PERIOD_D1, BvSPeriod, PRICE_CLOSE, 0));
   double ld_636 = MathAbs(iBearsPower(NULL, PERIOD_D1, BvSPeriod, PRICE_CLOSE, 0));
   string l_text_644 = "";
   string l_text_652 = "";
   string l_text_660 = "";
   string l_text_668 = "";
   string l_text_676 = "";
   string l_text_684 = "";
   string l_text_692 = "";
   if (ld_532 >= ld_540) {
      l_text_644 = "-";
      l_color_708 = Lime;
   }
   if (ld_532 < ld_540) {
      l_text_644 = "-";
      l_color_708 = Red;
   }
   if (ld_548 >= ld_556) {
      l_text_652 = "-";
      l_color_712 = Lime;
   }
   if (ld_548 < ld_556) {
      l_text_652 = "-";
      l_color_712 = Red;
   }
   if (ld_564 >= ld_572) {
      l_text_660 = "-";
      l_color_716 = Lime;
   }
   if (ld_564 < ld_572) {
      l_text_660 = "-";
      l_color_716 = Red;
   }
   if (ld_580 >= ld_588) {
      l_text_668 = "-";
      l_color_720 = Lime;
   }
   if (ld_580 < ld_588) {
      l_text_668 = "-";
      l_color_720 = Red;
   }
   if (ld_596 >= ld_604) {
      l_text_676 = "-";
      l_color_724 = Lime;
   }
   if (ld_596 < ld_604) {
      l_text_676 = "-";
      l_color_724 = Red;
   }
   if (ld_612 >= ld_620) {
      l_text_684 = "-";
      l_color_728 = Lime;
   }
   if (ld_612 < ld_620) {
      l_text_684 = "-";
      l_color_728 = Red;
   }
   if (ld_628 >= ld_636) {
      l_text_692 = "-";
      l_color_732 = Lime;
   }
   if (ld_628 < ld_636) {
      l_text_692 = "-";
      l_color_732 = Red;
   }
   ObjectCreate("BVSM1t", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("BVSM1t", "Trend", 9, "Tahoma Narrow", Label_Color);
   ObjectSet("BVSM1t", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("BVSM1t", OBJPROP_XDISTANCE, Shift_Left_Right + 310);
   ObjectSet("BVSM1t", OBJPROP_YDISTANCE, Shift_Up_Down + 75);
   ObjectCreate("BVSMb", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("BVSMb", "Buyers", 9, "Tahoma Narrow", Label_Color);
   ObjectSet("BVSMb", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("BVSMb", OBJPROP_XDISTANCE, Shift_Left_Right + 310);
   ObjectSet("BVSMb", OBJPROP_YDISTANCE, Shift_Up_Down + 35);
   ObjectCreate("BVSMs", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("BVSMs", "Sellers", 9, "Tahoma Narrow", Label_Color);
   ObjectSet("BVSMs", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("BVSMs", OBJPROP_XDISTANCE, Shift_Left_Right + 310);
   ObjectSet("BVSMs", OBJPROP_YDISTANCE, Shift_Up_Down + 55);
   ObjectCreate("BVSM1", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("BVSM1", l_text_644, 75, "Tahoma Narrow", l_color_708);
   ObjectSet("BVSM1", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("BVSM1", OBJPROP_XDISTANCE, Shift_Left_Right + 260);
   ObjectSet("BVSM1", OBJPROP_YDISTANCE, Shift_Up_Down + 18);
   gs_null_180 = DoubleToStr(ld_108, 0) + "";
   ObjectCreate("Buyers1", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Buyers1", gs_null_180, 9, "Tahoma Narrow", Buyers_Color);
   ObjectSet("Buyers1", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Buyers1", OBJPROP_XDISTANCE, Shift_Left_Right + 263);
   ObjectSet("Buyers1", OBJPROP_YDISTANCE, Shift_Up_Down + 35);
   gs_null_188 = DoubleToStr(ld_116, 0) + "";
   ObjectCreate("Sellers1", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Sellers1", gs_null_188, 9, "Tahoma Narrow", Sellers_Color);
   ObjectSet("Sellers1", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Sellers1", OBJPROP_XDISTANCE, Shift_Left_Right + 263);
   ObjectSet("Sellers1", OBJPROP_YDISTANCE, Shift_Up_Down + 55);
   gs_null_292 = DoubleToStr(ld_140, 0) + "%";
   ObjectCreate("Pwr1", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Pwr1", gs_null_292, 9, "Tahoma Narrow", g_color_144);
   ObjectSet("Pwr1", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Pwr1", OBJPROP_XDISTANCE, Shift_Left_Right + 263);
   ObjectSet("Pwr1", OBJPROP_YDISTANCE, Shift_Up_Down + 95);
   ObjectCreate("BVSM5", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("BVSM5", l_text_652, 75, "Tahoma Narrow", l_color_712);
   ObjectSet("BVSM5", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("BVSM5", OBJPROP_XDISTANCE, Shift_Left_Right + 220);
   ObjectSet("BVSM5", OBJPROP_YDISTANCE, Shift_Up_Down + 18);
   gs_null_196 = DoubleToStr(ld_172, 0) + "";
   ObjectCreate("Buyers5", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Buyers5", gs_null_196, 9, "Tahoma Narrow", Buyers_Color);
   ObjectSet("Buyers5", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Buyers5", OBJPROP_XDISTANCE, Shift_Left_Right + 223);
   ObjectSet("Buyers5", OBJPROP_YDISTANCE, Shift_Up_Down + 35);
   gs_null_204 = DoubleToStr(ld_180, 0) + "";
   ObjectCreate("Sellers5", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Sellers5", gs_null_204, 9, "Tahoma Narrow", Sellers_Color);
   ObjectSet("Sellers5", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Sellers5", OBJPROP_XDISTANCE, Shift_Left_Right + 223);
   ObjectSet("Sellers5", OBJPROP_YDISTANCE, Shift_Up_Down + 55);
   gs_null_300 = DoubleToStr(ld_204, 0) + "%";
   ObjectCreate("Pwr5", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Pwr5", gs_null_300, 9, "Tahoma Narrow", g_color_148);
   ObjectSet("Pwr5", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Pwr5", OBJPROP_XDISTANCE, Shift_Left_Right + 223);
   ObjectSet("Pwr5", OBJPROP_YDISTANCE, Shift_Up_Down + 95);
   ObjectCreate("BVSM15", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("BVSM15", l_text_660, 75, "Tahoma Narrow", l_color_716);
   ObjectSet("BVSM15", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("BVSM15", OBJPROP_XDISTANCE, Shift_Left_Right + 180);
   ObjectSet("BVSM15", OBJPROP_YDISTANCE, Shift_Up_Down + 18);
   gs_null_212 = DoubleToStr(ld_236, 0) + "";
   ObjectCreate("Buyers15", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Buyers15", gs_null_212, 9, "Tahoma Narrow", Buyers_Color);
   ObjectSet("Buyers15", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Buyers15", OBJPROP_XDISTANCE, Shift_Left_Right + 183);
   ObjectSet("Buyers15", OBJPROP_YDISTANCE, Shift_Up_Down + 35);
   gs_null_220 = DoubleToStr(ld_244, 0) + "";
   ObjectCreate("Sellers15", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Sellers15", gs_null_220, 9, "Tahoma Narrow", Sellers_Color);
   ObjectSet("Sellers15", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Sellers15", OBJPROP_XDISTANCE, Shift_Left_Right + 183);
   ObjectSet("Sellers15", OBJPROP_YDISTANCE, Shift_Up_Down + 55);
   gs_null_308 = DoubleToStr(ld_268, 0) + "%";
   ObjectCreate("Pwr15", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Pwr15", gs_null_308, 9, "Tahoma Narrow", g_color_152);
   ObjectSet("Pwr15", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Pwr15", OBJPROP_XDISTANCE, Shift_Left_Right + 183);
   ObjectSet("Pwr15", OBJPROP_YDISTANCE, Shift_Up_Down + 95);
   ObjectCreate("BVSM30", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("BVSM30", l_text_668, 75, "Tahoma Narrow", l_color_720);
   ObjectSet("BVSM30", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("BVSM30", OBJPROP_XDISTANCE, Shift_Left_Right + 140);
   ObjectSet("BVSM30", OBJPROP_YDISTANCE, Shift_Up_Down + 18);
   gs_null_228 = DoubleToStr(ld_300, 0) + "";
   ObjectCreate("Buyers30", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Buyers30", gs_null_228, 9, "Tahoma Narrow", Buyers_Color);
   ObjectSet("Buyers30", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Buyers30", OBJPROP_XDISTANCE, Shift_Left_Right + 143);
   ObjectSet("Buyers30", OBJPROP_YDISTANCE, Shift_Up_Down + 35);
   gs_null_236 = DoubleToStr(ld_308, 0) + "";
   ObjectCreate("Sellers30", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Sellers30", gs_null_236, 9, "Tahoma Narrow", Sellers_Color);
   ObjectSet("Sellers30", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Sellers30", OBJPROP_XDISTANCE, Shift_Left_Right + 143);
   ObjectSet("Sellers30", OBJPROP_YDISTANCE, Shift_Up_Down + 55);
   gs_null_316 = DoubleToStr(ld_332, 0) + "%";
   ObjectCreate("Pwr30", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Pwr30", gs_null_316, 9, "Tahoma Narrow", g_color_156);
   ObjectSet("Pwr30", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Pwr30", OBJPROP_XDISTANCE, Shift_Left_Right + 143);
   ObjectSet("Pwr30", OBJPROP_YDISTANCE, Shift_Up_Down + 95);
   ObjectCreate("BVSM60", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("BVSM60", l_text_676, 75, "Tahoma Narrow", l_color_724);
   ObjectSet("BVSM60", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("BVSM60", OBJPROP_XDISTANCE, Shift_Left_Right + 100);
   ObjectSet("BVSM60", OBJPROP_YDISTANCE, Shift_Up_Down + 18);
   gs_null_244 = DoubleToStr(ld_364, 0) + "";
   ObjectCreate("Buyers60", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Buyers60", gs_null_244, 9, "Tahoma Narrow", Buyers_Color);
   ObjectSet("Buyers60", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Buyers60", OBJPROP_XDISTANCE, Shift_Left_Right + 103);
   ObjectSet("Buyers60", OBJPROP_YDISTANCE, Shift_Up_Down + 35);
   gs_null_252 = DoubleToStr(ld_372, 0) + "";
   ObjectCreate("Sellers60", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Sellers60", gs_null_252, 9, "Tahoma Narrow", Sellers_Color);
   ObjectSet("Sellers60", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Sellers60", OBJPROP_XDISTANCE, Shift_Left_Right + 103);
   ObjectSet("Sellers60", OBJPROP_YDISTANCE, Shift_Up_Down + 55);
   gs_null_324 = DoubleToStr(ld_396, 0) + "%";
   ObjectCreate("Pwr60", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Pwr60", gs_null_324, 9, "Tahoma Narrow", g_color_160);
   ObjectSet("Pwr60", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Pwr60", OBJPROP_XDISTANCE, Shift_Left_Right + 103);
   ObjectSet("Pwr60", OBJPROP_YDISTANCE, Shift_Up_Down + 95);
   ObjectCreate("BVSM240", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("BVSM240", l_text_684, 75, "Tahoma Narrow", l_color_728);
   ObjectSet("BVSM240", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("BVSM240", OBJPROP_XDISTANCE, Shift_Left_Right + 60);
   ObjectSet("BVSM240", OBJPROP_YDISTANCE, Shift_Up_Down + 18);
   gs_null_260 = DoubleToStr(ld_428, 0) + "";
   ObjectCreate("Buyers240", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Buyers240", gs_null_260, 9, "Tahoma Narrow", Buyers_Color);
   ObjectSet("Buyers240", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Buyers240", OBJPROP_XDISTANCE, Shift_Left_Right + 63);
   ObjectSet("Buyers240", OBJPROP_YDISTANCE, Shift_Up_Down + 35);
   gs_null_268 = DoubleToStr(ld_436, 0) + "";
   ObjectCreate("Sellers240", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Sellers240", gs_null_268, 9, "Tahoma Narrow", Sellers_Color);
   ObjectSet("Sellers240", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Sellers240", OBJPROP_XDISTANCE, Shift_Left_Right + 63);
   ObjectSet("Sellers240", OBJPROP_YDISTANCE, Shift_Up_Down + 55);
   gs_null_332 = DoubleToStr(ld_460, 0) + "%";
   ObjectCreate("Pwr240", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Pwr240", gs_null_332, 9, "Tahoma Narrow", g_color_164);
   ObjectSet("Pwr240", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Pwr240", OBJPROP_XDISTANCE, Shift_Left_Right + 63);
   ObjectSet("Pwr240", OBJPROP_YDISTANCE, Shift_Up_Down + 95);
   ObjectCreate("BVSM1440", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("BVSM1440", l_text_692, 75, "Tahoma Narrow", l_color_732);
   ObjectSet("BVSM1440", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("BVSM1440", OBJPROP_XDISTANCE, Shift_Left_Right + 20);
   ObjectSet("BVSM1440", OBJPROP_YDISTANCE, Shift_Up_Down + 18);
   gs_null_276 = DoubleToStr(ld_492, 0) + "";
   ObjectCreate("Buyers1440", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Buyers1440", gs_null_276, 9, "Tahoma Narrow", Buyers_Color);
   ObjectSet("Buyers1440", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Buyers1440", OBJPROP_XDISTANCE, Shift_Left_Right + 20);
   ObjectSet("Buyers1440", OBJPROP_YDISTANCE, Shift_Up_Down + 35);
   gs_null_284 = DoubleToStr(ld_500, 0) + "";
   ObjectCreate("Sellers1440", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Sellers1440", gs_null_284, 9, "Tahoma Narrow", Sellers_Color);
   ObjectSet("Sellers1440", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Sellers1440", OBJPROP_XDISTANCE, Shift_Left_Right + 20);
   ObjectSet("Sellers1440", OBJPROP_YDISTANCE, Shift_Up_Down + 55);
   gs_null_340 = DoubleToStr(ld_524, 0) + "%";
   ObjectCreate("Pwr1440", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Pwr1440", gs_null_340, 9, "Tahoma Narrow", g_color_168);
   ObjectSet("Pwr1440", OBJPROP_CORNER, Top_Right_Corner);
   ObjectSet("Pwr1440", OBJPROP_XDISTANCE, Shift_Left_Right + 23);
   ObjectSet("Pwr1440", OBJPROP_YDISTANCE, Shift_Up_Down + 95);
   return (0);
}