//+------------------------------------------------------------------+
//|                                                         HpDb.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Utils\Utils.mqh>
#include <Files\FileBin.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHpDb
  {
private:
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
   string common_folder=TerminalInfoString(TERMINAL_COMMONDATA_PATH);
   PrintFormat("shared folder of the client terminals is %s",common_folder);
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
   string fileName="SimuResult\\"+IntegerToString(date.year)+"\\"+
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
   CFileBin file;
   file.SetCommon(true);
   int ret= file.Open(fileName,FILE_WRITE);
   if(ret == INVALID_HANDLE)
     {
      Error("Failded to open write "+fileName);
      ErrorCurrentError();
      return;
     }

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
   file.WriteCharArray(buffer);
   file.Close();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              CHpDb::GetHp(datetime time,int &hp[],datetime  &hpTime[])
  {
   string fileName=GetFileName(time);
   CFileBin file;
   file.SetCommon(true);
   int ret= file.Open(fileName,FILE_READ);
   if(ret == INVALID_HANDLE)
     {
      for(int i=0; i<ArraySize(hp);++i)
        {
         hp[i]=-1;
         hpTime[i]=0;
        }
      Debug("No hp file of "+fileName);
      return;
     }
   char buffer[];
   ArrayResize(buffer,(int)file.Size());
   file.ReadCharArray(buffer);
   file.Close();

   if(ArraySize(buffer)!=ArraySize(hp)*9)
     {
      Error("hp size is not equal. bufferSize=",IntegerToString(ArraySize(buffer)),
            ", should =",IntegerToString(ArraySize(hp)*9));
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

      Debug("hp file of "+fileName+" is loaded ok.");
     }
  }
//+------------------------------------------------------------------+
