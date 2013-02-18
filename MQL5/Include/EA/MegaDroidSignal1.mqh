//+------------------------------------------------------------------+
//|                                             MegaDroidSignal1.mqh |
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
#include "MegaDroidLib1.mqh"
#include <Utils\Utils.mqh>
#include <Utils\mt4timeseries.mqh>

// EURUSD, H1
// 2010.03.26 00:30, 2010.12.15 00:36
class CMegaDroidSignal1 : public CExpertModelSignal
{
public:
	CMegaDroidSignal1();
	~CMegaDroidSignal1();
	virtual bool      ValidationSettings();
	virtual bool      InitIndicators(CIndicators* indicators);

	virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
	virtual bool      CheckCloseLong(CTableOrder* t, double& price);
	virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
	virtual bool      CheckCloseShort(CTableOrder* t, double& price);

	void InitParameters();
private:
    CiRSI m_iRSI_796, m_iRSI_820;
    CiCCI m_iCCI_828;
    CiMA m_iMA_868;
    CiHigh m_iHigh;
    CiLow m_iLow;
    CiClose m_iClose;
private:
    int init();
    void s1_setRules();
    void s1_dayRange();
    int s1_direction();
    //int ProcessPatch(string module, int address, int byte);
    int s1_openBuyRule();
    int s1_openSellRule();
    bool s1_closeBuyRule(CTableOrder* order);
    bool s1_closeSellRule(CTableOrder* order);
    int s1_openBuy(double& price,double& sl,double& tp);
    int s1_openSell(double& price,double& sl,double& tp);
    void Refresh(bool ai_0);
    
    
    int gi_260;
    int gi_684;
    double gd_312;
    int gi_332;
    double g_irsi_796;
    double g_irsi_804;
    double g_irsi_812;
    double g_irsi_820;
    double g_icci_828;
    double g_icci_836;
    double g_icci_844;
    double g_ima_868;
    
    bool gi_256;
    double gd_224;
    bool gi_444;
    bool gi_460;
    int gi_464;
    bool gi_492;
    int gi_928;
    int gi_932;
    datetime gi_936;
    bool gi_900;
    int gi_920;
    int gi_924;
    datetime g_datetime_264;
    int g_spread_284;
    int g_spread_288;
    bool gi_452;
    double gd_296;
    bool gi_520;
    datetime gi_280;
    int gi_456;
    datetime g_datetime_940;
    datetime g_datetime_944;
    double g_ihigh_884;
    double g_ilow_892;
    bool gi_512;
    bool gi_448;
    bool gi_724;
    MqlDateTime gi_268;
    int gi_252;
    int g_hour_272;
    double gi_908;
    bool gi_472;
    ulong g_ticket_948;
    datetime g_datetime_952;
    ulong g_ticket_956;
    datetime g_datetime_960;
    bool gi_468;
    double gi_916;
    int g_stoplevel_292;
    //int g_datetime_972 = 0;
    //int g_ticket_732 = -2;
    //int g_datetime_976 = 0;
    //int g_ticket_736 = -2;
    bool gi_876;
    bool gi_880;
    
    bool Stealth;
    bool NFA;
    
    // lib
    CMegaDroidLib1 lib;
};

void CMegaDroidSignal1::InitParameters()
{
    gi_256 = true;
	gd_224 = 1000.0;
	gi_444 = true;
    gi_460 = true;
    gi_464 = 20;
    gi_492 = true;
    gi_452 = true;
    gi_520 = true;
    gi_456 = 12;
    gi_448 = true;
    gi_252 = 3;
    gi_468 = true;
    gi_876 = true;
    gi_880 = true;
    
    Stealth = true;
    NFA = false;
    
	init();
}

void CMegaDroidSignal1::CMegaDroidSignal1()
{
}

void CMegaDroidSignal1::~CMegaDroidSignal1()
{
}
bool CMegaDroidSignal1::ValidationSettings()
{
	if(!CExpertSignal::ValidationSettings()) 
		return(false);

	if(false)
	{
		printf(__FUNCTION__+": Indicators should not be Null!");
		return(false);
	}
	return(true);
}

