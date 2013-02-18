//+------------------------------------------------------------------+
//|                                                   Classifier.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "Instances.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CClassifier
  {
private:

public:
                     CClassifier();
                    ~CClassifier();
                    virtual void buildClassifier(CInstances& instances) {};
                    virtual double classifyInstance(CInstance& instance) { return 1; }
                    virtual string ToString() { return ""; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CClassifier::CClassifier()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CClassifier::~CClassifier()
  {
  }
//+------------------------------------------------------------------+
