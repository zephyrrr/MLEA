//+------------------------------------------------------------------+
//|                                                 20-200Signal.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

#include <ExpertModel\ExpertModel.mqh>
#include <ExpertModel\ExpertModelSignal.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\DealInfo.mqh>

#include <Indicators\Oscilators.mqh>
 #include <Indicators\TimeSeries.mqh>
 

class C20200Signal : public CExpertModelSignal
  {
private:
    CiATR m_iATR;
    CiOpen m_iOpen;
    
    int GetSignal();
    
    int m_signal;
    bool m_canTrade;
    int m_tradeTime;
    int t1, t2;
    int delta;
    int TakeProfit;
    int StopLoss;

    //double m_Open[];
     
    CPositionInfo m_positionInfo;
public:
                     C20200Signal();
                    ~C20200Signal();
   virtual bool      ValidationSettings();
   virtual bool      InitIndicators(CIndicators* indicators);
   
   virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseLong(CTableOrder* t, double& price);
   virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseShort(CTableOrder* t, double& price);
   
   void InitParameters();
  };

void C20200Signal::InitParameters()
{
    m_signal = 0;
    m_canTrade = true;
    m_tradeTime = 18;
    t1 = 7;
    t2 = 2;
    delta = 70;
    TakeProfit = 200;
    StopLoss = 2000;
}

bool C20200Signal::InitIndicators(CIndicators* indicators)
{
    if(indicators==NULL) 
        return(false);
    bool ret = true;
        
    ret &= m_iATR.Create(m_symbol.Name(), PERIOD_D1, 14);
    ret &= m_iOpen.Create(m_symbol.Name(), m_period);
    
    ret &= indicators.Add(GetPointer(m_iATR));
    ret &= indicators.Add(GetPointer(m_iOpen));
    
    return ret;
}


void C20200Signal::C20200Signal()
{
    
}

void C20200Signal::~C20200Signal()
{
}
bool C20200Signal::ValidationSettings()
{
    if(!CExpertSignal::ValidationSettings()) 
        return(false);
    
    /*if(m_iATR.Handle() == -1)
    {
        printf(__FUNCTION__+": Indicators should not be Null!");
        return(false);
    }*/
   return(true);
}


int C20200Signal::GetSignal() 
{
    CExpertModel* em = (CExpertModel *)m_expert;
    if (em.GetOrderCount(ORDER_TYPE_BUY) >= 1 
        || em.GetOrderCount(ORDER_TYPE_SELL) >= 1 )
        return 0;
        
    datetime now = TimeCurrent();
    MqlDateTime m_dtStruct;
    TimeToStruct(now, m_dtStruct);
    if (m_dtStruct.hour > m_tradeTime)
    {
        m_canTrade = true;
    }
    
    int hour = m_dtStruct.hour - GetCETOffset();
    if (m_dtStruct.hour == m_tradeTime && m_dtStruct.min >= 0 && m_canTrade)
    {
        int len;
        if (t1>=t2)
            len=t1+1; //t1 ?t2 - bar indexes, get the largest value
        else 
            len=t2+1;       //and add 1 (for zeroth bar)
            
        m_iOpen.Refresh(-1);
        //CopyOpen(m_symbol.Name(), m_period, 0, len, m_Open);//filling the Open[] array with current values
        
        if(m_iOpen.GetData(t1) > (m_iOpen.GetData(t2) + delta * m_symbol.Point()))  //check sell conditions
        {              
            //Print("Sell");
            m_canTrade=false; // reset flag (disable trading until the next day);
            return -1;
        }
        else if((m_iOpen.GetData(t1) + delta * m_symbol.Point()) < m_iOpen.GetData(t2))//check buy conditions
        {            
            //Print("Buy");
            m_canTrade=false; // reset flag (disable trading until the next day);    
            return 1;
        }
    }
    return 0;
}


bool C20200Signal::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
{
    m_signal = GetSignal();
    
    if (m_signal > 0)
    {
        m_iATR.Refresh(-1);
        double atr = m_iATR.Main(1);
        //StopLoss = (int)((2 * atr) / m_symbol.Point());
        
        price = m_symbol.Ask();
        tp = price + TakeProfit * m_symbol.Point();
        sl = price - StopLoss * m_symbol.Point();
        
        return true;
    }

    return false;
}

bool C20200Signal::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
{
    if (m_signal < 0)
    {
        m_iATR.Refresh(-1);
        double atr = m_iATR.Main(1);
        //StopLoss= (int)(2 * atr / m_symbol.Point());
        
        price = m_symbol.Bid();
        tp = price - TakeProfit * m_symbol.Point();
        sl = price + StopLoss * m_symbol.Point();
        
        return true;
    }

    return false;
}
 
bool C20200Signal::CheckCloseLong(CTableOrder* t, double& price)
{
    return false;
}

bool C20200Signal::CheckCloseShort(CTableOrder* t, double& price)
{
    return false;
}
