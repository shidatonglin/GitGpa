//+------------------------------------------------------------------+
//|                                          100DollarMartingale.mq4 |
//|                                             Komgrit Sungkhaphong |
//|                               http://iamforextrader.blogspot.com |
//+------------------------------------------------------------------+
//https://www.forexfactory.com/showthread.php?t=458279
#property copyright "Komgrit Sungkhaphong"
#property link      "http://iamforextrader.blogspot.com"

#define EANAME "EA6000-M"

extern int Magic=65494321;
extern double  startlot=0.1;
extern string  __trail="----Trailing----";
extern int     trigger1=150;
extern int     move1=30;
extern int     trigger2=150;
extern int     move2=30;


#include <Func1.mqh>

int LotDecimal
      ,multi
      ;
int m1,m15,m30,h1,h4,d1,w1,mn;

double lowestbuy,highestsell;
int countbuy,countsell;
double NextHigherSell,NextLowerBuy;
   double average.buy;
   double average.sell;
int EventCode;
double StopLossBuy, StopLossSell;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
      switch(MarketInfo(Symbol(), MODE_LOTSTEP))
   {
      case 0.01 : LotDecimal = 2; break;
      case  0.1 : LotDecimal = 1; break;
      case    1 : LotDecimal = 0; break;
   }
   switch(Digits)
   {
     case 5:   multi=100000;    break;
     case 3:   multi=1000;      break;
     case 2:   multi=100;      break;
   }
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
//----
   double LotBuy, LotSell;
   string LBuy,LSell;
   LotBuy=startlot;
   LotSell=startlot;
   
   LotBuy=startlot*MathPow(1.4,CountOrder.Buy());
   LotSell=startlot*MathPow(1.4,CountOrder.Sell());

   double ATR=iATR(NULL,0,14,0);
   int ATRRound;
   ATRRound=NormalizeDouble(2*ATR*multi,0);
   double MFI=iMFI(NULL,0,3,0);
   double MFI1=iMFI(NULL,0,5,1);
   double MFID=iMFI(NULL,PERIOD_D1,3,0);
   double ema144=iMA(NULL,0,144,0,MODE_EMA,PRICE_CLOSE,0);
   double ema50=iMA(NULL,0,50,0,MODE_EMA,PRICE_CLOSE,0);
   double ema20=iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,0);
   double ema6D=iMA(NULL,PERIOD_D1,6,0,MODE_EMA,PRICE_CLOSE,0);
   double ema12D=iMA(NULL,PERIOD_D1,12,0,MODE_EMA,PRICE_CLOSE,0);
   double ema200D=iMA(NULL,PERIOD_D1,200,0,MODE_EMA,PRICE_CLOSE,0);
   
   
   
  
   /*
   if(countbuy!=CountOrder.Buy())
   {      
      
      lowestbuy=Find.Price.Lowest(OP_BUY);
      NextLowerBuy=lowestbuy-200*Point;
      //NextLowerBuy=lowestbuy-ATR;
      LBuy="LB"+CountOrder.Buy();
      
   }
   
   if(countsell!=CountOrder.Sell())
   {
     
     highestsell=Find.Price.Highest(OP_SELL);
     NextHigherSell=highestsell+200*Point;
     //NextHigherSell=highestsell+ATR;
     LSell="LS"+CountOrder.Sell();
     
   }
   */
   if(CountOrder.Buy()==0)
   {
      StopLossBuy=0;
   }
   if(CountOrder.Sell()==0)
   {
      StopLossSell=500000;
   }
   
   int tb=0;
   int ts=0;
   
   if(MFI<=0      
      && MFID>50 
      && CountOrder.Buy()==0 
      //&& Bid>ema6D
      //&& Bid>ema12D
      //&& ema12D>ema200D 
      //&& Bid>ema144 
      && Bid>ema50
      && Bid>ema20 
      //&&ema20>ema50
      && Bid>Low[iLowest(NULL,0,MODE_LOW,3,0)]+100*Point
      )   
      {
         tb=SendOrder.Buy(LotBuy,Bid-5000*Point,0,EANAME); 
         NextLowerBuy=OffSetPrice(tb,200);
         Print("next buy"+DoubleToStr(NextLowerBuy,Digits));
         draw_NextLowerBuy(NextLowerBuy);
      }
   
   if(MFI>=100       
      && MFID<50
      && CountOrder.Sell()==0
      //&& Bid<ema6D
      //&& ema12D<ema200D
      //&& Bid<ema12D
      //&& Bid<ema144
      && Bid>ema50
      && Bid<ema20 
      //&&ema20<ema50
      && Bid+100*Point<High[iHighest(NULL,0,MODE_HIGH,3,0)]
      )   
      {
         ts=SendOrder.Sell(LotSell,Ask+5000*Point,0,EANAME);
         NextHigherSell=OffSetPrice(ts,200);   
         Print("next sell"+DoubleToStr(NextHigherSell,Digits));
         draw_NextHigherSell(NextHigherSell);        
      }
   
   
   if(CountOrder.Buy()>=1 && Bid<NextLowerBuy)
   {  
      tb=SendOrder.Buy(LotBuy,0,0,EANAME);
      NextLowerBuy=OffSetPrice(tb,ATRRound);     
                  
      average.buy=Find.BreakEvenPrice(OP_BUY);
      Print("Buy Average Cost:"+DoubleToStr(average.buy,Digits));
      draw_average_cost(average.buy);
      
      Print("next buy"+DoubleToStr(NextLowerBuy,Digits));
      draw_NextLowerBuy(NextLowerBuy);
      
      
   }
   if(CountOrder.Sell()>=1 && Bid>NextHigherSell)
   {
      ts=SendOrder.Sell(LotSell,0,0,EANAME);
      NextHigherSell=OffSetPrice(ts,ATRRound);
      
      average.sell=Find.BreakEvenPrice(OP_SELL);
      Print("Sell Average Cost:"+DoubleToStr(average.sell,Digits));
      draw_average_cost(average.sell);
      
      Print("next sell"+DoubleToStr(NextHigherSell,Digits));
      draw_NextHigherSell(NextHigherSell);
   }
   
   
   if(iBars(NULL,0)>h1)
   {
      //SendOrder.Buy(Lot);
      //SendOrder.Sell(Lot,Bid+200*Point);

      

      
      h1=iBars(NULL,0);
   }
   
   
   
   if(average.buy!=Find.BreakEvenPrice(OP_BUY))
   {

   }   
   if(average.sell!=Find.BreakEvenPrice(OP_SELL))
   {

   }   
   
   

   
   if(CountOrder.Buy()==1)
   {
      EventCode=1000;
      //Print(EventCode+":trailing buy");
      TrailingAllBuy2(trigger1,move1,trigger1,move1);
      
   }
   if(CountOrder.Sell()==1)
   {     
      EventCode=1100; 
      //Print(EventCode+":trailing sell");
      TrailingAllSell2(trigger1,move1,trigger1,move1);
   }  
   
   
   if(CountOrder.Buy()>=2)
   {
      if(StopLossBuy<average.buy)
      {
         if(Bid-average.buy>=trigger1*Point) StopLossBuy=Find.BreakEvenPrice(OP_BUY)+move1*Point;       
      }
      
      if(StopLossBuy>average.buy)
      {
         if(Bid-StopLossBuy>=trigger2*Point) StopLossBuy=StopLossBuy+move2*Point;      
      }
      
      if(Bid<StopLossBuy)  Close.All.Buy();
      draw_stoploss_buy(StopLossBuy);      
   }
   
   if(CountOrder.Sell()>=2)
   {
      if(StopLossSell>average.sell)
      {
         if(average.sell-Ask>=trigger1*Point) StopLossSell=Find.BreakEvenPrice(OP_SELL)-move1*Point;
      }
      
      if(StopLossSell<average.sell)
      {
         if(StopLossSell-Ask>=trigger2*Point) StopLossSell=StopLossSell-move2*Point;      
      }   
      
      if(Ask>StopLossSell)  Close.All.Sell();
      draw_stoploss_sell(StopLossSell);
      
   }
   
   
   
   //if(AccountProfit()/AccountBalance()<-0.5){ Close.All.Sell(); Close.All.Buy();}
   
   

