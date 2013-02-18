//+------------------------------------------------------------------+
//|                                           MegaDroidTrailing2.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

#include <ExpertModel\ExpertModel.mqh>
#include <ExpertModel\ExpertModelTrailing.mqh>

#include <Trade\Trade.mqh>
#include "MegaDroidLib2.mqh"
#include <Utils\Utils.mqh>
#include <Utils\mt4timeseries.mqh>

class CMegaDroidTrailing2 : public CExpertModelTrailing
{
private:
public:
                      CMegaDroidTrailing2();
    virtual bool      ValidationSettings();
    virtual bool      InitIndicators(CIndicators* indicators);
    
    virtual bool      CheckTrailingStopLong(CTableOrder* order,double& sl,double& tp);
    virtual bool      CheckTrailingStopShort(CTableOrder* order,double& sl,double& tp);
    
    void InitParameters();
    
private:
    CiHigh m_iHigh_1000;
    CiLow m_iLow_1008;
    
    CMegaDroidLib2 lib;
};

void CMegaDroidTrailing2::CMegaDroidTrailing2()
{
}

bool CMegaDroidTrailing2::ValidationSettings()
{
    if (!CExpertModelTrailing::ValidationSettings())
        return false;
        
   return true;
}

void CMegaDroidTrailing2::InitParameters()
{
    lib.S2_CheckSymbol();
}

bool CMegaDroidTrailing2::InitIndicators(CIndicators* indicators)
{
    if(indicators==NULL) 
		return(false);
	bool ret = true;

    ret &= m_iHigh_1000.Create(m_symbol.Name(), lib.g_timeframe_544);
    ret &= m_iLow_1008.Create(m_symbol.Name(), lib.g_timeframe_544);
    
    ret &= indicators.Add(GetPointer(m_iHigh_1000));
    ret &= indicators.Add(GetPointer(m_iLow_1008));
    
	return ret;
}

bool CMegaDroidTrailing2::CheckTrailingStopLong(CTableOrder* order,double& sl,double& tp)
{
    int gi_552 = 60;
    
    int g_stoplevel_292 = m_symbol.StopsLevel();
    bool Stealth = true;
    double gd_296 = 0.0001 / m_symbol.Point();
    
    double gi_1040 = 0, gi_1036 = 0;
    
    double g_ihigh_1000 = m_iHigh_1000.GetData(iHighest(NULL, lib.g_timeframe_544, MODE_HIGH, lib.gi_584, 1)); //iHigh(NULL, g_timeframe_544, iHighest(NULL, g_timeframe_544, MODE_HIGH, gi_584, 1));
    double g_ilow_1008 = m_iLow_1008.GetData(iLowest(NULL, lib.g_timeframe_544, MODE_LOW, lib.gi_584, 1)); //iLow(NULL, g_timeframe_544, iLowest(NULL, g_timeframe_544, MODE_LOW, gi_584, 1));
   
   
    if (lib.gd_564 > 0.0) {
      gi_1040 = lib.gd_564 * (g_ihigh_1000 - g_ilow_1008) / m_symbol.Point();
      if (lib.gi_556 > 0 && gi_1040 > lib.gi_556 * gd_296) gi_1040 = lib.gi_556 * gd_296;
      if (gi_1040 < lib.gi_560 * gd_296) gi_1040 = lib.gi_560 * gd_296;
   } else gi_1040 = lib.gi_560 * gd_296;
   if (gi_1040 < g_stoplevel_292) gi_1040 = g_stoplevel_292;
   if (Stealth) gi_1036 = gi_552 * gd_296;
   else gi_1036 = lib.gi_548 * gd_296;
   if (gi_1036 < g_stoplevel_292) gi_1036 = g_stoplevel_292;
   
    sl = EMPTY_VALUE;
    tp = EMPTY_VALUE;
    
    if(order==NULL)  
        return(false);
    
    double l_ord_takeprofit_0 = order.TakeProfit();
    double l_ord_stoploss_8 = order.StopLoss();
    if (l_ord_takeprofit_0 == 0.0 || l_ord_stoploss_8 == 0.0) 
    {
        if (l_ord_takeprofit_0 == 0.0) 
        {
            if (gi_1036 < g_stoplevel_292) 
                gi_1036 = g_stoplevel_292;
            l_ord_takeprofit_0 = NormalizeDouble(m_symbol.Ask() + gi_1036 * m_symbol.Point(), m_symbol.Digits());
        }
        if (l_ord_stoploss_8 == 0.0) 
        {
            if (gi_1040 < g_stoplevel_292) 
                gi_1040 = g_stoplevel_292;
            l_ord_stoploss_8 = NormalizeDouble(m_symbol.Bid() - gi_1040 * m_symbol.Point(), m_symbol.Digits());
        }
        
        sl = l_ord_stoploss_8;
        tp = l_ord_takeprofit_0;
        return true;
    }

    if (lib.gi_572 > 0) 
    {
        if (m_symbol.Bid() - order.Price() > m_symbol.Point() * gd_296 * lib.gi_572) 
        {
            if (order.StopLoss() < m_symbol.Bid() - m_symbol.Point() * gd_296 * lib.gi_572 
                || order.StopLoss() == 0.0) 
            {
                sl = NormalizeDouble(m_symbol.Bid() - m_symbol.Point() * gd_296 * lib.gi_572, m_symbol.Digits());
                tp = order.TakeProfit();
            }
        }
    }
   
    return false;
}

