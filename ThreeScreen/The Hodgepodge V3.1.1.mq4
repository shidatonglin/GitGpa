//+------------------------------------------------------------------+
//|                                          The Hodgepodge v3.0.mq4 |
//|        Copyright 2020. All rights reserved By Christopher Smith. |
//|                                             http://LossForex.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2020. All rights reserved By Christopher Smith"
#property link "http://LossForex.com"
#property description "\n\n\n\n\n\n\n\nCoded By : Belal Hossain (LossForex.Com)"
#property strict

enum e_EN_MT{
yes1 = 1,// Enable
no1 = 0// Disable
};
enum e_SL_Type{
auto = 1,// Auto StopLoss
menu = 2,// Manual StopLoss
none = 0// No StopLoss
};
enum e_EN_BE{
yes2 = 1,// Enable
no2 = 0// Disable
};
enum e_EN_TS{
yes3 = 1,// Enable
no3 = 0// Disable
};
enum e_EN_RE{
yes4 = 1,// Enable
no4 = 0// Disable
};
enum e_Exit_Type{
breaks = 1,// SMA Break
colors = 2,// Colour Change
not = 3 // No Exit
};
enum e_EN_Inside{
yes5 = 1,// Enable
no5 = 0// Disable
};
enum e_EN_HT{
yes7 = 1,// Enable
no7 = 0// Disable
};
enum e_Ind2TF{
h = 1,// Period H4
d = 2,// Period D1
w = 3,// Period W1
hd = 4,// Period (H4 + D1)
dw = 5,// Period (D1 + W1)
hdw = 6// Period (H4 + D1 + W1)
};

extern int Magic = 20170629;                    // Magic Number
extern string Trade_Comment = "";               // Trade Comment
extern double Lot_Size = 0.01;                  // Lot Size
extern e_EN_MT EN_MT = no1;                     // Martingale Status
extern double Add_Lot_Size = 0.05;              // Additional Lot Size
extern int Take_Profit = 200;                   // Take Profit
extern e_SL_Type SL_Type = auto;                // Stop Loss Type
extern int Stop_Loss = 100;                     // Manual Stop Loss
extern e_EN_BE EN_BE = no2;                     // Break Even Status
extern int Break_Even = 100;                    // Break Even
extern int Break_Even_Lock = 5;                 // Break Even Lock
extern e_EN_TS EN_TS = no3;                     // Trailing Stop Status
extern int Start_Ts = 300;                      // Start Trailing At
extern int maintain_Ts = 200;                   // Maintain Trail Distance
extern e_EN_RE EN_RE = yes4;                    // Re Entry Status
extern e_Exit_Type Exit_Type = colors;          // Trade Exit Type
extern string setting = "---------------- Entry Indicator Settings ----------------";//-----------------------------------------------------------------
extern int Moving_Period = 5;                   // Current MA Period
extern int Moving_Shift = 3;                    // Current MA Shift
extern ENUM_MA_METHOD Moving_Method = 0;        // Current MA Method
extern ENUM_APPLIED_PRICE Moving_Apply = 5;     // Current MA Apply To
extern string Filter = "----------------------- Filter Settings ------------------------";//-----------------------------------------------------------------
extern e_EN_Inside EN_Inside = no5;             // Inside Bar Filter Status
extern ENUM_TIMEFRAMES Inside_Time = 1440;      // Inside Bar TimeFrame
extern e_EN_HT EN_HT = yes7;                    // Moving Average Filter Status
extern e_Ind2TF Ind2TF = hdw;                   // Moving Average TimeFrame
extern int Moving_Period1 = 5;                  // 1st MA Period
extern int Moving_Shift1 = 0;                   // 1st MA Shift
extern ENUM_MA_METHOD Moving_Method1 = 1;       // 1st MA Method
extern ENUM_APPLIED_PRICE Moving_Apply1 = 0;    // 1st MA Apply To
extern int Moving_Period2 = 8;                  // 2nd MA Period
extern int Moving_Shift2 = 0;                   // 2nd MA Shift
extern ENUM_MA_METHOD Moving_Method2 = 1;       // 2nd MA Method
extern ENUM_APPLIED_PRICE Moving_Apply2 = 0;    // 2nd MA Apply To
extern string other = "----------------------- Other Settings -----------------------";//-----------------------------------------------------------------
extern ENUM_BASE_CORNER Corner = 3;             // Panel Corner
extern int X_Distance = 20;                     // Panel X Distance
extern int Y_Distance = 25;                     // Panel Y Distance
extern color Up_Color = MediumSeaGreen;         // Up Color
extern color Down_Color = Red;                  // Down Color

