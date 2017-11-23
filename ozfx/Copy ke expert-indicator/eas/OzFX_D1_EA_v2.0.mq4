//+------------------------------------------------------------------+
//|                                          OzFX_D1_EA_v2.0.mq4     |
//|                           Copyright © 2008, DGC, mthalmei, Lowen |
//+------------------------------------------------------------------+
//| 13.03.2008: mthalmei - Added ATR functionality                   |
//| 02.05.2008: Lowen - Let user choose amount of TP-increments, etc |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, DGC, mthalmei, Lowen"

extern string  SEP01 = "*----Execution Options-----*";
extern int     EA_Mode = 0; // 0 = trade and manage, 1 = trade only, 2 = manage only
extern bool    Use_SMA_Filter = false;
extern bool    Use_RSI_Filter = false;

extern string  SEP02 = "*----Parameter Values------*";
extern double  Lot_Size = 0.1;
extern int     Lot_Divider = 1; // Lot_Size must be dividable by this number; number must be 1 or higher. Also Broker must support the resulting Lotsize
extern int     Stop_Loss = 80;
extern int     TP_Increment = 50;
extern bool    LetLastLotRun = true; // if true, last Lot-part will run till manual closed, BE, or reversing signal
extern int     Trade_Window = 5; // number of minutes after open of bar to set new trades
extern int     Magic_Number = 1234567;

extern string  SEP03 = "*----ATR Settings----------*";
extern bool    Use_ATR_Stop = false;
extern bool    Use_ATR_TP = false;
extern int     ATR_Length = 14;

int      k;
int      iTicket;
int      iTradeDir;
double   dLastTP;
double   dThisProfit;
double   iTradesClosed;
double   dSL;
double   dOriginal;
double   dSignal;
double   dSMAFilter;
double   dRSIFilter;
int      iNumBars;
double   dATRVal;
double   TP_Increment_Int;
double   Lot_Part;

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
   dATRVal = 0.0;
   TP_Increment_Int = TP_Increment * Point;
   Lot_Part = Lot_Size / Lot_Divider;
   return(0);
}

int start()
{
// Calculate ATR Values
   if (Use_ATR_TP  == true || Use_ATR_Stop == true)
   {
      dATRVal=NormalizeDouble(iATR(NULL,0,ATR_Length,1),Digits);
      if (Use_ATR_TP == true)
         TP_Increment_Int = TP_Increment * 0.01 * dATRVal;
      if (Use_ATR_Stop == true)
         dSL = -Stop_Loss * 0.01 * dATRVal;
   }

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
      iTradesClosed = Lot_Divider - (OrderLots() / Lot_Part);  //number of closed Trades (x of Lot_Divider)

      if (Use_ATR_Stop == true)
         dSL = -Stop_Loss * 0.01 * dATRVal;  // StopLoss is x percent of ATR
      else
         dSL = -Stop_Loss * Point;
         
      if (iTradesClosed > 0)  //StopLoss to BE when first Lot-part is closed
         dSL = 0.0;
      
      dLastTP = iTradesClosed * TP_Increment_Int;
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

      if (dThisProfit <= dSL)  //close lots if SL reached
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
            ObjectCreate("TPLine", OBJ_HLINE, 0, 0, OrderOpenPrice() + (dLastTP + TP_Increment_Int));
            break;
         case -1:
            ObjectCreate("TPLine", OBJ_HLINE, 0, 0, OrderOpenPrice() - (dLastTP + TP_Increment_Int));
            break;
      }
      ObjectSet("TPLine", OBJPROP_COLOR, Green);
      ObjectSet("TPLine", OBJPROP_STYLE, STYLE_DASHDOTDOT);

      if (dThisProfit >= dLastTP + TP_Increment_Int)
      {
         dSL = 0.0;
         if (Lot_Divider == 1)  //if single TP, close whole Lot_Size when price reaches TP
         {
            switch(iTradeDir)
            {
               case 1:
                  OrderClose (OrderTicket(), Lot_Size, Bid, 3, Blue);
               case -1:
                  OrderClose (OrderTicket(), Lot_Size, Ask, 3, Red);
            }
         } 
         else if (LetLastLotRun == true)
         {
  
            if (iTradesClosed <= (Lot_Divider - 2))  //if multiple TP, close 1 part of Lot_Size for each TP increment; let last part run till manual closed, till BE, or reverse signal
            {
               dLastTP += TP_Increment_Int;
               switch(iTradeDir)
               {
                  case 1:
                     OrderClose (OrderTicket(), Lot_Part, Bid, 3, Blue);
                  case -1:
                     OrderClose (OrderTicket(), Lot_Part, Ask, 3, Red);
               }
            }
         } 
         else if (LetLastLotRun == false)
         {
            if (iTradesClosed <= (Lot_Divider - 1))  //if multiple TP, close 1 part of Lot_Size for each TP increment
            {
               dLastTP += TP_Increment_Int;
               switch(iTradeDir)
               {
                  case 1:
                     OrderClose (OrderTicket(), Lot_Part, Bid, 3, Blue);
                  case -1:
                     OrderClose (OrderTicket(), Lot_Part, Ask, 3, Red);
               }
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
   
   string zNextTP = DoubleToStr((dLastTP + TP_Increment_Int) / Point, 0);
   
   string zATR = "";
   if (Use_ATR_TP == true || Use_ATR_Stop == true)
      zATR = "\n             ATR: " + DoubleToStr(dATRVal / Point, 0);
   
   Comment("Current Position: ", zTradeDir, "\n",
           "  Current Profit: ", zProfit, "\n",
           "       Stop Loss: ", zStop, "\n",
           "         Next TP: ", zNextTP,
           zATR);

   return(0);
}

