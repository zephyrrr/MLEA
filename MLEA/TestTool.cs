using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Data.SqlClient;
using System.Linq;
using weka.core;
using Feng.Data;

namespace MLEA
{
    public class TestTool : WekaData
    {
        public TestTool()
            : base('B', 20, 20, null)
        {
        }

        public static void Test3()
        {
            var d = new SortedDictionary<DateTime, int[,]>();
            List<int> ms = new List<int>();
            List<int> ns = new List<int>();
            foreach (var file in System.IO.Directory.GetFiles("F:\\Forex\\Test_EURUSD", "IncrementTest2_EURUSD_HpProb_M15_*_*.txt"))
            {
                var t = Path.GetFileNameWithoutExtension(file).Replace("IncrementTest2_EURUSD_HpProb_M15_", "");
                string[] tt = t.Split('_');
                int m = Convert.ToInt32(tt[0]);
                int n = Convert.ToInt32(tt[1]);
                ms.Add(m);
                ns.Add(n);
                using (StreamReader sr = new StreamReader(file))
                {
                    while (!sr.EndOfStream)
                    {
                        string s = sr.ReadLine();
                        string[] ss = s.Split(',');
                        if (ss.Length != 6)
                            continue;
                        var date = Convert.ToDateTime(ss[0]);
                        if (!d.ContainsKey(date))
                        {
                            d[date] = new int[20, 20];
                            for (int i = 0; i < 20; ++i)
                                for (int j = 0; j < 20; ++j)
                                    d[date][i, j] = -1;
                        }
                        d[date][m, n] = Convert.ToInt32(ss[1]);
                    }
                }
            }

            //foreach (var kvp in d)
            //    foreach(var m in ms)
            //        foreach (var n in ns)
            //        {
            //            if (kvp.Value[m, n] == -1)
            //            {
            //                kvp.Value[m, n] = 2;
            //            }
            //        }

            int[,] last = new int[20, 20];
            for (int i = 0; i < 20; ++i)
                for (int j = 0; j < 20; ++j)
                    last[i, j] = -1;
            using (StreamWriter sw = new StreamWriter("d:\\a.csv"))
            {
                foreach (var kvp in d)
                {
                    sw.Write(kvp.Key.ToString(Parameters.DateTimeFormat));
                    sw.Write(",");
                    for (int i = 0; i < 20; ++i)
                        for (int j = 0; j < 20; ++j)
                        {
                            //if (kvp.Value[i, j] != -1)
                            //{
                            //    sw.Write(kvp.Value[i, j] + ",");
                            //}
                            if (kvp.Value[i, j] != -1)
                            {
                                last[i, j] = kvp.Value[i, j];
                            }
                            if (last[i, j] != -1)
                            {
                                sw.Write(last[i, j] + ",");
                            }
                        }
                    sw.WriteLine();
                }
            }
        }
        public static void Test1()
        {
            int x, y, z, w;
            int dx, dy, dz, dw;
            int nx, ny, nz, nw;
            x = -1; y = -1; z = -1; w = -1;
            int tp = 0, fp = 0;
            using(StreamReader sr = new StreamReader("d:\\p.txt"))
            {
                while (!sr.EndOfStream)
                {
                    string s = sr.ReadLine();
                    string[] ss = s.Split(',');
                    nx = Convert.ToInt32(ss[0]);
                    ny = Convert.ToInt32(ss[1]);
                    nz = Convert.ToInt32(ss[2]);
                    nw = Convert.ToInt32(ss[3]);
                    if (x != -1)
                    {
                        dx = nx - x;
                        dy = ny - y;
                        dz = nz - z;
                        dw = nw - w;

                        int v = 2;
                        if (dx > dy)
                            v = 0;
                        else if (dy > dx)
                            v = 1;

                        //if (Math.Abs(nx - ny) < 5 || nz > 10)
                        //    v = 2;

                        if (Math.Abs(dx) < 6 || Math.Abs(dy) < 6)
                            v = 2;

                        int d = Convert.ToInt32(ss[4]);
                        if (v == 0 || v == 1)
                        {
                            if (v == d)
                                tp++;
                            else
                                fp++;
                        }
                    }

                    x = nx;
                    y = ny;
                    z = nz;
                    w = nw;
                }
            }
        }
        public static double[,] ParseTotalResult(string fileName, string destFileName, bool useFactor = false)
        {
            //for (int m = 2; m < 3; ++m)
            {
                int m = 2;
                int n = 0;

                double[,] totalProfit = new double[20, 20];
                double[,] profitFactor = new double[20, 20];
                double[,] maxDropdown = new double[20, 20];
                
                for(int i0=0; i0<20; ++i0)
                    for (int j0 = 0; j0 < 20; ++j0)
                    {
                        totalProfit[i0, j0] = -1;
                    }
                int i = 0, j = 0;
                using (StreamReader sr = new StreamReader(fileName))
                {
                    while (!sr.EndOfStream)
                    {
                        string s = sr.ReadLine().Trim();
                        if (string.IsNullOrEmpty(s))
                            continue;
                        if (s.Contains("select"))
                            continue;
                        else if (s.Contains("tn="))
                            continue;
                        else if (s.Contains("TotalProfit"))
                        {
                            totalProfit[i, j] = Convert.ToDouble(WekaUtils.GetSubstring(s, "TotalProfit ="));
                            profitFactor[i, j] = Convert.ToDouble(WekaUtils.GetSubstring(s, "ProfitFactor ="));
                            maxDropdown[i, j] = Convert.ToDouble(WekaUtils.GetSubstring(s, "MaxDrawdown ="));
                        }
                        else
                        {
                            string[] ss = s.Split(new char[] { ',', ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries);
                            if (ss.Length == 4)
                            {
                                i = Convert.ToInt32(ss[0]);
                                System.Diagnostics.Debug.Assert(i + 1 == Convert.ToInt32(ss[1]));
                                j = Convert.ToInt32(ss[2]);
                                System.Diagnostics.Debug.Assert(j + 1 == Convert.ToInt32(ss[3]));

                                if (i == 0 && j == 0)
                                {
                                    n++;
                                }
                                if (n >= m)
                                    break;

                                totalProfit[i, j] = 0;
                            }
                            else if (ss.Length >= 15)
                            {
                            }
                            else
                            {
                                throw new ArgumentException("");
                            }
                        }
                    }
                }

                if (useFactor)
                {
                    for (i = 0; i < totalProfit.GetLength(0); ++i)
                    {
                        for (j = 0; j < totalProfit.GetLength(1); ++j)
                        {
                            if (totalProfit[i, j] != -1)
                            {
                                totalProfit[i, j] /= Math.Max(i + 1, j + 1);
                            }
                        }
                    }
                }

                if (!string.IsNullOrEmpty(destFileName))
                {
                    using (StreamWriter sw = new StreamWriter(string.Format("{0}.csv", destFileName)))
                    {
                        for (i = 0; i < totalProfit.GetLength(0); ++i)
                        {
                            for (j = 0; j < totalProfit.GetLength(1); ++j)
                            {
                                //if (j % 2 == 0)
                                //    continue;

                                if (j > 0)
                                    sw.Write(",");
                                sw.Write((totalProfit[i, j] == -1 ? 0 : totalProfit[i, j]).ToString("F1"));
                            }
                            sw.WriteLine();
                        }

                        sw.WriteLine();
                        for (i = 0; i < profitFactor.GetLength(0); ++i)
                        {
                            for (j = 0; j < profitFactor.GetLength(1); ++j)
                            {
                                //if (j % 2 == 0)
                                //    continue;
                                if (j > 0)
                                    sw.Write(",");
                                sw.Write(profitFactor[i, j].ToString("F2"));
                            }

                            sw.WriteLine();
                        }
                        sw.WriteLine();

                        for (i = 0; i < totalProfit.GetLength(0); ++i)
                        {
                            for (j = 0; j < totalProfit.GetLength(1); ++j)
                            {
                                //if (j % 2 == 0)
                                //    continue;

                                if (j > 0)
                                    sw.Write(",");
                                if (totalProfit[i, j] == 0 || totalProfit[i, j] == -1)
                                    sw.Write("0");
                                else
                                    sw.Write((totalProfit[i, j] / maxDropdown[i, j]).ToString("F2"));
                            }
                            sw.WriteLine();
                        }
                    }
                }
                return totalProfit;
            }
        }
        public static void CheckMtData(string tableName)
        {
            long startTime = WekaUtils.GetTimeFromDate(new DateTime(2008, 1, 1));
            long endTime = 0;
            while (endTime < WekaUtils.GetTimeFromDate(new DateTime(2013, 1, 1)))
            {
                endTime = startTime + 60 * 60 * 24 * 7;
                var dt2 = Feng.Data.DbHelper.Instance.ExecuteDataTable(string.Format("SELECT * FROM Forex.dbo.{0} WHERE TIME >= {1} AND TIME < {2} ORDER BY TIME", tableName, startTime, endTime));
                var dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(string.Format("SELECT * FROM Forex_MT.dbo.{0} WHERE TIME >= {1} AND TIME < {2} ORDER BY TIME", tableName, startTime, endTime));
                if (dt.Rows.Count == 0)
                    continue;
                if (dt.Rows.Count != dt2.Rows.Count)
                {
                    System.Console.WriteLine("count is not equal." + (dt2.Rows.Count - dt.Rows.Count).ToString());
                    //startTime = endTime;
                    //continue;
                }

                for (int i = 0; i < dt2.Rows.Count; ++i)
                {
                    var row = dt2.Rows[i];
                    long time2 = (long)row["Time"];

                    int idx = i;
                    if (dt.Rows.Count != dt2.Rows.Count)
                    {
                        idx = -1;
                        for (int i2 = 0; i2 < dt.Rows.Count; ++i2)
                        {
                            long time = (long)dt.Rows[i2]["Time"];
                            if (time == time2)
                            {
                                idx = i2;
                                break;
                            }
                        }
                        if (idx == -1)
                        {
                            System.Console.WriteLine(string.Format("{0} is idx = -1", WekaUtils.GetDateFromTime(time2)));
                            startTime = endTime;
                            continue;
                        }
                    }

                    for (int j = 0; j < dt2.Columns.Count; ++j)
                    {
                        //if (!TestParameters2.CandidateParameter.AllIndNames2.Keys.Contains<string>(dt2.Columns[j].ColumnName))
                        //    continue;

                        if (dt2.Rows[i][j] is double)
                        {
                            if (Math.Abs((double)dt2.Rows[i][j] - (double)dt.Rows[idx][j]) > 0.001)
                            {
                                System.Console.WriteLine(string.Format("{0} {1}, {2} is not equal.", WekaUtils.GetDateFromTime(time2), dt2.Columns[j].ColumnName, dt.Columns[j].ColumnName));
                                //throw new AssertException("Mt Data is not equal.");
                            }
                        }
                        else if (dt2.Rows[i][j].ToString() != dt.Rows[idx][j].ToString())
                        {
                            System.Console.WriteLine(string.Format("{0} {1}, {2}  is not equal.", WekaUtils.GetDateFromTime(time2), dt2.Columns[j].ColumnName, dt.Columns[j].ColumnName));
                            //throw new AssertException("Mt Data is not equal.");
                        }
                    }
                }
                System.Console.WriteLine(string.Format("{0} is ok", WekaUtils.GetDateFromTime(startTime)));
                startTime = endTime;
            }
        }
        public static void CheckMtHpData(string symbol = "EURUSD")
        {
            Dictionary<long, int> diffHpTimes = new Dictionary<long, int>();

            int mode = 1;
            long startTime = WekaUtils.GetTimeFromDate(new DateTime(2002, 6, 1, 0, 0, 0));
            long endTime = 0;
            while (endTime < WekaUtils.GetTimeFromDate(new DateTime(2013, 1, 1)))
            {
                endTime = startTime + 60 * 60 * 24 * 7;
                var dt2 = Feng.Data.DbHelper.Instance.ExecuteDataTable(string.Format("SELECT * FROM Forex_MT.dbo.{0}_HP WHERE TIME >= {1} AND TIME < {2} ORDER BY TIME", symbol, startTime, endTime));
                var dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(string.Format("SELECT * FROM Forex.dbo.{0}_HP WHERE TIME >= {1}  AND TIME < {2} ORDER BY TIME", symbol, startTime, endTime));
                if (dt.Rows.Count != dt2.Rows.Count)
                {
                    System.Console.WriteLine("count is not equal.");
                }
                for (int i = 0; i < dt2.Rows.Count; ++i)
                {
                    var row2 = dt2.Rows[i];
                    long time2 = (long)row2["Time"];
                    bool isComplete = (bool)row2["IsComplete"];

                    sbyte?[, ,] hps2 = HpData.DeserializeHp((byte[])row2["hp"]);
                    long?[, ,] hpTimes2 = HpData.DeserializeHpTimes((byte[])row2["hp_date"]);

                    int idx = i;
                    if (dt.Rows.Count != dt2.Rows.Count)
                    {
                        idx = -1;
                        for (int i2 = 0; i2 < dt.Rows.Count; ++i2)
                        {
                            long t = (long)dt.Rows[i2]["Time"];
                            if (t == time2)
                            {
                                idx = i2;
                                break;
                            }
                        }
                        if (idx == -1)
                        {
                            System.Console.WriteLine(string.Format("{0} is idx = -1", WekaUtils.GetDateFromTime(time2)));
                            startTime = endTime;
                            continue;
                        }
                    }

                    var row = dt.Rows[idx];
                    long time = (long)row["Time"];
                    sbyte?[, ,] hps = HpData.DeserializeHp((byte[])row["hp"]);
                    long?[, ,] hpTimes = HpData.DeserializeHpTimes((byte[])row["hp_date"]);

                    WekaUtils.DebugAssert(time == time2, "time == time2");

                    if (mode == 0)
                    {
                        int n = hps.GetLength(1) / hps2.GetLength(1);

                        long maxHpTime = 0;
                        for (int k = 0; k < hps.GetLength(0); ++k)
                            for (int tp = 0; tp < hps.GetLength(1); ++tp)
                                for (int sl = 0; sl < hps.GetLength(2); ++sl)
                                {
                                    if (tp % n != n - 1 || sl % n != n - 1)
                                        continue;

                                    if (!isComplete && (!hps2[k, tp / n, sl / n].HasValue || hps2[k, tp / n, sl / n].Value == -1))
                                        continue;

                                    if (hps2[k, tp / n, sl / n] != hps[k, tp, sl]
                                        || hpTimes2[k, tp / n, sl / n] != hpTimes[k, tp, sl])
                                    {
                                        throw new AssertException("hp value is not equal.");
                                    }
                                    maxHpTime = Math.Max(maxHpTime, hpTimes2[k, tp / n, sl / n].Value);
                                }
                    }
                    else if (mode == 1)
                    {
                        int n = 1;
                        long maxHpTime = 0;
                        for (int k = 0; k < Math.Min(hps2.GetLength(0), hps.GetLength(0)); ++k)
                            for (int tp = 0; tp < Math.Min(hps2.GetLength(1), hps.GetLength(1)); ++tp)
                                for (int sl = 0; sl < Math.Min(hps2.GetLength(2), hps.GetLength(2)); ++sl)
                                {
                                    if (!isComplete && (!hps2[k, tp / n, sl / n].HasValue || hps2[k, tp / n, sl / n].Value == -1))
                                        continue;

                                    if (hps2[k, tp / n, sl / n] != hps[k, tp, sl])
                                    {
                                        Console.WriteLine(string.Format("{0} hp value is not equal.", WekaUtils.GetDateFromTime(time)));
                                    }
                                    else if (hpTimes2[k, tp / n, sl / n] != hpTimes[k, tp, sl])
                                    {
                                        Console.WriteLine(string.Format("{0} hpTime value is not equal. {1}, {2}, {3}", WekaUtils.GetDateFromTime(time), 
                                            hpTimes2[k, tp / n, sl / n] - hpTimes[k, tp, sl],
                                            WekaUtils.GetDateFromTime(hpTimes2[k, tp / n, sl / n].Value), WekaUtils.GetDateFromTime(hpTimes[k, tp, sl].Value)));

                                        diffHpTimes[hpTimes2[k, tp / n, sl / n].Value] = 1;
                                    }
                                    maxHpTime = Math.Max(maxHpTime, hpTimes2[k, tp / n, sl / n].Value);
                                }
                    }
                }
                System.Console.WriteLine(string.Format("{0} is ok", WekaUtils.GetDateFromTime(startTime)));

                startTime = endTime;
            }
        }

        public static void CheckHpData(string symbol)
        {
            long startTime = 946859400;
            
            while (true)
            {
                var dt2 = Feng.Data.DbHelper.Instance.ExecuteDataTable(string.Format("SELECT TOP 200 * FROM dbo.{0}_HP WHERE TIME >= {1} ORDER BY TIME", symbol, startTime));
                if (dt2.Rows.Count == 0)
                    break;

                for (int i = 0; i < dt2.Rows.Count; ++i)
                {
                    var row = dt2.Rows[i];

                    sbyte?[, ,] hps2 = HpData.DeserializeHp((byte[])row["hp"]);
                    long?[, ,] hpTimes2 = HpData.DeserializeHpTimes((byte[])row["hp_date"]);

                    for (int k = 0; k < hps2.GetLength(0); ++k)
                        for (int tp = 0; tp < hps2.GetLength(1); ++tp)
                            for (int sl = 0; sl < hps2.GetLength(2); ++sl)
                            {
                                if (!hps2[k, tp, sl].HasValue
                                    || hps2[k, tp, sl].Value == -1)
                                {
                                    //throw new AssertException("hp value is not set.");
                                }
                            }
                }
                System.Console.WriteLine(string.Format("{0} is ok", WekaUtils.GetDateFromTime(startTime)));
                startTime = (long)dt2.Rows[dt2.Rows.Count - 1]["Time"] + 60;
            }
        }
        public static void CheckHpData2()
        {
            string symbol = "EURUSD";
            var simulationData = SimulationData.Instance.Init(symbol);
            int tp = 20;
            int sl = 20;
            var x = new TpSlM1SimulateStrategy(symbol, tp * 10, sl * 10, simulationData);
            var y = new DbSimulationStrategy(symbol, tp * 10, sl * 10);

            DateTime openDate = WekaUtils.GetDateFromTime(946859400);
            int ntp = 0, nfp = 0;
            for (int i = 0; i < 48; ++i)
            {
                var d = openDate.AddMinutes(30 * i);
                DateTime? closeDate;
                var hp = x.DoBuy(d, -1, out closeDate);
                if (hp.Value)
                    ntp++;
                else
                    nfp++;

                DateTime? closeDate2;
                var hp2 = y.DoBuy(d, -1, out closeDate2);
                WekaUtils.DebugAssert(hp == hp2, "hp == hp2");
                WekaUtils.DebugAssert(closeDate == closeDate2, "closeDate == closeDate2");
            }
            ntp = 0; nfp = 0;
            for (int i = 0; i < 48; ++i)
            {
                var d = new DateTime(2006, 6, 19).AddMinutes(30 * i);
                DateTime? closeDate;
                var hp = x.DoSell(d, -1, out closeDate);
                if (hp.Value)
                    ntp++;
                else
                    nfp++;

                DateTime? closeDate2;
                var hp2 = y.DoSell(d, -1, out closeDate2);
                WekaUtils.DebugAssert(hp == hp2, "hp == hp2");
                WekaUtils.DebugAssert(closeDate == closeDate2, "closeDate == closeDate2");
            }
        }
        #region "bat"
        public static void GenerateBatFile2()
        {
            int[] sl = new int[] { 30, 40, 50, 60, 70, 80, 90, 100 };
            int[][] tp = new int[][] { 
                new int[] { 15, 20, 25, 30, 35, 40, 45, 50 },
                new int[] { 30, 40, 50, 60, 70, 80, 90, 100 },
                new int[] { 60, 80, 100, 120, 140, 160, 180, 200 },
                new int[] { 45, 60, 75, 90, 105, 120, 135, 150 }};

            using (StreamWriter sw = new StreamWriter("C:\\do.bat"))
            {
                for (int i = 0; i < tp.Length; ++i)
                {
                    for (int j = 0; j < tp[i].Length; ++j)
                    {
                        sw.WriteLine(string.Format("MLEA.exe -n W2D05T{0}S{1}D{2} -t {0} -s {1} -d {2}", tp[i][j], sl[j], "S"));
                        sw.WriteLine(string.Format("MLEA.exe -n W2D05T{0}S{1}D{2} -t {0} -s {1} -d {2}", tp[i][j], sl[j], "B"));
                    }
                }
            }
        }

        public static void GenerateBatFile1()
        {
            for (int year = 2008; year <= 2010; ++year)
            {
                using (StreamWriter sw = new StreamWriter(string.Format("c:\\do_{0}.bat", year)))
                {
                    for (int month = 0; month < 12; ++month)
                    {
                        string trainFile = string.Format("EURUSD_{0}-{2}-01_{1}-01-01.new.B.libsvm", year, year + 1, (month + 1).ToString("00"));
                        string testFile = string.Format("EURUSD_{0}-01-05_{1}-01-01.new.B.libsvm", year + 1, year + 2);

                        sw.WriteLine(string.Format("svm-train.exe -s 0 -t 0 -c 1 -g 1 -b 1 {0}", trainFile));
                        //sw.WriteLine(string.Format("svm-predict -b 1 {1} {0}.model {0}.output", trainFile, testFile));
                        //sw.WriteLine(string.Format("MLEA GeneratePrecisionRecall {1} {0}.output {0}.comp", trainFile, testFile));
                        //sw.WriteLine(string.Format("train.exe -s 3 -w0 100 -w1 10000 {0}", trainFile));
                        //sw.WriteLine(string.Format("predict {1} {0}.model a.output", trainFile, testFile));
                        sw.WriteLine();
                    }
                }
            }
        }
        #endregion

        #region "result parse"
        public static void GenerateRandomMql(string mqlFile, DateTime start, DateTime end)
        {
            System.Random randomGenerator = new System.Random((int)System.DateTime.Now.Ticks);
            using (StreamWriter sw = new StreamWriter(mqlFile))
            {
                sw.WriteLine("string m_historyDealsTxt[] = {");

                string s = null;
                DateTime date = start;
                while (date <= end)
                {
                    if (date.DayOfWeek != DayOfWeek.Saturday && date.DayOfWeek != DayOfWeek.Sunday)
                    {
                        if (!string.IsNullOrEmpty(s))
                            sw.WriteLine(", ");
                        double d = randomGenerator.NextDouble();
                        if (d > 1.0 / 3)
                            s = "Hold";
                        else
                            s = "Buy";
                        sw.Write("\"");
                        sw.Write(s);
                        sw.Write(", ");
                        sw.Write(date.ToString(Parameters.DateTimeFormat));
                        sw.Write(" , 0, 0, 0, 0");//, 2010-05-18T00:00:00, 0, 0, 0, 0
                        sw.Write("\"");
                    }

                    date = date.AddMinutes(5);
                }
                sw.WriteLine("};");
            }
        }
        public static void ConvertDataToMql(string txtFile = "c:\\ea_order.txt", string mqlFile = "D:\\Program Files\\MetaTrader 5\\MQL5\\Include\\Data\\ea_order.mqh")
        {
            List<String> pattern = new List<string>();
            Dictionary<string, int> dict = new Dictionary<string, int>();

            using (StreamReader sr = new StreamReader(txtFile))
            {
                using (StreamWriter sw = new StreamWriter(mqlFile))
                {
                    sw.WriteLine("string m_historyDealsTxt[] = {");

                    string s = null;
                    while (true)
                    {
                        if (sr.EndOfStream)
                            break;
                        else if (!string.IsNullOrEmpty(s))
                            sw.WriteLine(",");

                        s = sr.ReadLine();
                        if (string.IsNullOrEmpty(s))
                            continue;

                        sw.Write("\"");

                        sw.Write(s);

                        sw.Write("\"");
                    }
                    sw.WriteLine("};");
                }
            }
        }
        public static void MergeEaorder(string buyOrderFile, string sellOrderFile, string resultFile)
        {
            Dictionary<DateTime, string> buyActions = new Dictionary<DateTime, string>();
            using (StreamReader sr1 = new StreamReader(buyOrderFile))
            {
                while (true)
                {
                    if (sr1.EndOfStream)
                        break;
                    string s = sr1.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        continue;
                    string[] ss = s.Split(new char[] { ',' });
                    buyActions[Convert.ToDateTime(ss[1])] = ss[0];
                }
            }
            Dictionary<DateTime, string> sellActions = new Dictionary<DateTime, string>();
            using (StreamReader sr2 = new StreamReader(sellOrderFile))
            {
                while (true)
                {
                    if (sr2.EndOfStream)
                        break;
                    string s = sr2.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        continue;
                    string[] ss = s.Split(new char[] { ',' });
                    sellActions[Convert.ToDateTime(ss[1])] = ss[0];
                }
            }

            using (StreamWriter sw = new StreamWriter(resultFile))
            {
                foreach (var kvp in buyActions)
                {
                    int ret = 0;
                    if (kvp.Value == "Buy")
                    {
                        ret = 1;
                        if (sellActions.ContainsKey(kvp.Key))
                        {
                            if (sellActions[kvp.Key] == "Sell")
                            {
                                ret = 2;
                            }
                        }
                    }
                    else
                    {
                        if (sellActions.ContainsKey(kvp.Key))
                        {
                            if (sellActions[kvp.Key] == "Sell")
                            {
                                ret = -1;
                            }
                        }
                    }

                    sw.WriteLine(string.Format("{0}, {1}, 0, 0, 0, 0",
                        (ret == 1 ? "Buy" : (ret == -1 ? "Sell" : (ret == 2 ? "Hold" : "Quit"))), kvp.Key.ToString("yyyy-MM-ddTHH:mm:ss")));
                }
            }
        }

        public static void ParseResultWithBestClassifier(string inputFile, string outputFile)
        {
            Tuple<double, double>[] ret = new Tuple<double, double>[20];
            for (int i = 0; i < ret.Length; ++i)
                ret[i] = new Tuple<double, double>(0, 0);

            int nStart = 0;
            int nShouldStart = 2;
            using (StreamReader sr = new StreamReader(inputFile))
            {
                while (true)
                {
                    if (sr.EndOfStream)
                        break;

                    string s = sr.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        continue;
                    if (s.StartsWith("-----"))
                    {
                        nStart++;
                        if (nStart > nShouldStart)
                            break;
                        continue;
                    }
                    if (nStart < nShouldStart)
                        continue;

                    if (s.StartsWith("Best Classifier:"))
                    {
                        System.Text.RegularExpressions.Regex r = new System.Text.RegularExpressions.Regex("Best Classifier: N=(.*),TC=(.*),TP=(.*),FP=(.*),TD=(.*),TV=(.*)");
                        var match = r.Match(s);
                        if (match.Success)
                        {
                            string name = match.Groups[1].Value;
                            string[] ss = name.Split(new char[] { '_' });
                            double c = Convert.ToDouble(ss[1]) / Convert.ToDouble(ss[2]);

                            int tc = (int)(-Convert.ToDouble(match.Groups[2].Value) / 2500);

                            s = sr.ReadLine();
                            System.Text.RegularExpressions.Regex r2 = new System.Text.RegularExpressions.Regex("(.*)TTP=(.*),TFP=(.*),NC=(.*),NTP=(.*),NFP=(.*),NV=(.*),CP=(.*),CV=(.*),CD=(.*),TC=(.*),TV=(.*)");
                            match = r2.Match(s);
                            if (match.Success)
                            {
                                int tp = Convert.ToInt32(match.Groups[2].Value);
                                int fp = Convert.ToInt32(match.Groups[3].Value);
                                ret[tc] = new Tuple<double, double>(ret[tc].Item1 + tp * c, ret[tc].Item2 + fp);
                            }
                        }
                    }
                }
            }

            using (StreamWriter sw = new StreamWriter(outputFile))
            {
                for (int i = 0; i < ret.Length; ++i)
                {
                    sw.WriteLine(string.Format("{0}\t{1}\t{2}\t{3}", i, ret[i].Item1, ret[i].Item2, (double)ret[i].Item1 / (ret[i].Item1 + ret[i].Item2)));
                }
            }
        }
        public static void GetResultCost(string inputFile, string outputFile)//, string trPrefix = null)
        {
            DateTime dtStart = new DateTime(2009, 1, 1);
            int outputFileIdx = -1;
            using (StreamReader sr = new StreamReader(inputFile))
            {
                StreamWriter sw = new StreamWriter(outputFile);
                DateTime currentDate = dtStart;
                while (true)
                {
                    if (sr.EndOfStream)
                        break;

                    string s = sr.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        continue;
                    if (s.StartsWith("Now is"))
                    {
                        try
                        {
                            currentDate = Convert.ToDateTime(s.Substring(7, 19));
                        }
                        catch (Exception)
                        {
                        }
                    }
                    if (currentDate > System.DateTime.Now)
                        continue;

                    if (s.StartsWith("------"))
                        outputFileIdx++;
                    if (outputFileIdx > 0)
                    {
                        sw.Close();
                        sw = new StreamWriter(outputFile + outputFileIdx.ToString());
                    }

                    string trStart = "TR:";
                    if (s.Contains(trStart))
                    {
                        System.Text.RegularExpressions.Regex r = new System.Text.RegularExpressions.Regex("(.*)TTP=(.*),TFP=(.*),NC=(.*),NTP=(.*),NFP=(.*),NV=(.*),CP=(.*),CV=(.*),CD=(.*),TC=(.*),TV=(.*)");
                        var match = r.Match(s);
                        if (match.Success)
                        {
                            double nowCost = Convert.ToDouble(match.Groups[4].Value);
                            double totalCost = Convert.ToDouble(match.Groups[11].Value);
                            double cp = Convert.ToDouble(match.Groups[8].Value);
                            double cv = Convert.ToDouble(match.Groups[9].Value);
                            //sw.WriteLine(string.Format("{0}, {1}, {2}, {3}, {4}", currentDate.ToString(Parameters.DateTimeFormat), (currentDate - dtStart).TotalHours, cost.ToString(Parameters.DoubleFormatString), costs[1].ToString(Parameters.DoubleFormatString), (cost - cost3).ToString(Parameters.DoubleFormatString)));
                            sw.WriteLine(string.Format("{0}, {1}, {2}, {3}, {4}, {5}",
                                currentDate.ToString(Parameters.DateTimeFormat),
                                (currentDate - dtStart).TotalHours,
                                nowCost.ToString(Parameters.DoubleFormatString),
                                (nowCost + cp).ToString(Parameters.DoubleFormatString),
                                totalCost.ToString(Parameters.DoubleFormatString),
                                cv.ToString(Parameters.DoubleFormatString)));
                        }
                    }
                }
                sw.Close();
            }
        }
        public static void GetResultCostDropdown(string inputFile, string outputFile)
        {
            using (StreamReader sr = new StreamReader(inputFile))
            using (StreamWriter sw = new StreamWriter(outputFile))
            {
                double nowMaxEquit = 0;
                while (true)
                {
                    if (sr.EndOfStream)
                        break;
                    string s = sr.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        continue;
                    string[] ss = s.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                    double equit = Convert.ToDouble(ss[2]);
                    if (equit < nowMaxEquit)
                    {
                        nowMaxEquit = equit;
                        sw.WriteLine("0");
                    }
                    else
                    {
                        sw.WriteLine((nowMaxEquit - equit).ToString(Parameters.DoubleFormatString));
                    }
                }
            }
        }
        #endregion

        #region "ForexCombo"
        public static void GenerateForexComboData()
        {
            var dt = Feng.Data.DbHelper.Instance.ExecuteDataTable("SELECT Date, b_hp FROM EURUSD_M5 WHERE Date >= '2010.05.03' AND Date <= '2011.10.14' AND b_hp IS NOT NULL");
            Dictionary<DateTime, int> probDict = new Dictionary<DateTime, int>();
            foreach (System.Data.DataRow row in dt.Rows)
            {
                probDict[(DateTime)row["Date"]] = (int)(double)row["b_hp"];
            }
            using (StreamWriter sw = new StreamWriter("c:\\ComboBreakIndicator.arff"))
            {
                sw.WriteLine("@relation 'ComboBreakIndicator'");
                sw.WriteLine("@attribute MAPlusClose numeric");
                sw.WriteLine("@attribute ATR numeric");
                sw.WriteLine("@attribute Hour numeric");
                sw.WriteLine("@attribute prop {0,1}");
                sw.WriteLine("@data");

                using (StreamReader sr = new StreamReader("c:\\ComboBreakIndicator.txt"))
                {
                    while (true)
                    {
                        if (sr.EndOfStream)
                            break;
                        string s = sr.ReadLine();
                        if (string.IsNullOrEmpty(s))
                            continue;

                        string[] ss = s.Split(new char[] { ',' });
                        double a = (Convert.ToDouble(ss[2]) - Convert.ToDouble(ss[3])) * 1;
                        sw.Write(a.ToString("N2"));
                        sw.Write(",");
                        double b = Convert.ToDouble(ss[4]) * 1;
                        sw.Write(b.ToString("N2"));
                        sw.Write(",");
                        sw.Write(Convert.ToInt32(ss[1]));
                        sw.Write(",");

                        DateTime date = Convert.ToDateTime(ss[0]);
                        int prob = probDict.ContainsKey(date) ? probDict[date] : 0;
                        sw.WriteLine(prob);
                    }
                }
            }
        }
        #endregion

        #region "Cluster"
        public void SplitDataAccordCluster()
        {
            Instances origInstances = WekaUtils.LoadInstances("EURUSD_2010-01-05_2010-04-01.new.B.arff");
            Instances noClassInstances = WekaUtils.RemoveClassAttribute(origInstances); // LoadInstances("cluster.arff");
            WekaUtils.DebugAssert(origInstances.numInstances() == noClassInstances.numInstances(), "");

            var cluster = WekaUtils.CreateCluster();
            //cluster.buildClusterer(noClassInstances);
            //weka.core.SerializationHelper.write(string.Format("{0}\\cluster.cluster", m_baseDir), cluster);
            cluster = (weka.clusterers.Clusterer)weka.core.SerializationHelper.read(string.Format("c:\\cluster.cluster"));

            Instances[] newInstances = new Instances[cluster.numberOfClusters()];

            for (int i = 0; i < cluster.numberOfClusters(); ++i)
            {
                newInstances[i] = new Instances(origInstances, 0, 0);
            }

            for (int i = 0; i < noClassInstances.numInstances(); ++i)
            {
                int n = cluster.clusterInstance(noClassInstances.instance(i));
                WekaUtils.DebugAssert(n >= 0 && n < cluster.numberOfClusters(), "");

                newInstances[n].add(origInstances.instance(i));
            }

            for (int i = 0; i < cluster.numberOfClusters(); ++i)
            {
                string fileName = GetArffFileName(true, i.ToString());
                WekaUtils.SaveInstances(newInstances[i], fileName);
            }
        }

        public void TestSplitDataProb()
        {
            int sum = 0;
            string oldBaseDir = TestParameters.BaseDir;
            for (int i = 0; i < 10; ++i)
            {
                TestParameters.BaseDir = oldBaseDir + "\\n";
                string fileName = GetArffFileName(true, i.ToString());

                Instances instances = WekaUtils.LoadInstances(fileName);
                instances.setClassIndex(instances.numAttributes() - 1);

                int pos = 0, neg = 0;
                foreach (Instance ins in instances)
                {
                    if (ins.classValue() == 1)
                        pos++;
                    else if (ins.classValue() == 0)
                        neg++;
                }

                if (pos > neg)
                {
                    TestParameters.BaseDir = oldBaseDir;
                    fileName = GetArffFileName(true, i.ToString());
                    instances = WekaUtils.LoadInstances(fileName);
                    instances.setClassIndex(instances.numAttributes() - 1);

                    pos = 0; neg = 0;
                    foreach (Instance ins in instances)
                    {
                        if (ins.classValue() == 1)
                            pos++;
                        else if (ins.classValue() == 0)
                            neg++;
                    }
                    sum += pos - neg;
                }
            }
        }

        public void TestCluster()
        {
            //string modelFileName = string.Format("{0}\\cluster.model", m_baseDir);
            //var cluster = (weka.clusterers.SimpleKMeans)weka.core.SerializationHelper.read(modelFileName);

            weka.clusterers.SimpleKMeans cluster = new weka.clusterers.SimpleKMeans();

            Instances origInstances = WekaUtils.LoadInstances(GetArffFileName(true, "B", "new"));
            Instances noClassInstances = WekaUtils.RemoveClassAttribute(origInstances);

            //foreach (Instance i in origInstances)
            //{
            //    List<double> d = new List<double>();
            //    foreach (Instance j in cluster.getClusterCentroids())
            //    {
            //        d.Add(cluster.getDistanceFunction().distance(i, j));
            //    }
            //}
            for (int c = 5; c <= 200; ++c)
            {
                cluster.setOptions(weka.core.Utils.splitOptions(string.Format("-V -M -N {0} -A \"weka.core.EuclideanDistance -R first-last\" -I 500 -O -S 10", c)));
                cluster.buildClusterer(noClassInstances);
                double d = cluster.getSquaredError();

                WekaUtils.Instance.WriteLog(string.Format("{0}: {1}", c, d));
            }
        }
        #endregion

        #region "Sql"
        //public static void DeleteTestData()
        //{
        //    string sql = ("SELECT Time, ClsName, TestResult, ClassValue, DealsData FROM TestData WHERE [Time] >= @Time1 AND [Time] < @Time2 AND [Type] = @Type AND ({0})");

        //    SqlCommand cmd = new SqlCommand(string.Format(sql, inClause));
        //    cmd.Parameters.AddWithValue("@Time1", GetTimeFromDate(currentDate));
        //    cmd.Parameters.AddWithValue("@Time2", GetTimeFromDate(m_testDataEndDate));
        //    cmd.Parameters.AddWithValue("@Type", m_testDataType);
        //}
        public static void Test2()
        {
            DateTime dateStart = new DateTime(2008, 6, 1);
            int sum = 0;
            bool buy = false;

            int deltaMinutes = 240;

            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["DataConnectionString"].ConnectionString))
            {
                conn.Open();

                while (true)
                {
                    string sql = string.Format("SELECT COUNT(*) FROM EURUSD_M5 WHERE B_hp = {0} AND B_hp_Date >= '{1}'AND B_hp_Date < '{2}'", 1, dateStart, dateStart.AddMinutes(deltaMinutes));
                    System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn);
                    int buy_pos = (int)cmd.ExecuteScalar();
                    sql = string.Format("SELECT COUNT(*) FROM EURUSD_M5 WHERE B_hp = {0} AND B_hp_Date >= '{1}' AND B_hp_Date < '{2}'", 0, dateStart, dateStart.AddMinutes(deltaMinutes));
                    cmd = new System.Data.SqlClient.SqlCommand(sql, conn);
                    int buy_neg = (int)cmd.ExecuteScalar();

                    sql = string.Format("SELECT COUNT(*) FROM EURUSD_M5 WHERE B_hp = {0} AND Date >= '{1}' AND Date < '{2}'", 1, dateStart, dateStart.AddMinutes(deltaMinutes));
                    cmd = new System.Data.SqlClient.SqlCommand(sql, conn);
                    int buy_pos_now = (int)cmd.ExecuteScalar();
                    sql = string.Format("SELECT COUNT(*) FROM EURUSD_M5 WHERE B_hp = {0} AND Date >= '{1}' AND Date < '{2}'", 0, dateStart, dateStart.AddMinutes(deltaMinutes));
                    cmd = new System.Data.SqlClient.SqlCommand(sql, conn);
                    int buy_neg_now = (int)cmd.ExecuteScalar();

                    if (buy_pos + buy_neg > 0)
                    {
                        if (buy)
                        {
                            sum += (buy_pos_now - buy_neg_now);
                        }
                        if (buy_pos > buy_neg)
                            buy = true;
                        else
                            buy = false;
                    }
                    else
                    {
                        buy = false;
                    }

                    sql = string.Format("SELECT COUNT(*) FROM EURUSD_M5 WHERE S_hp = {0} AND S_hp_Date >= '{1}'AND S_hp_Date < '{2}'", 1, dateStart, dateStart.AddMinutes(deltaMinutes));
                    cmd = new System.Data.SqlClient.SqlCommand(sql, conn);
                    int sell_pos = (int)cmd.ExecuteScalar();
                    sql = string.Format("SELECT COUNT(*) FROM EURUSD_M5 WHERE S_hp = {0} AND S_hp_Date >= '{1}' AND S_hp_Date < '{2}'", 0, dateStart, dateStart.AddMinutes(deltaMinutes));
                    cmd = new System.Data.SqlClient.SqlCommand(sql, conn);
                    int sell_neg = (int)cmd.ExecuteScalar();

                    //sql = string.Format("SELECT COUNT(*) FROM EURUSD_M5 WHERE S_hp = {0} AND Date >= '{1}' AND Date < '{2}'", 1, dateStart, dateStart.AddMinutes(deltaMinutes));
                    //cmd = new SqlCommand(sql, conn);
                    //int sell_pos_now = (int)cmd.ExecuteScalar();
                    //sql = string.Format("SELECT COUNT(*) FROM EURUSD_M5 WHERE S_hp = {0} AND Date >= '{1}' AND Date < '{2}'", 0, dateStart, dateStart.AddMinutes(deltaMinutes));
                    //cmd = new SqlCommand(sql, conn);
                    //int sell_neg_now = (int)cmd.ExecuteScalar();

                    //if (sell_pos + sell_neg != 0)
                    //{
                    //    if (sell)
                    //    {
                    //        sum += (sell_pos_now - sell_neg_now);
                    //    }

                    //    if (sell_pos > sell_neg)
                    //        sell = true;
                    //    else
                    //        sell = false;
                    //}


                    dateStart = dateStart.AddMinutes(deltaMinutes);

                    WekaUtils.Instance.WriteLog(dateStart.ToString() + ": " + buy_pos + ", " + buy_neg + "," + sum.ToString());

                    if (dateStart > new DateTime(2011, 10, 1))
                        break;

                    System.Threading.Thread.Sleep(1000);
                }
            }
        }
        #endregion

        #region "ChangeClass"
        public static void ChangeArffClassAccordProb()
        {
            Instances origInstances = WekaUtils.LoadInstances("E:\\Forex\\Forex3\\EURUSD_2010-01-03_2010-10-10.new.B.arff");
            origInstances.setClassIndex(origInstances.numAttributes() - 1);

            int i = 0;
            using (System.IO.StreamReader sr2 = new System.IO.StreamReader("E:\\Forex\\Forex3\\1.output"))
            {
                sr2.ReadLine();

                while (true)
                {
                    string s2 = sr2.ReadLine();
                    if (sr2.EndOfStream)
                        break;

                    var ss = s2.Split(new char[] { ' ' });
                    int b = Convert.ToInt32(ss[0]);
                    double prob = Convert.ToDouble(ss[2]);
                    if (prob < 0.95 && b == 1)
                    {
                        b = 0;
                        origInstances.instance(i).setClassValue(b);
                    }
                    i++;
                }
            }

            WekaUtils.SaveInstances(origInstances, "E:\\Forex\\Forex3\\EURUSD_2010-01-03_2010-10-10.new.B1.arff");
        }
        public static void RemoveHeadTailAction(string arffFileName, int removeCnt = 1)
        {
            Instances origInstances = WekaUtils.LoadInstances(arffFileName);
            origInstances.setClassIndex(origInstances.numAttributes() - 1);

            double defaultValue = 1;
            for (int i = 0; i < origInstances.numInstances(); ++i)
            {
                if (origInstances.instance(i).classValue() != defaultValue)
                {
                    int i1 = i;
                    double v1 = origInstances.instance(i).classValue();
                    while (origInstances.instance(i).classValue() == v1)
                    {
                        i++;
                    }
                    if (i - i1 < 2 * removeCnt)
                    {
                        throw new ArgumentException("Too big of removeCnt");
                    }
                    for (int j = 0; j < removeCnt; ++j)
                        origInstances.instance(j + i1).setClassValue(defaultValue);
                    for (int j = 0; j < removeCnt; ++j)
                        origInstances.instance(i - 1 - j).setClassValue(defaultValue);
                }
            }

            WekaUtils.SaveInstances(origInstances, arffFileName.Replace(".cc.arff", ".cc2.arff"));
        }
        public static void ConvertToSequenceAction(string arffFileName, int successClassCnt = 3)
        {
            for (int k = 0; k < 1/*(m_enableTest ? 2 : 1)*/; ++k)
            {
                //SetTraining(k == 0);
                //string arffFileName = GetArffFileName(append);

                Instances origInstances = WekaUtils.LoadInstances(arffFileName);
                origInstances.setClassIndex(origInstances.numAttributes() - 1);

                double nowClass = -1;
                for (int i = 0; i < origInstances.numInstances(); ++i)
                {
                    if (nowClass == -1)
                    {
                        nowClass = origInstances.instance(i).classValue();
                        continue;
                    }
                    if (nowClass == origInstances.instance(i).classValue())
                        continue;

                    // if = 0, then remain 0
                    if (origInstances.instance(i).classValue() == 1)
                    {
                        nowClass = 1;
                    }
                    else
                    {
                        bool same = true;
                        for (int j = 1; j < successClassCnt; ++j)
                        {
                            if (i + j >= origInstances.numInstances())
                                break;

                            if (origInstances.instance(i + j).classValue() != origInstances.instance(i).classValue())
                            {
                                same = false;
                                break;
                            }
                        }
                        if (!same)
                        {
                            origInstances.instance(i).setClassValue(nowClass);
                        }
                        else
                        {
                            nowClass = origInstances.instance(i).classValue();
                        }
                    }
                }

                WekaUtils.SaveInstances(origInstances, arffFileName.Replace(".arff", ".cc.arff"));
            }
        }
        #endregion

        #region"dist"
        //public void TestWithDistance()
        //{
        //    m_baseDir = "E:\\Dropbox\\Forex";

        //    m_isTrain = true;
        //    m_trainTimeStart = new DateTime(2010, 1, 1);
        //    m_trainTimeEnd = new DateTime(2010, 11, 1);
        //    Instances origInstances = new Instances(new BufferedReader(new FileReader(GetArffFileName(m_newFileAppend))));
        //    origInstances.setClassIndex(origInstances.numAttributes() - 1);

        //    //m_trainTimeEnd = new DateTime(2010, 3, 1);
        //    m_isTrain = false;
        //    m_testTimeStart = new DateTime(2010, 11, 1);
        //    m_testTimeEnd = new DateTime(2010, 12, 1);
        //    Instances testInstances = new Instances(new BufferedReader(new FileReader(GetArffFileName(m_newFileAppend))));
        //    testInstances.setClassIndex(origInstances.numAttributes() - 1);

        //    int[,] c = new int[3, 3];
        //    for (int i = 0; i < testInstances.numInstances(); ++i)
        //    {
        //        double minError = double.MaxValue;
        //        int minJ = -1;
        //        for (int j = 0; j < origInstances.numInstances(); ++j)
        //        {
        //            double sumError = 0;
        //            bool sameAttr = true;
        //            for (int k = 0; k < 2; ++k)
        //            {
        //                if (testInstances.instance(i).value(k) - origInstances.instance(j).value(k) != 0)
        //                {
        //                    sameAttr = false;
        //                    break;
        //                }
        //            }
        //            if (!sameAttr)
        //                continue;
        //            for (int k = 2; k < origInstances.numAttributes() - 1; ++k)
        //            {
        //                double error = Math.Abs(testInstances.instance(i).value(k) - origInstances.instance(j).value(k));
        //                sumError += error;
        //            }
        //            if (sumError < minError)
        //            {
        //                minError = sumError;
        //                minJ = j;
        //            }
        //        }

        //        int cv = (int)origInstances.instance(minJ).classValue();
        //        if (minError > 10)
        //            cv = 1;

        //        c[(int)testInstances.instance(i).classValue(), cv]++;
        //    }
        //}
        #endregion

        #region "data"


        public void GenerateWeightFile(string arffFileName, string weightFileName)
        {
            string period = "M5";
            Instances origInstances = WekaUtils.LoadInstances(arffFileName);
            DateTime maxDate = Convert.ToDateTime(origInstances.attribute(0).formatDate(origInstances.instance(0).value(0)));
            DateTime minDate = Convert.ToDateTime(origInstances.attribute(0).formatDate(origInstances.instance(origInstances.numInstances() - 1).value(0)));
            int n = (int)(minDate - maxDate).TotalMinutes / WekaUtils.GetMinuteofPeriod(period);

            using (StreamWriter sw = new StreamWriter(weightFileName))
            {
                for (int i = 0; i < origInstances.numInstances(); ++i)
                {
                    DateTime date = Convert.ToDateTime(origInstances.attribute(0).formatDate(origInstances.instance(i).value(0)));
                    int m = (int)(minDate - date).TotalMinutes / WekaUtils.GetMinuteofPeriod(period);

                    sw.WriteLine(-m + n + 1);
                }
            }
        }
        public static void GeneratePrecisionRecall(string originalLibsvmFile, string outputFile, string resultFile)
        {
            double[] thresholds = new double[] { 0.5, 0.7, 0.9, 0.95, 0.99, 0.999 };

            using (StreamWriter sw1 = new StreamWriter(resultFile + ".precision"))
            using (StreamWriter sw2 = new StreamWriter(resultFile + ".recall"))
            using (StreamWriter sw3 = new StreamWriter(resultFile + ".accuracy"))
            using (StreamWriter sw4 = new StreamWriter(resultFile + ".fscore"))
            using (StreamWriter sw5 = new StreamWriter(resultFile + ".trueposnum"))
            using (StreamWriter sw6 = new StreamWriter(resultFile + ".posnum"))
            {
                for (int i = 0; i < thresholds.Length; ++i)
                {
                    double threshold = thresholds[i];

                    int[,] r = new int[2, 2];
                    List<double> recalls = new List<double>();
                    List<double> precisions = new List<double>();

                    int n = 0;
                    using (StreamReader sr1 = new StreamReader(originalLibsvmFile))
                    {
                        using (StreamReader sr2 = new StreamReader(outputFile))
                        {
                            string labelCaption = sr2.ReadLine();   // labels 0 1
                            string[] ss = labelCaption.Split(new char[] { ' ' });
                            int positionIdx = (ss[2] == "1" ? 2 : 1);

                            while (true)
                            {
                                string s1 = sr1.ReadLine();
                                string s2 = sr2.ReadLine();
                                if (sr1.EndOfStream)
                                    break;
                                ss = s1.Split(new char[] { ' ' });
                                int a = (int)Convert.ToDouble(ss[0]);
                                ss = s2.Split(new char[] { ' ' });
                                int b = Convert.ToInt32(ss[0]);
                                double prob = 1;
                                if (ss.Length >= 3)
                                {
                                    prob = Convert.ToDouble(ss[positionIdx]);
                                }
                                // a: actual, b:predict
                                if (n > 0)
                                {
                                    if (prob < threshold)
                                        b = 0;
                                    else
                                        b = 1;

                                    r[a, b]++;

                                    double precision = 0, recall = 0, accuracy = 0, fscore = 0;
                                    if (r[1, 1] + r[0, 1] != 0)
                                    {
                                        precision = (double)r[1, 1] / (r[1, 1] + r[0, 1]);
                                    }
                                    if (r[1, 1] + r[1, 0] != 0)
                                    {
                                        recall = (double)r[1, 1] / (r[1, 1] + r[1, 0]);
                                    }
                                    accuracy = (double)(r[1, 1] + r[0, 0]) / (r[1, 1] + r[0, 1] + r[1, 0] + r[0, 0]);

                                    if (precision + recall != 0)
                                    {
                                        fscore = (precision * recall) / (precision + recall) / 2.0;
                                    }

                                    precisions.Add(precision);
                                    recalls.Add(recall);

                                    if (n > 0)
                                    {
                                        sw1.Write(", ");
                                        sw2.Write(", ");
                                        sw3.Write(", ");
                                        sw4.Write(", ");
                                        sw5.Write(", ");
                                        sw6.Write(", ");
                                    }

                                    sw1.Write(precision.ToString("N2"));
                                    sw2.Write(recall.ToString("N2"));
                                    sw3.Write(accuracy.ToString("N2"));
                                    sw4.Write(fscore.ToString("N2"));
                                    sw5.Write(r[1, 1]);
                                    sw6.Write((r[1, 1] + r[0, 1]).ToString());
                                }
                                n++;
                            }
                        }
                    }

                    sw1.WriteLine();
                    sw2.WriteLine();
                    sw3.WriteLine();
                    sw4.WriteLine();
                    sw5.WriteLine();
                    sw6.WriteLine();
                }
            }
        }





        #endregion

        #region "stock"
        public void TestStock()
        {
            var dt = DbHelper.Instance.ExecuteDataTable("SELECT [Date], [Price],[Type],[Volume] FROM STOCK_Tick_SH600000 ORDER BY Date");
            int money = 0;
            float firstPrice = (float)dt.Rows[0]["Price"];
            int firstDay = ((DateTime)dt.Rows[0]["Date"]).Day;
            double p = 0;
            using (StreamWriter sw = new StreamWriter("c:\\a.txt"))
            {
                for (int i = 0; i < dt.Rows.Count; ++i)
                {
                    int d = ((DateTime)dt.Rows[i]["Date"]).Day;
                    if (d != firstDay)
                    {
                        firstDay = d;
                        sw.WriteLine(string.Format("{0},{1}", money, p));
                    }

                    if (dt.Rows[i]["Type"].ToString() == "B")
                        money += (int)dt.Rows[i]["Volume"];
                    else if (dt.Rows[i]["Type"].ToString() == "S")
                        money -= (int)dt.Rows[i]["Volume"];
                    else
                        throw new AssertException("invalid type.");
                    p = (float)dt.Rows[i]["Price"] - firstPrice;
                }
            }
        }
        #endregion

        #region "Mt"
        public static void CheckMtLogToDbData(string logResultFile)
        {
            using (StreamReader sr = new StreamReader(logResultFile))
            {
                while (true)
                {
                    if (sr.EndOfStream)
                        break;
                    string s = sr.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        continue;

                    int orderNo = Convert.ToInt32(s.Substring(0, s.IndexOf(':')));
                    s = s.Substring(s.IndexOf(':') + 2);
                    string[] ss = s.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                    if (ss[ss.Length - 1].Trim() == "No out now")
                        continue;
                    DateTime openDate = Convert.ToDateTime(ss[0].Trim());
                    char dealType = ss[1].Trim() == "buy" ? 'B' : 'S';
                    double openPrice = Convert.ToDouble(ss[2].Trim());
                    double slPrice = Convert.ToDouble(ss[3].Replace("sl=", "").Trim());
                    double tpPrice = Convert.ToDouble(ss[4].Replace("tp=", "").Trim());
                    int tp = (int)Math.Round(Math.Abs(tpPrice - openPrice) * 10000) / 10 * 10;
                    int sl = (int)Math.Round(Math.Abs(slPrice - openPrice) * 10000) / 10 * 10;
                    DateTime closeDate = Convert.ToDateTime(ss[5].Trim());
                    int closeType = ss[6].Trim() == "sl" ? 0 : 1;

                    string sql = string.Format("SELECT * FROM EURUSD_HP WHERE DEALTYPE = '{0}' AND TP = {1} AND SL = {2} AND Time = {3}",
                        dealType, tp, sl, WekaUtils.GetTimeFromDate(openDate));
                    var dt = DbHelper.Instance.ExecuteDataTable(sql);
                    if (dt.Rows.Count != 1)
                    {
                        WekaUtils.Instance.WriteLog("invalid info for " + s);
                    }
                    else
                    {
                        DateTime hpDate = (DateTime)dt.Rows[0]["hp_Date"];
                        int hp = (byte)dt.Rows[0]["hp"];
                        if (hp != closeType)
                        {
                            WekaUtils.Instance.WriteLog(string.Format("not correspond hp for {0}. hp={1} and close_type={2}",
                                    orderNo, hp, closeType));
                        }
                        else
                        {
                            if (hpDate < closeDate.AddSeconds(-closeDate.Second))
                            {
                                WekaUtils.Instance.WriteLog(string.Format("not correspond hp_date for {0}. hp_date={1} and close_date={2}",
                                    orderNo, hpDate.ToString(Parameters.DateTimeFormat), closeDate.ToString(Parameters.DateTimeFormat)));
                            }
                        }
                    }
                }
            }
        }
        public static void GetMtLogFileOrders(string mtReportFile, string inputLogDir, string outputFile)
        {
            System.Text.RegularExpressions.Regex r = new System.Text.RegularExpressions.Regex("<tr bgcolor=\"(#F7F7F7|#FFFFFF)\" align=right><td>(.*)</td><td>(.*)</td><td>(.*)</td><td>(.*)</td><td>(.*)</td><td>(.*)</td><td>(.*)</td><td>(.*)</td><td>(.*)</td><td>(.*)</td><td>(.*)</td><td>(.*)</td><td>(.*)</td></tr>");
            Dictionary<long, string> inDeals = new Dictionary<long, string>();
            bool nowIsDealInfo = false;
            using (StreamReader sr = new StreamReader(mtReportFile))
            {
                while (true)
                {
                    if (sr.EndOfStream)
                        break;
                    string s = sr.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        continue;

                    if (!nowIsDealInfo && s.Contains("<b>Deals</b></div></th>"))
                        nowIsDealInfo = true;
                    if (!nowIsDealInfo)
                        continue;

                    var match = r.Match(s);
                    if (!match.Success)
                        continue;

                    var currentDate = Convert.ToDateTime(match.Groups[2].Value);
                    string inout = match.Groups[6].Value;
                    if (inout == "in" || inout == "out")
                    {
                        inDeals[Convert.ToInt32(match.Groups[9].Value)] = currentDate.ToString(Parameters.DateTimeFormat) + "," +
                            match.Groups[5].Value + "," +
                            match.Groups[8].Value + "," +
                            match.Groups[14].Value.Replace("WekaExpert:", "");
                    }
                }
            }

            DirectoryInfo di = new DirectoryInfo(inputLogDir);
            FileSystemInfo[] files = di.GetFileSystemInfos();
            var orderedFiles = files.OrderBy(f => f.CreationTime);

            Dictionary<long, string> inDealsOut = new Dictionary<long, string>();
            r = new System.Text.RegularExpressions.Regex("Debug:\\|:(.*)Send order (.*),ORDER_DELETE,(.*),(sl|tp)");
            foreach (var file in orderedFiles)
            {
                using (StreamReader sr = new StreamReader(file.FullName))
                {
                    while (true)
                    {
                        if (sr.EndOfStream)
                            break;
                        string s = sr.ReadLine();
                        if (string.IsNullOrEmpty(s))
                            continue;
                        var match = r.Match(s);
                        if (!match.Success)
                            continue;
                        int deleteOrder = Convert.ToInt32(match.Groups[3].Value);
                        inDealsOut[deleteOrder] = Convert.ToDateTime(match.Groups[1].Value).ToString(Parameters.DateTimeFormat) + ", " +
                                match.Groups[4].Value + ", " +
                                match.Groups[2].Value;
                    }
                }
            }

            using (StreamWriter sw = new StreamWriter(outputFile))
            {
                foreach (var kvp in inDeals)
                {
                    sw.Write(kvp.Key + ": " + kvp.Value);
                    sw.Write(", ");
                    if (inDealsOut.ContainsKey(kvp.Key))
                    {
                        sw.Write(inDealsOut[kvp.Key]);
                    }
                    else
                    {
                        sw.Write("No out now");
                    }
                    sw.WriteLine();
                }
            }
        }

        //public static Dictionary<int, int> GetAccordingDealFromLog(List<MtReportDeal> list)
        //{
        //    Dictionary<int, int> inDealsOut = new Dictionary<int, int>();

        //    var r = new System.Text.RegularExpressions.Regex("Debug:\\|:(.*)Send order (.*),ORDER_DELETE,(.*),(sl|tp)");
        //    using (StreamReader sr = new StreamReader("d:\\20120529.log"))
        //    {
        //        while (true)
        //        {
        //            if (sr.EndOfStream)
        //                break;
        //            string s = sr.ReadLine();
        //            if (string.IsNullOrEmpty(s))
        //                continue;
        //            var match = r.Match(s);
        //            if (!match.Success)
        //                continue;
        //            int deleteOrder = Convert.ToInt32(match.Groups[3].Value);
        //            inDealsOut[deleteOrder] = 0;
        //        }
        //    }

        //    return inDealsOut;
        //}

        

        public static void TestMultiClassifierResult()
        {
            double[] prob = new double[] { 0.4, 0.4, 0.4 };
            int n = 100000;
            int[,] p = new int[prob.Length + 1, n];

            System.Random random = new Random();
            for (int i = 0; i < n; ++i)
            {
                var r = random.NextDouble();
                if (r < 0.5)
                    p[0, i] = 0;
                else
                    p[0, i] = 1;
            }

            double sump = 0;
            List<double> ps = new List<double>();
            for (int x = 0; x < 1000; ++x)
            {
                for (int j = 0; j < prob.Length; ++j)
                {
                    for (int i = 0; i < n; ++i)
                    {
                        var r = random.NextDouble();
                        if (r < prob[j])
                            p[j + 1, i] = p[0, i];
                        else
                            p[j + 1, i] = 1 - p[0, i];
                    }
                }

                for (int j = 0; j < prob.Length; ++j)
                {
                    int tp = 0, fp = 0;
                    for (int i = 0; i < n; ++i)
                    {
                        if (p[0, i] == p[j + 1, i])
                            tp++;
                        else
                            fp++;
                    }
                    double p1 = (double)tp / (tp + fp);
                    WekaUtils.DebugAssert(Math.Abs(p1 - prob[j]) < 0.2, "");
                }

                {
                    int tp = 0, fp = 0;
                    for (int i = 0; i < n; ++i)
                    {
                        bool same = true;
                        for (int j = 1; j < prob.Length; ++j)
                        {
                            if (p[1, i] != p[j + 1, i])
                            {
                                same = false;
                                break;
                            }
                        }
                        if (same)
                        {
                            if (p[1, i] == p[0, i])
                                tp++;
                            else
                                fp++;
                        }
                    }
                    double p1 = (double)tp / (tp + fp);

                    sump += p1;
                    ps.Add(p1);
                }
            }

            double ret = sump / ps.Count;

            using (StreamWriter sw = new StreamWriter("c:\\test.txt"))
            {
                foreach (var i in ps)
                    sw.WriteLine(i);
            }
        }
        public static void ReorderEaOrderTxt(string inputFile, string outputFile, int nHour = 1)
        {
            SortedDictionary<DateTime, List<string>> dict = new SortedDictionary<DateTime, List<string>>();
            using (StreamReader sr = new StreamReader(inputFile))
            {
                while (!sr.EndOfStream)
                {
                    string s = sr.ReadLine();
                    string[] ss = s.Split(',');
                    DateTime date = Convert.ToDateTime(ss[1]);
                    if (!dict.ContainsKey(date))
                        dict[date] = new List<string>();
                    dict[date].Add(s);
                }
            }

            using (StreamWriter sw = new StreamWriter(outputFile))
            {
                foreach (var kvp in dict)
                {
                    if (kvp.Key.Hour % nHour != 0)
                        continue;
                    for (int i = 0; i < kvp.Value.Count; ++i )
                    {
                        string oldDate = kvp.Key.ToString(Parameters.DateTimeFormat);
                        string newDate = kvp.Key.AddMinutes(i).ToString(Parameters.DateTimeFormat);
                        sw.WriteLine(kvp.Value[i].Replace(oldDate, newDate));
                    }
                }
            }
        }
       
        
        public static void GenerateCandidateClassifierSeq(string fileName)
        {
            Dictionary<string, List<int>> dict = new Dictionary<string, List<int>>();
            using (StreamReader sr = new StreamReader(fileName))
            {
                while (true)
                {
                    if (sr.EndOfStream)
                        break;
                    string s = sr.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        continue;
                    if (s.Contains("Candidate Classifier:"))
                    {
                        System.Text.RegularExpressions.Regex r = new System.Text.RegularExpressions.Regex(".*Candidate Classifier: N=(.*),TrN=.*,TeN=.*,TC=.*,TD=.*, TDP=(.*)");
                        var match = r.Match(s);
                        if (match.Success)
                        {
                            string name = match.Groups[1].Value;
                            int num = Convert.ToInt32(match.Groups[2].Value);
                            if (!dict.ContainsKey(name))
                                dict[name] = new List<int>();
                            dict[name].Add(num);
                        }
                    }
                }
            }
            using (StreamWriter sw = new StreamWriter("c:\\GenerateCandidateClassifierSeq.txt"))
            {
                foreach (var kvp in dict)
                {
                    sw.Write(kvp.Key);
                    sw.Write(":");
                    foreach (var i in kvp.Value)
                    {
                        sw.Write(i);
                        sw.Write(",");
                    }
                    sw.WriteLine();

                    for (int i = 0; i < kvp.Value.Count - 1; ++i)
                    {
                        WekaUtils.DebugAssert(kvp.Value[i] <= kvp.Value[i + 1], "");
                    }
                }
            }
        }

        public static void PrintDealInfoSum(DateTime date)
        {
            string sql = ("SELECT Time, ClsName, TestResult, ClassValue, DealsInfo, DealsData FROM TestData WHERE [Time] >= @Time1 AND [Time] < @Time2 ORDER BY Time, ClsName");

            SqlCommand cmd = new SqlCommand(string.Format(sql));
            cmd.Parameters.AddWithValue("@Time1", WekaUtils.GetTimeFromDate(date));
            cmd.Parameters.AddWithValue("@Time2", WekaUtils.GetTimeFromDate(date.AddDays(1)));

            var dt = DbHelper.Instance.ExecuteDataTable(cmd);
            StringBuilder sb = new StringBuilder();
            foreach (System.Data.DataRow row in dt.Rows)
            {
                var clsInfo = new CandidateClassifier(row["ClsName"].ToString(), 0, 0, 'B', -1, null);

                clsInfo.SetData((string)row["TestResult"], (string)row["ClassValue"], (byte[])row["DealsInfo"], (byte[])row["DealsData"]);
                string s = clsInfo.Deals.PrintAll();
                sb.AppendLine(clsInfo.Name);
                sb.AppendLine(s);
            }
            Console.WriteLine(sb.ToString());
            Console.ReadLine();
        }
        public static void PrintDealInfoDetail(string clsInfoName, DateTime date)
        {
            string sql = ("SELECT Time, ClsName, TestResult, ClassValue, DealsInfo, DealsData FROM TestData WHERE [Time] = @Time AND ClsName = @ClsName");

            SqlCommand cmd = new SqlCommand(string.Format(sql));
            cmd.Parameters.AddWithValue("@Time", WekaUtils.GetTimeFromDate(date));
            cmd.Parameters.AddWithValue("@ClsName", clsInfoName);

            var dt = DbHelper.Instance.ExecuteDataTable(cmd);
            var row = dt.Rows[0];
            var clsInfo = new CandidateClassifier(clsInfoName, 0, 0, 'B', -1, null);

            clsInfo.SetData((string)row["TestResult"], (string)row["ClassValue"], (byte[])row["DealsInfo"], (byte[])row["DealsData"]);
            string s = clsInfo.Deals.PrintAll(true);
            Console.WriteLine(s);
            Console.ReadLine();
        }

        public static void CheckMtSimuResultWithHpDb()
        {
            Dictionary<string, Tuple<byte[, ,], long[, ,]>> hps = new Dictionary<string, Tuple<byte[, ,], long[, ,]>>();

            string sql = string.Format("SELECT * FROM EURUSD_HP WHERE TIME > {0} AND TIME < {1} AND TIME % 1800 = 0 AND TP % 20 = 0 AND SL % 20 = 0 ORDER BY TIME, DEALTYPE, TP, SL",
                WekaUtils.GetTimeFromDate(new DateTime(2009, 1, 1)), WekaUtils.GetTimeFromDate(new DateTime(2010, 1, 1)));

            DbHelper.Instance.ExecuteDataTable(sql, (row) =>
            {
                DateTime date = WekaUtils.GetDateFromTime((long)row["Time"]);
                // 
                string srcFile = string.Format("C:\\ProgramData\\MetaQuotes\\Terminal\\Common\\Files\\SimuResult\\{0}\\{1}\\{2}\\{3}\\{4}\\20_20_30.20_20_30.sim",
                    date.Year, date.Month, date.Day, date.Hour, date.Minute);
                byte[, ,] hp;
                long[, ,] hpTime;
                if (!hps.ContainsKey(srcFile))
                {
                    int tp_count_1 = 30, sl_count_1 = 30;
                    hp = new byte[2, tp_count_1, sl_count_1];
                    hpTime = new long[2, tp_count_1, sl_count_1];
                    using (BinaryReader br = new BinaryReader(new FileStream(srcFile, FileMode.Open)))
                    {
                        for (int k = 0; k < 2; ++k)
                            for (int i = 0; i < tp_count_1; ++i)
                                for (int j = 0; j < sl_count_1; ++j)
                                {
                                    byte n = br.ReadByte();
                                    long time = br.ReadInt64();

                                    long time2 = 0;
                                    byte[] buffer = new byte[8];
                                    for (int kk = 0; kk < 8; ++kk)
                                    {
                                        //buffer[7 - k] = (byte)(time >> (k * 8));
                                        buffer[kk] = (byte)(time >> (kk * 8));
                                    }
                                    for (int kk = 0; kk < 8; ++kk)
                                    {
                                        time2 <<= 8;
                                        time2 ^= buffer[kk] & 0xFF;
                                    }

                                    var d = WekaUtils.GetDateFromTime(time2);
                                    hp[k, i, j] = n;
                                    hpTime[k, i, j] = time2;
                                }

                        hps[srcFile] = new Tuple<byte[, ,], long[, ,]>(hp, hpTime);
                    }
                }
                hp = hps[srcFile].Item1;
                hpTime = hps[srcFile].Item2;
                if (row["Hp"] == System.DBNull.Value)
                    return;

                int dealType = row["DealType"].ToString() == "B" ? 0 : 1;
                int tp = (short)row["Tp"] / 20 - 1;
                int sl = (short)row["Sl"] / 20 - 1;
                int hpDb = (byte)row["Hp"];
                if (hpDb == 1)
                    hpDb = 2;

                DateTime hpTimeDb = (DateTime)row["hp_date"];
                try
                {
                    if (hp[dealType, tp, sl] != hpDb || WekaUtils.GetDateFromTime(hpTime[dealType, tp, sl]) != hpTimeDb)
                    {
                        if (hp[dealType, tp, sl] != hpDb)
                        {
                            System.Console.WriteLine(string.Format("Big different at {0}, {1}, {2}, {3}", date.ToString(), dealType, tp, sl));

                            //DateTime? closeDate;
                            //bool? hpStrategy;
                            //TpSlM1SimulateStrategy strategy = new TpSlM1SimulateStrategy("EURUSD", (tp + 1)* 20 * 0.0001, (sl + 1) * 20 * 0.0001);
                            //if (dealType == 0)
                            //    hpStrategy = strategy.DoBuy(date, -1, out closeDate);
                            //else
                            //    hpStrategy = strategy.DoSell(date, -1, out closeDate);

                            //int hpStrategy2 = hpStrategy.HasValue && hpStrategy.Value ? 2 : 0;
                            //if (hpStrategy2 != hpDb)
                            //{
                            //}
                        }
                        else
                        {
                            //System.Console.WriteLine(string.Format("different at {0}, {1}, {2}, {3}", date.ToString(), dealType, tp, sl));
                        }
                    }
                }
                catch (Exception)
                {
                }
            });
        }
        public static void CheckMtSimuResult(string srcDir)
        {
            foreach (var file in System.IO.Directory.GetFiles(srcDir, "*.*", SearchOption.AllDirectories))
            {
                string sfile = file;// srcDir + "\\2009\\4\\3\\23\\0\\20_20_30.20_20_30.sim";
                using (BinaryReader br = new BinaryReader(new FileStream(sfile, FileMode.Open)))
                {
                    while (true)
                    {
                        try
                        {
                            byte n = br.ReadByte();
                            byte[] buffer = new byte[8];
                            for (int i = 0; i < 8; ++i)
                                buffer[i] = br.ReadByte();

                            long time2 = 0;
                            for (int k = 0; k < 8; ++k)
                            {
                                time2 <<= 8;
                                time2 ^= buffer[k] & 0xFF;
                            }
                            DateTime date = WekaUtils.GetDateFromTime(time2);
                            if (n != 0 && n != 2 || date < new DateTime(1995, 1, 1))
                            {
                                System.Console.WriteLine(file);
                                break;
                            }
                        }
                        catch (System.IO.EndOfStreamException)
                        {
                            break;
                        }
                    }
                }
            }
        }

        public static void ConvertMtSimuResultIntToByte(string srcDir, string destDir)
        {
            foreach (var file in System.IO.Directory.GetFiles(srcDir))
            {
                string newFile = Path.GetFileNameWithoutExtension(file) + ".10.10.sim";
                newFile = Path.Combine(destDir, newFile);
                using (BinaryWriter bw = new BinaryWriter(new FileStream(newFile, FileMode.CreateNew)))
                {
                    using (BinaryReader br = new BinaryReader(new FileStream(file, FileMode.Open)))
                    {
                        while (true)
                        {
                            try
                            {
                                int n = br.ReadInt32();
                                bw.Write((byte)n);
                            }
                            catch (System.IO.EndOfStreamException)
                            {
                                break;
                            }
                        }
                    }
                }
            }
        }

        public static void ConverttMtSimuResultToPerhourData()
        {
            foreach (var datFile in System.IO.Directory.GetFiles("E:\\Forex\\mtData"))
            {
                string fileName = Path.GetFileName(datFile);
                string timeFile = Path.Combine("D:\\Program Files\\MetaTrader 5\\tester\\Agent-127.0.0.1-3000\\MQL5\\Files", fileName);

                List<DateTime> times = new List<DateTime>();

                using (BinaryReader br2 = new BinaryReader(new FileStream(timeFile, FileMode.Open)))
                {
                    while (true)
                    {
                        try
                        {
                            long n = br2.ReadInt64();
                            DateTime date = WekaUtils.GetDateFromTime(n);

                            times.Add(date);
                        }

                        catch (System.IO.EndOfStreamException)
                        {
                            break;
                        }
                    }
                }

                byte[,] d = new byte[times.Count, 200];
                using (BinaryReader br1 = new BinaryReader(new FileStream(datFile, FileMode.Open)))
                {
                    while (true)
                    {
                        try
                        {
                            for (int i = 0; i < 200; ++i)
                                for (int j = 0; j < times.Count; ++j)
                                    d[j, i] = br1.ReadByte();
                        }
                        catch (System.IO.EndOfStreamException)
                        {
                            break;
                        }
                    }
                }

                for (int j = 0; j < times.Count; ++j)
                {
                    DateTime date = times[j];
                    string newFile = "E:\\Forex\\mtData1\\" + date.Year + "\\" + date.Month + "\\" + date.Day + "\\" + date.Hour + "\\" + date.Minute + "\\10.10.sim";
                    if (File.Exists(newFile))
                    {
                        using (BinaryReader br3 = new BinaryReader(new FileStream(newFile, FileMode.Open)))
                        {
                            for (int i = 0; i < 200; ++i)
                            {
                                byte b = br3.ReadByte();
                                WekaUtils.DebugAssert(d[j, i] == b, "");
                            }
                        }

                    }
                    else
                    {
                        Feng.Utils.IOHelper.TryCreateDirectory(newFile);
                        using (BinaryWriter bw = new BinaryWriter(new FileStream(newFile, FileMode.CreateNew)))
                        {
                            for (int i = 0; i < 200; ++i)
                                bw.Write(d[j, i]);
                        }
                    }
                }
            }
        }

        public static void GenerateMtSimuData()
        {
            int tp_start_1 = 20, tp_delta_1 = 20, tp_count_1 = 30;
            int sl_start_1 = 20, sl_delta_1 = 20, sl_count_1 = 30;
            int tp_start_2 = 20, tp_delta_2 = 20, tp_count_2 = 20;
            int sl_start_2 = 20, sl_delta_2 = 20, sl_count_2 = 20;

            string srcFileName = string.Format("{0}_{1}_{2}.{3}_{4}_{5}.sim", tp_start_1, tp_delta_1, tp_count_1, sl_start_1, sl_delta_1, sl_count_1);
            string destFileName = string.Format("{0}_{1}_{2}.{3}_{4}_{5}.sim", tp_start_2, tp_delta_2, tp_count_2, sl_start_2, sl_delta_2, sl_count_2);
            byte[, ,] hp = new byte[2, tp_count_1, sl_count_1];
            long[, ,] hpTime = new long[2, tp_count_1, sl_count_1];
            byte[, ,] hp2 = new byte[2, tp_count_2, sl_count_2];
            long[, ,] hpTime2 = new long[2, tp_count_2, sl_count_2];

            foreach (string srcFile in System.IO.Directory.GetFiles("C:\\ProgramData\\MetaQuotes\\Terminal\\Common\\Files\\SimuResult", srcFileName, SearchOption.AllDirectories))
            {
                string destFile = Path.GetDirectoryName(srcFile) + "\\" + destFileName;
                using (BinaryReader br = new BinaryReader(new FileStream(srcFile, FileMode.Open)))
                {
                    for (int k = 0; k < 2; ++k)
                        for (int i = 0; i < tp_count_1; ++i)
                            for (int j = 0; j < sl_count_1; ++j)
                            {
                                byte n = br.ReadByte();
                                long time = br.ReadInt64();

                                long time2 = 0;
                                byte[] buffer = new byte[8];
                                for (int kk = 0; kk < 8; ++kk)
                                {
                                    //buffer[7 - k] = (byte)(time >> (k * 8));
                                    buffer[kk] = (byte)(time >> (kk * 8));
                                }
                                for (int kk = 0; kk < 8; ++kk)
                                {
                                    time2 <<= 8;
                                    time2 ^= buffer[kk] & 0xFF;
                                }
                                DateTime date = WekaUtils.GetDateFromTime(time2);

                                hp[k, i, j] = n;
                                hpTime[k, i, j] = time2;
                            }
                }

                for (int k = 0; k < 2; ++k)
                    for (int i = 0; i < tp_count_2; ++i)
                        for (int j = 0; j < sl_count_2; ++j)
                        {
                            hp2[k, i, j] = 0xFF;
                            hpTime2[k, i, j] = 0;
                        }

                for (int k = 0; k < 2; ++k)
                    for (int i = 0; i < tp_count_2; ++i)
                        for (int j = 0; j < sl_count_2; ++j)
                        {
                            int tp2 = tp_start_2 + i * tp_delta_2;
                            int sl2 = sl_start_2 + j * sl_delta_2;
                            int i1 = (tp2 - tp_start_1) / tp_delta_1;
                            int j1 = (sl2 - sl_start_1) / sl_delta_1;
                            hp2[k, i, j] = hp[k, i1, j1];
                            hpTime2[k, i, j] = hpTime[k, i1, j1];
                        }

                using (BinaryWriter bw = new BinaryWriter(new FileStream(destFile, FileMode.Create)))
                {
                    for (int k = 0; k < 2; ++k)
                        for (int i = 0; i < tp_count_2; ++i)
                            for (int j = 0; j < sl_count_2; ++j)
                            {
                                bw.Write(hp2[k, i, j]);
                                bw.Write(hpTime2[k, i, j]);
                            }
                }
            }
        }
        #endregion

        public static void ParseDetailDealLog(string fileName)
        {
            string[] inputFiles = new string[] { string.Format("\\\\192.168.0.10\\f$\\Forex\\TestDebug\\console.{0}.txt", fileName) };
            //string[] inputFiles = new string[] { string.Format("f:\\Forex\\Data\\{0}.txt", fileName) };
            string outputFile = TestParameters.GetBaseFilePath(string.Format("{0}_ccScores_w{1}.txt", 
                TestParameters2.CandidateParameter.MainSymbol, TestParameters2.lastWeek));

            if (System.IO.File.Exists(outputFile)) 
                return;

            //string symbol = "GBPUSD";
            //int tpMinDelta = TestParameters.GetTpMinDelta(symbol);
            //int slMinDelta = TestParameters.GetSlMinDelta(symbol);

            int dealTpCount = 15;
            int dealSlCount = 15;
            int tpDelta = 600 / dealTpCount;
            int slDelta = 600 / dealSlCount;

            //int n = TestParameters2.nTpsl;

            int tpStart = TestParameters2.tpStart;
            int slStart = TestParameters2.slStart;
            int tpCount = TestParameters2.tpCount;
            int slCount = TestParameters2.slCount;


            using (StreamWriter sw = new StreamWriter(outputFile))
            {
                foreach (string inputFile in inputFiles)
                {
                    using (StreamReader sr = new StreamReader(inputFile))
                    {
                        System.Text.RegularExpressions.Regex rResult = new System.Text.RegularExpressions.Regex(
                            string.Format("(.*?)TR:TTP=(.*?),TFP=(.*?),NC.*"), System.Text.RegularExpressions.RegexOptions.Compiled);
                        System.Text.RegularExpressions.Regex rBest = new System.Text.RegularExpressions.Regex(
                            "Best Classifier: N=(.*?),TC=(.*?),TP=(.*?),FP=(.*?),TD=(.*?),TV=(.*?)", System.Text.RegularExpressions.RegexOptions.Compiled);
                        System.Text.RegularExpressions.Regex rCC = new System.Text.RegularExpressions.Regex(
                            string.Format("CC:N=(.*?),TrN=(.*?),TeN=(.*?),NC=(.*?),NTP=(.*?),NFP=(.*?),NDA=(.*?),NDS=(.*?),TD=(.*?),TV=(.*?),(.*?)"),
                            System.Text.RegularExpressions.RegexOptions.Compiled);

                        double[, ,] scores = new double[2, dealTpCount, dealSlCount];
                        long[, ,] ndas = new long[2, dealTpCount, dealSlCount];
                        long[, ,] ndss = new long[2, dealTpCount, dealSlCount];

                        DateTime currentDate = DateTime.MinValue;
                        string bestClassifier = string.Empty;
                        double bestNc = 0;

                        int ccCount = 0;
                        while (true)
                        {
                            if (sr.EndOfStream)
                                break;

                            string s = sr.ReadLine();
                            if (string.IsNullOrEmpty(s))
                                continue;
                            if (s.StartsWith("Now is"))
                            {
                                DateTime date = Convert.ToDateTime(s.Substring(7, 19));
                                if (date > System.DateTime.Now)
                                    return;

                                Console.WriteLine(s);
                                currentDate = date;
                                ccCount = 0;
                            }
                            else if (s.StartsWith("CC:"))
                            {
                                if (ccCount >= scores.Length)
                                    continue;

                                var match = rCC.Match(s);
                                WekaUtils.DebugAssert(match.Success, "");

                                string[] ss = match.Groups[1].Value.Split('_');
                                int tpi =  Convert.ToInt32(ss[1]) / tpDelta - 1;
                                int sli =  Convert.ToInt32(ss[2]) / slDelta - 1;
                                if (ss[0] == "B")
                                {
                                    scores[0, tpi, sli] = Convert.ToDouble(match.Groups[4].Value);
                                    ndas[0, tpi, sli] = Convert.ToInt32(match.Groups[7].Value);
                                    ndss[0, tpi, sli] = Convert.ToInt32(match.Groups[8].Value);
                                }
                                else
                                {
                                    scores[1, tpi, sli] = Convert.ToDouble(match.Groups[4].Value);
                                    ndas[1, tpi, sli] = Convert.ToInt32(match.Groups[7].Value);
                                    ndss[1, tpi, sli] = Convert.ToInt32(match.Groups[8].Value);
                                }
                                ccCount++;
                            }
                            else if (s.StartsWith("Best Classifier: "))
                            {
                                var match = rBest.Match(s);
                                WekaUtils.DebugAssert(match.Success, "");
                                bestClassifier = match.Groups[1].Value;
                                bestNc = Convert.ToDouble(match.Groups[2].Value);
                            }
                            else if (s.Contains("-TR"))
                            {
                                if (ccCount != 2 * dealTpCount * dealSlCount)
                                    continue;
                                ccCount = 0;

                                if (currentDate.Hour % TestParameters2.MainPeriodOfHour != 0)
                                    continue;

                                if (string.IsNullOrEmpty(bestClassifier))
                                {
                                    bestClassifier = "B_0_0";
                                    bestNc = 0;
                                }

                                var match = rResult.Match(s);
                                WekaUtils.DebugAssert(match.Success, "");

                                //DateTime dayDate = new DateTime(currentDate.Year, currentDate.Month, currentDate.Day);
                                //var row = Feng.Data.DbHelper.Instance.ExecuteDataRow(string.Format("SELECT ATR_14 FROM EURUSD_D1 WHERE Time = '{0}'",
                                //    WekaUtils.GetTimeFromDate(dayDate)));
                                //if (row == null)
                                //    continue;

                                sw.Write(currentDate.ToString(Parameters.DateTimeFormat));
                                sw.Write(", ");

                                //sw.Write((int)currentDate.DayOfWeek);
                                //sw.Write(", ");
                                //sw.Write(currentDate.Hour);
                                //sw.Write(", ");

                                //sw.Write(row[0].ToString());
                                //sw.Write(", ");

                                sw.Write(bestClassifier);
                                sw.Write(", ");
                                sw.Write((int)bestNc);
                                sw.Write(", ");

                                int tpc = Convert.ToInt32(match.Groups[2].Value);
                                int fpc = Convert.ToInt32(match.Groups[3].Value);
                                //sw.WriteLine(tp == 2 ? "1" : "0");
                                sw.Write(tpc);
                                sw.Write(", ");
                                sw.Write(fpc);
                                sw.Write(", ");

                                string[] ss = bestClassifier.Split(new char[] { '_' });
                                int tp = Convert.ToInt32(ss[1]);
                                int sl = Convert.ToInt32(ss[2]);
                                sw.Write(-tp * tpc + sl * fpc);
                                sw.Write(", ");

                                for (int k = 0; k < 2; ++k)
                                {
                                    for (int i = tpStart; i < tpCount; ++i)
                                    {
                                        for (int j = slStart; j < slCount; ++j)
                                        {
                                            WekaUtils.DebugAssert(scores[k, i * dealTpCount / tpCount, j * dealSlCount / slCount] != -1, "");

                                            sw.Write(scores[k, i * dealTpCount / tpCount, j * dealSlCount / slCount].ToString());
                                            if (j != slCount - 1)
                                            {
                                                sw.Write(",");
                                            }
                                        }
                                        sw.Write(",");
                                    }
                                    sw.Write(",");
                                }

                                for (int k = 0; k < 2; ++k)
                                {
                                    for (int i = tpStart; i < tpCount; ++i)
                                    {
                                        for (int j = slStart; j < slCount; ++j)
                                        {
                                            sw.Write(ndas[k, i * dealTpCount / tpCount, j * dealSlCount / slCount].ToString());
                                            if (j != slCount - 1)
                                            {
                                                sw.Write(",");
                                            }
                                        }
                                        sw.Write(",");
                                    }
                                    sw.Write(",");
                                }

                                for (int k = 0; k < 2; ++k)
                                {
                                    for (int i = tpStart; i < tpCount; ++i)
                                    {
                                        for (int j = slStart; j < slCount; ++j)
                                        {
                                            sw.Write(ndss[k, i * dealTpCount / tpCount, j * dealSlCount / slCount].ToString());
                                            if (j != slCount - 1)
                                            {
                                                sw.Write(",");
                                            }
                                        }
                                        sw.Write(",");
                                    }
                                    sw.Write(",");
                                }
                                sw.WriteLine();

                                for (int k = 0; k < 2; ++k)
                                {
                                    for (int i = 0; i < dealTpCount; ++i)
                                    {
                                        for (int j = 0; j < dealSlCount; ++j)
                                        {
                                            scores[k, i, j] = -1;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        public static void GenerateConsoleCCs()
        {
            System.Text.RegularExpressions.Regex r = new System.Text.RegularExpressions.Regex(
                            string.Format("CC:N=(.*),TrN=(.*),TeN=(.*),NC=(.*),NTP=(.*),NFP=(.*),TD=(.*),TV=(.*),(.*)"));

            using (StreamWriter sw = new StreamWriter("d:\\console_cc.csv"))
            {
                using (StreamReader sr = new StreamReader("d:\\console.2006-2009.txt"))
                {
                    double[, ,] scores = new double[2, 30, 30];
                    DateTime currentDate = DateTime.MinValue;
                    string summary = string.Empty;
                    string trStart = "CC:";
                    while (true)
                    {
                        if (sr.EndOfStream)
                            break;

                        string s = sr.ReadLine();
                        if (string.IsNullOrEmpty(s))
                            continue;
                        if (s.StartsWith("Now is"))
                        {
                            if (currentDate != DateTime.MinValue)
                            {
                                for (int k = 0; k < 2; ++k)
                                {
                                    for (int i = 0; i < scores.GetLength(1); ++i)
                                    {
                                        for (int j = 0; j < scores.GetLength(2); ++j)
                                        {
                                            sw.Write(scores[k, i, j].ToString(Parameters.DoubleFormatString));
                                            if (j != scores.GetLength(1) - 1)
                                            {
                                                sw.Write(",");
                                            }
                                        }
                                        sw.WriteLine();
                                    }
                                    sw.WriteLine();
                                }
                                sw.WriteLine(currentDate.ToString(Parameters.DateTimeFormat));
                                sw.WriteLine(summary);
                                sw.WriteLine();
                                sw.WriteLine();
                            }
                            DateTime date = Convert.ToDateTime(s.Substring(7, 19));
                            currentDate = date;
                            summary = string.Empty;
                        }
                        else if (s.StartsWith(trStart))
                        {
                            var match = r.Match(s);
                            WekaUtils.DebugAssert(match.Success, "");
                            double cost = Convert.ToDouble(match.Groups[4].Value);

                            string[] ss = match.Groups[1].Value.Split('_');
                            if (ss[0] == "B")
                            {
                                scores[0, Convert.ToInt32(ss[1]) / 20 - 1, Convert.ToInt32(ss[2]) / 20 - 1] = cost;
                            }
                            else
                            {
                                scores[1, Convert.ToInt32(ss[1]) / 20 - 1, Convert.ToInt32(ss[2]) / 20 - 1] = cost;
                            }
                        }
                        else if (s.StartsWith("Best Classifier:"))
                        {
                            summary += s;
                            summary += System.Environment.NewLine;
                        }
                        else if (s.StartsWith("2M_20"))
                        {
                            summary += s;
                        }
                    }
                }
            }
        }

        public static void GenerateTpslWekaTrainFile(string inputFile, string outputFile)
        {
            for (int i = 0; i < 23; ++i)
            {
                int testHour = i;
                string hourString = "_H" + i.ToString();

                using (StreamWriter sw = new StreamWriter(outputFile + hourString + ".arff"))
                {
                    sw.WriteLine("@relation Tpsl");
                    sw.WriteLine("@attribute timestamp date \"yyyy-MM-dd\'T\'HH:mm:ss\"");
                    for (int k = 0; k < 2 * 20 * 20; ++k)
                        sw.WriteLine(string.Format("@attribute V{0} numeric", k + 1));
                    sw.WriteLine("@attribute prop {0,1}");
                    sw.WriteLine();
                    sw.WriteLine("@data");

                    using (StreamReader sr = new StreamReader(inputFile))
                    {
                        System.Text.RegularExpressions.Regex r = new System.Text.RegularExpressions.Regex(
                            string.Format("CC:N=(.*){0},TrN=(.*),TeN=(.*),NC=(.*),NTP=(.*),NFP=(.*),TD=(.*),TV=(.*),Cls=(.*),MM=(.*)", hourString));

                        DateTime currentDate = DateTime.MinValue;
                        while (true)
                        {
                            if (sr.EndOfStream)
                                break;

                            string s = sr.ReadLine();
                            if (string.IsNullOrEmpty(s))
                                continue;
                            if (s.StartsWith("Now is"))
                            {
                                DateTime date = Convert.ToDateTime(s.Substring(7, 19));
                                if (date.Hour == testHour)
                                {
                                    if (currentDate != DateTime.MinValue)
                                    {
                                        // get hp in db
                                        var row = Feng.Data.DbHelper.Instance.ExecuteDataRow(string.Format("SELECT Hp FROM EURUSD_HP WHERE DealType = '{0}' AND Tp = '{1}' AND Sl = '{2}' AND Time = '{3}'",
                                            "B", 100, 100, WekaUtils.GetTimeFromDate(currentDate)));
                                        sw.WriteLine(row[0].ToString());
                                    }
                                    if (date > System.DateTime.Now)
                                        continue;

                                    currentDate = date;
                                    sw.Write(currentDate.ToString(Parameters.DateTimeFormat));
                                    sw.Write(",");
                                }
                            }

                            string trStart = "CC:";
                            if (s.StartsWith(trStart) && s.Contains(hourString + ","))
                            {
                                var match = r.Match(s);
                                if (match.Success)
                                {
                                    double cost = Convert.ToDouble(match.Groups[4].Value);
                                    sw.Write(cost.ToString());
                                    sw.Write(", ");
                                }
                                else
                                {
                                    throw new AssertException(s);
                                }
                            }
                        }
                    }
                }
            }
        }
        public static void ConvertHpAccordCloseTime()
        {
            Instances instances = WekaUtils.LoadInstances("f:\\forex\\a.arff");

            int n = TestParameters.TpMaxCount;
            using (StreamWriter sw = new StreamWriter("f:\\forex\\b.arff"))
            {
                sw.WriteLine("@relation 'openTimeAccordCloseTime'");
                sw.WriteLine("@attribute timestamp date \"yyyy-MM-dd\'T\'HH:mm:ss\"");
                sw.WriteLine("@attribute hpdate date \"yyyy-MM-dd\'T\'HH:mm:ss\"");
                for (int j = 0; j < 2 * n * n; ++j)
                {
                    //if (j % 2 != 0)
                    //    continue;
                    sw.WriteLine(string.Format("@attribute p{0}", j) + " {0,1,-1}");
                }
                sw.WriteLine("@attribute prop " + " {0,1}");
                sw.WriteLine("@data");
                sw.WriteLine();

                WekaUtils.DebugAssert(instances.numAttributes() == 2 * n * n + 2 + 1, "");

                for (int i = 0; i < instances.numInstances(); ++i)
                {
                    for (int j = 0; j < 2; ++j)
                    {
                        sw.Write(WekaUtils.GetDateValueFromInstances(instances, j, i).ToString(Parameters.DateTimeFormat));
                        sw.Write(",");
                    }
                    for (int j = 2; j < 2 * n * n + 2; ++j)
                    {
                        //if (j % 2 != 0)
                        //    continue;
                        double v = instances.instance(i).value(j);
                        sw.Write(Math.Sign(v));
                        sw.Write(",");
                    }
                    sw.WriteLine((int)(instances.instance(i).classValue()));
                }
            }
        }
        public static void GenerateHpAccordCloseTime(string symbol, string period)
        {
            int n = TestParameters.TpMaxCount;
            long[, ,] openTimes = new long[2, n, n];
            DateTime date = new DateTime(2000, 1, 1);

            var hps = HpData.Instance.GetHpSum(symbol, period);

            DateTime lastSaveTime = DateTime.MinValue;
            List<Tuple<long, long, int, int, int, int>> list = new List<Tuple<long, long, int, int, int, int>>();

            string fileName = "f:\\forex\\a.arff";

            using (StreamWriter sw = new StreamWriter(fileName))
            {
                sw.WriteLine("@relation 'openTimeAccordCloseTime'");
                sw.WriteLine("@attribute timestamp date \"yyyy-MM-dd\'T\'HH:mm:ss\"");
                sw.WriteLine("@attribute hpdate date \"yyyy-MM-dd\'T\'HH:mm:ss\"");
                for(int i = 0;i<2*n*n; ++i)
                    sw.WriteLine(string.Format("@attribute p{0} numeric", i));
                sw.WriteLine("@attribute prop " + " {0,1}");
                sw.WriteLine("@data");
                sw.WriteLine();
            }
            while (true)
            {
                Console.WriteLine("Now is " + date);

                var nextBufferDate = date.AddMonths(1);
                var sql = string.Format("SELECT * FROM {0}_HP WHERE TIME >= '{1}' AND TIME < '{2}' AND TIME % 1800 = 0",
                                symbol, WekaUtils.GetTimeFromDate(date), WekaUtils.GetTimeFromDate(nextBufferDate));
                var allDt = Feng.Data.DbHelper.Instance.ExecuteDataTable(sql);
                if (allDt.Rows.Count == 0)
                    break;

                foreach (System.Data.DataRow row in allDt.Rows)
                {
                    long nowTime = (long)row["Time"];
                    sbyte?[, ,] hp = HpData.DeserializeHp((byte[])row["hp"]);
                    long?[, ,] hpTime = HpData.DeserializeHpTimes((byte[])row["hp_date"]);
                    for (int i = 0; i < hp.GetLength(0); ++i)
                        for (int j = 0; j < hp.GetLength(1); ++j)
                            for (int k = 0; k < hp.GetLength(2); ++k)
                            {
                                if (hp[i, j, k] == null)
                                    continue;
                                if (hp[i, j, k].Value == 1)
                                {
                                    list.Add(new Tuple<long, long, int, int, int, int>(hpTime[i, j, k].Value, nowTime, i, j, k, 1));
                                }
                                else if (hp[i, j, k].Value == 0)
                                {
                                    list.Add(new Tuple<long, long, int, int, int, int>(hpTime[i, j, k].Value, nowTime, i, j, k, 0));
                                }
                                else
                                {
                                    throw new AssertException("hp value should be 0 or 1.");
                                }
                            }
                }

                list.Sort(new Comparison<Tuple<long, long, int, int, int, int>>((x, y) =>
                {
                    if (x.Item1 != y.Item1)
                        return x.Item1.CompareTo(y.Item1);
                    else if (x.Item2 != y.Item2)
                        return x.Item2.CompareTo(y.Item2);
                    else if (x.Item3 != y.Item3)
                        return x.Item3.CompareTo(y.Item3);
                    else if (x.Item4 != y.Item4)
                        return x.Item4.CompareTo(y.Item4);
                    else if (x.Item5 != y.Item5)
                        return x.Item5.CompareTo(y.Item5);
                    else
                        return x.Item6.CompareTo(y.Item6);
                }));

                long nextTime = WekaUtils.GetTimeFromDate(nextBufferDate);
                long closeTime = list[0].Item1;
                
                for(int i=1;i<list.Count; ++i)
                {
                    var here = list[i];
                    if (here.Item1 >= nextTime)
                    {
                        list.RemoveRange(0, i);
                        break;
                    }
                    if (closeTime != here.Item1)
                    {
                        if (closeTime != -1)
                        {
                            int h = 3600 * 24;
                            DateTime d = WekaUtils.GetDateFromTime(closeTime / h * h);
                            if (hps.ContainsKey(d))
                            {
                                if (d != lastSaveTime && lastSaveTime != DateTime.MinValue)
                                {
                                    // save
                                    using (StreamWriter sw = new StreamWriter(fileName, true))
                                    {
                                        sw.Write(string.Format("{0},{1},", WekaUtils.GetDateFromTime(closeTime).ToString(Parameters.DateTimeFormat),
                                            WekaUtils.GetDateFromTime(hps[d].Item2).ToString(Parameters.DateTimeFormat)));

                                        for (int i1 = 0; i1 < openTimes.GetLength(0); ++i1)
                                            for (int j = 0; j < openTimes.GetLength(1); ++j)
                                                for (int k = 0; k < openTimes.GetLength(2); ++k)
                                                {
                                                    if (openTimes[i1, j, k] != 0)
                                                    {
                                                        long deltaTime = closeTime - Math.Abs(openTimes[i1, j, k]);
                                                        var x = deltaTime / 60.0 / 60.0;
                                                        //double v = Math.Exp(x);
                                                        var v = x;
                                                        if (openTimes[i1, j, k] < 0)
                                                            v = -v;
                                                        sw.Write(v.ToString("F2"));
                                                    }
                                                    else
                                                    {
                                                        sw.Write("0");
                                                    }
                                                    sw.Write(",");
                                                }
                                        sw.WriteLine(hps[d].Item1);

                                    }
                                }
                                lastSaveTime = d;
                            }
                        }

                        closeTime = here.Item1;
                    }

                    {
                        WekaUtils.DebugAssert(here.Item1 == closeTime, "");
                        long v = here.Item2;
                        if (here.Item6 == 0)
                            v = -v;
                        openTimes[here.Item3, here.Item4, here.Item5] = v;
                    }
                }

                date = nextBufferDate;
            }
        }

        public static void GenerateHpAccordCloseTime2(string symbol)
        {
            List<Tuple<long, long, int, int, int>> list = new List<Tuple<long, long, int, int, int>>();
            DateTime date = new DateTime(2000, 1, 1);
            var nextBufferDate = date.AddYears(1);
            var sql = string.Format("SELECT * FROM {0}_HP WHERE TIME >= '{1}' AND TIME < '{2}' AND TIME % 1800 = 0",
                                symbol, WekaUtils.GetTimeFromDate(date), WekaUtils.GetTimeFromDate(nextBufferDate));
            var allDt = Feng.Data.DbHelper.Instance.ExecuteDataTable(sql);
            foreach (System.Data.DataRow row in allDt.Rows)
            {
                long nowTime = (long)row["Time"];
                sbyte?[, ,] hp = HpData.DeserializeHp((byte[])row["hp"]);
                long?[, ,] hpTime = HpData.DeserializeHpTimes((byte[])row["hp_date"]);
                for(int i=0; i<hp.GetLength(0); ++i)
                    for(int j=0; j<hp.GetLength(1); ++j)
                        for (int k = 0; k < hp.GetLength(2); ++k)
                        {
                            if (hp[i, j, k] == null)
                                continue;
                            if (hp[i, j, k].Value == 1)
                            {
                                list.Add(new Tuple<long, long, int, int, int>(hpTime[i, j, k].Value, nowTime, i, j, k));
                            }
                            else if (hp[i, j, k].Value == 0)
                            {
                            }
                            else
                            {
                                throw new AssertException("hp value should be 0 or 1.");
                            }
                        }
            }

            list.Sort(new Comparison<Tuple<long, long, int, int, int>>((x, y) =>
                {
                    return x.Item1.CompareTo(y.Item1);
                }));

            using (StreamWriter sw = new StreamWriter("f:\\forex\\a.txt"))
            {
                foreach (var i in list)
                {
                    sw.WriteLine(string.Format("{0}, {1}, {2}, {3}, {4}", WekaUtils.GetDateFromTime(i.Item1), WekaUtils.GetDateFromTime(i.Item2), i.Item3, i.Item4, i.Item5));
                }
            }
        }

        public static void GenerateSumByCloseTime(string symbol, string period)
        {
            int tpp = TestParameters.GetTpSlMinDelta(symbol) * TestParameters2.nTpsl;

            SortedDictionary<long, int[]> hpSumbyCloseTime = new SortedDictionary<long, int[]>();
            HpData.IterateHpData(symbol, period, (nowDate, j, k, l, hp, hpTime) =>
            {
                int sum;
                if (hp == 1)    // win
                {
                    sum = -(k + 1) * tpp;
                }
                else if (hp == 0)
                {
                    sum = (l + 1) * tpp;
                }
                else
                {
                    throw new ArgumentException("hp should be 0 or 1.");
                }
                if (!hpSumbyCloseTime.ContainsKey(hpTime))
                {
                    hpSumbyCloseTime[hpTime] = new int[2];
                    hpSumbyCloseTime[hpTime][0] = hpSumbyCloseTime[hpTime][1] = 0;
                }

                hpSumbyCloseTime[hpTime][j] += sum;
            });

            using (StreamWriter sw = new StreamWriter("d:\\a.txt"))
            {
                foreach (var kvp in hpSumbyCloseTime)
                {
                    int r = 2;
                    if (kvp.Value[0] < 0 && kvp.Value[1] >= 0)
                        r = 0;
                    else if (kvp.Value[1] < 0 && kvp.Value[0] >= 0)
                        r = 1;
                    sw.WriteLine(string.Format("{0}, {1}, {2}, {3}", WekaUtils.GetDateFromTime(kvp.Key).ToString(Parameters.DateTimeFormat),
                        kvp.Value[0], kvp.Value[1],
                        r));
                }
            }
        }
        public static void ConvertPrev2OrderTxt()
        {
            using (StreamReader sr = new StreamReader("d:\\a.txt"))
            using (StreamWriter sw = new StreamWriter("d:\\ea_order_EURUSD.txt"))
            {
                while (!sr.EndOfStream)
                {
                    string s = sr.ReadLine();
                    string[] ss = s.Split(',');
                    int a = Convert.ToInt32(ss[1]);
                    int b = Convert.ToInt32(ss[2]);

                    if (a < -5000 && b >= 0)
                        sw.WriteLine(string.Format("Sell, {0}, 40, 40, 0, 0, Unknown, Unknown", ss[0]));
                    else if (b <= -5000 && a >= 0)
                        sw.WriteLine(string.Format("Buy, {0}, 40, 40, 0, 0, Unknown, Unknown", ss[0]));
                }
            }
        }

        public static void GenerateHpDataToTxt2()
        {
            DateTime date = new DateTime(2006, 1, 1);
            DateTime maxDate = new DateTime(2012, 1, 1);
            string hpFileName = "d:\\hpdata.gbp.txt";
            using (StreamWriter sw = new StreamWriter(hpFileName))
            {
                while (true)
                {
                    System.Data.DataTable[] dts = new System.Data.DataTable[2];
                    string sql1 = string.Format("SELECT * FROM EURUSD_HP WHERE TIME >= '{0}' AND TIME < '{1}' AND TIME % 1800 = 0 AND TP % 20 = 0 AND SL % 20 = 0 AND DEALTYPE = 'B'",
                            WekaUtils.GetTimeFromDate(date), WekaUtils.GetTimeFromDate(date.AddDays(1)));
                    dts[0] = Feng.Data.DbHelper.Instance.ExecuteDataTable(sql1);
                    string sql2 = string.Format("SELECT * FROM EURUSD_HP WHERE TIME >= '{0}' AND TIME < '{1}' AND TIME % 1800 = 0 AND TP % 20 = 0 AND SL % 20 = 0 AND DEALTYPE = 'S'",
                        WekaUtils.GetTimeFromDate(date), WekaUtils.GetTimeFromDate(date.AddDays(1)));
                    dts[1] = Feng.Data.DbHelper.Instance.ExecuteDataTable(sql2);

                    if (dts[0].Rows.Count == 0 && dts[1].Rows.Count == 0)
                    {
                        date = date.AddDays(1);
                        if (date >= maxDate)
                            break;
                        continue;
                    }

                    sw.Write(date.ToString(Parameters.DateTimeFormat));
                    sw.Write(", ");

                    for (int i = 0; i < 2; ++i)
                    {
                        int[, ,] cost = new int[30, 30, 2];
                        foreach (System.Data.DataRow row in dts[i].Rows)
                        {
                            int tp = (short)(row["Tp"]);
                            int sl = (short)(row["Sl"]);

                            if (row["hp"] == System.DBNull.Value)
                            {
                                //cost[tp / 20 - 1, sl / 20 - 1] = -1;
                            }
                            else
                            {
                                int hp = Convert.ToInt32(row["hp"]);
                                if (hp == 1)
                                    cost[tp / 20 - 1, sl / 20 - 1, 0]++;
                                else if (hp == 0)
                                    cost[tp / 20 - 1, sl / 20 - 1, 1]++;
                                else
                                    throw new AssertException("hp value should be 0 or 1.");

                            }
                        }

                        for (int j = 0; j < cost.GetLength(0); ++j)
                            for (int k = 0; k < cost.GetLength(1); ++k)
                                sw.Write(cost[j, k, 0] + ", " + cost[j, k, 1] + ", ");
                    }
                    sw.WriteLine();

                    date = date.AddDays(1);
                    if (date >= maxDate)
                        break;
                }
            }
        }

        
    }
}
