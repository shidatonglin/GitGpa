//+------------------------------------------------------------------+
//|                                                 OzFX Signals.mq4 |
//|                                           Copyright © 2008, Daud |
//|                                          http://www.ozfx.com.au/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Daud"
#property link      "http://www.ozfx.com.au/"

/*
   == Updates ==   
   03/03/08:: by lac_raz. Separate indicator window and signal maximum 20 pairs
   03/03/08:: v1.1 Modified by ydaudw. Add more signal maximum 24 pairs. Integrate with main chart.
   03/04/08:: v1.2 Modified by ydaudw. Add more parameter for filtering Original Method and when 
              signal was generate.
   03/07/08:: v1.3 Modified by ydaudw. Some update & bug fixed.
   03/08/08:: v1.4 Modified by ydaudw. Give options to customize period and fix some bugs.
   03/17/08:: v1.5 Show when the next bar emerge and fix AES duplication signal.
   03/24/08:: v1.6 Add Squeeze-More signal.
*/

#property indicator_chart_window

extern string PairsList = "Gold,EURUSD,EURCHF,EURGBP,USDJPY,AUDUSD,EURJPY,GBPUSD,GBPJPY,USDCAD,USDCHF,NZDUSD,CHFJPY,CADJPY,EURAUD,EURCAD,GBPCHF,AUDJPY";//- This is where you add the currency pairs you want 
extern string SymbolSuffix = "";//- If your broker names the currency pairs with a suffix for a mini account (like an "m", for example), enter the suffix here
extern bool ShowTimeTillNextBar = False;
extern bool ShowAESSignal = True;
extern bool Show4HoursSqueezeMore = True;
extern bool SMAFilterOriginal = True;
extern int SMAFilterPeriod = 200;
extern int StochKPeriod = 5;
extern int StochDPeriod = 3;
extern int StochSlowing = 4;
extern int ATRPeriod = 5;
extern int Low_TF = 60;
extern bool SendEmail = false;

string Pair[24]; //Pairs array
int SymNo;
int k;

int init()
{
   string short_name="OZFXPAIRS";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   
   int i,j,k;
   string Cur;
   
   for (i=0, j=0, k=1; i<24 && k>0;)
   {
      k=StringFind(PairsList,",",j);
      if (k==0) Cur=StringSubstr(PairsList,j,0);
      else Cur=StringSubstr(PairsList,j,k-j);
      
      Pair[i]=Cur;
      i++;
     
      j=StringFind(PairsList,",",j)+1;
      if (j==0) break;
   }
   SymNo = i;
   
   return(0);
}

