//+------------------------------------------------------------------+
//|                                               LadderSystemEA.mq4 |
//|                               Copyright © 2013, Khalil Abokwaik. |
//+------------------------------------------------------------------+

#property copyright "Copyright 2014, Khalil Abokwaik"
//--- input parameters
 

input int      Magic_Number                = 40005;
input int      Ladder_Step_Pips            = 70;    // Ladder Step Size.
input int      Unified_Stop_Pips           = 140;    // Stop Loss PIPS
input double   Fixed_Lot_Size              = 0.1;    // Starting Lot Size
input double   Lot_as_EQ_Perc              = 0.0;
input int      Max_Open_Orders             = 15;      // Maximum Orders (Ladder Steps)

int ord_arr[100];

double sell_price = 0,buy_price  = 0,stop_loss=0,profit_target=0,Lot_Size=0;
bool OrderSelected=false,OrderDeleted=false;
int NewOrder=0;
int oper_max_tries = 3,tries=0;
//-----------
void delete_pending_order()
{ int k=-1;
   for(int j=0;j<100;j++) ord_arr[j]=0;
   
   int ot = OrdersTotal();
   for(j=0;j<ot;j++)
   {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic_Number)
      {   
         if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP)   
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
               OrderDeleted=OrderDelete(ord_arr[j]);
               tries=tries+1;
            }
    }
}


int open_first_order()
{        double rem=0;
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

         if(Close[0]>Open[0])
         {
            NewOrder=0;
            tries=0;
            while(NewOrder<=0 && tries< oper_max_tries)
            {
               NewOrder=OrderSend(Symbol(),OP_BUY,Lot_Size,Ask,5,
                                  Bid-(Unified_Stop_Pips*Point),
                                  Ask+(Max_Open_Orders*Ladder_Step_Pips*Point),
                                  "LSEA",Magic_Number,0,Blue);            
               tries=tries+1;
            }
            OrderSelected=false; tries=0;
            while(!OrderSelected && tries<oper_max_tries)
            {
               OrderSelected=OrderSelect(NewOrder,SELECT_BY_TICKET,MODE_TRADES);
               tries=tries+1;
            }
            buy_price =OrderOpenPrice();
            stop_loss=OrderStopLoss();
            profit_target=OrderTakeProfit();
            sell_price=0;
         }
         else
         {
            NewOrder=0;
            tries=0;
            while(NewOrder<=0 && tries< oper_max_tries)
            {
               NewOrder=OrderSend(Symbol(),OP_SELL,Lot_Size,Bid,5,
                                  Ask+(Unified_Stop_Pips*Point),
                                  Bid-(Max_Open_Orders*Ladder_Step_Pips*Point),
                                  "LSEA",Magic_Number,0,Red);            
               tries=tries+1;
            }
            OrderSelected=false;tries=0;
            while(!OrderSelected && tries< oper_max_tries)
            {
               OrderSelected=OrderSelect(NewOrder,SELECT_BY_TICKET,MODE_TRADES);
               tries=tries+1;
            }
            sell_price =OrderOpenPrice();
            stop_loss=OrderStopLoss();
            profit_target=OrderTakeProfit();
            buy_price=0;

         }
         return(NewOrder);
}

