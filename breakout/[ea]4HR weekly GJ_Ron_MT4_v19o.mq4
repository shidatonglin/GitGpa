//+-----------+
//|4HR Weekly |
//+-----------+
#property copyright "Ron Thompson"
#property link      "http://www.ForexMT4.com/"

// This EA is NEVER to be SOLD individually 
// This EA is NEVER to be INCLUDED as part of a collection that is SOLD


/*
Calculates the 1st N hours of the week, and 
uses the Hi/Lo + BufferSize+spread to create 
buy and sell points and take profit levels

Place on an H1 GBPJPY chart
*/



// EA SPECIFIC
extern int     MagicNumber   = 538                ;
extern string  TradeComment  = "_4HrWkly_19n.txt" ;

extern string  bd            = "0=Sunday..."      ;
extern int     BrokerDay     =  1                 ;
       int     Bday;
extern int     BrokerHour    =  2                 ;
       int     Bhour;
extern int     HourCount     =  4                 ;
extern int     BufferSize    = 26                 ;
extern string  cd            =  "5=Friday"        ;
extern int     CloseDay      =  5                 ;
extern string  ch            =  "Broker hour"     ;
extern int     CloseHour     = 19                 ;

extern double  Lots          =  0.01              ;
extern double  ProfitX       =  4                 ;
extern double  LossLimitPCT  =  81                ;

extern string  td            = "1=1X 2=2X 3=3X 4=4X 0=ProfitX";
extern int     T1            =  0 ;
extern int     T2            =  0 ;
extern int     T3            =  0 ;
extern int     T4            =  0 ;

extern double  BreakEvenX    =  0                 ;
extern bool    OneProfitTrade=  false             ;

       
// user input
extern int    Slippage            =       2       ;
extern double TrailStop           =       0       ;
extern double TrailStep           =       0       ;
extern bool   TrailAfterProfit    =    true       ;
extern bool   KillLogging         =    true       ;
extern bool   PersistentGraphics  =   false       ;




double  ProfitMade          =       0             ; 
double  LossLimit           =       0             ;

double  WH;          // weekly hi in absolute price 
double  WL;          // weekly lo in absolute price 
double  WW;          // weekly window in integer pips
double  prevPrice;   // used to determine if price
double  currPrice;   // has crossed the buy or sell lines

// Trade control
bool    TradeBUYAllowed=true;
bool    TradeSELLAllowed=true;
double  lotsi;                                // used for Martingale loss recovery
double  myPoint;                              // support for 3/5 decimal places
int     maxloop=25;                           // maximum number of attempts to handle errors

// Bar handling
datetime      bartime=0;                            // used to determine when a bar has moved
int           bartick=0;                            // number of times bars have moved

// Objects
int     uniq=0;
string Object_ID = "WKLY";


// used for verbose error logging
#include <stdlib.mqh>



//+-------------+
//| Custom init |
//|-------------+
// Called ONCE when EA is added to chart or recompiled

int init()
  {
   // get normalized Point based on Broker decimal places
   myPoint = SetPoint();

   if(!PersistentGraphics) myObjectsDeleteAll();

   // adjust for midnight crossing, if any
   Bhour = BrokerHour+HourCount;
   Bday = BrokerDay;

   if(Bhour>23) 
     {
      Bhour=Bhour-24;
      Bday=BrokerDay+1;
     }
   
   CalcWindow();
   prevPrice=Close[0];
   currPrice=Close[0];

   logwrite(TradeComment,"Init Complete");

  }


//+----------------+
//| Custom DE-init |
//+----------------+
// Called ONCE when EA is removed from chart

int deinit()
  {
   if(!PersistentGraphics) myObjectsDeleteAll();

   logwrite(TradeComment,"DE-Init Complete");
   Comment(" ");
  }


//+-----------+
//| Main      |
//+-----------+
// Called EACH TICK and each Bar[]

