//+------------------------------------------------------------------+
//|                                          OzFX smD1 iLines v4.mq4 |
//|                                                         SwingMan |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "SwingMan"
#property link      ""

#property indicator_chart_window

//====================================================================
// ### HISTORY Signals (OzFX smD1 iSignals v2 / SwingMan)
// v1 - Source Code = OzFX Daily Signals X-02RR 
//                    #property copyright "Copyright © 2008, DGC"
//                    #property link      "http://www.ozfx.com.au/"
//                  = Ronald Raygun codes  
// v2
//    - Alert options for RegularCode and AESCode
//    - TickValue and MarginRequired
//    - Check ShiftEntry only =0 or =1
// ### HISTORY Lines 
// v1 - Default ShiftEntry = 1
// v2 - use ATR for the lines
// v3 - no repaint version ...
// v4 - n targets, statistics
//====================================================================

//---- extern inputs -------------------------------------------------
extern int ShiftEntry = 0;
extern int StopLoss = 80;
extern int firstTarget = 40;
extern int stepTarget = 40;
extern bool CalculateLinesWithATR = false;
extern bool Show_Lines_RegularCode = true;
extern bool Draw_Lines = true;
extern int NumberOfTargets = 4;
extern int Period_ATR = 21;
extern double ATRfactor_StopLoss = 1.0;
extern double ATRfactor_firstTarget = 0.50;
extern double ATRfactor_stepTarget = 0.50;
//##extern bool Show_TickValueAndMargin = false;
//extern bool SendAlert_LineCrosses = false;
//--------------------------------------------------------------------


#property indicator_buffers 6
#property indicator_color1 LawnGreen   // TP
#property indicator_color2 LawnGreen   // TP
#property indicator_color3 LawnGreen   // TP
#property indicator_color4 LawnGreen   // TP
#property indicator_color5 Gold    // Entry
#property indicator_color6 Red // SL

//---- constants

//---- buffers
double bufferSL[], bufferENTRY[], bufferTP1[], bufferTP2[], bufferTP3[], bufferTP4[], bufferTP5[];
double atr[];

//---- variables
int Spread;
int iLastRegular, iLastAES, k;
double dEntryPriceRegular, dEntryPriceAES;
string IndicatorName;
double value_StopLoss, value_firstTarget, value_stepTarget;
bool bLineDrawed, bStartOK;
int oldRegularCode, oldAEScode;
int nSignals;
int crossSL, crossTP1, crossTP2, crossTP3, crossTP4, crossTP5;
int lastLevel;
double plusPoints, minusPoints;
datetime FirstTime;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   //if (Period() == PERIOD_D1) NumberOfTargets = 4; else
   //if (Period() <= PERIOD_H4) NumberOfTargets = 2;
   nSignals = 0;
   lastLevel = 0;
   plusPoints = 0;
   minusPoints = 0;
   crossSL = 0;
   crossTP1 = 0;
   crossTP2 = 0;
   crossTP3 = 0;
   crossTP4 = 0; 
   crossTP5 = 0;
   Spread = MarketInfo(Symbol(), MODE_SPREAD);
   FirstTime = 0;
  
   bStartOK = true;
   if (NumberOfTargets <= 0 || NumberOfTargets > 4) {
     Alert("NumberOfTargets between 1 and 4.");
     bStartOK = false;
     return(-1);    
   }
   if (ShiftEntry < 0 || ShiftEntry > 1) {
     Alert("Allowed ShiftEntry only 0 or 1.");
     bStartOK = false;
     return(-1); 
   }
   IndicatorName = "OzFX smD1 iLines v4";
   ShowResults();
   IndicatorDigits(Digits);   

//---- arrays
   ArraySetAsSeries(atr,true);   
   ArraySetAsSeries(bufferTP5,true);
   
//---- lines
   SetIndexBuffer(0, bufferTP1);
   SetIndexBuffer(1, bufferTP2);   
   SetIndexBuffer(2, bufferTP3);     
   SetIndexBuffer(3, bufferTP4);  
   SetIndexBuffer(4, bufferENTRY);  
   SetIndexBuffer(5, bufferSL);  

