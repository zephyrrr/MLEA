//+------------------------------------------------------------------+
//|                                             SignalCandlesRSI.mqh |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                              Revision 2010.10.12 |
//+------------------------------------------------------------------+
#include <Expert\Signal\SignalCandles.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals based on reversal candlestick patterns             |
//| confirmed by RSI                                                 |
//| Type=Signal                                                      |
//| Name=CandlesRSI                                                  |
//| Class=CSignalCandlesRSI                                          |
//| Page=                                                            |
//| Parameter=Range,int,6                                            |
//| Parameter=Minimum,int,25                                         |
//| Parameter=ShadowBig,double,0.5                                   |
//| Parameter=ShadowSmall,double,0.2                                 |
//| Parameter=Limit,double,0.0                                       |
//| Parameter=StopLoss,double,2.0                                    |
//| Parameter=TakeProfit,double,1.0                                  |
//| Parameter=Expiration,int,4                                       |
//| Parameter=PeriodRSI,int,12                                       |
//| Parameter=AppliedRSI,ENUM_APPLIED_PRICE,PRICE_CLOSE              |
//| Parameter=ExtrMap,int,11184810                                   |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalCandlesRSI.                                         |
//| Appointment: Class trading signals with candlestick patterns     |
//|              and RSI reverce.                                    |
//|              Derives from class CSignalCandles.                  |
//+------------------------------------------------------------------+
class CSignalCandlesRSI : public CSignalCandles
  {
protected:
   CiRSI            *m_RSI;
   CiMA             *m_app_price;
   //--- input parameters
   int               m_periodRSI;
   ENUM_APPLIED_PRICE m_appliedRSI;
   int               m_extr_map;

public:
                     CSignalCandlesRSI();
                    ~CSignalCandlesRSI();
   //--- methods initialize protected data
   void              PeriodRSI(int period)                  { m_periodRSI=period;      }
   void              AppliedRSI(ENUM_APPLIED_PRICE applied) { m_appliedRSI=applied;    }
   void              ExtrMap(int map)                       { m_extr_map=map;          }
   virtual bool      InitIndicators(CIndicators* indicators);
   virtual bool      ValidationSettings();
   //---
   virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseLong(double& price);
   virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseShort(double& price);

protected:
   bool              InitRSI(CIndicators* indicators);
   bool              InitApplied(CIndicators* indicators);
   //---
   double            RSI(int ind)                           { return(m_RSI.Main(ind)); }
   int               StateRSI(int ind);
   bool              ExtStateRSI(int ind);
   bool              ComapareMaps(int map);
  };
//+------------------------------------------------------------------+
//| Constructor CSignalCandlesRSI.                                   |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CSignalCandlesRSI::CSignalCandlesRSI()
  {
//--- initialize protected data
   m_RSI       =NULL;
   m_app_price =NULL;
//--- set default inputs
   m_periodRSI =12;
   m_appliedRSI=PRICE_CLOSE;
   m_extr_map =11184810;   // 101010101010101010101010b
  }
