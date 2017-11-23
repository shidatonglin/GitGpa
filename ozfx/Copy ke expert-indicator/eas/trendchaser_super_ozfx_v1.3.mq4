#property copyright   "tomhliles@yahoo.com"
#property link        "tomhliles@yahoo.com"
#define SIGNAL_NONE 0
#define SIGNAL_BUY   1
#define SIGNAL_SELL  2
#define SIGNAL_CLOSEBUY 3
#define SIGNAL_CLOSESELL 4 
 extern bool         ma_filter = true;
  extern bool         stochastics = true;
 extern bool         trade_0_line = true;
 extern bool         trade_color_change = true;
 extern bool         trade_the_cross_only = true;
  extern  int       maximum_trades  = 0;
    extern bool use_4_targets= true;
   extern int          tp_1    = 50;
     extern int          tp_2    = 100;
       extern int          tp_3    = 150;
  extern int          tp_4    = 200;
   extern int          BreakEven       = 50;
   extern int          TrailingStop    = 200;
       extern bool   use_ma_sl= false;
   extern bool         use_hidden_stop_loss = true;
  extern int          hidden_sl    = 100;
      extern bool scale_sl= true;
   extern int          sl_1    = 50;
     extern int          sl_2    = 100;
       extern int          sl_3    = 150;
  extern int          sl_4    = 200;
 extern bool shut_down_after_target= false;
   extern int       ma_period  = 200;
    extern int ma_timeframe= 1440;
   extern  double       deviation = 0.01;
    
 extern string auto_b=     "//////////"; 
 extern  bool         auto_balance = false;
 extern int       divisor  = 2;
  extern   bool         custom_balance = false;
 extern double balance =1000;
   extern string money=     "////money management//////"; 
    extern bool close_loss_trail_winns= false;
    extern     bool         close_profit_symbol = false;
     extern  double       profit_target_percent = 0.1;

   extern  double emergency_loss_protection = -100;
       extern  double       Maximum_Risk = 0.5;
    extern double       Lots = 0.01;
     extern int       mm_calculation  = 10000;
            extern  bool         use_martingale = false;
     extern double       multiplier = 100;
   extern  string stealth=     "///for the paranoid////";
  extern  string magic_number=     "///if mn is 0, ea manages all trades////";
  extern int          MagicNumber  = 0;
 extern  string TRADE_COMMENT=     ""; 
  extern bool         close_all_equty_target = false;
  extern double equity_target = 1000;
  extern  double equty_stop_trading= -100;
extern  double equty_cut_off= -100;
    bool         breakeven = False;
  
 
   bool         use_hidden_take_profit = False;
  int          hidden_tp    = 10;
    bool         trail = False;
 


  
double close_lots1=0;
 int       probl  = 1;
int multiply_hedge2= 2;
bool hedge= true;

  bool         buy_only = false;
  bool         sell_only = false;

   bool         use_4_mas = true;
 
    string ema_1=     "//////////";    
    int       ema1_tf  = 0;
     int       ema1_period  = 2;
         string ema_2=     "//////////";    
    int       ema2_tf  = 0;
      int       ema2_period  = 5;
            string ema_3=     "//////////";    
   int       ema3_tf  = 0;
     int       ema3_period  = 200;
                string ema_4=     "/////main trend/////";    
   int       ema4_tf  = 0;
     int       ema4_period  = 1000;

  string overide=     "////will overide the ema//////";        ///////parabolic 

  bool instant_reentry= true;


 

 
 

     
     
         string ema_settings=     "///moving average////";        ///////parabolic 
  bool         ema_filter = false;
  int          ema_period=4000;
  int          ema_tf=1440;
 
 
    string ema_settings2=     "///this only checked if target hit////";        ///////parabolic 
  bool auto_trend= false;
  int          autotrend_tf=240;
  int          autotrend_period=90;
 
 
 
  bool         manual_overide = false;
   bool go_long= true;
   bool         trade_allowed = True;
   bool go_short= true;
bool can_trade1= false;
double  trend2=1;
  bool reverse= false;
  bool dont_trade_monday= false;
  int time_frame=240;
  string entry_buy=     "//////buy settings////////////////";        ///////parabolic
 double    buy_tp_level = 100;
   double    buy_level = 100;
    double    buy_sl_level = 100;
     string entry_sell=     "//////sell settings////////////////";        ///////parabolic    
  double    sell_sl_level = 100;
 double    sell_level = 100;
 double    sell_tp_level = 100;
  string close_options=     "//////////////////////";        ///////parabolic 
  
 
      


    bool         reenter = false;
 bool         use_pivot_hedge = false;
    double       multiply_by = 2;
   bool         use_tp = false;
   bool         use_sl = false;
 

  string mm_options=     "//////////////////////";        ///////parabolic 


  
  
 int          mtrend=0;
  bool use_range_trail= false;
 double trail_pcnt =-0.5;
 int          orders_limit=4;

   bool trail_losers_winners= False;
  bool         use_power_trend = False;
 double pt_risk = 0.2;
 double pt_target = 0.1;
 int          env_period=30;
  double       env_dev = 0.2;
  int          env_tf=5;
bool ma_longs=true;
bool ma_shorts=true;


  bool         auto_tf_settings = false;
     bool         take_a_break = false;
  bool         EachTickMode  = true;
  bool         auto_trade_less_please = False;
  bool         trade_at_the_cross_only = False;
 string parabolic_sar=     "//////parabolic stop and reverse////////////////";        ///////parabolic
 bool         open_with_tc = False;
 bool         close_with_tc = False;
  bool         use_tc_hedge = False;
   double       psar = 0.003;
  double       max = 0.2;
  int          time_frame_for_signal=30;
 string parabolic_sar_2=     "second parabolic stop and reverse//////////////";         ///////parabolic2
  bool         open_with_tc2 = False; 
   bool         close_with_tc2 = False;
   bool         use_tc2_hedge = False;
  double       psar2 = 0.06;
  double       max2 = 0.2;
   int          time_frame_for_signal2=5;
   bool         reverse_second_tc_entry = true;
  bool         reverse_second_tc_exits = false;

   bool         original = false;
  string money_management=     "settings//////////////////////////////////// ";
   bool         manage_all_trades = false;


        double       Max_Lots_allowed    = 50; 
     
          int          max_trades=1000;
    int limit_longs   = 1000;
   int limit_shorts   = 1000;
  bool         close_trades_limit = true;
   int       limit = 1000; 

   bool multiply_hedge =True;
 
    double       hedge_plus = 1;
      bool         dis_dbl_hedge = false;
  double       at_percent_profit = -6;
 string taking_profit=     "settings /////////////////////////////////";



 string high_low=     "h/l filter//////////////////////////////";
    bool         trade_h_l = False;
 
  bool         hi_lo_filter = False;
   double             h_l_tf = 0;
  string pivot_filter1=     "one pivot/////////////////////////////// ";
  bool         one_pivot = False;
  int piv_period= 0;
  double       level =50;
  string pivot_filter2=     "all pivots//////////////////////////////";
   bool         auto_pivot = False;
  double       orders = 20;
    bool         pivot_filter = False;
    bool         open_with_pivots = false;
    
     int          fibshift    = 1;
    bool         show_piv_lines = false;
   string customize_the_pivot=     "longs//////////// ";
  double               h1_tf = 0;
   double    h1 = 100;
    double             h4_tf = 0;
  int       h4 = 100;
    double             d1_tf = 0;
    int       d1 = 100;
    double             w1_tf = 0;
     int       w1 = 100;
      double             mn_tf = 0;
     int       mn = 100;
     string customize_the_pivot2=     "shorts/////////// ";
    double               h1_tfs = 0;
     double    h1s = 0;
      double             h4_tfs = 0;
     int       h4s = 0;
     double             d1_tfs = 0;
     int       d1s = 0;
      double             w1_tfs = 0;
     int       w1s = 0;
      double             mn_tfs = 0;
     int       mns = 0;
bool pivot_long=true;
bool pivot_short=true;
 bool         activ_hi_lo_auto = false;
int profit_level2= -15;

 
  bool         tp_every_hour = false;
 string take_profit_in_percent=     "only effects current chart";
 bool         auto_target = false;
 bool longs= true;
 bool shorts= true;
int total_orders2 = 2;

 double       pros = 0.00;
 double       prob = 0.00;
  double       cu = 0.00;
 bool         hedge_lots = false;
 double       lots_plus = 2;
 double       buy_lots = 0;
   double       sell_lots = 0;



 bool         hedge_now = False;
 string equity_options=     "equity closses trades globally";


 bool         shut_down_ea_after_target = False;

  bool         hedge_at_equty_target = False;
 bool         hedge_at_equty_loss = False;
  double eq_loss_hedge = -5;
 double restart_trading_percent = 0;





 string take_profit_in_dollars=     "only effects current chart";
 bool         profittarget = False;
 double       profitp = 1.99;





bool         trade_less_please_below_margin = False;
 double       cross_margin_level = 75;

 string env=  "//////envelopes hedge";
  bool         hedge_with_envelopes = False;

  string env4=  "//////envelopes";                     ////////////////envelopes
   bool         open_with_envelopes = false;
   bool         close_with_envelopes = False;
    string env2=  "buy options";
   int          envelopes_period_buy = 2;
   int          apply_to_buy = 3;
    int          apply_to_close_buy = 2;
    double       buy = 0.01;
    double       close_buy = 0.01;
    bool         open_buy_upper_line = False;
    bool         exit_buy_upper_line = True;
    bool         open_buy_lower_line = True;
    bool         exit_buy_lower_line = False;
    string env3=  "sell options";
///////////////////////////////////////////////////////
 bool  h1_buy = false;
  bool  h1_sell = false;
  bool  h4_buy = false;
  bool  h4_sell = false;
  bool  day_buy = false;
   bool  day_sell = false;
  bool  week_buy = false;
  bool  week_sell = false;
  bool  month_buy = false;
  bool  month_sell = false;



   bool         mn_pin_long = false;
  bool         mn_pin_short = false;
   bool         w1_pin_long = false;
  bool         w1_pin_short = false;
   bool         d1_pin_long = false;
   bool         d1_pin_short = false;
   bool         h4_pin_long = false;
   bool         h4_pin_short = false;

    int          envelopes_period_sell = 2;
    int          apply_to_sell = 2;
   int          apply_to_close_sell = 3;
   double       sell = 0.01;
    double       close_sell = 0.01;
    int          time_frame_for_env=0;
    bool         open_sell_upper_line = True;
     bool         exit_sell_upper_line = False;
     bool         open_sell_lower_line = False;
    bool         exit_sell_lower_line = True;
 string atr=  "average_true_range";                   ////average_true_range
 bool         use_atr_for_ranges  = False;
 bool           close_with_atr_range_filter = False;
  int          atr_period2=5;
  double          atr_level2=0.0009;
  int          atr_tf2=15;
  string margin_options2="activate ma hedge";       ////hedge_ma_margin
 bool         hedge_ma_if_under_margin = False;
 double       hedge_ma_margin_level = 75;
  string margin_options3="stop trading excluding hedges";    //stop_trades_under_margin
 bool         stop_trades_under_margin = False;
 double       stop_trades_level = 75;
string margin_options4="close profit trades";                ///tp_at_margin_level
bool         tp_at_margin_level = False;
double       tp_margin_level = 5;
int winnpips   = 40;
int losspips   = 20;
  string margin_options5="trail profit trades";        //trail profit trades
 bool         trail_at_margin_level = False;
 double       trail_level = 40;
 bool         scale_sl_at_equityloss = False;
 double Equityslscale = -50;
 bool         scale_tp_at_equityloss = False;
 double Equitytpscale = -50;
 string margin_options6="close all trades";            //close_at_margin_level
 bool         close_at_margin_level = False;
 double       margin_level = -80;
  string margin_options7="activate breakeven";////////////////////activate breakeven
 bool         use_emergency_be = False;
 int start_be_if_orders_exceeds   = 100;
   string indies="moving averages";            ////////////////////moving averages
 bool         open_with_ma = False;
  bool         hedge_with_ma = False;
   string indies2="moving average one";
  int period   = 200;
  int shift   = 0;
  int method   = 0;
  int apply   = 0;
   string indies3="moving average two";
 int period2   = 50;
  int shift2   = 0;
  int method2   = 0;
  int apply2   = 0;
  bool         auto_broker_settings = False;                  ////////////broker



  string trading_time= "///////////////////////////////////////////";                                //////////time

   bool         dont_restrict_hedge = true;
  bool         UseHourTrade_longs = False;
  int          FromHourTrade_longs = 5;
  int          ToHourTrade_longs = 9;
   bool         UseHourTrade_shorts = False;
  int          FromHourTrade_shorts = 5;
  int          ToHourTrade_shorts = 9;
 
  bool         UseHourTrade = False;
  int          FromHourTrade = 5;
  int          ToHourTrade = 9;
  bool         close_all_trades_at_time = False;
  int       CloseHour=21;
  int       CloseMinute=00;
  bool         trade_allowed_longs = true;
  bool         trade_allowed_shorts = true;

 int          StopLoss        = 5000; 
int stop   = 1;
int tstop   = 1;
 bool         use_scale_stop_loss = False;
 int          sscale1        = 10; 
 int          sscale2        = 20; 
 int          sscale3        = 30; 

 int          TakeProfit      = 5000;
 bool         use_scale_take_profit = False;
 int          scale1        = 10; 
 int          scale2        = 20; 
int          scale3        = 30; 


 string alerts= "notification options//////////////////////////////////";                          ////////////////////notification
 bool         Use_popup_and_sound_alert = False;
 bool         Use_Sound_only = False;
 bool         email_notification     = False; 
   bool         comments = True;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool         closepending = False;
string              epsar2dir = "none";
string              psar2dir = "none";
string              envsmode = "none";
string              envcsmode = "none";
string              envbmode = "none";
string              envcbmode = "none";
string              automode = "none";
string              mode = "none";
string              direc = "none";
string              tick_mode = "none";
string              mode_for_entry = "none";
string              mode_for_exit = "none";
string              status = "do not trade this pair";

string       swap  = "2=buy 0=sell 1=no trade";
double       swap_direction = 1;
bool         swap_direction_only = False;
double       pro = 1;
double longg = 0;
double shor = 0;

double       pcnt = 0.0;
double       symbol_profit = 0.0;
bool         close_margin_equity = False;
bool         hedgelong = False;
bool         hedgeshort = False;
bool         testOpen = True;
int      openLongs = 0;                  //  how many longs are open 
int      openShorts = 0; 
int      openLongsp = 0;     
int      aopenLongs = 0;                  //  how many longs are open 
int      aopenShorts = 0;     //  how many longs are open 
int      openShortsp = 0;
string average_true_range="//////filter";
bool         hedge_equty_loss = False;
int          atr_period=1;
double          atr_level=0;
int          atr_tf=0;
string              Message = "new alert from trendchaser";
string              NameFileSound = "alert.wav";
bool         refresh = True;
bool   TradeAllowed=true; 
datetime bartime=1;                          // used to determine when a bar has moved
int      bartick=0;                          // number of times bars have moved
bool         normal_entry = False;
bool         enter_at_ma = False;
int          ma=2;
bool         allow_longs = True;
bool         allow_shorts = True;
bool         can_trade_long = True;
bool         can_trade_shorts = True;
int trend   = 0;

bool         trade_allowedp = True;
bool         demo_account_only = false;//////////////////////////////////////////////////////demo only?
bool         use_account = false;
int account_number   = 21414;                         /////////////////////////////////////customers account number
/////////////////////////////////////////set expiration date
bool can_trade= false;
bool pswrd = false;
string              pswrd1 = "trendchaser";           /////////////////////////////////////set a password
 string              password = "trendchaser";
 string custom_trade=     "0-Sunday,1,2,3,4,5,6";
 string symbol=     "GBPJPYm";
 double       lots_for_custom = 0.01;
 bool         custom_short_trade = false;
 bool         custom_long_trade = false;
 int          open_Hour = 0;
 int          minute = 0;
 int          day_of_week = 0;
 int          sl = 5000;
 int          tp = 5000;
 int       custom_magic  = 95;
   bool         reset = false;
string trendd="none";
 bool         use_expiration = false;
string              expiration_date = "2008.05.01";
 int          total_orders    = 0;
 

 bool         trade_w1_fib = false;
 int trade=0;
  int trades=0;
  int trade2=0;
  int trades2=0;
  int trade3=0;
  int trades3=0;
 int w0=0;
 int w01=0;
  double       profb = 0.0;

      double       profs = 0.0;
        bool         risk_protection = true;

 
 string show_fibo_levels=     "standard fibs ";
 bool         show_h1 = false;
    bool         show_h4 = false;
  bool         show_d1 = false;
   bool         show_d11 = false;
     bool         show_w1 = false;
      bool         show_mn = false;
     bool         activate_martingale_at_margin = False;
 double       Min_Lots_allowed    = 0.01;
  double       Dis_Mm_If_Lots_Under  = 0.01;
 

 double       lots_increase_when_losing = 0;
 int          losses_without_a_break    = 0;
   bool         auto_h4_settings = false;
 bool         h4_settings = false;
 bool         m5_settings = false;
    bool         auto_time_frame = false;


