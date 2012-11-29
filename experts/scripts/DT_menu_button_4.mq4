//+------------------------------------------------------------------+
//|                                             DT_menu_button_4.mq4 |
//|                                                              Dex |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dex"
#property link      ""

#include <DT_defaults.mqh>
#include <DT_functions.mqh>
#include <DT_icons.mqh>

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start(){
  if( getGlobal( "REAL_PRICE" ) == 0.0 ){
    setGlobal( "REAL_PRICE", 1.0 );
  }else{
    setGlobal( "REAL_PRICE", 0.0 );
  }
  fakeTick();
  return(0);
}