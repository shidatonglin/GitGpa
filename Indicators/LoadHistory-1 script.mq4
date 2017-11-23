//+------------------------------------------------------------------+
//|                                                 LoadHistory.mq4
//|                                          Copyright 2012, K Lam
//+------------------------------------------------------------------+
//
//verison 2 fix the timeframe H1 is not funcation

#property copyright "Copyright 2010, K Lam"
#property link      "FXKill.U"

#define Version  20120106

#import "kernel32.dll"
   int _lopen  (string path, int of);
   int _llseek (int handle, int offset, int origin);
   int _lread  (int handle, string buffer, int bytes);
   int _lclose (int handle);
#import
#import "user32.dll"
   int GetAncestor (int hWnd, int gaFlags);
   int GetParent (int hWnd);
   int GetDlgItem (int hDlg, int nIDDlgItem);
   int SendMessageA (int hWnd, int Msg, int wParam, int lParam);
   int PostMessageA (int hWnd, int Msg, int wParam, int lParam);
#import

#define LVM_GETITEMCOUNT   0x1004

#define WM_SCROLL          0x80F9
#define WM_COMMAND         0x0111
#define WM_KEYUP           0x0101
#define WM_KEYDOWN         0x0100
#define WM_CLOSE           0x0010

#define VK_PGUP            0x21
#define VK_PGDN            0x22
#define VK_HOME            0x24
#define VK_END             0x23
#define VK_DOWN            0x28
#define VK_PLUS            0xBB
#define VK_MINUS           0xBD

int nsymb;
int LastPage=0;  //0 to close all not 0 then will leave the page open at last time frame
int Pause=500;               //Wait 500= 0.5 scend
int KeyHome=300;
int HomeLoop=500;
string Symbols[];

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void start() {
//--------------------------------------------------------------------
   if(GlobalVariableCheck("glSymbolHandle")) {
      GlobalVariableSet("glSymbolHandle",WindowHandle(Symbol(),Period()));
      return;
   }
   
   MarketInfoToSymbols();
   DownloadHomeKey();
   return;
}


//+------------------------------------------------------------------+
//| MarketInfoToSymbols()                                            |
//+------------------------------------------------------------------+
void MarketInfoToSymbols() {
   int i,handle,handleset,size;
   string symb="symbols     ",path;
   
   path=StringConcatenate(TerminalPath(),"\\history\\",AccountServer(),"\\symbols.sel");//\\symbols.raw"
   handle=_lopen(path,0);
   
   if(handle<0) {
      Print("Error Loding file symbols.sel : ",GetLastError());
      return;
   }
   
   handleset=FileOpen("quoting.set",FILE_READ | FILE_WRITE);
   
   if(handleset<0) {
      Print("Error Creating file quoting.set : ",GetLastError());
      return;
   }
   
   size=128;//size=1936;
   nsymb=_llseek(handle,0,2)/size; //_llseek(handle,i*size,0);
   for(i=0;i<nsymb;i++){
      _llseek(handle,4+(i*size),0);
      _lread(handle,symb,12);
      FileWrite(handleset,symb);
      }
      
   _lclose(handle);                                                  //close symbols.sel
   
   if(!FileSeek(handleset,0,SEEK_SET)) {
      Print("Error Seeking file quoting.set : ",GetLastError());
   }
   ArrayResize(Symbols,nsymb+1);
   
   for(i=1;i<=nsymb;i++){//for(i=0;i<nsymb;i++){
      Symbols[i]=FileReadString(handleset);
   }
   
   FileClose(handleset);
   FileDelete("quoting.set");
   return;
}

