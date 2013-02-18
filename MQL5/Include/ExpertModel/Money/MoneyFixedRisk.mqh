//+------------------------------------------------------------------+
//|                                               MoneyFixedRisk.mqh |
//|                      Copyright ?2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                              Revision 2010.10.08 |
//+------------------------------------------------------------------+
#include <ExpertModel\ExpertModelMoney.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Trading with fixed risk                                    |
//| Type=Money                                                       |
//| Name=FixRisk                                                     |
//| Class=CMoneyFixedRisk                                            |
//| Page=                                                            |
//| Parameter=Percent,double,10.0,Risk percentage                    |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CMoneyFixedRisk.                                           |
//| Purpose: Class of money management with fixed percent risk.      |
//|              Derives from class CExpertMoney.                    |
//+------------------------------------------------------------------+
class CMoneyFixedRisk : public CExpertModelMoney
  {
public:
   //---
   virtual double    CheckOpenLong(double price,double sl);
   virtual double    CheckOpenShort(double price,double sl);
  };
//+------------------------------------------------------------------+
//| Getting lot size for open long position.                         |
//| INPUT:  no.                                                      |
//| OUTPUT: lot-if successful, 0.0 otherwise.                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double CMoneyFixedRisk::CheckOpenLong(double price,double sl)
  {
   if(m_symbol==NULL) return(0.0);
//--- select lot size
   double lot;
   double minvol=m_symbol.LotsMin();
   if(sl==0.0)
      lot=minvol;
   else
     {
      double loss;
      if(price==0.0)
         loss=-m_account.OrderProfitCheck(m_symbol.Name(),ORDER_TYPE_BUY,1.0,m_symbol.Ask(),sl);
      else
         loss=-m_account.OrderProfitCheck(m_symbol.Name(),ORDER_TYPE_BUY,1.0,price,sl);
      double stepvol=m_symbol.LotsStep();
      lot=MathFloor(m_account.Balance()*m_percent/loss/100.0/stepvol)*stepvol;
     }
//---
   if(lot<minvol) lot=minvol;
//---
   double maxvol=m_symbol.LotsMax();
   if(lot>maxvol) lot=maxvol;
//--- return trading volume
   return(lot);
  }
//+------------------------------------------------------------------+
//| Getting lot size for open short position.                        |
//| INPUT:  no.                                                      |
//| OUTPUT: lot-if successful, 0.0 otherwise.                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double CMoneyFixedRisk::CheckOpenShort(double price,double sl)
  {
   if(m_symbol==NULL) return(0.0);
//--- select lot size
   double lot;
   double minvol=m_symbol.LotsMin();
   if(sl==0.0)
      lot=minvol;
   else
     {
      double loss;
      if(price==0.0)
         loss=-m_account.OrderProfitCheck(m_symbol.Name(),ORDER_TYPE_SELL,1.0,m_symbol.Bid(),sl);
      else
         loss=-m_account.OrderProfitCheck(m_symbol.Name(),ORDER_TYPE_SELL,1.0,price,sl);
      double stepvol=m_symbol.LotsStep();
      lot=MathFloor(m_account.Balance()*m_percent/loss/100.0/stepvol)*stepvol;
     }
//---
   if(lot<minvol) lot=minvol;
//---
   double maxvol=m_symbol.LotsMax();
   if(lot>maxvol) lot=maxvol;
//--- return trading volume
   return(lot);
  }
//+------------------------------------------------------------------+
