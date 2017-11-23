
#property copyright "Copyright ?2012, invest-system.net"
#property link      "invest-system.net"

//int g_acc_number_76 =
double g_maxlot = 0.0;
string gs_88 = "AP_v.3.0";
double g_lotsDegital = 2.0;
string gs_104 = "AutoP_v.3.0";
int gi_unused_112 = 1;
extern string __1__ = "Money Management Setting";
extern int MMType = 1;
bool gi_128 = TRUE;
extern string __2__ = "Order Lots Setting";
extern double LotMultiplikator = 1.667;
double g_lotMultiper;
double g_slippage_156 = 5.0;
extern string __3__ = "";
extern string _____ = "true - 镱耱?眄, false - 铗 徉豚眈?";
extern bool LotConst_or_not = FALSE;
extern double Lot = 0.01;
extern double RiskPercent = 30.0;
double g_lot;
extern string __4__ = "";
extern double TakeProfit = 5.0;
double g_TP;
double g_pips_232 = 0.0;
double gd_240 = 10.0;
double gd_248 = 10.0;
extern string __5__ = "Next order step setting";
extern double Step = 5.0;
double g_step;
extern string __6__ = "Max trader setting";
extern int MaxTrades = 30;
extern string __7__ = "Equity Setting";
extern bool UseEquityStop = FALSE;
extern double TotalEquityRisk = 20.0;
bool gi_312 = FALSE;
bool gi_316 = FALSE;
bool g_checkOrderExpire = FALSE;
double g_expiredHours = 48.0;
bool gi_332 = FALSE;
int gi_336 = 2;
int gi_340 = 16;
extern string __8__ = "Magic number setting";
extern int Magic = 1111111;
int g_Magic;
extern string __9__ = "show table ?";
extern bool ShowTableOnTesting = TRUE;
extern string _ = "(true-怅?,false-恹觌.)";
double g_takeProfitPrice;
double g_accountEquity;
double gd_unused_396;
double gd_unused_404;
double g_averagePrice;
double g_bid;
double g_ask;
double g_lastBuyPrice;
double g_lastSellPrice;
double spread_point;
bool g_modifyTakeProfit;
int g_checkBarTime = 0;
int g_expiredTime;
int g_totalOrderNum = 0;
double g_nextlots;
int g_pos_484 = 0;
int g_orders;
double gd_492 = 0.0;
bool g_enableTrade = FALSE;
bool _lastorder_buy = FALSE;
bool _lastorder_sell = FALSE;
int g_orderticket;
bool g_InTrade = FALSE;
int g_datetime_520 = 0;
int g_datetime_524 = 0;
double gd_528;
double gd_536;
int g_fontsize_544 = 14;
int g_color_548 = Gold;
int g_color_552 = Orange;
int g_color_556 = Gray;
int gi_unused_560 = 5197615;

