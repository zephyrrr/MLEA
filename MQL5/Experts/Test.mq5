//+------------------------------------------------------------------+
//|                                                         Test.mq5 |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#property version   "1.00"
#property tester_file "adotest.mdb"



  
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnStart()
  {
   
   Print("Start: ", TimeToString(TimeLocal(), TIME_SECONDS));
   
   float d = 0;
   float a = 2.45f;
   int d1 = 0;
   int a1 = 2;
   int j = 0;
   for(int i=0; i<50000000; ++i)
   {
   for(j=0; j<100; ++j)
    //d1 += a1 + a1;
    ;
   }
   Print("End: ", TimeToString(TimeLocal(), TIME_SECONDS));
   return 0;
  }
  
