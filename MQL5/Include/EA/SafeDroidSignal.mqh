//+------------------------------------------------------------------+
//|                                              SafeDroidSignal.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

#include <ExpertModel\ExpertModel.mqh>
#include <ExpertModel\ExpertModelSignal.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\DealInfo.mqh>

#include <Indicators\Oscilators.mqh>
#include <Indicators\TimeSeries.mqh>
#include "SafeDroidLib.mqh"

// EURUSD, M30
class CSafeDroidSignal : public CExpertModelSignal
{
private:
	CiMA m_iMA_16, m_iMA_8, m_iMA_32;
	CiRSI m_iRSI_24;
	CiMomentum m_iMomentum_32;
	CiAC m_iAC_40;
	CiRVI m_iRVI_48;
	CiOpen m_iOpen;
	CiClose m_iClose;
	bool GetOpenSignal(int wantSignal);

	int gi_PointTen;
	string gs_RegCode;
	int g_acc_number_168;
	int License_Number;
	string User_Login;
	string User_Password;
	int Strategy_ID;
	int Transaction_Level;

	int gi_160;
	int gi_276;
	double gd_232, gd_240;
	int g_bars_252, g_bars_256, g_bars_248, g_bars_260;
	int gi_172, gi_176;

	int gi_216, gi_220, gi_224, gi_228;
	int gi_208, gi_204;
	int gi_280;
	double gd_264;

public:
	CSafeDroidSignal();
	~CSafeDroidSignal();
	virtual bool      ValidationSettings();
	virtual bool      InitIndicators(CIndicators* indicators);

	virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
	virtual bool      CheckCloseLong(CTableOrder* t, double& price);
	virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
	virtual bool      CheckCloseShort(CTableOrder* t, double& price);

	void InitParameters();
};

void CSafeDroidSignal::InitParameters()
{
	int Stop_Loss = 150;
	int Expected_Profit = 50;
	Transaction_Level = 2;

	gi_PointTen = 1;
	//gs_RegCode = "12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234";
	gs_RegCode = "";
	g_acc_number_168 = 2858348;
	License_Number = 0;
	User_Login = "User";
	User_Password = "Pwd";
	Strategy_ID = 192837;
	gi_160 = 1;

	double l_point_8 = m_symbol.Point();
	if (100000.0 * l_point_8 == 1.0) gi_PointTen = 10;
	else gi_PointTen = 1;

	int gi_136 = Stop_Loss;
	int gi_144 = Stop_Loss;
	gi_208 = 0;
	gi_216 = 0;
	gi_220 = 0;
	gi_224 = 0;
	gi_228 = 0;
	int gi_140 = Expected_Profit + 1;
	int gi_148 = Expected_Profit + 1;
	gi_208 = gi_PointTen * Expected_Profit;
	gi_216 = gi_PointTen * gi_136;
	gi_220 = gi_PointTen * gi_140;
	gi_224 = gi_PointTen * gi_144;
	gi_228 = gi_PointTen * gi_148;
	//gs_284 = Order_Size;
}

void CSafeDroidSignal::CSafeDroidSignal()
{
}

void CSafeDroidSignal::~CSafeDroidSignal()
{
}
bool CSafeDroidSignal::ValidationSettings()
{
	if(!CExpertSignal::ValidationSettings()) 
		return(false);

	if(false)
	{
		printf(__FUNCTION__+": Indicators should not be Null!");
		return(false);
	}
	return(true);
}

bool CSafeDroidSignal::InitIndicators(CIndicators* indicators)
{
	if(indicators==NULL) 
		return(false);
	bool ret = true;

	ret &= m_iMA_16.Create(m_symbol.Name(), m_period, 24, 8, MODE_SMA, PRICE_CLOSE);
	ret &= m_iMA_8.Create(m_symbol.Name(), m_period, 12, 6, MODE_SMA, PRICE_CLOSE);
	ret &= m_iRSI_24.Create(m_symbol.Name(), m_period, 5, PRICE_CLOSE);
	ret &= m_iMomentum_32.Create(m_symbol.Name(), m_period, 12, PRICE_CLOSE);
	ret &= m_iAC_40.Create(m_symbol.Name(), m_period);
	ret &= m_iRVI_48.Create(m_symbol.Name(), m_period, 12);
	ret &= m_iOpen.Create(m_symbol.Name(), m_period);
	ret &= m_iClose.Create(m_symbol.Name(), m_period);
	ret &= m_iMA_32.Create(m_symbol.Name(), m_period, 12, 3, MODE_SMA, PRICE_CLOSE);

	ret &= indicators.Add(GetPointer(m_iMA_16));
	ret &= indicators.Add(GetPointer(m_iMA_8));
	ret &= indicators.Add(GetPointer(m_iRSI_24));
	ret &= indicators.Add(GetPointer(m_iMomentum_32));
	ret &= indicators.Add(GetPointer(m_iAC_40));
	ret &= indicators.Add(GetPointer(m_iRVI_48));
	ret &= indicators.Add(GetPointer(m_iOpen));
	ret &= indicators.Add(GetPointer(m_iClose));
	ret &= indicators.Add(GetPointer(m_iMA_32));

	return ret;
}


