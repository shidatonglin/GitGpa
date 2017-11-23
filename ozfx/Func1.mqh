//+------------------------------------------------------------------+
//|                                                         Func1.mq4 |
//|                                             Komgrit Sungkhaphong |
//|                               http://iamforextrader.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Komgrit Sungkhaphong"
#property link      "http://iamforextrader.blogspot.com"

///////////////////////////////////////////////////////////////////
//--------------------------FUNC1--------------------------------//
///////////////////////////////////////////////////////////////////
int SendOrder.SellLimit
   (double LotSize,
   double Price,
   double StopPrice=0,
   double TargetPrice=0,
   datetime Expiration=0,
   string Comment_Text="")
   {
      int ticket;
      if(Price < Bid+StopPoint()) Price=Bid+StopPoint();
      ticket=SendOrder(OP_SELLLIMIT,Magic,LotSize,Price,3,StopPrice,TargetPrice,Expiration,Comment_Text,Violet);
      return (ticket);
   }
int SendOrder.SellStop
   (double LotSize,
   double Price,
   double StopPrice=0,
   double TargetPrice=0,
   datetime Expiration=0,
   string Comment_Text="")
   {
      int ticket;
      if(Price > Bid-StopPoint()) Price=Bid-StopPoint();
      ticket=SendOrder(OP_SELLSTOP,Magic,LotSize,Price,3,StopPrice,TargetPrice,Expiration,Comment_Text,Violet);
      return (ticket);
   }
int SendOrder.BuyLimit
   (double LotSize,
   double Price,
   double StopPrice=0,
   double TargetPrice=0,
   datetime Expiration=0,
   string Comment_Text="")
   {
      int ticket;
      if(Price > Ask-StopPoint()) Price=Ask-StopPoint();
      ticket=SendOrder(OP_BUYLIMIT,Magic,LotSize,Price,3,StopPrice,TargetPrice,Expiration,Comment_Text,Aqua);
      return (ticket);
   }
int SendOrder.BuyStop
   (double LotSize,
   double Price,
   double StopPrice=0,
   double TargetPrice=0,
   datetime Expiration=0,
   string Comment_Text="")
   {
      int ticket;
      if(Price < Ask+StopPoint()) Price=Ask+StopPoint();
      ticket=SendOrder(OP_BUYSTOP,Magic,LotSize,Price,3,StopPrice,TargetPrice,Expiration,Comment_Text,Aqua);      
      return (ticket);      
   }
int SendOrder.Sell(double LotSize, double StopPrice=0, double TargetPrice=0,string Comment_Text="")
   {
      int ticket;
      ticket=SendOrder(OP_SELL,Magic,LotSize,Bid,3,StopPrice,TargetPrice,0,Comment_Text,Purple);
      return (ticket);
   }
int SendOrder.Buy(double LotSize, double StopPrice=0, double TargetPrice=0,string Comment_Text="")
   {
      int ticket;
      ticket=SendOrder(OP_BUY,Magic,LotSize,Ask,3,StopPrice,TargetPrice,0,Comment_Text,Blue);
      return (ticket);
   }
/*
Function: SendOrder(..)
   Require global vairable
   Order_Type
   MN =  Magic Number
   LotSize
   Price 
   Stop
   Target
   Expire
   Comment_text
   
*/
int SendOrder
   (int Order_Type,
   int MN,
   double LotSize, 
   double Price,
   int Slippage=3,  
   double Stop=0, 
   double Target=0, 
   datetime Expire=0, 
   string Comment_Text="",
   color color_order=CLR_NONE)
   {
      int ticket_number;
      //Normalizing numbers
      LotSize=NormalizeLotSize(LotSize);
      Price=NormalizeDouble(Price,Digits);
      Target=NormalizeDouble(Target,Digits);
      Stop=NormalizeDouble(Stop,Digits);
   
         
      //send order command
      ticket_number=OrderSend(Symbol(),Order_Type,LotSize,Price,Slippage,Stop,Target,Comment_Text,MN,0,color_order);
      if(OrderSelect(ticket_number,SELECT_BY_TICKET)==true)
      {
         string objName="OrderText"+ticket_number;
         //string objText=ticket_number+" "+DoubleToStr(Price,Digits);
         //string objText="^^"+DoubleToStr(LotSize,2)+" SL:"+DoubleToStr((Price-Stop)*Multi.Points(),0)+"pts";
         string objText="#"+ticket_number;
         if(!ObjectCreate(objName, OBJ_TEXT, 0, TimeCurrent(), Price-100*Point))
         {
          //Print("error: can't create text_object! code #",GetLastError());
          return(0);
         }
         ObjectSetText(objName, objText, 8, "Courier New", Blue);
         return(ticket_number);  
      }
      else
      {
         return(-1);
         //Print("error: Cannot send order, code:",GetLastError());
      }   
   }

