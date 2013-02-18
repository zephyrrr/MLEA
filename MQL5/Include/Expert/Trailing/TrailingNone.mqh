//+------------------------------------------------------------------+
//|                                                 TrailingNone.mqh |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                              Revision 2010.10.08 |
//+------------------------------------------------------------------+
#include <Expert\ExpertTrailing.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Trailing Stop not used                                     |
//| Type=Trailing                                                    |
//| Name=None                                                        |
//| Class=CTrailingNone                                              |
//| Page=                                                            |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CTrailingNone.                                             |
//| Appointment: Class no traling stops.                             |
//|              Derives from class CExpertTrailing.                 |
//+------------------------------------------------------------------+
class CTrailingNone : public CExpertTrailing
  {
public:
   virtual bool      CheckTrailingStopLong(CPositionInfo* position,double& sl,double& tp)  { return (false); }
   virtual bool      CheckTrailingStopShort(CPositionInfo* position,double& sl,double& tp) { return (false); }
  };
//+------------------------------------------------------------------+
