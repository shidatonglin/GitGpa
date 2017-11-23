//+------------------------------------------------------------------+
//|                                    Price MA Breakout.mq4
//+------------------------------------------------------------------+
// Indicator properties
#property copyright "Copyright © 2014, TradeForexFx "
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

double CrossUp[];
double CrossDown[];
extern int MA = 5;
extern int MA_Mode = 1;
extern int shift = 2;
extern bool AlertON=true;
double alertTag;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
	{
		SetIndexStyle(0, DRAW_ARROW, EMPTY,2);
		SetIndexArrow(0, 233);
		SetIndexBuffer(0, CrossUp);
		SetIndexStyle(1, DRAW_ARROW, EMPTY,2);
		SetIndexArrow(1, 234);
		SetIndexBuffer(1, CrossDown);
		return(0);
	}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
	{
		return(0);
	}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
	{
		int limit, i;
		double MAnow, close01 , close02;
		int counted_bars=IndicatorCounted();
		//---- check for possible errors
		if(counted_bars<0) return(-1);
		//---- last counted bar will be recounted
		if(counted_bars>0) counted_bars--;
		limit=Bars-counted_bars;
		for(i = 0; i <= limit; i++)
		{
			MAnow = iMA(NULL, 0, MA, shift, MA_Mode, PRICE_CLOSE, i+1);
			//slowerEMAnow = iMA(NULL, 0, SlowerMA, shift, MA_Mode, PRICE_CLOSE, i+1);
			close01     = iClose(NULL,0,i+1);
			close02  = iClose(NULL,0,i+2);
			if((close01 > MAnow) && close02 < MAnow  )
			{
				CrossUp[i+1] = Low[i+1] - Point*30;
			}
			else
			if((close01 < MAnow)  && close02  > MAnow)
			{
				CrossDown[i+1] = High[i+1] + Point*30;
			}
			if(AlertON==true && i==1 && CrossUp[i] > CrossDown[i] && alertTag!=Time[0])
			{
				Alert(Symbol()," ",Period()," - SELL PRICE BREAKOUT");
				alertTag = Time[0];
			}
			if(AlertON==true && i==1 && CrossUp[i] < CrossDown[i] && alertTag!=Time[0])
			{
				Alert(Symbol()," ",Period()," - BUY PRICE BREAKOUT");
				alertTag = Time[0];
			}
		}
		return(0);
	}