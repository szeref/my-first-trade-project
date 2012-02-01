//+------------------------------------------------------------------+
//|                                                   volatility.mq4 |
//|                                                              Dex |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dex"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 1 

#property indicator_minimum 0

double Buf_0[]; 
double CURR_BUF = 0;

int init(){
  SetIndexBuffer(0,Buf_0);
  SetIndexStyle (0,DRAW_HISTOGRAM,0,2,LightBlue); 
  CURR_BUF = 0;
  return(0);
}

int deinit(){
  ObjectDelete("Volatility_hud");
  return(0);
}

int start(){ 
  int i, Counted_bars; 
  
  Counted_bars = IndicatorCounted();
  i=Bars-Counted_bars-1; 
  
  while(i>=0) {    
    Buf_0[i]=((High[i]-MathMax(Open[i],Close[i]))+(MathMin(Open[i],Close[i])-Low[i]))*MathPow(10,Digits);    
    i--;
  }
  if(Buf_0[1] != CURR_BUF){
    double all = 0;
    int len = WindowBarsPerChart();
    for(i = 0; i<len; i++){
      all = all+Buf_0[i];
    }
    if(ObjectFind("Volatility_hud") == -1){
      createHud();
    }
    ObjectSetText("Volatility_hud","avarage: "+DoubleToStr((all/len),1),8,"Arial",Black);
    CURR_BUF = Buf_0[1];    
  }
  return(0);
}

bool createHud(){
  ObjectCreate("Volatility_hud", OBJ_LABEL, WindowFind("volatility"), 0, 0);
  ObjectSet("Volatility_hud", OBJPROP_CORNER, 0);
  ObjectSet("Volatility_hud", OBJPROP_XDISTANCE, 85);
  ObjectSet("Volatility_hud", OBJPROP_YDISTANCE, 3);
  ObjectSet("Volatility_hud", OBJPROP_BACK, true);  
}