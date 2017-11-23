//+------------------------------------------------------------------+
//|                                               Sequencer_v1_2.mq4 |
//|                                          Copyright © 2008, Xaron |
//|                                             http://www.xaron.net |
//|                                                                  |
//| This EA was created by Xaron: xaron@gmx.eu                       |
//|                                                                  |
//| Special thanks goes to FXTradePro for this great idea of         |
//| a sequence of trades and Rama for his EA and effort.             |
//|                                                                  |
//| This EA may NOT be sold and is licensed under the GPL:           |
//|                                                                  |
//|        http://www.gnu.org/copyleft/gpl.html                      |
//|                                                                  |
//| That means, any changes and additions must be distributed        |
//| together with the source code!                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Xaron"
#property link      "http://www.xaron.net"

#include <stdlib.mqh>
#include <stderror.mqh> // Handles errors
#include <info.mq4>     // Handles information displayed on chart
#include <log.mq4>      // Creates and manages expert log file

extern string ExpertName       = "Sequencer v1.2";
extern int    TakeProfit       = 40;
extern int    StopLoss         = 10;
extern int    BreakEvenStop    = 30;
extern double AllowedSlippage  = 10.0;
extern color  LabelColor1      = OrangeRed;
extern color  LabelColor2      = OrangeRed;

extern string EntryOptions             = "-= Entry Options =-";
extern bool   FirstOrderLong           = true;
extern bool   StopTradingAfterSequence = true;
extern bool   UseTimeEntry             = false;
extern int    EntryHour                = 0;
extern int    EntryMinute              = 0;
extern bool   UsePriceEntry            = false;
extern double EntryPrice               = 0.0;
extern bool   UseBreakoutEntryOCO      = false;
extern double UpperBreakoutPrice       = 0.0;
extern double LowerBreakoutPrice       = 0.0;
extern bool   ReverseBreakout          = false;

extern string PositionSizeSettings = "-= Position Size Settings =-";
extern double PSize1  = 0.01;
extern double PSize2  = 0.01;
extern double PSize3  = 0.02;
extern double PSize4  = 0.03;
extern double PSize5  = 0.04;
extern double PSize6  = 0.06;
extern double PSize7  = 0.08;
extern double PSize8  = 0.11;
extern double PSize9  = 0.15;
extern double PSize10 = 0.20;
extern double PSize11 = 0.27;
extern double PSize12 = 0.36;
extern double PSize13 = 0.47;
extern double PSize14 = 0.62;
extern double PSize15 = 0.80;
extern double PSize16 = 1.02;
extern double PSize17 = 1.30;
extern double PSize18 = 1.65;
extern double PSize19 = 2.08;
extern double PSize20 = 2.63;
extern double PSize21 = 3.31;
extern double PSize22 = 4.16;
extern double PSize23 = 5.22;
extern double PSize24 = 6.55;

//Static variable for later retrieve 
//on EA reloading (e.g. after unnormal computer shut down).
static int _currentProgressionLevel = 1;
static int _lastOrderTicket = 0;
static bool _stopTrading = false;

