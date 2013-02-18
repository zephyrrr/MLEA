using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using System.Linq;
using Feng.Data;

namespace MLEA
{
    public static class DbUtils
    {
        public static void GenerateRandomData(string symbol, string period)
        {
            var dt = DbHelper.Instance.ExecuteDataTable(string.Format("SELECT TIME FROM {0}_{1}", symbol, period));
            var dtHighLow = DbHelper.Instance.ExecuteDataTable(string.Format("SELECT MAX(HIGH), MIN(LOW) FROM {0}_{1}", symbol, period));
            double high = (double)dtHighLow.Rows[0][0];
            double low = (double)dtHighLow.Rows[0][1];
            high = 1;
            low = 0;

            System.Random randomGenerator = new Random();
            var dtDest = DbHelper.Instance.ExecuteDataTable(string.Format("SELECT * FROM {0}_{1} WHERE TIME = -1", symbol, period));
            double open = 0;
            double step;
            if (period == "M1")
                step = 0.0050;
            else if (period == "D1")
                step = 0.0300;
            else if (period == "H4")
                step = 0.0150;
            else
                throw new ArgumentException("incorrect period.");
            foreach (System.Data.DataRow row in dt.Rows)
            {
                var rowDest = dtDest.NewRow();
                long time = (long)row["Time"];
                rowDest["Time"] = time;
                System.DateTime date = WekaUtils.GetDateFromTime(time);
                rowDest["Date"] = date;
                rowDest["hour"] = date.Hour;
                rowDest["dayofweek"] = date.DayOfWeek;
                rowDest["spread"] = 50;

                double[] d = new double[3];
                for (int i = 0; i < d.Length; ++i)
                    d[i] = (randomGenerator.NextDouble() * 2 - 1) * step;
                Array.Sort(d);
                rowDest["low"] = open + d[0];
                rowDest["open"] = open;
                rowDest["close"] = open + d[1];
                rowDest["high"] = open + d[2];

                open = open + d[1];
                dtDest.Rows.Add(rowDest);
            }

            DbHelper.Instance.BulkCopy(dtDest, string.Format("{0}R_{1}", symbol, period));
        }

        public static void GenerateRandomData(string symbol)
        {
            GenerateRandomData(symbol, "M1");
            GenerateRandomData(symbol, "D1");
            GenerateIndicators(symbol + "R", "D1");
        }

        private static bool CheckTimeIdx(long time, MqlRates[] rates, ref int idx)
        {
            if (idx >= 0)
                return true;
            idx = ~idx;
            if (idx >= 0 && idx < rates.Length && (rates[idx].time - time) / 60 <= 60 * 24)
                return true;
            return false;
        }

        public static void CalculateUSDX()
        {
            DbHelper.Instance.ExecuteNonQuery("TRUNCATE TABLE USDX_M1");
            System.Data.DataTable dtUsdx = DbHelper.Instance.ExecuteDataTable("SELECT * FROM USDX_M1");

            var eurs = DbData.Instance.ReadRates("EURUSD_M1");
            var jpys = DbData.Instance.ReadRates("USDJPY_M1");
            var gbps = DbData.Instance.ReadRates("GBPUSD_M1");
            var cads = DbData.Instance.ReadRates("USDCAD_M1");
            var seks = DbData.Instance.ReadRates("USDSEK_M1");
            var chfs = DbData.Instance.ReadRates("USDCHF_M1");

            for (int i=0; i<eurs.Length; ++i)
            {
                //eurs[i].open
                var row = dtUsdx.NewRow();

                int i2 = Array.BinarySearch<MqlRates>(jpys, eurs[i]);
                int i3 = Array.BinarySearch<MqlRates>(gbps, eurs[i]);
                int i4 = Array.BinarySearch<MqlRates>(cads, eurs[i]);
                int i5 = Array.BinarySearch<MqlRates>(seks, eurs[i]);
                int i6 = Array.BinarySearch<MqlRates>(chfs, eurs[i]);
                if (!CheckTimeIdx(eurs[i].time, jpys, ref i2) ||
                    !CheckTimeIdx(eurs[i].time, gbps, ref i3) ||
                    !CheckTimeIdx(eurs[i].time, cads, ref i4) ||
                    !CheckTimeIdx(eurs[i].time, seks, ref i5) ||
                    !CheckTimeIdx(eurs[i].time, chfs, ref i6))
                    continue;

                long time = eurs[i].time; 
                row["Time"] = time;
                System.DateTime date = WekaUtils.GetDateFromTime(time);
                row["Date"] = date;
                row["hour"] = date.Hour;
                row["dayofweek"] = (int)date.DayOfWeek;
                row["spread"] = -1;

                row["open"] = GetUSDX(eurs[i].open, jpys[i2].open, gbps[i3].open, cads[i4].open, seks[i5].open, chfs[i6].open);
                row["close"] = GetUSDX(eurs[i].close, jpys[i2].close, gbps[i3].close, cads[i4].close, seks[i5].close, chfs[i6].close);
                row["high"] = GetUSDX(eurs[i].high, jpys[i2].high, gbps[i3].high, cads[i4].high, seks[i5].high, chfs[i6].high);
                row["low"] = GetUSDX(eurs[i].low, jpys[i2].low, gbps[i3].low, cads[i4].low, seks[i5].low, chfs[i6].low);

                dtUsdx.Rows.Add(row);
            }

            DbHelper.Instance.BulkCopy(dtUsdx, "USDX_M1");
        }

        private static double GetUSDX(double eur, double jpy, double gbp, double cad, double sek, double chf)
        {
            var usdx = 50.14348112 * Math.Pow(eur, -0.576) * Math.Pow(jpy, 0.136) * Math.Pow(gbp, -0.119) * 
                Math.Pow(cad, 0.091) * Math.Pow(sek, 0.042) * Math.Pow(chf, 0.036);
            return usdx;
        }
        private static double GetEURX(double eurusd, double eurjpy, double eurgbp, double eurcad, double eursek, double eurchf)
        {
            var usdx = 34.38805726 * Math.Pow(eurusd, 0.3155) * Math.Pow(eurgbp, 0.3056) * Math.Pow(eurjpy, 0.1891) *
                Math.Pow(eurchf, 0.1113) * Math.Pow(eursek, 0.0785);
            return usdx;
        }


        public static void ConvertHpdataFromSaturday2Monday(string symbol = "EURUSD")
        {
            long startTime = 946859400;
            while (true)
            {
                var dt2 = Feng.Data.DbHelper.Instance.ExecuteDataTable(string.Format("SELECT TOP 200 * FROM {0}_HP WHERE TIME >= {1} ORDER BY TIME", symbol, startTime));
                if (dt2.Rows.Count == 0)
                    break;

                for (int i = 0; i < dt2.Rows.Count; ++i)
                {
                    var row = dt2.Rows[i];
                    long time2 = (long)row["Time"];
                    bool isComplete = (bool)row["IsComplete"];

                    sbyte?[, ,] hps2 = HpData.DeserializeHp((byte[])row["hp"]);
                    long?[, ,] hpTimes2 = HpData.DeserializeHpTimes((byte[])row["hp_date"]);

                    bool dataChanged = false;
                    for (int k = 0; k < hps2.GetLength(0); ++k)
                        for (int tp = 0; tp < hps2.GetLength(1); ++tp)
                            for (int sl = 0; sl < hps2.GetLength(2); ++sl)
                            {
                                if (hps2[k, tp, sl].HasValue && hps2[k, tp, sl].Value != -1)
                                {
                                    long hpTime = hpTimes2[k, tp, sl].Value;
                                    DateTime date = WekaUtils.GetDateFromTime(hpTime);
                                    if (date.DayOfWeek == DayOfWeek.Saturday)
                                    {
                                        WekaUtils.DebugAssert(date.Hour == 0 && date.Minute == 0 && date.Second == 0, "date.Hour == 0 && date.Minute == 0 && date.Second == 0");

                                        var newDate = date.AddDays(2);
                                        var newTime = WekaUtils.GetTimeFromDate(newDate);

                                        hpTimes2[k, tp, sl] = newTime;
                                        dataChanged = true;
                                    }
                                }
                            }
                    if (dataChanged)
                    {
                        var sql = new SqlCommand(string.Format("UPDATE {0}_HP SET hp_date = @HpTimes WHERE TIME = @Time", symbol));
                        sql.Parameters.AddWithValue("@Time", time2);
                        sql.Parameters.AddWithValue("@HpTimes", HpData.SerializeHpTimes(hpTimes2));
                        DbHelper.Instance.ExecuteNonQuery(sql);
                    }
                }
                System.Console.WriteLine(string.Format("{0} is ok", WekaUtils.GetDateFromTime(startTime)));
                startTime = (long)dt2.Rows[dt2.Rows.Count-1]["Time"] + 60;
            }
        }

        public static void ConvertDbFromSaturday2Monday(string symbolPeriod = "EURUSD_M1")
        {
            var dt = DbHelper.Instance.ExecuteDataTable(string.Format("SELECT * FROM {0} WHERE DAYOFWEEK = 6", symbolPeriod));
            foreach (System.Data.DataRow row in dt.Rows)
            {
                long time = (long)row["Time"];
                DateTime date = WekaUtils.GetDateFromTime(time);
                WekaUtils.DebugAssert(date.Hour == 0 && date.Minute == 0 && date.Second == 0, "date.Hour == 0 && date.Minute == 0 && date.Second == 0");

                var newDate = date.AddDays(2);
                var newTime = WekaUtils.GetTimeFromDate(newDate);

                var sql = string.Format("UPDATE {0} SET TIME = {1}, DATE = '{2}', DAYOFWEEK = 1 WHERE TIME = {3}",
                    symbolPeriod, newTime, newDate.ToString(), time);

                DbHelper.Instance.ExecuteNonQuery(sql);

            }
        }
        #region "DbUpdate"
        public static void UpdateTickDb()
        {
            //long lastTime = -1;
            using (SqlConnection conn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["DataConnectionString"].ConnectionString))
            {
                conn.Open();
                SqlCommand cmdReader = new SqlCommand("SELECT ID, DATE FROM EURUSD_TICK", conn);
                var reader = cmdReader.ExecuteReader();
                Func<bool> f2 = () => !reader.Read();
                Func<SqlCommand[]> f1 = () =>
                {
                    object[] row = new object[reader.FieldCount];
                    reader.GetValues(row);

                    SqlCommand cmd = new SqlCommand("UPDATE EURUSD_TICK SET TIME = @TIME WHERE ID = @ID");

                    DateTime date = (DateTime)row[1];
                    long time = (long)(date - Parameters.MtStartTime).TotalSeconds;
                    //if (time <= lastTime)
                    //    time = lastTime + 1;

                    cmd.Parameters.AddWithValue("@TIME", time);
                    cmd.Parameters.AddWithValue("@ID", row[0]);
                    //lastTime = time;

                    return new SqlCommand[] { cmd };
                };
                BatchDb(f1, f2);
            }
        }

