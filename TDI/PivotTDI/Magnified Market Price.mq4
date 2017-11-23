//+------------------------------------------------------------------+
//| Magnified Market Price.mq4        ver1.4             by Habeeb   |
//+------------------------------------------------------------------+

#property indicator_chart_window

  extern string note1 = "Change font colors automatically? True = Yes";
  extern bool   Bid_Ask_Colors = True;
  extern string note2 = "Default Font Color";
  extern color  FontColor = Black;
  extern string note3 = "Font Size";
  extern int    FontSize=24;
  extern string note4 = "Font Type";
  extern string FontType="Comic Sans MS";
  extern string note5 = "Display the price in what corner?";
  extern string note6 = "Upper left=0; Upper right=1";
  extern string note7 = "Lower left=2; Lower right=3";
  extern int    WhatCorner=2;

  double        Old_Price;

int init()
  {
   return(0);
  }

int deinit()
  {
  ObjectDelete("Market_Price_Label"); 
  
  return(0);
  }

int start()
  {
   if (Bid_Ask_Colors == True)
   {
    if (Bid > Old_Price) FontColor = LawnGreen;
    if (Bid < Old_Price) FontColor = Red;
    Old_Price = Bid;
   }
   
   string Market_Price = DoubleToStr(Bid, Digits);
  
   ObjectCreate("Market_Price_Label", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Market_Price_Label", Market_Price, FontSize, FontType, FontColor);
   ObjectSet("Market_Price_Label", OBJPROP_CORNER, WhatCorner);
   ObjectSet("Market_Price_Label", OBJPROP_XDISTANCE, 1);
   ObjectSet("Market_Price_Label", OBJPROP_YDISTANCE, 1);
  }