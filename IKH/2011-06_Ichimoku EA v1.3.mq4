//+------------------------------------------------------------------+
//|                                             Ichimoku EA v1.3.mq4 |
//|           Copyright © 2011, forexBaron.net - All rights reserved |
//|                                            http://forexBaron.net |
//|   based on an EA by Mark Johnson, Copyright © 2009, Mark Johnson.|
//+------------------------------------------------------------------+
/*
CREDITS: Many thanks especially to Steve Hopwood (http://www.forexfactory.com/stevehopwood)
and Mark Johnson (Scooby-Doo, http://www.forexfactory.com/scooby-doo) for their contributions and 
their help to lots of people at forexfactory.com!
*/

/*
  To learn more about the ichimoku, just visit
  http://www.forexfabrik.de/forex-grundlagen/ichimoku-kinko-hyo/ (german)
  or http://fxtrade.oanda.com/learn/forex-indicators/ichimoku-kinko-hyo (english)
  or http://www.forex-tsd.com/general-discussion/157-ichimoku-2.html (english)
*/
//---
/*
ichimoku trading - some recommended settings for different timeframes:
D1 settings:
============
9,26,52
7,22,44
5,10,20

H1 settings:
============
120,240,480
6,12,24
12,24,120

M30 settings:
=============
8,26,130

M5 settings:
============
72,144,288
*/

#property copyright "copyright © 2011, forexBaron.net"
#property link      "http://forexBaron.net"
#property show_inputs
#define EANAME "#2011-06_Ichimoku EA v1.3"

//+------------------------------------------------------------------+
//| expert External variables                                        |
//+------------------------------------------------------------------+
extern string tradealhint = "if false, no trades will be opened:";
extern bool tradeAllowed = true;
extern double lotSize = 0.1;
extern int    magic = 2011646;
extern string ordercomment = "Ichimoku EA v1.3";
extern int maxOpenOrders = 5;
extern string gmthint1 = "your GMT timezone (e.g. 6, -7, etc.):";
extern int GMTShift = 6;
extern string closehint = "stop trading on friday?";
extern bool stopTradingOnFriday = true;
extern string closehint1 = "if true, at which time (GMT)?";
extern int fridayCloseTime = 13;
extern string gmthint12 = "default: 23";
extern int startTradingOnSundayGMTtime = 23;
extern bool showScreenComments = true;
extern string erroralerthint = "show error and message alerts?";
extern bool errorAlerts = false;
extern string pairhint = "trade the pair of the current chart only?";
extern bool useCurrentChartPair = false;
extern string hl0 = "+--- trade management:";
extern bool useATRforTP = true;
extern bool useATRforSL = true;
extern string tpslhint = "if false, enter fixed pips amount:";
extern int fixedTP = 10;
extern int fixedSL = 30;
extern int atrTPmultiplier = 3;
extern int atrSLmultiplier = 3;
extern int atrCalcTF = 15;
extern int atrCalcPeriod = 14;
extern string minprofithint = "Close Orders at minimum Profit?";
extern bool closeOrdersAtMinProfit = false;
extern double minProfit = 5.00;
extern string maxlosshint = "Close Orders at maximum loss?";
extern bool closeOrdersAtMaxLoss = false;
extern double maxLoss = 5.00;
extern string behint = "set to BreakEven?";
extern bool setToBreakEven = true;
extern int BreakEvenPips = 6;
extern int setToBEafterPips = 10;
//------------------------------ external parameters: --------------+
extern string hl1 = "+--- EA specific parameters:";
extern string ihint0 = "Tenkan Sen Period:";
extern int tenkanSen = 8; // 7
extern string ihint1 = "Kijun Sen Period:";
extern int kijunSen = 26; // 22
extern string ihint2 = "Senkou Span B Period:";
extern int senkouSpanB = 130; // 44
extern string hhint1 = "++---------------------------------------------++";
extern string ignhint0 = "ignore Kijun Signals?";
extern bool ignoureKijun = false;
extern string ignhint1 = "ignore Tenkan Signals?";
extern bool ignoreTenkan = false;
extern string ignhint2 = "ignore Senkou Signals?";
extern bool ignoreSenkou = false;
extern string ignhint3 = "ignore Chikou Signals?";
extern bool ignoreChikou = false;
extern string kumohint = "ignore kumo if width less than:";
extern double ignoreKumoIfWidthUnder = 0.0; // 0.0005
extern string tenkankumohint = "tenkan cross in/over/under kumo";
extern string tenkankumohint1 = "which signals should be used?";
extern string tenkankumohint2 = "(to use it, ignoreTenkan and";
extern string tenkankumohint3 = "ignoreSenkou must be FALSE!)";
extern string tenkankumohint4 = "0 : ALL / 1 : NORMAL/STRONG";
extern string tenkankumohint5 = "2 : ONLY STRONG SIGNALS";
extern int tenkanKumoMode = 1;
extern string chikkuhint = "same for the chikou span:";
extern int chikouKumoMode = 1;
extern string hhint2 = "++---------------------------------------------++";
extern string choicehint = "use Open Prices (true) or EMA?";
extern bool useOpenPrice = true;
extern string emahint = "settings for ema (if used instead of price)";
extern int emaPeriod = 1;
extern int emaMethod = 0;
extern int emaShift = 0;
extern int emaAppliedPrice = 0;
extern string hhint3 = "++---------------------------------------------++";
extern string tfhint = "timeFrame periods in minutes:";
extern int timeFrame = 30;
extern string tfhint1 = "use second timeFrame for";
extern string tfhint2 = "trend confirmation?";
extern bool useSecondTFalso = false;
extern int timeFrame1 = 60;

//------------------------------------------------+
string chikouKumoComment = "";
//string ichiTrend = "NONE";
//---

//------------------------------------------------+
string commentText;

//+------------------------------------------------------------------+
//| expert Internal variables                                        |
//+------------------------------------------------------------------+

//string pairTrend[] = {""};
string pairs[] = {"EURUSD","EURGBP","EURCHF","GBPUSD",
                  "CHFJPY","AUDUSD","EURJPY","AUDJPY",
                  "EURAUD","USDCAD","USDCHF","USDJPY",
                  "GBPCHF","GBPCAD","AUDCAD"};
string suffix;
bool   found;
bool   news;
bool   allowed;
double balance;
double price;
int    order;
string copyrightNotice  = "Copyright © 2011, forexBaron.net All rights reserved.";

//+------------------------------------------------------------------+
//| expert Initialization function                                   |
//+------------------------------------------------------------------+

