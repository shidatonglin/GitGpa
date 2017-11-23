#property copyright "V 3.00 © 2013, CompassFX"
#property link      "www.compassfx.com"

// v3-01 - Removed broker GMT look-up (as many brokers missing) and replaced with 
//         'Broker_GMT_offset' entry so time functions now work with all brokers.

#property indicator_chart_window

/*
#import "CompassFX.dll"
   string gGrab(string a0, string a1);
#import "dots.dll"
   string returnReg(string a0, string a1);
*/
#import "kernel32.dll"
   int GetTimeZoneInformation(int& a0[]);
#import "dotsv3.dll"
   double dValue(double a0, double a1, int a2);
#import

int gi_76;
bool gi_80 = FALSE;
string gs_84;
double gd_92 = 1.1;
extern string Custom_Indicator = "D.O.T.S. Method";
// extern string Copyright = "© 2013, CompassFX";
// extern string Web_Address = "www.compassfx.com";
extern int Broker_GMT_offset = 2; // GMT_offset (platform GMT diff, if above false)
extern bool Show_Clock = true;
extern int Clock_Vertical_Position = 15;
extern string Level = "=== Level settings ===";
extern int Level_Width = 1;
extern int Text_Font_Size = 8;
extern int Level_Text_Shift = 0;
extern bool Extend_Lines = TRUE;
extern string Daily = "=== Daily settings ===";
extern bool Show_Daily_Open = TRUE;
extern int Number_of_Days = 1;
extern string d1 = "1 = Broker Daily Open";
extern string d2 = "2 = Australian Open";
extern string d3 = "3 = Tokyo Open";
extern string d4 = "4 = Midnight NY Open";
extern string d5 = "5 = European Open";
extern string d6 = "6 = London Open";
extern string d7 = "7 = New York Open";
extern int Daily_Open_Setting = 1;
extern bool Show_Trend = TRUE;
extern string Color = "=== Color settings ===";
extern color Level_Text_Color = DimGray;
extern color Daily_Open_Color = White;
extern color Daily_Separator_Color = DimGray;
extern color Clock_Color = SteelBlue;
extern color Buy_Color = Green;
extern color BT1_Color = LimeGreen;
extern color BT2_Color = CornflowerBlue;
extern color BuySL_Color = Olive;
extern color Sell_Color = Crimson;
extern color ST1_Color = OrangeRed;
extern color ST2_Color = Goldenrod;
extern color SellSL_Color = SaddleBrown;
extern color Up_Trend_Color = RoyalBlue;
extern color Down_Trend_Color = Red;
extern color Flat_Trend_Color = DimGray;
int gi_312 = -7;
int gi_316 = -11;
int gi_320 = -1;
int gi_324 = 0;
int gi_328 = 5;
int gi_332 = 21;
double gda_344[22];
double gda_348[22];
double gda_352[22];
double gda_356[22];
double gda_360[22];
double gda_364[22];
double gda_368[22];
double gda_372[22];
double gda_376[22];
double gda_380[22];
double gda_384[22];
double gda_388[22];
double gda_392[22];
double gda_396[22];
double gda_400[48];
double gda_404[48];
double gda_408[48];
int gia_436[48];
int gia_440[48];
int gi_448 = 22;
int gi_452;
int gi_456;
int gi_460;
int gi_464;
string gsa_468[] = {"Local", "Broker", "N.York", "GMT"};
int gi_472 = -5;
int gi_476;
int gi_480;
double gd_484;
int gi_500;
int gi_504;
bool gi_508 = TRUE;
bool gi_512 = TRUE;
int gi_520;
string gs_524 = "Arial Narrow";
int gi_532 = 9;
int gi_536 = 20;
int gi_540;
bool gi_544 = FALSE;
string gs_548 = "DOTS3_";
string gs_556 = "CLOCK_";
string gs_564 = "WARN_";
double gd_572;
int gi_580;
int gi_584;

/* int f0_16() {
   int li_0;
   bool li_4;
   int li_8;
   gi_76 = FileOpen("dot.bin", FILE_CSV|FILE_READ);
   if (gi_76 < 1) li_4 = FALSE;
   else {
      li_0 = StrToInteger(FileReadString(gi_76));
      FileClose(gi_76);
      li_4 = TRUE;
   }
   if (TimeLocal() - li_0 >= 86400 || li_4 == FALSE) {
      li_8 = f0_1();
      switch (li_8) {
      case 0:
         gi_76 = FileOpen("dot.bin", FILE_WRITE, 8);
         if (gi_76 < 1) {
            Print("Cannot open password cache!");
            return (0);
         }
         FileWrite(gi_76, TimeLocal());
         FileClose(gi_76);
         break;
      case 1:
         Alert("Invalid software key provided!! Please re-install the software with the correct key.");
         gi_80 = TRUE;
         break;
      case 4:
         Alert("Your account has been disabled! Please contact support@compassfx.com");
         gi_80 = TRUE;
         break;
      case 5:
         Alert("Server error!! Please make sure you are connected to the Internet and try again.");
         gi_80 = TRUE;
         break;
      case 6:
         Alert("No key found in your registry (could be a bad installation)! Please re-install DOTs as Administrator.");
         gi_80 = TRUE;
      }
   }
   return (0);
}

int f0_1() {
   string ls_0;
   string ls_8;
   string ls_16;
   string ls_24 = returnReg("Software\\CompassFX\\DOTs", "key");
   if (ls_24 == "") return (6);
   string ls_32 = "key=" + ls_24;
   string ls_40 = gGrab("http://www.compassfx.com/synergy_scripts/d_login.php", ls_32);
   Print("Result -- ", ls_40);
   if (StringSubstr(ls_40, 0, 1) == "0") {
      gs_84 = ls_40;
      return (0);
   }
   if (StringSubstr(ls_40, 0, 1) == "1") return (1);
   if (StringSubstr(ls_40, 0, 1) == "4") return (4);
   return (5);
} */

