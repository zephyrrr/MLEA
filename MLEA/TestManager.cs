using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace MLEA
{
    public class TestManager
    {
        //private DateTime m_trainTimeStart;
        //private DateTime m_trainTimeEnd;
        //private DateTime m_testTimeStart;
        //private DateTime m_testTimeEnd;

        public void Do()
        {
            //m_currentTp = 60;
            //m_currentSl = 600;
            //m_currentDealTypeIdx = 0;
            //SetTrainTime(new DateTime(2010, 1, 1), new DateTime(2010, 12, 1));
            ////SetTestTime(new DateTime(2011, 2, 1), new DateTime(2011, 2, 5));
            //m_enableTest = false;
            //m_currentTestHour = 22;

            //m_generateOneClassHp = 0;

            //GenerateData();
        }

        private void DoBatchAction(Action action)
        {
            //WekaUtils.DebugAssert(m_trainTimeStart.DayOfWeek == DayOfWeek.Monday);
            //WekaUtils.DebugAssert(m_testTimeStart.DayOfWeek == DayOfWeek.Monday);
            //WekaUtils.DebugAssert(m_trainTimeEnd.DayOfWeek == DayOfWeek.Monday);
            //WekaUtils.DebugAssert(m_testTimeStart.DayOfWeek == DayOfWeek.Monday);

            //if (m_trainTimeStart.DayOfWeek == DayOfWeek.Saturday || m_trainTimeStart.DayOfWeek == DayOfWeek.Sunday)
            //    continue;

            if (WekaData.m_testTimeStart.DayOfWeek == DayOfWeek.Saturday || WekaData.m_testTimeStart.DayOfWeek == DayOfWeek.Sunday)
                return;

            var performanceCount = Feng.Windows.Utils.QueryPerformance.StopQuery();
            string s = string.Format("Now is {0}, {1}", WekaData.m_testTimeStart.ToString(Parameters.DateTimeFormat), performanceCount);
            //System.Console.Title = s;
            Feng.Windows.Utils.QueryPerformance.StartQuery();
            if (TestParameters.EnableDetailLog)
            {
                WekaUtils.Instance.WriteLog(string.Empty);
                WekaUtils.Instance.WriteHorizontalLine();
                WekaUtils.Instance.WriteLog(string.Format("Now train time is {0} - {1}",
                    WekaData.m_trainTimeStart.ToString(Parameters.DateTimeFormat), WekaData.m_trainTimeEnd.ToString(Parameters.DateTimeFormat)));
                WekaUtils.Instance.WriteLog(string.Format("and test time is {0} - {1}",
                    WekaData.m_testTimeStart.ToString(Parameters.DateTimeFormat), WekaData.m_testTimeEnd.ToString(Parameters.DateTimeFormat)));
            }
            else
            {
                WekaUtils.Instance.WriteLog(s);
            }

            try
            {
                action();
            }
            catch (System.OutOfMemoryException ex)
            {
                WekaUtils.Instance.WriteLog(ex.Message);
                throw;
            }
            catch (Exception ex)
            {
                WekaUtils.Instance.WriteLog(ex.Message);
                WekaUtils.Instance.WriteLog(ex.StackTrace);
                //i--;
            }
        }

        public void BatchGenerateData()
        {
            WekaData data = new WekaData('B', 20, 20, null);
            BatchAction(() =>
            {
                data.GenerateData();
            });
        }
        private void UpdateSettings()
        {
        }

        public int ReadConfig(string[] args)
        {
            string s = weka.core.Utils.getOption('n', args);
            if (!string.IsNullOrEmpty(s))
                TestParameters.TestName = s;
            //s = weka.core.Utils.getOption('t', args);
            //if (!string.IsNullOrEmpty(s))
            //    m_currentTp = Convert.ToInt32(s);
            //s = weka.core.Utils.getOption('s', args);
            //if (!string.IsNullOrEmpty(s))
            //    m_currentSl = Convert.ToInt32(s);
            //s = weka.core.Utils.getOption('d', args);
            //if (!string.IsNullOrEmpty(s))
            //{
            //    m_dealType = s.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            //}
            s = weka.core.Utils.getOption('f', args);
            if (!string.IsNullOrEmpty(s))
                ReadConfigFile(s);

            //s = weka.core.Utils.getOption('c', args);
            //if (!string.IsNullOrEmpty(s))
            //    TestParameters.ClassifierType = Convert.ToInt32(s);
            //s = weka.core.Utils.getOption("sn", args);
            //if (!string.IsNullOrEmpty(s))
            //    TestParameters.SymbolCount = Convert.ToInt32(s);

            s = weka.core.Utils.getOption("ds", args);
            if (!string.IsNullOrEmpty(s))
            {
                TestParameters.BatchDateStart = Convert.ToDateTime(s);
            }
            s = weka.core.Utils.getOption("de", args);
            if (!string.IsNullOrEmpty(s))
            {
                TestParameters.BatchDateEnd = Convert.ToDateTime(s);
            }
            //s = weka.core.Utils.getOption("btp", args);
            //if (!string.IsNullOrEmpty(s))
            //{
            //    TestParameters.BatchTps = WekaUtils.StringToIntArray(s);
            //}
            //s = weka.core.Utils.getOption("bsl", args);
            //if (!string.IsNullOrEmpty(s))
            //{
            //    TestParameters.BatchSls = WekaUtils.StringToIntArray(s);
            //}

            s = weka.core.Utils.getOption("func", args);
            if (!string.IsNullOrEmpty(s))
            {
                //System.Console.ReadLine();
                string func = s;

                s = weka.core.Utils.getOption("funcClass", args);
                string funcClass = "MLEA.IndicatorLearn";
                if (!string.IsNullOrEmpty(s))
                {
                    funcClass = s;
                }

                object[] param = null;
                s = weka.core.Utils.getOption("funcParam", args);
                if (!string.IsNullOrEmpty(s))
                {
                    string[] ss = s.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                    param = new object[ss.Length];
                    for (int i = 0; i < param.Length; ++i)
                    {
                        param[i] = ss[i].Trim();
                    }
                }

                try
                {
                    Feng.Utils.ReflectionHelper.RunStaticMethod(typeof(Program).Assembly.GetName().Name, funcClass, func, param);
                }
                catch (Exception ex)
                {
                    System.Console.WriteLine(ex.Message);
                    try
                    {
                        Feng.Utils.ReflectionHelper.RunInstanceMethod(typeof(Program).Assembly.GetName().Name, funcClass, func, this, param);
                    }
                    catch (Exception ex2)
                    {
                        System.Console.WriteLine(ex2.Message);
                    }
                }
                return 1;
            }
            return 0;
        }

        private void ReadConfigFile(string configFile)
        {
            try
            {
                using (StreamReader sr = new StreamReader(configFile))
                {
                    while (true)
                    {
                        if (sr.EndOfStream)
                            break;
                        string s = sr.ReadLine();
                        if (string.IsNullOrEmpty(s))
                            continue;
                        if (s[0] == '#')
                            continue;

                        string[] ss = s.Split(new char[] { '=' }, StringSplitOptions.RemoveEmptyEntries);
                        if (ss.Length != 2)
                            continue;
                        string s1 = ss[1].Trim();
                        switch (ss[0].Trim())
                        {
                            case "TestName":
                                TestParameters.TestName = s1;
                                break;
                            //case "BatchTp":
                            //    {
                            //        TestParameters.BatchTps = WekaUtils.StringToIntArray(s1);
                            //    }
                            //    break;
                            //case "BatchSl":
                            //    {
                            //        TestParameters.BatchSls = WekaUtils.StringToIntArray(s1);
                            //    }
                            //    break;
                        }
                    }
                }

                UpdateSettings();
            }
            catch (Exception ex)
            {
                WekaUtils.Instance.WriteLog(ex.Message);
            }
        }

        public static void OutputTestInfoCandidate(CandidateParameter cp)
        {
            WekaUtils.Instance.WriteHorizontalLine();
            WekaUtils.Instance.WriteLog(string.Format("Candidate Name = {0}", cp.Name));
            WekaUtils.Instance.WriteLog(string.Format("MainSymbol = {0}, MainPeriod = {1}", cp.MainSymbol, cp.MainPeriod));
            WekaUtils.Instance.WriteLog(string.Format("PeriodCount = {0}, PrevTimeCount = {1}, SymbolCount = {2}", cp.PeriodCount, cp.PrevTimeCount, cp.SymbolCount));
            WekaUtils.Instance.WriteLog(string.Format("TakeProfit Length = {0}, StopLoss Length = {1}", cp.BatchTps.Length, cp.BatchSls.Length));
            WekaUtils.Instance.WriteLog(string.Format("dealInfoLastMinutes = {0}", cp.DealInfoLastMinutes));
            WekaUtils.Instance.WriteLog(string.Format("ClassifierType = {0}", cp.ClassifierType == null ? "Default" : cp.ClassifierType.Name));
            WekaUtils.Instance.WriteLog(string.Format("MoneyManagementType = {0}", cp.MoneyManagementType == null ? "Default" : cp.MoneyManagementType.Name));
        }

        private void OutputTestInfo()
        {
            WekaUtils.Instance.WriteHorizontalLine();
            WekaUtils.Instance.WriteLog(string.Format("Test Name is {0}", TestParameters.TestName));

            WekaUtils.Instance.WriteLog(string.Format("TrainTime = {0}, TestTime = {1}", TestParameters.BatchTrainMinutes, TestParameters.BatchTestMinutes));
            //if (Parameters.AllDealTypes.Length > 0)
            //{
            //    WekaUtils.Instance.WriteLog(string.Format("DealTypes = {0}, {1}", Parameters.AllDealTypes[0], Parameters.AllDealTypes.Length > 1 ? Parameters.AllDealTypes[1].ToString() : string.Empty));
            //}
            //WekaUtils.Instance.WriteLog(string.Format("TakeProfit = {0}, StopLoss = {1}", m_currentTp, m_currentSl));
        }

        public void InitBatchBatch(CandidateParameter cp)
        {
            TestParameters.SaveDataFile = false;
            TestParameters.EnableDetailLog = false;
            TestParameters.SaveModel = false;

            if (cp.ClassifierType == null && !TestParameters.EnableExcludeClassifier)
            {
                TestParameters.SaveModel = false;

                TestParameters.UseFilter = false;

                if (cp.MoneyManagementType == null)
                {
                    TestParameters.UseTrain = false;
                }
                //GenerateBatchEmptyInstance();
            }
            else
            {
                //GenerateBatchEmptyInstance();
            }

            //TestParameters.EnablePerhourTrain = true;

            OutputTestInfo();
            UpdateSettings();
        }

        public List<ParameterdCandidateStrategy> AddRealDealCandidates(string symbol, int dealInfoLastWeek, IBestCandidateSelector bcs = null)
        {
            List<ParameterdCandidateStrategy> realDealsCandidates = new List<ParameterdCandidateStrategy>();
            //TestParameters.InitTpsls(20, 10);
            //realDealsCandidates.Add(new RealDealCandidate("1M_10", 1 * 4 * 7 * 24 * 12 * 5, this));
            //realDealsCandidates.Add(new RealDealCandidate("1.5M_10", (int)(1.5 * 4 * 7 * 24 * 12 * 5), this));
            //realDealsCandidates.Add(new RealDealCandidate("2M_10", 2 * 4 * 7 * 24 * 12 * 5, this));

            {
                CandidateParameter cp = new CandidateParameter(symbol);

                int delta = TestParameters.GetTpSlMinDelta(symbol) * TestParameters2.nTpsl;
                cp.InitTpsls(TestParameters2.tpStart, delta, TestParameters2.tpCount, TestParameters2.slStart, delta, TestParameters2.slCount);

                cp.SymbolStart = Array.IndexOf<string>(cp.AllSymbols, symbol);
                cp.SymbolCount = 1;
                cp.PeriodStart = Array.IndexOf<string>(cp.AllPeriods, "M1");
                cp.PeriodCount = 1;

                cp.DealInfoLastMinutes = dealInfoLastWeek * 7 * 24 * 12 * 5;
                cp.Group = 1;

                InitBatchBatch(cp);

                if (cp.ClassifierType == null && !TestParameters.EnableExcludeClassifier)
                {
                    cp.AllIndNames.Clear();
                    cp.AllIndNames2.Clear();
                }
                else
                {
                    cp.DeleteUnusedIndicators();
                    //GenerateBatchEmptyInstance();
                }

                ParameterdCandidateStrategy mainPcs = new ParameterdCandidateStrategy(cp, null, bcs);
                realDealsCandidates.Add(mainPcs);

                //    for (int i = 2; i <= 3; ++i)
                //    {
                //        var cp2 = cp.Clone();
                //        cp2.Name += "_" + i.ToString();
                //        cp2.DealInfoLastMinutes = i * 2 * 4 * 7 * 24 * 12 * 5;
                //        realDealsCandidates.Add(new ParameterdCandidateStrategy(cp2));
                //    }
            }


            {
                //CandidateParameter cp = new CandidateParameter("GBPUSD");
                //cp.InitTpsls(10, 60);
                //cp.SymbolStart = 1;
                //cp.DealInfoLastMinutes = 2 * 4 * 7 * 24 * 12 * 5;
                //cp.Group = 2;
                //ParameterdCandidateStrategy mainPcs = new ParameterdCandidateStrategy(cp);
                //mainPcs.m_bestCandidateSelector = new BestCandidateSelector1(0);
                //realDealsCandidates.Add(mainPcs);

                //    for (int i = 2; i <= 3; ++i)
                //    {
                //        var cp2 = cp.Clone();
                //        cp2.Name += "_" + i.ToString();
                //        cp2.DealInfoLastMinutes = i * 2 * 4 * 7 * 24 * 12 * 5;
                //        realDealsCandidates.Add(new ParameterdCandidateStrategy(cp2));
                //    }
            }

            {
                //CandidateParameter cp = new CandidateParameter("EURGBP");
                //cp.InitTpsls(10, 30);
                //cp.SymbolStart = 6;
                //cp.DealInfoLastMinutes = 6 * 4 * 7 * 24 * 12 * 5;
                //cp.Group = 3;
                //ParameterdCandidateStrategy mainPcs = new ParameterdCandidateStrategy(cp);
                //mainPcs.m_bestCandidateSelector = new BestCandidateSelector1(0);
                //realDealsCandidates.Add(mainPcs);

                //    //    for (int i = 2; i <= 3; ++i)
                //    //    {
                //    //        var cp2 = cp.Clone();
                //    //        cp2.Name += "_" + i.ToString();
                //    //        cp2.DealInfoLastMinutes = i * 2 * 4 * 7 * 24 * 12 * 5;
                //    //        realDealsCandidates.Add(new ParameterdCandidateStrategy(cp2));
                //    //    }
            }

            foreach (var i in realDealsCandidates)
            {
                OutputTestInfoCandidate(i.CandidateParameter);
                WekaUtils.Instance.WriteLog(string.Format("BestCandidateSelector = {0}",
                    i.BestCandidateSelector == null ? "Null" : i.BestCandidateSelector.ToString()));
            }

            return realDealsCandidates;
        }


        public void BatchBatch(string symbol, int dealInfoLastWeek = 8)
        {
            List<string> realDealsResult = new List<string>();

            //ParameterdCandidateStrategy nowUseCandidate = null;

            //var realDealsCandidates = AddRealDealCandidates(symbol, dealInfoLastWeek, new BestCandidateSelector1(0));
            var realDealsCandidates = AddRealDealCandidates(symbol, dealInfoLastWeek, null);

            float maxCurrentVolume = 0;
            float totalCost = 0;
            float totalVolume = 0;//, currentVolume = 0;
            //if (m_enableStoreResultInDb)
            //{
            //    System.Data.SqlClient.SqlCommand cmdInit = new SqlCommand(string.Format("DELETE TestResult WHERE TestName = '{0}'", TestParameters.TestName));
            //    DbHelper.Instance.ExecuteNonQuery(cmdInit);
            //}
            DateTime startRealDate = TestParameters.BatchDateStart.AddMinutes(TestParameters.BatchTrainMinutes).AddMinutes(2 * 4 * 7 * 24 * 12 * 5);
            BatchAction(() =>
            {
                WekaUtils.DebugAssert(WekaData.m_trainTimeEnd == WekaData.m_testTimeStart, "WekaData.m_trainTimeEnd == WekaData.m_testTimeStart");
                //WekaUtils.WriteData(string.Format("Now is {0}", m_testTimeStart.ToString(m_dateTimeFormat)));
                DateTime nowDate = WekaData.m_testTimeStart;

                WekaData.SetTrainTime(WekaData.m_trainTimeStart, WekaData.m_trainTimeEnd);
                WekaData.SetTestTime(WekaData.m_testTimeStart, WekaData.m_testTimeEnd);

                foreach (var i in realDealsCandidates)
                {
                    if (!i.HasParent)
                    {
                        i.ExecuteCandidate(nowDate);
                    }
                }
                if (nowDate < startRealDate)
                {
                    System.Console.Title = nowDate.ToString(Parameters.DateTimeFormat);
                    return;
                }

                List<CandidateClassifier>[] bestCs = new List<CandidateClassifier>[realDealsCandidates.Count];
                for (int i = 0; i < bestCs.Length; ++i)
                {
                    bestCs[i] = realDealsCandidates[i].GetBestCandidates(nowDate);
                    realDealsCandidates[i].ExecuteBest(nowDate, bestCs[i]);
                }

                //// select best
                //ParameterdCandidateStrategy bestCandidate = null;
                //double bestScore = 10000;
                //foreach (var i in realDealsCandidates)
                //{
                //    double score = i.RealDeals.NowCost;// +i.RealDeals.CurrentProfit;// -lastScoreofRealDealCandidate[i.Name];
                //    if (i != nowUseCandidate)
                //    {
                //        // 如果要更换Candidate，则必须至少领先15000
                //        score += 10000;
                //    }
                //    if (score < bestScore)
                //    {
                //        bestScore = score;
                //        bestCandidate = i;
                //    }
                //}
                //if (bestCandidate != nowUseCandidate)
                //{
                //    string s = null;
                //    if (nowUseCandidate != null)
                //    {
                //        s = string.Format("Now switch to realDealCandidate of {0}. until {1}, {2}",
                //            bestCandidate != null ? bestCandidate.CandidateParameter.Name : "Null", 
                //            m_testTimeStart.ToString(Parameters.DateTimeFormat), nowUseCandidate.CurrentSummary);

                //        totalCost += nowUseCandidate.RealDeals.TotalCost;
                //        totalVolume += nowUseCandidate.RealDeals.TotalVolume;
                //    }
                //    else
                //    {
                //        s = string.Format("Now switch to realDealCandidate of {0}. until {1}, null",
                //            bestCandidate != null ? bestCandidate.CandidateParameter.Name : "Null", 
                //            m_testTimeStart.ToString(Parameters.DateTimeFormat));
                //    }
                //    WekaUtils.Instance.WriteLog(s);
                //    realDealsResult.Add(s);

                //    foreach (var i in realDealsCandidates)
                //    {
                //        i.RealDeals.CloseAll();
                //        i.RealDeals.Reset();
                //    }
                //    nowUseCandidate = bestCandidate;
                //}

                //string finalSummary = null;
                //if (nowUseCandidate != null)
                //{
                //    maxCurrentVolume = Math.Max(maxCurrentVolume, nowUseCandidate.RealDeals.CurrentVolume);
                //    finalSummary = (string.Format("{0}:Final,N={1},PTC={2},PTV={3}", 
                //        nowDate.ToString(Parameters.DateTimeFormat),
                //        nowUseCandidate.CandidateParameter.Name,
                //        (totalCost + nowUseCandidate.RealDeals.NowCost).ToString(Parameters.DoubleFormatString),
                //        (totalVolume + nowUseCandidate.RealDeals.NowVolume).ToString(Parameters.DoubleFormatString)));
                //}
                //else
                //{
                //    finalSummary = (string.Format("{0}Final,N={1},PTC={2},PTV={3}",
                //        nowDate.ToString(Parameters.DateTimeFormat),
                //        "Null",
                //       (totalCost).ToString(Parameters.DoubleFormatString),
                //       (totalVolume).ToString(Parameters.DoubleFormatString)));
                //}
                //WekaUtils.Instance.WriteLog(finalSummary);
                //System.Console.Title = finalSummary;


                //Dictionary<int, bool> allSames = new Dictionary<int, bool>();
                //Dictionary<int, char> groupDealTypes = new Dictionary<int, char>();
                //foreach (var i in realDealsCandidates)
                //{
                //    allSames[i.CandidateParameter.Group] = true;
                //    groupDealTypes[i.CandidateParameter.Group] = '0';
                //}

                //for (int i = 0; i < realDealsCandidates.Count; ++i)
                //{
                //    int group = realDealsCandidates[i].CandidateParameter.Group;
                //    if (bestCs[i].Count == 0)
                //    {
                //        allSames[group] = false;
                //        break;
                //    }
                //    char c = bestCs[i][0].DealType;
                //    if (groupDealTypes[group] == '0')
                //    {
                //        groupDealTypes[group] = c;
                //    }
                //    else if (c != groupDealTypes[group])
                //    {
                //        allSames[group] = false;
                //        break;
                //    }
                //}

                //totalCost = totalVolume = currentVolume = 0;
                //for (int i = 0; i < realDealsCandidates.Count; ++i)
                //{
                //    bool allSame = allSames[realDealsCandidates[i].CandidateParameter.Group];
                //    realDealsCandidates[i].ExecuteBest(nowDate, allSame ? bestCs[i] : null);

                //    totalCost += realDealsCandidates[i].RealDeals.TotalCost;
                //    totalVolume += realDealsCandidates[i].RealDeals.TotalVolume;
                //    currentVolume += realDealsCandidates[i].RealDeals.CurrentVolume;
                //}
                //maxCurrentVolume = Math.Max(maxCurrentVolume, currentVolume);
                //StringBuilder sb = new StringBuilder();
                //sb.Append(string.Format("{0}:All total:TC={1},TV={2},CV={3}", 
                //    nowDate.ToString(Parameters.DateTimeFormat),
                //    totalCost.ToString(Parameters.DoubleFormatString), 
                //    totalVolume.ToString(Parameters.DoubleFormatString), 
                //    currentVolume.ToString(Parameters.DoubleFormatString)));
                //foreach(var kvp in groupDealTypes)
                //{
                //    if (allSames[kvp.Key])
                //    {
                //        sb.Append(string.Format(",G{0}={1}", kvp.Key, kvp.Value));
                //    }
                //}
                //WekaUtils.Instance.WriteLog(sb.ToString(), true, ConsoleColor.Red);
                //System.Console.Title = sb.ToString();
            });

            //foreach (var i in realDealsCandidates)
            //{
            //    i.OutputSummary();
            //}
            foreach (var i in realDealsResult)
            {
                WekaUtils.Instance.WriteLog(i);
            }
            WekaUtils.Instance.WriteLog(string.Format("End:maxCurrentVolume={0},ATC ={1},ATV={2}", maxCurrentVolume,
                (totalCost).ToString(Parameters.DoubleFormatString),
                (totalVolume).ToString(Parameters.DoubleFormatString)));

            WekaUtils.Instance.DeInit();
        }

        private void BatchAction(Action action)
        {
            if (TestParameters.EnablePerhourTrain && TestParameters.BatchTestMinutes < 60)
            {
                throw new AssertException("If use PerHourTrain, TestMinute should >= 60");
            }
            if (TestParameters.EnablePerhourTrain && (TestParameters.BatchTestMinutes % 60 * 24 != 0))
            {
                throw new AssertException("If use PerHourTrain, TestMinute should be n * D1");
            }
            //WekaUtils.DebugAssert(m_batchDateStart.DayOfWeek == DayOfWeek.Monday);

            int n = (int)(TestParameters.BatchDateEnd.AddMinutes(-TestParameters.BatchTrainMinutes) - TestParameters.BatchDateStart).TotalMinutes / TestParameters.BatchTestMinutes;

            for (int i = 0; i <= n; i += 1)
            {
                if (i % 50 == 0 && System.GC.GetTotalMemory(false) > Parameters.TotalCanUseMemory)
                {
                    System.GC.Collect();
                    System.GC.WaitForFullGCComplete();
                    System.Console.WriteLine("GC Collect");
                }

                if (i == n)
                {
                    SetTimeMinutesFromTrainStart(new DateTime(2020, 1, 1), TestParameters.BatchTrainMinutes, TestParameters.BatchTestMinutes);
                    DoBatchAction(action);
                }
                else
                {
                    DateTime date = TestParameters.BatchDateStart.AddMinutes(i * TestParameters.BatchTestMinutes);
                    SetTimeMinutesFromTrainStart(date, TestParameters.BatchTrainMinutes, TestParameters.BatchTestMinutes);

                    if (TestParameters.EnablePerhourTrain)
                    {
                        DateTime originalTestTimeStart = WekaData.m_testTimeStart;
                        for (int h = 0; h < Math.Min(Parameters.AllHour, TestParameters.BatchTestMinutes / 60); ++h)
                        {
                            WekaData.m_testTimeStart = originalTestTimeStart.AddHours(h);
                            DoBatchAction(action);
                        }
                    }
                    else
                    {
                        DoBatchAction(action);
                    }
                }
            }
        }

        public DateTime[] SetTimeMinutesFromTestEnd(DateTime testTimeEnd, int trainMinutes, int testMinutes)
        {
            int i = 0;
            DateTime d = testTimeEnd;
            while (i < testMinutes)
            {
                d = d.AddMinutes(-1);
                if (!d.IsHoliday())
                    i++;
            }
            SetTestTime(d, testTimeEnd);
            var testTimeStart = d;

            i = 0;
            while (i < trainMinutes)
            {
                d = d.AddMinutes(-1);
                if (!d.IsHoliday())
                    i++;
            }
            SetTrainTime(d, testTimeStart);

            return new DateTime[] { d, testTimeStart, testTimeStart, testTimeEnd };
        }

        public DateTime[] SetTimeMinutesFromTrainStart(DateTime trainTimeStart, int trainMinutes, int testMinutes)
        {
            var trainTimeEnd = trainTimeStart.AddMinutes(trainMinutes);
            SetTrainTime(trainTimeStart, trainTimeEnd);
            var testTimeStart = trainTimeEnd;
            var testTimeEnd = testTimeStart.AddMinutes(testMinutes);
            SetTestTime(trainTimeEnd, testTimeEnd);

            return new DateTime[] { trainTimeStart, trainTimeEnd, testTimeStart, testTimeEnd };
        }
        public void SetTrainTime(DateTime trainTimeStart, DateTime trainTimeEnd)
        {
            //m_trainTimeStart = trainStart;
            //m_trainTimeEnd = trainEnd;

            WekaData.SetTrainTime(trainTimeStart, trainTimeEnd);
        }
        public void SetTestTime(DateTime testTimeStart, DateTime testTimeEnd)
        {
            //m_testTimeStart = testStart;
            //m_testTimeEnd = testEnd;

            WekaData.SetTestTime(testTimeStart, testTimeEnd);
        }

        //public void SetTimeDays(DateTime trainStart, int trainDays, int testDays)
        //{
        //    SetTimeMinutesFromTrainStart(trainStart, trainDays * 60 * 24, testDays * 60 * 24);
        //}

        public void GenerateEaOrder(CandidateClassifier bestClassifierInfo, weka.core.Instances testInstances)
        {
            if (bestClassifierInfo == null)
                return;

            //int j = m_bestClassifierInfo.DealType == m_dealType[0] ? 0 : 1;

            string eaorderFileName = string.Format("{0}\\ea_order.txt", TestParameters.BaseDir);
            //Instances testInstances = bestClassifierInfo.CurrentTestInstances;

            //Instances testInstancesNew = null;
            //Instances testInstances = null;
            //if (m_saveDataFile)
            //{
            //    SetTraining(false);
            //    string testFileName = GetArffFileName(m_dealType[j], m_newFileAppend);
            //    WekaUtils.Instance.WriteLog("Load instance of " + testFileName);

            //    testInstancesNew = WekaUtils.LoadInstances(testFileName);

            //    testInstances = WekaUtils.LoadInstances(GetArffFileName(m_dealType[j]));
            //}
            //else
            //{
            //    testInstancesNew = m_testInstancesNew[j];
            //    testInstances = m_testInstances[j];
            //}

            System.Data.DataTable dt = null;
            if (!testInstances.attribute(0).isDate())
            {
                dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(string.Format("SELECT Date FROM {0} WHERE Date >= '{1}' AND Date < '{2}' {4}",
                    "EURUSD" + "_" + "M1",
                    WekaData.m_testTimeStart.ToString(Parameters.DateTimeFormat), WekaData.m_testTimeEnd.ToString(Parameters.DateTimeFormat),
                    "ORDER BY Time"));

                if (dt.Rows.Count != testInstances.numInstances())
                {
                    WekaUtils.Instance.WriteLog("different count!");
                    return;
                }
            }
            //else
            //{
            //    if (testInstancesNew.numInstances() != testInstances.numInstances())
            //    {
            //        WekaUtils.Instance.WriteLog("different count!");
            //        return;
            //    }
            //}

            // todo: save info in file
            //for (int j = 0; j < m_dealType.Length; ++j)
            //{
            //    if (m_saveDataFile)
            //    {
            //        string modelFileName = GetModelFileName(m_dealType[j]);

            //        WriteLog("Load model of " + modelFileName);

            //        //ObjectInputStream ois = new ObjectInputStream(new FileInputStream(modelFileName));
            //        //Classifier cls = (Classifier)ois.readObject();
            //        //ois.close();
            //        m_bestClassifier[m_dealType[j]] = (Classifier)weka.core.SerializationHelper.read(modelFileName);
            //    }
            //}

            //foreach (string testFileName in System.IO.Directory.GetFiles(m_baseDir, NormalizeFileName(string.Format("{0}_{1}_{2}_*.arff", m_symbol, dt1.ToString(m_dateTimeFormat), dt2.ToString(m_dateTimeFormat)))))
            //{
            //    string[] ss2 = System.IO.Path.GetFileNameWithoutExtension(testFileName).Split(new char[] { '_' }, StringSplitOptions.RemoveEmptyEntries);
            //    if (ss2.Length != 5)
            //        continue;

            //    try
            //    {
            //        m_trainTimeStart = ConvertFileNameToDateTime(ss2[1]);
            //        m_trainTimeEnd = ConvertFileNameToDateTime(ss2[2]);
            //        m_testTimeStart = ConvertFileNameToDateTime(ss2[3]);
            //        m_testTimeEnd = ConvertFileNameToDateTime(ss2[4]);
            //    }
            //    catch (Exception)
            //    {
            //        continue;
            //    }

            double[] tr = bestClassifierInfo.CurrentTestRet;
            double[] cv = bestClassifierInfo.CurrentClassValue;

            using (StreamWriter sw = new StreamWriter(eaorderFileName, true))
            {
                for (int i = 0; i < testInstances.numInstances(); i++)
                {
                    string clsLabels;
                    double v = tr[i];

                    if (v != double.NaN)
                    {
                        clsLabels = testInstances.classAttribute().value((int)v);// CalcAction(v);
                    }
                    else
                    {
                        clsLabels = "0";
                    }

                    string clsLabel;
                    if (clsLabels == "2")
                    {
                        clsLabel = bestClassifierInfo.DealType == 'B' ? "1" : "-1";
                    }
                    else
                    {
                        clsLabel = "0";
                    }
                    //if (clsLabels.Length >= 2)
                    //{
                    //    if (clsLabels[0] == "1" && clsLabels[1] == "0")
                    //        clsLabel = "1";
                    //    else if (clsLabels[0] == "0" && clsLabels[1] == "1")
                    //        clsLabel = "-1";
                    //    else if (clsLabels[0] == "1" && clsLabels[1] == "1")
                    //        clsLabel = "2";
                    //}
                    //else if (clsLabels.Length == 1)
                    //{
                    //    if (clsLabels[0] == "1")
                    //    {
                    //        if (m_dealType[0] == "B")
                    //            clsLabel = "1";
                    //        else if (m_dealType[0] == "S")
                    //            clsLabel = "-1";
                    //    }
                    //}
                    //else
                    //{
                    //    throw new AssertException("invalid clsLabels.Length");
                    //}
                    string date;
                    string dateClose = string.Empty;
                    if (testInstances.attribute(0).isDate())
                    {
                        date = WekaUtils.GetDateValueFromInstances(testInstances, 0, i).ToString(Parameters.DateTimeFormat);
                        dateClose = WekaUtils.GetDateValueFromInstances(testInstances, 1, i).ToString(Parameters.DateTimeFormat);
                    }
                    else
                    {
                        date = ((DateTime)dt.Rows[i]["Date"]).ToString(Parameters.DateTimeFormat);
                    }

                    sw.WriteLine(string.Format("{0}, {1}, {2}, {3}, 0, 0, {4}, {5}",
                        m_actions[clsLabel], date, bestClassifierInfo.Tp, bestClassifierInfo.Sl, dateClose, cv[i] == v ? "Right" : "Wrong"));

                    //ret[ConvertFileNameToDateTime(date)] = clsLabel;
                }
            }

            //// save labeled data
            //BufferedWriter writer = new BufferedWriter(new FileWriter(string.Format("c:\\eurusd_m1_arff.result")));
            //writer.write(labeled.toString());
            //writer.newLine();
            //writer.flush();
            //writer.close();
        }

        private static Dictionary<string, string> m_actions = new Dictionary<string, string>() { 
                { "1", "Buy" },
                { "0", "Hold"}, 
                { "-1", "Sell"},
                {"2", "Quit"}};


        private DateTime ConvertFileNameToDateTime(string s)
        {
            if (s.Length == 10)
            {
            }
            else if (s.Length == 13)
            {
                s += ":00:00";
            }
            else if (s.Length == 16)
            {
                s += ":00";
            }
            else if (s.Length == 19)
            {
            }
            else
            {
                throw new AssertException("Invalid datetime format of " + s);
            }
            s = s.Replace('p', ':');
            return Convert.ToDateTime(s);
        }
        public void BatchTrainWithWeka()
        {
            double totalCost = 0;
            foreach (string testFileName in System.IO.Directory.GetFiles(TestParameters.BaseDir, string.Format("*.{0}.arff", Parameters.NewFileAppend)))
            {
                string[] ss2 = System.IO.Path.GetFileNameWithoutExtension(testFileName).Replace("." + Parameters.NewFileAppend, "").Split(new char[] { '_' }, StringSplitOptions.RemoveEmptyEntries);
                if (ss2.Length != 5)
                    continue;

                try
                {
                    WekaData.m_trainTimeStart = ConvertFileNameToDateTime(ss2[1]);
                    WekaData.m_trainTimeEnd = ConvertFileNameToDateTime(ss2[2]);
                    WekaData.m_testTimeStart = ConvertFileNameToDateTime(ss2[3]);
                    WekaData.m_testTimeEnd = ConvertFileNameToDateTime(ss2[4]);
                }
                catch (Exception)
                {
                    continue;
                }

                //string trainFileName = GetArffFileName(m_newFileAppend);
                //ConvertToSequenceAction(trainFileName, 12);

                double cost = 0;// = TrainandTest(m_newFileAppend).totalCost();
                totalCost += cost;

                WekaUtils.Instance.WriteLog("Now total cost is " + totalCost.ToString(), true, ConsoleColor.Red);
            }
        }



        public void BatchTestWithWeka()
        {
            string eaorderFileName = string.Format("{0}\\ea_order.txt", TestParameters.BaseDir);
            if (System.IO.File.Exists(eaorderFileName))
            {
                System.IO.File.Delete(eaorderFileName);
            }

            //const string modelDirPrefix = "";// "\\model_libsvm";

            //foreach (string modelFileName in System.IO.Directory.GetFiles(m_baseDir + modelDirPrefix, "*.model"))
            //{
            //    TestWithWeka(modelFileName);
            //}

            //var retEnumerator = ret.GetEnumerator();
            //Func<bool> f2 = () => !retEnumerator.MoveNext();
            //Func<SqlCommand> f1 = () =>
            //{
            //    SqlCommand cmd = new SqlCommand(string.Format("UPDATE {0} SET hp_t = @hp_t WHERE TIME = @TIME", m_symbolPeriod));

            //    long time = (long)(retEnumerator.Current.Key - Parameters.MtStartTime).TotalSeconds;

            //    cmd.Parameters.AddWithValue("@TIME", time);
            //    cmd.Parameters.AddWithValue("@hp_t", retEnumerator.Current.Value);

            //    return cmd;
            //};
            //BatchDb(f1, f2);
        }

        public static void Clear()
        {
            s_dictlastMaxJHpTime.Clear();
        }

        private static bool IncrementTestTrainCheck(string resultFile, long maxjHpTime, int maxjHpTimeHp, int maxjHpTimeCount,
            Tuple<int, int> tuple)
        {
            //Console.WriteLine("maxjHpTimeCount = " + maxjHpTimeCount.ToString());

            if (!s_dictlastMaxJHpTime.ContainsKey(resultFile))
                s_dictlastMaxJHpTime[resultFile] = 0;
            if (s_dictlastMaxJHpTime[resultFile] >= maxjHpTime)
                return false;
            if (maxjHpTimeCount < 20)
                return false;
            s_dictlastMaxJHpTime[resultFile] = maxjHpTime;
            return true;
        }

        private static object[,] IncrementTestTrain(bool newjHpTime, Func<weka.classifiers.Classifier> clsCreator, string resultFile, int step,
            weka.core.Instances trainInstances, weka.core.Instances trainInstancesWithDate,
            weka.core.Instances allInstances, weka.core.Instances allInstancesWithDate,
            long maxjHpTime, int maxjHpTimeHp,
            Tuple<int, int> tuple)
        {
            if (!newjHpTime)
                return null;

            int timeAfter = 0;

            object[,] toRet = new object[step, 9];
            for (int j = 0; j < step; ++j)
                toRet[j, 0] = 2;

            var cls = clsCreator();
            bool b = true;
            b = WekaUtils.TrainInstances(cls, trainInstances);
            if (!b)
            {
                WekaUtils.Instance.WriteLog(string.Format("TrainInstance error!"));
                return null;
            }

            long totolCost = 0;
            //var eval = WekaUtils.TestInstances(trainInstances, cls, null);
            //totolCost = (long)eval.totalCost();

            // get hp last time
            long[] maxLastTimes = new long[trainInstances.numClasses()];
            long[] minLastTimes = new long[trainInstances.numClasses()];
            for (int j = 0; j < trainInstances.numClasses(); ++j)
            {
                maxLastTimes[j] = 0;
                minLastTimes[j] = long.MaxValue;
            }
            for (int j = 0; j < trainInstances.numInstances(); ++j)
            {
                DateTime openTime = WekaUtils.GetDateValueFromInstances(trainInstancesWithDate, 0, j);
                DateTime closeTime = WekaUtils.GetDateValueFromInstances(trainInstancesWithDate, 1, j);

                int v = (int)trainInstances.instance(j).classValue();

                long lastTime = (long)(closeTime - openTime).TotalSeconds;
                if (lastTime > maxLastTimes[v])
                    maxLastTimes[v] = lastTime;
                if (lastTime < minLastTimes[v])
                    minLastTimes[v] = lastTime;
            }

            var ai = tuple.Item1;
            DateTime nowDate = WekaUtils.GetDateValueFromInstances(allInstancesWithDate, 0, ai);
            //var i2 = tuple.Item2;
            for (int j = 0; j < step; ++j)
            {
                int idx = ai + timeAfter + j;
                DateTime nextDate = WekaUtils.GetDateValueFromInstances(allInstancesWithDate, 0, idx);

                double d = 2;
                d = cls.classifyInstance(allInstances.instance(idx));
                double[] v = cls.distributionForInstance(allInstances.instance(idx));
                //if (d == 2)
                //{
                //    WekaUtils.Instance.WriteLog(string.Format("{0} classifyInstance result = 2", nowDate.ToString(Parameters.DateTimeFormat)));
                //    continue;
                //}

                //if ((d == 1 && maxjHpTimeHp == 1)
                //    || (d == 0 && maxjHpTimeHp == 0))
                //    d = 2;
                //if ((d == 1 && maxjHpTimeHp == 0)
                //    || (d == 0 && maxjHpTimeHp == 1))
                //    d = 2;

                toRet[j, 0] = (int)d;
                toRet[j, 1] = (int)allInstances.instance(idx).classValue();
                toRet[j, 2] = WekaUtils.GetTimeFromDate(nextDate);
                toRet[j, 3] = WekaUtils.GetTimeFromDate(nowDate);
                toRet[j, 4] = trainInstances.numInstances();
                toRet[j, 5] = totolCost;
                toRet[j, 6] = maxjHpTime;
                toRet[j, 7] = v[(int)d];
                if (d != 2 && (maxLastTimes[(int)d] == 0
                    || maxLastTimes[(int)d] == long.MaxValue))
                {
                    maxLastTimes[(int)d] = maxLastTimes[3];
                }
                toRet[j, 8] = maxLastTimes[(int)d];

                //using (StreamWriter sw = new StreamWriter("d:\\p.txt", true))
                //{
                //    sw.WriteLine(string.Format("{0}", (int)allInstancesNoDate.instance(idx).classValue()));
                //}
            }

            return toRet;
        }
        private static Dictionary<string, long> s_dictlastMaxJHpTime = new Dictionary<string, long>();
        public static string IncrementTest(weka.core.Instances allInstancesWithDate,
            Func<weka.classifiers.Classifier> clsCreator, string removeAttributes, string resultFile, int step)
        {
            //if (!(TestParameters2.UsePartialHpDataM1 || TestParameters2.UsePartialHpData))
            //{
            //    HpData.Instance.Clear();
            //}

            int trainMinutes = TestParameters2.MinTrainPeriod * WekaUtils.GetMinuteofPeriod(TestParameters2.CandidateParameter.MainPeriod);

            string ret = string.Empty;

            string sampleFile = null; // resultFile.Replace("Increment", "sample");
            bool useInstanceWeight = false;
            bool enablePerHour = false;
            bool enableDiffClass = false;
            int sameClassCount = -1;// TestParameters2.MaxTrainSize / 3; // allInstances.numClasses();
            bool enableDiffHpTime = false;
            bool enableRemoveLittle = false;
            bool enableRemoveLargeThanMid = true;
            bool enableFilter = false;

            if (!TestParameters2.RealTimeMode && File.Exists(resultFile))
                File.Delete(resultFile);

            weka.core.Instances allInstances;
            var filter = new weka.filters.MultiFilter();
            //filter.setOptions(weka.core.Utils.splitOptions("-F \"weka.filters.unsupervised.attribute.Remove -R 1,4\" -F \"weka.filters.unsupervised.attribute.Discretize -B 10 -M -1.0 -R first-last\""));
            filter.setOptions(weka.core.Utils.splitOptions(string.Format("-F \"weka.filters.unsupervised.attribute.Remove -R {0} \"", removeAttributes)));
            filter.setInputFormat(allInstancesWithDate);
            allInstances = weka.filters.Filter.useFilter(allInstancesWithDate, filter);

            long[] jHpTimes = new long[allInstancesWithDate.numInstances()];
            DateTime[] jDates = new DateTime[allInstancesWithDate.numInstances()];
            DateTime[] jHpDates = new DateTime[allInstancesWithDate.numInstances()];
            int[] jHps = new int[allInstancesWithDate.numInstances()];

            for (int j = 0; j < jDates.Length; ++j)
            {
                jDates[j] = WekaUtils.GetDateValueFromInstances(allInstancesWithDate, 0, j);
                jHpTimes[j] = WekaUtils.GetTimeValueFromInstances(allInstancesWithDate, 1, j);
                jHpDates[j] = WekaUtils.GetDateFromTime(jHpTimes[j]);
                jHps[j] = (int)allInstances.instance(j).classValue();
            }

            #region "action"
            Func<Tuple<int, int>, Tuple<weka.core.Instances, weka.core.Instances, long, int, int>> action = (tuple) =>
            {
                var ai = tuple.Item1;

                DateTime nowDate = WekaUtils.GetDateValueFromInstances(allInstancesWithDate, 0, ai);
                if (nowDate < TestParameters2.TrainStartTime || nowDate > TestParameters2.TrainEndTime)
                    return null;

                DateTime nowHpDate = WekaUtils.GetDateValueFromInstances(allInstancesWithDate, 1, ai);
                double nowClass = allInstancesWithDate.instance(ai).classValue();
                double preJClass = -1;

                List<weka.core.Instance> listTrainInstances = new List<weka.core.Instance>(ai / 2);
                List<weka.core.Instance> listTrainInstancesWithDate = new List<weka.core.Instance>(ai / 2);

                int[] counts = new int[allInstancesWithDate.numClasses()];

                long maxjHpTime = -1;
                int maxjHpTimeHp = 2;
                int maxjHpTimeCount = 0;
                bool enoughTrainMinutes = false;
                DateTime firstDate = nowDate.AddMinutes(-trainMinutes);
                int classIdxWithDate = allInstancesWithDate.classIndex();
                int classIdx = allInstances.classIndex();
                for (int j = ai - 1; j >= 0; --j)
                {
                    long jHpTime = jHpTimes[j]; // WekaUtils.GetTimeValueFromInstances(allInstancesWithDate, 1, j);
                    DateTime jHpDate = jHpDates[j];// WekaUtils.GetDateFromTime(jHpTime);
                    DateTime jDate = jDates[j];// WekaUtils.GetDateValueFromInstances(allInstancesWithDate, 0, j);
                    int jHp = jHps[j]; // (int)allInstancesWithDate.instance(j).value(classIdxWithDate);

                    if (enablePerHour)
                    {
                        if (nowDate.Hour != jDate.Hour)
                            continue;
                    }

                    weka.core.Instance instInsert = null;
                    weka.core.Instance instInsertWithDate = null;
                    if (jHpDate <= nowDate)
                    {
                        if (jHpTime > maxjHpTime)
                        {
                            maxjHpTime = jHpTime;
                            maxjHpTimeHp = jHp;
                            maxjHpTimeCount = 1;
                        }
                        else if (jHpTime == maxjHpTime)
                        {
                            maxjHpTimeCount++;
                        }

                        instInsert = new weka.core.DenseInstance(allInstances.instance(j));
                        //instInsert.setDataset(trainInstances);

                        instInsertWithDate = new weka.core.DenseInstance(allInstancesWithDate.instance(j));
                        //instInsertWithDate.setDataset(trainInstancesWithDate);
                    }
                    else
                    {
                        if (TestParameters2.UsePartialHpDataM1 || TestParameters2.UsePartialHpData)
                        {
                            Tuple<int, long> hp = null;
                            if (TestParameters2.UsePartialHpDataM1)
                            {
                                hp = HpData.Instance.GetHpSumByM1(TestParameters2.CandidateParameter.MainSymbol, TestParameters2.CandidateParameter.MainPeriod,
                                    WekaUtils.GetTimeFromDate(nowDate), WekaUtils.GetTimeFromDate(jDate));
                                if (hp.Item2 == 0)
                                    hp = null;
                            }
                            else if (TestParameters2.UsePartialHpData)
                            {
                                var hps = HpData.Instance.GetHpSum(TestParameters2.CandidateParameter.MainSymbol, TestParameters2.CandidateParameter.MainPeriod,
                                    WekaUtils.GetTimeFromDate(nowDate), WekaUtils.GetTimeFromDate(jDate));

                                if (hps.ContainsKey(jDate))
                                {
                                    hp = hps[jDate];
                                }
                            }

                            if (hp != null)
                            {
                                if (WekaUtils.GetDateFromTime(hp.Item2) > nowDate)
                                {
                                    throw new AssertException("hpdate should less than now");
                                }
                                jHp = hp.Item1;
                                jHpTime = hp.Item2;

                                if (jHpTime > maxjHpTime)
                                {
                                    maxjHpTime = jHpTime;
                                    maxjHpTimeHp = jHp;
                                    maxjHpTimeCount = 0;
                                }
                                else if (jHpTime == maxjHpTime)
                                {
                                    maxjHpTimeCount++;
                                }

                                instInsert = new weka.core.DenseInstance(allInstances.instance(j));
                                //instInsert.setDataset(trainInstances);
                                //instInsert.setClassValue(jHp);
                                instInsert.setValue(classIdx, jHp);

                                instInsertWithDate = new weka.core.DenseInstance(allInstancesWithDate.instance(j));
                                //instInsertWithDate.setDataset(trainInstancesWithDate);
                                //instInsertWithDate.setClassValue(jHp);
                                instInsertWithDate.setValue(classIdxWithDate, jHp);
                                instInsertWithDate.setValue(1, jHpTime * 1000);
                            }
                        }
                        
                    }
                    if (instInsert == null)
                        continue;

                    double jClass = jHp;
                    if (enableDiffClass && jClass == preJClass)
                        continue;
                    if (sameClassCount > 0)
                    {
                        if (counts[(int)jClass] >= sameClassCount)
                            continue;
                        counts[(int)jClass]++;
                    }
                    if (enableFilter && j > 0 && Filter(jDate, allInstancesWithDate.instance(j), allInstancesWithDate.instance(j - 1)))
                        continue;
                    if (useInstanceWeight)
                        instInsert.setWeight((nowDate - jDate).TotalMinutes);

                    listTrainInstances.Add(instInsert);
                    listTrainInstancesWithDate.Add(instInsertWithDate);

                    preJClass = jClass;

                    if (jDate <= firstDate)
                    {
                        enoughTrainMinutes = true;
                        break;
                    }
                }

                //weka.core.Instances trainInstances2 = new weka.core.Instances(allInstancesNoDate, 0);
                //for (int x = trainInstances.numInstances() - 1; x >= 0; --x)
                //{
                //    weka.core.Instance inst = new weka.core.DenseInstance(trainInstances.instance(x));
                //    trainInstances2.add(inst);
                //}
                //WekaUtils.SaveInstances(trainInstances2, "d:\\a.arff");

                //if (trainInstances.numInstances() >= trainLength)
                //    break;

                

                if (!enoughTrainMinutes)
                {
                    Console.WriteLine(string.Format("{0}, not enough trainMinutes",
                        nowDate.ToString(Parameters.DateTimeFormat)));
                    return null;
                }
                if (listTrainInstances.Count < TestParameters2.MinTrainSize)
                {
                    Console.WriteLine(string.Format("{0}, numInstances {1} < minTrainSize {2}",
                        nowDate.ToString(Parameters.DateTimeFormat), listTrainInstances.Count, TestParameters2.MinTrainSize));
                    return null;
                }
                //else if (listTrainInstances.Count == 1)
                //{
                //    lock (WekaUtils.Instance)
                //    {
                //        WekaUtils.Instance.WriteLog("trainInstances.numInstances() == 1, nowDate = " + nowDate.ToString());
                //        if (!System.IO.File.Exists("d:\\a.arff"))
                //        {
                //            WekaUtils.SaveInstances(trainInstances, "d:\\a.arff");
                //        }
                //    }
                //}

                weka.core.Instances trainInstances = new weka.core.Instances(allInstances, listTrainInstances.Count);
                weka.core.Instances trainInstancesWithDate = new weka.core.Instances(allInstancesWithDate, listTrainInstancesWithDate.Count);
                WekaUtils.AddInstanceQuickly(trainInstances, listTrainInstances);
                WekaUtils.AddInstanceQuickly(trainInstancesWithDate, listTrainInstancesWithDate);

                if (enableRemoveLittle)
                {
                    double preClass = 2;
                    for (int ii = 0; ii < trainInstances.numInstances(); ++ii)
                    {
                        var iiClass = trainInstances.instance(ii).classValue();
                        if (iiClass == 2)
                            continue;

                        int jj = ii + 1;
                        while (jj < trainInstances.numInstances())
                        {
                            if (trainInstances.instance(jj).classValue() == iiClass)
                                jj++;
                            else
                                break;
                        }
                        int count = jj - ii;
                        if (count < 5)
                        {
                            for (jj = 0; jj < count; ++jj)
                            {
                                trainInstances.instance(ii + jj).setClassValue(preClass);
                            }
                        }
                        else
                        {
                            preClass = iiClass;
                            ii += count;
                        }
                    }
                }

                if (enableDiffHpTime)
                {
                    Dictionary<long, int> jDictHpTimes = new Dictionary<long, int>();

                    int n = trainInstances.numInstances();
                    List<weka.core.Instance> list1 = new List<weka.core.Instance>(n);
                    List<weka.core.Instance> list2 = new List<weka.core.Instance>(n);

                    //java.util.LinkedList deleteList = new java.util.LinkedList();
                    for (int j = 0; j < n; ++j)
                    {
                        long jHpTime = WekaUtils.GetTimeValueFromInstances(trainInstancesWithDate, 1, j);
                        if (jDictHpTimes.ContainsKey(jHpTime))
                        {
                            continue;
                        }
                        else
                        {
                            jDictHpTimes[jHpTime] = list1.Count;
                            list1.Add(trainInstances.instance(j));
                            list2.Add(trainInstancesWithDate.instance(j));
                        }
                    }
                    weka.core.Instances newTrainInstances = new weka.core.Instances(trainInstances, list1.Count);
                    weka.core.Instances newTrainInstancesWithDate = new weka.core.Instances(trainInstancesWithDate, list2.Count);
                    WekaUtils.AddInstanceQuickly(newTrainInstances, list1);
                    WekaUtils.AddInstanceQuickly(newTrainInstancesWithDate, list2);

                    trainInstances = newTrainInstances;
                    trainInstancesWithDate = newTrainInstancesWithDate;
                }

                if (enableRemoveLargeThanMid)
                {
                    int n = trainInstances.numInstances();
                    long[] lastTimes = new long[n];
                    for (int j = 0; j < n; ++j)
                    {
                        long openTime = WekaUtils.GetTimeValueFromInstances(trainInstancesWithDate, 0, j);
                        long closeTime = WekaUtils.GetTimeValueFromInstances(trainInstancesWithDate, 1, j);

                        lastTimes[j] = (long)(closeTime - openTime);
                    }
                    Array.Sort(lastTimes);
                    long midLastTime = lastTimes[lastTimes.Count() / 2];

                    List<weka.core.Instance> list1 = new List<weka.core.Instance>(n);
                    List<weka.core.Instance> list2 = new List<weka.core.Instance>(n);
                    //java.util.LinkedList deleteList = new java.util.LinkedList();
                    for (int j = 0; j < n; ++j)
                    {
                        if (lastTimes[j] > midLastTime)
                        {
                            //deleteList.add(trainInstances.instance(j));
                        }
                        else
                        {
                            list1.Add(trainInstances.instance(j));
                            list2.Add(trainInstancesWithDate.instance(j));
                        }
                    }
                    weka.core.Instances newTrainInstances = new weka.core.Instances(trainInstances, list1.Count);
                    weka.core.Instances newTrainInstancesWithDate = new weka.core.Instances(trainInstancesWithDate, list2.Count);
                    WekaUtils.AddInstanceQuickly(newTrainInstances, list1);
                    WekaUtils.AddInstanceQuickly(newTrainInstancesWithDate, list2);

                    trainInstances = newTrainInstances;
                    trainInstancesWithDate = newTrainInstancesWithDate;
                    //trainInstances.removeAll(deleteList);
                }

                if (!string.IsNullOrEmpty(sampleFile))
                {
                    lock (sampleFile)
                    {
                        if (!System.IO.File.Exists(sampleFile))
                        {
                            WekaUtils.SaveInstances(trainInstancesWithDate, sampleFile);
                        }
                    }
                }

                //using (StreamWriter sw = new StreamWriter("d:\\p.txt", true))
                //{
                //    sw.Write("{0},{1},", nowDate.ToString(Parameters.DateTimeFormat), nowHpDate.ToString(Parameters.DateTimeFormat));
                //}

                return new Tuple<weka.core.Instances, weka.core.Instances, long, int, int>(trainInstances, trainInstancesWithDate, maxjHpTime, maxjHpTimeHp, maxjHpTimeCount);
            };

            #endregion

            //allInstancesNoDate = allInstances;
            if (!TestParameters2.RealTimeMode)
            {
                int tpb = 0, fpb = 0, tps = 0, fps = 0;
                int db = 0, ds = 0, dn = 0;

                int parallelStep = 1;
                if (TestParameters.EnableMultiThread)
                {
                    parallelStep = 100;
                }
                int startIdx = TestParameters2.MinTrainPeriod * 2 / 3;
                for (int i0 = startIdx; i0 < allInstancesWithDate.numInstances() - step; i0 += step * parallelStep)
                {
                    List<Tuple<int, int>> toTest = new List<Tuple<int, int>>();
                    for (int i = i0; i < Math.Min(i0 + step * parallelStep, allInstancesWithDate.numInstances() - step); i += step)
                    {
                        toTest.Add(new Tuple<int, int>(i, toTest.Count));
                    }

                    var toRet0 = new Tuple<weka.core.Instances, weka.core.Instances, long, int, int>[toTest.Count];
                    if (TestParameters.EnableMultiThread)
                    {
                        Parallel.ForEach(toTest, (tuple) =>
                            {
                                int i = tuple.Item1 - i0;
                                toRet0[i] = action(tuple);
                            });
                    }
                    else
                    {
                        for (int i = 0; i < toTest.Count; ++i)
                        {
                            var r = action(toTest[i]);
                            toRet0[i] = r;
                        }
                    }


                    object[, ,] toRet = new object[toTest.Count, step, 9];
                    bool[] toRet1 = new bool[toTest.Count];
                    for (int i = 0; i < toTest.Count; ++i)
                    {
                        for (int j = 0; j < step; ++j)
                            toRet[i, j, 0] = 2;

                        if (toRet0[i] != null)
                        {
                            var maxjHpTime = toRet0[i].Item3;
                            var maxjHpTimeHp = toRet0[i].Item4;
                            var maxjHpTimeCount = toRet0[i].Item5;

                            toRet1[i] = IncrementTestTrainCheck(resultFile, maxjHpTime, maxjHpTimeHp, maxjHpTimeCount, toTest[i]);
                        }
                    }

                    if (TestParameters.EnableMultiThread)
                    {
                        Parallel.ForEach(toTest, (tuple) =>
                            {
                                int i = tuple.Item1 - i0;

                                if (toRet0[i] != null)
                                {
                                    var trainInstances = toRet0[i].Item1;
                                    var trainInstancesWithDate = toRet0[i].Item2;
                                    var maxjHpTime = toRet0[i].Item3;
                                    var maxjHpTimeHp = toRet0[i].Item4;
                                    var r = IncrementTestTrain(toRet1[i], clsCreator, resultFile, step, trainInstances, trainInstancesWithDate, allInstances, allInstancesWithDate,
                                        maxjHpTime, maxjHpTimeHp, toTest[i]);

                                    if (r != null)
                                    {
                                        for (int j = 0; j < toRet.GetLength(1); ++j)
                                            for (int k = 0; k < toRet.GetLength(2); ++k)
                                                toRet[i, j, k] = r[j, k];
                                    }
                                }
                            });
                    }
                    else
                    {
                        for (int i = 0; i < toTest.Count; ++i)
                        {
                            if (toRet0[i] != null)
                            {
                                var trainInstances = toRet0[i].Item1;
                                var trainInstancesWithDate = toRet0[i].Item2;
                                var maxjHpTime = toRet0[i].Item3;
                                var maxjHpTimeHp = toRet0[i].Item4;
                                var r = IncrementTestTrain(toRet1[i], clsCreator, resultFile, step, trainInstances, trainInstancesWithDate, allInstances, allInstancesWithDate,
                                    maxjHpTime, maxjHpTimeHp, toTest[i]);

                                if (r != null)
                                {
                                    for (int j = 0; j < toRet.GetLength(1); ++j)
                                        for (int k = 0; k < toRet.GetLength(2); ++k)
                                            toRet[i, j, k] = r[j, k];
                                }
                            }
                        }
                    }

                    for (int i = 0; i < toTest.Count; ++i)
                    {
                        //action(toTest[i]);
                        for (int j = 0; j < step; ++j)
                        {
                            int d = (int)toRet[i, j, 0];
                            if (d != 0 && d != 1 && d != 2)
                                throw new AssertException("d should be -1, 0, 1 or 2. but it's" + d.ToString());

                            if (toRet[i, j, 6] == null)
                            {
                                //Console.WriteLine("toRet[i, j, 6] == null");
                                continue;
                            }
                            long maxJHpTime = (long)toRet[i, j, 6];
                            //if (lastMaxJHpTime >= (long)toRet[i, j, 6])
                            //    continue;
                            //lastMaxJHpTime = (long)toRet[i, j, 6];

                            if (d == 0)
                                db++;
                            else if (d == 1)
                                ds++;
                            else
                                dn++;

                            int v = (int)toRet[i, j, 1];

                            if (d != 2)
                            {
                                if (v == 3 || d == v)
                                {
                                    if (d == 0)
                                    {
                                        tpb++;
                                    }
                                    else if (d == 1)
                                    {
                                        tps++;
                                    }
                                }
                                else
                                {
                                    if (d == 0)
                                    {
                                        fpb++;
                                    }
                                    else if (d == 1)
                                    {
                                        fps++;
                                    }
                                }
                            }

                            DateTime nowDate = WekaUtils.GetDateFromTime((long)toRet[i, j, 3]);
                            DateTime nextDate = WekaUtils.GetDateFromTime((long)toRet[i, j, 2]);

                            //nextDate = WekaUtils.GetDateFromTime(maxJHpTime);

                            //if (j == 0)
                            {
                                if (tpb + fpb + tps + fps != 0)
                                {
                                    ret = (string.Format("{0}, tn={1},tc={2}, db={3},ds={4},dn={5}, tpb={6},fpb={7},tps={8},fps={9},p={10}", 
                                            nextDate.ToString(Parameters.DateTimeFormat), toRet[i, j, 4], toRet[i, j, 5],
                                            db, ds, dn, 
                                            tpb, fpb, tps, fps, ((double)(tpb+tps) / (tpb + fpb + tps + fps)).ToString("F2")));
                                }
                                else
                                {
                                    ret = (string.Format("{0}, tn={1},tc={2}, db={3},ds={4},dn={5}, tpb={6},fpb={7},tps={8},fps={9},p={10}",
                                            nextDate.ToString(Parameters.DateTimeFormat), toRet[i, j, 4], toRet[i, j, 5],
                                            db, ds, dn,
                                            tpb, fpb, tps, fps, 0));
                                }
                                WekaUtils.Instance.WriteLog(ret);
                            }

                            //if (d != 2)
                            {
                                using (StreamWriter sw = new StreamWriter(resultFile, true))
                                {
                                    sw.WriteLine(string.Format("{1}, {2}, {6}, {3}, {4}, {5}", nowDate, 
                                        nextDate.ToString(Parameters.DateTimeFormat),
                                        d, v, (double)toRet[i, j, 7],
                                        WekaUtils.GetDateFromTime(maxJHpTime).ToString(Parameters.DateTimeFormat),
                                        toRet[i, j, 8]));
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                for (int i0 = allInstancesWithDate.numInstances() - 1; i0 < allInstancesWithDate.numInstances() && i0 >= 0; i0++)
                {
                    List<Tuple<int, int>> toTest = new List<Tuple<int, int>>();
                    toTest.Add(new Tuple<int, int>(i0, toTest.Count));

                    var toRet0 = new Tuple<weka.core.Instances, weka.core.Instances, long, int, int>[toTest.Count];
                    
                    for (int i = 0; i < toTest.Count; ++i)
                    {
                        var r = action(toTest[i]);
                        toRet0[i] = r;
                    }

                    object[, ,] toRet = new object[toTest.Count, step, 9];
                    for (int i = 0; i < toTest.Count; ++i)
                    {
                        for (int j = 0; j < toRet.GetLength(1); ++j)
                            toRet[i, j, 0] = 2;

                        if (toRet0[i] != null)
                        {
                            var trainInstances = toRet0[i].Item1;
                            var trainInstancesWithDate = toRet0[i].Item2;
                            var maxjHpTime = toRet0[i].Item3;
                            var maxjHpTimeHp = toRet0[i].Item4;
                            var maxjHpTimeCount = toRet0[i].Item5;

                            bool b = IncrementTestTrainCheck(resultFile, maxjHpTime, maxjHpTimeHp, maxjHpTimeCount, toTest[i]);
                            var r = IncrementTestTrain(b, clsCreator, resultFile, step, trainInstances, trainInstancesWithDate, allInstances, allInstancesWithDate,
                                maxjHpTime, maxjHpTimeHp, toTest[i]);

                            if (r != null)
                            {
                                for (int j = 0; j < toRet.GetLength(1); ++j)
                                    for (int k = 0; k < toRet.GetLength(2); ++k)
                                        toRet[i, j, k] = r[j, k];
                            }
                        }
                    }

                    for (int j = 0; j < step; ++j)
                    {
                        int d = (int)toRet[0, j, 0];
                        if (d != 0 && d != 1 && d != 2)
                            throw new AssertException("d should be -1, 0, 1 or 2.");

                        if (toRet[0, j, 6] == null)
                            continue;
                        long maxJHpTime = (long)toRet[0, j, 6];
                        //if (lastMaxJHpTime >= (long)toRet[i, j, 6])
                        //    continue;
                        //lastMaxJHpTime = (long)toRet[i, j, 6];

                        int v = (int)toRet[0, j, 1];

                        DateTime nowDate = WekaUtils.GetDateFromTime((long)toRet[0, j, 3]);
                        DateTime nextDate = WekaUtils.GetDateFromTime((long)toRet[0, j, 2]);

                        //nextDate = WekaUtils.GetDateFromTime(maxJHpTime);
                        //if (d != 2)
                        {
                            using (StreamWriter sw = new StreamWriter(resultFile, true))
                            {
                                sw.WriteLine(string.Format("{1}, {2}, {6}, {3}, {4}, {5}", nowDate,
                                    nextDate.ToString(Parameters.DateTimeFormat),
                                    d, v, (double)toRet[0, j, 7],
                                    WekaUtils.GetDateFromTime(maxJHpTime).ToString(Parameters.DateTimeFormat),
                                    toRet[0, j, 8]));
                            }
                        }
                    }
                }
            }

            return ret;
        }
        public static DateTime[] GetDataDateRange()
        {
            var cp = TestParameters2.CandidateParameter;

            DateTime dataStartTime = TestParameters2.TrainStartTime.AddMinutes(-WekaUtils.GetMinuteofPeriod(cp.MainPeriod) * (TestParameters2.MaxTrainSize));
            dataStartTime = dataStartTime.AddMonths(-1);
            DateTime dataEndTime = TestParameters2.TrainEndTime;
            return new DateTime[] { dataStartTime, dataEndTime };
        }

        public void GenerateHpProbArff(string arffFileName)
        {
            int preLength = TestParameters2.PreLength;

            int tpStart = TestParameters2.tpStart;
            int slStart = TestParameters2.slStart;
            int tpCount = TestParameters2.tpCount;
            int slCount = TestParameters2.slCount;

            var cp = TestParameters2.CandidateParameter;

            var dataDates = GetDataDateRange();

            ForexDataRows[,] hpdvs = new ForexDataRows[cp.SymbolCount, cp.PeriodCount];

            for (int s = 0; s < cp.SymbolCount; ++s)
                for (int p = 0; p < cp.PeriodCount; ++p)
                {
                    string symbol = cp.AllSymbols[s + cp.SymbolStart];
                    string period = cp.AllPeriods[p + cp.PeriodStart];
                    string symbolPeriod = string.Format("{0}_{1}", symbol, period);
                    hpdvs[s, p] = DbData.Instance.GetDbData(dataDates[0], dataDates[1], symbolPeriod, 0, true, cp);
                }

            if (File.Exists(arffFileName))
            {
                System.IO.File.Delete(arffFileName);
            }

            string wekaFileName = string.Format(arffFileName);
            using (StreamWriter sw = new StreamWriter(wekaFileName))
            {
                sw.WriteLine("@relation 'hpProb'");
                sw.WriteLine("@attribute timestamp date \"yyyy-MM-dd\'T\'HH:mm:ss\"");
                sw.WriteLine("@attribute hpdate date \"yyyy-MM-dd\'T\'HH:mm:ss\"");
                sw.WriteLine("@attribute spread numeric");
                sw.WriteLine("@attribute mainClose numeric");

                sw.WriteLine("@attribute prop " + " {0,1,2,3}");
                sw.WriteLine("@data");
                sw.WriteLine();

                var hps = HpData.Instance.GetHpSum(cp.MainSymbol, cp.MainPeriod);
                var hpdv = hpdvs[0, 0];
                for (int i = preLength - 1; i < hpdv.Length; ++i)
                {
                    DateTime nowDate = WekaUtils.GetDateFromTime((long)hpdv[i].Time);
                    //if (nowDate.Hour % TestParameters2.MainPeriodOfHour != 0)
                    //    continue;

                    if (!hps.ContainsKey(nowDate) && !(TestParameters2.RealTimeMode && i == hpdv.Length - 1))
                        continue;

                    long hpTime = WekaUtils.GetTimeFromDate(Parameters.MaxDate);
                    int hp = 0;
                    if (!(TestParameters2.RealTimeMode && i == hpdv.Length - 1))
                    {
                        hpTime = hps[nowDate].Item2;
                        hp = hps[nowDate].Item1;
                    }

                    sw.Write(nowDate.ToString(Parameters.DateTimeFormat));
                    sw.Write(",");

                    // hp
                    sw.Write(WekaUtils.GetDateFromTime(hpTime).ToString(Parameters.DateTimeFormat));
                    sw.Write(",");

                    sw.Write(Convert.ToInt32(hpdv[i]["spread"]));
                    sw.Write(",");

                    sw.Write(((double)hpdv[i]["close"]).ToString());
                    sw.Write(",");

                    sw.WriteLine(hp.ToString());
                }
            }
        }
        public static bool Filter(DateTime nowDate, weka.core.Instance instance = null, weka.core.Instance preInstance = null)
        {
            //if (nowDate.DayOfWeek == DayOfWeek.Friday && nowDate.AddDays(7).Month != nowDate.Month)
            //    return true;
            if (nowDate.DayOfWeek == DayOfWeek.Friday)
                return true;

            //var cp = TestParameters2.CandidateParameter;
            //string symbolPeriod = string.Format("{0}_{1}", cp.MainSymbol, cp.MainPeriod);
            //ForexDataRows hpdv = DbData.Instance.GetDbData(TestParameters2.TrainStartTime, TestParameters2.TrainEndTime, symbolPeriod, 0, true, cp);
            //int idx = hpdv.BinarySearch(0, hpdv.Length, WekaUtils.GetTimeFromDate(nowDate));
            //if (idx < 1)
            //    return true;

            //if ((int)hpdv[idx]["spread"] >= 50)
            //    return true;
            //if (Math.Abs((double)hpdv[idx]["close"] - (double)hpdv[idx-1]["close"]) > 0.0050)
            //    return true;

            if (instance != null)
            {
                if (instance.value(2) > 60)
                    return true;
                if (Math.Abs((double)instance.value(3) - (double)preInstance.value(3)) > 0.0050)
                    return true;
            }
            else
            {
                var dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(string.Format("SELECT TOP 2 * FROM {0}_{1} WHERE TIME <= {2} ORDER BY TIME DESC",
                TestParameters2.CandidateParameter.MainSymbol, TestParameters2.CandidateParameter.MainPeriod,
                WekaUtils.GetTimeFromDate(nowDate)));

                if ((int)dt.Rows[0]["spread"] > 50)
                    return true;

                if ((double)dt.Rows[0]["close"] - (double)dt.Rows[1]["close"] > 0.0050)// && selectedDeal == 0)
                    return true;
                if ((double)dt.Rows[0]["close"] - (double)dt.Rows[1]["close"] < -0.0050)// && selectedDeal == 1)
                    return true;

                //if ((double)dt.Rows[0]["MA_10"] - (double)dt.Rows[1]["MA_10"] < 0 && selectedDeal == 0)
                //    return true;
                //if ((double)dt.Rows[0]["MA_10"] - (double)dt.Rows[1]["MA_10"] > 0 && selectedDeal == 1)
                //    return true;

                //dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(string.Format("SELECT TOP 1 * FROM {0}_{1} WHERE TIME = {2} ORDER BY TIME",
                //    TestParameters2.CandidateParameter.MainSymbol, TestParameters2.CandidateParameter.MainPeriod,
                //    WekaUtils.GetTimeFromDate(nowDate)));
                //if ((double)dt.Rows[0]["MACD_12_26_9_M"] >= 0 && selectedDeal == 1)
                //    return true;
                //if ((double)dt.Rows[0]["MACD_12_26_9_M"] <= 0 && selectedDeal == 0)
                //    return true;
                //if ((double)dt.Rows[0]["RSI_14"] >= 70 && selectedDeal == 0)
                //    return true;
                //if ((double)dt.Rows[0]["RSI_14"] <= 30 && selectedDeal == 1)
                //    return true;
            }
            return false;
        }

        public string BuildHpProbDeals(bool withPrice = false)
        {
            WekaUtils.Instance.WriteLog("Now BuildHpProbDeals");

            var cp = TestParameters2.CandidateParameter;
            string resultFile = TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_{1}_{2}.txt",
                 cp.MainSymbol, "HpProb", cp.MainPeriod));
            if (File.Exists(resultFile))
                return string.Empty;

            string arffFileName = TestParameters.GetBaseFilePath(string.Format("{0}_{1}_{2}.arff",
                cp.MainSymbol, "HpProb", cp.MainPeriod));

            if (!System.IO.File.Exists(arffFileName))
            {
                GenerateHpProbArff(arffFileName);
            }

            weka.core.Instances allInstances = WekaUtils.LoadInstances(arffFileName);

            WekaUtils.SaveInstances(allInstances, arffFileName);

            int n = (int)(24 / TestParameters2.MainPeriodOfHour);
            n = TestParameters2.nPeriod;
            if (!withPrice)
            {
                return TestManager.IncrementTest(allInstances, () =>
                    {
                        return WekaUtils.CreateClassifier(typeof(InstancesProb));
                    }, "1,2,3,4", resultFile, n);   // 4: mainClose
            }
            else
            {
                return TestManager.IncrementTest(allInstances, () =>
                {
                    return WekaUtils.CreateClassifier(typeof(MyLibLinear), 0, 0, "-S 1 -C 1.0 -E 0.01 -B 1.0");
                }, "1,2,3", resultFile, n);
            }
        }


        public string BuildPricePatternDeals(bool withPrice = false)
        {
            WekaUtils.Instance.WriteLog("Now BuildPricePatternDeals");

            var cp = TestParameters2.CandidateParameter;
            string resultFile = TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_{1}_{2}.txt",
                cp.MainSymbol, "Price", cp.MainPeriod));
            if (File.Exists(resultFile))
                return string.Empty;

            TestParameters.EnablePerhourTrain = false;
            TestParameters.UseFilter = false;

            cp.DeleteUnusedIndicators();

            var dataDates = TestManager.GetDataDateRange();
            SetTrainTime(dataDates[0], dataDates[1]);
            WekaData wekaData = new WekaData(cp);

            string arffFileName = TestParameters.GetBaseFilePath(string.Format("{0}_{1}_{2}.arff",
                cp.MainSymbol, "Price", cp.MainPeriod));
            weka.core.Instances allInstances;
            if (!System.IO.File.Exists(arffFileName))
            {
                WekaData.GenerateArffTemplate(true, false, cp);

                wekaData.UseNullHp = true;
                wekaData.GenerateData(true, false);

                allInstances = wekaData.CurrentTrainInstances;

                var hps = HpData.Instance.GetHpSum(cp.MainSymbol, cp.MainPeriod);
                DateTime nextHpDate = DateTime.MinValue;
                weka.core.Instances newAllInstances = new weka.core.Instances(allInstances, 0);
                //java.util.LinkedList deleteList = new java.util.LinkedList();
                for (int i = 0; i < allInstances.numInstances(); ++i)
                {
                    DateTime nowDate = WekaUtils.GetDateValueFromInstances(allInstances, 0, i);
                    
                    if (TestParameters2.RealTimeMode && i == allInstances.numInstances() - 1)
                    {
                        allInstances.instance(i).setClassValue(0);
                        allInstances.instance(i).setValue(1, WekaUtils.GetTimeFromDate(Parameters.MaxDate) * 1000);

                        newAllInstances.add(allInstances.instance(i));
                    }
                    else if (hps.ContainsKey(nowDate))
                    {
                        int selectedDeal = hps[nowDate].Item1;
                        // 此时还不知道hp，不能滤
                        //if (TxtTest.Filter(nowDate, selectedDeal))
                        //{
                        //    deleteList.Add(allInstances.instance(i));
                        //}
                        //else
                        {
                            allInstances.instance(i).setClassValue(hps[nowDate].Item1);
                            allInstances.instance(i).setValue(1, hps[nowDate].Item2 * 1000);
                        }
                        
                        //if (nowDate < nextHpDate)
                        //{
                        //    deleteList.Add(allInstances.instance(i));
                        //}
                        //else
                        //{
                        //    DateTime hpDate = WekaUtils.GetDateTimeValueFromInstances(allInstances, 1, i);
                        //    nextHpDate = hpDate;
                        //}
                        newAllInstances.add(allInstances.instance(i));
                    }
                    else
                    {
                        //deleteList.Add(allInstances.instance(i));
                    }
                }
                //allInstances.removeAll(deleteList);
                allInstances = newAllInstances;
                WekaUtils.SaveInstances(allInstances, arffFileName);
            }
            else
            {
                allInstances = WekaUtils.LoadInstances(arffFileName);
            }
            //TestParameters.ClassifierType = typeof(weka.classifiers.lazy.IBk);
            //var cls = WekaUtils.CreateClassifier(0, 0);
            //TestParameters.ClassifierType = typeof(weka.classifiers.functions.LibSVM);

            //cls = WekaUtils.CreateClassifier(typeof(ProbClassifier));

            //GenerateHpDateSpan(allInstances);
            //return;

            int n = (int)(24 / TestParameters2.MainPeriodOfHour);
            n = TestParameters2.nPeriod;
            if (!withPrice)
            {
                return TestManager.IncrementTest(allInstances, () =>
                {
                    return WekaUtils.CreateClassifier(typeof(MyLibLinear), 0, 0, "-S 1 -C 1.0 -E 0.01 -B 1.0");
                    //return WekaUtils.CreateClassifier(typeof(weka.classifiers.lazy.IBk));
                    //return WekaUtils.CreateClassifier(typeof(ProbClassifier));
                    //return WekaUtils.CreateClassifier(typeof(InstancesProb));
                },
                "1,2,3,4,5,6,7,8", resultFile, n);
            }
            else
            {
                return TestManager.IncrementTest(allInstances, () =>
                {
                    return WekaUtils.CreateClassifier(typeof(MyLibLinear), 0, 0, "-S 1 -C 1.0 -E 0.01 -B 1.0");
                },
                "1,2,3,5,6,7,8", resultFile, n);
            }
        }

        public static void GenerateHpDateSpan(weka.core.Instances allInstances)
        {
            using (StreamWriter sw = new StreamWriter("d:\\a.txt"))
            {
                for (int i = 0; i < allInstances.numInstances(); ++i)
                {
                    DateTime nowDate = WekaUtils.GetDateValueFromInstances(allInstances, 0, i);
                    DateTime nowHpDate = WekaUtils.GetDateValueFromInstances(allInstances, 1, i);
                    sw.WriteLine((nowHpDate - nowDate).TotalMinutes);
                }
            }
        }
        public void BuildExcludeModels()
        {
            Parameters.TotalCanUseMemory = 600 * 1000 * 1000;
            
            TestParameters.SaveDataFile = false;
            //m_batchBufferMinutes = (new TimeSpan(365 + 5, 0, 0, 0)).TotalMinutes;

            weka.classifiers.Classifier cls = new weka.classifiers.functions.LibSVM();
            (cls as weka.classifiers.AbstractClassifier).setOptions(weka.core.Utils.splitOptions("-S 0 -K 2"));
            //Classifier cls = new MincostLiblinearClassifier();
            //Classifier cls = new weka.classifiers.functions.LibLINEAR();
            //(cls as AbstractClassifier).setOptions(weka.core.Utils.splitOptions("-S 0 -P -C 1 -B 1"));
            //var cls = new SvmLightClassifier();
            //cls.setOptions(weka.core.Utils.splitOptions("-c 20 -l 4 -w 1 --p 1 --b 1"));

            var cp = new CandidateParameter("BuildExcludeModels");
            cp.DeleteUnusedIndicators();

            ParameterdCandidateStrategy realDealCandidate = new ParameterdCandidateStrategy(cp);

            SetTrainTime(new DateTime(2009, 1, 1), new DateTime(2009, 4, 30));
            //m_generateOneClassHp = 0;

            realDealCandidate.IterateClassifierInfos2(new Func<CandidateClassifier, bool>((clsInfo) =>
            {
                string modelFileName = clsInfo.WekaData.GetExcludeModelFileName(clsInfo.Name);
                //if (!System.IO.File.Exists(modelFileName))
                {
                    WekaUtils.Instance.WriteLog(string.Format("{0} is building exclude model.", clsInfo.Name));

                    //clsInfo.WekaData.m_currentTestHour = clsInfo.Hour;
                    clsInfo.WekaData.GenerateData(true, false);
                    WekaUtils.TrainInstances(clsInfo.WekaData.CurrentTrainInstancesNew, modelFileName, cls);

                    MyEvaluation eval = new MyEvaluation();
                    eval.evaluateModel(cls, clsInfo.WekaData.CurrentTrainInstancesNew);
                    return true;
                }
                //else
                //{
                //    m_currentTestHour = h;
                //    GenerateData(true, false);

                //    cls = WekaUtils.TryLoadClassifier(modelFileName);
                //    var eval = WekaUtils.TestInstances(m_trainInstancesNew[k], cls);
                //}
            }));
        }

        //private int CalcAction(double r, bool isNominal = true)
        //{
        //    if (isNominal)
        //        return (int)r - 1;

        //    if (r > 7)
        //        return 1;
        //    else if (r < 3)
        //        return -1;
        //    else
        //        return 0;
        //}

        //public void GenerateModelAccordingInstancesRecordObsolete()
        //{
        //    SetTraining(true);

        //    Instances allInstances = new Instances(new BufferedReader(new FileReader(GetArffFileName())));
        //    allInstances.setClassIndex(allInstances.numAttributes() - 1);

        //    string instanceFileName = string.Format("{0}\\instance.txt", m_baseDir);
        //    using (StreamReader sr = new StreamReader(instanceFileName))
        //    {
        //        while (true)
        //        {
        //            string s = sr.ReadLine();
        //            if (string.IsNullOrEmpty(s))
        //                break;
        //            string[] ss = s.Split(new char[] { ':', ',' }, StringSplitOptions.RemoveEmptyEntries);

        //            Instances currentInstances = new Instances(allInstances, 0);
        //            for (int i = 1; i < ss.Length - 1; ++i)
        //            {
        //                currentInstances.add(allInstances.instance(Convert.ToInt32(ss[i])));
        //            }
        //            AbstractClassifier cls = new weka.classifiers.functions.LibSVM();
        //            cls.setOptions(weka.core.Utils.splitOptions("-S 0 -K 2 -D 3 -G 0.0 -R 0.0 -N 0.5 -M 40.0 -C 1.0 -E 0.0010 -P 0.1"));

        //            WekaUtils.TrainInstances(cls, trainInstances);

        //            Evaluation eval = new Evaluation(currentInstances);
        //            eval.evaluateModel(cls, currentInstances);

        //            ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(string.Format("{0}\\{1}.model", m_baseDir, ss[0])));
        //            oos.writeObject(cls);
        //            oos.flush();
        //            oos.close();
        //        }
        //    }
        //}
        //public void TestWithWeka3Obsolete()
        //{
        //    string instanceFileName = string.Format("{0}\\instance.txt", m_baseDir);

        //    SetTraining(true);
        //    Instances allInstances = new Instances(new BufferedReader(new FileReader(GetArffFileName())));
        //    allInstances.setClassIndex(allInstances.numAttributes() - 1);

        //    SetTraining(false);
        //    Instances testInstances = new Instances(new BufferedReader(new FileReader(GetArffFileName())));
        //    testInstances.setClassIndex(allInstances.numAttributes() - 1);

        //    System.Data.DataTable dt = DbHelper.Instance.ExecuteDataTable(string.Format("SELECT time, {5} FROM {0} WHERE time >= '{1}' and time < '{2}' and {3} {4}",
        //        m_symbolPeriod, m_testTimeStart.ToString(m_dateFormat), m_testTimeEnd.ToString(m_dateFormat), m_selectWhere, m_selectOrder, m_hpColumn));
        //    if (testInstances.numInstances() != dt.Rows.Count)
        //    {
        //        WriteLog("different count!");
        //        return;
        //    }

        //    using (StreamWriter sw = new StreamWriter(string.Format("{0}\\ea_order.txt", m_baseDir), false))
        //    {
        //        for (int k = 0; k < testInstances.numInstances(); k++)
        //        {
        //            Classifier selectClassifier = null;
        //            double minError = double.MaxValue;

        //            using (StreamReader sr = new StreamReader(instanceFileName))
        //            {
        //                while (true)
        //                {
        //                    string s = sr.ReadLine();
        //                    if (string.IsNullOrEmpty(s))
        //                        break;
        //                    string[] ss = s.Split(new char[] { ':', ',' }, StringSplitOptions.RemoveEmptyEntries);

        //                    Instances currentInstances = new Instances(allInstances, 0);
        //                    for (int i = 1; i < ss.Length - 1; ++i)
        //                    {
        //                        currentInstances.add(allInstances.instance(Convert.ToInt32(ss[i])));
        //                    }
        //                    currentInstances.add(testInstances.instance(k));

        //                    AbstractClassifier cls = new weka.classifiers.functions.LibSVM();
        //                    cls.setOptions(weka.core.Utils.splitOptions("-S 0 -K 2 -D 3 -G 0.0 -R 0.0 -N 0.5 -M 40.0 -C 1.0 -E 0.0010 -P 0.1"));

        //                    WekaUtils.TrainInstances(cls, trainInstances);

        //                    Evaluation eval = new Evaluation(currentInstances);
        //                    eval.evaluateModel(cls, currentInstances);

        //                    if (eval.rootMeanSquaredError() < minError)
        //                    {
        //                        minError = eval.rootMeanSquaredError();
        //                        selectClassifier = cls;
        //                    }
        //                }
        //            }

        //            double v = selectClassifier.classifyInstance(testInstances.instance(k));
        //            double clsLabel = CalcAction(v);
        //            if (clsLabel > 0.01)
        //                sw.WriteLine(string.Format("Buy, {0}, 0, 0, 0, 0", ((DateTime)dt.Rows[k]["time"]).ToString(m_dateTimeFormat)));
        //            else if (clsLabel < -0.01)
        //                sw.WriteLine(string.Format("Sell, {0}, 0, 0, 0, 0", ((DateTime)dt.Rows[k]["time"]).ToString(m_dateTimeFormat)));
        //            else
        //                sw.WriteLine(string.Format("Hold, {0}, 0, 0, 0, 0", ((DateTime)dt.Rows[k]["time"]).ToString(m_dateTimeFormat)));
        //        }
        //    }
        //}

        //public void TestWithWeka2Obsolete()
        //{
        //    string instanceFileName = string.Format("{0}\\instance.txt", m_baseDir);

        //    SetTraining(false);

        //    Dictionary<int, int> modelInstance = new Dictionary<int, int>();
        //    using (StreamReader sr = new StreamReader(instanceFileName))
        //    {
        //        while (true)
        //        {
        //            string s = sr.ReadLine();
        //            if (string.IsNullOrEmpty(s))
        //                break;
        //            string[] ss = s.Split(new char[] { ':', ',' }, StringSplitOptions.RemoveEmptyEntries);
        //            modelInstance[Convert.ToInt32(ss[0])] = ss.Length - 1;
        //        }
        //    }

        //    Instances origInstances = new Instances(new BufferedReader(new FileReader(GetArffFileName())));
        //    origInstances.setClassIndex(origInstances.numAttributes() - 1);

        //    System.Data.DataTable dt = DbHelper.Instance.ExecuteDataTable(string.Format("SELECT time, {5} FROM {0} WHERE time >= '{1}' and time < '{2}' and {3} {4}",
        //        m_symbolPeriod2, m_testTimeStart.ToString(m_dateFormat), m_testTimeEnd.ToString(m_dateFormat), m_selectWhere, m_selectOrder, m_hpColumn));
        //    if (origInstances.numInstances() != dt.Rows.Count)
        //    {
        //        WriteLog("different count!");
        //        return;
        //    }
        //    Instances testInstance = new Instances(origInstances);

        //    Dictionary<Classifier, int> clses = new Dictionary<Classifier, int>();

        //    foreach (var kvp in modelInstance)
        //    {
        //        //if (!fileName.EndsWith("\\0.model"))
        //        //    continue;
        //        string fileName = string.Format("{0}\\{1}.model", m_baseDir, kvp.Key.ToString());
        //        ObjectInputStream ois = new ObjectInputStream(new FileInputStream(fileName));
        //        Classifier cls = (Classifier)ois.readObject();
        //        ois.close();

        //        weka.classifiers.functions.LibSVM libSVM = cls as weka.classifiers.functions.LibSVM;

        //        clses[cls] = kvp.Value;
        //    }

        //    using (StreamWriter sw = new StreamWriter(string.Format("{0}\\ea_order.txt", m_baseDir), false))
        //    {
        //        // label instances
        //        for (int i = 0; i < origInstances.numInstances(); i++)
        //        {
        //            double sumLabel = 0;
        //            int sumCnt = 0;
        //            foreach (var kvp in clses)
        //            {
        //                try
        //                {
        //                    double v = kvp.Key.classifyInstance(origInstances.instance(i));

        //                    sumLabel += CalcAction(v) * kvp.Value;
        //                    sumCnt += kvp.Value;
        //                }
        //                catch (Exception)
        //                {
        //                }
        //            }

        //            double clsLabel = sumLabel / sumCnt;
        //            testInstance.instance(i).setClassValue(Math.Sign(clsLabel));

        //            clsLabel = origInstances.instance(i).classValue() - 1;
        //            //clsLabel = origInstances.instance(i).value(4);
        //            //if (clsLabel > -20)
        //            //    clsLabel = -1;
        //            ////else if (clsLabel < -90)
        //            ////    clsLabel = 1;
        //            //else
        //            //    clsLabel = 0;

        //            if (clsLabel > 0.01)
        //                sw.WriteLine(string.Format("Buy, {0}, 0, 0, 0, 0", ((DateTime)dt.Rows[i]["time"]).ToString("yyyy.MM.dd HH:mm")));
        //            else if (clsLabel < -0.01)
        //                sw.WriteLine(string.Format("Sell, {0}, 0, 0, 0, 0", ((DateTime)dt.Rows[i]["time"]).ToString("yyyy.MM.dd HH:mm")));
        //            else
        //                sw.WriteLine(string.Format("Hold, {0}, 0, 0, 0, 0", ((DateTime)dt.Rows[i]["time"]).ToString("yyyy.MM.dd HH:mm")));
        //        }
        //    }

        //    //BufferedWriter writer = new BufferedWriter(new FileWriter(string.Format("c:\\eurusd_m1_arff.result")));
        //    //writer.write(testInstance.toString());
        //    //writer.newLine();
        //    //writer.flush();
        //    //writer.close();
        //}

        //public void TestWithWekaMultiModel()
        //{
        //    SetTraining(false);
        //    string testAppend = m_newFileAppend;

        //    string eaorderFileName = string.Format("{0}\\ea_order.txt", m_baseDir);
        //    if (System.IO.File.Exists(eaorderFileName))
        //    {
        //        System.IO.File.Delete(eaorderFileName);
        //    }

        //    const string modelDirPrefix = "\\model_libsvm";

        //    Dictionary<DateTime, Classifier> clss = new Dictionary<DateTime, Classifier>();
        //    //m_trainTimeStart = new DateTime(2010, 1, 1);
        //    //m_trainTimeEnd = new DateTime(2010, 6, 30);
        //    //m_testTimeStart = new DateTime(2010, 6, 30);
        //    //m_testTimeEnd = new DateTime(2010, 7, 10);
        //    foreach (string testFileName in System.IO.Directory.GetFiles(m_baseDir, string.Format("eurusd_*.{0}.arff", m_newFileAppend)))
        //    {
        //        string[] ss2 = System.IO.Path.GetFileNameWithoutExtension(testFileName).Replace("." + m_newFileAppend, "").Split(new char[] { '_' }, StringSplitOptions.RemoveEmptyEntries);
        //        if (ss2.Length != 5)
        //            continue;

        //        try
        //        {
        //            m_trainTimeStart = ConvertFileNameToDateTime(ss2[1]);
        //            m_trainTimeEnd = ConvertFileNameToDateTime(ss2[2]);
        //            m_testTimeStart = ConvertFileNameToDateTime(ss2[3]);
        //            m_testTimeEnd = ConvertFileNameToDateTime(ss2[4]);
        //        }
        //        catch (Exception)
        //        {
        //            continue;
        //        }
        //        WriteLog("Load instance of " + testFileName);

        //        Instances testInstances = new Instances(new BufferedReader(new FileReader(GetArffFileName(testAppend))));
        //        testInstances.setClassIndex(testInstances.numAttributes() - 1);

        //        System.Data.DataTable dt = DbHelper.Instance.ExecuteDataTable(string.Format("SELECT date FROM {0} WHERE date >= '{1}' and date < '{2}' and {3} {4}",
        //                    m_symbolPeriod2, m_testTimeStart.ToString(m_dateFormat), m_testTimeEnd.ToString(m_dateFormat), m_selectWhere, m_selectOrder));
        //        if (testInstances.numInstances() != dt.Rows.Count)
        //        {
        //            WriteLog("different count!");
        //        }
        //        else
        //        {
        //            using (StreamWriter sw = new StreamWriter(eaorderFileName, true))
        //            {
        //                for (int i = 0; i < testInstances.numInstances(); i++)
        //                {
        //                    int sa = 0, sb = 0, sc = 0;
        //                    foreach (string modelFileName in System.IO.Directory.GetFiles(m_baseDir + modelDirPrefix, "*.model"))
        //                    {
        //                        string[] ss = System.IO.Path.GetFileNameWithoutExtension(modelFileName).Split(new char[] { '_' }, StringSplitOptions.RemoveEmptyEntries);
        //                        if (ss.Length != 3)
        //                            continue;
        //                        DateTime dt1 = ConvertFileNameToDateTime(ss[1]);
        //                        if (dt1 > m_trainTimeStart)
        //                            continue;
        //                        Classifier cls;
        //                        if (!clss.ContainsKey(dt1))
        //                        {
        //                            WriteLog("Load model of " + modelFileName);

        //                            ObjectInputStream ois = new ObjectInputStream(new FileInputStream(modelFileName));
        //                            cls = (Classifier)ois.readObject();
        //                            ois.close();

        //                            clss[dt1] = cls;
        //                        }
        //                        cls = clss[dt1];

        //                        double v = cls.classifyInstance(testInstances.instance(i));
        //                        //double v = origInstances.instance(i).classValue();
        //                        double clsLabel = CalcAction(v);

        //                        if (clsLabel > 0)
        //                            sa++;
        //                        else if (clsLabel < 0)
        //                            sc++;
        //                        else
        //                            sb++;
        //                    }

        //                    int sn = sa + sb + sc;
        //                    if ((double)sa / sn > 0.6)
        //                        sw.WriteLine(string.Format("Buy, {0}, 0, 0, 0, 0", ((DateTime)dt.Rows[i]["date"]).ToString(m_dateTimeFormat)));
        //                    else if ((double)sc / sn > 0.6)
        //                        sw.WriteLine(string.Format("Sell, {0}, 0, 0, 0, 0", ((DateTime)dt.Rows[i]["date"]).ToString(m_dateTimeFormat)));
        //                    else
        //                        sw.WriteLine(string.Format("Hold, {0}, 0, 0, 0, 0", ((DateTime)dt.Rows[i]["date"]).ToString(m_dateTimeFormat)));
        //                }
        //            }
        //            WriteLog("Test finish.");
        //        }
        //    }
        //}
    }
}
