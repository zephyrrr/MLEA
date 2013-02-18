//+------------------------------------------------------------------+
//|                                                     DealInfo.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <Object.mqh>
#include <Utils\Utils.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class DealInfo : public CObject
  {
private:
   datetime          m_openTime;
   float             m_openPrice;
   char              m_dealType;

   float             m_closePriceTp,m_closePriceSl;
   datetime          m_closeTime;
   float             m_cost;
   float             m_volume;
public:
                     DealInfo();
                     DealInfo(datetime openTime,float openPrice,char dealType,float closePriceTp,float closePriceSl,float volume);
                    ~DealInfo();
   datetime          OpenTime() { return m_openTime; }
   float             OpenPrice() { return m_openPrice; }
   float             ClosePriceTp() { return m_closePriceTp; }
   float             ClosePriceSl() { return m_closePriceSl; }
   char              DealType() { return m_dealType; }

   datetime          CloseTime() { return m_closeTime; }
   void              CloseTime(datetime closeTime) { m_closeTime=closeTime; }
   float             Cost() { return m_cost; }
   void              Cost(float cost) { m_cost=cost; }
   float             Volume() { return m_volume; }
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   void              PrintAll();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
DealInfo::DealInfo()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
DealInfo::DealInfo(datetime openTime,float openPrice,char dealType,float closePriceTp,float closePriceSl,float volume)
  {
   m_openTime=openTime;
   m_openPrice= openPrice;
   m_dealType = dealType;
   m_closePriceTp = closePriceTp;
   m_closePriceSl = closePriceSl;
   m_closeTime=0;
   m_cost=0;
   m_volume=volume;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
DealInfo::~DealInfo()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DealInfo::Save(const int file_handle)
  {
   if(file_handle<0) return(false);

//--- writing start marker - 0xFFFFFFFFFFFFFFFF
   if(FileWriteLong(file_handle,-1)!=sizeof(long)) return(false);

   if(FileWriteLong(file_handle,m_openTime)!=sizeof(long)) return(false);
   if(FileWriteFloat(file_handle,m_openPrice)!=sizeof(float)) return(false);
   if(FileWriteInteger(file_handle,m_dealType) !=sizeof(int)) return(false);
   if(FileWriteFloat(file_handle, m_closePriceTp) != sizeof(float)) return(false);
   if(FileWriteFloat(file_handle, m_closePriceSl) != sizeof(float)) return(false);
   if(FileWriteLong(file_handle,m_closeTime)!=sizeof(long)) return(false);
   if(FileWriteFloat(file_handle,m_cost)!=sizeof(float)) return(false);
   if(FileWriteFloat(file_handle,m_volume)!=sizeof(float)) return(false);
   Debug("Save DealInfo with openTime = "+TimeToString(m_openTime));
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DealInfo::Load(const int file_handle)
  {
   if(file_handle<0) return(false);

//--- reading and checking begin marker - 0xFFFFFFFFFFFFFFFF
   if(FileReadLong(file_handle)!=-1) return(false);

   m_openTime = (datetime)FileReadLong(file_handle);
   m_openPrice= FileReadFloat(file_handle);
   m_dealType = (char)FileReadInteger(file_handle);
   m_closePriceTp= FileReadFloat(file_handle);
   m_closePriceSl= FileReadFloat(file_handle);
   m_closeTime=(datetime)FileReadLong(file_handle);
   m_cost=FileReadFloat(file_handle);
   m_volume=FileReadFloat(file_handle);
   Debug("Load DealInfo with openTime = "+TimeToString(m_openTime));
   return(true);
  }
//+------------------------------------------------------------------+
void DealInfo::PrintAll(void)
  {
   Info("DealInfo: m_openTime = "+TimeToString(m_openTime)+
        ", m_openPrice = "+DoubleToString(m_openPrice,4)+
        ", m_dealType = "+CharToString(m_dealType)+
        ", m_closeTime = "+TimeToString(m_closeTime)+
        ", m_closePriceTp = "+DoubleToString(m_closePriceTp,4)+
        ", m_closePriceSl = "+DoubleToString(m_closePriceSl,4)+
        ", m_cost = "+DoubleToString(m_cost,4)+
        ", m_volume ="+DoubleToString(m_volume,2));
  }
//+------------------------------------------------------------------+
