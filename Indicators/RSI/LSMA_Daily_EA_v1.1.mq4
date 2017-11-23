//+------------------------------------------------------------------+
//|                                                                  |
//|                                          LSMA_Daily_wLog         |
//|                                                                  |
//| Written by Robert Hill aka MrPip for StrategyBuilder FX group    |
//|                                                                  |
//| 7/15/2007  Updated code and added log file                       |
//+------------------------------------------------------------------+


#property copyright "Robert Hill"
#property link      "None"
#include <stdlib.mqh>

extern string  Expert_Name    = "LSMA_Daily";
extern int     MagicNumberBase = 200000;
extern string  UserComment = "LSMA_EA";
extern string  in="---Indicator settings---";
extern int     LSMAShortPeriod=7;
extern int     LSMALongPeriod=16;
extern int     MonthStart = 9;
extern int     MonthEnd = 11;
extern bool    UseFreshCross = true;
extern double  MartMult = 2.0;


//+---------------------------------------------------+
//|Money Management                                   |
//+---------------------------------------------------+
extern string  mm = "---Money Management---";
extern double  Lots=1.0;
extern double  MaxLots = 100;
extern bool    UseMoneyManagement = true; // Change to false to shutdown money management controls.
extern bool    BrokerIsIBFX = false;
extern string  m1="Set mini and micro to false for standard account";
extern bool    AccountIsMini = false;
extern bool    AccountIsMicro = false;
extern string  fm="UseFreeMargin = false to use Account Balance";
extern bool    UseFreeMargin = false;
extern double  TradeSizePercent = 10;  // Change to whatever percent of equity you wish to risk.
extern bool    BrokerPermitsFractionalLots = true;

//+---------------------------------------------------+
//|Profit controls                                    |
//+---------------------------------------------------+
extern string  st6 = "--Profit Controls--";
extern double  StopLoss=0;
extern double  TakeProfit=0;
extern int     Slippage=3;
extern string  db0="---Flag to run start once per bar---";
extern string  db1=" Set to false when using stoploss";
extern string  db2=" takeprofit or trailing stop";
extern bool    UseOncePerDailyBar = true;


//+---------------------------------------------------+
//|General controls                                   |
//+---------------------------------------------------+
int            MagicNumber=0;
string         setup;
int            TradesInThisSymbol = 0;
double         mLots=0;
datetime       timeprev = 0;
int NewTicket;

//+---------------------------------------------------+
//|  Indicator values for signals and filters         |
//|  Add or Change to test your system                |
//+---------------------------------------------------+

//+------------------------------------------------------------------+
//| Calculate MagicNumber, setup comment and assign RSI Period       |
//|                                                                  |
//+------------------------------------------------------------------+
int init()
{

	MagicNumber = MagicNumberBase + func_Symbol2Val(Symbol())*100 + func_TimeFrame_Const2Val(Period()); 
   setup=Expert_Name + Symbol() + "_" + func_TimeFrame_Val2String(func_TimeFrame_Const2Val(Period()));
   setup = UserComment;
    
 return(0);
}

int deinit()
{
 return(0);
}

//+------------------------------------------------------------------------+
//| LSMA - Least Squares Moving Average function calculation               |
//| LSMA_In_Color Indicator plots the end of the linear regression line    |
//+------------------------------------------------------------------------+

double LSMADaily(int Rperiod, int shift)
{
   int i;
   double sum;
   int length;
   double lengthvar;
   double tmp;
   double wt;

     length = Rperiod;
 
     sum = 0;
     for(i = length; i >= 1  ; i--)
     {
       lengthvar = length + 1;
       lengthvar /= 3;
       tmp = 0;
       tmp = ( i - lengthvar)*iClose(NULL,0,length-i+shift);
       sum+=tmp;
      }
      wt = sum*6/(length*(length+1));
    
    return(wt);
}


//+------------------------------------------------------------------+
//| CheckExitCondition                                               |
//| Check if AngleSep cross 0 line                                   |
//+------------------------------------------------------------------+
bool CheckExitCondition(int TradeType)
{
   bool YesClose;
   double L_Fast,L_Slow;
   
   YesClose = false;
   L_Fast=LSMADaily(LSMAShortPeriod,1);
   L_Slow=LSMADaily(LSMALongPeriod,1);
   
   if (TradeType == OP_BUY)
   {
      if (L_Fast < L_Slow) YesClose = true;
   }
   if (TradeType == OP_SELL)
   {
    if (L_Fast > L_Slow) YesClose = true;
   }
    
   return (YesClose);
}


