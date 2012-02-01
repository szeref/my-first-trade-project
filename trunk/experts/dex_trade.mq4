//+------------------------------------------------------------------+
//|                                                    dex_trade.mq4 |
//|                                                              Dex |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dex"
#property link      ""

string SYMBOLS[19] = {"EURUSD-Pro","USDJPY-Pro","AUDUSD-Pro","EURAUD-Pro","USDCAD-Pro","USDCHF-Pro","EURJPY-Pro","GBPUSD-Pro","CHFJPY-Pro","AUDJPY-Pro","CADJPY-Pro","NZDJPY-Pro","AUDCHF-Pro","NZDUSD-Pro","GBPJPY-Pro","EURGBP-Pro","AUDCAD-Pro","GBPAUD-Pro","EURCHF-Pro"};
string SHORT_SYMBOLS[19] = {"EURUSD","USDJPY","AUDUSD","EURAUD","USDCAD","USDCHF","EURJPY","GBPUSD","CHFJPY","AUDJPY","CADJPY","NZDJPY","AUDCHF","NZDUSD","GBPJPY","EURGBP","AUDCAD","GBPAUD","EURCHF"};
int CURR_RSI[19];

int TIME_FRAME = PERIOD_H1;
datetime CUR_TIME = 0;
int REFRESH_TIME = 10;


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init(){
   showInfo(true);
   saveDataToFile();
  //Alert();
     
   return(0);

}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit(){
   removeAllObject();
   return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start(){
   
   
 

   saveDataToFile();
   showInfo();
   return(0);
}
//+------------------------------------------------------------------+

void showInfo(bool init = false){
   if(init){
      ObjectCreate("DT_spread_info", OBJ_LABEL, 0, 0, 0);
      ObjectSet("DT_spread_info", OBJPROP_CORNER, 0);
      ObjectSet("DT_spread_info", OBJPROP_XDISTANCE, 5);
      ObjectSet("DT_spread_info", OBJPROP_YDISTANCE, 15);
      
     /* ObjectCreate("DT_label_2", OBJ_LABEL, 0, 0, 0);
      ObjectSet("DT_label_2", OBJPROP_CORNER, 0);
      ObjectSet("DT_label_2", OBJPROP_XDISTANCE, 5);
      ObjectSet("DT_label_2", OBJPROP_YDISTANCE, 28);   */
   }
   ObjectSetText("DT_spread_info","Spread: "+DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD),0),8,"Arial","blue");
  // ObjectSetText("DT_label_2","Spread: "+DoubleToStr(MarketInfo(Symbol(),MODE_FREEZELEVEL),0),8,"Arial","blue");
}

void removeAllObject(){
   int obj_total= ObjectsTotal();   
   for (int j= obj_total-1; j>=0; j--) {
      string name= ObjectName(j);  
      if (StringSubstr(name,0,3)=="DT_") 
         ObjectDelete(name);
   }   
}

void saveDataToFile(){
// return;
   if(TimeCurrent()<CUR_TIME+REFRESH_TIME){
      return;
   }

   int i = 0;
   int len = ArraySize(SYMBOLS);
   int rsi_tmp;
   bool need_write = false;
   string out = "", direction = "";
   double iMA_curr, iMA_prev;

   for(; i<len; i=i+1){
      rsi_tmp = iRSI(SYMBOLS[i],TIME_FRAME, 10, 0, 0);
      
      if(CURR_RSI[i] != rsi_tmp){      
         CURR_RSI[i] = rsi_tmp;         
         need_write = true;         
      }
      
      iMA_curr = iMA(SYMBOLS[i], TIME_FRAME, 2, 0, MODE_SMA, 0, 0);
      iMA_prev = iMA(SYMBOLS[i], TIME_FRAME, 2, 1, MODE_SMA, 0, 0);
      
      if(iMA_curr-iMA_prev>0){
         direction = "up";
      }else{
         direction = "down";
      }
      
      out = out+SHORT_SYMBOLS[i]+" "+CURR_RSI[i]+" "+direction+"\r\n";      
   }
   
   if(need_write){
      int handle;   
      handle=FileOpen("result.bin", FILE_BIN|FILE_WRITE);
        if(handle<1){
         Print("can't open file error-",GetLastError());
         return(0);
        }
      FileWriteString(handle, out, StringLen(out));
      FileClose(handle); 
      
      Alert(TimeCurrent());  
   }

   CUR_TIME = TimeCurrent();
}