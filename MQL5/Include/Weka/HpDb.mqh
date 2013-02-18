//+------------------------------------------------------------------+
//|                                                         HpDb.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "Win32File.mqh"
#include <Utils\Utils.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHpDb
  {
private:
   string            m_baseDir;
   string            m_append;
   string            GetFileName(datetime time);
public:
                     CHpDb();
                    ~CHpDb();
   void              SetAppend(string append) { m_append=append; };
   void              GetHp(datetime time,int &hp[],datetime  &hpTime[]);
   void              PutHp(datetime time,int &hp[],datetime  &hpTime[]);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHpDb::CHpDb()
  {
   m_baseDir="E:\\Forex\\mtData";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHpDb::~CHpDb()
  {

  }
//+------------------------------------------------------------------+

string CHpDb::GetFileName(datetime time)
  {
   MqlDateTime date;
   TimeToStruct(time,date);
   string fileName=IntegerToString(date.year)+"\\"+
                   IntegerToString(date.mon)+"\\"+
                   IntegerToString(date.day)+"\\"+
                   IntegerToString(date.hour)+ "\\" +
                   IntegerToString(date.min) + "\\" +
                   m_append+".sim";
   return fileName;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void               CHpDb::PutHp(datetime time,int &hp[],datetime  &hpTime[])
  {
   string fileName=GetFileName(time);
   CWin32File file;
   file.OpenW(m_baseDir+"\\"+fileName);

   char buffer[];
   ArrayResize(buffer,ArraySize(hp)*9);
   for(int i=0; i<ArraySize(hp);++i)
     {
      buffer[9*i]=(char)hp[i];
      for(int j=0; j<8;++j)
        {
         buffer[9*i+1+7-j]=(char)(hpTime[i]>>(j*8));
        }
     }
   file.Write(buffer);
   file.Close();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              CHpDb::GetHp(datetime time,int &hp[],datetime  &hpTime[])
  {
   string fileName=GetFileName(time);
   CWin32File file;
   bool ret = file.OpenR(m_baseDir+"\\"+fileName);
   if (!ret)
   {
    for(int i=0; i<ArraySize(hp);++i)
        {
         hp[i]=-1;
         hpTime[i]=0;
        }
    return;
   }
   char buffer[];
   file.Read(buffer);
   file.Close();

   if(ArraySize(buffer)!=ArraySize(hp)*9)
     {
      for(int i=0; i<ArraySize(hp);++i)
        {
         hp[i]=-1;
         hpTime[i]=0;
        }
     }
   else
     {
      for(int i=0; i<ArraySize(hp);++i)
        {
         hp[i]=buffer[9*i];
         hpTime[i]= 0;
         for(int j=0; j<8;++j)
           {
            hpTime[i]<<= 8;
            hpTime[i] ^= buffer[9 * i + 1 + j] & 0xFF;
           }
        }
     }
  }
//+------------------------------------------------------------------+
