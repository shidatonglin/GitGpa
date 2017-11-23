//+-----------------------------------------------------------------------------------+
//|                                               Stoch Spike_Wakena Scalper V5.2.mq4 |
//|                                               Copyright © 2005, Alejandro Galindo |
//|                                                               http://elCactus.com |
//|                                                       Copyright © 2009, spike2009 |
//|                                                 http://bulldogge1232000@yahoo.com |
//+-----------------------------------------------------------------------------------+

///Please, do not sell this EA because its FREE

#property copyright "Copyright © 2009, spike2009"
#property link      " bulldogge1232000@yahoo.com "

extern string    INFO=" Stoch Spike_Wakena Scalper V5.2 ";
extern string    OWN="Copyright © 2009, spike2009";
extern string    sq="--STOCH SETTING--";
extern int       K_Period = 28;
extern int       D_Period = 6;
extern int       Slow_Period = 14;
extern int       Stoch_TF1 = 1;                      // Primary stoch time frame
extern int       Stoch_TF2 = 1;                      // Secondary stoch time frame
extern int       shift=1;
extern int       H_level =80;
extern int       L_level =20;
extern string    ChooseLineMode="Choose 1=mode main, 2=mode signal";
extern int       stochlinemode = 1;
extern string    ChooseeMAMode="Choose 1=mode SMA, 2=mode LWMA, 3=mode EMA";
extern int       stochMAmode = 2;
extern bool      ExitWithSTOCH=False;
extern string    se="--ENVELOPE SETTINGS--";
extern int       ENVELOPE_Slow_Period = 14;
extern int       ENVELOPE_TF = 1440;
extern string    sb="--TRADE SETTING--";
extern double    Lots = 0.01;                       // We start with this lots number
extern int       TakeProfit = 32;                   // Profit Goal for the latest order opened
extern bool      MyMoneyProfitTarget=True;
extern double    My_Money_Profit_Target=45;
extern double    multiply=2; 
extern int       MaxTrades=4;                      // Maximum number of orders to open
extern int       Pips=15;                           // Distance in Pips from one order to another
extern int       StopLoss = 0;                     // StopLoss
extern int       TrailingStop = 0;                 // Pips to trail the StopLoss
extern string    MM="--MOney Management--";        // (from order 2, not from first order
extern string    MMSwicth="if one the lots size will increase based on account size";
extern int       mm=1;                             // if one the lots size will increase based on account size
extern string    riskset="risk to calculate the lots size (only if mm is enabled)";
extern int       risk=10;                           // risk to calculate the lots size (only if mm is enabled)
extern string    accounttypes="0 if Normal Lots, 1 for mini lots, 2 for micro lots";
extern int       AccountType=2;                    // 0 if Normal Lots, 1 for mini lots, 2 for micro lots
extern string    magicnumber="--MAgic No--";
extern int       MagicNumber=222777;               // Magic number for the orders placed
extern string    so="--CUTLOSS SETTING--";
extern bool      SecureProfitProtection=True;
extern string    SP="If profit made is bigger than SecureProfit we close the orders";
extern int       SecureProfit=22;                 // If profit made is bigger than SecureProfit we close the orders
extern string    OTP="Number of orders to enable the account protection";
extern int       OrderstoProtect=3;               // Number of orders to enable the account protection
extern string    ASP="if one will check profit from all symbols, if cero only this symbol";
extern bool      AllSymbolsProtect=False;         // if one will check profit from all symbols, if cero only this symbol
extern string    EP="if true, then the expert will protect the account equity to the percent specified";
extern bool      EquityProtection=False;          // if true, then the expert will protect the account equity to the percent specified
extern string    AEP="percent of the account to protect on a set of trades";
extern int       AccountEquityPercentProtection=90; // percent of the account to protect on a set of trades
extern string    AMP="if true, then the expert will use money protection to the USD specified";
extern bool      AccountMoneyProtection=False;
extern double    AccountMoneyProtectionValue=3000.00;
string           s1="--seting berapa jam dia nak open order--";
bool             UseHourTrade = False;
int              FromHourTrade = 0;
int              ToHourTrade = 1;

