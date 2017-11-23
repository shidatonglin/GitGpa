/*         
          o=======================================o
         //                                       \\
         O                  KEOPS                  O
        ||               by Edorenta               ||
        ||             (Paul de Renty)             ||
        ||           edorenta@gmail.com            ||
         O           __________________            O
         \\                                       //
          o=======================================o

        
         ____________________________________________
         T                                          T
         T           INTRO & EXT. INPUTS            T
         T__________________________________________T
*/

#property copyright     "Paul de Renty (Edorenta @ ForexFactory.com)"
#property link          "edorenta@gmail.com (mp me on FF rather than by email)"
#property description   "Keops' Pyramid; Step-in, Scale-in, Burn!"
#property version     "1.01" 

#property strict
#include <stdlib.mqh>
#define effacer 7

string version = "1.01";
extern bool open_buy = true;
extern bool open_sell = true;
extern int magic_1 = 0;                //Magic Number Long Cycle
extern int magic_2 = 0;                //Magic Number Short Cycle
extern bool show_name = true;            //Show EA name on chart

enum mm     {classic        //Classic
            ,mart           //Martingale
            ,r_mart         //Anti-Martingale (unavailable)
            ,scale          //Scale-in Loss
            ,r_scale        //Scale-in Profit  (unavailable)
            ,};
extern mm mm_mode = scale;             //Money Management

extern double blots = 0.01;            //Base lot size
extern double xtor = 1.6;              //Martingale multiplicator
extern double increment = 0.01;        //Scaler increment
extern int atr_p = 50;                 //ATR TP period
extern double atr_x = 0.5;             //ATR TP multiplier
extern double step_x = 0.5;            //Step (TP multiplier)
extern bool inc_step = true;           //Increasing step
/*
extern int ma1_p = 10;                     //MA ST period
extern ENUM_MA_METHOD ma1_type = MODE_EMA; //MA ST type
extern int ma2_p = 50;                     //MA LT period
extern ENUM_MA_METHOD ma2_type = MODE_EMA; //MA LT type
*/

extern int rsi_p = 5;                  //RSI period
extern int max_trades = 6;             //Max number of trades in Cycle

extern bool use_war_stop = true;       //Use Emergency Stop  
extern double war_stop_pct = 25;       //Emergency Stop K%

//extern bool reversed_logic = false;    //Reversed Logic
bool BUY, SELL;
bool sl1_set, sl2_set;

/*       ____________________________________________
         T                                          T
         T             ON INIT FUNCTION             T
         T__________________________________________T
*/

int OnInit(){
   return(INIT_SUCCEEDED);
}

/*       ____________________________________________
         T                                          T
         T             ON TICK FUNCTION             T
         T__________________________________________T
*/

