//+------------------------------------------------------------------+
//|                                   CloseIfSymbolProfitReaches.mq4 |
//|                                                   Baruch Fishman |
//|                                                baaaaaary@msn.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#property strict
//--- input parameters
input double   profitGoal=100.0;//profit goal in acount currency
input int      linesToMoveDown=0;//line to start on if there are items on the chart at the top
input bool     deleteLimits=true;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      double pft = TotalSymbolProfit();
      string s = "";
      for(int i=0;i<linesToMoveDown;i++)
      {
         s += "\r\n";
      }
      s = StringConcatenate(s,"Closing if profit is more than ",profitGoal,
                            "\r\n","Current profit is ",pft,
                            "\r\nStill need ",profitGoal-pft);
      Comment(s);                                   
      //Print("pft=",pft);
      if(pft >= profitGoal)
      {
         CloseAll();
         ExpertRemove();
      }
  }
  
  void CloseAll()
  {
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(i > OrdersTotal()-1)continue;
      if(!OrderSelect(i,SELECT_BY_POS))continue;
      if(OrderSymbol() != Symbol())continue;
      if(OrderType() < 2)OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),1000);
      else if(deleteLimits)OrderDelete(OrderTicket());
   }
  }
  
  double GetOrderProfit(int t)
  {
   if(t != OrderTicket() && !OrderSelect(t,SELECT_BY_TICKET))return -1;
   return OrderProfit() + OrderCommission() + OrderSwap();
  }
  
  double TotalSymbolProfit()
  {
   double tot = 0;
   for(int i=0;i<OrdersTotal();i++)
   {      
      if(!OrderSelect(i,SELECT_BY_POS))continue;
      if(OrderSymbol() != Symbol())continue;
      tot += GetOrderProfit(OrderTicket());
   }
   return tot;
  }
//+------------------------------------------------------------------+
