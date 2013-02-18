using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Linq;
using System.IO;
using System.Data.SqlClient;

namespace MLEA
{
    public class CCScoreData : Feng.Singleton<CCScoreData>
    {
        public static SortedDictionary<DateTime, Tuple<int, int, int, int, int, double[, ,]>> GetDetailDeals(string inputFile, int nTpsl)
        {
            int m1 = TestParameters.TpMaxCount / TestParameters2.nTpsl;
            int m2 = TestParameters.SlMaxCount / TestParameters2.nTpsl;
            SortedDictionary<DateTime, Tuple<int, int, int, int, int, double[, ,]>> list = new SortedDictionary<DateTime, Tuple<int, int, int, int, int, double[, ,]>>();

            using (StreamReader sr = new StreamReader(inputFile))
            {
                while (!sr.EndOfStream)
                {
                    string s = sr.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        continue;
                    string[] ss = s.Trim().Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                    string[] ss2 = ss[1].Trim().Split(new char[] { '_' }, StringSplitOptions.RemoveEmptyEntries);

                    int prefixN = 6;    // should be 6 because of one empty
                    WekaUtils.DebugAssert(ss.Length == 2 * m1 * m2 * 3 + prefixN, "ss.Length == 2 * tpRealCount * slRealCount * 3 + prefixN");

                    DateTime date = Convert.ToDateTime(ss[0]);
                    date = new DateTime(date.Year, date.Month, date.Day, date.Hour, date.Minute, 0);
                    //if (date.Hour != 0)
                    //    continue;
                    //if (!hpData.ContainsKey(date))
                    //    continue;

                    double[, ,] ccRealScores = new double[2, TestParameters2.tpCount, TestParameters2.slCount];
                    int n = 0;
                    for (int i = 0; i < 2; ++i)
                        for (int j = 0; j < TestParameters2.tpCount; ++j)
                            for (int k = 0; k < TestParameters2.slCount; ++k)
                            {
                                ccRealScores[i, j, k] = Convert.ToDouble(ss[prefixN + n]);
                                n++;
                            }
                    double[, ,] ccScores = new double[2, TestParameters2.tpCount, TestParameters2.slCount];
                    for (int i = 0; i < 2; ++i)
                        for (int j = 0; j < TestParameters2.tpCount; ++j)
                            for (int k = 0; k < TestParameters2.slCount; ++k)
                            {
                                ccScores[i, j, k] = ccRealScores[i, j, k];
                                n++;
                            }

                    var t = new Tuple<int, int, int, int, int, double[, ,]>(
                        ss2[0] == "B" ? 0 : 1, Convert.ToInt32(ss2[1]), Convert.ToInt32(ss2[2]),
                        Convert.ToInt32(ss[5]), Convert.ToInt32(ss[3]) + Convert.ToInt32(ss[4]),
                        ccScores);
                    list[date] = t;
                    //for (int i = 0; i < 2; ++i)
                    //{
                    //    double avg1 = 0, avg2 = 0, sum1 = 0, sum2 = 0;
                    //    for (int j = 0; j < 30; ++j)
                    //        for (int k = 0; k < 30; ++k)
                    //        {
                    //            avg1 += (j + 1) * 20 * ccScores[i, j, k];
                    //            sum1 += ccScores[i, j, k];
                    //            avg2 += (k + 1) * 20 * ccScores[i, j, k];
                    //            sum2 += ccScores[i, j, k];
                    //        }
                    //    avg1 /= sum1;
                    //    avg2 /= sum2;
                    //}
                }
            }
            return list;

            //int dimension = 4;
            //for (int i = 0; i < dimension; ++i)
            //{
            //    int[] idx = new int[dimension];
            //    int[] totalScore = new int[clsScores.GetLength(i)];
            //    for (idx[0] = 0; idx[0] < clsScores.GetLength(0); ++idx[0])
            //        for (idx[1] = 0; idx[1] < clsScores.GetLength(1); ++idx[1])
            //            for (idx[2] = 0; idx[2] < clsScores.GetLength(2); ++idx[2])
            //                for (idx[3] = 0; idx[3] < clsScores.GetLength(3); ++idx[3])
            //                {
            //                    totalScore[idx[i]] += clsScores[idx[0], idx[1], idx[2], idx[3]];
            //                }

            //    for (int j = 0; j < totalScore.GetLength(0); ++j)
            //    {
            //        System.Console.WriteLine(totalScore[j]);
            //    }
            //}
        }