bool CMegaDroidSignal1::InitIndicators(CIndicators* indicators)
{
	if(indicators==NULL) 
		return(false);
	bool ret = true;

	ret &= m_iRSI_796.Create(m_symbol.Name(), (ENUM_TIMEFRAMES)lib.g_timeframe_368, lib.g_period_400, PRICE_CLOSE);
    ret &= m_iRSI_820.Create(m_symbol.Name(), PERIOD_M1, lib.g_period_404, PRICE_CLOSE);
    ret &= m_iCCI_828.Create(m_symbol.Name(), (ENUM_TIMEFRAMES)lib.g_timeframe_368, lib.g_period_408, PRICE_TYPICAL);
    ret &= m_iMA_868.Create(m_symbol.Name(), (ENUM_TIMEFRAMES)lib.g_timeframe_368, lib.g_period_408, 0, MODE_SMA, PRICE_MEDIAN);
    ret &= m_iHigh.Create(m_symbol.Name(), (ENUM_TIMEFRAMES)lib.g_timeframe_368);
    ret &= m_iLow.Create(m_symbol.Name(), (ENUM_TIMEFRAMES)lib.g_timeframe_368);
    ret *= m_iClose.Create(m_symbol.Name(), (ENUM_TIMEFRAMES)lib.g_timeframe_368);
    
    ret &= indicators.Add(GetPointer(m_iRSI_796));
    ret &= indicators.Add(GetPointer(m_iRSI_820));
    ret &= indicators.Add(GetPointer(m_iCCI_828));
    ret &= indicators.Add(GetPointer(m_iMA_868));
    ret &= indicators.Add(GetPointer(m_iHigh));
    ret &= indicators.Add(GetPointer(m_iLow));
    ret &= indicators.Add(GetPointer(m_iClose));
    
	return ret;
}

void CMegaDroidSignal1::Refresh(bool ai_0) {
   double lda_4[1];
   int lia_8[4];
   if (ai_0) 
    m_symbol.RefreshRates();
    
   g_datetime_264 = TimeCurrent();
   /*if (!IsTesting() && AutoServerGmtOffset || AutoLocalGmtOffset) {
      gi_332 = GetGmtOffset(gi_336, g_datetime_264, AutoServerGmtOffset, lda_4, lia_8);
      if (gi_332 == 4 && !AutoLocalGmtOffset) gi_332 = 0;
      else GmtOffset = lda_4[0];
      gi_528 = lia_8[0];
      gi_532 = lia_8[1];
      gi_652 = lia_8[2];
      gi_656 = lia_8[3];
   }*/
   TimeToStruct(g_datetime_264 - 3600 * GetGMTOffset(), gi_268);
   g_hour_272 = gi_268.hour;
   gi_280 = g_datetime_264 - 3600 * gi_268.hour - 60 * gi_268.min - gi_268.sec;
   g_spread_284 = m_symbol.Spread(); 
   g_stoplevel_292 = m_symbol.StopsLevel();
   gd_296 = 0.0001 / m_symbol.Point();
   if (m_symbol.Digits() < 4) gd_296 = 100.0 * gd_296;
}

bool CMegaDroidSignal1::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
{
	CExpertModel* em = (CExpertModel *)m_expert;
    if (em.GetOrderCount(ORDER_TYPE_BUY) > 0)
        return false;
    
    g_spread_288 = g_spread_284;    
    Refresh(0);
    gi_724 = lib.IsTradeTime(lib.gi_336, gi_268.year, gi_268.mon, gi_268.day, gi_252);
    //if (NFA) RefreshOrders();
    
    bool gi_716 = true;
    bool gi_524 = true;
    
	s1_setRules();
    if ((gi_920 < gi_924 && (g_hour_272 >= gi_920 && g_hour_272 <= gi_924 - 1)) 
        || (gi_920 >= gi_924 && (g_hour_272 >= gi_920 || g_hour_272 <= gi_924 - 1))) 
    {
        gi_716 = true;
    }
    else 
    {
        gi_716 = false;
    }

    if (gi_716 && gi_524) 
    {
        int l_day_of_week_24 = gi_268.day_of_week;
        if ((l_day_of_week_24 == 5 && g_hour_272 >= gi_920) || (l_day_of_week_24 == 1 && gi_920 >= gi_924 && g_hour_272 <= gi_924 - 1)) 
            gi_716 = false;
        else if (l_day_of_week_24 > 5 || l_day_of_week_24 < 1) 
            gi_716 = false;
   }
   
   //if (gi_968 != gi_716) 
   //{
   //   if (gi_716) gi_780++;
   //   gi_968 = gi_716;
   //}
   
   int li_16 = s1_openBuyRule();

   if (!gi_716 || !gi_724) 
    return false;  
   
   //if (NFA && !FIFOrule()) return false;
   if (/*g_datetime_972 != iTime(NULL, g_timeframe_368, gi_260) && */li_16) 
   {
      //g_ticket_732 = s1_openBuy();
        s1_openBuy(price,sl,tp);
        
      //g_datetime_972 = iTime(NULL, g_timeframe_368, gi_260);
      if (gi_460) {
         gi_876 = false;
         gi_880 = true;
      }
      return true;
   }
   
	return false;
}