int init()
  {

    balance = AccountBalance();
    suffix  = StringSubstr(Symbol(),6,StringLen(Symbol())-6);
    string cursuffix = StringSubstr(Symbol(),7,StringLen(Symbol())-7);

/*
      for(int a = 0; a < ArraySize(pairs); a++)
        {
          pairs[a] = pairs[a] + suffix; 
          //pairTrend[a] = "FLAT";
          //pairTrendB4[a] = "FLAT";
        }
*/
       // use default Pairs
       if (!useCurrentChartPair)
        {
         for(int a = 0; a < ArraySize(pairs); a++)
          {
           pairs[a] = pairs[a] + suffix;
          }
        }
        // use only the pair of the current chart
       else if (useCurrentChartPair)
         {
          ArrayResize(pairs,1);
          pairs[0] = Symbol();
         }
    // END check which pairs to trade and extract pairs to trade

    if (showScreenComments) Comment("\nWaiting for tick update on ",pairs[0]," ...");

    return(0);
    
  }
  
//+------------------------------------------------------------------+
//| expert Deinitialization function                                 |
//+------------------------------------------------------------------+

int deinit()
  {
    Comment("");
    return(0);
  }
  
//+------------------------------------------------------------------+
//| expert Start function                                            |
//+------------------------------------------------------------------+

int start()
  {

    //double Lots = NormalizeDouble(balance/50000,1);
    double Lots = lotSize;
    double MinLots  = MarketInfo(Symbol(),MODE_MINLOT);
    double MaxLots  = MarketInfo(Symbol(),MODE_MAXLOT);
    if(Lots < MinLots) Lots = MinLots;
    if(Lots > MaxLots) Lots = MaxLots;
 
    commentText = StringConcatenate("\n",EANAME," | ",copyrightNotice);
    commentText = commentText + StringConcatenate("\n","  leverage: 1:",AccountLeverage()," | Account free margin ",DoubleToStr(AccountFreeMargin(),2)," ",AccountCurrency()," | AccountProfit: ",AccountProfit()," ",AccountCurrency(),"");
    commentText = commentText + StringConcatenate("\n"," GMT day: ",daynumberToString(gmtTime(GMTShift,1))," | GMT hour: ",gmtTime(GMTShift,0)," | Your local hour: ",TimeHour(TimeLocal())," (",TimeToStr(TimeLocal(), TIME_DATE|TIME_MINUTES|TIME_SECONDS),")");
    
    string minProfitStr, maxLossStr;
    if (closeOrdersAtMinProfit) minProfitStr = DoubleToStr(minProfit,2);
     else minProfitStr = "%";
    if (closeOrdersAtMaxLoss) maxLossStr = DoubleToStr(maxLoss,2);
     else maxLossStr = "%";
     commentText = commentText + StringConcatenate("\n","  close orders at min. profit: ",minProfitStr," ",AccountCurrency()," | max. loss: ",maxLossStr," ",AccountCurrency(),"");

    if (stopTradingOnFriday)
     {
       /* do not trade on Friday past GMT 11:59,
          do not trade sunday before 24 o'clock GMT,
          do not trade Saturday ever */
      if ((gmtTime(GMTShift,1) == 5 && gmtTime(GMTShift,0) >= fridayCloseTime)
           || (gmtTime(GMTShift,0) == 0 && gmtTime(GMTShift,0) < startTradingOnSundayGMTtime)
           || (gmtTime(GMTShift,1) == 6))
          {
           tradeAllowed = false;
          }
     }
    
    if (!tradeAllowed) commentText = commentText + StringConcatenate("\n","  .:: TRADING NOT ALLOWED","\n");
     else if (tradeAllowed) commentText = commentText + StringConcatenate("\n","  .:: TRADING ALLOWED","\n");

    if (useSecondTFalso) commentText = commentText + StringConcatenate("  TF:",timeFrame," | TF1:",timeFrame1,"\n");
     else if (!useSecondTFalso) commentText = commentText + StringConcatenate("  TF:",timeFrame,"\n");
    commentText = commentText + StringConcatenate("  open orders: ",getOrdersPerMagic(magic)," | max. open orders: ",maxOpenOrders," | pairs to trade: ",ArraySize(pairs),"\n");

    for(int c = 0; c < ArraySize(pairs); c++)
      {
        checkForOpenAndClose(pairs[c],timeFrame,Lots);
        if (TradeExist(pairs[c]) == true)
         {
          if (setToBreakEven) checkForBreakEven(pairs[c],magic,BreakEvenPips);
          
          // check if NO SL/TP is set:
          modifyNoMagicTrades(atrCalcTF, atrCalcPeriod,atrTPmultiplier,atrSLmultiplier,magic);
          
          // check if close order at min. profit is selected:
           if (closeOrdersAtMinProfit == true) checkForCloseOrdersAtMinProfit(pairs[c],magic,CLR_NONE,minProfit);
           if (closeOrdersAtMaxLoss == true)  checkForCloseOrdersAtMaxLoss(pairs[c],magic,CLR_NONE,maxLoss);
         }
      }
    if (showScreenComments) Comment(commentText);

//---
    return(0);
  }
  

//+------------------------------------------------------------------+
//| expert TradeClose function                                       |
//+------------------------------------------------------------------+

void TradeClose(string symbol, int dir)
  {

    for(int b = OrdersTotal(); b >= 0; b--)
      {
        if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES) == true)
          {
            if(OrderSymbol() == symbol && OrderType() == dir && OrderMagicNumber() == magic)
              {
                order = -1;
                while(order < 0)
                  {
                    RefreshRates();
                    order = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),50,CLR_NONE);
                    Sleep(10);
                  }
              }
          }
      }

  }

//+------------------------------------------------------------------+
//| expert getOrdersPerMagic function                                |
//+------------------------------------------------------------------+ 
// returns amount of open orders by magicnumber

int getOrdersPerMagic(int magicNumber)
  {
    int Orders;
    for(int e = 0; e < OrdersTotal(); e++)
      {
        if(OrderSelect(e,SELECT_BY_POS,MODE_TRADES))
          {
            if(OrderMagicNumber() == magicNumber)
              {
                Orders++;
              }
          }
      }
    return(Orders);
  }

//+------------------------------------------------------------------+
//| expert TradeExists function                                      |
//+------------------------------------------------------------------+

bool TradeExist(string symbol)
  {

    found = false;

    for(int d = 0; d <= OrdersTotal(); d++)
      {
        if(OrderSelect(d,SELECT_BY_POS,MODE_TRADES) == true)
          {
            if(OrderSymbol() == symbol && OrderMagicNumber() == magic)
              {
                found = true;
              }
          }
      }

    return(found);

  }

//+------------------------------------------------------------------+
//| expert SendOrder function                                        |
//+------------------------------------------------------------------+  

