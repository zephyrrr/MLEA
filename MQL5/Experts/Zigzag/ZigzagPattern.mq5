//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2010, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright   "zephyrrr"
#property link        ""
#property version     "1.00"
#property description ""

//---- include object oriented framework
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Indicators\Indicators.mqh>
#include <Files\FileTxt.mqh>
#include <Utils.mqh>
#include <ZigzagPatternValueColor.mqh>
//#include <ZigzagPatternValue.mqh>
#include <ZigzagPatternData\ZigzagPatternData_70_35.mq5>
//#include <ZigzagPatternData\ZigzagPatternData_70_35_oldest.mq5>

//---- input parameters
int     Magic=12345;
int     Slippage=30;

input int ProfitTarget=700;
input int StopLoss=350;
input double ProbLimit = 0.93;
input int CountLimit = 6;
input bool UseOneLot = false;

double  Lots=1;
//+------------------------------------------------------------------+
//| MA crossover example expert class                                |
//+------------------------------------------------------------------+
class CZigzagPattern
  {
private:
   int               Dig;
   double            Points;
   bool              Initialized;
   bool              Running;
   ulong             OrderNumber;
   double            GetSize();
   
protected:
   string            m_Pair;                    // Currency pair to trade
   CTrade            m_Trade;                   // Trading object
   CSymbolInfo       m_Symbol;                  // Symbol info object
   CPositionInfo     m_Position;                // Position info object
   void              InitSystem();
   bool              CheckEntry();
   bool              CheckExit();

public:
                     CZigzagPattern();               // Constructor
                    ~CZigzagPattern() { Deinit(); }  // Destructor
   bool              Init(string Pair);
   void              Deinit();
   bool              Validated();
   bool              Execute();
  };

CZigzagPattern m_ea;
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CZigzagPattern::CZigzagPattern()
  {
   Initialized=false;
  }
//+------------------------------------------------------------------+
//| Performs system initialisation                                   |
//+------------------------------------------------------------------+
bool CZigzagPattern::Init(string Pair)
  {
   m_Pair=Pair;
   m_Symbol.Name(m_Pair);                // Symbol
   m_Trade.SetExpertMagicNumber(Magic);  // Magic number
    m_Trade.LogLevel(0);
    
   Dig=m_Symbol.Digits();
   Points=m_Symbol.Point();
   m_Trade.SetDeviationInPoints(Slippage);

   Print("Digits = ",Dig,", Points = ",DoubleToString(Points,Dig));

   MathSrand((int)TimeLocal()); // Initialize random number generator

   Initialized=true;

   return(true);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
CZigzagPattern::Deinit()
  {
   Initialized=false;

   Print("DeInitialized OK");
  }

//+------------------------------------------------------------------+
//| Checks if everything initialized successfully                    |
//+------------------------------------------------------------------+
bool CZigzagPattern::Validated()
  {
   return(Initialized);
  }
//+------------------------------------------------------------------+
//| Performs system reinitialisation                                 |
//+------------------------------------------------------------------+
void CZigzagPattern::InitSystem()
  {
   Running=false;
   Initialized=true;
  }
//+------------------------------------------------------------------+
//| Performs system logic. Called on every tick                      |
//+------------------------------------------------------------------+
bool CZigzagPattern::Execute()
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
double CZigzagPattern::GetSize()
{
    double v = NormalizeDouble((Lots) * AccountInfoDouble(ACCOUNT_BALANCE) / 10000, 1);
    if (UseOneLot)
        return 1;
    else
        return MathMin(v, 500);
}

CZigzagPatternValue m_zigzagPatternValue;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    if(!m_ea.Init(Symbol()))
    {
        m_ea.Deinit();
        return(-1);
    }


    Print("Begin Init!");
   
    if (!m_zigzagPatternValue.Init())
        return -1;
    
    //LoadTxt();
    if (!LoadTxtDeal())
    {
      Alert("Error in Load TxtDeal!");
      return -1;
    }
    Print("Initialized OK");
         
    return(0);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    m_ea.Deinit();
    m_zigzagPatternValue.Deinit();
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

    //Print("Now Time is ", TimeToString(m_priceTime[0]));
    
    m_ea.Execute();
}

