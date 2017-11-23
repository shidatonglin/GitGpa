//+---------------------------------------------------------------------------------+
//|                                                                                 |
//|           RSI-R2.mq4 - Ver 1.3 @ 04/19/2007 by Bluto                            |
//|                                                                                 |
//| Rev 1.1 - Enhanced Money Mgmt & Optimized RSI Periods Per Pairs                 |
//|                                                                                 |
//| Rev 1.2 - Enhanced RSI_Period handler to allow usage of either pre-determined   |
//|           internal optimized RSI_Period values set in the int init() function   |
//|           or default RSI_Period value via the boolean UseDefaultRSI_Period      |
//|           extern variable.                                                      |
//|           Set UseDefaultRSI_Period = true to use default RSI_Period value when  |            |
//|           performing your own optimizations of RSI_Period via backtesting.      |
//|                                                                                 |
//| Rev 1.3   Added test of Price-Close vs. 200SMA to exit a trade that is moving   |
//|           in the wrong direction.                                               |                                     |
//+---------------------------------------------------------------------------------+
/*In layman's terms, this is how the RSI-R2 Ver 1.1 EA works:

With each new tick, the EA is called and control passes to the init_start() mainline function.

First, we perform the money management option via the "Calc_Money_Management()" function call if the value of the UseMoneyMgmt variable is set to true. This function calculates the appropriate lot size to use based on available equity and the "RiskPercent" setting. If money management is disabled, the value of the default "LotSize" variable is used.

-Then-

Using a daily timeframe, first, get the closing value of RSI three days ago (RSI_Day_1), the closing value of RSI two days ago (RSI_Day_2) and the value of RSI one day ago (RSI_Day_3) . Also, get the closing value of a 200-day simple moving average one day ago (SMA200_Day3). We will analyze the behavior of a short term RSI over the prior three days as our primary buy/sell trigger.

-Then-

Check for Buy Signal: We're looking for a decreasing value of RSI over the past three days into a deeper oversold status as price remains above SMA200.

If the value of RSI_Day_1 < 65 and the value of RSI_Day_2 < RSI_Day_1 and the value of RSI_Day_3 < RSI_Day_2 and the value of Closing Price from one day ago is > SMA200_Day3, we have a Buy signal, so set the boolean Buy Flag (Buy_Mode) to True, otherwise set it to false.

-Then-

Check for Sell Signal: We're looking for an increasing value of RSI over the past three days into a deeper overbought status as price remains below SMA200.

If the value of RSI_Day_1 > 35 and the value of RSI_Day_2 > RSI_Day_1 and the value of RSI_Day_3 > RSI_Day_2 and the value of Closing Price from one day ago is < SMA200_Day3, we have a Sell signal, so set the boolean Sell Flag (Sell_Mode) to True, otherwise set it to false.

-Then-

Before we act on any potential signals that may have fired, we do some housekeeping on any order that may already be open. The EA only allows one sell or one buy order to be open at a time. If we have an open Buy order in progress and the value of RSI_Day_3 > 75, we close the order because RSI is entering extreme overbought status (reversal coming?) If we have an open sell order and the value of RSI_Day_3 < 25, we close the order because RSI is entering extreme oversold status.
The order closures would actually happen on the opening bar of day 4 since we're on a D1 timeframe.

We then update trailing stop using Parabolic SAR. Managing these stops can cause an order to stop out if things get nasty.

-Then-

We now act on any new buy/sell signals:

If we have a new buy signal and there isn't a buy order already open (OpenBuyOrders = 0), we check first to see if a sell order may be open and if so, we close it. Then we simply open a newa buy order and increment the open buy order counter (OpenBuyOrders++). The counter keeps us from opening multiple buy orders since we only want one.

If we have a new sell signal and there isn't a sellorder already open (OpenSellOrders = 0), we check first to see if a buy order may be open and if so, we close it. Then we simply open a new sell order and increment the open sell order counter (OpenSellOrders++). The counter keeps us from opening multiple sell orders since we only want one.

That's it. Control then passes back to MT4 via the last statement of "return(0)" in the init_start() routine until the next tick occurs and calls the EA at which point we repeat the entire process again.

I hope that this helps clarify what the EA is doing under the hood.

-bluto
*/


#property copyright "Bluto"
#property link      "None"

