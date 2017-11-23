#property copyright "Paradox"
#property link "http://www.forexfactory.com"
//#include <stdlib.mqh>

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 CLR_NONE
#property indicator_color2 CLR_NONE
#property indicator_color3 CLR_NONE
#property indicator_color4 CLR_NONE
#property indicator_color5 CLR_NONE
#property indicator_color6 CLR_NONE
#property indicator_color7 CLR_NONE
#property indicator_color8 CLR_NONE
   
extern string Pairs = "AUDJPY,AUDUSD,CHFJPY,EURCHF,EURGBP,EURJPY,EURUSD,GBPCHF,GBPJPY,GBPUSD,NZDJPY,NZDUSD,USDCHF,USDJPY";
extern string Weights = "1,1,1,1,1,1,1,-1,1,1,1,1,-1,1";
extern int StartBars = 800;
extern color UpColor = MediumSeaGreen;
extern color DnColor = OrangeRed;
extern int BodyWidth = 4;
extern int WickWidth = 1;
extern int HAMethod1 = 2;
extern int HAPeriod1 = 15;
extern int HAMethod2 = 2;
extern int HAPeriod2 = 15;
extern color HAUpColor = RoyalBlue;
extern color HADnColor = Red;
extern int ATRPeriod = 100;

extern int StatsFontSize = 10;
extern int StatsCorner = 1;
extern color StatsColor = LightSeaGreen;
extern color StatsNegativeColor = Red;
extern color StatsBgColor = DarkSlateGray;



string PairVals[]; 
double WeightVals[];
 
bool ShowPairStarts = true;


string BrokerSuffix = "";

//---- buffers
double HighBuffer[];
double LowBuffer[]; 
double OpenBuffer[];
double CloseBuffer[]; 
double HAOpen[];
double HAClose[]; 
double HAOpenMA[];
double HACloseMA[]; 

datetime LastBarTime = 0;
int LastWindowBars = 0;
int LastFirstBars = 0;
bool initDone = false;
double Spread = 0;
int TimeSize;
string PREFIX = "BASKET_CHART";
int ObjectId;
//+------------------------------------------------------------------+
//     expert initialization function                                |       
//+------------------------------------------------------------------+
int init()
{ 
  
   PREFIX = PREFIX;


   StringSplit(Pairs, ",", PairVals);
   StringSplitToDoubles(Weights, ",", WeightVals);
   Comment("");
   if (ArraySize(PairVals) != ArraySize(WeightVals))
   {
      Print ("Pair and Weight sizes do not match: PairVals = ", ArraySize(PairVals), " Weights = ", ArraySize(WeightVals));
      Comment ("Pair and Weight sizes do not match: PairVals = ", ArraySize(PairVals), " Weights = ", ArraySize(WeightVals));
      return;
   }
   BrokerSuffix = StringSubstr(Symbol(),6); 
   
   IndicatorBuffers(8); 
   SetIndexBuffer(0, OpenBuffer);
   SetIndexBuffer(1, HighBuffer);
   SetIndexBuffer(2, LowBuffer); 
   SetIndexBuffer(3, CloseBuffer); 
   SetIndexBuffer(4, HAOpen);
   SetIndexBuffer(5, HAClose);
   SetIndexBuffer(6, HAOpenMA); 
   SetIndexBuffer(7, HACloseMA); 

   SetIndexLabel(0, "Open");
   SetIndexLabel(1, "High");
   SetIndexLabel(2, "Low"); 
   SetIndexLabel(3, "Close");  
   SetIndexLabel(4, "HAOpen");
   SetIndexLabel(5, "HAClose");
   SetIndexLabel(6, "HAOpenMA"); 
   SetIndexLabel(7, "HACloseMA");  

   IndicatorShortName(PREFIX); 

   for (int i = Bars; i >= 0 ; i--)
   { 
      HighBuffer[i]=EMPTY_VALUE;
      LowBuffer[i]=EMPTY_VALUE; 
      OpenBuffer[i]=EMPTY_VALUE;
      CloseBuffer[i]=EMPTY_VALUE; 
      HAOpen[i]=EMPTY_VALUE;
      HAClose[i]=EMPTY_VALUE; 
      HAOpenMA[i]=EMPTY_VALUE;
      HACloseMA[i]=EMPTY_VALUE; 
   }
   
   DeleteObjectsByPrefix(PREFIX + "_BB");
   DeleteObjectsByPrefix(PREFIX + "_SB");
   //----
   //InitChart();
   //----
   return(0);                                                              
}

