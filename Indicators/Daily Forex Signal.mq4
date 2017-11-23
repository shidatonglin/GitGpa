#property copyright "Copyright © 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window

int init() {
   IndicatorShortName("Daily Forex Signal");
   return (0);
}

int deinit() {
   ObjectsDeleteAll(1, OBJ_LABEL);
   return (0);
}

int start() {
   int Li_0 = 2090;
   int Li_4 = 4;
   int Li_8 = 30;
   string Ls_12 = "admin@valasssp.com";
   string Ls_20 = "Daily Forex Signal";
   if (TimeYear(Time[0]) > Li_0) {
      Alert(Ls_20 + " has expired. ", "Please contact" + Ls_12);
      return (0);
   }
   if (TimeYear(Time[0]) == Li_0 && TimeMonth(Time[0]) > Li_4) {
      Alert(Ls_20 + " has expired. ", "Please contact" + Ls_12);
      return (0);
   }
   if (TimeYear(Time[0]) == Li_0 && TimeMonth(Time[0]) == Li_4 && TimeDay(Time[0]) > Li_8) {
      Alert(Ls_20 + " has expired. ", "Please contact" + Ls_12);
      return (0);
   }
   alerts("AUDCAD", "label-01", "arrow-01", "ttp-01", "tp-01", "act-01", 2, 38);
   alerts("AUDJPY", "label-02", "arrow-02", "ttp-02", "tp-02", "act-02", 2, 56);
   alerts("AUDNZD", "label-03", "arrow-03", "ttp-03", "tp-03", "act-03", 2, 74);
   alerts("AUDUSD", "label-04", "arrow-04", "ttp-04", "tp-04", "act-04", 2, 92);
   alerts("CADJPY", "label-05", "arrow-05", "ttp-05", "tp-05", "act-05", 2, 128);
   alerts("EURAUD", "label-06", "arrow-06", "ttp-06", "tp-06", "act-06", 225, 38);
   alerts("EURCAD", "label-07", "arrow-07", "ttp-07", "tp-07", "act-07", 225, 56);
   alerts("EURGBP", "label-08", "arrow-08", "ttp-08", "tp-08", "act-08", 225, 74);
   alerts("EURJPY", "label-09", "arrow-09", "ttp-09", "tp-09", "act-09", 225, 92);
   alerts("EURNZD", "label-10", "arrow-10", "ttp-10", "tp-10", "act-10", 225, 110);
   alerts("EURUSD", "label-11", "arrow-11", "ttp-11", "tp-11", "act-11", 225, 128);
   alerts("GBPAUD", "label-12", "arrow-12", "ttp-12", "tp-12", "act-12", 480, 38);
   alerts("GBPCAD", "label-13", "arrow-13", "ttp-13", "tp-13", "act-13", 480, 56);
   alerts("GBPJPY", "label-14", "arrow-14", "ttp-14", "tp-14", "act-14", 480, 74);
   alerts("GBPNZD", "label-15", "arrow-15", "ttp-15", "tp-15", "act-15", 480, 92);
   alerts("GBPUSD", "label-16", "arrow-16", "ttp-16", "tp-16", "act-16", 480, 110);
   alerts("NZDCAD", "label-17", "arrow-17", "ttp-17", "tp-17", "act-17", 480, 128);
   alerts("NZDJPY", "label-18", "arrow-18", "ttp-18", "tp-18", "act-18", 700, 38);
   alerts("NZDUSD", "label-19", "arrow-19", "ttp-19", "tp-19", "act-19", 700, 56);
   alerts("USDCAD", "label-20", "arrow-20", "ttp-20", "tp-20", "act-20", 700, 74);
   alerts("USDJPY", "label-21", "arrow-21", "ttp-21", "tp-21", "act-21", 700, 92);
   alerts("EURCHF", "label-22", "arrow-22", "ttp-22", "tp-22", "act-22", 700, 110);
   alerts("GBPCHF", "label-23", "arrow-23", "ttp-23", "tp-23", "act-23", 700, 128);
   alerts("USDCHF", "label-24", "arrow-24", "ttp-24", "tp-04", "act-24", 2, 110);
   return (0);
}

