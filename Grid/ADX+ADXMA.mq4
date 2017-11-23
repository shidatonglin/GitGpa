/*         
          o=======================================o
         //                                       \\ 
         O             ADX + ADXMA Mod             O
        ||               by Edorenta               ||
        ||             (Paul de Renty)             ||                    
        ||           edorenta@gmail.com            ||
         O           __________________            O
         \\                                       //
          o=======================================o                                                               

*/

#property copyright "Copyright © 2016, MetaQuotes Software Corp & Edorenta."

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Turquoise
#property indicator_color2 Magenta
#property indicator_color3 Turquoise
#property indicator_color4 Magenta

//---- input parameters
extern int ADX_period=50;                    //ADX period
extern int ADXMA_ln=25;                      //ADXMA period
extern ENUM_MA_METHOD ADXMA_type = MODE_SMA; //ADXMA calculation
//---- buffers
double ADXBuffer[];
double ADXMABuffer[];
double PlusDiBuffer[];
double MinusDiBuffer[];
double PlusSdiBuffer[];
double MinusSdiBuffer[];
double TempBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 3 additional buffers are used for counting.
   IndicatorBuffers(7);
//---- indicator buffers
   SetIndexBuffer(0,ADXBuffer);
   SetIndexBuffer(1,ADXMABuffer);
   SetIndexBuffer(2,PlusDiBuffer);
   SetIndexBuffer(3,MinusDiBuffer);
   
   SetIndexBuffer(4,PlusSdiBuffer);
   SetIndexBuffer(5,MinusSdiBuffer);
   SetIndexBuffer(6,TempBuffer);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("ADX("+ADX_period+") + ADXMA("+ADXMA_ln+")");
   SetIndexLabel(0,"ADX");
   SetIndexLabel(1,"ADXMA");
   SetIndexLabel(2,"+DI");
   SetIndexLabel(3,"-DI");
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
   SetIndexStyle(2,DRAW_LINE,STYLE_DOT);
   SetIndexStyle(3,DRAW_LINE,STYLE_DOT);
//----
   SetIndexDrawBegin(0,ADX_period);
   SetIndexDrawBegin(1,ADX_period);
   SetIndexDrawBegin(2,ADX_period);
   SetIndexDrawBegin(3,ADX_period);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Average Directional Movement Index                               |
//+------------------------------------------------------------------+
int start()
  {
   double pdm,mdm,tr;
   double price_high,price_low;
   int    starti,i,counted_bars=IndicatorCounted();
//----
   i=Bars-2;
   PlusSdiBuffer[i+1]=0;
   MinusSdiBuffer[i+1]=0;
   if(counted_bars>=i) i=Bars-counted_bars-1;
   starti=i;
//----
   while(i>=0)
     {
      price_low=Low[i];
      price_high=High[i];
      //----
      pdm=price_high-High[i+1];
      mdm=Low[i+1]-price_low;
      if(pdm<0) pdm=0;  // +DM
      if(mdm<0) mdm=0;  // -DM
      if(pdm==mdm) { pdm=0; mdm=0; }
      else if(pdm<mdm) pdm=0;
           else if(mdm<pdm) mdm=0;
      //---- counting directional strength
      double num1=MathAbs(price_high-price_low);
      double num2=MathAbs(price_high-Close[i+1]);
      double num3=MathAbs(price_low-Close[i+1]);
      tr=MathMax(num1,num2);
      tr=MathMax(tr,num3);
      //---- counting plus/minus direction
      if(tr==0) { PlusSdiBuffer[i]=0; MinusSdiBuffer[i]=0; }
      else      { PlusSdiBuffer[i]=100.0*pdm/tr; MinusSdiBuffer[i]=100.0*mdm/tr; }
      //----
      i--;
     }
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
//---- apply EMA to +DI
   for(i=0; i<=limit; i++)
      PlusDiBuffer[i]=iMAOnArray(PlusSdiBuffer,Bars,ADX_period,0,MODE_EMA,i);
//---- apply EMA to -DI
   for(i=0; i<=limit; i++)
      MinusDiBuffer[i]=iMAOnArray(MinusSdiBuffer,Bars,ADX_period,0,MODE_EMA,i);
//---- Directional Movement (DX)
   i=Bars-2;
   TempBuffer[i+1]=0;
   i=starti;
   while(i>=0)
     {
      double div=MathAbs(PlusDiBuffer[i]+MinusDiBuffer[i]);
      if(div==0.00) TempBuffer[i]=0;
      else TempBuffer[i]=100*(MathAbs(PlusDiBuffer[i]-MinusDiBuffer[i])/div);
      i--;
     }
//---- ADX is exponential moving average on DX
   for(i=0; i<limit; i++)
      ADXBuffer[i]=iMAOnArray(TempBuffer,Bars,ADX_period,0,MODE_EMA,i);
   for(i=limit;i>=0;i--){
      ADXMABuffer[i] = iMAOnArray(ADXBuffer,0,ADXMA_ln,0,ADXMA_type,i);
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+--------------+