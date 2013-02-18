//+------------------------------------------------------------------+
//|                                             RandomClassifier.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "Classifier.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CRandomClassifier : public CClassifier
  {
private:
   double            m_counts[3];
   double            m_cost;
   bool              m_initRandom;
public:
                     CRandomClassifier(double cost);
                    ~CRandomClassifier();
   virtual void      buildClassifier(CInstances &instances);
   virtual double    classifyInstance(CInstance &instance);
   virtual string    ToString();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CRandomClassifier::CRandomClassifier(double cost)
  {
   m_cost=cost;
   m_initRandom=false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CRandomClassifier::~CRandomClassifier()
  {
  }
//+------------------------------------------------------------------+
string CRandomClassifier::ToString()
  {
   return DoubleToString(m_counts[2], 1) + "/" + DoubleToString(m_counts[1] + m_counts[2] + m_counts[0], 1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRandomClassifier::buildClassifier(CInstances &instances)
  {
   for(int i=0; i<ArraySize(m_counts); i++)
     {
      m_counts[i]=0;
     }
   double sumOfWeights=0;

   double c=m_cost;//-TestParameters.GetCost();

   CInstance *instance=(CInstance*)instances.GetFirstNode();
   while(instance!=NULL)
     {
      int v=(int)instance.classValue();
      if(v == 2)
        {
         m_counts[v]+=c;
         sumOfWeights+=c;
        }
      else
        {
         m_counts[v]+=1;
         sumOfWeights+=1;
        }
      instance=(CInstance*)instances.GetNextNode();
     }
    
   double start=0;
   for(int i=0; i<ArraySize(m_counts);++i)
     {
      m_counts[i]=m_counts[i]/sumOfWeights+start;
      start=m_counts[i];
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CRandomClassifier::classifyInstance(CInstance &instance)
  {
   if(!m_initRandom)
     {
      MathSrand((int)TimeCurrent());
      m_initRandom=true;
     }

   double  r=(double)MathRand()/32767.0;

   for(int i=0; i<ArraySize(m_counts);++i)
     {
      if(r<m_counts[i])
         return i==1 ? 0 : i;
     }
   return 0;
  }
//+------------------------------------------------------------------+
