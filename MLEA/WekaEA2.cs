using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Data.SqlClient;
using weka.core;
using weka.classifiers;
using java.io;
using MLEA;

namespace WekaEA
{
    public class WekaEA2
    {
        [System.Runtime.InteropServices.DllImport("kernel32.dll")]
        private static extern int AllocConsole();
        [System.Runtime.InteropServices.DllImport("kernel32.dll")]
        private static extern int FreeConsole();

        #region "Simulate"
        private static void SimulateMt(WekaEA2 ea, DateTime startDate, DateTime endDate, Feng.Data.DbHelper dbHelper)
        {
            long minTime = WekaUtils.GetTimeFromDate(startDate);
            long maxTime = WekaUtils.GetTimeFromDate(endDate);

            var dtD1 = dbHelper.ExecuteDataTable(string.Format("SELECT * FROM {0}_{3} WHERE TIME >= {1} AND TIME < {2} ORDER BY TIME", ea.m_symbol, minTime, maxTime, TestParameters2.CandidateParameter.MainPeriod));
            var dtM1 = dbHelper.ExecuteDataTable(string.Format("SELECT * FROM {0}_M1 WHERE TIME >= {1} AND TIME < {2} ORDER BY TIME", ea.m_symbol, minTime, maxTime));

            int idxD1 = 0;
            double[] pp = new double[TestParameters.CandidateParameter4Db.AllIndNames.Count + 6 + 5];

            for (int i = 0; i < dtM1.Rows.Count; ++i)
            {
                long nowTime = (long)dtM1.Rows[i]["Time"];
                FillPp(pp, dtM1.Rows[i]);
                ea.OnNewBar(nowTime, 60, pp);

                if (idxD1 >= dtD1.Rows.Count)
                    break;

                long nowD1Time = (long)dtD1.Rows[idxD1]["Time"];
                if (nowTime >= nowD1Time)
                {
                    FillPp(pp, dtD1.Rows[idxD1]);
                    ea.OnNewBar(nowD1Time, (int)(TestParameters2.MainPeriodOfHour * 60 * 60), pp);
                    idxD1++;
                }
            }
        }
        public static void SimulateMt(string symbol)
        {
            TestParameters2.RealTimeMode = true;
            TestParameters2.DBDataConsistent = false;
            TestParameters2.MinTrainSize = 1;

            //var X = WekaUtils.GetDateFromTime(949104000);

            WekaEA.WekaEA2 ea = new WekaEA.WekaEA2();
            ea.Init(symbol);

            var dbHelper = Feng.Data.DbHelper.CreateDatabase("Forex");
            //ea.UpdateHp(WekaUtils.GetTimeFromDate(new DateTime(2001, 4, 12)));
            SimulateMt(ea, TestParameters2.TrainStartTime, TestParameters2.TrainEndTime, dbHelper);

            ea.Deinit();
        }
        private static void FillPp(double[] pp, System.Data.DataRow row)
        {
            long nowTime = (long)row["Time"];
            DateTime nowDate = WekaUtils.GetDateFromTime(nowTime);
            pp[0] = nowTime;
            pp[1] = 0;
            pp[2] = nowDate.Hour / 24.0;
            pp[3] = (int)nowDate.DayOfWeek / 5.0;
            pp[4] = 0;
            pp[5] = 0;

            pp[6] = (double)row["close"];
            pp[7] = (double)row["open"];
            pp[8] = (double)row["high"];
            pp[9] = (double)row["low"];
            pp[10] = (int)row["spread"];

            if (row.Table.Columns["AMA_9_2_30"] == null)
            {
                for (int i = 11; i < pp.Length; ++i)
                    pp[i] = 0;
                return;
            }

            int n = 11;
            foreach (var kvp in TestParameters.CandidateParameter4Db.AllIndNames)
            {
                pp[n] = (double)row[kvp.Key];
                n++;
            }
        }
        #endregion