        public static void ImportTickToDb()
        {
            string[] fileNames = new string[] { /*"e:\\EURUSD_Ticks__2007.01.01_2008.01.01.csv", */"e:\\EURUSD_Ticks__2008.01.01_2009.01.01.csv", "e:\\EURUSD_Ticks__2009.01.01_2010.01.01.csv", "e:\\EURUSD_Ticks__2010.01.01_2011.01.01.csv", "e:\\EURUSD_Ticks__2011.01.01_2011.10.01.csv" };
            foreach (string f in fileNames)
            {
                DateTime? maxDate = null;
                try
                {
                    maxDate = DateTime.Parse(DbHelper.Instance.ExecuteScalar("SELECT MAX(Date) FROM EURUSD_Tick").ToString());
                }
                catch (Exception)
                {
                }
                using (StreamReader sr = new StreamReader(f))
                {
                    sr.ReadLine();
                    Func<bool> f2 = () => sr.EndOfStream;
                    Func<SqlCommand[]> f1 = () =>
                    {
                        string s = sr.ReadLine();
                        if (string.IsNullOrEmpty(s))
                            return null;

                        string[] ss = s.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                        if (ss.Length != 5)
                        {
                            WekaUtils.Instance.WriteLog("Length should be 5");
                            return null;
                        }
                        DateTime dt = DateTime.ParseExact(ss[0], "yyyy.MM.dd HH:mm:ss", null);
                        if (maxDate.HasValue && dt < maxDate)
                            return null;

                        string sql = string.Format("INSERT INTO [EURUSD_Tick] ([Date],[Time],[Ask],[Bid],[AskVolume],[BidVolume]");
                        sql += ") VALUES (@Date, @Time, @Ask,@Bid,@AskVolume, @BidVolume";
                        sql += ")";
                        SqlCommand cmd = new SqlCommand(sql);

                        cmd.Parameters.AddWithValue("@Date", dt);
                        cmd.Parameters.AddWithValue("Time", (long)(dt - Parameters.MtStartTime).TotalSeconds);
                        cmd.Parameters.AddWithValue("@Ask", Convert.ToDouble(ss[1]));
                        cmd.Parameters.AddWithValue("@Bid", Convert.ToDouble(ss[2]));
                        cmd.Parameters.AddWithValue("@AskVolume", Convert.ToDouble(ss[3]));
                        cmd.Parameters.AddWithValue("@BidVolume", Convert.ToDouble(ss[4]));

                        return new SqlCommand[] { cmd };

                    };
                    BatchDb(f1, f2);
                }
            }
        }