extern string    TradingTime="--trading time setting--";
extern bool      UseTradingHours = True;
extern bool      TradeAsianMarket = true;
extern int       StartHour1 = 11;              // Start trades after time
extern int       StopHour1 = 23;               // Stop trading after time
extern bool      TradeEuropeanMarket = true;
extern int       StartHour2 = 7;               // Start trades after time
extern int       StopHour2 = 11;               // Stop trading after time
extern bool      TradeNewYorkMarket = false;
extern int       StartHour3 = 15;              // Start trades after time
extern int       StopHour3 = 17;               // Stop trading after time
extern bool      TradeOnFriday=False;
extern string    OtherSetting="--Others Setting--";
extern int       OrdersTimeAlive=0;            // in seconds
extern string    reverse="if one the desition to go long/short will be reversed";
extern bool      ReverseCondition=False;       // if one the desition to go long/short will be reversed
extern string    limitorder="if true, instead open market orders it will open limit orders ";
extern bool      SetLimitOrders=False;         // if true, instead open market orders it will open limit orders 
extern int       Manual=0;                     // If set to one then it will not open trades automatically
color            ArrowsColor=Black;            // color for the orders arrows


int              OpenOrdersBasedOn=16;         // Method to decide if we start long or short
bool             ContinueOpening=True;

int              OpenOrders=0, cnt=0;
int              MarketOpenOrders=0,           LimitOpenOrders=0;
int              slippage=5;
double           sl=0,                         tp=0;
double           BuyPrice=0,                   SellPrice=0;
double           lotsi=0,                      mylotsi=0;
int              mode=0,                       myOrderType=0,                    myOrderTypetmp=0;

double LastPrice=0;
int  PreviousOpenOrders=0;
double Profit=0;
int LastTicket=0, LastType=0;
double LastClosePrice=0, LastLots=0;
double Pivot=0;
double PipValue=0;
bool Reversed=False;
double tmp=0;
double iTmpH=0;
double iTmpL=0;
datetime NonTradingTime[][2];
bool FileReaded=false;
string dateLimit = "2030.01.12 23:00";
int CurTimeOpeningFlag=0;
datetime LastOrderOpenTime=0;
bool YesStop;
int slgap=0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//---- 
   int dig=MarketInfo(Symbol(),MODE_DIGITS);
    int x;
    if(dig==2) x=1;
    if(dig==3) x=10;
    if(dig==4) x=1;
    if(dig==5) x=10;
            
   if(TakeProfit>0) TakeProfit = TakeProfit*x;
   if(StopLoss>0) StopLoss = StopLoss*x; 
   if(TrailingStop>0) TrailingStop = TrailingStop*x;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   DeleteAllObjects();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
  
//**************ADDED FOR ACCOUNT SENTRY ***************
  
      if (GlobalVariableGet("GV_CloseAllAndHalt") > 0){
      return (0);
      } else
      
//**************END ACCOUNT SENTRY HOOK ****************
   

   //--- Set Margin counter ---------------------------- WJ Begin --//
   //--- Init Code ---//
   string GlobValMargin = AccountNumber()+"_Stoch-Power-EA-5h_Margin";
   if(!GlobalVariableCheck(GlobValMargin)) GlobalVariableSet(GlobValMargin,0);
   double AcctMargin = GlobalVariableGet(GlobValMargin);

   //--- Start Code ---//
   double AcctMarginCurr = AccountMargin();
   if(AcctMargin < AcctMarginCurr){
      AcctMargin = AcctMarginCurr;
      GlobalVariableSet(GlobValMargin,AcctMargin);
   }
   //--------------------------------------------------- WJ End ----//

  
