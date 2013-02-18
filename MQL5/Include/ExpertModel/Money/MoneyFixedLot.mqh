//+------------------------------------------------------------------+
//|                                                MoneyFixedLot.mqh |
//|                      Copyright ?2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                              Revision 2010.10.08 |
//+------------------------------------------------------------------+
#include <ExpertModel\ExpertModelMoney.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Trading with fixed trade volume                            |
//| Type=Money                                                       |
//| Name=FixLot                                                      |
//| Class=CMoneyFixedLot                                             |
//| Page=                                                            |
//| Parameter=Percent,double,10.0                                    |
//| Parameter=Lots,double,0.1                                        |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CMoneyFixedLot.                                            |
//| Appointment: Class money managment with fixed lot.               |
//|              Derives from class CExpertMoney.                    |
//+------------------------------------------------------------------+
class CMoneyFixedLot : public CExpertModelMoney
  {
protected:
   //--- input parameters
   double            m_lots;

public:
                     CMoneyFixedLot();
                     CMoneyFixedLot(double lots);
   //---    
   void              Lots(double lots) { m_lots=lots; }
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
void CMoneyFixedLot::CMoneyFixedLot()
  {
//--- set default inputs
   m_lots=0.1;
  }
void CMoneyFixedLot::CMoneyFixedLot(double lots)
{
    m_lots = lots;
}
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if settings are correct, false otherwise.           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CMoneyFixedLot::ValidationSettings()
  {
   if(!CExpertMoney::ValidationSettings()) return(false);
//--- initial data checks
   if(m_lots<m_symbol.LotsMin() || m_lots>m_symbol.LotsMax())
     {
      //printf(__FUNCTION__+": lots amount must be in the range from %f to %f",m_symbol.LotsMin(),m_symbol.LotsMax());
      //return(false);
     }
   if(MathAbs(m_lots/m_symbol.LotsStep()-MathRound(m_lots/m_symbol.LotsStep()))>1.0E-10)
     {
      printf(__FUNCTION__+": lots amount is not corresponding with lot step %f",m_symbol.LotsStep());
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Getting lot size for open long position.                         |
//| INPUT:  no.                                                      |
//| OUTPUT: lot-if successful, 0.0 otherwise.                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double CMoneyFixedLot::CheckOpenLong(double price,double sl)
  {
   return(m_lots);
  }
//+------------------------------------------------------------------+
//| Getting lot size for open short position.                        |
//| INPUT:  no.                                                      |
//| OUTPUT: lot-if successful, 0.0 otherwise.                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double CMoneyFixedLot::CheckOpenShort(double price,double sl)
  {
   return(m_lots);
  }
//+------------------------------------------------------------------+
