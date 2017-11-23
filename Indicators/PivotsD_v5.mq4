
//+-------------------------------------------------------------------------------------------+
//|                                   PivotsD.mq4                                             |                                                        
//+-------------------------------------------------------------------------------------------+ 

#property copyright "Traderathome - public domain code"
#property link      "n/a" 

/*--------------------------------------------------------------------------------------------+
PivotsD: 

This indicator displays pivots for the current day.  It provides for color and line style 
selection of pivot lines, and for color, font style and font size selection of line labels.    

Pivot lines can start at the StartofDay or be full-screen lines.  If the lines start at 
StartofDay, so do the labels.  When lines are full-screen then the labels can be positioned 
anywhere from the left side of the chart to the right of the current candle.  And if you zoom 
in/out on the chart, an activity that will distort the position of the labels, with the next 
incoming data tic labels are restored automatically to the proper position.  Included is the 
ability to independently turn on/off the price display in the line labels and the chart margin.  
But note that MT4 allows right margin price labels to work only for full screen lines. 

Pivots can be calculated using either the "Daily" pivot formula (default), or the "Fibonacci" 
formula that has two added levels.  Included are mid-pivot lines which can be turned on/off.

Background colors can be applied to highlight either, or both, the timeframes for yesterday
and today.  The Day Candle can be shown to the right of the current candle on any TF chart.  
A price label can be shown beside the Day Candle.

The first item in the Indicator Window is the indicator "On/Off" switch (default=true).  By  
turning the indicator display "Off", you do not have to remove the indicator from your chart 
list when not in use, and meanwhile the indicator settings for that chart are preserved.


PivotsD_v2: 

Many "THANKS!" are owed to Domas4 for coding the price labels to be compatible with non-forex 
items!  Set the input to "false" on charts for non-forex items such as Gold, Stocks, etc.


PivotD_v3:

Revised code corrects the failure of pivot lines to display during first time frame of the 
chart at the open of a new day.  The external input for labels font style was changed to allow 
the actual neme of a font style to be typed in.  Thus, more style choices are now available to 
the user.  Arial, Arial Bold and Verdana Bold are recommended, with font sizes 8 to 12.
 
 
PivotD_v4:
Session background boxes for white charts have both been given lighter shades for defaults.
Terminology for label placement, when lines are full screen, has been improved.  Now the user 
selects between 100% left (all the way to the left) and 0% (all the way to the right).  With 
this improvement, when LinePlacement = 2 and Shift_PivotLabels_PerCent_Left = 0, and the lines 
have become full screen, the labels will now be placed to the right.  New code adds a third
line placement option, which allows lines to start at the current candle.  New code also lets
the lines be stopped at the current candle.  The Separator draw is revised so that it is 
subordinate on the chart, just as the pivot lines.  An optional label is added for the 
Separator, showing the day of week.  A Data Box is added. It includes a user input for the 
number of days to be used in calculating average range. The external inputs section is 
reworked for improved clarity and consistency of terminology. 
                                                                              - Traderathome
---------------------------------------------------------------------------------------------*/
#property indicator_chart_window
#property indicator_buffers 5

#property indicator_color1  MidnightBlue
#property indicator_color2  MidnightBlue
#property indicator_color3  MidnightBlue
#property indicator_color4  MidnightBlue
#property indicator_color5  CLR_NONE