//---- 
   int cnt=0;
   bool result;   
   string text="";
   string version="VERSI INI DAH EXPIRED...SILA YM xxul_gunturean utk penggantian";

   
  // skrip masa trading
    if (UseTradingHours)
   {

     YesStop = true;
// Check trading Asian Market
     if (TradeAsianMarket)
     {
        if (StartHour1 > 18)
        {
// Check broker that uses Asian open before 0:00

          if (Hour() >= StartHour1) YesStop = false;
          if (!YesStop)
          {
            if (StopHour1 < 24)
            {
              if ( Hour() <= StopHour1) YesStop = false;
            }
// These cannot be combined even though the code looks the same
            if (StopHour1 >=0)
            {
              if ( Hour() <= StopHour1) YesStop = false;
            }
          }
        }
        else
        {
          if (Hour() >= StartHour1 && Hour() <= StopHour1) YesStop = false;
        }
     }
     if (YesStop)
     {
// Check trading European Market
       if (TradeEuropeanMarket)
       {
         if (Hour() >= StartHour2 && Hour() <= StopHour2) YesStop = false;
       }
     }
     if (YesStop)
     {
// Check trading European Market
       if (TradeNewYorkMarket)
       {
         if (Hour() >= StartHour3 && Hour() <= StopHour3) YesStop = false;
       }
     }
     if (YesStop)
     {
//      Comment ("Trading has been stopped as requested - wrong time of day");
       return (0);
      }
   }
   
   // skrip masa trading

   
   if (AccountType==0)
   {
	 if (mm!=0) { lotsi=MathCeil(AccountBalance()*risk/10000); }
	 else { lotsi=Lots; }
   } 
   
   if (AccountType==1)
   {  // then is mini
    if (mm!=0) { lotsi=MathCeil(AccountBalance()*risk/10000)/10; }
	 else { lotsi=Lots; }
   }
   
   if (AccountType==2)
   {
    if (mm!=0) { lotsi=MathCeil(AccountBalance()*risk/10000)/100; }
    else { lotsi=Lots; }
   }

   if (lotsi<0.01) lotsi=0.01;
   if (lotsi>100) lotsi=100; 
   
   OpenOrders=0;
   MarketOpenOrders=0;
   LimitOpenOrders=0;
   for(cnt=0;cnt<OrdersTotal();cnt++)   
   {
     if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
     {
	   if (OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
	   {				
	  	  if (OrderType()==OP_BUY || OrderType()==OP_SELL) 
	  	  {
	  	   MarketOpenOrders++;
	  	   LastOrderOpenTime=OrderOpenTime();
	  	  }
	  	  if (OrderType()==OP_SELLLIMIT || OrderType()==OP_BUYLIMIT) LimitOpenOrders++;
	  	  OpenOrders++;
	   }
	  }
   }  
   
   if (OpenOrders<1) 
   {
	  if (!TradeOnFriday && DayOfWeek()==5) 
	  {
	    Comment("TradeOnfriday is False");
	    return(0);
	  }
   }
   
   PipValue=MarketInfo(Symbol(),MODE_TICKVALUE); 
   
   if (PipValue==0) { PipValue=5; }
  
   if (AccountMoneyProtection && AccountBalance()-AccountEquity()>=AccountMoneyProtectionValue)
   {
    text = text + "\nClosing all orders and stop trading because account money protection activated..";
    Print("Closing all orders and stop trading because account money protection activated.. Balance: ",AccountBalance()," Equity: ",AccountEquity());
    PreviousOpenOrders=OpenOrders+1;
    ContinueOpening=False;
    return(0);
   }
   
   ////aku masukkan time
   if (UseHourTrade){
      if (!(Hour()>=FromHourTrade && Hour()<=ToHourTrade)) {
    text = text + "\nORDER TELAH DI TUTUP KERANA MASA DAH TAMAT.";
    Print("ORDER TELAH DI TUTUP KERANA MASA TAMAT. UNTUNG: ",AccountProfit()," EKUITI: ",AccountEquity());
    PreviousOpenOrders=OpenOrders+1;
    ContinueOpening=False;
    return(0);
   }
}
   //set my profit for one Day
   if (MyMoneyProfitTarget && AccountProfit()>= My_Money_Profit_Target)
   {
    text = text + "\nClosing all orders and stop trading because mymoney profit target reached..";
    Print("Closing all orders and stop trading because mymoney profit target reached.. Profit: ",AccountProfit()," Equity: ",AccountEquity());
    PreviousOpenOrders=OpenOrders+1;
    ContinueOpening=False;
    return(0);
   }
   // Account equity protection 
   if (EquityProtection && AccountEquity()<=AccountBalance()*AccountEquityPercentProtection/100) 
	 {
	 text = text + "\nClosing all orders and stop trading because account money protection activated.";
	 Print("Closing all orders and stop trading because account money protection activated. Balance: ",AccountBalance()," Equity: ", AccountEquity());
	 //Comment("Closing orders because account equity protection was triggered. Balance: ",AccountBalance()," Equity: ", AccountEquity());
	 //OrderClose(LastTicket,LastLots,LastClosePrice,slippage,Orange);		 
	 PreviousOpenOrders=OpenOrders+1;
	 ContinueOpening=False;
	 return(0);
   }
     
   // if dont trade at fridays then we close all
   if (!TradeOnFriday && DayOfWeek()==5)
   {
    PreviousOpenOrders=OpenOrders+1;
    ContinueOpening=False;
    text = text +"\nClosing all orders and stop trading because TradeOnFriday protection.";
    Print("Closing all orders and stop trading because TradeOnFriday protection.");
   }
   
   // Orders Time alive protection
   if (OrdersTimeAlive>0 && CurTime() - LastOrderOpenTime>OrdersTimeAlive)
   {
    PreviousOpenOrders=OpenOrders+1;
    ContinueOpening=False;
    text = text + "\nClosing all orders because OrdersTimeAlive protection.";
    Print("Closing all orders because OrdersTimeAlive protection.");
   }
   
   if (PreviousOpenOrders>OpenOrders) 
   {	  
	  for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
	  {
	     if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
	     {
	  	   mode=OrderType();
		   if ((OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber) || AllSymbolsProtect) 
		   {
		 	 if (mode==OP_BUY || mode==OP_SELL)
		 	 { 
		 	  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,ArrowsColor);
	 		  return(0);
	 		 }
		  }
		 }
	  }
	  for(cnt=0;cnt<OrdersTotal();cnt++)
	  {
	     if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
	     {
	  	   mode=OrderType();
		   if ((OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber) || AllSymbolsProtect) 
		   {
		 	 if (mode==OP_SELLLIMIT || mode==OP_BUYLIMIT || mode==OP_BUYSTOP || mode==OP_SELLSTOP)
		 	 {
			  OrderDelete(OrderTicket());
	 		  return(0);
	 		 }
		  }
		 }
	  }
   }
   PreviousOpenOrders=OpenOrders;
      
   if (OpenOrders>=MaxTrades) 
   {
	  ContinueOpening=False;
   } else {
	  ContinueOpening=True;
   }

   if (LastPrice==0) 
   {
	  for(cnt=0;cnt<OrdersTotal();cnt++)
	  {	
	    if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
	    {
		  mode=OrderType();	
		  if (OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber) 
		  {
			LastPrice=OrderOpenPrice();
			if (mode==OP_BUY) { myOrderType=2; }
			if (mode==OP_SELL) { myOrderType=1;	}
		  }
		 }
	  }
   }

   // SecureProfit protection
  //if (SecureProfitProtection && MarketOpenOrders>=(MaxTrades-OrderstoProtect)
  // Modified to make easy to understand 
  if (SecureProfitProtection && MarketOpenOrders>=OrderstoProtect) 
   {
	  Profit=0;
     for(cnt=0;cnt<OrdersTotal();cnt++)
     {
      if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
      {
       if ((OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) || AllSymbolsProtect)
        Profit=Profit+OrderProfit();         
      }
     }	    
	  if (Profit>=SecureProfit) 
	  {
	     text = text + "\nClosing orders because account protection with SecureProfit was triggered.";
	     Print("Closing orders because account protection with SeureProfit was triggered. Balance: ",AccountBalance()," Equity: ", AccountEquity()," Profit: ",Profit);
	     PreviousOpenOrders=OpenOrders+1;
		  ContinueOpening=False;
		  return(0);
	  }
   }

  myOrderTypetmp=3;
  switch (OpenOrdersBasedOn)
  {  
     case 16:
       myOrderTypetmp=OpenOrdersBasedOnSTOCH();
       break; 	
     default: 
        myOrderTypetmp=OpenOrdersBasedOnSTOCH();
        break;
  }
  
  


   if (OpenOrders<1 && Manual==0) 
   {
     myOrderType=myOrderTypetmp;
	  if (ReverseCondition)
	  {
	  	  if (myOrderType==1) { myOrderType=2; }
		  else { if (myOrderType==2) { myOrderType=1; } }
	  }
   }   
   if (ReverseCondition)
   {
    if (myOrderTypetmp==1) { myOrderTypetmp=2; }
    else { if (myOrderTypetmp==2) { myOrderTypetmp=1; } }
   }
   
   // if we have opened positions we take care of them
   cnt=OrdersTotal()-1;
   while(cnt>=0)
   {
     if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==false)        break;
	  if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) // && Reversed==False) 
	  {
        //Print("Ticket ",OrderTicket()," modified.");	     
	  	  if (OrderType()==OP_SELL) 
	  	  {		
	  	     if (ExitWithSTOCH&& myOrderTypetmp==2)
           {
             PreviousOpenOrders=OpenOrders+1;
             ContinueOpening=False;
             text = text +"\nClosing all orders because Indicator triggered another signal.";
             Print("Closing all orders because Indicator triggered another signal."); 
             //return(0);
           }
	  	  	  if (TrailingStop>0) 
			  {
				  if ((OrderOpenPrice()-OrderClosePrice())>=(TrailingStop*Point+Pips*Point)) 
				  {						
					 if (OrderStopLoss()>(OrderClosePrice()+TrailingStop*Point))
					 {										    
					    result=OrderModify(OrderTicket(),OrderOpenPrice(),OrderClosePrice()+TrailingStop*Point,OrderClosePrice()-TakeProfit*Point-TrailingStop*Point,0,Purple);
					    if(result!=TRUE) Print("LastError = ", GetLastError());
                   else OrderPrint();
	  					 return(0);	  					
	  				 }
	  			  }
			  }
	  	  }
   
	  	  if (OrderType()==OP_BUY)
	  	  {
	  	     if (ExitWithSTOCH && myOrderTypetmp==1)
           {
             PreviousOpenOrders=OpenOrders+1;
             ContinueOpening=False;
             text = text +"\nClosing all orders because Indicator triggered another signal.";
             Print("Closing all orders because Indicator triggered another signal."); 
             //return(0);
           }
	  		 if (TrailingStop>0) 
	  		 {
			   if ((OrderClosePrice()-OrderOpenPrice())>=(TrailingStop*Point+Pips*Point)) 
				{
					if (OrderStopLoss()<(OrderClosePrice()-TrailingStop*Point)) 
					{					   
					   result=OrderModify(OrderTicket(),OrderOpenPrice(),OrderClosePrice()-TrailingStop*Point,OrderClosePrice()+TakeProfit*Point+TrailingStop*Point,0,ArrowsColor);		
					   if(result!=TRUE) Print("LastError = ", GetLastError());                  
                  else OrderPrint();
                  return(0);
					}
  				}
			 }
	  	  }
   	}
      cnt--;
   }   

   
  // skrip masa trading
    if (UseTradingHours)
   {

     YesStop = true;
// Check trading Asian Market
     if (TradeAsianMarket)
     {
        if (StartHour1 > 18)
        {
// Check broker that uses Asian open before 0:00

          if (Hour() >= StartHour1) YesStop = false;
          if (!YesStop)
          {
            if (StopHour1 < 24)
            {
              if ( Hour() <= StopHour1) YesStop = false;
            }
// These cannot be combined even though the code looks the same
            if (StopHour1 >=0)
            {
              if ( Hour() <= StopHour1) YesStop = false;
            }
          }
        }
        else
        {
          if (Hour() >= StartHour1 && Hour() <= StopHour1) YesStop = false;
        }
     }
     if (YesStop)
     {
// Check trading European Market
       if (TradeEuropeanMarket)
       {
         if (Hour() >= StartHour2 && Hour() <= StopHour2) YesStop = false;
       }
     }
     if (YesStop)
     {
// Check trading European Market
       if (TradeNewYorkMarket)
       {
         if (Hour() >= StartHour3 && Hour() <= StopHour3) YesStop = false;
       }
     }
     if (YesStop)
     {
//      Comment ("Trading has been stopped as requested - wrong time of day");
       return (0);
      }
   }
   
   // skrip masa trading


      if (!IsTesting()) 
      {
	     if (myOrderType==3 && OpenOrders<1) { text=text + "\nOPEN ORDER"; }
	     //else { text= text + "\n                         "; }
	     Comment("LAST PRICE=",LastPrice," OPEN ORDERS=",PreviousOpenOrders,"\nCONTINUE OPENING=",ContinueOpening," MY ORDER TYPE=",myOrderType,"\nLOT=",lotsi,text);
      }
   if(OpenOrders==0) slgap=0;
      if( BuyGap() < slgap && OpenOrders==MaxTrades) { slgap=BuyGap(); Alert("XXXXXXXXXXXXXXXXXXXXXX DD = ",slgap); }

      if (OpenOrders<1)
         OpenMarketOrders();
      else
         if (SetLimitOrders) OpenLimitOrders();
         else OpenMarketOrders();

