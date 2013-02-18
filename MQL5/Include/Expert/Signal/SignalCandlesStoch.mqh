//+------------------------------------------------------------------+
//|                                           SignalCandlesStoch.mqh |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                              Revision 2010.10.12 |
//+------------------------------------------------------------------+
#include <Expert\Signal\SignalCandles.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals based on reversal candlestick patterns             |
//| confirmed by Stochastic                                          |
//| Type=Signal                                                      |
//| Name=CandlesStoch                                                |
//| Class=CSignalCandlesStoch                                        |
//| Page=                                                            |
//| Parameter=Range,int,6                                            |
//| Parameter=Minimum,int,25                                         |
//| Parameter=ShadowBig,double,0.5                                   |
//| Parameter=ShadowSmall,double,0.2                                 |
//| Parameter=Limit,double,0.0                                       |
//| Parameter=StopLoss,double,2.0                                    |
//| Parameter=TakeProfit,double,1.0                                  |
//| Parameter=Expiration,int,4                                       |
//| Parameter=PeriodK,int,8                                          |
//| Parameter=PeriodD,int,3                                          |
//| Parameter=PeriodSlow,int,3                                       |
//| Parameter=Applied,ENUM_STO_PRICE,STO_LOWHIGH                     |
//| Parameter=ExtrMap,int,11184810                                   |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalCandlesStoch.                                       |
//| Appointment: Class trading signals with candlestick patterns     |
//|              and Stochastic reverce.                             |
//|              Derives from class CSignalCandles.                  |
//+------------------------------------------------------------------+
class CSignalCandlesStoch : public CSignalCandles
  {
protected:
   CiStochastic     *m_stoch;
   CPriceSeries     *m_app_price_high;
   CPriceSeries     *m_app_price_low;
   //--- input parameters
   int               m_periodK;
   int               m_periodD;
   int               m_period_slow;
   ENUM_STO_PRICE    m_applied;
   int               m_extr_map;

public:
                     CSignalCandlesStoch();
                    ~CSignalCandlesStoch();
   //--- methods initialize protected data
   void              PeriodK(int period)             { m_periodK=period;            }
   void              PeriodD(int period)             { m_periodD=period;            }
   void              PeriodSlow(int period)          { m_period_slow=period;        }
   void              Applied(ENUM_STO_PRICE applied) { m_applied=applied;           }
   void              ExtrMap(int map)                { m_extr_map=map;              }
   virtual bool      InitIndicators(CIndicators* indicators);
   virtual bool      ValidationSettings();
   //---
   virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseLong(double& price);
   virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseShort(double& price);

protected:
   bool              InitStoch(CIndicators* indicators);
   //---
   double            StochMain(int ind)              { return(m_stoch.Main(ind));   }
   double            StochSignal(int ind)            { return(m_stoch.Signal(ind)); }
   int               StateStoch(int ind);
   bool              ExtStateStoch(int ind);
   bool              ComapareMaps(int map);
  };
//+------------------------------------------------------------------+
//| Constructor CSignalCandlesStoch.                                 |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CSignalCandlesStoch::CSignalCandlesStoch()
  {
//--- initialize protected data
   m_stoch      =NULL;
//--- set default inputs
   m_periodK    =8;
   m_periodD    =3;
   m_period_slow=3;
   m_applied    =STO_LOWHIGH;
   m_extr_map  =11184810;   // 101010101010101010101010b
  }
