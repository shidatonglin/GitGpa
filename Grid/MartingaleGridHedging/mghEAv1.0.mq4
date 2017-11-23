#include <WinUser32.mqh>
//#include <stdlib.mqh>
#include <OrderSendReliable.mq4>
//#include <OrderCloseReliable.mqh>
//--- input parameters


extern double  BaseLot        = 0.05;
extern double  maxLot         =2;

extern int     MagicNo        = 2955;
extern int     MaxLevel       =3;
extern double  ClsPercnt      = 0.1;
extern   int   OrderGap       =10;



string	      TextDisplay;

static double  pt;
string         TradeComment   = "mghA";

int            numBuy, numSell, prevnumBuy, prevnumSell, numPenBuy, numPenSell;


double         maxBuyLots, maxSellLots, totalProfit, AllProfit, prevEquity=0, currEquity=0;



static double  lowestBuyPrice, highestSellPrice, lowestSellPrice, highestBuyPrice, lowestSellPrice2, highestBuyPrice2;
datetime       lastBuyTime, lastSellTime;
double         totalSellProfit, totalBuyProfit;
int            lastestOrderCloseType;

double         AveragePrice, TotalVolume;
bool           EAsuspended=false;
datetime       SuspenEATime=0;
void init()
{
   pt = Point;
   if (Digits == 3 || Digits == 5) pt = 10*pt;

}


void start()
{
   
   
  
   
       
     CountOrders();
     if(numBuy==0 && numSell==0) prevEquity=AccountEquity();
     if(numBuy!=0 || numSell!=0) currEquity=AccountEquity();
     prevnumSell=numSell;
     prevnumBuy=numBuy;
     double tp=0;

     	for (int i = 0; i < OrdersTotal(); i++) {
	    	
	    	
	    	if ( OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol()  && OrderTakeProfit()==0 )

	    	     { 
	    	       
	    	       if (OrderType()==OP_SELL)
	    	         {
	    	            if(numSell==1) tp=lowestSellPrice -10 *pt;
	    	            if(numSell>1) tp=lowestSellPrice;
	    	            SetTakeProfit(OP_SELL, tp);
	    	          }
	    	          
	    	       if (OrderType()==OP_BUY)
	    	         {
	    	            if(numBuy==1) tp=highestBuyPrice +10 *pt;
	    	            if(numBuy>1)  tp=highestBuyPrice;
	    	            SetTakeProfit(OP_BUY, tp);
	    	          }	    	            
	    	       
	     }  
  
}


   double OpenProfit=   totalBuyProfit  +    totalSellProfit;

                                                            
TextDisplay="\nOpen Buy: "     + numBuy    + " Open Sell: " + numSell + " Open Sell Profit: " + totalSellProfit + " Open Buy Profit: " + totalBuyProfit + " OPen Profit: " + OpenProfit;

TextDisplay=CheckReport () + TextDisplay ;
Comment(TextDisplay);
//  if((numBuy == MaxLevel && numSell == MaxLevel) && (currEquity-prevEquity)/prevEquity>= ClsPercnt) CloseOpenPairPositions();


  ManageOrders();
   
}


void PlaceSingleOrder(string sym, int type, double lotsize, double price)
{
   int ticket, result;
 
        ticket= OrderSendReliable(sym, type, lotsize, price, 0, 0, 0, TradeComment, MagicNo, 0, 0);
        
       if (ticket>0 && type==OP_SELL)
        {
          while (prevnumSell==numSell)
            {
               CountOrders();
             }
           prevnumSell=numSell;
         }
         
       if (ticket>0 && type==OP_BUY)
        {
          while (prevnumBuy==numBuy)
            {
               CountOrders();
             }
           prevnumBuy=numBuy;
         }
         
   
      if (ticket < 0)
      {
         // error handling: to be implemented
         int e = GetLastError();
         Print("Error: "+DoubleToStr(e, 0));
      }
  // }
   
}



