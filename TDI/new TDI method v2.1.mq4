//+------------------------------------------------------------------+
//|                                               new TDI method.mq4 |
//|                                    Copyright 2015, Zheng zuodong |
//|                                            https://www.yczzd.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Zheng zuodong"
#property link      "https://www.yczzd.com"
#property strict

#include <stdlib.mqh>
#include <stderror.mqh>

#define EA_NAME   "new TDI method"
#define VER       "V2.1"
#define COMMENT   "newTDImethod"
#define STAT_IDLE 0     // Idle. waiting for cross
#define STAT_BUSY 1     // Trade in progress
#define SIG_NO    0
#define SIG_UP    1
#define SIG_DN    2
#define TEXT_FONT  "Courier New"

extern int    BrokerGMTShift = 2;        //Broker GMT shift
extern bool   DST = true;                //Daylight saving time
int           DSTOffset;  
extern double Lots = 0.1;                   //Fix lots
extern int    CounterTradeMax = 3;          //Max number of Counter Trading
extern int    CounterTradeGap = 50;         //Gap of Counter Trading
//extern double CounterLotMulti = 1;       //Multi of Counter Trading
double CounterLotMulti = 1;       //Multi of Counter Trading
extern int    SinglePairTP    = 50;         //TP of Single Symbol Basket
extern double SinglePairSL    = 200;        //SL of Single Symbol Basket   
extern int    BreakevenPips   = 25;         //Breakeven Point of Single Symbol Basket
extern int    RSIPeriod       = 13;         //Period of RSI used TDI  
extern int    RSIPrice        = 0;          //Apply Price 0=CLOSE, 1=OPEN, 2=HIGH, 3=LOW, 4=MEDIAN, 5=TYPICAL, 6=WEIGHTED
extern int    SignalLevelUP   = 70;         //Up Level of Confirm  SELL Signal
extern int    SignalLevelDN   = 30;         //Down Level of Confirm BUY Signal
extern string BTS = "*** Basket Trading Setting ***";
extern double BasketProfitPercent   = 5;    //TP of all Trading in Percent
extern double BasketStoplossPercent = 10;   //SL of all Trading in Percent   
// % of Account Balance

int      gStatus;
int      gSignal;
int      gTicket;
int      gOrderType;

double   gPoint;
double   gSL;
double   gTP;
double   gBasketProfit;
int      gOrdersInBasket;
double   MaxProfit=0, MinProfit=0;
datetime MaxProfitTime, MinProfitTime;
string   gTF, gComment;
datetime gLoadEATime;

datetime TSO, LSO, NSO;
datetime TSC, LSC, NSC;  
datetime TokyoTime, LondonTime, NewyorkTime;  //Tokyo, London, Newyork session Open & Close & Now time

double RSIBuf[],MBLBuf[],RPLBuf[],TSLBuf[];
int    arraysize;

double Price[2];
int    giSlippage;
int    iError;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   gLoadEATime = TimeCurrent();
   gPoint = Point;
   if (Digits==3 || Digits==5) gPoint = 10*gPoint;
   switch(Period())
   {  case 1    : gTF = "M1"; break;
      case 5    : gTF = "M5"; break;
      case 15   : gTF = "M15"; break;
      case 30   : gTF = "M30"; break;
      case 60   : gTF = "H1"; break;
      case 240  : gTF = "H4"; break;
      case 1440 : gTF = "D1"; break;
   }
   gComment = COMMENT +" "+ VER +" "+ Symbol()+"-";

/*   
  if (!IndicatorExists(INDI_NAME+".ex4"))
    Alert(Symbol()+", "+TF2Str(Period())+", "+EA_NAME+": Error! "+TerminalPath()+"\\experts\\indicators\\"+INDI_NAME+".ex4 cannot be found.");//---
*/   
  for(int i=0;i<=288;i++)
  {  SubDisplay("Gray"+IntegerToString(i,0),"|",1,5+i,1,12,TEXT_FONT,Green);
     if(MathMod(i,12)==0)
       SubDisplay("BrokerTime"+IntegerToString(i,0),"|",1,5+i,11,12,TEXT_FONT,Green);
  }
  int n=0;
  for(int i=288;i>=0;i--)
  {   
      if(MathMod(i,24)==0)
      {  
         SubDisplay("Time"+IntegerToString(i,0),IntegerToString(n,0),1,5+i,21,8,TEXT_FONT,Lime);
         n=n+2;
      }
  
  }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  datetime DeltaDelay;
  double   PairTP=0,PairSL=0,PairProfit=0;
  double   AverageOpenPrice=0;
  double   totalopenprice=0;
  int      i, n=0, TradeType=0, SinglePairTradeNum=0;
  int      PairTicket[];
  double   PairOpenPrice[];
  double   TradeLots[];
  double   CounterLots;
  
  bool     SinglePairBE=false;
