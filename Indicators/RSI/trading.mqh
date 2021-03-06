//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Trade operation                                                |
//+------------------------------------------------------------------+
class trading
  {
private:
   string            textcom;
   bool              useECNNDD;
   double            ND(double pr);
   int               NormE(int pr);
   double            NormL(double lo);
   bool              ChekPar(int tip,double oop,double osl,double otp,double op,double sl,double tp,int mod=0);
   int               SendOrd(int tip,double lo,double op,double sl,double tp,string com);
   bool              StopLev(double pr1,double pr2);
   bool              Freez(double pr1,double pr2);
   bool              FreeM(double lo);
   string            StrTip(int tip);
   string            Errors(int id);
   void              Err(int id);

public:
   bool              ruErr;
   int               Magic;
   string            Com;
   int               slipag;
   double            Lot;
   bool              Lot_const;
   double            Risk;
   int               NumTry;
   color             BayCol;
   color             SelCol;
   bool              ClosePosAll(int OrdType=-1);
   bool              OpnOrd(int tip,double op_l,double op_pr,int stop,int take);
   double            Lots();
   int               Dig();

  };
//+------------------------------------------------------------------+
//| OpnOrd                                                           |
//+------------------------------------------------------------------+
bool trading:: OpnOrd(int tip,double op_l,double op_pr,int stop,int take)
  {
   bool res=false;
   long stoplevel=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   double sl=0.0,tp=0.0;
   if(MathMod(tip,2.0)==0.0)
     {
      if(!useECNNDD)
        {
         if(stop>0)
            sl=op_pr-NormE(stop)*Point;
         if(take>0)
            tp=op_pr+NormE(take)*Point;
        }
     }
   else{if(!useECNNDD){if(stop>0)sl=op_pr+NormE(stop)*Point;if(take>0)tp=op_pr-NormE(take)*Point;}}
   if(SendOrd(tip,op_l,op_pr,sl,tp,Com)>0)
      res=true;
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(res);
  }
//+------------------------------------------------------------------+
//| SendOrd                                                          |
//+------------------------------------------------------------------+
int trading:: SendOrd(int tip,double lo,double op,double sl,double tp,string com)
  {
   int i=0,tiket=0;
   if(!FreeM(lo))
      return(tiket);
   color col=SelCol;
   if(MathMod(tip,2.0)==0.0)
      col=BayCol;
   for(i=1;i<NumTry;i++)
     {
      switch(tip)
        {
         case 0:
            op=Ask;
            break;
         case 1:
            op=Bid;
            break;
        }
      if(!ChekPar(tip,0.0,0.0,0.0,op,sl,tp,0))
         break;
      tiket=OrderSend(_Symbol,tip,NormL(lo),ND(op),slipag,ND(sl),ND(tp),com,Magic,0,col);
      if(tiket>0)
         break;
      else
        {
         int er=GetLastError();
         textcom=StringConcatenate(textcom,"\n",__FUNCTION__,"Position opening error",StrTip(tip)," : ",
                                   Errors(er)," ,attempt ",IntegerToString(i),"  ",TimeCurrent());
         Err(er);
        }
     }
   return(tiket);
  }
//+------------------------------------------------------------------+
//| ClosePosAll                                                      |
//+------------------------------------------------------------------+
bool trading::ClosePosAll(int OrdType=-1)
  {
   double price;
   int i;
   bool _Ans=true;
   for(int pos=OrdersTotal()-1; pos>=0; pos--)
     {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()!=_Symbol || OrderMagicNumber()!=Magic)
         continue;
      int order_type=OrderType();
      if(order_type>1 || (OrdType>=0 && OrdType!=order_type))
         continue;
      RefreshRates();
      i=0;
      bool Ans=false;
      while(!Ans && i<NumTry)
        {
         if(order_type==OP_BUY)
            price=Bid;
         else
            price=Ask;
         Ans=OrderClose(OrderTicket(),OrderLots(),ND(price),slipag);
         if(!Ans)
           {
            int er=GetLastError();
            if(er>0)
               textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
           }
         i++;
        }
      if(!Ans)
         _Ans=false;
     }
   return(_Ans);
  }