        public void Clear()
        {
            if (m_testDataInsertTable != null && m_testDataInsertTable.Rows.Count > 0)
            {
                Feng.Data.DbHelper.Instance.BulkCopy(m_testDataInsertTable, m_testDataTableName);
                m_testDataInsertTable.Rows.Clear();
                m_testDataInsertTable = null;
            }

            m_testData = null;
            m_testDataEndDate = DateTime.MinValue;
        }

        public static void SaveCCScoresToDb(DateTime nowDate, CandidateParameter cp, ParameterdCandidateStrategy pcs)
        {
            string tableName = string.Format("{0}_CCSCORE_{1}", cp.MainSymbol, cp.DealInfoLastMinutes / (7 * 24 * 12 * 5));
            long nowTime = WekaUtils.GetTimeFromDate(nowDate);
            try
            {
                Feng.Data.DbHelper.Instance.ExecuteNonQuery(string.Format("SELECT TOP 1 * FROM {0} WHERE TIME = -1", tableName));
            }
            catch (Exception)
            {
                string sqlCreate = string.Format(@"CREATE TABLE {0}(
	[Time] [bigint] NOT NULL,
	[scores] [varbinary](max) NOT NULL,
	[nda] [varbinary](max) NOT NULL,
	[nds] [varbinary](max) NOT NULL,
 CONSTRAINT [PK_{0}] PRIMARY KEY CLUSTERED 
(
	[Time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]", tableName);
                Feng.Data.DbHelper.Instance.ExecuteNonQuery(sqlCreate);
            }

            long[, ,] ndas = new long[Parameters.AllDealTypes.Length, cp.BatchTps.Length, cp.BatchSls.Length];
            long[, ,] ndss = new long[Parameters.AllDealTypes.Length, cp.BatchTps.Length, cp.BatchSls.Length];
            double[, ,] nowScores = new double[Parameters.AllDealTypes.Length, cp.BatchTps.Length, cp.BatchSls.Length];

            pcs.IterateClassifierInfos((k, ii, jj, h) =>
            {
                nowScores[k, ii, jj] = pcs.m_classifierInfoIdxs[k, ii, jj, h].Deals.NowScore;
                ndas[k, ii, jj] = pcs.m_classifierInfoIdxs[k, ii, jj, h].Deals.DealLastTimeAvg;
                ndss[k, ii, jj] = pcs.m_classifierInfoIdxs[k, ii, jj, h].Deals.DealLastTimeStd;
            });

            string sql = string.Format("INSERT INTO [{0}] ([Time],[scores],[nda],[nds]) VALUES (@Time, @score, @nda, @nds)", tableName);
            var cmd = new System.Data.SqlClient.SqlCommand(sql);
            cmd.Parameters.AddWithValue("@Time", nowTime);
            cmd.Parameters.AddWithValue("@score", CCScoreData.SerializeScores(nowScores));
            cmd.Parameters.AddWithValue("@nda", CCScoreData.SerializeScoreTimes(ndas));
            cmd.Parameters.AddWithValue("@nds", CCScoreData.SerializeScoreTimes(ndss));

            try
            {
                Feng.Data.DbHelper.Instance.ExecuteNonQuery(string.Format("DELETE FROM {0} WHERE TIME = '{1}'", tableName, WekaUtils.GetTimeFromDate(nowDate)));

                Feng.Data.DbHelper.Instance.ExecuteNonQuery(cmd);
            }
            catch (Exception)
            {
            }
        }

        public void GenerateData(string symbol, int lastWeek)
        {
            TestParameters.SaveCCScoresToDb = true;
            TestParameters2.RealTimeMode = false;

            TestParameters.EnablePerhourTrain = false;
            TestParameters.BatchTrainMinutes = 2 * 4 * 7 * 24 * 12 * 5;
            TestParameters.BatchTestMinutes = (int)(1 * 1 * 3 * 5);
            TestParameters.BatchDateStart = TestParameters2.TrainStartTime;
            TestParameters.BatchDateEnd = TestParameters2.TrainEndTime;

            var ea = new TestManager();

            string fileName = string.Format("{0}\\console_{1}_ccScores_w{2}.txt", TestParameters.BaseDir,
                symbol, lastWeek);
            if (System.IO.File.Exists(fileName))
            {
                System.Console.WriteLine("File exist.");
                return;
            }
            string tableName = string.Format("{0}_CCSCORE_{1}", symbol, lastWeek);
            bool tableAlready = false;
            try
            {
                Feng.Data.DbHelper.Instance.ExecuteDataTable("SELECT TOP 1 * FROM " + tableName);
                tableAlready = true;
            }
            catch (Exception)
            {
            }
            if (tableAlready)
            {
                System.Console.WriteLine("table exist");
                return;
            }

            ea.BatchBatch(symbol, lastWeek);
            //System.IO.File.Move(string.Format("{0}\\console.txt", TestParameters.BaseDir), fileName);
            System.IO.File.Delete(string.Format("{0}\\console.txt", TestParameters.BaseDir));

            DbData.Instance.Clear();
        }

        public void GenerateDataToTxt(string symbol, string lastWeek)
        {
            int n = TestParameters2.nTpsl;

            string ccScoreFileName = TestParameters.GetBaseFilePath(string.Format("{0}_ccScores_w{2}_{1}.txt",
                TestParameters2.CandidateParameter.MainSymbol, TestParameters2.CandidateParameter.MainPeriod, TestParameters2.lastWeek));

            DateTime date = TestParameters2.TrainStartTime;
            DateTime maxDate = TestParameters2.TrainEndTime;
            if (!TestParameters2.RealTimeMode && System.IO.File.Exists(ccScoreFileName))
                return;

            SortedDictionary<DateTime, string> dictAlready = new SortedDictionary<DateTime, string>();
            if (System.IO.File.Exists(ccScoreFileName))
            {
                using (StreamReader sr = new StreamReader(ccScoreFileName))
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

            string sql;
            System.Data.DataTable allDt = null;
            DateTime nextBufferDate = DateTime.MinValue;

            while (true)
            {
                if (!TestParameters2.RealTimeMode)
                {
                    Console.WriteLine(date.ToString(Parameters.DateTimeFormat));
                }

                if (dictAlready.ContainsKey(date))
                {
                    GenerateDateToTxt(ccScoreFileName, date, dictAlready[date]);

                    date = date.AddHours(TestParameters2.MainPeriodOfHour);
                    if (date >= maxDate)
                        break;
                }
                else
                {
                    if (date.DayOfWeek == DayOfWeek.Saturday || date.DayOfWeek == DayOfWeek.Sunday)
                    {
                        date = date.AddHours(TestParameters2.MainPeriodOfHour);
                        continue;
                    }
                    if (nextBufferDate <= date)
                    {
                        nextBufferDate = date.AddHours(TestParameters2.MainPeriodOfHour);
                        string tableName = string.Format("{0}_CCSCORE_{1}", TestParameters2.CandidateParameter.MainSymbol, TestParameters2.lastWeek);

                        sql = string.Format("SELECT * FROM {0} WHERE TIME >= '{1}' AND TIME < '{2}' AND {3}",
                            tableName, WekaUtils.GetTimeFromDate(date), WekaUtils.GetTimeFromDate(nextBufferDate),
                            string.IsNullOrEmpty(TestParameters.DbSelectWhere) ? "1 = 1" : TestParameters.DbSelectWhere);
                        allDt = Feng.Data.DbHelper.Instance.ExecuteDataTable(sql);
                    }

                    DateTime nextDate = date.AddHours(TestParameters2.MainPeriodOfHour);
                    sql = string.Format("TIME >= '{1}' AND TIME < '{2}'",
                            symbol, WekaUtils.GetTimeFromDate(date), WekaUtils.GetTimeFromDate(nextDate));
                    var dt = allDt.Select(sql);

                    if (dt.Length > 0)
                    {
                        double[, ,] scores = new double[2, TestParameters.TpMaxCount / n, TestParameters.SlMaxCount / n];
                        long[, ,] ndas = new long[2, TestParameters.TpMaxCount / n, TestParameters.SlMaxCount / n];
                        long[, ,] ndss = new long[2, TestParameters.TpMaxCount / n, TestParameters.SlMaxCount / n];

                        for (int j = 0; j < scores.GetLength(0); ++j)
                            for (int k = 0; k < scores.GetLength(1); ++k)
                                for (int l = 0; l < scores.GetLength(2); ++l)
                                {
                                    scores[j, k, l] = -1;
                                    ndas[j, k, l] = -1;
                                    ndss[j, k, l] = -1;
                                }

                        System.Data.DataRow row = dt[0];
                        {
                            double[, ,] score = DeserializeScores((byte[])row["scores"]);
                            long[, ,] nda = DeserializeScoreTimes((byte[])row["nda"]);
                            long[, ,] nds = DeserializeScoreTimes((byte[])row["nds"]);

                            WekaUtils.DebugAssert(score.GetLength(0) == 2, "");
                            WekaUtils.DebugAssert(nda.GetLength(0) == 2, "");

                            for (int j = 0; j < score.GetLength(0); ++j)
                                for (int k = 0; k < score.GetLength(1); ++k)
                                    for (int l = 0; l < score.GetLength(2); ++l)
                                    {
                                        if (k % n != n - 1 || l % n != n - 1)
                                            continue;

                                        //if (k / n >= TestParameters2.tpCount)
                                        //    continue;
                                        //if (l / n >= TestParameters2.slCount)
                                        //    continue;

                                        scores[j, k / n, l / n] = score[j, k, l];
                                        ndas[j, k / n, l / n] = nda[j, k, l];
                                        ndss[j, k / n, l / n] = nds[j, k, l];
                                    }

                            GenerateDateToTxt(ccScoreFileName, date, scores, ndas, ndss);
                        }
                    }
                    date = nextDate;
                    if (date >= maxDate)
                        break;
                }
            }
        }

        private static void GenerateDateToTxt(string ccScoreFileName, DateTime nowDate, string s)
        {
            using (StreamWriter sw = new System.IO.StreamWriter(ccScoreFileName, true))
            {
                sw.Write(string.Format("{0},B_0_0,0,0,0,0, ", nowDate.ToString(Parameters.DateTimeFormat)));
                sw.WriteLine(s);
            }
        }

        public static void GenerateDateToTxt(string ccScoreFileName, DateTime nowDate, double[, ,] nowScores, long[, ,] ndas, long[, ,] ndss)
        {
            int n = 1;

            using (StreamWriter sw = new System.IO.StreamWriter(ccScoreFileName, true))
            {
                sw.Write(string.Format("{0},B_0_0,0,0,0,0, ", nowDate.ToString(Parameters.DateTimeFormat)));

                for (int k = 0; k < 2; ++k)
                {
                    for (int i = 0; i < TestParameters2.tpCount; ++i)
                    {
                        for (int j = 0; j < TestParameters2.slCount; ++j)
                        {
                            WekaUtils.DebugAssert(nowScores[k, i * n, j * n] != -1, "nowScores[k, i * n, j * n] != -1");

                            sw.Write(nowScores[k, i * n, j * n].ToString());
                            if (j != TestParameters2.slCount - 1)
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
                    for (int i = 0; i < TestParameters2.tpCount; ++i)
                    {
                        for (int j = 0; j < TestParameters2.slCount; ++j)
                        {
                            sw.Write(ndas[k, i * n, j * n].ToString());
                            if (j != TestParameters2.slCount - 1)
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
                    for (int i = 0; i < TestParameters2.tpCount; ++i)
                    {
                        for (int j = 0; j < TestParameters2.slCount; ++j)
                        {
                            sw.Write(ndss[k, i * n, j * n].ToString());
                            if (j != TestParameters2.slCount - 1)
                            {
                                sw.Write(",");
                            }
                        }
                        sw.Write(",");
                    }
                    sw.Write(",");
                }
                sw.WriteLine();
            }
        }

        public static byte[] SerializeScores(double[, ,] scores)
        {
            return Feng.Windows.Utils.SerializeHelper.Serialize(scores);
        }
        public static byte[] SerializeScoreTimes(long[, ,] scoreTimes)
        {
            return Feng.Windows.Utils.SerializeHelper.Serialize(scoreTimes);
        }
        public static double[, ,] DeserializeScores(byte[] p)
        {
            return Feng.Windows.Utils.SerializeHelper.Deserialize<double[, ,]>(p);
        }
        public static long[, ,] DeserializeScoreTimes(byte[] p)
        {
            return Feng.Windows.Utils.SerializeHelper.Deserialize<long[, ,]>(p);
        }

        #region "TestData"
        //private System.Data.Common.DbTransaction m_txn;
        //private int m_txnCmdCnt = 0;
        //private const int m_txnCmdBufferCnt = 10000;
        //private SqlCommand[] m_cmdBuffers = new SqlCommand[m_txnCmdBufferCnt];
        //private void SetTransaction(System.Data.SqlClient.SqlCommand cmd)
        //{
        //    if (m_txn == null)
        //    {
        //        m_txn = Feng.Data.DbHelper.Instance.BeginTransaction();
        //    }
        //    cmd.Transaction = m_txn as SqlTransaction;
        //    m_cmdBuffers[m_txnCmdCnt] = cmd;
        //    m_txnCmdCnt++;
        //    if (m_txnCmdCnt >= m_txnCmdBufferCnt)
        //    {
        //        EndTransaction();
        //    }
        //}
        //private void EndTransaction()
        //{
        //    if (m_txn == null)
        //        return;

        //    try
        //    {
        //        Feng.Data.DbHelper.Instance.CommitTransaction(m_txn);
        //    }
        //    catch (Exception ex)
        //    {
        //        System.Console.WriteLine(ex.Message);
        //        Feng.Data.DbHelper.Instance.RollbackTransaction(m_txn);

        //        while (true)
        //        {
        //            try
        //            {
        //                m_txn = Feng.Data.DbHelper.Instance.BeginTransaction();
        //                for (int i = 0; i < m_txnCmdCnt; ++i)
        //                {
        //                    m_cmdBuffers[i].Transaction = m_txn as SqlTransaction;
        //                    Feng.Data.DbHelper.Instance.ExecuteNonQuery(m_cmdBuffers[i]);
        //                }
        //                Feng.Data.DbHelper.Instance.CommitTransaction(m_txn);
        //                break;
        //            }
        //            catch (Exception)
        //            {
        //                Feng.Data.DbHelper.Instance.RollbackTransaction(m_txn);
        //            }
        //        }
        //    }
        //    m_txn = null;
        //    m_txnCmdCnt = 0;
        //}
        //private int m_testDataType = 01;

        private string m_testDataTableName;
        public CCScoreData()
        {
            if (TestParameters.EnnableLoadTestData)
            {
                m_testDataTableName = string.Format("{0}_CCSCORE_{1}_Deals", TestParameters2.CandidateParameter.MainSymbol, TestParameters2.lastWeek);

                string createsql = string.Format(@"CREATE TABLE [dbo].[{0}](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Time] [bigint] NOT NULL,
	[ClsName] [nvarchar](50) NOT NULL,
	[TestResult] [nvarchar](255) NOT NULL,
	[ClassValue] [nvarchar](255) NOT NULL,
	[DealsInfo] [varbinary](max) NOT NULL,
	[DealsData] [varbinary](max) NULL,
 CONSTRAINT [PK_EURUSD_CCSCORE_1_DEALS] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]", m_testDataTableName);
                try
                {
                    Feng.Data.DbHelper.Instance.ExecuteDataTable(string.Format("SELECT * FROM {0} WHERE TIME = -1", m_testDataTableName));
                }
                catch (Exception)
                {
                    Feng.Data.DbHelper.Instance.ExecuteNonQuery(createsql);
                }
            }
        }
        public DateTime? GetNewestTestData()
        {
            string sql = string.Format("SELECT MAX(Time) FROM {0}", m_testDataTableName);
            var r = Feng.Data.DbHelper.Instance.ExecuteScalar(sql);
            if (r == System.DBNull.Value)
                return null;
            else
                return WekaUtils.GetDateFromTime(Convert.ToInt64(r));
        }
        private Dictionary<long, List<System.Data.DataRow>> m_testData;
        private DateTime m_testDataEndDate;
        public void LoadTestData(DateTime currentDate, Dictionary<string, CandidateClassifier> clsInfos)
        {
            //EndTransaction();
            if (m_testData == null || currentDate >= m_testDataEndDate)
            {
                m_testDataEndDate = currentDate.AddDays(7);
                if (m_testData == null)
                {
                    m_testData = new Dictionary<long, List<System.Data.DataRow>>();
                }
                else
                {
                    m_testData.Clear();
                    System.GC.Collect();
                }

                WekaUtils.Instance.WriteLog(string.Format("Load Test Data to {0}", m_testDataEndDate));
                //SqlCommand cmd = new SqlCommand("SELECT ClsName, TestResult, ClassValue, DealsData FROM TestData WHERE [Time] = @Time AND [Type] = @Type");
                //cmd.Parameters.AddWithValue("@Time", GetTimeFromDate(currentDate));
                //cmd.Parameters.AddWithValue("@Type", m_testDataType);
                //var ret = Feng.Data.DbHelper.Instance.ExecuteDataTable(cmd);

                Dictionary<string, string> dict = new Dictionary<string, string>();
                foreach (var kvp in clsInfos)
                {
                    dict[kvp.Value.DealType + "_" + kvp.Value.Tp + "_" + kvp.Value.Sl] = null;
                }
                string[] clsNames = new string[dict.Count];
                dict.Keys.CopyTo(clsNames, 0);

                string[] paramNames = clsNames.Select(
                        (s, i) => "ClsName LIKE '" + s + "_%'"//"@tag" + i.ToString()
                    ).ToArray();
                string inClause = string.Join(" OR ", paramNames);

                string sql = ("SELECT Time, ClsName, TestResult, ClassValue, DealsInfo, DealsData FROM {0} WHERE [Time] >= @Time1 AND [Time] < @Time2 AND ({1})");

                SqlCommand cmd = new SqlCommand(string.Format(sql, m_testDataTableName, inClause));
                cmd.Parameters.AddWithValue("@Time1", WekaUtils.GetTimeFromDate(currentDate));
                cmd.Parameters.AddWithValue("@Time2", WekaUtils.GetTimeFromDate(m_testDataEndDate));

                //for (int i = 0; i < paramNames.Length; i++)
                //{
                //    cmd.Parameters.AddWithValue(paramNames[i], clsNames[i]);
                //}

                var ret = Feng.Data.DbHelper.Instance.ExecuteDataTable(cmd);
                foreach (System.Data.DataRow row in ret.Rows)
                {
                    long time = (long)row["Time"];
                    if (!m_testData.ContainsKey(time))
                    {
                        m_testData[time] = new List<System.Data.DataRow>();
                    }
                    m_testData[time].Add(row);
                }
            }

            long ctime = WekaUtils.GetTimeFromDate(currentDate);
            if (m_testData.ContainsKey(ctime))
            {
                foreach (System.Data.DataRow row in m_testData[ctime])
                {
                    string name = (string)row["ClsName"];
                    if (clsInfos.ContainsKey(name))
                    {
                        if (row["DealsData"] == System.DBNull.Value)
                        {
                            clsInfos[name].SetData((string)row["TestResult"], (string)row["ClassValue"], (byte[])row["DealsInfo"], null);
                        }
                        else
                        {
                            clsInfos[name].SetData((string)row["TestResult"], (string)row["ClassValue"], (byte[])row["DealsInfo"], (byte[])row["DealsData"]);
                        }
                    }
                }
            }
        }
        private System.Data.DataTable m_testDataInsertTable;
        public void SaveTestData(CandidateClassifier clsInfo, DateTime nowDate)
        {
            if (TestParameters.OnlyNewestTestDataSaved)
            {
                string sql = string.Format("DELETE FROM {0}", m_testDataTableName);
                Feng.Data.DbHelper.Instance.ExecuteNonQuery(sql);
            }

            string str = WekaUtils.DoubleArrayToIntString(clsInfo.CurrentTestRet);
            string scv = WekaUtils.DoubleArrayToIntString(clsInfo.CurrentClassValue);

            if (m_testDataInsertTable == null)
            {
                m_testDataInsertTable = new System.Data.DataTable();
                m_testDataInsertTable.Columns.Add("Id", typeof(int));
                m_testDataInsertTable.Columns.Add("Time", typeof(long));
                //m_testDataInsertTable.Columns.Add("Type", typeof(int));
                m_testDataInsertTable.Columns.Add("ClsName", typeof(string));
                m_testDataInsertTable.Columns.Add("TestResult", typeof(string));
                m_testDataInsertTable.Columns.Add("ClassValue", typeof(string));
                m_testDataInsertTable.Columns.Add("DealsInfo", typeof(byte[]));
                m_testDataInsertTable.Columns.Add("DealsData", typeof(byte[]));
            }
            var row = m_testDataInsertTable.NewRow();
            row["ClsName"] = clsInfo.Name;
            //row["Type"] = m_testDataType;
            row["Time"] = WekaUtils.GetTimeFromDate(nowDate);
            row["TestResult"] = str;
            row["ClassValue"] = scv;
            row["DealsInfo"] = Feng.Windows.Utils.SerializeHelper.Serialize(clsInfo.Deals);

            bool shouldSave = false;
            if (nowDate.DayOfWeek != DayOfWeek.Sunday && nowDate.DayOfWeek != DayOfWeek.Saturday && nowDate.Day == 20)
                shouldSave = true;
            if (nowDate.Day == 21 && nowDate.DayOfWeek == DayOfWeek.Monday)
                shouldSave = true;
            if (nowDate.Day == 22 && nowDate.DayOfWeek == DayOfWeek.Monday)
                shouldSave = true;

            if (TestParameters.OnlyNewestTestDataSaved)
                shouldSave = true;

            if (shouldSave)
            {
                byte[] dealsData = Feng.Windows.Utils.SerializeHelper.Serialize(clsInfo.Deals.Deals);
                System.IO.MemoryStream outStream = new System.IO.MemoryStream();
                using (System.IO.Compression.GZipStream zipStream =
                                new System.IO.Compression.GZipStream(outStream, System.IO.Compression.CompressionMode.Compress))
                {
                    System.IO.MemoryStream inStream = new System.IO.MemoryStream(dealsData);
                    inStream.CopyTo(zipStream);
                }
                row["DealsData"] = outStream.ToArray();
            }
            else
            {
                row["DealsData"] = System.DBNull.Value;
            }
            m_testDataInsertTable.Rows.Add(row);

            if (m_testDataInsertTable.Rows.Count > 100)
            {
                //WekaUtils.Instance.WriteLog("Save Test Data.");

                try
                {
                    Feng.Data.DbHelper.Instance.BulkCopy(m_testDataInsertTable, m_testDataTableName);
                }
                catch (Exception ex)
                {
                    WekaUtils.Instance.WriteLog(ex.Message);
                }
                m_testDataInsertTable.Rows.Clear();
            }
            //SqlCommand cmd = new SqlCommand("INSERT INTO TestData ([ClsName],[Time], [Type], TestResult, ClassValue, DealsData) VALUES (@ClsName, @Time, @Type, @TestResult, @ClassValue, @DealsData)");
            //cmd.Parameters.AddWithValue("@ClsName", clsInfo.Name);
            //cmd.Parameters.AddWithValue("@Type", m_testDataType);
            //cmd.Parameters.AddWithValue("@Time", WekaUtils.GetTimeFromDate(currentDate));
            //cmd.Parameters.AddWithValue("@TestResult", str);
            //cmd.Parameters.AddWithValue("@ClassValue", scv);
            //cmd.Parameters.AddWithValue("@DealsData", Feng.Utils.SerializeHelper.Serialize(clsInfo.Deals));
            //SetTransaction(cmd);
        }
        #endregion
    }
}
