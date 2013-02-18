//+------------------------------------------------------------------+
//|                                                MyExpertModel.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
#include <Expert\Trailing\TrailingNone.mqh>
#include <Expert\Money\MoneyFixedLot.mqh>

#include <Turtle\ForexMorningSignal2.mqh>
#include <Turtle\ForexMorningTrailing2.mqh>
#include <Turtle\20-200Signal.mqh>

CExpert ExtExpert;
   
int OnInit()
{
    if(!ExtExpert.Init(Symbol(), Period(), true, 88888))
    {
        printf(__FUNCTION__+": error initializing expert");
        ExtExpert.Deinit();
        return(-1);
    }

    CForexMorningSignal *signal = new CForexMorningSignal;
    if(signal==NULL || !ExtExpert.InitSignal(signal) || !signal.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating signal");
        ExtExpert.Deinit();
        return(-2);
    }
     
    CForexMorningTrailing *trailing = new CForexMorningTrailing;
    if(trailing==NULL || !ExtExpert.InitTrailing(trailing) || !trailing.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating trailing");
        ExtExpert.Deinit();
        return(-5);
    }
     
    CMoneyFixedLot *money=new CMoneyFixedLot;
    money.Percent(10);
    money.Lots(0.1);
    if(money==NULL || !ExtExpert.InitMoney(money) || !money.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating money");
        ExtExpert.Deinit();
        return(-8);
    }

    if(!ExtExpert.InitIndicators())
    {
        printf(__FUNCTION__+": error initializing indicators");
        ExtExpert.Deinit();
        return(-11);
    }
    
    return(0);
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
