//+------------------------------------------------------------------+
//|                                           PipesMinerEESignal.mqh |
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
#include "PipesMinerEELib.mqh"

class CPipesMinerEESignal : public CExpertModelSignal
{
private:
	CiMACD  m_iMACD_76, m_iMACD_84_1;
	CiMACD  m_iMACD_84_2;
	CiMA m_iMA_60;
	CiOpen m_iOpen;
	CiMA m_iMA_0, m_iMA_8, m_iMA_16;
	CiRSI m_iRSI_24, m_iRSI_32;
	CiMomentum m_iMomentum_40, m_iMomentum_48;

	//int gia_156[200][2];
	//int g_index_160;
	//int g_ticket_164;
	//ulong g_ticket_144;
	//ulong g_ticket_152;

	int gi_100;
	//int gi_104;
	int gi_tp;
	int gi_sl;

	bool gi_184;
	int gi_168;
	int gi_124;
	double gd_188;

	void IPO();
	void SORD(int ai_0);
	int UPO(int ai_0);
	double CL();
	double R_PRCE(int ai_0);
	double R_PRF(int ai_0);
	double R_LSS(int ai_0);
	double CO_PL();
	int OT();
	int MMX();
	int GLT();
	ulong _GTC();
	void C_ORD();
	void G_LO();
	bool iTT();
	bool GL_CLP(double ad_0, double ad_8, double ad_16, double ad_24, double ad_32, double ad_40);
	bool GL_CSP(double ad_0, double ad_8, double ad_16, double ad_24, double ad_32, double ad_40);

	bool GetOpenSignal(int wantSignal);

public:
	CPipesMinerEESignal();
	~CPipesMinerEESignal();
	virtual bool      ValidationSettings();
	virtual bool      InitIndicators(CIndicators* indicators);

	virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
	virtual bool      CheckCloseLong(CTableOrder* t, double& price);
	virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
	virtual bool      CheckCloseShort(CTableOrder* t, double& price);

	void InitParameters();
};

void CPipesMinerEESignal::InitParameters()
{
	//g_index_160 = 0;
	//g_ticket_164 = 0;
	gi_100 = 1;
	//gi_104 = 8;
	gi_tp = 40;
	gi_sl = 290;
	//g_ticket_144 = 0;
	//g_ticket_152 = 0;
	gi_184 = true;

	gi_168 = 0;
	gi_168 = OT();

	gi_124 = 7;

	IPO();
	gi_168 = 0;
	int li_0 = MMX();

	gi_tp = 40 * li_0;
	gi_sl = 290 * li_0;
	gi_124 = 7 * li_0;
	gd_188 = 1 / m_symbol.Point();
	//g_ticket_152 = GLT();
	//g_ticket_144 = _GTC();

	//gd_172 = m_symbol.Spread;
}

void CPipesMinerEESignal::CPipesMinerEESignal()
{
}

void CPipesMinerEESignal::~CPipesMinerEESignal()
{
}
bool CPipesMinerEESignal::ValidationSettings()
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

