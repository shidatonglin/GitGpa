//+------------------------------------------------------------------+
//|                                                MGH BatchLots.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 09.11.2014, SwingMan"
#property link      "http://www.forexfactory.com/showthread.php?t=497448"
#property version   "1.00"
#property strict
#property indicator_chart_window

//+------------------------------------------------------------------+
input string ____Batch_1="-----------------------------------------";
input double first_Lot=0.10;
input double second_Lot=0.05;
input int Number_Batches=10;

//+------------------------------------------------------------------+

//---- buffers
double Batch[200][3];

//---- variables
bool calculateOK=true;
string CR="\n";
//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   Batch[1][1]=first_Lot;
   Batch[1][2]=second_Lot;

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
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
   if(calculateOK==false)
      return(0);
   int iBatch;

   for(iBatch=2;iBatch<=Number_Batches;iBatch++)
     {
      if(MathMod(iBatch,2)!=0)
         Get_OddBatchValues(iBatch); //-- Batch 3,5,7...
      else
      if(MathMod(iBatch,2)==0)
         Get_EvenBatchValues(iBatch); //-- Batch 2,4,6...
     }

//-- write results ------------------------------
   string sResult,sNR;
   for(iBatch=1;iBatch<=Number_Batches;iBatch++)
     {
      if(iBatch<10)
         sNR="Batch: "+" "+(string)iBatch;
      else
         sNR="Batch: "+(string)iBatch;
      sResult=sResult+sNR+"      "+DoubleToString(Batch[iBatch][1],2)+"      "+DoubleToString(Batch[iBatch][2],2)+CR;
     }
   Comment(sResult);
//--- return value of prev_calculated for next call
   calculateOK=false;
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|   Batch 2,4,6...
//+------------------------------------------------------------------+
void Get_EvenBatchValues(int batchNr)
  {
   double plusSum,minusSum,sum;

//=========================================
//-- Trade 1
//=========================================
   plusSum=0;
   minusSum=0;
   sum=0;
   for(int j=1; j<batchNr; j++)
     {
      //-- old Batch 1, 3, 5 -----------------
      if(MathMod(j,2)!=0)
        {
         minusSum=minusSum+Batch[j][1]*4;
         minusSum=minusSum+Batch[j][2]*3;
        }
      else
      //-- old Batch 2, 4, 6 -----------------
      if(MathMod(j,2)==0)
        {
         plusSum=plusSum+Batch[j][1]*2;
         plusSum=plusSum+Batch[j][2]*3;
        }
     }
   sum=minusSum-plusSum;
   sum=sum/2.0;

   Batch[batchNr][1]=NormalizeDouble(sum,2);

//=========================================
//-- Trade 2
//=========================================
   plusSum=0;
   minusSum=0;
   sum=0;
   for(int j=1; j<batchNr; j++)
     {
      //-- old Batch 1, 3, 5 -----------------
      if(MathMod(j,2)!=0)
        {
         minusSum=minusSum+Batch[j][1]*3;
         minusSum=minusSum+Batch[j][2]*2;
        }
      else
      //-- old Batch 2, 4, 6 -----------------
      if(MathMod(j,2)==0)
        {
         plusSum=plusSum+Batch[j][1]*1;
         plusSum=plusSum+Batch[j][2]*2;
        }
     }
   plusSum=plusSum+Batch[batchNr][1]*1;

   sum=minusSum-plusSum;
   sum=sum/2.0;

   Batch[batchNr][2]=NormalizeDouble(sum,2);
  }
//+------------------------------------------------------------------+
//|   Batch 3,5,7...
//+------------------------------------------------------------------+
void Get_OddBatchValues(int batchNr)
  {
   double plusSum,minusSum,sum;

//=========================================
//-- Trade 1
//=========================================
   plusSum=0;
   minusSum=0;
   sum=0;
   for(int j=1; j<batchNr; j++)
     {
      //-- old Batch 1, 3, 5 -----------------
      if(MathMod(j,2)!=0)
        {
         plusSum=plusSum+Batch[j][1]*2;
         plusSum=plusSum+Batch[j][2]*3;
        }
      else
      //-- old Batch 2, 4, 6 -----------------
      if(MathMod(j,2)==0)
        {
         minusSum=minusSum+Batch[j][1]*4;
         minusSum=minusSum+Batch[j][2]*3;
        }
     }
   sum=minusSum-plusSum;
   sum=sum/2.0;

   Batch[batchNr][1]=NormalizeDouble(sum,2);

//=========================================
//-- Trade 2
//=========================================
   plusSum=0;
   minusSum=0;
   sum=0;
   for(int j=1; j<batchNr; j++)
     {
      //-- old Batch 1, 3, 5 -----------------
      if(MathMod(j,2)!=0)
        {         
         plusSum=plusSum+Batch[j][1]*1;
         plusSum=plusSum+Batch[j][2]*2;
        }
      else
      //-- old Batch 2, 4, 6 -----------------
      if(MathMod(j,2)==0)
        {
         minusSum=minusSum+Batch[j][1]*3;
         minusSum=minusSum+Batch[j][2]*2;
        }
     }
   plusSum=plusSum+Batch[batchNr][1]*1;

   sum=minusSum-plusSum;
   sum=sum/2.0;

   Batch[batchNr][2]=NormalizeDouble(sum,2);
  }
//+------------------------------------------------------------------+
