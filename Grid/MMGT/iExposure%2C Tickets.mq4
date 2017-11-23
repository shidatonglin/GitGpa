//+------------------------------------------------------------------+
//|                                           iExposure, Tickets.mq4 |
//|                      Copyright 2012, Deltabron - Paul Geirnaerdt |
//|                                          http://www.deltabron.nl |
//+------------------------------------------------------------------+
//
// Parts based on iExposure
//
#property copyright "Copyright 2012, Deltabron - Paul Geirnaerdt"
#property link      "http://www.deltabron.nl"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_minimum 0.0
#property indicator_maximum 0.1

#define version      "v1.0.8"

//+------------------------------------------------------------------+
//| Release Notes                                                    |
//+------------------------------------------------------------------+
// v1.0.2, 6/1/12
// * Changed file header
// * Improved display format of Shelley Basket Breakeven values
// v1.0.3, 6/21/12
// * Added user setting for Shelley BE Global Variable
// v1.0.4, 6/26/12
// * Added information on baskets
// v1.0.5, 6/27/12
// * Improved resetting of basket high- and low-water mark values
// v1.0.6, 6/28/12
// * Added timestamp to high- and low-water marks
// * Introduced GV's to save water marks
// * Default colors changed for better visibility
// v1.0.7, 7/6/2012
// * Introduced use of Magic Number
// v1.0.8, 7/23/2012
// * Fixed Shelley BE Global Variable

#define EPSILON      0.00000001

#define TICKETS_MAX  1024
#define SYMBOL       0
#define TICKET       1
#define TIME         2
#define TYPE         3
#define LOTS         4
#define PRICE        5
#define PROFIT       6
#define PIPS         7
#define PIPSTOBE     8
#define STOPLOSS     9
#define TAKEPROFIT   10
#define MESSAGE      11

#define COLUMNS      12

extern string  ste            = "----Stealth----";
extern bool    useGVStealth   = false;
extern string  stealthPrefix  = "Stealth_";
extern bool    useHiddenPips  = false;
extern int     hiddenPips     = 0;

extern string  gen            = "----General----";
extern string  nonPropFont    = "Lucida Console";
extern int     magicNumber    = 0;
string         magicNumberGV;

extern string  pip            = "----Pips----";
extern bool    showRealPips   = true;
extern int     breakEvenPips  = 0;
extern string  ShelleyBEGV    = "Shelley Stop Loss Pips";
extern bool    showShelleyBEPips = false;
extern bool    showShelleyBECash = false;
extern bool    showBasketInfo = true;
bool           basketClosed;
double         highWaterMarkPips;
double         lowWaterMarkPips;
double         highWaterMarkCash;
double         lowWaterMarkCash;
datetime       highWaterMarkTimestamp;
datetime       lowWaterMarkTimestamp;

extern string  col            = "----Colo(u)rs----";
extern color   ExtHeaderColor = CadetBlue;
extern color   ExtBodyColor   = SkyBlue;
extern color   ExtWinBGColor  = SeaGreen; // LightGreen;
extern color   ExtLossBGColor = FireBrick; // LightPink;
extern color   ExtWinColor    = SeaGreen;
extern color   ExtLossColor   = FireBrick;

string ExtName = "Exposure, Tickets";
string ExtTickets[TICKETS_MAX][COLUMNS];
double ExtTicketsValues[TICKETS_MAX][COLUMNS];
int    ExtLines = -1;
string ExtCols[COLUMNS] = {"Symbol", "Ticket", "Time", "Type", " Lots", " Price", "Profit", "Pips", "to BE", " Stoploss", 
                           "Takeprofit", " " };
int    ExtShifts[COLUMNS] = { 10, 70, 150, 280, 320, 365, 440, 510, 585, 635, 720, 810 };
int    ExtVertShift = 14;
int    ExtVertOffset = 8;
double ExtMapBuffer[];

