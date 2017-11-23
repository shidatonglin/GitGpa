//+------------------------------------------------------------------+
//|                                                        Clock.mq4 |
//|                                                           Jerome |
//|                                                4xCoder@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Jerome"
#property link      "4xCoder@gmail.com"

#import "kernel32.dll"
void GetLocalTime(int& TimeArray[]);
void GetSystemTime(int& TimeArray[]);
int  GetTimeZoneInformation(int& TZInfoArray[]);
#import

//------------------------------------------------------------------
// Instructions
//    This Version requires Allow DLL Imports be set in Common Tab when you add this to a chart.
//    You can also enable this by default in the Options>Expert Advisors Tab, but you may want
//    to turn off "Confirm DLL Function Calls"
//
//    ShowLocal - Set to tru to show your local time zone
//    corner    - 0 = top left, 1 = top right, 2 = bottom left, 3 = bottom right
//    topOff    - pixels from top to show the clock
//    labelColor- Color of label
//    clockColor- Color of clock
//    show12HourTime - true show 12 hour time, false, show 24 hour time
//    myGMT     - put your timezone (e.g: 8 for malaysia, -5 for New York)
//
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red


//---- input parameters
extern bool         ShowLocal=true;
extern int          corner=3;
extern int          topOff=380;
extern color        labelColor=Gray;
extern color        clockColor=White;
extern bool         show12HourTime=false;
extern int          myGMT=8;  //added by RJ1
//---- spread monitor
int Spread;
//---- buffers
double ExtMapBuffer1[];
int LondonTZ = 0;
int TokyoTZ = 9;
int NewYorkTZ = -5;

