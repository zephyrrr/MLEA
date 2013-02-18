//+------------------------------------------------------------------+
//|                                                      QExport.mq5 |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
#property copyright "GF1D, 2010"
#property link      "garf1eldhome@mail.ru"
#property version   "1.00"

#include "QService.mqh"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   QService* serv = new QService();
   serv.Create("mt5");

   MqlTick tick;
   SymbolInfoTick("GBPUSD", tick);
 
   int total = 0;
   
   for(int c = 0; c < 10; c++)
   {
      int calls=0;
      
      int ticks=GetTickCount();

      while(GetTickCount()-ticks < 1000)
      {
         for(int i=0; i<100; i++) serv.SendTick("GBPUSD",tick);
         calls++;
      }
      
      Print(calls*100," calls per second");
      
      total += calls * 100;
   }
     
   Print("Average ", total/10," calls per second");

   serv.Close();
   delete serv;
}
//+------------------------------------------------------------------+
