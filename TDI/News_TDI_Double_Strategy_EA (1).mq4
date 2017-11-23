//+------------------------------------------------------------------+
//|                                       newTDImethod Dashboard.mq4 |
//|                                    Copyright 2015, Zheng zuodong |
//|                                            https://www.yczzd.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Zheng zuodong"
#property link      "https://www.yczzd.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>
#include <stderror.mqh>

#import  "Wininet.dll"
int InternetOpenW(string,int,string,string,int);
int InternetConnectW(int,string,int,string,string,int,int,int);
int HttpOpenRequestW(int,string,string,int,string,int,string,int);
int InternetOpenUrlW(int,string,string,int,int,int);
int InternetReadFile(int,uchar  &arr[],int,int  &arr[]);
int InternetCloseHandle(int);
#import

#define EA_NAME   "NewTDI_DB"
#define COMMENT   "NewTDI_DB"
#define BullColor Lime
#define BearColor Red
#define TEXT_FONT "Courier New"                             //"Consolas";"Courier New";"Arial Black";
#define READURL_BUFFER_SIZE   150
#define TITLE		0
#define COUNTRY   1
#define DATE		2
#define TIME		3
#define IMPACT		4
#define FORECAST	5
#define PREVIOUS	6

#define CCM1      0
#define CCM5      1
#define CCH1      2
#define CCH4      3
#define CCD1      4

enum  ENUM_TST    {OBOS_TYPE=0, Trend_TYPE=1, News_TYPE=2};

input string          bs              ="===== Basic setup =====";
input bool            UseDefaultPairs =true;                 // Use the default 28 pairs
input string          OwnPairs        ="AUDJPY,AUDUSD,CADJPY,CHFJPY,EURAUD,EURJPY,EURUSD,GBPJPY,USDJPY";                   // Comma seperated own pair list
      string          DefaultPairs[]  ={"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY",
                                        "EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD",
                                        "GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY",
                                        "NZDUSD","USDCAD","USDCHF","USDJPY"};
      string          TradePairs[];
      int             CountPairs;
      string          postfix         =StringSubstr(Symbol(),6,3);
input bool            DisplaySession  =true;                 //Show trade session
input int             BrokerGMTShift  =2;                    //Broker GMT offset
input bool            DST = true;                            //Daylight saving time
      int             DSTOffset; 
      datetime        TSO, LSO, NSO;
      datetime        TSC, LSC, NSC;  
      datetime        TokyoTime, LondonTime, NewyorkTime;    //Tokyo, London, Newyork session Open & Close & Now time

input string          style           ="===== Trading Style =====";
input ENUM_TST        TradingStyle    =2;                    //=0 is OBOS; =1 is Trend; =2 is News
      string          comment;         
input string          news            ="===== News Pending Trading Setup=====";
input int             SecondBeforeNews=55;                    //Pending order Time(second) before Red news post
input int             PendOrderGapPips=10;                    //Gaps of Pending placed away price of current
input double          NewsTPinPips    =50;
input double          RiskMoneyPercent=2;                    //Percentage equity loss for each trade,0 means fix_lots
input double          RiskRatio       =0;                    //Reward/risk ratio, 0 means use ATR to stoploss
input bool            UseMM           =true;                 //Auto calculate Lot,TP,SL
input bool            FilterUseCC     =true;                 //Use Currency Strength Filter and Market Orders
      double          newsBUYLots, newsSELLLots, newsBUYTP, newsBUYSL, newsSELLTP, newsSELLSL, buystopprice, sellstopprice;
      double          UpFractals, DnFractals;
      int             PendOrTradeFlag[28], NewsPendTicket[28][2];
input string          tdi             ="===== TDI setup =====";
input ENUM_TIMEFRAMES TDI_TF          =30;                   //TimeFrame to TDI
input int             RSIPeriod       =13;                   //Period of RSI used TDI  
input int             RSIPrice        =0;                    //Apply Price 0=CLOSE, 1=OPEN, 2=HIGH, 3=LOW, 4=MEDIAN, 5=TYPICAL, 6=WEIGHTED
      int             tdibars;

input string          tm              ="===== Trading Manage =====";
input double          Lots            =0.1;                  //Fix lots
input int             CounterTradeMax =5;                    //Max number of Counter Trading
input int             CounterTradeGap =30;                  //Gap of Counter Trading in Pips,x10 for 5 digits
input double          CounterLotMulti =1;                    //Multi of Lot for Counter Trading
input int             SignalLevelUP   =70;                   //Level of OverBought
input int             SignalLevelDN   =30;                   //Level of OverSell

input string          fs              ="===== Filter setup =====";
input bool            UseNewsFilter   =false;
input bool            ShowNewsEvent   =true;
input int             ShowNewsLines   =10;

      int             CurrentTF, xmlHandle,newsIdx,next,nextNewsIdx,BoEvent,end,begin,minsTillNews,tmpMins,startshow,newsflag[];
static int            UpdateRateSec = 10;
      int             WebUpdateFreq = 240; // 240 Minutes between web updates to not overload FF server
      double          ExtMapBuffer0[];
      string          xmlFileName, xmlSearchName, sData,myEvent, mainData[150][7];
      string          sUrl = "http://www.forexfactory.com/ffcal_week_this.xml";
      string          sTags[7] = {"<title>","<country>","<date><![CDATA[","<time><![CDATA[",
                                  "<impact><![CDATA[","<forecast><![CDATA[","<previous><![CDATA["};
      string          eTags[7] = {"</title>","</country>","]]></date>","]]></time>",
                                  "]]></impact>","]]></forecast>","]]></previous>"};
      datetime        WeekStartTime, newsTime, ReNewsTime[150], Countdown;
      bool            Deinitialized, skip;
      color           NewsColor;
input string          mm              ="===== Money Manage =====";
input double          SinglePairTP    =50;                   //TP of Single Symbol Basket,in $$
input double          SinglePairSL    =150;                  //SL of Single Symbol Basket,in $$
input bool            Breakeven       =true;
input double          BreakevenDollar =25;                   //Breakeven Point of Single pair Basket in $$
input int             BEpoint         =10;                  //Set SL inPips when BreakevenDollar hit,x10 for 5 digits
input double          BasketProfitPercent   =5;              //TP of all Trading in Percent
input double          BasketStoplossPercent =10;             //SL of all Trading in Percent   
      double          MaxProfit, MinProfit;
      datetime        MaxProfitTime, MinProfitTime;
      double          gOrdersInBasket;
      double          gBasketProfit;

input string          cm              ="===== Chart Manage =====";
input string          Usertemplate    ="NewTDImethod.tpl";
input int             x_axis          =15;
input int             y_axis          =50;

struct tdival {
   double  RSIBuf[];
   double  RPLBuf[];
   double  TSLBuf[];
   double  MBLBuf[];
}; tdival tdivalues[];

struct pairinf {
   double PairPoint;
   int    pipsfactor;
   double Pips;
   double spread;
   double digits;
   int    tradecount;
   int    tradeticket[];
   double tradelots[];
   double pairtradelots;
   double tradeopenprice[];
   double totalopenprice;
   double averageopenprice;
   int    tradetype;
   double pairprofit;
   bool   pairBEflag;  
}; pairinf pairinfo[];

struct signal {
   double Signalmaup;
   double Signalmadn;
   double Signaldirup;
   double Signaldirdn;
   double prevSignalusd;
   double buystrength;
   double sellstrength;
}; signal signals[];

struct adrval {
   double adr;
   double adr1;
   double adr5;
   double adr10;
   double adr20;
}; adrval adrvalues[];

color ProfitColor,ProfitColor1,ProfitColor2,ProfitColor3,PipsColor,Color,Color1,Color2,Color3,Color4,Color5,Color6,Color7,Color8,Color9,Color10,
      Color11,Color12,LotColor,LotColor1,OrdColor,OrdColor1;
color BackGrnCol =C'20,20,20';
color LineColor=clrBlack;
color TextColor=clrBlack;
int labelcolor,labelcolor1,labelcolor2=clrNONE,labelcolor3,labelcolor4,labelcolor5,labelcolor6,labelcolor7,
    labelcolor8,labelcolor9,labelcolor10,labelcolor11; 

double blots[28];
int    i,k,p,iError;
double Price[2];
int    giSlippage;

