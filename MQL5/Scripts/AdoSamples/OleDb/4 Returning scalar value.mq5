//+------------------------------------------------------------------+
//|                                       Returning scalar value.mq5 |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
//----------------------------------------------------------------
// This sample demonstrates how to execute sql statement, which
// returns single value (one record with one cell, scalar function etc).
// We'll calculate total employees salary and will get name of
// the youngest employee
//----------------------------------------------------------------

#property copyright "GF1D, 2010"
#property link      "garf1eldhome@mail.ru"
#property version   "1.00"

// include OleDb components
#include <Ado\Providers\OleDb.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
// connection
   COleDbConnection *conn=new COleDbConnection();
   conn.ConnectionString("Provider=Microsoft.Jet.OLEDB.4.0;Data Source=MQL5\Files\adotest.mdb");

// command for the total salay calculation
   COleDbCommand *cmdSalary=new COleDbCommand();
   cmdSalary.Connection(conn);
   cmdSalary.CommandText("SELECT SUM(p.Salary) " +
                         "FROM Employees e "+
                         "INNER JOIN Professions p "
                         "ON p.Id = e.ProfessionId;");

// command for the youngest employee name
   COleDbCommand *cmdEmp=new COleDbCommand();
   cmdEmp.Connection(conn);
   cmdEmp.CommandText("SELECT Name " +
                      "FROM Employees "+
                      "WHERE BirthDate = (SELECT MAX(BirthDate) FROM Employees);");

   if(CheckAdoError())
     {
      delete cmdSalary;
      delete cmdEmp;
      ResetAdoError();  // reset error
      return;
     }

   conn.Open();

// retrieve total salary
   CAdoValue *valSalary=cmdSalary.ExecuteScalar();

// retrieve the youngest employee name
   CAdoValue *valEmp=cmdEmp.ExecuteScalar();

   conn.Close();

   if(!CheckAdoError())
     {
      // print results
      Alert("Total salary: ",valSalary.AnyToString()," units");
      Alert("The youngest employee: ",valEmp.AnyToString());
     }

// values, retrieved through ExecuteScalar have to be deleted explictly
   delete valSalary;
   delete valEmp;

   delete conn;
   delete cmdSalary;
   delete cmdEmp;
  }
//+------------------------------------------------------------------+
