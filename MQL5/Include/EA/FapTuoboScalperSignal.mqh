//+------------------------------------------------------------------+
//|                                        FapTuoboScalperSignal.mqh |
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
#include "FapTuoboLib.mqh"
#include <Utils\Utils.mqh>

// EURCHF, EURGPB, GBPCHF, USDCHF, GBPUSD, EURUSD or USDCAD M15
class CFapTuoboScalperSignal : public CExpertModelSignal
{
private:
	CiRSI m_iRSI;
	CiRSI m_iRSIM1;
	CiMA m_iMA2;

    CiClose m_iClose;
	CiHigh m_iHigh;
	CiLow m_iLow;
	CiMA m_iMA;
	CiTime m_iTime;
	CiTime m_iTimeD1;
private:    
	int gi_TakeProfit, gi_StopLoss;
	double gd_1532;
	double gd_1620;
	datetime gi_TimeCurrent;
	int gi_1504, gi_1508, gi_1512, gi_1516, gi_1520;
	double gd_1556, gd_1564, gd_1572, gd_1580, gd_1588, gd_1612, gd_1364;
	double gd_1540, gd_1548;
	double gd_MaxSpread;
	int gi_1436, gi_1440, gi_1444, gi_1448;

	int gi_1460, gi_1464, gi_1472, gi_1480, gi_1488, gi_1496, gi_1468, gi_1476, gi_1484, gi_1492, gi_1500;

	int gi_StartWorkTimeHour, gi_EndWorkTimeHour;
	int Scalper_StartWorkTimeHour, Scalper_EndWorkTimeHour, Scalper_StartSessionMinute, Scalper_EndSessionMinute;
	bool Scalper_StealthMode, Scalper_UseCustomLevels, Scalper_TradeFriday, Scalper_TradeMonday;
	bool Scalper_SimpleHeightFilter;
	bool Scalper_TrendFilter;

	bool Scalper_IsRelaxHours();
	bool Scalper_CheckTrendFilter();
	bool Scalper_CheckSimpleHeightFilter();
	bool Scalper_IsTradeTime(datetime ai_0, int ai_4, int ai_8, int ai_12, int ai_16);
	int ExistPosition();
	int HaveAllOrders();
	bool Scalper_HaveTrade();

	bool NoiseFilter(CTableOrder* order);
	int WatchLevels(CTableOrder* order);


	bool GetOpenSignal(int wantSignal);
public:
	CFapTuoboScalperSignal();
	~CFapTuoboScalperSignal();
	virtual bool      ValidationSettings();
	virtual bool      InitIndicators(CIndicators* indicators);

	virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
	virtual bool      CheckCloseLong(CTableOrder* t, double& price);
	virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
	virtual bool      CheckCloseShort(CTableOrder* t, double& price);

	void InitParameters();
};