double arrUSD[6][10],arrEUR[6][10],arrGBP[5][10],arrCHF[5][10],arrJPY[5][10],arrAUD[5][10],arrCAD[5][10],arrNZD[5][10];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{

//---Check Symbol for trading
  if (UseDefaultPairs == true)
    ArrayCopy(TradePairs,DefaultPairs);
  else
    StringSplit(OwnPairs,',',TradePairs);
  CountPairs=ArraySize(TradePairs);
  if (CountPairs <= 0) 
  {
    Print("No pairs to trade");
    return(INIT_FAILED);
  }
//---check trading style
  if(TradingStyle==0)  
    comment=COMMENT+"(OBOS)";
  else if(TradingStyle==1)
    comment=COMMENT+"(Trend)";
  else if(TradingStyle==2)
    comment=COMMENT+"(News)";
  
//---Init array size   
  ArrayResize(adrvalues,CountPairs);
  ArrayResize(signals,CountPairs);
  ArrayResize(pairinfo,CountPairs); 
  ArrayResize(newsflag,CountPairs); 
  
  SetPanel("MaxProfit",0,x_axis+200,y_axis-40,260,20,Gold,Green,2);
  SetText("Maxprofit","Max Profit:",x_axis+203,y_axis-38,Green,11);
  SetPanel("Mprofit",0,x_axis+300,y_axis-40,80,20,0,Green,2);
  Create_Button("CloseAll","CLOSE ALL",78,20,x_axis+483,y_axis-40,Red,White,12);
  SetPanel("MaxLoss",0,x_axis+585,y_axis-40,260,20,Gold,Red,2);
  SetText("maxloss","Min Profit: ",x_axis+588,y_axis-38,Red,11);
  SetPanel("Mloss",0,x_axis+685,y_axis-40,80,20,0,Red,2);
  
  SetPanel("Title",0,x_axis,y_axis-20,900,20,Blue,LineColor,1);
  SetText("TitleText1","  SYMBOL   SPREAD  PIPS  IMP  Countdwon  Currency",x_axis,y_axis-17,White,9);
  SetText("TitleText2","  ATR5    TSL1     RPL1     TSL0     RPL0",x_axis+350,y_axis-17,White,9);
  SetText("TitleText3","  ORDERS  LOTS  PROFIT  ",x_axis+650,y_axis-17,White,9);
  SetPanel("totalprofit",0,x_axis+819,y_axis-20,80,20,White,Blue,1);

  for(i=0;i<=8;i++)  {
  SetPanel("tf"+IntegerToString(i),0,825,110+i*21,390,20,Blue,Gray,1);
  SetPanel("tf1"+IntegerToString(i),0,865,110+i*21,350,20,0,Gray,1);
  SetPanel("tf2"+IntegerToString(i),0,935,110+i*21,210,20,0,Gray,1);
  SetPanel("tf3"+IntegerToString(i),0,1005,110+i*21,70,20,0,Gray,1);
  }
  SubDisplay("textile","Currency Strength Meter",0,915,85,12,"Arial Black",Pink);
  SetText("tftext","   M1     M5     H1     H4    D1",865,111,White,12);
  SetText("cu1","USD",827,132,White,12);
  SetText("cu2","EUR",827,153,White,12);
  SetText("cu3","GBP",827,174,White,12);
  SetText("cu4","CHF",827,195,White,12);
  SetText("cu5","AUD",827,216,White,12);
  SetText("cu6","CAD",827,237,White,12);
  SetText("cu7","JPY",827,258,White,12);
  SetText("cu8","NZD",827,279,White,12);
  
   
  for(i=0;i<CountPairs;i++)
  {
    NewsPendTicket[i][0]=0;
    NewsPendTicket[i][1]=0;
    PendOrTradeFlag[i]=0;
//---Init pairs infomation    
    TradePairs[i] = TradePairs[i]+postfix;
    if (MarketInfo(TradePairs[i] ,MODE_DIGITS) == 4 || MarketInfo(TradePairs[i] ,MODE_DIGITS) == 2) 
    {  pairinfo[i].PairPoint = MarketInfo(TradePairs[i] ,MODE_POINT);
       pairinfo[i].pipsfactor = 1;  
    } 
    else { 
      pairinfo[i].PairPoint = MarketInfo(TradePairs[i] ,MODE_POINT)/10.0;
      pairinfo[i].pipsfactor = 10;
    }
    
//    pairinfo[i].point   =MarketInfo(TradePairs[i],MODE_POINT);
    pairinfo[i].digits  =MarketInfo(TradePairs[i],MODE_DIGITS);
    ArrayResize(pairinfo[i].tradeticket,CounterTradeMax+1);
    ArrayResize(pairinfo[i].tradelots,CounterTradeMax+1);
    ArrayResize(pairinfo[i].tradeopenprice,CounterTradeMax+1);
//    pairinfo[i].tradecount =0;
//    pairinfo[i].pairtradelots =0;
//    pairinfo[i].totalopenprice =0;
//    pairinfo[i].averageopenprice =0;
//    pairinfo[i].tradetype =0;
//    pairinfo[i].pairprofit =0;
//    pairinfo[i].pairBEflag =false;
//---Init Dashboard infomation 
    SetText("index"+IntegerToString(i),IntegerToString(i+1,2,'0'),x_axis-15,y_axis+1+(i*16),White,9);
    Create_Button(IntegerToString(i)+"Pair",TradePairs[i],70 ,17,x_axis ,y_axis+(i*16),DarkGray,Black,9);
    SetPanel("Spread"+IntegerToString(i),0,x_axis+72,y_axis+(i*16),50,17,labelcolor,C'61,61,61',1);
    SetPanel("Pips"+IntegerToString(i),0,x_axis+125,y_axis+(i*16),40,17,labelcolor,C'61,61,61',1);
    SetPanel("IMP"+IntegerToString(i),0,x_axis+167,y_axis+(i*16),40,17,labelcolor,C'61,61,61',1);         
    SetPanel("Countdwon"+IntegerToString(i),0,x_axis+209,y_axis+(i*16),65,17,BackGrnCol,C'61,61,61',1);
    SetPanel("Currency"+IntegerToString(i),0,x_axis+276,y_axis+(i*16),70,17,BackGrnCol,C'61,61,61',1);
    SetPanel("atr"+IntegerToString(i),0,x_axis+348,y_axis+(i*16),55,17,BackGrnCol,C'61,61,61',1);
    SetPanel("Tsl1"+IntegerToString(i),0,x_axis+405,y_axis+(i*16),60,17,BackGrnCol,Red,1);
    SetPanel("Rpl1"+IntegerToString(i),0,x_axis+467,y_axis+(i*16),60,17,BackGrnCol,Lime,1);
    SetPanel("Tsl0"+IntegerToString(i),0,x_axis+529,y_axis+(i*16),60,17,BackGrnCol,Red,1);
    SetPanel("Rpl0"+IntegerToString(i),0,x_axis+591,y_axis+(i*16),60,17,BackGrnCol,Lime,1);

   }
//Get current time frame
   CurrentTF=Period();
//With the first DLL call below, the program will exit (and stop) automatically after one alert. 
   if(!IsDllsAllowed())
     {
      Alert(Symbol()," ",Period(),", FFCal: Allow DLL Imports");
     }
//Management of FFCal.xml Files involves setting up a search to find and delete files
//that are not of this Sunday date.  This search is limited to 10 weeks back (604800 seconds). 
//Files with Sunday dates that are older will not be purged by this search and will have to be
//manually deleted by the user.
   xmlFileName=GetXmlFileName();
   for(datetime t=WeekStartTime;t>=WeekStartTime-6048000;t=t-604800)
     {
      xmlSearchName=(StringConcatenate(TimeYear(t),"-",
                     PadString(DoubleToStr(TimeMonth(t),0),"0",2),"-",
                     PadString(DoubleToStr(TimeDay(t),0),"0",2),"-FFCal-News",".xml"));
      xmlHandle=FileOpen(xmlSearchName,FILE_BIN|FILE_READ);
      if(xmlHandle>=0) //file exists.  A return of -1 means file does not exist.
        {
         FileClose(xmlHandle);
         if(xmlSearchName!=xmlFileName)FileDelete(xmlSearchName);
        }
     }
   SetIndexBuffer(0,ExtMapBuffer0);
   SetIndexStyle(0,DRAW_NONE);
   IndicatorShortName("FxNewsCal");
   Deinitialized=false;
   
   EventSetTimer(2);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   ObjectsDeleteAll();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTimer()
{
int RemainTime=0;
  
  for(i=0;i<CountPairs;i++)  {
    pairinfo[i].tradecount =0;
    pairinfo[i].pairtradelots =0;
    pairinfo[i].totalopenprice =0;
    pairinfo[i].averageopenprice =0;
    pairinfo[i].tradetype =0;
    pairinfo[i].pairprofit =0;
    pairinfo[i].pairBEflag =false;
    newsflag[i]=0;
    NewsPendTicket[i][0]=0;
    NewsPendTicket[i][1]=0;
    PendOrTradeFlag[i]=0;    
  }  
//   gOrdersInBasket=0;
//   gBasketProfit=0;
  for(i=0;i<150;i++)  {
    for(k=0;k<7;k++)  {
      mainData[i][k]="";
    }
    ReNewsTime[i]=0;
  }
//---
  CheckBasketProfit();
  Calc_TDI();
  NewsCalendar(ShowNewsEvent);
  if(DisplaySession==true)
    Session_Boxes();
//---Check exist orders
  for(i=0; i<OrdersTotal(); i++)
  {  if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true)
     {  for(p=0;p<CountPairs;p++)
        {  if(OrderSymbol()!=TradePairs[p])     continue;
           else if(StringFind(OrderComment(),comment,0)!=-1)
           {  if(pairinfo[p].tradecount<=StrToInteger(StringSubstr(OrderComment(),StringLen(OrderComment())-1,0)))
              {  pairinfo[p].tradecount=StrToInteger(StringSubstr(OrderComment(),StringLen(OrderComment())-1,0));
                 pairinfo[p].tradeticket[pairinfo[p].tradecount-1]= OrderTicket();
                 pairinfo[p].tradeopenprice[pairinfo[p].tradecount-1]= OrderOpenPrice();
                 pairinfo[p].pairtradelots += OrderLots();
                 pairinfo[p].tradelots[pairinfo[p].tradecount-1]= OrderLots();
                 if(OrderStopLoss()!=0)  pairinfo[p].pairBEflag=true;
                 pairinfo[p].tradetype= OrderType();
                 pairinfo[p].pairprofit += OrderProfit()+OrderSwap();
              }
           }
        }
     }
     else
     {
        iError=GetLastError();
        Print("Order Select(when check exist order) Error: ",iError,"--",ErrorDescription(iError));
     }
  }
//---Calculate and Fill Pairs information and TDI data.
  SetText("maxprofit",DoubleToString(MaxProfit,2),x_axis+305,y_axis-38,Lime,11);
  SetText("maxprofittime",TimeToStr(MaxProfitTime,TIME_SECONDS),x_axis+382,y_axis-38,White,11);
  SetText("minprofit",DoubleToString(MinProfit,2),x_axis+690,y_axis-38,Red,11);
  SetText("minprofittime",TimeToStr(MinProfitTime,TIME_SECONDS),x_axis+767,y_axis-38,White,11);
  if(gBasketProfit>=0)
    SetText("TotalProfit",DoubleToStr(gBasketProfit,2),x_axis+825,y_axis-17,Green,11);
  else
    SetText("TotalProfit",DoubleToStr(gBasketProfit,2),x_axis+825,y_axis-17,Red,11);
  
  for(i=0;i<CountPairs;i++)
  {  pairinfo[i].spread=MarketInfo(TradePairs[i],MODE_SPREAD)/pairinfo[i].pipsfactor;
     pairinfo[i].Pips =(iClose(TradePairs[i],PERIOD_D1,0)-iOpen(TradePairs[i], PERIOD_D1,0))/MarketInfo(TradePairs[i],MODE_POINT)/pairinfo[i].pipsfactor;     
     SetText("spread"+IntegerToString(i),DoubleToStr(pairinfo[i].spread,1),x_axis+72+8,y_axis+(i*16),Gold,9);
     if(pairinfo[i].Pips<0)
       SetText("pips"+IntegerToString(i),DoubleToStr(MathAbs(pairinfo[i].Pips),0),x_axis+125+8,y_axis+(i*16),Red,9);
     else
       SetText("pips"+IntegerToString(i),DoubleToStr(MathAbs(pairinfo[i].Pips),0),x_axis+125+8,y_axis+(i*16),Lime,9);
     SetText("atr5"+IntegerToString(i),DoubleToStr(iATR(TradePairs[i],PERIOD_D1,5,0),MarketInfo(TradePairs[i],MODE_DIGITS)),x_axis+348,y_axis+(i*16),Aqua,9);
     SetText("tsl1"+IntegerToString(i),DoubleToStr(tdivalues[i].TSLBuf[1],4),x_axis+405,y_axis+(i*16),Gray,9);
     SetText("rpl1"+IntegerToString(i),DoubleToStr(tdivalues[i].RPLBuf[1],4),x_axis+467,y_axis+(i*16),Gray,9);
     SetText("tsl0"+IntegerToString(i),DoubleToStr(tdivalues[i].TSLBuf[0],4),x_axis+529,y_axis+(i*16),White,9);
     SetText("rpl0"+IntegerToString(i),DoubleToStr(tdivalues[i].RPLBuf[0],4),x_axis+591,y_axis+(i*16),White,9);
     if(pairinfo[i].tradecount==0)
     {  SetText("orders"+IntegerToString(i),DoubleToStr(pairinfo[i].tradecount,0),x_axis+668,y_axis+(i*16),Gray,9);
        SetText("totallots"+IntegerToString(i),DoubleToStr(pairinfo[i].pairtradelots,2),x_axis+720,y_axis+(i*16),Gray,9);
     }     
     if(pairinfo[i].tradecount>0 && pairinfo[i].tradetype==OP_BUY)
     {  SetText("orders"+IntegerToString(i),DoubleToStr(pairinfo[i].tradecount,0),x_axis+668,y_axis+(i*16),Lime,9);
        SetText("totallots"+IntegerToString(i),DoubleToStr(pairinfo[i].pairtradelots,2),x_axis+720,y_axis+(i*16),Lime,9);
     }
     if(pairinfo[i].tradecount>0 && pairinfo[i].tradetype==OP_SELL)
     {  SetText("orders"+IntegerToString(i),DoubleToStr(pairinfo[i].tradecount,0),x_axis+668,y_axis+(i*16),Red,9);
        SetText("totallots"+IntegerToString(i),DoubleToStr(pairinfo[i].pairtradelots,2),x_axis+720,y_axis+(i*16),Red,9);
     }       
     if(pairinfo[i].pairprofit>0)
       SetText("pairprofit"+IntegerToString(i),DoubleToStr(pairinfo[i].pairprofit,2),x_axis+770,y_axis+(i*16),Lime,9);
     else if(pairinfo[i].pairprofit<0)
       SetText("pairprofit"+IntegerToString(i),DoubleToStr(MathAbs(pairinfo[i].pairprofit),2),x_axis+770,y_axis+(i*16),Red,9);
     else
       SetText("pairprofit"+IntegerToString(i),DoubleToStr(MathAbs(pairinfo[i].pairprofit),2),x_axis+770,y_axis+(i*16),Gray,9);

  }
//+-----Display Currency Strength
color ccColor;
  for(i=0;i<5;i++)
  {  switch(i)
     {  case 0:  Cc(PERIOD_M1);  
        case 1:  Cc(PERIOD_M5);  
        case 2:  Cc(PERIOD_H1);  
        case 3:  Cc(PERIOD_H4);  
        case 4:  Cc(PERIOD_D1);  
     }
  }
  for(i=0;i<5;i++)
  {  SubDisplay("ccUSD"+IntegerToString(i), DoubleToStr(arrUSD[i][1]*10000,0),0,870+i*70,135,9,"Consolas",DarkGray);
     if(arrUSD[i][0]<arrUSD[i][1])  ccColor=Red;
     else  ccColor=Lime;
     SubDisplay("ccUSD1"+IntegerToString(i), "|"+DoubleToStr(arrUSD[i][0]*10000,0),0,900+i*70,135,9,"Consolas",ccColor);
     SubDisplay("ccEUR"+IntegerToString(i), DoubleToStr(arrEUR[i][1]*10000,0),0,870+i*70,156,9,"Consolas",DarkGray);
     if(arrEUR[i][0]<arrEUR[i][1])  ccColor=Red;
     else  ccColor=Lime;
     SubDisplay("ccEUR1"+IntegerToString(i), "|"+DoubleToStr(arrEUR[i][0]*10000,0),0,900+i*70,156,9,"Consolas",ccColor);
     SubDisplay("ccGBP"+IntegerToString(i), DoubleToStr(arrGBP[i][1]*10000,0),0,870+i*70,177,9,"Consolas",DarkGray);
     if(arrGBP[i][0]<arrGBP[i][1])  ccColor=Red;
     else  ccColor=Lime;
     SubDisplay("ccGBP1"+IntegerToString(i), "|"+DoubleToStr(arrGBP[i][0]*10000,0),0,900+i*70,177,9,"Consolas",ccColor);    
     SubDisplay("ccCHF"+IntegerToString(i), DoubleToStr(arrCHF[i][1]*10000,0),0,870+i*70,198,9,"Consolas",DarkGray);
     if(arrCHF[i][0]<arrCHF[i][1])  ccColor=Red;
     else  ccColor=Lime;
     SubDisplay("ccCHF1"+IntegerToString(i), "|"+DoubleToStr(arrCHF[i][0]*10000,0),0,900+i*70,198,9,"Consolas",ccColor);    
     SubDisplay("ccAUD"+IntegerToString(i), DoubleToStr(arrAUD[i][1]*10000,0),0,870+i*70,219,9,"Consolas",DarkGray);
     if(arrAUD[i][0]<arrAUD[i][1])  ccColor=Red;
     else  ccColor=Lime;
     SubDisplay("ccAUD1"+IntegerToString(i), "|"+DoubleToStr(arrAUD[i][0]*10000,0),0,900+i*70,219,9,"Consolas",ccColor);
     SubDisplay("ccCAD"+IntegerToString(i), DoubleToStr(arrCAD[i][1]*10000,0),0,870+i*70,240,9,"Consolas",DarkGray);
     if(arrCAD[i][0]<arrCAD[i][1])  ccColor=Red;
     else  ccColor=Lime;
     SubDisplay("ccCAD1"+IntegerToString(i), "|"+DoubleToStr(arrCAD[i][0]*10000,0),0,900+i*70,240,9,"Consolas",ccColor);
     SubDisplay("ccJPY"+IntegerToString(i), DoubleToStr(arrJPY[i][1]*10000,0),0,870+i*70,261,9,"Consolas",DarkGray);
     if(arrJPY[i][0]<arrJPY[i][1])  ccColor=Red;
     else  ccColor=Lime;
     SubDisplay("ccJPY1"+IntegerToString(i), "|"+DoubleToStr(arrJPY[i][0]*10000,0),0,900+i*70,261,9,"Consolas",ccColor);
     SubDisplay("ccNZD"+IntegerToString(i), DoubleToStr(arrNZD[i][1]*10000,0),0,870+i*70,282,9,"Consolas",DarkGray);
     if(arrNZD[i][0]<arrNZD[i][1])  ccColor=Red;
     else  ccColor=Lime;
     SubDisplay("ccNZD1"+IntegerToString(i), "|"+DoubleToStr(arrNZD[i][0]*10000,0),0,900+i*70,282,9,"Consolas",ccColor);                         
  }
  
//+----Display news in 12h  
  for(k=0;k<newsIdx;k++)
  {  if(ReNewsTime[k]<TimeCurrent() && ReNewsTime[k+1]>=TimeCurrent())
       startshow=k+1;
  }
  for(p=newsIdx;p>=startshow;p--)
  {  
   for(i=0;i<CountPairs;i++)
   { 

     if((StringFind(TradePairs[i],mainData[p][COUNTRY],0)!=-1)
        && (mainData[p][IMPACT]=="High" || mainData[p][IMPACT]=="Medium")
        && (ReNewsTime[p]-TimeCurrent())<12*3600)
     {  if(mainData[p][IMPACT]=="High")
          NewsColor=clrRed;
        if(mainData[p][IMPACT]=="Medium")
          NewsColor=clrYellow;
//        if(mainData[p][IMPACT]=="Low")
//          NewsColor=clrLime;
        SetObjText("imp"+IntegerToString(i),CharToStr('M'),x_axis+167+2,y_axis+(i*16),NewsColor,12);  
        SetText("countdown"+IntegerToString(i),TimeToStr((ReNewsTime[p]-TimeCurrent()),TIME_SECONDS),x_axis+209+5,y_axis+(i*16),NewsColor,9);
        SetText("currency"+IntegerToString(i),mainData[p][COUNTRY],x_axis+280,y_axis+(i*16),NewsColor,9);
     }
     if (ReNewsTime[p]-TimeCurrent()<=0)
     {
       SetObjText("imp"+IntegerToString(i),"",x_axis+167+2,y_axis+(i*16),0,12);  
       SetText("countdown"+IntegerToString(i),"",x_axis+209+5,y_axis+(i*16),0,9);
       SetText("currency"+IntegerToString(i),"",x_axis+280,y_axis+(i*16),0,9);     
     }
   }
  }
  
//---Check breakeven,if profit more than BE, then setup SL to OpenPrice+5 or -5
  for(i=0;i<CountPairs;i++)
  {  if(pairinfo[i].tradecount>0 && pairinfo[i].pairBEflag==false && 
        pairinfo[i].pairprofit>=BreakevenDollar && Breakeven==true)
     {  for(p=0;p<pairinfo[i].tradecount;p++)
          pairinfo[i].totalopenprice += pairinfo[i].tradeopenprice[p];
        pairinfo[i].averageopenprice=pairinfo[i].totalopenprice/pairinfo[i].tradecount;
        for(p=0;p<pairinfo[i].tradecount;p++)
        {  if(pairinfo[i].tradetype==OP_BUY)
           {  if(OrderModify(pairinfo[i].tradeticket[p],pairinfo[i].tradeopenprice[p],
                    NormalizeDouble(pairinfo[i].averageopenprice+BEpoint*pairinfo[i].PairPoint,int(pairinfo[i].digits)),0,0,Blue)==true)
              {  pairinfo[i].pairBEflag=true; Print("Ticket #",pairinfo[i].tradeticket[p],", BreakEven is hit, buySL Modify OOKK!!");}
              else
                Print("Ticket #",pairinfo[i].tradeticket[p],", BreakEven is hit, but SL Modify error ",OrderError());           
           }
           if(pairinfo[i].tradetype==OP_SELL)
           {  if(OrderModify(pairinfo[i].tradeticket[p],pairinfo[i].tradeopenprice[p],
                    NormalizeDouble(pairinfo[i].averageopenprice-BEpoint*pairinfo[i].PairPoint,int(pairinfo[i].digits)),0,0,Blue)==true)
              {  pairinfo[i].pairBEflag=true; Print("Ticket #",pairinfo[i].tradeticket[p],", BreakEven is hit, sellSL Modify OOKK!!");}
              else
                Print("Ticket #",pairinfo[i].tradeticket[p],", BreakEven is hit, but SL Modify error ",OrderError());           
           }
        }
     } 
//---Check single pair profit. if >SinglePairTP or <SL,then close the pair  
    if(pairinfo[i].tradecount>0 && TradingStyle==OBOS_TYPE && (pairinfo[i].pairprofit>=SinglePairTP || pairinfo[i].pairprofit<=(-1)*SinglePairSL))  
      CloseSpecifyOrder(TradePairs[i],"Single pair basket profit or lost hited, close specified pair "+TradePairs[i]);
//---if Trade Signal Line(Red line) above  SignalLevelUP, or below SignalLevelDN, Close single pair positions in profit
    else if(pairinfo[i].tradecount>0 && TradingStyle==OBOS_TYPE && pairinfo[i].tradetype==OP_BUY && 
           tdivalues[i].TSLBuf[0]>SignalLevelUP && tdivalues[i].RPLBuf[0]<tdivalues[i].TSLBuf[0])
      CloseSpecifyOrder(TradePairs[i]," TSL[0] > SignalLevelUP, close specified pair "+TradePairs[i]+" BUY order");
    else if(pairinfo[i].tradecount>0 && TradingStyle==OBOS_TYPE && pairinfo[i].tradetype==OP_SELL &&
           tdivalues[i].TSLBuf[0]<SignalLevelDN && tdivalues[i].RPLBuf[0]>tdivalues[i].TSLBuf[0])
      CloseSpecifyOrder(TradePairs[i]," TSL[0] < SignalLevelDN, close specified pair "+TradePairs[i]+" SELL order");
//---if price run opposite direction to order, then add order(Lots=Lots*CounterLotMulti^n)
    else if(pairinfo[i].tradecount>0 && TradingStyle==OBOS_TYPE && pairinfo[i].tradecount<=CounterTradeMax)
    {  double CounterLots=NormalizeDouble(Lots*MathPow(CounterLotMulti,pairinfo[i].tradecount),1);
       if(pairinfo[i].tradetype==OP_BUY)
       {  if(pairinfo[i].tradeopenprice[pairinfo[i].tradecount-1]-MarketInfo(TradePairs[i],MODE_ASK) >=CounterTradeGap*pairinfo[i].PairPoint)
          {  if(OrderSend(TradePairs[i],pairinfo[i].tradetype,CounterLots,MarketInfo(TradePairs[i],MODE_ASK),
                3,0,0,comment+IntegerToString(pairinfo[i].tradecount+1,0),0,0,Green)==false)
             {  iError=GetLastError();
                Print("Open ",TradePairs[i]," ",IntegerToString(pairinfo[i].tradecount+1,0),"# Buy Order(when Check counterTrade) error:", iError,"--",ErrorDescription(iError));
             }
             else
               Print("Open ",TradePairs[i]," ",IntegerToString(pairinfo[i].tradecount+1,0),"# Buy Order(when Check counterTrade) OOKK!");
          }
       }
       if(pairinfo[i].tradetype==OP_SELL)
       {  if(MarketInfo(TradePairs[i],MODE_BID)-pairinfo[i].tradeopenprice[pairinfo[i].tradecount-1] >=CounterTradeGap*pairinfo[i].PairPoint)
          {  if(OrderSend(TradePairs[i],pairinfo[i].tradetype,CounterLots,MarketInfo(TradePairs[i],MODE_BID),
                3,0,0,comment+IntegerToString(pairinfo[i].tradecount+1,0),0,0,Green)==false)
             {  iError=GetLastError();
                Print("Open ",TradePairs[i]," ",IntegerToString(pairinfo[i].tradecount+1,0),"# Sell Order(when Check counterTrade) error:", iError,"--",ErrorDescription(iError));
             }
             else
               Print("Open ",TradePairs[i]," ",IntegerToString(pairinfo[i].tradecount+1,0),"# Sell Order(when Check counterTrade) OOKK!");
          }
       }
    }
//---RPL and TSL have crossed in pre-two candles, then open order if next candle trend continue yet
    else if(pairinfo[i].tradecount==0 && TradingStyle==OBOS_TYPE && tdivalues[i].RPLBuf[0]<tdivalues[i].RPLBuf[1]-0.2 &&
            tdivalues[i].RPLBuf[1]<tdivalues[i].TSLBuf[1] &&
            tdivalues[i].RPLBuf[2]>tdivalues[i].TSLBuf[2] &&
            tdivalues[i].TSLBuf[0]>SignalLevelUP)
    {  if(OrderSend(TradePairs[i],OP_SELL,Lots,MarketInfo(TradePairs[i],MODE_BID),3,0,0,comment+IntegerToString(1,0),0,0,Green)==false)
       {  iError=GetLastError();
          Print("Open ",TradePairs[i]," 1# Sell Order(when Check TDI's signal) error:", iError,"--",ErrorDescription(iError));
       }
       else
         Print("Open ",TradePairs[i]," 1# Sell Order(when Check TDI's signal) OOKK!");
    }
    else if(pairinfo[i].tradecount==0 && TradingStyle==OBOS_TYPE && tdivalues[i].RPLBuf[0]>tdivalues[i].RPLBuf[1]+0.2 &&
            tdivalues[i].RPLBuf[1]>tdivalues[i].TSLBuf[1] && 
            tdivalues[i].RPLBuf[2]<tdivalues[i].TSLBuf[2] &&
            tdivalues[i].TSLBuf[0]<SignalLevelDN)
    {  if(OrderSend(TradePairs[i],OP_BUY,Lots,MarketInfo(TradePairs[i],MODE_ASK),3,0,0,comment+IntegerToString(1,0),0,0,Green)==false)
       {  iError=GetLastError();
          Print("Open ",TradePairs[i]," 1# Buy Order(when Check TDI's sign) error:", iError,"--",ErrorDescription(iError));
       }
       else
         Print("Open ",TradePairs[i]," 1# Buy Order(when Check TDI's sign) OOKK!");
    }
  }
  if(TradingStyle==News_TYPE)
     RedNewsTrade();
  ChartRedraw(0); 
}
//+------------------------------------------------------------------+
void SetPanel(string name,int sub_window,int x,int y,int width,int height,color bg_color,color border_clr,int border_width)
  {
   if(ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(0,name,OBJPROP_COLOR,border_clr);
      ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,name,OBJPROP_WIDTH,border_width);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,0);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
     }
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg_color);
  }
