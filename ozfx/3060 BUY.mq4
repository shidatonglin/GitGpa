//+------------------------------------------------------------------+
//|                                                      ttb BUY.mq4 |
//|                                                        iamgotzaa |
//|                                         http://www.iamgotzaa.net |
//+------------------------------------------------------------------+
#property copyright "iamgotzaa"
#property link      "ttp://www.iamgotzaa.net"

static bool Buy=true;
static bool Sell=false;

extern double lot=0.1;
extern int TakeProfit=10;
extern int StopLoss=500;
extern int Step=10;
extern int StressOutPipOffset=10;
extern double x=1.44;
int magic;


bool stressmode;
int M=0,lastM=0;  //Martingale Step

double NextPrice=0, thisPrice=0;
double thisLot=0;
double thisTakeProfit,NewTakeProfit,thisStopLoss;
double thisDD,thisDDP,maxDD,maxDDP,balance;

int ticket,trailingCount,HeadCount;

bool HaveHead;
double HeadPrice;

bool ModDone=true,NewOrderDone=true;
int ticketseries[30];
//[0] contain total ticket number in the array
//[1]..[29]contain ticket number 
double PxL[3];
//[0] average price to breakeven
//[1] sum lot
//[2] sum price x lot

int orderDecimal;



string botcomment;
static int objnamecounter;
static int message_age;
static string obj[10];

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   if(Buy)  botcomment="Buy Bot-";
   if(Sell)  botcomment="Sell Bot-";
   HaveHead=false;
   stressmode=true;
   if(Buy)  magic=11111;
   if(Sell) magic=22222;
   //ModDone=true;
   //NewOrderDone=true;
   //trailingCount=0;
   balance=AccountBalance();
   //orderDecimal=MarketInfo(Symbol(),MODE_LOTSTEP);
   if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.01)   orderDecimal=2;
   if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.1)   orderDecimal=1;
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
     static_info();
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
      if(!HaveHead)
      {
         inform(1);
         if(Buy) NextPrice=Ask;
         if(Sell) NextPrice=Bid;
         M=0;
         ArrayInitialize(ticketseries,0);
         ArrayInitialize(PxL,0);
         thisTakeProfit=0;
         thisPrice=0;
         trailingCount=0;
      }
     static_info();
     RecordDrawnDown();
     account_info();
      thisLot=callotsize(M);
     trade(condition());
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