string _versionNumber = "1.1";
int _magicNumber = 0;
bool _breakEven = false;
int _numberOfTries = 10;  // how often may the EA try to open a position/order
int _error;
string _text, _text1, _text2, _text3, _text4, _text5;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
  // Set the Magic numbers
  if( Symbol() == "AUDCADm" || Symbol() == "AUDCAD" ) { _magicNumber = 95741001; }
  if( Symbol() == "AUDJPYm" || Symbol() == "AUDJPY" ) { _magicNumber = 95741002; }
  if( Symbol() == "AUDNZDm" || Symbol() == "AUDNZD" ) { _magicNumber = 95741003; }
  if( Symbol() == "AUDUSDm" || Symbol() == "AUDUSD" ) { _magicNumber = 95741004; }
  if( Symbol() == "CHFJPYm" || Symbol() == "CHFJPY" ) { _magicNumber = 95741005; }
  if( Symbol() == "EURAUDm" || Symbol() == "EURAUD" ) { _magicNumber = 95741006; }
  if( Symbol() == "EURCADm" || Symbol() == "EURCAD" ) { _magicNumber = 95741007; }
  if( Symbol() == "EURCHFm" || Symbol() == "EURCHF" ) { _magicNumber = 95741008; }
  if( Symbol() == "EURGBPm" || Symbol() == "EURGBP" ) { _magicNumber = 95741009; }
  if( Symbol() == "EURJPYm" || Symbol() == "EURJPY" ) { _magicNumber = 95741010; }
  if( Symbol() == "EURUSDm" || Symbol() == "EURUSD" ) { _magicNumber = 95741011; }
  if( Symbol() == "GBPCHFm" || Symbol() == "GBPCHF" ) { _magicNumber = 95741012; }
  if( Symbol() == "GBPJPYm" || Symbol() == "GBPJPY" ) { _magicNumber = 95741013; }
  if( Symbol() == "GBPUSDm" || Symbol() == "GBPUSD" ) { _magicNumber = 95741014; }
  if( Symbol() == "NZDJPYm" || Symbol() == "NZDJPY" ) { _magicNumber = 95741015; }
  if( Symbol() == "NZDUSDm" || Symbol() == "NZDUSD" ) { _magicNumber = 95741016; }
  if( Symbol() == "USDCHFm" || Symbol() == "USDCHF" ) { _magicNumber = 95741017; }
  if( Symbol() == "USDJPYm" || Symbol() == "USDJPY" ) { _magicNumber = 95741018; }
  if( Symbol() == "USDCADm" || Symbol() == "USDCAD" ) { _magicNumber = 95741019; }
  if( Symbol() == "XAUUSDm" || Symbol() == "XAUUSD" ) { _magicNumber = 95741020; }
  if( Symbol() == "XAGUSDm" || Symbol() == "XAGUSD" ) { _magicNumber = 95741021; }
  if( _magicNumber == 0 ) { _magicNumber = 95741999; }

  // Creates a log.txt file to save events information from expert execution
  string logFile = DoubleToStr( _magicNumber, 0 );
  log_open( logFile );
  log( "Log file successfully opened at " + TimeToStr( TimeCurrent(), TIME_DATE ) );
  log( "Sequencer version: " + _versionNumber );

  // Creates Labels text for information display
  info_init(false);
  info_clear();

  if( IsTradeAllowed() || IsExpertEnabled() )
  {
    info( 0, ExpertName + " EA is allowed to trade.", LabelColor1, 8 );
    info( 1, "On first tick this message will desapear.", LabelColor2 );
  }
  else
    info( 0, ExpertName + " EA is not allowed to trade.", Red, 8 );

  // The following code is only for getting the last orders back
  // in case of that the EA was stopped by any reason (crash, etc.)
  // Check for any open trades from the last session to resume
  int openOrders = OrdersTotal();
  for( int i = 0; i < openOrders; i++ )
  {
    OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
    if( OrderMagicNumber() == _magicNumber )
    {
      // Open Order found!
      // Get the last used progression level from the comment of the order
      _currentProgressionLevel = StrToInteger( OrderComment() ) + 1;
      _lastOrderTicket = OrderTicket();
      _text = "Found an active order - ticket: " + DoubleToStr( _lastOrderTicket, 0 ) +
        " - progression: " + DoubleToStr( _currentProgressionLevel, 0 );
      log( _text );
      Print( _text );
      // Check if this was a break even order
      // If yes we have to go back one level in the sequence
      if( OrderOpenPrice() == OrderStopLoss() )
      {
        _breakEven = true;
        _currentProgressionLevel--;
        if( _currentProgressionLevel < 1 )
          _currentProgressionLevel = 1;
      }
      break;  // nothing more to do, we've found our order
    }
  }

  return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
  Comment( "" );
  info_clear();
  info_deinit();
  int deInitReason = UninitializeReason();
  switch( deInitReason )
  {
    case 0: _text  = "Normal deinit. No forced causes";                          break;
    case 1: _text  = "REASON_REMOVE: Expert removed from chart";                 break;
    case 2: _text  = "REASON_RECOMPILE: Expert recompiled";                      break;
    case 3: _text  = "REASON_CHARTCHANGE: Symbol or timeframe changed on chart"; break;
    case 4: _text  = "REASON_CHARTCLOSE: Chart closed or Test Stopped";          break;
    case 5: _text  = "REASON_PARAMETERS: Input parameters were changed by user"; break;
    case 6: _text  = "REASON_ACCOUNT: Other account activated";                  break;
    default: _text = "Deinit reason not defined";                                break;
  }
  log( "Reason for deinitialization: " + deInitReason + " " + _text );
 
  log( "Close log file, the expert has finished work at " +
    TimeToStr( TimeCurrent(), TIME_DATE ) + " ---------------------------------");
  log_close();
  return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----
  if( !IsExpertEnabled() || !IsTradeAllowed() )
    return(8);
  _text1 = "";
  _text2 = "";
  _text3 = "";
  _text4 = "";
  _text5 = "";
  if( _stopTrading )
  {
    _text1 = "Trading has been stopped.";
    _text2 = "";
    _text3 = "";
    _text4 = "";
    _text5 = "";
    // if the extern variable has been reset, start a new sequence!
    if( !StopTradingAfterSequence )
    {
      // Check if the last progression level is still running...
      int openOrders = OrdersTotal();
      for( int i = 0; i < openOrders; i++ )
      {
        OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
        if( OrderMagicNumber() == _magicNumber )
          break;  // Yes, there is still an open order, don't restart yet...
        else
        {
          _stopTrading = false;
          _currentProgressionLevel = 1;
          _lastOrderTicket = 0;
          break;
        }
      }
    } 
  }
  else
  {
    // Trading is allowed, show the info labels
    _text1 = "Magic: " + DoubleToStr( _magicNumber, 0 ) +
      " - Floating P/L: " + DoubleToStr( OrderProfit() + OrderSwap(), 2 );
    _text2 = "Progression Sequence Level: " + DoubleToStr( _currentProgressionLevel - 1, 0 );
    if( _breakEven )
      _text3 = "Current Lot Size: " + DoubleToStr( GetPositionSize( _currentProgressionLevel ), 2 );
    else
      _text3 = "Current Lot Size: " + DoubleToStr( GetPositionSize( _currentProgressionLevel - 1 ), 2 );
    _text4 = "Next Lot Size: " + DoubleToStr( GetPositionSize( _currentProgressionLevel ), 2 );
    _text5 = "";

    // Trail the stop for open positions if the BE level has been reached
    if( OrderSelect( _lastOrderTicket, SELECT_BY_TICKET ) )
    {
      // Correct order and SL still on its initial value?
      if( OrderMagicNumber() == _magicNumber && OrderOpenPrice() != OrderStopLoss() &&
          BreakEvenStop > 0.0 )
      {
        if( OrderType() == OP_BUY )
        {
          // Do we want to trail the stop to BE?
          if( ( Bid - OrderOpenPrice() ) > Point * BreakEvenStop )
          {
            _breakEven = true;
            _text = "Order " + OrderTicket() + " reached its break even level at " +
              DoubleToStr( OrderOpenPrice(), Digits ) + ".";
            Print( _text );
            log( _text );
            ChangeSL( OrderOpenPrice() );
            _currentProgressionLevel--;
            if( _currentProgressionLevel < 1 )
               _currentProgressionLevel = 1;
          }
        }
        else if( OrderType() == OP_SELL )
        {
          if( ( OrderOpenPrice() - Ask ) > Point * BreakEvenStop )
          {
            _breakEven = true;
            _text = "Order " + OrderTicket() + " reached its break even level at " +
              DoubleToStr( OrderOpenPrice(), Digits ) + ".";
            Print( _text );
            log( _text );
            ChangeSL( OrderOpenPrice() );
            _currentProgressionLevel--;
            if( _currentProgressionLevel < 1 )
               _currentProgressionLevel = 1;
          }
        }
      }
    }
    
    // ===================== TIME ENTRY =====================
    if( UseTimeEntry )
    {
      // Do we have an open position already?
      if( _lastOrderTicket == 0 )
      {
        // ... no, so wait for the time entry
        datetime periodStart = MathFloor( TimeCurrent() / 86400 ) * 86400 +
          EntryHour * 3600 + EntryMinute * 60;
        // just use a time entry window of one minute!
        datetime periodEnd = periodStart + 60;
        datetime now = TimeCurrent();
        // time entry reached, open a new position
        if( now >= periodStart && now < periodEnd )
        {
          _text = "Time Entry reached!";
          Print( _text );
          log( _text );
          // Get the correct position size
          double posSizeTE = GetPositionSize( _currentProgressionLevel );
          int typeOfOrderTE = OP_SELL;
          if( FirstOrderLong )
            typeOfOrderTE = OP_BUY;

          _lastOrderTicket = NewOrder( typeOfOrderTE, posSizeTE );
          if( _lastOrderTicket < 0 )
            return(9);

          _currentProgressionLevel++;
          if( GetPositionSize( _currentProgressionLevel ) == 0.0 )
          {
            if( StopTradingAfterSequence )
              _stopTrading = true;
            _currentProgressionLevel = 1;
            _lastOrderTicket = 0;
          }
        }
        else
          _text5 = "Waiting for time entry!";
      }
      else  // there is already a position open, check for stop and reverse
      {
        if( ManageOpenPositions() < 0 )
          return(9);
      }
    }
    // ===================== PRICE ENTRY =====================
    else if( UsePriceEntry )
    {
      // Do we have an open position already?
      int typeOfOrderPE = 0;
      if( _lastOrderTicket == 0 )
      {
        bool doEnterPE = false;
        if( FirstOrderLong )
        {
          if( Ask >= EntryPrice )
            doEnterPE = true;
          typeOfOrderPE = OP_BUY;
        }
        else
        {
          if( Bid <= EntryPrice )
            doEnterPE = true;
          typeOfOrderPE = OP_SELL;
        }
        if( doEnterPE )
        { 
          _text = "Price Entry reached!";
          Print( _text );
          log( _text );
          // Get the correct position size
          double posSizePE = GetPositionSize( _currentProgressionLevel );
          _lastOrderTicket = NewOrder( typeOfOrderPE, posSizePE );
          if( _lastOrderTicket < 0 )
            return(9);
          _currentProgressionLevel++;
          if( GetPositionSize( _currentProgressionLevel ) == 0.0 )
          {
            if( StopTradingAfterSequence )
              _stopTrading = true;
            _currentProgressionLevel = 1;
            _lastOrderTicket = 0;
          }
        }
        else
          _text5 = "Waiting for a price entry!";
      }
      else  // there is already a position open, check for stop and reverse
      {
        if( ManageOpenPositions() < 0 )
          return(9);
      }
    }
    // ===================== OCO ENTRY =====================
    else if( UseBreakoutEntryOCO )
    {
      // Do we have an open position already?
      int typeOfOrderOCO = 0;
      if( _lastOrderTicket == 0 )
      {
        bool doEnterOCO = false;
        if( Ask >= UpperBreakoutPrice )
        {
          doEnterOCO = true;
          if( ReverseBreakout )
            typeOfOrderOCO = OP_SELL;
          else
            typeOfOrderOCO = OP_BUY;
        }
        else if( Bid <= LowerBreakoutPrice )
        {
          doEnterOCO = true;
          if( ReverseBreakout )
            typeOfOrderOCO = OP_BUY;
          else
            typeOfOrderOCO = OP_SELL;
        }
        if( doEnterOCO )
        { 
          _text = "OCO breakout level reached!";
          Print( _text );
          log( _text );
          // Get the correct position size
          double posSizeOCO = GetPositionSize( _currentProgressionLevel );
          _lastOrderTicket = NewOrder( typeOfOrderOCO, posSizeOCO );
          if( _lastOrderTicket < 0 )
            return(9);
          _currentProgressionLevel++;
          if( GetPositionSize( _currentProgressionLevel ) == 0.0 )
          {
            if( StopTradingAfterSequence )
              _stopTrading = true;
            _currentProgressionLevel = 1;
            _lastOrderTicket = 0;
          }
        }
        else
          _text5 = "Waiting for an OCO entry!";
      }
      else  // there is already a position open, check for stop and reverse
      {
        if( ManageOpenPositions() < 0 )
          return(9);
      }
    }
    // ===================== MANUAL ENTRY =====================
    else // otherwise open directly a new position
    {
      // Do we have an open position already?
      if( _lastOrderTicket == 0 )
      {
        _text = "Manual price entry!";
        Print( _text );
        log( _text );
        // Get the correct position size
        double posSizeDE = GetPositionSize( _currentProgressionLevel );
        int typeOfOrderDE = OP_SELL;
        if( FirstOrderLong )
          typeOfOrderDE = OP_BUY;

        _lastOrderTicket = NewOrder( typeOfOrderDE, posSizeDE );
        if( _lastOrderTicket < 0 )
          return(9);

        _currentProgressionLevel++;
        if( GetPositionSize( _currentProgressionLevel ) == 0.0 )
        {
          if( StopTradingAfterSequence )
            _stopTrading = true;
          _currentProgressionLevel = 1;
          _lastOrderTicket = 0;
        }
      }
      else  // there is already a position open, check for stop and reverse
      {
        if( ManageOpenPositions() < 0 )
          return(9);
      }
    }
  }
   
  // Display information on top left corner.   
  info( 0, _text1, LabelColor1, 8 );
  info( 1, _text2, LabelColor2 );
  info( 2, _text3, LabelColor2 );
  info( 3, _text4, LabelColor2 );
  info( 4, _text5, LabelColor2 );  
