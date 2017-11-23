/*
!xMeter.mq4     
Copyright © 2007, MetaQuotes Software Corp.     
Price Meter System™ ©GPL     

Robert Hill
   5/16/2007 Corrected problem with IBFX mini Account

*/


#property copyright "x Meter System™ ©GPL"
#property link      "forex-tsd dot com"

#define ARRSIZE  18                     // number of pairs !!!DON'T CHANGE THIS NUMBER!!!
#define PAIRSIZE 8                      // number of currencies !!!DON'T CHANGE THIS NUMBER!!!
#define TABSIZE  10                     // scale of currency's power !!!DON'T CHANGE THIS NUMBER!!!
#define ORDER    2                      // available type of order !!!DON'T CHANGE THIS NUMBER!!!

// Added to make code easier to understand
// Currency pair
#define EURUSD 0
#define GBPUSD 1
#define AUDUSD 2
#define USDJPY 3
#define USDCHF 4
#define USDCAD 5
#define EURJPY 6
#define EURGBP 7
#define EURCHF 8
#define EURAUD 9
#define GBPJPY 10
#define GBPCHF 11
#define NZDUSD 12
#define EURNZD 13
#define GBPNZD 14
#define AUDNZD 15
#define NZDCAD 16
#define NZDCHF 17
#define NZDJPY 18

// Currency
#define USD 0
#define EUR 1
#define GBP 2
#define CHF 3                                                                                      
#define CAD 4                                                                                      
#define AUD 5                                                                                      
#define JPY 6                                                                                      
#define NZD 7                                                                                      
                                                                                                   
extern bool AccountIsIBFXmini = TRUE;

   string aPair[ARRSIZE]   = {"EURUSDm","GBPUSDm","AUDUSDm","USDJPYm","USDCHFm","USDCADm",
                              "EURJPYm","EURGBPm","EURCHFm","EURAUDm","GBPJPYm","GBPCHFm","NZDUSDm","NEURNZDm","NGBPNZDm","NAUDNZDm","NNZDCADm","NNZDCHFm","NNZDJPYm"};
   string aMajor[PAIRSIZE] = {"USD","EUR","GBP","CHF","CAD","AUD","JPY","NZD"};
   string aOrder[ORDER]    = {"BUY ","SELL "};

//+------------------------------------------------------------------+
//     expert initialization function                                |       
//+------------------------------------------------------------------+
int init()
  {
   int   err,lastError;
//----
   initGraph();
   while (true)                                                             // infinite loop for main program
      {
      if (IsConnected()) main();
      if (!IsConnected()) objectBlank();
      WindowRedraw();
      Sleep(1000);                                                          // give your PC a breath
      }
//----
   return(0);                                                               // end of init function
  }
//+------------------------------------------------------------------+
//     expert deinitialization function                              |       
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectsDeleteAll(0,OBJ_LABEL);
   Print("shutdown error - ",GetLastError());                               // system is detached from platform
//----
   return(0);                                                               // end of deinit function
  }
//+------------------------------------------------------------------+
//     expert start function                                         |       
//+------------------------------------------------------------------+
int start()
  {
//----

//----
   return(0);                                                               // end of start funtion
  }
