#include "stdafx.h"

using namespace System;
using namespace System::Runtime::InteropServices;
using namespace System::Data;

// ---------------------------------------------------------------
_DLLAPI void __stdcall CommitDbTransaction(const long long hTransaction,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hTransaction <= 0
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle hTran = GCHandle::FromIntPtr(IntPtr((HANDLE)hTransaction));
		IDbTransaction^ tran = (IDbTransaction^)hTran.Target;
		tran->Commit();
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
_DLLAPI void __stdcall RollbackDbTransaction(const long long hTransaction,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hTransaction <= 0
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle hTran = GCHandle::FromIntPtr(IntPtr((HANDLE)hTransaction));
		IDbTransaction^ tran = (IDbTransaction^)hTran.Target;
		tran->Rollback();
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

