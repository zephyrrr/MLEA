//+------------------------------------------------------------------+
//|                                               Signal2EMATime.mqh |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                              Revision 2010.08.31 |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
//--- inputs
input int    Inp_Signal_2EMA_Time_FastPeriod =21;   // Signal::2EMA_Time::PeriodFast
input int    Inp_Signal_2EMA_Time_SlowPeriod =34;   // Signal::2EMA_Time::PeriodSlow
input int    Inp_Signal_2EMA_Time_PeriodATR  =24;   // Signal::2EMA_Time::PeriodATR
input double Inp_Signal_2EMA_Time_LimitATR   =1.0;  // Signal::2EMA_Time::LimitATR
input double Inp_Signal_2EMA_Time_StopATR    =2.0;  // Signal::2EMA_Time::StopATR
input double Inp_Signal_2EMA_Time_TakeATR    =1.0;  // Signal::2EMA_Time::TakeATR
input int    Inp_Signal_2EMA_Time_Expiration =4;    // Signal::2EMA_Time::Expiration
input int    Inp_Signal_2EMA_Time_GoodHour   =-1;   // Signal::2EMA_Time::GoodHour
input int    Inp_Signal_2EMA_Time_BadHourMapp=0;    // Signal::2EMA_Time::BadHourMapp
//+------------------------------------------------------------------+
//| Class CSignal2EMATime.                                           |
//| Appointment: Class trading signals cross two EMA.                |
//|              Derives from class CExpertSignal.                   |
//+------------------------------------------------------------------+
class CSignal2EMATime : public CExpertSignal
  {
protected:
   CiMA             *m_fastEMA;
   CiMA             *m_slowEMA;
   CiATR            *m_ATR;

public:
                     CSignal2EMATime();
   //---
   virtual bool      Init(CSymbolInfo* symbol,ENUM_TIMEFRAMES period,double adjusted_point);
   virtual bool      InitIndicators(CIndicators *indicators);
   //---
   virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseLong(double& price);
   virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseShort(double& price);
   //---
   virtual bool      CheckTrailingOrderLong(COrderInfo *order,double& price);
   virtual bool      CheckTrailingOrderShort(COrderInfo *order,double& price);

protected:
   bool              InitFastEMA(CIndicators *indicators);
   bool              InitSlowEMA(CIndicators *indicators);
   bool              InitATR(CIndicators *indicators);
   //---
   double            FastEMA(int ind)      { return(m_fastEMA.Main(ind));         }
   double            SlowEMA(int ind)      { return(m_slowEMA.Main(ind));         }
   double            StateFastEMA(int ind) { return(FastEMA(ind)-FastEMA(ind+1)); }
   double            StateSlowEMA(int ind) { return(SlowEMA(ind)-SlowEMA(ind+1)); }
   double            StateEMA(int ind)     { return(FastEMA(ind)-SlowEMA(ind));   }
   //---
   double            ATR(int ind)          { return(m_ATR.Main(ind));             }
   //---
   bool              CheckTimeFilter(datetime time);
  };
//+------------------------------------------------------------------+
//| Constructor CSignal2EMATime.                                     |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CSignal2EMATime::CSignal2EMATime()
  {
//--- initialize protected data
   m_fastEMA=NULL;
   m_slowEMA=NULL;
   m_ATR    =NULL;
  }
