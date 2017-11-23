//+------------------------------------------------------------------+
//|                                               Keltner_0_1.mq4     |
//|                                               By David Willis    | 
//|                       Based on 5 Min Keltner system               |
//|                       By Paulus                                  |
//+------------------------------------------------------------------+


extern double  Lots = 1.0;
extern double  TP   = 10;
extern double  SL   = 1;  // number of pips past the signal bar
extern double  MinimumSL = 5;
extern double  limit_amount=2;

extern int     keltner_lenght = 10;
extern double  keltner_TimesATR=1.0; 
extern string  Keltner_indicator="_My Keltner Channel";

extern int     start_time=5;
extern int     endtradingtime=20;
extern int     slippage = 5;
extern int     MagicNumber = 12345;


//+------------------------------------------------------------------+
int init()
  {
   return(0);
  }
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+


int start()
{
 int signalold;                                                                     // if = 0, the signal bar is not old (price has not moved past sl or tp levels
 double sl,sl2,slamount,tp,entrypoint,slammount,spread=Ask-Bid;
 int last_signal = lastsignal();                                                    // bars to last signal bar
 int second_last_signal=secondlastsig(last_signal);                                 // bars to second to last signal bar
 int last_sig_direction=lastsigdirection(last_signal);                              // 0=long, 1=short
 int second_last_sig_dir=lastsigdirection(second_last_signal);                      // 0=long, 1=short
 double pips_moved=pipsmoved(last_signal,last_sig_direction);                       //pips moved in direction of trade since signal bar
 double pips_moved_against=pipsmovedagainst(last_signal,last_sig_direction);        //pips moved against last signal
// int last_entry_signal = lastentry(last_signal,last_sig_direction);               //last time price moved to limit price after a signal bar
 int last_trade=lastrade();                                                         //time in seconds from the last trade placed
 int last_trade_signal=TimeCurrent()-Time[last_signal];                             //time in seconds from the last signal bar
 
 
 if(last_sig_direction==0) {entrypoint= Close[last_signal]-limit_amount*Point;}
 else
 {entrypoint= Close[last_signal]+limit_amount*Point;}         
 
 
 
 
 
 
 
 // get take profit and Stop loss values and see if last signal bar is old 
 if(last_sig_direction== 0)
 {
  sl=Low[last_signal]-((SL*Point)+(Ask-Bid));
  sl2=entrypoint-MinimumSL*Point;
  if(sl2<sl){sl=sl2;}
  slammount=(entrypoint-sl)/Point;
  tp=entrypoint+TP*Point+spread;
  if(slammount>pips_moved_against && TP>pips_moved){signalold=0;}
  else {signalold=1;}
 }
 
 else 
 {
  sl=High[last_signal]+((SL*Point)+(Ask-Bid));
  sl2=entrypoint+MinimumSL*Point;
  if(sl2>sl){sl=sl2;}
  slammount=(sl-entrypoint)/Point;
  tp=entrypoint-TP*Point-spread;
  if(slammount>pips_moved_against && TP>pips_moved){signalold=0;}
  else {signalold=1;} 
 }
 
 
 
 Comment("\nlast signal bar = ",last_signal,"\nsecond last signal= ",second_last_signal,"\nlast signal direction= ", last_sig_direction,
 "\nsecond last signal direction= ",second_last_sig_dir,"\npips moved= ",pips_moved, "\npips moved agains= ", pips_moved_against,
 "\nrsi filter= ",rsifilter(last_signal+1,second_last_signal+1,last_sig_direction),"\ntrading time = ",tradingtime(),
 "\nlast entry = ",entrypoint,"\nlast trade = ",last_trade, "\nlast sig = ",last_trade_signal,"\nSignal 0ld = ",signalold,
 "\nslammout= ",slammount, "\nstop loss = ",sl, "\ntake profit = ",tp,"\nspread= ",spread);


 if(last_trade>last_trade_signal && signalold==0  && tradingtime()==1)
 { 
   if(second_last_sig_dir != last_sig_direction || rsifilter(last_signal+1,second_last_signal+1,last_sig_direction)==1)
   { 
     //long trade
     if(last_sig_direction== 0)
     {
      if(Bid<=entrypoint)
      {
       if(opentrades()>0 && tradedirection() ==1 ){closealltrades();}
       if(opentrades()==0)
       {         
        OrderSend(Symbol(),OP_BUY,Lots,Ask,slippage,sl,tp,"K"+MagicNumber,MagicNumber,0,Blue);
       }
      }
     }  
     else   //Short trade
     {   
      if(Bid>=entrypoint)
      {
       if(opentrades()>0 && tradedirection() ==0 ){closealltrades();}
       if(opentrades()==0)
       {       
        OrderSend(Symbol(),OP_SELL,Lots,Bid,slippage,sl,tp,"K"+MagicNumber,MagicNumber,0,Red);
       }
      }
     }  
   }  
 }      
  
 return(0);     
}       
       
  
        