// 1: Buy; -1: Sell
int GetLastDealType()
{
    HistorySelect(0,TimeCurrent());
    
    int cnt = HistoryDealsTotal();
    //Print("Deal cnt = ", cnt);
    
    if (cnt != 0)
    {
        int idx = cnt - 1;
        while(idx >= 0)
        {
            ulong ticket = HistoryDealGetTicket(idx);
            //HistoryDealSelect(ticket);
            if (HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT)
            {
                double p = HistoryDealGetDouble(ticket, DEAL_PROFIT);
                if (p > 0)
                {
                    if (HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_BUY)
                        return -1;
                    else
                        return 1;
                }
                else
                {
                    if (HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_BUY)
                        return 1;
                    else
                        return -1;
                }
            }
            idx--;
        }
    }
    return 0;
}

#define maxPatternCnt 50
double buyProb[2 * (maxPatternCnt + 1) * (maxPatternCnt + 1) * 2];
double sellProb[2 * (maxPatternCnt + 1) * (maxPatternCnt + 1) * 2];

int GetPatternInt(int i1, int i2, int i3, int i4)
{
    return i1 * ((maxPatternCnt + 1) * (maxPatternCnt + 1) * 2) + i2 * ((maxPatternCnt + 1) * 2) + i3 * 2 + i4;
}
int GetPatternInt(string p)
{
    int idx1 = StringFind(p, ",");
    int idx2 = StringFind(p, ",", idx1 + 1);
    string p0 = StringSubstr(p, 0, idx1);
    string p1 = StringSubstr(p, idx1 + 1, idx2 - idx1 - 1);
    string p2 = StringSubstr(p, idx2 + 1);
    int ip1 = (int)StringToInteger(p1);
    int ip2 = (int)StringToInteger(p2);
    
    ip1 = (int)MathMin(ip1, maxPatternCnt - 1);
    ip2 = (int)MathMin(ip2, maxPatternCnt - 1);
    int hl = p0 == "H" ? 0 : 1;
    
    return GetPatternInt(hl, ip1, ip2, 0);
}

int m_historyDealsTxtIdx = 0;
bool LoadTxtDeal()
{
    //return LoadTxtDeal_oldest();

    if (m_historyDealsTxtIdx == ArraySize(m_historyDealsTxt))
       return true;
       
    while(true)
    {
        string s = m_historyDealsTxt[m_historyDealsTxtIdx];
        if (s != NULL && StringLen(s) > 0)
        {
            //Print(s);
            int idx=0,idx2=0;
            string s1=GetSubString(s, idx, idx2);
            string s2=GetSubString(s, idx, idx2);
            string s3=GetSubString(s, idx, idx2);
            string s4=GetSubString(s, idx, idx2);
            string s5=GetSubString(s, idx, idx2);
            string s6=GetSubString(s, idx, idx2);
            string s7=GetSubString(s, idx, idx2);
            string s8=GetSubString(s, idx, idx2);
            
            if (s5 != "None")
            {
                datetime closeTime = StringToTime(s4);
                if ((!(bool)MQL5InfoInteger(MQL5_TESTING) || closeTime < TimeCurrent()))
                {
                    //int i1 = StringSubstr(s1, 0, 1) == "H" ? 0 : 1;
                    //string i2s = StringSubstr(s1, 2, StringSubstr(s1, 3, 1) == "," ? 1 : 2);
                    //string i3s = StringSubstr(s1, 2 + StringLen(i2s) + 1);
                    //int i2 = (int)StringToInteger(i2s);
                    //int i3 = (int)StringToInteger(i3s);
                    //i2 = (int)MathMin(i2, maxPatternCnt - 1);
                    //i3 = (int)MathMin(i3, maxPatternCnt - 1);
                    int i4 = s5 == "True" ? 0 : 1;
                
                    int pii = GetPatternInt(s2);
                    int pi = i4 == 1 ? pii + 1 : pii;
                    
                    //int lastPi = GetPatternInt(s8);
                    //lastPi = 0;
                        
                    if (s7 == "Buy")
                    {
                        //buyProb[lastPi0][pi0] *= 1;
                        //buyProb[lastPi0 + 1][pi0 + 1] *= 1;
                        buyProb[pi]++;
                    }
                    else
                    {
                        //sellProb[lastPi0][pi0] *= 1;
                        //sellProb[lastPi0 + 1][pi0 + 1] *= 1;
                        sellProb[pi]++;
                    }
                }
                else
                {
                    break;
                }
            }

            m_historyDealsTxtIdx++;
            if (m_historyDealsTxtIdx == ArraySize(m_historyDealsTxt))
                break;
        }
        else
        {
            break;
        }
    }
    
    return true;
}