double stoplevel;
int init() {
   spread_point = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   stoplevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
   if (IsTesting() == TRUE) printInfor();
   if (IsTesting() == FALSE) printInfor();
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   double _lastorderlots_buy;
   double _lastorderlots_sell;
   double _closePrice2;
   double _closePrice1;
   // int li_unused_0 = MarketInfo(Symbol(), MODE_STOPLEVEL);
   // int li_unused_4 = MarketInfo(Symbol(), MODE_SPREAD);
   double point_8 = MarketInfo(Symbol(), MODE_POINT);
   double _bid = MarketInfo(Symbol(), MODE_BID);
   double _ask = MarketInfo(Symbol(), MODE_ASK);
   // int li_unused_32 = MarketInfo(Symbol(), MODE_DIGITS);
   if (g_maxlot == 0.0) g_maxlot = MarketInfo(Symbol(), MODE_MAXLOT);
   double _minlot = MarketInfo(Symbol(), MODE_MINLOT);
   double _lotstep = MarketInfo(Symbol(), MODE_LOTSTEP);
  /* if (AccountNumber() != g_acc_number_76 && (!IsDemo())) {
      Comment("杨忮蝽桕 祛驽?疣犷蜞螯 蝾朦觐 磬 聍蛤?" + g_acc_number_76 + ", 潆 徨耧豚蝽钽?镱潢膻麇龛 ?漯筱铎?聍蛤?镥疱殇栩?磬 襦轵 invest-system.net");
      Sleep(1000);
      Print("杨忮蝽桕 祛驽?疣犷蜞螯 蝾朦觐 磬 聍蛤?" + g_acc_number_76 + ", 潆 镱潢膻麇龛 ?漯筱铎?聍蛤?镳铊滂蝈 磬 襦轵 invest-system.net");
      return;
   }*/
   if (((!IsOptimization()) && !IsTesting() && (!IsVisualMode())) || (ShowTableOnTesting && IsTesting() && (!IsOptimization()))) {
      f0_13();
      f0_10();
   }

   // Order lots management
   if (LotConst_or_not) g_lot = Lot;
   else g_lot = AccountBalance() * RiskPercent / 100.0 / 10000.0;
   if (g_lot < _minlot) g_lot = _minlot;
   //Print("orders lots error!" + g_lot + "is smaller than min lots" + _minlot);
   if (g_lot > g_maxlot && g_maxlot > 0.0) g_lot = g_maxlot; //Print("orders lots error!" + g_lot + "is bigger than max lots " + g_maxlot);
   // lot multiper
   g_lotMultiper = LotMultiplikator;
   g_TP = TakeProfit;
   g_step = Step;
   g_Magic = Magic;
   string ls_84 = "true";
   string ls_92 = "false";
   /*
   if (gi_332 == FALSE 
      || ( (gi_332 && (gi_340 > gi_336 && (Hour() >= gi_336 && Hour() <= gi_340)))
         || (gi_336 > gi_340 && (!(Hour() >= gi_340 && Hour() <= gi_336)) 
           )
           )
      ) 
         ls_84 = "true";
   if ( (gi_332 && ( gi_340 > gi_336 && (!(Hour() >= gi_336 && Hour() <= gi_340))) )
      || (gi_336 > gi_340 && (Hour() >= gi_340 && Hour() <= gi_336))) 
         ls_92 = "true";
         */
   if (gi_316) f0_18(gd_240, gd_248, g_averagePrice);
   //
   if (g_checkOrderExpire) {
      if (TimeCurrent() >= g_expiredTime) {
         closeAll();
         Print("Closed All due to TimeOut");
      }
   }

   if (g_checkBarTime == Time[0]) return (0);
   g_checkBarTime = Time[0];

   double _profit = getProfits();
   if (UseEquityStop) {
      if (_profit < 0.0 && MathAbs(_profit) > TotalEquityRisk / 100.0 * getAccountEquity()) {
         closeAll();
         Print("Closed All due to Stop Out");
         g_InTrade = FALSE;
      }
   }
   g_orders = getTotalOrders();
   if (g_orders == 0) g_modifyTakeProfit = FALSE;
   // Get last order type
   for (g_pos_484 = OrdersTotal() - 1; g_pos_484 >= 0; g_pos_484--) {
      OrderSelect(g_pos_484, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_Magic) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_Magic) {
         if (OrderType() == OP_BUY) {
            _lastorder_buy = TRUE;
            _lastorder_sell = FALSE;
            _lastorderlots_buy = OrderLots();
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_Magic) {
         if (OrderType() == OP_SELL) {
            _lastorder_buy = FALSE;
            _lastorder_sell = TRUE;
            _lastorderlots_sell = OrderLots();
            break;
         }
      }
   }
   // if order existed, calc next order price
   if (g_orders > 0 && g_orders <= MaxTrades) {
      RefreshRates();
      g_lastBuyPrice = getLastBuyOrderOpenPrice();
      g_lastSellPrice = getLastSellOrderOpenPrice();
      if (_lastorder_buy && g_lastBuyPrice - Ask >= g_step * Point) g_enableTrade = TRUE;
      if (_lastorder_sell && Bid - g_lastSellPrice >= g_step * Point) g_enableTrade = TRUE;
   }
   // if no orders existed, reset control parameters
   if (g_orders < 1) {
      _lastorder_sell = FALSE;
      _lastorder_buy = FALSE;
      g_enableTrade = TRUE;
      g_accountEquity = AccountEquity();
   }
   //???????????????????????????????????????????
   // If orders existed
   if (g_enableTrade) {
      g_lastBuyPrice = getLastBuyOrderOpenPrice();
      g_lastSellPrice = getLastSellOrderOpenPrice();
      if (_lastorder_sell) {// last sell orders
         if (gi_312 || ls_92 == "true") {
            closeOrderByType(0, 1);
            g_nextlots = NormalizeDouble(g_lotMultiper * _lastorderlots_sell, g_lotsDegital);
         } else g_nextlots = getNextOrderLots(OP_SELL);
         if (gi_128 && ls_84 == "true") {// open sell order if price go aginst per step
            g_totalOrderNum = g_orders;
            if (g_nextlots > 0.0) {
               RefreshRates();
               g_orderticket = openOrder(OP_SELL, g_nextlots, Bid, g_slippage_156, Ask, 0, 0, Symbol() + "-" + gs_88 + "-" + g_totalOrderNum, g_Magic, 0, HotPink);
               if (g_orderticket < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               g_lastSellPrice = getLastSellOrderOpenPrice();
               g_enableTrade = FALSE;
               g_InTrade = TRUE;
            }
         }
      } else {
         if (_lastorder_buy) {// last buy orders
            if (gi_312 || ls_92 == "true") {
               closeOrderByType(1, 0);
               g_nextlots = NormalizeDouble(g_lotMultiper * _lastorderlots_buy, g_lotsDegital);
            } else g_nextlots = getNextOrderLots(OP_BUY);
            if (gi_128 && ls_84 == "true") {// open buy order if price go aginst per step
               g_totalOrderNum = g_orders;
               if (g_nextlots > 0.0) {
                  g_orderticket = openOrder(OP_BUY, g_nextlots, Ask, g_slippage_156, Bid, 0, 0, Symbol() + "-" + gs_88 + "-" + g_totalOrderNum, g_Magic, 0, Lime);
                  if (g_orderticket < 0) {
                     Print("Error: ", GetLastError());
                     return (0);
                  }
                  g_lastBuyPrice = getLastBuyOrderOpenPrice();
                  g_enableTrade = FALSE;
                  g_InTrade = TRUE;
               }
            }
         }
      }
   }
   //???????????????????????????????????????????
   // no order existed, start new order
   if (g_enableTrade && g_orders < 1) {// init order control
      _closePrice2 = iClose(Symbol(), 0, 2);
      _closePrice1 = iClose(Symbol(), 0, 1);
      g_bid = Bid;
      g_ask = Ask;
      if ((!_lastorder_sell) && !_lastorder_buy && ls_84 == "true") {
         g_totalOrderNum = g_orders;
         if (_closePrice2 > _closePrice1) {// Open sell order due to last two close price
            g_nextlots = getNextOrderLots(OP_SELL);
            if (g_nextlots > 0.0) {
               g_orderticket = openOrder(OP_SELL, g_nextlots, g_bid, g_slippage_156, g_bid, 0, 0, Symbol() + "-" + gs_88 + "-" + g_totalOrderNum, g_Magic, 0, HotPink);
               if (g_orderticket < 0) {
                  Print(g_nextlots, "Error: ", GetLastError());
                  return (0);
               }
               // g_lastBuyPrice = getLastBuyOrderOpenPrice();
               g_lastSellPrice = getLastSellOrderOpenPrice();
               g_InTrade = TRUE;
            }
         } else {// Open buy order due to last two close price
            g_nextlots = getNextOrderLots(OP_BUY);
            if (g_nextlots > 0.0) {
               g_orderticket = openOrder(OP_BUY, g_nextlots, g_ask, g_slippage_156, g_ask, 0, 0, Symbol() + "-" + gs_88 + "-" + g_totalOrderNum, g_Magic, 0, Lime);
               if (g_orderticket < 0) {
                  Print(g_nextlots, "Error: ", GetLastError());
                  return (0);
               }
               g_lastBuyPrice = getLastBuyOrderOpenPrice();
               // g_lastSellPrice = getLastSellOrderOpenPrice();
               g_InTrade = TRUE;
            }
         }
      }
      if (g_orderticket > 0) g_expiredTime = TimeCurrent() + 60.0 * (60.0 * g_expiredHours);
      g_enableTrade = FALSE;
   }

   ////???????????????????????????????????????????
   // calculate order average price and set order takeprofit
   g_orders = getTotalOrders();
   g_averagePrice = 0;
   double _totalOrderLots = 0;
   for (g_pos_484 = OrdersTotal() - 1; g_pos_484 >= 0; g_pos_484--) {
      OrderSelect(g_pos_484, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_Magic) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_Magic) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            g_averagePrice += OrderOpenPrice() * OrderLots();
            _totalOrderLots += OrderLots();
         }
      }
   }
   if (g_orders > 0) g_averagePrice = NormalizeDouble(g_averagePrice / _totalOrderLots, Digits);
   if (g_InTrade) {
      for (g_pos_484 = OrdersTotal() - 1; g_pos_484 >= 0; g_pos_484--) {
         OrderSelect(g_pos_484, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_Magic) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_Magic) {
            if (OrderType() == OP_BUY) {
               g_takeProfitPrice = g_averagePrice + g_TP * Point;
               // gd_unused_396 = g_takeProfitPrice;
               gd_492 = g_averagePrice - g_pips_232 * Point;
               g_modifyTakeProfit = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_Magic) {
            if (OrderType() == OP_SELL) {
               g_takeProfitPrice = g_averagePrice - g_TP * Point;
               // gd_unused_404 = g_takeProfitPrice;
               gd_492 = g_averagePrice + g_pips_232 * Point;
               g_modifyTakeProfit = TRUE;
            }
         }
      }
   }
   if (g_InTrade) {
      if (g_modifyTakeProfit == TRUE) {
         for (g_pos_484 = OrdersTotal() - 1; g_pos_484 >= 0; g_pos_484--) {
            OrderSelect(g_pos_484, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_Magic) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_Magic) {
               int cmd = OrderType();
               if(cmd == 0 || cmd == 2 || cmd == 4){//buy
                  g_takeProfitPrice = MathMax(Bid + stoplevel,g_takeProfitPrice);
               }else{//sell
                  g_takeProfitPrice = MathMin(Ask - stoplevel,g_takeProfitPrice);
               }
               //MathMax(stoplevel,
               OrderModify(OrderTicket(), NormalizeDouble(g_averagePrice,Digits), OrderStopLoss(), NormalizeDouble(g_takeProfitPrice,Digits), 0, Yellow);
            }
            g_InTrade = FALSE;
         }
      }
   }
   return (0);
}