//----
   return(0);
  }
//+------------------------------------------------------------------+


void OpenMarketOrders()
{         
   int cnt=0;      
      if (myOrderType==1 && ContinueOpening) 
      {	      
	     if ((Bid-LastPrice)>=Pips*Point || OpenOrders<1) 
	     {	     		
		    SellPrice=Bid;				
		    LastPrice=0;
		    if (TakeProfit==0) { tp=0; }
		    else { tp=SellPrice-TakeProfit*Point; }	
		    if (StopLoss==0) { sl=0; }
		    else { sl=SellPrice+StopLoss*Point;  }
		    if (OpenOrders!=0) 
		    {
			      mylotsi=lotsi;			
			      for(cnt=0;cnt<OpenOrders;cnt++)
			      {
				     if (MaxTrades>12) { mylotsi=NormalizeDouble(mylotsi*multiply,2); }
				     else { mylotsi=NormalizeDouble(mylotsi*multiply,2); }
			      }
		    } else { mylotsi=lotsi; }
		    if (mylotsi>100) { mylotsi=100; }			    
		    OrderSend(Symbol(),OP_SELL,mylotsi,SellPrice,slippage,sl,tp,"MyMEFx EA"+MagicNumber,MagicNumber,0,ArrowsColor);		    		    
		    return(0);
	     }
	     
	  //   Sleep(6000);   ////aku letak
        //      RefreshRates(); 
      }
      
      if (myOrderType==2 && ContinueOpening) 
      {
	     if ((LastPrice-Ask)>=Pips*Point || OpenOrders<1) 
	     {			      
		    BuyPrice=Ask;
		    LastPrice=0;
		    if (TakeProfit==0) { tp=0; }
		    else { tp=BuyPrice+TakeProfit*Point; }	
		    if (StopLoss==0)  { sl=0; }
		    else { sl=BuyPrice-StopLoss*Point; }
		    if (OpenOrders!=0) {
			   mylotsi=lotsi;			
			   for(cnt=0;cnt<OpenOrders;cnt++)
			   {
				  if (MaxTrades>12) { mylotsi=NormalizeDouble(mylotsi*multiply,2); }
				  else { mylotsi=NormalizeDouble(mylotsi*multiply,2); }
			   }
		    } else { mylotsi=lotsi; }
		    if (mylotsi>100) { mylotsi=100; }
		    OrderSend(Symbol(),OP_BUY,mylotsi,BuyPrice,slippage,sl,tp,"MyMEFx EA"+MagicNumber,MagicNumber,0,ArrowsColor);		    
		    return(0);
	     }
      }   
}