int init() {
   f0_4();
   f0_33();
   f0_26();
   f0_8();
   gi_540 = ArrayRange(gsa_468, 0);
   gd_572 = f0_30();
   if (gd_572 == 0.01) gi_580 = 2;
   else gi_580 = 4;
   gi_464 = Number_of_Days;
   if (Number_of_Days > 22) gi_464 = 22;
   gi_508 = TRUE;
   IndicatorShortName("D.O.T.S.");
//   f0_16();
   return (0);
}

int deinit() {
   f0_27();
   f0_3();
   f0_26();
   f0_8();
   return (0);
}

int f0_0() {
   int li_0;
   int li_4 = gi_476 - 2;
   switch (Daily_Open_Setting) {
   case 1:
      li_0 = 0;
      break;
   case 2:
      li_0 = 0;
      break;
   case 3:
      li_0 = 2;
      break;
   case 4:
      li_0 = 7;
      break;
   case 5:
      li_0 = 9;
      break;
   case 6:
      li_0 = 10;
      break;
   case 7:
      li_0 = 15;
   }
   if (gi_476 != 100) li_0 += li_4;
   if (li_0 >= 24) li_0 -= 24;
   if (li_0 < 0) li_0 += 24;
   return (li_0);
}

int start() {
   if (gi_80) return (0);
   if (Period() > PERIOD_H4) return (-1);
   if (!IsDllsAllowed()) {
      f0_20(255);
      gi_544 = TRUE;
      return (0);
   }
   // gi_476 = f0_21();
   gi_476 = Broker_GMT_offset;
   // if (gi_476 == 100) Daily_Open_Setting = TRUE;
   gd_484 = f0_19();
   gi_480 = gd_484;
   gi_504 = f0_0();
   if (!f0_7()) {
      f0_11(255);
      gi_544 = TRUE;
      return (0);
   }
   if (f0_22(gd_484, gi_476)) {
      f0_31();
      gi_544 = TRUE;
      return (0);
   }
   if (gi_544) {
      f0_8();
      gi_544 = FALSE;
   }
   f0_31();
   return (0);
}

void f0_31() {
   if (Show_Clock) f0_13(gi_536, Clock_Vertical_Position);
   WindowRedraw();
   if (f0_34()) f0_28(48);
   for (int li_0 = 0; li_0 < gi_464; li_0++) f0_5(li_0);
   f0_12();
}

double f0_19() {
   int lia_0[43];
   switch (GetTimeZoneInformation(lia_0)) {
   case 0:
      return (lia_0[0] / (-60.0));
   case 1:
      return (lia_0[0] / (-60.0));
   case 2:
      return ((lia_0[0] + lia_0[42]) / (-60.0));
   }
   return (0);
}

int f0_17(double ad_0, double ad_8) {
   int li_16 = TimeLocal() - 3600.0 * ad_0;
   int li_20 = TimeCurrent() - 3600.0 * ad_8;
   if (li_16 > li_20 + 300) return (li_16);
   return (li_20);
}

int f0_22(double ad_0, double ad_8) {
   int li_16 = DayOfWeek();
   if (li_16 == 0) return (1);
   if (li_16 == 6) return (1);
   int li_20 = TimeLocal() - 3600.0 * ad_0;
   int li_24 = TimeCurrent() - 3600.0 * ad_8;
   if (li_20 > li_24 + 300) return (1);
   return (0);
}

int f0_34() {
   if (gi_504 < 23) {
      if (TimeHour(iTime(NULL, 0, 0)) == gi_504) gi_520 = -1;
   } else {
      if (TimeDayOfWeek(gi_520) == gi_328 - 1)
         if (TimeHour(iTime(NULL, 0, 0)) == gi_332 - 1) gi_520 = -1;
   }
   if (gi_512 || TimeHour(iTime(NULL, 0, 0)) > gi_520) {
      gi_512 = FALSE;
      gi_520 = TimeHour(iTime(NULL, 0, 0));
      return (1);
   }
   return (0);
}

