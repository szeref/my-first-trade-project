//+------------------------------------------------------------------+
//|                                                   DT_archive.mq4 |
//|                                                              Dex |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dex"
#property link      ""
datetime histDates[0];

bool initArchive(string isOn){
  setAppStatus(APP_ID_ARCHIVE, isOn);
  
  if(isOn == "0"){        
    return (false);    
  }
  
  deInitArchive();

  int idx = 0, len = OrdersHistoryTotal();
  
  if(len==0){
    addComment("Nincs pozici� a megadott history intervallumban!",1);
    //return (false);
  }
  
  for(int i = 0; i < len; i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && Symbol() == OrderSymbol() && OrderProfit() != 0){     
      addHistoryPosition(OrderTicket(), OrderOpenTime(), OrderCloseTime(), OrderOpenPrice(), OrderStopLoss(), OrderTakeProfit(), OrderClosePrice(), OrderProfit(), OrderComment(), OrderCommission(), OrderLots(), OrderSwap(), OrderType());          
      ArrayResize(histDates, idx+1);
      histDates[idx] = OrderOpenTime();
      idx++;
    }
  }
  
  ObjectCreate("DT_BO_archive_hud", OBJ_LABEL, 0, 0, 0);
  ObjectSet("DT_BO_archive_hud", OBJPROP_CORNER, 0);
  ObjectSet("DT_BO_archive_hud", OBJPROP_XDISTANCE, 3);
  ObjectSet("DT_BO_archive_hud", OBJPROP_YDISTANCE, 45);
  ObjectSet("DT_BO_archive_hud", OBJPROP_BACK, true);
  
  return (errorCheck("initArchive"));
}

bool startArchive(string isOn){
  if(isAppStatusChanged(APP_ID_ARCHIVE, isOn)){
    if(isOn == "1"){
      initArchive("1");
    }else{
      deInitArchive();
      return (false);
    }    
  }
  if(isOn == "0"){return (false);}
	if(delayTimer(APP_ID_ARCHIVE, 1000)){return (false);}
  
 /* if(ObjectFind("DT_BO_archive_hud") == -1){
    initArchive(isOn);
    return (false);
  }*/
  
  double curr_time = Time[WindowFirstVisibleBar()];
  int len = ArraySize(histDates), pos_left = 0;
  string text;
  for(int i = 0; i < len; i++) {
    if(histDates[i] < curr_time){
      pos_left++;
    }
  }
  text = "<<< "+pos_left+"  |  "+(len-pos_left)+" >>>";
  ObjectSetText("DT_BO_archive_hud",text,10,"Arial",Black);
  return (errorCheck("startArchive"));
}

bool deInitArchive(){
  removeObjects("archive");
  return (errorCheck("deInitArchive"));
}

bool addHistoryPosition(int ticket, datetime open_time, datetime close_time, double open_price, double sl, double tp, double close_price, double profit, string comment, double commission, double lots, double swap , int type){
  string name = "DT_BO_archive_"+ticket;
  string text = "profit: "+DoubleToStr(profit,2)+"  lot: "+DoubleToStr(lots,2)+"  com: "+DoubleToStr(commission,2)+"  swap: "+DoubleToStr(swap,2);
  createTrendLine("DT_BO_archive_p_"+ticket, open_price, open_time, close_time, Black, text);
  createTrendLine("DT_BO_archive_sl_"+ticket, sl, open_time, close_time, Red, text);
  createTrendLine("DT_BO_archive_tp_"+ticket, tp, open_time, close_time, Blue, text);
  
  int result;
  color result_c;
  if(profit > 0){
    result = 74;
    result_c = DarkGreen;
  }else{
    result = 76;
    result_c = Red;
  }
  
  createArrow("DT_BO_archive_result_"+ticket, open_time-(Period()*120), MathMax(sl,tp), result_c, result, 5, text );
  
  createRectangle("DT_BO_archive_move_"+ticket, open_time, open_price, close_time, close_price, type, text);
  return (errorCheck("addHistoryPosition"));
}

bool createTrendLine(string name, double y, double x1, double x2, color c, string text = ""){
  double offset = WindowBarsPerChart()*Period()*60/8;
  x1 = x1-offset;
  x2 = x2+offset;
  
  ObjectCreate(name, OBJ_TREND, 0, x1, y, x2, y);
	ObjectSet(name, OBJPROP_COLOR, c);             
	ObjectSet(name, OBJPROP_RAY, false);
	ObjectSet(name, OBJPROP_STYLE, 4);
	ObjectSet(name, OBJPROP_BACK, true);
	ObjectSetText(name, text, 8);
}

bool createArrow(string name, double x, double y, color c, int style, int width, string text = ""){
  ObjectCreate(name, OBJ_ARROW, 0, x, y);
	ObjectSet(name, OBJPROP_COLOR, c);             
	ObjectSet(name, OBJPROP_WIDTH, width);
	ObjectSet(name, OBJPROP_ARROWCODE, style);
	ObjectSetText(name, text, 8);
}

bool createRectangle(string name, double x1, double y1, double x2, double y2, int type, string text = ""){
  color c;
  if(type == 1){
    c = Pink;
  }else{
    c = LightBlue;
  }
  x1 = x1-(Period()*30);
  x2 = x2+(Period()*30);
  ObjectCreate(name, OBJ_RECTANGLE, 0, x1, y1, x2, y2);
  ObjectSet(name, OBJPROP_BACK, true);
  ObjectSet(name, OBJPROP_COLOR,c);
	ObjectSetText(name, text, 8);
}