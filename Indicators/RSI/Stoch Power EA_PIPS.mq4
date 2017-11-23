//+-----------------------------------------------------------------------------------+
//|                                                                STOCH POWER EA.mq4 |
//|                                               Copyright © 2005, Alejandro Galindo |
//|                                                               http://elCactus.com |
//|                               Copyright © 2007, AZAM575 & SYLARVAMPIRE & YUSOF786 |
//|                                                                 http://mymefx.com |
//|                                                 Copyright © 2008, David E. Fulton |
//|                                                     http://www.defulton.com/forex |
//+-----------------------------------------------------------------------------------+

///Please, do not sell this EA because its FREE

#property copyright "Copyright © 2008, David E. Fulton"
#property link      "www.defulton.com/forex"

string version="Stoch Power EA V5.0H Build 005";
extern string  INFO="Stoch Power EA V5.0H Build 005";
extern string  OWN="Copyright © 2008, David E. Fulton";
extern string  sq="--STOCH SETTING--";
extern double step = 1.5;   // Êמ‎פ. ראדא
extern int    K_Period = 28;
extern int    D_Period = 6;
extern int    Slow_Period = 14;
extern int    Stoch_TF = 1;
extern int    shift=1;
extern int    H_level =80;
extern int    L_level =20;
string        ChooseLineMode="Choose 1=mode main, 2=mode signal";
int           stochlinemode = 1;
extern string  ChooseeMAMode="Choose 1=mode SMA, 2=mode LWMA, 3=mode EMA";
extern int    stochMAmode = 2;
extern bool ExitWithSTOCH=False;
extern string  sb="--TRADE SETTING--";
extern double Lots = 0.01;       // We start with this lots number
extern int    TakeProfit = 30;  // Profit Goal for the latest order opened
extern bool MyMoneyProfitTarget=False;
extern double My_Money_Profit_Target=50;
extern double multiply=2.0; 
extern int MaxTrades=5;        // Maximum number of orders to open
extern int Pips=12;             // Distance in Pips from one order to another
extern int    StopLoss = 0;  // StopLoss
extern int    TrailingStop = 0;// Pips to trail the StopLoss
extern string  MM="--MOney Management--"; // (from order 2, not from first order
extern string  MMSwicth="if one the lots size will increase based on account size";
extern int mm=0;                // if one the lots size will increase based on account size
extern string  riskset="risk to calculate the lots size (only if mm is enabled)";
extern int risk=0;             // risk to calculate the lots size (only if mm is enabled)
extern string accounttypes="0 if Normal Lots, 1 for mini lots, 2 for micro lots";
extern int AccountType=2;  // 0 if Normal Lots, 1 for mini lots, 2 for micro lots
extern string  magicnumber="--MAgic No--";
extern int MagicNumber=222777;  // Magic number for the orders placed
extern string  so="--CUTLOSS SETTING--";
extern bool SecureProfitProtection=False;
extern string  SP="If profit made is bigger than SecureProfit we close the orders";
extern int SecureProfit=20;     // If profit made is bigger than SecureProfit we close the orders
extern string  OTP="Number of orders to enable the account protection";
extern int OrderstoProtect=3;   // Number of orders to enable the account protection
extern string  ASP="if one will check profit from all symbols, if cero only this symbol";
extern bool AllSymbolsProtect=False; // if one will check profit from all symbols, if cero only this symbol
extern string  EP="if true, then the expert will protect the account equity to the percent specified";
extern bool EquityProtection=False;  // if true, then the expert will protect the account equity to the percent specified
extern string  AEP="percent of the account to protect on a set of trades";
extern int AccountEquityPercentProtection=90; // percent of the account to protect on a set of trades
extern string  AMP="if true, then the expert will use money protection to the USD specified";
extern bool AccountMoneyProtection=False;
extern double AccountMoneyProtectionValue=3000.00;
bool UseHourTrade = False;
int FromHourTrade = 0;
int ToHourTrade = 1;

