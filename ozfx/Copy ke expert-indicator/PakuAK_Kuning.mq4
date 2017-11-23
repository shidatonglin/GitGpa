//+------------------------------------------------------------------+
//|                                             OzFX_D1_Ind_v1.0.mq4 |
//|                                            Copyright © 2008, DGC |
//|                                          http://www.ozfx.com.au/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, DGC"
#property link      "http://www.ozfx.com.au/"

#include <WinUser32.mqh>

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Yellow
#property indicator_width1 2
#property indicator_color2 DodgerBlue
#property indicator_width2 2
#property indicator_color3 Red
#property indicator_width3 2
#property indicator_color4 Green
#property indicator_width4 1
#property indicator_style4 2
#property indicator_level1 0
#property indicator_minimum -1.2
#property indicator_maximum 1.2

extern string SEP1 = "----SIGNAL CONTROLS----";
extern bool Show_OzFX_Signals = true;
extern bool Show_AES_Signals = false;
extern string SEP2 = "----FILTER CONTROLS----";
extern bool Show_SMA_Filter = false;
extern int SMA_Filter_Period = 200;
extern bool Show_RSI_Filter = false;
extern int RSI_Filter_Period = 45;
extern string SEP3 = "----ALERT CONTROLS----";
extern bool Popup_Alerts_On = false;
extern bool Audio_Alerts_On = false;
extern bool EMail_Alerts_On = false;
extern int Alert_Signal = 0;
extern bool Alert_SMA_Filtered = false;
extern bool Alert_RSI_Filtered = false;

double OzFX_Regular[];
double OzFX_AES[];
double Filter_SMA[];
double Filter_RSI[];

int iLastRegular;
double dLastAES;
int k;

bool bAlertSounded;

int init()
{
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, OzFX_Regular);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(1, OzFX_AES);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Filter_SMA);
   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, Filter_RSI);
   iLastRegular = 0;
   dLastAES = 0;
   bAlertSounded = false;
   return(0);
}

