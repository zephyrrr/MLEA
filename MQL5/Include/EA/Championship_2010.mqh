//+------------------------------------------------------------------+
//|                                            Championship_2010.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#include <ExpertModel\ExpertModelSignal.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Files\FileTxt.mqh>

#include <Indicators\Trend.mqh>
#include <Indicators\Oscilators.mqh>
#include <Indicators\TimeSeries.mqh>

#include <ExpertModel\ExpertModel.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CChampionship_2010 : public CExpertModelSignal
  {
private:

public:
                     CChampionship_2010();
                    ~CChampionship_2010();
                    
public:
   virtual bool      ValidationSettings();
   virtual bool      InitIndicators(CIndicators* indicators);
   
   virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseLong(CTableOrder* t, double& price);
   virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckCloseShort(CTableOrder* t, double& price);
   virtual bool  CheckTrailingOrderLong(COrderInfo* order, double& price);
   virtual bool  CheckTrailingOrderShort(COrderInfo* order, double& price);
   bool InitParameters() { return true; };
   
private:
    bool buy_open, sell_open;

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CChampionship_2010::CChampionship_2010()
  {
    buy_open = false;
    sell_open = false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CChampionship_2010::~CChampionship_2010()
  {
  }
//+------------------------------------------------------------------+
bool CChampionship_2010::ValidationSettings()
{
    if(!CExpertSignal::ValidationSettings()) 
        return(false);
        
    if (false)
    {
      printf(__FUNCTION__+": Indicators should not be Null!");
      return(false);
    }
    return(true);
}

bool CChampionship_2010::InitIndicators(CIndicators* indicators)
{
    if(indicators==NULL) 
        return(false);
    bool ret = true;
    
    return ret;
}

bool CChampionship_2010::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
{
    ushort     PERIOD         =     250;
    ulong order_step = 100;
    ulong trailing_level = 200;
    ulong inside_level = 400;
    ulong stop_loss = 800;
    ulong take_profit = 1500;
    
    double High[], Low[];
    double CalcHigh  = 0;
    double CalcLow   = 0;
    
    ulong stop_level;
    double spread; 

    MqlTick tick;
    SymbolInfoTick(_Symbol, tick);
    
    if(Bars(_Symbol, PERIOD_M5) < PERIOD)
        {
         return false;
        }
        
    if((CopyHigh(_Symbol, PERIOD_M5, 0, PERIOD, High) == PERIOD)
        &&(CopyLow(_Symbol, PERIOD_M5, 0, PERIOD, Low) == PERIOD))
       {
         CalcHigh = High[0];
         CalcLow  = Low[0];

         for(int j=1; j < PERIOD; j++)
          {
            if(CalcHigh < High[j]) CalcHigh = High[j];
            if(CalcLow  >  Low[j]) CalcLow  = Low[j];
          }
       }

      if(CalcHigh < 0.01 || CalcLow < 0.01) 
        return false;
        
      stop_level = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
      spread = tick.ask - tick.bid;
      if(order_step < stop_level) order_step = stop_level;
      if(trailing_level < stop_level) trailing_level = stop_level;
      
      //if (sell_open)
      //      return false;
            
      if(tick.bid <= (CalcHigh - inside_level * _Point)) buy_open  = true;
      if(tick.bid >= (CalcLow  + inside_level * _Point)) sell_open = true;
      
      if (buy_open)
      {
        price = NormalizeDouble(CalcHigh - order_step * _Point + spread, _Digits);
        if(tick.ask + stop_level * _Point > price) 
            price = tick.ask + stop_level * _Point;
            
        if(stop_loss == 0) 
            sl = 0;
        else 
            sl = NormalizeDouble(price - MathMax(stop_loss, stop_level) * _Point - spread, _Digits);
            
        if(take_profit == 0) 
            tp = 0;
        else 
            tp = NormalizeDouble(price + MathMax(take_profit, stop_level) * _Point - spread, _Digits);
            
        Print(CalcHigh, ",", price, ",", sl, ",", tp);
        return true;
      }
      return false;
}

bool CChampionship_2010::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
{
    return false;
}

bool CChampionship_2010::CheckCloseLong(CTableOrder* t, double& price)
{
    return false;
}

bool CChampionship_2010::CheckCloseShort(CTableOrder* t, double& price)
{
    return false;
}

bool CChampionship_2010::CheckTrailingOrderLong(COrderInfo* order, double& price)
{
    return false;
    
    ushort     PERIOD         =     250;
    ulong order_step = 10;
    ulong trailing_level = 20;
    ulong inside_level = 40;
    ulong stop_loss = 80;
    ulong take_profit = 150;
    
    double High[], Low[];
    double CalcHigh  = 0;
    double CalcLow   = 0;
    
    ulong stop_level;
    double spread; 

    MqlTick tick;
    SymbolInfoTick(_Symbol, tick);
    
    if((CopyHigh(_Symbol, PERIOD_M5, 0, PERIOD, High) == PERIOD)
        &&(CopyLow(_Symbol, PERIOD_M5, 0, PERIOD, Low) == PERIOD))
       {
         CalcHigh = High[0];
         CalcLow  = Low[0];

         for(int j=1; j < PERIOD; j++)
          {
            if(CalcHigh < High[j]) CalcHigh = High[j];
            if(CalcLow  >  Low[j]) CalcLow  = Low[j];
          }
       }

      if(CalcHigh < 0.01 || CalcLow < 0.01) 
        return false;
        
      stop_level = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
      spread = tick.ask - tick.bid;
      if(order_step < stop_level) order_step = stop_level;
      if(trailing_level < stop_level) trailing_level = stop_level;
      
      
    buy_open = false;
           
           double tp, sl;
           double order_open_price = order.PriceOpen();
           
            if(( NormalizeDouble(CalcHigh - order_step * _Point + spread, _Digits) < NormalizeDouble(order_open_price - order_step * _Point + spread, _Digits)) && 
               ( NormalizeDouble(CalcHigh - order_step * _Point + spread, _Digits) > tick.ask + stop_level * _Point))
              {

               price = NormalizeDouble(CalcHigh - order_step * _Point + spread, _Digits);

               if(stop_loss == 0) sl = 0;
               else sl = NormalizeDouble(CalcHigh - order_step * _Point - MathMax(stop_loss, stop_level) * _Point, _Digits);

               if(take_profit == 0) tp = 0;
               else tp = NormalizeDouble(CalcHigh - order_step * _Point + MathMax(take_profit, stop_level) * _Point, _Digits);
               
               sell_open = true;
               return true;
               }
               
    return false;
}

bool CChampionship_2010::CheckTrailingOrderShort(COrderInfo* order, double& price)
{
    return false;
}