//+------------------------------------------------------------------+
//| Destructor CSignalCandlesStoch.                                  |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CSignalCandlesStoch::~CSignalCandlesStoch()
  {
//---
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if settings are correct, false otherwise.           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCandlesStoch::ValidationSettings()
  {
   if(!CSignalCandles::ValidationSettings()) return(false);
   if(m_periodK<=0)
     {
      printf(__FUNCTION__+": period%K Stochastic must be greater than 0");
      return(false);
     }
   if(m_periodD<=0)
     {
      printf(__FUNCTION__+": period%D Stochastic must be greater than 0");
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
bool CSignalCandlesStoch::InitIndicators(CIndicators* indicators)
  {
//--- check
   if(indicators==NULL)                            return(false);
//--- create and initialize candles
   if(!CSignalCandles::InitIndicators(indicators)) return(false);
//--- create and initialize Stochastic indicator
   if(!InitStoch(indicators))                      return(false);
   if(m_applied==STO_CLOSECLOSE)
     {
      //--- copy Close series
      m_app_price_high=m_close;
      //--- copy Close series
      m_app_price_low =m_close;
     }
   else
     {
      //--- copy High series
      m_app_price_high=m_high;
      //--- copy Low series
      m_app_price_low =m_low;
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create Stochastic indicators.                                    |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCandlesStoch::InitStoch(CIndicators* indicators)
  {
//--- create Stochastic indicator
   if(m_stoch==NULL)
      if((m_stoch=new CiStochastic)==NULL)
        {
         printf(__FUNCTION__+": error creating object");
         return(false);
        }
//--- add Stochastic indicator to collection
   if(!indicators.Add(m_stoch))
     {
      printf(__FUNCTION__+": error adding object");
      delete m_stoch;
      return(false);
     }
//--- initialize Stochastic indicator
   if(!m_stoch.Create(m_symbol.Name(),m_period,m_periodK,m_periodD,m_period_slow,MODE_SMA,m_applied))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
   m_stoch.BufferResize(100);
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
int CSignalCandlesStoch::StateStoch(int ind)
  {
   int    res=0;
   double var;
//---
   for(int i=ind;;i++)
     {
      if(StochMain(i+1)==EMPTY_VALUE) break;
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
bool CSignalCandlesStoch::ExtStateStoch(int ind)
  {
   double extr_osc[8];
   double extr_pr[8];
   int    extr_pos[8];
   int    pos=ind,off,index;
   int    extr_map=0,map;
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
            map=0;
            if(extr_pr[i-2]<extr_pr[i])   map+=1;  // set bit 0
            if(extr_osc[i-2]<extr_osc[i]) map+=4;  // set bit 2
            extr_map+=map<<(4*(i-2));
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
            map=0;
            if(extr_pr[i-2]>extr_pr[i])   map+=1;  // set bit 0
            if(extr_osc[i-2]>extr_osc[i]) map+=4;  // set bit 2
            extr_map+=map<<(4*(i-2));
           }
         else
            extr_pr[i]=m_app_price_high.MaxValue(pos-1,4,index);
        }
      extr_pos[i]=pos;
      extr_osc[i]=StochMain(pos);
     }
   if(!ComapareMaps(extr_map)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check extended map.                                              |
//| INPUT:  map - checked map.                                       |
//| OUTPUT: true if map similar to the sample, else false.           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCandlesStoch::ComapareMaps(int map)
  {
   int inp_map,check_map;
//---
   for(int i=0;i<12;i++)
     {
      inp_map=(m_extr_map>>(2*i))&3;
      if(inp_map>=2) continue;
      check_map=(map>>(2*i))&3;
      if(inp_map!=check_map) return(false);
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
bool CSignalCandlesStoch::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
  {
   if(!CSignalCandles::CheckOpenLong(price,sl,tp,expiration))  return(false);
   if(StateStoch(1)<=0)                                        return(false);
   if(!ExtStateStoch(1))                                       return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check conditions for long position close.                        |
//| INPUT:  price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCandlesStoch::CheckCloseLong(double& price)
  {
   if(!CSignalCandles::CheckCloseLong(price))                  return(false);
   if(StateStoch(1)>=0)                                        return(false);
//---
   return(true);
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
bool CSignalCandlesStoch::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
  {
   if(!CSignalCandles::CheckOpenShort(price,sl,tp,expiration)) return(false);
   if(StateStoch(1)>=0)                                        return(false);
   if(!ExtStateStoch(1))                                       return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check conditions for short position close.                       |
//| INPUT:  price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCandlesStoch::CheckCloseShort(double& price)
  {
   if(!CSignalCandles::CheckCloseShort(price))                 return(false);
   if(StateStoch(1)<=0)                                        return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
