////+------------------------------------------------------------------+
//|                MA Cross Arrows.mq4                               |
//|                Copyright © 2006  Scorpion@fxfisherman.com        |
//+------------------------------------------------------------------+
#property copyright "FxFisherman.com"
#property link      "http://www.fxfisherman.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 White
#property indicator_color3 Red

extern int Crossed_Pips = 2;
extern int MA_Period = 20;
extern int MA_Type = MODE_SMA;
extern int Shift_Bars=0;
extern int Bars_Count= 1000;
int state;

extern bool ShowAlert      = FALSE;
extern bool SendEmail      = TRUE;
extern bool Push           = TRUE;
extern string PlatformName="IC Markets";
string FileName="MATouch_Alert";

//---- buffers
double v1[];
double v2[];
double v3[];
  
int init()
  {

   IndicatorBuffers(3);
   SetIndexArrow(0,217);
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexDrawBegin(1,MA_Period * 2);
   SetIndexBuffer(0, v1);
   SetIndexLabel(0,"Buy");
   
   SetIndexArrow(1,218);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexDrawBegin(1,MA_Period * 2);
   SetIndexBuffer(1, v2);
   SetIndexLabel(1,"Sell");
   
 
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1);
   SetIndexDrawBegin(1,MA_Period * 2);
   SetIndexBuffer(2, v3);
   SetIndexLabel(2,"MA");
   
   watermark();
 
   return(0);
  }

int start()
 {
  double ma;
  int previous;
  int i;
  int shift;
  bool crossed_up, crossed_down;
  int totalBars = Bars - (MA_Period * 2);
  
  if (Bars_Count > 0 && Bars_Count <= totalBars)
  {
    i = Bars_Count;
  }else if(totalBars <= 0 ) {
    return(0);
  }else{
    i = totalBars;
  }
  
  while(i>=0)
   {
    shift = i + Shift_Bars;
    ma = iMA(Symbol(), Period(), MA_Period, 0, MA_Type, PRICE_CLOSE, shift);
    crossed_up = High[shift] >= (ma + (Crossed_Pips * Point));
    crossed_down = Low[shift] <= (ma - (Crossed_Pips * Point));

    v1[i] = NULL;
    v2[i] = NULL;    
    v3[i] = ma;
    if (crossed_up && previous != 1) {
      v1[i] = ma + (Crossed_Pips * Point);
      previous = 1;
    }else if(crossed_down && previous != 2){
      v2[i] = ma - (Crossed_Pips * Point);
      previous = 2;
    }
 
    i--;
   }
   
   ma = iMA(Symbol(), Period(), MA_Period, 0, MA_Type, PRICE_CLOSE, 0);
   if (Close[0] >= ma + (Crossed_Pips * Point) && state != 1) { 
      state = 1;
     // Alert(Symbol() + " - UP - Price has crossed up the moving average.");
      SendAlerts(i,"Price has crossed up the moving average","Buy");
   }
   else if (Close[0] <= ma - (Crossed_Pips * Point) && state != -1) {
      state = -1;
      //Alert(Symbol() + " - DOWN - Price has crossed down the moving average.");
   SendAlerts(i,"Price has crossed down the moving average","Sell");   
   }

   return(0);
 }
 
//+------------------------------------------------------------------+

void watermark()
  {
   ObjectCreate("fxfisherman", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("fxfisherman", "fxfisherman.com", 11, "Lucida Handwriting", RoyalBlue);
   ObjectSet("fxfisherman", OBJPROP_CORNER, 2);
   ObjectSet("fxfisherman", OBJPROP_XDISTANCE, 5);
   ObjectSet("fxfisherman", OBJPROP_YDISTANCE, 10);
   return(0);
  }
//+------------------------------------------------------------------+
 bool SendAlerts(int thisi,string action,string type){

	string header,body;
 	header= FileName+" "+type+" signal on "+ Symbol()+" "+GetPeriodName();
 	body  = FileName+" has detected that "+action+" on "+ Symbol()+" "+GetPeriodName()+" on "+PlatformName;
static datetime prevtime=0;
 if(prevtime == Time[0]) {
	return(0);
 }
 Alert("MA TOUCH "+Symbol());
SendNotification("PRICE has touched ma" + _Symbol);
 prevtime = Time[0];

if(ShowAlert){
  Alert(header);
  }
 if (!IsTesting()){ 
if(SendEmail){
 	SendMail(header,body);
 }
 }
 }


//+------------------------------------------------------------------+
string GetPeriodName(){
   switch(Period()){
       case PERIOD_D1:  return("D1");
       case PERIOD_H4:  return("H4");
       case PERIOD_H1:  return("H1");
       case PERIOD_M1:  return("M1");
       case PERIOD_M15: return("M15");
       case PERIOD_M30: return("M30");
       case PERIOD_M5:  return("M5");
       case PERIOD_MN1: return("MN1");
       case PERIOD_W1:  return("W1");
     }
  }

