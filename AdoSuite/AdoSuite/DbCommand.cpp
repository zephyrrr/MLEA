#include "stdafx.h"
#include "MqlDateTime.h"
#include "AdoHelper.h"

using namespace System;
using namespace System::Runtime::InteropServices;
using namespace System::Data;

// ---------------------------------------------------------------
_DLLAPI long long __stdcall GetDbCommandParameterList(const long long hCommand,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hCommand <= 0
		|| exType == NULL 
		|| exMessage == NULL) return -1;

	try
	{
		GCHandle hCmd = GCHandle::FromIntPtr(IntPtr((HANDLE)hCommand));
		IDbCommand^ cmd = (IDbCommand^)hCmd.Target;
		GCHandle hList = GCHandle::Alloc(cmd->Parameters);
		return (long long)GCHandle::ToIntPtr(hList).ToPointer(); 
	}
	catch (Exception^ ex)
	{
		IntPtr exT = Marshal::StringToHGlobalUni(ex->GetType()->Name);
		wcsncpy(exType, (const wchar_t*)exT.ToPointer(), 64);
		Marshal::FreeHGlobal(exT);

		IntPtr exM = Marshal::StringToHGlobalUni(ex->Message);
		wcsncpy(exMessage, (const wchar_t*)exM.ToPointer(), 256);
		Marshal::FreeHGlobal(exM);

		return 0;
	}
}