//---
   arraysize = Bars;
   ArrayResize(RSIBuf,arraysize);
   ArrayResize(RPLBuf,arraysize);
   ArrayResize(TSLBuf,arraysize);
   ArrayResize(MBLBuf,arraysize);
   
   ArrayResize(PairTicket,CounterTradeMax+1);
   ArrayResize(PairOpenPrice,CounterTradeMax+1);
   ArrayResize(TradeLots,CounterTradeMax+1);

   
   ArrayInitialize(RSIBuf,0);
   ArrayInitialize(RPLBuf,0);
   ArrayInitialize(TSLBuf,0);
   ArrayInitialize(MBLBuf,0);
   ArraySetAsSeries(RSIBuf,true);
   
   ArrayInitialize(PairTicket,0);
   ArrayInitialize(PairOpenPrice,0);
   ArrayInitialize(TradeLots,0);
  
//  if(TimeMinute(Time[0])==0 && TimeSeconds(Time[0])<10)
    Session_Boxes();
  DeltaDelay=TimeCurrent()-gLoadEATime;
  CheckBasketProfit();
//  Print("gBasketProfit= ",gBasketProfit);
  iDisplayInfo("BSKProfit","ProfitInBasket="+AlignStr(DoubleToStr(gBasketProfit,2),10),3,10,10,10,TEXT_FONT,Yellow);  
  iDisplayInfo("BSKTOrder","OrdersInBasket="+AlignStr(IntegerToString(gOrdersInBasket,0),10),3,10,25,10,TEXT_FONT,Yellow);
  iDisplayInfo("BskproMax","BasketPro Max.="+AlignStr(DoubleToStr(MaxProfit,2),6)+"@"+TimeToStr(MaxProfitTime,TIME_MINUTES),3,10,40,10,TEXT_FONT,Green);
  iDisplayInfo("BskproMin","BasketPro Min.="+AlignStr(DoubleToStr(MinProfit,2),6)+"@"+TimeToStr(MinProfitTime,TIME_MINUTES),3,10,55,10,TEXT_FONT,Green);
//Calculate TDI value  
  for(i=0;i<arraysize;i++)     //(i=arraysize-1;i>=0;i--)  
  {  RefreshRates();
     RSIBuf[i] = NormalizeDouble((iRSI(NULL,0,RSIPeriod,RSIPrice,i)),4);
  }
  for(i=0;i<arraysize;i++)  {
     RPLBuf[i] = NormalizeDouble((iMAOnArray(RSIBuf,arraysize,2,0,0,i)),4);
     TSLBuf[i] = NormalizeDouble((iMAOnArray(RSIBuf,arraysize,7,0,0,i)),4);
     MBLBuf[i] = NormalizeDouble((iMAOnArray(RSIBuf,arraysize,34,0,0,i)),4);   
  }
  for(i=0;i<3;i++)  {   
     iDisplayInfo("RPLvalue"+IntegerToString(i,0),"RPL"+IntegerToString(i,0)+"="+DoubleToStr(RPLBuf[i],4),3,10,145+i*15,8,TEXT_FONT,Lime);
     iDisplayInfo("TSLvalue"+IntegerToString(i,0),"TSL"+IntegerToString(i,0)+"="+DoubleToStr(TSLBuf[i],4),3,100,145+i*15,8,TEXT_FONT,Red);
//   iDisplayInfo("MBLvalue"+IntegerToString(i,0),"MBL"+IntegerToString(i,0)+"="+DoubleToStr(MBLBuf[i],4),3,10,145+i*15,8,TEXT_FONT,Yellow);
  }

