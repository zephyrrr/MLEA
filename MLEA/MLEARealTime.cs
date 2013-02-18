using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public class MLEARealTime
    {
        private TestManager m_tm = new TestManager();
        TaLibTest m_taLibTest = new TaLibTest();
        TxtTest m_txtTest = new TxtTest();

        public void Init()
        {
            TestParameters.EnablePerhourTrain = false;
            TestParameters.BatchTrainMinutes = 2 * 4 * 7 * 24 * 12 * 5;
            TestParameters.BatchTestMinutes = 1 * 24 * 12 * 5;

            //var realDealsCandidates = m_tm.AddRealDealCandidates(TestParameters2.CandidateParameter.MainSymbol, Convert.ToInt32(TestParameters2.lastWeek));
            //if (realDealsCandidates.Count != 1)
            //    throw new NotSupportedException("Now only one realDealsCandidate is supported!");
            //_realDealsCandidate = realDealsCandidates[0];
            //if (_realDealsCandidate.HasParent)
            //    throw new NotSupportedException("only one realDealsCandidate should be parent itself!");

            foreach (string s in System.IO.Directory.GetFiles(TestParameters.BaseDir, "IncrementTest_*.txt"))
            {
                System.IO.File.Delete(s);
            }
            foreach (string s in System.IO.Directory.GetFiles(TestParameters.BaseDir, "hpdata.*.txt"))
            {
                System.IO.File.Delete(s);
            }
        }
        //private ParameterdCandidateStrategy _realDealsCandidate;
        public void RunOnTick(long nowTime, MqlRates nowRate)
        {
            // We now updateHpData on every bar
            //DateTime nowDate = WekaUtils.GetDateFromTime(nowTime);

            //if (!TestParameters2.UseFutureHpData)
            //{
            //    realDealsCandidate.ExecuteCandidateNowDeals(nowDate, nowRate);
            //}
        }

        public void RunOnBar(long nowTime)
        {
            DateTime nowDate = WekaUtils.GetDateFromTime(nowTime);

            //TestParameters2.TrainStartTime = new DateTime(2000, 1, 1);
            if (nowDate < TestParameters2.TrainStartTime)
                return;
            TestParameters2.TrainEndTime = nowDate.AddSeconds(1);

            //// only for batchbatch
            //var ttts = m_tm.SetTimeMinutesFromTestEnd(nowDate,
            //    TestParameters.BatchTrainMinutes, TestParameters.BatchTestMinutes);
            //WekaUtils.DebugAssert((ttts[3] - nowDate).TotalMinutes < 1, "(ttts[3] - nowDate).TotalMinutes < 1");

            //Console.WriteLine(string.Format("TrainTime = {0}, {1}; TestTime = {2}, {3}", ttts[0], ttts[1], ttts[2], ttts[3]));
            //if (nowDate >= new DateTime(2004, 3, 29))
            //{
            //}

            //WekaUtils.Instance.WriteLog("Run ExecuteCandidate.");
            //if (!TestParameters2.DBDataConsistent)
            //{
            //    _realDealsCandidate.UpdateUnclosedDeals(nowDate);
            //}
            //_realDealsCandidate.ExecuteCandidate(nowDate);

            //WekaUtils.Instance.WriteLog("Run GenerateCCScores.");
            //GenerateCCScores(nowDate);

            bool inPrepare = false;
            if (TestParameters2.InPreparing)
                inPrepare = true;
            if ((TestParameters2.TrainEndTime - TestParameters2.TrainStartTime).TotalHours < TestParameters2.MinTrainSize * TestParameters2.MainPeriodOfHour)
                inPrepare = true;

            if (!inPrepare)
            {
                WekaUtils.Instance.WriteLog("Run GenerateHpDataToTxt.");
                HpData.Instance.GenerateHpDataToTxt(TestParameters2.CandidateParameter.MainSymbol, TestParameters2.CandidateParameter.MainPeriod);

                foreach (string s1 in System.IO.Directory.GetFiles(TestParameters.BaseDir, "*.arff"))
                    System.IO.File.Delete(s1);
                foreach (string s1 in System.IO.Directory.GetFiles(TestParameters.BaseDir, "IncrementTest_*.txt"))
                    System.IO.File.Delete(s1);

                //WekaUtils.Instance.WriteLog("Run BuildHpProbDeals.");
                m_tm.BuildHpProbDeals();

                //WekaUtils.Instance.WriteLog("Run BuildPricePatternDeals.");
                m_tm.BuildPricePatternDeals();

                //WekaUtils.Instance.WriteLog("Run BuildCandlePatternDeals.");
                m_taLibTest.BuildCandlePatternDeals();

                ////WekaUtils.Instance.WriteLog("Run BuildCCScoreDeals.");
                //m_txtTest.BuildCCScoreDeals();

                string orderFile = TestParameters.GetBaseFilePath(string.Format("ea_order_{0}.txt", TestParameters2.CandidateParameter.MainSymbol));
                System.IO.File.Delete(orderFile);
                m_txtTest.MergeAllBuildResult();

                if (System.IO.File.Exists(orderFile))
                {
                    string signalResultFile = "C:\\ProgramData\\MetaQuotes\\Terminal\\Common\\Files\\{0}_{1}.txt";
                    if (!TestParameters2.DBDataConsistent)
                    {
                        signalResultFile = string.Format(signalResultFile, "MLEASignal", TestParameters2.CandidateParameter.MainSymbol);
                    }
                    else
                    {
                        signalResultFile = string.Format(signalResultFile, "MLEASignal_db", TestParameters2.CandidateParameter.MainSymbol);
                    }
                    System.IO.File.Copy(orderFile, signalResultFile, true);
                }
            }

            HpData.Instance.Clear();
            DbData.Instance.Clear();
            m_taLibTest.Clear();
            WekaData.ClearTemplates();
            CCScoreData.Instance.Clear();

            System.GC.Collect();
        }

        private void GenerateCCScores(DateTime nowDate)
        {
            //long[, ,] ndas = new long[Parameters.AllDealTypes.Length, realDealsCandidate.CandidateParameter.BatchTps.Length, realDealsCandidate.CandidateParameter.BatchSls.Length];
            //long[, ,] ndss = new long[Parameters.AllDealTypes.Length, realDealsCandidate.CandidateParameter.BatchTps.Length, realDealsCandidate.CandidateParameter.BatchSls.Length];
            //double[, ,] nowScores = new double[Parameters.AllDealTypes.Length, realDealsCandidate.CandidateParameter.BatchTps.Length, realDealsCandidate.CandidateParameter.BatchSls.Length];

            //realDealsCandidate.IterateClassifierInfos((k, ii, jj, h) =>
            //    {
            //        nowScores[k, ii, jj] = realDealsCandidate.m_classifierInfoIdxs[k, ii, jj, h].Deals.NowScore;
            //        ndas[k, ii, jj] = realDealsCandidate.m_classifierInfoIdxs[k, ii, jj, h].Deals.DealLastTimeAvg;
            //        ndss[k, ii, jj] = realDealsCandidate.m_classifierInfoIdxs[k, ii, jj, h].Deals.DealLastTimeStd;
            //    });

            //string ccScoreFileName = TestParameters.GetBaseFilePath(string.Format("{0}_ccScores_w{2}_{1}.txt",
            //    TestParameters2.CandidateParameter.MainSymbol, TestParameters2.CandidateParameter.MainPeriod, TestParameters2.lastWeek));

            //CCScoreData.GenerateDateToTxt(ccScoreFileName, nowDate, nowScores, ndas, ndss);
        }
    }
}
