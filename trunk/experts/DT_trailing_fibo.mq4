//+------------------------------------------------------------------+
//|                                             DT_trailing_fibo.mq4 |
//|                                                              Dex |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dex"
#property link      ""
#include <DT_defaults.mqh>
#include <DT_functions.mqh>
#include <DT_fibo_lines.mqh>

int TF_TIMER = 0;
bool GOT_ERROR = false;

int init(){
  return(0);
}

int deinit(){
  return(0);
}

int start(){
  if(GetTickCount()>TF_TIMER){
    TF_TIMER = GetTickCount()+ 7000;

    if(ObjectFind("DT_GO_FiboLines_FIBO_BASE") == -1){
      if(!GOT_ERROR){
        Alert("There is no DT Fibo!");
        GOT_ERROR = true;
      }
      return (0);
    }
    if(!selectFirstOpenPosition(Symbol())){
      if(!GOT_ERROR){
        Alert("There is no open position in "+Symbol()+"!");
        GOT_ERROR = true;
      }
      return (0);
    }
    GOT_ERROR = false;

    int ticket_id = OrderTicket();
    double cur_y1 = ObjectGet("DT_GO_FiboLines_FIBO_BASE", OBJPROP_PRICE1);
    double cur_y2 = ObjectGet("DT_GO_FiboLines_FIBO_BASE", OBJPROP_PRICE2);

    double tp, op, sl;
    sl = NormalizeDouble(OrderStopLoss(), Digits);
    double spread;
    int i;

    if(OrderType()<2){
      tp = NormalizeDouble(OrderTakeProfit(), Digits);
      op = NormalizeDouble(OrderOpenPrice(), Digits);

      if(cur_y2-cur_y1>0){    //Sell
        spread = getMySpread();
        for(i = FIBO_LV_NR-1; i > 0; i--){
          if(ObjectGet("DT_GO_FiboLines_RECT_lv"+i,OBJPROP_TIMEFRAMES) != -1 && Low[0] < ObjectGet("DT_GO_FiboLines_RECT_lv"+i,OBJPROP_PRICE2) && sl > NormalizeDouble(ObjectGet("DT_GO_FiboLines_RECT_lv"+i, OBJPROP_PRICE1), Digits)+spread){
            Alert(ticket_id+" "+op+" "+NormalizeDouble(ObjectGet("DT_GO_FiboLines_RECT_lv"+i, OBJPROP_PRICE1), Digits)+spread+" "+tp);
            OrderModify(ticket_id, op, NormalizeDouble(ObjectGet("DT_GO_FiboLines_RECT_lv"+i, OBJPROP_PRICE1), Digits)+spread, tp, 0);
          }
        }
      }else{                 //Buy
        for(i = FIBO_LV_NR-1; i > 0; i--){
          if(ObjectGet("DT_GO_FiboLines_RECT_lv"+i,OBJPROP_TIMEFRAMES) != -1 && High[0] > ObjectGet("DT_GO_FiboLines_RECT_lv"+i,OBJPROP_PRICE2) && sl < NormalizeDouble(ObjectGet("DT_GO_FiboLines_RECT_lv"+i, OBJPROP_PRICE1), Digits)){
            Alert(ticket_id+" "+op+" "+NormalizeDouble(ObjectGet("DT_GO_FiboLines_RECT_lv"+i, OBJPROP_PRICE1), Digits)+" "+tp);
            OrderModify(ticket_id, op, NormalizeDouble(ObjectGet("DT_GO_FiboLines_RECT_lv"+i, OBJPROP_PRICE1), Digits), tp, 0);
          }
        }
      }
      errorCheck("OrderModify");

    }else{
      spread = getMySpread();
      double exp = TimeCurrent()+10000;
      if(cur_y2-cur_y1>0){    //Sell
        if(High[0] > cur_y2){
          ObjectSet("DT_GO_FiboLines_FIBO_BASE", OBJPROP_PRICE2, High[0]);
          if(updateFibo()){
            getTPLevel(tp);
            op = NormalizeDouble(ObjectGet("DT_GO_FiboLines_RECT_lv0", OBJPROP_PRICE2), Digits);
            sl = NormalizeDouble(ObjectGet("DT_GO_FiboLines_RECT_lv0", OBJPROP_PRICE1), Digits);
            Alert(ticket_id+" "+op+" "+sl+" "+tp+" "+exp);
            OrderModify(ticket_id, op, sl+spread, tp+spread, exp);
          }
        }
      }else{                  //Buy
        if(Low[0] < cur_y2){
          ObjectSet("DT_GO_FiboLines_FIBO_BASE", OBJPROP_PRICE2, Low[0]);
          if(updateFibo()){
            getTPLevel(tp);
            op = NormalizeDouble(ObjectGet("DT_GO_FiboLines_RECT_lv0", OBJPROP_PRICE2), Digits);
            sl = NormalizeDouble(ObjectGet("DT_GO_FiboLines_RECT_lv0", OBJPROP_PRICE1), Digits);
            Alert(ticket_id+" "+op+spread+" "+sl+" "+tp+" "+exp);
            OrderModify(ticket_id, op+spread, sl, tp, exp);
          }
        }
      }
    }
  }
  return (errorCheck("trailing_fibo start"));
}

