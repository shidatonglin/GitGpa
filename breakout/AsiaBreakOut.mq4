
extern double baseLots           = 0.01;
extern bool   enable             = true;
extern int    magicNum           = 201870803;
extern string comments           = "AsiaBreakOut V1.0";
extern int    maxSpread          = 30;
extern int     slippage          = 2;
// extern string sTimeBegin         = "08:00";
extern string boxTimeStartGMT    = "21:00"; // 5am for beijing time
extern string boxTimeEndGMT      = "05:00";  // 13 fro beijing time
extern int    boxbreakout_offset = 10;
extern int    expDate            = 24;
extern bool   removePendingOrders = false;
extern bool   useTickMode        = false;
extern int    barShift           = 1;
extern int BreakevenStop             = 250;// Break even, o to disable
extern int Trail_Stop_Pips           = 0;//Trailing Stop, 0 to disable
extern int Trail_Stop_Jump_Pips      = 100;//Trail Stop Shift
extern int TouchesAddin              = 30;
extern int BrokerTimeZone            = 3;


double   buyPrice,//define BuyStop price
buyTP,      //Take Profit BuyStop
buySL,      //Stop Loss BuyStop
sellPrice,  //define SellStop price
sellTP,     //Take Profit SellStop
sellSL;     //Stop Loss SellStop

static bool secondH4Barfound = false;
static double barHigh,barLow,barSize;
int buyOrderTicket,sellOrderTicket;
datetime _ExpDate=0;
string label_name = "AsiaBreakOut";

double prevAsk = -1;
double prevBid = -1;
int tries=0,oper_max_tries=3;
int iBarBegin,iBarEnd;
// int totalBars;
int thisBarOrders=0;
int curGmtTime = 0;
int init() {
  // totalBars = iBars( NULL, PERIOD_D1);
  curGmtTime = TimeGMT();
  return (0);
}

int deinit() {
   return (0);
}

