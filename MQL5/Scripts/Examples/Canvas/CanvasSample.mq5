//+------------------------------------------------------------------+
//|                                                 CanvasSample.mq5 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property script_show_inputs
//---
#include <Canvas\Canvas.mqh>
//+------------------------------------------------------------------+
//| inputs                                                           |
//+------------------------------------------------------------------+
input int      Width=800;
input int      Height=600;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
int OnStart(void)
  {
   int total=1024;
   int limit=MathMax(Width,Height);
   int x1,x2,x3,y1,y2,y3,r;
   int x[],y[];
//--- check
   if(Width<100 || Height<100)
     {
      Print("Too simple.");
      return(-1);
     }
//--- create canvas
   CCanvas canvas;
   if(!canvas.CreateBitmapLabel("SampleCanvas",0,0,Width,Height,COLOR_FORMAT_ARGB_RAW))
     {
      Print("Error creating canvas: ",GetLastError());
      return(-1);
     }
//--- deawing
   canvas.Erase(XRGB(0x1F,0x1F,0x1F));
   canvas.Update();
//--- start randomizer
   srand(GetTickCount());
//--- draw pixels
   for(int i=0;i<total && !IsStopped();i++)
     {
      x1=rand()%limit;
      y1=rand()%limit;
      canvas.PixelSet(x1,y1,RandomRGB());
      canvas.Update();
     }
//--- erase
   canvas.Erase(XRGB(0x1F,0x1F,0x1F));
   canvas.Update();
//--- draw horizontal/vertical lines
   for(int i=0;i<total && !IsStopped();i++)
     {
      x1=rand()%limit;
      x2=rand()%limit;
      y1=rand()%limit;
      y2=rand()%limit;
      if(i%2==0)
         canvas.LineHorizontal(x1,x2,y1,RandomRGB());
      else
         canvas.LineVertical(x1,y1,y2,RandomRGB());
      canvas.Update();
     }
//--- draw lines
   for(int i=0;i<total && !IsStopped();i++)
     {
      x1=rand()%limit;
      x2=rand()%limit;
      y1=rand()%limit;
      y2=rand()%limit;
      canvas.Line(x1,y1,x2,y2,RandomRGB());
      canvas.Update();
     }
//--- erase
   canvas.Erase(XRGB(0x1F,0x1F,0x1F));
   canvas.Update();
//--- draw filled circles
   for(int i=0;i<total && !IsStopped();i++)
     {
      x1=rand()%limit;
      y1=rand()%limit;
      r =rand()%limit;
      canvas.FillCircle(x1,y1,r,RandomRGB());
      canvas.Update();
     }
//--- draw circles
   for(int i=0;i<total && !IsStopped();i++)
     {
      x1=rand()%limit;
      y1=rand()%limit;
      r =rand()%limit;
      canvas.Circle(x1,y1,r,RandomRGB());
      canvas.Update();
     }
//--- erase
   canvas.Erase(XRGB(0x1F,0x1F,0x1F));
   canvas.Update();
//--- draw filled rectangles
   for(int i=0;i<total && !IsStopped();i++)
     {
      x1=rand()%limit;
      y1=rand()%limit;
      x2=rand()%limit;
      y2=rand()%limit;
      canvas.FillRectangle(x1,y1,x2,y2,RandomRGB());
      canvas.Update();
     }
//--- draw rectangles
   for(int i=0;i<total && !IsStopped();i++)
     {
      x1=rand()%limit;
      y1=rand()%limit;
      x2=rand()%limit;
      y2=rand()%limit;
      canvas.Rectangle(x1,y1,x2,y2,RandomRGB());
      canvas.Update();
     }
//--- erase
   canvas.Erase(XRGB(0x1F,0x1F,0x1F));
   canvas.Update();
//--- draw filled triangles
   for(int i=0;i<total && !IsStopped();i++)
     {
      x1=rand()%limit;
      y1=rand()%limit;
      x2=rand()%limit;
      y2=rand()%limit;
      x3=rand()%limit;
      y3=rand()%limit;
      canvas.FillTriangle(x1,y1,x2,y2,x3,y3,RandomRGB());
      canvas.Update();
     }
//--- draw triangles
   for(int i=0;i<total && !IsStopped();i++)
     {
      x1=rand()%limit;
      y1=rand()%limit;
      x2=rand()%limit;
      y2=rand()%limit;
      x3=rand()%limit;
      y3=rand()%limit;
      canvas.Triangle(x1,y1,x2,y2,x3,y3,RandomRGB());
      canvas.Update();
     }
//--- erase
   canvas.Erase(XRGB(0x1F,0x1F,0x1F));
   canvas.Update();
//---
   ArrayResize(x,10);
   ArrayResize(y,10);
//--- draw polyline
   for(int i=0;i<10;i++)
     {
      x[i]=rand()%Width;
      y[i]=rand()%Height;
     }
   canvas.Polyline(x,y,RandomRGB());
   canvas.Update();
//--- draw polygon
   for(int i=0;i<10;i++)
     {
      x[i]=rand()%Width;
      y[i]=rand()%Height;
     }
   canvas.Polygon(x,y,RandomRGB());
   canvas.Update();
//--- filling
   for(int j=0,clr=0;j<total && !IsStopped();j++,clr++)
     {
      int xf=rand()%Width;
      int yf=rand()%Height;
      canvas.Fill(xf,yf,RandomRGB());
      canvas.Update();
     }
//--- finish
   ObjectDelete(0,"SampleCanvas");
   canvas.Destroy();
   return(0);
  }
//+------------------------------------------------------------------+
//| Random RGB color                                                 |
//+------------------------------------------------------------------+
uint RandomRGB(void)
  {
   return(XRGB(rand()%255,rand()%255,rand()%255));
  }
//+------------------------------------------------------------------+