bool CMegaDroidSignal1::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
{
	CExpertModel* em = (CExpertModel *)m_expert;

	if (em.GetOrderCount(ORDER_TYPE_SELL) > 0)
        return false;
        
    g_spread_288 = g_spread_284;
    Refresh(0);

    gi_724 = lib.IsTradeTime(lib.gi_336, gi_268.year, gi_268.mon, gi_268.day, gi_252);
    //if (NFA) RefreshOrders();
    
    bool gi_716 = true;
    bool gi_524 = true;
    
	s1_setRules();
    if ((gi_920 < gi_924 && (g_hour_272 >= gi_920 && g_hour_272 <= gi_924 - 1)) 
        || (gi_920 >= gi_924 && (g_hour_272 >= gi_920 || g_hour_272 <= gi_924 - 1))) 
    {
        gi_716 = true;
    }
    else 
    {
        gi_716 = false;
    }
    int l_day_of_week_24;

   if (gi_716 && gi_524) {
      l_day_of_week_24 = gi_268.day_of_week;
      if ((l_day_of_week_24 == 5 && g_hour_272 >= gi_920) || (l_day_of_week_24 == 1 && gi_920 >= gi_924 && g_hour_272 <= gi_924 - 1)) 
        gi_716 = false;
      else
         if (l_day_of_week_24 > 5 || l_day_of_week_24 < 1) 
            gi_716 = false;
   }
   
   //if (gi_968 != gi_716) 
   //{
   //   if (gi_716) gi_780++;
   //   gi_968 = gi_716;
   //}
   
   int li_20 = s1_openSellRule();
   
   if (!gi_716 || !gi_724) 
    return false;  
   
   //TimeLog("li_20 = " + IntegerToString(li_20));
   
   if (/*g_datetime_976 != iTime(NULL, g_timeframe_368, gi_260)  && g_ticket_736 < 0 && */li_20) {
        s1_openSell(price, sl, tp);
      //g_ticket_736 = s1_openSell();
      //if (g_ticket_736 >= 0) {
      //   g_datetime_976 = iTime(NULL, g_timeframe_368, gi_260);
         if (gi_460) {
            gi_876 = true;
            gi_880 = false;
         }
      //}
      return true;
   }
   
	return false;
}


bool CMegaDroidSignal1::CheckCloseLong(CTableOrder* t, double& price)
{
	CExpertModel* em = (CExpertModel *)m_expert;
    if (s1_closeBuyRule(t))
    {
        price = m_symbol.Bid();
        return true;
    }
	return false;
}

bool CMegaDroidSignal1::CheckCloseShort(CTableOrder* t, double& price)
{
	CExpertModel* em = (CExpertModel *)m_expert;
	if (s1_closeSellRule(t))
    {
        price = m_symbol.Bid();
        return true;
    }
	return false;
}