#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
/*---------------------------------------------------------------------------------------------
Color Suggestions:

Item                            White Chart         Black Chart   

TodayBoxColor                   White               Black
YesterdayBoxColor               White               Black
PriceLabel_StaticColor          MidnightBlue        Yellow
PriceLabel_UPColor              MidnightBlue        Yellow
PriceLabel_DOWNColor            MidnightBlue        Yellow
PriceLabel_PointerColor         MidnightBlue        Yellow
Central_Pivot_Color             MidnightBlue        Yellow
Resistance_Pivots_Color         MidnightBlue        Yellow
Support_Pivots_Color            MidnightBlue        Yellow
MidPivots_Color                 MidnightBlue        Yellow    
PivotLabels_Color               MidnightBlue        Yellow
SeparatorLines_Color            MidnightBlue        Yellow
SeparatorLabel_Color            MidnightBlue        Yellow
Data_Box_Color                  White               Yellow
---------------------------------------------------------------------------------------------*/
//External Inputs 
extern bool   Indicator_On                   = true;
extern bool   Use_For_Forex                  = true;
extern bool   Use_Day_Formula                = true;
extern string _                              = "";
extern string Part_1                         = "Session Box Settings:";
extern bool   Show_Today_Box                 = true;
extern color  Today_Box_Color                = C'249,249,249';
extern bool   Show_Yesterday_Box             = true;
extern color  Yesterday_Box_Color            = C'239,239,239';
extern string __                             = "";
extern string Part_2                         = "Day Candle & Price Label Settings:";
extern bool   Show_DayCandle                 = true;
extern bool   Show_PriceLabel                = true;
extern color  PriceLabel_StaticColor         = Blue;
extern color  PriceLabel_UPColor             = MidnightBlue;
extern color  PriceLabel_DOWNColor           = MidnightBlue;
extern color  PriceLabel_PointerColor        = MidnightBlue;
extern string PriceLabel_FontStyle           = "Arial Bold";
extern int    PriceLabel_FontSize            = 12;
extern int    Shift_PriceLabel_Right         = 20;
extern int    Shift_DayCandle_right          = 24; 
extern string ___                            = "";
extern string Part_3                         = "Pivot Line Settings:";
extern string note1                          = "Start with fullscreen lines, enter '1'";
extern string note2                          = "Start lines at Day Separator, enter '2'";
extern string note3                          = "Start lines at current candle, enter '3'";
extern int    StartLines                     = 2;
extern bool   EndLines_At_Current_Candle     = false;
extern color  CentralPivot_Color             = MidnightBlue;
extern int    CP_LineStyle_01234             = 0;
extern int    CP_SolidLine_Thickness         = 2;
extern color  Resistance_Pivots_Color        = MidnightBlue;
extern int    R_LineStyle_01234              = 0;
extern int    R_SolidLineThickness           = 2; 
extern color  Support_Pivots_Color           = MidnightBlue;
extern int    S_LineStyle_01234              = 0;
extern int    S_SolidLineThickness           = 2;
extern bool   Show_MidPivots                 = true;
extern color  MidPivots_Color                = MidnightBlue; 
extern int    mP_LineStyle_01234             = 2;    
extern int    mP_SolidLineThickness          = 1;
extern string ____                           = "";
extern string Part_4                         = "Pivot Label Settings:";
extern color  PivotLabels_Color              = MidnightBlue;
extern string PivotLabels_FontStyle          = "arial Bold";
extern int    PivotLabels_Fontsize           = 9; 
extern bool   Show_Price_in_PivotLabels      = true;
extern string note4                          = "Show_RightMargin_Prices and";
extern string note5                          = "Shift_Pivotlabels_PerCent_Left";
extern string note6                          = "work only when lines are fullscreen.";
extern bool   Show_RightMargin_Prices        = true;
extern int    Shift_PivotLabels_PerCent_Left = 50;
extern bool   Subordinate_Labels             = false;
extern string _____                          = "";
extern string Part_5                         = "Today Separator Settings:";
extern bool   Show_Separator                 = true; 
extern color  Separator_Color                = MidnightBlue;
extern int    Separator_LineStyle_01234      = 2;
extern int    Separator_SolidLineThickness   = 2;
extern bool   Show_SeparatorLabel            = true;
extern color  SeparatorLabel_Color           = MidnightBlue; 
extern string SeparatorLabel_FontStyle       = "Arial Bold";
extern int    SeparatorLabel_FontSize        = 9;
extern int    LabelOnChart_TopBot_12         = 2;
extern string ______                         = "";
extern string Part_6                         = "Data Comment Settings:"; 
extern bool   Show_Data_Comment              = true;
extern color  Data_Comment_Background_Color  = C'173,222,252';
extern int    Days_Used_For_Range_Data       = 30;

//Buffers, Constants and Variables
int      fxDigits,CalcPeriod,shift,dow,YesterdayBar,TodayBar;
datetime StartTime;
double   HiPrice,LoPrice,Range,ClosePrice,Pivot,R1,S1,R2,S2,R3,S3,R4,S4,R5,S5;
double   DayHigh[],DayLow[],DayOpen[],DayClose[],Old_Price;
string   Price;