void CFapTuoboScalperSignal::InitParameters()
{
	int gi_796 = 25;
	int gi_800 = 60;
	int gi_804 = 5;
	int gi_808 = 140;
	int gi_812 = 4;
	int gi_816 = 170;
	int gi_820 = 3;
	int gi_824 = 200;
	int gi_828 = 3;
	int gi_832 = 240;
	int gi_836 = 1;
	double gd_840 = 0.3;
	int gi_848 = 75;
	int gi_852 = 75;
	int gi_856 = 6;
	int gi_860 = 30;
	int gi_864 = 5;
	int gi_868 = 120;
	int gi_872 = 2;
	int gi_876 = 150;
	int gi_880 = 5;
	int gi_884 = 160;
	int gi_888 = 1;
	double gd_892 = 0.5;
	int gi_900 = 75;
	int gi_904 = 80;
	int gi_908 = 7;
	int gi_912 = 145;
	int gi_916 = 6;
	int gi_920 = 180;
	int gi_924 = 5;
	int gi_928 = 205;
	int gi_932 = 3;
	int gi_936 = 250;
	int gi_940 = 3;
	double gd_944 = 0.35;
	int gi_952 = 75;
	int gi_956 = 75;
	int gi_960 = 5;
	int gi_964 = 120;
	int gi_968 = 3;
	int gi_972 = 165;
	int gi_976 = 5;
	int gi_980 = 195;
	int gi_984 = -6;
	int gi_988 = 205;
	int gi_992 = 3;
	double gd_996 = 0.5;
	int gi_1004 = 80;
	int gi_1008 = 75;
	int gi_1012 = 7;
	int gi_1016 = 105;
	int gi_1020 = 2;
	int gi_1024 = 165;
	int gi_1028 = 4;
	int gi_1032 = 235;
	int gi_1036 = -7;
	int gi_1040 = 240;
	int gi_1044 = -4;
	double gd_1048 = 0.5;
	int gi_1056 = 80;
	int gi_1060 = 75;
	int gi_1064 = 5;
	int gi_1068 = 165;
	int gi_1072 = 6;
	int gi_1076 = 105;
	int gi_1080 = 3;
	int gi_1084 = 115;
	int gi_1088 = -6;
	int gi_1092 = 240;
	int gi_1096 = -21;
	double gd_1100 = 10000.0;
	int gi_1108 = 25;
	int gi_1112 = 55;
	int gi_1116 = 6;
	int gi_1120 = 100;
	int gi_1124 = 2;
	int gi_1128 = 140;
	int gi_1132 = 0;
	int gi_1136 = 210;
	int gi_1140 = -1;
	int gi_1144 = 200;
	int gi_1148 = 1; //-12;
	double gd_1152 = 10000.0;
	int gi_1160 = 10;
	int g_period_1164 = 8;
	int g_period_1168 = 6;
	int gi_1172 = 30;
	int g_period_1176 = 20;
	int gi_1180 = 36;
	int gi_1184 = 20;

	int Scalper_EURGBP_TakeProfit = 5;
	int Scalper_EURGBP_StopLoss = 35;
	int Scalper_EURCHF_TakeProfit = 3;
	int Scalper_EURCHF_StopLoss = 93;
	int Scalper_GBPCHF_TakeProfit = 10;
	int Scalper_GBPCHF_StopLoss = 81;
	int Scalper_USDCAD_TakeProfit = 11;
	int Scalper_USDCAD_StopLoss = 73;
	int Scalper_USDCHF_TakeProfit = 9;
	int Scalper_USDCHF_StopLoss = 82;
	int Scalper_GBPUSD_TakeProfit = 10;
	int Scalper_GBPUSD_StopLoss = 76;
	int Scalper_EURUSD_TakeProfit = 16;
	int Scalper_EURUSD_StopLoss = 69;

	Scalper_TradeFriday = true;
	Scalper_TradeMonday = true;

	Scalper_StealthMode = true;
	Scalper_UseCustomLevels = true;
	Scalper_SimpleHeightFilter = true;
	Scalper_TrendFilter = true;
	double Scalper_MaxSpread = 6.0;

	if (m_symbol.Name() == "EURGBP")
	{
		gi_TakeProfit = Scalper_EURGBP_TakeProfit;
		gi_StopLoss = Scalper_EURGBP_StopLoss;
		gi_1460 = gi_796;
		gd_1532 = gd_840;
		gi_1464 = gi_800;
		gi_1472 = gi_808;
		gi_1480 = gi_816;
		gi_1488 = gi_824;
		gi_1496 = gi_832;
		gi_1468 = gi_804;
		gi_1476 = gi_812;
		gi_1484 = gi_820;
		gi_1492 = gi_828;
		gi_1500 = gi_836;
	}
	else if (m_symbol.Name() == "EURCHF")
	{
		gi_TakeProfit = Scalper_EURCHF_TakeProfit;
		gi_StopLoss = Scalper_EURCHF_StopLoss;
		gi_1460 = gi_848;
		gd_1532 = gd_892;
		gi_1464 = gi_852;
		gi_1472 = gi_860;
		gi_1480 = gi_868;
		gi_1488 = gi_876;
		gi_1496 = gi_884;
		gi_1468 = gi_856;
		gi_1476 = gi_864;
		gi_1484 = gi_872;
		gi_1492 = gi_880;
		gi_1500 = gi_888;
	}
	else if (m_symbol.Name() == "GBPCHF")
	{
		gi_TakeProfit = Scalper_GBPCHF_TakeProfit;
		gi_StopLoss = Scalper_GBPCHF_StopLoss;
		gi_1460 = gi_900;
		gd_1532 = gd_944;
		gi_1464 = gi_904;
		gi_1472 = gi_912;
		gi_1480 = gi_920;
		gi_1488 = gi_928;
		gi_1496 = gi_936;
		gi_1468 = gi_908;
		gi_1476 = gi_916;
		gi_1484 = gi_924;
		gi_1492 = gi_932;
		gi_1500 = gi_940;
	}
	else if (m_symbol.Name() == "USDCAD")
	{
		gi_TakeProfit = Scalper_USDCAD_TakeProfit;
		gi_StopLoss = Scalper_USDCAD_StopLoss;
		gi_1460 = gi_952;
		gd_1532 = gd_996;
		gi_1464 = gi_956;
		gi_1472 = gi_964;
		gi_1480 = gi_972;
		gi_1488 = gi_980;
		gi_1496 = gi_988;
		gi_1468 = gi_960;
		gi_1476 = gi_968;
		gi_1484 = gi_976;
		gi_1492 = gi_984;
		gi_1500 = gi_992;
	}
	else if (m_symbol.Name() == "USDCHF")
	{
		Scalper_SimpleHeightFilter = false;
		Scalper_TrendFilter = false;
		gi_TakeProfit = Scalper_USDCHF_TakeProfit;
		gi_StopLoss = Scalper_USDCHF_StopLoss;
		gi_1460 = gi_1004;
		gd_1532 = gd_1048;
		gi_1464 = gi_1008;
		gi_1472 = gi_1016;
		gi_1480 = gi_1024;
		gi_1488 = gi_1032;
		gi_1496 = gi_1040;
		gi_1468 = gi_1012;
		gi_1476 = gi_1020;
		gi_1484 = gi_1028;
		gi_1492 = gi_1036;
		gi_1500 = gi_1044;
	}
	else if (m_symbol.Name() == "GBPUSD")
	{
		Scalper_SimpleHeightFilter = false;
		Scalper_TrendFilter = false;
		gi_TakeProfit = Scalper_GBPUSD_TakeProfit;
		gi_StopLoss = Scalper_GBPUSD_StopLoss;
		gi_1460 = gi_1056;
		gd_1532 = gd_1100;
		gi_1464 = gi_1060;
		gi_1472 = gi_1068;
		gi_1480 = gi_1076;
		gi_1488 = gi_1084;
		gi_1496 = gi_1092;
		gi_1468 = gi_1064;
		gi_1476 = gi_1072;
		gi_1484 = gi_1080;
		gi_1492 = gi_1088;
		gi_1500 = gi_1096;
	}
	else if (m_symbol.Name() == "EURUSD")
	{
		gi_TakeProfit = Scalper_EURUSD_TakeProfit;
		gi_StopLoss = Scalper_EURUSD_StopLoss;
		gi_1460 = gi_1108;
		gd_1532 = gd_1152;
		gi_1464 = gi_1112;
		gi_1472 = gi_1120;
		gi_1480 = gi_1128;
		gi_1488 = gi_1136;
		gi_1496 = gi_1144;
		gi_1468 = gi_1116;
		gi_1476 = gi_1124;
		gi_1484 = gi_1132;
		gi_1492 = gi_1140;
		gi_1500 = gi_1148;
	}
	else
	{
		printf(__FUNCTION__+": unsupported symbol!");
		return;
	}

	gi_TakeProfit *= 10;
	gi_StopLoss *= 10;

	gd_1548 = (-1 * gi_StopLoss) * m_symbol.Point();
	gd_1540 = gi_TakeProfit * m_symbol.Point();
	gi_1504 = 60 * gi_1464;
	gi_1508 = 60 * gi_1472;
	gi_1512 = 60 * gi_1480;
	gi_1516 = 60 * gi_1488;
	gi_1520 = 60 * gi_1496;

	gd_1556 = gi_1468 * m_symbol.Point() * 10;
	gd_1564 = gi_1476 * m_symbol.Point() * 10;
	gd_1572 = gi_1484 * m_symbol.Point() * 10;
	gd_1580 = gi_1492 * m_symbol.Point() * 10;
	gd_1588 = gi_1500 * m_symbol.Point() * 10;
	gd_1620 = gi_1460 * m_symbol.Point() * 10;
	gd_MaxSpread = Scalper_MaxSpread * m_symbol.Point() * 10;
	double gd_1604 = gi_StopLoss * m_symbol.Point();
	gd_1612 = gd_1604 / 2.0;
	gi_1436 = 100 - gi_1172;
	gi_1440 = 100 - gi_1180;
	gi_1444 = gi_1184 / 2 + 50;
	gi_1448 = 50 - gi_1184 / 2;

	long l_leverage_0 = AccountInfoInteger(ACCOUNT_LEVERAGE);
	gd_1364 = NormalizeDouble(5.0 * (100 / l_leverage_0), 2);
	//g_magic_1276 = Scalper_MagicNumber;
	//g_slippage_1320 = Scalper_Slippage * MathPow(10, Digits - gi_digits);

	Scalper_StartWorkTimeHour = 20;
	Scalper_StartSessionMinute = 0;
	Scalper_EndWorkTimeHour = 24;
	Scalper_EndSessionMinute = 0;

	int gmtOffset = GetGMTOffset();

	gi_StartWorkTimeHour = Scalper_StartWorkTimeHour + gmtOffset;
	gi_EndWorkTimeHour = Scalper_EndWorkTimeHour + gmtOffset;
	while (true) {
		if (gi_StartWorkTimeHour >= 24) {
			gi_StartWorkTimeHour -= 24;
			continue;
		}
		if (gi_StartWorkTimeHour >= 0) break;
		gi_StartWorkTimeHour += 24;
	}
	while (true) {
		if (gi_EndWorkTimeHour >= 24) {
			gi_EndWorkTimeHour -= 24;
			continue;
		}
		if (gi_EndWorkTimeHour >= 0) break;
		gi_EndWorkTimeHour += 24;
	}
	if (Scalper_StartSessionMinute < 0 || Scalper_StartSessionMinute > 59) Scalper_StartSessionMinute = 0;
	if (Scalper_EndSessionMinute < 0 || Scalper_EndSessionMinute > 59) Scalper_EndSessionMinute = 0;
	if (gi_StartWorkTimeHour != gi_EndWorkTimeHour || Scalper_StartSessionMinute != Scalper_EndSessionMinute) {
		if (gi_1160 > 0) {
			Scalper_EndSessionMinute -= gi_1160;
			if (Scalper_EndSessionMinute < 0) {
				Scalper_EndSessionMinute += 60;
				gi_EndWorkTimeHour--;
				if (gi_EndWorkTimeHour < 0) gi_EndWorkTimeHour += 24;
			}
		}
	}
}