double f0_11(double ad_0) {
   return (NormalizeDouble(ad_0, Digits));
}

int closeOrderByType(bool closeBuy = TRUE, bool closeSell = TRUE) {
   int li_ret_8 = 0;
   for (int pos_12 = OrdersTotal() - 1; pos_12 >= 0; pos_12--) {
      if (OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_Magic) {
            if (OrderType() == OP_BUY && closeBuy) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), f0_11(Bid), 5, CLR_NONE)) {
                     Print("Error close BUY " + OrderTicket());
                     li_ret_8 = -1;
                  }
               } else {
                  if (g_datetime_520 == iTime(NULL, 0, 0)) return (-2);
                  g_datetime_520 = iTime(NULL, 0, 0);
                  Print("Need close BUY " + OrderTicket() + ". Trade Context Busy");
                  return (-2);
               }
            }
            if (OrderType() == OP_SELL && closeSell) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!(!OrderClose(OrderTicket(), OrderLots(), f0_11(Ask), 5, CLR_NONE))) continue;
                  Print("Error close SELL " + OrderTicket());
                  li_ret_8 = -1;
                  continue;
               }
               if (g_datetime_524 == iTime(NULL, 0, 0)) return (-2);
               g_datetime_524 = iTime(NULL, 0, 0);
               Print("Need close SELL " + OrderTicket() + ". Trade Context Busy");
               return (-2);
            }
         }
      }
   }
   return (li_ret_8);
}