int start()
{
   for (k = Bars - 205; k >= 0; k --)
   {

/*---------------------*/            
/*  OZFX REGULAR CODE  */
/*---------------------*/
      OzFX_Regular[k] = 0;
      if (iAC(Symbol(), 0, k) > 0 &&
          iAC(Symbol(), 0, k) > iAC(Symbol(), 0, k + 1) &&
          iStochastic(Symbol(), 0, 5, 3, 4, MODE_SMA, 0, MODE_MAIN, k) > 50)
      {
         if (iLastRegular != 1) OzFX_Regular[k] = 1;
         iLastRegular = 1;
      }   
      
      if (iAC(Symbol(), 0, k) < 0 &&
          iAC(Symbol(), 0, k) < iAC(Symbol(), 0, k + 1) &&
          iStochastic(Symbol(), 0, 5, 3, 4, MODE_SMA, 0, MODE_MAIN, k) < 50)
      {
         if (iLastRegular != -1) OzFX_Regular[k] = -1;
         iLastRegular = -1;
      }   
      if (Show_OzFX_Signals == false) OzFX_Regular[k] = 0.0;
      
/*-----------------*/            
/*  OZFX AES CODE  */
/*-----------------*/
      OzFX_AES[k] = 0;
      if (/*iAC(Symbol(), 0, k) > 0 &&*/
          iAC(Symbol(), 0, k) > iAC(Symbol(), 0, k + 1) &&
          iStochastic(Symbol(), 0, 5, 3, 4, MODE_SMA, 0, MODE_MAIN, k)
          > iStochastic(Symbol(), 0, 5, 3, 4, MODE_SMA, 0, MODE_SIGNAL, k) /*&&
          iStochastic(Symbol(), 0, 5, 3, 4, MODE_SMA, 0, MODE_MAIN, k + 1)
          < iStochastic(Symbol(), 0, 5, 3, 4, MODE_SMA, 0, MODE_SIGNAL, k + 1) &&
          iAO(Symbol(), 0, k) > iAO(Symbol(), 0, k + 1)*/)
      {
         if (dLastAES != 0.7) OzFX_AES[k] = 0.7;
         dLastAES = 0.7;
      }   
      
      if (/*iAC(Symbol(), 0, k) < 0 &&*/
          iAC(Symbol(), 0, k) < iAC(Symbol(), 0, k + 1) &&
          iStochastic(Symbol(), 0, 5, 3, 4, MODE_SMA, 0, MODE_MAIN, k)
          < iStochastic(Symbol(), 0, 5, 3, 4, MODE_SMA, 0, MODE_SIGNAL, k) /*&&
          iStochastic(Symbol(), 0, 5, 3, 4, MODE_SMA, 0, MODE_MAIN, k + 1)
          > iStochastic(Symbol(), 0, 5, 3, 4, MODE_SMA, 0, MODE_SIGNAL, k + 1) &&
          iAO(Symbol(), 0, k) < iAO(Symbol(), 0, k + 1)*/)
      {
         if (dLastAES != -0.7) OzFX_AES[k] = -0.7;
         dLastAES = -0.7;
      }   
      if (Show_AES_Signals == false) OzFX_AES[k] = 0.0;
/*-------------------*/            
/*  SMA FILTER CODE  */
/*-------------------*/            
      Filter_SMA[k] = 0;
      if (Close[k] > iMA(Symbol(), 0, SMA_Filter_Period, 0, MODE_SMA, PRICE_CLOSE, k))
         Filter_SMA[k] = 1;
      if (Close[k] <= iMA(Symbol(), 0, SMA_Filter_Period, 0, MODE_SMA, PRICE_CLOSE, k))
         Filter_SMA[k] = -1;
      if (Show_SMA_Filter == false) Filter_SMA[k] = EMPTY_VALUE;

/*-------------------*/            
/*  RSI FILTER CODE  */
/*-------------------*/            
      Filter_RSI[k] = 0;
      if (50 > iRSI(Symbol(), 0, RSI_Filter_Period, PRICE_CLOSE, k))
         Filter_RSI[k] = -1;
      if (50 <= iRSI(Symbol(), 0, RSI_Filter_Period, PRICE_CLOSE, k))
         Filter_RSI[k] = 1;
      if (Show_RSI_Filter == false) Filter_RSI[k] = EMPTY_VALUE;
   }

/*--------------*/            
/*  ALERT CODE  */
/*--------------*/   

   if ((Alert_SMA_Filtered == false ||
      (Alert_SMA_Filtered == true && OzFX_Regular[0] == Filter_SMA[0]))
      &&
      (Alert_RSI_Filtered == false ||
      (Alert_RSI_Filtered == true && MathCeil(OzFX_AES[0]) == Filter_SMA[0])))
   {
      switch (Alert_Signal)
      {
         case 0:
            if (OzFX_Regular[0] != 0 && bAlertSounded == false)
            {
               if (Popup_Alerts_On == true)
                  MessageBox("alert", "Trade Alert!!", MB_OK);
               if (Audio_Alerts_On == true)
                  PlaySound("Alert.wav");
               if (EMail_Alerts_On == true)
                  SendMail("Trade Alert!!", "alert");
               bAlertSounded = true;
            }
            else bAlertSounded = false;
            break;
         case 1:
            if (OzFX_Regular[0] != 0 && bAlertSounded == false)
            {
               if (Popup_Alerts_On == true)
                  MessageBox("alert", "Trade Alert!!", MB_OK);
               if (Audio_Alerts_On == true)
                  PlaySound("Alert.wav");
               if (EMail_Alerts_On == true)
                  SendMail("Trade Alert!!", "alert");
               bAlertSounded = true;
            }
            else bAlertSounded = false;
            break;
      }
   }         

   return(0);
}