//////////////////////////////////////////////////////////////////////
int CMegaDroidSignal1::init() 
{
   if (gi_256) gi_260 = 0;
   else gi_260 = 1;
   //gi_336 = Increment(Symbol());
   
   //ProcessPatch("MegaDroid.dll", 0x326d0, 1);
   //ProcessPatch("MegaDroid.dll", 0x326d4, 0);
   //ProcessPatch("MegaDroid.dll", 0x326d5, 0x40);
   //ProcessPatch("MegaDroid.dll", 0x326d6, 0);
   //ProcessPatch("MegaDroid.dll", 0x326d7, 0);
   //ProcessPatch("MegaDroid.dll", 0x27460, 0xC2);
   //ProcessPatch("MegaDroid.dll", 0x27461, 0x14);
   //ProcessPatch("MegaDroid.dll", 0x27462, 0x00);

   bool li_20 = false;
   li_20 = lib.S1_CheckSymbol();
   //li_24 = S2_CheckSymbol();

   gd_312 = gd_224;
   gi_332 = 0;
   return (0);
}

int CMegaDroidSignal1::s1_direction() {
    //TimeLog(gi_260 + "," + g_icci_828 + "," + g_irsi_796 + ", " + g_datetime_944 + "," + g_datetime_264 + "," + g_datetime_940);
   if (g_icci_828 >= 0.0 || g_irsi_796 >= 50.0) g_datetime_944 = g_datetime_264;
   if (g_icci_828 <= 0.0 || g_irsi_796 <= 50.0) g_datetime_940 = g_datetime_264;
   if (g_datetime_944 > 0 && g_datetime_264 - g_datetime_944 > 3600.0 * lib.gd_496) return (2);
   if (g_datetime_940 > 0 && g_datetime_264 - g_datetime_940 > 3600.0 * lib.gd_496) return (3);
   if (g_datetime_944 == 0 || g_datetime_940 == 0) return (0);
   return (1);
}

void CMegaDroidSignal1::s1_dayRange() {
   int l_shift_0;
   if (g_datetime_264 - gi_280 < 3600.0 * gi_456) l_shift_0 = iBarShift(NULL, lib.g_timeframe_368, gi_280 - 86400);
   else l_shift_0 = iBarShift(NULL, lib.g_timeframe_368, gi_280);
 
   g_ihigh_884 = m_iHigh.GetData(iHighest(NULL, lib.g_timeframe_368, MODE_HIGH, l_shift_0 - gi_260, gi_260));
   g_ilow_892 = m_iLow.GetData(iLowest(NULL, lib.g_timeframe_368, MODE_LOW, l_shift_0 - gi_260, gi_260));
}

void CMegaDroidSignal1::s1_setRules() {
   int li_0;

   g_irsi_796 = m_iRSI_796.Main(gi_260); //iRSI(NULL, g_timeframe_368, g_period_400, PRICE_CLOSE, gi_260);
   g_irsi_804 = m_iRSI_796.Main(gi_260 + 1); //iRSI(NULL, g_timeframe_368, g_period_400, PRICE_CLOSE, gi_260 + 1);
   g_irsi_812 = m_iRSI_796.Main(gi_260 + 2); //iRSI(NULL, g_timeframe_368, g_period_400, PRICE_CLOSE, gi_260 + 2);
   if (gi_444) g_irsi_820 = m_iRSI_820.Main(gi_260); //iRSI(NULL, PERIOD_M1, g_period_404, PRICE_CLOSE, gi_260);
   g_icci_828 = m_iCCI_828.Main(gi_260); //iCCI(NULL, g_timeframe_368, g_period_408, PRICE_TYPICAL, gi_260);
   g_icci_836 = m_iCCI_828.Main(gi_260 + 1); //iCCI(NULL, g_timeframe_368, g_period_408, PRICE_TYPICAL, gi_260 + 1);
   g_icci_844 = m_iCCI_828.Main(gi_260 + 2); //iCCI(NULL, g_timeframe_368, g_period_408, PRICE_TYPICAL, gi_260 + 2);
   g_ima_868 = m_iMA_868.Main(gi_260); //iMA(NULL, g_timeframe_368, g_period_408, 0, MODE_SMA, PRICE_MEDIAN, gi_260);
   
   if (gi_460) {
      if (g_irsi_796 >= 50 - gi_464 / 2 && g_irsi_796 <= gi_464 / 2 + 50) {
         gi_876 = true;
         gi_880 = true;
      }
   }
   if (gi_452) s1_dayRange();
   if (gi_492) {
      li_0 = gi_928;
      gi_928 = s1_direction();
      //Print("h1:" + g_datetime_264 + ", " + gi_928 + ", " + li_0);
         
      if (li_0 != gi_928) {
         gi_932 = li_0;
         
         
         if (gi_928 == 1) 
         {
            gi_936 = (datetime)(g_datetime_264 + 3600.0 * lib.gd_504);
         }
      }
   }
   if (lib.gi_516 > 0) {
      if (g_spread_284 > lib.gi_516 * gd_296) {
         if (g_spread_288 < g_spread_284) {
            Print("Strategy1: Safe spread limit exceeded: spread = ", g_spread_284);
            if (gi_520) Print("Strategy1: Using DayDirection filter");
         }
         gi_900 = true;
      } else gi_900 = false;
   }

   if (gi_900) {
      gi_920 = lib.gi_536;
      gi_924 = lib.gi_540;
      return;
   }
   gi_920 = lib.gi_528;
   gi_924 = lib.gi_532;
}

