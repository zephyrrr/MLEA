//+------------------------------------------------------------------+
//|                                                      FileBin.mqh |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "File.mqh"
//+------------------------------------------------------------------+
//| Class CFileBin.                                                  |
//| Purpose: Class of operations with binary files.                  |
//|          Derives from class CFile.                               |
//+------------------------------------------------------------------+
class CFileBin : public CFile
  {
public:
                     CFileBin(void);
                    ~CFileBin(void);
   //--- methods for working with files
   int               Open(const string file_name,const int open_flags);
   //--- methods for writing data
   uint              WriteChar(const char value)                    const;
   uint              WriteShort(const short value)                  const;
   uint              WriteInteger(const int value)                  const;
   uint              WriteLong(const long value)                    const;
   uint              WriteFloat(const float value)                  const;
   uint              WriteDouble(const double value)                const;
   uint              WriteString(const string value)                const;
   uint              WriteString(const string value,const int size) const;
   uint              WriteCharArray(const char& array[],const int start_item=0,const int items_count=-1)     const;
   uint              WriteShortArray(const short& array[],const int start_item=0,const int items_count=-1)   const;
   uint              WriteIntegerArray(const int& array[],const int start_item=0,const int items_count=-1)   const;
   uint              WriteLongArray(const long& array[],const int start_item=0,const int items_count=-1)     const;
   uint              WriteFloatArray(const float& array[],const int start_item=0,const int items_count=-1)   const;
   uint              WriteDoubleArray(const double& array[],const int start_item=0,const int items_count=-1) const;
   bool              WriteObject(CObject *object)                   const;
   //--- methods for reading data
   bool              ReadChar(char& value)                          const;
   bool              ReadShort(short& value)                        const;
   bool              ReadInteger(int& value)                        const;
   bool              ReadLong(long& value)                          const;
   bool              ReadFloat(float& value)                        const;
   bool              ReadDouble(double& value)                      const;
   bool              ReadString(string& value)                      const;
   bool              ReadString(string& value,const int size)       const;
   bool              ReadCharArray(char& array[],const int start_item=0,const int items_count=-1)            const;
   bool              ReadShortArray(short& array[],const int start_item=0,const int items_count=-1)          const;
   bool              ReadIntegerArray(int& array[],const int start_item=0,const int items_count=-1)          const;
   bool              ReadLongArray(long& array[],const int start_item=0,const int items_count=-1)            const;
   bool              ReadFloatArray(float& array[],const int start_item=0,const int items_count=-1)          const;
   bool              ReadDoubleArray(double& array[],const int start_item=0,const int items_count=-1)        const;
   bool              ReadObject(CObject *object)                    const;
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CFileBin::CFileBin(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CFileBin::~CFileBin(void)
  {
  }
//+------------------------------------------------------------------+
//| Opening a binary file.                                           |
//+------------------------------------------------------------------+
int CFileBin::Open(const string file_name,const int open_flags)
  {
   return(CFile::Open(file_name,open_flags|FILE_BIN));
  }
//+------------------------------------------------------------------+
//| Write a variable of char or uchar type.                          |
//+------------------------------------------------------------------+
uint CFileBin::WriteChar(const char value) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileWriteInteger(m_handle,value,sizeof(char)));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write a variable of short or ushort type.                        |
//+------------------------------------------------------------------+
uint CFileBin::WriteShort(const short value) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileWriteInteger(m_handle,value,sizeof(short)));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write a variable of int or uint type.                            |
//+------------------------------------------------------------------+
uint CFileBin::WriteInteger(const int value) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileWriteInteger(m_handle,value,sizeof(int)));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write a variable of long or ulong type.                          |
//+------------------------------------------------------------------+
uint CFileBin::WriteLong(const long value) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileWriteLong(m_handle,value));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write a variable of float type.                                  |
//+------------------------------------------------------------------+
uint CFileBin::WriteFloat(const float value) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileWriteFloat(m_handle,value));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write a variable of double type.                                 |
//+------------------------------------------------------------------+
uint CFileBin::WriteDouble(const double value) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileWriteDouble(m_handle,value));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write a variable of string type.                                 |
//+------------------------------------------------------------------+
uint CFileBin::WriteString(const string value) const
  {
//--- checking
   if(m_handle<0) return(0);
//---
   int size=StringLen(value);
   FileWriteInteger(m_handle,size);
//---
   return(FileWriteString(m_handle,value,size));
  }
