//+------------------------------------------------------------------+
//|                                              Trend Indicator.mq4 |
//|                                   Copyright 2014, Eric Schroeder |
//+------------------------------------------------------------------+
//#property copyright "Copyright 2014, Eric Schroeder"
//#property link      "http://www.metaquotes.net"

#property indicator_chart_window

extern int     StartingHour      = 0;
extern string  Section1          = "--- Time Frames ---";
extern string  PeriodsToWatch    = "H1,H4,D1"; // Time Frames to display are user defined
extern string  Section3          = "--- Text and Color ---";
extern int     TextSize          = 11;
extern color   TextColor         = White;
extern color   TextColor1        = White;
extern color   TrendSize         = 22;
extern int     Step_X            = 20;
extern int     Step_Y            = 19;
extern color   UpColor           = Lime;
extern color   DnColor           = Red;
extern string  FontType          = "Arial";//"Lucida Sans Unicode";
extern string  Section4          = "--- Position ---";
extern int     Corner            = 1;
extern double  DisplayStarts_X   = 1400;
extern double  DisplayStarts_Y   = 20;
extern string  Section5          = "--- Other Options ---";
extern string  PairsToWatch      = "AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,EURAUD,GBPAUD";



//int symbolCodeNoSignal=167;//108,110,,232

color colorCodeNoSignal=Silver;

//Pair extraction
int      NoOfPairs;              // Holds the number of pairs passed by the user via the inputs screen
int      NoOfPeriods;            // Holds the number of periods passed by the user via the inputs screen
string   TradePair[];            // Array to hold the pairs traded by the user
string   TradePeriod[];          // Array to hold the periods traded by the user
int      TradePeriodTF[];        // Array to hold the periods traded by the user
int      TradeTrendSymbol[][5];  // Array to hold the pairs trend symbol
color    TradeTrendColor[][5];   // Array to hold the pairs trend color

string   trend;
int      OldBars;
int      WindowNo=0;
//+------------------------------------------------------------------+
string objPrefix;  // all objects drawn by this indicator will be prefixed with this
string buff_str;
//+------------------------------------------------------------------+

int i,j,k;
double m,n;
int TF;
string Pair;
color FontColor;
bool AlertSent;
double H4Open;
static double D1Open;
double CurrentClose;
double BarOpen;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   AlertSent=false;
//   if(Corner==2 || Corner==3)
//      Alert("Please use Corner 0 or 1");

   objPrefix=WindowExpertName();

   NoOfPeriods=StringFindCount(PeriodsToWatch,",")+1;
   ArrayResize(TradePeriod,NoOfPeriods);
   ArrayResize(TradePeriodTF,NoOfPeriods);
   StrToStringArray(PeriodsToWatch,TradePeriod);

   for(j=0; j<NoOfPeriods; j++)
     {
      TradePeriodTF[j]=StrToTF(TradePeriod[j]);
     }

      //Extract the pairs traded by the user
      NoOfPairs=StringFindCount(PairsToWatch,",")+1;
      ArrayResize(TradePair,NoOfPairs);
      string AddChar=StringSubstr(Symbol(),6,4);
      StrPairToStringArray(PairsToWatch,TradePair,AddChar);

      for(i=0; i<NoOfPairs; i++)
        {
         for(j=0; j<NoOfPeriods; j++)
           {
            TF=TradePeriodTF[j];

           }
        }

//----	
   ArrayResize(TradeTrendSymbol,NoOfPairs);
//   ArrayInitialize(TradeTrendSymbol,symbolCodeNoSignal); // Initialize the array with symbolCodeNoSignal
   ArrayResize(TradeTrendColor,NoOfPairs);
   ArrayInitialize(TradeTrendColor,colorCodeNoSignal);   // Initialize the array with colorCodeNoSignal
//---- 

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   Comment("");
//+------------------------------------------------------------------+ 
   RemoveObjects(objPrefix);
