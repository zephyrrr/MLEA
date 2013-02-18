// QExportWrapper.cpp : Defines the exported functions for the DLL application.

#include "stdafx.h"
#include "ServiceManaged.h"
// ---------------------------------------------------------------
using namespace System;

// ---------------------------------------------------------------
// создае??открывае?сервис 
// ?возвращает указател?на него
// ---------------------------------------------------------------
_DLLAPI long long __stdcall CreateExportService(const wchar_t* serverName)
{
	IntPtr hService = ServiceManaged::CreateExportService(gcnew String(serverName));
	
	return (long long)hService.ToPointer(); 
}

// ----------------------------------------- ----------------------
// закрывае?сервис
// ---------------------------------------------------------------
_DLLAPI void __stdcall DestroyExportService(const long long hService)
{
	ServiceManaged::DestroyExportService(IntPtr((HANDLE)hService));
}

// ---------------------------------------------------------------
// Передает ти?
// ---------------------------------------------------------------
_DLLAPI void __stdcall SendTick(const long long hService, const wchar_t* symbol, const HANDLE hTick)
{
	ServiceManaged::SendTick(IntPtr((HANDLE)hService), gcnew String(symbol), IntPtr((HANDLE)hTick));
}

// ---------------------------------------------------------------
// Регистрирует экспортируемый символ
// ---------------------------------------------------------------
_DLLAPI void __stdcall RegisterSymbol(const long long hService, const wchar_t* symbol)
{
	ServiceManaged::RegisterSymbol(IntPtr((HANDLE)hService), gcnew String(symbol));
}

// ---------------------------------------------------------------
// Убирае?экспортируемый символ
// ---------------------------------------------------------------
_DLLAPI void __stdcall UnregisterSymbol(const long long hService, const wchar_t* symbol)
{
	ServiceManaged::UnregisterSymbol(IntPtr((HANDLE)hService), gcnew String(symbol));
}

