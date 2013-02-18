//+------------------------------------------------------------------+
//|                                                       Expert.mqh |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                              Revision 2011.03.30 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Include files.                                                   |
//+------------------------------------------------------------------+
#include "ExpertBase.mqh"
#include "ExpertTrade.mqh"
#include "ExpertSignal.mqh"
#include "ExpertMoney.mqh"
#include "ExpertTrailing.mqh"
//+------------------------------------------------------------------+
//| enumerations                                                     |
//+------------------------------------------------------------------+
//--- flags of expected events
enum ENUM_TRADE_EVENTS
  {
   TRADE_EVENT_NO_EVENT              =0,         // no expected events
   TRADE_EVENT_POSITION_OPEN         =0x1,       // flag of expecting the "opening of position" event
   TRADE_EVENT_POSITION_VOLUME_CHANGE=0x2,       // flag of expecting of the "modification of position volume" event
   TRADE_EVENT_POSITION_MODIFY       =0x4,       // flag of expecting of the "modification of stop order of position" event
   TRADE_EVENT_POSITION_CLOSE        =0x8,       // flag of expecting of the "closing of position" event
   TRADE_EVENT_POSITION_STOP_TAKE    =0x10,      // flag of expecting of the "triggering of stop order of position"
   TRADE_EVENT_ORDER_PLACE           =0x20,      // flag of expecting of the "placing of pending order" event
   TRADE_EVENT_ORDER_MODIFY          =0x40,      // flag of expecting of the "modification of pending order" event
   TRADE_EVENT_ORDER_DELETE          =0x80,      // flag of expecting of the "deletion of pending order" event
   TRADE_EVENT_ORDER_TRIGGER         =0x100      // flag of expecting of the "triggering of pending order" event
  };
//+------------------------------------------------------------------+
//| Macro definitions.                                               |
//+------------------------------------------------------------------+
//--- check the expectation of event
#define IS_WAITING_POSITION_OPENED         ((m_waiting_event&TRADE_EVENT_POSITION_OPEN)!=0)
#define IS_WAITING_POSITION_VOLUME_CHANGED ((m_waiting_event&TRADE_EVENT_POSITION_VOLUME_CHANGE)!=0)
#define IS_WAITING_POSITION_MODIFIED       ((m_waiting_event&TRADE_EVENT_POSITION_MODIFY)!=0)
#define IS_WAITING_POSITION_CLOSED         ((m_waiting_event&TRADE_EVENT_POSITION_CLOSE)!=0)
#define IS_WAITING_POSITION_STOP_TAKE      ((m_waiting_event&TRADE_EVENT_POSITION_STOP_TAKE)!=0)
#define IS_WAITING_ORDER_PLACED            ((m_waiting_event&TRADE_EVENT_ORDER_PLACE)!=0)
#define IS_WAITING_ORDER_MODIFIED          ((m_waiting_event&TRADE_EVENT_ORDER_MODIFY)!=0)
#define IS_WAITING_ORDER_DELETED           ((m_waiting_event&TRADE_EVENT_ORDER_DELETE)!=0)
#define IS_WAITING_ORDER_TRIGGERED         ((m_waiting_event&TRADE_EVENT_ORDER_TRIGGER)!=0)
//+------------------------------------------------------------------+
//| Class CExpert.                                                   |
//| Purpose: Base class expert advisor.                              |
//| Derives from class CExpertBase.                                  |
//+------------------------------------------------------------------+
class CExpert : public CExpertBase
  {
protected:
   int               m_period_flags;             // timeframe flags (as visible flags)
   int               m_max_orders;               // max number of orders (include position)
   MqlDateTime       m_last_tick_time;           // time of last tick
   datetime          m_expiration;               // time expiration order
   //--- history info
   int               m_pos_tot;                  // number of open positions
   int               m_deal_tot;                 // number of deals in history
   int               m_ord_tot;                  // number of pending orders
   int               m_hist_ord_tot;             // number of orders in history
   datetime          m_beg_date;                 // start date of history
   //---
   int               m_waiting_event;            // flags of expected trade events
   //--- trading objects
   CExpertTrade     *m_trade;                    // trading object
   CExpertSignal    *m_signal;                   // trading signals object
   CExpertMoney     *m_money;                    // money manager object
   CExpertTrailing  *m_trailing;                 // trailing stops object
   //--- indicators
   CIndicators       m_indicators;               // indicator collection to fast recalculations
   //--- market objects
   CPositionInfo     m_position;                 // position info object
   COrderInfo        m_order;                    // order info object
   //--- flags of handlers
   bool              m_on_tick_process;          // OnTick will be processed       (default true)
   bool              m_on_trade_process;         // OnTrade will be processed      (default false)
   bool              m_on_timer_process;         // OnTimer will be processed      (default false)
   bool              m_on_chart_event_process;   // OnChartEvent will be processed (default false)
   bool              m_on_book_event_process;    // OnBookEvent will be processed  (default false)

public:
                     CExpert();
                    ~CExpert()                              { Deinit();                       }
   //--- initialization
   bool              Init(string symbol,ENUM_TIMEFRAMES period,bool every_tick,ulong magic=0);
   void              Magic(ulong value);
   //--- initialization trading objects
   virtual bool      InitSignal(CExpertSignal* signal=NULL);
   virtual bool      InitTrailing(CExpertTrailing* trailing=NULL);
   virtual bool      InitMoney(CExpertMoney* money=NULL);
   virtual bool      InitTrade(ulong magic,CExpertTrade* trade=NULL);
   //--- deinitialization
   virtual void      Deinit();
   //--- methods of setting adjustable parameters
   void              OnTickProcess(bool value)              { m_on_tick_process=value;        }
   void              OnTradeProcess(bool value)             { m_on_trade_process=value;       }
   void              OnTimerProcess(bool value)             { m_on_timer_process=value;       }
   void              OnChartEventProcess(bool value)        { m_on_chart_event_process=value; }
   void              OnBookEventProcess(bool value)         { m_on_book_event_process=value;  }
   int               MaxOrders()                      const { return(m_max_orders);           }
   void              MaxOrders(int value)                   { m_max_orders=value;             }
   //--- methods of access to protected data
   CExpertSignal*    Signal()                         const { return(m_signal);               }
   //--- method of verification of settings
   virtual bool      ValidationSettings();
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators* indicators=NULL);
   //--- event handlers
   virtual void      OnTick();
   virtual void      OnTrade();
   virtual void      OnTimer();
   virtual void      OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam);
   virtual void      OnBookEvent(const string& symbol);