int BarCount;
int Current;
bool TickCheck = False;
double LotsOptimized()

  {
  string currentSymbol = Symbol();
 double    LL=MarketInfo(currentSymbol,MODE_LOTSTEP);
 double    LOT=MarketInfo(currentSymbol,MODE_MINLOT);
 
   double lot=Lots;
   int    orders=HistoryTotal();
   int    losses=losses_without_a_break;
   
   if(use_martingale==false&&LL==0.001)
   lot=NormalizeDouble(balance*Maximum_Risk/mm_calculation,3);
    // close_lots1= NormalizeDouble(lot/5,3);
      if(use_martingale&&LL==0.001)
   lot=NormalizeDouble(balance*Maximum_Risk/mm_calculation*OrdersTotal()/multiplier,3);
    // close_lots1= NormalizeDouble(lot/5,3);
   
   if(use_martingale==false&&LL==0.01)
   lot=NormalizeDouble(balance*Maximum_Risk/mm_calculation,2);
   //  close_lots1= NormalizeDouble(lot/5,2);
      if(use_martingale&&LL==0.01)
   lot=NormalizeDouble(balance*Maximum_Risk/mm_calculation*OrdersTotal()/multiplier,2);
   //  close_lots1= NormalizeDouble(lot/5,2);
   
   if(use_martingale==false&&LL==0.1)
   lot=NormalizeDouble(balance*Maximum_Risk/mm_calculation,1);
  //  close_lots1= NormalizeDouble(lot/5,1);
      if(use_martingale&&LL==0.1)
   lot=NormalizeDouble(balance*Maximum_Risk/mm_calculation*OrdersTotal()/multiplier,1);
 //close_lots1= NormalizeDouble(lot/5,1);
   if(lots_increase_when_losing>0)
     {
      for(int i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!"); break; }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) continue;
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
        }
      if(losses>0) lot=NormalizeDouble(lot+lot+losses/lots_increase_when_losing,2);
     }
   if(lot<Dis_Mm_If_Lots_Under) lot=Lots;
   if(lot> Max_Lots_allowed) lot=Max_Lots_allowed;
  
   return(lot);
  }
  
  void hidden_take_profit()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( OrderSymbol()==Symbol()  )
     {
  if (probl==2&&OrderType() == OP_BUY &&  OrderOpenPrice()+hidden_tp*Point<=Bid )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
  if (probl==2&&OrderType() == OP_SELL &&  OrderOpenPrice()-hidden_tp*Point>=Ask  )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
  
      }
  }
  return;
}
void hidden_take_profit_1()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( OrderSymbol()==Symbol()  )
     {
  if (probl==2&&OrderType() == OP_BUY &&  OrderOpenPrice()+tp_1*Point<Bid )  result = OrderClose( OrderTicket(), close_lots1, MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
  if (probl==2&&OrderType() == OP_SELL &&  OrderOpenPrice()-tp_1*Point>Ask  )  result = OrderClose( OrderTicket(), close_lots1, MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
  
      }
  }
  return;
}
void hidden_take_profit_2()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( OrderSymbol()==Symbol()  )
     {
  if (probl==2&&OrderType() == OP_BUY &&  OrderOpenPrice()+tp_2*Point<Bid )  result = OrderClose( OrderTicket(), close_lots1, MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
  if (probl==2&&OrderType() == OP_SELL &&  OrderOpenPrice()-tp_2*Point>Ask  )  result = OrderClose( OrderTicket(), close_lots1, MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
  
      }
  }
  return;
}
void hidden_take_profit_3()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( OrderSymbol()==Symbol()  )
     {
  if (probl==2&&OrderType() == OP_BUY &&  OrderOpenPrice()+tp_3*Point<Bid )  result = OrderClose( OrderTicket(), close_lots1, MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
  if (probl==2&&OrderType() == OP_SELL &&  OrderOpenPrice()-tp_3*Point>Ask  )  result = OrderClose( OrderTicket(), close_lots1, MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
  
      }
  }
  return;
}
void hidden_take_profit_4()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( OrderSymbol()==Symbol()  )
     {
  if (probl==2&&OrderType() == OP_BUY &&  OrderOpenPrice()+tp_4*Point<Bid )  result = OrderClose( OrderTicket(), close_lots1, MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
  if (probl==2&&OrderType() == OP_SELL &&  OrderOpenPrice()-tp_4*Point>Ask  )  result = OrderClose( OrderTicket(), close_lots1, MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
  
      }
  }
  return;
}
void hidden_stop_loss1()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( OrderSymbol()==Symbol()  )
     {
  if (probl==2&&OrderType() == OP_BUY &&  OrderOpenPrice()-sl_1*Point>=Bid )  result = OrderClose( OrderTicket(), close_lots1, MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
  if (probl==2&&OrderType() == OP_SELL &&  OrderOpenPrice()+sl_1*Point<=Ask  )  result = OrderClose( OrderTicket(), close_lots1, MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
  
      }
  }
  return;
}
void hidden_stop_loss2()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( OrderSymbol()==Symbol()  )
     {
  if (probl==2&&OrderType() == OP_BUY &&  OrderOpenPrice()-sl_2*Point>=Bid )  result = OrderClose( OrderTicket(), close_lots1, MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
  if (probl==2&&OrderType() == OP_SELL &&  OrderOpenPrice()+sl_2*Point<=Ask  )  result = OrderClose( OrderTicket(), close_lots1, MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
  
      }
  }
  return;
}
void hidden_stop_loss3()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( OrderSymbol()==Symbol()  )
     {
  if (probl==2&&OrderType() == OP_BUY &&  OrderOpenPrice()-sl_3*Point>=Bid )  result = OrderClose( OrderTicket(), close_lots1, MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
  if (probl==2&&OrderType() == OP_SELL &&  OrderOpenPrice()+sl_3*Point<=Ask  )  result = OrderClose( OrderTicket(), close_lots1, MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
  
      }
  }
  return;
}
void hidden_stop_loss4()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( OrderSymbol()==Symbol()  )
     {
  if (probl==2&&OrderType() == OP_BUY &&  OrderOpenPrice()-sl_4*Point>=Bid )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
  if (probl==2&&OrderType() == OP_SELL &&  OrderOpenPrice()+sl_4*Point<=Ask  )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
  
      }
  }
  return;
}
void hidden_stop_loss()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( OrderSymbol()==Symbol()  )
     {
  if (probl==2&&OrderType() == OP_BUY &&  OrderOpenPrice()-hidden_sl*Point>=Bid )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
  if (probl==2&&OrderType() == OP_SELL &&  OrderOpenPrice()+hidden_sl*Point<=Ask  )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
  
      }
  }
  return;
}



void trail_losers()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( OrderSymbol()==Symbol()  )
     {
  if (probl==2&&OrderProfit()<0&&OrderType() == OP_BUY )  result = OrderModify(OrderTicket(), OrderOpenPrice(),Ask - TrailingStop * Point, OrderTakeProfit(),  Red);
  if (probl==2&&OrderProfit()<0&&OrderType() == OP_SELL )  result =OrderModify(OrderTicket(), OrderOpenPrice(),Bid + TrailingStop * Point,OrderTakeProfit(),   Red);
      trail();   
      }
  }
  return;
}
void scale_take_profit()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( probl==2&&OrderSymbol()==Symbol()  )
     {
  if (OrderType() == OP_BUY &&  OrderOpenPrice()+scale1*Point<=Bid )  result = OrderClose( OrderTicket(), OrderLots()/3, MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
  if (OrderType() == OP_SELL &&  OrderOpenPrice()-scale1*Point>=Ask  )  result = OrderClose( OrderTicket(), OrderLots()/3, MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
  
      }
  }
  return;
}
void scale_take_profit2()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( probl==2&&OrderSymbol()==Symbol()  )
     {
  if (OrderType() == OP_BUY &&  OrderOpenPrice()+scale2*Point<=Bid )  result = OrderClose( OrderTicket(), OrderLots()/2, MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
  if (OrderType() == OP_SELL &&  OrderOpenPrice()-scale2*Point>=Ask  )  result = OrderClose( OrderTicket(), OrderLots()/2, MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
  
      }
  }
  return;
}
void scale_take_profit3()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( probl==2&&OrderSymbol()==Symbol()  )
     {
  if (OrderType() == OP_BUY &&  OrderOpenPrice()+scale3*Point<=Bid )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
  if (OrderType() == OP_SELL &&  OrderOpenPrice()-scale3*Point>=Ask  )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
  
      }
  }
  return;
}
void scale_stop_loss()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( OrderSymbol()==Symbol()  )
     {
  if (OrderType() == OP_BUY &&  OrderOpenPrice()-sscale1*Point>=Bid )  result = OrderClose( OrderTicket(), OrderLots()/3, MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
  if (OrderType() == OP_SELL &&  OrderOpenPrice()+sscale1*Point<=Ask  )  result = OrderClose( OrderTicket(), OrderLots()/3, MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
  
      }
  }
  return;
}
void scale_stop_loss2()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( OrderSymbol()==Symbol()  )
     {
  if (OrderType() == OP_BUY &&  OrderOpenPrice()-sscale2*Point>=Bid )  result = OrderClose( OrderTicket(), OrderLots()/2, MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
  if (OrderType() == OP_SELL &&  OrderOpenPrice()+sscale2*Point<=Ask  )  result = OrderClose( OrderTicket(), OrderLots()/2, MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
  
      }
  }
  return;
}
void scale_stop_loss3()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( OrderSymbol()==Symbol()  )
     {
  if (OrderType() == OP_BUY &&  OrderOpenPrice()-sscale3*Point>=Bid )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
  if (OrderType() == OP_SELL &&  OrderOpenPrice()+sscale3*Point<=Ask  )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
  
      }
  }
  return;
}
  void Closelongs()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if (probl==2&& OrderSymbol()==Symbol()  )
     {
           if ( OrderType() == OP_BUY )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
           if ( OrderType() > 1 ) result = OrderDelete( OrderTicket() );
 
      }
  }
  return;
}
void Closepending()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( OrderSymbol()==Symbol()   )  
     {
           if ( OrderType() > 1 ) result = OrderDelete( OrderTicket() );
      }
  }
  return;
}
void Closelongsinprofit()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( OrderSymbol()==Symbol()   )
    if ( probl==2&& OrderProfit()==-losspips*LotsOptimized()  ) 
     {
           if ( OrderType() == OP_BUY )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
      }
  }
  return;
}
void Closelosers()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if (probl==2&& OrderSymbol()==Symbol()  )
    
     {
           if (OrderProfit()<0&&OrderOpenTime()<Time[5]&& OrderType() == OP_BUY )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
     if (OrderProfit()<0&&OrderOpenTime()<Time[5]&& OrderType() == OP_SELL )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
 trail();
      }
  }
  return;
}
void mCloselosers()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( probl==2&&OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber )
    
     {
           if (OrderProfit()<0&&OrderOpenTime()<Time[5]&& OrderType() == OP_BUY )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
     if (OrderProfit()<0&&OrderOpenTime()<Time[5]&& OrderType() == OP_SELL )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
 trail();
      }
  }
  return;
}
void Closeshortsinprofit()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( probl==2&&OrderSymbol()==Symbol()   )
    if (  OrderProfit()==-losspips*LotsOptimized()  ) 
     {
           if ( OrderType() == OP_SELL )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
      }
  }
  return;
}
void Closeshorts()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( probl==2&&OrderSymbol()==Symbol()   )
     {
           if ( OrderType() == OP_SELL )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
      }
  }
  return;
}
 void mClose_target()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if (probl==2&& OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber  )
     {
if (  OrderSymbol()==Symbol()&&OrderType() == OP_BUY )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
if ( OrderSymbol()==Symbol()&&OrderType() == OP_SELL )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );

         RefreshRates();
         if(total_orders>0)
         mClose_target();
         if(total_orders==0)
         trend2=1;
      }
  }
  return;
}
  void Close_target()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if (probl==2&& OrderSymbol()==Symbol()   )
     {
if (  OrderSymbol()==Symbol()&&OrderType() == OP_BUY )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
if ( OrderSymbol()==Symbol()&&OrderType() == OP_SELL )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );

         RefreshRates();
         if(total_orders>0)
         Close_target();
         if(total_orders==0)
         trend2=1;
      }
  }
  return;
}

void Closeprofit()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if (probl==2&& OrderSymbol()==Symbol()   )
     {
if ( OrderProfit()>0&& OrderSymbol()==Symbol()&&OrderType() == OP_BUY )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
if ( OrderProfit()>0&&OrderSymbol()==Symbol()&&OrderType() == OP_SELL )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );

      }
  }
  return;
}
void Closeppall()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if (probl==2&& refresh  )
     {
if (  OrderType() == OP_BUY )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
if ( OrderType() == OP_SELL )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
         RefreshRates();
         if(total_orders>0)
         Closeppall();
      }
  }
  return;
}
void breakeven()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if (trail==false&& probl==2&&OrderSymbol()==Symbol()  )
     {
           if ( OrderType() == OP_BUY &&High[0]-OrderOpenPrice()>=BreakEven*Point && OrderStopLoss()!=OrderOpenPrice())  result = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Green);
           if ( OrderType() == OP_SELL &&OrderOpenPrice()-Low[0]>=BreakEven*Point && OrderStopLoss()!=OrderOpenPrice())  result = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Green);
            int error=GetLastError();
      }
  }
  return;
}
void profittarget()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if (probl==2&& OrderSymbol()==Symbol() &&pro>=profitp )
     {
           if ( OrderType() == OP_BUY )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
           if ( OrderType() == OP_SELL )  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );

    }
  }
  return;
}
void close_all_orders()
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
close_all_orders();
   }
  }
  return;
}

/*void close_symbol_orders()
{
  int total = OrdersTotal();
  for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();

    bool result = false;
    if ( OrderSymbol()==Symbol() )
    
    switch(type)
    {
      //Close opened long positions
      case OP_BUY       : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                          
      
      //Close opened short positions
      case OP_SELL      : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
                          


  
   }
  }
  return;
}*/
void morders()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( OrderMagicNumber()==MagicNumber&&OrderSymbol()==Symbol()   )
     {
           if ( OrderType() == OP_SELL )  {openShorts=openShorts+1;}
           if ( OrderType() == OP_BUY )   {openLongs=openLongs+1;}
           if ( OrderType() == OP_SELL )  {pro=pro+OrderProfit();}
           if ( OrderType() == OP_BUY )   {pro=pro+OrderProfit();}
           if ( OrderType() == OP_SELL )  {profb=profb+OrderProfit();}
           if ( OrderType() == OP_BUY )   {profs=profs+OrderProfit();}
           if ( OrderType() == OP_SELL )  {pros=pros+OrderLots();}
           if ( OrderType() == OP_BUY )   {prob=prob+OrderLots();}
      }
  }
  return;
}
void orders()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if ( OrderSymbol()==Symbol()   )
     {
           if ( OrderType() == OP_SELL )  {openShorts=openShorts+1;}
           if ( OrderType() == OP_BUY )   {openLongs=openLongs+1;}
           if ( OrderType() == OP_SELL )  {pro=pro+OrderProfit();}
           if ( OrderType() == OP_BUY )   {pro=pro+OrderProfit();}
           if ( OrderType() == OP_SELL )  {profb=profb+OrderProfit();}
           if ( OrderType() == OP_BUY )   {profs=profs+OrderProfit();}
           if ( OrderType() == OP_SELL )  {pros=pros+OrderLots();}
           if ( OrderType() == OP_BUY )   {prob=prob+OrderLots();}
      }
  }
  return;
}
void accorders()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if (OrderType() == OP_SELL|| OrderType() == OP_BUY )
     {
           if ( OrderType() == OP_SELL )  {aopenShorts=aopenShorts+1;}
           if ( OrderType() == OP_BUY )  {aopenLongs=aopenLongs+1;}
      }
  }
  return;
}
void maccorders()
{
  int totalorders = OrdersTotal();
  for(int i=totalorders-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
    if (OrderMagicNumber()==MagicNumber&&OrderType() == OP_SELL|| OrderType() == OP_BUY )
     {
           if ( OrderType() == OP_SELL )  {aopenShorts=aopenShorts+1;}
           if ( OrderType() == OP_BUY )  {aopenLongs=aopenLongs+1;}
      }
  }
  return;
}
/*void trail2() 
  {
  for (int i = 0; i < OrdersTotal(); i++) {
     OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
     if ( OrderSymbol()==Symbol() &&OrderMagicNumber()==1||OrderMagicNumber()==2||OrderMagicNumber()==3||OrderMagicNumber()==4 ||OrderMagicNumber()==5||OrderMagicNumber()==6)  // only look if mygrid and symbol...
        {
            if (OrderType() == OP_BUY) {
               if (Bid - OrderOpenPrice() > 100 * MarketInfo(OrderSymbol(), MODE_POINT)) {
                  if (OrderStopLoss() < Bid - 100 * MarketInfo(OrderSymbol(), MODE_POINT)) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), Bid - 100 * MarketInfo(OrderSymbol(), MODE_POINT), OrderTakeProfit(), Red);
                  }
               }
            } else if (OrderType() == OP_SELL) {
               if (OrderOpenPrice() - Ask > 100 * MarketInfo(OrderSymbol(), MODE_POINT)) {
                  if ((OrderStopLoss() > Ask + 100 * MarketInfo(OrderSymbol(), MODE_POINT)) || 
                        (OrderStopLoss() == 0)) {
                     OrderModify(OrderTicket(), OrderOpenPrice(),
                        Ask + 100 * MarketInfo(OrderSymbol(), MODE_POINT), OrderTakeProfit(), Red);
             }
               }
            }
        }
	  }
	  }*/
void trail() 
  {
  for (int i = 0; i < OrdersTotal(); i++) {
     OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
     if ( probl==2&&OrderSymbol()==Symbol()  )  // only look if mygrid and symbol...
        {
            if (OrderType() == OP_BUY) {
               if (Bid - OrderOpenPrice() > TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT)) {
                  if (OrderStopLoss() < Bid - TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT)) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT), OrderTakeProfit(), Red);
                  }
               }
            } else if (OrderType() == OP_SELL) {
               if (OrderOpenPrice() - Ask > TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT)) {
                  if ((OrderStopLoss() > Ask + TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT)) || 
                        (OrderStopLoss() == 0)) {
                     OrderModify(OrderTicket(), OrderOpenPrice(),
                        Ask + TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT), OrderTakeProfit(), Red);
                  }
               }
            }
        }
	  }
	  }
	 
