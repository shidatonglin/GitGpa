//+---------------------------------------------------------------------------------------------+
//|                                                                    Rsi_R2_Opt_Indicator.mq4 |
//| Copyright © 2007 , http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/ |
//|                    http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/ |
//+---------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2007 , http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/"
#property link      "http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/"

//+------------------------------------------------------------------------------------------------------------+
//| http://www.tradingmarkets.com/.site/stocks/commentary/editorial/The-Improved-R2-Strategy.cfm               |
//| introduced to http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/                     |
//| by Peter , blackprinzze , blackprinzze@yahoo.com , for a complimentary build in .mq4                       |
//| built by transport_david                                                                                   |
//| This version should be able to match the AnyMA_RSI_R2_EA_Opt.mq4 expert ( Peter , Bluto , Robert , Loren ) |                        |
//+------------------------------------------------------------------------------------------------------------+

#property indicator_chart_window

#property indicator_buffers 5

#property indicator_color1 DeepSkyBlue
#property indicator_color2 Coral
#property indicator_color3 White
#property indicator_color4 SlateGray
#property indicator_color5 Pink

extern bool   Play_Alert          =    true;

extern string s0 = "---------------";
extern string t0 = "Hull Moving Average Filter";
extern bool   Use_Hull_Filter     =    true;
extern int    Hull_Periods        =     200;
extern int    Hull_Applied_Price  =       0;
extern int    Hull_Separation_Pips=       1;

extern string s1 = "---------------";
extern string t1 = "Trend Moving Average";
extern int    Ma_Periods          =     200;
extern int    Ma_Type             =       0;
extern int    Ma_Applied_Price    =       0;

extern string s2 = "---------------";
extern int    RsiPeriods          =       2;
extern int    Rsi_Applied_Price   =       0;

extern string s3 = "---------------";
extern int    BuyIfDay1RsiBelow   =      65; // 1st day of tracking must be < this setting
extern int    BuyIfDay3RsiBelow   =      65; // 3rd day must be < this setting

extern string s4 = "---------------";
extern int    SellIfDay1RsiAbove  =      35; // 1st day of tracking must be > this setting
extern int    SellIfDay3RsiAbove  =      35; // 3rd day must be > this setting

extern string s5 = "---------------";
extern int    CloseBuyIfRsiAbove  =      75;
extern int    CloseSellIfRsiBelow =      25;

extern string s6 = "---------------";
extern int    ShowBars            =   10000;

double Trend_Ma[];
double Sell_Arrow[];
double Buy_Arrow[];
double Close_Trade_Marker[];
double Calc[];
double Hull_MA[];

