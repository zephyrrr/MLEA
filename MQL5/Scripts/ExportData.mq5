//+------------------------------------------------------------------+
//|                                                   Show4Learn.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
#include <Utils\HistoryDataExport.mqh>

void OnStart()
  {
    CHistoryDataExport historyDataExport;
    //string symbol = "EURUSD";
    //ENUM_TIMEFRAMES period = PERIOD_M1;
    //string fileName = symbol + "_H1_Z.dat";
    
    //"EURUSD", 
    string symbols[] = {"EURUSD", "GBPUSD", "USDCHF", "USDJPY", "USDCAD", "AUDUSD", "USDSEK"};
    //string symbols[] = { "EURUSD" };
    //ENUM_TIMEFRAMES periods[] = {PERIOD_M5, PERIOD_M15, PERIOD_H1, PERIOD_H4, PERIOD_D1};
    ENUM_TIMEFRAMES periods[] = {PERIOD_M30};
    
    for(int i=0; i<ArraySize(symbols); ++i)
    {
        //historyDataExport.WriteData(symbols[i], PERIOD_M1);
        for(int j=0; j<ArraySize(periods); ++j)
        {
            Print("begin to write " + symbols[i] + ", " + GetPeriodName(periods[j]));
            historyDataExport.WriteAll(symbols[i], periods[j]);
            Print("end to write " + symbols[i] + ", " + GetPeriodName(periods[j]));
        }
    }
    
    //string symbol = "EURUSD";
    //ENUM_TIMEFRAMES period = PERIOD_M15;
    //WriteAll(symbol, period);
    
  }
//+------------------------------------------------------------------+