//+------------------------------------------------------------------+
//| ND                                                               |
//+------------------------------------------------------------------+
double trading:: ND(double pr)
  {
   double res=NormalizeDouble(pr,_Digits);
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(res);
  }
//+------------------------------------------------------------------+
//| NormE                                                            |
//+------------------------------------------------------------------+
int trading:: NormE(int pr)
  {
   long res=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   res++;
   if(pr>res)
      res=pr;
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(int(res));
  }
//+------------------------------------------------------------------+
//| NormL                                                            |
//+------------------------------------------------------------------+
double trading:: NormL(double lo)
  {
   double res=lo;
   int mf=int(MathCeil(lo/SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP)));
   res=mf*SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   res=MathMax(res,SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN));
   res=MathMin(res,SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX));
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(res);
  }
//+------------------------------------------------------------------+
//| Errors                                                           |
//+------------------------------------------------------------------+
string trading:: Errors(int id)
  {
   string res="";
   if(ruErr)
     {
      switch(id)
        {
         case 0:    res=" No errors. ";break;
         case 1:    res=" No errors but result is unknown. ";break;
         case 2:    res=" Common error. ";break;
         case 3:    res=" Incorrect parameters. ";break;
         case 4:    res=" Trade server is busy. ";break;
         case 5:    res=" Older version of the client terminal. ";break;
         case 6:    res=" No connection with trade server. ";break;
         case 7:    res=" Not enough rights. ";break;
         case 8:    res=" Too many requests. ";break;
         case 9:    res=" Malfunctional trade operation. ";break;
         case 64:   res=" Account disabled. ";break;
         case 65:   res=" Incorrect account number. ";break;
         case 128:  res=" Trade timeout. ";break;
         case 129:  res=" Incorrect price. ";break;
         case 130:  res=" Incorrect stops. ";break;
         case 131:  res=" Incorrect volume. ";break;
         case 132:  res=" Market is closed. ";break;
         case 133:  res=" Trading forbidden. ";break;
         case 134:  res=" Not enough money to perform the operation. ";break;
         case 135:  res=" Price changed. ";break;
         case 136:  res=" No prices. ";break;
         case 137:  res=" Broker is busy. ";break;
         case 138:  res=" New prices. ";break;
         case 139:  res=" Order is disabled and is being processed. ";break;
         case 140:  res=" Only buying is allowed. ";break;
         case 141:  res=" Too many requests. ";break;
         case 145:  res=" Modification denied because the order is too close to market. ";break;
         case 146:  res=" Trade context is busy. ";break;
         case 147:  res=" Expirations are denied by broker. ";break;
         case 148:  res=" The number of open and pending orders has reached the limit set by the broker. ";break;
         case 149:  res=" Hedging is disabled ";break;
         case 150:  res=" Forbidden by FIFO rules ";break;
         case 4000: res=" No error. ";break;
         case 4001: res=" Wrong function pointer. ";break;
         case 4002: res=" Array index is outside the range. ";break;
         case 4003: res=" No memory for function call stack. ";break;
         case 4004: res=" Recursive stack overflow. ";break;
         case 4005: res=" Not enough stack for parameter. ";break;
         case 4006: res=" No memory for string parameter. ";break;
         case 4007: res=" No memory for temp string. ";break;
         case 4008: res=" Not initialized string. ";break;
         case 4009: res=" Not initialized string in array. ";break;
         case 4010: res=" No memory for string array. ";break;
         case 4011: res=" String too long. ";break;
         case 4012: res=" Remainder from zero divide. ";break;
         case 4013: res=" Zero divide. ";break;
         case 4014: res=" Unknown command. ";break;
         case 4015: res=" Wrong jump. ";break;
         case 4016: res=" Not initialized array. ";break;
         case 4017: res=" DLL calls are not allowed. ";break;
         case 4018: res=" Cannot load the library. ";break;
         case 4019: res=" Cannot call the function. ";break;
         case 4020: res=" Calls of external library functions are not allowed. ";break;
         case 4021: res=" Not enough memory for returned string. ";break;
         case 4022: res=" System is busy. ";break;
         case 4023: res=" DLL function call critical error ";break;
         case 4024: res=" Internal error ";break;
         case 4025: res=" No memory ";break;
         case 4026: res=" Incorrect pointer ";break;
         case 4027: res=" Too many parameters of string formatting ";break;
         case 4028: res=" Number of parameters exceeds number of parameters of string formatting ";break;
         case 4029: res=" Incorrect array ";break;
         case 4030: res=" Chart not responding ";break;
         case 4050: res=" Invalid number of function parameters. ";break;
         case 4051: res=" Invalid value of function parameter. ";break;
         case 4052: res=" String function internal error. ";break;
         case 4053: res=" Array error. ";break;
         case 4054: res=" Incorrect use of time series array. ";break;
         case 4053: res=" Custom indicator error. ";break;
         case 4056: res=" Incompatible arrays. ";break;
         case 4057: res=" Global variable processing error. ";break;
         case 4058: res=" Global variable not found. ";break;
         case 4059: res=" Function is not allowed in testing mode. ";break;
         case 4060: res=" Function is not allowed. ";break;
         case 4061: res=" Mail sending error. ";break;
         case 4062: res=" String parameter expected. ";break;
         case 4063: res=" Integer parameter expected. ";break;
         case 4064: res=" Double parameter expected. ";break;
         case 4065: res=" Array expected as parameter. ";break;
         case 4066: res=" Requested history data are being updated. ";break;
         case 4067: res=" Error when executing trade operation. ";break;
         case 4068: res=" Resource not found ";break;
         case 4069: res=" Resource not supported ";break;
         case 4070: res=" Resource duplicate ";break;
         case 4071: res=" Custom indicator initialization error ";break;
         case 4099: res=" End of file. ";break;
         case 4100: res=" Error when working with file. ";break;
         case 4101: res=" Wrong file name. ";break;
         case 4102: res=" Too many open files. ";break;
         case 4103: res=" Cannot open the file. ";break;
         case 4104: res=" Incompatible file access mode. ";break;
         case 4105: res=" No orders selected. ";break;
         case 4106: res=" Unknown symbol. ";break;
         case 4107: res=" Invalid price parameter for trading function. ";break;
         case 4108: res=" Wrong ticket number. ";break;
         case 4109:res=" Trading is not allowed. Necessary to enable the option "Allow the EA to trade" in the EA's features. ";break;
         case 4110: res=" Long positions are not allowed. Check the EA's features. ";break;
         case 4111: res=" Short positions are not allowed. Check the EA's features. ";break;
         case 4200: res=" Object already exists. ";break;
         case 4201: res=" Unknown object property requested. ";break;
         case 4202: res=" Object does not exist. ";break;
         case 4203: res=" Unknown object type. ";break;
         case 4204: res=" No object name. ";break;
         case 4205: res=" Object coordinates error. ";break;
         case 4206: res=" The specified subwindow cannot be found. ";break;
         case 4207: res=" Error when working with the object ";break;
         case 4210: res=" Unknown chart property ";break;
         case 4211: res=" Chart not found ";break;
         case 4212: res=" Chart subwindow not found ";break;
         case 4213: res=" Indicator not found ";break;
         case 4220: res=" Instrument selection error ";break;
         case 4250: res=" Push notification sending error ";break;
         case 4251: res=" Push notification parameters error ";break;
         case 4252: res=" Notifications are not allowed ";break;
         case 4253: res=" Too many requests of sending push notifications ";break;
         case 5001: res=" Too many open files ";break;
         case 5002: res=" Wrong file name ";break;
         case 5003: res=" Too long file name ";break;
         case 5004: res=" File opening error ";break;
         case 5005: res=" Text file buffer location error ";break;
         case 5006: res=" File deleting error ";break;
         case 5007: res=" Wrong file handle (file is closed or has not been opened) ";break;
         case 5008: res=" Wrong file handle (no handle index in the table) ";break;
         case 5009: res=" The file must be opened with the FILE_WRITE flag ";break;
         case 5010: res=" The file must be opened with the FILE_READ flag ";break;
         case 5011: res=" The file must be opened with the FILE_BIN flag ";break;
         case 5012: res=" The file must be opened with the FILE_TXT flag ";break;
         case 5013: res=" The file must be opened with FILE_TXT or FILE_CSV flags ";break;
         case 5014: res=" The file must be opened with the FILE_CSV flag ";break;
         case 5015: res=" File reading error ";break;
         case 5016: res=" File writing error ";break;
         case 5017: res=" Specify string size for binary files ";break;
         case 5018: res=" Wrong file type (TXT for string arrays, BIN for other types)";break;
         case 5019: res=" File is a directory ";break;
         case 5020: res=" File does not exist ";break;
         case 5021: res=" File cannot be rewritten ";break;
         case 5022: res=" Wrong directory name ";break;
         case 5023: res=" Directory does not exist ";break;
         case 5024: res=" Specified file is not a directory ";break;
         case 5025: res=" Directory deleting error ";break;
         case 5026: res=" Directory clearing error ";break;
         case 5027: res=" Array size change error ";break;
         case 5028: res=" String size change error ";break;
         case 5029: res=" Structure contains strings or dynamic arrays ";break;
         default :  res=" Unknown error. ";
        }
     }
   else
      res= StringConcatenate(GetLastError());
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(res);
  }