int start()
  {

   if(IsTesting() && TrailStep>TrailStop) return(0);


   //procedures use lotsi, so keep it 
   //tracked with Lots
   lotsi=Lots;

   int      cnt=0;
   int      OrdersPerSymbol=0;

   double CurrentProfit=0;
     
   // EA specific
   datetime   t;
   bool       boxtime=false;



   OrdersPerSymbol=0;
   for(cnt=OrdersTotal();cnt>=0;cnt--)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if( OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) OrdersPerSymbol++;
     }

   // if close time, close everything
   t=iTime(Symbol(),0,0);
   if( TimeDayOfWeek(t)==CloseDay && TimeHour(t)==CloseHour && OrdersPerSymbol>0 )
     {
      CloseEverything();
     }



   // bar counting
   if(bartime!=iTime(Symbol(), 0, 0) ) 
     {
      bartime=iTime(Symbol(), 0, 0) ;
      bartick++; 


      if(!PersistentGraphics) myObjectsDeleteAll();
      CalcWindow();

      Print("OnNewBar  WH="+WH+" WL="+WL);
      if(Close[0]<WH && Close[0]>WL)       Print("Price inside limits - no order");

     }


   // no trading while box is forming
   t=iTime(Symbol(),0,0);

   // box does NOT cross midnight
   if( BrokerHour<Bhour)
     {
      if( TimeDayOfWeek(t)==BrokerDay && TimeHour(t)>=BrokerHour && TimeHour(t)< Bhour )
        {
            boxtime=true;
         
            //it is a new box, so allow new trades
            TradeBUYAllowed=true;
            TradeSELLAllowed=true;
        }
     }

   // box CROSSES midnight
   if( BrokerHour>Bhour)
     {
      if( (TimeDayOfWeek(t)==BrokerDay && TimeHour(t)>=BrokerHour) || (TimeDayOfWeek(t)==Bday && TimeHour(t)< Bhour)  )
        {
         boxtime=true;
   
         //it is a new box, so allow new trades
         TradeBUYAllowed=true;
         TradeSELLAllowed=true;
        }
     }


   //save previous tick
   prevPrice=currPrice;
   currPrice=Close[0];
   
   if( prevPrice< WH && currPrice>=WH ) Print("Price crossed up thru WH");
   if( prevPrice> WH && currPrice<=WH ) Print("Price crossed down thru WH");

   if( prevPrice> WL && currPrice<=WL ) Print("Price crossed down thru WL");
   if( prevPrice< WL && currPrice>=WL ) Print("Price crossed up thru WL");



   if(TradeBUYAllowed && prevPrice<=WH && currPrice>=WH && OrdersPerSymbol==0 && !boxtime)
     {
      Print("-----Preparing to BUY");
      if(LossLimitPCT==0) LossLimit=WW; else LossLimit=WW*(LossLimitPCT/100);

      if(T1>0) {ProfitMade=WW*T1; OpenBuy();}  else  {ProfitMade=WW*ProfitX; OpenBuy();}
      if(T2>0) {ProfitMade=WW*T2; OpenBuy();}  else  {ProfitMade=WW*ProfitX; OpenBuy();}
      if(T3>0) {ProfitMade=WW*T3; OpenBuy();}  else  {ProfitMade=WW*ProfitX; OpenBuy();}
      if(T4>0) {ProfitMade=WW*T4; OpenBuy();}  else  {ProfitMade=WW*ProfitX; OpenBuy();}

      TradeBUYAllowed=false;
     }
     
   if(TradeSELLAllowed && prevPrice>=WL && currPrice<=WL && OrdersPerSymbol==0 && !boxtime)
     {
      Print("-----Preparing to SELL");
      if(LossLimitPCT==0) LossLimit=WW; else LossLimit=WW*(LossLimitPCT/100);

      if(T1>0) {ProfitMade=WW*T1; OpenSell();}  else  {ProfitMade=WW*ProfitX; OpenSell();}
      if(T2>0) {ProfitMade=WW*T2; OpenSell();}  else  {ProfitMade=WW*ProfitX; OpenSell();}
      if(T3>0) {ProfitMade=WW*T3; OpenSell();}  else  {ProfitMade=WW*ProfitX; OpenSell();}
      if(T4>0) {ProfitMade=WW*T4; OpenSell();}  else  {ProfitMade=WW*ProfitX; OpenSell();}

      TradeSELLAllowed=false;
     }
   



   //
   // Order Management
   //


   for(cnt=OrdersTotal();cnt>=0;cnt--)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if( OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber )
        {
        
         if(OrderType()==OP_BUY)
           {
            CurrentProfit=(Bid-OrderOpenPrice()) ;

            // check for break even
            if( BreakEvenX>0 )                                                 CheckBuyBreakEven(CurrentProfit);

            // check for trail before any profit
            if( TrailStop>0 && !TrailAfterProfit)                              CheckBuyTrailingStop();
            // check for trail after 'trail' pips of profit
            if( TrailStop>0 &&  TrailAfterProfit 
               && Close[0]>OrderOpenPrice()+(TrailStop*myPoint) )              CheckBuyTrailingStop();
             
            // check for profit
            if(ProfitMade>0 && CurrentProfit>=(ProfitMade*myPoint))            CloseBuy(OrderLots(), "PROFIT");
              
            // check for loss
            if(LossLimit>0 && CurrentProfit<=(LossLimit*(-1)*myPoint))         CloseBuy(OrderLots(), "LOSS");
              
           } // if BUY


         if(OrderType()==OP_SELL)
           {
            CurrentProfit=(OrderOpenPrice()-Ask);

            // check for break even
            if( BreakEvenX>0 )                                                 CheckSellBreakEven(CurrentProfit);
           
            // check for trail before any profit
            if( TrailStop>0 && !TrailAfterProfit)                              CheckSellTrailingStop();
            // check for trail after 'trail' pips of profit
            if( TrailStop>0 &&  TrailAfterProfit 
               && Close[0]<OrderOpenPrice()-(TrailStop*myPoint) )              CheckSellTrailingStop();


            // check for profit
            if( ProfitMade>0 && CurrentProfit>=(ProfitMade*myPoint) )          CloseSell(OrderLots(), "PROFIT");

            // check for loss
            if( LossLimit>0 && CurrentProfit<=(LossLimit*(-1)*myPoint) )       CloseSell(OrderLots(), "LOSS");
           } //if SELL
           

        } // if(OrderSymbol&&MagicNumber)
        

     } // for


  } // start()


