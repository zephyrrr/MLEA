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
        public void Init(string symbol)
        {
            //AllocConsole();

            m_symbol = symbol;
            java.lang.System.setOut(new PrintStream(new ByteArrayOutputStream()));
            java.util.TimeZone.setDefault(java.util.TimeZone.getTimeZone("GMT"));

            TestParameters.TestName = "MTTest";

            bool initAll = true;
            if (initAll)
            {
                //Feng.Data.DbHelper.Instance.ExecuteNonQuery("truncate table [Forex_MT].[dbo].[EURUSD_D1]");
                //Feng.Data.DbHelper.Instance.ExecuteNonQuery("truncate table [Forex_MT].[dbo].[EURUSD_M1]");
                //Feng.Data.DbHelper.Instance.ExecuteNonQuery("truncate table [Forex_MT].[dbo].[EURUSD_HP]");

                System.IO.File.Delete(string.Format("{0}\\console.txt", TestParameters.BaseDir));
                System.IO.File.Delete(TestParameters.GetBaseFilePath(string.Format("{0}_ccScores.txt", TestParameters2.CandidateParameter.MainSymbol)));
            }

            if (m_simuStrategy == null)
            {
                InitSimulationStrategys();
            }

            m_mleaRealTime.Init();
        }

        public void Deinit()
        {
            //FreeConsole();
            WekaUtils.Instance.DeInit();
        }
        MLEARealTime m_mleaRealTime = new MLEARealTime();

        private string m_symbol;

        private void ImportToDb(long nowTime1, double[] pp, string tableName, bool addIndicators = true)
        {
            Dictionary<string, int> inds = TestParameters.CandidateParameter4Db.AllIndNames;

            System.Diagnostics.Debug.Assert(pp.Length == inds.Count + 6 + 5);
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
                System.Diagnostics.Debug.Assert(newDate.Hour == 0);
                System.Diagnostics.Debug.Assert(newDate.Minute == 0);
                System.Diagnostics.Debug.Assert(newDate.Second == 0);
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
        private void UpdateHp(long nowTime)
        {
            SimulationData.Instance.OnNewData(nowTime);

            var dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(
                string.Format("SELECT TIME FROM {0}_M1 WHERE TIME NOT IN (SELECT TIME FROM {0}_HP) AND {1}", m_symbol,
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
                newHpSql.Parameters.AddWithValue("@hp", WekaUtils.SerializeHp(hps));
                newHpSql.Parameters.AddWithValue("@hp_date", WekaUtils.SerializeHpTimes(hpTimes));
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

            //WekaUtils.Instance.WriteLog(string.Format("Now updatehp of {0}, {1}", nowTime, m_symbol));

            dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(string.Format("SELECT * FROM {0}_HP WHERE IsComplete = 0", m_symbol));
            txn = Feng.Data.DbHelper.Instance.BeginTransaction();

            foreach (System.Data.DataRow row in dt.Rows)
            {
                long time = (long)row["Time"];
                DateTime date = WekaUtils.GetDateFromTime(time);

                sbyte?[, ,] hps = WekaUtils.DeserializeHp((byte[])row["hp"]);
                long?[, ,] hpTimes = WekaUtils.DeserializeHpTimes((byte[])row["hp_date"]);

                bool isComplete = true;
                for (int k = 0; k < Parameters.AllDealTypes.Length; ++k)
                {
                    //if (!isComplete)
                    //    break;

                    char dealType = Parameters.AllDealTypes[k];
                    for (int i = 0; i < TestParameters2.CandidateParameter.BatchTps.Length; ++i)
                    {
                        if (!isComplete)
                            break;

                        for (int j = 0; j < TestParameters2.CandidateParameter.BatchSls.Length; ++j)
                        {
                            if (hps[k,i,j].HasValue && hps[k, i, j].Value != -1)
                                continue;

                            ISimulateStrategy strategy = m_simuStrategy[i, j];

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
                                isComplete = false;
                                break;
                            }
                        }
                    }
                }

                System.Data.SqlClient.SqlCommand updateCmd = new SqlCommand(string.Format("UPDATE [{0}_HP] SET [hp] = @hp,[hp_date] = @hp_date,[IsComplete] = @IsComplete WHERE [Time] = @Time", m_symbol));
                updateCmd.Parameters.AddWithValue("@hp", WekaUtils.SerializeHp(hps));
                updateCmd.Parameters.AddWithValue("@hp_date", WekaUtils.SerializeHpTimes(hpTimes));
                updateCmd.Parameters.AddWithValue("@IsComplete", isComplete);
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

        public void OnNewBar(long nowTime, int barLength, double[] pp)
        {
            //System.Windows.Forms.MessageBox.Show(barLength.ToString() + "," + pp.Length.ToString());

            try
            {
                if (barLength == 24 * 60 * 60)   // Day
                {
                    WekaUtils.Instance.WriteLog(string.Format("Now is {0}", WekaUtils.GetDateFromTime(nowTime).ToString(Parameters.DateTimeFormat)));

                    string symbolPeriodTime = m_symbol + "_D1";

                    WekaUtils.Instance.WriteLog(string.Format("Insert Record to {0} at time {1}", symbolPeriodTime, nowTime));
                    ImportToDb(nowTime, pp, symbolPeriodTime);

                    UpdateHp(nowTime);

                    m_mleaRealTime.RunOnBar(nowTime);

                    WekaUtils.Instance.FlushLog();
                    //CalculateNewSignal();
                }
                else if (barLength == 60)
                {
                    string symbolPeriodTime = m_symbol + "_M1";

                    ImportToDb(nowTime, pp, symbolPeriodTime, false);

                    //MqlRates nowRate = new MqlRates();
                    //nowRate.close = pp[6];
                    //nowRate.open = pp[7];
                    //nowRate.high = pp[8];
                    //nowRate.low = pp[9];
                    //nowRate.spread = (int)pp[10];
                    //nowRate.time = (long)pp[0];

                    //m_mleaRealTime.RunOnTick(nowTime, nowRate);
                }
            }
            catch (Exception ex)
            {
                WekaUtils.Instance.WriteLog(ex.Message);
                WekaUtils.Instance.WriteLog(ex.StackTrace);
            }
        }
    }
}