bool CSafeDroidSignal::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
{
    return false;
    
	CExpertModel* em = (CExpertModel *)m_expert;

	gi_172 = 1;
	gi_176 = 1;
	//gi_172 = ccttll(Transaction_Level, 0, gs_RegCode, g_acc_number_168, License_Number, User_Login, User_Password, gi_160);
	//gi_176 = ccttll(Transaction_Level, 1, gs_RegCode, g_acc_number_168, License_Number, User_Login, User_Password, gi_160);
	bool gi_268 = true;

	//if (gi_152 != 1) 
	{
		if (em.GetOrderCount(ORDER_TYPE_BUY) > 0) {
			gi_268 = true;
		}
		if (em.GetOrderCount(ORDER_TYPE_SELL) > 0) {
			gi_268 = false;
		}
	}

	int li_68 = em.GetOrderCount(ORDER_TYPE_BUY);

	double l_ima_16 = m_iMA_16.Main(0); //iMA(NULL, 0, 24, 8, MODE_SMA, PRICE_CLOSE, 0);
	double l_ima_8 = m_iMA_8.Main(0); //iMA(NULL, 0, g_period_188, gd_196, MODE_SMA, PRICE_CLOSE, 0);
	double l_irsi_24 = m_iRSI_24.Main(0); //iRSI(NULL, 0, 5, PRICE_CLOSE, 0);
	double l_imomentum_32 = m_iMomentum_32.Main(0); //iMomentum(NULL, 0, 12, PRICE_CLOSE, 0);
	double l_iac_40 = m_iAC_40.Main(5); //iAC(NULL, Period(), 5);
	double l_irvi_48 = m_iRVI_48.Main(0); //iRVI(NULL, 0, 12, MODE_MAIN, 0);

	int condition1;
	//condition1 = oobbpp(l_ima_16, l_ima_8, l_irsi_24, l_imomentum_32, l_irvi_48, gi_PointTen, m_symbol.Point(), 
	//    m_iOpen.GetData(0), m_iClose.GetData(0), m_iOpen.GetData(1), m_iClose.GetData(1), 
	//    gs_RegCode, g_acc_number_168, License_Number, User_Login, User_Password, gi_160);
	//Print("condition1 = ", condition1);
	if (m_iClose.GetData(0) <= m_iOpen.GetData(0) || m_iClose.GetData(1) <= m_iOpen.GetData(1) 
		|| (double)(10 * gi_PointTen) * m_symbol.Point() >= m_iClose.GetData(1) - m_iOpen.GetData(1) )
		condition1 = 0;
	else
		condition1 = 1;

 //   if (TimeCurrent() == D'2008.09.26 16:00:13')
	//{
 //   	Print(m_iOpen.GetData(0), ", ", m_iClose.GetData(0), ", ", m_iOpen.GetData(1), ", ", m_iClose.GetData(1));
 //   	Print(condition1);
	//}
	
	if (condition1 == 1) {

		gi_276 = li_68;
		int bars = Bars(m_symbol.Name(), m_period);
		//gd_232 = bbmmpp(l_ima_16, l_iac_40, l_irvi_48, li_68, bars, g_bars_252, gd_232, 
		//  m_symbol.Ask(), gi_PointTen, m_iClose.GetData(1), m_symbol.Point(), 
		//  gs_RegCode, g_acc_number_168, License_Number, User_Login, User_Password, gi_160);

        //if (TimeCurrent() == D'2008.09.26 16:00:13')
		//{
		//    Print(m_symbol.Ask(), ",", gd_232);
		//}
		double v21 = 80 * m_symbol.Point();//(double)(int)sub_10001540(gi_PointTen) * m_symbol.Point();
		if ( !li_68 && bars - g_bars_252 > 0 && gd_232 > 0.0 && m_symbol.Ask() - gd_232 < v21 || gd_232 == 0.0 )
			gd_232 = m_iClose.GetData(1) + 10000.0;
        //gd_232 = m_iClose.GetData(1) + 10000.0;

		int condition2;
		//condition2 = ooobbb(l_iac_40, l_ima_16, m_iClose.GetData(0), l_ima_8, li_68, gi_172, m_iClose.GetData(1), 
		//  m_symbol.Ask(), gd_232, bars, g_bars_256, l_irsi_24, l_imomentum_32, gi_268, g_bars_252, g_bars_248, gs_RegCode, 
		//  g_acc_number_168, License_Number, User_Login, User_Password, gi_160);

		if (m_iClose.GetData(0) <=l_ima_8
			|| li_68 >= gi_172
			|| m_iClose.GetData(1) <= l_ima_8
			|| m_symbol.Ask() >= gd_232
			|| bars <= g_bars_256 + 1
			|| l_irsi_24 <= 52.0
			|| l_irsi_24 >= 60.0
			|| l_imomentum_32 <= 100.0)
		{
			condition2 = 0;
		}
		else
		{
			condition2 = 1;

			if (gi_268 != 1
				|| bars <= g_bars_252 + 4 )
				condition2 = 0;
		}

        //f (TimeCurrent() == D'2008.09.26 16:00:13')
		//{
		//    Print(bars, ",", gd_232, ",", condition2);
		//    Print(m_iClose.GetData(0), ",", l_ima_8, ",", m_iClose.GetData(1), ",", l_irsi_24, ",", l_imomentum_32, ",", m_symbol.Ask());
		//}
		
		if (condition2 == 1) {
			double l_price_104 = 0;
			double l_price_112 = 0;
			m_symbol.RefreshRates();
			if (gi_216 == 0) l_price_104 = 0;
			else l_price_104 = m_symbol.Ask() - gi_216 * m_symbol.Point();
			l_price_104 = NormalizeDouble(l_price_104, m_symbol.Digits());
			if (gi_220 == 0) l_price_112 = 0;
			else l_price_112 = m_symbol.Ask() + gi_220 * m_symbol.Point();
			l_price_112 = NormalizeDouble(l_price_112, m_symbol.Digits());
			//int li_120 = bbnnpp(gi_172, gs_RegCode, g_acc_number_168, License_Number, User_Login, User_Password, gi_160);

			price = m_symbol.Ask();
			sl = l_price_104;
			tp = l_price_112;

			//gi_264 = false;
			g_bars_256 = bars;

			return true;
			/*for (int l_count_124 = 0; l_count_124 < li_120; l_count_124++) {
			if (CountOrders(OP_BUY) < gi_172) {
			l_ticket_56 = OrderSend(Symbol(), OP_BUY, Set_Lots(), NormalizeDouble(Ask, Digits), 5, l_price_104, l_price_112, l_magic_0, g_magic_76, 0, Blue);
			if (l_ticket_56 < 0) {
			Print("Order Send Error: " + GetLastError() + " Send Again");
			Sleep(500);
			RefreshRates();
			l_ticket_60 = OrderSend(Symbol(), OP_BUY, Set_Lots(), NormalizeDouble(Ask, Digits), 5, l_price_104, l_price_112, l_magic_0, g_magic_76, 0, Blue);
			if (l_ticket_60 < 0) {
			l_error_128 = GetLastError();
			if (l_error_128 == 130) {
			Sleep(300);
			RefreshRates();
			l_ticket_132 = OrderSend(Symbol(), OP_BUY, Set_Lots(), NormalizeDouble(Ask, Digits), 5, 0, 0, l_magic_0, g_magic_76, 0, Blue);
			if (l_ticket_132 > 0) {
			Sleep(100);
			OrderModify(l_ticket_132, OrderOpenPrice(), l_price_104, l_price_112, 0, Red);
			gi_264 = FALSE;
			g_bars_256 = Bars;
			}
			}
			} else {
			gi_264 = FALSE;
			g_bars_256 = Bars;
			}
			} else {
			gi_264 = FALSE;
			g_bars_256 = Bars;
			}
			RefreshRates();
			}
			}*/
		}
	}
	return false;
}

