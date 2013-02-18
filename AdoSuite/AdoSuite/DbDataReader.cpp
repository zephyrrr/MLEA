#include "stdafx.h"
#include "MqlDateTime.h"
#include "AdoHelper.h"

using namespace System;
using namespace System::Runtime::InteropServices;
using namespace System::Data;

// ---------------------------------------------------------------
_DLLAPI bool __stdcall DbDataReaderRead(const long long hReader,
											wchar_t* exType, 
											wchar_t* exMessage)
{
	if (hReader <= 0
		|| exType == NULL 
		|| exMessage == NULL) return false;

	try
	{
		GCHandle hRdr = GCHandle::FromIntPtr(IntPtr((HANDLE)hReader));
		IDataReader^ reader = (IDataReader^)hRdr.Target;
		return reader->Read();
	}
	catch (Exception^ ex)
	{
		IntPtr exT = Marshal::StringToHGlobalUni(ex->GetType()->Name);
		wcsncpy(exType, (const wchar_t*)exT.ToPointer(), 64);
		Marshal::FreeHGlobal(exT);

		IntPtr exM = Marshal::StringToHGlobalUni(ex->Message);
		wcsncpy(exMessage, (const wchar_t*)exM.ToPointer(), 256);
		Marshal::FreeHGlobal(exM);
	}
}

// ---------------------------------------------------------------
_DLLAPI bool __stdcall DbDataReaderIsClosed(const long long hReader,
											wchar_t* exType, 
											wchar_t* exMessage)
{
	if (hReader <= 0
		|| exType == NULL 
		|| exMessage == NULL) return false;

	try
	{
		GCHandle hRdr = GCHandle::FromIntPtr(IntPtr((HANDLE)hReader));
		IDataReader^ reader = (IDataReader^)hRdr.Target;
		return reader->IsClosed;
	}
	catch (Exception^ ex)
	{
		IntPtr exT = Marshal::StringToHGlobalUni(ex->GetType()->Name);
		wcsncpy(exType, (const wchar_t*)exT.ToPointer(), 64);
		Marshal::FreeHGlobal(exT);

		IntPtr exM = Marshal::StringToHGlobalUni(ex->Message);
		wcsncpy(exMessage, (const wchar_t*)exM.ToPointer(), 256);
		Marshal::FreeHGlobal(exM);
	}
}


// ---------------------------------------------------------------
_DLLAPI int __stdcall DbDataReaderGetFieldsCount(const long long hReader,
											wchar_t* exType, 
											wchar_t* exMessage)
{
	if (hReader <= 0
		|| exType == NULL 
		|| exMessage == NULL) return false;

	try
	{
		GCHandle hRdr = GCHandle::FromIntPtr(IntPtr((HANDLE)hReader));
		IDataReader^ reader = (IDataReader^)hRdr.Target;
		return reader->FieldCount;
	}
	catch (Exception^ ex)
	{
		IntPtr exT = Marshal::StringToHGlobalUni(ex->GetType()->Name);
		wcsncpy(exType, (const wchar_t*)exT.ToPointer(), 64);
		Marshal::FreeHGlobal(exT);

		IntPtr exM = Marshal::StringToHGlobalUni(ex->Message);
		wcsncpy(exMessage, (const wchar_t*)exM.ToPointer(), 256);
		Marshal::FreeHGlobal(exM);
	}
}

// ---------------------------------------------------------------
_DLLAPI void __stdcall DbDataReaderClose(const long long hReader,
											wchar_t* exType, 
											wchar_t* exMessage)
{
	if (hReader <= 0
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle hRdr = GCHandle::FromIntPtr(IntPtr((HANDLE)hReader));
		IDataReader^ reader = (IDataReader^)hRdr.Target;
		return reader->Close();
	}
	catch (Exception^ ex)
	{
		IntPtr exT = Marshal::StringToHGlobalUni(ex->GetType()->Name);
		wcsncpy(exType, (const wchar_t*)exT.ToPointer(), 64);
		Marshal::FreeHGlobal(exT);

		IntPtr exM = Marshal::StringToHGlobalUni(ex->Message);
		wcsncpy(exMessage, (const wchar_t*)exM.ToPointer(), 256);
		Marshal::FreeHGlobal(exM);
	}
}

// ---------------------------------------------------------------
_DLLAPI void __stdcall DbDataReaderColumnScheme(const long long hReader,
												const int index,
												wchar_t* columnName,
												int* columnType,
												wchar_t* exType, 
												wchar_t* exMessage)
{
	if (hReader <= 0
		|| columnName == NULL
		|| columnType == NULL
		|| exType == NULL
		|| exMessage == NULL) return;

	try
	{
		GCHandle hRdr = GCHandle::FromIntPtr(IntPtr((HANDLE)hReader));
		IDataReader^ reader = (IDataReader^)hRdr.Target;

		// column name
		IntPtr ptrName = Marshal::StringToHGlobalUni(reader->GetName(index));
		wcsncpy(columnName, (const wchar_t*)ptrName.ToPointer(), 32);
		Marshal::FreeHGlobal(ptrName);
			
		// column type
		*columnType = AdoHelper::GetAdoType(reader->GetFieldType(index));
	}
	catch (Exception^ ex)
	{
		IntPtr exT = Marshal::StringToHGlobalUni(ex->GetType()->Name);
		wcsncpy(exType, (const wchar_t*)exT.ToPointer(), 64);
		Marshal::FreeHGlobal(exT);

		IntPtr exM = Marshal::StringToHGlobalUni(ex->Message);
		wcsncpy(exMessage, (const wchar_t*)exM.ToPointer(), 256);
		Marshal::FreeHGlobal(exM);
	}
}

