//+------------------------------------------------------------------+
//|                                              Renko_Hunter_v4.mq4 |
//|
//|  
//-------------------------------------------------------------

#property copyright "Copyright ?2015, Peter Malecki, Roland Malecki"
#property link      "http://www.dicdata.de/"

#include <stdlib.mqh>
#include <WinUser32.mqh>


// exported variables
 //************************************************************
// Money mangement parameters
//************************************************************
extern bool   MM                    = true;

extern  string  dispMM = "Settings Money Management";
//Exemple de SizingRule: 1.0= 1 lot, 5%B=5% de la balance 5%F=5% du free margin, 100$= 100$
//extern double  Size				   = 5.0; 	
extern string  SizingRule				= "2%B"; 	//Risk/Reward per trade. Or, can be fixed number of lots;
extern double 	ProfitLossfactor		= 0.30;		//Factor to calculate TP and SL. Multiple of the ADR
extern int LastXTrades              = 8; //10; //Used for TSSF calculation
double  maxlots;

extern double BuyLots27             = 0.2;
extern int BuyStoploss27            = 100;
extern int BuyTakeprofit27          = 100;
extern double SellLots22            = 0.2;
extern int SellStoploss22           = 100;
extern int SellTakeprofit22         = 100;

extern int Slippage               = 3;

// local variables
double PipValue=1;    // this variable is here to support 5-digit brokers
bool Terminated = false;
string LF = "\n";  // use this in custom or utility blocks where you need line feeds
int NDigits = 4;   // used mostly for NormalizeDouble in Flex type blocks
int ObjCount = 0;  // count of all objects created on the chart, allows creation of objects with unique names
int current = 0;

double MINLOT;

int init()
{
    MINLOT = MarketInfo(Symbol(),MODE_MINLOT);
    maxlots = MarketInfo(Symbol(),MODE_MAXLOT);
     
    NDigits = Digits;
    
    if (false) ObjectsDeleteAll();      // clear the chart
 
    Comment("");    // clear the chart
    return (0);
}

// Expert start
int start()
{
    if (Bars < 10)
    {
        Comment("Not enough bars");
        return (0);
    }
    if (Terminated == true)
    {
        Comment("EA Terminated.");
        return (0);
    }
    
    OnEveryTick5();
    return (0);
}

void OnEveryTick5()
{
    PipValue = 1;
    if (NDigits == 3 || NDigits == 5) PipValue = 10;
    
    IfOrderExists28();
    IfOrderExists39();
    CustomCode4();
    
}

void IfOrderExists28()
{
    bool exists = false;
    int orderstotal = OrdersTotal();    
    
    for (int i= orderstotal-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == 38)
        {
            exists = true;
        }
    }
    else
    {
        Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
    }
    
    if (exists)
    {
        TechnicalAnalysis2x31();
        
    }
}

void TechnicalAnalysis2x31()
{
    if ((Close[2] > Open[2]) && (Close[1] < Open[1]))
    {
        CloseOrder35();
        
    }
}

void CloseOrder35()
{
    int orderstotal = OrdersTotal();
    int orders = 0;
    int ordticket[90][2];
    
    for (int i = orderstotal-1; i>=0; i--)
    {
        bool sel = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderType() != OP_BUY || OrderSymbol() != Symbol() || OrderMagicNumber() != 38)
        {
            continue;
        }
        ordticket[orders][0] = OrderOpenTime();
        ordticket[orders][1] = OrderTicket();
        orders++;
    }
    if (orders > 1)
    {
        ArrayResize(ordticket,orders);
        ArraySort(ordticket);
    }
    for (i = 0; i < orders; i++)
    {
        if (OrderSelect(ordticket[i][1], SELECT_BY_TICKET) == true)
        {
            bool ret = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(),Slippage, Yellow);
            if (ret == false)
            Print("OrderClose() error - ", ErrorDescription(GetLastError()));
        }
    }
    
}

void IfOrderExists39()
{
    bool exists = false;
    int orderstotal = OrdersTotal();
        
    for (int i=orderstotal-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == 39)
        {
            exists = true;
        }
    }
    else
    {
        Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
    }
    
    if (exists)
    {
        TechnicalAnalysis2x34();
        
    }
}

void TechnicalAnalysis2x34()
{
    if ((Close[2] < Open[2]) && (Close[1] > Open[1]))
    {
        CloseOrder36();
        
    }
}