bool CSafeDroidSignal::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
{
    //return false;

	CExpertModel* em = (CExpertModel *)m_expert;

	gi_172 = 1;
	gi_176 = 1;
	//gi_172 = ccttll(Transaction_Level, 0, gs_RegCode, g_acc_number_168, License_Number, User_Login, User_Password, gi_160);
	//gi_176 = ccttll(Transaction_Level, 1, gs_RegCode, g_acc_number_168, License_Number, User_Login, User_Password, gi_160);

	bool gi_264 = true;
	//if (gi_152 != 1) 
	{
		if (em.GetOrderCount(ORDER_TYPE_BUY) > 0) {
			gi_264 = false;
		}
		if (em.GetOrderCount(ORDER_TYPE_SELL) > 0) {
			gi_264 = true;
		}
	}

	int li_64 = em.GetOrderCount(ORDER_TYPE_SELL);

	double l_ima_16 = m_iMA_16.Main(0); //iMA(NULL, 0, 24, 8, MODE_SMA, PRICE_CLOSE, 0);
	double l_ima_8 = m_iMA_8.Main(0); //iMA(NULL, 0, g_period_188, gd_196, MODE_SMA, PRICE_CLOSE, 0);
	double l_irsi_24 = m_iRSI_24.Main(0); //iRSI(NULL, 0, 5, PRICE_CLOSE, 0);
	double l_imomentum_32 = m_iMomentum_32.Main(0); //iMomentum(NULL, 0, 12, PRICE_CLOSE, 0);
	double l_iac_40 = m_iAC_40.Main(5); //iAC(NULL, Period(), 5);
	double l_irvi_48 = m_iRVI_48.Main(0); //iRVI(NULL, 0, 12, MODE_MAIN, 0);

	int condidion1;
	//condition1 = oosspp(l_ima_16, l_ima_8, l_irsi_24, l_imomentum_32, l_irvi_48, gi_PointTen, m_symbol.Point(), 
	//    m_iOpen.GetData(0), m_iClose.GetData(0), m_iOpen.GetData(1), m_iClose.GetData(1), gs_RegCode, 
	//    g_acc_number_168, License_Number, User_Login, User_Password, gi_160);
	//Print("contidion1 = ", contidion1);
	if ( m_iClose.GetData(0) >= m_iOpen.GetData(0) || m_iClose.GetData(1) >= m_iOpen.GetData(1) 
		|| (double)(10 * gi_PointTen) * m_symbol.Point() >= m_iOpen.GetData(1) - m_iClose.GetData(1) )
		condidion1 = 0;
	else
		condidion1 = 1;

	if (condidion1 == 1) {

		gi_280 = li_64;
		int bars = Bars(m_symbol.Name(), m_period);

		//gd_240 = ssmmpp(l_ima_16, l_iac_40, l_irvi_48, li_64, bars, g_bars_248, gd_240, m_symbol.Bid(), gi_PointTen, 
		//  m_iClose.GetData(1), m_symbol.Point(), gs_RegCode, g_acc_number_168, License_Number, User_Login, User_Password, gi_160);
		double v20 = 80 * m_symbol.Point(); //(double)(int)sub_10001540(gi_PointTen) * m_symbol.Point();
		
		if ( !li_64 && bars - g_bars_248 > 0 /*&& gd_240 > 0*/ && gd_240 - m_symbol.Bid() < v20)
		{
		    gd_240 = 0;
		}
		if (gd_240 == 0.0)
			gd_240 = m_iClose.GetData(1) - 10000.0;
        
		//if (TimeCurrent() == D'2010.01.04 07:46:34')
		//      Print(l_iac_40, ", ", l_ima_16, ", ", m_iClose.GetData(0), ", ", l_ima_8, ", ", li_64, ", ", gi_176, ", ", m_iClose.GetData(1), ", ", m_symbol.Bid(), ", ", gd_240, ", ", bars, ", ", g_bars_260, ", ", l_irsi_24, ", ", l_imomentum_32, ", ", gi_264, ", ", g_bars_248, ", ", g_bars_252, ", ", gs_RegCode, ", ", g_acc_number_168, ", ", License_Number, ", ", User_Login, ", ", User_Password, ", ", gi_160);

		int condition2;
		//condition2 = ooosss(l_iac_40, l_ima_16, m_iClose.GetData(0), l_ima_8, li_64, gi_176, m_iClose.GetData(1), m_symbol.Bid(), 
		//  gd_240, bars, g_bars_260, l_irsi_24, l_imomentum_32, gi_264, g_bars_248, g_bars_252, 
		//  gs_RegCode, g_acc_number_168, License_Number, User_Login, User_Password, gi_160);
		
		if (m_iClose.GetData(0) >= l_ima_8
			|| li_64 >= gi_176
			|| m_iClose.GetData(1) >= l_ima_8
			|| m_symbol.Bid() <= gd_240
			|| bars <= g_bars_260 + 1
			|| l_irsi_24 <= 40.0
			|| l_irsi_24 >= 48.0
			|| l_imomentum_32 >= 100.0)
		{
		    //Debug("Condition2 = 0(1)");
		    /*if (m_iClose.GetData(0) < l_ima_8
			&& m_iClose.GetData(1) < l_ima_8
			&& l_irsi_24 > 40.0)
			{
    		    Print("here, " + gd_240);
		    }*/
		      
			condition2 = 0;
		}
		else
		{
			condition2 = 1;
			if (gi_264 != 1
				|| bars <= g_bars_248 + 4 )
		    {
				condition2 = 0;
				//Debug("Condition2 = 0(2)");
		    }
		}

        /*Debug("condition2 = " + condition2 + ", " + gd_240);
		Debug(l_iac_40 + ", " + l_ima_16 + ", " + m_iClose.GetData(0) + ", " + l_ima_8 + ", " + li_64 
		    + ", " + gi_176 + ", " + m_iClose.GetData(1) + ", " + m_symbol.Bid() + ", " + gd_240 + ", " + bars +  ", " 
		    + g_bars_260 + ", " + l_irsi_24 + ", " + l_imomentum_32 + ", " + gi_264 + ", " + g_bars_248 + ", " 
		    + g_bars_252 + "," + gi_160);
		*/
		if (condition2 == 1) 
		{
			//Print(l_iac_40, ", ", l_ima_16, ", ", m_iClose.GetData(0), ", ", l_ima_8, ", ", li_64, ", ", gi_176, ", ", m_iClose.GetData(1), ", ", m_symbol.Bid(), ", ", gd_240, ", ", bars, ", ", g_bars_260, ", ", l_irsi_24, ", ", l_imomentum_32, ", ", gi_264, ", ", g_bars_248, ", ", g_bars_252, ", ", gs_RegCode, ", ", g_acc_number_168, ", ", License_Number, ", ", User_Login, ", ", User_Password, ", ", gi_160);

			double l_price_72 = 0;
			double l_price_80 = 0;
			m_symbol.RefreshRates();
			if (gi_224 == 0) l_price_72 = 0;
			else l_price_72 = m_symbol.Bid() + gi_224 * m_symbol.Point();
			l_price_72 = NormalizeDouble(l_price_72, m_symbol.Digits());
			if (gi_228 == 0) l_price_80 = 0;
			else l_price_80 = m_symbol.Bid() - gi_228 * m_symbol.Point();
			l_price_80 = NormalizeDouble(l_price_80, m_symbol.Digits());
			//int li_88 = ssnnpp(gi_176, gs_RegCode, g_acc_number_168, License_Number, User_Login, User_Password, gi_160);

			price = m_symbol.Bid();
			sl = l_price_72;
			tp = l_price_80;

			//gi_268 = false;
			g_bars_260 = bars;
			return true;

			/*for (int l_count_92 = 0; l_count_92 < li_88; l_count_92++) {
			if (CountOrders(OP_SELL) < gi_176) {
			l_ticket_56 = OrderSend(Symbol(), OP_SELL, Set_Lots(), NormalizeDouble(Bid, Digits), 5, l_price_72, l_price_80, l_magic_0, g_magic_76, 0, Red);
			if (l_ticket_56 < 0) {
			Print("Order Sell Error: " + GetLastError() + " Send Again");
			Sleep(500);
			RefreshRates();
			l_ticket_60 = OrderSend(Symbol(), OP_SELL, Set_Lots(), NormalizeDouble(Bid, Digits), 5, l_price_72, l_price_80, l_magic_0, g_magic_76, 0, Red);
			if (l_ticket_60 < 0) {
			l_error_96 = GetLastError();
			if (l_error_96 == 130) {
			Sleep(300);
			RefreshRates();
			l_ticket_100 = OrderSend(Symbol(), OP_SELL, Set_Lots(), NormalizeDouble(Bid, Digits), 5, 0, 0, l_magic_0, g_magic_76, 0, Red);
			if (l_ticket_100 > 0) {
			Sleep(100);
			OrderModify(l_ticket_100, OrderOpenPrice(), l_price_72, l_price_80, 0, Red);
			gi_268 = FALSE;
			g_bars_260 = Bars;
			}
			}
			} else {
			gi_268 = FALSE;
			g_bars_260 = Bars;
			}
			} else {
			gi_268 = FALSE;
			g_bars_260 = Bars;
			}
			RefreshRates();
			}
			}*/
		}
	}
	return false;
}

