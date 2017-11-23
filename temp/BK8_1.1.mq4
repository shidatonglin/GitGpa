//+------------------------------------------------------------------+
//|                                                          Abdul_EA 
//|                         Copyright 2016, FxMath Financial Solution  
//|                                            https://www.fxmath.com  
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, FxMath Financial Solution"
#property link      "https://www.fxmath.com "




extern string  Version="1.1";

extern string Section_1="SL/TP Settings";
extern bool FIX_SLTP=true;
extern double Fix_TakeProfit=50;
extern double Fix_StopLoss=50;


extern bool Trailing_Enable=true;
extern double TrailingStop=10;





//+------------------------------------------------------------------+


extern string Section_2="Indicator Settings";
extern string Section_2_1="Moving Average Setting";
extern int ma_period=5;
extern int ma_shift=3;
extern int ma_method=MODE_SMA;
extern int ma_price=PRICE_CLOSE;

extern string Section_2_2="Bands Setting";
extern int band_period=20;
extern int band_deviation=0;
extern int band_shift=2;
extern int band_price=PRICE_CLOSE;





extern string Section_3="Money Management";
extern bool UseMoneyManagement = false;
extern double Lots = 0.1;
 int LotsDecimals = 2;
extern double PercentageRisked = 2.0;
extern double MaximumLots = 0.5;



double Slip=3;
extern int MagicNumber=2016;
extern string TradeComment="Abdul_EA";


extern string Section_4="Trade Time";
extern bool   UseTimer = true;
extern string Timer = "08:00-16:00";



bool License=False;

int lastDeletedOrderTicket = -1;
int lastHistoryPosChecked = 0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
   Slip*=PointValue(); 
	Fix_StopLoss*=PointValue(); 
	Fix_TakeProfit*=PointValue();
	TrailingStop*=PointValue(); 

	LotsDecimals = (int)MathCeil(MathAbs(MathLog(MarketInfo(Symbol(), MODE_LOTSTEP)) / MathLog(10)));

	
   
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
  

  
  if(Signal()==1){OpenPosition(1);}
  if(Signal()==2){OpenPosition(-1);}


 if(FIX_SLTP)ModifySLTP();
   
if(Trailing_Enable)Trailing();




   return(0);
  }


//+-------------------Trailing--------------------------------+
void Trailing(){

bool res;
for (int l_pos_0 = 0; l_pos_0 <= OrdersTotal(); l_pos_0++) {
      
      if (OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol()  && OrderMagicNumber()==MagicNumber && TrailingStop>0 ){
if(OrderType()==OP_BUY && Bid-OrderOpenPrice()>TrailingStop && OrderStopLoss()<Bid-TrailingStop){res=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TrailingStop,OrderTakeProfit(),0,Green);return;}  
if(OrderType()==OP_SELL && OrderOpenPrice()-Ask>TrailingStop && OrderStopLoss()>Ask+TrailingStop){res=OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TrailingStop,OrderTakeProfit(),0,Red);return;}
} 
         } 
         return;
}
//+-------------------openPosition--------------------------------+
void OpenPosition(int Status){
 
if(Status==1 && TotalOrder(2)>0)CloseOrders();
if(Status==-1 && TotalOrder(1)>0)CloseOrders();
int ticket=0;

double StopLossPips=Fix_StopLoss;
 
if(!checkTradeClosedThisMinute() && !checkTradeClosedThisBar()){   
if(Status==1 && TotalOrder(3)<1)ticket=OrderSend(Symbol(),OP_BUY,getLots(StopLossPips/PointValue()),Ask,Slip,0,0,TradeComment,MagicNumber,0,Green);
if(Status==-1 && TotalOrder(3)<1)ticket=OrderSend(Symbol(),OP_SELL,getLots(StopLossPips/PointValue()),Bid,Slip,0,0,TradeComment,MagicNumber,0,Red);

 }
}
//+-------------------Close Orders--------------------------------+
void CloseOrdersReverse(){
bool res;
for (int l_pos_0 = 0; l_pos_0 <= OrdersTotal(); l_pos_0++) {
    //  OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES)==true && OrderSymbol() == Symbol() && OrderMagicNumber()==MagicNumber ){
      if(OrderType()==OP_BUY && Signal()==2)res=OrderClose(OrderTicket(),OrderLots(),Bid,Slip,Yellow);
      if(OrderType()==OP_SELL && Signal()==1)res=OrderClose(OrderTicket(),OrderLots(),Ask,Slip,Yellow);
      }
      }
      return;
}
//+------------------------------------------------------------------+

