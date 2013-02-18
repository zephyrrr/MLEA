//+------------------------------------------------------------------+
//|                                                ZigzagPattern.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

long GetZigzagPattern(double &zigzagValues[], double &priceClose[], int lastDelta, double &zigzagValuesLatest[])
{
    int length = 5;
    double m_highLowDelta = 0.0005;
    int zigzagValuesCount = ArraySize(zigzagValuesLatest);
    //double zigzagValuesLatest[50];
    
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
            if (zigzagValuesLatest[i] >= zigzagValuesLatest[j] + m_highLowDelta)
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
            if (zigzagValuesLatest[i] <= zigzagValuesLatest[j] - m_highLowDelta)
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

string GetZigzagPatternLatest(double &zigzagValues[], double nowPrice, int lastDelta, double &zigzagValuesLatest[])
{
    double m_highLowDelta = 0.0005;
    //int zigzagValuesCount = 50;
    //double zigzagValuesLatest[50];
    int zigzagValuesCount = ArraySize(zigzagValuesLatest);
    
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
            if (zigzagValuesLatest[i] >= zigzagValuesLatest[j] + m_highLowDelta)
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
            if (zigzagValuesLatest[i] <= zigzagValuesLatest[j] - m_highLowDelta)
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