protected:
   //--- initialization
   virtual bool      InitParameters()                       { return(true);                   }
   //--- deinitialization
   virtual void      DeinitTrade();
   virtual void      DeinitSignal();
   virtual void      DeinitTrailing();
   virtual void      DeinitMoney();
   virtual void      DeinitIndicators();
   //--- refreshing 
   virtual bool      Refresh();
   //--- processing (main method)
   virtual bool      Processing();
   //--- trade open positions check
   virtual bool      CheckOpen();
   virtual bool      CheckOpenLong();
   virtual bool      CheckOpenShort();
   //--- trade open positions processing
   virtual bool      OpenLong(double price,double sl,double tp);
   virtual bool      OpenShort(double price,double sl,double tp);
   //--- trade reverse positions check
   virtual bool      CheckReverse();
   virtual bool      CheckReverseLong();
   virtual bool      CheckReverseShort();
   //--- trade reverse positions processing
   virtual bool      ReverseLong(double price,double sl,double tp);
   virtual bool      ReverseShort(double price,double sl,double tp);
   //--- trade close positions check
   virtual bool      CheckClose();
   virtual bool      CheckCloseLong();
   virtual bool      CheckCloseShort();
   //--- trade close positions processing
   virtual bool      CloseAll(double lot);
   virtual bool      Close();
   virtual bool      CloseLong(double price);
   virtual bool      CloseShort(double price);
   //--- trailing stop check
   virtual bool      CheckTrailingStop();
   virtual bool      CheckTrailingStopLong();
   virtual bool      CheckTrailingStopShort();
   //--- trailing stop processing
   virtual bool      TrailingStopLong(double sl,double tp);
   virtual bool      TrailingStopShort(double sl,double tp);
   //--- trailing order check
   virtual bool      CheckTrailingOrderLong();
   virtual bool      CheckTrailingOrderShort();
   //--- trailing order processing
   virtual bool      TrailingOrderLong(double delta);
   virtual bool      TrailingOrderShort(double delta);
   //--- delete order check
   virtual bool      CheckDeleteOrderLong();
   virtual bool      CheckDeleteOrderShort();
   //--- delete order processing
   virtual bool      DeleteOrders();
   virtual bool      DeleteOrder();
   virtual bool      DeleteOrderLong();
   virtual bool      DeleteOrderShort();
   //--- lot for trade
   double            LotOpenLong(double price,double sl);
   double            LotOpenShort(double price,double sl);
   double            LotReverse(double sl);
   //--- methods of working with trade history
   void              PrepareHistoryDate();
   void              HistoryPoint(bool from_check_trade=false);
   bool              CheckTradeState();
   //--- set/reset waiting events
   void              WaitEvent(ENUM_TRADE_EVENTS event)     { m_waiting_event|=event;         }
   void              NoWaitEvent(ENUM_TRADE_EVENTS event)   { m_waiting_event&=~event;        }
   //--- trade events
   virtual bool      TradeEventPositionStopTake()           { return(true);                   }
   virtual bool      TradeEventOrderTriggered()             { return(true);                   }
   virtual bool      TradeEventPositionOpened()             { return(true);                   }
   virtual bool      TradeEventPositionVolumeChanged()      { return(true);                   }
   virtual bool      TradeEventPositionModified()           { return(true);                   }
   virtual bool      TradeEventPositionClosed()             { return(true);                   }
   virtual bool      TradeEventOrderPlaced()                { return(true);                   }
   virtual bool      TradeEventOrderModified()              { return(true);                   }
   virtual bool      TradeEventOrderDeleted()               { return(true);                   }
   virtual bool      TradeEventNotIdentified()              { return(true);                   }
   //--- timeframe functions
   void              TimeframeAdd(ENUM_TIMEFRAMES period);
   int               TimeframesFlags(MqlDateTime& time);
  };
//+------------------------------------------------------------------+
//| Constructor CExpert.                                             |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
CExpert::CExpert()
  {
//--- initialization of protected data
   m_other_symbol          =true;
   m_other_period          =true;
//---
   m_adjusted_point        =10;
   m_period                =WRONG_VALUE;
   m_period_flags          =0;
   m_last_tick_time.min    =-1;
   m_expiration            =0;
//---
   m_pos_tot               =0;
   m_deal_tot              =0;
   m_ord_tot               =0;
   m_hist_ord_tot          =0;
   m_beg_date              =0;
//---
   m_trade                 =NULL;
   m_signal                =NULL;
   m_money                 =NULL;
   m_trailing              =NULL;
//--- setting default values for input parameters
   m_on_tick_process       =true;
   m_on_trade_process      =false;
   m_on_timer_process      =false;
   m_on_chart_event_process=false;
   m_on_book_event_process =false;
   m_max_orders            =1;
  }