//+------------------------------------------------------------------+

void SetText(string name,string text,int x,int y,color colour,int fontsize)
  {
   if (ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);

    ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
    ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
    ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
    ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
    ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
//    ObjectSetString(0,name,OBJPROP_TEXT,text);
    ObjectSetText(name,text,fontsize,TEXT_FONT,colour);
  }
//+------------------------------------------------------------------+

void SetObjText(string name,string charTostr,int x,int y,color colour,int fontsize)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);

   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_TEXT,charTostr);
   ObjectSetString(0,name,OBJPROP_FONT,"Wingdings");
  }  
//+------------------------------------------------------------------+
  
void Create_Button(string but_name,string label,int xsize,int ysize,int xdist,int ydist,int bcolor,int fcolor,int fontsize)
{
   if(ObjectFind(0,but_name)<0)
   {
      if(!ObjectCreate(0,but_name,OBJ_BUTTON,0,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create the button! Error code = ",GetLastError());
         return;
        }
      ObjectSetInteger(0,but_name,OBJPROP_XSIZE,xsize);
      ObjectSetInteger(0,but_name,OBJPROP_YSIZE,ysize);
      ObjectSetInteger(0,but_name,OBJPROP_CORNER,CORNER_LEFT_UPPER);     
      ObjectSetInteger(0,but_name,OBJPROP_XDISTANCE,xdist);      
      ObjectSetInteger(0,but_name,OBJPROP_YDISTANCE,ydist);         
      ObjectSetInteger(0,but_name,OBJPROP_BGCOLOR,bcolor);
     ObjectSetInteger(0,but_name,OBJPROP_COLOR,fcolor);
//      ObjectSetInteger(0,but_name,OBJPROP_FONTSIZE,9);
      ObjectSetText(but_name,label,fontsize,TEXT_FONT,fcolor);
//      ObjectSetInteger(0,but_name,OBJPROP_HIDDEN,true);
      //ObjectSetInteger(0,but_name,OBJPROP_BORDER_COLOR,ChartGetInteger(0,CHART_COLOR_FOREGROUND));
//      ObjectSetInteger(0,but_name,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      
      ChartRedraw();      
   }
}  
  
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,  const long &lparam, const double &dparam,  const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
  
      {
/*      if (sparam==button_close_basket_All)
        {
               ObjectSetString(0,button_close_basket_All,OBJPROP_TEXT,"Closing...");               
               close_basket(Magic_Number);
               ObjectSetInteger(0,button_close_basket_All,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_All,OBJPROP_TEXT,"Close Basket"); 
               return;
        }

     if (StringFind(sparam,"CLOSE") >= 0)
        {
               int ind = StringToInteger(sparam);
               closeOpenOrders(TradePairs[ind]);               
               ObjectSetInteger(0,ind+"CLOSE",OBJPROP_STATE,0);
               ObjectSetString(0,ind+"CLOSE",OBJPROP_TEXT,"CLOSE");
               return;
        }
*/        
      if (StringFind(sparam,"Pair") >= 0) {
         int ind = int(StringToInteger(sparam));
         ObjectSetInteger(0,sparam,OBJPROP_STATE,0);
         OpenChart(ind);
         return;         
      }   
     }
}

