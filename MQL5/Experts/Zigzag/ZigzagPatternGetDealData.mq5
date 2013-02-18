//+------------------------------------------------------------------+
//|                                        ZigzagPatternDataSave.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Indicators\Indicators.mqh>
#include <Files\FileTxt.mqh>

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
    
    ArraySetAsSeries(m_zigzagValues,true);
    ArraySetAsSeries(m_priceTime,true);
    ArraySetAsSeries(m_priceClose,true);
    
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
  
string m_lastP;
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
    if(CopyBuffer(m_indicatorZigzag, 0, 0, 1000,m_zigzagValues) < 0)
    {
        Print("Error copying Zigzag indicator buffer - error:",GetLastError());
        return;
    }
    if(CopyTime(_Symbol,_Period, 0, 10, m_priceTime) < 0)
    {
        Print("Error copying time - error:",GetLastError());
        return;
    }
    if(CopyClose(_Symbol,_Period, 0, 10, m_priceClose) < 0)
    {
        Print("Error copying close - error:",GetLastError());
        return;
    }
   
    string p = GetZigzagPatternLatest();
    if (p == m_lastP)
        return;
    if(PositionSelect(_Symbol))
        return;
            
    CSymbolInfo  m_Symbol;
    m_Symbol.Name(Symbol()); 
    m_Symbol.RefreshRates();
    double Points = m_Symbol.Point();
     
    double tp = m_Symbol.Ask() + (Points * 700);
    double sl = m_Symbol.Bid() - (Points * 350);
    
    CTrade            m_Trade;
    m_Trade.SetDeviationInPoints(30);
    m_Trade.Buy(0.01, _Symbol, m_Symbol.Ask(), sl, tp, p);
    m_lastP = p;
  }
//+------------------------------------------------------------------+

int m_indicatorZigzag;
double m_zigzagValues[];
datetime m_priceTime[];
double m_priceClose[];

long GetZigzagPattern()
{
    int length = 5;
    double m_highLowDelta = 0.0005;
    int zigzagValuesCount = 50;
    double zigzagValues[50];
    
    int lastZigzag = 0;
    for(int i=0; i<ArraySize(m_zigzagValues); ++i)
    {
        if (m_zigzagValues[i] != 0)
        {
            lastZigzag = i;
            break;
        }
    }
    
    if (lastZigzag > 3)
    {
        int n = zigzagValuesCount - 2;
        for(int i=0; i<ArraySize(m_zigzagValues); ++i)
        {
            if (m_zigzagValues[i] != 0)
            {
                zigzagValues[n] = m_zigzagValues[i];
                n--;
                if (n < 0)
                    break;
            }
        }
        zigzagValues[zigzagValuesCount - 1] = m_priceClose[0];
    }
    else
    {
        int n = zigzagValuesCount - 1;
        for(int i=0; i<ArraySize(m_zigzagValues); ++i)
        {
            if (m_zigzagValues[i] != 0)
            {
                zigzagValues[n] = m_zigzagValues[i];
                n--;
                if (n < 0)
                    break;
            }
        }
    }
    
    //for(int i=0; i<zigzagValuesCount; ++i)
    //{
        //Print("Z ", i, " = ", zigzagValues[i]);
    //}
    
    int start = zigzagValuesCount - 2 * length - 2;

    bool firstHigh = true;
    if (zigzagValues[start] < zigzagValues[start + 1])
        firstHigh = false;
    bool lastLow = true;
    if (zigzagValues[zigzagValuesCount - 1] > zigzagValues[zigzagValuesCount - 2])
        lastLow = false;
                
    int highStart = firstHigh ? start : start + 1;
    int highLowCount[50];
    
    for (int i = highStart; i < zigzagValuesCount; i += 2)
    {
        int n = 0;
        for (int j = i - 2; j >= 0; j -= 2)
        {
            if (zigzagValues[i] >= zigzagValues[j] + m_highLowDelta)
                n++;
            else
                break;
        }
        if (n >= 10)
            n = 9;

        highLowCount[i] = n;
    }

    int lowStart = firstHigh ? start + 1 : start;
    for (int i = lowStart; i < zigzagValuesCount; i += 2)
    {
        int n = 0;
        for (int j = i - 2; j >= 0; j -= 2)
        {
            if (zigzagValues[i] <= zigzagValues[j] - m_highLowDelta)
                n++;
            else
                break;
        }
        if (n >= 10)
            n = 9;

        highLowCount[i] = n;
    }
    
    long ret = 0;
    long ret1 = 0, ret2 = 0;
    
    // last is low
    //if (lastLow)
    {
        int i = 2 * length + lowStart;

        long n = 0;
        
        for (int j = 0; j < length; ++j)
        {
            n += highLowCount[i - 2 * j] * (int)MathPow(10, length - j - 1);
        }
        ret1 = n;
    }
    //else
    {
        int i = 2 * length + highStart;

        long n = 0;
        for (int j = 0; j < length; ++j)
        {
            n += highLowCount[i - 2 * j] * (int)MathPow(10, length - j - 1);
        }

        n *= 100000;
        ret2 = n;
    }

    ret = ret1 + ret2;
    //Print(TimeToString(m_priceTime[0]), " Get Pattern of ", IntegerToString(ret), " lastLow = ", lastLow,
    //    " highStart = ", highStart, " lowStart = ", lowStart, " ret1 = ", ret1, " ret2 = ", ret2);
    return ret;
}

