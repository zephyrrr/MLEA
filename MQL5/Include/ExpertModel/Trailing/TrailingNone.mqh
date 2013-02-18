//+------------------------------------------------------------------+
//|                                      TrailingNone.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

#include <ExpertModel\ExpertModel.mqh>
#include <ExpertModel\ExpertModelTrailing.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
 
class CTrailingNone : public CExpertModelTrailing
{
public:
    virtual bool      CheckTrailingStopLong(CTableOrder* order,double& sl,double& tp)  { return (false); }
    virtual bool      CheckTrailingStopShort(CTableOrder* order,double& sl,double& tp)  { return (false); }
};


