//+------------------------------------------------------------------+
//|                                          CZigzagPatternValue.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                              Revision 2010.02.08 |
//+------------------------------------------------------------------+

#include <Object.mqh>

#define ZIGZAG_INDICATOR_COUNT 1000
#define ZIGZAG_COUNT 50

class CZigzagPatternValue : public CObject
{
    private:
        int m_indicatorZigzag;
        double m_zigzagValues[ZIGZAG_INDICATOR_COUNT];
        MqlTick m_mqlTick;
        double m_zigzagValuesLatest[2 * ZIGZAG_COUNT];
    private:
        bool RefreshZigzag();
        string GetZigzagPatternLatest(double &zigzagValues[], double nowPrice, int lastDelta, double &zigzagValuesLatest[]);
        long GetZigzagPattern(double &zigzagValues[], double &priceClose[], int lastDelta, double &zigzagValuesLatest[]);
    public:
        bool Init();
        bool Deinit();
        string GetZigzagPatternLatest();
        string GetZigzagPatternLatest(double &zigzagValuesLatest[]);
};


bool CZigzagPatternValue::Init()
{
    m_indicatorZigzag=iCustom(Symbol(), Period(), "Examples\\Zigzag");
    if(m_indicatorZigzag < 0)
    {
        Alert("Error Creating Handles for indicators - error: ", GetLastError(), "!");
        return false;
    }
    bool ret = ArraySetAsSeries(m_zigzagValues, true);

    return true;
}

bool CZigzagPatternValue::Deinit()
{
    if(m_indicatorZigzag!=-1)
    {
        IndicatorRelease(m_indicatorZigzag);
    }
    return true;
}

bool CZigzagPatternValue::RefreshZigzag()
{
    double zigzagValues[ZIGZAG_INDICATOR_COUNT];
    if(CopyBuffer(m_indicatorZigzag, 0, 0, ZIGZAG_INDICATOR_COUNT, zigzagValues) < 0)
    {
        Print("Error copying Zigzag indicator buffer - error:", GetLastError());
        return false;
    }
    for(int i=0; i<ZIGZAG_INDICATOR_COUNT; ++i)
    {
        m_zigzagValues[i] = zigzagValues[ZIGZAG_INDICATOR_COUNT - 1 - i];
    }
    
    //if (StringSubstr(TimeToString(TimeCurrent()), 0, 16) == "2000.09.20 04:07")
    //{
    //    for(int i=0; i<ZIGZAG_INDICATOR_COUNT; ++i)
    //        Print(m_zigzagValues[i]);
    //}
    
    SymbolInfoTick(Symbol(), m_mqlTick);
    
    return true;
}

string CZigzagPatternValue::GetZigzagPatternLatest()
{
    return GetZigzagPatternLatest(m_zigzagValuesLatest);
}

string CZigzagPatternValue::GetZigzagPatternLatest(double &zigzagValuesLatest[])
{
    RefreshZigzag();
    
    return GetZigzagPatternLatest(m_zigzagValues, m_mqlTick.bid, 12, zigzagValuesLatest);
}