bool CSafeDroidSignal::CheckCloseLong(CTableOrder* t, double& price)
{
	CExpertModel* em = (CExpertModel *)m_expert;

	double ld_52 = gi_208 * m_symbol.Point();
	ld_52 = NormalizeDouble(ld_52, m_symbol.Digits());

	double l_ima_32 = m_iMA_32.Main(0); //iMA(NULL, 0, 12, 3, MODE_SMA, PRICE_CLOSE, 0);
	double l_ima_16 = m_iMA_8.Main(0); //iMA(NULL, 0, g_period_188, gd_196, MODE_SMA, PRICE_CLOSE, 0);
	double l_irsi_24 = m_iRSI_24.Main(0); //iRSI(NULL, 0, 5, PRICE_CLOSE, 0);
	double l_imomentum_40 = m_iMomentum_32.Main(0); //iMomentum(NULL, 0, 12, PRICE_CLOSE, 0);

	double l_ord_open_price_104 = t.Price();
	int li_112 = (int)(TimeCurrent() - t.TimeSetup());
	
	int condition1 = bbccoo(l_ima_32, l_irsi_24, l_imomentum_40, l_ima_16, l_ord_open_price_104, 
		m_iClose.GetData(0), m_symbol.Bid(), ld_52, m_symbol.Bid() - t.Price(), gi_204, li_112, 
		m_symbol.Point(), gi_PointTen, gs_RegCode, g_acc_number_168, License_Number, User_Login, User_Password, gi_160);
	
	if (condition1 == 1) 
	{

		price = m_symbol.Bid();

		gd_232 = price;
		g_bars_252 = Bars(m_symbol.Name(), m_period);
		return true;
	}

	return false;
}

