//+------------------------------------------------------------------+
//|                                                       Dex SR.mq4 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Dex"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

double BUFF1[];
double BUFF2[];
int init(){
  SetIndexBuffer(0,BUFF1);
  SetIndexBuffer(1,BUFF2);
  SetIndexStyle(0,DRAW_ARROW);
  SetIndexArrow(0,119);
  SetIndexStyle(1,DRAW_ARROW);
  SetIndexArrow(1,119);
  
  SetIndexEmptyValue(0,0.0);
  SetIndexEmptyValue(1,0.0);
  return(0);
}

int deinit(){

  return(0);
}

int start(){
  int Counted_bars=IndicatorCounted();  
  int len=Bars-Counted_bars-1;
  
  len=WindowFirstVisibleBar();
  int i = 0;
  
  double tmp;
  
  while(i < len){
    tmp = iCustom(Symbol(),0,"ZigZag",12, 5, 3,0,i);
    if( tmp != 0 ){
      BUFF1[i] = tmp; 
    }
    i++;
  }

  return(0);
}

