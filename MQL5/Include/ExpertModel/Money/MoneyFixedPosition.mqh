//+------------------------------------------------------------------+
//|                                           FixedPositionMoney.mqh |
//|                       Copyright ?2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                              Revision 2010.10.08 |
//+------------------------------------------------------------------+
#include <ExpertModel\ExpertModelMoney.mqh>
#include <Trade\PositionInfo.mqh>
#include <ExpertModel\ExpertModel.mqh>
#include <Utils\Utils.mqh>

class CMoneyFixedPosition : public CExpertModelMoney
  {
protected:
   //--- input parameters
    double m_lots;
    double m_maxPositionLot;
    CPositionInfo m_position;
public:
                     CMoneyFixedPosition();
   //---
   void              Lots(double lots) { m_lots=lots; }
   void              MaxPositionLot(double maxPositionLot) { m_maxPositionLot = maxPositionLot; }
   virtual bool      ValidationSettings();
   //---
   virtual double    CheckOpenLong(double price,double sl);
   virtual double    CheckOpenShort(double price,double sl);
  };

void CMoneyFixedPosition::CMoneyFixedPosition()
{
   m_lots=5;
   m_maxPositionLot = 15;
}

bool CMoneyFixedPosition::ValidationSettings()
  {
   if(!CExpertMoney::ValidationSettings()) return(false);
//--- initial data checks
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
//--- ok
   return(true);
  }

double CMoneyFixedPosition::CheckOpenLong(double price,double sl)
{
    double all = GetAllPositionVolumn();

    double lot1 = 0;
    if (all + m_lots <= m_maxPositionLot)  
        lot1 = m_lots;
    else
        lot1 = m_maxPositionLot - all;
        
    double lot;
    if(price==0.0)
        lot=m_account.MaxLotCheck(m_symbol.Name(),ORDER_TYPE_BUY,m_symbol.Ask(),m_percent);
    else
        lot=m_account.MaxLotCheck(m_symbol.Name(),ORDER_TYPE_BUY,price,m_percent);
        
   return MathMin(lot1, lot);
}

double CMoneyFixedPosition::CheckOpenShort(double price,double sl)
{
    double all = GetAllPositionVolumn();

    double lot1 = 0;
    if (all + m_lots <= m_maxPositionLot)  
        lot1 = m_lots;
    else
        lot1 = m_maxPositionLot - all;
        
    double lot;
    if(price==0.0)
        lot=m_account.MaxLotCheck(m_symbol.Name(),ORDER_TYPE_BUY,m_symbol.Ask(),m_percent);
    else
        lot=m_account.MaxLotCheck(m_symbol.Name(),ORDER_TYPE_BUY,price,m_percent);
        
   return MathMin(lot1, lot);
}
//+------------------------------------------------------------------+
