//+------------------------------------------------------------------+
//|                                                     SaveTick.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Files/FileBin.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
    SaveToDisk();
   
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
    MqlTick mqlTick;
    SymbolInfoTick(Symbol(), mqlTick);

    if (m_outputIdx < 10000)
    {
        m_outputTick[m_outputIdx] = mqlTick;
        m_outputIdx++;
    }
    else
    {
        SaveToDisk();
    }
  }
void SaveToDisk()
{
    CFileBin file;
    file.Open(_Symbol + "_Tick.dat", FILE_READ | FILE_WRITE);
    file.Seek(0, SEEK_END);

    for(int i=0; i<m_outputIdx; ++i)
    {
        file.WriteLong(m_outputTick[i].time);
        file.WriteDouble(m_outputTick[i].bid);
        file.WriteDouble(m_outputTick[i].ask);
    }
        
    file.Close();
    m_outputIdx = 0;
}
MqlTick m_outputTick[10000];
int m_outputIdx = 0;