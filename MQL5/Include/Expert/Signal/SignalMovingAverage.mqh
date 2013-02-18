//+------------------------------------------------------------------+
//|                                          SignalMovingAverage.mqh |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                              Revision 2010.10.12 |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals based on price crossover with SMA                  |
//| Type=Signal                                                      |
//| Name=MovingAverage                                               |
//| Class=CSignalMovingAverage                                       |
//| Page=                                                            |
//| Parameter=Period,int,12                                          |
//| Parameter=Shift,int,6                                            |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalMovingAverage.                                      |
//| Appointment: Class trading signals cross price and MA.           |
//|              Derives from class CExpertSignal.                   |
//+------------------------------------------------------------------+
class CSignalMovingAverage : public CExpertSignal
  {
protected:
   CiMA             *m_MA;
   CiOpen           *m_open;
   CiClose          *m_close;
   //--- input parameters
   int               m_ma_period;                   // MA period
   int               m_ma_shift;                    // MA shift

public:
                     CSignalMovingAverage();
                    ~CSignalMovingAverage();
   //--- methods initialize protected data
   void              Period(int period)  { m_ma_period=period;           }
   void              Shift(int shift)    { m_ma_shift=shift;             }
   virtual bool      InitIndicators(CIndicators* indicators);
   virtual bool      ValidationSettings();
   //---
   virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseLong(double& price);
   virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseShort(double& price);

protected:
   bool              InitMA(CIndicators* indicators);
   bool              InitOpen(CIndicators* indicators);
   bool              InitClose(CIndicators* indicators);
   //---
   double            MA(int ind)         { return(m_MA.Main(ind));       }
   double            Open(int ind)       { return(m_open.GetData(ind));  }
   double            Close(int ind)      { return(m_close.GetData(ind)); }
   double            StateMA(int ind)    { return(MA(ind)-MA(ind+1));    }
   double            StateOpen(int ind)  { return(Open(ind)-MA(ind));    }
   double            StateClose(int ind) { return(Close(ind)-MA(ind));   }
  };
//+------------------------------------------------------------------+
//| Constructor CSignalMovingAverage.                                |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CSignalMovingAverage::CSignalMovingAverage()
  {
//--- initialize protected data
   m_MA        =NULL;
   m_open      =NULL;
   m_close     =NULL;
//--- set default inputs
   m_ma_period =12;
   m_ma_shift  =6;
  }
//+------------------------------------------------------------------+
//| Destructor CSignalMovingAverage.                                 |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CSignalMovingAverage::~CSignalMovingAverage()
  {
//---
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if settings are correct, false otherwise.           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalMovingAverage::ValidationSettings()
  {
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
//| Create indicators.                                               |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalMovingAverage::InitIndicators(CIndicators* indicators)
  {
//--- check
   if(indicators==NULL)       return(false);
//--- create and initialize MA indicator
   if(!InitMA(indicators))    return(false);
//--- create and initialize Open series
   if(!InitOpen(indicators))  return(false);
//--- create and initialize Close series
   if(!InitClose(indicators)) return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create MA indicators.                                            |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalMovingAverage::InitMA(CIndicators* indicators)
  {
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
//--- initialize EMA indicator
   if(!m_MA.Create(m_symbol.Name(),m_period,m_ma_period,m_ma_shift,MODE_SMA,PRICE_CLOSE))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
   m_MA.BufferResize(3+m_ma_shift);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create Open series.                                              |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalMovingAverage::InitOpen(CIndicators* indicators)
  {
//--- create Open series
   if(m_open==NULL)
      if((m_open=new CiOpen)==NULL)
        {
         printf(__FUNCTION__+": error creating object");
         return(false);
        }
//--- add Open series to collection
   if(!indicators.Add(m_open))
     {
      printf(__FUNCTION__+": error adding object");
      delete m_open;
      return(false);
     }
//--- initialize Open series
   if(!m_open.Create(m_symbol.Name(),m_period))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create Close series.                                             |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalMovingAverage::InitClose(CIndicators* indicators)
  {
//--- create Close series
   if(m_close==NULL)
      if((m_close=new CiClose)==NULL)
        {
         printf(__FUNCTION__+": error creating object");
         return(false);
        }
//--- add Close series to collection
   if(!indicators.Add(m_close))
     {
      printf(__FUNCTION__+": error adding object");
      delete m_close;
      return(false);
     }
//--- initialize Close series
   if(!m_close.Create(m_symbol.Name(),m_period))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
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
bool CSignalMovingAverage::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
  {
   price=0.0;
   sl   =0.0;
   tp   =0.0;
//---
   return(StateOpen(1)<0 && StateClose(1)>0 && StateMA(1)>0);
  }
//+------------------------------------------------------------------+
//| Check conditions for long position close.                        |
//| INPUT:  price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalMovingAverage::CheckCloseLong(double& price)
  {
   price=0.0;
//---
   return(StateOpen(1)>0 && StateClose(1)<0 && StateMA(1)<0);
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
bool CSignalMovingAverage::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
  {
   price=0.0;
   sl   =0.0;
   tp   =0.0;
//---
   return(StateOpen(1)>0 && StateClose(1)<0 && StateMA(1)<0);
  }
//+------------------------------------------------------------------+
//| Check conditions for short position close.                       |
//| INPUT:  price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalMovingAverage::CheckCloseShort(double& price)
  {
   price=0.0;
//---
   return(StateOpen(1)<0 && StateClose(1)>0 && StateMA(1)>0);
  }
//+------------------------------------------------------------------+