//Function: NormalizeLotSize(lot)
// Returns = NormalizeDouble(lot, ..lot step decimal.. )
double NormalizeLotSize(double LotSize)
   {
      int LotStep;
      switch(MarketInfo(Symbol(), MODE_LOTSTEP))
      {
         case 0.01 : LotStep = 2; break;
         case  0.1 : LotStep = 1; break;
         case    1 : LotStep = 0; break;
      }
      LotSize=NormalizeDouble(LotSize,LotStep);
      return(LotSize);
   }



int Multi.Points()
{
   int multiplier;
   switch(Digits)
   {
     case 5:   multiplier=100000;    break;
     case 3:   multiplier=1000;      break;
     case 2:   multiplier=100;      break;
   }
   return(multiplier);
}

int Multi.Pips()
{
   int multiplier;
   switch(Digits)
   {
     case 5:   multiplier=10000;    break;
     case 3:   multiplier=100;      break;
     case 2:   multiplier=10;      break;
   }
   return(multiplier);
}

double StopPoint()
{
   return(MarketInfo(Symbol(),MODE_STOPLEVEL)*Point);
}


void TrailingBuy(int ticket, int Trigger1=100, int Lock1=30, int Trigger2=100, int Lock2=30)
{
   double newstops;
   if(OrderSelect(ticket,SELECT_BY_TICKET)==true && OrderType()==OP_BUY && OrderCloseTime()==0)
   {
      if(OrderStopLoss()<OrderOpenPrice() || OrderStopLoss()==0)
      {
         RefreshRates();
         newstops=OrderOpenPrice()+Lock1*Point;
         if(Bid-OrderOpenPrice()>=Trigger1*Point && Bid-newstops>=StopPoint())
         {            
            if(newstops>OrderStopLoss())
            OrderModify(OrderTicket(),OrderOpenPrice(),newstops,OrderTakeProfit(),0,CLR_NONE);
            //Print("MODIFY STEP1 BUY : "+OrderTicket());
            
         }      
      }
      
      if(OrderStopLoss()>OrderOpenPrice())
      {
         RefreshRates();
         newstops=OrderStopLoss()+Lock2*Point;
         if(Bid-OrderStopLoss()>=Trigger2*Point && Bid-newstops>=StopPoint())
         {
            if(OrderModify(OrderTicket(),OrderOpenPrice(),newstops,OrderTakeProfit(),0,CLR_NONE)==true)
            {
               //Print("MODIFY STEP2 BUY : "+OrderTicket());
            }
         }      
      }   
   }
   return;
}

void TrailingSell(int ticket, int Trigger1=100, int Lock1=30, int Trigger2=100, int Lock2=30)
{
   double newstops;
   if(OrderSelect(ticket,SELECT_BY_TICKET)==true && OrderType()==OP_SELL && OrderCloseTime()==0)
   {
      if(OrderStopLoss()>OrderOpenPrice()|| OrderStopLoss()==0)
      {
         RefreshRates();
         newstops=OrderOpenPrice()-Lock1*Point;
         if(OrderOpenPrice()-Ask>=Trigger1*Point && newstops-Ask>=StopPoint())
         {            
            if(OrderModify(OrderTicket(),OrderOpenPrice(),newstops,OrderTakeProfit(),0,CLR_NONE)==true)
            {
               //Print("MODIFY STEP1 SELL : "+OrderTicket());
            }
         }      
      }
      
      if(OrderStopLoss()<OrderOpenPrice())
      {
         RefreshRates();
         newstops=OrderStopLoss()-Lock2*Point;
         if(OrderStopLoss()-Ask>=Trigger2*Point && newstops-Ask>=StopPoint())
         {
            if(OrderModify(OrderTicket(),OrderOpenPrice(),newstops,OrderTakeProfit(),0,CLR_NONE)==true)
            {
               //Print("MODIFY STEP2 SELL : "+OrderTicket());
            }
         }      
      }   
   }
   return;
}


