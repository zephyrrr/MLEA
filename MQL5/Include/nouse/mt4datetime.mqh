//+------------------------------------------------------------------+
//|                                                      common4.mqh |
//|                                      Copyright 2009, A. Williams |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, A. Williams"
#property link      "http://www.mql5.com"

int Day()
{
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.day);
}
int DayOfWeek()
{
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.day_of_week);
}
int DayOfYear()
{
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.day_of_year);
}
int Hour()
{
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.hour);
}
int Minute()
{
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.min);
}
int Seconds()
{
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.sec);
}
int Year()
{
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.year);
}

int TimeDay(datetime date)
{
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day);
}
int TimeDayOfWeek(datetime date)
{
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day_of_week);
}
int TimeDayOfYear(datetime date)
{
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day_of_year);
}
int TimeHour(datetime date)
{
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.hour);
}
int TimeMinute(datetime date)
{
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.min);
}
int TimeMonth(datetime date)
{
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.mon);
}
int TimeSeconds(datetime date)
{
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.sec);
}
int TimeYear(datetime date)
{
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.year);
}