int start() {
   string aesPairs[24];
   string ozfxRegPairs[24];
   string sqzmorePairs[24];
   string rsiomaPairs[24];
   int i,k,regindex,aesindex,sqzindex,risomaIndex;
   datetime previousTime;

   for(i=0,regindex=0,aesindex=0,sqzindex=0;i<SymNo;i++) 
   {
      string currPair = Pair[i]+SymbolSuffix;

/*------------------*/
/*  Variable Begin  */
/*------------------*/
      // double AC0 = iAC(currPair,0,0);
      // double AC1 = iAC(currPair,0,1);
      // double AO0 = iAO(currPair,0,0);
      // double AO1 = iAO(currPair,0,1);
      // string ATR = DoubleToStr(iATR(currPair,0,ATRPeriod,0),5);
      // double STM = iStochastic(currPair,0,StochKPeriod,StochDPeriod,StochSlowing,MODE_SMA,0,MODE_MAIN,0);
      // double STS = iStochastic(currPair,0,StochKPeriod,StochDPeriod,StochSlowing,MODE_SMA,0,MODE_SIGNAL,0);
      // bool AboveMA = iClose(currPair,0,0) > iMA(currPair,0,SMAFilterPeriod,0,MODE_SMA,PRICE_CLOSE,0);
      // bool BelowMA = iClose(currPair,0,0) < iMA(currPair,0,SMAFilterPeriod,0,MODE_SMA,PRICE_CLOSE,0);
      // double AC04 = iAC(currPair,240,0);
      // double AC14 = iAC(currPair,240,1);
      // double AO04 = iAO(currPair,240,0);
      // double AO14 = iAO(currPair,240,1);
      // double STM4 = iStochastic(currPair,240,5,3,4,MODE_SMA,0,MODE_MAIN,0);
      // double STS4 = iStochastic(currPair,240,5,3,4,MODE_SMA,0,MODE_SIGNAL,0);     
      // string ATR4 = DoubleToStr(iATR(currPair,240,ATRPeriod,0),5);
      //Print("Pair: "+currPair+" AC0: "+DoubleToStr(AC0,5)+"; AC1: "+DoubleToStr(AC1,5)+" STM: "+DoubleToStr(STM,5)+"; STS: "+DoubleToStr(STS,5)+" AO0: "+DoubleToStr(AO0,5)+"; AO1: "+DoubleToStr(AO1,5));
      
      double RSIOMA_Main0 = iCustom( currPair, Low_TF, "RSIOMA (2)",14,1,0,21,1, 0,0);
      double RSIOMA_Main1 = iCustom( currPair, Low_TF, "RSIOMA (2)",14,1,0,21,1, 0,1);
      double RSIOMA_Main2 = iCustom( currPair, Low_TF, "RSIOMA (2)",14,1,0,21,1, 0,2);
      double RSIOMA_Main3 = iCustom( currPair, Low_TF, "RSIOMA (2)",14,1,0,21,1, 0,3);

      double RSIOMA_Signal0 = iCustom( currPair, Low_TF, "RSIOMA (2)",14,1,0,21,1, 5,0);
      double RSIOMA_Signal1 = iCustom( currPair, Low_TF, "RSIOMA (2)",14,1,0,21,1, 5,1);
      double RSIOMA_Signal2 = iCustom( currPair, Low_TF, "RSIOMA (2)",14,1,0,21,1, 5,2);
      double RSIOMA_Signal3 = iCustom( currPair, Low_TF, "RSIOMA (2)",14,1,0,21,1, 5,3);

      if(RSIOMA_Signal1>RSIOMA_Main1 && RSIOMA_Main2 < RSIOMA_Signal2){
         rsiomaPairs[risomaIndex] = Pair[i] + " (RSIOMA - " + 14/21 + ")" + " - Long";
      }

      if(RSIOMA_Signal1<RSIOMA_Main1 && RSIOMA_Main2 > RSIOMA_Signal2){
         rsiomaPairs[risomaIndex] = Pair[i] + " (RSIOMA - " + 14/21 + ")" + " - Short";
      }

      // Price cross up  or down Ma channel(10/5 smma apply to high and low)

      // RSIOMA signal line cross down or up 80 or 20 line

      // 55 wpr cross -80 -20 line in H1 timeframe

   }
   if(SendEmail){
      string emailBody = "";
      for(int i =0; i <= risomaIndex){
         emailBody = emailBody + rsiomaPairs[i] + "\n";
      }
      if(previousTime != Time[0]) SendMail(emailBody);
   }
   
   // ObjectsDeleteAll(0,OBJ_LABEL);
   // createTitle();
   // if (ShowTimeTillNextBar) BarEnd();
   
   // int count = regindex; //ArraySize(ozfxRegPairs);      
   // for(k=0;k<count;k++)
   // {
   //    ObjectCreate("OZFXREG"+k, OBJ_LABEL, 0, 0, 0);
   //    ObjectSetText("OZFXREG"+k,ozfxRegPairs[k]  ,8, "Arial", Yellow);
   //    ObjectSet("OZFXREG"+k, OBJPROP_CORNER, 0);
   //    ObjectSet("OZFXREG"+k, OBJPROP_XDISTANCE, 10);
   //    ObjectSet("OZFXREG"+k, OBJPROP_YDISTANCE, 42+k*15);      
   // }
   
   // if (ShowAESSignal)
   // {   
   //    count = aesindex; //ArraySize(aesPairs);
   //    for(k=0;k<count;k++)
   //    {
   //       ObjectCreate("OZFXAES"+k, OBJ_LABEL, 0, 0, 0);
   //       ObjectSetText("OZFXAES"+k, aesPairs[k] ,8, "Arial", DodgerBlue);
   //       ObjectSet("OZFXAES"+k, OBJPROP_CORNER, 0);
   //       ObjectSet("OZFXAES"+k, OBJPROP_XDISTANCE, 180);
   //       ObjectSet("OZFXAES"+k, OBJPROP_YDISTANCE, 42+k*15);
   //    }
   // }

   // if (Show4HoursSqueezeMore)
   // {
   //    count = sqzindex; //ArraySize(sqzmorePairs);
   //    for(k=0;k<count;k++)
   //    {
   //       ObjectCreate("OZFXSM"+k, OBJ_LABEL, 0, 0, 0);
   //       ObjectSetText("OZFXSM"+k,sqzmorePairs[k] ,8, "Arial", Orchid);
   //       ObjectSet("OZFXSM"+k, OBJPROP_CORNER, 0);
   //       ObjectSet("OZFXSM"+k, OBJPROP_XDISTANCE, 350);
   //       ObjectSet("OZFXSM"+k, OBJPROP_YDISTANCE, 42+k*15);
   //    }
   // } 

   return(0);
}

