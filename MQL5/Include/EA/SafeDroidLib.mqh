//+------------------------------------------------------------------+
//|                                                 SafeDroidLib.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

/*
#import "SafeDroid.dll"
   int ccttll(int a0, int a1, string a2, int a3, int a4, string a5, string a6, int a7);
   double lloopp(int a0, int a1, int a2, int a3, double a4, int a5, int a6, int a7);
   int oosspp(double a0, double a1, double a2, double a3, double a4, int a5, double a6, double a7, double a8, double a9, double a10, string a11, int a12, int a13, string a14, string a15, int a16);
   double ssmmpp(double a0, double a1, double a2, int a3, int a4, int a5, double a6, double a7, int a8, double a9, double a10, string a11, int a12, int a13, string a14, string a15, int a16);
   double bbmmpp(double a0, double a1, double a2, int a3, int a4, int a5, double a6, double a7, int a8, double a9, double a10, string a11, int a12, int a13, string a14, string a15, int a16);
   int oobbpp(double a0, double a1, double a2, double a3, double a4, int a5, double a6, double a7, double a8, double a9, double a10, string a11, int a12, int a13, string a14, string a15, int a16);
   int ssnnpp(int a0, string a1, int a2, int a3, string a4, string a5, int a6);
   int bbnnpp(int a0, string a1, int a2, int a3, string a4, string a5, int a6);
   int ssppbb(int a0, int a1, string a2, string a3, string a4, int a5);
   int ooosss(double a0, double a1, double a2, double a3, int a4, int a5, double a6, double a7, double a8, int a9, int a10, double a11, double a12, int a13, int a14, int a15, string a16, int a17, int a18, string a19, string a20, int a21);
   int ooobbb(double a0, double a1, double a2, double a3, int a4, int a5, double a6, double a7, double a8, int a9, int a10, double a11, double a12, int a13, int a14, int a15, string a16, int a17, int a18, string a19, string a20, int a21);
   int ssccoo(double a0, double a1, double a2, double a3, double a4, double a5, double a6, double a7, double a8, int a9, int a10, double a11, int a12, string a13, int a14, int a15, string a16, string a17, int a18);
   int bbccoo(double a0, double a1, double a2, double a3, double a4, double a5, double a6, double a7, double a8, int a9, int a10, double a11, int a12, string a13, int a14, int a15, string a16, string a17, int a18);
#import
*/

int ccttll(int a1, int a2, string a3, int a4, int a5, string a6, string a7, int a8)
{
  int result; // eax@2

  if ( a1 )
  {
    if ( a1 == 1 )
      result = 2;
    else
      result = ((a1 != 2) - 1) & 4;
  }
  else
  {
    result = 1;
  }
  return result;
}

double lloopp(int a1, int a2, int a3, int a4, double a5, int a6, int a7, int a8)
{
  int v8; // eax@6
  double result; // st7@11
  int v10; // eax@17

  if ( a4 && a4 <= 2 && a4 >= 0 && a8 != 1 )
  {
    if ( a3 == 2 )
      v8 = 4;
    else
      v8 = a3 + 1;
    if ( a6 != v8 || a7 < 7 * v8 || a7 > 10 * v8 )
    {
      if ( a6 != 3 * v8 && a6 != 2 * v8 || a7 < 2 * v8 || a7 > 8 * v8 )
      {
        v10 = 5 * v8;
        if ( a7 < v10 || a6 || a1 > v10 )
          result = a5;
        else
          result = (double)(3 * a4) * a5;
      }
      else
      {
        result = (double)(2 * a4) * a5;
      }
    }
    else
    {
      result = (double)(2 * a4) * a5;
    }
  }
  else
  {
    result = a5;
  }
  return result;
}

int ssppbb(int a1, int a2, int a3, int a4, int a5, int a6)
{
  return 1;
}

int sub_10001000()
{
  return 1;
}
int sub_10001540(int a1)
{
  int v2; // eax@1

  v2 = -(a1 != 10);
  //LOBYTE(v2) = v2 & 0xB8;
  v2 = v2 & 0xFFB8;
  return v2 + 80;
}
 