int init() {
   BarCount = Bars;
   if (EachTickMode) Current = 0; else Current = 1;
   return(0);
}
int deinit() {
ObjectsDeleteAll(0, OBJ_HLINE);
   return(0);
}
int start()
  {
 
  if (UseHourTrade_longs){
   if((Hour()<FromHourTrade_longs)||(Hour()>ToHourTrade_longs))
trade_allowed_longs= false;
  {
     }
   }
  if (UseHourTrade_longs){
   if((Hour()>=FromHourTrade_longs)&&(Hour()<=ToHourTrade_longs))
trade_allowed_longs= true;
  {
     }
   }
  if (UseHourTrade_shorts){
   if((Hour()<FromHourTrade_shorts)||(Hour()>ToHourTrade_shorts))
trade_allowed_shorts= false;
  {
     }
   }
  if (UseHourTrade_shorts){
   if((Hour()>=FromHourTrade_shorts)&&(Hour()<=ToHourTrade_shorts))
trade_allowed_shorts= true;
  {
     }
   }
   if (auto_balance) { 
balance = AccountBalance()/divisor;
                 {
     }
   }
  if (auto_balance==false&&custom_balance==false) { 
balance = AccountBalance();
                 {
     }
   }
 if (auto_tf_settings&&Period()==PERIOD_M1) { 
      psar = 0.003;
         time_frame_for_signal=30;
     psar2 = 0.06;
        time_frame_for_signal2=5;
                 {
     }
   }
   if (auto_tf_settings&&Period()==PERIOD_M5) { 
      psar = 0.003;
         time_frame_for_signal=30;
     psar2 = 0.06;
        time_frame_for_signal2=5;
                 {
     }
   }
   if (auto_tf_settings&&Period()==PERIOD_M15) { 
      psar = 0.003;
         time_frame_for_signal=30;
     psar2 = 0.06;
        time_frame_for_signal2=5;
                 {
     }
   }
   if (auto_tf_settings&&Period()==PERIOD_M30) { 
      psar = 0.003;
         time_frame_for_signal=30;
     psar2 = 0.06;
        time_frame_for_signal2=5;
                 {
     }
   }
   if (auto_tf_settings&&Period()==PERIOD_H1) { 
      psar = 0.001;
         time_frame_for_signal=240;
     psar2 = 0.002;
        time_frame_for_signal2=60;
                 {
     }
   }
   if (auto_tf_settings&&Period()==PERIOD_H4) { 
      psar = 0.001;
         time_frame_for_signal=240;
     psar2 = 0.002;
        time_frame_for_signal2=60;
                 {
     }
   }
   if (auto_tf_settings&&Period()==PERIOD_D1) { 
      psar = 0.001;
         time_frame_for_signal=240;
     psar2 = 0.002;
        time_frame_for_signal2=60;
                 {
     }
   }
   if (auto_tf_settings&&Period()==PERIOD_W1) { 
      psar = 0.001;
         time_frame_for_signal=240;
     psar2 = 0.002;
        time_frame_for_signal2=60;
                 {
     }
   }
   if (auto_tf_settings&&Period()==PERIOD_MN1) { 
      psar = 0.001;
         time_frame_for_signal=240;
     psar2 = 0.002;
        time_frame_for_signal2=60;
                 {
     }
   }
   /* if (original) { 
profit_target_percent = 0.1;

Maximum_Risk = 0.1;
      psar = 0.003;
         time_frame_for_signal=30;
     psar2 = 0.06;
        time_frame_for_signal2=5;
                 {
     }
   }
   if (reset) { 
   profit_target_percent = 0.5;

Maximum_Risk = 0.5;
      psar = 0.001;
         time_frame_for_signal=240;
     psar2 = 0.002;
        time_frame_for_signal2=60;
                 {
     }
   }*/
  /*if (h4_settings) { 
  m5_settings = false;
        auto_time_frame = false;
        autofibs = false;
    orders = 20;
        pivot_filter = true;
              h1_tf = 60;
    h1 = 50;
             h4_tf = 240;
      h4 = 50;
          d1_tf = 1440;
     d1 = 50;
            w1_tf = 10080;
      w1 = 50;
            mn_tf = 43200;
      mn = 50;
              h1_tfs = 60;
   h1s = 50;
           h4_tfs = 240;
      h4s = 50;
            d1_tfs = 1440;//
      d1s = 50;
            w1_tfs = 10080;
      w1s = 50;
            mn_tfs = 43200;
   mns = 50;
      auto_target = false;
         losses_without_a_break    = 0;
         max_trades=1000;
 limit_longs   = 1000;
limit_shorts   = 1000;
        close_trades_limit = true;
      limit = 1000;
multiply_hedge =True;
      hedge_plus = 1;
    EachTickMode  = true;
        auto_trade_less_please = False;
         trade_at_the_cross_only = False;
        open_with_tc = true;
        close_with_tc = False;
      use_tc_hedge = true;
      psar = 0.003;
      max = 0.2;
         time_frame_for_signal=240;
      open_with_tc2 = true;
        close_with_tc2 = False;
      use_tc2_hedge = False;
     psar2 = 0.06;
     max2 = 0.2;
        time_frame_for_signal2=240;
  h1_buy = false;
  h1_sell = false;
  h4_buy = false;
  h4_sell = false;
  day_buy = false;
 day_sell = false;
  week_buy = false;
 week_sell = false;
 month_buy = false;
 month_sell = false;
       mn_pin_long = true;
       mn_pin_short = true;
       w1_pin_long = true;
      w1_pin_short = true;
      d1_pin_long = true;
     d1_pin_short = true;
     h4_pin_long = true;
   h4_pin_short = true;

                 {
     }
   }*/
/////////////////////////////////////////////////////////////////////////////////
  double pcnt =( (AccountEquity()-AccountBalance()) / AccountBalance())*100;

  int total_orders = openShorts+openLongs;
  
  int difference = openShorts-openLongs;
int pipps = pro/LotsOptimized()*5000;
int fibshift=1;
if (auto_trade_less_please&&total_orders==0) {          
trade_at_the_cross_only = false;
                  {
     }
   }
if (use_range_trail==false&&auto_trade_less_please&&total_orders>0) {           
trade_at_the_cross_only = True;
                  {
     }
   }
   if (auto_trade_less_please&&total_orders2==2) {          
trade_at_the_cross_only = True;
                  {
     }
   }
if (time_frame==1440&&DayOfWeek()==0||DayOfWeek()==1) {          
 fibshift=2;
                  {
     }
   }
   if (time_frame==1440&&DayOfWeek()>1) {          
 fibshift=1;
                  {
     }
   }
   
double total_lots = pros + prob;


 // buy_lots=NormalizeDouble(pros - prob,10);
 // sell_lots=NormalizeDouble(prob - pros,10);
double buy_lots = total_lots - prob ;
double sell_lots = total_lots - pros ;
double cl = iClose(NULL, 0, Current + 0);
double env = iEnvelopes(NULL, env_tf, env_period, MODE_SMMA, 0, 0, env_dev, MODE_UPPER, Current + 0);
double env2 = iEnvelopes(NULL, env_tf, env_period, MODE_SMMA, 0, 0, env_dev, MODE_LOWER, Current + 0);
double m1 = iMA(NULL, 0, period, shift, method, apply, Current + 1);
double m2 = iMA(NULL, 0, period2, shift2, method2, apply2, Current + 1);
    double tcc = iClose(NULL, 0, Current + 0);
double tccc = iSAR(NULL, time_frame_for_signal, psar, max, Current + 0);   
      double tcc2 = iClose(NULL, 0, Current + 0);
double tccc2 = iSAR(NULL, time_frame_for_signal2, psar2, max2, Current + 0); 
  double atr1= iATR(NULL,atr_tf2,atr_period2,0);
double atr21= atr_level2;
double ma = iMA(NULL, ema_tf, ema_period, shift, 1, apply, Current + 0);

double ma2 = iMA(NULL, autotrend_tf, autotrend_period, 0, 0, 0, Current + 0);
double ema1 = iMA(NULL, ema1_tf, ema1_period, 0, 0, 1,  0);
double ema2 = iMA(NULL, ema2_tf, ema2_period, 0, 0, 1,  0);
double ema3 = iMA(NULL, ema3_tf, ema3_period, 0, 0, 1,  0);
double ema4 = iMA(NULL, ema4_tf, ema4_period, 0, 0, 1,  0);
double ema31 = iMA(NULL, ema3_tf, ema3_period, 0, 0, 1,  1);
double ema41 = iMA(NULL, ema4_tf, ema4_period, 0, 0, 1,  1);

 

if (auto_trend&&trend2==1&&cl>ma2) { 
trend2=2;
buy_only=true;
sell_only=false;
                 {
     }
   }
   if (auto_trend&&trend2==1&&cl<ma2) { 
trend2=2;
buy_only=false;
sell_only=true;
                 {
     }
   }
if (use_power_trend&&cl>env||cl<env2) { 
Maximum_Risk = pt_risk;
profit_target_percent = pt_target;
                 {
     }
   }
   if (use_power_trend&&cl<env&&cl>env2) { 
Maximum_Risk = 0.1;
profit_target_percent = 0.1;
                 {
     }
   }
 if (ema_filter&&cl>ma) { 
ma_longs=true;
ma_shorts=false;
                 {
     }
   }
  if (ema_filter&&cl<ma) { 
ma_longs=false;
ma_shorts=true;
                 {
     }
   }
   if (ema_filter==false) { 
ma_longs=true;
ma_shorts=true;
                 {
     }
   }
   /////////////////////////////////////////////////////////////////////////////////////////
     double sch= iHigh(NULL,time_frame,0);
double scl= iLow(NULL,time_frame,0);
double sco= iOpen(NULL,time_frame,0);
double scc= iClose(NULL,time_frame,0);

  double sch1= iHigh(NULL,time_frame,1);
double scl1= iLow(NULL,time_frame,1);
double sco1= iOpen(NULL,time_frame,1);
double scc1= iClose(NULL,time_frame,1);

//////////////////////////////////////////////////////////////////////////////////////////////
         double m_h= iHigh(NULL,time_frame,1);
double m_l= iLow(NULL,time_frame,1);
double m_o= iOpen(NULL,time_frame,1);
double m_c= iClose(NULL,time_frame,1);

double m2_h= iHigh(NULL,time_frame,2);
double m2_l= iLow(NULL,time_frame,2);
double m2_o= iOpen(NULL,time_frame,2);
double m2_c= iClose(NULL,time_frame,2);
   ////////////////////////////////
         double w_h= iHigh(NULL,time_frame,1);
double w_l= iLow(NULL,time_frame,1);
double w_o= iOpen(NULL,time_frame,1);
double w_c= iClose(NULL,time_frame,1);

double w2_h= iHigh(NULL,time_frame,2);
double w2_l= iLow(NULL,time_frame,2);
double w2_o= iOpen(NULL,time_frame,2);
double w2_c= iClose(NULL,time_frame,2);
   ////////////////////////////////
         double h1_h= iHigh(NULL,time_frame,1);
double h1_l= iLow(NULL,time_frame,1);
double h1_o= iOpen(NULL,time_frame,1);
double h1_c= iClose(NULL,time_frame,1);

double h12_h= iHigh(NULL,time_frame,2);
double h12_l= iLow(NULL,time_frame,2);
double h12_o= iOpen(NULL,time_frame,2);
double h12_c= iClose(NULL,time_frame,2);
   ////////////////////////////////
      double h4_h= iHigh(NULL,time_frame,1);
double h4_l= iLow(NULL,time_frame,1);
double h4_o= iOpen(NULL,time_frame,1);
double h4_c= iClose(NULL,time_frame,1);

double h42_h= iHigh(NULL,time_frame,2);
double h42_l= iLow(NULL,time_frame,2);
double h42_o= iOpen(NULL,time_frame,2);
double h42_c= iClose(NULL,time_frame,2);
   ////////////////////////////////
   double day_h= iHigh(NULL,time_frame,1);
double day_l= iLow(NULL,time_frame,1);
double day_o= iOpen(NULL,time_frame,1);
double day_c= iClose(NULL,time_frame,1);

double day2_h= iHigh(NULL,time_frame,2);
double day2_l= iLow(NULL,time_frame,2);
double day2_o= iOpen(NULL,time_frame,2);
double day2_c= iClose(NULL,time_frame,2);
////////////////////////////////////////////////////////////////////
double h11_high= iHigh(NULL,time_frame,fibshift);
double h11_low= iLow(NULL,time_frame,fibshift);
double h11_open= iOpen(NULL,time_frame,fibshift);
double h11_close= iClose(NULL,time_frame,fibshift);
                                          double h11= h11_high-h11_low;
                                          double h11_100= h11/100*100+h11_low;
                                          double h11_73= h11/100*76.4+h11_low;
                                          double h11_61= h11/100*61.8+h11_low;
                                          double h11_50= h11/100*50+h11_low;
                                          double h11_38= h11/100*38.2+h11_low;
                                          double h11_23= h11/100*23.6+h11_low;
                                          double h11_0= h11/100*0+h11_low;
  if (show_h1&&ObjectFind("h11_100") != 0)
   {
      ObjectCreate("h11_100", OBJ_HLINE, 0, Time[0], h11_100);
      ObjectSet("h11_100", OBJPROP_COLOR, White);
      ObjectSet("h11_100", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("h11_100", 0, Time[0], h11_100);
   }                                         
if (show_h1&&ObjectFind("h11_73") != 0)
   {
      ObjectCreate("h11_73", OBJ_HLINE, 0, Time[0], h11_73);
      ObjectSet("h11_73", OBJPROP_COLOR, White);
      ObjectSet("h11_73", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("h11_73", 0, Time[0], h11_73);
   }             
if (show_h1&&ObjectFind("h11_61") != 0)
   {
      ObjectCreate("h11_61", OBJ_HLINE, 0, Time[0], h11_61);
      ObjectSet("h11_61", OBJPROP_COLOR, White);
      ObjectSet("h11_61", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("h11_61", 0, Time[0], h11_61);
   }  
   if (show_h1&&ObjectFind("h11_50") != 0)
   {
      ObjectCreate("h11_50", OBJ_HLINE, 0, Time[0], h11_50);
      ObjectSet("h11_50", OBJPROP_COLOR, White);
      ObjectSet("h11_50", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("h11_50", 0, Time[0], h11_50);
   }  
      if (show_h1&&ObjectFind("h11_38") != 0)
   {
      ObjectCreate("h11_38", OBJ_HLINE, 0, Time[0], h11_38);
      ObjectSet("h11_38", OBJPROP_COLOR, White);
      ObjectSet("h11_38", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("h11_38", 0, Time[0], h11_38);
   }  
         if (show_h1&&ObjectFind("h11_23") != 0)
   {
      ObjectCreate("h11_23", OBJ_HLINE, 0, Time[0], h11_23);
      ObjectSet("h11_23", OBJPROP_COLOR, White);
      ObjectSet("h11_23", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("h11_23", 0, Time[0], h11_23);
   }  
            if (show_h1&&ObjectFind("h11_0") != 0)
   {
      ObjectCreate("h11_0", OBJ_HLINE, 0, Time[0], h11_0);
      ObjectSet("h11_0", OBJPROP_COLOR, White);
      ObjectSet("h11_0", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("h11_0", 0, Time[0], h11_0);
   }  
double h41_high= iHigh(NULL,time_frame,fibshift);
double h41_low= iLow(NULL,time_frame,fibshift);
double h41_open= iOpen(NULL,time_frame,fibshift);
double h41_close= iClose(NULL,time_frame,fibshift);
                                          double h41= h41_high-h41_low;
                                          double h41_100= h41/100*100+h41_low;
                                          double h41_73= h41/100*76.4+h41_low;
                                          double h41_61= h41/100*61.8+h41_low;
                                          double h41_50= h41/100*50+h41_low;
                                          double h41_38= h41/100*38.2+h41_low;
                                          double h41_23= h41/100*23.6+h41_low;
                                          double h41_0= h41/100*0+h41_low;
  if (show_h4&&ObjectFind("h41_100") != 0)
   {
      ObjectCreate("h41_100", OBJ_HLINE, 0, Time[0], h41_100);
      ObjectSet("h41_100", OBJPROP_COLOR, Yellow);
      ObjectSet("h41_100", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("h41_100", 0, Time[0], h41_100);
   }                                         
if (show_h4&&ObjectFind("h41_73") != 0)
   {
      ObjectCreate("h41_73", OBJ_HLINE, 0, Time[0], h41_73);
      ObjectSet("h41_73", OBJPROP_COLOR, Yellow);
      ObjectSet("h41_73", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("h41_73", 0, Time[0], h41_73);
   }             
if (show_h4&&ObjectFind("h41_61") != 0)
   {
      ObjectCreate("h41_61", OBJ_HLINE, 0, Time[0], h41_61);
      ObjectSet("h41_61", OBJPROP_COLOR, Yellow);
      ObjectSet("h41_61", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("h41_61", 0, Time[0], h41_61);
   }  
   if (show_h4&&ObjectFind("h41_50") != 0)
   {
      ObjectCreate("h41_50", OBJ_HLINE, 0, Time[0], h41_50);
      ObjectSet("h41_50", OBJPROP_COLOR, Yellow);
      ObjectSet("h41_50", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("h41_50", 0, Time[0], h41_50);
   }  
      if (show_h4&&ObjectFind("h41_38") != 0)
   {
      ObjectCreate("h41_38", OBJ_HLINE, 0, Time[0], h41_38);
      ObjectSet("h41_38", OBJPROP_COLOR, Yellow);
      ObjectSet("h41_38", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("h41_38", 0, Time[0], h41_38);
   }  
         if (show_h4&&ObjectFind("h41_23") != 0)
   {
      ObjectCreate("h41_23", OBJ_HLINE, 0, Time[0], h41_23);
      ObjectSet("h41_23", OBJPROP_COLOR, Yellow);
      ObjectSet("h41_23", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("h41_23", 0, Time[0], h41_23);
   }  
            if (show_h4&&ObjectFind("h41_0") != 0)
   {
      ObjectCreate("h41_0", OBJ_HLINE, 0, Time[0], h41_0);
      ObjectSet("h41_0", OBJPROP_COLOR, Yellow);
      ObjectSet("h41_0", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("h41_0", 0, Time[0], h41_0);
   }  
double day1_high= iHigh(NULL,240,fibshift);
double day1_low= iLow(NULL,240,fibshift);
double day1_open= iOpen(NULL,240,fibshift);
double day1_close= iClose(NULL,240,fibshift);
                                          double day1= day1_high-day1_low;
                                          double day1_100= day1/100*100+day1_low;
                                          double day1_73= day1/100*76.4+day1_low;
                                          double day1_61= day1/100*61.8+day1_low;
                                          double day1_50= day1/100*50+day1_low;
                                          double day1_38= day1/100*38.2+day1_low;
                                          double day1_23= day1/100*23.6+day1_low;
                                          double day1_0= day1/100*0+day1_low;
  if (show_d11&&ObjectFind("day1_100") != 0)
   {
      ObjectCreate("day1_100", OBJ_HLINE, 0, Time[0], day1_100);
      ObjectSet("day1_100", OBJPROP_COLOR, Orange);
      ObjectSet("day1_100", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("day1_100", 0, Time[0], day1_100);
   }                                         
if (show_d1&&ObjectFind("day1_73") != 0)
   {
      ObjectCreate("day1_73", OBJ_HLINE, 0, Time[0], day1_73);
      ObjectSet("day1_73", OBJPROP_COLOR, Orange);
      ObjectSet("day1_73", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("day1_73", 0, Time[0], day1_73);
   }             
if (show_d1&&ObjectFind("day1_61") != 0)
   {
      ObjectCreate("day1_61", OBJ_HLINE, 0, Time[0], day1_61);
      ObjectSet("day1_61", OBJPROP_COLOR, Orange);
      ObjectSet("day1_61", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("day1_61", 0, Time[0], day1_61);
   }  
   if (show_d1&&ObjectFind("day1_50") != 0)
   {
      ObjectCreate("day1_50", OBJ_HLINE, 0, Time[0], day1_50);
      ObjectSet("day1_50", OBJPROP_COLOR, Orange);
      ObjectSet("day1_50", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("day1_50", 0, Time[0], day1_50);
   }  
      if (show_d1&&ObjectFind("day1_38") != 0)
   {
      ObjectCreate("day1_38", OBJ_HLINE, 0, Time[0], day1_38);
      ObjectSet("day1_38", OBJPROP_COLOR, Orange);
      ObjectSet("day1_38", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("day1_38", 0, Time[0], day1_38);
   }  
         if (show_d1&&ObjectFind("day1_23") != 0)
   {
      ObjectCreate("day1_23", OBJ_HLINE, 0, Time[0], day1_23);
      ObjectSet("day1_23", OBJPROP_COLOR, Orange);
      ObjectSet("day1_23", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("day1_23", 0, Time[0], day1_23);
   }  
            if (show_d11&&ObjectFind("day1_0") != 0)
   {
      ObjectCreate("day1_0", OBJ_HLINE, 0, Time[0], day1_0);
      ObjectSet("day1_0", OBJPROP_COLOR, Orange);
      ObjectSet("day1_0", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("day1_0", 0, Time[0], day1_0);
   }  

double week1_high= iHigh(NULL,time_frame,fibshift);
double week1_low= iLow(NULL,time_frame,fibshift);
double week1_open= iOpen(NULL,time_frame,fibshift);
double week1_close= iClose(NULL,time_frame,fibshift);
                                          double neg1= -0.618;
                                          double neg2= -1.618;
                                          double week1= week1_high-week1_low;
                                          double week1_261= week1/100*261.8+week1_low;
                                          double week1_161= week1/100*161.8+week1_low;
                                          double week1_100= week1/100*100+week1_low;
                                          double week1_73= week1/100*76.4+week1_low;
                                          double week1_61= week1/100*61.8+week1_low;
                                          double week1_50= week1/100*50+week1_low;
                                          double week1_38= week1/100*38.2+week1_low;
                                          double week1_23= week1/100*23.6+week1_low;
                                          double week1_0= week1/100*0+week1_low;
                                          double week1__61= week1/100*neg1+week1_low;
                                          double week1__161= week1/100*neg2+week1_low;
  if (show_w1&&ObjectFind("week1_100") != 0)
   {
      ObjectCreate("week1_100", OBJ_HLINE, 0, Time[0], week1_100);
      ObjectSet("week1_100", OBJPROP_COLOR, Red);
      ObjectSet("week1_100", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("week1_100", 0, Time[0], week1_100);
   }                                         
if (show_w1&&ObjectFind("week1_73") != 0)
   {
      ObjectCreate("week1_73", OBJ_HLINE, 0, Time[0], week1_73);
      ObjectSet("week1_73", OBJPROP_COLOR, Red);
      ObjectSet("week1_73", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("week1_73", 0, Time[0], week1_73);
   }             
if (show_w1&&ObjectFind("week1_61") != 0)
   {
      ObjectCreate("week1_61", OBJ_HLINE, 0, Time[0], week1_61);
      ObjectSet("week1_61", OBJPROP_COLOR, Red);
      ObjectSet("week1_61", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("week1_61", 0, Time[0], week1_61);
   }  
   if (show_w1&&ObjectFind("week1_50") != 0)
   {
      ObjectCreate("week1_50", OBJ_HLINE, 0, Time[0], week1_50);
      ObjectSet("week1_50", OBJPROP_COLOR, Red);
      ObjectSet("week1_50", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("week1_50", 0, Time[0], week1_50);
   }  
      if (show_w1&&ObjectFind("week1_38") != 0)
   {
      ObjectCreate("week1_38", OBJ_HLINE, 0, Time[0], week1_38);
      ObjectSet("week1_38", OBJPROP_COLOR, Red);
      ObjectSet("week1_38", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("week1_38", 0, Time[0], week1_38);
   }  
         if (show_w1&&ObjectFind("week1_23") != 0)
   {
      ObjectCreate("week1_23", OBJ_HLINE, 0, Time[0], week1_23);
      ObjectSet("week1_23", OBJPROP_COLOR, Red);
      ObjectSet("week1_23", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("week1_23", 0, Time[0], week1_23);
   }  
            if (show_w1&&ObjectFind("week1_0") != 0)
   {
      ObjectCreate("week1_0", OBJ_HLINE, 0, Time[0], week1_0);
      ObjectSet("week1_0", OBJPROP_COLOR, Red);
      ObjectSet("week1_0", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("week1_0", 0, Time[0], week1_0);
   }  


double month1_high= iHigh(NULL,time_frame,fibshift);
double month1_low= iLow(NULL,time_frame,fibshift);
double month1_open= iOpen(NULL,time_frame,fibshift);
double month1_close= iClose(NULL,time_frame,fibshift);
                                          double month1= month1_high-month1_low;
                                          double month1_100= month1/100*100+month1_low;
                                          double month1_73= month1/100*76.4+month1_low;
                                          double month1_61= month1/100*61.8+month1_low;
                                          double month1_50= month1/100*50+month1_low;
                                          double month1_38= month1/100*38.2+month1_low;
                                          double month1_23= month1/100*23.6+month1_low;
                                          double month1_0= month1/100*0+month1_low;
  if (show_mn&&ObjectFind("month1_100") != 0)
   {
      ObjectCreate("month1_100", OBJ_HLINE, 0, Time[0], month1_100);
      ObjectSet("month1_100", OBJPROP_COLOR, Blue);
      ObjectSet("month1_100", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("month1_100", 0, Time[0], month1_100);
   }                                         
if (show_mn&&ObjectFind("month1_73") != 0)
   {
      ObjectCreate("month1_73", OBJ_HLINE, 0, Time[0], month1_73);
      ObjectSet("month1_73", OBJPROP_COLOR, Blue);
      ObjectSet("month1_73", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("month1_73", 0, Time[0], month1_73);
   }             
if (show_mn&&ObjectFind("month1_61") != 0)
   {
      ObjectCreate("month1_61", OBJ_HLINE, 0, Time[0], month1_61);
      ObjectSet("month1_61", OBJPROP_COLOR, Blue);
      ObjectSet("month1_61", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("month1_61", 0, Time[0], month1_61);
   }  
   if (show_mn&&ObjectFind("month1_50") != 0)
   {
      ObjectCreate("month1_50", OBJ_HLINE, 0, Time[0], month1_50);
      ObjectSet("month1_50", OBJPROP_COLOR, Blue);
      ObjectSet("month1_50", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("month1_50", 0, Time[0], month1_50);
   }  
      if (show_mn&&ObjectFind("month1_38") != 0)
   {
      ObjectCreate("month1_38", OBJ_HLINE, 0, Time[0], month1_38);
      ObjectSet("month1_38", OBJPROP_COLOR, Blue);
      ObjectSet("month1_38", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("month1_38", 0, Time[0], month1_38);
   }  
         if (show_mn&&ObjectFind("month1_23") != 0)
   {
      ObjectCreate("month1_23", OBJ_HLINE, 0, Time[0], month1_23);
      ObjectSet("month1_23", OBJPROP_COLOR, Blue);
      ObjectSet("month1_23", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("month1_23", 0, Time[0], month1_23);
   }  
            if (show_mn&&ObjectFind("month1_0") != 0)
   {
      ObjectCreate("month1_0", OBJ_HLINE, 0, Time[0], month1_0);
      ObjectSet("month1_0", OBJPROP_COLOR, Blue);
      ObjectSet("month1_0", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("month1_0", 0, Time[0], month1_0);
   }  

////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////

double hi1= iHigh(NULL,piv_period,fibshift);
double lo1= iLow(NULL,piv_period,fibshift);

double hi21= hi1/2;
double lo21= lo1/2;

double pivot1= hi21+lo21;
double p11= pivot1/2;
double mid_upper1 = p11+hi21;
double mid_lower1 = p11+lo21;
////////////////////////////////////////////////////h4
double hi= iHigh(NULL,time_frame,fibshift);
double lo= iLow(NULL,time_frame,fibshift);
double h_l_hi= iHigh(NULL,time_frame,fibshift);
double h_l_lo= iLow(NULL,time_frame,fibshift);
double hi2= hi/2;
double lo2= lo/2;
double r= hi-lo;
double pivot= r/100*buy_level+lo;
double p1= pivot/2;
double mid_upper = p1+hi2;
double mid_lower = p1+lo2;
//////////////////////////////////////////////////////monthly
double mhi= iHigh(NULL,time_frame,fibshift);
double mlo= iLow(NULL,time_frame,fibshift);

double mhi2= mhi/2;
double mlo2= mlo/2;
double mr= mhi-mlo;
double pivot_tp= mr/100*buy_tp_level+mlo;
double mp1= pivot_tp/2;
double mmid_upper = mp1+mhi2;
double mmid_lower = mp1+mlo2;
///////////////////////////////////////////////////////weekly
double whi= iHigh(NULL,time_frame,fibshift);
double wlo= iLow(NULL,time_frame,fibshift);

double whi2= whi/2;
double wlo2= wlo/2;
double wr= whi-wlo;
double pivot_sl= wr/100*buy_sl_level+wlo;
double wp1= pivot_sl/2;
double wmid_upper = wp1+whi2;
double wmid_lower = wp1+wlo2;
///////////////////////////////////////////////////////daily
double dhi= iHigh(NULL,time_frame,fibshift);
double dlo= iLow(NULL,time_frame,fibshift);

double dhi2= dhi/2;
double dlo2= dlo/2;
double dr= dhi-dlo;
double dpivot= dr/100*buy_level+dlo;
double dp1= dpivot/2;
double dmid_upper = dp1+dhi2;
double dmid_lower = dp1+dlo2;
///////////////////////////////////////////////////////h1
double hhi= iHigh(NULL,time_frame,fibshift);
double hlo= iLow(NULL,time_frame,fibshift);

double hhi2= hhi/2;
double hlo2= hlo/2;
double hr= hhi-hlo;
double hpivot= hr/100*buy_level+hlo;
double hp1= hpivot/2;
double hmid_upper = hp1+hhi2;
double hmid_lower = hp1+hlo2;
////////////////////////////////////////////////////////////end
////////////////////////////////////////////////////h4   shorts
double his= iHigh(NULL,time_frame,fibshift);
double los= iLow(NULL,time_frame,fibshift);

double hi2s= his/2;
double lo2s= los/2;
double rs= his-los;
double pivots= rs/100*sell_level+los;
double p1s= pivots/2;
double mid_uppers = p1s+hi2s;
double mid_lowers = p1s+lo2s;
//////////////////////////////////////////////////////monthly
double mhis= iHigh(NULL,time_frame,fibshift);
double mlos= iLow(NULL,time_frame,fibshift);

double mhi2s= mhis/2;
double mlo2s= mlos/2;
double mrs= mhi-mlos;
double pivots_tp= mrs/100*sell_tp_level+mlos;
double mp1s= pivots_tp/2;
double mmid_uppers = mp1s+mhi2s;
double mmid_lowers = mp1s+mlo2s;
///////////////////////////////////////////////////////weekly
double whis= iHigh(NULL,time_frame,fibshift);
double wlos= iLow(NULL,time_frame,fibshift);

double whi2s= whis/2;
double wlo2s= wlos/2;
double wrs= whis-wlos;
double pivots_sl= wrs/100*sell_sl_level+wlos;
double wp1s= pivots_sl/2;
double wmid_uppers = wp1s+whi2s;
double wmid_lowers = wp1s+wlo2s;
///////////////////////////////////////////////////////daily
double dhis= iHigh(NULL,time_frame,fibshift);
double dlos= iLow(NULL,time_frame,fibshift);

double dhi2s= dhis/2;
double dlo2s= dlos/2;
double drs= dhis-dlos;
double dpivots= drs/100*sell_level+dlos;
double dp1s= dpivots/2;
double dmid_uppers = dp1s+dhi2s;
double dmid_lowers = dp1s+dlo2s;
///////////////////////////////////////////////////////h1
double hhis= iHigh(NULL,time_frame,fibshift);
double hlos= iLow(NULL,time_frame,fibshift);

double hhi2s= hhis/2;
double hlo2s= hlos/2;
double hrs= hhis-hlos;
double hpivots= hrs/100*sell_level+hlos;
double hp1s= hpivots/2;


double hmid_uppers = hp1s+hhi2s;
double hmid_lowers = hp1s+hlo2s;
////////////////////////////////////////////////////////////

if (show_piv_lines&&ObjectFind("hpivots") != 0)
   {
      ObjectCreate("hpivots", OBJ_HLINE, 0, Time[0], hpivots);
      ObjectSet("hpivots", OBJPROP_COLOR, White);
      ObjectSet("hpivots", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("hpivots", 0, Time[0], hpivots);
   } 
     
   if (show_piv_lines&&ObjectFind("hpivot") != 0)
   {
      ObjectCreate("hpivot", OBJ_HLINE, 0, Time[0], hpivot);
      ObjectSet("hpivot", OBJPROP_COLOR, White);
      ObjectSet("hpivot", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("hpivot", 0, Time[0], hpivot);
   }   
   if (show_piv_lines&&ObjectFind("pivots") != 0)
   {
      ObjectCreate("pivots", OBJ_HLINE, 0, Time[0], pivots);
      ObjectSet("pivots", OBJPROP_COLOR, Orange);
      ObjectSet("pivots", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("pivots", 0, Time[0], pivots);
   }   
   if (show_piv_lines&&ObjectFind("pivot") != 0)
   {
      ObjectCreate("pivot", OBJ_HLINE, 0, Time[0], pivot);
      ObjectSet("pivot", OBJPROP_COLOR, Orange);
      ObjectSet("pivot", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("pivot", 0, Time[0], pivot);
   }   
   //////////////////////////////////////////////////////////////////////////
    if (show_piv_lines&&ObjectFind("dpivots") != 0)
   {
      ObjectCreate("dpivots", OBJ_HLINE, 0, Time[0], dpivots);
      ObjectSet("dpivots", OBJPROP_COLOR, OrangeRed);
      ObjectSet("dpivots", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("dpivots", 0, Time[0], dpivots);
   }   
   if (show_piv_lines&&ObjectFind("dpivot") != 0)
   {
      ObjectCreate("dpivot", OBJ_HLINE, 0, Time[0], dpivot);
      ObjectSet("dpivot", OBJPROP_COLOR, OrangeRed);
      ObjectSet("dpivot", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("dpivot", 0, Time[0], dpivot);
   }   
    //////////////////////////////////////////////////////////////////////////
    if (show_piv_lines&&ObjectFind("wpivots") != 0)
   {
      ObjectCreate("wpivots", OBJ_HLINE, 0, Time[0], pivots_sl);
      ObjectSet("wpivots", OBJPROP_COLOR, Red);
      ObjectSet("wpivots", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("wpivots", 0, Time[0], pivots_sl);
   }   
   if (show_piv_lines&&ObjectFind("wpivot") != 0)
   {
      ObjectCreate("wpivot", OBJ_HLINE, 0, Time[0], pivot_sl);
      ObjectSet("wpivot", OBJPROP_COLOR, Red);
      ObjectSet("wpivot", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("wpivot", 0, Time[0], pivot_sl);
   }   
    //////////////////////////////////////////////////////////////////////////
    if (show_piv_lines&&ObjectFind("mpivots") != 0)
   {
      ObjectCreate("mpivots", OBJ_HLINE, 0, Time[0], pivots_tp);
      ObjectSet("mpivots", OBJPROP_COLOR, Blue);
      ObjectSet("mpivots", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("mpivots", 0, Time[0], pivots_tp);
   }   
   if (show_piv_lines&&ObjectFind("mpivot") != 0)
   {
      ObjectCreate("mpivot", OBJ_HLINE, 0, Time[0], pivot_tp);
      ObjectSet("mpivot", OBJPROP_COLOR, Blue);
      ObjectSet("mpivot", OBJPROP_WIDTH, 0);
   }
   else
   {
      ObjectMove("mpivot", 0, Time[0], pivot_tp);
    }
   if (buy_level>sell_level) {
reverse = false;
                  {

     }
   }  

     if (buy_level<sell_level) {
reverse = true;
                  {

     }
   }  
        if (cl==hpivot) {
h1_buy = true;
                  {

     }
   }  
   if (cl==hpivots) {
h1_sell = true;
                  {

     }
   }  
       if (cl==pivot) {
h4_buy = true;
                  {

     }
   }  
   if (cl==pivots) {
h4_sell = true;
                  {

     }
   }  
        if (cl==dpivot) {
day_buy = true;
                  {

     }
   }  
   if (cl==dpivots) {
day_sell = true;
                  {

     }
   }  
        if (cl==pivot_tp) {
week_buy = true;
                  {

     }
   }  
   if (cl==pivot_tp) {
week_sell = true;
                  {

     }
   }  
    if (cl==pivot_tp) {
month_buy = true;
                  {

     }
   }  
   if (cl==pivot_tp) {
month_sell = true;
                  {

     }
   }  
if (hi_lo_filter&&cl>h_l_hi) {          
pivot_long=true;
pivot_short=false;
                  {
     }
   }
   if (hi_lo_filter&&cl<h_l_hi) {          
pivot_long=false;
                  {
     }
   }
   if (hi_lo_filter&&cl>h_l_lo) {          
pivot_short=false;
                  {
     }
   }
   if (hi_lo_filter&&cl<h_l_lo) {          
pivot_long=false;
pivot_short=true;
                  {
     }
   }

   ///////////////////////////////////////////////////////////////////////////
   if (one_pivot&&cl>mid_upper1) {          
pivot_long=true;
                  {
     }
   }
   if (one_pivot&&cl<mid_upper1) {          
pivot_long=false;
                  {
     }
   }
   if (one_pivot&&cl>mid_lower1) {          
pivot_short=false;
                  {
     }
   }
   if (one_pivot&&cl<mid_lower1) {          
pivot_short=true;
                  {
     }
   }
if (symbol_profit>0&&tp_every_hour&& Minute() == 01) {          
Closeprofit();
                  {
     }
   }

if (scale_sl_at_equityloss&&pcnt<Equityslscale) {          
use_scale_stop_loss=true;
                  {
     }
   }
   if (scale_sl_at_equityloss&&pcnt>Equityslscale) {          
use_scale_stop_loss=false;
                  {
     }
   }
if (scale_tp_at_equityloss&&pcnt<Equitytpscale) {          
use_scale_take_profit=true;
                  {
     }
   }
   if (scale_tp_at_equityloss&&pcnt>Equitytpscale) {          
use_scale_take_profit=false;
                  {
     }
   }
if (stop ==4) {          
stop=1;
                  {
     }
   }
   if (tstop ==4) {          
tstop=1;
                  {
     }
   }
if (tstop==1&&use_scale_take_profit) {          
scale_take_profit();
                  {
     }
   }
   if (tstop==2&&use_scale_take_profit) {          
scale_take_profit2();
                  {
     }
   }
   if (tstop==3&&use_scale_take_profit) {          
scale_take_profit3();
tstop = tstop + 1;
                  {
     }
   }
if (stop==1&&use_scale_stop_loss) {          
scale_stop_loss();
stop = stop + 1;
                  {
     }
   }
if (stop==2&&use_scale_stop_loss) {          
scale_stop_loss2();
stop = stop + 1;
                  {
     }
   }
   if (stop==3&&use_scale_stop_loss) {          
scale_stop_loss3();
stop = stop + 1;
                  {
     }
   }
if (probl==2&&use_hidden_stop_loss) {          
hidden_stop_loss();
                  {
     }
   }
if (probl==2&&use_hidden_take_profit) {          
hidden_take_profit();
                  {
     }
   }
if (pswrd1==password) {          
pswrd = true;
                  {
     }
   }
   
if (pswrd) {          
can_trade = true;
                  {
     }
   }
if (pswrd==false) {          
can_trade = false;
Alert ("Wrong password!");
                  {
     }
   }

//if (manage_all_trades&&profittarget&&pro>=profitp) {         

//Close_target();
  //                {
  //   }
  // }
 //  if (manage_all_trades==false&&profittarget&&pro>=profitp) {         

//mClose_target();
 //                 {
  //   }
  // }
/*if (openLongs>=limit_longs) {         
trade_allowed = false;
trade_allowedp = false;
                  {
     }
   }
   if (openShorts>=limit_shorts) {          
trade_allowed = false;
trade_allowedp = false;
                  {
     }
   }*/
if (use_emergency_be&&total_orders<start_be_if_orders_exceeds) {          
breakeven = false;
                  {
     }
   }
if (use_emergency_be&&total_orders>start_be_if_orders_exceeds) {          
breakeven = true;
                  {
     }
   }
   if (closepending) {          
Closepending();
                  {
     }
   }
if (breakeven) {           
breakeven();
                  {
     }
   }
   if (trail) {          
trail();
                  {
     }
   }
if (trend==2) {          
trend = 0;
                  {
     }
   } 
if (trend==1) {          
trend = 0;
                  {
     }
   } 
if (m1>m2) {           
trend = 1;
                  {
     }
   } 
  if (m1<m2) {          
trend = 2;
                  {
     }
   }  
   if (open_with_ma==false&&hedge_with_ma==false) {          
trend = 3;
                  {
     }
   } 
   if (open_with_ma&&trend == 1) {          
longs= true;
shorts= false;
                  {
     }
   } 
   if (open_with_ma&&trend == 2) {          
longs= false;
shorts= true;
                  {
     }
   } 
   if(use_tc2_hedge&&openShorts>openLongs&&tccc2>tcc2){
  hedgelong = true;
                  {
     }
   }  
if(use_tc2_hedge&&openShorts<openLongs&&tccc2<tcc2){
  hedgeshort = true;
                  {
     }
   }  
 if(hedge_now){
 use_tc_hedge = false;
  hedgeshort = true;
   hedgelong = true;
   use_tc2_hedge = False;
   hedge_with_envelopes = False;
                  {
     }
   }  
   
   if(hedge_at_equty_loss&&pcnt<eq_loss_hedge){
  hedgeshort = true;
   hedgelong = true;
    trade_allowedp = false;
                  {
     }
   } 
   if(hedge_at_equty_loss&&pcnt>=restart_trading_percent){
    trade_allowedp = true;
                  {
     }
   } 
    if(shut_down_ea_after_target==false&&hedge_at_equty_target&&pcnt>equity_target){
  hedgeshort = true;
   hedgelong = true;
                  {
     }
   } 
   if(shut_down_ea_after_target&&hedge_at_equty_target&&pcnt>equity_target){
  hedgeshort = true;
   hedgelong = true;
   trade_allowedp = false;
                  {
     }
   }  
if (testOpen) {            
openLongs = 0; 
openShorts = 0; 
                  {
     }
   }   
 if (manage_all_trades&&testOpen ) {
             accorders();
                    orders();
                  {
     }
   }
   if (manage_all_trades==false&&testOpen ) {
             maccorders();
                    morders();
                  {
     }
   }
   if (use_atr_for_ranges&&atr1<atr21){
allow_longs = false;
 allow_shorts = false;
     {
     }
   }
    if (probl==2&&profittarget){
profittarget();
     {
     }
   }
      if (probl==2&&close_with_atr_range_filter&&atr1<atr21){
Close_target();
     {
     }
   }
   HideTestIndicators(true);
  static bool ITradedOnThisBar;
  int      OrdersPerSymbol=0;
  int      cnt=0;
  int  ticket, total;
  if(bartime!=Time[0]) 
     {
      bartime=Time[0];
      bartick++; 
      OrdersPerSymbol=0;
      for(cnt=OrdersTotal();cnt>=0;cnt--)
        {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if( OrderSymbol()==Symbol()) OrdersPerSymbol++;
        } 
      if(OrdersPerSymbol==0) TradeAllowed=true;
     }
   if (Hour() == CloseHour && Minute() >= CloseMinute&&close_all_trades_at_time) {
   Closeppall();
   {
     }
   }
   if (UseHourTrade){
   if((Hour()<FromHourTrade)||(Hour()>ToHourTrade))
trade_allowed= false;
trade_allowedp= false;
  {
     }
   }
  if (UseHourTrade){
   if((Hour()>=FromHourTrade)&&(Hour()<=ToHourTrade))
trade_allowed= true;
trade_allowedp= true;
  {
     }
   }
bool demo_account = IsDemo();                                                                    //demo
if (demo_account_only)
{
Alert ("You can not use the program with a real account!"); 
return(0);
}
int hard_accnt = account_number;                                                                           //<-- type the user account here before compiling
int accnt = AccountNumber();
if (use_account&&accnt != hard_accnt)
{
 Alert ("You can not use this account (" + DoubleToStr(accnt,0) + ") with this program!"); 
  return(0);
 }
string expire_date = expiration_date;                                                                  //<-- hard coded datetime yr/month/day
datetime e_d = StrToTime(expire_date); 
if (use_expiration&&CurTime() >= e_d)
{
Alert ("The trial version has expired!"); 
 return(0);
  }
      int Leverage=AccountLeverage(); 
   double Balance=balance; 
   double FreeMargin=AccountFreeMargin();
    double profit=AccountProfit();
    double equity=AccountEquity();
 
   int    MM=MarketInfo("GBPJPYm",MODE_MARGININIT);
                double    SWAPLONG=MarketInfo("GBPJPYm",MODE_SWAPLONG);
   double    SWAPSHORT=MarketInfo("GBPJPYm",MODE_SWAPSHORT);
   int    MAXLOT=MarketInfo("GBPJPYm",MODE_MAXLOT);
    double    MINLOT=MarketInfo("GBPJPYm",MODE_MINLOT);
   int    spread=MarketInfo("GBPJPYm",MODE_SPREAD);
            double    SWAPLONG1=MarketInfo("GBPUSDm",MODE_SWAPLONG);
   double    SWAPSHORT1=MarketInfo("GBPUSDm",MODE_SWAPSHORT);
   int    MAXLOT1=MarketInfo("GBPUSDm",MODE_MAXLOT);
   double    MINLOT1=MarketInfo("GBPUSDm",MODE_MINLOT);
   int    spread1=MarketInfo("GBPUSDm",MODE_SPREAD);
            double    SWAPLONG2=MarketInfo("EURUSDm",MODE_SWAPLONG);
   double    SWAPSHORT2=MarketInfo("EURUSDm",MODE_SWAPSHORT);
   int    MAXLOT2=MarketInfo("EURUSDm",MODE_MAXLOT);
   double    MINLOT2=MarketInfo("EURUSDm",MODE_MINLOT);
   int    spread2=MarketInfo("EURUSDm",MODE_SPREAD);
            double    SWAPLONG3=MarketInfo("USDJPYm",MODE_SWAPLONG);
   double    SWAPSHORT3=MarketInfo("USDJPYm",MODE_SWAPSHORT);
   int    MAXLOT3=MarketInfo("USDJPYm",MODE_MAXLOT);
   double    MINLOT3=MarketInfo("USDJPYm",MODE_MINLOT);
   int    spread3=MarketInfo("USDJPYm",MODE_SPREAD);
                     double    SWAPLONG4=MarketInfo("USDCHFm",MODE_SWAPLONG);
   double    SWAPSHORT4=MarketInfo("USDCHFm",MODE_SWAPSHORT);
   int    MAXLOT4=MarketInfo("USDCHFm",MODE_MAXLOT);
   double    MINLOT4=MarketInfo("USDCHFm",MODE_MINLOT);
   int    spread4=MarketInfo("USDCHFm",MODE_SPREAD);
                     double    SWAPLONG5=MarketInfo("EURCHFm",MODE_SWAPLONG);
   double    SWAPSHORT5=MarketInfo("EURCHFm",MODE_SWAPSHORT);
   int    MAXLOT5=MarketInfo("EURCHFm",MODE_MAXLOT);
   double    MINLOT5=MarketInfo("EURCHFm",MODE_MINLOT);
   int    spread5=MarketInfo("EURCHFm",MODE_SPREAD);
            double    SWAPLONG6=MarketInfo("AUDUSDm",MODE_SWAPLONG);
   double    SWAPSHORT6=MarketInfo("AUDUSDm",MODE_SWAPSHORT);
   int    MAXLOT6=MarketInfo("AUDUSDm",MODE_MAXLOT);
   int    MINLOT6=MarketInfo("AUDUSDm",MODE_MINLOT);
   int    spread6=MarketInfo("AUDUSDm",MODE_SPREAD);
                     double    SWAPLONG7=MarketInfo("USDCADm",MODE_SWAPLONG);
   double    SWAPSHORT7=MarketInfo("USDCADm",MODE_SWAPSHORT);
   int    MAXLOT7=MarketInfo("USDCADm",MODE_MAXLOT);
   double    MINLOT7=MarketInfo("USDCADm",MODE_MINLOT);
   int    spread7=MarketInfo("USDCADm",MODE_SPREAD);
                     double    SWAPLONG8=MarketInfo("NZDUSDm",MODE_SWAPLONG);
   double    SWAPSHORT8=MarketInfo("NZDUSDm",MODE_SWAPSHORT);
   int    MAXLOT8=MarketInfo("NZDUSDm",MODE_MAXLOT);
   double    MINLOT8=MarketInfo("NZDUSDm",MODE_MINLOT);
   int    spread8=MarketInfo("NZDUSDm",MODE_SPREAD);
                     double    SWAPLONG9=MarketInfo("EURGBPm",MODE_SWAPLONG);
   double    SWAPSHORT9=MarketInfo("EURGBPm",MODE_SWAPSHORT);
   int    MAXLOT9=MarketInfo("EURGBPm",MODE_MAXLOT);
   double    MINLOT9=MarketInfo("EURGBPm",MODE_MINLOT);
   int    spread9=MarketInfo("EURGBPm",MODE_SPREAD);
                     double    SWAPLONG11=MarketInfo("EURJPYm",MODE_SWAPLONG);
   double    SWAPSHORT11=MarketInfo("EURJPYm",MODE_SWAPSHORT);
   int    MAXLOT11=MarketInfo("EURJPYm",MODE_MAXLOT);
   double    MINLOT11=MarketInfo("EURJPYm",MODE_MINLOT);
   int    spread11=MarketInfo("EURJPYm",MODE_SPREAD);
                     double    SWAPLONG12=MarketInfo("CHFJPYm",MODE_SWAPLONG);
   double    SWAPSHORT12=MarketInfo("CHFJPYm",MODE_SWAPSHORT);
   int    MAXLOT12=MarketInfo("CHFJPYm",MODE_MAXLOT);
   double    MINLOT12=MarketInfo("CHFJPYm",MODE_MINLOT);
   int    spread12=MarketInfo("CHFJPYm",MODE_SPREAD);
                     double    SWAPLONG13=MarketInfo("GBPCHFm",MODE_SWAPLONG);
   double    SWAPSHORT13=MarketInfo("GBPCHFm",MODE_SWAPSHORT);
   int    MAXLOT13=MarketInfo("GBPCHFm",MODE_MAXLOT);
   double    MINLOT13=MarketInfo("GBPCHFm",MODE_MINLOT);
   int    spread13=MarketInfo("GBPCHFm",MODE_SPREAD);
                     double    SWAPLONG14=MarketInfo("EURAUDm",MODE_SWAPLONG);
   double    SWAPSHORT14=MarketInfo("EURAUDm",MODE_SWAPSHORT);
   int    MAXLOT14=MarketInfo("EURAUDm",MODE_MAXLOT);
   double    MINLOT14=MarketInfo("EURAUDm",MODE_MINLOT);
   int    spread14=MarketInfo("EURAUDm",MODE_SPREAD);
                     double    SWAPLONG15=MarketInfo("EURCADm",MODE_SWAPLONG);
   double    SWAPSHORT15=MarketInfo("EURCADm",MODE_SWAPSHORT);
   int    MAXLOT15=MarketInfo("EURCADm",MODE_MAXLOT);
   double    MINLOT15=MarketInfo("EURCADm",MODE_MINLOT);
   int    spread15=MarketInfo("EURCADm",MODE_SPREAD);
                     double    SWAPLONG16=MarketInfo("AUDCADm",MODE_SWAPLONG);
   double    SWAPSHORT16=MarketInfo("AUDCADm",MODE_SWAPSHORT);
   int    MAXLOT16=MarketInfo("AUDCADm",MODE_MAXLOT);
   double    MINLOT16=MarketInfo("AUDCADm",MODE_MINLOT);
   int    spread16=MarketInfo("AUDCADm",MODE_SPREAD);
                     double    SWAPLONG17=MarketInfo("AUDJPYm",MODE_SWAPLONG);
   double    SWAPSHORT17=MarketInfo("AUDJPYm",MODE_SWAPSHORT);
   int    MAXLOT17=MarketInfo("AUDJPYm",MODE_MAXLOT);
   double    MINLOT17=MarketInfo("AUDJPYm",MODE_MINLOT);
   int    spread17=MarketInfo("AUDJPYm",MODE_SPREAD);
                    double    SWAPLONG18=MarketInfo("NZDJPYm",MODE_SWAPLONG);
   double    SWAPSHORT18=MarketInfo("NZDJPYm",MODE_SWAPSHORT);
   int    MAXLOT18=MarketInfo("NZDJPYm",MODE_MAXLOT);
   double    MINLOT18=MarketInfo("NZDJPYm",MODE_MINLOT);
   int    spread18=MarketInfo("NZDJPYm",MODE_SPREAD);
            double    SWAPLONG19=MarketInfo("AUDNZDm",MODE_SWAPLONG);
   double    SWAPSHORT19=MarketInfo("AUDNZDm",MODE_SWAPSHORT);
   int    MAXLOT19=MarketInfo("AUDNZDm",MODE_MAXLOT);
   double    MINLOT19=MarketInfo("AUDNZDm",MODE_MINLOT);
   int    spread19=MarketInfo("AUDNZDm",MODE_SPREAD);
         double    nSWAPLONG=MarketInfo("GBPJPY",MODE_SWAPLONG);
         double    point=MarketInfo("GBPJPY",MODE_POINT);
   double    nSWAPSHORT=MarketInfo("GBPJPY",MODE_SWAPSHORT);
   int    nMAXLOT=MarketInfo("GBPJPY",MODE_MAXLOT);
   double    nMINLOT=MarketInfo("GBPJPY",MODE_MINLOT);
   int    nspread=MarketInfo("GBPJPY",MODE_SPREAD);
            double    nSWAPLONG1=MarketInfo("GBPUSD",MODE_SWAPLONG);
   double    nSWAPSHORT1=MarketInfo("GBPUSD",MODE_SWAPSHORT);
   int    nMAXLOT1=MarketInfo("GBPUSD",MODE_MAXLOT);
   double    nMINLOT1=MarketInfo("GBPUSD",MODE_MINLOT);
   int    nspread1=MarketInfo("GBPUSD",MODE_SPREAD);
            double    nSWAPLONG2=MarketInfo("EURUSD",MODE_SWAPLONG);
   double    nSWAPSHORT2=MarketInfo("EURUSD",MODE_SWAPSHORT);
   int    nMAXLOT2=MarketInfo("EURUSD",MODE_MAXLOT);
   double    nMINLOT2=MarketInfo("EURUSD",MODE_MINLOT);
   int    nspread2=MarketInfo("EURUSD",MODE_SPREAD);
            double    nSWAPLONG3=MarketInfo("USDJPY",MODE_SWAPLONG);
   double    nSWAPSHORT3=MarketInfo("USDJPY",MODE_SWAPSHORT);
   int    nMAXLOT3=MarketInfo("USDJPY",MODE_MAXLOT);
   double    nMINLOT3=MarketInfo("USDJPY",MODE_MINLOT);
   int    nspread3=MarketInfo("USDJPY",MODE_SPREAD);
                     double    nSWAPLONG4=MarketInfo("USDCHF",MODE_SWAPLONG);
   double    nSWAPSHORT4=MarketInfo("USDCHF",MODE_SWAPSHORT);
   int    nMAXLOT4=MarketInfo("USDCHF",MODE_MAXLOT);
   double    nMINLOT4=MarketInfo("USDCHF",MODE_MINLOT);
   int    nspread4=MarketInfo("USDCHF",MODE_SPREAD);
                     double    nSWAPLONG5=MarketInfo("EURCHF",MODE_SWAPLONG);
   double    nSWAPSHORT5=MarketInfo("EURCHF",MODE_SWAPSHORT);
   int    nMAXLOT5=MarketInfo("EURCHF",MODE_MAXLOT);
   double    nMINLOT5=MarketInfo("EURCHF",MODE_MINLOT);
   int    nspread5=MarketInfo("EURCHF",MODE_SPREAD);
            double    nSWAPLONG6=MarketInfo("AUDUSD",MODE_SWAPLONG);
   double    nSWAPSHORT6=MarketInfo("AUDUSD",MODE_SWAPSHORT);
   int    nMAXLOT6=MarketInfo("AUDUSD",MODE_MAXLOT);
   double    nMINLOT6=MarketInfo("AUDUSD",MODE_MINLOT);
   int    nspread6=MarketInfo("AUDUSD",MODE_SPREAD);
                     double    nSWAPLONG7=MarketInfo("USDCAD",MODE_SWAPLONG);
   double    nSWAPSHORT7=MarketInfo("USDCAD",MODE_SWAPSHORT);
   int    nMAXLOT7=MarketInfo("USDCAD",MODE_MAXLOT);
   double    nMINLOT7=MarketInfo("USDCAD",MODE_MINLOT);
   int    nspread7=MarketInfo("USDCAD",MODE_SPREAD);
                     double    nSWAPLONG8=MarketInfo("NZDUSD",MODE_SWAPLONG);
   double    nSWAPSHORT8=MarketInfo("NZDUSD",MODE_SWAPSHORT);
   int    nMAXLOT8=MarketInfo("NZDUSD",MODE_MAXLOT);
   double    nMINLOT8=MarketInfo("NZDUSD",MODE_MINLOT);
   int    nspread8=MarketInfo("NZDUSD",MODE_SPREAD);
                     double    nSWAPLONG9=MarketInfo("EURGBP",MODE_SWAPLONG);
   double    nSWAPSHORT9=MarketInfo("EURGBP",MODE_SWAPSHORT);
   int    nMAXLOT9=MarketInfo("EURGBP",MODE_MAXLOT);
   double    nMINLOT9=MarketInfo("EURGBP",MODE_MINLOT);
   int    nspread9=MarketInfo("EURGBP",MODE_SPREAD);
                     double    nSWAPLONG11=MarketInfo("EURJPY",MODE_SWAPLONG);
   double    nSWAPSHORT11=MarketInfo("EURJPY",MODE_SWAPSHORT);
   int    nMAXLOT11=MarketInfo("EURJPY",MODE_MAXLOT);
   double    nMINLOT11=MarketInfo("EURJPY",MODE_MINLOT);
   int    nspread11=MarketInfo("EURJPY",MODE_SPREAD);
                     double    nSWAPLONG12=MarketInfo("CHFJPY",MODE_SWAPLONG);
   double    nSWAPSHORT12=MarketInfo("CHFJPY",MODE_SWAPSHORT);
   int    nMAXLOT12=MarketInfo("CHFJPY",MODE_MAXLOT);
   double    nMINLOT12=MarketInfo("CHFJPY",MODE_MINLOT);
   int    nspread12=MarketInfo("CHFJPY",MODE_SPREAD);
                     double    nSWAPLONG13=MarketInfo("GBPCHF",MODE_SWAPLONG);
   double    nSWAPSHORT13=MarketInfo("GBPCHF",MODE_SWAPSHORT);
   int    nMAXLOT13=MarketInfo("GBPCHF",MODE_MAXLOT);
   double    nMINLOT13=MarketInfo("GBPCHF",MODE_MINLOT);
   int    nspread13=MarketInfo("GBPCHF",MODE_SPREAD);
                     double    nSWAPLONG14=MarketInfo("EURAUD",MODE_SWAPLONG);
   double    nSWAPSHORT14=MarketInfo("EURAUD",MODE_SWAPSHORT);
   int    nMAXLOT14=MarketInfo("EURAUD",MODE_MAXLOT);
   double    nMINLOT14=MarketInfo("EURAUD",MODE_MINLOT);
   int    nspread14=MarketInfo("EURAUD",MODE_SPREAD);
                     double    nSWAPLONG15=MarketInfo("EURCAD",MODE_SWAPLONG);
   double    nSWAPSHORT15=MarketInfo("EURCAD",MODE_SWAPSHORT);
   int    nMAXLOT15=MarketInfo("EURCAD",MODE_MAXLOT);
   double    nMINLOT15=MarketInfo("EURCAD",MODE_MINLOT);
   int    nspread15=MarketInfo("EURCAD",MODE_SPREAD);
                     double    nSWAPLONG16=MarketInfo("AUDCAD",MODE_SWAPLONG);
   double    nSWAPSHORT16=MarketInfo("AUDCAD",MODE_SWAPSHORT);
   int    nMAXLOT16=MarketInfo("AUDCAD",MODE_MAXLOT);
   double    nMINLOT16=MarketInfo("AUDCAD",MODE_MINLOT);
   int    nspread16=MarketInfo("AUDCAD",MODE_SPREAD);
                     double    nSWAPLONG17=MarketInfo("AUDJPY",MODE_SWAPLONG);
   double    nSWAPSHORT17=MarketInfo("AUDJPY",MODE_SWAPSHORT);
   int    nMAXLOT17=MarketInfo("AUDJPY",MODE_MAXLOT);
   double    nMINLOT17=MarketInfo("AUDJPY",MODE_MINLOT);
   int    nspread17=MarketInfo("AUDJPY",MODE_SPREAD);
                    double    nSWAPLONG18=MarketInfo("NZDJPY",MODE_SWAPLONG);
   double    nSWAPSHORT18=MarketInfo("NZDJPY",MODE_SWAPSHORT);
   int    nMAXLOT18=MarketInfo("NZDJPY",MODE_MAXLOT);
   double    nMINLOT18=MarketInfo("NZDJPY",MODE_MINLOT);
   int    nspread18=MarketInfo("NZDJPY",MODE_SPREAD);
            double    nSWAPLONG19=MarketInfo("AUDNZD",MODE_SWAPLONG);
   double    nSWAPSHORT19=MarketInfo("AUDNZD",MODE_SWAPSHORT);
   int    nMAXLOT19=MarketInfo("AUDNZD",MODE_MAXLOT);
   double    nMINLOT19=MarketInfo("AUDNZD",MODE_MINLOT);
   int    nspread19=MarketInfo("AUDNZD",MODE_SPREAD); 
    

 
{int acctotal_orders = aopenShorts+aopenLongs;
               double symbol_profitb =profb / balance*100;
        double symbol_profits =profs / balance*100;
 double symbol_profit =pro / balance*100;
 double both =aopenShorts+aopenLongs;
  double both2 =openShorts+openLongs;
 double both3 =  AccountFreeMargin();
        if (comments){

double freemargin =( (AccountFreeMargin()-AccountMargin()) / AccountEquity())*100;
Comment("\n"," --***--TREND CHASER SUPER EMA--***-- Period ", Period(),(""),
 "\n",
"\n","Balance  = ",DoubleToStr(AccountBalance(),2),"     Free Margin  = ",DoubleToStr(AccountFreeMargin(),2),
"\n"," Equity  = ",DoubleToStr(AccountEquity(),2),
"\n",
"\n","Account Orders = ",DoubleToStr(acctotal_orders,0),"     Longs  = ",DoubleToStr(aopenLongs,0), "     Total  = ",DoubleToStr(both,0),
  
 "\n","                                Shorts  = ",DoubleToStr(aopenShorts,0),
 "\n",
"\n","Account Profit  = ",DoubleToStr(pcnt,2),
"\n","        TARGET  = ",DoubleToStr(equity_target,2), "     Global Stop Loss  =   ",DoubleToStr(emergency_loss_protection,2),
"\n",
"\n",
"\n",
"\n","Symbol Profit  =   ",DoubleToStr(symbol_profit,2),"     Longs  = ",DoubleToStr(symbol_profits,2),"     Shorts  = ",DoubleToStr(symbol_profitb,2),
"\n","       TARGET  =     ",DoubleToStr(profit_target_percent,2),
"\n",

"\n","Symbol Orders= ",DoubleToStr(total_orders,0), "     Longs  = ",DoubleToStr(openLongs,0),"       Total  = ",DoubleToStr(both2,0), "             Buy Lots   = ",DoubleToStr(prob,2),
"\n","                               Shorts  = ",DoubleToStr(openShorts,0),"                                  Sell Lots    = ",DoubleToStr(pros,2),

"\n","                                  Trend   = ",(trendd));
  
 // "\n",
 // "\n",  "     fib code  = ",DoubleToStr(w0,0), 
 // "\n","   h1  = ",DoubleToStr(hpivot,4),
 //  "\n","   h4  = ",DoubleToStr(pivot,4),
  //   "\n","   day  = ",DoubleToStr(dpivot,4),
  // "\n","   week  = ",DoubleToStr(wpivot,4),
   // "\n","   month  = ",DoubleToStr(mpivot,4));trend=long;
 // "\n",
  //"\n",
//"\n","     Psar = ",DoubleToStr(psar,4),//max = 0.011;
//"     Time Frame= ",DoubleToStr(time_frame_for_signal,0),
//"\n", 
//"\n",
//"\n","     Psar2= ",DoubleToStr(psar2,4),//max = 0.011;
//"     Time Frame= ",DoubleToStr(time_frame_for_signal2,0),
 //"\n",
 //"\n","     trend  = ",(trendd,));//   entry= ",(psar2dir),"     exit= ",(epsar2dir));
      }      
      else {
      }
   }
  
   if(probl==2&&risk_protection&&pcnt<emergency_loss_protection){
  Closeppall();
          {

     }
   }  
   /* if (symbol_profits>0.1) {
   Closelongs();

                  {

     }
   }  
   if (symbol_profitb>0.1) {
   Closeshorts();

                  {

     }
   }  */
   if (trendd=="long") {

mtrend=1;
                  {
     }
   } 
   if (trendd=="short") {

mtrend=2;
                  {
     }
   } 
    if (use_range_trail&&symbol_profit>trail_pcnt&&mtrend==1&&openShorts==0&&total_orders<orders_limit) {
trade_at_the_cross_only = false;

trail();
                  {
     }
   } 
   if (use_range_trail&&symbol_profit>trail_pcnt&&mtrend==2&&openLongs==0&&total_orders<orders_limit) {
trade_at_the_cross_only = false;

trail();
                  {
     }
   } 
    if (auto_trade_less_please&&use_range_trail&&symbol_profit<trail_pcnt) {
trade_at_the_cross_only = true;

                  {
     }
   } 
   if (auto_trade_less_please&&use_range_trail&&symbol_profit<trail_pcnt) {
trade_at_the_cross_only = true;
                  {
     }
   } 
  
  // if (trail_losers_winners&&manage_all_trades&&close_loss_trail_winns==false&&symbol_profit>profit_target_percent) {

//trail_losers();
   //               {
   //  }
  // } 
   
   //if (trail_losers_winners&&manage_all_trades==false&&close_loss_trail_winns==false&&symbol_profit>profit_target_percent&& OrderMagicNumber() ==MagicNumber) {

//trail_losers();

   //               {
   //  }
  // } 
    if (probl==2&&manage_all_trades&&close_loss_trail_winns&&symbol_profit>profit_target_percent) {
close_profit_symbol=false;
Closelosers();
                  {
     }
   } 
   
   if (probl==2&&manage_all_trades==false&&close_loss_trail_winns&&symbol_profit>profit_target_percent&& OrderMagicNumber() ==MagicNumber) {
close_profit_symbol=false;
mCloselosers();

                  {
     }
   } 
   
    if (shut_down_after_target&&symbol_profit>profit_target_percent) {          
trade_allowed=false;
                  {
     }
   }
   if (probl==2&&close_loss_trail_winns==false&&manage_all_trades&&close_profit_symbol&&symbol_profit>profit_target_percent&&OrderMagicNumber()==MagicNumber) {          
Close_target();
                  {
     }
   }
   /*if (total_orders>2) {          
profit_target_percent= 0.05;
                  {
     }
   }
   if (total_orders<2) {          
profit_target_percent= 1;
                  {
     }
   }*/
   if (probl==2&&close_loss_trail_winns==false&&manage_all_trades==false&&close_profit_symbol&&symbol_profit>profit_target_percent&&OrderMagicNumber()==MagicNumber) {          
mClose_target();
                  {
     }
   }
   
   
   if (auto_pivot&&total_orders>orders) {
                 h1_tf = 60;
      h1 = 50;
                h4_tf = 240;
         h4 = 50;
                d1_tf = 1440;
         d1 = 50;
                w1_tf = 10800;
         w1 = 50;
                mn_tf = 43200;
         mn = 50;
  
                h1_tfs = 60;
      h1s = 50;
                h4_tfs = 240;
         h4s = 50;
                d1_tfs = 1440;
         d1s = 50;
                w1_tfs = 10800;
         w1s = 50;
                mn_tfs = 43200;
         mns = 50;
       
                  {

     }
   }  
   if (auto_pivot&&total_orders<orders) {
   
           h1_tf = 60;
      h1 = 50;
                h4_tf = 60;
         h4 = 50;
                d1_tf = 60;
         d1 = 50;
                w1_tf = 60;
         w1 = 50;
                mn_tf = 60;
         mn = 50;
  
                h1_tfs = 60;
      h1s = 50;
                h4_tfs = 60;
         h4s = 50;
                d1_tfs = 60;
         d1s = 50;
                w1_tfs = 60;
         w1s = 50;
                mn_tfs = 60;
         mns = 50;
       
        
                  {

     }
   }  
   if (activ_hi_lo_auto&&symbol_profit>-2) {
 hi_lo_filter = false;
 hedge_lots = false;
use_martingale = false;
open_with_tc2 = true;

                  {

     }
   }  
  
    if (activ_hi_lo_auto&&symbol_profit<-2) {
 hi_lo_filter = true;
 hedge_lots = false;
use_martingale = false;
open_with_tc2 = false;
piv_period= 240;
                  {

     }
   }  

if (activ_hi_lo_auto&&symbol_profit<-3) {
 hi_lo_filter = true;
 hedge_lots = false;
 use_martingale = false;
 open_with_tc2 = false;
piv_period= 43200;
                  {

     }
   }   


if (activ_hi_lo_auto&&symbol_profit<-5) {
 hi_lo_filter = true;
 hedge_lots = false;
 use_martingale = false;
 
piv_period= 10080;
                  {

     }
   }   
   if (activ_hi_lo_auto&&symbol_profit<-7) {
 hi_lo_filter = true;
 hedge_lots = false;
 use_martingale = false;
 open_with_tc2 = false;
piv_period= 1440;
                  {

     }
   }   
   if (activ_hi_lo_auto&&symbol_profit<-10) {
 hi_lo_filter = true;
 hedge_lots = false;
 use_martingale = false;
 open_with_tc2 = false;
piv_period= 240;
                  {

     }
   }   
   if (activ_hi_lo_auto&&symbol_profit<-20) {
 hi_lo_filter = false;
 hedge_lots = false;
 use_martingale = false;
 open_with_tc2 = false;

                  {

     }
   }   
    if (auto_time_frame&&symbol_profit>-1) {          
time_frame_for_signal2=5;
                  {
     }
   }
 if (auto_time_frame&&symbol_profit<-1&&symbol_profit>-3) {          
time_frame_for_signal2=30;
                  {
     }
   }
if (auto_time_frame&&symbol_profit<-3) {          
time_frame_for_signal2=240;
                  {
     }
   }
   if (activate_martingale_at_margin&&freemargin<cross_margin_level) {           
use_martingale = true;
         {
     }
   }  
   if (activate_martingale_at_margin&&freemargin>cross_margin_level) {            
use_martingale = False;
         {
     }
   }  
    if (trade_less_please_below_margin&&freemargin<cross_margin_level) {          
trade_at_the_cross_only = true;
         {
     }
   }   
   if (trade_less_please_below_margin&&OrdersTotal()==0) {         
trade_at_the_cross_only = False;
                  {
     }
   }   
   if (hedge_ma_if_under_margin&&freemargin>hedge_ma_margin_level) {          
hedge_with_ma = false;   
                  {
     }
   }   
    if (hedge_ma_if_under_margin&&freemargin<hedge_ma_margin_level) {          
hedge_with_ma = true;
use_tc_hedge = false;  
                  {
     }
   }   
   if (probl==2&&tp_at_margin_level&&freemargin<tp_margin_level){
Closelongsinprofit();
Closeshortsinprofit();
     {
     }
   }
   if (probl==2&&close_margin_equity&&freemargin<20&&pcnt>-5){
Closeppall();
     {
     }
   }
if (probl==2&&close_at_margin_level&&freemargin<margin_level){
Closeppall();
     {
     }
   }if (trail_at_margin_level&&freemargin>trail_level){
trail = False;
     {
     }
   }
   if (trail_at_margin_level&&freemargin<trail_level){
trail = true;
     {
     }
   }
if (stop_trades_under_margin&&freemargin<stop_trades_level){
trade_allowed = false;
trade_allowedp = false;
     {
     }
   }
if (stop_trades_under_margin&&freemargin>stop_trades_level){
trade_allowed = true;
     {
     }
   }
   if (buy_only||sell_only){
ema_filter=false;
     {
     }
   }
   
   if (probl==2&&instant_reentry&&trade_allowed&&OrdersTotal()==0&&manual_overide==false&&go_long&&ema_filter&&cl>ma) { 
   
OrderSend(Symbol(), OP_BUY,LotsOptimized(), Ask, 200, NULL, NULL, "" + TRADE_COMMENT + "", MagicNumber, 236, DodgerBlue);
  

                  {
     }
   }
   if (probl==2&&instant_reentry&&trade_allowed&&OrdersTotal()==0&&manual_overide==false&&go_short&&ema_filter&&cl<ma) { 
   
OrderSend(Symbol(), OP_SELL,LotsOptimized(), Bid, 200, NULL, NULL, "" + TRADE_COMMENT + "", MagicNumber, 0, DeepPink);
   

                  {
     }
   }
  if (probl==2&&instant_reentry&&trade_allowed&&OrdersTotal()==0&&buy_only) { 
  
OrderSend(Symbol(), OP_BUY,LotsOptimized(), Ask, 200, NULL, NULL,"" + TRADE_COMMENT + "", MagicNumber, 236, DodgerBlue);
  

                  {
     }
   }
   if (probl==2&&instant_reentry&&trade_allowed&&OrdersTotal()==0&&sell_only) { 
OrderSend(Symbol(), OP_SELL,LotsOptimized(), Bid, 200, NULL, NULL, "" + TRADE_COMMENT + "", MagicNumber, 0, DeepPink);
   

                  {
     }
   }
   if (probl==2&&close_trades_limit&&total_orders>limit) {
   Closeppall();

                  {

     }
   }  
   
   int Order = SIGNAL_NONE;
   int Total, Ticket, MagicNumber;
   double StopLossLevel, TakeProfitLevel;
   if (EachTickMode && Bars != BarCount) TickCheck = False;
   Total = OrdersTotal();
   Order = SIGNAL_NONE; 
   
 double st =   iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,0);
   double ac = iAC(NULL, 0, Current + 0);
double acl = 0;
double ac2 = iAC(NULL, 0, Current + 1);
double ac3 = iAC(NULL, 0, Current + 2);

double ma200 =iEnvelopes(NULL, ma_timeframe, ma_period, MODE_SMA, 0, PRICE_OPEN, deviation, MODE_UPPER, Current + 0);
double ma2002 =iEnvelopes(NULL, 0, ma_period, MODE_SMA, 0, PRICE_OPEN, deviation, MODE_LOWER, Current + 0);
double atr= iATR(NULL,atr_tf,atr_period,0);
double atr2= atr_level;
double val=iForce(NULL, 0, 13,MODE_SMA,PRICE_CLOSE,0);
double val2=8;
double val3= -8;
double bec = iClose(NULL, 0, Current + 0);
double be = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_buy, buy, MODE_LOWER, Current + 0);
double bec2 = iClose(NULL, 0, Current + 1);
double be2 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_buy, buy, MODE_LOWER, Current + 1);
double bec3 = iClose(NULL, 0, Current + 2);
double be3 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_buy, buy, MODE_LOWER, Current + 2);  
double rbec = iClose(NULL, 0, Current + 0);
double rbe = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_buy, buy, MODE_UPPER, Current + 0);
double rbec2 = iClose(NULL, 0, Current + 1);
double rbe2 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_buy, buy, MODE_UPPER, Current + 1);
double rbec3 = iClose(NULL, 0, Current + 2);
double rbe3 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_buy, buy, MODE_UPPER, Current + 2);
double bsar = iSAR(NULL, time_frame_for_signal, psar, max, Current + 0);
double bsarc = iClose(NULL, 0, Current + 0);
double bsar2 = iSAR(NULL, time_frame_for_signal, psar, max, Current + 1);
double bsarc2 = iClose(NULL, 0, Current + 1);
double bsar3 = iSAR(NULL, time_frame_for_signal, psar, max, Current + 2);
double bsarc3 = iClose(NULL, 0, Current + 2);
double bsardbl = iSAR(NULL, time_frame_for_signal2, psar2, max2, Current + 0);
double bsarcdbl = iClose(NULL, 0, Current + 0);
double bsar2dbl = iSAR(NULL, time_frame_for_signal2, psar2, max2, Current + 1);
double bsarc2dbl = iClose(NULL, 0, Current + 1);
double bsar3dbl = iSAR(NULL, time_frame_for_signal2, psar2, max2, Current +2);
double bsarc3dbl = iClose(NULL, 0, Current + 2);
double bmac = iClose(NULL, 0, Current + 0);
double bma = iMA(NULL, time_frame_for_signal, ma, 0, MODE_SMMA, PRICE_OPEN, Current + 0);
double bmac2 = iClose(NULL, 0, Current + 1);
double bma2 = iMA(NULL, time_frame_for_signal, ma, 0, MODE_SMMA, PRICE_OPEN, Current + 1);
double bmac3 = iClose(NULL, 0, Current + 2);
double bma3 = iMA(NULL, time_frame_for_signal, ma, 0, MODE_SMMA, PRICE_OPEN, Current + 2);
double ssar =iSAR(NULL, time_frame_for_signal, psar, max, Current + 0);
double ssarc = iClose(NULL, 0, Current + 0);
double ssar2 = iSAR(NULL, time_frame_for_signal, psar, max, Current + 1);
double ssarc2 = iClose(NULL, 0, Current + 1);
double ssar3 = iSAR(NULL, time_frame_for_signal, psar, max, Current +  2);
double ssarc3 = iClose(NULL, 0, Current + 2);
double ssardbl = iSAR(NULL, time_frame_for_signal2, psar2, max2, Current + 0);
double ssarcdbl = iClose(NULL, 0, Current + 0);
double ssar2dbl = iSAR(NULL, time_frame_for_signal2, psar2, max2, Current + 1);
double ssarc2dbl = iClose(NULL, 0, Current + 1);
double ssar3dbl = iSAR(NULL, time_frame_for_signal2, psar2, max2, Current + 2);
double ssarc3dbl = iClose(NULL, 0, Current + 2);
double sec = iClose(NULL, 0, Current + 0);
double se = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_sell, buy, MODE_UPPER, Current + 0);
double sec2 = iClose(NULL, 0, Current + 1);
double se2 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_sell, buy, MODE_UPPER, Current + 1);
double sec3 = iClose(NULL, 0, Current + 2);
double se3 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_sell, buy, MODE_UPPER, Current + 2);
double rsec = iClose(NULL, 0, Current + 0);
double rse = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_sell, buy, MODE_LOWER, Current + 0);
double rsec2 = iClose(NULL, 0, Current + 1);
double rse2 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_sell, buy, MODE_LOWER, Current + 1);
double rsec3 = iClose(NULL, 0, Current + 2);
double rse3 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_sell, buy, MODE_LOWER, Current + 2);
double smac = iClose(NULL, 0, Current + 0);
double sma = iMA(NULL, time_frame_for_signal, ma, 0, MODE_SMMA, PRICE_OPEN, Current + 0);
double smac2 = iClose(NULL, 0, Current + 1);
double sma2 = iMA(NULL, time_frame_for_signal, ma, 0, MODE_SMMA, PRICE_OPEN, Current + 1);
double smac3 = iClose(NULL, 0, Current + 2);
double sma3 = iMA(NULL, time_frame_for_signal, ma, 0, MODE_SMMA, PRICE_OPEN, Current + 2);
double Close_bec = iClose(NULL, 0, Current + 0);
double Close_be = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_close_buy, close_buy, MODE_UPPER, Current + 0);
double rClose_bec = iClose(NULL, 0, Current + 0);
double rClose_be = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_close_buy, close_buy, MODE_LOWER, Current + 0);
double Close_bsar = iSAR(NULL, time_frame_for_signal, psar, max, Current + 0);
double Close_bsarc = iClose(NULL, 0, Current + 0);
double Close_bsardbl = iSAR(NULL, time_frame_for_signal2, psar2, max2, Current + 0);
double Close_bsarcdbl = iClose(NULL, 0, Current + 0);
double Close_sec = iClose(NULL, 0, Current + 0);
double Close_se = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_close_sell, close_sell, MODE_LOWER, Current + 0);
double rClose_sec = iClose(NULL, 0, Current + 0);
double rClose_se = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_close_sell, close_sell, MODE_UPPER, Current + 0);
double Close_ssar = iSAR(NULL, time_frame_for_signal, psar, max, Current  + 0);
double Close_ssarc = iClose(NULL, 0, Current + 0);
double Close_ssardbl = iSAR(NULL, time_frame_for_signal2, psar2, max2, Current  + 0);
double Close_ssarcdbl = iClose(NULL, 0, Current + 0);
double close_lots= NormalizeDouble(LotsOptimized()/5,2);
if (Maximum_Risk==0 ) {         
 close_lots1 = NormalizeDouble(Lots/5,2);  
   close_lots= NormalizeDouble(Lots/5,2);             
                               {

     }
   }  
   if (Maximum_Risk>0 ) {         
 close_lots1 = NormalizeDouble(LotsOptimized()/5,2);  
          close_lots= NormalizeDouble(LotsOptimized()/5,2);      
                               {

     }
   }  


double closed_none= LotsOptimized();
double closed_1= NormalizeDouble(LotsOptimized()/5*4,2);
double closed_2= NormalizeDouble(LotsOptimized()/5*3,2);
double closed_3= NormalizeDouble(LotsOptimized()/5*2,2);
double closed_4= NormalizeDouble(LotsOptimized()/5*1,2);

 
        if (use_4_targets&&probl==2&& OrderLots()== closed_none) { 
                                    trail=false; 
                             breakeven=true; 
                    hidden_take_profit_1();                 
                              {

     }
   }  
                  if (use_4_targets&&probl==2&& OrderLots()<= closed_none&&OrderLots()>=closed_1) {         
                    hidden_take_profit_2();                 
                              {

     }
   }  
                   if (use_4_targets&&probl==2&& OrderLots()<= closed_1&&OrderLots()>=closed_2) {         
                                                         // trail=true;  
                          // breakeven=false;
                    hidden_take_profit_3();                 
                               {

     }
   }  
                   if (use_4_targets&&probl==2&& OrderLots()<= closed_2&&OrderLots()>=closed_3) {         
                                       trail=true;  
                           breakeven=false;  
                    hidden_take_profit_4();                 
                               {

     }
   }  
    double slclosed_none= LotsOptimized();
double slclosed_1= NormalizeDouble(LotsOptimized()/5*4,2);
double slclosed_2= NormalizeDouble(LotsOptimized()/5*3,2);
double slclosed_3= NormalizeDouble(LotsOptimized()/5*2,2);
double slclosed_4= NormalizeDouble(LotsOptimized()/5*1,2);

 
        if (scale_sl&&probl==2&& OrderLots()== slclosed_none) { 
                          
                    hidden_stop_loss1();                 
                              {

     }
   }  
                  if (scale_sl&&probl==2&& OrderLots()<= slclosed_none&&OrderLots()>=slclosed_1) {         
                    hidden_stop_loss2();                 
                              {

     }
   }  
                   if (scale_sl&&probl==2&& OrderLots()<= slclosed_1&&OrderLots()>=slclosed_2) {         
                         
                    hidden_stop_loss3();                 
                               {

     }
   }  
                   if (scale_sl&&probl==2&& OrderLots()<= slclosed_2&&OrderLots()>=slclosed_3) {         
                                         
                           
                    hidden_stop_loss4();                 
                               {

     }
   }  
 bool IsTrade = False;
   for (int i = maximum_trades; i < Total; i ++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(ITradedOnThisBar != Bars&&OrderType() <= OP_SELL &&  OrderSymbol() == Symbol()) {
         IsTrade = True;
         if(ITradedOnThisBar != Bars&&OrderType() == OP_BUY) { 

if (probl==2&&Order == SIGNAL_CLOSEBUY ) {         
                    Closelongs();                 
                               {

     }
   }  
            if (Order == SIGNAL_CLOSEBUY ) {         
               OrderClose(OrderTicket(), OrderLots(), Bid, 200, MediumSeaGreen);
               if (email_notification) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + " Close Buy");          
               if (Use_Sound_only) PlaySound(NameFileSound);
               if (Use_popup_and_sound_alert) Alert(Message);      
               continue;
            }
   
   
   if (probl==2&&Order == SIGNAL_CLOSESELL ) {         
                    Closeshorts();
                  }
            if (probl==2&&Order == SIGNAL_CLOSESELL ) {       
               OrderClose(OrderTicket(), OrderLots(), Ask, 200, DarkOrange);
               if (email_notification) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + " Close Sell");         
               if (Use_Sound_only) PlaySound(NameFileSound);
               if (Use_popup_and_sound_alert) Alert(Message);          
                     continue;
                  }
               }
            }
         }
         bool canttrade = true;
    


      if (probl==2&&use_ma_sl&&cl>ma200) {
   Closeshorts();

                  {

     }
   }  
    if (probl==2&&use_ma_sl&&cl<ma2002) {
   Closelongs();

                  {

     }
   }  
datetime tLastLongEntry = Time[1];
datetime tLastShortEntry = Time[1];
if (ma_filter&&stochastics==false&&trade_0_line&&trade_the_cross_only&&probl==2&&ac<acl&&cl<ma2002&&ac2>acl) { 
Order = SIGNAL_SELL;
trend2=2;

                 {
     }
   }
    if (ma_filter&&stochastics==false&&trade_0_line&&trade_the_cross_only&&probl==2&&ac>acl&&cl>ma200&&ac2<acl) { 
Order = SIGNAL_BUY;
trend2=2;

                 {
     }
   }
   if (ma_filter&&stochastics==false&&trade_0_line&&trade_the_cross_only==false&&probl==2&&ac<acl&&cl<ma2002) { 
Order = SIGNAL_SELL;
trend2=2;

                 {
     }
   }
    if (ma_filter&&stochastics==false&&trade_0_line&&trade_the_cross_only==false&&probl==2&&ac>acl&&cl>ma200) { 
Order = SIGNAL_BUY;
trend2=2;

                 {
     }
   }
   if (ma_filter&&stochastics==false&&trade_color_change&&trade_the_cross_only==false&&probl==2&&ac>ac2&&cl>ma200) { 
Order = SIGNAL_BUY;
trend2=2;

                 {
     }
   }
   if (ma_filter&&stochastics==false&&trade_color_change&&trade_the_cross_only==false&&probl==2&&ac<ac2&&cl<ma2002) { 
Order = SIGNAL_SELL;
trend2=2;

                 {
     }
   }
    if (ma_filter&&stochastics==false&&trade_color_change&&trade_the_cross_only&&probl==2&&ac>ac2&&ac2<ac3&&cl>ma200) { 
Order = SIGNAL_BUY;
trend2=2;

                 {
     }
   }
   if (ma_filter&&stochastics==false&&trade_color_change&&trade_the_cross_only&&probl==2&&ac<ac2&&ac2>ac3&&cl<ma2002) { 
Order = SIGNAL_SELL;
trend2=2;

                 {
     }
   }/////////////////////
   
   
   
   if (ma_filter&&stochastics&&trade_0_line&&trade_the_cross_only&&probl==2&&ac<acl&&cl<ma2002&&ac2>acl&&st<50) { 
Order = SIGNAL_SELL;
trend2=2;

                 {
     }
   }
    if (ma_filter&&stochastics&&trade_0_line&&trade_the_cross_only&&probl==2&&ac>acl&&cl>ma200&&ac2<acl&&st>50) { 
Order = SIGNAL_BUY;
trend2=2;

                 {
     }
   }
   if (ma_filter&&stochastics&&trade_0_line&&trade_the_cross_only==false&&probl==2&&ac<acl&&cl<ma2002&&st<50) { 
Order = SIGNAL_SELL;
trend2=2;

                 {
     }
   }
    if (ma_filter&&stochastics&&trade_0_line&&trade_the_cross_only==false&&probl==2&&ac>acl&&cl>ma200&&st>50) { 
Order = SIGNAL_BUY;
trend2=2;

                 {
     }
   }
   if (ma_filter&&stochastics&&trade_color_change&&trade_the_cross_only==false&&probl==2&&ac>ac2&&cl>ma200&&st>50) { 
Order = SIGNAL_BUY;
trend2=2;

                 {
     }
   }
   if (ma_filter&&stochastics&&trade_color_change&&trade_the_cross_only==false&&probl==2&&ac<ac2&&cl<ma2002&&st<50) { 
Order = SIGNAL_SELL;
trend2=2;

                 {
     }
   }
    if (ma_filter&&stochastics&&trade_color_change&&trade_the_cross_only&&probl==2&&ac>ac2&&ac2<ac3&&cl>ma200&&st>50) { 
Order = SIGNAL_BUY;
trend2=2;

                 {
     }
   }
   if (ma_filter&&stochastics&&trade_color_change&&trade_the_cross_only&&probl==2&&ac<ac2&&ac2>ac3&&cl<ma2002&&st<50) { 
Order = SIGNAL_SELL;
trend2=2;

                 {
     }
   }//////////////////////////////////////////
      if (ma_filter&&stochastics==false&&trade_color_change&&trade_the_cross_only==false&&probl==2&&ac>ac2&&cl>ma200) { 
Order = SIGNAL_BUY;
trend2=2;

                 {
     }
   }
   if (ma_filter&&stochastics==false&&trade_color_change&&trade_the_cross_only==false&&probl==2&&ac<ac2&&cl<ma2002) { 
Order = SIGNAL_SELL;
trend2=2;

                 {
     }
   }
    if (ma_filter&&stochastics==false&&trade_color_change&&trade_the_cross_only&&probl==2&&ac>ac2&&ac2<ac3&&cl>ma200) { 
Order = SIGNAL_BUY;
trend2=2;

                 {
     }
   }
   if (ma_filter&&stochastics==false&&trade_color_change&&trade_the_cross_only&&probl==2&&ac<ac2&&ac2>ac3&&cl<ma2002) { 
Order = SIGNAL_SELL;
trend2=2;

                 {
     }
   }

    
   if (canttrade&&probl==2&&pcnt>equty_stop_trading&& can_trade&&trade_allowedp&& trade_allowed &&Order == SIGNAL_BUY &&ITradedOnThisBar != Bars&& ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
      if(!IsTrade) {
         if (AccountFreeMargin() < (0 * Lots)) {
            Print("We have no money. Free Margin = ", AccountFreeMargin());
            return(0);
         }
         if (TRUE) StopLossLevel = Ask - StopLoss * Point; else StopLossLevel = 0.0;
         if (True) TakeProfitLevel = Ask + TakeProfit * Point; else TakeProfitLevel = 0.0;
         Ticket = OrderSend(Symbol(), OP_BUY,LotsOptimized(), Ask, 200, NULL, NULL, "" + TRADE_COMMENT + "", MagicNumber, 236, DodgerBlue);
         if(Ticket > 0) {
            if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) {
				Print("BUY order opened : ", OrderOpenPrice());
			
				ITradedOnThisBar = Bars;
                if (email_notification) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + " Open Buy");
                if (Use_Sound_only) PlaySound(NameFileSound);
                if (Use_popup_and_sound_alert) Alert(Message);
			} else {
				Print("Error opening BUY order : ", GetLastError());
			}
         }
         if (refresh) {
  
 h1_buy = false;
  h1_sell = false;
  h4_buy = false;
  h4_sell = false;
  day_buy = false;
  day_sell = false;
  week_buy = false;
  week_sell = false;
  month_buy = false;
  month_sell = false;
  
   hi_lo_filter = false;
 hedge_lots = false;
 
 
profb=0;
profs=0;
  pivot_long=true;
  pivot_short=true;
   symbol_profit=0;
      pro=0;  
           prob=0; 
           pros=0; 
acctotal_orders = 0;
aopenShorts= 0;
aopenLongs= 0;

     Min_Lots_allowed    = Lots;
       Dis_Mm_If_Lots_Under  = Lots;
       //trail2();
                  {

     }
   } 
         if (EachTickMode) TickCheck = True;
         if (!EachTickMode) BarCount = Bars;
         return(0);
      }
   }
   if (probl==2&&pcnt>equty_stop_trading&&can_trade&&trade_allowedp&&trade_allowed &&Order == SIGNAL_SELL &&ITradedOnThisBar != Bars&& trend==3||trend==2&& ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
      if(!IsTrade) {
         if (AccountFreeMargin() < (0 * Lots)) {
            Print("We have no money. Free Margin = ", AccountFreeMargin());
            return(0);
         }
         if (True) StopLossLevel = Bid + StopLoss * Point; else StopLossLevel = 0.0;
         if (True) TakeProfitLevel = Bid - TakeProfit * Point; else TakeProfitLevel = 0.0;
         Ticket = OrderSend(Symbol(), OP_SELL,LotsOptimized(), Bid, 200, NULL, NULL, "" + TRADE_COMMENT + "", MagicNumber, 0, DeepPink);
         if(Ticket > 0) {
            if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) {               
				Print("SELL order opened : ", OrderOpenPrice());
				
				ITradedOnThisBar = Bars;
                if (email_notification) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + " Open Sell");
                if (Use_Sound_only) PlaySound(NameFileSound);
                if (Use_popup_and_sound_alert) Alert(Message);     
			} else {
				Print("Error opening SELL order : ", GetLastError());
			}
         }
         if (refresh) {
  
 h1_buy = false;
  h1_sell = false;
  h4_buy = false;
  h4_sell = false;
  day_buy = false;
  day_sell = false;
  week_buy = false;
  week_sell = false;
  month_buy = false;
  month_sell = false;
  
   hi_lo_filter = false;
 hedge_lots = false;
 
 
profb=0;
profs=0;
  pivot_long=true;
  pivot_short=true;
   symbol_profit=0;
      pro=0;  
           prob=0; 
           pros=0; 
acctotal_orders = 0;
aopenShorts= 0;
aopenLongs= 0;

     Min_Lots_allowed    = Lots;
       Dis_Mm_If_Lots_Under  = Lots;
       //trail2();
                  {

     }
   } 
         if (EachTickMode) TickCheck = True;
         if (!EachTickMode) BarCount = Bars;
         return(0);
         
      }
   }
   if (probl==2&&pcnt<equty_cut_off&&cl<ema4) {      
Closelongs();
                {
     }
   }   
   if (probl==2&&pcnt<equty_cut_off&&cl>ema4) {      
Closeshorts();
                {
     }
   }   
   if (dont_restrict_hedge) {      
trade_allowed_shorts=true; 
trade_allowed_longs=true;
                {
     }
   }   
   
   
  
   if (trade_allowed_longs&&pivot_long&&longs&&hedge_lots&&allow_longs&&can_trade&&hedge_with_envelopes&&hedge_with_ma==false&&open_with_ma==false&&use_tc_hedge==false&&cl>env&&prob < pros  *lots_plus) {         
OrderSend(Symbol(), OP_BUY,buy_lots, Ask, 200, NULL, NULL, "" + TRADE_COMMENT + "", MagicNumber, 236, DodgerBlue);
                  {
     }
   }   
   if (trade_allowed_shorts&&pivot_short&&shorts&&hedge_lots&&allow_shorts&&can_trade&&hedge_with_envelopes&&hedge_with_ma==false&&open_with_ma==false&&use_tc_hedge==false&&cl<env2&&prob > pros *lots_plus) {          
OrderSend(Symbol(), OP_SELL,sell_lots, Bid, 200, NULL, NULL, "" + TRADE_COMMENT + "", MagicNumber, 0, DeepPink);
                  {
     }
   }   
   ///////////////////////
  
  
   
   
   
   
   
   if (probl==2&&close_loss_trail_winns==false&&manage_all_trades&&close_profit_symbol&&symbol_profit>profit_target_percent&&OrderMagicNumber()==MagicNumber) {          
Close_target();
                  {
     }
   }
   if (probl==2&&close_loss_trail_winns==false&&manage_all_trades==false&&close_profit_symbol&&symbol_profit>profit_target_percent&&OrderMagicNumber()==MagicNumber) {          
mClose_target();
                  {
     }
   }
   if(probl==2&&close_all_equty_target&&pcnt>equity_target){
  Closeppall();
          {

     }
   }   
   

   if(auto_h4_settings&&symbol_profit<-10){
  h4_settings= true;
   m5_settings= false;
          {

     }
   }   
   if(auto_h4_settings&&symbol_profit>-2){
  h4_settings= false;
  m5_settings= true;
          {

     }
   }   
  int totalorders = OrdersTotal();
  for(int ic=totalorders-1;ic>=0;ic--)
 {
    OrderSelect(ic, SELECT_BY_POS);
    bool result = false;
    if ( OrderMagicNumber()==custom_magic&&Symbol()==symbol )
     {
  if ( OrderType() == OP_SELL )  {cu=cu+1;}
           if ( OrderType() == OP_BUY )  {cu=cu+1;}
            if (custom_long_trade&&Hour() == open_Hour && Minute() == minute&&DayOfWeek()==day_of_week&& OrdersTotal()==0) {
   OrderSend(symbol, OP_BUY,lots_for_custom, Ask, 200, NULL, NULL, "" + TRADE_COMMENT + "", MagicNumber, 236, DodgerBlue);
                  {
     }
   }
     if (custom_short_trade&&Hour() == open_Hour && Minute() == minute&&DayOfWeek()==day_of_week&& OrdersTotal()==0) {
   OrderSend(symbol, OP_SELL,lots_for_custom, Bid, 200, NULL, NULL, "" + TRADE_COMMENT + "", MagicNumber, 0, DeepPink);
     

   
      }
  }
 
}
   
   if (auto_target&&total_orders>100) {
 profit_target_percent = 5;

                  {

     }
   }  
   if (auto_target&&total_orders>50) {
 profit_target_percent = 2;

                  {

     }
   }  

    if (auto_target&&total_orders>20) {
 profit_target_percent = 1;

                  {

     }
   }  
       if (auto_target&&total_orders<20) {
 profit_target_percent = 0.1;

                  {

     }
   }  
if (w0==0&&cl==week1_0) {          
w0++;
                  {
     }
   }
   
   if (w0==1&&cl>week1_23) {          
w0++;
                  {
     }
   }
   
  if (w0==2&&cl>week1_38) {          
w0++;
                  {
     }
   } 
   
   if (w0==3&&cl>week1_50) {          
w0++;
                  {
     }
   } 
   
   if (w0==4&&cl>week1_61) {          
w0++;
                  {
     }
   } 
   
    if (w0==5&&cl>week1_73) {          
w0++;
                  {
     }
   } 
  if (w0==6&&cl>week1_100) {          /////////////fib 0 to 100
w0++;
                  {
     }
   }  
   
 //if (w0==7) {          
//status= "went up all fibs";
  //                {
  //   }
  // }
  //////////////////////////////////////////////////////////////
  if (w01==0&&cl==week1_0) {          
w01++;
                  {
     }
   }
   
   if (w01==1&&cl>week1_23) {          
w01++;
                  {
     }
   }
   
  if (w01==2&&cl>week1_38) {          
w01++;
                  {
     }
   } 
   
   if (w01==3&&cl>week1_50) {          
w01++;
                  {
     }
   } 
   
   if (w01==4&&cl>week1_61) {          
w01++;
                  {
     }
   } 
   
    if (w01==5&&cl>week1_73) {          
w01++;
                  {
     }
   } 
  if (w01==6&&cl>week1_100) {          /////////////fib 0 to 100
w01++;
                  {
     }
   }  
   
 //if (w01==7) {          
//status= "went up all fibs";
  //                {
  //   }
  // }
  if (trade_w1_fib&&trade3==0&&cl>week1_23&&cl<week1_38) {          
OrderSend(Symbol(), OP_BUY,LotsOptimized(), Ask, 200, NULL, NULL, "Buy(trendchaser super ea   " + MagicNumber  + ")", 3, 236, DodgerBlue);
  trade3=1;
   
                  {
   }
   }
 //   if (OrderMagicNumber()==3&&cl>week1_50||cl<week1_0) {          
//OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
 //   trade3=0;
 //                 {
 //  }
 //  }
   ///////////////
  //if (trade_w1_fib&&trade2==0&&cl>week1_61&&cl<week1_73) {          
//OrderSend(Symbol(), OP_BUY,LotsOptimized(), Ask, 200, NULL, NULL, "Buy(trendchaser super ea   " + MagicNumber  + ")", 4, 236, DodgerBlue);
 // trade2=1;
   
 //                 {
 //  }
 //  }
  //  if (OrderMagicNumber()==4&&cl>week1_100||cl<week1_0) {          
//OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
 //   trade2=0;
 //                 {
 //  }
 //  }
   //////
  if (trade_w1_fib&&trade==0&&cl>week1_50&&cl<week1_61) {          
OrderSend(Symbol(), OP_BUY,LotsOptimized(), Ask, 200, NULL, NULL, "Buy(trendchaser super ea   " + MagicNumber  + ")", 1, 236, DodgerBlue);
  trade=1;
   
                  {
   }
   }
  //  if (OrderMagicNumber()==1&&cl>week1_73||cl<week1_0) {          
//OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
 //   trade=0;
 //                 {
 //  }
 //  }
   
    /////////////////////////////////////////////////////////////////////////////////////////////////
 // if (trade_w1_fib&&trades3==0&&cl<week1_61&&cl>week1_50) {          
//OrderSend(Symbol(), OP_SELL,LotsOptimized(), Bid, 200, NULL, NULL, "Sell(trendchaser super ea   " + MagicNumber  + ")", 6, 0, DeepPink);
  //  trades3=1;
 // / 
  //                {
  // }
  // }
  //  if (OrderMagicNumber()==6&&cl<week1_50||cl>week1_100) {          
//OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
 //   trades3=0;
 //                 {
 //  }
 //  }
   ///////////////
   //if (trade_w1_fib&&trades2==0&&cl<week1_38&&cl>week1_23) {          
//OrderSend(Symbol(), OP_SELL,LotsOptimized(), Bid, 200, NULL, NULL, "Sell(trendchaser super ea   " + MagicNumber  + ")", 5, 0, DeepPink);
    //trades2=1;
   
     //             {
   //}
  // }
 //   if (OrderMagicNumber()==5&&cl<week1_0||cl>week1_100) {          
//OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
 //   trades2=0;
 //                 {
 //  }
 //  }
   ///////////////////
    if (trade_w1_fib&&trades==0&&cl<week1_50&&cl>week1_38) {          
OrderSend(Symbol(), OP_SELL,LotsOptimized(), Bid, 200, NULL, NULL, "Sell(trendchaser super ea   " + MagicNumber  + ")", 2, 0, DeepPink);
    trades=1;
   
                  {
   }
   }
  //  if (OrderMagicNumber()==2&&cl<week1_23||cl>week1_100) {          
//OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
  //  trades=0;
  ///                {
 //  }
 //  }
 
   
     if(take_a_break){
 multiply_hedge =false;
 hedge_plus=0;
         open_with_tc = False;
        open_with_tc2 = False;

       use_tc2_hedge = False;
          {

     }
   }  
   if(take_a_break&&openLongs == openShorts){
       use_tc2_hedge = False;
          {
     }
   }  
 if(dis_dbl_hedge&&pcnt<at_percent_profit){
 multiply_hedge =false;
 
          {

     }
   }  
   if(dis_dbl_hedge&&total_orders==0){
 multiply_hedge =true;
 
          {

     }
   }  
   
  
 /*  if (total_orders==0) {
open_with_envelopes = false;
reverse_second_tc_entry = false;

                  {
     }
   }   
   if (total_orders>0) {
open_with_envelopes = true;
reverse_second_tc_entry = true;

                  {
     }
   }   
*/
   if (cl<ema4) { 
   trendd="short";

                  {
     }
   }
   if (cl>ema4) { 
   trendd="long";


                  {
     }
   }
    if (use_tp&&cl<pivots_tp) { 
   
 Closeshorts();
                  {
     }
   }
   if (use_sl&&cl>pivots_sl) { 
   
 Closeshorts();

                  {
     }
   }
    if (use_tp&&cl>pivot_tp) { 
   
Closelongs(); 
                  {
     }
   }
   if (use_sl&&cl<pivot_sl) { 
   
Closelongs(); 

                  {
     }
   }
      
  if (refresh) {
     profb = 0.0;

        profs = 0.0;
  total_orders2 = 0;

  
 hedge_lots = false;
  pivot_long=true;
  pivot_short=true;
   symbol_profit=0;
      pro=0;  
           prob=0; 
           pros=0; 
acctotal_orders = 0;
aopenShorts= 0;
aopenLongs= 0;
     Min_Lots_allowed    = Lots;
       Dis_Mm_If_Lots_Under  = Lots;
                  {
     }
   }   
   if (OrdersTotal()==0) {
  trade=0;
  trades=0;
  trade2=0;
  trades2=0;
 trade3=0;
  trades3=0;
                  {
     }
   }  
   if (refresh) {
  
 h1_buy = false;
  h1_sell = false;
  h4_buy = false;
  h4_sell = false;
  day_buy = false;
  day_sell = false;
  week_buy = false;
  week_sell = false;
  month_buy = false;
  month_sell = false;
  
   hi_lo_filter = false;
 hedge_lots = false;
 
 probl=2;
profb=0;
profs=0;
  pivot_long=true;
  pivot_short=true;
   symbol_profit=0;
      pro=0;  
           prob=0; 
           pros=0; 
acctotal_orders = 0;
aopenShorts= 0;
aopenLongs= 0;

     Min_Lots_allowed    = Lots;
       Dis_Mm_If_Lots_Under  = Lots;
       //trail2();
                  {

     }
   } 

  
   if (!EachTickMode) BarCount = Bars;
   return(0);
}