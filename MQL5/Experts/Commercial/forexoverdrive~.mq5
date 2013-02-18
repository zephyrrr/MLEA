#property link      "http://www.eafan.net"

extern string Product_Name = "www.eafan.net";
extern string Creator = "www.eafan.net";
extern int MagicNo = 567;
extern string User_name;
extern string Password;
bool gi_112 = true;
bool gi_116 = true;
extern double RiskPercent = 15.0;
double gd_128 = 0.1;
double gd_136 = 100.0;
int gi_144 = 1;
double gd_148 = 0.0;
double g_pips_156 = 25.0;
double g_pips_164 = 328.0;
double g_slippage_172 = 3.0;
double g_pips_180 = 15.0;
bool gi_unused_188 = true;
int gi_192 = 5;
bool gi_196 = false;
bool gi_200 = false;
double gd_204 = 10.0;
bool gi_212 = false;
bool gi_216 = false;
bool gi_220 = false;
int gi_224;
int gi_228;
int gi_232;
int gi_236;
int g_period_240 = 10;
double gd_244 = 10.0;
double gd_unused_252 = 5.0;
double gd_unused_260 = 10.0;
double gd_unused_268 = 22.0;
double gd_unused_276 = 20.0;
double gd_unused_284 = 26.0;
double gd_unused_292 = 13.0;
double gd_unused_300 = 15.0;
double gd_unused_308 = 10.0;
double g_maxlot_316;
double g_minlot_324;
double g_lotstep_332;
double gd_340;
int gi_348;
double g_price_352;
double gd_360;
double g_point_368;
int g_slippage_376;
bool gi_unused_380 = false;
int gi_384 = 23;
int gi_388 = 30;
int gi_392 = 100;
int gi_396 = 0;
int gi_400 = 0;

int init() {
   if (Point() == 0.00001) g_point_368 = 0.0001;
   else {
      if (Point() == 0.001) g_point_368 = 0.01;
      else g_point_368 = Point();
   }
   return (0);
}

int deinit() {
   return (0);
}

int Crossed(double ad_0, double ad_8) {
   if (ad_0 > ad_8) gi_400 = 1;
   if (ad_0 < ad_8) gi_400 = 2;
   if (gi_400 != gi_396) {
      gi_396 = gi_400;
      return (gi_396);
   }
   return (0);
}

double Predict() {
   double l_ima_0;
   double l_ima_8;
   double l_ima_16;
   double l_istddev_24;
   double ld_ret_32;
   double ld_40 = 0;
   double ld_48 = 0;
   double ld_56 = 0;
   double ld_64 = 0;
   double ld_unused_72 = 0;
   double ld_unused_80 = 0;
   double ld_88 = 0;
   double ld_96 = 0;
   double ld_104 = 0;
   double ld_112 = 0;
   double ld_120 = 0;
   double ld_unused_128 = 0;
   double ld_136 = 0;
   double ld_144 = 0;
   double ld_152 = 0;
   double ld_160 = 0;
   double l_ima_168 = iMA(NULL, 0, g_period_240, 0, MODE_SMA, PRICE_CLOSE, 0);
   for (int li_176 = 1; li_176 <= g_period_240; li_176++) {
      l_ima_0 = iMA(NULL, 0, g_period_240, 0, MODE_SMA, PRICE_CLOSE, li_176);
      l_ima_8 = iMA(NULL, 0, g_period_240, 0, MODE_SMA, PRICE_HIGH, li_176);
      l_ima_16 = iMA(NULL, 0, g_period_240, 0, MODE_SMA, PRICE_LOW, li_176);
      l_istddev_24 = iStdDev(NULL, 0, g_period_240, 0, MODE_SMA, PRICE_CLOSE, li_176);
      ld_40 += (High[li_176] + Low[li_176]) / 2.0;
      ld_48 += Close[li_176];
      ld_56 += ld_40 - ld_48;
      ld_64 += l_ima_0;
      ld_112 += l_istddev_24;
      ld_136 += Close[li_176] - Open[li_176] - (Close[li_176 - 1] - (Open[li_176 - 1]));
      ld_160 = ld_160 + (l_ima_8 - l_ima_0) + (l_ima_16 - l_ima_0);
   }
   ld_88 = ld_40 / g_period_240;
   ld_96 = ld_48 / g_period_240;
   ld_104 = ld_64 / g_period_240;
   ld_120 = ld_112 / g_period_240;
   ld_152 = ld_56 / g_period_240;
   ld_144 = ld_136 / g_period_240;
   if (ld_152 > 0.0 && l_ima_168 > ld_104 && ld_144 > 0.0 && Open[0] < l_ima_168 + ld_120 && Open[0] > l_ima_168) {
      ld_ret_32 = 1;
      gd_360 = 10000.0 * (2.0 * ld_120) + gd_244;
   }
   if (ld_152 < 0.0 && l_ima_168 < ld_104 && ld_144 < 0.0 && Open[0] > l_ima_168 - ld_120 && Open[0] < l_ima_168) {
      ld_ret_32 = 2;
      gd_360 = 10000.0 * (2.0 * ld_120) + gd_244;
   }
   if (ld_152 > 0.0 && l_ima_168 > ld_104 && ld_144 > 0.0 && Open[0] < l_ima_168 - ld_120) {
      ld_ret_32 = 3;
      gd_360 = 10000.0 * (2.0 * ld_120) + 10.0;
   }
   if (ld_152 < 0.0 && l_ima_168 < ld_104 && ld_144 < 0.0 && Open[0] > l_ima_168 + ld_120) {
      ld_ret_32 = 4;
      gd_360 = 10000.0 * (2.0 * ld_120) + 10.0;
   }
   return (ld_ret_32);
}