//+-----------------+
//| CloseEverything |
//+-----------------+
// Closes all OPEN and PENDING orders

int CloseEverything()
  {
   int i;
    
   for(i=OrdersTotal();i>=0;i--)
     {

      OrderSelect(i, SELECT_BY_POS);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         if(OrderType()==OP_BUY)       CloseBuy (OrderLots(), "CloseEverything");
         if(OrderType()==OP_SELL)      CloseSell(OrderLots(), "CloseEverything");
         if(OrderType()==OP_BUYLIMIT)  OrderDelete( OrderTicket() );
         if(OrderType()==OP_SELLLIMIT) OrderDelete( OrderTicket() );
         if(OrderType()==OP_BUYSTOP)   OrderDelete( OrderTicket() );
         if(OrderType()==OP_SELLSTOP)  OrderDelete( OrderTicket() );
        }

      Sleep(1000);

     } //for
  
  } // closeeverything



// log data to a file name passed in
// print everything regardless of log setting
void logwrite (string filename, string mydata)
  {
   int myhandle;
   string gregorian=TimeToStr(CurTime(),TIME_DATE|TIME_SECONDS);

   Print(mydata+" "+gregorian);
   
   // don't log anything if testing or if user doesn't want it
   if(IsTesting()) return(0);
   if(KillLogging) return(0);

   myhandle=FileOpen(Symbol()+"_"+filename, FILE_CSV|FILE_WRITE|FILE_READ, ";");
   if(myhandle>0)
     {
      FileSeek(myhandle,0,SEEK_END);
      FileWrite(myhandle, mydata+" "+gregorian);
      FileClose(myhandle);
     }
  } 



