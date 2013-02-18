using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public class ParameterdCandidateStrategy
    {
        public ParameterdCandidateStrategy(CandidateParameter cp = null, 
            ParameterdCandidateStrategy parent = null, IBestCandidateSelector bestCandidateSelector = null)
        {
            if (cp == null)
            {
                cp = new CandidateParameter("Default");
            }
            this.CandidateParameter = cp;

            if (cp.ClassifierType == null && !TestParameters.EnableExcludeClassifier)
            {
                cp.SymbolCount = 1;
                cp.PeriodCount = 1;
                cp.PeriodTimeCount = 0;
                cp.PrevTimeCount = 0;
            }

            InitClassifierInfos(parent);

            if (TestParameters2.RealTimeMode)
            {
                m_enableDetailLogLevel2 = false;
            }

            m_bestCandidateSelector = bestCandidateSelector;
        }
        public override string ToString()
        {
            return this.CandidateParameter.Name.ToString();
        }
        public CandidateParameter CandidateParameter;

        
        private bool m_enableDetailLogLevel2 = false;
        //private bool m_enableStoreResultInDb = false;

        public int DealInfoLastMinutes
        {
            get { return this.CandidateParameter.DealInfoLastMinutes; }
        }
        
        private RealDealsInfo m_realDealsInfo = new RealDealsInfo();
        public RealDealsInfo RealDeals
        {
            get { return m_realDealsInfo; }
        }

        public Dictionary<string, CandidateClassifier> m_classifierInfos = new Dictionary<string, CandidateClassifier>();
        public CandidateClassifier[, , ,] m_classifierInfoIdxs;
        private double[, , ,] m_totalScores;
        private int[, , ,] m_totalDeals;

        public void OutputSummary()
        {
            //summary
            IterateClassifierInfos((k, i, j, h) =>
            {
                if (m_totalScores[k, i, j, h] != 0)
                {
                    WekaUtils.Instance.WriteLog(string.Format("Predict score for {0}: TC={1}, TD={2}", m_classifierInfoIdxs[k, i, j, h].Name, m_totalScores[k, i, j, h].ToString(Parameters.DoubleFormatString), m_totalDeals[k, i, j, h]));
                }
            });
            PrintClassifierInfoScores();
        }

        protected void InitClassifierInfos(ParameterdCandidateStrategy parent = null)
        {
            //int[] sls = m_batchSls != null ? m_batchSls : (m_sl.HasValue ? new int[] { m_sl.Value } : new int[] { 50, 70 });
            //int[][] tps = m_batchTps != null ? m_batchTps : (m_tp.HasValue ? new int[][] { new int[] { m_tp.Value } }
            //    : new int[][] { new int[] { 100, 140 }, new int[] { 50, 70 } });

            //if (Parameters.AllDealTypes == null || Parameters.AllDealTypes.Length == 0)
            //{
            //    Parameters.AllDealTypes = new char[] { 'B', 'S' };
            //}
            if (parent == null)
            {
                m_classifierInfos.Clear();
                m_classifierInfoIdxs = new CandidateClassifier[Parameters.AllDealTypes.Length, this.CandidateParameter.BatchTps.Length, this.CandidateParameter.BatchSls.Length, Parameters.AllHour];
                m_totalScores = new double[m_classifierInfoIdxs.GetLength(0), m_classifierInfoIdxs.GetLength(1), m_classifierInfoIdxs.GetLength(2), m_classifierInfoIdxs.GetLength(3)];
                m_totalDeals = new int[m_classifierInfoIdxs.GetLength(0), m_classifierInfoIdxs.GetLength(1), m_classifierInfoIdxs.GetLength(2), m_classifierInfoIdxs.GetLength(3)];

                for (int k = 0; k < m_classifierInfoIdxs.GetLength(0); ++k)
                {
                    for (int i = 0; i < m_classifierInfoIdxs.GetLength(1); ++i)
                    {
                        for (int j = 0; j < m_classifierInfoIdxs.GetLength(2); ++j)
                        {
                            int tp = this.CandidateParameter.BatchTps[i];
                            int sl = this.CandidateParameter.BatchSls[j];

                            if (!TestParameters.EnablePerhourTrain)
                            {
                                string name = string.Format("{0}_{1}_{2}", Parameters.AllDealTypes[k], tp, sl);
                                m_classifierInfos[name] = new CandidateClassifier(name, tp, sl, Parameters.AllDealTypes[k], -1, this.CandidateParameter);

                                m_classifierInfoIdxs[k, i, j, 0] = m_classifierInfos[name];
                                m_totalScores[k, i, j, 0] = 0;
                                m_totalDeals[k, i, j, 0] = 0;
                            }
                            else
                            {
                                for (int h = 0; h < m_classifierInfoIdxs.GetLength(3); ++h)
                                {
                                    //if (h != 9)
                                    //    continue;

                                    string name = string.Format("{0}_{1}_{2}_H{3}", Parameters.AllDealTypes[k], tp, sl, h);
                                    m_classifierInfos[name] = new CandidateClassifier(name, tp, sl, Parameters.AllDealTypes[k], h, this.CandidateParameter);

                                    m_classifierInfoIdxs[k, i, j, h] = m_classifierInfos[name];
                                    m_totalScores[k, i, j, h] = 0;
                                    m_totalDeals[k, i, j, h] = 0;
                                }
                            }
                        }
                    }
                }

                this.HasParent = false;
            }
            else
            {
                m_classifierInfoIdxs = parent.m_classifierInfoIdxs;
                m_totalScores = new double[m_classifierInfoIdxs.GetLength(0), m_classifierInfoIdxs.GetLength(1), m_classifierInfoIdxs.GetLength(2), m_classifierInfoIdxs.GetLength(3)];
                m_totalDeals = new int[m_classifierInfoIdxs.GetLength(0), m_classifierInfoIdxs.GetLength(1), m_classifierInfoIdxs.GetLength(2), m_classifierInfoIdxs.GetLength(3)];

                m_classifierInfos = parent.m_classifierInfos;

                this.HasParent = true;
            }
        }

        public bool HasParent
        {
            get;
            set;
        }
        private void PrintClassifierInfoScores()
        {
            WekaUtils.Instance.WriteLog(System.Environment.NewLine);
            WekaUtils.Instance.WriteLog("Print detail data.");
            for (int k = 0; k < m_classifierInfoIdxs.GetLength(0); ++k)
            {
                for (int h = 0; h < m_classifierInfoIdxs.GetLength(3); ++h)
                {
                    WekaUtils.Instance.WriteLog(string.Format("DealType = {0}, Hour = {1}", Parameters.AllDealTypes[k], h));

                    for (int i = 0; i < m_classifierInfoIdxs.GetLength(1); ++i)
                    {
                        for (int j = 0; j < m_classifierInfoIdxs.GetLength(2); ++j)
                        {
                            WekaUtils.Instance.WriteLog(WekaUtils.GetCommaString(m_totalScores[k, i, j, h].ToString(Parameters.DoubleFormatString)), false);
                        }
                        WekaUtils.Instance.WriteLog(System.Environment.NewLine, false);
                    }

                    if (!TestParameters.EnablePerhourTrain)
                        break;
                }
            }

            if (TestParameters.EnablePerhourTrain)
            {
                WekaUtils.Instance.WriteLog("Print data accord hour.");
                double[, ,] d = new double[m_classifierInfoIdxs.GetLength(0), m_classifierInfoIdxs.GetLength(1), m_classifierInfoIdxs.GetLength(2)];
                IterateClassifierInfos((k, i, j, h) =>
                {
                    d[k, i, j] += m_totalScores[k, i, j, h];
                });
                for (int k = 0; k < m_classifierInfoIdxs.GetLength(0); ++k)
                {
                    WekaUtils.Instance.WriteLog(string.Format("DealType = {0}", Parameters.AllDealTypes[k]));

                    for (int i = 0; i < m_classifierInfoIdxs.GetLength(1); ++i)
                    {
                        for (int j = 0; j < m_classifierInfoIdxs.GetLength(2); ++j)
                        {
                            WekaUtils.Instance.WriteLog(WekaUtils.GetCommaString(d[k, i, j].ToString(Parameters.DoubleFormatString)), false);
                        }
                        WekaUtils.Instance.WriteLog(System.Environment.NewLine, false);
                    }
                }
            }


            {
                WekaUtils.Instance.WriteLog("Print data accord tp.");
                double[, ,] d = new double[m_classifierInfoIdxs.GetLength(0), m_classifierInfoIdxs.GetLength(2), m_classifierInfoIdxs.GetLength(3)];
                IterateClassifierInfos((k, i, j, h) =>
                {
                    d[k, j, h] += m_totalScores[k, i, j, h];
                });
                for (int k = 0; k < m_classifierInfoIdxs.GetLength(0); ++k)
                {
                    WekaUtils.Instance.WriteLog(string.Format("DealType = {0}", Parameters.AllDealTypes[k]));

                    for (int h = 0; h < m_classifierInfoIdxs.GetLength(3); ++h)
                    {
                        for (int j = 0; j < m_classifierInfoIdxs.GetLength(2); ++j)
                        {
                            WekaUtils.Instance.WriteLog(WekaUtils.GetCommaString(d[k, j, h].ToString(Parameters.DoubleFormatString)), false);
                        }
                        WekaUtils.Instance.WriteLog(System.Environment.NewLine, false);
                        if (!TestParameters.EnablePerhourTrain)
                            break;
                    }
                }
            }

            {
                WekaUtils.Instance.WriteLog("Print data accord sl.");
                double[, ,] d = new double[m_classifierInfoIdxs.GetLength(0), m_classifierInfoIdxs.GetLength(1), m_classifierInfoIdxs.GetLength(3)];
                IterateClassifierInfos((k, i, j, h) =>
                {
                    d[k, i, h] += m_totalScores[k, i, j, h];
                });
                for (int k = 0; k < m_classifierInfoIdxs.GetLength(0); ++k)
                {
                    WekaUtils.Instance.WriteLog(string.Format("DealType = {0}", Parameters.AllDealTypes[k]));

                    for (int h = 0; h < m_classifierInfoIdxs.GetLength(3); ++h)
                    {
                        for (int i = 0; i <  m_classifierInfoIdxs.GetLength(1); ++i)
                        {
                            WekaUtils.Instance.WriteLog(WekaUtils.GetCommaString(d[k, i, h].ToString(Parameters.DoubleFormatString)), false);
                        }
                        WekaUtils.Instance.WriteLog(System.Environment.NewLine, false);
                        if (!TestParameters.EnablePerhourTrain)
                            break;
                    }
                }
            }
        }

        public void IterateClassifierInfos(Action<int, int, int, int> action)
        {
            IterateClassifierInfos((k, i, j, h) =>
            {
                action(k, i, j, h);
                return true;    // continue
            });
        }
        public void IterateClassifierInfos(Func<int, int, int, int, bool> action)
        {
            for (int k = 0; k < m_classifierInfoIdxs.GetLength(0); ++k)
            {
                for (int i = 0; i < m_classifierInfoIdxs.GetLength(1); ++i)
                {
                    for (int j = 0; j < m_classifierInfoIdxs.GetLength(2); ++j)
                    {
                        for (int h = 0; h < m_classifierInfoIdxs.GetLength(3); ++h)
                        {
                            bool r = action(k, i, j, h);
                            if (!r)
                                return;

                            if (!TestParameters.EnablePerhourTrain)
                                break;
                        }
                    }
                }
            }
        }

        public void IterateClassifierInfos2(Action<CandidateClassifier> action)
        {
            IterateClassifierInfos2((clsInfo) =>
            {
                action(clsInfo);
                return true;    // continue
            });
        }
        public void IterateClassifierInfos2(Func<CandidateClassifier, bool> action)
        {
            for (int k = 0; k < m_classifierInfoIdxs.GetLength(0); ++k)
            {
                for (int i = 0; i < m_classifierInfoIdxs.GetLength(1); ++i)
                {
                    for (int j = 0; j < m_classifierInfoIdxs.GetLength(2); ++j)
                    {
                        for (int h = 0; h < m_classifierInfoIdxs.GetLength(3); ++h)
                        {
                            if (TestParameters.EnablePerhourTrain)
                            {
                                if (h != m_currentTestHour)
                                    continue;
                            }
                            bool r = action(m_classifierInfoIdxs[k, i, j, h]);
                            if (!r)
                                return;

                            if (!TestParameters.EnablePerhourTrain)
                                break;
                        }
                    }
                }
            }
        }

        private double[] GetTotalCostByDealType()
        {
            double[] d = new double[m_classifierInfoIdxs.GetLength(0)];

            IterateClassifierInfos((k, i, j, h) =>
            {
                if ((TestParameters.EnablePerhourTrain && h == m_currentTestHour) || !TestParameters.EnablePerhourTrain)
                {
                    d[k] += m_classifierInfoIdxs[k, i, j, h].Deals.NowScore;
                }
            });
            return d;
        }

        public int CurrentTestHour
        {
            get { return m_currentTestHour; }
        }
        private int m_currentTestHour = -1;
        private string currentSummary = string.Empty;
        public string CurrentSummary
        {
            get { return currentSummary; }
        }

        private System.Random m_randomGenerator = new Random();


        public void UpdateUnclosedDeals(DateTime nowDate)
        {
            Dictionary<DateTime, System.Data.DataRow> dictHp = new Dictionary<DateTime, System.Data.DataRow>();
            foreach (var kvp in m_classifierInfos)
            {
                foreach (var i in kvp.Value.Deals.Deals)
                {
                    if (i.CloseTime.HasValue)
                        continue;

                    if (!dictHp.ContainsKey(i.OpenTime))
                    {
                        var sql = string.Format("SELECT * FROM {0}_HP WHERE TIME = {1}", this.CandidateParameter.MainSymbol, WekaUtils.GetTimeFromDate(i.OpenTime));
                        var dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(sql);
                        if (dt.Rows.Count > 0)
                            dictHp[i.OpenTime] = dt.Rows[0];
                    }
                    if (!dictHp.ContainsKey(i.OpenTime))
                        continue;
                    var row = dictHp[i.OpenTime];

                    int tpMinDelta = TestParameters.GetTpSlMinDelta(this.CandidateParameter.MainSymbol);
                    int slMinDelta = TestParameters.GetTpSlMinDelta(this.CandidateParameter.MainSymbol);

                    int d = i.DealType == 'B' ? 0 : 1;
                    sbyte?[, ,] hps = HpData.DeserializeHp((byte[])row["hp"]);
                    long?[, ,] hpsTime = HpData.DeserializeHpTimes((byte[])row["hp_date"]);
                    var hp = hps[d, kvp.Value.Tp / tpMinDelta - 1, kvp.Value.Sl / slMinDelta - 1];
                    if (hp.HasValue
                        && hp.Value != -1)
                    {
                        i.CloseTime = WekaUtils.GetDateFromTime(hpsTime[d, kvp.Value.Tp / tpMinDelta - 1, kvp.Value.Sl / slMinDelta - 1].Value);
                        i.Cost = hp.Value == 1 ? -kvp.Value.Tp : kvp.Value.Sl;
                    }
                }
            }
        }
        private void ExecuteCandidateNowDeals(DateTime nowDate, MqlRates nowRate)
        {
            foreach (var kvp in m_classifierInfos)
            {
                var clsInfo = kvp.Value;
                clsInfo.Deals.NowDeals(nowDate, nowRate);
            }
        }

        public void ExecuteCandidate(DateTime nowDate)
        {
            m_currentTestHour = nowDate.Hour;

            foreach (var kvp in m_classifierInfos)
            {
                kvp.Value.Initialized = false;
            }
            if (TestParameters.EnnableLoadTestData)
            {
                if (!TestParameters.OnlyNewestTestDataSaved)
                {
                    CCScoreData.Instance.LoadTestData(nowDate, m_classifierInfos);
                }
                else
                {
                    DateTime? maxTestDate = CCScoreData.Instance.GetNewestTestData();
                    if (maxTestDate.HasValue && maxTestDate.Value > nowDate)
                        return;
                    if (maxTestDate.HasValue && maxTestDate.Value == nowDate)
                        CCScoreData.Instance.LoadTestData(nowDate, m_classifierInfos);
                }
            }

            WekaData.GenerateArffTemplate(true, true, this.CandidateParameter);

            string candidateClsInfoSummary = "CC:N={0},TrN={1},TeN={4},NC={7},NTP={8},NFP={9},NDA={14},NDS={15},TD={10},TV={11},Cls={12},MM={13}";
            //Instances testInstancesWithoutClassValue = null;  / wrong, should use closeTime

            System.Threading.Tasks.Task[] tasks;
            System.Threading.Tasks.TaskFactory taskFactory = null;
            if (TestParameters.EnableMultiThread)
            {
                int cpuCount = Environment.ProcessorCount - 2;
                cpuCount = Math.Max(cpuCount, 1);
                LimitedConcurrencyLevelTaskScheduler lcts = new LimitedConcurrencyLevelTaskScheduler(1);
                taskFactory = new System.Threading.Tasks.TaskFactory(lcts);
            }
            if (!TestParameters.EnablePerhourTrain)
            {
                tasks = new System.Threading.Tasks.Task[m_classifierInfos.Count];
            }
            else
            {
                tasks = new System.Threading.Tasks.Task[m_classifierInfos.Count / Parameters.AllHour];
            }
            int taskIdx = 0;
            foreach (var kvp in m_classifierInfos)
            {
                if (TestParameters.EnablePerhourTrain)
                {
                    if (kvp.Value.Hour != m_currentTestHour)
                        continue;
                }
                var clsInfo = kvp.Value;

                Action action = () =>
                    {
                        if (clsInfo.Initialized || nowDate > System.DateTime.Now)
                        {
                            if (m_enableDetailLogLevel2)
                            {
                                WekaUtils.Instance.WriteLog(string.Format(candidateClsInfoSummary, clsInfo.Name,
                                    -1, 0, 0,
                                    clsInfo.CurrentClassValue.Length, 0, 0,
                                    clsInfo.Deals.NowScore.ToString(Parameters.DoubleFormatString),
                                    clsInfo.Deals.NowTp, clsInfo.Deals.NowFp,
                                    clsInfo.Deals.TotalDeal, clsInfo.Deals.TotalVolume.ToString("N2"),
                                    clsInfo.Classifier == null ? string.Empty : clsInfo.Classifier.ToString(),
                                    clsInfo.MoneyManagement == null ? string.Empty : clsInfo.MoneyManagement.ToString(),
                                    clsInfo.Deals.DealLastTimeAvg, clsInfo.Deals.DealLastTimeStd));
                            }
                        }
                        else
                        {
                            weka.core.Instances trainInstances;
                            weka.core.Instances testInstances;
                            bool noData = false;
                            if (TestParameters.UseTrain)
                            {
                                clsInfo.WekaData.GenerateData(true, true);
                                trainInstances = clsInfo.WekaData.CurrentTrainInstances;
                                testInstances = clsInfo.WekaData.CurrentTestInstances;

                                if (trainInstances.numInstances() == 0)
                                {
                                    if (m_enableDetailLogLevel2)
                                    {
                                        WekaUtils.Instance.WriteLog(string.Format("{0} - No Train Data", clsInfo.Name));
                                    }
                                    noData = true;
                                }
                            }
                            else
                            {
                                clsInfo.WekaData.GenerateData(false, true);
                                trainInstances = WekaData.GetTrainInstancesTemplate(this.CandidateParameter.Name);
                                testInstances = clsInfo.WekaData.CurrentTestInstances;
                            }

                            if (testInstances.numInstances() == 0)
                            {
                                if (m_enableDetailLogLevel2)
                                {
                                    WekaUtils.Instance.WriteLog(string.Format("{0} - No Test Data", clsInfo.Name));
                                }
                                noData = true;
                            }

                            if (!noData)
                            {
                                clsInfo.WekaData.TrainandTest(clsInfo, this.CandidateParameter);

                                clsInfo.Deals.Now(nowDate, WekaUtils.GetValueFromInstance(testInstances, "mainClose", 0));
                                if (m_enableDetailLogLevel2)
                                {
                                    WekaUtils.Instance.WriteLog(string.Format(candidateClsInfoSummary, clsInfo.Name,
                                        trainInstances.numInstances(), WekaUtils.GetDateValueFromInstances(trainInstances, 0, 0), WekaUtils.GetDateValueFromInstances(trainInstances, 0, trainInstances.numInstances() - 1),
                                        testInstances.numInstances(), WekaUtils.GetDateValueFromInstances(testInstances, 0, 0), WekaUtils.GetDateValueFromInstances(testInstances, 0, testInstances.numInstances() - 1),
                                        clsInfo.Deals.NowScore.ToString(Parameters.DoubleFormatString),
                                         clsInfo.Deals.NowTp, clsInfo.Deals.NowFp,
                                         clsInfo.Deals.TotalDeal, clsInfo.Deals.TotalVolume.ToString("N2"),
                                         clsInfo.Classifier == null ? string.Empty : clsInfo.Classifier.ToString(),
                                         clsInfo.MoneyManagement == null ? string.Empty : clsInfo.MoneyManagement.ToString(),
                                         clsInfo.Deals.DealLastTimeAvg, clsInfo.Deals.DealLastTimeStd));
                                }
                            }
                            else
                            {
                                clsInfo.CurrentClassValue = Parameters.DoubleArrayEmpty;
                                clsInfo.CurrentTestRet = Parameters.DoubleArrayEmpty;

                                clsInfo.Deals.Now(nowDate, null);
                                if (m_enableDetailLogLevel2)
                                {
                                    WekaUtils.Instance.WriteLog(string.Format(candidateClsInfoSummary, clsInfo.Name,
                                        trainInstances.numInstances(), 0, 0,
                                        testInstances.numInstances(), 0, 0,
                                        clsInfo.Deals.NowScore.ToString(Parameters.DoubleFormatString),
                                         clsInfo.Deals.NowTp, clsInfo.Deals.NowFp,
                                         clsInfo.Deals.TotalDeal, clsInfo.Deals.TotalVolume.ToString("N2"),
                                         clsInfo.Classifier == null ? string.Empty : clsInfo.Classifier.ToString(),
                                         clsInfo.MoneyManagement == null ? string.Empty : clsInfo.MoneyManagement.ToString(),
                                         clsInfo.Deals.DealLastTimeAvg, clsInfo.Deals.DealLastTimeStd));
                                }
                            }

                            if (TestParameters.EnnableLoadTestData)
                            {
                                CCScoreData.Instance.SaveTestData(clsInfo, nowDate);
                            }

                            if (TestParameters.EnableDetailLog)
                            {
                                // Check TestInstance Result
                                SortedDictionary<int, int> closeNums = new SortedDictionary<int, int>();
                                for (int i = 0; i < testInstances.numInstances(); ++i)
                                {
                                    if (clsInfo.CurrentTestRet[i] != 2)
                                        continue;

                                    DateTime openDate = WekaUtils.GetDateValueFromInstances(testInstances, 0, i);
                                    DateTime closeDate = WekaUtils.GetDateValueFromInstances(testInstances, 1, i);
                                    WekaUtils.DebugAssert(openDate >= nowDate, "openDate >= nowDate");

                                    int n = (int)(closeDate - nowDate).TotalHours / (TestParameters.BatchTestMinutes / 60) + 1;
                                    if (!closeNums.ContainsKey(n))
                                    {
                                        closeNums[n] = 1;
                                    }
                                    else
                                    {
                                        closeNums[n]++;
                                    }
                                }
                                foreach (var cn in closeNums)
                                {
                                    WekaUtils.Instance.WriteLog(string.Format("  Next {0} Period-{1} has {2} deals",
                                        cn.Key, nowDate.AddHours(TestParameters.BatchTestMinutes / 60 * cn.Key), cn.Value));
                                }
                            }
                        }

                        clsInfo.WekaData.Clear();
                    };

                if (TestParameters.EnableMultiThread)
                {
                    tasks[taskIdx] = taskFactory.StartNew(action);

                    taskIdx++;
                }
                else
                {
                    action();
                }
            }

            if (TestParameters.EnableMultiThread)
            {
                try
                {
                    System.Threading.Tasks.Task.WaitAll(tasks);
                }
                catch (AggregateException ex)
                {
                    foreach (var i in ex.InnerExceptions)
                    {
                        WekaUtils.Instance.WriteLog(i.Message);
                        WekaUtils.Instance.WriteLog(i.StackTrace);
                    }
                }
            }

            if (TestParameters.SaveCCScoresToDb)
            {
                CCScoreData.SaveCCScoresToDb(nowDate, this.CandidateParameter, this);
            }
        }

        public IBestCandidateSelector BestCandidateSelector
        {
            get { return m_bestCandidateSelector; }
        }

        private IBestCandidateSelector m_bestCandidateSelector;
        public List<CandidateClassifier> GetBestCandidates(DateTime nowDate)
        {
            List<CandidateClassifier> minScoreInfos = null;
            if (m_bestCandidateSelector != null 
                && m_classifierInfoIdxs[0, 0, 0, 0].Deals.IsAvailableNow)
            {
                minScoreInfos = m_bestCandidateSelector.GetBestClassifierInfo(this);
            }
            if (minScoreInfos == null)
            {
                minScoreInfos = new List<CandidateClassifier>();
            }
            return minScoreInfos;
        }

        private void OutputRealDealSummary(DateTime nowDate)
        {
            string realDealSummary = "TR:TTP={0},TFP={1},NC={2},NTP={3},NFP={4},NV={5},CP={6},CV={7},CD={8},TC={9},TV={10}";
            if (!string.IsNullOrEmpty(this.CandidateParameter.Name))
            {
                realDealSummary = this.CandidateParameter.Name + "-" + realDealSummary;
            }
            var testInstancesTemplate = WekaData.GetTestInstancesTemplate(this.CandidateParameter.Name);
            if (testInstancesTemplate != null && testInstancesTemplate.numInstances() > 0)
            {
                m_realDealsInfo.Now(nowDate, WekaUtils.GetValueFromInstance(testInstancesTemplate, "mainClose", 0));
            }
            else
            {
                m_realDealsInfo.Now(nowDate, null);
            }
            //currentSummary = string.Format(realDealSummary,
            //    (int)eval.numTruePositives(1), (int)eval.numFalsePositives(1),
            //    m_realDealsInfo.NowCost.ToString(Parameters.DoubleFormatString), m_realDealsInfo.NowTp, m_realDealsInfo.NowFp, m_realDealsInfo.NowVolume.ToString("N2"),
            //    m_realDealsInfo.CurrentProfit.ToString(Parameters.DoubleFormatString), m_realDealsInfo.CurrentVolume.ToString("N2"), m_realDealsInfo.CurrentDeal,
            //    m_realDealsInfo.TotalCost.ToString(Parameters.DoubleFormatString), m_realDealsInfo.TotalVolume.ToString("N2"));

            currentSummary = string.Format(realDealSummary,
                    0, 0,
                    m_realDealsInfo.NowCost.ToString(Parameters.DoubleFormatString), m_realDealsInfo.NowTp, m_realDealsInfo.NowFp, m_realDealsInfo.NowVolume.ToString("N2"),
                    m_realDealsInfo.CurrentProfit.ToString(Parameters.DoubleFormatString), m_realDealsInfo.CurrentVolume.ToString("N2"), m_realDealsInfo.CurrentDeal,
                    m_realDealsInfo.TotalCost.ToString(Parameters.DoubleFormatString), m_realDealsInfo.TotalVolume.ToString("N2"));

            //if (m_enableStoreResultInDb)
            //{
                //System.Data.SqlClient.SqlCommand cmd = new SqlCommand("INSERT TestResult (TestName, Date, Content, TotalCost) VALUES (@TestName, @Date, @Content, @TotalCost)");
                //cmd.Parameters.AddWithValue("@TestName", TestParameters.TestName);
                //cmd.Parameters.AddWithValue("@Date", m_testTimeEnd);
                //cmd.Parameters.AddWithValue("@Content", currentSummary);
                //cmd.Parameters.AddWithValue("@TotalCost", realDealsInfo.NowCost);

                //Feng.Data.DbHelper.Instance.ExecuteNonQuery(cmd);
            //}
        }
        public void ExecuteBest(DateTime nowDate, List<CandidateClassifier> minScoreInfos)
        {
            OutputRealDealSummary(nowDate);

            float totalCost = 0;
            int totalDeal = 0;

            if (minScoreInfos != null)
            {
                List<DealInfo> candidateDeals = new List<DealInfo>();
                foreach (var minScoreInfo in minScoreInfos)
                {
                    minScoreInfo.WekaData.GenerateData(false, true);
                    weka.core.Instances minTestInstances = minScoreInfo.WekaData.CurrentTestInstances;
                    weka.core.Instances minTestInstancesNew = minScoreInfo.WekaData.CurrentTestInstancesNew;

                    if (minTestInstances.numInstances() > 0)
                    {
                        MyEvaluation eval = new MyEvaluation(minScoreInfo.CostMatrix);
                        eval.evaluateModel(minScoreInfo.CurrentTestRet, minScoreInfo.CurrentClassValue);

                        float vol;
                        // vol = (float)minScoreInfo.MoneyManagement.GetVolume(null);
                        vol = 0.1F;
                        //vol = (float)Math.Round(minScore / -20000.0, 1);
                        //WekaUtils.DebugAssert(vol > 0);

                        int tp = (int)eval.numTruePositives(1);
                        int fp = (int)eval.numFalsePositives(1);

                        double minScore = minScoreInfo.Deals.NowScore;
                        //WekaUtils.Instance.WriteLog(string.Format("Best Classifier: N={0},TC={1},TP={2},FP={3},TD={4},TV={5},TTP={6},TFP={7},",
                        //        minScoreInfo.Name, minScoreInfo.Deals.NowScore.ToString(Parameters.DoubleFormatString),
                        //        minScoreInfo.Deals.NowTp, minScoreInfo.Deals.NowFp, minScoreInfo.Deals.NowDeal,
                        //        minScoreInfo.Deals.TotalVolume.ToString("N2"), tp, fp),
                        //    true, ConsoleColor.DarkGreen);

                        // Exclude
                        //if (TestParameters.EnableExcludeClassifier)
                        //{
                        //if (minScoreInfo.ExcludeClassifier == null)
                        //{
                        //    string modelFileName4Exclude = GetExcludeModelFileName(minScoreInfo.Name);
                        //    minScoreInfo.ExcludeClassifier = WekaUtils.TryLoadClassifier(modelFileName4Exclude);
                        //}
                        //}

                        for (int i = 0; i < minScoreInfo.CurrentTestRet.Length; i++)
                        {
                            if (minScoreInfo.CurrentTestRet[i] == 2)
                            {
                                if (minScoreInfo.ExcludeClassifier != null)
                                {
                                    double cv2 = minScoreInfo.ExcludeClassifier.classifyInstance(minTestInstancesNew.instance(i));
                                    if (cv2 != 2)
                                        continue;
                                }
                                candidateDeals.Add(new DealInfo(WekaUtils.GetDateValueFromInstances(minTestInstances, 0, i),
                                    (float)WekaUtils.GetValueFromInstance(minTestInstances, "mainClose", i),
                                    minScoreInfo.DealType,
                                    (float)vol,
                                    (float)(minScoreInfo.CurrentClassValue[i] == 2 ? -minScoreInfo.Tp : minScoreInfo.Sl),
                                    WekaUtils.GetDateValueFromInstances(minTestInstances, 1, i)));
                            }
                        }
                        float nowCost = (float)eval.totalCost();
                        int nowDeal = tp + fp;
                        totalCost += nowCost * vol;
                        totalDeal += nowDeal;

                        //float diff = Math.Abs(totalCost - realDealsInfo.TotalCost);
                        //WekaUtils.DebugAssert(diff < 5);
                        //WekaUtils.DebugAssert(Math.Abs(totalDeal - (realDealsInfo.NowDeal + realDealsInfo.CurrentDeal)) == 0);
                        //if (diff > 0.5)
                        //    totalCost = realDealsInfo.TotalCost;

                        IterateClassifierInfos((k, i, j, h) =>
                        {
                            if (m_classifierInfoIdxs[k, i, j, h] == minScoreInfo)
                            {
                                m_totalScores[k, i, j, h] += nowCost;
                                m_totalDeals[k, i, j, h] += nowDeal;
                                return false;
                            }
                            else
                            {
                                return true;
                            }
                        });
                    }
                }


                int selectCount = 50;
                for (int i = 0; i < selectCount; ++i)
                {
                    if (candidateDeals.Count == 0)
                        break;

                    int selectedDealIdx = (int)Math.Round(m_randomGenerator.NextDouble() * candidateDeals.Count);
                    if (selectedDealIdx == candidateDeals.Count)
                        selectedDealIdx = candidateDeals.Count - 1;

                    m_realDealsInfo.AddDeal(candidateDeals[selectedDealIdx]);
                    candidateDeals.RemoveAt(selectedDealIdx);
                }

            }

            //if (m_enableDetailLogLevel2)
            //{
            //    IterateClassifierInfos((k, i, j, h) =>
            //        {
            //            if (h == m_currentTestHour && m_totalScores[k, i, j, h] != 0)
            //            {
            //                WekaUtils.Instance.WriteLog(string.Format("Predict score for {0}: TC={1}, TD={2}", m_classifierInfoIdxs[k, i, j, h].Name, m_totalScores[k, i, j, h].ToString(Parameters.DoubleFormatString), m_totalDeals[k, i, j, h]));
            //            }
            //        });

            //}
            if (!string.IsNullOrEmpty(currentSummary))
            {
                WekaUtils.Instance.WriteLog(currentSummary, true, ConsoleColor.Red);
                System.Console.Title = nowDate.ToString(Parameters.DateTimeFormat) + ":" + currentSummary;
            }

            //if (m_enableDetailLogLevel2)
            //{
            //    if (TestParameters.EnablePerhourTrain)
            //    {
            //        double[] totalCostPerHour = new double[m_classifierInfoIdxs.GetLength(3)];
            //        int[] totalDealPerHour = new int[m_classifierInfoIdxs.GetLength(3)];
            //        IterateClassifierInfos((k, i, j, h) =>
            //        {
            //            totalCostPerHour[h] += m_totalScores[k, i, j, h];
            //            totalDealPerHour[h] += m_totalDeals[k, i, j, h];
            //        });
            //        for (int i = 0; i < totalCostPerHour.Length; ++i)
            //        {
            //            if (totalCostPerHour[i] == 0)
            //                continue;

            //            WekaUtils.Instance.WriteLog(string.Format("Predict score Per hour of {0}: TC={1}, TD={2}", i, totalCostPerHour[i].ToString(Parameters.DoubleFormatString), totalDealPerHour[i]));
            //        }
            //    }

            //if ((m_testTimeStart.Month == 4 || m_testTimeStart.Month == 3) && m_testTimeStart.Day == 20)
            //{
            //    foreach (var cls in m_classifierInfos)
            //    {
            //        WekaUtils.Instance.WriteLog(cls.Value.Deals.PrintAll());
            //    }
            //}
            //if (m_currentTestHour == 0)
            //{
            //    var cls = m_classifierInfoIdxs[0, 0, 0, 0];
            //    WekaUtils.Instance.WriteLog((cls.Classifier as RandomClassifier).GetCountInfo());
            //}
            //}

            //if (m_saveDataFile)
            //{
            //    var files = System.IO.Directory.GetFiles(m_baseDir, "*.arff");
            //    if (files.Length > 100)
            //    {
            //        foreach (string fileName in files)
            //        {
            //            try
            //            {
            //                System.IO.File.Delete(fileName);
            //            }
            //            catch (Exception)
            //            {
            //            }
            //        }
            //    }
            //}
        }
    }
}
