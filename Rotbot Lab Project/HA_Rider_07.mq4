//------------------------------------------------------------------------------------------------
//--- HA_Rider_07.mq4 
//--- Copyright © 2015, Khalil Abokwaik. 
//--- Posted on "Robots Lab Project@Forex Factory"
//--- Linke : http://www.forexfactory.com/showthread.php?t=517564
//------------------------------------------------------------------------------------------------
#property copyright     "Copyright 2015, Khalil Abokwaik"
#property link          "http://www.forexfactory.com/abokwaik"
#property description   "Robots Lab@ForexFactory"
#property description   "HA_Rider Trading System of TyLamai"
#property strict
//------------------------------------------------------------------------------------------------
#include <stderror.mqh>
#include <stdlib.mqh>
//--- input parameters ---------------------------------------------------------------------------
input int      Magic_Number              = 140023; // Unique magic number per Robot Instance
input string   Time_Frame                = "D1";   // Time Frame Used, letters or minutes
//--------------------------------------------
input string   HA_Settings               = "Heiken Ashi Indicator Settings";//Heiken Ashi Indicator Settings
input string   Indicator_Type            = "HAS"; // HA:Heiken Ashi, HAS:Heiken Ashi Smoothed
input int      HAS_MA_Method_1           = 2;//HAS MA Method 1 : 0:Simple,1:Exponential,2:Smoothed,3:Linear_Wighted
input int      HAS_MA_Period_1           = 4;//HAS MA Period 1 
input int      HAS_MA_Method_2           = 2;//HAS MA Method 2 : 0:Simple,1:Exponential,2:Smoothed,3:Linear_Wighted
input int      HAS_MA_Period_2           = 1;//HAS MA Period 2 
//--------------------------------------------
input string   Lot_Size_Controls         = "Lot Size Controls";//Lot Size Controls
input double   Fixed_Lot_Size            = 0.1;// Lot Size for 1st order in the chain, to Disable set to 0   
input double   Next_Lot_Factor           = 0.8;// Next Order Multiply Factor 
input string   Lot_Size_Percentage_Of    = "E";// 1st Order Lot Size as Prcentage Of "E"quity, "B" Balance
input double   Lot_Size_Percentage       = 0;//Lot Size Percentage 2=2%
//--------------------------------------------
input string   Orders_Controls           = "Orders Controls";//Orders Controls
input int      Min_Pips_Between_Orders   = 20;// Min. Distance in Pips or Points between orders
                                              // Pips(for 4-digit broker) or Points(for 5-digit broker)
input int      Max_Open_Orders           = 10;// Max. Open Orders per pair
//--------------------------------------------
input string   Closing_Options           = "Closing Options";//Closing Options
input double   Equity_Gain_Percentage    = 10;//Equity Gain Percentage
input double   Equity_Loss_Percentage    = 10;//Equity Loss Percentage
input double   Equity_Gain_Amount        =  0;//Equity Gain Amount
input double   Equity_Loss_Amount        =  0;//Equity Loss Amount
input int      Stop_Loss_Pips            = 100;//Stop Loss in Pips (0 to disable)
input int      Trailing_Stop_Pips        = 100;//Trailing Stop in Pips (0 to disable)
input int      Trailing_Stop_Jump        = 10;//Trailing Stop Jump (to reduce order modification requests)
//--------------------------------------------
input string   Entry_Filters             = "Entry Filters";//Entry Filters
input int      MA_Period                 = 200;//MA Period. 0 to disable
input int      MA_Type                   = 0;//MA Type:0:Simple,1:Exponential,2:Smoothed,3:Linear_Wighted
input string   Higher_TF                 = "W1";//Higher Time Frame (to disable set as Time_Frame)
input int      H_HAS_MA_Method_1         = 2;//HAS MA Method 1 : 0:Simple,1:Exponential,2:Smoothed,3:Linear_Wighted
input int      H_HAS_MA_Period_1         = 4;//HAS MA Period 1 
input int      H_HAS_MA_Method_2         = 2;//HAS MA Method 2 : 0:Simple,1:Exponential,2:Smoothed,3:Linear_Wighted
input int      H_HAS_MA_Period_2         = 1;//HAS MA Period 2 

