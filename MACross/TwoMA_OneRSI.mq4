//+------------------------------------------------------------------+
//|                               Copyright © 2016, Khalil Abokwaik. |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Khalil Abokwaik"
#property link "http://www.forexfactory.com/abokwaik"
#property description "Robot (2 MA, 1 RSI) version 4.1"
#property description "based on  Sis.yphus thread http://www.forexfactory.com/showthread.php?t=574065"
#property version "4.1"
#property  strict
//--- custom types ---------------------------------------------------------------------------------
enum enum_exit_types
{
   EXIT_NONE=0,
   EXIT_ON_CLOSE=1,
   EXIT_ON_CROSS=2
};
enum enum_exit_modes
{
   MA_PRICE_CLOSE=0,
   MA_PRICE_HIGH_LOW=1
};

//--- input parameters ----------------------------------------------------------------------------
input int      Magic_Number              = 160131;  // Magic Number
input string   n1="Indicator Settingts";//-----------------------------
input int      sma_period                = 200;//Slow MA Period
input ENUM_MA_METHOD 
               sma_method=MODE_EMA;//Slow MA Method
input int      fma_period                = 5;//Fast MA Period
input ENUM_MA_METHOD 
               fma_method=MODE_EMA;//Fast MA Method
input int      rsi_period                = 2;//RSI Period
input int      rsi_entry_high            = 95;//RSI High Entry Level
input int      rsi_entry_low             = 5;//RSI Low Entry Level
input int      rsi_exit_high             = 95;//RSI High Exit Level
input int      rsi_exit_low              = 5;//RSI Low Exit Level

input string   n2="Position & Trade Management";//-----------------------------
input double   Fixed_Lot_Size            = 0.1;     // Fixed Lot, set 0 to enable Auto Lot
input double   Bal_Perc_Lot_Size         = 1;//Balance (%) Auto Lot
input int      SL_Pips                   = 0;//Stop Loss in Pips or Points, 0 to disable
input int      TP_Pips                   = 0;//Take Profit in Pips or Points, 0 to disable
input int      Trail_Stop_Pips           = 0;//Trailing Stop, 0 to disable
input int      Trail_Stop_Jump_Pips      = 10;//Trail Stop Shift
input int      max_orders                = 1;//Max Orders 
input string   n3="Entry & Exit";//-----------------------------
input bool     fma_entry                 = true;//Entry on Fast MA
input bool     rsi_entry                 = true;//Entry on RSI
input enum_exit_types    
               fma_exit                  = EXIT_ON_CLOSE;//Exit on Fast MA
input enum_exit_modes    
               fma_mode                  = MA_PRICE_CLOSE;//Exit Modes (Close, High/Low)
input bool     rsi_exit                  = false;//Exit on RSI
input enum_exit_types 
               sma_exit                  = EXIT_NONE;//Exit on Opposite Slow MA
