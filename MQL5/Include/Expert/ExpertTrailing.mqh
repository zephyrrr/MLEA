//+------------------------------------------------------------------+
//|                                               ExpertTrailing.mqh |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                              Revision 2011.03.30 |
//+------------------------------------------------------------------+
#include "ExpertBase.mqh"
//+------------------------------------------------------------------+
//| Class CExpertTrailing.                                           |
//| Purpose: Base class traling stops.                               |
//| Derives from class CExpertBase.                                  |
//+------------------------------------------------------------------+
class CExpertTrailing : public CExpertBase
  {
public:
   //---
   virtual bool      CheckTrailingStopLong(CPositionInfo *position,double& sl,double& tp)  { return(false); }
   virtual bool      CheckTrailingStopShort(CPositionInfo *position,double& sl,double& tp) { return(false); }
  };
//+------------------------------------------------------------------+
