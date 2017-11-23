//+------------------------------------------------------------------+
//|                                            AutoEquityManager.mq4 |
//|                                          Don Perry, Gene Katsuro |
//|                                                    Modded by WNW | 
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Don Perry, Gene Katsuro"
#property link      "http://www.metaquotes.net"
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
extern double EquityAmount = 1050;
int init()
  {
//----
   
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

Print("Account equity = ",AccountEquity());
Print("Account balance = ",AccountBalance());

 if(AccountEquity() >= EquityAmount)
 { 
int total = OrdersTotal();
  for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();

    bool result = false;
    
    switch(type)
    {
      //Close opened long positions
      case OP_BUY       : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                          break;
      
      //Close opened short positions
      case OP_SELL      : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
                          break;

      //Close pending orders
      case OP_BUYLIMIT  :
      case OP_BUYSTOP   :
      case OP_SELLLIMIT :
      case OP_SELLSTOP  : result = OrderDelete( OrderTicket() );
    }
    
    if(result == false)
    {
      Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
      Sleep(3000);
    }  
  }
  
 
     Print("ALL ORDERS CLOSE-->Locked in on Profits");
 }
 return(0);

  }
//+------------------------------------------------------------------+