void trade(int cond)
{
     switch (cond)
     {
          case 0: PlaySound("tick.wav");     break;
          
          //..no order.. then open order just one
          case 10:
          {
               M=0;

               ArrayInitialize(ticketseries,0);
               ArrayInitialize(PxL,0);
               thisTakeProfit=0;
               thisPrice=0;
               trailingCount=0;
               HeadPrice=0;
               double tp,sl;
               string _comment;
               //HaveHead=false;
               _comment=botcomment+M;
               //what price to buy?
               //and spread is Low
               RefreshRates();
               
               if(Buy)
               {
                    tp=NormalizeDouble(Bid+TakeProfit*10*Point,5);
                    sl=NormalizeDouble(Bid-StopLoss*10*Point,5);
                    ticket=OrderSend(Symbol(),OP_BUY,lot,Ask,2,sl,tp,"HeadB",magic,0,White);
               }
               if(Sell)
               {
                    tp=NormalizeDouble(Ask-TakeProfit*10*Point,5);
                    sl=NormalizeDouble(Ask+StopLoss*10*Point,5);
                    ticket=OrderSend(Symbol(),OP_SELL,lot,Bid,2,sl,tp,"HeadS",magic,0,White);
               }
               
               Sleep(150);    //give some time for server
               
               if(ticket>0)
               {
                    ticketseries[0]++;
                    ticketseries[ticketseries[0]]=ticket;
                     
                    OrderSelect(ticket,SELECT_BY_TICKET);
                    thisPrice=OrderOpenPrice();
                    HeadPrice=OrderOpenPrice();
                    inform(10,thisPrice,lot);
                    //set next price 
                    if(Buy)   NextPrice=thisPrice-Step*10*Point;
                    if(Sell)   NextPrice=thisPrice+Step*10*Point;
                    
                    //set next lot
                    
                    
                    //show this take profit level
                    thisTakeProfit=tp;
                    
                    //flag new series on
                    HaveHead=true;     //flagship
                    HeadCount++;
                    
                    //adding level
                    M++;
                    
                    
                    
                    
               }
               
               //static_info();
               break;
          }
          //counter-following order is here
          case 22:
          {
               double tp2,sl2,_lot2;
               string _comment2;
               
               _comment2=botcomment+M;
               
               //calculate lot size
               
               
               RefreshRates();

               if(Buy)
               {
                    tp2=NormalizeDouble(Bid+TakeProfit*10*Point,5);
                    sl2=NormalizeDouble(Bid-StopLoss*10*Point,5);
                    ticket=OrderSend(Symbol(),OP_BUY,thisLot,Ask,2,sl2,tp2,_comment2,magic,0,Tomato);
               }
               if(Sell)
               {
                    tp2=NormalizeDouble(Ask-TakeProfit*10*Point,5);
                    sl2=NormalizeDouble(Ask+StopLoss*10*Point,5);
                    ticket=OrderSend(Symbol(),OP_SELL,thisLot,Bid,2,sl2,tp2,_comment2,magic,0,Tomato);
               }
               
               Sleep(150);    //give some time for server
               if(ticket>0)
               {
                    ticketseries[0]++;
                    ticketseries[ticketseries[0]]=ticket;
                     
                    OrderSelect(ticket,SELECT_BY_TICKET);
                    thisPrice=OrderOpenPrice();
                    
                    inform(22,thisPrice,OrderLots(),OrderTicket());
                    //set next price 
                    if(Buy)   NextPrice=thisPrice-Step*10*Point;
                    if(Sell)   NextPrice=thisPrice+Step*10*Point;
                    
                    //set next lot
                    
                    
                    //show this take profit level
                    thisTakeProfit=tp2;
                    
                    //flag up New Order Already Opened
                    NewOrderDone=true;
                    
                    //adding level
                    M++;
               }
               
               //zero-ize the array 
               ArrayInitialize(PxL,0);
               //revise total order for single take profit
               for(int j=1;j<=ticketseries[0];j++)
               {
                  OrderSelect(ticketseries[j],SELECT_BY_TICKET);
                  PxL[1]=PxL[1]+OrderLots();
                  PxL[2]=PxL[2]+(OrderOpenPrice()*OrderLots());
                  PxL[0]=NormalizeDouble((PxL[2]/PxL[1]),5);
               }
               
               //set new take profit for all
               if(Buy)  NewTakeProfit=NormalizeDouble((PxL[0]+TakeProfit*10*Point),5);
               if(Sell) NewTakeProfit=NormalizeDouble((PxL[0]-TakeProfit*10*Point),5);
               thisTakeProfit=NewTakeProfit;
               //and modify
               for(int k=1;k<=ticketseries[0];k++)
               {
                  bool modok22;
                  
                  OrderSelect(ticketseries[k],SELECT_BY_TICKET);
                  modok22=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NewTakeProfit,0,Green);
                  
                  
                  Sleep(150); //give time for server to response
                  if(modok22)
                  {
                     inform(23,thisTakeProfit,0,ticketseries[k]);
                  }   
               }               
               trailingCount=0;
               ModDone=true;
               stressmode=true;
          }
          
          
          case 21:   //trailing take profit
          {
               //static_info();
               //set new TP
               if(Buy)  thisTakeProfit=NormalizeDouble(thisTakeProfit+TakeProfit*10*Point,5);
               if(Sell)  thisTakeProfit=NormalizeDouble(thisTakeProfit-TakeProfit*10*Point,5);
               
               //modify order TP
               
               
               for(int i=1;i<=ticketseries[0];i++)
               {
                  bool modok21;
                  
                  OrderSelect(ticketseries[i],SELECT_BY_TICKET);
                  modok21=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),thisTakeProfit,0,Green);
                  Sleep(150);      //give time for server to response
                  if(modok21)
                  {
                     inform(21,thisTakeProfit,0,ticketseries[i]);
                  }   
               }
               trailingCount++;
               ModDone=true;
               
               break;
      
          }
          
          //after second traling TP
          //raise SL to lock profit.
          case 40:
          {
               if(Buy)  thisStopLoss=NormalizeDouble(HeadPrice+TakeProfit*10*Point,5);
               if(Sell)  thisStopLoss=NormalizeDouble(HeadPrice-TakeProfit*10*Point,5);
               //modify order TP
               for(int i40=1;i40<=ticketseries[0];i40++)
               {
                  bool modok40_1;
                  
                  OrderSelect(ticketseries[i40],SELECT_BY_TICKET);
                  modok40_1=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),thisTakeProfit,0,Green);
                  Sleep(150);
                  if(modok40_1)
                  {
                     inform(21,thisTakeProfit,0,ticketseries[i40]);
                  }   
               }               
               //ModDone=true;
               //modify order SL
               for(int j40=1;j40<=ticketseries[0];j40++)
               {
                  bool modok40_2;
                  
                  OrderSelect(ticketseries[j40],SELECT_BY_TICKET);
                  modok40_2=OrderModify(OrderTicket(),OrderOpenPrice(),thisStopLoss,OrderTakeProfit(),0,Green);
                  Sleep(150);
                  if(modok40_2)
                  {
                     inform(40,thisStopLoss,0,ticketseries[j40]);
                  }   
               }
               trailingCount++;
               
               ModDone=true;
               break;          
          }// end case 40
          case 99:
          {
               Sleep(360000);
               CloseAllThese();
               ModDone=false;
               //if(Buy)   NextPrice=Ask;
               //if(Sell)   NextPrice=Bid;
               break;
          } 
     }//end switch
}

