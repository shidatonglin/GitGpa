#property copyright "Copyright © 2009, CompassFX // Alerts mod. fxdaytrader http://ForexBaron.net"
#property link      "http://www.compassfx.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 DarkOrange
#property indicator_color2 Green
#property indicator_color3 DarkOrange
#property indicator_color4 Green

 string CustomIndicator = "Synergy Average Price Bars";
 string Copyright = "© 2009, CompassFX // mod. fxdaytrader http://ForexBaron.net";
 string WebAddress = "www.compassfx.com";
int indiCounted = 0;
double HA0buffer[],HA1buffer[],HAopenBuffer[],HAcloseBuffer[];

extern string ashi="******* Alert settings:";
extern int SignalCandle=1;
extern bool PopupAlerts            = FALSE;
extern bool EmailAlerts            = FALSE;
extern bool PushNotificationAlerts = FALSE;
extern bool SoundAlerts            = FALSE;
extern string SoundFileLong        = "alert.wav";
extern string SoundFileShort       = "alert2.wav";
int curCandleDir,lastCandleDir;
int lastDir=3;

int init() {
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 1);
   SetIndexBuffer(0, HA0buffer);//red
   SetIndexLabel(0, "HA0");
   SetIndexBuffer(0, HA0buffer);
   SetIndexDrawBegin(0, 10);
   
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 1);
   SetIndexBuffer(1, HA1buffer);//blue
   SetIndexLabel(1, "HA1");
   SetIndexBuffer(1, HA1buffer);
   SetIndexDrawBegin(1, 10);
   
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 3);
   SetIndexBuffer(2, HAopenBuffer);//red
   SetIndexLabel(2, "HAOpen");
   SetIndexBuffer(2, HAopenBuffer);
   SetIndexDrawBegin(2, 10);
   
   SetIndexStyle(3, DRAW_HISTOGRAM, STYLE_SOLID, 3);
   SetIndexBuffer(3, HAcloseBuffer);//blue
   SetIndexLabel(3, "HAClose");
   SetIndexBuffer(3, HAcloseBuffer);
   SetIndexDrawBegin(3, 10);
   
   return(0);
}

int deinit() {
   return(0);
}

int start() {
   double HAmedian,MaxHighHA,MinLowHA,HAweighted;
   if (Bars <= 10) return(0);
   indiCounted = IndicatorCounted();
   if (indiCounted < 0) return (-1);
   if (indiCounted > 0) indiCounted--;
   
   for (int shift = Bars - indiCounted - 1; shift >= 0; shift--) {
      HAweighted = NormalizeDouble((Open[shift] + High[shift] + Low[shift] + Close[shift]) / 4.0, Digits);
      HAweighted = (HAweighted + Close[shift]) / 2.0;
      HAmedian = (HAopenBuffer[shift + 1] + (HAcloseBuffer[shift + 1])) / 2.0;
      MaxHighHA = MathMax(High[shift], MathMax(HAmedian, HAweighted));
      MinLowHA = MathMin(Low[shift], MathMin(HAmedian, HAweighted));
      if (HAmedian < HAweighted) {//BLUE CANDLE
         HA0buffer[shift] = MinLowHA;//red
         HA1buffer[shift] = MaxHighHA;//blue
         if (shift==(SignalCandle+1)) lastCandleDir=OP_BUY;
         if (shift==SignalCandle)     curCandleDir=OP_BUY;
      } else {//RED CANDLE
         HA0buffer[shift] = MaxHighHA;//red
         HA1buffer[shift] = MinLowHA;//blue
         if (shift==(SignalCandle+1)) lastCandleDir=OP_SELL;
         if (shift==SignalCandle)     curCandleDir=OP_SELL;
      }
      HAopenBuffer[shift] = HAmedian;//red
      HAcloseBuffer[shift] = HAweighted;//blue
   }//for (int shift = Bars - indiCounted - 1; shift >= 0; shift--) {   
//----
   if (curCandleDir==OP_BUY && lastCandleDir==OP_SELL && lastDir!=1) { lastDir=1; doAlerts("CandleDirection changed to LONG",SoundFileLong); }
   if (curCandleDir==OP_SELL && lastCandleDir==OP_BUY && lastDir!=2) { lastDir=2; doAlerts("CandleDirection changed to SHORT",SoundFileShort); }
//----
   return(0);
}

void doAlerts(string msg,string SoundFile) {
        msg="Synergy APB1 Alert on "+Symbol()+", period "+TFtoStr(Period())+": "+msg;
 string emailsubject="MT4 alert on acc. "+AccountNumber()+", "+WindowExpertName()+" - Alert on "+Symbol()+", period "+TFtoStr(Period());
  if (PopupAlerts) Alert(msg);
  if (EmailAlerts) SendMail(emailsubject,msg);
  if (PushNotificationAlerts) SendNotification(msg);
  if (SoundAlerts) PlaySound(SoundFile);
}//void doAlerts(string msg,string SoundFile) {

string TFtoStr(int period) {
 if (period==0) period=Period();
 switch(period) {
  case 1     : return("M1");  break;
  case 5     : return("M5");  break;
  case 15    : return("M15"); break;
  case 30    : return("M30"); break;
  case 60    : return("H1");  break;
  case 240   : return("H4");  break;
  case 1440  : return("D1");  break;
  case 10080 : return("W1");  break;
  case 43200 : return("MN1"); break;
  default    : return(DoubleToStr(period,0));
 }
 return("UNKNOWN");
}//string TFtoStr(int period) {