string TimeToString( datetime when ) {
   if ( !show12HourTime )
      return (TimeToStr( when, TIME_MINUTES ));
      
   int hour = TimeHour( when );
   int minute = TimeMinute( when );
   
   string ampm = " AM";
   
   string timeStr;
   if ( hour >= 12 ) {
      hour = hour - 12;
      ampm = " PM";
   }
      
   if ( hour == 0 )
      hour = 12;
   timeStr = DoubleToStr( hour, 0 ) + ":";
   if ( minute < 10 )
      timeStr = timeStr + "0";
   timeStr = timeStr + DoubleToStr( minute, 0 );
   timeStr = timeStr + ampm;
   
   return (timeStr);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  if ( !IsDllsAllowed() ) {
      Alert( "Clock V1_2: DLLs are disabled.  To enable tick the checkbox in the Common Tab of indicator" );
      return;
  }
   int    counted_bars=IndicatorCounted();
//----
      
   int    TimeArray[4];
   int    TZInfoArray[43];
   int    nYear,nMonth,nDay,nHour,nMin,nSec,nMilliSec;
   string sMilliSec;
   
   GetLocalTime(TimeArray);
//---- parse date and time from array
   nYear=TimeArray[0]&0x0000FFFF;
   nMonth=TimeArray[0]>>16;
   nDay=TimeArray[1]>>16;
   nHour=TimeArray[2]&0x0000FFFF;
   nMin=TimeArray[2]>>16;
   nSec=TimeArray[3]&0x0000FFFF;
   nMilliSec=TimeArray[3]>>16;
   string LocalTimeS = FormatDateTime(nYear,nMonth,nDay,nHour,nMin,nSec);
   datetime localTime = StrToTime( LocalTimeS );

   //-----------------------------------------------------
   LondonTZ = GMT_Offset("LONDON",localTime);
   TokyoTZ = GMT_Offset("TOKYO",localTime);
   NewYorkTZ = GMT_Offset("US",localTime);
   //-----------------------------------------------------
   
   
   int gmt_shift=0-myGMT;
   int dst=GetTimeZoneInformation(TZInfoArray);
   if(dst!=0) gmt_shift=TZInfoArray[0];
   //Print("Difference between your local time and GMT is: ",gmt_shift," minutes");
   if(dst==2) gmt_shift+=TZInfoArray[42];
   

   datetime brokerTime = CurTime();
   datetime GMT = localTime + gmt_shift * 3600;  //added by RJ1
   
   //datetime london = GMT + (LondonTZ + (dst - 1)) * 3600;
   //datetime tokyo = GMT + (TokyoTZ) * 3600;
   //datetime newyork = GMT + (NewYorkTZ + (dst - 1)) * 3600;
   datetime london = GMT + (LondonTZ) * 3600;
   datetime tokyo = GMT + (TokyoTZ) * 3600;
   datetime newyork = GMT + (NewYorkTZ) * 3600;
   
   //Print( brokerTime, " ", GMT, " ", local, " ", london, " ", tokyo, " ", newyork  );
   string BrokerName=TerminalCompany(); //added by RJ1
   string BrokerGMT; //added by RJ1
   string GMTs = TimeToString( GMT );
   string GMTd = TimeDay (GMT);  //added by RJ1
   string GMTm = TimeMonth (GMT);  //added by RJ1
   string GMTQ = GMTs + "  " + GMTd+"/"+GMTm;  //added by RJ1
   string locals = TimeToString( localTime  );
   string locald = TimeDay( localTime  );  //added by RJ1
   string localm = TimeMonth( localTime  );  //added by RJ1
   string localQ = locals + "  " + locald+"/"+localm;  //added by RJ1
   string londons = TimeToString( london  );
   string londond = TimeDay (london);  //added by RJ1
   string londonm = TimeMonth (london);  //added by RJ1
   string londonQ = londons + "  " + londond+"/"+londonm;    //added by RJ1
   string tokyos = TimeToString( tokyo  );
   string tokyod = TimeDay (tokyo);  //added by RJ1
   string tokyom = TimeMonth (tokyo);  //added by RJ1
   string tokyoQ = tokyos + "  " + tokyod+"/"+tokyom;  //added by RJ1
   string newyorks = TimeToString( newyork  );
   string newyorkd = TimeDay (newyork);  //added by RJ1
   string newyorkm = TimeMonth (newyork);  //added by RJ1
   string newyorkQ = newyorks + "  " + newyorkd+"/"+newyorkm;  //added by RJ1
   string brokers = TimeToString( CurTime() );
   string brokerd = TimeDay (brokerTime);  //added by RJ1
   string brokerm = TimeMonth (brokerTime);  //added by RJ1
   string brokerQ = brokers + "  " + brokerd+"/"+brokerm;  //added by RJ1
   string bars = TimeToStr( CurTime() - Time[0], TIME_MINUTES );
   
   if ( ShowLocal ) {
      ObjectSetText( "locl", "Local:", 8, "Arial", labelColor );
      ObjectSetText( "loct", localQ, 8, "Arial", clockColor );
   }
   ObjectSetText( "gmtl", "GMT:", 8, "Arial", labelColor );
   ObjectSetText( "gmtt", GMTQ, 8, "Arial", clockColor );
   ObjectSetText( "nyl", "New York:", 8, "Arial", labelColor );
   ObjectSetText( "nyt", newyorkQ, 8, "Arial", clockColor );
   ObjectSetText( "lonl", "London:", 8, "Arial", labelColor );
   ObjectSetText( "lont", londonQ, 8, "Arial", clockColor );
   ObjectSetText( "tokl", "Tokyo:", 8, "Arial", labelColor );
   ObjectSetText( "tokt", tokyoQ, 8, "Arial", clockColor );
   ObjectSetText( "brol", "Broker:", 8, "Arial", labelColor );
   ObjectSetText( "brot", brokerQ, 8, "Arial", clockColor );
   ObjectSetText( "barl", "Bar:", 8, "Arial", labelColor );
   ObjectSetText( "bart", bars, 8, "Arial", clockColor );
//---- spread
        Spread=NormalizeDouble((Ask-Bid)/Point,0);
        ObjectSetText("Spread Monitor1","Spread:", 8, "Arial", labelColor);
        ObjectSetText("Spread Monitor2",DoubleToStr(Spread ,0),8, "Arial", clockColor);
        
        //added by RJ1 to calculate Broker Timezone
        ObjectSetText("broGMT1",BrokerName+":", 8, "Arial", labelColor);
         if((brokerTime-GMT)>=0)
          BrokerGMT="GMT +"+DoubleToStr((StrToTime(brokers)-StrToTime(GMTs))/3600,0);
        else  
          BrokerGMT="GMT -"+DoubleToStr((StrToTime(brokers)-StrToTime(GMTs))/3600,0);
        ObjectSetText("broGMT2",BrokerGMT, 8, "Arial", clockColor);       
        
//----
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int ObjectMakeLabel( string n, int xoff, int yoff ) {
   ObjectCreate( n, OBJ_LABEL, 0, 0, 0 );
   ObjectSet( n, OBJPROP_CORNER, corner );
   ObjectSet( n, OBJPROP_XDISTANCE, xoff );
   ObjectSet( n, OBJPROP_YDISTANCE, yoff );
   ObjectSet( n, OBJPROP_BACK, true );
}

string FormatDateTime(int nYear,int nMonth,int nDay,int nHour,int nMin,int nSec)
  {
   string sMonth,sDay,sHour,sMin,sSec;
//----
   sMonth=100+nMonth;
   sMonth=StringSubstr(sMonth,1);
   sDay=100+nDay;
   sDay=StringSubstr(sDay,1);
   sHour=100+nHour;
   sHour=StringSubstr(sHour,1);
   sMin=100+nMin;
   sMin=StringSubstr(sMin,1);
   sSec=100+nSec;
   sSec=StringSubstr(sSec,1);
//----
   return(StringConcatenate(nYear,".",sMonth,".",sDay," ",sHour,":",sMin,":",sSec));
  }

int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   
   int top=topOff;
   int left = 102;
   if ( show12HourTime )
      left = 102;
   if ( ShowLocal ) {
      ObjectMakeLabel( "locl", left, 75 );
      ObjectMakeLabel( "loct", 40, 75 );
   }
   ObjectMakeLabel( "brol", left, 105 );
   ObjectMakeLabel( "brot", 40, 105 );
   ObjectMakeLabel( "gmtl", left, 60 );
   ObjectMakeLabel( "gmtt", 40, 60 );
   ObjectMakeLabel( "nyl", left, 45 );
   ObjectMakeLabel( "nyt", 40, 45 );
   ObjectMakeLabel( "lonl", left, 30 );
   ObjectMakeLabel( "lont", 40, 30 );
   ObjectMakeLabel( "tokl", left, 15 );
   ObjectMakeLabel( "tokt", 40, 15 );
   ObjectMakeLabel( "barl", left, 0 );
   ObjectMakeLabel( "bart", 40, 0 );
//---- spread monitor
   ObjectMakeLabel( "Spread Monitor1", left, 90 );   
   ObjectMakeLabel( "Spread Monitor2", 80, 90 );   
   ObjectMakeLabel( "broGMT1", left, 120 );  //added by RJ1
   ObjectMakeLabel( "broGMT2", 55, 120 );  //added by RJ1    

  //----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete( "locl" );
   ObjectDelete( "loct" );
   ObjectDelete( "brol" );
   ObjectDelete( "brot" );
   ObjectDelete( "nyl" );
   ObjectDelete( "nyt" );
   ObjectDelete( "gmtl" );
   ObjectDelete( "gmtt" );
   ObjectDelete( "lonl" );
   ObjectDelete( "lont" );
   ObjectDelete( "tokl" );
   ObjectDelete( "tokt" );
   ObjectDelete( "barl" );
   ObjectDelete( "bart" );
//---- spread monitor
   ObjectDelete( "Spread Monitor1" );   
   ObjectDelete( "Spread Monitor2" );
   ObjectDelete( "broGMT1" );   //added by RJ1      
   ObjectDelete( "broGMT2" );  //added by RJ1
//----
   return(0);
  }
  
