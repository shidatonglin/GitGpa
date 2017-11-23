//+------------------------------------------------------------------+
//|                                          TMS Angleator v3.00.mq4 |
//|                                                     Griffin Soul |
//|                         http://www.forexfactory.com/griffinssoul |
//+------------------------------------------------------------------+
//
// MODIFICATIONS
//
// 2015.07.05  MRaye  Added option to use WAvg of both TDI lines for angle calculations.
// 2015.07.05  MRaye  Added Wayover Bought/Sold states to better visualize extremes.
// 2015.07.05  MRaye  Changed panel ratio text to be DimGray.
// 2015.07.08  MRaye  Added [Panel Location] parm to allow for different panel placements.
// 2015.07.08  MRaye  Added [xAxis Offset] & [Instance ID] parms to allow for multiple 
//                    panels on the same chart.
// 2015.07.09  MRaye  Combined Arrow & Zone into single fn to elimate iCustom recalculations.
// 2015.07.09  MRaye  Combined Angles & Seperation into single fn to elimate iCustom recalculations.
// 2015.07.09  MRaye  Added/modified Seperation text to include confirmed crossing states.
// 2015.07.10  MRaye  Added [..RSIPrice] & [..TradeSig] parms to accomodate for different parameter
//                    orders in external TDI indicators.
// 2015.07.14  MRaye  Renamed object identifiers to eliminate confusion when dealing with multiple TFs.
// 2015.07.14  MRaye  Added ability to turn on/off M5 statistics for scalp trading.
// 2015.07.15  MRaye  Added MTF seperation indicator to panel.
// 2015.07.16  MRaye  Added M5 divider line on panel to better visually seperate M5 from other TFs.

#property copyright "Griffin Soul"
#property link      "http://www.forexfactory.com/griffinssoul"
#property version   "3.00"
#property strict
#property indicator_chart_window

// External settings
extern color  Text_Color = clrLavender;
extern color  Back_Ground_Color = clrMidnightBlue;
extern color  Arrow_Bull = clrGreen;
extern color  Neutral_Arrow = clrBlack;
extern bool   trans_back = false;
extern color  Arrow_Bear = clrRed;
extern color  Over_bought = clrGreen;
extern color  Over_sold = clrRed;
extern color  Wayover_bought = clrDarkSlateGray;
extern color  Wayover_sold = clrMaroon;
extern color  Above_fifty = clrLightGreen;
extern color  Below_fifty = clrOrange;
extern string Font_Type = "Times New";
extern int    Font_Size = 8;
extern double TDI_cross_threshold = 1.5;   // TDI cross happens within Green/Red line separation less than 1.00 (default)
extern double TDI_normal_threshold = 5.0;  // Separation is normal for values less than 5.00 (default) & strong > 5.00
extern int    TDI_Angle_Type = 0;          // TDI Angle (0=WAVG, 1=Green, 2=Red)
extern string TDI_Indicator = "TDI-RT-Clone"; // TDI Indicator
extern int    TDI_Indicator_RSIPrice = 4;
extern int    TDI_Indicator_TradeSig = 3;
extern bool   bShowM5 = true;              // Show M5?
extern bool   bShowSpread = true;          // Show MTF Seperation?
extern int    Panel_Location = 1;          // Panel Location (0=TopLeft, 1=TopRight, 2=BottomLeft, 3=BottomRight)
extern int    iXOffset = 0;                // Panel X-Axis Offset
extern string Instance = "TMSAngl1";       // Instance ID

// Global declarations
double GreenAngle;
double RedAngle;
double GreenAngle_HX;
double RedAngle_HX;
double test_TdiDistance;
double convert2pips;
string ratio_display;
string degree_display;
string TdiDistance;
string Tdi_cross_HX;
string Tdi_zone_HX;
string sTDISpread;
color  slope_color_HX;
color  zone_color_HX;
color  spread_color_HX = clrDimGray;
int    Expand_X=240;

