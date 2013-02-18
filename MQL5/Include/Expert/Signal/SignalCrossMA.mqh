//+------------------------------------------------------------------+
//|                                                SignalCrossMA.mqh |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                              Revision 2010.10.12 |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals based on crossover of two MA                       |
//| Type=Signal                                                      |
//| Name=CrossMA                                                     |
//| Class=CSignalCrossMA                                             |
//| Page=                                                            |
//| Parameter=FastPeriod,int,12                                      |
//| Parameter=FastShift,int,0                                        |
//| Parameter=FastMethod,ENUM_MA_METHOD,MODE_EMA                     |
//| Parameter=FastApplied,ENUM_APPLIED_PRICE,PRICE_CLOSE             |
//| Parameter=SlowPeriod,int,24                                      |
//| Parameter=SlowShift,int,0                                        |
//| Parameter=SlowMethod,ENUM_MA_METHOD,MODE_EMA                     |
//| Parameter=SlowApplied,ENUM_APPLIED_PRICE,PRICE_CLOSE             |
//| Parameter=StopLoss,int,20                                        |
//| Parameter=TakeProfit,int,50                                      |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalCrossMA.                                            |
//| Appointment: Class trading signals cross two MA.                 |
//|              Derives from class CExpertSignal.                   |
//+------------------------------------------------------------------+
class CSignalCrossMA : public CExpertSignal
  {
protected:
   CiMA             *m_FastMA;
   CiMA             *m_SlowMA;
   //--- input parameters
   int               m_fast_period;
   int               m_fast_shift;
   ENUM_MA_METHOD    m_fast_method;
   ENUM_APPLIED_PRICE m_fast_applied;
   int               m_slow_period;
   int               m_slow_shift;
   ENUM_MA_METHOD    m_slow_method;
   ENUM_APPLIED_PRICE m_slow_applied;
   int               m_stop_loss;
   int               m_take_profit;

public:
                     CSignalCrossMA();
                    ~CSignalCrossMA();
   //--- methods initialize protected data
   void              FastPeriod(int period)                  { m_fast_period=period;              }
   void              FastShift(int shift)                    { m_fast_shift=shift;                }
   void              FastMethod(ENUM_MA_METHOD method)       { m_fast_method=method;              }
   void              FastApplied(ENUM_APPLIED_PRICE applied) { m_fast_applied=applied;            }
   void              SlowPeriod(int period)                  { m_slow_period=period;              }
   void              SlowShift(int shift)                    { m_slow_shift=shift;                }
   void              SlowMethod(ENUM_MA_METHOD method)       { m_slow_method=method;              }
   void              SlowApplied(ENUM_APPLIED_PRICE applied) { m_slow_applied=applied;            }
   void              StopLoss(int stop_loss)                 { m_stop_loss=stop_loss;             }
   void              TakeProfit(int take_profit)             { m_take_profit=take_profit;         }
   virtual bool      InitIndicators(CIndicators* indicators);
   virtual bool      ValidationSettings();
   //---
   virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseLong(double& price);
   virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseShort(double& price);

protected:
   bool              InitFastMA(CIndicators* indicators);
   bool              InitSlowMA(CIndicators* indicators);
   //---
   double            FastMA(int ind)                         { return(m_FastMA.Main(ind));        }
   double            SlowMA(int ind)                         { return(m_SlowMA.Main(ind));        }
   double            StateFastMA(int ind)                    { return(FastMA(ind)-FastMA(ind+1)); }
   double            StateSlowMA(int ind)                    { return(SlowMA(ind)-SlowMA(ind+1)); }
   double            StateMA(int ind)                        { return(FastMA(ind)-SlowMA(ind));   }
   int               ExtStateMA(int ind);
  };
//+------------------------------------------------------------------+
//| Constructor CSignalCrossMA.                                      |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CSignalCrossMA::CSignalCrossMA()
  {
//--- initialize protected data
   m_FastMA      =NULL;
   m_SlowMA      =NULL;
//--- set default inputs
   m_fast_period =12;
   m_fast_shift  =0;
   m_fast_method =MODE_EMA;
   m_fast_applied=PRICE_CLOSE;
   m_slow_period =24;
   m_slow_shift  =0;
   m_slow_method =MODE_EMA;
   m_slow_applied=PRICE_CLOSE;
   m_stop_loss   =20;
   m_take_profit =50;
  }
