//+------------------------------------------------------------------+
//|                                                 Select query.mq5 |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
//----------------------------------------------------------------
// This sample demonstrates how to execute select statement and read
// resulting data using DataReader class. We'll recieve information
// about all the employees
//----------------------------------------------------------------

#property copyright "GF1D, 2010"
#property link      "garf1eldhome@mail.ru"
#property version   "1.00"

#include <Object.mqh>
#include <Arrays\List.mqh>

// include OleDb components
#include <Ado\Providers\OleDb.mqh>
//----------------------------------------------------------------
// declare class to store information about employees
class Employee : public CObject
  {
private:
   string            _Name;
   MqlDateTime       _BirthDate;
   bool              _IsMarried;

public:
   const string Name() { return _Name; }
   void Name(const string value) { _Name=value; }

   const MqlDateTime BirthDate() { return _BirthDate; }
   void BirthDate(MqlDateTime &value) { _BirthDate=value; }

   const bool IsMarried() { return _IsMarried; }
   void IsMarried(const bool value) { _IsMarried=value; }
  };
//----------------------------------------------------------------
void OnStart()
  {
// connection
   COleDbConnection *conn=new COleDbConnection();
   conn.ConnectionString("Provider=Microsoft.Jet.OLEDB.4.0;Data Source=MQL5\Files\adotest.mdb");

// command for retrieving the information
   COleDbCommand *cmd=new COleDbCommand();
   cmd.Connection(conn);
   cmd.CommandText("SELECT Name, BirthDate, IsMarried " +
                   "FROM Employees;");

   if(CheckAdoError())
     {
      delete cmd;
      ResetAdoError();  
      return;
     }

   conn.Open();

// get reader for the query result
   COleDbDataReader *reader=cmd.ExecuteReader();

// create new employees list
   CList *employees=new CList();

// fill the list using reader
   while(reader.Read())
     {
      Employee *e=new Employee();
      e.Name(reader.GetValue("Name").ToString());
      MqlDateTime mdt;
      mdt=reader.GetValue("BirthDate").ToDatetime();
      e.BirthDate(mdt);
      e.IsMarried(reader.GetValue("IsMarried").ToBool());

      employees.Add(e);
     }

   conn.Close();

   if(!CheckAdoError())
     {
      Alert(IntegerToString(employees.Total())+" records read");
     }

   delete conn;
   delete cmd;
   delete reader;
   delete employees;
  }
//+------------------------------------------------------------------+
