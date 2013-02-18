//+------------------------------------------------------------------+
//|                                                     SaveTick.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Files/FileBin.mqh>
#include <Indicators\Trend.mqh>
#include <Indicators\Oscilators.mqh>
#include <Indicators\TimeSeries.mqh>

CiClose m_iClose;
CiMA m_iMa;
CiATR m_iATR;
int lastMin = 0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
    bool ret = true;
    
    ret &= m_iClose.Create(Symbol(), PERIOD_M5);
    ret &= m_iMa.Create(Symbol(), PERIOD_H1, 1, 0, MODE_EMA, PRICE_CLOSE);
    ret &= m_iATR.Create(Symbol(), PERIOD_H1, 19);
    
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
    
    MqlDateTime dt;
    TimeToStruct(mqlTick.time, dt);
    if (dt.min != lastMin)
    {
        //Print("diff time");
        
        lastMin = dt.min;
        
        m_iMa.Refresh(-1);
        m_iATR.Refresh(-1);
        if (m_outputIdx < 10000)
        {
            m_outputTick[m_outputIdx][0] = mqlTick.time / 60 * 60;
            m_outputTick[m_outputIdx][1] = m_iMa.Main(0);
            m_outputTick[m_outputIdx][2] = m_iATR.Main(0);
            
            m_outputIdx++;
        }
        else
        {
            SaveToDisk();
        }
    }
    else
    {
        //Print("same time");
    }
  }
void SaveToDisk()
{
    Print("save");
    CFileBin file;
    file.Open(Symbol() + "_Indicator.dat", FILE_READ | FILE_WRITE);
    file.Seek(0, SEEK_END);

    for(int i=0; i<m_outputIdx; ++i)
    {
        file.WriteLong((long)m_outputTick[i][0]);
        file.WriteDouble(m_outputTick[i][1]);
        file.WriteDouble(m_outputTick[i][2]);
    }
   
    file.Close();
    m_outputIdx = 0;
}
double m_outputTick[10000][3];
int m_outputIdx = 0;