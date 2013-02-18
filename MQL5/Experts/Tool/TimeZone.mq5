//+------------------------------------------------------------------+
//|                                                     TimeZone.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Utils\Utils.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
    datetime now = TimeCurrent();
    Print("Current time is " + TimeToString(now));
    datetime gmt = TimeGMT();
    Print("GMT time is " + TimeToString(gmt));
    Print("GMT Offset is " + IntegerToString(GetGMTOffset()));
    Print("CET Offset is " + IntegerToString(GetCETOffset()));
  }
//+------------------------------------------------------------------+
