//+------------------------------------------------------------------+
//|                                                     big_move.mq4 |
//|                                                              Dex |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dex"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 2 

#property indicator_color1 LightSkyBlue  
#property indicator_color2 Magenta    

#property indicator_minimum 0
double Buf_0[];
double Buf_1[];

int INTERVAL = 20;
double CS = 0.00120;
double ENTER = 0.00400;

int cs = 120;
int enter = 400;
int tp = 530;

int multi = 100000;

int init(){
  SetIndexBuffer(0,Buf_0);
  SetIndexStyle (0,DRAW_HISTOGRAM, STYLE_SOLID, 2, LightSkyBlue);
  SetIndexEmptyValue(0, 0.0);
  
  SetIndexBuffer(1,Buf_1);
  SetIndexStyle (1,DRAW_HISTOGRAM, STYLE_SOLID, 2, Magenta);
  SetIndexEmptyValue(1, 0.0); 
  
  
  if(StringFind(Symbol(), "JPY")!= -1){
    multi = multi/100;
    CS = (CS*100)/4*3;
    ENTER = (ENTER*100)/4*3;
    cs = cs/4*3;
    enter = enter/4*3;
    tp =tp/4*3;
  }
  
  SetLevelValue(0,enter);
  SetLevelValue(1,tp);
  SetLevelValue(2,enter-cs);

  return(0);
}

int start(){


 
  int Counted_bars=IndicatorCounted();  
  int len=Bars-Counted_bars-1; 
  double o, h, l, c, tmp;
 // len = WindowFirstVisibleBar();  
 // len = 80;  
  double start_up_price = Open[len], up_high = High[len], start_up_time = Time[len];
  double start_down_price = Open[len], down_low = Low[len], start_down_time = Time[len];
  int last_pos = len+100;
  int interval = INTERVAL;
  double highest, lowest, start_price;
  int in_position = 0;
  
  for(int i=len; i>0; i--){
    o = Open[i];
    h = High[i];
    l = Low[i];
    c = Close[i];
    
    Buf_0[i]=0.0;
    Buf_1[i]=0.0;
    
    if(in_position != 0){
      if(in_position > 0){
        if(h > up_high){
          up_high = h;
          last_pos = i;
        }else if(up_high-CS > l){
          Buf_0[i] = NormalizeDouble((up_high-start_price)*multi,0);
          in_position = 0;
        }
      }else{
        if(l < down_low){
          down_low = l;
          last_pos = i;
        }else if(down_low+CS < h){
          Buf_1[i] = NormalizeDouble((start_price-down_low)*multi,0);
          in_position = 0;
        }
      }
    
    }else{
      if(last_pos-i < INTERVAL){
        interval = last_pos-i+1;
      }else{
        interval = INTERVAL;
      }
      
      lowest = Low[iLowest(NULL, 0, 1, interval, i)];
      highest = High[iHighest(NULL, 0, 2, interval, i)];
      
      if( h-lowest > ENTER){
        in_position = 1;
        start_price = lowest;
        up_high = h;
        last_pos = i;
      }else if(highest-l > ENTER){
        in_position = -1;
        start_price = highest;
        down_low = l;
        last_pos = i;
      }
    }

    




continue;    
    if(up_high-start_up_price < ENTER){
      tmp = Low[iLowest(NULL, 0, 1, 20, i)];
       if(tmp < start_up_price){
        start_up_price = tmp;
       }
    }
    
    if(h > up_high){
      up_high = h;
    }else if(up_high-CS > l){
      if(up_high-start_up_price > ENTER){
        Buf_0[i] = NormalizeDouble((up_high-start_up_price)*multi,0);
      }
      start_up_price = o;
      up_high = h;
    }
    
    if(start_down_price-down_low < ENTER){
      tmp = High[iHighest(NULL, 0, 2, 20, i)];
        if(tmp > start_down_price){
        start_down_price = tmp;
        }
    }
    
    if(l < down_low){
      down_low = l;
    }else if(down_low+CS < h){
      if(start_down_price-down_low > ENTER){
        Buf_1[i] = NormalizeDouble((start_down_price-down_low)*multi,0);
      }
      start_down_price = o;
      down_low = l;
    }
  }

  int f = 0;
  int a = 0;
  double buko = 0;
  double jep = 0;
  // for(i=len; i>0; i--){
    // if(Buf_0[i]>tp){
      // jep = jep+ (Buf_0[i]-tp);
      // f++;
    // }
    // if(Buf_1[i]>tp){
      // jep = jep+ (Buf_1[i]-tp);
      // f++;
    // }
    // if(Buf_0[i]> enter && Buf_0[i]< tp){
      // a++;
      // buko = buko + (cs- (Buf_0[i]-enter));
    // }
    // if(Buf_1[i]> enter && Buf_1[i]< tp){
      // buko = buko + (cs- (Buf_1[i]-enter));
      // a++;
    // }
  // }
  for(i=len; i>0; i--){
    if(Buf_0[i]>460){
      jep = jep+ 60;
      f++;
    }
    if(Buf_1[i]>460){
      jep = jep+ 60;
      f++;
    }
    if(Buf_0[i]> enter && Buf_0[i]< 460){
      a++;
      buko = buko + 70;
    }
    if(Buf_1[i]> enter && Buf_1[i]< 460){
      buko = buko + 70;
      a++;
    }
  }
   //Alert("Nyero: "+f+" Ossz: "+DoubleToStr(jep,0)+" Buko: "+a+" Ossz: -"+DoubleToStr(buko,0)+" | "+DoubleToStr(jep/buko,2));  
   
  return(0);
}

int deinit(){
return(0);
}