//----
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {

      GetPairTrends(TradeTrendSymbol,TradeTrendColor);
      PrintPairTrends();

//----

//----
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int getPeriod(int &j1)
  {
   for(j1=0; j1<NoOfPeriods; j1++)
     {
      if(Period()==TradePeriodTF[j1])
         break;
/*		
		   switch(Period()) 
      {
         case 1:
            break;
         case 5:
            j = 0;
            break;
         case 15:
            j = 1;
            break;
         case 30:
            break;
         case 60: 
            j = 2;
            break;
         case 240: 
            j = 3;
            break;
         case 1440: 
            j = 4;
            break;
         case 10080: 
            break;
         case 43200: 
            break;
*/
     }
   return(j1);
  }
// RemoveObjects                                                     |
//-------------------------------------------------------------------+
void RemoveObjects(string Pref)
  {
//   int i;
   string objname="";

   for(i=ObjectsTotal(); i>=0; i--)
     {
      objname=ObjectName(i);
      if(StringFind(objname,Pref,0)>-1) ObjectDelete(objname);
     }
   return;
  } // End void RemoveObjects(string Pref)
//+------------------------------------------------------------------+
// StringFindCount                                                   |
//+------------------------------------------------------------------+
int StringFindCount(string str,string str2)
// Returns the number of occurrences of STR2 in STR
// Usage:   int x = StringFindCount("ABCDEFGHIJKABACABB","AB")   returns x = 3
  {
   int c=0;
   for(i=0; i<StringLen(str); i++)
      if(StringSubstr(str,i,StringLen(str2))==str2) c++;
   return(c);
  } // End int StringFindCount(string str, string str2)
//+------------------------------------------------------------------+
// StrPairToStringArray                                                  |
//+------------------------------------------------------------------+
void StrPairToStringArray(string str,string &a[],string p_suffix,string delim=",")
  {
   int z1=-1,z2=0;
   for(i=0; i<ArraySize(a); i++)
     {
      z2=StringFind(str,delim,z1+1);
      a[i]=StringSubstr(str,z1+1,z2-z1-1)+p_suffix;
      if(z2>=StringLen(str)-1) break;
      z1=z2;
     }
   return;
  } // End void StrPairToStringArray(string str, string &a[], string p_suffix, string delim=",") 
//+------------------------------------------------------------------+
// StrToStringArray                                                  |
//+------------------------------------------------------------------+
void StrToStringArray(string str,string &a[],string delim=",")
  {
   int z1=-1,z2=0;
   for(i=0; i<ArraySize(a); i++)
     {
      z2=StringFind(str,delim,z1+1);
      a[i]=StringSubstr(str,z1+1,z2-z1-1);
      if(z2>=StringLen(str)-1) break;
      z1=z2;
     }
   return;
  } // End void StrToStringArray(string str, string &a[], string delim=",") 
//+------------------------------------------------------------------+
// StrToTF(string str)                                               |
//+------------------------------------------------------------------+
// Converts a timeframe string to its MT4-numeric value
// Usage:   int x=StrToTF("M15")   returns x=15
int StrToTF(string str)
  {
   str = StringUpper(str);
   str = StringTrimLeft(str);
   str = StringTrimRight(str);

   if(str == "M1")   return(1);
   if(str == "M5")   return(5);
   if(str == "M15")  return(15);
   if(str == "M30")  return(30);
   if(str == "H1")   return(60);
   if(str == "H4")   return(240);
   if(str == "D1")   return(1440);
   if(str == "W1")   return(10080);
   if(str == "MN")   return(43200);
   return(0);
  }
//+------------------------------------------------------------------+
// StringUpper(string str)                                           |
//+------------------------------------------------------------------+
// Converts any lowercase characters in a string to uppercase
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "THE QUICK BROWN FOX"
string StringUpper(string str)
  {
   string outstr = "";
   string lower  = "abcdefghijklmnopqrstuvwxyz";
   string upper  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
   for(i=0; i<StringLen(str); i++)
     {
      int t1 = StringFind(lower,StringSubstr(str,i,1),0);
      if(t1 >=0)
         outstr=outstr+StringSubstr(upper,t1,1);
      else
         outstr=outstr+StringSubstr(str,i,1);
     }
   return(outstr);
  }
//+------------------------------------------------------------------+
//| GetPairTrends                                                    |
//+------------------------------------------------------------------+
void GetPairTrends(int &trend_symbol[][],color &trend_color[][])
  {
   for(i=0; i<NoOfPairs; i++)
     {
      Pair = TradePair[i];
         D1Open = iOpen(Pair,PERIOD_D1,0);
         H4Open = iOpen(Pair,PERIOD_H4,0);
         CurrentClose=iClose(Pair,PERIOD_D1,0);
         if(StartingHour!=0)
           {
            int shift=0;
            datetime CurrentHour=TimeHour(Time[0]);

            for(int rng=0; rng<1; rng++)
              {
               while(rng<1)
                 {
                  if(CurrentHour == 0)
                     CurrentHour = 24;

                  if(CurrentHour==StartingHour)
                    {
                     int DayStartBar=shift;
                     break;
                    }
                  CurrentHour--;
                  shift++;
                 }
              }// end for(int rng=0;rng<1;rng++)
            D1Open = iOpen(Pair,PERIOD_H1,DayStartBar);
            H4Open = iOpen(Pair,PERIOD_H1,(DayStartBar%4));
            CurrentClose=iClose(Pair,PERIOD_H1,0);
           }
      for(j=0; j<NoOfPeriods; j++)
        {
         TF=TradePeriodTF[j];

           {
//            trend_symbol[i][j]= symbolCodeNoSignal;
            trend_color[i][j] = colorCodeNoSignal;
      BarOpen=iOpen(Pair,TF,0);
      if(TF==1440)
         BarOpen=D1Open;
      if(TF==240)
         BarOpen=H4Open;
      

            if(BarOpen<CurrentClose)
               trend_color[i][j] = UpColor;
            if(BarOpen>CurrentClose)
               trend_color[i][j] = DnColor;
           }
        } //End for(j=0; j<NoOfPeriods; j++)
     } //End for(i=0; i<NoOfPairs; i++)
   return;

  }//End GetPairTrends(int &trend_symbol[][], color &trend_color[][])
//+------------------------------------------------------------------+
//| PrintPairTrends                                                    |
//+------------------------------------------------------------------+
void PrintPairTrends()
  {
   RemoveObjects(objPrefix);

      //Set Trade Pair
      for(i=0; i<NoOfPairs; i++)
        {
         buff_str=StringConcatenate(objPrefix,TradePair[i]);
         ObjectDelete(buff_str);
         ObjectCreate(buff_str,OBJ_LABEL,WindowNo,0,0,0,0);
         ObjectSet(buff_str,OBJPROP_CORNER,1);
         ObjectSet(buff_str,OBJPROP_XDISTANCE,DisplayStarts_X+TextSize*(NoOfPeriods*2));
         ObjectSet(buff_str,OBJPROP_YDISTANCE,DisplayStarts_Y+(i+1)*(Step_Y));
         ObjectSetText(buff_str,TradePair[i],TextSize-2,FontType,TextColor1);
        }
//Set Trade Period
   for(j=0; j<NoOfPeriods; j++)
     {
      buff_str=StringConcatenate(objPrefix,TradePeriod[j]);
      ObjectDelete(buff_str);
      ObjectCreate(buff_str,OBJ_LABEL,WindowNo,0,0,0,0);
      ObjectSet(buff_str,OBJPROP_CORNER,1);
      ObjectSet(buff_str,OBJPROP_XDISTANCE,DisplayStarts_X+2+(NoOfPeriods-1-j)*(Step_X));
      ObjectSet(buff_str,OBJPROP_YDISTANCE,DisplayStarts_Y);
      ObjectSetText(buff_str,TradePeriod[j],TextSize-2,FontType,TextColor);
     }
//Set Trade Trend
   for(i=0; i<NoOfPairs; i++)
     {
      for(j=0; j<NoOfPeriods; j++)
        {
         buff_str=StringConcatenate(objPrefix,TradePair[i],TradePeriod[j]);
         ObjectDelete(buff_str);
         ObjectCreate(buff_str,OBJ_LABEL,WindowNo,0,0,0,0);
         ObjectSet(buff_str,OBJPROP_CORNER,1);
         ObjectSet(buff_str,OBJPROP_XDISTANCE,DisplayStarts_X+(NoOfPeriods-1-j)*(Step_X));
         ObjectSet(buff_str,OBJPROP_YDISTANCE,DisplayStarts_Y+(i+0.5)*(Step_Y));//+TextSize/2));
         ObjectSetText(buff_str,"n",TrendSize,"Wingdings",TradeTrendColor[i][j]);
        }
     }
//----
   return;

  }//End PrintPairTrends()
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//                                                                   |
//+------------------------------------------------------------------+
void getMinBars(int TF1,int &MinBars)
  {
   switch(TF1)
     {
      case 1:
         break;
      case 5:
         MinBars=50;
         break;
      case 15:
         MinBars=50;
         break;
      case 30:
         break;
      case 60:
         MinBars=50;
         break;
      case 240:
         MinBars=35;
         break;
      case 1440:
         MinBars=15;
         break;
      case 10080:
         break;
      case 43200:
         break;
     }
   return;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