        #region "DB"
        private void ImportToDb(long nowTime1, double[] pp, string tableName, bool addIndicators = true)
        {
            Dictionary<string, int> inds = TestParameters.CandidateParameter4Db.AllIndNames;

            WekaUtils.DebugAssert(pp.Length == inds.Count + 6 + 5, string.Format("pp.Length == inds.Count + 6 + 5, {0}, {1}", pp.Length, inds.Count + 6 + 5));
            string sql = string.Format("IF NOT EXISTS (SELECT * FROM [{0}] WHERE TIME = @Time) INSERT INTO [{0}] ([Time],[date],[hour],[dayofweek],[open],[close],[high],[low],[spread]", tableName);
            if (addIndicators)
            {
                foreach (var kvp in inds)
                {
                    sql += ",[" + kvp.Key + "]";
                }
            }
            sql += ") VALUES (@Time, @date, @hour,@dayofweek,@open, @close,@high,@low,@spread";
            if (addIndicators)
            {
                foreach (var kvp in inds)
                {
                    sql += ",@" + kvp.Key;
                }
            }
            sql += ")";
            var cmd = new SqlCommand(sql);

            long newtime = (long)pp[0];
            DateTime newDate = WekaUtils.GetDateFromTime(newtime);

            if (newDate.DayOfWeek == DayOfWeek.Saturday)
            {
                WekaUtils.DebugAssert(newDate.Hour == 0, "Saturday hour should be 0.");
                WekaUtils.DebugAssert(newDate.Minute == 0, "Saturday Minute should be 0.");
                WekaUtils.DebugAssert(newDate.Second == 0, "Saturday Second should be 0.");
                newDate = newDate.AddDays(2);
                newtime = newtime + (long)(new TimeSpan(2, 0, 0, 0).TotalSeconds);
            }

            cmd.Parameters.AddWithValue("@time", newtime);
            cmd.Parameters.AddWithValue("@date", newDate);
            cmd.Parameters.AddWithValue("@hour", newDate.Hour);
            cmd.Parameters.AddWithValue("@dayofweek", newDate.DayOfWeek);
            cmd.Parameters.AddWithValue("@open", pp[7]);
            cmd.Parameters.AddWithValue("@close", pp[6]);
            cmd.Parameters.AddWithValue("@high", pp[8]);
            cmd.Parameters.AddWithValue("@low", pp[9]);
            cmd.Parameters.AddWithValue("@spread", pp[10]);

            if (addIndicators)
            {
                int start = 11;
                foreach (var kvp in inds)
                {
                    cmd.Parameters.AddWithValue("@" + kvp.Key, pp[start]);
                    start++;
                }
            }

            try
            {
                Feng.Data.DbHelper.Instance.ExecuteNonQuery(cmd);
            }
            catch (Exception ex)
            {
                WekaUtils.Instance.WriteLog(ex.Message);
            }
        }

