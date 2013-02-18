//+------------------------------------------------------------------+
//|                                        FXCOMBOReversalSignal.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#include <ExpertModel\ExpertModelSignal.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\DealInfo.mqh>

#include <Indicators\Oscilators.mqh>
#include <Indicators\TimeSeries.mqh>

#include <ExpertModel\ExpertModel.mqh>

class CFXCOMBOReversalSignal : public CExpertModelSignal
  {
private:
    CiBands m_iBand;
    CiHigh m_iHigh;
    CiLow m_iLow;
    
    int TakeProfit;
    int StopLoss;
    int gi_540;
    int gi_536;
    
    bool GetOpenSignal(int wantSignal);
    bool GetCloseSignal(int wantSignal);
public:
                     CFXCOMBOReversalSignal();
                    ~CFXCOMBOReversalSignal();
   virtual bool      ValidationSettings();
   virtual bool      InitIndicators(CIndicators* indicators);
   
   virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseLong(CTableOrder* t, double& price);
   virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseShort(CTableOrder* t, double& price);
  };

void CFXCOMBOReversalSignal::CFXCOMBOReversalSignal()
{
}

void CFXCOMBOReversalSignal::~CFXCOMBOReversalSignal()
{
}

bool CFXCOMBOReversalSignal::ValidationSettings()
{
    if(!CExpertSignal::ValidationSettings()) 
        return(false);
        
    if (false)
    {
      printf(__FUNCTION__+": Indicators should not be Null!");
      return(false);
    }
    return(true);
}

bool CFXCOMBOReversalSignal::InitIndicators(CIndicators* indicators)
{
    if(indicators==NULL) 
        return(false);
    bool ret = true;
    
    ret &= m_iBand.Create(m_symbol.Name(), PERIOD_H1, 26, 0, 2, PRICE_CLOSE);
    ret &= m_iHigh.Create(m_symbol.Name(), PERIOD_H1);
    ret &= m_iLow.Create(m_symbol.Name(), PERIOD_H1);
    
    ret &= indicators.Add(GetPointer(m_iBand));
    ret &= indicators.Add(GetPointer(m_iHigh));
    ret &= indicators.Add(GetPointer(m_iLow));
    
    TakeProfit = 160 * GetPointOffset(m_symbol.Digits());
    StopLoss = 70 * GetPointOffset(m_symbol.Digits());
    gi_540 = 30 * GetPointOffset(m_symbol.Digits());
    gi_536 = -3 * GetPointOffset(m_symbol.Digits());
    
    return ret;
}

bool CFXCOMBOReversalSignal::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
{
    if (GetOpenSignal(1))
    {
        price = m_symbol.Ask();
        tp = price + TakeProfit * m_symbol.Point();
        sl = price - StopLoss * m_symbol.Point();
        
        Debug("CFXCOMBOReversalSignal open long with price = " + DoubleToString(price, 4) + " and tp = " + DoubleToString(tp, 4) + " and sl = " + DoubleToString(sl, 4));
        return true;
    }
    
    return false;
}

bool CFXCOMBOReversalSignal::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
{
    if (GetOpenSignal(-1))
    {
        price = m_symbol.Bid();
        tp = price - TakeProfit * m_symbol.Point();
        sl = price + StopLoss * m_symbol.Point();
        
        Debug("CFXCOMBOReversalSignal open short with price = " + DoubleToString(price, 4) + " and tp = " + DoubleToString(tp, 4) + " and sl = " + DoubleToString(sl, 4));
        return true;
    }
    
    return false;
}

bool CFXCOMBOReversalSignal::CheckCloseLong(CTableOrder* t, double& price)
{
    if (GetCloseSignal(1))
    {
        price = m_symbol.Bid();
        
        Debug("CFXCOMBOReversalSignal close long with price = " + DoubleToString(price, 4));
        return true;
    }
    return false;
}

bool CFXCOMBOReversalSignal::CheckCloseShort(CTableOrder* t, double& price)
{
    if (GetCloseSignal(-1))
    {
        price = m_symbol.Ask();
        
        Debug("CFXCOMBOReversalSignal close long with price = " + DoubleToString(price, 4));
        return true;
    }
    return false;
}

bool CFXCOMBOReversalSignal::GetOpenSignal(int wantSignal)
{
    int li_324 = 22;
    int li_328 = 0;
   
    MqlDateTime now;
    TimeGMT(now);
    int hour = now.hour - GetGMTOffset();
    if (hour < 0) hour += 24;
    
    if (li_324 <= li_328)
    {
        if (hour < li_324 || hour > li_328)
            return false;
    }
    else
    {
        if (hour < li_324 && hour > li_328)
            return false;
    }
      
    CExpertModel* em = (CExpertModel *)m_expert;

    m_iBand.Refresh(-1);
    m_iLow.Refresh(-1);
    m_iHigh.Refresh(-1);
    
    double ld_36 = m_symbol.Point();
    
    double l_ibands_300 = m_iBand.Upper(1);
    double l_ibands_308 = m_iBand.Lower(1);
    double l_ilow_292 = m_iLow.GetData(1);
    double l_ihigh_284 = m_iHigh.GetData(1);
    
    //Print(l_ibands_300, ", ", l_ibands_308, ", ", l_ilow_292, ", ", l_ihigh_284);
    
    if (wantSignal == 1 && em.GetOrderCount(ORDER_TYPE_BUY) < 1 && l_ibands_300 - l_ibands_308 >= gi_540 * ld_36 
        && l_ilow_292 < l_ibands_308 - gi_536 * ld_36)
    {
        return true;
    }
    else if (wantSignal == -1 && em.GetOrderCount(ORDER_TYPE_SELL) < 1 && l_ibands_300 - l_ibands_308 >= gi_540 * ld_36 
        && l_ihigh_284 > l_ibands_300 + gi_536 * ld_36) 
    {
        return true;
    }
    return false;
}

bool CFXCOMBOReversalSignal::GetCloseSignal(int wantSignal)
{
    m_iBand.Refresh(-1);
    m_iLow.Refresh(-1);
    m_iHigh.Refresh(-1);
    
    int li_324 = 22;
    int li_328 = 0;
   
    MqlDateTime now;
    TimeGMT(now);
    int hour = now.hour - GetGMTOffset();
    if (hour < 0) hour += 24;
    
    double ld_36 = m_symbol.Point();
    
    double l_ibands_300 = m_iBand.Upper(1);
    double l_ibands_308 = m_iBand.Lower(1);
    double l_ilow_292 = m_iLow.GetData(1);
    double l_ihigh_284 = m_iHigh.GetData(1);
    
    if ((li_324 <= li_328 && hour >= li_324 && hour <= li_328) || (li_324 > li_328 && (hour >= li_324 || hour <= li_328)))
    {
        if (wantSignal == 1 && l_ibands_300 - l_ibands_308 >= gi_540 * ld_36 && l_ihigh_284 > l_ibands_300 + gi_536 * ld_36)
        {
            return true;
        }
        else if (wantSignal == -1 && l_ibands_300 - l_ibands_308 >= gi_540 * ld_36 && l_ilow_292 < l_ibands_308 - gi_536 * ld_36)
        {
            return true;
        }
    }
    return false;
}