//---
// Start
//---
int start()
{
   const int iYPosSlopeInd = 90;
   const int iYPosSpreadInd = 120;
   const int iYPosZoneInd = 135;
   int iXPadding;

   //---Panel Ratio
   if (trans_back == false)
   {
      Panel_Ratio();
      ObjectCreate(Instance+"_PanelInfo", OBJ_LABEL,1, 0, 0);
      ObjectSet(Instance+"_PanelInfo", OBJPROP_CORNER, Panel_Location);
      ObjectSet(Instance+"_PanelInfo", OBJPROP_XDISTANCE, 10+iXOffset);
      ObjectSet(Instance+"_PanelInfo", OBJPROP_YDISTANCE, 10);
      ObjectSetText(Instance+"_PanelInfo", ratio_display, Font_Size, Font_Type, clrDimGray);
   }

   SetTDICurrent();
   //---Angles
   ObjectCreate(Instance+"_TDIAngles", OBJ_LABEL, 1, 0, 0);
   ObjectSet(Instance+"_TDIAngles", OBJPROP_CORNER, Panel_Location);
   ObjectSet(Instance+"_TDIAngles", OBJPROP_XDISTANCE, 10+iXOffset);
   ObjectSet(Instance+"_TDIAngles", OBJPROP_YDISTANCE, 25);
   ObjectSetText(Instance+"_TDIAngles", degree_display + "  Green: " +DoubleToStr(GreenAngle,0)+ "°  Red: " +DoubleToStr(RedAngle,0)+"°", Font_Size, Font_Type, Text_Color);
   //---Separation
   ObjectCreate(Instance+"_TDISpread", OBJ_LABEL,1, 0, 0);
   ObjectSet(Instance+"_TDISpread", OBJPROP_CORNER, Panel_Location);
   ObjectSet(Instance+"_TDISpread", OBJPROP_XDISTANCE, 10+iXOffset);
   ObjectSet(Instance+"_TDISpread", OBJPROP_YDISTANCE, 40);
   if (TdiDistance == "Crossed UP")
      ObjectSetText(Instance+"_TDISpread",  "TDI "+TdiDistance+" ["+DoubleToStr(test_TdiDistance,1)+"]", Font_Size, Font_Type, clrLime);
   else if (TdiDistance == "Crossed DOWN")
      ObjectSetText(Instance+"_TDISpread",  "TDI "+TdiDistance+" ["+DoubleToStr(test_TdiDistance,1)+"]", Font_Size, Font_Type, clrRed);
   else
      ObjectSetText(Instance+"_TDISpread",  "TDI Seperation: "+TdiDistance+" ["+DoubleToStr(test_TdiDistance,1)+"]",Font_Size,Font_Type,Text_Color);

   //---M5 (x=202)
   if (bShowM5)
   {
      iXPadding=4;
      SetArrowAndZone(PERIOD_M5);
      ObjectCreate(Instance+"_M5_label",OBJ_LABEL,1,0,0);
      ObjectSet(Instance+"_M5_label",OBJPROP_CORNER,Panel_Location);
      ObjectSet(Instance+"_M5_label",OBJPROP_XDISTANCE,210+iXOffset+iXPadding);
      ObjectSet(Instance+"_M5_label",OBJPROP_YDISTANCE,70);
      ObjectSet(Instance+"_M5_label",OBJPROP_ANCHOR,ANCHOR_UPPER);
      ObjectSetText(Instance+"_M5_label","M5",Font_Size,Font_Type,DimGray);
      ObjectCreate(Instance+"_M5_slope",OBJ_LABEL,1,0,0);
      ObjectSet(Instance+"_M5_slope",OBJPROP_CORNER,Panel_Location);
      ObjectSet(Instance+"_M5_slope",OBJPROP_BACK,false);
      ObjectSet(Instance+"_M5_slope",OBJPROP_XDISTANCE,210+iXOffset+iXPadding);
      ObjectSet(Instance+"_M5_slope",OBJPROP_YDISTANCE,iYPosSlopeInd);
      ObjectSet(Instance+"_M5_slope",OBJPROP_ANCHOR,ANCHOR_UPPER);
      ObjectSetText(Instance+"_M5_slope", Tdi_cross_HX, 12,"Wingdings", slope_color_HX);
      ObjectCreate(Instance+"_M5_zone",OBJ_LABEL,1,0,0);
      ObjectSet(Instance+"_M5_zone",OBJPROP_CORNER,Panel_Location);
      ObjectSet(Instance+"_M5_zone",OBJPROP_BACK,false);
      ObjectSet(Instance+"_M5_zone",OBJPROP_XDISTANCE,210+iXOffset+iXPadding);
      ObjectSet(Instance+"_M5_zone",OBJPROP_YDISTANCE,iYPosZoneInd);
      ObjectSet(Instance+"_M5_zone",OBJPROP_ANCHOR,ANCHOR_UPPER);
      ObjectSetText(Instance+"_M5_zone", Tdi_zone_HX, 12,"Wingdings", zone_color_HX);
      if (bShowSpread)
      {
         ObjectCreate(Instance+"_M5_spread",OBJ_LABEL,1,0,0);
         ObjectSet(Instance+"_M5_spread",OBJPROP_CORNER,Panel_Location);
         ObjectSet(Instance+"_M5_spread",OBJPROP_BACK,false);
         ObjectSet(Instance+"_M5_spread",OBJPROP_XDISTANCE,210+iXOffset+iXPadding);
         ObjectSet(Instance+"_M5_spread",OBJPROP_YDISTANCE,iYPosSpreadInd);
         ObjectSet(Instance+"_M5_spread",OBJPROP_ANCHOR,ANCHOR_CENTER);
         ObjectSetText(Instance+"_M5_spread",sTDISpread,12,"Wingdings",spread_color_HX);
      }
   }
   else
      iXPadding=20;
   
   //---M15
   SetArrowAndZone(PERIOD_M15);
   ObjectCreate(Instance+"_M15_label",OBJ_LABEL,1,0,0);
   ObjectSet(Instance+"_M15_label",OBJPROP_CORNER,Panel_Location);
   ObjectSet(Instance+"_M15_label",OBJPROP_XDISTANCE,167+iXOffset+iXPadding);
   ObjectSet(Instance+"_M15_label",OBJPROP_YDISTANCE,70);
   ObjectSet(Instance+"_M15_label",OBJPROP_ANCHOR,ANCHOR_UPPER);
   ObjectSetText(Instance+"_M15_label","M15",Font_Size,Font_Type,Text_Color);
   ObjectCreate(Instance+"_M15_slope",OBJ_LABEL,1,0,0);
   ObjectSet(Instance+"_M15_slope",OBJPROP_CORNER,Panel_Location);
   ObjectSet(Instance+"_M15_slope",OBJPROP_BACK,false);
   ObjectSet(Instance+"_M15_slope",OBJPROP_XDISTANCE,167+iXOffset+iXPadding);
   ObjectSet(Instance+"_M15_slope",OBJPROP_YDISTANCE,iYPosSlopeInd);
   ObjectSet(Instance+"_M15_slope",OBJPROP_ANCHOR,ANCHOR_UPPER);
   ObjectSetText(Instance+"_M15_slope", Tdi_cross_HX, 12,"Wingdings", slope_color_HX);
   ObjectCreate(Instance+"_M15_zone",OBJ_LABEL,1,0,0);
   ObjectSet(Instance+"_M15_zone",OBJPROP_CORNER,Panel_Location);
   ObjectSet(Instance+"_M15_zone",OBJPROP_BACK,false);
   ObjectSet(Instance+"_M15_zone",OBJPROP_XDISTANCE,167+iXOffset+iXPadding);
   ObjectSet(Instance+"_M15_zone",OBJPROP_YDISTANCE,iYPosZoneInd);
   ObjectSet(Instance+"_M15_zone",OBJPROP_ANCHOR,ANCHOR_UPPER);
   ObjectSetText(Instance+"_M15_zone", Tdi_zone_HX, 12,"Wingdings", zone_color_HX);
   if (bShowSpread)
   {
      ObjectCreate(Instance+"_M15_spread",OBJ_LABEL,1,0,0);
      ObjectSet(Instance+"_M15_spread",OBJPROP_CORNER,Panel_Location);
      ObjectSet(Instance+"_M15_spread",OBJPROP_BACK,false);
      ObjectSet(Instance+"_M15_spread",OBJPROP_XDISTANCE,167+iXOffset+iXPadding);
      ObjectSet(Instance+"_M15_spread",OBJPROP_YDISTANCE,iYPosSpreadInd);
      ObjectSet(Instance+"_M15_spread",OBJPROP_ANCHOR,ANCHOR_CENTER);
      ObjectSetText(Instance+"_M15_spread",sTDISpread,12,"Wingdings",spread_color_HX);
   }

   //---M30
   SetArrowAndZone(PERIOD_M30);
   ObjectCreate(Instance+"_M30_label",OBJ_LABEL,1,0,0);
   ObjectSet(Instance+"_M30_label",OBJPROP_CORNER,Panel_Location);
   ObjectSet(Instance+"_M30_label",OBJPROP_XDISTANCE,132+iXOffset+iXPadding);
   ObjectSet(Instance+"_M30_label",OBJPROP_YDISTANCE,70);
   ObjectSet(Instance+"_M30_label",OBJPROP_ANCHOR,ANCHOR_UPPER);
   ObjectSetText(Instance+"_M30_label","M30",Font_Size,Font_Type,Text_Color);
   ObjectCreate(Instance+"_M30_slope",OBJ_LABEL,1,0,0);
   ObjectSet(Instance+"_M30_slope",OBJPROP_CORNER,Panel_Location);
   ObjectSet(Instance+"_M30_slope",OBJPROP_BACK,false);
   ObjectSet(Instance+"_M30_slope",OBJPROP_XDISTANCE,132+iXOffset+iXPadding);
   ObjectSet(Instance+"_M30_slope",OBJPROP_YDISTANCE,iYPosSlopeInd);
   ObjectSet(Instance+"_M30_slope",OBJPROP_ANCHOR,ANCHOR_UPPER);
   ObjectSetText(Instance+"_M30_slope", Tdi_cross_HX, 12,"Wingdings", slope_color_HX);
   ObjectCreate(Instance+"_M30_zone",OBJ_LABEL,1,0,0);
   ObjectSet(Instance+"_M30_zone",OBJPROP_CORNER,Panel_Location);
   ObjectSet(Instance+"_M30_zone",OBJPROP_BACK,false);
   ObjectSet(Instance+"_M30_zone",OBJPROP_XDISTANCE,132+iXOffset+iXPadding);
   ObjectSet(Instance+"_M30_zone",OBJPROP_YDISTANCE,iYPosZoneInd);
   ObjectSet(Instance+"_M30_zone",OBJPROP_ANCHOR,ANCHOR_UPPER);
   ObjectSetText(Instance+"_M30_zone", Tdi_zone_HX, 12,"Wingdings", zone_color_HX);
   if (bShowSpread)
   {
      ObjectCreate(Instance+"_M30_spread",OBJ_LABEL,1,0,0);
      ObjectSet(Instance+"_M30_spread",OBJPROP_CORNER,Panel_Location);
      ObjectSet(Instance+"_M30_spread",OBJPROP_BACK,false);
      ObjectSet(Instance+"_M30_spread",OBJPROP_XDISTANCE,132+iXOffset+iXPadding);
      ObjectSet(Instance+"_M30_spread",OBJPROP_YDISTANCE,iYPosSpreadInd);
      ObjectSet(Instance+"_M30_spread",OBJPROP_ANCHOR,ANCHOR_CENTER);
      ObjectSet(Instance+"_M30_spread",OBJPROP_ZORDER,0);
      ObjectSetText(Instance+"_M30_spread",sTDISpread,12,"Wingdings",spread_color_HX);
   }

   //---H1
   SetArrowAndZone(PERIOD_H1);
   ObjectCreate(Instance+"_H1_label",OBJ_LABEL,1,0,0);
   ObjectSet(Instance+"_H1_label",OBJPROP_CORNER,Panel_Location);
   ObjectSet(Instance+"_H1_label",OBJPROP_XDISTANCE,97+iXOffset+iXPadding);
   ObjectSet(Instance+"_H1_label",OBJPROP_YDISTANCE,70);
   ObjectSet(Instance+"_H1_label",OBJPROP_ANCHOR,ANCHOR_UPPER);
   ObjectSetText(Instance+"_H1_label","H1",Font_Size,Font_Type,Text_Color);
   ObjectCreate(Instance+"_H1_slope",OBJ_LABEL,1,0,0);
   ObjectSet(Instance+"_H1_slope",OBJPROP_CORNER,Panel_Location);
   ObjectSet(Instance+"_H1_slope",OBJPROP_BACK,false);
   ObjectSet(Instance+"_H1_slope",OBJPROP_XDISTANCE,97+iXOffset+iXPadding);
   ObjectSet(Instance+"_H1_slope",OBJPROP_YDISTANCE,iYPosSlopeInd);
   ObjectSet(Instance+"_H1_slope",OBJPROP_ANCHOR,ANCHOR_UPPER);
   ObjectSetText(Instance+"_H1_slope", Tdi_cross_HX, 12,"Wingdings", slope_color_HX);
   ObjectCreate(Instance+"_H1_zone",OBJ_LABEL,1,0,0);
   ObjectSet(Instance+"_H1_zone",OBJPROP_CORNER,Panel_Location);
   ObjectSet(Instance+"_H1_zone",OBJPROP_BACK,false);
   ObjectSet(Instance+"_H1_zone",OBJPROP_XDISTANCE,97+iXOffset+iXPadding);
   ObjectSet(Instance+"_H1_zone",OBJPROP_YDISTANCE,iYPosZoneInd);
   ObjectSet(Instance+"_H1_zone",OBJPROP_ANCHOR,ANCHOR_UPPER);
   ObjectSetText(Instance+"_H1_zone", Tdi_zone_HX, 12,"Wingdings", zone_color_HX);
   if (bShowSpread)
   {
      ObjectCreate(Instance+"_H1_spread",OBJ_LABEL,1,0,0);
      ObjectSet(Instance+"_H1_spread",OBJPROP_CORNER,Panel_Location);
      ObjectSet(Instance+"_H1_spread",OBJPROP_BACK,false);
      ObjectSet(Instance+"_H1_spread",OBJPROP_XDISTANCE,97+iXOffset+iXPadding);
      ObjectSet(Instance+"_H1_spread",OBJPROP_YDISTANCE,iYPosSpreadInd);
      ObjectSet(Instance+"_H1_spread",OBJPROP_ANCHOR,ANCHOR_CENTER);
      ObjectSetText(Instance+"_H1_spread",sTDISpread,12,"Wingdings",spread_color_HX);
   }

   //---H4
   SetArrowAndZone(PERIOD_H4);
   ObjectCreate(Instance+"_H4_label",OBJ_LABEL,1,0,0);
   ObjectSet(Instance+"_H4_label",OBJPROP_CORNER,Panel_Location);
   ObjectSet(Instance+"_H4_label",OBJPROP_XDISTANCE,62+iXOffset+iXPadding);
   ObjectSet(Instance+"_H4_label",OBJPROP_YDISTANCE,70);
   ObjectSet(Instance+"_H4_label",OBJPROP_ANCHOR,ANCHOR_UPPER);
   ObjectSetText(Instance+"_H4_label","H4",Font_Size,Font_Type,Text_Color);
   ObjectCreate(Instance+"_H4_slope",OBJ_LABEL,1,0,0);
   ObjectSet(Instance+"_H4_slope",OBJPROP_CORNER,Panel_Location);
   ObjectSet(Instance+"_H4_slope",OBJPROP_BACK,false);
   ObjectSet(Instance+"_H4_slope",OBJPROP_XDISTANCE,62+iXOffset+iXPadding);
   ObjectSet(Instance+"_H4_slope",OBJPROP_YDISTANCE,iYPosSlopeInd);
   ObjectSet(Instance+"_H4_slope",OBJPROP_ANCHOR,ANCHOR_UPPER);
   ObjectSetText(Instance+"_H4_slope", Tdi_cross_HX, 12,"Wingdings", slope_color_HX);
   ObjectCreate(Instance+"_H4_zone",OBJ_LABEL,1,0,0);
   ObjectSet(Instance+"_H4_zone",OBJPROP_CORNER,Panel_Location);
   ObjectSet(Instance+"_H4_zone",OBJPROP_BACK,false);
   ObjectSet(Instance+"_H4_zone",OBJPROP_XDISTANCE,62+iXOffset+iXPadding);
   ObjectSet(Instance+"_H4_zone",OBJPROP_YDISTANCE,iYPosZoneInd);
   ObjectSet(Instance+"_H4_zone",OBJPROP_ANCHOR,ANCHOR_UPPER);
   ObjectSetText(Instance+"_H4_zone", Tdi_zone_HX, 12,"Wingdings", zone_color_HX);
   if (bShowSpread)
   {
      ObjectCreate(Instance+"_H4_spread",OBJ_LABEL,1,0,0);
      ObjectSet(Instance+"_H4_spread",OBJPROP_CORNER,Panel_Location);
      ObjectSet(Instance+"_H4_spread",OBJPROP_BACK,false);
      ObjectSet(Instance+"_H4_spread",OBJPROP_XDISTANCE,62+iXOffset+iXPadding);
      ObjectSet(Instance+"_H4_spread",OBJPROP_YDISTANCE,iYPosSpreadInd);
      ObjectSet(Instance+"_H4_spread",OBJPROP_ANCHOR,ANCHOR_CENTER);
      ObjectSetText(Instance+"_H4_spread",sTDISpread,12,"Wingdings",spread_color_HX);
   }

   //---D1
   SetArrowAndZone(PERIOD_D1);
   ObjectCreate(Instance+"_D1_label",OBJ_LABEL,1,0,0);
   ObjectSet(Instance+"_D1_label",OBJPROP_CORNER,Panel_Location);
   ObjectSet(Instance+"_D1_label",OBJPROP_XDISTANCE,27+iXOffset+iXPadding);
   ObjectSet(Instance+"_D1_label",OBJPROP_YDISTANCE,70);
   ObjectSet(Instance+"_D1_label",OBJPROP_ANCHOR,ANCHOR_UPPER);
   ObjectSetText(Instance+"_D1_label","D1",Font_Size,Font_Type,Text_Color);
   ObjectCreate(Instance+"_D1_slope",OBJ_LABEL,1,0,0);
   ObjectSet(Instance+"_D1_slope",OBJPROP_CORNER,Panel_Location);
   ObjectSet(Instance+"_D1_slope",OBJPROP_BACK,false);
   ObjectSet(Instance+"_D1_slope",OBJPROP_XDISTANCE,27+iXOffset+iXPadding);
   ObjectSet(Instance+"_D1_slope",OBJPROP_YDISTANCE,iYPosSlopeInd);
   ObjectSet(Instance+"_D1_slope",OBJPROP_ANCHOR,ANCHOR_UPPER);
   ObjectSetText(Instance+"_D1_slope", Tdi_cross_HX, 12,"Wingdings", slope_color_HX);
   ObjectCreate(Instance+"_D1_zone",OBJ_LABEL,1,0,0);
   ObjectSet(Instance+"_D1_zone",OBJPROP_CORNER,Panel_Location);
   ObjectSet(Instance+"_D1_zone",OBJPROP_BACK,false);
   ObjectSet(Instance+"_D1_zone",OBJPROP_XDISTANCE,27+iXOffset+iXPadding);
   ObjectSet(Instance+"_D1_zone",OBJPROP_YDISTANCE,iYPosZoneInd);
   ObjectSet(Instance+"_D1_zone",OBJPROP_ANCHOR,ANCHOR_UPPER);
   ObjectSetText(Instance+"_D1_zone", Tdi_zone_HX, 12,"Wingdings", zone_color_HX);
   if (bShowSpread)
   {
      ObjectCreate(Instance+"_D1_spread",OBJ_LABEL,1,0,0);
      ObjectSet(Instance+"_D1_spread",OBJPROP_CORNER,Panel_Location);
      ObjectSet(Instance+"_D1_spread",OBJPROP_BACK,false);
      ObjectSet(Instance+"_D1_spread",OBJPROP_XDISTANCE,27+iXOffset+iXPadding);
      ObjectSet(Instance+"_D1_spread",OBJPROP_YDISTANCE,iYPosSpreadInd);
      ObjectSet(Instance+"_D1_spread",OBJPROP_ANCHOR,ANCHOR_CENTER);
      ObjectSetText(Instance+"_D1_spread",sTDISpread,12,"Wingdings",spread_color_HX);
   }

   // Calculate for ECN / Non-ECN brokers
   if (Digits == 5 || Digits == 3)
      convert2pips=Point*10;
   else if (Digits == 4 || Digits == 2)
      convert2pips=Point;

   return(0);
}