double getNextOrderLots(int a_cmd_0) {
   double ld_ret_4;
   int datetime_12;
   switch (MMType) {
   case 0:
      ld_ret_4 = g_lot;
      break;
   case 1:
      ld_ret_4 = NormalizeDouble(g_lot * MathPow(g_lotMultiper, g_totalOrderNum), g_lotsDegital);
      break;
   case 2:
      datetime_12 = 0;
      ld_ret_4 = g_lot;
      for (int pos_20 = OrdersHistoryTotal() - 1; pos_20 >= 0; pos_20--) {
         if (!(OrderSelect(pos_20, SELECT_BY_POS, MODE_HISTORY))) return (-3);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_Magic) {
            if (datetime_12 < OrderCloseTime()) {
               datetime_12 = OrderCloseTime();
               if (OrderProfit() < 0.0) {
                  ld_ret_4 = NormalizeDouble(OrderLots() * g_lotMultiper, g_lotsDegital);
                  continue;
               }
               ld_ret_4 = g_lot;
               continue;
               return (-3);
            }
         }
      }
   }
   if (AccountFreeMarginCheck(Symbol(), a_cmd_0, ld_ret_4) <= 0.0) return (-1);
   if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) return (-2);
   return (ld_ret_4);
}

int getTotalOrders() {
   int count_0 = 0;
   for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_Magic) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_Magic)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count_0++;
   }
   return (count_0);
}

