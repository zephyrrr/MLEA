//+------------------------------------------------------------------+
//|                                                         Time.mqh |
//|                            Copyright 2010, Vasily Sokolov (C-4). |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, Vasily Sokolov (C-4)."
#property link      "http://www.mql5.com"

#include <Arrays\List.mqh>

CList message_list;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMessage:CObject
  {
private:
   string            m_msg;
   datetime          m_time_set;
public:
   string         Message(){return(m_msg);}
   void           Message(string msg){m_msg=(string)msg;}
   datetime       TimeSet(){return(m_time_set);}
   void           TimeSet(datetime set_time){m_time_set=(datetime)set_time;}
  };

CMessage message;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct t_period
  {
   datetime          m1;
   datetime          m2;
   datetime          m3;
   datetime          m4;
   datetime          m5;
   datetime          m6;
   datetime          m10;
   datetime          m12;
   datetime          m15;
   datetime          m20;
   datetime          m30;
   datetime          h1;
   datetime          h2;
   datetime          h3;
   datetime          h4;
   datetime          h6;
   datetime          h8;
   datetime          h12;
   datetime          d1;
   datetime          w1;
   datetime          mn1;
   datetime          current;
  };
//t_period timeframes;

int GetPeriodEnumerator(uchar n_period)
  {
   switch(n_period)
     {
      case 0: return(PERIOD_CURRENT);
      case 1: return(PERIOD_M1);
      case 2: return(PERIOD_M2);
      case 3: return(PERIOD_M3);
      case 4: return(PERIOD_M4);
      case 5: return(PERIOD_M5);
      case 6: return(PERIOD_M6);
      case 7: return(PERIOD_M10);
      case 8: return(PERIOD_M12);
      case 9: return(PERIOD_M15);
      case 10: return(PERIOD_M20);
      case 11: return(PERIOD_M30);
      case 12: return(PERIOD_H1);
      case 13: return(PERIOD_H2);
      case 14: return(PERIOD_H3);
      case 15: return(PERIOD_H4);
      case 16: return(PERIOD_H6);
      case 17: return(PERIOD_H8);
      case 18: return(PERIOD_H12);
      case 19: return(PERIOD_D1);
      case 20: return(PERIOD_W1);
      case 21: return(PERIOD_MN1);
      default:
         Print("Enumerator period must be smallest 22");
         return(-1);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool timing(string symbol,ENUM_TIMEFRAMES tf,t_period &timeframes)
  {
   int rez;
   MqlRates raters[1];
   rez=CopyRates(symbol,tf,0,1,raters);
   if(rez==0)
     {
      Print("Error timing");
      return(false);
     }
   switch(tf)
     {
      case PERIOD_M1:
         if(raters[0].time==timeframes.m1)return(false);
         else{timeframes.m1=raters[0].time; return(true);}
      case PERIOD_M2:
         if(raters[0].time==timeframes.m2)return(false);
         else{timeframes.m2=raters[0].time; return(true);}
      case PERIOD_M3:
         if(raters[0].time==timeframes.m3)return(false);
         else{timeframes.m3=raters[0].time; return(true);}
      case PERIOD_M4:
         if(raters[0].time==timeframes.m4)return(false);
         else{timeframes.m4=raters[0].time; return(true);}
      case PERIOD_M5:
         if(raters[0].time==timeframes.m5)return(false);
         else{timeframes.m5=raters[0].time; return(true);}
      case PERIOD_M6:
         if(raters[0].time==timeframes.m6)return(false);
         else{timeframes.m6=raters[0].time; return(true);}
      case PERIOD_M10:
         if(raters[0].time==timeframes.m10)return(false);
         else{timeframes.m10=raters[0].time; return(true);}
      case PERIOD_M12:
         if(raters[0].time==timeframes.m12)return(false);
         else{timeframes.m12=raters[0].time; return(true);}
      case PERIOD_M15:
         if(raters[0].time==timeframes.m15)return(false);
         else{timeframes.m15=raters[0].time; return(true);}
      case PERIOD_M20:
         if(raters[0].time==timeframes.m20)return(false);
         else{timeframes.m20=raters[0].time; return(true);}
      case PERIOD_M30:
         if(raters[0].time==timeframes.m30)return(false);
         else{timeframes.m30=raters[0].time; return(true);}
      case PERIOD_H1:
         if(raters[0].time==timeframes.h1)return(false);
         else{timeframes.h1=raters[0].time; return(true);}
      case PERIOD_H2:
         if(raters[0].time==timeframes.h2)return(false);
         else{timeframes.h2=raters[0].time; return(true);}
      case PERIOD_H3:
         if(raters[0].time==timeframes.h3)return(false);
         else{timeframes.h3=raters[0].time; return(true);}
      case PERIOD_H4:
         if(raters[0].time==timeframes.h4)return(false);
         else{timeframes.h4=raters[0].time; return(true);}
      case PERIOD_H6:
         if(raters[0].time==timeframes.h6)return(false);
         else{timeframes.h6=raters[0].time; return(true);}
      case PERIOD_H8:
         if(raters[0].time==timeframes.h8)return(false);
         else{timeframes.h8=raters[0].time; return(true);}
      case PERIOD_H12:
         if(raters[0].time==timeframes.h12)return(false);
         else{timeframes.h12=raters[0].time; return(true);}
      case PERIOD_D1:
         if(raters[0].time==timeframes.d1)return(false);
         else{timeframes.d1=raters[0].time; return(true);}
      case PERIOD_W1:
         if(raters[0].time==timeframes.w1)return(false);
         else{timeframes.w1=raters[0].time; return(true);}
      case PERIOD_MN1:
         if(raters[0].time==timeframes.mn1)return(false);
         else{timeframes.mn1=raters[0].time; return(true);}
      case PERIOD_CURRENT:
         if(raters[0].time==timeframes.current)return(false);
         else{timeframes.current=raters[0].time; return(true);}
      default:
         return(false);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PrintTime(string msg,datetime delay)
  {
   string current_str;
   CMessage *current_msg;
   CMessage *new_message;
   for(int i=0;i<message_list.Total();i++)
     {
      current_msg=message_list.GetNodeAtIndex(i);
      if(CheckPointer(current_msg)==POINTER_INVALID)continue;
      if(StringFind(current_msg.Message(),msg)!=-1)
        {
         if(current_msg.TimeSet()+delay>=TimeCurrent())
           {
            Print(msg," ",current_msg.TimeSet());
            current_msg.TimeSet(TimeCurrent());
            return;
           }
         else return;
        }
     }
   Print(msg);
   new_message=new CMessage;
   new_message.Message(msg);
   new_message.TimeSet(TimeCurrent());
   message_list.Add(new_message);
  }
//+------------------------------------------------------------------+
