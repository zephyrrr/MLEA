//+------------------------------------------------------------------+
//|                                              DbParameterList.mqh |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
#property copyright "GF1D, 2010"
#property link      "garf1eldhome@mail.ru"

//--------------------------------------------------------------------
#include "DbParameter.mqh"
#include "ClrObject.mqh"

//--------------------------------------------------------------------
#import "AdoSuite.dll"
   void DbParameterListAdd(const long, const long, string&, string&);
   void DbParameterListRemove(const long, const long, string&, string&);
#import

//--------------------------------------------------------------------
/// \brief  \~russian Класс, пердставляющий коллекцию параметров команды
///         \~english Represents parameter collection
class CDbParameterList : public CClrObject
{ 
private: 
   CDbParameter* _Parameters[];
   
protected:
   /// \brief  \~russian Создает параметр команды. Виртуальный метод. Должен быть переопределен в наследниках
   ///         \~english Creates new parameter. Virtual. Must be overriden
   virtual CDbParameter* CreateParameter() { return NULL; }
   
public:
   /// \brief  \~russian конструктор класса
   ///         \~english constructor
   CDbParameterList() { MqlTypeName("CDbParameterList"); }
   /// \brief  \~russian деструктор класса
   ///         \~english destructor
   ~CDbParameterList();
   
// properties

   /// \brief  \~russian Возвращает количество параметров в коллекции
   ///         \~english Gets parameters count
   const int Count() { return ArraySize(_Parameters); }
   
// methods
 
   /// \brief  \~russian Возвращает параметр по индексу
   ///         \~english Gets parameter by index
   CDbParameter* GetByIndex(const int index);
   /// \brief  \~russian Возвращает параметр по имени
   ///         \~english Gets parameter by name
   CDbParameter* GetByName(const string name);
   
   /// \brief  \~russian Добавляет параметр
   ///         \~english Adds new parameter to the collection
   CDbParameter* Add(CDbParameter* par);
   /// \brief  \~russian Добавляет параметр
   ///         \~english Creatres and adds new parameter to the collection
   /// \~russian \param name имя параметра
   /// \~english \param name parameter name
   /// \~russian \param value значение параметра
   /// \~english \param value parameter value
   CDbParameter* Add(const string name, CAdoValue* value);
   
   /// \brief  \~russian Удаляет параметр
   ///         \~english Removes the paramer from the collection
   void Remove(CDbParameter* par);
   /// \brief  \~russian Удаляет параметр по индексу
   ///         \~english Removes parameter by index
   void RemoveByIndex(const int index);
   /// \brief  \~russian Удаляет параметр по имени
   ///         \~english Removes parameter by name
   void RemoveByName(const string name);
};

//--------------------------------------------------------------------
CDbParameterList::~CDbParameterList(void)
{
   for (int i = 0; i < ArraySize(_Parameters); i++)
      if (CheckPointer(_Parameters[i]))
      {
         delete _Parameters[i];
         _Parameters[i] = NULL;
      }
}

//--------------------------------------------------------------------
CDbParameter* CDbParameterList::Add(CDbParameter* parameter)
{
   if (parameter == NULL)
   {
      OnClrException("Add", "ArgumentException", "");
      return NULL;
   }
   
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);

   DbParameterListAdd(ClrHandle(), parameter.ClrHandle(), exType, exMsg);
   
   if (exType != "") 
   {
      OnClrException("Add", exType, exMsg);
      return NULL;
   }
   
   int count = Count();
   ArrayResize(_Parameters, count+1);
   _Parameters[count] = parameter;
   
   return parameter;
}

//--------------------------------------------------------------------
CDbParameter* CDbParameterList::Add(const string name, CAdoValue *value)
{   
   if (value == NULL)
   {
      OnClrException("Add", "ArgumentException", "");
      return NULL;
   }
   
   CDbParameter* par = CreateParameter();
   par.ParameterName(name);
   par.Value(value);
   return Add(par);
}

//--------------------------------------------------------------------
CDbParameterList::Remove(CDbParameter *parameter)
{
   if (parameter == NULL)
   {
      OnClrException("Remove", "ArgumentException", "");
      return;
   }
   
   int count = Count();
   int index = -1;
   bool found = false;
   
   for (int i = 0; i < count; i++)
      if (_Parameters[i].ClrHandle() == parameter.ClrHandle())
      {
         index = i;
         found = true;
         break;
      }
      
   if (!found) return;
   
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
   
   DbParameterListRemove(ClrHandle(), parameter.ClrHandle(), exType, exMsg);
   
   if (exType != "") 
   {
      OnClrException("Remove", exType, exMsg);
      return;
   }

   for (int i = index + 1; i < count; i++)
      _Parameters[i - 1] = _Parameters[i];
      
   if (CheckPointer(parameter) == POINTER_DYNAMIC)
   {
      delete parameter;
      parameter = NULL;
   }
   
   ArrayResize(_Parameters, count - 1);

}

//--------------------------------------------------------------------
CDbParameterList::RemoveByIndex(const int index)
{
   if (index >= Count()) return;
   Remove(_Parameters[index]);
}

//--------------------------------------------------------------------
CDbParameter* CDbParameterList::GetByIndex(const int index)
{
   if (index >= Count()) return NULL;
   
   return _Parameters[index];
}

//--------------------------------------------------------------------
CDbParameter* CDbParameterList::GetByName(const string name)
{
   for (int i = 0; i < Count(); i++)
      if (_Parameters[i].ParameterName() == name)
         return _Parameters[i];
  
   return NULL;
}

//--------------------------------------------------------------------
CDbParameterList::RemoveByName(const string name)
{
   CDbParameter* par = GetByName(name);
   if (par != NULL) Remove(par);
}