bool LoadTxtDeal_oldest()
{
    if (m_historyDealsTxtIdx == ArraySize(m_historyDealsTxt))
       return true;
       
    while(true)
    {
        string s = m_historyDealsTxt[m_historyDealsTxtIdx];
        if (s != NULL && StringLen(s) > 0)
        {
            //Print(s);
            int idx=0,idx2=0;
            string s1=GetSubString(s,idx,idx2);
            string s2=GetSubString(s,idx,idx2);
            string s3=GetSubString(s,idx,idx2);
            string s4=GetSubString(s,idx,idx2);
            string s5=GetSubString(s,idx,idx2);
            string s6=GetSubString(s, idx, idx2);
            
            if (s4 == "None")
            {
                Alert("None result in pattern3Detail!");
                return false;
            }
        
            //if ((bool)MQL5InfoInteger(MQL5_TESTING))
            //{
                //Print("Now file time is ", s3);
            //}
        
            datetime closeTime = StringToTime(s3);

            if ((!(bool)MQL5InfoInteger(MQL5_TESTING) || closeTime < TimeCurrent()))
            {
                //int i1 = StringSubstr(s1, 0, 1) == "H" ? 0 : 1;
                //string i2s = StringSubstr(s1, 2, StringSubstr(s1, 3, 1) == "," ? 1 : 2);
                //string i3s = StringSubstr(s1, 2 + StringLen(i2s) + 1);
                //int i2 = (int)StringToInteger(i2s);
                //int i3 = (int)StringToInteger(i3s);
                //i2 = (int)MathMin(i2, maxPatternCnt - 1);
                //i3 = (int)MathMin(i3, maxPatternCnt - 1);
                int i4 = s4 == "True" ? 0 : 1;
            
                int pii = GetPatternInt(s1);
                int pi = i4 == 1 ? pii + 1 : pii;
                
                int lastPi = GetPatternInt(s6);
                lastPi = 0;
                    
                if (s5 == "Buy")
                {
                    //buyProb[lastPi0][pi0] *= 1;
                    //buyProb[lastPi0 + 1][pi0 + 1] *= 1;
                    buyProb[pi]++;
                }
                else
                {
                    //sellProb[lastPi0][pi0] *= 1;
                    //sellProb[lastPi0 + 1][pi0 + 1] *= 1;
                    sellProb[pi]++;
                }
            }
            m_historyDealsTxtIdx++;
            if (m_historyDealsTxtIdx == ArraySize(m_historyDealsTxt))
                break;
        }
        else
        {
            break;
        }
    }
    
    return true;
}

