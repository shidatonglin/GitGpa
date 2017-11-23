//============================================= ICHIMOKSTER 1.0 ===================================
//================================================================================================+
#define SIGNAL_NONE 0
#define SIGNAL_BUY   1
#define SIGNAL_SELL  2
#define SIGNAL_CLOSEBUY 3
#define SIGNAL_CLOSESELL 4

extern int MagicNumber      = 4711;
extern string REM           = "Ichimokster";
extern double MinLot        = 0.01;
extern bool EachTickMode    = true;  // 1,True (every tick); 0,False (complete bar)
extern bool UseTrailingStop = true;
extern bool UseATRTS        = true;
extern double ATRfactor     = 1;
extern bool UseTakeProfit   = false;
extern int TakeProfit       = 1000;
extern int TrailingStop     = 20;
extern double TF1           = 5;     
extern double TF2           = 15;    
extern double TF3           = 30;  
extern double TF4           = 60;     
extern double TF5           = 240;    
extern double TF6           = 1440;  
extern bool UseMoneyMngt    = true;  // Use Money Management
extern int MMfactor         = 5000;  // Lessening this will accelerate growth of Lot Size

bool TickCheck = False;
double Lots;
int Slippage = 3;
int BarCount;
int Current;
//+------------------------------------------------------------------+
int init()
{//A
   BarCount = Bars;
   if (EachTickMode) Current = 0; else Current = 1;
   return(0);
}//a
   int deinit(){}
   int start()
{//A
   int Sit;
   string Text[21];    // Declaring a string array
   color  Color[21];    // Declaring an array of colors

   int TS = 9;
   int KS = 26;
   int SS = 52;
   
   int XPOS1 = 0;
   int XPOS2 = 220;
   int XPOS3 = 440;
   int XPOS4 = 0;
   int XPOS5 = 220;
   int XPOS6 = 440;
//-------------------------------------------------------------------
   Text[0]= "TENKAN > KIJUN";
   Text[1]= "TENKAN = KIJUN";
   Text[2]= "TENKAN < KIJUN";

   Text[3]= "PRICE > TENKAN";
   Text[4]= "PRICE = TENKAN";
   Text[5]= "PRICE < TENKAN";
   
   Text[6]= "PRICE > KUMO";
   Text[7]= "PRICE = KUMO";
   Text[8]= "PRICE < KUMO";

   Text[9] = "CHIKOU > PRICE CURVE";
   Text[10]= "CHIKOU = PRICE CURVE";
   Text[11]= "CHIKOU < PRICE CURVE";

   Text[12]= "CHIKOU > TENKAN";
   Text[13]= "CHIKOU = TENKAN";
   Text[14]= "CHIKOU < TENKAN";

   Text[15]= "CHIKOU > KIJUN";
   Text[16]= "CHIKOU = KIJUN";
   Text[17]= "CHIKOU < KIJUN";

   Text[18]= "CHIKOU > KUMO";
   Text[19]= "CHIKOU = KUMO";
   Text[20]= "CHIKOU < KUMO";
// =================================================== COLORS
   Color[0]= GreenYellow; 
   Color[1]= Blue;        
   Color[2]= OrangeRed; 
   
   Color[3]= GreenYellow; 
   Color[4]= Blue;        
   Color[5]= OrangeRed; 
   
   Color[6]= GreenYellow; 
   Color[7]= Blue;        
   Color[8]= OrangeRed; 
   
   Color[9]= GreenYellow; 
   Color[10]= Blue;        
   Color[11]= OrangeRed; 
   
   Color[12]= GreenYellow; 
   Color[13]= Blue;        
   Color[14]= OrangeRed; 
   
   Color[15]= GreenYellow; 
   Color[16]= Blue;        
   Color[17]= OrangeRed; 
   
   Color[18]= GreenYellow; 
   Color[19]= Blue;        
   Color[20]= OrangeRed; 
//============================================================================
   double TENKAN1   = iIchimoku(NULL,TF1,TS,KS,SS,MODE_TENKANSEN,0);
   double KIJUN1    = iIchimoku(NULL,TF1,TS,KS,SS,MODE_KIJUNSEN ,0);
   double SENKOUA1  = iIchimoku(NULL,TF1,TS,KS,SS,MODE_SENKOUSPANA,0);
   double SENKOUB1  = iIchimoku(NULL,TF1,TS,KS,SS,MODE_SENKOUSPANB,0);
   double xTENKAN1  = iIchimoku(NULL,TF1,TS,KS,SS,MODE_TENKANSEN,KS);
   double xKIJUN1   = iIchimoku(NULL,TF1,TS,KS,SS,MODE_KIJUNSEN ,KS);
   double xSENKOUA1 = iIchimoku(NULL,TF1,TS,KS,SS,MODE_SENKOUSPANA,KS);
   double xSENKOUB1 = iIchimoku(NULL,TF1,TS,KS,SS,MODE_SENKOUSPANB,KS);
   double xPRICE1   = iClose(NULL,TF1,KS);
    
   double TENKAN2   = iIchimoku(NULL,TF2,TS,KS,SS,MODE_TENKANSEN,0);
   double KIJUN2    = iIchimoku(NULL,TF2,TS,KS,SS,MODE_KIJUNSEN ,0);
   double SENKOUA2  = iIchimoku(NULL,TF2,TS,KS,SS,MODE_SENKOUSPANA,0);
   double SENKOUB2  = iIchimoku(NULL,TF2,TS,KS,SS,MODE_SENKOUSPANB,0);
   double xTENKAN2  = iIchimoku(NULL,TF2,TS,KS,SS,MODE_TENKANSEN,KS);
   double xKIJUN2   = iIchimoku(NULL,TF2,TS,KS,SS,MODE_KIJUNSEN ,KS);
   double xSENKOUA2 = iIchimoku(NULL,TF2,TS,KS,SS,MODE_SENKOUSPANA,KS);
   double xSENKOUB2 = iIchimoku(NULL,TF2,TS,KS,SS,MODE_SENKOUSPANB,KS);
   double xPRICE2   = iClose(NULL,TF2,KS);
      
   double TENKAN3   = iIchimoku(NULL,TF3,TS,KS,SS,MODE_TENKANSEN,0);
   double KIJUN3    = iIchimoku(NULL,TF3,TS,KS,SS,MODE_KIJUNSEN ,0);
   double SENKOUA3  = iIchimoku(NULL,TF3,TS,KS,SS,MODE_SENKOUSPANA,0);
   double SENKOUB3  = iIchimoku(NULL,TF3,TS,KS,SS,MODE_SENKOUSPANB,0);
   double xTENKAN3  = iIchimoku(NULL,TF3,TS,KS,SS,MODE_TENKANSEN,KS);
   double xKIJUN3   = iIchimoku(NULL,TF3,TS,KS,SS,MODE_KIJUNSEN ,KS);
   double xSENKOUA3 = iIchimoku(NULL,TF3,TS,KS,SS,MODE_SENKOUSPANA,KS);
   double xSENKOUB3 = iIchimoku(NULL,TF3,TS,KS,SS,MODE_SENKOUSPANB,KS);
   double xPRICE3   = iClose(NULL,TF3,KS);
   
   
   double TENKAN4   = iIchimoku(NULL,TF4,TS,KS,SS,MODE_TENKANSEN,0);
   double KIJUN4    = iIchimoku(NULL,TF4,TS,KS,SS,MODE_KIJUNSEN ,0);
   double SENKOUA4  = iIchimoku(NULL,TF4,TS,KS,SS,MODE_SENKOUSPANA,0);
   double SENKOUB4  = iIchimoku(NULL,TF4,TS,KS,SS,MODE_SENKOUSPANB,0);
   double xTENKAN4  = iIchimoku(NULL,TF4,TS,KS,SS,MODE_TENKANSEN,KS);
   double xKIJUN4   = iIchimoku(NULL,TF4,TS,KS,SS,MODE_KIJUNSEN ,KS);
   double xSENKOUA4 = iIchimoku(NULL,TF4,TS,KS,SS,MODE_SENKOUSPANA,KS);
   double xSENKOUB4 = iIchimoku(NULL,TF4,TS,KS,SS,MODE_SENKOUSPANB,KS);
   double xPRICE4   = iClose(NULL,TF4,KS);
      
   double TENKAN5   = iIchimoku(NULL,TF5,TS,KS,SS,MODE_TENKANSEN,0);
   double KIJUN5    = iIchimoku(NULL,TF5,TS,KS,SS,MODE_KIJUNSEN ,0);
   double SENKOUA5  = iIchimoku(NULL,TF5,TS,KS,SS,MODE_SENKOUSPANA,0);
   double SENKOUB5  = iIchimoku(NULL,TF5,TS,KS,SS,MODE_SENKOUSPANB,0);
   double xTENKAN5  = iIchimoku(NULL,TF5,TS,KS,SS,MODE_TENKANSEN,KS);
   double xKIJUN5   = iIchimoku(NULL,TF5,TS,KS,SS,MODE_KIJUNSEN ,KS);
   double xSENKOUA5 = iIchimoku(NULL,TF5,TS,KS,SS,MODE_SENKOUSPANA,KS);
   double xSENKOUB5 = iIchimoku(NULL,TF5,TS,KS,SS,MODE_SENKOUSPANB,KS);
   double xPRICE5   = iClose(NULL,TF5,KS);
     
   double TENKAN6   = iIchimoku(NULL,TF6,TS,KS,SS,MODE_TENKANSEN,0);
   double KIJUN6    = iIchimoku(NULL,TF6,TS,KS,SS,MODE_KIJUNSEN ,0);
   double SENKOUA6  = iIchimoku(NULL,TF6,TS,KS,SS,MODE_SENKOUSPANA,0);
   double SENKOUB6  = iIchimoku(NULL,TF6,TS,KS,SS,MODE_SENKOUSPANB,0);
   double xTENKAN6  = iIchimoku(NULL,TF6,TS,KS,SS,MODE_TENKANSEN,KS);
   double xKIJUN6   = iIchimoku(NULL,TF6,TS,KS,SS,MODE_KIJUNSEN ,KS);
   double xSENKOUA6 = iIchimoku(NULL,TF6,TS,KS,SS,MODE_SENKOUSPANA,KS);
   double xSENKOUB6 = iIchimoku(NULL,TF6,TS,KS,SS,MODE_SENKOUSPANB,KS);   
   double xPRICE6   = iClose(NULL,TF6,KS);  
    
   int SPREAD = MarketInfo(Symbol(),MODE_SPREAD);
   double ATR = iATR(NULL,TF2,5,0);
//------------------------------------------------------------------------
   ObjectCreate("TF1", OBJ_LABEL, 0, 0, 0);               // TF1 Header
   ObjectSet("TF1",    OBJPROP_CORNER, 2);
   ObjectSet("TF1",    OBJPROP_XDISTANCE, XPOS1);
   ObjectSet("TF1",    OBJPROP_YDISTANCE, 340);
   ObjectSetText("TF1","M"+TF1,20,"Arial",Yellow);

   ObjectCreate("TF2", OBJ_LABEL, 0, 0, 0);               // TF2 Header
   ObjectSet("TF2",    OBJPROP_CORNER, 2);
   ObjectSet("TF2",    OBJPROP_XDISTANCE, XPOS2);
   ObjectSet("TF2",    OBJPROP_YDISTANCE, 340);
   ObjectSetText("TF2","M"+TF2,20,"Arial",Yellow);

   ObjectCreate("TF3", OBJ_LABEL, 0, 0, 0);               // TF3 Header
   ObjectSet("TF3",    OBJPROP_CORNER, 2);
   ObjectSet("TF3",    OBJPROP_XDISTANCE, XPOS3);
   ObjectSet("TF3",    OBJPROP_YDISTANCE, 340);
   ObjectSetText("TF3","M"+TF3,20,"Arial",Yellow);
   
   ObjectCreate("TF4", OBJ_LABEL, 0, 0, 0);               // TF4 Header
   ObjectSet("TF4",    OBJPROP_CORNER, 2);
   ObjectSet("TF4",    OBJPROP_XDISTANCE, XPOS4);
   ObjectSet("TF4",    OBJPROP_YDISTANCE, 150);
   ObjectSetText("TF4","M"+TF4,20,"Arial",Yellow);
   
   ObjectCreate("TF5", OBJ_LABEL, 0, 0, 0);               // TF5 Header
   ObjectSet("TF5",    OBJPROP_CORNER, 2);
   ObjectSet("TF5",    OBJPROP_XDISTANCE, XPOS5);
   ObjectSet("TF5",    OBJPROP_YDISTANCE, 150);
   ObjectSetText("TF5","M"+TF5,20,"Arial",Yellow);
   
   ObjectCreate("TF6", OBJ_LABEL, 0, 0, 0);               // TF6 Header
   ObjectSet("TF6",    OBJPROP_CORNER, 2);
   ObjectSet("TF6",    OBJPROP_XDISTANCE, XPOS6);
   ObjectSet("TF6",    OBJPROP_YDISTANCE, 150);
   ObjectSetText("TF6","M"+TF6,20,"Arial",Yellow); 
//------------------------------------------------------------------------- TF1
   if (TENKAN1 >  KIJUN1)  Sit=0; // Tenkan > Kijun
   if (TENKAN1 == KIJUN1)  Sit=1; // Tenkan = Kijun
   if (TENKAN1 <  KIJUN1)  Sit=2; // Tenkan < Kijun
   ObjectDelete("Tenkan_Kijun_1");
   ObjectCreate("Tenkan_Kijun_1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Tenkan_Kijun_1", OBJPROP_CORNER, 2);
   ObjectSet("Tenkan_Kijun_1", OBJPROP_XDISTANCE, XPOS1);
   ObjectSet("Tenkan_Kijun_1", OBJPROP_YDISTANCE, 320);
   ObjectSetText("Tenkan_Kijun_1",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  TENKAN1)  Sit=3; // Price > Tenkan
   if (Close[0] == TENKAN1)  Sit=4; // Price = Tenkan
   if (Close[0] <  TENKAN1)  Sit=5; // Price < Tenkan
   ObjectDelete("Price_Tenkan_1");
   ObjectCreate("Price_Tenkan_1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Price_Tenkan_1", OBJPROP_CORNER, 2);
   ObjectSet("Price_Tenkan_1", OBJPROP_XDISTANCE, XPOS1);
   ObjectSet("Price_Tenkan_1", OBJPROP_YDISTANCE, 300);
   ObjectSetText("Price_Tenkan_1",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] > SENKOUA1 && Close[0] > SENKOUB1) Sit=6; // PRICE > KUMO
   if (Close[0] < SENKOUA1 && Close[0] > SENKOUB1) Sit=7; // PRICE = KUMO
   if (Close[0] > SENKOUA1 && Close[0] < SENKOUB1) Sit=7; // PRICE = KUMO
   if (Close[0] < SENKOUA1 && Close[0] < SENKOUB1) Sit=8; // PRICE < KUMO
   ObjectDelete("Price_Kumo_1");
   ObjectCreate("Price_Kumo_1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Price_Kumo_1", OBJPROP_CORNER, 2);
   ObjectSet("Price_Kumo_1", OBJPROP_XDISTANCE, XPOS1);
   ObjectSet("Price_Kumo_1", OBJPROP_YDISTANCE, 280);
   ObjectSetText("Price_Kumo_1",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  xPRICE1)  Sit=9;  // Chikou > Price
   if (Close[0] == xPRICE1)  Sit=10; // Chikou = Price
   if (Close[0] <  xPRICE1)  Sit=11; // Chikou < Price
   ObjectDelete("Chikou_Price_1");
   ObjectCreate("Chikou_Price_1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Price_1", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Price_1", OBJPROP_XDISTANCE, XPOS1);
   ObjectSet("Chikou_Price_1", OBJPROP_YDISTANCE, 260);
   ObjectSetText("Chikou_Price_1",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  xTENKAN1)  Sit=12; // Chikou above Tenkan curve
   if (Close[0] == xTENKAN1)  Sit=13; // Chikou equal to Tenkan curve
   if (Close[0] <  xTENKAN1)  Sit=14; // Chikou below Tenkan curve
   ObjectDelete("Chikou_Tenkan_1");
   ObjectCreate("Chikou_Tenkan_1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Tenkan_1", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Tenkan_1", OBJPROP_XDISTANCE, XPOS1);
   ObjectSet("Chikou_Tenkan_1", OBJPROP_YDISTANCE, 240);
   ObjectSetText("Chikou_Tenkan_1",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  xKIJUN1)  Sit=15; // Chikou above Kijun curve
   if (Close[0] == xKIJUN1)  Sit=16; // Chikou equal to Kijun curve
   if (Close[0] <  xKIJUN1)  Sit=17; // Chikou below Kijun curve
   ObjectDelete("Chikou_Kijun_1");
   ObjectCreate("Chikou_Kijun_1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Kijun_1", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Kijun_1", OBJPROP_XDISTANCE, XPOS1);
   ObjectSet("Chikou_Kijun_1", OBJPROP_YDISTANCE, 220);
   ObjectSetText("Chikou_Kijun_1",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] > xSENKOUA1 && Close[0] > xSENKOUB1) Sit=18; // Chikou above KUMO
   if (Close[0] < xSENKOUA1 && Close[0] > xSENKOUB1) Sit=19; // Chikou inside KUMO
   if (Close[0] > xSENKOUA1 && Close[0] < xSENKOUB1) Sit=19; // Chikou inside KUMO
   if (Close[0] < xSENKOUA1 && Close[0] < xSENKOUB1) Sit=20; // Chikou below KUMO
   ObjectDelete("Chikou_Kumo_1");
   ObjectCreate("Chikou_Kumo_1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Kumo_1", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Kumo_1", OBJPROP_XDISTANCE, XPOS1);
   ObjectSet("Chikou_Kumo_1", OBJPROP_YDISTANCE, 200);
   ObjectSetText("Chikou_Kumo_1",Text[Sit],10,"Arial",Color[Sit]);
  //--------------------------------------------------------------------- TF2
   if (TENKAN2 >  KIJUN2)  Sit=0; // BULLISH Tenkan_Kijun cross
   if (TENKAN2 == KIJUN2)  Sit=1; // No Tenkan_Kijun cross
   if (TENKAN2 <  KIJUN2)  Sit=2; // BEARISH Tenkan_Kijun cross
   ObjectDelete("Tenkan_Kijun_2");
   ObjectCreate("Tenkan_Kijun_2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Tenkan_Kijun_2", OBJPROP_CORNER, 2);
   ObjectSet("Tenkan_Kijun_2", OBJPROP_XDISTANCE, XPOS2);
   ObjectSet("Tenkan_Kijun_2", OBJPROP_YDISTANCE, 320);
   ObjectSetText("Tenkan_Kijun_2",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  TENKAN2)  Sit=3; // Price above Tenkan
   if (Close[0] == TENKAN2)  Sit=4; // Price equal to Tenkan
   if (Close[0] <  TENKAN2)  Sit=5; // Price below Tenkan
   ObjectDelete("Price_Tenkan_2");
   ObjectCreate("Price_Tenkan_2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Price_Tenkan_2", OBJPROP_CORNER, 2);
   ObjectSet("Price_Tenkan_2", OBJPROP_XDISTANCE, XPOS2);
   ObjectSet("Price_Tenkan_2", OBJPROP_YDISTANCE, 300);
   ObjectSetText("Price_Tenkan_2",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] > SENKOUA2 && Close[0] > SENKOUB2) Sit=6; // PRICE above KUMO
   if (Close[0] < SENKOUA2 && Close[0] > SENKOUB2) Sit=7; // PRICE inside KUMO
   if (Close[0] > SENKOUA2 && Close[0] < SENKOUB2) Sit=7; // PRICE inside KUMO
   if (Close[0] < SENKOUA2 && Close[0] < SENKOUB2) Sit=8; // PRICE below KUMO
   ObjectDelete("Price_Kumo_2");
   ObjectCreate("Price_Kumo_2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Price_Kumo_2", OBJPROP_CORNER, 2);
   ObjectSet("Price_Kumo_2", OBJPROP_XDISTANCE, XPOS2);
   ObjectSet("Price_Kumo_2", OBJPROP_YDISTANCE, 280);
   ObjectSetText("Price_Kumo_2",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  xPRICE2)  Sit=9;  // Chikou Span above Price curve
   if (Close[0] == xPRICE2)  Sit=10; // Chikou Span equal to Price curve
   if (Close[0] <  xPRICE2)  Sit=11; // Chikou Span below Price Curve
   ObjectDelete("Chikou_Price_2");
   ObjectCreate("Chikou_Price_2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Price_2", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Price_2", OBJPROP_XDISTANCE, XPOS2);
   ObjectSet("Chikou_Price_2", OBJPROP_YDISTANCE, 260);
   ObjectSetText("Chikou_Price_2",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  xTENKAN2)  Sit=12; // Chikou above Tenkan curve
   if (Close[0] == xTENKAN2)  Sit=13; // Chikou equal to Tenkan curve
   if (Close[0] <  xTENKAN2)  Sit=14; // Chikou below Tenkan curve
   ObjectDelete("Chikou_Tenkan_2");
   ObjectCreate("Chikou_Tenkan_2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Tenkan_2", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Tenkan_2", OBJPROP_XDISTANCE, XPOS2);
   ObjectSet("Chikou_Tenkan_2", OBJPROP_YDISTANCE, 240);
   ObjectSetText("Chikou_Tenkan_2",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  xKIJUN2)  Sit=15; // Chikou above Kijun curve
   if (Close[0] == xKIJUN2)  Sit=16; // Chikou equal to Kijun curve
   if (Close[0] <  xKIJUN2)  Sit=17; // Chikou below Kijun curve
   ObjectDelete("Chikou_Kijun_2");
   ObjectCreate("Chikou_Kijun_2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Kijun_2", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Kijun_2", OBJPROP_XDISTANCE, XPOS2);
   ObjectSet("Chikou_Kijun_2", OBJPROP_YDISTANCE, 220);
   ObjectSetText("Chikou_Kijun_2",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] > xSENKOUA2 && Close[0] > xSENKOUB2) Sit=18; // Chikou above KUMO
   if (Close[0] < xSENKOUA2 && Close[0] > xSENKOUB2) Sit=19; // Chikou inside KUMO
   if (Close[0] > xSENKOUA2 && Close[0] < xSENKOUB2) Sit=19; // Chikou inside KUMO
   if (Close[0] < xSENKOUA2 && Close[0] < xSENKOUB2) Sit=20; // Chikou below KUMO
   ObjectDelete("Chikou_Kumo_2");
   ObjectCreate("Chikou_Kumo_2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Kumo_2", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Kumo_2", OBJPROP_XDISTANCE, XPOS2);
   ObjectSet("Chikou_Kumo_2", OBJPROP_YDISTANCE, 200);
   ObjectSetText("Chikou_Kumo_2",Text[Sit],10,"Arial",Color[Sit]);
//--------------------------------------------------------------------- TF3
   if (TENKAN3 >  KIJUN3)  Sit=0; // BULLISH Tenkan_Kijun cross
   if (TENKAN3 == KIJUN3)  Sit=1; // No Tenkan_Kijun cross
   if (TENKAN3 <  KIJUN3)  Sit=2; // BEARISH Tenkan_Kijun cross
   ObjectDelete("Tenkan_Kijun_3");
   ObjectCreate("Tenkan_Kijun_3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Tenkan_Kijun_3", OBJPROP_CORNER, 2);
   ObjectSet("Tenkan_Kijun_3", OBJPROP_XDISTANCE, XPOS3);
   ObjectSet("Tenkan_Kijun_3", OBJPROP_YDISTANCE, 320);
   ObjectSetText("Tenkan_Kijun_3",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  TENKAN3)  Sit=3; // Price above Tenkan
   if (Close[0] == TENKAN3)  Sit=4; // Price equal to Tenkan
   if (Close[0] <  TENKAN3)  Sit=5; // Price below Tenkan
   ObjectDelete("Price_Tenkan_3");
   ObjectCreate("Price_Tenkan_3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Price_Tenkan_3", OBJPROP_CORNER, 2);
   ObjectSet("Price_Tenkan_3", OBJPROP_XDISTANCE, XPOS3);
   ObjectSet("Price_Tenkan_3", OBJPROP_YDISTANCE, 300);
   ObjectSetText("Price_Tenkan_3",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] > SENKOUA3 && Close[0] > SENKOUB3) Sit=6; // PRICE above KUMO
   if (Close[0] < SENKOUA3 && Close[0] > SENKOUB3) Sit=7; // PRICE inside KUMO
   if (Close[0] > SENKOUA3 && Close[0] < SENKOUB3) Sit=7; // PRICE inside KUMO
   if (Close[0] < SENKOUA3 && Close[0] < SENKOUB3) Sit=8; // PRICE below KUMO
   ObjectDelete("Price_Kumo_3");
   ObjectCreate("Price_Kumo_3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Price_Kumo_3", OBJPROP_CORNER, 2);
   ObjectSet("Price_Kumo_3", OBJPROP_XDISTANCE, XPOS3);
   ObjectSet("Price_Kumo_3", OBJPROP_YDISTANCE, 280);
   ObjectSetText("Price_Kumo_3",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  xPRICE3)  Sit=9;  // Chikou Span above Price curve
   if (Close[0] == xPRICE3)  Sit=10; // Chikou Span equal to Price curve
   if (Close[0] <  xPRICE3)  Sit=11; // Chikou Span below Price Curve
   ObjectDelete("Chikou_Price_3");
   ObjectCreate("Chikou_Price_3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Price_3", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Price_3", OBJPROP_XDISTANCE, XPOS3);
   ObjectSet("Chikou_Price_3", OBJPROP_YDISTANCE, 260);
   ObjectSetText("Chikou_Price_3",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  xTENKAN3)  Sit=12; // Chikou above Tenkan curve
   if (Close[0] == xTENKAN3)  Sit=13; // Chikou equal to Tenkan curve
   if (Close[0] <  xTENKAN3)  Sit=14; // Chikou below Tenkan curve
   ObjectDelete("Chikou_Tenkan_3");
   ObjectCreate("Chikou_Tenkan_3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Tenkan_3", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Tenkan_3", OBJPROP_XDISTANCE, XPOS3);
   ObjectSet("Chikou_Tenkan_3", OBJPROP_YDISTANCE, 240);
   ObjectSetText("Chikou_Tenkan_3",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  xKIJUN3)  Sit=15; // Chikou above Kijun curve
   if (Close[0] == xKIJUN3)  Sit=16; // Chikou equal to Kijun curve
   if (Close[0] <  xKIJUN3)  Sit=17; // Chikou below Kijun curve
   ObjectDelete("Chikou_Kijun_3");
   ObjectCreate("Chikou_Kijun_3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Kijun_3", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Kijun_3", OBJPROP_XDISTANCE, XPOS3);
   ObjectSet("Chikou_Kijun_3", OBJPROP_YDISTANCE, 220);
   ObjectSetText("Chikou_Kijun_3",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] > xSENKOUA3 && Close[0] > xSENKOUB3) Sit=18; // Chikou above KUMO
   if (Close[0] < xSENKOUA3 && Close[0] > xSENKOUB3) Sit=19; // Chikou inside KUMO
   if (Close[0] > xSENKOUA3 && Close[0] < xSENKOUB3) Sit=19; // Chikou inside KUMO
   if (Close[0] < xSENKOUA3 && Close[0] < xSENKOUB3) Sit=20; // Chikou below KUMO
   ObjectDelete("Chikou_Kumo_3");
   ObjectCreate("Chikou_Kumo_3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Kumo_3", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Kumo_3", OBJPROP_XDISTANCE, XPOS3);
   ObjectSet("Chikou_Kumo_3", OBJPROP_YDISTANCE, 200);
   ObjectSetText("Chikou_Kumo_3",Text[Sit],10,"Arial",Color[Sit]);
//-------------------------------------------------------------------------- TF4
   if (TENKAN4 >  KIJUN4)  Sit=0; // BULLISH Tenkan_Kijun cross
   if (TENKAN4 == KIJUN4)  Sit=1; // No Tenkan_Kijun cross
   if (TENKAN4 <  KIJUN4)  Sit=2; // BEARISH Tenkan_Kijun cross
   ObjectDelete("Tenkan_Kijun_4");
   ObjectCreate("Tenkan_Kijun_4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Tenkan_Kijun_4", OBJPROP_CORNER, 2);
   ObjectSet("Tenkan_Kijun_4", OBJPROP_XDISTANCE, XPOS4);
   ObjectSet("Tenkan_Kijun_4", OBJPROP_YDISTANCE, 130);
   ObjectSetText("Tenkan_Kijun_4",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  TENKAN4)  Sit=3; // Price above Tenkan
   if (Close[0] == TENKAN4)  Sit=4; // Price equal to Tenkan
   if (Close[0] <  TENKAN4)  Sit=5; // Price below Tenkan
   ObjectDelete("Price_Tenkan_4");
   ObjectCreate("Price_Tenkan_4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Price_Tenkan_4", OBJPROP_CORNER, 2);
   ObjectSet("Price_Tenkan_4", OBJPROP_XDISTANCE, XPOS4);
   ObjectSet("Price_Tenkan_4", OBJPROP_YDISTANCE, 110);
   ObjectSetText("Price_Tenkan_4",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] > SENKOUA4 && Close[0] > SENKOUB4) Sit=6; // PRICE above KUMO
   if (Close[0] < SENKOUA4 && Close[0] > SENKOUB4) Sit=7; // PRICE inside KUMO
   if (Close[0] > SENKOUA4 && Close[0] < SENKOUB4) Sit=7; // PRICE inside KUMO
   if (Close[0] < SENKOUA4 && Close[0] < SENKOUB4) Sit=8; // PRICE below KUMO
   ObjectDelete("Price_Kumo_4");
   ObjectCreate("Price_Kumo_4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Price_Kumo_4", OBJPROP_CORNER, 2);
   ObjectSet("Price_Kumo_4", OBJPROP_XDISTANCE, XPOS4);
   ObjectSet("Price_Kumo_4", OBJPROP_YDISTANCE, 90);
   ObjectSetText("Price_Kumo_4",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  xPRICE4)  Sit=9;  // Chikou Span above Price curve
   if (Close[0] == xPRICE4)  Sit=10; // Chikou Span equal to Price curve
   if (Close[0] <  xPRICE4)  Sit=11; // Chikou Span below Price Curve
   ObjectDelete("Chikou_Price_4");
   ObjectCreate("Chikou_Price_4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Price_4", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Price_4", OBJPROP_XDISTANCE, XPOS4);
   ObjectSet("Chikou_Price_4", OBJPROP_YDISTANCE, 70);
   ObjectSetText("Chikou_Price_4",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  xTENKAN4)  Sit=12; // Chikou above Tenkan curve
   if (Close[0] == xTENKAN4)  Sit=13; // Chikou equal to Tenkan curve
   if (Close[0] <  xTENKAN4)  Sit=14; // Chikou below Tenkan curve
   ObjectDelete("Chikou_Tenkan_4");
   ObjectCreate("Chikou_Tenkan_4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Tenkan_4", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Tenkan_4", OBJPROP_XDISTANCE, XPOS4);
   ObjectSet("Chikou_Tenkan_4", OBJPROP_YDISTANCE, 50);
   ObjectSetText("Chikou_Tenkan_4",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  xKIJUN4)  Sit=15; // Chikou above Kijun curve
   if (Close[0] == xKIJUN4)  Sit=16; // Chikou equal to Kijun curve
   if (Close[0] <  xKIJUN4)  Sit=17; // Chikou below Kijun curve
   ObjectDelete("Chikou_Kijun_4");
   ObjectCreate("Chikou_Kijun_4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Kijun_4", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Kijun_4", OBJPROP_XDISTANCE, XPOS4);
   ObjectSet("Chikou_Kijun_4", OBJPROP_YDISTANCE, 30);
   ObjectSetText("Chikou_Kijun_4",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] > xSENKOUA4 && Close[0] > xSENKOUB4) Sit=18; // Chikou above KUMO
   if (Close[0] < xSENKOUA4 && Close[0] > xSENKOUB4) Sit=19; // Chikou inside KUMO
   if (Close[0] > xSENKOUA4 && Close[0] < xSENKOUB4) Sit=19; // Chikou inside KUMO
   if (Close[0] < xSENKOUA4 && Close[0] < xSENKOUB4) Sit=20; // Chikou below KUMO
   ObjectDelete("Chikou_Kumo_4");
   ObjectCreate("Chikou_Kumo_4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Kumo_4", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Kumo_4", OBJPROP_XDISTANCE, XPOS4);
   ObjectSet("Chikou_Kumo_4", OBJPROP_YDISTANCE, 10);
   ObjectSetText("Chikou_Kumo_4",Text[Sit],10,"Arial",Color[Sit]);
  //--------------------------------------------------------------------- TF5
   if (TENKAN5 >  KIJUN5)  Sit=0; // BULLISH Tenkan_Kijun cross
   if (TENKAN5 == KIJUN5)  Sit=1; // No Tenkan_Kijun cross
   if (TENKAN5 <  KIJUN5)  Sit=2; // BEARISH Tenkan_Kijun cross
   ObjectDelete("Tenkan_Kijun_5");
   ObjectCreate("Tenkan_Kijun_5", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Tenkan_Kijun_5", OBJPROP_CORNER, 2);
   ObjectSet("Tenkan_Kijun_5", OBJPROP_XDISTANCE, XPOS5);
   ObjectSet("Tenkan_Kijun_5", OBJPROP_YDISTANCE, 130);
   ObjectSetText("Tenkan_Kijun_5",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  TENKAN5)  Sit=3; // Price above Tenkan
   if (Close[0] == TENKAN5)  Sit=4; // Price equal to Tenkan
   if (Close[0] <  TENKAN5)  Sit=5; // Price below Tenkan
   ObjectDelete("Price_Tenkan_5");
   ObjectCreate("Price_Tenkan_5", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Price_Tenkan_5", OBJPROP_CORNER, 2);
   ObjectSet("Price_Tenkan_5", OBJPROP_XDISTANCE, XPOS5);
   ObjectSet("Price_Tenkan_5", OBJPROP_YDISTANCE, 110);
   ObjectSetText("Price_Tenkan_5",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] > SENKOUA5 && Close[0] > SENKOUB5) Sit=6; // PRICE above KUMO
   if (Close[0] < SENKOUA5 && Close[0] > SENKOUB5) Sit=7; // PRICE inside KUMO
   if (Close[0] > SENKOUA5 && Close[0] < SENKOUB5) Sit=7; // PRICE inside KUMO
   if (Close[0] < SENKOUA5 && Close[0] < SENKOUB5) Sit=8; // PRICE below KUMO
   ObjectDelete("Price_Kumo_5");
   ObjectCreate("Price_Kumo_5", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Price_Kumo_5", OBJPROP_CORNER, 2);
   ObjectSet("Price_Kumo_5", OBJPROP_XDISTANCE, XPOS5);
   ObjectSet("Price_Kumo_5", OBJPROP_YDISTANCE, 90);
   ObjectSetText("Price_Kumo_5",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  xPRICE5)  Sit=9;  // Chikou Span above Price curve
   if (Close[0] == xPRICE5)  Sit=10; // Chikou Span equal to Price curve
   if (Close[0] <  xPRICE5)  Sit=11; // Chikou Span below Price Curve
   ObjectDelete("Chikou_Price_5");
   ObjectCreate("Chikou_Price_5", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Price_5", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Price_5", OBJPROP_XDISTANCE, XPOS5);
   ObjectSet("Chikou_Price_5", OBJPROP_YDISTANCE, 70);
   ObjectSetText("Chikou_Price_5",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  xTENKAN5)  Sit=12; // Chikou above Tenkan curve
   if (Close[0] == xTENKAN5)  Sit=13; // Chikou equal to Tenkan curve
   if (Close[0] <  xTENKAN5)  Sit=14; // Chikou below Tenkan curve
   ObjectDelete("Chikou_Tenkan_5");
   ObjectCreate("Chikou_Tenkan_5", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Tenkan_5", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Tenkan_5", OBJPROP_XDISTANCE, XPOS5);
   ObjectSet("Chikou_Tenkan_5", OBJPROP_YDISTANCE, 50);
   ObjectSetText("Chikou_Tenkan_5",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  xKIJUN5)  Sit=15; // Chikou above Kijun curve
   if (Close[0] == xKIJUN5)  Sit=16; // Chikou equal to Kijun curve
   if (Close[0] <  xKIJUN5)  Sit=17; // Chikou below Kijun curve
   ObjectDelete("Chikou_Kijun_5");
   ObjectCreate("Chikou_Kijun_5", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Kijun_5", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Kijun_5", OBJPROP_XDISTANCE, XPOS5);
   ObjectSet("Chikou_Kijun_5", OBJPROP_YDISTANCE, 30);
   ObjectSetText("Chikou_Kijun_5",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] > xSENKOUA5 && Close[0] > xSENKOUB5) Sit=18; // Chikou above KUMO
   if (Close[0] < xSENKOUA5 && Close[0] > xSENKOUB5) Sit=19; // Chikou inside KUMO
   if (Close[0] > xSENKOUA5 && Close[0] < xSENKOUB5) Sit=19; // Chikou inside KUMO
   if (Close[0] < xSENKOUA5 && Close[0] < xSENKOUB5) Sit=20; // Chikou below KUMO
   ObjectDelete("Chikou_Kumo_5");
   ObjectCreate("Chikou_Kumo_5", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Kumo_5", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Kumo_5", OBJPROP_XDISTANCE, XPOS5);
   ObjectSet("Chikou_Kumo_5", OBJPROP_YDISTANCE, 10);
   ObjectSetText("Chikou_Kumo_5",Text[Sit],10,"Arial",Color[Sit]);
//--------------------------------------------------------------------- TF6
   if (TENKAN6 >  KIJUN6)  Sit=0; // BULLISH Tenkan_Kijun cross
   if (TENKAN6 == KIJUN6)  Sit=1; // No Tenkan_Kijun cross
   if (TENKAN6 <  KIJUN6)  Sit=2; // BEARISH Tenkan_Kijun cross
   ObjectDelete("Tenkan_Kijun_6");
   ObjectCreate("Tenkan_Kijun_6", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Tenkan_Kijun_6", OBJPROP_CORNER, 2);
   ObjectSet("Tenkan_Kijun_6", OBJPROP_XDISTANCE, XPOS6);
   ObjectSet("Tenkan_Kijun_6", OBJPROP_YDISTANCE, 130);
   ObjectSetText("Tenkan_Kijun_6",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  TENKAN6)  Sit=3; // Price above Tenkan
   if (Close[0] == TENKAN6)  Sit=4; // Price equal to Tenkan
   if (Close[0] <  TENKAN6)  Sit=5; // Price below Tenkan
   ObjectDelete("Price_Tenkan_6");
   ObjectCreate("Price_Tenkan_6", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Price_Tenkan_6", OBJPROP_CORNER, 2);
   ObjectSet("Price_Tenkan_6", OBJPROP_XDISTANCE, XPOS6);
   ObjectSet("Price_Tenkan_6", OBJPROP_YDISTANCE, 110);
   ObjectSetText("Price_Tenkan_6",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] > SENKOUA6 && Close[0] > SENKOUB6) Sit=6; // PRICE above KUMO
   if (Close[0] < SENKOUA6 && Close[0] > SENKOUB6) Sit=7; // PRICE inside KUMO
   if (Close[0] > SENKOUA6 && Close[0] < SENKOUB6) Sit=7; // PRICE inside KUMO
   if (Close[0] < SENKOUA6 && Close[0] < SENKOUB6) Sit=8; // PRICE below KUMO
   ObjectDelete("Price_Kumo_6");
   ObjectCreate("Price_Kumo_6", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Price_Kumo_6", OBJPROP_CORNER, 2);
   ObjectSet("Price_Kumo_6", OBJPROP_XDISTANCE, XPOS6);
   ObjectSet("Price_Kumo_6", OBJPROP_YDISTANCE, 90);
   ObjectSetText("Price_Kumo_6",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  xPRICE6)  Sit=9;  // Chikou Span above Price curve
   if (Close[0] == xPRICE6)  Sit=10; // Chikou Span equal to Price curve
   if (Close[0] <  xPRICE6)  Sit=11; // Chikou Span below Price Curve
   ObjectDelete("Chikou_Price_6");
   ObjectCreate("Chikou_Price_6", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Price_6", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Price_6", OBJPROP_XDISTANCE, XPOS6);
   ObjectSet("Chikou_Price_6", OBJPROP_YDISTANCE, 70);
   ObjectSetText("Chikou_Price_6",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  xTENKAN6)  Sit=12; // Chikou above Tenkan curve
   if (Close[0] == xTENKAN6)  Sit=13; // Chikou equal to Tenkan curve
   if (Close[0] <  xTENKAN6)  Sit=14; // Chikou below Tenkan curve
   ObjectDelete("Chikou_Tenkan_6");
   ObjectCreate("Chikou_Tenkan_6", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Tenkan_6", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Tenkan_6", OBJPROP_XDISTANCE, XPOS6);
   ObjectSet("Chikou_Tenkan_6", OBJPROP_YDISTANCE, 50);
   ObjectSetText("Chikou_Tenkan_6",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] >  xKIJUN6)  Sit=15; // Chikou above Kijun curve
   if (Close[0] == xKIJUN6)  Sit=16; // Chikou equal to Kijun curve
   if (Close[0] <  xKIJUN6)  Sit=17; // Chikou below Kijun curve
   ObjectDelete("Chikou_Kijun_6");
   ObjectCreate("Chikou_Kijun_6", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Kijun_6", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Kijun_6", OBJPROP_XDISTANCE, XPOS6);
   ObjectSet("Chikou_Kijun_6", OBJPROP_YDISTANCE, 30);
   ObjectSetText("Chikou_Kijun_6",Text[Sit],10,"Arial",Color[Sit]);

   if (Close[0] > xSENKOUA6 && Close[0] > xSENKOUB6) Sit=18; // Chikou above KUMO
   if (Close[0] < xSENKOUA6 && Close[0] > xSENKOUB6) Sit=19; // Chikou inside KUMO
   if (Close[0] > xSENKOUA6 && Close[0] < xSENKOUB6) Sit=19; // Chikou inside KUMO
   if (Close[0] < xSENKOUA6 && Close[0] < xSENKOUB6) Sit=20; // Chikou below KUMO
   ObjectDelete("Chikou_Kumo_6");
   ObjectCreate("Chikou_Kumo_6", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Chikou_Kumo_6", OBJPROP_CORNER, 2);
   ObjectSet("Chikou_Kumo_6", OBJPROP_XDISTANCE, XPOS6);
   ObjectSet("Chikou_Kumo_6", OBJPROP_YDISTANCE, 10);
   ObjectSetText("Chikou_Kumo_6",Text[Sit],10,"Arial",Color[Sit]);
//+-----------------------------------------------------------------+
   int Order = SIGNAL_NONE;
   int Total,Ticket;
   double StopLossLevel,TakeProfitLevel,TickValue,LotValue;
   string Txt,MMstat,Etick,TStop,TProfit;


   if (EachTickMode && Bars != BarCount) TickCheck = False;
   Total = OrdersTotal();
   Order = SIGNAL_NONE;

   if (UseMoneyMngt)
      {//B
       //Lots=(AccountFreeMargin()/MMfactor);// Use Money Management
         Lots=NormalizeDouble((AccountFreeMargin()/MMfactor),2);// Use Money Management
         if (AccountFreeMargin() < 50) Lots = MinLot;
         TickValue = (MarketInfo(Symbol(),MODE_TICKVALUE)*Lots);
         if(Digits == 5 || Digits == 3)TickValue = TickValue*1;
         LotValue = (MarketInfo(Symbol(),MODE_TICKVALUE));
         if(Digits == 5 || Digits == 3)LotValue = LotValue*1;
         MMstat = "Yes";
      }//b
   else
      {//B
         Lots = MinLot;
         TickValue = (MarketInfo(Symbol(),MODE_TICKVALUE)*Lots);// No Money Management
         if(Digits == 5 || Digits == 3)TickValue = TickValue*1;
         LotValue = (MarketInfo(Symbol(),MODE_TICKVALUE));
         if(Digits == 5 || Digits == 3)LotValue = LotValue*1;
         MMstat = "No";
      }//b

   if (UseTakeProfit)
      {//B
         TProfit = "Yes";
         if (TakeProfit < SPREAD)
            TakeProfit = SPREAD;
      }//b
   else
      TProfit = "No";

   if (UseTrailingStop)
      {//B
         TStop = "Yes";
         if (TrailingStop < SPREAD)
            TrailingStop = SPREAD;
         if (UseATRTS)
            TrailingStop = ATR*ATRfactor/Point;
      }//b
   else
      TStop   = "No";

   if (EachTickMode)    Etick = "No"; else Etick   = "Yes";

   Txt=
   "\nFree Margin = " + NormalizeDouble(AccountFreeMargin(),2)+
   //"\nUse Money Management = " + MMstat +
   //"\nUse MM Factor = " + MMfactor +
   "\nLots = " + Lots +
   "\nPip Value = " + NormalizeDouble(TickValue,2) +
   //"\nComplete Bar = " + Etick +
   "\nUse Trailing Stop = " + TStop +
   //"\nATR = " + ATR +
   //"\nATRfactor = " + ATRfactor +
   "\nTrailing Stop = " + TrailingStop
   ;

   //Comment(Txt);

   // Check position
   bool IsTrade = False;
   for (int i = 0; i < Total; i ++)
      {//B
         OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         if(OrderType() <= OP_SELL &&  OrderSymbol() == Symbol())
            {//C
               IsTrade = True;
               if(OrderType() == OP_BUY)
                  {//D
//----------------------------------------------CLOSEBUY strategies
                     //if (Close[0] < CHIKOU1) Order = SIGNAL_CLOSEBUY;
                     if (Order == SIGNAL_CLOSEBUY && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount))))
                        {//E
                           Alert("CLOSE BUY ",Symbol());
                           OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, MediumSeaGreen);
                           ObjectDelete("xLine");
                           ObjectCreate("xLine",OBJ_VLINE,0,TimeCurrent(),0);
                           ObjectSet("xLine", OBJPROP_COLOR, Red);
                           if (!EachTickMode) BarCount = Bars;
                           IsTrade = False;
                           continue;
                        }//e
                     // BUY Trailing stop
                     if(UseTrailingStop && TrailingStop > 0)
                        {//E
                           if(Bid - OrderOpenPrice() > Point * TrailingStop)
                              {//F
                                 if(OrderStopLoss() < Bid - Point * TrailingStop)
                                    {//G
                                       OrderModify(OrderTicket(), OrderOpenPrice(), Bid - Point * TrailingStop, OrderTakeProfit(), 0, MediumSeaGreen);
                                       if (!EachTickMode) BarCount = Bars;
                                       continue;
                                    }//g
                              }//f
                        }//e
                  }//d
               else
                  {//D
//----------------------------------------------CLOSESELL strategies
                     //if (Close[0] > CHIKOU1) Order = SIGNAL_CLOSESELL;
                     if (Order == SIGNAL_CLOSESELL && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount))))
                        {//E
                           Alert("CLOSE SELL ",Symbol());
                           OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, DarkOrange);
                           ObjectDelete("xLine");
                           ObjectCreate("xLine",OBJ_VLINE,0,TimeCurrent(),0);
                           ObjectSet("xLine", OBJPROP_COLOR, Red);
                           if (!EachTickMode) BarCount = Bars;
                           IsTrade = False;
                           continue;
                        }//e
                     // SELL Trailing stop
                     if(UseTrailingStop && TrailingStop > 0)
                        {//E
                           if((OrderOpenPrice() - Ask) > (Point * TrailingStop))
                              {//F
                                 if((OrderStopLoss() > (Ask + Point * TrailingStop)) || (OrderStopLoss() == 0))
                                    {//G
                                       OrderModify(OrderTicket(), OrderOpenPrice(), Ask + Point * TrailingStop, OrderTakeProfit(), 0, DarkOrange);
                                       if (!EachTickMode) BarCount = Bars;
                                       continue;
                                    }//g
                              }//f
                        }//e
                  }//d
            }//c
      }//b

   // BUY conditions

   /*if (
      Close[0] > xTENKAN &&
      Close[0] > xKIJUN &&
      Close[0] > xSENKOUB &&

      Close[0] > TENKAN2 &&
      TENKAN2  > KIJUN2 &&
      Close[0] > SENKOUA2 &&
      Close[0] > SENKOUB2 &&
      Close[0] > PriceCurve2 &&

      Close[0] > TENKAN3 &&
      TENKAN2  > KIJUN3 &&
      Close[0] > SENKOUA3 &&
      Close[0] > SENKOUB3 &&
      Close[0] > PriceCurve3 &&

      RSI47  < 2 &&
      RSI711 < 2 &&
      RSI411 < 2
      ) Order = SIGNAL_BUY;

   // SELL conditions

   if (
      Close[0] < xTENKAN &&
      Close[0] < xKIJUN &&
      Close[0] < xSENKOUB &&

      Close[0] < TENKAN2 &&
      TENKAN2  < KIJUN2 &&
      Close[0] < SENKOUA2 &&
      Close[0] < SENKOUB2 &&
      Close[0] < PriceCurve2 &&

      Close[0] < TENKAN3 &&
      TENKAN2  < KIJUN3 &&
      Close[0] < SENKOUA3 &&
      Close[0] < SENKOUB3 &&
      Close[0] < PriceCurve3 
      ) Order = SIGNAL_SELL;*/

   // Order BUY
   if (Order == SIGNAL_BUY && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount))))
      {//B
         if(!IsTrade)
            {//C
               if (AccountFreeMargin() < 0)
                  {//D
                     Print("We have no money. Free Margin = ",AccountFreeMargin());return(0);
                  }//d
               if (UseTakeProfit) TakeProfitLevel = Ask + TakeProfit * Point; else TakeProfitLevel = 0.0;
               //Ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,StopLossLevel,TakeProfitLevel,REM + EntryTF,MagicNumber,0,DodgerBlue);
               if(Ticket > 0)
                  {//D
                     if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES))
                        {//E
                           Alert("BUY ",Symbol());
                           ObjectDelete("Line");
                           ObjectCreate("Line",OBJ_VLINE,0,TimeCurrent(),0);
                           ObjectSet("Line", OBJPROP_COLOR, Yellow);
                        }//e
                     else
                        {//E
                           Print("Error opening BUY order : ", GetLastError());
                        }//e
                  }//d
               if (EachTickMode) TickCheck = True;
               if (!EachTickMode) BarCount = Bars;
               return(0);
            }//c
      }//b
   //Order SELL
   if (Order == SIGNAL_SELL && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount))))
      {//B
         if(!IsTrade)
            {//C
               if (AccountFreeMargin() < 0)
                  {//D
                     Print("We have no money. Free Margin = ", AccountFreeMargin());return(0);
                  }//d
               if (UseTakeProfit) TakeProfitLevel = Bid - TakeProfit * Point; else TakeProfitLevel = 0.0;
               //Ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,StopLossLevel,TakeProfitLevel,REM + EntryTF,MagicNumber,0,DeepPink);
               if(Ticket > 0)
                  {//D
                     if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES))
                        {//E
                           Alert("SELL ",Symbol());
                           ObjectDelete("Line");
                           ObjectCreate("Line",OBJ_VLINE,0,TimeCurrent(),0);
                           ObjectSet("Line", OBJPROP_COLOR, Yellow);
                        }//e
                     else
                        {//E
                           Print("Error opening SELL order : ", GetLastError());
                        }//e
                  }//d
               if (EachTickMode) TickCheck = True;
               if (!EachTickMode) BarCount = Bars;
               return(0);
            }//c
      }//b
   if (!EachTickMode) BarCount = Bars;
   return(0);
}//a
//+------------------------------------------------------------------+