void InitChart()
{ 
   DeleteObjectsByPrefix(PREFIX + "_BB");
   DeleteObjectsByPrefix(PREFIX + "_SB");  
   
   TimeSize = MathAbs(Time[0] - Time[1]);
   int limit = MathMin(StartBars,Bars);
   if (StartBars == 0) limit = WindowBarsPerChart();
     
   //Print (" limit ", limit, " IndicatorCounted()  ", IndicatorCounted() );
   for (int i = limit-1; i >= 0 ; i--)
   {
      HighBuffer[i]=EMPTY_VALUE;
      LowBuffer[i]=EMPTY_VALUE;   
      OpenBuffer[i]=EMPTY_VALUE;
      CloseBuffer[i]=EMPTY_VALUE;    
      HAOpen[i]=EMPTY_VALUE;
      HAClose[i]=EMPTY_VALUE; 
      HAOpenMA[i]=EMPTY_VALUE;
      HACloseMA[i]=EMPTY_VALUE; 
   }
   int start = 0;
   
   //Print (" limit ", limit);
   for (i = start; i < limit; i++)   
   {
      plot(i);
   }
   DrawHA();
}
//+------------------------------------------------------------------+
//     expert deinitialization function                              |       
//+------------------------------------------------------------------+
int deinit()
{
   DeleteObjectsByPrefix(PREFIX);

   //Print("shutdown error - ",ErrorDescription(GetLastError()));                               

   return(0);                                                               
}

//+------------------------------------------------------------------+
//     expert start function                                         |       
//+------------------------------------------------------------------+

