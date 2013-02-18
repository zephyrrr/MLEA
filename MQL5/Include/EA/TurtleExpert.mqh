//+------------------------------------------------------------------+
//|                                                 TurtleExpert.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Expert\Expert.mqh>
#include <Utils.mqh>
#include <Turtle\TurtleN.mqh>
#include <Turtle\TurtleSignal.mqh>
#include <Turtle\TurtleMoney.mqh>
#include <Turtle\TurtleStop.mqh>

#include <Turtle\AllSignal.mqh>
#include <Expert\Trailing\TrailingNone.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTurtleExpert : public CExpert
{
private:
    CTurtleN m_turtleN;
public:
                     CTurtleExpert();
                    ~CTurtleExpert();
    virtual bool      InitSignal(CExpertSignal* signal=NULL);
    virtual bool      InitTrailing(CExpertTrailing* trailing=NULL);
    virtual bool      InitMoney(CExpertMoney* money=NULL);
protected:
    virtual bool  InitTrade(long magic);
    virtual bool Processing();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTurtleExpert::CTurtleExpert()
{
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTurtleExpert::~CTurtleExpert()
  {
  }
bool CTurtleExpert::InitTrade(long magic)
{
    m_turtleN.Init(GetPointer(m_symbol), m_period, magic);
    
    if(m_trade==NULL)
     {
      if((m_trade=new CExpertTrade)==NULL) return(false);
      m_trade.SetSymbol(GetPointer(m_symbol)); // symbol for trade
      m_trade.SetExpertMagicNumber(magic);     // magic
      //--- set default deviation for trading in adjusted points
      m_trade.SetDeviationInPoints((ulong)(3*m_adjusted_point/m_symbol.Point()));
      
      m_trade.LogLevel(LOG_LEVEL_NO);
     }
//--- ok
   return(true);
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Initialization signal object                                     |
//| INPUT:  signal - pointer of signal object.                       |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTurtleExpert::InitSignal(CExpertSignal* signal)
{
    if(m_signal!=NULL) 
        delete m_signal;

    if(signal==NULL)
    {
        CTurtleSignal* n = new CTurtleSignal;
        //CAllSignal* n = new CAllSignal;
        if (n == NULL)
            return false;
        n.Init(GetPointer(m_turtleN));
        signal = n;
    }

    m_signal=signal;

    if(!m_signal.Init(GetPointer(m_symbol),m_period,m_adjusted_point)) 
        return(false);

   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization trailing object                                   |
//| INPUT:  trailing - pointer of trailing object.                   |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTurtleExpert::InitTrailing(CExpertTrailing* trailing)
{
    if(m_trailing!=NULL) 
        delete m_trailing;

    if(trailing==NULL)
    {
        CTurtleStop* n = new CTurtleStop;
        //CTrailingNone* n = new CTrailingNone();
        if (n == NULL)
            return false;
        n.Init(GetPointer(m_turtleN));
        trailing = n;
     }

    m_trailing=trailing;

    if(!m_trailing.Init(GetPointer(m_symbol),m_period,m_adjusted_point)) 
        return(false);

   return(true);
}
//+------------------------------------------------------------------+
//| Initialization money object                                      |
//| INPUT:  money - pointer of money object.                         |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTurtleExpert::InitMoney(CExpertMoney *money)
{
    if(m_money!=NULL) 
        delete m_money;
        
    if(money==NULL)
    {
        CTurtleMoney* n = new CTurtleMoney;
        if (n == NULL)
            return false;
        n.Init(GetPointer(m_turtleN));
        money = n;
    }

    m_money=money;
    
    if(!m_money.Init(GetPointer(m_symbol),m_period,m_adjusted_point)) 
        return(false);

    return(true);
}

bool CTurtleExpert::Processing()
  {
//--- check if open positions
   if(m_position.Select(m_symbol.Name()))
     {
      //--- open position is available
      //--- check the possibility of reverse the position
      if(CheckReverse()) return(true);
      //--- check the possibility of closing the position/delete pending orders
      if(!CheckClose())
        {
         //--- check the possibility of modifying the position
         //if(CheckTrailingStop()) return(true);
         CheckTrailingStop();
         //--- return without operations
         //return(false);
        }
     }
//--- check if plased pending orders
   int total=OrdersTotal();
   if(total!=0)
     {
      for(int i=total-1;i>=0;i--)
        {
         m_order.Select(OrderGetTicket(i));
         if(m_order.Symbol()!=m_symbol.Name()) continue;
         if(m_order.OrderType()==ORDER_TYPE_BUY_LIMIT || m_order.OrderType()==ORDER_TYPE_BUY_STOP)
           {
            //--- check the ability to delete a pending order to buy
            if(CheckDeleteOrderLong()) return(true);
            //--- check the possibility of modifying a pending order to buy
            if(CheckTrailingOrderLong()) return(true);
           }
         else
           {
            //--- check the ability to delete a pending order to sell
            if(CheckDeleteOrderShort()) return(true);
            //--- check the possibility of modifying a pending order to sell
            if(CheckTrailingOrderShort()) return(true);
           }
         //--- return without operations
         return(false);
        }
     }
//--- check the possibility of opening a position/setting pending order
   if(CheckOpen()) return(true);
//--- return without operations
   return(false);
  }
