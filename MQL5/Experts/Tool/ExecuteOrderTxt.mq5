//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2010, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright   "zephyrrr"
#property version     "1.00"
#property description ""

//---- include object oriented framework
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Indicators\Indicators.mqh>
#include <Files\FileTxt.mqh>
#include <Utils\Utils.mqh>

double EveryVolume = 0.01;
double MaxVolume = 15;
int TakeProfit = 1000;
int StopLoss = 500;
int BreakEven = 300;

#include <Data\ea_order.mqh>
string orderFileName = "";

//+------------------------------------------------------------------+
//| MA crossover example expert class                                |
//+------------------------------------------------------------------+
class CExecuteOrderTxt
{
private:
    bool              Initialized;
    bool              Running;
    ulong             OrderNumber;
    double            GetSize();
    //---- input parameters
    int     Magic;
    int     Slippage;
    
    int     m_tp;
    int     m_sl;
    double  Lots;
    
    string m_dealType[];
    datetime m_dealTime[];
    long m_dealBl[];
    long m_dealTp[];
    long m_dealSl[];
    double m_dealProb[];
    int m_currentTimeIdx;
private:
    void AddToHistory(string s, int i);
    string GetSubString(string s,int &idx,int &idx2);
protected:
    string            m_Pair;                    // Currency pair to trade
    CTrade            m_trade;                   // Trading object
    CSymbolInfo       m_symbol;                  // Symbol info object
    CPositionInfo     m_position;                // Position info object
    void              InitSystem();
    bool              CheckEntry();
    bool              CheckExit();

public:
                     CExecuteOrderTxt();               // Constructor
                    ~CExecuteOrderTxt() { Deinit(); }  // Destructor
    bool              Init(string Pair);
    void              Deinit();
    bool              Validated();
    bool              Execute();
};


//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CExecuteOrderTxt::CExecuteOrderTxt()
{
    Initialized=false;

    Magic=12345;
    Slippage=30;

    m_tp=TakeProfit;
    m_sl=StopLoss;

    Lots=0.1;
}
//+------------------------------------------------------------------+
//| Performs system initialisation                                   |
//+------------------------------------------------------------------+
bool CExecuteOrderTxt::Init(string Pair)
{
    m_Pair=Pair;
    m_symbol.Name(m_Pair);                // Symbol
    m_trade.SetExpertMagicNumber(Magic);  // Magic number

    m_trade.SetDeviationInPoints(Slippage);

    MathSrand((int)TimeLocal()); // Initialize random number generator

    Print("Begin Read Order Text.");
  
    int n=0;
    CFileTxt file;
    if (orderFileName != "")
    {
        if(file.Open(orderFileName,FILE_READ)==INVALID_HANDLE)
        {
            Alert("Error Open stat file ",GetLastError(),"!!");
            return false;
        }

        while(true)
        {
            if(file.IsEnding())
                break;
            string s=file.ReadString();
            n++;
        }
    }
    else
    {
        n = ArraySize(m_historyDealsTxt);
    }
    
    ArrayResize(m_dealType,n);
    ArrayResize(m_dealTime,n);
    ArrayResize(m_dealBl,n);
    ArrayResize(m_dealTp,n);
    ArrayResize(m_dealSl,n);
    ArrayResize(m_dealProb,n);

    if (orderFileName != "")
    {
        file.Seek(0,SEEK_SET);
    
        int i=0;
        while(true)
        {
            if(file.IsEnding())
                break;
            string s=file.ReadString();
          
            AddToHistory(s, i);
            i++;
        }
    }
    else
    {
        for(int i=0; i<n; ++i)
        {
            AddToHistory(m_historyDealsTxt[i], i);
        }
    }
    
    m_currentTimeIdx = 0;
    Print("Read Order Text OK");
   
    Initialized=true;

    return(true);
}