//+------------------------------------------------------------------+
//| CheckEntryCondition                                              |
//| Check if separation on LSMA pair                                 |
//+------------------------------------------------------------------+
bool CheckEntryCondition(int TradeType)
{
   bool YesTrade;
   double L_Fast,L_Slow;
   double L_FastPrev,L_SlowPrev;
   
   L_Fast=LSMADaily(LSMAShortPeriod,1);
   L_Slow=LSMADaily(LSMALongPeriod,1);
   
   YesTrade = false;
 

   if (TradeType == OP_BUY)
   {
    if ( L_Fast > L_Slow)
    {
       if (UseFreshCross == true)
       {
         L_FastPrev=LSMADaily(LSMAShortPeriod,2);
         L_SlowPrev=LSMADaily(LSMALongPeriod,2);
         if (L_FastPrev < L_SlowPrev) YesTrade = true; else YesTrade = false;
       }
       else
         YesTrade = true;
     }
   }
   
   if (TradeType == OP_SELL)
   {
     if ( L_Fast < L_Slow)
     {
       if (UseFreshCross == true)
       {
         L_FastPrev=LSMADaily(LSMAShortPeriod,2);
         L_SlowPrev=LSMADaily(LSMALongPeriod,2);
         if (L_FastPrev > L_SlowPrev) YesTrade = true; else YesTrade = false;
       }
       else
         YesTrade = true;
     }
   }
   
   return (YesTrade);
}
  
 
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Start                                                            |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int start()
{ 

// Only run once per completed bar

     if (UseOncePerDailyBar == true)
     {
       if(timeprev==Time[0]) return(0);
       timeprev = Time[0];
     }
     
//+------------------------------------------------------------------+
//| Check for Open Position                                          |
//+------------------------------------------------------------------+

     HandleOpenPositions();
     
     if (Month() < MonthStart) return(0);
     if (Month() > MonthEnd) return(0);
     
     
// Check if any open positions were not closed

     TradesInThisSymbol = CheckOpenPositions();
  
// Only allow 1 trade per Symbol

     if(TradesInThisSymbol > 0) {
       return(0);}
   
   mLots = CalcLotsMART();
          

	if(CheckEntryCondition(OP_BUY) == true)
	{
		   NewTicket = OpenBuyOrder(mLots, StopLoss,TakeProfit, Slippage, setup, MagicNumber, Green);
		   return(0);
	}

   
	if(CheckEntryCondition(OP_SELL) == true)
	{
         NewTicket = OpenSellOrder(mLots, StopLoss,TakeProfit, Slippage, setup, MagicNumber, Red);
	}

  return(0);
}

double CalcLotsMART() {
   double mLots,StartingLots;
   
   StartingLots = GetLots();
   
   if (OrderSelect(NewTicket, SELECT_BY_TICKET, MODE_HISTORY) == TRUE) {
      if (OrderProfit() < 1.0 * (TakeProfit * OrderLots())) {
         if (OrderLots() <= 8000.0) mLots = NormalizeDouble(MartMult * OrderLots(), 2);
         if (OrderLots() > 8000.0) mLots = StartingLots;
         return (mLots);
      } else return (StartingLots);
   } else return (StartingLots);
}

//+------------------------------------------------------------------+
//| Get number of lots for this trade                                |
//+------------------------------------------------------------------+
double GetLots()
{
   double lot;
   
   if(UseMoneyManagement == true)
   {
     lot = LotsOptimized();
   }
   else
   {
      lot = Lots;
   }

// Use at least 1 micro lot
   if (AccountIsMicro == true)
   {
      if (lot < 0.01) lot = 0.01;
      if (lot > MaxLots) lot = MaxLots * 100;
      if (BrokerIsIBFX == true) lot = lot * 10;
      return(lot);
   }

// Use at least 1 mini lot
   if(AccountIsMini == true)
   {
      if (lot < 0.1) lot = 0.1;
      if (lot > MaxLots) lot = MaxLots;
      if (BrokerIsIBFX == true) lot = lot * 10;
      return(lot);
   }
   
// Standard account   
   if( BrokerPermitsFractionalLots == false)
   {
      if (lot >= 1.0) lot = MathFloor(lot); else lot = 1.0;
   }
   
   if (lot > MaxLots) lot = MaxLots;

   return(lot);
}

//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+

double LotsOptimized()
  {
   double lot=Lots;
//---- select lot size

   if (UseFreeMargin == true)
        lot=NormalizeDouble(MathFloor(AccountFreeMargin()*TradeSizePercent/10000)/10,1);
   else
        lot=NormalizeDouble(MathFloor(AccountBalance()*TradeSizePercent/10000)/10,1);

  // Check if mini or standard Account
  if(AccountIsMini == true)
  {
    lot = MathFloor(lot*10)/10;
  }

   return(lot);
} 