int start()
{ 
   if (ArraySize(PairVals) != ArraySize(WeightVals))
   {
      Print ("Pair and Weight sizes do not match: PairVals = ", ArraySize(PairVals), " Weights = ", ArraySize(WeightVals));
      Comment ("Pair and Weight sizes do not match: PairVals = ", ArraySize(PairVals), " Weights = ", ArraySize(WeightVals));
      return;
   }
   
  if(!initDone){InitChart();initDone = true;}
   
   int limit=1;

   for(;limit<(Bars - 100);limit++)
   {
      if(HighBuffer[limit]!=EMPTY_VALUE) break;
   }      
   //Print (" limit ", limit);
   int start = 0;    

   for (int i = start; i <= limit; i++)   
   {
      plot(i);
   }
 
   //Print (" ObjectFind(Refresh) ", ObjectFind("Refresh"));
   if(LastBarTime != Time[0] || LastWindowBars != WindowBarsPerChart() || LastFirstBars != WindowFirstVisibleBar() || ObjectFind("Refresh") >= 0)
   {
      LastBarTime = Time[0];
      LastWindowBars = WindowBarsPerChart();       
      LastFirstBars = WindowFirstVisibleBar();       
      DrawCandlesticks();
      DrawHA();
   }
   ShowStats();
   return(0);                                                               // end of start funtion
}
    
  
//+------------------------------------------------------------------+
//     expert custom function                                        |       
//+------------------------------------------------------------------+    
void plot(int shift)                         
  {
//---- 
   int    index, pindex;
   double cnt;
   string symbol; 
  
   RefreshRates();   
   
   double open =0; 
   double high =0; 
   double low =0; 
   double close =0; 
   int pairCount =ArrayRange(PairVals,0); 
    
   for (index = 0; index < pairCount; index++)                                
   {                           
      
      symbol = PairVals[index] + BrokerSuffix;          

      int offset = iBarShift(symbol,0,Time[shift] );
      if ( MathAbs(Time[shift]  - iTime(symbol,0, offset)) > 120)
      {  if ( MathAbs(Time[shift]  - iTime(symbol,0, offset+1)) < 120)         
         {                  
            //Print("Added offset");
            offset = offset+1;
         }
         else if ( MathAbs(Time[shift]  - iTime(symbol,0, offset-1)) < 120)         
         {                  
            //Print("Decrement offset");
            offset = offset-1;
         }
         else{
       
         //Weights[index] = 0;
         if (offset > 5) Print("MISMATCHED BAR symbol ", symbol, " Time[shift] ", TimeToStr(Time[shift]), " iTime(symbol,0, offset) ", TimeToStr(iTime(symbol,0,offset)), " iTime(symbol,0, offset+1) ", TimeToStr(iTime(symbol,0,offset+1)), " iTime(symbol,0, offset-1) ", TimeToStr(iTime(symbol,0,offset-1)), " shift ", shift, " offset ", offset); 
         //, " PairVals[index] ", PairVals[index], " ratioOpen ",ratioOpen, " ratioHigh ",ratioHigh, " ratioLow ",ratioLow, " ratioClose ",ratioClose);
         }
      }
      int bars = iBars(symbol, 0);
      if (bars == (offset + 1) && ShowPairStarts)
      {      
         //Print ("HERE", TimeToStr(iTime(symbol,Period(),shift + offset)), " LowBuffer[shift-1]", LowBuffer[shift-1] );   
         DrawText(PREFIX + "_BB" + PairVals[index], Time[shift], LowBuffer[shift-1] - 10, PairVals[index], UpColor);
      }
      
      if ((bars - (offset + 1)) < 1) continue;
      
      double tickSize = MarketInfo(symbol, MODE_TICKSIZE);
      open = open + (iOpen(symbol,Period(),offset)/tickSize - 100000) * WeightVals[index];
      high = high + (iHigh(symbol,Period(),offset)/tickSize - 100000) * WeightVals[index];
      low = low + (iLow(symbol,Period(),offset)/tickSize - 100000) * WeightVals[index];
      close = close + (iClose(symbol,Period(),offset)/tickSize - 100000) * WeightVals[index];
    
   } 
       
 
    
   LowBuffer[shift]=low;
   HighBuffer[shift]=high;   
   OpenBuffer[shift]=open;
   CloseBuffer[shift]=close;
   
   DeleteObjectsByPrefix(PREFIX + "_BB" + Time[shift]);
   DeleteObjectsByPrefix(PREFIX + "_SB" + Time[shift]);
   if(open<close)
   {		 
	   DrawLine(PREFIX + "_BB" +Time[shift],Time[shift],open,close,BodyWidth,UpColor); 
	   DrawLine(PREFIX + "_SB" +Time[shift],Time[shift],low ,high ,WickWidth,UpColor);
   }
   else
   {
	   DrawLine(PREFIX + "_BB" +Time[shift],Time[shift],open,close,BodyWidth,DnColor);
	   DrawLine(PREFIX + "_SB" +Time[shift],Time[shift] + (TimeSize / 4),high,low,WickWidth,DnColor);
   }	 
              
  
}
 

void DrawCandlesticks()
{
   DeleteObjectsByPrefix(PREFIX + "_BB");
   DeleteObjectsByPrefix(PREFIX + "_SB");
   int start = 0;
   
   for (int i = Bars; i >= MathMax(start, WindowFirstVisibleBar() - WindowBarsPerChart());i--)
   {     
      if (HighBuffer[i] == EMPTY_VALUE) continue;
      if(OpenBuffer[i]<CloseBuffer[i])
	   {		    
		   DrawLine(PREFIX + "_BB" +Time[i],Time[i],OpenBuffer[i],CloseBuffer[i],BodyWidth,UpColor); 
		   DrawLine(PREFIX + "_SB" +Time[i],Time[i],LowBuffer[i] ,HighBuffer[i] ,WickWidth,UpColor);
	   }
	   else
	   {
		   DrawLine(PREFIX + "_BB" +Time[i],Time[i],OpenBuffer[i],CloseBuffer[i],BodyWidth,DnColor);
		   DrawLine(PREFIX + "_SB" +Time[i],Time[i] + (TimeSize / 4),HighBuffer[i],LowBuffer[i],WickWidth,DnColor);
	   }	
   }
}     
  
void DrawLine(string name,datetime time, double pfrom, double pto, int width,color col)
{
   
   if(ObjectFind(name) == GetWindow())
   {         
      ObjectDelete(name);
   } 
   
   ObjectCreate(name, OBJ_TREND, GetWindow(), time, pfrom,time,pto);
   ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(name, OBJPROP_COLOR, col);
   ObjectSet(name,OBJPROP_WIDTH,width);
   ObjectSet(name,OBJPROP_RAY,0);

}  
void DrawText(string name,datetime time, double position,string value, color col)
{
   if(ObjectFind(name) == GetWindow())
   {               
      ObjectDelete(name);
   }
   ObjectCreate(name, OBJ_TEXT, GetWindow(), time, position);   
   ObjectSetText(name,value, 8,"Arial",col);
     
}  
  