void OpenLimitOrders()
{
   int cnt=0;
               
      if (myOrderType==1 && ContinueOpening) 
      {	
	     //if ((Bid-LastPrice)>=Pips*Point || OpenOrders<1) 
	     //{		
		    //SellPrice=Bid;				
		    SellPrice = LastPrice+Pips*Point;
		    LastPrice=0;
		    if (TakeProfit==0) { tp=0; }
		    else { tp=SellPrice-TakeProfit*Point; }	
		    if (StopLoss==0) { sl=0; }
		    else { sl=SellPrice+StopLoss*Point;  }
		    if (OpenOrders!=0) 
		    {
			      mylotsi=lotsi;			
			      for(cnt=0;cnt<OpenOrders;cnt++)
			      {
				     if (MaxTrades>12) { mylotsi=NormalizeDouble(mylotsi*multiply,2); }
				     else { mylotsi=NormalizeDouble(mylotsi*multiply,2); }
			      }
		    } else { mylotsi=lotsi; }
		    if (mylotsi>100) { mylotsi=100; }
		    OrderSend(Symbol(),OP_SELLLIMIT,mylotsi,SellPrice,slippage,sl,tp,"MyMEFx EA"+MagicNumber,MagicNumber,0,ArrowsColor);		    		    
		    return(0);
	     //}
      }
      
      if (myOrderType==2 && ContinueOpening) 
      {
	     //if ((LastPrice-Ask)>=Pips*Point || OpenOrders<1) 
	     //{		
		    //BuyPrice=Ask;
		    BuyPrice=LastPrice-Pips*Point;
		    LastPrice=0;
		    if (TakeProfit==0) { tp=0; }
		    else { tp=BuyPrice+TakeProfit*Point; }	
		    if (StopLoss==0)  { sl=0; }
		    else { sl=BuyPrice-StopLoss*Point; }
		    if (OpenOrders!=0) {
			   mylotsi=lotsi;			
			   for(cnt=0;cnt<OpenOrders;cnt++)
			   {
				  if (MaxTrades>12) { mylotsi=NormalizeDouble(mylotsi*multiply,2); }
				  else { mylotsi=NormalizeDouble(mylotsi*multiply,2); }
			   }
		    } else { mylotsi=lotsi; }
		    if (mylotsi>100) { mylotsi=100; }
		    OrderSend(Symbol(),OP_BUYLIMIT,mylotsi,BuyPrice,slippage,sl,tp,"MyMEFx EA"+MagicNumber,MagicNumber,0,ArrowsColor);		    
		    return(0);
	     //}
      }   

}