bool CPipesMinerEESignal::InitIndicators(CIndicators* indicators)
{
	if(indicators==NULL) 
		return(false);
	bool ret = true; 

	ret &= m_iMACD_76.Create(m_symbol.Name(), m_period, 12, 26, 9, PRICE_CLOSE);
	ret &= m_iMACD_84_1.Create(m_symbol.Name(), m_period, 7, 20, 5, PRICE_CLOSE);
	ret &= m_iMACD_84_2.Create(m_symbol.Name(), m_period, 5, 22, 11, PRICE_CLOSE);

	ret &= m_iMA_60.Create(m_symbol.Name(), m_period, 50, 3, MODE_SMA, PRICE_CLOSE);
	ret &= m_iOpen.Create(m_symbol.Name(), m_period);

	ret &= m_iMA_0.Create(m_symbol.Name(), m_period, 10, 3, MODE_SMA, PRICE_CLOSE);
	ret &= m_iMA_8.Create(m_symbol.Name(), m_period, 21, 3, MODE_SMA, PRICE_CLOSE);
	ret &= m_iMA_16.Create(m_symbol.Name(), m_period, 50, 3, MODE_SMA, PRICE_CLOSE);
	ret &= m_iRSI_24.Create(m_symbol.Name(), m_period, 14, PRICE_CLOSE);
	ret &= m_iRSI_32.Create(m_symbol.Name(), m_period, 7, PRICE_CLOSE);
	ret &= m_iMomentum_40.Create(m_symbol.Name(), m_period, 10, PRICE_CLOSE);
	ret &= m_iMomentum_48.Create(m_symbol.Name(), m_period, 21, PRICE_CLOSE);;

	ret &= indicators.Add(GetPointer(m_iMACD_76));
	ret &= indicators.Add(GetPointer(m_iMACD_84_1));
	ret &= indicators.Add(GetPointer(m_iMACD_84_2));
	ret &= indicators.Add(GetPointer(m_iMA_60));
	ret &= indicators.Add(GetPointer(m_iOpen));
	ret &= indicators.Add(GetPointer(m_iMA_0));
	ret &= indicators.Add(GetPointer(m_iMA_8));
	ret &= indicators.Add(GetPointer(m_iMA_16));
	ret &= indicators.Add(GetPointer(m_iRSI_24));
	ret &= indicators.Add(GetPointer(m_iRSI_32));
	ret &= indicators.Add(GetPointer(m_iMomentum_40));
	ret &= indicators.Add(GetPointer(m_iMomentum_48));

	return ret;
}

bool CPipesMinerEESignal::GetOpenSignal(int wantSignal) 
{
	double l_ima_0 = 0;
	double l_ima_8 = 0;
	double l_ima_16 = 0;
	double l_irsi_24 = 0;
	double l_irsi_32 = 0;
	double l_imomentum_40 = 0;
	double l_imomentum_48 = 0;
	double ld_60 = 0;

	if (iTT()) 
	{
		m_iMA_0.Refresh(-1);
		m_iMA_8.Refresh(-1);
		m_iMA_16.Refresh(-1);
		m_iRSI_24.Refresh(-1);
		m_iRSI_32.Refresh(-1);
		m_iMomentum_40.Refresh(-1);
		m_iMomentum_48.Refresh(-1);

		l_ima_0 = m_iMA_0.Main(0); // iMA(NULL, 0, 10, gi_112, MODE_SMA, PRICE_CLOSE, 0);
		l_ima_8 = m_iMA_8.Main(0); // iMA(NULL, 0, 21, gi_112, MODE_SMA, PRICE_CLOSE, 0);
		l_ima_16 = m_iMA_16.Main(0); // iMA(NULL, 0, 50, gi_112, MODE_SMA, PRICE_CLOSE, 0);
		l_irsi_24 = m_iRSI_24.Main(0); // iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
		l_irsi_32 = m_iRSI_32.Main(0); // iRSI(NULL, 0, 7, PRICE_CLOSE, 0);
		l_imomentum_40 = m_iMomentum_40.Main(0); // iMomentum(NULL, 0, 10, PRICE_CLOSE, 0);
		l_imomentum_48 = m_iMomentum_48.Main(0); // iMomentum(NULL, 0, 21, PRICE_CLOSE, 0);
		G_LO();

		gi_168 = OT();

		// enough order
		if (gi_168 >= gi_100) 
		{
			return false;
		}

		if (wantSignal == 1 && GL_CLP(l_ima_0, l_ima_8, l_irsi_32, l_irsi_24, l_imomentum_40, l_imomentum_48))
		{
			return true;
			//ld_60 = CL();
			//  if (OpenOrder(1, gi_tp, gi_sl, ld_60) == 0) 
			//  {
			//     if (g_ticket_144 > 0) {
			//        if (ld_60 > Lots) UPO(g_ticket_144);
			//        else SORD(g_ticket_144);
			//     }
			//     g_ticket_152 = g_ticket_144;
			//     break;
			//  }
		}
		if (wantSignal == -1 && GL_CSP(l_ima_0, l_ima_8, l_irsi_32, l_irsi_24, l_imomentum_40, l_imomentum_48)) 
		{
			return true;
			//ld_60 = CL();
			//   if (OpenOrder(2, gi_tp, gi_sl, ld_60) == 0) {
			//      if (g_ticket_144 > 0) {
			//         if (ld_60 > Lots) UPO(g_ticket_144);
			//         else SORD(g_ticket_144);
			//      }
			//      g_ticket_152 = g_ticket_144;
			//   }
		}
	}

	return false;
}