//+------------------------------------------------------------------+
//| Initialization and checking for input parameters                 |
//| INPUT:  symbol     - symbol name,                                |
//|         period     - period,                                     |
//|         every_tick - every tick flag,                            |
//|         magic      - magic number for trade.                     |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::Init(string symbol,ENUM_TIMEFRAMES period,bool every_tick,ulong magic)
  {
//--- returns false if the EA is initialized on a symbol/timeframe different from the current one
   if(symbol!=Symbol() || period!=Period())
     {
      printf(__FUNCTION__+": wrong symbol or timeframe (must be %s:%s)",symbol,EnumToString(period));
      return(false);
     }
//--- initialize common information
   if(m_symbol==NULL)
     {
      if((m_symbol=new CSymbolInfo)==NULL) return(false);
     }
   if(!m_symbol.Name(symbol)) return(false);
   m_period    =period;                     // period
   m_every_tick=every_tick;
   m_magic     =magic;
   if(every_tick)
      TimeframeAdd(WRONG_VALUE);            // add all periods
   else
      TimeframeAdd(period);                 // add specified period
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5) digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- initializing objects expert
   if(!InitTrade(magic))
     {
      printf(__FUNCTION__+": error initialization trade object");
      return(false);
     }
   if(!InitSignal())
     {
      printf(__FUNCTION__+": error initialization signal object");
      return(false);
     }
   if(!InitTrailing())
     {
      printf(__FUNCTION__+": error initialization trailing object");
      return(false);
     }
   if(!InitMoney())
     {
      printf(__FUNCTION__+": error initialization money object");
      return(false);
     }
   if(!InitParameters())
     {
      printf(__FUNCTION__+": error initialization parameters");
      return(false);
     }
//--- initialization for working with trade history
   PrepareHistoryDate();
   HistoryPoint();
//--- primary initialization is successful, pass to the phase of tuning
   m_init_phase    =INIT_PHASE_TUNING;
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Sets magic number for object and its dependent objects           |
//| INPUT:  value - new value of magic number.                       |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CExpert::Magic(ulong value)
  {
   if(m_trade!=NULL)    m_trade.SetExpertMagicNumber(value);
   if(m_signal!=NULL)   m_signal.Magic(value);
   if(m_money!=NULL)    m_money.Magic(value);
   if(m_trailing!=NULL) m_trailing.Magic(value);
//---
   CExpertBase::Magic(value);
  }
