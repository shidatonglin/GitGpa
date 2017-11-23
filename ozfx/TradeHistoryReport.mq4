//+------------------------------------------------------------------+
//|                                           TradeHistoryReport.mq4 |
//|                                                         renexxxx |
//|                                                                  |
//| version 0.1   initial release (RZ)                               |
//|------------------------------------------------------------------+
#property copyright "renexxxx"
#property link      "http://www.flashwebdesign.com.au/"
#property indicator_chart_window    // Indicator is drawn in the main window
#property indicator_buffers 1       // Number of buffers



//--- input parameters
extern int       MagicNumber          = -1;
extern string    ReportTitle          = "TradeReport";
extern datetime  StartDate            = D'2014.01.01 00:00';
extern datetime  EndDate              = D'2014.12.31 23:59';
extern int       RefreshMinutes       = 5;
extern string    screenFont           = "Consolas";

#define MAXSYMBOLS               30
#define COLUMNS                  10
#define NUMTRADES                 0
#define BUYLOTS                   1
#define NUMBUYS                   2
#define SELLLOTS                  3
#define NUMSELLS                  4
#define TOTALLOTS                 5
#define TOTALPROFIT               6
#define TOTALLOSS                 7
#define NETTPROFIT                8
#define NETTPIPS                  9

string trade_Symbol[MAXSYMBOLS];              // Array to store symbol names involved
double trade_Info[MAXSYMBOLS][COLUMNS];       // Array to store trade history information

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {

   // Set Indicator Name
   IndicatorShortName( WindowExpertName() );

   // Initialize Seed for Random Generator
   MathSrand( TimeLocal() );
   
   start();
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
   
   ObjectsDeleteAll(0);
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {

   //Print("Starting ...");
   static int timeToRun = -1;

   if (timeToRun < TimeCurrent() ) {
      //Print("Running ...");
      run();
      timeToRun = TimeCurrent() + RefreshMinutes * 60;
   }

   return(0);
}

void run() {

   // Initialize the arrays
   initArrays( trade_Symbol, trade_Info );
   
   //Print("Done initArrays ...");
   // Collect the information
   getInfo( trade_Symbol, trade_Info );
   
   //Print("Done getInfo ...");
   // Display it on the screen
   display( trade_Symbol, trade_Info );
}

void initArrays( string &symbols[MAXSYMBOLS], double &info[MAXSYMBOLS][COLUMNS] ) {

   for (int iSymbol = 0; iSymbol < MAXSYMBOLS; iSymbol++ ) {
      symbols[iSymbol] = "";
      for (int iColumn=0; iColumn < COLUMNS; iColumn++) info[iSymbol][iColumn] = 0.0;
   }
}

void getInfo( string &symbols[], double &info[][COLUMNS] ) {

   string mysymbol;
   int index;
   double profit;
   
   for (int iOrder=OrdersHistoryTotal()-1; iOrder >= 0; iOrder-- ) {
      //---- check selection result
      if ( !OrderSelect(iOrder, SELECT_BY_POS, MODE_HISTORY) ) {
         Print("Access to history failed with error (",GetLastError(),")");
         break;
      }
      if ( (MagicNumber == -1) || (OrderMagicNumber() == MagicNumber) ) {
         if ( (OrderType() == OP_BUY) || (OrderType() == OP_SELL) ) {
            if ( (OrderCloseTime() > StartDate) && (OrderCloseTime() < EndDate) ) {
         
               mysymbol = OrderSymbol();
               index = findInArray( symbols, mysymbol );

               // If this is a new symbol, add it to symbols
               if ( index == -1 ) {
                  index = addToArray( symbols, mysymbol );
               }
            
               info[index][NUMTRADES] += 1;
               info[index][TOTALLOTS] += OrderLots();
            
               profit = OrderProfit() + OrderSwap() + OrderCommission();
               info[index][NETTPROFIT] += profit;
               if ( profit > 0.0 ) {
                  info[index][TOTALPROFIT] += profit;
               }
               else {
                  info[index][TOTALLOSS] += profit;
               }
              
               if ( OrderType() == OP_BUY ) {
                  info[index][BUYLOTS] += OrderLots();
                  info[index][NUMBUYS] += 1;
                  info[index][NETTPIPS] += ( OrderClosePrice() - OrderOpenPrice() ) / pips2Points( mysymbol );
               }
               else if ( OrderType() == OP_SELL ) {
                  info[index][SELLLOTS] += OrderLots();
                  info[index][NUMSELLS] += 1;
                  info[index][NETTPIPS] += ( OrderOpenPrice() - OrderClosePrice() ) / pips2Points( mysymbol );
               }
            
            } // if

         } // if

      } // if
      
   } // for
            
}                        

//+------------------------------------------------------------------+
//| addToArray( string &array[], string elem)                        |
//|    -- add elem to array                                          |
//+------------------------------------------------------------------+
int addToArray( string &array[], string elem ) {

   for(int iSymbol = 0; iSymbol < MAXSYMBOLS; iSymbol++) {
      if ( array[iSymbol] == "" ) break;
   }
   if ( iSymbol < MAXSYMBOLS ) {
      array[iSymbol] = elem;
   }
   else {
      Print("No more memory to store symbol " + elem );
   }
   return(iSymbol);
}

//+------------------------------------------------------------------+
//| findInArray( string &array, string elem )                        |
//+------------------------------------------------------------------+
int findInArray( string &array[], string elem ) {

   int pos = -1;
   for (int i = 0; i < ArraySize( array ); i++ ) {
      if (elem == array[i]) {
         pos = i;
         break;
      }
   }
   return(pos);
}

//+------------------------------------------------------------------+
//| double pips2Points                                               |
//|     convert PIPs to POINTs for the given symbol                  |
//+------------------------------------------------------------------+
double pips2Points(string symbol) {
   static int pipMultiplierTab[] = { 1, 10, 1, 10, 1, 10, 100, 1000}; 
   double point = MarketInfo(symbol,MODE_POINT);
   int digits   = MarketInfo(symbol,MODE_DIGITS);
   
   point *= pipMultiplierTab[digits];
   return(point);
}

//+------------------------------------------------------------------+
//| double calcTotal                                                 |
//|     calculate the total of a given column                        |
//+------------------------------------------------------------------+
double calcTotal( double &info[MAXSYMBOLS][COLUMNS], int column ) {

   double total = 0.0;
   if ( column < COLUMNS ) {
      for ( int iSymbol = 0; iSymbol < MAXSYMBOLS; iSymbol++ ) {
         total += info[iSymbol][column];
      }
   }
   return(total);
}

//+------------------------------------------------------------------+
//| void sortIndices                                                 |
//|     create a mapping of indices, such that symbols[sorted[i]]    |
//|     is in alphabetic order                                       |
//+------------------------------------------------------------------+
void sortIndices( string &symbols[], int &sorted[] ) {

   int count = ArraySize( symbols );
   int tempID;

   ArrayResize( sorted, count );

   for (int id=0; id < count; id++) sorted[id] = id;
   for (int id1=0; id1 < count-1; id1++ ) {
      for ( int id2=id1+1; id2 < count; id2++ ) {
         if ( (symbols[sorted[id1]] != "") && (symbols[sorted[id2]] != "") && (symbols[sorted[id1]] > symbols[sorted[id2]]) ) {
            tempID = sorted[id1];
            sorted[id1] = sorted[id2];
            sorted[id2] = tempID;
         } // if
      } // for
   } // for
}
         
   
//+------------------------------------------------------------------+
//| display()                                                        |
//+------------------------------------------------------------------+
void display( string &symbols[], double &info[][COLUMNS] ) {

   int iTrade, iColumn, nDecimals, nLine;
   color textColor;
   string symbol;
   double total;
   int sorted[];
   
   int nWindow = WindowFind( WindowExpertName() );
   nWindow = 0;

   ObjectsDeleteAll(nWindow);
   DrawTime( nWindow, RandomString( 5, 10), 10, 0, White );
   DrawText( nWindow, RandomString( 5, 10), ReportTitle, 300, 2, White, 9 );
   DrawText( nWindow, RandomString( 5, 10), "From: " + TimeToStr( StartDate, TIME_DATE ) + " Until: " + TimeToStr( EndDate, TIME_DATE ), 440, 2, White, 9 );
   DrawCell( nWindow, RandomString( 5, 10), 2, 10, 680, 30, Maroon );
   DrawText( nWindow, RandomString( 5, 10), "Symbol", 10,30, White, 9 );
   DrawText( nWindow, RandomString( 5, 10), "Trades", 80,30, White, 9 );
   DrawText( nWindow, RandomString( 5, 10), "BUY", 140,25, White, 8 );
   DrawText( nWindow, RandomString( 5, 10), "Lots", 140,35, White, 8 );
   DrawText( nWindow, RandomString( 5, 10), "BUY", 200,25, White, 8 );
   DrawText( nWindow, RandomString( 5, 10), "Trades", 200,35, White, 8 );
   DrawText( nWindow, RandomString( 5, 10), "SELL", 260,25, White, 8 );
   DrawText( nWindow, RandomString( 5, 10), "Lots", 260,35, White, 8 );
   DrawText( nWindow, RandomString( 5, 10), "SELL ", 320,25, White, 8 );
   DrawText( nWindow, RandomString( 5, 10), "Trades", 320,35, White, 8 );
   DrawText( nWindow, RandomString( 5, 10), "TOTAL", 380,25, White, 8 );
   DrawText( nWindow, RandomString( 5, 10), "Lots", 380,35, White, 8 );
   DrawText( nWindow, RandomString( 5, 10), "Profit", 440,30, White, 9 );
   DrawText( nWindow, RandomString( 5, 10), "Loss", 500,30, White, 9 );
   DrawText( nWindow, RandomString( 5, 10), "NETT", 560,25, White, 8 );
   DrawText( nWindow, RandomString( 5, 10), "P/L", 560,35, White, 8 );
   DrawText( nWindow, RandomString( 5, 10), "NETT", 620,25, White, 8 );
   DrawText( nWindow, RandomString( 5, 10), "PIPs", 620,35, White, 8 );

   nLine = -1;
   sortIndices( symbols, sorted );
   for (iTrade = 0; iTrade < ArraySize( symbols ); iTrade++) {

      symbol = symbols[sorted[iTrade]];
      if ( symbol == "" ) continue;
      
      nLine++;
      //--- Draw SYMBOL text
      DrawText( nWindow, RandomString( 5, 10), symbol, 10, 60+nLine*16, DodgerBlue );
         
      //--- Draw Info Text
      for (iColumn=0; iColumn < COLUMNS; iColumn++) {

         // Set the number of decimals
         nDecimals = 2;
         if ( (iColumn == NUMTRADES) || (iColumn == NUMBUYS) || (iColumn == NUMSELLS) ) nDecimals = 0;
         
         // Set the color;
         textColor = Yellow;
         if ( (iColumn == NETTPROFIT) || (iColumn == NETTPIPS) ) {
            if ( info[sorted[iTrade]][iColumn] > 0.0 ) textColor = Lime; else textColor = Red;
         }
         
         DrawText( nWindow, RandomString( 5, 10), rightAlign( DoubleToStr( info[sorted[iTrade]][iColumn], nDecimals ), 12 ), 30+iColumn*60, 60+nLine*16, textColor );
         
      } // for

   } // for

   nLine++;
   DrawCell( nWindow, RandomString( 5, 10), 2, 60+nLine*16, 680, 2, Maroon );
   
   // Draw Totals
   nLine++;
   DrawText( nWindow, RandomString( 5, 10), "Totals", 10, 60+nLine*16, DodgerBlue );
   for (iColumn=0; iColumn < COLUMNS; iColumn++) {

      // Get the column total
      total = calcTotal( info, iColumn );
      
      // Set the number of decimals
      nDecimals = 2;
      if ( (iColumn == NUMTRADES) || (iColumn == NUMBUYS) || (iColumn == NUMSELLS) ) nDecimals = 0;
      
      // Set the color;
      textColor = Yellow;
      if ( (iColumn == NETTPROFIT) || (iColumn == NETTPIPS) ) {
         if ( total > 0.0 ) textColor = Lime; else textColor = Red;
      }
      
      DrawText( nWindow, RandomString( 5, 10), rightAlign( DoubleToStr( total, nDecimals ), 12 ), 30+iColumn*60, 60+nLine*16, textColor );
      
   } // for

}

void DrawCell(int nWindow, string nCellName, double nX, double nY, double nWidth, double nHeight, color nColor) {
   double   iHeight, iWidth, iXSpace;
   int      iSquares, i;
   
   if(nWidth > nHeight) {
      iSquares = MathCeil(nWidth/nHeight);      // Number of squares used.
      iHeight  = MathRound((nHeight*100)/77);   // Real height size.
      iWidth   = MathRound((nWidth*100)/77);    // Real width size.
      iXSpace  = iWidth/iSquares - ((iHeight/(9-(nHeight/100)))*2);

      for(i=0;i<iSquares;i++) {
         ObjectCreate   (nCellName+i, OBJ_LABEL,nWindow,0,0);
         ObjectSetText  (nCellName+i, CharToStr(110),iHeight, "Wingdings", nColor);
         ObjectSet      (nCellName+i, OBJPROP_XDISTANCE,nX + iXSpace*i);
         ObjectSet      (nCellName+i, OBJPROP_YDISTANCE,nY);    
         ObjectSet      (nCellName+i, OBJPROP_BACK, true);
      }        
   }
   else {
      iSquares = MathCeil(nHeight/nWidth);      // Number of squares used.
      iHeight  = MathRound((nHeight*100)/77);   // Real height size.
      iWidth   = MathRound((nWidth*100)/77);    // Real width size.
      iXSpace  = iHeight/iSquares - ((iWidth/(9-(nWidth/100)))*2);   
 
      for(i=0;i<iSquares;i++) {
         ObjectCreate   (nCellName+i, OBJ_LABEL,nWindow,0,0);
         ObjectSetText  (nCellName+i, CharToStr(110),iWidth, "Wingdings", nColor);
         ObjectSet      (nCellName+i, OBJPROP_XDISTANCE,nX);
         ObjectSet      (nCellName+i, OBJPROP_YDISTANCE,nY + iXSpace*i);    
         ObjectSet      (nCellName+i, OBJPROP_BACK, true);
      }       
   }
}

void DrawText( int nWindow, string nCellName, string nText, double nX, double nY, color nColor, int fontSize = 8 ) {

   ObjectCreate( nCellName, OBJ_LABEL, nWindow, 0, 0);
   ObjectSetText( nCellName, nText, fontSize, screenFont, nColor);
   ObjectSet( nCellName, OBJPROP_XDISTANCE, nX );
   ObjectSet( nCellName, OBJPROP_YDISTANCE, nY );
   ObjectSet( nCellName, OBJPROP_BACK, false);
   
}
   
void DrawTime ( int nWindow, string nCellName, double nX, double nY, color nColor ) {

   static int clock = 0;
   datetime now = TimeLocal();
   
   ObjectCreate( nCellName, OBJ_LABEL, nWindow, 0, 0);
   ObjectSetText( nCellName, CharToStr( 183 + clock ), 15, "WingDings", nColor );
   ObjectSet( nCellName, OBJPROP_XDISTANCE, nX );
   ObjectSet( nCellName, OBJPROP_YDISTANCE, nY );
   ObjectSet( nCellName, OBJPROP_BACK, false);
   
   DrawText( nWindow, nCellName+"_Time", TimeToStr( now, TIME_DATE|TIME_SECONDS ), nX+20, nY+2, nColor, 9 );

   // Move the "clock" character value
   clock++;
   if (clock == 10) clock = 0;

}

string rightAlign( string field, int width ) {

   string output = field;
   while(StringLen(output) < width) {
      output = " " + output;
   }
   return(output);
}
   
string RandomString(int minLength, int maxLength) {

   if ((minLength > maxLength) || (minLength <= 0)) return("");
   
   string rstring = "";
   int strLen = RandomNumber( minLength, maxLength );
   
   for (int i=0; i<strLen; i++) {
      rstring = rstring + CharToStr( RandomNumber( 97, 122 ) );
   }
   return(rstring);
}   

int RandomNumber(int low, int high) {

   if (low > high) return(-1);

   int number = low + MathFloor(((MathRand() * (high-low)) / 32767));
   return(number);
   
}