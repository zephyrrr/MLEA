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
 m_indicatorZigzag=iCustom(_Symbol,_Period,"Examples\\Zigzag");
   if(m_indicatorZigzag<0)
     {
      Alert("Error Creating Handles for indicators - error: ",GetLastError(),"!!");
      return -1;
     }
     
      ArraySetAsSeries(m_zigzagBuf,true);
      ArraySetAsSeries(m_mqlRatesBuf,true);
      
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
    if(m_indicatorZigzag!=-1)
     {
      IndicatorRelease(m_indicatorZigzag);
     }
   
  }
  
int m_indicatorZigzag;
double m_zigzagBuf[];
MqlRates m_mqlRatesBuf[];

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
    string symbol = "EURUSD";
//    bool ret = SymbolInfoTick(symbol, tick);
//    if (!ret)
//        Alert("Error to retrive tick!");
//        
//    CFileBin file;
//    file.Open(symbol + "_Tick.dat", FILE_READ | FILE_WRITE);
//    file.Seek(0, SEEK_END);
//    file.WriteLong(tick.time);
//    file.WriteDouble(tick.bid);
//    file.WriteDouble(tick.ask);
//    file.WriteDouble(tick.last);
//    file.WriteLong(tick.volume);
//    file.Close();

    if(CopyBuffer(m_indicatorZigzag,0, 0, 1, m_zigzagBuf)<0)
     {
      Alert("Error copying Zigzag indicator buffer - error:",GetLastError());
      return;
     }
   if(CopyRates(_Symbol,_Period,0, 1, m_mqlRatesBuf)<0)
     {
      Alert("Error copying Zigzag indicator time - error:",GetLastError());
      return;
     }
     
    CFileBin file;
    file.Open(symbol + "_Tick.dat", FILE_READ | FILE_WRITE);
    file.Seek(0, SEEK_END);
    file.WriteLong(m_mqlRatesBuf[0].time);
        file.WriteDouble(m_mqlRatesBuf[0].open);
        file.WriteDouble(m_mqlRatesBuf[0].high);
        file.WriteDouble(m_mqlRatesBuf[0].low);
        file.WriteDouble(m_mqlRatesBuf[0].close);
        file.WriteLong(m_mqlRatesBuf[0].tick_volume);
        file.WriteInteger(m_mqlRatesBuf[0].spread);
        file.WriteLong(m_mqlRatesBuf[0].real_volume);
        
        file.WriteDouble(m_zigzagBuf[0]);
    file.Close();
  }
//+------------------------------------------------------------------+
