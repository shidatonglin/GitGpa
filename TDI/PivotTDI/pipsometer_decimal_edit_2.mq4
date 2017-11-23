//+------------------------------------------------------------------+
//|                                            luktom pipsometer.mq4 |
//|                                   luktom :: £ukasz Tomaszkiewicz |
//|                                               http://luktom.biz/ |
//+------------------------------------------------------------------+
#property copyright "luktom :: £ukasz Tomaszkiewicz"
#property link      "http://luktom.biz/"

#property indicator_chart_window

extern color color1=LimeGreen;
extern color color2=Black;
extern bool allSymbols=false;
extern int corner=3;

int init() {
   ObjectCreate("lpm_pips",OBJ_LABEL,0,0,0);
   ObjectSet("lpm_pips",OBJPROP_CORNER,corner);
   ObjectSetText("lpm_pips","pips",15);
   ObjectSet("lpm_pips",OBJPROP_COLOR,color1);
   ObjectSet("lpm_pips",OBJPROP_XDISTANCE,20);
   ObjectSet("lpm_pips",OBJPROP_YDISTANCE,25);
   
   

   start();
   
   return(0);
}

int deinit() {
   ObjectDelete("lpm_pips");
   ObjectDelete("lpm_pips_tosl");
   ObjectDelete("lpm_pips_realized");
   ObjectDelete("lpm_long");
   ObjectDelete("lpm_short");   
   ObjectDelete("lpm_longlabel");
   ObjectDelete("lpm_shortlabel");
   return(0);
}

int start() {

   ObjectSetText("lpm_short",DoubleToStr(countOrders(OP_SELL,allSymbols)/10,1));
   ObjectSetText("lpm_long",DoubleToStr(countOrders(OP_BUY,allSymbols)/10,1));
   
   double profit;
   double sl;
   calcProfit(profit,sl,allSymbols);
   
   ObjectSetText("lpm_pips",sign(profit)+DoubleToStr(MathAbs(profit)/10,1));
   ObjectSetText("lpm_pips_tosl",sign(sl)+DoubleToStr(MathAbs(sl)/10,1));

   double realized;
   calcRealized(realized,allSymbols);
   
   ObjectSetText("lpm_pips_realized",sign(realized)+DoubleToStr(MathAbs(realized)/10,1));


   return(0);
}

void calcRealized(double& out, bool allSymbols=false) {

   double profit=0;
   double p=0;   
      
   for(int i=0;i<OrdersHistoryTotal();i++) {
    if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) {
     
     if(allSymbols || OrderSymbol()==Symbol()) {
     
      if(OrderCloseTime()<StrToTime("0:00")) {
       continue;
      }
      
      p=0;
      
      if(OrderType()==OP_BUY) {
       p=(OrderClosePrice()-OrderOpenPrice())/Point;
      }
      
      if(OrderType()==OP_SELL) {
       p=(OrderOpenPrice()-OrderClosePrice())/Point;
      }
      
      profit+=p;
     
     }
    }
   }

   out=profit;

}

double calcProfit(double& out, double& outsl,bool allSymbols=false) {

   double profit=0;
   double p=0;
   double sl=0;
   double s=0;
      
   for(int i=0;i<OrdersTotal();i++) {
    if(OrderSelect(i,SELECT_BY_POS)) {
     
     if(allSymbols || OrderSymbol()==Symbol()) {
      
      p=0;
      s=0;
      
      if(OrderType()==OP_BUY) {
       p=(Bid-OrderOpenPrice())/Point;
       if(OrderStopLoss()>0) {
        s=(OrderStopLoss()-OrderOpenPrice())/Point;
       }
      }
      
      if(OrderType()==OP_SELL) {
       p=(OrderOpenPrice()-Ask)/Point;
       if(OrderStopLoss()>0) {
        s=(OrderOpenPrice()-OrderStopLoss())/Point;
       }
      }
      
      sl+=s;
      profit+=p;
     
     }
    }
   }
   
   out=profit;
   outsl=sl;

}

int countOrders(int oType,bool allSymbols=false) {

   int count=0;
 
   for(int i=0;i<OrdersTotal();i++) {
    if(OrderSelect(i,SELECT_BY_POS)) {
     if(allSymbols || OrderSymbol()==Symbol()) {
      if(OrderType()==oType || oType<0) {
       count++;
      }
     }
    }
   }
   
   return(count);
 
}

string sign(double value) {
 
   if(value>0) {
    return("+");
   }
 
   if(value<0) {
    return("-");
   }

}