void OnTick(){

//        o-----------------------o
//        |    INNER VARIABLES    |
//        o-----------------------o

double step_long;
double step_short;
double sl1, sl2, tp;
double mlots_1;
double mlots_2;
double spread, last, previous;
int i;
int nb_trades, nb_shorts, nb_longs;
double buy_min, buy_max, sell_max, sell_min;

if(show_name==true) Popup();

   double atr1 = iATR(NULL,0,atr_p,0);
   double atr2 = iATR(NULL,0,2*atr_p,0);
   double atr3 = NormalizeDouble(((atr1+atr2)/2)*atr_x,Digits);
   
   double ma1 = iMA(NULL,0,atr_p*2,0,MODE_LWMA,PRICE_HIGH,0);
   double ma2 = iMA(NULL,0,atr_p*2,0,MODE_LWMA,PRICE_LOW,0);
   double ma3 = NormalizeDouble(atr_x*(ma1 - ma2),Digits);

/*   
   double MA1 = iMA(NULL,0,ma1_p,0,ma1_type,PRICE_CLOSE,0);
   double PMA1 = iMA(NULL,0,ma1_p,0,ma1_type,PRICE_CLOSE,1);
   double MA2 = iMA(NULL,0,ma2_p,0,ma2_type,PRICE_CLOSE,0);
   double PMA2 = iMA(NULL,0,ma2_p,0,ma2_type,PRICE_CLOSE,1);

   double slope1 = NormalizeDouble((MA1-PMA1),4);                //slope1 ST
   double slope2 = NormalizeDouble((MA2-PMA2),4);                //slope1 LT
*/
 
   double RSI = iRSI(NULL,0,rsi_p,PRICE_CLOSE,0);
   double PRSI = iRSI(NULL,0,rsi_p,PRICE_CLOSE,1);
      
   last = Close[0];
   previous = Close[1];
   spread = Ask - Bid;
   tp = NormalizeDouble(((atr3+(ma3/1.25))/2)*atr_x,Digits);

//        o-----------------------o
//        |  CURRENT P/L COUNTER  |
//        o-----------------------o

buy_min = 0; buy_max = 0;
sell_min = 0; sell_max = 0;
nb_shorts = 0; nb_longs = 0;

   for(i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==Symbol())
            if((OrderMagicNumber()==magic_1||OrderMagicNumber()==magic_2)){
               if(OrderType()==OP_BUY){
                  nb_longs++;
                  if(OrderOpenPrice()<buy_min || buy_min==0){
                     buy_min=OrderOpenPrice();
                  }
                  if(OrderOpenPrice()>buy_max || buy_min==0){
                     buy_max=OrderOpenPrice();
                  }
               }
               if(OrderType()==OP_SELL){
                  nb_shorts++;
                  if(OrderOpenPrice()>sell_max || sell_max==0){
                     sell_max=OrderOpenPrice();
                  }
                  if(OrderOpenPrice()<sell_min || sell_min==0){
                     sell_min=OrderOpenPrice();
                  }
               }
            }

//Print(nb_shorts+" & "+sell_max);

nb_trades = nb_longs + nb_shorts;

//        o-----------------------o
//        |   RECOVERY MM SETS    |
//        o-----------------------o

mlots_1=blots;
mlots_2=blots;

if (mm_mode==mart){
   if (nb_longs>0){
      mlots_1=NormalizeDouble(blots*(MathPow(xtor,(nb_longs))),2);
   }
   if (nb_shorts>0){
      mlots_2=NormalizeDouble(blots*(MathPow(xtor,(nb_shorts))),2);
   }
}
if (mm_mode==scale){
   if (nb_longs>0){
      mlots_1=blots+(increment*nb_longs);
   }
   if (nb_shorts>0){
      mlots_2=blots+(increment*nb_shorts);
   }
}
//        o-----------------------o
//        |      FIRST TRADE      |
//        o-----------------------o

step_long = NormalizeDouble(tp*step_x,Digits);
step_short = NormalizeDouble(tp*step_x,Digits);

if (inc_step==true){
   step_long = NormalizeDouble(tp*step_x*nb_longs,Digits);
   step_short = NormalizeDouble(tp*step_x*nb_shorts,Digits);
}


if (open_buy && nb_longs==0){
   BUY = false;
   sl1_set = false;
   
   if (RSI>PRSI) {
      int ticket_buy = OrderSend(Symbol(),OP_BUY,mlots_1,
                Ask,0,0,Ask+tp,
                "Robot Test "+DoubleToStr(mlots_1,2)+" on "+Symbol(),
                magic_1,0,Turquoise);
      BUY = true;
         for(i=0;i<OrdersTotal();i++){
            if((OrderMagicNumber()==magic_1) && OrderSymbol()==Symbol() && OrderType() == OP_BUY){
             if( !  OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ) continue;
               OrderModify(OrderTicket(),OrderOpenPrice(),0,Ask+tp,0,Magenta);
            }
         }
   }
}

if (open_sell && nb_shorts==0){
   SELL = false; 
   sl2_set = false;
   
   if (RSI<PRSI) {
   int ticket_sell =  OrderSend(Symbol(),OP_SELL,mlots_2,
                Bid,0,0,Bid-tp,
                "Robot Test "+DoubleToStr(mlots_2,2)+" on "+Symbol(),
                magic_2,0,Magenta);
      SELL = true;
         for(i=0;i<OrdersTotal();i++){
            if((OrderMagicNumber()==magic_2) && OrderSymbol()==Symbol() && OrderType() == OP_SELL){
             if( !  OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ) continue;
               OrderModify(OrderTicket(),OrderOpenPrice(),0,Bid-tp,0,Magenta);
            }
         }
   }
}

//        o-----------------------o
//        |   SPAM OTHER TRADES   |
//        o-----------------------o

if (open_buy && nb_longs>0 && nb_longs<max_trades){
   if (BUY == true){
      if (RSI>PRSI && last<= NormalizeDouble(buy_min-(step_long),Digits)){
      int ticket_buy =   OrderSend(Symbol(),OP_BUY,mlots_1,
                Ask,0,0,0,
                "Robot Test "+DoubleToStr(mlots_1,2)+" on "+Symbol(),
                magic_1,0,Turquoise);
         
         for(i=0;i<OrdersTotal();i++){
            if((OrderMagicNumber()==magic_1) && OrderSymbol()==Symbol() && OrderType() == OP_BUY){
             if( !  OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ) continue;
               OrderModify(OrderTicket(),OrderOpenPrice(),0,NormalizeDouble((buy_min+tp),Digits),0,Turquoise);
            }
         }
      }
   }
}

if(nb_longs==max_trades && sl1_set == false){
   sl1_set=true;
   if(inc_step==true) sl1 = tp*nb_longs; else sl1 = tp;
   for(i=0;i<OrdersTotal();i++){
      if((OrderMagicNumber()==magic_1) && OrderSymbol()==Symbol() && OrderType() == OP_BUY){
             if( !  OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ) continue;
         OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(buy_min-sl1,Digits),OrderTakeProfit(),0,Turquoise);
      }
   }
}

