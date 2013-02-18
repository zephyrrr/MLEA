//+------------------------------------------------------------------+
//|                                            TrailingFixedPips.mqh |
//|                      Copyright ?2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                              Revision 2010.10.08 |
//+------------------------------------------------------------------+
#include <ExpertModel\ExpertModel.mqh>
#include <ExpertModel\ExpertModelTrailing.mqh>
// wizard description start
//+----------------------------------------------------------------------+
//| Description of the class                                             |
//| Title=Trailing Stop based on fixed Stop Level                        |
//| Type=Trailing                                                        |
//| Name=FixedPips                                                       |
//| Class=CTrailingFixedPips                                             |
//| Page=                                                                |
//| Parameter=StopLevel,int,30,Stop Loss trailing level (in points)      |
//| Parameter=ProfitLevel,int,50,Take Profit trailing level (in points)  |
//+----------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CTrailingFixedPips.                                        |
//| Purpose: Class of trailing stops with fixed stop level in pips.  |
//|              Derives from class CExpertTrailing.                 |
//+------------------------------------------------------------------+
class CTrailingFixedPips : public CExpertModelTrailing
  {
protected:
   //--- input parameters
   int               m_stop_level;
   int               m_profit_level;

public:
                     CTrailingFixedPips();
                     CTrailingFixedPips(int stop_level, int profit_level);
   //--- methods of initialization of protected data
   void              StopLevel(int stop_level)     { m_stop_level=stop_level;     }
   void              ProfitLevel(int profit_level) { m_profit_level=profit_level; }
   virtual bool      ValidationSettings();
   //---
   virtual bool      CheckTrailingStopLong(CTableOrder* position,double& sl,double& tp);
   virtual bool      CheckTrailingStopShort(CTableOrder* position,double& sl,double& tp);
  };
//+------------------------------------------------------------------+
//| Constructor CTrailingFixedPips.                                  |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CTrailingFixedPips::CTrailingFixedPips()
  {
//--- set default inputs
   m_stop_level  =30;
   m_profit_level=50;
  }
  
void CTrailingFixedPips::CTrailingFixedPips(int stop_level, int profit_level)
  {
//--- set default inputs
   m_stop_level  =stop_level;
   m_profit_level=profit_level;
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if settings are correct, false otherwise.           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTrailingFixedPips::ValidationSettings()
  {
   if(!CExpertTrailing::ValidationSettings()) return(false);
//--- initial data checks
   if(m_profit_level!=0 && m_profit_level*(m_adjusted_point/m_symbol.Point())<m_symbol.StopsLevel())
     {
      printf(__FUNCTION__+": trailing Profit Level must be 0 or greater than %d",m_symbol.StopsLevel());
      return(false);
     }
   if(m_stop_level!=0 && m_stop_level*(m_adjusted_point/m_symbol.Point())<m_symbol.StopsLevel())
     {
      printf(__FUNCTION__+": trailing Stop Level must be 0 or greater than %d",m_symbol.StopsLevel());
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Checking trailing stop and/or profit for long position.          |
//| INPUT:  position - pointer for position object,                  |
//|         sl       - refernce for new stop loss,                   |
//|         tp       - refernce for new take profit.                 |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTrailingFixedPips::CheckTrailingStopLong(CTableOrder* position,double& sl,double& tp)
  {
//--- check
   if(position==NULL)  return(false);
   if(m_stop_level==0) return(false);
//---
   double delta;
   double pos_sl=position.StopLoss();
   double base  =(pos_sl==0.0)?position.Price():pos_sl;
   double price =m_symbol.Bid();
//---
   sl=EMPTY_VALUE;
   tp=EMPTY_VALUE;
   delta=m_stop_level*m_adjusted_point;
   if(price-base>delta)
     {
      sl=price-delta;
      if(m_profit_level!=0) tp=price+m_profit_level*m_adjusted_point;
     }
//---
   return(sl!=EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//| Checking trailing stop and/or profit for short position.         |
//| INPUT:  position - pointer for position object,                  |
//|         sl       - refernce for new stop loss,                   |
//|         tp       - refernce for new take profit.                 |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTrailingFixedPips::CheckTrailingStopShort(CTableOrder* position,double& sl,double& tp)
  {
//--- check
   if(position==NULL)  return(false);
   if(m_stop_level==0) return(false);
//---
   double delta;
   double pos_sl=position.StopLoss();
   double base  =(pos_sl==0.0)?position.Price():pos_sl;
   double price =m_symbol.Ask();
//---
   sl=EMPTY_VALUE;
   tp=EMPTY_VALUE;
   delta=m_stop_level*m_adjusted_point;
   if(base-price>delta)
     {
      sl=price+delta;
      if(m_profit_level!=0) tp=price-m_profit_level*m_adjusted_point;
     }
//---
   return(sl!=EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