extern double LotSize=10;
extern int    Slippage=3;
extern double StopLoss=0;
extern double TakeProfit=700;
extern double RiskPercent=2.0;
extern bool   UseMoneyMgmt=false;
extern bool   BrokerPermitsFractionalLots = true;
extern bool   UseDefaultRSI_Period = false;
extern int    RSI_Period = 4;
extern double RSI_Overbought_Value = 75.0; 
extern double RSI_Oversold_Value = 25.0; 
int           MagicNumber = 0;
int           ticket;
int           OpenBuyOrders = 0;
int           OpenSellOrders = 0;
int           i;
bool          Buy_Mode = false, Sell_Mode = false;
double        RSI_Day_1 = 0, RSI_Day_2 = 0, RSI_Day_3 = 0, SMA200_Day3 = 0;
double        MM_MinLotSize = 0;
double        MM_MaxLotSize = 0;
double        MM_LotStep = 0;
double        MM_Decimals = 0;
double        MM_OrderLotSize = 0;
int           MM_AcctLeverage = 0;
int           MM_CurrencyLotSize = 0;


int init()
{
   if (Symbol()=="AUDCADm" || Symbol()=="AUDCAD") {MagicNumber=200001;if(UseDefaultRSI_Period==false){RSI_Period=5;}}
   if (Symbol()=="AUDJPYm" || Symbol()=="AUDJPY") {MagicNumber=200002;if(UseDefaultRSI_Period==false){RSI_Period=7;}}
   if (Symbol()=="AUDNZDm" || Symbol()=="AUDNZD") {MagicNumber=200003;if(UseDefaultRSI_Period==false){RSI_Period=6;}}
   if (Symbol()=="AUDUSDm" || Symbol()=="AUDUSD") {MagicNumber=200004;if(UseDefaultRSI_Period==false){RSI_Period=4;}}
   if (Symbol()=="CHFJPYm" || Symbol()=="CHFJPY") {MagicNumber=200005;if(UseDefaultRSI_Period==false){RSI_Period=4;}}
   if (Symbol()=="EURAUDm" || Symbol()=="EURAUD") {MagicNumber=200006;if(UseDefaultRSI_Period==false){RSI_Period=2;}}
   if (Symbol()=="EURCADm" || Symbol()=="EURCAD") {MagicNumber=200007;if(UseDefaultRSI_Period==false){RSI_Period=3;}}
   if (Symbol()=="EURCHFm" || Symbol()=="EURCHF") {MagicNumber=200008;if(UseDefaultRSI_Period==false){RSI_Period=3;}}
   if (Symbol()=="EURGBPm" || Symbol()=="EURGBP") {MagicNumber=200009;if(UseDefaultRSI_Period==false){RSI_Period=2;}}
   if (Symbol()=="EURJPYm" || Symbol()=="EURJPY") {MagicNumber=200010;if(UseDefaultRSI_Period==false){RSI_Period=4;}}
   if (Symbol()=="EURUSDm" || Symbol()=="EURUSD") {MagicNumber=200011;if(UseDefaultRSI_Period==false){RSI_Period=4;}}
   if (Symbol()=="GBPCHFm" || Symbol()=="GBPCHF") {MagicNumber=200012;if(UseDefaultRSI_Period==false){RSI_Period=6;}}  
   if (Symbol()=="GBPJPYm" || Symbol()=="GBPJPY") {MagicNumber=200013;if(UseDefaultRSI_Period==false){RSI_Period=4;}}
   if (Symbol()=="GBPUSDm" || Symbol()=="GBPUSD") {MagicNumber=200014;if(UseDefaultRSI_Period==false){RSI_Period=3;}}
   if (Symbol()=="NZDJPYm" || Symbol()=="NZDJPY") {MagicNumber=200015;if(UseDefaultRSI_Period==false){RSI_Period=6;}}
   if (Symbol()=="NZDUSDm" || Symbol()=="NZDUSD") {MagicNumber=200016;if(UseDefaultRSI_Period==false){RSI_Period=7;}}
   if (Symbol()=="USDCHFm" || Symbol()=="USDCHF") {MagicNumber=200017;if(UseDefaultRSI_Period==false){RSI_Period=4;}}
   if (Symbol()=="USDJPYm" || Symbol()=="USDJPY") {MagicNumber=200018;if(UseDefaultRSI_Period==false){RSI_Period=4;}}
   if (Symbol()=="USDCADm" || Symbol()=="USDCAD") {MagicNumber=200019;if(UseDefaultRSI_Period==false){RSI_Period=2;}}
   if (MagicNumber==0) {MagicNumber = 200999;}  
 
 return(0);
}

int deinit()
{
 return(0);
}

