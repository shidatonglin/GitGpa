//+------------------------------------------------------------------+
//|                                            CCI CustomCandles.mq4 |
//|                                                  modified by cja |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Christof Risch (iya)"
#property link      "http://www.forexfactory.com/showthread.php?t=13321"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue//wick
#property indicator_color2 Red//wick
#property indicator_color3 Blue//candle
#property indicator_color4 Red//candle
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3


//---- stoch settings
extern int	  CCI_Period		= 25;
extern int    CCI_Price       = 5;
extern int    Overbought		= 100;
extern int	  Oversold			= -100;
extern string note            = "turn on Alert = true; turn off = false";
extern bool   alertsOn        = true;
extern bool   alertsOnCurrent = false;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = true;
extern bool   alertsEmail     = false;
extern string soundfile       = "alert2.wav";

//---- input parameters
extern int	BarWidth			= 1,
				CandleWidth		= 3;

//---- buffers
double Bar1[],
		 Bar2[],
		 Candle1[],
		 Candle2[],
		 trend[];
		 

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
	IndicatorShortName("CCI Candles:("+	CCI_Period+")");
	IndicatorBuffers(5);
	SetIndexBuffer(0,Bar1);
	SetIndexBuffer(1,Bar2);				
	SetIndexBuffer(2,Candle1);
	SetIndexBuffer(3,Candle2);
	SetIndexBuffer(4,trend);
	SetIndexStyle(0,DRAW_HISTOGRAM,0,BarWidth);
	SetIndexStyle(1,DRAW_HISTOGRAM,0,BarWidth);
	SetIndexStyle(2,DRAW_HISTOGRAM,0,CandleWidth);
	SetIndexStyle(3,DRAW_HISTOGRAM,0,CandleWidth);

	return(0);
}

//+------------------------------------------------------------------+
double CCI  	(int i = 0)	{return(iCCI(NULL,0,CCI_Period,CCI_Price,i));}



//+------------------------------------------------------------------+
void SetCandleColor(int col, int i)
{
	double high,low,bodyHigh,bodyLow;
	
	bodyHigh = MathMax(Open[i],Close[i]);
   bodyLow  = MathMin(Open[i],Close[i]);
   high		= High[i];
   low		= Low[i];

	Bar1[i]    = EMPTY_VALUE;
   Bar2[i]    = EMPTY_VALUE;
   Candle1[i] = EMPTY_VALUE;
   Candle2[i] = EMPTY_VALUE;
	
	switch(col)
	{
		case 1: Bar1[i] = high;	Bar2[i] = low; Candle1[i] = bodyHigh;	Candle2[i] = bodyLow; break;
      case 2: Bar2[i] = high;	Bar1[i] = low; Candle2[i] = bodyHigh;	Candle1[i] = bodyLow; break;
	
	}
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars=IndicatorCounted();
   if (counted_bars<0) return(-1);
   if (counted_bars>0) counted_bars--;
         int limit=MathMin(Bars-counted_bars,Bars-1);
   
   //
   //
   //
   //
   //
   
	for(int i = limit; i>=0; i--)//MathMax(Bars-1-IndicatorCounted(),1)
	{
		double cci	= CCI(i); 
		       trend[i] = trend[i+1];
			 	 if(cci > Overbought)	{ trend[i] = 1; SetCandleColor(1,i); }
		else	 if(cci < Oversold)		{ trend[i] =-1; SetCandleColor(2,i); }
		
	}
	
	//
	//
	//
	//
	//
	
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1;
      if (trend[whichBar] != trend[whichBar+1])
      if (trend[whichBar] == 1)
            doAlert("overbought");
      else  doAlert("oversold");       
   }
   
   return(0);
}
//+------------------------------------------------------------------+


void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," cci cross ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," cci cross "),message);
             if (alertsSound)   PlaySound(soundfile);
      }
}
   
   
   

