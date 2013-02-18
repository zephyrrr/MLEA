//+------------------------------------------------------------------+
//|                                      FXCOMBOBreakoutTrailing.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

#include <ExpertModel\ExpertModel.mqh>
#include <ExpertModel\ExpertModelTrailing.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
 
class CFXCOMBOBreakoutTrailing : public CExpertModelTrailing
{
private:
    double ATRTrailingFactor2;
    int MaxPipsTrailing2;
    int MinPipsTrailing2;
    int gi_428;
    int gi_432;
    
    CiATR m_iATR;
    datetime m_lastModifyTime;
public:
                      CFXCOMBOBreakoutTrailing();
                      ~CFXCOMBOBreakoutTrailing();
    virtual bool      ValidationSettings();
    virtual bool      InitIndicators(CIndicators* indicators);
  
    virtual bool      CheckTrailingStopLong(CTableOrder* order,double& sl,double& tp);
    virtual bool      CheckTrailingStopShort(CTableOrder* order,double& sl,double& tp);
};
void CFXCOMBOBreakoutTrailing::CFXCOMBOBreakoutTrailing()
{
    m_lastModifyTime = 0;
}

void CFXCOMBOBreakoutTrailing::~CFXCOMBOBreakoutTrailing()
{
}

bool CFXCOMBOBreakoutTrailing::ValidationSettings()
{
    if (!CExpertModelTrailing::ValidationSettings())
        return false;
    return(true);
}

bool CFXCOMBOBreakoutTrailing::InitIndicators(CIndicators* indicators)
{
    if(indicators==NULL) 
        return(false);
    bool ret = true;
    
    m_iATR.Create(m_symbol.Name(), PERIOD_H1, 19);
    indicators.Add(GetPointer(m_iATR));
    
    ATRTrailingFactor2 = 4.7;
    MaxPipsTrailing2 = 180 * GetPointOffset(m_symbol.Digits());
    MinPipsTrailing2 = 10 * GetPointOffset(m_symbol.Digits());
    gi_428 = 270 * GetPointOffset(m_symbol.Digits());
    gi_432 = 20 * GetPointOffset(m_symbol.Digits());
    
    return ret;
}

bool CFXCOMBOBreakoutTrailing::CheckTrailingStopLong(CTableOrder* order,double& sl,double& tp)
{
    sl = EMPTY_VALUE;
    tp = EMPTY_VALUE;
    
    datetime now = TimeCurrent();
    if (now < m_lastModifyTime + 300)
        return false;
        
    m_iATR.Refresh(-1);
    
    double l_iatr_236 = m_iATR.Main(1);
    double ld_92 = l_iatr_236 * ATRTrailingFactor2;
    
    double ld_36 = m_symbol.Point();
    
    ld_92 = l_iatr_236 * ATRTrailingFactor2;
    if (ld_92 > MaxPipsTrailing2 * ld_36) 
        ld_92 = MaxPipsTrailing2 * ld_36;
    if (ld_92 < MinPipsTrailing2 * ld_36) 
        ld_92 = MinPipsTrailing2 * ld_36;
    if (m_symbol.Bid() - order.Price() > gi_428 * ld_36) 
        ld_92 = gi_432 * ld_36;
    double l_price_100 = NormalizeDouble(m_symbol.Bid() - ld_92, m_symbol.Digits());

    if (m_symbol.Bid() - order.Price() > ld_92) 
    {
        if (order.StopLoss() < l_price_100) 
        {
            sl = l_price_100;
            m_lastModifyTime = TimeCurrent();
            
            Debug("CFXCOMBOBreakoutTrailing set long sl = " + DoubleToString(sl, 4));
            return true;
        }
    }
                        
    return false;
}

bool CFXCOMBOBreakoutTrailing::CheckTrailingStopShort(CTableOrder* order,double& sl,double& tp)
{
    sl = EMPTY_VALUE;
    tp = EMPTY_VALUE;
    
    datetime now = TimeCurrent();
    if (now < m_lastModifyTime + 300)
        return false;
        
    m_iATR.Refresh(-1);
    
    double l_iatr_236 = m_iATR.Main(1);
    double ld_92 = l_iatr_236 * ATRTrailingFactor2;
    
    double ld_36 = m_symbol.Point();
    
    ld_92 = l_iatr_236 * ATRTrailingFactor2;
    if (ld_92 > MaxPipsTrailing2 * ld_36) 
        ld_92 = MaxPipsTrailing2 * ld_36;
    if (ld_92 < MinPipsTrailing2 * ld_36) 
        ld_92 = MinPipsTrailing2 * ld_36;
    if (order.Price() - m_symbol.Ask() > gi_428 * ld_36) 
        ld_92 = gi_432 * ld_36;
    double l_price_100 = NormalizeDouble(m_symbol.Ask() + ld_92, m_symbol.Digits());

    //Print(m_symbol.Bid(), ", ", order.Price(), ", ", ld_92, ", ", order.StopLoss(), ", ", l_price_100);
    
    if (order.Price() - m_symbol.Ask() > ld_92) 
    {
        if (order.StopLoss() > l_price_100) 
        {
            sl = l_price_100;
            m_lastModifyTime = TimeCurrent();
            
            Debug("CFXCOMBOBreakoutTrailing set short sl = " + DoubleToString(sl, 4));
            return true;
        }
    }
                        
    return false;
}
//+------------------------------------------------------------------+