//+-------------------------------------------------------------------------------------------+
//| Indicator Initialization                                                                  |                                                        
//+-------------------------------------------------------------------------------------------+      
int init()
   {
   if (Use_For_Forex)  {string sub=StringSubstr(Symbol(), 3, 3);
      if (sub == "JPY") {fxDigits = 2;} else {fxDigits = 4;}}
      
   SetIndexBuffer(0, DayHigh);
   SetIndexBuffer(1, DayLow);
   SetIndexBuffer(2, DayClose);
   SetIndexBuffer(3, DayOpen);
   
   if (Show_DayCandle){
      for (int i=0;i<4;i++){
         SetIndexStyle(i,DRAW_HISTOGRAM);
         SetIndexShift(i,Shift_DayCandle_right);
         SetIndexLabel(i,"[PivotsD] DayCandle");}}            
   else{for(i=0;i<4;i++) {SetIndexStyle(i,DRAW_NONE);}}      
   return(0);
   }

//+-------------------------------------------------------------------------------------------+
//| Indicator De-initialization                                                               |                                                        
//+-------------------------------------------------------------------------------------------+       
int deinit()
   {   
   int obj_total= ObjectsTotal();  
   for (int k= obj_total; k>=0; k--){
      string name= ObjectName(k); 
      if (StringSubstr(name,0,9)=="[PivotsD]"){ObjectDelete(name);}}
      Comment("");     
   return(0);
   }