//+------------------------------------------------------------------+


int lastsignal()
{
  int signal=0,cnt;
  
  for(cnt=1;cnt < 100;cnt++)
  {  //  for long sig bar
   if(iStochastic(NULL,0,5,3,3,0,1,MODE_MAIN,cnt+1) < 20.0) // stochastic under 20
   {if(iCustom(NULL,0,"StochasticDiNapoli_v1[1]",8,3,3,0,cnt) < 30.0||iCustom(NULL,0,"StochasticDiNapoli_v1[1]",8,3,3,0,cnt+1) < 30.0)// DiNaoli under 30
    {if(iStochastic(NULL,0,5,3,3,0,1,MODE_MAIN,cnt+1) < iStochastic(NULL,0,5,3,3,0,1,MODE_MAIN,cnt)) // stochastic increase
     {if(Close[cnt+1] < iCustom(NULL,0,Keltner_indicator,0,keltner_lenght,0,0,0,keltner_TimesATR,2,cnt+1)) //close previous bar under keltner channel
      {if(Close[cnt]>Open[cnt]) // upbar
       {if(High[cnt]<iCustom(NULL,0,Keltner_indicator,0,keltner_lenght,0,0,0,keltner_TimesATR,0,cnt))
        {if(Close[cnt+1]<=Open[cnt+1])
         {
           signal = cnt;
           break;
       }}}}}}}
       //for short sig bar
   if(iStochastic(NULL,0,5,3,3,0,1,MODE_MAIN,cnt+1) > 80.0) // stochastic over 80
   {if(iCustom(NULL,0,"StochasticDiNapoli_v1[1]",8,3,3,0,cnt) > 70.0||iCustom(NULL,0,"StochasticDiNapoli_v1[1]",8,3,3,0,cnt+1) > 70.0)// DiNaoli over 70
    {if(iStochastic(NULL,0,5,3,3,0,1,MODE_MAIN,cnt+1) > iStochastic(NULL,0,5,3,3,0,1,MODE_MAIN,cnt)) // stochastic decrease
     {if(Close[cnt+1] > iCustom(NULL,0,Keltner_indicator,0,keltner_lenght,0,0,0,keltner_TimesATR,0,cnt+1)) //close previous bar over keltner channel
      {if(Close[cnt]<Open[cnt]) // downbar
       {if(Low[cnt]>iCustom(NULL,0,Keltner_indicator,0,keltner_lenght,0,0,0,keltner_TimesATR,2,cnt))
       {if(Close[cnt+1]>=Open[cnt+1])
        {
         signal = cnt;
         break;
       }}}}}}}     
  }
return(signal);
}

