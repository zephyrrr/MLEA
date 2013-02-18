//+------------------------------------------------------------------+
//|                                           TpslClassifierInfo.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "DealsInfo.mqh"
#include "Classifier.mqh"
#include "MoneyManagement.mqh"
#include "ProbMoneyManagement.mqh"
#include "AllTrueClassifier.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTpslClassifierInfo
  {
private:
   string            m_Name;
   int               m_Tp;
   int               m_Sl;
   char              m_DealType;
   DealsInfo       *m_Deals;
   double            m_CurrentClassValue[];
   double            m_CurrentTestRet[];

   CClassifier      *m_Classifier;
   CMoneyManagement *m_MoneyManagement;
public:
                     CTpslClassifierInfo(string name,int tp,int sl,char dealType,int dealInfoLastMinutes);
                    ~CTpslClassifierInfo();

   string            Name() { return m_Name; };
   int               Tp() { return m_Tp; };
   int               Sl() { return m_Sl; };
   char              DealType() { return m_DealType; };
   DealsInfo        *Deals() { return m_Deals;}
   
   CClassifier     *Classifier() { return m_Classifier; }
   void Classifier(CClassifier *cls) { m_Classifier=cls; }
   
   CMoneyManagement *MoneyManagement() { return m_MoneyManagement; }
   void MoneyManagement(CMoneyManagement *mm) { m_MoneyManagement = mm; }
   //double[] CurrentClassValue();
   //void CurrentClassValue(double[] d);
   //double[] CurrentTestRet();
   //void CurrentTestRet(double[] d);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTpslClassifierInfo::CTpslClassifierInfo(string name,int tp,int sl,char dealType,int dealInfoLastMinutes)
  {
   m_Name=name;
   m_Tp = tp;
   m_Sl = sl;
   m_DealType=dealType;
   m_Deals=new DealsInfo(dealInfoLastMinutes);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTpslClassifierInfo::~CTpslClassifierInfo()
  {
   delete m_Deals;
   if(m_Classifier != NULL)
   {
    delete m_Classifier;
   }
   if(m_MoneyManagement != NULL)
   {
    delete m_MoneyManagement;
   }
  }

//                    double[] CTpslClassifierInfo::CurrentClassValue()
//                    { return m_CurrentClassValue; }
//                    
//                    void CTpslClassifierInfo::CurrentClassValue(double[] d)
//                    {
//                        m_CurrentClassValue = d;
//                    }
//                    double[] CTpslClassifierInfo::CurrentTestRet()
//                    {
//                        return m_CurrentTestRet;
//                    }
//                    void CTpslClassifierInfo::CurrentTestRet(double[] d)
//                    {
//                    return m_CurrentTestRet = d;
//                    }