//int CMegaDroidSignal1::ProcessPatch(string module, int address, int byte)
//{
//   int mem[1];
//   int out;
//   mem[0] = byte;
//   int hproc = GetCurrentProcess();
//   int hmod = GetModuleHandleA(module);
//   int addr = address + hmod;
//   int result = WriteProcessMemory(hproc, addr, mem, 1, out);
//   return (result);
//}

int CMegaDroidSignal1::s1_openBuyRule() {
   double l_iclose_0;
   double l_iclose_8;
   int l_shift_16;
   int l_shift_20;
   if (!gi_876) return (0);
   if (gi_900 && !gi_520) return (0);
   if (gi_492) {
      if (gi_928 == 2) return (0);
      if (g_datetime_264 <= gi_936)
         if (gi_932 == 2) return (0);
   }
   if (gi_512 || gi_900) {
      if (g_datetime_264 - gi_280 < 43200.0) {
         l_shift_16 = iBarShift(NULL, lib.g_timeframe_368, gi_280 - 86400);
         l_shift_20 = iBarShift(NULL, lib.g_timeframe_368, gi_280);
      } else {
         l_shift_16 = iBarShift(NULL, lib.g_timeframe_368, gi_280);
         l_shift_20 = gi_260;
      }
      l_iclose_8 = m_iClose.GetData(l_shift_16); //iClose(NULL, g_timeframe_368, l_shift_16);
      l_iclose_0 = m_iClose.GetData(l_shift_20); //iClose(NULL, g_timeframe_368, l_shift_20);
      if (l_iclose_0 < l_iclose_8) return (0);
   }
   bool ret = (lib.s1_Buy(m_symbol.Ask(), g_icci_828, g_irsi_796, g_irsi_820, g_ima_868, lib.gd_420, lib.gd_436, lib.gi_372 * gd_296 * m_symbol.Point(), gi_448, gi_444));

   //TimeLog(m_symbol.Ask() + ", " + g_icci_828 + ", " + g_irsi_796 + ", " + g_irsi_820 + ", " + g_ima_868 + ", " + gd_420 + ", " + gd_436 + ", " + gi_372 * gd_296 * m_symbol.Point() + ", " + gi_448 + ", " + gi_444);
   
   return ret;
}

