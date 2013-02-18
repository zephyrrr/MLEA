//+------------------------------------------------------------------+
//|                                      MarketFacilitationIndex.mq5 |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  Lime,SaddleBrown,Blue,Pink
#property indicator_width1  2
//--- input parameter
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK; // Volumes
//---- buffers
double                    ExtMFIBuffer[];
double                    ExtColorBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- indicators
   SetIndexBuffer(0,ExtMFIBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//--- name for DataWindow
   IndicatorSetString(INDICATOR_SHORTNAME,"BWMFI");
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateMFI(const int start,const int rates_total,
                  const double &High[],
                  const double &Low[],
                  const long &Volume[])
  {
   int  i=start;
   bool mfi_up=true,vol_up=true;
//--- calculate first values of mfi_up and vol_up
   if(i>0)
     {
      int n=i;
      while(n>0)
        {
         if(ExtMFIBuffer[n]>ExtMFIBuffer[n-1]) { mfi_up=true;  break; }
         if(ExtMFIBuffer[n]<ExtMFIBuffer[n-1]) { mfi_up=false; break; }
         //--- if mfi values are equal continue
         n--;
        }
      n=i;
      while(n>0)
        {
         if(Volume[n]>Volume[n-1]) { vol_up=true;  break; }
         if(Volume[n]<Volume[n-1]) { vol_up=false; break; }
         //--- if real volumes are equal continue
         n--;
        }
     }
//---
   while(i<rates_total && !IsStopped())
     {
      if(Volume[i]==0)
        {
         if(i>0) ExtMFIBuffer[i]=ExtMFIBuffer[i-1];
         else    ExtMFIBuffer[i]=0;
        }
      else ExtMFIBuffer[i]=(High[i]-Low[i])/_Point/Volume[i];
      //--- calculate changes
      if(i>0)
        {
         if(ExtMFIBuffer[i]>ExtMFIBuffer[i-1]) mfi_up=true;
         if(ExtMFIBuffer[i]<ExtMFIBuffer[i-1]) mfi_up=false;
         if(Volume[i]>Volume[i-1])             vol_up=true;
         if(Volume[i]<Volume[i-1])             vol_up=false;
        }
      //--- set colors
      if(mfi_up && vol_up)   ExtColorBuffer[i]=0.0;
      if(!mfi_up && !vol_up) ExtColorBuffer[i]=1.0;
      if(mfi_up && !vol_up)  ExtColorBuffer[i]=2.0;
      if(!mfi_up && vol_up)  ExtColorBuffer[i]=3.0;
      i++;
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---
   int start=0;
//---
   if(start<prev_calculated) start=prev_calculated-1;
//--- calculate with tick or real volumes
   if(InpVolumeType==VOLUME_TICK)
      CalculateMFI(start,rates_total,High,Low,TickVolume);
   else
      CalculateMFI(start,rates_total,High,Low,Volume);
//--- normalize last mfi value
   if(rates_total>1)
     {
      datetime ctm=TimeTradeServer(),lasttm=Time[rates_total-1],nexttm=lasttm+datetime(PeriodSeconds());
      if(ctm<nexttm && ctm>=lasttm && nexttm!=lasttm)
        {
         double correction_koef=double(1+ctm-lasttm)/double(nexttm-lasttm);
         ExtMFIBuffer[rates_total-1]*=correction_koef;
        }
     }
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+