string m_lastZigzag;
bool CZigzagPattern::CheckEntry()
{  
    //if (TimeCurrent() % 60 * 5 != 0)
    //    return false;
        
    LoadTxtDeal();
    
    bool limitOrder = false;
    bool buy = false, sell = false;
    
    //double zigzagValuesLatest[100];
    string p = m_zigzagPatternValue.GetZigzagPatternLatest();
    if (p == m_lastZigzag)
      return false;
    
    //m_lastZigzag = p;
    //Print(TimeToString(TimeCurrent()), ", ", p);
    //if (StringSubstr(TimeToString(TimeCurrent()), 0, 16) == "2008.01.09 16:47")
    //{
    //    for(int i=0; i<100; ++i)
    //        Print(zigzagValuesLatest[i]);
    //}
    //return false;
     
    int pi0 = GetPatternInt(p);
    
    string comment;
    //if (m_lastZigzag != NULL)
    {
        int lastPi0 = GetPatternInt(m_lastZigzag);
        
        double ta = buyProb[pi0];
        double tb = buyProb[pi0 + 1];
        double t1 = tb != 0 ? ta / tb : 1;
        //t1 = tb != 0 ? (ta - 1) / (tb + 1) : 1;
        
        //Print(" Zigzag = ", p, " Last is ", m_lastZigzag,  ", ta = ", ta, ", tb = ", tb);
        
        comment = p;// + ", " + m_lastZigzag;
        comment += ",B:" + DoubleToString(t1, 1) + "," + DoubleToString(ta, 0) + "," + DoubleToString(tb, 0);
        if ((tb == 0 && ta > 1) || (t1 > ProbLimit))
        {
            if (ta + tb > CountLimit)
            {
                buy = true;
            }
        }
        ta = sellProb[pi0];
        tb = sellProb[pi0 + 1];
        double t2 = tb != 0 ? ta / tb : 1;
        //t2 = tb != 0 ? (ta - 1) / (tb + 1) : 1;
        
        comment += ",S:" + DoubleToString(t2, 1) + "," + DoubleToString(ta, 0) + "," + DoubleToString(tb, 0);
        if ((tb == 0 && ta > 1) || (t2 > ProbLimit))
        {
            if (ta + tb > CountLimit)
            {
                sell = true;
            }
        }
        if (buy && sell)
        {
            Print("Buy and sell");
            if (t1 > t2) sell = false;
            else buy = false;
            //return false;
        }
        if (!(bool)MQL5InfoInteger(MQL5_TESTING))
        {
            Print(TimeToString(TimeCurrent()), " ", comment);
        }
        
        //if (StringSubstr(TimeToString(TimeCurrent()), 0, 16) == "2009.01.08 09:24")
        //{
        //	Print(p, " ", comment);
        //}
    }
    m_lastZigzag = p;
    //int pWinBuy[] = {1,17,2, 1,17,3, 1,5,1, 1,8,5, 0,2,3, 1,13,4, 0,14,4, 0,15,4, 0,24,4, 1,15,2, 1,4,24, 1,15,24, 1,9,1, 1,14,3, 1,1,13, 0,3,24, 0,1,13, 0,3,8, 1,7,2, 0,5,4, 0,7,24, 1,7,24, 1,12,3, 0,6,21, 0,8,21, 1,1,9, 0,6,4, 1,3,22, 1,3,20, 1,9,3, 1,4,13, 0,6,3, 1,5,7, 1,2,20, 1,10,4, 1,24,10, 0,4,24, 0,8,24, 0,9,24, 1,1,11, 0,2,13, 1,8,2, 0,19,1, 1,5,2, 1,2,13, 1,1,23, 0,16,1, 1,1,19, 0,6,5, 1,3,23, 1,6,3, 0,7,3, 0,4,12, 1,0,23, 1,9,2, 0,6,2, 1,3,4, 1,5,18, 1,7,17, 1,7,22, 0,10,24, 1,9,22, 0,8,2, 0,11,2, 1,3,18, 1,21,5, 1,23,7, 1,23,9, 1,12,2, 1,12,6, 1,2,11, 1,10,22, 0,1,10, 1,5,14, 0,20,4, 0,13,5, 1,13,6, 1,2,15, 1,4,10, 1,4,12, 0,18,24, 1,9,7, 0,6,19, 0,9,19, 1,6,4, 1,8,6, 0,19,3, 1,5,19, 1,4,7, 0,6,7, 0,24,24, 0,1,12, 0,6,6, 1,3,15, 0,5,7, 1,2,19, 1,3,8, 1,7,3, 0,2,15, 0,8,3, 1,12,4, 1,11,4, 0,8,5, 1,4,17, 0,15,2, 1,5,11, 1,1,12, 0,3,12, 0,14,24, 1,2,10, 0,18,1, 0,12,2, 1,3,14, 0,2,9, 0,5,9, 0,5,11, 0,1,21, 0,20,24, 1,7,11, 1,7,13, 0,3,17, 0,4,15, 1,7,7, 0,17,4, 1,2,16, 0,6,22, 0,24,22, 0,20,2, 0,22,2, 1,24,19, 0,23,2, 1,23,3, 0,19,5, 1,23,5, 1,2,17, 1,7,9, 1,7,10, 0,24,20, 0,21,11, 1,3,10, 1,11,22, 1,17,24, 0,22,7, 1,20,3, 1,16,4, 1,16,5, 0,23,5, 0,17,7, 1,5,10, 1,4,8, 1,18,2, 1,24,22, 0,7,6, 0,6,10, 1,4,20, 1,7,6, 0,7,14, 1,13,21, 1,6,10, 1,4,9, 1,2,21, 1,4,11, 1,6,11, 1,6,15, 0,14,5, 0,5,12, 0,17,12, 1,15,3, 0,3,11, 0,6,11, 0,4,9, 0,15,9, 0,16,9, 0,2,22, 0,14,22, 0,7,7, 1,20,2, 0,19,24, 1,6,13, 0,2,21, 0,5,10, 1,5,23, 0,15,12, 0,8,6, 1,12,14, 0,9,6};
    //int pWinSell[] = {1,24,11, 1,24,14, 1,6,5, 1,20,1, 0,3,9, 0,5,5, 1,5,6, 1,4,4, 0,1,18, 0,10,1, 0,12,1, 1,15,6, 1,3,12, 1,14,2, 1,6,6, 0,17,24, 0,1,6, 1,3,9, 0,24,6, 1,12,24, 0,14,3, 1,10,8, 0,4,6, 0,8,9, 0,9,8, 1,4,13, 1,4,15, 1,2,18, 0,22,3, 1,6,8, 0,24,19, 1,10,2, 1,10,4, 1,10,12, 1,10,16, 1,24,9, 0,14,7, 0,21,13, 0,4,4, 0,4,20, 0,6,20, 0,9,4, 0,19,4, 0,13,3, 0,23,0, 0,2,5, 0,14,2, 0,6,5, 1,14,1, 1,14,4, 0,6,16, 1,5,4, 1,5,3, 0,8,22, 0,11,24, 0,4,5, 0,16,7, 1,11,5, 1,11,6, 1,11,24, 1,3,18, 1,21,5, 0,14,1, 0,11,4, 0,13,6, 0,15,6, 1,2,14, 0,1,9, 0,3,23, 0,24,23, 0,20,4, 0,16,2, 0,3,6, 0,1,15, 1,6,4, 0,14,19, 0,5,7, 1,5,8, 0,2,11, 0,2,14, 0,3,14, 1,24,17, 1,22,1, 1,18,5, 1,18,6, 0,4,13, 0,5,13, 0,17,2, 0,14,24, 0,16,24, 0,2,9, 0,1,21, 0,7,10, 0,5,8, 0,14,6, 1,6,7, 0,24,22, 1,24,21, 0,3,21, 0,4,21, 0,5,21, 1,24,18, 1,2,22, 0,10,6, 0,11,6, 1,13,8, 1,13,9, 1,13,24, 1,7,10, 1,5,20, 0,7,8, 1,22,2, 1,14,7, 1,17,24, 1,24,23, 1,10,6, 1,3,17, 0,20,10, 1,14,9, 1,7,15, 0,11,18, 0,24,18, 0,5,16, 1,3,16, 1,7,6, 0,17,1, 1,7,5, 0,19,6, 0,23,24, 1,23,24, 1,4,11, 1,4,14, 0,7,7, 0,11,5, 1,6,16, 0,13,4, 1,21,3, 1,6,12, 1,6,22, 1,8,20, 0,9,23, 1,4,16, 1,16,7, 1,16,24, 0,17,3, 1,14,13};
    //for(int i=0; i<ArraySize(pWinBuy); i+=3)
    //{
    //    if (((p0 == "H" && pWinBuy[i] == 0) || (p0 == "L" && pWinBuy[i] == 1))
    //        && ip1 == pWinBuy[i+1] && ip2 == pWinBuy[i+2])
    //    {
    //        buy = true;
    //        break;
    //    }
    //}
    //for(int i=0; i<ArraySize(pWinSell); i+=3)
    //{
    //    if (((p0 == "H" && pWinSell[i] == 0) || (p0 == "L" && pWinSell[i] == 1))
    //        && ip1 == pWinSell[i+1] && ip2 == pWinSell[i+2])
    //    {
    //        sell = true;
    //        break;
    //    }
    //}
    
    // "H,1,12"
    //if (p0 == "H" && p1 == "6" && p2 == "2")
    //{
        //buy = true;
    //}
    //Print("p = ", p, "  p1 = ", p1, " and p2 = ", p2);

//    int length = 3;
//    long zigzagPattern = GetZigzagPattern();
//    
//    string p = IntegerToString(zigzagPattern, 10, '0');
//    string pHigh = StringSubstr(p, 0, length);
//    string pLow = StringSubstr(p, 5, length);
//    
//    int lastDealType = GetLastDealType();
//    //Print("Last Deal Type is ", lastDealType);
//    lastDealType = 0;
//    
//    double patternLimit = 0.0;
//    double a = 0, b = 0;
//    if (zigzagPattern != -1)
//    {
//        if (IsContain("B" + pHigh) && lastDealType >= 0)
//        {
//            a = StringToDouble(Get("B" + pHigh));
//            //Print(a);
//            if (a > patternLimit)
//            {
//                buy = true;
//            }
//        }
//        if (IsContain("S" + pLow) && lastDealType <= 0)
//        {
//            b = StringToDouble(Get("S" + pLow));
//            //Print(b);
//            if (b > patternLimit)
//            {
//                sell = true;
//            }
//        }
//        
//        if (buy && sell)
//        {
//            if (a > b)
//            {
//                sell = false;
//            }
//            else
//            {
//                buy = false;
//            }
//        }
//        
//        //Print("Get Pattern of ", pHigh, ", ", a, " and ", pLow, ", ", b);
//        //return false;
//    }
   
    if (!buy && !sell)
    {
        //if(PositionSelect(_Symbol))
        //{
        //    m_Trade.PositionClose(_Symbol);
        //    Print("Close Position");
        //}

        return false;
    }
            
    // Close all
    int total=OrdersTotal();
    if (total > 1)
        Alert("Too much order!");
    for(int k=0;k<total;k++)
    {
        ulong ticket = OrderGetTicket(k);
        if (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_LIMIT && buy)
            return false;
        if (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_SELL_LIMIT && sell)
            return false;
                
        m_Trade.OrderDelete(ticket);
        Print("Delete Order "+IntegerToString(ticket));
    }

//    if(PositionSelect(_Symbol))
//    {
//        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && buy)
//            return false;
//        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && sell)
//            return false;
//                 
//        m_Trade.PositionClose(_Symbol);
//        Print("Close Position");
//    }

    m_Symbol.RefreshRates();
    if(buy)
    {
        double tp = m_Symbol.Ask() + (Points * ProfitTarget);
        double sl = m_Symbol.Bid() - (Points * StopLoss);
               
        //tp = MathMin(tp, m_Symbol.Ask() + (Points * m_dealTp[i]));
        //sl = MathMin(sl, m_Symbol.Bid() - (Points * m_dealSl[i]));
               
        double volume;// = MathMax(1, MathRound(GetSize() * m_dealProb[i] / 500));
        volume = GetSize();
               
        double inPrice = m_Symbol.Ask();
        if (!limitOrder)
        {
            m_Trade.Buy(volume, _Symbol, m_Symbol.Ask(), sl, tp, comment);
        }
        else
        {
            inPrice = m_Symbol.Ask()-0.00100;
            //inPrice=MathMax(m_Symbol.Ask()-0.0015, inPrice);
            //inPrice = MathMax(inPrice, m_Symbol.Ask()+ (Points * m_dealBl[i]));
               
            m_Trade.BuyLimit(volume, inPrice, _Symbol, sl, tp, 0, 0, comment);
        }
               
        Print("Open Buy in ",DoubleToString(inPrice), ", ", DoubleToString(volume), " with sl ",DoubleToString(sl)," and tp ",DoubleToString(tp));
    }
    else if(sell)
    {
        double tp = m_Symbol.Bid() - (Points * ProfitTarget);
        double sl = m_Symbol.Ask() + (Points * StopLoss);
        //tp = MathMin(tp, m_Symbol.Bid() - (Points * m_dealTp[i]));
        //sl = MathMin(sl, m_Symbol.Ask() + (Points * m_dealSl[i]));
               
        double volume;// = MathMax(1, MathRound(GetSize() * m_dealProb[i] / 500));
        volume = GetSize();
               
        double inPrice = m_Symbol.Bid();
        if (!limitOrder)
        {
            m_Trade.Sell(volume, _Symbol, m_Symbol.Bid(), sl, tp, comment);
        }
        else
        {
            inPrice = m_Symbol.Bid() + 0.0010;
            //inPrice=MathMin(m_Symbol.Bid() + 0.0015, inPrice);
            //inPrice = MathMax(inPrice, m_Symbol.Bid()+ (Points * m_dealBl[i]));
               
            m_Trade.SellLimit(volume, inPrice,_Symbol,sl,tp, 0, 0, comment);
        }
        Print("Open Sell in ",DoubleToString(inPrice), ", ", DoubleToString(volume), " with sl ",DoubleToString(sl)," and tp ",DoubleToString(tp));
    }    
    return(false);
}

