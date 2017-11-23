//+------------------------------------------------------------------+
//|                                              OzFX_D1_EA_v1.0.mq4 |
//|                                            Copyright © 2008, DGC |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, DGC"

extern string  SEP01 = "*----Execution Options-----*";
extern int     EA_Mode = 0; // 0 = trade and manage, 1 = trade only, 2 = manage only
extern bool    Use_SMA_Filter = false;
extern bool    Use_RSI_Filter = false;

extern string  SEP02 = "*----Parameter Values------*";
extern double  Lot_Size = 0.5;
extern int     Stop_Loss = 100;
extern int     TP_Increment = 50;
extern int     Trade_Window = 5; // number of minutes after open of bar to set new trades
extern int     Magic_Number = 1234567;

int      k;
int      iTicket;
int      iTradeDir;
double   dLastTP;
double   dThisProfit;
int      iTradesClosed;
double   dSL;
double   dOriginal;
double   dSignal;
double   dSMAFilter;
double   dRSIFilter;
int      iNumBars;

int init()
{
   iTicket = 0;
   iTradeDir = 0;
   dLastTP = 0.0;
   dThisProfit = 0.0;
   iTradesClosed = 0;
   dSL = -Stop_Loss * Point;
   dSignal = 0.0;
   dSMAFilter = 0;
   dRSIFilter = 0;
   iNumBars = Bars;
   return(0);
}

