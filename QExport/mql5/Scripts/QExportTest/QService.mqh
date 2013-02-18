//+------------------------------------------------------------------+
//|                                                     QService.mqh |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
#property copyright "GF1D, 2010"
#property link      "garf1eldhome@mail.ru"

//--------------------------------------------------------------------
#import "QExportWrapper.dll"
   long  CreateExportService(string);
   void DestroyExportService(long);
   void SendTick(long, string, MqlTick&);
   void RegisterSymbol(long, string);
   void UnregisterSymbol(long, string);
#import

//--------------------------------------------------------------------
class QService
{
   private:
      // service pointer
      long hService;
      // service name
      string serverName;
      // name of the global variable of the service
      string gvName;
      // flag that indicates is service closed or not
      bool wasDestroyed;
      
      // enters the critical section
      void EnterCriticalSection();
      // leaves the critical section
      void LeaveCriticalSection();
      
   public:
   
      QService();
      ~QService();
      
      // opens service
      void Create(const string);
      // closes service
      void Close();
      // sends tick
      void SendTick(const string, MqlTick&);
};

//--------------------------------------------------------------------
QService::QService()
{
   wasDestroyed = false;
}

//--------------------------------------------------------------------
QService::~QService()
{
   // close if it hasn't been destroyed
   if (!wasDestroyed)
      Close();
}

//--------------------------------------------------------------------
QService::Create(const string serviceName)
{
   EnterCriticalSection();
   
   serverName = serviceName;
   
   bool exists = false;
   string name;
   
   // check for the active service with such name
   for (int i = 0; i < GlobalVariablesTotal(); i++)
   {
      name = GlobalVariableName(i);
      if (StringFind(name, "QService|" + serverName) == 0)
      {
         exists = true;
         break;
      }
   }
   
   if (!exists)   // if not exists
   {
      // starting service
      hService = CreateExportService(serverName);
      // adding a global variable
      gvName = "QService|" + serverName + ">" + (string)hService;
      GlobalVariableTemp(gvName);
      GlobalVariableSet(gvName, 1);
   }
   else          // the service is exists
   {
      gvName = name;
      // service handle
      hService = (int)StringSubstr(gvName, StringFind(gvName, ">") + 1);
      // notify the fact of using the service by this script
      // by increase of its counter
      GlobalVariableSet(gvName, NormalizeDouble(GlobalVariableGet(gvName), 0) + 1);
   }
   
   // register the chart symbol
   RegisterSymbol(hService, Symbol());
   
   LeaveCriticalSection();
}

//--------------------------------------------------------------------
QService::Close()
{
   EnterCriticalSection();
   
   // notifying that this script doen't uses the service
   // by decreasing of its counter
   GlobalVariableSet(gvName, NormalizeDouble(GlobalVariableGet(gvName), 0) - 1);
     
   // close service if there isn't any scripts that uses it
   if (NormalizeDouble(GlobalVariableGet(gvName), 0) < 1.0)
   {
      GlobalVariableDel(gvName);
      DestroyExportService(hService);
   }  
   else UnregisterSymbol(hService, Symbol()); // unregistering symbol
    
   wasDestroyed = true;
   
   LeaveCriticalSection();
}

//--------------------------------------------------------------------
QService::SendTick(const string symbol, MqlTick& tick)
{
   if (!wasDestroyed)
      SendTick(hService, symbol, tick);
}

//--------------------------------------------------------------------
QService::EnterCriticalSection()
{
   while (GlobalVariableCheck("QService_CriticalSection") > 0)
      Sleep(1);
   GlobalVariableTemp("QService_CriticalSection");
}

//--------------------------------------------------------------------
QService::LeaveCriticalSection()
{
   GlobalVariableDel("QService_CriticalSection");
}