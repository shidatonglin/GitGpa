
#property copyright "Copyright © 2008, MQL Service"
#property link      "http://www.mqlservice.net"
//#property show_inputs

//#include <WinUser32.mqh>
#include <stdlib.mqh>

#import "user32.dll"
   int RegisterWindowMessageW(string lpString);
   int PostMessageW(int hWnd,int Msg,int wParam,int lParam);
#import

extern int BarsRange = 3;
extern int TimeFrame = 3;
extern int MaxBars = 8000;
extern bool ShowGaps = TRUE;
extern bool RescaleFor5DigitsBroker = TRUE;
extern bool InvertPrices = false;
extern double subtractFrom = 2;

int HstHandle = -1;
string SymbolName;

double open(int pShift) {
   if (InvertPrices) 
         return (NormalizeDouble(subtractFrom-iOpen(Symbol(), PERIOD_M1, pShift),_Digits));
   else  return (                    iOpen(Symbol(), PERIOD_M1, pShift));
}

double close(int pShift) {
   if (InvertPrices) 
         return (NormalizeDouble(subtractFrom-iClose(Symbol(), PERIOD_M1, pShift),_Digits));
   else  return (                    iClose(Symbol(), PERIOD_M1, pShift));
}

double high(int pShift) {
   if (InvertPrices) 
         return (NormalizeDouble(subtractFrom-iLow(Symbol(), PERIOD_M1, pShift),_Digits));
   else  return (                    iHigh(Symbol(), PERIOD_M1, pShift));
}

double low(int pShift) {
   if (InvertPrices) 
         return (NormalizeDouble(subtractFrom-iHigh(Symbol(), PERIOD_M1, pShift),_Digits));
   else  return (                    iLow(Symbol(), PERIOD_M1, pShift));
}


double volume(int pShift) { return (iVolume(Symbol(), PERIOD_M1, pShift)); }
int    time(int pShift)   { return (pShift);                               }

