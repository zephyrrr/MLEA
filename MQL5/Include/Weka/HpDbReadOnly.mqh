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
   int               tp_start_1,tp_delta_1,tp_count_1;
   int               sl_start_1,sl_delta_1,sl_count_1;
   int               tp_start_2,tp_delta_2,tp_count_2;
   int               sl_start_2,sl_delta_2,sl_count_2;
public:
                     CHpDb();
                    ~CHpDb();
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
   m_append="20_20_30.20_20_30";

   tp_start_1 = 20; tp_delta_1 = 20; tp_count_1 = 30;
   sl_start_1 = 20; sl_delta_1 = 20; sl_count_1 = 30;
   tp_start_2 = 20; tp_delta_2 = 20; tp_count_2 = 20;
   sl_start_2 = 20; sl_delta_2 = 20; sl_count_2 = 20;
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
   //Alert("It's ReadOnly HpDb");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              CHpDb::GetHp(datetime time,int &hp[],datetime  &hpTime[])
  {
   string fileName=GetFileName(time);
   CFileBin file;
   file.SetCommon(true);
   int ret=file.Open(fileName,FILE_READ);
   for(int i=0; i<ArraySize(hp);++i)
     {
      hp[i]=-1;
      hpTime[i]=0;
     }

   if(ret==INVALID_HANDLE)
     {
      Debug("No hp file of "+fileName);
      return;
     }

   char buffer[];
   ArrayResize(buffer,(int)file.Size());
   file.ReadCharArray(buffer);
   file.Close();

   if(ArraySize(hp)!=2 * tp_count_2*sl_count_2)
     {
      Error("Hp count is not equal to set size.");
      return;
     }

   for(int k=0; k<2;++k)
      for(int i=0; i<tp_count_2;++i)
         for(int j=0; j<sl_count_2;++j)
           {
            int tp2 = tp_start_2 + i * tp_delta_2;
            int sl2 = sl_start_2 + j * sl_delta_2;
            int i1 = (tp2 - tp_start_1) / tp_delta_1;
            int j1 = (sl2 - sl_start_1) / sl_delta_1;
            int idx1=k*tp_count_1*sl_count_1+
                     i1*sl_count_1+
                     j1;
            int idx2 = k*tp_count_2*sl_count_2+
                     i1*sl_count_2+
                     j1;
                     
            hp[idx2]=buffer[9*idx1];
            hpTime[idx2]= 0;
            for(int jj=0; jj<8;++jj)
              {
               hpTime[idx2]<<= 8;
               hpTime[idx2] ^= buffer[9 * idx1 + 1 + jj] & 0xFF;
              }
           }

   Debug("hp file of "+fileName+" is loaded ok.");
  }
//+------------------------------------------------------------------+