double prevtime;
double goober;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   
   IndicatorBuffers(6);
   
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(0,Trend_Ma);
   SetIndexLabel(0,"Trend_Ma ( "+Ma_Periods+" )");
   
   SetIndexEmptyValue(1,0.0);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,Sell_Arrow);
   SetIndexLabel(1,"R2_Sell_Arrow");
   
   SetIndexEmptyValue(2,0.0);
   SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexArrow(2,233);
   SetIndexBuffer(2,Buy_Arrow);
   SetIndexLabel(2,"R2_Buy_Arrow");
   
   SetIndexEmptyValue(3,0.0);
   SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID,0);
   SetIndexArrow(3,172);
   SetIndexBuffer(3,Close_Trade_Marker);
   SetIndexLabel(3,"R2_Close_Trade_Marker");
   
   SetIndexEmptyValue(4,0.0);
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,1);
   SetIndexBuffer(4,Hull_MA);
   SetIndexLabel(4,"Hull_Ma_Filter ( "+Hull_Periods+" )");
   
   SetIndexEmptyValue(5,0.0);
   SetIndexBuffer(5,Calc);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----
   int shift = ShowBars;
   
   if (ShowBars >= Bars) ShowBars = Bars-1;
   
   for ( shift = ShowBars; shift >= 0; shift-- )
    {
      
      double Exp = 2;
      
      double firstwma = iMA(Symbol(),0,MathFloor(Hull_Periods/2),0,MODE_LWMA,Hull_Applied_Price,shift);
      
      double secondwma = iMA(Symbol(),0,Hull_Periods,0,MODE_LWMA,Hull_Applied_Price,shift);
      
      Calc[shift] = (Exp*firstwma)-secondwma;
      
    }
   if (Use_Hull_Filter)
    {
     for ( shift = ShowBars; shift >= 0; shift-- )
      {
       
       double Hulldifference = (iMAOnArray(Calc,0,MathFloor(MathSqrt(Hull_Periods)),0,MODE_LWMA,shift+1) - iMAOnArray(Calc,0,MathFloor(MathSqrt(Hull_Periods)),0,MODE_LWMA,shift+2));
       
       Hull_MA[shift] = iMAOnArray(Calc,0,MathFloor(MathSqrt(Hull_Periods)),0,MODE_LWMA,shift);
       
       Trend_Ma[shift] = iMA( Symbol(), 0, Ma_Periods, 0, Ma_Type, Ma_Applied_Price, shift);
       
       if (prevtime != Time[0]) { RefreshRates(); prevtime=Time[0]; } 
       
       double Day1 = iRSI(Symbol(),0,RsiPeriods,Rsi_Applied_Price,shift+3);
       double Day2 = iRSI(Symbol(),0,RsiPeriods,Rsi_Applied_Price,shift+2);
       double Day3 = iRSI(Symbol(),0,RsiPeriods,Rsi_Applied_Price,shift+1);
       double Today = iRSI(Symbol(),0,RsiPeriods,Rsi_Applied_Price,shift);
       
       //- Sell Arrows ---
       
       if ( (iClose(Symbol(),0,shift+1) < Trend_Ma[shift+1])
         && (Day1 > SellIfDay1RsiAbove)
         && (Day2 > Day1)
         && (Day3 > Day2)
         && (Day3 > SellIfDay3RsiAbove)
         && (Hulldifference <= -Hull_Separation_Pips*Point) )
          
          Sell_Arrow[shift] = iHigh(Symbol(),0,shift) + (20*Point);//High arrow Sell
       
       //- Buy Arrows ---
       
       if ( (iClose(Symbol(),0,shift+1) > Trend_Ma[shift+1])
         && (Day1 < BuyIfDay1RsiBelow)
         && (Day2 < Day1)
         && (Day3 < Day2)
         && (Day3 < BuyIfDay3RsiBelow)
         && (Hulldifference >= Hull_Separation_Pips*Point) )
          
          Buy_Arrow[shift] = iLow(Symbol(),0,shift) - (20*Point);//Low arrow Buy 
       
       //- Close Trades Marker ---
       
       if (Today < CloseSellIfRsiBelow)
         
          Close_Trade_Marker[shift] = iLow(Symbol(),0,shift) - (50*Point);
       
       if (Today > CloseBuyIfRsiAbove)
         
          Close_Trade_Marker[shift] = iHigh(Symbol(),0,shift) + (50*Point);
      
      }
    }
   
   if (!Use_Hull_Filter)
    {
     for ( shift = ShowBars; shift >= 0; shift-- )
      {
       
       Hull_MA[shift] = 0;
       
       Trend_Ma[shift] = iMA( Symbol(), 0, Ma_Periods, 0, Ma_Type, Ma_Applied_Price, shift);
       
       if (prevtime != Time[0]) { RefreshRates(); prevtime=Time[0]; } 
       
       Day1 = iRSI(Symbol(),0,RsiPeriods,Rsi_Applied_Price,shift+3);
       Day2 = iRSI(Symbol(),0,RsiPeriods,Rsi_Applied_Price,shift+2);
       Day3 = iRSI(Symbol(),0,RsiPeriods,Rsi_Applied_Price,shift+1);
       Today = iRSI(Symbol(),0,RsiPeriods,Rsi_Applied_Price,shift);
       
       //- Sell Arrows ---
       
       if ( (iClose(Symbol(),0,shift+1) < Trend_Ma[shift+1])
         && (Day1 > SellIfDay1RsiAbove)
         && (Day2 > Day1)
         && (Day3 > Day2)
         && (Day3 > SellIfDay3RsiAbove) )
          
          Sell_Arrow[shift] = iHigh(Symbol(),0,shift) + (20*Point); // High arrow Sell
       
       //- Buy Arrows ---
       
       if ( (iClose(Symbol(),0,shift+1) > Trend_Ma[shift+1])
         && (Day1 < BuyIfDay1RsiBelow)
         && (Day2 < Day1)
         && (Day3 < Day2)
         && (Day3 < BuyIfDay3RsiBelow) )
          
          Buy_Arrow[shift] = iLow(Symbol(),0,shift) - (20*Point); // Low arrow Buy 
       
       //- Close Trades Marker ---
       
       if (Today < CloseSellIfRsiBelow)
         
          Close_Trade_Marker[shift] = iLow(Symbol(),0,shift) - (50*Point);
       
       if (Today > CloseBuyIfRsiAbove)
         
          Close_Trade_Marker[shift] = iHigh(Symbol(),0,shift) + (50*Point);
      
      }
    }
   
   if (Play_Alert)
    {
     int SignalBar = 0;
     if ( (Close_Trade_Marker[0] != 0) && (goober < Time[0]) )
      {
        //Alert("Close_Trade_Marker , "+Symbol()+" , M_"+Period()+" , Bid = ",Bid," , Hour = ",Hour()," , Minute = ",Minute()," .");
        PlaySound("email.wav");
        goober = Time[0];
      }
     if ( (Sell_Arrow[0] != 0) && (goober < Time[0]) )
      {
        //Alert("R2_Sell Arrow , "+Symbol()+" , M_"+Period()+" , Bid = ",Bid," , Hour = ",Hour()," , Minute = ",Minute()," .");
        PlaySound("email.wav");
        goober = Time[0];
      }
     if ( (Buy_Arrow[0] != 0) && (goober < Time[0]) )
      {
        //Alert("R2_Buy Arrow , "+Symbol()+" , M_"+Period()+" , Ask = ",Ask," , Hour = ",Hour()," , Minute = ",Minute()," .");
        PlaySound("email.wav");
        goober = Time[0];
      }
    }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+