void emailAlert(){
      
      
}

// void createTitle()
// {
//    ObjectCreate("OZFXREG", OBJ_LABEL, 0, 0, 0);
//    ObjectSetText("OZFXREG","PAKU KUNING ada di: ",9, "Arial Bold", Yellow);
//    ObjectSet("OZFXREG", OBJPROP_CORNER, 0);
//    ObjectSet("OZFXREG", OBJPROP_XDISTANCE, 10);
//    ObjectSet("OZFXREG", OBJPROP_YDISTANCE, 25);
//    if (ShowAESSignal)
//    {
//       ObjectCreate("OZFXAES", OBJ_LABEL, 0, 0, 0);
//       ObjectSetText("OZFXAES","PAKU Kuning Gelap ada di:" ,9, "Arial Bold", Khaki);
//       ObjectSet("OZFXAES", OBJPROP_CORNER, 0);
//       ObjectSet("OZFXAES", OBJPROP_XDISTANCE, 180);
//       ObjectSet("OZFXAES", OBJPROP_YDISTANCE, 25);
//    }
//    if (Show4HoursSqueezeMore)
//    {
//       ObjectCreate("OZFXSM", OBJ_LABEL, 0, 0, 0);
//       ObjectSetText("OZFXSM","H4 only: Paku Merah/Biru ada di" ,9, "Arial Bold", Orchid);
//       ObjectSet("OZFXSM", OBJPROP_CORNER, 0);
//       ObjectSet("OZFXSM", OBJPROP_XDISTANCE, 350);
//       ObjectSet("OZFXSM", OBJPROP_YDISTANCE, 25);
//    }   
// }

int deinit()
{
   ObjectsDeleteAll(0,OBJ_LABEL); 
   return(0);
}

void BarEnd()
{
   double i;
   int m,s,k;
   m=Time[0]+Period()*60-CurTime();
   i=m/60.0;
   s=m%60;
   m=(m-m%60)/60;
   
   ObjectCreate("TIME", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("TIME",m + " minutes " + s + " seconds left to bar end",8,"Arial Bold",Lime);
   ObjectSet("TIME", OBJPROP_CORNER, 0);
   ObjectSet("TIME", OBJPROP_XDISTANCE, 10);
   ObjectSet("TIME", OBJPROP_YDISTANCE, 12);
}