void CloseOrder36()
{
    int orderstotal = OrdersTotal();
    int orders = 0;
    int ordticket[90][2];
    
    for (int i = orderstotal -1 ; i>=0; i--)
    {
        bool sel = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderType() != OP_SELL || OrderSymbol() != Symbol() || OrderMagicNumber() != 39)
        {
            continue;
        }
        ordticket[orders][0] = OrderOpenTime();
        ordticket[orders][1] = OrderTicket();
        orders++;
    }
    
    if (orders > 1)
    {
        ArrayResize(ordticket,orders);
        ArraySort(ordticket);
    }
    for (i = 0; i < orders; i++)
    {
        if (OrderSelect(ordticket[i][1], SELECT_BY_TICKET) == true)
        {
            bool ret = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(),Slippage, Yellow);
            if (ret == false)
            Print("OrderClose() error - ", ErrorDescription(GetLastError()));
        }
    }
    
}

void CustomCode4()
{
    
    TechnicalAnalysis2x25();
    TechnicalAnalysis2x19();
    
}

void TechnicalAnalysis2x25()
{
    if ((iMA(NULL, NULL,21,0,MODE_EMA,PRICE_CLOSE,current) > iMA(NULL, NULL,50,0,MODE_EMA,PRICE_CLOSE,current)) && (Ask > iMA(NULL, NULL,21,0,MODE_EMA,PRICE_CLOSE,current)))
    {
        TechnicalAnalysis3x26();
        
    }
}

void TechnicalAnalysis3x26()
{
    if ((Close[3] > Open[3]) && (Close[2] > Open[2]) && (Close[1] > Open[1]))
    {
        IfOrderDoesNotExist16();
        
    }
}

void IfOrderDoesNotExist16()
{
    bool exists = false;
    int orderstotal = OrdersTotal();
     
    for (int i = orderstotal -1 ; i>=0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == 38)
        {
            exists = true;
        }
    }
    else
    {
        Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
    }
    
    if (exists == false)
    {
        BuyOrder27();
        IfOrderExists17();
        
    }
}

void BuyOrder27()
{
    
    BuyLots27 = GetLots(Symbol(),ProfitLossfactor); 
    
    RefreshRates();
    
    double SL = Ask - BuyStoploss27*PipValue*Point;
    if (BuyStoploss27 == 0) SL = 0;
    double TP = Ask + BuyTakeprofit27*PipValue*Point;
    if (BuyTakeprofit27 == 0) TP = 0;
    int ticket = -1;
 
    ticket = OrderSend(Symbol(), OP_BUY, BuyLots27, Ask,Slippage, 0, 0, "Buy Renko", 38, 0, Blue);
 
    if (ticket > -1)
    {
        if (true)
        {
            bool sel = OrderSelect(ticket, SELECT_BY_TICKET);
            bool ret = OrderModify(OrderTicket(), OrderOpenPrice(), SL, TP, 0, Blue);
            if (ret == false)
            Print("OrderModify() error - ", ErrorDescription(GetLastError()));
        }
            
    }
    else
    {
        Print("OrderSend() error - ", ErrorDescription(GetLastError()));
    }
}

void IfOrderExists17()
{
    bool exists = false;
    int orderstotal = OrdersTotal();
        
    for (int i=orderstotal-1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == 39)
        {
            exists = true;
        }
    }
    else
    {
        Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
    }
    
    if (exists)
    {
        CloseOrder18();
        
    }
}

void CloseOrder18()
{
    int orderstotal = OrdersTotal();
    int orders = 0;
    int ordticket[90][2];
    
    for (int i=orderstotal-1; i >= 0; i--)
    {
        bool sel = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderType() != OP_SELL || OrderSymbol() != Symbol() || OrderMagicNumber() != 39)
        {
            continue;
        }
        ordticket[orders][0] = OrderOpenTime();
        ordticket[orders][1] = OrderTicket();
        orders++;
    }
    
    if (orders > 1)
    {
        ArrayResize(ordticket,orders);
        ArraySort(ordticket);
    }
    
    for (i = 0; i < orders; i++)
    {
        if (OrderSelect(ordticket[i][1], SELECT_BY_TICKET) == true)
        {
            bool ret = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(),Slippage, Yellow);
            if (ret == false)
            Print("OrderClose() error - ", ErrorDescription(GetLastError()));
        }
    }
    
}

void TechnicalAnalysis2x19()
{
    if ((iMA(NULL, 0,21,0,MODE_EMA,PRICE_CLOSE,current) < iMA(NULL, 0,50,0,MODE_EMA,PRICE_CLOSE,current)) && (Bid < iMA(NULL, NULL,21,0,MODE_EMA,PRICE_CLOSE,current)))
    {
        TechnicalAnalysis3x20();
        
    }
}

void TechnicalAnalysis3x20()
{
    if ((Close[3] < Open[3]) && (Close[2] < Open[2]) && (Close[1] < Open[1]))
    {
        IfOrderDoesNotExist21();
        
    }
}