//ENTRY LONG (buy, Ask) 
void OpenBuy()
     {
      int      gle=0;
      int      ticket=0;
      
      double SL=0;
      double TP=0;
      int loopcount;

      // PLACE order is independent of MODIFY order. 
      // This is mandatory for ECNs and acceptable for retail brokers

      loopcount=0;
      while(true)          
        {
         // place order - NO TP OR SL
         ticket=OrderSend(Symbol(),OP_BUY,lotsi,Ask,Slippage,0,0,TradeComment,MagicNumber,White);
         gle=GetLastError();
         if(gle==0)
           {
            logwrite(TradeComment,"BUY PLACED Ticket="+ticket+" Ask="+Ask+" Lots="+lotsi);
            break;
           }
          else 
           {
            logwrite(TradeComment,"-----ERROR-----  Placing BUY order: Lots="+lotsi+" Bid="+Bid+" Ask="+Ask+" ticket="+ticket+" Err="+gle+" "+ErrorDescription(gle)); 
            
            RefreshRates();
            Sleep(500);

            // give up after loopcount tries
            loopcount++;
            if(loopcount>maxloop)
              {
               logwrite(TradeComment,"-----ERROR-----  Giving up on placing BUY order"); 
               return(gle);
              }
           }
        }//while - place order 


      // modify the order for users TP & SL
      loopcount=0;
      while(true)
        {
         // don't set TP and SL both to zero, they're already there
         if(LossLimit==0 && ProfitMade==0) break;
         
         if(LossLimit  ==0) SL=0;
         if(ProfitMade ==0) TP=0;
         if(LossLimit   >0) SL=Ask-((LossLimit)*myPoint );
         if(ProfitMade  >0) TP=Ask+((ProfitMade)*myPoint );
         OrderModify(ticket,OrderOpenPrice(),SL,TP,0,White);
         gle=GetLastError();
         if(gle==0)
           {
            logwrite(TradeComment,"BUY MODIFIED Ticket="+ticket+" Ask="+Ask+" Lots="+lotsi+" SL="+SL+" TP="+TP);
            break;
           }
          else 
           {
            logwrite(TradeComment,"-----ERROR-----  Modifying BUY order: Lots="+lotsi+" SL="+SL+" TP="+TP+" Bid="+Bid+" Ask="+Ask+" ticket="+ticket+" Err="+gle+" "+ErrorDescription(gle)); 
            
            RefreshRates();
            Sleep(500);

            loopcount++;
            if(loopcount>maxloop)
              {
               logwrite(TradeComment,"-----ERROR-----  Giving up on modifying BUY order"); 
               return(gle);
              }
           }
        }//while - modify order
        
        
     }//BUYme



   //ENTRY SHORT (sell, Bid)