int CMegaDroidSignal1::s1_openSellRule() 
{
    //TimeLog(gi_880 + "," + gi_900 + "," + gi_520 + "," + gi_492 + "," + gi_928 + ", " + g_datetime_264 + ", " + gi_936 + "," + gi_932);
    
   double l_iclose_0;
   double l_iclose_8;
   int l_shift_16;
   int l_shift_20;
   if (!gi_880) return (0);

   if (gi_900 && !gi_520) return (0);

   if (gi_492) {
      if (gi_928 == 3) return (0);

      if (g_datetime_264 <= gi_936)
         if (gi_932 == 3) return (0);
   }

   if (gi_512 || gi_900) {
      if (g_datetime_264 - gi_280 < 43200.0) {
         l_shift_16 = iBarShift(NULL, lib.g_timeframe_368, gi_280 - 86400);
         l_shift_20 = iBarShift(NULL, lib.g_timeframe_368, gi_280);
      } else {
         l_shift_16 = iBarShift(NULL, lib.g_timeframe_368, gi_280);
         l_shift_20 = gi_260;
      }
      l_iclose_8 = m_iClose.GetData(l_shift_16); //iClose(NULL, g_timeframe_368, l_shift_16);
      l_iclose_0 = m_iClose.GetData(l_shift_20); //iClose(NULL, g_timeframe_368, l_shift_20);
      if (l_iclose_0 > l_iclose_8) 
      {
        //TimeLog(l_iclose_0 + ", " + l_iclose_8);
        return (0);
      }
   }
   //TimeLog(g_timeframe_368 + ", " + g_period_400 + ", " + gi_260 + ", " + g_irsi_796);
   //TimeLog(m_symbol.Bid() + ", " + g_icci_828 + ", " + g_irsi_796 + ", " + g_irsi_820 + ", " + g_ima_868 + ", " + gd_412 + ", " + gd_428 + ", " + gi_372 * gd_296 * m_symbol.Point() + ", " + gi_448 + ", " + gi_444);
   
   return (lib.s1_Sell(m_symbol.Bid(), g_icci_828, g_irsi_796, g_irsi_820, g_ima_868, lib.gd_412, lib.gd_428, lib.gi_372 * gd_296 * m_symbol.Point(), gi_448, gi_444));
}

bool CMegaDroidSignal1::s1_closeBuyRule(CTableOrder* order) {
   if (Stealth || order.TakeProfit() == 0.0) {
      if (lib.gi_372 > 0)
         if (NormalizeDouble(m_symbol.Bid() - order.Price(), m_symbol.Digits()) >= NormalizeDouble(lib.gi_372 * m_symbol.Point() * gd_296, m_symbol.Digits())) return (true);
   }
   if (order.StopLoss() == 0.0) {
      if (gi_908 > 0)
         if (NormalizeDouble(order.Price() - m_symbol.Ask(), m_symbol.Digits()) >= NormalizeDouble(gi_908 * m_symbol.Point() * gd_296, m_symbol.Digits())) return (true);
   }
   
   double orderProfit = order.OrderType() == ORDER_TYPE_BUY ? m_symbol.Bid() - order.Price() : order.Price() - m_symbol.Ask();
   
   if (gi_472) {
      if (g_ticket_948 != order.Ticket()) {
         g_datetime_952 = order.TimeSetup();
         g_ticket_948 = order.Ticket();
      }
      if (g_icci_828 >= 0.0 || g_irsi_796 >= 50.0) g_datetime_952 = g_datetime_264;
      if (g_icci_844 < g_icci_836 && g_irsi_812 < g_irsi_804) g_datetime_952 = iTime(NULL, lib.g_timeframe_368, gi_260);
      if (g_datetime_264 - g_datetime_952 > 3600.0 * lib.gd_476 && orderProfit < 0.0) return (true);
   }
   if (gi_468) {
      if (g_datetime_264 - order.TimeSetup() > 3600.0 * lib.gd_476) {
         if (g_icci_828 > 0.0 && g_irsi_796 > 50.0 && orderProfit > 0.0) return (true);
         if (g_datetime_264 - order.TimeSetup() > 3600.0 * lib.gd_484) return (true);
      }
   }
   return (false);
}

