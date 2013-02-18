#include "stdafx.h"

using namespace System;
using namespace System::Runtime::InteropServices;
using namespace System::Data;

// ---------------------------------------------------------------
_DLLAPI int __stdcall GetDbParameterListCount(const long long hList,
												wchar_t* exType, 
												wchar_t* exMessage)
{
	if (hList <= 0
		|| exType == NULL 
		|| exMessage == NULL) return -1;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hList));
		IDataParameterCollection^ list = (IDataParameterCollection^)handle.Target;
		return list->Count;
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
_DLLAPI void __stdcall DbParameterListAdd(const long long hList,
											const long long hParameter,
											wchar_t* exType, 
											wchar_t* exMessage)
{
	if (hList <= 0
		|| hParameter <= 0
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle handleList = GCHandle::FromIntPtr(IntPtr((HANDLE)hList));
		IDataParameterCollection^ list = (IDataParameterCollection^)handleList.Target;
		GCHandle handlePar = GCHandle::FromIntPtr(IntPtr((HANDLE)hParameter));
		IDbDataParameter^ par = (IDbDataParameter^)handlePar.Target;
		list->Add(par);
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
_DLLAPI void __stdcall DbParameterListRemove(const long long hList,
												const long long hParameter,
												wchar_t* exType, 
												wchar_t* exMessage)
{
	if (hList <= 0
		|| hParameter <= 0
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle handleList = GCHandle::FromIntPtr(IntPtr((HANDLE)hList));
		IDataParameterCollection^ list = (IDataParameterCollection^)handleList.Target;
		GCHandle handlePar = GCHandle::FromIntPtr(IntPtr((HANDLE)hParameter));
		IDbDataParameter^ par = (IDbDataParameter^)handlePar.Target;
		list->Remove(par);
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
