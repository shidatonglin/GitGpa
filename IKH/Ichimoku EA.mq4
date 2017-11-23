// ------------------------------------------------------------------------------------------------
// Copyright © 2011, www.lifesdream.org
// http://www.lifesdream.org
// ------------------------------------------------------------------------------------------------
#include <stdlib.mqh>
#include <stderror.mqh> 
#property copyright "Copyright © 2011, www.lifesdream.org"
#property link "http://www.lifesdream.org"

// ------------------------------------------------------------------------------------------------
// VARIABLES EXTERNAS
// ------------------------------------------------------------------------------------------------

extern int magic1 = 47291;
extern int magic2 = 47292;
extern int magic3 = 47293;
// Configuration
extern string www.lifesdream.org = "Ichimoku EA v1.3";
extern string CommonSettings = "---------------------------------------------";
extern int user_slippage = 2; 
extern int user_tp = 100;
extern int user_sl = 100;
extern int use_tp_sl = 1;
extern double profit_lock = 0.90;
extern int strategy1 = 1; // Tenkan Sen/Kijun Sen Cross
extern int strategy2 = 1; // Kijun Sen Cross
extern int strategy3 = 1;  // Kumo Breakout
extern int signal_strength = 1; // 1=strong | 2: neutral | 3: weak
extern string MoneyManagementSettings = "---------------------------------------------";
// Money Management
extern int money_management = 1;
extern double min_lots = 0.1;
extern int risk=1;
extern int progression = 0; // 0=none | 1:ascending | 2:martingale
// Indicator
extern string IndicatorSettings = "---------------------------------------------";
extern int tenkan_sen=9;
extern int kijun_sen=26;
extern int senkou_span = 52;
extern int shift = 1;

// ------------------------------------------------------------------------------------------------
// VARIABLES GLOBALES
// ------------------------------------------------------------------------------------------------
string key1 = "Ichimoku EA v1.3 (strategy 1)";
string key2 = "Ichimoku EA v1.3 (strategy 2)";
string key3 = "Ichimoku EA v1.3 (strategy 3)";
// Definimos 1 variable para guardar los tickets
int order_ticket1,order_ticket2,order_ticket3;
// Definimos 1 variable para guardar los lotes
double order_lots1,order_lots2,order_lots3;
// Definimos 1 variable para guardar las valores de apertura de las ordenes
double order_price1,order_price2,order_price3;
// Definimos 1 variable para guardar los beneficios
double order_profit1,order_profit2,order_profit3;
// Definimos 1 variable para guardar los tiempos
int order_time1,order_time2,order_time3;
// indicadores
double signal1=0,signal2=0,signal3=0;
// Cantidad de ordenes;
int orders1 = 0;
int direction1= 0;
double max_profit1=0, close_profit1=0;
double last_order_profit1=0, last_order_lots1=0;
int orders2 = 0;
int direction2= 0;
double max_profit2=0, close_profit2=0;
double last_order_profit2=0, last_order_lots2=0;
int orders3 = 0;
int direction3= 0;
double max_profit3=0, close_profit3=0;
double last_order_profit3=0, last_order_lots3=0;
// Colores
color c=Black;
// Cuenta
double balance, equity;
int slippage=0;
// OrderReliable
int retry_attempts = 10; 
double sleep_time = 4.0;
double sleep_maximum	= 25.0;  // in seconds
string OrderReliable_Fname = "OrderReliable fname unset";
static int _OR_err = 0;
string OrderReliableVersion = "V1_1_1"; 

// ------------------------------------------------------------------------------------------------
// START
// ------------------------------------------------------------------------------------------------
int start()
{  
  int ticket, i, n;
  double price;
  bool cerrada, encontrada;

  if (MarketInfo(Symbol(),MODE_DIGITS)==4)
  {
    slippage = user_slippage;
  }
  else if (MarketInfo(Symbol(),MODE_DIGITS)==5)
  {
    slippage = 10*user_slippage;
  }
  
  if(IsTradeAllowed() == false) 
  {
    Comment("Copyright © 2011, www.lifesdream.org\nTrade not allowed.");
    return;  
  }
  
  if (use_tp_sl==0)
    Comment(StringConcatenate("\nCopyright © 2011, www.lifesdream.org\nIchimoku EA v1.3 is running.",
                              "\nStrategy 1 (Tenkan Sen/Kijun Sen Cross). Next order lots (: ",CalcularVolumen(1),
                              "\nStrategy 2 (Kijun Sen Cross). Next order lots (: ",CalcularVolumen(2),
                              "\nStrategy 3 (Kumo Breakout). Next order lots (: ",CalcularVolumen(3)
                             )
           );
  else if (use_tp_sl==1)  
    Comment(StringConcatenate("\nCopyright © 2011, www.lifesdream.org\nIchimoku EA v1.3 is running.",
                              "\nStrategy 1 (Tenkan Sen/Kijun Sen Cross). Next order lots: ",CalcularVolumen(1),"\nTake profit ($): ",CalcularVolumen(1)*10*user_tp,"\nStop loss ($): ",CalcularVolumen(1)*10*user_sl,
                              "\nStrategy 2 (Kijun Sen Cross). Next order lots: ",CalcularVolumen(2),"\nTake profit ($): ",CalcularVolumen(2)*10*user_tp,"\nStop loss ($): ",CalcularVolumen(2)*10*user_sl,
                              "\nStrategy 3 (Kumo Breakout). Next order lots: ",CalcularVolumen(3),"\nTake profit ($): ",CalcularVolumen(3)*10*user_tp,"\nStop loss ($): ",CalcularVolumen(3)*10*user_sl
                             )
           );
  
  // Actualizamos el estado actual
  InicializarVariables();
  ActualizarOrdenes();
  
  encontrada=FALSE;
  if (OrdersHistoryTotal()>0)
  {
    i=1;
    
    while (i<=100 && encontrada==FALSE)
    { 
      n = OrdersHistoryTotal()-i;
      if(OrderSelect(n,SELECT_BY_POS,MODE_HISTORY)==TRUE)
      {
        if (OrderMagicNumber()==magic1)
        {
          encontrada=TRUE;
          last_order_profit1=OrderProfit();
          last_order_lots1=OrderLots();
        }
        if (OrderMagicNumber()==magic2)
        {
          encontrada=TRUE;
          last_order_profit2=OrderProfit();
          last_order_lots2=OrderLots();
        }
        if (OrderMagicNumber()==magic3)
        {
          encontrada=TRUE;
          last_order_profit3=OrderProfit();
          last_order_lots3=OrderLots();
        }
      }
      i++;
    }
  }
  
  if (strategy1==1) Robot1();
  if (strategy2==1) Robot2();
  if (strategy3==1) Robot3();
  
  return(0);
}


// ------------------------------------------------------------------------------------------------
// INICIALIZAR VARIABLES
// ------------------------------------------------------------------------------------------------
void InicializarVariables()
{
  orders1=0;
  direction1=0;
  order_ticket1 = 0;
  order_lots1 = 0;
  order_price1 = 0;
  order_time1 = 0;
  order_profit1 = 0;
  last_order_profit1 = 0;
  last_order_lots1 = 0;
  
  orders2=0;
  direction2=0;
  order_ticket2 = 0;
  order_lots2 = 0;
  order_price2 = 0;
  order_time2 = 0;
  order_profit2 = 0;
  last_order_profit2 = 0;
  last_order_lots2 = 0;
  
  orders3=0;
  direction3=0;
  order_ticket3 = 0;
  order_lots3 = 0;
  order_price3 = 0;
  order_time3 = 0;
  order_profit3 = 0;
  last_order_profit3 = 0;
  last_order_lots3 = 0;
}

// ------------------------------------------------------------------------------------------------
// ACTUALIZAR ORDENES
// ------------------------------------------------------------------------------------------------
void ActualizarOrdenes()
{
  int ordenes1=0,ordenes2=0,ordenes3=0;
  
  // Lo que hacemos es introducir los tickets, los lotes, y los valores de apertura en las matrices. 
  // Además guardaremos el número de ordenes en una variables.
  
  // Ordenes de compra
  for(int i=0; i<OrdersTotal(); i++)
  {
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
    {
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic1)
      {
        order_ticket1 = OrderTicket();
        order_lots1 = OrderLots();
        order_price1 = OrderOpenPrice();
        order_time1 = OrderOpenTime();
        order_profit1 = OrderProfit();
        ordenes1++;
        if (OrderType()==OP_BUY) direction1=1;
        if (OrderType()==OP_SELL) direction1=2;
      }
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic2)
      {
        order_ticket2 = OrderTicket();
        order_lots2 = OrderLots();
        order_price2 = OrderOpenPrice();
        order_time2 = OrderOpenTime();
        order_profit2 = OrderProfit();
        ordenes2++;
        if (OrderType()==OP_BUY) direction2=1;
        if (OrderType()==OP_SELL) direction2=2;
      }
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic3)
      {
        order_ticket3 = OrderTicket();
        order_lots3 = OrderLots();
        order_price3 = OrderOpenPrice();
        order_time3 = OrderOpenTime();
        order_profit3 = OrderProfit();
        ordenes3++;
        if (OrderType()==OP_BUY) direction3=1;
        if (OrderType()==OP_SELL) direction3=2;
      }
    }
  }
  
  // Actualizamos variables globales
  orders1 = ordenes1;
  orders2 = ordenes2;
  orders3 = ordenes3;
}

