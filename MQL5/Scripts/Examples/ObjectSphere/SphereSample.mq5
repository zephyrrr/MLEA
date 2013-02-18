//+------------------------------------------------------------------+
//|                                                 SphereSample.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//|                                              Revision 2010.02.08 |
//+------------------------------------------------------------------+
#property copyright "2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//---
#include "Sphere.mqh"
//---
string ArrowChar="*";
int    SleepTime=50;
//---
#define NUM_SPHERES 5
#define VISIBLE     0
#define INVISIBLE   1
//---
//+------------------------------------------------------------------+
//| Script to demonstrate the use of arrays.                         |
//+------------------------------------------------------------------+
CSphere *Sphere[NUM_SPHERES];
//--- arrays to initialize spheres
int   arrX[NUM_SPHERES]={100,100,300,500,500};
int   arrY[NUM_SPHERES]={100,500,300,500,350};
int   arrR[NUM_SPHERES]={30,40,100,60,20};
int   arrP[NUM_SPHERES]={10,13,30,20,7};
int   arrM[NUM_SPHERES]={10,13,30,20,7};
color arrC[NUM_SPHERES]={Red,Blue,Yellow,Green,Gray};
//+------------------------------------------------------------------+
//| Script initialization function                                   |
//+------------------------------------------------------------------+
int Init()
  {
   int i;
//--- creating objects
   for(i=0;i<NUM_SPHERES;i++)
     {
      if((Sphere[i]=new CSphere)==NULL) break;
      if(!Sphere[i].Create(i,arrC[i],arrX[i],arrY[i],arrR[i],arrP[i],arrM[i],ArrowChar))
         break;
     }
   if(i!=NUM_SPHERES)
     {
      printf("Error creating sphere %d",i);
      return(-1);
     }
//--- configuring orbits
   if(Sphere[0]!=NULL && Sphere[2]!=NULL)
      Sphere[0].SetOrbite(Sphere[2],M_PI/4,-M_PI/8,0,0.1);
   if(Sphere[1]!=NULL && Sphere[2]!=NULL)
      Sphere[1].SetOrbite(Sphere[2],-M_PI/8,-M_PI/16,M_PI/8,0.02);
   if(Sphere[3]!=NULL && Sphere[2]!=NULL)
      Sphere[3].SetOrbite(Sphere[2],M_PI/8,M_PI/4,M_PI/8,0.05);
   if(Sphere[4]!=NULL && Sphere[3]!=NULL)
      Sphere[4].SetOrbite(Sphere[3],M_PI/4,M_PI/8,M_PI/8,0.1);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Deinit()
  {
//--- deleting objects
   for(int i=0;i<NUM_SPHERES;i++)
     {
      if(Sphere[i]!=NULL)
        {
         delete Sphere[i];
         Sphere[i]=NULL;
        }
     }
//---
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
int OnStart()
  {
//--- call init function
   if(Init()==0)
     {
      //--- cycle until the script is not halted
      while(!IsStopped())
        {
         //--- цикл по объектам
         for(int i=0;i<NUM_SPHERES;i++)
           {
            if(Sphere[i]!=NULL)
              {
               Sphere[i].Recalculate();
              }
           }
         ChartRedraw();
         Sleep(SleepTime);
        }
     }
//--- call deinit function
   Deinit();
//---
   return(0);
  }
//+------------------------------------------------------------------+