//+------------------------------------------------------------------+
//| OpenBuyOrder                                                     |
//| If Stop Loss or TakeProfit are used the values are calculated    |
//| for each trade                                                   |
//+------------------------------------------------------------------+
int OpenBuyOrder(double mLots, double mStopLoss, double mTakeProfit, int mSlippage, string mComment, int mMagic, color mColor)
{
   int err,ticket;
   double myPrice, myStopLoss = 0, myTakeProfit = 0;
   
   RefreshRates();
   myStopLoss = StopLong(Bid,mStopLoss);
   myTakeProfit = TakeLong(Bid,mTakeProfit);
 // Normalize all price / stoploss / takeprofit to the proper # of digits.
   if (Digits > 0) 
   {
     myPrice = NormalizeDouble( Ask, Digits);
     myStopLoss = NormalizeDouble( myStopLoss, Digits);
     myTakeProfit = NormalizeDouble( myTakeProfit, Digits); 
   }
   ticket=OrderSend(Symbol(),OP_BUY,mLots,myPrice,mSlippage,myStopLoss,myTakeProfit,mComment,mMagic,0,mColor); 
   if (ticket > 0)
   {
    if (OrderSelect( ticket,SELECT_BY_TICKET, MODE_TRADES) ) 
     {
      Print("BUY order opened : ", OrderOpenPrice( ));
//      ModifyOrder(ticket,OrderOpenPrice( ), OrderStopLoss(), myTakeProfit);
     }
   }
   else
   {
      err = GetLastError();
      if(err==0)
      { 
         return(ticket);
      }
      else
      {
         if(err==4 || err==137 ||err==146 || err==136) //Busy errors
         {
            Sleep(5000);
         }
         else //normal error
         {
           Print("Error opening BUY order [" + setup + "]: (" + err + ") " + ErrorDescription(err)); 
         }  
      }
   }
   
   return(ticket);
}

//+------------------------------------------------------------------+
//| OpenSellOrder                                                    |
//| If Stop Loss or TakeProfit are used the values are calculated    |
//| for each trade                                                   |
//+------------------------------------------------------------------+
int OpenSellOrder(double mLots, double mStopLoss, double mTakeProfit, int mSlippage, string mComment, int mMagic, color mColor)
{
   int err, ticket;
   double myPrice, myStopLoss = 0, myTakeProfit = 0;
   
   RefreshRates();
   
   myStopLoss = StopShort(Ask,mStopLoss);
   myTakeProfit = TakeShort(Ask,mTakeProfit);
   
 // Normalize all price / stoploss / takeprofit to the proper # of digits.
   if (Digits > 0) 
   {
     myPrice = NormalizeDouble( Bid, Digits);
     myStopLoss = NormalizeDouble( myStopLoss, Digits);
     myTakeProfit = NormalizeDouble( myTakeProfit, Digits); 
   }
   ticket=OrderSend(Symbol(),OP_SELL,mLots,myPrice,mSlippage,myStopLoss,myTakeProfit,mComment,mMagic,0,mColor); 
   if (ticket > 0)
   {
     if (OrderSelect( ticket,SELECT_BY_TICKET, MODE_TRADES) ) 
     {
      Print("Sell order opened : ", OrderOpenPrice());
//      ModifyOrder(ticket,OrderOpenPrice( ), OrderStopLoss(), myTakeProfit);
     }
   }
   else
   {
      err = GetLastError();
      if(err==0)
      { 
         return(ticket);
      }
      else
      {
        if(err==4 || err==137 ||err==146 || err==136) //Busy errors
        {
           Sleep(5000);
        }
        else //normal error
        {
           Print("Error opening Sell order [" + mComment + "]: (" + err + ") " + ErrorDescription(err));
        }
      } 
   }
   
   return(ticket);
}


double StopLong(double price,int stop)
{
 if(stop==0)
  return(0);
 else
  return(price-(stop*Point));
}

double StopShort(double price,int stop)
{
 if(stop==0)
  return(0);
 else
  return(price+(stop*Point));
}

double TakeLong(double price,int take)
{
 if(take==0)
  return(0);
 else
  return(price+(take*Point));
}

double TakeShort(double price,int take)
{
 if(take==0)
  return(0);
 else
  return(price-(take*Point));
}