void f0_25(int ai_0) {
   int li_4 = 0;
   for (int li_8 = 0; li_8 < ai_0 * 2; li_8++) {
      if (TimeDayOfWeek(iTime(NULL, PERIOD_D1, li_8)) != 0) {
         gda_404[li_4] = iHigh(NULL, PERIOD_D1, li_8);
         gda_408[li_4] = iLow(NULL, PERIOD_D1, li_8);
         gda_400[li_4] = iOpen(NULL, PERIOD_D1, li_8);
         gia_436[li_4] = iTime(NULL, PERIOD_D1, li_8);
         gia_440[li_4] = Time[0];
         if (li_4 > 0) {
            if (TimeDayOfWeek(iTime(NULL, PERIOD_D1, li_8 - 1)) != 0) gia_440[li_4] = iTime(NULL, PERIOD_D1, li_8 - 1);
            else gia_440[li_4] = iTime(NULL, PERIOD_D1, li_8 - 2);
         }
         li_4++;
         if (li_4 == ai_0) break;
      }
   }
}

void f0_32(int ai_0) {
   int li_16;
   bool li_20;
   bool li_24;
   int li_4 = 0;
   int li_8 = 0;
   int li_12 = 0;
   while (li_4 < ai_0 * 2) {
      if (TimeDayOfWeek(iTime(NULL, 0, li_12)) == 0) {
         li_4++;
         continue;
      }
      gda_404[li_8] = -99999;
      gda_408[li_8] = 99999;
      if (li_4 > 0) gia_440[li_8] = gia_436[li_8 - 1];
      li_20 = FALSE;
      while (!li_20) {
         if (TimeHour(iTime(NULL, 0, li_12)) >= gi_504) {
            li_24 = FALSE;
            while (!li_24) {
               if (TimeHour(iTime(NULL, 0, li_12)) < gi_504) li_24 = TRUE;
               else {
                  if (TimeDayOfWeek(iTime(NULL, 0, li_12)) == 0) li_12++;
                  else {
                     gda_404[li_8] = MathMax(iHigh(NULL, 0, li_12), gda_404[li_8]);
                     gda_408[li_8] = MathMin(iLow(NULL, 0, li_12), gda_408[li_8]);
                     li_12++;
                  }
               }
            }
            li_20 = TRUE;
         } else {
            li_24 = FALSE;
            while (!li_24) {
               if (TimeHour(iTime(NULL, 0, li_12)) == 0) li_24 = TRUE;
               else {
                  if (TimeDayOfWeek(iTime(NULL, 0, li_12)) == 0) li_12++;
                  else {
                     gda_404[li_8] = MathMax(iHigh(NULL, 0, li_12), gda_404[li_8]);
                     gda_408[li_8] = MathMin(iLow(NULL, 0, li_12), gda_408[li_8]);
                     li_12++;
                  }
               }
            }
            li_24 = FALSE;
            while (!li_24) {
               if (TimeHour(iTime(NULL, 0, li_12)) > 0) li_24 = TRUE;
               else {
                  if (TimeDayOfWeek(iTime(NULL, 0, li_12)) == 0) li_12++;
                  else {
                     gda_404[li_8] = MathMax(iHigh(NULL, 0, li_12), gda_404[li_8]);
                     gda_408[li_8] = MathMin(iLow(NULL, 0, li_12), gda_408[li_8]);
                     li_12++;
                  }
               }
            }
            li_24 = FALSE;
            while (!li_24) {
               if (TimeHour(iTime(NULL, 0, li_12)) < gi_504) li_24 = TRUE;
               else {
                  if (TimeDayOfWeek(iTime(NULL, 0, li_12)) == 0) li_12++;
                  else {
                     gda_404[li_8] = MathMax(iHigh(NULL, 0, li_12), gda_404[li_8]);
                     gda_408[li_8] = MathMin(iLow(NULL, 0, li_12), gda_408[li_8]);
                     li_12++;
                  }
               }
            }
            li_20 = TRUE;
         }
      }
      li_16 = li_12;
      li_20 = FALSE;
      while (!li_20) {
         if (TimeDayOfWeek(iTime(NULL, 0, li_16 - 1)) == 0) li_16--;
         else {
            if (gda_400[li_8] == 0.0) gda_400[li_8] = iOpen(NULL, 0, li_16 - 1);
            gia_436[li_8] = iTime(NULL, 0, li_16 - 1);
            li_20 = TRUE;
         }
      }
      li_8++;
      if (li_8 == ai_0) break;
      li_4++;
   }
}

void f0_28(int ai_0) {
   if (gi_504 == 0 || Daily_Open_Setting == 1) f0_25(ai_0);
   else f0_32(ai_0);
   for (int li_4 = 0; li_4 < 48; li_4++) {
      gda_404[li_4] = NormalizeDouble(gda_404[li_4], gi_580);
      gda_408[li_4] = NormalizeDouble(gda_408[li_4], gi_580);
      gda_400[li_4] = NormalizeDouble(gda_400[li_4], gi_580);
   }
   for (li_4 = 0; li_4 < 22; li_4++) {
      gda_392[li_4] = f0_6(li_4 + 1);
      gda_396[li_4] = f0_24(li_4);
   }
}

