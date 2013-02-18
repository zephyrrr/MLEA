using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

using java.io;
using java.util;
using weka.core;
using weka.classifiers;
using weka.classifiers.trees;


namespace MLEA
{
    class Program
    {
        static void Main(string[] args)
        {
            System.Console.Write("File Date: ");
            System.Console.WriteLine(System.IO.File.GetLastWriteTime(System.Reflection.Assembly.GetExecutingAssembly().Location));

            try
            {
                Microsoft.Practices.ServiceLocation.ServiceLocator.SetLocatorProvider(new Microsoft.Practices.ServiceLocation.ServiceLocatorProvider(
                delegate()
                {
                    return new EmptyServiceProvider();
                }));

                //Feng.Utils.SecurityHelper.SelectAutomaticServer();

                java.lang.System.setOut(new PrintStream(new ByteArrayOutputStream()));
                java.util.TimeZone.setDefault(java.util.TimeZone.getTimeZone("GMT"));

                string cmdSymbol = "EURUSD";
                if (args.Length == 2)
                {
                    if (args[0] == "-s")
                    {
                        cmdSymbol = args[1];
                    }
                }
                //if (args.Length > 0)
                //{
                //    int n = ea.ReadConfig(args);
                //    if (n == 1)
                //        return;
                //}

                //DbUtils.CompensateMissingDateAll();
                //DbUtils.CheckDataIntegrityAll();
                //DbUtils.CheckDateIntegrityOfCount();
                //DbUtils.CheckDbZeroValues();
                //DbUtils.ConvertHpdataFromSaturday2Monday();
                //TestTool.CheckMtData("EURUSD_M1");
                //TestTool.CheckMtHpData("EURUSD");
                //DbUtils.ImportToDbAll("EURUSD", "M30");
                //DbUtils.CalculateUSDX();
                //DbUtils.GeneratePeriodData("USDX", "D1", 0);
                //DbUtils.GenerateIndicators("USDX", "D1");
                //return;
                //DbUtils.GenerateRandomData("EURUSD");

                //TestParameters2.InitParameters("EURUSD", "M15", 1);
                //string updateHpWhere = string.Format("TIME >= {0} AND TIME < {1} AND Time % 1800 = 0",
                //    WekaUtils.GetTimeFromDate(new DateTime(2000, 1, 1)), WekaUtils.GetTimeFromDate(new DateTime(2013, 1, 1)));
                //DbUtils.UpdateAllHp3("EURUSD", updateHpWhere);

                //WekaEA.WekaEA2 wekaEA2 = new WekaEA.WekaEA2();
                //wekaEA2.Init("EURUSD");
                //wekaEA2.RunTool("ImportDB");
                //WekaEA.WekaEA2.SimulateMt("EURUSD");
                //return;

                //SimulateIncrementTest();

                //TestTool.GenerateConsoleCCs();

                //TestTool.CheckHpData();
                //TestTool.GetResultCost("f:\\Forex\\console.2000-2012.USDCHF.w8.txt", "d:\\result8.txt");
                //TestTool.ParseMtReport4Consecutive();
                //TestTool.TestMultiClassifierResult();

                //DbUtils.CheckDbCountToSame("D1");

                //TestTool.ReorderEaOrderTxt(string.Format("f:\\forex\\TestDebug\\ea_order_{0}.txt", TestParameters2.CandidateParameter.MainSymbol),
                //    "f:\\forex\\TestDebug\\ea_order.txt", 1);
                //TestTool.GenerateHpAccordCloseTime("USDCHF");
                //TestTool.ConvertHpAccordCloseTime();
                //DbUtils.GeneratePeriodData("IF9999", "D1", TestParameters2.HourAhead);
                //DbUtils.GenerateIndicators("AUDUSD", "D1");
                //TestTool.ParseDetailDealLog(string.Format("{0}_ccScores_w{1}", TestParameters2.CandidateParameter.MainSymbol, TestParameters2.lastWeek));

                //string symbol = cmdSymbol;

                TestTool.ParseTotalResult("e:\\total_result.txt", "e:\\ff", true);
                //foreach (var s in Parameters.AllSymbolsFull)
                //{
                //    string fileName = string.Format("\\\\192.168.0.10\\f$\\Forex\\Test_{0}\\total_result.txt", s);
                //    if (System.IO.File.Exists(fileName))
                //        TestTool.ParseTotalResult(fileName, s);
                //}

                TaLibTest taLibTest = new TaLibTest();
                TestManager tm = new TestManager();
                TxtTest txtTest = new TxtTest();

                foreach (string s in new string[] { "EURUSD" })//"GBPUSD", "EURUSD", "USDCHF","AUDUSD", "USDJPY", "USDCAD"
                {
                    foreach (string p in new string[] { "M15" })//"M5", "M15", "M30", "H1", "H4", "D1" })
                    {
                        TestParameters2.InitParameters(s, p, 1);
                        TestParameters.TestName = "Test_" + s;

                        System.IO.File.Delete(TestParameters.GetBaseFilePath("console.txt"));
                        foreach (string s1 in Directory.GetFiles(TestParameters.BaseDir, "ea_order*.txt"))
                            System.IO.File.Delete(s1);

                        //TxtTest.SimulateEaOrders();

                        HpData.Instance.GenerateHpDataToTxt(TestParameters2.CandidateParameter.MainSymbol, TestParameters2.CandidateParameter.MainPeriod);

                        bool[,] selectedTpSl = new bool[20, 20];
                        for (int i = 0; i < 20; i += 1)
                            for (int j = 0; j < 20; j += 1)
                                selectedTpSl[i, j] = false;

                        bool onlyOneTime = false;

                        for (int t = 0; t < 1; ++t)
                        {
                            //TestParameters2.TrainStartTime = (new DateTime(2010, 1, 1)).AddMonths(12 * t);
                            //TestParameters2.TrainEndTime = (new DateTime(2010, 1, 1)).AddMonths(12 * (t + 1));
                            //if (TestParameters2.TrainStartTime > new DateTime(2012, 8, 1))
                            //    break;

                            string resultFileName = TestParameters.GetBaseFilePath("total_result.txt");
                            var alreadyResults = TestTool.ParseTotalResult(resultFileName, null);

                            for (int i = 9; i >= 2; i -= 1)
                            {
                                for (int j = 19; j >= 2; j -= 1)
                                {
                                    if (alreadyResults[i, j] != -1)
                                        continue;

                                    if (!onlyOneTime)
                                    {
                                        TestParameters2.slStart = i;
                                        TestParameters2.slCount = i + 1;
                                        TestParameters2.tpStart = j;
                                        TestParameters2.tpCount = j + 1;
                                    }

                                    using (StreamWriter sw = new StreamWriter(resultFileName, true))
                                    {
                                        sw.WriteLine(string.Format("{0},{1},{2},{3}",
                                               TestParameters2.slStart, TestParameters2.slCount,
                                               TestParameters2.tpStart, TestParameters2.tpCount));

                                        if (!(args.Length >= 1 && args[0] == "-t"))
                                        {
                                            foreach (string s1 in Directory.GetFiles(TestParameters.BaseDir, "IncrementTest_*.txt"))
                                                System.IO.File.Delete(s1);
                                            foreach (string s1 in Directory.GetFiles(TestParameters.BaseDir, "*.arff"))
                                                System.IO.File.Delete(s1);
                                        }

                                        try
                                        {
                                            TestParameters2.OutputParameters();

                                            var s0 = tm.BuildHpProbDeals();
                                            sw.WriteLine(s0);

                                            var s1 = tm.BuildPricePatternDeals();
                                            sw.WriteLine(s1);

                                            var s2 = taLibTest.BuildCandlePatternDeals();
                                            sw.WriteLine(s2);

                                            //foreach (string w in new string[] { "1" })
                                            //{
                                            //    TestParameters2.lastWeek = w;
                                            //    try
                                            //    {
                                            //        CCScoreData.Instance.GenerateData(s, Convert.ToInt32(w));
                                            //    }
                                            //    catch (Exception ex)
                                            //    {
                                            //        WekaUtils.Instance.WriteLog(ex.Message);
                                            //    }

                                            //    CCScoreData.Instance.GenerateDataToTxt(TestParameters2.CandidateParameter.MainSymbol, TestParameters2.lastWeek);
                                            //    txtTest.BuildCCScoreDeals();
                                            //}

                                            WekaUtils.Instance.DeInit();

                                            string result;
                                            if (selectedTpSl[i, j] || onlyOneTime)
                                            {
                                                if (selectedTpSl[i, j])
                                                {
                                                    sw.WriteLine(string.Format("{0} select {1},{2}",
                                                        TestParameters2.TrainStartTime.ToString(Parameters.DateTimeFormat), i, j));
                                                }
                                                result = txtTest.SimulateAccordDealLog(true);
                                            }
                                            else
                                            {
                                                result = txtTest.SimulateAccordDealLog(false);
                                            }
                                            sw.WriteLine(result);
                                            sw.Flush();

                                            string profitString = WekaUtils.GetSubstring(result, "ProfitFactor = ");
                                            double profitFactor = 0;
                                            if (!string.IsNullOrEmpty(profitString))
                                                profitFactor = Convert.ToDouble(profitString);
                                            if (profitFactor > 1.1)
                                                selectedTpSl[i, j] = true;
                                            else
                                                selectedTpSl[i, j] = false;

                                            if (!onlyOneTime)
                                            {
                                                foreach (string is1 in Directory.GetFiles(TestParameters.BaseDir, "IncrementTest_*.txt"))
                                                {
                                                    string is2 = string.Format("{0}_{1}_{2}.txt", is1.Replace(".txt", "").Replace("IncrementTest_", "IncrementTest2_"), i, j);
                                                    System.IO.File.Delete(is2);
                                                    System.IO.File.Move(is1, is2);
                                                }

                                                WekaUtils.Instance.DeInit();
                                                foreach (string is1 in Directory.GetFiles(TestParameters.BaseDir, "console.txt"))
                                                {
                                                    string is2 = string.Format("{0}_{1}_{2}.txt", is1.Replace(".txt", ""), i, j);
                                                    System.IO.File.Delete(is2);
                                                    System.IO.File.Move(is1, is2);
                                                }
                                            }
                                        }
                                        catch (Exception ex)
                                        {
                                            WekaUtils.Instance.WriteLog(ex.Message);
                                            WekaUtils.Instance.WriteLog(ex.StackTrace);
                                        }

                                        TestManager.Clear();

                                        if (onlyOneTime)
                                            break;
                                    }
                                    if (onlyOneTime)
                                        break;
                                }

                                HpData.Instance.Clear();
                                DbData.Instance.Clear();
                                taLibTest.Clear();
                                WekaData.ClearTemplates();
                                CCScoreData.Instance.Clear();
                            }
                        }
                        TxtTest.SortEaOrders();
                    }
                }

                //foreach (string s in new string[] { "GBPUSD", "AUDUSD", "USDJPY", "USDCAD", "USDCHF", "EURUSD" })
                //{
                //    TestParameters.TestName = "Test_" + s;
                //    TestParameters2.InitParameters(s, "M5", 1);

                //    foreach (string w in new string[] { "1" })
                //    {
                //        TestParameters2.lastWeek = w;
                //        try
                //        {
                //            CCScoreData.Instance.GenerateData(s, Convert.ToInt32(w));
                //        }
                //        catch (Exception ex)
                //        {
                //            WekaUtils.Instance.WriteLog(ex.Message);
                //        }
                //    }

                //    foreach (string p in new string[] { "M5", "M15", "M30", "H1", "H4", "D1" })
                //    {
                //        TestParameters.TestName = "Test_" + s;

                //        if (p == "M5")
                //            TestParameters2.MaxTrainSize = TestParameters2.MinTrainSize = 5;
                //        else
                //            TestParameters2.MaxTrainSize = TestParameters2.MinTrainSize = 2;

                //        TestParameters2.InitParameters(s, p, 1);
                //        //TestParameters2.tpCount = TestParameters2.slCount = 20;

                //        //TestParameters2.InitParameters(symbol, "D1", 4);
                //        //TestParameters2.tpCount = TestParameters2.slCount = 10;
                //        //TestParameters2.tpStart = TestParameters2.slStart = 9;

                //        TestParameters2.OutputParameters();

                //        foreach (string w in new string[] { "1" })
                //        {
                //            TestParameters2.lastWeek = w;

                //            CCScoreData.Instance.GenerateDataToTxt(TestParameters2.CandidateParameter.MainSymbol, TestParameters2.lastWeek);
                //            txtTest.BuildCCScoreDeals();
                //        }
                //    }
                //}

                ///////////////////////////////////////////////////////////////////////////////////
                WaitForThreads();
                //Feng.Utils.SecurityHelper.DeselectAutomaticServer();
            }
            catch (Exception ex)
            {
                System.Console.WriteLine(ex.Message);
                System.Console.WriteLine(ex.StackTrace);
                System.Console.ReadLine();
            }

            System.Console.WriteLine("End");
            System.Console.Beep();

            ReadLine(60000);
        }

