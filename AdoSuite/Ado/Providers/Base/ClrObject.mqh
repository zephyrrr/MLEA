//+------------------------------------------------------------------+
//|                                                    ClrObject.mqh |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
#property copyright "GF1D, 2010"
#property link      "garf1eldhome@mail.ru"

#include "..\..\AdoErrors.mqh"

//--------------------------------------------------------------------
#import "AdoSuite.dll"
   long CreateManagedObject(const string, const string, string&, string&);
   void DestroyManagedObject(const long, string&, string&);
#import

//--------------------------------------------------------------------
/// \brief  \~russian Объект исполняющей среды .NET.
///         \~english Represents CLR Object.
///
/// \~russian Содержит необходимые методы для создания и уничтожения управляемых объектов, обработки исключений при вызове. Является базовым класом
/// \~english Includes neccessary methods for creating and disposing managed objects, exception handling. Abstract class
class CClrObject
{
private:
// variables
   bool _IsCreated, _IsAssigned;
   long _ClrHandle;
   string _MqlTypeName;

protected:
   
// properties
   
   /// \brief  \~russian Возвращает имя типа, который представляет производный класс
   ///         \~english Gets type string of inherited class
   const string MqlTypeName() { return _MqlTypeName; }
   /// \brief  \~russian Устанавливает имя типа, который представляет производный класс
   ///         \~english Sets type string of inherited class
   void MqlTypeName(const string value) { _MqlTypeName = value; }
   
// methods
   
   /// \brief  \~russian Создает объект CLR 
   ///         \~english Creates CLR object
   /// \~russian \param  asmName   имя сборки. Используется короткое имя сборки: System, System.Data и т п 
   /// \~english \param  asmName   short assembly name: System, System.Data etc
   /// \~russian \param  typeName  полное имя типа: System.String, System.Data.DataTable и т п
   /// \~english \param  typeName  full type name eg System.String, System.Data.DataTable etc
   void CreateClrObject(const string asmName, const string typeName);   
   /// \brief  \~russian Уничтожает объект CLR. Автоматически вызывается в деструкторе, поэтому явно вызывать не нужно!
   ///         \~english Destroys CLR object. Called automatically in desctructor, so dont call it explictly!
   void DestroyClrObject();
   
// events

   /// \brief  \~russian Вызывается перед тем как объект будет создан. Виртуальный метод
   ///         \~english Called before object is being created. Virtual
   /// \~russian \param isCanceling  переменная bool, передающаяся по cсылке. Если установить значение false, то создание объекта будет подавлено
   /// \~english \param isCanceling  bool variable, passed by a reference. If set value to false, then object creation will be suppressed
   /// \~russian \param creating    true - если объект создается, false - если объект присваивается через функцию CClrObject::Assign
   /// \~english \param creating    when true indicates that object is creating, otherwise object is assigning using CClrObject::Assign
   virtual void OnObjectCreating(bool& isCanceling, bool creating = true)   {}
   /// \brief  \~russian Вызывается после того, как Clr объект создан. Виртуальный метод
   ///         \~english Called after CLR object was created
   virtual void OnObjectCreated()                        {}
   /// \brief  \~russian Вызывается перед тем, как Clr объект будет уничтожен. Виртуальный метод
   ///         \~english Called before object is being destroyed. Virtual
   virtual void OnObjectDestroying()                     {}
   /// \brief  \~russian Вызывается после того, как Clr объект уничтожен. Виртуальный метод
   ///         \~english Called after CLR object was destroyed
   virtual void OnObjectDestroyed()                      {}
   
   /// \brief  \~russian Вызывается в случае исключения(ошибки). Виртуальный метод.
   ///         \~english Called when an exception occurs. Virtual
   /// \~russian \param method    имя метода, в котором произошло исключение
   /// \~english \param method    method name where the exception was thrown
   /// \~russian \param type      тип исключения. Обычно один из .NET типов 
   /// \~english \param type      exception type. Usually one of .NET types
   /// \~russian \param message   подробная информация об ошибке 
   /// \~english \param message   exception message. Describes error details
   /// \~russian \param mqlErr    ошибка mql, соответствующая данному исключению. По умолчанию ADOERR_FIRST  
   /// \~english \param mqlErr    appropriate mql error equivalent. ADOERR_FIRST by default
  virtual void OnClrException(const string method, const string type, const string message, const ushort mqlErr);
   
public: 
   /// \brief  \~russian конструктор класса
   ///         \~english constructor
   CClrObject() { _MqlTypeName = "CClrObject"; }
   /// \brief  \~russian деструктор класса
   ///         \~english destructor
   ~CClrObject() { DestroyClrObject(); }
   
// properties
   
   /// \brief  \~russian Возвращает указатель на GCHandle, содержащий объект
   ///         \~english Returns pointer for GCHandle, catching the object
   const long ClrHandle() { return _ClrHandle; }
   /// \brief  \~russian Возвращает true если объект был присвоен, в противном случае false
   ///         \~english Indicates whether object was assigned
   const bool IsAssigned() { return _IsAssigned; }
   /// \brief  \~russian Возвращает true если объект был создан из mql кода, в противном случае false
   ///         \~english Indicates whether object was created
   const bool IsCreated() { return _IsCreated; }
   
// methods

   /// \brief  \~russian Присвязывает объект к уже созданному объекту CLR 
   ///         \~english Assigns this object to an existing CLR object
   /// \~russian \param handle       указатель на GCHanlde, содержащий объект 
   /// \~english \param handle       pointer to GCHanlde with object
   /// \~russian \param autoDestroy  true - если CLR объект необходимо уничтожить с уничтожением соответствующего ССlrObject, false - если объект нужно остваить в памяти. По умолчанию false.
   /// \~english \param autoDestroy  Indicates whether CLR object has to be destroyed with appropriate ССlrObject
   void Assign(const long handle, const bool autoDestroy); 
};

//--------------------------------------------------------------------
void CClrObject::CreateClrObject(const string asmName, const string typeName)
{
   bool isCanceling = false;
   
   OnObjectCreating(isCanceling, true);
   
   if (isCanceling) return;
   
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);

   _ClrHandle = CreateManagedObject(asmName, typeName, exType, exMsg);
   
   if (exType != "") 
   {
      _IsCreated = false;
      OnClrException("CreateClrObject", exType, exMsg);
   }
   else _IsCreated = true;
   _IsAssigned = false;
   
   OnObjectCreated();

}

//--------------------------------------------------------------------
CClrObject::DestroyClrObject(void)
{
   if (!_IsCreated) return;

   OnObjectDestroying();
   
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
 
   DestroyManagedObject(_ClrHandle, exType, exMsg);
   
   _IsCreated = false;
   
   if (exType != "") 
      OnClrException("DestroyClrObject", exType, exMsg);
   
   OnObjectDestroyed();
}

//--------------------------------------------------------------------
CClrObject::Assign(const long handle, const bool autoDestroy = false)
{
   bool isCanceling = false;
   OnObjectCreating(isCanceling, false);
   
   if (isCanceling) return;
    
   _ClrHandle = handle;
   _IsCreated = autoDestroy;
   _IsAssigned = true;
  
   OnObjectCreated();
}

//--------------------------------------------------------------------
CClrObject::OnClrException(const string method, const string type, const string message, const ushort mqlErr = ADOERR_FIRST)
{
   Alert("Метод ", _MqlTypeName, "::", method, " выдал исключение типа ", type, ":\r\n", message);
   SetUserError(mqlErr);
}
