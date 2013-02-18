//+------------------------------------------------------------------+
//|                                                 DbDataReader.mqh |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
#property copyright "GF1D, 2010"
#property link      "garf1eldhome@mail.ru"

#include "ClrObject.mqh"
#include "..\..\AdoTypes.mqh"
#include "..\..\Data\AdoValue.mqh"

//--------------------------------------------------------------------
#import "AdoSuite.dll"
bool DbDataReaderRead(const long,string&,string&);
int DbDataReaderClose(const long,string&,string&);
bool DbDataReaderIsClosed(const long,string&,string&);
void DbDataReaderColumnScheme(const long,const int,string&,int&,string&,string&);
int DbDataReaderGetFieldsCount(const long,string&,string&);
bool DbReaderGetBool(const long,const int,string&,string&);
long DbReaderGetLong(const long,const int,string&,string&);
double DbReaderGetDouble(const long,const int,string&,string&);
string DbReaderGetString(const long,const int,string&,string&);
void DbReaderGetDateTime(const long,const int,MqlDateTime&,string&,string&);
#import
//--------------------------------------------------------------------
/// \brief  \~russian Класс для чтения данных в прямом направлении
///         \~english Reads a forward-only stream of rows from a data source
class CDbDataReader : public CClrObject
  {
private:
   string            _FieldNames[];
   int               _FieldTypes[];
   CAdoValue        *_CurrentRow[];

protected:
   // events
   virtual void      OnObjectCreated();

public:
   /// \brief  \~russian конструктор класса
   ///         \~english constructor
                     CDbDataReader() { MqlTypeName("CDbDataReader"); }
   /// \brief  \~russian деструктор класса
   ///         \~english destructor
                    ~CDbDataReader();

   // properties

   /// \brief  \~russian Проверяет закрыт ли объект и выозвращает true если закрыт
   ///         \~english Checks whether reader is closed
   const bool        IsClosed();

   /// \brief  \~russian Возвращает количество столбцов в читаемой выборке
   ///         \~english Gets field count of the row
   const int FieldCount() { return ArraySize(_FieldNames); }

   /// \brief  \~russian Возвращает имя столбца по его индексу
   ///         \~english Gets column name by index
   const string      FieldName(const int index);
   /// \brief  \~russian Возвращает тип столбца по его индексу
   ///         \~english Gets column type by index
   const ENUM_ADOTYPES FieldType(const int index);
   /// \brief  \~russian Возвращает тип столбца по его имени
   ///         \~english Gets column type by name
   const ENUM_ADOTYPES FieldType(const string name);

   /// \brief  \~russian Возвращает значение поля по индексу
   ///         \~english Gets value by index
   CAdoValue        *GetValue(const int index);
   /// \brief  \~russian Возвращает значение поля по имени
   ///         \~english Gets value by name
   CAdoValue        *GetValue(const string name);

   // methods

   /// \brief  \~russian Перемещает курсор на следующую запись
   ///         \~english Moves the cursor to the next row
   /// \return \~russian true - если крсор перемещен и можно считать данные, false в противном случае \~english true if the cursor is moved and the data can be read, false otherwise
   bool              Read();
   /// \brief  \~russian Закрывает курсор
   ///         \~english Closes reader
   void              Close();
  };
//--------------------------------------------------------------------
CDbDataReader::OnObjectCreated()
  {
   if(!IsAssigned()) return;

   string exType="",exMsg="";
   StringInit(exType,64);
   StringInit(exMsg,256);

   int fCount=DbDataReaderGetFieldsCount(ClrHandle(),exType,exMsg);

   if(exType!="")
     {
      OnClrException("OnObjectCreated(DbDataReaderGetFieldsCount)",exType,exMsg);
      return;
     }

   ArrayResize(_FieldNames,fCount);
   ArrayResize(_FieldTypes,fCount);
   ArrayResize(_CurrentRow,fCount);

// load scheme
   for(int i=0; i<fCount; i++)
     {
      string name="";
      StringInit(name,32);
      int type=-1;

      DbDataReaderColumnScheme(ClrHandle(),i,name,type,exType,exMsg);

      if(exType!="")
        {
         OnClrException("OnObjectCreated{DbDataReaderLoadStructure}",exType,exMsg);
         return;
        }

      _FieldNames[i] = name;
      _FieldTypes[i] = type + ADOTYPE_VALUE;
      _CurrentRow[i] = new CAdoValue();
     }
  }