//+------------------------------------------------------------------+
void OpenChart(int ind) 
{
long nextchart = ChartFirst();
   do {
      string sym = ChartSymbol(nextchart);
      if (StringFind(sym,TradePairs[ind]) >= 0) {
            ChartSetInteger(nextchart,CHART_BRING_TO_TOP,true);
            ChartSetSymbolPeriod(nextchart,TradePairs[ind],TDI_TF);
            ChartApplyTemplate(nextchart,Usertemplate);
            return;
         }
   } while ((nextchart = ChartNext(nextchart)) != -1);
   long newchartid = ChartOpen(TradePairs[ind],TDI_TF);
   ChartApplyTemplate(newchartid,Usertemplate);
 }

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 void GetAdrValues() {

   double s=0.0;
   for ( i=0;i<ArraySize(TradePairs);i++) {
      for(int a=1;a<=20;a++) {
      pairinfo[i].PairPoint=(iClose(TradePairs[i],PERIOD_D1,0)-iOpen(TradePairs[i], PERIOD_D1,0))/MarketInfo(TradePairs[i],MODE_POINT);
         if(pairinfo[i].PairPoint != 0)
            s=s+(iHigh(TradePairs[i],PERIOD_D1,a)-iLow(TradePairs[i],PERIOD_D1,a))/pairinfo[i].PairPoint;
         if(a==1)
            adrvalues[i].adr1=MathRound(s);
         if(a==5)
            adrvalues[i].adr5=MathRound(s/5);
         if(a==10)
            adrvalues[i].adr10=MathRound(s/10);
         if(a==20)
            adrvalues[i].adr20=MathRound(s/20);
      }
      adrvalues[i].adr=MathRound((adrvalues[i].adr1+adrvalues[i].adr5+adrvalues[i].adr10+adrvalues[i].adr20)/4.0);
      s=0.0;
   }
 }
 //++++++++++++++++++++++++++++++++++++++++++++++++++
