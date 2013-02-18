//+------------------------------------------------------------------+
//|                                          CProbMoneyManagement.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "MoneyManagement.mqh"
#include <Utils\Utils.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CProbMoneyManagement : public CMoneyManagement
  {
private:
   double            m_counts[3];
   double            m_cost;
public:
                     CProbMoneyManagement(double cost);
                    ~CProbMoneyManagement();
   virtual void      Build(CInstances &instances);
   virtual double    GetVolume(CInstance &instance);
   virtual string    ToString();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CProbMoneyManagement::CProbMoneyManagement(double cost)
  {
   m_cost=cost;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CProbMoneyManagement::~CProbMoneyManagement()
  {

  }
//+------------------------------------------------------------------+

void CProbMoneyManagement::Build(CInstances &instances)
  {
   for(int i=0; i<ArraySize(m_counts); i++)
     {
      m_counts[i]=0;
     }
   //double sumOfWeights=0;

   double c=m_cost;//-TestParameters.GetCost();

   CInstance *instance=(CInstance*)instances.GetFirstNode();
   while(instance!=NULL)
     {
      int v=(int)instance.classValue();
      if(v == 2)
        {
         m_counts[v]+=c;
         //sumOfWeights+=c;
        }
      else
        {
         m_counts[v]++;
         //sumOfWeights+=1;
        }
      instance=(CInstance*)instances.GetNextNode();
     }
    //Info(DoubleToString(m_counts[2], 1),  "/", DoubleToString(m_counts[1]+m_counts[2]+m_counts[0], 1));
    //Info(ToString());
  }
//+------------------------------------------------------------------+

double CProbMoneyManagement::GetVolume(CInstance &instance)
  {
    double sum = m_counts[0]+m_counts[1]+m_counts[2];
    if (sum == 0)
        return 1;
   double v=m_counts[2]/sum;
   return NormalizeDouble(v, 2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CProbMoneyManagement::ToString()
  {
   string s = DoubleToString(m_counts[2],1)+"/"+DoubleToString(m_counts[0], 1) + "/" + DoubleToString(m_counts[1],1);
   return s;
  }
//+------------------------------------------------------------------+