//+------------------------------------------------------------------+
//| Write a part of string.                                          |
//+------------------------------------------------------------------+
uint CFileBin::WriteString(const string value,const int size) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileWriteString(m_handle,value,size));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write array variables of type char or uchar.                     |
//+------------------------------------------------------------------+
uint CFileBin::WriteCharArray(const char& array[],const int start_item,const int items_count) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileWriteArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write an array of variables of short or ushort type.             |
//+------------------------------------------------------------------+
uint CFileBin::WriteShortArray(const short& array[],const int start_item,const int items_count) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileWriteArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write an array of variables of int or uint type.                 |
//+------------------------------------------------------------------+
uint CFileBin::WriteIntegerArray(const int& array[],const int start_item,const int items_count) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileWriteArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write an array of variables of long or ulong type.               |
//+------------------------------------------------------------------+
uint CFileBin::WriteLongArray(const long& array[],const int start_item,const int items_count) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileWriteArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write an array of variables of float type.                       |
//+------------------------------------------------------------------+
uint CFileBin::WriteFloatArray(const float& array[],const int start_item,const int items_count) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileWriteArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write an array of variables of double type.                      |
//+------------------------------------------------------------------+
uint CFileBin::WriteDoubleArray(const double& array[],const int start_item,const int items_count) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileWriteArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write data of an instance of the CObject class.                  |
//+------------------------------------------------------------------+
bool CFileBin::WriteObject(CObject *object) const
  {
   if(CheckPointer(object)) return(object.Save(m_handle));
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read a variable of char or uchar type.                           |
//+------------------------------------------------------------------+
bool CFileBin::ReadChar(char& value) const
  {
   if(m_handle!=INVALID_HANDLE)
     {
      ResetLastError();
      value=(char)FileReadInteger(m_handle,sizeof(char));
      return(GetLastError()==0);
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read a variable of short or ushort type.                         |
//+------------------------------------------------------------------+
bool CFileBin::ReadShort(short& value) const
  {
   if(m_handle!=INVALID_HANDLE)
     {
      ResetLastError();
      value=(short)FileReadInteger(m_handle,sizeof(short));
      return(GetLastError()==0);
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read a variable of int or uint type.                             |
//+------------------------------------------------------------------+
bool CFileBin::ReadInteger(int& value) const
  {
   if(m_handle!=INVALID_HANDLE)
     {
      ResetLastError();
      value=FileReadInteger(m_handle,sizeof(int));
      return(GetLastError()==0);
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read a variable of long or ulong type.                           |
//+------------------------------------------------------------------+
bool CFileBin::ReadLong(long& value) const
  {
   if(m_handle!=INVALID_HANDLE)
     {
      ResetLastError();
      value=FileReadLong(m_handle);
      return(GetLastError()==0);
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read a variable of float type.                                   |
//+------------------------------------------------------------------+
bool CFileBin::ReadFloat(float& value) const
  {
   if(m_handle!=INVALID_HANDLE)
     {
      ResetLastError();
      value=FileReadFloat(m_handle);
      return(GetLastError()==0);
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read a variable of double type.                                  |
//+------------------------------------------------------------------+
bool CFileBin::ReadDouble(double& value) const
  {
   if(m_handle!=INVALID_HANDLE)
     {
      ResetLastError();
      value=FileReadDouble(m_handle);
      return(GetLastError()==0);
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read an array of variables of string type.                       |
//+------------------------------------------------------------------+
bool CFileBin::ReadString(string& value) const
  {
   if(m_handle!=INVALID_HANDLE)
     {
      int size=FileReadInteger(m_handle);
      value=FileReadString(m_handle,size);
      return(size==StringLen(value));
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read a part of string.                                           |
//+------------------------------------------------------------------+
bool CFileBin::ReadString(string& value,const int size) const
  {
   if(m_handle!=INVALID_HANDLE)
     {
      value=FileReadString(m_handle,size);
      return(size==StringLen(value));
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read an array of variables of char or uchar type.                |
//+------------------------------------------------------------------+
bool CFileBin::ReadCharArray(char& array[],const int start_item,const int items_count) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileReadArray(m_handle,array,start_item,items_count)!=0);
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read an array of variables of short or ushort type.              |
//+------------------------------------------------------------------+
bool CFileBin::ReadShortArray(short& array[],const int start_item,const int items_count) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileReadArray(m_handle,array,start_item,items_count)!=0);
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read an array of variables of int or uint type.                  |
//+------------------------------------------------------------------+
bool CFileBin::ReadIntegerArray(int& array[],const int start_item,const int items_count) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileReadArray(m_handle,array,start_item,items_count)!=0);
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read an array of variables of long or ulong type.                |
//+------------------------------------------------------------------+
bool CFileBin::ReadLongArray(long& array[],const int start_item,const int items_count) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileReadArray(m_handle,array,start_item,items_count)!=0);
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read an array of variables of float type.                        |
//+------------------------------------------------------------------+
bool CFileBin::ReadFloatArray(float& array[],const int start_item,const int items_count) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileReadArray(m_handle,array,start_item,items_count)!=0);
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read an array of variables of double type.                       |
//+------------------------------------------------------------------+
bool CFileBin::ReadDoubleArray(double& array[],const int start_item,const int items_count) const
  {
   if(m_handle!=INVALID_HANDLE) return(FileReadArray(m_handle,array,start_item,items_count)!=0);
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read data of an instance of the CObject class.                   |
//+------------------------------------------------------------------+
bool CFileBin::ReadObject(CObject *object) const
  {
   if(CheckPointer(object)) return(object.Load(m_handle));
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