bool isMarketLongPosition() {
   for(int i=0; i<OrdersTotal(); i++) {
      if (OrderSelect(i,SELECT_BY_POS)==true && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
         if(OrderType() == OP_BUY) {
            return(true);
         }
      }
   }

   return(false);
}

//+------------------------------------------------------------------+

bool isMarketShortPosition() {
   for(int i=0; i<OrdersTotal(); i++) {
      if (OrderSelect(i,SELECT_BY_POS)==true && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
         if(OrderType() == OP_SELL) {
            return(true);
         }
      }
   }

   return(false);
}


bool checkTradeClosedThisMinute() {
   string currentTime2 = TimeToStr( TimeCurrent(), TIME_DATE|TIME_MINUTES);

   int startAt = lastHistoryPosChecked-10;
   if(startAt < 0) {
      startAt = 0;
   }

   for(int i=startAt;i<OrdersHistoryTotal();i++) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
         string orderTime = TimeToStr( OrderCloseTime(), TIME_DATE|TIME_MINUTES);

         if(lastDeletedOrderTicket != -1 && OrderTicket() == lastDeletedOrderTicket) {
                continue;
         }
         
         lastHistoryPosChecked = i;

         if(orderTime == currentTime2) {
            return(true);
         }
      }
   }

   return(false);
}

//+------------------------------------------------------------------+

bool checkTradeClosedThisBar() {
   int startAt = lastHistoryPosChecked-10;
   if(startAt < 0) {
      startAt = 0;
   }

   for(int i=startAt;i<OrdersHistoryTotal();i++) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
         if((OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderCloseTime() >= Time[0]) {
            return(true);
         }
      }
   }

   return(false);
}

//+------------------------------------------------------------------+

int getOpenBarsForOrder(int expBarsPeriod) {
   datetime opTime = OrderOpenTime();

   int numberOfBars = 0;
   for(int i=0; i<expBarsPeriod+10; i++) {
      if(opTime < Time[i]) {
         numberOfBars++;
      }
   }

   return(numberOfBars);
}
//+-------------------Close Orders--------------------------------+
void CloseOrders(){
bool res;
for (int l_pos_0 = 0; l_pos_0 <= OrdersTotal(); l_pos_0++) {
     // OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES)==true && OrderSymbol() == Symbol() && OrderMagicNumber()==MagicNumber && (OrderStopLoss()==0 || OrderTakeProfit()==0) ){
      if(OrderType()==OP_BUY)res=OrderClose(OrderTicket(),OrderLots(),Bid,Slip,Yellow);
      if(OrderType()==OP_SELL)res=OrderClose(OrderTicket(),OrderLots(),Ask,Slip,Yellow);
      }
      }
      return;
}

//+-------------------ModifySLTP--------------------------------+
void ModifySLTP(){
for (int l_pos_0 = 0; l_pos_0 <= OrdersTotal(); l_pos_0++) {
      if (OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES)==true && OrderSymbol() == Symbol()  && OrderMagicNumber()==MagicNumber  && (OrderStopLoss()==0||OrderTakeProfit()==0)){
     
      double StopLossPips=0;
      double ProfitTargetPips=0;
     
    StopLossPips=Fix_StopLoss;
    ProfitTargetPips=Fix_TakeProfit;
      
      
	 
	  bool res;
      if(OrderType()==OP_BUY )res=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-StopLossPips,OrderOpenPrice()+ProfitTargetPips,0,Green);
      if(OrderType()==OP_SELL )res=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+StopLossPips,OrderOpenPrice()-ProfitTargetPips,0,Red);
      }
      }
      return;
}
//+-------------------Total Orders--------------------------------+
int TotalOrder(int mode){
int sum=0;
for (int l_pos_0 = 0; l_pos_0 <= OrdersTotal(); l_pos_0++) {
      if(OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES)){
      if (OrderSymbol() == Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_BUY && mode==1)sum++;
      if (OrderSymbol() == Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_SELL && mode==2)sum++;
      if (OrderSymbol() == Symbol() && OrderMagicNumber()==MagicNumber &&  mode==3)sum++;
      }
	  }
      return(sum);
}
//+---------------------------Signal----------------------------+
int Signal(){

if(Close[1]>ma(1) && Open[1]<ma(1) && Open[0]>ma(0) && TimeFilter())return(1);
if(Close[1]<ma(1) && Open[1]>ma(1) && Open[0]<ma(0) && TimeFilter())return(2);

return(0);
}

