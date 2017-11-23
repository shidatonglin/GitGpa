//+------------------------------------------------------------------+
//|                                    PowerSM SemiMartingale-EA.mq4 |
//|             Copyright ?2007, Scott Merritt, mer071898@mchsi.com |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2007, Scott Merritt, modified by RickD"
#property link      "http://www.mql4.info/, http://www.e2e-fx.com"
#include <stdlib.mqh>

#define acct 0 //if not 0 then will work only on this account number
#define expireD 1
#define expireM 1
#define expireY 2020
#define buy 1;
#define sell 0;
string   Expire_Message = "Your trial period is over!"; 

// TO DO
// 1. Add target profit exit conditions
// 2. Add set up number control logic
// 3.
extern int expertId = 183547;
extern int TakeProfit=400;
extern int StopLoss=100;
extern int BreakevenStop = 250;

extern bool TimeEntry=true;
extern string StartTime="15:20";
extern string StopTime="22:30";
extern bool PriceEntry=false;
extern double Price=1.5500;
extern bool FirstLong=false;
extern string LotsProgression="0.1;0.1;0.2;0.3;0.4;0.6;0.8;1.1;1.5;2.0;2.7;3.6;4.7;6.2;8.0;10.2;13.0;16.5;20.8;26.3;33.1;41.6;52.2;65.5;82.5;103.9;130.9;165;207.9;262;330.1;416;524.7;661.1";
extern bool RestartNewCycle = true;
extern bool userMinLot=true;

extern int    slippage=3;   	//slippage for market order processing
extern int    OrderTriesNumber=10; //to repeat sending orders when you receive an error or requote

extern string    EAName="PowerSM"; 
extern double  targetProfit = 2.5;
extern int    Fast_EMA           = 12;
extern int    Slow_EMA           = 26;
extern int    Signal_SMA         = 9;
extern int    Shift              = 1;
extern int    TradingRange       = 0;


bool buysig,sellsig,cycleended;
int tries,co,plen,lord,mord,lpos;
double Lot,lots[],tlot,lop,lcp,lsl,ltp;
double setprofit,cur_profit;
double lbid = -1;
int counter = 0;
datetime curr_time = 0;
int init() 
{
   int i,j,k;
   string ls;
   while (true) {
   	j=StringFind(LotsProgression,";",i);
   	if (j>0) {
   		ls=StringSubstr(LotsProgression,i,j-i);
   		i=j+1;
   		k++;
   		ArrayResize(lots,k);
   		lots[k-1]=StrToDouble(ls);
		if(userMinLot) {
			lots[k-1]=lots[k-1]/10;
		}
   	} else {
   		ls=StringSubstr(LotsProgression,i);
   		k++;
   		ArrayResize(lots,k);
   		lots[k-1]=StrToDouble(ls);
		if(userMinLot) {
			lots[k-1]=lots[k-1]/10;
		}
   		break;
   	}
   }

   plen=ArraySize(lots);
}

void start()  {
   if (Year()*10000+Month()*100+Day()>=expireY*10000+expireM*100+expireD) {
      Alert("Expire_Message");
      double d1;
      d1=2/d1;
      return(-1);
   }
   if (acct!=0 && AccountNumber()!=acct) {
      Alert("EA will not work on this account number");
      double d;
      d=2/d;
      return(-1);
   }
   //---- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false) return;
   
   //if(curr_time>=Time[0]) return;
   //else curr_time =Time[0];

   if (lbid == -1) lbid = Bid;

   co=CalculateCurrentOrders();
   if (co > 0) counter = 1;
   CheckForClose();  
   CheckForSignals();
   CheckForOpen();  
   DoBreakEven(BreakevenStop,0);
   //Comment("serve time now=="+TimeCurrent());
   //Comment("Local time now=="+TimeLocal());
   lbid = Bid;
}


int CalculateCurrentOrders() {
   int ord; string c;
//----
   for(int i=0;i<OrdersTotal();i++) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==expertId) {
         ord++;
		 cur_profit = OrderProfit();
         if (OrderType()==OP_BUY) {
            mord=1;
            if (OrderClosePrice()-OrderOpenPrice()>BreakevenStop*Point) tlot=MathAbs(tlot); else tlot=-MathAbs(tlot);
         }
         if (OrderType()==OP_SELL) {
            mord=-1;
            if (-OrderClosePrice()+OrderOpenPrice()>BreakevenStop*Point) tlot=MathAbs(tlot); else tlot=-MathAbs(tlot);
         }
         c=StringSubstr(OrderComment(),0,StringFind(OrderComment(),"_",0));
         lpos=StrToInteger(c);
         return(ord);
      }
   }