//--------------------------------------------
input string   Miscellaneous_Options     = "Miscellaneous Options";//Miscellaneous Options
input int      Max_Seconds_to_Activate   = 60;// Max. Seconds to activate after candle starts
input int      Max_Allowed_Slippage      = 10;//Max Allowed Slippage
input string   Normal_or_ECN_Account     = "N";//N:Normal, E:ECN
//--- local parameters --------------------------------------------------------------------------
double         HA_Open,HA_Close,HAH_Open,HAH_Close,ma,lot_size_percentage=0;
int            ord_arr[500],Tr_SL_Pips=0,NewOrder=0,time_frame=0,higher_tf=0;
double         sell_price = 0,buy_price  = 0,stop_loss=0,profit_target=0;
bool           Long,Short,OrderSelected=false,OrderClosed=false,OrderMod=false;
int            oper_max_tries = 10,tries=0,curr_ord_type,error_code=0;
double         sl_price=0,tp_price=0,Lot_Size=0;
double         MA_Val,PSAR_Val,AO_Val,AC_Val,pAC_Val,pAO_Val;
datetime       prev_order_time=0;

//--- Functions & Procedures ----------------------------------------------------------------------

int market_buy_order()
{  double rem=0; bool x=false;
   NewOrder=0;
   tries=0;
   // Lot (Position) Size Calculation 
   lot_size_percentage=Lot_Size_Percentage/100;
   Lot_Size=last_order_lots();
   if(Lot_Size==0) 
   {
      if(Fixed_Lot_Size>0)
         Lot_Size=Fixed_Lot_Size;
      else
      {
         if(Lot_Size_Percentage_Of=="E" && lot_size_percentage>0)
         {
            Lot_Size=MathMin(NormalizeDouble(AccountEquity()/MarketInfo(Symbol(),MODE_MARGINREQUIRED)*lot_size_percentage,2),MarketInfo(Symbol(),MODE_MAXLOT));
            rem=Lot_Size/(MarketInfo(Symbol(),MODE_MINLOT));
            Lot_Size=MathFloor(rem)*MarketInfo(Symbol(),MODE_MINLOT);
         
         }
         if(Lot_Size_Percentage_Of=="B" && lot_size_percentage>0)
         {
            Lot_Size=MathMin(NormalizeDouble(AccountBalance()/MarketInfo(Symbol(),MODE_MARGINREQUIRED)*lot_size_percentage,2),MarketInfo(Symbol(),MODE_MAXLOT));
            rem=Lot_Size/(MarketInfo(Symbol(),MODE_MINLOT));
            Lot_Size=MathFloor(rem)*MarketInfo(Symbol(),MODE_MINLOT);
         
         }

      }
   }
   else
   { 
      Lot_Size=Lot_Size*Next_Lot_Factor;
      Lot_Size=MathMax(Lot_Size,MarketInfo(Symbol(),MODE_MINLOT));
   }   
   // stop loss calculation
   if(Stop_Loss_Pips==0)
      sl_price=0;
   else
      sl_price = Bid-Stop_Loss_Pips*Point;
   while(NewOrder<=0 && tries< oper_max_tries)
   {
      if(Normal_or_ECN_Account=="E")
      {
         NewOrder=OrderSend(Symbol(),OP_BUY,Lot_Size,Ask,Max_Allowed_Slippage,0,0,"HAR_07",Magic_Number,0,Blue);            
         if(NewOrder<=0)
         {
            error_code=GetLastError();
            if(error_code!=ERR_NO_ERROR) 
            {  //Alert("ECN Order Send Error: ",ErrorDescription(error_code));
               Print("ECN Order Send Error: ",ErrorDescription(error_code));
            }
         }
         tries=tries+1;
         if(NewOrder>0 && sl_price>0)
         {
           if(OrderSelect(NewOrder,SELECT_BY_TICKET,MODE_TRADES))
           {
               x=OrderModify(NewOrder,OrderOpenPrice(),sl_price,0,0,Yellow);
               if(!x)
               {
                  error_code=GetLastError();
                  if(error_code!=ERR_NO_ERROR) 
                  {  //Alert("ECN Order SL Modify Error: ",ErrorDescription(error_code));
                     Print("ECN Order SL Modify Error: ",ErrorDescription(error_code));
                  }
               }
           }        
         }
      }
      else
      {
         NewOrder=OrderSend(Symbol(),OP_BUY,Lot_Size,Ask,Max_Allowed_Slippage,sl_price,0,"HAR_07",Magic_Number,0,Blue);            
         if(NewOrder<=0)
         {
            error_code=GetLastError();
            if(error_code!=ERR_NO_ERROR) 
            {  //Alert("Order Send Error: ",ErrorDescription(error_code));
               Print("Order Send Error: ",ErrorDescription(error_code));
            }
         }
         tries=tries+1;         
      }      
   }
   if(NewOrder>0) prev_order_time=TimeCurrent();
   return(NewOrder);
}
//-----------------------------------------------------------------------------------------------
int market_sell_order()
{
   double rem=0; bool x=false;
   NewOrder=0;
   tries=0;
   // Lot (Position) Size Calculation    
   lot_size_percentage=Lot_Size_Percentage/100;
   Lot_Size=last_order_lots();
   if(Lot_Size==0) 
   {
      if(Fixed_Lot_Size>0)
         Lot_Size=Fixed_Lot_Size;
      else
      {
         if(Lot_Size_Percentage_Of=="E" && lot_size_percentage>0)
         {
            Lot_Size=MathMin(NormalizeDouble(AccountEquity()/MarketInfo(Symbol(),MODE_MARGINREQUIRED)*lot_size_percentage,2),MarketInfo(Symbol(),MODE_MAXLOT));
            rem=Lot_Size/(MarketInfo(Symbol(),MODE_MINLOT));
            Lot_Size=MathFloor(rem)*MarketInfo(Symbol(),MODE_MINLOT);
         
         }
         if(Lot_Size_Percentage_Of=="B" && lot_size_percentage>0)
         {
            Lot_Size=MathMin(NormalizeDouble(AccountBalance()/MarketInfo(Symbol(),MODE_MARGINREQUIRED)*lot_size_percentage,2),MarketInfo(Symbol(),MODE_MAXLOT));
            rem=Lot_Size/(MarketInfo(Symbol(),MODE_MINLOT));
            Lot_Size=MathFloor(rem)*MarketInfo(Symbol(),MODE_MINLOT);
         
         }

      }
   }
   else
   { 
      Lot_Size=Lot_Size*Next_Lot_Factor;
      Lot_Size=MathMax(Lot_Size,MarketInfo(Symbol(),MODE_MINLOT));
   }   
   // stop loss calculation
   if(Stop_Loss_Pips==0)
      sl_price=0;
   else
      sl_price = Ask+Stop_Loss_Pips*Point;

   // Trying to open the order
   
   while(NewOrder<=0 && tries< oper_max_tries)
   {
      if(Normal_or_ECN_Account=="E")
      {
         NewOrder=OrderSend(Symbol(),OP_SELL,Lot_Size,Bid,Max_Allowed_Slippage,0,0,"HAR_07",Magic_Number,0,Red);            
         if(NewOrder<=0)
         {        
            error_code=GetLastError();
            if(error_code!=ERR_NO_ERROR) 
            {  //Alert("ECN Order Send Error: ",ErrorDescription(error_code));
               Print("ECN Order Send Error: ",ErrorDescription(error_code));
            }
         }
         tries=tries+1;
         if(NewOrder>0 && sl_price>0)
         {
           if(OrderSelect(NewOrder,SELECT_BY_TICKET,MODE_TRADES))
           {
               x=OrderModify(NewOrder,OrderOpenPrice(),sl_price,0,0,Yellow);
               if(!x)
               {
                  error_code=GetLastError();
                  if(error_code!=ERR_NO_ERROR) 
                  {  //Alert("ECN Order SL Modify Error: ",ErrorDescription(error_code));
                     Print("ECN Order SL Modify Error: ",ErrorDescription(error_code));
                  }
               }
           }        
         }
      }
      else
      {
         NewOrder=OrderSend(Symbol(),OP_SELL,Lot_Size,Bid,Max_Allowed_Slippage,sl_price,0,"HAR_07",Magic_Number,0,Red);            
         if(NewOrder<=0)
         {
            error_code=GetLastError();
            if(error_code!=ERR_NO_ERROR) 
            {  //Alert("Order Send Error: ",ErrorDescription(error_code));
               Print("Order Send Error: ",ErrorDescription(error_code));
            }
         }
         tries=tries+1;         
      }      
   }
   if(NewOrder>0) prev_order_time=TimeCurrent();
   return(NewOrder);
}
//-----------------------------------------------------------------------------------------------
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
//-----------------------------------------------------------------------------------------------
int current_order_type()
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
//-----------------------------------------------------------------------------------------------
double last_order_lots()
{ double ord_lots=0;
  int tkt_num=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()==Magic_Number 
         && OrderSymbol()==Symbol()
         && OrderTicket()>tkt_num
        ) 
        {
            ord_lots = OrderLots();
            tkt_num=OrderTicket();
 
        }
   }
   return(ord_lots);
}
//-----------------------------------------------------------------------------------------------
double last_order_open_price()
{ double last_order_open_pr=0;
  int tkt_num=0;

   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()==Magic_Number 
         && OrderSymbol()==Symbol()
         && OrderTicket()>tkt_num
        ) 
        {
            tkt_num=OrderTicket();
            last_order_open_pr=OrderOpenPrice();
        }
   }
   return(last_order_open_pr);
}
//-----------------------------------------------------------------------------------------------
bool Order_Open_in_TF(int TF)
{ int j=0;
   if(TF==0) TF=ChartPeriod();
   for(j=0;j<OrdersTotal();j++)
   {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic_Number)
      {   
         if((TimeCurrent()-OrderOpenTime())/60 < TF) return(true);
      }     
    }
   return(false);
}
//-----------------------------------------------------------------------------------------------
void close_pair_orders()
{ int k=-1,j=0;
   bool order_found= false;
   for(j=0;j<500;j++) ord_arr[j]=0;
   
   int ot = OrdersTotal();
   for(j=0;j<ot;j++)
   {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic_Number)
      {   
         if( (OrderType()==OP_SELL || OrderType()==OP_BUY)   )
         {  k = k + 1; 
            ord_arr[k]=OrderTicket();
         }
      }     
    }
    for(j=0;j<=k;j++)
    {  OrderClosed=false;
       tries=0;
       while(!OrderClosed && tries<oper_max_tries)
            {
               order_found=OrderSelect(ord_arr[j],SELECT_BY_TICKET,MODE_TRADES);
               if(OrderType()==OP_SELL && order_found) OrderClosed=OrderClose(ord_arr[j],OrderLots(),Ask,Max_Allowed_Slippage,NULL);
               if(OrderType()==OP_BUY && order_found) OrderClosed=OrderClose(ord_arr[j],OrderLots(),Bid,Max_Allowed_Slippage,NULL);
               if(order_found && !OrderClosed)
               {
                  error_code=GetLastError();
                  if(error_code!=ERR_NO_ERROR) 
                  {  //Alert("Order Close Error: ",ErrorDescription(error_code));
                     Print("Order Close Error: ",ErrorDescription(error_code));
                  }
               }               
               tries=tries+1;
            }
    }
}
//-----------------------------------------------------------------------------------------------
void close_basket()
{ int k=-1,j=0;
   bool order_found= false;
   for(j=0;j<500;j++) ord_arr[j]=0;
   
   int ot = OrdersTotal();
   for(j=0;j<ot;j++)
   {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()==Magic_Number)
      {   
         if( (OrderType()==OP_SELL || OrderType()==OP_BUY)   )
         {  k = k + 1; 
            ord_arr[k]=OrderTicket();
         }
      }     
    }
    for(j=0;j<=k;j++)
    {  OrderClosed=false;
       tries=0;
       while(!OrderClosed && tries<oper_max_tries)
            {
               order_found=OrderSelect(ord_arr[j],SELECT_BY_TICKET,MODE_TRADES);
               if(OrderType()==OP_SELL && order_found) OrderClosed=OrderClose(ord_arr[j],OrderLots(),Ask,Max_Allowed_Slippage,Pink);
               if(OrderType()==OP_BUY && order_found) OrderClosed=OrderClose(ord_arr[j],OrderLots(),Bid,Max_Allowed_Slippage,Pink);
               if(order_found && !OrderClosed)
               {
                  error_code=GetLastError();
                  if(error_code!=ERR_NO_ERROR) 
                  {  //Alert("Order Close Error: ",ErrorDescription(error_code));
                     Print("Order Close Error: ",ErrorDescription(error_code));
                  }
               }               
               tries=tries+1;
            }
    }
}

