//+------------------------------------------------------------------+
//|                                                         abc1.mq4 |
//|                                                        iamgotzaa |
//|                               http://iamforextrader.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "iamgotzaa"
#property link      "http://iamforextrader.blogspot.com"
#property version   "1.00"
#property strict
#include <SmallFunc.mqh>
#include <LastOrder.mqh>

#include <structure.mqh>
//---

COUNTORDER  port;

string comments;
extern int MA_Method=3;
extern int Price=6;
extern int Fast=3;
extern int Slow=5;
extern int Shift = 0;
input int MagicNumber=3130;
input double yourstartlotsize=0.1;
input int starthour=9;
input int endhour=18;
double ccfp[8];
double sorted[8];
double indexi[8];
//---
//double arrUSD[];  0
//double arrEUR[];  1
//double arrGBP[];  2
//double arrCHF[];  3
//double arrJPY[];  4
//double arrAUD[];  5
//double arrCAD[];  6
//double arrNZD[];  7

double usd,eur,gbp,chf,jpy,aud,cad,nzd;
double maxval=-1000000,minval=1000000;
string maxSymbol,minSymbol;
int barh4;
string stateA=NULL;

string pair[28];
//EURUSD
//GBPUSD
//AUDUSD
//NZDUSD
//USDCAD
//USDJPY
//USDCHF
//EURGBP
//EURAUD
//EURNZD
//EURCAD
//EURJPY
//EURCHF
//GBPAUD
//GBPNZD
//GBPCAD
//GBPJPY
//GBPCHF
//AUDNZD
//AUDCAD
//AUDJPY
//AUDCHF
//NZDCAD
//NZDJPY
//NZDCHF
//CHFJPY
//CADCHF
//CADJPY


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//MagicNumber=AutomaticIDGenerate();
   stateA="idle";
   Assign28SymbolToList(pair);

//find minval
   InitCCFP();
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   string itemcomment;
   if(Hour()<starthour && Hour()>=endhour)
     {
      Comment("Not working hour");
      return;
     }

   if(iBars(NULL,PERIOD_H1)==barh4)
     {
      InitCCFP();

      barh4=iBars(NULL,PERIOD_H1);
     }
   for(int i=0;i<8;i++)
     {
      double valA=ccfp[i];
      string currencyA=SymbolbyIndex(i);

      for(int k=0;k<8;k++)
        {
         double valB=ccfp[k];
         string currencyB=SymbolbyIndex(k);
         string ComposeSymbol=currencyA+currencyB;
         string ComposeSymbol_R=currencyB+currencyA;
         string finalSymbol;
         double finalValA=0;
         double finalValB=0;
         if(VerifySymbol(pair,ComposeSymbol))
           {
            finalSymbol=ComposeSymbol;
            finalValA=valA;
            finalValB=valB;
           }
         if(VerifySymbol(pair,ComposeSymbol_R))
           {
            finalSymbol=ComposeSymbol_R;
            finalValA=valB;
            finalValB=valA;
           }
         if(order_count_symbol(MagicNumber,finalSymbol)==0 && currencyB!="JPY")
           {
            double ATR=iATR(finalSymbol,PERIOD_D1,20,1);
            double StopOffset=NormalizeDouble(1.2*ATR,(int)MarketInfo(finalSymbol,MODE_DIGITS));
            double TargetOffset=NormalizeDouble(1.8*ATR,(int)MarketInfo(finalSymbol,MODE_DIGITS));
            if(MathAbs(finalValA-finalValB)>990*Point)
              {
              double ask=MarketInfo(finalSymbol,MODE_ASK);
                  double bid=MarketInfo(finalSymbol,MODE_BID);
               if(finalValA>100*Point && finalValB<100*Point && ask>0 && bid>0)
                 {
                  //Print("Buy ",finalSymbol);
                  //Print("sl=",ask-StopOffset," tp",ask+TargetOffset);
                  int t=OrderSend(finalSymbol,OP_BUY,yourstartlotsize,
                                  ask,5,
                                  ask-StopOffset,
                                  ask+TargetOffset,
                                  "abc1",MagicNumber);
                 }
               if(finalValA<100*Point && finalValB>100*Point && ask>0 && bid>0)
                 {
                  //Print("Sell ",finalSymbol);
                  int t=OrderSend(finalSymbol,OP_SELL,yourstartlotsize,
                                  bid,5,
                                  bid+StopOffset,
                                  bid-TargetOffset,
                                  "abc1",MagicNumber);
                 }
              }

           }

        }
     }

