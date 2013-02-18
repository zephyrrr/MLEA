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
#include <Weka\WekaExpert.mqh>

CPositionInfo m_position;
CSymbolInfo m_symbol;
CTrade m_trade;
CWekaExpert m_expert(_Symbol);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    m_symbol.Name(_Symbol);
    return(0);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}
  
int runTime = 0;
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
    int r = 0;
    //if (runTime > 400)
    //    return;
    //if (IsNewBar(Symbol(), PERIOD_H1))
    {
        runTime++;
        if (runTime >= 1)
        {
            m_expert.BuildModel();
        }
    }
    if (IsNewBar(Symbol(), PERIOD_M5))
    {
        //r = m_expert.PredictByModel();
    }
    if (r == 0)
        return;
        
    int dealType = r / 1000000;
    int     m_tp = (r - dealType * 1000000) / 1000;
    int     m_sl = (r - dealType * 1000000 - m_tp * 1000);
    
    bool limitOrder = false;
    m_symbol.RefreshRates();
    double volume = 0.01;
    
    // quit
    if (r == 0)
    {
        if(m_position.Select(m_symbol.Name()))
        {
            m_trade.PositionClose(m_position.Symbol());
            Print("Close Position");
        }
        return;
    }
    // hold
    else if (r == 2)
    {
        return;
    }
    
    // if exist, return;
    if(m_position.Select(m_symbol.Name()))
    {
        if (m_position.PositionType() == POSITION_TYPE_BUY && dealType == 1)
        {
            //if (PositionGetDouble(POSITION_PROFIT) > 0)
            //return false;
        }
        else if (m_position.PositionType() == POSITION_TYPE_SELL && dealType == 2)
        {
            //if (PositionGetDouble(POSITION_PROFIT) > 0)
            //return false;
        } 
        else 
        {
            m_trade.PositionClose(m_symbol.Name());
            //Print("Close Position");
        }
    }
            
    if (dealType == 1)
    {
        double tp = m_symbol.Ask() + (m_symbol.Point() * m_tp);
        double sl = m_symbol.Ask() - (m_symbol.Point() * m_sl);
               
               //tp = MathMin(tp, m_symbol.Ask() + (Points * m_dealTp[i]));
               //sl = MathMin(sl, m_symbol.Bid() - (Points * m_dealSl[i]));
               
        double inPrice = m_symbol.Ask();
        if (!limitOrder)
        {
            m_trade.Buy(volume, m_symbol.Name(), m_symbol.Ask(), sl, tp);
        }
        else
        {
            inPrice = m_symbol.Ask()-0.00100;
            m_trade.BuyLimit(volume, inPrice, m_symbol.Name(), sl, tp);
        }
    }
    else if (dealType == 2)
    {
        double tp = m_symbol.Bid() - (m_symbol.Point() * m_tp);
        double sl = m_symbol.Bid() + (m_symbol.Point() * m_sl);
               
        double inPrice = m_symbol.Bid();
        if (!limitOrder)
        {
            m_trade.Sell(volume, m_symbol.Name(), m_symbol.Bid(), sl, tp);
        }
        else
        {
            inPrice = m_symbol.Bid() + 0.0010;
            m_trade.SellLimit(volume, inPrice, m_symbol.Name(),sl,tp);
        }
    }
  }
//+------------------------------------------------------------------+
