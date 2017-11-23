//+------------------------------------------------------------------+
//|                                                CCFp(advisor).mq4 |
//|                                 m_a_sim@mail.ru - Simakov Mikhail|
//|                             http://www.mql4.com/ru/users/m_a_sim |
//+------------------------------------------------------------------+

#property copyright "m_a_sim@mail.ru - Simakov Mikhail"
#property link      "http://www.mql4.com/ru/users/m_a_sim"
// #include <stdlib.mqh>

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+

extern int MA_Method=3;
extern int Price=6;
extern int Fast=3;
extern int Slow=5;
extern int sl=200;
extern double lot=0.01;
extern int magicMAX=101;
extern int magicMIN=201;
extern int BreakevenStop             = 250;// Break even, o to disable
extern int Trail_Stop_Pips           = 250;//Trailing Stop, 0 to disable
extern int Trail_Stop_Jump_Pips      = 100;//Trail Stop Shift
extern bool TickMode   = false;
extern bool checkMaxMinCrossDirection = true;

int      oper_max_tries = 3,tries=0;

int init()
  {
//----
   log("CCFP EA Start to work!!!");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectsDeleteAll();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int bar;
int MAX,MIN,MAX1,MIN1;
double maxd,mind;
string label_name="Framework";
string comments = "ccfpea";
string values="";
int shift;
int start()
{
  drawInfo();
  int   i, jj,ticket,simMAX,simMIN;
  bool valideMax = true, valideMin = true;
  if(TickMode) shift = 0;
  else shift = 1;
  
  if (OrdersTotal()>0){
    for(i=0;i<OrdersTotal();i++) {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      // MAX
      if (OrderSymbol()=="EURUSD" && OrderMagicNumber()==magicMAX ){simMAX=1;}
      if (OrderSymbol()=="GBPUSD" && OrderMagicNumber()==magicMAX ){simMAX=2;}
      if (OrderSymbol()=="USDCHF" && OrderMagicNumber()==magicMAX ){simMAX=3;}
      if (OrderSymbol()=="USDJPY" && OrderMagicNumber()==magicMAX ){simMAX=4;}
      if (OrderSymbol()=="AUDUSD" && OrderMagicNumber()==magicMAX ){simMAX=5;}
      if (OrderSymbol()=="USDCAD" && OrderMagicNumber()==magicMAX ){simMAX=6;}
      if (OrderSymbol()=="NZDUSD" && OrderMagicNumber()==magicMAX ){simMAX=7;}
      // MIN
      if (OrderSymbol()=="EURUSD" && OrderMagicNumber()==magicMIN ){simMIN=1;}
      if (OrderSymbol()=="GBPUSD" && OrderMagicNumber()==magicMIN ){simMIN=2;}
      if (OrderSymbol()=="USDCHF" && OrderMagicNumber()==magicMIN ){simMIN=3;}
      if (OrderSymbol()=="USDJPY" && OrderMagicNumber()==magicMIN ){simMIN=4;}
      if (OrderSymbol()=="AUDUSD" && OrderMagicNumber()==magicMIN ){simMIN=5;}
      if (OrderSymbol()=="USDCAD" && OrderMagicNumber()==magicMIN ){simMIN=6;}
      if (OrderSymbol()=="NZDUSD" && OrderMagicNumber()==magicMIN ){simMIN=7;}
    }

    if(BreakevenStop > 0)DoBreakEven(BreakevenStop,0);
    if(Trail_Stop_Pips > 0) trail_stop();

    for(i=0;i<OrdersTotal();i++) {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber()==magicMAX){
        if(MAX!=simMAX) {
          if(OrderType()==OP_SELL)
          OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)
            ,MarketInfo(OrderSymbol(),MODE_DIGITS)),5,Violet);
          if(OrderType()==OP_BUY)
          OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)
            ,MarketInfo(OrderSymbol(),MODE_DIGITS)),5,Violet);
          log("Close order due to max value changed!!"); 
        }
      } else 
      if(OrderMagicNumber()==magicMIN){
        if(MIN!=simMIN) {
          if(OrderType()==OP_SELL)
          OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)
            ,MarketInfo(OrderSymbol(),MODE_DIGITS)),5,Violet); 
          if(OrderType()==OP_BUY)
          OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)
            ,MarketInfo(OrderSymbol(),MODE_DIGITS)),5,Violet); 
          log("Close order due to min value changed!!");
        }
      }
    }
  }

  // The following code will execute only once per bar
  if (bar!=Bars ){
    // maxd=iCustom(NULL, 0, "CCFp", false,MA_Method, Price, Fast, Slow, True, True, True, True, True, True
    //   , True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, 0, 0, 0, shift);
    // mind=iCustom(NULL, 0, "CCFp", false,MA_Method, Price, Fast, Slow, True, True, True, True, True, True
    //   , True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, 0, 0, 0, shift);
    maxd = -999;
    mind = 999;
    MAX=0;
    MIN=0;
    //double iUSD=iCustom(NULL, 0, "CCFp", false,MA_Method, Price, Fast, Slow, True, True, True, True, True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, 0, 0, 0, 1);
    values = "";
    for (i=0;i<=7;i++){
      double iValue=iCustom(NULL, 0, "CCFp", false,MA_Method, Price, Fast, Slow, True, True, True, True
        , True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, 0, 0, i, shift);
      values = values + "  ( "+i+" )  " + iValue + "\n";
      if (maxd<iValue)
      {
        maxd=iValue;
        MAX=i;
      }
      if (mind>iValue)
      { 
        mind=iValue;
        MIN=i;
      }
    }
    double pre_Max = iCustom(NULL, 0, "CCFp", false,MA_Method, Price, Fast, Slow, True, True, True, True
      , True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, 0, 0, MAX, shift+1);
    double pre_Min = iCustom(NULL, 0, "CCFp", false,MA_Method, Price, Fast, Slow, True, True, True, True
      , True, True, True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, 0, 0, MIN, shift+1);
    if(checkMaxMinCrossDirection){
      if(maxd-pre_Max<=0){
        valideMax = false;
      }
      if(mind-pre_Min>=0){
        valideMin = false;
      }
    }
    MAX1=0;
    MIN1=0;
    for (i=0;i<=7;i++){
      if (pre_Max
         <iCustom(NULL, 0, "CCFp", false,MA_Method, Price, Fast, Slow, True, True, True, True, True, True
          , True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, 0, 0, i, shift+1))
      {
        MAX1=1;
        log("CCFp max value changed!! Current time:" + TimeToStr(TimeCurrent())
           + " Current Max value: ("+ getSymbolByIndex(MAX) + ")" + maxd
           + " \nPrevious Max pair: ("+ getSymbolByIndex(i) + ")");
      }
      if (pre_Min
         >iCustom(NULL, 0, "CCFp", false,MA_Method, Price, Fast, Slow, True, True, True, True, True, True
          , True, True, Black, Black, Black, Black, Black, Black, Black, Black, 2, 0, 0, i, shift+1))
      {
        MIN1=1;
        log("CCFp min value changed!! Current time :" + TimeToStr(TimeCurrent())
          + " Current Min value: ("+ getSymbolByIndex(MIN) + ")" + mind
          + " \nPrevious Min pair: ("+ getSymbolByIndex(i) + ")");
      }
    }
    
    //Comment(MAX,"  ",MIN);
    Comment("MAX==="+MAX
            +"\nMIN--->"+MIN
            +"\nMAX1--->"+MAX1
            +"\nMIN1--->"+MIN1
            +"\n"+values);


    //MAX=====================================
    jj=0;
     if (OrdersTotal()>0){
       for(i=0;i<OrdersTotal();i++){
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if(OrderMagicNumber()==magicMAX){
          jj=1;
        }
       }
     }
    if (jj==0 && valideMax){
      if(IsTesting()){
        if (MAX==1&&MAX1==1 && Symbol()=="EURUSD"){ticket=OrderSend("EURUSD",OP_BUY ,lot,NormalizeDouble(MarketInfo("EURUSD",MODE_ASK),MarketInfo("EURUSD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("EURUSD",MODE_ASK),MarketInfo("EURUSD",MODE_DIGITS))-sl*MarketInfo("EURUSD",MODE_POINT),0," "+comments,magicMAX,0, Blue );}
        if (MAX==2&&MAX1==1 && Symbol()=="GBPUSD"){ticket=OrderSend("GBPUSD",OP_BUY ,lot,NormalizeDouble(MarketInfo("GBPUSD",MODE_ASK),MarketInfo("GBPUSD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("GBPUSD",MODE_ASK),MarketInfo("GBPUSD",MODE_DIGITS))-sl*MarketInfo("GBPUSD",MODE_POINT),0," "+comments,magicMAX,0, Blue );}
        if (MAX==3&&MAX1==1 && Symbol()=="USDCHF"){ticket=OrderSend("USDCHF",OP_SELL,lot,NormalizeDouble(MarketInfo("USDCHF",MODE_BID),MarketInfo("USDCHF",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("USDCHF",MODE_BID),MarketInfo("USDCHF",MODE_DIGITS))+sl*MarketInfo("USDCHF",MODE_POINT),0," "+comments,magicMAX,0, Red );}
        if (MAX==4&&MAX1==1 && Symbol()=="USDJPY"){ticket=OrderSend("USDJPY",OP_SELL,lot,NormalizeDouble(MarketInfo("USDJPY",MODE_BID),MarketInfo("USDJPY",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("USDJPY",MODE_BID),MarketInfo("USDJPY",MODE_DIGITS))+sl*MarketInfo("USDJPY",MODE_POINT),0," "+comments,magicMAX,0, Red );}
        if (MAX==5&&MAX1==1 && Symbol()=="AUDUSD"){ticket=OrderSend("AUDUSD",OP_BUY ,lot,NormalizeDouble(MarketInfo("AUDUSD",MODE_ASK),MarketInfo("AUDUSD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("AUDUSD",MODE_ASK),MarketInfo("AUDUSD",MODE_DIGITS))-sl*MarketInfo("AUDUSD",MODE_POINT),0," "+comments,magicMAX,0, Blue );}
        if (MAX==6&&MAX1==1 && Symbol()=="USDCAD"){ticket=OrderSend("USDCAD",OP_SELL,lot,NormalizeDouble(MarketInfo("USDCAD",MODE_BID),MarketInfo("USDCAD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("USDCAD",MODE_BID),MarketInfo("USDCAD",MODE_DIGITS))+sl*MarketInfo("USDCAD",MODE_POINT),0," "+comments,magicMAX,0, Red );}
        if (MAX==7&&MAX1==1 && Symbol()=="NZDUSD"){ticket=OrderSend("NZDUSD",OP_BUY ,lot,NormalizeDouble(MarketInfo("NZDUSD",MODE_ASK),MarketInfo("NZDUSD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("NZDUSD",MODE_ASK),MarketInfo("NZDUSD",MODE_DIGITS))-sl*MarketInfo("NZDUSD",MODE_POINT),0," "+comments,magicMAX,0, Blue );}
      
      }
      else {
        if (MAX==1&&MAX1==1){ticket=OrderSend("EURUSD",OP_BUY ,lot,NormalizeDouble(MarketInfo("EURUSD",MODE_ASK),MarketInfo("EURUSD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("EURUSD",MODE_ASK),MarketInfo("EURUSD",MODE_DIGITS))-sl*MarketInfo("EURUSD",MODE_POINT),0," "+comments,magicMAX,0, Blue );}
        if (MAX==2&&MAX1==1){ticket=OrderSend("GBPUSD",OP_BUY ,lot,NormalizeDouble(MarketInfo("GBPUSD",MODE_ASK),MarketInfo("GBPUSD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("GBPUSD",MODE_ASK),MarketInfo("GBPUSD",MODE_DIGITS))-sl*MarketInfo("GBPUSD",MODE_POINT),0," "+comments,magicMAX,0, Blue );}
        if (MAX==3&&MAX1==1){ticket=OrderSend("USDCHF",OP_SELL,lot,NormalizeDouble(MarketInfo("USDCHF",MODE_BID),MarketInfo("USDCHF",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("USDCHF",MODE_BID),MarketInfo("USDCHF",MODE_DIGITS))+sl*MarketInfo("USDCHF",MODE_POINT),0," "+comments,magicMAX,0, Red );}
        if (MAX==4&&MAX1==1){ticket=OrderSend("USDJPY",OP_SELL,lot,NormalizeDouble(MarketInfo("USDJPY",MODE_BID),MarketInfo("USDJPY",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("USDJPY",MODE_BID),MarketInfo("USDJPY",MODE_DIGITS))+sl*MarketInfo("USDJPY",MODE_POINT),0," "+comments,magicMAX,0, Red );}
        if (MAX==5&&MAX1==1){ticket=OrderSend("AUDUSD",OP_BUY ,lot,NormalizeDouble(MarketInfo("AUDUSD",MODE_ASK),MarketInfo("AUDUSD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("AUDUSD",MODE_ASK),MarketInfo("AUDUSD",MODE_DIGITS))-sl*MarketInfo("AUDUSD",MODE_POINT),0," "+comments,magicMAX,0, Blue );}
        if (MAX==6&&MAX1==1){ticket=OrderSend("USDCAD",OP_SELL,lot,NormalizeDouble(MarketInfo("USDCAD",MODE_BID),MarketInfo("USDCAD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("USDCAD",MODE_BID),MarketInfo("USDCAD",MODE_DIGITS))+sl*MarketInfo("USDCAD",MODE_POINT),0," "+comments,magicMAX,0, Red );}
        if (MAX==7&&MAX1==1){ticket=OrderSend("NZDUSD",OP_BUY ,lot,NormalizeDouble(MarketInfo("NZDUSD",MODE_ASK),MarketInfo("NZDUSD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("NZDUSD",MODE_ASK),MarketInfo("NZDUSD",MODE_DIGITS))-sl*MarketInfo("NZDUSD",MODE_POINT),0," "+comments,magicMAX,0, Blue );}
      }
    }
    
    
    //MIN================================

    jj=0;
     if (OrdersTotal()>0){
     for(i=0;i<OrdersTotal();i++){
     OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
     if(OrderMagicNumber()==magicMIN){jj=1;}
     }}

    if (jj==0 && valideMin){
      if(IsTesting()){
        if (MIN==1&&MIN1==1 && Symbol()=="EURUSD"){ticket=OrderSend("EURUSD",OP_SELL,lot,NormalizeDouble(MarketInfo("EURUSD",MODE_BID),MarketInfo("EURUSD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("EURUSD",MODE_BID),MarketInfo("EURUSD",MODE_DIGITS))+sl*MarketInfo("EURUSD",MODE_POINT),0," "+comments,magicMIN,0, Red );}
        if (MIN==2&&MIN1==1 && Symbol()=="GBPUSD"){ticket=OrderSend("GBPUSD",OP_SELL,lot,NormalizeDouble(MarketInfo("GBPUSD",MODE_BID),MarketInfo("GBPUSD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("GBPUSD",MODE_BID),MarketInfo("GBPUSD",MODE_DIGITS))+sl*MarketInfo("GBPUSD",MODE_POINT),0," "+comments,magicMIN,0, Red );}
        if (MIN==3&&MIN1==1 && Symbol()=="USDCHF"){ticket=OrderSend("USDCHF",OP_BUY ,lot,NormalizeDouble(MarketInfo("USDCHF",MODE_ASK),MarketInfo("USDCHF",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("USDCHF",MODE_ASK),MarketInfo("USDCHF",MODE_DIGITS))-sl*MarketInfo("USDCHF",MODE_POINT),0," "+comments,magicMIN,0, Blue );}
        if (MIN==4&&MIN1==1 && Symbol()=="USDJPY"){ticket=OrderSend("USDJPY",OP_BUY ,lot,NormalizeDouble(MarketInfo("USDJPY",MODE_ASK),MarketInfo("USDJPY",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("USDJPY",MODE_ASK),MarketInfo("USDJPY",MODE_DIGITS))-sl*MarketInfo("USDJPY",MODE_POINT),0," "+comments,magicMIN,0, Blue );}
        if (MIN==5&&MIN1==1 && Symbol()=="AUDUSD"){ticket=OrderSend("AUDUSD",OP_SELL,lot,NormalizeDouble(MarketInfo("AUDUSD",MODE_BID),MarketInfo("AUDUSD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("AUDUSD",MODE_BID),MarketInfo("AUDUSD",MODE_DIGITS))+sl*MarketInfo("AUDUSD",MODE_POINT),0," "+comments,magicMIN,0, Red );}
        if (MIN==6&&MIN1==1 && Symbol()=="USDCAD"){ticket=OrderSend("USDCAD",OP_BUY ,lot,NormalizeDouble(MarketInfo("USDCAD",MODE_ASK),MarketInfo("USDCAD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("USDCAD",MODE_ASK),MarketInfo("USDCAD",MODE_DIGITS))-sl*MarketInfo("USDCAD",MODE_POINT),0," "+comments,magicMIN,0, Blue );}
        if (MIN==7&&MIN1==1 && Symbol()=="NZDUSD"){ticket=OrderSend("NZDUSD",OP_SELL,lot,NormalizeDouble(MarketInfo("NZDUSD",MODE_BID),MarketInfo("NZDUSD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("NZDUSD",MODE_BID),MarketInfo("NZDUSD",MODE_DIGITS))+sl*MarketInfo("NZDUSD",MODE_POINT),0," "+comments,magicMIN,0, Red );}
    
      } else {
        if (MIN==1&&MIN1==1){ticket=OrderSend("EURUSD",OP_SELL,lot,NormalizeDouble(MarketInfo("EURUSD",MODE_BID),MarketInfo("EURUSD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("EURUSD",MODE_BID),MarketInfo("EURUSD",MODE_DIGITS))+sl*MarketInfo("EURUSD",MODE_POINT),0," "+comments,magicMIN,0, Red );}
        if (MIN==2&&MIN1==1){ticket=OrderSend("GBPUSD",OP_SELL,lot,NormalizeDouble(MarketInfo("GBPUSD",MODE_BID),MarketInfo("GBPUSD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("GBPUSD",MODE_BID),MarketInfo("GBPUSD",MODE_DIGITS))+sl*MarketInfo("GBPUSD",MODE_POINT),0," "+comments,magicMIN,0, Red );}
        if (MIN==3&&MIN1==1){ticket=OrderSend("USDCHF",OP_BUY ,lot,NormalizeDouble(MarketInfo("USDCHF",MODE_ASK),MarketInfo("USDCHF",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("USDCHF",MODE_ASK),MarketInfo("USDCHF",MODE_DIGITS))-sl*MarketInfo("USDCHF",MODE_POINT),0," "+comments,magicMIN,0, Blue );}
        if (MIN==4&&MIN1==1){ticket=OrderSend("USDJPY",OP_BUY ,lot,NormalizeDouble(MarketInfo("USDJPY",MODE_ASK),MarketInfo("USDJPY",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("USDJPY",MODE_ASK),MarketInfo("USDJPY",MODE_DIGITS))-sl*MarketInfo("USDJPY",MODE_POINT),0," "+comments,magicMIN,0, Blue );}
        if (MIN==5&&MIN1==1){ticket=OrderSend("AUDUSD",OP_SELL,lot,NormalizeDouble(MarketInfo("AUDUSD",MODE_BID),MarketInfo("AUDUSD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("AUDUSD",MODE_BID),MarketInfo("AUDUSD",MODE_DIGITS))+sl*MarketInfo("AUDUSD",MODE_POINT),0," "+comments,magicMIN,0, Red );}
        if (MIN==6&&MIN1==1){ticket=OrderSend("USDCAD",OP_BUY ,lot,NormalizeDouble(MarketInfo("USDCAD",MODE_ASK),MarketInfo("USDCAD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("USDCAD",MODE_ASK),MarketInfo("USDCAD",MODE_DIGITS))-sl*MarketInfo("USDCAD",MODE_POINT),0," "+comments,magicMIN,0, Blue );}
        if (MIN==7&&MIN1==1){ticket=OrderSend("NZDUSD",OP_SELL,lot,NormalizeDouble(MarketInfo("NZDUSD",MODE_BID),MarketInfo("NZDUSD",MODE_DIGITS)),5,NormalizeDouble(MarketInfo("NZDUSD",MODE_BID),MarketInfo("NZDUSD",MODE_DIGITS))+sl*MarketInfo("NZDUSD",MODE_POINT),0," "+comments,magicMIN,0, Red );}
      }
    }
  //=========================

    bar=Bars;
  }

   
   return(0);
}
//+------------------------------------------------------------------+


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
      if ( OrderMagicNumber() != magicMIN && OrderMagicNumber() != magicMAX )  continue;
      if ( OrderType() == OP_BUY ) {
         if (Bid<OrderOpenPrice()+BP*Point) continue;
         if ( OrderOpenPrice()+BE*Point-OrderStopLoss()>Point/10) {
               //Print(BP,"  ",BE," bestop");
               bres=OrderModify (OrderTicket(), OrderOpenPrice(), OrderOpenPrice()+BE*Point, OrderTakeProfit(), 0, Black);
           if (!bres) Print("Error Modifying BE BUY order : ",(GetLastError()));
           else log("Modify order stoploss due to break even");
         }
      }

      if ( OrderType() == OP_SELL ) {
         if (Ask>OrderOpenPrice()-BP*Point) continue;
         if ( OrderStopLoss()-(OrderOpenPrice()-BE*Point)>Point/10) {
               //Print(BP,"  ",BE," bestop");
               bres=OrderModify (OrderTicket(), OrderOpenPrice(), OrderOpenPrice()-BE*Point, OrderTakeProfit(), 0, Gold);
           if (!bres) Print("Error Modifying BE SELL order : ",(GetLastError()));
           else log("Modify order stoploss due to break even");
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
      if(OrderMagicNumber()==magicMIN && OrderMagicNumber()==magicMAX )
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
               log("Modify order stoploss due to trail_stop");
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
               log("Modify order stoploss due to trail_stop");
               tries=tries+1;
               
            }
         
         }
         
      }
   }
}

void log(string String)
{
   // if(!debugMode){
   //    return;
   // }
   int Handle;

   //if (!Auditing) return;
   string Filename = "logs\\" + "ccfpea" + " (" + Symbol() + ", " + strPeriod( Period() ) + 
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

string getSymbolByIndex(int index){
  switch (index)
  {
    case 0: return "USD";
    case 1: return "EUR";
    case 2: return "GBP";
    case 3: return "CHF";
    case 4: return "JPY";
    case 5: return "AUD";
    case 6: return "CAD";
    case 7: return "NZD";
  }
}