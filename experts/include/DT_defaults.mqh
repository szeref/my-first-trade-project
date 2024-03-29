//+------------------------------------------------------------------+
//|                                                  DT_defaults.mq4 |
//|                                                              Dex |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dex"
#property link      ""

#define SPREAD 1
#define MIN_PROFIT 2
#define MAX_PROFIT 3
#define STOPLOSS 4
#define SML_TP 5
#define FAIL_SL 6
#define FAIL_TP 7
#define SML_MAGNET 8
#define MAX_DIST 9

#define USED_SYM 6

string SYMBOL_DATA[USED_SYM][10] = {
// full name  | av. spread | min profit | max profit | Stop Loss |   SML TP  |   FAIL SL |    FAIL TP  |   SML_MAGNET |  MAX_DIST
  "EURUSD-Pro",  "0.00008",  "0.00100",   "0.00750",   "0.00080",   "0.00120",   "0.00090",   "0.00120",   "0.00100",    "0.00250",
  "USDJPY-Pro",  "0.009",    "0.00008",   "0.00008",   "0.00080",   "0.00120",   "0.00090",   "0.00120",   "0.00100",    "0.00250",
  "EURJPY-Pro",  "0.014",    "0.00008",   "0.00008",   "0.00080",   "0.00120",   "0.00090",   "0.00120",   "0.00100",    "0.00250",
  "GBPUSD-Pro",  "0.00014",  "0.00100",   "0.00750",   "0.00080",   "0.00120",   "0.00090",   "0.00120",   "0.00100",    "0.00250",
  "AUDUSD-Pro",  "0.00015",  "0.00100",   "0.00750",   "0.00080",   "0.00120",   "0.00090",   "0.00120",   "0.00100",    "0.00250",
  "EURUSD",      "0.0001",   "0.0018",    "0.0075",    "0.0008",    "0.0012",    "0.0009",    "0.0012",    "0.0010",     "0.0025", 
};                                                                                                                     