//+------------------------------------------------------------------+
//| Initialization trade object                                      |
//| INPUT:  magic - magic number for trade,                          |
//|         trade - pointer of trade object.                         |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::InitTrade(ulong magic,CExpertTrade* trade=NULL)
  {
//--- удаляем существующий объект
   if(m_trade!=NULL) delete m_trade;
//---
   if(trade==NULL)
     {
      if((m_trade=new CExpertTrade)==NULL) return(false);
     }
   else m_trade=trade;
//--- tune trade object
   m_trade.SetSymbol(GetPointer(m_symbol));
   m_trade.SetExpertMagicNumber(magic);
   //--- set default deviation for trading in adjusted points
   m_trade.SetDeviationInPoints((ulong)(3*m_adjusted_point/m_symbol.Point()));
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization signal object                                     |
//| INPUT:  signal - pointer of signal object.                       |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::InitSignal(CExpertSignal* signal)
  {
   if(m_signal!=NULL) delete m_signal;
//---
   if(signal==NULL)
     {
      if((m_signal=new CExpertSignal)==NULL) return(false);
     }
   else
      m_signal=signal;
//--- initializing signal object
   if(!m_signal.Init(GetPointer(m_symbol),m_period,m_adjusted_point)) return(false);
   m_signal.EveryTick(m_every_tick);
   m_signal.Magic(m_magic);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization trailing object                                   |
//| INPUT:  trailing - pointer of trailing object.                   |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::InitTrailing(CExpertTrailing* trailing)
  {
   if(m_trailing!=NULL) delete m_trailing;
//---
   if(trailing==NULL)
     {
      if((m_trailing=new CExpertTrailing)==NULL) return(false);
     }
   else
      m_trailing=trailing;
//--- initializing trailing object
   if(!m_trailing.Init(GetPointer(m_symbol),m_period,m_adjusted_point)) return(false);
   m_trailing.EveryTick(m_every_tick);
   m_trailing.Magic(m_magic);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization money object                                      |
//| INPUT:  money - pointer of money object.                         |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::InitMoney(CExpertMoney *money)
  {
   if(m_money!=NULL) delete m_money;
//---
   if(money==NULL)
     {
      if((m_money=new CExpertMoney)==NULL) return(false);
     }
   else
      m_money=money;
//--- initializing money object
   if(!m_money.Init(GetPointer(m_symbol),m_period,m_adjusted_point)) return(false);
   m_money.EveryTick(m_every_tick);
   m_money.Magic(m_magic);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Validation settings                                              |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::ValidationSettings()
  {
   if(!CExpertBase::ValidationSettings()) return(false);
//--- Check signal parameters
   if(!m_signal.ValidationSettings())
     {
      printf(__FUNCTION__+": error signal parameters");
      return(false);
     }
//--- Check trailing parameters
   if(!m_trailing.ValidationSettings())
     {
      printf(__FUNCTION__+": error trailing parameters");
      return(false);
     }
//--- Check money parameters
   if(!m_money.ValidationSettings())
     {
      printf(__FUNCTION__+": error money parameters");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization indicators                                        |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::InitIndicators(CIndicators* indicators)
  {
//--- NULL always comes as the parameter, but here it's not significant for us
   CIndicators* indicators_ptr=GetPointer(m_indicators);
//--- gather information about using of timeseries
   m_used_series|=m_signal.UsedSeries();
   m_used_series|=m_trailing.UsedSeries();
   m_used_series|=m_money.UsedSeries();
//--- create required timeseries
   if(!CExpertBase::InitIndicators(indicators_ptr)) return(false);
   m_signal.SetPriceSeries(m_open,m_high,m_low,m_close);
   m_signal.SetOtherSeries(m_spread,m_time,m_tick_volume,m_real_volume);
   if(!m_signal.InitIndicators(indicators_ptr))
     {
      printf(__FUNCTION__+": error initialization indicators of signal object");
      return(false);
     }
   m_trailing.SetPriceSeries(m_open,m_high,m_low,m_close);
   m_trailing.SetOtherSeries(m_spread,m_time,m_tick_volume,m_real_volume);
   if(!m_trailing.InitIndicators(indicators_ptr))
     {
      printf(__FUNCTION__+": error initialization indicators of trailing object");
      return(false);
     }
   m_money.SetPriceSeries(m_open,m_high,m_low,m_close);
   m_money.SetOtherSeries(m_spread,m_time,m_tick_volume,m_real_volume);
   if(!m_money.InitIndicators(indicators_ptr))
     {
      printf(__FUNCTION__+": error initialization indicators of money object");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Deinitialization expert                                          |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CExpert::Deinit()
  {
//--- delete trade class
   DeinitTrade();
//--- delete signal class
   DeinitSignal();
//--- delete trailing class
   DeinitTrailing();
//--- delete money class
   DeinitMoney();
//--- delete indicators collection
   DeinitIndicators();
  }
//+------------------------------------------------------------------+
//| Deinitialization trade object                                    |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CExpert::DeinitTrade()
  {
   if(m_trade!=NULL)
     {
      delete m_trade;
      m_trade=NULL;
     }
  }
//+------------------------------------------------------------------+
//| Deinitialization signal object                                   |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CExpert::DeinitSignal()
  {
   if(m_signal!=NULL)
     {
      delete m_signal;
      m_signal=NULL;
     }
  }
//+------------------------------------------------------------------+
//| Deinitialization trailing object                                 |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CExpert::DeinitTrailing()
  {
   if(m_trailing!=NULL)
     {
      delete m_trailing;
      m_trailing=NULL;
     }
  }
//+------------------------------------------------------------------+
//| Deinitialization money object                                    |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CExpert::DeinitMoney()
  {
   if(m_money!=NULL)
     {
      delete m_money;
      m_money=NULL;
     }
  }
//+------------------------------------------------------------------+
//| Deinitialization indicators                                      |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CExpert::DeinitIndicators()
  {
   m_indicators.Clear();
  }
//+------------------------------------------------------------------+
//| Refreshing data for processing                                   |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::Refresh()
  {
   MqlDateTime time;
//--- refresh rates
   if(!m_symbol.RefreshRates()) return(false);
//--- check need processing
   TimeToStruct(m_symbol.Time(),time);
   if(m_period_flags!=WRONG_VALUE && m_period_flags!=0)
      if((m_period_flags & TimeframesFlags(time))==0) return(false);
   m_last_tick_time=time;
//--- refresh indicators
   m_indicators.Refresh();
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Main function                                                    |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if any trade operation processed, false otherwise.  |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::Processing()
  {
//--- check if open positions
   if(m_position.Select(m_symbol.Name()))
     {
      //--- open position is available
      //--- check the possibility of reverse the position
      if(CheckReverse()) return(true);
      //--- check the possibility of closing the position/delete pending orders
      if(!CheckClose())
        {
         //--- check the possibility of modifying the position
         if(CheckTrailingStop()) return(true);
         //--- return without operations
         return(false);
        }
     }
//--- check if plased pending orders
   int total=OrdersTotal();
   if(total!=0)
     {
      for(int i=total-1;i>=0;i--)
        {
         m_order.SelectByIndex(i);
         if(m_order.Symbol()!=m_symbol.Name()) continue;
         if(m_order.OrderType()==ORDER_TYPE_BUY_LIMIT || m_order.OrderType()==ORDER_TYPE_BUY_STOP)
           {
            //--- check the ability to delete a pending order to buy
            if(CheckDeleteOrderLong()) return(true);
            //--- check the possibility of modifying a pending order to buy
            if(CheckTrailingOrderLong()) return(true);
           }
         else
           {
            //--- check the ability to delete a pending order to sell
            if(CheckDeleteOrderShort()) return(true);
            //--- check the possibility of modifying a pending order to sell
            if(CheckTrailingOrderShort()) return(true);
           }
         //--- return without operations
         return(false);
        }
     }
//--- check the possibility of opening a position/setting pending order
   if(CheckOpen()) return(true);
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| OnTick handler                                                   |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CExpert::OnTick()
  {
//--- check process flag
   if(!m_on_tick_process) return;
//--- updated quotes and indicators
   if(!Refresh())         return;
//--- expert processing
   Processing();
  }
//+------------------------------------------------------------------+
//| OnTrade handler                                                  |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CExpert::OnTrade()
  {
//--- check process flag
   if(!m_on_trade_process) return;
   CheckTradeState();
  }
//+------------------------------------------------------------------+
//| OnTimer handler                                                  |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CExpert::OnTimer()
  {
//--- check process flag
   if(!m_on_timer_process) return;
  }
//+------------------------------------------------------------------+
//| OnChartEvent handler                                             |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CExpert::OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
  {
//--- check process flag
   if(!m_on_chart_event_process) return;
  }
//+------------------------------------------------------------------+
//| OnBookEvent handler                                              |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CExpert::OnBookEvent(const string& symbol)
  {
//--- check process flag
   if(!m_on_book_event_process) return;
  }
//+------------------------------------------------------------------+
//| Check for position open or limit/stop order set                  |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CheckOpen()
  {
   if(CheckOpenLong())  return(true);
   if(CheckOpenShort()) return(true);
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for long position open or limit/stop order set             |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CheckOpenLong()
  {
   double   price=EMPTY_VALUE;
   double   sl=0.0;
   double   tp=0.0;
   datetime expiration=TimeCurrent();
//--- check signal for long enter operations
   if(m_signal.CheckOpenLong(price,sl,tp,expiration))
     {
      if(!m_trade.SetOrderExpiration(expiration))
        {
         m_expiration=expiration;
        }
      return(OpenLong(price,sl,tp));
     }
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for short position open or limit/stop order set            |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CheckOpenShort()
  {
   double   price=EMPTY_VALUE;
   double   sl=0.0;
   double   tp=0.0;
   datetime expiration=TimeCurrent();
//--- check signal for short enter operations
   if(m_signal.CheckOpenShort(price,sl,tp,expiration))
     {
      if(!m_trade.SetOrderExpiration(expiration))
        {
         m_expiration=expiration;
        }
      return(OpenShort(price,sl,tp));
     }
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Long position open or limit/stop order set                       |
//| INPUT:  price - price,                                           |
//|         sl    - stop loss,                                       |
//|         tp    - take profit.                                     |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::OpenLong(double price,double sl,double tp)
  {
   if(price==EMPTY_VALUE) return(false);
//--- get lot for open
   double lot=LotOpenLong(price,sl);
//--- check lot for open
   if(lot==0.0) return(false);
//---
   return(m_trade.Buy(lot,price,sl,tp));
  }
//+------------------------------------------------------------------+
//| Short position open or limit/stop order set                      |
//| INPUT:  price - price,                                           |
//|         sl    - stop loss,                                       |
//|         tp    - take profit.                                     |
//| OUTPUT: true-if trade operation successful, false otherwise.     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::OpenShort(double price,double sl,double tp)
  {
   if(price==EMPTY_VALUE) return(false);
//--- get lot for open
   double lot=LotOpenShort(price,sl);
//--- check lot for open
   if(lot==0.0) return(false);
//---
   return(m_trade.Sell(lot,price,sl,tp));
  }
//+------------------------------------------------------------------+
//| Check for position reverse                                       |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CheckReverse()
  {
   if(m_position.PositionType()==POSITION_TYPE_BUY)
     {
      //--- check the possibility of reverse the long position
      if(CheckReverseLong())  return(true);
     }
   else
      //--- check the possibility of reverse the short position
      if(CheckReverseShort()) return(true);
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for long position reverse                                  |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CheckReverseLong()
  {
   double   price=EMPTY_VALUE;
   double   sl=0.0;
   double   tp=0.0;
   datetime expiration=TimeCurrent();
//--- check signal for long reverse operations
   if(m_signal.CheckReverseLong(price,sl,tp,expiration)) return(ReverseLong(price,sl,tp));
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for short position reverse                                 |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CheckReverseShort()
  {
   double   price=EMPTY_VALUE;
   double   sl=0.0;
   double   tp=0.0;
   datetime expiration=TimeCurrent();
//--- check signal for short reverse operations
   if(m_signal.CheckReverseShort(price,sl,tp,expiration)) return(ReverseShort(price,sl,tp));
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Long position reverse                                            |
//| INPUT:  price - price,                                           |
//|         sl    - stop loss,                                       |
//|         tp    - take profit.                                     |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::ReverseLong(double price,double sl,double tp)
  {
   if(price==EMPTY_VALUE) return(false);
//--- get lot for reverse
   double lot=LotReverse(sl);
//--- check lot
   if(lot==0.0) return(false);
//---
   return(m_trade.Sell(lot,price,sl,tp));
  }
//+------------------------------------------------------------------+
//| Short position reverse                                           |
//| INPUT:  price - price,                                           |
//|         sl    - stop loss,                                       |
//|         tp    - take profit.                                     |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::ReverseShort(double price,double sl,double tp)
  {
   if(price==EMPTY_VALUE) return(false);
//--- get lot for reverse
   double lot=LotReverse(sl);
//--- check lot
   if(lot==0.0) return(false);
//---
   return(m_trade.Buy(lot,price,sl,tp));
  }
//+------------------------------------------------------------------+
//| Check for position close or limit/stop order delete              |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CheckClose()
  {
   double lot;
//--- position must be selected before call
   if((lot=m_money.CheckClose(GetPointer(m_position)))!=0.0)
      return(CloseAll(lot));
//--- check for position type
   if(m_position.PositionType()==POSITION_TYPE_BUY)
     {
      //--- check the possibility of closing the long position / delete pending orders to buy
      if(CheckCloseLong())
        {
         DeleteOrders();
         return(true);
        }
     }
   else
     {
      //--- check the possibility of closing the short position / delete pending orders to sell
      if(CheckCloseShort())
        {
         DeleteOrders();
         return(true);
        }
     }
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for long position close or limit/stop order delete         |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CheckCloseLong()
  {
   double price=EMPTY_VALUE;
//--- check for long close operations
   if(m_signal.CheckCloseLong(price))
      return(CloseLong(price));
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for short position close or limit/stop order delete        |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CheckCloseShort()
  {
   double price=EMPTY_VALUE;
//--- check for short close operations
   if(m_signal.CheckCloseShort(price))
      return(CloseShort(price));
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Position close and orders delete                                 |
//| INPUT:  lot - volume for close.                                  |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CloseAll(double lot)
  {
   bool result;
//--- check for close operations
   if(m_position.PositionType()==POSITION_TYPE_BUY) result=m_trade.Sell(lot,0,0,0);
   else                                     result=m_trade.Buy(lot,0,0,0);
   result|=DeleteOrders();
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Position close                                                   |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::Close()
  {
   return(m_trade.PositionClose(m_symbol.Name()));
  }
//+------------------------------------------------------------------+
//| Long position close                                              |
//| INPUT:  price - price for close.                                 |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CloseLong(double price)
  {
   if(price==EMPTY_VALUE) return(false);
//---
   return(m_trade.Sell(m_position.Volume(),price,0,0));
  }
//+------------------------------------------------------------------+
//| Short position close                                             |
//| INPUT:  price - price for close.                                 |
//| OUTPUT: true-if trade operation successful, false otherwise.     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CloseShort(double price)
  {
   if(price==EMPTY_VALUE) return(false);
//---
   return(m_trade.Buy(m_position.Volume(),price,0,0));
  }
//+------------------------------------------------------------------+
//| Check for trailing stop/profit position                          |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CheckTrailingStop()
  {
//--- position must be selected before call
   if(m_position.PositionType()==POSITION_TYPE_BUY)
     {
      //--- check the possibility of modifying the long position
      if(CheckTrailingStopLong()) return(true);
     }
   else
     {
      //--- check the possibility of modifying the short position
      if(CheckTrailingStopShort()) return(true);
     }
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for trailing stop/profit long position                     |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CheckTrailingStopLong()
  {
   double sl=EMPTY_VALUE;
   double tp=EMPTY_VALUE;
//--- check for long trailing stop operations
   if(m_trailing.CheckTrailingStopLong(GetPointer(m_position),sl,tp))
     {
      if(sl==EMPTY_VALUE) sl=m_position.StopLoss();
      if(tp==EMPTY_VALUE) tp=m_position.TakeProfit();
      //--- long trailing stop operations
      return(TrailingStopLong(sl,tp));
     }
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for trailing stop/profit short position                    |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CheckTrailingStopShort()
  {
   double sl=EMPTY_VALUE;
   double tp=EMPTY_VALUE;
//--- check for short trailing stop operations
   if(m_trailing.CheckTrailingStopShort(GetPointer(m_position),sl,tp))
     {
      if(sl==EMPTY_VALUE) sl=m_position.StopLoss();
      if(tp==EMPTY_VALUE) tp=m_position.TakeProfit();
      //--- short trailing stop operations
      return(TrailingStopShort(sl,tp));
     }
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Trailing stop/profit long position                               |
//| INPUT:  sl - new stop loss,                                      |
//|         tp - new take profit.                                    |
//| OUTPUT: true-if trade operation successful, false otherwise.     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::TrailingStopLong(double sl,double tp)
  {
   return(m_trade.PositionModify(m_symbol.Name(),sl,tp));
  }
//+------------------------------------------------------------------+
//| Trailing stop/profit short position                              |
//| INPUT:  sl - new stop loss,                                      |
//|         tp - new take profit.                                    |
//| OUTPUT: true-if trade operation successful, false otherwise.     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::TrailingStopShort(double sl,double tp)
  {
   return(m_trade.PositionModify(m_symbol.Name(),sl,tp));
  }
//+------------------------------------------------------------------+
//| Check for trailing long limit/stop order                         |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CheckTrailingOrderLong()
  {
   double price;
//--- check the possibility of modifying the long order
   if(m_signal.CheckTrailingOrderLong(GetPointer(m_order),price))
      return(TrailingOrderLong(m_order.PriceOpen()-price));
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for trailing short limit/stop order                        |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CheckTrailingOrderShort()
  {
   double price;
//--- check the possibility of modifying the short order
   if(m_signal.CheckTrailingOrderShort(GetPointer(m_order),price))
      return(TrailingOrderShort(m_order.PriceOpen()-price));
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Trailing long limit/stop order                                   |
//| INPUT:  delta - price change.                                    |
//| OUTPUT: true-if trade operation successful, false otherwise.     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::TrailingOrderLong(double delta)
  {
   ulong  ticket=m_order.Ticket();
   double price =m_order.PriceOpen()-delta;
   double sl    =m_order.StopLoss()-delta;
   double tp    =m_order.TakeProfit()-delta;
//--- modifying the long order
   return(m_trade.OrderModify(ticket,price,sl,tp,m_order.TypeTime(),m_order.TimeExpiration()));
  }
//+------------------------------------------------------------------+
//| Trailing short limit/stop order                                  |
//| INPUT:  delta - price change.                                    |
//| OUTPUT: true-if trade operation successful, false otherwise.     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::TrailingOrderShort(double delta)
  {
   ulong  ticket=m_order.Ticket();
   double price =m_order.PriceOpen()-delta;
   double sl    =m_order.StopLoss()-delta;
   double tp    =m_order.TakeProfit()-delta;
//--- modifying the short order
   return(m_trade.OrderModify(ticket,price,sl,tp,m_order.TypeTime(),m_order.TimeExpiration()));
  }
//+------------------------------------------------------------------+
//| Check for delete long limit/stop order                           |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CheckDeleteOrderLong()
  {
   double price;
//--- check the possibility of deleting the long order
   if(m_expiration!=0 && TimeCurrent()>m_expiration)
     {
      m_expiration=0;
      return(DeleteOrderLong());
     }
   if(m_signal.CheckCloseLong(price))
      return(DeleteOrderLong());
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for delete short limit/stop order                          |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation processed, false otherwise.      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CheckDeleteOrderShort()
  {
   double price;
//--- check the possibility of deleting the short order
   if(m_expiration!=0 && TimeCurrent()>m_expiration)
     {
      m_expiration=0;
      return(DeleteOrderShort());
     }
   if(m_signal.CheckCloseShort(price))
      return(DeleteOrderShort());
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Delete all limit/stop orders                                     |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation successful, false otherwise.     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::DeleteOrders()
  {
   bool result=false;
   int  total=OrdersTotal();
//---
   for(int i=total-1;i>=0;i--)
     {
      if(m_order.Select(OrderGetTicket(i)))
        {
         if(m_order.Symbol()!=m_symbol.Name()) continue;
         result|=DeleteOrder();
        }
     }
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Delete limit/stop order                                          |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation successful, false otherwise.     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::DeleteOrder()
  {
   return(m_trade.OrderDelete(m_order.Ticket()));
  }
//+------------------------------------------------------------------+
//| Delete long limit/stop order                                     |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation successful, false otherwise.     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::DeleteOrderLong()
  {
   return(m_trade.OrderDelete(m_order.Ticket()));
  }
//+------------------------------------------------------------------+
//| Delete short limit/stop order                                    |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if trade operation successful, false otherwise.     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::DeleteOrderShort()
  {
   return(m_trade.OrderDelete(m_order.Ticket()));
  }
//+------------------------------------------------------------------+
//| Method of getting the lot for open long position.                |
//| INPUT:  price - price,                                           |
//|         sl    - stop loss.                                       |
//| OUTPUT: lot for open.                                            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double CExpert::LotOpenLong(double price,double sl)
  {
   return(m_money.CheckOpenLong(price,sl));
  }
//+------------------------------------------------------------------+
//| Method of getting the lot for open short position.               |
//| INPUT:  price - price,                                           |
//|         sl    - stop loss.                                       |
//| OUTPUT: lot for open.                                            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double CExpert::LotOpenShort(double price,double sl)
  {
   return(m_money.CheckOpenShort(price,sl));
  }
//+------------------------------------------------------------------+
//| Method of getting the lot for reverse position.                  |
//| INPUT:  sl - stop loss.                                          |
//| OUTPUT: lot for open.                                            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double CExpert::LotReverse(double sl)
  {
   return(m_money.CheckReverse(GetPointer(m_position),sl));
  }
//+------------------------------------------------------------------+
//| Method of setting the start date for the history.                |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CExpert::PrepareHistoryDate()
  {
   MqlDateTime dts;
//---
   TimeCurrent(dts);
//--- set up a date at the beginning of the month (but not less than one day)
   if(dts.day==1)
     {
      if(dts.mon==1)
        {
         dts.mon=12;
         dts.year--;
        }
      else
         dts.mon--;
     }
   dts.day =1;
   dts.hour=0;
   dts.min =0;
   dts.sec =0;
//---
   m_beg_date=StructToTime(dts);
  }
//+------------------------------------------------------------------+
//| Method of establishing the checkpoint history.                   |
//| INPUT:  from_check_trade-flag to avoid recursive.                |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CExpert::HistoryPoint(bool from_check_trade)
  {
//--- check possible recursion
   if(!from_check_trade) CheckTradeState();
//--- select history point
   if(HistorySelect(m_beg_date,TimeCurrent()))
     {
      m_hist_ord_tot=HistoryOrdersTotal();
      m_deal_tot    =HistoryDealsTotal();
     }
   else
     {
      m_hist_ord_tot=0;
      m_deal_tot    =0;
     }
   m_ord_tot=OrdersTotal();
   m_pos_tot=PositionsTotal();
  }
//+------------------------------------------------------------------+
//| Method of verification of trade events.                          |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if the event is handled, false otherwise.           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpert::CheckTradeState()
  {
   bool res=false;
//--- select current history point
   HistorySelect(m_beg_date,INT_MAX);
   int hist_ord_tot=HistoryOrdersTotal();
   int ord_tot     =OrdersTotal();
   int deal_tot    =HistoryDealsTotal();
   int pos_tot     =PositionsTotal();
//--- check for quantitative changes
   if(hist_ord_tot==m_hist_ord_tot && ord_tot==m_ord_tot && deal_tot==m_deal_tot && pos_tot==m_pos_tot)
     {
      //--- no quantitative changes
      if(IS_WAITING_POSITION_MODIFIED)
        {
         res=TradeEventPositionModified();
         NoWaitEvent(TRADE_EVENT_POSITION_MODIFY);
        }
      if(IS_WAITING_ORDER_MODIFIED)
        {
         res=TradeEventOrderModified();
         NoWaitEvent(TRADE_EVENT_ORDER_MODIFY);
        }
      return(true);
     }
//--- check added a pending order
   if(hist_ord_tot==m_hist_ord_tot && ord_tot==m_ord_tot+1 && deal_tot==m_deal_tot && pos_tot==m_pos_tot)
     {
      //--- was added a pending order
      res=TradeEventOrderPlaced();
      //--- establishment of the checkpoint history of the trade
      HistoryPoint(true);
      return(true);
     }
//--- check make a deal "with the market"
   if(hist_ord_tot==m_hist_ord_tot+1 && ord_tot==m_ord_tot)
     {
      //--- was an attempt to make a deal "with the market"
      if(deal_tot==m_deal_tot+1)
        {
         //--- operation successfull
         //--- check position update/subtracting
         if(pos_tot==m_pos_tot)
           {
            //--- position update/subtracting
            if(IS_WAITING_POSITION_VOLUME_CHANGED)
              {
               res=TradeEventPositionVolumeChanged();
               NoWaitEvent(TRADE_EVENT_POSITION_VOLUME_CHANGE);
              }
            //--- establishment of the checkpoint history of the trade
            HistoryPoint(true);
            return(res);
           }
         //--- check position open
         if(pos_tot==m_pos_tot+1)
           {
            //--- position open
            if(IS_WAITING_POSITION_OPENED)
              {
               res=TradeEventPositionOpened();
               NoWaitEvent(TRADE_EVENT_POSITION_OPEN);
              }
            //--- establishment of the checkpoint history of the trade
            HistoryPoint(true);
            //---
            return(res);
           }
         //--- check position is closed (including the stoploss/takeprofit)
         if(pos_tot==m_pos_tot-1)
           {
            //--- position is closed (including the stoploss/takeprofit)
            if(IS_WAITING_POSITION_CLOSED)
              {
               res=TradeEventPositionClosed();
               NoWaitEvent(TRADE_EVENT_POSITION_CLOSE);
              }
            else
               res=TradeEventPositionStopTake();
            //--- establishment of the checkpoint history of the trade
            HistoryPoint(true);
            //---
            return(res);
           }
        }
      else
        {
         //--- operation failed
         //--- establishment of the checkpoint history of the trade
         HistoryPoint(true);
         return(false);
        }
     }
//--- check delete pending order
   if(hist_ord_tot==m_hist_ord_tot+1 && ord_tot==m_ord_tot-1 && deal_tot==m_deal_tot && pos_tot==m_pos_tot)
     {
      //--- delete pending order
      res=TradeEventOrderDeleted();
      //--- establishment of the checkpoint history of the trade
      HistoryPoint(true);
      //---
      return(res);
     }
//--- check triggering of a pending order
   if(hist_ord_tot==m_hist_ord_tot+1 && ord_tot==m_ord_tot-1)
     {
      //--- triggering of a pending order
      if(deal_tot==m_deal_tot+1)
        {
         //--- operation successfull
         //--- check position update/subtracting
         if(pos_tot==m_pos_tot)
           {
            //--- position update/subtracting
            res=TradeEventOrderTriggered();
            //--- establishment of the checkpoint history of the trade
            HistoryPoint(true);
            //---
            return(res);
           }
         //--- check position open
         if(pos_tot==m_pos_tot+1)
           {
            //--- position open
            res=TradeEventOrderTriggered();
            //--- establishment of the checkpoint history of the trade
            HistoryPoint(true);
            //---
            return(res);
           }
         //--- check position is closed
         if(pos_tot==m_pos_tot-1)
           {
            //--- position is closed
            res=TradeEventOrderTriggered();
            //--- establishment of the checkpoint history of the trade
            HistoryPoint(true);
            //---
            return(res);
           }
        }
      else
        {
         //--- operation failed
         //--- establishment of the checkpoint history of the trade
         HistoryPoint(true);
         return(false);
        }
     }
//--- trade event non identifical
   res=TradeEventNotIdentified();
//--- establishment of the checkpoint history of the trade
   HistoryPoint(true);
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| Add timeframe for checked                                        |
//| INPUT:  period - timeframe for check.                            |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CExpert::TimeframeAdd(ENUM_TIMEFRAMES period)
  {
   switch(period)
     {
      case PERIOD_M1:  m_period_flags|=OBJ_PERIOD_M1;  break;
      case PERIOD_M2:  m_period_flags|=OBJ_PERIOD_M2;  break;
      case PERIOD_M3:  m_period_flags|=OBJ_PERIOD_M3;  break;
      case PERIOD_M4:  m_period_flags|=OBJ_PERIOD_M4;  break;
      case PERIOD_M5:  m_period_flags|=OBJ_PERIOD_M5;  break;
      case PERIOD_M6:  m_period_flags|=OBJ_PERIOD_M6;  break;
      case PERIOD_M10: m_period_flags|=OBJ_PERIOD_M10; break;
      case PERIOD_M12: m_period_flags|=OBJ_PERIOD_M12; break;
      case PERIOD_M15: m_period_flags|=OBJ_PERIOD_M15; break;
      case PERIOD_M20: m_period_flags|=OBJ_PERIOD_M20; break;
      case PERIOD_M30: m_period_flags|=OBJ_PERIOD_M30; break;
      case PERIOD_H1:  m_period_flags|=OBJ_PERIOD_H1;  break;
      case PERIOD_H2:  m_period_flags|=OBJ_PERIOD_H2;  break;
      case PERIOD_H3:  m_period_flags|=OBJ_PERIOD_H3;  break;
      case PERIOD_H4:  m_period_flags|=OBJ_PERIOD_H4;  break;
      case PERIOD_H6:  m_period_flags|=OBJ_PERIOD_H6;  break;
      case PERIOD_H8:  m_period_flags|=OBJ_PERIOD_H8;  break;
      case PERIOD_H12: m_period_flags|=OBJ_PERIOD_H12; break;
      case PERIOD_D1:  m_period_flags|=OBJ_PERIOD_D1;  break;
      case PERIOD_W1:  m_period_flags|=OBJ_PERIOD_W1;  break;
      case PERIOD_MN1: m_period_flags|=OBJ_PERIOD_MN1; break;
      default:         m_period_flags=WRONG_VALUE;     break;
     }
  }
//+------------------------------------------------------------------+
//| Forms timeframes flags                                           |
//| INPUT:  time - reference.                                        |
//| OUTPUT: timeframes flags.                                        |
//| REMARK: for simplicity, set the "new week" flag at the beginning |
//          of every new day                                         |
//+------------------------------------------------------------------+
int CExpert::TimeframesFlags(MqlDateTime &time)
  {
//--- set flags for all timeframes
   int   result=OBJ_ALL_PERIODS;
//--- if first check, then setting flags all timeframes
   if(m_last_tick_time.min==-1)       return(result);
//--- check change time
   if(time.min==m_last_tick_time.min &&
      time.hour==m_last_tick_time.hour &&
      time.day==m_last_tick_time.day &&
      time.mon==m_last_tick_time.mon) return(OBJ_NO_PERIODS);
//--- new month?
   if(time.mon!=m_last_tick_time.mon) return(result);
//--- reset the "new month" flag
   result^=OBJ_PERIOD_MN1;
//--- new day?
   if(time.day!=m_last_tick_time.day) return(result);
//--- reset the "new day" and "new week" flags
   result^=OBJ_PERIOD_D1+OBJ_PERIOD_W1;
//--- temporary variables to speed up working with structures
   int last,curr;
//--- new hour?
   curr=time.hour;
   last=m_last_tick_time.hour;
   if(curr!=last)
     {
      if(curr%2!=0  && curr-last<2)      result^=OBJ_PERIOD_H2;
      if(curr%3!=0  && curr-last<3)      result^=OBJ_PERIOD_H3;
      if(curr%4!=0  && curr-last<4)      result^=OBJ_PERIOD_H4;
      if(curr%6!=0  && curr-last<6)      result^=OBJ_PERIOD_H6;
      if(curr%8!=0  && curr-last<8)      result^=OBJ_PERIOD_H8;
      if(curr%12!=0 && curr-last<12)     result^=OBJ_PERIOD_H12;
      return(result);
     }
//--- reset all flags for hour timeframes
   result^=OBJ_PERIOD_H1+OBJ_PERIOD_H2+OBJ_PERIOD_H3+OBJ_PERIOD_H4+OBJ_PERIOD_H6+OBJ_PERIOD_H8+OBJ_PERIOD_H12;
//--- new minute?
   curr=time.min;
   last=m_last_tick_time.min;
   if(curr!=last)
     {
      if(curr%2!=0  && curr-last<2)       result^=OBJ_PERIOD_M2;
      if(curr%3!=0  && curr-last<3)       result^=OBJ_PERIOD_M3;
      if(curr%4!=0  && curr-last<4)       result^=OBJ_PERIOD_M4;
      if(curr%5!=0  && curr-last<5)       result^=OBJ_PERIOD_M5;
      if(curr%6!=0  && curr-last<6)       result^=OBJ_PERIOD_M6;
      if(curr%10!=0 && curr-last<10)      result^=OBJ_PERIOD_M10;
      if(curr%12!=0 && curr-last<12)      result^=OBJ_PERIOD_M12;
      if(curr%15!=0 && curr-last<15)      result^=OBJ_PERIOD_M15;
      if(curr%20!=0 && curr-last<20)      result^=OBJ_PERIOD_M20;
      if(curr%30!=0 && curr-last<30)      result^=OBJ_PERIOD_M30;
     }
//---
   return(result);
  }
//+------------------------------------------------------------------+
