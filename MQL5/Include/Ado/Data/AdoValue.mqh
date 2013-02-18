//+------------------------------------------------------------------+
//|                                                     AdoValue.mqh |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
#property copyright "GF1D, 2010"
#property link      "garf1eldhome@mail.ru"

#include <Object.mqh>
#include "..\AdoTypes.mqh"
//--------------------------------------------------------------------
/// \brief  \~russian Класс, способный хранить в себе переменные основных типов mql
///         \~english
class CAdoValue : public CObject
  {
private:
   bool              _BoolValue;
   long              _LongValue;
   double            _DoubleValue;
   string            _StringValue;
   MqlDateTime       _DateValue;

   int               _ValueType;
   bool              _HasValue;

public:
   /// \brief  \~russian конструктор
   ///         \~english constructor
                     CAdoValue() { _HasValue=false; }

   /// \brief  \~russian Устанавливет значение
   ///         \~english Sets value
   void              SetValue(const bool val);
   /// \brief  \~russian Устанавливет значение
   ///         \~english Sets value
   void              SetValue(const short val);
   /// \brief  \~russian Устанавливет значение
   ///         \~english Sets value
   void              SetValue(const int val);
   /// \brief  \~russian Устанавливет значение
   ///         \~english Sets value
   void              SetValue(const long val);
   /// \brief  \~russian Устанавливет значение
   ///         \~english Sets value
   void              SetValue(const float val);
   /// \brief  \~russian Устанавливет значение
   ///         \~english Sets value
   void              SetValue(const double val);
   /// \brief  \~russian Устанавливет значение
   ///         \~english Sets value
   void              SetValue(const char val);
   /// \brief  \~russian Устанавливет значение
   ///         \~english Sets value
   void              SetValue(const string val);
   /// \brief  \~russian Устанавливет значение
   ///         \~english Sets value
   void              SetValue(const datetime val);
   /// \brief  \~russian Устанавливет значение
   ///         \~english Sets value
   void              SetValue(const MqlDateTime &val);

   /// \brief  \~russian Возвращает значение логической переменной
   ///         \~english Returns boolean value
   const bool ToBool() { return _BoolValue; }
   /// \brief  \~russian Возвращает значение целочисленной переменной
   ///         \~english Returns long value
   const long ToLong() { return _LongValue; }
   /// \brief  \~russian Возвращает значение переменной с плавающей точкой
   ///         \~english Returns double value
   const double ToDouble() { return _DoubleValue; }
   /// \brief  \~russian Возвращает значение строковой переменной
   ///         \~english Returns string value
   const string ToString() { return _StringValue; }
   /// \brief  \~russian Возвращает значение переменной типа дата
   ///         \~english Returns date value
   const MqlDateTime ToDatetime() { return _DateValue; }

   /// \brief  \~russian Представляет значение в виде строки и возвращает его
   ///         \~english Returns value, converted to string
   const string      AnyToString();

   /// \brief  \~russian Очищает значение класса
   ///         \~english Clears value
   void              Empty();

   /// \brief  \~russian Проверяет, присвоено ли классу значение
   ///         \~english Checks if object has value
   const bool HasValue() { return _HasValue; }

   /// \brief  \~russian Возвращает тип переменной, хранящийся в данном классе
   ///         \~english Returns type of the value, stored in the object
   virtual int Type() { return _ValueType; }

  };
//--------------------------------------------------------------------
CAdoValue::SetValue(const bool val)
  {
   _BoolValue = val;
   _ValueType = ADOTYPE_BOOL;
   _HasValue=true;
  }
//--------------------------------------------------------------------
CAdoValue::SetValue(const long val)
  {
   _LongValue = val;
   _ValueType = ADOTYPE_LONG;
   _HasValue=true;
  }
//--------------------------------------------------------------------
CAdoValue::SetValue(const double val)
  {
   _DoubleValue=val;
   _ValueType= ADOTYPE_DOUBLE;
   _HasValue = true;
  }
//--------------------------------------------------------------------
CAdoValue::SetValue(const string val)
  {
   _StringValue=val;
   _ValueType= ADOTYPE_STRING;
   _HasValue = true;
  }
//--------------------------------------------------------------------
CAdoValue::SetValue(const MqlDateTime &val)
  {
   _DateValue = val;
   _ValueType = ADOTYPE_DATETIME;
   _HasValue=true;
  }
//--------------------------------------------------------------------
CAdoValue::SetValue(const short val)
  {
   SetValue((long)val);
  }
//--------------------------------------------------------------------
CAdoValue::SetValue(const int val)
  {
   SetValue((long)val);
  }
//--------------------------------------------------------------------
CAdoValue::SetValue(const float val)
  {
   SetValue((double)val);
  }
//--------------------------------------------------------------------
CAdoValue::SetValue(const char val)
  {
   SetValue(CharToString(val));
  }
//--------------------------------------------------------------------
CAdoValue::SetValue(const datetime val)
  {
   MqlDateTime time;
   TimeToStruct(val,time);
   SetValue(time);
  }
//--------------------------------------------------------------------
CAdoValue::Empty(void)
  {
   _HasValue=false;
   _BoolValue = NULL;
   _LongValue = NULL;
   _DoubleValue = NULL;
   _StringValue = NULL;
   _DateValue.day = _DateValue.mon = _DateValue.year = 0;
   _DateValue.sec = _DateValue.min = _DateValue.hour = 0;
  }
//--------------------------------------------------------------------
string CAdoValue::AnyToString(void)
  {
   if(!_HasValue) return "";

   switch(Type())
     {
      case ADOTYPE_BOOL: return(string)_BoolValue;
      case ADOTYPE_LONG: return IntegerToString(_LongValue);
      case ADOTYPE_DOUBLE: return DoubleToString(_DoubleValue);
      case ADOTYPE_STRING: return _StringValue;
      case ADOTYPE_DATETIME:
         return(string)_DateValue.day+"."+(string)_DateValue.mon+"."+(string)_DateValue.year+" "
         +(string)_DateValue.hour + ":" + (string)_DateValue.min + ":" + (string)_DateValue.sec;
      default: return "";
     }
  }
//+------------------------------------------------------------------+