//Autotrailing
   for(int i=0;i<OrdersTotal();i++)
     {
      int ticket=0;
      string thissymbol="";
      if(OrderSelect(i,SELECT_BY_POS))
        {
         if(OrderMagicNumber()==MagicNumber)
           {
            ticket=OrderTicket();
            thissymbol=OrderSymbol();
           }
         string counter=StringSubstr(thissymbol,0,3);
         string base=StringSubstr(thissymbol,3,3);

         if(OrderType()==OP_BUY)
           {
            if( ccfp[IndexbySymbol(counter)]<ccfp[IndexbySymbol(base)])
              {
               close_order_immediate(ticket);
              }
           }
         if(OrderType()==OP_SELL)
           {
            if(ccfp[IndexbySymbol(counter)]>ccfp[IndexbySymbol(base)])
              {
               close_order_immediate(ticket);
              }
           }
         stoplosswheelbarrel2(ticket,300*Point,50*Point);

         itemcomment=itemcomment+" "+IntegerToString(OrderTicket())+
                     " "+OrderSymbol()+
                     " $"+DoubleToString(OrderProfit(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS))+
                     "\n";

        }
     }
   Comment(itemcomment);
  }
//+------------------------------------------------------------------+

void info(string yourmsg)
  {
   comments=comments+" ["+__FUNCTION__+"] "+yourmsg+"\n";
  }
//+------------------------------------------------------------------+
void  WaitforEntry(string &_state)
  {
   if(_state!="idle")
     {
      return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WaitforStop(string &_state)
  {
   if(_state!="trailing")
     {
      return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Hold(string &_state)
  {
   if(_state!="hold")
     {
      return;
     }

  }
//+------------------------------------------------------------------+
string SymbolbyIndex(int index)
  {
//double usd,eur,gbp,chf,jpy,aud,cad,nzd;
   switch(index)
     {
      case  0: return("USD");  break;
      case  1: return("EUR");  break;
      case  2: return("GBP");  break;
      case  3: return("CHF");  break;
      case  4: return("JPY");  break;
      case  5: return("AUD");  break;
      case  6: return("CAD");  break;
      case  7: return("NZD");  break;

      default: return("");
      break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int IndexbySymbol(string symbol)
  {
   if(symbol=="USD") return(0);
   if(symbol=="EUR") return(1);
   if(symbol=="GBP") return(2);
   if(symbol=="CHF") return(3);
   if(symbol=="JPY") return(4);
   if(symbol=="AUD") return(5);
   if(symbol=="CAD") return(6);
   if(symbol=="NZD") return(7);
   else return(-1);
  }
//+------------------------------------------------------------------+
void InitCCFP()
  {
   for(int i=0;i<8;i++)
     {
      RefreshRates();
      // ccfp[i]=iCustom(NULL,PERIOD_D1,"CCFp",i,0);
      ccfp[i]=iCustom(NULL, PERIOD_D1, "CCFp", false,MA_Method, Price, Fast, Slow, True, True, True, True
        , True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, 0, 0, i, Shift);
     }
//---
//find maxval
   for(int i=0;i<8;i++)
     {
      if(ccfp[i]>maxval)
        {
         maxval=ccfp[i];
         maxSymbol=SymbolbyIndex(i);
        }

      if(ccfp[i]<minval)
        {
         minval=ccfp[i];
         minSymbol=SymbolbyIndex(i);
        }
     }

//Print("Max ccfp is ",maxSymbol," = ",maxval);
//Print("Min ccfp is ",minSymbol," = ",minval);
  }
//+------------------------------------------------------------------+
bool VerifySymbol(string &list[],string yoursymbol)
  {
   for(int i=0;i<ArraySize(list);i++)
     {
      if(yoursymbol==list[i])
        {
         return(true);
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Assign28SymbolToList(string &array[])
  {
//EURUSD
//GBPUSD
//AUDUSD
//NZDUSD
//USDCAD
//USDJPY
//USDCHF
   array[0]="EURUSD";
   array[1]="GBPUSD";
   array[2]="AUDUSD";
   array[3]="NZDUSD";
   array[4]="USDCAD";
   array[5]="USDJPY";
   array[6]="USDCHF";
//EURGBP
//EURAUD
//EURNZD
//EURCAD
//EURJPY
//EURCHF
   array[7]="EURGBP";
   array[8]="EURAUD";
   array[9]="EURNZD";
   array[10]="EURCAD";
   array[11]="EURJPY";
   array[12]="EURCHF";
//GBPAUD
//GBPNZD
//GBPCAD
//GBPJPY
//GBPCHF
   array[13]="GBPAUD";
   array[14]="GBPNZD";
   array[15]="GBPCAD";
   array[16]="GBPJPY";
   array[17]="GBPCHF";

//AUDNZD
//AUDCAD
//AUDJPY
//AUDCHF
   array[18]="AUDNZD";
   array[19]="AUDCAD";
   array[20]="AUDJPY";
   array[21]="AUDCHF";
//NZDCAD
//NZDJPY
//NZDCHF
   array[22]="NZDCAD";
   array[23]="NZDJPY";
   array[24]="NZDCHF";
//CHFJPY
//CADCHF
//CADJPY
   array[25]="CHFJPY";
   array[26]="CADCHF";
   array[27]="CADJPY";
  }
//+------------------------------------------------------------------+