void f0_12() {
   int li_0;
   int li_4;
   f0_27();
   gi_452 = f0_29(gi_312 - Level_Text_Shift);
   gi_456 = f0_29(gi_320 - Level_Text_Shift);
   gi_460 = f0_29(gi_316 - Level_Text_Shift);
   for (int li_8 = 0; li_8 < gi_464; li_8++) {
      li_0 = gi_456;
      li_4 = gi_460;
      if (li_8 > 0) {
         li_0 = gia_436[li_8];
         li_4 = gia_440[li_8];
      }
      f0_9(li_8, li_0, li_4, gia_436[li_8], gia_440[li_8]);
      f0_18(li_8, gia_436[li_8]);
   }
}

void f0_5(int ai_0) {
   double ld_36 = gda_392[ai_0];
   double ld_4 = gda_404[ai_0 + 1];
   double ld_12 = gda_408[ai_0 + 1];
   double ld_20 = ld_4 - ld_12;
   double ld_28 = NormalizeDouble(ld_20 / gd_572, 0);
   if (ld_36 >= ld_28) {
      gda_356[ai_0] = gda_400[ai_0];
      gda_360[ai_0] = dValue(gda_356[ai_0], ld_20, 1);
      gda_364[ai_0] = dValue(gda_356[ai_0], ld_20, 2);
      gda_368[ai_0] = dValue(gda_356[ai_0], ld_20, 3);
      gda_372[ai_0] = gda_360[ai_0] - 1.272 * (gda_360[ai_0] - gda_356[ai_0]);
      gda_376[ai_0] = dValue(gda_356[ai_0], ld_20, 4);
      gda_380[ai_0] = dValue(gda_356[ai_0], ld_20, 5);
      gda_384[ai_0] = dValue(gda_356[ai_0], ld_20, 6);
      gda_388[ai_0] = gda_376[ai_0] + 1.272 * (gda_356[ai_0] - gda_376[ai_0]);
      gda_344[ai_0] = gda_368[ai_0] + 0.175 * ld_20;
      gda_348[ai_0] = gda_368[ai_0] + 0.135 * ld_20;
      gda_352[ai_0] = gda_368[ai_0] + ld_20 / 10.0;
   } else {
      if (ld_36 < ld_28) {
         gda_356[ai_0] = gda_400[ai_0];
         gda_360[ai_0] = dValue(gda_356[ai_0], ld_20, 7);
         gda_364[ai_0] = dValue(gda_356[ai_0], ld_20, 8);
         gda_368[ai_0] = dValue(gda_356[ai_0], ld_20, 9);
         gda_372[ai_0] = gda_360[ai_0] - 1.272 * (gda_360[ai_0] - gda_356[ai_0]);
         gda_376[ai_0] = dValue(gda_356[ai_0], ld_20, 10);
         gda_380[ai_0] = dValue(gda_356[ai_0], ld_20, 11);
         gda_384[ai_0] = dValue(gda_356[ai_0], ld_20, 12);
         gda_388[ai_0] = gda_376[ai_0] + 1.272 * (gda_356[ai_0] - gda_376[ai_0]);
         gda_344[ai_0] = gda_368[ai_0] + 0.175 * ld_20;
         gda_348[ai_0] = gda_368[ai_0] + 0.135 * ld_20;
         gda_352[ai_0] = gda_368[ai_0] + ld_20 / 10.0;
      }
   }
   gda_360[ai_0] = NormalizeDouble(gda_360[ai_0], gi_580);
   gda_364[ai_0] = NormalizeDouble(gda_364[ai_0], gi_580);
   gda_368[ai_0] = NormalizeDouble(gda_368[ai_0], gi_580);
   gda_372[ai_0] = NormalizeDouble(gda_372[ai_0], gi_580);
   gda_376[ai_0] = NormalizeDouble(gda_376[ai_0], gi_580);
   gda_380[ai_0] = NormalizeDouble(gda_380[ai_0], gi_580);
   gda_384[ai_0] = NormalizeDouble(gda_384[ai_0], gi_580);
   gda_388[ai_0] = NormalizeDouble(gda_388[ai_0], gi_580);
}