void CFapTuoboScalperSignal::CFapTuoboScalperSignal()
{
}

void CFapTuoboScalperSignal::~CFapTuoboScalperSignal()
{
}
bool CFapTuoboScalperSignal::ValidationSettings()
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

bool CFapTuoboScalperSignal::InitIndicators(CIndicators* indicators)
{
	if(indicators==NULL) 
		return(false);
	bool ret = true;
    
	ret &= m_iMA.Create(m_symbol.Name(), m_period, 5, 0, MODE_EMA, PRICE_CLOSE);
	ret &= m_iHigh.Create(m_symbol.Name(), m_period);
	ret &= m_iLow.Create(m_symbol.Name(), m_period);
	ret &= m_iTime.Create(m_symbol.Name(), m_period);
	ret &= m_iTimeD1.Create(m_symbol.Name(), PERIOD_D1);
    ret &= m_iClose.Create(m_symbol.Name(), m_period);
    
	ret &= m_iRSI.Create(m_symbol.Name(), m_period, 6, PRICE_CLOSE);
	ret &= m_iRSIM1.Create(m_symbol.Name(), PERIOD_M1, 20, PRICE_CLOSE);
	ret &= m_iMA2.Create(m_symbol.Name(), m_period, 8, 0, MODE_SMA, PRICE_MEDIAN);

	ret &= indicators.Add(GetPointer(m_iMA));
	ret &= indicators.Add(GetPointer(m_iHigh));
	ret &= indicators.Add(GetPointer(m_iLow));
	ret &= indicators.Add(GetPointer(m_iTime));
	ret &= indicators.Add(GetPointer(m_iTimeD1));
	ret &= indicators.Add(GetPointer(m_iRSI));
	ret &= indicators.Add(GetPointer(m_iRSIM1));
	ret &= indicators.Add(GetPointer(m_iMA2));

	return ret;
}

