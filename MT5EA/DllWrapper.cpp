// DllWrapper.cpp : 定义 DLL 应用程序的导出函数。
//

#include "stdafx.h"
#include "EAWrapperr.h"

using namespace System;

_DLLAPI void __stdcall HelloDllTest(const wchar_t* say)
{
	MessageBox(NULL, say, say, NULL);
}

_DLLAPI long long __stdcall Create()
{
	IntPtr hService = CEAWrapper::Create();
	
	return (long long)hService.ToPointer();
}

// ----------------------------------------- ----------------------
// 玎牮噱?皴疴桉
// ---------------------------------------------------------------
_DLLAPI void __stdcall Destroy(const long long hService)
{
	CEAWrapper::Destroy(IntPtr((HANDLE)hService));
}

_DLLAPI int __stdcall GetBestAction(const long long hService, const double* p)
{
	return CEAWrapper::GetBestAction(IntPtr((HANDLE)hService), p);
}

_DLLAPI void __stdcall HelloTest(const long long hService, const wchar_t* say)
{
	CEAWrapper::HelloTest(IntPtr((HANDLE)hService), gcnew String(say));
}