bool CPipesMinerEESignal::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
{
	CExpertModel* em = (CExpertModel *)m_expert;
	if (em.GetOrderCount(ORDER_TYPE_BUY) >= gi_100)
		return false;

	if (TimeCurrent() % (5 * 60) != 0)
		return false;

	if (GetOpenSignal(1))
	{
		m_symbol.RefreshRates();

		price = m_symbol.Ask();
		tp = price + gi_tp * m_symbol.Point();
		sl = price - gi_sl * m_symbol.Point();


		return true;
	}

	return false;
}

bool CPipesMinerEESignal::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
{
	CExpertModel* em = (CExpertModel *)m_expert;
	if (em.GetOrderCount(ORDER_TYPE_SELL) >= gi_100)
		return false;

	if (TimeCurrent() % (5 * 60) != 0)
		return false;

	if (GetOpenSignal(-1))
	{
		m_symbol.RefreshRates();

		price = m_symbol.Bid();
		tp = price - gi_tp * m_symbol.Point();
		sl = price + gi_sl * m_symbol.Point();

		return true;
	}

	return false;
}

bool CPipesMinerEESignal::CheckCloseLong(CTableOrder* t, double& price)
{
	CExpertModel* em = (CExpertModel *)m_expert;

	if (t.StopLoss() == 0.0 && t.TakeProfit() == 0.0) 
	{
		double l_ord_open_price_60 = t.Price();
		double ld_44 = m_symbol.Bid() - l_ord_open_price_60;

		ld_44 = NormalizeDouble(ld_44, m_symbol.Digits());
		ld_44 *= gd_188;
		if (ld_44 >= gi_tp || ld_44 <= gi_sl)
		{
			price = m_symbol.Bid();

			return true;
		}
	}

	return false;
}

