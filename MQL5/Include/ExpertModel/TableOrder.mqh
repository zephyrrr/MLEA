//+------------------------------------------------------------------+
//|                                                      torders.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Arrays\List.mqh>
#include <Utils\Utils.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTableOrder : public CObject
  {
private:
   string            m_symbol;         // order symbol
   ulong             m_magic;          // magic number of the EA
   ulong             m_ticket;         // base order ticket
   ulong             m_ticket_sl;      // stop loss price of base order
   ulong             m_ticket_tp;      // take profit price of base order
   ENUM_ORDER_TYPE   m_type;           // order type
   datetime          m_time_setup;     // order setup time
   double            m_price;          // order price
   double            m_sl;             // stop loss price
   double            m_tp;             // take profit price
   double            m_volume_initial; // order volume
public:
                     CTableOrder();
                     ~CTableOrder();
   bool              Set(COrderInfo &order_info,double stop_loss,double take_profit);
   bool              Set(CHistoryOrderInfo &history_order_info,double stop_loss,double take_profit);
   bool              Set(ulong Ticket,double stop_loss,double take_profit);

   ulong             Magic(){return(m_magic);}
   ulong             Ticket(){return(m_ticket);}
   void              Ticket(ulong ticket){m_ticket=ticket;}
   ulong             TicketSL(){return(m_ticket_sl);}
   ulong             TicketTP(){return(m_ticket_tp);}
   void              TicketSL(ulong ticket){m_ticket_sl=ticket;}
   void              TicketTP(ulong ticket){m_ticket_tp=ticket;}
   ENUM_ORDER_TYPE   OrderType(void){return(m_type);}
   void              OrderType(ENUM_ORDER_TYPE type){m_type=type;}
   datetime          TimeSetup(void){return(m_time_setup);}
   double            Price(){return(m_price);}
   double            StopLoss(void){return(m_sl);}
   void              StopLoss(double new_sl){m_sl=new_sl;}
   double            TakeProfit(void){return(m_tp);}
   void              TakeProfit(double new_tp){m_tp=new_tp;}
   double            VolumeInitial(){return(m_volume_initial);}

   double            Profit(CSymbolInfo *symbol);
   virtual bool      Save(int file_handle);
   virtual bool      Load(int file_handle);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTableOrder::CTableOrder(void)
  {
   m_magic=0;
   m_ticket=0;
   m_type=0;
   m_time_setup=0;
   m_price=0.0;
   m_volume_initial=0.0;
  }
  CTableOrder::~CTableOrder(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTableOrder::Set(CHistoryOrderInfo &history_order_info,double stop_loss,double take_profit)
  {
   HistoryOrderSelect(history_order_info.Ticket());
   m_magic=history_order_info.Magic();
   m_ticket=history_order_info.Ticket();
   m_type=history_order_info.OrderType();
   m_time_setup=history_order_info.TimeSetup();
   m_volume_initial=history_order_info.VolumeInitial();
   m_price=history_order_info.PriceOpen();
   m_sl=stop_loss;
   m_tp=take_profit;
   m_symbol=history_order_info.Symbol();
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTableOrder::Set(COrderInfo &order_info,double stop_loss,double take_profit)
  {
   OrderSelect(order_info.Ticket());
   m_magic=order_info.Magic();
   m_ticket=order_info.Ticket();
   m_type=order_info.OrderType();
   m_time_setup=order_info.TimeSetup();
   m_volume_initial=order_info.VolumeInitial();
   m_price=order_info.PriceOpen();
   m_sl=stop_loss;
   m_tp=take_profit;
   m_symbol=order_info.Symbol();
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTableOrder::Set(ulong ticket,double stop_loss,double take_profit)
  {
   if(HistoryOrderSelect(ticket))
     {
      CHistoryOrderInfo history_order_info;
      history_order_info.Ticket(ticket);
      Set(history_order_info,stop_loss,take_profit);
      return(true);
     }
   if(OrderSelect(ticket))
     {
      COrderInfo        order_info;
      order_info.Select(ticket);
      Set(order_info,stop_loss,take_profit);
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+

bool CTableOrder::Save(int file_handle)
  {
   if(file_handle<0) return(false);

//--- writing start marker - 0xFFFFFFFFFFFFFFFF
   if(FileWriteLong(file_handle,-1)!=sizeof(long)) return(false);

   if(FileWriteInteger(file_handle,StringLen(m_symbol),INT_VALUE)!=INT_VALUE) return(false);
   if(FileWriteString(file_handle,m_symbol)!=StringLen(m_symbol)) return(false);
   if(FileWriteLong(file_handle,m_magic)!=sizeof(long)) return(false);
   if(FileWriteLong(file_handle,m_ticket)!=sizeof(long)) return(false);
   if(FileWriteLong(file_handle, m_ticket_tp) != sizeof(long)) return(false);
   if(FileWriteLong(file_handle, m_ticket_sl) != sizeof(long)) return(false);
   if(FileWriteInteger(file_handle,m_type,INT_VALUE)!=INT_VALUE) return(false);
   if(FileWriteLong(file_handle,m_time_setup) != sizeof(long)) return(false);
   if(FileWriteDouble(file_handle, m_price) != sizeof(double)) return(false);
   if(FileWriteDouble(file_handle, m_sl) != sizeof(double)) return(false);
   if(FileWriteDouble(file_handle, m_tp) != sizeof(double)) return(false);
   if(FileWriteDouble(file_handle,m_volume_initial)!=sizeof(double)) return(false);

   Debug("Save TableOrder with ticker = "+IntegerToString(m_ticket));
   return true;
  }
//+------------------------------------------------------------------+
//| Reading list from file.                                          |
//| INPUT:  file_handle - handle of file previously opened           |
//|         for reading file.                                        |
//| OUTPUT: true if OK, else false.                                  |
//| REMARK: m_curr_node unchanged.                                   |
//+------------------------------------------------------------------+
bool CTableOrder::Load(int file_handle)
  {
   if(file_handle<0) return(false);

//--- reading and checking begin marker - 0xFFFFFFFFFFFFFFFF
   if(FileReadLong(file_handle)!=-1) return(false);

   int symbolLen=FileReadInteger(file_handle,INT_VALUE);
   m_symbol= FileReadString(file_handle,symbolLen);
   m_magic = FileReadLong(file_handle);
   m_ticket= FileReadLong(file_handle);
   m_ticket_tp = FileReadLong(file_handle);
   m_ticket_sl = FileReadLong(file_handle);
   m_type=(ENUM_ORDER_TYPE)FileReadInteger(file_handle,INT_VALUE);
   m_time_setup=(datetime)FileReadLong(file_handle);
   m_price=FileReadDouble(file_handle);
   m_sl = FileReadDouble(file_handle);
   m_tp = FileReadDouble(file_handle);
   m_volume_initial=FileReadDouble(file_handle);

   Debug("Load TableOrder with ticker = "+IntegerToString(m_ticket));
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CTableOrder::Profit(CSymbolInfo *symbol)
  {
   if(m_type==ORDER_TYPE_BUY)
      return symbol.Bid()-m_price;
   else if(m_type==ORDER_TYPE_SELL)
      return m_price-symbol.Ask();
   else
      return 0;
  }
//+------------------------------------------------------------------+