//+-------------------------------------------------------------------------------------------+
//| Indicator Start                                                                           |                                                        
//+-------------------------------------------------------------------------------------------+         
int start()
   {
   deinit();if (Indicator_On == false) {return(0);}
   
   //Code for Pivots---------------------------------------------------------------------------
	string pLineStr,pStr,p,s1Str,S1LineStr,s1,r1Str,R1LineStr,r1;
	string s2Str,S2LineStr,s2,r2Str,R2LineStr,r2; 
	string s3Str,S3LineStr,s3,r3Str,R3LineStr,r3;
	string s4Str,S4LineStr,s4,r4Str,R4LineStr,r4;
	string s5Str,S5LineStr,s5,r5Str,R5LineStr,r5;
	string mrLineStr;
	
      if(Use_Day_Formula){ 
         pLineStr  = " DPV";
         S1LineStr = " DS1";
         R1LineStr = " DR1";
         S2LineStr = " DS2";
         R2LineStr = " DR2";
         S3LineStr = " DS3";
         R3LineStr = " DR3";
         mrLineStr = " m";}       
      else{ 
         pLineStr  = " FPV";
         S1LineStr = " FS1";
         R1LineStr = " FR1";
         S2LineStr = " FS2";
         R2LineStr = " FR2";
         S3LineStr = " FS3";
         R3LineStr = " FR3";
         S4LineStr = " FS4";
         R4LineStr = " FR4";
         S5LineStr = " FS5";
         R5LineStr = " FR5";
         mrLineStr = " m";}
    
   CalcPeriod = 1440;       
   shift	= iBarShift(NULL,CalcPeriod,Time[0])+ 1;//default = one period ago	 
	StartTime = iTime(NULL,CalcPeriod,shift);	 
	dow = TimeDayOfWeek(StartTime);string dowStr;
	   switch(dow)
	      {
   	   case 5: dowStr = "Monday";break;
   	   //Monday = Friday value 2 periods ago 
         case 0: shift=iBarShift(NULL,CalcPeriod,Time[0])+2; dowStr = "Monday"; break;
         case 1: dowStr = "Tuesday"; break;       
         case 2: dowStr = "Wednesday"; break;
         case 3: dowStr = "Thursday"; break;
         case 4: dowStr = "Friday"; break;	 	   
         } 	     
 	ClosePrice  = NormalizeDouble(iClose(NULL,CalcPeriod,shift),4);
   HiPrice     = NormalizeDouble (iHigh(NULL,CalcPeriod,shift),4); 
   LoPrice     = NormalizeDouble (iLow(NULL,CalcPeriod,shift),4);
   Range       = HiPrice -  LoPrice;
   Pivot       = NormalizeDouble((HiPrice+LoPrice+ClosePrice)/3,4);
      
   if(Use_Day_Formula){
      R1 = (2*Pivot)-LoPrice;
      S1 = (2*Pivot)-HiPrice;
      R2 = Pivot+(R1-S1);
      S2 = Pivot-(R1-S1); 
      R3 = ( 2.0 * Pivot) + ( HiPrice - ( 2.0 * LoPrice ) );
      S3 = ( 2.0 * Pivot) - ( ( 2.0 * HiPrice ) - LoPrice );}      

   else{ 
      R5 = Pivot + (Range  * 2.618);
      R4 = Pivot + (Range  * 1.618);
      R3 = Pivot +  Range ;     
      R2 = Pivot + (Range  * 0.618);
      R1 = Pivot + (Range  * 0.382);
      S1 = Pivot - (Range  * 0.382);      
      S2 = Pivot - (Range  * 0.618);       
      S3 = Pivot -  Range ;     
      S4 = Pivot - (Range  * 1.618);    
      S5 = Pivot - (Range  * 2.618);}
    
   //Main Pivots-------------------------------------------------------------------------------   
   if(CP_LineStyle_01234>0){CP_SolidLine_Thickness=0;}
   if(R_LineStyle_01234>0){R_SolidLineThickness=0;} 
   if(S_LineStyle_01234>0){S_SolidLineThickness=0;}
  
   drawLine("R3", R3, Resistance_Pivots_Color,R_LineStyle_01234,R_SolidLineThickness); 
   drawLabel( R3LineStr,R3,PivotLabels_Color);
   drawLine("R2", R2, Resistance_Pivots_Color,R_LineStyle_01234,R_SolidLineThickness);
   drawLabel(R2LineStr,R2,PivotLabels_Color);
   drawLine("R1", R1, Resistance_Pivots_Color,R_LineStyle_01234,R_SolidLineThickness);
   drawLabel(R1LineStr,R1,PivotLabels_Color);
   drawLine("PIVOT", Pivot,CentralPivot_Color,CP_LineStyle_01234,CP_SolidLine_Thickness);
   drawLabel(pLineStr, Pivot,PivotLabels_Color);
   drawLine("S1", S1, Support_Pivots_Color,S_LineStyle_01234,S_SolidLineThickness);
   drawLabel(S1LineStr,S1,PivotLabels_Color);
   drawLine("S2", S2, Support_Pivots_Color,S_LineStyle_01234,S_SolidLineThickness);
   drawLabel(S2LineStr,S2,PivotLabels_Color);
   drawLine("S3", S3, Support_Pivots_Color,S_LineStyle_01234,S_SolidLineThickness);
   drawLabel(S3LineStr ,S3,PivotLabels_Color);
     
   if(Use_Day_Formula==false){
   drawLine("R5", R5, Resistance_Pivots_Color,R_LineStyle_01234,R_SolidLineThickness); 
   drawLabel( R5LineStr,R5,PivotLabels_Color);
   drawLine("R4", R4, Resistance_Pivots_Color,R_LineStyle_01234,R_SolidLineThickness);
   drawLabel(R4LineStr,R4,PivotLabels_Color);
   drawLine("S4", S4, Support_Pivots_Color,S_LineStyle_01234,S_SolidLineThickness);
   drawLabel(S4LineStr,S4,PivotLabels_Color);
   drawLine("S5", S5, Support_Pivots_Color,S_LineStyle_01234,S_SolidLineThickness);
   drawLabel(S5LineStr ,S5,PivotLabels_Color);}
   
   //Mid Pivots--------------------------------------------------------------------------------
   if(Show_MidPivots){
   if(mP_LineStyle_01234>0){mP_SolidLineThickness=0;}
   
   drawLine("MR3", (R2+R3)/2, MidPivots_Color,mP_LineStyle_01234,mP_SolidLineThickness); 
   drawLabel(mrLineStr+"R3",(R2+R3)/2,PivotLabels_Color);
   drawLine("MR2", (R1+R2)/2, MidPivots_Color,mP_LineStyle_01234,mP_SolidLineThickness); 
   drawLabel(mrLineStr+"R2",(R1+R2)/2,PivotLabels_Color); 
   drawLine("MR1", (Pivot+R1)/2, MidPivots_Color,mP_LineStyle_01234,mP_SolidLineThickness); 
   drawLabel(mrLineStr+"R1",(Pivot+R1)/2,PivotLabels_Color);
   drawLine("MS1", (Pivot+S1)/2, MidPivots_Color,mP_LineStyle_01234,mP_SolidLineThickness); 
   drawLabel(mrLineStr+"S1",(Pivot+S1)/2,PivotLabels_Color);
   drawLine("MS2", (S1+S2)/2, MidPivots_Color,mP_LineStyle_01234,mP_SolidLineThickness); 
   drawLabel(mrLineStr+"S2",(S1+S2)/2,PivotLabels_Color);
   drawLine("MS3", (S2+S3)/2, MidPivots_Color,mP_LineStyle_01234,mP_SolidLineThickness); 
   drawLabel(mrLineStr+"S3",(S2+S3)/2,PivotLabels_Color);
     
   if(Use_Day_Formula==false){   
   drawLine("MR5", (R4+R5)/2, MidPivots_Color,mP_LineStyle_01234,mP_SolidLineThickness); 
   drawLabel(mrLineStr+"R5",(R4+R5)/2,PivotLabels_Color);
   drawLine("MR4", (R3+R4)/2, MidPivots_Color,mP_LineStyle_01234,mP_SolidLineThickness); 
   drawLabel(mrLineStr+"R4",(R3+R4)/2,PivotLabels_Color); 
   drawLine("MS4", (S3+S4)/2, MidPivots_Color,mP_LineStyle_01234,mP_SolidLineThickness); 
   drawLabel(mrLineStr+"S4",(S3+S4)/2,PivotLabels_Color);
   drawLine("MS5", (S4+S5)/2, MidPivots_Color,mP_LineStyle_01234,mP_SolidLineThickness); 
   drawLabel(mrLineStr+"S5",(S4+S5)/2,PivotLabels_Color);}}
     
   //Show Today Separator vertical line--------------------------------------------------------
   if(Show_Separator){
      if(Show_SeparatorLabel){
      double top = WindowPriceMax();
      double bottom = WindowPriceMin();
     	double scale = top - bottom;	
      double YadjustTop = scale/5000; //250;
      double YadjustBot = scale/(350/SeparatorLabel_FontSize); 	
      double level = top - YadjustTop;  if (LabelOnChart_TopBot_12==2){level = bottom + YadjustBot;}}
   Separator(" Today Separator", dowStr, iTime(NULL, PERIOD_D1,0),Separator_Color,
   Separator_LineStyle_01234, Separator_SolidLineThickness, level);}   
          
   //Code for TF Background colors and Day Candle----------------------------------------------
   int digits = MarketInfo(Symbol(),MODE_DIGITS);
   double modifier = 1; if (digits==3 || digits==5) modifier = 10.0;
   
   //Define today's bar and it's data                     
   TodayBar          = iBarShift(NULL,PERIOD_D1,Time[0]);
   double HiToday    = iHigh (NULL,PERIOD_D1,TodayBar);
   double LoToday    = iLow  (NULL,PERIOD_D1,TodayBar); 
   double open       = iOpen( NULL,PERIOD_D1,TodayBar);
   double current    = iClose(NULL,PERIOD_D1,TodayBar);
   double change     = (current-iOpen(NULL,PERIOD_D1,TodayBar))/(Point*modifier);
   double startToday = iTime(NULL,PERIOD_D1,TodayBar);
   double endToday   = iTime(NULL,0,0);
      
   //Define yesterday's bar and it's data              
   YesterdayBar = iBarShift(NULL,PERIOD_D1,Time[(24*60)/Period()]);  
   double HiYesterday    = iHigh (NULL,PERIOD_D1,YesterdayBar);
   double LoYesterday    = iLow  (NULL,PERIOD_D1,YesterdayBar);
   double startYesterday = iTime(NULL,PERIOD_D1,YesterdayBar);
   double endYesterday   = iTime(NULL,PERIOD_D1,TodayBar);
      
   if(Show_DayCandle){
      int shift = 0; if (change>0) {DayHigh[shift] = HiToday;  DayLow[shift] = LoToday;}            
      else  {DayHigh[shift] = LoToday; DayLow[shift] = HiToday;}            
      DayClose[shift] = current; DayOpen[shift] = open+0.000001;                  
      int i,limit; for(i=0,limit=Bars-1;i<4;i++) SetIndexDrawBegin(i,limit);}
      
   if (Show_Today_Box)   
   colorTFbox ("[PivotsD] TFBoxToday", startToday, endToday, HiToday, LoToday, Today_Box_Color);  
   
   if (Show_Yesterday_Box)   
   colorTFbox ("[PivotsD] TFBoxYesterday", startYesterday, endYesterday, HiYesterday, LoYesterday, Yesterday_Box_Color);   
   
   //Code for price label----------------------------------------------------------------------
   if(Show_PriceLabel)
   {
   //Clear chart of previous label    
   int obj_total= ObjectsTotal();  
   for (int k= obj_total; k>=0; k--){
      string name= ObjectName(k);    
      if(StringSubstr(name,9,6)==" Price"){ObjectDelete(name);}}   
       
   //Get x,y co-ordinates for labels
   double x = Time[0];
   double y1 = Bid;
   double y2 = Bid;
	
   //Assign the Price & Colors
   int Color1 = PriceLabel_PointerColor;
   int Color2 = PriceLabel_StaticColor; 
   if (Bid > Old_Price) {Color2 = PriceLabel_UPColor;}
   if (Bid < Old_Price) {Color2 = PriceLabel_DOWNColor;}
   Old_Price=Bid;
     
   //Define the standard digits used for Price
   if (Use_For_Forex) {Price=DoubleToStr(Bid, fxDigits);}
   else {Price=DoubleToStr(Bid, Digits);}  

   //Prepare to construct labels 
   string Tab1; for(i=1; i<=Shift_PriceLabel_Right; i++) {Tab1 = Tab1 + " ";} 
   string Text1 = Tab1 +  "^";
   string Text2 = Tab1 + "             " + Price; //15
 
   //Construct/move labels floating at bid 
   string pointer = "[PivotsD] Pointer";      
   if(ObjectFind(pointer) != 0){
      ObjectCreate(pointer, OBJ_TEXT, 0, x, y1);
      ObjectSetText(pointer, Text1, PriceLabel_FontSize, PriceLabel_FontStyle, Color1);}
   else {ObjectMove(pointer, 0, x, y1);}
    
   string price = "[PivotsD] Price";            
   if(ObjectFind(price) != 0){
      ObjectCreate(price, OBJ_TEXT, 0, x, y2);
      ObjectSetText(price, Text2, PriceLabel_FontSize, PriceLabel_FontStyle, Color2);}
   else {ObjectMove(price, 0, x, y2);}                         	   	      
   }
      
   //Data Box section--------------------------------------------------------------------------
   if (Show_Data_Comment){
      string dComment = "[PivotsD] Data Box";       
      ObjectCreate(dComment, OBJ_LABEL, 0, 0, 0, 0, 0);
      ObjectSetText(dComment, "g", 92, "Webdings");
      ObjectSet(dComment, OBJPROP_CORNER, 0);
      ObjectSet(dComment, OBJPROP_XDISTANCE, 0);
      ObjectSet(dComment, OBJPROP_YDISTANCE, 13 );      
      ObjectSet(dComment, OBJPROP_COLOR, Data_Comment_Background_Color);
      ObjectSet(dComment, OBJPROP_BACK, false);
      //Daily Average Range
      int Ra=0, RaP=Days_Used_For_Range_Data;
      for(i=0; i<RaP; i++) {Ra = Ra + ((iHigh(NULL,PERIOD_D1,i)- iLow(NULL,PERIOD_D1,i))/Point);}
      Ra = ((Ra/RaP)+1); //Add "1" to balance excessive rounding down  	
      //Get time (H/M/S) remaining on current candle		
   	int h,m,s,t;    
      t=Time[0]+(Period()*60)-CurTime();
      s=t%60; string seconds = (s); if (s<10) {seconds = ("0"+seconds);} 
      m=(t-t%60)/60;   
      for(i=0; i<24; i++){
         if(m>=60){m=m-60;h=h+1;}
         string minutes = (m); if (m<10) {minutes = ("0"+minutes);}   
         string hours = (h); if (h<10) {hours = ("0"+hours);} 
         string timeleft = (minutes+":"+seconds);
         if (h>=1) {timeleft = (hours+":"+minutes+":"+seconds);}
         if (Period()>1440){timeleft = NULL;}}         
      //Spread
      int spread = MarketInfo(Symbol(), MODE_SPREAD); 
      //Set up Comment string     
      string C= "\n ----------  PivotsD  ----------\n";  
      C=C + "   Range  Today:    "+DoubleToStr(MathRound((HiToday-LoToday)/Point),0)+ "\n";  
      C=C + "         Yesterday:    "+DoubleToStr(MathRound((HiYesterday-LoYesterday)/Point),0) + "\n";            
      C=C + "   "+Days_Used_For_Range_Data+" Day Range:    "+ Ra + "\n";
      C=C + "Time to next bar:    " + timeleft + "\n";       
      C=C + "             Spread:    " + spread + "\n"; 
      C=C + "      Swap  Long:    "+DoubleToStr(MarketInfo(Symbol(),MODE_SWAPLONG),2) + "\n";
      C=C + "     Swap  Short:    "+DoubleToStr(MarketInfo(Symbol(),MODE_SWAPSHORT),2) + "\n";                 
      Comment(C);}
         
   //End of program computations---------------------------------------------------------------        
   return(0);
   } 