bool CMegaDroidTrailing2::CheckTrailingStopShort(CTableOrder* order,double& sl,double& tp)
{
    int gi_552 = 60;
    
    int g_stoplevel_292 = m_symbol.StopsLevel();
    bool Stealth = true;
    double gd_296 = 0.0001 / m_symbol.Point();
    
    double gi_1044 = 0, gi_1048 = 0;
    
    double g_ihigh_1000 = m_iHigh_1000.GetData(iHighest(NULL, lib.g_timeframe_544, MODE_HIGH, lib.gi_584, 1)); //iHigh(NULL, g_timeframe_544, iHighest(NULL, g_timeframe_544, MODE_HIGH, gi_584, 1));
    double g_ilow_1008 = m_iLow_1008.GetData(iLowest(NULL, lib.g_timeframe_544, MODE_LOW, lib.gi_584, 1)); //iLow(NULL, g_timeframe_544, iLowest(NULL, g_timeframe_544, MODE_LOW, gi_584, 1));
   
    if (lib.gd_564 > 0.0) {
      gi_1048 = lib.gd_564 * (g_ihigh_1000 - g_ilow_1008) / m_symbol.Point();
      if (lib.gi_556 > 0 && gi_1048 > lib.gi_556 * gd_296) gi_1048 = lib.gi_556 * gd_296;
      if (gi_1048 < lib.gi_560 * gd_296) gi_1048 = lib.gi_560 * gd_296;
   } else gi_1048 = lib.gi_560 * gd_296;
   if (gi_1048 < g_stoplevel_292) gi_1048 = g_stoplevel_292;
   if (Stealth) gi_1044 = gi_552 * gd_296;
   else gi_1044 = lib.gi_548 * gd_296;
   if (gi_1044 < g_stoplevel_292) gi_1044 = g_stoplevel_292;
   
    sl = EMPTY_VALUE;
    tp = EMPTY_VALUE;
    
    if(order==NULL)  
        return(false);
    
    double l_ord_takeprofit_0 = order.TakeProfit();
    double l_ord_stoploss_8 = order.StopLoss();
    if (l_ord_takeprofit_0 == 0.0 || l_ord_stoploss_8 == 0.0) 
    {
        if (l_ord_takeprofit_0 == 0.0) 
        {
            if (gi_1044 < g_stoplevel_292) 
                gi_1044 = g_stoplevel_292;
            l_ord_takeprofit_0 = NormalizeDouble(m_symbol.Bid() - gi_1044 * m_symbol.Point(), m_symbol.Digits());
        }
        if (l_ord_stoploss_8 == 0.0) 
        {
            if (gi_1048 < g_stoplevel_292) 
                gi_1048 = g_stoplevel_292;
            l_ord_stoploss_8 = NormalizeDouble(m_symbol.Ask() + gi_1048 * m_symbol.Point(), m_symbol.Digits());
        }
        
        sl = l_ord_stoploss_8;
        tp = l_ord_takeprofit_0;
        return true;
    }

    if (lib.gi_572 > 0) 
    {
        if (order.Price() - m_symbol.Ask() > m_symbol.Point() * gd_296 * lib.gi_572) 
        {
            if (order.StopLoss() > m_symbol.Ask() + m_symbol.Point() * gd_296 * lib.gi_572 
                || order.StopLoss() == 0.0) 
            {
                sl = NormalizeDouble(m_symbol.Ask() + m_symbol.Point() * gd_296 * lib.gi_572, m_symbol.Digits());
                tp = order.TakeProfit();
            }
        }
    }
   
    return false;
}