void TrailingAllSell(int t1,int t2, int t3, int t4)
{
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         if(OrderMagicNumber()==Magic && OrderType()==OP_SELL && OrderSymbol()==Symbol())
         {
            TrailingSell(OrderTicket(),t1,t2,t3,t4);         
         }
      }
   
   }
   return;
}

void TrailingAllBuy(int t1,int t2, int t3, int t4)
{
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         if(OrderMagicNumber()==Magic && OrderType()==OP_BUY && OrderSymbol()==Symbol())
         {
            TrailingBuy(OrderTicket(),t1,t2,t3,t4);         
         }
      }
   
   }
   return;
}



//------------FUNC----------------------------------

int CountOrder.BuyStop()
{
   return(CountOrder(OP_BUYSTOP));
}
int CountOrder.SellStop()
{
   return(CountOrder(OP_SELLSTOP));
}

int CountOrder.BuyLimit()
{
   return(CountOrder(OP_BUYLIMIT));
}
int CountOrder.SellLimit()
{
   return(CountOrder(OP_SELLLIMIT));
}

int CountOrder.Buy()
{
   return(CountOrder(OP_BUY));
}
int CountOrder.AllBuy()
{
   return(CountOrder.Buy()+CountOrder.BuyStop()+CountOrder.BuyLimit());
}

int CountOrder.PendingBuy()
{
   return(CountOrder.BuyStop()+CountOrder.SellLimit());
}

int CountOrder.PendingSell()
{
   return(CountOrder.SellStop()+CountOrder.SellLimit());
}

int CountOrder.AllSell()
{
   return(CountOrder.Sell()+CountOrder.BuyLimit()+CountOrder.SellLimit());
}

int CountOrder.Sell()
{
   return(CountOrder(OP_SELL));
}

//Function: CountOrder( type of order )
int CountOrder(int type)
{
   int count=0;
   for(int i=0; i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         if(OrderMagicNumber()==Magic &&
               OrderSymbol()==Symbol() &&
               OrderType()==type)
               {
                  count++;
               }
      }
   }
   return(count);
}

//function: CountOrder.All()
//Returns number of total order by specific Magic number use in the EA
int CountOrder.All()
{
   int count=0;
   for(int i=0; i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         if(OrderMagicNumber()==Magic &&
               OrderSymbol()==Symbol())
               {
                  count++;
               }
      }
   }
   return(count);
}

int Close.All(int type)
{
   int closecount;
   for(int i=0; i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         if(OrderMagicNumber()==Magic &&
               OrderSymbol()==Symbol() &&
               OrderType()==type)
               {
                  bool closeok;
                  closeok=OrderClose(OrderTicket(),OrderLots(),Bid,5,CLR_NONE);
                  if(closeok) closecount++;
               }
      }
   }
   return(closecount);
}

int Close.All.Buy()
{
   return(Close.All(OP_BUY));
}

int Close.All.Sell()
{
   return(Close.All(OP_SELL));
}

void Delete.Pending(int type)
{
   for(int i=0; i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         if(OrderMagicNumber()==Magic &&
               OrderSymbol()==Symbol() &&
               OrderType()==type)
               {
                  OrderDelete(OrderTicket());
               }
      }
   }
   return;
}

void Delete.PendingAll()
{
   Delete.PendingBuy();
   Delete.PendingSell();
   return;
}

void Delete.PendingBuy()
{
   Delete.Pending(OP_BUYLIMIT);
   Delete.Pending(OP_BUYSTOP);
   return;
}

void Delete.PendingSell()
{
   Delete.Pending(OP_SELLLIMIT);
   Delete.Pending(OP_SELLSTOP);
   return;
}

//return
// int ticket number
int Find.Order(int type)
{
   for(int i=0; i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         if(OrderMagicNumber()==Magic &&
               OrderSymbol()==Symbol() &&
               OrderType()==type &&
               OrderCloseTime()==0)
               {
                  return(OrderTicket());                  
               }
      }
   }
}

int Find.OrderBuy()
{
   return(Find.Order(OP_BUY));
}

int Find.OrderSell()
{
   return(Find.Order(OP_SELL));
}