void DeleteAllObjects()
{
 int    obj_total=ObjectsTotal();
 string name;
 for(int i=0;i<obj_total;i++)
 {
  name=ObjectName(i);
  if (name!="")
   ObjectDelete(name);
 }
 ObjectDelete("FLP_txt");
 ObjectDelete("P_txt");
}

// 16
int OpenOrdersBasedOnSTOCH()
{
 int myOrderType=3;
 double modest;
  switch (stochlinemode)
  {  
     case 1:
       modest=MODE_MAIN;
       break; 	
     case 2:
       modest=MODE_SIGNAL;
       break; 
     default: 
        modest=MODE_MAIN;
        break;
  }
  
 double mamode;
  switch (stochMAmode)
  {  
     case 1:
       modest=MODE_SMA;
       break; 	
     case 2:
       modest=MODE_LWMA;
       break; 
            case 3:
       modest=MODE_EMA;
       break; 
     default: 
        modest=MODE_LWMA;
        break;
  }

 //---- lot setting and modifications
 
   double stom1=iStochastic(NULL,Stoch_TF1,K_Period,D_Period,Slow_Period,mamode,0,MODE_MAIN, shift);
   double stom2=iStochastic(NULL,Stoch_TF1,K_Period,D_Period,Slow_Period,mamode,0,MODE_MAIN, shift+3);
     double stom3=iStochastic(NULL,Stoch_TF2,K_Period,D_Period,Slow_Period,mamode,0,MODE_MAIN, shift);
     double stom4=iStochastic(NULL,Stoch_TF2,K_Period,D_Period,Slow_Period,mamode,0,MODE_MAIN, shift+3);
   double stos1=iStochastic(NULL,Stoch_TF1,K_Period,D_Period,Slow_Period,mamode,0,MODE_SIGNAL, shift);
   double stos2=iStochastic(NULL,Stoch_TF1,K_Period,D_Period,Slow_Period,mamode,0,MODE_SIGNAL, shift+3);
     double stos3=iStochastic(NULL,Stoch_TF2,K_Period,D_Period,Slow_Period,mamode,0,MODE_SIGNAL, shift);
     double stos4=iStochastic(NULL,Stoch_TF2,K_Period,D_Period,Slow_Period,mamode,0,MODE_SIGNAL, shift+3);
   double E_upper=iEnvelopes(NULL,ENVELOPE_TF ,ENVELOPE_Slow_Period,MODE_SMA,0,PRICE_CLOSE,0.9,1,1);
   double E_lower=iEnvelopes(NULL,ENVELOPE_TF ,ENVELOPE_Slow_Period,MODE_SMA,0,PRICE_CLOSE,0.9,2,1);
   double ma1=iMA(NULL,Stoch_TF1 ,2,MODE_SMA,0,PRICE_CLOSE,0);
   double ma2=iMA(NULL,Stoch_TF1,200,MODE_SMA,0,PRICE_CLOSE,0);


//Sell order
        //  if(previousstoch>H_level && currentstoch<H_level)
         //if(previousstoch>currentstoch && currentstoch > H_level) 
         //if(previousstoch>H_level && previousstoch>currentstoch && currentstoch<H_level)
      if ((stom1<stos1 && stom2>=stos2 && stom2>H_level && (Low[0] > E_lower && High[0] < E_upper))||(stom3<stos3 && stom4>=stos4 && stom4>H_level && ma1 < ma2 && ((Low[0]<E_lower)||(High[0]>E_upper))))
         //if(previousstoch>H_level && signalstoch > currentstoch)
 {
  myOrderType=1;
 }
 
//buy order
       // if(previousstoch<L_level && currentstoch>L_level)
       //if(previousstoch<currentstoch && currentstoch < L_level)
       //if(previousstoch<L_level && previousstoch<currentstoch && currentstoch>L_level)
     if ((stom1>stos1 && stom2<=stos2 && stom2<L_level && (Low[0] > E_lower && High[0] < E_upper))||(stom3>stos3 && stom4<=stos4 && stom4<L_level && ma1 > ma2 && ((Low[0] < E_lower)||(High[0] > E_upper)))) 
       // if(previousstoch<L_level && signalstoch < currentstoch)
   
 {
  myOrderType=2;
 }


 return(myOrderType);
}

int BuyGap() { 
   double value=0;
   for (int i=0; i<OrdersTotal(); i++) { 
		if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
			if((OrderSymbol()==Symbol()) && OrderMagicNumber() == MagicNumber) 
		{
			if(OrderType()==OP_BUY) value=(OrderClosePrice()-OrderOpenPrice())/Point;
			if(OrderType()==OP_SELL) value=(OrderOpenPrice()-OrderClosePrice())/Point;
			
		}
	}  
   return(value); 
}