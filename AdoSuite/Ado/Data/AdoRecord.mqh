//+------------------------------------------------------------------+
//|                                                    AdoRecord.mqh |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
#property copyright "GF1D, 2010"
#property link      "garf1eldhome@mail.ru"

#include "..\AdoTypes.mqh"
#include "AdoValueList.mqh"
#include "AdoColumnList.mqh"
#include "AdoValue.mqh"
#include <Object.mqh>

//--------------------------------------------------------------------
/// \brief  \~russian Класс, представляющий запись в таблице
///         \~english Represents a row in a table
class CAdoRecord : public CObject 
{
private:
   // variables
   CAdoValueList* _Values;
   CAdoColumnList* _Columns;
   
protected:
// properties

   /// \brief  \~russian Возвращает коллекцию значений полей 
   ///         \~english Gets value collection for the row
   CAdoValueList* Values();

// methods

   /// \brief  \~russian Создает коллекцию значений для записи. Виртуальный метод
   ///         \~english Creates value collection for the row
   virtual CAdoValueList* CreateValues() { return new CAdoValueList(); }

public:
   /// \brief  \~russian конструктор класса
   ///         \~english constructor
   ~CAdoRecord();
   
// properties

   /// \brief  \~russian Возвращает тип объекта
   ///         \~english
  virtual int Type() { return ADOTYPE_RECORD; }
   
// methods

   /// \brief  \~russian Устанавливает типы ячеек для записи
   ///         \~english Sets column value types for the row
   void SetColumns(CAdoColumnList* value);
   
   /// \brief  \~russian Возвращает значение по индексу
   ///         \~english Gets value by index
   CAdoValue* GetValue(const int index);
   /// \brief  \~russian Возвращает значение по имени
   ///         \~english Gets value by name
   CAdoValue* GetValue(const string name);
   
   virtual int Compare(const CObject* node, int mode = 0);
};

//--------------------------------------------------------------------
CAdoRecord::~CAdoRecord(void)
{
   if (CheckPointer(_Values) == POINTER_DYNAMIC) 
      delete _Values;
}

//--------------------------------------------------------------------
CAdoValueList* CAdoRecord::Values(void)
{
   if (!CheckPointer(_Values))
      _Values = CreateValues();
      
   return _Values;
}

//--------------------------------------------------------------------
int CAdoRecord::Compare(const CObject* node, int mode = 0)
{
   CAdoRecord* rhs = node;
   if (!CheckPointer(rhs)) return 0;
   
   CAdoValueList* rhsValues = rhs.Values();
   
   CAdoValue *val1 = this.Values().GetValue(mode),
      *val2 = rhsValues.GetValue(mode);
   
   if (!CheckPointer(val1) || !CheckPointer(val2)) return 0;
   if (val1.Type() != val2.Type()) return 0;
   
   switch (val1.Type())
   {
      case ADOTYPE_BOOL:
         if (val1.ToBool() > val2.ToBool()) return 1;
         if (val1.ToBool() < val2.ToBool()) return -1;
         break;
         
       case ADOTYPE_LONG:
         if (val1.ToLong() > val2.ToLong()) return 1;
         if (val1.ToLong() < val2.ToLong()) return -1;
         break;
         
       case ADOTYPE_DOUBLE:
         if (val1.ToDouble() > val2.ToDouble()) return 1;
         if (val1.ToDouble() < val2.ToDouble()) return -1;
         break;
         
       case ADOTYPE_STRING:
         if (val1.ToString() > val2.ToString()) return 1;
         if (val1.ToString() < val2.ToString()) return -1;
         break;
         
       case ADOTYPE_DATETIME:
         {
            MqlDateTime time1, time2; 
            time1 = val1.ToDatetime();
            time2 = val2.ToDatetime();
            
            // 0_o
            if (time1.year > time2.year) return 1;
            else if (time1.year < time2.year) return -1;
            else if (time1.mon > time2.mon) return 1;
            else if (time1.mon < time2.mon) return -1;
            else if (time1.day > time2.day) return 1;
            else if (time1.day < time2.day) return -1;
            else if (time1.hour > time2.hour) return 1;
            else if (time1.hour < time2.hour) return -1;
            else if (time1.min > time2.min) return 1;
            else if (time1.min < time2.min) return -1;
            else if (time1.sec > time2.sec) return 1;
            else return -1;
            
     //       if (time1.year > time2.year && time1.mon > time2.mon && time1.day > time2.day && time1.hour > time2.hour && time1.min > time2.min && time1.sec > time2.sec) return 1;
     //       if (time1.year < time2.year && time1.mon < time2.mon && time1.day < time2.day && time1.hour < time2.hour && time1.min < time2.min && time1.sec < time2.sec) return -1;
         }
         break;
         
     default: break;
   }
   
   return 0;
}

//--------------------------------------------------------------------
CAdoRecord::SetColumns(CAdoColumnList *value)
{
   Values().Clear();
   
   int _r = value.Total();
   for (int i = 0; i < value.Total(); i++)
      Values().Add(Values().CreateElement());
      
   _Columns = value;
}

//--------------------------------------------------------------------
CAdoValue* CAdoRecord::GetValue(const int index)
{
   return Values().GetValue(index);
}

//--------------------------------------------------------------------
CAdoValue* CAdoRecord::GetValue(const string name)
{
   for (int i = 0; i < _Columns.Total(); i++)
      if (_Columns.GetColumn(i).ColumnName() == name)
         return Values().GetValue(i);
         
   return NULL;
}