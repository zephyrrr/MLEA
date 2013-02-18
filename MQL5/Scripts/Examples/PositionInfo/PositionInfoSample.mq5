//+------------------------------------------------------------------+
//|                                           PositionInfoSample.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//|                                              Revision 2010.02.08 |
//+------------------------------------------------------------------+
#property copyright "2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//---
#include <Trade\PositionInfo.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>
//---
#include "PositionInfoSampleInit.mqh"
//+------------------------------------------------------------------+
//| Script to testing the use of class CPositionInfo.                |
//+------------------------------------------------------------------+
//---
//+------------------------------------------------------------------+
//| Position Info Sample script class                                |
//+------------------------------------------------------------------+
class CPositionInfoSample
  {
protected:
   CPositionInfo     m_position;
   //--- chart objects
   CChartObjectButton m_button_prev;
   CChartObjectButton m_button_next;
   CChartObjectLabel  m_label[19];
   CChartObjectLabel  m_label_info[19];
   //---
   int               curr_pos;
   int               total_pos;

public:
                     CPositionInfoSample();
   bool              Init();
   void              Deinit();
   void              Processing();

private:
   void              CheckButtons();
   void              InfoToChart();
  };
//---
CPositionInfoSample ExtScript;
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPositionInfoSample::CPositionInfoSample()
  {
   curr_pos =-1;
   total_pos=-1;
  }
//+------------------------------------------------------------------+
//| Method Init.                                                     |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CPositionInfoSample::Init()
  {
   int   i,sy=10;
   int   dy=16;
   color color_label;
   color color_info;
//--- tuning colors
   color_info =(color)(ChartGetInteger(0,CHART_COLOR_BACKGROUND)^0xFFFFFF);
   color_label=(color)(color_info^0x202020);
//---
   if(ChartGetInteger(0,CHART_SHOW_OHLC)) sy+=16;
//--- creation Buttons
   m_button_prev.Create(0,"ButtonPrev",0,10,sy,100,20);
   m_button_prev.Description("Prev Position");
   m_button_prev.Color(Red);
   m_button_prev.FontSize(8);
//---
   m_button_next.Create(0,"ButtonNext",0,110,sy,100,20);
   m_button_next.Description("Next Position");
   m_button_next.Color(Red);
   m_button_next.FontSize(8);
//---
   sy+=20;
//--- creation Labels[]
   for(i=0;i<13;i++)
     {
      m_label[i].Create(0,"Label"+IntegerToString(i),0,20,sy+dy*i);
      m_label[i].Description(init_str[i]);
      m_label[i].Color(color_label);
      m_label[i].FontSize(8);
      //---
      m_label_info[i].Create(0,"LabelInfo"+IntegerToString(i),0,120,sy+dy*i);
      m_label_info[i].Description(" ");
      m_label_info[i].Color(color_info);
      m_label_info[i].FontSize(8);
     }
   InfoToChart();
//--- redraw chart
   ChartRedraw();
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Method Deinit.                                                   |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CPositionInfoSample::Deinit()
  {
  }
//+------------------------------------------------------------------+
//| Method Processing.                                               |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CPositionInfoSample::Processing(void)
  {
   if(total_pos!=PositionsTotal())
     {
      total_pos=PositionsTotal();
      if(total_pos==0)
        {
         m_label_info[0].Description("0");
         m_label_info[1].Description("");
         curr_pos=-1;
         return;
        }
      else
        {
         m_label_info[0].Description(IntegerToString(total_pos));
         if(curr_pos==-1) curr_pos=0;
         if(curr_pos>=total_pos) curr_pos=total_pos-1;
         m_label_info[1].Description(IntegerToString(curr_pos));
        }
     }
   CheckButtons();
   PositionSelect(PositionGetSymbol(curr_pos));
   InfoToChart();
   //--- redraw chart
   ChartRedraw();
   Sleep(250);
  }
//+------------------------------------------------------------------+
//| Method InfoToChart.                                              |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: display position info.                                   |
//+------------------------------------------------------------------+
void CPositionInfoSample::CheckButtons()
  {
   if(m_button_prev.State())
     {
      m_button_prev.State(false);
      if(curr_pos>=0)
         m_label_info[1].Description(IntegerToString(--curr_pos));
     }
   if(m_button_next.State())
     {
      m_button_next.State(false);
      if(curr_pos<total_pos-1)
         m_label_info[1].Description(IntegerToString(++curr_pos));
     }
  }
//+------------------------------------------------------------------+
//| Function for display position info                               |
//+------------------------------------------------------------------+
void CPositionInfoSample::InfoToChart()
  {
   m_label_info[2].Description(m_position.Symbol());
   m_label_info[3].Description(TimeToString(m_position.Time()));
   m_label_info[4].Description(m_position.TypeDescription());
   m_label_info[5].Description(DoubleToString(m_position.Volume()));
   m_label_info[6].Description(DoubleToString(m_position.PriceOpen()));
   m_label_info[7].Description(DoubleToString(m_position.StopLoss()));
   m_label_info[8].Description(DoubleToString(m_position.TakeProfit()));
   m_label_info[9].Description(DoubleToString(m_position.PriceCurrent()));
   m_label_info[10].Description(DoubleToString(m_position.Commission()));
   m_label_info[11].Description(DoubleToString(m_position.Swap()));
   m_label_info[12].Description(DoubleToString(m_position.Profit()));
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
int OnStart()
  {
//--- call init function
   if(ExtScript.Init()==0)
     {
      //--- cycle until the script is not halted
      while(!IsStopped()) ExtScript.Processing();
     }
//--- call deinit function
   ExtScript.Deinit();
//---
   return(0);
  }
//+------------------------------------------------------------------+
