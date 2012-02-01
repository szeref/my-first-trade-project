//+------------------------------------------------------------------+
//|                                                DT_reset_fibo.mq4 |
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
  for(int i=0;i<6;i++){
    ObjectSetText("DT_GO_FiboLines_"+i,LINE_FIBOS_STR[i]); 
  }
  addComment("Reset fibo lines.");
  updateFibo();
}