void OpenSell()
     {
      int      gle=0;
      int      ticket=0;
      
      double SL=0;
      double TP=0;
      int loopcount;

      // PLACE order is independent of MODIFY order. 
      // This is mandatory for ECNs and acceptable for retail brokers

      loopcount=0;
      while(true)
        {
         ticket=OrderSend(Symbol(),OP_SELL,lotsi,Bid,Slippage,0,0,TradeComment,MagicNumber,Red);
         gle=GetLastError();
         if(gle==0)
           {
            logwrite(TradeComment,"SELL PLACED Ticket="+ticket+" Bid="+Bid+" Lots="+lotsi);
            break;
           }
            else 
           {
            logwrite(TradeComment,"-----ERROR-----  placing SELL order: Lots="+lotsi+" SL="+SL+" TP="+TP+" Bid="+Bid+" Ask="+Ask+" ticket="+ticket+" Err="+gle+" "+ErrorDescription(gle)); 
                            
            RefreshRates();
            Sleep(500);

            loopcount++;
            if(loopcount>maxloop)
              {
               logwrite(TradeComment,"-----ERROR-----  Giving up on placing SELL order"); 
               return(gle);
              }
           }
        }//while

      
      // modify the order for users TP & SL
      loopcount=0;
      while(true)
        {
         // don't set TP and SL both to zero, they're already there
         if(LossLimit==0 && ProfitMade==0) break;
         
         if(LossLimit  ==0) SL=0;
         if(ProfitMade ==0) TP=0;
         if(LossLimit   >0) SL=Bid+((LossLimit)*myPoint );
         if(ProfitMade  >0) TP=Bid-((ProfitMade)*myPoint );
         OrderModify(ticket,OrderOpenPrice(),SL,TP,0,Red);
         gle=GetLastError();
         if(gle==0)
           {
            logwrite(TradeComment,"SELL MODIFIED Ticket="+ticket+" Bid="+Bid+" Lots="+lotsi+" SL="+SL+" TP="+TP);
            break;
           }
            else 
           {
            logwrite(TradeComment,"-----ERROR-----  modifying SELL order: Lots="+lotsi+" SL="+SL+" TP="+TP+" Bid="+Bid+" Ask="+Ask+" ticket="+ticket+" Err="+gle+" "+ErrorDescription(gle)); 
                            
            RefreshRates();
            Sleep(500);

            loopcount++;
            if(loopcount>maxloop)
              {
               logwrite(TradeComment,"-----ERROR-----  Giving up on placing SELL order"); 
               return(gle);
              }
           }

        }//while

     }//SELLme



void CloseBuy (double myLots, string myInfo)
  {
   int gle;
   int cnt;
   int OrdersPerSymbol;

   int loopcount=0;
   
   string bTK=" Ticket="+OrderTicket();
   string bSL=" SL="+OrderStopLoss();
   string bTP=" TP="+OrderTakeProfit();
   string bPM;
   string bLL;
   string bER;

   bPM=" PM="+ProfitMade;
   bLL=" LL="+LossLimit;

   if(OneProfitTrade && myInfo=="PROFIT")
     {
      TradeBUYAllowed=false;
      TradeSELLAllowed=false;
     }

   while(true)
     {
      OrderClose(OrderTicket(),myLots,Bid,Slippage,White);
      gle=GetLastError();
      bER=" error="+gle+" "+ErrorDescription(gle);

      if(gle==0)
        {
         logwrite(TradeComment,"CLOSE BUY "+myInfo+ bTK + bSL + bTP + bPM + bLL);
         break;
        }
       else 
        {
         logwrite(TradeComment,"-----ERROR----- CLOSE BUY "+myInfo+ bER +" Bid="+Bid+ bTK + bSL + bTP + bPM + bLL);
         RefreshRates();
         Sleep(500);
        }


      loopcount++;
      if(loopcount>maxloop)
        {
         logwrite(TradeComment,"-----ERROR-----  Giving up on closing SELL order"); 
         return(gle);
        }
                     
     }//while
  
  }


void CloseSell (double myLots, string myInfo)
  {
   int gle;
   int cnt;
   int OrdersPerSymbol;

   int loopcount=0;

   string sTK=" Ticket="+OrderTicket();
   string sSL=" SL="+OrderStopLoss();
   string sTP=" TP="+OrderTakeProfit();
   string sPM;
   string sLL;
   string sER;
      
   sPM=" PM="+ProfitMade;
   sLL=" LL="+LossLimit;

   if(OneProfitTrade && myInfo=="PROFIT")
     {
      TradeBUYAllowed=false;
      TradeSELLAllowed=false;
     }

   while(true)
     {
      OrderClose(OrderTicket(),myLots,Ask,Slippage,Red);
      gle=GetLastError();
      sER=" error="+gle+" "+ErrorDescription(gle);
      
      if(gle==0)
        {
         logwrite(TradeComment,"CLOSE SELL "+myInfo + sTK + sSL + sTP + sPM + sLL);
         break;
        }
      else 
        {
         logwrite(TradeComment,"-----ERROR----- CLOSE SELL "+myInfo+ sER +" Ask="+Ask+ sTK + sSL + sTP + sPM + sLL);
         RefreshRates();
         Sleep(500);
        }

      loopcount++;
      if(loopcount>maxloop)
        {
         logwrite(TradeComment,"-----ERROR-----  Giving up on closing SELL order"); 
         return(gle);
        }
                 
     }//while                 
  }      