//+------------------------------------------------------------------+
//     expert custom function                                        |       
//+------------------------------------------------------------------+    
void main()                                                                 // this a control center
  {
//----
   double aMeter[PAIRSIZE];
   double aHigh[ARRSIZE];
   double aLow[ARRSIZE];
   double aBid[ARRSIZE];
   double aAsk[ARRSIZE];
   double aRatio[ARRSIZE];
   double aRange[ARRSIZE];
   double aLookup[ARRSIZE];
   double aStrength[ARRSIZE];
   double point;
   int    index;
   string mySymbol;
     
   for (index = 0; index < ARRSIZE; index++)                                // initialize all pairs required value 
      {
      RefreshRates();                                                       // refresh all currency's instrument
      if (AccountIsIBFXmini)
         mySymbol = aPair[index];
      else
         mySymbol = StringSubstr(aPair[index],0,6);                        // Only look at first 6 characters of pair
      point            = GetPoint(mySymbol);               // get a point basis
      aHigh[index]     = MarketInfo(mySymbol,MODE_HIGH);                // set a high today
      aLow[index]      = MarketInfo(mySymbol,MODE_LOW);                 // set a low today
      aBid[index]      = MarketInfo(mySymbol,MODE_BID);                 // set a last bid
      aAsk[index]      = MarketInfo(mySymbol,MODE_ASK);                 // set a last ask
      aRange[index]    = MathMax((aHigh[index]-aLow[index])/point,1);       // calculate range today
      aRatio[index]    = (aBid[index]-aLow[index])/aRange[index]/point;     // calculate pair ratio
      aLookup[index]   = iLookup(aRatio[index]*100);                        // set a pair grade
      aStrength[index] = 9-aLookup[index];                                  // set a pair strengh
      } 

   // calculate all currencies meter         
   aMeter[USD] = NormalizeDouble((aLookup[USDJPY]+aLookup[USDCHF]+aLookup[USDCAD]+aStrength[EURUSD]+aStrength[GBPUSD]+aStrength[AUDUSD])/6,1);
   aMeter[EUR] = NormalizeDouble((aLookup[EURUSD]+aLookup[EURJPY]+aLookup[EURGBP]+aLookup[EURCHF]+aLookup[EURAUD])/5,1);
   aMeter[GBP] = NormalizeDouble((aLookup[GBPUSD]+aLookup[GBPJPY]+aLookup[GBPCHF]+aStrength[EURGBP])/4,1);
   aMeter[CHF] = NormalizeDouble((aStrength[USDCHF]+aStrength[EURCHF]+aStrength[GBPCHF])/3,1);
   aMeter[CAD] = NormalizeDouble((aStrength[USDCAD]),1);
   aMeter[AUD] = NormalizeDouble((aLookup[AUDUSD]+aStrength[EURAUD])/2,1);
   aMeter[JPY] = NormalizeDouble((aStrength[USDJPY]+aStrength[EURJPY]+aStrength[GBPJPY])/3,1);     
   aMeter[NZD] = NormalizeDouble((aLookup[NZDUSD]+aStrength[EURNZD]+aStrength[GBPNZD]+aStrength[AUDNZD]+aLookup[NZDCAD]+aLookup[NZDCHF]+aLookup[NZDJPY])/7,1);



/*
   aMeter[0] = NormalizeDouble((aLookup[3]+aLookup[4]+aLookup[5]+aStrength[0]+aStrength[1]+aStrength[2])/6,1);
   aMeter[1] = NormalizeDouble((aLookup[0]+aLookup[6]+aLookup[7]+aLookup[8]+aLookup[9])/5,1);
   aMeter[2] = NormalizeDouble((aLookup[1]+aLookup[10]+aLookup[11]+aStrength[7])/4,1);
   aMeter[3] = NormalizeDouble((aStrength[4]+aStrength[8]+aStrength[11])/3,1);
   aMeter[4] = NormalizeDouble((aStrength[5]),1);
   aMeter[5] = NormalizeDouble((aLookup[2]+aStrength[9])/2,1);
   aMeter[6] = NormalizeDouble((aStrength[3]+aStrength[6]+aStrength[10])/3,1);     
*/
             
   objectBlank();   
   paintUSD(aMeter[USD]);
   paintEUR(aMeter[EUR]);
   paintGBP(aMeter[GBP]);
   paintCHF(aMeter[CHF]);
   paintCAD(aMeter[CAD]);
   paintAUD(aMeter[AUD]);
   paintJPY(aMeter[JPY]);
   paintNZD(aMeter[NZD]);
   paintLine();
   //----
  }
  