        private static string ReadLine(int timeoutms)
        {
            System.Console.WriteLine("Wait Input");
            ReadLineDelegate d = System.Console.ReadLine;
            IAsyncResult result = d.BeginInvoke(null, null);
            result.AsyncWaitHandle.WaitOne(timeoutms);//timeout e.g. 15000 for 15 secs
            if (result.IsCompleted)
            {
                string resultstr = d.EndInvoke(result);
                System.Console.WriteLine("Read: " + resultstr);
                return resultstr;
            }
            else
            {
                System.Console.WriteLine("Timed out!");
                //throw new TimedoutException("Timed Out!");
                return null;
            }
        }
        delegate string ReadLineDelegate();

        private static void WaitForThreads()
        {
            int maxThreads = 0;
            int placeHolder = 0;
            int availThreads = 0;
            int timeOutSeconds = 1000000000;

            //Now wait until all threads from the Threadpool have returned
            while (timeOutSeconds > 0)
            {
                //figure out what the max worker thread count it
                System.Threading.ThreadPool.GetMaxThreads(out 
                             maxThreads, out placeHolder);
                System.Threading.ThreadPool.GetAvailableThreads(out availThreads,
                                                               out placeHolder);

                if (availThreads == maxThreads) break;
                // Sleep
                System.Threading.Thread.Sleep(TimeSpan.FromMilliseconds(1000));
                --timeOutSeconds;
            }
        }
        private static void SimulateIncrementTest()
        {
            TxtTest txtTest = new TxtTest();

            string s = "EURUSD";
            string p = "M15";
            TestParameters2.InitParameters(s, p, 1);
            TestParameters.TestName = "Test_" + s;

            //double sum = 0;
            //for (int i = 0; i < 20; i += 1)
            //{
            //    for (int j = 0; j < 20; j += 1)
            //    {
            //        if (i < 4)
            //            continue;
            //        if (j < 6)
            //            continue;

            //        TestParameters2.slStart = i;
            //        TestParameters2.slCount = i + 1;
            //        TestParameters2.tpStart = j;
            //        TestParameters2.tpCount = j + 1;

            //        var cp = TestParameters2.CandidateParameter;
            //        string resultFile = TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_{1}_{2}.txt",
            //            cp.MainSymbol, "Price", cp.MainPeriod));
            //        string originalFile = string.Format("{0}_{1}_{2}.txt", resultFile.Replace(".txt", "").Replace("IncrementTest_", "IncrementTest2_"), i, j);
            //        System.IO.File.Delete(resultFile);
            //        if (System.IO.File.Exists(originalFile))
            //            System.IO.File.Copy(originalFile, resultFile);
            //        else
            //            continue;

            //        resultFile = TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_{1}_{2}.txt",
            //            cp.MainSymbol, "CandlePattern", cp.MainPeriod));
            //        originalFile = string.Format("{0}_{1}_{2}.txt", resultFile.Replace(".txt", "").Replace("IncrementTest_", "IncrementTest2_"), i, j);
            //        System.IO.File.Delete(resultFile);
            //        if (System.IO.File.Exists(originalFile))
            //            System.IO.File.Copy(originalFile, resultFile);
            //        else
            //            continue;

            //        resultFile = TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_{1}_{2}.txt",
            //            cp.MainSymbol, "HpProb", cp.MainPeriod));
            //        originalFile = string.Format("{0}_{1}_{2}.txt", resultFile.Replace(".txt", "").Replace("IncrementTest_", "IncrementTest2_"), i, j);
            //        System.IO.File.Delete(resultFile);
            //        if (System.IO.File.Exists(originalFile))
            //            System.IO.File.Copy(originalFile, resultFile);
            //        else
            //            continue;

            //        string result = txtTest.SimulateAccordDealLog(true);

            //        string profitString = WekaUtils.GetSubstring(result, "TotalProfit = ");
            //        double profitFactor = 0;
            //        if (!string.IsNullOrEmpty(profitString))
            //            profitFactor = Convert.ToDouble(profitString);

            //        sum += profitFactor;
            //    }
            //}
            //TxtTest.SortEaOrders();

            TxtTest.SimulateEaOrders();
        }

        public class EmptyServiceProvider : Microsoft.Practices.ServiceLocation.ServiceLocatorImplBase
        {
            protected override object DoGetInstance(Type serviceType, string key)
            {
                return null;
            }

            protected override IEnumerable<object> DoGetAllInstances(Type serviceType)
            {
                return null;
            }
        }
    }
}