int start()
{ 

  Calc_Money_Management();
  
  SMA200_Day3 = iMA(NULL,PERIOD_D1,200, 0, MODE_SMA, PRICE_CLOSE, 1);

  RSI_Day_1 = iRSI(NULL, PERIOD_D1, RSI_Period, PRICE_CLOSE, 3);
  RSI_Day_2 = iRSI(NULL, PERIOD_D1, RSI_Period, PRICE_CLOSE, 2);
  RSI_Day_3 = iRSI(NULL, PERIOD_D1, RSI_Period, PRICE_CLOSE, 1);
  
  if (RSI_Day_1 < 65 && RSI_Day_2 < RSI_Day_1 && RSI_Day_3 < RSI_Day_2 && Close[1] > SMA200_Day3) 
   {
    Buy_Mode=true;
   } else {
    Buy_Mode=false;
   } 
   
   if (RSI_Day_1 > 35 && RSI_Day_2 > RSI_Day_1 && RSI_Day_3 > RSI_Day_2 && Close[1] < SMA200_Day3) 
   {
    Sell_Mode=true;
   } else {
    Sell_Mode=false;
   } 

  if (OpenBuyOrders == 1 && (RSI_Day_3 > RSI_Overbought_Value || Close[1] < SMA200_Day3))
   {
     CloseLongs(MagicNumber);
     OpenBuyOrders = 0;   
   }
   
   if (OpenSellOrders == 1 && (RSI_Day_3 < RSI_Oversold_Value || Close[1] > SMA200_Day3))
   {
     CloseShorts(MagicNumber);
     OpenSellOrders = 0;   
   }
     
     
//----- Count number of existing open buy & sell orders; update trailing stops.
  
  OpenBuyOrders=0;
  OpenSellOrders=0;
   
      
// Manage Paraolic SAR 

  for (i = 0; i <= OrdersTotal(); i++)
   {
    OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
    if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == MagicNumber))
     {
      if (OrderType() == OP_BUY)
       {
        OpenBuyOrders++;
        if ((iSAR(NULL,0,0.02,0.2,1) > OrderStopLoss()) && (Bid > iSAR(NULL,0,0.02,0.2,1)) && (OrderOpenPrice() < iSAR(NULL,0,0.02,0.2,1)) && (iSAR(NULL,0,0.02,0.2,1) > iSAR(NULL,0,0.02,0.2,2)))
         {
          OrderModify(OrderTicket(),OrderOpenPrice(),iSAR(NULL,0,0.02,0.2,1),OrderTakeProfit(),0,Blue);
          Print("Order # ",OrderTicket()," updated at ",Hour(),":",Minute(),":",Seconds());
          return(0);
         }
       }
      if (OrderType() == OP_SELL)
       {
        OpenSellOrders++;
        if ((iSAR(NULL,0,0.02,0.2,1) < OrderStopLoss()) && (Ask < iSAR(NULL,0,0.02,0.2,1)) && (OrderOpenPrice() > iSAR(NULL,0,0.02,0.2,1)) && (iSAR(NULL,0,0.02,0.2,1) < iSAR(NULL,0,0.02,0.2,2)))
         {
          OrderModify(OrderTicket(),OrderOpenPrice(),iSAR(NULL,0,0.02,0.2,1),OrderTakeProfit(),0,Blue);
          Print("Order # ",OrderTicket()," updated at ",Hour(),":",Minute(),":",Seconds());
          return(0);
         }
       }
     }
   }


//----- Generic order handler.
//----- If we have a new buy signal, close existing sell orders; if we have a new sell signal, close existing buy orders; reset order counters.
//----- Next, create new buy or sell order.
         
  if (Buy_Mode==true && OpenBuyOrders==0) 
   {
    if(OpenSellOrders > 0)
     {
      CloseShorts(MagicNumber);
      OpenSellOrders = 0; 
     } 
    if(OpenBuyOrders == 0)
     {  
      ticket = OpenPendingOrder(OP_BUY,MM_OrderLotSize,Ask,Slippage,Bid,StopLoss,TakeProfit,"RSI-R2",MagicNumber,0,Lime);
      if(ticket<0)
       {
        Print("OrderSend failed with error #",GetLastError());
        return(0);
       }
      else
       {
        OpenBuyOrders++;
       }    
     }
   }
   
  if (Sell_Mode==true && OpenSellOrders==0) 
   {
    if(OpenBuyOrders > 0)
     {
      CloseLongs(MagicNumber);
      OpenBuyOrders = 0;
     }  
    if (OpenSellOrders == 0) 
     {
      ticket = OpenPendingOrder(OP_SELL,MM_OrderLotSize,Bid,Slippage,Ask,StopLoss,TakeProfit,"RSI-R2",MagicNumber,0,HotPink);
      if(ticket<0)
       {
        Print("OrderSend failed with error #",GetLastError());
        return(0);
       }
      else
       {
        OpenSellOrders++;
       }    
     }
   }
   
  return(0);
}

//----- Order Processing Functions

void CloseLongs(int MagicNumber)
{
 int trade;
 for(trade=OrdersTotal()-1;trade>=0;trade--)
 {
  if(OrderSelect(trade,SELECT_BY_POS,MODE_TRADES)==false)
   continue;

  if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=MagicNumber)
   continue;
   
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber)
  if(OrderType()==OP_BUY)
   OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Blue);
 }//for
}