string AlignStr(string text, int len)
{
  int textlength;
  
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
  int Range = 200;


  for(i=0;i<=288;i++)
  {  SubDisplay("Gray"+IntegerToString(i,0),"|",3,5+i,1,12,TEXT_FONT,Green);
     if(MathMod(i,12)==0)
       SubDisplay("BrokerTime"+IntegerToString(i,0),"|",3,5+i,11,12,TEXT_FONT,Green);
  }
  int n=0;
  for(i=288;i>=0;i--)
  {   
      if(MathMod(i,24)==0)
      {  
         SubDisplay("Time"+IntegerToString(i,0),IntegerToString(n,0),3,5+i,21,8,TEXT_FONT,Lime);
         n=n+2;
      }
  }
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
     }
     if(TimeHour(Time[i]-BrokerGMTShift*3600)==8-DSTOffset && TimeMinute(Time[i]-BrokerGMTShift*3600)==0)
     {  LSO=Time[i];
        LSC=LSO+9*3600;
        LondonLHigh=High[iHighest(Symbol(),0,MODE_HIGH,9,i-8)];
        LondonRLow =Low[iLowest(Symbol(),0,MODE_LOW,9,i-8)];
     }
     if(TimeHour(Time[i]-BrokerGMTShift*3600)==13-DSTOffset && TimeMinute(Time[i]-BrokerGMTShift*3600)==0)
     {  NSO=Time[i];
        NSC=NSO+9*3600;
        NewyorkLHigh=High[iHighest(Symbol(),0,MODE_HIGH,9,i-8)];
        NewyorkRLow =Low[iLowest(Symbol(),0,MODE_LOW,9,i-8)];
    }
  } 
  SubDisplay("Broker","BrokerTime: "+TimeToStr(TimeCurrent(),TIME_SECONDS),3,77,1,10,TEXT_FONT,White);
  for(i=0;i<8;i++)
    SubDisplay("TimeVLine"+IntegerToString(i,0),"|",3,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(TimeCurrent())*60+TimeMinute(TimeCurrent()))/5),0)),2+i*12,12,TEXT_FONT,Aqua);
  for(i=0;i<108;i++)
  {  if(TimeHour(TimeCurrent())>=TimeHour(TSO) && TimeHour(TimeCurrent())<TimeHour(TSC))
       SubDisplay("TokyoSession"+IntegerToString(i,0),"|",3,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(TSO)*60+TimeMinute(TSO))/5),0))-i,35,12,TEXT_FONT,Lime);
     else
       SubDisplay("TokyoSession"+IntegerToString(i,0),"|",3,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(TSO)*60+TimeMinute(TSO))/5),0))-i,35,12,TEXT_FONT,Gray);
  }
  SubDisplay("TokyoTime","TokyoTime: "+TimeToStr(TokyoTime,TIME_SECONDS),3,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(TSO)*60+TimeMinute(TSO))/5),0))-160,37,8,TEXT_FONT,White);
  for(i=0;i<108;i++)
  {  if(TimeHour(TimeCurrent())>=TimeHour(LSO) && TimeHour(TimeCurrent())<TimeHour(LSC))
       SubDisplay("LondonSession"+IntegerToString(i,0),"|",3,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(LSO)*60+TimeMinute(LSO))/5),0))-i,50,12,TEXT_FONT,Lime);
     else
       SubDisplay("LondonSession"+IntegerToString(i,0),"|",3,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(LSO)*60+TimeMinute(LSO))/5),0))-i,50,12,TEXT_FONT,Gray);
  }
  SubDisplay("LondonTime","LondonTime: "+TimeToStr(LondonTime,TIME_SECONDS),3,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(LSO)*60+TimeMinute(LSO))/5),0))-160,52,8,TEXT_FONT,White);
  for(i=0;i<108;i++)
  {  if(TimeHour(TimeCurrent())>=TimeHour(NSO) && TimeHour(TimeCurrent())<TimeHour(NSC))
       SubDisplay("NoeyorkSession"+IntegerToString(i,0),"|",3,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(NSO)*60+TimeMinute(NSO))/5),0))-i,65,12,TEXT_FONT,Lime);
     else
       SubDisplay("NoeyorkSession"+IntegerToString(i,0),"|",3,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(NSO)*60+TimeMinute(NSO))/5),0))-i,65,12,TEXT_FONT,Gray);
  } 
  SubDisplay("NewYorkTime","NewYorkTime: "+TimeToStr(NewyorkTime,TIME_SECONDS),3,293-StrToInteger(DoubleToStr(MathFloor((TimeHour(NSO)*60+TimeMinute(NSO))/5),0))-56,67,8,TEXT_FONT,White);
}
//++++++++++++++++++++++++++++++++++++++++++++++++
void SubDisplay(string LabelName,string LabelDoc,int Corner,int TextX,int TextY,int DocSize,string DocStyle,color DocColor)
{ 
   ObjectCreate(LabelName, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(LabelName, LabelDoc, DocSize, DocStyle,DocColor);
   ObjectSet(LabelName, OBJPROP_CORNER, Corner); 
   ObjectSet(LabelName, OBJPROP_XDISTANCE, TextX); 
   ObjectSet(LabelName, OBJPROP_YDISTANCE, TextY); 
   return; 
}
//+++++++++++++++++++++++++++++++++++++++++++++++++
//   Function Calc_TDI()
//+++++++++++++++++++++++++++++++++++++++++++++++++
void Calc_TDI()
{
   tdibars = 10;        //Bars;
   ArrayResize(tdivalues,CountPairs);
   
//Calculate TDI value
  for(p=0;p<CountPairs;p++)
  {
     ArrayResize(tdivalues[p].RSIBuf,tdibars);
     ArrayResize(tdivalues[p].RPLBuf,tdibars);
     ArrayResize(tdivalues[p].TSLBuf,tdibars);
     ArrayResize(tdivalues[p].MBLBuf,tdibars);
     
     ArrayInitialize(tdivalues[p].RSIBuf,0);
     ArrayInitialize(tdivalues[p].RPLBuf,0);
     ArrayInitialize(tdivalues[p].TSLBuf,0);
     ArrayInitialize(tdivalues[p].MBLBuf,0);
     ArraySetAsSeries(tdivalues[p].RSIBuf,true);
     
     for(i=0;i<tdibars;i++)     //(i=arraysize-1;i>=0;i--)  
     {  RefreshRates();
        tdivalues[p].RSIBuf[i] = NormalizeDouble((iRSI(TradePairs[p],0,RSIPeriod,RSIPrice,i)),4);
     }
     for(i=0;i<tdibars;i++)  {
       tdivalues[p].RPLBuf[i] = NormalizeDouble((iMAOnArray(tdivalues[p].RSIBuf,tdibars,2,0,0,i)),4);
       tdivalues[p].TSLBuf[i] = NormalizeDouble((iMAOnArray(tdivalues[p].RSIBuf,tdibars,7,0,0,i)),4);
       tdivalues[p].MBLBuf[i] = NormalizeDouble((iMAOnArray(tdivalues[p].RSIBuf,tdibars,34,0,0,i)),4);   
     }
  }
}
int CheckBasketProfit()
{ 
   gOrdersInBasket=0;
   gBasketProfit=0;
  for(int n=0; n<OrdersTotal(); n++) 
  {
    if(OrderSelect(n, SELECT_BY_POS, MODE_TRADES)==false)
    {  iError=GetLastError();
       Print("OrderSelect() Function in CheckBasket error = ",iError,"--",ErrorDescription(iError));
    }
    if(StringSubstr(OrderComment(),0,StringLen(comment))==comment)
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
}
//+------------------------------------------------------------------+
//| Function..: Close Open Order                                           |
//+------------------------------------------------------------------+
void CloseSpecifyOrder(string pair, string notes)
{  int iOrders=OrdersTotal()-1;
   if(pair=="NULL")
   {  for(int n=0; n<OrdersTotal(); n++)  {
        if(OrderSelect(n,SELECT_BY_POS,MODE_TRADES)) {
          if((OrderType()<=OP_SELL) && GetMarketInfo()) {
            if(!OrderClose(OrderTicket(),OrderLots(),Price[1-OrderType()],giSlippage))
              Print(notes,", error=", iError,"--",ErrorDescription(iError));
            else  Print(notes, ", Order Close OOKK!");
          }
          else if(OrderType()>OP_SELL) {
            if(!OrderDelete(OrderTicket()))   Print(notes,", error=", iError,"--",ErrorDescription(iError));
          }
        }
      }   
   }
   if(pair!="NULL")
   {  for(int n=0; n<OrdersTotal(); n++)   {
        if(OrderSelect(n,SELECT_BY_POS,MODE_TRADES) && (OrderSymbol() == pair))   {
          if((OrderType()<=OP_SELL) && GetMarketInfo())   {
            if(!OrderClose(OrderTicket(),OrderLots(),Price[1-OrderType()],giSlippage))
              Print(notes,", error=", iError,"--",ErrorDescription(iError));
            else  Print(notes, ", Order Close OOKK!");
          }
        }
        else continue;
      }
   }
   return;
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
//| Function..: OrderError                                           |
//+------------------------------------------------------------------+
string OrderError() {
  iError=GetLastError();
  return(StringConcatenate(", Order:",OrderTicket(),", Error=",iError,"--",ErrorDescription(iError)));
}

//+-----------------------------------------------------------------------------------------------+
//| Subroutine: getting the name of the ForexFactory .xml file                                    |
//+-----------------------------------------------------------------------------------------------+ 
//deVries: one file for all charts!   
string GetXmlFileName()
{
   int adjustDays=0;
   switch(TimeDayOfWeek(TimeLocal()))
   {
      case 0:    adjustDays=0;     break;
      case 1:    adjustDays=1;     break;
      case 2:    adjustDays=2;     break;
      case 3:    adjustDays=3;     break;
      case 4:    adjustDays=4;     break;
      case 5:    adjustDays=5;     break;
      case 6:    adjustDays=6;     break;
   }
   WeekStartTime=TimeLocal() -(adjustDays *86400);
   string fileName=(StringConcatenate(TimeYear(WeekStartTime),"-",
     PadString(DoubleToStr(TimeMonth(WeekStartTime),0),"0",2),"-",
     PadString(DoubleToStr(TimeDay(WeekStartTime),0),"0",2),"-FFCal-News",".xml"));

   return(fileName); //Always a Sunday date  		
}

//+-----------------------------------------------------------------------------------------------+
//| Subroutine: to pad string                                                                     |
//+-----------------------------------------------------------------------------------------------+ 
//deVries: 
string PadString(string toBePadded,string paddingChar,int paddingLength)
{
   while(StringLen(toBePadded)<paddingLength)
   {
      toBePadded=StringConcatenate(paddingChar,toBePadded);
   }
   return (toBePadded);
}

//+--------------------------------------------------------------------------------------------+
//Function NewsCalendar(): Download .xml file from ForexFactory,
// and Parse the XML file looking for an event to report
//+--------------------------------------------------------------------------------------------+
int NewsCalendar(bool show)
{
p=0;
startshow=0;
string sign;
  InitNews(sUrl);
//qFish-----------------------------------------------------------------------------------------
//Perform remaining checks once per UpdateRateSec (Refreshing News from XML file)
   if(CurrentTF==Period())
     {
      //if we haven't changed time frame then keep doing what we are doing
      if(MathMod(Seconds(),UpdateRateSec)==0)
        {
         return (true);
        }
      //otherwise, we've switched time frame and do not need to skip every 10 s,
      //thus immediately execute all of the start() function code   
      else
        {
         CurrentTF=Period();
        }
     }
//New xml file handling coding and revised parsing coding
   xmlHandle=FileOpen(xmlFileName,FILE_BIN|FILE_READ);
   if(xmlHandle>=0)
     {
      ulong size=FileSize(xmlHandle);
      sData=FileReadString(xmlHandle,int(size));
      FileClose(xmlHandle);
     }
//Parse the XML file looking for an event to report		
   newsIdx=0;
   nextNewsIdx=-1;
   tmpMins=10080;   // (a week)
   BoEvent= 0;
   while(true)
     {
      BoEvent=StringFind(sData,"<event>",BoEvent);
      if(BoEvent==-1) break;
      BoEvent+=7;
      next=StringFind(sData,"</event>",BoEvent);
      if(next == -1) break;
      myEvent = StringSubstr(sData, BoEvent, next - BoEvent);
      BoEvent = next;
      begin= 0;
      skip = false;
      for(i=0; i < 7; i++)
        {
         mainData[newsIdx][i]="";
         next=StringFind(myEvent,sTags[i],begin);
         // Within this event, if tag not found, then it must be missing; skip it
         if(next==-1) continue;
         else
           {
            // We must have found the sTag okay...
            begin= next+StringLen(sTags[i]);            // Advance past the start tag
            end = StringFind(myEvent,eTags[i],begin);   // Find start of end tag
                                                        //Get data between start and end tag
            if(end>begin && end!=-1)
              {mainData[newsIdx][i]=StringSubstr(myEvent,begin,end-begin);
              if(i==TIME)
              {ReNewsTime[newsIdx]=MakeDateTime(mainData[newsIdx][DATE],mainData[newsIdx][TIME]);
               mainData[newsIdx][DATE]=TimeToString(ReNewsTime[newsIdx],TIME_DATE);
               mainData[newsIdx][TIME]=TimeToString(ReNewsTime[newsIdx],TIME_MINUTES);
              }              
              }
           }
        }//End "for" loop

      //If not skipping this event, then log time to event it into ExtMapBuffer0
      if(!skip)
        {
//         ExtMapBuffer0[newsIdx]=minsTillNews;
         newsIdx++;
        }//End "skip" routine
   }//End "while" routine
   if(show==true)
   {  for(k=0;k<newsIdx;k++)
     {  if(ReNewsTime[k]<TimeCurrent() && ReNewsTime[k+1]>=TimeCurrent())
          startshow=k;
     }
     SubDisplay("title1","CountDown "+"Country "+"Impact"+"            News   Summary",2,10,5,10,TEXT_FONT,White);
     SubDisplay("title2","Predict"+"  Prev.",2,495,5,10,TEXT_FONT,White);
     SubDisplay("--","_________ _______ ______ ___________________________________",2,10,18,10,TEXT_FONT,clrAqua);
     SubDisplay("--1","_________ _______ ______ ___________________________________",2,10,20,10,TEXT_FONT,clrAqua);
     SubDisplay("---","________ _______",2,495,18,10,TEXT_FONT,clrAqua);
     SubDisplay("---1","________ _______",2,495,20,10,TEXT_FONT,clrAqua);
     for(i=0;i<ShowNewsLines;i++)
     {  
        if(mainData[startshow+i][IMPACT]=="High")
          NewsColor=clrRed;
        if(mainData[startshow+i][IMPACT]=="Low")
          NewsColor=clrLime;
        if(mainData[startshow+i][IMPACT]=="Medium")
          NewsColor=clrYellow;
        if(ReNewsTime[startshow+i]<TimeCurrent())
          {NewsColor=clrGray;Countdown=TimeCurrent()-ReNewsTime[startshow+i];sign="-";}
        else
          {Countdown=ReNewsTime[startshow+i]-TimeCurrent();sign=" ";}
          
        {  SubDisplay("news1"+IntegerToString(i,2),sign+TimeToStr(Countdown,TIME_SECONDS)+"  "
                               +mainData[startshow+i][COUNTRY]+"  "
                               +PadString(mainData[startshow+i][IMPACT]," ",8)+" "
                               +PadString(mainData[startshow+i][TITLE],"-",35),2,10,20+15*i,10,TEXT_FONT,NewsColor);
           SubDisplay("news2"+IntegerToString(i,2),PadString(mainData[startshow+i][FORECAST]," ",10)+"   "
                               +mainData[startshow+i][PREVIOUS],2,465,20+15*i,10,TEXT_FONT,NewsColor);
        }
     }
   }     
  return(0);
}
//+-----------------------------------------------------------------------------------------------+
//| Subroutines: recoded creation and maintenance of single xml file                              |
//+-----------------------------------------------------------------------------------------------+   
//deVries: void InitNews(string& mainData[][], string newsUrl)
void InitNews(string newsUrl)
{
   if(DoFileDownLoad()) //Added to check if the CSV file already exists
   {
      DownLoadWebPageToFile(newsUrl); //downloading the xml file
   }
}
//+-----------------------------------------------------------------------------------------------+
//| Indicator Subroutine For Date/Time    changed by deVries                                      |
//+-----------------------------------------------------------------------------------------------+ 
datetime MakeDateTime(string strDate,string strTime) //not string now datetime
{  datetime newsevent;
   int n1stDash = StringFind(strDate, "-");
   int n2ndDash = StringFind(strDate, "-", n1stDash+1);

   string strMonth=StringSubstr(strDate,0,2);
   string strDay=StringSubstr(strDate,3,2);
   string strYear=StringSubstr(strDate,6,4);

   int nTimeColonPos=StringFind(strTime,":");
   string strHour=StringSubstr(strTime,0,nTimeColonPos);
   string strMinute= StringSubstr(strTime,nTimeColonPos+1,2);
   string strAM_PM = StringSubstr(strTime,StringLen(strTime)-2);

   int nHour24=StrToInteger(strHour);
   if((strAM_PM == "pm" || strAM_PM == "PM") && nHour24 != 12) {nHour24 += 12;}
   if((strAM_PM == "am" || strAM_PM == "AM") && nHour24 == 12) {nHour24 = 0;}

   newsevent=StringToTime(strYear+"."+strMonth+"."+strDay)
                         +nHour24*3600+(StringToInteger(strMinute)*60)+BrokerGMTShift*3600;
   return(newsevent);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//deVries: If we have recent file don't download again
bool DoFileDownLoad()
{
   xmlHandle=0;
   ulong size;
   datetime time=TimeCurrent();

   if(GlobalVariableCheck("Update.FF_Cal") == false)
      return(true);
   if((time - GlobalVariableGet("Update.FF_Cal")) > WebUpdateFreq*60)
      return(true);

   xmlFileName=GetXmlFileName();
   xmlHandle=FileOpen(xmlFileName,FILE_BIN|FILE_READ);  //check if file exist 
   if(xmlHandle>=0)//when the file exists we read data
   {
      size=FileSize(xmlHandle);
      sData=FileReadString(xmlHandle,int(size));
      FileClose(xmlHandle);//close it again check is done
       return(false);//file exists no need to download again
   }
//File does not exist if FileOpen return -1 or if GetLastError = ERR_CANNOT_OPEN_FILE (4103)
   return(true); //commando true to download xml file     
}
//+-----------------------------------------------------------------------------------------------+
//| Subroutine: downloading the ForexFactory .xml file                                            |
//+-----------------------------------------------------------------------------------------------+    
//deVries: new coding replacing old "GrabWeb" coding
void DownLoadWebPageToFile(string url)
{
int HttpOpen = InternetOpenW(" ",0," "," ",0);
int HttpConnect = InternetConnectW(HttpOpen, "", 80, "", "", 3, 0, 1);
int HttpRequest = InternetOpenUrlW(HttpOpen, url, NULL, 0, 0, 0);

int    read[1];
uchar  Buffer[];
string NEWS="";
  ArrayResize(Buffer,READURL_BUFFER_SIZE+1);
  xmlFileName=GetXmlFileName();
  xmlHandle=FileOpen(xmlFileName,FILE_BIN|FILE_READ|FILE_WRITE);
//File exists if FileOpen return >=0. 
  if(xmlHandle>=0) {FileClose(xmlHandle); FileDelete(xmlFileName);}
//Open new XML.  Write the ForexFactory page contents to a .htm file.  Close new XML.
  xmlHandle=FileOpen(xmlFileName,FILE_BIN|FILE_WRITE);

  while(true)
  {
     InternetReadFile(HttpRequest,Buffer,READURL_BUFFER_SIZE,read);
     string strThisRead = CharArrayToString(Buffer,0,read[0],CP_UTF8);
     if(read[0]> 0)
       NEWS = NEWS + strThisRead;
     else
     {
        FileWriteString(xmlHandle,NEWS);
        FileClose(xmlHandle);
//Find the XML end tag to ensure a complete page was downloaded.
        end=StringFind(NEWS,"</weeklyevents>",0);
//If the end of file tag is not found, a return -1 (or, "end <=0" in this case), 
//then return (false).
        if(end==-1) {Alert(Symbol()," ",Period(),", FFCal Error: File download incomplete!");}
//Else, set global to time of last update
        else {GlobalVariableSet("Update.FF_Cal",TimeCurrent());}
          break;
     }
  }
  if(HttpRequest>0) InternetCloseHandle(HttpRequest);
  if(HttpConnect>0) InternetCloseHandle(HttpConnect);
  if(HttpOpen>0) InternetCloseHandle(HttpOpen);
}

//+---News trading Risk calculate-----------------------------+
//|   Function RiskCalculate()                                |
//+-----------------------------------------------------------+
void RiskCalculateForRatio(string pairs, double riskpercent, double riskratio)
{
  int n=0;
  newsBUYLots=0; newsSELLLots=0; newsBUYTP=0; newsBUYSL=0; newsSELLTP=0; newsSELLSL=0; UpFractals=0; DnFractals=0;

double point        =MarketInfo(pairs,MODE_POINT);
double spread       =MarketInfo(pairs,MODE_SPREAD);
double tickvalue    =MarketInfo(pairs,MODE_TICKVALUE);
int    digits       =MarketInfo(pairs,MODE_DIGITS);
int    lotsdigits   =MathLog10(MarketInfo(pairs,MODE_LOTSTEP)*(-1));
double atr5         =iATR(pairs,PERIOD_D1,5,0);
double gaps         =(iHigh(pairs,PERIOD_H4,0)-iLow(pairs,PERIOD_H4,0))/point;
  if(gaps<5)    gaps=(iHigh(pairs,PERIOD_D1,0)-iLow(pairs,PERIOD_D1,0))/point;
double riskmoney    =riskpercent*0.01*AccountEquity();
  if(riskmoney>2*gaps*tickvalue*MarketInfo(pairs,MODE_LOTSTEP))
     riskmoney=2*gaps*tickvalue*MarketInfo(pairs,MODE_LOTSTEP);
  
  buystopprice=NormalizeDouble(MarketInfo(pairs,MODE_ASK)+PendOrderGapPips*point,digits);
  sellstopprice=NormalizeDouble(MarketInfo(pairs,MODE_BID)-PendOrderGapPips*point,digits);
  if(riskratio>0)
  {
  newsBUYSL =NormalizeDouble(iLow(pairs,PERIOD_D1,0),digits);
  newsSELLSL=NormalizeDouble(iHigh(pairs,PERIOD_D1,0),digits);
  if(buystopprice-newsBUYSL<30*point)
    newsBUYSL=NormalizeDouble(buystopprice-30*point,digits);
  if(newsSELLSL-sellstopprice<30*point)
    newsSELLSL=NormalizeDouble(sellstopprice+30*point,digits);
  newsBUYTP =NormalizeDouble(buystopprice+(buystopprice-newsBUYSL)*riskratio,digits);
  newsSELLTP=NormalizeDouble(sellstopprice-(newsSELLSL-sellstopprice)*riskratio,digits);
  }
  else
  {  newsBUYSL =iLow(pairs,PERIOD_D1,1);   //NormalizeDouble(buystopprice-atr5,digits);
     newsSELLSL=iHigh(pairs,PERIOD_D1,1);  //NormalizeDouble(sellstopprice+atr5,digits);
     if(FilterUseCC==false)
     {  newsBUYTP =iHigh(TradePairs[i],PERIOD_D1,1);
        newsSELLTP=iLow(TradePairs[i],PERIOD_D1,1);
     }
     else
     {  newsBUYTP =NormalizeDouble(MarketInfo(TradePairs[i],MODE_ASK)+NewsTPinPips*point,digits);  //
        newsSELLTP=NormalizeDouble(MarketInfo(TradePairs[i],MODE_BID)-NewsTPinPips*point,digits);  //
     }
  }
   if(UseMM==false)  {
     newsBUYLots=MarketInfo(pairs,MODE_MINLOT);
     newsSELLLots=newsBUYLots;
   }
   else  {
     newsBUYLots=NormalizeDouble(riskmoney/(((buystopprice-newsBUYSL)/point)*tickvalue),lotsdigits);
     newsSELLLots=NormalizeDouble(riskmoney/(((newsSELLSL-sellstopprice)/point)*tickvalue),lotsdigits);
     
     if(newsBUYLots<MarketInfo(pairs,MODE_MINLOT))  newsBUYLots=MarketInfo(pairs,MODE_MINLOT);
     if(newsSELLLots<MarketInfo(pairs,MODE_MINLOT))  newsSELLLots=MarketInfo(pairs,MODE_MINLOT);
   }
}

//+-----------------------------------------------------------------------------------+
//|---Function: Red News Trade                                                        |
//+-----------------------------------------------------------------------------------+
void RedNewsTrade()
{  int ordertotal=OrdersTotal();
   for(i=0;i<CountPairs;i++)
   {  for(k=0;k<ordertotal;k++)
      {  if(OrderSelect(k,SELECT_BY_POS,MODE_TRADES)==false)
         {  Print("Select order(when check exist orders) error= ", iError,"--",ErrorDescription(iError));
            Print("K=Ordertotal=",k);
         }
         else
         {  if(StringFind(OrderComment(),comment,0)!=-1 && OrderSymbol()!=TradePairs[i])
              continue;
            else
            {  PendOrTradeFlag[i]=1;
               if(OrderType()<=1)
               {  for(p=0;p<ordertotal;p++)
                  {  if(OrderSelect(p,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==TradePairs[i] && OrderType()>1)
                     {  if(!OrderDelete(OrderTicket()))
                          Print("Delete opposite pending order error= ", iError,"--",ErrorDescription(iError));
                     }
                  }
               }
            }
         }//end if OrderSelect()
      }//end for(k>ordertotal)
   }//end for(i>=CountPairs)
bool AllowTradeTime=false; 
   for(i=0;i<CountPairs;i++)
   { /* for(k=0;k<OrdersHistoryTotal();k++)
      {  if(OrderSelect(k,SELECT_BY_POS,MODE_HISTORY) && OrderSymbol()==TradePairs[i])
           {  if(TimeCurrent()-OrderCloseTime()<4*3600)
                AllowTradeTime=false;
              else
                AllowTradeTime=true;
           }
      } */
      
      for(p=startshow; p<startshow+3; p++)
      {  if(   mainData[p][IMPACT]=="High"
            && ReNewsTime[p]-TimeCurrent()<SecondBeforeNews
            && StringFind(TradePairs[i],mainData[p][COUNTRY],0)!=-1  
            && PendOrTradeFlag[i]==0
           )//&& AllowTradeTime==true
         {  
            RiskCalculateForRatio(TradePairs[i],RiskMoneyPercent,RiskRatio);
            if(FilterUseCC==false)  {
            while(!PendOrTradeFlag[i])
            {  datetime expire=TimeCurrent()+PERIOD_M15*60;
               if(NewsPendTicket[i][0]<=0 && NewsPendTicket[i][1]<=0)
               {  NewsPendTicket[i][0]=OrderSend(TradePairs[i],OP_BUYSTOP,newsBUYLots,buystopprice,5,newsBUYSL,newsBUYTP,comment+IntegerToString(1,0),0,expire,Red);
                  NewsPendTicket[i][1]=OrderSend(TradePairs[i],OP_SELLSTOP,newsSELLLots,sellstopprice,5,newsSELLSL,newsSELLTP,comment+IntegerToString(1,0),0,expire,Red); 
               }
               if(NewsPendTicket[i][0]>0 && NewsPendTicket[i][1]<=0)
                 NewsPendTicket[i][1]=OrderSend(TradePairs[i],OP_SELLSTOP,newsSELLLots,sellstopprice,5,newsSELLSL,newsSELLTP,comment+IntegerToString(1,0),0,expire,Red); 
               if(NewsPendTicket[i][0]<=0 && NewsPendTicket[i][1]>0)
                 NewsPendTicket[i][0]=OrderSend(TradePairs[i],OP_BUYSTOP,newsBUYLots,buystopprice,5,newsBUYSL,newsBUYTP,comment+IntegerToString(1,0),0,expire,Red);
//    Print("imp=",mainData[p][IMPACT],", country=",mainData[p][COUNTRY],", Paie= ",TradePairs[i]);
               if(NewsPendTicket[i][0]==-1 || NewsPendTicket[i][0]==-1)
               {  iError=GetLastError();
                  Print("Open ",TradePairs[i]," pending order error:", iError,"--",ErrorDescription(iError));
                  PendOrTradeFlag[i]=0;
               }
               else
               {  PendOrTradeFlag[i]=1;  Print("Open pending is OOKK!"); 
               }
            }//end while(!PendOrTradeFlag[i])
            }
            else
            {  if(mainData[p][COUNTRY]=="AUD" && PendOrTradeFlag[i]==0 &&
                 ((arrAUD[0][0]>arrAUD[0][4] && arrAUD[1][0]>=arrAUD[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==0) ||
                 (arrAUD[0][0]<arrAUD[0][4] && arrAUD[1][0]<=arrAUD[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==3)))
                 if(!OrderSend(TradePairs[i],OP_BUY,newsBUYLots,MarketInfo(TradePairs[i],MODE_ASK),5,0,newsBUYTP,comment+IntegerToString(1,0),0,0,Red))  
                   Print("OrderSend() error=",GetLastError());
                 else  {PendOrTradeFlag[i]=1;  Print("Open BUY order ",TradePairs[i]," is OOKK!"); }
               if(mainData[p][COUNTRY]=="AUD" && PendOrTradeFlag[i]==0 &&
                 ((arrAUD[0][0]>arrAUD[0][4] && arrAUD[1][0]>=arrAUD[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==3) ||
                 (arrAUD[0][0]<arrAUD[0][4] && arrAUD[1][0]<=arrAUD[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==0)))
                 if(!OrderSend(TradePairs[i],OP_SELL,newsSELLLots,MarketInfo(TradePairs[i],MODE_BID),5,0,newsSELLTP,comment+IntegerToString(1,0),0,0,Red))
                   Print("OrderSend() error=",GetLastError());
                 else  {PendOrTradeFlag[i]=1;  Print("Open SELL order ",TradePairs[i]," is OOKK!");}

               if(mainData[p][COUNTRY]=="USD" && PendOrTradeFlag[i]==0 &&
                 ((arrUSD[0][0]>arrUSD[0][4] && arrUSD[1][0]>=arrUSD[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==0) ||
                 (arrUSD[0][0]<arrUSD[0][4] && arrUSD[1][0]<=arrUSD[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==3)))
                 if(!OrderSend(TradePairs[i],OP_BUY,newsBUYLots,MarketInfo(TradePairs[i],MODE_ASK),5,0,newsBUYTP,comment+IntegerToString(1,0),0,0,Red))
                   Print("OrderSend() error=",GetLastError());
                 else  {PendOrTradeFlag[i]=1;  Print("Open BUY order ",TradePairs[i]," is OOKK!"); }
               if(mainData[p][COUNTRY]=="USD" && PendOrTradeFlag[i]==0 &&
                 ((arrUSD[0][0]>arrUSD[0][4] && arrUSD[1][0]>=arrUSD[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==3) ||
                 (arrUSD[0][0]<arrUSD[0][4] && arrUSD[1][0]<=arrUSD[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==0)))
                 if(!OrderSend(TradePairs[i],OP_SELL,newsSELLLots,MarketInfo(TradePairs[i],MODE_BID),5,0,newsSELLTP,comment+IntegerToString(1,0),0,0,Red))
                   Print("OrderSend() error=",GetLastError());
                 else  {PendOrTradeFlag[i]=1;  Print("Open SELL order ",TradePairs[i]," is OOKK!");}
               
               if(mainData[p][COUNTRY]=="EUR" && PendOrTradeFlag[i]==0 &&
                 ((arrEUR[0][0]>arrEUR[0][4] && arrEUR[1][0]>=arrEUR[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==0) ||
                 (arrEUR[0][0]<arrEUR[0][4] && arrEUR[1][0]<=arrEUR[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==3)))
                 if(!OrderSend(TradePairs[i],OP_BUY,newsBUYLots,MarketInfo(TradePairs[i],MODE_ASK),5,0,newsBUYTP,comment+IntegerToString(1,0),0,0,Red))
                   Print("OrderSend() error=",GetLastError());
                 else  {PendOrTradeFlag[i]=1;  Print("Open BUY order ",TradePairs[i]," is OOKK!"); }
               if(mainData[p][COUNTRY]=="EUR" && PendOrTradeFlag[i]==0 &&
                 ((arrEUR[0][0]>arrEUR[0][4] && arrEUR[1][0]>=arrEUR[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==3) ||
                 (arrEUR[0][0]<arrEUR[0][4] && arrEUR[1][0]<=arrEUR[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==0)))
                 if(!OrderSend(TradePairs[i],OP_SELL,newsSELLLots,MarketInfo(TradePairs[i],MODE_BID),5,0,newsSELLTP,comment+IntegerToString(1,0),0,0,Red))
                   Print("OrderSend() error=",GetLastError());
                 else  {PendOrTradeFlag[i]=1;  Print("Open SELL order ",TradePairs[i]," is OOKK!");}
                 
               if(mainData[p][COUNTRY]=="GBP" && PendOrTradeFlag[i]==0 &&
                 ((arrGBP[0][0]>arrGBP[0][4] && arrGBP[1][0]>=arrGBP[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==0) ||
                 (arrGBP[0][0]<arrGBP[0][4] && arrGBP[1][0]<=arrGBP[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==3)))
                 if(!OrderSend(TradePairs[i],OP_BUY,newsBUYLots,MarketInfo(TradePairs[i],MODE_ASK),5,0,newsBUYTP,comment+IntegerToString(1,0),0,0,Red))
                   Print("OrderSend() error=",GetLastError());
                 else  {PendOrTradeFlag[i]=1;  Print("Open BUY order ",TradePairs[i]," is OOKK!"); }
               if(mainData[p][COUNTRY]=="GBP" && PendOrTradeFlag[i]==0 &&
                 ((arrGBP[0][0]>arrGBP[0][4] && arrGBP[1][0]>=arrGBP[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==3) ||
                 (arrGBP[0][0]<arrGBP[0][4] && arrGBP[1][0]<=arrGBP[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==0)))
                 if(!OrderSend(TradePairs[i],OP_SELL,newsSELLLots,MarketInfo(TradePairs[i],MODE_BID),5,0,newsSELLTP,comment+IntegerToString(1,0),0,0,Red))
                   Print("OrderSend() error=",GetLastError());
                 else  {PendOrTradeFlag[i]=1;  Print("Open SELL order ",TradePairs[i]," is OOKK!");}  
                 
               if(mainData[p][COUNTRY]=="JPY" && PendOrTradeFlag[i]==0 &&
                 ((arrJPY[0][0]>arrJPY[0][4] && arrJPY[1][0]>=arrJPY[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==0) ||
                 (arrJPY[0][0]<arrJPY[0][4] && arrJPY[1][0]<=arrJPY[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==3)))
                 if(!OrderSend(TradePairs[i],OP_BUY,newsBUYLots,MarketInfo(TradePairs[i],MODE_ASK),5,0,newsBUYTP,comment+IntegerToString(1,0),0,0,Red))
                   Print("OrderSend() error=",GetLastError());
                 else  {PendOrTradeFlag[i]=1;  Print("Open BUY order ",TradePairs[i]," is OOKK!"); }
               if(mainData[p][COUNTRY]=="JPY" && PendOrTradeFlag[i]==0 &&
                 ((arrJPY[0][0]>arrJPY[0][4] && arrJPY[1][0]>=arrJPY[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==3) ||
                 (arrJPY[0][0]<arrJPY[0][4] && arrJPY[1][0]<=arrJPY[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==0)))
                 if(!OrderSend(TradePairs[i],OP_SELL,newsSELLLots,MarketInfo(TradePairs[i],MODE_BID),5,0,newsSELLTP,comment+IntegerToString(1,0),0,0,Red))
                   Print("OrderSend() error=",GetLastError());
                 else  {PendOrTradeFlag[i]=1;  Print("Open SELL order ",TradePairs[i]," is OOKK!");}  
                 
               if(mainData[p][COUNTRY]=="CAD" && PendOrTradeFlag[i]==0 &&
                 ((arrCAD[0][0]>arrCAD[0][4] && arrCAD[1][0]>=arrCAD[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==0) ||
                 (arrCAD[0][0]<arrCAD[0][4] && arrCAD[1][0]<=arrCAD[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==3)))
                 if(!OrderSend(TradePairs[i],OP_BUY,newsBUYLots,MarketInfo(TradePairs[i],MODE_ASK),5,0,newsBUYTP,comment+IntegerToString(1,0),0,0,Red))
                   Print("OrderSend() error=",GetLastError());
                 else  {PendOrTradeFlag[i]=1;  Print("Open BUY order ",TradePairs[i]," is OOKK!"); }
               if(mainData[p][COUNTRY]=="CAD" && PendOrTradeFlag[i]==0 &&
                 ((arrCAD[0][0]>arrCAD[0][4] && arrCAD[1][0]>=arrCAD[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==3) ||
                 (arrCAD[0][0]<arrCAD[0][4] && arrCAD[1][0]<=arrCAD[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==0)))
                 if(!OrderSend(TradePairs[i],OP_SELL,newsSELLLots,MarketInfo(TradePairs[i],MODE_BID),5,0,newsSELLTP,comment+IntegerToString(1,0),0,0,Red))
                   Print("OrderSend() error=",GetLastError());
                 else  {PendOrTradeFlag[i]=1;  Print("Open SELL order ",TradePairs[i]," is OOKK!");}                     
                    
               if(mainData[p][COUNTRY]=="NZD" && PendOrTradeFlag[i]==0 &&
                 ((arrNZD[0][0]>arrNZD[0][4] && arrNZD[1][0]>=arrNZD[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==0) ||
                 (arrNZD[0][0]<arrNZD[0][4] && arrNZD[1][0]<=arrNZD[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==3)))
                 if(!OrderSend(TradePairs[i],OP_BUY,newsBUYLots,MarketInfo(TradePairs[i],MODE_ASK),5,0,newsBUYTP,comment+IntegerToString(1,0),0,0,Red))
                   Print("OrderSend() error=",GetLastError());
                 else  {PendOrTradeFlag[i]=1;  Print("Open BUY order ",TradePairs[i]," is OOKK!"); }
               if(mainData[p][COUNTRY]=="NZD" && PendOrTradeFlag[i]==0 &&
                 ((arrNZD[0][0]>arrNZD[0][4] && arrNZD[1][0]>=arrNZD[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==3) ||
                 (arrNZD[0][0]<arrNZD[0][4] && arrNZD[1][0]<=arrNZD[1][1] && StringFind(TradePairs[i],mainData[p][COUNTRY],0)==0)))
                 if(!OrderSend(TradePairs[i],OP_SELL,newsSELLLots,MarketInfo(TradePairs[i],MODE_BID),5,0,newsSELLTP,comment+IntegerToString(1,0),0,0,Red))
                   Print("OrderSend() error=",GetLastError());
                 else  {PendOrTradeFlag[i]=1;  Print("Open SELL order ",TradePairs[i]," is OOKK!");}                        
            }
         }
      }//end for(p=startshow)
 //  Print(TradePairs[i]," tickvalue=",MathLog10(0.01)*-1);
   }//end for(i>=CountPairs)
}

//+-----------------------------------------------------------------------------------+
//|---Function:CC      //Currency strength                                            |
//+-----------------------------------------------------------------------------------+
void Cc(int timeframe)
{
int MA_Method = 3;
int WeightedPrice = 6;
bool USD = 1,EUR = 1,GBP = 1,CHF = 1,JPY = 1,AUD = 1,CAD = 1,NZD = 1;
// for monthly
int mn_per = 12, mn_fast = 3;
// for weekly
int w_per = 9, w_fast = 3;
// for daily
int d_per = 5, d_fast = 3;
// for H4
int h4_per = 18, h4_fast = 6;
// for H1
int h1_per = 24, h1_fast = 8;
// for M30
int m30_per = 16, m30_fast = 2;
// for M15
int m15_per = 16, m15_fast = 4;
// for M5
int m5_per = 12, m5_fast = 3;
// for M1
int m1_per = 30, m1_fast = 10;
//----
int Slow=0, Fast=0;
int tf;
double EURUSD_Fast=0, EURUSD_Slow=0, GBPUSD_Fast=0, GBPUSD_Slow=0, AUDUSD_Fast=0, AUDUSD_Slow=0, NZDUSD_Fast=0, NZDUSD_Slow=0;
double USDCHF_Fast=0, USDCHF_Slow=0, USDCAD_Fast=0, USDCAD_Slow=0, USDJPY_Fast=0, USDJPY_Slow=0;
  
   switch(timeframe)
     {
       case 1:     Slow = m1_per; Fast = m1_fast;  tf=0;  break;
       case 5:     Slow = m5_per; Fast = m5_fast;  tf=1;  break;
       case 15:    Slow = m15_per;Fast = m15_fast;        break;
       case 30:    Slow = m30_per;Fast = m30_fast;        break;
       case 60:    Slow = h1_per; Fast = h1_fast;  tf=2;  break;
       case 240:   Slow = h4_per; Fast = h4_fast;  tf=3;  break;
       case 1440:  Slow = d_per;  Fast = d_fast;   tf=4;  break;
       case 10080: Slow = w_per;  Fast = w_fast;          break;
       case 43200: Slow = mn_per; Fast = mn_fast;         break;
     }
//---- main cycle
   for( i = 0; i < 10; i++)
     {
       // Preliminary calculation
       if(EUR)
         {
           EURUSD_Fast = ma("EURUSD", timeframe, Fast, MA_Method, WeightedPrice, i);
           EURUSD_Slow = ma("EURUSD", timeframe, Slow, MA_Method, WeightedPrice, i);
           if (!EURUSD_Fast || !EURUSD_Slow)
               break;
         }
       if(GBP)
         {
           GBPUSD_Fast = ma("GBPUSD", timeframe, Fast, MA_Method, WeightedPrice, i);
           GBPUSD_Slow = ma("GBPUSD", timeframe, Slow, MA_Method, WeightedPrice, i);
           if(!GBPUSD_Fast || !GBPUSD_Slow)
               break;
         }
       if(AUD)
         {
           AUDUSD_Fast = ma("AUDUSD", timeframe, Fast, MA_Method, WeightedPrice, i);
           AUDUSD_Slow = ma("AUDUSD", timeframe, Slow, MA_Method, WeightedPrice, i);
           if(!AUDUSD_Fast || !AUDUSD_Slow)
               break;
         }
       if(NZD)
         {
           NZDUSD_Fast = ma("NZDUSD", timeframe, Fast, MA_Method, WeightedPrice, i);
           NZDUSD_Slow = ma("NZDUSD", timeframe, Slow, MA_Method, WeightedPrice, i);
           if(!NZDUSD_Fast || !NZDUSD_Slow)
               break;
         }
       if(CAD)
         {
           USDCAD_Fast = ma("USDCAD", timeframe, Fast, MA_Method, WeightedPrice, i);
           USDCAD_Slow = ma("USDCAD", timeframe, Slow, MA_Method, WeightedPrice, i);
           if(!USDCAD_Fast || !USDCAD_Slow)
               break;
         }
       if(CHF)
         {
           USDCHF_Fast = ma("USDCHF", timeframe, Fast, MA_Method, WeightedPrice, i);
           USDCHF_Slow = ma("USDCHF", timeframe, Slow, MA_Method, WeightedPrice, i);
           if(!USDCHF_Fast || !USDCHF_Slow)
               break;
         }
       if(JPY)
         {
           USDJPY_Fast = ma("USDJPY", timeframe, Fast, MA_Method, WeightedPrice, i) / 100;
           USDJPY_Slow = ma("USDJPY", timeframe, Slow, MA_Method, WeightedPrice, i) / 100;
           if(!USDJPY_Fast || !USDJPY_Slow)
               break;
         }
       // calculation of currencies
       if(USD)
         {
           arrUSD[tf][i] = 0;
           if(EUR)   arrUSD[tf][i] += EURUSD_Slow - EURUSD_Fast;
           if(GBP)   arrUSD[tf][i] += GBPUSD_Slow - GBPUSD_Fast;
           if(AUD)   arrUSD[tf][i] += AUDUSD_Slow - AUDUSD_Fast;
           if(NZD)   arrUSD[tf][i] += NZDUSD_Slow - NZDUSD_Fast;
           if(CHF)   arrUSD[tf][i] += USDCHF_Fast - USDCHF_Slow;
           if(CAD)   arrUSD[tf][i] += USDCAD_Fast - USDCAD_Slow;
           if(JPY)   arrUSD[tf][i] += USDJPY_Fast - USDJPY_Slow;
         }// end if USD
       if(EUR)
         {
           arrEUR[tf][i] = 0;
           if(USD)   arrEUR[tf][i] += EURUSD_Fast - EURUSD_Slow;
           if(GBP)   arrEUR[tf][i] += EURUSD_Fast / GBPUSD_Fast - EURUSD_Slow / GBPUSD_Slow;
           if(AUD)   arrEUR[tf][i] += EURUSD_Fast / AUDUSD_Fast - EURUSD_Slow / AUDUSD_Slow;
           if(NZD)   arrEUR[tf][i] += EURUSD_Fast / NZDUSD_Fast - EURUSD_Slow / NZDUSD_Slow;
           if(CHF)   arrEUR[tf][i] += EURUSD_Fast*USDCHF_Fast - EURUSD_Slow*USDCHF_Slow;
           if(CAD)   arrEUR[tf][i] += EURUSD_Fast*USDCAD_Fast - EURUSD_Slow*USDCAD_Slow;
           if(JPY)   arrEUR[tf][i] += EURUSD_Fast*USDJPY_Fast - EURUSD_Slow*USDJPY_Slow;
         }// end if EUR
       if(GBP)
         {
           arrGBP[tf][i] = 0;
           if(USD)   arrGBP[tf][i] += GBPUSD_Fast - GBPUSD_Slow;
           if(EUR)   arrGBP[tf][i] += EURUSD_Slow / GBPUSD_Slow - EURUSD_Fast / GBPUSD_Fast;
           if(AUD)   arrGBP[tf][i] += GBPUSD_Fast / AUDUSD_Fast - GBPUSD_Slow / AUDUSD_Slow;
           if(NZD)   arrGBP[tf][i] += GBPUSD_Fast / NZDUSD_Fast - GBPUSD_Slow / NZDUSD_Slow;
           if(CHF)   arrGBP[tf][i] += GBPUSD_Fast*USDCHF_Fast - GBPUSD_Slow*USDCHF_Slow;
           if(CAD)   arrGBP[tf][i] += GBPUSD_Fast*USDCAD_Fast - GBPUSD_Slow*USDCAD_Slow;
           if(JPY)   arrGBP[tf][i] += GBPUSD_Fast*USDJPY_Fast - GBPUSD_Slow*USDJPY_Slow;
         }// end if GBP
       if(AUD)
         {
           arrAUD[tf][i] = 0;
           if(USD)   arrAUD[tf][i] += AUDUSD_Fast - AUDUSD_Slow;
           if(EUR)   arrAUD[tf][i] += EURUSD_Slow / AUDUSD_Slow - EURUSD_Fast / AUDUSD_Fast;
           if(GBP)   arrAUD[tf][i] += GBPUSD_Slow / AUDUSD_Slow - GBPUSD_Fast / AUDUSD_Fast;
           if(NZD)   arrAUD[tf][i] += AUDUSD_Fast / NZDUSD_Fast - AUDUSD_Slow / NZDUSD_Slow;
           if(CHF)   arrAUD[tf][i] += AUDUSD_Fast*USDCHF_Fast - AUDUSD_Slow*USDCHF_Slow;
           if(CAD)   arrAUD[tf][i] += AUDUSD_Fast*USDCAD_Fast - AUDUSD_Slow*USDCAD_Slow;
           if(JPY)   arrAUD[tf][i] += AUDUSD_Fast*USDJPY_Fast - AUDUSD_Slow*USDJPY_Slow;
         }// end if AUD
       if(NZD)
         {
           arrNZD[tf][i] = 0;
           if(USD)   arrNZD[tf][i] += NZDUSD_Fast - NZDUSD_Slow;
           if(EUR)   arrNZD[tf][i] += EURUSD_Slow / NZDUSD_Slow - EURUSD_Fast / NZDUSD_Fast;
           if(GBP)   arrNZD[tf][i] += GBPUSD_Slow / NZDUSD_Slow - GBPUSD_Fast / NZDUSD_Fast;
           if(AUD)   arrNZD[tf][i] += AUDUSD_Slow / NZDUSD_Slow - AUDUSD_Fast / NZDUSD_Fast;
           if(CHF)   arrNZD[tf][i] += NZDUSD_Fast*USDCHF_Fast - NZDUSD_Slow*USDCHF_Slow;
           if(CAD)   arrNZD[tf][i] += NZDUSD_Fast*USDCAD_Fast - NZDUSD_Slow*USDCAD_Slow;
           if(JPY)   arrNZD[tf][i] += NZDUSD_Fast*USDJPY_Fast - NZDUSD_Slow*USDJPY_Slow;
         }// end if NZD
       if(CAD)
         {
           arrCAD[tf][i] = 0;
           if(USD)   arrCAD[tf][i] += USDCAD_Slow - USDCAD_Fast;
           if(EUR)   arrCAD[tf][i] += EURUSD_Slow*USDCAD_Slow - EURUSD_Fast*USDCAD_Fast;
           if(GBP)   arrCAD[tf][i] += GBPUSD_Slow*USDCAD_Slow - GBPUSD_Fast*USDCAD_Fast;
           if(AUD)   arrCAD[tf][i] += AUDUSD_Slow*USDCAD_Slow - AUDUSD_Fast*USDCAD_Fast;
           if(NZD)   arrCAD[tf][i] += NZDUSD_Slow*USDCAD_Slow - NZDUSD_Fast*USDCAD_Fast;
           if(CHF)   arrCAD[tf][i] += USDCHF_Fast / USDCAD_Fast - USDCHF_Slow / USDCAD_Slow;
           if(JPY)   arrCAD[tf][i] += USDJPY_Fast / USDCAD_Fast - USDJPY_Slow / USDCAD_Slow;
         }// end if CAD
       if(CHF)
         {
           arrCHF[tf][i] = 0;
           if(USD)   arrCHF[tf][i] += USDCHF_Slow - USDCHF_Fast;
           if(EUR)   arrCHF[tf][i] += EURUSD_Slow*USDCHF_Slow - EURUSD_Fast*USDCHF_Fast;
           if(GBP)   arrCHF[tf][i] += GBPUSD_Slow*USDCHF_Slow - GBPUSD_Fast*USDCHF_Fast;
           if(AUD)   arrCHF[tf][i] += AUDUSD_Slow*USDCHF_Slow - AUDUSD_Fast*USDCHF_Fast;
           if(NZD)   arrCHF[tf][i] += NZDUSD_Slow*USDCHF_Slow - NZDUSD_Fast*USDCHF_Fast;
           if(CAD)   arrCHF[tf][i] += USDCHF_Slow / USDCAD_Slow - USDCHF_Fast / USDCAD_Fast;
           if(JPY)   arrCHF[tf][i] += USDJPY_Fast / USDCHF_Fast - USDJPY_Slow / USDCHF_Slow;
         }// end if CHF
       if(JPY)
         {
           arrJPY[tf][i] = 0;
           if(USD)   arrJPY[tf][i] += USDJPY_Slow - USDJPY_Fast;
           if(EUR)   arrJPY[tf][i] += EURUSD_Slow*USDJPY_Slow - EURUSD_Fast*USDJPY_Fast;
           if(GBP)   arrJPY[tf][i] += GBPUSD_Slow*USDJPY_Slow - GBPUSD_Fast*USDJPY_Fast;
           if(AUD)   arrJPY[tf][i] += AUDUSD_Slow*USDJPY_Slow - AUDUSD_Fast*USDJPY_Fast;
           if(NZD)   arrJPY[tf][i] += NZDUSD_Slow*USDJPY_Slow - NZDUSD_Fast*USDJPY_Fast;
           if(CAD)   arrJPY[tf][i] += USDJPY_Slow / USDCAD_Slow - USDJPY_Fast / USDCAD_Fast;
           if(CHF)   arrJPY[tf][i] += USDJPY_Slow / USDCHF_Slow - USDJPY_Fast / USDCHF_Fast;
         }// end if JPY
     }//end block for(int i=0; i<limit; i++)
//----
  }
//+------------------------------------------------------------------+
//|  Subroutines                                                     |
//+------------------------------------------------------------------+
double ma(string sym, int tf, int per, int Mode, int price, int shift)
  {
    return(iMA(sym, tf, per, 0, Mode, price, shift));
  }   

