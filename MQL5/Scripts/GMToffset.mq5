//+------------------------------------------------------------------+
//|  Auto GMT                                      ShowGMToffset.mq4 |
//|  Use_Broker_Time True/False;  then>> GMT -12 to +12              |  
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#import "kernel32.dll"
   void GetLocalTime(int& a0[]);
   int GetTimeZoneInformation(int& a0[]);
#import

extern string TimezoneString = " --- Timezone ---";
extern bool AutoGMTOffset = true;
extern int Manual_GMTOffset = 0;
extern double RandomOpenMinuteDelay = 5.0;
int GMToffset;
datetime LocalTime;

int OnStart() {

   if (TerminalInfoInteger(TERMINAL_DLLS_ALLOWED) == 0) {
      Alert("ShowGMT: DLLs are disabled.  To enable tick the checkbox in the Common Tab of indicator");
      return -1;
   }
 
   AutoGMTOffset();
   string display = "\n\n GMT: " + TimeToString(LocalTime, TIME_MINUTES); 
   if (GMToffset>0) 
    display = display + "\n Broker TimeZone GMT: +" + IntegerToString(GMToffset);
   else 
    display = display + "\n Broker TimeZone GMT: " + IntegerToString(GMToffset);
    
   int Myoffset = (int)((TimeLocal() - LocalTime) / 3600.0);
   if (Myoffset>0) 
    display = display + "\n Your TimeZone GMT: +" + IntegerToString(Myoffset);
   else 
    display = display + "\n Your TimeZone GMT: " + IntegerToString(Myoffset);
   Comment (display);

   return(0);
}

int AutoGMTOffset() {
   int Timezone[43];
      if (AutoGMTOffset == false) {
         GMToffset = Manual_GMTOffset;
         LocalTime = TimeCurrent() - 3600 * GMToffset;
      } else {
         int offset1 = 0;
         int offset2 = GetTimeZoneInformation(Timezone);
         if (offset2 == 1 || offset2 == 0) 
            offset1 = Timezone[0];
         if (offset2 == 2) 
            offset1 += Timezone[42];
            
         LocalTime = TimeLocal() + 60 * offset1;
         GMToffset = (int)MathRound((TimeCurrent() - LocalTime) / 3600.0);
         Print((int)(TimeCurrent() - LocalTime));
      }
   return (0);
}

//  if (Tradetime(19, 4) == 1) //when true,1 then trade time begins and checking for trades

//  if (Tradetime(18, 2) == 0) //when false,0 then trade time ends. Maybe close position(s)

int Tradetime(int StartTime, int StopTime) { //StartTime, StopTime
   bool Tradetime = false;
   MqlDateTime mqlDateTime;
   TimeToStruct(LocalTime, mqlDateTime);
   
   if (StartTime > StopTime) if (mqlDateTime.hour <= StopTime || mqlDateTime.hour >= StartTime) 
    Tradetime = true;
   if (StartTime < StopTime) if (mqlDateTime.hour >= StartTime && mqlDateTime.hour <= StopTime) 
    Tradetime = true;
   if (StartTime == StopTime && mqlDateTime.hour == StartTime) 
    Tradetime = true;
   if (mqlDateTime.day_of_week == 5 && mqlDateTime.hour > 6) 
    Tradetime = false;
   if (mqlDateTime.min < RandomOpenMinuteDelay) 
    Tradetime = false;
   if (mqlDateTime.day_of_week == 1 && mqlDateTime.hour < 2) 
    Tradetime = false;
   if (mqlDateTime.day_of_year < 7) 
    Tradetime = false;
   if (mqlDateTime.mon == 12 && mqlDateTime.day > 20) 
    Tradetime = false;
   return (Tradetime);
}