//----
  return(0);
}
//+------------------------------------------------------------------+

// Function to manage the open positions
// It checks for closed positions and enters the next progression if necessary
int ManageOpenPositions()
{
  if( OrderSelect( _lastOrderTicket, SELECT_BY_TICKET ) )
  {
    if( OrderMagicNumber() == _magicNumber )
    {
      // Was the order closed?
      if( OrderCloseTime() > 0 )
      {
        if( OrderType() == OP_BUY )
        {
          // Was the order closed in profit?
          if( OrderClosePrice() >= OrderTakeProfit() )
          {
            _text = "Order " + OrderTicket() + " closed with profit at " +
              DoubleToStr( OrderClosePrice(), Digits ) + ".";
            Print( _text );
            log( _text );
            if( StopTradingAfterSequence )
              _stopTrading = true;
            _currentProgressionLevel = 1;
            _lastOrderTicket = 0;
          }
          else if( OrderClosePrice() <= OrderStopLoss() )
          {
            _text = "Order " + OrderTicket() + " hit its stop loss at " +
              DoubleToStr( OrderClosePrice(), Digits ) + ".";
            Print( _text );
            log( _text );
            EnterNextProgression();
            if( _lastOrderTicket < 0 )
              return(9);
          }
        }
        else if( OrderType() == OP_SELL )
        {
          // Was the order closed in profit?
          if( OrderClosePrice() <= OrderTakeProfit() )
          {
            _text = "Order " + OrderTicket() + " closed with profit at " +
              DoubleToStr( OrderClosePrice(), Digits ) + ".";
            Print( _text );
            log( _text );
            if( StopTradingAfterSequence )
              _stopTrading = true;
            _currentProgressionLevel = 1;
            _lastOrderTicket = 0;
          }
          else if( OrderClosePrice() >= OrderStopLoss() )
          {
            _text = "Order " + OrderTicket() + " hit its stop loss at " +
              DoubleToStr( OrderClosePrice(), Digits ) + ".";
            Print( _text );
            log( _text );
            EnterNextProgression();
            if( _lastOrderTicket < 0 )
              return(9);
          }
        }
      }
    }
  }
}

