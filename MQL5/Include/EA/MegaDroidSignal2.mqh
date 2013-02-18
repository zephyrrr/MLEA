//+------------------------------------------------------------------+
//|                                             MegaDroidSignal2.mqh |
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
#include "MegaDroidLib2.mqh"
#include <Utils\Utils.mqh>
#include <Utils\mt4timeseries.mqh>

class CMegaDroidSignal2 : public CExpertModelSignal
{
public:
	CMegaDroidSignal2();
	~CMegaDroidSignal2();
	virtual bool      ValidationSettings();
	virtual bool      InitIndicators(CIndicators* indicators);

	virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
	virtual bool      CheckCloseLong(CTableOrder* t, double& price);
	virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
	virtual bool      CheckCloseShort(CTableOrder* t, double& price);

	void InitParameters();
	
private:
    CiCCI m_iCCI_984, m_iCCI_992;
    CiHigh m_iHigh_1000;
    CiLow m_iLow_1008;
    CiClose m_iClose;
    
    int init();
    void s2_setRules();
    int s2_openBuyRule();
    int s2_openSellRule();
    bool s2_closeBuyRule(CTableOrder* order);
    bool s2_closeSellRule(CTableOrder* order);
    int s2_openBuy(double& price,double& sl,double& tp);
    int s2_openSell(double& price,double& sl,double& tp);
    void Refresh(bool ai_0);
    
    bool gi_256;
    int gi_260;
    double gd_312;
    double gd_224;
    int gi_332;
    double g_icci_984;
    double g_icci_992;
    double g_ihigh_1000;
    double g_ilow_1008;
    double g_ihigh_1016;
    double g_ilow_1024;

    int g_spread_284;
    double gd_296;
    int g_spread_288;
    int gi_1052;
    int gi_1056;
    datetime g_datetime_264;
    datetime gi_280;
    double gi_1040, gi_1048;
    datetime gi_1064, gi_1068, gi_1092, gi_1096;
    ulong g_ticket_1060, g_ticket_1088;
    datetime g_datetime_1076, g_datetime_1072, g_datetime_1104, g_datetime_1100;
    double g_ord_open_price_1080, g_ord_open_price_1108;
    int g_stoplevel_292;
    MqlDateTime gi_268;
    int g_hour_272;
    double gi_1044;
    double gi_1036;
    bool gi_596;
    bool gi_604;
    bool gi_600;
    bool gi_644;
    bool gi_1032;
    bool gi_636;
    bool gi_632;
    int gi_552;
    bool gi_724;
    int gi_252;
    
    bool Stealth;
    bool NFA;
    
    CMegaDroidLib2 lib;
};

void CMegaDroidSignal2::InitParameters()
{
	gi_256 = true;
	gd_224 = 1000.0;
	gi_596 = true;
    gi_604 = true;
    gi_600 = false;
    gi_644 = true;
    gi_1032 = false;
    gi_636 = false;
    gi_632 = false;
    gi_552 = 60;
    gi_252 = 3;
    
	Stealth = true;
    NFA = false;
    
    init();
}

void CMegaDroidSignal2::CMegaDroidSignal2()
{
}

void CMegaDroidSignal2::~CMegaDroidSignal2()
{
}
bool CMegaDroidSignal2::ValidationSettings()
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

bool CMegaDroidSignal2::InitIndicators(CIndicators* indicators)
{
	if(indicators==NULL) 
		return(false);
	bool ret = true;

	ret &= m_iCCI_984.Create(m_symbol.Name(), lib.g_timeframe_544, lib.g_period_588, PRICE_TYPICAL);
	ret &= m_iCCI_992.Create(m_symbol.Name(), lib.g_timeframe_544, lib.g_period_592, PRICE_TYPICAL);
    ret &= m_iHigh_1000.Create(m_symbol.Name(), lib.g_timeframe_544);
    ret &= m_iLow_1008.Create(m_symbol.Name(), lib.g_timeframe_544);
    ret &= m_iClose.Create(m_symbol.Name(), lib.g_timeframe_544);
    
    ret &= indicators.Add(GetPointer(m_iCCI_984));
    ret &= indicators.Add(GetPointer(m_iCCI_992));
    ret &= indicators.Add(GetPointer(m_iHigh_1000));
    ret &= indicators.Add(GetPointer(m_iLow_1008));
    ret &= indicators.Add(GetPointer(m_iClose));
    
	return ret;
}