void CountOrders()
{
   numBuy = 0; numSell = 0; maxBuyLots = 0; maxSellLots = 0; totalSellProfit = 0; totalBuyProfit= 0;
   double buyProfit1=0; double buyProfit2=0; double sellProfit1=0; double sellProfit2=0; 
   lowestBuyPrice = 9999; highestSellPrice = 0; lowestSellPrice = 9999; highestBuyPrice = 0;lowestSellPrice2=9999; highestBuyPrice2=0;
   for(int cnt = OrdersTotal()-1; cnt >= 0; cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() == Symbol())
      {
         if ( OrderType() == OP_BUY) 
           { 
             numBuy++;
              buyProfit1 +=OrderProfit()+ OrderSwap() + OrderCommission();
              if (OrderOpenPrice() < lowestBuyPrice) 
                 {
                   lowestBuyPrice = OrderOpenPrice(); 
                   lastBuyTime = OrderOpenTime();
                 }
             if (OrderOpenPrice() > highestBuyPrice) 
                { highestBuyPrice =OrderOpenPrice();}
            
           //   totalBuyProfit += OrderProfit();
              if (OrderLots() > maxBuyLots) maxBuyLots = OrderLots();
           }
         else if ( OrderType() == OP_SELL)
            {
              numSell++;
              sellProfit1 +=OrderProfit()+ OrderSwap() + OrderCommission();
               if (OrderOpenPrice() > highestSellPrice) 
                  {
                    highestSellPrice = OrderOpenPrice(); 
                    lastSellTime =OrderOpenTime();
                  }
                 if (OrderOpenPrice() < lowestSellPrice)   
                   { lowestSellPrice = OrderOpenPrice();}
                  
            //    totalSellProfit += OrderProfit();
               if (OrderLots() > maxSellLots) maxSellLots = OrderLots();
            }
            
            
        //

        
        totalBuyProfit = buyProfit1;
        totalSellProfit = sellProfit1 ;
      }
   }
}

double  SetTakeProfit(int type, double tp) 
{

   

 
      for ( int i = 0; i < OrdersTotal(); i++)
      {

 //        if ( OrderSelect(i, SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol()  && OrderMagicNumber()==Magic && OrderType()==type ) ModifySelectedOrder(type, TP);
         if ( OrderSelect(i, SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol()   && OrderType()==type ) ModifySelectedOrder(type, tp);
      }   
}

void CloseOpenPairPositions()
{
  for (int i=10; i>=0; i--)
   {
   for(int cnt = OrdersTotal()-1; cnt >= 0; cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderMagicNumber() == MagicNo)
      {
         if (OrderType() == OP_BUY && OrderSymbol()==Symbol()) OrderCloseReliable(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5);
         else if (OrderType() == OP_SELL && OrderSymbol() == Symbol())OrderCloseReliable(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5);
      } 
   }
  } 
}

bool ModifySelectedOrder(int type, double tp)
{
   bool ok =OrderModifyReliable(OrderTicket(), OrderOpenPrice(), 0, tp, 0);
   if (!ok) 
   {
      int err = GetLastError();
   }
}

double Punto(string symbol) {
	if (StringFind(symbol,"JPY") >=0) {
		return(0.01);
	} else {
		return(0.0001);
	}
}
double	SPREAD() {
	double this = (Ask - Bid) / Punto(Symbol());
	return(this);
}




void ManageOrders()
  {
  
    CountOrders();
    


          double OrderGap=10;
          double Lots=0;

//   if(!SellOnly)
//      {
         if (numBuy == 0 && numSell ==0 && iClose(Symbol(),PERIOD_D1,1)> iClose(Symbol(),PERIOD_D1,2))
         {

               RefreshRates();
               PlaceSingleOrder(Symbol(), OP_BUY, BaseLot, Ask);
         }
      
      
      
         if (numBuy > 0 && numSell==0 && Ask <= (lowestBuyPrice-OrderGap*pt) && numBuy <MaxLevel)
         {

               RefreshRates();
              // SetStopLoss(OP_SELL);
             //  if (numBuy <=5) PlaceSingleOrder(Symbol(), OP_SELL, Lots, Bid);
             //  if (numBuy >5)  PlaceSingleOrder(Symbol(), OP_SELL, 2*BaseLot, Bid);
               PlaceSingleOrder(Symbol(), OP_BUY, BaseLot, Ask);
         }


            
 // double lot   }
 
          if (numBuy == 0 && numSell ==3 && Ask>=(highestSellPrice + OrderGap*pt))
         {

               RefreshRates();
               Lots=2*maxSellLots;
               if(2*maxSellLots>maxLot) Lots=maxLot;
               PlaceSingleOrder(Symbol(), OP_BUY, Lots, Ask);
         }
      
      
      
         if (numBuy > 0 && numSell==3 && Ask <= (lowestBuyPrice-OrderGap*pt) && numBuy <MaxLevel)
         {

               RefreshRates();
              // SetStopLoss(OP_SELL);
             //  if (numBuy <=5) PlaceSingleOrder(Symbol(), OP_SELL, Lots, Bid);
             //  if (numBuy >5)  PlaceSingleOrder(Symbol(), OP_SELL, 2*BaseLot, Bid);
                Lots=2*maxSellLots;
                if(2*maxSellLots>maxLot) Lots=maxLot;
               PlaceSingleOrder(Symbol(), OP_BUY, Lots, Ask);
         }


 
          CountOrders();
    


        if (numBuy == 0 && numSell ==0 && iClose(Symbol(),PERIOD_D1,1)<= iClose(Symbol(),PERIOD_D1,2))
         {

               RefreshRates();
               PlaceSingleOrder(Symbol(), OP_SELL, BaseLot, Bid);
             //  RefreshRates();
            //   PlaceSingleOrder(HedgingPair, OP_BUY, Lots, MarketInfo(HedgingPair, MODE_BID));

         }
        
        if (numSell > 0 && Bid >= (highestSellPrice+OrderGap*pt ) && numBuy==0 && numSell <MaxLevel)
         {

      
               RefreshRates();
              // SetStopLoss(OP_BUY);
             //  if(numSell <=5) PlaceSingleOrder(Symbol(), OP_BUY, Lots, Ask);
             //  if(numSell >5) PlaceSingleOrder(Symbol(), OP_BUY, 2*BaseLot, Ask);
               PlaceSingleOrder(Symbol(), OP_SELL, BaseLot, Bid);
         }

   
 
            
  // double lot
  
          if (numBuy == 3 && numSell ==0 && Bid <=(lowestBuyPrice - OrderGap*pt))
         {

               RefreshRates();
                Lots=2*maxBuyLots;
                  if(2*maxBuyLots>maxLot) Lots=maxLot;
               PlaceSingleOrder(Symbol(), OP_SELL, Lots, Bid);
             //  RefreshRates();
            //   PlaceSingleOrder(HedgingPair, OP_BUY, Lots, MarketInfo(HedgingPair, MODE_BID));

         }
        
        if (numSell > 0 && Bid >= (highestSellPrice+OrderGap*pt ) && numBuy==3 && numSell <MaxLevel)
         {

      
               RefreshRates();
              // SetStopLoss(OP_BUY);
             //  if(numSell <=5) PlaceSingleOrder(Symbol(), OP_BUY, Lots, Ask);
             //  if(numSell >5) PlaceSingleOrder(Symbol(), OP_BUY, 2*BaseLot, Ask);
             Lots=2*maxBuyLots;
                  if(2*maxBuyLots>maxLot) Lots=maxLot;
               PlaceSingleOrder(Symbol(), OP_SELL,Lots, Bid);
         }

   


   
  }   
  
  


