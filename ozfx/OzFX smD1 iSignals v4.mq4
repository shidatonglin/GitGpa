//+------------------------------------------------------------------+
//|                                        OzFX smD1 iSignals v4.mq4 |
//|                                                         SwingMan |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "SwingMan"
#property link      ""
//====================================================================
// HISTORY
// v1 - Source Code = OzFX Daily Signals X-02RR 
//                    #property copyright "Copyright © 2008, DGC"
//                    #property link      "http://www.ozfx.com.au/"
//                  = Ronald Raygun codes  
// v2 - Alert options for RegularCode and AESCode
//    - TickValue and MarginRequired
//    - Check ShiftEntry only =0 or =1
// v3 - no repaint version ...
// v4 - signal alerts, swing signals
//====================================================================

#property indicator_chart_window

//---- extern inputs -------------------------------------------------
extern bool Show_RegularSignals = true;
extern bool Show_AESSignals = true;
extern bool Show_SwingSignals = true;
//extern bool Set_FilterSMA = false;
//extern int Period_FilterSMA = 200;
//extern int ShiftEntry = 0;
extern bool SendAlert_RegularCode = false;
extern bool SendAlert_AESCode = false;
extern bool SendAlert_SwingCode = false;
extern bool Show_TickValueAndMargin = false;
extern int Period_avg = 5;
extern bool Show_BalanceLine = true;
extern int Period_ATR = 21;
//--------------------------------------------------------------------

#property indicator_buffers 8
#property indicator_color1 Blue  // EntryLong 1
#property indicator_color2 Red   // EntryShort 1
#property indicator_color3 Blue  // EntryLong 2
#property indicator_color4 Red   // EntryShort 2
#property indicator_color5 LimeGreen //Green   // avg long
#property indicator_color6 Crimson // avg short
#property indicator_color7 Blue  // EntryLong 3
#property indicator_color8 Red   // EntryShort 3

//---- constants
int Mode_avg = MODE_SMA;
int Price_avg =PRICE_TYPICAL;
int ShiftEntry = 0;

//---- buffers
double OzFX_RegularLong[], OzFX_RegularShort[];
double OzFX_AESLong[], OzFX_AESShort[];
double OzFX_SwingLong[], OzFX_SwingShort[];
double avg[], trend[], avgLong[], avgShort[];
//double avgFilter[];

//---- variables
int iLastRegular, iLastAES;
int oldRegularCode, oldAEScode, lastRegularAlert, lastAESAlert;
double dOffset;
int k;
string IndicatorName;
int iLastSwing, oldSwingCode, lastSwingAlert;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   if (ShiftEntry < 0 || ShiftEntry > 1) {
     Alert("Allowed value for ShiftEntry are only 0 or 1.");
     return(-1); 
   }
   IndicatorName = "OzFX smD1 iSignals v4";   
   ShowResults();
   
//---- mavg      
   ArraySetAsSeries(avg,true);
   ArraySetAsSeries(trend,true);   
//   ArraySetAsSeries(avgFilter,true);
      
//---- signals
   SetIndexBuffer(0, OzFX_RegularLong);
   SetIndexBuffer(1, OzFX_RegularShort);   
   SetIndexBuffer(2, OzFX_AESLong);     
   SetIndexBuffer(3, OzFX_AESShort);  
   SetIndexBuffer(4, avgLong);
   SetIndexBuffer(5, avgShort);
   SetIndexBuffer(6, OzFX_SwingLong);
   SetIndexBuffer(7, OzFX_SwingShort);     

   // regular signals
   if (Show_RegularSignals) {   
      SetIndexStyle(0,DRAW_ARROW,EMPTY,2); 
      SetIndexStyle(1,DRAW_ARROW,EMPTY,2); 
   } else {
      SetIndexStyle(0,DRAW_NONE); 
      SetIndexStyle(1,DRAW_NONE); 
   }
   // AES signals
   if (Show_AESSignals) {
      SetIndexStyle(2,DRAW_ARROW,EMPTY,2);
      SetIndexStyle(3,DRAW_ARROW,EMPTY,2);
   } else {
      SetIndexStyle(2,DRAW_NONE);   
      SetIndexStyle(3,DRAW_NONE);
   }
   // Swing signals
   if (Show_SwingSignals) {
      SetIndexStyle(6,DRAW_ARROW,EMPTY,0);
      SetIndexStyle(7,DRAW_ARROW,EMPTY,0);   
   } else {
      SetIndexStyle(6,DRAW_NONE);
      SetIndexStyle(7,DRAW_NONE);   
   }
   SetIndexArrow(0, 233); // regular
   SetIndexArrow(1, 234);
   SetIndexArrow(2, 241); // AES
   SetIndexArrow(3, 242);
   SetIndexArrow(6, 217); // Swing
   SetIndexArrow(7, 218);
   