//+------------------------------------------------------------------+
//| Lots                                                             |
//+------------------------------------------------------------------+
double trading:: Lots()
  {
   double res;
   if(!Lot_const)
      res=Lot;
   else
   if(Risk>0.0)
      res=(AccountBalance()/(100.0/Risk))/MarketInfo(_Symbol,MODE_MARGINREQUIRED);
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(res);
  }
//+------------------------------------------------------------------+
//| ChekPar                                                          |
//+------------------------------------------------------------------+
bool trading:: ChekPar(int tip,double oop,double osl,double otp,double op,double sl,double tp,int mod=0)
  {
   bool res=true;
   double pro=0.0,prc=0.0;
   if(MathMod(tip,2.0)==0.0)
     {pro=Ask;prc=Bid;}
   else
     {pro=Bid;prc=Ask;}
   switch(mod)
     {
      case 0:
         switch(tip)
           {
            case 0:
            if(sl>0.0 && !StopLev(prc,sl)){res=false;break;}
            if(tp>0.0 && !StopLev(tp,prc)){res=false;break;}
            break;
            case 1:
            if(sl>0.0 && !StopLev(sl,prc)){res=false;break;}
            if(tp>0.0 && !StopLev(prc,tp)){res=false;break;}
            break;
            case 2:
            if(!StopLev(pro,op)){res=false;break;}
            if(sl>0.0 && !StopLev(op,sl)){res=false;break;}
            if(tp>0.0 && !StopLev(tp,op)){res=false;break;}
            break;
            case 3:
            if(!StopLev(op,pro)){res=false;break;}
            if(sl>0.0 && !StopLev(sl,op)){res=false;break;}
            if(tp>0.0 && !StopLev(op,tp)){res=false;break;}
            break;
            case 4:
            if(!StopLev(op,pro)){res=false;break;}
            if(sl>0.0 && !StopLev(op,sl)){res=false;break;}
            if(tp>0.0 && !StopLev(tp,op)){res=false;break;}
            break;
            case 5:
            if(!StopLev(pro,op)){res=false;break;}
            if(sl>0.0 && !StopLev(sl,op)){res=false;break;}
            if(tp>0.0 && !StopLev(op,tp)){res=false;break;}
            break;
           }
         break;
      case 1:
         switch(tip)
           {
            case 0:
            if(osl>0.0 && !Freez(prc,osl)){res=false;break;}
            if(otp>0.0 && !Freez(otp,prc)){res=false;break;}
            break;
            case 1:
            if(osl>0.0 && !Freez(osl,prc)){res=false;break;}
            if(otp>0.0 && !Freez(prc,otp)){res=false;break;}
            break;
           }
         break;
      case 2:
      if(prc>oop){if(!Freez(prc,oop)){res=false;break;}}
      else{if(!Freez(oop,prc)){res=false;break;}}
      break;
      case 3:
         switch(tip)
           {
            case 0:
            if(osl>0.0 && !Freez(prc,osl)){res=false;break;}
            if(otp>0.0 && !Freez(otp,prc)){res=false;break;}
            if(sl>0.0 && !StopLev(prc,sl)){res=false;break;}
            if(tp>0.0 && !StopLev(tp,prc)){res=false;break;}
            break;
            case 1:
            if(osl>0.0 && !Freez(osl,prc)){res=false;break;}
            if(otp>0.0 && !Freez(prc,otp)){res=false;break;}
            if(sl>0.0 && !StopLev(sl,prc)){res=false;break;}
            if(tp>0.0 && !StopLev(prc,tp)){res=false;break;}
            break;
            case 2:
            if(sl>0.0 && !StopLev(op,sl)){res=false;break;}
            if(tp>0.0 && !StopLev(tp,op)){res=false;break;}
            if(!StopLev(pro,op) || !Freez(pro,op)){res=false;break;}
            break;
            case 3:
            if(sl>0.0 && !StopLev(sl,op)){res=false;break;}
            if(tp>0.0 && !StopLev(op,tp)){res=false;break;}
            if(!StopLev(op,pro) || !Freez(op,pro)){res=false;break;}
            break;
            case 4:
            if(sl>0.0 && !StopLev(op,sl)){res=false;break;}
            if(tp>0.0 && !StopLev(tp,op)){res=false;break;}
            if(!StopLev(op,pro) || !Freez(op,pro)){res=false;break;}
            break;
            case 5:
            if(sl>0.0 && !StopLev(sl,op)){res=false;break;}
            if(tp>0.0 && !StopLev(op,tp)){res=false;break;}
            if(!StopLev(pro,op) || !Freez(pro,op)){res=false;break;}
            break;
           }
         break;
     }
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(res);
  }