//--
// Functions
//--
void Panel_Ratio()
{
   double nHeight=NormalizeDouble(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,1),0);
   double nWidth=NormalizeDouble(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,1),0);
   ratio_display="Panel Ratio: "+DoubleToStr(NormalizeDouble(nWidth/nHeight,2),2);
//   double TdiGreen0=iCustom(Symbol(),0, TDI_Indicator, 13, 0, 34, 2, 0, 7, 0, TDI_Indicator_RSIPrice, 0);
//   double TdiRed0=iCustom(Symbol(),0, TDI_Indicator, 13, 0, 34, 2, 0, 7, 0, TDI_Indicator_TradeSig, 0);
//   ratio_display="  Panel Ratio: "+DoubleToStr(NormalizeDouble(ratio,2),2)+"  Green: "+DoubleToStr(NormalizeDouble(TdiGreen0,1),1)+"  Red: "+DoubleToStr(NormalizeDouble(TdiRed0,1),1);
}

void SetTDICurrent()
{
   double TdiGreen0=iCustom(Symbol(),0, TDI_Indicator, 13, 0, 34, 2, 0, 7, 0, TDI_Indicator_RSIPrice, 0);
   double TdiGreen1=iCustom(Symbol(),0, TDI_Indicator, 13, 0, 34, 2, 0, 7, 0, TDI_Indicator_RSIPrice, 1);
   double TdiRed0=iCustom(Symbol(),0, TDI_Indicator, 13, 0, 34, 2, 0, 7, 0, TDI_Indicator_TradeSig, 0);
   double TdiRed1=iCustom(Symbol(),0, TDI_Indicator, 13, 0, 34, 2, 0, 7, 0, TDI_Indicator_TradeSig, 1);
   double TdiGreenDegrees=(MathArctan(TdiGreen0 - TdiGreen1)*180)/3.1415;
   double TdiRedDegrees=(MathArctan(TdiRed0 - TdiRed1)*180)/3.1415;
   double TdiDegree;
   
   if (TDI_Angle_Type == 0)
   {
      TdiDegree=(TdiRedDegrees+(TdiGreenDegrees*13/34.0))/(1+(13/34.0));
      degree_display="TDI WAvg Angle: "+DoubleToStr(NormalizeDouble(TdiDegree,2),0)+"°";
   }      
   else
   {
      TdiDegree=TdiGreenDegrees/TdiRedDegrees;
      degree_display="TDI Angle Ratio: "+DoubleToStr(NormalizeDouble(TdiDegree,2),2);
   }
   GreenAngle=NormalizeDouble(TdiGreenDegrees,0);
   RedAngle=NormalizeDouble(TdiRedDegrees,0);

   test_TdiDistance=NormalizeDouble(MathAbs(TdiGreen0 - TdiRed0),2);
   if (TdiGreen0 >= TdiRed0 && TdiGreen1 < TdiRed1)
      TdiDistance="Crossed UP";
   else if (TdiRed0 >= TdiGreen0 && TdiRed1 < TdiGreen1)
      TdiDistance="Crossed DOWN";
   else if (test_TdiDistance < TDI_cross_threshold)
      TdiDistance="Approaching";
   else if (test_TdiDistance > TDI_cross_threshold && test_TdiDistance < TDI_normal_threshold)
      TdiDistance="Good";
   else if (test_TdiDistance > TDI_normal_threshold)
      TdiDistance="STRONG";
   else if (test_TdiDistance > 10)
      TdiDistance="DANGER-ZONE";
}