//---- return orders volume
   return(ord);
}

double GetLastTrade() 
{
   int ord; lord=0;
   string c;
//----
   for(int i=OrdersHistoryTotal()-1;i>=0;i--) 
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==expertId) 
      {
         if (OrderType()==OP_BUY) lord=1;
         if (OrderType()==OP_SELL) lord=-1;
         c=StringSubstr(OrderComment(),0,StringFind(OrderComment(),"_",0));
         lpos=StrToInteger(c);
         if(lpos==0){
			setprofit = 0;
		 }
		 setprofit = setprofit + OrderProfit();
         lop = NormalizeDouble(OrderOpenPrice(), Digits);
         lcp = NormalizeDouble(OrderClosePrice(), Digits);
         lsl = NormalizeDouble(OrderStopLoss(), Digits);
         ltp = NormalizeDouble(OrderTakeProfit(), Digits);
         
         if (OrderProfit()>0) 
          return(OrderLots()); 
         else 
          return(-OrderLots());
      }
   }
   return(0);
}

bool IsEntryTime()
{
  datetime tm0 = TimeLocal();
  datetime tm1 = StrToTime(TimeToStr(tm0, TIME_DATE) + " " + StartTime);
  datetime tm2 = StrToTime(TimeToStr(tm0, TIME_DATE) + " " + StopTime);

  bool isTm = false; 
  if (tm1 <= tm2) 
    isTm = isTm || (tm1 <= tm0 && tm0 < tm2);
  else
    isTm = isTm || (tm1 <= tm0 || tm0 < tm2);
  
  return (isTm);
}

void CheckForSignals() 
{
  buysig = false;
  sellsig = false;
      
	if (co > 0) return;

  if (TimeEntry)
  {
    bool cond = IsEntryTime();
    if (!cond) return;
  }

  if (PriceEntry)
  { 
    cond = ((Bid >= Price && lbid < Price) || (Bid <= Price && lbid > Price));
    if (!cond) return;
  }
	
	double lastlot = GetLastTrade();
	if (lastlot >= 0)
	{
	  if (counter > 0)
	  {
	    if (!RestartNewCycle) return;
	  }
	
    if (FirstLong) 
      buysig = true; 
    else 
      sellsig = true;
      
    lpos = 0;
    Lot = lots[0];
	}

	else
	{
    lpos++;

    int BE = 0;
    if (lord > 0 && lcp == lop+BE*Point) lpos--;
    if (lord < 0 && lcp == lop-BE*Point) lpos--;

    Lot = lots[lpos];
    if (lord > 0) 
      sellsig = true;
    else if (lord < 0) 
      buysig = true;
  }
  /*
  int macd = MACD();
  if(macd==1 && buysig) buysig=true;
  else buysig=false;
  
  if(macd==0 && sellsig) sellsig=true;
  else sellsig=false;
  if(false){
     if(macd==1) buysig=true;
     else buysig=false;
     
     if(macd==0) sellsig=true;
     else sellsig=false;
  }
  */
  
  
}

void CheckForOpen() {
   int    res,tr,TP;
   //---- sell conditions
   if(sellsig && co==0)  {
	   Print("sell open ",Lot," ",lpos);
      res = OpenAtMarket(OP_SELL,Lot,TakeProfit,lpos);
	   if (res>0) { tlot=Lot; }
      return;
   }
   //---- buy conditions
   if(buysig && co==0)  {
	   Print("buy open ",Lot," ",lpos);
      res = OpenAtMarket(OP_BUY,Lot,TakeProfit,lpos);
	   if (res>0) { tlot=Lot; }
      return;
   }
}

void CheckForClose(){
	if(setprofit >0){// set close normally, do nothing
		
	} else {
		bool is_closed = false;
		if(setprofit+cur_profit>targetProfit){
			for(int i=0;i<OrdersTotal();i++) {
			  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
			  if(OrderSymbol()==Symbol() && OrderMagicNumber()==expertId) {
				  if (OrderType()==OP_BUY) {
					is_closed = false;
   					while(!is_closed){
						is_closed = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID),MarketInfo(OrderSymbol(),MODE_DIGITS)),3,Red);
					 }
				  }
				  if (OrderType()==OP_SELL){
					is_closed = false;
					while(!is_closed){
						is_closed = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK),MarketInfo(OrderSymbol(),MODE_DIGITS)),3,Red);
					 }
				  }  
			  }
		   }
		}
	}	
}
  
