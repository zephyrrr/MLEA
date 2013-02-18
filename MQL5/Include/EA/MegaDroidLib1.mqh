//+------------------------------------------------------------------+
//|                                                 MagaDroidLib.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

//#import "MegaDroid.dll"
//   //int GetGmtOffset(int a0, int a1, int a2, double& a3[], int& a4[]);
//   //void Activate(string a0, int a1, int a2, string a3, int a4);
//   //int GetState();
//   //int GetStatus();
//   int Increment(string a0);
//   bool Decrement(int a0);
//   bool IsTradeTime(int a0, int a1, int a2, int a3, int a4);
//   bool s1_Buy(double a0, double a1, double a2, double a3, double a4, double a5, double a6, double a7, int a8, int a9);
//   bool s1_Sell(double a0, double a1, double a2, double a3, double a4, double a5, double a6, double a7, int a8, int a9);
//   bool s2_Buy(double a0, double a1, double a2, double a3, double a4, double a5, int a6, int a7);
//   bool s2_Sell(double a0, double a1, double a2, double a3, double a4, double a5, int a6, int a7);
//   bool s1_Init(int a0, int& a1[], int& a2[], int& a3[], int& a4[], int& a5[], int& a6[], int& a7[], int& a8[], int& a9[], int& a10[], int& a11[], double& a12[], double& a13[], double& a14[], double& a15[], int& a16[], int& a17[], int& a18[], int& a19[], int& a20[], int& a21[]);
//   bool s2_Init(int a0, int& a1[], int& a2[], int& a3[], double& a4[], int& a5[], int& a6[], int& a7[], int& a8[], double& a9[], double& a10[], double& a11[], int& a12[], int& a13[], int& a14[], int& a15[], int& a16[], int& a17[]);
//#import "kernel32.dll"
//   int  GetCurrentProcess();
//   int  WriteProcessMemory(int handle, int address, int& buffer[], int size, int& written);
//   int  GetModuleHandleA(string module);
//   int  LoadLibraryA(string module);
//#import

class CMegaDroidLib1
{
public:
    CMegaDroidLib1();
public:
    
    bool s1_Init(int a0, int& a1[], int& a2[], int& a3[], int& a4[], int& a5[], int& a6[], int& a7[], int& a8[], int& a9[], int& a10[], int& a11[], double& a12[], double& a13[], double& a14[], double& a15[], int& a16[], int& a17[], int& a18[], int& a19[], int& a20[], int& a21[]);
    bool s1_Buy(double a2, double a3, double a4, double a5, double a6, double a7, double a8, double a9, int a10, int a11);
    bool s1_Sell(double a1, double a2, double a3, double a4, double a5, double a6, double a7, double a8, int a9, int a10);
    bool IsTradeTime(int a1, int a2, int a3, int a4, int a5);
    int S1_CheckSymbol();
    
public:
    int gi_336;
    int gi_372;
    int gi_380;
    int gi_384;
    int gi_388;
    int g_period_400;
    int g_period_404;
    int g_period_408;
    double gd_412;
    double gd_420;
    double gd_428;
    double gd_436;
    double gd_476;
    double gd_484;
    double gd_496;
    double gd_504;
    int gi_516;
    int gi_528;
    int gi_532;
    int gi_536;
    int gi_540;
    ENUM_TIMEFRAMES g_timeframe_368;

    // Other
    int gi_376;
};

void CMegaDroidLib1::CMegaDroidLib1()
{
    gi_372 = 10;
    gi_380 = 200;
    gi_384 = 20;
    gi_388 = 0;
    g_period_400 = 6;
    g_period_404 = 20;
    g_period_408 = 8;
    gd_412 = 70.0;
    gd_420 = 30.0;
    gd_428 = 64.0;
    gd_436 = 36.0;
    gd_476 = 1.0;
    gd_484 = 24.0;
    gd_496 = 1.0;
    gd_504 = 1.0;
    gi_516 = 0;
    gi_528 = 21;
    gi_532 = 1;
    gi_536 = 21;
    gi_540 = 0;
    g_timeframe_368 = PERIOD_M15;
    
    // Other
    gi_376 = 50;
}

bool CMegaDroidLib1::s1_Init(int a0, int& a1[], int& a2[], int& a3[], int& a4[], int& a5[], int& a6[], int& a7[], int& a8[], int& a9[], int& a10[], int& a11[], double& a12[], double& a13[], double& a14[], double& a15[], int& a16[], int& a17[], int& a18[], int& a19[], int& a20[], int& a21[])
{
    a1[0] = 10;
    a2[0] = 150;
    a3[0] = 60;
    a4[0] = 0;
    a5[0] = 6;
    a6[0] = 20;
    a7[0] = 8;
    a8[0] = 70;
    a9[0] = 30;
    a10[0] = 70;
    a11[0] = 30;
    a12[0] = 1;
    a13[0] = 12;
    a14[0] = 1;
    a15[0]= 1;
    a16[0] = 40;
    a17[0] = 21;
    a18[0] = 23;
    a19[0] = 21;
    a20[00] = 23;
    a21[0] = 15;
    
    return true;
}


bool CMegaDroidLib1::s1_Buy(double a2, double a3, double a4, double a5, double a6, double a7, double a8, double a9, int a10, int a11)
{
  return a3 < 0.0 && (!a10 || a6 - a2 >= a9) && (a7 > a4 || a11 && a8 > a5 && a4 < 50.0);
}

bool CMegaDroidLib1::s1_Sell(double a1, double a2, double a3, double a4, double a5, double a6, double a7, double a8, int a9, int a10)
{
  return a2 > 0.0 && (!a9 || a1 - a5 >= a8) && (a6 < a3 || a10 && a7 < a4 && a3 > 50.0);
}

bool CMegaDroidLib1::IsTradeTime(int a1, int a2, int a3, int a4, int a5)
{
  return a4 <= 31 - a5;
}

int CMegaDroidLib1::S1_CheckSymbol() {
   int lia_0[1];
   int lia_4[1];
   int lia_8[1];
   int lia_12[1];
   int lia_16[1];
   int lia_20[1];
   int lia_24[1];
   int lia_28[1];
   int lia_32[1];
   int lia_36[1];
   int lia_40[1];
   double lda_44[1];
   double lda_48[1];
   double lda_52[1];
   double lda_56[1];
   int lia_60[1];
   int lia_64[1];
   int lia_68[1];
   int lia_72[1];
   int lia_76[1];
   int lia_80[1];
   if (s1_Init(gi_336, lia_0, lia_4, lia_8, lia_12, lia_16, lia_20, lia_24, lia_28, lia_32, lia_36, lia_40, lda_44, lda_48, lda_52, lda_56, lia_60, lia_64, lia_68, lia_72, lia_76, lia_80)) {
      gi_372 = lia_0[0];
      gi_380 = lia_4[0];
      gi_384 = lia_8[0];
      gi_388 = lia_12[0];
      g_period_400 = lia_16[0];
      g_period_404 = lia_20[0];
      g_period_408 = lia_24[0];
      gd_412 = lia_28[0];
      gd_420 = lia_32[0];
      gd_428 = lia_36[0];
      gd_436 = lia_40[0];
      gd_476 = lda_44[0];
      gd_484 = lda_48[0];
      gd_496 = lda_52[0];
      gd_504 = lda_56[0];
      gi_516 = lia_60[0];
      gi_528 = lia_64[0];
      gi_532 = lia_68[0];
      gi_536 = lia_72[0];
      gi_540 = lia_76[0];
      g_timeframe_368 = (ENUM_TIMEFRAMES)lia_80[0];
      return (1);
   }
   return (0);
}
