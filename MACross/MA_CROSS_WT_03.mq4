//+------------------------------------------------------------------+
//|                                                  MA_CROSS_WT.mq4 |
//|                               Copyright © 2014, Khalil Abokwaik. |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Khalil Abokwaik"
//--- input parameters
 
input int      Magic_Number              = 40001;
input int      Fast_MA_Period            = 20;    
input int      Slow_MA_Period            = 100;    
input int      Slower_MA_Period          = 600;    
input int      MA_Method                 = 0; //0:Simple, 1:Exponential, 2:Smoothed, 3:Linear_Wighted
input double   Fixed_Lot_Size            = 0.1;    
input double   Lot_as_EQ_Perc            = 0.1;
input int      Max_Open_Orders           = 10;      
input int      SL_Pips                   = 0;
input int      TP_Pips                   = 0;
input int      Common_TP_Price           = 0; // 1:to enable, so all open orders share the same TP Target
input int      Min_Distance_pips         = 30;
input int      Closing_Method            = 0; //0:default when Slow MA crosses Slower MA. 
                                              //1:when Fast MA crossed Slower MA
input int      Entry_Method              = 0; //0:default buying cross ups above Slower MA and selling cross downs Below Slower MA
                                              //1:buying cross downs above Slower MA and selling cross ups below Slower MA
int ord_arr[100];

double sell_price = 0,buy_price  = 0,stop_loss=0,profit_target=0;
bool OrderSelected=false,OrderDeleted=false;
int NewOrder=0;
int oper_max_tries = 100,tries=0;
int operation_mode = -1; // -1:stand by, 0:Long, 1:Short
double fast_ma=0,slow_ma=0,slower_ma=0,prev_fast_ma=0,prev_slow_ma=0,prev_slower_ma=0;
double sl_price=0,tp_price=0,Lot_Size=0;
//-----------

int market_buy_order()
{    double rem=0;
   NewOrder=0;
   tries=0;
      if(SL_Pips==0) sl_price = 0;
      else sl_price=Bid-SL_Pips*Point;
   
   if(total_orders()==0 || Common_TP_Price==0)
   {
      if(TP_Pips==0) tp_price = 0;
      else tp_price=Ask+TP_Pips*Point;
   }
   if(Fixed_Lot_Size==0 && Lot_as_EQ_Perc>0)
   {
      Lot_Size=MathMin(NormalizeDouble(AccountEquity()/MarketInfo(Symbol(),MODE_MARGINREQUIRED)*Lot_as_EQ_Perc,2),MarketInfo(Symbol(),MODE_MAXLOT));
      rem=Lot_Size/(MarketInfo(Symbol(),MODE_MINLOT));
      Lot_Size=MathFloor(rem)*MarketInfo(Symbol(),MODE_MINLOT);
   }
   else
   { 
      if (Fixed_Lot_Size==0) Lot_Size=0.1;
      else Lot_Size=Fixed_Lot_Size;
   }
   while(NewOrder<=0 && tries< oper_max_tries)
   {
      NewOrder=OrderSend(Symbol(),OP_BUY,Lot_Size,Ask,5,
                         sl_price,
                         tp_price,
                         "MACROSSWT",Magic_Number,0,Blue);            
      tries=tries+1;
   }
   return(NewOrder);
}
int market_sell_order()
{
   double rem=0;
   NewOrder=0;
   tries=0;
      if(SL_Pips==0) sl_price = 0;
      else sl_price=Ask+SL_Pips*Point;

   if(total_orders()==0 || Common_TP_Price==0)
   {   
      if(TP_Pips==0) tp_price = 0;
      else tp_price=Bid-TP_Pips*Point;
   }
   if(Fixed_Lot_Size==0 && Lot_as_EQ_Perc>0)
   {
      Lot_Size=MathMin(NormalizeDouble(AccountEquity()/MarketInfo(Symbol(),MODE_MARGINREQUIRED)*Lot_as_EQ_Perc,2),MarketInfo(Symbol(),MODE_MAXLOT));
      rem=Lot_Size/(MarketInfo(Symbol(),MODE_MINLOT));
      Lot_Size=MathFloor(rem)*MarketInfo(Symbol(),MODE_MINLOT);
      
   }
   else    Lot_Size=0.1;
   
   while(NewOrder<=0 && tries< oper_max_tries)
   {
      NewOrder=OrderSend(Symbol(),OP_SELL,Lot_Size,Bid,5,
                         sl_price,
                         tp_price,
                         "MACROSSWT",Magic_Number,0,Red);            
      tries=tries+1;
   }
   return(NewOrder);
}



int total_orders()
{ int tot_orders=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()==Magic_Number 
         && OrderSymbol()==Symbol()
         && (OrderType()==OP_BUY || OrderType()==OP_SELL)
        ) tot_orders=tot_orders+1;
   }
   return(tot_orders);
}