        ISimulateStrategy[,] m_simuStrategy;
        private void InitSimulationStrategys()
        {
            var simulationData = SimulationData.Instance.Init(m_symbol);

            m_simuStrategy = new ISimulateStrategy[TestParameters2.CandidateParameter.BatchTps.Length, TestParameters2.CandidateParameter.BatchSls.Length];
            for (int i = 0; i < TestParameters2.CandidateParameter.BatchTps.Length; ++i)
            {
                for (int j = 0; j < TestParameters2.CandidateParameter.BatchSls.Length; ++j)
                {
                    int tp = TestParameters2.CandidateParameter.BatchTps[i];
                    int sl = TestParameters2.CandidateParameter.BatchSls[j];

                    m_simuStrategy[i, j] = new TpSlM1SimulateStrategy(m_symbol, tp * 10, sl * 10, simulationData);
                }
            }
        }
        public void UpdateHp(long nowTime)
        {
            System.Console.WriteLine("Now UpdateHp.");

            int n = TestParameters2.nTpsl;

            if (m_simuStrategy != null)
            {
                SimulationData.Instance.OnNewData(nowTime);
            }

            var dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(
                string.Format("SELECT TIME FROM {0}_M1 WHERE TIME NOT IN (SELECT TIME FROM {0}_HP) AND TIME <= {1} AND TIME > {2} AND {3}", 
                m_symbol, nowTime, nowTime - 60 * 60 * 24 * 7,
                string.IsNullOrEmpty(TestParameters.DbSelectWhere) ? "1 = 1" : TestParameters.DbSelectWhere));
            var txn = Feng.Data.DbHelper.Instance.BeginTransaction();

            foreach (System.Data.DataRow row in dt.Rows)
            {
                long time = (long)row["Time"];
                var newHpSql = new SqlCommand(string.Format("IF NOT EXISTS (SELECT * FROM [{0}_HP] WHERE Time = {1}) INSERT INTO [{0}_HP] ([Time],[hp],[hp_date],[IsComplete]) VALUES ({1}, @hp, @hp_date, 0)", m_symbol, time));
                sbyte?[, ,] hps = new sbyte?[Parameters.AllDealTypes.Length, TestParameters2.CandidateParameter.BatchTps.Length, TestParameters2.CandidateParameter.BatchSls.Length];
                long?[, ,] hpTimes = new long?[Parameters.AllDealTypes.Length, TestParameters2.CandidateParameter.BatchTps.Length, TestParameters2.CandidateParameter.BatchSls.Length];
                for (int k = 0; k < Parameters.AllDealTypes.Length; ++k)
                {
                    for (int i = 0; i < TestParameters2.CandidateParameter.BatchTps.Length; ++i)
                    {
                        for (int j = 0; j < TestParameters2.CandidateParameter.BatchSls.Length; ++j)
                        {
                            hps[k, i, j] = null;
                            hpTimes[k, i, j] = null;
                        }
                    }
                }
                newHpSql.Parameters.AddWithValue("@hp", HpData.SerializeHp(hps));
                newHpSql.Parameters.AddWithValue("@hp_date", HpData.SerializeHpTimes(hpTimes));
                newHpSql.Transaction = txn as SqlTransaction;
                Feng.Data.DbHelper.Instance.ExecuteNonQuery(newHpSql);
            }

            try
            {
                Feng.Data.DbHelper.Instance.CommitTransaction(txn);
            }
            catch (Exception)
            {
                Feng.Data.DbHelper.Instance.RollbackTransaction(txn);
                throw;
            }

            dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(string.Format("SELECT * FROM {0}_HP WHERE TIME <= {1} AND IsComplete = 0", 
                m_symbol, nowTime));
            txn = Feng.Data.DbHelper.Instance.BeginTransaction();

            foreach (System.Data.DataRow row in dt.Rows)
            {
                if (m_simuStrategy == null)
                {
                    InitSimulationStrategys();
                }

                long time = (long)row["Time"];
                DateTime date = WekaUtils.GetDateFromTime(time);

                sbyte?[, ,] hps = HpData.DeserializeHp((byte[])row["hp"]);
                long?[, ,] hpTimes = HpData.DeserializeHpTimes((byte[])row["hp_date"]);

                if (date.Minute == 0 && date.Hour == 12)
                System.Console.WriteLine(string.Format("Now updatehp of {0}, {1}", date.ToString(Parameters.DateTimeFormat), m_symbol));

                bool[] isComplete = new bool[Parameters.AllDealTypes.Length];
                for (int k = 0; k < Parameters.AllDealTypes.Length; ++k)
                {
                    isComplete[k] = true;

                    char dealType = Parameters.AllDealTypes[k];
                    for (int i = 0; i < TestParameters2.CandidateParameter.BatchTps.Length; ++i)
                    {
                        if (!isComplete[k])
                            break;
                        //if (i % n != n - 1)
                        //    continue;

                        for (int j = 0; j < TestParameters2.CandidateParameter.BatchSls.Length; ++j)
                        {
                            if (!isComplete[k])
                                break;
                            //if (j % n != n - 1)
                            //    continue;

                            if (hps[k, i, j].HasValue && hps[k, i, j].Value != -1)
                                continue;

                            ISimulateStrategy strategy = m_simuStrategy[i, j];

                            //if (j == 5 && i == 9 && date == new DateTime(2010, 6, 1, 0, 15, 0))
                            //{
                            //}

                            DateTime? closeDate;
                            bool? hp;
                            if (dealType == 'B')
                                hp = strategy.DoBuy(date, -1, out closeDate);
                            else if (dealType == 'S')
                                hp = strategy.DoSell(date, -1, out closeDate);
                            else
                                throw new ArgumentException("Invalid dealtype of " + dealType);

                            if (hp.HasValue)
                            {
                                //WekaUtils.Instance.WriteLog(string.Format("Get Update Result of {0},{1},{2},{3} = {4},{5}", 
                                //    time, dealType, 
                                //    TestParameters.DefaultCandidateParameter.BatchTps[i], TestParameters.DefaultCandidateParameter.BatchSls[j],
                                //    hp.Value, closeDate.Value));

                                if (hp.Value)
                                {
                                    // tp
                                    for (int jj = j; jj < TestParameters2.CandidateParameter.BatchSls.Length; ++jj)
                                    {
                                        hps[k, i, jj] = 1;
                                        hpTimes[k, i, jj] = WekaUtils.GetTimeFromDate(closeDate.Value);
                                    }
                                }
                                else
                                {
                                    for (int ii = i; ii < TestParameters2.CandidateParameter.BatchTps.Length; ++ii)
                                    {
                                        hps[k, ii, j] = 0;
                                        hpTimes[k, ii, j] = WekaUtils.GetTimeFromDate(closeDate.Value);
                                    }
                                }
                            }
                            else
                            {
                                isComplete[k] = false;
                                break;
                            }
                        }
                    }
                }

                System.Data.SqlClient.SqlCommand updateCmd = new SqlCommand(string.Format("UPDATE [{0}_HP] SET [hp] = @hp,[hp_date] = @hp_date,[IsComplete] = @IsComplete WHERE [Time] = @Time", m_symbol));
                updateCmd.Parameters.AddWithValue("@hp", HpData.SerializeHp(hps));
                updateCmd.Parameters.AddWithValue("@hp_date", HpData.SerializeHpTimes(hpTimes));
                updateCmd.Parameters.AddWithValue("@IsComplete", WekaUtils.AndAll(isComplete));
                updateCmd.Parameters.AddWithValue("@Time", time);
                updateCmd.Transaction = txn as SqlTransaction;

                Feng.Data.DbHelper.Instance.ExecuteNonQuery(updateCmd);
            }

            try
            {
                Feng.Data.DbHelper.Instance.CommitTransaction(txn);
            }
            catch (Exception)
            {
                Feng.Data.DbHelper.Instance.RollbackTransaction(txn);
                throw;
            }
        }
        #endregion

