//+------------------------------------------------------------------+
//|                                                        Utils.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#include "ErrorDescription.mqh"
#include "Logger.mqh"
#include <Trade\PositionInfo.mqh>

#define DEBUG_CATELOGY "Debug"
#define INFO_CATELOGY "Info"
#define NOTICE_CATELOGY "Notice"
#define WARN_CATELOGY "Warn"
#define ERROR_CATELOGY "Error"

#define IN_TEST_MODE true

CLogger logger;

bool EnableDebugLog = false;
bool EnableInfoLog = true;
bool EnableNoticeLog = true;
bool EnableWarnLog = true;
bool EnableErrorLog = true;

void Debug(string s) { if (EnableDebugLog) logger.Write(s, DEBUG_CATELOGY); }
void Debug(string s1, string s2) { if (EnableDebugLog) logger.Write(s1 + s2, DEBUG_CATELOGY); }
void Debug(string s1, string s2, string s3) { if (EnableDebugLog) logger.Write(s1 + s2 + s3, DEBUG_CATELOGY); }
void Debug(string s1, string s2, string s3, string s4) { if (EnableDebugLog) logger.Write(s1 + s2 + s3 + s4, DEBUG_CATELOGY); }
void Debug(string s1, string s2, string s3, string s4, string s5) { if (EnableDebugLog) logger.Write(s1 + s2 + s3 + s4 + s5, DEBUG_CATELOGY); }

void Info(string s) { if (EnableInfoLog) logger.Write(s, INFO_CATELOGY); }
void Info(string s1, string s2) { if (EnableInfoLog) logger.Write(s1 + s2, INFO_CATELOGY); }
void Info(string s1, string s2, string s3) { if (EnableInfoLog) logger.Write(s1 + s2 + s3, INFO_CATELOGY); }
void Info(string s1, string s2, string s3, string s4) { if (EnableInfoLog) logger.Write(s1 + s2 + s3 + s4, INFO_CATELOGY); }
void Info(string s1, string s2, string s3, string s4, string s5) { if (EnableInfoLog) logger.Write(s1 + s2 + s3 + s4 + s5, INFO_CATELOGY); }

void Notice(string s) { if (EnableNoticeLog) logger.Write(s, NOTICE_CATELOGY); }
void Notice(string s1, string s2) { if (EnableNoticeLog) logger.Write(s1 + s2, NOTICE_CATELOGY); }
void Notice(string s1, string s2, string s3) { if (EnableNoticeLog) logger.Write(s1 + s2 + s3, NOTICE_CATELOGY); }
void Notice(string s1, string s2, string s3, string s4) { if (EnableNoticeLog) logger.Write(s1 + s2 + s3 + s4, NOTICE_CATELOGY); }
void Notice(string s1, string s2, string s3, string s4, string s5) { if (EnableNoticeLog) logger.Write(s1 + s2 + s3 + s4 + s5, NOTICE_CATELOGY); }

void Warn(string s) { if (EnableWarnLog) logger.Write(s, WARN_CATELOGY); }
void Warn(string s1, string s2) { if (EnableWarnLog) logger.Write(s1 + s2, WARN_CATELOGY); }
void Warn(string s1, string s2, string s3) { if (EnableWarnLog) logger.Write(s1 + s2 + s3, WARN_CATELOGY); }
void Warn(string s1, string s2, string s3, string s4) { if (EnableWarnLog) logger.Write(s1 + s2 + s3 + s4, WARN_CATELOGY); }
void Warn(string s1, string s2, string s3, string s4, string s5) { if (EnableWarnLog) logger.Write(s1 + s2 + s3 + s4 + s5, WARN_CATELOGY); }

void Error(string s) { if (EnableErrorLog) { logger.Write(s, ERROR_CATELOGY); Print(s); } }
void Error(string s1, string s2) { if (EnableErrorLog) { logger.Write(s1 + s2, ERROR_CATELOGY); Print(s1, s2); }}
void Error(string s1, string s2, string s3) { if (EnableErrorLog) { logger.Write(s1 + s2 + s3, ERROR_CATELOGY); Print(s1, s2, s3);}}
void Error(string s1, string s2, string s3, string s4) { if (EnableErrorLog) { logger.Write(s1 + s2 + s3 + s4, ERROR_CATELOGY); Print(s1, s2, s3, s4);}}
void Error(string s1, string s2, string s3, string s4, string s5) { if (EnableErrorLog) { logger.Write(s1 + s2 + s3 + s4 + s5, ERROR_CATELOGY); Print(s1, s2, s3, s4, s5);}}

void InfoCurrentError()
{
    if (EnableInfoLog)
    {
        Debug(ErrorDescription(GetLastError()));
    }
    ResetLastError();
}

