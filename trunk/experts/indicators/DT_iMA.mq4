//+------------------------------------------------------------------+
//|                                                       DT_iMA.mq4 |
//|                                                              Dex |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dex"
#property link      ""

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#property indicator_chart_window    
#property indicator_buffers 6       
#property indicator_color1 Magenta  
#property indicator_color2 RoyalBlue
#property indicator_color3 Red   
 
double Buf_0[];     
double Buf_1[]; 
double Buf_2[];
double Buf_3[];     
double Buf_4[]; 
double Buf_5[];
//--------------------------------------------------------------- 2 --
int init(){
  if(Period() > PERIOD_D1){
    return (false);
  }
  
  SetIndexBuffer(0,Buf_0);         
  SetIndexStyle (0,DRAW_ZIGZAG);  

  SetIndexBuffer(1,Buf_1);         
  SetIndexStyle (1,DRAW_ZIGZAG);

  SetIndexBuffer(2,Buf_2);         
  SetIndexStyle (2,DRAW_ZIGZAG);  

  SetIndexBuffer(3,Buf_3);         
  SetIndexStyle (3,DRAW_ZIGZAG);

  SetIndexBuffer(4,Buf_4);         
  SetIndexStyle (4,DRAW_ZIGZAG);  

  SetIndexBuffer(5,Buf_5);         
  SetIndexStyle (5,DRAW_ZIGZAG);



  SetIndexEmptyValue(0, 0.0);
  SetIndexEmptyValue(1, 0.0);
  SetIndexEmptyValue(2, 0.0);
  SetIndexEmptyValue(3, 0.0);
  SetIndexEmptyValue(4, 0.0);
  SetIndexEmptyValue(5, 0.0);
  return;                          
}

int start(){
  if(Period() > PERIOD_D1){
    return (false);
  }
                   
  int Counted_bars=IndicatorCounted();  
  int len=Bars-Counted_bars-1; 
  int i=0, t1 = 0, t2;
  double p1, p2, multiplier = 1.8; 
  
  
  
  p1 = iMA(NULL,PERIOD_D1,10,0,MODE_LWMA,PRICE_WEIGHTED,0);
  Buf_0[0]=p1;
  p2 = iMA(NULL,PERIOD_D1,10,0,MODE_LWMA,PRICE_HIGH,0);
  Buf_2[0]=p2+((p2-p1)*multiplier);
  p2 = iMA(NULL,PERIOD_D1,10,0,MODE_LWMA,PRICE_LOW,0);
  Buf_4[0]=p2-((p1-p2)*multiplier); 
 
  p1 = iMA(NULL,PERIOD_D1,10,0,MODE_LWMA,PRICE_WEIGHTED,0);
  Buf_1[0]=p1;
  p2 = iMA(NULL,PERIOD_D1,10,0,MODE_LWMA,PRICE_HIGH,0);
  Buf_3[0]=p2+((p2-p1)*multiplier);
  p2 = iMA(NULL,PERIOD_D1,10,0,MODE_LWMA,PRICE_LOW,0);
  Buf_5[0]=p2-((p1-p2)*multiplier);        
 
  for(i=(PERIOD_D1/Period())*3; i<len; i++){
  
    t2 = iBarShift(NULL, PERIOD_D1, Time[i], false);
    if(t1 != t2){
      t1 = t2;
      if(MathMod(t2,2) == 0){
        p1 = iMA(NULL,PERIOD_D1,13,-3,MODE_LWMA,PRICE_WEIGHTED,t2);
        Buf_0[i]=p1;
        p2 = iMA(NULL,PERIOD_D1,13,-3,MODE_LWMA,PRICE_HIGH,t2);
        Buf_2[i]=p2+((p2-p1)*multiplier);
        p2 = iMA(NULL,PERIOD_D1,13,-3,MODE_LWMA,PRICE_LOW,t2);
        Buf_4[i]=p2-((p1-p2)*multiplier);
        
        Buf_1[i]=0.0;
        Buf_3[i]=0.0;
        Buf_5[i]=0.0;
        
      }else{
        p1 = iMA(NULL,PERIOD_D1,13,-3,MODE_LWMA,PRICE_WEIGHTED,t2);
        Buf_1[i]=p1;
        p2 = iMA(NULL,PERIOD_D1,13,-3,MODE_LWMA,PRICE_HIGH,t2);
        Buf_3[i]=p2+((p2-p1)*multiplier);
        p2 = iMA(NULL,PERIOD_D1,13,-3,MODE_LWMA,PRICE_LOW,t2);
        Buf_5[i]=p2-((p1-p2)*multiplier);
                
        Buf_0[i]=0.0;
        Buf_2[i]=0.0;
        Buf_4[i]=0.0;
      }
    }  
    
  } 
  return;                         
 }