//Function
// find latest ticket live order buy/sell
int Find.LastOrder(int type)
{
   int last_ticket=0;
   for(int i=0; i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         if(OrderMagicNumber()==Magic &&
               OrderSymbol()==Symbol() &&
               OrderType()==type &&
               OrderCloseTime()==0)
               {
                  if(OrderTicket()>last_ticket) last_ticket=OrderTicket();
               }
      }
   }
   return(last_ticket);
}
int Find.LastOrder.Buy()
{
   return(Find.LastOrder(OP_BUY));
}
int Find.LastOrder.Sell()
{
   return(Find.LastOrder(OP_SELL));
}

double Find.BreakEvenPrice(int type)
{
   double Sum.PriceByLots=0;
   double Sum.Lots=0;
   double BreakEvenPrice=0;
   for(int i=0; i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         if(OrderMagicNumber()==Magic &&
               OrderSymbol()==Symbol() &&
               OrderType()==type &&
               OrderCloseTime()==0)
               {
                  Sum.Lots=Sum.Lots+OrderLots();
                  Sum.PriceByLots=Sum.PriceByLots+(OrderOpenPrice()*OrderLots());                  
               }
      }
   }
   if(Sum.Lots==0)
   {
      return(-1);
      //Print("BREAKEVEN::error Sum.Lots=0");
   }
   else
   {
      BreakEvenPrice=Sum.PriceByLots/Sum.Lots;
      BreakEvenPrice=NormalizeDouble(BreakEvenPrice,Digits);
   }
   return(BreakEvenPrice);
}

double Get.OpenPrice (int ticket)
{
   if(OrderSelect(ticket,SELECT_BY_TICKET)==true)
   {
      return(OrderOpenPrice());
   }
   else   return(-1);
}

datetime Get.OpenTime (int ticket)
{
   if(OrderSelect(ticket,SELECT_BY_TICKET)==true)
   {
      return(OrderOpenTime());
   }
   else   return(-1);
}


//find pending order in certain price range
int Find.PendingOrder(int type, double pricehi, double pricelow)
{   
   int foundticket;
   for(int i=0; i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         if(OrderMagicNumber()==Magic &&
               OrderSymbol()==Symbol() &&
               OrderType()==type &&
               OrderCloseTime()==0)
               {
                  if(OrderOpenPrice()<pricehi && OrderOpenPrice()>pricelow)
                  {
                     foundticket=OrderTicket();                     
                  }                
               }
      }
   }
   return(foundticket);
}
void TrailingBuy2(int ticket, int Trigger1=100, int Lock1=30, int Trigger2=100, int Lock2=30)
{
   double newstops;
   if(OrderSelect(ticket,SELECT_BY_TICKET)==true && OrderType()==OP_BUY && OrderCloseTime()==0)
   {
      if(OrderStopLoss()<OrderOpenPrice()|| OrderStopLoss()==0)
      {
         RefreshRates();
         newstops=OrderOpenPrice()+Lock1*Point;
         if(Close[1]-OrderOpenPrice()>=Trigger1*Point && Bid-newstops>=StopPoint())
         {            
            if(newstops>OrderStopLoss())
            OrderModify(OrderTicket(),OrderOpenPrice(),newstops,OrderTakeProfit(),0,CLR_NONE);
            //Print("MODIFY STEP1 BUY : "+OrderTicket());
            
         }      
      }
      
      if(OrderStopLoss()>OrderOpenPrice())
      {
         RefreshRates();
         newstops=OrderStopLoss()+Lock2*Point;
         if(Bid-OrderStopLoss()>=Trigger2*Point && Bid-newstops>=StopPoint())
         {
            if(OrderModify(OrderTicket(),OrderOpenPrice(),newstops,OrderTakeProfit(),0,CLR_NONE)==true)
            {
               //Print("MODIFY STEP2 BUY : "+OrderTicket());
            }
         }      
      }   
   }
   return;
}

