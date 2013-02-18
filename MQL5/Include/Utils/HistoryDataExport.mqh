//+------------------------------------------------------------------+
//|                                            HistoryDataExport.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#include <Files\FileBin.mqh>
#include <utils\Utils.mqh>

class CHistoryDataExport : CObject
{
private:
    datetime m_startDate;
    datetime m_endDate;
public:
    CHistoryDataExport();
    bool WriteIndicator(string symbol, ENUM_TIMEFRAMES period, string indicatorName, int indicatorHandle, int indicatorBufferNum = 0);
    bool WriteData(string symbol, ENUM_TIMEFRAMES period);
    void WriteAll(string symbol, ENUM_TIMEFRAMES period);
    void SetDate(datetime start, datetime end) { m_startDate = start; m_endDate = end; }
    int CheckLoadHistory(string symbol,ENUM_TIMEFRAMES period,datetime start_date);
};

void CHistoryDataExport::CHistoryDataExport()
{
    m_startDate = D'2000.01.01 00:00';
    m_endDate = D'2020.03.01 00:00';
}

int CHistoryDataExport::CheckLoadHistory(string symbol,ENUM_TIMEFRAMES period,datetime start_date)
  {
   datetime first_date=0;
   datetime times[100];
//--- check symbol & period
   if(symbol==NULL || symbol=="") symbol=Symbol();
   if(period==PERIOD_CURRENT)     period=Period();
//--- check if symbol is selected in the MarketWatch
   if(!SymbolInfoInteger(symbol,SYMBOL_SELECT))
     {
      if(GetLastError()==ERR_MARKET_UNKNOWN_SYMBOL) return(-1);
      SymbolSelect(symbol,true);
     }
//--- check if data is present
   SeriesInfoInteger(symbol,period,SERIES_FIRSTDATE,first_date);
   if(first_date>0 && first_date<=start_date) return(1);
//--- don't ask for load of its own data if it is an indicator
   if(MQL5InfoInteger(MQL5_PROGRAM_TYPE)==PROGRAM_INDICATOR && Period()==period && Symbol()==symbol)
      return(-4);
//--- second attempt
   if(SeriesInfoInteger(symbol,PERIOD_M1,SERIES_TERMINAL_FIRSTDATE,first_date))
     {
      //--- there is loaded data to build timeseries
      if(first_date>0)
        {
         //--- force timeseries build
         CopyTime(symbol,period,first_date+PeriodSeconds(period),1,times);
         //--- check date
         if(SeriesInfoInteger(symbol,period,SERIES_FIRSTDATE,first_date))
            if(first_date>0 && first_date<=start_date) return(2);
        }
     }
//--- max bars in chart from terminal options
   int max_bars=TerminalInfoInteger(TERMINAL_MAXBARS);
//--- load symbol history info
   datetime first_server_date=0;
   while(!SeriesInfoInteger(symbol,PERIOD_M1,SERIES_SERVER_FIRSTDATE,first_server_date) && !IsStopped())
      Sleep(5);
//--- fix start date for loading
   if(first_server_date>start_date) start_date=first_server_date;
   if(first_date>0 && first_date<first_server_date)
      Print("Warning: first server date ",first_server_date," for ",symbol,
            " does not match to first series date ",first_date);
//--- load data step by step
   int fail_cnt=0;
   while(!IsStopped())
     {
      //--- wait for timeseries build
      while(!SeriesInfoInteger(symbol,period,SERIES_SYNCHRONIZED) && !IsStopped())
         Sleep(5);
      //--- ask for built bars
      int bars=Bars(symbol,period);
      if(bars>0)
        {
         if(bars>=max_bars) return(-2);
         //--- ask for first date
         if(SeriesInfoInteger(symbol,period,SERIES_FIRSTDATE,first_date))
            if(first_date>0 && first_date<=start_date) return(0);
        }
      //--- copying of next part forces data loading
      int copied=CopyTime(symbol,period,bars,100,times);
      if(copied>0)
        {
         //--- check for data
         if(times[0]<=start_date)  return(0);
         if(bars+copied>=max_bars) return(-2);
         fail_cnt=0;
        }
      else
        {
         //--- no more than 100 failed attempts
         fail_cnt++;
         if(fail_cnt>=100) return(-5);
         Sleep(10);
        }
     }
//--- stopped
   return(-3);
  }
  