void SendOrder(string symbol, int dir, double lots)
  {
    
    price = 0;
    order = -1;
    int ticket;
    double sl, tp;
    
    if(dir == OP_BUY)
      {
        //while(order < 0)
        //  {
            while(IsTradeContextBusy()) Sleep(100);
            RefreshRates();
            price = MarketInfo(symbol,MODE_ASK);
             //sl = calcTPSL(Pairs[b],OP_BUY,0,0,atrSLmultiplier,ATRtimeframe,ATRperiod,true,0);
             if (useATRforSL) sl = calcTPSL(symbol,OP_BUY,0,0,atrSLmultiplier,atrCalcTF,atrCalcPeriod,true,0);
              else if (!useATRforSL) sl = calcTPSL(symbol,OP_BUY,fixedSL,fixedTP,0,0,0,false,0);
              
             if (useATRforTP) tp = calcTPSL(symbol,OP_BUY,0,0,atrTPmultiplier,atrCalcTF,atrCalcPeriod,true,1);
              else if (!useATRforTP) tp = calcTPSL(symbol,OP_BUY,fixedSL,fixedTP,0,0,0,false,1);
            order = OrderSend(symbol,dir,lots,price,30,0,0,ordercomment,magic,0,CLR_NONE);
            Sleep(10);
         // }
             while(IsTradeContextBusy()) Sleep(100);
             RefreshRates();
             if (order > 0)
              {
               OrderSelect(order,SELECT_BY_TICKET);
               // ticket = OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Blue);
               if (tp != 0 || sl != 0) ticket = OrderModify(order,OrderOpenPrice(),sl,tp,OrderExpiration(),CLR_NONE); // OrderTakeProfit()
              }
      }
      
    if(dir == OP_SELL)
      {
        //while(order < 0)
          //{
            while(IsTradeContextBusy()) Sleep(100);
            RefreshRates();
            price = MarketInfo(symbol,MODE_BID);
             if (useATRforSL) sl = calcTPSL(symbol,OP_SELL,0,0,atrSLmultiplier,atrCalcTF,atrCalcPeriod,true,0);
              else if (!useATRforSL) sl = calcTPSL(symbol,OP_SELL,fixedSL,fixedTP,0,0,0,false,0);
             if (useATRforTP) tp = calcTPSL(symbol,OP_SELL,0,0,atrTPmultiplier,atrCalcTF,atrCalcPeriod,true,1);
              else if (!useATRforTP) tp = calcTPSL(symbol,OP_SELL,fixedSL,fixedTP,0,0,0,false,1);
            order = OrderSend(symbol,dir,lots,price,30,0,0,ordercomment,magic,0,CLR_NONE);
            Sleep(10);
          //}
             while(IsTradeContextBusy()) Sleep(100);
             RefreshRates();
            if (order > 0)
              {
               OrderSelect(order,SELECT_BY_TICKET);
               if (tp != 0 || sl != 0) ticket = OrderModify(order,OrderOpenPrice(),sl,tp,OrderExpiration(),CLR_NONE); // OrderTakeProfit()
              }
      }
//---

   if (order < 0)
    {
      int err = GetLastError();
      if (errorAlerts) Alert(symbol," order send failed, error #",err,"");
      Print(symbol," order send failed, error #",err,"");
     return(false);
    }//if (ticket < 0)
   if (ticket < 0)
    {
      err = GetLastError();
      if (errorAlerts) Alert(symbol," ordermodify failed, error #",err,"");
      Print(symbol," ordermodify failed, error #",err,"");
     return(false);
    }//if (ticket < 0)
   
  
//---
  }

//+------------------------------------------------------------------+
//| expert News function                                             |
//+------------------------------------------------------------------+  

bool NewsExist(string symbol)
  {
  
    news = false;
    
    int minutesSincePrevEvent =
      iCustom(NULL, 0, "Economic News", symbol, true, false, false, true, true, 1, 0);

    int minutesUntilNextEvent =
      iCustom(NULL, 0, "Economic News", symbol, true, false, false, true, true, 1, 1);

    if((minutesUntilNextEvent <= 45) || 
       (minutesSincePrevEvent <= 15))
      {
        news = true;
      }
      
    return(news);

  }
//------------------------- EA main function:

void checkForOpenAndClose(string symbol,int timeFrame,double Lots)
 {
   string tradeTrigger = "NONE";
   string closeTrigger = "NONE";

//-------- start indicator check -------------------+

//--- old function ichimoku was here
/*
mode 0: return ichiTrend (default)
mode 1: return kijunTrend
mode 2: return tenkanTrend
mode 3: return senkouTrend
mode 4: return chickouTrend
*/
string ichiTrendTF1 = getIchiTrend(symbol,timeFrame,0);
string ichiTrendTF2 = getIchiTrend(symbol,timeFrame1,0);


  //commentText = commentText + StringConcatenate("\n",symbol," :  tradeSignal: ",ichiTrendTF1,"|",ichiTrendTF2," (tenk: ",tenkanTrend, " | kij: ",kijunTrend," | senk: ",senkouTrend," | chik: ",chikouTrend,"");
  if (useSecondTFalso && (ichiTrendTF1 == ichiTrendTF2)) commentText = commentText + StringConcatenate("\n",symbol," :  tradeSignal: ",ichiTrendTF1," | time to bar close: ",timeToBarClose(symbol,timeFrame,0,0),"m : ",timeToBarClose(symbol,timeFrame,0,1),"s");
   else if (!useSecondTFalso) commentText = commentText + StringConcatenate("\n",symbol," :  tradeSignal: TF(",timeFrame,"): ",ichiTrendTF1," | time to bar close: ",timeToBarClose(symbol,timeFrame,0,0),"m : ",timeToBarClose(symbol,timeFrame,0,1),"s");
    else commentText = commentText + StringConcatenate("\n",symbol," :  tradeSignal: TF(",timeFrame,"): ",ichiTrendTF1," | TF1(",timeFrame1,"): ",ichiTrendTF2," | time to bar close: ",timeToBarClose(symbol,timeFrame,0,0),"m : ",timeToBarClose(symbol,timeFrame,0,1),"s");

bool newBarOpened = false;
newBarOpened = isNewBarVarVolume(symbol,timeFrame,0,1);

if (!useSecondTFalso) ichiTrendTF2 = "LONG";
if (ichiTrendTF1 == "LONG" && ichiTrendTF2 == "LONG" && newBarOpened)
{
tradeTrigger = "BUY";
closeTrigger = "CLOSE SELL";
}

if (!useSecondTFalso) ichiTrendTF2 = "SHORT";
if (ichiTrendTF1 == "SHORT" && ichiTrendTF2 == "SHORT" && newBarOpened)
{
tradeTrigger = "SELL";
closeTrigger = "CLOSE BUY";
}
//--------------- END ICHIMOKU
 
//-------- end indicator check -------------------+

        // Close?
         if(closeTrigger == "CLOSE SELL") TradeClose(symbol,OP_SELL); //  && tradeAllowed
         if(closeTrigger == "CLOSE BUY") TradeClose(symbol,OP_BUY); //  && tradeAllowed

        // Open new order?
         // old: OrdersTotal() < maxOpenOrders
        if(getOrdersPerMagic(magic) < maxOpenOrders
           && tradeAllowed
           && tradeTrigger == "BUY")
          {
            if(errorAlerts && TradeExist(symbol) == false) Alert(symbol," : OPEN BUY ORDER");
            if(TradeExist(symbol) == false) SendOrder(symbol,OP_BUY,Lots);
          }
 
         // old: OrdersTotal() < maxOpenOrders
        if(getOrdersPerMagic(magic) < maxOpenOrders
           && tradeAllowed
           && tradeTrigger == "SELL")
          {
            if(errorAlerts && TradeExist(symbol) == false) Alert(symbol," : OPEN SELL ORDER");
            if(TradeExist(symbol) == false) SendOrder(symbol,OP_SELL,Lots);
          }
 }
