//+------------------------------------------------------------------+
//|                                        OrderTxtSignal.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#include <ExpertModel\ExpertModelSignal.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Files\FileTxt.mqh>

#include <Indicators\Trend.mqh>
#include <Indicators\Oscilators.mqh>
#include <Indicators\TimeSeries.mqh>

#include <ExpertModel\ExpertModel.mqh>
#include <Data\ea_order.mqh>
//string DefaultOrderFileName = "MLEASignal.db.txt";//"ea_order.txt";

class COrderTxtSignal : public CExpertModelSignal
  {
private:
   string            m_defaultOrderFileName;

   int               m_defaultTp;
   int               m_defaultSl;

   string            m_dealType[];
   datetime          m_dealTime[];
   long              m_dealBl[];
   long              m_dealTp[];
   long              m_dealSl[];
   double            m_dealProb[];
   int               m_currentTimeIdx;
   double            m_limitPrice;

   datetime          m_lastCheckOpenTime,m_lastCheckCloseTime;

   bool              GetCurrentLine(bool isCheckOpen);
   void              AddToHistory(string s,int i);
   string            GetSubString(string s,int &idx,int &idx2);
   bool              CanDealAccordProfit();

   CPositionInfo     m_position;
   datetime          TruncateTime(datetime time);
public:
                     COrderTxtSignal();
                    ~COrderTxtSignal();
   virtual bool      ValidationSettings();
   virtual bool      InitIndicators(CIndicators *indicators);

   virtual bool      CheckOpenLong(double &price,double &sl,double &tp,datetime &expiration);
   virtual bool      CheckCloseLong(CTableOrder *t,double &price);
   virtual bool      CheckOpenShort(double &price,double &sl,double &tp,datetime &expiration);
   virtual bool      CheckCloseShort(CTableOrder *t,double &price);
   virtual bool      CheckCloseOrderLong();
   virtual bool      CheckCloseOrderShort();

   bool              InitParameters(bool readDefaultFile=true);

   bool              ReadOrderTxts(string orderFileName);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COrderTxtSignal::COrderTxtSignal()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderTxtSignal::InitParameters(bool readDefaultFile)
  {
   m_lastCheckOpenTime=D'2000.01.01';
   m_lastCheckCloseTime=D'2000.01.01';

   m_defaultTp = 100;
   m_defaultSl = 100;
   m_limitPrice= 0.0020;

   if(readDefaultFile)
     {
      m_defaultOrderFileName="ea_order_"+m_symbol.Name()+".txt";
      Print("Begin Read Order Text ",m_defaultOrderFileName);
      int r=ReadOrderTxts(m_defaultOrderFileName);
      if(!r)
        {
         Error("Error Open Order File.");
        }
      else
        {
         Print("Read Order File OK");
        }
     }

   m_position.Select(m_symbol.Name());
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderTxtSignal::ReadOrderTxts(string orderFileName)
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
         n++;
        }
     }
   else
     {
      n=ArraySize(m_historyDealsTxt);
     }

   ArrayResize(m_dealType,n);
   ArrayResize(m_dealTime,n);
   ArrayResize(m_dealBl,n);
   ArrayResize(m_dealTp,n);
   ArrayResize(m_dealSl,n);
   ArrayResize(m_dealProb,n);

   if(orderFileName!="")
     {
      file.Seek(0,SEEK_SET);

      int i=0;
      while(true)
        {
         if(file.IsEnding())
            break;
         string s=file.ReadString();

         AddToHistory(s,i);
         i++;
        }
     }
   else
     {
      for(int i=0; i<n;++i)
        {
         AddToHistory(m_historyDealsTxt[i],i);
        }
     }

   m_currentTimeIdx=0;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COrderTxtSignal::AddToHistory(string s,int i)
  {
   int idx=0,idx2=0;
   idx=0; idx2=0;
   string s1=GetSubString(s,idx,idx2);
   m_dealType[i]=s1;

   s1=GetSubString(s,idx,idx2);
// 2011-01-17T01:00:00 -> 2011.01.17 01:00:00
//if(StringLen(s1)==19)
//   s1=StringSubstr(s1,0,16);
   StringReplace(s1,"-",".");
   StringReplace(s1,"T"," ");
   m_dealTime[i]=StringToTime(s1);

   s1=GetSubString(s,idx,idx2);
   m_dealTp[i]=StringToInteger(s1);

   s1=GetSubString(s,idx,idx2);
   m_dealSl[i]=StringToInteger(s1);

   s1=GetSubString(s,idx,idx2);
   m_dealBl[i]=StringToInteger(s1);

   s1=GetSubString(s,idx,idx2);
   m_dealProb[i]=StringToDouble(s1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string COrderTxtSignal::GetSubString(string s,int &idx,int &idx2)
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COrderTxtSignal::~COrderTxtSignal()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderTxtSignal::ValidationSettings()
  {
   if(!CExpertSignal::ValidationSettings())
      return(false);

   if(false)
     {
      printf(__FUNCTION__+": Indicators should not be Null!");
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderTxtSignal::InitIndicators(CIndicators *indicators)
  {
   if(indicators==NULL)
      return(false);
   bool ret=true;

   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime COrderTxtSignal::TruncateTime(datetime time)
  {
   return time/1*1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderTxtSignal::GetCurrentLine(bool isCheckOpen)
  {
   datetime now=TimeCurrent();
   now=TruncateTime(now);

//Print(TimeToString(m_lastCheckOpenTime));
//Print("Check" + isCheckOpen);

   if(isCheckOpen)
     {
      if(now==m_lastCheckOpenTime)
         return false;
     }
   else
     {
      if(now==m_lastCheckCloseTime)
         return false;
     }

//Print("Check" + isCheckOpen);        
   if(m_currentTimeIdx>=ArraySize(m_dealTime))
     {
      //if(PositionSelect(Symbol()))
      //{
      //    CTrade trade;
      //    trade.PositionClose(Symbol());
      //}
      return false;
     }

   for(int i=m_currentTimeIdx; i<ArraySize(m_dealTime);++i)
     {
      datetime dealTime=m_dealTime[i];
      if(dealTime>now)
        {
         return false;
        }
      else if(dealTime==now)
        {
         m_currentTimeIdx=i;
         return true;
        }
      else
        {
         m_currentTimeIdx=i+1;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderTxtSignal::CanDealAccordProfit()
  {
   if(m_position.Volume()!=0)
     {
      double pp=m_position.Profit()/m_position.Volume()/10;
      //if (MathAbs(pp) > 10)
      //    Print(pp);
      if(pp<-100)
         return false;
     }

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderTxtSignal::CheckOpenLong(double &price,double &sl,double &tp,datetime &expiration)
  {
   Debug("COrderTxtSignal::CheckOpenLong");

//if (!CanDealAccordProfit())
//    return false;

   bool ret=false;
   if(GetCurrentLine(true) && m_dealType[m_currentTimeIdx]=="Buy")
     {
      m_symbol.RefreshRates();
      price=m_symbol.Ask()-m_limitPrice;
      //m_dealSl[m_currentTimeIdx] = 1000;

      if(m_dealTp[m_currentTimeIdx]!=0)
        {
         tp = price + m_symbol.Point() * GetPointOffset(m_symbol.Digits()) * m_dealTp[m_currentTimeIdx];
         sl = price - m_symbol.Point() * GetPointOffset(m_symbol.Digits()) * m_dealSl[m_currentTimeIdx];
        }
      else
        {
         tp = price + m_symbol.Point() * GetPointOffset(m_symbol.Digits()) * m_defaultTp;
         sl = price - m_symbol.Point() * GetPointOffset(m_symbol.Digits()) * m_defaultSl;
        }

      m_lastCheckOpenTime=TruncateTime(TimeCurrent());

      expiration=TimeCurrent()+60*60*4;
      ret=true;
     }

   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderTxtSignal::CheckOpenShort(double &price,double &sl,double &tp,datetime &expiration)
  {
   Debug("COrderTxtSignal::CheckOpenShort");

//if (!CanDealAccordProfit())
//    return false;

   bool ret=false;
   if(GetCurrentLine(true) && m_dealType[m_currentTimeIdx]=="Sell")
     {
      m_symbol.RefreshRates();
      price=m_symbol.Bid()+m_limitPrice;
      //m_dealSl[m_currentTimeIdx] = 1000;

      if(m_dealTp[m_currentTimeIdx]!=0)
        {
         tp = price - m_symbol.Point() * GetPointOffset(m_symbol.Digits()) * m_dealTp[m_currentTimeIdx];
         sl = price + m_symbol.Point() * GetPointOffset(m_symbol.Digits()) * m_dealSl[m_currentTimeIdx];
        }
      else
        {
         tp = price - m_symbol.Point() * GetPointOffset(m_symbol.Digits()) * m_defaultTp;
         sl = price + m_symbol.Point() * GetPointOffset(m_symbol.Digits()) * m_defaultSl;
        }
      expiration=TimeCurrent()+60*60*4;
      ret=true;
     }
   m_lastCheckOpenTime=TruncateTime(TimeCurrent());
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderTxtSignal::CheckCloseLong(CTableOrder *t,double &price)
  {
   return false;
   Debug("COrderTxtSignal::CheckCloseLong");

   bool ret=false;
   if(GetCurrentLine(false) && m_dealType[m_currentTimeIdx]=="Sell")
     {
      price=m_symbol.Bid();

      m_lastCheckCloseTime=TruncateTime(TimeCurrent());
      ret=true;
     }

   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderTxtSignal::CheckCloseShort(CTableOrder *t,double &price)
  {
   return false;
   Debug("COrderTxtSignal::CheckCloseShort");

   bool ret=false;
   if(GetCurrentLine(false) && m_dealType[m_currentTimeIdx]=="Buy")
     {
      price=m_symbol.Ask();

      ret=true;
     }
   m_lastCheckCloseTime=TruncateTime(TimeCurrent());
   return ret;
  }
//+------------------------------------------------------------------+

bool  COrderTxtSignal::CheckCloseOrderLong()
  {
   Debug("COrderTxtSignal::CheckCloseOrderLong");

   bool ret=false;
   if(GetCurrentLine(false) && m_dealType[m_currentTimeIdx]=="Sell")
     {
      m_lastCheckCloseTime=TruncateTime(TimeCurrent());
      ret=true;
     }

   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  COrderTxtSignal::CheckCloseOrderShort()
  {
   Debug("COrderTxtSignal::CheckCloseOrderShort");

   bool ret=false;
   if(GetCurrentLine(false) && m_dealType[m_currentTimeIdx]=="Buy")
     {
      ret=true;
     }
   m_lastCheckCloseTime=TruncateTime(TimeCurrent());
   return ret;
  }
//+------------------------------------------------------------------+
