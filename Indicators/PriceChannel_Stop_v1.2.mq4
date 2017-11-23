//+------------------------------------------------------------------+
//|                                       PriceChannel_Stop_v1.2.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Aqua
#property indicator_color2 Magenta
#property indicator_color3 Aqua
#property indicator_color4 Magenta
#property indicator_color5 Aqua
#property indicator_color6 Magenta
//---- input parameters
extern int ChannelPeriod=9;
extern double Risk=0.30;
extern int Signal=1;
extern int Line=1;
extern int SoundAlertMode=0;
extern int SMSAlertMode=0;
extern int AlertTimes=1;
extern int Nbars=1000;
//---- indicator buffers
double UpTrendBuffer[];
double DownTrendBuffer[];
double UpTrendSignal[];
double DownTrendSignal[];
double UpTrendLine[];
double DownTrendLine[];
double trend[];
bool UpTrendAlert=false, DownTrendAlert=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   IndicatorBuffers(7);
   SetIndexBuffer(0,UpTrendBuffer);
   SetIndexBuffer(1,DownTrendBuffer);
   SetIndexBuffer(2,UpTrendSignal);
   SetIndexBuffer(3,DownTrendSignal);
   SetIndexBuffer(4,UpTrendLine);
   SetIndexBuffer(5,DownTrendLine);
   SetIndexBuffer(6,trend);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexArrow(0,159);
   SetIndexArrow(1,159);
   SetIndexArrow(2,108);
   SetIndexArrow(3,108);
//---- name for DataWindow and indicator subwindow label
   short_name="PriceChannel_Stop_v1("+ChannelPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"UpTrend Stop");
   SetIndexLabel(1,"DownTrend Stop");
   SetIndexLabel(2,"UpTrend Signal");
   SetIndexLabel(3,"DownTrend Signal");
   SetIndexLabel(4,"UpTrend Line");
   SetIndexLabel(5,"DownTrend Line");
//----
   SetIndexDrawBegin(0,ChannelPeriod);
   SetIndexDrawBegin(1,ChannelPeriod);
   SetIndexDrawBegin(2,ChannelPeriod);
   SetIndexDrawBegin(3,ChannelPeriod);
   SetIndexDrawBegin(4,ChannelPeriod);
   SetIndexDrawBegin(5,ChannelPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| PriceChannel_Stop_v1                                             |
//+------------------------------------------------------------------+
int start()
  {
   int    i,shift;
   double high, low, price;
   double smax[5000],smin[5000],bsmax[5000],bsmin[5000];
   string Message;
   
   for (shift=Nbars-1;shift>=0;shift--)
   {
   UpTrendBuffer[shift]=EMPTY_VALUE;
   DownTrendBuffer[shift]=EMPTY_VALUE;
   UpTrendSignal[shift]=-1;
   DownTrendSignal[shift]=-1;
   UpTrendLine[shift]=EMPTY_VALUE;
   DownTrendLine[shift]=EMPTY_VALUE;
   trend[shift]=0;
   }
   for (shift=Nbars-ChannelPeriod-1;shift>=0;shift--)
   {	
      high=High[shift]; low=Low[shift]; i=shift-1+ChannelPeriod;
      while(i>=shift)
        {
         price=High[i];
         if(high<price) high=price;
         price=Low[i];
         if(low>price)  low=price;
         i--;
        } 
     smax[shift]=high;
     smin[shift]=low;
     
     bsmax[shift]=smax[shift]-(smax[shift]-smin[shift])*Risk;
	  bsmin[shift]=smin[shift]+(smax[shift]-smin[shift])*Risk;
     
     trend[shift]=trend[shift+1];
     if (Close[shift]>bsmax[shift+1])  {trend[shift]= 1; } 
	  if (Close[shift]<bsmin[shift+1])  {trend[shift]=-1; }
		  		
	  if(trend[shift]>0 && bsmin[shift]<bsmin[shift+1]) bsmin[shift]=bsmin[shift+1];
	  if(trend[shift]<0 && bsmax[shift]>bsmax[shift+1]) bsmax[shift]=bsmax[shift+1];
	  
	  if (trend[shift]>0) 
	  {
	     
	     if (Signal>0 && UpTrendBuffer[shift+1]==-1.0)
	     {
	     UpTrendSignal[shift]=bsmin[shift];
	     if(Line>0) UpTrendLine[shift]=bsmin[shift];
	     if (SoundAlertMode>0 && shift==0) PlaySound("alert2.wav");
	     }
	     else
	     {
	     UpTrendBuffer[shift]=bsmin[shift];
	     if(Line>0) UpTrendLine[shift]=bsmin[shift];
	     UpTrendSignal[shift]=-1;
	     }
	  
	  if (Signal==2) UpTrendBuffer[shift]=0;   
	  DownTrendBuffer[shift]=-1.0;
	  DownTrendLine[shift]=EMPTY_VALUE;
	  }
	  
	  
	  if (trend[shift]<0) 
	  {
	  
	  if (Signal>0 && DownTrendBuffer[shift+1]==-1.0)
	     {
	     DownTrendSignal[shift]=bsmax[shift];
	     if(Line>0) DownTrendLine[shift]=bsmax[shift];
	     if (SoundAlertMode>0 && shift==0) PlaySound("alert2.wav");
	     }
	     else
	     {
	     DownTrendBuffer[shift]=bsmax[shift];
	     if(Line>0)DownTrendLine[shift]=bsmax[shift];
	     DownTrendSignal[shift]=-1;
	     }
	  
	  if (Signal==2) DownTrendBuffer[shift]=0;    
	  UpTrendBuffer[shift]=-1.0;
	  UpTrendLine[shift]=EMPTY_VALUE;
	  }
	  
	  
	 
	  //if ( trend[0]>0 && Close[2]<=bsmax[3] && Close[1]>bsmax[2] && Volume[0]>1 && !UpTrendAlert)
	  if ( trend[2]<0 && trend[1]>0 && Volume[0]>1 && !UpTrendAlert)
	  {
	  Message = " "+Symbol()+" M"+Period()+": Signal for BUY";
	  if ( SoundAlertMode>0 ) Alert (Message); 
	  if ( SMSAlertMode>0   ) SendMail ("Signal from PriceChannel_Stop",TimeToStr(CurTime())+Message);
	  UpTrendAlert=true; DownTrendAlert=false;
	  } 
	 
	  
	  //if ( trend[0]<0 && Close[2]>=bsmin[3] && Close[1]<bsmin[2] && Volume[0]>1 && !DownTrendAlert)
	  if ( trend[2]>0 && trend[1]<0 && Volume[0]>1 && !DownTrendAlert)
	  {
	  Message = " "+Symbol()+" M"+Period()+": Signal for SELL";
	  if ( SoundAlertMode>0 ) Alert (Message); 
	  if ( SMSAlertMode>0   ) SendMail ("Signal from PriceChannel_Stop",TimeToStr(CurTime())+Message);
	  DownTrendAlert=true; UpTrendAlert=false;
	  } 
	 
   }
   return(0);
  }
//+------------------------------------------------------------------+