using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace MLEA
{
    public interface IHpData
    {
        Tuple<int[, , ,], long[, ,]> GetHpData(DateTime date);
        void Clear();
    }

    public class HpDbData : IHpData
    {
        public HpDbData(string symbol)
        {
            m_symbol = symbol;
        }
        private string m_symbol;

        private SortedDictionary<long, Tuple<int[, , ,], long[, ,]>> m_buffer = new SortedDictionary<long, Tuple<int[, , ,], long[, ,]>>();
        public void Clear()
        {
            m_buffer.Clear();
        }
        public Tuple<int[, , ,], long[, ,]> GetHpData(DateTime date)
        {
            int n = m_buffer.Count - 5 * 15 * 20000;
            if (n > 0)
            {
                List<long> delete = new List<long>();
                foreach (var kvp in m_buffer)
                {
                    delete.Add(kvp.Key);
                    if (delete.Count >= n)
                        break;
                }
                foreach (var i in delete)
                {
                    m_buffer.Remove(i);
                }
            }

            Tuple<int[, , ,], long[, ,]> ret = null;
            long time = WekaUtils.GetTimeFromDate(date);
            if (!m_buffer.ContainsKey(time))
            {
                var sql = string.Format("SELECT * FROM {0}_HP WHERE TIME = {1}", m_symbol, time);
                var dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(sql);
                if (dt.Rows.Count > 0)
                {
                    ret = HpData.SumHp(dt.Select());
                }
                m_buffer[time] = ret;
            }
            
            return m_buffer[time];
        }
    }

    public class HpData : Feng.Singleton<HpData>, IHpData
    {
        public static Tuple<int[, , ,], long[, ,]> SumHp(System.Data.DataRow[] dt)
        {
            int n = TestParameters2.nTpsl;
            int m1 = TestParameters.TpMaxCount / n;
            int m2 = TestParameters.SlMaxCount / n;

            int[, , ,] hps = new int[2, m1, m2, 2];
            long[, ,] hpTimes = new long[2, m1, m2];
            for (int j = 0; j < hps.GetLength(0); ++j)
                for (int k = 0; k < hps.GetLength(1); ++k)
                    for (int l = 0; l < hps.GetLength(2); ++l)
                    {
                        hps[j, k, l, 0] = hps[j, k, l, 1] = -1;
                        hpTimes[j, k, l] = -1;
                    }

            foreach (System.Data.DataRow row in dt)
            {
                sbyte?[, ,] hp = HpData.DeserializeHp((byte[])row["hp"]);
                long?[, ,] hpTime = HpData.DeserializeHpTimes((byte[])row["hp_date"]);

                WekaUtils.DebugAssert(hp.GetLength(0) == 2, "");
                WekaUtils.DebugAssert(hp.GetLength(1) % m1 == 0, "");
                WekaUtils.DebugAssert(hp.GetLength(2) % m2 == 0, "");
                WekaUtils.DebugAssert(hpTime.GetLength(0) == 2, "");

                for (int j = 0; j < hp.GetLength(0); ++j)
                    for (int k = 0; k < hp.GetLength(1); ++k)
                        for (int l = 0; l < hp.GetLength(2); ++l)
                        {
                            if (k % n != n - 1 || l % n != n - 1)
                                continue;
                            if (!hp[j, k, l].HasValue || hp[j, k, l] == -1)
                                continue;

                            //if (k / n >= TestParameters2.tpCount)
                            //    continue;
                            //if (l / n >= TestParameters2.slCount)
                            //    continue;

                            if (hps[j, k / n, l / n, 0] == -1)
                                hps[j, k / n, l / n, 0] = 0;
                            if (hps[j, k / n, l / n, 1] == -1)
                                hps[j, k / n, l / n, 1] = 0;

                            if (hp[j, k, l] == 1)
                                hps[j, k / n, l / n, 0]++;
                            else if (hp[j, k, l] == 0)
                                hps[j, k / n, l / n, 1]++;
                            else
                                throw new AssertException("hp should be 0 or 1.");

                            hpTimes[j, k / n, l / n] = Math.Max(hpTimes[j, k / n, l / n], hpTime[j, k, l].Value);
                        }

            }
            return new Tuple<int[, , ,], long[, ,]>(hps, hpTimes);
        }

        public static byte[] SerializeHp(sbyte?[, ,] hps)
        {
            return Feng.Windows.Utils.SerializeHelper.Serialize(hps);
        }
        public static byte[] SerializeHpTimes(long?[, ,] hpTimes)
        {
            return Feng.Windows.Utils.SerializeHelper.Serialize(hpTimes);
        }

        public static sbyte?[, ,] DeserializeHp(byte[] p)
        {
            return Feng.Windows.Utils.SerializeHelper.Deserialize<sbyte?[, ,]>(p);
        }
        public static long?[, ,] DeserializeHpTimes(byte[] p)
        {
            return Feng.Windows.Utils.SerializeHelper.Deserialize<long?[, ,]>(p);
        }

        public static void IterateHpData(string symbol, string period, Action<DateTime, int, int, int, int, long> action)
        {
            double mainPeriodOfHour = WekaUtils.GetMinuteofPeriod(period) / 60.0;

            int n = TestParameters2.nTpsl;
            int m1 = TestParameters.TpMaxCount / n;
            int m2 = TestParameters.SlMaxCount / n;

            DateTime date = TestParameters2.TrainStartTime;
            DateTime maxDate = TestParameters2.TrainEndTime;

            string sql;
            System.Data.DataTable allDt = null;
            DateTime nextBufferDate = DateTime.MinValue;

            while (true)
            {
                if (!TestParameters2.RealTimeMode)
                {
                    Console.WriteLine(date.ToString(Parameters.DateTimeFormat));
                }
                if (date.DayOfWeek == DayOfWeek.Saturday || date.DayOfWeek == DayOfWeek.Sunday)
                {
                    date = date.AddHours(mainPeriodOfHour);
                    continue;
                }
                if (nextBufferDate <= date)
                {
                    nextBufferDate = date.AddHours(mainPeriodOfHour * 240);
                    sql = string.Format("SELECT * FROM {0}_HP WHERE TIME >= '{1}' AND TIME < '{2}' AND {3}",
                        symbol, WekaUtils.GetTimeFromDate(date), WekaUtils.GetTimeFromDate(nextBufferDate),
                        string.IsNullOrEmpty(TestParameters.DbSelectWhere) ? "1 = 1" : TestParameters.DbSelectWhere);
                    allDt = Feng.Data.DbHelper.Instance.ExecuteDataTable(sql);
                }

                DateTime nextDate = date.AddHours(mainPeriodOfHour);
                sql = string.Format("TIME >= '{1}' AND TIME < '{2}'",
                        symbol, WekaUtils.GetTimeFromDate(date), WekaUtils.GetTimeFromDate(nextDate));
                var dt = allDt.Select(sql);

                bool isComplete = true;

                foreach (System.Data.DataRow row in dt)
                {
                    bool b = (bool)row["IsComplete"];
                    if (!b)
                    {
                        isComplete = false;
                        break;
                    }
                }

                if ((TestParameters2.UsePartialHpData || isComplete) && dt.Length > 0)
                {
                    foreach (System.Data.DataRow row in dt)
                    {
                        sbyte?[, ,] hp = HpData.DeserializeHp((byte[])row["hp"]);
                        long?[, ,] hpTime = HpData.DeserializeHpTimes((byte[])row["hp_date"]);

                        WekaUtils.DebugAssert(hp.GetLength(0) == 2, "");
                        WekaUtils.DebugAssert(hp.GetLength(1) % m1 == 0, "");
                        WekaUtils.DebugAssert(hp.GetLength(2) % m2 == 0, "");
                        WekaUtils.DebugAssert(hpTime.GetLength(0) == 2, "");

                        for (int j = 0; j < hp.GetLength(0); ++j)
                            for (int k = 0; k < hp.GetLength(1); ++k)
                                for (int l = 0; l < hp.GetLength(2); ++l)
                                {
                                    if (k % n != n - 1 || l % n != n - 1)
                                        continue;
                                    if (!hp[j, k, l].HasValue || hp[j, k, l] == -1)
                                        continue;

                                    action(date, j, k, l, hp[j, k, l].Value, hpTime[j, k, l].Value);
                                }

                    }
                }
                date = nextDate;
                if (date >= maxDate)
                    break;
            }
        }
        

        //public void ConvertHpDataPeriod(string symbol, string periodSsrc, string periodDest)
        //{
        //    string hpFileName = TestParameters.GetBaseFilePath(string.Format("{0}_{1}_hpdata.txt", symbol, periodSsrc));
        //    var hpData = GetHpDateFromTxt(hpFileName, TestParameters2.nTpsl);

        //    string hpFileName2 = TestParameters.GetBaseFilePath(string.Format("{0}_{1}_hpdata.txt", symbol, periodDest));

        //    int m = TestParameters.TpSlMaxCount / TestParameters2.nTpsl;
        //    DateTime date = TestParameters2.TrainStartTime;
        //    DateTime maxDate = TestParameters2.TrainEndTime;
        //    using(StreamWriter sw = new StreamWriter(hpFileName2))
        //    {
        //        while (true)
        //        {
        //            if (!TestParameters2.RealTimeMode)
        //            {
        //                Console.WriteLine(date.ToString(Parameters.DateTimeFormat));
        //            }

        //            StringBuilder sb = new StringBuilder();
        //            {
        //                if (date.DayOfWeek == DayOfWeek.Saturday || date.DayOfWeek == DayOfWeek.Sunday)
        //                {
        //                    date = date.AddHours(mainPeriodOfHour);
        //                    continue;
        //                }
                        
        //                bool isComplete = true;

                        
        //                if ((TestParameters2.UsePartialHpData || isComplete))
        //                {
        //                    sb.Append(date.ToString(Parameters.DateTimeFormat));
        //                    sb.Append(", ");

        //                    int[, , ,] hps = new int[2, m, m, 2];
        //                    long[, ,] hpTimes = new long[2, m, m];
        //                    for (int j = 0; j < hps.GetLength(0); ++j)
        //                        for (int k = 0; k < hps.GetLength(1); ++k)
        //                            for (int l = 0; l < hps.GetLength(2); ++l)
        //                            {
        //                                hps[j, k, l, 0] = hps[j, k, l, 1] = -1;
        //                                hpTimes[j, k, l] = -1;
        //                            }

        //                    List<DateTime> dts = new List<DateTime>();
        //                    foreach (DateTime dt in dts)
        //                    {
        //                        if (!hpData.ContainsKey(dt))
        //                            continue;

        //                        sbyte?[, ,] hp = hpData[dt].Item1;
        //                        long[, ,] hpTime = hpData[dt].Item2;

        //                        WekaUtils.DebugAssert(hp.GetLength(0) == 2, "");
        //                        WekaUtils.DebugAssert(hp.GetLength(1) % m == 0, "");
        //                        WekaUtils.DebugAssert(hp.GetLength(2) % m == 0, "");
        //                        WekaUtils.DebugAssert(hpTime.GetLength(0) == 2, "");

        //                        for (int j = 0; j < hp.GetLength(0); ++j)
        //                            for (int k = 0; k < hp.GetLength(1); ++k)
        //                                for (int l = 0; l < hp.GetLength(2); ++l)
        //                                {
        //                                    if (k % n != n - 1 || l % n != n - 1)
        //                                        continue;
        //                                    if (!hp[j, k, l].HasValue || hp[j, k, l] == -1)
        //                                        continue;

        //                                    //if (k / n >= TestParameters2.tpCount)
        //                                    //    continue;
        //                                    //if (l / n >= TestParameters2.slCount)
        //                                    //    continue;

        //                                    if (hps[j, k / n, l / n, 0] == -1)
        //                                        hps[j, k / n, l / n, 0] = 0;
        //                                    if (hps[j, k / n, l / n, 1] == -1)
        //                                        hps[j, k / n, l / n, 1] = 0;

        //                                    if (hp[j, k, l] == 1)
        //                                        hps[j, k / n, l / n, 0]++;
        //                                    else if (hp[j, k, l] == 0)
        //                                        hps[j, k / n, l / n, 1]++;
        //                                    else
        //                                        throw new AssertException("hp should be 0 or 1.");

        //                                    hpTimes[j, k / n, l / n] = Math.Max(hpTimes[j, k / n, l / n], hpTime[j, k, l].Value);
        //                                }

        //                    }

        //                    for (int j = 0; j < hps.GetLength(0); ++j)
        //                        for (int k = 0; k < hps.GetLength(1); ++k)
        //                            for (int l = 0; l < hps.GetLength(2); ++l)
        //                            {
        //                                if (isComplete)
        //                                {
        //                                    if (hps[j, k, l, 0] == -1 || hps[j, k, l, 1] == -1)
        //                                    {
        //                                        throw new AssertException("hps should not be -1.");
        //                                    }
        //                                }
        //                                if (hps[j, k, l, 0] == -1)
        //                                    hps[j, k, l, 0] = 0;
        //                                if (hps[j, k, l, 1] == -1)
        //                                    hps[j, k, l, 1] = 0;
        //                                sb.Append(hps[j, k, l, 0] + ", " + hps[j, k, l, 1] + ", ");
        //                            }

        //                    long maxHpTime = 0;
        //                    for (int j = 0; j < hpTimes.GetLength(0); ++j)
        //                        for (int k = 0; k < hpTimes.GetLength(1); ++k)
        //                            for (int l = 0; l < hpTimes.GetLength(2); ++l)
        //                            {
        //                                if (isComplete)
        //                                {
        //                                    if (hpTimes[j, k, l] == -1)
        //                                    {
        //                                        throw new AssertException("hpTimes should not be -1.");
        //                                    }
        //                                }
        //                                if (hpTimes[j, k, l] == -1)
        //                                    hpTimes[j, k, l] = Parameters.MaxTime;
        //                                sb.Append(hpTimes[j, k, l] + ", ");
        //                                maxHpTime = Math.Max(hpTimes[j, k, l], maxHpTime);
        //                            }

        //                    sb.AppendLine();

        //                    sw.Write(sb.ToString());
        //                }
        //                DateTime nextDate = date.AddMinutes(WekaUtils.GetMinuteofPeriod(periodDest));

        //                date = nextDate;
        //                if (date >= maxDate)
        //                    break;
        //            }
        //        }
        //    }
        //}

        public static Dictionary<long, int> GetHpDateTimesCountFromInstance(string fileName)
        {
            Dictionary<long, int> dictTimes = new Dictionary<long, int>();
            int dealCount = 0;

            var instances = WekaUtils.LoadInstances(TestParameters.GetBaseFilePath(fileName));
            for (int i = 0; i < instances.numInstances(); ++i)
            {
                var date = WekaUtils.GetDateValueFromInstances(instances, 0, i);
                var hpdate = WekaUtils.GetDateValueFromInstances(instances, 1, i);

                
                var hptime = WekaUtils.GetTimeFromDate(hpdate);
                if (dictTimes.ContainsKey(hptime))
                {
                    dictTimes[hptime]++;
                }
                else
                {
                    dictTimes[hptime] = 1;
                }
                dealCount++;

                Console.WriteLine(date.ToString(Parameters.DateTimeFormat) + ", " + dictTimes.Count + ", " + dealCount);

            }
            return dictTimes;
        }

        public static Dictionary<long, int> GetHpDateTimesCount(string symbol, string period)
        {
            double mainPeriodOfHour = WekaUtils.GetMinuteofPeriod(period) / 60.0;

            Dictionary<long, int> dictTimes = new Dictionary<long, int>();
            int dealCount = 0;

            int n = TestParameters2.nTpsl;

            DateTime date = TestParameters2.TrainStartTime;
            DateTime maxDate = TestParameters2.TrainEndTime;

            string sql;
            System.Data.DataTable allDt = null;
            DateTime nextBufferDate = DateTime.MinValue;

            while (true)
            {
                Console.WriteLine(date.ToString(Parameters.DateTimeFormat) + ", " + dictTimes.Count + ", " + dealCount);

                if (date.DayOfWeek == DayOfWeek.Saturday || date.DayOfWeek == DayOfWeek.Sunday)
                {
                    date = date.AddHours(mainPeriodOfHour);
                    continue;
                }
                if (nextBufferDate <= date)
                {
                    nextBufferDate = date.AddHours(mainPeriodOfHour * 100);
                    sql = string.Format("SELECT * FROM {0}_HP WHERE TIME >= '{1}' AND TIME < '{2}' AND {3}",
                        symbol, WekaUtils.GetTimeFromDate(date), WekaUtils.GetTimeFromDate(nextBufferDate),
                        string.IsNullOrEmpty(TestParameters.DbSelectWhere) ? "1 = 1" : TestParameters.DbSelectWhere);
                    allDt = Feng.Data.DbHelper.Instance.ExecuteDataTable(sql);
                }

                DateTime nextDate = date.AddHours(mainPeriodOfHour);
                sql = string.Format("TIME >= '{1}' AND TIME < '{2}'",
                        symbol, WekaUtils.GetTimeFromDate(date), WekaUtils.GetTimeFromDate(nextDate));
                var dt = allDt.Select(sql);

                bool isComplete = true;

                if ((TestParameters2.UsePartialHpData || isComplete) && dt.Length > 0)
                {
                    foreach (System.Data.DataRow row in dt)
                    {
                        sbyte?[, ,] hp = HpData.DeserializeHp((byte[])row["hp"]);
                        long?[, ,] hpTime = HpData.DeserializeHpTimes((byte[])row["hp_date"]);

                        WekaUtils.DebugAssert(hp.GetLength(0) == 2, "");
                        WekaUtils.DebugAssert(hpTime.GetLength(0) == 2, "");

                        for (int j = 0; j < hp.GetLength(0); ++j)
                            for (int k = 0; k < hp.GetLength(1); ++k)
                                for (int l = 0; l < hp.GetLength(2); ++l)
                                {
                                    if (k % n != n - 1 || l % n != n - 1)
                                        continue;
                                    if (!hp[j, k, l].HasValue || hp[j, k, l] == -1)
                                        continue;

                                    //if (k / n >= TestParameters2.tpCount)
                                    //    continue;
                                    //if (l / n >= TestParameters2.slCount)
                                    //    continue;

                                    if (dictTimes.ContainsKey(hpTime[j, k, l].Value))
                                    {
                                        dictTimes[hpTime[j, k, l].Value]++;
                                    }
                                    else
                                    {
                                        dictTimes[hpTime[j, k, l].Value] = 1;
                                    }
                                    dealCount++;
                                }

                    }

                }
                date = nextDate;
                if (date >= maxDate)
                    break;
            }

            return dictTimes;
        }


        public void GenerateHpDataToTxt(string symbol, string period)
        {
            double mainPeriodOfHour = WekaUtils.GetMinuteofPeriod(period) / 60.0;

            int n = TestParameters2.nTpsl;
            int m1 = TestParameters.TpMaxCount / n;
            int m2 = TestParameters.SlMaxCount / n;

            var dataDates = TestManager.GetDataDateRange();
            DateTime date = dataDates[0];
            DateTime maxDate = dataDates[1];

            date = new DateTime(2000, 1, 1);

            string hpFileName = TestParameters.GetBaseFilePath(string.Format("{0}_{1}_hpdata.txt", symbol, period));
            if (!TestParameters2.RealTimeMode && System.IO.File.Exists(hpFileName))
                return;

            SortedDictionary<DateTime, string> dictAlready = new SortedDictionary<DateTime, string>();
            string hpFileNameAlready = hpFileName + ".full";
            if (!TestParameters2.DBDataConsistent)
            {
                if (System.IO.File.Exists(hpFileNameAlready))
                {
                    using (StreamReader sr = new StreamReader(hpFileNameAlready))
                    {
                        while (!sr.EndOfStream)
                        {
                            string s = sr.ReadLine();
                            int idx = s.IndexOf(',');
                            DateTime d = Convert.ToDateTime(s.Substring(0, idx));
                            string s2 = s.Substring(idx + 1);
                            dictAlready[d] = s2.Trim();
                        }
                    }
                }
            }

            string sql;
            System.Data.DataTable allDt = null;
            DateTime nextBufferDate = DateTime.MinValue;
            using (StreamWriter sw = new StreamWriter(hpFileName))
            using (StreamWriter sw2 = new StreamWriter(hpFileNameAlready))
            {
                while (true)
                {
                    if (!TestParameters2.RealTimeMode)
                    {
                        Console.WriteLine(date.ToString(Parameters.DateTimeFormat));
                    }

                    StringBuilder sb = new StringBuilder();
                    if (dictAlready.ContainsKey(date))
                    {
                        sb.Append(date.ToString(Parameters.DateTimeFormat));
                        sb.Append(", ");
                        sb.AppendLine(dictAlready[date]);

                        sw.Write(sb.ToString());
                        sw2.Write(sb.ToString());

                        date = date.AddHours(mainPeriodOfHour);
                        if (date >= maxDate)
                            break;
                    }
                    else
                    {
                        if (date.DayOfWeek == DayOfWeek.Saturday || date.DayOfWeek == DayOfWeek.Sunday)
                        {
                            date = date.AddHours(mainPeriodOfHour);
                            continue;
                        }
                        if (nextBufferDate <= date)
                        {
                            nextBufferDate = date.AddHours(mainPeriodOfHour);
                            sql = string.Format("SELECT * FROM {0}_HP WHERE TIME >= '{1}' AND TIME < '{2}' AND {3}",
                                symbol, WekaUtils.GetTimeFromDate(date), WekaUtils.GetTimeFromDate(nextBufferDate),
                                string.IsNullOrEmpty(TestParameters.DbSelectWhere) ? "1 = 1" : TestParameters.DbSelectWhere);
                            //if (!TestParameters2.UsePartialHpData && TestParameters2.RealTimeMode)
                            //{
                            //    sql += " AND IsComplete = 1";
                            //}
                            allDt = Feng.Data.DbHelper.Instance.ExecuteDataTable(sql);
                        }

                        DateTime nextDate = date.AddHours(mainPeriodOfHour);
                        sql = string.Format("TIME >= '{1}' AND TIME < '{2}'",
                                symbol, WekaUtils.GetTimeFromDate(date), WekaUtils.GetTimeFromDate(nextDate));
                        var dt = allDt.Select(sql);

                        bool isComplete = true;
                        
                        foreach (System.Data.DataRow row in dt)
                        {
                            bool b = (bool)row["IsComplete"];
                            if (!b)
                            {
                                isComplete = false;
                                break;
                            }
                        }
                        
                        if ((TestParameters2.UsePartialHpData || isComplete) && dt.Length > 0)
                        {
                            sb.Append(date.ToString(Parameters.DateTimeFormat));
                            sb.Append(", ");

                            var hpAll = SumHp(dt);
                            var hps = hpAll.Item1;
                            var hpTimes = hpAll.Item2;

                            for (int j = 0; j < hps.GetLength(0); ++j)
                                for (int k = 0; k < hps.GetLength(1); ++k)
                                    for (int l = 0; l < hps.GetLength(2); ++l)
                                    {
                                        if (isComplete)
                                        {
                                            if (hps[j, k, l, 0] == -1 || hps[j, k, l, 1] == -1)
                                            {
                                                throw new AssertException("hps should not be -1.");
                                            }
                                        }
                                        if (hps[j, k, l, 0] == -1)
                                            hps[j, k, l, 0] = 0;
                                        if (hps[j, k, l, 1] == -1)
                                            hps[j, k, l, 1] = 0;
                                        sb.Append(hps[j, k, l, 0] + ", " + hps[j, k, l, 1] + ", ");
                                    }

                            long maxHpTime = 0;
                            for (int j = 0; j < hpTimes.GetLength(0); ++j)
                                for (int k = 0; k < hpTimes.GetLength(1); ++k)
                                    for (int l = 0; l < hpTimes.GetLength(2); ++l)
                                    {
                                        if (isComplete)
                                        {
                                            if (hpTimes[j, k, l] == -1)
                                            {
                                                throw new AssertException("hpTimes should not be -1.");
                                            }
                                        }
                                        if (hpTimes[j, k, l] == -1)
                                            hpTimes[j, k, l] = Parameters.MaxTime;
                                        sb.Append(hpTimes[j, k, l] + ", ");
                                        maxHpTime = Math.Max(hpTimes[j, k, l], maxHpTime);
                                    }

                            sb.AppendLine();

                            sw.Write(sb.ToString());
                            if (isComplete && !TestParameters2.DBDataConsistent)
                            {
                                sw2.Write(sb.ToString());
                            }
                        }
                        date = nextDate;
                        if (date >= maxDate)
                            break;
                    }
                }
            }

            if (TestParameters2.DBDataConsistent)
            {
                File.Delete(hpFileNameAlready);
            }
        }

        IHpData m_hpDataDb;
        public Tuple<int, long> GetHpSumByM1(string symbol, string period, long nowTime, long getTime)
        {
            System.Diagnostics.Debug.Assert(getTime != -1, "");

            Tuple<int, long> ret = new Tuple<int, long>(0, 0);

            if (m_hpDataDb == null)
            {
                m_hpDataDb = new HpDbData(symbol);
            }

            long time = getTime - 60;

            long hpdate = 0;
            double[] sum = new double[2];
            sum[0] = sum[1] = 0;
            while(true)
            {
                time += 60;

                if (time >= getTime + 60 * WekaUtils.GetMinuteofPeriod(period))
                    break;

                System.Diagnostics.Debug.Assert(time < nowTime, "");
                var hps = m_hpDataDb.GetHpData(WekaUtils.GetDateFromTime(time));
                if (hps == null)
                    continue;

                for (int k = 0; k < 2; ++k)
                {
                    for (int tp = TestParameters2.tpStart; tp < TestParameters2.tpCount; ++tp)
                    {
                        for (int sl = TestParameters2.slStart; sl < TestParameters2.slCount; ++sl)
                        {
                            var hpItem10 = hps.Item1[k, tp, sl, 0];
                            var hpItem11 = hps.Item1[k, tp, sl, 1];
                            var hpItem2 = hps.Item2[k, tp, sl];
                            WekaUtils.DebugAssert(hpItem10 >= 0, "hp data should >= 0");
                            WekaUtils.DebugAssert(hpItem11 >= 0, "hp data should >= 0");
                            WekaUtils.DebugAssert(hpItem2 >= 0, "hp data should >= 0");

                            // 当用PartialData模式的，还未知道的数据
                            if (hpItem2 == Parameters.MaxTime)
                                continue;

                            if (hpItem2 > nowTime)
                                continue;

                            int tpp = 1;
                            int tp1 = tpp * (tp + 1);
                            int sl1 = tpp * (sl + 1);

                            int v = 1;
                            //v = 600 / (sl + 1);

                            sum[k] -= tp1 * v * hpItem10;
                            sum[k] += sl1 * v * hpItem11;

                            hpdate = Math.Max(hpdate, hpItem2);
                        }
                    }
                }
            }

            int hpSum = 2;

            bool useOneClass = false;
            if (useOneClass)
            {
                if (sum[0] < 0)
                    hpSum = 0;
            }
            else
            {
                bool enableMultiClass = true;
                if (enableMultiClass)
                {
                    if (sum[0] < 0 && sum[1] >= 0)
                        hpSum = 0;
                    else if (sum[1] < 0 && sum[0] >= 0)
                        hpSum = 1;
                    else if (sum[0] >= 0 && sum[1] >= 0)
                        hpSum = 2;
                    else
                        hpSum = 3;
                }
                else
                {
                    double delta = 0 * (TestParameters2.tpCount - TestParameters2.tpStart);
                    if (sum[0] < sum[1] - delta)
                        hpSum = 0;
                    else if (sum[0] > sum[1] + delta)
                        hpSum = 1;
                }
            }

            ret = new Tuple<int, long>(hpSum, hpdate);

            return ret;
        }

        public Dictionary<DateTime, Tuple<int, long>> GetHpSum(string symbol, string period)
        {
            return GetHpSum(symbol, period, Parameters.MaxTime, -1);
        }
        public Dictionary<DateTime, Tuple<int, long>> GetHpSum(string symbol, string period, long nowTime, long getTime)
        {
            Dictionary<DateTime, Tuple<int, long>> ret = new Dictionary<DateTime, Tuple<int, long>>();

            Dictionary<DateTime, Tuple<int[, , ,], long[, ,]>> hpData;
            hpData = GetHpDataFromTxt(symbol, period);

            int preHpSum = 2;
            foreach (var kvp in hpData)
            {
                DateTime nowDate = kvp.Key;

                var retKey = kvp.Key.AddHours(TestParameters2.HourAhead);
                if (getTime != -1)
                {
                    if (WekaUtils.GetTimeFromDate(retKey) < getTime)
                        continue;
                    else if (WekaUtils.GetTimeFromDate(retKey) > getTime)
                        break;
                }
                var hps = kvp.Value;

                long hpdate = 0;
                double[] sum = new double[2];
                sum[0] = sum[1] = 0;
                for (int k = 0; k < 2; ++k)
                {
                    for (int tp = TestParameters2.tpStart; tp < TestParameters2.tpCount; ++tp)
                    {
                        for (int sl = TestParameters2.slStart; sl < TestParameters2.slCount; ++sl)
                        {
                            var hpItem10 = hps.Item1[k, tp, sl, 0];
                            var hpItem11 = hps.Item1[k, tp, sl, 1];
                            var hpItem2 = hps.Item2[k, tp, sl];
                            WekaUtils.DebugAssert(hpItem10 >= 0, "hp data should >= 0");
                            WekaUtils.DebugAssert(hpItem11 >= 0, "hp data should >= 0");
                            WekaUtils.DebugAssert(hpItem2 >= 0, "hp data should >= 0");

                            // 当用PartialData模式的，还未知道的数据
                            if (hpItem2 == Parameters.MaxTime)
                                continue;

                            if (hpItem2 > nowTime)
                                continue;

                            int tpp = 1;
                            int tp1 = tpp * (tp + 1);
                            int sl1 = tpp * (sl + 1);

                            int v = 1;
                            //v = 600 / (sl + 1);

                            sum[k] -= tp1 * v * hpItem10;
                            sum[k] += sl1 * v * hpItem11;

                            hpdate = Math.Max(hpdate, hpItem2);

                            //System.Console.WriteLine(string.Format("{0},{1},{2},{3},{4}", k, tp1, sl1, hps.Item1[k, tp, sl, 0], hps.Item1[k, tp, sl, 1]));
                        }
                    }
                }

                //var dt = Feng.Data.DbHelper.Instance.ExecuteDataTable("SELECT * FROM GBPUSD_HP WHERE TIME >= '" + WekaUtils.GetTimeFromDate(kvp.Key) + "' AND TIME < '" + WekaUtils.GetTimeFromDate(kvp.Key.AddHours(1)) + "'");
                //var row = dt.Rows[0];
                //sbyte?[, ,] hp = WekaUtils.DeserializeHp((byte[])row["hp"]);
                //long?[, ,] hpTime = WekaUtils.DeserializeHpTimes((byte[])row["hp_date"]);

                int hpSum = 2;

                //if (nowDate >= new DateTime(2010, 4, 12, 0, 30, 0))
                //{
                //}

                bool useOneClass = false;
                if (useOneClass)
                {
                    if (sum[0] < 0)
                        hpSum = 0;
                }
                else
                {
                    bool enableMultiClass = true;
                    if (enableMultiClass)
                    {
                        if (sum[0] < 0 && sum[1] >= 0)
                            hpSum = 0;
                        else if (sum[1] < 0 && sum[0] >= 0)
                            hpSum = 1;
                        else if (sum[0] >= 0 && sum[1] >= 0)
                            hpSum = 2;
                        else  // <0, <0
                            hpSum = 3;

                        preHpSum = hpSum;
                    }
                    else
                    {
                        double delta = 0 * (TestParameters2.tpCount - TestParameters2.tpStart);
                        if (sum[0] < sum[1] - delta)
                            hpSum = 0;
                        else if (sum[0] > sum[1] + delta)
                            hpSum = 1;

                        if (hpSum == 2)
                            hpSum = preHpSum;
                        preHpSum = hpSum;
                        if (hpSum == -1)
                            continue;
                    }
                }
                
                if (hpdate == 0)
                    continue;

                ret[retKey] = new Tuple<int, long>(hpSum, hpdate);
            }

            return ret;
        }

        public Dictionary<string, Dictionary<DateTime, Tuple<int[, , ,], long[, ,]>>> m_hpBuffer = new Dictionary<string, Dictionary<DateTime, Tuple<int[, , ,], long[, ,]>>>();
        //private int tpStart, slStart, tpCount, slCount;

        public void Clear()
        {
            m_hpBuffer.Clear();
            if (m_hpDataDb != null)
            {
                m_hpDataDb.Clear();
            }
        }
        public Tuple<int[, , ,], long[, ,]> GetHpData(DateTime date)
        {
            int n = TestParameters2.nTpsl;
            int m1 = TestParameters.TpMaxCount / n;
            int m2 = TestParameters.SlMaxCount / n;
            lock (this)
            {
                string bufferKey = TestParameters2.CandidateParameter.MainSymbol + "." + TestParameters2.CandidateParameter.MainPeriod + "." + TestParameters2.nTpsl;
                if (m_hpBuffer.ContainsKey(bufferKey))
                {
                    if (m_hpBuffer[bufferKey].ContainsKey(date))
                        return m_hpBuffer[bufferKey][date];
                }
            }
            return null;
        }
        public Dictionary<DateTime, Tuple<int[, , ,], long[, ,]>> GetHpDataFromTxt(string symbol, string period)
        {
            string hpFile = TestParameters.GetBaseFilePath(string.Format("{0}_{1}_hpdata.txt", symbol, period));

            int n = TestParameters2.nTpsl;
            int m1 = TestParameters.TpMaxCount / n;
            int m2 = TestParameters.SlMaxCount / n;
            lock (this)
            {
                string bufferKey = symbol + "." + period + "." + TestParameters2.nTpsl;
                if (m_hpBuffer.ContainsKey(bufferKey))
                    return m_hpBuffer[bufferKey];
                Dictionary<DateTime, Tuple<int[, , ,], long[, ,]>> ret;

                string serializeFile = hpFile + ".serialize";
                if (false && File.Exists(serializeFile))
                {
                    ret = Feng.Windows.Utils.SerializeHelper.Deserialize<Dictionary<DateTime, Tuple<int[, , ,], long[, ,]>>>(serializeFile);
                }
                else
                {
                    DateTime lastWriteDate = DateTime.MinValue;
                    ret = new Dictionary<DateTime, Tuple<int[, , ,], long[, ,]>>();
                    using (StreamReader sr = new StreamReader(hpFile))
                    {
                        while (true)
                        {
                            if (sr.EndOfStream)
                                break;
                            string s = sr.ReadLine().Trim();
                            string[] ss = s.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

                            int ssLength = 1 + 2 * m1 * m2 * 2 + 2 * m1 * m2;
                            if (ss.Length != ssLength && sr.EndOfStream)
                                break;
                            WekaUtils.DebugAssert(ss.Length == ssLength, string.Format("HpData LineLength should be {0}, but is {1}", ssLength, ss.Length));

                            DateTime nowDate = Convert.ToDateTime(ss[0]);


                            if (nowDate.Day == 1 && (nowDate - lastWriteDate).Days > 1)
                            {
                                System.Console.WriteLine("Read HpData at {0}", nowDate.ToString());
                                lastWriteDate = nowDate;
                            }
                            if (nowDate < TestParameters2.TrainStartTime.AddMinutes(-(TestParameters2.MinTrainPeriod + 500) * WekaUtils.GetMinuteofPeriod(TestParameters2.CandidateParameter.MainPeriod)))
                                continue;
                            if (nowDate > TestParameters2.TrainEndTime)
                                break;

                            int nn = 1;
                            int[, , ,] hps = new int[2, m1, m2, 2];
                            for (int i = 0; i < hps.GetLength(0); ++i)
                                for (int j = 0; j < hps.GetLength(1); ++j)
                                    for (int k = 0; k < hps.GetLength(2); ++k)
                                        for (int l = 0; l < 2; ++l)
                                        {
                                            hps[i, j, k, l] = Convert.ToInt32(ss[nn]);
                                            nn++;
                                        }

                            long[, ,] hpTimes = new long[2, m1, m2];
                            for (int i = 0; i < hpTimes.GetLength(0); ++i)
                                for (int j = 0; j < hpTimes.GetLength(1); ++j)
                                    for (int k = 0; k < hpTimes.GetLength(2); ++k)
                                    {
                                        hpTimes[i, j, k] = Convert.ToInt64(ss[nn]);
                                        nn++;
                                    }


                            ret[nowDate] = new Tuple<int[, , ,], long[, ,]>(hps, hpTimes);
                        }
                    }

                    //Feng.Utils.SerializeHelper.Serialize(serializeFile, ret);
                }

                m_hpBuffer[bufferKey] = ret;
                return ret;
            }
        }
    }
}