//pass CurrProfit as pips
void CheckBuyBreakEven(double CurrProfit) 
  {
   double SL;  //stoploss
   double TP;  //takeprofit
   
   int  gle;   // getlasterror number

   // This event sets OrderStopLoss equal to OrderOpenPrice (plus spread)
   // thus it will only ever get executed one time per ticket

   if (CurrProfit >= ((BreakEvenX*WW)*myPoint) && OrderOpenPrice()>OrderStopLoss())
     {
      SL=OrderOpenPrice()+(Ask-Bid);
      TP=OrderTakeProfit();
      OrderModify(OrderTicket(),OrderOpenPrice(),SL,TP, White);
      gle=GetLastError();
      if(gle==0)
        {
         logwrite(TradeComment,"MODIFY BUY BE Ticket="+OrderTicket()+" SL="+SL+" TP="+TP);
        }
       else 
        {
         logwrite(TradeComment,"-----ERROR----- MODIFY BUY  BE Bid="+Bid+" error="+gle+" "+ErrorDescription(gle));
        }

     }

  }  //CheckBreakEven



void CheckSellBreakEven(double CurrProfit) 
  {
   double SL;  //stoploss
   double TP;  //takeprofit
   
   int  gle;   // getlasterror number

   // This event sets OrderStopLoss equal to OrderOpenPrice (plus spread)
   // thus it will only ever get executed one time per ticket

   if (CurrProfit >= ((BreakEvenX*WW)*myPoint) && OrderOpenPrice()<OrderStopLoss())
     {
      SL=OrderOpenPrice()-(Ask-Bid);
      TP=OrderTakeProfit();
      OrderModify(OrderTicket(),OrderOpenPrice(),SL,TP, Red);
      gle=GetLastError();
      if(gle==0)
        {
         logwrite(TradeComment,"MODIFY SELL BE Ticket="+OrderTicket()+" SL="+SL+" TP="+TP);
        }
       else 
        {
         logwrite(TradeComment,"-----ERROR----- MODIFY SELL BE Ask="+Ask+" error="+gle+" "+ErrorDescription(gle));
        }

     }

  }//checksellbreakevn




void CheckBuyTrailingStop()
  {
   double SL;  //stoploss
   double TP;  //takeprofit
   
   int  gle;   // getlasterror number

   // check for trailing stop
   if( OrderStopLoss()==0 || OrderStopLoss() < Bid-(TrailStop*myPoint) )
     {
      SL=Bid-(TrailStop-TrailStep)*myPoint;
      TP=OrderTakeProfit();
      OrderModify(OrderTicket(),OrderOpenPrice(),SL,TP,0,White);
      gle=GetLastError();
      if(gle==0)
        {
         logwrite(TradeComment,"MODIFY BUY TS Ticket="+OrderTicket()+" SL="+SL+" TP="+TP);
        }
       else 
        {
         logwrite(TradeComment,"-----ERROR----- MODIFY BUY TS Bid="+Bid+" error="+gle+" "+ErrorDescription(gle)+" ");
        }

     }

  }//CheckBuyTrailingStop