int start() {
  //if(enable && Period() != PERIOD_H4) {
    //log("Please attach to H4 chart!!");
    //Alert("Please attach to H4 chart!!");
    //enable = false;
  //}
  // if(totalBars != iBars( NULL, PERIOD_D1)){
  //   totalBars = iBars( NULL, PERIOD_D1);
    
  // }

  if(TimeDay( curGmtTime ) != TimeDay( TimeGMT() )){
    secondH4Barfound = false;
    curGmtTime = TimeGMT();
    log("A new day comeing!! secondH4Barfound = "+secondH4Barfound);
  }
  if(sqOrderOpenedThisBar(magicNum)) return(0);// search for orders open in this bar or close in this bar
  else thisBarOrders = 0;
  int cmd = -1;
  drawInfo();
  Comment("barHigh---->"+barHigh
           +"\nbarLow---->"+barLow
           +"\nbarSize---->"+barSize/Point
           +"\nsecondH4Barfound---->"+secondH4Barfound
           +"\niBarBegin--->"+iBarBegin
           +"\niBarEnd--->"+iBarEnd
           +"\n thisBarOrders--->"+thisBarOrders);
  if(removePendingOrders) deleteAllPendngOrders();
   if(!enable) return(0);
  if(getTotalOrderByType(0) > 0){// Get market order numbers
    if(BreakevenStop>0) DoBreakEven(BreakevenStop,0);
    if(Trail_Stop_Pips>0){
      trail_stop();
    }
  }
  double   _bid     = NormalizeDouble(MarketInfo(Symbol(), MODE_BID), Digits); //define a lower price 
  double   _ask     = NormalizeDouble(MarketInfo(Symbol(), MODE_ASK), Digits); //define an upper price
   if(!secondH4Barfound){
      findTargetBar();
   } else {
      double   _point   = MarketInfo(Symbol(), MODE_POINT);
      if(barSize/_point > 2000) return(0);
      
      //Print(getTotalOrderByType(2));
      if(getTotalOrderByType(2) > 0){
      // If buy order triggered, delete the coupled sell orders
      // Only used when using pending orders
      // Not used in this solutions
         int orderType = last_order_type();
         if(orderType == OP_BUY) {
        if(deleteTargetOrder(sellOrderTicket))// sellOrderTicket = 0;
        deleteAllPendngOrders();
      }
      // If sell order triggered, delete the coupled buy orders
      // Only used when using pending orders
      // Not used in this solutions
         else if(orderType == OP_SELL){
        if(deleteTargetOrder(buyOrderTicket))// buyOrderTicket = 0;
        deleteAllPendngOrders();
      }

      } else {
        double LongEntry = NormalizeDouble(barHigh+boxbreakout_offset*_point,Digits);
        double ShortEntry = NormalizeDouble(barLow-boxbreakout_offset*_point,Digits);

        if(useTickMode){
          if ((Ask > LongEntry && prevAsk - TouchesAddin * Point <= LongEntry) 
            || (Ask - TouchesAddin * Point < LongEntry && prevAsk >= LongEntry)){
            cmd = OP_BUY;
          }
          if ((Bid < ShortEntry && prevBid + TouchesAddin * Point >= ShortEntry) 
            || (Bid + TouchesAddin * Point > ShortEntry && prevBid <= ShortEntry)){
            cmd = OP_SELL;
          }
        }else {
          if(Open[barShift + 0] < LongEntry && Close[barShift + 0] >= LongEntry){
            cmd = OP_BUY;
          } else
          if(Open[barShift + 0] > ShortEntry && Close[barShift + 0] <= ShortEntry){
            cmd = OP_SELL;
          }
        }
         double lot = getOrderLots();
      // error 4109
      if(cmd==OP_SELL){
        sellPrice=_bid;
        sellSL=NormalizeDouble(sellPrice+barSize,Digits);
        sellTP=NormalizeDouble(sellPrice-barSize,Digits);
        _ExpDate=TimeCurrent()+expDate*60*60; 
        sellOrderTicket = OrderOpenF(Symbol(),OP_SELL,lot,sellPrice,slippage,sellSL,sellTP,comments+" sell order",magicNum,_ExpDate,Red);
        //Comment("sellOrderTicket"+sellOrderTicket);
        log("Open sell order success!! ticket==="+sellOrderTicket
            + "\n sellSL===>"+sellSL + " sellTP===>"+sellTP);
      }
         if(cmd==OP_BUY){
        buyPrice=_ask;
        buySL = NormalizeDouble(buyPrice-barSize,Digits); //define a stop loss with interval
        buyTP=NormalizeDouble(buyPrice+barSize,Digits);       //define a take profit
        _ExpDate=TimeCurrent()+expDate*60*60;                   //a pending order expiration time calculation
        buyOrderTicket = OrderOpenF(Symbol(),OP_BUY,lot,buyPrice,slippage,buySL,buyTP,comments+" buy order",magicNum,_ExpDate,Blue);
        //Comment("buyOrderTicket"+buyOrderTicket);
        log("Open buy order success!! ticket==="+buyOrderTicket
          + "\n buySL===>"+buySL + " buyTP===>"+buyTP);
      }
      }
   }
  prevBid = _bid;
  prevAsk = _ask;
  return(0);
}

void findTargetBar(){
   datetime gmtTime = TimeGMT();
   int gmtHour = TimeHour( gmtTime );
   if(gmtHour < getHourFromTimeStr(boxTimeEndGMT)){
      return;
   }
   datetime dtTimeBegin = StrToTime(TimeToStr(gmtTime, TIME_DATE) + " " + boxTimeStartGMT);
   datetime dtTimeEnd = StrToTime(TimeToStr(gmtTime, TIME_DATE) + " " + boxTimeEndGMT);
   if(dtTimeBegin > dtTimeEnd){
      dtTimeBegin = dtTimeBegin - 24*60*60;
   }
   dtTimeBegin = convertToBrokerTime(dtTimeBegin);
   dtTimeEnd = convertToBrokerTime(dtTimeEnd);
   log("dtTimeBegin--->"+TimeToStr(dtTimeBegin));
   log("dtTimeEnd--->"+TimeToStr(dtTimeEnd));
   
   iBarBegin = iBarShift(NULL, 0, dtTimeBegin);
   iBarEnd = iBarShift(NULL, 0, dtTimeEnd);
   log("iBarBegin--->"+iBarBegin);
   log("iBarEnd--->"+iBarEnd);
   barHigh = High[Highest(NULL, 0, MODE_HIGH, iBarBegin-iBarEnd, iBarEnd)];
   barLow = Low [Lowest (NULL, 0, MODE_LOW , iBarBegin-iBarEnd, iBarEnd)];
   //iBarBegin = iBarShift(NULL, PERIOD_H4, dtTimeBegin);
   // barHigh = iHigh( NULL, PERIOD_H4, iBarBegin );
   // barLow = iLow( NULL, PERIOD_H4, iBarBegin );
   barSize = NormalizeDouble( barHigh-barLow, Digits );
   log("Asia BreakOut Box found: iBarBegin=="+iBarBegin
     + "\n barHigh==" + barHigh
     + "\n barLow==" + barLow);
   secondH4Barfound = true;
}