void SetArrowAndZone(int period_HX)
{
   double TdiGreen0_HX=iCustom(Symbol(),period_HX, TDI_Indicator, 13, 0, 34, 2, 0, 7, 0, TDI_Indicator_RSIPrice, 0);
   double TdiGreen1_HX=iCustom(Symbol(),period_HX, TDI_Indicator, 13, 0, 34, 2, 0, 7, 0, TDI_Indicator_RSIPrice, 1);
   double TdiRed0_HX=iCustom(Symbol(),period_HX, TDI_Indicator, 13, 0, 34, 2, 0, 7, 0, TDI_Indicator_TradeSig, 0);
   double TdiRed1_HX=iCustom(Symbol(),period_HX, TDI_Indicator, 13, 0, 34, 2, 0, 7, 0, TDI_Indicator_TradeSig, 1);
   double TdiGreenDegrees_HX=(MathArctan(TdiGreen0_HX - TdiGreen1_HX)*180)/3.1415;
   double TdiRedDegrees_HX=(MathArctan(TdiRed0_HX - TdiRed1_HX)*180)/3.1415;
   double TdiWAvgAngle_HX=(TdiRedDegrees_HX+(TdiGreenDegrees_HX*13/34.0))/(1+(13/34.0));
   double Angle_HX;

   switch (TDI_Angle_Type)
   {
      case 0: Angle_HX=NormalizeDouble(TdiWAvgAngle_HX,0); break;
      case 1: Angle_HX=NormalizeDouble(TdiGreenDegrees_HX,0); break;
      case 2: Angle_HX=NormalizeDouble(TdiRedDegrees_HX,0); break;
   }
   
   if (Angle_HX > 60.0)
   { Tdi_cross_HX=CharToStr(233); slope_color_HX=Arrow_Bull; }
   else if (Angle_HX > 30.0)
   { Tdi_cross_HX=CharToStr(236); slope_color_HX=Arrow_Bull; }
   else if (Angle_HX < -60.0)
   { Tdi_cross_HX=CharToStr(234); slope_color_HX=Arrow_Bear; }
   else if (Angle_HX < -30.0)
   { Tdi_cross_HX=CharToStr(238); slope_color_HX=Arrow_Bear; }
   else
   { Tdi_cross_HX=CharToStr(232); slope_color_HX=Neutral_Arrow; }

   Tdi_zone_HX=CharToStr(110);
   if (TdiGreen0_HX > 74.0)
      zone_color_HX=Wayover_bought;
   else if (TdiGreen0_HX > 68.0)
      zone_color_HX=Over_bought;
   else if (TdiGreen0_HX > 50.0)
      zone_color_HX=Above_fifty;
   else if(TdiGreen0_HX > 32.0)
      zone_color_HX=Below_fifty;
   else if(TdiGreen0_HX > 26.0)
      zone_color_HX=Over_sold;
   else
      zone_color_HX=Wayover_sold;

   double nTDISpread=NormalizeDouble(MathAbs(TdiGreen0_HX - TdiRed0_HX),2);
   if (TdiGreen0_HX >= TdiRed0_HX && TdiGreen1_HX < TdiRed1_HX)
      sTDISpread="È"; // Crossed-Up
   else if (TdiRed0_HX >= TdiGreen0_HX && TdiRed1_HX < TdiGreen1_HX)
      sTDISpread="Ê"; // Crossed-Down
   else if (nTDISpread < TDI_cross_threshold)
      sTDISpread=CharToStr(159);
   else if (nTDISpread > TDI_cross_threshold && nTDISpread < TDI_normal_threshold)
      sTDISpread="l";
   else if (nTDISpread > TDI_normal_threshold)
      sTDISpread="£";
   else if (nTDISpread > 10)
      sTDISpread="N";
}