//-----------------------------------------------------------------------------------------------
void trail_stop()
{ double new_sl=0,old_sl=0,op_price=0; int ord_ticket=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      old_sl=OrderStopLoss();
      op_price=OrderOpenPrice();
      new_sl=0;
      ord_ticket=OrderTicket();
      if(OrderMagicNumber()==Magic_Number && OrderSymbol()==Symbol())
      {
         if(OrderType()==OP_BUY)
         {
            if(Bid-op_price>Trailing_Stop_Pips*Point && op_price>old_sl) new_sl=op_price;
            if (Bid-old_sl>Trailing_Stop_Pips*Point+Trailing_Stop_Jump*Point && old_sl>=op_price)
            new_sl = Bid-Trailing_Stop_Pips*Point;
             OrderMod=false;
             tries=0;
             while(!OrderMod && tries<oper_max_tries && new_sl>old_sl)
            {
               OrderMod=OrderModify(ord_ticket,op_price,new_sl,0,0,White);
               if(!OrderMod)               
               {
                  error_code=GetLastError();
                  if(error_code!=ERR_NO_ERROR) 
                  {  //Alert("Trailing Stop Modify Error: ",ErrorDescription(error_code));
                     Print("Trailing Stop Modify Error: ",ErrorDescription(error_code));
                     
                  }
               }
               tries=tries+1;
            }
            
         }
         if(OrderType()==OP_SELL)
         {
             if(op_price-Ask>Trailing_Stop_Pips*Point && (op_price<old_sl||old_sl==0)) new_sl=op_price;
             if(old_sl-Ask>Trailing_Stop_Pips*Point+Trailing_Stop_Jump*Point && old_sl<=op_price)
             new_sl=Ask+Trailing_Stop_Pips*Point;
             OrderMod=false;
             tries=0;
             while(!OrderMod && tries<oper_max_tries && (new_sl<old_sl || old_sl==0) && new_sl>0)
            { 
               OrderMod=OrderModify(ord_ticket,op_price,new_sl,0,0,White);
               if(!OrderMod)
               {  error_code=GetLastError();
                  if(error_code!=ERR_NO_ERROR) 
                  {  //Alert("Trailing Stop Modify Error: ",ErrorDescription(error_code));
                     Print("Trailing Stop Modify Error: ",ErrorDescription(error_code));
                     
                  }               
               }
               tries=tries+1;
            }
         
         }
         
      }
   }
         

}
//-----------------------------------------------------------------------------------------------
int StringToTimeFrame(string tfs)
{
   int tf=0;
         if (tfs=="M1" || tfs=="1"     ||tfs=="m1")   tf=PERIOD_M1;
         if (tfs=="M5" || tfs=="5"     ||tfs=="m5")   tf=PERIOD_M5;
         if (tfs=="M15"|| tfs=="15"    ||tfs=="m15")  tf=PERIOD_M15;
         if (tfs=="M30"|| tfs=="30"    ||tfs=="m30")  tf=PERIOD_M30;
         if (tfs=="H1" || tfs=="60"    ||tfs=="h1")   tf=PERIOD_H1;
         if (tfs=="H4" || tfs=="240"   ||tfs=="h4")   tf=PERIOD_H4;
         if (tfs=="D1" || tfs=="1440"  ||tfs=="d1")   tf=PERIOD_D1;
         if (tfs=="W1" || tfs=="10080" ||tfs=="w1")   tf=PERIOD_W1;
         if (tfs=="MN" || tfs=="43200" ||tfs=="mn")   tf=PERIOD_MN1;
         if (tf==0)               tf=Period();
   return(tf);
}

