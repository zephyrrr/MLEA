//+------------------------------------------------------------------+
//|                                           SignalEMAStochTime.mqh |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                              Revision 2010.08.31 |
//+------------------------------------------------------------------+
#include <Expert\Signal\SignalCandles.mqh>
//--- inputs
input int            Inp_Signal_EMA_Stoch_Time_FastPeriod=21;        // Signal::EMA_Stoch_Time::PeriodFast
input int            Inp_Signal_EMA_Stoch_Time_SlowPeriod=34;        // Signal::EMA_Stoch_Time::PeriodSlow
input int            Inp_Signal_EMA_Stoch_Time_PeriodK=8;            // Signal::EMA_Stoch_Time::PeriodK
input int            Inp_Signal_EMA_Stoch_Time_PeriodD=3;            // Signal::EMA_Stoch_Time::PeriodD
input int            Inp_Signal_EMA_Stoch_Time_PeriodSlowD=3;        // Signal::EMA_Stoch_Time::PeriodSlowD
input ENUM_STO_PRICE Inp_Signal_EMA_Stoch_Time_AppPrice=STO_LOWHIGH; // Signal::EMA_Stoch_Time::Applied
input int            Inp_Signal_EMA_Stoch_Time_ExtrMapp=149796;      // Signal::EMA_Stoch_Time::ExtrMapp
input int            Inp_Signal_EMA_Stoch_Time_PeriodATR =24;        // Signal::EMA_Stoch_Time::PeriodATR
input double         Inp_Signal_EMA_Stoch_Time_LimitATR  =0.5;       // Signal::EMA_Stoch_Time::LimitATR
input double         Inp_Signal_EMA_Stoch_Time_StopATR   =2.0;       // Signal::EMA_Stoch_Time::StopATR
input double         Inp_Signal_EMA_Stoch_Time_TakeATR   =1.0;       // Signal::EMA_Stoch_Time::TakeATR
input int            Inp_Signal_EMA_Stoch_Time_HourMapp  =0;         // Signal::EMA_Stoch_Time::HourMapp
//+------------------------------------------------------------------+
//| Class CSignalEMAStochTime.                                       |
//| Appointment: Class trading signals cross two EMA.                |
//|              Derives from class CSignal_Candles.                 |
//+------------------------------------------------------------------+
class CSignalEMAStochTime : public CSignalCandles
  {
protected:
   CiMA             *m_fastEMA;
   CiMA             *m_slowEMA;
   //---
   CiStochastic     *m_stoch;
   CPriceSeries     *m_app_price_high;
   CPriceSeries     *m_app_price_low;
   //---
   CiATR            *m_ATR;

public:
                     CSignalEMAStochTime();
   //---
   virtual bool      Init(CSymbolInfo* symbol,ENUM_TIMEFRAMES period,double adjusted_point);
   virtual bool      InitIndicators(CIndicators *indicators);
   //---
   virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseLong(double& price);
   virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseShort(double& price);

protected:
   bool              InitFastEMA(CIndicators *indicators);
   bool              InitSlowEMA(CIndicators *indicators);
   bool              InitStochastic(CIndicators *indicators);
   bool              InitATR(CIndicators *indicators);
   //---
   double            FastEMA(int ind)      { return(m_fastEMA.Main(ind));         }
   double            SlowEMA(int ind)      { return(m_slowEMA.Main(ind));         }
   double            StateFastEMA(int ind) { return(FastEMA(ind)-FastEMA(ind+1)); }
   double            StateSlowEMA(int ind) { return(SlowEMA(ind)-SlowEMA(ind+1)); }
   double            StateEMA(int ind)     { return(FastEMA(ind)-SlowEMA(ind));   }
   //---
   double            StochMain(int ind)    { return(m_stoch.Main(ind));           }
   double            StochSignal(int ind)  { return(m_stoch.Signal(ind));         }
   int               StateStoch(int ind);
   bool              ExtStateStoch(int ind);
   bool              ComapareMapps(int mapp);
   //---
   double            ATR(int ind)          { return(m_ATR.Main(ind));             }
  };