bool CFapTuoboScalperSignal::GetOpenSignal(int wantSignal)
{
	bool ret = 0;

	int l_day_of_week_16;
	double l_irsi_20;
	double l_irsi_28;
	double l_ima_36;
	int li_44;
	int l_count_48;
	double l_ima_52;
	gi_TimeCurrent = TimeCurrent();


	//SetOrderLevels();

	int gmtOffset = GetGMTOffset();

	MqlDateTime dt_strcut;
	TimeToStruct(gi_TimeCurrent - 3600 * gmtOffset, dt_strcut);

	l_day_of_week_16 = dt_strcut.day_of_week;

	if (l_day_of_week_16 == 0 || l_day_of_week_16 > 5) return ret;

	if (!Scalper_TradeFriday)
		if (l_day_of_week_16 >= 5) return ret;
	if (!Scalper_TradeMonday)
		if (l_day_of_week_16 <= 1) return ret;

	if (l_day_of_week_16 == 1 && dt_strcut.hour < Scalper_StartWorkTimeHour 
		|| (dt_strcut.hour == Scalper_StartWorkTimeHour &&
		dt_strcut.min < Scalper_StartSessionMinute)) 
		return ret;

	if (Scalper_IsTradeTime(gi_TimeCurrent, gi_StartWorkTimeHour, Scalper_StartSessionMinute, gi_EndWorkTimeHour, Scalper_EndSessionMinute)) 
	{
		int Scalper_RelaxHours = 0;
		int Scalper_OneTrade = 0;
		bool Scalper_OneOpenTrade = false;
		int Scalper_ReverseTrade = 0;

		if (Scalper_RelaxHours > 0)
			if (Scalper_IsRelaxHours()) return ret;
		if (Scalper_SimpleHeightFilter)
			if (Scalper_CheckSimpleHeightFilter()) return ret;
		if (Scalper_TrendFilter)
			if (Scalper_CheckTrendFilter()) return ret;
		if (Scalper_OneTrade != 0) {
			if (Scalper_HaveTrade()) 
			{
				Debug("Already have one trade inside this interval of time.");
				return ret;

			}
		}

		if (Scalper_OneOpenTrade) {
			if (HaveAllOrders() > 0) 
			{
				Debug("Already have open order");
				return ret;

			}
		}

		if (m_symbol.Ask() - m_symbol.Bid() > gd_MaxSpread) 
		{
				Debug("Trade signal is missed due to invalid high spread.");
				Debug("Current spread = " + DoubleToString(m_symbol.Ask() - m_symbol.Bid()) + ",  MaxSpread = " + DoubleToString(gd_MaxSpread));
				Debug("Fapturbo will try again later when spreads come to normal.");

		} else {


			m_iRSI.Refresh(-1);
			m_iRSIM1.Refresh(-1);
			m_iMA.Refresh(-1);

			l_irsi_20 = m_iRSI.Main(0);
			l_irsi_28 = m_iRSIM1.Main(0);
			l_ima_36 = m_iMA.Main(1);

			static bool gi_1416 = true;
			static bool gi_1420 = true;

			int gi_1180 = 36;
			int gi_1172 = 30;
			int gia_1284[1];
			int gia_1288[1];
			int gia_1296[100];
			int gia_1300[100];
			int gia_1304[100];
			int gia_1308[100];
			int g_bool_1268 = 0;
			int g_acc_number_1292 = 0;

			bool Scalper_UseFilterMA = false;
			int Scalper_PeriodFilterMA = 100;
			int Scalper_PriceFilterMA = 0;
			int Scalper_MethodFilterMA = 0;


			if (wantSignal == 1)
			{
				if (Scalper_ReverseTrade == 0) 
					li_44 = fun2(m_symbol.Ask() + 0.0002, ExistPosition(), l_irsi_20, l_irsi_28, gi_1180, gi_1172, l_ima_36, g_acc_number_1292, g_acc_number_1292, gia_1296, gia_1300, gia_1304, (int)gi_TimeCurrent, gia_1308, gia_1284, g_bool_1268, gia_1288);
				else 
					li_44 = fun3(m_symbol.Bid() - 0.0002, ExistPosition(), l_irsi_20, l_irsi_28, gi_1440, gi_1436, l_ima_36, g_acc_number_1292, g_acc_number_1292, gia_1296, gia_1300, gia_1304, (int)gi_TimeCurrent, gia_1308, gia_1284, g_bool_1268, gia_1288);

				if (li_44 == 1) 
				{
					if (gi_1416) 
					{
						if (!Scalper_UseFilterMA) 
							l_count_48 = 0;
						else 
						{
							//l_ima_52 = iMA(NULL, 0, Scalper_PeriodFilterMA, 0, Scalper_MethodFilterMA, Scalper_PriceFilterMA, 0);
							if (m_iClose.GetData(1) <= l_ima_52) l_count_48++;
						}
						if (l_count_48 == 0) 
						{
							//OpenPosition(OP_BUY, gi_TakeProfit, gi_StopLoss);
							ret = 1;
							gi_1416 = false;
							gi_1420 = true;
						}
					}
				}
			}
			else if (wantSignal == -1)
			{     
				//Print(m_symbol.Bid() - 0.0002, ",", l_irsi_20, ",", l_irsi_28, ",", l_ima_36, ",", gi_1440, ",", gi_1436);
				if (Scalper_ReverseTrade == 0) 
					li_44 = fun3(m_symbol.Bid() - 0.0002, ExistPosition(), l_irsi_20, l_irsi_28, gi_1440, gi_1436, l_ima_36, g_acc_number_1292, g_acc_number_1292, gia_1296, gia_1300, gia_1304, (int)gi_TimeCurrent, gia_1308, gia_1284, g_bool_1268, gia_1288);
				else 
					li_44 = fun2(m_symbol.Ask() + 0.0002, ExistPosition(), l_irsi_20, l_irsi_28, gi_1180, gi_1172, l_ima_36, g_acc_number_1292, g_acc_number_1292, gia_1296, gia_1300, gia_1304, (int)gi_TimeCurrent, gia_1308, gia_1284, g_bool_1268, gia_1288);


				if (li_44 == 1) 
				{
					if (gi_1420) 
					{
						if (!Scalper_UseFilterMA) 
							l_count_48 = 0;
						else 
						{
							//l_ima_52 = iMA(NULL, 0, Scalper_PeriodFilterMA, 0, Scalper_MethodFilterMA, Scalper_PriceFilterMA, 0);
							if (m_iClose.GetData(1) >= l_ima_52) l_count_48++;
						}
						if (l_count_48 == 0) 
						{
							//OpenPosition(OP_SELL, gi_TakeProfit, gi_StopLoss);
							ret = -1;
							gi_1420 = false;
							gi_1416 = true;
						}
					}
				}
			}

			if (fun4(l_irsi_20, gi_1444, gi_1448))
			{
				gi_1420 = true;
				gi_1416 = true;
			}
		}
	}

	return ret;
}
bool CFapTuoboScalperSignal::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
{
	CExpertModel* em = (CExpertModel *)m_expert;
	if (em.GetOrderCount(ORDER_TYPE_BUY) >= 1)
		return false;

	if (GetOpenSignal(1))
	{
		m_symbol.RefreshRates();

		price = m_symbol.Ask();
		//tp = price + gi_TakeProfit * m_symbol.Point();
		//sl = price - gi_StopLoss * m_symbol.Point();

		return true;
	}

	return false;
}