//---- mavg      
   if (Show_BalanceLine) {
      SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,2);
      SetIndexStyle(5,DRAW_LINE,STYLE_SOLID,2);   
   } else {
      SetIndexStyle(4,DRAW_NONE);
      SetIndexStyle(5,DRAW_NONE);   
   }
//---- labels
   SetIndexLabel(0, NULL); // regular
   SetIndexLabel(1, NULL);
   SetIndexLabel(2, NULL); // AES
   SetIndexLabel(3, NULL);   
   SetIndexLabel(4, NULL); // BalanceLIne
   SetIndexLabel(5, NULL);   
   SetIndexLabel(6, NULL); // Swing
   SetIndexLabel(7, NULL);   
   //---- or   
   /*SetIndexLabel(0, "LONG regular"); // regular
   SetIndexLabel(1, "SHORT regular");
   SetIndexLabel(2, "LONG AES"); // AES
   SetIndexLabel(3, "SHORT AES");   
   if (Show_BalanceLine) {   
      SetIndexLabel(4, "avgLong");
      SetIndexLabel(5, "avgShort");      
   } else {   
      SetIndexLabel(4, NULL);
      SetIndexLabel(5, NULL);   
   }*/
//----
   return(0);
}
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{  
   Comment("");
   return(0);
}
  
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   if (ShiftEntry < 0 || ShiftEntry > 1) return(-1); 
   ArrayResize(avg,Bars);
   ArrayResize(trend,Bars);
//   ArrayResize(avgFilter,Bars);      
   
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0) return(-1); 
   if(counted_bars > 0) counted_bars--; 
   int limit=Bars-counted_bars;
