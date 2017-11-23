//+------------------------------------------------------------------+
//|                                              OxFX Manager v3.mq4 |
//|                                            Copyright © 2008, DGC |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, DGC"

extern int iStopLoss = 100;
extern int iTPIncrement = 50;
extern int iTradeFactor = 10; //1 = .05/.01, 10 = 0.5/0.1, 100 = 5.0/1.0, 1000 = 50/10

int k;
int iTicket;
int iTradeDir;
int iPrevProfit;
double dThisProfit;
int iTradesClosed;

int init()
{
   iTicket = 0;
   iTradeDir = 0;
   iPrevProfit = 0;
   dThisProfit = 0.0;
   iTradesClosed = 0;
   iStopLoss = 100;
   return(0);
}

int start()
{
   // do any orders exist?
   if (OrdersTotal() > 0)
   {
      iTicket = 0;
      // cycle through open orders looking for one for this symbol
      for (k = 0; k < OrdersTotal(); k++)
         if (OrderSelect(k, SELECT_BY_POS, MODE_TRADES) == true)
            // if found, store the ticket number
            if (OrderSymbol() == Symbol()
               && (OrderType() == OP_BUY || OrderType() == OP_SELL))
                 iTicket = OrderTicket();
      // if ticket is valid
      if (iTicket != 0)
      {
         // select current order to be managed
         OrderSelect(iTicket, SELECT_BY_TICKET);

         // set variables for long order
         iTradeDir = 1;
         dThisProfit = Bid - OrderOpenPrice();
         // change variables if order is short
         if (OrderType() == OP_SELL)
         {
            iTradeDir = -1;
            dThisProfit = - dThisProfit;
         }   
         iTradesClosed = 5 - (OrderLots() / (0.01 * iTradeFactor));
         iStopLoss = 100;
         if (iTradesClosed >= 1) iStopLoss = 0;
         iPrevProfit = iTradesClosed * iTPIncrement;
         
         // check price against current stoploss
         if (dThisProfit < -(iStopLoss * Point))
         {
            // if violated, close entire order and reset tracking variables and quit
            OrderClose(OrderTicket(), OrderLots(), Bid, 5, Red);
            iTicket = 0;
            iTradeDir = 0;
            iPrevProfit = 0;
            dThisProfit = 0.0;
            iTradesClosed = 0;
            iStopLoss = 100;
            return(0);
         }   

         // check if next TP has been reached
         if (dThisProfit > (iPrevProfit + iTPIncrement) * Point)
         {
            // if so, move stoploss to BE
            iStopLoss = 0;
            // make sure only 4 TPs are used
            if (iTradesClosed < 4)
            {
               // set next TP to next increment
               iPrevProfit += iTPIncrement;
               // close one portion of the trade according to the trade direction (long/short)
               switch(iTradeDir)
               {
                  case 1:
                     OrderClose (OrderTicket(), 0.01 * iTradeFactor, Bid, 3, Blue);
                  case -1:
                     OrderClose (OrderTicket(), 0.01 * iTradeFactor, Ask, 3, Red);
               }      
            }
         }
      }   
      Comment("Ticket = ", iTicket, "\n",
              "Trade Direction = ", iTradeDir, "\n",
              "Current Profit = ", dThisProfit, "\n",
              "StopLoss = ", iStopLoss, "\n",
              "TPs Hit = ", iTradesClosed, "\n",
              "Next TP = ", iPrevProfit + iTPIncrement);
   }
   return(0);
}