void CloseShorts(int MagicNumber)
{
 int trade;
 for(trade=OrdersTotal()-1;trade>=0;trade--)
 {
  if(OrderSelect(trade,SELECT_BY_POS,MODE_TRADES)==false)
   continue;

  if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=MagicNumber)
   continue;
   
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber)
  if(OrderType()==OP_SELL)
   OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Red);
 }//for
}

int OpenPendingOrder(int pType,double pLots,double pLevel,int sp, double pr, int sl, int tp,string pComment,int pMagic,datetime pExpiration,color pColor)
{
  int ticket=0;
  int err=0;
  int c = 0;
  int NumberOfTries = 10;
  switch (pType)
  {
      case OP_BUY:
         for(c = 0 ; c < NumberOfTries ; c++)
         {  
            RefreshRates();
            ticket=OrderSend(Symbol(),OP_BUY,pLots,Ask,sp,StopLong(Bid,sl),TakeLong(Bid,tp),pComment,pMagic,pExpiration,pColor);
            if (ticket > 0) break;
            err=GetLastError();
            if(err==0)
            { 
               break;
            }
            else
            {
               if(err==4 || err==137 ||err==146 || err==136) //Busy errors
               {
                  Sleep(5000);
                  continue;
               }
               else //normal error
               {
                  Print("Error Code= ", err);
                  break;
               }  
            }
         } 
         break;
      case OP_SELL:
         for(c = 0 ; c < NumberOfTries ; c++)
         {
            RefreshRates();
            ticket=OrderSend(Symbol(),OP_SELL,pLots,Bid,sp,StopShort(Ask,sl),TakeShort(Ask,tp),pComment,pMagic,pExpiration,pColor);
            if (ticket > 0) break;
            err=GetLastError();
            if(err==0)
            { 
               break;
            }
            else
            {
               if(err==4 || err==137 ||err==146 || err==136) //Busy errors
               {
                  Sleep(5000);
                  continue;
               }
               else //normal error
               {
                  Print("Error Code= ", err);
                  break;
               }  
            }
         } 
         break;
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


void Calc_Money_Management()
 {
  MM_AcctLeverage = AccountLeverage();
  MM_MinLotSize = MarketInfo(Symbol(),MODE_MINLOT);
  MM_MaxLotSize = MarketInfo(Symbol(),MODE_MAXLOT);
  MM_LotStep = MarketInfo(Symbol(),MODE_LOTSTEP);
  MM_CurrencyLotSize = MarketInfo(Symbol(),MODE_LOTSIZE);

  if(MM_LotStep == 0.01) {MM_Decimals = 2;}
  if(MM_LotStep == 0.1) {MM_Decimals = 1;}

  if(BrokerPermitsFractionalLots == true)
   {
    if (UseMoneyMgmt == true)
     {
      MM_OrderLotSize = AccountEquity() * (RiskPercent * 0.01) / (MM_CurrencyLotSize / MM_AcctLeverage);
      MM_OrderLotSize = StrToDouble(DoubleToStr(MM_OrderLotSize,MM_Decimals));
      if (MM_OrderLotSize < MM_MinLotSize) {MM_OrderLotSize = MM_MinLotSize;}
      if (MM_OrderLotSize > MM_MaxLotSize) {MM_OrderLotSize = MM_MaxLotSize;}
     }
    else
     {
      MM_OrderLotSize = LotSize;
      if (MM_OrderLotSize < MM_MinLotSize) {MM_OrderLotSize = MM_MinLotSize;}
      if (MM_OrderLotSize > MM_MaxLotSize) {MM_OrderLotSize = MM_MaxLotSize;}
     }
   }
  else
   {
    if (UseMoneyMgmt == true)
     {
      MM_OrderLotSize = AccountEquity() * (RiskPercent * 0.01) / (MM_CurrencyLotSize / MM_AcctLeverage);
      MM_OrderLotSize = MathRound(MM_OrderLotSize);
      if (MM_OrderLotSize < MM_MinLotSize) {MM_OrderLotSize = MM_MinLotSize;}
      if (MM_OrderLotSize > MM_MaxLotSize) {MM_OrderLotSize = MM_MaxLotSize;}
     }
    else
     {
      MM_OrderLotSize = LotSize;
      if (MM_OrderLotSize < MM_MinLotSize) {MM_OrderLotSize = MM_MinLotSize;}
      if (MM_OrderLotSize > MM_MaxLotSize) {MM_OrderLotSize = MM_MaxLotSize;}
     }
   }   
  return(0);   
 }