CExecuteOrderTxt::AddToHistory(string s, int i)
{
    int idx=0,idx2=0;
    idx = 0; idx2 = 0;
        string s1=GetSubString(s,idx,idx2);
        m_dealType[i]=s1;

        s1=GetSubString(s,idx,idx2);
        // 2011-01-17T01:00:00 -> 2011.01.17 01:00
        if (StringLen(s1) == 19)
            s1 = StringSubstr(s1, 0, 16);
        StringReplace(s1, "-", ".");
        StringReplace(s1, "T", " ");
        m_dealTime[i]=StringToTime(s1);

        s1=GetSubString(s,idx,idx2);
        m_dealTp[i]=StringToInteger(s1);

        s1=GetSubString(s,idx,idx2);
        m_dealSl[i]=StringToInteger(s1);

        s1=GetSubString(s,idx,idx2);
        m_dealBl[i]=StringToInteger(s1);
        
        s1 = GetSubString(s, idx, idx2);
        m_dealProb[i] = StringToDouble(s1); 
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
CExecuteOrderTxt::Deinit()
{
    if (Initialized)
    {
        Initialized=false;
    
        Print("DeInitialized OK");
    }
}

//+------------------------------------------------------------------+
//| Checks if everything initialized successfully                    |
//+------------------------------------------------------------------+
bool CExecuteOrderTxt::Validated()
{
    return(Initialized);
}
//+------------------------------------------------------------------+
//| Performs system reinitialisation                                 |
//+------------------------------------------------------------------+
void CExecuteOrderTxt::InitSystem()
{
    Running=false;
    Initialized=true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CExecuteOrderTxt::GetSubString(string s,int &idx,int &idx2)
{
    idx2=StringFind(s,",",idx);
    if(idx2== -1)
        idx2= StringLen(s);

    string symbol=StringSubstr(s,idx,idx2-idx);
    StringTrimLeft(symbol);
    StringTrimRight(symbol);
    idx=idx2+1;
    return symbol;
}
//+------------------------------------------------------------------+
//| Performs system logic. Called on every tick                      |
//+------------------------------------------------------------------+
bool CExecuteOrderTxt::Execute()
{
    CheckEntry();
  
   //if(Running)
   //  {                   // Are we in a trade at the moment?
   //   if(CheckExit()>0)
   //     {        // Yes - Last trade complete?
   //      Initialized = false;       // Yes - Indicate we need to reinitialise
   //      InitSystem();              //  and start all over again!
   //     }
   //  }
   //else
   //  {
   //   if(CheckEntry()>0)
   //     {       // Entered a trade?
   //      Running=true;            // Yes - Indicate that we're in a trade
   //     }
   //  }
    return(true);
}

//+------------------------------------------------------------------+
//| Returns trade size based on money management system (if any!)    |
//+------------------------------------------------------------------+
double CExecuteOrderTxt::GetSize()
{
    double v = NormalizeDouble((Lots) * AccountInfoDouble(ACCOUNT_BALANCE) / 10000, 1);
    return MathMin(v, 500);
    //return 1;
}
  
bool CExecuteOrderTxt::CheckEntry()
{
    if(m_position.Select(m_symbol.Name()))
    {
        if (m_position.Volume() >= MaxVolume)
            return false;
    }
    bool limitOrder = false;
  
    datetime now = TimeCurrent();
    
    if (m_currentTimeIdx >= ArraySize(m_dealTime))
    {
        if(PositionSelect(Symbol()))
        {
            m_trade.PositionClose(Symbol());
        }
        return false;
    }
    
    /*if(PositionSelect(Symbol()))
    {
        datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
        if (dt - openTime >= 60 * 60 * 6)
        {
            m_trade.PositionClose(Symbol());
        }
    }*/
    
    for(int i=m_currentTimeIdx; i<ArraySize(m_dealTime);++i)
    {
        datetime dealTime = m_dealTime[i];
        if (dealTime > now)
        {
            //Print("not now.", m_currentTimeIdx, dealTime);
            return false;
        }
            
        string nowDealType;
        nowDealType = m_dealType[i];
        /*MathSrand((uint)TimeCurrent());
        int rand = MathRand();
        if (rand < 32767 / 3)
            nowDealType = "Buy";
        //else if (rand > 32767 * 2 / 3)
            //    nowDealType = "Sell";
        else
            nowDealType = "Hold";*/
        m_currentTimeIdx = i + 1;     
        if(dealTime == now)
        {
            //Print("Now idx is " + m_currentTimeIdx);
            
            //Print("Find Pattern ", m_dealType[i], " ", TimeToString(m_dealTime[i]));
            
            //if(m_dealType[i]=="Hold")
            //    m_dealType[i] = "Quit";
                

            if(nowDealType != "Buy" && nowDealType != "Sell" && nowDealType != "Quit" && nowDealType != "Hold")
               return false;
                    

            if(nowDealType == "Quit")
                return false;
            if(nowDealType == "Hold")
                return false;
                
            if(nowDealType=="Quit")
            {
               if(m_position.Select(m_symbol.Name()))
               {
                  m_trade.PositionClose(m_position.Symbol());
                  Print("Close Position");
               }
               return false;
            }
            
            /*if (nowDealType = "Sell")
                nowDealType = "Buy";
            else
                nowDealType = "Sell";*/
                
            /*if(nowDealType=="Buy")
            {
               if ((double)m_dealBl[i] / m_dealSl[i] < 0.0)
                  return false;
            }
            else if (nowDealType=="Sell")
            {
               if ((double)m_dealTp[i] / m_dealSl[i] < 0.0)
                  return false;
            }*/
            
            m_symbol.RefreshRates();
            
            /*if(m_position.Select(Symbol()))
            {
                if (m_position.PositionType() == POSITION_TYPE_BUY)
                {
                    if (m_position.PriceCurrent() - m_position.PriceOpen() >= BreakEven * Points)
                    {
                        m_trade.PositionModify(m_position.Symbol(), m_position.PriceCurrent(), m_position.TakeProfit());
                    }
                }
                else if (m_position.PositionType() == POSITION_TYPE_SELL)
                {
                    if (m_position.PriceCurrent() - m_position.PriceOpen() <= -BreakEven * Points)
                    {
                        m_trade.PositionModify(m_position.Symbol(), m_position.PriceCurrent(), m_position.TakeProfit());
                    }
                }
            }*/

            // Close all pending order
            int total=OrdersTotal();
            for(int k=0;k<total;k++)
            {
                ulong ticket = OrderGetTicket(k);
                //if (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_LIMIT && nowDealType=="Buy")
                // return false;
                //if (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_SELL_LIMIT && nowDealType=="Sell")
                // return false;
                
                m_trade.OrderDelete(ticket);
                Print("Delete Order "+IntegerToString(ticket));
            }

            // if exist, return;
            if(m_position.Select(m_symbol.Name()))
            {
                if (m_position.PositionType() == POSITION_TYPE_BUY && nowDealType=="Buy")
                {
                    //if (PositionGetDouble(POSITION_PROFIT) > 0)
                    //return false;
                }
                else if (m_position.PositionType() == POSITION_TYPE_SELL && nowDealType=="Sell")
                {
                    //if (PositionGetDouble(POSITION_PROFIT) > 0)
                    //return false;
                } 
                else 
                {
                    m_trade.PositionClose(m_symbol.Name());
                    //Print("Close Position");
                }
            }

            double volume;// = MathMax(1, MathRound(GetSize() * m_dealProb[i] / 500));
            volume = GetSize();
            volume = EveryVolume;

            if(nowDealType=="Buy")
            {
                double tp, sl;
                if (m_dealTp[i] != 0)
                {
                    tp = m_symbol.Ask() + m_symbol.Point() * GetPointOffset(m_symbol.Digits()) * m_dealTp[i];
                    sl = m_symbol.Ask() - m_symbol.Point() * GetPointOffset(m_symbol.Digits()) * m_dealSl[i];
                }
                else
                {
                    tp = m_symbol.Ask() + m_symbol.Point() * GetPointOffset(m_symbol.Digits()) * m_tp;
                    sl = m_symbol.Ask() - m_symbol.Point() * GetPointOffset(m_symbol.Digits()) * m_sl;
                }

               double inPrice = m_symbol.Ask();
               if (!limitOrder)
               {
                  m_trade.Buy(volume, m_symbol.Name(), m_symbol.Ask(), sl, tp);
               }
               else
               {
                  inPrice = m_symbol.Ask()-0.00100;
                  //inPrice=MathMax(m_symbol.Ask()-0.0015, inPrice);
                  //inPrice = MathMax(inPrice, m_symbol.Ask()+ (Points * m_dealBl[i]));
               
                  m_trade.BuyLimit(volume, inPrice, m_symbol.Name(), sl, tp);
               }
               
               //Print("Open Buy in ",DoubleToString(inPrice), ", ", DoubleToString(volume), " with sl ",DoubleToString(sl)," and tp ",DoubleToString(tp));
            }
            else if(nowDealType=="Sell")
            {
               double tp, sl;
                if (m_dealTp[i] != 0)
                {
                    tp = m_symbol.Bid() - m_symbol.Point() * GetPointOffset(m_symbol.Digits()) * m_dealTp[i];
                    sl = m_symbol.Bid() + m_symbol.Point() * GetPointOffset(m_symbol.Digits()) * m_dealSl[i];
                }
                else
                {
                    tp = m_symbol.Bid() - m_symbol.Point() * GetPointOffset(m_symbol.Digits()) * m_tp;
                    sl = m_symbol.Bid() + m_symbol.Point() * GetPointOffset(m_symbol.Digits()) * m_sl;
                }
               
               double inPrice = m_symbol.Bid();
               if (!limitOrder)
               {
                  m_trade.Sell(volume, m_symbol.Name(), m_symbol.Bid(), sl, tp);
               }
               else
               {
                  inPrice = m_symbol.Bid() + 0.0010;
                  //inPrice=MathMin(m_symbol.Bid() + 0.0015, inPrice);
                  //inPrice = MathMax(inPrice, m_symbol.Bid()+ (Points * m_dealBl[i]));
               
                  m_trade.SellLimit(volume, inPrice,m_symbol.Name(),sl,tp);
               }
               //Print("Open Sell in ",DoubleToString(inPrice), ", ", DoubleToString(volume), " with sl ",DoubleToString(sl)," and tp ",DoubleToString(tp));
            }
            else
            {
               Alert("UnProcessed " + nowDealType);
            }
            break;
        }
    }
    return(false);
}

bool CExecuteOrderTxt::CheckExit()
{
   return(false);
}

CExecuteOrderTxt m_ea;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    if(!m_ea.Init(Symbol()))
    {
        return(-1);
    }
    return 0;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    m_ea.Deinit();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    if(!m_ea.Validated())
    {
        return;
    }

    m_ea.Execute();
}