//---Check exist orders
  for(i=0; i<OrdersTotal(); i++)
  {  if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true)
     {  if(OrderSymbol()!=Symbol())
          continue;
        else if(StringSubstr(OrderComment(),0,StringLen(OrderComment())-1)==gComment)
        {  if(SinglePairTradeNum<StrToInteger(StringSubstr(OrderComment(),StringLen(OrderComment())-1,1)))
           {  SinglePairTradeNum=StrToInteger(StringSubstr(OrderComment(),StringLen(OrderComment())-1,1));
              PairTicket[SinglePairTradeNum-1] = OrderTicket();
              PairOpenPrice[SinglePairTradeNum-1] = OrderOpenPrice();
              TradeLots[SinglePairTradeNum-1] = OrderLots();
              if(OrderStopLoss()!=0)   SinglePairBE=true;
              TradeType = OrderType();
              PairProfit += OrderProfit()+OrderSwap();
              n++;
           }
        }
     }
     else
     {
        iError=GetLastError();
        Print("Order Select(when check exist order) Error: ",iError,"--",ErrorDescription(iError));
     }
  }
  
//---Check breakeven,if profit more than BE, then setup SL to BE+10  
  if(SinglePairTradeNum>0 && SinglePairBE==false && PairProfit>=BreakevenPips)
  {  for(i=0;i<SinglePairTradeNum;i++)
       totalopenprice += PairOpenPrice[i];
     AverageOpenPrice=totalopenprice/SinglePairTradeNum;
     for(i=0;i<SinglePairTradeNum;i++)
     {  if(TradeType==OP_BUY)
        {  if(OrderModify(PairTicket[i],PairOpenPrice[i],NormalizeDouble(AverageOpenPrice+10*Point,Digits),0,0,Blue)==true)
             Print(Symbol()," Ticket #",PairTicket[i],"BreakEven Modify OOKK!!");
           else
             Print(Symbol()," Ticket #",PairTicket[i],"BreakEven Modify error ",OrderError());
        }
        if(TradeType==OP_SELL)
        {  if(OrderModify(PairTicket[i],PairOpenPrice[i],NormalizeDouble(AverageOpenPrice-10*Point,Digits),0,0,Blue)==true)
             Print(Symbol()," Ticket #",PairTicket[i],"BreakEven Modify OOKK!!");
           else
             Print(Symbol()," Ticket #",PairTicket[i],"BreakEven Modify error ",OrderError());
        }     
      }
  }

//---Check single pair profit. if >SinglePairTP,then close the pair  
  if(SinglePairTradeNum>0 && (PairProfit>=SinglePairTP || PairProfit<=SinglePairSL*(-1)))
    CloseSpecifyOrder(Symbol(),"Single pair basket profit reach, close specified pair");
  
  iDisplayInfo("Pairprofit","Pair Profit="+AlignStr(DoubleToStr(PairProfit,2),10),3,10,70,10,TEXT_FONT,Lime);
  iDisplayInfo("PairTradeNum","Pair Order Num="+AlignStr(IntegerToString(n,0),10),3,10,85,10,TEXT_FONT,Lime);

//---if Trade Signal Line(Red line) above  SignalLevelUP, or below SignalLevelDN, Close single pair positions in profit
  if(SinglePairTradeNum>0 && TradeType==OP_BUY && TSLBuf[0]>SignalLevelUP && RPLBuf[0]<TSLBuf[0])
    CloseSpecifyOrder(Symbol(),"TSL value > SignalLevelUP, close specified pair BUY order");
  
  if(SinglePairTradeNum>0 && TradeType==OP_SELL && TSLBuf[0]<SignalLevelDN && RPLBuf[0]>TSLBuf[0])
    CloseSpecifyOrder(Symbol(),"TSL value < SignalLevelDN, close specified pair SELL order");

