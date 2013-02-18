//+------------------------------------------------------------------+
//|                                               ExpertTrailing.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

#include <Expert\Expert.mqh>
#include <Expert\ExpertTrailing.mqh>
#include "TableOrders.mqh"

class CExpertModelTrailing : public CExpertTrailing
{
protected:
    CExpert* m_expert;
public:
    void SetExpertModel(CExpert *expert) { m_expert = expert; }  
    virtual bool      CheckTrailingStopLong(CTableOrder* order, double& sl,double& tp)  { return(false); }
    virtual bool      CheckTrailingStopShort(CTableOrder* order, double& sl,double& tp) { return(false); }      
};
