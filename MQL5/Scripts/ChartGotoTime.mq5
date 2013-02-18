//+------------------------------------------------------------------+
//|                                                ChartGotoTime.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
datetime goto = D'2000.02.24 05:31';
void OnStart()
  {
    datetime now = TimeCurrent();
    long chartId = ChartID();
    ChartSetInteger(chartId,CHART_AUTOSCROLL,false);
    ChartSetInteger(chartId,CHART_SHIFT,true);
    
    //int period = PeriodSeconds(ChartPeriod(chartId));
    //int shift = (int)((now - goto) / period * 256 / 365);
    int shift = Bars(Symbol(), Period(), goto, now);
    bool ret = ChartNavigate(chartId, CHART_END, -shift);
    //Print("Chart back to ", shift);
    
    if (!ret)
    {
        Print("Failed to goto time!");
        return;
    }
    ChartRedraw(chartId);
  }
//+------------------------------------------------------------------+