// Enters the next progression level if there is one
void EnterNextProgression()
{
  int lastOrderType = OrderType();
  // Get the correct position size
  double posSize = GetPositionSize( _currentProgressionLevel );
  int typeOfOrder = OP_SELL;
  if( lastOrderType == OP_SELL )
    typeOfOrder = OP_BUY;

  _lastOrderTicket = NewOrder( typeOfOrder, posSize );
  _currentProgressionLevel++;
  _breakEven = false;
  if( GetPositionSize( _currentProgressionLevel ) == 0.0 )
  {
    if( StopTradingAfterSequence )
      _stopTrading = true;
    _currentProgressionLevel = 1;
    _lastOrderTicket = 0;
  }
}

// Opens a new order with several tries if the first attempt doesn't work
// Returns the new order ticket
int NewOrder( int typeOfOrder, double positionSize )
{
//----
  double sl = 0.0;
  double tp = 0.0;
  double price = 0.0;
  color arrowColor = Green;
  for( int i = 1 ; i <= _numberOfTries; i++ )
  {
    if( typeOfOrder == OP_BUY )
    {
      price = NormalizeDouble( Ask, Digits );
      sl = price - StopLoss * MarketInfo( Symbol(), MODE_POINT );
      tp = price + TakeProfit * MarketInfo( Symbol(), MODE_POINT );
    }
    else
    {
      price = NormalizeDouble( Bid, Digits );
      sl = price + StopLoss * MarketInfo( Symbol(), MODE_POINT );
      tp = price - TakeProfit * MarketInfo( Symbol(), MODE_POINT );
      arrowColor = Red;
    }
    int ticket = OrderSend( Symbol(), typeOfOrder, positionSize, price,
      AllowedSlippage, sl, tp, DoubleToStr( _currentProgressionLevel, 0 ), _magicNumber, 0, arrowColor );

    if( ticket < 1 )
    {
      _error = GetLastError(); 
      _text = "Error: " + _error + " " + ErrorDescription( _error ) +
        " SL: " + sl + " TP: " + tp + " Retry: " + i + "/" + _numberOfTries;
      Print( _text );
      log( _text );
      Sleep( 10000 );
    }
    else
    {
      _text = "Ticket opened by EA :" + ticket + " " + _text;
      Print( _text );
      log( _text );
      break;
    }
  }
         
  if( ticket < 1 )
  {
    _error = GetLastError();
    _text = "Could not open order: " + DoubleToStr( positionSize, 2 ) + " lots of " +
      Symbol() + " at price " + DoubleToStr( price, Digits );

    Print( _text );
    log( _text );

    _text = "Error: " + _error + " - " + ErrorDescription( _error );
    Print( _text );
    log( _text );
  }
  return( ticket );
}