//---- entry and stop loss lines
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,2);
   SetIndexStyle(5,DRAW_LINE,STYLE_SOLID,1);   
   SetIndexLabel(4, "ENTRY");
   SetIndexLabel(5, "StopLoss");      

//---- levels
   if (Draw_Lines) {
   if (NumberOfTargets == 4) {  
      SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);      
      SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1);
      SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1);      
      SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,1);
      SetIndexLabel(0, "TargetPrice 1"); 
      SetIndexLabel(1, "TargetPrice 2");
      SetIndexLabel(2, "TargetPrice 3"); 
      SetIndexLabel(3, "TargetPrice 4");   
   } else
   if (NumberOfTargets == 3) {  
      SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
      SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1);
      SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1);      
      SetIndexStyle(3,DRAW_NONE);
      SetIndexLabel(0, "TargetPrice 1"); 
      SetIndexLabel(1, "TargetPrice 2");
      SetIndexLabel(2, "TargetPrice 3"); 
      SetIndexLabel(3, NULL);   
   } else
   if (NumberOfTargets == 2) {  
      SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
      SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
      SetIndexLabel(0, "TargetPrice 1"); 
      SetIndexLabel(1, "TargetPrice 2");
      SetIndexLabel(2, NULL); 
      SetIndexLabel(3, NULL);   
   } else
   if (NumberOfTargets == 1) {  
      SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
      SetIndexLabel(0, "TargetPrice 1"); 
      SetIndexLabel(1, NULL);
      SetIndexLabel(2, NULL); 
      SetIndexLabel(3, NULL);   
   }
   } else {
      SetIndexStyle(0,DRAW_NONE);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
      SetIndexStyle(4,DRAW_NONE);
      SetIndexStyle(5,DRAW_NONE);
      SetIndexLabel(0, NULL); 
      SetIndexLabel(1, NULL);
      SetIndexLabel(2, NULL); 
      SetIndexLabel(3, NULL);      
      SetIndexLabel(4, NULL); 
      SetIndexLabel(5, NULL);      
   } 
         
//---- variables
   value_StopLoss    = StopLoss*Point;
   value_firstTarget = firstTarget*Point;
   value_stepTarget  = stepTarget*Point;
//----
   Delete_TextObjects();
   return(0);
}
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{  
   Delete_TextObjects();
   Comment("");
   Sleep(300);
   Delete_TextObjects();
   return(0);
}
  
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   if (bStartOK == false) return(-1); 
   ArrayResize(atr,Bars);
   ArrayResize(bufferTP5,Bars);      
   
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0) return(-1); 
   int limit=Bars-counted_bars;