bool CFapTuoboScalperSignal::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
{
	CExpertModel* em = (CExpertModel *)m_expert;
	if (em.GetOrderCount(ORDER_TYPE_SELL) >= 1)
		return false;

	if (GetOpenSignal(-1))
	{
		m_symbol.RefreshRates();

		price = m_symbol.Bid();
		//tp = price - gi_TakeProfit * m_symbol.Point();
		//sl = price + gi_StopLoss * m_symbol.Point();

		return true;
	}

	return false;
}

bool CFapTuoboScalperSignal::Scalper_IsRelaxHours() 
{
	CExpertModel* em = (CExpertModel *)m_expert;

	int Scalper_RelaxHours = 0;

	int digit = (int)SymbolInfoInteger(em.Symbol(), SYMBOL_DIGITS);
	double point = SymbolInfoDouble(em.Symbol(), SYMBOL_POINT);
	double gd_1604 = NormalizeDouble(gi_StopLoss * digit, digit);


	int dealsCnt = HistoryDealsTotal() - 1;
	ulong ticket;
	long maxDealTime = -2147483648;
	ulong maxDealTicket = 0;
	for (int i = dealsCnt; i >= 0; i--) 
	{
		if( (ticket=HistoryDealGetTicket(i)) > 0)
		{ 
			if (HistoryDealGetInteger(ticket, DEAL_MAGIC) == em.Magic()
				&& HistoryDealGetString(ticket, DEAL_SYMBOL) == em.Symbol()
				&& HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT) 
			{
				long d = HistoryDealGetInteger(ticket, DEAL_TIME);
				if (maxDealTime < d) 
				{
					maxDealTime = d;
					maxDealTicket = ticket;
				}
			}
		}
	}
	if (maxDealTicket <= 0) 
		return false;

	bool li_20 = false;

	//double ld_24 = NormalizeDouble(OrderOpenPrice(), Digits);
	double ld_24 = NormalizeDouble(HistoryDealGetDouble(maxDealTicket, DEAL_PRICE), digit);
	double ld_32 = NormalizeDouble(HistoryDealGetDouble(maxDealTicket, DEAL_PRICE), digit);
	double ld_40 = NormalizeDouble(HistoryOrderGetDouble(HistoryDealGetInteger(maxDealTicket, DEAL_ORDER), ORDER_SL), digit);
	if (HistoryDealGetInteger(maxDealTicket, DEAL_TYPE) == DEAL_TYPE_SELL) 
	{
		if (ld_32 <= ld_40 && ld_40 != 0.0) 
			li_20 = true;
		else
			if (NormalizeDouble(ld_24 - ld_32, digit) >= gd_1612) 
				li_20 = true;
	} else 
	{
		if (ld_32 >= ld_40 && ld_40 != 0.0) 
			li_20 = true;
		else
			if (NormalizeDouble(ld_32 - ld_24, digit) >= gd_1612) 
				li_20 = true;
	}
	if (!li_20) 
		return (false);

	/*
	int l_shift_48 = iBarShift(NULL, PERIOD_H1, maxDealTime, false);
	if (l_shift_48 < Scalper_RelaxHours) {
	l_datetime_52 = iTime(NULL, PERIOD_H1, 0);
	if (g_datetime_1432 != l_datetime_52) {
	if (WriteLog) {
	Print("Relax Hours Left = " + DoubleToStr(l_shift_48 - Scalper_RelaxHours, 0) + " (after StopLoss).");
	}
	g_datetime_1432 = l_datetime_52;
	}
	return (true);
	}*/
	return (false);
}

