using namespace System;

ref class CEAWrapper
{
public:
	static void HelloServiceTest(IntPtr hService, String^ say);

	static IntPtr Create(String^ symbol);
	static void Destroy(IntPtr);
	/*static void Train(IntPtr hService, const long long nowTime, const int numInst, const int numAttr, const double* p, const int numHp, const int* r, const int numInst2, const double* p2, const int* r2);
	static int Test(IntPtr hService, const long long nowTime, const int numAttr, const double* p);
	static void Now(IntPtr hService, const long long nowTime, const double nowPrice);*/
	static void OnNewBar(const IntPtr hService, const long long nowTime, const int barLength, const double* p, const int num);
	static void RunTool(const IntPtr hService, String^ toolName);
};