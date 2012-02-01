//+------------------------------------------------------------------+
//|                                                DT_fibo_trade.mq4 |
//|                                                              Dex |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dex"
#property link      ""

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
#include <DT_defaults.mqh>
#include <DT_functions.mqh>
#include <WinUser32.mqh>

int start(){
  if(ObjectFind("DT_GO_FiboLines_RECT_lv0") != -1 && ObjectFind("DT_GO_FiboLines_RECT_lv4") != -1){
    int i = 0, type, ticket;  
    string tp_text;
    double tp;
    
    tp_text = getTPLevel(tp);
    double sl = NormalizeDouble(ObjectGet("DT_GO_FiboLines_RECT_lv0", OBJPROP_PRICE1), Digits);
    double op = NormalizeDouble(ObjectGet("DT_GO_FiboLines_RECT_lv0", OBJPROP_PRICE2), Digits);
    string type_text;
    double lots = StrToDouble(getGlobal("LOT"));
    double spread = getMySpread();
    
    RefreshRates();
    if(tp > sl){
      type = OP_BUYSTOP;
      type_text = "BUY STOP";
      op = op + spread;
    }else{
      type = OP_SELLSTOP;
      type_text = "SELL STOP";
      sl = sl + spread;
      tp = tp + spread;
      
    }
    int result = MessageBox(StringConcatenate("Are you should want a ",type_text," trade with ",DoubleToStr(lots,2)," lots? ( TP: ",tp_text," )"), "Fibo trading", MB_YESNO|MB_ICONQUESTION );
    if(result == IDYES){
      while(i < 5){
        ticket = OrderSend(Symbol(),type,lots,op,2,sl,tp, ""+TimeCurrent(),333,TimeCurrent()+10000);    
    
        if (ticket >=0){
          break;
        }else{
          errorCheck("initTradeLines");
          i++;
          Sleep(1400);
        }        
      }
    }
    
  }else{
    Alert("Fibo is missing!");
  } 
  
  return(0);
}