//--
// Setup main background box
//---
int init()
{
   if (trans_back == false)
   {
      ObjectCreate(Instance+"_PanelBox",OBJ_RECTANGLE_LABEL,1,0,0,0);
      ObjectSet(Instance+"_PanelBox",OBJPROP_CORNER,Panel_Location);
      ObjectSet(Instance+"_PanelBox",OBJPROP_BGCOLOR, Back_Ground_Color);
      ObjectSet(Instance+"_PanelBox",OBJPROP_XDISTANCE, Expand_X+2+iXOffset);
      ObjectSet(Instance+"_PanelBox",OBJPROP_YDISTANCE, 2);
      ObjectSet(Instance+"_PanelBox",OBJPROP_XSIZE, Expand_X);
      if (bShowSpread)
         ObjectSet(Instance+"_PanelBox",OBJPROP_YSIZE, 163);
      else
         ObjectSet(Instance+"_PanelBox",OBJPROP_YSIZE, 145);
      ObjectSet(Instance+"_PanelBox",OBJPROP_BACK,trans_back);
      if (bShowM5)
      {
         ObjectCreate(Instance+"_M5Divider",OBJ_RECTANGLE_LABEL,1,0,0,0);
         ObjectSet(Instance+"_M5Divider",OBJPROP_CORNER,Panel_Location);
         ObjectSet(Instance+"_M5Divider",OBJPROP_COLOR, clrYellow);
         ObjectSet(Instance+"_PanelBox",OBJPROP_BGCOLOR, Back_Ground_Color);
         ObjectSet(Instance+"_M5Divider",OBJPROP_XSIZE, 2);
         ObjectSet(Instance+"_M5Divider",OBJPROP_YSIZE, 80);
         ObjectSet(Instance+"_M5Divider",OBJPROP_BACK, false);
         ObjectSet(Instance+"_M5Divider",OBJPROP_XDISTANCE, 194+iXOffset);
         ObjectSet(Instance+"_M5Divider",OBJPROP_YDISTANCE, 70);
      }
   }
   
   return(0);
}

