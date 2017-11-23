//+------------------------------------------------------------------+
//|                                                FX_SHIChannel.mq4 |
//+------------------------------------------------------------------+
//|                                                    SHI_Slope.mq4 |
//|                                         Shimodax, Shurka & Kevin |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Shimodax, based on SHI-Channel from Shurka & Kevin"
#property  link     "http://www.strategybuilderfx.com/forums/showthread.php?t=15112"

#property indicator_chart_window
#property indicator_buffers 4

#property indicator_color1 Gold
#property indicator_color2 DarkGoldenrod
#property indicator_color3 Gold
#property indicator_color4 Red

double UpperLimitBuf[];
double MedLimitBuf[];
double LowerLimitBuf[];
double PriceAlertBuf[];


//---- input parameters
extern bool AlertSlopeChange= false;  // signal changes in slope 
extern bool AlertChannelBreak= false;  // signal changes in slope 
extern int SHIBars= 240;          // bars to use to find a channel
extern int BarsForFract= 0;
extern bool DebugLogger= false;
//#include "fxoe-lib.mqh"




//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   //---- indicators

   SetIndexStyle(0, DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(0, UpperLimitBuf);
   SetIndexEmptyValue(0, 0.0);
   SetIndexLabel(0, "SHI Channel Upper");      
   
   SetIndexStyle(1, DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(1, MedLimitBuf);
   SetIndexEmptyValue(1, 0.0);
   SetIndexLabel(1, "SHI Channel Median");      
   
   SetIndexStyle(2, DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(2, LowerLimitBuf);
   SetIndexEmptyValue(2, 0.0);
   SetIndexLabel(2, "SHI Channel Lower");      
   
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,164);
   SetIndexBuffer(3,PriceAlertBuf);
   SetIndexEmptyValue(3,0.0);
   
   IndicatorShortName("FXOE-SHI Channel("+SHIBars+" bars)");
	
   return(0);
}


//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
   static double lastslope= 0.0;
   static int didbreakalert= false;

   double rcslope, dummy1[100], dummy2[100];
   int counted_bars= IndicatorCounted(),
       rc;

   ArrayInitialize(UpperLimitBuf, 0.0);
   ArrayInitialize(MedLimitBuf, 0.0);
   ArrayInitialize(LowerLimitBuf, 0.0);
   ArrayInitialize(PriceAlertBuf, 0.0);
   
 
   rc= SHIChannels(0, SHIBars, dummy1, dummy2, UpperLimitBuf, MedLimitBuf, LowerLimitBuf, PriceAlertBuf, rcslope, BarsForFract, false);

  // Comment(" SHI-Channel(", SHIBars, " bars): Channel Size= ", DoubleToStr(MathAbs(UpperLimitBuf[1] - LowerLimitBuf[1])/Point,0), ", Slope = ", DoubleToStr(rcslope, 2));
 
   if (AlertSlopeChange && rcslope!=lastslope) {
         Alert("FXOE-SHIChannel changed on ", Symbol(),"/",Period());
      lastslope= rcslope;
   }

   if (AlertChannelBreak && PriceAlertBuf[0]!=0) {
      if (!didbreakalert) {
         Alert("FXOE-SHIChannel signals break on ", Symbol(),"/",Period());
         didbreakalert= true;
      }
   }
   else {
      didbreakalert= false;
   }  
   
   return (0);  
}
//+------------------------------------------------------------------+
//| SHI Channels (by shimodax, based on shurka&kevin, based on slavic|
//+------------------------------------------------------------------+
int SHIChannels(int offset, int howmany, double &upslopehistobuf[], double &downslopehistobuf[], 
                           double &uplimitbuf[], double &medlimitbuf[], double &downlimitbuf[], double &pricealertbuf[], 
                           double &rcslope, int barsfofr, int lazyness)
{
   // by Shimodax, based on  "SHI_Channel.mq4 by Shurka & Kevin"
   // original link ""
   int currentbar= 0, startbar;
   double step=0, slope;
   int b1=-1, b2=-1;
   int updown=0, 
       barsforfract= 0; // fractal (reverse point) size
   double p1=0, p2=0, pp=0, px, llow, hhigh, p1lower, p1upper;
   int i=0, lastbar= 300, ishift=0, inspectwidth;
   double iprice=0;

   rcslope= 0;
   
   // lazyness (how many fresh bars will be ignored when determining the trend)
   if (lazyness<2)
      lazyness= 2;
   

	if ((howmany==0) || (Bars<offset+howmany)) 
	  lastbar= Bars; 
	else 
	  lastbar= offset+howmany;   //lastbar-количество обсчитываемых баров
	
	if (barsfofr>0) {
		barsforfract= barsfofr; 
   }
	else {
		switch (Period()) {
			case 1: barsforfract=12; break;
			case 5: barsforfract=48; break;
			case 15: barsforfract=24; break;
			case 30: barsforfract=24; break;
			case 60: barsforfract=12; break;
			case 240: barsforfract=15; break;
			case 1440: barsforfract=10; break;
			case 10080: barsforfract=6; break;
			default: return(-1); break;
		}
	}
	

	startbar= offset + lazyness;
	b1=-1; b2=-1; 
	updown=0;
	
	currentbar= startbar; 
	while(((b1==-1) || (b2==-1)) && (currentbar<lastbar))
	{
		//updown=1 значит первый фрактал найден сверху, updown=-1 значит первый фрактал
		//найден снизу, updown=0 значит фрактал ещё не найден.
		//В1 и В2 - номера баров с фракталами, через них строим опорную линию.
		//Р1 и Р2 - соответственно цены через которые будем линию проводить

      //UpDown=1 means the 1st fractal has been found on top,
      //UpDown=-1 means the 1st fractal has been found at the bottom,
      //UpDown=0 means a fractal has not yet been found
      //B1 & B2 - base line fractal bars
      //P1 & P2 - prices for this line
      
      
      inspectwidth= MathMax(currentbar-barsforfract, startbar);  // avoid negative indices (beyond zero-bar)
                                                                 // or looking further than startbar
                                                                 // (bug found by Shahin)
      
      llow= Lowest(NULL,0, MODE_LOW, barsforfract*2+1, inspectwidth);
		if(updown<1 && currentbar==llow) 
		{
			if(updown==0) { updown=-1; b1=currentbar; p1=Low[b1]; }
			else { b2=currentbar; p2=Low[b2];}
		}
		
		hhigh= Highest(NULL,0, MODE_HIGH, barsforfract*2+1, inspectwidth);
		if(updown>-1 && (currentbar==hhigh)) 
		{
			if(updown==0) { updown=1; b1=currentbar; p1=High[b1]; }
			else { b2=currentbar; p2=High[b2]; }
		}
		currentbar++;
	}

	if((b1==-1) || (b2==-1)) {
      if (DebugLogger)
        Print("No SHI channel at [", TimeOffset(lastbar), " ... ", TimeOffset(offset+2), "]");
  
      return(-1);    // Значит не нашли фракталов среди 300 баров 8-)
                     // No fractals have been found in 300 bar range 8-)
	}
	
	step= (p2-p1)/(b2-b1);                 // slope (price diff)/(time diff)
	                                       // (if positive then the channel is descending)
	                                       
	p1= p1-(b1-offset)*step; b1= offset;   // extend right side of channel up to the right side of 
	                                       // the requested area (usually end of chart, bar= 0)
	

   //
	// determine other sides channel border 
	//
	ishift=0; iprice=0;
	if(updown==1) { 
	
		pp= 99999; // too high to survive low-tests
		
		for (i= offset+lazyness; i<=b2; i++) {    // find lowest low matching slope
			pp= MathMin(pp, Low[i]-step*(i-offset)); 
		}
	
	   // swap to make pp upper and p1 lower Point
	   p1upper= p1;
	   p1lower= pp;
	} 
	else { 
		pp= -1; // too low to surive high tests
		
		for (i= offset+lazyness; i<=b2; i++) {    // find highest high matching slope
			pp= MathMax(pp, High[i]-step*(i-offset));
		}
		
	   p1upper= pp;
	   p1lower= p1;
	}

   // now the lower trend channel slopes back from b1/p1, the upper channel from b1/pp
   
   //
	// determine range braks (upper/lower channel)
	//
	for (i= 0; i<lazyness; i++) {
	  if (Low[offset+i]<p1lower+step*i) { 
	     ishift= offset+i; 
	     iprice= p1lower + step*i; 
	  }  
	  if (High[offset+i]>p1upper+step*i) { 
	     ishift= offset+1; 
	     iprice= p1upper + step*i; 
	   }
	}

   if (iprice!=0) 
      pricealertbuf[ishift]= iprice; // // 0 (zero) means the channel line remains intact, dot means the channel is broken
   
   

   //
   // fill buffers for the in-chart channel borders
   //
   for (i= lastbar; i>=offset; i--) {
      downlimitbuf[i]= p1lower + (step * (i-b1));
      medlimitbuf[i]= ((p1lower + p1upper)/2) + (step * (i-b1));
      uplimitbuf[i]= p1upper + (step * (i-b1));
   }



   //
   // fill buffers for use with the slope histogram
   //
   slope= -step/Point;


   //
   // fill in the slope into the slop buffers 
   // 

   if (slope>0) {
      upslopehistobuf[offset]= slope;
      downslopehistobuf[offset]= 0;
   }
   else {
      downslopehistobuf[offset]= slope;
      upslopehistobuf[offset]= 0;
   }
   
   /*
   for (i= offset; i<offset+lazyness+1; i++) {
      if (slope>0) 
         upslopehistobuf[i]= slope;
      else
         downslopehistobuf[i]= slope;
   }
   */

   rcslope= slope;
   
   if (DebugLogger)
      Print(TimeOffset(offset), "FXOE SHI channel at [", TimeOffset(lastbar), " ... ", TimeOffset(offset+1), "] is ", MathRound((pp-p1)/Point), " pips wide with slope ", slope);
	        
   return(0);
}

//+------------------------------------------------------------------+
//| Helper function                                                  |
//+------------------------------------------------------------------+
string TimeOffset(int offset) 
{
   string s= TimeToStr(Time[offset]) + " #" + offset + " ";
   return (s);
}

//+------------------------------------------------------------------+   