int getHourFromTimeStr(string timeStr){
   return TimeHour(StrToTime(TimeToStr(TimeGMT(),TIME_DATE) + " " + timeStr));
}

datetime convertToBrokerTime(datetime dt){
  return dt + BrokerTimeZone*60*60;
}

// double getNextOrderLots(int a_cmd_0) {
//    double ld_ret_4;
//    int datetime_12;
//    switch (MMType) {
//    case 0:
//       ld_ret_4 = g_lot;
//       break;
//    case 1:
//       ld_ret_4 = NormalizeDouble(g_lot * MathPow(g_lotMultiper, g_totalOrderNum), g_lotsDegital);
//       break;
//    case 2:
//       datetime_12 = 0;
//       ld_ret_4 = g_lot;
//       for (int pos_20 = OrdersHistoryTotal() - 1; pos_20 >= 0; pos_20--) {
//          if (!(OrderSelect(pos_20, SELECT_BY_POS, MODE_HISTORY))) return (-3);
//          if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_Magic) {
//             if (datetime_12 < OrderCloseTime()) {
//                datetime_12 = OrderCloseTime();
//                if (OrderProfit() < 0.0) {
//                   ld_ret_4 = NormalizeDouble(OrderLots() * g_lotMultiper, g_lotsDegital);
//                   continue;
//                }
//                ld_ret_4 = g_lot;
//                continue;
//                return (-3);
//             }
//          }
//       }
//    }
//    if (AccountFreeMarginCheck(Symbol(), a_cmd_0, ld_ret_4) <= 0.0) return (-1);
//    if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) return (-2);
//    return (ld_ret_4);
// }

double getOrderLots(){

   if(baseLots < MarketInfo( NULL, MODE_MINLOT)){
      baseLots = MarketInfo( NULL, MODE_MINLOT);
   } else if(baseLots > MarketInfo( NULL, MODE_MAXLOT)){
      baseLots = MarketInfo( NULL, MODE_MAXLOT);
   }
   return baseLots;
}

bool sqOrderOpenedThisBar(int orderMagicNumber) {
   double pl = 0;
   thisBarOrders = 0;
   for(int i=0; i<OrdersTotal(); i++) {
      if (OrderSelect(i,SELECT_BY_POS)==true && OrderSymbol() == Symbol()) {
         if(orderMagicNumber == 0 || OrderMagicNumber() == orderMagicNumber) {
            if(OrderOpenTime() > Time[1]) {
               //return(true);
               thisBarOrders++;
            }
         }
      }
   }

   for(i=OrdersHistoryTotal(); i>=0; i--) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true && OrderSymbol() == Symbol()) {
         if(orderMagicNumber == 0 || OrderMagicNumber() == orderMagicNumber) {
            if(OrderOpenTime() > Time[1]) {
               // return(true);
               thisBarOrders++;
            }
         }
      }
   }

   if(thisBarOrders>0) return true;


   return(false);
}

/*
   type: 0 -- Market Order
         1 -- Pending Order
         2 -- total order
*/
int getTotalOrderByType(int type=0){
   int tot_orders=0, pendingOrders=0, marketOrders=0;
    for(int i=0;i<OrdersTotal();i++){

        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
        if(OrderMagicNumber()==magicNum 
            && OrderSymbol()==Symbol()
            //&& OrderOpenTime() >= dayStartWork
            ) {
            tot_orders=tot_orders+1;
            if(OrderType() <= OP_SELL) marketOrders=marketOrders+1;
            else pendingOrders=pendingOrders+1;
        }
    }
    //Comment("marketOrders--->"+marketOrders
    //        +"\npendingOrders--->"+pendingOrders
    //        +"\ntot_orders--->"+tot_orders);
    if(type==0) return (marketOrders);
    else if(type==1) return (pendingOrders);
    else return (tot_orders);
}