//+---------------------------Bands----------------------------+
double band(int mode,int shift){
return(iBands(NULL,0,band_period,band_deviation,band_shift,band_price,mode,shift));
}
//+---------------------------MA----------------------------+
double ma(int shift){
return(iMA(NULL,0,ma_period,ma_shift,ma_method,ma_price,shift));
}

//+-------------------PointValue--------------------------------+
double PointValue() {
   if (MarketInfo(Symbol(), MODE_DIGITS) == 5.0 || MarketInfo(Symbol(), MODE_DIGITS) == 3.0) return (10.0 * Point);
   return (Point);
}



//+------------------------------------------------------------------+

double getLots(double slSize) {
   if(slSize <= 0) {
      return(Lots);
   }

   if(UseMoneyManagement == false) {
      if(Lots > MaximumLots) {
         return(MaximumLots);
      }

      return(Lots);
   }

   
      return(getLotsRiskPercentage(slSize));
  
}


double getLotsRiskPercentage(double slSize) {
   if(PercentageRisked <0 ) {
       return(0);
   }

   double riskPerTrade = (AccountBalance() *  (PercentageRisked / 100.0));
   return(computeMMFromRiskPerTrade(riskPerTrade, slSize));
}


double computeMMFromRiskPerTrade(double riskPerTrade, double slSize) {
   if(slSize <= 0) {
        return(0);
   }

  
   double CurrencyAdjuster=1;
   if (MarketInfo(Symbol(),MODE_TICKSIZE)!=0) CurrencyAdjuster=MarketInfo(Symbol(),MODE_TICKVALUE) * (MarketInfo(Symbol(),MODE_POINT) / MarketInfo(Symbol(),MODE_TICKSIZE));

   double lotMM1 = NormalizeDouble(riskPerTrade / CurrencyAdjuster / (slSize * 10.0), LotsDecimals);
   double lotMM;
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   if(MathMod(lotMM*100, lotStep*100) > 0) {
      lotMM = lotMM1 - MathMod(lotMM1, lotStep);
   } else {
      lotMM = lotMM1;
   }

   lotMM = NormalizeDouble( lotMM, LotsDecimals);

   if(MarketInfo(Symbol(), MODE_LOTSIZE)==10000.0) lotMM=lotMM*10.0 ;
   lotMM=NormalizeDouble(lotMM,LotsDecimals);

   double Smallest_Lot = MarketInfo(Symbol(), MODE_MINLOT);
   double Largest_Lot = MarketInfo(Symbol(), MODE_MAXLOT);

   if (lotMM < Smallest_Lot) lotMM = Smallest_Lot;
   if (lotMM > Largest_Lot) lotMM = Largest_Lot;

   if(lotMM > MaximumLots) {
      lotMM = MaximumLots;
   }
 

   return (lotMM);
}

//+-------------------Time Filter--------------------------------+
bool TimeFilter()
 {
  if (!UseTimer)return(true);
  if (Timer=="" || Timer==" ")return(true);
  
  int pos = StringFind(Timer,"-",0);
  int top = StrToTime(StringTrimLeft(StringTrimRight(StringSubstr(Timer,0,pos))));
  int tcl = StrToTime(StringTrimLeft(StringTrimRight(StringSubstr(Timer,pos+1))));
  
  if(top<tcl)
   {
    if(TimeCurrent()>=top&&TimeCurrent()<tcl)return(true);
    else return(false);
   }
  if (top>tcl)
   {
    if(TimeCurrent()>=top||TimeCurrent()<tcl)return(true);
    else return(false);         
   }
  return(true);
 }