//----
   for (k = Bars - 205; k >= 0; k --)
   {      
      //if (ShiftEntry == 0) double dPrice = Close[k]; else dPrice = Open[k];
      double dPrice = Open[k];
      
//  OZFX REGULAR CODE  //
//---------------------//
      if (iAC(Symbol(), 0, k + ShiftEntry) > 0 &&
          iAC(Symbol(), 0, k + ShiftEntry) > iAC(Symbol(), 0, k + 1 + ShiftEntry) &&
          iStochastic(Symbol(), 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, k + ShiftEntry) > 50)
      {
         /*if (iLastRegular != 1) {
            if (Show_Lines_RegularCode) Set_TradingLines(true, k, 1, dEntryPrice);
         } else  
            if (Show_Lines_RegularCode) Set_TradingLines(false, k, 1, dEntryPrice);*/
         iLastRegular = 1;
         dEntryPriceRegular  = dPrice;
      }   
      
      if (iAC(Symbol(), 0, k + ShiftEntry) < 0 &&
          iAC(Symbol(), 0, k + ShiftEntry) < iAC(Symbol(), 0, k + 1 + ShiftEntry) &&
          iStochastic(Symbol(), 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, k + ShiftEntry) < 50)
      {
         /*if (iLastRegular != -1) {
            if (Show_Lines_RegularCode) Set_TradingLines(true, k, -1, dEntryPrice);
         }else  
            if (Show_Lines_RegularCode) Set_TradingLines(false, k, -1, dEntryPrice);*/
         iLastRegular = -1;
         dEntryPriceRegular  = dPrice;
      } 
      //--- draw
      if (Show_Lines_RegularCode) {
         if (iLastRegular != oldRegularCode) {
            if (iLastRegular == 1) Set_TradingLines(true, k, 1, dEntryPriceRegular); else            
            if (iLastRegular ==-1) Set_TradingLines(true, k, -1, dEntryPriceRegular);            
         }
         else
           Set_TradingLines(false, k, 1, dEntryPriceRegular);
            
      }
      oldRegularCode = iLastRegular; 

//  OZFX AES CODE  //
//-----------------//
      if (iAC(Symbol(), 0, k + ShiftEntry) > iAC(Symbol(), 0, k + 1 + ShiftEntry) &&
          iStochastic(Symbol(), 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, k + ShiftEntry)
          > iStochastic(Symbol(), 0, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, k + ShiftEntry))
      {
         /*if (iLastAES != 0.7) {
            if (Show_Lines_RegularCode == false) Set_TradingLines(true, k, 1, dEntryPrice);
         } else 
            if (Show_Lines_RegularCode == false) Set_TradingLines(false, k, 1, dEntryPrice);*/
         iLastAES = 1;
         dEntryPriceAES  = dPrice;
      }   
      
      if (iAC(Symbol(), 0, k + ShiftEntry) < iAC(Symbol(), 0, k + 1 + ShiftEntry) &&
          iStochastic(Symbol(), 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, k + ShiftEntry)
          < iStochastic(Symbol(), 0, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, k + ShiftEntry))
      {
         /*if (iLastAES != -0.7) {
            if (Show_Lines_RegularCode == false) Set_TradingLines(true, k, -1, dEntryPrice);
         } else 
            if (Show_Lines_RegularCode == false) Set_TradingLines(false, k, -1, dEntryPrice);*/
         iLastAES = -1;
         dEntryPriceAES  = dPrice;
      }   
      //--- draw
      if (Show_Lines_RegularCode == false) {
         if (iLastAES != oldAEScode) {
            if (iLastAES == 1) Set_TradingLines(true, k, 1, dEntryPriceAES); else            
            if (iLastAES ==-1) Set_TradingLines(true, k, -1, dEntryPriceAES);
         }
         else
           Set_TradingLines(false, k, 1, dEntryPriceAES);
            
      }      
      oldAEScode = iLastAES;
      
//  statistic levels      //
//------------------------//
      Get_StatisticLevels(k);
      if (k==0) {
         Write_LevelTexts();
         Write_StatisticLevels();
      }
      
//  lines          //
//-----------------//
//if (k==0) {
//Print("limit=",limit,"  counted_bars=",counted_bars,"  bLineDrawed=",bLineDrawed,"  dEntryPrice=",dEntryPrice);
//}   
      /*if (bLineDrawed) 
        bLineDrawed = false;
      else {
        if (MathAbs(dEntryPrice - bufferENTRY[k]) < 0.00001)
          Set_TradingLines(false, k, -1, dEntryPrice);
        else if(k==0)
          Set_TradingLines(true, k, iLastRegular, dEntryPrice);
      }*/  
   }   
//----
   return(0);
}
//+------------------------------------------------------------------+