bool CFapTuoboScalperSignal::Scalper_CheckTrendFilter() 
{
	int gi_1200 = 4;
	int gi_1204 = 3;

	if (gi_1200 <= 0) 
		return (false);

	m_iMA.Refresh(-1);

	int i = 0;
	for (i = 0; i <= gi_1204; i++) 
	{
		double ld_4 = m_iMA.Main(i);
		double ld_12 = m_iMA.Main(i + gi_1200);
		double ld_20 = 100.0 * MathAbs(ld_4 - ld_12) / ld_12;
		if (ld_20 > gd_1532) 
			break;
	}
	if (i > gi_1204) 
		return (false);

		Debug("Today market is in risky conditions. Trading is forbidden by the filter TrendFilter.");
		if (i != 0) 
		{
			Debug("Relax Bars Left = " + DoubleToString(gi_1204 - i, 0) + " (after MaxPercentMove).");
		}

	return (true);
}

bool CFapTuoboScalperSignal::Scalper_CheckSimpleHeightFilter() 
{
	static datetime g_datetime_1428;

	m_iHigh.Refresh(-1);
	m_iLow.Refresh(-1);
	m_iTime.Refresh(-1);

	bool li_0 = false;
	if (m_iHigh.GetData(1) - m_iLow.GetData(1) > gd_1620) 
		li_0 = true;
	if (m_iHigh.GetData(2) - m_iLow.GetData(2)  > gd_1620) 
		li_0 = true;
	if (li_0) 
	{
		datetime l_datetime_4 = m_iTime.GetData(1);
		if (g_datetime_1428 != l_datetime_4) 
		{

				Debug("Today market is in risky conditions. Trade is forbidden by the filter SimpleHeightFilter.");
			g_datetime_1428 = l_datetime_4;
		}
		return (true);
	}
	return (false);
}