//+-------------------------------------------------------------------------------------------+
//| drawLabel sub-routine to name and draw labels for pivot lines                             |                                                        
//+-------------------------------------------------------------------------------------------+ 
void drawLabel(string text, double level, color Color)
   {
   //Determine start time for the label
   if (Shift_PivotLabels_PerCent_Left < 0) {Shift_PivotLabels_PerCent_Left =0;}
   if (Shift_PivotLabels_PerCent_Left > 100) {Shift_PivotLabels_PerCent_Left =100;}
   int A = WindowFirstVisibleBar();
   int L = A*(Shift_PivotLabels_PerCent_Left)/100;
   int AA = Time[L];
   if(StartLines==2){
      AA = iTime(NULL,PERIOD_D1,0)+1;//StartofDay time
      //If labels about to go off-screen, switch to Fullscreen setting  
      if(AA<=iTime(NULL,0,WindowFirstVisibleBar()))AA=Time[L];}
   
   //Assign label name to the pivot line labels
   string plabel = "[PivotsD] " + text + " Label";
                             
   //Define the digits used for price in label
   if (Use_For_Forex) {Price=DoubleToStr(level, fxDigits);}
   else {Price=DoubleToStr(level, Digits);}    
          
   //Label content is 'text' unless price is to be shown
   if (Show_Price_in_PivotLabels && StrToInteger(text)==0) {text = text + "   " + Price;} 

   //Set any additional text spacing required for labels  
   if(StartLines==2){
      if(iTime(NULL,PERIOD_D1,0) >= iTime(NULL,0,WindowFirstVisibleBar())){
         if(Show_Price_in_PivotLabels){text="                          "+text;}//26
         if(Show_Price_in_PivotLabels==false){text = "           " + text;}}//11 
      if(AA==Time[L] && Shift_PivotLabels_PerCent_Left == 0){
         text =  "                 " + text;}//17
      if(iTime(NULL,0,WindowFirstVisibleBar()) >= iTime(NULL,PERIOD_D1,0)){
         if(Show_Price_in_PivotLabels){text="                                 "+text;}//33
         if(Show_Price_in_PivotLabels==false){text = "                    " + text;}}}//20 
          
   if(StartLines==3) {
      AA = Time[0];
      if(Show_Price_in_PivotLabels){text="                                 "+text;}//33
      if(Show_Price_in_PivotLabels==false){text = "                    " + text;}}//20                
                      
   else if (Shift_PivotLabels_PerCent_Left == 0){
      text = "                                                  " + text;}//50
       
   else if (Shift_PivotLabels_PerCent_Left == 100){
      if(Show_Price_in_PivotLabels){text="                                 "+text;}//33
      if(Show_Price_in_PivotLabels==false){text = "                    " + text;}}//20       
    
   //Draw the labels
   if(ObjectFind(plabel) != 0){      
      ObjectCreate(plabel, OBJ_TEXT, 0, AA, level);       
      ObjectSetText(plabel, text, PivotLabels_Fontsize, PivotLabels_FontStyle, Color);
      ObjectSet(plabel, OBJPROP_BACK, false);
      if(Subordinate_Labels) {ObjectSet(plabel, OBJPROP_BACK, true);}} 
   else{ObjectMove(plabel, 0, AA, level);}            
   }

