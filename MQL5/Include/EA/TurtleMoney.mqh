//+------------------------------------------------------------------+
//|                                                  TurtleMoney.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

//+------------------------------------------------------------------+
//|                                                MoneyFixedLot.mqh |
//|                      Copyright ?2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                              Revision 2010.10.08 |
//+------------------------------------------------------------------+
#include <ExpertModel\ExpertModel.mqh>
#include <ExpertModel\ExpertModelMoney.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>


class CTurtleMoney : public CExpertModelMoney
{
private:
    double m_PDN;
    double m_N;
    double TR();
    double TR(int idx);

    double GetLots();
    double GetUnitLot();
    double N();
    
    double MaxLotSingleMarket;
    double MaxLotAllMakert;
public:
                     CTurtleMoney();
   virtual bool      ValidationSettings();
   //---
   virtual double    CheckOpenLong(double price,double sl);
   virtual double    CheckOpenShort(double price,double sl);
  };

void CTurtleMoney::CTurtleMoney()
{
    MaxLotSingleMarket = 6;
    MaxLotAllMakert = 15;
}

bool CTurtleMoney::ValidationSettings()
{
   return CExpertModelMoney::ValidationSettings();
}

double CTurtleMoney::CheckOpenLong(double price,double sl)
{
    return GetLots();
}

double CTurtleMoney::CheckOpenShort(double price,double sl)
{
    return GetLots();
}

double CTurtleMoney::GetLots(void)
{
    return 1;
    
    double ret = 0;
    CExpertModel* em = (CExpertModel *)m_expert;
    
    double singleLots = GetPositionVolumn(m_symbol.Name());
    double allLots = GetAllPositionVolumn();
    
    ret = GetUnitLot();
    if (singleLots < MaxLotSingleMarket)
    {
        ret = MathMin(ret, MaxLotSingleMarket - singleLots);
        if (ret < MaxLotAllMakert)
        {
            ret = MathMin(ret, MaxLotAllMakert - ret);
        }
    }
    else
    {
        ret = 0;
    }
    
    //Print("HaveUnit = ", haveUnit, " and Unit = ", GetUnitLot(), " and Lots = ", ret, " and allpos = ", allLots);
    return ret;
}

double CTurtleMoney::GetUnitLot()
{
    double n = N();
    double tickValue = m_symbol.TickValue();
    double point = m_symbol.Point();
    double lots = (0.01 * m_account.Balance()) / (n * tickValue) * point;
    lots = MathRound(lots / m_symbol.LotsStep()) * m_symbol.LotsStep();
    //if (lots*(1000*Ask)>AccountBalance()) { lots=AccountBalance()/(1000*Ask); lots=MathFloor(lots*10)/10; } 
    //if (lots>MaxLotsPerTrade) lots=MaxLotsPerTrade;
    lots = MathMax(lots, m_symbol.LotsMin());
    lots = MathMin(lots, m_symbol.LotsMax());
    
    //if (lots > 2)
    //{
        //Print("N = ", n, " tick = ", tickValue, " point = ", point, " balance = ", m_account.Balance());
    //}
    return (lots);
}

double CTurtleMoney::N()
{
    int days = 20;
    if (m_PDN == 0) 
    {
        for (int i=0; i < days; i++) 
        {
            m_PDN += TR(i + 2);
        }
        m_PDN = m_PDN / days;
    }
    m_N = ((days - 1) * m_PDN + TR()) / days;
    if (isNewBar(m_symbol.Name(), m_period))
    {
        m_PDN = m_N;
    }
    //Print("m_PDN = ", m_PDN, ", N = ", m_N);
    
    return m_N;
 }
 
double CTurtleMoney::TR()
{
    return TR(1);
}

double CTurtleMoney::TR(int idx)
{ 
    double H = iHigh(m_symbol.Name(), m_period, idx);
    double L = iLow(m_symbol.Name(), m_period, idx);
    double PDC = iClose(m_symbol.Name(), m_period, idx + 1);
    return MathMax(MathMax(H - L, H - PDC), PDC - L);
}

