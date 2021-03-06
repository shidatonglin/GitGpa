//+------------------------------------------------------------------+
//|                                               MA_BBands_V3.2.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//|                                        E-MAIL:40468962@qq.com    |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 White
#property indicator_color2 White
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_color5 Yellow



#property  indicator_width1  2
#property  indicator_width2  2
#property  indicator_width3  1
#property  indicator_width4  1
#property  indicator_width5  1


extern int MAPeriod = 9 ;
extern int OsMA = 3 ;//5 
extern int HiLow_Find_Period = 3;//5;9
//-------------------------

extern double Bands_Deviations = 0.4 ; //0.5;0.8;1.0
extern int BB_Period = 20 ;
extern int Dist = 2 ;
//-------------------------

double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];

double Get_Point;
//-------------------

int init()
  {
  
   IndicatorBuffers(7);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer5);   

   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer6);     
     
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,233);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexEmptyValue(2,0.0);
   
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,234);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexEmptyValue(3,0.0);
   
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,ExtMapBuffer7); 
   
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,ExtMapBuffer1);
   
   SetIndexStyle(6,DRAW_NONE);
   SetIndexBuffer(6,ExtMapBuffer2);   
   
   
    if(Digits==2 || Digits==4) Get_Point=Point;
    else if(Digits==3 || Digits==5) Get_Point=10*Point; 
   
   return(0);
  }
//----------------------------------------
 
int deinit()
  {return(0);}
//---------------------------------------- 
int start()
  { 
  Comment( " MA_BBands_V3.2" );  
    int counted_bars=IndicatorCounted();    
    if(counted_bars<0) return(-1); 
    if(counted_bars>0) counted_bars--;
    int limit=Bars-counted_bars;   
    double OsMA_Now, OsMA_Pre; 
    
    //for(int i=limit-1; i>=0; i--)
    for(int i=1; i<=limit; i++)    
     {           
           double MAUP1 = iMA(NULL,0,MAPeriod,-15,MODE_SMA,PRICE_HIGH,i); 
           double BB_UP = iBands(NULL,0,BB_Period,Bands_Deviations,0,PRICE_HIGH,MODE_UPPER,i+4);
           double MA_HIGH = iMA(NULL,0,HiLow_Find_Period,0,MODE_LWMA,PRICE_HIGH,i);  
           
           double MADN1 = iMA(NULL,0,MAPeriod,-15,MODE_SMA,PRICE_LOW,i); 
           double BB_DN = iBands(NULL,0,BB_Period,Bands_Deviations,0,PRICE_LOW ,MODE_LOWER,i+4);
           double MA_LOW = iMA(NULL,0,HiLow_Find_Period,0,MODE_LWMA,PRICE_LOW,i);  
           
           double SEC_UP = iMA(NULL,0,9,-7,MODE_SMA,PRICE_HIGH,i); 
           double SEC_DN = iMA(NULL,0,9,-7,MODE_SMA,PRICE_LOW,i); 
       
//--------------------------------------------------------------------        
         if (MAUP1>BB_UP) {ExtMapBuffer1[i]=MAUP1+Dist*Get_Point; BB_UP=EMPTY_VALUE ;}     
         else if (MAUP1<BB_UP) {ExtMapBuffer1[i]=BB_UP ; MAUP1=EMPTY_VALUE ;}
                              
         if( MADN1 >0.0 ) 
         {
          if ( MADN1<BB_DN)  {ExtMapBuffer2[i]=MADN1-Dist*Get_Point; BB_DN=EMPTY_VALUE ;}                        
          else if (MADN1>BB_DN) { ExtMapBuffer2[i]=BB_DN ; MADN1=EMPTY_VALUE ; }
         }
       
         if (MADN1 ==0.0 ) { ExtMapBuffer2[i]=BB_DN; MADN1=EMPTY_VALUE ;}          
//------------------------------------------------------------
//------------------------------------------------------------
 
         if (SEC_UP>ExtMapBuffer1[i]) {ExtMapBuffer5[i]=SEC_UP+Dist*Get_Point; ExtMapBuffer1[i]=EMPTY_VALUE ;}     
         else if (SEC_UP<ExtMapBuffer1[i]) {ExtMapBuffer5[i]=ExtMapBuffer1[i] ; SEC_UP=EMPTY_VALUE ;}
                              
         if( SEC_DN >0.0 ) 
         {
          if ( SEC_DN<ExtMapBuffer2[i])  {ExtMapBuffer6[i]=SEC_DN-Dist*Get_Point; ExtMapBuffer2[i]=EMPTY_VALUE ;}                        
          else if (SEC_DN>ExtMapBuffer2[i]) { ExtMapBuffer6[i]=ExtMapBuffer2[i] ; SEC_DN=EMPTY_VALUE ; }
         }
       
         if (SEC_DN ==0.0 ) { ExtMapBuffer6[i]=ExtMapBuffer2[i]; SEC_DN=EMPTY_VALUE ;}  


//------------------------------------------------------------
      
       OsMA_Now = iOsMA(NULL,0,5,9,OsMA,PRICE_CLOSE,i) ;
       OsMA_Pre = iOsMA(NULL,0,5,9,OsMA,PRICE_CLOSE,i+1) ;

//-------------------
       if((OsMA_Now>0 && OsMA_Pre<0)&&(MA_LOW < ExtMapBuffer6[i]) && (Low[i] < ExtMapBuffer6[i]))
       //if((OsMA_Now>0 && OsMA_Pre<0)&&(MA_LOW < ExtMapBuffer6[i]) && (Close[i] < ExtMapBuffer6[i]))
       {
        ExtMapBuffer3[i+1] = Low[i]-2*Get_Point;
       }
              
       if((OsMA_Now<0 && OsMA_Pre>0) && (MA_HIGH > ExtMapBuffer5[i]) && (High[i] > ExtMapBuffer5[i]))
      //if((OsMA_Now<0 && OsMA_Pre>0) && (MA_HIGH > ExtMapBuffer5[i]) && (Close[i] > ExtMapBuffer5[i]))
       {
        ExtMapBuffer4[i+1] = High[i]+2*Get_Point;
       }  
       
       ExtMapBuffer7[i]=(ExtMapBuffer5[i]+ExtMapBuffer6[i])/2.0 ;
       
        
     } 
     
        //WindowRedraw();
        RefreshRates(); 
     
   return(0);

   
  } 
//--------------------------------