//+------------------------------------------------------------------+
//| DownloadHomeKey()                                                |
//+------------------------------------------------------------------+
void DownloadHomeKey() {
   int i,j,k,l,hmain,handle,handlechart,count,num;
   int tf[9]={1,5,15,30,60,240,1440,10080,43200};
   int TimeF[9]={33137,33138,33139,33140,35400,33136,33134,33141,33334};       
   int PreXBars,PreBars,CurrBars;
   
   GlobalVariableSet("glSymbolHandle",WindowHandle(Symbol(),Period()));
   hmain=GetAncestor(WindowHandle(Symbol(),Period()),2);
   if (hmain!=0) {
      handle=GetDlgItem(hmain,0xE81C);
      handle=GetDlgItem(handle,0x50);
      handle=GetDlgItem(handle,0x8A71);
      count=SendMessageA(handle,LVM_GETITEMCOUNT,0,0);
      } else Print("Error :",GetLastError());

   for(i=1;i<=count&&!IsStopped();i++) {
      OpenChart(i,hmain);
      Sleep(Pause);
      PostMessageA(hmain,WM_COMMAND,33042,0);
      Sleep(Pause);
      handlechart=GlobalVariableGet("glSymbolHandle");
      PostMessageA(handlechart, WM_KEYDOWN, VK_MINUS,0);//Pass - Key
      for (j=0;j<10&&!IsStopped();j++) {
         PostMessageA(handlechart,WM_COMMAND,TimeF[j],0);
         PostMessageA(handlechart,WM_COMMAND,WM_SCROLL,0);
         k=0;
         PreXBars=iBars(Symbols[i],tf[j]);
         if(PreXBars==0) {//wait the the new chat coming
            for(l=0;l<HomeLoop*100;l++) {
               Sleep(10);
               if(iBars(Symbols[i],tf[j])>0) break;}
            }
         
         
         for(l=0;l<HomeLoop;l++) {
            PostMessageA(handlechart, WM_KEYDOWN, VK_HOME,0);//Pass HOME Key
            Sleep(KeyHome);
            PostMessageA(handlechart, WM_KEYDOWN, VK_HOME,0);
            Sleep(KeyHome);
            //PostMessageA(handlechart, WM_KEYDOWN, VK_END,0);
            //Sleep(100);
            PostMessageA(handlechart,WM_COMMAND,33324,0);//Refresh
            Sleep(KeyHome);

            CurrBars=iBars(Symbols[i],tf[j]);
            
            if(PreBars!=CurrBars) {
               k=0;
               PreBars=CurrBars;
               //Print(Symbols[i]," Timeframe =",tf[j]," PreBars=",PreBars," CurrBars=",CurrBars," Bars=",iBars(Symbols[i],tf[j]));
               } else k++;
            if(k>5) break; //if 4 time is same then break
            
            PostMessageA(handlechart, WM_KEYDOWN, VK_END,0);//Sleep(100);
         }
         
         Print(Symbols[i]," Timeframe ",tf[j]," Pre Bars=",PreXBars," Now Bars=",iBars(Symbols[i],tf[j]));
         PostMessageA(handlechart,WM_COMMAND,WM_SCROLL,0);
         PostMessageA(handlechart,WM_COMMAND,33324,0);//Refresh 
         Sleep(Pause);
      }
      
         switch(LastPage) {
            case 1: PostMessageA(handlechart,WM_COMMAND,TimeF[0],0); break;
            case 5: PostMessageA(handlechart,WM_COMMAND,TimeF[1],0); break;
            case 15: PostMessageA(handlechart,WM_COMMAND,TimeF[2],0); break;
            case 30: PostMessageA(handlechart,WM_COMMAND,TimeF[3],0); break;
            case 60: PostMessageA(handlechart,WM_COMMAND,TimeF[4],0); break;
            case 240: PostMessageA(handlechart,WM_COMMAND,TimeF[5],0); break;
            case 1440: PostMessageA(handlechart,WM_COMMAND,TimeF[6],0); break;
            case 10080: PostMessageA(handlechart,WM_COMMAND,TimeF[7],0); break;
            case 43200: PostMessageA(handlechart,WM_COMMAND,TimeF[8],0); break;
            case 0: PostMessageA(GetParent(handlechart),WM_CLOSE,0,0); break;
            default: PostMessageA(handlechart,WM_COMMAND,TimeF[4],0); break;
            }
         Sleep(Pause);

   }
   
   GlobalVariableDel("glSymbolHandle");
   return;
}

//+------------------------------------------------------------------+
void OpenChart(int Num, int handle) {
   int hwnd;
   hwnd=GetDlgItem(handle,0xE81C); 
   hwnd=GetDlgItem(hwnd,0x50);
   hwnd=GetDlgItem(hwnd,0x8A71);
   PostMessageA(hwnd,WM_KEYDOWN,VK_HOME,0);
   while(Num>1) {
      PostMessageA(hwnd,WM_KEYDOWN,VK_DOWN,0);
      Num--;
   }
   PostMessageA(handle,WM_COMMAND,33160,0);
   return;
}
//+------------------------------------------------------------------+