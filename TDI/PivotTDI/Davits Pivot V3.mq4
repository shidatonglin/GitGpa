//+------------------------------------------------------------------+
//|                                              Davits Pivot V2.mq4 |
//|                                                     Griffinssoul |
//|                         http://www.forexfactory.com/griffinssoul |
//+------------------------------------------------------------------+
#property copyright "Griffinssoul"
#property link      "http://www.forexfactory.com/griffinssoul"
#property version   "3.00"
#property strict
#property indicator_chart_window
//
#property description "Griffinssoul 28022016 - added 78.6 fib-pivot and price to lines."
#property description "Griffinssoul 28022016 - added long and short horizontal lines."
#property description "Nico Scholtz 19092016 - fixed bug in manual pivot calculation."
//string endofpivot1=TimeToStr(iTime(0,PERIOD_D1,1),TIME_DATE);
//string startofpivot=TimeToStr(iTime(0,PERIOD_D1,2),TIME_DATE);
extern bool brokercandle=true;//Broker's Candle
extern datetime startofpivot=D'2016.09.12 07:00';//Choose H1 Start Candle
extern datetime endofpivot=D'2016.09.19 06:00';//Choose H1 Finish Candle
extern bool StartEndLines=true;//Display Start and End lines for manual settings
extern string  comment1="Choose the TF ";
//--
enum TFOfPivot
  {
   M=1,     // MN
   W=2,     // W1
   D=3,     // D1
  };
input TFOfPivot swaptf=2;
//--
extern string  comment2="Choose Pivot Method ";
//--
enum PivotMethod
  {
   HLC=1,      // Avg of High, Low, Close
   HLCC=2,     // Avg of High, Low, Close, Close
   HLOC=3,     // Avg of High, Low, Open, Close
   HLOO=4,     // Avg of High, Low, Open, Open
   HLO=5,// Avg of High, Low, Open
  };
input PivotMethod pivot_meth=1;
//--
extern bool pivot_fib=true;//Choose Fib(true) or Standard(false)
extern color chose_color_pivot = clrBlue;
extern color label_color_pivot = clrBlue;
extern int width_of_pivot_line = 0;
extern int line_style_of_pivot = 4;
extern color chose_color_R38 = clrRed;
extern color label_color_R38 = clrRed;
extern color chose_color_R61 = clrRed;
extern color label_color_R61 = clrRed;
extern color chose_color_R78 = clrRed;
extern color label_color_R78 = clrRed;
extern color chose_color_R100 = clrRed;
extern color label_color_R100 = clrRed;
extern color chose_color_R138 = clrRed;
extern color label_color_R138 = clrRed;
extern color chose_color_R161 = clrRed;
extern color label_color_R161 = clrRed;
extern color chose_color_R200 = clrRed;
extern color label_color_R200 = clrRed;
extern int width_of_R_line = 0;
extern int line_style_of_R = 1;
extern color chose_color_S38 = clrGreen;
extern color label_color_S38 = clrGreen;
extern color chose_color_S61 = clrGreen;
extern color label_color_S61 = clrGreen;
extern color chose_color_S78 = clrGreen;
extern color label_color_S78 = clrGreen;
extern color chose_color_S100 = clrGreen;
extern color label_color_S100 = clrGreen;
extern color chose_color_S138 = clrGreen;
extern color label_color_S138 = clrGreen;
extern color chose_color_S161 = clrGreen;
extern color label_color_S161 = clrGreen;
extern color chose_color_S200 = clrGreen;
extern color label_color_S200 = clrGreen;
extern int width_of_S_line = 0;
extern int line_style_of_S = 1;
extern int LL=40;//Length of lines 
extern int SS=0;//Shift to right
extern bool show_200=false;//Show all S&R to 200% 
extern bool ShortHorizontalLines=false;//Short(default) or Long(with price labels) horizontal lines
                                       //--
