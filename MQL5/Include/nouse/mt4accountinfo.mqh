//+------------------------------------------------------------------+
//|                                                  accountinfo.mqh |
//|                                      Copyright 2009, A. Williams |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, A. Williams"
#property link      "http://www.mql5.com"

//no AccountFreeMarginMode 

double AccountBalance()
{  	
   return(AccountInfoDouble(ACCOUNT_BALANCE));
}

double AccountCredit()
{
 	return(AccountInfoDouble(ACCOUNT_CREDIT));
}

string AccountCompany()
{
 	return(AccountInfoString(ACCOUNT_COMPANY));
}

string AccountCurrency()
{
 	return(AccountInfoString(ACCOUNT_CURRENCY));
}

double AccountEquity()
{
 	return(AccountInfoDouble(ACCOUNT_EQUITY));
}
double AccountFreeMargin()
{
 	return(AccountInfoDouble(ACCOUNT_FREEMARGIN));
}
int AccountLeverage()
{
 	return(AccountInfoInteger(ACCOUNT_LEVERAGE));
}
double AccountMargin()
{
 	return(AccountInfoDouble(ACCOUNT_MARGIN));
}
string AccountName()
{
 	return(AccountInfoString(ACCOUNT_NAME));
}
int AccountNumber()
{
 	return(AccountInfoInteger(ACCOUNT_LOGIN));
}
double AccountProfit()
{
 	return(AccountInfoDouble(ACCOUNT_PROFIT));
}
string AccountServer()
{
 	return(AccountInfoString(ACCOUNT_SERVER));
}
double AccountStopoutLevel()
{
 	return(AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));
}
int AccountStopoutMode()
{
 	return(AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE));
}