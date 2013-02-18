using namespace System;
using namespace System::Threading;


ref class ServiceManaged
{
	public:
		static IntPtr CreateExportService(String^);
		static void SendTick(IntPtr, String^, IntPtr);
		static void DestroyExportService(IntPtr);
		static void RegisterSymbol(IntPtr, String^);
		static void UnregisterSymbol(IntPtr, String^);
};
