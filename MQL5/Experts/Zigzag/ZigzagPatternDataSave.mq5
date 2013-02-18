//+------------------------------------------------------------------+
//|                                        ZigzagPatternDataSave.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Files\FileTxt.mqh>
#include <Utils.mqh>
//#include <ZigzagPatternValue.mqh>
#include <ZigzagPatternValueColor.mqh>

#define dataBufferCnt 50000

CZigzagPatternValue m_zigzagPatternValue;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
    //perid_toM5 = PeriodSeconds(PERIOD_M5) / PeriodSeconds(_Period);

    bool ret = m_zigzagPatternValue.Init();
    if (!ret)
        return -1;
        
    return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
    m_zigzagPatternValue.Deinit();
   
    SaveToDisk();
  }
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
    string p = m_zigzagPatternValue.GetZigzagPatternLatest();
    if (m_lastP == p)
        return;
    //Print(TimeCurrent(), ", ", p);
    
    MqlTick mqlTick;
    SymbolInfoTick(Symbol(), mqlTick);
        
    m_lastP = p;
    if (m_outputIdx < dataBufferCnt)
    {
        m_outputTime[m_outputIdx] = TimeCurrent();
        m_outputPattern[m_outputIdx] = p;
        m_outputPrice[m_outputIdx] = mqlTick.bid;
        m_outputIdx++;
    }
    else
    {
        SaveToDisk();
    }
  }
//+------------------------------------------------------------------+
string m_lastP;

void SaveToDisk()
{
    CFileTxt file;
        file.Open(_Symbol + "_" + GetPeriodName(_Period) + "_ZigzagPatterns.txt", FILE_READ | FILE_WRITE);
        file.Seek(0, SEEK_END);
        //string s = TimeToString(m_priceTime[0]) + "," + IntegerToString(p, 10, '0') + "," + DoubleToString(m_priceClose[0]) + "\r\n";
        //string s = TimeToString() + "\t" + p + "\t" + DoubleToString(m_priceClose[0]);
        //for(int i=0; i<ArraySize(m_zigzagValuesLatest); ++i)
        //{
        //    s += "\t" + DoubleToString(m_zigzagValuesLatest[i]) ;
        //}
        //s += "\r\n";
        for(int i=0; i<m_outputIdx; ++i)
        {
            string s = TimeToString(m_outputTime[i]) + "\t" + m_outputPattern[i] + "\t" + DoubleToString(m_outputPrice[i], 5) + "\r\n";
            file.WriteString(s);
        }
        
        file.Close();
        m_outputIdx = 0;
}

datetime m_outputTime[dataBufferCnt];
string m_outputPattern[dataBufferCnt];
double m_outputPrice[dataBufferCnt];
int m_outputIdx = 0;