//+-------------------------------------------------------------------------------------------+
//| drawline sub-routine to name and draw pivot lines                                         |                                                        
//+-------------------------------------------------------------------------------------------+      
void drawLine(string text, double level, color Color, int linestyle, int thickness)
   {
   int AA, AB;
   int A1 = iTime(NULL,0,WindowFirstVisibleBar()); 
   int A2 = iTime(NULL,PERIOD_D1,0);
   int A3 = Time[1]; if(Time[1] >= A2) {A3 = A2;}   
   int A4 = Time[1];
   int A5 = Time[0];
   int a = linestyle;
   int b = thickness;
   int c =1; if (a==0)c=b; 
   int Z= OBJ_TREND, F= false;
   string pline = "[PivotsD] " + text + " Line";
          
   //Use Horizontal Line format for StartLine 1.
   if(StartLines==1){{AA=A1; AB=A5; F=true;}
      if(Show_RightMargin_Prices){Z = OBJ_HLINE;}       
      if(EndLines_At_Current_Candle){AB=A1; AA=A5; Z= OBJ_TREND; F=false;}}
      
   //Use Trend Line format for startLine 2.    
   if(StartLines==2){{AA= A3; AB= A5; Z= OBJ_TREND; F= true;}
      //But if lines have become full screen over time, switch back to Horizontal Line format.
      if(A1 >= A2){AA= A1; AB= A5; Z= OBJ_HLINE;}   
      if(EndLines_At_Current_Candle){AB=A3; AA=A5;Z = OBJ_TREND;F=false;}}

   if(StartLines==3) {AA=A4; AB=A5; Z= OBJ_TREND; F= true;}
           
   if(ObjectFind(pline) != 0){
      ObjectCreate(pline, Z, 0, AA, level, AB, level);                            
      ObjectSet(pline, OBJPROP_STYLE, a);              
      ObjectSet(pline, OBJPROP_WIDTH, c);     
      ObjectSet(pline, OBJPROP_COLOR, Color);
      ObjectSet(pline, OBJPROP_BACK, true);
      ObjectSet(pline, OBJPROP_RAY, F);}
   else{      
      ObjectMove(pline, 1, AB,level);
      ObjectMove(pline, 0, AA, level);}   
   }

