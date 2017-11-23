//+------------------------------------------------------------------+
//| MTF CJA   Alert           MTF_Waddah_Attar_ExplosionSA  M2.mq4 ik|
//|    standalone        Copyright © 2006, MetaQuotes Software Corp. |
//|     fxTSD.com                          http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//+------------------------------------------------------------------+
//|                                       Waddah_Attar_Explosion.mq4 |
//|                              Copyright © 2006, Eng. Waddah Attar |
//|                                          waddahattar@hotmail.com |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2006, Eng. Waddah Attar"
#property  link      "waddahattar@hotmail.com"
//----
#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  Green
#property  indicator_color2  Red
#property  indicator_color3  Gold
#property  indicator_color4  Aqua
#property  indicator_minimum 0.0
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 1
#property indicator_width4 1
//----
extern int Minutes=0;
extern int  Sensetive=150;
extern int  DeadZonePip=15;
extern int  ExplosionPower=15;
extern int  TrendPower=15;
extern bool AlertWindow=false;
extern int  AlertCount=20;
extern bool AlertLong=true;
extern bool AlertShort=true;
extern bool AlertExitLong=true;
extern bool AlertExitShort=true;
extern string note_TF_Minutes="5,15,30,60H1,240H4,1440D1,10080W1,43200MN1";
//----
double   ind_buffer1[];
double   ind_buffer2[];
double   ind_buffer3[];
double   ind_buffer4[];
//----
int LastTime1=1;
int LastTime2=1;
int LastTime3=1;
int LastTime4=1;
int Status=0, PrevStatus=-1;
double bask, bbid;
string TimeFrameStr;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID);
   SetIndexStyle(3, DRAW_LINE);
//----   
   SetIndexBuffer(0, ind_buffer1);
   SetIndexBuffer(1, ind_buffer2);
   SetIndexBuffer(2, ind_buffer3);
   SetIndexBuffer(3, ind_buffer4);
//----
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   switch(Minutes)
     {
      case 1 : TimeFrameStr=" Period M1 "; break;
      case 5 : TimeFrameStr=" Period M5 "; break;
      case 15 : TimeFrameStr=" Period M15 "; break;
      case 30 : TimeFrameStr=" Period M30 "; break;
      case 60 : TimeFrameStr=" Period H1 "; break;
      case 240 : TimeFrameStr=" Period H4 "; break;
      case 1440 : TimeFrameStr=" Period D1 "; break;
      case 10080 : TimeFrameStr=" Period W1 "; break;
      case 43200 : TimeFrameStr=" Period MN1 "; break;
      default : TimeFrameStr=" Current TimeFrame "; Minutes=0;
     }
//----   
   if (Minutes<=Period()) Minutes=Period();
   IndicatorShortName("WadAttExpl:|"+TimeFrameStr+"|[S-" + Sensetive +"][DZ-"+ DeadZonePip +"][EP-"+ ExplosionPower +"][TrP-"+ TrendPower +"])");
   //  Comment("copyright waddahwttar@hotmail.com");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   double Trend1, Trend2, Explo1, Explo2, Dead;
   double pwrt, pwre;
   int    limit, i, y=0,counted_bars=IndicatorCounted();
//----
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),Minutes);
   if(counted_bars < 0)
      return(-1);
//----
   if(counted_bars > 0)
      counted_bars--;
   //limit = Bars - counted_bars;
   limit=Bars-counted_bars+Minutes/Period();
