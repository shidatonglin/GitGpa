/*------------------------------------------------------------------------------------
   Name: TDI-MTF.mq4
   Copyright ©2010, Xaphod, http://forexwhiz.appspot.com
   
   Description: - MTF TDI Indicator
                - Requires 'Traders_Dynamic_Index.mq4' is installed
	          
   Change log: 
       2010-11-10. Xaphod, v1.01 
          - Added Auto Higher TF
          - Added indicator level lines
       2010-11-10. Xaphod, v1.01 
          - Fixed time axis to correspond with the lower TF.
       2010-11-10. Xaphod, v1.00 
          - Initial Release 
         
-------------------------------------------------------------------------------------*/
// Indicator properties
#property copyright "Copyright © 2010, Xaphod"
#property link      "http://forexwhiz.appspot.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  Blue
#property indicator_color2  Yellow
#property indicator_color3  Blue
#property indicator_color4  Green
#property indicator_color5  Red
#property indicator_width1  1
#property indicator_width2  2
#property indicator_width3  1
#property indicator_width4  2
#property indicator_width5  2
#property indicator_level1  32.0
#property indicator_level2  50.0
#property indicator_level3  68.0
#property indicator_levelcolor DimGray
#property indicator_levelstyle STYLE_DOT

// Constant definitions
#define INDICATOR_NAME "TDI-MTF"
#define INDICATOR_VERSION "1.02"
#define TDI_INDI "Traders_Dynamic_Index"


// Indicator parameters
extern string    Version=INDICATOR_VERSION;
extern bool      AutoTimeFrame=True;           // Automatically select the next higher TF. M15 and M30 -> H1
extern int       TimeFrame=0;                  // Timeframe: 0,1,5,15,30,60,240,1440 etc. Current Timeframe=0. 
extern int       TDI_RSIPeriod = 13;           // Period. Recomended values: 8-25
extern int       TDI_RSIPrice = 0;             // 0=CLOSE, 1=OPEN, 2=HIGH, 3=LOW, 4=MEDIAN, 5=TYPICAL, 6=WEIGHTED
extern int       TDI_VolatilityBand = 34;      // Recomended values: 20-40
extern int       TDI_RSIPriceLine = 2;         // Period
extern int       TDI_RSIPriceType = 0;         // 0=SMA, 1=EMA, 2=SSMA, 3=LWMA
extern int       TDI_TradeSignalLine = 7;      // Period
extern int       TDI_TradeSignalType = 0;      // 0=SMA, 1=EMA, 2=SSMA, 3=LWMA

// Global module varables
double dBuffer0[];
double dBuffer1[];
double dBuffer2[];
double dBuffer3[];
double dBuffer4[];

extern int iTimeFrame;
//-----------------------------------------------------------------------------
// function: init()
// Description: Custom indicator initialization function.
//-----------------------------------------------------------------------------
int init() {
  // Init indicator buffers
  SetIndexStyle(0,DRAW_LINE);
  SetIndexBuffer(0,dBuffer0);
  SetIndexLabel(0,"VBHighLine");
  SetIndexStyle(1,DRAW_LINE);
  SetIndexBuffer(1,dBuffer1);
  SetIndexLabel(1,"MarketBaseLine");
  SetIndexStyle(2,DRAW_LINE);
  SetIndexBuffer(2,dBuffer2);
  SetIndexLabel(2,"VBLowLine");
  SetIndexStyle(3,DRAW_LINE);
  SetIndexBuffer(3,dBuffer3);
  SetIndexLabel(3,"RSIPriceLine");
  SetIndexStyle(4,DRAW_LINE);
  SetIndexBuffer(4,dBuffer4);
  SetIndexLabel(4,"TradeSignalLine");  
  
  // Set Timeframe
  if (AutoTimeFrame)
    iTimeFrame=NextHigherTF(TimeFrame);
  else
    iTimeFrame=TimeFrame;
    
  // Other stuff  
  IndicatorShortName(INDICATOR_NAME+" ["+TF2Str(iTimeFrame)+"]");
  IndicatorDigits(4); 
    
  return(0);
}


//-----------------------------------------------------------------------------
// function: deinit()
// Description: Custom indicator deinitialization function.
//-----------------------------------------------------------------------------
int deinit() {
  return (0);
}


