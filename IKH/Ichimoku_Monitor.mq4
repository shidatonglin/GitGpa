
// ---------------------------------------------------------------------------


#property copyright "Copyright © 2009, ichi360.com"
#property link      "http://www.ichi360.com"

#property indicator_chart_window
extern int     KatanaType           = 61;
extern int     TenkanSen            = 9;
extern int     KijunSen             = 26;
extern int     SenkoSpan            = 52;
extern int     TextOffSetFromRight  = 10;
extern int     TextOffSetFromTop    = -45;
extern bool    Alertof5mn = false; 
extern bool    Alertof15mn = false;
extern bool    Alertof30mn = false;
extern bool    Alertof1h = false;
extern bool    Alertof4h = false;
extern bool    Alertofd = false;
extern bool    Alertofw = false;
extern color   TextColor            = White;
extern color   BullishTextColor     = Blue;
extern color   BearishTextColor     = Red;
extern color   FlatTextColor        = Gold;
bool  a =1;

int init() 
{

   return (0);
}

int deinit() 
{
   // --- MasterWhite Added
   
   ObjectDelete("txtMonitor_1");
   ObjectDelete("txtMonitor_2");
   ObjectDelete("txtMonitor_3");
   ObjectDelete("txtMonitor_4");
   
   // --- Second Group
   
   ObjectDelete("txt1M_1");
   ObjectDelete("txt1M_2");
   ObjectDelete("txt1M_3");
   ObjectDelete("txt1M_4");
   ObjectDelete("txt1M_5");
   //
   ObjectDelete("txt5M_1");
   ObjectDelete("txt5M_2");
   ObjectDelete("txt5M_3");
   ObjectDelete("txt5M_4");
   ObjectDelete("txt5M_5");
   //
   ObjectDelete("txt15M_1");
   ObjectDelete("txt15M_2");
   ObjectDelete("txt15M_3");
   ObjectDelete("txt15M_4");
   ObjectDelete("txt15M_5");
   //
   ObjectDelete("txt30M_1");
   ObjectDelete("txt30M_2");
   ObjectDelete("txt30M_3");
   ObjectDelete("txt30M_4");
   ObjectDelete("txt30M_5");
   
   // --- Original
   
   ObjectDelete("txt1H_1");
   ObjectDelete("txt1H_2");
   ObjectDelete("txt1H_3");
   ObjectDelete("txt1H_4");
   ObjectDelete("txt1H_5");
   //
   ObjectDelete("txt4H_1");
   ObjectDelete("txt4H_2");
   ObjectDelete("txt4H_3");
   ObjectDelete("txt4H_4");
   ObjectDelete("txt4H_5");
   //
   ObjectDelete("txt1D_1");
   ObjectDelete("txt1D_2");
   ObjectDelete("txt1D_3");
   ObjectDelete("txt1D_4");
   ObjectDelete("txt1D_5");
   //
   ObjectDelete("txt1W_1");
   ObjectDelete("txt1W_2");
   ObjectDelete("txt1W_3");
   ObjectDelete("txt1W_4");
   ObjectDelete("txt1W_5");

   return (0);
}