double ssmmpp(double b1, double b2, double b3, int a7, int a8, int a9, double a10, double a11, int a12, double a13, double a14, string a15, int a16, int a17, string a18, string a19, int a20)
{
  // -3
  double v21;

  v21 = (double)(int)sub_10001540(a12) * a14;
  if ( !a7 && a8 - a9 > 0 && a10 > 0.0 && a10 - a11 < v21 || a10 == 0.0 )
    a10 = a13 - 10000.0;
  return a10;
}

double bbmmpp(double b1, double b2, double b3, int a7, int a8, int a9, double a10, double a11, int a12, double a13, double a14, string a15, int a16, int a17, string a18, string a19, int a20)
{
  double v21;
    
  // -3
  v21 = (double)(int)sub_10001540(a12) * a14;
  if ( !a7 && a8 - a9 > 0 && a10 > 0.0 && a11 - a10 < v21 || a10 == 0.0 )
    a10 = a13 + 10000.0;
  return a10;
}

  
int oobbpp(double b1, double b2, double b3, double b4, double b5, int a11, double a12, double a13, double a14, double a15, double a16, string a17, int a18, int a19, string a20, string a21, int a22)
{
    // -5
  if (a14 <= a13 || a16 <= a15 || (double)(10 * a11) * a12 >= a16 - a15 )
    return 0;
  return 1;
}

int oosspp(double b1, double b2, double b3, double b4, double b5, int a11, double a12, double a13, double a14, double a15, double a16, string a17, int a18, int a19, string a20, string a21, int a22)
{
  if ( a14 >= a13 || a16 >= a15 || (double)(10 * a11) * a12 >= a15 - a16 )
    return 0;
  return 1;
}

int ssnnpp(int a1, string a2, int a3, int a4, string a5, string a6, int a7)
{
  int v7; // qax@1
  double v8; // st7@1

  v8 = (double)a1;
  ceil(v8);
  v7 = (int)v8;
  if ( v8 < 1 )
  {
    if ( a1 > 0 )
        // LODWORD(v7) = 1;
      v7 = v7 / 256 * 256 + 1;
  }
  return v7;
}

int bbnnpp(int a1, string a2, int a3, int a4, string a5, string a6, int a7)
{
    return ssnnpp(a1, a2, a3, a4, a5, a6, a7);
}

int ooosss(double b1, double b2, double a5, double a6, int a7, int a8, double a9, double a10, double a11, int a12, int a13, double a14, double a15, int a16, int a17, int a18, string a19, int a20, int a21, string a22, string a23, int a24)
{
    int result = 0;
    if (a5 >= a6
        || a7 >= a8
        || a9 >= a6
        || a10 <= a11
        || a12 <= a13 + 1
        || a14 <= 40.0
        || a14 >= 48.0
        || a15 >= 100.0)
    return result;
    
    result = 1;
    if (a16 != 1
        || a12 <= a17 + 4 )
//LABEL_22:
        result = 0;
  return result;
}

int ooobbb(double b1, double b2, double a5, double a6, int a7, int a8, double a9, double a10, double a11, int a12, int a13, double a14, double a15, int a16, int a17, int a18, string a19, int a20, int a21, string a22, string a23, int a24)
{
    // -2
  int result = 0; // eax@10

  if (a5 <= a6
    || a7 >= a8
    || a9 <= a6
    || a10 >= a11
    || a12 <= a13 + 1
    || a14 <= 52.0
    || a14 >= 60.0
    || a15 <= 100.0)
    return result;
    
  result = 1;  
    
  if (a16 != 1
    || a12 <= a17 + 4 )
    result = 0;
  return result;

}

int ssccoo(double b1, double b2, double b3, double b4, double a9, double a10, double a11, double a12, double a13, int a14, int a15, double a16, int a17, string a18, int a19, int a20, string a21, string a22, int a23)
{
  return (int)(a9 > a10 && a12 + a11 <= a9 && (double)a14 < a13
      || a15 > 7200 && (double)a17 * a16 <= a9 - a11
      || a15 > 86400 && (double)(20 * a17) * a16 >= a11 - a9);
}

int bbccoo(double b1, double b2, double b3, double b4, double a9, double a10, double a11, double a12, double a13, int a14, int a15, double a16, int a17, string a18, int a19, int a20, string a21, string a22, int a23)
{
  return (int)(a9 < a10 && a11 - a12 >= a9 && (double)a14 < a13
      || a15 > 7200 && (double)a17 * a16 <= a11 - a9
      || a15 > 86400 && (double)(20 * a17) * a16 >= a9 - a11);
}