//--------------------------------------------------------------------
//   Get Statistic Levels
//--------------------------------------------------------------------
void Get_StatisticLevels(int i)
{
//if (Time[i] < D'2008.02.26 00:00') return;
   //-- new level
   if (bufferENTRY[i] != bufferENTRY[i+1]) {
      lastLevel = 0;
      nSignals++;
      if (FirstTime == 0) FirstTime= Time[i];
   } else

   //-- check level crossings
   {
      //-- long trading
      if ( (Show_Lines_RegularCode && iLastRegular == 1) || (Show_Lines_RegularCode==false && iLastAES == 1) ) {         
         if (lastLevel == 0) {
            if (Low[i]  < bufferSL[i])  {lastLevel=-1; crossSL++; minusPoints = minusPoints + 5*MathAbs(bufferSL[i] - bufferENTRY[i]);}
            if (High[i] > bufferTP1[i]) {lastLevel=1; crossTP1++; plusPoints = plusPoints + MathAbs(bufferTP1[i] - bufferENTRY[i]);}
         }
         if (lastLevel == 1) {
            if (High[i] > bufferTP2[i]) {lastLevel=2; crossTP2++; plusPoints = plusPoints + MathAbs(bufferTP1[i] - bufferENTRY[i]);}
         }
         if (lastLevel == 2) {
            if (High[i] > bufferTP3[i]) {lastLevel=3; crossTP3++; plusPoints = plusPoints + MathAbs(bufferTP1[i] - bufferENTRY[i]);}
         }
         if (lastLevel == 3) {
            if (High[i] > bufferTP4[i]) {lastLevel=4; crossTP4++; plusPoints = plusPoints + MathAbs(bufferTP1[i] - bufferENTRY[i]);}
         }
         if (lastLevel == 4) {
            if (High[i] > bufferTP5[i]) {lastLevel=5; crossTP5++; plusPoints = plusPoints + MathAbs(bufferTP1[i] - bufferENTRY[i]);}
         }
      }
      //-- short trading
      if ( (Show_Lines_RegularCode && iLastRegular == -1) || (Show_Lines_RegularCode==false && iLastAES == -1) ) { 
         if (lastLevel == 0) {
            if (Low[i]  > bufferSL[i])  {lastLevel=-1; crossSL++; minusPoints = minusPoints + 5*MathAbs(bufferSL[i] - bufferENTRY[i]);}
            if (High[i] < bufferTP1[i]) {lastLevel=1; crossTP1++; plusPoints = plusPoints + MathAbs(bufferTP1[i] - bufferENTRY[i]);}
         }
         if (lastLevel == 1) {
            if (High[i] < bufferTP2[i]) {lastLevel=2; crossTP2++; plusPoints = plusPoints + MathAbs(bufferTP1[i] - bufferENTRY[i]);}
         }
         if (lastLevel == 2) {
            if (High[i] < bufferTP3[i]) {lastLevel=3; crossTP3++; plusPoints = plusPoints + MathAbs(bufferTP1[i] - bufferENTRY[i]);}
         }
         if (lastLevel == 3) {
            if (High[i] < bufferTP4[i]) {lastLevel=4; crossTP4++; plusPoints = plusPoints + MathAbs(bufferTP1[i] - bufferENTRY[i]);}
         }
         if (lastLevel == 4) {
            if (High[i] < bufferTP5[i]) {lastLevel=5; crossTP5++; plusPoints = plusPoints + MathAbs(bufferTP1[i] - bufferENTRY[i]);}
         }
      }
   }
}


//--------------------------------------------------------------------
//   Trading lines
//--------------------------------------------------------------------
void Set_TradingLines(bool ChangeDirection, int i, int sign, double EntryPrice)
{
   if (ChangeDirection) {
     if (CalculateLinesWithATR) {
         double dATR = iATR(Symbol(), 0, Period_ATR, i+1);
         value_StopLoss    = dATR * ATRfactor_StopLoss;
         value_firstTarget = dATR * ATRfactor_firstTarget;
         value_stepTarget  = dATR * ATRfactor_stepTarget;
      } 
      else
      {
         value_StopLoss    = StopLoss*Point;
         value_firstTarget = firstTarget*Point;
         value_stepTarget  = stepTarget*Point;   
      }
      
      bufferENTRY[i] = EntryPrice;
   
      bufferSL[i] = bufferENTRY[i] - value_StopLoss*sign;
   
      bufferTP1[i] = bufferENTRY[i] + value_firstTarget*sign;
      bufferTP2[i] = bufferTP1[i] + value_stepTarget*sign;
      bufferTP3[i] = bufferTP2[i] + value_stepTarget*sign;
      bufferTP4[i] = bufferTP3[i] + value_stepTarget*sign;
      bufferTP5[i] = bufferTP4[i] + value_stepTarget*sign;
      bLineDrawed = true;
   } 
   else
   {
      bufferENTRY[i] = bufferENTRY[i+1];
   
      bufferSL[i]  = bufferSL[i+1];
   
      bufferTP1[i] = bufferTP1[i+1];
      bufferTP2[i] = bufferTP2[i+1];
      bufferTP3[i] = bufferTP3[i+1];
      bufferTP4[i] = bufferTP4[i+1];
      bufferTP5[i] = bufferTP5[i+1];
   }      
}