int Slippage = 100;
int reentry = 0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(EN_HT == 0)
     {
      DeleteObject();
     }
   else if(EN_HT == 1)
     {
      DrawObject();
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   DeleteObject();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   HideTestIndicators(true);
   double Poin = Point;
   double calLot = Lot_Size;
   if(EN_MT == 1 && LastProfit() < 0)
     {
      calLot = LastLot() + Add_Lot_Size;
     }
   string pair = StringSubstr(Symbol(),0,6);
   string ext = StringSubstr(Symbol(),6,0);
   if(Digits == 3 || Digits == 5){Poin = Point*10;}
   else if(MarketInfo("EURUSD"+ext, MODE_DIGITS) == 5)
     {
      if((Symbol() == "gold" || Symbol() == "GOLD" || Symbol() == "XAUUSD") && Digits == 2){Poin = Point*10;}
     }
//---
   string tmp = ObjectGetString(0, "1CCF_diff"+pair+"suggest", OBJPROP_TEXT, 0);
   string indr = StringSubstr(tmp,28,0);
   double Heikenclos1 = iCustom(Symbol(),0,"Heiken Ashi",3,1);
   double Heikenclos2 = iCustom(Symbol(),0,"Heiken Ashi",3,2);
   double Heikenopen1 = iCustom(Symbol(),0,"Heiken Ashi",2,1);
   double Heikenopen2 = iCustom(Symbol(),0,"Heiken Ashi",2,2);
   double MaC1 = iMA(Symbol(),0,Moving_Period,Moving_Shift,Moving_Method,Moving_Apply,1);
   double MaC2 = iMA(Symbol(),0,Moving_Period,Moving_Shift,Moving_Method,Moving_Apply,2);
   double mah41 = iMA(Symbol(),PERIOD_H4,Moving_Period1,Moving_Shift1,Moving_Method1,Moving_Apply1,0);
   double mah42 = iMA(Symbol(),PERIOD_H4,Moving_Period2,Moving_Shift2,Moving_Method2,Moving_Apply2,0);
   double mahD1 = iMA(Symbol(),PERIOD_D1,Moving_Period1,Moving_Shift1,Moving_Method1,Moving_Apply1,0);
   double mahD2 = iMA(Symbol(),PERIOD_D1,Moving_Period2,Moving_Shift2,Moving_Method2,Moving_Apply2,0);
   double mahW1 = iMA(Symbol(),PERIOD_W1,Moving_Period1,Moving_Shift1,Moving_Method1,Moving_Apply1,0);
   double mahW2 = iMA(Symbol(),PERIOD_W1,Moving_Period2,Moving_Shift2,Moving_Method2,Moving_Apply2,0);
//---
   if(EN_HT == 1)
     {
      DrawObject();
      if(mah41 > mah42)
        {
         ObjectSetString(0,"Data H4",OBJPROP_TEXT,Symbol()+" H4"); 
         ObjectSetInteger(0,"Data H-4",OBJPROP_COLOR,Up_Color);
        }
      else if(mah41 < mah42)
        {
         ObjectSetString(0,"Data H4",OBJPROP_TEXT,Symbol()+" H4");
         ObjectSetInteger(0,"Data H-4",OBJPROP_COLOR,Down_Color);
        }
      if(mahD1 > mahD2)
        {
         ObjectSetString(0,"Data D1",OBJPROP_TEXT,Symbol()+" D1");
         ObjectSetInteger(0,"Data D-1",OBJPROP_COLOR,Up_Color);
        }
      else if(mahD1 < mahD2)
        {
         ObjectSetString(0,"Data D1",OBJPROP_TEXT,Symbol()+" D1");
         ObjectSetInteger(0,"Data D-1",OBJPROP_COLOR,Down_Color);
        }
      if(mahW1 > mahW2)
        {
         ObjectSetString(0,"Data W1",OBJPROP_TEXT,Symbol()+" W1");
         ObjectSetInteger(0,"Data W-1",OBJPROP_COLOR,Up_Color);
        }
      else if(mahW1 < mahW2)
        {
         ObjectSetString(0,"Data W1",OBJPROP_TEXT,Symbol()+" W1");
         ObjectSetInteger(0,"Data W-1",OBJPROP_COLOR,Down_Color);
        }
      if(Ind2TF == 1){ObjectDelete("Data D1");ObjectDelete("Data W1");ObjectDelete("Data D-1");ObjectDelete("Data W-1");}
      if(Ind2TF == 2){ObjectDelete("Data H4");ObjectDelete("Data W1");ObjectDelete("Data H-4");ObjectDelete("Data W-1");}
      if(Ind2TF == 3){ObjectDelete("Data H4");ObjectDelete("Data D1");ObjectDelete("Data H-4");ObjectDelete("Data D-1");}
      if(Ind2TF == 4){ObjectDelete("Data W1");ObjectDelete("Data W-1");}
      if(Ind2TF == 5){ObjectDelete("Data H4");ObjectDelete("Data H-4");}
   }
//---
   int signal = 10;
   if((Ind2TF == 1 && mah41 > mah42) || (Ind2TF == 2 && mahD1 > mahD2) || (Ind2TF == 3 && mahW1 > mahW2) || 
   (Ind2TF == 4 && (mah41 > mah42 && mahD1 > mahD2)) || (Ind2TF == 5 && (mahD1 > mahD2 && mahW1 > mahW2)) || 
   (Ind2TF == 6 && (mah41 > mah42 && mahD1 > mahD2 && mahW1 > mahW2)))
     {
      signal = 0;
     }
   else if((Ind2TF == 1 && mah41 < mah42) || (Ind2TF == 2 && mahD1 < mahD2) || (Ind2TF == 3 && mahW1 < mahW2) || 
   (Ind2TF == 4 && (mah41 < mah42 && mahD1 < mahD2)) || (Ind2TF == 5 && (mahD1 < mahD2 && mahW1 < mahW2)) || 
   (Ind2TF == 6 && (mah41 < mah42 && mahD1 < mahD2 && mahW1 < mahW2)))
     {
      signal = 1;
     }
//---
   static int bar = Bars-1;
   if(bar != Bars)
     {
      if(ThisPairTrade() > 0)
        {
         if(((Exit_Type == 1 && Heikenclos1 < MaC1) || (Exit_Type == 2 && Heikenopen1 > Heikenclos1)) && ThisPairBuy() > 0)
           {
            for(int i=0;i<OrdersTotal();i++)
              {
               int select = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
               if(OrderType() == 0 && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
                 {
                  int close = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),50);
                 }
              }
            reentry = 0;
           }
         else if(((Exit_Type == 1 && Heikenclos1 > MaC1) || (Exit_Type == 2 && Heikenopen1 < Heikenclos1)) && ThisPairSell() > 0)
           {
            for(int i=0;i<OrdersTotal();i++)
              {
               int select = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
               if(OrderType() == 1 && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
                 {
                  int close = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),50);
                 }
              }
             reentry = 0;
           }
        }
      else if(Heikenclos2 < MaC2 && Heikenclos1 > MaC1 && ThisPairTrade() == 0)
        {
         if(EN_HT == 0 || (EN_HT == 1 && signal == 0))
           {
            if(EN_Inside == 0 || (EN_Inside == 1 && iClose(Symbol(), Inside_Time, 1) > iHigh(Symbol(), Inside_Time, 2)))
              {
               int tradeb = OrderSend(Symbol(), 0, calLot, Ask, Slippage, 0, 0, Trade_Comment, Magic, 0, clrNONE);
               if(tradeb > 0){bar = Bars;}
              }
           }
        }
      else if(Heikenclos2 > MaC2 && Heikenclos1 < MaC1 && ThisPairTrade() == 0)
        {
         if(EN_HT == 0 || (EN_HT == 1 && signal == 1))
           {
            if(EN_Inside == 0 || (EN_Inside == 1 && iClose(Symbol(), Inside_Time, 1) < iLow(Symbol(), Inside_Time, 2)))
              {
               int trades = OrderSend(Symbol(), 1, calLot, Bid, Slippage, 0, 0, Trade_Comment, Magic, 0, clrNONE);
               if(trades > 0){bar = Bars;}
              }
           }
        }
      else{bar = Bars;}
     }