// ---------------------------------------------------------------
// GET VALUE 
// ---------------------------------------------------------------
_DLLAPI bool __stdcall DbReaderGetBool(long long hReader,
									   int fieldNum,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hReader <= 0
		|| exType == NULL 
		|| exMessage == NULL) return false;

	try
	{
		GCHandle hRdr = GCHandle::FromIntPtr(IntPtr((HANDLE)hReader));
		IDataReader^ reader = (IDataReader^)hRdr.Target;
		return (bool)Convert::ToBoolean(reader[fieldNum]);
	}
	catch (Exception^ ex)
	{
		IntPtr exT = Marshal::StringToHGlobalUni(ex->GetType()->Name);
		wcsncpy(exType, (const wchar_t*)exT.ToPointer(), 64);
		Marshal::FreeHGlobal(exT);

		IntPtr exM = Marshal::StringToHGlobalUni(ex->Message);
		wcsncpy(exMessage, (const wchar_t*)exM.ToPointer(), 256);
		Marshal::FreeHGlobal(exM);
	}
}

// ---------------------------------------------------------------
_DLLAPI long long __stdcall DbReaderGetLong(long long hReader,
									   int fieldNum,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hReader <= 0
		|| exType == NULL 
		|| exMessage == NULL) return -1;

	try
	{
		GCHandle hRdr = GCHandle::FromIntPtr(IntPtr((HANDLE)hReader));
		IDataReader^ reader = (IDataReader^)hRdr.Target;
		return (long long)Convert::ToInt64(reader[fieldNum]);
	}
	catch (Exception^ ex)
	{
		IntPtr exT = Marshal::StringToHGlobalUni(ex->GetType()->Name);
		wcsncpy(exType, (const wchar_t*)exT.ToPointer(), 64);
		Marshal::FreeHGlobal(exT);

		IntPtr exM = Marshal::StringToHGlobalUni(ex->Message);
		wcsncpy(exMessage, (const wchar_t*)exM.ToPointer(), 256);
		Marshal::FreeHGlobal(exM);
	}
}

// ---------------------------------------------------------------
_DLLAPI double __stdcall DbReaderGetDouble(long long hReader,
									   int fieldNum,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hReader <= 0
		|| exType == NULL 
		|| exMessage == NULL) return -1;

	try
	{
		GCHandle hRdr = GCHandle::FromIntPtr(IntPtr((HANDLE)hReader));
		IDataReader^ reader = (IDataReader^)hRdr.Target;
		return (double)Convert::ToDouble(reader[fieldNum]);
	}
	catch (Exception^ ex)
	{
		IntPtr exT = Marshal::StringToHGlobalUni(ex->GetType()->Name);
		wcsncpy(exType, (const wchar_t*)exT.ToPointer(), 64);
		Marshal::FreeHGlobal(exT);

		IntPtr exM = Marshal::StringToHGlobalUni(ex->Message);
		wcsncpy(exMessage, (const wchar_t*)exM.ToPointer(), 256);
		Marshal::FreeHGlobal(exM);
	}
}


// ---------------------------------------------------------------
_DLLAPI wchar_t* __stdcall DbReaderGetString(long long hReader,
									   int fieldNum,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hReader <= 0
		|| exType == NULL 
		|| exMessage == NULL) return NULL;

	try
	{
		GCHandle hRdr = GCHandle::FromIntPtr(IntPtr((HANDLE)hReader));
		IDataReader^ reader = (IDataReader^)hRdr.Target;
		return (wchar_t*)Marshal::StringToHGlobalUni(Convert::ToString(reader[fieldNum])).ToPointer();
	}
	catch (Exception^ ex)
	{
		IntPtr exT = Marshal::StringToHGlobalUni(ex->GetType()->Name);
		wcsncpy(exType, (const wchar_t*)exT.ToPointer(), 64);
		Marshal::FreeHGlobal(exT);

		IntPtr exM = Marshal::StringToHGlobalUni(ex->Message);
		wcsncpy(exMessage, (const wchar_t*)exM.ToPointer(), 256);
		Marshal::FreeHGlobal(exM);
	}
}

// ---------------------------------------------------------------
_DLLAPI void __stdcall DbReaderGetDateTime(long long hReader,
									   int fieldNum,
										HANDLE value,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hReader <= 0
		|| exType == NULL 
		|| value == NULL
		|| exMessage == NULL) return;

	try
	{
		GCHandle hRdr = GCHandle::FromIntPtr(IntPtr((HANDLE)hReader));
		IDataReader^ reader = (IDataReader^)hRdr.Target;

		MqlDateTime mt = MqlDateTime::FromDateTime(Convert::ToDateTime(reader[fieldNum]));
		Marshal::StructureToPtr(mt, IntPtr(value), false);
	}
	catch (Exception^ ex)
	{
		IntPtr exT = Marshal::StringToHGlobalUni(ex->GetType()->Name);
		wcsncpy(exType, (const wchar_t*)exT.ToPointer(), 64);
		Marshal::FreeHGlobal(exT);

		IntPtr exM = Marshal::StringToHGlobalUni(ex->Message);
		wcsncpy(exMessage, (const wchar_t*)exM.ToPointer(), 256);
		Marshal::FreeHGlobal(exM);
	}
}


