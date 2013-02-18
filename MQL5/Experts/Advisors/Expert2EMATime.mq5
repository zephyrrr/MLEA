//+------------------------------------------------------------------+
//|                                               Expert2EMATime.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//|                                              Revision 2010.08.26 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2010, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property version     "5.00"
//---
input string InpTitle="Expert: Signal-2EMA+Time, Trailing-None, Money-None"; // Expert::Title
input long   InpMagicNumber=5;                                               // Expert::MagicNimber
//---
#include <Expert\Expert.mqh>
#include <Expert\Signal\Signal2EMATime.mqh>
//--- 
CExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- creation of all necessary objects
   if(ExtExpert.Init(Symbol(),Period(),false,InpMagicNumber))
     {
      if(!ExtExpert.InitSignal(new CSignal2EMATime)) return(-2);
      //--- ok
      return(0);
     }
//--- failed
   ExtExpert.Deinit();
   return(-1);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| Function-event handler "tick"                                    |
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