//---if price run opposite direction to order, then add order(Lots=Lots*CounterLotMulti^n)
  if(SinglePairTradeNum>0 && SinglePairTradeNum<=CounterTradeMax)
  {  CounterLots=NormalizeDouble(Lots*MathPow(CounterLotMulti,SinglePairTradeNum),1);
     if(TradeType==OP_BUY)
     {  if(PairOpenPrice[SinglePairTradeNum-1]-Ask >=CounterTradeGap*Point)
        {  if(OrderSend(Symbol(),TradeType,CounterLots,Ask,3,0,0,gComment+IntegerToString(SinglePairTradeNum+1,0),0,0,Green)==false)
           {  iError=GetLastError();
              Print("Open ",Symbol()," ",IntegerToString(SinglePairTradeNum+1,0),"# Buy Order(when Check counterTrade) error:", iError,"--",ErrorDescription(iError));
           }
           else
              Print("Open ",Symbol()," ",IntegerToString(SinglePairTradeNum+1,0),"# Buy Order(when Check counterTrade) OOKK!");
        }
     }
     if(TradeType==OP_SELL)
     {  if(Bid-PairOpenPrice[SinglePairTradeNum-1] >=CounterTradeGap*Point)
        {  if(OrderSend(Symbol(),TradeType,CounterLots,Bid,3,0,0,gComment+IntegerToString(SinglePairTradeNum+1,0),0,0,Green)==false)
           {  iError=GetLastError();
              Print("Open ",Symbol()," ",IntegerToString(SinglePairTradeNum+1,0),"# Sell Order(when Check counterTrade) error:", iError,"--",ErrorDescription(iError));
           }
           else
              Print("Open ",Symbol()," ",IntegerToString(SinglePairTradeNum+1,0),"# Sell Order(when Check counterTrade) OOKK!");
        }
     }
  }

//---RPL and TSL have crossed in pre-two candles, then open order if next candle trend continue yet
  if(SinglePairTradeNum==0 && RPLBuf[0]<RPLBuf[1]-0.2 && RPLBuf[1]<TSLBuf[1] && RPLBuf[2]>TSLBuf[2] && TSLBuf[0]>SignalLevelUP)
  {  if(OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,gComment+IntegerToString(1,0),0,0,Green)==false)
     {  iError=GetLastError();
        Print("Open ",Symbol()," 1# Sell Order(when Check TDI's sign) error:", iError,"--",ErrorDescription(iError));
     }
     else
       Print("Open ",Symbol()," 1# Sell Order(when Check TDI's sign) OOKK!");
  }
  if(SinglePairTradeNum==0 && RPLBuf[0]>RPLBuf[1]+0.2 && RPLBuf[1]>TSLBuf[1] && RPLBuf[2]<TSLBuf[2] && TSLBuf[0]<SignalLevelDN)
  {  if(OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,gComment+IntegerToString(1,0),0,0,Green)==false)
     {  iError=GetLastError();
        Print("Open ",Symbol()," 1# Buy Order(when Check TDI's sign) error:", iError,"--",ErrorDescription(iError));
     }
     else
       Print("Open ",Symbol()," 1# Buy Order(when Check TDI's sign) OOKK!");
  }  
}
//+------------------------------------------------------------------+
void iDisplayInfo(string LabelName,string LabelDoc,int Corner,int TextX,int TextY,int DocSize,string DocStyle,color DocColor)
{ 
   ObjectCreate(LabelName, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(LabelName, LabelDoc, DocSize, DocStyle,DocColor);
   ObjectSet(LabelName, OBJPROP_CORNER, Corner); 
   ObjectSet(LabelName, OBJPROP_XDISTANCE, TextX); 
   ObjectSet(LabelName, OBJPROP_YDISTANCE, TextY); 
   return; 
}
//-----------------------------------------------------------------------------
// function: CheckBasketProfit()
// Description: Check if BasketTP has been hit
//-----------------------------------------------------------------------------
/*
int CheckBasketProfit()
{
  int i;
  gOrdersInBasket=0;
  gBasketProfit=0;
  
  for(i=0; i<OrdersTotal(); i++) 
  {
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==false)
    {  iError=GetLastError();
       Print("OrderSelect() Function in CheckBasket error = ",iError,"--",ErrorDescription(iError));
    }
    if(StringSubstr(OrderComment(),0,StringLen(COMMENT))==COMMENT)
    {  gBasketProfit+= OrderProfit();
       gOrdersInBasket++;
    }
  }

  if(BasketProfitPercent>0 && gBasketProfit>=BasketProfitPercent*0.01*AccountBalance()) 
      CloseSpecifyOrder("NULL","Basket Profit percent Hit,Close all orders");
  if(BasketStoplossPercent>0 && gBasketProfit<=BasketStoplossPercent*(-0.01)*AccountBalance())
    CloseSpecifyOrder("NULL","Basket Stopless percent Hit,Close all orders");
    
  return(0);
}
*/
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
int CheckBasketProfit()
{ int i;
  gOrdersInBasket=0;
  gBasketProfit=0;
  for(i=0; i<OrdersTotal(); i++) 
  {
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==false)
    {  iError=GetLastError();
       Print("OrderSelect() Function in CheckBasket error = ",iError,"--",ErrorDescription(iError));
    }
    if(StringSubstr(OrderComment(),0,StringLen(COMMENT))==COMMENT)
    {  gBasketProfit+= OrderProfit()+OrderSwap();
       gOrdersInBasket++;
    }
  }
  if(gBasketProfit>MaxProfit) {MaxProfit=gBasketProfit;  MaxProfitTime=TimeCurrent();}
  if(gBasketProfit<MinProfit) {MinProfit=gBasketProfit;  MinProfitTime=TimeCurrent();}

  if(BasketProfitPercent>0 && gBasketProfit>=BasketProfitPercent*0.01*AccountBalance()) 
      CloseSpecifyOrder("NULL","Basket Profit percent Hit,Close all orders");
  if(BasketStoplossPercent>0 && gBasketProfit<=BasketStoplossPercent*(-0.01)*AccountBalance())
    CloseSpecifyOrder("NULL","Basket Stopless percent Hit,Close all orders");
    
  return(0);
}//-----------------------------------------------------------------------------
// function: NoTradeSameCandle()
// Description: Not trade in the same candlestick.
//-----------------------------------------------------------------------------
bool NoTradeSameCandle()
{
   int i, history;
   bool tradeID=true;
   history=OrdersHistoryTotal();
   for(i=0;i<history;i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
      {  iError=GetLastError();
         Print("Order Select when Check History order Error = ",iError,"--",ErrorDescription(iError));
         break;
      }
      if(OrderSymbol()!=Symbol())
        continue;
      else
      {  if(TimeHour(OrderOpenTime())==TimeHour(Time[0]))
         {  tradeID=false;
            break;
         }
         else
           tradeID=true;
      }
   }
   return(tradeID);
}