int condition()
{
     int retval;
     bool check;
     
     check=IsThereFirstEAOrder();
     //0 do nothing Ask does not low enough to open next step
     //if(Ask>=NextPrice && check)    retval=0;
     
     
     //10 no order from this EA; reset everything
     if(!check)
     {
         //reset flag no series right now
         
         retval=10;
     }
     else
     {
         if(HaveHead)
         {

             retval=20;
             //inform(20);
             //21 trailing TP
             //22 open next order 
             //29 trailing SL
             double gaptrialTP;
             double enoughPip;
             
             if(Buy)     gaptrialTP=NormalizeDouble((thisTakeProfit-Bid)*10000,0);  
             if(Sell)     gaptrialTP=NormalizeDouble((Ask-thisTakeProfit)*10000,0);  
             //gap_step=NormalizeDouble((thisPrice-Ask)*10000,0);
    
             //trailing TP

               if(gaptrialTP<=3)
                 {
                    //inform(21);
                    if(ModDone)
                    {
                        Print("trailing TP Gap:"+DoubleToStr(gaptrialTP,0)+"<=3");
                    }   
                    retval=21;
                    ModDone=false;

                 }
                 else retval=20;          

/*
              if(Buy)    enoughPip=NormalizeDouble((Bid-HeadPrice)*10000,0);
              if(Sell)    enoughPip=NormalizeDouble((HeadPrice-Ask)*10000,0);
             //40 trailing TP and raise SL higher
             if(enoughPip>(TakeProfit/2))
               {
                    if(ModDone)
                    {
                        Print("trailing TP 3rd-Gap:"+DoubleToStr(gaptrialTP,0)+"<=3");
                    }
                  retval=40;
                  ModDone=false;
               }else retval=20; 
*/          
            if(Buy)
            {
               //..level is too high
               //too much to fall
               
               if(M>7 && stressmode==true)
               {
                    NextPrice=NextPrice-0.0030;
                    stressmode=false;
               }
                              
               //if(M>6)   return(99);
               if(Ask<NextPrice)
               {
                  //inform(22);
                  retval=22;
                  
                  //NewOrderDone=false;
               }else retval=20;
            }
            if(Sell)
            {
               
               if(M>7 && stressmode==true)
               {
                    NextPrice=NextPrice+0.0030;
                    stressmode=false;
               }
               
               //if(M>6)   return(99);
               if(Bid>NextPrice)
               {
                  //inform(22);
                  retval=22;
                  
                  //NewOrderDone=false;
               }else retval=20;
            }
         }//end have Head order
     }//end else 
     
     //30 trailing TP UP
     //gap=NormalizeDouble((thisTakeProfit-Bid)*10000,0);
     //if(gap<=3 && check)   retval=30;     
     
     //40 modify TP if there are two more open positions
     return(retval);
}


//true if there EA order 
bool IsThereFirstEAOrder()
{
   bool check; 
   for(int i=0;i<OrdersTotal();i++)
   {
      //Try to find "Head" Order 
      OrderSelect(i,SELECT_BY_POS);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
      {
         //found Head-Order
         if(Buy)
         {
               if(OrderComment()=="HeadB"){ check=true; break;}
               // does not found Head-Order; means Head already closed then reset Martingale Level (M)
               else{ check=false; M=0; }
         }
         if(Sell)
         {
               if(OrderComment()=="HeadS"){ check=true; break;}
               // does not found Head-Order; means Head already closed then reset Martingale Level (M)
               else{ check=false; M=0; }
         }         
         
      }
      
   }
     return(check);     
}

