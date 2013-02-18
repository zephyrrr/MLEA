//+------------------------------------------------------------------+
//|                                                         Test.mq5 |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Weka\WekaExpert.mqh>

#define BUFFERSIZE 81
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
  /*Print(TimeLocal());
  int k = 0;
  for(int i=0; i<2*30*30*24*80*60; ++i)
  for(int j=0; j<10; ++j)
    k++;
  Print(TimeLocal());
  return;*/
   //logger.SetSetting("WekaEA", "Test");   
   
   CWekaExpert* expert;
   //expert = new CWekaExpert("EURUSD");
   //expert.BuildHpData();
   //expert = new CWekaExpert("EURUSD");
   //expert.BuildHpData(D'2006.01.01 00:00', D'2012.01.01');

   //expert.PrintDebugInfo();
   //expert.Test();

   //expert.PrintDebugInfo();
    //expert.Predict();
    
    if (expert != NULL)
        delete expert;
  }
//+------------------------------------------------------------------+
