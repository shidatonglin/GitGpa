//+------------------------------------------------------------------+
//|                                                   GetAllObjs.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

string pair[28];
string tradePair[28][2];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   Assign28SymbolToList(pair);
   
   showAllObjs();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void showAllObjs(){
   int obj_total=ObjectsTotal();
   string name;
   string value;
   string orderType;
   int index = 0;
   for(int i=0;i<obj_total;i++)
    {
     name = ObjectName(i);
     
     if(ObjectGet(name,OBJPROP_XDISTANCE) == 25){
         //Print("objectname--->"+ name + " object value--->"+ObjectGetString(0,name,OBJPROP_TEXT));
         value = ObjectGetString(0,name,OBJPROP_TEXT);
         if(VerifySymbol(pair,value)){
            tradePair[index][0]=value;
            
            //Print("value--->"+value + " next obj--->"+ ObjectName(i+1));
            string nextObj = ObjectName(i+1);
            if(StringFind(nextObj,"suggest")>0){
            }
            string suggest = ObjectGetString(0,nextObj,OBJPROP_TEXT);
            //printf("objectname--->"+nextObj + " ojectvalue---->"+suggest);
            //Print(ObjectName(i+1));
            //Print(StringFind(suggest,"Sell"));
            if(StringFind(nextObj,"suggest")>0 && StringFind(nextObj,value)>0){
               if(StringFind(suggest,"Sell")>0){
                  tradePair[index][1]="sell";
               }
               if(StringFind(suggest,"Buy")>0){
                  tradePair[index][1]="buy";
               }
            }
            index++; 
         }
     }
     //if(StringFind(name,"suggest")>0){
        //string count = ObjectGetString(0,name,OBJPROP_TEXT);
        //Print("objectname--->"+ name + " object value--->"+count);

     //}
     //Print(i," object - ",name);
    }
    
    for(int j=0;j<index;j++){
       
       Print(tradePair[j][0] + " " + tradePair[j][1]);
    }
}


//+------------------------------------------------------------------+
bool VerifySymbol(string &list[],string yoursymbol)
  {
   for(int i=0;i<ArraySize(list);i++)
     {
      if(yoursymbol==list[i])
        {
         return(true);
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+


void Assign28SymbolToList(string &array[])
  {
//EURUSD
//GBPUSD
//AUDUSD
//NZDUSD
//USDCAD
//USDJPY
//USDCHF
   array[0]="EURUSD";
   array[1]="GBPUSD";
   array[2]="AUDUSD";
   array[3]="NZDUSD";
   array[4]="USDCAD";
   array[5]="USDJPY";
   array[6]="USDCHF";
//EURGBP
//EURAUD
//EURNZD
//EURCAD
//EURJPY
//EURCHF
   array[7]="EURGBP";
   array[8]="EURAUD";
   array[9]="EURNZD";
   array[10]="EURCAD";
   array[11]="EURJPY";
   array[12]="EURCHF";
//GBPAUD
//GBPNZD
//GBPCAD
//GBPJPY
//GBPCHF
   array[13]="GBPAUD";
   array[14]="GBPNZD";
   array[15]="GBPCAD";
   array[16]="GBPJPY";
   array[17]="GBPCHF";

//AUDNZD
//AUDCAD
//AUDJPY
//AUDCHF
   array[18]="AUDNZD";
   array[19]="AUDCAD";
   array[20]="AUDJPY";
   array[21]="AUDCHF";
//NZDCAD
//NZDJPY
//NZDCHF
   array[22]="NZDCAD";
   array[23]="NZDJPY";
   array[24]="NZDCHF";
//CHFJPY
//CADCHF
//CADJPY
   array[25]="CHFJPY";
   array[26]="CADCHF";
   array[27]="CADJPY";
  }