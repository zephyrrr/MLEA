//+------------------------------------------------------------------+
//|                                           ForexMorningSignal.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#include <Expert\ExpertSignal.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\DealInfo.mqh>

#include <Indicators\Oscilators.mqh>
 #include <Indicators\TimeSeries.mqh>
 
// GBPUSD, M15
class CForexMorningSignal : public CExpertSignal
  {
private:
    CiMomentum  m_iMomentum;
    CiCCI m_iCCI;
    CiATR m_iATR;
    CiHigh m_iHigh;
    CiLow m_iLow;
    
    int CheckMomentum();
    int CheckCCI();
    bool IsLongCandleBefore();
    
    bool m_checkTimeResultInCheckLong;
    bool CheckTime(bool isBuy);
    bool CheckTime();
    
    string GetNowStringAccordPeriod();
    string m_lastNow;
    int m_lastDealDay;
    MqlDateTime m_dtStruct;
    
    int GetSignal();
    
public:
                     CForexMorningSignal();
                    ~CForexMorningSignal();
   virtual bool      ValidationSettings();
   //---
   virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseLong(double& price);
   virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseShort(double& price);
  };

void CForexMorningSignal::CForexMorningSignal()
{
   m_iMomentum.Create(m_symbol.Name(), m_period, 60, PRICE_TYPICAL);
    //m_iMomentum.BufferResize(1000);
    m_iCCI.Create(m_symbol.Name(), m_period, 60, PRICE_TYPICAL);
    //m_iCCI.BufferResize(1000);
    m_iATR.Create(m_symbol.Name(), m_period, 20);
    //m_iATR.BufferResize(1000);
    
    m_iHigh.Create(m_symbol.Name(), m_period);
    m_iLow.Create(m_symbol.Name(), m_period);
}

void CForexMorningSignal::~CForexMorningSignal()
{
}
bool CForexMorningSignal::ValidationSettings()
{
    if(!CExpertSignal::ValidationSettings()) 
        return(false);
        
    if(m_iMomentum.Handle() == -1 || m_iCCI.Handle() == -1)
    {
        printf(__FUNCTION__+": Indicators should not be Null!");
        return(false);
    }
    return(true);
}


int CForexMorningSignal::CheckMomentum() 
{
    m_iMomentum.Refresh(-1);
    double l_imomentum_0 = m_iMomentum.Main(1);
    double ld_8 = 100.0 * (l_imomentum_0 - 100.0);
    //Print("Momentum ", l_imomentum_0, " : ", ld_8);
    if (MathAbs(ld_8) > 80.0) 
    {
        //Debug("Momentum is higher/lower than allowed");
        return (0);
    }
    if (ld_8 > 0.0) return (1);
    if (ld_8 < 0.0) return (-1);
    return (0);
}

int CForexMorningSignal::CheckCCI() 
{
    m_iCCI.Refresh(-1);
    double l_icci_0 = m_iCCI.Main(1);
    //Print("CCI: ", l_icci_0);
    if (l_icci_0 > 0.0) return (1);
    if (l_icci_0 < 0.0) return (-1);
    return (0);
}

string CForexMorningSignal::GetNowStringAccordPeriod()
{
    datetime now = TimeGMT();
 
    string ret = TimeToString(now, TIME_DATE);

    if (m_period == PERIOD_D1) 
        return (ret);
    
    TimeToStruct(now, m_dtStruct);
    if (m_period == PERIOD_H4 || m_period == PERIOD_H1) 
    {
        ret = ret + IntegerToString(m_dtStruct.hour, 2);
    }
    else if (m_period == PERIOD_M30 || m_period == PERIOD_M15 || m_period == PERIOD_M5 || m_period == PERIOD_M1) 
    {
        ret = TimeToString(now, TIME_DATE | TIME_MINUTES);
    }
    return ret;
}

bool CForexMorningSignal::CheckTime() 
{
    string nows = GetNowStringAccordPeriod();
    if(nows == m_lastNow)
        return false;
    m_lastNow = nows;
    
    if (m_dtStruct.min != 30 || m_dtStruct.hour != 7) 
        return false;
    if (m_dtStruct.day == m_lastDealDay)
        return false;
             
    return true;
}

bool CForexMorningSignal::CheckTime(bool isBuy) 
{
    if (isBuy)
    {
        m_checkTimeResultInCheckLong = CheckTime();
        return m_checkTimeResultInCheckLong;
    }
    else
    {
        return m_checkTimeResultInCheckLong;
    }
}

int CForexMorningSignal::GetSignal() 
{
    int li_ret_0 = CheckMomentum();
    int li_4 = CheckCCI();
    
    if (li_ret_0 != li_4) 
        return (0);
    
    if (li_ret_0 != 0)
        if (IsLongCandleBefore()) 
            return (0);
        
    return (li_ret_0);
}

bool CForexMorningSignal::IsLongCandleBefore() 
{
    m_iHigh.Refresh(-1);
    m_iLow.Refresh(-1);
    m_iATR.Refresh(-1);
    
    double ld_12;
    double l_iatr_0 = m_iATR.Main(1);
    for (int i = 1; i < 15; i++) 
    {
        ld_12 = m_iHigh.GetData(i) - m_iLow.GetData(i);
        if (ld_12 >= l_iatr_0 * 3) 
            return true;
    }
    return false;
}

bool CForexMorningSignal::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
{
    if (!CheckTime(true))
        return false;
    
    int signal = GetSignal();
    if (signal > 0)
    {
        m_symbol.RefreshRates();
        
        price = m_symbol.Ask();
        tp = price + 550 * m_symbol.Point();
        sl = price - 550 * m_symbol.Point();
        
        m_lastDealDay = m_dtStruct.day;
        return true;
    }

    return false;
}

bool CForexMorningSignal::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
{
    if (!CheckTime(false))
        return false;
    
    int signal = GetSignal();
    if (signal < 0)
    {
        m_symbol.RefreshRates();
        
        price = m_symbol.Bid();
        tp = price - 550 * m_symbol.Point();
        sl = price + 550 * m_symbol.Point();
        
        m_lastDealDay = m_dtStruct.day;
        return true;
    }

    return false;
}
 
bool CForexMorningSignal::CheckCloseLong(double& price)
{
    return false;
}

bool CForexMorningSignal::CheckCloseShort(double& price)
{
    
    return false;
}
