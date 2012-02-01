//+------------------------------------------------------------------+
//|                                        DT_toggle_custom_fibo.mq4 |
//|                                                              Dex |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dex"
#property link      ""

#include <DT_defaults.mqh>
#include <DT_functions.mqh>
#include <DT_comments.mqh>
#include <DT_fibo_lines.mqh>
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start(){
  
  if(ObjectFind("DT_GO_FiboLines_FIBO_BASE") == -1){
    addComment("There is no fibo lines!",1);
    return (0);
  }
  
  double base_y1 = ObjectGet("DT_GO_FiboLines_FIBO_BASE",OBJPROP_PRICE1);
  double base_y2 = ObjectGet("DT_GO_FiboLines_FIBO_BASE",OBJPROP_PRICE2);
  string fibo; 
  bool has_change = false;
  
  for(int i=0;i<6;i++){
    if(ObjectGet("DT_GO_FiboLines_"+i,OBJPROP_PRICE1) != ObjectGet("DT_GO_FiboLines_"+i+"_label",OBJPROP_PRICE1)){
      fibo = DoubleToStr((ObjectGet("DT_GO_FiboLines_"+i,OBJPROP_PRICE1)-base_y2)/(base_y1-base_y2),3);
      ObjectSetText("DT_GO_FiboLines_"+i,fibo);      
      addComment("Change "+LINE_FIBOS_STR[i]+" fibo to "+fibo);
      has_change = true;      
    }
  }
  if(has_change){
    updateFibo();
  }
  
  return(0);
}