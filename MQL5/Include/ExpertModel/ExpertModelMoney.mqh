//+------------------------------------------------------------------+
//|                                                  ExpertMoney.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

#include <Expert\Expert.mqh>
#include <Expert\ExpertMoney.mqh>
//#include "ExpertModel.mqh"

class CExpertModelMoney : public CExpertMoney
{
protected:
    CExpert* m_expert;
public:
    void SetExpertModel(CExpert *expert) { m_expert = expert; }    
    virtual double CheckClose(CPositionInfo* position);
};

double CExpertModelMoney::CheckClose(CPositionInfo* position)
{
    return(0.0);
}
