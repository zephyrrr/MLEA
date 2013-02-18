//+------------------------------------------------------------------+
//|                                            PipesMinerEEMoney.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <ExpertModel\ExpertModel.mqh>
#include <ExpertModel\ExpertModelMoney.mqh>
#include <Trade\DealInfo.mqh>

class CPipesMinerEEMoney : public CExpertModelMoney
{
private:
    double            m_lots;
    CDealInfo       m_dealInfo;
    double m_martingale;
public:
                     CPipesMinerEEMoney();
   void              Lots(double lots) { m_lots=lots; }
   void              Martingale(double martingale) { m_martingale=martingale; }
   double            GetLot();
   virtual bool      ValidationSettings();
   virtual double    CheckOpenLong(double price,double sl);
   virtual double    CheckOpenShort(double price,double sl);
};

void CPipesMinerEEMoney::CPipesMinerEEMoney()
{
   m_lots = 1;
   m_martingale = 1;
}

bool CPipesMinerEEMoney::ValidationSettings()
{
    if(!CExpertMoney::ValidationSettings()) return(false);

    if(m_lots<m_symbol.LotsMin() || m_lots>m_symbol.LotsMax())
    {
        printf(__FUNCTION__+": lots amount must be in the range from %f to %f",m_symbol.LotsMin(),m_symbol.LotsMax());
        return(false);
    }
    if(MathAbs(m_lots/m_symbol.LotsStep()-MathRound(m_lots/m_symbol.LotsStep()))>1.0E-10)
    {
        printf(__FUNCTION__+": lots amount is not corresponding with lot step %f",m_symbol.LotsStep());
        return(false);
    }
    return(true);
}

double CPipesMinerEEMoney::GetLot()
{
    CExpertModel* em = (CExpertModel *)m_expert;
    
    HistorySelect(0, TimeCurrent());
    int cnt = HistoryDealsTotal();
    for(int i = cnt - 1; i >= 0; --i)
    {
        m_dealInfo.SelectByIndex(i);
        if (m_dealInfo.Entry() == DEAL_ENTRY_OUT && m_dealInfo.Magic() == em.Magic() && m_dealInfo.Symbol() == m_symbol.Name())
        {
            if (m_dealInfo.Profit() < 0)
                return m_martingale * m_lots;
            else 
                return m_lots;
        }
    }
    return(m_lots);
}
double CPipesMinerEEMoney::CheckOpenLong(double price,double sl)
{
    return GetLot();
}

double CPipesMinerEEMoney::CheckOpenShort(double price,double sl)
{
   return GetLot();
}
