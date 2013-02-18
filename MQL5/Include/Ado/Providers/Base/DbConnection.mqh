//+------------------------------------------------------------------+
//|                                                 DbConnection.mqh |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
#property copyright "GF1D, 2010"
#property link      "garf1eldhome@mail.ru"

#include "ClrObject.mqh"
#include "DbTransaction.mqh"

//--------------------------------------------------------------------
#import "AdoSuite.dll"
void OpenDbConnection(const long,string&,string&);
void CloseDbConnection(const long,string&,string&);
int GetDbConnectionState(const long,string&,string&);
string GetDbConnectionString(const long,string&,string&);
void SetDbConnectionString(const long,const string,string&,string&);
int GetDbConnectionTimeout(const long,string&,string&);
long DbConnectionTransaction(const long,string&,string&);
long DbConnectionTransactionLevel(const long,const int,string&,string&);
#import
//--------------------------------------------------------------------
/// \brief  \~russian Перечисление, представляющее состояние подключения к базе данных
///         \~english Describes the current state of the connection to a data source
enum ENUM_CONNECTION_STATE
  {
   CONSTATE_BROKEN = 0x10,
   CONSTATE_CLOSED = 0,
   CONSTATE_CONNECTING= 2,
   CONSTATE_EXECUTING = 4,
   CONSTATE_FETCHING=8,
   CONSTATE_OPEN=1
  };
//--------------------------------------------------------------------
/// \brief  \~russian Класс, позволяющий устанавливать подключение к источнику данных
///         \~english Represents a connection to a database
class CDbConnection : public CClrObject
  {
protected:
   // methods

   /// \brief  \~russian Создает объект транзакции. Виртуальный метод. Должен быть переопределен в наследниках
   ///         \~english Creates transaction. Virtual. Must be overriden
   virtual CDbTransaction *CreateTransaction() { return NULL; }

public:
   /// \brief  \~russian конструктор класса
   ///         \~english constructor
                     CDbConnection() { MqlTypeName("CDbConnection"); }

   // properties

   /// \brief  \~russian Возвращает строку подключения
   ///         \~english Gets connection string
   string            ConnectionString();
   /// \brief  \~russian Задает строку подключения
   ///         \~english Sets connection string
   void              ConnectionString(string value);

   /// \brief  \~russian Возвращает максимальное количество секунд, в течении которых пытаемся подключиться к бд
   ///         \~english Gets connection timeout
   int               ConnectionTimeout();
   /// \brief  \~russian Возвращает текущее состояние соединения
   ///         \~english Gets current connection state
   ENUM_CONNECTION_STATE State();

   // methods

   /// \brief  \~russian Открывает соединение
   ///         \~english Opens the connection
   void              Open();
   /// \brief  \~russian Закрывает соединение
   ///         \~english Closes the connection
   void              Close();

   /// \brief  \~russian Начинает транзакцию
   ///         \~english Begins a transaction
   virtual CDbTransaction *BeginTransaction();
   /// \brief  \~russian Начинает транзакцию с указанным уровнем изоляции
   ///         \~english Begins a transaction with specified isolation level
   /// \~russian \param level Один из возможных уровней изоляции транзакции 
   /// \~english \param level \~russian Transaction isolation level
   CDbTransaction   *BeginTransaction(ENUM_DBTRAN_ISOLATION_LEVEL level);
  };
//--------------------------------------------------------------------
CDbConnection::Open(void)
  {
   string exType="",exMsg="";
   StringInit(exType,64);
   StringInit(exMsg,256);

   OpenDbConnection(ClrHandle(),exType,exMsg);

   if(exType!="")
      OnClrException("Open",exType,exMsg);
  }
//--------------------------------------------------------------------
CDbConnection::Close(void)
  {
   string exType="",exMsg="";
   StringInit(exType,64);
   StringInit(exMsg,256);

   CloseDbConnection(ClrHandle(),exType,exMsg);

   if(exType!="")
      OnClrException("Close",exType,exMsg);
  }
//--------------------------------------------------------------------
ENUM_CONNECTION_STATE CDbConnection::State(void)
  {
   string exType="",exMsg="";
   StringInit(exType,64);
   StringInit(exMsg,256);

   ENUM_CONNECTION_STATE state=GetDbConnectionState(ClrHandle(),exType,exMsg);

   if(exType!="")
      OnClrException("State(get)",exType,exMsg);

   return state;
  }
//--------------------------------------------------------------------
string CDbConnection::ConnectionString(void)
  {
   string exType="",exMsg="";
   StringInit(exType,64);
   StringInit(exMsg,256);

   string conStr=GetDbConnectionString(ClrHandle(),exType,exMsg);

   if(exType!="")
      OnClrException("ConnectionString(get)",exType,exMsg);

   return conStr;
  }
//--------------------------------------------------------------------
void CDbConnection::ConnectionString(string value)
  {
   string exType="",exMsg="";
   StringInit(exType,64);
   StringInit(exMsg,256);

   SetDbConnectionString(ClrHandle(),value,exType,exMsg);

   if(exType!="")
      OnClrException("ConnectionString(set)",exType,exMsg);
  }
//--------------------------------------------------------------------
int CDbConnection::ConnectionTimeout(void)
  {
   string exType="",exMsg="";
   StringInit(exType,64);
   StringInit(exMsg,256);

   int value=GetDbConnectionTimeout(ClrHandle(),exType,exMsg);

   if(exType!="")
      OnClrException("ConnectionTimeout(get)",exType,exMsg);

   return value;
  }
//--------------------------------------------------------------------
CDbTransaction *CDbConnection::BeginTransaction()
  {
   string exType="",exMsg="";
   StringInit(exType,64);
   StringInit(exMsg,256);

   long hTransaction=DbConnectionTransaction(ClrHandle(),exType,exMsg);

   if(exType!="")
     {
      OnClrException("BeginTransaction",exType,exMsg);
      return NULL;
     }

   CDbTransaction *tran=CreateTransaction();
   tran.Assign(hTransaction,true);

   return tran;
  }
//--------------------------------------------------------------------
CDbTransaction *CDbConnection::BeginTransaction(ENUM_DBTRAN_ISOLATION_LEVEL level)
  {
   string exType="",exMsg="";
   StringInit(exType,64);
   StringInit(exMsg,256);

   long hTransaction=DbConnectionTransactionLevel(ClrHandle(),level,exType,exMsg);

   if(exType!="")
     {
      OnClrException("BeginTransaction",exType,exMsg);
      return NULL;
     }

   CDbTransaction *tran=CreateTransaction();
   tran.Assign(hTransaction,true);

   return tran;
  }
//+------------------------------------------------------------------+