//+------------------------------------------------------------------+ 
//| Expert function checkForCloseOrdersAtMinProfit                   |
//+------------------------------------------------------------------+ 
// e.g. checkForCloseOrdersAtMinProfit(Pairs[b],Magic,minProfit,0);
// mode = 0: close single order at minprofit
// mode = 1: close all orders if accountprofit > minproft
int checkForCloseOrdersAtMinProfit(string symbol,int magicNumber,color tradeArrowColor,double minProfit)
 {
   RefreshRates();
   int cnt;
   int total = OrdersTotal();
   int ticket;
   
   double moneyAmount;
   moneyAmount = NormalizeDouble(OrderProfit() + OrderSwap() + OrderCommission(),2);
   
        for (cnt = 0 ; cnt <= total ; cnt++)
            {
               OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
               if (OrderMagicNumber() == magicNumber && OrderSymbol() == symbol && (moneyAmount > minProfit))
               { 
                   if(OrderType()==OP_BUY)
                     ticket = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5000,tradeArrowColor); // MarketInfo(OrderSymbol(),MODE_BID) OrderClosePrice()
                   if(OrderType()==OP_SELL) 
                     ticket = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5000,tradeArrowColor); // MarketInfo(OrderSymbol(),MODE_ASK)
                   // if(OrderType()>OP_SELL) OrderDelete(OrderTicket());
                }
            }
 }
//+------------------------------------------------------------------+ 
//| Expert function checkForCloseOrdersAtMaxLoss                     |
//+------------------------------------------------------------------+ 
// e.g. checkForCloseOrdersAtMaxLoss(Pairs[b],Magic,maxLoss);
// mode = 0: close single order at maxloss
// mode = 1: close all orders if accountprofit > maxloss
int checkForCloseOrdersAtMaxLoss(string symbol,int magicNumber,color tradeArrowColor,double maxLoss)
 {
   RefreshRates();
   int cnt;
   int total = OrdersTotal();
   int ticket;
   
   double moneyAmount, maxLossAmount;
   maxLossAmount = maxLoss - (2 * maxLoss);
   moneyAmount = NormalizeDouble(OrderProfit() + OrderSwap() + OrderCommission(),2);
   
        for (cnt = 0 ; cnt <= total ; cnt++)
            {
               OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
               if ((OrderMagicNumber() == magicNumber) && (OrderSymbol() == symbol) && (moneyAmount < maxLossAmount))
               { 
                   if(OrderType()==OP_BUY)
                     ticket = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5000,tradeArrowColor); // MarketInfo(OrderSymbol(),MODE_BID) OrderClosePrice()
                   if(OrderType()==OP_SELL) 
                     ticket = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5000,tradeArrowColor); // MarketInfo(OrderSymbol(),MODE_ASK)
                   // if(OrderType()>OP_SELL) OrderDelete(OrderTicket());
                }
            }
 }
//+------------------------------------------------------------------+
//| expert Function: calcTP                                          |
//+------------------------------------------------------------------+  
// mode = 0 : calculate stoploss
// mode = 1 : calculate takeprofit
double calcTPSL(string symbol, int type, int stoplossPips, int takeprofitPips, int atrMultiplier, int atrTF, int atrPeriod, bool useATR, int mode)
  {
   RefreshRates();
   
   double price;
   double sl;
   double tp;
   double point = MarketInfo(symbol,MODE_POINT);
   double digit = MarketInfo(symbol,MODE_DIGITS);
   double spread = MarketInfo(symbol,MODE_SPREAD);
   
   double multiplier;
   if(digit == 2 || digit == 4) multiplier = 1;
   if(digit == 3 || digit == 5) multiplier = 10;
   if(digit == 6) multiplier = 100;   
   if(digit == 7) multiplier = 1000;
   //point*=multiplier;
   // end adjust for 5 digit brokers    

     /* old:
     stoplossPips = iATR(FX[b],PERIOD_D1,14,0); // for buy: (Price - iATR(FX[b],PERIOD_D1,14,0)) * multiplier;
     takeprofitPips = iATR(FX[b],PERIOD_D1,14,0); //        (Price + iATR(FX[b],PERIOD_D1,14,0)) * multiplier;
     */
     // old: int atrTPmultiplier = 2; int atrSLmultiplier = 4;
     // double ATRtakeprofitPips = atrMultiplier * iATR(symbol,atrTF,atrPeriod,0)/MarketInfo(symbol,MODE_POINT); // 2 * iATR...
     // double ATRstoplossPips = atrMultiplier * iATR(symbol,atrTF,atrPeriod,0)/MarketInfo(symbol,MODE_POINT); // 4 * iATR...
     
     if (useATR == true)
      {
       stoplossPips = atrMultiplier * iATR(symbol,atrTF,atrPeriod,0)/MarketInfo(symbol,MODE_POINT);
       takeprofitPips = stoplossPips; // only use stoplossPips, because it does not matter what the name is
      }
      
   /* A pending order price can be no closer to the current price, than this
      amount. On IBFX it's equal to 30 (3.0 pips.) A TP or SL, can be no
      closer to the order price (open, limit, or stop) or closing price
      filled order) than this amount. */
       // minGap.stops	= MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;
       // order.SL = MathMin(Bid - TrailingStop * pips2dbl,Bid - minGap.stops); 
        // with spread: take += MarketInfo(symbol,MODE_SPREAD);
         // double currentSpread = MarketInfo(Symbol(),MODE_SPREAD);
         // double minStopLossLevel = MarketInfo(Symbol(),MODE_STOPLEVEL);
         // double minStopLossPips = (currentSpread + minStopLossLevel);

    // adjust minimum distance of pips (depending on currency and broker)
    double minGapStopPips = MarketInfo(Symbol(),MODE_STOPLEVEL) * point;

    // not for OP_BUYSTOP / OP_BUYLIMIT
     if(type == OP_BUY) price = NormalizeDouble(MarketInfo(symbol,MODE_ASK),digit);
    // not for OP_SELLSTOP / OP_SELLLIMIT
     if(type == OP_SELL) price = NormalizeDouble(MarketInfo(symbol,MODE_BID),digit);

    // mode == 0, calculate stoploss
    if (mode == 0)
     {
        if (stoplossPips < minGapStopPips) stoplossPips = minGapStopPips;
       if(type == OP_BUY) sl = NormalizeDouble(price-stoplossPips*point,digit);
       if(type == OP_SELL) sl = NormalizeDouble(price+stoplossPips*point,digit);
      return(sl);
     }

    // mode == 1, calculate takeprofit
    if (mode == 1)
     {
        takeprofitPips += MarketInfo(symbol,MODE_SPREAD); // takeprofitpips + spread
        if (takeprofitPips < minGapStopPips) takeprofitPips = minGapStopPips;
       if(type == OP_BUY) tp = NormalizeDouble(price+takeprofitPips*point,digit);
       if(type == OP_SELL) tp = NormalizeDouble(price-takeprofitPips*point,digit);
      return(tp);
     }
  }
