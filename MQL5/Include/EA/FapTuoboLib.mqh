//+------------------------------------------------------------------+
//|                                                 FapTuoboUtil.mqh |
//|                                                         zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
/*#import "FapTurbo3.dll"
   int fun1(int a0, int a1, double a2, double a3, int a4, int a5, int a6, int a7, int a8, int a9, int a10, int a11, int a12, int a13, int a14, int a15, int& a16[], int& a17[], int& a18[], int a19, int& a20[], int& a21[], int a22, int& a23[]);
   int fun2(double a0, int a1, double a2, double a3, int a4, int a5, double a6, int a7, int a8, int& a9[], int& a10[], int& a11[], int a12, int& a13[], int& a14[], int a15, int& a16[]);
   int fun3(double a0, int a1, double a2, double a3, int a4, int a5, double a6, int a7, int a8, int& a9[], int& a10[], int& a11[], int a12, int& a13[], int& a14[], int a15, int& a16[]);
   bool fun4(double a0, int a1, int a2);*/
   
int fun1(int a1, int a2, double a3, double a4, int a5, int a6, int a7, int a8, int a9, int a10, int a11, int a12, int a13, int a14, int a15, int a16, int& a17[], int& a18[], int& a19[], int a20, int& a21[], int& a22[], int a23, int& a24[]) {
  if ( a1 || !a2 && !a5 )
    return (0);
  if ( a3 < a4 )
  {
    if ( a6 == 1)
    {
      if ( !a7 && !a8 )
        return (0);
    }
    else
    {
      if ( !a7 )
        return (0);
    }
  }
  else
  {
    if ( a3 == a4 )
    {
      if ( !a7 && !a8 )
        return (0);
    }
    else
    {
      if ( a6 == 1 )
      {
        if ( !a7 && !a8 )
          return (0);
      }
      else
      {
        if ( !a8 )
          return (0);
      }
    }
  }
  if ( a9 || a10 )
    return (0);
  int v25 = 0;
  if ( a11 == 1 )
  {
    if ( a13 == 1 )
      v25 = 1;
  }
  int result = 0;
  if ( a12 && a14 )
    result = -1;
  else
    result = v25;
  return (result);
}

int fun2(double a1, int a2, double a3, double a4, int a5, int a6, double a7, int a8, int a9, int& a10[], int& a11[], int& a12[], int a13, int& a14[], int& a15[], int a16, int& a17[]) {
   return (int)(!a2 && a7 >= a1 && (a3 < a6 || a4 < a5));
}

int fun3(double a1, int a2, double a3, double a4, int a5, int a6, double a7, int a8, int a9, int& a10[], int& a11[], int& a12[], int a13, int& a14[], int& a15[], int a16, int& a17[]) {
   return (int)(!a2 && a1 >= a7 && (a6 < a3 || a5 < a4));
}

bool fun4(double a1, int a2, int a3) {
   return (a1 < a2 && a3 < a1);
}
