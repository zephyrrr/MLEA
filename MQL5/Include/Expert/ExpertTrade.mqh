//+------------------------------------------------------------------+
//|                                                  ExpertTrade.mqh |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//|                                              Revision 2010.07.01 |
//+------------------------------------------------------------------+
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//| Class CExpertTrade.                                              |
//| Appointment: Class simple trade operations.                      |
//|              Derives from class CTrade.                          |
//+------------------------------------------------------------------+
class CExpertTrade : public CTrade
  {
protected:
   ENUM_ORDER_TYPE_TIME m_order_type_time;
   datetime          m_order_expiration;
   CSymbolInfo      *m_symbol;          // symbol object
   CAccountInfo      m_account;         // account object

public:
                     CExpertTrade();
   //--- methods for easy trade
   bool              SetSymbol(CSymbolInfo* symbol);
   bool              SetOrderTypeTime(ENUM_ORDER_TYPE_TIME order_type_time);
   bool              SetOrderExpiration(datetime order_expiration);
   bool              Buy(double volume,double price,double sl,double tp,const string comment="");
   bool              Sell(double volume,double price,double sl,double tp,const string comment="");
  };
//+------------------------------------------------------------------+
//| Constructor CExpertTrade.                                        |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CExpertTrade::CExpertTrade()
  {
//--- initialize protected data
   m_symbol          =NULL;
   m_order_type_time =ORDER_TIME_GTC;
   m_order_expiration=0;
  }
//+------------------------------------------------------------------+
//| Setting working symbol for easy trade operations.                |
//| INPUT:  symbol_name -symbol for easy trade operations.           |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpertTrade::SetSymbol(CSymbolInfo* symbol)
  {
   if(symbol==NULL) return(false);
//---
   m_symbol=symbol;
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Setting order expiration type for easy trade operations.         |
//| INPUT:  order_type_time -order expiration type.                  |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: working symbol must be set previously by SetSymbol().    |
//+------------------------------------------------------------------+
bool CExpertTrade::SetOrderTypeTime(ENUM_ORDER_TYPE_TIME order_type_time)
  {
   if(m_symbol==NULL) return(false);
//---
   if((m_symbol.TradeTimeFlags()&order_type_time)==0)
     {
      m_order_type_time =ORDER_TIME_GTC;
      m_order_expiration=0;
      return(false);
     }
//---
   m_order_type_time=order_type_time;
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Setting order expiration time for easy trade operations.         |
//| INPUT:  order_expiration -order expiration time.                 |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: working symbol must be set previously by SetSymbol().    |
//+------------------------------------------------------------------+
bool CExpertTrade::SetOrderExpiration(datetime order_expiration)
  {
   if(m_symbol==NULL) return(false);
//--- check expiration
   if(order_expiration>=TimeCurrent()+60)
     {
      if(!SetOrderTypeTime(ORDER_TIME_SPECIFIED)) return(false);
      m_order_expiration=order_expiration;
     }
   else
     {
      m_order_type_time=ORDER_TIME_GTC;
      m_order_expiration=0;
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Easy LONG trade operation.                                       |
//| INPUT:  volume     -volume of trade operation,                   |
//|         price      -price for trade operation,                   |
//|         stop       -price of stop loss,                          |
//|         take       -price of take profit,                        |
//|         comment    -comment of trade operation.                  |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: working symbol must be set previously by SetSymbol().    |
//+------------------------------------------------------------------+
bool CExpertTrade::Buy(double volume,double price,double sl,double tp,const string comment="")
  {
   double ask,stops_level;
//--- checking
   if(m_symbol==NULL)           return(false);
   string symbol=m_symbol.Name();
   if(symbol=="")               return(false);
//---
   ask=m_symbol.Ask();
   stops_level=m_symbol.StopsLevel()*m_symbol.Point();
   if(price!=0.0)
     {
      if(price>ask+stops_level)
        {
         //--- send "BUY_STOP" order
         return(OrderOpen(symbol,ORDER_TYPE_BUY_STOP,volume,0.0,price,sl,tp,
                       m_order_type_time,m_order_expiration,comment));
        }
      if(price<ask-stops_level)
        {
         //--- send "BUY_LIMIT" order
         return(OrderOpen(symbol,ORDER_TYPE_BUY_LIMIT,volume,0.0,price,sl,tp,
                       m_order_type_time,m_order_expiration,comment));
        }
     }
//---
   return(PositionOpen(symbol,ORDER_TYPE_BUY,volume,ask,sl,tp,comment));
  }
//+------------------------------------------------------------------+
//| Easy SHORT trade operation.                                      |
//| INPUT:  volume     -volume of trade operation,                   |
//|         price      -price for trade operation,                   |
//|         stop       -price of stop loss,                          |
//|         take       -price of take profit,                        |
//|         comment    -comment of trade operation.                  |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: working symbol must be set previously by SetSymbol().    |
//+------------------------------------------------------------------+
bool CExpertTrade::Sell(double volume,double price,double sl,double tp,const string comment="")
  {
   double bid,stops_level;
//--- checking
   if(m_symbol==NULL)           return(false);
   string symbol=m_symbol.Name();
   if(symbol=="")               return(false);
//---
   bid=m_symbol.Bid();
   stops_level=m_symbol.StopsLevel()*m_symbol.Point();
   if(price!=0.0)
     {
      if(price>bid+stops_level)
        {
         //--- send "SELL_LIMIT" order
         return(OrderOpen(symbol,ORDER_TYPE_SELL_LIMIT,volume,0.0,price,sl,tp,
                       m_order_type_time,m_order_expiration,comment));
        }
      if(price<bid-stops_level)
        {
         //--- send "SELL_STOP" order
         return(OrderOpen(symbol,ORDER_TYPE_SELL_STOP,volume,0.0,price,sl,tp,
                       m_order_type_time,m_order_expiration,comment));
        }
     }
//---
   return(PositionOpen(symbol,ORDER_TYPE_SELL,volume,bid,sl,tp,comment));
  }
//+------------------------------------------------------------------+