//----
   return(0);
  }
//+------------------------------------------------------------------+

void draw_average_cost(double price)
{
   ObjectDelete("draw_average_cost");
   ObjectCreate("draw_average_cost", OBJ_HLINE , 0,Time[0], price);
   ObjectSet("draw_average_cost", OBJPROP_STYLE, STYLE_DASH);
   ObjectSet("draw_average_cost", OBJPROP_COLOR, Red);
   ObjectSet("draw_average_cost", OBJPROP_WIDTH, 1);
   WindowRedraw();
}

void draw_stoploss_buy(double price)
{
   ObjectDelete("draw_stoploss_buy");
   ObjectCreate("draw_stoploss_buy", OBJ_HLINE , 0,Time[0], price);
   ObjectSet("draw_stoploss_buy", OBJPROP_STYLE, STYLE_DASH);
   ObjectSet("draw_stoploss_buy", OBJPROP_COLOR, Orange);
   ObjectSet("draw_stoploss_buy", OBJPROP_WIDTH, 1);
   WindowRedraw();
}

void draw_stoploss_sell(double price)
{
   ObjectDelete("draw_stoploss_sell");
   ObjectCreate("draw_stoploss_sell", OBJ_HLINE , 0,Time[0], price);
   ObjectSet("draw_stoploss_sell", OBJPROP_STYLE, STYLE_DASH);
   ObjectSet("draw_stoploss_sell", OBJPROP_COLOR, Orange);
   ObjectSet("draw_stoploss_sell", OBJPROP_WIDTH, 1);
   WindowRedraw();
}