void f0_9(int ai_0, int ai_4, int ai_8, int ai_12, int ai_16) {
   bool li_20;
   bool li_24;
   gi_584 = gda_396[ai_0];
   if (Show_Trend) {
      if (gi_584 == 1) f0_23("L3", gda_352[ai_0],Period() + "-min: Up Trend", Text_Font_Size, Up_Trend_Color);
      if (gi_584 == 2) f0_23("L3", gda_352[ai_0],Period() + "-min: Down Trend", Text_Font_Size, Down_Trend_Color);
      if (gi_584 == 3) f0_23("L3", gda_352[ai_0],Period() + "-min: Flat Trend", Text_Font_Size, Flat_Trend_Color);
   }
   if (ai_0 == 0) {
      // f0_23("L1", gda_344[ai_0], "D.O.T.S. | CompassFX", Text_Font_Size, Gray);
      // if (gi_476 == 100) f0_23("L2", gda_348[ai_0], "Unknown Broker", Text_Font_Size, Gray);
      f0_23("BT2", gda_368[ai_0], "BT2 " + DoubleToStr(gda_368[ai_0], gi_580) + "", Text_Font_Size, Level_Text_Color);
      f0_23("BT1", gda_364[ai_0], "BT1 " + DoubleToStr(gda_364[ai_0], gi_580) + "", Text_Font_Size, Level_Text_Color);
      f0_23("BEntry", gda_360[ai_0], "Buy " + DoubleToStr(gda_360[ai_0], gi_580) + "", Text_Font_Size, Level_Text_Color);
      f0_23("BuySL", gda_372[ai_0], "BSL " + DoubleToStr(gda_372[ai_0], gi_580) + "", Text_Font_Size, Level_Text_Color);
      f0_23("SEntry", gda_376[ai_0], "Sell " + DoubleToStr(gda_376[ai_0], gi_580) + "", Text_Font_Size, Level_Text_Color);
      f0_23("ST1", gda_380[ai_0], "ST1 " + DoubleToStr(gda_380[ai_0], gi_580) + "", Text_Font_Size, Level_Text_Color);
      f0_23("ST2", gda_384[ai_0], "ST2 " + DoubleToStr(gda_384[ai_0], gi_580) + "", Text_Font_Size, Level_Text_Color);
      f0_23("SellSL", gda_388[ai_0], "SSL " + DoubleToStr(gda_388[ai_0], gi_580) + "", Text_Font_Size, Level_Text_Color);
   }
   if (Show_Daily_Open) {
      if (ai_0 == 0) f0_10("MDOp" + ai_0, ai_4, gda_356[ai_0], ai_8, gda_356[ai_0], 1, STYLE_SOLID, Daily_Open_Color);
      else f0_10("MDOp" + ai_0, ai_12, gda_356[ai_0], ai_16, gda_356[ai_0], 1, STYLE_DASH, Daily_Open_Color);
   }
   if (ai_0 == 0) {
      li_20 = Level_Width;
      li_24 = gi_324;
   } else {
      li_20 = TRUE;
      li_24 = TRUE;
   }
   f0_10("MBEntry" + ai_0, ai_4, NormalizeDouble(gda_360[ai_0], gi_580), ai_8, NormalizeDouble(gda_360[ai_0], gi_580), li_20, li_24, Buy_Color);
   f0_10("MBT1" + ai_0, ai_4, NormalizeDouble(gda_364[ai_0], gi_580), ai_8, NormalizeDouble(gda_364[ai_0], gi_580), li_20, li_24, BT1_Color);
   f0_10("MBT2" + ai_0, ai_4, NormalizeDouble(gda_368[ai_0], gi_580), ai_8, NormalizeDouble(gda_368[ai_0], gi_580), li_20, li_24, BT2_Color);
   f0_10("MBSL" + ai_0, ai_4, NormalizeDouble(gda_372[ai_0], gi_580), ai_8, NormalizeDouble(gda_372[ai_0], gi_580), li_20, STYLE_SOLID, BuySL_Color);
   f0_10("MSEntry" + ai_0, ai_4, NormalizeDouble(gda_376[ai_0], gi_580), ai_8, NormalizeDouble(gda_376[ai_0], gi_580), li_20, li_24, Sell_Color);
   f0_10("MST1" + ai_0, ai_4, NormalizeDouble(gda_380[ai_0], gi_580), ai_8, NormalizeDouble(gda_380[ai_0], gi_580), li_20, li_24, ST1_Color);
   f0_10("MST2" + ai_0, ai_4, NormalizeDouble(gda_384[ai_0], gi_580), ai_8, NormalizeDouble(gda_384[ai_0], gi_580), li_20, li_24, ST2_Color);
   f0_10("MSL" + ai_0, ai_4, NormalizeDouble(gda_388[ai_0], gi_580), ai_8, NormalizeDouble(gda_388[ai_0], gi_580), li_20, STYLE_SOLID, SellSL_Color);
   if (ai_0 == 0) {
      if (Extend_Lines) {
         f0_10("MBEntryLine", ai_12, NormalizeDouble(gda_360[ai_0], gi_580), ai_4, NormalizeDouble(gda_360[ai_0], gi_580), 1, STYLE_DASH, Buy_Color);
         f0_10("MBT1Line", ai_12, NormalizeDouble(gda_364[ai_0], gi_580), ai_4, NormalizeDouble(gda_364[ai_0], gi_580), 1, STYLE_DASH, BT1_Color);
         f0_10("MBT2Line", ai_12, NormalizeDouble(gda_368[ai_0], gi_580), ai_4, NormalizeDouble(gda_368[ai_0], gi_580), 1, STYLE_DASH, BT2_Color);
         f0_10("MBSLLine", ai_12, NormalizeDouble(gda_372[ai_0], gi_580), ai_4, NormalizeDouble(gda_372[ai_0], gi_580), 1, STYLE_SOLID, BuySL_Color);
         f0_10("MSEntryLine", ai_12, NormalizeDouble(gda_376[ai_0], gi_580), ai_4, NormalizeDouble(gda_376[ai_0], gi_580), 1, STYLE_DASH, Sell_Color);
         f0_10("MST1Line", ai_12, NormalizeDouble(gda_380[ai_0], gi_580), ai_4, NormalizeDouble(gda_380[ai_0], gi_580), 1, STYLE_DASH, ST1_Color);
         f0_10("MST2Line", ai_12, NormalizeDouble(gda_384[ai_0], gi_580), ai_4, NormalizeDouble(gda_384[ai_0], gi_580), 1, STYLE_DASH, ST2_Color);
         f0_10("MSLLine", ai_12, NormalizeDouble(gda_388[ai_0], gi_580), ai_4, NormalizeDouble(gda_388[ai_0], gi_580), 1, STYLE_SOLID, SellSL_Color);
         if (Show_Daily_Open) f0_10("MDOpLine", ai_12, gda_356[ai_0], ai_4, gda_356[ai_0], 1, STYLE_DASH, Daily_Open_Color);
      }
   }
}