void DrawFixedLabel(string objname, string s, int Corner, int DX, int DY, int FSize, string Font, color c, bool bg)
{
   ObjectCreate(objname, OBJ_LABEL, GetWindow(), 0, 0);
   
   ObjectSet(objname, OBJPROP_CORNER, Corner);
   ObjectSet(objname, OBJPROP_XDISTANCE, DX);
   ObjectSet(objname, OBJPROP_YDISTANCE, DY);
   ObjectSet(objname,OBJPROP_BACK, bg);      
   ObjectSetText(objname, s, FSize, Font, c);
   
} 

void DrawHA()
{ 
   int bars;
   while(OpenBuffer[bars]!=EMPTY_VALUE )
   {    
    bars++;
   }
  
  for (int i = bars-1; i >= 0; i--)
  {
   double maOpen = iMAOnArray(OpenBuffer,Bars,HAPeriod1,0,HAMethod1,i);
   double maClose = iMAOnArray(CloseBuffer,Bars,HAPeriod1,0,HAMethod1,i);
   double maLow = iMAOnArray(LowBuffer,Bars,HAPeriod1,0,HAMethod1,i);
   double maHigh = iMAOnArray(HighBuffer,Bars,HAPeriod1,0,HAMethod1,i);
   
   double haOpen=(HAOpen[i+1]+HAClose[i+1])/2;
   double haClose=(maOpen+maHigh+maLow+maClose)/4;
   double haHigh=MathMax(maHigh, MathMax(haOpen, haClose));
   double haLow=MathMin(maLow, MathMin(haOpen, haClose));
 
   HAOpen[i]=haOpen;
   HAClose[i]=haClose;

  } 
  
  for(i=0; i<bars; i++) 
  {
      HAOpenMA[i]=iMAOnArray(HAOpen,Bars,HAPeriod2,0,HAMethod2,i);
      HACloseMA[i]=iMAOnArray(HAClose,Bars,HAPeriod2,0,HAMethod2,i);
      if(HAOpenMA[i]<HACloseMA[i])
      {		    
       //Print ("i ", i , " HAOpenMA[i] ", HAOpenMA[i], " HACloseMA[i] ", HACloseMA[i]);
         DrawLine(PREFIX + "_HA_" +Time[i],Time[i],HAOpenMA[i],HACloseMA[i],BodyWidth,HAUpColor); 
      }
      else
      {
        DrawLine(PREFIX + "_HA_" +Time[i],Time[i],HAOpenMA[i],HACloseMA[i],BodyWidth,HADnColor); 
      }	   
  }    
} 
       
      

void DeleteObjectsByPrefix(string Prefix)
{
   int L = StringLen(Prefix);
   int i = 0; 
   while(i < ObjectsTotal())
   {
    string ObjName = ObjectName(i);
    if(StringSubstr(ObjName, 0, L) != Prefix) 
      { 
        i++; 
        continue;
      }
    ObjectDelete(ObjName);
   }
}

