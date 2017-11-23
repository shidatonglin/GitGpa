
#property copyright "Copyright © 2011, ichi360.com"
#property link      "http://www.ichi360.com"

#property indicator_chart_window

extern int TenkanSen = 9;
extern int KijunSen = 26;
extern int SenkoSpan = 52;
extern double LotsForStrongSignal = 3.0;
extern double LotsForAverageSignal = 2.0;
extern double LotsForWeakSignal = 1.0;
extern bool ScreenAlertForWeakSignals = FALSE;
extern bool ScreenAlertForAverageSignals = FALSE;
extern bool ScreenAlertForStrongSignals = FALSE;
extern bool EmailAlertForWeakSignals = FALSE;
extern bool EmailAlertForAverageSignals = FALSE;
extern bool EmailAlertForStrongSignals = FALSE;
extern int TextOffSetFromRight = 8;
extern int TextOffSetFromTop = 2;
extern color TextColor = Black;
extern color BullishTextColor = MediumSeaGreen;
extern color BearishTextColor = Red;
extern color FlatTextColor = Gold;
extern color PriceTextColor = Black;
bool gi_164 = FALSE;
bool gi_168 = FALSE;

int init() {
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   string ls_36;
   double l_ichimoku_396;
   double l_ichimoku_404;
   string ls_412;
   double l_ichimoku_420;
   double l_ichimoku_428;
   double l_ichimoku_436;
   double l_ichimoku_444;
   string ls_452;
   double ld_460;
   double ld_468;
   double ld_476;
   string ls_unused_496;
   int li_unused_504;
   int li_unused_508;
   double ld_512;
   string ls_520;
   color l_color_544;
   string ls_548;
   string l_text_556;
   string l_text_564;
   color l_color_572;
   color l_color_576;
   int li_580;
   string ls_584;
   string ls_592;
   int l_digits_0 = MarketInfo(Symbol(), MODE_DIGITS);
   double l_point_4 = MarketInfo(Symbol(), MODE_POINT);
   double l_ticksize_12 = MarketInfo(Symbol(), MODE_TICKSIZE);
   double l_tickvalue_20 = MarketInfo(Symbol(), MODE_TICKVALUE);
   int li_unused_28 = MarketInfo(Symbol(), MODE_SPREAD);
   int li_unused_32 = MarketInfo(Symbol(), MODE_PROFITCALCMODE);
   switch (Period()) {
   case PERIOD_M1:
      ls_36 = "M1";
      break;
   case PERIOD_M5:
      ls_36 = "M5";
      break;
   case PERIOD_M15:
      ls_36 = "M15";
      break;
   case PERIOD_M30:
      ls_36 = "M30";
      break;
   case PERIOD_H1:
      ls_36 = "H1";
      break;
   case PERIOD_H4:
      ls_36 = "H4";
      break;
   case PERIOD_D1:
      ls_36 = "D1";
      break;
   case PERIOD_W1:
      ls_36 = "W1";
      break;
   case PERIOD_MN1:
      ls_36 = "MN";
      break;
   default:
      ls_36 = "240M";
   }
   double ld_48 = 0;
   double ld_56 = 0;
   double ld_64 = 0;
   double ld_72 = 0;
   double ld_80 = 0;
   double ld_88 = 0;
   double ld_96 = 0;
   double ld_104 = 0;
   double ld_112 = 0;
   double ld_120 = 0;
   double ld_128 = 0;
   double ld_136 = 0;
   double ld_144 = 0;
   double ld_152 = 0;
   double ld_160 = 0;
   double ld_168 = 0;
   double ld_176 = 0;
   double ld_184 = 0;
   double ld_192 = 0;
   double l_high_200 = High[iHighest(NULL, 0, MODE_HIGH, 64, 0)];
   double l_low_208 = Low[iLowest(NULL, 0, MODE_LOW, 64, 0)];
   ld_88 = (l_high_200 - l_low_208) / 8.0;
   ld_96 = l_low_208 - 2.0 * ld_88;
   ld_104 = ld_96 + ld_88;
   ld_112 = ld_104 + ld_88;
   ld_120 = ld_112 + ld_88;
   ld_128 = ld_120 + ld_88;
   ld_136 = ld_128 + ld_88;
   ld_144 = ld_136 + ld_88;
   ld_192 = ld_144 + ld_88;
   ld_184 = ld_192 + ld_88;
   ld_176 = ld_184 + ld_88;
   ld_168 = ld_176 + ld_88;
   ld_160 = ld_168 + ld_88;
   ld_152 = ld_160 + ld_88;
   if (iClose(NULL, 0, 1) <= ld_96) {
      ld_64 = ld_96;
      ld_56 = ld_64 + ld_88;
      ld_48 = ld_56 + ld_88;
      ld_72 = ld_64 - ld_88;
      ld_80 = ld_72 - ld_88;
   }
   if (iClose(NULL, 0, 1) >= ld_96 && iClose(NULL, 0, 1) < ld_104) {
      ld_64 = ld_104;
      ld_56 = ld_64 + ld_88;
      ld_48 = ld_56 + ld_88;
      ld_72 = ld_64 - ld_88;
      ld_80 = ld_72 - ld_88;
   }
   if (iClose(NULL, 0, 1) >= ld_104 && iClose(NULL, 0, 1) < ld_112) {
      ld_64 = ld_112;
      ld_56 = ld_64 + ld_88;
      ld_48 = ld_56 + ld_88;
      ld_72 = ld_64 - ld_88;
      ld_80 = ld_72 - ld_88;
   }
   if (iClose(NULL, 0, 1) >= ld_112 && iClose(NULL, 0, 1) < ld_120) {
      ld_64 = ld_120;
      ld_56 = ld_64 + ld_88;
      ld_48 = ld_56 + ld_88;
      ld_72 = ld_64 - ld_88;
      ld_80 = ld_72 - ld_88;
   }
   if (iClose(NULL, 0, 1) >= ld_120 && iClose(NULL, 0, 1) < ld_128) {
      ld_64 = ld_128;
      ld_56 = ld_64 + ld_88;
      ld_48 = ld_56 + ld_88;
      ld_72 = ld_64 - ld_88;
      ld_80 = ld_72 - ld_88;
   }
   if (iClose(NULL, 0, 1) >= ld_128 && iClose(NULL, 0, 1) < ld_136) {
      ld_64 = ld_136;
      ld_56 = ld_64 + ld_88;
      ld_48 = ld_56 + ld_88;
      ld_72 = ld_64 - ld_88;
      ld_80 = ld_72 - ld_88;
   }
   if (iClose(NULL, 0, 1) >= ld_136 && iClose(NULL, 0, 1) < ld_144) {
      ld_64 = ld_144;
      ld_56 = ld_64 + ld_88;
      ld_48 = ld_56 + ld_88;
      ld_72 = ld_64 - ld_88;
      ld_80 = ld_72 - ld_88;
   }
   if (iClose(NULL, 0, 1) >= ld_144 && iClose(NULL, 0, 1) < ld_192) {
      ld_64 = ld_192;
      ld_56 = ld_64 + ld_88;
      ld_48 = ld_56 + ld_88;
      ld_72 = ld_64 - ld_88;
      ld_80 = ld_72 - ld_88;
   }
   if (iClose(NULL, 0, 1) >= ld_192 && iClose(NULL, 0, 1) < ld_184) {
      ld_64 = ld_184;
      ld_56 = ld_64 + ld_88;
      ld_48 = ld_56 + ld_88;
      ld_72 = ld_64 - ld_88;
      ld_80 = ld_72 - ld_88;
   }
   if (iClose(NULL, 0, 1) >= ld_184 && iClose(NULL, 0, 1) < ld_176) {
      ld_64 = ld_176;
      ld_56 = ld_64 + ld_88;
      ld_48 = ld_56 + ld_88;
      ld_72 = ld_64 - ld_88;
      ld_80 = ld_72 - ld_88;
   }
   if (iClose(NULL, 0, 1) >= ld_176 && iClose(NULL, 0, 1) < ld_168) {
      ld_64 = ld_168;
      ld_56 = ld_64 + ld_88;
      ld_48 = ld_56 + ld_88;
      ld_72 = ld_64 - ld_88;
      ld_80 = ld_72 - ld_88;
   }
   if (iClose(NULL, 0, 1) >= ld_168 && iClose(NULL, 0, 1) < ld_160) {
      ld_64 = ld_160;
      ld_56 = ld_64 + ld_88;
      ld_48 = ld_56 + ld_88;
      ld_72 = ld_64 - ld_88;
      ld_80 = ld_72 - ld_88;
   }
   if (iClose(NULL, 0, 1) >= ld_160 && iClose(NULL, 0, 1) < ld_152) {
      ld_64 = ld_152;
      ld_56 = ld_64 + ld_88;
      ld_48 = ld_56 + ld_88;
      ld_72 = ld_64 - ld_88;
      ld_80 = ld_72 - ld_88;
   }
   if (iClose(NULL, 0, 1) >= ld_152) {
      ld_64 = ld_152;
      ld_56 = ld_64 + ld_88;
      ld_48 = ld_56 + ld_88;
      ld_72 = ld_64 - ld_88;
      ld_80 = ld_72 - ld_88;
   }
   double l_ichimoku_216 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_TENKANSEN, 0);
   double l_ichimoku_224 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_KIJUNSEN, 0);
   double l_ichimoku_232 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_TENKANSEN, 1);
   double l_ichimoku_240 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_KIJUNSEN, 1);
   double l_ichimoku_248 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANA, 0);
   double l_ichimoku_256 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANB, 0);
   double l_ichimoku_264 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANA, -26);
   double l_ichimoku_272 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANB, -26);
   double l_ichimoku_280 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_CHINKOUSPAN, KijunSen);
   string ls_unused_288 = "Flat";
   int li_unused_296 = 232;
   int li_unused_300 = FlatTextColor;
   if (l_ichimoku_248 > l_ichimoku_256) {
      ls_unused_288 = "Bullish";
      li_unused_296 = 233;
      li_unused_300 = BullishTextColor;
   }
   if (l_ichimoku_248 < l_ichimoku_256) {
      ls_unused_288 = "Bearish";
      li_unused_296 = 234;
      li_unused_300 = BearishTextColor;
   }
   string ls_unused_304 = "Flat";
   int li_unused_312 = FlatTextColor;
   int li_unused_316 = 232;
   if (l_ichimoku_264 > l_ichimoku_272) {
      ls_unused_304 = "Bullish";
      li_unused_316 = 233;
      li_unused_312 = BullishTextColor;
   }
   if (l_ichimoku_264 < l_ichimoku_272) {
      ls_unused_304 = "Bearish";
      li_unused_316 = 234;
      li_unused_312 = BearishTextColor;
   }
   string ls_unused_320 = "Flat";
   if (l_ichimoku_216 > l_ichimoku_224) ls_unused_320 = "Cross is Bullish";
   if (l_ichimoku_216 < l_ichimoku_224) ls_unused_320 = "Cross is Bearish";
   string ls_328 = "Flat";
   int li_336 = 232;
   color l_color_340 = FlatTextColor;
   if (Close[0] > l_ichimoku_248 && Close[0] > l_ichimoku_256) {
      ls_328 = "Bullish, Price is above Kumo";
      li_336 = 233;
      l_color_340 = BullishTextColor;
   }
   if (Close[0] < l_ichimoku_248 && Close[0] < l_ichimoku_256) {
      ls_328 = "Bearish, Price is below Kumo";
      li_336 = 234;
      l_color_340 = BearishTextColor;
   }
   if (Close[0] > l_ichimoku_248 && Close[0] < l_ichimoku_256) {
      ls_328 = "Flat, Price is inside Kumo";
      li_336 = 232;
      l_color_340 = FlatTextColor;
   }
   if (Close[0] < l_ichimoku_248 && Close[0] > l_ichimoku_256) {
      ls_328 = "Flat, Price is inside Kumo";
      li_336 = 232;
      l_color_340 = FlatTextColor;
   }
   string ls_unused_344 = "Flat";
   int li_352 = 232;
   color l_color_356 = FlatTextColor;
   if (l_ichimoku_280 > Close[KijunSen]) {
      ls_unused_344 = "Bullish";
      li_352 = 233;
      l_color_356 = BullishTextColor;
   }
   if (l_ichimoku_280 < Close[KijunSen]) {
      ls_unused_344 = "Bearish";
      li_352 = 234;
      l_color_356 = BearishTextColor;
   }
   string ls_unused_360 = "Flat";
   int li_unused_368 = 232;
   int li_unused_372 = FlatTextColor;
   if (l_ichimoku_224 > l_ichimoku_248 && l_ichimoku_224 > l_ichimoku_256) {
      ls_unused_360 = "Bullish";
      li_unused_368 = 233;
      li_unused_372 = BullishTextColor;
   }
   if (l_ichimoku_224 < l_ichimoku_248 && l_ichimoku_224 < l_ichimoku_256) {
      ls_unused_360 = "Bearish";
      li_unused_368 = 234;
      li_unused_372 = BearishTextColor;
   }
   string ls_unused_376 = "Flat";
   int li_384 = 232;
   color l_color_388 = FlatTextColor;
   if (Close[0] > l_ichimoku_224) {
      ls_unused_376 = "Bullish";
      li_384 = 233;
      l_color_388 = BullishTextColor;
   }
   if (Close[0] < l_ichimoku_224) {
      ls_unused_376 = "Bearish";
      li_384 = 234;
      l_color_388 = BearishTextColor;
   }
   int li_392 = 0;
   int li_528 = 232;
   color l_color_532 = FlatTextColor;
   color l_color_536 = FlatTextColor;
   if (l_ichimoku_216 >= l_ichimoku_224) {
      l_color_536 = BullishTextColor;
      if (li_392 >= 0) {
         l_ichimoku_396 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_TENKANSEN, li_392);
         l_ichimoku_404 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_KIJUNSEN, li_392);
         if (l_ichimoku_396 >= l_ichimoku_404) {
            li_392++;
/*empty:7336:(@)*/
         }
         ld_512 = (Open[li_392] + Close[li_392] + Low[li_392] + High[li_392]) / 4.0;
         l_ichimoku_420 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_TENKANSEN, li_392);
         l_ichimoku_428 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_KIJUNSEN, li_392);
         l_ichimoku_436 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANA, li_392);
         l_ichimoku_444 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANB, li_392);
         if (l_ichimoku_420 > l_ichimoku_436 && l_ichimoku_428 > l_ichimoku_436 && l_ichimoku_420 > l_ichimoku_444 && l_ichimoku_428 > l_ichimoku_444) {
            ls_412 = "Strong Bullish Crossover";
            li_unused_504 = 3;
            li_unused_508 = 233;
            ls_452 = "Long " + DoubleToStr(LotsForStrongSignal, 2) + " Lots";
            li_528 = 233;
            l_color_532 = BullishTextColor;
         }
         if (l_ichimoku_420 > l_ichimoku_436 && l_ichimoku_428 < l_ichimoku_444) {
            ls_412 = "Average Bullish Crossover";
            li_unused_504 = 2;
            li_unused_508 = 236;
            ls_452 = "Long " + DoubleToStr(LotsForAverageSignal, 2) + " Lots";
            li_528 = 236;
            l_color_532 = BullishTextColor;
         }
         if (l_ichimoku_420 < l_ichimoku_436 && l_ichimoku_428 > l_ichimoku_444) {
            ls_412 = "Average Bullish Crossover";
            li_unused_504 = 2;
            li_unused_508 = 236;
            ls_452 = "Long " + DoubleToStr(LotsForAverageSignal, 2) + " Lots";
            li_528 = 236;
            l_color_532 = BullishTextColor;
         }
         if (l_ichimoku_420 < l_ichimoku_436 && l_ichimoku_428 < l_ichimoku_444) {
            ls_412 = "Weak Bullish Crossover";
            li_unused_504 = 1;
            li_unused_508 = 236;
            ls_452 = "Long " + DoubleToStr(LotsForWeakSignal, 2) + " Lots";
            li_528 = 236;
            l_color_532 = FlatTextColor;
         }
         ld_460 = Close[0] - Open[li_392];
         ld_476 = 10000.0 * ld_460;
         if (StringFind(Symbol(), "JPY", 0) >= 0) ld_476 = 100.0 * ld_460;
         ld_468 = ld_476 * l_tickvalue_20;
      }
   }
   if (l_ichimoku_216 <= l_ichimoku_224) {
      l_color_536 = BearishTextColor;
      if (li_392 >= 0) {
         l_ichimoku_396 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_TENKANSEN, li_392);
         l_ichimoku_404 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_KIJUNSEN, li_392);
         if (l_ichimoku_396 <= l_ichimoku_404) {
            li_392++;
/*empty:9400:(@)*/
         }
         ld_512 = (Open[li_392] + Close[li_392] + Low[li_392] + High[li_392]) / 4.0;
         l_ichimoku_420 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_TENKANSEN, li_392);
         l_ichimoku_428 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_KIJUNSEN, li_392);
         l_ichimoku_436 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANA, li_392);
         l_ichimoku_444 = iIchimoku(NULL, 0, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANB, li_392);
         if (l_ichimoku_420 < l_ichimoku_436 && l_ichimoku_428 < l_ichimoku_444) {
            ls_412 = "Strong Bearish Crossover";
            li_unused_504 = 3;
            li_unused_508 = 234;
            ls_452 = "Short " + DoubleToStr(LotsForStrongSignal, 2) + " Lots";
            li_528 = 234;
            l_color_532 = BearishTextColor;
         }
         if (l_ichimoku_420 > l_ichimoku_436 && l_ichimoku_428 < l_ichimoku_444) {
            ls_412 = "Average Bearish Crossover";
            li_unused_504 = 2;
            li_unused_508 = 238;
            ls_452 = "Short " + DoubleToStr(LotsForAverageSignal, 2) + " Lots";
            li_528 = 238;
            l_color_532 = BearishTextColor;
         }
         if (l_ichimoku_420 < l_ichimoku_436 && l_ichimoku_428 > l_ichimoku_444) {
            ls_412 = "Average Bearish Crossover";
            li_unused_504 = 2;
            li_unused_508 = 238;
            ls_452 = "Short " + DoubleToStr(LotsForAverageSignal, 2) + " Lots";
            li_528 = 238;
            l_color_532 = BearishTextColor;
         }
         if (l_ichimoku_420 > l_ichimoku_436 && l_ichimoku_428 > l_ichimoku_444) {
            ls_412 = "Weak Bearish Crossover";
            li_unused_504 = 1;
            li_unused_508 = 238;
            ls_452 = "Short " + DoubleToStr(LotsForWeakSignal, 2) + " Lots";
            li_528 = 238;
            l_color_532 = FlatTextColor;
         }
         ld_460 = Open[li_392 - 1] - Close[0];
         ld_476 = 10000.0 * ld_460;
         if (StringFind(Symbol(), "JPY", 0) >= 0) ld_476 = 100.0 * ld_460;
         ld_468 = ld_476 * l_tickvalue_20;
      }
   }
   int li_540 = 0;
   if (StringFind(ls_328, "Bullish", 0) >= 0) {
      ls_unused_496 = "Long";
      l_color_544 = BullishTextColor;
      ls_548 = "Bullish";
      if (ls_412 == "Strong Bullish Crossover") li_540 += 40;
      if (ls_412 == "Average Bullish Crossover") li_540 += 20;
      if (ls_412 == "Weak Bullish Crossover") li_540 += 0;
      if (Close[0] > l_ichimoku_248 && Close[0] > l_ichimoku_256) li_540 += 20;
      if ((Close[0] > l_ichimoku_248 && Close[0] < l_ichimoku_256) || (Close[0] < l_ichimoku_248 && Close[0] > l_ichimoku_256)) li_540 += 10;
      if (Close[0] < l_ichimoku_248 && Close[0] < l_ichimoku_256) li_540 += 0;
      if (Close[0] > l_ichimoku_224) li_540 += 10;
      if (l_ichimoku_280 > Close[KijunSen]) li_540 += 20;
      if (l_ichimoku_280 > l_ichimoku_224) li_540 += 5;
      if (l_ichimoku_280 > l_ichimoku_216) li_540 += 5;
      if (ls_548 == "Flat" || li_540 == 0) l_color_544 = FlatTextColor;
   }
   if (StringFind(ls_328, "Bearish", 0) >= 0) {
      ls_unused_496 = "Short";
      l_color_544 = BearishTextColor;
      ls_548 = "Bearish";
      if (ls_412 == "Strong Bearish Crossover") li_540 += 40;
      if (ls_412 == "Average Bearish Crossover") li_540 += 20;
      if (ls_412 == "Weak Bearish Crossover") li_540 += 0;
      if (Close[0] < l_ichimoku_248 && Close[0] < l_ichimoku_256) li_540 += 20;
      if ((Close[0] > l_ichimoku_248 && Close[0] < l_ichimoku_256) || (Close[0] < l_ichimoku_248 && Close[0] > l_ichimoku_256)) li_540 += 10;
      if (Close[0] > l_ichimoku_248 && Close[0] > l_ichimoku_256) li_540 += 0;
      if (Close[0] < l_ichimoku_224) li_540 += 10;
      if (l_ichimoku_280 < Close[KijunSen]) li_540 += 20;
      if (l_ichimoku_280 < l_ichimoku_224) li_540 += 5;
      if (l_ichimoku_280 < l_ichimoku_216) li_540 += 5;
      if (ls_548 == "Flat" || li_540 == 0) l_color_544 = FlatTextColor;
   }
   if (StringFind(ls_328, "Flat", 0) >= 0) {
      ls_unused_496 = "Wait";
      l_color_544 = FlatTextColor;
      ls_548 = "Flat";
      if (ls_412 == "Strong Bearish Crossover") li_540 = 0;
      if (ls_412 == "Average Bearish Crossover") li_540 = 0;
      if (ls_412 == "Weak Bearish Crossover") li_540 = 0;
      if (Close[0] < l_ichimoku_248 && Close[0] < l_ichimoku_256) li_540 = 0;
      if ((Close[0] > l_ichimoku_248 && Close[0] < l_ichimoku_256) || (Close[0] < l_ichimoku_248 && Close[0] > l_ichimoku_256)) li_540 = 0;
      if (Close[0] > l_ichimoku_248 && Close[0] > l_ichimoku_256) li_540 = 0;
      if (Close[0] < l_ichimoku_224) li_540 = 0;
      if (l_ichimoku_280 < Close[KijunSen]) li_540 = 0;
      if (l_ichimoku_280 < l_ichimoku_224) li_540 = 0;
      if (l_ichimoku_280 < l_ichimoku_216) li_540 = 0;
      if (ls_548 == "Flat" || li_540 == 0) l_color_544 = FlatTextColor;
   }
   if (li_540 == 0) {
      l_text_556 = "::";
      l_text_564 = "::::::::";
      li_580 = 80;
      if (ls_548 == "Bullish") {
         l_color_572 = FlatTextColor;
         l_color_576 = FlatTextColor;
      }
      if (ls_548 == "Bearish") {
         l_color_572 = FlatTextColor;
         l_color_576 = FlatTextColor;
      }
      if (ls_548 == "Flat") {
         l_color_572 = FlatTextColor;
         l_color_576 = FlatTextColor;
      }
   } else {
      if (li_540 > 0 && li_540 < 10) {
         l_text_556 = ":";
         l_text_564 = ":::::::::";
         li_580 = 80;
         if (ls_548 == "Bullish") {
            l_color_572 = BullishTextColor;
            l_color_576 = BearishTextColor;
         }
         if (ls_548 == "Bearish") {
            l_color_572 = BearishTextColor;
            l_color_576 = BullishTextColor;
         }
         if (ls_548 == "Flat") {
            l_color_572 = FlatTextColor;
            l_color_576 = FlatTextColor;
         }
      } else {
         if (li_540 >= 10 && li_540 < 20) {
            l_text_556 = "::";
            l_text_564 = "::::::::";
            li_580 = 80;
            if (ls_548 == "Bullish") {
               l_color_572 = BullishTextColor;
               l_color_576 = BearishTextColor;
            }
            if (ls_548 == "Bearish") {
               l_color_572 = BearishTextColor;
               l_color_576 = BullishTextColor;
            }
            if (ls_548 == "Flat") {
               l_color_572 = FlatTextColor;
               l_color_576 = FlatTextColor;
            }
         } else {
            if (li_540 >= 20 && li_540 < 30) {
               l_text_556 = "::";
               l_text_564 = "::::::::";
               li_580 = 80;
               if (ls_548 == "Bullish") {
                  l_color_572 = BullishTextColor;
                  l_color_576 = BearishTextColor;
               }
               if (ls_548 == "Bearish") {
                  l_color_572 = BearishTextColor;
                  l_color_576 = BullishTextColor;
               }
               if (ls_548 == "Flat") {
                  l_color_572 = FlatTextColor;
                  l_color_576 = FlatTextColor;
               }
            } else {
               if (li_540 >= 30 && li_540 < 40) {
                  l_text_556 = ":::";
                  l_text_564 = ":::::::";
                  li_580 = 70;
                  if (ls_548 == "Bullish") {
                     l_color_572 = BullishTextColor;
                     l_color_576 = BearishTextColor;
                  }
                  if (ls_548 == "Bearish") {
                     l_color_572 = BearishTextColor;
                     l_color_576 = BullishTextColor;
                  }
                  if (ls_548 == "Flat") {
                     l_color_572 = FlatTextColor;
                     l_color_576 = FlatTextColor;
                  }
               } else {
                  if (li_540 >= 40 && li_540 < 50) {
                     l_text_556 = "::::";
                     l_text_564 = "::::::";
                     li_580 = 60;
                     if (ls_548 == "Bullish") {
                        l_color_572 = BullishTextColor;
                        l_color_576 = BearishTextColor;
                     }
                     if (ls_548 == "Bearish") {
                        l_color_572 = BearishTextColor;
                        l_color_576 = BullishTextColor;
                     }
                     if (ls_548 == "Flat") {
                        l_color_572 = FlatTextColor;
                        l_color_576 = FlatTextColor;
                     }
                  } else {
                     if (li_540 >= 50 && li_540 < 60) {
                        l_text_556 = ":::::";
                        l_text_564 = ":::::";
                        li_580 = 50;
                        if (ls_548 == "Bullish") {
                           l_color_572 = BullishTextColor;
                           l_color_576 = BearishTextColor;
                        }
                        if (ls_548 == "Bearish") {
                           l_color_572 = BearishTextColor;
                           l_color_576 = BullishTextColor;
                        }
                        if (ls_548 == "Flat") {
                           l_color_572 = FlatTextColor;
                           l_color_576 = FlatTextColor;
                        }
                     } else {
                        if (li_540 >= 60 && li_540 < 70) {
                           l_text_556 = "::::::";
                           l_text_564 = "::::";
                           li_580 = 40;
                           if (ls_548 == "Bullish") {
                              l_color_572 = BullishTextColor;
                              l_color_576 = BearishTextColor;
                           }
                           if (ls_548 == "Bearish") {
                              l_color_572 = BearishTextColor;
                              l_color_576 = BullishTextColor;
                           }
                           if (ls_548 == "Flat") {
                              l_color_572 = FlatTextColor;
                              l_color_576 = FlatTextColor;
                           }
                        } else {
                           if (li_540 >= 70 && li_540 < 80) {
                              l_text_556 = ":::::::";
                              l_text_564 = ":::";
                              li_580 = 30;
                              if (ls_548 == "Bullish") {
                                 l_color_572 = BullishTextColor;
                                 l_color_576 = BearishTextColor;
                              }
                              if (ls_548 == "Bearish") {
                                 l_color_572 = BearishTextColor;
                                 l_color_576 = BullishTextColor;
                              }
                              if (ls_548 == "Flat") {
                                 l_color_572 = FlatTextColor;
                                 l_color_576 = FlatTextColor;
                              }
                           } else {
                              if (li_540 >= 80 && li_540 < 90) {
                                 l_text_556 = "::::::::";
                                 l_text_564 = "::";
                                 li_580 = 20;
                                 if (ls_548 == "Bullish") {
                                    l_color_572 = BullishTextColor;
                                    l_color_576 = BearishTextColor;
                                 }
                                 if (ls_548 == "Bearish") {
                                    l_color_572 = BearishTextColor;
                                    l_color_576 = BullishTextColor;
                                 }
                                 if (ls_548 == "Flat") {
                                    l_color_572 = FlatTextColor;
                                    l_color_576 = FlatTextColor;
                                 }
                              } else {
                                 if (li_540 >= 90 && li_540 < 100) {
                                    l_text_556 = ":::::::::";
                                    l_text_564 = ":";
                                    li_580 = 10;
                                    if (ls_548 == "Bullish") {
                                       l_color_572 = BullishTextColor;
                                       l_color_576 = BearishTextColor;
                                    }
                                    if (ls_548 == "Bearish") {
                                       l_color_572 = BearishTextColor;
                                       l_color_576 = BullishTextColor;
                                    }
                                    if (ls_548 == "Flat") {
                                       l_color_572 = FlatTextColor;
                                       l_color_576 = FlatTextColor;
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
   if (li_540 == 100) {
      l_text_556 = "::::::::";
      l_text_564 = "::";
      li_580 = 20;
      if (ls_548 == "Bullish") {
         l_color_572 = BullishTextColor;
         l_color_576 = BullishTextColor;
      }
      if (ls_548 == "Bearish") {
         l_color_572 = BearishTextColor;
         l_color_576 = BearishTextColor;
      }
      if (ls_548 == "Flat") {
         l_color_572 = FlatTextColor;
         l_color_576 = FlatTextColor;
      }
   }
   ObjectDelete("ichi360_Trade_HLine");
   ObjectDelete("ichi360_Trade_VLine");
   ObjectCreate("ichi360_Trade_HLine", OBJ_HLINE, 0, 0, Open[li_392 - 1]);
   ObjectSet("ichi360_Trade_HLine", OBJPROP_COLOR, l_color_536);
   ObjectSet("ichi360_Trade_HLine", OBJPROP_STYLE, STYLE_DASH);
   ObjectCreate("ichi360_Trade_VLine", OBJ_VLINE, 0, Time[li_392 - 1], Open[li_392 - 1]);
   ObjectSet("ichi360_Trade_VLine", OBJPROP_COLOR, l_color_536);
   ObjectSet("ichi360_Trade_VLine", OBJPROP_STYLE, STYLE_DASH);
   ObjectDelete("BestEntry");
   ObjectDelete("TradeSuggestion");
   ObjectDelete("txt1");
   ObjectDelete("txt2");
   ObjectDelete("txt3");
   ObjectDelete("txt3a");
   ObjectDelete("txt3b");
   ObjectDelete("txt4");
   ObjectDelete("txt5");
   ObjectDelete("txt6");
   ObjectDelete("txt7");
   ObjectDelete("txt8");
   ObjectDelete("txt9");
   ObjectDelete("txt10");
   ObjectDelete("txt11");
   ObjectDelete("txt12");
   ObjectDelete("txt13");
   ObjectDelete("txt14");
   ObjectDelete("txt15");
   ObjectDelete("txt16");
   ObjectDelete("txt17");
   ObjectDelete("txt18");
   ObjectDelete("txt19");
   ObjectDelete("txt20");
   ObjectDelete("txt21");
   ObjectDelete("txt22");
   ObjectDelete("txt23");
   ObjectDelete("txt24");
   ObjectDelete("txt30");
   ObjectDelete("txt31");
   ObjectDelete("txt32");
   ObjectDelete("txt33");
   ObjectDelete("txt34");
   ObjectDelete("txt35");
   ObjectDelete("txt36");
   ObjectDelete("txt37");
   ObjectDelete("txt38");
   ObjectDelete("txt39");
   ObjectDelete("txt40");
   ObjectCreate("txt1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1", OBJPROP_CORNER, 1);
   ObjectSet("txt1", OBJPROP_YDISTANCE, TextOffSetFromTop + 2);
   ObjectSet("txt1", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt2", OBJPROP_CORNER, 1);
   ObjectSet("txt2", OBJPROP_YDISTANCE, TextOffSetFromTop + 14);
   ObjectSet("txt2", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt3a", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt3a", OBJPROP_CORNER, 1);
   ObjectSet("txt3a", OBJPROP_YDISTANCE, TextOffSetFromTop + 16);
   ObjectSet("txt3a", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt3b", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt3b", OBJPROP_CORNER, 1);
   ObjectSet("txt3b", OBJPROP_YDISTANCE, TextOffSetFromTop + 16);
   ObjectSet("txt3b", OBJPROP_XDISTANCE, TextOffSetFromRight + li_580);
   ObjectCreate("txt4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt4", OBJPROP_CORNER, 1);
   ObjectSet("txt4", OBJPROP_YDISTANCE, TextOffSetFromTop + 50);
   ObjectSet("txt4", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt5", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt5", OBJPROP_CORNER, 1);
   ObjectSet("txt5", OBJPROP_YDISTANCE, TextOffSetFromTop + 60);
   ObjectSet("txt5", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt6", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt6", OBJPROP_CORNER, 1);
   ObjectSet("txt6", OBJPROP_YDISTANCE, TextOffSetFromTop + 76);
   ObjectSet("txt6", OBJPROP_XDISTANCE, TextOffSetFromRight + 94);
   ObjectCreate("txt7", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt7", OBJPROP_CORNER, 1);
   ObjectSet("txt7", OBJPROP_YDISTANCE, TextOffSetFromTop + 76);
   ObjectSet("txt7", OBJPROP_XDISTANCE, TextOffSetFromRight + 68);
   ObjectCreate("txt8", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt8", OBJPROP_CORNER, 1);
   ObjectSet("txt8", OBJPROP_YDISTANCE, TextOffSetFromTop + 76);
   ObjectSet("txt8", OBJPROP_XDISTANCE, TextOffSetFromRight + 34);
   ObjectCreate("txt9", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt9", OBJPROP_CORNER, 1);
   ObjectSet("txt9", OBJPROP_YDISTANCE, TextOffSetFromTop + 76);
   ObjectSet("txt9", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt10", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt10", OBJPROP_CORNER, 1);
   ObjectSet("txt10", OBJPROP_YDISTANCE, TextOffSetFromTop + 86);
   ObjectSet("txt10", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt11", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt11", OBJPROP_CORNER, 1);
   ObjectSet("txt11", OBJPROP_YDISTANCE, TextOffSetFromTop + 96);
   ObjectSet("txt11", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt12", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt12", OBJPROP_CORNER, 1);
   ObjectSet("txt12", OBJPROP_YDISTANCE, TextOffSetFromTop + 108);
   ObjectSet("txt12", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt13", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt13", OBJPROP_CORNER, 1);
   ObjectSet("txt13", OBJPROP_YDISTANCE, TextOffSetFromTop + 120);
   ObjectSet("txt13", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt14", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt14", OBJPROP_CORNER, 1);
   ObjectSet("txt14", OBJPROP_YDISTANCE, TextOffSetFromTop + 132);
   ObjectSet("txt14", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt15", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt15", OBJPROP_CORNER, 1);
   ObjectSet("txt15", OBJPROP_YDISTANCE, TextOffSetFromTop + 142);
   ObjectSet("txt15", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt16", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt16", OBJPROP_CORNER, 1);
   ObjectSet("txt16", OBJPROP_YDISTANCE, TextOffSetFromTop + 150);
   ObjectSet("txt16", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt17", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt17", OBJPROP_CORNER, 1);
   ObjectSet("txt17", OBJPROP_YDISTANCE, TextOffSetFromTop + 160);
   ObjectSet("txt17", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt18", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt18", OBJPROP_CORNER, 1);
   ObjectSet("txt18", OBJPROP_YDISTANCE, TextOffSetFromTop + 172);
   ObjectSet("txt18", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt19", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt19", OBJPROP_CORNER, 1);
   ObjectSet("txt19", OBJPROP_YDISTANCE, TextOffSetFromTop + 184);
   ObjectSet("txt19", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt20", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt20", OBJPROP_CORNER, 1);
   ObjectSet("txt20", OBJPROP_YDISTANCE, TextOffSetFromTop + 196);
   ObjectSet("txt20", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt21", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt21", OBJPROP_CORNER, 1);
   ObjectSet("txt21", OBJPROP_YDISTANCE, TextOffSetFromTop + 208);
   ObjectSet("txt21", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt22", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt22", OBJPROP_CORNER, 1);
   ObjectSet("txt22", OBJPROP_YDISTANCE, TextOffSetFromTop + 220);
   ObjectSet("txt22", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt23", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt23", OBJPROP_CORNER, 1);
   ObjectSet("txt23", OBJPROP_YDISTANCE, TextOffSetFromTop + 232);
   ObjectSet("txt23", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt24", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt24", OBJPROP_CORNER, 1);
   ObjectSet("txt24", OBJPROP_YDISTANCE, TextOffSetFromTop + 240);
   ObjectSet("txt24", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt30", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt30", OBJPROP_CORNER, 1);
   ObjectSet("txt30", OBJPROP_YDISTANCE, TextOffSetFromTop + 252);
   ObjectSet("txt30", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt31", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt31", OBJPROP_CORNER, 1);
   ObjectSet("txt31", OBJPROP_YDISTANCE, TextOffSetFromTop + 264);
   ObjectSet("txt31", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt32", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt32", OBJPROP_CORNER, 1);
   ObjectSet("txt32", OBJPROP_YDISTANCE, TextOffSetFromTop + 276);
   ObjectSet("txt32", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectCreate("txt33", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt33", OBJPROP_CORNER, 1);
   ObjectSet("txt33", OBJPROP_YDISTANCE, TextOffSetFromTop + 288);
   ObjectSet("txt33", OBJPROP_XDISTANCE, TextOffSetFromRight);
   ObjectSetText("txt1", "---------------------------------------------------------------------------------------------", 8, "Arial", TextColor);
   ObjectSetText("txt2", li_540 + "% " + ls_548 + " (" + ls_36 + "): " + Symbol(), 9, "Arial Black", l_color_544);
   ObjectSetText("txt3a", l_text_564, 22, "Arial Black", l_color_576);
   ObjectSetText("txt3b", l_text_556, 22, "Arial Black", l_color_572);
   ObjectSetText("txt4", "-----------------------------------------------------------------------------------", 8, "Arial", TextColor);
   ObjectSetText("txt5", "PA   P/KS   TS/KS    CS", 8, "Tahoma", TextColor);
   ObjectSetText("txt6", CharToStr(li_336), 11, "Wingdings", l_color_340);
   ObjectSetText("txt7", CharToStr(li_384), 11, "Wingdings", l_color_388);
   ObjectSetText("txt8", CharToStr(li_528), 11, "Wingdings", l_color_532);
   ObjectSetText("txt9", CharToStr(li_352), 11, "Wingdings", l_color_356);
   ObjectSetText("txt10", "-----------------------------------------------------------------------------------", 8, "Arial", TextColor);
   ObjectSetText("txt11", ls_452 + " @ " + DoubleToStr(Open[li_392 - 1], l_digits_0), 8, "Tahoma", TextColor);
   ObjectSetText("txt12", "Pips Earned: " + DoubleToStr(ld_476, 0), 8, "Tahoma", TextColor);
   ObjectSetText("txt13", "Tick Value: " + DoubleToStr(l_tickvalue_20, 0), 8, "Tahoma", TextColor);
   ObjectSetText("txt14", "P/L: " + DoubleToStr(ld_468, 0), 8, "Tahoma", TextColor);
   ObjectSetText("txt15", "-----------------------------------------------------------------------------------", 8, "Arial", TextColor);
   ObjectSetText("txt16", "Price: " + DoubleToStr(Close[0], l_digits_0), 10, "Arial Black", PriceTextColor);
   ObjectSetText("txt17", "-----------------------------------------------------------------------------------", 8, "Arial", TextColor);
   ObjectSetText("txt18", "Next Levels of Possible S/R", 8, "Tahoma", TextColor);
   ObjectSetText("txt19", "Level 1: " + DoubleToStr(ld_48, l_digits_0), 8, "Tahoma", TextColor);
   ObjectSetText("txt20", "Level 2: " + DoubleToStr(ld_56, l_digits_0), 8, "Tahoma", TextColor);
   ObjectSetText("txt21", "Level 3: " + DoubleToStr(ld_64, l_digits_0), 8, "Tahoma", TextColor);
   ObjectSetText("txt22", "Level 4: " + DoubleToStr(ld_72, l_digits_0), 8, "Tahoma", TextColor);
   ObjectSetText("txt23", "Level 5: " + DoubleToStr(ld_80, l_digits_0), 8, "Tahoma", TextColor);
   ObjectSetText("txt24", "--------------------------------------------------------------------------------", 8, "Arial", TextColor);
   ObjectSetText("txt30", "ichi360 v8 - Ichimoku Trading System", 7, "Tahoma", TextColor);
   ObjectSetText("txt31", "by www.ichi360.com", 7, "Tahoma", TextColor);
   ObjectSetText("txt32", "Build 8.100", 7, "Tahoma", TextColor);
   ObjectSetText("txt33", "--------------------------------------------------------------------------------", 8, "Arial", TextColor);
   if (l_ichimoku_216 > l_ichimoku_224 && l_ichimoku_232 <= l_ichimoku_240 && gi_164 == FALSE) {
      ls_520 = Symbol() + ": " + ls_36 + " - " + ls_412 + ", " + ls_452 + " @ " + DoubleToStr(Close[0], l_digits_0);
      ls_592 = "ichi360V6 Trade Signal - " + Symbol() + ": " + ls_36 + " - " + ls_412;
      ls_584 = "--------------------------------------------------------------" 
         + "\n" 
         + "Symbol: " + Symbol() 
         + "\n" 
         + "Alert Generated On: " + TimeToStr(TimeLocal()) 
         + "\n" 
         + "TimeFrame: " + ls_36 
         + "\n" 
         + "Crossover: " + ls_412 
         + "\n" 
         + "Suggestion: " + ls_452 + " @ " + DoubleToStr(Close[0], l_digits_0) 
         + "\n" 
         + "--------------------------------------------------------------" 
      + "\n";
      if (ScreenAlertForWeakSignals == TRUE && StringFind(ls_412, "Weak", 0) >= 0) {
         Alert(ls_520);
         PlaySound("Alert.wav");
      }
      if (ScreenAlertForAverageSignals == TRUE && StringFind(ls_412, "Average", 0) >= 0) {
         Alert(ls_520);
         PlaySound("Alert.wav");
      }
      if (ScreenAlertForStrongSignals == TRUE && StringFind(ls_412, "Strong", 0) >= 0) {
         Alert(ls_520);
         PlaySound("Alert.wav");
      }
      if (EmailAlertForWeakSignals == TRUE && StringFind(ls_412, "Weak", 0) >= 0) SendMail(ls_592, ls_584);
      if (EmailAlertForAverageSignals == TRUE && StringFind(ls_412, "Average", 0) >= 0) SendMail(ls_592, ls_584);
      if (EmailAlertForStrongSignals == TRUE && StringFind(ls_412, "Strong", 0) >= 0) SendMail(ls_592, ls_584);
      gi_164 = TRUE;
      gi_168 = FALSE;
   }
   if (l_ichimoku_216 < l_ichimoku_224 && l_ichimoku_240 <= l_ichimoku_232 && gi_168 == FALSE) {
      ls_520 = Symbol() + ": " + ls_36 + " - " + ls_412 + ", " + ls_452 + " @ " + DoubleToStr(Close[0], l_digits_0);
      ls_592 = "ichi360V6 Trade Signal - " + Symbol() + ": " + ls_36 + " - " + ls_412;
      ls_584 = "--------------------------------------------------------------" 
         + "\n" 
         + "Symbol: " + Symbol() 
         + "\n" 
         + "Alert Generated On: " + TimeToStr(TimeLocal()) 
         + "\n" 
         + "TimeFrame: " + ls_36 
         + "\n" 
         + "Crossover: " + ls_412 
         + "\n" 
         + "Suggestion: " + ls_452 + " @ " + DoubleToStr(Close[0], l_digits_0) 
         + "\n" 
         + "--------------------------------------------------------------" 
      + "\n";
      if (ScreenAlertForWeakSignals == TRUE && StringFind(ls_412, "Weak", 0) >= 0) {
         Alert(ls_520);
         PlaySound("Alert.wav");
      }
      if (ScreenAlertForAverageSignals == TRUE && StringFind(ls_412, "Average", 0) >= 0) {
         Alert(ls_520);
         PlaySound("Alert.wav");
      }
      if (ScreenAlertForStrongSignals == TRUE && StringFind(ls_412, "Strong", 0) >= 0) {
         Alert(ls_520);
         PlaySound("Alert.wav");
      }
      if (EmailAlertForWeakSignals == TRUE && StringFind(ls_412, "Weak", 0) >= 0) SendMail(ls_592, ls_584);
      if (EmailAlertForAverageSignals == TRUE && StringFind(ls_412, "Average", 0) >= 0) SendMail(ls_592, ls_584);
      if (EmailAlertForStrongSignals == TRUE && StringFind(ls_412, "Strong", 0) >= 0) SendMail(ls_592, ls_584);
      gi_168 = TRUE;
      gi_164 = FALSE;
   }
   return (0);
}