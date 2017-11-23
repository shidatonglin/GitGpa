
//+------------------------------------------------------------------+
//|                                              FXSniperT3CCIEA.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

extern int        Magic = 999991;
extern double     Lots = 0.10;
extern bool       AutoMoneyManagement = false;  
extern double     PercentToRisk = 1;
extern double     StopLoss = 40;
extern double     TakeProfit = 200;
extern int        Slippage = 3;
extern int        CCI_Period = 50;
extern int        T3_Period = 5;
extern double     b = 0.618;
extern string     Comments = "FXSnipersT3CCI";


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
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
//----
      double   Risk = PercentToRisk/100,FXSCurrent,FXSLast;
      
      if (AutoMoneyManagement)
         Lots = NormalizeDouble(AccountBalance()*Risk/StopLoss/(MarketInfo(Symbol(), MODE_TICKVALUE)),2);

      FXSCurrent = iCustom(Symbol(),0,"FX Snipers T3 CCI",CCI_Period,T3_Period,b,0,1);
      FXSLast    = iCustom(Symbol(),0,"FX Snipers T3 CCI",CCI_Period,T3_Period,b,0,2);

      if ( FXSCurrent > 0 && FXSLast < 0 && NoOpenOrders() == false )
         CloseTrades(OP_SELL);
      if ( FXSCurrent > 0 && FXSLast < 0 && NoOpenOrders()  )
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,Bid-StopLoss*Point,Ask+TakeProfit*Point, Comments+" Buy",Magic,0,Lime); 
               
      if ( FXSCurrent < 0 && FXSLast > 0 && NoOpenOrders()==false )
         CloseTrades(OP_BUY);
      if ( FXSCurrent < 0 && FXSLast > 0 && NoOpenOrders() )
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,Ask+StopLoss*Point,Bid-TakeProfit*Point, Comments+" Sell",Magic,0,Red);
                                  
//----
   return(0);
  }
//+------------------------------------------------------------------+

void CloseTrades(int type )
   {
      int totalorders = OrdersTotal();
      
      for(int n=totalorders-1;n>=0;n--)
         {
            OrderSelect(n, SELECT_BY_POS);
            //bool result = false;

            if ( OrderMagicNumber()== Magic ) 
               {
                  //Close opened long positions
                  if ( OrderType() == type && type == OP_BUY )OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, White );
                  //Close opened short positions
                  if ( OrderType() == type && type == OP_SELL )OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, White );
                  //Close pending orders
                  //if ( OrderType() > 1 )result=  OrderDelete( OrderTicket() );
               }
         }
       
      return;
   } 

bool NoOpenOrders()
   {
      bool result = true;
      int totalorders = OrdersTotal();
      for(int n=totalorders-1;n>=0;n--)
         {
            OrderSelect(n, SELECT_BY_POS);
            if ( OrderMagicNumber() == Magic )
               result = false;
         }
      return(result);
   }   
 