//--------------------------------------------------------------------
CDbDataReader::~CDbDataReader()
  {
   for(int i=0; i<ArraySize(_CurrentRow); i++)
      if(CheckPointer(_CurrentRow[i])==POINTER_DYNAMIC)
        {
         delete _CurrentRow[i];
         _CurrentRow[i]=NULL;
        }
  }
//--------------------------------------------------------------------
bool CDbDataReader::IsClosed(void)
  {
   string exType="",exMsg="";
   StringInit(exType,64);
   StringInit(exMsg,256);

   bool value=DbDataReaderIsClosed(ClrHandle(),exType,exMsg);

   if(exType!="")
      OnClrException("IsClosed",exType,exMsg);

   return value;
  }
//--------------------------------------------------------------------
string CDbDataReader::FieldName(const int index)
  {
   if(index<0 || index>=FieldCount()) return "";
   else return _FieldNames[index];
  }
//--------------------------------------------------------------------
ENUM_ADOTYPES CDbDataReader::FieldType(const int index)
  {
   if(index<0 || index>=FieldCount()) return -1;
   else return _FieldTypes[index];
  }
//--------------------------------------------------------------------
ENUM_ADOTYPES CDbDataReader::FieldType(const string name)
  {
   int index = -1;
   for(int i = 0; i < FieldCount(); i++)
      if(_FieldNames[i]==name)
        {
         index=i;
         break;
        }

   return FieldType(index);
  }
//--------------------------------------------------------------------
CAdoValue *CDbDataReader::GetValue(const int index)
  {
   if(index<0 || index>=FieldCount()) return NULL;
   else return _CurrentRow[index];
  }
//--------------------------------------------------------------------
CAdoValue *CDbDataReader::GetValue(const string name)
  {
   int index = -1;
   for(int i = 0; i < FieldCount(); i++)
      if(_FieldNames[i]==name)
        {
         index=i;
         break;
        }

   return GetValue(index);
  }
//--------------------------------------------------------------------
bool CDbDataReader::Read(void)
  {
   string exType="",exMsg="";
   StringInit(exType,64);
   StringInit(exMsg,256);

   bool read=DbDataReaderRead(ClrHandle(),exType,exMsg);

   if(exType!="" || !read)
     {
      for(int i=0; i<FieldCount(); i++) _CurrentRow[i].Empty();

      if(exType!="")
         OnClrException("Read",exType,exMsg);

      return false;
     }

   for(int i=0; i<FieldCount(); i++)
     {
      switch(_FieldTypes[i])
        {
         case ADOTYPE_BOOL:
            _CurrentRow[i].SetValue(DbReaderGetBool(ClrHandle(),i,exType,exMsg));
            break;

         case ADOTYPE_LONG:
            _CurrentRow[i].SetValue(DbReaderGetLong(ClrHandle(),i,exType,exMsg));
            break;

         case ADOTYPE_DOUBLE:
            _CurrentRow[i].SetValue(DbReaderGetDouble(ClrHandle(),i,exType,exMsg));
            break;

         case ADOTYPE_STRING:
            _CurrentRow[i].SetValue(DbReaderGetString(ClrHandle(),i,exType,exMsg));
            break;

         case ADOTYPE_DATETIME:
           {
            MqlDateTime mdt;
            DbReaderGetDateTime(ClrHandle(),i,mdt,exType,exMsg);
            _CurrentRow[i].SetValue(mdt);
           }
         break;

         default:
            exType="UnknownAdoTypeException";
            break;
        }

      if(exType!="")
        {
         for(int i=0; i<FieldCount(); i++) _CurrentRow[i].Empty();

         OnClrException("Read(get value)",exType,exMsg);
         return false;
        }
     }

   return true;
  }
//--------------------------------------------------------------------
CDbDataReader::Close(void)
  {
   string exType="",exMsg="";
   StringInit(exType,64);
   StringInit(exMsg,256);

   DbDataReaderClose(ClrHandle(),exType,exMsg);

   if(exType!="")
      OnClrException("Close",exType,exMsg);
  }
//+------------------------------------------------------------------+