//---
   static int bar2 = Bars;
   if(bar2 != Bars)
     {
     if(ThisPairTrade() < 2 && reentry == 0 && EN_RE == 1)
        {
         if(Heikenclos1 > MaC1 && Heikenclos2 > MaC2 && Heikenclos1 > Heikenopen1 && Heikenclos2 < Heikenopen2)
           {
            if(EN_HT == 0 || (EN_HT == 1 && signal == 0))
              {
               if(EN_Inside == 0 || (EN_Inside == 1 && iClose(Symbol(), Inside_Time, 1) > iHigh(Symbol(), Inside_Time, 2)))
                 {
                  int trader = OrderSend(Symbol(), 0, calLot, Ask, Slippage, 0, 0, Trade_Comment, Magic, 0, clrNONE);
                  if(trader > 0){reentry = 1;bar2 = Bars;}
                 }
              }
           }
         else if(Heikenclos1 < MaC1 && Heikenclos2 < MaC2 && Heikenclos1 < Heikenopen1 && Heikenclos2 > Heikenopen2)
           {
            if(EN_HT == 0 || (EN_HT == 1 && signal == 1))
              {
               if(EN_Inside == 0 || (EN_Inside == 1 && iClose(Symbol(), Inside_Time, 1) < iLow(Symbol(), Inside_Time, 2)))
                 {
                  int trader = OrderSend(Symbol(), 1, calLot, Bid, Slippage, 0, 0, Trade_Comment, Magic, 0, clrNONE);
                  if(trader > 0){reentry = 1;bar2 = Bars;}
                 }
              }
           }
         else{bar2 = Bars;}
        }
     else{bar2 = Bars;}
     }
   if(ThisPairTrade() == 0)
     {
      reentry = 0;
     }