//+------------------------------------------------------------------+
//| function timeToBarClose                                          |
//+------------------------------------------------------------------+  
int timeToBarClose(string symbol,int timeFrame,int shift,int mode)
// mode = 0: return minutes until bar closes
// mode = 1: return seconds of the minutes to bar Close
// e.g. timeToBarClose(symbol,timeFrame,0,0) : minutes
//      timeToBarClose(symbol,timeFrame,0,1) : seconds
  {
 // count time until bar ends, modified from the fuction by Nick Bilak
	if (timeFrame == 0) timeFrame = Period();
	double ti;
   int tm,ts;
   // old: tm=Time[0]+Period()*60-CurTime();
   tm=iTime(symbol,timeFrame,shift)+timeFrame*60-CurTime();
   ti=tm/60.0;
   ts=tm%60;
   tm=(tm-tm%60)/60;
 // count time until bar ends END 
   if (mode == 0) return(tm);
   if (mode == 1) return(ts);
  }
//+------------------------------------------------------------------+
//| function daynumberToString                                       |
//+------------------------------------------------------------------+  
// daynumberToString(5) : returns friday (converts daynumber to string name)
string daynumberToString(int daynumber)
{
       string DayName;
       switch(daynumber)
        {
         case 0 : DayName = "sunday"; break;
         case 1 : DayName = "monday"; break;
         case 2 : DayName = "tuesday"; break;
         case 3 : DayName = "wednesday"; break;
         case 4 : DayName = "thursday"; break;
         case 5 : DayName = "friday"; break;
         case 6 : DayName = "saturday"; break;
         default: DayName = "ERROR";
        }
       return(DayName);
}
//+------------------------------------------------------------------+
//| function gmtTime: returns time or the day  in GMT time           |
//+------------------------------------------------------------------+  
// for gmtShift = 1 (timezone: Germany):
// gmtTime(6,0): returns current hour in gmt timezone (e.g. 14 for time 14:01 - 14:59)
// gmtTime(6,1): returns number of current day in gmt timezone (e.g. 5 for friday)
int gmtTime(int gmtShift, int hourOrDaynumber)
  {  

    // determine GMT day and hour
    
    int gmtHH = TimeHour(TimeLocal()) - gmtShift; // gmtShift = -5 for NYC without daylight savings, e.g.
    int gmtDayNumber = TimeDayOfWeek(TimeLocal());
    if (gmtHH < 0)
     {
      gmtHH += 24;
      gmtDayNumber -= 1;   
     }
    if (gmtHH > 23)
     {
      gmtHH -= 24;
      gmtDayNumber += 1;
     }
    if (gmtDayNumber < 0) gmtDayNumber += 7;
    if (gmtDayNumber > 6) gmtDayNumber -= 7; 

    // end determine GMT day and hour
    
    // return current day number in gmt timezone if requested
    if (hourOrDaynumber == 1) return(gmtDayNumber);

    // return current hour in gmt timezone if requested
    if (hourOrDaynumber == 0) return(gmtHH);  
  }