void TrailingSell2(int ticket, int Trigger1=100, int Lock1=30, int Trigger2=100, int Lock2=30)
{
   double newstops;
   if(OrderSelect(ticket,SELECT_BY_TICKET)==true && OrderType()==OP_SELL && OrderCloseTime()==0)
   {
      if(OrderStopLoss()>OrderOpenPrice() || OrderStopLoss()==0)
      {
         RefreshRates();
         newstops=OrderOpenPrice()-Lock1*Point;
         if(OrderOpenPrice()-Close[1]>=Trigger1*Point && newstops-Ask>=StopPoint())
         {            
            if(OrderModify(OrderTicket(),OrderOpenPrice(),newstops,OrderTakeProfit(),0,CLR_NONE)==true)
            {
               //Print("MODIFY STEP1 SELL : "+OrderTicket());
            }
         }      
      }
      
      if(OrderStopLoss()<OrderOpenPrice())
      {
         RefreshRates();
         newstops=OrderStopLoss()-Lock2*Point;
         if(OrderStopLoss()-Ask>=Trigger2*Point && newstops-Ask>=StopPoint())
         {
            if(OrderModify(OrderTicket(),OrderOpenPrice(),newstops,OrderTakeProfit(),0,CLR_NONE)==true)
            {
               //Print("MODIFY STEP2 SELL : "+OrderTicket());
            }
         }      
      }   
   }
   return;
}

void TrailingAllSell2(int t1,int t2, int t3, int t4)
{
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         if(OrderMagicNumber()==Magic && OrderType()==OP_SELL && OrderSymbol()==Symbol())
         {
            //Print("Start trailing sell order #"+OrderTicket());
            TrailingSell2(OrderTicket(),t1,t2,t3,t4);         
         }
      }
   
   }
   return;
}

void TrailingAllBuy2(int t1,int t2, int t3, int t4)
{
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         if(OrderMagicNumber()==Magic && OrderType()==OP_BUY && OrderSymbol()==Symbol())
         {
            //Print("Start trailing buy order #"+OrderTicket());
            TrailingBuy2(OrderTicket(),t1,t2,t3,t4);         
         }
      }
   
   }
   return;
}

double Find.Price.Lowest(int type)
{
   int last_ticket=0;
   double Price.Lowest=0;
   for(int i=0; i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         if(OrderMagicNumber()==Magic &&
               OrderSymbol()==Symbol() &&
               OrderType()==type &&
               OrderCloseTime()==0)
               {
                  if(OrderTicket()>last_ticket) last_ticket=OrderTicket();
                  if(Price.Lowest==0)  Price.Lowest=OrderOpenPrice();
                  else if(Price.Lowest>0)
                  {
                     if(OrderOpenPrice()<Price.Lowest)   Price.Lowest=OrderOpenPrice();
                  }
               }
      }
   }
   return(Price.Lowest);
}

double Find.Price.Highest(int type)
{
   int last_ticket=0;
   double Price.Highest=0;
   for(int i=0; i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         if(OrderMagicNumber()==Magic &&
               OrderSymbol()==Symbol() &&
               OrderType()==type &&
               OrderCloseTime()==0)
               {
                  if(OrderTicket()>last_ticket) last_ticket=OrderTicket();
                  if(Price.Highest==0)  Price.Highest=OrderOpenPrice();
                  else if(Price.Highest>0)
                  {
                     if(OrderOpenPrice()>Price.Highest)   Price.Highest=OrderOpenPrice();
                  }
               }
      }
   }
   return(Price.Highest);
}
//CountProfit()
//return profit (-loss) in dollars
double CountProfit(int type)
{
   double profit;
   for(int i=0; i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         if(OrderMagicNumber()==Magic &&
               OrderSymbol()==Symbol() &&
               OrderType()==type &&
               OrderCloseTime()==0)
               {
                  profit=profit+OrderProfit();
               }
      }
   }         
   return(profit);   
}

double CountProfit.Percent(int type)
{
   double profit;
   double profitpercent;
   profit=CountProfit(type);
   profitpercent=profit/AccountBalance()*100;
   profitpercent=NormalizeDouble(profitpercent,2);
   return(profitpercent);
}

double CountLots(int type)
{
   double lots;
   for(int i=0; i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         if(OrderMagicNumber()==Magic &&
               OrderSymbol()==Symbol() &&
               OrderType()==type &&
               OrderCloseTime()==0)
               {
                  lots=lots+OrderLots();
               }
      }
   }         
   return(lots);  
}

bool LiveOrderCheck(int ticket)
{
   if(OrderSelect(ticket,SELECT_BY_TICKET)==true)
   {
      if(   OrderMagicNumber()==Magic &&
            OrderSymbol()==Symbol() &&            
            OrderCloseTime()==0)
         {
            return(true);
         }
         else return(false);
   }
}