void static_info()
{
     ObjectCreate ("info1", OBJ_LABEL, 0, 0, 0);
     ObjectSetText("info1", "lot="+DoubleToStr(lot,2)+" step="+Step+" x="+DoubleToStr(x,2), 8, "Courier New", White);
     ObjectSet    ("info1", OBJPROP_CORNER, 1);
     ObjectSet    ("info1", OBJPROP_XDISTANCE, 10);
     ObjectSet    ("info1", OBJPROP_YDISTANCE, 20);
     
     ObjectCreate ("info2", OBJ_LABEL, 0, 0, 0);
     ObjectSetText("info2", "TakeProfit="+TakeProfit+" StopLoss="+StopLoss, 8, "Courier New", White);
     ObjectSet    ("info2", OBJPROP_CORNER, 1);
     ObjectSet    ("info2", OBJPROP_XDISTANCE, 10);
     ObjectSet    ("info2", OBJPROP_YDISTANCE, 30);
     
     ObjectCreate ("info3", OBJ_LABEL, 0, 0, 0);
     ObjectSetText("info3", "M="+M+" Next Price="+DoubleToStr(NextPrice,5), 8, "Courier New", Yellow);
     ObjectSet    ("info3", OBJPROP_CORNER, 1);
     ObjectSet    ("info3", OBJPROP_XDISTANCE, 10);
     ObjectSet    ("info3", OBJPROP_YDISTANCE, 40);

     ObjectCreate ("info4", OBJ_LABEL, 0, 0, 0);
     ObjectSetText("info4", "Condition="+DoubleToStr(condition(),0), 8, "Courier New", Pink);
     ObjectSet    ("info4", OBJPROP_CORNER, 1);
     ObjectSet    ("info4", OBJPROP_XDISTANCE, 10);
     ObjectSet    ("info4", OBJPROP_YDISTANCE, 50);
     
     ObjectCreate ("info5", OBJ_LABEL, 0, 0, 0);
     ObjectSetText("info5", " ("+DoubleToStr((thisTakeProfit-Bid)*10000,0)+" pip away)"+"thisPrice="+DoubleToStr(thisPrice,5)+" thisTP="+DoubleToStr(thisTakeProfit,5), 8, "Courier New", Yellow);
     ObjectSet    ("info5", OBJPROP_CORNER, 1);
     ObjectSet    ("info5", OBJPROP_XDISTANCE, 10);
     ObjectSet    ("info5", OBJPROP_YDISTANCE, 60);           

     ObjectCreate ("info6", OBJ_LABEL, 0, 0, 0);
     ObjectSetText("info6", "Live ticket count="+DoubleToStr(ticketseries[0],0), 8, "Courier New", Lime);
     ObjectSet    ("info6", OBJPROP_CORNER, 1);
     ObjectSet    ("info6", OBJPROP_XDISTANCE, 10);
     ObjectSet    ("info6", OBJPROP_YDISTANCE, 70);     

     ObjectCreate ("info7", OBJ_LABEL, 0, 0, 0);
     ObjectSetText("info7", "thisLot="+DoubleToStr(thisLot,2), 8, "Courier New", Lime);
     ObjectSet    ("info7", OBJPROP_CORNER, 1);
     ObjectSet    ("info7", OBJPROP_XDISTANCE, 10);
     ObjectSet    ("info7", OBJPROP_YDISTANCE, 80);  

     ObjectCreate ("info8", OBJ_LABEL, 0, 0, 0);
     ObjectSetText("info8", "TrailingCount="+trailingCount+" HeadCount:"+HeadCount, 8, "Courier New", DarkGreen);
     ObjectSet    ("info8", OBJPROP_CORNER, 1);
     ObjectSet    ("info8", OBJPROP_XDISTANCE, 10);
     ObjectSet    ("info8", OBJPROP_YDISTANCE, 90);  
   
     WindowRedraw();

}