double GetPoint(string mSymbol)
{

  double myPoint = 0.0001, YenPoint = 0.01;


 string mySymbol;
 
 mySymbol = StringSubstr(mSymbol,0,6);                        // Only look at first 6 characters of pair
 
 if (mySymbol == "USDJPY") return (YenPoint);
 if (mySymbol == "EURJPY") return (YenPoint);
 if (mySymbol == "GBPJPY") return (YenPoint);

 return(myPoint);

}

int iLookup(double ratio)                                                   // this function will return a grade value
  {                                                                         // based on its power.
   int    aTable[TABSIZE]  = {0,3,10,25,40,50,60,75,90,97};                 // grade table for currency's power
   int   index;
   
   if      (ratio <= aTable[0]) index = 0;
   else if (ratio < aTable[1])  index = 0;
   else if (ratio < aTable[2])  index = 1;
   else if (ratio < aTable[3])  index = 2;
   else if (ratio < aTable[4])  index = 3;
   else if (ratio < aTable[5])  index = 4;
   else if (ratio < aTable[6])  index = 5;
   else if (ratio < aTable[7])  index = 6;
   else if (ratio < aTable[8])  index = 7;
   else if (ratio < aTable[9])  index = 8;
   else                         index = 9;
   return(index);                                                           // end of iLookup function
  }
  
void initGraph()
  {
   ObjectsDeleteAll(0,OBJ_LABEL);

   objectCreate("usd_1",150,43);
   objectCreate("usd_2",150,35);
   objectCreate("usd_3",150,27);
   objectCreate("usd_4",150,19);
   objectCreate("usd_5",150,11);
   objectCreate("usd",152,12,"USD",7,"Arial Narrow",SkyBlue);
   objectCreate("usdp",154,21,DoubleToStr(9,1),8,"Arial Narrow",Silver);
   
   objectCreate("eur_1",130,43);
   objectCreate("eur_2",130,35);
   objectCreate("eur_3",130,27);
   objectCreate("eur_4",130,19);
   objectCreate("eur_5",130,11);
   objectCreate("eur",132,12,"EUR",7,"Arial Narrow",SkyBlue);
   objectCreate("eurp",134,21,DoubleToStr(9,1),8,"Arial Narrow",Silver);
   
   objectCreate("gbp_1",110,43);
   objectCreate("gbp_2",110,35);
   objectCreate("gbp_3",110,27);
   objectCreate("gbp_4",110,19);
   objectCreate("gbp_5",110,11);
   objectCreate("gbp",112,12,"GBP",7,"Arial Narrow",SkyBlue);
   objectCreate("gbpp",114,21,DoubleToStr(9,1),8,"Arial Narrow",Silver);
   
   objectCreate("chf_1",90,43);
   objectCreate("chf_2",90,35);
   objectCreate("chf_3",90,27);
   objectCreate("chf_4",90,19);
   objectCreate("chf_5",90,11);
   objectCreate("chf",92,12,"CHF",7,"Arial Narrow",SkyBlue);
   objectCreate("chfp",94,21,DoubleToStr(9,1),8,"Arial Narrow",Silver);

   objectCreate("cad_1",70,43);
   objectCreate("cad_2",70,35);   
   objectCreate("cad_3",70,27);
   objectCreate("cad_4",70,19);
   objectCreate("cad_5",70,11);
   objectCreate("cad",72,12,"CAD",7,"Arial Narrow",SkyBlue);
   objectCreate("cadp",74,21,DoubleToStr(9,1),8,"Arial Narrow",Silver);
   
   objectCreate("aud_1",50,43);
   objectCreate("aud_2",50,35);
   objectCreate("aud_3",50,27);
   objectCreate("aud_4",50,19);
   objectCreate("aud_5",50,11);
   objectCreate("aud",52,12,"AUD",7,"Arial Narrow",SkyBlue);
   objectCreate("audp",54,21,DoubleToStr(9,1),8,"Arial Narrow",Silver);

   objectCreate("jpy_1",30,43);
   objectCreate("jpy_2",30,35);
   objectCreate("jpy_3",30,27);
   objectCreate("jpy_4",30,19);
   objectCreate("jpy_5",30,11);
   objectCreate("jpy",33,12,"JPY",7,"Arial Narrow",SkyBlue);
   objectCreate("jpyp",34,21,DoubleToStr(9,1),8,"Arial Narrow",Silver);
   
   objectCreate("nzd_1",10,43);
   objectCreate("nzd_2",10,35);
   objectCreate("nzd_3",10,27);
   objectCreate("nzd_4",10,19);
   objectCreate("nzd_5",10,11);
   objectCreate("nzd",13,12,"NZD",7,"Arial Narrow",SkyBlue);
   objectCreate("nzdp",14,21,DoubleToStr(9,1),8,"Arial Narrow",Silver);

   objectCreate("line",10,6,"-----------------------------------",10,"Arial",DimGray);  
   objectCreate("line1",10,27,"-----------------------------------",10,"Arial",DimGray);  
   objectCreate("line2",10,69,"-----------------------------------",10,"Arial",DimGray);
   objectCreate("sign",11,1,"»»» Price Meter System™ ©GPL «««",8,"Arial Narrow",DimGray);
   WindowRedraw();
  }