int secondlastsig(int last)
{
  int signal=0,cnt;
  
  for(cnt=last+1;cnt<100;cnt++)
  {  //  for long sig bar
   if(iStochastic(NULL,0,5,3,3,0,1,MODE_MAIN,cnt+1) < 20.0) // stochastic under 20
   {if(iCustom(NULL,0,"StochasticDiNapoli_v1[1]",8,3,3,0,cnt) < 30.0||iCustom(NULL,0,"StochasticDiNapoli_v1[1]",8,3,3,0,cnt+1) < 30.0)// DiNaoli under 30
    {if(iStochastic(NULL,0,5,3,3,0,1,MODE_MAIN,cnt+1) < iStochastic(NULL,0,5,3,3,0,1,MODE_MAIN,cnt)) // stochastic increas
     {if(Close[cnt+1] < iCustom(NULL,0,Keltner_indicator,0,keltner_lenght,0,0,0,keltner_TimesATR,2,cnt+1)) //close previous bar under keltner channel
      {if(Close[cnt]>Open[cnt]) // upbar
       {if(Close[cnt+1]<Open[cnt+1])
        {
         signal = cnt;
         break;
       }}}}}}
       //for short sig bar
   if(iStochastic(NULL,0,5,3,3,0,1,MODE_MAIN,cnt+1) > 80.0) // stochastic over 80
   {if(iCustom(NULL,0,"StochasticDiNapoli_v1[1]",8,3,3,0,cnt) > 70.0||iCustom(NULL,0,"StochasticDiNapoli_v1[1]",8,3,3,0,cnt+1) > 70.0)// DiNaoli over 70
    {if(iStochastic(NULL,0,5,3,3,0,1,MODE_MAIN,cnt+1) > iStochastic(NULL,0,5,3,3,0,1,MODE_MAIN,cnt)) // stochastic decrease
     {if(Close[cnt+1] > iCustom(NULL,0,Keltner_indicator,0,keltner_lenght,0,0,0,keltner_TimesATR,0,cnt+1)) //close previous bar over keltner channel
      {if(Close[cnt]<Open[cnt]) // downbar
       {if(Close[cnt+1]>Open[cnt+1])
        {
         signal = cnt;
         break;
       }}}}}}     
  }
return(signal);
}


int lastsigdirection(int sig)
{
  int direction;
  
  if(Close[sig]>Open[sig]){direction=0;}
  if(Close[sig]<Open[sig]){direction=1;}
  
  return(direction);
}



//(High[last_signal-6]-Close[last_signal])/Point


double pipsmoved(int sig, int direction)  
{
  double pips=0.0;
  int cnt;
  
  if(direction==0) //long
  {
   for(cnt=0;cnt<sig;cnt++)
   {
    if((High[cnt]-Close[sig])>=pips){pips=(High[cnt]-Close[sig]);}
   }
   return(pips/Point);
  }
  
  if(direction==1) // short
  {
   for(cnt=sig-1;cnt>=0;cnt--)
   {
    if(Close[sig]-Low[cnt]>pips*Point){pips=(Close[sig]-Low[cnt])/Point;}
   }
   return(pips);
  }
}
 
 
double pipsmovedagainst(int sig, int revdirection)  
{
  double pips=0.0;
  int cnt,direction;
  
  if(revdirection==0){direction=1;}
  else{direction=0;}
  
  if(direction==0) //long
  {
   for(cnt=0;cnt<sig;cnt++)
   {
    if((High[cnt]-Close[sig])>=pips){pips=(High[cnt]-Close[sig]);}
   }
   return(pips/Point);
  }
  
  if(direction==1) // short
  {
   for(cnt=sig-1;cnt>=0;cnt--)
   {
    if(Close[sig]-Low[cnt]>pips*Point){pips=(Close[sig]-Low[cnt])/Point;}
   }
   return(pips);
  }
}

