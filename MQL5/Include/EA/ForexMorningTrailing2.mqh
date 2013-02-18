//+------------------------------------------------------------------+
//|                                          ForexMoringTrailing.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

#include <Expert\ExpertTrailing.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
 
class CForexMorningTrailing : public CExpertTrailing
{
private:
    int HiddenStopLossPips;
    int HiddenProfitTargetPips;
    int BreakEvenAtPipsProfit;
    int BreakEvenAddPips;
    int TrailingStopPips;
    
    CTrade m_trade;
public:
                     CForexMorningTrailing();
    virtual bool      ValidationSettings();
  
    virtual bool      CheckTrailingStopLong(CPositionInfo* position,double& sl,double& tp);
    virtual bool      CheckTrailingStopShort(CPositionInfo* position,double& sl,double& tp);
};
void CForexMorningTrailing::CForexMorningTrailing()
{
    HiddenStopLossPips = 400;
    HiddenProfitTargetPips = 350;
    BreakEvenAtPipsProfit = 200;
    BreakEvenAddPips = 0;
    TrailingStopPips = 0;
}

bool CForexMorningTrailing::ValidationSettings()
{
    if (!CExpertModelTrailing::ValidationSettings())
        return false;
    return(true);
}

bool CForexMorningTrailing::CheckTrailingStopLong(CPositionInfo* position,double& sl,double& tp)
{
    sl = EMPTY_VALUE;
    tp = EMPTY_VALUE;
    
    if(position==NULL)  
        return(false);
    
    bool closePosition = false;
     
    if (TrailingStopPips > 0) 
    {
        if (m_symbol.Bid() > position.StopLoss() + TrailingStopPips * m_symbol.Point()) 
        {
            sl = m_symbol.Bid() - TrailingStopPips * m_symbol.Point();
        }
    }
    if (BreakEvenAtPipsProfit > 0)
    {
        if (m_symbol.Bid() - position.PriceOpen() >= BreakEvenAtPipsProfit * m_symbol.Point() 
            && position.StopLoss() < position.PriceOpen()) 
        {
            sl = position.PriceOpen() + BreakEvenAddPips * m_symbol.Point();
            Print("sl2");
        }
    }
        
    if (HiddenProfitTargetPips > 0)
    {
        if (m_symbol.Bid() - position.PriceOpen() >= HiddenProfitTargetPips * m_symbol.Point()) 
        {
            Print("sl3");
            closePosition = true;
            m_trade.PositionClose(position.Symbol());
        }
    }     
    if (HiddenStopLossPips > 0)
    {
        if (position.PriceOpen() - m_symbol.Bid() >= HiddenStopLossPips * m_symbol.Point()) 
        {
            Print("sl4");
            closePosition = true;
            m_trade.PositionClose(position.Symbol());
        }
    }
    
    if (!closePosition)
    {
        if ((sl != EMPTY_VALUE && sl != position.StopLoss())
            || (tp != EMPTY_VALUE && tp != position.TakeProfit()))
            return true;
    }
    
    return false;
}

bool CForexMorningTrailing::CheckTrailingStopShort(CPositionInfo* position,double& sl,double& tp)
{
    sl = EMPTY_VALUE;
    tp = EMPTY_VALUE;
    
    if(position==NULL)  
        return(false);
    
    bool closePosition = false;

    if (TrailingStopPips > 0) 
    {
        if (m_symbol.Ask() < position.StopLoss() - TrailingStopPips * m_symbol.Point()) 
        {
            sl = m_symbol.Ask() + TrailingStopPips * m_symbol.Point();
        }
    }
    if (BreakEvenAtPipsProfit > 0)
    {
        if (position.PriceOpen() - m_symbol.Ask() >= BreakEvenAtPipsProfit * m_symbol.Point() 
            && position.StopLoss() > position.PriceOpen())
        {
            Print("sl2");
            sl = position.PriceOpen() - BreakEvenAddPips * m_symbol.Point();
        }
    }
        
    if (HiddenProfitTargetPips > 0)
    {
        if (position.PriceOpen() - m_symbol.Ask() >= HiddenProfitTargetPips * m_symbol.Point()) 
        {
            Print("sl3");
            closePosition = true;
            m_trade.PositionClose(position.Symbol());
        }
    }     
    if (HiddenStopLossPips > 0)
    {
        if (m_symbol.Ask() - position.PriceOpen() >= HiddenStopLossPips * m_symbol.Point()) 
        {
            Print("sl4");
            closePosition = true;
            m_trade.PositionClose(position.Symbol());
        }
    }
    
    if (!closePosition)
    {
        if ((sl != EMPTY_VALUE && sl != position.StopLoss())
            || (tp != EMPTY_VALUE && tp != position.TakeProfit()))
            return true;
    }
    return false;
}
//+------------------------------------------------------------------+

