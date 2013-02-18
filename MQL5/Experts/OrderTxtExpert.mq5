//+------------------------------------------------------------------+
//|                                                MyExpertModel.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#property tester_library "kernel32.dll"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <ExpertModel\ExpertModel.mqh>
#include <EA\ExpertCreator.mqh>

#include <Utils\HistoryDataExport.mqh>

CExpertModel *ExtExpert;
ExpertFactory expertFactory;

int OnInit()
{
    logger.SetSetting("OrderTxtExpert", "OrderTxtExpert");   
    
    ExtExpert = expertFactory.CreateOrderTxtExpert();
    
    if (ExtExpert == NULL)
        return -1;
    
    return(0);
}

//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    logger.DeInit();
    if (ExtExpert != NULL)
    {
        ExtExpert.Deinit();
        delete ExtExpert;
    }
}
//+------------------------------------------------------------------+
//| Function-event handler "tick"                                    |
//+------------------------------------------------------------------+
void OnTick()
{
    if (ExtExpert != NULL)
    {
        ExtExpert.OnTick();
    }
}
//+------------------------------------------------------------------+
//| Function-event handler "trade"                                   |
//+------------------------------------------------------------------+
void OnTrade()
{
    if (ExtExpert != NULL)
    {
        ExtExpert.OnTrade();
    }
}
//+------------------------------------------------------------------+
//| Function-event handler "timer"                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    if (ExtExpert != NULL)
    {
        ExtExpert.OnTimer();
    }
}
//+------------------------------------------------------------------+
