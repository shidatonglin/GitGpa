//+------------------------------------------------------------------+
//|                                                     Laguerre.mq4 |
//|                                                     Emerald King |
//|                                     mailto:info@emerald-king.com |
//+------------------------------------------------------------------+
#property copyright "Emerald King"
#property link      "mailto:info@emerald-king.com"

#include <gSpeak.mqh>

#property indicator_separate_window
#property indicator_minimum -0.1
#property indicator_maximum  1.1
#property indicator_color1 Blue
#property indicator_width1 2
#property indicator_level2 0.85
#property indicator_level3 0.45
#property indicator_level4 0.15

//---- input parameters
extern double  gamma=0.55;
extern int     CountBars=9500;
extern double  BuyLevel=0.15;
extern double  SellLevel=0.85;
extern bool    UseAlertSound=false;
extern string  SoundFile="alert.wav";
extern bool    UseAlertVoice=false;
extern bool    UseEmail=false;
extern string  VoiceSell="Laguerre Indicator found possibke Sell setup";
extern string  VoiceBuy="Laguerre Indicator found possible Buy setup";

datetime TimeStamp;

double L0 = 0;
double L1 = 0;
double L2 = 0;
double L3 = 0;
double L0A = 0;
double L1A = 0;
double L2A = 0;
double L3A = 0;
double LRSI = 0;
double CU = 0;
double CD = 0;

double val1[],
       ValBar1=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
      
int init()
  {
//---- indicators
//----
   SetIndexBuffer(0,val1);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {

   if (CountBars>Bars) CountBars=Bars;
   SetIndexDrawBegin(0,Bars-CountBars);
   
   int i;
   int    counted_bars=IndicatorCounted();

   i=CountBars-1;
   
   while(i>=0)
   {
      L0A = L0;
      L1A = L1;
      L2A = L2;
      L3A = L3;
      L0 = (1 - gamma)*Close[i] + gamma*L0A;
      L1 = - gamma *L0 + L0A + gamma *L1A;
      L2 = - gamma *L1 + L1A + gamma *L2A;
      L3 = - gamma *L2 + L2A + gamma *L3A;

      CU = 0;
      CD = 0;
      
      if (L0 >= L1) CU = L0 - L1; else CD = L1 - L0;
      if (L1 >= L2) CU = CU + L1 - L2; else CD = CD + L2 - L1;
      if (L2 >= L3) CU = CU + L2 - L3; else CD = CD + L3 - L2;

      if (CU + CD != 0) LRSI = CU / (CU + CD);
      val1[i] = LRSI;

      if(i==1) ValBar1=LRSI;
      if(i==0 && ValBar1>SellLevel && LRSI<=SellLevel && TimeStamp!=Time[0])
      {
         Alert("Verify Sell "+ Symbol()+" (Curr ", LRSI,"/Prev (",ValBar1,") LAG1");
         if(UseEmail) SendMail(Symbol()," Verify Sell (Curr " + LRSI+"/Prev ("+ValBar1+") LAG1");
         if(UseAlertSound) PlaySound(SoundFile);
         if(UseAlertVoice)
         {
            gRate(1);
            gVolume(100);
            gPitch(10);
            gSpeak(VoiceSell);
         }
         TimeStamp = Time[0];
      }

      if(i==0 && ValBar1<BuyLevel && LRSI>=BuyLevel && TimeStamp!=Time[0])
      {
         Alert("Verify Buy "+ Symbol()+" (Curr ", LRSI,"/Prev ",ValBar1,") LAG1");
         if(UseEmail) SendMail(Symbol()," Verify Buy (Curr " + LRSI+"/Prev ("+ValBar1+") LAG1");
         if(UseAlertSound) PlaySound(SoundFile);
         if(UseAlertVoice)
         {
            gRate(1);
            gVolume(100);
            gPitch(10);
            gSpeak(VoiceBuy);
         }
         TimeStamp = Time[0];
      }
    
      i--;
	}
   return(0);
 }
//+------------------------------------------------------------------+ 