// ------------------------------------------------------------------------------------------------
// ESCRIBE
// ------------------------------------------------------------------------------------------------
void Escribe(string nombre, string s, int x, int y, string font, int size, color c)
{
  if (ObjectFind(nombre)!=-1)
  {
    ObjectSetText(nombre,s,size,font,c);
  }
  else
  {
    ObjectCreate(nombre,OBJ_LABEL,0,0,0);
    ObjectSetText(nombre,s,size,font,c);
    ObjectSet(nombre,OBJPROP_XDISTANCE, x);
    ObjectSet(nombre,OBJPROP_YDISTANCE, y);
  }
}

// ------------------------------------------------------------------------------------------------
// CALCULAR VOLUMEN
// ------------------------------------------------------------------------------------------------
double CalcularVolumen(int strategy)
{ 
  double aux; 
  int n;
  
  if (strategy==1)
  {
    if (money_management==0)
    {
      aux=min_lots;
    }
    else
    {    
      if (progression==0) 
      { 
        aux = risk*AccountFreeMargin();
        aux= aux/100000;
        n = MathFloor(aux/min_lots);
      
        aux = n*min_lots;                   
      }  
  
      if (progression==1)
      {
        if (last_order_profit1<0)
        {
          aux = last_order_lots1+min_lots;
        }
        else 
        {
          aux = last_order_lots1-min_lots;
        }  
      }        
     
      if (progression==2)
      {
        if (last_order_profit1<0)
        {
          aux = last_order_lots1*2;
        }
        else 
        {
           aux = risk*AccountFreeMargin();
           aux= aux/100000;
           n = MathFloor(aux/min_lots);
           
           aux = n*min_lots;         
        }  
      }     
    
      if (aux<min_lots)
        aux=min_lots;
     
      if (aux>MarketInfo(Symbol(),MODE_MAXLOT))
        aux=MarketInfo(Symbol(),MODE_MAXLOT);
      
      if (aux<MarketInfo(Symbol(),MODE_MINLOT))
        aux=MarketInfo(Symbol(),MODE_MINLOT);
    }
  }
  
  if (strategy==2)
  {
    if (money_management==0)
    {
      aux=min_lots;
    }
    else
    {    
      if (progression==0) 
      { 
        aux = risk*AccountFreeMargin();
        aux= aux/100000;
        n = MathFloor(aux/min_lots);
      
        aux = n*min_lots;                   
      }  
  
      if (progression==1)
      {
        if (last_order_profit2<0)
        {
          aux = last_order_lots2+min_lots;
        }
        else 
        {
          aux = last_order_lots2-min_lots;
        }  
      }        
     
      if (progression==2)
      {
        if (last_order_profit2<0)
        {
          aux = last_order_lots2*2;
        }
        else 
        {
           aux = risk*AccountFreeMargin();
           aux= aux/100000;
           n = MathFloor(aux/min_lots);
           
           aux = n*min_lots;         
        }  
      }     
    
      if (aux<min_lots)
        aux=min_lots;
     
      if (aux>MarketInfo(Symbol(),MODE_MAXLOT))
        aux=MarketInfo(Symbol(),MODE_MAXLOT);
      
      if (aux<MarketInfo(Symbol(),MODE_MINLOT))
        aux=MarketInfo(Symbol(),MODE_MINLOT);
    }
  }
  
  if (strategy==3)
  {
    if (money_management==0)
    {
      aux=min_lots;
    }
    else
    {    
      if (progression==0) 
      { 
        aux = risk*AccountFreeMargin();
        aux= aux/100000;
        n = MathFloor(aux/min_lots);
      
        aux = n*min_lots;                   
      }  
  
      if (progression==1)
      {
        if (last_order_profit3<0)
        {
          aux = last_order_lots3+min_lots;
        }
        else 
        {
          aux = last_order_lots3-min_lots;
        }  
      }        
     
      if (progression==2)
      {
        if (last_order_profit3<0)
        {
          aux = last_order_lots3*2;
        }
        else 
        {
           aux = risk*AccountFreeMargin();
           aux= aux/100000;
           n = MathFloor(aux/min_lots);
           
           aux = n*min_lots;         
        }  
      }     
    
      if (aux<min_lots)
        aux=min_lots;
     
      if (aux>MarketInfo(Symbol(),MODE_MAXLOT))
        aux=MarketInfo(Symbol(),MODE_MAXLOT);
      
      if (aux<MarketInfo(Symbol(),MODE_MINLOT))
        aux=MarketInfo(Symbol(),MODE_MINLOT);
    }
  }
  
  
  return(aux);
}

// ------------------------------------------------------------------------------------------------
// CALCULA VALOR PIP
// ------------------------------------------------------------------------------------------------
double CalculaValorPip(double lotes)
{ 
   double aux_mm_valor=0;
   
   double aux_mm_tick_value = MarketInfo(Symbol(), MODE_TICKVALUE);
   double aux_mm_tick_size = MarketInfo(Symbol(), MODE_TICKSIZE);
   int aux_mm_digits = MarketInfo(Symbol(),MODE_DIGITS);   
   double aux_mm_veces_lots = 1/lotes;
      
   if (aux_mm_digits==5)
   {
     aux_mm_valor=aux_mm_tick_value*10;
   }
   else if (aux_mm_digits==4)
   {
     aux_mm_valor = aux_mm_tick_value;
   }
   
   if (aux_mm_digits==3)
   {
     aux_mm_valor=aux_mm_tick_value*10;
   }
   else if (aux_mm_digits==2)
   {
     aux_mm_valor = aux_mm_tick_value;
   }
   
   aux_mm_valor = aux_mm_valor/aux_mm_veces_lots;
   
   return(aux_mm_valor);
}

// ------------------------------------------------------------------------------------------------
// CALCULA TAKE PROFIT
// ------------------------------------------------------------------------------------------------
int CalculaTakeProfit(int strategy)
{ 
  int aux_take_profit;      
  
  if (strategy==1) aux_take_profit=MathRound(CalculaValorPip(order_lots1)*user_tp);  
  if (strategy==2) aux_take_profit=MathRound(CalculaValorPip(order_lots2)*user_tp);  
  if (strategy==3) aux_take_profit=MathRound(CalculaValorPip(order_lots3)*user_tp);  

  return(aux_take_profit);
}

// ------------------------------------------------------------------------------------------------
// CALCULA STOP LOSS
// ------------------------------------------------------------------------------------------------
int CalculaStopLoss(int strategy)
{ 
  int aux_stop_loss;      
  
  if (strategy==1) aux_stop_loss=-1*CalculaValorPip(order_lots1)*user_sl;
  if (strategy==2) aux_stop_loss=-1*CalculaValorPip(order_lots2)*user_sl;
  if (strategy==3) aux_stop_loss=-1*CalculaValorPip(order_lots3)*user_sl;
    
  return(aux_stop_loss);
}

