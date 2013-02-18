//+------------------------------------------------------------------+
//|                                                        MCSpy.mq5 |
//|                                    Copyright 2011, EarnForex.com |
//|                                     http://www.earnforex.com.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, EarnForex.com"
#property link      "http://www.earnforex.com.com"
#property version   "1.00"
#property description "Generates chart events for multi-currency EA."

#property indicator_chart_window

input long chart_id = 0;
input ushort custom_event_id = 0;

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   EventChartCustom(chart_id, custom_event_id, (long)_Period, price[rates_total - 1], _Symbol);   
   return(rates_total);
}

//+------------------------------------------------------------------+