bool CFapTuoboScalperSignal::Scalper_IsTradeTime(datetime ai_0, int ai_4, int ai_8, int ai_12, int ai_16) 
{
	MqlDateTime dt_struct;
	TimeToStruct(ai_0, dt_struct);

	int li_28;
	int li_32;
	int l_hour_20 = dt_struct.hour;
	int l_minute_24 = dt_struct.min;
	if (ai_4 == ai_12 && ai_8 == ai_16) return (true);
	if (ai_16 == 0) {
		if (ai_12 == 0) li_28 = 23;
		else li_28 = ai_12 - 1;
		li_32 = 59;
	} else {
		li_28 = ai_12;
		li_32 = ai_16 - 1;
	}
	if (ai_4 == li_28) {
		if (ai_8 == li_32) return (true);
		if (ai_8 < li_32) {
			if (l_hour_20 != ai_4) return (false);
			if (l_minute_24 < ai_8 || l_minute_24 > li_32) return (false);
			return (true);
		}
		if (ai_8 > li_32) {
			if (l_hour_20 == ai_4)
				if (l_minute_24 < ai_8 && l_minute_24 > li_32) return (false);
			return (true);
		}
	}
	if (ai_4 < li_28) {
		if (l_hour_20 < ai_4 || l_hour_20 > li_28) return (false);
		if (l_hour_20 == ai_4 && l_minute_24 < ai_8) return (false);
		if (l_hour_20 == li_28 && l_minute_24 > li_32) return (false);
		return (true);
	}
	if (ai_4 > li_28) {
		if (l_hour_20 < ai_4 && l_hour_20 > li_28) return (false);
		if (l_hour_20 == ai_4 && l_minute_24 < ai_8) return (false);
		if (l_hour_20 == li_28 && l_minute_24 > li_32) return (false);
		return (true);
	}
	return (true);
}

int CFapTuoboScalperSignal::ExistPosition() 
{
	CExpertModel* em = (CExpertModel *)m_expert;
	if (em.TableOrders().Total() > 0)
		return 1;
	return 0;
}


bool CFapTuoboScalperSignal::CheckCloseLong(CTableOrder* t, double& price)
{
	CExpertModel* em = (CExpertModel *)m_expert;

	int ret = 0; 
	if (Scalper_StealthMode) 
		ret = WatchLevels(t);
	if (ret ==0 && Scalper_UseCustomLevels) 
	{
		bool r = NoiseFilter(t);
		if (r) ret = 1;
	}

	if (ret == 1)
	{
		price = m_symbol.Bid();
		return true;
	}
	return false;
}

bool CFapTuoboScalperSignal::CheckCloseShort(CTableOrder* t, double& price)
{
	CExpertModel* em = (CExpertModel *)m_expert;

	int ret = 0; 
	if (Scalper_StealthMode) 
		ret = WatchLevels(t);
	if (ret ==0 && Scalper_UseCustomLevels) 
	{
		bool r = NoiseFilter(t);
		if (r) ret = -1;
	}

	if (ret == -1)
	{
		price = m_symbol.Ask();
		return true;
	}
	return false;
}

bool CFapTuoboScalperSignal::NoiseFilter(CTableOrder* order) 
{
	bool ret = false;

	CExpertModel* em = (CExpertModel *)m_expert;

	int li_12 = (int)(gi_TimeCurrent - order.TimeSetup());
	if (li_12 > gi_1504) 
	{
		double ld_16;
		double ld_24 = order.Price();
		int li_32 = 0;
		double ld_36;
		if (order.OrderType()== ORDER_TYPE_BUY)
		{
			ld_16 = m_symbol.Bid();
			ld_36 = ld_16 - ld_24;
		}
		else 
		{
			ld_16 = m_symbol.Ask();
			ld_36 = ld_24 - ld_16;
		}

		//Print(li_12, ",", gi_1508, ",", ld_36, ",", gd_1556);

		if (li_12 < gi_1508 && ld_36 >= gd_1556) 
			li_32 = 1;
		else if (li_12 > gi_1508 && li_12 < gi_1512 && ld_36 >= gd_1564) 
			li_32 = 2;
		else if (li_12 > gi_1512 && li_12 < gi_1516 && ld_36 >= gd_1572) 
			li_32 = 3;
		else if (li_12 > gi_1516 && li_12 < gi_1520 && ld_36 >= gd_1580) 
			li_32 = 4;
		else if (li_12 > gi_1520 && ld_36 >= gd_1588) 
			li_32 = 5;

		if (li_32 != 0) 
		{
			ret = true;
			//    CloseOrder(OrderTicket(), OrderLots(), OrderType(), g_slippage_1320);
				Debug("NoiseFilter: level for close, " + IntegerToString(li_32));
		}
	}
	return ret;
}

