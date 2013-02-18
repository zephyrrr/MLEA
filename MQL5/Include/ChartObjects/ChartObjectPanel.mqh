//+------------------------------------------------------------------+
//|                                             ChartObjectPanel.mqh |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <ChartObjects\ChartObjectsTxtControls.mqh>
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayInt.mqh>
//+------------------------------------------------------------------+
//| Class CChartObjectPanel.                                         |
//| Purpose: Class for grouping objects for managing a chart         |
//+------------------------------------------------------------------+
class CChartObjectPanel : public CChartObjectButton
  {
protected:
   CArrayObj         m_attachment;       // array of attached objects
   CArrayInt         m_dX;               // array of dX attached objects
   CArrayInt         m_dY;               // array of dY attached objects
   bool              m_expanded;         // collapsed/expanded flag

public:
                     CChartObjectPanel();
                    ~CChartObjectPanel();
   //--- method for attaching objects
   bool              Attach(CChartObjectLabel *chart_object);
   bool              X_Distance(int X);
   bool              Y_Distance(int Y);
   int               X_Size() const;
   int               Y_Size() const;
   virtual bool      Timeframes(int timeframes);
   bool              State(bool state);
   bool              CheckState();

protected:
  };
//+------------------------------------------------------------------+
//| Constructor.                                                     |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CChartObjectPanel::CChartObjectPanel(void)
  {
   m_expanded=true;
  }
//+------------------------------------------------------------------+
//| Destructor.                                                      |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CChartObjectPanel::~CChartObjectPanel(void)
  {
//--- All objects added by the method Add(), deleted automatically
  }
//+------------------------------------------------------------------+
//| Method CheckPanelModes.                                          |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CChartObjectPanel::Attach(CChartObjectLabel *chart_object)
  {
   if(m_attachment.Add(chart_object))
     {
      int x,y;
      x=chart_object.X_Distance();
      m_dX.Add(chart_object.X_Distance());
      x+=X_Distance();
      chart_object.X_Distance(X_Distance()+chart_object.X_Distance());
      y=CChartObjectButton::Y_Size();
      y+=chart_object.Y_Distance();
      m_dY.Add(chart_object.Y_Distance()+CChartObjectButton::Y_Size()+2);
      chart_object.Y_Distance(Y_Distance()+chart_object.Y_Distance()+CChartObjectButton::Y_Size()+2);
      return(true);
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Method CheckPanelModes.                                          |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CChartObjectPanel::X_Distance(int X)
  {
   CChartObjectLabel *chart_object;
//---
   for(int i=0;i<m_attachment.Total();i++)
     {
      chart_object=m_attachment.At(i);
      chart_object.X_Distance(X+m_dX.At(i));
     }
//---
   return(CChartObjectButton::X_Distance(X));
  }
//+------------------------------------------------------------------+
//| Method CheckPanelModes.                                          |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CChartObjectPanel::Y_Distance(int Y)
  {
   CChartObjectLabel *chart_object;
//---
   for(int i=0;i<m_attachment.Total();i++)
     {
      chart_object=m_attachment.At(i);
      chart_object.Y_Distance(Y+m_dY.At(i));
     }
//---
   return(CChartObjectButton::Y_Distance(Y));
  }
//+------------------------------------------------------------------+
//| Method CheckPanelModes.                                          |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
int CChartObjectPanel::X_Size() const
  {
   int                max_x=CChartObjectButton::X_Size()+X_Distance();
   CChartObjectLabel *chart_object;
//---
   if(m_expanded)
     {
      for(int i=0;i<m_attachment.Total();i++)
        {
         if((chart_object=m_attachment.At(i))!=NULL)
           {
            if(max_x<chart_object.X_Distance()+chart_object.X_Size())
               max_x=chart_object.X_Distance()+chart_object.X_Size();
           }
        }
      return(max_x-X_Distance()+2);
     }
//---
   return(CChartObjectButton::X_Size()+2);
  }
//+------------------------------------------------------------------+
//| Method CheckPanelModes.                                          |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
int CChartObjectPanel::Y_Size() const
  {
   int                max_y=CChartObjectButton::Y_Size()+Y_Distance();
   CChartObjectLabel *chart_object;
//---
   if(m_expanded)
     {
      for(int i=0;i<m_attachment.Total();i++)
        {
         if((chart_object=m_attachment.At(i))!=NULL)
           {
            if(max_y<chart_object.Y_Distance()+chart_object.Y_Size())
               max_y=chart_object.Y_Distance()+chart_object.Y_Size();
           }
        }
      return(max_y-Y_Distance()+2);
     }
//---
   return(CChartObjectButton::Y_Size()+2);
  }
//+------------------------------------------------------------------+
//| Method CheckPanelModes.                                          |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CChartObjectPanel::Timeframes(int timeframes)
  {
   int                i;
   bool               res=CChartObject::Timeframes(timeframes);
   CChartObjectLabel *chart_object;
//---
   if(m_expanded)
   for(i=0;i<m_attachment.Total();i++)
     {
      chart_object=m_attachment.At(i);
      res&=chart_object.Timeframes(timeframes);
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| Method CheckPanelModes.                                          |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CChartObjectPanel::State(bool state)
  {
   if(CChartObjectButton::State(state))
     {
      m_expanded=state;
      return(true);
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Method CheckPanelModes.                                          |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CChartObjectPanel::CheckState(void)
  {
   int                i;
   CChartObjectLabel *chart_object;
//---
   if(m_expanded!=State())
     {
      if(m_expanded=State())
        {
         //--- make all objects visible
         for(i=0;i<m_attachment.Total();i++)
           {
            chart_object=m_attachment.At(i);
            chart_object.Timeframes(-1);
           }
        }
      else
        {
         //--- make all objects invisible
         for(i=0;i<m_attachment.Total();i++)
           {
            chart_object=m_attachment.At(i);
            chart_object.Timeframes(0x100000);
           }
        }
      return(true);
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