double f0_30() {
   double ld_0;
   if (StringFind(Symbol(), "JPY") >= 0) ld_0 = 0.01;
   else ld_0 = 0.0001;
   return (ld_0);
}

int f0_29(int ai_0) {
   if (ai_0 < 0) return (Time[0] + 60 * Period() * MathAbs(ai_0));
   return (Time[ai_0]);
}

double f0_6(int ai_0) {
   double ld_12;
   double ld_20;
   double ld_4 = 0;
   ld_4 = 0.0;
   for (int li_28 = ai_0; li_28 < gi_448 + ai_0; li_28++) {
      ld_20 = gda_404[li_28] - gda_408[li_28];
      ld_4 += ld_20;
   }
   ld_12 = NormalizeDouble(ld_4 / gi_448 / gd_572, 0);
   return (ld_12);
}

double f0_24(int ai_0) {
   int li_52;
   double ld_4 = iMA(NULL, 0, 3, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ld_12 = iMA(NULL, 0, 10, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ld_20 = iMA(NULL, 0, 26, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ld_28 = iMA(NULL, 0, 47, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ld_36 = (ld_4 + ld_12) / 2.0;
   double ld_44 = (ld_20 + ld_28) / 2.0;
   if (MathAbs(ld_36 - ld_44) < Ask - Bid) li_52 = 3;
   else {
      if (ld_36 < ld_44) li_52 = 2;
      else li_52 = 1;
   }
   return (li_52);
}

void f0_13(int ai_0, int ai_4) {
   int li_28;
   int li_32;
   int li_44;
   string ls_48;
   string ls_56;
   int li_16 = ai_0;
   int li_24 = ai_4;
   gi_500 = f0_17(gd_484, gi_476);
   for (int li_8 = 0; li_8 < gi_540; li_8++) {
      switch (li_8) {
      case 0:
         li_44 = TimeLocal();
         ls_48 = gsa_468[li_8] + "  " + TimeToStr(li_44, TIME_MINUTES) + " : " + gi_480;
         break;
      case 1:
         li_44 = gi_500 + 3600 * gi_476;
         ls_48 = gsa_468[li_8] + "  " + TimeToStr(li_44, TIME_MINUTES) + " : " + gi_476;
         break;
      case 2:
         li_44 = gi_500 + 3600 * gi_472;
         ls_48 = gsa_468[li_8] + "  " + TimeToStr(li_44, TIME_MINUTES) + " : " + gi_472;
         break;
      case 3:
         li_44 = gi_500;
         ls_48 = gsa_468[li_8] + "  " + TimeToStr(li_44, TIME_MINUTES);
      }
      f0_15("_" + DoubleToStr(li_8, 0), ls_48, Black, li_16, li_24);
      li_32 = StringLen(ls_48);
      ls_56 = "_";
      for (int li_12 = 0; li_12 < li_32; li_12++) ls_56 = ls_56 + "_";
      if (gsa_468[li_8] == "GMT") ls_56 = ls_56 + "_";
      li_28 = li_24;
      for (li_12 = 0; li_12 < gi_532 + 4; li_12++) {
         f0_14("_" + DoubleToStr(li_8, 0) + "_" + DoubleToStr(li_12, 0), li_16 - 5, li_28, ls_56, Clock_Color);
         li_28--;
      }
      li_24 = li_24 + gi_532 / 2 + 15;
   }
}

void f0_14(string as_0, int ai_8, int ai_12, string as_16, color ai_24) {
   string ls_28 = gs_556 + Symbol() + as_0;
   if (ObjectFind(ls_28) == -1) {
      ObjectCreate(ls_28, OBJ_LABEL, 0, 0, 0);
      ObjectSet(ls_28, OBJPROP_BACK, TRUE);
   }
   ObjectSet(ls_28, OBJPROP_XDISTANCE, ai_8);
   ObjectSet(ls_28, OBJPROP_YDISTANCE, ai_12);
   ObjectSetText(ls_28, as_16, gi_532, gs_524, ai_24);
}

void f0_15(string as_0, string as_8, color ai_16, int ai_20, int ai_24) {
   string ls_28 = gs_556 + Symbol() + as_0;
   if (ObjectFind(ls_28) == -1) ObjectCreate(ls_28, OBJ_LABEL, 0, 0, 0);
   ObjectSet(ls_28, OBJPROP_XDISTANCE, ai_20);
   ObjectSet(ls_28, OBJPROP_YDISTANCE, ai_24);
   ObjectSetText(ls_28, as_8, gi_532, gs_524, ai_16);
}

void f0_26() {
   string ls_8;
   int li_4 = ObjectsTotal();
   for (int li_0 = li_4; li_0 >= 0; li_0--) {
      ls_8 = ObjectName(li_0);
      if (StringFind(ls_8, gs_556) > -1) ObjectDelete(ls_8);
   }
}

void f0_8() {
   string ls_4;
   int li_0 = ObjectsTotal();
   if (li_0 > 0) {
      for (int li_12 = li_0; li_12 >= 0; li_12--) {
         ls_4 = ObjectName(li_12);
         if (StringFind(ls_4, gs_564, 0) >= 0) ObjectDelete(ls_4);
      }
   }
}

void f0_2(string as_0, int ai_8, int ai_12, int ai_16, int ai_20, color ai_24, string as_28) {
   if (ObjectFind(as_0) != 0) {
      ObjectCreate(as_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(as_0, OBJPROP_CORNER, ai_16);
      ObjectSet(as_0, OBJPROP_XDISTANCE, ai_8);
      ObjectSet(as_0, OBJPROP_YDISTANCE, ai_12);
   }
   ObjectSetText(as_0, as_28, ai_20, "Verdana", ai_24);
}

void f0_20(int ai_0) {
   f0_2(gs_564 + Symbol() + "_warn1", 50, 50, 0, Text_Font_Size, ai_0, "DLL is not allowed. Go to top menu bar.");
   f0_2(gs_564 + Symbol() + "_warn2", 50, Text_Font_Size * 2 + 50 + 4, 0, Text_Font_Size, ai_0, "Select Tools. Select Options.");
   f0_2(gs_564 + Symbol() + "_warn3", 50, Text_Font_Size * 4 + 50 + 8, 0, Text_Font_Size, ai_0, "Under Expert Advisor tab, check Allow DLL imports.");
   f0_2(gs_564 + Symbol() + "_warn4", 50, Text_Font_Size * 4 + 50 + 28, 0, Text_Font_Size, ai_0, "Close and re-open MT4 platform.");
}

void f0_11(int ai_0) {
   f0_2(gs_564 + Symbol() + "_warn5", 50, 50, 0, Text_Font_Size, ai_0, "Not enough bars in chart. Turn off AutoScroll.");
   f0_2(gs_564 + Symbol() + "_warn6", 50, Text_Font_Size * 2 + 50 + 4, 0, Text_Font_Size, ai_0, "Press Page Up Key repeatedly until this message disappears.");
   f0_2(gs_564 + Symbol() + "_warn7", 50, Text_Font_Size * 4 + 50 + 8, 0, Text_Font_Size, ai_0, "Then press the End Key and the DOTS levels should appear.");
   f0_2(gs_564 + Symbol() + "_warn8", 50, Text_Font_Size * 4 + 50 + 28, 0, Text_Font_Size, ai_0, "If not, close and re-open chart. Re-apply DOTS to chart.");
}

void f0_4() {
   string ls_4;
   int li_0 = ObjectsTotal();
   if (li_0 > 0) {
      for (int li_12 = li_0; li_12 >= 0; li_12--) {
         ls_4 = ObjectName(li_12);
         if (StringFind(ls_4, gs_556, 0) >= 0)
            if (StringFind(ls_4, Symbol(), 0) < 0) ObjectDelete(ls_4);
      }
   }
}

void f0_18(int ai_0, int ai_4) {
   string ls_8 = gs_548 + Symbol() + "_Day" + ai_0;
   ObjectDelete(ls_8);
   ObjectCreate(ls_8, OBJ_VLINE, 0, ai_4, Bid);
   ObjectSet(ls_8, OBJPROP_COLOR, Daily_Separator_Color);
   ObjectSet(ls_8, OBJPROP_WIDTH, 1);
   ObjectSet(ls_8, OBJPROP_STYLE, STYLE_SOLID);
}

void f0_10(string as_0, int ai_8, double ad_12, int ai_20, double ad_24, double ad_32, double ad_40, color ai_48) {
   string ls_52 = gs_548 + Symbol() + "_" + as_0;
   ObjectCreate(ls_52, OBJ_TREND, 0, ai_8, ad_12, ai_20, ad_24);
   ObjectSet(ls_52, OBJPROP_COLOR, ai_48);
   ObjectSet(ls_52, OBJPROP_RAY, FALSE);
   ObjectSet(ls_52, OBJPROP_WIDTH, ad_32);
   ObjectSet(ls_52, OBJPROP_STYLE, ad_40);
}

void f0_27() {
   string ls_0 = gs_548 + Symbol() + "_";
   for (int li_8 = 0; li_8 < 5; li_8++) {
      ObjectDelete(ls_0 + "MDOp" + li_8);
      ObjectDelete(ls_0 + "MBEntry" + li_8);
      ObjectDelete(ls_0 + "MBT1" + li_8);
      ObjectDelete(ls_0 + "MBT2" + li_8);
      ObjectDelete(ls_0 + "MBSL" + li_8);
      ObjectDelete(ls_0 + "MSEntry" + li_8);
      ObjectDelete(ls_0 + "MST1" + li_8);
      ObjectDelete(ls_0 + "MST2" + li_8);
      ObjectDelete(ls_0 + "MSL" + li_8);
   }
   ObjectDelete(ls_0 + "MDOpLine");
   ObjectDelete(ls_0 + "MBEntryLine");
   ObjectDelete(ls_0 + "MBT1Line");
   ObjectDelete(ls_0 + "MBT2Line");
   ObjectDelete(ls_0 + "MBSLLine");
   ObjectDelete(ls_0 + "MSEntryLine");
   ObjectDelete(ls_0 + "MST1Line");
   ObjectDelete(ls_0 + "MST2Line");
   ObjectDelete(ls_0 + "MSLLine");
}

void f0_23(string as_0, double ad_8, string as_16, int ai_24, color ai_28) {
   string ls_32 = gs_548 + Symbol() + "_";
   ObjectDelete(ls_32 + as_0);
   if (ObjectFind(ls_32 + as_0) != 0) {
      ObjectCreate(ls_32 + as_0, OBJ_TEXT, 0, gi_452, ad_8);
      ObjectSetText(ls_32 + as_0, as_16, ai_24, "Tahoma", ai_28);
      return;
   }
   ObjectMove(ls_32 + as_0, 0, gi_452, ad_8);
}

void f0_33() {
   string ls_4;
   int li_0 = ObjectsTotal();
   if (li_0 > 0) {
      for (int li_12 = li_0; li_12 >= 0; li_12--) {
         ls_4 = ObjectName(li_12);
         if (StringFind(ls_4, gs_548, 0) >= 0)
            if (StringFind(ls_4, Symbol(), 0) < 0) ObjectDelete(ls_4);
      }
   }
}

void f0_3() {
   string ls_8;
   int li_4 = ObjectsTotal();
   for (int li_0 = li_4; li_0 >= 0; li_0--) {
      ls_8 = ObjectName(li_0);
      if (StringFind(ls_8, gs_548) > -1) ObjectDelete(ls_8);
   }
}

bool f0_7() {
   int li_0 = 1440 / Period();
   int li_4 = 48 * li_0 + 5 * li_0;
   if (Bars > li_4) return (TRUE);
   return (FALSE);
}

/*
int f0_21() {
   string ls_0 = TerminalCompany();
   if (StringFind(ls_0, "ACM") >= 0) return (1);
   if (StringFind(ls_0, "Alpari") >= 0) return (2);
   if (StringFind(ls_0, "ATC") >= 0) return (2);
   if (StringFind(ls_0, "Ava Financial") >= 0) return (0);
   if (StringFind(ls_0, "AxiCorp") >= 0) return (2);
   if (StringFind(ls_0, "Citi FX") >= 0) return (0);
   if (StringFind(ls_0, "Easy Forex") >= 0) return (0);
   if (StringFind(ls_0, "FinFx") >= 0) return (2);
   if (StringFind(ls_0, "FOREX.com") >= 0) return (0);
   if (StringFind(ls_0, "Forex.com") >= 0) return (0);
   if (StringFind(ls_0, "Forex Capital Markets") >= 0) return (0);
   if (StringFind(ls_0, "FOREX Ltd") >= 0) return (0);
   if (StringFind(ls_0, "Forex Place") >= 0) return (0);
   if (StringFind(ls_0, "FXDirectDealer") >= 0) return (2);
   if (StringFind(ls_0, "FXDD") >= 0) return (2);
   if (StringFind(ls_0, "FXOpen") >= 0) return (2);
   if (StringFind(ls_0, "FXPRIMUS") >= 0) return (2);
   if (StringFind(ls_0, "FXPRO") >= 0) return (2);
   if (StringFind(ls_0, "FX Solutions") >= 0) return (-5);
   if (StringFind(ls_0, "GAIN Capital") >= 0) return (0);
   if (StringFind(ls_0, "GCI Financial") >= 0) return (-5);
   if (StringFind(ls_0, "Go Markets") >= 0) return (2);
   if (StringFind(ls_0, "Hantec") >= 0) return (0);
   if (StringFind(ls_0, "IBFX") >= 0) return (0);
   if (StringFind(ls_0, "InterbankFX") >= 0) return (0);
   if (StringFind(ls_0, "Interbank FX") >= 0) return (0);
   if (StringFind(ls_0, "iTrade") >= 0) return (0);
   if (StringFind(ls_0, "London Capital Group") >= 0) return (0);
   if (StringFind(ls_0, "SafeCap") >= 0) return (0);
   if (StringFind(ls_0, "MB Trading") >= 0) return (-5);
   if (StringFind(ls_0, "MIG Bank") >= 0) return (1);
   if (StringFind(ls_0, "OANDA") >= 0) return (-5);
   if (StringFind(ls_0, "Pepperstone") >= 0) return (2);
   if (StringFind(ls_0, "Smart Live") >= 0) return (1);
   if (StringFind(ls_0, "Straighthold") >= 0) return (2);
   if (StringFind(ls_0, "Swissquote") >= 0) return (1);
   if (StringFind(ls_0, "VantageFX") >= 0) return (2);
   if (StringFind(ls_0, "Trading Point") >= 0) return (2);
   return (100);
} */