//+-------------------------------------------------------------------------------------------+
//| colorTFbox sub-routine to draw colored background for yesterday & today sessions          |                                                 
//+-------------------------------------------------------------------------------------------+      
void colorTFbox (string name, double starttime, double endtime, double high, double low, color Color)
   {
   string TFbox = "[PivotsD] " + name;
   if (ObjectFind(TFbox) != 0){
      ObjectCreate(TFbox,OBJ_RECTANGLE,0,0,0);
      ObjectSet(TFbox,OBJPROP_TIME1,starttime);
      ObjectSet(TFbox,OBJPROP_TIME2,endtime);
      ObjectSet(TFbox,OBJPROP_PRICE1,high);
      ObjectSet(TFbox,OBJPROP_PRICE2,low);
      ObjectSet(TFbox,OBJPROP_COLOR,Color);}
   else{      
      ObjectMove(TFbox, 1, starttime, high);
      ObjectMove(TFbox, 0, endtime, low);}                             
   }

//+-------------------------------------------------------------------------------------------+
//| Separator sub-routine to name and draw Today Separator line and label                     |          
//+-------------------------------------------------------------------------------------------+   
void Separator(string name, string text, datetime T, color Color, int linestyle, int thickness, double level) 
   {
   int a = linestyle;
   int b = thickness;
   int c =1; if (a==0)c=b;    
   string vline= "[PivotsD] " + name, vlabel = vline + " Label";
   
   if (ObjectFind(vline) != 0){ 
      ObjectCreate(vline, OBJ_TREND, 0, T, 0, T, 100);
      ObjectSet(vline, OBJPROP_STYLE, a);    
      ObjectSet(vline, OBJPROP_WIDTH, c);
      ObjectSet(vline, OBJPROP_COLOR, Color);
      ObjectSet(vline, OBJPROP_BACK, true); }
   else{
      ObjectMove(vline, 0, T, 0); 
      ObjectMove(vline, 1, T, 100);}  
  
   if(Show_SeparatorLabel){                         
      if (ObjectFind(vlabel) != 0) {
         ObjectCreate (vlabel, OBJ_TEXT, 0, T, level);
         ObjectSetText(vlabel, text, SeparatorLabel_FontSize, SeparatorLabel_FontStyle, SeparatorLabel_Color); 
         ObjectSet(vlabel, OBJPROP_BACK, false);
         if(Subordinate_Labels) {ObjectSet(vlabel, OBJPROP_BACK, true);}}        
      else{ObjectMove(vlabel, 0, T, level);}}                              
   }

//+-------------------------------------------------------------------------------------------+
//| End of Program                                                                            |                                                        
//+-------------------------------------------------------------------------------------------+      

