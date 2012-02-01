//+------------------------------------------------------------------+
//|                                                     DT_iMA_2.mq4 |
//|                                                              Dex |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dex"
#property link      ""

#property indicator_chart_window    
#property indicator_buffers 3 
      
#property indicator_color1 Magenta  
#property indicator_color2 RoyalBlue
#property indicator_color3 Red

double Buf_0[];
double Buf_1[];
double Buf_2[];
  
int init(){
  if(Period() > PERIOD_D1){
    return (0);
  }
  
  SetIndexBuffer(0,Buf_0);
  SetIndexStyle (0,DRAW_LINE, STYLE_SOLID, 2, Magenta);
  SetIndexEmptyValue(0, 0.0);
  
  SetIndexBuffer(1,Buf_1);
  SetIndexStyle (1,DRAW_LINE, STYLE_SOLID, 2, RoyalBlue);
  SetIndexEmptyValue(1, 0.0);
  
  SetIndexBuffer(2,Buf_2);
  SetIndexStyle (2,DRAW_LINE, STYLE_SOLID, 2, Red);
  SetIndexEmptyValue(2, 0.0);
  
  return(0);
}

int start(){
  if(Period() > PERIOD_D1){
    return (0);
  }
  int Counted_bars=IndicatorCounted();  
  int len=Bars-Counted_bars-1; 
  
  int multi = (PERIOD_D1/Period());
  int period = 13*multi;
  int ma_shift = -3*multi;
  
  double h,l,m;
  
  for(int i=len; i>0; i--){
    h = iMA(NULL,0,period,ma_shift,MODE_LWMA,PRICE_HIGH,i);
    m = iMA(NULL,0,period,ma_shift,MODE_LWMA,PRICE_WEIGHTED,i);
    l = iMA(NULL,0,period,ma_shift,MODE_LWMA,PRICE_LOW,i);
    Buf_0[i] = m + ((h - m)*multi)/2;
    Buf_1[i] = m;
    Buf_2[i] = m - ((m - l)*multi)/2;
  } 
  return(0);
}

int deinit(){
  return(0);
}