long CZigzagPatternValue::GetZigzagPattern(double &zigzagValues[], double &priceClose[], int lastDelta, double &zigzagValuesLatest[])
{
    int length = 5;
    double m_highLowDelta = 0.0005;
    int zigzagValuesCount = ArraySize(zigzagValuesLatest);
    for(int i=0; i<zigzagValuesCount; ++i)
    {
        zigzagValuesLatest[i] = 0;
    }
    
    int lastZigzag = 0;
    for(int i=0; i<ArraySize(zigzagValues); ++i)
    {
        if (zigzagValues[i] != 0)
        {
            lastZigzag = i;
            break;
        }
    }
    
    if (lastZigzag > lastDelta)
    {
        int n = zigzagValuesCount - 2;
        for(int i=0; i<ArraySize(zigzagValues); ++i)
        {
            if (zigzagValues[i] != 0)
            {
                zigzagValuesLatest[n] = zigzagValues[i];
                n--;
                if (n < 0)
                    break;
            }
        }
        zigzagValuesLatest[zigzagValuesCount - 1] = priceClose[0];
    }
    else
    {
        int n = zigzagValuesCount - 1;
        for(int i=0; i<ArraySize(zigzagValues); ++i)
        {
            if (zigzagValues[i] != 0)
            {
                zigzagValuesLatest[n] = zigzagValues[i];
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
    if (zigzagValuesLatest[start] < zigzagValuesLatest[start + 1])
        firstHigh = false;
    bool lastLow = true;
    if (zigzagValuesLatest[zigzagValuesCount - 1] > zigzagValuesLatest[zigzagValuesCount - 2])
        lastLow = false;
                
    int highStart = firstHigh ? start : start + 1;
    int highLowCount[50];
    
    for (int i = highStart; i < zigzagValuesCount; i += 2)
    {
        int n = 0;
        for (int j = i - 2; j >= 0; j -= 2)
        {
            if (zigzagValuesLatest[j] != 0
                && zigzagValuesLatest[i] >= zigzagValuesLatest[j] + m_highLowDelta)
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
            if (zigzagValuesLatest[j] != 0
                && zigzagValuesLatest[i] <= zigzagValuesLatest[j] - m_highLowDelta)
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

string CZigzagPatternValue::GetZigzagPatternLatest(double &zigzagValues[], double nowPrice, int lastDelta, double &zigzagValuesLatest[])
{
    double m_highLowDelta = 0.0005;
    int zigzagValuesCount = ArraySize(zigzagValuesLatest);
    for(int i=0; i<zigzagValuesCount; ++i)
    {
        zigzagValuesLatest[i] = 0;
    }
    
    int lastZigzag = 0;
    for(int i=0; i<ArraySize(zigzagValues); ++i)
    {
        if (zigzagValues[i] != 0)
        {
            lastZigzag = i;
            break;
        }
    }
    
    if (lastZigzag > lastDelta)
    {
        int n = zigzagValuesCount - 2;
        for(int i=0; i<ArraySize(zigzagValues); ++i)
        {
            if (zigzagValues[i] != 0)
            {
                zigzagValuesLatest[n] = zigzagValues[i];
                n--;
                if (n < 0)
                    break;
            }
        }
        zigzagValuesLatest[zigzagValuesCount - 1] = nowPrice;
    }
    else
    {
        int n = zigzagValuesCount - 1;
        for(int i=0; i<ArraySize(zigzagValues); ++i)
        {
            if (zigzagValues[i] != 0)
            {
                zigzagValuesLatest[n] = zigzagValues[i];
                n--;
                if (n < 0)
                    break;
            }
        }
    }
    
    bool lastLow = true;
    
    int delta = 1;
    while(true)
    {
        if (zigzagValuesLatest[zigzagValuesCount - delta] > zigzagValuesLatest[zigzagValuesCount - delta - 1])
        {
            lastLow = false;
            break;
        }
        else  if (zigzagValuesLatest[zigzagValuesCount - delta] < zigzagValuesLatest[zigzagValuesCount - delta - 1]) 
        {
            lastLow = true;
            break;
        }
        else
        {
            delta += 2;
        }
    }
    
    long ret1 = 0, ret2 = 0;
    
    int i = lastLow ? zigzagValuesCount - 2 : zigzagValuesCount - 1;
    {
        int n = 0;
        for (int j = i - 2; j >= 0; j -= 2)
        {
            if (zigzagValuesLatest[j] != 0 
                && zigzagValuesLatest[i] >= zigzagValuesLatest[j] + m_highLowDelta)
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
            if (zigzagValuesLatest[j] != 0 
                && zigzagValuesLatest[i] <= zigzagValuesLatest[j] - m_highLowDelta)
                n++;
            else
                break;
        }
        ret2 = n;
    }
    
    string ret = (lastLow ? "L," : "H,") + IntegerToString(ret1) + "," + IntegerToString(ret2);
    //Print(TimeToString(m_priceTime[0]), " Get Pattern of ", IntegerToString(ret), " lastLow = ", lastLow,
    //    " highStart = ", highStart, " lowStart = ", lowStart, " ret1 = ", ret1, " ret2 = ", ret2);
    
    
    
    return ret;
}
