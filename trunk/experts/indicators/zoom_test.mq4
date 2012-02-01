//+------------------------------------------------------------------+
//|                                                    Z_test.mq4 |
//|                                                              Dex |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dex"
#property link      ""

#property indicator_chart_window
 
#property indicator_buffers 4
 
#property indicator_color1 Black
#property indicator_color2 Black
#property indicator_color3 LightSeaGreen
#property indicator_color4 OrangeRed

double Buf_0[];     
double Buf_1[]; 
double Buf_2[];
double Buf_3[];

double I_X1 = 0.0, I_X2 = 0.0, I_Y1 = 0.0, I_Y2 = 0.0;
double Z_X1 = 0.0, Z_X2 = 0.0, Z_Y1 = 0.0, Z_Y2 = 0.0;

int PERIOD;

int init(){
  SetIndexBuffer(0,Buf_0);         
  SetIndexStyle (0,DRAW_HISTOGRAM,0,1);

  SetIndexBuffer(1,Buf_1);         
  SetIndexStyle (1,DRAW_HISTOGRAM,0,1);

  SetIndexBuffer(2,Buf_2);         
  SetIndexStyle (2,DRAW_HISTOGRAM,0,2);

  SetIndexBuffer(3,Buf_3);         
  SetIndexStyle (3,DRAW_HISTOGRAM,0,2);
  
  SetIndexEmptyValue(0, 0.0);
  SetIndexEmptyValue(1, 0.0);
  SetIndexEmptyValue(2, 0.0);
  SetIndexEmptyValue(3, 0.0);
  
  PERIOD = getPrevPeriod(Period());
  PERIOD = getPrevPeriod(PERIOD);
  
  int div = Period()/PERIOD;
  double dif = WindowPriceMax(0)-WindowPriceMin(0);
  int z_x1_nr = WindowFirstVisibleBar()-(WindowBarsPerChart()/20);
  int z_x2_nr = z_x1_nr-roundToPeriod(WindowBarsPerChart()/10*3,PERIOD);
  
  double z_x1 = Time[z_x1_nr];
  double z_x2 = Time[z_x2_nr];
  
  int i_x1_nr = WindowLastVisibleBar()+((z_x1_nr-z_x2_nr)/div);
  
  double z_y1 = High[iHighest(NULL,0,MODE_HIGH,i_x1_nr,WindowLastVisibleBar())];
  double z_y2 = Low[iLowest(NULL,0,MODE_LOW,i_x1_nr,WindowLastVisibleBar())];
  
  ObjectCreate("DT_BO_zoom_Z_chart", OBJ_RECTANGLE, 0, z_x1, z_y1, z_x2, z_y2);
  ObjectSet("DT_BO_zoom_Z_chart", OBJPROP_BACK, false);
  ObjectSet("DT_BO_zoom_Z_chart", OBJPROP_COLOR,Black);
  ObjectSet("DT_BO_zoom_Z_chart", OBJPROP_WIDTH,2);
  
  double i_x1 = Time[i_x1_nr];
  double i_y1 = z_y1;
  double i_x2 = Time[WindowLastVisibleBar()];
  double i_y2 = z_y2;
  
  ObjectCreate("DT_BO_zoom_Z_index", OBJ_RECTANGLE, 0, i_x1, i_y1, i_x2, i_y2);
  ObjectSet("DT_BO_zoom_Z_index", OBJPROP_BACK, false);
  ObjectSet("DT_BO_zoom_Z_index", OBJPROP_COLOR,Black);
  
  return(0);
}

int start(){
  updateZoom();
  return(0);
}

int deinit(){
  removeObjects("zoom");
  return(0);
}

bool updateZoom(){
  double cur_z_x1 = ObjectGet("DT_BO_zoom_Z_chart",OBJPROP_TIME1);
  double cur_z_y1 = ObjectGet("DT_BO_zoom_Z_chart",OBJPROP_PRICE1);
  double cur_z_x2 = ObjectGet("DT_BO_zoom_Z_chart",OBJPROP_TIME2);
  double cur_z_y2 = ObjectGet("DT_BO_zoom_Z_chart",OBJPROP_PRICE2);
  
  double cur_i_x1 = ObjectGet("DT_BO_zoom_Z_index",OBJPROP_TIME1);
  double cur_i_y1 = ObjectGet("DT_BO_zoom_Z_index",OBJPROP_PRICE1);
  double cur_i_x2 = ObjectGet("DT_BO_zoom_Z_index",OBJPROP_TIME2);
  double cur_i_y2 = ObjectGet("DT_BO_zoom_Z_index",OBJPROP_PRICE2);
  
  if(cur_z_x1 != Z_X1 || cur_z_y1 != Z_Y1 || cur_z_x2 != Z_X2 || cur_z_y2 != Z_Y2 || cur_i_x1 != I_X1 || cur_i_y1 != I_Y1 || cur_i_x2 != I_X2 || cur_i_y2 != I_Y2){
    for(int i = 0; i < WindowFirstVisibleBar(); i++){
      Buf_0[i] = EMPTY_VALUE;
      Buf_1[i] = EMPTY_VALUE;
      Buf_2[i] = EMPTY_VALUE;
      Buf_3[i] = EMPTY_VALUE;
    }
    int div = Period()/PERIOD;
    
    I_X1 = cur_i_x1;
    I_X2 = getIndexX2(cur_i_x1, ((getZoomX2(cur_z_x1,cur_z_x2)-cur_z_x1)/(Period()/PERIOD)));
    I_Y1 = cur_i_y1;
    I_Y2 = cur_i_y1-(cur_z_y1-cur_z_y2);

    ObjectSet("DT_BO_zoom_Z_index",OBJPROP_TIME2, I_X2);
    ObjectSet("DT_BO_zoom_Z_index",OBJPROP_PRICE2, I_Y2);
    
    Z_X1 = cur_z_x1;
    Z_Y1 = cur_z_y1;
    Z_X2 = cur_z_x2;
    Z_Y2 = cur_z_y2;
    
    int start = iBarShift(NULL,0,I_X2)*div;
    // int end = start+(iBarShift(NULL,0,Z_X1)-iBarShift(NULL,0,Z_X2));
    int end = start+((iBarShift(NULL,0,cur_i_x1)-iBarShift(NULL,0,cur_i_x2))*div);
    
    i = iBarShift(NULL,0,Z_X1);
    
    double h,l,c,o,y_dif = Z_Y2-I_Y2;
    for(; end >= start; end--){
      h = iHigh(NULL, PERIOD, end)+y_dif;
      l = iLow(NULL, PERIOD, end)+y_dif;
      c = iClose(NULL, PERIOD, end)+y_dif;
      o = iOpen(NULL, PERIOD, end)+y_dif;
      if(h < Z_Y2){ h = Z_Y2; }
      if(l > Z_Y1){ l = Z_Y1; }
      
      if(h > Z_Y1){ h = Z_Y1; }
      if(l < Z_Y2){ l = Z_Y2; }
      
      if(c > Z_Y1){ c = Z_Y1; }
      if(c < Z_Y2){ c = Z_Y2; }
      
      if(o > Z_Y1){ o = Z_Y1; }
      if(o < Z_Y2){ o = Z_Y2; }
      
      
      Buf_0[i] = h;
      Buf_1[i] = l;
      
      Buf_2[i] = c;
      Buf_3[i] = o;
      
      i--;
    }
    
    removeObjects("zoom_obj");
    showAllObject(y_dif);
  }
  return (0);
}     