input string   n4="Trading Entry Hours (inclusive)";//-----------------------------
input int      start_hour                = 0;//Start Hour (Broker Time)
input int      end_hour                  = 24;//End Hour (Broker Time)
//--- variables ---------------------------------------------------------------------------------------
int      last_type=-1;
datetime bar_time=0,p_time=0;
int      ord_arr[100];
double   sell_price = 0,buy_price  = 0,stop_loss=0,profit_target=0;
bool     OrderSelected=false,OrderDeleted=false;
int      NewOrder=0;
int      oper_max_tries = 2,tries=0;
double   sl_price=0,tp_price=0,Lot_Size=0,ord_price=0;
int      tkt_num=0;
int      trend_tf=0;
bool     buy=false,sell=false;
double   sma,fma_B, fma_C, fma_S,rsi;
int      lot_decimals=2;
//-----------------------------------------------------------------------------------------------------
void init()
{
   double ml=MarketInfo(Symbol(),MODE_MINLOT);
   if(ml==0.01) lot_decimals=2;
   if(ml==0.1) lot_decimals=1;
   if(ml==1) lot_decimals=0;
   sma=iMA(Symbol(),0,sma_period,0,sma_method,PRICE_CLOSE,1);
   fma_C=iMA(Symbol(),0,fma_period,0,fma_method,PRICE_CLOSE,1);;
   if(fma_mode==MA_PRICE_CLOSE) 
   {
      fma_B=iMA(Symbol(),0,fma_period,0,fma_method,PRICE_CLOSE,1);
      fma_S=iMA(Symbol(),0,fma_period,0,fma_method,PRICE_CLOSE,1);
   }
   if(fma_mode==MA_PRICE_HIGH_LOW) 
   {
      fma_B=iMA(Symbol(),0,fma_period,0,fma_method,PRICE_HIGH,1);
      fma_S=iMA(Symbol(),0,fma_period,0,fma_method,PRICE_LOW,1);
   }
}
//-----------------------------------------------------------------------------------------------------
int start()
{  int i=0;
   if(sma_exit==EXIT_ON_CROSS)
   {
      if(current_order_type()==OP_BUY && MarketInfo(Symbol(),MODE_BID)<sma) close_current_orders(OP_BUY);
      if(current_order_type()==OP_SELL && MarketInfo(Symbol(),MODE_BID)>sma) close_current_orders(OP_SELL);
   }
   if(fma_exit ==EXIT_ON_CROSS)
   {
      if(current_order_type()==OP_BUY && MarketInfo(Symbol(),MODE_BID)>fma_B) close_current_orders(OP_BUY);
      if(current_order_type()==OP_SELL && MarketInfo(Symbol(),MODE_BID)<fma_S) close_current_orders(OP_SELL);
   }
   if(Time[0]>bar_time)
   {  
      //initialise signals and Calc. indicator values
      buy=false;
      sell=false;
      sma=iMA(Symbol(),0,sma_period,0,sma_method,PRICE_CLOSE,1);
      fma_C=iMA(Symbol(),0,fma_period,0,fma_method,PRICE_CLOSE,1);;
      if(fma_mode==MA_PRICE_CLOSE) 
      {
         fma_B=iMA(Symbol(),0,fma_period,0,fma_method,PRICE_CLOSE,1);
         fma_S=iMA(Symbol(),0,fma_period,0,fma_method,PRICE_CLOSE,1);
      }
      if(fma_mode==MA_PRICE_HIGH_LOW) 
      {
         fma_B=iMA(Symbol(),0,fma_period,0,fma_method,PRICE_HIGH,1);
         fma_S=iMA(Symbol(),0,fma_period,0,fma_method,PRICE_LOW,1);
      }

      rsi=iRSI(Symbol(),0,rsi_period,PRICE_CLOSE,1);
      //check for close ----------------------------------
      if(current_order_type()==OP_BUY)
      {
         if(fma_exit==EXIT_ON_CLOSE && MarketInfo(Symbol(),MODE_BID)>fma_B) close_current_orders(OP_BUY);
         if(rsi_exit && rsi>rsi_exit_high) close_current_orders(OP_BUY);
         if(sma_exit==EXIT_ON_CLOSE && MarketInfo(Symbol(),MODE_BID)<sma) close_current_orders(OP_BUY);
      }
      if(current_order_type()==OP_SELL)
      {
         if(fma_exit ==EXIT_ON_CLOSE && MarketInfo(Symbol(),MODE_BID)<fma_S) close_current_orders(OP_SELL);
         if(rsi_exit && rsi<rsi_exit_low) close_current_orders(OP_SELL);
         if(sma_exit==EXIT_ON_CLOSE && MarketInfo(Symbol(),MODE_BID)>sma) close_current_orders(OP_SELL);
      }

      // check entry signals -----------------------------------
      buy=MarketInfo(Symbol(),MODE_BID)>sma;
      if(fma_entry) buy=buy && MarketInfo(Symbol(),MODE_BID)<fma_C;
      if(rsi_entry) buy=buy && rsi<rsi_entry_low;

      sell=MarketInfo(Symbol(),MODE_BID)<sma;
      if(fma_entry) sell=sell && MarketInfo(Symbol(),MODE_BID)>fma_C;
      if(rsi_entry) sell=sell && rsi>rsi_entry_high;

      //market orders ------------------------------------------
      // Add time filter in order to gap of new week 
      if(DayOfWeek()==1 && TimeHour(TimeLocal()) <=12){
        return(0)
      }
      bool time_ok=Hour()>=start_hour && Hour()<=end_hour;
      if(start_hour>end_hour) time_ok=!(Hour()>end_hour && Hour()<start_hour);
      if(buy && total_orders()<max_orders && time_ok &&
         (current_order_type()==OP_BUY || current_order_type()==-1)) market_buy_order();
      if(sell && total_orders()<max_orders && time_ok &&
      (current_order_type()==OP_SELL || current_order_type()==-1)) market_sell_order();
      if(Trail_Stop_Pips>0) trail_stop();
      bar_time=Time[0];
      
   }

   return(1);
}