bool CHistoryDataExport::WriteIndicator(string symbol, ENUM_TIMEFRAMES period, string indicatorName, int indicatorHandle, int indicatorBufferNum = 0)
{
    string fileName = symbol + "_" + GetPeriodName(period) + "_" + indicatorName + ".dat";
    //if (FileIsExist(fileName))
    //    return true;
   
    //Print("Start to Write ", fileName);
   
    datetime time_array[];     
    ArraySetAsSeries(time_array, true);
    int n = CopyTime(symbol, period, m_startDate, m_endDate, time_array);
    int length = ArraySize(time_array);
    
    double indicatorBuffer[];
    //SetIndexBuffer(0,indicatorBuffer,INDICATOR_DATA);
    ArraySetAsSeries(indicatorBuffer, true);
    //int indicatorHandle = iMA(symbol, period, 60, 0, MODE_EMA, PRICE_CLOSE);
    //int indicatorHandle = iATR(symbol, period, 19); 
    //int indicatorHandle = iBands(symbol, period, 26*60, 0, 2, PRICE_CLOSE);
    //int indicatorHandle = iWPR(symbol, period, 18*15);
    
    if(indicatorHandle == INVALID_HANDLE)
    {
        Print("Error Creating Handles for indicator of " + indicatorName + "!");
        ErrorCurrentError();
        return false;
    }
    
    n = CopyBuffer(indicatorHandle, indicatorBufferNum, m_startDate, m_endDate, indicatorBuffer);
    if (n < 0)
    {
        Print("Error in CopyBuffer of " + indicatorName + "!");
        ErrorCurrentError();
        return false;
    }
    int length2 = ArraySize(indicatorBuffer);
    if (length != length2)
    {
        Print("MqlRates and indicator haven't the same length! rate length is ", length, " and indicator length is ", length2);
        return false;
    }

    CFileBin file;
    file.SetCommon(true);
    file.Open(fileName, FILE_WRITE | FILE_COMMON);
    for (int i=0; i<length; ++i)
    {
        file.WriteLong(time_array[i]);
        file.WriteDouble(indicatorBuffer[i]);
    }
    file.Close();
    
    //Print("Finish Write ", fileName);
    return true;
}

bool CHistoryDataExport::WriteData(string symbol, ENUM_TIMEFRAMES period)
{
    string fileName = symbol + "_" + GetPeriodName(period) + ".dat";
    //if (FileIsExist(fileName))
    //    return true;
        
    Print("Start to Write ", fileName, " from ", TimeToString(m_startDate), " to ", TimeToString(m_endDate));
   
    int res=CheckLoadHistory(symbol,period,D'2000.01.01 00:00');
    switch(res)
    {
      case -1 : Print("Unknown symbol ",symbol);             break;
      case -2 : Print("Requested bars more than max bars in chart"); break;
      case -3 : Print("Program was stopped");                        break;
      case -4 : Print("Indicator shouldn't load its own data");      break;
      case -5 : Print("Load failed");                                break;
      case  0 : Print("Loaded OK");                                  break;
      case  1 : Print("Loaded previously");                          break;
      case  2 : Print("Loaded previously and built");                break;
      default : Print("Unknown result");
    }
     
    //long start_pos = SeriesInfoInteger(symbol, period, SERIES_SERVER_FIRSTDATE);
    //datetime startData = datetime(start_pos);  // 1993
    
    MqlRates rates[];
    ArraySetAsSeries(rates,true);
   
    int n = CopyRates(symbol, period, m_startDate, m_endDate, rates);
    if (n < 0)
    {
        Print("Error in CopyRates!");
        ErrorCurrentError();
        return false;
    }

    int length = ArraySize(rates);
    
    CFileBin file;
    file.SetCommon(true);
    file.Open(fileName, FILE_WRITE | FILE_COMMON);
    for (int i=length-1; i>=0; --i)
    {
        file.WriteLong(rates[i].time);
        file.WriteDouble(rates[i].open);
        file.WriteDouble(rates[i].high);
        file.WriteDouble(rates[i].low);
        file.WriteDouble(rates[i].close);
        file.WriteLong(rates[i].tick_volume);
        file.WriteInteger(rates[i].spread);
        file.WriteLong(rates[i].real_volume);
        
        //file.WriteDouble(indicatorBuffer[i]);
    }
    file.Close();
    
    Print("Finish Write with length = ", length);
    return true;
}

