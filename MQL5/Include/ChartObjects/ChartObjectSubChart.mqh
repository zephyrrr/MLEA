//+------------------------------------------------------------------+
//|                                          ChartObjectSubChart.mqh |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "ChartObject.mqh"
//+------------------------------------------------------------------+
//| Class CChartObjectSubChart.                                      |
//| Purpose: Class of the "SubChart" object of chart.                |
//|          Derives from class CChartObject.                        |
//+------------------------------------------------------------------+
class CChartObjectSubChart : public CChartObject
  {
public:
                     CChartObjectSubChart(void);
                    ~CChartObjectSubChart(void);
   //--- methods of access to properties of the object
   int               X_Distance(void)                      const;
   bool              X_Distance(const int X)               const;
   int               Y_Distance(void)                      const;
   bool              Y_Distance(const int Y)               const;
   ENUM_BASE_CORNER  Corner(void)                          const;
   bool              Corner(const ENUM_BASE_CORNER corner) const;
   int               X_Size(void)                          const;
   bool              X_Size(const int size)                const;
   int               Y_Size(void)                          const;
   bool              Y_Size(const int size)                const;
   string            Symbol(void)                          const;
   bool              Symbol(const string symbol)           const;
   int               Period(void)                          const;
   bool              Period(const int period)              const;
   int               Scale(void)                           const;
   bool              Scale(const int scale)                const;
   bool              DateScale(void)                       const;
   bool              DateScale(const bool scale)           const;
   bool              PriceScale(void)                      const;
   bool              PriceScale(const bool scale)          const;
   //--- change of time/price coordinates is blocked
   bool              Time(const datetime time)             const { return(false);     }
   bool              Price(const double price)             const { return(false);     }
   //--- method of creating object
   bool              Create(long chart_id,const string name,const int window,
                            const int X,const int Y,const int sizeX,const int sizeY);
   //--- method of identifying the object
   virtual int       Type(void)                            const { return(OBJ_CHART); }
   //--- methods for working with files
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CChartObjectSubChart::CChartObjectSubChart(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CChartObjectSubChart::~CChartObjectSubChart(void)
  {
  }
//+------------------------------------------------------------------+
//| Create object "SubChart".                                        |
//+------------------------------------------------------------------+
bool CChartObjectSubChart::Create(long chart_id,const string name,const int window,
                                  const int X,const int Y,const int sizeX,const int sizeY)
  {
   if(!ObjectCreate(chart_id,name,(ENUM_OBJECT)Type(),window,0,0,0)) return(false);
   if(!Attach(chart_id,name,window,1))                               return(false);
   if(!X_Distance(X))                                                return(false);
   if(!Y_Distance(Y))                                                return(false);
   if(!X_Size(sizeX))                                                return(false);
   if(!Y_Size(sizeY))                                                return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Get the X-distance.                                              |
//+------------------------------------------------------------------+
int CChartObjectSubChart::X_Distance(void) const
  {
//--- checking
   if(m_chart_id==-1) return(0);
//--- result
   return((int)ObjectGetInteger(m_chart_id,m_name,OBJPROP_XDISTANCE));
  }
//+------------------------------------------------------------------+
//| Set the X-distance.                                              |
//+------------------------------------------------------------------+
bool CChartObjectSubChart::X_Distance(const int X) const
  {
//--- checking
   if(m_chart_id==-1) return(false);
//--- result
   return(ObjectSetInteger(m_chart_id,m_name,OBJPROP_XDISTANCE,X));
  }
//+------------------------------------------------------------------+
//| Get the Y-distance.                                              |
//+------------------------------------------------------------------+
int CChartObjectSubChart::Y_Distance(void) const
  {
//--- checking
   if(m_chart_id==-1) return(0);
//--- result
   return((int)ObjectGetInteger(m_chart_id,m_name,OBJPROP_YDISTANCE));
  }
//+------------------------------------------------------------------+
//| Set the Y-distance.                                              |
//+------------------------------------------------------------------+
bool CChartObjectSubChart::Y_Distance(const int Y) const
  {
//--- checking
   if(m_chart_id==-1) return(false);
//--- result
   return(ObjectSetInteger(m_chart_id,m_name,OBJPROP_YDISTANCE,Y));
  }
//+------------------------------------------------------------------+
//| Get base corner.                                                 |
//+------------------------------------------------------------------+
ENUM_BASE_CORNER CChartObjectSubChart::Corner(void) const
  {
//--- checking
   if(m_chart_id==-1) return(WRONG_VALUE);
//--- result
   return((ENUM_BASE_CORNER)ObjectGetInteger(m_chart_id,m_name,OBJPROP_CORNER));
  }
//+------------------------------------------------------------------+
//| Set base corner.                                                 |
//+------------------------------------------------------------------+
bool CChartObjectSubChart::Corner(const ENUM_BASE_CORNER corner) const
  {
//--- checking
   if(m_chart_id==-1) return(false);
//--- result
   return(ObjectSetInteger(m_chart_id,m_name,OBJPROP_CORNER,corner));
  }
//+------------------------------------------------------------------+
//| Get the X-size.                                                  |
//+------------------------------------------------------------------+
int CChartObjectSubChart::X_Size(void) const
  {
//--- checking
   if(m_chart_id==-1) return(0);
//--- result
   return((int)ObjectGetInteger(m_chart_id,m_name,OBJPROP_XSIZE));
  }
//+------------------------------------------------------------------+
//| Set X-size.                                                      |
//+------------------------------------------------------------------+
bool CChartObjectSubChart::X_Size(const int size) const
  {
//--- checking
   if(m_chart_id==-1) return(false);
//--- result
   return(ObjectSetInteger(m_chart_id,m_name,OBJPROP_XSIZE,size));
  }
//+------------------------------------------------------------------+
//| Get the Y-size.                                                  |
//+------------------------------------------------------------------+
int CChartObjectSubChart::Y_Size(void) const
  {
//--- checking
   if(m_chart_id==-1) return(0);
//--- result
   return((int)ObjectGetInteger(m_chart_id,m_name,OBJPROP_YSIZE));
  }
//+------------------------------------------------------------------+
//| Set the Y-size.                                                  |
//+------------------------------------------------------------------+
bool CChartObjectSubChart::Y_Size(const int size) const
  {
//--- checking
   if(m_chart_id==-1) return(false);
//--- result
   return(ObjectSetInteger(m_chart_id,m_name,OBJPROP_YSIZE,size));
  }
//+------------------------------------------------------------------+
//| Get chart symbol.                                                |
//+------------------------------------------------------------------+
string CChartObjectSubChart::Symbol(void) const
  {
//--- checking
   if(m_chart_id==-1) return("");
//--- result
   return(ObjectGetString(m_chart_id,m_name,OBJPROP_SYMBOL));
  }
//+------------------------------------------------------------------+
//| Set chart symbol.                                                |
//+------------------------------------------------------------------+
bool CChartObjectSubChart::Symbol(const string symbol) const
  {
//--- checking
   if(m_chart_id==-1) return(false);
//--- result
   return(ObjectSetString(m_chart_id,m_name,OBJPROP_SYMBOL,symbol));
  }
//+------------------------------------------------------------------+
//| Get chart period.                                                |
//+------------------------------------------------------------------+
int CChartObjectSubChart::Period(void) const
  {
//--- checking
   if(m_chart_id==-1) return(0);
//--- result
   return((int)ObjectGetInteger(m_chart_id,m_name,OBJPROP_PERIOD));
  }
//+------------------------------------------------------------------+
//| Set chart period.                                                |
//+------------------------------------------------------------------+
bool CChartObjectSubChart::Period(const int period) const
  {
//--- checking
   if(m_chart_id==-1) return(false);
//--- result
   return(ObjectSetInteger(m_chart_id,m_name,OBJPROP_PERIOD,period));
  }
//+------------------------------------------------------------------+
//| Get chart scale.                                                 |
//+------------------------------------------------------------------+
int CChartObjectSubChart::Scale(void) const
  {
//--- checking
   if(m_chart_id==-1) return(-1);
//--- result
   return((int)ObjectGetInteger(m_chart_id,m_name,OBJPROP_CHART_SCALE));
  }
//+------------------------------------------------------------------+
//| Set chart scale.                                                 |
//+------------------------------------------------------------------+
bool CChartObjectSubChart::Scale(const int scale) const
  {
//--- checking
   if(m_chart_id==-1) return(false);
//--- result
   return(ObjectSetInteger(m_chart_id,m_name,OBJPROP_CHART_SCALE,scale));
  }
//+------------------------------------------------------------------+
//| Get the "time scale" flag.                                       |
//+------------------------------------------------------------------+
bool CChartObjectSubChart::DateScale(void) const
  {
//--- checking
   if(m_chart_id==-1) return(false);
//--- result
   return(ObjectGetInteger(m_chart_id,m_name,OBJPROP_DATE_SCALE));
  }
//+------------------------------------------------------------------+
//| Set the "time scale" flag.                                       |
//+------------------------------------------------------------------+
bool CChartObjectSubChart::DateScale(const bool scale) const
  {
//--- checking
   if(m_chart_id==-1) return(false);
//--- result
   return(ObjectSetInteger(m_chart_id,m_name,OBJPROP_DATE_SCALE,scale));
  }
//+------------------------------------------------------------------+
//| Get the "price scale" flag.                                      |
//+------------------------------------------------------------------+
bool CChartObjectSubChart::PriceScale(void) const
  {
//--- checking
   if(m_chart_id==-1) return(false);
//--- result
   return(ObjectGetInteger(m_chart_id,m_name,OBJPROP_PRICE_SCALE));
  }
//+------------------------------------------------------------------+
//| Set the "price scale" flag.                                      |
//+------------------------------------------------------------------+
bool CChartObjectSubChart::PriceScale(const bool scale) const
  {
//--- checking
   if(m_chart_id==-1) return(false);
//--- result
   return(ObjectSetInteger(m_chart_id,m_name,OBJPROP_PRICE_SCALE,scale));
  }
//+------------------------------------------------------------------+
//| Writing parameters of object to file.                            |
//+------------------------------------------------------------------+
bool CChartObjectSubChart::Save(const int file_handle)
  {
   int    len;
   string str;
//--- checking
   if(file_handle<=0)                   return(false);
   if(m_chart_id==-1)                   return(false);
//--- writing
   if(!CChartObject::Save(file_handle)) return(false);
//--- writing value of the "X-distance" property
   if(FileWriteInteger(file_handle,(int)ObjectGetInteger(m_chart_id,m_name,OBJPROP_XDISTANCE),INT_VALUE)!=sizeof(int))     return(false);
//--- writing value of the "Y-distance" property
   if(FileWriteInteger(file_handle,(int)ObjectGetInteger(m_chart_id,m_name,OBJPROP_YDISTANCE),INT_VALUE)!=sizeof(int))     return(false);
//--- writing value of the "corner" property
   if(FileWriteInteger(file_handle,(int)ObjectGetInteger(m_chart_id,m_name,OBJPROP_CORNER),INT_VALUE)!=sizeof(int))        return(false);
//--- writing value of the "X-size" property
   if(FileWriteInteger(file_handle,(int)ObjectGetInteger(m_chart_id,m_name,OBJPROP_XSIZE),INT_VALUE)!=sizeof(int))         return(false);
//--- writing value of the "Y-size" property
   if(FileWriteInteger(file_handle,(int)ObjectGetInteger(m_chart_id,m_name,OBJPROP_YSIZE),INT_VALUE)!=sizeof(int))         return(false);
//--- writing value of the "symbol" property
   str=ObjectGetString(m_chart_id,m_name,OBJPROP_SYMBOL);
   len=StringLen(str);
   if(FileWriteInteger(file_handle,len,INT_VALUE)!=INT_VALUE)                                                              return(false);
   if(len!=0) if(FileWriteString(file_handle,str,len)!=len)                                                                return(false);
//--- writing value of the "period" property
   if(FileWriteInteger(file_handle,(int)ObjectGetInteger(m_chart_id,m_name,OBJPROP_PERIOD),INT_VALUE)!=sizeof(int))        return(false);
//--- writing value of the "scale" property
   if(FileWriteDouble(file_handle,ObjectGetDouble(m_chart_id,m_name,OBJPROP_SCALE))!=sizeof(double))                       return(false);
//--- writing value of the "time scale" property
   if(FileWriteInteger(file_handle,(int)ObjectGetInteger(m_chart_id,m_name,OBJPROP_DATE_SCALE),CHAR_VALUE)!=sizeof(char))  return(false);
//--- writing value of the "price scale" property
   if(FileWriteInteger(file_handle,(int)ObjectGetInteger(m_chart_id,m_name,OBJPROP_PRICE_SCALE),CHAR_VALUE)!=sizeof(char)) return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Reading parameters of object from file.                          |
//+------------------------------------------------------------------+
bool CChartObjectSubChart::Load(const int file_handle)
  {
   int    len;
   string str;
//--- checking
   if(file_handle<=0)                   return(false);
   if(m_chart_id==-1)                   return(false);
//--- reading
   if(!CChartObject::Load(file_handle)) return(false);
//--- reading value of the "X-distance" property
   if(!ObjectSetInteger(m_chart_id,m_name,OBJPROP_XDISTANCE,FileReadInteger(file_handle,INT_VALUE)))    return(false);
//--- reading value of the "Y-distance" property
   if(!ObjectSetInteger(m_chart_id,m_name,OBJPROP_YDISTANCE,FileReadInteger(file_handle,INT_VALUE)))    return(false);
//--- reading value of the "corner" property
   if(!ObjectSetInteger(m_chart_id,m_name,OBJPROP_CORNER,FileReadInteger(file_handle,INT_VALUE)))       return(false);
//--- reading value of the "X-size" property
   if(!ObjectSetInteger(m_chart_id,m_name,OBJPROP_XSIZE,FileReadInteger(file_handle,INT_VALUE)))        return(false);
//--- reading value of the "Y-size" property
   if(!ObjectSetInteger(m_chart_id,m_name,OBJPROP_YSIZE,FileReadInteger(file_handle,INT_VALUE)))        return(false);
//--- reading value of the "symbol" property
   len=FileReadInteger(file_handle,INT_VALUE);
   if(len!=0) str=FileReadString(file_handle,len);
   else       str="";
   if(!ObjectSetString(m_chart_id,m_name,OBJPROP_SYMBOL,str))                                           return(false);
//--- reading value of the "period" property
   if(!ObjectSetInteger(m_chart_id,m_name,OBJPROP_PERIOD,FileReadInteger(file_handle,INT_VALUE)))       return(false);
//--- reading value of the "scale" property
   if(!ObjectSetDouble(m_chart_id,m_name,OBJPROP_SCALE,FileReadDatetime(file_handle)))                  return(false);
//--- reading value of the "time scale" property
   if(!ObjectSetInteger(m_chart_id,m_name,OBJPROP_DATE_SCALE,FileReadInteger(file_handle,CHAR_VALUE)))  return(false);
//--- reading value of the "price scale" property
   if(!ObjectSetInteger(m_chart_id,m_name,OBJPROP_PRICE_SCALE,FileReadInteger(file_handle,CHAR_VALUE))) return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