//-----------------------------------------------------------------------------------------------------
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
//-----------------------------------------------------------------------------------------------------
int market_buy_order()
{  double rem=0; bool x=false;
   NewOrder=0;
   tries=0;
   double x_lots=0;
   if (Fixed_Lot_Size > 0) Lot_Size=Fixed_Lot_Size;
   else 
   {
      Lot_Size=NormalizeDouble((AccountBalance()*Bal_Perc_Lot_Size/100)/MarketInfo(Symbol(),MODE_MARGINREQUIRED),lot_decimals);
   }
   if(SL_Pips==0) sl_price=0;
   else sl_price = MarketInfo(Symbol(),MODE_ASK)-SL_Pips*Point;
   if(TP_Pips==0) tp_price=0;
   else tp_price=MarketInfo(Symbol(),MODE_ASK)+TP_Pips*Point;
   while(NewOrder<=0 && tries< oper_max_tries)
   {
      NewOrder=OrderSend(Symbol(),OP_BUY,Lot_Size,MarketInfo(Symbol(),MODE_ASK),5,
                         sl_price,
                         tp_price,
                         "2m1r",Magic_Number,0,Blue);            
      tries=tries+1;
   }
   
   return(NewOrder);
}
//-----------------------------------------------------------------------------------------------------
int market_sell_order()
{
   double rem=0; bool x=false;
   NewOrder=0;
   tries=0;
   double x_lots=0;
   if (Fixed_Lot_Size > 0) Lot_Size=Fixed_Lot_Size;
   else 
   {
      Lot_Size=NormalizeDouble((AccountBalance()*Bal_Perc_Lot_Size/100)/MarketInfo(Symbol(),MODE_MARGINREQUIRED),lot_decimals);
   }

   if(SL_Pips==0) sl_price=0;
   else sl_price = MarketInfo(Symbol(),MODE_BID)+SL_Pips*Point;
   if(TP_Pips==0) tp_price=0;
   else tp_price=MarketInfo(Symbol(),MODE_BID)-TP_Pips*Point;

   while(NewOrder<=0 && tries< oper_max_tries)
   {
      NewOrder=OrderSend(Symbol(),OP_SELL,Lot_Size,MarketInfo(Symbol(),MODE_BID),5,
                         sl_price,
                         tp_price,
                         "2m1r",Magic_Number,0,Red);            
      tries=tries+1;
   }
   

   
   return(NewOrder);
}
//-----------------------------------------------------------------------------------------------------
int current_order_type()
{ int ord_type=-1;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()==Magic_Number 
         && OrderSymbol()==Symbol()
         && (OrderType()==OP_BUY || OrderType()==OP_SELL)
        ) 
        {
         ord_type=OrderType();
        }
   } 
   return(ord_type);
}
//-----------------------------------------------------------------------------------------------------
void close_current_orders(int ord_type)
{ int k=-1,j=0;
   bool x= false;
   for( j=0;j<100;j++) ord_arr[j]=0;
   
   int ot = OrdersTotal();
   for(j=0;j<ot;j++)
   {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic_Number)
      {   
         if( OrderType()==ord_type)
         {  k = k + 1; 
            ord_arr[k]=OrderTicket();
         }
      }     
    }
    for(j=0;j<=k;j++)
    {  bool OrderClosed=false;
       tries=0;
       while(!OrderClosed && tries<oper_max_tries)
            {
               RefreshRates();
               x=OrderSelect(ord_arr[j],SELECT_BY_TICKET,MODE_TRADES);
               if(OrderType()==OP_SELL) OrderClosed=OrderClose(ord_arr[j],OrderLots(),MarketInfo(Symbol(),MODE_ASK),100,NULL);
               if(OrderType()==OP_BUY) OrderClosed=OrderClose(ord_arr[j],OrderLots(),MarketInfo(Symbol(),MODE_BID),100,NULL);
               tries=tries+1;
            }
    }
}

//-----------------------------------------------------------------------------------------------------
void trail_stop()
{ double new_sl=0; bool OrderMod=false;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()==Magic_Number && OrderSymbol()==Symbol())
      {
         RefreshRates();         
         if(OrderType()==OP_BUY)
         {  new_sl=0;
            if(MarketInfo(Symbol(),MODE_BID)-OrderOpenPrice()>Trail_Stop_Pips*Point && OrderOpenPrice()>OrderStopLoss()) new_sl=OrderOpenPrice();
            if (MarketInfo(Symbol(),MODE_BID)-OrderStopLoss()>Trail_Stop_Pips*Point+Trail_Stop_Jump_Pips*Point && OrderStopLoss()>=OrderOpenPrice())
            new_sl = MarketInfo(Symbol(),MODE_BID)-Trail_Stop_Pips*Point;
             OrderMod=false;
             tries=0;
             
             while(!OrderMod && tries<oper_max_tries && new_sl>0)
            {  
               OrderMod=OrderModify(OrderTicket(),OrderOpenPrice(),new_sl,OrderTakeProfit(),0,White);
               tries=tries+1;
               
            }
            
         }
         if(OrderType()==OP_SELL)
         {   new_sl=0;
             if(OrderOpenPrice()-MarketInfo(Symbol(),MODE_ASK)>Trail_Stop_Pips*Point && (OrderOpenPrice()<OrderStopLoss()||OrderStopLoss()==0)) new_sl=OrderOpenPrice();
             if(OrderStopLoss()-MarketInfo(Symbol(),MODE_ASK)>Trail_Stop_Pips*Point+Trail_Stop_Jump_Pips*Point && OrderStopLoss()<=OrderOpenPrice())
             new_sl=MarketInfo(Symbol(),MODE_ASK)+Trail_Stop_Pips*Point;
             OrderMod=false;
             tries=0;
             
             while(!OrderMod && tries<oper_max_tries && new_sl>0)
            {  
               OrderMod=OrderModify(OrderTicket(),OrderOpenPrice(),new_sl,OrderTakeProfit(),0,White);
               tries=tries+1;
               
            }
         
         }
         
      }
   }
}