extern string  TradingTime="--trading time setting--";
extern bool    UseTradingHours = false;
extern bool    TradeAsianMarket = true;
extern int     StartHour1 = 0;       // Start trades after time
extern int     StopHour1 = 3;      // Stop trading after time
extern bool    TradeEuropeanMarket = true;
extern int     StartHour2 = 9;       // Start trades after time
extern int     StopHour2 = 11;      // Stop trading after time
extern bool    TradeNewYorkMarket = true;
extern int     StartHour3 = 15;       // Start trades after time
extern int     StopHour3 = 17;      // Stop trading after time
extern bool    TradeOnFriday=true;
extern string  OtherSetting="--Others Setting--";
int            OrdersTimeAlive=0;  // in seconds
extern string  reverse="if one the desition to go long/short will be reversed";
extern bool ReverseCondition=False;  // if one the desition to go long/short will be reversed
extern string  limitorder="if true, instead open market orders it will open limit orders ";
extern bool SetLimitOrders=False; // if true, instead open market orders it will open limit orders 
int Manual=0;            // If set to one then it will not open trades automatically
color ArrowsColor=Black;       // color for the orders arrows


int OpenOrdersBasedOn=16; // Method to decide if we start long or short
bool ContinueOpening=True;

int  OpenOrders=0, cnt=0;
int MarketOpenOrders=0, LimitOpenOrders=0;
int  slippage=5;
double sl=0, tp=0;
double BuyPrice=0, SellPrice=0;
double lotsi=0, mylotsi=0;
int mode=0, myOrderType=0, myOrderTypetmp=0;

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
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//---- 
   
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
//---- 
   int cnt=0;
   bool result;   
   string text="";
   
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
    text = text + "\nNot the designated trading hours.";
    Print("Not the designated trading hours. Profit: ",AccountProfit()," Equity: ",AccountEquity());
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

      if (!IsTesting()) 
      {
	     if (myOrderType==3 && OpenOrders<1) { text=text + "\nWaiting for a position"; }
	     //else { text= text + "\n                         "; }
	     Comment(version,"\nLast price=",LastPrice," Previous open orders=",PreviousOpenOrders,"\nContinue opening=",ContinueOpening," My order type=",myOrderType,"\nLot size=",lotsi,text);
      }

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
	     if ((Bid-LastPrice)>=ÂסודמÎנהונמגSell()*step*Pips*Point || OpenOrders<1) 
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
	     if ((LastPrice-Ask)>=ÂסודמÎנהונמגBuy()*step*Pips*Point || OpenOrders<1) 
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
		    SellPrice = LastPrice+ÂסודמÎנהונמגSell()*step*Pips*Point;
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
		    BuyPrice=LastPrice-ÂסודמÎנהונמגBuy()*step*Pips*Point;
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
 
    	double stom1=iStochastic(NULL,Stoch_TF,K_Period,D_Period,Slow_Period,mamode,0,MODE_MAIN,shift);
   	double stom2=iStochastic(NULL,Stoch_TF,K_Period,D_Period,Slow_Period,mamode,0,MODE_MAIN,shift+3);
   	double stos1=iStochastic(NULL,Stoch_TF,K_Period,D_Period,Slow_Period,mamode,0,MODE_SIGNAL,shift);
   	double stos2=iStochastic(NULL,Stoch_TF,K_Period,D_Period,Slow_Period,mamode,0,MODE_SIGNAL,shift+3);
//Sell order
        //  if(previousstoch>H_level && currentstoch<H_level)
         //if(previousstoch>currentstoch && currentstoch > H_level)  
         //if(previousstoch>H_level && previousstoch>currentstoch && currentstoch<H_level)
      if (stom1<stos1 && stom2>=stos2 && stom2>H_level)
         //if(previousstoch>H_level && signalstoch > currentstoch)
 {
  myOrderType=1;
 }
  
//buy order
         // if(previousstoch<L_level && currentstoch>L_level)
  //if(previousstoch<currentstoch && currentstoch < L_level)
    //if(previousstoch<L_level && previousstoch<currentstoch && currentstoch>L_level)
if (stom1>stos1 && stom2<=stos2 && stom2<L_level)
    
            // if(previousstoch<L_level && signalstoch < currentstoch)
    
 {
  myOrderType=2;
 }

 return(myOrderType);
}



int ÂסודמÎנהונמגBuy() {
 
  int res = 0;
  int cnt = OrdersTotal();
  for (int i=0; i < cnt; i++) {
    OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol() != Symbol()) continue;

    if(OrderType()==OP_BUY||OrderType()==OP_BUYSTOP) res++;
   }
  return(res);
}
int ÂסודמÎנהונמגSell() {
 
  int res = 0;
  int cnt = OrdersTotal();
  for (int i=0; i < cnt; i++) {
    OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol() != Symbol()) continue;

    if(OrderType()==OP_SELL||OrderType()==OP_SELLSTOP) res++;
   }
  return(res);
}