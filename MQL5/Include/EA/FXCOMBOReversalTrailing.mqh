//+------------------------------------------------------------------+
//|                                      FXCOMBOReversalTrailing.mqh |
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
 
class CFXCOMBOReversalTrailing : public CExpertModelTrailing
{
private:
    CiATR m_iATR;
    datetime m_lastModifyTime;
    
    int MaxPipsTrailing3;
    int MinPipsTrailing3;
    double gd_524;
public:
                      CFXCOMBOReversalTrailing();
                      ~CFXCOMBOReversalTrailing();
    virtual bool      ValidationSettings();
    virtual bool      InitIndicators(CIndicators* indicators);
  
    virtual bool      CheckTrailingStopLong(CTableOrder* order,double& sl,double& tp);
    virtual bool      CheckTrailingStopShort(CTableOrder* order,double& sl,double& tp);
};
void CFXCOMBOReversalTrailing::CFXCOMBOReversalTrailing()
{
    m_lastModifyTime = 0;
}

void CFXCOMBOReversalTrailing::~CFXCOMBOReversalTrailing()
{
}

bool CFXCOMBOReversalTrailing::ValidationSettings()
{
    if (!CExpertModelTrailing::ValidationSettings())
        return false;
    return(true);
}

bool CFXCOMBOReversalTrailing::InitIndicators(CIndicators* indicators)
{
    if(indicators==NULL) 
        return(false);
    bool ret = true;
    
    ret &= m_iATR.Create(m_symbol.Name(), PERIOD_H1, 19);
    ret &= indicators.Add(GetPointer(m_iATR));
    
    MaxPipsTrailing3 = 60 * GetPointOffset(m_symbol.Digits());
    MinPipsTrailing3 = 20 * GetPointOffset(m_symbol.Digits());
    gd_524 = 13.0;
    
    return ret;
}

bool CFXCOMBOReversalTrailing::CheckTrailingStopLong(CTableOrder* order,double& sl,double& tp)
{
    sl = EMPTY_VALUE;
    tp = EMPTY_VALUE;
    
    datetime now = TimeCurrent();
    if (now < m_lastModifyTime + 300)
        return false;
        
    double ld_36 = m_symbol.Point();
    
    double l_iatr_276 = m_iATR.Main(1);
    double ld_124 = l_iatr_276 * gd_524;
    
    if (ld_124 > MaxPipsTrailing3 * ld_36) 
        ld_124 = MaxPipsTrailing3 * ld_36;
    if (ld_124 < MinPipsTrailing3 * ld_36) 
        ld_124 = MinPipsTrailing3 * ld_36;
    double l_price_132 = NormalizeDouble(m_symbol.Bid() - ld_124, m_symbol.Digits());

    //Print(m_symbol.Bid(), ", ", order.Price(), ", ", ld_124, ", ", order.StopLoss(), ", ", l_price_132);
    
    if (m_symbol.Bid() - order.Price() > ld_124) 
    {
        if (order.StopLoss() < l_price_132) 
        {
            sl = l_price_132;
            m_lastModifyTime = TimeCurrent();
            
            Debug("CFXCOMBOReversalTrailing set long sl = " + DoubleToString(sl, 4));
            return true;
        }
    }
                        
    return false;
}

bool CFXCOMBOReversalTrailing::CheckTrailingStopShort(CTableOrder* order,double& sl,double& tp)
{
    sl = EMPTY_VALUE;
    tp = EMPTY_VALUE;
    
    datetime now = TimeCurrent();
    if (now < m_lastModifyTime + 300)
        return false;
        
    double ld_36 = m_symbol.Point();
    
    double l_iatr_276 = m_iATR.Main(1);
    double ld_124 = l_iatr_276 * gd_524;
    
    if (ld_124 > MaxPipsTrailing3 * ld_36) 
        ld_124 = MaxPipsTrailing3 * ld_36;
    if (ld_124 < MinPipsTrailing3 * ld_36) 
        ld_124 = MinPipsTrailing3 * ld_36;
    double l_price_132 = NormalizeDouble(m_symbol.Ask() + ld_124, m_symbol.Digits());

    if (order.Price() - m_symbol.Ask() > ld_124) 
    {
        if (order.StopLoss() > l_price_132) 
        {
            sl = l_price_132;
            m_lastModifyTime = TimeCurrent();
            
            Debug("CFXCOMBOReversalTrailing set long sl = " + DoubleToString(sl, 4));
            return true;
        }
    }
                        
    return false;
}
//+------------------------------------------------------------------+

