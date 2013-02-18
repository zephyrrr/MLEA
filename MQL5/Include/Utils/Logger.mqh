//+------------------------------------------------------------------+
//|                                                      Clogger.mqh |
//|                                                             ProF |
//|                                                          http:// |
//+------------------------------------------------------------------+
#property copyright "ProF"
#property link      "http://"

// Cache max size (number of files)
#define MAX_CACHE_SIZE	 10000
// Max file size in megabytes
#define MAX_FILE_SIZEMB	10
//+------------------------------------------------------------------+
//|   Logger                                                         |
//+------------------------------------------------------------------+
class CLogger
  {
private:
   string            m_project, m_file;              // Name of project and log file
   string            logCache[MAX_CACHE_SIZE];  // Cache max size
   int               sizeCache;                 // Cache counter
   int               cacheTimeLimit;            // Caching time
   datetime          cacheTime;                 // Time of cache last flush into file
   int               handleFile;                // Handle of log file
   string            defCategory;               // Default category
   void              WriteLog(string log_msg);  // Writing message into log or file, and flushing cache
public:
   void              CLogger(void);
   void             ~CLogger(void);           // Destructor
   void              SetSetting(string project,string file_name,
                                string default_category="",int cache_time_limit=0);                // Settings
   void              Init();                    // Initialization, open file for writing
   void              DeInit();                  // Deinitialization, closing file
   void              Write(string msg,string category="");                                         // Generating message
   void              Write(string msg,string category,color colorOfMsg,string file="",int line=0); // Generating message
   void              Write(string msg,string category,uchar red,uchar green,uchar blue,
                           string file="",int line=0);                                             // Generating message
   void              Flush(void);               // Flushing cache into file

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLogger::CLogger(void)
  {
   cacheTimeLimit=0; cacheTime=0; sizeCache=0;
   //SetSetting("DefaultLog","default");        // Settings
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLogger::~CLogger(void)
  {
   DeInit();
  }
//+------------------------------------------------------------------+
//|  Settings                                                        |
//+------------------------------------------------------------------+
void CLogger::SetSetting(string project_name,string file_name,
                         string default_category="",int cache_time_limit=0)
  {
   m_project=project_name;            // Project name
   m_file=file_name;                  // File name

   cacheTimeLimit=cache_time_limit; // Caching time
   if(default_category=="")         // Setting default category
     {  defCategory="Comment";   }
   else
     {defCategory=default_category;}
   
   Init();
  }
//+------------------------------------------------------------------+
//|  Initialization                                                  |
//+------------------------------------------------------------------+
void CLogger::Init(void)
  {
   string path;
   MqlDateTime date;
   int i=0;
   TimeToStruct(TimeCurrent(),date);                           // Get current time

   StringConcatenate(path,"log\\log_",m_project,"\\log_",m_file,"_",
                     StringFormat("%04i%02i%02i", date.year,date.mon,date.day));             // Generate path and file name
   handleFile=FileOpen(path+".txt",FILE_WRITE|FILE_READ|
                       FILE_UNICODE|FILE_TXT|FILE_SHARE_READ|FILE_COMMON); // Open or create file
   while(FileSize(handleFile)>(MAX_FILE_SIZEMB*1000000))       // Check file size
     {
      // Open or create new log file
      i++;
      FileClose(handleFile);
      handleFile=FileOpen(path+"_"+IntegerToString(i)+".txt",
                          FILE_WRITE|FILE_READ|FILE_UNICODE|FILE_TXT|FILE_SHARE_READ|FILE_COMMON);
     }
   FileSeek(handleFile,0,SEEK_END);                            // Set pointer to the end of file
  }
//+------------------------------------------------------------------+
//|   Deinitialization                                               |
//+------------------------------------------------------------------+
void CLogger::DeInit(void)
  {
   if(handleFile!=INVALID_HANDLE)
     {
      Flush();
      FileClose(handleFile); // Close file
     }
  }
//+------------------------------------------------------------------+
//|   Write message into file of cache                               |
//+------------------------------------------------------------------+
void CLogger::WriteLog(string log_msg)
  {
   if(cacheTimeLimit!=0) // Check if cache is enabled
     {
      if((sizeCache<MAX_CACHE_SIZE-1 && TimeCurrent()-cacheTime<cacheTimeLimit)
         || sizeCache==0) // Check if cache time is out or if cache limit is reached
        {
         // Write message into cache
         logCache[sizeCache++]=log_msg;
        }
      else
        {
         // Write message into cache and flush cache into file
         logCache[sizeCache++]=log_msg;
         Flush();
        }

     }
   else
     {
      // Cache is disabled, immediately write into file
      FileWrite(handleFile,log_msg);
     }
   if(FileTell(handleFile)>(MAX_FILE_SIZEMB*1000000)) // Check current file size
     {
      // File size exceeds allowed limit, close current file and open new one
      DeInit();
      Init();
     }
  }
//+------------------------------------------------------------------+
//|   Generate message and write into log                            |
//+------------------------------------------------------------------+
void CLogger::Write(string msg,string category="")
  {
   string msg_log;
   if(category=="")                 // Check if passed category exists
     {   category=defCategory;   }  // Set default category

// Generate line and call method to write message
   StringConcatenate(msg_log,category,":|:",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),"    ",msg);
   WriteLog(msg_log);
  }
//+------------------------------------------------------------------+
//|    Generate message and write into log                           |
//+------------------------------------------------------------------+
void CLogger::Write(string msg,string category,color colorOfMsg,string file="",int line=0)
  {
   string msg_log;
   int red,green,blue;
   red=(colorOfMsg  &Red);             // Select red color from constant
   green=(colorOfMsg  &0x00FF00)>>8;   // Select green color from constant
   blue=(colorOfMsg  &Blue)>>16;       // Select blue color from constant
                                       // Check if file or line are passed, generate line and call method of writing message
   if(file!="" && line!=0)
     {
      StringConcatenate(msg_log,category,":|:",red,",",green,",",blue,
                        ":|:",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),"    ",
                        "file: ",file,"   line: ",line,"   ",msg);
     }
   else
     {
      StringConcatenate(msg_log,category,":|:",red,",",green,",",blue,
                        ":|:",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),"    ",msg);
     }
   WriteLog(msg_log);
  }
//+------------------------------------------------------------------+
//|    Generate message and write into log                           |
//+------------------------------------------------------------------+
void CLogger::Write(string msg,string category,uchar red,uchar green,uchar blue,string file="",int line=0)
  {
   string msg_log;

// Check if file or line are passed, generate line and call method of writing message
   if(file!="" && line!=0)
     {
      StringConcatenate(msg_log,category,":|:",red,",",green,",",blue,
                        ":|:",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),"    ",
                        "file: ",file,"   line: ",line,"   ",msg);
     }
   else
     {
      StringConcatenate(msg_log,category,":|:",red,",",green,",",blue,
                        ":|:",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),"    ",msg);
     }
   WriteLog(msg_log);
  }
//+------------------------------------------------------------------+
//|    Flush cache into file                                         |
//+------------------------------------------------------------------+
void CLogger::Flush(void)
  {
   for(int i=0;i<sizeCache;i++) // In loop write all messages into file
     {
      FileWrite(handleFile,logCache[i]);
     }
   sizeCache=0;                  // Reset cache counter
   cacheTime=TimeCurrent();      // Set time of reseting cache
  }
//+------------------------------------------------------------------+
