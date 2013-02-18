//+------------------------------------------------------------------+
//|                                                     MLEAInit.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <EA\MLEASignal.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
    CSymbolInfo symbol;
    symbol.Name(Symbol());
   CMLEASignal s;
   s.Init(GetPointer(symbol), PERIOD_H4, 10);
   s.InitParameters();
   s.ExportData(D'2000.01.01', D'2003.01.01');
  }
//+------------------------------------------------------------------+