///-----------------------------------------------------------------------------
// function: start()
// Description: Custom indicator iteration function.
//-----------------------------------------------------------------------------
int start() {
  int iNewBars;
  int iCountedBars; 
  int i;
  double dVBHighLine;        // Upper volatility band - Upper Blue line
  double dVBLowLine;         // Lower volatility band - Lower Blue line
  double dMarketBaseLine;    // Market Base Line - Yellow line
  double dRSIPriceLine;      // RSI PriceLine - Green line
  double dTradeSignalLine;   // Trade Signal Line - Red line
  
  // Get unprocessed ticks
  iCountedBars=IndicatorCounted();
  if(iCountedBars < 0) return (-1); 
  if(iCountedBars>0) iCountedBars--;
  iNewBars=Bars-iCountedBars;
  
  for(i=iNewBars; i>=0; i--) {      
    // Get TDI Data
    dBuffer0[i]=iCustom(NULL,iTimeFrame,TDI_INDI,TDI_RSIPeriod,TDI_RSIPrice,TDI_VolatilityBand,TDI_RSIPriceLine,
                        TDI_RSIPriceType,TDI_TradeSignalLine,TDI_TradeSignalType,1,iBarShift(Symbol(), iTimeFrame, Time[i]));       // Upper Blue line
    dBuffer1[i]=iCustom(NULL,iTimeFrame,TDI_INDI,TDI_RSIPeriod,TDI_RSIPrice,TDI_VolatilityBand,TDI_RSIPriceLine,
                            TDI_RSIPriceType,TDI_TradeSignalLine,TDI_TradeSignalType,2,iBarShift(Symbol(), iTimeFrame, Time[i]));   // Yellow line
    dBuffer2[i]=iCustom(NULL,iTimeFrame,TDI_INDI,TDI_RSIPeriod,TDI_RSIPrice,TDI_VolatilityBand,TDI_RSIPriceLine,
                       TDI_RSIPriceType,TDI_TradeSignalLine,TDI_TradeSignalType,3,iBarShift(Symbol(), iTimeFrame, Time[i]));        // Lower Blue line
    dBuffer3[i]=iCustom(NULL,iTimeFrame,TDI_INDI,TDI_RSIPeriod,TDI_RSIPrice,TDI_VolatilityBand,TDI_RSIPriceLine,
                          TDI_RSIPriceType,TDI_TradeSignalLine,TDI_TradeSignalType,4,iBarShift(Symbol(), iTimeFrame, Time[i]));     // Green line
    dBuffer4[i]=iCustom(NULL,iTimeFrame,TDI_INDI,TDI_RSIPeriod,TDI_RSIPrice,TDI_VolatilityBand,TDI_RSIPriceLine,
                            TDI_RSIPriceType,TDI_TradeSignalLine,TDI_TradeSignalType,5,iBarShift(Symbol(), iTimeFrame, Time[i]));  // Red line
  }
  // Bye bye  
  return(0);
}
//+------------------------------------------------------------------+


//-----------------------------------------------------------------------------
// function: TF2Str()
// Description: Convert time-frame to a string
//-----------------------------------------------------------------------------
string TF2Str(int iPeriod) {
  if (iPeriod==0) iPeriod=Period();
  switch(iPeriod) {
    case PERIOD_M1: return("M1");
    case PERIOD_M5: return("M5");
    case PERIOD_M15: return("M15");
    case PERIOD_M30: return("M30");
    case PERIOD_H1: return("H1");
    case PERIOD_H4: return("H4");
    case PERIOD_D1: return("D1");
    case PERIOD_W1: return("W1");
    case PERIOD_MN1: return("MN1");
    default: return("M"+iPeriod);
  }
}

//-----------------------------------------------------------------------------
// function: NextHigherTF()
// Description: Select the next higher time-frame. 
//              Note: M15 and M30 both select H1 as next higher TF. 
//-----------------------------------------------------------------------------
int NextHigherTF(int iPeriod) {
  if (iPeriod==0) iPeriod=Period();
  switch(iPeriod) {
    case PERIOD_M1: return(PERIOD_M5);
    case PERIOD_M5: return(PERIOD_M15);
    case PERIOD_M15: return(PERIOD_H1);
    case PERIOD_M30: return(PERIOD_H1);
    case PERIOD_H1: return(PERIOD_H4);
    case PERIOD_H4: return(PERIOD_D1);
    case PERIOD_D1: return(PERIOD_W1);
    case PERIOD_W1: return(PERIOD_MN1);
    case PERIOD_MN1: return(PERIOD_MN1);
    default: return(Period());
  }
}