//--
// Deinit everything
//---
int deinit()
{
   ObjectDelete(Instance+"_PanelBox");
   ObjectDelete(Instance+"_PanelInfo");
   ObjectDelete(Instance+"_TDIAngles");
   ObjectDelete(Instance+"_TDISpread");
   ObjectDelete(Instance+"_M5Divider");

   ObjectDelete(Instance+"_M5_label");
   ObjectDelete(Instance+"_M5_slope");
   ObjectDelete(Instance+"_M5_zone");
   ObjectDelete(Instance+"_M5_spread");
   ObjectDelete(Instance+"_M15_label");
   ObjectDelete(Instance+"_M15_slope");
   ObjectDelete(Instance+"_M15_zone");
   ObjectDelete(Instance+"_M15_spread");
   ObjectDelete(Instance+"_M30_label");
   ObjectDelete(Instance+"_M30_slope");
   ObjectDelete(Instance+"_M30_zone");
   ObjectDelete(Instance+"_M30_spread");
   ObjectDelete(Instance+"_H1_label");
   ObjectDelete(Instance+"_H1_slope");
   ObjectDelete(Instance+"_H1_zone");
   ObjectDelete(Instance+"_H1_spread");
   ObjectDelete(Instance+"_H4_label");
   ObjectDelete(Instance+"_H4_slope");
   ObjectDelete(Instance+"_H4_zone");
   ObjectDelete(Instance+"_H4_spread");
   ObjectDelete(Instance+"_D1_label");
   ObjectDelete(Instance+"_D1_slope");
   ObjectDelete(Instance+"_D1_zone");
   ObjectDelete(Instance+"_D1_spread");

   return(0);
}