//+------------------------------------------------------------------+
//|                                                  ExpertModel.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Expert\Expert.mqh>
#include "ExpertModelSignal.mqh"
#include "ExpertModelMoney.mqh"
#include "ExpertModelTrailing.mqh"
#include "TableOrders.mqh"

//#include <Trade\HistoryOrderInfo.mqh>

#include <Utils\Utils.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_ORDER_MODE
  {
   ORDER_ADD,
   ORDER_DELETE
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_TYPE_DELETED_ORDER
  {
   DELETE_ALL_LONG,
   DELETE_ALL_SHORT,
   DELETE_ALL_BUY,
   DELETE_ALL_BUY_STOP,
   DELETE_ALL_BUY_LIMIT,
   DELETE_ALL_BUY_STOP_LIMIT,
   DELETE_ALL_SELL,
   DELETE_ALL_SELL_STOP,
   DELETE_ALL_SELL_LIMIT,
   DELETE_ALL_SELL_STOP_LIMIT
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct OrdersInfo
  {
   int               all_orders;
   int               long_orders;
   int               short_orders;
   int               buy_sell_orders;
   int               delayed_orders;
   int               buy_orders;
   int               sell_orders;
   int               buy_stop_orders;
   int               sell_stop_orders;
   int               buy_limit_orders;
   int               sell_limit_orders;
   int               buy_stop_limit_orders;
   int               sell_stop_limit_orders;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CExpertModel : public CExpert
  {
private:
   string            m_expertName;
   long              m_magic;
   CTableOrders      m_listTableOrders;
   string            m_persistFileName;
   int               m_lastDealCount;

public:
   CList *TableOrders() { return GetPointer(m_listTableOrders); }
   CExpertModelSignal *ExpertModelSignal() { return(CExpertModelSignal *)m_signal; }
   CExpertModelTrailing *ExpertModelTrailing() { return(CExpertModelTrailing *)m_trailing; }
   CExpertModelMoney *ExpertModelMoney() { return(CExpertModelMoney *)m_money; }
public:
                     CExpertModel();
                    ~CExpertModel();
   virtual bool      InitSignal(CExpertModelSignal *signal=NULL);
   virtual bool      InitTrailing(CExpertModelTrailing *trailing=NULL);
   virtual bool      InitMoney(CExpertModelMoney *money=NULL);
   virtual bool      InitParameters();
   bool              Init(string symbol,ENUM_TIMEFRAMES period,bool every_tick,long magic,string name="");

   virtual void      Deinit();

   string            Name(){return(m_expertName);}
   ENUM_TIMEFRAMES   Period(void){return(m_period);}
   string            Symbol(void){return(m_symbol.Name());}
   ulong             Magic(void){return m_magic; }

   double            GetPosition();
   int               GetOrderCount(ENUM_ORDER_TYPE type);

private:
   bool              LoadOrders();
   bool              SaveOrders();
   bool              DeleteTableOrder(ulong Ticket);
   void              DeleteTableOrdersByType(ENUM_TYPE_DELETED_ORDER type);

   bool              AddOrder(ulong tiket,double stop_loss,double take_profit);
   void              GetOrdersInfo(OrdersInfo &orders);
   bool              SendOrder(string symbol,ENUM_ORDER_TYPE op_type,ENUM_ORDER_MODE op_mode,ulong ticket,double lot,double price,double stop_loss,double take_profit,string comment);
   bool              ReplaceDelayedOrders(void);

protected:
   //--- processing (main method)
   virtual bool      Processing();
   bool              CheckTpandSl();

   //--- trade open positions processing
   virtual bool      OpenLong(double price,double sl,double tp);
   virtual bool      OpenShort(double price,double sl,double tp);
   virtual bool      CloseLong(CTableOrder *t,double price);
   virtual bool      CloseShort(CTableOrder *t,double price);
   virtual bool      CheckCloseLong();
   virtual bool      CheckCloseShort();
   virtual bool      CheckDeleteOrderLong();
   virtual bool      CheckDeleteOrderShort();

   //virtual bool DeleteOrders();
   virtual bool      TradeEventOrderTriggered();

   virtual bool      CheckTrailingStop();
   bool              CheckTrailingStopLong(CTableOrder *t);
   bool              CheckTrailingStopShort(CTableOrder *t);
   bool              TrailingStopLong(CTableOrder *t,double sl,double tp);
   bool              TrailingStopShort(CTableOrder *t,double sl,double tp);

   bool              CheckCloseLong(CTableOrder *t);
   bool              CheckCloseShort(CTableOrder *t);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CExpertModel::CExpertModel()
  {
   CExpert::OnTradeProcess(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CExpertModel::~CExpertModel()
  {
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Initialization signal object                                     |
//| INPUT:  signal - pointer of signal object.                       |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpertModel::InitSignal(CExpertModelSignal *signal)
  {
   Debug("CExpertModel::InitSignal");

   signal.SetExpertModel(GetPointer(this));

   return CExpert::InitSignal(signal);
  }
//+------------------------------------------------------------------+
//| Initialization trailing object                                   |
//| INPUT:  trailing - pointer of trailing object.                   |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpertModel::InitTrailing(CExpertModelTrailing *trailing)
  {
   Debug("CExpertModel::InitTrailing");

   trailing.SetExpertModel(GetPointer(this));

   return CExpert::InitTrailing(trailing);
  }
//+------------------------------------------------------------------+
//| Initialization money object                                      |
//| INPUT:  money - pointer of money object.                         |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CExpertModel::InitMoney(CExpertModelMoney *money)
  {
   Debug("CExpertModel::InitMoney");

   money.SetExpertModel(GetPointer(this));

   return CExpert::InitMoney(money);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::InitParameters()
  {
   m_trade.LogLevel(LOG_LEVEL_ALL);
   return CExpert::InitParameters();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::LoadOrders(void)
  {
   m_persistFileName=m_expertName+"_TableOrders.bin";

   if(FileIsExist(m_persistFileName))
     {
      int filehandle = FileOpen(m_persistFileName, FILE_READ|FILE_BIN);
      if(filehandle != INVALID_HANDLE)
        {
         bool r=m_listTableOrders.Load(filehandle);
         if(!r)
           {
            FileDelete(m_persistFileName);
           }
         FileClose(filehandle);
         return r;
        }
      else
        {
         return false;
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::SaveOrders(void)
  {
   if(FileIsExist(m_persistFileName))
     {
      FileDelete(m_persistFileName);
     }

   if(m_listTableOrders.Total()>0)
     {
      int filehandle = FileOpen(m_persistFileName, FILE_WRITE|FILE_BIN);
      if(filehandle != INVALID_HANDLE)
        {
         bool r=m_listTableOrders.Save(filehandle);
         FileClose(filehandle);
         if(!r)
           {
            FileDelete(m_persistFileName);
           }
         return r;
        }
      else
        {
         return false;
        }
     }
   return true;

/*if(m_listTableOrders!=NULL)
     {
      CTableOrder *p=m_listTableOrders.GetFirstNode();
      while(p!=NULL)
        {
         CTableOrder *pNext=m_listTableOrders.GetNextNode();
         delete p;
         p=pNext;
        }

      delete m_listTableOrders;
     }*/
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::Init(string symbol,ENUM_TIMEFRAMES period,bool every_tick,long magic,string name="")
  {
   Debug("CExpertModel::Init");

   m_magic=magic;
   m_expertName=name=="" ? "Expert" : name;

   LoadOrders();

   return CExpert::Init(symbol,period,every_tick,magic);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CExpertModel::Deinit(void)
  {
   Debug("CExpertModel::Deinit");

   SaveOrders();

   CExpert::Deinit();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CExpertModel::DeleteTableOrdersByType(ENUM_TYPE_DELETED_ORDER type)
  {
   Debug("CExpertModel::DeleteTableOrdersByType");

   bool r;
   CTableOrder *t=(CTableOrder *)m_listTableOrders.GetFirstNode();
   while(t!=NULL)
     {
      r=false;
      if(type==DELETE_ALL_BUY)
        {
         switch(t.OrderType())
           {
            case ORDER_TYPE_BUY:
            case ORDER_TYPE_BUY_STOP:
            case ORDER_TYPE_BUY_LIMIT:
            case ORDER_TYPE_BUY_STOP_LIMIT:
               r=m_listTableOrders.DeleteCurrent();
               if(r)
                  Debug("Delete table order of buy.");
               else
                  Error("Failed to delete table order of buy.");
               break;
           }
        }
      else if(type==DELETE_ALL_SELL)
        {
         switch(t.OrderType())
           {
            case ORDER_TYPE_SELL:
            case ORDER_TYPE_SELL_STOP:
            case ORDER_TYPE_SELL_LIMIT:
            case ORDER_TYPE_SELL_STOP_LIMIT:
               r=m_listTableOrders.DeleteCurrent();
               if(r)
                  Debug("Delete table order of buy.");
               else
                  Error("Failed to delete table order of buy.");
               break;
           }
        }
      if(!r)
         t=m_listTableOrders.GetNextNode();
      else
         t=m_listTableOrders.GetCurrentNode();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::DeleteTableOrder(ulong ticket)
  {
   Debug("CExpertModel::DeleteTableOrder");

   bool r=false;
   CTableOrder *t=(CTableOrder *)m_listTableOrders.GetFirstNode();
   while(t!=NULL)
     {
      if(t.Ticket()==ticket)
        {
         r=m_listTableOrders.DeleteCurrent();
         if(r)
            Debug("Delete table order of ",IntegerToString(ticket));
         else
            Error("Failed to delete table order of ",IntegerToString(ticket));
         return r;
        }
      t=m_listTableOrders.GetNextNode();
     }
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CExpertModel::GetOrdersInfo(OrdersInfo &ordersInfo)
  {
   Debug("CExpertModel::GetOrdersInfo");

//int orders_total=m_listTableOrders.Total();
   ordersInfo.all_orders=0;
   ordersInfo.buy_limit_orders=0;
   ordersInfo.buy_orders=0;
   ordersInfo.buy_sell_orders=0;
   ordersInfo.buy_sell_orders=0;
   ordersInfo.buy_stop_limit_orders=0;
   ordersInfo.buy_stop_orders=0;
   ordersInfo.delayed_orders=0;
   ordersInfo.long_orders=0;
   ordersInfo.sell_limit_orders=0;
   ordersInfo.sell_orders=0;
   ordersInfo.sell_stop_limit_orders=0;
   ordersInfo.sell_stop_orders=0;
   ordersInfo.short_orders=0;

   CTableOrder *t=m_listTableOrders.GetFirstNode();
   while(t!=NULL)
     {
      ENUM_ORDER_TYPE order_type=t.OrderType();
      switch(order_type)
        {
         case ORDER_TYPE_BUY:
            ordersInfo.all_orders++;
            ordersInfo.long_orders++;
            ordersInfo.buy_orders++;
            break;
         case ORDER_TYPE_SELL:
            ordersInfo.all_orders++;
            ordersInfo.short_orders++;
            ordersInfo.sell_orders++;
            break;
         case ORDER_TYPE_BUY_STOP:
            ordersInfo.all_orders++;
            ordersInfo.long_orders++;
            ordersInfo.delayed_orders++;
            ordersInfo.buy_stop_orders++;
            break;
         case ORDER_TYPE_SELL_STOP:
            ordersInfo.all_orders++;
            ordersInfo.short_orders++;
            ordersInfo.delayed_orders++;
            ordersInfo.sell_stop_orders++;
            break;
         case ORDER_TYPE_BUY_LIMIT:
            ordersInfo.all_orders++;
            ordersInfo.long_orders++;
            ordersInfo.delayed_orders++;
            ordersInfo.buy_limit_orders++;
            break;
         case ORDER_TYPE_SELL_LIMIT:
            ordersInfo.all_orders++;
            ordersInfo.short_orders++;
            ordersInfo.delayed_orders++;
            ordersInfo.sell_limit_orders++;
            break;
         case ORDER_TYPE_BUY_STOP_LIMIT:
            ordersInfo.all_orders++;
            ordersInfo.long_orders++;
            ordersInfo.delayed_orders++;
            ordersInfo.buy_stop_limit_orders++;
            break;
         case ORDER_TYPE_SELL_STOP_LIMIT:
            ordersInfo.all_orders++;
            ordersInfo.short_orders++;
            ordersInfo.delayed_orders++;
            ordersInfo.sell_stop_limit_orders++;
            break;
        }

      t=m_listTableOrders.GetNextNode();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::AddOrder(ulong ticket,double stop_loss,double take_profit)
  {
   Debug("CExpertModel::AddOrder");

   CTableOrder *t=new CTableOrder;
   if(!t.Set(ticket,stop_loss,take_profit))
     {
      Error("The order addition has failed. Check order parameters.");
      return(false);
     }
   if(m_listTableOrders.Add(t)==-1)
     {
      Error("Can't add order to the orders table. Error!");
      return(false);
     }
   Debug("Order ",IntegerToString(ticket)," has been added successfully");
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::SendOrder(string symbol,ENUM_ORDER_TYPE op_type,ENUM_ORDER_MODE op_mode,ulong ticket,double lot,double price,double stop_loss,double take_profit,string comment)
  {
   Info("Send order "+symbol+","+EnumToString(op_type)+"("+DoubleToString(price,4)+","+DoubleToString(take_profit,4)+","+DoubleToString(stop_loss,4)+","+DoubleToString(lot,2)+"),",
        EnumToString(op_mode)+",",IntegerToString(ticket)+",",
        comment);

   Debug("CExpertModel::SendOrder");

   comment=this.Name()+":"+comment;
//comment = "";

   ulong code_return=0;
   m_symbol.RefreshRates();
   double lot_send=lot;
   double lot_max=m_symbol.LotsMax();

//double lot_max=5.0;
   bool rez=false;
   int floor_lot=(int)MathFloor(lot/lot_max);

/*lot_check=CheckLot(symbol, lot, op_type);
	//All or nothing
	if(lot_check!=lot&&op_mode==ORDER_DELETE)return(false);
	if(lot_check==EMPTY_VALUE)return(false);
	lot_margin=CheckMargin(symbol, op_type, lot_check, price);
	//All or nothing
	if(lot_margin!=lot_check&&op_mode==ORDER_DELETE)return(false);
	if(lot_margin==EMPTY_VALUE)return(false);
	lot=lot_margin;
	lot_send=lot_margin;*/

   if(MathMod(lot,lot_max)==0)
      floor_lot=floor_lot-1;
   int itteration=(int)MathCeil(lot/lot_max);
   if(itteration>1)
      Info("The order volume exceeds the maximum allowed volume. It will be divided into "+IntegerToString(itteration)+" parts");
   for(int i=1;i<=itteration;i++)
     {
      if(i==itteration)
         lot_send=lot-(floor_lot*lot_max);
      else
         lot_send=lot_max;

      int retryCnt=3;
      for(int j=0;j<retryCnt;j++)
        {
         //Debug("Send Order: TRADE_RETCODE_DONE");
         m_symbol.RefreshRates();
         if(op_type==ORDER_TYPE_BUY)
           {
            double nowPrice=m_symbol.Ask();
            if(MathAbs(nowPrice-price)>=m_symbol.StopsLevel()*m_symbol.Point())
              {
               if(price>nowPrice)
                  op_type=ORDER_TYPE_BUY_STOP;
               else if(price<nowPrice)
                  op_type=ORDER_TYPE_BUY_LIMIT;
              }
            else
              {
               price=nowPrice;
              }
           }
         if(op_type==ORDER_TYPE_SELL)
           {
            double nowPrice=m_symbol.Bid();
            if(MathAbs(nowPrice-price)>=m_symbol.StopsLevel()*m_symbol.Point())
              {
               if(price<nowPrice)
                  op_type=ORDER_TYPE_SELL_STOP;
               else if(price>nowPrice)
                  op_type=ORDER_TYPE_SELL_LIMIT;
              }
            else
              {
               price=nowPrice;
              }
           }

         m_trade.SetDeviationInPoints(ulong(0.0010/m_symbol.Point()));
         m_trade.SetExpertMagicNumber(m_magic);
         switch(op_type)
           {
            case ORDER_TYPE_BUY:
               rez=m_trade.Buy(lot_send,price,0.0,0.0,comment);
               break;
            case ORDER_TYPE_SELL:
               rez=m_trade.Sell(lot_send,price,0.0,0.0,comment);
               break;
            case ORDER_TYPE_BUY_LIMIT:
               rez=m_trade.BuyLimit(lot_send,price,m_symbol.Name(),0.0,0.0,0,0,comment);
               break;
            case ORDER_TYPE_BUY_STOP:
               rez=m_trade.BuyStop(lot_send,price,m_symbol.Name(),0.0,0.0,0,0,comment);
               break;
            case ORDER_TYPE_SELL_LIMIT:
               rez=m_trade.SellLimit(lot_send,price,m_symbol.Name(),0.0,0.0,0,0,comment);
               break;
            case ORDER_TYPE_SELL_STOP:
               rez=m_trade.SellStop(lot_send,price,m_symbol.Name(),0.0,0.0,0,0,comment);
               break;
           }

         // Don't remove Sleep! It's needed to place order into m_history_order_info!!!
         if((bool)MQL5InfoInteger(MQL5_TESTING))
           {
            Sleep(5000);
           }

         if(m_trade.ResultRetcode()==TRADE_RETCODE_PLACED||
            m_trade.ResultRetcode()==TRADE_RETCODE_DONE_PARTIAL||
            m_trade.ResultRetcode()==TRADE_RETCODE_DONE)
           {
            //rez=m_history_order_info.Ticket(m_trade.ResultOrder());
            if(op_mode==ORDER_ADD)
              {
               rez=AddOrder(m_trade.ResultOrder(),stop_loss,take_profit);
               Info("Add Order ",IntegerToString(m_trade.ResultOrder()));
              }
            if(op_mode==ORDER_DELETE)
              {
               rez=DeleteTableOrder(ticket);
               Info("Delete Order ",IntegerToString(ticket));
              }
            code_return=m_trade.ResultRetcode();
            break;
           }
         else
           {
            Error("Send Order Error: "+m_trade.ResultRetcodeDescription()+", "+m_trade.ResultComment());
           }
         if(m_trade.ResultRetcode()==TRADE_RETCODE_TRADE_DISABLED||
            m_trade.ResultRetcode()==TRADE_RETCODE_MARKET_CLOSED||
            m_trade.ResultRetcode()==TRADE_RETCODE_NO_MONEY||
            m_trade.ResultRetcode()==TRADE_RETCODE_TOO_MANY_REQUESTS||
            m_trade.ResultRetcode()==TRADE_RETCODE_SERVER_DISABLES_AT||
            m_trade.ResultRetcode()==TRADE_RETCODE_CLIENT_DISABLES_AT||
            m_trade.ResultRetcode()==TRADE_RETCODE_LIMIT_ORDERS||
            m_trade.ResultRetcode()==TRADE_RETCODE_LIMIT_VOLUME)
           {
            break;
           }
        }
     }

   Debug("CExpertModel::SendOrder finish: "+IntegerToString(rez));

   if(!(bool)MQL5InfoInteger(MQL5_TESTING))
     {
      SaveOrders();
     }

   return(rez);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::ReplaceDelayedOrders(void)
  {
// not working yet
   Debug("CExpertModel::ReplaceDelayedOrders");

   if(m_symbol.TradeMode()==SYMBOL_TRADE_MODE_DISABLED)
      return(false);

   bool r=false;
   CTableOrder *t=m_listTableOrders.GetFirstNode();
   while(t!=NULL)
     {
      r=false;
      switch(t.OrderType())
        {
         case ORDER_TYPE_BUY:
         case ORDER_TYPE_SELL:
           {
            HistorySelect(D'2000.01.01',D'2020.01.01');
            int history_orders=HistoryOrdersTotal();
            for(int b=0;b<history_orders;b++)
              {
               ulong ticket=HistoryOrderGetTicket(b);
               // if order ticket from history is equal to one of the "simulated-Stop-Loss" or "simulated-Take-Profit" tickets
               // it means that order should be deleted from the table of orders
               if(ticket==t.TicketSL() || ticket==t.TicketTP())
                 {
                  r=m_listTableOrders.DeleteCurrent();
                 }
              }
           }
         break;
         // if we haven't found the Stop Loss and Take Profit orders in the history,
         // it seems that we haven't placed them. Hence we need to place them
         // using the methods for pending orders, presented below
         // the loop will continue, there isn't a "break" statement
         case ORDER_TYPE_BUY_LIMIT:
         case ORDER_TYPE_BUY_STOP:
         case ORDER_TYPE_BUY_STOP_LIMIT:
         case ORDER_TYPE_SELL_LIMIT:
         case ORDER_TYPE_SELL_STOP:
         case ORDER_TYPE_SELL_STOP_LIMIT:
           {
            HistorySelect(D'2000.01.01',D'2020.01.01');
            int history_orders=HistoryOrdersTotal();
            for(int b=0;b<history_orders;b++)
              {
               ulong ticket=HistoryOrderGetTicket(b);
               long request;
               m_order.InfoInteger(ORDER_STATE,request);

               //Print(t.Ticket(), ",", ticket, ",", request);

               // if the historical order ticket is equal to the pending order ticket,
               // it means that pending order has been executed and we need to place
               // the pending "simulated-Stop-Loss" and "simulated-Take-Profit" orders
               // Also we need to change the status (ORDER_TYPE_BUY or ORDER_TYPE_SELL)
               //  of pending order in the orders table    

               if(t.Ticket()==ticket && 
                  (request==ORDER_STATE_PARTIAL || request==ORDER_STATE_FILLED))
                 {
                  Print("2");
                  // Change order status in the orders table:
                  m_order.InfoInteger(ORDER_TYPE,request);
                  if(t.OrderType()!=request)
                     t.OrderType((ENUM_ORDER_TYPE)request);
                  //------------------------------------------------------------------
                  // Let's place "simulated-Stop-Loss" and "simulated-Take-Profit" pending orders
                  // the price levels should be defined
                  // also we need to check the absence of "simulated-Stop-Loss" and "simulated-Take-Profit"
                  // related with current order:
                  if(t.StopLoss()!=0.0 && t.TicketSL()==0)
                    {

                     // Try to place pending order
                     switch(t.OrderType())
                       {
                        case ORDER_TYPE_BUY:
                          {
                           // Try it 3 times
                           for(int try=0;try<3;try++)
                             {
                              m_trade.SellStop(t.VolumeInitial(),t.StopLoss(),m_symbol.Name(),0.0,0.0,0,0,"take-profit for buy");
                              if(m_trade.ResultRetcode()==TRADE_RETCODE_PLACED || m_trade.ResultRetcode()==TRADE_RETCODE_DONE)
                                {
                                 t.TicketTP(m_trade.ResultDeal());
                                 break;
                                }
                             }
                          }
                        break;
                        case ORDER_TYPE_SELL:
                          {
                           // Try it 3 times
                           for(int try=0;try<3;try++)
                             {
                              m_trade.BuyStop(t.VolumeInitial(),t.StopLoss(),m_symbol.Name(),0.0,0.0,0,0,"take-profit for buy");
                              if(m_trade.ResultRetcode()==TRADE_RETCODE_PLACED || m_trade.ResultRetcode()==TRADE_RETCODE_DONE)
                                {
                                 t.TicketTP(m_trade.ResultDeal());
                                 break;
                                }
                             }
                          }
                        break;
                       }
                    }
                  if(t.TakeProfit()!=0.0 && t.TicketTP()==0)
                    {
                     // Trying to place "simulated-Take-Profit" pending order
                     switch(t.OrderType())
                       {
                        case ORDER_TYPE_BUY:
                          {
                           // Try it 3 times
                           for(int try=0;try<3;try++)
                             {
                              m_trade.SellLimit(t.VolumeInitial(),t.StopLoss(),m_symbol.Name(),0.0,0.0,0,0,"take-profit for buy");
                              if(m_trade.ResultRetcode()==TRADE_RETCODE_PLACED || m_trade.ResultRetcode()==TRADE_RETCODE_DONE)
                                {
                                 t.TicketTP(m_trade.ResultDeal());
                                 break;
                                }
                             }
                          }
                        break;
                        case ORDER_TYPE_SELL:
                          {
                           // Try it 3 times
                           for(int try=0;try<3;try++)
                             {
                              m_trade.BuyLimit(t.VolumeInitial(),t.StopLoss(),m_symbol.Name(),0.0,0.0,0,0,"take-profit for buy");
                              if(m_trade.ResultRetcode()==TRADE_RETCODE_PLACED || m_trade.ResultRetcode()==TRADE_RETCODE_DONE)
                                {
                                 t.TicketTP(m_trade.ResultDeal());
                                 break;
                                }
                             }
                          }
                        break;
                       }
                    }
                 }
              }
           }
         break;
        }
      if(r)
         t=m_listTableOrders.GetCurrentNode();
      else
         t=m_listTableOrders.GetNextNode();
     }

   return(true);
  }
/////////////////////////////////////////////////////////////////////////////////////
int CExpertModel::GetOrderCount(ENUM_ORDER_TYPE type)
  {
   Debug("CExpertModel::GetOrderCount");

   OrdersInfo ordersInfo;
   GetOrdersInfo(ordersInfo);
   if(type==ORDER_TYPE_BUY)
      return ordersInfo.long_orders;
   else if(type==ORDER_TYPE_SELL)
      return ordersInfo.short_orders;
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CExpertModel::GetPosition()
  {
   Debug("CExpertModel::GetPosition");

   int elements=0.0;
   double volume_position=0.0;
   double volume_current=0.0;
   CTableOrder *t=m_listTableOrders.GetFirstNode();
   while(t!=NULL)
     {
      if(t.OrderType()==ORDER_TYPE_SELL)
         volume_position-=t.VolumeInitial();
      if(t.OrderType()==ORDER_TYPE_BUY)
         volume_position+=t.VolumeInitial();

      t=m_listTableOrders.GetNextNode();
     }
   return(volume_position);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::TradeEventOrderTriggered()
  {
   Print("CExpertModel::TradeEventOrderTriggered");

   HistorySelect(LONG_MIN,LONG_MAX);
   int dealsCount=HistoryDealsTotal();

   CTableOrder *t=m_listTableOrders.GetFirstNode();
   while(t!=NULL)
     {
      if(t.OrderType()==ORDER_TYPE_BUY_LIMIT
         || t.OrderType() == ORDER_TYPE_BUY_STOP
         || t.OrderType() == ORDER_TYPE_SELL_LIMIT
         || t.OrderType() == ORDER_TYPE_SELL_STOP)
        {
         ENUM_ORDER_STATE orderState=(ENUM_ORDER_STATE)HistoryOrderGetInteger(t.Ticket(),ORDER_STATE);
         if(orderState==ORDER_STATE_CANCELED
            || orderState == ORDER_STATE_EXPIRED
            || orderState == ORDER_STATE_REJECTED)
           {
            m_listTableOrders.DeleteCurrent();
            t=m_listTableOrders.GetCurrentNode();
            continue;
           }

         if(dealsCount!=m_lastDealCount)
           {
            for(int i=dealsCount-1; i>=0; --i)
              {
               ulong ticket=HistoryDealGetTicket(i);
               //Print(ticket, ",", HistoryDealGetInteger(ticket,DEAL_ORDER), ",", t.Ticket());
               if(HistoryDealGetInteger(ticket,DEAL_ORDER)==t.Ticket())
                 {
                  Info("Order replaced");

                  if(t.OrderType()==ORDER_TYPE_BUY_LIMIT
                     || t.OrderType()==ORDER_TYPE_BUY_STOP)
                     t.OrderType(ORDER_TYPE_BUY);
                  else
                     t.OrderType(ORDER_TYPE_SELL);
                  break;
                 }
               if(HistoryDealGetInteger(ticket,DEAL_TIME)<t.TimeSetup())
                  break;
              }
           }
        }
      t=m_listTableOrders.GetNextNode();
     }
   m_lastDealCount=dealsCount;

   return true;
  }
/////////////////////////////////////////////////////////////////////////////////////////////////
bool CExpertModel::CheckTpandSl()
  {
   Debug("CExpertModel::CheckTpandSl");

   HistorySelect(LONG_MIN,LONG_MAX);
   int dealsCount=HistoryDealsTotal();

   CTableOrder *t=m_listTableOrders.GetFirstNode();
   int r=false;
   while(t!=NULL)
     {
      if(t.OrderType()==ORDER_TYPE_SELL)
        {
         //Debug(t.TakeProfit(), ", ", t.StopLoss(), ", ", m_symbol.Ask());

         if(t.StopLoss()!=0.0 && m_symbol.Ask()>=t.StopLoss())
           {
            r=SendOrder(m_symbol.Name(),ORDER_TYPE_BUY,ORDER_DELETE,t.Ticket(),t.VolumeInitial(),m_symbol.Ask(),
                        0.0,0.0,"sl:"+IntegerToString(t.Ticket()));
           }
         else if(t.TakeProfit()!=0.0 && m_symbol.Ask()<=t.TakeProfit())
           {
            r=SendOrder(m_symbol.Name(),ORDER_TYPE_BUY,ORDER_DELETE,t.Ticket(),t.VolumeInitial(),m_symbol.Ask(),
                        0.0,0.0,"tp:"+IntegerToString(t.Ticket()));
           }
        }
      else if(t.OrderType()==ORDER_TYPE_BUY)
        {
         if(t.StopLoss()!=0.0 && m_symbol.Bid()<=t.StopLoss())
           {
            r=SendOrder(m_symbol.Name(),ORDER_TYPE_SELL,ORDER_DELETE,t.Ticket(),t.VolumeInitial(),m_symbol.Bid(),
                        0.0,0.0,"sl:"+IntegerToString(t.Ticket()));
           }
         else if(t.TakeProfit()!=0.0 && m_symbol.Bid()>=t.TakeProfit())
           {
            r=SendOrder(m_symbol.Name(),ORDER_TYPE_SELL,ORDER_DELETE,t.Ticket(),t.VolumeInitial(),m_symbol.Bid(),
                        0.0,0.0,"tp:"+IntegerToString(t.Ticket()));
           }
        }
      else
        {
         //Print(t.Ticket(), ",", t.OrderType());
        }

      t=m_listTableOrders.GetNextNode();
     }

   return(r);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::Processing()
  {
   Debug("CExpertModel::Processing");
   m_symbol.RefreshRates();

   CExpertModelSignal *signal=(CExpertModelSignal *)m_signal;
   signal.PreProcess();

//ReplaceDelayedOrders();

   bool ret=false;
   CheckTpandSl();

   if(m_position.Select(m_symbol.Name()))
     {
      ret|=CheckClose();

      CTableOrder *t=m_listTableOrders.GetFirstNode();
      while(t!=NULL)
        {
         if(t.OrderType()==ORDER_TYPE_BUY)
           {
            ret|=CheckCloseLong(t);
           }
         else if(t.OrderType()==ORDER_TYPE_SELL)
           {
            ret|=CheckCloseShort(t);
           }
         t=m_listTableOrders.GetNextNode();
        }

      CheckTrailingStop();
     }

//--- check if plased pending orders
   int total=OrdersTotal();
   if(total!=0)
     {
      for(int i=total-1;i>=0;i--)
        {
         m_order.SelectByIndex(i);
         if(m_order.Symbol()!=m_symbol.Name())
            continue;
         if(m_order.Magic()!=m_magic)
            continue;
         if(m_order.OrderType()==ORDER_TYPE_BUY_LIMIT || m_order.OrderType()==ORDER_TYPE_BUY_STOP)
           {
            CheckDeleteOrderLong();
            CheckTrailingOrderLong();
           }
         else if(m_order.OrderType()==ORDER_TYPE_SELL_LIMIT || m_order.OrderType()==ORDER_TYPE_SELL_STOP)
           {
            CheckDeleteOrderShort();
            CheckTrailingOrderShort();
           }
        }
     }

   if(CheckOpen())
      return(true);

   Debug("CExpertModel::Processing finish");

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::CheckDeleteOrderLong()
  {
//--- check the possibility of deleting the long order
   if(m_expiration!=0 && TimeCurrent()>m_expiration)
     {
      m_expiration=0;
      return(DeleteOrderLong());
     }
   CExpertModelSignal *signal=(CExpertModelSignal*)m_signal;
   if(signal.CheckCloseOrderLong())
      return(DeleteOrderLong());
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::CheckDeleteOrderShort()
  {
//--- check the possibility of deleting the short order
   if(m_expiration!=0 && TimeCurrent()>m_expiration)
     {
      m_expiration=0;
      return(DeleteOrderShort());
     }
   CExpertModelSignal *signal=(CExpertModelSignal*)m_signal;
   if(signal.CheckCloseOrderShort())
      return(DeleteOrderShort());
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::OpenLong(double price,double sl,double tp)
  {
   Debug("CExpertModel::OpenLong");

   if(price==EMPTY_VALUE) return(false);
   double lot=LotOpenLong(price,sl);
   if(lot==0.0) return(false);
   return SendOrder(m_symbol.Name(),ORDER_TYPE_BUY,ORDER_ADD,0,lot,price,sl,tp,
                    "sl="+DoubleToString(sl,4)+",tp="+DoubleToString(tp,4));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::OpenShort(double price,double sl,double tp)
  {
   Debug("CExpertModel::OpenShort");

   if(price==EMPTY_VALUE)
      return(false);
   double lot=LotOpenShort(price,sl);
   if(lot==0.0)
      return(false);

   bool ret=SendOrder(m_symbol.Name(),ORDER_TYPE_SELL,ORDER_ADD,0,lot,price,sl,tp,
                      "sl="+DoubleToString(sl,4)+",tp="+DoubleToString(tp,4));

   Debug("CExpertModel::OpenShort finish");

   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::CloseLong(CTableOrder *t,double price)
  {
   Debug("CExpertModel::CloseLong");

   if(price==EMPTY_VALUE)
      return(false);

   bool ret=SendOrder(m_symbol.Name(),ORDER_TYPE_SELL,ORDER_DELETE,t.Ticket(),t.VolumeInitial(),m_symbol.Bid(),
                      0.0,0.0,"close");
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::CloseShort(CTableOrder *t,double price)
  {
   Debug("CExpertModel::CloseShort");

   if(price==EMPTY_VALUE)
      return(false);

   bool ret=SendOrder(m_symbol.Name(),ORDER_TYPE_BUY,ORDER_DELETE,t.Ticket(),t.VolumeInitial(),m_symbol.Ask(),
                      0.0,0.0,"close");
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
bool CExpertModel::DeleteOrders()
{
	bool result=false;
	int  total=OrdersTotal();

	for(int i=total-1;i>=0;i--)
	{
		if(m_order.Select(OrderGetTicket(i)))
		{
			if(m_order.Symbol()!=m_symbol.Name()) continue;
			if (m_order.Magic() != m_magic) continue;
			result|=DeleteTableOrder();
		}
	}
	return(result);
}*/

bool CExpertModel::CheckTrailingStop()
  {
   Debug("CExpertModel::CheckTrailingStop");

   CTableOrder *t=m_listTableOrders.GetFirstNode();
   bool r=true;
   while(t!=NULL)
     {
      if(t.OrderType()==ORDER_TYPE_BUY)
        {
         r&=CheckTrailingStopLong(t);
        }
      else if(t.OrderType()==ORDER_TYPE_SELL)
        {
         r&=CheckTrailingStopShort(t);
        }
      t=m_listTableOrders.GetNextNode();
     }
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::CheckTrailingStopLong(CTableOrder *t)
  {
   Debug("CExpertModel::CheckTrailingStopLong");

   double sl=EMPTY_VALUE;
   double tp=EMPTY_VALUE;

   CExpertModelTrailing *trailing=(CExpertModelTrailing *)m_trailing;
   if(trailing.CheckTrailingStopLong(t,sl,tp))
     {
      if(sl==EMPTY_VALUE) sl=t.StopLoss();
      if(tp==EMPTY_VALUE) tp=t.TakeProfit();
      return(TrailingStopLong(t,sl,tp));
     }

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::CheckTrailingStopShort(CTableOrder *t)
  {
   Debug("CExpertModel::CheckTrailingStopShort");

   double sl=EMPTY_VALUE;
   double tp=EMPTY_VALUE;

   CExpertModelTrailing *trailing=(CExpertModelTrailing *)m_trailing;
   if(trailing.CheckTrailingStopShort(t,sl,tp))
     {
      if(sl==EMPTY_VALUE) sl=t.StopLoss();
      if(tp==EMPTY_VALUE) tp=t.TakeProfit();
      return(TrailingStopShort(t,sl,tp));
     }

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::TrailingStopLong(CTableOrder *t,double sl,double tp)
  {
   Debug("CExpertModel::TrailingStopLong");

   t.StopLoss(sl);
   t.TakeProfit(tp);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::TrailingStopShort(CTableOrder *t,double sl,double tp)
  {
   Debug("CExpertModel::TrailingStopShort");

   t.StopLoss(sl);
   t.TakeProfit(tp);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::CheckCloseLong()
  {
   Debug("CExpertModel::CheckCloseLong");
   CExpertModelSignal *signal=(CExpertModelSignal *)m_signal;
   double price=EMPTY_VALUE;
   if(signal.CheckCloseLong(NULL,price))
     {
      CTableOrder *t=m_listTableOrders.GetFirstNode();
      bool r=true;
      while(t!=NULL)
        {
         r &=CloseLong(t,price);
         t=m_listTableOrders.GetNextNode();
        }
      return r;
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::CheckCloseLong(CTableOrder *t)
  {
   Debug("CExpertModel::CheckCloseLong Order");

   CExpertModelSignal *signal=(CExpertModelSignal *)m_signal;
   double price=EMPTY_VALUE;
   if(signal.CheckCloseLong(t,price))
      return(CloseLong(t,price));
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::CheckCloseShort()
  {
   Debug("CExpertModel::CheckCloseShort");

   CExpertModelSignal *signal=(CExpertModelSignal *)m_signal;
   double price=EMPTY_VALUE;
   if(signal.CheckCloseShort(NULL,price))
     {
      CTableOrder *t=m_listTableOrders.GetFirstNode();
      bool r=true;
      while(t!=NULL)
        {
         r &=CloseShort(t,price);
         t=m_listTableOrders.GetNextNode();
        }
      return r;
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertModel::CheckCloseShort(CTableOrder *t)
  {
   Debug("CExpertModel::CheckCloseShort Order");

   CExpertModelSignal *signal=(CExpertModelSignal *)m_signal;
   double price=EMPTY_VALUE;
   if(signal.CheckCloseShort(t,price))
      return(CloseShort(t,price));
   return(false);
  }
//+------------------------------------------------------------------+