//----
   //for (k = Bars-205; k >= 0; k --)
   for (k = limit-1; k >= 0; k--)
   {
      double dOffset = iATR(Symbol(),0,Period_ATR,k+1) * 0.40;
      
//  OZFX Filter  // ##################################################
//---------------------//      
//      avgFilter[k] = iMA(Symbol(), 0, Period_FilterSMA, 0, MODE_SMA, PRICE_CLOSE, k);
      
//  OZFX REGULAR CODE  // ############################################
//---------------------//
      iLastRegular = Get_OzFXRegularSignal(k);
      if (iLastRegular != 0) {
         //-- signal long
         if (iLastRegular != oldRegularCode && iLastRegular == 1) {
// if (Set_FilterSMA && Open[k] > avgFilter[k])  
            OzFX_RegularLong[k] = Low[k] - dOffset;
            if (SendAlert_RegularCode && k == 0) {
               if (lastRegularAlert == -1 || lastRegularAlert == 0) {
                 Send_TextAlert(1, "Regular");
                 lastRegularAlert = 1;
               }                          
            }   
         }      
         
         //-- signal short
         if (iLastRegular != oldRegularCode && iLastRegular ==-1) {
// if (Set_FilterSMA && Open[k] < avgFilter[k])
            OzFX_RegularShort[k] = High[k] + dOffset; 
            if (SendAlert_RegularCode && k == 0) {
               if (lastRegularAlert == 1 || lastRegularAlert == 0) {
                 Send_TextAlert(-1, "Regular");
                 lastRegularAlert = -1;
               }              
            }
         }
         oldRegularCode = iLastRegular;
      }
      else {     
         OzFX_RegularLong[k] = EMPTY_VALUE;
         OzFX_RegularShort[k] = EMPTY_VALUE;
      }

//  OZFX AES CODE  // ################################################
//-----------------//      
      iLastAES = Get_OzFXAESSignal(k);      
      if (iLastAES != 0) {
         //-- signal long
         if (iLastAES != oldAEScode && iLastAES == 1) {
// if (Set_FilterSMA && Open[k] > avgFilter[k])           
            OzFX_AESLong[k] = Low[k] - dOffset;
            if (SendAlert_AESCode && k == 0) {
              if (lastAESAlert == -1 || lastAESAlert == 0) {
                Send_TextAlert(1, "AES");
                lastAESAlert = 1;
              } 
            }
         } 
         //-- signal short
         if (iLastAES != oldAEScode && iLastAES ==-1) {
// if (Set_FilterSMA && Open[k] < avgFilter[k])           
            OzFX_AESShort[k] = High[k] + dOffset;
            if (SendAlert_AESCode && k == 0) {
               if (lastAESAlert == 1 || lastAESAlert == 0) {
                 Send_TextAlert(-1, "AES");
                 lastAESAlert = -1;
               }  
            }   
         }   
         oldAEScode = iLastAES;
      } 
      else {      
         OzFX_AESLong[k] = EMPTY_VALUE;
         OzFX_AESShort[k] = EMPTY_VALUE;
      }


//  OZFX Swing CODE  // ##############################################
//-----------------//      
      iLastSwing = Get_OzFXSwingSignal(k);      
      if (iLastSwing != 0) {
         //-- signal long
         if (iLastSwing != oldSwingCode && iLastSwing == 1) {
// if (Set_FilterSMA && Open[k] > avgFilter[k])           
            OzFX_SwingLong[k] = Low[k] - dOffset + dOffset*0.5;
            if (SendAlert_SwingCode && k == 0) {
              if (lastSwingAlert == -1 || lastSwingAlert == 0) {
                Send_TextAlert(1, "Swing");
                lastSwingAlert = 1;
              } 
            }
         } 
         //-- signal short
         if (iLastSwing != oldSwingCode && iLastSwing ==-1) {
// if (Set_FilterSMA && Open[k] < avgFilter[k])           
            OzFX_SwingShort[k] = High[k] + dOffset - dOffset*0.5;
            if (SendAlert_SwingCode && k == 0) {
               if (lastSwingAlert == 1 || lastSwingAlert == 0) {
                 Send_TextAlert(-1, "Swing");
                 lastSwingAlert = -1;
               }  
            }   
         }   
         oldSwingCode = iLastSwing;
      } 
      else {      
         OzFX_SwingLong[k] = EMPTY_VALUE;
         OzFX_SwingShort[k] = EMPTY_VALUE;
      }

//####################################################################
//  average colored // ###############################################
//-----------------//              
      avg[k] = iMA(Symbol(), 0, Period_avg, 0, Mode_avg, Price_avg, k);

      trend[k] = trend[k+1];
      if (avg[k]> avg[k+1]) trend[k] =1;
      if (avg[k]< avg[k+1]) trend[k] =-1;

      if (trend[k]>0)
        { 
          avgLong[k] = avg[k];       
          if (trend[k+1]<0) avgLong[k+1]=avg[k+1]; 
          avgShort[k] = EMPTY_VALUE;
        }
      else              
      {
      if (trend[k]<0)
        { 
          avgShort[k] = avg[k]; 
          if (trend[k+1]>0) avgShort[k+1]=avg[k+1];
          avgLong[k] = EMPTY_VALUE;
        }              
      }
   }   
//----
   return(0);
}
//+------------------------------------------------------------------+

int Get_OzFXRegularSignal(int i)
{
   //-- Regular long
//   if (Set_FilterSMA && Open[i] > avgFilter[i]) { 
      bool condAClong1 = iAC(Symbol(), 0, i + ShiftEntry) > 0;
      bool condAClong2 = iAC(Symbol(), 0, i + ShiftEntry) > iAC(Symbol(), 0, i + 1 + ShiftEntry);
      bool condSTlong1 = iStochastic(Symbol(), 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, i + ShiftEntry) > 50;
      if (condAClong1 && condAClong2 && condSTlong1) return(1);
//   }
   //-- Regular short
//   if (Set_FilterSMA && Open[i] < avgFilter[i]) { 
      bool condACshort1 = iAC(Symbol(), 0, i + ShiftEntry) < 0;
      bool condACshort2 = iAC(Symbol(), 0, i + ShiftEntry) < iAC(Symbol(), 0, i + 1 + ShiftEntry);
      bool condSTshort1 = iStochastic(Symbol(), 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, i + ShiftEntry) < 50;
      if (condACshort1 && condACshort2 && condSTshort1) return(-1);
//   }
   return(0);
}