// ------------------------------------------------------------------------------------------------
// CALCULA SIGNAL 
// ------------------------------------------------------------------------------------------------
int CalculaSignal(int strategy,int aux_tenkan_sen, double aux_kijun_sen, double aux_senkou_span, int aux_shift)
{
  int aux=0;
  double kt1=0, kb1=0, kt2=0, kb2=0;  
  double ts1,ts2,ks1,ks2,ssA1,ssA2,ssB1,ssB2,close1,close2; 
  
  ts1 = iIchimoku(Symbol(), 0, aux_tenkan_sen, aux_kijun_sen, aux_senkou_span, MODE_TENKANSEN, aux_shift);
  ks1 = iIchimoku(Symbol(), 0, aux_tenkan_sen, aux_kijun_sen, aux_senkou_span, MODE_KIJUNSEN, aux_shift);
  ssA1 = iIchimoku(Symbol(), 0, aux_tenkan_sen, aux_kijun_sen, aux_senkou_span, MODE_SENKOUSPANA, aux_shift);
  ssB1 = iIchimoku(Symbol(), 0, aux_tenkan_sen, aux_kijun_sen, aux_senkou_span, MODE_SENKOUSPANB, aux_shift);
  close1 = iClose(Symbol(), 0, aux_shift);
  ts2 = iIchimoku(Symbol(), 0, aux_tenkan_sen, aux_kijun_sen, aux_senkou_span, MODE_TENKANSEN, aux_shift+1);
  ks2 = iIchimoku(Symbol(), 0, aux_tenkan_sen, aux_kijun_sen, aux_senkou_span, MODE_KIJUNSEN, aux_shift+1);
  ssA2 = iIchimoku(Symbol(), 0, aux_tenkan_sen, aux_kijun_sen, aux_senkou_span, MODE_SENKOUSPANA, aux_shift+1);
  ssB2 = iIchimoku(Symbol(), 0, aux_tenkan_sen, aux_kijun_sen, aux_senkou_span, MODE_SENKOUSPANB, aux_shift+1);
  close2 = iClose(Symbol(), 0, aux_shift+1);
  
  if (ssA1 >= ssB1) kt1 = ssA1;
  else kt1 = ssB1;
  
  if (ssA1 <= ssB1) kb1 = ssA1;
  else kb1 = ssB1;
  
  if (ssA2 >= ssB2) kt2 = ssA2;
  else kt2 = ssB2;
  
  if (ssA2 <= ssB2) kb2 = ssA2;
  else kb2 = ssB2;
    
  // Valores de retorno
  // 1. Compra
  // 2. Venta
  
  // STRATEGY 1: Tenkan Sen / Kijun Sen Cross
  if (strategy==1)
  {
    // BUY SIGNAL
    if (ts1>ks1 && ts2<ks2)
    {
      // STRONG
      if (signal_strength==1)
      { 
        if (ks1>kt1) aux=1;   
      }
      // NEUTRAL
      else if (signal_strength==2)
      {
        if (ks1>kb1) aux=1;
      }
      // WEAK
      else if (signal_strength==3)
      {
        aux=1;
      }      
    }
    // SELL SIGNAL
    if (ts1<ks1 && ts2>ks2)
    {
      // STRONG
      if (signal_strength==1)
      { 
        if (ts1<kb1) aux=2;   
      }
      // NEUTRAL
      else if (signal_strength==2)
      {
        if (ts1<kt1) aux=2;
      }
      // WEAK
      else if (signal_strength==3)
      {
        aux=2;
      }      
    }
  }
  
  // STRATEGY 2: Kijun Sen Cross
  if (strategy==2)
  {
    // BUY SIGNAL
    if (close1>ks1 && close2<ks2)
    {
      // STRONG
      if (signal_strength==1)
      { 
        if (ks1>kt1) aux=1;   
      }
      // NEUTRAL
      else if (signal_strength==2)
      {
        if (ks1>kb1) aux=1;
      }
      // WEAK
      else if (signal_strength==3)
      {
        aux=1;
      }      
    }  
    // SELL SIGNAL
    if (close1<ks1 && close2>ks2)
    {
      // STRONG
      if (signal_strength==1)
      { 
        if (ks1<kb1) aux=2;   
      }
      // NEUTRAL
      else if (signal_strength==2)
      {
        if (ks1<kt1) aux=2;
      }
      // WEAK
      else if (signal_strength==3)
      {
        aux=2;
      }      
    }  
  }
  
  // STRATEGY 3: Kumo Breakout
  if (strategy==3)
  {
    // BUY SIGNAL
    if (close1>kt1 && close2<kt2)
    {
      aux=1;
    }  
    // SELL SIGNAL
    if (close1<kb1 && close2>kb2)
    {
      aux=2;
    }     
  }
   
  return(aux);  
}

// ------------------------------------------------------------------------------------------------
// ROBOT 1
// ------------------------------------------------------------------------------------------------
void Robot1()
{
  int ticket=-1, i;
  bool cerrada=FALSE;  
  
  if (orders1==0 && direction1==0)
  {     
    signal1 = CalculaSignal(1,tenkan_sen,kijun_sen,senkou_span,shift);
    // ----------
    // COMPRA
    // ----------
    if (signal1==1)
      ticket = OrderSendReliable(Symbol(),OP_BUY,CalcularVolumen(1),MarketInfo(Symbol(),MODE_ASK),slippage,0,0,key1,magic1,0,Blue); 
    // En este punto hemos ejecutado correctamente la orden de compra
    // Los arrays se actualizarán en la siguiente ejecución de start() con ActualizarOrdenes()
     
    // ----------
    // VENTA
    // ----------
    if (signal1==2)
      ticket = OrderSendReliable(Symbol(),OP_SELL,CalcularVolumen(1),MarketInfo(Symbol(),MODE_BID),slippage,0,0,key1,magic1,0,Red);         
    // En este punto hemos ejecutado correctamente la orden de venta
    // Los arrays se actualizarán en la siguiente ejecución de start() con ActualizarOrdenes()       
  }
  
  // **************************************************
  // ORDERS>0 AND DIRECTION=1 AND USE_TP_SL=1
  // **************************************************
  if (orders1>0 && direction1==1 && use_tp_sl==1)
  {
    // CASO 1.1 >>> Tenemos el beneficio y  activamos el profit lock
    if (order_profit1 > CalculaTakeProfit(1) && max_profit1==0)
    {
      max_profit1 = order_profit1;
      close_profit1 = profit_lock*order_profit1;      
    } 
    // CASO 1.2 >>> Segun va aumentando el beneficio actualizamos el profit lock
    if (max_profit1>0)
    {
      if (order_profit1>max_profit1)
      {      
        max_profit1 = order_profit1;
        close_profit1 = profit_lock*order_profit1; 
      }
    }   
    // CASO 1.3 >>> Cuando el beneficio caiga por debajo de profit lock cerramos las ordenes
    if (max_profit1>0 && close_profit1>0 && max_profit1>close_profit1 && order_profit1<close_profit1) 
    {
      cerrada=OrderCloseReliable(order_ticket1,order_lots1,MarketInfo(Symbol(),MODE_BID),slippage,Blue);
      max_profit1=0;
      close_profit1=0;  
    }
      
    // CASO 2 >>> Tenemos "size" pips de perdida
    if (order_profit1 <= CalculaStopLoss(1))
    {
      cerrada=OrderCloseReliable(order_ticket1,order_lots1,MarketInfo(Symbol(),MODE_BID),slippage,Blue);
      max_profit1=0;
      close_profit1=0;  
    }   
    
  }
    
  // **************************************************
  // ORDERS>0 AND DIRECTION=2 AND USE_TP_SL=1
  // **************************************************
  if (orders1>0 && direction1==2 && use_tp_sl==1)
  {
    // CASO 1.1 >>> Tenemos el beneficio y  activamos el profit lock
    if (order_profit1 > CalculaTakeProfit(1) && max_profit1==0)
    {
      max_profit1 = order_profit1;
      close_profit1 = profit_lock*order_profit1;      
    } 
    // CASO 1.2 >>> Segun va aumentando el beneficio actualizamos el profit lock
    if (max_profit1>0)
    {
      if (order_profit1>max_profit1)
      {      
        max_profit1 = order_profit1;
        close_profit1 = profit_lock*order_profit1; 
      }
    }   
    // CASO 1.3 >>> Cuando el beneficio caiga por debajo de profit lock cerramos las ordenes
    if (max_profit1>0 && close_profit1>0 && max_profit1>close_profit1 && order_profit1<close_profit1) 
    {
      cerrada=OrderCloseReliable(order_ticket1,order_lots1,MarketInfo(Symbol(),MODE_ASK),slippage,Red);
      max_profit1=0;
      close_profit1=0;  
    }
      
    // CASO 2 >>> Tenemos "size" pips de perdida
    if (order_profit1 <= CalculaStopLoss(1))
    {
      cerrada=OrderCloseReliable(order_ticket1,order_lots1,MarketInfo(Symbol(),MODE_ASK),slippage,Red);
      max_profit1=0;
      close_profit1=0;  
    }   
  }
  
  // **************************************************
  // ORDERS>0 AND DIRECTION=1 AND USE_TP_SL=0
  // **************************************************
  if (orders1>0 && direction1==1 && use_tp_sl==0)
  {
    signal1 = CalculaSignal(1,tenkan_sen,kijun_sen,senkou_span,shift);
    if (signal1==2)
    {
      cerrada=OrderCloseReliable(order_ticket1,order_lots1,MarketInfo(Symbol(),MODE_BID),slippage,Blue);
      max_profit1=0;
      close_profit1=0;    
    }  
  }
    
  // **************************************************
  // ORDERS>0 AND DIRECTION=2 AND USE_TP_SL=0
  // **************************************************
  if (orders1>0 && direction1==2 && use_tp_sl==0)
  {
    signal1 = CalculaSignal(1,tenkan_sen,kijun_sen,senkou_span,shift);
    if (signal1==1)
    {
      cerrada=OrderCloseReliable(order_ticket1,order_lots1,MarketInfo(Symbol(),MODE_ASK),slippage,Red);
      max_profit1=0;
      close_profit1=0;   
    }  
  }    
    
}