void inform(int event, double price=0,double lot=0, double ticket=0)
{
     string t;



     
     objnamecounter++;
     switch(event)
     {
          case 0: t="do nothing";                                                      break;
          case 1: t="Start New Series";   break;
          case 10: t="First Buy condition match";        break;
          //case 20: t="waiting for next Buy";                         break;
          case 20: break;
          case 21: t="TRAIL_TP:"+DoubleToStr(ticket,0)+"-->"+DoubleToStr(price,5); break;
          case 23: t="MOD_TP :"+DoubleToStr(ticket,0)+"-->"+DoubleToStr(price,5); break;
          case 22: t="REACH"+M+"LVL-NEW_OPEN:"+DoubleToStr(ticket,0)+"["+DoubleToStr(price,0)+"/"+DoubleToStr(lot,0)+"]";                         break;
          case 29: t="TRAIL_TP";                         break;
          case 40: t="MOD_SL"+DoubleToStr(ticket,0)+"-->"+DoubleToStr(price,5); break;
          
     }
     //set old message color
     if (event==0)                 // This happens at every tick
     {
          if (message_age==0) return;        // If it is gray already
          if (GetTickCount()-message_age>200)// The color has become updated within 15 sec
          {
               for(int k=0;k<=9; k++)       // Color lines with gray
                 ObjectSet( obj[k], OBJPROP_COLOR, Gray);
               message_age=0;                  // Flag: All lines are gray
               WindowRedraw();               // Redrawing objects
          }
          return;                          // Exit the function
     }    
     objnamecounter++;
     message_age=GetTickCount();           // Last publication time
     ObjectDelete(obj[9]);
     for(int i=9;i>=1;i--)
     {
          obj[i]=obj[i-1];
          ObjectSet    (obj[i],OBJPROP_YDISTANCE, 10+15*i);  // Axis Y
          
     }
     obj[0]="info_"+Symbol()+"_"+objnamecounter;
     ObjectCreate (obj[0], OBJ_LABEL, 0, 0, 0);
     ObjectSet    (obj[0],OBJPROP_CORNER, 3   );  // Corner
     ObjectSet    (obj[0],OBJPROP_XDISTANCE, 5);// Axis ?
     ObjectSet    (obj[0],OBJPROP_YDISTANCE, 10);  // Axis Y
     ObjectSetText(obj[0],t,8,"Courier New",LightGray);
     WindowRedraw();                      // Redrawing all objects     
     return;
}

double callotsize(int _m)
{
     double lots;
     

     if(_m==0)
     {
          lots=lot;
     }
     else if(_m>=1 && _m<=8)
     {
          lots=NormalizeDouble(lot*MathPow(x,_m-1),orderDecimal);
     }
     else if(_m>=9)
     {
          lots=NormalizeDouble(lot*MathPow(x,_m-1),orderDecimal);
     }
/*
     if(lots>maxtradesize)
     {

          MultiOrder=true;
     }
*/     
     return(lots);
}

void RecordDrawnDown()
{
     double dd=0,ddp=0;
     
     dd=NormalizeDouble(AccountEquity()-AccountBalance(),2);
     ddp=dd/AccountBalance()*100;
     thisDD=dd;
     thisDDP=ddp;
     if(dd<=maxDD)
     {
          maxDD=dd;
          maxDDP=ddp;
     }
}
double recProfit()
{
     double p;
     p=(AccountBalance()-balance)/balance*100;
     return(p);
}
void account_info()
{

   ObjectCreate ("acc1", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("acc1", "Balance="+DoubleToStr(AccountBalance(),2)+"("+DoubleToStr(recProfit(),2)+"%)", 10, "Courier New", LightPink);
   ObjectSet    ("acc1", OBJPROP_CORNER, 2);
   ObjectSet    ("acc1", OBJPROP_XDISTANCE, 10);
   ObjectSet    ("acc1", OBJPROP_YDISTANCE, 10);  

   //equity
   ObjectCreate ("acc2", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("acc2", "Equity="+DoubleToStr(AccountEquity(),2), 10, "Courier New", LightPink);
   ObjectSet    ("acc2", OBJPROP_CORNER, 2);
   ObjectSet    ("acc2", OBJPROP_XDISTANCE, 10);
   ObjectSet    ("acc2", OBJPROP_YDISTANCE, 25); 
   
   ObjectCreate ("acc3", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("acc3", "drawn down="+DoubleToStr(thisDD,2)+"("+DoubleToStr(thisDDP,2)+"%)", 10, "Courier New", LightPink);
   ObjectSet    ("acc3", OBJPROP_CORNER, 2);
   ObjectSet    ("acc3", OBJPROP_XDISTANCE, 10);
   ObjectSet    ("acc3", OBJPROP_YDISTANCE, 40); 
   
   ObjectCreate ("acc4", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("acc4", "Max drawn down="+DoubleToStr(maxDD,2)+"("+DoubleToStr(maxDDP,2)+"%)", 10, "Courier New", LightPink);
   ObjectSet    ("acc4", OBJPROP_CORNER, 2);
   ObjectSet    ("acc4", OBJPROP_XDISTANCE, 10);
   ObjectSet    ("acc4", OBJPROP_YDISTANCE, 55); 
        WindowRedraw();
}

void CloseAllThese()
{
     for(int i=1;i<=ticketseries[0];i++)
     {
          OrderSelect(ticketseries[i],SELECT_BY_TICKET);
          if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
          {
               if (OrderType() ==  OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, 3, Blue);
               if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, 3, Red);          
          }
          Sleep(1000);
     
     }
}