double last_buy_price()
{ double ord_price=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()==Magic_Number 
         && OrderSymbol()==Symbol()
         && OrderType()==OP_BUY
         && OrderOpenPrice()>ord_price
        ) 
        ord_price = OrderOpenPrice();
   }
   
   return(ord_price+Min_Distance_pips*Point);
   
}
double last_sell_price()
{ double ord_price=999999;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()==Magic_Number 
         && OrderSymbol()==Symbol()
         && OrderType()==OP_SELL
         && OrderOpenPrice()<ord_price
        ) 
        ord_price = OrderOpenPrice();
   }
   return(ord_price-Min_Distance_pips*Point);
}
int last_order_type()
{ int ord_type=-1;
  int tkt_num=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()==Magic_Number 
         && OrderSymbol()==Symbol()
         && OrderTicket()>tkt_num
        ) 
        {
            ord_type = OrderType();
            tkt_num=OrderTicket();
        }
   }
   return(ord_type);
}
void close_sell_orders()
{ int k=-1;
   bool x= false;
   for(int j=0;j<100;j++) ord_arr[j]=0;
   
   int ot = OrdersTotal();
   for(j=0;j<ot;j++)
   {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic_Number)
      {   
         if(OrderType()==OP_SELL)   
         {  k = k + 1; 
            ord_arr[k]=OrderTicket();
         }
      }     
    }
    for(j=0;j<=k;j++)
    {  OrderDeleted=false;
       tries=0;
       while(!OrderDeleted && tries<oper_max_tries)
            {
               x=OrderSelect(ord_arr[j],SELECT_BY_TICKET,MODE_TRADES);
               OrderDeleted=OrderClose(ord_arr[j],OrderLots(),Ask,100,Red);
               tries=tries+1;
            }
    }
}

void close_buy_orders()
{ int k=-1;
   bool x= false;
   for(int j=0;j<100;j++) ord_arr[j]=0;
   
   int ot = OrdersTotal();
   for(j=0;j<ot;j++)
   {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic_Number)
      {   
         if(OrderType()==OP_BUY)   
         {  k = k + 1; 
            ord_arr[k]=OrderTicket();
         }
      }     
    }
    for(j=0;j<=k;j++)
    {  OrderDeleted=false;
       tries=0;
       while(!OrderDeleted && tries<oper_max_tries)
            {
               x=OrderSelect(ord_arr[j],SELECT_BY_TICKET,MODE_TRADES);
               OrderDeleted=OrderClose(ord_arr[j],OrderLots(),Bid,100,Red);
               tries=tries+1;
            }
    }
}

void init()
{
}
int start()
{  
   prev_fast_ma=iMA(Symbol(),0,Fast_MA_Period,0,MA_Method,PRICE_CLOSE,2);
   prev_slow_ma=iMA(Symbol(),0,Slow_MA_Period,0,MA_Method,PRICE_CLOSE,2);
   prev_slower_ma=iMA(Symbol(),0,Slower_MA_Period,0,MA_Method,PRICE_CLOSE,2);

   fast_ma=iMA(Symbol(),0,Fast_MA_Period,0,MA_Method,PRICE_CLOSE,1);
   slow_ma=iMA(Symbol(),0,Slow_MA_Period,0,MA_Method,PRICE_CLOSE,1);
   slower_ma=iMA(Symbol(),0,Slower_MA_Period,0,MA_Method,PRICE_CLOSE,1);
   //Check for Closing positions
   if(Closing_Method==0)
   {
      if(last_order_type()==0 && slow_ma<slower_ma && total_orders()>0) close_buy_orders();
      if(last_order_type()==1 && slow_ma>slower_ma && total_orders()>0) close_sell_orders();
   }
   if(Closing_Method==1)
   {
      if(last_order_type()==0 && fast_ma<slower_ma && total_orders()>0) close_buy_orders();
      if(last_order_type()==1 && fast_ma>slower_ma && total_orders()>0) close_sell_orders();
   }   
   //Decide on Trade Direction
   if (fast_ma>slower_ma && slow_ma>slower_ma) operation_mode=0; //Long
   else 
   {
      if (fast_ma<slower_ma && slow_ma<slower_ma) operation_mode=1; //Short
      else operation_mode=-1; //neutral
   }  
   //Entry
   if(Entry_Method==0)
   {
      if(operation_mode==0)
      {  
         if(fast_ma>slow_ma && prev_fast_ma<prev_slow_ma && Ask > last_buy_price() && total_orders()<Max_Open_Orders)
         {
            market_buy_order();
         }
      }
      if(operation_mode==1)
      {
         if(fast_ma<slow_ma && prev_fast_ma>prev_slow_ma && Bid < last_sell_price() && total_orders()<Max_Open_Orders)
         {
            market_sell_order();
         }
   
      }
    }
   if(Entry_Method==1)
   {
      if(operation_mode==0)
      {  
         if(fast_ma<slow_ma && prev_fast_ma>prev_slow_ma && Ask > last_buy_price() && total_orders()<Max_Open_Orders)
         {
            market_buy_order();
         }
      }
      if(operation_mode==1)
      {
         if(fast_ma>slow_ma && prev_fast_ma<prev_slow_ma && Bid < last_sell_price() && total_orders()<Max_Open_Orders)
         {
            market_sell_order();
         }
   
      }
    }

   return(1);
}

