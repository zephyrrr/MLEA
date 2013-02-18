//+------------------------------------------------------------------+
//|                                           Using transactions.mq5 |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
//----------------------------------------------------------------
// The sample demonstrates how to execute multiple commands in a single
// transaction. We'll add new profession "Designer" and an employee
// with similiar occupation
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

// command for adding the profession
   COleDbCommand *cmdProf=new COleDbCommand();
   cmdProf.Connection(conn);
   cmdProf.CommandText("INSERT INTO Professions(Title, Salary) VALUES(?, ?)" );

   CAdoValue *valTitle=new CAdoValue();
   valTitle.SetValue("Designer");
   cmdProf.Parameters().Add("",valTitle);

   CAdoValue *valSalary=new CAdoValue();
   valSalary.SetValue(3000);
   cmdProf.Parameters().Add("",valSalary);

// command for adding an employee
   COleDbCommand *cmdEmp=new COleDbCommand();
   cmdEmp.Connection(conn);
   cmdEmp.CommandText("INSERT INTO Employees(Name, ProfessionId) " +
                      "SELECT ?, Id FROM Professions WHERE Title = ?; ");

   CAdoValue *valName=new CAdoValue();
   valName.SetValue("Kinst S. Shishkin");
   cmdEmp.Parameters().Add("",valName);

   cmdEmp.Parameters().Add("",valTitle);

   if(CheckAdoError())
     {
      delete conn;
      delete cmdProf;
      delete cmdEmp;
      ResetAdoError();
      return;
     }

   conn.Open();

// begin transaction
   COleDbTransaction *tran=conn.BeginTransaction();

// specify that our commands will execute in transaction 'tran'
   cmdEmp.Transaction(tran);
   cmdProf.Transaction(tran);

// execute first command 
   cmdProf.ExecuteNonQuery();

   if(CheckAdoError())
     {
      if(conn.State()==CONSTATE_OPEN) // if the connection is still opened
        {
         // rollback the transaction
         tran.Rollback();
         conn.Close();
        }

      delete conn;
      delete cmdProf;
      delete cmdEmp;
      delete tran;
      ResetAdoError();
      return;
     }

// execute second command
   cmdEmp.ExecuteNonQuery();

   if(CheckAdoError())
     {
      if(conn.State()==CONSTATE_OPEN)
        {
         // rollback the trasaction
         tran.Rollback();
         conn.Close();
        }

      delete conn;
      delete cmdProf;
      delete cmdEmp;
      delete tran;
      ResetAdoError();
      return;
     }

// commit transaction
   tran.Commit();

   conn.Close();

   delete conn;
   delete cmdProf;
   delete cmdEmp;
   delete tran;
  }
//+------------------------------------------------------------------+