double Predict2() {
   double ld_ret_0;
   double ld_8 = 0;
   double ld_16 = 0;
   double ld_24 = 0;
   double ld_32 = 0;
   double ld_40 = 0;
   double ld_48 = 0;
   double ld_56 = 0;
   double ld_64 = 0;
   double ld_72 = 0;
   double l_istddev_80 = 0;
   double ld_88 = 0;
   double ld_96 = 0;
   double ld_104 = 0;
   l_istddev_80 = iStdDev(NULL, 0, 10, 0, MODE_EMA, PRICE_CLOSE, 0);
   double l_istddev_112 = iStdDev(NULL, 0, 20, 0, MODE_EMA, PRICE_CLOSE, 0);
   double l_ima_120 = iMA(NULL, PERIOD_M30, 10, 0, MODE_SMA, PRICE_CLOSE, 0);
   double l_ima_128 = iMA(NULL, PERIOD_M30, 10, 0, MODE_SMA, PRICE_CLOSE, 1);
   double l_ima_136 = iMA(NULL, PERIOD_M30, 10, 0, MODE_SMA, PRICE_CLOSE, 2);
   for (int li_144 = 1; li_144 <= 20; li_144++) {
      ld_8 += Close[li_144];
      ld_16 += High[li_144] - Low[li_144];
      ld_24 += Close[li_144] - Open[li_144];
      if (li_144 <= 10) {
         ld_88 += Close[li_144];
         ld_96 += High[li_144] - Low[li_144];
         ld_104 += Close[li_144] - Open[li_144];
      }
   }
   ld_32 = ld_8 / 20.0;
   ld_40 = ld_16 / 20.0;
   ld_48 = ld_24 / 20.0;
   double ld_148 = ld_88 / 10.0;
   double ld_156 = ld_96 / 10.0;
   double ld_164 = ld_104 / 10.0;
   ld_72 = (Open[0] - ld_148) / l_istddev_80;
   double ld_172 = (Open[0] - ld_32) / l_istddev_112;
   ld_56 = ld_148 + 0.308 * ld_156;
   double ld_180 = ld_32 + 0.18 * ld_40;
   ld_64 = ld_148 - 0.308 * ld_156;
   double ld_188 = ld_32 - 0.18 * ld_40;
   if ((l_ima_120 - l_ima_136 > l_ima_128 - l_ima_136 + 0.0002 && ld_164 > 0.0 && ld_104 > 0.0 && Open[0] > ld_64 && Open[0] <= ld_148 + ld_72 * ld_164 && ld_72 < 0.0 &&
      High[1] - Low[1] < 1.777 * ld_156) || (l_ima_120 - l_ima_136 > l_ima_128 - l_ima_136 + 0.0002 && ld_48 > 0.0 && ld_24 > 0.0 && Open[0] > ld_188 && Open[0] <= ld_32 + ld_72 * ld_48 && ld_172 < 0.0 && High[1] - Low[1] < 1.586 * ld_156)) {
      ld_ret_0 = 1;
      gd_360 = 10000.0 * l_istddev_112 + 10.0;
   }
   if ((l_ima_120 - l_ima_136 < l_ima_128 - l_ima_136 - 0.0002 && ld_164 < 0.0 && ld_104 < 0.0 && Open[0] < ld_56 && Open[0] >= ld_148 + ld_72 * ld_164 && ld_72 > 0.0 &&
      High[1] - Low[1] < 1.777 * ld_156) || (l_ima_120 - l_ima_136 < l_ima_128 - l_ima_136 - 0.0002 && ld_48 < 0.0 && ld_24 < 0.0 && Open[0] < ld_180 && Open[0] >= ld_32 + ld_72 * ld_48 && ld_172 > 0.0 && High[1] - Low[1] < 1.586 * ld_156)) {
      ld_ret_0 = 2;
      gd_360 = 10000.0 * l_istddev_112 + 10.0;
   }
   if (l_ima_120 - l_ima_136 > l_ima_128 - l_ima_136 + 0.0002 && ld_48 > 0.0 && ld_24 > 0.0 && Open[0] > ld_188 && Open[0] <= ld_32 + ld_72 * ld_48 && ld_172 < 0.0 &&
      High[1] - Low[1] > 1.586 * ld_156) {
      ld_ret_0 = 3;
      g_price_352 = 10000.0 * l_istddev_112 + 10.0;
   }
   if (l_ima_120 - l_ima_136 < l_ima_128 - l_ima_136 - 0.0002 && ld_48 < 0.0 && ld_24 < 0.0 && Open[0] < ld_180 && Open[0] >= ld_32 + ld_72 * ld_48 && ld_172 > 0.0 &&
      High[1] - Low[1] > 1.586 * ld_156) {
      ld_ret_0 = 4;
      g_price_352 = 10000.0 * l_istddev_112 + 10.0;
   }
   return (ld_ret_0);
}

