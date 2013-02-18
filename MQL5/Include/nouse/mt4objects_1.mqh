//+------------------------------------------------------------------+
//|                                                      common2.mqh |
//|                                      Copyright 2009, A. Williams |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, A. Williams"
#property link      "http://www.mql5.com"

//You must include the mt4timeseries.mqh in addition to this for a some of the functions below to work. 

#define EMPTY -1

bool ObjectCreate( string name, ENUM_OBJECT type, int window, datetime time1, double price1, datetime time2=0, double price2=0, datetime time3=0, double price3=0) 
{
   return(ObjectCreate(0, name, type, window, time1, price1, time2, price2,time3, price3));   
}
bool ObjectDelete( string name)
{
   return(ObjectDelete(0,name));
}
string ObjectDescription( string name)
{
   return(ObjectGetString(0,name,OBJPROP_TEXT));
}
int ObjectFind( string name)
{
   return(ObjectFind(0,name));
}
double ObjectGet( string name, ENUM_OBJECT_PROPERTY_INTEGER index)
{
   return(ObjectGetInteger(0,name, index));
}
string ObjectGetFiboDescription( string name, int index)
{
   return(ObjectGetString(0,name,OBJPROP_LEVELTEXT,index));
}
int ObjectGetShiftByValue( string name, double value)
{
   return(iBarShift(NULL,PERIOD_CURRENT,ObjectGetTimeByValue(0, name, value)));
}
double ObjectGetValueByShift( string name, int shift)
{
   return(ObjectGetValueByTime(0,name,iTime(NULL,PERIOD_CURRENT,shift),0));
}
bool ObjectMove( string name, int point, datetime time1, double price1)
{
   return(ObjectMove(0, name, point, time1, price1));
}
string ObjectName( int index)
{
   return(ObjectName(0,index));
}
int ObjectsDeleteAll(int window=EMPTY, int type=EMPTY)
{
   return(ObjectsDeleteAll(0, window, type));
}
bool ObjectSet( string name, ENUM_OBJECT_PROPERTY_INTEGER index, double value) 
{
   return(ObjectSetInteger(0, name, index, value));
}
bool ObjectSetFiboDescription(string name, int index, string text) 
{
   return(ObjectSetString(0,name,OBJPROP_LEVELTEXT,index,text));
}
bool ObjectSetText( string name, string text, int font_size, string font="", color text_color=CLR_NONE) 
{
   int tmpObjType=ObjectType(name);
   if(tmpObjType != OBJ_LABEL && tmpObjType != OBJ_TEXT) return(false);
   if(StringLen(text) > 0 && font_size > 0)
   {
      if(ObjectSetString(0,name,OBJPROP_TEXT,text)==true && ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size)==true)
      {
         if((StringLen(font)>0) && ObjectSetString(0,name,OBJPROP_FONT,font)==false) return(false);
         if(text_color > -1 && ObjectSetInteger(0,name,OBJPROP_COLOR,text_color)==false) return(false);
         return(true);
      }
      return(false);
   }
   return(false);
}
int ObjectsTotal(int type=EMPTY, int window=-1) 
{
   return(ObjectsTotal(0,window,type));
}
int ObjectType( string name) 
{
   return(ObjectGetInteger(0,name,OBJPROP_TYPE));
}
