//+------------------------------------------------------------------+
//|                                                  ZigzagColor.mq5 |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_ZIGZAG
#property indicator_color1  DodgerBlue,Red
//--- input parameters
input int ExtDepth=12;
input int ExtDeviation=5;
input int ExtBackstep=3;
int level=3; // recounting's depth 
//--- indicator buffers
double ZigzagPeakBuffer[];
double ZigzagLawnBuffer[];
double HighMapBuffer[];
double LowMapBuffer[];
double ColorBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ZigzagPeakBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ZigzagLawnBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,HighMapBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,LowMapBuffer,INDICATOR_CALCULATIONS);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"ZigZag("+(string)ExtDepth+","+(string)ExtDeviation+","+(string)ExtBackstep+")");
   PlotIndexSetString(0,PLOT_LABEL,"ZigzagColor");
//--- set drawing line empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
  }
//+------------------------------------------------------------------+
//| get highest value for range                                      |
//+------------------------------------------------------------------+
double Highest(const double&array[],int range,int fromIndex)
  {
   double res;
//---
   res=array[fromIndex];
   for(int i=fromIndex;i>fromIndex-range && i>=0;i--)
     {
      if(res<array[i]) res=array[i];
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| get lowest value for range                                       |
//+------------------------------------------------------------------+
double Lowest(const double&array[],int range,int fromIndex)
  {
   double res;
//---
   res=array[fromIndex];
   for(int i=fromIndex;i>fromIndex-range && i>=0;i--)
     {
      if(res>array[i]) res=array[i];
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| Detrended Price Oscillator                                       |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
   int i,limit=0;
//--- check for rates count
   if(rates_total<100)
     {
      //--- clean up arrays
      ArrayInitialize(ZigzagPeakBuffer,0.0);
      ArrayInitialize(ZigzagLawnBuffer,0.0);
      ArrayInitialize(HighMapBuffer,0.0);
      ArrayInitialize(LowMapBuffer,0.0);
      ArrayInitialize(ColorBuffer,0.0);
      //--- exit with zero result
      return(0);
     }
//--- preliminary calculations
   int counterZ=0,whatlookfor=0;
   int shift,back=0,lasthighpos=0,lastlowpos=0;
   double val=0,res=0;
   double curlow=0,curhigh=0,lasthigh=0,lastlow=0;
//--- set empty values
   if(prev_calculated==0)
     {
      ArrayInitialize(ZigzagPeakBuffer,0.0);
      ArrayInitialize(ZigzagLawnBuffer,0.0);
      ArrayInitialize(HighMapBuffer,0.0);
      ArrayInitialize(LowMapBuffer,0.0);
      //--- start calculation from bar number ExtDepth
      limit=ExtDepth-1;
     }
//---
   if(prev_calculated>0)
     {
      i=rates_total-1;
      while(counterZ<level && i>rates_total -100)
        {
         res=(ZigzagPeakBuffer[i]+ZigzagLawnBuffer[i]);
         //---
         if(res!=0) counterZ++;
         i--;
        }
      i++;
      limit=i;
      //---
      if(LowMapBuffer[i]!=0)
        {
         curlow=LowMapBuffer[i];
         whatlookfor=1;
        }
      else
        {
         curhigh=HighMapBuffer[i];
         whatlookfor=-1;
        }
      //---
      for(i=limit+1;i<rates_total && !IsStopped();i++)
        {
         ZigzagPeakBuffer[i]=0.0;
         ZigzagLawnBuffer[i]=0.0;
         LowMapBuffer[i]=0.0;
         HighMapBuffer[i]=0.0;
        }
     }
//----
   for(shift=limit;shift<rates_total && !IsStopped();shift++)
     {

      val=Lowest(Low,ExtDepth,shift);
      //---
      if(val==lastlow) val=0.0;
      else
        {
         lastlow=val;
         //---
         if((Low[shift]-val)>(ExtDeviation*_Point)) val=0.0;
         else
           {
            //---
            for(back=ExtBackstep;back>=1;back--)
              {
               res=LowMapBuffer[shift-back];
               //---
               if((res!=0) && (res>val)) LowMapBuffer[shift-back]=0.0;
              }
           }
        }
      //---
      if(Low[shift]==val) LowMapBuffer[shift]=val;
      else
         LowMapBuffer[shift]=0.0;
      //--- high
      val=Highest(High,ExtDepth,shift);
      //---
      if(val==lasthigh) val=0.0;
      else
        {
         lasthigh=val;
         //---
         if((val-High[shift])>(ExtDeviation*_Point)) val=0.0;
         else
           {
            //---
            for(back=ExtBackstep;back>=1;back--)
              {
               res=HighMapBuffer[shift-back];
               //---
               if((res!=0) && (res<val)) HighMapBuffer[shift-back]=0.0;
              }
           }
        }
      //---
      if(High[shift]==val) HighMapBuffer[shift]=val;
      else  HighMapBuffer[shift]=0.0;
     }
// final cutting 
   if(whatlookfor==0)
     {
      lastlow=0;
      lasthigh=0;
     }
   else
     {
      lastlow=curlow;
      lasthigh=curhigh;
     }
//----
   for(shift=limit;shift<rates_total && !IsStopped();shift++)
     {
      res=0.0;
      switch(whatlookfor)
        {
         // look for peak or lawn 
         case 0: if(lastlow==0 && lasthigh==0)
           {
            if(HighMapBuffer[shift]!=0)
              {
               lasthigh=High[shift];
               lasthighpos=shift;
               whatlookfor=-1;
               ZigzagPeakBuffer[shift]=lasthigh;
               ColorBuffer[shift]=0;
               res=1;
              }
            if(LowMapBuffer[shift]!=0)
              {
               lastlow=Low[shift];
               lastlowpos=shift;
               whatlookfor=1;
               ZigzagLawnBuffer[shift]=lastlow;
               ColorBuffer[shift]=1;
               res=1;
              }
           }
         break;
         // look for peak
         case 1: if(LowMapBuffer[shift]!=0.0 && LowMapBuffer[shift]<lastlow && 
                    HighMapBuffer[shift]==0.0)
           {
            ZigzagLawnBuffer[lastlowpos]=0.0;
            lastlowpos=shift;
            lastlow=LowMapBuffer[shift];
            ZigzagLawnBuffer[shift]=lastlow;
            ColorBuffer[shift]=1;
            res=1;
           }
         if(HighMapBuffer[shift]!=0.0 && LowMapBuffer[shift]==0.0)
           {
            lasthigh=HighMapBuffer[shift];
            lasthighpos=shift;
            ZigzagPeakBuffer[shift]=lasthigh;
            ColorBuffer[shift]=0;
            whatlookfor=-1;
            res=1;
           }
         break;
         // look for lawn
         case -1:  if(HighMapBuffer[shift]!=0.0 && 
                      HighMapBuffer[shift]>lasthigh && 
                      LowMapBuffer[shift]==0.0)
           {
            ZigzagPeakBuffer[lasthighpos]=0.0;
            lasthighpos=shift;
            lasthigh=HighMapBuffer[shift];
            ZigzagPeakBuffer[shift]=lasthigh;
            ColorBuffer[shift]=0;
           }
         if(LowMapBuffer[shift]!=0.0 && HighMapBuffer[shift]==0.0)
           {
            lastlow=LowMapBuffer[shift];
            lastlowpos=shift;
            ZigzagLawnBuffer[shift]=lastlow;
            ColorBuffer[shift]=1;
            whatlookfor=1;
           }
         break;
         default: return(rates_total);
        }
     }

//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