        public static void ExportStockData()
        {
            using (StreamWriter sw = new StreamWriter("F:\\Stock.dat"))
            {
                int n = 0;
                using (SqlConnection conn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["DataConnectionString"].ConnectionString))
                {
                    conn.Open();
                    SqlCommand cmdReader = new SqlCommand("SELECT * FROM STOCK_Tick", conn);
                    var reader = cmdReader.ExecuteReader();
                    while (reader.Read())
                    {
                        sw.WriteLine(string.Format("{0},{1},{2},{3},{4}", reader["Date"], reader["Stock"], reader["Price"], reader["Type"], reader["Volume"]));

                        n++;
                        if (n % 1000 == 0)
                        {
                            sw.Flush();
                            System.Console.WriteLine(n);
                        }
                    }

                    reader.Close();
                }
            }
        }
        public static void ImportStockData()
        {
            foreach (string fileName in System.IO.Directory.GetFiles("e:\\level2", "*.csv", SearchOption.AllDirectories))
            {
                WekaUtils.Instance.WriteLog(fileName);

                using (StreamReader sr = new StreamReader(fileName))
                {
                    sr.ReadLine();
                    Func<bool> f2 = () => sr.EndOfStream;
                    Func<SqlCommand[]> f1 = () =>
                    {
                        string s = sr.ReadLine();
                        if (string.IsNullOrEmpty(s))
                            return null;

                        string[] ss = s.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                        if (ss.Length != 4)
                        {
                            WekaUtils.Instance.WriteLog("Length should be 4");
                            return null;
                        }

                        DateTime? date = null;
                        try
                        {
                            string day = System.IO.Path.GetDirectoryName(fileName).Replace("e:\\level2\\", "");
                            string time = ss[0];
                            date = new DateTime(Convert.ToInt32(day.Substring(0, 4)), Convert.ToInt32(day.Substring(4, 2)), Convert.ToInt32(day.Substring(6, 2)),
                                Convert.ToInt32(time.Substring(0, 2)), Convert.ToInt32(time.Substring(2, 2)), Convert.ToInt32(time.Substring(4, 2)));
                        }
                        catch (Exception)
                        {
                            throw;
                        }

                        string sql = string.Format("INSERT INTO [STOCK_Tick] ([Stock],[Date],[Price],[Type],[Volume]");
                        sql += ") VALUES (@Stock, @Date, @Price, @Type, @Volume";
                        sql += ")";
                        SqlCommand cmd = new SqlCommand(sql);

                        cmd.Parameters.AddWithValue("@Stock", System.IO.Path.GetFileNameWithoutExtension(fileName));
                        cmd.Parameters.AddWithValue("@Date", date);
                        cmd.Parameters.AddWithValue("@Price", Convert.ToDouble(ss[1]));
                        cmd.Parameters.AddWithValue("@Type", ss[2]);
                        cmd.Parameters.AddWithValue("@Volume", Convert.ToInt32(ss[3]));

                        return new SqlCommand[] { cmd };

                    };
                    BatchDb(f1, f2);
                }
                System.IO.File.Move(fileName, fileName + ".im");
            }
        }
        #endregion

        #region "DbImport"
        public static void ImportToDbAll(string symbol = null, string period = null)
        {
            foreach (string s in Parameters.AllSymbolsFull)
            {
                if (!string.IsNullOrEmpty(symbol) && s != symbol)
                    continue;

                foreach (string p in Parameters.AllPeriodsFull)
                {
                    if (!string.IsNullOrEmpty(period) && p != period)
                        continue;
                    ImportToDb(s, p);
                }
            }
        }

        //public static void CheckDbCountToHpCountSame(string period)
        //{
        //    Dictionary<long, long>[] dicts = new Dictionary<long, long>[Parameters.AllSymbols.Length];
        //    for (int i = 0; i < dicts.Length; ++i)
        //    {
        //        dicts[i] = new Dictionary<long, long>();
        //        var dt = DbHelper.Instance.ExecuteDataTable(string.Format("SELECT TIME FROM {0}_{1}", Parameters.AllSymbols[i], period));
        //        foreach (System.Data.DataRow row in dt.Rows)
        //        {
        //            long time = (long)row[0];
        //            dicts[i][time] = time;
        //        }
        //    }
        //}
        public static void CheckDbCountToSame(string period)
        {
            Dictionary<long, long>[] dicts = new Dictionary<long, long>[Parameters.AllSymbolsFull.Length];
            for (int i = 0; i < dicts.Length; ++i)
            {
                dicts[i] = new Dictionary<long, long>();
                var dt = DbHelper.Instance.ExecuteDataTable(string.Format("SELECT TIME FROM {0}_{1}", Parameters.AllSymbolsFull[i], period));
                foreach (System.Data.DataRow row in dt.Rows)
                {
                    long time = (long)row[0];
                    dicts[i][time] = time;
                }
            }

            Dictionary<long, long> sameTime = new Dictionary<long,long>();

            foreach (var kvp in dicts[0])
            {
                bool haveData = true;
                for (int i = 1; i < dicts.Length; ++i)
                {
                    if (!dicts[i].ContainsKey(kvp.Key))
                    {
                        haveData = false;
                        break;
                    }
                }
                if (haveData)
                    sameTime.Add(kvp.Key, kvp.Key);
            }

            for (int i = 0; i < dicts.Length; ++i)
            {
                foreach (var kvp in dicts[i])
                {
                    if (!sameTime.ContainsKey(kvp.Key))
                    {
                        Console.WriteLine(string.Format("Delete {0} at {1}", Parameters.AllSymbolsFull[i], kvp.Key));
                        DbHelper.Instance.ExecuteNonQuery(string.Format("DELETE FROM {0}_{1} WHERE TIME = {2}",
                            Parameters.AllSymbolsFull[i], period, kvp.Key));
                    }
                }
            }
        }
        public static void GeneratePeriodData(string symbol, string period, int aheadHour)
        {
            //var rateM1 = MT5Data.ReadRates(symbol + "_M1");
            var rateM1 = DbData.Instance.ReadRates(symbol + "_M1");
            List<MqlRates> ratesNew = new List<MqlRates>();
          
            for(int i=0; i<rateM1.Length; ++i)
            {
                rateM1[i].time += aheadHour * 3600;
            }
            int newPeriodSecond = 60 * WekaUtils.GetMinuteofPeriod(period);
            MqlRates newRate = new MqlRates();
            newRate.low = double.MaxValue;
            newRate.open = rateM1[0].open;
            newRate.time = rateM1[0].time / newPeriodSecond * newPeriodSecond;

            int cnt = 0;
            for(int i=1; i<rateM1.Length; ++i)
            {
                if (rateM1[i].time - newRate.time >= newPeriodSecond)
                {
                    if (newRate.low != double.MaxValue && newRate.high != 0)
                    {
                        if (cnt > newPeriodSecond / 60 / 8)
                        {
                            ratesNew.Add(newRate);
                        }
                    }
                    else
                    {
                    }
                    newRate = new MqlRates();
                    newRate.low = double.MaxValue;
                    newRate.open = rateM1[i].open;
                    newRate.time = rateM1[i].time / newPeriodSecond * newPeriodSecond;
                    cnt = 0;
                }
                else
                {
                    newRate.high = Math.Max(newRate.high, rateM1[i].high);
                    newRate.low = Math.Min(newRate.low, rateM1[i].low);
                    newRate.real_volume += rateM1[i].real_volume;
                    newRate.spread = Math.Max(newRate.spread, rateM1[i].spread);
                    newRate.tick_volume += rateM1[i].tick_volume;
                    newRate.close = rateM1[i].close;

                    cnt++;
                }
            }

            var rate = ratesNew.ToArray();
            for (int n = 0; n < rate.Length; ++n)
            {
                long newtime = rate[n].time + 60 * WekaUtils.GetMinuteofPeriod(period);
                rate[n].time = newtime;
            }

            ImportToDb(symbol, period, 0, rate, null);
        }

        public static void GenerateIndicators(string symbol, string period)
        {
            var taLibTest = new TaLibTest();
            var ind = taLibTest.GnerateIndicators(symbol, period);

            var rate = DbData.Instance.ReadRates(string.Format("{0}_{1}", symbol, period));

            DbHelper.Instance.ExecuteNonQuery(string.Format("TRUNCATE TABLE {0}_{1}", symbol, period));

            ImportToDb(symbol, period, 0, rate, ind);
        }

        public static void ImportToDb(string symbol, string period, int periodTime_cnt = 0)
        {
            System.Console.WriteLine(string.Format("Now import date of {0}-{1} to db", symbol, period));

            string symbolPeriod = symbol + "_" + period;
            string symbolPeriodTime = symbol + "_" + period +
                (periodTime_cnt == 1 ? (period == "M5" ? "_3" : "_4") : string.Empty) +
                (periodTime_cnt == 2 ? (period == "M5" ? "_12" : "_16") : string.Empty) +
                (periodTime_cnt == 3 ? (period == "M5" ? "_48" : "_64") : string.Empty);

            //var rate = DukasData.ReadRates(symbolPeriod);
            var rate = MT5Data.ReadRates(symbolPeriod);
            for (int n = 0; n < rate.Length; ++n)
            {
                long newtime = rate[n].time + 60 * WekaUtils.GetMinuteofPeriod(period);
                rate[n].time = newtime;
            }

            Dictionary<string, Dictionary<long, double>> inds = new Dictionary<string, Dictionary<long, double>>();

            foreach (string indName in TestParameters.CandidateParameter4Db.AllIndNames.Keys)
            {
                if (period != "M1")
                {
                    var ind = MT5Data.ReadIndicators(symbolPeriodTime, indName);
                    Dictionary<long, double> ind2 = new Dictionary<long, double>();
                    foreach (var kvp in ind)
                    {
                        long newtime = kvp.Key + 60 * WekaUtils.GetMinuteofPeriod(period);
                        ind2[newtime] = kvp.Value;
                    }
                    inds[indName] = ind2;
                }
            }

            ImportToDb(symbol, period, periodTime_cnt, rate, inds);
        }

        // 注意修改rate.time（例如M15，需要加60*15）
        public static void ImportToDb(string symbol, string period, int periodTime_cnt, MqlRates[] rate, Dictionary<string, Dictionary<long, double>> inds)
        {
            string symbolPeriod = symbol + "_" + period;

            string symbolPeriodTime = symbol + "_" + period +
                (periodTime_cnt == 1 ? (period == "M5" ? "_3" : "_4") : string.Empty) +
                (periodTime_cnt == 2 ? (period == "M5" ? "_12" : "_16") : string.Empty) +
                (periodTime_cnt == 3 ? (period == "M5" ? "_48" : "_64") : string.Empty);

            //DateTime maxDate = (DateTime)DbHelper.Instance.ExecuteScalar(string.Format("SELECT ISNULL(MAX(Date), '2001.01.01') FROM {0}", m_symbolPeriod));
            //DateTime minDate = (DateTime)DbHelper.Instance.ExecuteScalar(string.Format("SELECT ISNULL(MIN(Date), '2012.01.01') FROM {0}", m_symbolPeriod));

            bool deleteFirst = false;
            if (deleteFirst)
            {
                DbHelper.Instance.ExecuteNonQuery(string.Format("TRUNCATE TABLE {0}", symbolPeriodTime));
            }

            System.Data.DataTable dt;
            try
            {
                dt = DbHelper.Instance.ExecuteDataTable(string.Format("SELECT Time FROM {0} WHERE Spread > 0 ORDER BY Time", symbolPeriodTime));
            }
            catch (Exception)
            {
                string sql = @"CREATE TABLE [dbo].[{0}](
	[Time] [bigint] NOT NULL,
	[Date] [datetime] NOT NULL,
	[hour] [int] NOT NULL,
	[dayofweek] [int] NOT NULL,
	[open] [float] NOT NULL,
	[close] [float] NOT NULL,
	[high] [float] NOT NULL,
	[low] [float] NOT NULL,
	[spread] [int] NULL,
	[AskVolume] [float] NULL,
	[BidVolume] [float] NULL,
	[AMA_9_2_30] [float] NULL,
	[ADX_14] [float] NULL,
	[ADX_14_P] [float] NULL,
	[ADX_14_M] [float] NULL,
	[ADXWilder_14] [float] NULL,
	[ADXWilder_14_P] [float] NULL,
	[ADXWilder_14_M] [float] NULL,
	[Bands_20_2] [float] NULL,
	[DEMA_14] [float] NULL,
	[FrAMA_14] [float] NULL,
	[MA_10] [float] NULL,
	[TEMA_14] [float] NULL,
	[VIDyA_9_12] [float] NULL,
	[ATR_14] [float] NULL,
	[BearsPower_13] [float] NULL,
	[BullsPower_13] [float] NULL,
	[CCI_14] [float] NULL,
	[DeMarker_14] [float] NULL,
	[MACD_12_26_9_M] [float] NULL,
	[MACD_12_26_9_S] [float] NULL,
	[RSI_14] [float] NULL,
	[RVI_10_M] [float] NULL,
	[RVI_10_S] [float] NULL,
	[Stochastic_5_3_3_M] [float] NULL,
	[Stochastic_5_3_3_S] [float] NULL,
	[TriX_14] [float] NULL,
	[WPR_14] [float] NULL,
 CONSTRAINT [PK_{0}] PRIMARY KEY CLUSTERED 
(
	[Time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]";

                string sql_m1 = @"CREATE TABLE [dbo].[{0}](
	[Time] [bigint] NOT NULL,
	[Date] [datetime] NOT NULL,
	[hour] [int] NOT NULL,
	[dayofweek] [int] NOT NULL,
	[open] [float] NOT NULL,
	[close] [float] NOT NULL,
	[high] [float] NOT NULL,
	[low] [float] NOT NULL,
	[spread] [int] NOT NULL,
 CONSTRAINT [PK_{0}] PRIMARY KEY CLUSTERED 
(
	[Time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]";

                if (period == "M1")
                {
                    DbHelper.Instance.ExecuteNonQuery(string.Format(sql_m1, symbolPeriod));
                }
                else
                {
                    DbHelper.Instance.ExecuteNonQuery(string.Format(sql, symbolPeriod));
                }

                dt = DbHelper.Instance.ExecuteDataTable(string.Format("SELECT Time FROM {0} WHERE Spread > 0 ORDER BY Time", symbolPeriodTime));
            }

            Dictionary<long, long> existRows = new Dictionary<long, long>();
            foreach (System.Data.DataRow row in dt.Rows)
            {
                long time = (long)row["Time"];
                existRows[time] = time;
            }

            dt = DbHelper.Instance.ExecuteDataTable(string.Format("SELECT * FROM {0} WHERE Time = -1", symbolPeriodTime));

            Dictionary<long, int> rateExist = new Dictionary<long, int>();
            for (int n = 0; n < rate.Length; ++n)
            {
                long newtime = rate[n].time;// 放在前面了 +60 * WekaUtils.GetMinuteofPeriod(period);
                DateTime newDate = WekaUtils.GetDateFromTime(newtime);
                if (rateExist.ContainsKey(newtime))
                {
                    continue;
                }
                rateExist[newtime] = 1;

                if (newDate.DayOfWeek == DayOfWeek.Saturday)
                {
                    //WekaUtils.DebugAssert(newDate.Hour == 0 && newDate.Minute == 0 && newDate.Second == 0, "newDate.Hour == 0 && newDate.Minute == 0 && newDate.Second == 0");
                    if (newDate.Hour == 0 && newDate.Minute == 0 && newDate.Second == 0)
                    {
                        newDate = newDate.AddDays(2);
                        newtime = newtime + (long)(new TimeSpan(2, 0, 0, 0).TotalSeconds);
                    }
                    else
                    {
                        continue;
                    }
                }
                else if (newDate.DayOfWeek == DayOfWeek.Sunday)
                {
                    Console.WriteLine(string.Format("{0} is Sunday", newDate.ToString(Parameters.DateTimeFormat)));
                    continue;
                }

                if (existRows.ContainsKey(newtime))// newDate >= minDate && newDate <= maxDate)
                {
                    continue;
                }

                if (rate[n].open == rate[n].close && rate[n].open == rate[n].low && rate[n].open == rate[n].high)
                {
                    Console.WriteLine(string.Format("{0} is all same price", newDate.ToString(Parameters.DateTimeFormat)));
                    //continue;
                }

                {
                    System.Data.DataRow row = dt.NewRow();
                    row["Time"] = newtime;
                    row["Date"] = newDate;
                    row["hour"] = newDate.Hour;
                    row["dayofweek"] = newDate.DayOfWeek;
                    row["open"] = rate[n].open;
                    row["close"] = rate[n].close;
                    row["high"] = rate[n].high;
                    row["low"] = rate[n].low;
                    row["spread"] = rate[n].spread;

                    if (period != "M1" && inds != null)
                    {
                        foreach (var kvp in inds)
                        {
                            if (kvp.Value.ContainsKey(rate[n].time))
                            {
                                row[kvp.Key] = kvp.Value[rate[n].time];
                            }
                            else
                            {
                                row[kvp.Key] = 0;
                            }
                        }
                    }
                    dt.Rows.Add(row);
                }
            }
            System.Console.WriteLine(string.Format("{0} has {1}, write {2}", symbolPeriodTime, existRows.Count, dt.Rows.Count));
            Feng.Data.DbHelper.Instance.BulkCopy(dt, symbolPeriodTime);

            //int n = 0;
            //Func<bool> f2 = () => n >= rate.Length;
            //Func<SqlCommand[]> f1 = () =>
            //{
            //    SqlCommand cmd = null;

            //    long newtime = rate[n].time + 60 * WekaUtils.GetMinuteofPeriod(period);
            //    DateTime newDate = WekaUtils.GetDateFromTime(newtime);

            //    if (existRows.ContainsKey(newtime))// newDate >= minDate && newDate <= maxDate)
            //    {
            //    }
            //    else
            //    {
            //        //if (!ind2.ContainsKey(rate[i].time / 3600 * 3600))
            //        //{
            //        //    WriteLog("No indicator of " + rate[i].time);
            //        //    continue;
            //        //}

            //        string sql = string.Format("INSERT INTO [{0}] ([time],[date],[hour],[dayofweek],[open],[close],[high],[low],[spread]", symbolPeriodTime);
            //        foreach (var kvp in inds)
            //        {
            //            sql += ",[" + kvp.Key + "]";
            //        }
            //        sql += ") VALUES (@time, @date, @hour,@dayofweek,@open, @close,@high,@low,@spread";
            //        foreach (var kvp in inds)
            //        {
            //            sql += ",@" + kvp.Key;
            //        }
            //        sql += ")";
            //        cmd = new SqlCommand(sql);

            //        cmd.Parameters.AddWithValue("@time", newtime);
            //        cmd.Parameters.AddWithValue("@date", newDate);
            //        cmd.Parameters.AddWithValue("@hour", newDate.Hour);
            //        cmd.Parameters.AddWithValue("@dayofweek", newDate.DayOfWeek);
            //        cmd.Parameters.AddWithValue("@open", rate[n].open);
            //        cmd.Parameters.AddWithValue("@close", rate[n].close);
            //        cmd.Parameters.AddWithValue("@high", rate[n].high);
            //        cmd.Parameters.AddWithValue("@low", rate[n].low);
            //        //cmd.Parameters.AddWithValue("@tick_volume", rate[i].tick_volume);
            //        cmd.Parameters.AddWithValue("@spread", rate[n].spread);
            //        //cmd.Parameters.AddWithValue("@real_volume", rate[i].real_volume);

            //        foreach (var kvp in inds)
            //        {
            //            if (kvp.Value.ContainsKey(rate[n].time))
            //            {
            //                cmd.Parameters.AddWithValue("@" + kvp.Key, kvp.Value[rate[n].time]);
            //            }
            //            else
            //            {
            //                cmd.Parameters.AddWithValue("@" + kvp.Key, 0);
            //            }
            //        }
            //    }

            //    n++;

            //    if (cmd != null)
            //    {
            //        return new SqlCommand[] { cmd };
            //    }
            //    else
            //    {
            //        return null;
            //    }
            //};

            //DbUtils.BatchDb(f1, f2);
        }

        public static void CheckDbZeroValues()
        {
            foreach (string symbol in Parameters.AllSymbolsFull)
            {
                foreach (string period in Parameters.AllPeriodsFull)
                {
                    foreach (var kvp in TestParameters.CandidateParameter4Db.AllIndNames2)
                    {
                        string sql = string.Format("SELECT COUNT(*) FROM {0}_{1} WHERE [{2}] IS NULL OR [{2}] = 0", symbol, period, kvp.Key);
                        int n = (int)DbHelper.Instance.ExecuteScalar(sql);
                        if (n > 0)
                        {
                            System.Console.WriteLine(string.Format("{0}_{1}_{2} Zero values = {3}", symbol, period, kvp.Key, n));
                            UpdateToDb(symbol, period, kvp.Key);
                        }
                    }
                    foreach (var kvp in TestParameters.CandidateParameter4Db.AllIndNames)
                    {
                        string sql = string.Format("SELECT COUNT(*) FROM {0}_{1} WHERE [{2}] IS NULL OR [{2}] = 0", symbol, period, kvp.Key);
                        int n = (int)DbHelper.Instance.ExecuteScalar(sql);
                        if (n > 0)
                        {
                            System.Console.WriteLine(string.Format("{0}_{1}_{2} Zero values = {3}", symbol, period, kvp.Key, n));
                        }
                        if (n > 5000)
                        {
                            UpdateToDb(symbol, period, kvp.Key);
                            int n2 = (int)DbHelper.Instance.ExecuteScalar(sql);
                            System.Console.WriteLine(string.Format("After Update, Zero values = {3}", symbol, period, kvp.Key, n2));
                        }
                    }
                }
            }
        }

        public static void UpdateToDb(string symbol, string period, string indName)
        {
            string symbolPeriod = symbol + "_" + period;

            var rate = MT5Data.ReadRates(symbolPeriod);

            string[] indNames = new string[] { indName };
            Dictionary<long, double>[] inds = new Dictionary<long, double>[indNames.Length];
            for (int i = 0; i < indNames.Length; ++i)
            {
                inds[i] = MT5Data.ReadIndicators(symbolPeriod, indNames[i]);
            }
            int n = 0;

            Func<bool> f2 = () => n >= rate.Length;
            Func<SqlCommand[]> f1 = () =>
            {
                long time = rate[n].time;

                for (int i = 0; i < indNames.Length; ++i)
                {
                    if (!inds[i].ContainsKey(time))
                    {
                        WekaUtils.Instance.WriteLog(string.Format("no indicator of time {0}", time));
                        return null;
                    }
                }
                long newtime = rate[n].time + 60 * WekaUtils.GetMinuteofPeriod(period);

                string sql = string.Format("UPDATE [{0}] SET ", symbolPeriod);
                for (int i = 0; i < indNames.Length; ++i)
                {
                    if (i != 0)
                        sql += ", ";
                    sql += indNames[i] + " = @" + indNames[i];
                }
                sql += " WHERE [time]=@time";

                SqlCommand cmd = new SqlCommand(sql);
                cmd.Parameters.AddWithValue("@time", newtime);
                for (int i = 0; i < indNames.Length; ++i)
                {
                    cmd.Parameters.AddWithValue("@" + indNames[i], inds[i][time]);
                }

                n++;

                return new SqlCommand[] { cmd };
            };

            DbUtils.BatchDb(f1, f2);
        }
        #endregion
        

        //private static void CheckSqlData(string symbol, string dealType, int tp, int sl)
        //{
        //    string hpColumn = WekaUtils.GetHpColumn(dealType, tp, sl);
        //    string hpColumnDate = WekaUtils.GetHpColumn(dealType, tp, sl, "date");
        //    try
        //    {
        //        string sql = string.Format("SELECT TOP 1 {0} FROM {1}_HP", hpColumn, symbol);
        //        DbHelper.Instance.ExecuteDataTable(sql);
        //    }
        //    catch (Exception)
        //    {
        //        System.Console.WriteLine("Database schema wrong, add column " + hpColumn);
        //        string sql = string.Format("ALTER TABLE {1}_HP ADD {0} FLOAT NULL", hpColumn, symbol);
        //        DbHelper.Instance.ExecuteNonQuery(sql);
        //        sql = string.Format("ALTER TABLE {1}_HP ADD {0} DATETIME NULL", hpColumnDate, symbol);
        //        DbHelper.Instance.ExecuteNonQuery(sql);

        //        //UpdateHp(symbol, period);
        //    }
        //}

        private static void TryCreateHpTable(string symbol)
        {
            string tableName = symbol + "_HP";
            try
            {
                var dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(string.Format("SELECT * FROM {0} WHERE Time = -1", tableName));
            }
            catch (Exception)
            {
                string sql = @"CREATE TABLE [dbo].[{0}](
	[Time] [bigint] NOT NULL,
	[DealType] [char] NOT NULL,
	[Tp] [int] NOT NULL,
	[Sl] [int] NOT NULL,
	[hp] [int] NOT NULL,
    [hp_date] [datetime] NOT NULL,
CONSTRAINT [PK_{0}] PRIMARY KEY CLUSTERED 
(
	[Time] ASC,
    [DealType] ASC,
    [Tp] ASC,
    [Sl] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]";
                DbHelper.Instance.ExecuteNonQuery(string.Format(sql, tableName));
            }
            
        }

        public static void UpdateAllHp3AllSymbols(string where = null)
        {
            //int n = 0;
            //var tasks = new System.Threading.Tasks.Task[Parameters.AllSymbols.Length - 1];
            foreach (string s in Parameters.AllSymbolsFull)
            {
                WekaUtils.Instance.WriteLog(string.Format("Now UpdateAllHp3 of {0}", s));
                TestParameters.CandidateParameter4Db.InitTpsls(TestParameters.GetTpSlMinDelta(s), 
                    TestParameters.TpMaxCount, TestParameters.SlMaxCount);

                Action action = () =>
                    {
                        try
                        {
                            string symbol = s;
                            UpdateAllHp3(symbol, where);
                        }
                        catch (Exception ex)
                        {
                            WekaUtils.Instance.WriteLog(ex.Message);
                        }
                        SimulationData.Instance.Clear();
                    };
                action();
                //tasks[n] = System.Threading.Tasks.Task.Factory.StartNew(
                //n++;
            }
            //System.Threading.Tasks.Task.WaitAll(tasks);
        }
        public static void UpdateAllHp3(string symbol, string where = null, bool updateUnComplete = false)
        {
            //where = " TIME % 1800 = 0 AND Time >= " + WekaUtils.GetTimeFromDate(new DateTime(2001, 4, 10, 0, 0, 0)) +
            //    " AND TIME < " + WekaUtils.GetTimeFromDate(new DateTime(2001, 4, 11));
            try
            {
                DbHelper.Instance.ExecuteNonQuery(string.Format("SELECT * FROM {0}_HP WHERE TIME = -1", symbol));
            }
            catch (Exception)
            {
                string sql = @"CREATE TABLE [dbo].[{0}_HP](
	[Time] [bigint] NOT NULL,
	[hp] [varbinary](max) NOT NULL,
	[hp_date] [varbinary](max) NOT NULL,
    [IsComplete] [bit] NOT NULL,
 CONSTRAINT [PK_{0}_HP] PRIMARY KEY CLUSTERED 
(
	[Time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
)";
                DbHelper.Instance.ExecuteNonQuery(string.Format(sql, symbol));
            }
            bool deleteFirst = false;
            if (deleteFirst)
            {
                string sql = string.Format("DELETE FROM {0}_HP WHERE {1}",
                                 symbol,
                                 string.IsNullOrEmpty(where) ? "1=1" : where);
                WekaUtils.Instance.WriteLog(sql);
                DbHelper.Instance.ExecuteNonQuery(sql);
            }

            System.Data.DataTable dt2 = new System.Data.DataTable();
            dt2.Columns.Add(new System.Data.DataColumn("Time", typeof(long)));
            dt2.Columns.Add(new System.Data.DataColumn("hp", typeof(byte[])));
            dt2.Columns.Add(new System.Data.DataColumn("hp_date", typeof(byte[])));
            dt2.Columns.Add(new System.Data.DataColumn("IsComplete", typeof(bool)));

            bool useAlreadHps = true;
            System.Data.DataTable dt = GetUpdateHpMainTable(symbol, where, TestParameters2.CandidateParameter.MainPeriod, useAlreadHps);

            //Dictionary<long, int> alreadyHps = new Dictionary<long, int>();
            //
            //if (useAlreadHps)
            //{
            //    System.Data.DataTable dtHp = DbHelper.Instance.ExecuteDataTable(string.Format("SELECT Time FROM {0}_HP WHERE IsComplete = 1", symbol));
            //    foreach (System.Data.DataRow row in dtHp.Rows)
            //    {
            //        long time = (long)row[0];
            //        alreadyHps[time] = 1;
            //    }
            //}

            var simulationData = SimulationData.Instance.Init(symbol);
            ISimulateStrategy[,] strategys = new ISimulateStrategy[TestParameters.CandidateParameter4Db.BatchTps.Length, TestParameters.CandidateParameter4Db.BatchSls.Length];
            for (int i = 0; i < TestParameters.CandidateParameter4Db.BatchTps.Length; ++i)
            {
                for (int j = 0; j < TestParameters.CandidateParameter4Db.BatchSls.Length; ++j)
                {
                    int tp = TestParameters.CandidateParameter4Db.BatchTps[i];
                    int sl = TestParameters.CandidateParameter4Db.BatchSls[j];

                    strategys[i, j] = new TpSlM1SimulateStrategy(symbol, tp * 10, sl * 10, simulationData);
                }
            }

            try
            {
                if (TestParameters.EnableMultiThread)
                {
                    Parallel.ForEach<System.Data.DataRow>(dt.Rows.Cast<System.Data.DataRow>(), row =>
                        {
                            UpdateHpRow(row, symbol, strategys, dt2, updateUnComplete);
                        }
                     );
                }
                else
                {
                    foreach (System.Data.DataRow row in dt.Rows)
                    {
                        UpdateHpRow(row, symbol, strategys, dt2, updateUnComplete);
                    }
                }

                DbHelper.Instance.BulkCopy(dt2, string.Format("{0}_HP", symbol));
                dt2.Rows.Clear();
            }
            catch (ArgumentOutOfRangeException)
            {
            }
        }

        private static void UpdateHpRow(System.Data.DataRow row, string symbol, ISimulateStrategy[,] strategys, System.Data.DataTable dtDest, bool updateUnComplete)
        {
            DateTime date = (DateTime)row["Date"];
            if (date.DayOfWeek == DayOfWeek.Saturday || date.DayOfWeek == DayOfWeek.Sunday)
                return;
            long time = WekaUtils.GetTimeFromDate(date);
            //if (alreadyHps.ContainsKey(time))
            //    return;

            System.Console.WriteLine(string.Format("Now updatehp of {0}, {1}", date.ToString(Parameters.DateTimeFormat), symbol));

            sbyte?[, ,] hps;
            long?[, ,] hpTimes;

            var hpRow = DbHelper.Instance.ExecuteDataRow(string.Format("SELECT * FROM {0}_HP WHERE TIME = {1}", symbol, time));
            if (hpRow != null)
            {
                hps = HpData.DeserializeHp((byte[])hpRow["hp"]);
                hpTimes = HpData.DeserializeHpTimes((byte[])hpRow["hp_date"]);
            }
            else
            {
                hps = new sbyte?[Parameters.AllDealTypes.Length, TestParameters.CandidateParameter4Db.BatchTps.Length, TestParameters.CandidateParameter4Db.BatchSls.Length];
                hpTimes = new long?[Parameters.AllDealTypes.Length, TestParameters.CandidateParameter4Db.BatchTps.Length, TestParameters.CandidateParameter4Db.BatchSls.Length];
                for (int k = 0; k < Parameters.AllDealTypes.Length; ++k)
                {
                    for (int i = 0; i < TestParameters.CandidateParameter4Db.BatchTps.Length; ++i)
                    {
                        for (int j = 0; j < TestParameters.CandidateParameter4Db.BatchSls.Length; ++j)
                        {
                            hps[k, i, j] = null;
                            hpTimes[k, i, j] = null;
                        }
                    }
                }
            }

            bool[] isComplete = new bool[Parameters.AllDealTypes.Length];
            for (int k = 0; k < Parameters.AllDealTypes.Length; ++k)
            {
                char dealType = Parameters.AllDealTypes[k];
                isComplete[k] = true;

                for (int i = 0; i < TestParameters.CandidateParameter4Db.BatchTps.Length; ++i)
                {
                    if (!isComplete[k])
                        break;
                    for (int j = 0; j < TestParameters.CandidateParameter4Db.BatchSls.Length; ++j)
                    {
                        if (!isComplete[k])
                            break;

                        if (hps[k, i, j].HasValue && hps[k, i, j] != -1)
                            continue;

                        ISimulateStrategy strategy = strategys[i, j];

                        DateTime? closeDate;
                        bool? hp;
                        if (dealType == 'B')
                            hp = strategy.DoBuy(date, (double)row["Close"], out closeDate);
                        else if (dealType == 'S')
                            hp = strategy.DoSell(date, (double)row["Close"], out closeDate);
                        else
                            throw new ArgumentException("Invalid dealtype of " + dealType);

                        if (hp.HasValue)
                        {
                            if (hp.Value)
                            {
                                // tp
                                for (int jj = j; jj < TestParameters.CandidateParameter4Db.BatchSls.Length; ++jj)
                                {
                                    hps[k, i, jj] = 1;
                                    hpTimes[k, i, jj] = WekaUtils.GetTimeFromDate(closeDate.Value);
                                }
                            }
                            else
                            {
                                for (int ii = i; ii < TestParameters.CandidateParameter4Db.BatchTps.Length; ++ii)
                                {
                                    hps[k, ii, j] = 0;
                                    hpTimes[k, ii, j] = WekaUtils.GetTimeFromDate(closeDate.Value);
                                }
                            }
                        }
                        else
                        {
                            isComplete[k] = false;
                            //if (dealType == 'B')
                            //    hp = strategy.DoBuy(date, (double)row["Close"], out closeDate);
                            //else if (dealType == 'S')
                            //    hp = strategy.DoSell(date, (double)row["Close"], out closeDate);

                            //if (!updateUnComplete)
                            //{
                            //    lock (dtDest)
                            //    {
                            //        DbHelper.Instance.BulkCopy(dtDest, string.Format("{0}_HP", symbol));
                            //        dtDest.Rows.Clear();

                            //        throw new AssertException("hp should not be null");
                            //    }
                            //}
                        }
                    }
                }
            }
            if (hpRow != null)
            {
                System.Data.SqlClient.SqlCommand updateCmd = new SqlCommand(string.Format("UPDATE [{0}_HP] SET [hp] = @hp,[hp_date] = @hp_date,[IsComplete] = @IsComplete WHERE [Time] = @Time", symbol));
                updateCmd.Parameters.AddWithValue("@hp", HpData.SerializeHp(hps));
                updateCmd.Parameters.AddWithValue("@hp_date", HpData.SerializeHpTimes(hpTimes));
                updateCmd.Parameters.AddWithValue("@IsComplete", WekaUtils.AndAll(isComplete));
                updateCmd.Parameters.AddWithValue("@Time", time);

                Feng.Data.DbHelper.Instance.ExecuteNonQuery(updateCmd);
            }
            else
            {
                lock (dtDest)
                {
                    if (!updateUnComplete && (!isComplete[0] || !isComplete[1]))
                        return;

                    System.Data.DataRow row2 = dtDest.NewRow();
                    row2["Time"] = row["Time"];
                    row2["hp"] = HpData.SerializeHp(hps);
                    row2["hp_date"] = HpData.SerializeHpTimes(hpTimes);
                    row2["IsComplete"] = WekaUtils.AndAll(isComplete);
                    dtDest.Rows.Add(row2);

                    if (dtDest.Rows.Count >= 100)
                    {
                        DbHelper.Instance.BulkCopy(dtDest, string.Format("{0}_HP", symbol));
                        dtDest.Rows.Clear();
                    }
                }
            }
        }
        public static void TestUpdateAllHp3()
        {
            var dt = DbHelper.Instance.ExecuteDataTable("SELECT * FROM EURUSD_HP");
            DateTime date = WekaUtils.GetDateFromTime((long)dt.Rows[0]["time"]);
            sbyte?[, ,] hp = HpData.DeserializeHp((byte[])dt.Rows[0]["hp"]);
            long?[, ,] hpTime = HpData.DeserializeHpTimes((byte[])dt.Rows[0]["hp_date"]);
        }
        public static void UpdateAllHp2(string symbol, string where = null)
        {
            bool deleteFirst = true;
            if (deleteFirst)
            {
                foreach (char dealType in Parameters.AllDealTypes)
                {
                    for (int i = 0; i < TestParameters.CandidateParameter4Db.BatchTps.Length; ++i)
                    {
                        for (int j = 0; j < TestParameters.CandidateParameter4Db.BatchSls.Length; ++j)
                        {
                            string sql = string.Format("DELETE FROM {0}_HP WHERE {1} AND DealType = '{2}' AND Tp = '{3}' AND Sl = '{4}'",
                                symbol,
                                string.IsNullOrEmpty(where) ? "1=1" : where,
                                dealType, TestParameters.CandidateParameter4Db.BatchTps[i], TestParameters.CandidateParameter4Db.BatchSls[j]);
                            WekaUtils.Instance.WriteLog(sql);
                            DbHelper.Instance.ExecuteNonQuery(sql);
                        }
                    }
                }
            }

            System.Data.DataTable dt2 = new System.Data.DataTable();
            dt2.Columns.Add(new System.Data.DataColumn("Time", typeof(long)));
            dt2.Columns.Add(new System.Data.DataColumn("DealType", typeof(string)));
            dt2.Columns.Add(new System.Data.DataColumn("Tp", typeof(int)));
            dt2.Columns.Add(new System.Data.DataColumn("Sl", typeof(int)));
            dt2.Columns.Add(new System.Data.DataColumn("hp", typeof(int)));
            dt2.Columns.Add(new System.Data.DataColumn("hp_date", typeof(DateTime)));

            System.Data.DataTable dt = GetUpdateHpMainTable(symbol, where);

            var simulationData = SimulationData.Instance.Init(symbol);
            ISimulateStrategy[,] strategys = new ISimulateStrategy[TestParameters.CandidateParameter4Db.BatchTps.Length, TestParameters.CandidateParameter4Db.BatchSls.Length];
            for (int i = 0; i < TestParameters.CandidateParameter4Db.BatchTps.Length; ++i)
            {
                for (int j = 0; j < TestParameters.CandidateParameter4Db.BatchSls.Length; ++j)
                {
                    int tp = TestParameters.CandidateParameter4Db.BatchTps[i];
                    int sl = TestParameters.CandidateParameter4Db.BatchSls[j];

                    strategys[i, j] = new TpSlM1SimulateStrategy(symbol, tp * 0.0001, sl * 0.0001, simulationData);
                }
            }
            foreach (System.Data.DataRow row in dt.Rows)
            {
                DateTime date = (DateTime)row["Date"];
                System.Console.WriteLine(string.Format("Now updatehp of {0}", date.ToString(Parameters.DateTimeFormat)));

                foreach (char dealType in Parameters.AllDealTypes)
                {
                    int?[,] hps = new int?[TestParameters.CandidateParameter4Db.BatchTps.Length, TestParameters.CandidateParameter4Db.BatchSls.Length];
                    DateTime?[,] hpDates = new DateTime?[TestParameters.CandidateParameter4Db.BatchTps.Length, TestParameters.CandidateParameter4Db.BatchSls.Length];
                    for (int i = 0; i < TestParameters.CandidateParameter4Db.BatchTps.Length; ++i)
                    {
                        for (int j = 0; j < TestParameters.CandidateParameter4Db.BatchSls.Length; ++j)
                        {
                            hps[i, j] = -1;
                        }
                    }

                    for (int i = 0; i < TestParameters.CandidateParameter4Db.BatchTps.Length; ++i)
                    {
                        for (int j = 0; j < TestParameters.CandidateParameter4Db.BatchSls.Length; ++j)
                        {
                            if (hps[i, j] != -1)
                                continue;

                            
                            ISimulateStrategy strategy = strategys[i, j];

                            DateTime? closeDate;
                            bool? hp;
                            if (dealType == 'B')
                                hp = strategy.DoBuy(date, (double)row["Close"], out closeDate);
                            else if (dealType == 'S')
                                hp = strategy.DoSell(date, (double)row["Close"], out closeDate);
                            else
                                throw new ArgumentException("Invalid dealtype of " + dealType);

                            if (hp.HasValue)
                            {
                                if (hp.Value)
                                {
                                    // tp
                                    for (int jj = j; jj < TestParameters.CandidateParameter4Db.BatchSls.Length; ++jj)
                                    {
                                        hps[i, jj] = 1;
                                        hpDates[i, jj] = closeDate.Value;
                                    }
                                }
                                else
                                {
                                    for (int ii = i; ii < TestParameters.CandidateParameter4Db.BatchTps.Length; ++ii)
                                    {
                                        hps[ii, j] = 0;
                                        hpDates[ii, j] = closeDate.Value;
                                    }
                                }
                            }
                            else
                            {
                                for (int ii = i; ii < TestParameters.CandidateParameter4Db.BatchTps.Length; ++ii)
                                    for (int jj = j; jj < TestParameters.CandidateParameter4Db.BatchSls.Length; ++jj)
                                    {
                                        hps[ii, jj] = null;
                                        hpDates[ii, jj] = null;
                                    }
                            }
                        }
                    }

                    for (int i = 0; i < TestParameters.CandidateParameter4Db.BatchTps.Length; ++i)
                    {
                        for (int j = 0; j < TestParameters.CandidateParameter4Db.BatchSls.Length; ++j)
                        {
                            System.Data.DataRow row2 = dt2.NewRow();
                            row2["Time"] = row["Time"];
                            row2["DealType"] = dealType;
                            row2["Tp"] = TestParameters.CandidateParameter4Db.BatchTps[i];
                            row2["Sl"] = TestParameters.CandidateParameter4Db.BatchSls[j];
                            row2["hp"] = hps[i, j] == null ? (object)System.DBNull.Value : hps[i, j].Value;
                            row2["hp_date"] = hpDates[i, j] == null ? (object)System.DBNull.Value : hpDates[i, j].Value;
                            dt2.Rows.Add(row2);
                        }
                    }
                }

                if (dt2.Rows.Count > 50000)
                {
                    DbHelper.Instance.BulkCopy(dt2, string.Format("{0}_HP", symbol));
                    dt2.Rows.Clear();
                }
            }
            DbHelper.Instance.BulkCopy(dt2, string.Format("{0}_HP", symbol));
            dt2.Rows.Clear();
        }

        public static void UpdateAllHp(string symbol = "EURUSD", string where = null)
        {
            //TryCreateHpTable(symbol);
            TestParameters.EnableDetailLog = false;

            bool deleteFirst = true;
            if (deleteFirst)
            {
                string sql = string.Format("DELETE FROM {0}_HP WHERE {1}",
                    symbol,
                    string.IsNullOrEmpty(where) ? "1=1" : where);
                DbHelper.Instance.ExecuteNonQuery(sql);
            }

            System.Data.DataTable dt = GetUpdateHpMainTable(symbol, where);
            foreach (char dealType in Parameters.AllDealTypes)
            {
                for (int i = 0; i < TestParameters.CandidateParameter4Db.BatchTps.Length; ++i)
                {
                    for (int j = 0; j < TestParameters.CandidateParameter4Db.BatchSls.Length; ++j)
                    {
                        int tp = TestParameters.CandidateParameter4Db.BatchTps[i];
                        int sl = TestParameters.CandidateParameter4Db.BatchSls[j];

                        try
                        {
                            //CheckSqlData(symbol, dealType, tp, sl);

                            string sql = string.Format("SELECT COUNT(*) FROM {0}_HP WHERE hp IS NOT NULL AND DealType = '{1}' AND Tp = {2} AND Sl = {3} AND {4}",
                                symbol, dealType, tp, sl,
                                string.IsNullOrEmpty(where) ? "1 = 1" : where);
                            int n1 = (int)DbHelper.Instance.ExecuteScalar(sql);
                            sql = string.Format("SELECT COUNT(*) FROM {0}_HP WHERE hp IS NULL AND DealType = '{1}' AND Tp = {2} AND Sl = {3} AND {4}",
                                symbol, dealType, tp, sl,
                                string.IsNullOrEmpty(where) ? "1 = 1" : where);
                            int n2 = (int)DbHelper.Instance.ExecuteScalar(sql);
                            if (dt.Rows.Count - n1 - n2 > 0)
                            {
                                sql = string.Format("SELECT Time FROM {0}_HP WHERE DealType = '{1}' AND Tp = {2} AND Sl = {3} AND {4}",
                                    symbol, dealType, tp, sl,
                                    string.IsNullOrEmpty(where) ? "1 = 1" : where);
                                var dt2 = DbHelper.Instance.ExecuteDataTable(sql);

                                Dictionary<long, int> dict = new Dictionary<long, int>();
                                foreach (System.Data.DataRow row in dt2.Rows)
                                {
                                    dict[(long)row[0]] = 1;
                                }
                                var dtDiff = dt.Clone();
                                foreach (System.Data.DataRow row in dt.Rows)
                                {
                                    long t = (long)row["Time"];
                                    if (!dict.ContainsKey(t))
                                    {
                                        var row2 = dtDiff.NewRow();
                                        row2.ItemArray = row.ItemArray;
                                        dtDiff.Rows.Add(row2);
                                    }
                                }
                                System.Console.WriteLine(string.Format("UpdateHp with count = {0}", dtDiff.Rows.Count));
                                UpdateHp(symbol, dealType, tp, sl, where, dtDiff);
                            }
                            else
                            {
                                //sql = string.Format("SELECT COUNT(*) FROM {0}_HP WHERE hp IS NOT NULL AND DealType = '{1}' AND Tp = {2} AND Sl = {3}", symbol, dealType, tp, sl);
                                //int n2 = (int)DbHelper.Instance.ExecuteScalar(sql);
                                //if (n2 < 20000)
                                //{
                                //    UpdateHp(symbol, dealType, tp, sl);
                                //}
                                //else
                                {
                                    System.Console.WriteLine(string.Format("CheckSqlData of {0}_{1}_{2}_{3} = {4}, {5}, {6}", symbol, dealType, tp, sl, dt.Rows.Count, n1, n2));
                                }
                            }

                            System.Threading.Thread.Sleep(5000);
                        }
                        catch (Exception ex)
                        {
                            System.Console.WriteLine(ex.Message);
                            System.Console.WriteLine(ex.StackTrace);
                        }
                    }
                }
            }
        }

        private static System.Data.DataTable GetUpdateHpMainTable(string symbol, string where = null, string period = "M5", bool useAlreadHps = true)
        {
            string sql;
            if (!useAlreadHps)
            {
                sql = string.Format("SELECT [Time], [Date], [Close] FROM {0}_{1} WHERE {2} ORDER BY Time",
                    symbol, period,
                    string.IsNullOrEmpty(where) ? "1 = 1" : where);
            }
            else
            {
                sql = string.Format("SELECT [Time], [Date], [Close] FROM {0}_{1} WHERE {2} AND ([Time] NOT IN (SELECT Time FROM {0}_HP WHERE IsComplete = 1)) ORDER BY Time",
                    symbol, period,
                    string.IsNullOrEmpty(where) ? "1 = 1" : where);
            }
            System.Data.DataTable dt = DbHelper.Instance.ExecuteDataTable(sql);
            return dt;
        }

        public static void UpdateHp(string symbol, char dealType, int tp, int sl, string where, System.Data.DataTable dt = null, bool deleteFirst = false)
        {
            if (dt == null)
            {
                dt = GetUpdateHpMainTable(symbol, where);
            }
            System.Console.WriteLine(string.Format("UpdateHp of {0}_{1}_{2}_{3}", symbol, dealType, tp, sl));

            if (deleteFirst)
            {
                string sql = string.Format("DELETE FROM {0}_HP WHERE DealType = '{1}' AND Tp = {2} AND Sl = {3} AND {4}",
                    symbol, dealType, tp, sl,
                    string.IsNullOrEmpty(where) ? "1=1" : where);
                DbHelper.Instance.ExecuteNonQuery(sql);
            }

            ISimulateStrategy strategy;// = new TpSlSimulateStrategy(0.0070, 0.0035);
            var simulationData = SimulationData.Instance.Init(symbol);
            strategy = new TpSlM1SimulateStrategy(symbol, tp * 0.0001, sl * 0.0001, simulationData);
            //strategy = new BreakEvenM1SimulateStrategy(0.0080, 0.0030, 0.0030);
            //strategy = new PriceProbSimulationStrategy(60, 0.0600);

            System.Data.DataTable dt2 = new System.Data.DataTable();
            dt2.Columns.Add(new System.Data.DataColumn("Time", typeof(long)));
            dt2.Columns.Add(new System.Data.DataColumn("DealType", typeof(string)));
            dt2.Columns.Add(new System.Data.DataColumn("Tp", typeof(int)));
            dt2.Columns.Add(new System.Data.DataColumn("Sl", typeof(int)));
            dt2.Columns.Add(new System.Data.DataColumn("hp", typeof(int)));
            dt2.Columns.Add(new System.Data.DataColumn("hp_date", typeof(DateTime)));
            foreach (System.Data.DataRow row in dt.Rows)
            {
                DateTime date = (DateTime)row["Date"];

                DateTime? closeDate;
                bool? hp;
                if (dealType == 'B')
                    hp = strategy.DoBuy(date, (double)row["Close"], out closeDate);
                else if (dealType == 'S')
                    hp = strategy.DoSell(date, (double)row["Close"], out closeDate);
                else
                    throw new ArgumentException("Invalid dealtype of " + dealType);

                System.Data.DataRow row2 = dt2.NewRow();
                row2["Time"] = row["Time"];
                row2["DealType"] = dealType;
                row2["Tp"] = tp;
                row2["Sl"] = sl;
                row2["hp"] = hp == null ? (object)System.DBNull.Value : hp;
                row2["hp_date"] = closeDate == null ? (object)System.DBNull.Value : closeDate;
                dt2.Rows.Add(row2);
            }
            DbHelper.Instance.BulkCopy(dt2, string.Format("{0}_HP", symbol));
            //System.Threading.ThreadPool.QueueUserWorkItem(new System.Threading.WaitCallback((o) =>
            //    {
            //        System.Console.WriteLine(string.Format("UpdateWriteHp Start of {0}_{1}_{2}_{3}", symbol, dealType, tp, sl));
            //        DbHelper.Instance.BulkCopy(dt2, string.Format("{0}_HP", symbol));
            //        System.Console.WriteLine(string.Format("UpdateWriteHp End of {0}_{1}_{2}_{3}", symbol, dealType, tp, sl));
            //    }));
        }

        public static void ConvertHpDataToSingleTableAll(string symbol)
        {
            for (int i = 0; i < TestParameters.CandidateParameter4Db.BatchTps.Length; ++i)
            {
                for (int j = 0; j < TestParameters.CandidateParameter4Db.BatchSls.Length; ++j)
                {
                    foreach (char s in Parameters.AllDealTypes)
                    {
                        ConvertHpDataToSingleTable(symbol, s, TestParameters.CandidateParameter4Db.BatchTps[i], TestParameters.CandidateParameter4Db.BatchSls[j]);
                        System.Console.WriteLine(string.Format("{0}_{1}_{2}_{3} is Converted.", symbol, s, TestParameters.CandidateParameter4Db.BatchTps[i], TestParameters.CandidateParameter4Db.BatchSls[j]));
                    }
                }
            }
        }
        public static void ConvertHpDataToSingleTable(string symbol, char dealType, int tp, int sl, bool forceDelete = false)
        {
            string sql;
            int n = 0;
            if (!forceDelete)
            {
                sql = string.Format("SELECT COUNT(*) FROM {0}_HP WHERE DealType = '{1}' AND Tp = {2} AND Sl = {3}", symbol, dealType, tp, sl);
                n = (int)DbHelper.Instance.ExecuteScalar(sql);
                if (n > 5000)
                {
                    return;
                }
            }
            if (forceDelete || n > 0)
            {
                sql = string.Format("DELETE FROM {0}_HP WHERE DealType = '{1}' AND Tp = {2} AND Sl = {3}", symbol, dealType, tp, sl);
                DbHelper.Instance.ExecuteNonQuery(sql);
            }
            sql = string.Format("SELECT Time, {1}_hp_{2}_{3}, {1}_hp_date_{2}_{3} FROM {0}_M5", symbol, dealType, tp, sl);
            var dt = DbHelper.Instance.ExecuteDataTable(sql);

            System.Data.DataTable dt2 = new System.Data.DataTable();
            dt2.Columns.Add(new System.Data.DataColumn("Time", typeof(long)));
            dt2.Columns.Add(new System.Data.DataColumn("DealType", typeof(string)));
            dt2.Columns.Add(new System.Data.DataColumn("Tp", typeof(int)));
            dt2.Columns.Add(new System.Data.DataColumn("Sl", typeof(int)));
            dt2.Columns.Add(new System.Data.DataColumn("hp", typeof(int)));
            dt2.Columns.Add(new System.Data.DataColumn("hp_date", typeof(DateTime)));
            foreach (System.Data.DataRow row in dt.Rows)
            {
                System.Data.DataRow row2 = dt2.NewRow();
                row2["Time"] = row[0];
                row2["DealType"] = dealType;
                row2["Tp"] = tp;
                row2["Sl"] = sl;
                row2["hp"] = row[1];
                row2["hp_date"] = row[2];
                dt2.Rows.Add(row2);
            }

            DbHelper.Instance.BulkCopy(dt2, string.Format("{0}_HP", symbol));
            //            var txn = DbHelper.Instance.BeginTransaction();
            //            foreach (System.Data.DataRow row in dt.Rows)
            //            {
            //                sql = string.Format(@"INSERT INTO {0}_HP ([Time],[DealType],[Tp],[Sl],[hp],[hp_date])
            //                    VALUES
            //                    (@Time,@DealType,@Tp,@Sl,@hp,@hp_date)", symbol);
            //                var cmd = new System.Data.SqlClient.SqlCommand(sql);
            //                cmd.Parameters.AddWithValue("@Time", row[0]);
            //                cmd.Parameters.AddWithValue("@DealType", dealType);
            //                cmd.Parameters.AddWithValue("@Tp", tp);
            //                cmd.Parameters.AddWithValue("@Sl", sl);
            //                cmd.Parameters.AddWithValue("@hp", row[1]);
            //                cmd.Parameters.AddWithValue("@hp_date", row[2]);
            //                cmd.Transaction = txn as System.Data.SqlClient.SqlTransaction;
            //                DbHelper.Instance.ExecuteNonQuery(cmd);
            //            }
            //            DbHelper.Instance.CommitTransaction(txn);
        }
        public static void CompensateMissingDateAll()
        {
            TestParameters.EnableDetailLog = false;
            DoAllSymbolPeriod((s1, s2) =>
            {
                CompensateMissingDate(s1, s2);
            });
        }
        public static void CheckDataIntegrityAll()
        {
            DoAllSymbolPeriod((s1, s2) =>
            {
                CheckDataIntegrity(s1, s2);
            });
        }

        public static void CompensateMissingDate(string symbol, string period)
        {
            List<DateTime> missingDate = CheckDataIntegrity(symbol, period);
            string symbolPeriod = symbol + "_" + period;

            System.Data.DataTable dtSrc = DbHelper.Instance.ExecuteDataTable(string.Format("SELECT * FROM {0} WHERE Time = -1", symbolPeriod));
            for (int i = 0; i < missingDate.Count; ++i)
            {
                var dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(string.Format("SELECT TOP 1 * FROM {0} WHERE Time < '{1}' ORDER BY Time DESC",
                    symbolPeriod, WekaUtils.GetTimeFromDate(missingDate[i])));
                if (dt.Rows.Count == 0)
                {
                    continue;
                }
                if (TestParameters.EnableDetailLog)
                {
                    System.Console.WriteLine(string.Format("Compensate {0} with Data {1}", missingDate[i], dt.Rows[0]["Date"]));
                }

                System.Data.DataRow row = dtSrc.NewRow();
                for (int j = 0; j < dt.Columns.Count; ++j)
                {
                    row[dt.Columns[j].ColumnName] = dt.Rows[0][j];
                }
                row["Date"] = missingDate[i];
                row["Time"] = WekaUtils.GetTimeFromDate(missingDate[i]);
                row["Spread"] = -1;

                dtSrc.Rows.Add(row);
            }

            System.Console.WriteLine(string.Format("Write {0} missing rows to {1}", dtSrc.Rows.Count, symbolPeriod));
            DbHelper.Instance.BulkCopy(dtSrc, symbolPeriod);

            //int i = 0;
            //Func<bool> f2 = () => i >= missingDate.Count;
            //Func<SqlCommand[]> f1 = () =>
            //{
            //    var dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(string.Format("SELECT TOP 1 * FROM {0} WHERE Time < '{1}' ORDER BY Time DESC",
            //        symbolPeriod, WekaUtils.GetTimeFromDate(missingDate[i])));
            //    if (dt.Rows.Count == 0)
            //    {
            //        i++;
            //        return null;
            //    }
            //    System.Console.WriteLine(string.Format("Compensate {0} with Data {1}", missingDate[i], dt.Rows[0]["Date"]));

            //    dt.Rows[0]["Date"] = missingDate[i];
            //    dt.Rows[0]["Time"] = WekaUtils.GetTimeFromDate(missingDate[i]);
            //    dt.Rows[0]["Spread"] = -1;
            //    StringBuilder sb = new StringBuilder();
            //    sb.Append("INSERT INTO ");
            //    sb.Append(symbolPeriod);
            //    sb.Append(" (");
            //    for (int j = 0; j < dt.Columns.Count; ++j)
            //    {
            //        sb.Append("[" + dt.Columns[j].ColumnName + "]");
            //        if (j != dt.Columns.Count - 1)
            //            sb.Append(",");
            //    }
            //    sb.Append(") VALUES (");
            //    for (int j = 0; j < dt.Columns.Count; ++j)
            //    {
            //        sb.Append("'" + dt.Rows[0][j] + "'");
            //        if (j != dt.Columns.Count - 1)
            //            sb.Append(",");
            //    }
            //    sb.Append(")");
            //    //DbHelper.Instance.ExecuteNonQuery(sb.ToString());

            //    i++;

            //    return new SqlCommand[] { new SqlCommand(sb.ToString()) };
            //};

            //while (!f2())
            //{
            //    var cmds = f1();
            //    if (cmds != null)
            //    {
            //        DbHelper.Instance.ExecuteNonQuery(cmds[0]);
            //    }
            //}
        }

        public static void DeleteCompensateDateAll()
        {
            DoAllSymbolPeriod((s1, s2) =>
            {
                DeleteCompensateDate(s1, s2);
                System.Console.WriteLine(string.Format("DELETE {0}_{1}", s1, s2));
            });
        }
        public static void DeleteCompensateDate(string symbol, string period)
        {
            string symbolPeriod = symbol + "_" + period;
            // or delete where spread = -1
            DbHelper.Instance.ExecuteNonQuery(string.Format("DELETE FROM {0} WHERE SPREAD = -1", symbolPeriod));

            //var dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(string.Format("SELECT Time FROM {0} ORDER BY Time", symbolPeriod));

            //string rateFileName = string.Format("D:\\Program Files\\MetaTrader 5\\MQL5\\Files\\{0}.dat", symbolPeriod);
            //var rate = WekaUtils.ReadRates(rateFileName);
            //Dictionary<long, MqlRates> rate2 = new Dictionary<long, MqlRates>();
            //foreach (var i in rate)
            //{
            //    rate2[i.time] = i;
            //}
            //foreach (System.Data.DataRow row in dt.Rows)
            //{
            //    long t = (long)row[0];
            //    if (!rate2.ContainsKey(t))
            //    {
            //        string sql = string.Format("DELETE FROM {0} WHERE TIME = {1}", symbolPeriod, t);
            //        DbHelper.Instance.ExecuteNonQuery(sql);
            //        System.Console.WriteLine(string.Format("DELETE {0} AT {1}", symbolPeriod, t));
            //    }
            //}
        }

        public static List<DateTime> CheckDataIntegrity(string symbol, string period)
        {
            string symbolPeriod = symbol + "_" + period;
            List<DateTime> ret = new List<DateTime>();
            var dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(string.Format("SELECT Date FROM {0} ORDER BY Time", symbolPeriod));

            DateTime now = new DateTime(2000, 1, 1);
            int min = WekaUtils.GetMinuteofPeriod(period);
            int h = min / 60;
            int m = min % 60;
            now = now.AddMinutes(min);

            int i = 0;
            while (true)
            {
                DateTime shouldNext = now.AddMinutes(min);
                now = shouldNext;
                if (shouldNext.DayOfWeek == DayOfWeek.Sunday)
                    continue;
                if (shouldNext.DayOfWeek == DayOfWeek.Saturday && (shouldNext.Hour != 0 || shouldNext.Minute != 0))
                    continue;
                if (shouldNext.DayOfWeek == DayOfWeek.Monday && shouldNext.Hour == 0 && shouldNext.Minute == 0)
                    continue;

                DateTime next = (DateTime)dt.Rows[i]["Date"];

                while (next < shouldNext)
                {
                    i++;
                    next = (DateTime)dt.Rows[i]["Date"];
                }
                if (next == shouldNext)
                {
                    i++;
                    if (i == dt.Rows.Count)
                        break;
                    continue;
                }

                ret.Add(shouldNext);

                if (TestParameters.EnableDetailLog)
                {
                    System.Console.WriteLine(shouldNext + " is missing!");
                }
            }

            return ret;
        }
        public static void CheckDateIntegrityOfCount()
        {
            foreach (string symbol in Parameters.AllSymbolsFull)
            {
                System.Console.WriteLine(string.Format("Now is symbol {0}", symbol));
                int c1 = (int)DbHelper.Instance.ExecuteScalar(string.Format("SELECT COUNT(*) FROM {0}_D1", symbol));
                int c2 = (int)DbHelper.Instance.ExecuteScalar(string.Format("SELECT COUNT(*) FROM {0}_H4", symbol));
                int c3 = (int)DbHelper.Instance.ExecuteScalar(string.Format("SELECT COUNT(*) FROM {0}_H1", symbol));
                int c4 = (int)DbHelper.Instance.ExecuteScalar(string.Format("SELECT COUNT(*) FROM {0}_M15", symbol));
                int c5 = (int)DbHelper.Instance.ExecuteScalar(string.Format("SELECT COUNT(*) FROM {0}_M5", symbol));
                System.Console.WriteLine(string.Format("D1 * 6 = {0}, H4 = {1}", c1 * 6, c2));
                System.Console.WriteLine(string.Format("H4 * 4 = {0}, H1 = {1}", c2 * 4, c3));
                System.Console.WriteLine(string.Format("H1 * 4 = {0}, M15 = {1}", c3 * 4, c4));
                System.Console.WriteLine(string.Format("M15 * 3 = {0}, M5 = {1}", c4 * 3, c5));
            }
        }

        public static void BatchDb(Func<SqlCommand[]> funcDo, Func<bool> funcFinish)
        {
            int m = 0;
            try
            {
                int bufferCnt = 10000;
                int n = 0;
                //var txn = DbHelper.Instance.BeginTransaction();
                System.Data.Common.DbTransaction txn = null;
                SqlCommand[] cmdBuffers = new SqlCommand[bufferCnt];

                while (true)
                {
                    bool finish = false;
                    if (funcFinish())
                    {
                        finish = true;
                        //DbHelper.Instance.CommitTransaction(txn);
                        //break;
                    }
                    else
                    {
                        SqlCommand[] cmds = funcDo();
                        if (cmds == null)
                            continue;

                        for (int i = 0; i < cmds.Length; ++i)
                        {
                            if (cmds[i] == null)
                                continue;

                            cmdBuffers[n] = cmds[i];
                            if (txn == null)
                            {
                                txn = DbHelper.Instance.BeginTransaction();
                            }
                            cmds[i].Transaction = txn as SqlTransaction;
                            DbHelper.Instance.ExecuteNonQuery(cmds[i]);

                            n++;
                            m++;
                        }
                    }

                    if (n >= bufferCnt || finish)
                    {
                        if (txn == null)
                            break;

                        try
                        {
                            System.Console.WriteLine(" - " + m);
                            DbHelper.Instance.CommitTransaction(txn);
                        }
                        catch (Exception ex)
                        {
                            System.Console.WriteLine(ex.Message);
                            DbHelper.Instance.RollbackTransaction(txn);

                            while (true)
                            {
                                try
                                {
                                    txn = DbHelper.Instance.BeginTransaction();
                                    for (int i = 0; i < n; ++i)
                                    {
                                        cmdBuffers[i].Transaction = txn as SqlTransaction;
                                        DbHelper.Instance.ExecuteNonQuery(cmdBuffers[i]);
                                    }
                                    DbHelper.Instance.CommitTransaction(txn);
                                    System.Console.WriteLine(" ----- " + m);
                                    break;
                                }
                                catch (Exception)
                                {
                                    DbHelper.Instance.RollbackTransaction(txn);
                                }
                            }
                        }

                        //txn = DbHelper.Instance.BeginTransaction();
                        txn = null;

                        n = 0;
                    }
                    if (finish)
                        break;
                }
                //DbHelper.Instance.CommitTransaction(txn);
            }
            catch (Exception ex)
            {
                WekaUtils.Instance.WriteLog(ex.Message);
                throw;
            }
        }

        public static void DoAllSymbolPeriod(Action<string, string> action)
        {
            foreach (string symbol in Parameters.AllSymbolsFull)
            {
                foreach (string period in Parameters.AllPeriodsFull)
                {
                    action(symbol, period);
                }
            }
        }
    }
}