// ------------------------------------------------------------------------------------------------
// ROBOT
// ------------------------------------------------------------------------------------------------
void Robot2()
{
  int ticket=-1, i;
  bool cerrada=FALSE;  
  
  if (orders2==0 && direction2==0)
  {     
    signal2 = CalculaSignal(2,tenkan_sen,kijun_sen,senkou_span,shift);
    // ----------
    // COMPRA
    // ----------
    if (signal2==1)
      ticket = OrderSendReliable(Symbol(),OP_BUY,CalcularVolumen(2),MarketInfo(Symbol(),MODE_ASK),slippage,0,0,key2,magic2,0,Blue); 
    // En este punto hemos ejecutado correctamente la orden de compra
    // Los arrays se actualizarán en la siguiente ejecución de start() con ActualizarOrdenes()
     
    // ----------
    // VENTA
    // ----------
    if (signal2==2)
      ticket = OrderSendReliable(Symbol(),OP_SELL,CalcularVolumen(2),MarketInfo(Symbol(),MODE_BID),slippage,0,0,key2,magic2,0,Red);         
    // En este punto hemos ejecutado correctamente la orden de venta
    // Los arrays se actualizarán en la siguiente ejecución de start() con ActualizarOrdenes()       
  }
  
  // **************************************************
  // ORDERS>0 AND DIRECTION=1 AND USE_TP_SL=1
  // **************************************************
  if (orders2>0 && direction2==1 && use_tp_sl==1)
  {
    // CASO 1.1 >>> Tenemos el beneficio y  activamos el profit lock
    if (order_profit2 > CalculaTakeProfit(2) && max_profit2==0)
    {
      max_profit2 = order_profit2;
      close_profit2 = profit_lock*order_profit2;      
    } 
    // CASO 1.2 >>> Segun va aumentando el beneficio actualizamos el profit lock
    if (max_profit2>0)
    {
      if (order_profit2>max_profit2)
      {      
        max_profit2 = order_profit2;
        close_profit2 = profit_lock*order_profit2; 
      }
    }   
    // CASO 1.3 >>> Cuando el beneficio caiga por debajo de profit lock cerramos las ordenes
    if (max_profit2>0 && close_profit2>0 && max_profit2>close_profit2 && order_profit2<close_profit2) 
    {
      cerrada=OrderCloseReliable(order_ticket2,order_lots2,MarketInfo(Symbol(),MODE_BID),slippage,Blue);
      max_profit2=0;
      close_profit2=0;  
    }
      
    // CASO 2 >>> Tenemos "size" pips de perdida
    if (order_profit2 <= CalculaStopLoss(2))
    {
      cerrada=OrderCloseReliable(order_ticket2,order_lots2,MarketInfo(Symbol(),MODE_BID),slippage,Blue);
      max_profit2=0;
      close_profit2=0;  
    }   
    
  }
    
  // **************************************************
  // ORDERS>0 AND DIRECTION=2 AND USE_TP_SL=1
  // **************************************************
  if (orders2>0 && direction2==2 && use_tp_sl==1)
  {
    // CASO 1.1 >>> Tenemos el beneficio y  activamos el profit lock
    if (order_profit2 > CalculaTakeProfit(2) && max_profit2==0)
    {
      max_profit2 = order_profit2;
      close_profit2 = profit_lock*order_profit2;      
    } 
    // CASO 1.2 >>> Segun va aumentando el beneficio actualizamos el profit lock
    if (max_profit2>0)
    {
      if (order_profit2>max_profit2)
      {      
        max_profit2 = order_profit2;
        close_profit2 = profit_lock*order_profit2; 
      }
    }   
    // CASO 1.3 >>> Cuando el beneficio caiga por debajo de profit lock cerramos las ordenes
    if (max_profit2>0 && close_profit2>0 && max_profit2>close_profit2 && order_profit2<close_profit2) 
    {
      cerrada=OrderCloseReliable(order_ticket2,order_lots2,MarketInfo(Symbol(),MODE_ASK),slippage,Red);
      max_profit2=0;
      close_profit2=0;  
    }
      
    // CASO 2 >>> Tenemos "size" pips de perdida
    if (order_profit2 <= CalculaStopLoss(2))
    {
      cerrada=OrderCloseReliable(order_ticket2,order_lots2,MarketInfo(Symbol(),MODE_ASK),slippage,Red);
      max_profit2=0;
      close_profit2=0;  
    }   
  }
  
  // **************************************************
  // ORDERS>0 AND DIRECTION=1 AND USE_TP_SL=0
  // **************************************************
  if (orders2 && direction2==1 && use_tp_sl==0)
  {
    signal2 = CalculaSignal(2,tenkan_sen,kijun_sen,senkou_span,shift);
    if (signal2==2)
    {
      cerrada=OrderCloseReliable(order_ticket2,order_lots2,MarketInfo(Symbol(),MODE_BID),slippage,Blue);
      max_profit2=0;
      close_profit2=0;    
    }  
  }
    
  // **************************************************
  // ORDERS>0 AND DIRECTION=2 AND USE_TP_SL=0
  // **************************************************
  if (orders2>0 && direction2==2 && use_tp_sl==0)
  {
    signal2 = CalculaSignal(2,tenkan_sen,kijun_sen,senkou_span,shift);
    if (signal2==1)
    {
      cerrada=OrderCloseReliable(order_ticket2,order_lots2,MarketInfo(Symbol(),MODE_ASK),slippage,Red);
      max_profit2=0;
      close_profit2=0;   
    }  
  }    
    
}

// ------------------------------------------------------------------------------------------------
// ROBOT 3
// ------------------------------------------------------------------------------------------------
void Robot3()
{
  int ticket=-1, i;
  bool cerrada=FALSE;  
  
  if (orders3==0 && direction3==0)
  {     
    signal3 = CalculaSignal(3,tenkan_sen,kijun_sen,senkou_span,shift);
    // ----------
    // COMPRA
    // ----------
    if (signal3==1)
      ticket = OrderSendReliable(Symbol(),OP_BUY,CalcularVolumen(3),MarketInfo(Symbol(),MODE_ASK),slippage,0,0,key3,magic3,0,Blue); 
    // En este punto hemos ejecutado correctamente la orden de compra
    // Los arrays se actualizarán en la siguiente ejecución de start() con ActualizarOrdenes()
     
    // ----------
    // VENTA
    // ----------
    if (signal3==2)
      ticket = OrderSendReliable(Symbol(),OP_SELL,CalcularVolumen(3),MarketInfo(Symbol(),MODE_BID),slippage,0,0,key3,magic3,0,Red);         
    // En este punto hemos ejecutado correctamente la orden de venta
    // Los arrays se actualizarán en la siguiente ejecución de start() con ActualizarOrdenes()       
  }
  
  // **************************************************
  // ORDERS>0 AND DIRECTION=1 AND USE_TP_SL=1
  // **************************************************
  if (orders3>0 && direction3==1 && use_tp_sl==1)
  {
    // CASO 1.1 >>> Tenemos el beneficio y  activamos el profit lock
    if (order_profit3 > CalculaTakeProfit(3) && max_profit3==0)
    {
      max_profit3 = order_profit3;
      close_profit3 = profit_lock*order_profit3;      
    } 
    // CASO 1.2 >>> Segun va aumentando el beneficio actualizamos el profit lock
    if (max_profit3>0)
    {
      if (order_profit3>max_profit3)
      {      
        max_profit3 = order_profit3;
        close_profit3 = profit_lock*order_profit3; 
      }
    }   
    // CASO 1.3 >>> Cuando el beneficio caiga por debajo de profit lock cerramos las ordenes
    if (max_profit3>0 && close_profit3>0 && max_profit3>close_profit3 && order_profit3<close_profit3) 
    {
      cerrada=OrderCloseReliable(order_ticket3,order_lots3,MarketInfo(Symbol(),MODE_BID),slippage,Blue);
      max_profit3=0;
      close_profit3=0;  
    }
      
    // CASO 2 >>> Tenemos "size" pips de perdida
    if (order_profit3 <= CalculaStopLoss(3))
    {
      cerrada=OrderCloseReliable(order_ticket3,order_lots3,MarketInfo(Symbol(),MODE_BID),slippage,Blue);
      max_profit3=0;
      close_profit3=0;  
    }   
    
  }
    
  // **************************************************
  // ORDERS>0 AND DIRECTION=2 AND USE_TP_SL=1
  // **************************************************
  if (orders3>0 && direction3==2 && use_tp_sl==1)
  {
    // CASO 1.1 >>> Tenemos el beneficio y  activamos el profit lock
    if (order_profit3 > CalculaTakeProfit(3) && max_profit3==0)
    {
      max_profit3 = order_profit3;
      close_profit3 = profit_lock*order_profit3;      
    } 
    // CASO 1.2 >>> Segun va aumentando el beneficio actualizamos el profit lock
    if (max_profit3>0)
    {
      if (order_profit3>max_profit3)
      {      
        max_profit3 = order_profit3;
        close_profit3 = profit_lock*order_profit3; 
      }
    }   
    // CASO 1.3 >>> Cuando el beneficio caiga por debajo de profit lock cerramos las ordenes
    if (max_profit3>0 && close_profit3>0 && max_profit3>close_profit3 && order_profit3<close_profit3) 
    {
      cerrada=OrderCloseReliable(order_ticket3,order_lots3,MarketInfo(Symbol(),MODE_ASK),slippage,Red);
      max_profit3=0;
      close_profit3=0;  
    }
      
    // CASO 2 >>> Tenemos "size" pips de perdida
    if (order_profit3 <= CalculaStopLoss(3))
    {
      cerrada=OrderCloseReliable(order_ticket3,order_lots3,MarketInfo(Symbol(),MODE_ASK),slippage,Red);
      max_profit3=0;
      close_profit3=0;  
    }   
  }
  
  // **************************************************
  // ORDERS>0 AND DIRECTION=1 AND USE_TP_SL=0
  // **************************************************
  if (orders3>0 && direction3==1 && use_tp_sl==0)
  {
    signal3 = CalculaSignal(3,tenkan_sen,kijun_sen,senkou_span,shift);
    if (signal3==2)
    {
      cerrada=OrderCloseReliable(order_ticket3,order_lots3,MarketInfo(Symbol(),MODE_BID),slippage,Blue);
      max_profit3=0;
      close_profit3=0;    
    }  
  }
    
  // **************************************************
  // ORDERS>0 AND DIRECTION=2 AND USE_TP_SL=0
  // **************************************************
  if (orders3>0 && direction3==2 && use_tp_sl==0)
  {
    signal3 = CalculaSignal(3,tenkan_sen,kijun_sen,senkou_span,shift);
    if (signal3==1)
    {
      cerrada=OrderCloseReliable(order_ticket3,order_lots3,MarketInfo(Symbol(),MODE_ASK),slippage,Red);
      max_profit3=0;
      close_profit3=0;   
    }  
  }    
    
}


