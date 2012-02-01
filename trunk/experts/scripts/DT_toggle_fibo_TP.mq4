//+------------------------------------------------------------------+
//|                                            DT_toggle_fibo_TP.mq4 |
//|                                                              Dex |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dex"
#property link      ""

#include <DT_defaults.mqh>
#include <DT_functions.mqh>
#include <DT_comments.mqh>
#include <DT_icons.mqh>
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start(){
  
  if(ObjectFind("DT_GO_FiboLines_RECT_lv0") == -1){  
    addComment("There is no fibo lines!",1);  
    return (0);
  }
  
  for(int i=FIBO_LV_NR-1;i>1;i--){
    if(ObjectGet("DT_GO_FiboLines_RECT_lv"+i,OBJPROP_TIMEFRAMES) != -1){
      ObjectSet("DT_GO_FiboLines_RECT_lv"+i,OBJPROP_TIMEFRAMES,-1);
      i=i-1;
      if(i == 0){i = 6;}
      addComment("The new Take Profit is "+ObjectDescription("DT_GO_FiboLines_RECT_lv"+i));
      return (0);
    }
  }
  for(i=FIBO_LV_NR-1;i>1;i--){
    ObjectSet("DT_GO_FiboLines_RECT_lv"+i,OBJPROP_TIMEFRAMES,OBJ_PERIOD_M1|OBJ_PERIOD_M5|OBJ_PERIOD_M15|OBJ_PERIOD_M30|OBJ_PERIOD_H1|OBJ_PERIOD_H4);
  }
  addComment("The new Take Profit is "+ObjectDescription("DT_GO_FiboLines_RECT_lv6"));
  return(0);
}