bool CSafeDroidSignal::CheckCloseShort(CTableOrder* t, double& price)
{
	CExpertModel* em = (CExpertModel *)m_expert;

	double ld_52 = gi_208 * m_symbol.Point();
	ld_52 = NormalizeDouble(ld_52, m_symbol.Digits());

	double l_ima_32 = m_iMA_32.Main(0); //iMA(NULL, 0, 12, 3, MODE_SMA, PRICE_CLOSE, 0);
	double l_ima_16 = m_iMA_8.Main(0); //iMA(NULL, 0, g_period_188, gd_196, MODE_SMA, PRICE_CLOSE, 0);
	double l_irsi_24 = m_iRSI_24.Main(0); //iRSI(NULL, 0, 5, PRICE_CLOSE, 0);
	double l_imomentum_40 = m_iMomentum_32.Main(0); //iMomentum(NULL, 0, 12, PRICE_CLOSE, 0);

	double l_ord_open_price_88 = t.Price();
	int li_96 = (int)(TimeCurrent() - t.TimeSetup());
	
	int condition1 = ssccoo(l_ima_32, l_irsi_24, l_imomentum_40, l_ima_16, l_ord_open_price_88, 
		m_iClose.GetData(0), m_symbol.Ask(), ld_52, t.Price() - m_symbol.Bid(), gi_204, li_96, 
		m_symbol.Point(), gi_PointTen, gs_RegCode, g_acc_number_168, License_Number, User_Login, User_Password, gi_160);
		
	//if (TimeCurrent() >= D'2009.11.03 18:30' && TimeCurrent() <= D'2009.11.04')
	//{
	//    Print(condition1, ", ", li_96);
	//}
	
	if (condition1 == 1) 
	{
			price = m_symbol.Ask();
			
			gd_240 = price;
			g_bars_248 = Bars(m_symbol.Name(), m_period);
			return true;
	}
	return false;
}