int CFapTuoboScalperSignal::WatchLevels(CTableOrder* order) 
{
	int ret = 0;

	double ld_12;
	double ld_20;
	double ld_28;
	if (gi_TakeProfit <= 0 && gi_StopLoss <= 0) 
		return  ret;

	CExpertModel* em = (CExpertModel *)m_expert;

	ld_20 = order.Price();

	if (order.OrderType() == ORDER_TYPE_BUY) 
	{
		ld_12 = m_symbol.Bid();
		ld_28 = ld_12 - ld_20;
		if ((gd_1540 > 0.0 && ld_28 >= gd_1540) || (gd_1548 < 0.0 && ld_28 <= gd_1548)) 
		{

				Debug("WatchLevels: level for close BUY");
			//CloseOrder(OrderTicket(), OrderLots(), 0, g_slippage_1320);
			ret = 1;
		}
	}
	else 
	{
		ld_12 = m_symbol.Ask();
		ld_28 = ld_20 - ld_12;
		//Print(m_symbol.Bid(), ",", ld_20, ",", ld_28, ",", gd_1548);

		if ((gd_1540 > 0.0 && ld_28 >= gd_1540) || (gd_1548 < 0.0 && ld_28 <= gd_1548)) 
		{
				Debug("WatchLevels: level for close SELL");

			//CloseOrder(OrderTicket(), OrderLots(), 1, g_slippage_1320);
			ret = -1;
		}
	}
	return ret;
}



bool CFapTuoboScalperSignal::Scalper_HaveTrade() 
{
	if (gi_StartWorkTimeHour == gi_EndWorkTimeHour 
		&& Scalper_StartSessionMinute == Scalper_EndSessionMinute) 
		return (false);

	m_iTimeD1.Refresh(-1);

	MqlDateTime dt_struct;
	datetime l_datetime_0 = TimeCurrent(dt_struct);
	datetime li_4 = m_iTimeD1.GetData(0);
	int l_hour_8 = dt_struct.hour;

	if (gi_StartWorkTimeHour > gi_EndWorkTimeHour)
		if (l_hour_8 < gi_StartWorkTimeHour) li_4 -= 86400;

	li_4 += 3600 * gi_StartWorkTimeHour + 60 * Scalper_StartSessionMinute;
	datetime l_datetime_20 = -2147483648;

	CExpertModel* em = (CExpertModel *)m_expert;
	int total_elements = em.TableOrders().Total();
	for(int i=total_elements-1;i>=0;i--)
	{
		CTableOrder *order = em.TableOrders().GetNodeAtIndex(i);
		datetime l_datetime_28 = order.TimeSetup();
		if (l_datetime_20 < l_datetime_28) 
			l_datetime_20 = l_datetime_28;
	}


	if (l_datetime_20 >= li_4) 
		return (true);


	int li_8 = HistoryDealsTotal() - 1;
	for (int i = li_8; i >= 0; i--) 
	{
		ulong ticket;
		if( ( ticket=HistoryDealGetTicket(i)) > 0)
		{ 
			if (HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_IN
				&& HistoryDealGetInteger(ticket, DEAL_MAGIC) == em.Magic())
			{
				datetime l_datetime_28 = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
				if (l_datetime_20 < l_datetime_28) 
					l_datetime_20 = l_datetime_28;
			}
		}
	}


	if (l_datetime_20 >= li_4) return (true);
	return (false);
}

int CFapTuoboScalperSignal::HaveAllOrders() 
{
	CExpertModel* em = (CExpertModel *)m_expert;
	int total_elements = em.TableOrders().Total();
	return total_elements;
}

/*
double CFapTuoboScalperSignal::CalculateProfitSession() 
{
double ld_ret_0 = 0;

CExpertModel* em = (CExpertModel *)m_expert;
int total_elements = em.ListTableOrders.Total();
for(int i=total_elements-1;i>=0;i--)
{
CTableOrder *order = em.ListTableOrders.GetNodeAtIndex(i);

//ld_ret_0 += order.Ticket + OrderSwap() + OrderCommission();
}

datetime li_16;
if (gi_StartWorkTimeHour == gi_EndWorkTimeHour 
&& Scalper_StartSessionMinute == Scalper_EndSessionMinute) 
{
li_16 = 0;
}
else 
{
MqlDateTime dt_struct;
datetime l_datetime_20 = TimeCurrent(dt_struct);
li_16 = m_iTimeD1.GetData(0);
int l_hour_24 = dt_struct.hour;

if (gi_StartWorkTimeHour > gi_EndWorkTimeHour)
if (l_hour_24 < gi_StartWorkTimeHour) li_16 -= 86400;
li_16 += 3600 * gi_StartWorkTimeHour + 60 * Scalper_StartSessionMinute;
}

int dealsCnt = HistoryDealsTotal() - 1;
for (int i = dealsCnt; i >= 0; i--) 
{
ulong ticket;
if( (ticket=HistoryDealGetTicket(i)) > 0)
{
if (HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT
&& HistoryDealGetInteger(ticket, DEAL_MAGIC) == em.Magic())
{
if (HistoryDealGetInteger(ticket, DEAL_TIME) >= li_16) 
{
ld_ret_0 += HistoryDealGetDouble(ticket, DEAL_PROFIT) 
+ HistoryDealGetDouble(ticket, DEAL_SWAP) 
+ HistoryDealGetDouble(ticket, DEAL_COMMISSION);
}
}
}
}
return (ld_ret_0);
}*/