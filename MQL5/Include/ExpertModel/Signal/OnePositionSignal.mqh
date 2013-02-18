//+------------------------------------------------------------------+
//|                                            OnePositionSignal.mqh |
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

class COnePositionSignal : public CExpertModelSignal
  {
private:
    CPositionInfo m_positionInfo;
    CSymbolInfo m_symbolInfo;
public:
                     COnePositionSignal();
                    ~COnePositionSignal();
   
   //---
   virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseLong(double& price);
   virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseShort(double& price);
  };
//+------------------------------------------------------------------+
//| Constructor CSignalMA.                                           |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void COnePositionSignal::COnePositionSignal()
{
}
//+------------------------------------------------------------------+
//| Destructor CSignalMA.                                            |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void COnePositionSignal::~COnePositionSignal()
{
}

//+------------------------------------------------------------------+
//| Check conditions for long position open.                         |
//| INPUT:  price      - refernce for price,                         |
//|         sl         - refernce for stop loss,                     |
//|         tp         - refernce for take profit,                   |
//|         expiration - refernce for expiration.                    |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool COnePositionSignal::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
{
    if (m_positionInfo.Select(Symbol()))
        return false;
    price = 0;
    m_symbolInfo.Name(Symbol());
    m_symbolInfo.RefreshRates();
    tp = m_symbolInfo.Ask() + 0.0201;
    sl = m_symbolInfo.Ask() - 0.0156;
    
    return true;
}

//+------------------------------------------------------------------+
//| Check conditions for short position open.                        |
//| INPUT:  price      - refernce for price,                         |
//|         sl         - refernce for stop loss,                     |
//|         tp         - refernce for take profit,                   |
//|         expiration - refernce for expiration.                    |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool COnePositionSignal::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
{
    return false;
    if (m_positionInfo.Select(Symbol()))
        return false;
    price = 0;
    return true;
}
  
//+------------------------------------------------------------------+
//| Check conditions for long position close.                        |
//| INPUT:  price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool COnePositionSignal::CheckCloseLong(double& price)
{
    return false;
}

//+------------------------------------------------------------------+
//| Check conditions for short position close.                       |
//| INPUT:  price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool COnePositionSignal::CheckCloseShort(double& price)
{
    return false;
}

