// DllWrapper.cpp : 定义 DLL 应用程序的导出函数。
//

#include "stdafx.h"
#include "EAWrapperr.h"
#include < vcclr.h >

using namespace System;

// Remember to copy terminal.exe.config file
_DLLAPI void __stdcall HelloDllTest(const wchar_t* say)
{
	MessageBox(NULL, say, say, NULL);
}

_DLLAPI void __stdcall HelloServiceTest(const long long hService, const wchar_t* say)
{
	CEAWrapper::HelloServiceTest(IntPtr((HANDLE)hService), gcnew String(say));
}

_DLLAPI long long __stdcall CreateEAService(const wchar_t* symbol)
{
	IntPtr hService = CEAWrapper::Create(gcnew String(symbol));
	
	return (long long)hService.ToPointer();
}

_DLLAPI void __stdcall DestroyEAService(const long long hService)
{
	CEAWrapper::Destroy(IntPtr((HANDLE)hService));
}

//_DLLAPI void __stdcall Train(const long long hService, const long long nowTime, const int numInst, const int numAttr, const double* p, const int numHp, const int* r, const int numInst2, const double* p2, const int* r2)
//{
//	CEAWrapper::Train(IntPtr((HANDLE)hService), nowTime, numInst, numAttr, p, numHp, r, numInst2, p2, r2);
//}
//
//_DLLAPI int __stdcall Test(const long long hService, const long long nowTime, const int numAttr, const double* p)
//{
//	return CEAWrapper::Test(IntPtr((HANDLE)hService), nowTime, numAttr, p);
//}
//
//_DLLAPI void __stdcall Now(const long long hService, const long long nowTime, const double nowPrice)
//{
//	CEAWrapper::Now(IntPtr((HANDLE)hService), nowTime, nowPrice);
//}

_DLLAPI void __stdcall OnNewBar(const long long hService, const long long nowTime, const int barLength, const double* p, const int num)
{
	CEAWrapper::OnNewBar(IntPtr((HANDLE)hService), nowTime, barLength, p, num);
}

_DLLAPI void __stdcall RunTool(const long long hService, const wchar_t* toolName)
{
	CEAWrapper::RunTool(IntPtr((HANDLE)hService), gcnew String(toolName));
}