//---
   if(ThisPairTrade() > 0)
     {
      for(int i=0;i<OrdersTotal();i++)
        {
         int Select = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         if(OrderType() == 0 && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
           {
            if(SL_Type == 1 && OrderStopLoss() == 0)
              {
               double autoslby = 0;
               for(int j=0;j<100;j++)
                 {
                  autoslby = iFractals(Symbol(),0,MODE_LOWER,j);
                  if(autoslby > 0){j = 100;}
                 }
               int modslb = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(autoslby, Digits),OrderTakeProfit(),0,CLR_NONE);
              }
            else if(SL_Type == 2 && OrderStopLoss() == 0)
              {
               int modslb = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-Stop_Loss*Poin,OrderTakeProfit(),0,CLR_NONE);
              }
            else if(OrderTakeProfit() == 0)
              {
               int modtpb = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderOpenPrice()+Take_Profit*Poin,0,CLR_NONE);
              }
            if(EN_BE == 1 && Bid > OrderOpenPrice()+Break_Even*Poin && OrderStopLoss() < OrderOpenPrice()+Break_Even_Lock*Poin)
              {
               int modbeb = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+Break_Even_Lock*Poin,OrderTakeProfit(),0,CLR_NONE);
              }
            if(EN_TS == 1 && Bid > OrderOpenPrice()+Start_Ts*Poin && Bid > OrderStopLoss()+maintain_Ts*Poin)
              {
               int modtsb = OrderModify(OrderTicket(),OrderOpenPrice(),Bid-maintain_Ts*Poin,OrderTakeProfit(),0,CLR_NONE);
              }
           }
         else if(OrderType() == 1 && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
           {
            if(SL_Type == 1 && OrderStopLoss() == 0)
              {
               double autoslsel = 0;
               for(int k=0;k<100;k++)
                 {
                  autoslsel = iFractals(Symbol(),0,MODE_UPPER,k);
                  if(autoslsel > 0){k = 100;}
                 }
               int modsls = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(autoslsel, Digits),OrderTakeProfit(),0,CLR_NONE);
              }
            else if(SL_Type == 2 && OrderStopLoss() == 0)
              {
               int modsls = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+Stop_Loss*Poin,OrderTakeProfit(),0,CLR_NONE);
              }
            else if(OrderTakeProfit() == 0)
              {
               int modtps = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderOpenPrice()-Take_Profit*Poin,0,CLR_NONE);
              }
            if(EN_BE == 1 && Bid < OrderOpenPrice()-Break_Even*Poin && OrderStopLoss() > OrderOpenPrice()-Break_Even_Lock*Poin)
              {
               int modbes = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-Break_Even_Lock*Poin,OrderTakeProfit(),0,CLR_NONE);
              }
            if(EN_TS == 1 && Bid < OrderOpenPrice()-Start_Ts*Poin && Bid < OrderStopLoss()-maintain_Ts*Poin)
              {
               int modts = OrderModify(OrderTicket(),OrderOpenPrice(),Bid+maintain_Ts*Poin,OrderTakeProfit(),0,CLR_NONE);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
int ThisPairTrade()
{
   int ThisPairTrade = 0;
   for(int i=0;i<OrdersTotal();i++)
     {
      int select = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if((OrderType() == 0 || OrderType() == 1)&& OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
        {
         ThisPairTrade++;
        }
     }
   return(ThisPairTrade);
}
//---
int ThisPairBuy()
{
   int ThisPairBuy = 0;
   for(int i=0;i<OrdersTotal();i++)
     {
      int select = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderType() == 0 && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
        {
         ThisPairBuy++;
        }
     }
   return(ThisPairBuy);
}
//---
int ThisPairSell()
{
   int ThisPairSell = 0;
   for(int i=0;i<OrdersTotal();i++)
     {
      int select = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderType() == 1 && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
        {
         ThisPairSell++;
        }
     }
   return(ThisPairSell);
}
//---
double LastLot()
{
   double LastLot = 0;
   for(int i=0;i<OrdersHistoryTotal();i++)
     {
      int select = OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
      if((OrderType()== 0 || OrderType() == 1) && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
       {
        LastLot = OrderLots();
       }
     }
   return(LastLot);
}
//---
double LastProfit()
{
   double LastProfit = 0;
   for(int i=0;i<OrdersHistoryTotal();i++)
     {
      int select = OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
      if((OrderType()== 0 || OrderType() == 1) && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
       {
        LastProfit = OrderProfit();
       }
     }
   return(LastProfit);
}
//---
void DrawObject()
{
   color back = (color)ChartGetInteger(0,CHART_COLOR_BACKGROUND,0);
   string matype1 = "";
   string matype2 = "";
   if(Moving_Method1 == 0){matype1 = "SMA";}
   else if(Moving_Method1 == 1){matype1 = "EMA";}
   else if(Moving_Method1 == 2){matype1 = "SMMA";}
   else if(Moving_Method1 == 3){matype1 = "LWMA";}
   if(Moving_Method2 == 0){matype2 = "SMA";}
   else if(Moving_Method2 == 1){matype2 = "EMA";}
   else if(Moving_Method2 == 2){matype2 = "SMMA";}
   else if(Moving_Method2 == 3){matype2 = "LWMA";}
   ObjectCreate ("Value Title", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Value Title", (string)Moving_Period1+" "+matype1+" x "+(string)Moving_Period2+" "+matype2, 10, "Arial", Gold);
   ObjectSet    ("Value Title", OBJPROP_CORNER, Corner);
   ObjectSet    ("Value Title", OBJPROP_XDISTANCE, X_Distance);
   ObjectSet    ("Value Title", OBJPROP_YDISTANCE, Y_Distance+38);
   ObjectSet    ("Value Title", OBJPROP_SELECTABLE,false);
   
   if(Ind2TF == 1 || Ind2TF == 4 || Ind2TF == 6)
     {
      ObjectCreate ("Data H4", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("Data H4", Symbol()+" H4", 8, "Arial", Gold);
      ObjectSet    ("Data H4", OBJPROP_CORNER, Corner);
      ObjectSet    ("Data H4", OBJPROP_XDISTANCE, X_Distance);
      ObjectSet    ("Data H4", OBJPROP_YDISTANCE, Y_Distance+24);
      ObjectSet    ("Data H4", OBJPROP_SELECTABLE,false);
      ObjectCreate ("Data H-4", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("Data H-4", "-", 60, "Arial", back);
      ObjectSet    ("Data H-4", OBJPROP_CORNER, Corner);
      ObjectSet    ("Data H-4", OBJPROP_XDISTANCE, X_Distance+62);
      if(Corner == 0 || Corner == 1){ObjectSet    ("Data H-4", OBJPROP_YDISTANCE, Y_Distance-20);}
      else{ObjectSet    ("Data H-4", OBJPROP_YDISTANCE, Y_Distance-6);}
      ObjectSet    ("Data H-4", OBJPROP_SELECTABLE,false);
     }
   if(Ind2TF == 2 || Ind2TF == 4 || Ind2TF == 5 || Ind2TF == 6)
     {
      ObjectCreate ("Data D1", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("Data D1", Symbol()+" D1", 8, "Arial", Gold);
      ObjectSet    ("Data D1", OBJPROP_CORNER, Corner);
      ObjectSet    ("Data D1", OBJPROP_XDISTANCE, X_Distance);
      ObjectSet    ("Data D1", OBJPROP_YDISTANCE, Y_Distance+12);
      ObjectSet    ("Data D1", OBJPROP_SELECTABLE,false);
      ObjectCreate ("Data D-1", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("Data D-1", "-", 60, "Arial", back);
      ObjectSet    ("Data D-1", OBJPROP_CORNER, Corner);
      ObjectSet    ("Data D-1", OBJPROP_XDISTANCE, X_Distance+62);
      if(Corner == 0 || Corner == 1){ObjectSet    ("Data D-1", OBJPROP_YDISTANCE, Y_Distance-32);}
      else{ObjectSet    ("Data D-1", OBJPROP_YDISTANCE, Y_Distance-18);}
      ObjectSet    ("Data D-1", OBJPROP_SELECTABLE,false);
     }
   if(Ind2TF == 3 || Ind2TF == 5 || Ind2TF == 6)
     {
      ObjectCreate ("Data W1", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("Data W1", Symbol()+" W1", 8, "Arial", Gold);
      ObjectSet    ("Data W1", OBJPROP_CORNER, Corner);
      ObjectSet    ("Data W1", OBJPROP_XDISTANCE, X_Distance);
      ObjectSet    ("Data W1", OBJPROP_YDISTANCE, Y_Distance+0);
      ObjectSet    ("Data W1", OBJPROP_SELECTABLE,false);
      ObjectCreate ("Data W-1", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("Data W-1", "-", 60, "Arial", back);
      ObjectSet    ("Data W-1", OBJPROP_CORNER, Corner);
      ObjectSet    ("Data W-1", OBJPROP_XDISTANCE, X_Distance+62);
      if(Corner == 0 || Corner == 1){ObjectSet    ("Data W-1", OBJPROP_YDISTANCE, Y_Distance-44);}
      else{ObjectSet    ("Data W-1", OBJPROP_YDISTANCE, Y_Distance-30);}
      ObjectSet    ("Data W-1", OBJPROP_SELECTABLE,false);
     }
}
//---
void DeleteObject()
{
   ObjectDelete("Data H4");
   ObjectDelete("Data D1");
   ObjectDelete("Data W1");
   ObjectDelete("Data H-4");
   ObjectDelete("Data D-1");
   ObjectDelete("Data W-1");
   ObjectDelete("Value Title");
}
//---