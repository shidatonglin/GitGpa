//+------------------------------------------------------------------+
//|                                                    InsideBar.mq4 |
//|                                  Copyright 2015, Iglakov Dmitry. |
//|                                               cjdmitri@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Iglakov Dmitry."
#property link      "cjdmitri@gmail.com"
#property version   "1.00"
#property strict

#define uptrend 1
#define downtrend 2
#define uptrend_nothing 3
#define downtrend_nothing 4
#define notrend 5


extern double  lot               = 0.1;                              //Lot Size
extern int     TP                = 300;                              //Take Profit
extern int     SL                = 500;
extern int     magic             = 555124;                           //Magic number
extern int     slippage          = 2;                                //Slippage
extern bool    debugMode         = true;
extern int     maxSpread         = 30;
extern bool    enable            = true;

double   buyPrice,//define BuyStop price
buyTP,      //Take Profit BuyStop
buySL,      //Stop Loss BuyStop
sellPrice,  //define SellStop price
sellTP,     //Take Profit SellStop
sellSL;     //Stop Loss SellStop

double white1, white2, yellow1, yellow2;
string key;
int totalOrder = 0;
static int orderTrend,currentTrend;
double white_10,white_11,white_20,white_21,
      yellow_10,yellow_11,yellow_20,yellow_21;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
    key = "kongfu ";
    return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
    if(!enable) {
      log("Not enabled!!");
      return;
    }
    if(StringFind( Symbol(), "JPY") == -1) 
    { 
      log("Not a jpy pair!!");
      return;
    }
    if(Period() != PERIOD_H2){
      log("Not a H2 chart!!");
      return;
    }
   double   _bid     = NormalizeDouble(MarketInfo(Symbol(), MODE_BID), Digits); //define a lower price 
   double   _ask     = NormalizeDouble(MarketInfo(Symbol(), MODE_ASK), Digits); //define an upper price
   double   _point   = MarketInfo(Symbol(), MODE_POINT);
   double   _spread  = _bid - _ask;
   if(_spread > maxSpread){
     log("Current spread it too large@!");
     return ;
   }

    currentTrend = getCurrentTrend();
    if(currentTrend==3 && currentTrend==4){
      CloseAll();
      return;
    }
    totalOrder = OrdersTotal();
    
    if(totalOrder==0){
      if (currentTrend == 1){
        if(_ask < white_20){
          buyPrice = _ask;
          buySL = _bid - SL*_point;
          buyTP = _bid + TP*_point;
          OrderOpenF(Symbol(),OP_BUY,lot,buyPrice,slippage,buySL,buyTP,key+"Uptrend trade",magic,0,Blue);
          orderTrend = 1;
        }
      } else
      if (currentTrend == 2){
        if(_bid > white_10){
          sellPrice = _bid;
          sellSL = _ask + SL*_point;
          sellTP = _ask - TP*_point;
          OrderOpenF(Symbol(),OP_SELL,lot,sellPrice,slippage,sellSL,sellTP,key+"Downtrend trade",magic,0,Red);
          orderTrend = 2;
        }
      } else
      if (currentTrend == 5){
        if(white_10 > white_11){// uptrend
          if(_ask < white_20){
            buyPrice = _ask;
            buySL = _bid - SL*_point;
            buyTP = _bid + TP*_point;
            OrderOpenF(Symbol(),OP_BUY,lot,buyPrice,slippage,buySL,buyTP,key+"Notread Up trade",magic,0,Blue);
            orderTrend = 5;
          }
        }
        if(white_10 < white_11){// downtrend
          if(_bid > white_10){
            sellPrice = _bid;
            sellSL = _ask + SL*_point;
            sellTP = _ask - TP*_point;
            OrderOpenF(Symbol(),OP_SELL,lot,sellPrice,slippage,sellSL,sellTP,key+"Notread Down trade",magic,0,Red);
            orderTrend = 5;
          }
        }
      }
    } else {
      if(currentTrend == 3 || currentTrend == 4){
        CloseAll();
      }
    }
  }