int rsifilter(int last,int second_last,int direction)
{
  int filter=0;
  int cnt;
  double peak1,peak2;
  
  if(direction==1)  //short
  {
   for(cnt=0,peak1=0,peak2=0;cnt<=2;cnt++)
   {
    if(iRSI(NULL,0,14,PRICE_CLOSE,last+cnt)>peak1) {peak1=iRSI(NULL,0,14,PRICE_CLOSE,last+cnt);}
    if(iRSI(NULL,0,14,PRICE_CLOSE,second_last+cnt)>peak2) {peak2=iRSI(NULL,0,14,PRICE_CLOSE,second_last+cnt);}
   }
   if(peak2>peak1) {filter=1;}
   return(filter);
  }
  
  if(direction==0) // long
  {
   for(cnt=0,peak1=500,peak2=500;cnt<=2;cnt++)
   {
    if(iRSI(NULL,0,14,PRICE_CLOSE,last+cnt)<peak1) {peak1=iRSI(NULL,0,14,PRICE_CLOSE,last+cnt);}
    if(iRSI(NULL,0,14,PRICE_CLOSE,second_last+cnt)<peak2) {peak2=iRSI(NULL,0,14,PRICE_CLOSE,second_last+cnt);}
   }
   if(peak2<peak1) {filter=1;}
   //Comment("\n\n\n\n\n\n\n\n\n\npeak1 = ",peak1,"\n peak2 = ",peak2);
   return(filter);
  }
  
}  

  
int opentrades()
{
  int trades=0;
  int cnt;
  
  for(cnt=0;cnt<OrdersTotal();cnt++)   
  {
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);  
    if (OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber) {trades ++;}
  }     
  return(trades);
}


void closealltrades()
{
  int cnt;
  for(cnt=0;cnt<10;cnt++)
  {
    closetrades();
    if(opentrades()==0){cnt=10;}
  }
}  
  

void closetrades()
{
  int cnt;
  for(cnt=0;cnt<OrdersTotal();cnt++)   
  {
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
	 if (OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
	 {		
	 	 if(OrderType() == 1) 	
	 	 {OrderClose(OrderTicket(),OrderLots(),Ask,slippage,Yellow);}
	 	 else {OrderClose(OrderTicket(),OrderLots(),Bid,slippage,Yellow);}
	 }
  }
}

int lastdirection()
{

  int cnt;
  int direction;
  
  if(opentrades()==0)
  {
   for(cnt=OrdersTotal();cnt>=0;cnt--)   
   {
    OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY);
	 if (OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
	 {				
	 	 if (OrderType() == 0) {direction=0;}
	 	 if (OrderType() == 1) {direction=1;}
	 	 cnt=-1;
	 }
   }
  }
  else
  direction=tradedirection();
  return (direction);
}
 
int tradedirection()
{

  int cnt;
  int direction;
  
  for(cnt=OrdersTotal();cnt>=0;cnt--)   
  {
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
	 if (OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
	 {				
	 	 if (OrderType() == 0) {direction=0;}
	 	 if (OrderType() == 1) {direction=1;}
	 	 cnt=-1;
	 }
  }
  return (direction);
} 

int tradingtime()
{

  int trading=0;
  
  if(start_time<endtradingtime && Hour()<endtradingtime && Hour()>start_time) {trading=1;}
  if(start_time>endtradingtime)
  {
    if(Hour()>start_time)    {trading=1;}
    if(Hour()<endtradingtime){trading=1;}
  }
  return(trading);
}


int lastentry(int sig, int direction)
{
  int entry=sig+1,cnt;
  
  for(cnt=sig-1;cnt>=0;cnt--)
  {
   if (direction==0)
   { 
     if (Low[cnt]<= Close[sig]-limit_amount*Point)
     {
      entry=cnt;
      return(entry);
     }
   }
   else
   {
     if (High[cnt]>= Close[sig]+limit_amount*Point)
     {
      entry=cnt;
      return(entry);
     }
    }
   }
     
return(0);
}

int lastrade()
 {
   int cnt;
   int time;
   
   for(cnt=0;cnt<100;cnt++)
   {
     OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY);
     if (OrderSymbol()==Symbol()&& OrderMagicNumber() == MagicNumber)
     {
       time=TimeCurrent()-OrderOpenTime();
       return(time);
     }
  }
 return(1000000);
 } 
//+---------------------------------------------------------------------------+
//|                              THE END                                      |
//+---------------------------------------------------------------------------+