void closeAll() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_Magic) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, g_slippage_156, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, g_slippage_156, Red);
         }
         Sleep(1000);
      }
   }
}

int openOrder(int ai_0, double a_lots_4, double a_price_12, int a_slippage_20, double ad_24, int ai_unused_32, int ai_36, string a_comment_40, int a_magic_48, int a_datetime_52, color a_color_56) {
   int ticket_60 = 0;
   int error_64 = 0;
   int count_68 = 0;
   int li_72 = 100;
   switch (ai_0) {
   case 2:
      for (count_68 = 0; count_68 < li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, a_lots_4, a_price_12, a_slippage_20, f0_12(ad_24, g_pips_232), f0_17(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52,
            a_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (count_68 = 0; count_68 < li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, a_lots_4, a_price_12, a_slippage_20, f0_12(ad_24, g_pips_232), f0_17(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52,
            a_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (count_68 = 0; count_68 < li_72; count_68++) {
         RefreshRates();
         ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, f0_12(Bid, g_pips_232), f0_17(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (count_68 = 0; count_68 < li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, a_lots_4, a_price_12, a_slippage_20, f0_0(ad_24, g_pips_232), f0_4(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52,
            a_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (count_68 = 0; count_68 < li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, a_lots_4, a_price_12, a_slippage_20, f0_0(ad_24, g_pips_232), f0_4(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52,
            a_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (count_68 = 0; count_68 < li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, f0_0(Ask, g_pips_232), f0_4(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
   }
   return (ticket_60);
}

double f0_12(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - MathMax(stoplevel,ai_8 * Point));
}

double f0_0(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + MathMax(stoplevel,ai_8 * Point));
}

double f0_17(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + MathMax(stoplevel,ai_8 * Point));
}

double f0_4(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - MathMax(stoplevel,ai_8 * Point));
}

double getProfits() {
   double ld_ret_0 = 0;
   for (g_pos_484 = OrdersTotal() - 1; g_pos_484 >= 0; g_pos_484--) {
      OrderSelect(g_pos_484, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_Magic) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_Magic)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0 += OrderProfit();
   }
   return (ld_ret_0);
}

void f0_18(int ai_0, int ai_4, double a_price_8) {
   int li_16;
   double order_stoploss_20;
   double price_28;
   if (ai_4 != 0) {
      for (int pos_36 = OrdersTotal() - 1; pos_36 >= 0; pos_36--) {
         if (OrderSelect(pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_Magic) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == g_Magic) {
               if (OrderType() == OP_BUY) {
                  li_16 = NormalizeDouble((Bid - a_price_8) / Point, 0);
                  if (li_16 < ai_0) continue;
                  order_stoploss_20 = OrderStopLoss();
                  price_28 = Bid + MathMax(stoplevel,ai_4 * Point);
                  if (order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 > order_stoploss_20)) OrderModify(OrderTicket(), a_price_8, price_28, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  li_16 = NormalizeDouble((a_price_8 - Ask) / Point, 0);
                  if (li_16 < ai_0) continue;
                  order_stoploss_20 = OrderStopLoss();
                  price_28 = Ask - MathMax(stoplevel,ai_4 * Point);
                  if (order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 < order_stoploss_20)) OrderModify(OrderTicket(), a_price_8, price_28, OrderTakeProfit(), 0, Red);
               }
            }
            Sleep(1000);
         }
      }
   }
}

double getAccountEquity() {
   if (getTotalOrders() == 0) gd_528 = AccountEquity();
   if (gd_528 < gd_536) gd_528 = gd_536;
   else gd_528 = AccountEquity();
   gd_536 = AccountEquity();
   return (gd_528);
}

double getLastBuyOrderOpenPrice() {
   double order_open_price_0;
   int ticket_8;
   double ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_Magic) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_Magic && OrderType() == OP_BUY) {
         ticket_8 = OrderTicket();
         if (ticket_8 > ticket_20) {
            order_open_price_0 = OrderOpenPrice();
            ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
         }
      }
   }
   return (order_open_price_0);
}

double getLastSellOrderOpenPrice() {
   double order_open_price_0;
   int ticket_8;
   double ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_Magic) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_Magic && OrderType() == OP_SELL) {
         ticket_8 = OrderTicket();
         if (ticket_8 > ticket_20) {
            order_open_price_0 = OrderOpenPrice();
            ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
         }
      }
   }
   return (order_open_price_0);
}

