//+------------------------------------------------------------------+
//|                                                 TurtleSignal.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#include <Expert\ExpertSignal.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Turtle\TurtleN.mqh>

// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals based on price crossover with MA                   |
//| Type=Signal                                                      |
//| Name=MA                                                          |
//| Class=CSignalMA                                                  |
//| Page=                                                            |
//| Parameter=Period,int,12                                          |
//| Parameter=Shift,int,0                                            |
//| Parameter=Method,ENUM_MA_METHOD,MODE_SMA                         |
//| Parameter=Applied,ENUM_APPLIED_PRICE,PRICE_CLOSE                 |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalMA.                                                 |
//| Appointment: Class trading signals cross price and MA.           |
//|              Derives from class CExpertSignal.                   |
//+------------------------------------------------------------------+
class CTurtleSignal : public CExpertSignal
  {
private:
    CTurtleN* m_turtleN;
    CSymbolInfo* m_symbol;

    ENUM_TIMEFRAMES   m_period; 
    double High[],Low[];
    double Highest(int spannedPeriod);
    double Lowest(int spannedPeriod);
    
    
    int m_entryType;
    int m_exitType;
public:
                     CTurtleSignal();
                    ~CTurtleSignal();
   void             Init(CTurtleN* turtleN) { m_turtleN = turtleN; m_symbol = turtleN.Symbol(); m_period = turtleN.Period(); }
   virtual bool      ValidationSettings();
   //---
   virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseLong(double& price);
   virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseShort(double& price);
  };
//+------------------------------------------------------------------+
//| Constructor CSignalMA.                                           |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CTurtleSignal::CTurtleSignal()
  {
    ArraySetAsSeries(High, true);
    ArraySetAsSeries(Low, true);
    m_entryType = 2;
    m_exitType = 2;
  }
//+------------------------------------------------------------------+
//| Destructor CSignalMA.                                            |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CTurtleSignal::~CTurtleSignal()
  {
//---
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if settings are correct, false otherwise.           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTurtleSignal::ValidationSettings()
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
//| Check conditions for long position open.                         |
//| INPUT:  price      - refernce for price,                         |
//|         sl         - refernce for stop loss,                     |
//|         tp         - refernce for take profit,                   |
//|         expiration - refernce for expiration.                    |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTurtleSignal::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
{
    //Info(__FUNCTION__);
    
    int nowOrders = m_turtleN.GetOrdersTotal(POSITION_TYPE_BUY);
    if (nowOrders > 0)
        return false;

    price=0.0;
    sl   =0.0;
    tp   =0.0;
   
    double openPrice = m_turtleN.GetLastDealPrice(POSITION_TYPE_BUY);
    if (openPrice == 0)
    {
        if (m_entryType == 1)
        {
            if (m_symbol.Bid() > Highest(20))
            {
                //Print("Signal Entry 1 Triggered!");
                
                sl = m_symbol.Bid() - 2 * m_turtleN.N();
                return true;
            }
        }
        else if (m_entryType == 2)
        {
            if (m_symbol.Bid() > Highest(55))
            {
                //Print("Signal Entry 2 Triggered!");
                
                sl = m_symbol.Bid() - 2 * m_turtleN.N();
                return true;
            }
        }
    }
    else
    {
        //int unit = GetUnit(POSITION_TYPE_BUY);
        if (m_symbol.Bid() - openPrice > 0.5 * m_turtleN.N())
        {
            //Print("openPrice is ", openPrice, " and N = ", 0.5 * m_turtleN.N(), " so Signal Append unit Triggered!");
            
            sl = m_symbol.Bid() - 2 * m_turtleN.N();
            return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Check conditions for short position open.                        |
//| INPUT:  price      - refernce for price,                         |
//|         sl         - refernce for stop loss,                     |
//|         tp         - refernce for take profit,                   |
//|         expiration - refernce for expiration.                    |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTurtleSignal::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
{
    int nowOrders = m_turtleN.GetOrdersTotal(POSITION_TYPE_SELL);
    if (nowOrders > 0)
        return false;

    price=0.0;
    sl   =0.0;
    tp   =0.0;
   
    double openPrice = m_turtleN.GetLastDealPrice(POSITION_TYPE_SELL);
    if (openPrice == 0)
    {
        if (m_entryType == 1)
        {
            if (m_symbol.Bid() < Lowest(20))
            {
                sl = m_symbol.Bid() + 2 * m_turtleN.N();
                return true;
            }
        }
        else if (m_entryType == 2)
        {
            if (m_symbol.Bid() < Lowest(55))
            {
                //Print("Signal Entry 2 Triggered!");
                
                sl = m_symbol.Bid() + 2 * m_turtleN.N();
                return true;
            }
        }
    }
    else
    {
        //int unit = GetUnit(POSITION_TYPE_BUY);
        if (m_symbol.Bid() - openPrice < -0.5 * m_turtleN.N())
        {
            //Print("openPrice is ", openPrice, " and N = ", 0.5 * m_turtleN.N(), " so Signal Append unit Triggered!");
            
            sl = m_symbol.Bid() + 2 * m_turtleN.N();
            return true;
        }
    }
    return false;
}
  
//+------------------------------------------------------------------+
//| Check conditions for long position close.                        |
//| INPUT:  price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTurtleSignal::CheckCloseLong(double& price)
{
    //Info(__FUNCTION__);
    price=0.0;
    
    if (m_exitType == 1)
    {
        //Print("Bid is ", m_symbol.Bid(), " and Lowest(10) is ", Lowest(10));
        if (m_symbol.Bid() < Lowest(10))
        {
            //Print("low than Lowest(10), Close it!");
            return true;
        }
    }
    else if (m_exitType == 2)
    {
        if (m_symbol.Bid() < Lowest(20))
            return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| Check conditions for short position close.                       |
//| INPUT:  price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTurtleSignal::CheckCloseShort(double& price)
{
    price=0.0;
    
    if (m_exitType == 1)
    {
        //Print("Bid is ", m_symbol.Bid(), " and Lowest(10) is ", Lowest(10));
        if (m_symbol.Bid() > Highest(10))
        {
            //Print("low than Lowest(10), Close it!");
            return true;
        }
    }
    else if (m_exitType == 2)
    {
        if (m_symbol.Bid() > Highest(20))
            return true;
    }
    return false;
}
//+------------------------------------------------------------------+

double CTurtleSignal::Highest(int spannedPeriod)
 { 
    double ret = 0;
    
    int copied = CopyHigh(m_symbol.Name(), m_period, 1, spannedPeriod, High);
    for (int i=0; i<spannedPeriod; i++) 
        ret = MathMax(ret, High[i]);

    return ret;
 }

double CTurtleSignal::Lowest(int spannedPeriod)
 { 
    double ret = DBL_MAX;
    
    int copied = CopyLow(m_symbol.Name(), m_period, 1, spannedPeriod, Low);
    for (int i=0; i<spannedPeriod; i++) 
        ret = MathMin(ret, Low[i]);

    return ret;
 }
