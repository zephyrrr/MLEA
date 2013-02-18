#include "StdAfx.h"
#include "EAWrapperr.h"

using namespace System;
using namespace System::Runtime::InteropServices;
using namespace System::Windows::Forms;
using namespace WekaEA;

void CEAWrapper::HelloServiceTest(IntPtr hService, String^ say)
{
	MessageBox::Show(say, "Hello " + say);
}

IntPtr CEAWrapper::Create(String^ symbol)
{
	try
	{
		WekaEA2^ service = gcnew WekaEA2;
		service->Init(symbol);
		GCHandle handle = GCHandle::Alloc(service);
		return GCHandle::ToIntPtr(handle);
	}
	catch (Exception^ ex)
	{
		MessageBox::Show(ex->Message, "CEAWrapper::Create");
		return IntPtr::Zero;
	}
}

// ---------------------------------------------------------------
void CEAWrapper::Destroy(IntPtr hService)
{
	try
	{
		GCHandle handle = GCHandle::FromIntPtr(hService);

		WekaEA2^ service = (WekaEA2^)handle.Target;
		service->Deinit();

		handle.Free();
	}
	catch (Exception^ ex)
	{
		MessageBox::Show(ex->Message, "CEAWrapper::Destroy");
	}
}

//void CEAWrapper::Train(IntPtr hService, const long long nowTime, const int numInst, const int numAttr, const double* p, const int numHp, const int* r, const int numInst2, const double* p2, const int* r2)
//{
//	try
//	{
//		GCHandle handle = GCHandle::FromIntPtr(hService);
//		WekaEA1^ service = (WekaEA1^)handle.Target;
//
//		array<double>^ pp = gcnew array<double>(numInst * numAttr);
//		for (int i = 0; i < numInst * numAttr; i++)
//		{
//			pp[i] = p[i];
//		}
//		array<int>^ pr = gcnew array<int>(numInst * numHp);
//		for (int i = 0; i < numInst * numHp; i++)
//		{
//			pr[i] = r[i];
//		}
//
//		array<double>^ pp2 = gcnew array<double>(numInst2 * numAttr);
//		for (int i = 0; i < numInst2 * numAttr; i++)
//		{
//			pp2[i] = p2[i];
//		}
//		array<int>^ pr2 = gcnew array<int>(numInst2 * numHp);
//		for (int i = 0; i < numInst2 * numHp; i++)
//		{
//			pr2[i] = r2[i];
//		}
//
//		service->Train(nowTime, pp, pr, pp2, pr2);
//
//		return;
//	}
//	catch (Exception^ ex)
//	{
//		MessageBox::Show(ex->Message, "CEAWrapper::Train");
//		MessageBox::Show(ex->StackTrace, "CEAWrapper::Train");
//	}
//}
//
//int CEAWrapper::Test(IntPtr hService, const long long nowTime, const int numAttr, const double* p)
//{
//	try
//	{
//		GCHandle handle = GCHandle::FromIntPtr(hService);
//		WekaEA1^ service = (WekaEA1^)handle.Target;
//
//		int numInst = 1;
//		array<double>^ pp = gcnew array<double>(numInst * numAttr);
//		for (int i = 0; i < numInst * numAttr; i++)
//		{
//			pp[i] = p[i];
//		}
//
//		return service->Test(nowTime, pp);
//	}
//	catch (Exception^ ex)
//	{
//		MessageBox::Show(ex->Message, "CEAWrapper::Test");
//		MessageBox::Show(ex->StackTrace, "CEAWrapper::Test");
//		return 0;
//	}
//}
//
//void CEAWrapper::Now(IntPtr hService, const long long nowTime, const double nowPrice)
//{
//	try
//	{
//		GCHandle handle = GCHandle::FromIntPtr(hService);
//		WekaEA1^ service = (WekaEA1^)handle.Target;
//
//		service->Now(nowTime, nowPrice);
//	}
//	catch (Exception^ ex)
//	{
//		MessageBox::Show(ex->Message, "CEAWrapper::Now");
//	}
//}
void CEAWrapper::RunTool(const IntPtr hService, String^ toolName)
{
	try
	{
		GCHandle handle = GCHandle::FromIntPtr(hService);
		WekaEA2^ service = (WekaEA2^)handle.Target;

		service->RunTool(toolName);
	}
	catch (Exception^ ex)
	{
		MessageBox::Show(ex->Message, "CEAWrapper::RunTool");
	}
}
void CEAWrapper::OnNewBar(const IntPtr hService, const long long nowTime, const int barLength, const double* p, const int num)
{
	try
	{
		GCHandle handle = GCHandle::FromIntPtr(hService);
		WekaEA2^ service = (WekaEA2^)handle.Target;

		array<double>^ pp = gcnew array<double>(num);
		for (int i = 0; i < num; i++)
		{
			pp[i] = p[i];
		}
		service->OnNewBar(nowTime, barLength, pp);
	}
	catch (Exception^ ex)
	{
		MessageBox::Show(ex->Message, "CEAWrapper::OnNewBar");
	}
}


