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
#include <Expert\ExpertMoney.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Turtle\TurtleN.mqh>

class CTurtleMoney : public CExpertMoney
{
private:
    CTurtleN* m_turtleN;
    
    double GetLots();
    double MaxUnitsSingleMarket;
public:
                     CTurtleMoney();
    void             Init(CTurtleN* turtleN) { m_turtleN = turtleN; }
   virtual bool      ValidationSettings();
   //---
   virtual double    CheckOpenLong(double price,double sl);
   virtual double    CheckOpenShort(double price,double sl);
  };
//+------------------------------------------------------------------+
//| Constructor CMoneyFixedLot.                                      |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CTurtleMoney::CTurtleMoney()
{
    MaxUnitsSingleMarket = 4;
}
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if settings are correct, false otherwise.           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTurtleMoney::ValidationSettings()
{
    if(m_turtleN == NULL)
    {
        printf(__FUNCTION__+": TurtleN is Null!");
        return(false);
    }

   return CExpertMoney::ValidationSettings();
}
double CTurtleMoney::CheckOpenLong(double price,double sl)
{
    return GetLots();
}
//+------------------------------------------------------------------+
//| Getting lot size for open short position.                        |
//| INPUT:  no.                                                      |
//| OUTPUT: lot-if successful, 0.0 otherwise.                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double CTurtleMoney::CheckOpenShort(double price,double sl)
{
    return GetLots();
}

double CTurtleMoney::GetLots(void)
{
    double ret = 0;
    double haveUnit = m_turtleN.GetPositionUnit(POSITION_TYPE_BUY) 
        + m_turtleN.GetPositionUnit(POSITION_TYPE_SELL);
    double units = 0;
    if (haveUnit < MaxUnitsSingleMarket)
    {
        units = m_turtleN.GetUnit();
        ret = units * MathMin(1, MaxUnitsSingleMarket - haveUnit);
    }
    
    //Print("HaveUnit = ", haveUnit, " and Unit = ", units, " and Lots = ", ret);
    return ret;
}