//=============================================================================
//							 OrderSendReliable()
//
//	This is intended to be a drop-in replacement for OrderSend() which, 
//	one hopes, is more resistant to various forms of errors prevalent 
//	with MetaTrader.
//			  
//	RETURN VALUE: 
//
//	Ticket number or -1 under some error conditions.  Check
// final error returned by Metatrader with OrderReliableLastErr().
// This will reset the value from GetLastError(), so in that sense it cannot
// be a total drop-in replacement due to Metatrader flaw. 
//
//	FEATURES:
//
//		 * Re-trying under some error conditions, sleeping a random 
//		   time defined by an exponential probability distribution.
//
//		 * Automatic normalization of Digits
//
//		 * Automatically makes sure that stop levels are more than
//		   the minimum stop distance, as given by the server. If they
//		   are too close, they are adjusted.
//
//		 * Automatically converts stop orders to market orders 
//		   when the stop orders are rejected by the server for 
//		   being to close to market.  NOTE: This intentionally
//       applies only to OP_BUYSTOP and OP_SELLSTOP, 
//       OP_BUYLIMIT and OP_SELLLIMIT are not converted to market
//       orders and so for prices which are too close to current
//       this function is likely to loop a few times and return
//       with the "invalid stops" error message. 
//       Note, the commentary in previous versions erroneously said
//       that limit orders would be converted.  Note also
//       that entering a BUYSTOP or SELLSTOP new order is distinct
//       from setting a stoploss on an outstanding order; use
//       OrderModifyReliable() for that. 
//
//		 * Displays various error messages on the log for debugging.
//
//
//	Matt Kennel, 2006-05-28 and following
//
//=============================================================================
int OrderSendReliable(string symbol, int cmd, double volume, double price,
					  int slippage, double stoploss, double takeprofit,
					  string comment, int magic, datetime expiration = 0, 
					  color arrow_color = CLR_NONE) 
{

	// ------------------------------------------------
	// Check basic conditions see if trade is possible. 
	// ------------------------------------------------
	OrderReliable_Fname = "OrderSendReliable";
	OrderReliablePrint(" attempted " + OrderReliable_CommandString(cmd) + " " + volume + 
						" lots @" + price + " sl:" + stoploss + " tp:" + takeprofit); 
						
	//if (!IsConnected()) 
	//{
	//	OrderReliablePrint("error: IsConnected() == false");
	//	_OR_err = ERR_NO_CONNECTION; 
	//	return(-1);
	//}
	
	if (IsStopped()) 
	{
		OrderReliablePrint("error: IsStopped() == true");
		_OR_err = ERR_COMMON_ERROR; 
		return(-1);
	}
	
	int cnt = 0;
	while(!IsTradeAllowed() && cnt < retry_attempts) 
	{
		OrderReliable_SleepRandomTime(sleep_time, sleep_maximum); 
		cnt++;
	}
	
	if (!IsTradeAllowed()) 
	{
		OrderReliablePrint("error: no operation possible because IsTradeAllowed()==false, even after retries.");
		_OR_err = ERR_TRADE_CONTEXT_BUSY; 

		return(-1);  
	}

	// Normalize all price / stoploss / takeprofit to the proper # of digits.
	int digits = MarketInfo(symbol, MODE_DIGITS);
	if (digits > 0) 
	{
		price = NormalizeDouble(price, digits);
		stoploss = NormalizeDouble(stoploss, digits);
		takeprofit = NormalizeDouble(takeprofit, digits); 
	}
	
	if (stoploss != 0) 
		OrderReliable_EnsureValidStop(symbol, price, stoploss); 

	int err = GetLastError(); // clear the global variable.  
	err = 0; 
	_OR_err = 0; 
	bool exit_loop = false;
	bool limit_to_market = false; 
	
	// limit/stop order. 
	int ticket=-1;

	if ((cmd == OP_BUYSTOP) || (cmd == OP_SELLSTOP) || (cmd == OP_BUYLIMIT) || (cmd == OP_SELLLIMIT)) 
	{
		cnt = 0;
		while (!exit_loop) 
		{
			if (IsTradeAllowed()) 
			{
				ticket = OrderSend(symbol, cmd, volume, price, slippage, stoploss, 
									takeprofit, comment, magic, expiration, arrow_color);
				err = GetLastError();
				_OR_err = err; 
			} 
			else 
			{
				cnt++;
			} 
			
			switch (err) 
			{
				case ERR_NO_ERROR:
					exit_loop = true;
					break;
				
				// retryable errors
				case ERR_SERVER_BUSY:
				case ERR_NO_CONNECTION:
				case ERR_INVALID_PRICE:
				case ERR_OFF_QUOTES:
				case ERR_BROKER_BUSY:
				case ERR_TRADE_CONTEXT_BUSY: 
					cnt++; 
					break;
					
				case ERR_PRICE_CHANGED:
				case ERR_REQUOTE:
					RefreshRates();
					continue;	// we can apparently retry immediately according to MT docs.
					
				case ERR_INVALID_STOPS:
					double servers_min_stop = MarketInfo(symbol, MODE_STOPLEVEL) * MarketInfo(symbol, MODE_POINT); 
					if (cmd == OP_BUYSTOP) 
					{
						// If we are too close to put in a limit/stop order so go to market.
						if (MathAbs(MarketInfo(symbol,MODE_ASK) - price) <= servers_min_stop)	
							limit_to_market = true; 
							
					} 
					else if (cmd == OP_SELLSTOP) 
					{
						// If we are too close to put in a limit/stop order so go to market.
						if (MathAbs(MarketInfo(symbol,MODE_BID) - price) <= servers_min_stop)
							limit_to_market = true; 
					}
					exit_loop = true; 
					break; 
					
				default:
					// an apparently serious error.
					exit_loop = true;
					break; 
					
			}  // end switch 

			if (cnt > retry_attempts) 
				exit_loop = true; 
			 	
			if (exit_loop) 
			{
				if (err != ERR_NO_ERROR) 
				{
					OrderReliablePrint("non-retryable error: " + OrderReliableErrTxt(err)); 
				}
				if (cnt > retry_attempts) 
				{
					OrderReliablePrint("retry attempts maxed at " + retry_attempts); 
				}
			}
			 
			if (!exit_loop) 
			{
				OrderReliablePrint("retryable error (" + cnt + "/" + retry_attempts + 
									"): " + OrderReliableErrTxt(err)); 
				OrderReliable_SleepRandomTime(sleep_time, sleep_maximum); 
				RefreshRates(); 
			}
		}
		 
		// We have now exited from loop. 
		if (err == ERR_NO_ERROR) 
		{
			OrderReliablePrint("apparently successful OP_BUYSTOP or OP_SELLSTOP order placed, details follow.");
			OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES); 
			OrderPrint(); 
			return(ticket); // SUCCESS! 
		} 
		if (!limit_to_market) 
		{
			OrderReliablePrint("failed to execute stop or limit order after " + cnt + " retries");
			OrderReliablePrint("failed trade: " + OrderReliable_CommandString(cmd) + " " + symbol + 
								"@" + price + " tp@" + takeprofit + " sl@" + stoploss); 
			OrderReliablePrint("last error: " + OrderReliableErrTxt(err)); 
			return(-1); 
		}
	}  // end	  
  
	if (limit_to_market) 
	{
		OrderReliablePrint("going from limit order to market order because market is too close.");
		if ((cmd == OP_BUYSTOP) || (cmd == OP_BUYLIMIT)) 
		{
			cmd = OP_BUY;
			price = MarketInfo(symbol,MODE_ASK);
		} 
		else if ((cmd == OP_SELLSTOP) || (cmd == OP_SELLLIMIT)) 
		{
			cmd = OP_SELL;
			price = MarketInfo(symbol,MODE_BID);
		}	
	}
	
	// we now have a market order.
	err = GetLastError(); // so we clear the global variable.  
	err = 0; 
	_OR_err = 0; 
	ticket = -1;

	if ((cmd == OP_BUY) || (cmd == OP_SELL)) 
	{
		cnt = 0;
		while (!exit_loop) 
		{
			if (IsTradeAllowed()) 
			{
				ticket = OrderSend(symbol, cmd, volume, price, slippage, 
									stoploss, takeprofit, comment, magic, 
									expiration, arrow_color);
				err = GetLastError();
				_OR_err = err; 
			} 
			else 
			{
				cnt++;
			} 
			switch (err) 
			{
				case ERR_NO_ERROR:
					exit_loop = true;
					break;
					
				case ERR_SERVER_BUSY:
				case ERR_NO_CONNECTION:
				case ERR_INVALID_PRICE:
				case ERR_OFF_QUOTES:
				case ERR_BROKER_BUSY:
				case ERR_TRADE_CONTEXT_BUSY: 
					cnt++; // a retryable error
					break;
					
				case ERR_PRICE_CHANGED:
				case ERR_REQUOTE:
					RefreshRates();
					continue; // we can apparently retry immediately according to MT docs.
					
				default:
					// an apparently serious, unretryable error.
					exit_loop = true;
					break; 
					
			}  // end switch 

			if (cnt > retry_attempts) 
			 	exit_loop = true; 
			 	
			if (!exit_loop) 
			{
				OrderReliablePrint("retryable error (" + cnt + "/" + 
									retry_attempts + "): " + OrderReliableErrTxt(err)); 
				OrderReliable_SleepRandomTime(sleep_time,sleep_maximum); 
				RefreshRates(); 
			}
			
			if (exit_loop) 
			{
				if (err != ERR_NO_ERROR) 
				{
					OrderReliablePrint("non-retryable error: " + OrderReliableErrTxt(err)); 
				}
				if (cnt > retry_attempts) 
				{
					OrderReliablePrint("retry attempts maxed at " + retry_attempts); 
				}
			}
		}
		
		// we have now exited from loop. 
		if (err == ERR_NO_ERROR) 
		{
			OrderReliablePrint("apparently successful OP_BUY or OP_SELL order placed, details follow.");
			OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES); 
			OrderPrint(); 
			return(ticket); // SUCCESS! 
		} 
		OrderReliablePrint("failed to execute OP_BUY/OP_SELL, after " + cnt + " retries");
		OrderReliablePrint("failed trade: " + OrderReliable_CommandString(cmd) + " " + symbol + 
							"@" + price + " tp@" + takeprofit + " sl@" + stoploss); 
		OrderReliablePrint("last error: " + OrderReliableErrTxt(err)); 
		return(-1); 
	}
}
	
