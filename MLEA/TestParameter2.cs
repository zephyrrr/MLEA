using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public static class TestParameters2
    {
        public static void InitParameters(string symbol = "EURUSD", string period = "D1", int ntpsl = 1)
        {
            //TestParameters.TpSlMaxCount = 30;
            //nTpsl = 2;
            nTpsl = ntpsl;

            if (tpCount == -1)
            {
                tpCount = TestParameters.TpMaxCount / nTpsl;
            }
            if (slCount == -1)
            {
                slCount = TestParameters.SlMaxCount / nTpsl;
            }

            //tpStart = slStart = 0;
            //tpCount = slCount = 10;

            var cp = CandidateParameter;

            cp.AllSymbols = new string[] { symbol };
            cp.SymbolStart = 0;
            cp.SymbolCount = cp.AllSymbols.Length;

            cp.AllPeriods = new string[] { period };
            cp.PeriodStart = 0;
            cp.PeriodCount = cp.AllPeriods.Length;

            cp.PrevTimeCount = PreLength;

            //int delta = TestParameters.GetTpSlMinDelta(symbol) * TestParameters2.nTpsl;
            //cp.InitTpsls(TestParameters2.tpStart, delta, TestParameters2.tpCount, TestParameters2.slStart, delta, TestParameters2.slCount);

            MainPeriodOfHour = WekaUtils.GetMinuteofPeriod(cp.MainPeriod) / 60.0;   // 24=D

            cp.InitIndicators();
        }
        static TestParameters2()
        {
            //if (Parameters.AllSymbols == null || Parameters.AllSymbols.Length == 0 || Parameters.AllSymbols.Length == 6)
            //{
                
            //}
            //InitParameters();
        }
        //public static string Symbol = "GBPUSD";
        //public static string Period = "D1";
        public static CandidateParameter CandidateParameter = new CandidateParameter("TestParameters2");

        public static double MainPeriodOfHour;

        public static string lastWeek = "4";

        public static int nTpsl = 1; // when 60:4, 30:2
        
        public static int slStart = 5;
        public static int slCount = 6;
        public static int tpStart = 9;
        public static int tpCount = 10;

        public static int nPeriod = 1;

        public static int MinTrainPeriod = 5000 * nPeriod;
        public static int MaxTrainSize = 20000 * nPeriod;
        public static int MinTrainSize = 1 * nPeriod;

        public static int PreLength = 1;

        public static bool UsePartialHpData = false;
        public static bool UsePartialHpDataM1 = false;

        //public static bool UsePartialHpData = true;
        //public static int PreLength = 1;
        //public static int MaxTrainSize = 5;
        //public static int MaxTrainPeriod = 600000;
        //public static int MinTrainSize = 5;
        //public static int slStart = 4;
        //public static int slCount = 5;
        //public static int tpStart = 5;
        //public static int tpCount = 14;

        public static int HourAhead = 0;

        public static DateTime TrainStartTime = new DateTime(2000, 1, 1);
        public static DateTime TrainEndTime = new DateTime(2012, 9, 1);

        public static bool RealTimeMode = false;

        public static bool DBDataConsistent = true;    // 数据库数据不会更改
        public static bool InPreparing = false;

        public static void OutputParameters()
        {
            WekaUtils.Instance.WriteHorizontalLine();
            WekaUtils.Instance.WriteLog(string.Format("TestParameter2 Values:"));
            TestManager.OutputTestInfoCandidate(TestParameters2.CandidateParameter);
            WekaUtils.Instance.WriteLog(string.Format("TrainStartTime = {0}, TrainEndTime = {1}", TrainStartTime.ToString(Parameters.DateTimeFormat), TrainEndTime.ToString(Parameters.DateTimeFormat)));
            WekaUtils.Instance.WriteLog(string.Format("MaxTrainSize = {0}", TestParameters2.MaxTrainSize));
            WekaUtils.Instance.WriteLog(string.Format("MaxTrainPeriod = {0}", TestParameters2.MinTrainPeriod));
            WekaUtils.Instance.WriteLog(string.Format("MinTrainSize = {0}", TestParameters2.MinTrainSize));
            WekaUtils.Instance.WriteLog(string.Format("UsePartialHpData = {0}", TestParameters2.UsePartialHpData));
            WekaUtils.Instance.WriteLog(string.Format("nTpsl = {0}", TestParameters2.nTpsl));
            WekaUtils.Instance.WriteLog(string.Format("slStart = {3}, slCount = {1}, tpStart = {2}, tpCount = {0}",
                TestParameters2.tpCount, TestParameters2.slCount, TestParameters2.tpStart, TestParameters2.slStart));
            WekaUtils.Instance.WriteLog(string.Format("lastWeek = {0}", TestParameters2.lastWeek));
            WekaUtils.Instance.WriteHorizontalLine();
        }
    }
}
