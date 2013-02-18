//+------------------------------------------------------------------+
//|                                              PipesMinerEELib.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

/*
#import "PipsMinerLib_EE.dll"
   int TLV(double a0, double a1, double a2, double a3, double a4, double a5, string a6, int a7, int a8);
   int TSV(double a0, double a1, double a2, double a3, double a4, double a5, string a6, int a7, int a8);
   int PLV(double a0, double a1, double a2, double a3, double a4, double a5, double a6, string a7, int a8, int a9);
   int PSV(double a0, double a1, double a2, double a3, double a4, double a5, double a6, string a7, int a8, int a9);
   double LND_Stock(double a0, double a1, double a2, double a3, double a4, string a5, int a6, int a7);
#import
*/


bool TLV(double a1, double a2, double a3, double a4, double a5, double a6, string a7, int a8, int a9)
{
  bool result; // eax@2
  double v10; // [sp+0h] [bp-10h]@3
  double v11; // [sp+8h] [bp-8h]@3

  if ( a9 < 8 )
  {
    v10 = (a3 - a4) * 1.0 / a6;
    v11 = v10;
    if ( v10 < 0.0 )
      v11 = v10 * -1.0;
    result = a5 <= v11 && v10 > 0.0 && a2 < a1;
  }
  else
  {
    result = -1;
  }
  return result;
}

bool PLV(double a1, double a2, double a3, double a4, double a5, double a6, double a7, string a9, int a10, int a11)
{
  bool result; // eax@2

  if ( a11 < 8 )
    result = a2 > a1 && a3 < a1;
  else
    result = -1;
  return result;
}

bool TSV(double a1, double a2, double a3, double a4, double a5, double a6, string a7, int a8, int a9)
{
  bool result; // eax@2
  double v10; // [sp+0h] [bp-10h]@3
  double v11; // [sp+8h] [bp-8h]@3

  if ( a9 < 8 )
  {
    v10 = (a3 - a4) * 1.0 / a6;
    v11 = v10;
    if ( v10 < 0.0 )
      v11 = v10 * -1.0;
    result = a5 <= v11 && v10 < 0.0 && a2 > a1;
  }
  else
  {
    result = -1;
  }
  return result;
}

bool PSV(double a1, double a2, double a3, double a4, double a5, double a6, double a7, string a9, int a10, int a11)
{
  bool result; // eax@2

  if ( a11 < 8 )
    result = a2 < a1 && a3 > a1;
  else
    result = -1;
  return result;
}

double LND_Stock(double a1, double a2, double a3, double a4, double a5, string a6, int a7, int a8)
{
  double result; // st7@2
  double v9; // [sp+0h] [bp-20h]@5
  double v10; // [sp+18h] [bp-8h]@3

  if ( a8 < 8 )
  {
    v10 = a1;
    if ( a1 <= 0.0 )
      v10 = -1.0 * a1 + 64988.0;
    v9 = (v10 * a4 - a3 - a5 + v10 * a4 - a3) / a1;
    if ( v9 < 0.0 )
      v9 = -1.0 * v9;
    result = v9 + 64988.0;
  }
  else
  {
    result = -1.0;
  }
  return result;
}
