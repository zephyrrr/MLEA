//+------------------------------------------------------------------+
//|                                                visualhistory.mq5 |
//|                                          Copyright 2010, alohafx |
//|                                   http://alohafx.blog36.fc2.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, alohafx"
#property link      "http://alohafx.blog36.fc2.com/"
#property version   "0.01"
#property indicator_chart_window

//input bool AllSymbol=false;
input datetime start=D'2010.10.04';
//--- variables for returning values from order properties
ulong    ticket;
double   open_price[99999];
double   open_price1;
double   initial_volume[99999];
double   lots;
datetime time_filled[99999];
datetime time_filled1;
string   othersymbols,symbol;
string   type[99999];
long     order_magic[99999];
long     positionID[99999];
long     chart_id[12];
string   chart_str[12];
int      handle,symtotal;
color    Color=Blue;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//---
   return(0);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   for(int i=0; i<HistoryOrdersTotal(); i++)
      {
      ObjectDelete(0,"history"+IntegerToString(i,0,' '));
      }
   Comment("");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   for(int i=0; i<HistoryOrdersTotal(); i++)
      {
      ObjectDelete(0,"history"+IntegerToString(i,0,' '));
      }
//---
   datetime from=start;
   datetime to=TimeCurrent();
//--- request the entire history
   HistorySelect(from,to);
//--- number of current pending orders
   uint     total=HistoryOrdersTotal();
//--- go through orders in a loop
   symtotal=0;
   othersymbols="";
//   ArrayInitialize(chart_str,"");
   for(int j=0; j<12; j++) chart_str[j]="";
   for(uint i=0;i<total;i++)
     {
      //--- return order ticket by its position in the list
      if(ticket=HistoryOrderGetTicket(i))
        {
         //--- return order properties
         symbol=           HistoryOrderGetString(ticket,ORDER_SYMBOL);
         if(symbol!=Symbol()) 
            {
            /*if(AllSymbol)
               {
               chart_id[i]=ChartOpen(symbol,ChartPeriod(0));
               chart_str[i]=symbol;
               handle=iCustom(symbol,0,"VisualHistory");
               ChartIndicatorAdd(chart_id,0,handle);
               }*/
            for(int j=0; j<12; j++)
               {
               if(chart_str[j]==symbol) break;
               if(chart_str[j]=="")
                  {
                  chart_str[j]=symbol;
                  othersymbols=othersymbols+symbol+"\n";
                  break;
                  }
               }
            continue;
            }
         open_price[symtotal]=       HistoryOrderGetDouble(ticket,ORDER_PRICE_OPEN);
         time_filled[symtotal]=      HistoryOrderGetInteger(ticket,ORDER_TIME_DONE);
         order_magic[symtotal]=      HistoryOrderGetInteger(ticket,ORDER_MAGIC);
         positionID[symtotal] =      HistoryOrderGetInteger(ticket,ORDER_POSITION_ID);
         initial_volume[symtotal]=   HistoryOrderGetDouble(ticket,ORDER_VOLUME_INITIAL);
         type[symtotal]=GetOrderType(HistoryOrderGetInteger(ticket,ORDER_TYPE));
         symtotal++;
        }
     }
   //--- prepare and show information about the order
   lots=0;
   for(int i=0; i<symtotal; i++)
      {
      if(StringSubstr(type[i],0,3)=="buy") lots=lots+initial_volume[i];
      else                                 lots=lots-initial_volume[i];
      if(i==symtotal-1)
         {
         if(lots<0) open_price1=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
         else       open_price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
         time_filled1=      TimeCurrent();
         }
      else
         {
         open_price1=      open_price[i+1];
         time_filled1=     time_filled[i+1];
         }
      if(lots==0) continue;

      if( (lots>0 && open_price[i]<=open_price1) || (lots<0 && open_price[i]>=open_price1) ) Color=Blue;
      if( (lots>0 && open_price[i]>=open_price1) || (lots<0 && open_price[i]<=open_price1) ) Color=Red;
      ObjectCreate(0,"history"+IntegerToString(i,0,' '),OBJ_TREND,0,time_filled[i],open_price[i],time_filled1,open_price1);
      ObjectSetInteger(0,"history"+IntegerToString(i,0,' '),OBJPROP_COLOR,Color);
      ObjectSetInteger(0,"history"+IntegerToString(i,0,' '),OBJPROP_WIDTH,3);
     }
//---
Comment("total= ",total,"\n",
        "symtotal= ",symtotal,"\n",
        othersymbols);
  //--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  returns the string name of the order type                       |
//+------------------------------------------------------------------+
string GetOrderType(long Type)
  {
   string str_type="unknown operation";
   switch(Type)
     {
      case (ORDER_TYPE_BUY):            return("buy");
      case (ORDER_TYPE_SELL):           return("sell");
      case (ORDER_TYPE_BUY_LIMIT):      return("buy limit");
      case (ORDER_TYPE_SELL_LIMIT):     return("sell limit");
      case (ORDER_TYPE_BUY_STOP):       return("buy stop");
      case (ORDER_TYPE_SELL_STOP):      return("sell stop");
      case (ORDER_TYPE_BUY_STOP_LIMIT): return("buy stop limit");
      case (ORDER_TYPE_SELL_STOP_LIMIT):return("sell stop limit");
     }
   return(str_type);
  }
//+------------------------------------------------------------------+
