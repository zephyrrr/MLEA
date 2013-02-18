//+------------------------------------------------------------------+
//|                                               WekaExpertTest.mq5 |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#property version   "1.00"

//#include <EA\WekaExpert.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Utils\Utils.mqh>
#include <Utils\IsNewBar.mqh>
#include <Files\FileTxt.mqh>

#include <EA\MLEASignal.mqh>

CPositionInfo m_position;
CSymbolInfo m_symbol;
CTrade m_trade;

CMLEASignal m_signal;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    m_symbol.Name(Symbol());
    m_signal.Init(GetPointer(m_symbol), PERIOD_D1, 1);
    m_signal.InitParameters();
    
    return(0);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
    m_signal.OnTick();
  }
//+------------------------------------------------------------------+