//-----------------------------------------------------------------------------------------------
void init()
{
   time_frame=StringToTimeFrame(Time_Frame);
   higher_tf=StringToTimeFrame(Higher_TF);
}
//-----------------------------------------------------------------------------------------------
int start()
{  
   if(TimeCurrent()-iTime(Symbol(),time_frame,0)<Max_Seconds_to_Activate)
   {
      // calculate indicator values
      if(Indicator_Type=="HAS")
      {
         HA_Open=iCustom(Symbol(),time_frame,"Heiken_Ashi_Smoothed_TF",HAS_MA_Method_1,HAS_MA_Period_1,HAS_MA_Method_2,HAS_MA_Period_2,time_frame,2,1);
         HA_Close=iCustom(Symbol(),time_frame,"Heiken_Ashi_Smoothed_TF",HAS_MA_Method_1,HAS_MA_Period_1,HAS_MA_Method_2,HAS_MA_Period_2,time_frame,3,1);

      }
      else
      {
         HA_Open=iCustom(Symbol(),time_frame,"Heiken Ashi",2,1);
         HA_Close=iCustom(Symbol(),time_frame,"Heiken Ashi",3,1);
      }

      // calculate filters
      // Moving Average
      if(MA_Period>0)
      {
         ma=iMA(Symbol(),time_frame,MA_Period,0,MA_Type,PRICE_CLOSE,1);
      }
      // Higher TF HA
      if(higher_tf!=time_frame)
      {
         if(Indicator_Type=="HAS")
         {
            HAH_Open=iCustom(Symbol(),time_frame,"Heiken_Ashi_Smoothed_TF",H_HAS_MA_Method_1,H_HAS_MA_Period_1,H_HAS_MA_Method_2,H_HAS_MA_Period_2,higher_tf,2,1);
            HAH_Close=iCustom(Symbol(),time_frame,"Heiken_Ashi_Smoothed_TF",H_HAS_MA_Method_1,H_HAS_MA_Period_1,H_HAS_MA_Method_2,H_HAS_MA_Period_2,higher_tf,3,1);
   
         }
         else
         {
            HAH_Open=iCustom(Symbol(),time_frame,"Heiken Ashi",2,1);
            HAH_Close=iCustom(Symbol(),time_frame,"Heiken Ashi",3,1);
         }

      }
         
      // initialize signals
      Long=False;
      Short=False;
      // update signals based on indicator values
      if(HA_Close>HA_Open) Long=True;
      if(HA_Close<HA_Open) Short=True;
      // check for closing current orders on signal change
      if(current_order_type()==0 && Short) close_pair_orders();
      if(current_order_type()==1 && Long) close_pair_orders();
      // check for openning new trades
      if(total_orders()<Max_Open_Orders 
         && Long 
         && !Order_Open_in_TF(time_frame)       //to avoid opening multiple orders on same candle
         && (Ask-last_order_open_price()>Min_Pips_Between_Orders*Point ||  last_order_open_price()==0)
         && ( (MA_Period>0 && Bid>ma) || MA_Period==0 )
         && ( (higher_tf!=time_frame && HAH_Close>HAH_Open) ||higher_tf==time_frame )
         )
         market_buy_order();
      
      if(total_orders()<Max_Open_Orders 
         && Short 
         && !Order_Open_in_TF(time_frame)       //to avoid opening multiple orders on same candle
         && (last_order_open_price()-Bid>Min_Pips_Between_Orders*Point ||  last_order_open_price()==0)
         && ( (MA_Period>0 && Bid<ma) || MA_Period==0 )
         && ( (higher_tf!=time_frame && HAH_Close<HAH_Open) ||higher_tf==time_frame )
         
         )
         market_sell_order();   
     
   }
   if(total_orders()>0 && Trailing_Stop_Pips>0) trail_stop();
   if( Equity_Gain_Percentage > 0 && (AccountEquity()-AccountBalance())/AccountBalance() > (Equity_Gain_Percentage/100)) close_basket();
   if( Equity_Loss_Percentage > 0 && (AccountBalance()-AccountEquity())/AccountBalance() > (Equity_Loss_Percentage/100)) close_basket();
   if( Equity_Gain_Amount > 0 && AccountEquity()-AccountBalance() > Equity_Gain_Amount) close_basket();
   if( Equity_Loss_Amount > 0 && AccountBalance()-AccountEquity() > Equity_Loss_Amount) close_basket();

   return(1);
}
//-----------------------------------------------------------------------------------------------