//+------------------------------------------------------------------+
//| Constructor CSignalEMAStochTime.                                 |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CSignalEMAStochTime::CSignalEMAStochTime()
  {
//--- initialize protected data
   m_fastEMA=NULL;
   m_slowEMA=NULL;
   m_stoch  =NULL;
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
bool CSignalEMAStochTime::Init(CSymbolInfo* symbol,ENUM_TIMEFRAMES period,double adjusted_point)
  {
   if(!CSignalCandles::Init(symbol,period,adjusted_point)) return(false);
   if(Inp_Signal_EMA_Stoch_Time_FastPeriod>=Inp_Signal_EMA_Stoch_Time_SlowPeriod)
     {
      printf("CSignalEMAStochTime: InpCSignalCrossEMASlowPeriod must be greater than InpCSignalCrossEMAFastPeriod");
      return(false);
     }
   if(Inp_Signal_EMA_Stoch_Time_PeriodK<=0)
     {
      printf("CSignalEMAStochTime: Period%K Stochastic must be greater than 0");
      return(false);
     }
   if(Inp_Signal_EMA_Stoch_Time_PeriodD<=0)
     {
      printf("CSignalEMAStochTime: Period%D Stochastic must be greater than 0");
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
bool CSignalEMAStochTime::InitIndicators(CIndicators *indicators)
  {
//--- create and initialize candles
   if(!CSignalCandles::InitIndicators(indicators)) return(false);
//--- create and initialize fast EMA indicator
   if(!InitFastEMA(indicators))                    return(false);
//--- create and initialize slow EMA indicator
   if(!InitSlowEMA(indicators))                    return(false);
//--- create and initialize Stochastic indicator
   if(!InitStochastic(indicators))                 return(false);
   if(Inp_Signal_EMA_Stoch_Time_AppPrice==STO_CLOSECLOSE)
     {
      //--- copy Close indicator
      m_app_price_high=m_close;
      //--- copy Close indicator
      m_app_price_low =m_close;
     }
   else
     {
      //--- copy High indicator
      m_app_price_high=m_high;
      //--- copy Low indicator
      m_app_price_low =m_low;
     }
//--- create and initialize ATR indicator
   if(!InitATR(indicators))                        return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create fast EMA indicators.                                      |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalEMAStochTime::InitFastEMA(CIndicators *indicators)
  {
   string symbol=m_symbol.Name();
//--- create fast EMA indicator and add it to collection
   if(m_fastEMA==NULL)
      if((m_fastEMA=new CiMA)==NULL)
         return(false);
   if(!indicators.Add(m_fastEMA))
      return(false);
//--- initialize EMA indicator
   if(!m_fastEMA.Create(symbol,m_period,Inp_Signal_EMA_Stoch_Time_FastPeriod,0,MODE_EMA,PRICE_CLOSE))
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
bool CSignalEMAStochTime::InitSlowEMA(CIndicators *indicators)
  {
   string symbol=m_symbol.Name();
//--- create slow EMA indicator and add it to collection
   if(m_slowEMA==NULL)
      if((m_slowEMA=new CiMA)==NULL)
         return(false);
   if(!indicators.Add(m_slowEMA))
      return(false);
//--- initialize EMA indicator
   if(!m_slowEMA.Create(symbol,m_period,Inp_Signal_EMA_Stoch_Time_SlowPeriod,0,MODE_EMA,PRICE_CLOSE))
      return(false);
   m_slowEMA.BufferResize(1000);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create Stochastic indicators.                                    |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalEMAStochTime::InitStochastic(CIndicators *indicators)
  {
   string symbol=m_symbol.Name();
//--- create Stochastic indicator and add it to collection
   if(m_stoch==NULL)
      if((m_stoch=new CiStochastic)==NULL)
         return(false);
   if(!indicators.Add(m_stoch))
      return(false);
//--- initialize Stochastic indicator
   if(!m_stoch.Create(symbol,m_period,Inp_Signal_EMA_Stoch_Time_PeriodK,Inp_Signal_EMA_Stoch_Time_PeriodD,
                      Inp_Signal_EMA_Stoch_Time_PeriodSlowD,MODE_SMA,Inp_Signal_EMA_Stoch_Time_AppPrice))
      return(false);
   m_stoch.BufferResize(1000);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create ATR indicators.                                           |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalEMAStochTime::InitATR(CIndicators *indicators)
  {
   string symbol=m_symbol.Name();
//--- create ATR indicator and add it to collection
   if(m_ATR==NULL)
      if((m_ATR=new CiATR)==NULL)
         return(false);
   if(!indicators.Add(m_ATR))
      return(false);
//--- initialize ATR indicator
   if(!m_ATR.Create(symbol,m_period,Inp_Signal_EMA_Stoch_Time_PeriodATR))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Check state Stochastic.                                          |
//| INPUT:  ind - start index for check.                             |
//| OUTPUT: absolute value - the number of intervals                 |
//|                          from the turn of oscillator,            |
//|         sign: minus - turn down the oscillator,                  |
//|               plus - turn up the oscillator.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
int CSignalEMAStochTime::StateStoch(int ind)
  {
   int    res=0;
   double var;
//---
   for(int i=ind;;i++)
     {
      if(StochMain(i+1)==WRONG_VALUE) break;
      var=StochMain(i)-StochMain(i+1);
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
//| Check extended state Stochastic.                                 |
//| INPUT:  ind - start index for check.                             |
//| OUTPUT: true if map similar to the sample, else false.           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalEMAStochTime::ExtStateStoch(int ind)
  {
   double extr_osc[8];
   double extr_pr[8];
   int    extr_pos[8];
   int    pos=ind,off,index;
   int    extr_mapp=0,mapp;
//---
   for(int i=0;i<8;i++)
     {
      off=StateStoch(pos);
      if(off>0)
        {
         //--- minimum
         pos+=off;
         if(i>1)
           {
            extr_pr[i]=m_app_price_low.MinValue(pos-2,5,index);
            mapp=0;
            if(extr_pr[i-2]<extr_pr[i])   mapp+=1;
            if(extr_osc[i-2]<extr_osc[i]) mapp+=2;
            extr_mapp+=mapp<<(3*(i-2));
           }
         else
            extr_pr[i]=m_app_price_low.MinValue(pos-1,4,index);
        }
      else
        {
         //--- maximum
         pos-=off;
         if(i>1)
           {
            extr_pr[i]=m_app_price_high.MaxValue(pos-2,5,index);
            mapp=0;
            if(extr_pr[i-2]>extr_pr[i])   mapp+=1;
            if(extr_osc[i-2]>extr_osc[i]) mapp+=2;
            extr_mapp+=mapp<<(3*(i-2));
           }
         else
            extr_pr[i]=m_app_price_high.MaxValue(pos-1,4,index);
        }
      extr_pos[i]=pos;
      extr_osc[i]=StochMain(pos);
     }
   if(!ComapareMapps(extr_mapp)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check extended mapp.                                             |
//| INPUT:  mapp - checked mapp.                                     |
//| OUTPUT: true if map similar to the sample, else false.           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalEMAStochTime::ComapareMapps(int mapp)
  {
   int inp_mapp,check_mapp;
//---
   for(int i=0;i<6;i++)
     {
      inp_mapp=(Inp_Signal_EMA_Stoch_Time_ExtrMapp>>(3*i))&7;
      if(inp_mapp>=4) continue;
      check_mapp=(mapp>>(3*i))&7;
      if(inp_mapp!=check_mapp) return(false);
     }
//---
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
bool CSignalEMAStochTime::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
  {
   price=0.0;
   sl   =0.0;
   tp   =0.0;
//---
   return(StateEMA(1)>0);
  }
//+------------------------------------------------------------------+
//| Check conditions for long position close.                        |
//| INPUT:  price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalEMAStochTime::CheckCloseLong(double& price)
  {
   price=0.0;
//---
   return(StateEMA(1)<0);
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
bool CSignalEMAStochTime::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
  {
   price=0.0;
   sl   =0.0;
   tp   =0.0;
//---
   return(StateEMA(1)<0);
  }
//+------------------------------------------------------------------+
//| Check conditions for short position close.                       |
//| INPUT:  price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalEMAStochTime::CheckCloseShort(double& price)
  {
   price=0.0;
//---
   return(StateEMA(1)>0);
  }
//+------------------------------------------------------------------+