void CHistoryDataExport::WriteAll(string symbol, ENUM_TIMEFRAMES period)
{
    WriteData(symbol, period);
    
    int ind1 = iAMA(symbol, period, 9, 2, 30, 0, PRICE_CLOSE);  WriteIndicator(symbol, period, "AMA_9_2_30", ind1);
    int ind2 = iADX(symbol, period, 14);                        WriteIndicator(symbol, period, "ADX_14", ind2); WriteIndicator(symbol, period, "ADX_14_P", ind2, 1);WriteIndicator(symbol, period, "ADX_14_M", ind2, 2);
    int ind3 = iADXWilder(symbol, period, 14);                  WriteIndicator(symbol, period, "ADXWilder_14", ind3);   WriteIndicator(symbol, period, "ADXWilder_14_P", ind3, 1);WriteIndicator(symbol, period, "ADXWilder_14_M", ind3, 2);
    int ind4 = iBands(symbol, period, 20, 0, 2, PRICE_CLOSE);   WriteIndicator(symbol, period, "Bands_20_2", ind4);
    int ind5 = iDEMA(symbol, period, 14, 0, PRICE_CLOSE);       WriteIndicator(symbol, period, "DEMA_14", ind5);
    //int ind6 = iEnvelopes();
    int ind7 = iFrAMA(symbol, period, 14, 0, PRICE_CLOSE);      WriteIndicator(symbol, period, "FrAMA_14", ind7);
    //int ind8 = iIchimoku();                                     
    int ind9 = iMA(symbol, period, 10, 0, MODE_SMA, PRICE_CLOSE);   WriteIndicator(symbol, period, "MA_10", ind9);
    //int ind10 = iSAR(symbol, period, 0.02, 0.2);                    WriteIndicator(symbol, period, "SAR_002_02", ind10);
    int ind11 = iStdDev(symbol, period, 20, 0, MODE_SMA, PRICE_CLOSE);  WriteIndicator(symbol, period, "StdDev_20", ind11);
    int ind12 = iTEMA(symbol, period, 14, 0, PRICE_CLOSE);      WriteIndicator(symbol, period, "TEMA_14", ind12);
    int ind13 = iVIDyA(symbol, period, 9, 12, 0, PRICE_CLOSE);  WriteIndicator(symbol, period, "VIDyA_9_12", ind13);
    
    int ind21 = iATR(symbol, period, 14);                       WriteIndicator(symbol, period, "ATR_14", ind21);
    int ind22 = iBearsPower(symbol, period, 13);                WriteIndicator(symbol, period, "BearsPower_13", ind22);
    int ind23 = iBullsPower(symbol, period, 13);                WriteIndicator(symbol, period, "BullsPower_13", ind23);
    //int ind24 = iChaikin();
    int ind25 = iCCI(symbol, period, 14, PRICE_TYPICAL);        WriteIndicator(symbol, period, "CCI_14", ind25);
    int ind26 = iDeMarker(symbol, period, 14);                  WriteIndicator(symbol, period, "DeMarker_14", ind26);
    //int ind27 = iForce();
    int ind28 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE);  WriteIndicator(symbol, period, "MACD_12_26_9_M", ind28); WriteIndicator(symbol, period, "MACD_12_26_9_S", ind28, 1);
    //int ind29 = iMomentum(symbol, period, 14, PRICE_CLOSE);     WriteIndicator(symbol, period, "Momentum_14", ind29);
    //int ind30 = iOsMA(symbol, period, 12, 26, 9, PRICE_CLOSE);  WriteIndicator(symbol, period, "OsMA_12_26_9", ind30);
    int ind31 = iRSI(symbol, period, 14, PRICE_CLOSE);          WriteIndicator(symbol, period, "RSI_14", ind31);
    int ind32 = iRVI(symbol, period, 10);                       WriteIndicator(symbol, period, "RVI_10_M", ind32);  WriteIndicator(symbol, period, "RVI_10_S", ind32, 1);
    int ind33 = iStochastic(symbol, period, 5, 3, 3, MODE_SMA, STO_LOWHIGH);    WriteIndicator(symbol, period, "Stochastic_5_3_3_M", ind33); WriteIndicator(symbol, period, "Stochastic_5_3_3_S", ind33, 1);
    int ind34 = iTriX(symbol, period, 14, PRICE_CLOSE);         WriteIndicator(symbol, period, "TriX_14", ind34);
    int ind35 = iWPR(symbol, period, 14);                       WriteIndicator(symbol, period, "WPR_14", ind35);
    
    //int ind41 = iAC(symbol, period);
    //int ind42 = iAlligator(symbol, period, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN);
    //int ind43 = iAO(symbol, period);
    //int ind44 = iFractals();
    //int ind45 = iGator();
    //int ind46 = iBWMFI();
    
    IndicatorRelease(ind1);
    IndicatorRelease(ind2);
    IndicatorRelease(ind3);
    IndicatorRelease(ind4);
    IndicatorRelease(ind5);
    IndicatorRelease(ind7);
    IndicatorRelease(ind9);
    IndicatorRelease(ind11);
    IndicatorRelease(ind12);
    IndicatorRelease(ind13);
    IndicatorRelease(ind21);
    IndicatorRelease(ind22);
    IndicatorRelease(ind23);
    IndicatorRelease(ind25);
    IndicatorRelease(ind26);
    IndicatorRelease(ind28);
    IndicatorRelease(ind31);
    IndicatorRelease(ind32);
    IndicatorRelease(ind33);
    IndicatorRelease(ind34);
    IndicatorRelease(ind35);
}