//--------------------------------------------------------------------
//   Level Texts
//--------------------------------------------------------------------
void Write_LevelTexts()
{
   Set_ValueText(LawnGreen, "OzFXLine_Ent", DoubleToStr(bufferENTRY[0],Digits), Time[0], bufferENTRY[0]);
   Set_ValueText(LawnGreen, "OzFXLine_SLS", DoubleToStr(bufferSL[0],Digits), Time[0], bufferSL[0]);   
   if (NumberOfTargets == 4) {
      Set_ValueText(LawnGreen, "OzFXLine_TP4", DoubleToStr(bufferTP4[0],Digits), Time[0], bufferTP4[0]);
      Set_ValueText(LawnGreen, "OzFXLine_TP3", DoubleToStr(bufferTP3[0],Digits), Time[0], bufferTP3[0]);
      Set_ValueText(LawnGreen, "OzFXLine_TP2", DoubleToStr(bufferTP2[0],Digits), Time[0], bufferTP2[0]);
      Set_ValueText(LawnGreen, "OzFXLine_TP1", DoubleToStr(bufferTP1[0],Digits), Time[0], bufferTP1[0]);   
   } else
   if (NumberOfTargets == 3) {
      Set_ValueText(LawnGreen, "OzFXLine_TP3", DoubleToStr(bufferTP3[0],Digits), Time[0], bufferTP3[0]);
      Set_ValueText(LawnGreen, "OzFXLine_TP2", DoubleToStr(bufferTP2[0],Digits), Time[0], bufferTP2[0]);
      Set_ValueText(LawnGreen, "OzFXLine_TP1", DoubleToStr(bufferTP1[0],Digits), Time[0], bufferTP1[0]);   
   } else
   if (NumberOfTargets == 2) {
      Set_ValueText(LawnGreen, "OzFXLine_TP2", DoubleToStr(bufferTP2[0],Digits), Time[0], bufferTP2[0]);
      Set_ValueText(LawnGreen, "OzFXLine_TP1", DoubleToStr(bufferTP1[0],Digits), Time[0], bufferTP1[0]);   
   } else
   if (NumberOfTargets == 1) {
      Set_ValueText(LawnGreen, "OzFXLine_TP1", DoubleToStr(bufferTP1[0],Digits), Time[0], bufferTP1[0]);   
   }
}

//--------------------------------------------------------------------
//   Write Statistic Levels
//--------------------------------------------------------------------
string SetText(string Text, int value)
{
   return(Text + "= "  + DoubleToStr(value,0)  + "   (" + DoubleToStr((100.0*value)/(1.0*nSignals),2) + "%)" + "\n");
}