void CheckSellTrailingStop()
  {
   double SL;  //stoploss
   double TP;  //takeprofit
   
   int  gle;   // getlasterror number

   // check for trailing stop
   if( OrderStopLoss()==0 || OrderStopLoss() > Ask+(TrailStop*myPoint) )
     {
      SL=Ask+(TrailStop-TrailStep)*myPoint;
      TP=OrderTakeProfit();
      OrderModify(OrderTicket(),OrderOpenPrice(),SL,TP,0,Red);
      gle=GetLastError();
      if(gle==0)
        {
         logwrite(TradeComment,"MODIFY SELL TS Ticket="+OrderTicket()+" SL="+SL+" TP="+TP);
        }
       else 
        {
         logwrite(TradeComment,"-----ERROR----- MODIFY SELL TS Ask="+Ask+" error="+gle+" "+ErrorDescription(gle));
        }

     }

  }//checkselltrailingstop





// Function to correct the value of Point
// for brokers that add an extra digit to price
// Courtesy of Robert Hill

double SetPoint()
{
   double mPoint;
  
   if (Digits < 4)
     {
      mPoint = 0.01;
     }
   else
     {
      mPoint = 0.0001;
     }
  
   return(mPoint);
}






void myObjectsDeleteAll()
  {
   int      i;
   int      j;
   string obj;
      
   // there are 23 different object types 
   for (j = 23; j >= 0; j--)
     {
      for (i = ObjectsTotal(j); i >= 0;i--)
        {
         obj=ObjectName(i);
         if (StringFind(obj ,Object_ID, 0) >= 0) ObjectDelete( obj );
        }
     } 
   uniq=0;
  }


void DrawLine(datetime x1, datetime x2, double y1, double y2, color lineColor, double style)
  {
   string lbl=Object_ID + "_" + uniq;
   uniq++;

   ObjectDelete(lbl);
   ObjectCreate(lbl, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
   ObjectSet(lbl, OBJPROP_RAY, 0);
   ObjectSet(lbl, OBJPROP_COLOR, lineColor);
   ObjectSet(lbl, OBJPROP_STYLE, style);
   ObjectSet(lbl, OBJPROP_WIDTH, 1);
  }


void DrawRisk( datetime x1, double y1, double risk )
  {
   string lbl=Object_ID + "_" + uniq;
   uniq++;

   ObjectCreate (lbl, OBJ_TEXT, 0, x1, y1 );
   ObjectSetText(lbl, DoubleToStr(risk, 0),16,"Arial",Aqua);
  }


void CalcWindow()
  {

   datetime t;
   datetime b;
   int i;   

   int weekbar;

   int hh;
   int ll;
   

   // look back until you find day & hour 
   for(i=0; i<=200; i++)
     {
      // this is the bar at the END of the hi/lo area 
      t=iTime(Symbol(),0,i);
      if( TimeHour(t)==Bhour && TimeDayOfWeek(t)==Bday )
        {
         // + 1 BAR not 1 hour - different direction
         weekbar=i+1;
         Print("WeekBar="+weekbar);
         break;
        }
     }         

   hh=iHighest(Symbol(),0,MODE_HIGH,HourCount,weekbar);
   WH=iHigh(Symbol(),0, hh )+(BufferSize*myPoint)+(Ask-Bid);

   ll=iLowest(Symbol(),0,MODE_LOW, HourCount,weekbar);
   WL= iLow(Symbol(),0, ll )-(BufferSize*myPoint)-(Ask-Bid);

   WW=(WH-WL)/myPoint;
   
   t=iTime(Symbol(),0,weekbar);
   b=iTime(Symbol(),0,weekbar+HourCount-1);
   
   //draw the current box
   DrawLine( b,  t, WH, WH, Aqua, STYLE_SOLID );
   DrawLine( b,  t, WL, WL, Aqua, STYLE_SOLID );
   DrawLine( b,  b, WH, WL, Aqua, STYLE_SOLID );
   DrawLine( t,  t, WH, WL, Aqua, STYLE_SOLID );
   
   //draw the current hi/low
   DrawLine( t, iTime(Symbol(),0,0), WH, WH, White, STYLE_SOLID );
   DrawLine( t, iTime(Symbol(),0,0), WL, WL,   Red, STYLE_SOLID );
   
   // draw the window width
   DrawRisk( t, WL+((WH-WL)/2), (WH-WL)/myPoint   ) ;

  }