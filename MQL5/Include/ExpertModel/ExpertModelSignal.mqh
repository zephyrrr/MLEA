//+------------------------------------------------------------------+
//|                                            ExpertModelSignal.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

#include <Expert\Expert.mqh>
#include <Expert\ExpertSignal.mqh>
#include "TableOrders.mqh"

class CExpertModelSignal : public CExpertSignal
{
protected:
    CExpert* m_expert;
public:
    void SetExpertModel(CExpert *expert) { m_expert = expert; }    
    virtual bool      CheckCloseLong(CTableOrder* order, double& price)  { return(false); }
    virtual bool      CheckCloseShort(CTableOrder* order, double& price) { return(false); }
    
    virtual bool  CheckCloseOrderLong() { return(false); }
    virtual bool  CheckCloseOrderShort() { return(false); }

    virtual void PreProcess() { return; }       
};