void deleteAllPendngOrders(){
   for(int i=0;i<OrdersTotal();i++){
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
        if(OrderMagicNumber()==magicNum 
            && OrderSymbol()==Symbol()
            && OrderType() > OP_SELL) {
            OrderDelete(OrderTicket());
        }
    }
}

int last_order_type(){ 
   int ord_type=-1;
   int tkt_num=0;
      for(int i=0;i<OrdersTotal();i++){
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
         if(OrderMagicNumber()==magicNum 
            && OrderSymbol()==Symbol()
            && OrderTicket()>tkt_num
        ) {
            ord_type = OrderType();
            tkt_num=OrderTicket();
        }
      }
      return(ord_type);
}

bool deleteTargetOrder(int ticket){
  bool result = false;
  if(OrderSelect( ticket, SELECT_BY_TICKET, MODE_TRADES)){
    result = OrderDelete(ticket);
  }
}

void drawInfo(){
   
   if(ObjectFind(label_name)<0) 
     { 
      //--- create Label object 
      ObjectCreate(0,label_name,OBJ_RECTANGLE_LABEL,0,0,0);            
      //--- set X coordinate 
      ObjectSetInteger(0,label_name,OBJPROP_XDISTANCE,1); 
      //--- set Y coordinate 
      ObjectSetInteger(0,label_name,OBJPROP_YDISTANCE,15);
      //--- set X size 
      ObjectSetInteger(0,label_name,OBJPROP_XSIZE,225); 
      //--- set Y size 
      ObjectSetInteger(0,label_name,OBJPROP_YSIZE,535);
      //--- define background color 
      ObjectSetInteger(0,label_name,OBJPROP_BGCOLOR,clrDarkBlue); 
      //--- define text for object Label 
      ObjectSetString(0,label_name,OBJPROP_TEXT,"Cache");    
      //--- disable for mouse selecting 
      ObjectSetInteger(0,label_name,OBJPROP_SELECTABLE,0);
      //--- set the style of rectangle lines 
      ObjectSetInteger(0,label_name,OBJPROP_STYLE,STYLE_SOLID);
      //--- define border type 
      ObjectSetInteger(0,label_name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      //--- define border width 
      ObjectSetInteger(0,label_name,OBJPROP_WIDTH,1); 
      //--- draw it on the chart 
      ChartRedraw(0);
     }
}

void DoBreakEven(int BP, int BE) {
   bool bres;
   for (int i = 0; i < OrdersTotal(); i++) {
      if ( !OrderSelect (i, SELECT_BY_POS) )  continue;
      if ( OrderMagicNumber() != magicNum || OrderSymbol() != Symbol())  continue;
      if ( OrderType() == OP_BUY ) {
         if (Bid<OrderOpenPrice()+BP*Point) continue;
         if ( OrderOpenPrice()+BE*Point-OrderStopLoss()>Point/10) {
               //Print(BP,"  ",BE," bestop");
               bres=OrderModify (OrderTicket(), OrderOpenPrice(), OrderOpenPrice()+BE*Point, OrderTakeProfit(), 0, Black);
           if (!bres) Print("Error Modifying BE BUY order : ",(GetLastError()));
           else log("Modifying BE BUy order success!!");
         }
      }

      if ( OrderType() == OP_SELL ) {
         if (Ask>OrderOpenPrice()-BP*Point) continue;
         if ( OrderStopLoss()-(OrderOpenPrice()-BE*Point)>Point/10) {
               //Print(BP,"  ",BE," bestop");
               bres=OrderModify (OrderTicket(), OrderOpenPrice(), OrderOpenPrice()-BE*Point, OrderTakeProfit(), 0, Gold);
           if (!bres) Print("Error Modifying BE SELL order : ",(GetLastError()));
           else log("Modifying BE SELL order success!!");
         }
      }
   }
   return;
}

void trail_stop()
{ double new_sl=0; bool OrderMod=false;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()==magicNum && OrderSymbol()==Symbol())
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
               log("Modifying buy order due to trail stope!! "+OrderTicket());
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
               log("Modifying sell order due to trail stope!! "+OrderTicket());
               tries=tries+1;
               
            }
         
         }
         
      }
   }
}