// Changes the SL
bool ChangeSL( double SL )
{
  for( int h = 0; h < OrdersTotal(); h++ )
  {
    OrderSelect( h, SELECT_BY_POS, MODE_TRADES );

    if( OrderSymbol() == Symbol() && OrderMagicNumber() == _magicNumber )
    {
      for( int i = 1; i <= _numberOfTries; i++ )
      {
        bool ticketModify = OrderModify( OrderTicket(), 0, SL, OrderTakeProfit(), 0, Pink );

        if( !ticketModify )
        {
          _error = GetLastError(); 
          _text = "Error: " + _error + " - " + ErrorDescription( _error ) +
            " - modified SL order: " + DoubleToStr( OrderTicket(), 0 ) +
            " - SL: " + DoubleToStr( SL, Digits ) +
            ". Retry: " + i + "/" + _numberOfTries;
          Print( _text );
          log( _text );
          Sleep( 5000 );
          RefreshRates();
        }
        else
          break;
      } //end for i

      if( !ticketModify )
      {
        _text = "It was not possible to change the SL for order: " + OrderTicket() +
          " SL: " + DoubleToStr( SL, Digits );

        Print( _text );
        log( _text );
        return( false );
      }
    }  //end if Symbol & Magic. 
  } //end for h
  return( true );
} //End ChangeSL() ---------------------------------