// ---------------------------------------------------------------
_DLLAPI void __stdcall SetDbCommandText(const long long hCommand,
										const wchar_t* value,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hCommand <= 0
		|| value == NULL 
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hCommand));
		IDbCommand^ cmd = (IDbCommand^)handle.Target;
		cmd->CommandText = gcnew String(value);
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
_DLLAPI wchar_t* __stdcall GetDbCommandText(const long long hCommand,
												wchar_t* exType, 
												wchar_t* exMessage)
{
	if (hCommand <= 0
		|| exType == NULL 
		|| exMessage == NULL) return NULL;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hCommand));
		IDbCommand^ cmd = (IDbCommand^)handle.Target;
		return (wchar_t*)Marshal::StringToHGlobalUni(cmd->CommandText).ToPointer();
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
_DLLAPI void __stdcall SetDbCommandTimeout(const long long hCommand,
										const int value,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hCommand <= 0
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hCommand));
		IDbCommand^ cmd = (IDbCommand^)handle.Target;
		cmd->CommandTimeout = value;
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
_DLLAPI int  __stdcall GetDbCommandTimeout(const long long hCommand,
												wchar_t* exType, 
												wchar_t* exMessage)
{
	if (hCommand <= 0
		|| exType == NULL 
		|| exMessage == NULL) return -1;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hCommand));
		IDbCommand^ cmd = (IDbCommand^)handle.Target;
		return cmd->CommandTimeout;
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
_DLLAPI void __stdcall SetDbCommandType(const long long hCommand,
										const int value,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hCommand <= 0
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hCommand));
		IDbCommand^ cmd = (IDbCommand^)handle.Target;
		cmd->CommandType = (CommandType)value;
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
_DLLAPI int  __stdcall GetDbCommandType(const long long hCommand,
												wchar_t* exType, 
												wchar_t* exMessage)
{
	if (hCommand <= 0
		|| exType == NULL 
		|| exMessage == NULL) return -1;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hCommand));
		IDbCommand^ cmd = (IDbCommand^)handle.Target;
		return (int)cmd->CommandType;
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
_DLLAPI void __stdcall SetDbCommandConnection(const long long hCommand,
										const long long hConnection,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hCommand <= 0
		|| hConnection <= 0
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle hCmd = GCHandle::FromIntPtr(IntPtr((HANDLE)hCommand));
		IDbCommand^ cmd = (IDbCommand^)hCmd.Target;
		GCHandle hCon = GCHandle::FromIntPtr(IntPtr((HANDLE)hConnection));
		IDbConnection^ con = (IDbConnection^)hCon.Target;
		cmd->Connection = con;
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
_DLLAPI void __stdcall SetDbCommandTransaction(const long long hCommand,
										const long long hTransaction,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hCommand <= 0
		|| hTransaction <= 0
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle hCmd = GCHandle::FromIntPtr(IntPtr((HANDLE)hCommand));
		IDbCommand^ cmd = (IDbCommand^)hCmd.Target;
		GCHandle hTran = GCHandle::FromIntPtr(IntPtr((HANDLE)hTransaction));
		IDbTransaction^ tran = (IDbTransaction^)hTran.Target;
		cmd->Transaction = tran;
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
_DLLAPI void __stdcall DbCommandExecuteNonQuery(const long long hCommand,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hCommand <= 0
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle hCmd = GCHandle::FromIntPtr(IntPtr((HANDLE)hCommand));
		IDbCommand^ cmd = (IDbCommand^)hCmd.Target;
		cmd->ExecuteNonQuery();
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
_DLLAPI long long __stdcall DbCommandExecuteReader(const long long hCommand,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hCommand <= 0
		|| exType == NULL 
		|| exMessage == NULL) return -1;

	try
	{
		GCHandle hCmd = GCHandle::FromIntPtr(IntPtr((HANDLE)hCommand));
		IDbCommand^ cmd = (IDbCommand^)hCmd.Target;

		IDataReader^ reader = cmd->ExecuteReader();
		GCHandle hReader = GCHandle::Alloc(reader);
		return (long long)GCHandle::ToIntPtr(hReader).ToPointer(); 

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
// SCALAR 
// ---------------------------------------------------------------
_DLLAPI int __stdcall DbCommandExecuteScalar(const long long hCommand,
											long long* hObject,
											wchar_t* exType, 
											wchar_t* exMessage)
{
	if (hCommand <= 0
		|| exType == NULL 
		|| exMessage == NULL) return -1;

	try
	{
		GCHandle hCmd = GCHandle::FromIntPtr(IntPtr((HANDLE)hCommand));
		IDbCommand^ cmd = (IDbCommand^)hCmd.Target;
		
		Object^ obj = cmd->ExecuteScalar();

		GCHandle hObj = GCHandle::Alloc(obj);
		*hObject = (long long)GCHandle::ToIntPtr(hObj).ToPointer(); 

		return AdoHelper::GetAdoType(obj);
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
_DLLAPI bool __stdcall DbCommandScalarGetBool(long long hObject,
											wchar_t* exType, 
											wchar_t* exMessage)
{
	if (hObject <= 0
		|| exType == NULL 
		|| exMessage == NULL) return false;

	try
	{
		GCHandle hObj = GCHandle::FromIntPtr(IntPtr((HANDLE)hObject));
		Object^ obj = (Object^)hObj.Target;
		bool value = Convert::ToBoolean(obj);
		hObj.Free();
		return value;
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
_DLLAPI long long __stdcall DbCommandScalarGetLong(long long hObject,
											wchar_t* exType, 
											wchar_t* exMessage)
{
	if (hObject <= 0
		|| exType == NULL 
		|| exMessage == NULL) return -1;

	try
	{
		GCHandle hObj = GCHandle::FromIntPtr(IntPtr((HANDLE)hObject));
		Object^ obj = (Object^)hObj.Target;
		long long value = Convert::ToInt64(obj);
		hObj.Free();
		return value;
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
_DLLAPI double __stdcall DbCommandScalarGetDouble(long long hObject,
											wchar_t* exType, 
											wchar_t* exMessage)
{
	if (hObject <= 0
		|| exType == NULL 
		|| exMessage == NULL) return -1;

	try
	{
		GCHandle hObj = GCHandle::FromIntPtr(IntPtr((HANDLE)hObject));
		Object^ obj = (Object^)hObj.Target;
		double value = Convert::ToDouble(obj);
		hObj.Free();
		return value;
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
_DLLAPI wchar_t* __stdcall DbCommandScalarGetString(long long hObject,
											wchar_t* exType, 
											wchar_t* exMessage)
{
	if (hObject <= 0
		|| exType == NULL 
		|| exMessage == NULL) return NULL;

	try
	{
		GCHandle hObj = GCHandle::FromIntPtr(IntPtr((HANDLE)hObject));
		Object^ obj = (Object^)hObj.Target;
		String^ value = Convert::ToString(obj);
		hObj.Free();
		return (wchar_t*)Marshal::StringToHGlobalUni(value).ToPointer();
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
_DLLAPI void __stdcall DbCommandScalarGetDatetime(long long hObject,
												HANDLE value,
												wchar_t* exType, 
												wchar_t* exMessage)
{
	if (hObject <= 0
		|| value == NULL
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle hObj = GCHandle::FromIntPtr(IntPtr((HANDLE)hObject));
		Object^ obj = (Object^)hObj.Target;
		DateTime time = Convert::ToDateTime(obj);
		hObj.Free();
		MqlDateTime mt = MqlDateTime::FromDateTime(time);
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

