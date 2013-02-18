#include "stdafx.h"
#include "GacHelper.h"

using namespace System;
using namespace System::Runtime::InteropServices;

// ---------------------------------------------------------------
_DLLAPI long long __stdcall CreateManagedObject(const wchar_t* asmName, 
												const wchar_t* typeName, 
												wchar_t* exType, 
												wchar_t* exMessage)
{
	if (asmName == NULL 
		|| typeName == NULL 
		|| exType == NULL 
		|| exMessage == NULL) return 0;

	try
	{	
		
		Object^ obj = Activator::CreateInstance(gcnew String(GetFullAssemblyName(asmName)), gcnew String(typeName))->Unwrap();
		GCHandle handle = GCHandle::Alloc(obj);
		return (long long)GCHandle::ToIntPtr(handle).ToPointer(); 
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
_DLLAPI void __stdcall DestroyManagedObject(long long hObject, 
											wchar_t* exType, 
											wchar_t* exMessage)
{
	if (hObject <= 0 
		|| exType == NULL 
		|| exMessage == NULL) return;

	try
	{
		GCHandle handle = GCHandle::FromIntPtr(IntPtr((HANDLE)hObject));
		handle.Free();
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
