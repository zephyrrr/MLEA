//+------------------------------------------------------------------+
//|                                                         File.mqh |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Object.mqh>
//+------------------------------------------------------------------+
//| Class CFile.                                                     |
//| Purpose: Base class of file operations.                          |
//|          Derives from class CObject.                             |
//+------------------------------------------------------------------+
class CFile : public CObject
  {
protected:
   int               m_handle;             // handle of file
   string            m_name;               // name of opened file
   int               m_flags;              // flags of opened file

public:
                     CFile(void);
                    ~CFile(void);
   //--- methods of access to protected data
   int               Handle(void)              const { return(m_handle); };
   string            FileName(void)            const { return(m_name);   };
   int               Flags(void)               const { return(m_flags);  };
   void              SetUnicode(const bool unicode);
   void              SetCommon(const bool common);
   //--- general methods for working with files
   int               Open(const string file_name,int open_flags,const short delimiter='\t');
   void              Close(void);
   void              Delete(void);
   ulong             Size(void)                                              const;
   ulong             Tell(void)                                              const;
   void              Seek(const long offset,const ENUM_FILE_POSITION origin) const;
   void              Flush(void)                                             const;
   bool              IsEnding(void)                                          const;
   bool              IsLineEnding(void)                                      const;
   //--- general methods for working with files
   void              Delete(const string file_name);
   bool              IsExist(const string file_name)                         const;
   bool              Copy(const string src_name,const int common_flag,const string dst_name,const int mode_flags) const;
   bool              Move(const string src_name,const int common_flag,const string dst_name,const int mode_flags) const;
   //--- general methods of working with folders
   bool              FolderCreate(const string folder_name) const;
   bool              FolderDelete(const string folder_name) const;
   bool              FolderClean(const string folder_name)  const;
   //--- general methods of finding files
   long              FileFindFirst(const string file_filter,string& returned_filename) const;
   bool              FileFindNext(const long search_handle,string& returned_filename)  const;
   void              FileFindClose(const long search_handle)                           const;
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CFile::CFile(void) : m_handle(INVALID_HANDLE),
                     m_name(""),
                     m_flags(FILE_ANSI)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CFile::~CFile(void)
  {
   if(m_handle!=INVALID_HANDLE) Close();
  }
//+------------------------------------------------------------------+
//| Set the FILE_UNICODE flag.                                       |
//+------------------------------------------------------------------+
void CFile::SetUnicode(const bool unicode)
  {
   if(m_handle==INVALID_HANDLE)
     {
      if(unicode) m_flags|=FILE_UNICODE;
      else        m_flags^=FILE_UNICODE;
     }
  }
//+------------------------------------------------------------------+
//| Set the "Common Folder" flag.                                    |
//+------------------------------------------------------------------+
void CFile::SetCommon(const bool common)
  {
   if(m_handle==INVALID_HANDLE)
     {
      if(common) m_flags|=FILE_COMMON;
      else       m_flags^=FILE_COMMON;
     }
  }
//+------------------------------------------------------------------+
//| Open file.                                                       |
//+------------------------------------------------------------------+
int CFile::Open(const string file_name,int open_flags,const short delimiter)
  {
//--- checking
   if(m_handle!=INVALID_HANDLE) Close();
//--- action
   if((open_flags&(FILE_BIN|FILE_CSV))==0) open_flags|=FILE_TXT;
   m_handle=FileOpen(file_name,open_flags|m_flags,delimiter);
   if(m_handle!=INVALID_HANDLE)
     {
      //--- store options of the opened file
      m_flags|=open_flags;
      m_name=file_name;
     }
//--- result
   return(m_handle);
  }
//+------------------------------------------------------------------+
//| Close file.                                                      |
//+------------------------------------------------------------------+
void CFile::Close(void)
  {
   if(m_handle!=INVALID_HANDLE)
     {
      //--- closing the file and resetting all the variables to the initial state
      FileClose(m_handle);
      m_handle=INVALID_HANDLE;
      m_name="";
      //--- reset all flags except the text
      m_flags&=FILE_ANSI|FILE_UNICODE;
     }
  }
//+------------------------------------------------------------------+
//| Deleting an open file.                                           |
//+------------------------------------------------------------------+
void CFile::Delete(void)
  {
   if(m_handle!=INVALID_HANDLE)
     {
      string file_name=m_name;
      Close();
      FileDelete(file_name,m_flags&FILE_COMMON);
     }
  }
//+------------------------------------------------------------------+
//| Get size of opened file.                                         |
//+------------------------------------------------------------------+
ulong CFile::Size(void) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileSize(m_handle));
//--- failure
   return(ULONG_MAX);
  }