void CMegaDroidSignal2::Refresh(bool ai_0) {
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

bool CMegaDroidSignal2::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
{
	CExpertModel* em = (CExpertModel *)m_expert;
    if (em.GetOrderCount(ORDER_TYPE_BUY) > 0)
        return false;
    
    g_spread_288 = g_spread_284;    
    Refresh(0);
	gi_724 = lib.IsTradeTime(lib.gi_336, gi_268.year, gi_268.mon, gi_268.day, gi_252);
	//if (NFA) RefreshOrders();
	
	s2_setRules();
	
	bool gi_720 = true;
    bool gi_648 = true;
    
    if ((gi_1052 < gi_1056 
        && (g_hour_272 >= gi_1052 && g_hour_272 <= gi_1056 - 1)) 
        || (gi_1052 >= gi_1056 && (g_hour_272 >= gi_1052 || g_hour_272 <= gi_1056 - 1))) 
        gi_720 = true;
    else 
        gi_720 = false;
    int l_day_of_week_24;
    if (gi_720 && gi_648) 
    {
        l_day_of_week_24 =  gi_268.day_of_week;
        if ((l_day_of_week_24 == 5 && g_hour_272 >= gi_1052) || (l_day_of_week_24 == 1 && gi_1052 >= gi_1056 && g_hour_272 <= gi_1056 - 1)) 
            gi_720 = false;
        else if (l_day_of_week_24 > 5 || l_day_of_week_24 < 1) 
                gi_720 = false;
    }
   
    //TimeLog(IntegerToString(gi_720) + ", " + StructToTime(gi_268) + ", " + l_day_of_week_24 + ", " + g_hour_272);
    
    int li_16 = s2_openBuyRule();
    if (!gi_720 || !gi_724) 
        return false;
        
    if (/*g_datetime_1124 != iTime(NULL, g_timeframe_544, gi_260) && g_ticket_756 < 0 && */li_16/* && g_ord_profit_764 >= 0.0*/) 
    {
      //g_ticket_756 = s2_openBuy();
        s2_openBuy(price,sl,tp);
        
      //g_datetime_1124 = iTime(NULL, g_timeframe_544, gi_260);
        g_ihigh_1016 = g_ihigh_1000;
        g_ilow_1024 = g_ilow_1008;
        //g_ord_profit_772 = 0;
        return true;
    }
   
	return false;
}

bool CMegaDroidSignal2::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
{
	CExpertModel* em = (CExpertModel *)m_expert;

	if (em.GetOrderCount(ORDER_TYPE_SELL) > 0)
        return false;
	
	g_spread_288 = g_spread_284;    
    Refresh(0);
	gi_724 = lib.IsTradeTime(lib.gi_336, gi_268.year, gi_268.mon, gi_268.day, gi_252);
	//if (NFA) RefreshOrders();
	
	s2_setRules();
	
	bool gi_720 = true;
    bool gi_648 = true;
    
    if ((gi_1052 < gi_1056 
        && (g_hour_272 >= gi_1052 && g_hour_272 <= gi_1056 - 1)) 
        || (gi_1052 >= gi_1056 && (g_hour_272 >= gi_1052 || g_hour_272 <= gi_1056 - 1))) 
        gi_720 = true;
    else 
        gi_720 = false;
    if (gi_720 && gi_648) 
    {
        int l_day_of_week_24 =  gi_268.day_of_week;
        if ((l_day_of_week_24 == 5 && g_hour_272 >= gi_1052) || (l_day_of_week_24 == 1 && gi_1052 >= gi_1056 && g_hour_272 <= gi_1056 - 1)) 
            gi_720 = false;
        else if (l_day_of_week_24 > 5 || l_day_of_week_24 < 1) 
                gi_720 = false;
    }
   
    int li_16 = s2_openSellRule();
    if (!gi_720 || !gi_724) 
        return false;
        
    if (/*g_datetime_1124 != iTime(NULL, g_timeframe_544, gi_260) && g_ticket_756 < 0 && */li_16/* && g_ord_profit_764 >= 0.0*/) 
    {
      //g_ticket_756 = s2_openBuy();
        s2_openSell(price,sl,tp);
        
      //g_datetime_1124 = iTime(NULL, g_timeframe_544, gi_260);
        g_ihigh_1016 = g_ihigh_1000;
        g_ilow_1024 = g_ilow_1008;
        //g_ord_profit_772 = 0;
        return true;
    }
   
	return false;
}

bool CMegaDroidSignal2::CheckCloseLong(CTableOrder* t, double& price)
{
	CExpertModel* em = (CExpertModel *)m_expert;
    if (s2_closeBuyRule(t))
    {
        price = m_symbol.Bid();
        return true;
    }
	return false;
}

bool CMegaDroidSignal2::CheckCloseShort(CTableOrder* t, double& price)
{
	CExpertModel* em = (CExpertModel *)m_expert;
	if (s2_closeSellRule(t))
    {
        price = m_symbol.Bid();
        return true;
    }
	return false;
}



//////////////////////////////////////////////////////////////////////
int CMegaDroidSignal2::init() 
{
   if (gi_256) gi_260 = 0;
   else gi_260 = 1;
   //gi_336 = Increment(Symbol());

   bool li_24 = false;
   li_24 = lib.S2_CheckSymbol();

   gd_312 = gd_224;
   gi_332 = 0;
   return (0);
}

void CMegaDroidSignal2::s2_setRules() {
   if (gi_596 || gi_604) 
    g_icci_984 = m_iCCI_984.Main(gi_260); //iCCI(NULL, g_timeframe_544, g_period_588, PRICE_TYPICAL, gi_260);
   if (gi_600) 
    g_icci_992 = m_iCCI_992.Main(gi_260); //iCCI(NULL, g_timeframe_544, g_period_592, PRICE_TYPICAL, gi_260);
   g_ihigh_1000 = m_iHigh_1000.GetData(iHighest(NULL, lib.g_timeframe_544, MODE_HIGH, lib.gi_584, 1)); //iHigh(NULL, g_timeframe_544, iHighest(NULL, g_timeframe_544, MODE_HIGH, gi_584, 1));
   g_ilow_1008 = m_iLow_1008.GetData(iLowest(NULL, lib.g_timeframe_544, MODE_LOW, lib.gi_584, 1)); //iLow(NULL, g_timeframe_544, iLowest(NULL, g_timeframe_544, MODE_LOW, gi_584, 1));
   if (lib.gi_640 > 0) {
      if (g_spread_284 > lib.gi_640 * gd_296) {
         if (g_spread_288 < g_spread_284) {
            Print("Strategy2: Safe spread limit exceeded: spread = ", g_spread_284);
            if (gi_644) Print("Strategy2: Using DayDirection filter");
         }
         gi_1032 = true;
      } else gi_1032 = false;
   }
   if (gi_1032) {
      gi_1052 = lib.gi_660;
      gi_1056 = lib.gi_664;
      return;
   }
   gi_1052 = lib.gi_652;
   gi_1056 = lib.gi_656;
}


int CMegaDroidSignal2::s2_openBuyRule() {
  double l_iclose_0;
   double l_iclose_8;
   int l_shift_16;
   int l_shift_20;
   if (gi_1032 && !gi_644) return (0);
   if (gi_636 || gi_1032) {
      if (g_datetime_264 - gi_280 < 43200.0) {
         l_shift_16 = iBarShift(NULL, lib.g_timeframe_544, gi_280 - 86400);
         l_shift_20 = iBarShift(NULL, lib.g_timeframe_544, gi_280);
      } else {
         l_shift_16 = iBarShift(NULL, lib.g_timeframe_544, gi_280);
         l_shift_20 = gi_260;
      }
      l_iclose_8 = m_iClose.GetData(l_shift_16); //iClose(NULL, g_timeframe_544, l_shift_16);
      l_iclose_0 = m_iClose.GetData(l_shift_20); //iClose(NULL, g_timeframe_544, l_shift_20);
      if (l_iclose_0 < l_iclose_8) return (0);
   }
   
   //TimeLog(m_symbol.Ask() + ", " + m_symbol.Bid() + ", " + g_icci_984 + ", " + g_icci_992 + ", " + g_ilow_1008
   //  + ", " + g_ihigh_1000 + ", " + gi_596 + ", " + gi_600);
     
   return (lib.s2_Buy(m_symbol.Ask(), m_symbol.Bid(), g_icci_984, g_icci_992, g_ilow_1008, g_ihigh_1000, gi_596, gi_600));
}

int CMegaDroidSignal2::s2_openSellRule() 
{
    double l_iclose_0;
   double l_iclose_8;
   int l_shift_16;
   int l_shift_20;
   if (gi_1032 && !gi_644) return (0);
   if (gi_636 || gi_1032) {
      if (g_datetime_264 - gi_280 < 43200.0) {
         l_shift_16 = iBarShift(NULL, lib.g_timeframe_544, gi_280 - 86400);
         l_shift_20 = iBarShift(NULL, lib.g_timeframe_544, gi_280);
      } else {
         l_shift_16 = iBarShift(NULL, lib.g_timeframe_544, gi_280);
         l_shift_20 = gi_260;
      }
      l_iclose_8 = m_iClose.GetData(l_shift_16); //iClose(NULL, g_timeframe_544, l_shift_16);
      l_iclose_0 = m_iClose.GetData(l_shift_16); //iClose(NULL, g_timeframe_544, l_shift_20);
      if (l_iclose_0 > l_iclose_8) return (0);
   }
   return (lib.s2_Sell(m_symbol.Ask(), m_symbol.Bid(), g_icci_984, g_icci_992, g_ilow_1008, g_ihigh_1000, gi_596, gi_600));
}

bool CMegaDroidSignal2::s2_closeBuyRule(CTableOrder* order) {
   double l_ord_profit_0;
   if (Stealth || order.TakeProfit() == 0.0) {
      if (lib.gi_548 > 0)
         if (NormalizeDouble(m_symbol.Bid() - order.Price(), m_symbol.Digits()) >= NormalizeDouble(lib.gi_548 * m_symbol.Point() * gd_296, m_symbol.Digits())) return (true);
   }
   if (order.StopLoss() == 0.0) {
      if (gi_1040 > 0)
         if (NormalizeDouble(order.Price() - m_symbol.Ask(), m_symbol.Digits()) >= NormalizeDouble(gi_1040 * m_symbol.Point() * gd_296, m_symbol.Digits())) return (true);
   }
   if (gi_604) {
      if (g_ticket_1060 != order.Ticket()) {
         gi_1064 = 0;
         gi_1068 = 0;
         g_datetime_1076 = order.TimeSetup();
         g_datetime_1072 = g_datetime_1076;
         g_ticket_1060 = order.Ticket();
         g_ord_open_price_1080 = order.Price();
      }
      l_ord_profit_0 = order.Profit(m_symbol);
      if (m_symbol.Ask() > g_ord_open_price_1080) {
         gi_1064 += g_datetime_264 - g_datetime_1072;
         g_datetime_1072 = g_datetime_264;
      } else {
         gi_1068 += g_datetime_264 - g_datetime_1072;
         g_datetime_1072 = g_datetime_264;
      }
      if (g_datetime_264 - g_datetime_1076 > 3600.0 * lib.gd_608) {
         if (g_icci_984 > 0.0 && l_ord_profit_0 > 0.0 && gi_1064 < gi_1068) 
         {
            return (true);
         }
         if (g_icci_984 > 100.0 && l_ord_profit_0 > 0.0) return (true);
         if (g_datetime_264 - g_datetime_1076 > 3600.0 * lib.gd_616 && l_ord_profit_0 > 0.0) return (true);
         if (g_datetime_264 - g_datetime_1076 > 3600.0 * lib.gd_624) return (true);
      }
   }
   if (gi_632) return (m_symbol.Bid() >= g_ihigh_1000);
   return (m_symbol.Bid() >= g_ihigh_1016);
}

bool CMegaDroidSignal2::s2_closeSellRule(CTableOrder* order) {
   double l_ord_profit_0;
   if (Stealth || order.TakeProfit() == 0.0) 
   {
      if (lib.gi_548 > 0)
         if (NormalizeDouble(order.Price() - m_symbol.Ask(), m_symbol.Digits()) >= NormalizeDouble(lib.gi_548 * m_symbol.Point() * gd_296, m_symbol.Digits())) 
         {
            //TimeLog("01, " + gi_548 + ", " + gd_296 + ", " + order.Price() + ", " +  m_symbol.Ask());
            return (true);
         }
   }
   if (order.StopLoss() == 0.0) 
   {
      if (gi_1048 > 0)
         if (NormalizeDouble(m_symbol.Bid() - order.Price(), m_symbol.Digits()) >= NormalizeDouble(gi_1048 * m_symbol.Point() * gd_296, m_symbol.Digits())) 
         {
            //TimeLog("02");
            return (true);
         }
   }
   if (gi_604) {
      if (g_ticket_1088 != order.Ticket()) {
         gi_1092 = 0;
         gi_1096 = 0;
         g_datetime_1104 = order.TimeSetup();
         g_datetime_1100 = g_datetime_1104;
         g_ticket_1088 = order.Ticket();
         g_ord_open_price_1108 = order.Price();
      }
      l_ord_profit_0 = order.Profit(m_symbol);
      if (m_symbol.Bid() < g_ord_open_price_1108) {
         gi_1092 += g_datetime_264 - g_datetime_1100;
         g_datetime_1100 = g_datetime_264;
      } else {
         gi_1096 += g_datetime_264 - g_datetime_1100;
         g_datetime_1100 = g_datetime_264;
      }
      if (g_datetime_264 - g_datetime_1104 > 3600.0 * lib.gd_608) {
         if (g_icci_984 < 0.0 && l_ord_profit_0 > 0.0 && gi_1092 < gi_1096) 
         {
            //TimeLog("1");
            return (true);
         }
         if (g_icci_984 < -100.0 && l_ord_profit_0 > 0.0) 
         {
            //TimeLog("2");
            return (true);
         }
         if (g_datetime_264 - g_datetime_1104 > 3600.0 * lib.gd_616 && l_ord_profit_0 > 0.0) 
         {
            //TimeLog("3");
            return (true);
         }
         if (g_datetime_264 - g_datetime_1104 > 3600.0 * lib.gd_624) 
         {
            //TimeLog("4");
            return (true);
         }
      }
   }
    //TimeLog(gi_632 + ", " + m_symbol.Ask() + ", " + g_ilow_1008 + ", " + g_ilow_1024);
    if (gi_632) 
    {
        return (m_symbol.Ask() <= g_ilow_1008);
    }
    else
    {
        return (m_symbol.Ask() <= g_ilow_1024);
    }
}

int CMegaDroidSignal2::s2_openBuy(double& price, double& sl, double& tp) {
   double ld_0 = 0;
   double ld_8 = 0;
   if (lib.gd_564 > 0.0) {
      gi_1040 = lib.gd_564 * (g_ihigh_1000 - g_ilow_1008) / m_symbol.Point();
      if (lib.gi_556 > 0 && gi_1040 > lib.gi_556 * gd_296) gi_1040 = lib.gi_556 * gd_296;
      if (gi_1040 < lib.gi_560 * gd_296) gi_1040 = lib.gi_560 * gd_296;
   } else gi_1040 = lib.gi_560 * gd_296;
   if (gi_1040 < g_stoplevel_292) gi_1040 = g_stoplevel_292;
   if (Stealth) gi_1036 = gi_552 * gd_296;
   else gi_1036 = lib.gi_548 * gd_296;
   if (gi_1036 < g_stoplevel_292) gi_1036 = g_stoplevel_292;
   ld_8 = NormalizeDouble(m_symbol.Bid() - gi_1040 * m_symbol.Point(), m_symbol.Digits());
   ld_0 = NormalizeDouble(m_symbol.Ask() + gi_1036 * m_symbol.Point(), m_symbol.Digits());
   
   price = m_symbol.Ask();
   sl = ld_8;
   tp = ld_0;
   return true;
   
   //return (openOrder(OP_BUY, gd_304, Ask, ld_0, ld_8, S2_Reference, gi_576, 0));
}

int CMegaDroidSignal2::s2_openSell(double& price, double& sl, double& tp) {
   double ld_0 = 0;
   double ld_8 = 0;
   if (lib.gd_564 > 0.0) {
      gi_1048 = lib.gd_564 * (g_ihigh_1000 - g_ilow_1008) / m_symbol.Point();
      if (lib.gi_556 > 0 && gi_1048 > lib.gi_556 * gd_296) gi_1048 = lib.gi_556 * gd_296;
      if (gi_1048 < lib.gi_560 * gd_296) gi_1048 = lib.gi_560 * gd_296;
   } else gi_1048 = lib.gi_560 * gd_296;
   if (gi_1048 < g_stoplevel_292) gi_1048 = g_stoplevel_292;
   if (Stealth) gi_1044 = gi_552 * gd_296;
   else gi_1044 = lib.gi_548 * gd_296;
   if (gi_1044 < g_stoplevel_292) gi_1044 = g_stoplevel_292;
   ld_8 = NormalizeDouble(m_symbol.Ask() + gi_1048 * m_symbol.Point(), m_symbol.Digits());
   ld_0 = NormalizeDouble(m_symbol.Bid() - gi_1044 * m_symbol.Point(), m_symbol.Digits());
   
   price = m_symbol.Bid();
   sl = ld_8;
   tp = ld_0;
   return true;
   
   //return (openOrder(OP_SELL, gd_304, Bid, ld_0, ld_8, S2_Reference, gi_580, 0));
}
