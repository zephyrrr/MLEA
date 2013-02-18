//+------------------------------------------------------------------+
//|                                                Lib CisNewBar.mqh |
//|                                            Copyright 2010, Lizar |
//|                                               Lizar-2010@mail.ru |
//|                                              Revision 2010.09.27 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Class CisNewBar.                                                 |
//| Appointment: Class with methods of detecting new bars            |
//+------------------------------------------------------------------+

class CisNewBar 
  {
   protected:
      datetime          m_lastbar_time;   // Time of opening last bar

      string            m_symbol;         // Symbol name
      ENUM_TIMEFRAMES   m_period;         // Chart period
      
      uint              m_retcode;        // Result code of detecting new bar 
      int               m_new_bars;       // Number of new bars
      string            m_comment;        // Comment of execution
      
   public:
      void              CisNewBar();      // CisNewBar constructor      
      //--- Methods of access to protected data:
      uint              GetRetCode() const      {return(m_retcode);     }  // Result code of detecting new bar 
      datetime          GetLastBarTime() const  {return(m_lastbar_time);}  // Time of opening new bar
      int               GetNewBars() const      {return(m_new_bars);    }  // Number of new bars
      string            GetComment() const      {return(m_comment);     }  // Comment of execution
      string            GetSymbol() const       {return(m_symbol);      }  // Symbol name
      ENUM_TIMEFRAMES   GetPeriod() const       {return(m_period);      }  // Chart period
      //--- Methods of initializing protected data:
      void              SetLastBarTime(datetime lastbar_time){m_lastbar_time=lastbar_time;                            }
      void              SetSymbol(string symbol)             {m_symbol=(symbol==NULL || symbol=="")?Symbol():symbol;  }
      void              SetPeriod(ENUM_TIMEFRAMES period)    {m_period=(period==PERIOD_CURRENT)?Period():period;      }
      //--- Methods of detecting new bars:
      bool              isNewBar(datetime new_Time);                       // First type of request for new bar
      int               isNewBar();                                        // Second type of request for new bar 
  };
   
//+------------------------------------------------------------------+
//| CisNewBar constructor.                                           |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CisNewBar::CisNewBar()
  {
   m_retcode=0;         // Result code of detecting new bar 
   m_lastbar_time=0;    // Time of opening last bar
   m_new_bars=0;        // Number of new bars
   m_comment="";        // Comment of execution
   m_symbol=Symbol();   // Symbol name, by default - symbol of current chart
   m_period=Period();   // Chart period, by default - period of current chart    
  }

//+------------------------------------------------------------------+
//| First type of request for new bar                     |
//| INPUT:  newbar_time - time of opening (hypothetically) new bar|
//| OUTPUT: true   - if new bar(s) has(ve) appeared                  |
//|         false  - if there is no new bar or in case of error      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CisNewBar::isNewBar(datetime newbar_time)
  {
   //--- Initialization of protected variables
   m_new_bars = 0;      // Number of new bars
   m_retcode  = 0;      // Result code of detecting new bar: 0 - no error
   m_comment  =__FUNCTION__+" Successful check for new bar";
   //---
   
   //--- Just to be sure, check: is the time of (hypothetically) new bar m_newbar_time less than time of last bar m_lastbar_time? 
   if(m_lastbar_time>newbar_time)
     { // If new bar is older than last bar, print error message
      m_comment=__FUNCTION__+" Synchronization error: time of previous bar "+TimeToString(m_lastbar_time)+
                                                  ", time of new bar request "+TimeToString(newbar_time);
      m_retcode=-1;     // Result code of detecting new bar: return -1 - synchronization error
      
      Print(m_comment);
      return(false);
     }
   //---
        
   //--- if it's the first call 
   if(m_lastbar_time==0)
     {  
      m_lastbar_time=newbar_time; //--- set time of last bar and exit
      m_comment   =__FUNCTION__+" Initialization of lastbar_time = "+TimeToString(m_lastbar_time);
      
      Print(m_comment);
      return(false);
     }   
   //---

   //--- Check for new bar: 
   if(m_lastbar_time<newbar_time)       
     { 
      m_new_bars=1;               // Number of new bars
      m_lastbar_time=newbar_time; // remember time of last bar
      return(true);
     }
   //---
   
   //--- if we've reached this line, then the bar is not new; return false
   return(false);
  }

//+------------------------------------------------------------------+
//| Second type of request for new bar                     |
//| INPUT:  no.                                                      |
//| OUTPUT: m_new_bars - Number of new bars                          |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
int CisNewBar::isNewBar()
  {
   datetime newbar_time;
   datetime lastbar_time=m_lastbar_time;
      
   //--- Request time of opening last bar:
   ResetLastError(); // Set value of predefined variable _LastError as 0.
   if(!SeriesInfoInteger(m_symbol,m_period,SERIES_LASTBAR_DATE,newbar_time))
     { // If request has failed, print error message:
      m_retcode=GetLastError();  // Result code of detecting new bar: write value of variable _LastError
      m_comment=__FUNCTION__+" Error when getting time of last bar opening: "+IntegerToString(m_retcode);
      
      Print(m_comment);
      return(0);
     }
   //---
   
   //---Next use first type of request for new bar, to complete analysis:
   if(!isNewBar(newbar_time)) return(0);
   
   //---Correct number of new bars:
   m_new_bars=Bars(m_symbol,m_period,lastbar_time,newbar_time)-1;

   //--- If we've reached this line - then there is(are) new bar(s), return their number:
   return(m_new_bars);
  }
  
