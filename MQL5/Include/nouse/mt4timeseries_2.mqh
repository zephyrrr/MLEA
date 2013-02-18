//+------------------------------------------------------------------+
//|                                                       common.mqh |
//|                                      Copyright 2009, A. Williams |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, A. Williams"
#property link      "http://www.mql5.com"

#define MODE_OPEN 0
#define MODE_LOW 1
#define MODE_HIGH 2
#define MODE_CLOSE 3
#define MODE_VOLUME 4 
#define MODE_REAL_VOLUME 5

ENUM_TIMEFRAMES TFMigrate(int tf)
{
   switch(tf)
   {
      case 0: return(PERIOD_CURRENT);
      case 1: return(PERIOD_M1);
      case 5: return(PERIOD_M5);
      case 15: return(PERIOD_M15);
      case 30: return(PERIOD_M30);
      case 60: return(PERIOD_H1);
      case 240: return(PERIOD_H4);
      case 1440: return(PERIOD_D1);
      case 10080: return(PERIOD_W1);
      case 43200: return(PERIOD_MN1);
      
      case 2: return(PERIOD_M2);
      case 3: return(PERIOD_M3);
      case 4: return(PERIOD_M4);      
      case 6: return(PERIOD_M6);
      case 10: return(PERIOD_M10);
      case 12: return(PERIOD_M12);
      case 16385: return(PERIOD_H1);
      case 16386: return(PERIOD_H2);
      case 16387: return(PERIOD_H3);
      case 16388: return(PERIOD_H4);
      case 16390: return(PERIOD_H6);
      case 16392: return(PERIOD_H8);
      case 16396: return(PERIOD_H12);
      case 16408: return(PERIOD_D1);
      case 32769: return(PERIOD_W1);
      case 49153: return(PERIOD_MN1);      

      default: return(PERIOD_CURRENT);
   }
}

//mt4 compatible timeseries functions (it accepts timeframe as int or ENUM_TIMEFRAMES. in other words ,compatible with mt4 and mt5)
double iOpen(string symbol,int tf,int index)
{   
   if(index < 0) return(-1);
   double Arr[];
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   if(CopyOpen(symbol,timeframe, index, 1, Arr)>0) return(Arr[0]);
   else return(-1);
}
double iLow(string symbol,int tf,int index)
{
   if(index < 0) return(-1);
   double Arr[];
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   if(CopyLow(symbol,timeframe, index, 1, Arr)>0) return(Arr[0]);
   else return(-1);
}
double iHigh(string symbol,int tf,int index)
{
   if(index < 0) return(-1);
   double Arr[];
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   if(CopyHigh(symbol,timeframe, index, 1, Arr)>0) return(Arr[0]);
   else return(-1);
}
double iClose(string symbol,int tf,int index)
{
   if(index < 0) return(-1);
   double Arr[];
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   if(CopyClose(symbol,timeframe, index, 1, Arr)>0) return(Arr[0]);
   else return(-1);
}
datetime iTime(string symbol,int tf,int index)
{
   if(index < 0) return(-1);
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   datetime Arr[];
   if(CopyTime(symbol, timeframe, index, 1, Arr)>0) return(Arr[0]);
   else return(-1);
}
int iVolume(string symbol,int tf,int index)
{
   if(index < 0) return(-1);
   long Arr[];
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   if(CopyTickVolume(symbol, timeframe, index, 1, Arr)>0) return(Arr[0]);
   else return(-1);
}
long iVolumeReal(string symbol,int tf,int index)
{
   if(index < 0) return(-1);
   long Arr[];
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   if(CopyRealVolume(symbol, timeframe, index, 1, Arr)>0) return(Arr[0]);
   else return(-1);
}
int iHighest(string symbol, int tf, int type=MODE_HIGH, int count=WHOLE_ARRAY, int start=0)
{
   if(start <0) return(-1);
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);

   if(count==0) count=Bars(symbol,timeframe);
   
   if(type==MODE_HIGH)
   {
      double Arr[];
      if(CopyHigh(symbol,timeframe,start,count,Arr)>0)  return((count-ArrayMaximum(Arr)-1)+start);
      else return(-1);
   } 
   else if(type==MODE_LOW)
   {   
      double Arr[];
      if(CopyLow(symbol,timeframe,start,count,Arr)>0) return((count-ArrayMaximum(Arr)-1)+start);
      else return(-1);
   }
   else if(type==MODE_OPEN)
   {   
      double Arr[];
      if(CopyOpen(symbol,timeframe,start,count,Arr)>0) return((count-ArrayMaximum(Arr)-1)+start);
      else return(-1);
   }  
   else if(type==MODE_CLOSE)
   {
      double Arr[];
      if(CopyClose(symbol,timeframe,start,count,Arr)>0) return((count-ArrayMaximum(Arr)-1)+start);
      else return(-1);
   }      
   else if(type==MODE_VOLUME)
   {
      long Arr[];
      if(CopyTickVolume(symbol,timeframe,start,count,Arr)>0) return((count-ArrayMaximum(Arr)-1)+start);
      else return(-1);
   }      
   else if(type==MODE_REAL_VOLUME)
   {
      long Arr[];
      if(CopyRealVolume(symbol,timeframe,start,count,Arr)>0) return((count-ArrayMaximum(Arr)-1)+start);
      else return(-1);
   }            
   else return(-1);
}

int iLowest(string symbol, int tf, int type=MODE_LOW, int count=WHOLE_ARRAY, int start=0)
{
   if(start <0) return(-1);
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   
   if(count==0) count=Bars(symbol,timeframe);   
   
   if(type==MODE_LOW)
   {         
      double Arr[];
      if(CopyLow(symbol,timeframe,start,count,Arr)>0)  return((count-ArrayMinimum(Arr)-1)+start);
      else return(-1);
   }
   else if(type==MODE_HIGH)
   {
      double Arr[];
      if(CopyHigh(symbol,timeframe,start,count,Arr)>0) return((count-ArrayMinimum(Arr)-1)+start);
      else return(-1);
   }
   if(type==MODE_OPEN)
   {   
      double Arr[];
      if(CopyOpen(symbol,timeframe,start,count,Arr)>0) return((count-ArrayMinimum(Arr)-1)+start);
      else return(-1);
   }
   else if(type==MODE_CLOSE)
   {
      double Arr[];
      if(CopyClose(symbol,timeframe,start,count,Arr)>0) return((count-ArrayMinimum(Arr)-1)+start);
      else return(-1);
   }   
   else if(type==MODE_VOLUME)
   {
      long Arr[];
      if(CopyTickVolume(symbol,timeframe,start,count,Arr)>0) return((count-ArrayMinimum(Arr)-1)+start);
      else return(-1);
   }      
   else if(type==MODE_REAL_VOLUME)
   {
      long Arr[];
      if(CopyRealVolume(symbol,timeframe,start,count,Arr)>0) return((count-ArrayMinimum(Arr)-1)+start);
      else return(-1);
   }         
   else return(-1);
}

int iBarShift(string symbol, int tf, datetime time, bool exact=true)
{
   if(time<0) return(-1);
   //sorry, exact will always =true in this code of mines. no exact=false yet.
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   datetime Arr[];  
   if(CopyTime(symbol, timeframe,iTime(symbol,timeframe,0), time, Arr)>0) return(ArraySize(Arr)-1);
   else return(-1);
}

int iBars(string symbol, int tf)
{
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   return(Bars(symbol,timeframe));
}