bool showAllObject(double shift){
  int j, obj_total= ObjectsTotal(), type;
  double trend_y;
  string name;
  for (j= obj_total-1; j>=0; j--) {
    name = ObjectName(j);
    type = ObjectType(name);
    if (type == OBJ_HLINE){
      trend_y = ObjectGet(name ,OBJPROP_PRICE1);
      if(trend_y < I_Y1 && trend_y > I_Y2){
        trend_y = trend_y+shift;
        ObjectCreate("DT_BO_zoom_obj_tl_"+j, OBJ_TREND, 0, Z_X1, trend_y, Z_X2, trend_y);
        ObjectSet("DT_BO_zoom_obj_tl_"+j, OBJPROP_RAY, false);
        ObjectSet("DT_BO_zoom_obj_tl_"+j, OBJPROP_COLOR, ObjectGet(name ,OBJPROP_COLOR));
        ObjectSet("DT_BO_zoom_obj_tl_"+j, OBJPROP_STYLE, ObjectGet(name ,OBJPROP_STYLE));
        ObjectSetText("DT_BO_zoom_obj_tl_"+j, ObjectDescription(name));
      }
    }
  } 

}   

bool ttt(string p, double t){
Alert(p+" | "+TimeYear(t)+"."+TimeMonth(t)+"."+TimeDay(t)+" "+TimeHour(t)+":"+TimeMinute(t));
return (false);
}

int getPrevPeriod(int peri){
  switch(peri){
    case PERIOD_MN1: return (PERIOD_W1);
    case PERIOD_W1: return (PERIOD_D1);
    case PERIOD_D1: return (PERIOD_H4);
    case PERIOD_H4: return (PERIOD_H1);
    case PERIOD_H1: return (PERIOD_M30);
    case PERIOD_M30: return (PERIOD_M15);
    case PERIOD_M15: return (PERIOD_M5);
    case PERIOD_M5: return (PERIOD_M1);
    default: return (-1);      
  }
}

int roundToPeriod(int nr, int period){
  int multi = Period()/period;
  int rem = nr%multi;
  if(rem != 0){
    if(rem > multi/2){
      return (nr-rem+multi);
    }else{
      return (nr-rem);
    }
  }else{
    return (nr);
  }
}

int WindowLastVisibleBar(){
  int nr = WindowFirstVisibleBar()-WindowBarsPerChart();
  if(nr < 0){
    return (0);
  }else{
    return (nr);
  }
}

double getIndexX2(double start, double shift){
  int tow, peri = PERIOD_D1*60;
  double end = start+shift;
  
  if(shift < peri){
    tow = TimeDayOfWeek(end);
    if(tow == 6){
      return (end+(2*peri));
    }
    if(tow == 0 || tow == 6){
      return (end+peri);
    }
  }
  
  for(double i = start; i <= end; i = i + peri){
    tow = TimeDayOfWeek(i);
    if(tow == 0 || tow == 6){
      end = end + peri;
    }
  }
  return (end);
}

double getZoomX2(double start, double end){
  int tow, peri = PERIOD_D1*60, nr_of_w = 0;
  for(double i = start; i <= end; i = i + peri){
    tow = TimeDayOfWeek(i);
    if(tow == 0 || tow == 6){
      nr_of_w++;
    }
  }
  return (end-(nr_of_w*peri));
}

bool removeObjects(string filter = "", string type = "BO"){
  int j, obj_total= ObjectsTotal();
  string name;
  
  if(filter == ""){      
    for (j= obj_total-1; j>=0; j--) {
       name= ObjectName(j);
       if (StringSubstr(name,3,2)==type){
          ObjectDelete(name);
       }
    }  
  }else{    
    filter = type+"_"+filter;   
    int len = StringLen(filter);
    for (j= obj_total-1; j>=0; j--) {
       name= ObjectName(j);
       if (StringSubstr(name,3,len)==filter){
          ObjectDelete(name);
       }
    }
  }
  return (0);
}

