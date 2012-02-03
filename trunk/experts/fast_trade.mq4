//+------------------------------------------------------------------+
//|                                                   fast_trade.mq4 |
//|                                                              Dex |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dex"
#property link      ""

#include <DT_defaults.mqh>
#include <DT_icons.mqh>
#include <DT_comments.mqh>
#include <DT_functions.mqh>

#define INTERVAL 20
//#define OPEN_POS 0.00350
//#define ENTER 0.00400
#define OPEN_POS 0.00070
#define ENTER 0.00120
#define TP 0.00060
#define SL 0.00070

//#define TP 0.00160
//#define SL 0.00170
//#define POS_EXPIRE 620
#define POS_EXPIRE 700
#define LOTS 0.1

double FT_SPREAD = 0.0;

int init(){
  FT_SPREAD = getMySpread();
  return(0);
}

int start(){
  bool has_pos = selectFirstOpenPosition(Symbol());
  int last_pos_idx, interval;
  double lowest, highest, h, l;
Alert(OrderTicket()+" zz "+OrderMagicNumber());
 
  if(!has_pos || OrderMagicNumber() != 11){
    h = iHigh( NULL, PERIOD_M1, 0);
    l = iLow( NULL, PERIOD_M1, 0);
    
    last_pos_idx = iBarShift(NULL, PERIOD_M1, selectLastPositionTime(Symbol()));
    if(last_pos_idx < INTERVAL){
      interval = last_pos_idx;      
    }else{
      interval = INTERVAL;
    }
        
    if(interval > 1){
      lowest = getLowest(interval);
      highest = getHighest(interval);
         
      Alert("interval:"+ interval+" lowest: "+lowest+" highest: "+highest+" dif(h-lowest): "+(h-lowest)+" dif(highest-l): "+(highest-l));
      if( lowest+OPEN_POS < h && lowest+ENTER > h ){
        Print(StringConcatenate("Open Fast Trade pos becouse: h:",h, " lowest: ",lowest, " Diff: ", h-lowest," bigger than ",OPEN_POS," interval: ",interval));
        order(OP_BUYSTOP, NormalizeDouble(lowest+ENTER+FT_SPREAD, Digits), NormalizeDouble(lowest+ENTER-SL, Digits), NormalizeDouble(lowest+ENTER+TP, Digits));
      
        ObjectSet("from", OBJPROP_PRICE1, lowest);
      }else if(highest-OPEN_POS > l && highest-ENTER < l){
        Print(StringConcatenate("Open Fast Trade pos becouse: highest:",highest, " l: ",l, " Diff: ", highest-l," bigger than ",OPEN_POS," interval: ",interval));
        order(OP_SELLSTOP, NormalizeDouble(highest-ENTER, Digits), NormalizeDouble(highest-ENTER+SL-FT_SPREAD, Digits), NormalizeDouble(highest-ENTER-TP-FT_SPREAD, Digits) );
      
        ObjectSet("from", OBJPROP_PRICE1, highest);
      }
    }
  }

  return(0);
}
int deinit(){
  return(0);
}

bool order(int type, double op, double sl, double tp){
  int i = 0, ticket;
  //while(i < 3){
    //ticket = OrderSend(Symbol(),type,0.1,op,5,sl,tp, "xxx",11);
    ticket = OrderSend(Symbol(),type,0.1,op,5,sl,tp, ""+TimeCurrent(),11,TimeCurrent()+POS_EXPIRE);
    
    ObjectSet("tp", OBJPROP_PRICE1, tp);
    ObjectSet("op", OBJPROP_PRICE1, op);
    ObjectSet("sl", OBJPROP_PRICE1, sl);    
    
    if (ticket >=0){
      Print(StringConcatenate("Open nr: ",ticket," position at ", TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS), " type: ",type," lot: ",LOTS," OP: ",op, " SL: ",sl," TP: ",tp, " EXP: ",POS_EXPIRE," Bid: ",Bid," ASK: ",Ask));
      Alert(StringConcatenate("Open nr: ",ticket," position at ", TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS), " type: ",type," lot: ",LOTS," OP: ",op, " SL: ",sl," TP: ",tp, " EXP: ",POS_EXPIRE," Bid: ",Bid," ASK: ",Ask));
      //break;
    }else{
      Print(StringConcatenate(i,". FAIL open position at ", TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS), " type: ",type," lot: ",LOTS," OP: ",op, " SL: ",sl," TP: ",tp, " EXP: ",POS_EXPIRE," Bid: ",Bid," ASK: ",Ask));
      Alert(StringConcatenate("Open nr: ",ticket," position at ", TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS), " type: ",type," lot: ",LOTS," OP: ",op, " SL: ",sl," TP: ",tp, " EXP: ",POS_EXPIRE," Bid: ",Bid," ASK: ",Ask));
      errorCheck("Fast trade");
      //i++;
      //Sleep(1000);
    }        
  //}
}

double getLowest(int interval){
  double result = 999999;
  for(int i = 0; i < interval; i++){
    result = MathMin(result, iLow(Symbol(),PERIOD_M1,i));
  }
  return (result);
}

double getHighest(int interval){
  double result = 0;
  for(int i = 0; i < interval; i++){
    result = MathMax(result, iHigh(Symbol(),PERIOD_M1,i));
  }
  return (result);
}