// Returns the position size for the parameter progression level
double GetPositionSize( int ProgressionLevel )
{
  double pSize = 0.0;
  switch( ProgressionLevel )
  {
    case 1:
      pSize = PSize1;
      break;
    case 2:
      pSize = PSize2;
      break;
    case 3:
      pSize = PSize3;
      break;
    case 4:
      pSize = PSize4;
      break;
    case 5:
      pSize = PSize5;
      break;
    case 6:
      pSize = PSize6;
      break;
    case 7:
      pSize = PSize7;
      break;
    case 8:
      pSize = PSize8;
      break;
    case 9:
      pSize = PSize9;
      break;
    case 10:
      pSize = PSize10;
      break;
    case 11:
      pSize = PSize11;
      break;
    case 12:
      pSize = PSize12;
      break;
    case 13:
      pSize = PSize13;
      break;
    case 14:
      pSize = PSize14;
      break;
    case 15:
      pSize = PSize15;
      break;
    case 16:
      pSize = PSize16;
      break;
    case 17:
      pSize = PSize17;
      break;
    case 18:
      pSize = PSize18;
      break;
    case 19:
      pSize = PSize19;
      break;
    case 20:
      pSize = PSize20;
      break;
    case 21:
      pSize = PSize21;
      break;
    case 22:
      pSize = PSize22;
      break;
    case 23:
      pSize = PSize23;
      break;
    case 24:
      pSize = PSize24;
      break;
    default:
      pSize = 0.0;
      break;
  }
  return ( pSize );
}