//+------------------------------------------------------------------+
//| Destructor CSignalCrossMA.                                       |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CSignalCrossMA::~CSignalCrossMA()
  {
//---
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if settings are correct, false otherwise.           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCrossMA::ValidationSettings()
  {
   if(m_fast_period>=m_slow_period)
     {
      printf(__FUNCTION__+": period of slow MA must be greater than period of fast MA");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCrossMA::InitIndicators(CIndicators* indicators)
  {
//--- check
   if(indicators==NULL)        return(false);
//--- create and initialize fast MA indicator
   if(!InitFastMA(indicators)) return(false);
//--- create and initialize slow MA indicator
   if(!InitSlowMA(indicators)) return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create fast MA indicators.                                       |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCrossMA::InitFastMA(CIndicators* indicators)
  {
//--- create fast MA indicator
   if(m_FastMA==NULL)
      if((m_FastMA=new CiMA)==NULL)
        {
         printf(__FUNCTION__+": error creating object");
         return(false);
        }
//--- add fast MA indicator to collection
   if(!indicators.Add(m_FastMA))
     {
      printf(__FUNCTION__+": error adding object");
      delete m_FastMA;
      return(false);
     }
//--- initialize fast MA indicator
   if(!m_FastMA.Create(m_symbol.Name(),m_period,m_fast_period,m_fast_shift,m_fast_method,m_fast_applied))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create slow MA indicators.                                       |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCrossMA::InitSlowMA(CIndicators* indicators)
  {
//--- create slow MA indicator
   if(m_SlowMA==NULL)
      if((m_SlowMA=new CiMA)==NULL)
        {
         printf(__FUNCTION__+": error creating object");
         return(false);
        }
//--- add slow MA indicator to collection
   if(!indicators.Add(m_SlowMA))
     {
      printf(__FUNCTION__+": error adding object");
      delete m_SlowMA;
      return(false);
     }
//--- initialize slow MA indicator
   if(!m_SlowMA.Create(m_symbol.Name(),m_period,m_slow_period,m_slow_shift,m_slow_method,m_slow_applied))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Check relative positions MAs.                                    |
//| INPUT:  ind - start index for check.                             |
//| OUTPUT: absolute value - the number of intervals                 |
//|                          from cross MAs,                         |
//|         sign: minus - fast MA crosses slow MA down,              |
//|               plus - fast MA crosses slow MA upward.             |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
int CSignalCrossMA::ExtStateMA(int ind)
  {
   int    res=0;
   double var;
//---
   for(int i=ind;i<5;i++)
     {
      if(FastMA(i)==WRONG_VALUE || SlowMA(i)==WRONG_VALUE) break;
      var=StateMA(i);
      if(res>0)
        {
         if(var<0) break;
         res++;
         continue;
        }
      if(res<0)
        {
         if(var>0) break;
         res--;
         continue;
        }
      if(var>0) res++;
      if(var<0) res--;
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| Check conditions for long position open.                         |
//| INPUT:  price      - refernce for price,                         |
//|         sl         - refernce for stop loss,                     |
//|         tp         - refernce for take profit,                   |
//|         expiration - refernce for expiration.                    |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCrossMA::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
  {
   price=0.0;
   sl   =m_symbol.Ask()-m_stop_loss*m_adjusted_point;
   tp   =m_symbol.Ask()+m_take_profit*m_adjusted_point;
//---
   return(ExtStateMA(1)==1);
  }
//+------------------------------------------------------------------+
//| Check conditions for long position close.                        |
//| INPUT:  price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCrossMA::CheckCloseLong(double& price)
  {
   price=0.0;
//---
   return(ExtStateMA(1)==-1);
  }
//+------------------------------------------------------------------+
//| Check conditions for short position open.                        |
//| INPUT:  price      - refernce for price,                         |
//|         sl         - refernce for stop loss,                     |
//|         tp         - refernce for take profit,                   |
//|         expiration - refernce for expiration.                    |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCrossMA::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
  {
   price=0.0;
   sl   =m_symbol.Bid()+m_stop_loss*m_adjusted_point;
   tp   =m_symbol.Bid()-m_take_profit*m_adjusted_point;
//---
   return(ExtStateMA(1)==-1);
  }
//+------------------------------------------------------------------+
//| Check conditions for short position close.                       |
//| INPUT:  price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCrossMA::CheckCloseShort(double& price)
  {
   price=0.0;
//---
   return(ExtStateMA(1)==1);
  }
//+------------------------------------------------------------------+