//+------------------------------------------------------------------+ 
//| Expert getIchiTrend function                                     |
//+------------------------------------------------------------------+
/*
mode 0: return ichiTrend (default)
mode 1: return kijunTrend
mode 2: return tenkanTrend
mode 3: return senkouTrend
mode 4: return chickouTrend
*/
string getIchiTrend(string symbol, int timeFrame, int mode)
{
string returnVal = "";
string ichiTrend = "NONE";

if (mode > 4)
 {
  returnVal = "ERROR - wrong mode selected";
  return(returnVal);
 }

//--------------- START ICHIMOKU:
int shift = 0;
//--- current vals:
double tenkansen = iIchimoku(symbol,timeFrame,tenkanSen,kijunSen,senkouSpanB,MODE_TENKANSEN ,shift);
double kijunsen = iIchimoku(symbol,timeFrame,tenkanSen,kijunSen,senkouSpanB,MODE_KIJUNSEN,shift);
double senkouspana = iIchimoku(symbol,timeFrame,tenkanSen,kijunSen,senkouSpanB,MODE_SENKOUSPANA,shift);
double senkouspanb = iIchimoku(symbol,timeFrame,tenkanSen,kijunSen,senkouSpanB,MODE_SENKOUSPANB,shift);
double chikouspan = iIchimoku(symbol,timeFrame,tenkanSen,kijunSen,senkouSpanB,MODE_CHINKOUSPAN,kijunSen);
double kumoWidth = NormalizeDouble(MathAbs(senkouspana - senkouspanb),MarketInfo(symbol,MODE_DIGITS));

// double chikouSpanPrice = Close[shift+kijunSen];
// double chikouSpanPriceb4 = Close[kijunSen+1+shift];
double chikouSpanPrice = iClose(symbol,timeFrame,shift+kijunSen);
double chikouSpanPriceb4 = iClose(symbol,timeFrame,shift+1+kijunSen);

double chikouSenkouspana = iIchimoku(symbol,timeFrame,tenkanSen,kijunSen,senkouSpanB,MODE_SENKOUSPANA,kijunSen+shift);
double chikouSenkouspanb = iIchimoku(symbol,timeFrame,tenkanSen,kijunSen,senkouSpanB,MODE_SENKOUSPANB,kijunSen+shift);
//double chikouSenkouspana = iIchimoku(symbol,timeFrame,tenkanSen,kijunSen,senkouSpanB,MODE_SENKOUSPANA,kijunsen+shift);
//double chikouSenkouspanb = iIchimoku(symbol,timeFrame,tenkanSen,kijunSen,senkouSpanB,MODE_SENKOUSPANB,kijunsen+shift);

//--- b4 vals:
double tenkansenb4 = iIchimoku(symbol,timeFrame,tenkanSen,kijunSen,senkouSpanB,MODE_TENKANSEN ,shift + 1);
double kijunsenb4 = iIchimoku(symbol,timeFrame,tenkanSen,kijunSen,senkouSpanB,MODE_KIJUNSEN,shift + 1);
double senkouspanab4 = iIchimoku(symbol,timeFrame,tenkanSen,kijunSen,senkouSpanB,MODE_SENKOUSPANA,shift + 1);
double senkouspanbb4 = iIchimoku(symbol,timeFrame,tenkanSen,kijunSen,senkouSpanB,MODE_SENKOUSPANB,shift + 1);
double chikouspanb4 = iIchimoku(symbol,timeFrame,tenkanSen,kijunSen,senkouSpanB,MODE_CHINKOUSPAN,kijunSen + 1);

//--- EMA (for current price position):
double priceSMA;
double priceSMAb4;
if (useOpenPrice)
 {
  //priceSMA = Open[shift];
  //priceSMAb4 = Open[shift+1];
  priceSMA = iOpen(symbol,timeFrame,shift);
  priceSMAb4 = iOpen(symbol,timeFrame,shift+1);
 }
if (!useOpenPrice)
 {
  priceSMA = iMA(symbol,timeFrame,emaPeriod,emaShift,emaMethod,emaAppliedPrice,shift);
  priceSMAb4 = iMA(symbol,timeFrame,emaPeriod,emaShift,emaMethod,emaAppliedPrice,shift + 1);
 }

//----------------

string kijunTrend = "-:-";
string tenkanTrend = "-:-";
string senkouTrend = "-:-";
string chikouTrend = "-:-";

//--- 1.: KIJUN SEN
if (priceSMA > kijunsen) kijunTrend = "LONG"; // (price over kijun sen)
 else if (priceSMA < kijunsen) kijunTrend = "SHORT"; // (price under kijun sen)
  else if (priceSMA == kijunsen) kijunTrend = "FLAT"; // (price = kijun sen)
//if(StringFind(senkouTrend,"LONG",0) > 0) senkouTrend = "LONG";

//--- 2.: TENKAN SEN/KIJUN SEN
if (tenkansen == kijunsen) tenkanTrend = "FLAT";
if (tenkansen > kijunsen) tenkanTrend = "LONG";
if (tenkansen < kijunsen) tenkanTrend = "SHORT";
//tenkan/kijun crosses:
if (tenkansen > kijunsen && tenkansenb4 < kijunsenb4) tenkanTrend = "LONG"; // (crossed kijun sen)";
if (tenkansen < kijunsen && tenkansenb4 > kijunsenb4) tenkanTrend = "SHORT"; // (crossed kijun sen)";

//--- 3.: SENKOU SPAN A/B
if (senkouspana > senkouspanb) senkouTrend = "LONG";
if (senkouspana < senkouspanb) senkouTrend = "SHORT";
//price in the kumo:
if (priceSMA < senkouspana && priceSMA > senkouspanb && kumoWidth >= ignoreKumoIfWidthUnder) senkouTrend = "FLAT"; // (price in kumo)";
if (priceSMA > senkouspana && priceSMA < senkouspanb && kumoWidth >= ignoreKumoIfWidthUnder) senkouTrend = "FLAT"; // (price in kumo)";
//price over the kumo:
if (priceSMA > senkouspana && priceSMAb4 < senkouspanab4
    && priceSMA > senkouspanb && priceSMAb4 > senkouspanbb4) senkouTrend = "LONG"; // (price over kumo)";
if (priceSMA > senkouspanb && priceSMAb4 < senkouspanbb4
    && priceSMA > senkouspana && priceSMAb4 > senkouspanab4) senkouTrend = "LONG"; // (price over kumo)";
//price under the kumo:
if (priceSMA < senkouspanb && priceSMA < senkouspana) senkouTrend = "SHORT"; // (price under kumo)";
//prive over the kumo:
if (priceSMA > senkouspanb && priceSMA > senkouspana) senkouTrend = "LONG"; // (price over kumo)";
//price under the kumo:
if (priceSMA < senkouspanb && priceSMAb4 > senkouspanbb4
    && priceSMA < senkouspana && priceSMAb4 < senkouspanab4) senkouTrend = "SHORT"; // (price under kumo)";
if (priceSMA < senkouspana && priceSMAb4 > senkouspanab4
    && priceSMA < senkouspanb && priceSMAb4 < senkouspanbb4) senkouTrend = "SHORT"; // (price under kumo)";
//trend reversal warning:
if (senkouspana > senkouspanb && senkouspanab4 < senkouspanbb4) senkouTrend = "LONG REVERSAL WARNING"; // trend may turn from short to long
if (senkouspana < senkouspanb && senkouspanab4 > senkouspanbb4) senkouTrend = "SHORT REVERSAL WARNING";  // trend may turn from long to short

//--- 4.: CHIKOU SPAN
// chikou over price its periods ago:
if (chikouspan > chikouSpanPrice) chikouTrend = "LONG"; // (over price)";
// chikou under price
if (chikouspan < chikouSpanPrice) chikouTrend = "SHORT"; // (under price)";
// chikou span long crossing price its periods ago
if (chikouspan > chikouSpanPrice && chikouspanb4 <= chikouSpanPriceb4) chikouTrend = "LONG"; // (cross price)";
// chikou span short crossing price its periods ago
if (chikouspan < chikouSpanPrice && chikouspanb4 >= chikouSpanPriceb4) chikouTrend = "SHORT"; // (cross price)";
// chikou over/under the kumo
if (chikouspan > chikouSenkouspana && chikouspan < chikouSenkouspanb) chikouTrend = "FLAT"; // (in kumo)";
if (chikouspan < chikouSenkouspana && chikouspan > chikouSenkouspanb) chikouTrend = "FLAT"; // (in kumo)";
if (chikouspan > chikouSenkouspana && chikouspan > chikouSenkouspanb) chikouTrend = "LONG"; // (over kumo)";
if (chikouspan < chikouSenkouspana && chikouspan < chikouSenkouspanb) chikouTrend = "SHORT";// (under kumo)";
  //else chikouTrend = "FLAT (in the kumo)";

//--- check if user only wants normal, strong, weak or all kumo signals:
string kumoAllowsTrade = "FLAT";
//determine strength of long signal:
if (!ignoreTenkan && !ignoreSenkou
    && kumoWidth >= ignoreKumoIfWidthUnder
    && tenkanTrend == "LONG")
    {
     //price over the kumo, STRONG SIGNAL:
     if (senkouTrend == "LONG") kumoAllowsTrade = "LONG";
     //price in the kumo, NORMAL SIGNAL:
     if (senkouTrend == "FLAT" && tenkanKumoMode < 2) kumoAllowsTrade = "LONG";
     //price under the kumo, WEAK SIGNAL:
     if (senkouTrend == "SHORT" && tenkanKumoMode == 0) kumoAllowsTrade = "LONG";
     //short reversal warning´, WEAK LONG SIGNAL, mode 0:
     if (senkouTrend == "SHORT REVERSAL WARNING" && tenkanKumoMode == 0) kumoAllowsTrade = "LONG";
    }
//determine strength of short signal:
if (!ignoreTenkan && !ignoreSenkou
    && kumoWidth >= ignoreKumoIfWidthUnder
    && tenkanTrend == "SHORT")
    {
     //price over the kumo, WEAK SIGNAL, mode 0:
     if (senkouTrend == "LONG" && tenkanKumoMode == 0) kumoAllowsTrade = "SHORT";
     //price in the kumo, NORMAL SIGNAL, mode 1:
     if (senkouTrend == "FLAT" && tenkanKumoMode < 2) kumoAllowsTrade = "SHORT";
     //price under the kumo, STRONG SIGNAL, mode 2:
     if (senkouTrend == "SHORT") kumoAllowsTrade = "SHORT";
     //long reversal warning´, WEAK SHORT SIGNAL, mode 0:
     if (senkouTrend == "LONG REVERSAL WARNING" && tenkanKumoMode == 0) kumoAllowsTrade = "SHORT";
    }
//--- same for chikou span:
string kumoAllowsChikouTrade = "FLAT";
//determine strength of long signal:
if (!ignoreChikou && !ignoreSenkou
    && kumoWidth >= ignoreKumoIfWidthUnder
    && tenkanTrend == "LONG")
    {
     //price over the kumo, STRONG SIGNAL:
     if (chikouTrend == "LONG") kumoAllowsChikouTrade = "LONG";
     //price in the kumo, NORMAL SIGNAL:
     if (chikouTrend == "FLAT" && chikouKumoMode < 2) kumoAllowsChikouTrade = "LONG";
     //price under the kumo, WEAK SIGNAL:
     if (chikouTrend == "SHORT" && chikouKumoMode == 0) kumoAllowsChikouTrade = "LONG";
    }
//determine strength of short signal:
if (!ignoreChikou && !ignoreSenkou
    && kumoWidth >= ignoreKumoIfWidthUnder
    && tenkanTrend == "SHORT")
    {
     //price over the kumo, WEAK SIGNAL, mode 0:
     if (chikouTrend == "LONG" && chikouKumoMode == 0) kumoAllowsChikouTrade = "SHORT";
     //price in the kumo, NORMAL SIGNAL, mode 1:
     if (chikouTrend == "FLAT" && chikouKumoMode < 2) kumoAllowsChikouTrade = "SHORT";
     //price under the kumo, STRONG SIGNAL, mode 2:
     if (chikouTrend == "SHORT") kumoAllowsChikouTrade = "SHORT";
    }

string tenkanKumoComment = "";
if (!ignoreTenkan && !ignoreSenkou)
 {
  if (tenkanKumoMode == 0) tenkanKumoComment = " (ALL kumo signals will be used)";
   else if (tenkanKumoMode == 1) tenkanKumoComment = " (NORMAL and STRONG kumo signals will be used)";
    else if (tenkanKumoMode == 2) tenkanKumoComment = " (ONLY STRONG kumo signals will be used)";
     else tenkanKumoComment = " (ERROR - wrong tenkanKumoMode selected)";
 }
//---
//string chikouKumoComment = "";
if (!ignoreChikou && !ignoreSenkou)
 {
  if (chikouKumoMode == 0) chikouKumoComment = " (ALL kumo signals will be used)";
   else if (chikouKumoMode == 1) chikouKumoComment = " (NORMAL and STRONG kumo signals will be used)";
    else if (chikouKumoMode == 2) chikouKumoComment = " (ONLY STRONG kumo signals will be used)";
     else chikouKumoComment = " (ERROR - wrong chikouKumoMode selected)";
 }

// set returnVAls:
/*
mode 0: return ichiTrend (default)
mode 1: return kijunTrend
mode 2: return tenkanTrend
mode 3: return senkouTrend
mode 4: return chickouTrend
*/
if (mode == 1) returnVal = kijunTrend;
if (mode == 2) returnVal = tenkanTrend;
if (mode == 3) returnVal = senkouTrend;
if (mode == 4) returnVal = chikouTrend;

//---- determine trend:
ichiTrend = "FLAT";
if (ignoureKijun) kijunTrend = "LONG";
if (ignoreTenkan)tenkanTrend = "LONG";
if (ignoreSenkou) senkouTrend = "LONG";
if (ignoreChikou) chikouTrend = "LONG";
if (ignoreTenkan || ignoreSenkou) kumoAllowsTrade = "LONG";
if (ignoreChikou || ignoreSenkou) kumoAllowsChikouTrade = "LONG";
if (tenkanTrend == "LONG"
    && kijunTrend == "LONG"
    && kumoAllowsTrade == "LONG"
    && kumoAllowsChikouTrade == "LONG"
    //&& senkouTrend == "LONG"
    //&& chikouTrend == "LONG"
    ) ichiTrend = "LONG";

if (ignoureKijun) kijunTrend = "SHORT";
if (ignoreTenkan)tenkanTrend = "SHORT";
if (ignoreSenkou) senkouTrend = "SHORT";
if (ignoreChikou) chikouTrend = "SHORT";
if (ignoreTenkan || ignoreSenkou) kumoAllowsTrade = "SHORT";
if (ignoreChikou || ignoreSenkou) kumoAllowsChikouTrade = "SHORT";

if (tenkanTrend == "SHORT"
    && kijunTrend == "SHORT"
    && kumoAllowsTrade == "SHORT"
    && kumoAllowsChikouTrade == "SHORT"
    //&& senkouTrend == "SHORT"
    //&& chikouTrend == "SHORT"
    ) ichiTrend = "SHORT";

if (mode == 0) returnVal = ichiTrend;
return (returnVal);
}
//+------------------------------------------------------------------+ 
//| Expert checkForBreakEven function                                |
//+------------------------------------------------------------------+
int checkForBreakEven(string symbol,int magicNumber, int BreakEven)
 {
   RefreshRates();
   int cnt;
   int total = OrdersTotal();
   int ticket;
   
   double point = MarketInfo(symbol,MODE_POINT);
   double digit = MarketInfo(symbol,MODE_DIGITS);
   double spread = MarketInfo(symbol,MODE_SPREAD);   
   double multiplier;
   if(digit == 2 || digit == 4) multiplier = 1;
   if(digit == 3 || digit == 5) multiplier = 10;
   if(digit == 6) multiplier = 100;   
   if(digit == 7) multiplier = 1000;
   point*=multiplier;
   BreakEven*=multiplier;
   setToBEafterPips*=multiplier;
   // end adjust for 5 digit brokers    

   
        for (cnt = 0 ; cnt <= total ; cnt++)
            {
               OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
               if (OrderMagicNumber() == magicNumber && OrderSymbol() == symbol)
               { 
              /* set BreakEven if set for OP_BUY */
              if (OrderType()==OP_BUY && BreakEven>0)
              {
                 if(Bid-OrderOpenPrice()>((point*BreakEven) + setToBEafterPips))
                 {
                    if(OrderStopLoss()<OrderOpenPrice()) 
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+point*1,OrderTakeProfit(),0,Gray);
                    }
                 }
              } // end BE for OP_BUY
  
              /* set BreakEven if set for OP_SELL */
              if (OrderType()==OP_SELL && BreakEven>0)
              {
                 if(OrderOpenPrice()-Ask>((point*BreakEven) + setToBEafterPips))
                 {
                    if(OrderStopLoss()>OrderOpenPrice()) 
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-point*1,OrderTakeProfit(),0,Gray);
                    }
                 }
              } // end BE for OP_SELL
                }
            }
 }
