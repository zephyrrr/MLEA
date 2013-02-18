//+------------------------------------------------------------------+
//|                                                     Instance.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Object.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CInstance : public CObject
  {
private:
    double m_attributeValue[];
    int m_size;
public:
                     CInstance(int numAttribute);
                     CInstance(double& d[]);
                    ~CInstance();
                    double value(int idx) { return m_attributeValue[idx]; }
                    void value(int idx, double d) { m_attributeValue[idx] = d; }
                    double classValue() { return m_attributeValue[m_size - 1]; }
                    void classValue(double c) { m_attributeValue[m_size - 1] = c; }
                    string ToString();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CInstance::CInstance(int numAttribute)
  {
    m_size = numAttribute;
    ArrayResize(m_attributeValue, m_size);
    
  }

CInstance::CInstance(double& d[])
{
    m_size = ArraySize(d);
    ArrayResize(m_attributeValue, m_size);
    for(int i=0; i<m_size; ++i)
    {
        m_attributeValue[i] = d[i];
    }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CInstance::~CInstance()
  {
  }
//+------------------------------------------------------------------+
string CInstance::ToString()
{
    string s = "";
    for(int i=0; i<m_size; ++i)
    {
        string s1 = DoubleToString(m_attributeValue[i], 4) + ",";
        StringAdd(s, s1);
    }
    return s;
}
