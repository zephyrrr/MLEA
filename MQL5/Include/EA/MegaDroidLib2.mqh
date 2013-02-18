//+------------------------------------------------------------------+
//|                                                MegaDroidLib2.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

//#include "MegaDroidLib1.mqh"
class CMegaDroidLib2
{
public:
    CMegaDroidLib2();
public:
    
    bool s2_Init(int a0, int& a1[], int& a2[], int& a3[], double& a4[], int& a5[], int& a6[], int& a7[], int& a8[], double& a9[], double& a10[], double& a11[], int& a12[], int& a13[], int& a14[], int& a15[], int& a16[], int& a17[]);
    bool s2_Buy(double a1, double a2, double a3, double a4, double a5, double a6, int a7, int a8);
    bool s2_Sell(double a1, double a2, double a3, double a4, double a5, double a6, int a7, int a8);
    int S2_CheckSymbol();
    bool IsTradeTime(int a1, int a2, int a3, int a4, int a5);
public:
    int gi_548;
    int gi_556;
    int gi_560;
    double gd_564;
    int gi_572;
    int gi_584;
    int g_period_588;
    int g_period_592;
    double gd_608;
    double gd_616;
    double gd_624;
    int gi_640;
    int gi_664;
    ENUM_TIMEFRAMES g_timeframe_544;
    int gi_652;
    int gi_656;
    int gi_660;
    
    int gi_336;
};

void CMegaDroidLib2::CMegaDroidLib2()
{
    gi_548 = 35;
    gi_556 = 200;
    gi_560 = 20;
    gd_564 = 1.0;
    gi_572 = 0;
    gi_584 = 36;
    g_period_588 = 168;
    g_period_592 = 275;
    gd_608 = 1.0;
    gd_616 = 12.0;
    gd_624 = 24.0;
    gi_640 = 0;
    gi_664 = 0;
    g_timeframe_544 = PERIOD_M5;
    gi_652 = 21;
    gi_656 = 4;
    gi_660 = 21;
}

bool CMegaDroidLib2::IsTradeTime(int a1, int a2, int a3, int a4, int a5)
{
  return a4 <= 31 - a5;
}

bool CMegaDroidLib2::s2_Init(int a0, int& a1[], int& a2[], int& a3[], double& a4[], int& a5[], int& a6[], int& a7[], int& a8[], double& a9[], double& a10[], double& a11[], int& a12[], int& a13[], int& a14[], int& a15[], int& a16[], int& a17[])
{
    a1[0] = 15;
    a2[0] = 150;
    a3[0] = 30;
    a4[0] = 0;
    a5[0] = 3;
    a6[0] = 180;
    a7[0] = 60;
    a8[0] = 275;
    a9[0] = 1;
    a10[0] = 3;
    a11[0] = 12;
    a12[0] = 4;
    a13[0] = 22;
    a14[0] = 23;
    a15[0]= 22;
    a16[0] = 23;
    a17[0] = 1;
    
    return true;
}

bool CMegaDroidLib2::s2_Buy(double a1, double a2, double a3, double a4, double a5, double a6, int a7, int a8)
{
  return a5 >= a1 && (!a7 || a3 < 0.0) && (!a8 || a4 >= 0.0) && a1 - a2 < a6 - a5;
}

bool CMegaDroidLib2::s2_Sell(double a1, double a2, double a3, double a4, double a5, double a6, int a7, int a8)
{
  return a6 <= a2 && (!a7 || a3 > 0.0) && (!a8 || a4 <= 0.0) && a1 - a2 < a6 - a5;
}


int CMegaDroidLib2::S2_CheckSymbol() {
   int lia_0[1];
   int lia_4[1];
   int lia_8[1];
   int lia_12[1];
   double lda_16[1];
   int lia_20[1];
   int lia_24[1];
   int lia_28[1];
   double lda_32[1];
   double lda_36[1];
   double lda_40[1];
   int lia_44[1];
   int lia_48[1];
   int lia_52[1];
   int lia_56[1];
   int lia_60[1];
   int lia_64[1];
   if (s2_Init(gi_336, lia_0, lia_4, lia_8, lda_16, lia_12, lia_20, lia_24, lia_28, lda_32, lda_36, lda_40, lia_44, lia_48, lia_52, lia_56, lia_60, lia_64)) {
      gi_548 = lia_0[0];
      gi_556 = lia_4[0];
      gi_560 = lia_8[0];
      gd_564 = lda_16[0];
      gi_572 = lia_12[0];
      gi_584 = lia_20[0];
      g_period_588 = lia_24[0];
      g_period_592 = lia_28[0];
      gd_608 = lda_32[0];
      gd_616 = lda_36[0];
      gd_624 = lda_40[0];
      gi_640 = lia_44[0];
      gi_652 = lia_48[0];
      gi_656 = lia_52[0];
      gi_660 = lia_56[0];
      gi_664 = lia_60[0];
      g_timeframe_544 = (ENUM_TIMEFRAMES)lia_64[0];
      return (1);
   }
   return (0);
}