if (open_sell && nb_shorts>0 && nb_shorts<max_trades){
   if (SELL == true){
      if (RSI<PRSI && last>= NormalizeDouble(sell_max+(step_short),Digits)){
       int ticket_sell =    OrderSend(Symbol(),OP_SELL,mlots_2,
                Bid,3,0,0,
                "Robot Test "+DoubleToStr(mlots_2,2)+" on "+Symbol(),
                magic_2,0,Magenta);
         
        
    //  double be = calculate_be();
    //      put_profit_on_be();  
        
         
                  for(i=0;i<OrdersTotal();i++){
            if((OrderMagicNumber()==magic_2) && OrderSymbol()==Symbol() && OrderType() == OP_SELL){
             if( !  OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ) continue;
               OrderModify(OrderTicket(),OrderOpenPrice(),0,NormalizeDouble((sell_max-tp),Digits),0,Magenta);
           
            }
         }
      }
   }
}

if(nb_shorts==max_trades && sl2_set == false){
   sl2_set = true;
   if(inc_step==true) sl2 = tp*nb_shorts; else sl2 = tp;
   for(i=0;i<OrdersTotal();i++){
      if((OrderMagicNumber()==magic_2) && OrderSymbol()==Symbol() && OrderType() == OP_SELL){
             if( !  OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ) continue;
         OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(sell_max+sl2,Digits),OrderTakeProfit(),0,Turquoise);
      }
   }
}

//        o-----------------------o
//        | Emergency Marin Call  |
//        o-----------------------o

if(use_war_stop==true){
   if(AccountEquity()<=NormalizeDouble(AccountBalance()*(1-(war_stop_pct/100)),2)){
   
   for(i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i,SELECT_BY_POS))         
         if(OrderSymbol() == Symbol() && (OrderMagicNumber()==magic_2||OrderMagicNumber()==magic_1))
            if(OrderType()==OP_BUY)
               OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits()),0,Turquoise);
            else
               OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits()),0,Magenta);
   }
}

string comment = "\n \n"
        + "*** Information *** \n"
        + "\n"
        
        + "Entry Levels: \n \n"
	     + "Higher Buy: " + (string) buy_max + "\n"
	     + "Lower Buy: " + (string) buy_min + "\n"
	     + "Higher Sell: " + (string) sell_max + "\n"
	     + "Lower Buy: " + (string) sell_min + "\n \n"
	        
        + "Current Trades: \n \n"
        + "Longs: " + (string)nb_longs + " / Shorts: " +(string)  nb_shorts + "\n"
        
        + "Risk Indicators: \n\n"
/*        + "Current lots long: " + data_counter(20) + "\n"
        + "Next size long: " + mlots_3 + "\n"
        + "Current lots short: " + data_counter(21) + "\n"
        + "Next size short: " + mlots_4 + "\n \n"        
*/       
        + "SL & TP Levels: \n \n"
        + "Spread: " +(string)  MarketInfo(Symbol(),MODE_SPREAD) + " points \n"
        + "Stoplevel/Freezelevel: " + DoubleToStr(MarketInfo(Symbol(),MODE_STOPLEVEL))
	     + " / " + DoubleToStr(MarketInfo(Symbol(),MODE_FREEZELEVEL)) + "\n"
	     + "Stoploss: " + (string) tp + " (" + DoubleToStr(tp/(10*Point),1) + " pips)";  
        
Comment (comment);

         calculate_be(0);
         calculate_be(1);



}

