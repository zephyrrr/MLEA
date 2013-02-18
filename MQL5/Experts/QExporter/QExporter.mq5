//+------------------------------------------------------------------+
//|                                                    QExporter.mq5 |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
#property copyright "GF1D, 2010"
#property link      "garf1eldhome@mail.ru"
#property version   "1.00"

#include "QService.mqh"
//--- input parameters
input string  ServerName = "mt5";

QService* service;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   service = new QService();
   service.Create(ServerName);
   return(0);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   service.Close();
   delete service;
   service = NULL;
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   MqlTick tick;
   SymbolInfoTick(Symbol(), tick);
   
   service.SendTick(Symbol(), tick);
}
//+------------------------------------------------------------------+
