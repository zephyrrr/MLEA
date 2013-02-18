//+------------------------------------------------------------------+
//|                                         TestTxtShowIndicator.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  Green,Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_minimum 0
#property indicator_maximum 2

#include <Files\FileTxt.mqh>

input string FileName = "IncrementTest_EURUSD_Price_M15.txt";

double  ExtAMABuffer[];
double  ExtColorsBuffer[];

string            m_dealType[];
datetime          m_dealTime[];
string            m_realDealType[];
int m_currentTimeIdx;

bool ReadOrderTxts(string orderFileName)
  {
   int n=0;
   CFileTxt file;
   if(orderFileName!="")
     {
      if(file.Open(orderFileName,FILE_READ|FILE_COMMON)==INVALID_HANDLE)
        {
         return false;
        }

      while(true)
        {
         if(file.IsEnding())
            break;
         string s=file.ReadString();
         if (s == "")
            continue;
         n++;
        }
     }

   ArrayResize(m_dealType, n);
   ArrayResize(m_dealTime, n);
   ArrayResize(m_realDealType, n);
   
   if(orderFileName!="")
     {
      file.Seek(0,SEEK_SET);

      int i=0;
      while(true)
        {
         if(file.IsEnding())
            break;
         string s=file.ReadString();
         if (s == "")
            continue;
            
         AddToHistory(s,i);
         i++;
        }
     }

   m_currentTimeIdx=0;

    Print("LoadOk");
   return true;
  }

string GetSubString(string s,int &idx,int &idx2)
  {
   idx2=StringFind(s,",",idx);
   if(idx2==-1)
      idx2=StringLen(s);

   string symbol=StringSubstr(s,idx,idx2-idx);
   StringTrimLeft(symbol);
   StringTrimRight(symbol);
   idx=idx2+1;
   return symbol;
  }
  
void AddToHistory(string s,int i)
  {
   int idx=0,idx2=0;
   idx=0; idx2=0;
   string s1;

   s1=GetSubString(s,idx,idx2);
// 2011-01-17T01:00:00 -> 2011.01.17 01:00:00
   //if(StringLen(s1)==19)
   //   s1=StringSubstr(s1,0,16);
   StringReplace(s1,"-",".");
   StringReplace(s1,"T"," ");
   m_dealTime[i]=StringToTime(s1);
   
   s1=GetSubString(s,idx,idx2);
   m_dealType[i]=s1;
   
   s1=GetSubString(s,idx,idx2);
   m_realDealType[i]=s1;
  }
  
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,ExtAMABuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
   

   IndicatorSetString(INDICATOR_SHORTNAME,"Test");

   IndicatorSetInteger(INDICATOR_DIGITS,0);
   
   ReadOrderTxts(FileName);
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
int i;

//--- detect position
   int pos=prev_calculated-1;
    if (pos < 1)
        pos = 1;
        
//--- main cycle
   for(i=pos;i<rates_total && !IsStopped();i++)
     {
        datetime t = time[i];
        ExtAMABuffer[i] = 0;
        ExtColorsBuffer[i] = 0;
        
        if (t < m_dealTime[0])
        {
            continue;
        }
            
        int idx = ArrayBsearch(m_dealTime, t);
        if (t != m_dealTime[idx])
            continue;
            
        double r = (double)StringToInteger(m_dealType[idx]);
        double v = (double)StringToInteger(m_realDealType[idx]);
                
        if (r == 0)
            ExtAMABuffer[i] = 1.0;
        else if (r == 1)
            ExtAMABuffer[i] = 2.0;
                
        if (r == v)
            ExtColorsBuffer[i] = 1.0;
        else
            ExtColorsBuffer[i] = 0.0;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   
  }
//+------------------------------------------------------------------+