string GetZigzagPatternLatest()
{
    double m_highLowDelta = 0.0005;
    int zigzagValuesCount = 50;
    double zigzagValues[50];
    
    int lastZigzag = 0;
    for(int i=0; i<ArraySize(m_zigzagValues); ++i)
    {
        if (m_zigzagValues[i] != 0)
        {
            lastZigzag = i;
            break;
        }
    }
    
    if (lastZigzag > 3)
    {
        int n = zigzagValuesCount - 2;
        for(int i=0; i<ArraySize(m_zigzagValues); ++i)
        {
            if (m_zigzagValues[i] != 0)
            {
                zigzagValues[n] = m_zigzagValues[i];
                n--;
                if (n < 0)
                    break;
            }
        }
        zigzagValues[zigzagValuesCount - 1] = m_priceClose[0];
    }
    else
    {
        int n = zigzagValuesCount - 1;
        for(int i=0; i<ArraySize(m_zigzagValues); ++i)
        {
            if (m_zigzagValues[i] != 0)
            {
                zigzagValues[n] = m_zigzagValues[i];
                n--;
                if (n < 0)
                    break;
            }
        }
    }
    
    bool lastLow = true;
    if (zigzagValues[zigzagValuesCount - 1] > zigzagValues[zigzagValuesCount - 2])
        lastLow = false;
    
    long ret1 = 0, ret2 = 0;
    
    int i = lastLow ? zigzagValuesCount - 2 : zigzagValuesCount - 1;
    {
        int n = 0;
        for (int j = i - 2; j >= 0; j -= 2)
        {
            if (zigzagValues[i] >= zigzagValues[j] + m_highLowDelta)
                n++;
            else
                break;
        }
        ret1 = n;
    }

    i = lastLow ? zigzagValuesCount - 1 : zigzagValuesCount - 2;
    {
        int n = 0;
        for (int j = i - 2; j >= 0; j -= 2)
        {
            if (zigzagValues[i] <= zigzagValues[j] - m_highLowDelta)
                n++;
            else
                break;
        }
        ret2 = n;
    }
    
    string ret = IntegerToString(ret1) + "," + IntegerToString(ret2);
    //Print(TimeToString(m_priceTime[0]), " Get Pattern of ", IntegerToString(ret), " lastLow = ", lastLow,
    //    " highStart = ", highStart, " lowStart = ", lowStart, " ret1 = ", ret1, " ret2 = ", ret2);
    return ret;
}