void IfOrderDoesNotExist21()
{
    bool exists = false;
    int orderstotal = OrdersTotal();    
   
    for (int i=orderstotal - 1; i >= 0; i--)
    
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == 39)
        {
            exists = true;
        }
    }
    else
    {
        Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
    }
    
    if (exists == false)
    {
        SellOrder22();
        IfOrderExists24();
        
    }
}

void SellOrder22()
{


    SellLots22 = GetLots(Symbol(),ProfitLossfactor); 
    
    RefreshRates();
    double SL = Bid + SellStoploss22*PipValue*Point;
    if (SellStoploss22 == 0) SL = 0;
    double TP = Bid - SellTakeprofit22*PipValue*Point;
    if (SellTakeprofit22 == 0) TP = 0;
    int ticket = -1;
 
    ticket = OrderSend(Symbol(), OP_SELL, SellLots22, Bid,Slippage, 0, 0, "Sell Renko", 39, 0, Red);
 
    if (ticket > -1)
    {
        if (true)
        {
            bool sel = OrderSelect(ticket, SELECT_BY_TICKET);
            bool ret = OrderModify(OrderTicket(), OrderOpenPrice(), SL, TP, 0, Red);
            if (ret == false)
            Print("OrderModify() error - ", ErrorDescription(GetLastError()));
        }
            
    }
    else
    {
        Print("OrderSend() error - ", ErrorDescription(GetLastError()));
    }
}

void IfOrderExists24()
{
    bool exists = false;
    int orderstotal = OrdersTotal();  
        
    for (int i=orderstotal - 1; i >= 0; i--)
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
        if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == 38)
        {
            exists = true;
        }
    }
    else
    {
        Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
    }
    
    if (exists)
    {
        CloseOrder23();
        
    }
}

void CloseOrder23()
{
    int orderstotal = OrdersTotal();
    int orders = 0;
    int ordticket[90][2];
    
    for (int i=orderstotal - 1; i >= 0; i--)
    {
        bool sel = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderType() != OP_BUY || OrderSymbol() != Symbol() || OrderMagicNumber() != 38)
        {
            continue;
        }
        ordticket[orders][0] = OrderOpenTime();
        ordticket[orders][1] = OrderTicket();
        orders++;
    }
    if (orders > 1)
    {
        ArrayResize(ordticket,orders);
        ArraySort(ordticket);
    }
    for (i = 0; i < orders; i++)
    {
        if (OrderSelect(ordticket[i][1], SELECT_BY_TICKET) == true)
        {
            bool ret = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(),Slippage, Yellow);
            if (ret == false)
            Print("OrderClose() error - ", ErrorDescription(GetLastError()));
        }
    }
    
}

int deinit()
{
    if (false) ObjectsDeleteAll();
        
    return (0);
}

/////////////////////////////////////////////////
/////////////////////////////////////////////////////////
//  MONEY MANAGEMENT
/////////////////////////////////////////////////////////
////////////////////////////////////////////////////

double getTSSF()
{
   double tradegagnant,tradeperdant;
   double profit, perte, avgwin, avgloss, prcwin, tssf;
 
	int orders=HistoryTotal();
	
	if(orders <= LastXTrades) return(0.0);
	tradegagnant=0.0;
   tradeperdant=0.0;
   profit=0.0;
   perte=0.0;
   avgwin=0.0;
   avgloss=0.0;
   prcwin=0.0;
   tssf=0.0;
   
   
	for(int j=orders-1;j>=orders-LastXTrades;j--)
   {
      if(OrderSelect(j,SELECT_BY_POS,MODE_HISTORY)==False) 
      { 
         Print("Erreur dans l historique!"); 
         break; 
      }

      if(OrderProfit() >= 0)
      {
         tradegagnant= tradegagnant+1.0;
         profit=profit+OrderProfit();
      }
      else
      {
         tradeperdant= tradeperdant+1.0;
         perte=perte-OrderProfit();
      }
   }
   
   if (tradegagnant == 0.0){
      avgwin=0.0;
   }
   else if (orders>LastXTrades){
      avgwin=profit/tradegagnant;
   }
   
   if (tradeperdant == 0.0){
      tssf = 1.0;
      return(tssf);
   }
   else if (orders>LastXTrades){
      avgloss=perte/tradeperdant;
   }
   if (orders>LastXTrades)prcwin=tradegagnant/(tradegagnant+tradeperdant);
   else prcwin= 0.0;
   if (avgloss == 0.0){
      tssf = 1.0;
      return(tssf);
   }
   else if (orders>LastXTrades){
      if(prcwin == 0.1)prcwin= 0.11;
      tssf=avgwin/avgloss*((1.1-prcwin)/(prcwin-0.1)+1);
   }

   return(tssf);
}
//+------------------------------------------------------------------+
//| expert  Div function                                   				|
//| Avoid divide by zero errors													|
//+------------------------------------------------------------------+
double Div(double a,double b,int loc=0)
{
	if(b==0)
	{
		Alert("Divide by zero error! a="+a+" b="+b+", loc="+loc);
		return(0);
	}
	return(a/b);
}

