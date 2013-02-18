//+------------------------------------------------------------------+
//|                                                    solutions.mqh |
//|                            Copyright 2010, Vasily Sokolov (C-4). |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, Vasily Sokolov (C-4)."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_TYPE_PRICE
  {
   MODE_OPEN,
   MODE_CLOSE,
   MODE_HIGH,
   MODE_LOW
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
   Find High value for N bars
   symbol - name of instrument for indicator calculation
   timeframe - timeframe for indicator calculation
   type - type of price (Open, Close, High, Low bar price)
   start - index of timeserias for begin calculation
   count - quantity elements
*/
double iHighest(string symbol,ENUM_TIMEFRAMES timeframe,ENUM_TYPE_PRICE type,int start=0,int count=WHOLE_ARRAY)
  {
   double      maximum=-1;
   MqlRates    raters[];
   int         size;
   if(count==WHOLE_ARRAY || Bars(symbol,timeframe)<start+count)
    count=Bars(symbol,timeframe)-start;
   if(count<=0)
    return(-1);
   CopyRates(symbol,timeframe,start,count,raters);
   size=ArraySize(raters);
   ArraySetAsSeries(raters,true);
   for(int i=0;i<size;i++)
     {
      switch(type)
        {
         case MODE_OPEN:
            if(raters[i].open>maximum)maximum=raters[i].open;
            break;
         case MODE_CLOSE:
            if(raters[i].close>maximum)maximum=raters[i].close;
            break;
         case MODE_HIGH:
            if(raters[i].high>maximum)maximum=raters[i].high;
            break;
         case MODE_LOW:
            if(raters[i].low>maximum)maximum=raters[i].low;
            break;
        }
     }
   return(maximum);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
   Find Low value for N bars
   symbol - name of instrument for indicator calculation
   timeframe - timeframe for indicator calculation
   type - type of price (Open, Close, High, Low bar price)
   start - index of timeserias for begin calculation
   count - quantity elements
*/
double iLowest(string symbol,ENUM_TIMEFRAMES timeframe,ENUM_TYPE_PRICE type,int start=0,int count=WHOLE_ARRAY)
  {
   double      minimum=DBL_MAX;
   MqlRates    raters[];
   int         size;
   if(count==WHOLE_ARRAY || Bars(symbol,timeframe)<start+count)count=Bars(symbol,timeframe)-start;
   if(count<=0)return(-1);
   CopyRates(symbol,timeframe,start,count,raters);
   size=ArraySize(raters);
   ArraySetAsSeries(raters,true);
   for(int i=0;i<size;i++)
     {
      switch(type)
        {
         case MODE_OPEN:
            if(raters[i].open<minimum)minimum=raters[i].open;
            break;
         case MODE_CLOSE:
            if(raters[i].close<minimum)minimum=raters[i].close;
            break;
         case MODE_HIGH:
            if(raters[i].high<minimum)minimum=raters[i].high;
            break;
         case MODE_LOW:
            if(raters[i].low<minimum)minimum=raters[i].low;
            break;
        }
     }
   if(minimum==DBL_MAX)minimum=-1;
   return(minimum);
  }
//+------------------------------------------------------------------+
