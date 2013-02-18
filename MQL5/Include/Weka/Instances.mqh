//+------------------------------------------------------------------+
//|                                                    Instances.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "Instance.mqh"
#include <Arrays\List.mqh>
#include <Files\FileTxt.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CInstances : public CList
  {
private:

public:
                     CInstances();
                    ~CInstances();
                    int numInstances() { return Total(); }
                    CInstance* instance(int i) { return (CInstance *)GetNodeAtIndex(i); }
                    string ToString();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CInstances::CInstances()
  {
    FreeMode(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CInstances::~CInstances()
  {
  }
//+------------------------------------------------------------------+
string CInstances::ToString(void)
{
    string s;
    StringInit(s,2000,0);
    CInstance *i=(CInstance *)GetFirstNode();
    while(i!=NULL)
    {
        string s1 = i.ToString() + "\r\n";
        //StringAdd(s, s1);
        StringConcatenate(s, s, s1);
        i = GetNextNode();
    }
    CFileTxt file;
    file.Open("instance_tmp.txt", FILE_WRITE);
    file.WriteString(s);
    file.Close();
    return s;
}
