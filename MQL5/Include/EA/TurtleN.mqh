//+------------------------------------------------------------------+
//|                                                      TurtleN.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

#include <Object.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Utils.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTurtleN : public CObject
{
private:
    double m_PDN;
    double m_N;
    double TR(int idx);
    CSymbolInfo*       m_symbol;                   // symbol info object
    ENUM_TIMEFRAMES   m_period;
    CAccountInfo m_account;
    
    COrderInfo m_order;
    CPositionInfo m_position;
    CDealInfo m_deal;
    long m_magic;
public:
    CTurtleN();
    ~CTurtleN();
    bool  Init(CSymbolInfo* symbol, ENUM_TIMEFRAMES period, long magic);
    CSymbolInfo* Symbol() { return GetPointer(m_symbol); }  
    ENUM_TIMEFRAMES Period() { return m_period; }
    double GetUnit();
    
    double GetPositionPrice(ENUM_POSITION_TYPE positionType);
    double GetPositionUnit(ENUM_POSITION_TYPE positionType);
    double GetLastDealPrice(ENUM_POSITION_TYPE positionType);
    int GetOrdersTotal(ENUM_POSITION_TYPE positionType);
    
public:
    double TR();
    double N();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTurtleN::CTurtleN()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTurtleN::~CTurtleN()
  {
  }
//+------------------------------------------------------------------+

bool CTurtleN::Init(CSymbolInfo* symbol,ENUM_TIMEFRAMES period, long magic)
{
    m_symbol = symbol;
    m_period = period;
    m_magic = magic;
    return true;
}

double CTurtleN::TR()
{
    return TR(1);
}

double CTurtleN::TR(int idx)
{ 
    double H = iHigh(m_symbol.Name(), m_period, idx);
    double L = iLow(m_symbol.Name(), m_period, idx);
    double PDC = iClose(m_symbol.Name(), m_period, idx + 1);
    return MathMax(MathMax(H - L, H - PDC), PDC - L);
}

double CTurtleN::N()
{
    int days = 20;
    if (m_PDN == 0) 
    {
        for (int i=0; i < days; i++) 
        {
            m_PDN += TR(i + 2);
        }
        m_PDN = m_PDN / days;
    }
    m_N = ((days - 1) * m_PDN + TR()) / days;
    if (isNewBar(m_symbol.Name(), m_period))
    {
        m_PDN = m_N;
    }
    //Print("m_PDN = ", m_PDN, ", N = ", m_N);
    
    return m_N;
 }
 
 //+------------------------------------------------------------------+
double CTurtleN::GetUnit()
{
    double n = N();
    double tickValue = m_symbol.TickValue();
    double point = m_symbol.Point();
    double lots = (0.01 * m_account.Balance()) / (n * tickValue) * point;
    lots = MathRound(lots / m_symbol.LotsStep()) * m_symbol.LotsStep();
    //if (lots*(1000*Ask)>AccountBalance()) { lots=AccountBalance()/(1000*Ask); lots=MathFloor(lots*10)/10; } 
    //if (lots>MaxLotsPerTrade) lots=MaxLotsPerTrade;
    lots = MathMax(lots, m_symbol.LotsMin());
    lots = MathMin(lots, m_symbol.LotsMax());
    
    //if (lots > 2)
    //{
        //Print("N = ", n, " tick = ", tickValue, " point = ", point, " balance = ", m_account.Balance());
    //}
    return (lots);
}

double CTurtleN::GetPositionPrice(ENUM_POSITION_TYPE positionType)
{
    m_position.Select(m_symbol.Name());
    if (m_position.Magic() == m_magic && m_position.PositionType() == positionType)
        return m_position.PriceOpen();
    else
        return 0;
}

double CTurtleN::GetPositionUnit(ENUM_POSITION_TYPE positionType)
{
    //m_position.Select(m_symbol.Name());
    //if (m_position.Magic() == m_magic && m_position.PositionType() == positionType)
    //    return MathRound(m_position.Volume() / GetUnit());
    //else
    //    return 0;
   
    int ret = 0;
    datetime from_date=0;         // from the very beginning
    datetime to_date=TimeCurrent();// till the current moment
    HistorySelect(from_date,to_date);
    int deals=HistoryDealsTotal();

    for(int i=deals-1; i>=0; --i)
    {
        m_deal.Ticket(HistoryDealGetTicket(i));
        if (m_deal.Entry() == DEAL_ENTRY_OUT)
        {
            //Print("Found Deal Out Entry at ", i, "!");
            return ret;
        }
        if (m_deal.Magic() == m_magic)
        {
            if (m_deal.Entry() == DEAL_ENTRY_IN)
            {
                if (positionType == POSITION_TYPE_BUY && m_deal.DealType() == DEAL_TYPE_BUY)
                    ret++;
                else if (positionType == POSITION_TYPE_SELL && m_deal.DealType() == DEAL_TYPE_SELL)
                    ret++;
            }
        }
    }
    return ret;
}

double CTurtleN::GetLastDealPrice(ENUM_POSITION_TYPE positionType)
{
    datetime from_date=0;         // from the very beginning
    datetime to_date=TimeCurrent();// till the current moment
    HistorySelect(from_date,to_date);
    int deals=HistoryDealsTotal();

    for(int i=deals-1; i>=0; --i)
    {
        m_deal.Ticket(HistoryDealGetTicket(i));
        if (m_deal.Entry() == DEAL_ENTRY_OUT)
        {
            return 0;
        }
        if (m_deal.Magic() == m_magic && m_deal.Entry() == DEAL_ENTRY_IN)
        {
            if (positionType == POSITION_TYPE_BUY && m_deal.DealType() == DEAL_TYPE_BUY)
                return m_deal.Price();
            else if (positionType == POSITION_TYPE_SELL && m_deal.DealType() == DEAL_TYPE_SELL)
                return m_deal.Price();
        }
    }
    return 0;
}

int CTurtleN::GetOrdersTotal(ENUM_POSITION_TYPE positionType)
{
    int ret = 0;
    int orderTotal = OrdersTotal();
    for(int i = orderTotal - 1; i>=0; --i)
    {
        m_order.SelectByIndex(i);
        if (m_order.Magic() == m_magic)
        {
            if (positionType == POSITION_TYPE_BUY && m_order.OrderType() == ORDER_TYPE_BUY)
                ret++;
            else if (positionType == POSITION_TYPE_SELL && m_order.OrderType() == ORDER_TYPE_SELL)
                ret++;
        }
    }
    return ret;
}