double wclose= 0;
double wopen = 0;
double whigh = 0;
double wlow=0;
//--
double calPivot = 0;
double calRange = 0;
//--
double R38  = 0;
double R61  = 0;
double R78  = 0;
double R100 = 0;
double R138 = 0;
double R161 = 0;
double R200 = 0;
//--
double S38  = 0;
double S61  = 0;
double S78  = 0;
double S100 = 0;
double S138 = 0;
double S161 = 0;
double S200 = 0;
//--
double R1 = 0;
double R2 = 0;
double R3 = 0;
double S1 = 0;
double S2 = 0;
double S3 = 0;
//--
int    chose_tf;
string lableR38;
string lableR61;
string lableR78;
string lableR100;
string lableS38;
string lableS61;
string lableS78;
string lableS100;
//+------------------------------------------------------------------+
int start()
  {
//-------------------------------------------------------------------+   
   if(brokercandle==true)
     {
      ObjectDelete("Start");
      ObjectDelete("End");
      switch(swaptf)
        {
         case 1:chose_tf=PERIOD_MN1;break;
         case 2:chose_tf=PERIOD_W1;break;
         case 3:chose_tf=PERIOD_D1;break;
        }
      wclose= iClose(Symbol(),chose_tf,1);
      wopen = iClose(Symbol(),chose_tf,1);
      whigh = iHigh(Symbol(),chose_tf,1);
      wlow=iLow(Symbol(),chose_tf,1);
     }
   else if(brokercandle==false)
     {
      ObjectDelete("Start");
      ObjectDelete("End");
      int BarShft_Start=iBarShift(Symbol(),PERIOD_H1,startofpivot);
      int BarShft_End=iBarShift(Symbol(),PERIOD_H1,endofpivot);
      wopen=iOpen(Symbol(),PERIOD_H1,BarShft_Start);
      wclose=iClose(Symbol(),PERIOD_H1,BarShft_End);
      int HighBar= iHighest(Symbol(),PERIOD_H1,MODE_HIGH,BarShft_Start-BarShft_End+1,BarShft_End);
      int LowBar = iLowest(Symbol(),PERIOD_H1,MODE_LOW,BarShft_Start-BarShft_End+1,BarShft_End);
      whigh= iHigh(Symbol(),PERIOD_H1,HighBar);
      wlow = iLow(Symbol(),PERIOD_H1,LowBar);
      //Comment("Start ", BarShft_Start, " End ", BarShft_End, "  High ", whigh, " Low ", wlow, " Open ", wopen, " Close ", wclose, " High ", whigh, " Low ", wlow );
      if(BarShft_Start<BarShft_End)
        {
         Alert("Error - Start time must be less than End time!");
        }
      if(StartEndLines==true)
        {
         ObjectCreate(0,"Start",OBJ_VLINE,0,startofpivot,0);
         ObjectSetInteger(0,"Start",OBJPROP_COLOR,clrLimeGreen);
         ObjectSetInteger(0,"Start",OBJPROP_WIDTH,0);
         ObjectSetInteger(0,"Start",OBJPROP_STYLE,2);

         ObjectCreate(0,"End",OBJ_VLINE,0,endofpivot,0);
         ObjectSetInteger(0,"End",OBJPROP_COLOR,clrTomato);
         ObjectSetInteger(0,"End",OBJPROP_WIDTH,0);
         ObjectSetInteger(0,"End",OBJPROP_STYLE,2);
        }
     }
   switch(pivot_meth)
     {
      case 1:calPivot = (whigh+wlow+wclose)/3;break;
      case 2:calPivot = (whigh+wlow+wclose+wclose)/4;break;
      case 3:calPivot = (whigh+wlow+wclose+wopen)/4;break;
      case 4:calPivot = (whigh+wlow+wopen+wopen)/4;break;
      case 5:calPivot = (whigh+wlow+wopen)/3;break;
     }

   calRange=(whigh-wlow);

   if(pivot_fib==true)
     {
      R38  = calRange*0.382+calPivot;
      R61  = calRange*0.618+calPivot;
      R78  = calRange*0.786+calPivot;
      R100 = calRange*1.00+calPivot;
      R138 = calRange*1.382+calPivot;
      R161 = calRange*1.618+calPivot;
      R200 = calRange*2.00+calPivot;

      S38  = calPivot-calRange*0.382;
      S61  = calPivot-calRange*0.618;
      S78  = calPivot-calRange*0.786;
      S100 = calPivot-calRange*1.00;
      S138 = calPivot-calRange*1.382;
      S161 = calPivot-calRange*1.618;
      S200 = calPivot-calRange*2.00;

      lableR38="R38 ";
      lableR61="R61 ";
      lableR78="R78 ";
      lableR100="R100 ";
      lableS38="S38 ";
      lableS61="S61 ";
      lableS78="S78 ";
      lableS100="S100 ";
     }
   else if(pivot_fib==false)
     {
      R1=2*calPivot-wlow;
      R2=calPivot+(whigh-wlow);
      R3=R2+(whigh-wlow);
      S1=2*calPivot-whigh;
      S2=calPivot-(whigh-wlow);
      S3=S2-(whigh-wlow);

      lableR38="R1";
      lableR61="R2";
      lableR100="R3";
      lableS38="S1";
      lableS61="S2";
      lableS100="S3";

      R38=R1;
      R61=R2;
      R100=R3;
      S38=S1;
      S61=S2;
      S100=S3;

      show_200=false;
     }
   if(ShortHorizontalLines==true)
     {
      ObjectCreate("WP_line",OBJ_TREND,0,Time[LL],calPivot,Time[0]+Period()*(900+SS),calPivot);
      ObjectSet("WP_line",OBJPROP_COLOR,chose_color_pivot);
      ObjectSet("WP_line",OBJPROP_WIDTH,width_of_pivot_line);
      ObjectSet("WP_line",OBJPROP_STYLE,line_style_of_pivot);
      ObjectSet("WP_line",OBJPROP_RAY,false);
      double WP_line_Price=ObjectGet("WP_line",OBJPROP_PRICE1);
      ObjectCreate("WP_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),calPivot);
      ObjectSetText("WP_label","Pivot: "+DoubleToStr(WP_line_Price,4),10,"Arial",label_color_pivot);

      ObjectCreate("WP_R38",OBJ_TREND,0,Time[LL],R38,Time[0]+Period()*(900+SS),R38);
      ObjectSet("WP_R38",OBJPROP_COLOR,chose_color_R38);
      ObjectSet("WP_R38",OBJPROP_WIDTH,width_of_R_line);
      ObjectSet("WP_R38",OBJPROP_STYLE,line_style_of_R);
      ObjectSet("WP_R38",OBJPROP_RAY,false);
      double WP_R38_Price=ObjectGet("WP_R38",OBJPROP_PRICE1);
      ObjectCreate("WP_R38_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),R38);
      ObjectSetText("WP_R38_label",lableR38+DoubleToStr(WP_R38_Price,4),10,"Arial",label_color_R38);

      ObjectCreate("WP_S38",OBJ_TREND,0,Time[LL],S38,Time[0]+Period()*(900+SS),S38);
      ObjectSet("WP_S38",OBJPROP_COLOR,chose_color_S38);
      ObjectSet("WP_S38",OBJPROP_WIDTH,width_of_S_line);
      ObjectSet("WP_S38",OBJPROP_STYLE,line_style_of_S);
      ObjectSet("WP_S38",OBJPROP_RAY,false);
      double WP_S38_Price=ObjectGet("WP_S38",OBJPROP_PRICE1);
      ObjectCreate("WP_S38_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),S38);
      ObjectSetText("WP_S38_label",lableS38+DoubleToStr(WP_S38_Price,4),10,"Arial",label_color_S38);

      ObjectCreate("WP_R61",OBJ_TREND,0,Time[LL],R61,Time[0]+Period()*(900+SS),R61);
      ObjectSet("WP_R61",OBJPROP_COLOR,chose_color_R61);
      ObjectSet("WP_R61",OBJPROP_WIDTH,width_of_R_line);
      ObjectSet("WP_R61",OBJPROP_STYLE,line_style_of_R);
      ObjectSet("WP_R61",OBJPROP_RAY,false);
      double WP_R61_Price=ObjectGet("WP_R61",OBJPROP_PRICE1);
      ObjectCreate("WP_R61_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),R61);
      ObjectSetText("WP_R61_label",lableR61+DoubleToStr(WP_R61_Price,4),10,"Arial",label_color_R61);

      ObjectCreate("WP_S61",OBJ_TREND,0,Time[LL],S61,Time[0]+Period()*(900+SS),S61);
      ObjectSet("WP_S61",OBJPROP_COLOR,chose_color_S61);
      ObjectSet("WP_S61",OBJPROP_WIDTH,width_of_S_line);
      ObjectSet("WP_S61",OBJPROP_STYLE,line_style_of_S);
      ObjectSet("WP_S61",OBJPROP_RAY,false);
      double WP_S61_Price=ObjectGet("WP_S61",OBJPROP_PRICE1);
      ObjectCreate("WP_S61_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),S61);
      ObjectSetText("WP_S61_label",lableS61+DoubleToStr(WP_S61_Price,4),10,"Arial",label_color_S61);

      ObjectCreate("WP_R78",OBJ_TREND,0,Time[LL],R78,Time[0]+Period()*(900+SS),R78);
      ObjectSet("WP_R78",OBJPROP_COLOR,chose_color_R78);
      ObjectSet("WP_R78",OBJPROP_WIDTH,width_of_R_line);
      ObjectSet("WP_R78",OBJPROP_STYLE,line_style_of_R);
      ObjectSet("WP_R78",OBJPROP_RAY,false);
      double WP_R78_Price=ObjectGet("WP_R78",OBJPROP_PRICE1);
      ObjectCreate("WP_R78_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),R78);
      ObjectSetText("WP_R78_label",lableR78+DoubleToStr(WP_R78_Price,4),10,"Arial",label_color_R78);

      ObjectCreate("WP_S78",OBJ_TREND,0,Time[LL],S78,Time[0]+Period()*(900+SS),S78);
      ObjectSet("WP_S78",OBJPROP_COLOR,chose_color_S78);
      ObjectSet("WP_S78",OBJPROP_WIDTH,width_of_S_line);
      ObjectSet("WP_S78",OBJPROP_STYLE,line_style_of_S);
      ObjectSet("WP_S78",OBJPROP_RAY,false);
      double WP_S78_Price=ObjectGet("WP_S78",OBJPROP_PRICE1);
      ObjectCreate("WP_S78_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),S78);
      ObjectSetText("WP_S78_label",lableS78+DoubleToStr(WP_S78_Price,4),10,"Arial",label_color_S78);

      ObjectCreate("WP_R100",OBJ_TREND,0,Time[LL],R100,Time[0]+Period()*(900+SS),R100);
      ObjectSet("WP_R100",OBJPROP_COLOR,chose_color_R100);
      ObjectSet("WP_R100",OBJPROP_WIDTH,width_of_R_line);
      ObjectSet("WP_R100",OBJPROP_STYLE,line_style_of_R);
      ObjectSet("WP_R100",OBJPROP_RAY,false);
      double WP_R100_Price=ObjectGet("WP_R100",OBJPROP_PRICE1);
      ObjectCreate("WP_R100_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),R100);
      ObjectSetText("WP_R100_label",lableR100+DoubleToStr(WP_R100_Price,4),10,"Arial",label_color_R100);

      ObjectCreate("WP_S100",OBJ_TREND,0,Time[LL],S100,Time[0]+Period()*(900+SS),S100);
      ObjectSet("WP_S100",OBJPROP_COLOR,chose_color_S100);
      ObjectSet("WP_S100",OBJPROP_WIDTH,width_of_S_line);
      ObjectSet("WP_S100",OBJPROP_STYLE,line_style_of_S);
      ObjectSet("WP_S100",OBJPROP_RAY,false);
      double WP_S100_Price=ObjectGet("WP_S100",OBJPROP_PRICE1);
      ObjectCreate("WP_S100_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),S100);
      ObjectSetText("WP_S100_label",lableS100+DoubleToStr(WP_S100_Price,4),10,"Arial",label_color_S100);

      if(show_200==true)
        {
         ObjectCreate("WP_R200",OBJ_TREND,0,Time[LL],R200,Time[0]+Period()*(900+SS),R200);
         ObjectSet("WP_R200",OBJPROP_COLOR,chose_color_R200);
         ObjectSet("WP_R200",OBJPROP_WIDTH,width_of_R_line);
         ObjectSet("WP_R200",OBJPROP_STYLE,line_style_of_R);
         ObjectSet("WP_R200",OBJPROP_RAY,false);
         double WP_R200_Price=ObjectGet("WP_R200",OBJPROP_PRICE1);
         ObjectCreate("WP_R200_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),R200);
         ObjectSetText("WP_R200_label","R200 "+DoubleToStr(WP_R200_Price,4),10,"Arial",label_color_R200);

         ObjectCreate("WP_S200",OBJ_TREND,0,Time[LL],S200,Time[0]+Period()*(900+SS),S200);
         ObjectSet("WP_S200",OBJPROP_COLOR,chose_color_S200);
         ObjectSet("WP_S200",OBJPROP_WIDTH,width_of_S_line);
         ObjectSet("WP_S200",OBJPROP_STYLE,line_style_of_S);
         ObjectSet("WP_S200",OBJPROP_RAY,false);
         double WP_S200_Price=ObjectGet("WP_S200",OBJPROP_PRICE1);
         ObjectCreate("WP_S200_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),S200);
         ObjectSetText("WP_S200_label","S200 "+DoubleToStr(WP_S200_Price,4),10,"Arial",label_color_S200);

         ObjectCreate("WP_R138",OBJ_TREND,0,Time[LL],R138,Time[0]+Period()*(900+SS),R138);
         ObjectSet("WP_R138",OBJPROP_COLOR,chose_color_R138);
         ObjectSet("WP_R138",OBJPROP_WIDTH,width_of_R_line);
         ObjectSet("WP_R138",OBJPROP_STYLE,line_style_of_R);
         ObjectSet("WP_R138",OBJPROP_RAY,false);
         double WP_R138_Price=ObjectGet("WP_R138",OBJPROP_PRICE1);
         ObjectCreate("WP_R138_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),R138);
         ObjectSetText("WP_R138_label","R138 "+DoubleToStr(WP_R138_Price,4),10,"Arial",label_color_R138);

         ObjectCreate("WP_S138",OBJ_TREND,0,Time[LL],S138,Time[0]+Period()*(900+SS),S138);
         ObjectSet("WP_S138",OBJPROP_COLOR,chose_color_S138);
         ObjectSet("WP_S138",OBJPROP_WIDTH,width_of_S_line);
         ObjectSet("WP_S138",OBJPROP_STYLE,line_style_of_S);
         ObjectSet("WP_S138",OBJPROP_RAY,false);
         double WP_S138_Price=ObjectGet("WP_S138",OBJPROP_PRICE1);
         ObjectCreate("WP_S138_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),S138);
         ObjectSetText("WP_S138_label","S138 "+DoubleToStr(WP_S138_Price,4),10,"Arial",label_color_S138);

         ObjectCreate("WP_R161",OBJ_TREND,0,Time[LL],R161,Time[0]+Period()*(900+SS),R161);
         ObjectSet("WP_R161",OBJPROP_COLOR,chose_color_R161);
         ObjectSet("WP_R161",OBJPROP_WIDTH,width_of_R_line);
         ObjectSet("WP_R161",OBJPROP_STYLE,line_style_of_R);
         ObjectSet("WP_R161",OBJPROP_RAY,false);
         double WP_R161_Price=ObjectGet("WP_R161",OBJPROP_PRICE1);
         ObjectCreate("WP_R161_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),R161);
         ObjectSetText("WP_R161_label","R161 "+DoubleToStr(WP_R161_Price,4),10,"Arial",label_color_R161);

         ObjectCreate("WP_S161",OBJ_TREND,0,Time[LL],S161,Time[0]+Period()*(900+SS),S161);
         ObjectSet("WP_S161",OBJPROP_COLOR,chose_color_S161);
         ObjectSet("WP_S161",OBJPROP_WIDTH,width_of_S_line);
         ObjectSet("WP_S161",OBJPROP_STYLE,line_style_of_S);
         ObjectSet("WP_S161",OBJPROP_RAY,false);
         double WP_S161_Price=ObjectGet("WP_S161",OBJPROP_PRICE1);
         ObjectCreate("WP_S161_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),S161);
         ObjectSetText("WP_S161_label","S161 "+DoubleToStr(WP_S161_Price,4),10,"Arial",label_color_S161);
        }
        }else{
      ObjectCreate("WP_line",OBJ_HLINE,0,0,calPivot);
      ObjectSet("WP_line",OBJPROP_COLOR,chose_color_pivot);
      ObjectSet("WP_line",OBJPROP_WIDTH,width_of_pivot_line);
      ObjectSet("WP_line",OBJPROP_STYLE,line_style_of_pivot);
      ObjectSet("WP_line",OBJPROP_RAY,false);
      ObjectCreate("WP_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),calPivot);
      ObjectSetText("WP_label","Pivot",10,"Arial",label_color_pivot);

      ObjectCreate("WP_R38",OBJ_HLINE,0,0,R38);
      ObjectSet("WP_R38",OBJPROP_COLOR,chose_color_R38);
      ObjectSet("WP_R38",OBJPROP_WIDTH,width_of_R_line);
      ObjectSet("WP_R38",OBJPROP_STYLE,line_style_of_R);
      ObjectSet("WP_R38",OBJPROP_RAY,false);
      ObjectCreate("WP_R38_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),R38);
      ObjectSetText("WP_R38_label",lableR38,10,"Arial",label_color_R38);

      ObjectCreate("WP_S38",OBJ_HLINE,0,0,S38);
      ObjectSet("WP_S38",OBJPROP_COLOR,chose_color_S38);
      ObjectSet("WP_S38",OBJPROP_WIDTH,width_of_S_line);
      ObjectSet("WP_S38",OBJPROP_STYLE,line_style_of_S);
      ObjectSet("WP_S38",OBJPROP_RAY,false);
      ObjectCreate("WP_S38_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),S38);
      ObjectSetText("WP_S38_label",lableS38,10,"Arial",label_color_S38);

      ObjectCreate("WP_R61",OBJ_HLINE,0,0,R61);
      ObjectSet("WP_R61",OBJPROP_COLOR,chose_color_R61);
      ObjectSet("WP_R61",OBJPROP_WIDTH,width_of_R_line);
      ObjectSet("WP_R61",OBJPROP_STYLE,line_style_of_R);
      ObjectSet("WP_R61",OBJPROP_RAY,false);
      ObjectCreate("WP_R61_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),R61);
      ObjectSetText("WP_R61_label",lableR61,10,"Arial",label_color_R61);

      ObjectCreate("WP_S61",OBJ_HLINE,0,0,S61);
      ObjectSet("WP_S61",OBJPROP_COLOR,chose_color_S61);
      ObjectSet("WP_S61",OBJPROP_WIDTH,width_of_S_line);
      ObjectSet("WP_S61",OBJPROP_STYLE,line_style_of_S);
      ObjectSet("WP_S61",OBJPROP_RAY,false);
      ObjectCreate("WP_S61_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),S61);
      ObjectSetText("WP_S61_label",lableS61,10,"Arial",label_color_S61);

      ObjectCreate("WP_R78",OBJ_HLINE,0,0,R78);
      ObjectSet("WP_R78",OBJPROP_COLOR,chose_color_R78);
      ObjectSet("WP_R78",OBJPROP_WIDTH,width_of_R_line);
      ObjectSet("WP_R78",OBJPROP_STYLE,line_style_of_R);
      ObjectSet("WP_R78",OBJPROP_RAY,false);
      ObjectCreate("WP_R78_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),R78);
      ObjectSetText("WP_R78_label",lableR78,10,"Arial",label_color_R78);

      ObjectCreate("WP_S78",OBJ_HLINE,0,0,S78);
      ObjectSet("WP_S78",OBJPROP_COLOR,chose_color_S78);
      ObjectSet("WP_S78",OBJPROP_WIDTH,width_of_S_line);
      ObjectSet("WP_S78",OBJPROP_STYLE,line_style_of_S);
      ObjectSet("WP_S78",OBJPROP_RAY,false);
      ObjectCreate("WP_S78_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),S78);
      ObjectSetText("WP_S78_label",lableS78,10,"Arial",label_color_S78);

      ObjectCreate("WP_R100",OBJ_HLINE,0,0,R100);
      ObjectSet("WP_R100",OBJPROP_COLOR,chose_color_R100);
      ObjectSet("WP_R100",OBJPROP_WIDTH,width_of_R_line);
      ObjectSet("WP_R100",OBJPROP_STYLE,line_style_of_R);
      ObjectSet("WP_R100",OBJPROP_RAY,false);
      ObjectCreate("WP_R100_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),R100);
      ObjectSetText("WP_R100_label",lableR100,10,"Arial",label_color_R100);

      ObjectCreate("WP_S100",OBJ_HLINE,0,0,S100);
      ObjectSet("WP_S100",OBJPROP_COLOR,chose_color_S100);
      ObjectSet("WP_S100",OBJPROP_WIDTH,width_of_S_line);
      ObjectSet("WP_S100",OBJPROP_STYLE,line_style_of_S);
      ObjectSet("WP_S100",OBJPROP_RAY,false);
      ObjectCreate("WP_S100_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),S100);
      ObjectSetText("WP_S100_label",lableS100,10,"Arial",label_color_S100);

      if(show_200==true)
        {
         ObjectCreate("WP_R200",OBJ_HLINE,0,0,R200);
         ObjectSet("WP_R200",OBJPROP_COLOR,chose_color_R200);
         ObjectSet("WP_R200",OBJPROP_WIDTH,width_of_R_line);
         ObjectSet("WP_R200",OBJPROP_STYLE,line_style_of_R);
         ObjectSet("WP_R200",OBJPROP_RAY,false);
         ObjectCreate("WP_R200_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),R200);
         ObjectSetText("WP_R200_label","R200 ",10,"Arial",label_color_R200);

         ObjectCreate("WP_S200",OBJ_HLINE,0,0,S200);
         ObjectSet("WP_S200",OBJPROP_COLOR,chose_color_S200);
         ObjectSet("WP_S200",OBJPROP_WIDTH,width_of_S_line);
         ObjectSet("WP_S200",OBJPROP_STYLE,line_style_of_S);
         ObjectSet("WP_S200",OBJPROP_RAY,false);
         ObjectCreate("WP_S200_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),S200);
         ObjectSetText("WP_S200_label","S200 ",10,"Arial",label_color_S200);

         ObjectCreate("WP_R138",OBJ_HLINE,0,0,R138);
         ObjectSet("WP_R138",OBJPROP_COLOR,chose_color_R138);
         ObjectSet("WP_R138",OBJPROP_WIDTH,width_of_R_line);
         ObjectSet("WP_R138",OBJPROP_STYLE,line_style_of_R);
         ObjectSet("WP_R138",OBJPROP_RAY,false);
         ObjectCreate("WP_R138_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),R138);
         ObjectSetText("WP_R138_label","R138 ",10,"Arial",label_color_R138);

         ObjectCreate("WP_S138",OBJ_HLINE,0,0,S138);
         ObjectSet("WP_S138",OBJPROP_COLOR,chose_color_S138);
         ObjectSet("WP_S138",OBJPROP_WIDTH,width_of_S_line);
         ObjectSet("WP_S138",OBJPROP_STYLE,line_style_of_S);
         ObjectSet("WP_S138",OBJPROP_RAY,false);
         ObjectCreate("WP_S138_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),S138);
         ObjectSetText("WP_S138_label","S138 ",10,"Arial",label_color_S138);

         ObjectCreate("WP_R161",OBJ_HLINE,0,0,R161);
         ObjectSet("WP_R161",OBJPROP_COLOR,chose_color_R161);
         ObjectSet("WP_R161",OBJPROP_WIDTH,width_of_R_line);
         ObjectSet("WP_R161",OBJPROP_STYLE,line_style_of_R);
         ObjectSet("WP_R161",OBJPROP_RAY,false);
         ObjectCreate("WP_R161_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),R161);
         ObjectSetText("WP_R161_label","R161 ",10,"Arial",label_color_R161);

         ObjectCreate("WP_S161",OBJ_HLINE,0,0,S161);
         ObjectSet("WP_S161",OBJPROP_COLOR,chose_color_S161);
         ObjectSet("WP_S161",OBJPROP_WIDTH,width_of_S_line);
         ObjectSet("WP_S161",OBJPROP_STYLE,line_style_of_S);
         ObjectSet("WP_S161",OBJPROP_RAY,false);
         ObjectCreate("WP_S161_label",OBJ_TEXT,0,Time[0]+Period()*(600+SS),S161);
         ObjectSetText("WP_S161_label","S161 ",10,"Arial",label_color_S161);
        }

     }

//-------------------------------------------------------------------+
   return(0);
  }
//-------------------------------------------------------------------+

//+------------------------------------------------------------------+
int deinit()
  {

//ObjectsDeleteAll();
   ObjectDelete("WP_label");
   ObjectDelete("WP_line");
   ObjectDelete("WP_R38");
   ObjectDelete("WP_R38_label");
   ObjectDelete("WP_S38");
   ObjectDelete("WP_S38_label");
   ObjectDelete("WP_R61");
   ObjectDelete("WP_R61_label");
   ObjectDelete("WP_S61");
   ObjectDelete("WP_S61_label");
   ObjectDelete("WP_R78");
   ObjectDelete("WP_R78_label");
   ObjectDelete("WP_S78");
   ObjectDelete("WP_S78_label");
   ObjectDelete("WP_R100");
   ObjectDelete("WP_R100_label");
   ObjectDelete("WP_S100");
   ObjectDelete("WP_S100_label");
   ObjectDelete("WP_R138");
   ObjectDelete("WP_R138_label");
   ObjectDelete("WP_R161");
   ObjectDelete("WP_R161_label");
   ObjectDelete("WP_S138");
   ObjectDelete("WP_S138_label");
   ObjectDelete("WP_S161");
   ObjectDelete("WP_S161_label");
   ObjectDelete("WP_R200");
   ObjectDelete("WP_R200_label");
   ObjectDelete("WP_S200");
   ObjectDelete("WP_S200_label");
   ObjectDelete("Start");
   ObjectDelete("End");

//-------------------------------------------------------------------+
   return(0);
  }
//-------------------------------------------------------------------+