        public void Init(string symbol)
        {
            m_symbol = symbol;
            java.lang.System.setOut(new PrintStream(new ByteArrayOutputStream()));
            java.util.TimeZone.setDefault(java.util.TimeZone.getTimeZone("GMT"));

            if (string.IsNullOrEmpty(TestParameters.TestName) || TestParameters.TestName == TestParameters.DefaultTestName)
            {
                if (TestParameters2.DBDataConsistent)
                {
                    TestParameters.TestName = "MTTestDb_" + m_symbol;
                }
                else
                {
                    TestParameters.TestName = "MTTest_" + m_symbol;
                }
            }
            AllocConsole();

            bool initAll = true;
            if (initAll)
            {
                //Feng.Data.DbHelper.Instance.ExecuteNonQuery("truncate table [Forex_MT].[dbo].[EURUSD_{0}]");
                //Feng.Data.DbHelper.Instance.ExecuteNonQuery("truncate table [Forex_MT].[dbo].[EURUSD_M1]");
                //Feng.Data.DbHelper.Instance.ExecuteNonQuery("truncate table [Forex_MT].[dbo].[EURUSD_HP]");

                System.IO.File.Delete(string.Format("{0}\\console.txt", TestParameters.BaseDir));

                foreach (string s in System.IO.Directory.GetFiles(TestParameters.BaseDir, "*_ccScores_*.txt"))
                {
                    System.IO.File.Delete(s);
                }
                //foreach (string s in System.IO.Directory.GetFiles(TestParameters.BaseDir, "*_hpdata.txt.full"))
                //{
                //    System.IO.File.Delete(s);
                //}
            }

            TestParameters2.RealTimeMode = true;
            TestParameters2.DBDataConsistent = false;

            //TestParameters2.InitParameters(symbol, "D1", 4);

            TestParameters2.InitParameters(symbol, "M15", 1);
            if (TestParameters.TpMaxCount != 20)
            {
                throw new AssertException("TpSlMaxCount should be 20.");
            }
            TestParameters2.CandidateParameter.InitTpsls(TestParameters.GetTpSlMinDelta(symbol) * TestParameters2.nTpsl, 
                TestParameters.TpMaxCount / TestParameters2.nTpsl,
                TestParameters.SlMaxCount / TestParameters2.nTpsl);

            m_mleaRealTime.Init();

            TestParameters2.OutputParameters();
        }

        public void Deinit()
        {
            WekaUtils.Instance.DeInit();
            FreeConsole();
        }
        MLEARealTime m_mleaRealTime = new MLEARealTime();

        private string m_symbol;
        private long m_nowTime;