//----
   // for(i = limit - 1; i >= 0; i--)
   for(i=0,y=0;i<limit;i++)
     {
      if (Time[i]<TimeArray[y]) y++;
      Trend1=(iMACD(NULL, Minutes, 20, 40, 9, PRICE_CLOSE, MODE_MAIN, y) -
                iMACD(NULL, Minutes, 20, 40, 9, PRICE_CLOSE, MODE_MAIN, y + 1))*Sensetive;
      Trend2=(iMACD(NULL, Minutes, 20, 40, 9, PRICE_CLOSE, MODE_MAIN, y + 2) -
                iMACD(NULL, Minutes, 20, 40, 9, PRICE_CLOSE, MODE_MAIN, y + 3))*Sensetive;
      Explo1=(iBands(NULL, Minutes, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, y) -
                iBands(NULL, Minutes, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, y));
      Explo2=(iBands(NULL, Minutes, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, y + 1) -
                iBands(NULL, Minutes, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, y + 1));
      Dead=Point * DeadZonePip;
      ind_buffer1[i]=0;
      ind_buffer2[i]=0;
      ind_buffer3[i]=0;
      ind_buffer4[i]=0;
      if(Trend1>=0)
         ind_buffer1[i]=Trend1;
      if(Trend1 < 0)
         ind_buffer2[i]=(-1*Trend1);
      ind_buffer3[i]=Explo1;
      ind_buffer4[i]=Dead;
      if(i==0)
        {
         if(Trend1 > 0 && Trend1 > Explo1 && Trend1 > Dead &&
            Explo1 > Dead && Explo1 > Explo2 && Trend1 > Trend2 &&
            LastTime1 < AlertCount && AlertLong==true && Ask!=bask)
           {
            pwrt=100*(Trend1 - Trend2)/Trend1;
            pwre=100*(Explo1 - Explo2)/Explo1;
            bask=Ask;
            if(pwre>=ExplosionPower && pwrt>=TrendPower)
              {
               if(AlertWindow==true)
                 {
                  Alert("WAE",LastTime1, "- ", Symbol(), " - BUY ", " (",
                        DoubleToStr(bask, Digits) , ") Trend PWR " ,
                        DoubleToStr(pwrt,0), " - Exp PWR ", DoubleToStr(pwre, 0));
                 }
               else
                 {
                  Print("WAE",LastTime1, "- ", Symbol(), " - BUY ", " (",
                        DoubleToStr(bask, Digits), ") Trend PWR ",
                        DoubleToStr(pwrt, 0), " - Exp PWR ", DoubleToStr(pwre, 0));
                 }
               LastTime1++;
              }
            Status=1;
           }
         if(Trend1 < 0 && MathAbs(Trend1) > Explo1 && MathAbs(Trend1) > Dead &&
            Explo1 > Dead && Explo1 > Explo2 && MathAbs(Trend1) > MathAbs(Trend2) &&
            LastTime2 < AlertCount && AlertShort==true && Bid!=bbid)
           {
            pwrt=100*(MathAbs(Trend1) - MathAbs(Trend2))/MathAbs(Trend1);
            pwre=100*(Explo1 - Explo2)/Explo1;
            bbid=Bid;
            if(pwre>=ExplosionPower && pwrt>=TrendPower)
              {
               if(AlertWindow==true)
                 {
                  Alert("WAE",LastTime2, "- ", Symbol(), " - SELL ", " (",
                        DoubleToStr(bbid, Digits), ") Trend PWR ",
                        DoubleToStr(pwrt,0), " - Exp PWR ", DoubleToStr(pwre, 0));
                 }
               else
                 {
                  Print("WAE",LastTime2, "- ", Symbol(), " - SELL ", " (",
                        DoubleToStr(bbid, Digits), ") Trend PWR " ,
                        DoubleToStr(pwrt, 0), " - Exp PWR ", DoubleToStr(pwre, 0));
                 }
               LastTime2++;
              }
            Status=2;
           }
         if(Trend1 > 0 && Trend1 < Explo1 && Trend1 < Trend2 && Trend2 > Explo2 &&
            Trend1 > Dead && Explo1 > Dead && LastTime3<=AlertCount &&
            AlertExitLong==true && Bid!=bbid)
           {
            bbid=Bid;
            if(AlertWindow==true)
              {
               Alert("WAE",LastTime3, "- ", Symbol(), " - Exit BUY ", " ",
                     DoubleToStr(bbid, Digits));
              }
            else
              {
               Print("WAE",LastTime3, "- ", Symbol(), " - Exit BUY ", " ",
                     DoubleToStr(bbid, Digits));
              }
            Status=3;
            LastTime3++;
           }
         if(Trend1 < 0 && MathAbs(Trend1) < Explo1 &&
            MathAbs(Trend1) < MathAbs(Trend2) && MathAbs(Trend2) > Explo2 &&
            Trend1 > Dead && Explo1 > Dead && LastTime4<=AlertCount &&
            AlertExitShort==true && Ask!=bask)
           {
            bask=Ask;
            if(AlertWindow==true)
              {
               Alert("WAE",LastTime4, "- ", Symbol(), " - Exit SELL ", " ",
                     DoubleToStr(bask, Digits));
              }
            else
              {
               Print("WAE",LastTime4, "- ", Symbol(), " - Exit SELL ", " ",
                     DoubleToStr(bask, Digits));
              }
            Status=4;
            LastTime4++;
           }
         PrevStatus=Status;
        }
      if(Status!=PrevStatus)
        {
         LastTime1=1;
         LastTime2=1;
         LastTime3=1;
         LastTime4=1;
        }
     }
//----  Refresh buffers +++++++++++++++++++++++++  Raff  
     if (Minutes>Period()) 
     {
      int PerINT=Minutes/Period()+1;
      datetime TimeArr[]; ArrayResize(TimeArr,PerINT);
      ArrayCopySeries(TimeArr,MODE_TIME,Symbol(),Period());
        for(i=0;i<PerINT+1;i++) 
        {
         if (TimeArr[i]>=TimeArray[0]) 
          {
 /********************************************************     
    Refresh buffers:         buffer[i] = buffer[0];
 ********************************************************/
            ind_buffer1[i]=ind_buffer1[0];
            ind_buffer2[i]=ind_buffer2[0];
            ind_buffer3[i]=ind_buffer3[0];
            ind_buffer4[i]=ind_buffer4[0];
           } 
         } 
       }
//++++++++++++++++++++++++++++++++++++++++ upgrade by Raff
   return(0);
  }
//+------------------------------------------------------------------+

