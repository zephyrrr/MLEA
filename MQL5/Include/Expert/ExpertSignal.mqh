//+------------------------------------------------------------------+
//|                                                 ExpertSignal.mqh |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "ExpertBase.mqh"
//+------------------------------------------------------------------+
//| Macro definitions.                                               |
//+------------------------------------------------------------------+
//--- check if a market model is used
#define IS_PATTERN_USAGE(p)          ((m_patterns_usage&(((int)1)<<p))!=0)
//+------------------------------------------------------------------+
//| Class CExpertSignal.                                             |
//| Purpose: Base class trading signals.                             |
//| Derives from class CExpertBase.                                  |
//+------------------------------------------------------------------+
class CExpertSignal : public CExpertBase
  {
protected:
   //--- variables
   double            m_base_price;     // base price for detection of level of entering (and/or exit?)
   //--- variables for working with additional filters
   CArrayObj         m_filters;        // array of additional filters (maximum number of fileter is 64)
   //--- Adjusted parameters
   double            m_weight;         // "weight" of a signal in a combined filter
   int               m_patterns_usage; // bit mask of  using of the market models of signals
   int               m_general;        // index of the "main" signal (-1 - no)
   long              m_ignore;         // bit mask of "ignoring" the additional filter
   long              m_invert;         // bit mask of "inverting" the additional filter
   int               m_threshold_open; // threshold value for opening
   int               m_threshold_close;// threshold level for closing
   double            m_price_level;    // level of placing a pending orders relatively to the base price
   double            m_stop_level;     // level of placing of the "stop loss" order relatively to the open price
   double            m_take_level;     // level of placing of the "take profit" order relatively to the open price
   int               m_expiration;     // time of expiration of a pending order in bars

public:
                     CExpertSignal(void);
                    ~CExpertSignal(void);
   //--- methods of access to protected data
   void              BasePrice(double value)                                  { m_base_price=value;       }
   int               UsedSeries(void);
   //--- methods of setting adjustable parameters
   void              Weight(double value)                                     { m_weight=value;           }
   void              PatternsUsage(int value)                                 { m_patterns_usage=value;   }
   void              General(int value)                                       { m_general=value;          }
   void              Ignore(long value)                                       { m_ignore=value;           }
   void              Invert(long value)                                       { m_invert=value;           }
   void              ThresholdOpen(int value)                                 { m_threshold_open=value;   }
   void              ThresholdClose(int value)                                { m_threshold_close=value;  }
   void              PriceLevel(double value)                                 { m_price_level=value;      }
   void              StopLevel(double value)                                  { m_stop_level=value;       }
   void              TakeLevel(double value)                                  { m_take_level=value;       }
   void              Expiration(int value)                                    { m_expiration=value;       }
   //--- method of initialization of the object
   void              Magic(ulong value);
   //--- method of verification of settings
   virtual bool      ValidationSettings(void);
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators* indicators);
   //--- methods for working with additional filters
   virtual bool      AddFilter(CExpertSignal *filter);
   //--- methods for generating signals of entering the market
   virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
   //--- methods for detection of levels of entering the market
   virtual bool      OpenLongParams(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      OpenShortParams(double& price,double& sl,double& tp,datetime& expiration);
   //--- methods for generating signals of exit from the market
   virtual bool      CheckCloseLong(double& price);
   virtual bool      CheckCloseShort(double& price);
   //--- methods for detection of levels of exit from the market
   virtual bool      CloseLongParams(double& price);
   virtual bool      CloseShortParams(double& price);
   //--- methods for generating signals of reversal of positions
   virtual bool      CheckReverseLong(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckReverseShort(double& price,double& sl,double& tp,datetime& expiration);
   //--- methods for generating signals of modification of pending orders
   virtual bool      CheckTrailingOrderLong(COrderInfo* order,double& price)  { return(false);            }
   virtual bool      CheckTrailingOrderShort(COrderInfo* order,double& price) { return(false);            }
   //--- methods of checking if the market models are formed
   virtual int       LongCondition(void)                                          { return(0);                }
   virtual int       ShortCondition(void)                                         { return(0);                }
   virtual double    Direction(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CExpertSignal::CExpertSignal(void) : m_base_price(0.0),
                                     m_general(-1),          // no "main" signal
                                     m_weight(1.0),
                                     m_patterns_usage(-1),   // all models are used
                                     m_ignore(0),            // all additional filters are used
                                     m_invert(0),
                                     m_threshold_open(50),
                                     m_threshold_close(100),
                                     m_price_level(0.0),
                                     m_stop_level(0.0),
                                     m_take_level(0.0),
                                     m_expiration(0)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CExpertSignal::~CExpertSignal(void)
  {
  }
//+------------------------------------------------------------------+
//| Get flags of used timeseries                                     |
//| OUTPUT: flags of using of timeseries if another                  |
//|         symbol or timeframe is not set, otherwise - 0.           |
//+------------------------------------------------------------------+
int CExpertSignal::UsedSeries(void)
  {
   if(m_other_symbol || m_other_period) return(0);
//--- check of the flags of using timeseries in the additional filters
   int total=m_filters.Total();
//--- loop by the additional filters
   for(int i=0;i<total;i++)
     {
      CExpertSignal *filter=m_filters.At(i);
      //--- check pointer
      if(filter==NULL) return(false);
      m_used_series|=filter.UsedSeries();
     }
//---
   return(m_used_series);
  }
//+------------------------------------------------------------------+
//| Sets magic number for object and its dependent objects           |
//+------------------------------------------------------------------+
void CExpertSignal::Magic(ulong value)
  {
   int total=m_filters.Total();
//--- loop by the additional filters
   for(int i=0;i<total;i++)
     {
      CExpertSignal *filter=m_filters.At(i);
      //--- check pointer
      if(filter==NULL) continue;
      filter.Magic(value);
     }
//---
   CExpertBase::Magic(value);
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CExpertSignal::ValidationSettings(void)
  {
   if(!CExpertBase::ValidationSettings()) return(false);
//--- check of parameters in the additional filters
   int total=m_filters.Total();
//--- loop by the additional filters
   for(int i=0;i<total;i++)
     {
      CExpertSignal *filter=m_filters.At(i);
      //--- check pointer
      if(filter==NULL)                 return(false);
      if(!filter.ValidationSettings()) return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool CExpertSignal::InitIndicators(CIndicators* indicators)
  {
//--- check pointer
   if(indicators==NULL)       return(false);
//---
   CExpertSignal *filter;
   int            total=m_filters.Total();
//--- gather information about using of timeseries
   for(int i=0;i<total;i++)
     {
      filter=m_filters.At(i);
      m_used_series|=filter.UsedSeries();
     }
//--- create required timeseries
   if(!CExpertBase::InitIndicators(indicators)) return(false);
//--- initialization of indicators and timeseries in the additional filters
   for(int i=0;i<total;i++)
     {
      filter=m_filters.At(i);
      filter.SetPriceSeries(m_open,m_high,m_low,m_close);
      filter.SetOtherSeries(m_spread,m_time,m_tick_volume,m_real_volume);
      if(!filter.InitIndicators(indicators)) return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Setting an additional filter.                                    |
//+------------------------------------------------------------------+
bool CExpertSignal::AddFilter(CExpertSignal *filter)
  {
//--- check pointer
   if(filter==NULL)                                     return(false);
//--- primary initialization of the filter
   if(!filter.Init(m_symbol,m_period,m_adjusted_point)) return(false);
//--- add the filter to the array of filters
   if(!m_filters.Add(filter))                           return(false);
   filter.EveryTick(m_every_tick);
   filter.Magic(m_magic);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Generating a buy signal.                                         |
//| INPUT:  price      - reference for placing the price of opening, |
//|         sl         - reference for placing the stop loss price,  |
//|         tp         - reference for the take profit price,        |
//|         expiration - reference for placing the expiration time.  |
//| OUTPUT: true if there is a signal, otherwise - false.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpertSignal::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
  {
   bool   result   =false;
   double direction=Direction();
//--- the "prohibition" signal
   if(direction==EMPTY_VALUE) return(false);
//--- check of exceeding the threshold value
   if(direction>=m_threshold_open)
     {
      //--- there's a signal
      result=true;
      //--- try to get the levels of opening
      if(!OpenLongParams(price,sl,tp,expiration)) result=false;
     }
//--- zeroize the base price
   m_base_price=0.0;
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| Generating a sell signal.                                        |
//| INPUT:  price      - reference for placing the price of opening, |
//|         sl         - reference for placing the stop loss price,  |
//|         tp         - reference for the take profit price,        |
//|         expiration - reference for placing the expiration time.  |
//| OUTPUT: true if there is a signal, otherwise - false.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpertSignal::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
  {
   bool   result   =false;
   double direction=Direction();
//--- the "prohibition" signal
   if(direction==EMPTY_VALUE) return(false);
//--- check of exceeding the threshold value
   if(-direction>=m_threshold_open)
     {
      //--- there's a signal
      result=true;
      //--- try to get the levels of opening
      if(!OpenShortParams(price,sl,tp,expiration)) result=false;
     }
//--- zeroize the base price
   m_base_price=0.0;
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| Detecting the levels for buying .                                |
//| INPUT:  price      - reference for placing the price of opening, |
//|         sl         - reference for placing the stop loss price,  |
//|         tp         - reference for the take profit price,        |
//|         expiration - reference for placing the expiration time.  |
//| OUTPUT: true in case of successful execution, otherwise - false. |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpertSignal::OpenLongParams(double& price,double& sl,double& tp,datetime& expiration)
  {
   CExpertSignal *general=NULL;
   if(m_general!=-1) general=m_filters.At(m_general);
//---
   if(general==NULL)
     {
      //--- if a base price is not specified explicitly, take the current market price
      if(m_base_price==0.0) m_base_price=m_symbol.Ask();
      price      =m_symbol.NormalizePrice(m_base_price-m_price_level*PriceLevelUnit());
      sl         =(m_stop_level==0.0)?0.0:m_symbol.NormalizePrice(price-m_stop_level*PriceLevelUnit());
      tp         =(m_take_level==0.0)?0.0:m_symbol.NormalizePrice(price+m_take_level*PriceLevelUnit());
      expiration+=m_expiration*PeriodSeconds(m_period);
     }
   else
     {
      return(general.OpenLongParams(price,sl,tp,expiration));
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Detecting the levels for selling.                                |
//| INPUT:  price      - reference for placing the price of opening, |
//|         sl         - reference for placing the stop loss price,  |
//|         tp         - reference for the take profit price,        |
//|         expiration - reference for placing the expiration time.  |
//| OUTPUT: true in case of successful execution, otherwise - false. |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpertSignal::OpenShortParams(double& price,double& sl,double& tp,datetime& expiration)
  {
   CExpertSignal *general=NULL;
   if(m_general!=-1) general=m_filters.At(m_general);
//---
   if(general==NULL)
     {
      //--- if a base price is not specified explicitly, take the current market price
      if(m_base_price==0.0) m_base_price=m_symbol.Bid();
      price      =m_symbol.NormalizePrice(m_base_price+m_price_level*PriceLevelUnit());
      sl         =(m_stop_level==0.0)?0.0:m_symbol.NormalizePrice(price+m_stop_level*PriceLevelUnit());
      tp         =(m_take_level==0.0)?0.0:m_symbol.NormalizePrice(price-m_take_level*PriceLevelUnit());
      expiration+=m_expiration*PeriodSeconds(m_period);
     }
   else
     {
      return(general.OpenShortParams(price,sl,tp,expiration));
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Generating a signal for closing of a long position.              |
//| INPUT:  price - reference for placing the price of closing.      |
//| OUTPUT: true if there is a signal, otherwise - false.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpertSignal::CheckCloseLong(double& price)
  {
   bool   result   =false;
   double direction=Direction();
//--- the "prohibition" signal
   if(direction==EMPTY_VALUE) return(false);
//--- check of exceeding the threshold value
   if(-direction>=m_threshold_close)
     {
      //--- there's a signal
      result=true;
      //--- try to get the level of closing
      if(!CloseLongParams(price)) result=false;
     }
//--- zeroize the base price
   m_base_price=0.0;
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| Generating a signal for closing a short position.                |
//| INPUT:  price - reference for placing the price of closing.      |
//| OUTPUT: true if there is a signal, otherwise - false.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpertSignal::CheckCloseShort(double& price)
  {
   bool   result   =false;
   double direction=Direction();
//--- the "prohibition" signal
   if(direction==EMPTY_VALUE) return(false);
//--- check of exceeding the threshold value
   if(direction>=m_threshold_close)
     {
      //--- there's a signal
      result=true;
      //--- try to get the level of closing
      if(!CloseShortParams(price)) result=false;
     }
//--- zeroize the base price
   m_base_price=0.0;
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| Detecting the levels for closing a long position.                |
//| INPUT:  price - reference for placing the price of closing.      |
//| OUTPUT: true in case of successful execution, otherwise - false. |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpertSignal::CloseLongParams(double& price)
  {
   CExpertSignal *general=NULL;
   if(m_general!=-1) general=m_filters.At(m_general);
//---
   if(general==NULL)
     {
      //--- if a base price is not specified explicitly, take the current market price
      price=(m_base_price==0.0)?m_symbol.Bid():m_base_price;
     }
   else
     {
      return(general.CloseLongParams(price));
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Detecting the levels for closing a short position.               |
//| INPUT:  price - reference for placing the price of closing.      |
//| OUTPUT: true in case of successful execution, otherwise - false. |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpertSignal::CloseShortParams(double& price)
  {
   CExpertSignal *general=NULL;
   if(m_general!=-1) general=m_filters.At(m_general);
//---
   if(general==NULL)
     {
      //--- if a base price is not specified explicitly, take the current market price
      price=(m_base_price==0.0)?m_symbol.Ask():m_base_price;
     }
   else
     {
      return(general.CloseShortParams(price));
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Generating a signal for reversing a long position.               |
//| INPUT:  price      - reference for placing the price of reverse, |
//|         sl         - reference for placing the stop loss price,  |
//|         tp         - reference for the take profit price,        |
//|         expiration - reference for placing the expiration time.  |
//| OUTPUT: true if there is a signal, otherwise - false.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpertSignal::CheckReverseLong(double& price,double& sl,double& tp,datetime& expiration)
  {
   double c_price;
//--- check the signal of closing a long position
   if(!CheckCloseLong(c_price))                return(false);
//--- check the signal of opening a short position
   if(!CheckOpenShort(price,sl,tp,expiration)) return(false);
//--- difference between the close and open prices must not exceed two spreads
   if(c_price!=price)                          return(false);
//--- there's a signal
   return(true);
  }
//+------------------------------------------------------------------+
//| Generating a signal for reversing a short position.              |
//| INPUT:  price      - reference for placing the price of reverse, |
//|         sl         - reference for placing the stop loss price,  |
//|         tp         - reference for the take profit price,        |
//|         expiration - reference for placing the time expiration.  |
//| OUTPUT: true if there is a signal, otherwise - false.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpertSignal::CheckReverseShort(double& price,double& sl,double& tp,datetime& expiration)
  {
   double c_price;
//--- check the signal of closing a short position
   if(!CheckCloseShort(c_price))               return(false);
//--- check the signal of opening a long position
   if(!CheckOpenLong(price,sl,tp,expiration))  return(false);
//--- difference between the close and open prices must not exceed two spreads
   if(c_price!=price)                          return(false);
//--- there's a signal
   return(true);
  }
//+------------------------------------------------------------------+
//| Detecting the "weighted" direction.                              |
//| INPUT:  no.                                                      |
//| OUTPUT: >0 - if the probability of price growth is greater,      |
//|         =0 - if the direction is not determined                  |
//|              (small probability),                                |
//|         <0 - if the probability of price falling is greater.     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double CExpertSignal::Direction(void)
  {
   CExpertSignal *filter;
   long           mask;
   double         direction;
   double         result=m_weight*(LongCondition()-ShortCondition());
   int            number=(result==0.0)? 0 : 1;      // number of "voted"
//---
   int            total=m_filters.Total();
//--- loop by filters
   for(int i=0;i<total;i++)
     {
      //--- mask for bit maps
      mask=((long)1)<<i;
      //--- check of the flag of ignoring the signal of filter
      if((m_ignore&mask)!=0) continue;
      filter=m_filters.At(i);
      direction=filter.Direction();
      //--- the "prohibition" signal
      if(direction==EMPTY_VALUE) return(EMPTY_VALUE);
      //--- check of flag of inverting the signal of filter
      if((m_invert&mask)!=0) result-=direction;
      else                   result+=direction;
      number++;
     }
//--- normalization
   if(number!=0)             result/=number;
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