//+------------------------------------------------------------------+
//| Get current position of pointer in file.                         |
//+------------------------------------------------------------------+
ulong CFile::Tell(void) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileTell(m_handle));
//--- failure
   return(ULONG_MAX);
  }
//+------------------------------------------------------------------+
//| Set position of pointer in file.                                 |
//+------------------------------------------------------------------+
void CFile::Seek(const long offset,const ENUM_FILE_POSITION origin) const
  {
   if(m_handle!=INVALID_HANDLE) FileSeek(m_handle,offset,origin);
  }
//+------------------------------------------------------------------+
//| Flush data from the file buffer of input-output to disk.         |
//+------------------------------------------------------------------+
void CFile::Flush(void) const
  {
   if(m_handle!=INVALID_HANDLE) FileFlush(m_handle);
  }
//+------------------------------------------------------------------+
//| Detect the end of file.                                          |
//+------------------------------------------------------------------+
bool CFile::IsEnding(void) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileIsEnding(m_handle));
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Detect the end of string.                                        |
//+------------------------------------------------------------------+
bool CFile::IsLineEnding(void) const
  {
//--- checking
   if(m_handle<0)            return(false);
   if((m_flags&FILE_BIN)!=0) return(false);
//--- action
   return(FileIsLineEnding(m_handle));
  }
//+------------------------------------------------------------------+
//| Deleting a file.                                                 |
//+------------------------------------------------------------------+
void CFile::Delete(const string file_name)
  {
//--- checking
   if(file_name==m_name) Close();
//--- action
   FileDelete(file_name,m_flags&FILE_COMMON);
  }
//+------------------------------------------------------------------+
//| Check if file exists.                                            |
//+------------------------------------------------------------------+
bool CFile::IsExist(const string file_name) const
  {
   return(FileIsExist(file_name,m_flags&FILE_COMMON));
  }
//+------------------------------------------------------------------+
//| Copying file.                                                    |
//+------------------------------------------------------------------+
bool CFile::Copy(const string src_name,const int common_flag,const string dst_name,const int mode_flags) const
  {
   return(FileCopy(src_name,common_flag,dst_name,mode_flags));
  }
//+------------------------------------------------------------------+
//| Move/rename file.                                                |
//+------------------------------------------------------------------+
bool CFile::Move(const string src_name,const int common_flag,const string dst_name,const int mode_flags) const
  {
   return(FileMove(src_name,common_flag,dst_name,mode_flags));
  }
//+------------------------------------------------------------------+
//| Create folder.                                                   |
//+------------------------------------------------------------------+
bool CFile::FolderCreate(const string folder_name) const
  {
   return(FolderCreate(folder_name,m_flags&FILE_COMMON));
  }
//+------------------------------------------------------------------+
//| Delete folder.                                                   |
//+------------------------------------------------------------------+
bool CFile::FolderDelete(const string folder_name) const
  {
   return(FolderDelete(folder_name,m_flags&FILE_COMMON));
  }
//+------------------------------------------------------------------+
//| Clean folder.                                                    |
//+------------------------------------------------------------------+
bool CFile::FolderClean(const string folder_name) const
  {
   return(FolderClean(folder_name,m_flags&FILE_COMMON));
  }
//+------------------------------------------------------------------+
//| Start search of files.                                           |
//+------------------------------------------------------------------+
long CFile::FileFindFirst(const string file_filter,string& returned_filename) const
  {
   return(FileFindFirst(file_filter,returned_filename,m_flags&FILE_COMMON));
  }
//+------------------------------------------------------------------+
//| Continue search of files.                                        |
//+------------------------------------------------------------------+
bool CFile::FileFindNext(const long search_handle,string& returned_filename) const
  {
   return(FileFindNext(search_handle,returned_filename));
  }
//+------------------------------------------------------------------+
//| End search of files.                                             |
//+------------------------------------------------------------------+
void CFile::FileFindClose(const long search_handle) const
  {
   FileFindClose(search_handle);
  }
//+------------------------------------------------------------------+