//+------------------------------------------------------------------+
//| Destructor CSignalCandlesRSI.                                    |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CSignalCandlesRSI::~CSignalCandlesRSI()
  {
//---
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if settings are correct, false otherwise.           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCandlesRSI::ValidationSettings()
  {
   if(!CSignalCandles::ValidationSettings()) return(false);
   if(m_periodRSI<=0)
     {
      printf(__FUNCTION__+": period RSI must be greater than 0");
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
bool CSignalCandlesRSI::InitIndicators(CIndicators* indicators)
  {
//--- check
   if(indicators==NULL)                            return(false);
//--- create and initialize candles
   if(!CSignalCandles::InitIndicators(indicators)) return(false);
//--- create and initialize RSI indicator
   if(!InitRSI(indicators))                        return(false);
//--- create and initialize Price series
   if(!InitApplied(indicators))                    return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create RSI indicators.                                           |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCandlesRSI::InitRSI(CIndicators* indicators)
  {
//--- create RSI indicator
   if(m_RSI==NULL)
      if((m_RSI=new CiRSI)==NULL)
        {
         printf(__FUNCTION__+": error creating object");
         return(false);
        }
//--- add RSI indicator to collection
   if(!indicators.Add(m_RSI))
     {
      printf(__FUNCTION__+": error adding object");
      delete m_RSI;
      return(false);
     }
//--- initialize RSI indicator
   if(!m_RSI.Create(m_symbol.Name(),m_period,m_periodRSI,m_appliedRSI))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
   m_RSI.BufferResize(100);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create Applied Price indicator.                                  |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCandlesRSI::InitApplied(CIndicators* indicators)
  {
//--- create Price indicator
   if(m_app_price==NULL)
      if((m_app_price=new CiMA)==NULL)
        {
         printf(__FUNCTION__+": error creating object");
         return(false);
        }
//--- add Price indicator to collection
   if(!indicators.Add(m_app_price))
     {
      printf(__FUNCTION__+": error adding object");
      delete m_app_price;
      return(false);
     }
//--- initialize Price indicator
   if(!m_app_price.Create(m_symbol.Name(),m_period,1,0,MODE_SMA,m_appliedRSI))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
   m_app_price.BufferResize(100);
   m_app_price.FullRelease(true);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Check state RSI.                                                 |
//| INPUT:  ind - start index for check.                             |
//| OUTPUT: absolute value - the number of intervals                 |
//|                          from the turn of oscillator,            |
//|         sign: minus - turn down the oscillator,                  |
//|               plus - turn up the oscillator.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
int CSignalCandlesRSI::StateRSI(int ind)
  {
   int    res=0;
   double var;
//---
   for(int i=ind;;i++)
     {
      if(RSI(i+1)==WRONG_VALUE) break;
      var=RSI(i)-RSI(i+1);
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
//| Check extended state RSI.                                        |
//| INPUT:  ind - start index for check.                             |
//| OUTPUT: true if map similar to the sample, else false.           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCandlesRSI::ExtStateRSI(int ind)
  {
   double extr_osc[8];
   double extr_pr[8];
   int    extr_pos[8];
   int    pos=ind,off,index;
   int    extr_map=0,map;
//---
   for(int i=0;i<8;i++)
     {
      off=StateRSI(pos);
      if(off>0)
        {
         //--- minimum
         pos+=off;
         extr_pr[i]=m_app_price.MinValue(0,pos-1,3,index);
         if(i>1)
           {
            map=0;
            if(extr_pr[i-2]<extr_pr[i])   map+=1;
            if(extr_osc[i-2]<extr_osc[i]) map+=4;
            extr_map+=map<<(4*(i-2));
           }
        }
      else
        {
         //--- maximum
         pos-=off;
         extr_pr[i]=m_app_price.MaxValue(0,pos-1,3,index);
         if(i>1)
           {
            map=0;
            if(extr_pr[i-2]>extr_pr[i])   map+=1;
            if(extr_osc[i-2]>extr_osc[i]) map+=4;
            extr_map+=map<<(4*(i-2));
           }
        }
      extr_pos[i]=pos;
      extr_osc[i]=RSI(pos);
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
bool CSignalCandlesRSI::ComapareMaps(int map)
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
bool CSignalCandlesRSI::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
  {
   if(!CSignalCandles::CheckOpenLong(price,sl,tp,expiration))  return(false);
   if(StateRSI(1)<=0)                                          return(false);
   if(!ExtStateRSI(1))                                         return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check conditions for long position close.                        |
//| INPUT:  price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCandlesRSI::CheckCloseLong(double& price)
  {
   if(!CSignalCandles::CheckCloseLong(price))                  return(false);
   if(StateRSI(1)>=0)                                          return(false);
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
bool CSignalCandlesRSI::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
  {
   if(!CSignalCandles::CheckOpenShort(price,sl,tp,expiration)) return(false);
   if(StateRSI(1)>=0)                                          return(false);
   if(!ExtStateRSI(1))                                         return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check conditions for short position close.                       |
//| INPUT:  price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalCandlesRSI::CheckCloseShort(double& price)
  {
   if(!CSignalCandles::CheckCloseShort(price))                 return(false);
   if(StateRSI(1)<=0)                                          return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