int start() {
   int currHigh;
   int currTime;
   double tmpVolume;
   
   int HstUnused[13];
   
   double currLevel;
   int localTime;
   
   if (_invalid(BarsRange, 0, "BarsRange")) return (0);
   if (_invalid(TimeFrame, 1, "TimeFrame")) return (0);
   if (!IsDllsAllowed()) {
      Alert(WindowExpertName(), ": Please Allow DLL imports to run this script");
      Comment(WindowExpertName(), " aborted due to disabled DLL calls");
      return (-1);
   }
   
   int MT4InternalMsg = RegisterWindowMessageW("MetaTrader4_Internal_Message");
   
   SymbolName = Symbol();
   int hWin = 0;
   int recordCount = 0;
   int Version = 401;
   int Digit = Digits;
   
   for (int shift = StringFind(SymbolName, ".", 0); shift > 0; shift = StringFind(SymbolName, ".", 0)) SymbolName = StringSubstr(SymbolName, 0, shift) + StringSubstr(SymbolName, shift + 1);
		HstHandle = FileOpenHistory(SymbolName + TimeFrame + ".hst", FILE_BIN|FILE_WRITE|FILE_ANSI);
		FileClose(HstHandle);
		HstHandle = FileOpenHistory(SymbolName + TimeFrame + ".hst", FILE_BIN|FILE_READ|FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ|FILE_ANSI);
   
   // HstHandle = FileOpenHistory(SymbolName + TimeFrame + ".hst", FILE_BIN|FILE_WRITE);
   if (HstHandle < 0) {
      Alert(WindowExpertName(), ": Cannot create ", SymbolName + TimeFrame + ".hst");
      Comment(WindowExpertName(), " aborted: Cannot create ", SymbolName + TimeFrame + ".hst");
      return (-1);
   }
   // Print("$Id: //mqlservice/mt4files/experts/scripts/s-Constant Range Bars.mq4#14 $");
   string Copyright = "(C)opyright 2008, MQL Service & Mladen";
   FileWriteInteger(HstHandle, Version, LONG_VALUE);
   FileWriteString(HstHandle, Copyright, 64);
   FileWriteString(HstHandle, SymbolName, 12);
   FileWriteInteger(HstHandle, TimeFrame, LONG_VALUE);
   FileWriteInteger(HstHandle, Digit, LONG_VALUE);
   FileWriteInteger(HstHandle, 0, LONG_VALUE);
   FileWriteInteger(HstHandle, 0, LONG_VALUE);
   FileWriteArray(HstHandle, HstUnused, 0, 13);
   FileFlush(HstHandle);
   int currPos = FileTell(HstHandle);
   
   int unusedMinutes = 60 * TimeFrame;
   
   //stabilisce il valor minimo fra MaxBars e TotaleBarre nel chart a 1 minuto
   //e da lì parte la conversione
   int offset = MathMin(MaxBars, iBars(Symbol(), PERIOD_M1) - 1);
   
   //non ci sono barre
   if (offset <= 0)
      if (MessageBox("No 1M bars available, there will be no history bars!\n\nContinue?", WindowExpertName(), MB_YESNO|MB_ICONQUESTION) == IDNO) return (0);
   
   //non è il timeframe giusto
   if (Period() != PERIOD_M1)
      if (MessageBox("It should be run on 1M chart!\n\nContinue?", WindowExpertName(), MB_YESNO|MB_ICONQUESTION) == IDNO) return (0);

   //controllo decimali
   int minSize = 1;
   if (Digits == 3 || Digits > 4) {
      if (RescaleFor5DigitsBroker) {
         BarsRange = 10 * BarsRange;
         minSize = 10;
      }
   }
   
   //orario inizio prima barra
   int startTime = time(iTime(Symbol(), PERIOD_M1, offset));
   // Print("Starting from ", TimeToStr(startTime, TIME_DATE|TIME_MINUTES|TIME_SECONDS));
   
   //valori iniziali: pone L=H=C=O (RangeBar) = close 
   double startLow = close(offset);
   double startHigh = startLow;
   double startVolume = 1.0;
   double startClose = startLow;
   double startOpen = startLow;
   
   int currSize = 1;
   MqlRates rates;

   //inizia il ciclo dalla barra successiva   
   for (shift = offset - 1; shift >= 0; shift--) {
   
      currTime = time(iTime(Symbol(), PERIOD_M1, shift));
      
      //se volume>0 è passato almeno un tick; calcola la dimensione della barra
      if (Volume[shift] > 0.0) currSize = MathMax(minSize, MathCeil((high(shift) - low(shift)) / Point / Volume[shift]));
      else currSize = minSize;
      
      currSize = MathRound(currSize / minSize) * minSize;
      
      //se la barra è negativa
      if (open(shift) > close(shift)) {
      
         currHigh = MathRound(high(shift) / Point / minSize) * minSize;
         
         while (currHigh >= MathRound(low(shift) / Point / minSize) * minSize) {
            currLevel = NormalizeDouble(currHigh * Point, Digits);
            startLow = MathMin(startLow, currLevel);
            startHigh = MathMax(startHigh, currLevel);
            startVolume++;
            if (MathRound((startHigh - startLow) / Point) >= BarsRange + minSize) {
               currPos = FileTell(HstHandle);
               if (CompareDoubles(startLow, currLevel)) {
                  if (ShowGaps) startLow = NormalizeDouble(startHigh - BarsRange * Point, Digits);
                  else startLow = NormalizeDouble(startLow + minSize * Point, Digits);
                  startClose = startLow;
               }
               if (CompareDoubles(startHigh, currLevel)) {
                  if (ShowGaps) startHigh = NormalizeDouble(startLow + BarsRange * Point, Digits);
                  else startHigh = NormalizeDouble(startHigh - minSize * Point, Digits);
                  startClose = startHigh;
               }
                  rates.time  = startTime;
                  rates.open  = startOpen;
                  rates.close = startClose;
                  rates.high  = startHigh;
                  rates.low   = startLow;
                  rates.tick_volume = startVolume;
                  rates.real_volume = startVolume;
   				   FileWriteStruct(HstHandle,rates);
               //FileWriteInteger(HstHandle, startTime, LONG_VALUE);
               //FileWriteDouble(HstHandle, startOpen, DOUBLE_VALUE);
               //FileWriteDouble(HstHandle, startLow, DOUBLE_VALUE);
               //FileWriteDouble(HstHandle, startHigh, DOUBLE_VALUE);
               //FileWriteDouble(HstHandle, startClose, DOUBLE_VALUE);
               //FileWriteDouble(HstHandle, startVolume, DOUBLE_VALUE);
               //FileFlush(HstHandle);
               recordCount++;
               startTime++;
               startTime = MathMax(currTime, startTime);
               startOpen = currLevel;
               startLow = currLevel;
               startHigh = currLevel;
               startClose = currLevel;
               startVolume = 1.0;
            } else startClose = currLevel;
            currHigh -= currSize;
         }
      } else {
         currHigh = MathRound(low(shift) / Point / minSize) * minSize;
         while (currHigh <= MathRound(high(shift) / Point / minSize) * minSize) {
            currLevel = NormalizeDouble(currHigh * Point, Digits);
            startLow = MathMin(startLow, currLevel);
            startHigh = MathMax(startHigh, currLevel);
            startVolume++;
            if (MathRound((startHigh - startLow) / Point) >= BarsRange + minSize) {
               currPos = FileTell(HstHandle);
               if (CompareDoubles(startLow, currLevel)) {
                  if (ShowGaps) startLow = NormalizeDouble(startHigh - BarsRange * Point, Digits);
                  else startLow = NormalizeDouble(startLow + minSize * Point, Digits);
                  startClose = startLow;
               }
               if (CompareDoubles(startHigh, currLevel)) {
                  if (ShowGaps) startHigh = NormalizeDouble(startLow + BarsRange * Point, Digits);
                  else startHigh = NormalizeDouble(startHigh - minSize * Point, Digits);
                  startClose = startHigh;
               }
                  rates.time  = startTime;
                  rates.open  = startOpen;
                  rates.close = startClose;
                  rates.high  = startHigh;
                  rates.low   = startLow;
                  rates.tick_volume = startVolume;
                  rates.real_volume = startVolume;
   				   FileWriteStruct(HstHandle,rates);
               //FileWriteInteger(HstHandle, startTime, LONG_VALUE);
               //FileWriteDouble(HstHandle, startOpen, DOUBLE_VALUE);
               //FileWriteDouble(HstHandle, startLow, DOUBLE_VALUE);
               //FileWriteDouble(HstHandle, startHigh, DOUBLE_VALUE);
               //FileWriteDouble(HstHandle, startClose, DOUBLE_VALUE);
               //FileWriteDouble(HstHandle, startVolume, DOUBLE_VALUE);
               //FileFlush(HstHandle);
               recordCount++;
               startTime++;
               startTime = MathMax(currTime, startTime);
               startOpen = currLevel;
               startLow = currLevel;
               startHigh = currLevel;
               startClose = currLevel;
               startVolume = 1.0;
            } else startClose = currLevel;
            currHigh += currSize;
         }
      }
   }
   FileFlush(HstHandle);
   currPos = FileTell(HstHandle);
                  rates.time  = startTime;
                  rates.open  = startOpen;
                  rates.close = startClose;
                  rates.high  = startHigh;
                  rates.low   = startLow;
                  rates.tick_volume = startVolume;
                  rates.real_volume = startVolume;
   				   FileWriteStruct(HstHandle,rates);
   //FileWriteInteger(HstHandle, startTime, LONG_VALUE);
   //FileWriteDouble(HstHandle, startOpen, DOUBLE_VALUE);
   //FileWriteDouble(HstHandle, startLow, DOUBLE_VALUE);
   //FileWriteDouble(HstHandle, startHigh, DOUBLE_VALUE);
   //FileWriteDouble(HstHandle, startClose, DOUBLE_VALUE);
   //FileWriteDouble(HstHandle, startVolume, DOUBLE_VALUE);
   FileFlush(HstHandle);
   // Print(recordCount, " record(s) written");
   //fine storico: refresh
   if (hWin == 0) {
      hWin = WindowHandle(SymbolName, TimeFrame);
      // if (hWin != 0) Print("Chart window detected");
   }
   _postMessage(hWin, MT4InternalMsg);
   
   //inizio real time
   startTime = TimeCurrent();
   Comment(WindowExpertName(), " started");
   
   //tutto il realTime è retto dal while() aggiornato ogni 100 msec
   while (IsStopped() == FALSE) {
      localTime = TimeLocal();
      if (RefreshRates()) {
         FileSeek(HstHandle, currPos, SEEK_SET);
         double sclose = Close[0]; if (InvertPrices) sclose=subtractFrom-Close[0];
         startLow = MathMin(startLow, sclose);
         startHigh = MathMax(startHigh, sclose);
         startVolume++;
         if (MathRound((startHigh - startLow) / Point / minSize) <= MathRound(BarsRange / minSize)) {
            tmpVolume = volume(0);
            startClose = close(0);
         } else {
            if (CompareDoubles(startLow, sclose)) {
               if (ShowGaps) startLow = NormalizeDouble(startHigh - BarsRange * Point, Digits);
               else startLow = NormalizeDouble(startLow + minSize * Point, Digits);
               startClose = startLow;
            }
            if (CompareDoubles(startHigh, sclose)) {
               if (ShowGaps) startHigh = NormalizeDouble(startLow + BarsRange * Point, Digits);
               else startHigh = NormalizeDouble(startHigh - minSize * Point, Digits);
               startClose = startHigh;
            }
                  rates.time  = startTime;
                  rates.open  = NormalizeDouble(MathMin(MathMax(startOpen, startLow), startHigh), Digits);
                  rates.low   = NormalizeDouble(MathMin(startLow, startHigh), Digits);
                  rates.high  = NormalizeDouble(MathMax(startHigh, startLow), Digits);
                  rates.close = NormalizeDouble(MathMin(MathMax(startClose, startLow), startHigh), Digits);
                  rates.tick_volume = NormalizeDouble(startVolume, 0);
                  rates.real_volume = NormalizeDouble(startVolume, 0);
   				   FileWriteStruct(HstHandle,rates);
            //FileWriteInteger(HstHandle, startTime, LONG_VALUE);
            //FileWriteDouble(HstHandle, NormalizeDouble(MathMin(MathMax(startOpen, startLow), startHigh), Digits), DOUBLE_VALUE);
            //FileWriteDouble(HstHandle, NormalizeDouble(MathMin(startLow, startHigh), Digits), DOUBLE_VALUE);
            //FileWriteDouble(HstHandle, NormalizeDouble(MathMax(startHigh, startLow), Digits), DOUBLE_VALUE);
            //FileWriteDouble(HstHandle, NormalizeDouble(MathMin(MathMax(startClose, startLow), startHigh), Digits), DOUBLE_VALUE);
            //FileWriteDouble(HstHandle, NormalizeDouble(startVolume, 0), DOUBLE_VALUE);
            FileFlush(HstHandle);
            currPos = FileTell(HstHandle);
            startTime++;
            startTime = MathMax(startTime, TimeCurrent());
            startVolume = 1;
            startOpen = sclose;
            startLow = sclose;
            startHigh = sclose;
            startClose = sclose;
            startVolume = 1.0;
            tmpVolume = startVolume;
         }
                  rates.time  = startTime;
                  rates.open  = NormalizeDouble(MathMin(MathMax(startOpen, startLow), startHigh), Digits);
                  rates.low   = NormalizeDouble(MathMin(startLow, startHigh), Digits);
                  rates.high  = NormalizeDouble(MathMax(startHigh, startLow), Digits);
                  rates.close = NormalizeDouble(MathMin(MathMax(startClose, startLow), startHigh), Digits);
                  rates.tick_volume = NormalizeDouble(startVolume, 0);
                  rates.real_volume = NormalizeDouble(startVolume, 0);
   				   FileWriteStruct(HstHandle,rates);
         //FileWriteInteger(HstHandle, startTime, LONG_VALUE);
         //FileWriteDouble(HstHandle, NormalizeDouble(MathMin(MathMax(startOpen, startLow), startHigh), Digits), DOUBLE_VALUE);
         //FileWriteDouble(HstHandle, NormalizeDouble(MathMin(startLow, startHigh), Digits), DOUBLE_VALUE);
         //FileWriteDouble(HstHandle, NormalizeDouble(MathMax(startHigh, startLow), Digits), DOUBLE_VALUE);
         //FileWriteDouble(HstHandle, NormalizeDouble(MathMin(MathMax(startClose, startLow), startHigh), Digits), DOUBLE_VALUE);
         //FileWriteDouble(HstHandle, NormalizeDouble(startVolume, 0), DOUBLE_VALUE);
         FileFlush(HstHandle);
         if (hWin == 0) {
            hWin = WindowHandle(SymbolName, TimeFrame);
            // if (hWin != 0) Print("Chart window detected");
         }
         hWin = WindowHandle(SymbolName, TimeFrame);
         _postMessage(hWin, MT4InternalMsg);
      } else Sleep(100);
   }
   Comment(WindowExpertName(), " stopped");
   return (0);
}

#define WM_COMMAND                     0x0111
void _postMessage(int pHandle, int pMessage) {
   if (pHandle != 0) {
      PostMessageW(pHandle, WM_COMMAND, 33324, 0);
      PostMessageW(pHandle, pMessage, 2, 1);
   }
}

void deinit() {
   if (HstHandle >= 0) {
      FileClose(HstHandle);
      // Print(SymbolName, TimeFrame, ".hst closed");
      HstHandle = -1;
   }
   // Print("Inputs were: ", "BarsRange=", BarsRange, "; ", "TimeFrame=", TimeFrame, "; ", "MaxBars=", MaxBars, "; ", "ShowGaps=", ShowGaps, ";");
}

bool _invalid(int pValue, int pInvalidValue, string pString) {
   if (pValue <= pInvalidValue) {
      Alert(WindowExpertName() + " " + Symbol() + Period() + " invalid parameter ", pString, ": ", pValue, ". Must be grater than ", pInvalidValue);
      return (TRUE);
   }
   return (FALSE);
}