/////////////////////////////////////////////////////////////////////////////////////
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GMT_Offset(string region,datetime dt1)
{
  int r1=0;
  if (region== "FRANKFURT")
    r1=GMT1(dt1);  
  else if (region=="LONDON")    
    r1=GMT0(dt1);
  else if (region=="US")        
    r1=GMT_5(dt1); 
  else if (region=="TOKYO")        
    r1=GMT9(dt1);      
  
    return (r1);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GMT0(datetime dt1)
{
//UK Standard Time = GMT
//UK Summer Time = BST (British Summer time) = GMT+1
//For 2003-2007 inclusive, the summer-time periods begin and end respectively on 
//the following dates at 1.00am Greenwich Mean Time:
//2003: the Sundays of 30 March and 26 October
//2004: the Sundays of 28 March and 31 October
//2005: the Sundays of 27 March and 30 October
//2006: the Sundays of 26 March and 29 October
//2007: the Sundays of 25 March and 28 October
  if ((dt1>last_sunday(TimeYear(dt1),3))&&(dt1<last_sunday(TimeYear(dt1),10)))
   return(1);//summer
  else
   return(0); 

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GMT_5(datetime dt1)
{
//US
//-------------------------------------------------------------------
//Eastern Standard Time (EST) = GMT-5
//-------------------------------------------------------------------
//Eastern Daylight Time (EDT) = GMT-4
//-----+--------------------------+----------------------------------
//Year | 	DST Begins 2 a.m.     |     DST Ends 2 a.m.
//1990-|                          |
//2006 |  (First Sunday in April) |	(Last Sunday in October)
//-----+--------------------------+----------------------------------                                  
//-----+--------------------------+----------------------------------
//Year | 	DST Begins 2 a.m.     |     DST Ends 2 a.m.
//2007-|  (Second Sunday in March)|	(First Sunday in November)
//-----+--------------------------+----------------------------------                                  

 if(TimeYear(dt1)<2007)
   if ((dt1>first_sunday(TimeYear(dt1),4))&&(dt1<last_sunday(TimeYear(dt1),10)))
     return(-4);
    else
     return(-5); 
 else
   if ((dt1>second_sunday(TimeYear(dt1),3))&&(dt1<first_sunday(TimeYear(dt1),11)))
     return(-4);
    else
     return(-5); 
     
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GMT9(datetime dt1)
{
   return(9);//standard=summer=+9

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_leap_year(int year1)
{
 
  if ((MathMod(year1,100)==0) && (MathMod(year1,400)==0))
    return(true);
  else if ((MathMod(year1,100)!=0) && (MathMod(year1,4)==0))  
    return(true);
  else 
    return (false); 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int n_days(int year1,int month1)
{
  int ndays1;
  if (month1==1)
    ndays1=31;
  else if(month1==2)
  {
    if (is_leap_year(year1))
      ndays1=29;      
    else
      ndays1=28;  
  }    
  else if(month1==3)
    ndays1=31;  
  else if(month1==4)
    ndays1=30;  
  else if(month1==5)//mai
    ndays1=31;  
  else if(month1==6)//iun          
    ndays1=30;  
  else if(month1==7)//iul          
    ndays1=31;  
  else if(month1==8)//aug          
    ndays1=31;  
  else if(month1==9)//sep          
    ndays1=30;  
  else if(month1==10)//oct          
    ndays1=31;  
  else if(month1==11)//nov          
    ndays1=30;  
  else if(month1==12)          
    ndays1=31;  
  
  return(ndays1);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int n_sdays(int year1,int month1)
{
  datetime ddt2;
  int ndays2=n_days(year1,month1);
  int i,nsun1=0;  
  for (i=1;i<=ndays2;i++) 
  {
    ddt2= StrToTime(DoubleToStr(year1,0)+"."+DoubleToStr(month1,0)+"."+DoubleToStr(i,0)+" 00:00");            
    if(TimeDayOfWeek(ddt2)==0)
      nsun1=nsun1+1; 
  }   
  return(nsun1);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime last_sunday(int year1,int month1)
{
  int i,ndays2,nsun1,nsun2;
  datetime dt2,dt3;
  ndays2=n_days(year1,month1);
  nsun2=n_sdays(year1,month1);
  nsun1=0;
  for (i=1;i<=ndays2;i++) 
  {
    dt2= StrToTime(DoubleToStr(year1,0)+"."+DoubleToStr(month1,0)+"."+DoubleToStr(i,0)+" 00:00");                    
    if(TimeDayOfWeek(dt2)==0)
    {       
      nsun1=nsun1+1; 
    }  
    if (nsun1==nsun2) 
    {
      dt3=dt2;  
      break;        
    }  
  }   
  return(dt3);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime first_sunday(int year1,int month1)
{
  int i,ndays2,nsun1,nsun2;
  datetime dt2,dt3;
  ndays2=n_days(year1,month1);
  nsun2=1;//n_sdays(year1,month1);
  nsun1=0;
  for (i=1;i<=ndays2;i++) 
  {
    dt2= StrToTime(DoubleToStr(year1,0)+"."+DoubleToStr(month1,0)+"."+DoubleToStr(i,0)+" 00:00");                    
    if(TimeDayOfWeek(dt2)==0)
    {       
      nsun1=nsun1+1; 
    }  
    if (nsun1==nsun2) 
    {
      dt3=dt2;  
      break;        
    }  
  }   
  return(dt3);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime second_sunday(int year1,int month1)
{
  int i,ndays2,nsun1,nsun2;
  datetime dt2,dt3;
  ndays2=n_days(year1,month1);
  nsun2=2;//n_sdays(year1,month1);
  nsun1=0;
  for (i=1;i<=ndays2;i++) 
  {
    dt2= StrToTime(DoubleToStr(year1,0)+"."+DoubleToStr(month1,0)+"."+DoubleToStr(i,0)+" 00:00");                    
    if(TimeDayOfWeek(dt2)==0)
    {       
      nsun1=nsun1+1; 
    }  
    if (nsun1==nsun2) 
    {
      dt3=dt2;  
      break;        
    }  
  }   
  return(dt3);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GMT1(datetime dt1)
{
//EUROPE
//Summer Time Rule 
//Start: Last Sunday in March
//End: Last Sunday in October
//Time: 1.00 am (01:00) Greenwich Mean Time (GMT) 
  
  if ((dt1>last_sunday(TimeYear(dt1),3))&&(dt1<last_sunday(TimeYear(dt1),10)))
   return(2);
  else
   return(1); 
}

  