//+---------------------------------------------------------------------------------------------------------------------+
//| The function opens or sets an order                                                                                 |
//| symbol      - symbol, at which a deal is performed.                                                                 |
//| cmd         - a deal Can have any value of trade operations.                                                        |
//| volume      - amount of lots.                                                                                       |
//| price       - Open price.                                                                                           |
//| slippage    - maximum price deviation for market buy or sell orders.         |
//| stoploss    - position close price when an unprofitability level is reached (0 if there is no unprofitability level)|
//| takeprofit  - position close price when a profitability level is reached (0 if there is no profitability level).    |
//| comment     - order comment. The last part of comment can be changed by the trade server.                           |
//| magic       - order magic number. Can be used as an identifier determined by user.                                  |
//| expiration  - pending order expiration time.                                                                        |
//| arrow_color - Opening arrow's color on the chart. If the parameter is missing or its value equals CLR_NONE          |
//|               then the opening arrow is not displayed on the chart.                                                 |
//+---------------------------------------------------------------------------------------------------------------------+
int OrderOpenF(string     OO_symbol,
               int        OO_cmd,
               double     OO_volume,
               double     OO_price,
               int        OO_slippage,
               double     OO_stoploss,
               double     OO_takeprofit,
               string     OO_comment,
               int        OO_magic,
               datetime   OO_expiration,
               color      OO_arrow_color)
  {
   int      result      = -1;    //result of opening an order
   int      Error       = 0;     //error when opening an order
   int      attempt     = 0;     //amount of performed attempts
   int      attemptMax  = 3;     //maximum amount of attempts
   bool     exit_loop   = false; //exit the loop
   string   lang=TerminalInfoString(TERMINAL_LANGUAGE);  //trading terminal language, for defining the language of the messages
   double   stopllvl=NormalizeDouble(MarketInfo(OO_symbol,MODE_STOPLEVEL)*MarketInfo(OO_symbol,MODE_POINT),Digits);  //minimum stop loss/ take profit level, in points
                                                                                                                     //the module provides a safe order opening. 
//--- checking stop orders for buying
   if(OO_cmd==OP_BUY || OO_cmd==OP_BUYLIMIT || OO_cmd==OP_BUYSTOP)
     {
      double tp = (OO_takeprofit - OO_price)/MarketInfo(OO_symbol, MODE_POINT);
      double sl = (OO_price - OO_stoploss)/MarketInfo(OO_symbol, MODE_POINT);
      if(tp>0 && tp<=stopllvl)
        {
         OO_takeprofit=OO_price+stopllvl+2*MarketInfo(OO_symbol,MODE_POINT);
        }
      if(sl>0 && sl<=stopllvl)
        {
         OO_stoploss=OO_price -(stopllvl+2*MarketInfo(OO_symbol,MODE_POINT));
        }
     }
//--- checking stop orders for selling
   if(OO_cmd==OP_SELL || OO_cmd==OP_SELLLIMIT || OO_cmd==OP_SELLSTOP)
     {
       tp = (OO_price - OO_takeprofit)/MarketInfo(OO_symbol, MODE_POINT);
       sl = (OO_stoploss - OO_price)/MarketInfo(OO_symbol, MODE_POINT);
      if(tp>0 && tp<=stopllvl)
        {
         OO_takeprofit=OO_price -(stopllvl+2*MarketInfo(OO_symbol,MODE_POINT));
        }
      if(sl>0 && sl<=stopllvl)
        {
         OO_stoploss=OO_price+stopllvl+2*MarketInfo(OO_symbol,MODE_POINT);
        }
     }
//--- while loop
   while(!exit_loop)
     {
      result=OrderSend(OO_symbol,OO_cmd,OO_volume,OO_price,OO_slippage,OO_stoploss,OO_takeprofit,OO_comment,OO_magic,OO_expiration,OO_arrow_color); //attempt to open an order using the specified parameters
      //--- if there is an error when opening an order
      if(result<0)
        {
         Error = GetLastError();                                     //assign a code to an error
         switch(Error)                                               //error enumeration
           {                                                         //order closing error enumeration and an attempt to fix them
            case  2:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(3000);                                       //3 seconds of delay
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;                                         //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case  3:
               RefreshRates();
               exit_loop = true;                                     //exit while
               break;                                                //exit switch   
            case  4:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(3000);                                       //3 seconds of delay
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case  5:
               exit_loop = true;                                     //exit while
               break;                                                //exit switch   
            case  6:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(5000);                                       //3 seconds of delay
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case  8:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(7000);                                       //3 seconds of delay
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case 64:
               exit_loop = true;                                     //exit while
               break;                                                //exit switch
            case 65:
               exit_loop = true;                                     //exit while
               break;                                                //exit switch
            case 128:
               Sleep(3000);
               RefreshRates();
               continue;                                             //exit switch
            case 129:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(3000);                                       //3 seconds of delay
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case 130:
               exit_loop=true;                                       //exit while
               break;
            case 131:
               exit_loop = true;                                     //exit while
               break;                                                //exit switch
            case 132:
               Sleep(10000);                                         //sleep for 10 seconds
               RefreshRates();                                       //update data
                                                                     //exit_loop = true;                                   //exit while
               break;                                                //exit switch
            case 133:
               exit_loop=true;                                       //exit while
               break;                                                //exit switch
            case 134:
               exit_loop=true;                                       //exit while
               break;                                                //exit switch
            case 135:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case 136:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case 137:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;
                  Sleep(2000);
                  RefreshRates();
                  break;
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;
                  exit_loop=true;
                  break;
                 }
            case 138:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;
                  Sleep(1000);
                  RefreshRates();
                  break;
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;
                  exit_loop=true;
                  break;
                 }
            case 139:
               exit_loop=true;
               break;
            case 141:
               Sleep(5000);
               exit_loop=true;
               break;
            case 145:
               exit_loop=true;
               break;
            case 146:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;
                  Sleep(2000);
                  RefreshRates();
                  break;
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;
                  exit_loop=true;
                  break;
                 }
            case 147:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;
                  OO_expiration=0;
                  break;
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;
                  exit_loop=true;
                  break;
                 }
            case 148:
               exit_loop=true;
               break;
            default:
               Print("Error: ",Error);
               exit_loop=true; //exit while 
               break;          //other options 
           }
        }
      //--- if no errors detected
      else
        {
         if(lang == "Russian") {Print ("The order is successfully opened. ", result);}
         if(lang == "English") {Print("The order is successfully opened.", result);}
         Error = 0;                                //reset the error code to zero
         break;                                    //exit while
                                                   //errorCount =0;                          //reset the amount of attempts to zero
        }
     }
   return(result);
  }
