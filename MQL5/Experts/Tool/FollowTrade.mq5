//+------------------------------------------------------------------+
//|                                                  followtrade.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>
#include <Files\FileTxt.mqh>
#include <errordescription.mqh>

input string followAccountName = "bobsley";
input double volumnDouble = 0.2;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    m_historyOrderCount = HistoryOrdersTotal();
    EventSetTimer(1);
    
    return(0);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    EventKillTimer();
}

long m_fileOffset = 0;
CFileTxt m_tradeFile;
void OnTimer()
{
    m_tradeFile.SetCommon(true);
    if (m_tradeFile.Open(followAccountName + "_trade.log", FILE_READ) == INVALID_HANDLE)
    //if (m_tradeFile.Open("example.log", FILE_COMMON | FILE_READ) == INVALID_HANDLE)
        return;
    
    while(true)
    {    
        m_tradeFile.Seek(m_fileOffset, SEEK_SET);
        if (m_tradeFile.IsEnding())
            break;
        string s = m_tradeFile.ReadString();
        if (s == NULL || StringLen(s) == 0)
        {
            m_fileOffset++;
            break;
        }
        Print("GetString " + s + ", " + IntegerToString(StringLen(s)));
        m_fileOffset += StringLen(s) + 1;
        StringTrimLeft(s);
        StringTrimRight(s);
        if (s == "")
            break;
            
        

        if (StringSubstr(s, 0, 3) == "REM")
            continue;
            
        int idx = StringFind(s, "\t");
        string cmd = StringSubstr(s, idx, StringLen(s) - idx);
        bool ret = ProcessCmd(cmd);
        if (!ret)
        {
            PrintError("Process Command " + cmd + " Failed!");
        }
        else
        {
            Print("Process Command " + cmd + " Succeed!");
        }
    }
    m_tradeFile.Close();
    m_historyOrderCount = HistoryOrdersTotal();
}
void PrintError(string msg)
{
    int error=GetLastError();
    
    Print(msg + " Error #", ErrorDescription(error), ", Trade Result #", m_trade.ResultRetcodeDescription());
    ResetLastError();
}

//+------------------------------------------------------------------+
long m_historyOrderCount = 0;

CTrade m_trade;
string GetSubString(string s, int& idx, int& idx2)
{
    idx2 = StringFind(s, ",", idx);
    string symbol = StringSubstr(s, idx, idx2 - idx);
    StringTrimLeft(symbol);
    StringTrimRight(symbol);
    idx = idx2 + 1;
    return symbol;
}

