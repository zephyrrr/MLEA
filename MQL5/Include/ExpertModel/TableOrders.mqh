//+------------------------------------------------------------------+
//|                                                  TableOrders.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Arrays\List.mqh>
#include "TableOrder.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTableOrders : public CList
  {
private:

public:
                     CTableOrders();
                    ~CTableOrders();
   virtual CObject *CreateElement() { return new CTableOrder(); }
   virtual int Type() { return 0x11117779; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTableOrders::CTableOrders()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTableOrders::~CTableOrders()
  {
  }
//+------------------------------------------------------------------+