//+------------------------------------------------------------------+
//| StopLev                                                          |
//+------------------------------------------------------------------+
bool trading:: StopLev(double pr1,double pr2)
  {
   bool res=true;
   long par=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   if(long(MathCeil((pr1-pr2)/Point))<=par)res=false;
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(res);
  }
//+------------------------------------------------------------------+
//| Freez                                                            |
//+------------------------------------------------------------------+
bool trading:: Freez(double pr1,double pr2)
  {
   bool res=true;
   long par=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   if(long(MathCeil((pr1-pr2)/Point))<=par)res=false;
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(res);
  }
//+------------------------------------------------------------------+
//| StrTip                                                           |
//+------------------------------------------------------------------+
string trading:: StrTip(int tip)
  {
   string name;
   switch(tip)
     {
      case 1:name=" Sell ";
      break;
      case 2:name=" BuyLimit ";
      break;
      case 3:name=" SellLimit ";
      break;
      case 4:name=" BuyStop ";
      break;
      case 5:name=" SellStop ";
      break;default:name=" Buy ";
     }
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(name);
  }
//+------------------------------------------------------------------+
//| Err                                                              |
//+------------------------------------------------------------------+
void trading:: Err(int id)
  {
   if(id==6 || id==129 || id==130 || id==136)
      Sleep(5000);
   if(id==128 || id==142 || id==143 || id==4 || id==132)
      Sleep(60000);
   if(id==145)
      Sleep(15000);
   if(id==146)
      Sleep(10000);
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
  }
//+------------------------------------------------------------------+
//| FreeM                                                            |
//+------------------------------------------------------------------+
bool trading:: FreeM(double lot)
  {
   bool res=true;
   if(lot*SymbolInfoDouble(_Symbol,SYMBOL_MARGIN_INITIAL)>AccountFreeMargin())
      res=false;
   if(!res)
      Alert("Not enough money to open a position");
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(res);
  }
//+------------------------------------------------------------------+
//| Dig                                                              |
//+------------------------------------------------------------------+
int trading:: Dig()
  {
   int dig;
   if(_Digits==5 || _Digits==3 || _Digits==1)
      dig=10;
   else
      dig=1;
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(dig);
  }
//+------------------------------------------------------------------+
