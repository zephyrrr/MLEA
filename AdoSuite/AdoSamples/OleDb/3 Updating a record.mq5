//+------------------------------------------------------------------+
//|                                            Updating a record.mq5 |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
//----------------------------------------------------------------
// The sample demonstrates how to update records in a database 
// table using COleDbCommand class. We'll increase the salary of 
// all the programmers by 1000 units 
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
   conn.ConnectionString("Provider=Microsoft.Jet.OLEDB.4.0;Data Source=1\MQL5\Files\adotest.mdb");

// create command
   COleDbCommand *cmd=new COleDbCommand();

// specify the connection which will be used by the command
   cmd.Connection(conn);

// specify the query for increasing programmer's salary by 1000 units
   cmd.CommandText("UPDATE Professions "+
                   "SET Salary = Salary + 1000 "+
                   "WHERE Title = ?;");

// add parameters

// Profession: programmer
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
