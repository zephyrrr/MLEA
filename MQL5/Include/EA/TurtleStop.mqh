//+------------------------------------------------------------------+
//|                                                   TurtleStop.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

#include <Expert\ExpertTrailing.mqh>
#include <Turtle\TurtleN.mqh>

// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Trailing Stop based on fixed Stop Level                    |
//| Type=Trailing                                                    |
//| Name=FixedPips                                                   |
//| Class=CTrailingFixedPips                                         |
//| Page=                                                            |
//| Parameter=StopLevel,int,30                                       |
//| Parameter=ProfitLevel,int,50                                     |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CTrailingFixedPips.                                        |
//| Appointment: Class traling stops with fixed in pips stop.        |
//|              Derives from class CExpertTrailing.                 |
//+------------------------------------------------------------------+
class CTurtleStop : public CExpertTrailing
{
private:
    CTurtleN* m_turtleN;
public:
                     CTurtleStop();
    void             Init(CTurtleN* turtleN) { m_turtleN = turtleN; }
    virtual bool      ValidationSettings();
  
    virtual bool      CheckTrailingStopLong(CPositionInfo* position,double& sl,double& tp);
    virtual bool      CheckTrailingStopShort(CPositionInfo* position,double& sl,double& tp);
};
//+------------------------------------------------------------------+
//| Constructor CTrailingFixedPips.                                  |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CTurtleStop::CTurtleStop()
  {
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if settings are correct, false otherwise.           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTurtleStop::ValidationSettings()
{
    if(!CExpertSignal::ValidationSettings()) 
        return(false);
    if(m_turtleN == NULL)
    {
        printf(__FUNCTION__+": TurtleN should not be Null!");
        return(false);
    }

    return(true);
}

//+------------------------------------------------------------------+
//| Checking trailing stop and/or profit for long position.          |
//| INPUT:  position - pointer for position object,                  |
//|         sl       - refernce for new stop loss,                   |
//|         tp       - refernce for new take profit.                 |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTurtleStop::CheckTrailingStopLong(CPositionInfo* position,double& sl,double& tp)
{
    sl = EMPTY_VALUE;
    tp = EMPTY_VALUE;
    
    if(position==NULL)  
        return(false);
        
    double base = m_turtleN.GetLastDealPrice(POSITION_TYPE_BUY);
    if (base == 0)
        return false;
    double pos_sl=position.StopLoss();
    
    sl = base - 2 * m_turtleN.N();
    
    if (MathAbs(sl - pos_sl) < m_symbol.Point())
        return false;
        
    //double price = m_symbol.Bid();
    //double delta= 2 * m_turtleN.N();
    //if(price-base>delta)
    //{
    //    sl=price-delta;
    //}
    //Print("Base price is ", base, " and N is ", m_turtleN.N());
    
    return true;
}
//+------------------------------------------------------------------+
//| Checking trailing stop and/or profit for short position.         |
//| INPUT:  position - pointer for position object,                  |
//|         sl       - refernce for new stop loss,                   |
//|         tp       - refernce for new take profit.                 |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTurtleStop::CheckTrailingStopShort(CPositionInfo* position,double& sl,double& tp)
{
    sl = EMPTY_VALUE;
    tp = EMPTY_VALUE;
    
    if(position==NULL)  
        return(false);
        
    double base = m_turtleN.GetLastDealPrice(POSITION_TYPE_SELL);
    if (base == 0)
        return false;
    double pos_sl=position.StopLoss();
    
    sl = base + 2 * m_turtleN.N();
    
    if (MathAbs(sl - pos_sl) < m_symbol.Point())
        return false;
        
    return true;
}
//+------------------------------------------------------------------+