string shortName;
string almostUniqueIndex;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init()
{
   shortName = ExtName + " - " + version;
   if ( magicNumber != 0 ) shortName = StringConcatenate( shortName, " (", magicNumber, ")" );
   IndicatorShortName ( shortName );
   SetIndexBuffer ( 0, ExtMapBuffer );
   SetIndexStyle ( 0, DRAW_NONE );
   IndicatorDigits ( 0 );
   SetIndexEmptyValue ( 0, 0.0 );
   
   string now = TimeCurrent();
   almostUniqueIndex = StringSubstr(now, StringLen(now) - 3) + magicNumber;

   magicNumberGV = "";
   if ( magicNumber != 0 ) magicNumberGV = "_" + magicNumber;
   
   basketClosed = true;
   for ( int i = 0; i < OrdersTotal(); i++ )
   {
      if ( !OrderSelect( i, SELECT_BY_POS ) ) continue;
      if ( magicNumber != 0 && OrderMagicNumber() != magicNumber ) continue;
      if ( OrderType() == OP_BUY || OrderType() == OP_SELL )
      {
         basketClosed = false;
         if ( GlobalVariableCheck( "BaludaHWMPips" + magicNumberGV ) )
            highWaterMarkPips = GlobalVariableGet( "BaludaHWMPips" + magicNumberGV );
         if ( GlobalVariableCheck( "BaludaLWMPips" + magicNumberGV ) )
            lowWaterMarkPips = GlobalVariableGet( "BaludaLWMPips" + magicNumberGV );
         if ( GlobalVariableCheck( "BaludaHWMCash" + magicNumberGV ) )
            highWaterMarkCash = GlobalVariableGet( "BaludaHWMCash" + magicNumberGV );
         if ( GlobalVariableCheck( "BaludaLWMCash" + magicNumberGV ) )
            lowWaterMarkCash = GlobalVariableGet( "BaludaLWMCash" + magicNumberGV );
         if ( GlobalVariableCheck( "BaludaHWMTimestamp" + magicNumberGV ) )
            highWaterMarkTimestamp = GlobalVariableGet( "BaludaHWMTimestamp" + magicNumberGV );
         if ( GlobalVariableCheck( "BaludaLWMTimestamp" + magicNumberGV ) )
            lowWaterMarkTimestamp = GlobalVariableGet( "BaludaLWMTimestamp" + magicNumberGV );
         break;
      }   
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
{
   int windex = WindowFind ( shortName );
   if ( windex > 0 ) ObjectsDeleteAll ( windex );
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start()
{
   string name;
   int    i, col, line, windex = WindowFind ( shortName );
   //----
   if ( windex < 0 ) return;

   //---- header line
   if ( ExtLines < 0 )
   {
      for ( col = 0; col < COLUMNS; col++ )
      {
         name = "Header_" + almostUniqueIndex + "_" + col;
         if ( ObjectCreate ( name, OBJ_LABEL, windex, 0, 0 ) )
         {
            ObjectSet ( name, OBJPROP_XDISTANCE, ExtShifts[col] );
            ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift + ExtVertOffset - 1 );
            ObjectSetText ( name, ExtCols[col], 9, nonPropFont, ExtHeaderColor );
         }
      }
      ExtLines = 0;
   }
   //----

   double footer_profit = 0.0;
   double footer_pips = 0.0;
   int total = Analyze();
   if ( !basketClosed && total == 0 )
   {
      basketClosed = true;
   }
   if ( basketClosed && total > 0 )
   {
      basketClosed = false;
      highWaterMarkPips = 0.0;
      lowWaterMarkPips = 0.0;
      highWaterMarkCash = 0.0;
      lowWaterMarkCash = 0.0;
      highWaterMarkTimestamp = 0;
      lowWaterMarkTimestamp = 0;
      GlobalVariableDel( "BaludaHWMPips" + magicNumberGV );
      GlobalVariableDel( "BaludaLWMPips" + magicNumberGV );
      GlobalVariableDel( "BaludaHWMCash" + magicNumberGV );
      GlobalVariableDel( "BaludaLWMCash" + magicNumberGV );
      GlobalVariableDel( "BaludaHWMTimestamp" + magicNumberGV );
      GlobalVariableDel( "BaludaLWMTimestamp" + magicNumberGV );
   }
   if ( total > 0 )
   {
      for ( line = 1; line <= total; line++ )
      {
         //---- add line
         name = "Line_" + almostUniqueIndex + "_" + line + "_0";
         if ( ObjectFind(name) < 0 )
         {
            int y_dist = ExtVertShift * ( line + 1 ) + ExtVertOffset;
            for ( col = 0; col < COLUMNS; col++ )
            {
               name = "Line_" + almostUniqueIndex + "_" + line + "_" + col;
               if ( ObjectCreate ( name, OBJ_LABEL, windex, 0, 0 ) )
               {
                  ObjectSet ( name, OBJPROP_XDISTANCE, ExtShifts[col] );
                  ObjectSet ( name, OBJPROP_YDISTANCE, y_dist );
               }
            }
         }

         //---- set line
         int    digits = MarketInfo ( ExtTickets[line - 1][SYMBOL], MODE_DIGITS );
         int    trailing_spaces = ( digits < 4 ) * 2;

         color line_color = ExtLossColor;
         color background_color = ExtLossBGColor;
         if ( ExtTicketsValues[line - 1][PROFIT] > 0 )
         {
            background_color = ExtWinBGColor;
         }
         if ( ( ExtTicketsValues[line - 1][TYPE] == OP_BUY && ExtTicketsValues[line - 1][STOPLOSS] > ExtTicketsValues[line - 1][PRICE] )
              ||
              ( ExtTicketsValues[line - 1][TYPE] == OP_SELL && ExtTicketsValues[line - 1][STOPLOSS] < ExtTicketsValues[line - 1][PRICE] )
            )
         {
            line_color = ExtWinColor;
         }
         footer_profit += ExtTicketsValues[line - 1][PROFIT];
         footer_pips += ExtTicketsValues[line - 1][PIPS];
         
         name = "Line_" + almostUniqueIndex + "_" + line + "_0";
         ObjectSetText ( name, ExtTickets[line - 1][SYMBOL], 9, nonPropFont, ExtBodyColor ); // line_color
         
         name = "Line_" + almostUniqueIndex + "_" + line + "_1";
         ObjectSetText ( name, RightAlign ( ExtTickets[line - 1][TICKET], 3 ), 9, nonPropFont, ExtBodyColor );
         
         name = "Line_" + almostUniqueIndex + "_" + line + "_2";
         ObjectSetText ( name, RightAlign ( ExtTickets[line - 1][TIME], 3 ), 9, nonPropFont, ExtBodyColor );
         
         name = "Line_" + almostUniqueIndex + "_" + line + "_3";
         ObjectSetText ( name, RightAlign ( ExtTickets[line - 1][TYPE], 3), 9, nonPropFont, ExtBodyColor );
         
         name = "Line_" + almostUniqueIndex + "_" + line + "_4";
         ObjectSetText ( name, RightAlign ( ExtTickets[line - 1][LOTS], 5 ), 9, nonPropFont, ExtBodyColor );
         
         name = "Line_" + almostUniqueIndex + "_" + line + "_5";
         ObjectSetText ( name, RightAlign ( ExtTickets[line - 1][PRICE], 9, trailing_spaces ), 9, nonPropFont, ExtBodyColor );
         
         name = "Line_" + almostUniqueIndex + "_" + line + "_6";
         ObjectSetText ( name, RightAlign ( ExtTickets[line - 1][PROFIT], 8 ), 9, nonPropFont, White );
         name = "Line_" + almostUniqueIndex + "_" + line + "_6_background";
         DrawCell ( windex, name, ExtShifts[6], ExtVertShift * ( line + 1 ) + ExtVertOffset - 7, 60, 13, background_color );
         
         name = "Line_" + almostUniqueIndex + "_" + line + "_7";
         ObjectSetText ( name, RightAlign ( ExtTickets[line - 1][PIPS], 8 ), 9, nonPropFont, White );
         name = "Line_" + almostUniqueIndex + "_" + line + "_7_background";
         DrawCell ( windex, name, ExtShifts[7], ExtVertShift * ( line + 1 ) + ExtVertOffset - 7, 60, 13, background_color );

         name = "Line_" + almostUniqueIndex + "_" + line + "_8";
         ObjectSetText ( name, RightAlign ( ExtTickets[line - 1][PIPSTOBE], 5 ), 9, nonPropFont, ExtBodyColor );

         name = "Line_" + almostUniqueIndex + "_" + line + "_9";
         ObjectSetText ( name, RightAlign ( ExtTickets[line - 1][STOPLOSS], 9, trailing_spaces ), 9, nonPropFont, line_color );

         //--- Show bullet for imminent stoploss
         name = "Line_" + almostUniqueIndex + "_" + line + "_9_background";
         double current_price = MarketInfo(ExtTickets[line - 1][SYMBOL], MODE_BID);
         if (ExtTicketsValues[line - 1][TYPE] == OP_SELL) current_price = MarketInfo(ExtTickets[line - 1][SYMBOL], MODE_ASK);
         if ( MathAbs((ExtTicketsValues[line - 1][STOPLOSS] - current_price) * ((digits > 3) * 99 + 1)) < 0.1 )
         {
            DrawBullet( windex, name, ExtShifts[8] + 65, ExtVertShift * ( line + 1 ) + ExtVertOffset - 2, ExtLossBGColor );
         }
         else
         {
            if (ObjectFind(name) > -1) ObjectDelete(name);
         }
         //---

         name = "Line_" + almostUniqueIndex + "_" + line + "_10";
         ObjectSetText ( name, RightAlign ( ExtTickets[line - 1][TAKEPROFIT], 9, trailing_spaces ), 9, nonPropFont, ExtBodyColor );

         //--- Show bullet for imminent takeprofit
         name = "Line_" + almostUniqueIndex + "_" + line + "_10_background";
         current_price = MarketInfo(ExtTickets[line - 1][SYMBOL], MODE_BID);
         if (ExtTicketsValues[line - 1][TYPE] == OP_SELL) current_price = MarketInfo(ExtTickets[line - 1][SYMBOL], MODE_ASK);
         if ( MathAbs((ExtTicketsValues[line - 1][TAKEPROFIT] - current_price) * ((digits > 3) * 99 + 1)) < 0.1 )
         {
            DrawBullet( windex, name, ExtShifts[9] + 65, ExtVertShift * ( line + 1 ) + ExtVertOffset - 2, ExtWinBGColor );
         }
         else
         {
            if (ObjectFind(name) > -1) ObjectDelete(name);
         }
         //---

         name = "Line_" + almostUniqueIndex + "_" + line + "_11";
         ObjectSetText ( name, RightAlign ( ExtTickets[line - 1][MESSAGE], 6 ), 9, nonPropFont, ExtBodyColor );
      }
   }
   
   if ( line == 0 ) line++;

   //---- footer line
   name = "Footer_" + almostUniqueIndex + "_0";
   int FooterVertOffset = 3;
   if ( ObjectFind(name) < 0 )
   {
      for ( col = 0; col < COLUMNS; col++ )
      {
         name = "Footer_" + almostUniqueIndex + "_" + col;
         if ( ObjectCreate ( name, OBJ_LABEL, windex, 0, 0 ) )
         {
            ObjectSet ( name, OBJPROP_XDISTANCE, ExtShifts[col] );
            ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 1 ) + ExtVertOffset + FooterVertOffset );
            ObjectSetText ( name, "" );
         }
      }
   }
   
   name = "Footer_" + almostUniqueIndex + "_0";
   ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 1 ) + ExtVertOffset + FooterVertOffset );
   if ( magicNumber == 0 )
   {
      ObjectSetText ( name, "" );
   }
   else
   {
      ObjectSetText ( name, "Magic number: " + magicNumber, 7, nonPropFont, ExtHeaderColor );
   }

   name = "Footer_" + almostUniqueIndex + "_1";
   ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 1 ) + ExtVertOffset + FooterVertOffset );
   ObjectSetText ( name, "" );

   name = "Footer_" + almostUniqueIndex + "_2";
   ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 1 ) + ExtVertOffset + FooterVertOffset );
   ObjectSetText ( name, "" );

   name = "Footer_" + almostUniqueIndex + "_3";
   ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 1 ) + ExtVertOffset + FooterVertOffset );
   ObjectSetText ( name, "" );

   name = "Footer_" + almostUniqueIndex + "_4";
   ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 1 ) + ExtVertOffset + FooterVertOffset );
   ObjectSetText ( name, "" );

   name = "Footer_" + almostUniqueIndex + "_5";
   ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 1 ) + ExtVertOffset + FooterVertOffset );
   ObjectSetText ( name, "   Total", 9, nonPropFont, ExtHeaderColor );
   
   background_color = ExtLossBGColor;
   if ( footer_profit > 0 ) background_color = ExtWinBGColor;
   name = "Footer_" + almostUniqueIndex + "_6";
   ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 1 ) + ExtVertOffset + FooterVertOffset );
   ObjectSetText ( name, RightAlign ( DoubleToStr ( footer_profit, 2 ), 8 ), 9, nonPropFont, White );
   name = "Footer_" + almostUniqueIndex + "_6_background";
   DrawCell(windex, name, ExtShifts[6], ExtVertShift*(line+1)+ExtVertOffset+FooterVertOffset-7, 60, 13, background_color);
   
   background_color = ExtLossBGColor;
   if ( footer_pips > 0 ) background_color = ExtWinBGColor;
   name = "Footer_" + almostUniqueIndex + "_7";
   ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 1 ) + ExtVertOffset + FooterVertOffset );
   ObjectSetText ( name, RightAlign ( DoubleToStr ( footer_pips, 1 ), 8 ), 9, nonPropFont, White );
   name = "Footer_" + almostUniqueIndex + "_7_background";
   DrawCell(windex, name, ExtShifts[7], ExtVertShift*(line+1)+ExtVertOffset+FooterVertOffset-7, 60, 13, background_color);

   name = "Footer_" + almostUniqueIndex + "_8";
   ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 1 ) + ExtVertOffset + FooterVertOffset );
   ObjectSetText ( name, "" );

   name = "Footer_" + almostUniqueIndex + "_9";
   ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 1 ) + ExtVertOffset + FooterVertOffset );
   if ( showShelleyBEPips && GlobalVariableCheck(ShelleyBEGV) )
   {
      ObjectSetText ( name, RightAlign ( DoubleToStr ( GlobalVariableGet(ShelleyBEGV), 1), 8), 9, nonPropFont, White );
      DrawCell(windex, name + "_background", ExtShifts[9], ExtVertShift*(line+1)+ExtVertOffset+FooterVertOffset-7, 60, 13, ExtWinBGColor);
   }
   else if ( showShelleyBECash && GlobalVariableCheck(ShelleyBEGV) )
   {
      ObjectSetText ( name, RightAlign ( DoubleToStr ( GlobalVariableGet(ShelleyBEGV), 2 ), 8), 9, nonPropFont, White );
      DrawCell(windex, name + "_background", ExtShifts[9], ExtVertShift*(line+1)+ExtVertOffset+FooterVertOffset-7, 60, 13, ExtWinBGColor);
   }
   else
   {
      ObjectSetText ( name, "" );
      DeleteCell(name + "_background");
   }   

   name = "Footer_" + almostUniqueIndex + "_10";
   ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 1 ) + ExtVertOffset + FooterVertOffset );
   ObjectSetText ( name, "" );

   name = "Footer_" + almostUniqueIndex + "_11";
   ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 1 ) + ExtVertOffset + FooterVertOffset );
   ObjectSetText ( name, "" );
   // ObjectSetText ( name, "line = " + line, 9, "Lucida Console", ExtHeaderColor );

   if ( showBasketInfo )
   {
      string objectText;

      // High-Water Mark
      name = "Basket_" + almostUniqueIndex + "_High_0";
      if ( ObjectFind(name) < 0 )
      {
         for ( col = 0; col < COLUMNS; col++ )
         {
            name = "Basket_" + almostUniqueIndex + "_High_" + col;
            if ( ObjectCreate ( name, OBJ_LABEL, windex, 0, 0 ) )
            {
               ObjectSet ( name, OBJPROP_XDISTANCE, ExtShifts[col] );
               ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 2 ) + ExtVertOffset + FooterVertOffset * 4 );
               ObjectSetText ( name, "" );
            }
         }
      }
   
      name = "Basket_" + almostUniqueIndex + "_High_0";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 2 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, "" );

      name = "Basket_" + almostUniqueIndex + "_High_1";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 2 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, "" );

      name = "Basket_" + almostUniqueIndex + "_High_2";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 2 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, "" );

      name = "Basket_" + almostUniqueIndex + "_High_3";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 2 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, "             High-Water Mark", 7, nonPropFont, ExtHeaderColor );

      name = "Basket_" + almostUniqueIndex + "_High_4";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 2 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, "" );

      name = "Basket_" + almostUniqueIndex + "_High_5";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 2 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, "" );
   
      if ( footer_profit > highWaterMarkCash )
      {
         highWaterMarkCash = footer_profit;
         highWaterMarkTimestamp = TimeCurrent();
         GlobalVariableSet( "BaludaHWMCash" + magicNumberGV, highWaterMarkCash );
         GlobalVariableSet( "BaludaHWMPips" + magicNumberGV, highWaterMarkPips );
         GlobalVariableSet( "BaludaHWMTimestamp" + magicNumberGV, highWaterMarkTimestamp );
      }
      background_color = ExtLossBGColor;
      if ( highWaterMarkCash > 0 ) background_color = ExtWinBGColor;
      name = "Basket_" + almostUniqueIndex + "_High_6";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 2 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, RightAlign ( DoubleToStr ( highWaterMarkCash, 2 ), 10 ), 7, nonPropFont, White );
      name = "Basket_" + almostUniqueIndex + "_High_6_background";
      DrawCell(windex, name, ExtShifts[6], ExtVertShift*(line+2)+ExtVertOffset+FooterVertOffset*4-9, 60, 13, background_color);
   
      highWaterMarkPips = MathMax( highWaterMarkPips, footer_pips );
      background_color = ExtLossBGColor;
      if ( highWaterMarkPips > 0 ) background_color = ExtWinBGColor;
      name = "Basket_" + almostUniqueIndex + "_High_7";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 2 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, RightAlign ( DoubleToStr ( highWaterMarkPips, 1 ), 10 ), 7, nonPropFont, White );
      name = "Basket_" + almostUniqueIndex + "_High_7_background";
      DrawCell(windex, name, ExtShifts[7], ExtVertShift*(line+2)+ExtVertOffset+FooterVertOffset*4-9, 60, 13, background_color);

      name = "Basket_" + almostUniqueIndex + "_High_8";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 2 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, "/ pair", 7, nonPropFont, ExtHeaderColor );

      background_color = ExtLossBGColor;
      if ( highWaterMarkCash > 0 ) background_color = ExtWinBGColor;
      name = "Basket_" + almostUniqueIndex + "_High_9";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 2 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, RightAlign ( DoubleToStr ( highWaterMarkCash / MathMax(total, 1), 2 ), 10 ), 7, nonPropFont, White );
      name = "Basket_" + almostUniqueIndex + "_High_9_background";
      DrawCell(windex, name, ExtShifts[9], ExtVertShift*(line+2)+ExtVertOffset+FooterVertOffset*4-9, 60, 13, background_color);
   
      background_color = ExtLossBGColor;
      if ( highWaterMarkPips > 0 ) background_color = ExtWinBGColor;
      name = "Basket_" + almostUniqueIndex + "_High_10";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 2 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, RightAlign ( DoubleToStr ( highWaterMarkPips / MathMax(total, 1), 2 ), 10 ), 7, nonPropFont, White );
      name = "Basket_" + almostUniqueIndex + "_High_10_background";
      DrawCell(windex, name, ExtShifts[10], ExtVertShift*(line+2)+ExtVertOffset+FooterVertOffset*4-9, 60, 13, background_color);
   
      objectText = "";
      if ( highWaterMarkTimestamp > 0 )
      {
         objectText = TimeToStr( highWaterMarkTimestamp, TIME_DATE|TIME_MINUTES );
      }
      name = "Basket_" + almostUniqueIndex + "_High_11";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 2 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, objectText, 7, nonPropFont, ExtHeaderColor );

      // Low-Water Mark
      name = "Basket_" + almostUniqueIndex + "_Low_0";
      if ( ObjectFind(name) < 0 )
      {
         for ( col = 0; col < COLUMNS; col++ )
         {
            name = "Basket_" + almostUniqueIndex + "_Low_" + col;
            if ( ObjectCreate ( name, OBJ_LABEL, windex, 0, 0 ) )
            {
               ObjectSet ( name, OBJPROP_XDISTANCE, ExtShifts[col] );
               ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 3 ) + ExtVertOffset + FooterVertOffset * 4 );
               ObjectSetText ( name, "" );
            }
         }
      }
   
      name = "Basket_" + almostUniqueIndex + "_Low_0";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 3 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, "" );

      name = "Basket_" + almostUniqueIndex + "_Low_1";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 3 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, "" );

      name = "Basket_" + almostUniqueIndex + "_Low_2";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 3 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, "" );

      name = "Basket_" + almostUniqueIndex + "_Low_3";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 3 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, "              Low-Water Mark", 7, nonPropFont, ExtHeaderColor );

      name = "Basket_" + almostUniqueIndex + "_Low_4";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 3 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, "" );

      name = "Basket_" + almostUniqueIndex + "_Low_5";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 3 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, "" );
   
      if ( footer_profit < lowWaterMarkCash )
      {
         lowWaterMarkCash = footer_profit;
         lowWaterMarkTimestamp = TimeCurrent();
         GlobalVariableSet( "BaludaLWMCash" + magicNumberGV, lowWaterMarkCash );
         GlobalVariableSet( "BaludaLWMPips" + magicNumberGV, lowWaterMarkPips );
         GlobalVariableSet( "BaludaLWMTimestamp" + magicNumberGV, lowWaterMarkTimestamp );
      }
      background_color = ExtLossBGColor;
      if ( lowWaterMarkCash > 0 ) background_color = ExtWinBGColor;
      name = "Basket_" + almostUniqueIndex + "_Low_6";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 3 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, RightAlign ( DoubleToStr ( lowWaterMarkCash, 2 ), 10 ), 7, nonPropFont, White );
      name = "Basket_" + almostUniqueIndex + "_Low_6_background";
      DrawCell(windex, name, ExtShifts[6], ExtVertShift*(line+3)+ExtVertOffset+FooterVertOffset*4-9, 60, 13, background_color);
   
      lowWaterMarkPips = MathMin( lowWaterMarkPips, footer_pips );
      background_color = ExtLossBGColor;
      if ( lowWaterMarkPips > 0 ) background_color = ExtWinBGColor;
      name = "Basket_" + almostUniqueIndex + "_Low_7";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 3 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, RightAlign ( DoubleToStr ( lowWaterMarkPips, 1 ), 10 ), 7, nonPropFont, White );
      name = "Basket_" + almostUniqueIndex + "_Low_7_background";
      DrawCell(windex, name, ExtShifts[7], ExtVertShift*(line+3)+ExtVertOffset+FooterVertOffset*4-9, 60, 13, background_color);

      name = "Basket_" + almostUniqueIndex + "_Low_8";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 3 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, "/ pair", 7, nonPropFont, ExtHeaderColor );

      background_color = ExtLossBGColor;
      if ( lowWaterMarkCash > 0 ) background_color = ExtWinBGColor;
      name = "Basket_" + almostUniqueIndex + "_Low_9";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 3 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, RightAlign ( DoubleToStr ( lowWaterMarkCash / MathMax(total, 1), 2 ), 10 ), 7, nonPropFont, White );
      name = "Basket_" + almostUniqueIndex + "_Low_9_background";
      DrawCell(windex, name, ExtShifts[9], ExtVertShift*(line+3)+ExtVertOffset+FooterVertOffset*4-9, 60, 13, background_color);
   
      background_color = ExtLossBGColor;
      if ( lowWaterMarkPips > 0 ) background_color = ExtWinBGColor;
      name = "Basket_" + almostUniqueIndex + "_Low_10";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 3 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, RightAlign ( DoubleToStr ( lowWaterMarkPips / MathMax(total, 1), 2 ), 10 ), 7, nonPropFont, White );
      name = "Basket_" + almostUniqueIndex + "_Low_10_background";
      DrawCell(windex, name, ExtShifts[10], ExtVertShift*(line+3)+ExtVertOffset+FooterVertOffset*4-9, 60, 13, background_color);
   
      objectText = "";
      if ( lowWaterMarkTimestamp > 0 )
      {
         objectText = TimeToStr( lowWaterMarkTimestamp, TIME_DATE|TIME_MINUTES );
      }
      name = "Basket_" + almostUniqueIndex + "_Low_11";
      ObjectSet ( name, OBJPROP_YDISTANCE, ExtVertShift * ( line + 3 ) + ExtVertOffset + FooterVertOffset * 4 );
      ObjectSetText ( name, objectText, 7, nonPropFont, ExtHeaderColor );
   }

   //---- remove lines
   while ( ObjectFind("Line_" + almostUniqueIndex + "_" + line + "_0") > -1 )
   {
      ObjectDelete ( "Line_" + almostUniqueIndex + "_" + line + "_0" );
      ObjectDelete ( "Line_" + almostUniqueIndex + "_" + line + "_1" );
      ObjectDelete ( "Line_" + almostUniqueIndex + "_" + line + "_2" );
      ObjectDelete ( "Line_" + almostUniqueIndex + "_" + line + "_3" );
      ObjectDelete ( "Line_" + almostUniqueIndex + "_" + line + "_4" );
      ObjectDelete ( "Line_" + almostUniqueIndex + "_" + line + "_5" );
      ObjectDelete ( "Line_" + almostUniqueIndex + "_" + line + "_6" );
      DeleteCell("Line_" + almostUniqueIndex + "_" + line + "_6_background");
      ObjectDelete ( "Line_" + almostUniqueIndex + "_" + line + "_7" );
      DeleteCell("Line_" + almostUniqueIndex + "_" + line + "_7_background");
      ObjectDelete ( "Line_" + almostUniqueIndex + "_" + line + "_8" );
      ObjectDelete ( "Line_" + almostUniqueIndex + "_" + line + "_9" );
      name = "Line_" + almostUniqueIndex + "_" + line + "_9_background";
      if (ObjectFind(name) > -1) ObjectDelete(name);
      ObjectDelete ( "Line_" + almostUniqueIndex + "_" + line + "_10" );
      name = "Line_" + almostUniqueIndex + "_" + line + "_10_background";
      if (ObjectFind(name) > -1) ObjectDelete(name);
      ObjectDelete ( "Line_" + almostUniqueIndex + "_" + line + "_11" );

      line++;
   }
