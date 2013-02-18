//+------------------------------------------------------------------+
//|                                          ForexMoringTrailing.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

#include <ExpertModel\ExpertModel.mqh>
#include <ExpertModel\ExpertModelTrailing.mqh>

#include <Trade\Trade.mqh>
 
class CForexGrowthBotTrailing : public CExpertModelTrailing
{
private:
public:
                      CForexGrowthBotTrailing();
    virtual bool      ValidationSettings();
    virtual bool      InitIndicators(CIndicators* indicators);
    
    virtual bool      CheckTrailingStopLong(CTableOrder* order,double& sl,double& tp);
    virtual bool      CheckTrailingStopShort(CTableOrder* order,double& sl,double& tp);
    
    void InitParameters();
};

void CForexGrowthBotTrailing::CForexGrowthBotTrailing()
{
    InitParameters();
}

bool CForexGrowthBotTrailing::ValidationSettings()
{
    if (!CExpertModelTrailing::ValidationSettings())
        return false;
        
   return true;
}

void CForexGrowthBotTrailing::InitParameters()
{
}

bool CForexGrowthBotTrailing::InitIndicators(CIndicators* indicators)
{
    if(indicators==NULL) 
        return(false);
    bool ret = true;
    
    return ret;
}

bool CForexGrowthBotTrailing::CheckTrailingStopLong(CTableOrder* order,double& sl,double& tp)
{
    sl = EMPTY_VALUE;
    tp = EMPTY_VALUE;
    
    if(order==NULL)  
        return(false);
    
    return false;
}

bool CForexGrowthBotTrailing::CheckTrailingStopShort(CTableOrder* order,double& sl,double& tp)
{
    sl = EMPTY_VALUE;
    tp = EMPTY_VALUE;
    
    if(order==NULL)  
        return(false);
    
    return false;
}
//+------------------------------------------------------------------+