bool ProcessCmd(string cmd)
{
    // "OrderOpen", "OrderDelete", "PositionModify", "OrderModify"
    m_trade.SetDeviationInPoints(10);
    
    int idx = 0;
    int idx2 = StringFind(cmd, "(", idx);
    if (idx2 == 0)
        return false;
    string cmdType = StringSubstr(cmd, idx, idx2 - idx);
    StringTrimLeft(cmdType);
    StringTrimRight(cmdType);
    idx = idx2 + 1;
    
    bool ret = false;
    // OrderOpen(1234, EURUSD,ORDER_TYPE_BUY_LIMIT, 1.00000, 0.00000, 0.38721, 0.00000, 0.00000, 0,0,)
    if (cmdType == "OrderOpen")
    {
        long magic = StringToInteger(GetSubString(cmd, idx, idx2));
        
        string symbol = GetSubString(cmd, idx, idx2);

        string order_type_string = GetSubString(cmd, idx, idx2);
        ENUM_ORDER_TYPE order_type = -1;
        if (order_type_string == "ORDER_TYPE_BUY")
            order_type = ORDER_TYPE_BUY;
        else if (order_type_string == "ORDER_TYPE_SELL")
            order_type = ORDER_TYPE_SELL;
        else if (order_type_string == "ORDER_TYPE_BUY_LIMIT")
            order_type = ORDER_TYPE_BUY_LIMIT;
        else if (order_type_string == "ORDER_TYPE_SELL_LIMIT")
            order_type = ORDER_TYPE_SELL_LIMIT;
        else if (order_type_string == "ORDER_TYPE_BUY_STOP")
            order_type = ORDER_TYPE_BUY_STOP;
        else if (order_type_string == "ORDER_TYPE_SELL_STOP")
            order_type = ORDER_TYPE_SELL_STOP;
        else if (order_type_string == "ORDER_TYPE_BUY_STOP_LIMIT")
            order_type = ORDER_TYPE_BUY_STOP_LIMIT;
        else if (order_type_string == "ORDER_TYPE_SELL_STOP_LIMIT")
            order_type = ORDER_TYPE_SELL_STOP_LIMIT;
        else
            return false;
        if (order_type == -1)
            return false;
                           
        double volumn = StringToDouble(GetSubString(cmd, idx, idx2)) * volumnDouble;
        double limit_price = StringToDouble(GetSubString(cmd, idx, idx2));
        double price = StringToDouble(GetSubString(cmd, idx, idx2));
        double sl = StringToDouble(GetSubString(cmd, idx, idx2));
        double tp = StringToDouble(GetSubString(cmd, idx, idx2));

        if (m_historyOrderCount == HistoryOrdersTotal())
        {
            m_trade.SetExpertMagicNumber(magic);
            if (order_type == ORDER_TYPE_BUY)
            {
                ret = m_trade.Buy(volumn, symbol);
            }
            else if (order_type == ORDER_TYPE_SELL)
            {
                ret = m_trade.Sell(volumn, symbol);
            }
            else
            {
                ret = m_trade.OrderOpen(symbol, order_type, volumn, limit_price, price, sl, tp, 0, 0, "");
            }
        }
        else
        {
            Print("History Count = " + IntegerToString(m_historyOrderCount));
            m_historyOrderCount++;
        }
    }
    // OrderModify(1, 1877932, 1.08617, 0.00000, 0.00000, 0, 0) // add position id
    else if (cmdType == "OrderModify")
    {
        uint position = (int)StringToInteger(GetSubString(cmd, idx, idx2));
        long ticket = StringToInteger(GetSubString(cmd, idx, idx2));
        
        double price = StringToDouble(GetSubString(cmd, idx, idx2));
        double sl = StringToDouble(GetSubString(cmd, idx, idx2));
        double tp = StringToDouble(GetSubString(cmd, idx, idx2));
        
        ticket = OrderGetTicket(position);
        if (ticket != 0)
        {
            ret = m_trade.OrderModify(ticket, price, sl, tp, 0, 0);
        }
        else
        {
            return false;
        }
    }
    // OrderDelete(0,1877945)
    else if (cmdType == "OrderDelete")
    {
        long magic = StringToInteger(GetSubString(cmd, idx, idx2));
        long ticket = StringToInteger(GetSubString(cmd, idx, idx2));
        
        bool find = false;
        uint total=OrdersTotal();
        for(uint i=0;i<total;i++)
        {
            ticket = OrderGetTicket(i);
            long m = OrderGetInteger(ORDER_MAGIC);
            if (m == magic)
            {
                find = true;
                ret = m_trade.OrderDelete(ticket);
                break;
            }
        }
        if (!find)
        {
            return false;
        }
    }
    // PositionModify(EURUSD, 1.39574, 0.00000)
    else if (cmdType == "PositionModify")
    {
        string symbol = GetSubString(cmd, idx, idx2);
        double sl = StringToDouble(GetSubString(cmd, idx, idx2));
        double tp = StringToDouble(GetSubString(cmd, idx, idx2));
        
        ret = m_trade.PositionModify(symbol, sl, tp);
    }
//    else if (cmdType == "PositionOpen")
//    {
//        string symbol = GetSubString(cmd, idx, idx2);
//
//        string order_type_string = GetSubString(cmd, idx, idx2);
//        ENUM_ORDER_TYPE order_type = ORDER_TYPE_BUY;
//        if (order_type_string == "ORDER_TYPE_BUY")
//            order_type = ORDER_TYPE_BUY;
//        else if (order_type_string == "ORDER_TYPE_SELL")
//            order_type = ORDER_TYPE_SELL;
//        else
//            return false;
//                        
//        double volumn = StringToDouble(GetSubString(cmd, idx, idx2)) * volumnDouble;
//        double price = StringToDouble(GetSubString(cmd, idx, idx2));
//        double sl = StringToDouble(GetSubString(cmd, idx, idx2));
//        double tp = StringToDouble(GetSubString(cmd, idx, idx2));
//        
//        m_trade.PositionOpen(symbol, ORDER_TYPE_BUY, volumn, price, sl, tp, "");
//    }
    else
    {
        return false;
    }
    
    //trade.OrderOpen();
    return ret;
}