//---- to avoid minimum==maximum
   ExtMapBuffer[Bars - 1] = -1;
//----
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Analyze()
{
   int    index = 0;
   int    i, type, total = OrdersTotal();
//----
   for ( i = 0; i < total; i++ )
   {
      if ( !OrderSelect ( i, SELECT_BY_POS ) ) continue;
      if ( magicNumber != 0 && OrderMagicNumber() != magicNumber ) continue;
      type = OrderType();
      if ( type != OP_BUY && type != OP_SELL ) continue;
      
      int digits = MarketInfo ( OrderSymbol(), MODE_DIGITS );
      double multiplier = ( ( digits % 2 ) * 9 + 1 ) * MarketInfo ( OrderSymbol(), MODE_POINT );
      double profit = OrderProfit() + OrderSwap() + OrderCommission();
      double stoploss = OrderStopLoss();
      double takeprofit = OrderTakeProfit();
      if ( useGVStealth )
      {
         stoploss = GlobalVariableGet(stealthPrefix + OrderTicket() + "_SL");
         takeprofit = GlobalVariableGet(stealthPrefix + OrderTicket() + "_TP");
      }
      else if ( useHiddenPips )
      {
         if ( type == OP_BUY )
         {
            if ( stoploss > EPSILON ) stoploss += hiddenPips * multiplier;
            if ( takeprofit > EPSILON ) takeprofit -= hiddenPips * multiplier;
         }
         else if ( type == OP_SELL )
         {
            if ( stoploss > EPSILON ) stoploss -= hiddenPips * multiplier;
            if ( takeprofit > EPSILON ) takeprofit += hiddenPips * multiplier;
         }
      }

      ExtTickets[index][SYMBOL]           = OrderSymbol();
      ExtTickets[index][TICKET]           = OrderTicket();
      ExtTickets[index][TIME]             = TimeToStr(OrderOpenTime(), TIME_DATE|TIME_MINUTES);
      ExtTicketsValues[index][TYPE]       = OrderType();
      if ( type == OP_BUY )
         ExtTickets[index][TYPE]          = "Buy";
      else
         ExtTickets[index][TYPE]          = "Sell";
      ExtTickets[index][LOTS]             = DoubleToStr(OrderLots(), 2);
      ExtTicketsValues[index][PRICE]      = OrderOpenPrice();
      ExtTickets[index][PRICE]            = DoubleToStr(OrderOpenPrice(), digits);
      ExtTicketsValues[index][PROFIT]     = profit;
      ExtTickets[index][PROFIT]           = DoubleToStr(profit, 2);
      ExtTicketsValues[index][PIPS]       = profit / OrderLots() / MarketInfo( OrderSymbol(), MODE_TICKVALUE );
      if (showRealPips)
         ExtTicketsValues[index][PIPS]   /= MathMod ( MarketInfo ( OrderSymbol(), MODE_DIGITS ), 2 ) * 9 + 1;
      ExtTickets[index][PIPS]             = DoubleToStr(ExtTicketsValues[index][PIPS], 1);
      ExtTicketsValues[index][PIPSTOBE]   = breakEvenPips - ExtTicketsValues[index][PIPS];
      if (ExtTicketsValues[index][PIPSTOBE] > EPSILON && breakEvenPips != 0)
         ExtTickets[index][PIPSTOBE]      = DoubleToStr(ExtTicketsValues[index][PIPSTOBE], 1);
      ExtTicketsValues[index][STOPLOSS]   = stoploss;
      ExtTickets[index][STOPLOSS]         = "";
      if (stoploss > EPSILON)
         ExtTickets[index][STOPLOSS]      = DoubleToStr(stoploss, digits);
      ExtTicketsValues[index][TAKEPROFIT] = takeprofit;
      ExtTickets[index][TAKEPROFIT]       = "";
      if (takeprofit > EPSILON)
         ExtTickets[index][TAKEPROFIT]    = DoubleToStr(takeprofit, digits);
      ExtTickets[index][MESSAGE]          = "";

      //----
      index += 1;
   }
//----
   return ( index );
}

