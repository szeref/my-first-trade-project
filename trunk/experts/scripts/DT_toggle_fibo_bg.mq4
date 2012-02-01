//+------------------------------------------------------------------+
//|                                            DT_toggle_fibo_bg.mq4 |
//|                                                              Dex |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dex"
#property link      ""

#include <DT_defaults.mqh>
#include <DT_functions.mqh>
#include <DT_comments.mqh>
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start(){
  
  if(ObjectFind("DT_GO_FiboLines_RECT_lv0") == -1){
    addComment("There is no fibo lines!",1);  
    return (0);
  }
  bool status = !(ObjectGet("DT_GO_FiboLines_RECT_lv0",OBJPROP_BACK));
  for(int i=0;i<7;i++){
    ObjectSet(StringConcatenate("DT_GO_FiboLines_RECT_lv",i), OBJPROP_BACK, status);
  }
  if(status){
    addComment("Switch Fibo background to ON.");
  }else{
    addComment("Switch Fibo background to OFF.");
  }
  return(0);
}