//+------------------------------------------------------------------+
//| Checking for input parameters and setting protected data.        |
//| INPUT:  symbol         -pointer to the CSymbolInfo,              |
//|         period         -working period,                          |
//|         adjusted_point -adjusted point value.                    |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignal2EMATime::Init(CSymbolInfo* symbol,ENUM_TIMEFRAMES period,double adjusted_point)
  {
   if(!CExpertSignal::Init(symbol,period,adjusted_point)) return(false);
   if(Inp_Signal_2EMA_Time_FastPeriod>=Inp_Signal_2EMA_Time_SlowPeriod)
     {
      printf("CSignalCrossEMA: InpCSignalCrossEMASlowPeriod must be greater than InpCSignalCrossEMAFastPeriod");
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
bool CSignal2EMATime::InitIndicators(CIndicators *indicators)
  {
//--- create and initialize fast EMA indicator
   if(!InitFastEMA(indicators))    return(false);
//--- create and initialize slow EMA indicator
   if(!InitSlowEMA(indicators))    return(false);
//--- create and initialize ATR indicator
   if(!InitATR(indicators)) return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create fast EMA indicators.                                      |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignal2EMATime::InitFastEMA(CIndicators *indicators)
  {
//--- create fast EMA indicator and add it to collection
   if(m_fastEMA==NULL)
      if((m_fastEMA=new CiMA)==NULL)
         return(false);
   if(!indicators.Add(m_fastEMA))
      return(false);
//--- initialize EMA indicator
   if(!m_fastEMA.Create(m_symbol.Name(),m_period,Inp_Signal_2EMA_Time_FastPeriod,0,MODE_EMA,PRICE_CLOSE))
      return(false);
   m_fastEMA.BufferResize(1000);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create slow EMA indicators.                                      |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignal2EMATime::InitSlowEMA(CIndicators *indicators)
  {
//--- create slow EMA indicator and add it to collection
   if(m_slowEMA==NULL)
      if((m_slowEMA=new CiMA)==NULL)
         return(false);
   if(!indicators.Add(m_slowEMA))
      return(false);
//--- initialize EMA indicator
   if(!m_slowEMA.Create(m_symbol.Name(),m_period,Inp_Signal_2EMA_Time_SlowPeriod,0,MODE_EMA,PRICE_CLOSE))
      return(false);
   m_slowEMA.BufferResize(1000);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create ATR indicators.                                           |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignal2EMATime::InitATR(CIndicators *indicators)
  {
//--- create ATR indicator and add it to collection
   if(m_ATR==NULL)
      if((m_ATR=new CiATR)==NULL)
         return(false);
   if(!indicators.Add(m_ATR))
      return(false);
//--- initialize ATR indicator
   if(!m_ATR.Create(m_symbol.Name(),m_period,Inp_Signal_2EMA_Time_PeriodATR))
      return(false);
//--- ok
   return(true);
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
bool CSignal2EMATime::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
  {
   if(!CheckTimeFilter(expiration)) return(false);
//---
   double ema=SlowEMA(1);
   double atr=ATR(1);
   double spread=m_symbol.Ask()-m_symbol.Bid();
//---
   price=m_symbol.NormalizePrice(ema-Inp_Signal_2EMA_Time_LimitATR*atr+spread);
   sl   =m_symbol.NormalizePrice(ema-(Inp_Signal_2EMA_Time_LimitATR+Inp_Signal_2EMA_Time_StopATR)*atr);
   tp   =m_symbol.NormalizePrice(ema-(Inp_Signal_2EMA_Time_LimitATR-Inp_Signal_2EMA_Time_TakeATR)*atr);
   expiration+=Inp_Signal_2EMA_Time_Expiration*PeriodSeconds(m_period);
//---
   return(StateEMA(1)>0);
  }
//+------------------------------------------------------------------+
//| Check conditions for long position close.                        |
//| INPUT:  price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignal2EMATime::CheckCloseLong(double& price)
  {
   return(false);
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
bool CSignal2EMATime::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
  {
   if(!CheckTimeFilter(expiration)) return(false);
//---
   double ema=SlowEMA(1);
   double atr=ATR(1);
   double spread=m_symbol.Ask()-m_symbol.Bid();
//---
   price      =m_symbol.NormalizePrice(ema+Inp_Signal_2EMA_Time_LimitATR*atr);
   sl         =m_symbol.NormalizePrice(ema+(Inp_Signal_2EMA_Time_LimitATR+Inp_Signal_2EMA_Time_StopATR)*atr+spread);
   tp         =m_symbol.NormalizePrice(ema+(Inp_Signal_2EMA_Time_LimitATR-Inp_Signal_2EMA_Time_TakeATR)*atr+spread);
   expiration+=Inp_Signal_2EMA_Time_Expiration*PeriodSeconds(m_period);
//---
   return(StateEMA(1)<0);
  }
//+------------------------------------------------------------------+
//| Check conditions for short position close.                       |
//| INPUT:  price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignal2EMATime::CheckCloseShort(double& price)
  {
   return(false);
  }
//+------------------------------------------------------------------+
//| Check conditions for long order modify.                          |
//| INPUT:  order - pointer for order object,                        |
//|         price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignal2EMATime::CheckTrailingOrderLong(COrderInfo *order,double& price)
  {
   double ema=SlowEMA(1);
   double atr=ATR(1);
   double spread=m_symbol.Ask()-m_symbol.Bid();
//---
   price=m_symbol.NormalizePrice(ema-Inp_Signal_2EMA_Time_LimitATR*atr+spread);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Check conditions for short order modify.                         |
//| INPUT:  order - pointer for order object,                        |
//|         price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignal2EMATime::CheckTrailingOrderShort(COrderInfo *order,double& price)
  {
   double ema=SlowEMA(1);
   double atr=ATR(1);
//---
   price=m_symbol.NormalizePrice(ema+Inp_Signal_2EMA_Time_LimitATR*atr);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Check conditions for time filter.                                |
//| INPUT:  time - current time.                                     |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignal2EMATime::CheckTimeFilter(datetime time)
  {
   MqlDateTime s_time;
//---
   TimeToStruct(time,s_time);
//---
   if((Inp_Signal_2EMA_Time_GoodHour==-1 || Inp_Signal_2EMA_Time_GoodHour==s_time.hour) &&
     !(Inp_Signal_2EMA_Time_BadHourMapp&(1<<s_time.hour)))
      return(true);
//--- no condition
   return(false);
  }
//+------------------------------------------------------------------+
