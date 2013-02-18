using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public static class TestParameters
    {
        public static CandidateParameter CandidateParameter4Db = new CandidateParameter("DbCp");

        public const int TpMaxCount = 20;
        public const int SlMaxCount = 20;
        private const int TlSlMinDelta = 10;

        //private static Dictionary<string, int> tpMinDeltas = new Dictionary<string, int>() { 
        //    { "EURUSD", 10 }, 
        //    { "GBPUSD", 10 },
        //    { "USDCHF", 10 },
        //    { "USDCAD", 10 },
        //    { "AUDUSD", 10 },
        //    { "USDJPY", 10 },
        //    { "EURGBP", 10 }};
        //private static Dictionary<string, int> slMinDeltas = tpMinDeltas;
        public static int GetTpSlMinDelta(string symbol)
        {
            //symbol = symbol.Substring(0, 6);
            //return tpMinDeltas[symbol];
            return TlSlMinDelta;
        }

        public static string DefaultTestName
        {
            get
            {
                string s;
#if DEBUG
                s = "TestDebug";
#else
                s = "TestDebug";// "TestRelease";
#endif
                return s;
            }
        }
        private static string BaseBaseDir;
        static TestParameters()
        {
            BaseBaseDir = "F:\\Forex";

            TestName = DefaultTestName;
            CommonDir = BaseBaseDir + "\\Common";
            if (!System.IO.Directory.Exists(CommonDir))
            {
                System.IO.Directory.CreateDirectory(CommonDir);
            }

            TmpDir = BaseBaseDir + "\\Tmp";
            if (!System.IO.Directory.Exists(TmpDir))
            {
                System.IO.Directory.CreateDirectory(TmpDir);
            }
        }

        //public static int GetSlMinDelta(string symbol)
        //{
        //    return slMinDeltas[symbol];
        //}

        public static string BaseDir;
        public static string CommonDir;
        public static string TmpDir;

        public static string GetBaseFilePath(string s)
        {
            return string.Format("{0}\\{1}", BaseDir, s);
        }

        private static string m_testName;
        public static string TestName
        {
            get { return m_testName; }
            set
            {
                m_testName = value;
                BaseDir = string.Format("{0}\\{1}", BaseBaseDir, TestName);
                if (!System.IO.Directory.Exists(BaseDir))
                {
                    System.IO.Directory.CreateDirectory(BaseDir);
                }
            }
        }

        public static string DbSelectWhere = "Time % 900 = 0";//"DATEPART(minute, date) % 3 = 0";

        // AND AskVolume IS NOT NULL AND BidVolume IS NOT NULL AND (AskVolume + BidVolume) > 10000

        public static bool EnableDetailLog = true;
        public const bool EnableExcludeClassifier = false;

        public static bool EnablePerhourTrain = false;

        public static int BatchTrainMinutes = 2 * 4 * 7 * 24 * 12 * 5;
        public static int BatchTestMinutes = 1 * 1 * 12 * 5;

        // Monday
        public static DateTime BatchDateStart = new DateTime(2009, 1, 9, 0, 0, 0); //(2007, 4, 2);    // (2009, 1, 5)
        public static DateTime BatchDateEnd = new DateTime(2011, 6, 30);

        public static bool SaveDataFile = false;
        public static bool SaveModel = false;
        public static bool SaveCCScoresToDb = false;

        public static bool EnnableLoadTestData = false;
        public static bool OnlyNewestTestDataSaved = true;

        public static bool EnableMultiThread = true;

        public static bool UseFilter = true; // Random时提高性能
        public static bool UseTrain = true; // Random时提高性能

        public static bool IndicatorUseNumeric = true;
    }
}
