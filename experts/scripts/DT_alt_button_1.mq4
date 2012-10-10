//+------------------------------------------------------------------+
//|                                              DT_alt_button_1.mq4 |
//|                                                              Dex |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dex"
#property link      ""

#include <DT_defaults.mqh>
#include <DT_functions.mqh>
#include <DT_objects.mqh>

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start(){
  bool hide = false;
  int i, len = ObjectsTotal(), width;
  string name;
  
  for( i = 0; i < len; i++ ){
    name = ObjectName(i);
    if( ObjectGet( name, OBJPROP_TIMEFRAMES ) != -1 ){
      if( ObjectType( name ) == OBJ_FIBO ){
        hide = true;
        break;
      }
    }
  }
  
  for( i = 0; i < len; i++ ){
    name = ObjectName(i);
    if( ObjectType( name ) == OBJ_FIBO ){
      if( hide && ObjectGet( name, OBJPROP_TIMEFRAMES ) == 0 ){
        ObjectSet( name, OBJPROP_TIMEFRAMES, -1 );
      }else if( !hide && ObjectGet( name, OBJPROP_TIMEFRAMES ) == -1 ){
        ObjectSet( name, OBJPROP_TIMEFRAMES, 0 );
      }
    }
  }
  
  changeObjectsIcon( 1, hide );
  
  return(0);
}