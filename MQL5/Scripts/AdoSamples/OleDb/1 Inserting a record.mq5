//+------------------------------------------------------------------+
//|                                           Inserting a record.mq5 |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
//----------------------------------------------------------------
// The sample demonstrates how to insert records into a database table
// using COleDbCommand class. We'll add some data about new employee
// into Employees table
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
// create connection to a database
   COleDbConnection *conn=new COleDbConnection();

// specify connection string to a MS Access file located in Metatrader\MQL5\Files
   conn.ConnectionString("Provider=Microsoft.Jet.OLEDB.4.0;Data Source=MQL5\Files\adotest.mdb");

// create command
   COleDbCommand *cmd=new COleDbCommand();

// specify the connection which will be used by the command
   cmd.Connection(conn);

// specify the query for adding new employee
   cmd.CommandText("INSERT INTO Employees(Name, BirthDate, IsMarried, ProfessionId) "+
                   "SELECT ?, ?, ?, Id FROM Professions WHERE Title = ?; ");

// adding parameters: parameters in OleDb are defined as ? symbol
// and the values will be applied sequentially

// Ivan D. Rezakov
   CAdoValue *valName=new CAdoValue();
   valName.SetValue("Ivan D. Rezakov");   // set value
   cmd.Parameters().Add("", valName);     // add parameter
   
// Birth date 10.04.1984
   MqlDateTime mdBirth;
   mdBirth.day = 10;
   mdBirth.mon = 4;
   mdBirth.year= 1984;
   CAdoValue *valDate=new CAdoValue();
   valDate.SetValue(mdBirth);
   cmd.Parameters().Add("",valDate);
// Married
   CAdoValue *valMarried=new CAdoValue();
   valMarried.SetValue(true);
   cmd.Parameters().Add("",valMarried);
// A programmer
   CAdoValue *valProf=new CAdoValue();
   valProf.SetValue("Programmer");
   cmd.Parameters().Add("",valProf);

// check for errors
   if(CheckAdoError())
     {
      // delete created objects to release memory
      delete conn;
      delete cmd;
      ResetAdoError();  // reset error
      return;
     }

// open connection
   conn.Open();

// executing sql statement
   cmd.ExecuteNonQuery();

// close connection
   conn.Close();

// delete 'standalone' objects - the command and the connection
// command parameters will be deleted with the command, 
// so you dont have to delete them explictly
   delete conn;
   delete cmd;
  }
//+------------------------------------------------------------------+
