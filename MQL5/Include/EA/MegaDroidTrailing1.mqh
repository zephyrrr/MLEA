//+------------------------------------------------------------------+
//|                                           MegaDroidTrailing1.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

#include <ExpertModel\ExpertModel.mqh>
#include <ExpertModel\ExpertModelTrailing.mqh>

#include <Trade\Trade.mqh>
#include "MegaDroidLib1.mqh"
#include <Utils\Utils.mqh>
#include <Utils\mt4timeseries.mqh>

class CMegaDroidTrailing1 : public CExpertModelTrailing
{
private:
public:
                      CMegaDroidTrailing1();
    virtual bool      ValidationSettings();
    virtual bool      InitIndicators(CIndicators* indicators);
    
    virtual bool      CheckTrailingStopLong(CTableOrder* order,double& sl,double& tp);
    virtual bool      CheckTrailingStopShort(CTableOrder* order,double& sl,double& tp);
    
    void InitParameters();
    
private:
    CiHigh m_iHigh;
    CMegaDroidLib1 lib;
};

void CMegaDroidTrailing1::CMegaDroidTrailing1()
{
}

bool CMegaDroidTrailing1::ValidationSettings()
{
    if (!CExpertModelTrailing::ValidationSettings())
        return false;
        
   return true;
}

void CMegaDroidTrailing1::InitParameters()
{
    lib.S1_CheckSymbol();
}

bool CMegaDroidTrailing1::InitIndicators(CIndicators* indicators)
{
    if(indicators==NULL) 
		return(false);
	bool ret = true;
	
	ret &= m_iHigh.Create(m_symbol.Name(), (ENUM_TIMEFRAMES)lib.g_timeframe_368);
    
    ret &= indicators.Add(GetPointer(m_iHigh));
    
    return ret;
}

bool CMegaDroidTrailing1::CheckTrailingStopLong(CTableOrder* order,double& sl,double& tp)
{
    int g_stoplevel_292 = m_symbol.StopsLevel();
    bool Stealth = true;
    double gd_296 = 0.0001 / m_symbol.Point();
    
    double gi_904 = 0, gi_908 = 0;
    
    
    if (gi_908 < g_stoplevel_292) gi_908 = g_stoplevel_292;
    if (Stealth) gi_904 = lib.gi_376 * gd_296;
    else gi_904 = lib.gi_372 * gd_296;
   
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
            if (gi_904 < g_stoplevel_292) 
                gi_904 = g_stoplevel_292;
            l_ord_takeprofit_0 = NormalizeDouble(m_symbol.Ask() + gi_904 * m_symbol.Point(), m_symbol.Digits());
        }
        if (l_ord_stoploss_8 == 0.0) 
        {
            if (gi_908 < g_stoplevel_292) 
                gi_908 = g_stoplevel_292;
            l_ord_stoploss_8 = NormalizeDouble(m_symbol.Bid() - gi_908 * m_symbol.Point(), m_symbol.Digits());
        }
        
        sl = l_ord_stoploss_8;
        tp = l_ord_takeprofit_0;
        return true;
    }

    if (lib.gi_388 > 0) 
    {
        if (m_symbol.Bid() - order.Price() > m_symbol.Point() * gd_296 * lib.gi_388) 
        {
            if (order.StopLoss() < m_symbol.Bid() - m_symbol.Point() * gd_296 * lib.gi_388 
                || order.StopLoss() == 0.0) 
            {
                sl = NormalizeDouble(m_symbol.Bid() - m_symbol.Point() * gd_296 * lib.gi_388, m_symbol.Digits());
                tp = order.TakeProfit();
            }
        }
    }
   
    return false;
}

bool CMegaDroidTrailing1::CheckTrailingStopShort(CTableOrder* order,double& sl,double& tp)
{
    int g_stoplevel_292 = m_symbol.StopsLevel();
    bool Stealth = true;
    double gd_296 = 0.0001 / m_symbol.Point();
    
    double gi_912 = 0, gi_916 = 0;
    
    /*int l_shift_0;
   if (g_datetime_264 - gi_280 < 3600.0 * gi_456) l_shift_0 = iBarShift(NULL, g_timeframe_368, gi_280 - 86400);
   else l_shift_0 = iBarShift(NULL, g_timeframe_368, gi_280);
   
    double g_ihigh_884 = m_iHigh.GetData(iHighest(NULL, g_timeframe_368, MODE_HIGH, l_shift_0 - gi_260, gi_260));
    
     if (g_ihigh_884 > 0.0) {
      gi_916 = (g_ihigh_884 - m_symbol.Ask() + m_symbol.Point() * gd_296) / m_symbol.Point();
      if (gi_380 > 0 && gi_916 > gi_380 * gd_296) gi_916 = gi_380 * gd_296;
      if (gi_916 < gi_384 * gd_296) gi_916 = gi_384 * gd_296;
   } else gi_916 = gi_384 * gd_296;*/
   if (gi_916 < g_stoplevel_292) gi_916 = g_stoplevel_292;
   if (Stealth) gi_912 = lib.gi_376 * gd_296;
   else gi_912 = lib.gi_372 * gd_296;
   if (gi_912 < g_stoplevel_292) gi_912 = g_stoplevel_292;

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
            if (gi_912 < g_stoplevel_292) 
                gi_912 = g_stoplevel_292;
            l_ord_takeprofit_0 = NormalizeDouble(m_symbol.Bid() - gi_912 * m_symbol.Point(), m_symbol.Digits());
        }
        if (l_ord_stoploss_8 == 0.0) 
        {
            if (gi_916 < g_stoplevel_292) 
                gi_916 = g_stoplevel_292;
            l_ord_stoploss_8 = NormalizeDouble(m_symbol.Ask() + gi_916 * m_symbol.Point(), m_symbol.Digits());
        }
        
        sl = l_ord_stoploss_8;
        tp = l_ord_takeprofit_0;
        return true;
    }

    if (lib.gi_388 > 0) 
    {
        if (order.Price() - m_symbol.Ask() > m_symbol.Point() * gd_296 * lib.gi_388) 
        {
            if (order.StopLoss() > m_symbol.Ask() + m_symbol.Point() * gd_296 * lib.gi_388 
                || order.StopLoss() == 0.0) 
            {
                sl = NormalizeDouble(m_symbol.Ask() + m_symbol.Point() * gd_296 * lib.gi_388, m_symbol.Digits());
                tp = order.TakeProfit();
            }
        }
    }
   
    return false;
}