//=============================================================================
//							 OrderSendReliableMKT()
//
//	This is intended to be an alternative for OrderSendReliable() which
// will update market-orders in the retry loop with the current Bid or Ask.
// Hence with market orders there is a greater likelihood that the trade will
// be executed versus OrderSendReliable(), and a greater likelihood it will
// be executed at a price worse than the entry price due to price movement. 
//			  
//	RETURN VALUE: 
//
//	Ticket number or -1 under some error conditions.  Check
// final error returned by Metatrader with OrderReliableLastErr().
// This will reset the value from GetLastError(), so in that sense it cannot
// be a total drop-in replacement due to Metatrader flaw. 
//
//	FEATURES:
//
//     * Most features of OrderSendReliable() but for market orders only. 
//       Command must be OP_BUY or OP_SELL, and specify Bid or Ask at
//       the time of the call.
//
//     * If price moves in an unfavorable direction during the loop,
//       e.g. from requotes, then the slippage variable it uses in 
//       the real attempt to the server will be decremented from the passed
//       value by that amount, down to a minimum of zero.   If the current
//       price is too far from the entry value minus slippage then it
//       will not attempt an order, and it will signal, manually,
//       an ERR_INVALID_PRICE (displayed to log as usual) and will continue
//       to loop the usual number of times. 
//
//		 * Displays various error messages on the log for debugging.
//
//
//	Matt Kennel, 2006-08-16
//
//=============================================================================
int OrderSendReliableMKT(string symbol, int cmd, double volume, double price,
					  int slippage, double stoploss, double takeprofit,
					  string comment, int magic, datetime expiration = 0, 
					  color arrow_color = CLR_NONE) 
{

	// ------------------------------------------------
	// Check basic conditions see if trade is possible. 
	// ------------------------------------------------
	OrderReliable_Fname = "OrderSendReliableMKT";
	OrderReliablePrint(" attempted " + OrderReliable_CommandString(cmd) + " " + volume + 
						" lots @" + price + " sl:" + stoploss + " tp:" + takeprofit); 

   if ((cmd != OP_BUY) && (cmd != OP_SELL)) {
      OrderReliablePrint("Improper non market-order command passed.  Nothing done.");
      _OR_err = ERR_MALFUNCTIONAL_TRADE; 
      return(-1);
   }

	//if (!IsConnected()) 
	//{
	//	OrderReliablePrint("error: IsConnected() == false");
	//	_OR_err = ERR_NO_CONNECTION; 
	//	return(-1);
	//}
	
	if (IsStopped()) 
	{
		OrderReliablePrint("error: IsStopped() == true");
		_OR_err = ERR_COMMON_ERROR; 
		return(-1);
	}
	
	int cnt = 0;
	while(!IsTradeAllowed() && cnt < retry_attempts) 
	{
		OrderReliable_SleepRandomTime(sleep_time, sleep_maximum); 
		cnt++;
	}
	
	if (!IsTradeAllowed()) 
	{
		OrderReliablePrint("error: no operation possible because IsTradeAllowed()==false, even after retries.");
		_OR_err = ERR_TRADE_CONTEXT_BUSY; 

		return(-1);  
	}

	// Normalize all price / stoploss / takeprofit to the proper # of digits.
	int digits = MarketInfo(symbol, MODE_DIGITS);
	if (digits > 0) 
	{
		price = NormalizeDouble(price, digits);
		stoploss = NormalizeDouble(stoploss, digits);
		takeprofit = NormalizeDouble(takeprofit, digits); 
	}
	
	if (stoploss != 0) 
		OrderReliable_EnsureValidStop(symbol, price, stoploss); 

	int err = GetLastError(); // clear the global variable.  
	err = 0; 
	_OR_err = 0; 
	bool exit_loop = false;
	
	// limit/stop order. 
	int ticket=-1;

	// we now have a market order.
	err = GetLastError(); // so we clear the global variable.  
	err = 0; 
	_OR_err = 0; 
	ticket = -1;

	if ((cmd == OP_BUY) || (cmd == OP_SELL)) 
	{
		cnt = 0;
		while (!exit_loop) 
		{
			if (IsTradeAllowed()) 
			{
            double pnow = price;
            int slippagenow = slippage;
            if (cmd == OP_BUY) {
            	// modification by Paul Hampton-Smith to replace RefreshRates()
               pnow = NormalizeDouble(MarketInfo(symbol,MODE_ASK),MarketInfo(symbol,MODE_DIGITS)); // we are buying at Ask
               if (pnow > price) {
                  slippagenow = slippage - (pnow-price)/MarketInfo(symbol,MODE_POINT); 
               }
            } else if (cmd == OP_SELL) {
            	// modification by Paul Hampton-Smith to replace RefreshRates()
               pnow = NormalizeDouble(MarketInfo(symbol,MODE_BID),MarketInfo(symbol,MODE_DIGITS)); // we are buying at Ask
               if (pnow < price) {
                  // moved in an unfavorable direction
                  slippagenow = slippage - (price-pnow)/MarketInfo(symbol,MODE_POINT);
               }
            }
            if (slippagenow > slippage) slippagenow = slippage; 
            if (slippagenow >= 0) {
            
				   ticket = OrderSend(symbol, cmd, volume, pnow, slippagenow, 
									stoploss, takeprofit, comment, magic, 
									expiration, arrow_color);
			   	err = GetLastError();
			   	_OR_err = err; 
			  } else {
			      // too far away, manually signal ERR_INVALID_PRICE, which
			      // will result in a sleep and a retry. 
			      err = ERR_INVALID_PRICE;
			      _OR_err = err; 
			  }
			} 
			else 
			{
				cnt++;
			} 
			switch (err) 
			{
				case ERR_NO_ERROR:
					exit_loop = true;
					break;
					
				case ERR_SERVER_BUSY:
				case ERR_NO_CONNECTION:
				case ERR_INVALID_PRICE:
				case ERR_OFF_QUOTES:
				case ERR_BROKER_BUSY:
				case ERR_TRADE_CONTEXT_BUSY: 
					cnt++; // a retryable error
					break;
					
				case ERR_PRICE_CHANGED:
				case ERR_REQUOTE:
					// Paul Hampton-Smith removed RefreshRates() here and used MarketInfo() above instead
					continue; // we can apparently retry immediately according to MT docs.
					
				default:
					// an apparently serious, unretryable error.
					exit_loop = true;
					break; 
					
			}  // end switch 

			if (cnt > retry_attempts) 
			 	exit_loop = true; 
			 	
			if (!exit_loop) 
			{
				OrderReliablePrint("retryable error (" + cnt + "/" + 
									retry_attempts + "): " + OrderReliableErrTxt(err)); 
				OrderReliable_SleepRandomTime(sleep_time,sleep_maximum); 
			}
			
			if (exit_loop) 
			{
				if (err != ERR_NO_ERROR) 
				{
					OrderReliablePrint("non-retryable error: " + OrderReliableErrTxt(err)); 
				}
				if (cnt > retry_attempts) 
				{
					OrderReliablePrint("retry attempts maxed at " + retry_attempts); 
				}
			}
		}
		
		// we have now exited from loop. 
		if (err == ERR_NO_ERROR) 
		{
			OrderReliablePrint("apparently successful OP_BUY or OP_SELL order placed, details follow.");
			OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES); 
			OrderPrint(); 
			return(ticket); // SUCCESS! 
		} 
		OrderReliablePrint("failed to execute OP_BUY/OP_SELL, after " + cnt + " retries");
		OrderReliablePrint("failed trade: " + OrderReliable_CommandString(cmd) + " " + symbol + 
							"@" + price + " tp@" + takeprofit + " sl@" + stoploss); 
		OrderReliablePrint("last error: " + OrderReliableErrTxt(err)); 
		return(-1); 
	}
}
		
	
//=============================================================================
//							 OrderModifyReliable()
//
//	This is intended to be a drop-in replacement for OrderModify() which, 
//	one hopes, is more resistant to various forms of errors prevalent 
//	with MetaTrader.
//			  
//	RETURN VALUE: 
//
//		TRUE if successful, FALSE otherwise
//
//
//	FEATURES:
//
//		 * Re-trying under some error conditions, sleeping a random 
//		   time defined by an exponential probability distribution.
//
//		 * Displays various error messages on the log for debugging.
//
//
//	Matt Kennel, 	2006-05-28
//
//=============================================================================
bool OrderModifyReliable(int ticket, double price, double stoploss, 
						 double takeprofit, datetime expiration, 
						 color arrow_color = CLR_NONE) 
{
	OrderReliable_Fname = "OrderModifyReliable";

	OrderReliablePrint(" attempted modify of #" + ticket + " price:" + price + 
						" sl:" + stoploss + " tp:" + takeprofit); 

	//if (!IsConnected()) 
	//{
	//	OrderReliablePrint("error: IsConnected() == false");
	//	_OR_err = ERR_NO_CONNECTION; 
	//	return(false);
	//}
	
	if (IsStopped()) 
	{
		OrderReliablePrint("error: IsStopped() == true");
		return(false);
	}
	
	int cnt = 0;
	while(!IsTradeAllowed() && cnt < retry_attempts) 
	{
		OrderReliable_SleepRandomTime(sleep_time,sleep_maximum); 
		cnt++;
	}
	if (!IsTradeAllowed()) 
	{
		OrderReliablePrint("error: no operation possible because IsTradeAllowed()==false, even after retries.");
		_OR_err = ERR_TRADE_CONTEXT_BUSY; 
		return(false);  
	}


	
	if (false) {
		 // This section is 'nulled out', because
		 // it would have to involve an 'OrderSelect()' to obtain
		 // the symbol string, and that would change the global context of the
		 // existing OrderSelect, and hence would not be a drop-in replacement
		 // for OrderModify().
		 //
		 // See OrderModifyReliableSymbol() where the user passes in the Symbol 
		 // manually.
		 
		 OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES);
		 string symbol = OrderSymbol();
		 int digits = MarketInfo(symbol,MODE_DIGITS);
		 if (digits > 0) {
			 price = NormalizeDouble(price,digits);
			 stoploss = NormalizeDouble(stoploss,digits);
			 takeprofit = NormalizeDouble(takeprofit,digits); 
		 }
		 if (stoploss != 0) OrderReliable_EnsureValidStop(symbol,price,stoploss); 
	}



	int err = GetLastError(); // so we clear the global variable.  
	err = 0; 
	_OR_err = 0; 
	bool exit_loop = false;
	cnt = 0;
	bool result = false;
	
	while (!exit_loop) 
	{
		if (IsTradeAllowed()) 
		{
			result = OrderModify(ticket, price, stoploss, 
								 takeprofit, expiration, arrow_color);
			err = GetLastError();
			_OR_err = err; 
		} 
		else 
			cnt++;

		if (result == true) 
			exit_loop = true;

		switch (err) 
		{
			case ERR_NO_ERROR:
				exit_loop = true;
				break;
				
			case ERR_NO_RESULT:
				// modification without changing a parameter. 
				// if you get this then you may want to change the code.
				exit_loop = true;
				break;
				
			case ERR_SERVER_BUSY:
			case ERR_NO_CONNECTION:
			case ERR_INVALID_PRICE:
			case ERR_OFF_QUOTES:
			case ERR_BROKER_BUSY:
			case ERR_TRADE_CONTEXT_BUSY: 
			case ERR_TRADE_TIMEOUT:		// for modify this is a retryable error, I hope. 
				cnt++; 	// a retryable error
				break;
				
			case ERR_PRICE_CHANGED:
			case ERR_REQUOTE:
				RefreshRates();
				continue; 	// we can apparently retry immediately according to MT docs.
				
			default:
				// an apparently serious, unretryable error.
				exit_loop = true;
				break; 
				
		}  // end switch 

		if (cnt > retry_attempts) 
			exit_loop = true; 
			
		if (!exit_loop) 
		{
			OrderReliablePrint("retryable error (" + cnt + "/" + retry_attempts + 
								"): "  +  OrderReliableErrTxt(err)); 
			OrderReliable_SleepRandomTime(sleep_time,sleep_maximum); 
			RefreshRates(); 
		}
		
		if (exit_loop) 
		{
			if ((err != ERR_NO_ERROR) && (err != ERR_NO_RESULT)) 
				OrderReliablePrint("non-retryable error: "  + OrderReliableErrTxt(err)); 

			if (cnt > retry_attempts) 
				OrderReliablePrint("retry attempts maxed at " + retry_attempts); 
		}
	}  
	
	// we have now exited from loop. 
	if ((result == true) || (err == ERR_NO_ERROR)) 
	{
		OrderReliablePrint("apparently successful modification order, updated trade details follow.");
		OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES); 
		OrderPrint(); 
		return(true); // SUCCESS! 
	} 
	
	if (err == ERR_NO_RESULT) 
	{
		OrderReliablePrint("Server reported modify order did not actually change parameters.");
		OrderReliablePrint("redundant modification: "  + ticket + " " + symbol + 
							"@" + price + " tp@" + takeprofit + " sl@" + stoploss); 
		OrderReliablePrint("Suggest modifying code logic to avoid."); 
		return(true);
	}
	
	OrderReliablePrint("failed to execute modify after " + cnt + " retries");
	OrderReliablePrint("failed modification: "  + ticket + " " + symbol + 
						"@" + price + " tp@" + takeprofit + " sl@" + stoploss); 
	OrderReliablePrint("last error: " + OrderReliableErrTxt(err)); 
	
	return(false);  
}
 
 
//=============================================================================
//
//						OrderModifyReliableSymbol()
//
//	This has the same calling sequence as OrderModify() except that the 
//	user must provide the symbol.
//
//	This function will then be able to ensure proper normalization and 
//	stop levels.
//
//=============================================================================
bool OrderModifyReliableSymbol(string symbol, int ticket, double price, 
							   double stoploss, double takeprofit, 
							   datetime expiration, color arrow_color = CLR_NONE) 
{
	int digits = MarketInfo(symbol, MODE_DIGITS);
	
	if (digits > 0) 
	{
		price = NormalizeDouble(price, digits);
		stoploss = NormalizeDouble(stoploss, digits);
		takeprofit = NormalizeDouble(takeprofit, digits); 
	}
	
	if (stoploss != 0) 
		OrderReliable_EnsureValidStop(symbol, price, stoploss); 
		
	return(OrderModifyReliable(ticket, price, stoploss, 
								takeprofit, expiration, arrow_color)); 
	
}
 
 
//=============================================================================
//							 OrderCloseReliable()
//
//	This is intended to be a drop-in replacement for OrderClose() which, 
//	one hopes, is more resistant to various forms of errors prevalent 
//	with MetaTrader.
//			  
//	RETURN VALUE: 
//
//		TRUE if successful, FALSE otherwise
//
//
//	FEATURES:
//
//		 * Re-trying under some error conditions, sleeping a random 
//		   time defined by an exponential probability distribution.
//
//		 * Displays various error messages on the log for debugging.
//
//
//	Derk Wehler, ashwoods155@yahoo.com  	2006-07-19
//
//=============================================================================
bool OrderCloseReliable(int ticket, double lots, double price, 
						int slippage, color arrow_color = CLR_NONE) 
{
	int nOrderType;
	string strSymbol;
	OrderReliable_Fname = "OrderCloseReliable";
	
	OrderReliablePrint(" attempted close of #" + ticket + " price:" + price + 
						" lots:" + lots + " slippage:" + slippage); 

// collect details of order so that we can use GetMarketInfo later if needed
	if (!OrderSelect(ticket,SELECT_BY_TICKET))
	{
		_OR_err = GetLastError();		
		OrderReliablePrint("error: " + ErrorDescription(_OR_err));
		return(false);
	}
	else
	{
		nOrderType = OrderType();
		strSymbol = OrderSymbol();
	}

	if (nOrderType != OP_BUY && nOrderType != OP_SELL)
	{
		_OR_err = ERR_INVALID_TICKET;
		OrderReliablePrint("error: trying to close ticket #" + ticket + ", which is " + OrderReliable_CommandString(nOrderType) + ", not OP_BUY or OP_SELL");
		return(false);
	}

	//if (!IsConnected()) 
	//{
	//	OrderReliablePrint("error: IsConnected() == false");
	//	_OR_err = ERR_NO_CONNECTION; 
	//	return(false);
	//}
	
	if (IsStopped()) 
	{
		OrderReliablePrint("error: IsStopped() == true");
		return(false);
	}

	
	int cnt = 0;
/*	
	Commented out by Paul Hampton-Smith due to a bug in MT4 that sometimes incorrectly returns IsTradeAllowed() = false
	while(!IsTradeAllowed() && cnt < retry_attempts) 
	{
		OrderReliable_SleepRandomTime(sleep_time,sleep_maximum); 
		cnt++;
	}
	if (!IsTradeAllowed()) 
	{
		OrderReliablePrint("error: no operation possible because IsTradeAllowed()==false, even after retries.");
		_OR_err = ERR_TRADE_CONTEXT_BUSY; 
		return(false);  
	}
*/

	int err = GetLastError(); // so we clear the global variable.  
	err = 0; 
	_OR_err = 0; 
	bool exit_loop = false;
	cnt = 0;
	bool result = false;
	
	while (!exit_loop) 
	{
		if (IsTradeAllowed()) 
		{
			result = OrderClose(ticket, lots, price, slippage, arrow_color);
			err = GetLastError();
			_OR_err = err; 
		} 
		else 
			cnt++;

		if (result == true) 
			exit_loop = true;

		switch (err) 
		{
			case ERR_NO_ERROR:
				exit_loop = true;
				break;
				
			case ERR_SERVER_BUSY:
			case ERR_NO_CONNECTION:
			case ERR_INVALID_PRICE:
			case ERR_OFF_QUOTES:
			case ERR_BROKER_BUSY:
			case ERR_TRADE_CONTEXT_BUSY: 
			case ERR_TRADE_TIMEOUT:		// for modify this is a retryable error, I hope. 
				cnt++; 	// a retryable error
				break;
				
			case ERR_PRICE_CHANGED:
			case ERR_REQUOTE:
				continue; 	// we can apparently retry immediately according to MT docs.
				
			default:
				// an apparently serious, unretryable error.
				exit_loop = true;
				break; 
				
		}  // end switch 

		if (cnt > retry_attempts) 
			exit_loop = true; 
			
		if (!exit_loop) 
		{
			OrderReliablePrint("retryable error (" + cnt + "/" + retry_attempts + 
								"): "  +  OrderReliableErrTxt(err)); 
			OrderReliable_SleepRandomTime(sleep_time,sleep_maximum); 
			// Added by Paul Hampton-Smith to ensure that price is updated for each retry
			if (nOrderType == OP_BUY)  price = NormalizeDouble(MarketInfo(strSymbol,MODE_BID),MarketInfo(strSymbol,MODE_DIGITS));
			if (nOrderType == OP_SELL) price = NormalizeDouble(MarketInfo(strSymbol,MODE_ASK),MarketInfo(strSymbol,MODE_DIGITS));
		}
		
		if (exit_loop) 
		{
			if ((err != ERR_NO_ERROR) && (err != ERR_NO_RESULT)) 
				OrderReliablePrint("non-retryable error: "  + OrderReliableErrTxt(err)); 

			if (cnt > retry_attempts) 
				OrderReliablePrint("retry attempts maxed at " + retry_attempts); 
		}
	}  
	
	// we have now exited from loop. 
	if ((result == true) || (err == ERR_NO_ERROR)) 
	{
		OrderReliablePrint("apparently successful close order, updated trade details follow.");
		OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES); 
		OrderPrint(); 
		return(true); // SUCCESS! 
	} 
	
	OrderReliablePrint("failed to execute close after " + cnt + " retries");
	OrderReliablePrint("failed close: Ticket #" + ticket + ", Price: " + 
						price + ", Slippage: " + slippage); 
	OrderReliablePrint("last error: " + OrderReliableErrTxt(err)); 
	
	return(false);  
}
 
 