//+------------------------------------------------------------------+


void log(string String)
{
   // if(!debugMode){
   //    return;
   // }
   int Handle;

   //if (!Auditing) return;
   string Filename = "logs\\" + "AsiaBreakOut" + " (" + Symbol() + ", " + strPeriod( Period() ) + 
              ")\\" + TimeToStr( LocalTime(), TIME_DATE ) + ".txt";
              
   Handle = FileOpen(Filename, FILE_READ|FILE_WRITE|FILE_CSV, "/t");
   if (Handle < 1)
   {
      Print("Error opening audit file: Code ", GetLastError());
      return;
   }

   if (!FileSeek(Handle, 0, SEEK_END))
   {
      Print("Error seeking end of audit file: Code ", GetLastError());
      return;
   }

   if (FileWrite(Handle, TimeToStr(CurTime(), TIME_DATE|TIME_SECONDS) + "  " + String) < 1)
   {
      Print("Error writing to audit file: Code ", GetLastError());
      return;
   }

   FileClose(Handle);
}

string strPeriod( int intPeriod )
{
  switch ( intPeriod )
  {
    case PERIOD_MN1: return("Monthly");
    case PERIOD_W1:  return("Weekly");
    case PERIOD_D1:  return("Daily");
    case PERIOD_H4:  return("H4");
    case PERIOD_H1:  return("H1");
    case PERIOD_M30: return("M30");
    case PERIOD_M15: return("M15");
    case PERIOD_M5:  return("M5");
    case PERIOD_M1:  return("M1");
    case PERIOD_M2:  return("M2");
    case PERIOD_M3:  return("M3");
    case PERIOD_M4:  return("M4");
    case PERIOD_M6:  return("M6");
    case PERIOD_M12:  return("M12");
    case PERIOD_M10:  return("M10");
    default:     return("Offline");
  }
}