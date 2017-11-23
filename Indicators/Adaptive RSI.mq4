//+------------------------------------------------------------------+ 
//| ARSI.mq4 
//+------------------------------------------------------------------+ 
#property copyright "Alexander Kirilyuk M." 
#property link "" 

#property indicator_separate_window
//#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 DodgerBlue

extern int ARSIPeriod = 14;

//---- buffers 
double ARSI[]; 

int init()
{ 
	string short_name = "ARSI (" + ARSIPeriod + ")";

	SetIndexStyle(0,DRAW_LINE); 
	SetIndexBuffer(0,ARSI); 
	//SetIndexDrawBegin(0,ARSIPeriod);

	return(0); 
} 

int start() 
{ 
	int i, counted_bars = IndicatorCounted(); 
	int limit;

	if(Bars <= ARSIPeriod) 
		return(0);

	if(counted_bars < 0)
	{
		return;
	}
	
	if(counted_bars == 0)
	{
		limit = Bars;
	}
	if(counted_bars > 0)
	{
		limit = Bars - counted_bars;
	}
	
	double sc;
	for(i = limit; i >= 0; i--)
	{
		sc = MathAbs(iRSI(NULL, 0, ARSIPeriod, PRICE_CLOSE, i)/100.0 - 0.5) * 2.0;

		if( Bars - i <= ARSIPeriod)
			ARSI[i] = Close[i];
		else		
			ARSI[i] = ARSI[i+1] + sc * (Close[i] - ARSI[i+1]);
	}

	return(0); 
} 


