//+------------------------------------------------------------------+
//|                                                       Turtle.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Turtle\TurtleExpert.mqh>

CTurtleExpert ExtExpert;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    if(!ExtExpert.Init(Symbol(),Period(), true, 88888))
    {
        printf(__FUNCTION__+": error initializing expert");
        ExtExpert.Deinit();
        return(-1);
    }

   return(0);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    ExtExpert.Deinit();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   ExtExpert.OnTick();
}
//+------------------------------------------------------------------+
//| Function-event handler "trade"                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| Function-event handler "timer"                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
