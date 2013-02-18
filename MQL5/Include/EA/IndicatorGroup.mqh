//+------------------------------------------------------------------+
//|                                                   WekaExpert.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <Trade\SymbolInfo.mqh>
#include <Files\FileTxt.mqh>
#include <Utils\Utils.mqh>

#define IND_CNT 27
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CIndicatorGroup
  {
private:
   int               inds[30];
   ENUM_TIMEFRAMES   m_period;
   string            m_symbol;

   int               AMA_9_2_30,ADX_14,ADXWilder_14,Bands_20_2,DEMA_14,FrAMA_14,MA_10,SAR_002_02,StdDev_20,TEMA_14,VIDyA_9_12;
   int               ATR_14,BearsPower_13,BullsPower_13,CCI_14,DeMarker_14,MACD_12_26_9,RSI_14,RVI_10,Stochastic_5_3_3,TriX_14,WPR_14;
   datetime          m_lastTime;
   int               m_currentHour;
   bool m_addIndicator;
public:
   void              InitParameters(string symbol,ENUM_TIMEFRAMES period,bool addIndicator=true);
                     CIndicatorGroup();
                    ~CIndicatorGroup();
   void              GetData(datetime nowTime,double &dp[]);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CIndicatorGroup::CIndicatorGroup()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CIndicatorGroup::InitParameters(string symbol,ENUM_TIMEFRAMES period, bool addIndicator)
  {
   m_symbol = symbol;
   m_period = period;

   AMA_9_2_30=ADX_14=ADXWilder_14=Bands_20_2=DEMA_14=FrAMA_14=MA_10=SAR_002_02=StdDev_20=TEMA_14=VIDyA_9_12=-1;
   ATR_14=BearsPower_13=BullsPower_13=CCI_14=DeMarker_14=MACD_12_26_9=RSI_14=RVI_10=Stochastic_5_3_3=TriX_14=WPR_14=-1;

    m_addIndicator = addIndicator;
    if (addIndicator)
    { 
   int n=0;
   inds[n] = iADXWilder(m_symbol, m_period, 14);          ADXWilder_14 = n; n++;
   inds[n] = iADX(m_symbol, m_period, 14);                ADX_14 = n; n++;
   inds[n] = iAMA(m_symbol, m_period, 9, 2, 30, 0, PRICE_CLOSE);   AMA_9_2_30 = n; n++;
   inds[n] = iATR(m_symbol, m_period, 14);                          ATR_14 = n; n++;
   inds[n] = iBands(m_symbol, m_period, 20, 0, 2, PRICE_CLOSE);     Bands_20_2 = n; n++;
   inds[n] = iBearsPower(m_symbol, m_period, 13);                   BearsPower_13 = n; n++;
   inds[n] = iBullsPower(m_symbol, m_period, 13);                   BullsPower_13 = n; n++;
   inds[n] = iCCI(m_symbol, m_period, 14, PRICE_TYPICAL);           CCI_14 = n; n++;
   inds[n] = iDeMarker(m_symbol, m_period, 14);                     DeMarker_14 = n; n++;
   inds[n] = iDEMA(m_symbol, m_period, 14, 0, PRICE_CLOSE);         DEMA_14 = n; n++;
   inds[n] = iFrAMA(m_symbol, m_period, 14, 0, PRICE_CLOSE);        FrAMA_14 = n; n++;
   inds[n] = iMACD(m_symbol, m_period, 12, 26, 9, PRICE_CLOSE);     MACD_12_26_9= n; n++;
   inds[n] = iMA(m_symbol, m_period, 10, 0, MODE_SMA, PRICE_CLOSE); MA_10 = n; n++;
   inds[n] = iRSI(m_symbol, m_period, 14, PRICE_CLOSE);             RSI_14 = n; n++;
   inds[n] = iRVI(m_symbol, m_period, 10);                          RVI_10 = n; n++;
   inds[n] = iStochastic(m_symbol, m_period, 5, 3, 3, MODE_SMA, STO_LOWHIGH);       Stochastic_5_3_3 = n; n++;
   inds[n] = iTEMA(m_symbol, m_period, 14, 0, PRICE_CLOSE);         TEMA_14 = n; n++;
   inds[n] = iTriX(m_symbol, m_period, 14, PRICE_CLOSE);            TriX_14 = n; n++;
   inds[n] = iVIDyA(m_symbol, m_period, 9, 12, 0, PRICE_CLOSE);     VIDyA_9_12 = n; n++;
   inds[n] = iWPR(m_symbol, m_period, 14);                          WPR_14 = n; n++;
   }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CIndicatorGroup::~CIndicatorGroup()
  {
   for(int j=0; j<30;++j)
     {
      if(inds[j]!=NULL)
        {
         IndicatorRelease(inds[j]);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CIndicatorGroup::GetData(datetime nowTime,double &dp[])
  {
   Debug("GetData of "+TimeToString(nowTime));

   int numAttr=IND_CNT+6+5;

   MqlDateTime date;
   ArrayResize(dp,numAttr);

   int pos=0;

   datetime time=nowTime;

   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   double indBuf[];
   ArraySetAsSeries(indBuf,true);

//double mainClose = 0;
//mainClose = dp[pos * numAttr + 5] = rates[0].close;

   datetime newTime=time-PeriodSeconds(m_period);
   CopyRates(m_symbol,m_period,newTime,2,rates);

   time=rates[0].time+PeriodSeconds(m_period);
   TimeToStruct(time,date);

   dp[pos*numAttr+0]=(double)time;
   dp[pos*numAttr+1]=0;    // closeTime
   dp[pos * numAttr + 2] = date.hour / 24.0;
   dp[pos * numAttr + 3] = date.day_of_week / 5.0;
   dp[pos * numAttr + 4] = 0;    // vol
   dp[pos * numAttr + 5] = 0.00; // mainClose

   int start=pos*numAttr+6;

   int p=0;

   dp[start] = rates[p].close;  start++;
   dp[start] = rates[p].open;   start++;
   dp[start] = rates[p].high;   start++;
   dp[start] = rates[p].low;    start++;
   dp[start] = rates[p].spread;    start++;

   if(!m_addIndicator)
      return;

   if(ADXWilder_14!=-1)
     {
      CopyBuffer(inds[ADXWilder_14],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
      CopyBuffer(inds[ADXWilder_14],1,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
      CopyBuffer(inds[ADXWilder_14],2,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start+=3;
     }

   if(ADX_14!=-1)
     {
      CopyBuffer(inds[ADX_14],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
      CopyBuffer(inds[ADX_14],1,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
      CopyBuffer(inds[ADX_14],2,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start+=3;
     }

   if(AMA_9_2_30!=-1)
     {
      CopyBuffer(inds[AMA_9_2_30],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start++;
     }

   if(ATR_14!=-1)
     {
      CopyBuffer(inds[ATR_14],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start++;
     }

   if(Bands_20_2!=-1)
     {
      CopyBuffer(inds[Bands_20_2],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start++;
     }

   if(BearsPower_13!=-1)
     {
      CopyBuffer(inds[BearsPower_13],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start++;
     }

   if(BullsPower_13!=-1)
     {
      CopyBuffer(inds[BullsPower_13],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start++;
     }

   if(CCI_14!=-1)
     {
      CopyBuffer(inds[CCI_14],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start++;
     }

   if(DeMarker_14!=-1)
     {
      CopyBuffer(inds[DeMarker_14],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start++;
     }

   if(DEMA_14!=-1)
     {
      CopyBuffer(inds[DEMA_14],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start++;
     }

   if(FrAMA_14!=-1)
     {
      CopyBuffer(inds[FrAMA_14],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start++;
     }

   if(MACD_12_26_9!=-1)
     {
      CopyBuffer(inds[MACD_12_26_9],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
      CopyBuffer(inds[MACD_12_26_9],1,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start+=2;
     }

   if(MA_10!=-1)
     {
      CopyBuffer(inds[MA_10],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start++;
     }

   if(RSI_14!=-1)
     {
      CopyBuffer(inds[RSI_14],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start++;
     }

   if(RVI_10!=-1)
     {
      CopyBuffer(inds[RVI_10],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
      CopyBuffer(inds[RVI_10],1,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start+=2;
     }

   if(Stochastic_5_3_3!=-1)
     {
      CopyBuffer(inds[Stochastic_5_3_3],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
      CopyBuffer(inds[Stochastic_5_3_3],1,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start+=2;
     }

   if(TEMA_14!=-1)
     {
      CopyBuffer(inds[TEMA_14],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start++;
     }

   if(TriX_14!=-1)
     {
      CopyBuffer(inds[TriX_14],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start++;
     }

   if(VIDyA_9_12!=-1)
     {
      CopyBuffer(inds[VIDyA_9_12],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start++;
     }

   if(WPR_14!=-1)
     {
      CopyBuffer(inds[WPR_14],0,newTime,2,indBuf);
      dp[start]=indBuf[p];   start++;
     }
   else
     {
      start++;
     }

   Debug("GetDate End");

   return;
  }
//+------------------------------------------------------------------+