void printInfor() {
   Comment("            AutoProfit v.3.0  " + Symbol() + "  " + Period(), 
      "\n", "            Forex Account Server:", AccountServer(), 
      "\n", "            Lots:  ", g_lot, 
      "\n", "            Symbol: ", Symbol(), 
      "\n", "            Price:  ", NormalizeDouble(Bid, 4), 
      "\n", "            Date: ", Month(), "-", Day(), "-", Year(), " Server Time: ", Hour(), ":", Minute(), ":", Seconds(), 
   "\n");
}

void f0_13() {
   double ld_0 = f0_8(0);
   string name_8 = gs_104 + "1";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 15);
   }
   ObjectSetText(name_8, "青疣犷蝾?皴泐漤: " + DoubleToStr(ld_0, 2), g_fontsize_544, "Courier New", g_color_548);
   ld_0 = f0_8(1);
   name_8 = gs_104 + "2";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 33);
   }
   ObjectSetText(name_8, "青疣犷蝾?怊屦? " + DoubleToStr(ld_0, 2), g_fontsize_544, "Courier New", g_color_548);
   ld_0 = f0_8(2);
   name_8 = gs_104 + "3";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 51);
   }
   ObjectSetText(name_8, "青疣犷蝾?镱玎怊屦? " + DoubleToStr(ld_0, 2), g_fontsize_544, "Courier New", g_color_548);
   name_8 = gs_104 + "4";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 76);
   }
   ObjectSetText(name_8, "拎豚眈 : " + DoubleToStr(AccountBalance(), 2), g_fontsize_544, "Courier New", g_color_548);
}

void f0_10() {
   string name_0 = gs_104 + "L_1";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 390);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 10);
   }
   ObjectSetText(name_0, "I N V E S T", 28, "Arial", g_color_552);
   name_0 = gs_104 + "L_2";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 382);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 50);
   }
   ObjectSetText(name_0, "  S Y S T E M", 16, "Arial", g_color_552);
   name_0 = gs_104 + "L_3";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 397);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 75);
   }
   ObjectSetText(name_0, "www.invest-system.net", 12, "Arial", g_color_556);
   name_0 = gs_104 + "L_4";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 382);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 57);
   }
   ObjectSetText(name_0, "_____________________", 12, "Arial", Gray);
   name_0 = gs_104 + "L_5";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 382);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 76);
   }
   ObjectSetText(name_0, "_____________________", 12, "Arial", Gray);
}

double f0_8(int ai_0) {
   double ld_ret_4 = 0;
   for (int pos_12 = 0; pos_12 < OrdersHistoryTotal(); pos_12++) {
      if (!(OrderSelect(pos_12, SELECT_BY_POS, MODE_HISTORY))) break;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
         if (OrderCloseTime() >= iTime(Symbol(), PERIOD_D1, ai_0) && OrderCloseTime() < iTime(Symbol(), PERIOD_D1, ai_0) + 86400) ld_ret_4 = ld_ret_4 + OrderProfit() + OrderCommission() + OrderSwap();
   }
   return (ld_ret_4);
}