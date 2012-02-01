//+------------------------------------------------------------------+
//|                                                       spread.mq4 |
//|                                                              Dex |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dex"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 1      

#property indicator_minimum 0
//#property indicator_maximum 100

#define TIME 0
#define SPREAD 1

double DATA[1][2];
double Buf_0[];

bool NOT_SET = true;

int init(){
  SetIndexBuffer(0,Buf_0);
  SetIndexStyle (0,DRAW_HISTOGRAM, STYLE_SOLID, 2, LightSkyBlue);
  SetIndexEmptyValue(0, 0.0);
  
  int i = 0, j = 0;
  int handle = FileOpen(Symbol()+"_spread.csv",FILE_READ,";");
  string in;
  
  if(handle>0){
  
    while(!FileIsEnding(handle)){
      in = FileReadString(handle);
      
      if(in != ""){ 
        if(j == 0){
          ArrayResize(DATA, i+1);
          DATA[i][TIME] = StrToDouble(in);
          j++;
          
        }else{
          DATA[i][SPREAD] = StrToDouble(in);  
          i++;
          j = 0;
        }           
      }       
    } 
  }
  FileClose(handle);
  
  
  return(0);
}

int start(){
   
  double spread = MarketInfo(Symbol(),MODE_SPREAD);
  int arr_size = ArrayRange(DATA,0);
  datetime time = TimeCurrent();
  
  setDataFromFile();
  
  if(iBarShift(NULL, PERIOD_M1, DATA[arr_size-1][TIME]) > 0){
    ArrayResize(DATA, arr_size+1);
    DATA[arr_size][TIME] = time;
    DATA[arr_size][SPREAD] = spread;
    
  }else if(spread > DATA[arr_size-1][SPREAD]){
    DATA[arr_size-1][SPREAD] = spread;
   
  }
  
  if(spread > Buf_0[0]){    
    Buf_0[0] = spread; 
  }   
   
  return(0);
}

int deinit(){
  int len = ArrayRange(DATA,0);
  string out = "";
  for(int i=0;i<len;i++){   
    if(DATA[i][TIME] != 0.0){
      out = StringConcatenate(out, DATA[i][TIME],";",DATA[i][SPREAD],"\r\n");
    }
  }
  
  int handle=FileOpen(Symbol()+"_spread.csv", FILE_BIN|FILE_WRITE);
  if(handle<1){
   Alert("spread write error");
   return(0);
  }
  FileWriteString(handle, out, StringLen(out));
  FileClose(handle);
  return(0);
}

bool setDataFromFile(){
  if(NOT_SET){
    int i, bar, len = ArrayRange(DATA,0);  
    
    /*for(i = 0; i < Bars-IndicatorCounted()-1;i++){
      Buf_0[i] = 0.0;
    }*/
    for(i=0;i<len;i++){      
      bar = iBarShift(NULL, 0, DATA[i][TIME]);      
      if(DATA[i][SPREAD] > Buf_0[bar]){      
        Buf_0[bar] = DATA[i][SPREAD];
      }
    }
    NOT_SET = false;
  }
  return (false);
}