int OpenAtMarket(int mode,double lot,int TP,int pos) {
   int    res,tr,col;
   double openprice,sl,tp;
   tries=0;
   while (res<=0 && tries<OrderTriesNumber) {
      tr=0; while (tr<5 && !IsTradeAllowed()) { tr++; Sleep(2000); }
      RefreshRates();
      if (mode==OP_SELL) {
         openprice=Bid; 
         if (StopLoss>0) sl=openprice+StopLoss*Point;
         if (TP>0) tp=openprice-TP*Point;
         col=Red;
      } else {
         openprice=Ask;
         if (StopLoss>0) sl=openprice-StopLoss*Point;
         if (TP>0) tp=openprice+TP*Point;
         col=Blue;
      }
      res=OrderSend(Symbol(),mode,lot,openprice,slippage,sl,tp,pos+"_"+EAName+"_"+expertId,expertId,0,col);
      tries++;
   }
   Print("market order:: ",Symbol(),"  ",mode,"  ",lot,"  ",openprice,"  ",sl,"  ",tp,"  ",pos+"_"+EAName+"_"+expertId);
   if (res<=0) Print("error opening order : ",ErrorDescription(GetLastError()));
   return(res);
}


void DoBreakEven(int BP, int BE) {
   bool bres;
   for (int i = 0; i < OrdersTotal(); i++) {
      if ( !OrderSelect (i, SELECT_BY_POS) )  continue;
      if ( OrderSymbol() != Symbol() || OrderMagicNumber() != expertId )  continue;
      if ( OrderType() == OP_BUY ) {
         if (Bid<OrderOpenPrice()+BP*Point) continue;
         if ( OrderOpenPrice()+BE*Point-OrderStopLoss()>Point/10) {
               //Print(BP,"  ",BE," bestop");
               bres=OrderModify (OrderTicket(), OrderOpenPrice(), OrderOpenPrice()+BE*Point, OrderTakeProfit(), 0, Black);
				   if (!bres) Print("Error Modifying BE BUY order : ",ErrorDescription(GetLastError()));
         }
      }

      if ( OrderType() == OP_SELL ) {
         if (Ask>OrderOpenPrice()-BP*Point) continue;
         if ( OrderStopLoss()-(OrderOpenPrice()-BE*Point)>Point/10) {
               //Print(BP,"  ",BE," bestop");
               bres=OrderModify (OrderTicket(), OrderOpenPrice(), OrderOpenPrice()-BE*Point, OrderTakeProfit(), 0, Gold);
				   if (!bres) Print("Error Modifying BE SELL order : ",ErrorDescription(GetLastError()));
         }
      }
   }
   return;
}

int MACD()
{
   int myOrderType =3;
   double MACDMainCurr=iMACD(NULL,0,Fast_EMA,Slow_EMA,Signal_SMA,PRICE_CLOSE,MODE_MAIN,Shift);
   double MACDSigCurr=iMACD(NULL,0,Fast_EMA,Slow_EMA,Signal_SMA,PRICE_CLOSE,MODE_SIGNAL,Shift);
   double MACDMainPre=iMACD(NULL,0,Fast_EMA,Slow_EMA,Signal_SMA,PRICE_CLOSE,MODE_MAIN,Shift+1);
   double MACDSigPre=iMACD(NULL,0,Fast_EMA,Slow_EMA,Signal_SMA,PRICE_CLOSE,MODE_SIGNAL,Shift+1);

   double SellRange=TradingRange*Point;
   double BuyRange=(TradingRange-(TradingRange*2))*Point;
   int minu = TimeMinute(TimeLocal());
   
   if(MACDMainCurr>MACDSigCurr && MACDMainPre<MACDSigPre && MACDSigPre<BuyRange && MACDMainCurr<0  && minu<=30) {myOrderType=buy;}
   if(MACDMainCurr<MACDSigCurr && MACDMainPre>MACDSigPre && MACDSigPre>SellRange && MACDMainCurr>0  && minu<=30) {myOrderType=sell;}

	return(myOrderType);
}


int getSignal(){
   bool userBB=true,useWPR,useRSI;
    int       bb_period = 20;
    int       bb_deviation = 2.5;
    int       bb_shift = 0;
   if(userBB){
      double upBB=iBands(NULL,0,bb_period,bb_deviation,0,PRICE_CLOSE,MODE_UPPER,bb_shift);
      double loBB=iBands(NULL,0,bb_period,bb_deviation,0,PRICE_CLOSE,MODE_LOWER,bb_shift);
   	if(Ask > upBB || Bid < loBB){
   		return true;
   	} else {
   		return false;
   	}   
   }
   if(useWPR){
      
   }
   if(useRSI){
      
   }
   

}

/*
int FindPos(double ls) {
   for (int i=0; i<plen; i++) {
      if (NormalizeDouble(MathAbs(lots[i]-ls),3)<0.001) return(i);
   }
   return(-1);
}
*/