int getCurrentTrend(){
  int trend = 0;
  white_10 = iCustom(Symbol(),Period(),"liun_interval_index", 1.0, 1.0, 1.2, 0.0, 8.0, 8.0, 1, 0);
  white_11 = iCustom(Symbol(),Period(),"liun_interval_index",1.0, 1.0, 1.2, 0.0, 8.0, 8.0, 1, 1);

  white_20 = iCustom(Symbol(),Period(),"liun_interval_index",1.0, 1.0, 1.2, 0.0, 8.0, 8.0, 0, 0);
  white_21 = iCustom(Symbol(),Period(),"liun_interval_index",1.0, 1.0, 1.2, 0.0, 8.0, 8.0, 0, 1);

  yellow_10 = iCustom(Symbol(),Period(),"liun_interval_trend", 0.0, 2.0, 3.0, 0.0, 20.0, 20.0, 0, 0);
  yellow_11 = iCustom(Symbol(),Period(),"liun_interval_trend", 0.0, 2.0, 3.0, 0.0, 20.0, 20.0, 0, 1);

  yellow_20 = iCustom(Symbol(),Period(),"liun_interval_trend", 0.0, 2.0, 3.0, 0.0, 20.0, 20.0, 1, 0);
  yellow_21 = iCustom(Symbol(),Period(),"liun_interval_trend", 0.0, 2.0, 3.0, 0.0, 20.0, 20.0, 1, 1);

  if (white_21 > yellow_11 && white_20 > white_21)
  {
    trend = uptrend;
  }

  //white2>yellow1 white2[0]<white2[1]
  if (white_21 > yellow_11 && white_20 < white_21)
  {
    trend = uptrend_nothing;
  }

  //white1<yellow2 white1[0]<white1[1]
  if(white_11 < yellow_21 && white_10 < white_11){
    trend = downtrend;
  }
  //white1<yellow2 white1[0]>white1[1]
  if(white_11 < yellow_21 && white_10 > white_11){
    trend = downtrend_nothing;
  }

  //white1 and white2 are between yellow1 and yellow2

  if(yellow_11 > white_11 && white_21 > yellow_21
    &&((white_10 > white_11 && white_20 > white_21 && yellow_10 < yellow_11 && yellow_20 < yellow_21)
      || (white_10 < white_11 && white_20 < white_21 && yellow_10 > yellow_11 && yellow_20 > yellow_21))){
    trend = notrend;
  }
  log("current trend---->"+trend);
  return trend;
}
//+----------------------------------------------------------------------------------------------------------------------+
//| The function opens or sets an order                                                                                  |
//| symbol      - symbol, at which a deal is performed.                                                                  |
//| cmd         - a deal (may be equal to any of the deal values).                                                       |
//| volume      - amount of lots.                                                                                        |
//| price       - Open price.                                                                                            |
//| slippage    - maximum price deviation for market buy or sell orders.                                                 |
//| stoploss    - position close price when an unprofitability level is reached (0 if there is no unprofitability level).|
//| takeprofit  - position close price when a profitability level is reached (0 if there is no profitability level).     |
//| comment     - order comment. The last part of comment can be changed by the trade server.                            |
//| magic       - order magic number. It can be used as a user-defined ID.                                               |
//| expiration  - pending order expiration time.                                                                         |
//| arrow_color - open arrow color on a chart. If the parameter is absent or equal to CLR_NONE,                          |
//|               the open arrow is not displayed on a chart.                                                            |
//+----------------------------------------------------------------------------------------------------------------------+
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
                                                                                                                     //the module provides safe order opening. 
//--- check stop orders for buying
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
//--- check stop orders for selling
   if(OO_cmd==OP_SELL || OO_cmd==OP_SELLLIMIT || OO_cmd==OP_SELLSTOP)
     {
      double tp = (OO_price - OO_takeprofit)/MarketInfo(OO_symbol, MODE_POINT);
      double sl = (OO_stoploss - OO_price)/MarketInfo(OO_symbol, MODE_POINT);
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
         if(lang == "Russian") {Print("Ордер успешно открыт. ", result);}
         if(lang == "English") {Print("The order is successfully opened.", result);}
         Error = 0;                                //reset the error code to zero
         break;                                    //exit while
         //errorCount =0;                          //reset the amount of attempts to zero
        }
     }
   return(result);
  }
//+------------------------------------------------------------------+

void CloseAll()
{

  int total = OrdersTotal();
  for(int i=total-1;i>=0;i--)
  {
    if(!OrderSelect(i, SELECT_BY_POS)) continue;
    if(OrderSymbol()!=Symbol() || OrderMagicNumber()!= magic) continue;
    int type   = OrderType();

    bool result = false;
    
    switch(type)
    {    
      //Close opened long positions
      case OP_BUY       : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                          break;

      //Close pending orders
      case OP_BUYLIMIT  :
      case OP_BUYSTOP   : result = OrderDelete( OrderTicket() );
      
      //Close opened short positions
      case OP_SELL      : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
                          break;

      //Close pending orders
      case OP_SELLLIMIT :
      case OP_SELLSTOP  : result = OrderDelete( OrderTicket() );
    }
    
    if(result == false)
    {
      log("Order " + OrderTicket() + " failed to close. Error:" + GetLastError() );
      Sleep(3000);
    }  
  }  
}  
void TrailingStop()
{
   // int tip,Ticket;
   // double StLo,OSL,OOP;
   // for (int i=0; i<OrdersTotal(); i++) 
   // {  if (OrderSelect(i, SELECT_BY_POS)==true)
   //    {  tip = OrderType();
   //       if (/*OrderSymbol()==symbol &&*/OrderMagicNumber()==Magic)
   //       {
   //          OSL   = NormalizeDouble(OrderStopLoss(),Digits);
   //          OOP   = NormalizeDouble(OrderOpenPrice(),Digits);
   //          Ticket = OrderTicket();
   //          if (tip==OP_BUY)             
   //          {
   //             StLo = NormalizeDouble(Bid-Ts*Point,Digits);
   //             if (StLo > OSL && StLo > OOP)
   //             {  if (!OrderModify(Ticket,OOP,StLo,OrderTakeProfit(),0,White))
   //                   Print("TrailingStop Error ",GetLastError()," buy SL ",OSL,"->",StLo);
   //             }
   //          }                                         
   //          if (tip==OP_SELL)        
   //          {
   //             StLo = NormalizeDouble(Ask+Ts*Point,Digits);
   //             if (StLo > OOP || StLo==0) continue;
   //             if (StLo < OSL || OSL==0 )
   //             {  if (!OrderModify(Ticket,OOP,StLo,OrderTakeProfit(),0,White))
   //                   Print("TrailingStop Error ",GetLastError()," sell SL ",OSL,"->",StLo);
   //             }
   //          } 
   //       }
   //    }
   // }
}

void log(string String)
{
   if(!debugMode){
      return;
   }
   int Handle;

   //if (!Auditing) return;
   string Filename = "logs\\" + key + " (" + Symbol() + ", " + strPeriod( Period() ) + 
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