void draw_NextLowerBuy(double price)
{
   ObjectDelete("draw_NextLowerBuy");
   ObjectCreate("draw_NextLowerBuy", OBJ_HLINE , 0,Time[0], price);
   ObjectSet("draw_NextLowerBuy", OBJPROP_STYLE, STYLE_DASH);
   ObjectSet("draw_NextLowerBuy", OBJPROP_COLOR, Blue);
   ObjectSet("draw_NextLowerBuy", OBJPROP_WIDTH, 1);
   WindowRedraw();
}

void draw_NextHigherSell(double price)
{
   ObjectDelete("draw_NextHigherSell");
   ObjectCreate("draw_NextHigherSell", OBJ_HLINE , 0,Time[0], price);
   ObjectSet("draw_NextHigherSell", OBJPROP_STYLE, STYLE_DASH);
   ObjectSet("draw_NextHigherSell", OBJPROP_COLOR, Magenta);
   ObjectSet("draw_NextHigherSell", OBJPROP_WIDTH, 1);
   WindowRedraw();
}

void Modify.All.Stoploss(int type, double price)
{
   price=NormalizeDouble(price,Digits);
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         bool modOK=false;
         if(OrderMagicNumber()==Magic 
            && OrderType()==type 
            && OrderSymbol()==Symbol()
            && OrderCloseTime()==0)
            {

                  modOK=OrderModify(OrderTicket(),OrderOpenPrice(),price,OrderTakeProfit(),0,CLR_NONE);
                  if(modOK)   Print("Modify SL: #"+OrderTicket()+"@"+DoubleToStr(price,Digits));
                  else Print("Fail to modify SL #"+OrderTicket()+" to SL @"+DoubleToStr(price,Digits));

            }
      }
   
   }
   return;
}

double OffSetPrice(int ticket, int offsetpoint=200)
{
   double price;
   if(OrderSelect(ticket,SELECT_BY_TICKET)==true)
   {
         if(OrderMagicNumber()==Magic             
            && OrderSymbol()==Symbol()
            && OrderCloseTime()==0)
            {
               if(OrderType()==OP_BUY)
               {
                  price=OrderOpenPrice()-offsetpoint*Point;
               }
               
               if(OrderType()==OP_SELL)
               {
                  price=OrderOpenPrice()+offsetpoint*Point;
               }
            }
   }
   price=NormalizeDouble(price,Digits);
   return(price);

}