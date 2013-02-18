//+------------------------------------------------------------------+
//|                                                   MLEASignal.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

#define TestDll 0
#import "MT5EA.dll"
   void HelloDllTest(string say);
   void HelloServiceTest(long hHandle, string say);
   long CreateEAService(string symbol);
   void DestroyEAService(long hHandle);
   void OnNewBar(long hService, long nowTime, int barLength, double& p[], int num);
   void RunTool(long hService, string toolName);
#import

#include <ExpertModel\ExpertModel.mqh>
#include <ExpertModel\ExpertModelSignal.mqh>

#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Files\FileTxt.mqh>
#include <Utils\IsNewBar.mqh>

#include <Indicators\Trend.mqh>
#include <Indicators\Oscilators.mqh>
#include <Indicators\TimeSeries.mqh>
#include <EA\IndicatorGroup.mqh>

#include <Utils\HistoryDataExport.mqh>

#include "OrderTxtSignal.mqh"

class CMLEASignal : public CExpertModelSignal
  {
private:
    long m_ea;
    CisNewBar m_isNewBars[2];
    datetime m_lastOpenTime;

    CIndicatorGroup m_indicatorGroups[2];
    CHistoryDataExport historyDataExport;
    
    COrderTxtSignal m_orderTxtSignal;
    bool m_simulateBeforeDone;
public:
    void OnTick();
                     CMLEASignal();
                    ~CMLEASignal();
   virtual bool      ValidationSettings();
   virtual bool      InitIndicators(CIndicators* indicators);
   
   virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseLong(CTableOrder* t, double& price);
   virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseShort(CTableOrder* t, double& price);
   bool InitParameters();
   void ExportData(datetime startTime, datetime nowTime);
  };

void CMLEASignal::ExportData(datetime startTime, datetime nowTime)
{
    // Write All Data
    if (nowTime > startTime)
    {
        Print("Run ExportData");
        
        historyDataExport.SetDate(startTime, nowTime);
        ENUM_TIMEFRAMES periods[] = {PERIOD_M5, PERIOD_M15, PERIOD_H1, PERIOD_H4, PERIOD_D1};
        historyDataExport.WriteData(m_symbol.Name(), PERIOD_M1);
        for(int j=0; j<ArraySize(periods); ++j)
        {
            historyDataExport.WriteAll(m_symbol.Name(), periods[j]);
        }
        
        //RunTool(m_ea, "ImportDB");
        Print("ExportData Finished.");
    }
    
}

bool CMLEASignal::InitParameters()
{
    if (TestDll)
    {
        HelloDllTest("HelloDllTest");
    }
    
    
    m_ea = CreateEAService(m_symbol.Name());
    if (m_ea == NULL)
    {
        Alert("MLEA Init failed!");
        return false;
    }
    else
    {
        if (TestDll)
        {
            HelloServiceTest(m_ea, "HelloServiceTest is OK.");
        }
    }
    
    m_isNewBars[1].SetSymbol(m_symbol.Name());
    m_isNewBars[1].SetPeriod(PERIOD_M1);
    
    m_isNewBars[0].SetSymbol(m_symbol.Name());
    m_isNewBars[0].SetPeriod(PERIOD_H4);

    for(int i=0; i<ArraySize(m_isNewBars); ++i)
    {
        m_indicatorGroups[i].InitParameters(m_isNewBars[i].GetSymbol(), m_isNewBars[i].GetPeriod(), i!=ArraySize(m_isNewBars)-1);
    }
    
    m_orderTxtSignal.Init(GetPointer(m_symbol), m_period, m_adjusted_point);
    m_orderTxtSignal.InitParameters(false);
    
    ENUM_PROGRAM_TYPE mql_program=(ENUM_PROGRAM_TYPE)MQL5InfoInteger(MQL5_PROGRAM_TYPE);
    if (!(bool)MQL5InfoInteger(MQL5_TESTING) && mql_program == PROGRAM_EXPERT)
    {
        datetime nowTime = TimeCurrent();
        MqlDateTime startDate;
        TimeToStruct(nowTime, startDate);
        startDate.year = startDate.year - 3;
        datetime startTime = StructToTime(startDate);
        ExportData(startTime, nowTime);
    }
    
    return true;
}

void CMLEASignal::CMLEASignal()
{
    m_simulateBeforeDone = false;
}

void CMLEASignal::~CMLEASignal()
{
    if (m_ea != NULL)
    {
        DestroyEAService(m_ea);
    }
}

bool CMLEASignal::ValidationSettings()
{
    if(!CExpertSignal::ValidationSettings()) 
        return(false);
        
    if (false)
    {
      printf(__FUNCTION__+": Indicators should not be Null!");
      return(false);
    }
    return(true);
}

bool CMLEASignal::InitIndicators(CIndicators* indicators)
{
    if(indicators==NULL) 
        return(false);
    bool ret = true;
    
    return ret;
}

void CMLEASignal::OnTick()
{
    bool newBar[];
    ArrayResize(newBar, ArraySize(m_isNewBars));
    for(int i=0; i<ArraySize(m_isNewBars); ++i)
    {
        newBar[i] = m_isNewBars[i].isNewBar();
    }
    
    if (newBar[1])
    {
        datetime nowTime = m_isNewBars[1].GetLastBarTime();
        double p[];
        m_indicatorGroups[1].GetData(nowTime, p);
        OnNewBar(m_ea, nowTime, PeriodSeconds(m_isNewBars[1].GetPeriod()), p, ArraySize(p));
    }
    
    if (newBar[0])
    {
        if (!m_simulateBeforeDone)
        {
            m_simulateBeforeDone = true;
            RunTool(m_ea, "SimulateBefore");
        }
        
        datetime nowTime = m_isNewBars[0].GetLastBarTime();
            
        //historyDataExport.SetDate(nowTime - 60 * 60 * 24 * 7, nowTime + 60 * 60);
        //historyDataExport.WriteData(m_symbol.Name(), PERIOD_M1);
            
        double p[];
        m_indicatorGroups[0].GetData(nowTime, p);
            
            //long time = m_isNewBarD1.GetLastBarTime();
            //long time2 = rates[0].time;
            //Print(TimeToString(time), ",", TimeToString(time2));
            
        OnNewBar(m_ea, nowTime, PeriodSeconds(m_isNewBars[0].GetPeriod()), p, ArraySize(p));
            
        Print("OnNewSignal");
        m_orderTxtSignal.ReadOrderTxts("MLEASignal_" + m_symbol.Name() + ".txt");    
    }
    
    
}

bool CMLEASignal::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
{
    Debug("COrderTxtSignal::CheckOpenLong");
    OnTick();
    
    return m_orderTxtSignal.CheckOpenLong(price, sl, tp, expiration);
}

bool CMLEASignal::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
{
    Debug("COrderTxtSignal::CheckOpenShort");
    
    return m_orderTxtSignal.CheckOpenShort(price, sl, tp, expiration);
}

bool CMLEASignal::CheckCloseLong(CTableOrder* t, double& price)
{
    return false;
    Debug("COrderTxtSignal::CheckCloseLong");
}

bool CMLEASignal::CheckCloseShort(CTableOrder* t, double& price)
{   
    return false;
    Debug("COrderTxtSignal::CheckCloseShort");
}