// function: AlignStr()
// Description: The string into a specified length 
string AlignStr(string text, int len)
{
  int textlength, i;
  
  textlength=StringLen(text);
  i=len-textlength;
  while(i>0)
  {  text=" "+text;
     i--;
  }
  return(text);
}
//+------------------------------------------------------------------+
//| function: Session_VLine()
//  Description: Draw vertical line. TSO(Tokyo Session OpenClose),LSO(London) ,NSO(Newyork)
//+------------------------------------------------------------------+
void Session_Boxes()
{
  int  i,    Range = 200;
//  datetime TSO, LSO, NSO;
//  datetime TSC, LSC, NSC;
//  datetime BrokerOpen;
//  datetime GMTTime;
  double   TokyoLHigh, TokyoRLow, LondonLHigh, LondonRLow, NewyorkLHigh, NewyorkRLow;
  if(DST==true)   DSTOffset=1;
  else            DSTOffset=0;

  TokyoTime   =TimeCurrent()-BrokerGMTShift*3600+9*3600;
  LondonTime  =TimeCurrent()-BrokerGMTShift*3600+DSTOffset*3600;
  NewyorkTime =TimeCurrent()-BrokerGMTShift*3600-5*3600+DSTOffset*3600;

  for(i=0; i<Range; i++)
  {  if(TimeHour(Time[i]-BrokerGMTShift*3600)==0 && TimeMinute(Time[i]-BrokerGMTShift*3600)==0)
     {  TSO=Time[i];
        TSC=TSO+9*3600;
        TokyoLHigh=High[iHighest(Symbol(),0,MODE_HIGH,9,i-8)];
        TokyoRLow =Low[iLowest(Symbol(),0,MODE_LOW,9,i-8)];
/*        ObjectSet("Tokyo"+IntegerToString(i,2),OBJPROP_STYLE,STYLE_DASH);
        ObjectCreate("Tokyo"+IntegerToString(i,2),OBJ_RECTANGLE,0,TSO,TokyoLHigh,TSC,TokyoRLow);
        ObjectSet("Tokyo"+IntegerToString(i,2),OBJPROP_COLOR,DimGray);
        ObjectCreate("TokyoRange"+IntegerToString(i,2),OBJ_TEXT,0,TSO,TokyoLHigh);
        ObjectSetText("TokyoRange"+IntegerToString(i,2),"Tokyo"+DoubleToStr((TokyoLHigh-TokyoRLow)/Point,0),8,TEXT_FONT,White);
*/        
     }
     if(TimeHour(Time[i]-BrokerGMTShift*3600)==8-DSTOffset && TimeMinute(Time[i]-BrokerGMTShift*3600)==0)
     {  LSO=Time[i];
        LSC=LSO+9*3600;
        LondonLHigh=High[iHighest(Symbol(),0,MODE_HIGH,9,i-8)];
        LondonRLow =Low[iLowest(Symbol(),0,MODE_LOW,9,i-8)];
/*        ObjectCreate("London"+IntegerToString(i,2),OBJ_RECTANGLE,0,LSO,LondonLHigh,LSC,LondonRLow);
        ObjectSet("London"+IntegerToString(i,2),OBJPROP_COLOR,DarkBlue);
        ObjectCreate("LondonRange"+IntegerToString(i,2),OBJ_TEXT,0,LSO,LondonLHigh);
        ObjectSetText("LondonRange"+IntegerToString(i,2),"London"+DoubleToStr((LondonLHigh-LondonRLow)/Point,0),8,TEXT_FONT,White);
*/     }
     if(TimeHour(Time[i]-BrokerGMTShift*3600)==13-DSTOffset && TimeMinute(Time[i]-BrokerGMTShift*3600)==0)
     {  NSO=Time[i];
        NSC=NSO+9*3600;
        NewyorkLHigh=High[iHighest(Symbol(),0,MODE_HIGH,9,i-8)];
        NewyorkRLow =Low[iLowest(Symbol(),0,MODE_LOW,9,i-8)];
/*        ObjectCreate("Newyork"+IntegerToString(i,2),OBJ_RECTANGLE,0,NSO,NewyorkLHigh,NSC,NewyorkRLow);
        ObjectSet("Newyork"+IntegerToString(i,2),OBJPROP_COLOR,DarkGreen);
        ObjectCreate("NewyorkRange"+IntegerToString(i,2),OBJ_TEXT,0,NSO,NewyorkLHigh);
        ObjectSetText("NewyorkRange"+IntegerToString(i,2),"Newyork"+DoubleToStr((NewyorkLHigh-NewyorkRLow)/Point,0),8,TEXT_FONT,White);
*/     }
  } 
  SubDisplay("Broker","BrokerTime: "+TimeToStr(TimeCurrent(),TIME_SECONDS),1,77,3,10,TEXT_FONT,White);
  for(i=0;i<8;i++)
    SubDisplay("TimeVLine"+IntegerToString(i,0),"|",1,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(TimeCurrent())*60+TimeMinute(TimeCurrent()))/5),0)),2+i*12,12,TEXT_FONT,Aqua);
  for(i=0;i<108;i++)
  {  if(TimeHour(TimeCurrent())>=TimeHour(TSO) && TimeHour(TimeCurrent())<TimeHour(TSC))
       SubDisplay("TokyoSession"+IntegerToString(i,0),"|",1,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(TSO)*60+TimeMinute(TSO))/5),0))-i,35,12,TEXT_FONT,Lime);
     else
       SubDisplay("TokyoSession"+IntegerToString(i,0),"|",1,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(TSO)*60+TimeMinute(TSO))/5),0))-i,35,12,TEXT_FONT,Gray);
  }
  SubDisplay("TokyoTime","TokyoTime: "+TimeToStr(TokyoTime,TIME_SECONDS),1,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(TSO)*60+TimeMinute(TSO))/5),0))-160,37,8,TEXT_FONT,White);
  for(i=0;i<108;i++)
  {  if(TimeHour(TimeCurrent())>=TimeHour(LSO) && TimeHour(TimeCurrent())<TimeHour(LSC))
       SubDisplay("LondonSession"+IntegerToString(i,0),"|",1,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(LSO)*60+TimeMinute(LSO))/5),0))-i,50,12,TEXT_FONT,Lime);
     else
       SubDisplay("LondonSession"+IntegerToString(i,0),"|",1,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(LSO)*60+TimeMinute(LSO))/5),0))-i,50,12,TEXT_FONT,Gray);
  }
  SubDisplay("LondonTime","LondonTime: "+TimeToStr(LondonTime,TIME_SECONDS),1,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(LSO)*60+TimeMinute(LSO))/5),0))-160,52,8,TEXT_FONT,White);
  for(i=0;i<108;i++)
  {  if(TimeHour(TimeCurrent())>=TimeHour(NSO) && TimeHour(TimeCurrent())<TimeHour(NSC))
       SubDisplay("NoeyorkSession"+IntegerToString(i,0),"|",1,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(NSO)*60+TimeMinute(NSO))/5),0))-i,65,12,TEXT_FONT,Lime);
     else
       SubDisplay("NoeyorkSession"+IntegerToString(i,0),"|",1,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(NSO)*60+TimeMinute(NSO))/5),0))-i,65,12,TEXT_FONT,Gray);
  } 
  SubDisplay("NewYorkTime","NewYorkTime: "+TimeToStr(NewyorkTime,TIME_SECONDS),1,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(NSO)*60+TimeMinute(NSO))/5),0))-56,67,8,TEXT_FONT,White);
}
//++++++++++++++++++++++++++++++++++++++++++++++++
void SubDisplay(string LabelName,string LabelDoc,int Corner,int TextX,int TextY,int DocSize,string DocStyle,color DocColor)
{ 
   ObjectCreate(LabelName, OBJ_LABEL, 1, 0, 0);
   ObjectSetText(LabelName, LabelDoc, DocSize, DocStyle,DocColor);
   ObjectSet(LabelName, OBJPROP_CORNER, Corner); 
   ObjectSet(LabelName, OBJPROP_XDISTANCE, TextX); 
   ObjectSet(LabelName, OBJPROP_YDISTANCE, TextY); 
   return; 
}