string GetUniqueName(string Prefix)
{
   ObjectId++;
   return (Prefix+" "+DoubleToStr(ObjectId, 0));
}
int GetWindow()
{
   return (WindowFind(PREFIX));
   //return (1);
}
      
   
void ShowStats()
{

   Spread = 0;
   for (int p = 0; p < ArraySize(PairVals); p++)                                
   {  
      string symbol = PairVals[p] + BrokerSuffix;          
      Spread = Spread + MarketInfo(symbol, MODE_SPREAD) * MathAbs(WeightVals[p]);
   }
   
   
   double sum;
   for (int i = 0; i < ATRPeriod; i++)                                
   {        
      sum = sum + HighBuffer[i] - LowBuffer[i];
   }
   
   DeleteObjectsByPrefix( PREFIX+"_STATSLABEL");
    
   string bg = "ggggg";
   int y=0,dy=StatsFontSize+2,x=10;
   
   
   for (p = 0; p < ArraySize(PairVals); p++)                                
   {        
      color c= StatsColor;
      if (WeightVals[p] < 0) c = StatsNegativeColor;
      y+=dy;DrawFixedLabel(GetUniqueName(PREFIX+"_STATSLABEL"), PairVals[p] + " = " + DoubleToStr(WeightVals[p],1) , StatsCorner, x, y, StatsFontSize, "Arial", c, false);
      DrawFixedLabel(GetUniqueName(PREFIX+"_STATSLABELBG"), bg, StatsCorner, x-5, y-5, 16, "Webdings", StatsBgColor, true);        
   }
   
       
   y+=dy;DrawFixedLabel(GetUniqueName(PREFIX+"_STATSLABEL"), "Spread="+DoubleToStr(Spread/10,1) , StatsCorner, x, y, StatsFontSize, "Arial", StatsColor, false);
   DrawFixedLabel(GetUniqueName(PREFIX+"_STATSLABELBG"), bg, StatsCorner, x-5, y-5, 16, "Webdings", StatsBgColor, true);
       
   y+=dy;DrawFixedLabel(GetUniqueName(PREFIX+"_STATSLABEL"), "ATR(" + ATRPeriod + ")="+DoubleToStr(sum/ATRPeriod/10,1) , StatsCorner, x, y, StatsFontSize, "Arial", StatsColor, false);
   DrawFixedLabel(GetUniqueName(PREFIX+"_STATSLABELBG"), bg, StatsCorner, x-5, y-5, 16, "Webdings", StatsBgColor, true);
       
       
   c= StatsColor;
   if (HAOpenMA[0] > HACloseMA[0]) c = StatsNegativeColor;
      
   y+=dy;DrawFixedLabel(GetUniqueName(PREFIX+"_STATSLABEL"), "HA="+DoubleToStr((HACloseMA[0] - HAOpenMA[0])/10,1) , StatsCorner, x, y, StatsFontSize, "Arial", c, false);
   DrawFixedLabel(GetUniqueName(PREFIX+"_STATSLABELBG"), bg, StatsCorner, x-5, y-5, 16, "Webdings", StatsBgColor, true);
       
}

 
       
void StringSplit(string InputString, string Separator, string & ResultArray[])
{
   //ArrayResize(ResultArray, 0);
   int lenSeparator = StringLen(Separator), NewArraySize;
   while (InputString != "") 
   {
      int p = StringFind(InputString, Separator);
      if (p == -1) {
         NewArraySize = ArraySize(ResultArray) + 1;
         
         ArrayResize(ResultArray, NewArraySize);      
         ResultArray[NewArraySize - 1] = InputString;
         //Print (" if ", InputString, " p ", p, " NewArraySize ", NewArraySize, " ResultArray[NewArraySize] ", ResultArray[NewArraySize]); 
         InputString = "";         
      } else {
         NewArraySize = ArraySize(ResultArray) + 1;
         ArrayResize(ResultArray, NewArraySize);     
         
         ResultArray[NewArraySize - 1] = StringSubstr(InputString, 0, p);
         //Print (" else ", InputString, " p ", p, " NewArraySize ", NewArraySize, " ResultArray[NewArraySize] ", ResultArray[NewArraySize]); 
         InputString = StringSubstr(InputString, p + lenSeparator);
         if (InputString == "")
         {
            ArrayResize(ResultArray, NewArraySize + 1);      
            ResultArray[NewArraySize] = "";
         }

      }     
   }
}

void StringSplitToDoubles(string InputString, string Separator, double & ResultArray[])
{
   int lenSeparator = StringLen(Separator), NewArraySize;
   while (InputString != "") 
   {
      int p = StringFind(InputString, Separator);
      if (p == -1) {
         NewArraySize = ArraySize(ResultArray) + 1;
         ArrayResize(ResultArray, NewArraySize);      
         ResultArray[NewArraySize - 1] = StrToDouble(InputString);
         InputString = "";
      } else {
         NewArraySize = ArraySize(ResultArray) + 1;
         ArrayResize(ResultArray, NewArraySize);      
         ResultArray[NewArraySize-1] = StrToDouble(StringSubstr(InputString, 0, p));
         InputString = StringSubstr(InputString, p + lenSeparator);
         if (InputString == "")
         {
            ArrayResize(ResultArray, NewArraySize + 1);      
            ResultArray[NewArraySize] = 0;
         }

      }     
   }
}