//+------------------------------------------------------------------+
//|                                             Filling AdoTable.mq5 |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
//----------------------------------------------------------------
// This sample demonstrates how to execute select statement and read
// resulting data into a table using DataAdapter class. We'll recieve 
// information about all the employees
//----------------------------------------------------------------

#property copyright "GF1D, 2010"
#property link      "garf1eldhome@mail.ru"
#property version   "1.00"

// include OleDb components
#include <Ado\Providers\OleDb.mqh>

#include <Ado\Data.mqh>
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

// create an adapter and specify select command
   COleDbDataAdapter *adapter=new COleDbDataAdapter();
   adapter.SelectCommand(cmd);

// create an empty table
   CAdoTable *employees=new CAdoTable();

// fill the table with data
   adapter.Fill(employees);

   if(!CheckAdoError())
      Alert(IntegerToString(employees.Records().Total())+" records read");

   delete conn;
   delete cmd;
   delete adapter;
   delete employees;
  }
//+------------------------------------------------------------------+