int Get_OzFXAESSignal(int i)
{
   //-- AES long
//   if (Set_FilterSMA && Open[i] > avgFilter[i]) { 
      bool condAClong1 = iAC(Symbol(), 0, i + ShiftEntry) > iAC(Symbol(), 0, i + 1 + ShiftEntry);     
      bool condSTlong1 = iStochastic(Symbol(), 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, i + ShiftEntry)
                       > iStochastic(Symbol(), 0, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i + ShiftEntry);          
      if (condAClong1 && condSTlong1) return(1);
//   }
   //-- AES short
//   if (Set_FilterSMA && Open[i] < avgFilter[i]) { 
      bool condACshort1 = iAC(Symbol(), 0, i + ShiftEntry) < iAC(Symbol(), 0, i + 1 + ShiftEntry);   
      bool condSTshort1 = iStochastic(Symbol(), 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, i + ShiftEntry)
                        < iStochastic(Symbol(), 0, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i + ShiftEntry);
      if (condACshort1 && condSTshort1) return(-1);
//   }     
   return(0);
}

int Get_OzFXSwingSignal(int i)
{
   //-- Swing long
//   if (Set_FilterSMA && Open[i] > avgFilter[i]) { 
      bool condAClong1 = iMA(Symbol(), 0, Period_avg, 0, Mode_avg, Price_avg, i + ShiftEntry) 
                         > iMA(Symbol(), 0, Period_avg, 0, Mode_avg, Price_avg, i + 1+ ShiftEntry);
      bool condAClong2 = iAC(Symbol(), 0, i + ShiftEntry) > iAC(Symbol(), 0, i + 1 + ShiftEntry) &&
                         iAC(Symbol(), 0, i + 1 + ShiftEntry) > iAC(Symbol(), 0, i + 2 + ShiftEntry) &&
                         iAC(Symbol(), 0, i + 2 + ShiftEntry) > iAC(Symbol(), 0, i + 3 + ShiftEntry);
      bool condSTlong1 = iStochastic(Symbol(), 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, i + ShiftEntry) > 50;
      if (condAClong1 && condAClong2 && condSTlong1) return(1);
//   }
   // Swing short
//   if (Set_FilterSMA && Open[i] < avgFilter[i]) { 
      bool condACshort1 = iMA(Symbol(), 0, Period_avg, 0, Mode_avg, Price_avg, i + ShiftEntry) 
                         < iMA(Symbol(), 0, Period_avg, 0, Mode_avg, Price_avg, i + 1+ ShiftEntry);   
      bool condACshort2 = iAC(Symbol(), 0, i + ShiftEntry) < iAC(Symbol(), 0, i + 1 + ShiftEntry) &&
                          iAC(Symbol(), 0, i + 1 + ShiftEntry) < iAC(Symbol(), 0, i + 2 + ShiftEntry) &&
                          iAC(Symbol(), 0, i + 2 + ShiftEntry) < iAC(Symbol(), 0, i + 3 + ShiftEntry);
      bool condSTshort1 = iStochastic(Symbol(), 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, i + ShiftEntry) < 50;
      if (condACshort1 && condACshort2 && condSTshort1) return(-1);
//   }   
   return(0);
}

void Send_TextAlert(int direction, string code)
{
   string s1, s2;
   if (direction ==  1) s1 = "LONG signal " + Symbol();
   if (direction == -1) s1 = "SHORT signal " + Symbol();
   if (code == "Regular") s2 = "  (OzFX regular code v4 / " + TimeToStr(TimeCurrent()) + ")";
   if (code == "AES")     s2 = "  (OzFX AES code v4 / " + TimeToStr(TimeCurrent()) + ")";
   if (code == "Swing")   s2 = "  (OzFX Swing code v4 / " + TimeToStr(TimeCurrent()) + ")";
   Alert(s1 + s2);
}

//--------------------------------------------------------------------
//   Show Results
//--------------------------------------------------------------------
void ShowResults()
{    
   string st = IndicatorName;
   if (Show_TickValueAndMargin) {
   st = st +"\n";
   st = st + "*************************\n";   
   st = st + "TickValue = "  + DoubleToStr(MarketInfo(Symbol(),MODE_TICKVALUE),2)+"\n";   
   st = st + "MarginRequired = "  + DoubleToStr(MarketInfo(Symbol(),MODE_MARGINREQUIRED),0)+"\n";
   st = st + "*************************";
   }
   Comment(st);
}