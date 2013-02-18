//+------------------------------------------------------------------+
//|                                                    DealsInfo.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "DealInfo.mqh"
#include <Arrays\List.mqh>
#include <Utils\Utils.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDealList : public CList
  {
private:

public:
                     CDealList() {};
                    ~CDealList() {};
   virtual CObject *CreateElement() { return new DealInfo(); }
   virtual int Type() { return 0x11127779; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class DealsInfo : public CObject
  {
private:
   int               m_lastSeconds;
   CDealList         m_deals;
   datetime          m_nowTime;
   MqlRates          m_nowPrice;
   
   bool              m_isLastForPeriod;
   datetime          m_firstDate;

   int               m_nowTp,m_nowFp;
   float             m_nowCost,m_nowProfit;
   float             m_totalVolume;
   int               m_totalDeal;
   float             m_symbolPoint;
   bool              m_isCloseTimeNotSet;
public:
                     DealsInfo(int lastMinutes);
                    ~DealsInfo();

   void              AddDeal(datetime openTime,datetime closeTime,int hp,double openPrice,char dealType,double closePriceTp,double closePriceSl,double volume);

   void              Now(datetime nowTime,MqlRates &nowPrice);

   int               NowTp() { return m_nowTp; }
   int               NowFp() { return m_nowFp; }
   int               NowDeal() { return m_nowTp+m_nowFp; }
   float             NowCost() { return m_nowCost; }
   float             NowProfit() { return m_nowProfit; }
   float             NowScore() { return m_nowCost; }
   float             NowPrecision();

   float TotalVolume() { return m_totalVolume; }
   int TotalDeal() { return m_totalDeal; }

   virtual bool      Save(int file_handle);
   virtual bool      Load(int file_handle);

   void              PrintAll(bool printDeal);
   void              Clear();
   bool              IsCloseTimeNotSet() { return m_isCloseTimeNotSet; }
private:
   void              RemoveOldDeals();
   int               GetDigit(float price);
   void              CalculateNow();
   void              CalculateTotal();
   void              CalculateNow(DealInfo *i);
   void              CalculateTotal(DealInfo *i);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
DealsInfo::DealsInfo(int lastMinutes)
  {
   m_deals.FreeMode(true);
   m_lastSeconds=lastMinutes*60;
   m_isLastForPeriod=false;
   m_firstDate=0;

   m_nowTp=0;
   m_nowFp=0;
   m_nowCost=0;
   m_nowProfit=0;

   m_totalVolume=0;
   m_totalDeal=0;
   m_symbolPoint=(float)SymbolInfoDouble(Symbol(),SYMBOL_POINT);
   m_isCloseTimeNotSet=false;
   m_isCloseTimeNotSet = false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
DealsInfo::~DealsInfo()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
DealsInfo::Clear()
  {
   m_deals.Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
DealsInfo::PrintAll(bool printDeal=false)
  {
   Info("Deals Debug: m_lastSeconds = "+IntegerToString(m_lastSeconds)+
        ", m_nowTime = "+TimeToString(m_nowTime)+
        //", m_lastTime = "+TimeToString(m_nowTime-m_lastSeconds)+
        ", m_nowPrice = "+DoubleToString(m_nowPrice.close,4)+
        //", m_isLastForPeriod = "+IntegerToString(m_isLastForPeriod)+
        //", m_firstDate = "+TimeToString(m_firstDate)+
        ", m_nowTp = "+IntegerToString(m_nowTp)+
        ", m_nowFp = "+IntegerToString(m_nowFp)+
        ", m_nowCost = "+DoubleToString(m_nowCost,4)+
        ", m_nowProfit = "+DoubleToString(m_nowProfit,4)+
        ", m_totalVolume = "+DoubleToString(m_totalVolume,2)+
        ", m_totalDeal = "+IntegerToString(m_totalDeal));
   Info("DealCount = ",IntegerToString(m_deals.Total()));

   if(printDeal)
     {
      DealInfo *p=m_deals.GetFirstNode();
      while(p!=NULL)
        {
         p.PrintAll();
         p=m_deals.GetNextNode();
        }
     }
  }
//+------------------------------------------------------------------+
void DealsInfo::AddDeal(datetime openTime,datetime closeTime,int hp,double openPrice,char dealType,double closePriceTp,double closePriceSl,double volume)
  {
   DealInfo *deal=new DealInfo(openTime,(float)openPrice,dealType,(float)closePriceTp,(float)closePriceSl,(float)volume);

   if(closeTime==0 || hp==1)
     {
      m_isCloseTimeNotSet=true;
      if (IN_TEST_MODE)
      {
        //Warn("hp = 1 when openTime = ",TimeToString(openTime));
      }
     }
   else
     {
      Debug("Add deal with closeTime",TimeToString(closeTime)," and hp = ",IntegerToString(hp));
      deal.CloseTime(closeTime);
      if(hp==2)
        {
         deal.Cost(-(float)MathAbs(deal.ClosePriceTp()-deal.OpenPrice()));
        }
      else
        {
         deal.Cost((float)MathAbs(deal.ClosePriceSl()-deal.OpenPrice()));
        }
     }
   m_deals.Add(deal);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DealsInfo::RemoveOldDeals()
  {
   datetime lastTime=m_nowTime-m_lastSeconds;
   Debug("Now = "+TimeToString(m_nowTime)+", lastSeconds = "+IntegerToString(m_lastSeconds)+", lastTime = "+TimeToString(lastTime));
   DealInfo *p=m_deals.GetFirstNode();
   while(p!=NULL)
     {
      if(p.OpenTime()<lastTime)
        {
         Debug("Delete Deal of "+TimeToString(p.OpenTime())+" while lastTime = "+TimeToString(lastTime));
         m_deals.DeleteCurrent();
         p=m_deals.GetCurrentNode();
        }
      else
        {
         p=m_deals.GetNextNode();
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DealsInfo::Now(datetime nowTime,MqlRates &nowPrice)
  {
   if(nowTime==0 || nowPrice.close==0)
     {
      Error("nowTime or nowPrice should not be 0");
      return;
     }

    //Debug("DealsInfo set now = ", TimeToString(nowTime));

   m_nowTime=nowTime;
   m_nowPrice=nowPrice;

/*
    if(m_firstDate==0)
     {
      m_firstDate=nowTime;
     }
   if(!m_isLastForPeriod)
     {
      datetime lastTime=m_nowTime - m_lastSeconds;
      if(m_firstDate<=lastTime)
        {
         m_isLastForPeriod=true;
         //Debug("FirstDate > LastTime");
        }
     }
if(m_isLastForPeriod)
     {
      RemoveOldDeals();
     }
   CalculateTotal();
   CalculateNow();*/

   m_totalVolume=0;
   m_totalDeal=0;
   m_nowCost=0;
   m_nowProfit=0;
   m_nowTp = 0;
   m_nowFp = 0;

   m_isCloseTimeNotSet=false;
   datetime lastTime=m_nowTime-m_lastSeconds;

   DealInfo *i=m_deals.GetFirstNode();
   while(i!=NULL)
     {
      if(i.OpenTime()<lastTime)
        {
         m_deals.DeleteCurrent();
         i=m_deals.GetCurrentNode();
        }
      else
        {
         CalculateTotal(i);
         CalculateNow(i);
         if(i.CloseTime()==0)
           {
            m_isCloseTimeNotSet=true;
           }
         i=m_deals.GetNextNode();
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
float DealsInfo::NowPrecision()
  {
   if(m_nowTp+m_nowFp==0)
      return 0;

   return(float)m_nowTp/(m_nowTp+m_nowFp);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DealsInfo::CalculateTotal(DealInfo *i)
  {
   m_totalVolume+=i.Volume();
   m_totalDeal++;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DealsInfo::CalculateNow(DealInfo *i)
  {
   if(i.CloseTime()>0)
     {
      if(i.CloseTime()<=m_nowTime)
        {
         if(i.Cost()<0)
            m_nowTp++;
         else
            m_nowFp++;

         float costV= i.Cost() * i.Volume();
         m_nowCost+=costV;
        }
      else
        {
         if(i.DealType()=='B')
           {
            float cost=(float)(m_nowPrice.close-i.OpenPrice());
            m_nowProfit-=cost*i.Volume();
           }
         else if(i.DealType()=='S')
           {
            float cost=(float)(i.OpenPrice()-m_nowPrice.close);
            m_nowProfit-=cost*i.Volume();
           }

         //Error("CloseTime is set after now. openTime = ",TimeToString(i.OpenTime()));

        }
     }
   else
     {
      const float spread=m_nowPrice.spread * m_symbolPoint;
      if(i.DealType()=='B')
        {
         if(m_nowPrice.low<i.ClosePriceSl()+spread)
           {
            m_nowFp++;
            float cost=(i.ClosePriceSl()-i.OpenPrice());
            float costV=cost*i.Volume();
            m_nowCost-=costV;
            m_nowProfit-=costV;
            i.CloseTime(m_nowTime);
            i.Cost(-cost);
           }
         else if(m_nowPrice.high>i.ClosePriceTp()+spread)
           {
            m_nowTp++;
            float cost=(i.ClosePriceTp()-i.OpenPrice());
            float costV=cost*i.Volume();
            m_nowCost-=costV;
            m_nowProfit-=costV;
            i.CloseTime(m_nowTime);
            i.Cost(-cost);
           }
         else
           {
            float cost=(float)(m_nowPrice.close-i.OpenPrice());
            m_nowProfit-=cost*i.Volume();
           }
        }
      else if(i.DealType()=='S')
        {
         if(m_nowPrice.high+spread>i.ClosePriceSl())
           {
            m_nowFp++;
            float cost=(i.OpenPrice()-i.ClosePriceSl());
            float costV=cost*i.Volume();
            m_nowCost-=costV;
            m_nowProfit-=costV;
            i.CloseTime(m_nowTime);
            i.Cost(-cost);
           }
         else if(m_nowPrice.low+spread<i.ClosePriceTp())
           {
            m_nowTp++;
            float cost=(i.OpenPrice()-i.ClosePriceTp());
            float costV=cost*i.Volume();
            m_nowCost-=costV;
            m_nowProfit-=costV;
            i.CloseTime(m_nowTime);
            i.Cost(-cost);
           }
         else
           {
            float cost=(float)(i.OpenPrice()-m_nowPrice.close);
            m_nowProfit-=cost*i.Volume();
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DealsInfo::CalculateTotal(void)
  {
   m_totalVolume=0;
   m_totalDeal= 0;
   DealInfo *i=(DealInfo *)m_deals.GetFirstNode();
   while(i!=NULL)
     {
      CalculateTotal(i);

      i=(DealInfo *)m_deals.GetNextNode();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DealsInfo::CalculateNow()
  {
   Debug("CalculateNow DealInfo stats");

   m_nowCost=0;
   m_nowProfit=0;
   m_nowTp = 0;
   m_nowFp = 0;

   DealInfo *i=(DealInfo *)m_deals.GetFirstNode();
   while(i!=NULL)
     {
      CalculateNow(i);
      i=(DealInfo *)m_deals.GetNextNode();
     }
//Info(DoubleToString(m_nowCost, 1), ", ", DoubleToString(m_nowProfit, 1));
  }
//+------------------------------------------------------------------+

bool DealsInfo::Save(int file_handle)
  {
   if(file_handle<0) return(false);

//--- writing start marker - 0xFFFFFFFFFFFFFFFF
   if(FileWriteLong(file_handle,-1)!=sizeof(long)) return(false);

   if(FileWriteInteger(file_handle,m_lastSeconds)!=sizeof(int)) return(false);
   if(FileWriteLong(file_handle,m_nowTime)!=sizeof(long)) return(false);
   if(FileWriteStruct(file_handle,m_nowPrice)!=sizeof(MqlRates)) return(false);
   if(FileWriteInteger(file_handle,m_isLastForPeriod)!=sizeof(int)) return(false);
   if(FileWriteLong(file_handle,m_firstDate)!=sizeof(long)) return(false);
   if(FileWriteInteger(file_handle,m_nowTp)!=sizeof(int)) return(false);
   if(FileWriteInteger(file_handle,m_nowFp)!=sizeof(int)) return(false);
   if(FileWriteFloat(file_handle,m_nowCost)!=sizeof(float)) return(false);
   if(FileWriteFloat(file_handle,m_nowProfit)!=sizeof(float)) return(false);
   if(FileWriteFloat(file_handle,m_totalVolume)!=sizeof(float)) return(false);
   if(FileWriteInteger(file_handle,m_totalDeal)!=sizeof(int)) return(false);
   if(FileWriteInteger(file_handle,m_isCloseTimeNotSet)!=sizeof(int)) return(false);

   if(m_deals.Save(file_handle)!=true) return(false);

   Debug("Save DealsInfo with nowTime = "+TimeToString(m_nowTime));
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DealsInfo::Load(int file_handle)
  {
   if(file_handle<0) return(false);

//--- reading and checking begin marker - 0xFFFFFFFFFFFFFFFF
   if(FileReadLong(file_handle)!=-1) return(false);

   m_lastSeconds=FileReadInteger(file_handle);
   m_nowTime=(datetime)FileReadLong(file_handle);
   FileReadStruct(file_handle,m_nowPrice);
   m_isLastForPeriod=(bool)FileReadInteger(file_handle);
   m_firstDate=(datetime)FileReadLong(file_handle);
   m_nowTp = FileReadInteger(file_handle);
   m_nowFp = FileReadInteger(file_handle);
   m_nowCost=FileReadFloat(file_handle);
   m_nowProfit=FileReadFloat(file_handle);
   m_totalVolume=FileReadFloat(file_handle);
   m_totalDeal=FileReadInteger(file_handle);
   m_isCloseTimeNotSet=(bool)FileReadInteger(file_handle);
   
   m_deals.Load(file_handle);

   Debug("Load DealsInfo with nowTime = "+TimeToString(m_nowTime));
   return(true);
  }
//+------------------------------------------------------------------+