//+------------------------------------------------------------------+
//| expert isNewBarVarVolume function                                |
//+------------------------------------------------------------------+
// isNewBarVarVolume(symbol,timeFrame,0,1)
// checks if new bar (true if iVolume < maxVolume)
bool isNewBarVarVolume(string symbol,int tf,int shift, int maxVolume)
  {
   bool isNewBarOpen;
   if (iVolume(symbol,tf,shift) > maxVolume) isNewBarOpen = false;
    else isNewBarOpen = true;   
   
   return(isNewBarOpen);
  }


//+------------------------------------------------------------------+
//|modifyNoMagicTrades                                               |
//+------------------------------------------------------------------+
// extern int option = 0;
// extern int magicNumber = 0; // set it if you'll use closing option 3 - closing by magic number
// extern string commentText = ""; // set it if you'll use closing option 4 - closing by comment
int modifyNoMagicTrades(int atrCalcTF, int atrCalcPeriod,int atrTPmultiplier,int atrSLmultiplier,int magicNumber)
{
   bool Alerts = false;
   
   bool useFixedStopLoss = false;
   bool useFixedTakeProfit = false;
   bool useATRtakeProfit = true;
   bool useATRstopLoss = true;
   //int atrTPmultiplier = 3;
   //int atrSLmultiplier = 3;
   int ATRtimeframe = atrCalcTF; // = 15;
   int ATRperiod = atrCalcPeriod; // = 14;
   double fixedStopLossPips = 0;
   double fixedTakeProfitPips = 0;
   
   double sl, tp;

//---
   string symbol;
   
   bool result;
   int err; // catch errors
   
   int total = OrdersTotal();
   int cnt = 0;
   int ticket;
   bool magicIsSet;
   
   RefreshRates();

         for (cnt = 0 ; cnt <= total ; cnt++)
            {
               magicIsSet = true;
               OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
               // if (OrderMagicNumber() != 0) magicIsSet = true;
                if (OrderMagicNumber() == magicNumber) magicIsSet = false;
                if (!magicIsSet && OrderStopLoss() == 0 && OrderTakeProfit() == 0)
                 {
                  symbol = OrderSymbol();
                
                  if(OrderType()==OP_BUY)
                   {
                    if (useATRtakeProfit == true) tp = calcTPSL(symbol,OP_BUY,0,0,atrTPmultiplier,ATRtimeframe,ATRperiod,true,1);
                    if (useATRstopLoss == true) sl = calcTPSL(symbol,OP_BUY,0,0,atrSLmultiplier,ATRtimeframe,ATRperiod,true,0);
                    if (useFixedTakeProfit == true) tp = calcTPSL(symbol,OP_BUY,fixedStopLossPips,fixedTakeProfitPips,atrTPmultiplier,ATRtimeframe,ATRperiod,false,1);
                    if (useFixedStopLoss == true) sl = calcTPSL(symbol,OP_BUY,fixedStopLossPips,fixedTakeProfitPips,atrSLmultiplier,ATRtimeframe,ATRperiod,false,0);
                   }
                
                  if(OrderType()==OP_SELL)
                   {
                    if (useATRtakeProfit == true) tp = calcTPSL(symbol,OP_SELL,0,0,atrTPmultiplier,ATRtimeframe,ATRperiod,true,1);
                    if (useATRstopLoss == true) sl = calcTPSL(symbol,OP_SELL,0,0,atrSLmultiplier,ATRtimeframe,ATRperiod,true,0);
                    if (useFixedTakeProfit == true) tp = calcTPSL(symbol,OP_SELL,fixedStopLossPips,fixedTakeProfitPips,atrTPmultiplier,ATRtimeframe,ATRperiod,false,1);
                    if (useFixedStopLoss == true) sl = calcTPSL(symbol,OP_SELL,fixedStopLossPips,fixedTakeProfitPips,atrSLmultiplier,ATRtimeframe,ATRperiod,false,0);
                   }                  
             
                while(IsTradeContextBusy()) Sleep(100);
                result = OrderModify(OrderTicket(), OrderOpenPrice(), sl, tp, OrderExpiration(), CLR_NONE);
                if (!result)
                 {
                  err=GetLastError();
                  Print(symbol, " SL/TP order modify failed with error #",err,""); // (",ErrorDescription(err),")");
                 }
                  else if (Alerts) Alert("Order ",OrderTicket()," modified");

                  
                  /*
                  if(OrderType()==OP_BUY)
                     OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5000,CLR_NONE);
                  if(OrderType()==OP_SELL) 
                     OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5000,CLR_NONE);
                  if(OrderType()>OP_SELL)
                     OrderDelete(OrderTicket());
                  */
               }
            }
}
/*

OP_BUY:
 if (useATRforSL) sl = calcTPSL(symbol,OP_BUY,0,0,atrSLmultiplier,atrCalcTF,atrCalcPeriod,true,0);
 if (useATRforTP) tp = calcTPSL(symbol,OP_BUY,0,0,atrTPmultiplier,atrCalcTF,atrCalcPeriod,true,1);

OP_SELL:
 if (useATRforSL) sl = calcTPSL(symbol,OP_SELL,0,0,atrSLmultiplier,atrCalcTF,atrCalcPeriod,true,0);
 if (useATRforTP) tp = calcTPSL(symbol,OP_SELL,0,0,atrTPmultiplier,atrCalcTF,atrCalcPeriod,true,1);
*/