int start() {
   int l_ticket_0;
   double l_price_4;
   bool li_12;
   bool li_16;
   bool li_20;
   bool li_24;
   bool li_28;
   bool li_32;
   bool li_36;
   bool li_40;
   bool li_44;
   bool li_48;
   bool li_52;
   bool li_56;
   double l_price_60;
   int l_hour_68 = TimeHour(TimeCurrent());
   int l_count_72 = 0;
   int l_count_76 = 0;
   double l_high_80 = High[iHighest(NULL, 0, MODE_HIGH, gi_392, 0)];
   double l_low_88 = Low[iLowest(NULL, 0, MODE_LOW, gi_392, 0)];
   double l_imacd_96 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
   double l_imacd_104 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
   double l_imacd_112 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
   double l_imacd_120 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);
   double l_ima_128 = iMA(NULL, 0, 5, 0, MODE_EMA, PRICE_HIGH, 0);
   double l_ima_136 = iMA(NULL, 0, 5, 0, MODE_EMA, PRICE_HIGH, 1);
   double l_ima_144 = iMA(NULL, 0, 5, 0, MODE_EMA, PRICE_LOW, 0);
   double l_ima_152 = iMA(NULL, 0, 5, 0, MODE_EMA, PRICE_LOW, 1);
   double l_ima_160 = iMA(NULL, 0, 22, 0, MODE_SMA, PRICE_CLOSE, 0);
   double l_ima_168 = iMA(NULL, 0, 22, 0, MODE_SMA, PRICE_CLOSE, 5);
   double l_ima_176 = iMA(NULL, 0, 22, 0, MODE_SMA, PRICE_CLOSE, 1);
   double l_ima_184 = iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, 0);
   double l_ima_192 = iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, 1);
   double l_ima_200 = iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, 2);
   double l_ima_208 = iMA(NULL, 0, 10, 0, MODE_EMA, PRICE_CLOSE, 1);
   double l_ima_216 = iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, 5);
   double l_ima_224 = iMA(NULL, 0, 5, 0, MODE_EMA, PRICE_CLOSE, 0);
   double l_ima_232 = iMA(NULL, 0, 5, 0, MODE_EMA, PRICE_CLOSE, 1);
   int li_240 = Crossed(l_ima_232, l_ima_176);
   double l_ima_244 = iMA(NULL, 0, gi_392, 0, MODE_SMA, PRICE_CLOSE, 0);
   double l_istddev_252 = iStdDev(NULL, 0, gi_392, 0, MODE_SMA, PRICE_CLOSE, 0);
   double l_istddev_260 = iStdDev(NULL, 0, 20, 0, MODE_EMA, PRICE_CLOSE, 0);
   double l_istddev_268 = iStdDev(NULL, 0, 20, 0, MODE_EMA, PRICE_CLOSE, 1);
   double l_iwpr_276 = iWPR(NULL, 0, 26, 0);
   double l_iwpr_284 = iWPR(NULL, 0, 26, 1);
   double l_iwpr_292 = iWPR(NULL, 0, 26, 2);
   double l_iwpr_300 = iWPR(NULL, 0, 114, 0);
   double l_iwpr_308 = iWPR(NULL, 0, 114, 1);
   double l_idemarker_316 = iDeMarker(NULL, 0, 13, 0);
   double l_idemarker_324 = iDeMarker(NULL, 0, 13, 1);
   double l_idemarker_332 = iDeMarker(NULL, 0, 13, 2);
   double l_istochastic_340 = iStochastic(NULL, 0, 15, 6, 7, MODE_EMA, 0, MODE_MAIN, 0);
   double l_istochastic_348 = iStochastic(NULL, 0, 15, 6, 7, MODE_EMA, 0, MODE_MAIN, 1);
   double l_istochastic_356 = iStochastic(NULL, 0, 15, 6, 7, MODE_EMA, 0, MODE_SIGNAL, 0);
   double l_istochastic_364 = iStochastic(NULL, 0, 15, 6, 7, MODE_EMA, 0, MODE_SIGNAL, 1);
   if (l_istochastic_348 < l_istochastic_364 - 5.0 && l_istochastic_340 >= l_istochastic_356) li_20 = true;
   if (l_istochastic_348 > l_istochastic_364 + 5.0 && l_istochastic_340 <= l_istochastic_356) li_24 = true;
   if (l_istochastic_348 > l_istochastic_364 && l_istochastic_340 > l_istochastic_356) li_28 = true;
   if (l_istochastic_348 < l_istochastic_364 && l_istochastic_340 < l_istochastic_356) li_32 = true;
   double l_istochastic_372 = iStochastic(NULL, 0, 10, 5, 5, MODE_SMA, 0, MODE_MAIN, 0);
   double l_istochastic_380 = iStochastic(NULL, 0, 10, 5, 5, MODE_SMA, 0, MODE_MAIN, 1);
   double l_istochastic_388 = iStochastic(NULL, 0, 10, 5, 5, MODE_SMA, 0, MODE_SIGNAL, 0);
   double l_istochastic_396 = iStochastic(NULL, 0, 10, 5, 5, MODE_SMA, 0, MODE_SIGNAL, 1);
   if (l_istochastic_380 < l_istochastic_396 - 5.0 && l_istochastic_372 >= l_istochastic_388) li_36 = true;
   if (l_istochastic_380 > l_istochastic_396 + 5.0 && l_istochastic_372 <= l_istochastic_388) li_40 = true;
   if (l_istochastic_380 < l_istochastic_396 && l_istochastic_372 >= l_istochastic_388) li_44 = true;
   if (l_istochastic_380 > l_istochastic_396 && l_istochastic_372 <= l_istochastic_388) li_48 = true;
   if (l_istochastic_380 > l_istochastic_396 && l_istochastic_372 > l_istochastic_388) li_52 = true;
   if (l_istochastic_380 < l_istochastic_396 && l_istochastic_372 < l_istochastic_388) li_56 = true;
   double l_irsi_404 = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
   double l_irsi_412 = iRSI(NULL, 0, 14, PRICE_CLOSE, 1);
   double l_irsi_420 = iRSI(NULL, 0, 14, PRICE_CLOSE, 2);
   double ld_unused_428 = 0;
   if (l_irsi_404 < 30.0) ld_unused_428 = 1;
   if (l_irsi_404 > 70.0) ld_unused_428 = 2;
   double l_ibands_436 = iBands(NULL, 0, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);
   double l_ibands_444 = iBands(NULL, 0, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 2);
   double l_ibands_452 = iBands(NULL, 0, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double l_ibands_460 = iBands(NULL, 0, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 2);
   double l_iadx_468 = iADX(NULL, 0, 14, PRICE_HIGH, MODE_MAIN, 0);
   double l_iadx_476 = iADX(NULL, 0, 14, PRICE_HIGH, MODE_PLUSDI, 0);
   double l_iadx_484 = iADX(NULL, 0, 14, PRICE_HIGH, MODE_PLUSDI, 1);
   double l_iadx_492 = iADX(NULL, 0, 14, PRICE_HIGH, MODE_MINUSDI, 0);
   double l_iadx_500 = iADX(NULL, 0, 14, PRICE_HIGH, MODE_MINUSDI, 1);
   if (l_iadx_476 > l_iadx_492) li_16 = true;
   if (l_iadx_492 > l_iadx_476) li_12 = true;
   if (l_iadx_468 < 30.0) {
      li_12 = false;
      li_16 = false;
   }
   g_maxlot_316 = MarketInfo(Symbol(), MODE_MAXLOT);
   g_minlot_324 = MarketInfo(Symbol(), MODE_MINLOT);
   g_lotstep_332 = MarketInfo(Symbol(), MODE_LOTSTEP);
   gd_340 = MarketInfo(Symbol(), MODE_MARGINREQUIRED) * g_lotstep_332;
   gi_348 = 3600 * gi_384 + 60 * gi_388;
   int li_unused_508 = MarketInfo(Symbol(), MODE_STOPLEVEL);
   g_slippage_376 = g_slippage_172;
   Comment("\n", "    Copyright ?2009 - Forex Overdrive Team", 
      "\n", "    ======================================", 
      "\n", "     Time      : ", TimeToStr(TimeCurrent()), 
      "\n", 
      "\n", "     Total Profit/Loss    : ", AccountProfit(), 
   "\n");
   if (DayOfWeek() == 5 && gi_112 == false && gi_220) return (0);
   if (!isTradeTime()) return (0);
   if (Bars < 100) {
      Print("bars less than 100");
      return (0);
   }
   if (!IsConnected()) {
      Print("Error 1");
      Sleep(5000);
      return (0);
   }
   double l_price_512 = g_pips_164;
   if (l_price_512 <= 0.0) l_price_512 = 0;
   bool li_520 = false;
   bool li_524 = false;
   int l_ord_total_528 = OrdersTotal();
   if (l_ord_total_528 > 0) {
      for (int l_pos_532 = 0; l_pos_532 < l_ord_total_528; l_pos_532++) {
         OrderSelect(l_pos_532, SELECT_BY_POS);
         if (OrderMagicNumber() == MagicNo) {
            if (OrderType() <= OP_SELL && OrderSymbol() == Symbol()) l_count_72++;
            else l_count_76++;
         }
         if (OrderType() == OP_BUY) li_520 = true;
         if (OrderType() == OP_SELL) li_524 = true;
      }
   }
   if (l_count_72 < gi_144) {
      if (l_count_72 > 0) {
         OrderSelect(l_count_72 - 1, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber() == MagicNo)
            if (TimeCurrent() - OrderOpenTime() <= 60.0 * gd_148) return (0);
      }
      if (AccountFreeMargin() < 100.0 * LotsOptimized()) {
         Print("You do not have enough money to trade! You have = ", AccountFreeMargin());
         return (0);
      }
      if (!IsTradeAllowed()) {
         Print("Wait...");
         Sleep(1000);
         return (0);
      }
      if (gi_216) {
         li_520 = false;
         li_524 = false;
      }
      if (li_524 == false) {
         if (Predict() == 3.0 && ((l_iwpr_276 > l_iwpr_284 + 9.0 && li_52) || (l_iwpr_276 > l_iwpr_284 + 9.0 && li_28) && l_idemarker_316 > l_idemarker_324 + 0.05 && l_ima_192 < l_ima_176) ||
            (l_istochastic_340 < 40.0 && Open[1] < l_ima_152 && l_ima_160 > l_ima_216) || (l_istochastic_380 < 40.0 && l_ima_160 > l_ima_176 && l_ima_208 > l_ima_192) || (Open[2] > l_ima_192 &&
            Open[1] < Close[1] && Open[0] > Close[1] && li_28 && l_iwpr_276 > l_iwpr_284 + 7.0 && l_idemarker_316 > l_idemarker_324 + 0.05)) {
            l_ticket_0 = OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, g_slippage_376, 0, 0, "Ewww.eafan.net", MagicNo, 0, Green);
            if (l_ticket_0 > 0) {
               if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) Print("Buy order opened : ", OrderOpenPrice());
               RefreshRates();
               if (l_price_512 > 0.0) l_price_512 = Ask - g_pips_164 * g_point_368;
               g_price_352 = Ask + gd_360 * g_point_368;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_512, g_price_352, 0, CLR_NONE);
            } else Print("Error opening Buy order : ", GetLastError());
            return (0);
         }
         if (Predict() == 1.0 && ((l_iwpr_276 > l_iwpr_284 + 9.0 && l_istochastic_372 < 60.0 && li_52) || (l_iwpr_276 > l_iwpr_284 + 18.0 && l_istochastic_340 < 70.0 && li_28) &&
            l_iwpr_276 < -15.0 && l_idemarker_316 > l_idemarker_324 && l_ima_192 > l_ima_176 && l_ima_160 > l_ima_176) || (l_istochastic_340 < 40.0 && Open[1] > l_ima_152 && l_ima_184 < l_ima_216) ||
            (l_istochastic_380 < 40.0 && l_ima_160 > l_ima_176 && l_ima_208 > l_ima_192) || (Open[2] > l_ima_192 && Open[1] < Close[1] && Open[0] > Close[1] && li_28 && l_iwpr_276 > l_iwpr_284 +
            7.0 && l_idemarker_316 > l_idemarker_324 + 0.1)) {
            l_ticket_0 = OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, g_slippage_376, 0, 0, "www.eafan.net", MagicNo, 0, Green);
            if (l_ticket_0 > 0) {
               if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) Print("BUY order opened : ", OrderOpenPrice());
               RefreshRates();
               if (l_price_512 > 0.0) l_price_512 = Ask - g_pips_164 * g_point_368;
               g_price_352 = Ask + gd_360 * g_point_368;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_512, g_price_352, 0, CLR_NONE);
            } else Print("Error opening Buy order : ", GetLastError());
            return (0);
         }
         if ((Predict2() == 1.0 && (l_istochastic_340 < 50.0 && Open[1] > l_ima_152 && l_ima_184 < l_ima_216 && li_28 && Open[0] > Close[1] && Open[1] > Close[1])) || (Predict2() == 1.0 &&
            l_istochastic_340 < 50.0 && li_28 && l_iwpr_276 > l_iwpr_284 + 7.0 && Open[2] < Close[2] && Open[0] > Close[1] && Open[1] > Close[1]) || (Predict2() == 3.0 && Open[0] > Close[1] && Open[1] < Close[1])) {
            l_ticket_0 = OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, g_slippage_376, 0, 0, "www.eafan.net", MagicNo, 0, Green);
            if (l_ticket_0 > 0) {
               if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) Print("Buy order opened : ", OrderOpenPrice());
               RefreshRates();
               if (l_price_512 > 0.0) l_price_512 = Ask - g_pips_164 * g_point_368;
               g_price_352 = Ask + gd_360 * g_point_368;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_512, g_price_352, 0, CLR_NONE);
            } else Print("Error opening Buy order : ", GetLastError());
            return (0);
         }
         if ((l_ima_224 > l_ima_232 && l_ima_160 > l_ima_176 + 0.0002 && Open[0] < l_ima_160 + l_istddev_260 && (l_istochastic_372 > l_istochastic_380 && l_istochastic_388 > l_istochastic_396) ||
            (l_istochastic_340 > l_istochastic_348 && l_istochastic_356 > l_istochastic_364) && l_iwpr_276 < -15.0 && l_iwpr_276 > l_iwpr_284 + 3.0 && li_28 && l_ima_184 > l_ima_160 && Open[0] > l_ima_224) ||
            (l_iwpr_300 > l_iwpr_308 && l_iwpr_300 > -20.0 && l_iwpr_308 > -20.0 && l_iwpr_276 > l_iwpr_284 + 25.0 && l_iwpr_276 < -15.0 && l_iwpr_284 < l_iwpr_292 && l_istddev_260 > l_istddev_268 &&
            l_idemarker_316 > l_idemarker_324 && l_ima_160 > l_ima_168 && li_28 && l_iadx_468 > 20.0) || (Low[1] < l_ima_160 - 3.2 * l_istddev_268 && l_iwpr_276 > l_iwpr_284 + 7.0 && l_iwpr_276 < -75.0 && li_28 && (l_istochastic_340 >= 20.0 && l_istddev_260 > l_istddev_268) ||
            l_iwpr_284 < l_iwpr_292) || (l_ima_128 > l_ima_184 && l_ima_128 > l_ima_136 && l_ima_136 < l_ima_184 && l_ima_160 > l_ima_168 + 0.0002 && Open[1] < Close[1] && li_28 && l_iwpr_276 > l_iwpr_284 + 7.0 && l_idemarker_316 > l_idemarker_324 && l_iadx_476 > l_iadx_492) ||
            (l_imacd_96 > l_imacd_104 && l_imacd_96 < -0.0003 && l_imacd_96 > l_imacd_112 && l_imacd_104 < l_imacd_120 && li_28 && l_iwpr_276 > l_iwpr_284 && li_16 && l_ima_208 > l_ima_192 &&
            Close[1] < Open[0] && Close[1] > Open[1] && l_istddev_260 > l_istddev_268) || (l_iwpr_276 >= -75.0 && l_iwpr_276 > l_iwpr_284 + 9.0 && l_iwpr_284 < l_iwpr_292 - 5.0 && Open[2] < Close[2] && Open[1] > Close[2] && Open[1] < Close[1] && li_28 && l_ima_184 > l_ima_192 + 0.0005 && l_iadx_468 > 25.0 && l_iadx_476 > 25.0 && l_ima_208 > l_ima_192) ||
            (li_240 == 1 && l_iadx_476 > 25.0 && l_iwpr_276 > l_iwpr_284 + 12.0 && l_iadx_468 > 25.0 && l_iadx_476 > l_iadx_484 || l_ima_208 > l_ima_192 && l_ima_160 >= l_ima_176 &&
            l_ima_232 < l_ima_216 && li_28) || (Close[1] > l_ima_192 && Open[1] < l_ima_192 && l_ima_208 > l_ima_192 && l_iadx_468 > 30.0 && l_iadx_476 > 25.0 && l_ima_160 > l_ima_168 + 0.0003 && li_28 && l_iwpr_276 > l_iwpr_284 + 18.0 && l_iwpr_284 > l_iwpr_292 + 7.0) ||
            (l_ima_224 > l_ima_232 && l_ima_184 > l_ima_192 && l_ima_160 > l_ima_176 && l_ima_160 > l_ima_168 + 0.0005 && l_ima_184 - l_ima_192 > l_ima_160 - l_ima_176 && l_ima_224 - l_ima_160 > l_ima_232 - l_ima_176 &&
            li_28 && l_iwpr_276 < -15.0 && l_iwpr_276 > l_iwpr_284 + 15.0 && l_ima_224 > l_ima_184 && l_ima_184 > l_ima_160 && Open[0] > l_ima_224)) {
            l_ticket_0 = OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, g_slippage_376, 0, 0, "www.eafan.net", MagicNo, 0, Green);
            if (l_ticket_0 > 0) {
               if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) Print("Buy order opened : ", OrderOpenPrice());
               RefreshRates();
               if (l_price_512 > 0.0) l_price_512 = Ask - g_pips_164 * g_point_368;
               g_price_352 = Ask + g_pips_156 * g_point_368;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_512, g_price_352, 0, CLR_NONE);
            } else Print("Error opening Buy order : ", GetLastError());
            return (0);
         }
         if ((li_20 && l_imacd_96 > l_imacd_104 && l_imacd_96 > l_imacd_112 && l_ima_208 > l_ima_192 && li_16 && l_iwpr_276 > l_iwpr_284 + 7.0 && l_istochastic_340 > l_istochastic_348 &&
            l_istochastic_356 > l_istochastic_364 + 1.0) || (li_20 && l_imacd_96 > l_imacd_104 && l_imacd_96 > l_imacd_112 && Open[0] > Close[1] && l_ima_184 < l_ima_192 && l_iwpr_276 > l_iwpr_284 + 9.0 && li_16 && l_ima_208 > l_ima_192) ||
            (li_20 && l_istochastic_340 < 30.0 && Open[1] > l_ima_152 && Close[1] > l_ima_216 && Open[0] > l_ima_128 && l_ima_184 < l_ima_216 && l_ima_184 < l_ima_192) || (li_20 &&
            Open[1] > l_ima_152 && Open[0] > l_ima_128 && Open[1] < Close[1] && l_iwpr_276 > l_iwpr_284 + 7.0 && l_idemarker_316 > l_idemarker_324 + 0.08 && l_istddev_260 > l_istddev_268)) {
            l_ticket_0 = OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, g_slippage_376, 0, 0, "www.eafan.net", MagicNo, 0, Green);
            if (l_ticket_0 > 0) {
               if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) Print("Buy order opened : ", OrderOpenPrice());
               RefreshRates();
               if (l_price_512 > 0.0) l_price_512 = Ask - g_pips_164 * g_point_368;
               g_price_352 = Ask + g_pips_156 * g_point_368;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_512, g_price_352, 0, CLR_NONE);
            } else Print("Error opening Buy order : ", GetLastError());
            return (0);
         }
         if ((Close[4] < Close[3] && Close[3] > Close[2] && Close[2] > Close[1] && Open[0] > Close[1] && High[1] - Close[1] < Open[1] - Low[1] && l_ima_184 > l_ima_216 + 0.0005 &&
            l_iwpr_276 > l_iwpr_284 + 9.0 && l_iadx_468 > 25.0 && l_iadx_476 > 25.0 && l_iwpr_284 > l_iwpr_292) || (Open[1] < Close[1] && Close[2] < l_ima_160 && Close[1] > l_ima_160 && Open[1] > l_ima_224 && Open[0] > l_ima_128 && l_ima_160 > l_ima_168 + 0.0005 && l_iwpr_276 < -5.0 && l_iwpr_276 > l_iwpr_284 + 7.0 && l_idemarker_316 > l_idemarker_324 && l_idemarker_324 > l_idemarker_332) ||
            (l_iadx_476 > l_iadx_484 && l_iadx_484 < l_iadx_500 && l_iadx_476 >= l_iadx_492 && l_iadx_468 >= 35.0 && l_iadx_476 > 25.0 && l_iwpr_276 > l_iwpr_284 + 15.0 && li_28) ||
            (l_irsi_412 < l_irsi_420 && l_irsi_404 > l_irsi_412 + 5.0 && l_irsi_412 < 30.0 && l_ima_208 > l_ima_192 && l_iadx_468 > 25.0 && l_iadx_476 > 25.0)) {
            l_ticket_0 = OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, g_slippage_376, 0, 0, "www.eafan.net", MagicNo, 0, Green);
            if (l_ticket_0 > 0) {
               if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) Print("BUY order opened : ", OrderOpenPrice());
               RefreshRates();
               if (l_price_512 > 0.0) l_price_512 = Ask - g_pips_164 * g_point_368;
               g_price_352 = Ask + g_pips_156 * g_point_368;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_512, g_price_352, 0, CLR_NONE);
            } else Print("Error opening Buy order : ", GetLastError());
            return (0);
         }
         if ((li_36 && Open[1] > l_ima_152 && Open[0] > l_ima_128 && Open[1] < Close[1] && l_ima_160 > l_ima_176 + 0.0002 && l_iadx_468 > 25.0 && l_iadx_476 > 25.0 && l_iwpr_276 > l_iwpr_284 +
            9.0 && l_ima_208 > l_ima_192) || (li_36 && l_imacd_96 > l_imacd_104 && l_imacd_96 < 0.0 && l_imacd_96 > l_imacd_112 && l_iadx_468 > 25.0 && l_iadx_476 > 25.0 && l_iwpr_276 > l_iwpr_284 + 7.0 && l_istochastic_372 > l_istochastic_380 && l_istochastic_388 > l_istochastic_396 + 1.0) ||
            ((li_44 && l_istochastic_380 < 25.0) || (li_36 && l_istochastic_380 < 30.0) && l_ima_160 > l_ima_176 + 0.0002 && l_ima_208 > l_ima_192)) {
            l_ticket_0 = OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, g_slippage_376, 0, 0, "www.eafan.net", MagicNo, 0, Green);
            if (l_ticket_0 > 0) {
               if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) Print("Buy order opened : ", OrderOpenPrice());
               RefreshRates();
               if (l_price_512 > 0.0) l_price_512 = Ask - g_pips_164 * g_point_368;
               g_price_352 = Ask + g_pips_156 * g_point_368;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_512, g_price_352, 0, CLR_NONE);
            } else Print("Error opening Buy order : ", GetLastError());
            return (0);
         }
         if ((Close[2] < l_ibands_444 && Open[1] > l_ibands_436 && Open[0] > Close[1] && Open[1] < Close[1] && li_52 && l_iwpr_276 > l_iwpr_284 + 12.0 && l_istochastic_372 > l_istochastic_380 +
            3.0 && l_istochastic_388 > l_istochastic_396 && l_ima_208 > l_ima_192 && l_ima_184 > l_ima_192) || (Close[3] > l_ima_216 && Open[2] > l_ima_192 && Open[1] < Close[1] && Open[1] > Close[2] && Close[1] > l_ima_160 + 2.2 * l_istddev_268 && Open[0] > Close[1] && l_istddev_260 > l_istddev_268 && li_28 && l_iwpr_276 > l_iwpr_284 + 7.0 && l_iwpr_276 < -15.0) ||
            (l_ima_192 < l_ima_200 - 0.0001 && l_ima_184 > l_ima_192 + 0.0002 && l_ima_184 > l_ima_200 + 0.0001 && l_ima_192 < l_ima_176 && li_28 || li_52 && Open[0] > Close[1]) ||
            (l_ima_176 - l_ima_244 < l_ima_160 - l_ima_244 && l_ima_244 < (l_high_80 + l_low_88) / 2.0 - 2.0 * l_istddev_252 && l_ima_160 - l_ima_244 > l_istddev_252 && Open[0] > Close[1] &&
            li_28) || (iSAR(NULL, 0, 0.02, 0.2, 1) > Close[1] && iSAR(NULL, 0, 0.02, 0.2, 0) < Open[0] && iSAR(NULL, PERIOD_M15, 0.02, 0.2, 1) > iClose(NULL, PERIOD_M15, 1) && iSAR(NULL, PERIOD_M15, 0.02, 0.2, 0) < iOpen(NULL, PERIOD_M15, 0) && iSAR(NULL, PERIOD_M30, 0.02, 0.2, 1) > iClose(NULL, PERIOD_M30, 1) && iSAR(NULL, PERIOD_M30, 0.02, 0.2, 0) < iOpen(NULL, PERIOD_M30, 0) && (Open[0] < Close[0] && Open[0] > Close[1] && Ask > l_ima_160) ||
            (l_ima_224 > l_ima_232 && l_imacd_96 > l_imacd_104 && l_imacd_96 < 0.0))) {
            l_ticket_0 = OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, g_slippage_376, 0, 0, "www.eafan.net", MagicNo, 0, Green);
            if (l_ticket_0 > 0) {
               if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) Print("Buy order opened : ", OrderOpenPrice());
               RefreshRates();
               if (l_price_512 > 0.0) l_price_512 = Ask - g_pips_164 * g_point_368;
               g_price_352 = Ask + g_pips_156 * g_point_368;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_512, g_price_352, 0, CLR_NONE);
            } else Print("Error opening Buy order : ", GetLastError());
            return (0);
         }
         if (Predict() == 1.0 || Predict2() == 1.0 && Ask < (l_high_80 + l_low_88) / 2.0 && li_28 && l_istochastic_340 < 45.0) {
            l_ticket_0 = OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, g_slippage_376, 0, 0, "www.eafan.net", MagicNo, 0, Green);
            if (l_ticket_0 > 0) {
               if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) Print("Buy order opened : ", OrderOpenPrice());
               RefreshRates();
               if (l_price_512 > 0.0) l_price_512 = Ask - g_pips_164 * g_point_368;
               g_price_352 = Ask + 10.0 * g_point_368;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_512, g_price_352, 0, CLR_NONE);
            } else Print("Error opening Buy order : ", GetLastError());
            return (0);
         }
      }
      if (li_520 == false) {
         if (Predict() == 4.0 && ((l_iwpr_276 < l_iwpr_284 - 9.0 && li_56) || (l_iwpr_276 < l_iwpr_284 - 9.0 && li_32) && l_idemarker_316 < l_idemarker_324 - 0.05 && l_ima_192 > l_ima_176) ||
            (l_istochastic_340 > 60.0 && Open[1] > l_ima_136 && l_ima_160 < l_ima_216) || (l_istochastic_380 > 60.0 && l_ima_160 < l_ima_176 && l_ima_208 < l_ima_192) || (Open[2] < l_ima_192 &&
            Open[1] > Close[1] && Open[0] < Close[1] && li_32 && l_iwpr_276 < l_iwpr_284 - 7.0 && l_idemarker_316 < l_idemarker_324 - 0.05)) {
            l_ticket_0 = OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, g_slippage_376, 0, 0, "www.eafan.net", MagicNo, 0, Red);
            if (l_ticket_0 > 0) {
               if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) Print("Sell order opened : ", OrderOpenPrice());
               RefreshRates();
               if (l_price_512 > 0.0) l_price_512 = Bid + g_pips_164 * g_point_368;
               g_price_352 = Bid - gd_360 * g_point_368;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_512, g_price_352, 0, CLR_NONE);
            } else Print("Error opening Sell order : ", GetLastError());
            return (0);
         }
         if (Predict() == 2.0 && ((l_iwpr_276 < l_iwpr_284 - 9.0 && l_istochastic_372 > 40.0 && li_56) || (l_iwpr_276 < l_iwpr_284 - 18.0 && l_istochastic_340 > 30.0 && li_32) &&
            l_iwpr_276 > -85.0 && l_idemarker_316 < l_idemarker_324 && l_ima_192 < l_ima_176 && l_ima_160 < l_ima_176) || (l_istochastic_340 > 60.0 && Open[1] < l_ima_136 && l_ima_184 > l_ima_216) ||
            (l_istochastic_380 > 60.0 && l_ima_160 < l_ima_176 && l_ima_208 < l_ima_192) || (Open[2] < l_ima_192 && Open[1] > Close[1] && Open[0] < Close[1] && li_32 && l_iwpr_276 < l_iwpr_284 - 7.0 &&
            l_idemarker_316 < l_idemarker_324 - 0.1)) {
            l_ticket_0 = OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, g_slippage_376, 0, 0, "www.eafan.net", MagicNo, 0, Red);
            if (l_ticket_0 > 0) {
               if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) Print("Sell order opened : ", OrderOpenPrice());
               RefreshRates();
               if (l_price_512 > 0.0) l_price_512 = Bid + g_pips_164 * g_point_368;
               g_price_352 = Bid - gd_360 * g_point_368;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_512, g_price_352, 0, CLR_NONE);
            } else Print("Error opening Sell order : ", GetLastError());
            return (0);
         }
         if ((Predict2() == 2.0 && (l_istochastic_340 > 50.0 && Open[1] < l_ima_136 && l_ima_184 > l_ima_216 && li_32 && Open[0] < Close[1] && Open[1] < Close[1])) || (Predict2() == 2.0 &&
            li_32 && l_istochastic_340 > 50.0 && l_iwpr_276 < l_iwpr_284 - 7.0 && Open[2] > Close[2] && Open[0] < Close[1] && Open[1] < Close[1]) || (Predict2() == 4.0 && Open[0] < Close[1] && Open[1] > Close[1])) {
            l_ticket_0 = OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, g_slippage_376, 0, 0, "www.eafan.net", MagicNo, 0, Red);
            if (l_ticket_0 > 0) {
               if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) Print("Sell order opened : ", OrderOpenPrice());
               RefreshRates();
               if (l_price_512 > 0.0) l_price_512 = Bid + g_pips_164 * g_point_368;
               g_price_352 = Bid - gd_360 * g_point_368;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_512, g_price_352, 0, CLR_NONE);
            } else Print("Error opening Sell order : ", GetLastError());
            return (0);
         }
         if ((l_ima_224 < l_ima_232 && l_ima_160 < l_ima_176 - 0.0002 && Open[0] >= l_ima_160 - l_istddev_260 && (l_istochastic_372 < l_istochastic_380 && l_istochastic_388 < l_istochastic_396) ||
            (l_istochastic_340 < l_istochastic_348 && l_istochastic_356 < l_istochastic_364) && l_iwpr_276 > -85.0 && l_iwpr_276 < l_iwpr_284 - 3.0 && li_32 && l_ima_184 < l_ima_160 && Open[0] < l_ima_224) ||
            (l_iwpr_300 < l_iwpr_308 && l_iwpr_300 < -80.0 && l_iwpr_308 < -80.0 && l_iwpr_276 < l_iwpr_284 - 25.0 && l_iwpr_276 > -85.0 && l_iwpr_284 > l_iwpr_292 && l_istddev_260 > l_istddev_268 &&
            l_idemarker_316 < l_idemarker_324 && l_ima_160 < l_ima_168 && li_32 && l_iadx_468 > 20.0) || (High[1] > l_ima_160 + 3.2 * l_istddev_268 && l_iwpr_276 < l_iwpr_284 - 7.0 && l_iwpr_276 > -25.0 && li_32 && (l_istochastic_340 <= 80.0 && l_istddev_260 > l_istddev_268) ||
            l_iwpr_284 > l_iwpr_292) || (l_ima_144 < l_ima_184 && l_ima_144 < l_ima_152 && l_ima_152 > l_ima_184 && l_ima_160 < l_ima_168 - 0.0002 && Open[1] > Close[1] && li_32 && l_iwpr_276 < l_iwpr_284 - 7.0 && l_idemarker_316 < l_idemarker_324 && l_iadx_492 > l_iadx_476) ||
            (l_imacd_96 < l_imacd_104 && l_imacd_96 > 0.0003 && l_imacd_96 < l_imacd_112 && l_imacd_104 > l_imacd_120 && li_32 && l_iwpr_276 < l_iwpr_284 && li_12 && l_ima_208 < l_ima_192 &&
            Close[1] > Open[0] && Close[1] < Open[1] && l_istddev_260 > l_istddev_268) || (l_iwpr_276 <= -25.0 && l_iwpr_276 < l_iwpr_284 - 9.0 && l_iwpr_284 > l_iwpr_292 + 5.0 && Open[2] > Close[2] && Open[1] < Close[2] && Open[1] > Close[1] && li_32 && l_ima_184 < l_ima_192 - 0.0005 && l_iadx_468 > 25.0 && l_iadx_492 > 25.0 && l_ima_208 < l_ima_192) ||
            (li_240 == 2 && l_iadx_492 > 25.0 && l_iwpr_276 < l_iwpr_284 - 12.0 && l_iadx_468 > 25.0 && l_iadx_492 > l_iadx_500 || l_ima_208 < l_ima_192 && l_ima_160 <= l_ima_176 &&
            l_ima_232 > l_ima_216 && li_32) || (Close[1] < l_ima_192 && Open[1] > l_ima_192 && l_ima_208 < l_ima_192 && l_iadx_468 > 30.0 && l_iadx_492 > 25.0 && l_ima_160 < l_ima_168 - 0.0003 && li_32 && l_iwpr_276 < l_iwpr_284 - 18.0 && l_iwpr_284 < l_iwpr_292 - 7.0) ||
            (l_ima_224 < l_ima_232 && l_ima_184 < l_ima_192 && l_ima_160 < l_ima_176 && l_ima_160 < l_ima_168 - 0.0005 && l_ima_192 - l_ima_184 > l_ima_176 - l_ima_160 && l_ima_160 - l_ima_224 > l_ima_176 - l_ima_232 &&
            li_32 && l_iwpr_276 > -85.0 && l_iwpr_276 < l_iwpr_284 - 15.0 && l_ima_224 < l_ima_184 && l_ima_184 < l_ima_160 && Open[0] < l_ima_224)) {
            l_ticket_0 = OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, g_slippage_376, 0, 0, "www.eafan.net", MagicNo, 0, Red);
            if (l_ticket_0 > 0) {
               if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) Print("Sell order opened : ", OrderOpenPrice());
               RefreshRates();
               if (l_price_512 > 0.0) l_price_512 = Bid + g_pips_164 * g_point_368;
               g_price_352 = Bid - g_pips_156 * g_point_368;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_512, g_price_352, 0, CLR_NONE);
            } else Print("Error opening SELL order : ", GetLastError());
            return (0);
         }
         if ((li_24 && l_imacd_96 < l_imacd_104 && l_imacd_96 < l_imacd_112 && l_ima_208 < l_ima_192 && li_12 && l_iwpr_276 < l_iwpr_284 - 7.0 && l_istochastic_340 < l_istochastic_348 &&
            l_istochastic_356 < l_istochastic_364 - 1.0) || (li_24 && l_imacd_96 < l_imacd_104 && l_imacd_96 < l_imacd_112 && Open[0] < Close[1] && l_ima_184 > l_ima_192 && l_iwpr_276 < l_iwpr_284 - 9.0 && li_12 && l_ima_208 < l_ima_192) ||
            (li_24 && l_istochastic_340 > 70.0 && Open[1] < l_ima_136 && Close[1] < l_ima_216 && Open[0] < l_ima_144 && l_ima_184 > l_ima_216 && l_ima_184 > l_ima_192) || (li_24 &&
            Open[1] < l_ima_136 && Open[0] < l_ima_144 && Open[1] > Close[1] && l_iwpr_276 < l_iwpr_284 - 7.0 && l_idemarker_316 < l_idemarker_324 - 0.08 && l_istddev_260 > l_istddev_268)) {
            l_ticket_0 = OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, g_slippage_376, 0, 0, "www.eafan.net", MagicNo, 0, Red);
            if (l_ticket_0 > 0) {
               if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) Print("Sell order opened : ", OrderOpenPrice());
               RefreshRates();
               if (l_price_512 > 0.0) l_price_512 = Bid + g_pips_164 * g_point_368;
               g_price_352 = Bid - g_pips_156 * g_point_368;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_512, g_price_352, 0, CLR_NONE);
            } else Print("Error opening Sell order : ", GetLastError());
            return (0);
         }
         if ((Close[4] > Close[3] && Close[3] < Close[2] && Close[2] < Close[1] && Open[0] > Close[1] && Close[1] - Low[1] < High[1] - Open[1] && l_ima_184 < l_ima_216 - 0.0005 &&
            l_iwpr_276 < l_iwpr_284 - 9.0 && l_iadx_468 > 25.0 && l_iadx_492 > 25.0 && l_iwpr_284 < l_iwpr_292) || (Open[1] > Close[1] && Close[2] > l_ima_160 && Close[1] < l_ima_160 && Open[1] < l_ima_224 && Open[0] < l_ima_144 && l_ima_160 < l_ima_168 - 0.0005 && l_iwpr_276 > -95.0 && l_iwpr_276 < l_iwpr_284 - 7.0 && l_idemarker_316 < l_idemarker_324 && l_idemarker_324 < l_idemarker_332) ||
            (l_iadx_492 > l_iadx_500 && l_iadx_484 > l_iadx_500 && l_iadx_476 <= l_iadx_492 && l_iadx_468 >= 35.0 && l_iadx_492 > 25.0 && l_iwpr_276 < l_iwpr_284 - 15.0 && li_32) ||
            (l_irsi_412 > l_irsi_420 && l_irsi_404 < l_irsi_412 - 5.0 && l_irsi_412 > 70.0 && l_ima_208 < l_ima_192 && l_iadx_468 > 25.0 && l_iadx_492 > 25.0)) {
            l_ticket_0 = OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, g_slippage_376, 0, 0, "www.eafan.net", MagicNo, 0, Red);
            if (l_ticket_0 > 0) {
               if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) Print("Sell order opened : ", OrderOpenPrice());
               RefreshRates();
               if (l_price_512 > 0.0) l_price_512 = Bid + g_pips_164 * g_point_368;
               g_price_352 = Bid - g_pips_156 * g_point_368;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_512, g_price_352, 0, CLR_NONE);
            } else Print("Error opening Sell order : ", GetLastError());
            return (0);
         }
         if ((li_40 && Open[1] < l_ima_136 && Open[0] < l_ima_144 && Open[1] > Close[1] && l_ima_160 < l_ima_176 - 0.0002 && l_iadx_468 > 25.0 && l_iadx_492 > 25.0 && l_iwpr_276 < l_iwpr_284 - 9.0 &&
            l_ima_208 < l_ima_192) || (li_40 && l_imacd_96 < l_imacd_104 && l_imacd_96 > 0.0 && l_imacd_96 < l_imacd_112 && l_iadx_468 > 25.0 && l_iadx_492 > 25.0 && l_iwpr_276 < l_iwpr_284 - 7.0 && l_istochastic_372 < l_istochastic_380 && l_istochastic_388 < l_istochastic_396 - 1.0) ||
            ((li_48 && l_istochastic_380 > 75.0) || (li_40 && l_istochastic_380 > 705.0) && l_ima_160 < l_ima_176 - 0.0002 && l_ima_208 < l_ima_192)) {
            l_ticket_0 = OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, g_slippage_376, 0, 0, "www.eafan.net", MagicNo, 0, Red);
            if (l_ticket_0 > 0) {
               if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) Print("Sell order opened : ", OrderOpenPrice());
               RefreshRates();
               if (l_price_512 > 0.0) l_price_512 = Bid + g_pips_164 * g_point_368;
               g_price_352 = Bid - g_pips_156 * g_point_368;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_512, g_price_352, 0, CLR_NONE);
            } else Print("Error opening SELL order : ", GetLastError());
            return (0);
         }
         if ((Close[2] > l_ibands_460 && Open[1] < l_ibands_452 && Open[0] < Close[1] && Open[1] > Close[1] && li_56 && l_iwpr_276 < l_iwpr_284 - 12.0 && l_istochastic_372 < l_istochastic_380 - 3.0 &&
            l_istochastic_388 < l_istochastic_396 && l_ima_208 < l_ima_192 && l_ima_184 < l_ima_192) || (Close[3] < l_ima_216 && Open[2] < l_ima_192 && Open[1] > Close[1] && Open[1] < Close[2] && Close[1] < l_ima_160 - 2.2 * l_istddev_268 && Open[0] < Close[1] && l_istddev_260 > l_istddev_268 && li_32 && l_iwpr_276 < l_iwpr_284 - 7.0 && l_iwpr_276 > -85.0) ||
            (l_ima_192 > l_ima_200 + 0.0001 && l_ima_184 < l_ima_192 - 0.0002 && l_ima_184 < l_ima_200 - 0.0001 && l_ima_192 > l_ima_176 && li_32 || li_56 && Open[0] < Close[1]) ||
            (l_ima_176 - l_ima_244 > l_ima_160 - l_ima_244 && l_ima_244 > (l_high_80 + l_low_88) / 2.0 + 2.0 * l_istddev_252 && l_ima_244 - l_ima_160 > l_istddev_252 && Open[0] < Close[1] &&
            li_32) || (iSAR(NULL, 0, 0.02, 0.2, 1) < Close[1] && iSAR(NULL, 0, 0.02, 0.2, 0) > Open[0] && iSAR(NULL, PERIOD_M15, 0.02, 0.2, 1) < iClose(NULL, PERIOD_M15, 1) && iSAR(NULL, PERIOD_M15, 0.02, 0.2, 0) > iOpen(NULL, PERIOD_M15, 0) && iSAR(NULL, PERIOD_M30, 0.02, 0.2, 1) < iClose(NULL, PERIOD_M30, 1) && iSAR(NULL, PERIOD_M30, 0.02, 0.2, 0) > iOpen(NULL, PERIOD_M30, 0) && (Open[0] > Close[0] && Open[0] < Close[1] && Bid < l_ima_160) ||
            (l_ima_224 < l_ima_232 && l_imacd_96 < l_imacd_104 && l_imacd_96 > 0.0))) {
            l_ticket_0 = OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, g_slippage_376, 0, 0, "www.eafan.net", MagicNo, 0, Red);
            if (l_ticket_0 > 0) {
               if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) Print("Sell order opened : ", OrderOpenPrice());
               RefreshRates();
               if (l_price_512 > 0.0) l_price_512 = Bid + g_pips_164 * g_point_368;
               g_price_352 = Bid - g_pips_156 * g_point_368;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_512, g_price_352, 0, CLR_NONE);
            } else Print("Error opening SELL order : ", GetLastError());
            return (0);
         }
         if (Predict() == 2.0 || Predict2() == 2.0 && Bid > (l_high_80 + l_low_88) / 2.0 && li_32 && l_istochastic_340 > 55.0) {
            l_ticket_0 = OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, g_slippage_376, 0, 0, "www.eafan.net", MagicNo, 0, Red);
            if (l_ticket_0 > 0) {
               if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) Print("Sell order opened : ", OrderOpenPrice());
               RefreshRates();
               if (l_price_512 > 0.0) l_price_512 = Bid + g_pips_164 * g_point_368;
               g_price_352 = Bid - 10.0 * g_point_368;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_512, g_price_352, 0, CLR_NONE);
            } else Print("Error opening SELL order : ", GetLastError());
            return (0);
         }
      }
   }
   if (gi_196 && AccountEquity() > AccountBalance() * (gd_204 / 100.0 + 1.0)) Close_All();
   for (int l_pos_536 = 0; l_pos_536 < l_count_72; l_pos_536++) {
      OrderSelect(l_pos_536, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNo) {
         l_price_60 = OrderStopLoss();
         if (OrderType() == OP_BUY) {
            if (AccountFreeMargin() <= 0.0 || (gi_212 && AccountEquity() + AccountMargin() < AccountBalance() * (1 - RiskPercent / 50.0))) {
               OrderClose(OrderTicket(), OrderLots(), Bid, g_slippage_172, Violet);
               return (0);
            }
            if (g_pips_180 <= 0.0) continue;
            if (Bid - OrderOpenPrice() <= g_point_368 * g_pips_180) continue;
            if (l_price_60 >= Bid - g_point_368 * g_pips_180) continue;
            l_price_60 = Bid - g_point_368 * g_pips_180;
            l_price_4 = OrderTakeProfit();
            if (l_iwpr_276 > l_iwpr_284 + 7.0 && li_28) l_price_4 = OrderTakeProfit() + gi_192 * g_point_368;
            OrderModify(OrderTicket(), OrderOpenPrice(), l_price_60, l_price_4, 0, Blue);
            return (0);
         }
         if (AccountFreeMargin() <= 0.0 || (gi_212 && AccountEquity() + AccountMargin() < AccountBalance() * (1 - RiskPercent / 50.0))) {
            OrderClose(OrderTicket(), OrderLots(), Ask, g_slippage_172, Violet);
            return (0);
         }
         if (g_pips_180 > 0.0) {
            if (OrderOpenPrice() - Ask > g_point_368 * g_pips_180) {
               if (l_price_60 > Ask + g_point_368 * g_pips_180 || l_price_60 == 0.0) {
                  l_price_60 = Ask + g_point_368 * g_pips_180;
                  l_price_4 = OrderTakeProfit();
                  if (l_iwpr_276 < l_iwpr_284 - 7.0 && li_32) l_price_4 = OrderTakeProfit() - gi_192 * g_point_368;
                  OrderModify(OrderTicket(), OrderOpenPrice(), l_price_60, l_price_4, 0, Red);
                  return (0);
               }
            }
         }
      }
   }
   return (0);
}

