//+------------------------------------------------------------------+
//|                                                   TrailingMA.mqh |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                              Revision 2010.10.12 |
//+------------------------------------------------------------------+
#include <Expert\ExpertTrailing.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Trailing Stop based on MA                                  |
//| Type=Trailing                                                    |
//| Name=MA                                                          |
//| Class=CTrailingMA                                                |
//| Page=                                                            |
//| Parameter=Period,int,12,Period of MA                             |
//| Parameter=Shift,int,0,Shift of MA                                |
//| Parameter=Method,ENUM_MA_METHOD,MODE_SMA,Method of averaging     |
//| Parameter=Applied,ENUM_APPLIED_PRICE,PRICE_CLOSE,Prices series   |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CTrailingMA.                                               |
//| Purpose: Class of trailing stops based on MA.                    |
//|              Derives from class CExpertTrailing.                 |
//+------------------------------------------------------------------+
class CTrailingMA : public CExpertTrailing
  {
protected:
   CiMA             *m_MA;
   //--- input parameters
   int               m_ma_period;
   int               m_ma_shift;
   ENUM_MA_METHOD    m_ma_method;
   ENUM_APPLIED_PRICE m_ma_applied;

public:
                     CTrailingMA();
                    ~CTrailingMA();
   //--- methods of initialization of protected data
   void              Period(int period)                  { m_ma_period=period;   }
   void              Shift(int shift)                    { m_ma_shift=shift;     }
   void              Method(ENUM_MA_METHOD method)       { m_ma_method=method;   }
   void              Applied(ENUM_APPLIED_PRICE applied) { m_ma_applied=applied; }
   virtual bool      InitIndicators(CIndicators* indicators);
   virtual bool      ValidationSettings();
   //---
   virtual bool      CheckTrailingStopLong(CPositionInfo* position,double& sl,double& tp);
   virtual bool      CheckTrailingStopShort(CPositionInfo* position,double& sl,double& tp);
  };
//+------------------------------------------------------------------+
//| Constructor CTrailingMA.                                         |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CTrailingMA::CTrailingMA()
  {
//--- initialize protected data
   m_MA        =NULL;
//--- set default inputs
   m_ma_period =12;
   m_ma_shift  =0;
   m_ma_method =MODE_SMA;
   m_ma_applied=PRICE_CLOSE;
  }
//+------------------------------------------------------------------+
//| Destructor CTrailingMA.                                          |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CTrailingMA::~CTrailingMA()
  {
//---
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if settings are correct, false otherwise.           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTrailingMA::ValidationSettings()
  {
   if(!CExpertTrailing::ValidationSettings()) return(false);
//--- initial data checks
   if(m_ma_period<=0)
     {
      printf(__FUNCTION__+": period MA must be greater than 0");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Checking for input parameters and setting protected data.        |
//| INPUT:  symbol         -pointer to the CSymbolInfo,              |
//|         period         -working period,                          |
//|         adjusted_point -adjusted point value.                    |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTrailingMA::InitIndicators(CIndicators* indicators)
  {
//--- check
   if(indicators==NULL)       return(false);
//--- create MA indicator
   if(m_MA==NULL)
      if((m_MA=new CiMA)==NULL)
        {
         printf(__FUNCTION__+": error creating object");
         return(false);
        }
//--- add MA indicator to collection
   if(!indicators.Add(m_MA))
     {
      printf(__FUNCTION__+": error adding object");
      delete m_MA;
      return(false);
     }
//--- initialize MA indicator
   if(!m_MA.Create(m_symbol.Name(),m_period,m_ma_period,m_ma_shift,m_ma_method,m_ma_applied))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
   m_MA.BufferResize(3+m_ma_shift);
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
bool CTrailingMA::CheckTrailingStopLong(CPositionInfo* position,double& sl,double& tp)
  {
//--- check
   if(position==NULL) return(false);
//---
   double level =NormalizeDouble(m_symbol.Bid()-m_symbol.StopsLevel()*m_symbol.Point(),m_symbol.Digits());
   double new_sl=NormalizeDouble(m_MA.Main(1),m_symbol.Digits());
   double pos_sl=position.StopLoss();
   double base  =(pos_sl==0.0)?position.PriceOpen():pos_sl;
//---
   sl=EMPTY_VALUE;
   tp=EMPTY_VALUE;
   if(new_sl>base && new_sl<level) sl=new_sl;
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
bool CTrailingMA::CheckTrailingStopShort(CPositionInfo* position,double& sl,double& tp)
  {
//--- check
   if(position==NULL) return(false);
//---
   double level =NormalizeDouble(m_symbol.Ask()+m_symbol.StopsLevel()*m_symbol.Point(),m_symbol.Digits());
   double new_sl=NormalizeDouble(m_MA.Main(1)+m_symbol.Spread()*m_symbol.Point(),m_symbol.Digits());
   double pos_sl=position.StopLoss();
   double base  =(pos_sl==0.0)?position.PriceOpen():pos_sl;
//---
   sl=EMPTY_VALUE;
   tp=EMPTY_VALUE;
   if(new_sl<base && new_sl>level) sl=new_sl;
//---
   return(sl!=EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