//+------------------------------------------------------------------+
void objectCreate(string name,int x,int y,string text="-",int size=42,
                  string font="Arial",color colour=CLR_NONE)
  {
   ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_CORNER,3);
   ObjectSet(name,OBJPROP_COLOR,colour);
   ObjectSet(name,OBJPROP_XDISTANCE,x);
   ObjectSet(name,OBJPROP_YDISTANCE,y);
   ObjectSetText(name,text,size,font,colour);
  }

void objectBlank()
  {
   ObjectSet("usd_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("usd_2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("usd_3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("usd_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("usd_5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("usd",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("usdp",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("eur_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("eur_2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("eur_3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("eur_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("eur_5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("eur",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("eurp",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("gbp_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("gbp_2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("gbp_3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("gbp_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("gbp_5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("gbp",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("gbpp",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("chf_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("chf_2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("chf_3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("chf_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("chf_5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("chf",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("chfp",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("cad_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("cad_2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("cad_3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("cad_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("cad_5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("cad",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("cadp",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("aud_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("aud_2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("aud_3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("aud_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("aud_5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("aud",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("audp",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("jpy_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("jpy_2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("jpy_3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("jpy_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("jpy_5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("jpy",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("jpyp",OBJPROP_COLOR,CLR_NONE);
   
   ObjectSet("nzd_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("nzd_2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("nzd_3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("nzd_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("nzd_5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("nzd",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("nzdp",OBJPROP_COLOR,CLR_NONE);

   ObjectSet("line1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("line2",OBJPROP_COLOR,CLR_NONE); 
  }
  
void paintUSD(double value)
  {
   if (value > 0) ObjectSet("usd_5",OBJPROP_COLOR,Red);
   if (value > 2) ObjectSet("usd_4",OBJPROP_COLOR,Orange);
   if (value > 4) ObjectSet("usd_3",OBJPROP_COLOR,Gold);   
   if (value > 6) ObjectSet("usd_2",OBJPROP_COLOR,YellowGreen);
   if (value > 7) ObjectSet("usd_1",OBJPROP_COLOR,Lime);
   ObjectSet("usd",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("usdp",DoubleToStr(value,1),8,"Arial Narrow",Silver);
  }

void paintEUR(double value)
  {
   if (value > 0) ObjectSet("eur_5",OBJPROP_COLOR,Red);
   if (value > 2) ObjectSet("eur_4",OBJPROP_COLOR,Orange);
   if (value > 4) ObjectSet("eur_3",OBJPROP_COLOR,Gold);   
   if (value > 6) ObjectSet("eur_2",OBJPROP_COLOR,YellowGreen);
   if (value > 7) ObjectSet("eur_1",OBJPROP_COLOR,Lime);
   ObjectSet("eur",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("eurp",DoubleToStr(value,1),8,"Arial Narrow",Silver);
  }

void paintGBP(double value)
  {
   if (value > 0) ObjectSet("gbp_5",OBJPROP_COLOR,Red);
   if (value > 2) ObjectSet("gbp_4",OBJPROP_COLOR,Orange);
   if (value > 4) ObjectSet("gbp_3",OBJPROP_COLOR,Gold);   
   if (value > 6) ObjectSet("gbp_2",OBJPROP_COLOR,YellowGreen);
   if (value > 7) ObjectSet("gbp_1",OBJPROP_COLOR,Lime);
   ObjectSet("gbp",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("gbpp",DoubleToStr(value,1),8,"Arial Narrow",Silver);
  }

void paintCHF(double value)
  {
   if (value > 0) ObjectSet("chf_5",OBJPROP_COLOR,Red);
   if (value > 2) ObjectSet("chf_4",OBJPROP_COLOR,Orange);
   if (value > 4) ObjectSet("chf_3",OBJPROP_COLOR,Gold);   
   if (value > 6) ObjectSet("chf_2",OBJPROP_COLOR,YellowGreen);
   if (value > 7) ObjectSet("chf_1",OBJPROP_COLOR,Lime);
   ObjectSet("chf",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("chfp",DoubleToStr(value,1),8,"Arial Narrow",Silver);
  }

void paintCAD(double value)
  {
   if (value > 0) ObjectSet("cad_5",OBJPROP_COLOR,Red);
   if (value > 2) ObjectSet("cad_4",OBJPROP_COLOR,Orange);
   if (value > 4) ObjectSet("cad_3",OBJPROP_COLOR,Gold);   
   if (value > 6) ObjectSet("cad_2",OBJPROP_COLOR,YellowGreen);
   if (value > 7) ObjectSet("cad_1",OBJPROP_COLOR,Lime);
   ObjectSet("cad",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("cadp",DoubleToStr(value,1),8,"Arial Narrow",Silver);
  }

void paintAUD(double value)
  {
   if (value > 0) ObjectSet("aud_5",OBJPROP_COLOR,Red);
   if (value > 2) ObjectSet("aud_4",OBJPROP_COLOR,Orange);
   if (value > 4) ObjectSet("aud_3",OBJPROP_COLOR,Gold);   
   if (value > 6) ObjectSet("aud_2",OBJPROP_COLOR,YellowGreen);
   if (value > 7) ObjectSet("aud_1",OBJPROP_COLOR,Lime);
   ObjectSet("aud",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("audp",DoubleToStr(value,1),8,"Arial Narrow",Silver);
  }

void paintJPY(double value)
  {
   if (value > 0) ObjectSet("jpy_5",OBJPROP_COLOR,Red);
   if (value > 2) ObjectSet("jpy_4",OBJPROP_COLOR,Orange);
   if (value > 4) ObjectSet("jpy_3",OBJPROP_COLOR,Gold);   
   if (value > 6) ObjectSet("jpy_2",OBJPROP_COLOR,YellowGreen);
   if (value > 7) ObjectSet("jpy_1",OBJPROP_COLOR,Lime);
   ObjectSet("jpy",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("jpyp",DoubleToStr(value,1),8,"Arial Narrow",Silver);
  }
  
void paintNZD(double value)
  {
   if (value > 0) ObjectSet("nzd_5",OBJPROP_COLOR,Red);
   if (value > 2) ObjectSet("nzd_4",OBJPROP_COLOR,Orange);
   if (value > 4) ObjectSet("nzd_3",OBJPROP_COLOR,Gold);   
   if (value > 6) ObjectSet("nzd_2",OBJPROP_COLOR,YellowGreen);
   if (value > 7) ObjectSet("nzd_1",OBJPROP_COLOR,Lime);
   ObjectSet("nzd",OBJPROP_COLOR,SkyBlue);
   ObjectSetText("nzdp",DoubleToStr(value,1),8,"Arial Narrow",Silver);
  }

void paintLine()
  {
   ObjectSet("line1",OBJPROP_COLOR,DimGray);
   ObjectSet("line2",OBJPROP_COLOR,DimGray);
  }

