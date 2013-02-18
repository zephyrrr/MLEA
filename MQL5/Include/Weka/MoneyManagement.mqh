//+------------------------------------------------------------------+
//|                                              MoneyManagement.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "Instances.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMoneyManagement
  {
private:

public:
                     CMoneyManagement();
                    ~CMoneyManagement();
   virtual void Build(CInstances& instances) {};
   virtual double GetVolume(CInstance& instance) { return 0; };
   virtual string ToString() { return ""; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMoneyManagement::CMoneyManagement()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMoneyManagement::~CMoneyManagement()
  {
  }
//+------------------------------------------------------------------+