bool CZigzagPattern::CheckExit()
{
   return(false);
}

//int LoadTxt()
//{
//    CFileTxt file;
//    if(file.Open("zigzagPatternAction.txt",FILE_READ)==INVALID_HANDLE)
//    {
//        Alert("Error Open highLowAction file ",GetLastError(),"!!");
//        return -1;
//    }
//    int idx=0,idx2=0;
//
//    file.Seek(0,SEEK_SET);
//
//    int i=0;
//    while(true)
//    {
//        if(file.IsEnding())
//            break;
//        string s=file.ReadString();
//      
//        idx = 0; idx2 = 0;
//        string s1=GetSubString(s,idx,idx2);
//        string s2=GetSubString(s,idx,idx2);
//        string s3=GetSubString(s,idx,idx2);
//        string s4=GetSubString(s,idx,idx2);
//        //string s5=GetSubString(s,idx,idx2);
//        
//        if (StringToInteger(s4) == 0)
//            continue;
//        string l = DoubleToString(StringToDouble(s3) / StringToDouble(s4), 3);
//            
//        bool bPut = false;
//        if (s2 == "Buy")
//        {
//            bPut = Put("B" + s1, l);
//        }
//        else if (s2 == "Sell")
//        {
//            bPut = Put("S" + s1, l);
//        }
//        else if (s2 == "")
//        {
//            Print("Wrong type of ", s1, s2);
//        }
//        else
//        {
//            Print("Wrong type of ", s1, s2);
//        }
//        if (!bPut)
//        {
//            Print("Not put in hash! Wrong type of ", s1, s2);
//        }
//        i++;
//    }
//    
//    Print("Loaded Zigzag Patterns count is ", GetSize());
//    
//    return 0;
//}