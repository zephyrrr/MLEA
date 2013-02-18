//+------------------------------------------------------------------+
//|                                                   Indicators.mqh |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Trend.mqh"
#include "Oscilators.mqh"
#include "Volumes.mqh"
#include "BillWilliams.mqh"
#include "Custom.mqh"
#include "TimeSeries.mqh"
//+------------------------------------------------------------------+
//| Class CIndicators.                                               |
//| Purpose: Class for creation of collection of instances of        |
//|          technical indicators.                                   |
//+------------------------------------------------------------------+
class CIndicators : public CArrayObj
  {
protected:
   MqlDateTime       m_prev_time;

public:
                     CIndicators(void);
                    ~CIndicators(void);
   //--- method for creation
   CIndicator*       Create(const string symbol,const ENUM_TIMEFRAMES period,
                            const ENUM_INDICATOR type,const int count,const MqlParam& params[]);
   bool              BufferResize(const int size);
   //--- method of refreshing of the data of all indicators in the collection
   int               Refresh(void);
protected:
   //--- method of formation of flags timeframes
   int               TimeframesFlags(const MqlDateTime& time);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CIndicators::CIndicators(void)
  {
   m_prev_time.min=-1;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CIndicators::~CIndicators(void)
  {
  }
//+------------------------------------------------------------------+
//| Indicator creation.                                              |
//+------------------------------------------------------------------+
CIndicator *CIndicators::Create(const string symbol,const ENUM_TIMEFRAMES period,
                                const ENUM_INDICATOR type,const int count,const MqlParam& params[])
  {
   CIndicator *result=NULL;
//---
   switch(type)
     {
      //--- Identifier of "Accelerator Oscillator"
      case IND_AC:
         if(count!=0) break;
         result=new CiAC;
         break;
      //--- Identifier of "Accumulation/Distribution"
      case IND_AD:
         if(count!=1) break;
         result=new CiAD;
         break;
      //--- Identifier of "Alligator"
      case IND_ALLIGATOR:
         if(count!=8) break;
         result=new CiAlligator;
         break;
      //--- Identifier of "Average Directional Index"
      case IND_ADX:
         if(count!=1) break;
         result=new CiADX;
         break;
      //--- Identifier of "Average Directional Index by Welles Wilder"
      case IND_ADXW:
         if(count!=1) break;
         result=new CiADXWilder;
         break;
      //--- Identifier of "Average True Range"
      case IND_ATR:
         if(count!=1) break;
         result=new CiATR;
         break;
      //--- Identifier of "Awesome Oscillator"
      case IND_AO:
         if(count!=0) break;
         result=new CiAO;
         break;
      //--- Identifier of "Bears Power"
      case IND_BEARS:
         if(count!=1) break;
         result=new CiBearsPower;
         break;
      //--- Identifier of "Bollinger Bands"
      case IND_BANDS:
         if(count!=4) break;
         result=new CiBands;
         break;
      //--- Identifier of "Bulls Power"
      case IND_BULLS:
         if(count!=1) break;
         result=new CiBullsPower;
         break;
      //--- Identifier of "Commodity Channel Index"
      case IND_CCI:
         if(count!=2) break;
         result=new CiCCI;
         break;
      //--- Identifier of "Chaikin Oscillator"
      case IND_CHAIKIN:
         if(count!=4) break;
         result=new CiChaikin;
         break;
      //--- Identifier of "DeMarker"
      case IND_DEMARKER:
         if(count!=1) break;
         result=new CiDeMarker;
         break;
      //--- Identifier of "Envelopes"
      case IND_ENVELOPES:
         if(count!=5) break;
         result=new CiEnvelopes;
         break;
      //--- Identifier of "Force Index"
      case IND_FORCE:
         if(count!=3) break;
         result=new CiForce;
         break;
      //--- Identifier of "Fractals"
      case IND_FRACTALS:
         if(count!=0) break;
         result=new CiFractals;
         break;
      //--- Identifier of "Gator oscillator"
      case IND_GATOR:
         if(count!=8) break;
         result=new CiGator;
         break;
      //--- Identifier of "Ichimoku Kinko Hyo"
      case IND_ICHIMOKU:
         if(count!=3) break;
         result=new CiIchimoku;
         break;
      //--- Identifier of "Moving Averages Convergence-Divergence"
      case IND_MACD:
         if(count!=4) break;
         result=new CiMACD;
         break;
      //--- Identifier of "Market Facilitation Index by Bill Williams"
      case IND_BWMFI:
         if(count!=1) break;
         result=new CiBWMFI;
         break;
      //--- Identifier of "Momentum"
      case IND_MOMENTUM:
         if(count!=2) break;
         result=new CiMomentum;
         break;
      //--- Identifier of "Money Flow Index"
      case IND_MFI:
         if(count!=2) break;
         result=new CiMFI;
         break;
      //--- Identifier of "Moving Average"
      case IND_MA:
         if(count!=4) break;
         result=new CiMA;
         break;
      //--- Identifier of "Moving Average of Oscillator (MACD histogram)"
      case IND_OSMA:
         if(count!=4) break;
         result=new CiOsMA;
         break;
      //--- Identifier of "On Balance Volume"
      case IND_OBV:
         if(count!=1) break;
         result=new CiOBV;
         break;
      //--- Identifier of "Parabolic Stop And Reverse System"
      case IND_SAR:
         if(count!=2) break;
         result=new CiSAR;
         break;
      //--- Identifier of "Relative Strength Index"
      case IND_RSI:
         if(count!=2) break;
         result=new CiRSI;
         break;
      //--- Identifier of "Relative Vigor Index"
      case IND_RVI:
         if(count!=1) break;
         result=new CiRVI;
         break;
      //--- Identifier of "Standard Deviation"
      case IND_STDDEV:
         if(count!=4) break;
         result=new CiStdDev;
         break;
      //--- Identifier of "Stochastic Oscillator"
      case IND_STOCHASTIC:
         if(count!=5) break;
         result=new CiStochastic;
         break;
      //--- Identifier of "Williams' Percent Range"
      case IND_WPR:
         if(count!=1) break;
         result=new CiWPR;
         break;
      //--- Identifier of "Double Exponential Moving Average"
      case IND_DEMA:
         if(count!=3) break;
         result=new CiDEMA;
         break;
      //--- Identifier of "Triple Exponential Moving Average"
      case IND_TEMA:
         if(count!=3) break;
         result=new CiTEMA;
         break;
      //--- Identifier of "Triple Exponential Moving Averages Oscillator"
      case IND_TRIX:
         if(count!=2) break;
         result=new CiTriX;
         break;
      //--- Identifier of "Fractal Adaptive Moving Average"
      case IND_FRAMA:
         if(count!=3) break;
         result=new CiFrAMA;
         break;
      //--- Identifier of "Adaptive Moving Average"
      case IND_AMA:
         if(count!=5) break;
         result=new CiAMA;
         break;
      //--- Identifier of "Variable Index DYnamic Average"
      case IND_VIDYA:
         if(count!=4) break;
         result=new CiVIDyA;
         break;
      //--- Identifier of "Volumes"
      case IND_VOLUMES:
         if(count!=1) break;
         result=new CiVolumes;
         break;
      //--- Identifier of "Custom"
      case IND_CUSTOM:
         if(count<=0) break;
         result=new CiCustom;
         break;
     }
   if(result!=NULL)
     {
      if(result.Create(symbol,period,type,count,params))
         Add(result);
      else
        {
         delete result;
         result=NULL;
        }
     }
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Set size of buffers of all indicators in the collection.         |
//+------------------------------------------------------------------+
bool CIndicators::BufferResize(const int size)
  {
   int total=Total();
   for(int i=0;i<total;i++)
     {
      CSeries *series=At(i);
      //--- check pointer
      if(series==NULL)               return(false);
      if(!series.BufferResize(size)) return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Refreshing of the data of all indicators in the collection.      |
//+------------------------------------------------------------------+
int CIndicators::Refresh(void)
  {
   MqlDateTime time;
   TimeCurrent(time);
//---
   int flags=TimeframesFlags(time);
   int total=Total();
//---
   for(int i=0;i<total;i++)
     {
      CSeries *indicator=At(i);
      if(indicator!=NULL) indicator.Refresh(flags);
     }
//---
   m_prev_time=time;
//---
   return(flags);
  }
//+------------------------------------------------------------------+
//| Formation of timeframe flags.                                    |
//+------------------------------------------------------------------+
int CIndicators::TimeframesFlags(const MqlDateTime& time)
  {
//--- set flags for all timeframes
   int   result=OBJ_ALL_PERIODS;
//--- if first check, then setting flags all timeframes
   if(m_prev_time.min==-1)       return(result);
//--- check change time
   if(time.min==m_prev_time.min &&
      time.hour==m_prev_time.hour &&
      time.day==m_prev_time.day &&
      time.mon==m_prev_time.mon) return(OBJ_NO_PERIODS);
//--- new month?
   if(time.mon!=m_prev_time.mon) return(result);
//--- reset the "new month" flag
   result^=OBJ_PERIOD_MN1;
//--- new day?
   if(time.day!=m_prev_time.day) return(result);
//--- reset the "new day" and "new week" flags
   result^=OBJ_PERIOD_D1+OBJ_PERIOD_W1;
//--- temporary variables to speed up working with structures
   int last,curr;
//--- new hour?
   curr=time.hour;
   last=m_prev_time.hour;
   if(curr!=last)
     {
      if(curr%2!=0  && curr-last<2)      result^=OBJ_PERIOD_H2;
      if(curr%3!=0  && curr-last<3)      result^=OBJ_PERIOD_H3;
      if(curr%4!=0  && curr-last<4)      result^=OBJ_PERIOD_H4;
      if(curr%6!=0  && curr-last<6)      result^=OBJ_PERIOD_H6;
      if(curr%8!=0  && curr-last<8)      result^=OBJ_PERIOD_H8;
      if(curr%12!=0 && curr-last<12)     result^=OBJ_PERIOD_H12;
      return(result);
     }
//--- reset all flags for hour timeframes
   result^=OBJ_PERIOD_H1+OBJ_PERIOD_H2+OBJ_PERIOD_H3+OBJ_PERIOD_H4+OBJ_PERIOD_H6+OBJ_PERIOD_H8+OBJ_PERIOD_H12;
//--- new minute?
   curr=time.min;
   last=m_prev_time.min;
   if(curr!=last)
     {
      if(curr%2!=0  && curr-last<2)       result^=OBJ_PERIOD_M2;
      if(curr%3!=0  && curr-last<3)       result^=OBJ_PERIOD_M3;
      if(curr%4!=0  && curr-last<4)       result^=OBJ_PERIOD_M4;
      if(curr%5!=0  && curr-last<5)       result^=OBJ_PERIOD_M5;
      if(curr%6!=0  && curr-last<6)       result^=OBJ_PERIOD_M6;
      if(curr%10!=0 && curr-last<10)      result^=OBJ_PERIOD_M10;
      if(curr%12!=0 && curr-last<12)      result^=OBJ_PERIOD_M12;
      if(curr%15!=0 && curr-last<15)      result^=OBJ_PERIOD_M15;
      if(curr%20!=0 && curr-last<20)      result^=OBJ_PERIOD_M20;
      if(curr%30!=0 && curr-last<30)      result^=OBJ_PERIOD_M30;
     }
//---
   return(result);
  }
//+------------------------------------------------------------------+