//+------------------------------------------------------------------+
//| Function..: Close Open Order                                           |
//+------------------------------------------------------------------+
void CloseSpecifyOrder(string pair, string notes)
{  int iOrders=OrdersTotal()-1, i;
   if(pair=="NULL")
   {  for(i=iOrders; i>=0; i--) 
      {  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && (OrderType()<=OP_SELL) && GetMarketInfo() && !OrderClose(OrderTicket(),OrderLots(),Price[1-OrderType()],giSlippage)) 
           Print(notes,", ",StringSubstr(OrderComment(),StringLen(OrderComment())-1,1), OrderError());
         else
           Print(notes,", #",StringSubstr(OrderComment(),StringLen(OrderComment())-1,1)," OK!!!");
      }
   }
   else
   {  for(i=iOrders; i>=0; i--)
      {  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) &&
            OrderSymbol() == pair                    &&
            (OrderType()<=OP_SELL)                   &&
            GetMarketInfo()                          &&
            !OrderClose(OrderTicket(),OrderLots(),Price[1-OrderType()],giSlippage))
           Print(notes, ", ",StringSubstr(OrderComment(),StringLen(OrderComment())-1,1),OrderError()); 
         else
           Print(notes,", ",StringSubstr(OrderComment(),StringLen(OrderComment())-1,1)," OK!!!");
      }
   
   }
}
//+------------------------------------------------------------------+
//| Function..: OrderError                                           |
//+------------------------------------------------------------------+
string OrderError() {
  iError=GetLastError();
  return(StringConcatenate(", Order:",OrderTicket(),", Error=",iError,"--",ErrorDescription(iError)));
}

//+------------------------------------------------------------------+
//| Function..: GetMarketInfo                                        |
//| Returns...: bool Success.                                        |
//+------------------------------------------------------------------+
bool GetMarketInfo() {
  RefreshRates();
  Price[0]=MarketInfo(OrderSymbol(),MODE_ASK);
  Price[1]=MarketInfo(OrderSymbol(),MODE_BID);
  double dPoint=MarketInfo(OrderSymbol(),MODE_POINT);
  if(dPoint==0) return(false);
  giSlippage=StrToInteger(DoubleToStr((Price[0]-Price[1])/dPoint,0));
  return(Price[0]>0.0 && Price[1]>0.0);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  ObjectsDeleteAll(); 
  }
 
