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
#include <stdlib.mqh>
extern int BreakevenStop             = 250;// Break even, o to disable
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
           if (!bres) Print("Error Modifying BE BUY order : ",ErrorDescription(GetLastError()));
         }
      }

      if ( OrderType() == OP_SELL ) {
         if (Ask>OrderOpenPrice()-BP*Point) continue;
         if ( OrderStopLoss()-(OrderOpenPrice()-BE*Point)>Point/10) {
               //Print(BP,"  ",BE," bestop");
               bres=OrderModify (OrderTicket(), OrderOpenPrice(), OrderOpenPrice()-BE*Point, OrderTakeProfit(), 0, Gold);
           if (!bres) Print("Error Modifying BE SELL order : ",ErrorDescription(GetLastError()));
         }
      }
   }
   return;
}

extern int Trail_Stop_Pips           = 250;//Trailing Stop, 0 to disable
extern int Trail_Stop_Jump_Pips      = 100;//Trail Stop Shift
void trail_stop()
{ double new_sl=0; bool OrderMod=false;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()==Magic_Number && OrderSymbol()==Symbol())
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
               tries=tries+1;
               
            }
         
         }
         
      }
   }
}