string CheckReport () {
	static string	ProfitReport = "";
	static int	TimeToReport = 0;
	static int	TradeCounter = 0;
	#define Daily		0
	#define Weekly		1
	#define	Monthly		2
	#define	All		3

	if (TradeCounter != HistoryTotal()) {
		TradeCounter = HistoryTotal();
		TimeToReport = 0;
	}

	if (TimeLocal() > TimeToReport) {
		TimeToReport = TimeLocal() + 300;
		double	Profit[10], Lots[10], Count[10];
		ArrayInitialize(Profit,0);
		ArrayInitialize(Lots,0.000001);
		ArrayInitialize(Count,0.000001);

		int Today     = TimeCurrent() - (TimeCurrent() % 86400);
		int ThisWeek  = Today - TimeDayOfWeek(Today)*86400;
		int ThisMonth = TimeMonth(TimeCurrent());
		for (int i = 0; i < HistoryTotal(); i++) {
			if ( OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) && OrderSymbol()==Symbol()  && OrderCloseTime() > 0 ) {
				Count[All]	+= 1;
				Profit[All]	+= OrderProfit() + OrderSwap();
				Lots[All]	+= OrderLots();
				if (OrderCloseTime() >= Today) {
					Count[Daily]	+= 1;
					Profit[Daily]	+= OrderProfit() + OrderSwap();
					Lots[Daily]	+= OrderLots();
				}
				if (OrderCloseTime() >= ThisWeek) {
					Count[Weekly]	+= 1;
					Profit[Weekly]	+= OrderProfit() + OrderSwap();
					Lots[Weekly]	+= OrderLots();
				}
				if (TimeMonth(OrderCloseTime()) == ThisMonth) {
					Count[Monthly]	+= 1;
					Profit[Monthly]	+= OrderProfit() + OrderSwap();
					Lots[Monthly]	+= OrderLots();
				}
			}
		}
		double OpenProfit=totalBuyProfit+totalSellProfit;
		
		ProfitReport = 	"\n\nPROFIT REPORT" +
				"\nToday: $"		 + DoubleToStr(Profit[Daily],2) +
				"\nThis Week: $"	 + DoubleToStr(Profit[Weekly],2) + 
				"\nThis Month: $"	 + DoubleToStr(Profit[Monthly],2) +
				"\nAll Profits: $"	 + DoubleToStr(Profit[All],2) +
				"\nAll Trades: "	 + DoubleToStr(Count[All],0) 	+ "  (Average $"+DoubleToStr(Profit[All]/Count[All],2)+" per trade)"+
				"\nAll Lots: "		 + DoubleToStr(Lots[All],2) 	+ "  (Average $"+DoubleToStr(Profit[All]/Lots[All],2) +" per lot)" ;
	}
	return (ProfitReport);
}