//+------------------------------------------------------------------+
//| Handle Open Positions                                            |
//| Check if any open positions need to be closed or modified        |
//+------------------------------------------------------------------+
int HandleOpenPositions()
{
   int cnt;
   
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
   {
      OrderSelect (cnt, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol() != Symbol()) continue;
      if ( OrderMagicNumber() != MagicNumber)  continue;
      
      if(OrderType() == OP_BUY)
      {
            
         if (CheckExitCondition(OP_BUY) == true)
          {
              CloseOrder(OrderTicket(),OrderOpenPrice(),OrderLots(),OP_BUY);
          }
      }

      if(OrderType() == OP_SELL)
      {
          if (CheckExitCondition(OP_SELL) == true)
          {
             CloseOrder(OrderTicket(),OrderOpenPrice(), OrderLots(),OP_SELL);
          }
      }
   }
}

//+------------------------------------------------------------------+
//| Check Open Position Controls                                     |
//+------------------------------------------------------------------+
  
int CheckOpenPositions()
{
   int cnt, total;
   int NumTrades;
   
   NumTrades = 0;
   total=OrdersTotal();
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
     {
      OrderSelect (cnt, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol() != Symbol()) continue;
      if ( OrderMagicNumber() != MagicNumber)  continue;
      
      if(OrderType() == OP_BUY )  NumTrades++;
      if(OrderType() == OP_SELL )  NumTrades++;
             
     }
     return (NumTrades);
  }
  
int CloseOrder(int ticket, double op, double numLots,int cmd)
{
   int CloseCnt, err, digits;
   double myPrice;
   string olStr, bidStr, askStr;
   
   RefreshRates();
   if (cmd == OP_BUY) myPrice = Bid;
   if (cmd == OP_SELL) myPrice = Ask;
   if (Digits > 0)  myPrice = NormalizeDouble( myPrice, Digits);
      olStr = DoubleToStr(numLots,2);
      bidStr = DoubleToStr(Bid, Digits);
      askStr = DoubleToStr(Ask, Digits);
   // try to close 3 Times
      
    CloseCnt = 0;
    while (CloseCnt < 3)
    {
       if (OrderClose(ticket,numLots,myPrice,Slippage,Violet) == false)
       {
         err=GetLastError();
         Print(CloseCnt," Error closing order : (", err , ") " + ErrorDescription(err));
         if (err > 0) CloseCnt++;
       }
       else
       {
         CloseCnt = 3;
       }
    }
}



int func_Symbol2Val(string symbol)
 {
   string mySymbol = StringSubstr(symbol,0,6);
   
	if(mySymbol=="AUDCAD") return(1);
	if(mySymbol=="AUDJPY") return(2);
	if(mySymbol=="AUDNZD") return(3);
	if(mySymbol=="AUDUSD") return(4);
	if(mySymbol=="CHFJPY") return(5);
	if(mySymbol=="EURAUD") return(6);
	if(mySymbol=="EURCAD") return(7);
	if(mySymbol=="EURCHF") return(8);
	if(mySymbol=="EURGBP") return(9);
	if(mySymbol=="EURJPY") return(10);
	if(mySymbol=="EURUSD") return(11);
	if(mySymbol=="GBPCHF") return(12);
	if(mySymbol=="GBPJPY") return(13);
	if(mySymbol=="GBPUSD") return(14);
	if(mySymbol=="NZDJPY") return(15);
	if(mySymbol=="NZDUSD") return(16);
	if(mySymbol=="USDCAD") return(17);
	if(mySymbol=="USDCHF") return(18);
	if(mySymbol=="USDJPY") return(19);
   Comment("unexpected Symbol");
	return(999);
}

//+------------------------------------------------------------------+
//| Time frame interval appropriation  function                      |
//+------------------------------------------------------------------+

int func_TimeFrame_Const2Val(int Constant ) {
   switch(Constant) {
      case 1:  // M1
         return(1);
      case 5:  // M5
         return(2);
      case 15:
         return(3);
      case 30:
         return(4);
      case 60:
         return(5);
      case 240:
         return(6);
      case 1440:
         return(7);
      case 10080:
         return(8);
      case 43200:
         return(9);
   }
}

//+------------------------------------------------------------------+
//| Time frame string appropriation  function                               |
//+------------------------------------------------------------------+

string func_TimeFrame_Val2String(int Value ) {
   switch(Value) {
      case 1:  // M1
         return("PERIOD_M1");
      case 2:  // M1
         return("PERIOD_M5");
      case 3:
         return("PERIOD_M15");
      case 4:
         return("PERIOD_M30");
      case 5:
         return("PERIOD_H1");
      case 6:
         return("PERIOD_H4");
      case 7:
         return("PERIOD_D1");
      case 8:
         return("PERIOD_W1");
      case 9:
         return("PERIOD_MN1");
   	default: 
   		return("undefined " + Value);
   }
}


//+------------------------------------------------------------------+