int create_ladder_step(int step_number,double org_buy_price,double org_sell_price)
{
   if(org_buy_price>0)
   {
      NewOrder=0;     tries=0;
      while(NewOrder<=0 && tries< oper_max_tries)
      {
         NewOrder=OrderSend(Symbol(),OP_BUYSTOP,Lot_Size,
                            org_buy_price+(step_number*Ladder_Step_Pips*Point),5,
                            org_buy_price+(step_number*Ladder_Step_Pips*Point)-(Unified_Stop_Pips*Point),
                            profit_target,"LSEA",Magic_Number,0,Blue);            
         tries=tries+1;
      }
   }
   else
   {
      NewOrder=0;tries=0;
      while(NewOrder<=0 && tries< oper_max_tries)
      {  
         NewOrder=OrderSend(Symbol(),OP_SELLSTOP,Lot_Size,
                            org_sell_price-(step_number*Ladder_Step_Pips*Point),5,
                            org_sell_price-(step_number*Ladder_Step_Pips*Point)+(Unified_Stop_Pips*Point),
                            profit_target,"LSEA",Magic_Number,0,Red);          
                    
         tries=tries+1;
      }
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
int last_order_type()
{ int ord_type=-1;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()==Magic_Number 
         && OrderSymbol()==Symbol()
         && (OrderType()==OP_BUY || OrderType()==OP_SELL)
        ) 
        {
            ord_type = OrderType();
            break;
        }
   }
   return(ord_type);
}

void modify_stop_loss()
{  double max_buy_SL=0,min_sell_SL=99999999;
   OrderSelected=false;
   int i;
   if(last_order_type()==0)
   {
      for( i=0;i<OrdersTotal();i++)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
            if(OrderMagicNumber()==Magic_Number 
            && OrderSymbol()==Symbol()
            && OrderType()==OP_BUY  ) 
            {
               if(OrderStopLoss()>max_buy_SL) max_buy_SL=OrderStopLoss();
            }

      }
      for( i=0;i<OrdersTotal();i++)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
            if(OrderMagicNumber()==Magic_Number 
            && OrderSymbol()==Symbol()
            && OrderType()==OP_BUY  )       
            {
               if(OrderStopLoss()<max_buy_SL)
               OrderSelected=false; tries=0;
               while(!OrderSelected && tries< oper_max_tries && OrderStopLoss()!=max_buy_SL)
               {  
                  OrderSelected=OrderModify(OrderTicket(),OrderOpenPrice(),max_buy_SL,OrderTakeProfit(),0,Yellow);
                  tries=tries+1;
               }
               
            }
       }
   }
   if(last_order_type()==1)
   {
      for( i=0;i<OrdersTotal();i++)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
            if(OrderMagicNumber()==Magic_Number 
            && OrderSymbol()==Symbol()
            && OrderType()==OP_SELL  ) 
            {
               if(OrderStopLoss()<min_sell_SL) min_sell_SL=OrderStopLoss();
               
            }

      }
      
      for( i=0;i<OrdersTotal();i++)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
            if(OrderMagicNumber()==Magic_Number 
            && OrderSymbol()==Symbol()
            && OrderType()==OP_SELL  )       
            {
               if(OrderStopLoss()>min_sell_SL)
               OrderSelected=false; tries=0;
               while(!OrderSelected && tries< oper_max_tries && OrderStopLoss()!=min_sell_SL)
               {
                  OrderSelected=OrderModify(OrderTicket(),OrderOpenPrice(),min_sell_SL,OrderTakeProfit(),0,Yellow);
                  tries=tries+1;
               }
               
            }
       }

   }

}

void init()
{
/*   spread=MarketInfo(Symbol(),MODE_SPREAD);
   min_lot_div=1/MarketInfo(Symbol(),MODE_MINLOT);
   tick_value=MarketInfo(Symbol(),MODE_TICKVALUE);
   last_oper=get_last_oper();
  
   Comment("Spread ",spread," Tick Value ",tick_value," last_vol=",last_vol ); 
 */
}
int start()
{  int first_order=0,next_order=0;
   if(total_orders()==0) 
   { 
      delete_pending_order();
      first_order=open_first_order();
      if(first_order<=0) 
      {
         Print("Error : Can Not Open First Order.");
         return(-1);
      }
      for(int i=1;i<Max_Open_Orders;i++)
      {
         next_order=create_ladder_step(i,buy_price,sell_price);
         if(next_order<=0) 
         {
            Print("Error : Can Not Create Next Order.");
            return(-1);
         }
         
      }
   }
   else
   {
      modify_stop_loss();
   }
   return(1);
}