//+------------------------------------------------------------------+
//|StringUpper (used to convert string case  )     						|
//+------------------------------------------------------------------+
string StringUpper(string str)
//+------------------------------------------------------------------+
// Converts any lowercase characters in a string to uppercase
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "THE QUICK BROWN FOX"
//if using capitalise, only the first char is Capitalised
{
  string outstr = "";
  string lower  = "abcdefghijklmnopqrstuvwxyz";
  string upper  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  for(int i=0; i<StringLen(str); i++)  {
    int t1 = StringFind(lower,StringSubstr(str,i,1),0);
    if (t1 >=0)
      outstr = outstr + StringSubstr(upper,t1,1);
    else
      outstr = outstr + StringSubstr(str,i,1);
  }
  return(outstr);
}
//+------------------------------------------------------------------+
//| expert StrToNum function                                        |
//+------------------------------------------------------------------+
double StrToNum(string str)
{
	//+------------------------------------------------------------------+
	// Usage: strips all non-numeric characters out of a string, to return a numeric (double) value
	//  valid numeric characters are digits 0,1,2,3,4,5,6,7,8,9, decimal point (.) and minus sign (-)
  	int    dp   = -1;
  	int    sgn  = 1;
  	double num  = 0.0;
  	for (int i=0; i<StringLen(str); i++)
  	{
    	string s = StringSubstr(str,i,1);
   	if (s == "-")  sgn = -sgn;   else
    	if (s == ".")  dp = 0;       else
    	if (s >= "0" && s <= "9")
    	{
      	if (dp >= 0)  dp++;
      	if (dp > 0)
        	num = num + Div(StrToInteger(s) , MathPow(10,dp),2421);
      else
       	num = num * 10 + StrToInteger(s);
    	}
  	}
  	return(num*sgn);
}
//+------------------------------------------------------------------+
//| expert GetLots function                                          |
//+------------------------------------------------------------------+
double GetLots(string symbol_current,double profitfactor)
{
	
	 double lotstep = MarketInfo(symbol_current,MODE_LOTSTEP);
		
	if(lotstep == 0) return(0.1);
	int    decimals		= MathLog(1 / lotstep) / MathLog(10);
	double AcctFreeMgn 	= AccountEquity();
	int 	 RiskType 		= 0;                            				// default to N lots
	double size, risk;
   
	double TSSFTrigger1=1;
   double TSSFTrigger2=2;
   double TSSFTrigger3=3;
   
   double tssf= getTSSF();
   
	if (StringFind(StringUpper(SizingRule),"B") >= 0)    AcctFreeMgn = AccountBalance();
	if (StringFind(StringUpper(SizingRule),"F") >= 0)    AcctFreeMgn = AccountFreeMargin();
	if (StringFind(SizingRule,"%") >= 0)       RiskType = 1;      // N% AcctFreeMgn
	if (StringFind(SizingRule,"$") >= 0)       RiskType = 2;      // $N amount
 
   double ratio= 1.0+tssf;
   if(tssf > 1.0){
      ratio= 2.0;
   }
   double TickValue = MarketInfo(symbol_current,MODE_TICKVALUE);
   if(Point == 0.001 || Point == 0.00001) TickValue *= 10;
	    
	switch (RiskType)
	{
		case 1  : risk = NormalizeDouble(AcctFreeMgn*ratio*StrToNum(SizingRule)/100,decimals); size= Div(Div(risk, 20,1522), TickValue, 1524);    break;   // calc vol = N% of account equity
		case 2  : risk = NormalizeDouble(StrToNum(SizingRule)*ratio,decimals); 					   size= Div(Div(risk, 20,1523), TickValue, 1525);    break;   // calc vol from entered $amount
		default : risk = NormalizeDouble(StrToNum(SizingRule)*ratio,decimals);                 size= risk;                              break;   // vol is simply no. of lots entered
   }

	double size1 = NormalizeDouble(size,decimals);
	if(size1 < MINLOT) 
	      size1 = MINLOT;
	if(size1 > maxlots) 
	      size1 = maxlots;
      //Print("tssf "+tssf+" ratio "+ratio+" size1 "+size1+" maxlots "+maxlots+" MINLOT "+MINLOT);
	return(size1);
}  