double LotsOptimized() {
   if (!gi_116) return (gd_128);
   if (gd_136 > 0.0) g_maxlot_316 = gd_136;
   double ld_ret_0 = AccountFreeMargin() * RiskPercent / 400.0;
   ld_ret_0 = NormalizeDouble(MathFloor(ld_ret_0 / gd_340) * g_lotstep_332, 2);
   if (ld_ret_0 < g_minlot_324) ld_ret_0 = g_minlot_324;
   if (ld_ret_0 > g_maxlot_316) ld_ret_0 = g_maxlot_316;
   return (ld_ret_0);
}

void Close_All() {
   int l_cmd_0;
   bool l_ord_close_4;
   for (int li_8 = OrdersTotal() - 1; li_8 >= 0; li_8--) {
      l_cmd_0 = OrderType();
      l_ord_close_4 = false;
      if (OrderMagicNumber() == MagicNo || (OrderMagicNumber() != MagicNo && gi_200)) {
         switch (l_cmd_0) {
         case OP_BUY:
            l_ord_close_4 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), g_slippage_376, Pink);
            break;
         case OP_SELL:
            l_ord_close_4 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), g_slippage_376, Pink);
         }
         if (l_ord_close_4 == 0) Sleep(1000);
      }
   }
   Print("Since Profit Protection is on, all trades have been closed.");
}

bool isTradeTime() {
   int l_str2time_0;
   int l_str2time_4;
   int l_datetime_8 = TimeCurrent();
   if (gi_220) {
      l_str2time_0 = StrToTime(gi_224 + ":" + gi_228);
      l_str2time_4 = StrToTime(gi_232 + ":" + gi_236);
      if (l_str2time_0 < l_str2time_4 && l_datetime_8 < l_str2time_0 || l_datetime_8 >= l_str2time_4) return (false);
      if (l_str2time_0 > l_str2time_4 && (l_datetime_8 < l_str2time_0 && l_datetime_8 >= l_str2time_4)) return (false);
   }
   return (true);
}