int start()
{

/*------------------*/
/*  GET TRADE INFO  */
/*------------------*/

   iTicket = 0;
   iTradeDir = 0;
   for (k = 0; k < OrdersTotal(); k++)
      if (OrderSelect(k, SELECT_BY_POS, MODE_TRADES) == true)
         if (OrderSymbol() == Symbol()
            && (OrderType() == OP_BUY || OrderType() == OP_SELL))
               iTicket = OrderTicket();
         if ((EA_Mode == 0 || EA_Mode == 1) && OrderMagicNumber() != Magic_Number)
            iTicket = 0;      

   if (iTicket == 0)
   {
      ObjectDelete("StopLine");
      ObjectDelete("TPLine");
   }   
   if (iTicket != 0)
   {
      OrderSelect(iTicket, SELECT_BY_TICKET);
      if (OrderType() == OP_BUY)
      {
         iTradeDir = 1;
         dThisProfit = Bid - OrderOpenPrice();
      }   
      if (OrderType() == OP_SELL)
      {
         iTradeDir = -1;
         dThisProfit = OrderOpenPrice() - Ask;
      }   
      iTradesClosed = 5 - (OrderLots() / (0.2 * Lot_Size));
      dSL = -Stop_Loss * Point;
      if (iTradesClosed >= 1) dSL = 0.0;
      dLastTP = iTradesClosed * TP_Increment * Point;
   }   

/*----------------*/
/*  MANAGE TRADE  */
/*----------------*/

   if (iTicket != 0 && (EA_Mode == 0 || EA_Mode == 2))
   {
      ObjectDelete("StopLine");
      switch (iTradeDir)
      {
         case 1:
            ObjectCreate("StopLine", OBJ_HLINE, 0, 0, OrderOpenPrice() + dSL);
            break;
         case -1:
            ObjectCreate("StopLine", OBJ_HLINE, 0, 0, OrderOpenPrice() - dSL);
            break;
      }
      ObjectSet("StopLine", OBJPROP_COLOR, Red);
      ObjectSet("StopLine", OBJPROP_STYLE, STYLE_DASHDOTDOT);

      if (dThisProfit <= dSL)
      {
         if (iTradeDir == 1)
            OrderClose(OrderTicket(), OrderLots(), Bid, 5, Blue);
         if (iTradeDir == -1)
            OrderClose(OrderTicket(), OrderLots(), Ask, 5, Red);
         iTicket = 0;
         iTradeDir = 0;
         dLastTP = 0.0;
         dThisProfit = 0.0;
         iTradesClosed = 0;
         dSL = -Stop_Loss * Point;
         return(0);
      }   

      ObjectDelete("TPLine");
      switch (iTradeDir)
      {
         case 1:
            ObjectCreate("TPLine", OBJ_HLINE, 0, 0, OrderOpenPrice() + (dLastTP + TP_Increment * Point));
            break;
         case -1:
            ObjectCreate("TPLine", OBJ_HLINE, 0, 0, OrderOpenPrice() - (dLastTP + TP_Increment * Point));
            break;
      }
      ObjectSet("TPLine", OBJPROP_COLOR, Green);
      ObjectSet("TPLine", OBJPROP_STYLE, STYLE_DASHDOTDOT);

      if (dThisProfit >= dLastTP + TP_Increment * Point)
      {
         dSL = 0.0;
         if (iTradesClosed < 4)
         {
            dLastTP += TP_Increment * Point;
            switch(iTradeDir)
            {
               case 1:
                  OrderClose (OrderTicket(), 0.2 * Lot_Size, Bid, 3, Blue);
               case -1:
                  OrderClose (OrderTicket(), 0.2 * Lot_Size, Ask, 3, Red);
            }
         }
      }
   }

/*-----------------------*/
/*  INITIATE NEW TRADES  */
/*-----------------------*/

   if (EA_Mode == 0 || EA_Mode == 1)
   {
      if (Bars > iNumBars)
      {
         dOriginal = iCustom(Symbol(), 0, "OzFX_D1_Ind_v1.0", "", true, true, "", true, 200, true, 45, "", false, false, false, 0, false, false, 0, 0);
         dSMAFilter = iCustom(Symbol(), 0, "OzFX_D1_Ind_v1.0", "", true, true, "", true, 200, true, 45, "", false, false, false, 0, false, false, 2, 0);
         dRSIFilter = iCustom(Symbol(), 0, "OzFX_D1_Ind_v1.0", "", true, true, "", true, 200, true, 45, "", false, false, false, 0, false, false, 3, 0);
         if (TimeCurrent() - Time[0] > Trade_Window * 60)
            iNumBars = Bars;
         dSignal = dOriginal;
         if (Use_SMA_Filter == true && dSMAFilter != dSignal) dSignal = 0.0;
         if (Use_RSI_Filter == true && dRSIFilter != dSignal) dSignal = 0.0;
         if (dSignal > 0)
            switch (iTradeDir)
            {
               case -1:
                  if (OrderSelect(iTicket, SELECT_BY_TICKET) == true)
                     OrderClose(iTicket, OrderLots(), Ask, 3, Red);
               case 0:
                  OrderSend(Symbol(), OP_BUY, Lot_Size, Ask, 3, 0, 0, NULL, Magic_Number, 0, Blue);
            }

         if (dSignal < 0)
            switch (iTradeDir)
            {
               case 1:
                  if (OrderSelect(iTicket, SELECT_BY_TICKET) == true)
                     OrderClose(iTicket, OrderLots(), Bid, 3, Blue);
               case 0:
                  OrderSend(Symbol(), OP_SELL, Lot_Size, Bid, 3, 0, 0, NULL, Magic_Number, 0, Red);
            }
      }
   }

/*-------------------------*/
/*  REPORT TRADING STATUS  */
/*-------------------------*/

   string zTradeDir = "No Trade";
   if (iTradeDir == 1) zTradeDir = "Long";
   if (iTradeDir == -1) zTradeDir = "Short";
   
   string zProfit = DoubleToStr(dThisProfit / Point, 0);
   
   string zStop = DoubleToStr(dSL / Point, 0);
   
   string zNextTP = DoubleToStr(dLastTP / Point + TP_Increment, 0);
   
   Comment("Current Position: ", zTradeDir, "\n",
           "  Current Profit: ", zProfit, "\n",
           "       Stop Loss: ", zStop, "\n",
           "         Next TP: ", zNextTP);

   return(0);
}

