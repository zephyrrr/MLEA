//+------------------------------------------------------------------+
//|                                            AllTrueClassifier.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "Classifier.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CAllTrueClassifier : public CClassifier
  {
private:

public:
                     CAllTrueClassifier();
                    ~CAllTrueClassifier();
   virtual void      buildClassifier(CInstances &instances);
   virtual double    classifyInstance(CInstance &instance);
   virtual string    ToString();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAllTrueClassifier::CAllTrueClassifier()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAllTrueClassifier::~CAllTrueClassifier()
  {
  }
//+------------------------------------------------------------------+
string CAllTrueClassifier::ToString()
  {
   return "1";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAllTrueClassifier::buildClassifier(CInstances &instances)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CAllTrueClassifier::classifyInstance(CInstance &instance)
  {
   return 2;
  }
//+------------------------------------------------------------------+