//+------------------------------------------------------------------+
//| Right Align Text                                                 |
//+------------------------------------------------------------------+
string RightAlign ( string text, int length = 10, int trailing_spaces = 0 )
{
   string text_aligned = text;
   for ( int i = 0; i < length - StringLen ( text ) - trailing_spaces; i++ )
   {
      text_aligned = " " + text_aligned;
   }
   return ( text_aligned );
}

//=========================================================
// DrawCell.
//
// Author:        Alexandre A. B. Borela
// Description:   Draws a cell using the minimum character
//                as it can, so it's going to take less time
//                to draw the cell.
void DrawCell ( int nWindow, string nCellName, double nX, double nY, double nWidth, double nHeight, color nColor )
{
   double   iHeight, iWidth, iXSpace;
   int      iSquares, i;

   if ( nWidth > nHeight )
   {
      iSquares = MathCeil ( nWidth / nHeight ); // Number of squares used.
      iHeight  = MathRound ( ( nHeight * 100 ) / 77 ); // Real height size.
      iWidth   = MathRound ( ( nWidth * 100 ) / 77 ); // Real width size.
      iXSpace  = iWidth / iSquares - ( ( iHeight / ( 9 - ( nHeight / 100 ) ) ) * 2 );

      for ( i = 0; i < iSquares; i++ )
      {
         ObjectCreate   ( nCellName + i, OBJ_LABEL, nWindow, 0, 0 );
         ObjectSetText  ( nCellName + i, CharToStr ( 110 ), iHeight, "Wingdings", nColor );
         ObjectSet      ( nCellName + i, OBJPROP_XDISTANCE, nX + iXSpace * i );
         ObjectSet      ( nCellName + i, OBJPROP_YDISTANCE, nY );
         ObjectSet      ( nCellName + i, OBJPROP_BACK, true );
      }
   }
   else
   {
      iSquares = MathCeil ( nHeight / nWidth ); // Number of squares used.
      iHeight  = MathRound ( ( nHeight * 100 ) / 77 ); // Real height size.
      iWidth   = MathRound ( ( nWidth * 100 ) / 77 ); // Real width size.
      iXSpace  = iHeight / iSquares - ( ( iWidth / ( 9 - ( nWidth / 100 ) ) ) * 2 );

      for ( i = 0; i < iSquares; i++ )
      {
         ObjectCreate   ( nCellName + i, OBJ_LABEL, nWindow, 0, 0 );
         ObjectSetText  ( nCellName + i, CharToStr ( 110 ), iWidth, "Wingdings", nColor );
         ObjectSet      ( nCellName + i, OBJPROP_XDISTANCE, nX );
         ObjectSet      ( nCellName + i, OBJPROP_YDISTANCE, nY + iXSpace * i );
         ObjectSet      ( nCellName + i, OBJPROP_BACK, true );
      }
   }
}

void DeleteCell(string name)
{
   int square = 0;
   while ( ObjectFind( name + square ) > -1 )
   {
      ObjectDelete( name + square );
      square++;
   }   
}

void DrawBullet(int window, string cellName, int col, int row, color bulletColor )
{
   ObjectCreate   ( cellName, OBJ_LABEL, window, 0, 0 );
   ObjectSetText  ( cellName, CharToStr ( 108 ), 9, "Wingdings", bulletColor );
   ObjectSet      ( cellName, OBJPROP_XDISTANCE, col );
   ObjectSet      ( cellName, OBJPROP_YDISTANCE, row );
   ObjectSet      ( cellName, OBJPROP_BACK, true );
}


