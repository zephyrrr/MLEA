//+------------------------------------------------------------------+
//|                                           SimulationResultDb.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "Win32File.mqh"
#include <Utils\Utils.mqh>

#define BATCH_DEAL_CNT_DB 2
#define BATCH_TP_CNT_DB 10
#define BATCH_SL_CNT_DB 10
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHpDb
  {
private:
   string            m_baseDir;
   int  m_arrayCnt;
   datetime          m_times[];
   char             m_hp[][BATCH_DEAL_CNT_DB][BATCH_TP_CNT_DB][BATCH_SL_CNT_DB];
   void              Load();
public:
                     CHpDb();
                    ~CHpDb();
   int               GetHp(datetime time,int deal, int tp,int sl);
   bool              PutHp(datetime& time[],int &hp[]);
   void              Save();
   //uint              Read(string simulateResultFileName,int &r[]);
   //uint              Write(string simulateResultFileName,int &r[]);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHpDb::CHpDb()
  {
   m_baseDir="E:\\Forex\\mtData";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHpDb::~CHpDb()
  {
  }
//+------------------------------------------------------------------+

int CHpDb::GetHp(datetime time,int deal, int tp,int sl)
  {
   int n=ArrayBsearch(m_times,time);
   if (n < 0 || n >= ArraySize(m_times) || m_times[n] != time)
    return -1;
   return m_hp[n][deal][tp][sl];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHpDb::PutHp(datetime& time[],int &hp[])
  {
    if (ArraySize(hp) != ArraySize(time) * BATCH_DEAL_CNT_DB * BATCH_TP_CNT_DB * BATCH_SL_CNT_DB)
        return false;
    
    int len = ArraySize(time);
    bool existInArray[];
    ArrayResize(existInArray, len);
    int newCnt = 0;
    for(int t=0; t<len; ++t)
    {
        int n = ArrayBsearch(m_times, time[t]);
        if (n >= 0 && n < len && m_times[n] == time[t])
        {
            newCnt++;
            existInArray[n] = true;
        }
        else
        {
            existInArray[n] = false;
        }
    }
    if (m_arrayCnt + newCnt >= ArraySize(m_times))
    {
        ArrayResize(m_times, m_arrayCnt + newCnt, 2 * newCnt);
        ArrayResize(m_hp, m_arrayCnt + newCnt, 2 * newCnt);
    }

    int n = 0;
    int m = 0;
    for(int k=0; k<BATCH_DEAL_CNT_DB; ++k)
        for(int i=0; i<BATCH_TP_CNT_DB; ++i)
            for(int j=0; j<BATCH_SL_CNT_DB; ++j)
                for(int t=0; t<ArraySize(time); ++t)
                {
                    if (!existInArray[t])
                    {
                        if (k == 0 && i == 0 && j == 0)
                            m_times[m_arrayCnt + m] = time[t];
                        m_hp[m_arrayCnt + m][k][i][j] = (char)hp[n];
                        m++;
                    }
                    n++;
                }
            
    m_arrayCnt +=  newCnt;
    return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHpDb::Load()
  {
    CWin32File file;
    bool ret = file.OpenR(m_baseDir + "\\time.dat");
    if (!ret)
    {
        Error("Error in open date file(time)");
        return;
    }
    char buffer[];
    ret = file.Read(buffer);
    if (!ret)
    {
        Error("Error in read date file(time)");
        return;
    }
    m_arrayCnt = ArraySize(buffer) / 8;
    ArrayResize(m_times, m_arrayCnt, 100);
    for(int i=0; i<m_arrayCnt; ++i)
    {
        m_times[i] = 0;
        for(int j=0; j<8; ++j)
        {
            m_times[i] = buffer[8*i + j] << j;
        }
    }
    file.Close();
    
    ArrayResize(m_hp, ArraySize(m_times));
    for(int k=0; k<BATCH_DEAL_CNT_DB; ++k)
        for(int i=0; i<BATCH_TP_CNT_DB; ++i)
            for(int j=0; j<BATCH_SL_CNT_DB; ++j)
            {
                string hpName = IntegerToString(k) + ", " + IntegerToString(i) + ", " + IntegerToString(j);
                ret = file.OpenR(m_baseDir + "\\" + hpName + ".dat");
                if (!ret)
                {
                    Error("Error in open date file(" + hpName + ")");
                    continue;
                }
                ret = file.Read(buffer);
                if (!ret)
                {
                    Error("Error in read date file(" + hpName + ")");
                    continue;
                }
                file.Close();
                for(int n=0; n<m_arrayCnt; ++n)
                {
                    m_hp[n][k][i][j] = buffer[n];
                }
            }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHpDb::Save()
  {
    CWin32File file;
    for(int k=0; k<BATCH_DEAL_CNT_DB; ++k)
        for(int i=0; i<BATCH_TP_CNT_DB; ++i)
            for(int j=0; j<BATCH_SL_CNT_DB; ++j)
            {
                string hpName = IntegerToString(k) + ", " + IntegerToString(i) + ", " + IntegerToString(j);
                bool ret = file.OpenW(m_baseDir + "\\" + hpName + ".dat");
                if (!ret)
                {
                    Error("Error in open write date file(" + hpName + ")");
                    continue;
                }
                char buffer[];
                ArrayResize(buffer, m_arrayCnt);
                for(int n=0; n<m_arrayCnt; ++n)
                {
                    buffer[n] = m_hp[n][k][i][j];
                }
                ret = file.Write(buffer);
                if (!ret)
                {
                    Error("Error in write date file(" + hpName + ")");
                    continue;
                }
                file.Close();
            }
  }
//uint CHpDb::Read(string simulateResultFileName,int &r[])
//  {
//   int handle=_lopen(m_baseDir+"\\"+simulateResultFileName,OF_READ);
//   if(handle<0)
//     {
//      return -1;
//     }
//   int result=_llseek(handle,0,0);
//   if(result<0)
//     {
//      return -1;
//     }
//
//   int length=ArraySize(r);
//   ArrayResize(m_buffer,length);
//
//   result=_lread(handle,m_buffer,length);
//   if(result!=ArraySize(r))
//     {
//      return -1;
//     }
//   for(int i=0; i<result;++i)
//     {
//      r[i]=m_buffer[i];
//     }
//   Info("Read simulation result from file, n = "+IntegerToString(result));
//   _lclose(handle);
//   return result;
//  }
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//uint CHpDb::Write(string simulateResultFileName,int &r[])
//  {
//   string path=m_baseDir+"\\"+simulateResultFileName;
//   int handle=_lopen(path,OF_WRITE);
//   int result;
//   if(handle<0)
//     {
//      handle=_lcreat(path,0);
//      if(handle<0)
//        {
//         return -1;
//        }
//      result=_lclose(handle);
//     }
//   handle=_lopen(path,OF_WRITE);
//   if(handle<0)
//     {
//      return -1;
//     }
//   result=_llseek(handle,0,0);
//   if(result<0)
//     {
//      return -1;
//     }
//
//   int length=ArraySize(r);
//   ArrayResize(m_buffer,length);
//   for(int i=0; i<length;++i)
//     {
//      m_buffer[i]=(uchar)r[i];
//     }
//
//   result=_lwrite(handle,m_buffer,length);
//   if(result!=length)
//      return -1;
//   result=_lclose(handle);
//   return length;
//  }
////+------------------------------------------------------------------+