void Write_StatisticLevels()
{
   int NplusPoints   = (crossTP1 + crossTP2 + crossTP3 + crossTP4 + crossTP5) * Spread;
   int NminusPoints  = 5*crossSL * Spread;
   
   //=================================================================
   //  Header
   //=================================================================   
   string st = "Statistic OzFX smD1 iLines v4:\n";
   st = st + "# First Trade= " + TimeToStr(FirstTime) + "\n";
   if (Show_Lines_RegularCode)
      st = st + "Regular Code\n"; else st = st + "AES Code\n";   
   if (CalculateLinesWithATR==false)
      st = st + "Levels=" + DoubleToStr(stepTarget,0) + " Points\n"; else st = st + "Dynamic Levels\n";
   st = st + "Spread= " + DoubleToStr(Spread,0) + " Points\n";
   st = st + "Points= " + DoubleToStr(Point,Digits) + "\n"; 
   st = st + "TickValue = "  + DoubleToStr(MarketInfo(Symbol(),MODE_TICKVALUE),2)+"\n";   
   st = st + "MarginRequired = "  + DoubleToStr(MarketInfo(Symbol(),MODE_MARGINREQUIRED),0)+"\n"; 
   
   //=================================================================
   //  Results
   //=================================================================
   st = st + "******************\n";
   
   int NettoPlus  = plusPoints/Point - NplusPoints;
   int NettoMinus = minusPoints/Point + NminusPoints;
   st = st + "plusPoints  = " + DoubleToStr(NettoPlus,0) + "  (" +
      DoubleToStr(plusPoints/Point,0) + "  -Spread= " + DoubleToStr(NplusPoints,0) + ")"   + "\n";
   st = st + "minusPoints= " +  DoubleToStr(NettoMinus,0) + "  (" +
      DoubleToStr(minusPoints/Point,0) + "  +Spread= " + DoubleToStr(NminusPoints,0) + ")"   + "\n";   
   double value1 = (plusPoints - minusPoints) / Point;
   st = st + "Points= " + DoubleToStr(value1,0) + "\n";
   st = st + "# min ProfitFactor= " + DoubleToStr((1.0*NettoPlus)/(1.0*NettoMinus),2) + "\n";
 
   double dFactor = 1.0*(crossTP1 + crossTP2 + crossTP3 + crossTP4 + crossTP5) / (5.0*crossSL);
   st = st + "Levels factor= " + DoubleToStr(dFactor,2) + "\n";   
   
   st = st + "\n";
   st = st + "nSignals= " + DoubleToStr(nSignals,0) + "\n";      
   st = st + "\n"; 
   st = st + SetText("crossSL", crossSL);
   st = st + "sum crossTPs= " + DoubleToStr(crossTP1+crossTP2+crossTP3+crossTP4+crossTP5,0) + "\n";
   st = st + SetText("crossTP1", crossTP1);
   st = st + SetText("crossTP2", crossTP2);
   st = st + SetText("crossTP3", crossTP3);
   st = st + SetText("crossTP4", crossTP4);
   st = st + SetText("crossTP5", crossTP5);
   st = st + "******************";
   Comment(st);
}


//--------------------------------------------------------------------
//   Show Results
//--------------------------------------------------------------------
void ShowResults()
{    
   return;
   /*
   string st = IndicatorName;
   if (Show_TickValueAndMargin) {
   st = st +"\n";
   st = st + "*************************\n";   
   st = st + "TickValue = "  + DoubleToStr(MarketInfo(Symbol(),MODE_TICKVALUE),2)+"\n";   
   st = st + "MarginRequired = "  + DoubleToStr(MarketInfo(Symbol(),MODE_MARGINREQUIRED),0)+"\n";
   st = st + "*************************";
   }
   Comment(st);
   return;*/
}

//--------------------------------------------------------------------
// Draw objects
//--------------------------------------------------------------------
/*string Get_ObjName(datetime time1)
{
   string sTime = TimeToStr(time1);
   string sName = "OzFXLine_";
   //"2007.12.21 08:00"
   // 0    5  8  11 14
   sName = sName + 
      StringSubstr(sTime, 0,4) + "_" +
      StringSubstr(sTime, 5,2) + 
      StringSubstr(sTime, 8,2) + "_" + 
      StringSubstr(sTime, 11,2) + 
      StringSubstr(sTime, 14,2);
   return(sName);
}*/

void Set_ValueText(color dColor, string sName, string sText, datetime time1, double dPosition)
{
   int nObjects = ObjectsTotal();
   for (int i=0; i<nObjects; i++) {
      if (sName == ObjectName(i)) {
         ObjectSet(sName,OBJPROP_TIME1,time1);
         ObjectSet(sName,OBJPROP_PRICE1,dPosition);
         ObjectSet(sName,OBJPROP_COLOR,dColor);         
         ObjectSetText(sName,sText);  
         return;
      }
   }
   //-- new text
   ObjectCreate(sName,OBJ_TEXT,0,time1,dPosition);
   ObjectSet(sName,OBJPROP_COLOR,dColor);
   ObjectSet(sName,OBJPROP_FONTSIZE,8);
   ObjectSet(sName,OBJPROP_WIDTH,2);
   ObjectSetText(sName,sText);
   return;
}

void Delete_TextObjects()
{
   int nObjects = ObjectsTotal();
   for (int i=0; i<nObjects; i++) {
      string sName = ObjectName(i);
      if (StringFind(sName,"OzFXLine_",0) == 0) 
         ObjectDelete(sName);
   }
   return;
}