void DebugCurrentError()
{
    if (EnableDebugLog)
    {
        Info(ErrorDescription(GetLastError()));
    }
    ResetLastError();
}
void ErrorCurrentError()
{
    if (EnableErrorLog)
    {
        Error(ErrorDescription(GetLastError()));
    }
    ResetLastError();
}

void TimeInfo(string s)
{
    datetime infoTimeStart = D'2010.03.26 00:30';
    if (TimeCurrent() >= infoTimeStart && TimeCurrent() <= infoTimeStart + 60)
    {
        Debug(s);
    }
}

string SYMBOLS[] = {"EURUSD", "GBPUSD", "AUDUSD", "USDJPY", "USDCHF", "USDCAD" };
double GetPositionVolumn(string symbol)
{
    CPositionInfo position;
    if (position.Select(symbol))
    {
        return position.Volume();
    }
    return 0;
}

double GetAllPositionVolumn()
{
    CPositionInfo position;
    double all = 0;
    for(int i=0; i<ArraySize(SYMBOLS); ++i)
    {
        if (position.Select(SYMBOLS[i]))
        {
            all += position.Volume();
        }
    }
    return all;
}

string GetSubString(string s,int &idx,int &idx2, string split = "\t")
  {
   idx2=StringFind(s,split,idx);
   if(idx2== -1)
      idx2= StringLen(s);

   string symbol=StringSubstr(s,idx,idx2-idx);
   StringTrimLeft(symbol);
   StringTrimRight(symbol);
   idx=idx2+1;
   return symbol;
  }
  
//+------------------------------------------------------------------+
//| returns string value of the period                               |
//+------------------------------------------------------------------+
string GetPeriodName(ENUM_TIMEFRAMES period)
  {
   if(period==PERIOD_CURRENT) period=Period();
//---
   switch(period)
     {
      case PERIOD_M1:  return("M1");
      case PERIOD_M2:  return("M2");
      case PERIOD_M3:  return("M3");
      case PERIOD_M4:  return("M4");
      case PERIOD_M5:  return("M5");
      case PERIOD_M6:  return("M6");
      case PERIOD_M10: return("M10");
      case PERIOD_M12: return("M12");
      case PERIOD_M15: return("M15");
      case PERIOD_M20: return("M20");
      case PERIOD_M30: return("M30");
      case PERIOD_H1:  return("H1");
      case PERIOD_H2:  return("H2");
      case PERIOD_H3:  return("H3");
      case PERIOD_H4:  return("H4");
      case PERIOD_H6:  return("H6");
      case PERIOD_H8:  return("H8");
      case PERIOD_H12: return("H12");
      case PERIOD_D1:  return("D1");
      case PERIOD_W1:  return("W1");
      case PERIOD_MN1: return("M1");
     }
//---
   return("unknown period");
  }
  
/*double High[],Low[], Close[];
//+------------------------------------------------------------------+
//| Get Low for specified bar index                                  |
//+------------------------------------------------------------------+
double iLow(string symbol,ENUM_TIMEFRAMES timeframe,int index)
  {
   double low=0;
   ArraySetAsSeries(Low,true);
   int copied=CopyLow(symbol,timeframe,0,Bars(symbol,timeframe),Low);
   if(copied>0 && index<copied) low=Low[index];
   return(low);
  }
//+------------------------------------------------------------------+
//| Get the High for specified bar index                             |
//+------------------------------------------------------------------+
double iHigh(string symbol,ENUM_TIMEFRAMES timeframe,int index)
  {
   double high=0;
   ArraySetAsSeries(High,true);
   int copied=CopyHigh(symbol,timeframe,0,Bars(symbol,timeframe),High);
   if(copied>0 && index<copied) high=High[index];
   return(high);
  }
  
//+------------------------------------------------------------------+
//| Get the High for specified bar index                             |
//+------------------------------------------------------------------+
double iClose(string symbol,ENUM_TIMEFRAMES timeframe,int index)
  {
   double close=0;
   ArraySetAsSeries(Close,true);
   int copied=CopyClose(symbol,timeframe,0,Bars(symbol,timeframe),Close);
   if(copied>0 && index<copied) close=Close[index];
   return(close);
  }*/
   
int GetGMTOffset()
{
    if ((bool)MQL5InfoInteger(MQL5_TESTING))
        return 2;
    else
        return 0;
}

int GetCETOffset()
{
    // CET: UTC + 1; CEST: UTC + 2(daylight saving)
    return 0;
}

int GetPointOffset(int digit)
{
    if (digit == 3 || digit == 5)
        return 10;
    else if (digit == 2 || digit == 4)
        return 1;
    else
        return -1;
}