int start() 
{


   // ===================================================================================================
   // Ichi read - added by MasterWhite
   // ===================================================================================================
   // --- M1 ---------- MasterWhite
   
   double l_ichimoku_012 = iIchimoku(NULL, PERIOD_M1, TenkanSen, KijunSen, SenkoSpan, MODE_TENKANSEN, 0);
   double l_ichimoku_020 = iIchimoku(NULL, PERIOD_M1, TenkanSen, KijunSen, SenkoSpan, MODE_KIJUNSEN, 0);
   double l_ichimoku_028 = iIchimoku(NULL, PERIOD_M1, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANA, 0);
   double l_ichimoku_036 = iIchimoku(NULL, PERIOD_M1, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANB, 0);
   double l_ichimoku_044 = iIchimoku(NULL, PERIOD_M1, TenkanSen, KijunSen, SenkoSpan, MODE_CHINKOUSPAN, 26);
   
   // --- M5 ---------- MasterWhite

     double l_ichimoku_052 = iIchimoku(NULL, PERIOD_M5, TenkanSen, KijunSen, SenkoSpan, MODE_TENKANSEN, 0);
   double l_ichimoku_060 = iIchimoku(NULL, PERIOD_M5, TenkanSen, KijunSen, SenkoSpan, MODE_KIJUNSEN, 0);
   double l_ichimoku_068 = iIchimoku(NULL, PERIOD_M5, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANA, 0);
   double l_ichimoku_076 = iIchimoku(NULL, PERIOD_M5, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANB, 0);
   double l_ichimoku_084 = iIchimoku(NULL, PERIOD_M5, TenkanSen, KijunSen, SenkoSpan, MODE_CHINKOUSPAN, 26);
   double l_ichimoku_1000 = iIchimoku(NULL, PERIOD_M5, 9, KatanaType, 26, MODE_KIJUNSEN, 0);

   // --- M15 ---------- MasterWhite

   double l_ichimoku_092 = iIchimoku(NULL, PERIOD_M15, TenkanSen, KijunSen, SenkoSpan, MODE_TENKANSEN, 0);
   double l_ichimoku_0100 = iIchimoku(NULL, PERIOD_M15, TenkanSen, KijunSen, SenkoSpan, MODE_KIJUNSEN, 0);
   double l_ichimoku_0108 = iIchimoku(NULL, PERIOD_M15, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANA, 0);
   double l_ichimoku_0116 = iIchimoku(NULL, PERIOD_M15, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANB, 0);
   double l_ichimoku_0124 = iIchimoku(NULL, PERIOD_M15, TenkanSen, KijunSen, SenkoSpan, MODE_CHINKOUSPAN, 26);
   double l_ichimoku_1001 = iIchimoku(NULL, PERIOD_M15, 9, KatanaType, 26, MODE_KIJUNSEN, 0);

   // --- M30 ---------- MasterWhite

   double l_ichimoku_0132 = iIchimoku(NULL, PERIOD_M30, TenkanSen, KijunSen, SenkoSpan, MODE_TENKANSEN, 0);
   double l_ichimoku_0140 = iIchimoku(NULL, PERIOD_M30, TenkanSen, KijunSen, SenkoSpan, MODE_KIJUNSEN, 0);
   double l_ichimoku_0148 = iIchimoku(NULL, PERIOD_M30, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANA, 0);
   double l_ichimoku_0156 = iIchimoku(NULL, PERIOD_M30, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANB, 0);
   double l_ichimoku_0164 = iIchimoku(NULL, PERIOD_M30, TenkanSen, KijunSen, SenkoSpan, MODE_CHINKOUSPAN, 26);
   double l_ichimoku_1002 = iIchimoku(NULL, PERIOD_M30, 9, KatanaType, 26, MODE_KIJUNSEN, 0);

   
   // ===================================================================================================
   // Ichi read - Original
   // ===================================================================================================
   

   // --- h1 ---------- MasterWhite
   
   double l_ichimoku_12 = iIchimoku(NULL, PERIOD_H1, TenkanSen, KijunSen, SenkoSpan, MODE_TENKANSEN, 0);
   double l_ichimoku_20 = iIchimoku(NULL, PERIOD_H1, TenkanSen, KijunSen, SenkoSpan, MODE_KIJUNSEN, 0);
   double l_ichimoku_28 = iIchimoku(NULL, PERIOD_H1, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANA, 0);
   double l_ichimoku_36 = iIchimoku(NULL, PERIOD_H1, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANB, 0);
   double l_ichimoku_44 = iIchimoku(NULL, PERIOD_H1, TenkanSen, KijunSen, SenkoSpan, MODE_CHINKOUSPAN, 26);
      double l_ichimoku_1003 = iIchimoku(NULL, PERIOD_H1, 9, KatanaType, 26, MODE_KIJUNSEN, 0);

   // --- h4 ---------- MasterWhite

   double l_ichimoku_52 = iIchimoku(NULL, PERIOD_H4, TenkanSen, KijunSen, SenkoSpan, MODE_TENKANSEN, 0);
   double l_ichimoku_60 = iIchimoku(NULL, PERIOD_H4, TenkanSen, KijunSen, SenkoSpan, MODE_KIJUNSEN, 0);
   double l_ichimoku_68 = iIchimoku(NULL, PERIOD_H4, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANA, 0);
   double l_ichimoku_76 = iIchimoku(NULL, PERIOD_H4, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANB, 0);
   double l_ichimoku_84 = iIchimoku(NULL, PERIOD_H4, TenkanSen, KijunSen, SenkoSpan, MODE_CHINKOUSPAN, 26);
   double l_ichimoku_1004 = iIchimoku(NULL, PERIOD_H4, 9, KatanaType, 26, MODE_KIJUNSEN, 0);

   // --- D1 ---------- MasterWhite

   double l_ichimoku_92 = iIchimoku(NULL, PERIOD_D1, TenkanSen, KijunSen, SenkoSpan, MODE_TENKANSEN, 0);
   double l_ichimoku_100 = iIchimoku(NULL, PERIOD_D1, TenkanSen, KijunSen, SenkoSpan, MODE_KIJUNSEN, 0);
   double l_ichimoku_108 = iIchimoku(NULL, PERIOD_D1, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANA, 0);
   double l_ichimoku_116 = iIchimoku(NULL, PERIOD_D1, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANB, 0);
   double l_ichimoku_124 = iIchimoku(NULL, PERIOD_D1, TenkanSen, KijunSen, SenkoSpan, MODE_CHINKOUSPAN, 26);
   double l_ichimoku_1005 = iIchimoku(NULL, PERIOD_D1, 9, KatanaType, 26, MODE_KIJUNSEN, 0);

   // --- W1 ---------- MasterWhite

   double l_ichimoku_132 = iIchimoku(NULL, PERIOD_W1, TenkanSen, KijunSen, SenkoSpan, MODE_TENKANSEN, 0);
   double l_ichimoku_140 = iIchimoku(NULL, PERIOD_W1, TenkanSen, KijunSen, SenkoSpan, MODE_KIJUNSEN, 0);
   double l_ichimoku_148 = iIchimoku(NULL, PERIOD_W1, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANA, 0);
   double l_ichimoku_156 = iIchimoku(NULL, PERIOD_W1, TenkanSen, KijunSen, SenkoSpan, MODE_SENKOUSPANB, 0);
   double l_ichimoku_164 = iIchimoku(NULL, PERIOD_W1, TenkanSen, KijunSen, SenkoSpan, MODE_CHINKOUSPAN, 26);
   double l_ichimoku_1006 = iIchimoku(NULL, PERIOD_W1, 9, KatanaType, 26, MODE_KIJUNSEN, 0);
   // MasterWhite added
   
   int li_0172 = 232;
   int li_0176 = 232;
   int li_0180 = 232;
   int li_0184 = 232;
   color l_color_0188 = FlatTextColor;
   color l_color_0192 = FlatTextColor;
   color l_color_0196 = FlatTextColor;
   color l_color_0200 = FlatTextColor;
   
   // original
   
   int li_172 = 232;
   int li_176 = 232;
   int li_180 = 232;
   int li_184 = 232;
   color l_color_188 = FlatTextColor;
   color l_color_192 = FlatTextColor;
   color l_color_196 = FlatTextColor;
   color l_color_200 = FlatTextColor;
   
   // ===================================================================================================
   // Color Determination - Group 1 (added by MasterWhite
   // ===================================================================================================
   
   // ---  M1 Color --------- MasterWhite

   if (l_ichimoku_012 > l_ichimoku_020) 
   {
      li_0172 = 233;
      l_color_0188 = BullishTextColor;
   }
   if (l_ichimoku_012 < l_ichimoku_020) 
   {
      li_0172 = 234;
      l_color_0188 = BearishTextColor;
   }

   // ---  M5 Color --------- MasterWhite

   if (l_ichimoku_052 > l_ichimoku_060) {
      li_0176 = 233;
      l_color_0192 = BullishTextColor;
   }
   if (l_ichimoku_052 < l_ichimoku_060) 
   {
      li_0176 = 234;
      l_color_0192 = BearishTextColor;
  
   }
     //Alert
 
        
   // ---  M15 Color --------- MasterWhite
   
   if (l_ichimoku_092 > l_ichimoku_0100) 
   {
      li_0180 = 233;
      l_color_0196 = BullishTextColor;
   }
   if (l_ichimoku_092 < l_ichimoku_0100) 
   {
      li_0180 = 234;
      l_color_0196 = BearishTextColor;
   }

 


   // ---  M30 Color --------- MasterWhite

   if (l_ichimoku_0132 > l_ichimoku_0140) 
   {
      li_0184 = 233;
      l_color_0200 = BullishTextColor;
   }
   if (l_ichimoku_0132 < l_ichimoku_0140) 
   {
      li_0184 = 234;
      l_color_0200 = BearishTextColor;
   }

 
   // ===================================================================================================
   // Color Determination - Group 1
   // ===================================================================================================
   
   // ---  H1 Color --------- MasterWhite

   if (l_ichimoku_12 > l_ichimoku_20) 
   {
      li_172 = 233;
      l_color_188 = BullishTextColor;
   }
   if (l_ichimoku_12 < l_ichimoku_20) 
   {
      li_172 = 234;
      l_color_188 = BearishTextColor;
   }
   
  

   // ---  H4 Color --------- MasterWhite

   if (l_ichimoku_52 > l_ichimoku_60) {
      li_176 = 233;
      l_color_192 = BullishTextColor;
   }
   if (l_ichimoku_52 < l_ichimoku_60) 
   {
      li_176 = 234;
      l_color_192 = BearishTextColor;
   }

 
   // ---  D1 Color --------- MasterWhite
   
   if (l_ichimoku_92 > l_ichimoku_100) 
   {
      li_180 = 233;
      l_color_196 = BullishTextColor;
   }
   if (l_ichimoku_92 < l_ichimoku_100) 
   {
      li_180 = 234;
      l_color_196 = BearishTextColor;
   }


 
   // ---  W1 Color --------- MasterWhite

   if (l_ichimoku_132 > l_ichimoku_140) 
   {
      li_184 = 233;
      l_color_200 = BullishTextColor;
   }
   if (l_ichimoku_132 < l_ichimoku_140) 
   {
      li_184 = 234;
      l_color_200 = BearishTextColor;
   }
   
   
   //Alert 
   if( l_ichimoku_052 == l_ichimoku_060 ||l_ichimoku_092 == l_ichimoku_0100 || l_ichimoku_0132 == l_ichimoku_0140 || l_ichimoku_12 == l_ichimoku_20 ||
   
   
   l_ichimoku_52 == l_ichimoku_60 || l_ichimoku_92 == l_ichimoku_100 || l_ichimoku_132 == l_ichimoku_140)
   {
  
  if ( Alertofw==true)
               {
                if( a==1 )
                   {
                            Alert(Symbol() , "Katana");
                 if(l_ichimoku_052 == l_ichimoku_1000 ||l_ichimoku_092 == l_ichimoku_1001 || l_ichimoku_0132 == l_ichimoku_1002 || l_ichimoku_12 == l_ichimoku_1003 ||
   
   
   l_ichimoku_52 == l_ichimoku_1004 || l_ichimoku_92 == l_ichimoku_1005 || l_ichimoku_132 == l_ichimoku_1006)
   
                   Alert(Symbol() , "Strong Katana");     
                   
                                   
                    } 
                    a=0;    
                }  
     }   
  else
  { a=1;
   } 
   
   // ---- MasterWhitte Added

   int li_0204 = 232;
   int li_0208 = 232;
   int li_0212 = 232;
   int li_0216 = 232;
   color l_color_0220 = FlatTextColor;
   color l_color_0224 = FlatTextColor;
   color l_color_0228 = FlatTextColor;
   color l_color_0232 = FlatTextColor;
   
   // ---- Original
   
   int li_204 = 232;
   int li_208 = 232;
   int li_212 = 232;
   int li_216 = 232;
   color l_color_220 = FlatTextColor;
   color l_color_224 = FlatTextColor;
   color l_color_228 = FlatTextColor;
   color l_color_232 = FlatTextColor;

   // ===================================================================================================
   // Color Determination - Group 2 - MasterWhite Added
   // ===================================================================================================
   
   // ---  M1 Color --------- MasterWhite
   
   if (Close[0] > l_ichimoku_028 && Close[0] > l_ichimoku_036) {
      li_0204 = 233;
      l_color_0220 = BullishTextColor;
   }
   if (Close[0] < l_ichimoku_028 && Close[0] < l_ichimoku_036) {
      li_0204 = 234;
      l_color_0220 = BearishTextColor;
   }
   if (Close[0] > l_ichimoku_028 && Close[0] < l_ichimoku_036) {
      li_0204 = 232;
      l_color_0220 = FlatTextColor;
   }
   if (Close[0] < l_ichimoku_028 && Close[0] > l_ichimoku_036) {
      li_0204 = 232;
      l_color_0220 = FlatTextColor;
   }

   // ---  M5 Color --------- MasterWhite

   if (Close[0] > l_ichimoku_068 && Close[0] > l_ichimoku_076) {
      li_0208 = 233;
      l_color_0224 = BullishTextColor;
   }
   if (Close[0] < l_ichimoku_068 && Close[0] < l_ichimoku_076) {
      li_0208 = 234;
      l_color_0224 = BearishTextColor;
   }
   if (Close[0] > l_ichimoku_068 && Close[0] < l_ichimoku_076) {
      li_0208 = 232;
      l_color_0224 = FlatTextColor;
   }
   if (Close[0] < l_ichimoku_068 && Close[0] > l_ichimoku_076) {
      li_0208 = 232;
      l_color_0224 = FlatTextColor;
   }

   // ---  M15 Color --------- MasterWhite

   if (Close[0] > l_ichimoku_0108 && Close[0] > l_ichimoku_0116) {
      li_0212 = 233;
      l_color_0228 = BullishTextColor;
   }
   if (Close[0] < l_ichimoku_0108 && Close[0] < l_ichimoku_0116) {
      li_0212 = 234;
      l_color_0228 = BearishTextColor;
   }
   if (Close[0] > l_ichimoku_0108 && Close[0] < l_ichimoku_0116) {
      li_0212 = 232;
      l_color_0228 = FlatTextColor;
   }
   if (Close[0] < l_ichimoku_0108 && Close[0] > l_ichimoku_0116) {
      li_0212 = 232;
      l_color_0228 = FlatTextColor;
   }

   // ---  M30 Color --------- MasterWhite

   if (Close[0] > l_ichimoku_0148 && Close[0] > l_ichimoku_0156) {
      li_0216 = 233;
      l_color_0232 = BullishTextColor;
   }
   if (Close[0] < l_ichimoku_0148 && Close[0] < l_ichimoku_0156) {
      li_0216 = 234;
      l_color_0232 = BearishTextColor;
   }
   if (Close[0] > l_ichimoku_0148 && Close[0] < l_ichimoku_0156) {
      li_0216 = 232;
      l_color_0232 = FlatTextColor;
   }
   if (Close[0] < l_ichimoku_0148 && Close[0] > l_ichimoku_0156) {
      li_0216 = 232;
      l_color_0232 = FlatTextColor;
   }

   // ===================================================================================================
   // Color Determination - Group 2
   // ===================================================================================================
   
   // ---  H1 Color --------- MasterWhite
   
   if (Close[0] > l_ichimoku_28 && Close[0] > l_ichimoku_36) {
      li_204 = 233;
      l_color_220 = BullishTextColor;
   }
   if (Close[0] < l_ichimoku_28 && Close[0] < l_ichimoku_36) {
      li_204 = 234;
      l_color_220 = BearishTextColor;
   }
   if (Close[0] > l_ichimoku_28 && Close[0] < l_ichimoku_36) {
      li_204 = 232;
      l_color_220 = FlatTextColor;
   }
   if (Close[0] < l_ichimoku_28 && Close[0] > l_ichimoku_36) {
      li_204 = 232;
      l_color_220 = FlatTextColor;
   }

   // ---  H4 Color --------- MasterWhite

   if (Close[0] > l_ichimoku_68 && Close[0] > l_ichimoku_76) {
      li_208 = 233;
      l_color_224 = BullishTextColor;
   }
   if (Close[0] < l_ichimoku_68 && Close[0] < l_ichimoku_76) {
      li_208 = 234;
      l_color_224 = BearishTextColor;
   }
   if (Close[0] > l_ichimoku_68 && Close[0] < l_ichimoku_76) {
      li_208 = 232;
      l_color_224 = FlatTextColor;
   }
   if (Close[0] < l_ichimoku_68 && Close[0] > l_ichimoku_76) {
      li_208 = 232;
      l_color_224 = FlatTextColor;
   }

   // ---  D1 Color --------- MasterWhite

   if (Close[0] > l_ichimoku_108 && Close[0] > l_ichimoku_116) {
      li_212 = 233;
      l_color_228 = BullishTextColor;
   }
   if (Close[0] < l_ichimoku_108 && Close[0] < l_ichimoku_116) {
      li_212 = 234;
      l_color_228 = BearishTextColor;
   }
   if (Close[0] > l_ichimoku_108 && Close[0] < l_ichimoku_116) {
      li_212 = 232;
      l_color_228 = FlatTextColor;
   }
   if (Close[0] < l_ichimoku_108 && Close[0] > l_ichimoku_116) {
      li_212 = 232;
      l_color_228 = FlatTextColor;
   }

   // ---  W1 Color --------- MasterWhite

   if (Close[0] > l_ichimoku_148 && Close[0] > l_ichimoku_156) {
      li_216 = 233;
      l_color_232 = BullishTextColor;
   }
   if (Close[0] < l_ichimoku_148 && Close[0] < l_ichimoku_156) {
      li_216 = 234;
      l_color_232 = BearishTextColor;
   }
   if (Close[0] > l_ichimoku_148 && Close[0] < l_ichimoku_156) {
      li_216 = 232;
      l_color_232 = FlatTextColor;
   }
   if (Close[0] < l_ichimoku_148 && Close[0] > l_ichimoku_156) {
      li_216 = 232;
      l_color_232 = FlatTextColor;
   }

   // ---- MasterWhite added
   
   int li_0236 = 232;
   int li_0240 = 232;
   int li_0244 = 232;
   int li_0248 = 232;
   color l_color_0252 = FlatTextColor;
   color l_color_0256 = FlatTextColor;
   color l_color_0260 = FlatTextColor;
   color l_color_0264 = FlatTextColor;


   // ---- Original
   
   int li_236 = 232;
   int li_240 = 232;
   int li_244 = 232;
   int li_248 = 232;
   color l_color_252 = FlatTextColor;
   color l_color_256 = FlatTextColor;
   color l_color_260 = FlatTextColor;
   color l_color_264 = FlatTextColor;

   // ===================================================================================================
   // Color Determination - Group 3 - MasterWhite Added
   // ===================================================================================================
   
   // ---  M1 Color --------- MasterWhite
   
   if (l_ichimoku_044 > iClose(NULL, PERIOD_M1, KijunSen)) {
      li_0236 = 233;
      l_color_0252 = BullishTextColor;
   }
   if (l_ichimoku_044 < iClose(NULL, PERIOD_M1, KijunSen)) {
      li_0236 = 234;
      l_color_0252 = BearishTextColor;
   }
   
   // ---  M5 Color --------- MasterWhite
   
   if (l_ichimoku_084 > iClose(NULL, PERIOD_M5, KijunSen)) {
      li_0240 = 233;
      l_color_0256 = BullishTextColor;
   }
   if (l_ichimoku_084 < iClose(NULL, PERIOD_M5, KijunSen)) {
      li_0240 = 234;
      l_color_0256 = BearishTextColor;
   }
   
   // ---  M15 Color --------- MasterWhite
   
   if (l_ichimoku_0124 > iClose(NULL, PERIOD_M15, KijunSen)) {
      li_0244 = 233;
      l_color_0260 = BullishTextColor;
   }
   if (l_ichimoku_0124 < iClose(NULL, PERIOD_M15, KijunSen)) {
      li_0244 = 234;
      l_color_0260 = BearishTextColor;
   }
   
   // ---  M30 Color --------- MasterWhite
   
   if (l_ichimoku_0164 > iClose(NULL, PERIOD_M30, KijunSen)) {
      li_0248 = 233;
      l_color_0264 = BullishTextColor;
   }
   if (l_ichimoku_0164 < iClose(NULL, PERIOD_M30, KijunSen)) {
      li_0248 = 234;
      l_color_0264 = BearishTextColor;
   }

   // ===================================================================================================
   // Color Determination - Group 3
   // ===================================================================================================
   
   // ---  H1 Color --------- MasterWhite
   
   if (l_ichimoku_44 > iClose(NULL, PERIOD_H1, KijunSen)) {
      li_236 = 233;
      l_color_252 = BullishTextColor;
   }
   if (l_ichimoku_44 < iClose(NULL, PERIOD_H1, KijunSen)) {
      li_236 = 234;
      l_color_252 = BearishTextColor;
   }
   
   // ---  H4 Color --------- MasterWhite
   
   if (l_ichimoku_84 > iClose(NULL, PERIOD_H4, KijunSen)) {
      li_240 = 233;
      l_color_256 = BullishTextColor;
   }
   if (l_ichimoku_84 < iClose(NULL, PERIOD_H4, KijunSen)) {
      li_240 = 234;
      l_color_256 = BearishTextColor;
   }
   
   // ---  D1 Color --------- MasterWhite
   
   if (l_ichimoku_124 > iClose(NULL, PERIOD_D1, KijunSen)) {
      li_244 = 233;
      l_color_260 = BullishTextColor;
   }
   if (l_ichimoku_124 < iClose(NULL, PERIOD_D1, KijunSen)) {
      li_244 = 234;
      l_color_260 = BearishTextColor;
   }
   
   // ---  W1 Color --------- MasterWhite
   
   if (l_ichimoku_164 > iClose(NULL, PERIOD_W1, KijunSen)) {
      li_248 = 233;
      l_color_264 = BullishTextColor;
   }
   if (l_ichimoku_164 < iClose(NULL, PERIOD_W1, KijunSen)) {
      li_248 = 234;
      l_color_264 = BearishTextColor;
   }

   // --- MasterWhite added

   int li_0268 = 232;
   int li_0272 = 232;
   int li_0276 = 232;
   int li_0280 = 232;
   color l_color_0284 = FlatTextColor;
   color l_color_0288 = FlatTextColor;
   color l_color_0292 = FlatTextColor;
   color l_color_0296 = FlatTextColor;
   
   // --- Original
   
   int li_268 = 232;
   int li_272 = 232;
   int li_276 = 232;
   int li_280 = 232;
   color l_color_284 = FlatTextColor;
   color l_color_288 = FlatTextColor;
   color l_color_292 = FlatTextColor;
   color l_color_296 = FlatTextColor;

   // ===================================================================================================
   // Color Determination - Group 4 -- MasterWhite Added
   // ===================================================================================================
   
   // ---  M1 Color --------- MasterWhite

   if (Close[0] > l_ichimoku_020) {
      li_0268 = 233;
      l_color_0284 = BullishTextColor;
   }
   if (Close[0] < l_ichimoku_020) {
      li_0268 = 234;
      l_color_0284 = BearishTextColor;
   }
   
   // ---  M5 Color --------- MasterWhite

   if (Close[0] > l_ichimoku_060) {
      li_0272 = 233;
      l_color_0288 = BullishTextColor;
   }
   if (Close[0] < l_ichimoku_060) {
      li_0272 = 234;
      l_color_0288 = BearishTextColor;
   }
   
   // ---  M15 Color --------- MasterWhite

   if (Close[0] > l_ichimoku_0100) {
      li_0276 = 233;
      l_color_0292 = BullishTextColor;
   }
   if (Close[0] < l_ichimoku_0100) {
      li_0276 = 234;
      l_color_0292 = BearishTextColor;
   }
   
   // ---  M30 Color --------- MasterWhite

   if (Close[0] > l_ichimoku_0140) {
      li_0280 = 233;
      l_color_0296 = BullishTextColor;
   }
   if (Close[0] < l_ichimoku_0140) {
      li_0280 = 234;
      l_color_0296 = BearishTextColor;
   }

   // ===================================================================================================
   // Color Determination - Group 4
   // ===================================================================================================
   
   // ---  H1 Color --------- MasterWhite

   if (Close[0] > l_ichimoku_20) {
      li_268 = 233;
      l_color_284 = BullishTextColor;
   }
   if (Close[0] < l_ichimoku_20) {
      li_268 = 234;
      l_color_284 = BearishTextColor;
   }
   
   // ---  H4 Color --------- MasterWhite

   if (Close[0] > l_ichimoku_60) {
      li_272 = 233;
      l_color_288 = BullishTextColor;
   }
   if (Close[0] < l_ichimoku_60) {
      li_272 = 234;
      l_color_288 = BearishTextColor;
   }
   
   // ---  D1 Color --------- MasterWhite

   if (Close[0] > l_ichimoku_100) {
      li_276 = 233;
      l_color_292 = BullishTextColor;
   }
   if (Close[0] < l_ichimoku_100) {
      li_276 = 234;
      l_color_292 = BearishTextColor;
   }
   
   // ---  W1 Color --------- MasterWhite

   if (Close[0] > l_ichimoku_140) {
      li_280 = 233;
      l_color_296 = BullishTextColor;
   }
   if (Close[0] < l_ichimoku_140) {
      li_280 = 234;
      l_color_296 = BearishTextColor;
   }
   
 
   
     
   // --- Clean objects ------- MasterWhite
   
   
   ObjectDelete("txtMonitor_1");
   ObjectDelete("txtMonitor_2");
   ObjectDelete("txtMonitor_3");
   ObjectDelete("txtMonitor_4");
   
   // --- MasterWhite added
   
   ObjectDelete("txt1M_1");
   ObjectDelete("txt1M_2");
   ObjectDelete("txt1M_3");
   ObjectDelete("txt1M_4");
   ObjectDelete("txt1M_5");
   //
   ObjectDelete("txt5M_1");
   ObjectDelete("txt5M_2");
   ObjectDelete("txt5M_3");
   ObjectDelete("txt5M_4");
   ObjectDelete("txt5M_5");
   //
   ObjectDelete("txt15M_1");
   ObjectDelete("txt15M_2");
   ObjectDelete("txt15M_3");
   ObjectDelete("txt15M_4");
   ObjectDelete("txt15M_5");
   //
   ObjectDelete("txt30M_1");
   ObjectDelete("txt30M_2");
   ObjectDelete("txt30M_3");
   ObjectDelete("txt30M_4");
   ObjectDelete("txt30M_5");
   
   // --- Original
   
   ObjectDelete("txt1H_1");
   ObjectDelete("txt1H_2");
   ObjectDelete("txt1H_3");
   ObjectDelete("txt1H_4");
   ObjectDelete("txt1H_5");
   //
   ObjectDelete("txt4H_1");
   ObjectDelete("txt4H_2");
   ObjectDelete("txt4H_3");
   ObjectDelete("txt4H_4");
   ObjectDelete("txt4H_5");
   //
   ObjectDelete("txt1D_1");
   ObjectDelete("txt1D_2");
   ObjectDelete("txt1D_3");
   ObjectDelete("txt1D_4");
   ObjectDelete("txt1D_5");
   //
   ObjectDelete("txt1W_1");
   ObjectDelete("txt1W_2");
   ObjectDelete("txt1W_3");
   ObjectDelete("txt1W_4");
   ObjectDelete("txt1W_5");

   // ---- Create text Objects ------ 

   ObjectCreate("txtMonitor_1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txtMonitor_1", OBJPROP_CORNER, 1);
   ObjectSet("txtMonitor_1", OBJPROP_YDISTANCE, TextOffSetFromTop + 45);
   ObjectSet("txtMonitor_1", OBJPROP_XDISTANCE, TextOffSetFromRight);
   //
   ObjectCreate("txtMonitor_2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txtMonitor_2", OBJPROP_CORNER, 1);
   ObjectSet("txtMonitor_2", OBJPROP_YDISTANCE, TextOffSetFromTop + 50);
   ObjectSet("txtMonitor_2", OBJPROP_XDISTANCE, TextOffSetFromRight);
   //
   ObjectCreate("txtMonitor_3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txtMonitor_3", OBJPROP_CORNER, 1);
   ObjectSet("txtMonitor_3", OBJPROP_YDISTANCE, TextOffSetFromTop + 60);
   ObjectSet("txtMonitor_3", OBJPROP_XDISTANCE, TextOffSetFromRight);

   // --- MasterWhite Text added
   
   ObjectCreate("txt1M_1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1M_1", OBJPROP_CORNER, 1);
   ObjectSet("txt1M_1", OBJPROP_YDISTANCE, TextOffSetFromTop + 76);
   ObjectSet("txt1M_1", OBJPROP_XDISTANCE, TextOffSetFromRight + 120);
   ObjectCreate("txt1M_2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1M_2", OBJPROP_CORNER, 1);
   ObjectSet("txt1M_2", OBJPROP_YDISTANCE, TextOffSetFromTop + 76);
   ObjectSet("txt1M_2", OBJPROP_XDISTANCE, TextOffSetFromRight + 94);
   ObjectCreate("txt1M_3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1M_3", OBJPROP_CORNER, 1);
   ObjectSet("txt1M_3", OBJPROP_YDISTANCE, TextOffSetFromTop + 76);
   ObjectSet("txt1M_3", OBJPROP_XDISTANCE, TextOffSetFromRight + 68);
   ObjectCreate("txt1M_4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1M_4", OBJPROP_CORNER, 1);
   ObjectSet("txt1M_4", OBJPROP_YDISTANCE, TextOffSetFromTop + 76);
   ObjectSet("txt1M_4", OBJPROP_XDISTANCE, TextOffSetFromRight + 34);
   ObjectCreate("txt1M_5", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1M_5", OBJPROP_CORNER, 1);
   ObjectSet("txt1M_5", OBJPROP_YDISTANCE, TextOffSetFromTop + 76);
   ObjectSet("txt1M_5", OBJPROP_XDISTANCE, TextOffSetFromRight);

   // ---- Original Text ( has moved down )
   
   ObjectCreate("txt1H_1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1H_1", OBJPROP_CORNER, 1);
   ObjectSet("txt1H_1", OBJPROP_YDISTANCE, TextOffSetFromTop + 76+80);
   ObjectSet("txt1H_1", OBJPROP_XDISTANCE, TextOffSetFromRight + 120);
   ObjectCreate("txt1H_2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1H_2", OBJPROP_CORNER, 1);
   ObjectSet("txt1H_2", OBJPROP_YDISTANCE, TextOffSetFromTop + 76+80);
   ObjectSet("txt1H_2", OBJPROP_XDISTANCE, TextOffSetFromRight + 94);
   ObjectCreate("txt1H_3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1H_3", OBJPROP_CORNER, 1);
   ObjectSet("txt1H_3", OBJPROP_YDISTANCE, TextOffSetFromTop + 76+80);
   ObjectSet("txt1H_3", OBJPROP_XDISTANCE, TextOffSetFromRight + 68);
   ObjectCreate("txt1H_4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1H_4", OBJPROP_CORNER, 1);
   ObjectSet("txt1H_4", OBJPROP_YDISTANCE, TextOffSetFromTop + 76+80);
   ObjectSet("txt1H_4", OBJPROP_XDISTANCE, TextOffSetFromRight + 34);
   ObjectCreate("txt1H_5", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1H_5", OBJPROP_CORNER, 1);
   ObjectSet("txt1H_5", OBJPROP_YDISTANCE, TextOffSetFromTop + 76+80);
   ObjectSet("txt1H_5", OBJPROP_XDISTANCE, TextOffSetFromRight);

   // --- MasterWhite Text added

   ObjectCreate("txt5M_1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt5M_1", OBJPROP_CORNER, 1);
   ObjectSet("txt5M_1", OBJPROP_YDISTANCE, TextOffSetFromTop + 96);
   ObjectSet("txt5M_1", OBJPROP_XDISTANCE, TextOffSetFromRight + 120);
   ObjectCreate("txt5M_2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt5M_2", OBJPROP_CORNER, 1);
   ObjectSet("txt5M_2", OBJPROP_YDISTANCE, TextOffSetFromTop + 96);
   ObjectSet("txt5M_2", OBJPROP_XDISTANCE, TextOffSetFromRight + 94);
   ObjectCreate("txt5M_3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt5M_3", OBJPROP_CORNER, 1);
   ObjectSet("txt5M_3", OBJPROP_YDISTANCE, TextOffSetFromTop + 96);
   ObjectSet("txt5M_3", OBJPROP_XDISTANCE, TextOffSetFromRight + 68);
   ObjectCreate("txt5M_4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt5M_4", OBJPROP_CORNER, 1);
   ObjectSet("txt5M_4", OBJPROP_YDISTANCE, TextOffSetFromTop + 96);
   ObjectSet("txt5M_4", OBJPROP_XDISTANCE, TextOffSetFromRight + 34);
   ObjectCreate("txt5M_5", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt5M_5", OBJPROP_CORNER, 1);
   ObjectSet("txt5M_5", OBJPROP_YDISTANCE, TextOffSetFromTop + 96);
   ObjectSet("txt5M_5", OBJPROP_XDISTANCE, TextOffSetFromRight);

   // ---- Original Text ( has moved down )

   ObjectCreate("txt4H_1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt4H_1", OBJPROP_CORNER, 1);
   ObjectSet("txt4H_1", OBJPROP_YDISTANCE, TextOffSetFromTop + 96+80);
   ObjectSet("txt4H_1", OBJPROP_XDISTANCE, TextOffSetFromRight + 120);
   ObjectCreate("txt4H_2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt4H_2", OBJPROP_CORNER, 1);
   ObjectSet("txt4H_2", OBJPROP_YDISTANCE, TextOffSetFromTop + 96+80);
   ObjectSet("txt4H_2", OBJPROP_XDISTANCE, TextOffSetFromRight + 94);
   ObjectCreate("txt4H_3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt4H_3", OBJPROP_CORNER, 1);
   ObjectSet("txt4H_3", OBJPROP_YDISTANCE, TextOffSetFromTop + 96+80);
   ObjectSet("txt4H_3", OBJPROP_XDISTANCE, TextOffSetFromRight + 68);
   ObjectCreate("txt4H_4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt4H_4", OBJPROP_CORNER, 1);
   ObjectSet("txt4H_4", OBJPROP_YDISTANCE, TextOffSetFromTop + 96+80);
   ObjectSet("txt4H_4", OBJPROP_XDISTANCE, TextOffSetFromRight + 34);
   ObjectCreate("txt4H_5", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt4H_5", OBJPROP_CORNER, 1);
   ObjectSet("txt4H_5", OBJPROP_YDISTANCE, TextOffSetFromTop + 96+80);
   ObjectSet("txt4H_5", OBJPROP_XDISTANCE, TextOffSetFromRight);


   // --- MasterWhite Text added

   ObjectCreate("txt15M_1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt15M_1", OBJPROP_CORNER, 1);
   ObjectSet("txt15M_1", OBJPROP_YDISTANCE, TextOffSetFromTop + 116);
   ObjectSet("txt15M_1", OBJPROP_XDISTANCE, TextOffSetFromRight + 120);
   ObjectCreate("txt15M_2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt15M_2", OBJPROP_CORNER, 1);
   ObjectSet("txt15M_2", OBJPROP_YDISTANCE, TextOffSetFromTop + 116);
   ObjectSet("txt15M_2", OBJPROP_XDISTANCE, TextOffSetFromRight + 94);
   ObjectCreate("txt15M_3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt15M_3", OBJPROP_CORNER, 1);
   ObjectSet("txt15M_3", OBJPROP_YDISTANCE, TextOffSetFromTop + 116);
   ObjectSet("txt15M_3", OBJPROP_XDISTANCE, TextOffSetFromRight + 68);
   ObjectCreate("txt15M_4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt15M_4", OBJPROP_CORNER, 1);
   ObjectSet("txt15M_4", OBJPROP_YDISTANCE, TextOffSetFromTop + 116);
   ObjectSet("txt15M_4", OBJPROP_XDISTANCE, TextOffSetFromRight + 34);
   ObjectCreate("txt15M_5", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt15M_5", OBJPROP_CORNER, 1);
   ObjectSet("txt15M_5", OBJPROP_YDISTANCE, TextOffSetFromTop + 116);
   ObjectSet("txt15M_5", OBJPROP_XDISTANCE, TextOffSetFromRight);

   // ---- Original Text ( has moved down )

   ObjectCreate("txt1D_1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1D_1", OBJPROP_CORNER, 1);
   ObjectSet("txt1D_1", OBJPROP_YDISTANCE, TextOffSetFromTop + 116+80);
   ObjectSet("txt1D_1", OBJPROP_XDISTANCE, TextOffSetFromRight + 120);
   ObjectCreate("txt1D_2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1D_2", OBJPROP_CORNER, 1);
   ObjectSet("txt1D_2", OBJPROP_YDISTANCE, TextOffSetFromTop + 116+80);
   ObjectSet("txt1D_2", OBJPROP_XDISTANCE, TextOffSetFromRight + 94);
   ObjectCreate("txt1D_3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1D_3", OBJPROP_CORNER, 1);
   ObjectSet("txt1D_3", OBJPROP_YDISTANCE, TextOffSetFromTop + 116+80);
   ObjectSet("txt1D_3", OBJPROP_XDISTANCE, TextOffSetFromRight + 68);
   ObjectCreate("txt1D_4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1D_4", OBJPROP_CORNER, 1);
   ObjectSet("txt1D_4", OBJPROP_YDISTANCE, TextOffSetFromTop + 116+80);
   ObjectSet("txt1D_4", OBJPROP_XDISTANCE, TextOffSetFromRight + 34);
   ObjectCreate("txt1D_5", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1D_5", OBJPROP_CORNER, 1);
   ObjectSet("txt1D_5", OBJPROP_YDISTANCE, TextOffSetFromTop + 116+80);
   ObjectSet("txt1D_5", OBJPROP_XDISTANCE, TextOffSetFromRight);

   // --- MasterWhite Text added

   ObjectCreate("txt30M_1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt30M_1", OBJPROP_CORNER, 1);
   ObjectSet("txt30M_1", OBJPROP_YDISTANCE, TextOffSetFromTop + 136);
   ObjectSet("txt30M_1", OBJPROP_XDISTANCE, TextOffSetFromRight + 120);
   ObjectCreate("txt30M_2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt30M_2", OBJPROP_CORNER, 1);
   ObjectSet("txt30M_2", OBJPROP_YDISTANCE, TextOffSetFromTop + 136);
   ObjectSet("txt30M_2", OBJPROP_XDISTANCE, TextOffSetFromRight + 94);
   ObjectCreate("txt30M_3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt30M_3", OBJPROP_CORNER, 1);
   ObjectSet("txt30M_3", OBJPROP_YDISTANCE, TextOffSetFromTop + 136);
   ObjectSet("txt30M_3", OBJPROP_XDISTANCE, TextOffSetFromRight + 68);
   ObjectCreate("txt30M_4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt30M_4", OBJPROP_CORNER, 1);
   ObjectSet("txt30M_4", OBJPROP_YDISTANCE, TextOffSetFromTop + 136);
   ObjectSet("txt30M_4", OBJPROP_XDISTANCE, TextOffSetFromRight + 34);
   ObjectCreate("txt30M_5", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt30M_5", OBJPROP_CORNER, 1);
   ObjectSet("txt30M_5", OBJPROP_YDISTANCE, TextOffSetFromTop + 136);
   ObjectSet("txt30M_5", OBJPROP_XDISTANCE, TextOffSetFromRight);

   // ---- Original Text ( has moved down )

   ObjectCreate("txt1W_1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1W_1", OBJPROP_CORNER, 1);
   ObjectSet("txt1W_1", OBJPROP_YDISTANCE, TextOffSetFromTop + 136+80);
   ObjectSet("txt1W_1", OBJPROP_XDISTANCE, TextOffSetFromRight + 120);
   ObjectCreate("txt1W_2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1W_2", OBJPROP_CORNER, 1);
   ObjectSet("txt1W_2", OBJPROP_YDISTANCE, TextOffSetFromTop + 136+80);
   ObjectSet("txt1W_2", OBJPROP_XDISTANCE, TextOffSetFromRight + 94);
   ObjectCreate("txt1W_3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1W_3", OBJPROP_CORNER, 1);
   ObjectSet("txt1W_3", OBJPROP_YDISTANCE, TextOffSetFromTop + 136+80);
   ObjectSet("txt1W_3", OBJPROP_XDISTANCE, TextOffSetFromRight + 68);
   ObjectCreate("txt1W_4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1W_4", OBJPROP_CORNER, 1);
   ObjectSet("txt1W_4", OBJPROP_YDISTANCE, TextOffSetFromTop + 136+80);
   ObjectSet("txt1W_4", OBJPROP_XDISTANCE, TextOffSetFromRight + 34);
   ObjectCreate("txt1W_5", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txt1W_5", OBJPROP_CORNER, 1);
   ObjectSet("txt1W_5", OBJPROP_YDISTANCE, TextOffSetFromTop + 136+80);
   ObjectSet("txt1W_5", OBJPROP_XDISTANCE, TextOffSetFromRight);

   
   // ---- Put Screen Objects ------ MasterWhite

   ObjectSetText("txtMonitor_1", "Ichimoku PA Monitor with Katana Alert", 7, "Tahoma", TextColor); // modified
   ObjectSetText("txtMonitor_2", "--------------------------------------------------", 8, "Arial", TextColor);
   ObjectSetText("txtMonitor_3", "PA   P/KS   TS/KS    CS", 8, "Tahoma", TextColor);
   
   // --- MasterWhite Added
   ObjectSetText("txt1M_1", "1M:", 8, "Tahoma", TextColor);
   ObjectSetText("txt1M_2", CharToStr(li_0204), 11, "Wingdings", l_color_0220);
   ObjectSetText("txt1M_3", CharToStr(li_0268), 11, "Wingdings", l_color_0284);
   ObjectSetText("txt1M_4", CharToStr(li_0172), 11, "Wingdings", l_color_0188);
   ObjectSetText("txt1M_5", CharToStr(li_0236), 11, "Wingdings", l_color_0252);
   ObjectSetText("txt5M_1", "5M:", 8, "Tahoma", TextColor);
   ObjectSetText("txt5M_2", CharToStr(li_0208), 11, "Wingdings", l_color_0224);
   ObjectSetText("txt5M_3", CharToStr(li_0272), 11, "Wingdings", l_color_0288);
   ObjectSetText("txt5M_4", CharToStr(li_0176), 11, "Wingdings", l_color_0192);
   ObjectSetText("txt5M_5", CharToStr(li_0240), 11, "Wingdings", l_color_0256);
   ObjectSetText("txt15M_1", "15M:", 8, "Tahoma", TextColor);
   ObjectSetText("txt15M_2", CharToStr(li_0212), 11, "Wingdings", l_color_0228);
   ObjectSetText("txt15M_3", CharToStr(li_0276), 11, "Wingdings", l_color_0292);
   ObjectSetText("txt15M_4", CharToStr(li_0180), 11, "Wingdings", l_color_0196);
   ObjectSetText("txt15M_5", CharToStr(li_0244), 11, "Wingdings", l_color_0260);
   ObjectSetText("txt30M_1", "30M:", 8, "Tahoma", TextColor);
   ObjectSetText("txt30M_2", CharToStr(li_0216), 11, "Wingdings", l_color_0232);
   ObjectSetText("txt30M_3", CharToStr(li_0280), 11, "Wingdings", l_color_0296);
   ObjectSetText("txt30M_4", CharToStr(li_0184), 11, "Wingdings", l_color_0200);
   ObjectSetText("txt30M_5", CharToStr(li_0248), 11, "Wingdings", l_color_0264);
   
   // ---- Original ( has moved down)
   
   ObjectSetText("txt1H_1", "1H:", 8, "Tahoma", TextColor);
   ObjectSetText("txt1H_2", CharToStr(li_204), 11, "Wingdings", l_color_220);
   ObjectSetText("txt1H_3", CharToStr(li_268), 11, "Wingdings", l_color_284);
   ObjectSetText("txt1H_4", CharToStr(li_172), 11, "Wingdings", l_color_188);
   ObjectSetText("txt1H_5", CharToStr(li_236), 11, "Wingdings", l_color_252);
   ObjectSetText("txt4H_1", "4H:", 8, "Tahoma", TextColor);
   ObjectSetText("txt4H_2", CharToStr(li_208), 11, "Wingdings", l_color_224);
   ObjectSetText("txt4H_3", CharToStr(li_272), 11, "Wingdings", l_color_288);
   ObjectSetText("txt4H_4", CharToStr(li_176), 11, "Wingdings", l_color_192);
   ObjectSetText("txt4H_5", CharToStr(li_240), 11, "Wingdings", l_color_256);
   ObjectSetText("txt1D_1", "D:", 8, "Tahoma", TextColor);
   ObjectSetText("txt1D_2", CharToStr(li_212), 11, "Wingdings", l_color_228);
   ObjectSetText("txt1D_3", CharToStr(li_276), 11, "Wingdings", l_color_292);
   ObjectSetText("txt1D_4", CharToStr(li_180), 11, "Wingdings", l_color_196);
   ObjectSetText("txt1D_5", CharToStr(li_244), 11, "Wingdings", l_color_260);
   ObjectSetText("txt1W_1", "W:", 8, "Tahoma", TextColor);
   ObjectSetText("txt1W_2", CharToStr(li_216), 11, "Wingdings", l_color_232);
   ObjectSetText("txt1W_3", CharToStr(li_280), 11, "Wingdings", l_color_296);
   ObjectSetText("txt1W_4", CharToStr(li_184), 11, "Wingdings", l_color_200);
   ObjectSetText("txt1W_5", CharToStr(li_248), 11, "Wingdings", l_color_264);
   ObjectSetText("txtMonitor_4", "--------------------------------------------------", 8, "Arial", TextColor);
   return (0);
}