void Popup() {
   string txt2 = version + "20";
   if (ObjectFind(txt2) == -1) {
      ObjectCreate(txt2, OBJ_LABEL, 0, 0, 0);
      ObjectSet(txt2, OBJPROP_CORNER, 0);
      ObjectSet(txt2, OBJPROP_XDISTANCE, 437);
      ObjectSet(txt2, OBJPROP_YDISTANCE, 2);
   }
   ObjectSetText(txt2, "Keops",20, "Century Gothic", LightGray);
   
   txt2 = version + "21";
   if (ObjectFind(txt2) == -1) {
      ObjectCreate(txt2, OBJ_LABEL, 0, 0, 0);
      ObjectSet(txt2, OBJPROP_CORNER, 0);
      ObjectSet(txt2, OBJPROP_XDISTANCE, 432);
      ObjectSet(txt2, OBJPROP_YDISTANCE, 49);
   }
   ObjectSetText(txt2, "by Edorenta || version " + version, 8, "Arial", Yellow);
   
   txt2 = version + "22";
   if (ObjectFind(txt2) == -1) {
      ObjectCreate(txt2, OBJ_LABEL, 0, 0, 0);
      ObjectSet(txt2, OBJPROP_CORNER, 0);
      ObjectSet(txt2, OBJPROP_XDISTANCE, 398);
      ObjectSet(txt2, OBJPROP_YDISTANCE, 35);
   }
   ObjectSetText(txt2, "______________________________", 8, "Arial", Gray);
   
   txt2 = version + "23";
   if (ObjectFind(txt2) == -1) {
      ObjectCreate(txt2, OBJ_LABEL, 0, 0, 0);
      ObjectSet(txt2, OBJPROP_CORNER, 0);
      ObjectSet(txt2, OBJPROP_XDISTANCE, 398);
      ObjectSet(txt2, OBJPROP_YDISTANCE, 50);
   }
   ObjectSetText(txt2, "______________________________", 8, "Arial", Gray);
}
/*       ____________________________________________
         T                                          T
         T                 THE END                  T
         T__________________________________________T
*/


double calculate_be(int sens = -1 )
 {
   int Total_Buy_Trades=-1;
   double Total_Buy_Size=0.0;
   double Total_Buy_Price=0.0;
   double Buy_Profit=0.0;
//---
   int Total_Sell_Trades=-1;
   double Total_Sell_Size=0.0;
   double Total_Sell_Price=0.0;
   double Sell_Profit=0.0;
//---
   int Net_Trades=0;
   double Net_Lots=0.0;
   double Net_Result=0.0;
//---
   double Average_Price=0.0;
   double distance=0.0;
   double Pip_Value=MarketInfo(Symbol(),MODE_TICKVALUE)*Point;
   double Pip_Size=MarketInfo(Symbol(),MODE_TICKSIZE)*Point;
//---
   int total=OrdersTotal();//---
   for(int i=0;i<total;i++)
     {
      int ord=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
        {
         if(OrderType()==OP_BUY && OrderSymbol()==Symbol())

           {
            Total_Buy_Trades++;
            Total_Buy_Price+= OrderOpenPrice()*OrderLots();
            Total_Buy_Size += OrderLots();
            Buy_Profit+=OrderProfit()+OrderSwap()+OrderCommission();
           }
         if(OrderType()==OP_SELL && OrderSymbol()==Symbol())
           {
            Total_Sell_Trades++;
            Total_Sell_Size+=OrderLots();
            Total_Sell_Price+=OrderOpenPrice()*OrderLots();
            Sell_Profit+=OrderProfit()+OrderSwap()+OrderCommission();
           }
        }
     }
   if(Total_Buy_Price>0)
     {
      Total_Buy_Price/=Total_Buy_Size;
     }
   if(Total_Sell_Price>0)
     {
      Total_Sell_Price/=Total_Sell_Size;
     }
     
  if( Total_Buy_Price != 0.0 ) H_line_Nom(0,Total_Buy_Price,"Total_Buy_Price");
  else                         H_line_Nom(effacer,0,"Total_Buy_Price");
  if( Total_Sell_Price != 0.0 ) H_line_Nom(1,Total_Sell_Price,"Total_Sell_Price");
  else                          H_line_Nom(effacer,0,"Total_Sell_Price");
     
  if( sens == OP_BUY)   return( Total_Buy_Price );
  if( sens == OP_SELL)   return( Total_Sell_Price );
 
  else return(-1);
  }



 //============================================================================
  int H_line_Nom( int sens, double prix1, string nom ="")
    {
     color couleur = Silver; 
    
     switch( sens ) 
       {
       case 0 : couleur =  PaleGreen;  break;
       case 1 : couleur =  Coral;      break;
       case 2 : couleur =  Violet;     break;
       case 3 : couleur =  Magenta;    break;
       case  effacer :
       if( ObjectFind(nom )>-1 ) ObjectDelete (nom );
       default : break;
       }
       
       
        ObjectDelete (nom );
        ObjectCreate (nom  , OBJ_HLINE, 0 , Time[0], prix1);
        ObjectSet    (nom  , OBJPROP_COLOR, couleur );
        ObjectSet    (nom  , OBJPROP_WIDTH, 2);
        WindowRedraw();
    //-------------
    return(0);
    }
//==================================================================================   









