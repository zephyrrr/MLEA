//+------------------------------------------------------------------+
//|                                                           AD.mq5 |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property description "Accumulation/Distribution"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  LightSeaGreen
#property indicator_label1  "A/D"
//--- input params
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK; // Volume type
//---- buffers
double ExtADbuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- indicator short name
   IndicatorSetString(INDICATOR_SHORTNAME,"A/D");
//---- index buffer
   SetIndexBuffer(0,ExtADbuffer);
//--- set index draw begin
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,1);
//---- OnInit done
  }
//+------------------------------------------------------------------+
//| Accumulation/Distribution                                        |
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
//--- check for bars count
   if(rates_total<2)
      return(0); //exit with zero result
//--- get current position
   int pos=prev_calculated-1;
   if(pos<0) pos=0;
//--- calculate with appropriate volumes
   if(InpVolumeType==VOLUME_TICK)
      Calculate(rates_total,pos,High,Low,Close,TickVolume);
   else
      Calculate(rates_total,pos,High,Low,Close,Volume);
//----
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Calculating with selected volume                                 |
//+------------------------------------------------------------------+
void Calculate(const int rates_total,const int pos,
               const double &High[],
               const double &Low[],
               const double &Close[],
               const long &Volume[])
  {
   double hi,lo,cl;
//--- main cycle
   for(int i=pos;i<rates_total && !IsStopped();i++)
     {
      //--- get some data from arrays
      hi=High[i];
      lo=Low[i];
      cl=Close[i];
      //--- calculate new AD
      double sum=(cl-lo)-(hi-cl);
      if(hi==lo) sum=0.0;
      else       sum=(sum/(hi-lo))*Volume[i];
      if(i>0) sum+=ExtADbuffer[i-1];
      ExtADbuffer[i]=sum;
     }
//----
  }
//+------------------------------------------------------------------+
