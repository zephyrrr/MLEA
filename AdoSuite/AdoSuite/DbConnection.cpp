#include "stdafx.h"

using namespace System;
using namespace System::Runtime::InteropServices;
using namespace System::Data;
using namespace System::Data::Common;

// ---------------------------------------------------------------
_DLLAPI void __stdcall OpenDbConnection(long long hConnection,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hConnection <= 0
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hConnection));
		IDbConnection^ conn = (IDbConnection^)handle.Target;
		conn->Open();
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
_DLLAPI void __stdcall CloseDbConnection(long long hConnection,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hConnection <= 0
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hConnection));
		IDbConnection^ conn = (IDbConnection^)handle.Target;
		conn->Close();
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
_DLLAPI int _stdcall GetDbConnectionState(long long hConnection,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hConnection <= 0
		|| exType == NULL 
		|| exMessage == NULL) return -1;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hConnection));
		IDbConnection^ conn = (IDbConnection^)handle.Target;
		return (int)conn->State;
	}
	catch (Exception^ ex)
	{
		IntPtr exT = Marshal::StringToHGlobalUni(ex->GetType()->Name);
		wcsncpy(exType, (const wchar_t*)exT.ToPointer(), 64);
		Marshal::FreeHGlobal(exT);

		IntPtr exM = Marshal::StringToHGlobalUni(ex->Message);
		wcsncpy(exMessage, (const wchar_t*)exM.ToPointer(), 256);
		Marshal::FreeHGlobal(exM);

		return (int)ConnectionState::Broken;
	}
}

// ---------------------------------------------------------------
_DLLAPI void _stdcall SetDbConnectionString(const long long hConnection,
										const wchar_t* value,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hConnection <= 0
		|| value == NULL
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hConnection));
		IDbConnection^ conn = (IDbConnection^)handle.Target;
		conn->ConnectionString = gcnew String(value);
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
_DLLAPI wchar_t* _stdcall GetDbConnectionString(const long long hConnection,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hConnection <= 0
		|| exType == NULL 
		|| exMessage == NULL) return NULL;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hConnection));
		IDbConnection^ conn = (IDbConnection^)handle.Target;
		return (wchar_t*)Marshal::StringToHGlobalUni(conn->ConnectionString).ToPointer();
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
_DLLAPI int _stdcall GetDbConnectionTimeout(const long long hConnection,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hConnection <= 0
		|| exType == NULL 
		|| exMessage == NULL) return -1;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hConnection));
		IDbConnection^ conn = (IDbConnection^)handle.Target;
		return conn->ConnectionTimeout;
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
_DLLAPI long long __stdcall DbConnectionTransaction(long long hConnection,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hConnection <= 0
		|| exType == NULL 
		|| exMessage == NULL) return -1;

	try
	{
		GCHandle hConn = GCHandle::FromIntPtr(IntPtr((HANDLE)hConnection));
		IDbConnection^ conn = (IDbConnection^)hConn.Target;
		
		IDbTransaction^ tran = conn->BeginTransaction();
		GCHandle hTran = GCHandle::Alloc(tran);
		return (long long)GCHandle::ToIntPtr(hTran).ToPointer(); 
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
_DLLAPI long long __stdcall DbConnectionTransactionLevel(long long hConnection,
										int level,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hConnection <= 0
		|| exType == NULL 
		|| exMessage == NULL) return -1;

	try
	{
		GCHandle hConn = GCHandle::FromIntPtr(IntPtr((HANDLE)hConnection));
		IDbConnection^ conn = (IDbConnection^)hConn.Target;
		
		IDbTransaction^ tran = conn->BeginTransaction((IsolationLevel)level);
		GCHandle hTran = GCHandle::Alloc(tran);
		return (long long)GCHandle::ToIntPtr(hTran).ToPointer(); 
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