bool CPipesMinerEESignal::CheckCloseShort(CTableOrder* t, double& price)
{
	CExpertModel* em = (CExpertModel *)m_expert;

	if (t.StopLoss() == 0.0 && t.TakeProfit() == 0.0) 
	{
		double l_ord_open_price_60 = t.Price();
		double ld_44 = l_ord_open_price_60 - m_symbol.Ask();

		ld_44 = NormalizeDouble(ld_44, m_symbol.Digits());
		ld_44 *= gd_188;
		if (ld_44 >= gi_tp || ld_44 <= gi_sl)
		{
			price = m_symbol.Ask();

			return true;
		}
	}

	return false;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


void CPipesMinerEESignal::IPO() 
{
	/*
	for (int l_index_0 = 0; l_index_0 < 200; l_index_0++) {
	gia_156[l_index_0][0] = 0;
	gia_156[l_index_0][1] = 0;
	}
	*/
}

void CPipesMinerEESignal::SORD(int ai_0) 
{
	/*
	if (g_index_160 < 200) {
	gia_156[g_index_160][0] = ai_0;
	gia_156[g_index_160][1] = 0;
	} else {
	g_index_160 = 0;
	gia_156[g_index_160][0] = ai_0;
	gia_156[g_index_160][1] = 0;
	}
	g_index_160++;
	*/
}

int CPipesMinerEESignal::UPO(int ai_0) 
{
	/*
	int l_index_4 = 0;
	bool li_8 = false;
	while (l_index_4 < 200) {
	li_8 = gia_156[l_index_4][0];
	if (li_8 == g_ticket_164) {
	gia_156[l_index_4][1] = ai_0;
	return (0);
	}
	l_index_4++;
	}*/
	return (-1);
}

double CPipesMinerEESignal::CL() {
	bool gi_108 = false;

	double ld_ret_0 = 0;
	/*
	double ld_unused_8 = 0;
	double ld_unused_16 = 0;
	double ld_unused_24 = 0;
	double l_ord_profit_32 = 0;
	int li_40 = 0;
	int l_ticket_44 = 0;
	bool li_48 = false;
	int l_datetime_52 = 0;
	if (gi_104 == 0) return (Lots);
	li_40 = g_index_160;
	ld_ret_0 = Lots;
	while (li_40 >= 0) {
	l_ticket_44 = gia_156[li_40][0];
	li_48 = gia_156[li_40][1];
	if (l_ticket_44 > 0 && li_48 == false) {
	if (OrderSelect(l_ticket_44, SELECT_BY_TICKET) == TRUE) {
	l_datetime_52 = OrderCloseTime();
	if (l_datetime_52 > 0) {
	l_ord_profit_32 = OrderProfit();
	if (l_ord_profit_32 < 0.0) {
	g_ticket_164 = l_ticket_44;
	ld_ret_0 = Lots * gi_104;
	if (gi_108) ld_ret_0 += Lots;
	return (ld_ret_0);
	}
	}
	}
	}
	li_40--;
	}&*/
	return (ld_ret_0);
}

double CPipesMinerEESignal::R_PRCE(int ai_0) {
	double l_price_4 = 0;
	switch (ai_0) {
	case 1:
		l_price_4 = m_symbol.Ask();
		break;
	case 2:
		l_price_4 = m_symbol.Bid();
	}
	l_price_4 = NormalizeDouble(l_price_4, m_symbol.Digits());
	return (l_price_4);
}

double CPipesMinerEESignal::R_PRF(int ai_0) {
	double ld_4 = 0;
	switch (ai_0) {
	case 1:
		ld_4 = m_symbol.Bid() + gi_tp * m_symbol.Point();
		break;
	case 2:
		ld_4 = m_symbol.Ask() - gi_tp * m_symbol.Point();
	}
	ld_4 = NormalizeDouble(ld_4, m_symbol.Digits());
	return (ld_4);
}

double CPipesMinerEESignal::R_LSS(int ai_0) {
	double ld_4 = 0;
	switch (ai_0) {
	case 1:
		ld_4 = m_symbol.Bid() - gi_sl * m_symbol.Point();
		break;
	case 2:
		ld_4 = m_symbol.Ask() + gi_sl * m_symbol.Point();
	}
	ld_4 = NormalizeDouble(ld_4, m_symbol.Digits());
	return (0.0);
}


double CPipesMinerEESignal::CO_PL() {
	/*int l_ord_total_0 = 0;
	int l_cmd_4 = 0;
	int l_magic_8 = 0;
	int l_ticket_12 = 0;
	double l_ord_takeprofit_16 = 0;
	double l_ord_stoploss_24 = 0;
	string l_symbol_32 = 0;
	int l_pos_40 = 0;
	double ld_44 = 0;
	double ld_52 = 0;
	double l_ord_open_price_60 = 0;
	double ld_68 = 0;
	l_ord_total_0 = OrdersTotal();
	if (l_ord_total_0 == 0) return (0);
	while (l_pos_40 < l_ord_total_0) {
	if (OrderSelect(l_pos_40, SELECT_BY_POS) == TRUE) {
	l_magic_8 = OrderMagicNumber();
	if (l_magic_8 == Magic_Number) {
	l_symbol_32 = OrderSymbol();
	if (l_symbol_32 == Symbol()) {
	l_ord_takeprofit_16 = OrderTakeProfit();
	l_ord_stoploss_24 = OrderStopLoss();
	if (l_ord_takeprofit_16 == 0.0 && l_ord_stoploss_24 == 0.0) {
	l_ord_open_price_60 = OrderOpenPrice();
	l_cmd_4 = OrderType();
	l_ticket_12 = OrderTicket();
	ld_68 = gd_172 * Point;
	switch (l_cmd_4) {
	case OP_SELL:
	ld_44 = l_ord_open_price_60 - (Bid + ld_68);
	break;
	case OP_BUY:
	ld_44 = Bid - l_ord_open_price_60;
	}
	ld_44 = NormalizeDouble(ld_44, Digits);
	ld_44 *= gd_188;
	if (ld_44 < 0.0) ld_52 = MathAbs(ld_44);
	if (ld_44 >= gi_tp) CloseOrder(l_ticket_12);
	if (ld_52 >= gi_sl) CloseOrder(l_ticket_12);
	}
	}
	}
	}
	l_pos_40++;
	}*/
	return (0);
}

int CPipesMinerEESignal::OT() 
{
	CExpertModel* em = (CExpertModel *)m_expert;
	return em.GetOrderCount(ORDER_TYPE_BUY) + em.GetOrderCount(ORDER_TYPE_SELL);
}

int CPipesMinerEESignal::MMX() {
	double l_point_0 = 0;
	l_point_0 = m_symbol.Point();
	if (l_point_0 >= 0.0001 && l_point_0 < 0.001) return (1);
	if (l_point_0 >= 0.01) return (1);
	return (10);
}

int CPipesMinerEESignal::GLT() {
	/*int l_hist_total_0 = 0;
	int l_ticket_4 = 0;
	int l_magic_8 = 0;
	int l_datetime_12 = 0;
	int l_datetime_16 = 0;
	string l_symbol_20 = "";
	int l_pos_28 = 0;
	l_hist_total_0 = OrdersHistoryTotal();
	if (l_hist_total_0 == 0) return (0);
	while (l_pos_28 < l_hist_total_0) {
	if (OrderSelect(l_pos_28, SELECT_BY_POS, MODE_HISTORY) == TRUE) {
	l_symbol_20 = OrderSymbol();
	if (l_symbol_20 == Symbol()) {
	l_magic_8 = OrderMagicNumber();
	if (l_magic_8 == Magic_Number) {
	l_datetime_16 = OrderCloseTime();
	if (l_datetime_16 > l_datetime_12 && l_datetime_16 > 0) {
	l_ticket_4 = OrderTicket();
	l_datetime_12 = l_datetime_16;
	}
	}
	}
	}
	l_pos_28++;
	}
	return (l_ticket_4);*/
	return 0;
}

ulong CPipesMinerEESignal::_GTC() 
{
	ulong l_ticket_8 = 0;

	CExpertModel* em = (CExpertModel *)m_expert;
	int total_elements = em.TableOrders().Total();
	for(int i=total_elements-1;i>=0;i--)
	{
		CTableOrder *order = em.TableOrders().GetNodeAtIndex(i);
		l_ticket_8 = order.Ticket();
		return (l_ticket_8);
	}

	return (l_ticket_8);
}

void CPipesMinerEESignal::C_ORD() {
	/*
	int li_unused_0 = 0;
	int li_4 = 0;
	int li_unused_8 = 0;
	int li_unused_12 = 0;
	int li_unused_16 = 0;
	li_4 = OT();
	if (li_4 == 0) {
	if (g_ticket_144 > 0) {
	g_ticket_152 = g_ticket_144;
	g_ticket_144 = 0;
	}
	if (gi_184 != false) return;
	gi_184 = true;
	return;
	}
	if (li_4 < gi_100) gi_184 = true; */
}

void CPipesMinerEESignal::G_LO() {
}

bool CPipesMinerEESignal::iTT() {
	MqlDateTime now;
	TimeCurrent(now);
	int London_Time_Shift = GetGMTOffset();

	int l_count_4 = -1;
	int l_hour_8 = 0;
	int li_12 = 0;
	int li_16 = 0;

	l_hour_8 = now.hour;
	l_count_4 = now.day_of_week; 
	if (London_Time_Shift > 0) {
		if (London_Time_Shift > l_hour_8) {
			l_count_4--;
			if (l_count_4 < 0) l_count_4 = 6;
		}
		li_12 = l_hour_8 - London_Time_Shift;
		if (li_12 < 0) li_12 = 24 - li_12;
	}
	if (London_Time_Shift < 0) {
		li_16 = (int)MathAbs(London_Time_Shift);
		if (li_16 + l_hour_8 >= 24) {
			l_count_4++;
			if (l_count_4 > 6) l_count_4 = 0;
		}
		li_12 = l_hour_8 + li_16;
		if (li_12 > 24) li_12 -= 24;
	}
	if (London_Time_Shift == 0) li_12 = l_hour_8;
	if (l_count_4 == 0 || l_count_4 == 6) return (false);
	if (li_12 >= 8 && li_12 <= 16) return (true);
	return (false);
}

bool CPipesMinerEESignal::GL_CLP(double ad_0, double ad_8, double ad_16, double ad_24, double ad_32, double ad_40) 
{
	double l_iopen_52 = 0;
	double l_ima_60 = 0;
	double l_ima_68 = 0;
	double l_imacd_76 = 0;
	double l_imacd_84 = 0;
	double l_imacd_92 = 0;
	double l_imacd_100 = 0;
	double ld_108 = 0;

	m_iMACD_76.Refresh(-1);
	m_iMACD_84_1.Refresh(-1);
	m_iMA_60.Refresh(-1);
	m_iOpen.Refresh(-1);

	l_imacd_76 = m_iMACD_76.Main(0); // iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
	l_imacd_84 = m_iMACD_84_1.Main(10); //iMACD(NULL, 0, 7, 20, 5, PRICE_CLOSE, MODE_MAIN, 10);
	l_imacd_92 = m_iMACD_76.Signal(0); //iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
	l_imacd_100 = m_iMACD_84_1.Signal(10); //iMACD(NULL, 0, 7, 20, 5, PRICE_CLOSE, MODE_SIGNAL, 10);
	l_ima_60 = m_iMA_60.Main(0); //iMA(NULL, 0, 50, gi_112, MODE_SMA, PRICE_CLOSE, 0);
	l_ima_68 = m_iMA_60.Main(10); //iMA(NULL, 0, 50, gi_112, MODE_SMA, PRICE_CLOSE, 10);
	ld_108 = LND_Stock(ad_16, l_imacd_76, l_imacd_92, l_imacd_84, l_imacd_100, "GLIVV", 0, gi_168);

	if (ld_108 > 0.0) 
	{
		int tlv = TLV(ad_0, ad_8, l_ima_60, l_ima_68, gi_124, m_symbol.Point(), "GLIVV", 0, gi_168);

		if (tlv == 1) 
		{
			l_iopen_52 = m_iOpen.GetData(0); //iOpen(NULL, 0, 0);
			int plv = PLV(l_iopen_52, ad_0, ad_8, ad_16, ad_24, ad_32, ad_40, "GLIVV", 0, gi_168);
			if (plv == 1) 
				return (true);
		}
	}
	return (false);
}

bool CPipesMinerEESignal::GL_CSP(double ad_0, double ad_8, double ad_16, double ad_24, double ad_32, double ad_40) {
	int li_unused_48 = 0;
	double l_iopen_52 = 0;
	double l_ima_60 = 0;
	double l_ima_68 = 0;
	double l_imacd_76 = 0;
	double l_imacd_84 = 0;
	double l_imacd_92 = 0;
	double l_imacd_100 = 0;
	double ld_108 = 0;

	m_iMACD_76.Refresh(-1);
	m_iMACD_84_2.Refresh(-1);
	m_iMA_60.Refresh(-1);
	m_iOpen.Refresh(-1);

	l_imacd_76 = m_iMACD_76.Main(0); // iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
	l_imacd_84 = m_iMACD_84_2.Main(10); //iMACD(NULL, 0, 5, 22, 11, PRICE_CLOSE, MODE_MAIN, 10);
	l_imacd_92 = m_iMACD_76.Signal(0); //iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
	l_imacd_100 = m_iMACD_84_2.Signal(10); //iMACD(NULL, 0, 5, 22, 11, PRICE_CLOSE, MODE_SIGNAL, 10);
	l_ima_60 = m_iMA_60.Main(0); //iMA(NULL, 0, 50, gi_112, MODE_SMA, PRICE_CLOSE, 0);
	l_ima_68 = m_iMA_60.Main(10); //iMA(NULL, 0, 50, gi_112, MODE_SMA, PRICE_CLOSE, 10);
	ld_108 = LND_Stock(ad_24, l_imacd_76, l_imacd_92, l_imacd_84, l_imacd_100, "GLIVV", 0, gi_168);
	if (ld_108 > 0.0) {
		if (TSV(ad_0, ad_8, l_ima_60, l_ima_68, gi_124, m_symbol.Point(), "GLIVV", 0, gi_168) == 1) {
			l_iopen_52 = m_iOpen.GetData(0); //iOpen(NULL, 0, 0);
			if (PSV(l_iopen_52, ad_0, ad_8, ad_16, ad_24, ad_32, ad_40, "GLIVV", 0, gi_168) == 1) return (true);
		}
	}
	return (false);
}
