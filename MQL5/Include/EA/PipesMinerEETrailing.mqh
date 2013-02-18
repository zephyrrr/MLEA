//+------------------------------------------------------------------+
//|                                         PipesMinerEETrailing.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

#include <ExpertModel\ExpertModel.mqh>
#include <ExpertModel\ExpertModelTrailing.mqh>

#include <Trade\Trade.mqh>
 
class CPipesMinerEETrailing : public CExpertModelTrailing
{
private:

public:
                      CPipesMinerEETrailing();
    virtual bool      ValidationSettings();
    virtual bool      InitIndicators(CIndicators* indicators);
    
    virtual bool      CheckTrailingStopLong(CTableOrder* order,double& sl,double& tp);
    virtual bool      CheckTrailingStopShort(CTableOrder* order,double& sl,double& tp);
    
    void InitParameters();
};

void CPipesMinerEETrailing::CPipesMinerEETrailing()
{
}

bool CPipesMinerEETrailing::ValidationSettings()
{
    if (!CExpertModelTrailing::ValidationSettings())
        return false;
        
   return true;
}

void CPipesMinerEETrailing::InitParameters()
{
}

bool CPipesMinerEETrailing::InitIndicators(CIndicators* indicators)
{
    if(indicators==NULL) 
        return(false);
    bool ret = true;
    
    return ret;
}

bool CPipesMinerEETrailing::CheckTrailingStopLong(CTableOrder* order,double& sl,double& tp)
{
    sl = EMPTY_VALUE;
    tp = EMPTY_VALUE;
    
    if(order==NULL)  
        return(false);
    
    if ((sl != EMPTY_VALUE && sl != order.StopLoss())
        || (tp != EMPTY_VALUE && tp != order.TakeProfit()))
    {
        return true;
    }
    
    return false;
}

bool CPipesMinerEETrailing::CheckTrailingStopShort(CTableOrder* order,double& sl,double& tp)
{
    sl = EMPTY_VALUE;
    tp = EMPTY_VALUE;
    
    if(order==NULL)  
        return(false);
        
    if ((sl != EMPTY_VALUE && sl != order.StopLoss())
        || (tp != EMPTY_VALUE && tp != order.TakeProfit()))
    {
        return true;
    }
    return false;
}
//+------------------------------------------------------------------+