        public void OnNewBar(long nowTime, int barLength, double[] pp)
        {
            //System.Windows.Forms.MessageBox.Show(barLength.ToString() + "," + pp.Length.ToString());
            m_nowTime = nowTime;

            try
            {
                if (barLength == TestParameters2.MainPeriodOfHour * 60 * 60) 
                {
                    WekaUtils.Instance.WriteLog(string.Format("Now is {0}, Memory = {1}M", WekaUtils.GetDateFromTime(nowTime).ToString(Parameters.DateTimeFormat), (int)(GC.GetTotalMemory(true) / 1e6)));

                    if (!TestParameters2.DBDataConsistent)
                    {
                        string symbolPeriodTime = m_symbol + "_" + TestParameters2.CandidateParameter.MainPeriod;
                        WekaUtils.Instance.WriteLog(string.Format("Insert Record to {0} at date {1}", symbolPeriodTime, WekaUtils.GetDateFromTime(nowTime)));
                        ImportToDb(nowTime, pp, symbolPeriodTime);

                        UpdateHp(nowTime);
                    }

                    m_mleaRealTime.RunOnBar(nowTime);

                    //if (!TestParameters2.InPreparing)
                    //{
                    //    SaveIntermediateFiles(nowTime);
                    //}

                    WekaUtils.Instance.FlushLog();
                }
                else if (barLength == 60)
                {
                    if (nowTime % 1800 == 0)
                    {
                        WekaUtils.Instance.WriteLog(string.Format("M1: Now is {0}", WekaUtils.GetDateFromTime(nowTime).ToString(Parameters.DateTimeFormat)));
                    }

                    if (!TestParameters2.DBDataConsistent)
                    {
                        string symbolPeriodTime = m_symbol + "_M1";
                        ImportToDb(nowTime, pp, symbolPeriodTime, false);
                    }

                    //MqlRates nowRate = new MqlRates();
                    //nowRate.close = pp[6];
                    //nowRate.open = pp[7];
                    //nowRate.high = pp[8];
                    //nowRate.low = pp[9];
                    //nowRate.spread = (int)pp[10];
                    //nowRate.time = (long)pp[0];
                    //m_mleaRealTime.RunOnTick(nowTime, nowRate);
                }
                else
                {
                    WekaUtils.Instance.WriteLog(string.Format("Unprocessed bar length {1}: Now is {0}",
                        WekaUtils.GetDateFromTime(nowTime).ToString(Parameters.DateTimeFormat), barLength));
                }
            }
            catch (Exception ex)
            {
                WekaUtils.Instance.WriteLog(ex.Message);
                WekaUtils.Instance.WriteLog(ex.StackTrace);
            }
        }

        public void RunTool(string toolName)
        {
            if (string.IsNullOrEmpty(m_symbol))
                throw new ArgumentException("Symbol should be init first.");
            switch (toolName)
            {
                case "ImportDB":
                    {
                        WekaUtils.Instance.WriteLog("RunTool of ImportDB");

                        DbUtils.ImportToDbAll(m_symbol, "M1");
                        DbUtils.ImportToDbAll(m_symbol, "M15");

                        Feng.Data.DbHelper.Instance.ExecuteNonQuery(string.Format("DELETE FROM {0}_M1 WHERE TIME > {1} OR TIME < {2}",
                            m_symbol, WekaUtils.GetTimeFromDate(TestParameters2.TrainStartTime),
                            WekaUtils.GetTimeFromDate(new DateTime(2008, 1, 1))));
                        Feng.Data.DbHelper.Instance.ExecuteNonQuery(string.Format("DELETE FROM {0}_M15 WHERE TIME > {1} OR TIME < {2}",
                            m_symbol, WekaUtils.GetTimeFromDate(TestParameters2.TrainStartTime),
                            WekaUtils.GetTimeFromDate(new DateTime(2008, 1, 1))));

                        string s = string.Format("TIME >= {0} AND TIME < {1} AND {2}",
                            WekaUtils.GetTimeFromDate(new DateTime(2008, 1, 1)), WekaUtils.GetTimeFromDate(new DateTime(2020, 1, 1)),
                            TestParameters.DbSelectWhere);
                        DbUtils.UpdateAllHp3(m_symbol, s, true);
                    }
                    break;
                case "SimulateBefore":
                    {
                        break;

                        WekaUtils.Instance.WriteLog("RunTool of SimulateBefore");
                        if (m_nowTime == 0)
                        {
                            throw new AssertException("when run simulatebefore, nowTime = 0");
                        }
                        DateTime endDate = WekaUtils.GetDateFromTime(m_nowTime);
                        int aheadHour = (int)((TestParameters2.MinTrainPeriod * 1.5) * TestParameters2.MainPeriodOfHour);
                        aheadHour += Convert.ToInt32(TestParameters2.lastWeek) * 7 * 24;
                        DateTime startDate = endDate.AddHours(-aheadHour);

                        WekaUtils.Instance.WriteLog(string.Format("Simulate from {0} to {1}", startDate, endDate));

                        TestParameters2.DBDataConsistent = true;
                        TestParameters2.InPreparing = true;
                        SimulateMt(this, startDate, endDate, Feng.Data.DbHelper.Instance);
                        TestParameters2.DBDataConsistent = false;
                        TestParameters2.InPreparing = false;
                    }
                    break;
            }
        }

        private void SaveIntermediateFiles(long nowTime)
        {
            string dir = TestParameters.BaseDir + "\\" + nowTime + "\\";
            System.IO.Directory.CreateDirectory(dir);
            foreach (string s in Directory.GetFiles(TestParameters.BaseDir))
            {
                string fileName = Path.GetFileName(s);
                System.IO.File.Copy(s, dir + fileName);
            }
        }
    }
}
