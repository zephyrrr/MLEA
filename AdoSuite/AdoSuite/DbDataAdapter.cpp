#include "stdafx.h"
#include "MqlDateTime.h"
#include "AdoHelper.h"

using namespace System;
using namespace System::Runtime::InteropServices;
using namespace System::Data;

// ---------------------------------------------------------------
_DLLAPI void __stdcall SetDbAdapterSelectCommand(const long long hAdapter,
										const long long hCommand,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	try
	{
		GCHandle hAdpt = GCHandle::FromIntPtr(IntPtr((HANDLE)hAdapter));
		IDbDataAdapter^ adapter = (IDbDataAdapter^)hAdpt.Target;
		GCHandle hCmd = GCHandle::FromIntPtr(IntPtr((HANDLE)hCommand));
		IDbCommand^ cmd = (IDbCommand^)hCmd.Target;
		adapter->SelectCommand = cmd;
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
_DLLAPI long long __stdcall DbAdapterFill(const long long hAdapter,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	try
	{
		GCHandle hAdpt = GCHandle::FromIntPtr(IntPtr((HANDLE)hAdapter));
		IDbDataAdapter^ adapter = (IDbDataAdapter^)hAdpt.Target;
		DataSet^ ds = gcnew DataSet();
		adapter->Fill(ds);
		DataTable^ dt = ds->Tables[0];
		GCHandle hTable = GCHandle::Alloc(dt);
		return (long long)GCHandle::ToIntPtr(hTable).ToPointer(); 
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
