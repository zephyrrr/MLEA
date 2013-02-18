//+------------------------------------------------------------------+
//|                                            VisualHistoryDeal.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

input datetime start=D'2010.10.04';
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   return(0);
  }
  
int m_historyDealCnt = 0;
bool m_created = false;

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    for(int i=0; i<m_historyDealCnt; i++)
    {
        ObjectDelete(0, "HistoryDealArrow" + IntegerToString(i, 0, ' '));
    }
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    if (m_created)
        return;
        
    datetime from=start;
    datetime to=TimeCurrent();
    HistorySelect(from,to);
    uint total=HistoryDealsTotal();
    for(uint i=0;i<total;i++)
    {
        int ticket = 0;
        if(ticket = HistoryDealGetTicket(i))
        {
            string symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
            if(symbol == Symbol())
            {
                double openPrice = HistoryDealGetDouble(ticket,DEAL_PRICE);
                int timeFilled = HistoryDealGetInteger(ticket,DEAL_TIME);
                double volumn = HistoryDealGetDouble(ticket, DEAL_VOLUME);
                string dealType = GetDealType(HistoryDealGetInteger(ticket, DEAL_TYPE));
                 
                string comment = "#" + IntegerToString(ticket) + " " + dealType + " " + DoubleToString(volumn, 2) + " "
                    + symbol + " at " + openPrice;
                    
                color col;
                if (dealType == "Buy")
                    col = Blue;
                else
                    col = Red;
                ObjectCreate(0, "HistoryDealArrow"+IntegerToString(i,0,' '), 
                    OBJ_ARROW, 0, timeFilled, openPrice);
                ObjectSetInteger(0,"HistoryDealArrow"+IntegerToString(i,0,' '), OBJPROP_COLOR, col);
            }
        }
    }
    
    m_created = true;
}
//+------------------------------------------------------------------+
string GetDealType(long Type)
  {
   string str_type="unknown operation";
   switch(Type)
     {
      case (DEAL_TYPE_BUY):            return("Buy");
      case (DEAL_TYPE_SELL):           return("Sell");
     }
   return(str_type);
  }