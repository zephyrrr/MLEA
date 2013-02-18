//+------------------------------------------------------------------+
//|                                                  CNamedPipes.mqh |
//|                                      Copyright 2010, Investeo.pl |
//|                                                http:/Investeo.pl |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, Investeo.pl"
#property link      "http:/Investeo.pl"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+

enum ENUM_PIPE_ACCESS
  {
   PIPE_ACCESS_INBOUND=1,
   PIPE_ACCESS_OUTBOUND=2,
   PIPE_ACCESS_DUPLEX=3,
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_PIPE_MODE
  {
   PIPE_TYPE_RW_BYTE=0,
   PIPE_TYPE_READ_MESSAGE=2,
   PIPE_TYPE_WRITE_MESSAGE=4,
  };

#define PIPE_WAIT 0
#define PIPE_NOWAIT 1

#define ERROR_PIPE_CONNECTED 535
#define ERROR_BROKEN_PIPE 109

#define INVALID_HANDLE_VALUE -1
#define GENERIC_READ  0x80000000
#define GENERIC_WRITE  0x40000000
#define OPEN_EXISTING  3
#define PIPE_UNLIMITED_INSTANCES 255
#define MQLTICK_SIZE 40
#define PIPE_BUFFER_SIZE 4096
#define STR_SIZE 255

//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
#import "kernel32.dll"
int CreateNamedPipeW(string pipeName,int openMode,int pipeMode,int maxInstances,int outBufferSize,int inBufferSize,int defaultTimeOut,int security);
int WaitNamedPipeW(string lpNamedPipeName,int nTimeOut);
bool ConnectNamedPipe(int pipeHandle,int overlapped);
bool DisconnectNamedPipe(int pipeHandle);
int CreateFileW(string name,int desiredAccess,int SharedMode,int security,int creation,int flags,int templateFile);
int WriteFile(int fileHandle,short &buffer[],int bytes,int &numOfBytes,int overlapped);
int WriteFile(int fileHandle,char &buffer[],int bytes,int &numOfBytes,int overlapped);
int WriteFile(int fileHandle,MqlTick &outgoing,int bytes,int &numOfBytes,int overlapped);
int WriteFile(int fileHandle,int &var,int bytes,int &numOfBytes,int overlapped);
int ReadFile(int fileHandle,short &buffer[],int bytes,int &numOfBytes,int overlapped);
int ReadFile(int fileHandle,char &buffer[],int bytes,int &numOfBytes,int overlapped);
int ReadFile(int fileHandle,MqlTick &incoming,int bytes,int &numOfBytes,int overlapped);
int ReadFile(int fileHandle,int &incoming,int bytes,int &numOfBytes,int overlapped);
int CloseHandle(int fileHandle);
int GetLastError(void);
int FlushFileBuffers(int pipeHandle);
#import
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CNamedPipe
  {
private:
   int               hPipe; // pipe handle
   string            pipeNumber;
   string            pipeNamePrefix;
   int               BufferSize;

protected:

public:
                     CNamedPipe();
                    ~CNamedPipe();

   bool              Create(int account);
   bool              Connect();
   bool              Disconnect();
   bool              Open(int account);
   int               Close();
   void              Flush();
   int               WriteUnicode(string message);
   string            ReadUnicode();
   int               WriteANSI(string message);
   string            ReadANSI();
   bool              ReadTick();
   bool              WriteTick(MqlTick &outgoing);
   string            GetPipeName();

   MqlTick           incoming;
  };
//+------------------------------------------------------------------+
//| CNamedPipe constructor
//+------------------------------------------------------------------+
CNamedPipe::CNamedPipe(void)
  {
   pipeNamePrefix="\\\\.\\pipe\\mt";
   BufferSize=PIPE_BUFFER_SIZE;
   hPipe=INVALID_HANDLE_VALUE;
   int err=kernel32::GetLastError();
  }
//+------------------------------------------------------------------+
//| CNamedPipe destructor
//+------------------------------------------------------------------+
CNamedPipe::~CNamedPipe(void)
  {
   if(hPipe!=INVALID_HANDLE_VALUE)
      CloseHandle(hPipe);

  }
//+------------------------------------------------------------------+
/// Create() : try to create a new instance of Named Pipe
/// \param account - source terminal account number  
/// \return true - if created, false otherwise
//+------------------------------------------------------------------+
bool CNamedPipe::Create(int account=0)
  {
   if(account==0)
      pipeNumber=IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
   else
      pipeNumber=IntegerToString(account);

   string fullPipeName=pipeNamePrefix+pipeNumber;

   hPipe=CreateNamedPipeW(fullPipeName,
                          (int)GENERIC_READ|GENERIC_WRITE|(ENUM_PIPE_ACCESS)PIPE_ACCESS_DUPLEX,
                          (ENUM_PIPE_MODE)PIPE_TYPE_RW_BYTE,PIPE_UNLIMITED_INSTANCES,
                          BufferSize*sizeof(ushort),BufferSize*sizeof(ushort),0,NULL);

   if(hPipe==INVALID_HANDLE_VALUE) return false;
   else
      return true;

  }
//+------------------------------------------------------------------+
/// Connect() : wait for a client to connect to a pipe               
/// \return true - if connected, false otherwise.
//+------------------------------------------------------------------+
bool CNamedPipe::Connect(void)
  {
   if(ConnectNamedPipe(hPipe,NULL)==false)
      return(kernel32::GetLastError()==ERROR_PIPE_CONNECTED);
   else return true;
  }
//+------------------------------------------------------------------+
/// Disconnect(): disconnect from a pipe
/// \return true - if disconnected, false otherwise    
//+------------------------------------------------------------------+
bool CNamedPipe::Disconnect(void)
  {
   return DisconnectNamedPipe(hPipe);
  }
//+------------------------------------------------------------------+
/// Open() : try to open previously created pipe
/// \param account - source terminal account number
/// \return true - if successfull, false otherwise
//+------------------------------------------------------------------+
bool CNamedPipe::Open(int account=0)
  {
   if(account==0)
      pipeNumber=IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
   else
      pipeNumber=IntegerToString(account);

   string fullPipeName=pipeNamePrefix+pipeNumber;

   if(hPipe==INVALID_HANDLE_VALUE)
     {
      if(WaitNamedPipeW(fullPipeName,5000)==0)
        {
         Print("Pipe "+fullPipeName+" busy.");
         return false;
        }

      hPipe=CreateFileW(fullPipeName,(int)GENERIC_READ|GENERIC_WRITE,0,NULL,OPEN_EXISTING,0,NULL);
      if(hPipe==INVALID_HANDLE_VALUE)
        {
         Print("Pipe open failed");
         return false;
        }

     }
   return true;
  }
//+------------------------------------------------------------------+
/// Close() : close pipe handle
/// \return 0 if successfull, non-zero otherwise  
//+------------------------------------------------------------------+
int CNamedPipe::Close(void)
  {
   return CloseHandle(hPipe);
  }
  
//+------------------------------------------------------------------+
/// WriteUnicode() : write unicode string to a pipe
/// \param message - string to send
/// \return number of bytes written to a pipe                                                                  |
//+------------------------------------------------------------------+
int CNamedPipe::WriteUnicode(string message)
  {
   int ushortsToWrite, bytesWritten;
   ushort UNICODEarray[];
   ushortsToWrite = StringToShortArray(message, UNICODEarray);
   WriteFile(hPipe,ushortsToWrite,sizeof(int),bytesWritten,0);
   WriteFile(hPipe,UNICODEarray,ushortsToWrite*sizeof(ushort),bytesWritten,0);
   return bytesWritten;
  }
//+------------------------------------------------------------------+
/// ReadUnicode(): read unicode string from a pipe
/// \return unicode string (MQL5 string)
//+------------------------------------------------------------------+
string CNamedPipe::ReadUnicode(void)
  {
   string ret;
   ushort UNICODEarray[STR_SIZE*sizeof(uint)];
   int bytesRead, ushortsToRead;
 
   ReadFile(hPipe,ushortsToRead,sizeof(int),bytesRead,0);
   ReadFile(hPipe,UNICODEarray,ushortsToRead*sizeof(ushort),bytesRead,0);
   if(bytesRead!=0)
      ret = ShortArrayToString(UNICODEarray);
   
   return ret;
  }
//+------------------------------------------------------------------+
/// WriteANSI() : write ANSI string to a pipe
/// \param message - string to send
/// \return number of bytes written to a pipe                                                                  |
//+------------------------------------------------------------------+
int CNamedPipe::WriteANSI(string message)
  {
   int bytesToWrite, bytesWritten;
   uchar ANSIarray[];
   bytesToWrite = StringToCharArray(message, ANSIarray);
   WriteFile(hPipe,bytesToWrite,sizeof(int),bytesWritten,0);
   WriteFile(hPipe,ANSIarray,bytesToWrite,bytesWritten,0);
   return bytesWritten;
  }
//+------------------------------------------------------------------+
/// ReadANSI(): read ANSI string from a pipe
/// \return unicode string (MQL5 string)
//+------------------------------------------------------------------+
string CNamedPipe::ReadANSI(void)
  {
   string ret;
   uchar ANSIarray[STR_SIZE];
   int bytesRead, bytesToRead;
 
   ReadFile(hPipe,bytesToRead,sizeof(int),bytesRead,0);
   ReadFile(hPipe,ANSIarray,bytesToRead,bytesRead,0);
   if(bytesRead!=0)
      ret = CharArrayToString(ANSIarray);
   
   return ret;
  }
//+------------------------------------------------------------------+
/// WriteTick() : write MqlTick to a pipe
/// \param outgoing - MqlTick to send
/// \return true if tick was written correctly, false otherwise
//+------------------------------------------------------------------+
bool CNamedPipe::WriteTick(MqlTick &outgoing)
  {
   int bytesWritten;

   WriteFile(hPipe,outgoing,MQLTICK_SIZE,bytesWritten,0);

   return(bytesWritten==MQLTICK_SIZE);
  }
//+------------------------------------------------------------------+
/// ReadTick() : read MqlTick from a pipe
/// \return true if tick was read correctly, false otherwise
//+------------------------------------------------------------------+
bool CNamedPipe::ReadTick()
  {
   int bytesRead;

   ReadFile(hPipe,incoming,MQLTICK_SIZE,bytesRead,NULL);

   return(bytesRead==MQLTICK_SIZE);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
/// GetPipeName() : return pipe name
/// \return string containing pipe name
//+------------------------------------------------------------------+
string CNamedPipe::GetPipeName(void)
  {
   return pipeNumber;
  }
//+------------------------------------------------------------------+
/// Flush() : flush pipe buffer
//+------------------------------------------------------------------+
void CNamedPipe::Flush(void)
  {
   FlushFileBuffers(hPipe);
  }
//+------------------------------------------------------------------+
