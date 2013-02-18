#include "stdafx.h"
#include "MqlDateTime.h"
#include "AdoHelper.h"

using namespace System;
using namespace System::Runtime::InteropServices;
using namespace System::Data;

// ---------------------------------------------------------------
_DLLAPI void __stdcall SetDbParameterDirection(const long long hParameter,
												int direction,
												wchar_t* exType, 
												wchar_t* exMessage)
{
	if (hParameter <= 0
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hParameter));
		IDbDataParameter^ par = (IDbDataParameter^)handle.Target;
		par->Direction = (ParameterDirection)direction;
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
_DLLAPI int __stdcall GetDbParameterDirection(const long long hParameter,
												wchar_t* exType, 
												wchar_t* exMessage)
{
	if (hParameter <= 0
		|| exType == NULL 
		|| exMessage == NULL) return -1;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hParameter));
		IDbDataParameter^ par = (IDbDataParameter^)handle.Target;
		return (int)par->Direction;
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
_DLLAPI void __stdcall SetDbParameterName(const long long hParameter,
											 const wchar_t* name,
											wchar_t* exType, 
											wchar_t* exMessage)
{
	if (hParameter <= 0
		|| exType == NULL 
		|| name == NULL
		|| exMessage == NULL) return;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hParameter));
		IDbDataParameter^ par = (IDbDataParameter^)handle.Target;
		par->ParameterName = gcnew String(name);
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
_DLLAPI wchar_t* __stdcall GetDbParameterName(const long long hParameter,
											wchar_t* exType, 
											wchar_t* exMessage)
{
	if (hParameter <= 0
		|| exType == NULL 
		|| exMessage == NULL) return NULL;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hParameter));
		IDbDataParameter^ par = (IDbDataParameter^)handle.Target;
		return (wchar_t*)Marshal::StringToHGlobalUni(par->ParameterName).ToPointer();
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
_DLLAPI int __stdcall GetDbParameterType(const long long hParameter,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hParameter <= 0
		|| exType == NULL 
		|| exMessage == NULL) return -1;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hParameter));
		IDbDataParameter^ par = (IDbDataParameter^)handle.Target;
		return AdoHelper::GetAdoType(par->Value);
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
// BOOLEAN
// ---------------------------------------------------------------
_DLLAPI bool __stdcall GetDbParameterValueBool(const long long hParameter,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hParameter <= 0
		|| exType == NULL 
		|| exMessage == NULL) return false;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hParameter));
		IDbDataParameter^ par = (IDbDataParameter^)handle.Target;
		return (bool)par->Value;
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
_DLLAPI void __stdcall SetDbParameterValueBool(const long long hParameter,
												bool value,
												wchar_t* exType, 
												wchar_t* exMessage)
{
	if (hParameter <= 0
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hParameter));
		IDbDataParameter^ par = (IDbDataParameter^)handle.Target;
		par->Value = value;
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
// LONG
// ---------------------------------------------------------------
_DLLAPI long long __stdcall GetDbParameterValueLong(const long long hParameter,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hParameter <= 0
		|| exType == NULL 
		|| exMessage == NULL) return -1;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hParameter));
		IDbDataParameter^ par = (IDbDataParameter^)handle.Target;
		return (long long)par->Value;
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
_DLLAPI void __stdcall SetDbParameterValueLong(const long long hParameter,
												const long long value,
												wchar_t* exType, 
												wchar_t* exMessage)
{
	if (hParameter <= 0
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hParameter));
		IDbDataParameter^ par = (IDbDataParameter^)handle.Target;
		par->Value = value;
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
// DOUBLE
// ---------------------------------------------------------------
_DLLAPI double __stdcall GetDbParameterValueDouble(const long long hParameter,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hParameter <= 0
		|| exType == NULL 
		|| exMessage == NULL) return -1;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hParameter));
		IDbDataParameter^ par = (IDbDataParameter^)handle.Target;
		return (double)par->Value;
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
_DLLAPI void __stdcall SetDbParameterValueDouble(const long long hParameter,
												double value,
												wchar_t* exType, 
												wchar_t* exMessage)
{
	if (hParameter <= 0
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hParameter));
		IDbDataParameter^ par = (IDbDataParameter^)handle.Target;
		par->Value = value;
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
// STRING
// ---------------------------------------------------------------
_DLLAPI wchar_t* __stdcall GetDbParameterValueString(const long long hParameter,
										wchar_t* exType, 
										wchar_t* exMessage)
{
	if (hParameter <= 0
		|| exType == NULL 
		|| exMessage == NULL) return NULL;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hParameter));
		IDbDataParameter^ par = (IDbDataParameter^)handle.Target;
		return (wchar_t*)Marshal::StringToHGlobalUni((String^)par->Value).ToPointer();
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
_DLLAPI void __stdcall SetDbParameterValueString(const long long hParameter,
												wchar_t* value,
												wchar_t* exType, 
												wchar_t* exMessage)
{
	if (hParameter <= 0
		|| value == NULL
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hParameter));
		IDbDataParameter^ par = (IDbDataParameter^)handle.Target;
		par->Value = gcnew String(value);
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
// DATETIME
// ---------------------------------------------------------------
_DLLAPI void __stdcall GetDbParameterValueDateTime(const long long hParameter,
												HANDLE value,
												wchar_t* exType, 
												wchar_t* exMessage)
{
	if (hParameter <= 0
		|| exType == NULL 
		|| value == NULL
		|| exMessage == NULL) return;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hParameter));
		IDbDataParameter^ par = (IDbDataParameter^)handle.Target;

		MqlDateTime mt = MqlDateTime::FromDateTime((DateTime)par->Value);
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

// ---------------------------------------------------------------
_DLLAPI void __stdcall SetDbParameterValueDateTime(const long long hParameter,
												HANDLE value,
												wchar_t* exType, 
												wchar_t* exMessage)
{
	if (hParameter <= 0
		|| exType == NULL 
		|| value == NULL
		|| exMessage == NULL) return;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hParameter));
		IDbDataParameter^ par = (IDbDataParameter^)handle.Target;
		MqlDateTime m = (MqlDateTime)Marshal::PtrToStructure(IntPtr(value), MqlDateTime::typeid);
		par->Value = m.ToDateTime();
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