void alerts(string A_symbol_0, string A_name_8, string A_name_16, string A_name_24, string A_name_32, string A_name_40, int A_x_48, int A_y_52) {
   string Ls_unused_56;
   double ima_64;
   double ima_72;
   double ima_80;
   double ima_88;
   color color_96;
   string text_100;
   color color_108;
   string text_112;
   color color_120;
   string text_124;
   color color_132;
   string Ls_unused_136;
   string Ls_unused_144;
   string Ls_unused_152;
   string Ls_unused_160;
   int Li_168;
   string Ls_172 = "Daily Forex Signal";
   double point_180 = MarketInfo(A_symbol_0, MODE_POINT);
   int period_188 = 24;
   int period_192 = 72;
   double ima_196 = iMA(A_symbol_0, PERIOD_M30, period_188, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ima_204 = iMA(A_symbol_0, PERIOD_M30, period_192, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ima_212 = iMA(A_symbol_0, PERIOD_H1, period_188, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ima_220 = iMA(A_symbol_0, PERIOD_H1, period_192, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ima_228 = iMA(A_symbol_0, PERIOD_H4, period_188, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ima_236 = iMA(A_symbol_0, PERIOD_H4, period_192, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ima_244 = iMA(A_symbol_0, PERIOD_D1, period_188, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ima_252 = iMA(A_symbol_0, PERIOD_D1, period_192, 0, MODE_EMA, PRICE_CLOSE, 0);
   bool bool_260 = ima_196 > ima_204 && ima_212 > ima_220 && ima_228 > ima_236 && ima_244 > ima_252;
   bool bool_264 = ima_196 < ima_204 && ima_212 < ima_220 && ima_228 < ima_236 && ima_244 < ima_252;
   bool bool_268 = ima_196 > ima_204 && ima_212 > ima_220 && ima_228 > ima_236 && ima_244 < ima_252;
   bool bool_272 = ima_196 < ima_204 && ima_212 < ima_220 && ima_228 < ima_236 && ima_244 > ima_252;
   int count_276 = 0;
   int Li_280 = 49;
   int count_284 = 0;
   for (count_276 = 1; count_276 < Li_280; count_276++) {
      ima_64 = iMA(A_symbol_0, PERIOD_M30, 24, 0, MODE_EMA, PRICE_CLOSE, count_276 - 1);
      ima_72 = iMA(A_symbol_0, PERIOD_M30, 72, 0, MODE_EMA, PRICE_CLOSE, count_276 - 1);
      ima_80 = iMA(A_symbol_0, PERIOD_M30, 24, 0, MODE_EMA, PRICE_CLOSE, count_276 + 1);
      ima_88 = iMA(A_symbol_0, PERIOD_M30, 72, 0, MODE_EMA, PRICE_CLOSE, count_276 + 1);
      if ((ima_64 > ima_72 && ima_80 < ima_88) || (ima_64 < ima_72 && ima_80 > ima_88)) count_284++;
   }
   int Li_288 = count_284 < 1;
   double spread_292 = MarketInfo(A_symbol_0, MODE_SPREAD);
   string dbl2str_300 = DoubleToStr(spread_292, 0);
   double ask_308 = MarketInfo(A_symbol_0, MODE_ASK);
   if (ask_308 > 10.0) Li_168 = 2;
   else Li_168 = 4;
   double Ld_316 = iHigh(A_symbol_0, PERIOD_D1, 1);
   double Ld_324 = iLow(A_symbol_0, PERIOD_D1, 1);
   double iclose_332 = iClose(A_symbol_0, PERIOD_D1, 1);
   double Ld_340 = (Ld_316 + Ld_324 + iclose_332) / 3.0;
   Ld_340 = NormalizeDouble(Ld_340, Li_168);
   double Ld_348 = 2.0 * Ld_340 - Ld_316;
   Ld_348 = NormalizeDouble(Ld_348, Li_168);
   double Ld_356 = 2.0 * Ld_340 - Ld_324;
   Ld_356 = NormalizeDouble(Ld_356, Li_168);
   double irsi_364 = iRSI(A_symbol_0, PERIOD_M30, 14, PRICE_CLOSE, 0);
   double imacd_372 = iMACD(A_symbol_0, PERIOD_M30, 5, 13, 1, PRICE_CLOSE, MODE_MAIN, 0);
   double imacd_380 = iMACD(A_symbol_0, PERIOD_M30, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
   double istochastic_388 = iStochastic(A_symbol_0, PERIOD_M30, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);
   if (bool_260 && Li_288 && irsi_364 > 50.0 && imacd_372 > 0.0 && imacd_380 > 0.0) {
      text_100 = "Buy";
      color_96 = Lime;
      color_132 = Lime;
      text_112 = Ld_316;
      color_108 = Lime;
      text_124 = "TP";
      color_120 = Lime;
   } else {
      if (bool_264 && Li_288 && irsi_364 < 50.0 && imacd_372 < 0.0 && imacd_380 < 0.0) {
         text_100 = "Sell";
         color_96 = Red;
         color_132 = Red;
         text_112 = Ld_324;
         color_108 = Red;
         text_124 = "TP";
         color_120 = Red;
      } else {
         if (bool_268 && Li_288) {
            text_100 = "Buy";
            color_96 = Lime;
            color_132 = Lime;
            text_112 = Ld_356;
            color_108 = Lime;
            text_124 = "TP";
            color_120 = Lime;
         } else {
            if (bool_272 && Li_288) {
               text_100 = "Sell";
               color_96 = Red;
               color_132 = Red;
               text_112 = Ld_348;
               color_108 = Red;
               text_124 = "TP";
               color_120 = Red;
            } else {
               text_100 = "";
               color_96 = Black;
               color_132 = Gray;
               text_112 = "";
               color_108 = Black;
               text_124 = "";
               color_120 = Black;
            }
         }
      }
   }
   ObjectCreate(A_name_16, OBJ_LABEL, WindowFind(Ls_172), 0, 0);
   ObjectSetText(A_name_16, dbl2str_300, 7, "Arial Bold", Yellow);
   ObjectSet(A_name_16, OBJPROP_CORNER, 0);
   ObjectSet(A_name_16, OBJPROP_XDISTANCE, A_x_48);
   ObjectSet(A_name_16, OBJPROP_YDISTANCE, A_y_52 + 2);
   ObjectCreate(A_name_8, OBJ_LABEL, WindowFind(Ls_172), 0, 0);
   ObjectSetText(A_name_8, A_symbol_0, 9, "Arial Bold", color_132);
   ObjectSet(A_name_8, OBJPROP_CORNER, 0);
   ObjectSet(A_name_8, OBJPROP_XDISTANCE, A_x_48 + 13);
   ObjectSet(A_name_8, OBJPROP_YDISTANCE, A_y_52);
   ObjectCreate(A_name_40, OBJ_LABEL, WindowFind(Ls_172), 0, 0);
   ObjectSetText(A_name_40, text_100, 10, "Arial Bold", color_96);
   ObjectSet(A_name_40, OBJPROP_CORNER, 0);
   ObjectSet(A_name_40, OBJPROP_XDISTANCE, A_x_48 + 65);
   ObjectSet(A_name_40, OBJPROP_YDISTANCE, A_y_52 + 0);
   ObjectCreate(A_name_32, OBJ_LABEL, WindowFind(Ls_172), 0, 0);
   ObjectSetText(A_name_32, text_124, 10, "Arial Bold", color_120);
   ObjectSet(A_name_32, OBJPROP_CORNER, 0);
   ObjectSet(A_name_32, OBJPROP_XDISTANCE, A_x_48 + 98);
   ObjectSet(A_name_32, OBJPROP_YDISTANCE, A_y_52 + 0);
   ObjectCreate(A_name_24, OBJ_LABEL, WindowFind(Ls_172), 0, 0);
   ObjectSetText(A_name_24, text_112, 10, "Arial Bold", color_108);
   ObjectSet(A_name_24, OBJPROP_CORNER, 0);
   ObjectSet(A_name_24, OBJPROP_XDISTANCE, A_x_48 + 120);
   ObjectSet(A_name_24, OBJPROP_YDISTANCE, A_y_52 + 0);
}
