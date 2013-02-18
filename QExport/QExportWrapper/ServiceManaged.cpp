#include "stdafx.h"

#include "ServiceManaged.h"

// ---------------------------------------------------------------
using namespace System;
using namespace System::Runtime::InteropServices;
using namespace System::Windows::Forms;
using namespace QExport;
using namespace QExport::Service;

// ---------------------------------------------------------------
IntPtr ServiceManaged::CreateExportService(String^ serverName)
{
	try
	{
		ExportService^ service = gcnew ExportService(serverName);
		service->Open();

		GCHandle handle = GCHandle::Alloc(service);
		return GCHandle::ToIntPtr(handle);
	}
	catch (Exception^ ex)
	{
		MessageBox::Show(ex->Message, "CreateExportService");
	}
}

// ---------------------------------------------------------------
void ServiceManaged::DestroyExportService(IntPtr hService)
{
	try
	{
		GCHandle handle = GCHandle::FromIntPtr(hService);

		ExportService^ service = (ExportService^)handle.Target;
		service->Close();

		handle.Free();
	}
	catch (Exception^ ex)
	{
		MessageBox::Show(ex->Message, "DestroyExportService");
	}
}

// ---------------------------------------------------------------
void ServiceManaged::SendTick(IntPtr hService, String^ symbol, IntPtr hTick)
{
	try
	{
		GCHandle handle = GCHandle::FromIntPtr(hService);
		ExportService^ service = (ExportService^)handle.Target;
	
		MqlTick tick = (MqlTick)Marshal::PtrToStructure(hTick, MqlTick::typeid);

		service->SendTick(symbol, tick);
	}
	catch (...)
	{
	}
}

// ---------------------------------------------------------------
void ServiceManaged::RegisterSymbol(IntPtr hService, String^ symbol)
{
	try
	{
		GCHandle handle = GCHandle::FromIntPtr(hService);
		ExportService^ service = (ExportService^)handle.Target;

		service->RegisterSymbol(symbol);
	}
	catch (Exception^ ex)
	{
		MessageBox::Show(ex->Message, "RegisterSymbol");
	}
}

// ---------------------------------------------------------------
void ServiceManaged::UnregisterSymbol(IntPtr hService, String^ symbol)
{
	try
	{
		GCHandle handle = GCHandle::FromIntPtr(hService);
		ExportService^ service = (ExportService^)handle.Target;

		service->UnregisterSymbol(symbol);
	}
	catch (Exception^ ex)
	{
		MessageBox::Show(ex->Message, "UnregisterSymbol");
	}
}