//=============================================================================
//=============================================================================
//								Utility Functions
//=============================================================================
//=============================================================================



int OrderReliableLastErr() 
{
	return (_OR_err); 
}


string OrderReliableErrTxt(int err) 
{
	return ("" + err + ":" + ErrorDescription(err)); 
}


void OrderReliablePrint(string s) 
{
	// Print to log prepended with stuff;
	if (!(IsTesting() || IsOptimization())) Print(OrderReliable_Fname + " " + OrderReliableVersion + ":" + s);
}


string OrderReliable_CommandString(int cmd) 
{
	if (cmd == OP_BUY) 
		return("OP_BUY");

	if (cmd == OP_SELL) 
		return("OP_SELL");

	if (cmd == OP_BUYSTOP) 
		return("OP_BUYSTOP");

	if (cmd == OP_SELLSTOP) 
		return("OP_SELLSTOP");

	if (cmd == OP_BUYLIMIT) 
		return("OP_BUYLIMIT");

	if (cmd == OP_SELLLIMIT) 
		return("OP_SELLLIMIT");

	return("(CMD==" + cmd + ")"); 
}


//=============================================================================
//
//						 OrderReliable_EnsureValidStop()
//
// 	Adjust stop loss so that it is legal.
//
//	Matt Kennel 
//
//=============================================================================
void OrderReliable_EnsureValidStop(string symbol, double price, double& sl) 
{
	// Return if no S/L
	if (sl == 0) 
		return;
	
	double servers_min_stop = MarketInfo(symbol, MODE_STOPLEVEL) * MarketInfo(symbol, MODE_POINT); 
	
	if (MathAbs(price - sl) <= servers_min_stop) 
	{
		// we have to adjust the stop.
		if (price > sl)
			sl = price - servers_min_stop;	// we are long
			
		else if (price < sl)
			sl = price + servers_min_stop;	// we are short
			
		else
			OrderReliablePrint("EnsureValidStop: error, passed in price == sl, cannot adjust"); 
			
		sl = NormalizeDouble(sl, MarketInfo(symbol, MODE_DIGITS)); 
	}
}


//=============================================================================
//
//						 OrderReliable_SleepRandomTime()
//
//	This sleeps a random amount of time defined by an exponential 
//	probability distribution. The mean time, in Seconds is given 
//	in 'mean_time'.
//
//	This is the back-off strategy used by Ethernet.  This will 
//	quantize in tenths of seconds, so don't call this with a too 
//	small a number.  This returns immediately if we are backtesting
//	and does not sleep.
//
//	Matt Kennel mbkennelfx@gmail.com.
//
//=============================================================================
void OrderReliable_SleepRandomTime(double mean_time, double max_time) 
{
	if (IsTesting()) 
		return; 	// return immediately if backtesting.

	double tenths = MathCeil(mean_time / 0.1);
	if (tenths <= 0) 
		return; 
	 
	int maxtenths = MathRound(max_time/0.1); 
	double p = 1.0 - 1.0 / tenths; 
	  
	Sleep(100); 	// one tenth of a second PREVIOUS VERSIONS WERE STUPID HERE. 
	
	for(int i=0; i < maxtenths; i++)  
	{
		if (MathRand() > p*32768) 
			break; 
			
		// MathRand() returns in 0..32767
		Sleep(100); 
	}
}  


