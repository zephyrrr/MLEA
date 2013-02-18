//+------------------------------------------------------------------+
//|                                                  DbParameter.mqh |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
#property copyright "GF1D, 2010"
#property link      "garf1eldhome@mail.ru"

#include "..\..\Data\AdoValue.mqh"
#include "..\..\AdoTypes.mqh"
#include "ClrObject.mqh"

//--------------------------------------------------------------------
#import "AdoSuite.dll"
	void SetDbParameterDirection(const long, const int, string&, string&);
	int GetDbParameterDirection(const long, string&, string&);
	void SetDbParameterName(const long, const string, string&, string&);
	string GetDbParameterName(const long, string&, string&);
	int GetDbParameterType(const long, string&, string&);
	bool GetDbParameterValueBool(const long, string&, string&);
	void SetDbParameterValueBool(const long, const bool, string&, string&);
	long GetDbParameterValueLong(const long, string&, string&);
	void SetDbParameterValueLong(const long, const long, string&, string&);
	double GetDbParameterValueDouble(const long, string&, string&);
	void SetDbParameterValueDouble(const long, const double, string&, string&);
	string GetDbParameterValueString(const long, string&, string&);
	void SetDbParameterValueString(const long, const string, string&, string&);
	void GetDbParameterValueDateTime(const long, MqlDateTime&, string&, string&);
	void SetDbParameterValueDateTime(const long, MqlDateTime&, string&, string&);
#import

//--------------------------------------------------------------------
/// \brief  \~russian ѕеречисление, представл€ющее направление параметра команды
///         \~english Represents parameter direction
enum ENUM_DBPARAMETER_DIRECTION
{
   DIRECTION_INPUT = 1,
   DIRECTION_INPUT_OUTPUT = 3,
   DIRECTION_OUTPUT = 2,
   DIRECTION_RETURNVALUE = 6
};

//--------------------------------------------------------------------
/// \brief  \~russian  ласс, представл€ющий параметр команды
///         \~english Represents command parameter
class CDbParameter : public CClrObject
{
private: 
   CAdoValue* _Value;
   
public:
   /// \brief  \~russian конструктор класса
   ///         \~english constructor
   CDbParameter() { MqlTypeName("CDbParameter"); }
   /// \brief  \~russian деструктор класса
   ///         \~english destructor
   ~CDbParameter();
   
// properties

   /// \brief  \~russian ¬озвращает направление параметра
   ///         \~english Gets parameter direction
   void Direction(ENUM_DBPARAMETER_DIRECTION value);
   /// \brief  \~russian «адает направление параметра
   ///         \~english Sets parameter direction
   ENUM_DBPARAMETER_DIRECTION Direction();

   /// \brief  \~russian ¬озвращает им€ параметра
   ///         \~english Gets parameter name
   void ParameterName(string value);
   /// \brief  \~russian «адает им€ параметра
   ///         \~english Sets parameter name
   const string ParameterName();
   
   /// \brief  \~russian ¬озвращает значение параметра
   ///         \~english Get value, associated with the parameter
   CAdoValue* Value();
   /// \brief  \~russian ”станавливает значение параметра
   ///         \~english Get value, associated with the parameter
   void Value(CAdoValue* value);
};

//--------------------------------------------------------------------
CDbParameter::~CDbParameter(void)
{
   if (CheckPointer(_Value) == POINTER_DYNAMIC)
   {
      delete _Value;
      _Value = NULL;
   }
}

//--------------------------------------------------------------------
ENUM_DBPARAMETER_DIRECTION CDbParameter::Direction(void)
{
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
 
   ENUM_DBPARAMETER_DIRECTION dir = GetDbParameterDirection(ClrHandle(), exType, exMsg);
   
   if (exType != "") 
   {
      OnClrException("Direction(get)", exType, exMsg);
      return -1;
   }  
   
   return dir;
}

//--------------------------------------------------------------------
CDbParameter::Direction(ENUM_DBPARAMETER_DIRECTION value)
{
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
 
   SetDbParameterDirection(ClrHandle(), value, exType, exMsg);
   
   if (exType != "") 
      OnClrException("Direction(set)", exType, exMsg);
}

//--------------------------------------------------------------------
string CDbParameter::ParameterName(void)
{
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
 
   string name = GetDbParameterName(ClrHandle(), exType, exMsg);
   
   if (exType != "") 
      OnClrException("ParameterName(get)", exType, exMsg);
      
   return name;
}

//--------------------------------------------------------------------
CDbParameter::ParameterName(string value)
{
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);

   SetDbParameterName(ClrHandle(), value, exType, exMsg);
   
   if (exType != "") 
      OnClrException("ParameterName(set)", exType, exMsg);
}

//--------------------------------------------------------------------
CAdoValue* CDbParameter::Value(void)
{
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
   
   int type = GetDbParameterType(ClrHandle(), exType, exMsg);
   
   if (exType != "") 
   {
      OnClrException("Value(get){GetDbParameterType}", exType, exMsg);
      return NULL;
   }
      
   if (CheckPointer(_Value) == POINTER_INVALID)
      _Value = new CAdoValue();
      
   switch (type + ADOTYPE_VALUE)
   {
      case ADOTYPE_BOOL:
         _Value.SetValue(GetDbParameterValueBool(ClrHandle(), exType, exMsg));
         break;
   
      case ADOTYPE_LONG:
         _Value.SetValue(GetDbParameterValueLong(ClrHandle(), exType, exMsg));
         break;

      case ADOTYPE_DOUBLE:
         _Value.SetValue(GetDbParameterValueDouble(ClrHandle(), exType, exMsg));
         break;

      case ADOTYPE_STRING:
         _Value.SetValue(GetDbParameterValueString(ClrHandle(), exType, exMsg));
         break;

      case ADOTYPE_DATETIME:
         {
            MqlDateTime mdt;
            GetDbParameterValueDateTime(ClrHandle(), mdt, exType, exMsg);
            _Value.SetValue(mdt);
         }
         break;
      default:
         exType = "UnknownAdoTypeException";
         break;
   }   
   
   if (exType != "") 
   {
      OnClrException("Value(get){GetDbParameterValue}", exType, exMsg);
      return NULL;
   }
      
   return _Value;
}

//--------------------------------------------------------------------
CDbParameter::Value(CAdoValue *value)
{
  if (CheckPointer(_Value) == POINTER_DYNAMIC)
      delete _Value;
      
   if (value == NULL)
   {
      OnClrException("Value(set)", "ArgumentException", "");
      return;
   }
      
   _Value = value;
   
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
  
   switch (_Value.Type())
   {
       case ADOTYPE_BOOL:
         SetDbParameterValueBool(ClrHandle(), _Value.ToBool(), exType, exMsg);
         break;
   
      case ADOTYPE_LONG:
         SetDbParameterValueLong(ClrHandle(), _Value.ToLong(), exType, exMsg);
         break;

      case ADOTYPE_DOUBLE:
         SetDbParameterValueDouble(ClrHandle(), _Value.ToDouble(), exType, exMsg);
         break;

      case ADOTYPE_STRING:
         SetDbParameterValueString(ClrHandle(), _Value.ToString(), exType, exMsg);
         break;

      case ADOTYPE_DATETIME:
         {
            MqlDateTime mdt;
            mdt = _Value.ToDatetime();
            SetDbParameterValueDateTime(ClrHandle(), mdt, exType, exMsg);
         }
         break;
         
      default:
         exType = "UnknownAdoTypeException";
         break;
   }
  
   if (exType != "") 
      OnClrException("Value(set){SetDbParameterValue}", exType, exMsg);
}