bool CMegaDroidSignal1::s1_closeSellRule(CTableOrder* order) {
   if (Stealth || order.TakeProfit() == 0.0) {
      if (lib.gi_372 > 0)
         if (NormalizeDouble(order.Price() - m_symbol.Ask(), m_symbol.Digits()) >= NormalizeDouble(lib.gi_372 * m_symbol.Point() * gd_296, m_symbol.Digits())) return (true);
   }
   if (order.StopLoss() == 0.0) {
      if (gi_916 > 0)
         if (NormalizeDouble(m_symbol.Bid() - order.Price(), m_symbol.Digits()) >= NormalizeDouble(gi_916 * m_symbol.Point() * gd_296, m_symbol.Digits())) return (true);
   }
   
   double orderProfit = order.OrderType() == ORDER_TYPE_BUY ? m_symbol.Bid() - order.Price() : order.Price() - m_symbol.Ask();
   
   if (gi_472) {
      if (g_ticket_956 != order.Ticket()) {
         g_datetime_960 = order.TimeSetup();
         g_ticket_956 = order.Ticket();
      }
      if (g_icci_828 <= 0.0 || g_irsi_796 <= 50.0) g_datetime_960 = g_datetime_264;
      if (g_icci_844 > g_icci_836 && g_irsi_812 > g_irsi_804) g_datetime_960 = iTime(NULL, lib.g_timeframe_368, gi_260);
      if (g_datetime_264 - g_datetime_960 > 3600.0 * lib.gd_476 && orderProfit < 0.0) return (true);
   }
   if (gi_468) {
      if (g_datetime_264 - order.TimeSetup() > 3600.0 * lib.gd_476) {
         if (g_icci_828 < 0.0 && g_irsi_796 < 50.0 && orderProfit > 0.0) return (true);
         if (g_datetime_264 - order.TimeSetup() > 3600.0 * lib.gd_484) return (true);
      }
   }
   return (false);
}

int CMegaDroidSignal1::s1_openBuy(double& price,double& sl,double& tp) {
    double gi_904;
    
   double ld_0 = 0;
   double ld_8 = 0;
   if (g_ilow_892 > 0.0) {
      gi_908 = (m_symbol.Bid() - g_ilow_892 + m_symbol.Point() * gd_296) / m_symbol.Point();
      if (lib.gi_380 > 0 && gi_908 > lib.gi_380 * gd_296) gi_908 = lib.gi_380 * gd_296;
      if (gi_908 < lib.gi_384 * gd_296) gi_908 = lib.gi_384 * gd_296;
   } else gi_908 = lib.gi_384 * gd_296;
   if (gi_908 < g_stoplevel_292) gi_908 = g_stoplevel_292;
   if (Stealth) gi_904 = (lib.gi_376 * gd_296);
   else gi_904 = lib.gi_372 * gd_296;
   if (gi_904 < g_stoplevel_292) gi_904 = g_stoplevel_292;
   ld_8 = NormalizeDouble(m_symbol.Bid() - gi_908 * m_symbol.Point(), m_symbol.Digits());
   ld_0 = NormalizeDouble(m_symbol.Ask() + gi_904 * m_symbol.Point(), m_symbol.Digits());
   
   price = m_symbol.Ask();
   sl = ld_8;
   tp = ld_0;
   return true;// (openOrder(OP_BUY, gd_304, Ask, ld_0, ld_8, S1_Reference, gi_392, 0));
}

int CMegaDroidSignal1::s1_openSell(double& price,double& sl,double& tp) {
    double gi_912;
    
   double ld_0 = 0;
   double ld_8 = 0;
   if (g_ihigh_884 > 0.0) {
      gi_916 = (g_ihigh_884 - m_symbol.Ask() + m_symbol.Point() * gd_296) / m_symbol.Point();
      if (lib.gi_380 > 0 && gi_916 > lib.gi_380 * gd_296) gi_916 = lib.gi_380 * gd_296;
      if (gi_916 < lib.gi_384 * gd_296) gi_916 = lib.gi_384 * gd_296;
   } else gi_916 = lib.gi_384 * gd_296;
   if (gi_916 < g_stoplevel_292) gi_916 = g_stoplevel_292;
   if (Stealth) gi_912 = lib.gi_376 * gd_296;
   else gi_912 = lib.gi_372 * gd_296;
   if (gi_912 < g_stoplevel_292) gi_912 = g_stoplevel_292;
   ld_8 = NormalizeDouble(m_symbol.Ask() + gi_916 * m_symbol.Point(), m_symbol.Digits());
   ld_0 = NormalizeDouble(m_symbol.Bid() - gi_912 * m_symbol.Point(), m_symbol.Digits());
   
   price = m_symbol.Bid();
   sl = ld_8;
   tp = ld_0;
   return true; //(openOrder(OP_SELL, gd_304, Bid, ld_0, ld_8, S1_Reference, gi_396, 0));
}
