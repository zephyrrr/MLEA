using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Data.SqlClient;
using Feng.Data;

using java.io;
using java.util;
using weka.core;
using weka.classifiers;
using weka.classifiers.trees;

#pragma warning disable 0429

namespace MLEA
{
    public class WekaData
    {
        private int m_currentTp = 20;
        private int m_currentSl = 20;
        private char m_currentDealType = 'B';

        //private bool m_useRandomData = false;

        private bool m_convertToLibsvm = false;

        //private bool m_enableTrain = true;
        private bool m_enableTest = true;
        private bool m_enableTrainSplitTest = false;
        private double m_trainSplitPercent = 100.0;
        private int m_trainSplitTestNums = -1;

        private const string m_hpColumn = "hp";
        private const string m_hpDateColumn = "hp_date";
        //private const int m_hpColumn = 1;
        //private const int m_hpDateColumn = 2;

        //private const string m_costFileName = m_commonDir + "\\cost2.cost";

        internal static DateTime m_trainTimeStart;
        internal static DateTime m_trainTimeEnd;
        internal static DateTime m_testTimeStart;
        internal static DateTime m_testTimeEnd;
        private static int m_currentTestHour = -1;
        public static void SetTrainTime(DateTime trainStart, DateTime trainEnd)
        {
            m_trainTimeStart = trainStart;
            m_trainTimeEnd = trainEnd;
        }
        public static void SetTestTime(DateTime testStart, DateTime testEnd)
        {
            m_testTimeStart = testStart;
            m_testTimeEnd = testEnd;
            m_currentTestHour = m_testTimeStart.Hour;
        }

        static WekaData()
        {
        }
        public WekaData(CandidateParameter cp)
        {
            m_cp = cp;
        }
        public WekaData(char dealType, int tp, int sl, CandidateParameter cp)
        {
            m_currentDealType = dealType;
            m_currentTp = tp;
            m_currentSl = sl;
            m_cp = cp;
        }
        private CandidateParameter m_cp;

        private string GetHpColumn(string append = null)
        {
            return WekaUtils.GetHpColumn(m_currentDealType, m_currentTp, m_currentTp, append);
        }
        
        public void SaveInstances()
        {
            string arffFileName = GetArffFileName(true, m_currentDealType.ToString());
            using (StreamWriter sw = new StreamWriter(string.Format("{0}\\{1}.arff", TestParameters.BaseDir, arffFileName)))
            {
                sw.WriteLine(m_trainInstances);
            }
            arffFileName = GetArffFileName(true, m_currentDealType.ToString(), Parameters.NewFileAppend);
            using (StreamWriter sw = new StreamWriter(string.Format("{0}\\{1}.arff", TestParameters.BaseDir, arffFileName)))
            {
                sw.WriteLine(m_trainInstancesNew);
            }

            arffFileName = GetArffFileName(false, m_currentDealType.ToString());
            using (StreamWriter sw = new StreamWriter(string.Format("{0}\\{1}.arff", TestParameters.BaseDir, arffFileName)))
            {
                sw.WriteLine(m_testInstances);
            }
            arffFileName = GetArffFileName(false, m_currentDealType.ToString(), Parameters.NewFileAppend);
            using (StreamWriter sw = new StreamWriter(string.Format("{0}\\{1}.arff", TestParameters.BaseDir, arffFileName)))
            {
                sw.WriteLine(m_testInstancesNew);
            }

            //string modelFileName = string.Format("{0}_{1}_{2}_{3}.model",
            //    m_symbol, m_trainTimeStart.ToString(Parameters.DateTimeFormat), m_trainTimeEnd.ToString(Parameters.DateTimeFormat), m_bestClassifierInfo.DealType);
            //ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(modelFileName));
            //oos.writeObject(m_bestClassifierInfo.Classifier);
            //oos.flush();
            //oos.close();
        }

        private static bool m_useClassAsAttribute = false;  // Check Classifier
        private static int? m_generateOneClassHp = null;
        public static string GetArffHeader(DateTime dt1, DateTime dt2, CandidateParameter cp)
        {
            //string header;
            //using (StreamReader sr = new StreamReader(string.Format("{0}\\{1}_header_{2}.arff", m_arffHeaderDir, m_symbol, m_symbolPeriod2_cnt)))
            //{
            //    header = sr.ReadToEnd();
            //}
            // header = header.Replace("@relation eurusd_m1", string.Format("@relation '{0}_{1}_{2}'", m_symbolPeriod2, dt1, dt2));
            StringBuilder header = new StringBuilder();
            header.AppendLine(string.Format("@relation '{0}_{1}'", dt1.ToString(Parameters.DateTimeFormat), dt2.ToString(Parameters.DateTimeFormat)));
            header.AppendLine("@attribute timestamp date \"yyyy-MM-dd'T'HH:mm:ss\"");
            header.AppendLine("@attribute hpdate date \"yyyy-MM-dd'T'HH:mm:ss\"");
            //header.AppendLine("@attribute hour {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23}");
            //header.AppendLine("@attribute day_of_week {1, 2, 3, 4, 5}");
            header.AppendLine("@attribute spread numeric");
            header.AppendLine("@attribute mainClose numeric");
            header.AppendLine("@attribute hour numeric");
            header.AppendLine("@attribute day_of_week numeric");
            header.AppendLine("@attribute vol numeric");
            
            for (int s = 0; s < cp.SymbolCount; ++s)
            {
                for (int i = 0; i < cp.PeriodCount; ++i) 
                {
                    for (int p = 0; p < cp.PrevTimeCount; ++p)
                    {
                        string postFix1 = cp.AllPeriods[i + cp.PeriodStart] + (p == 0 ? string.Empty : "_P" + p.ToString());
                        foreach (string name in cp.AllIndNames2.Keys)
                        {
                            header.AppendLine(string.Format("@attribute {0}_{1} {2}",
                                cp.AllSymbols[s + cp.SymbolStart], name + "_" + postFix1, TestParameters.IndicatorUseNumeric ? "numeric" : "{0,1,2,3}"));
                        }

                        for (int j = -1; j < Math.Max(0, Math.Min(cp.PeriodTimeCount - i, Parameters.PeriodTimeNames[i + cp.PeriodStart].Length)); ++j)
                        {
                            string postFix2;
                            if (j >= 0)
                                postFix2 = cp.AllPeriods[i + cp.PeriodStart] + "_" + Parameters.PeriodTimeNames[i + cp.PeriodStart][j] + (p == 0 ? string.Empty : "_P" + p.ToString());
                            else
                                postFix2 = postFix1;

                            foreach (string name in cp.AllIndNames.Keys)
                            {
                                header.AppendLine(string.Format("@attribute {0}_{1} {2}",
                                    cp.AllSymbols[s + cp.SymbolStart], name + "_" + postFix2, TestParameters.IndicatorUseNumeric ? "numeric" : "{0,1,2,3}"));
                            }
                        }
                    }
                }
            }

            if (m_useClassAsAttribute)
            {
                header.AppendLine("@attribute propAttr {0,1,2,3}");
            }
            if (!m_generateOneClassHp.HasValue)
            {
                // 0: Fail; 1: Unknown 2: Success
                header.AppendLine("@attribute prop {0,1,2,3}");
            }
            else
            {
                header.AppendLine("@attribute prop {0}");
            }
            header.AppendLine();
            header.AppendLine("@data");

            return header.ToString();
        }

        public static Instances GetTrainInstancesTemplate(string name)
        {
            if (m_trainInstancesTemplates.ContainsKey(name))
                return m_trainInstancesTemplates[name];
            else
                return null;
        }
        public static Instances GetTestInstancesTemplate(string name)
        {
            if (m_testInstancesTemplates.ContainsKey(name))
                return m_testInstancesTemplates[name];
            else
                return null;
        }
        private static Dictionary<string, Instances> m_trainInstancesTemplates = new Dictionary<string,Instances>();
        private static Dictionary<string, Instances> m_testInstancesTemplates = new Dictionary<string,Instances>();
        public static void ClearTemplates()
        {
            m_trainInstancesTemplates.Clear();
            m_testInstancesTemplates.Clear();
        }

        private Instances m_trainInstances, m_testInstances, m_trainInstancesNew, m_testInstancesNew;
        //private Dictionary<string, System.Collections.Generic.Queue<ClassifierInfo>> m_classifierQueue;
        //private TpslClassifierInfo m_bestClassifierInfo;
        public void Clear()
        {
            m_trainInstances = null;
            m_testInstances = null;
            m_trainInstancesNew = null;
            m_testInstancesNew = null;
        }
        public Instances CurrentTrainInstances
        {
            get { return m_trainInstances; }
        }
        public Instances CurrentTrainInstancesNew
        {
            get { return m_trainInstancesNew; }
        }
        public Instances CurrentTestInstances
        {
            get { return m_testInstances; }
        }
        public Instances CurrentTestInstancesNew
        {
            get { return m_testInstancesNew; }
        }

        //public void SetCurrentFromClassifierInfo(TpslClassifierInfo clsInfo)
        //{
        //    m_currentDealTypeIdx = clsInfo.DealType == Parameters.AllDealTypes[0] ? 0 : 1;
        //    m_currentTp = clsInfo.Tp;
        //    m_currentSl = clsInfo.Sl;
        //    TestParameters.SetCost(m_currentTp, m_currentSl);
        //}

        public void GenerateData(bool generateTrainData = true, bool generateTestData = true)
        {
            GenerateArff(generateTrainData, generateTestData);

            if (TestParameters.EnableDetailLog)
            {
                WekaUtils.Instance.WriteLog("Arff is generated.");
            }

            //ScaleArff();
            //WriteLog("Data is scaled.");

            //NormailizeArff();
            //WriteLog("Data is normalized.");

            if (m_filter == null)
            {
                m_filter = WekaUtils.CreateNormalFilter();
            }
            FilterArff(m_filter);

            if (TestParameters.EnableDetailLog)
            {
                WekaUtils.Instance.WriteLog("Data is filtered.");
            }

            if (m_convertToLibsvm)
            {
                ConvertToLibSVM(Parameters.NewFileAppend);
                if (TestParameters.EnableDetailLog)
                {
                    WekaUtils.Instance.WriteLog("Data is converted to libsvm format.");
                }
            }

            //using (StreamWriter sw = new StreamWriter(string.Format("{0}\\doeasy.bat", m_baseDir), true))
            //{
            //    SetTraining(true);
            //    string trainFileName = GetArffFileName(m_newFileAppend).Replace(".arff", ".libsvm");
            //    SetTraining(false);
            //    string testFileName = GetArffFileName(m_newFileAppend).Replace(".arff", ".libsvm");
            //    sw.WriteLine(string.Format("easy.py {0} {1}", trainFileName, testFileName));
            //}
        }

        private void TrainandTest()
        {
            var c = new CandidateClassifier("Test", m_currentTp, m_currentSl, Parameters.AllDealTypes[0], 0, null);
            TrainandTest(c, null);

            //var ev = (new MyEvaluation(TestParameters.CostMatrix));
            //ev.evaluateModel(c.Classifier, c.CurrentTrainInstancesNew1);
            //ev.evaluateModel(c.Classifier, c.CurrentTestInstancesNew1);
        }

        public void TrainandTest(CandidateClassifier classifierInfo, CandidateParameter cp)
        {
            //string dealType = classifierInfo.DealType;
            Classifier cls = null;

            if (TestParameters.UseTrain)
            {
                string modelFileName = GetModelFileName(classifierInfo.Name);

                if (TestParameters.SaveModel)
                {
                    cls = WekaUtils.TryLoadClassifier(modelFileName);
                }

                Instances trainInstancesNew, trainInstances;
                trainInstances = m_trainInstances;
                trainInstancesNew = m_trainInstancesNew;

                if (cls == null)
                {
                    if (classifierInfo.Classifier == null)
                    {
                        classifierInfo.Classifier = WekaUtils.CreateClassifier(cp.ClassifierType, m_currentTp, m_currentSl);
                    }
                    cls = classifierInfo.Classifier;
                }
                else
                {
                    if (TestParameters.EnableDetailLog)
                    {
                        System.Console.WriteLine("Model is loaded.");
                    }
                }

                if (m_enableTrainSplitTest)
                {
                    Instances trainTrainInst, trainTestInst;
                    DateTime splitTrainTimeEnd;
                    if (m_trainSplitTestNums != -1)
                    {
                        int trainTrainSize = trainInstancesNew.numInstances() - m_trainSplitTestNums;
                        int trainTestSize = m_trainSplitTestNums;
                        trainTrainInst = new Instances(trainInstancesNew, 0, trainTrainSize);
                        trainTestInst = new Instances(trainInstancesNew, trainTrainSize, trainTestSize);
                        splitTrainTimeEnd = WekaUtils.GetDateValueFromInstances(trainInstances, 0, trainTrainSize);
                    }
                    else if (m_trainSplitPercent != -1)
                    {
                        if (m_trainSplitPercent == 100.0)
                        {
                            int trainTrainSize = trainInstancesNew.numInstances();
                            trainTrainInst = new Instances(trainInstancesNew, 0, trainTrainSize);
                            trainTestInst = new Instances(trainInstancesNew, 0, trainTrainSize);
                            splitTrainTimeEnd = WekaUtils.GetDateValueFromInstances(trainInstances, 0, trainTrainSize);
                        }
                        else
                        {
                            int trainTrainSize = (int)Math.Round(trainInstancesNew.numInstances() * m_trainSplitPercent / 100);
                            int trainTestSize = trainInstancesNew.numInstances() - trainTrainSize;

                            trainTrainInst = new Instances(trainInstancesNew, 0, trainTrainSize);
                            trainTestInst = new Instances(trainInstancesNew, trainTrainSize, trainTestSize);
                            splitTrainTimeEnd = WekaUtils.GetDateValueFromInstances(trainInstances, 0, trainTrainSize);
                        }
                    }
                    else
                    {
                        trainTrainInst = new Instances(trainInstancesNew, 0);
                        trainTestInst = new Instances(trainInstancesNew, 0);
                        DateTime dt = WekaUtils.GetDateValueFromInstances(trainInstances, 0, trainInstances.numInstances() - 1);
                        splitTrainTimeEnd = m_trainTimeEnd.AddMinutes(-TestParameters.BatchTestMinutes);
                        while (splitTrainTimeEnd > dt)
                        {
                            splitTrainTimeEnd = splitTrainTimeEnd.AddMinutes(-TestParameters.BatchTestMinutes);
                        }
                        for (int i = 0; i < trainInstances.numInstances(); ++i)
                        {
                            dt = WekaUtils.GetDateValueFromInstances(trainInstances, 0, i);
                            if (dt <= splitTrainTimeEnd)
                            {
                                var ins = new DenseInstance(trainInstancesNew.instance(i));
                                trainTrainInst.add(ins);
                            }
                            else
                            {
                                var ins = new DenseInstance(trainInstancesNew.instance(i));
                                trainTestInst.add(ins);
                            }
                        }
                    }
                    cls = WekaUtils.TrainInstances(trainTrainInst, TestParameters.SaveModel ? modelFileName : null, cls);

                    //m_classifierQueue[dealType].Enqueue(new ClassifierInfo(cls, splitTrainTimeEnd));
                    //foreach (var i in m_classifierQueue[dealType])
                    //{
                    //    var e = WekaUtils.TestInstances(trainTestInst, i.Cls);
                    //    i.TotalCost = i.TotalCost * m_classifierQueueFactor + e.totalCost();
                    //    i.TotalNum = (int)(i.TotalNum * m_classifierQueueFactor) + (int)e.numInstances();
                    //}


                    //WriteEvalSummary(eval1, string.Format("Test Data from {0} to {1}", m_testTimeStart.ToString(Parameters.DateTimeFormat), m_testTimeEnd.ToString(Parameters.DateTimeFormat)));
                }
                else
                {
                    cls = WekaUtils.TrainInstances(trainInstancesNew, TestParameters.SaveModel ? modelFileName : null, cls);

                    //m_classifierQueue[dealType].Enqueue(new ClassifierInfo(cls, m_trainTimeEnd));
                    //foreach (var i in m_classifierQueue[dealType])
                    //{
                    //    var e = WekaUtils.TestInstances(trainInstancesNew, i.Cls);
                    //    i.TotalCost = i.TotalCost * m_classifierQueueFactor + e.totalCost();
                    //    i.TotalNum = (int)(i.TotalNum * m_classifierQueueFactor) + (int)e.numInstances();
                    //}
                }

                if (TestParameters.EnableDetailLog)
                {
                    System.Console.WriteLine("Model is trained.");
                }


                classifierInfo.Classifier = cls;
                //if (classifierInfo.CurrentTrainInstances1 != null)
                //{
                //    classifierInfo.CurrentTrainInstances1.clear();
                //}
                //if (classifierInfo.CurrentTrainInstancesNew1 != null)
                //{
                //    classifierInfo.CurrentTrainInstancesNew1.clear();
                //}
                //classifierInfo.CurrentTrainInstances = new Instances(trainInstances, 0, trainInstances.numInstances());
                //classifierInfo.CurrentTrainInstancesNew = new Instances(trainInstancesNew, 0, trainInstancesNew.numInstances());

                if (classifierInfo.MoneyManagement == null)
                {
                    classifierInfo.MoneyManagement = WekaUtils.CreateMoneyManagement(cp.MoneyManagementType, m_currentTp, m_currentSl);
                }
                IMoneyManagement mm = WekaUtils.TrainInstances4MM(trainInstancesNew, TestParameters.SaveModel ? modelFileName : null, classifierInfo.MoneyManagement);
                classifierInfo.MoneyManagement = mm;
            }
            else
            {
                if (classifierInfo.Classifier == null)
                {
                    classifierInfo.Classifier = WekaUtils.CreateClassifier(cp.ClassifierType, m_currentTp, m_currentSl);
                }
                cls = classifierInfo.Classifier;

                if (classifierInfo.MoneyManagement == null)
                {
                    classifierInfo.MoneyManagement = WekaUtils.CreateMoneyManagement(cp.MoneyManagementType, m_currentTp, m_currentSl);
                }
            }

            if (m_enableTest)
            {
                Instances testInstancesNew, testInstances;
                testInstances = m_testInstances;
                testInstancesNew = m_testInstancesNew;

                double[] cv = WekaUtils.ClassifyInstances(testInstancesNew, cls);

                if (TestParameters.EnableExcludeClassifier)
                {
                    bool hasPositive = false;
                    for (int i = 0; i < cv.Length; ++i)
                    {
                        if (cv[i] == 2)
                        {
                            hasPositive = true;
                            break;
                        }
                    }
                    if (hasPositive)
                    {
                        // Exclude
                        if (classifierInfo.ExcludeClassifier == null)
                        {
                            string modelFileName4Exclude = GetExcludeModelFileName(classifierInfo.Name);
                            classifierInfo.ExcludeClassifier = WekaUtils.TryLoadClassifier(modelFileName4Exclude);
                        }
                        if (classifierInfo.ExcludeClassifier != null)
                        {
                            double[] cv2 = WekaUtils.ClassifyInstances(testInstancesNew, classifierInfo.ExcludeClassifier);
                            // cv2 == 0 -> is class, otherwise = double.NaN;
                            for (int i = 0; i < cv.Length; ++i)
                            {
                                cv[i] = cv[i] == 2 && cv2[i] == 2 ? 2 : 0;
                            }
                        }
                    }
                }

                classifierInfo.CurrentTestRet = cv;

                classifierInfo.CurrentClassValue = new double[testInstances.numInstances()];
                for (int i = 0; i < testInstances.numInstances(); ++i)
                {
                    classifierInfo.CurrentClassValue[i] = testInstances.instance(i).classValue();
                }

                for (int i = 0; i < testInstances.numInstances(); i++)
                {
                    if (cv[i] == 2)
                    {
                        double openPrice = testInstances.instance(i).value(testInstances.attribute("mainClose"));
                        DateTime openTime = WekaUtils.GetDateValueFromInstances(testInstances, 0, i);
                        if (testInstances.instance(i).classValue() == 2 || testInstances.instance(i).classValue() == 0)
                        {
                            classifierInfo.Deals.AddDeal(openTime,
                                openPrice,
                                classifierInfo.DealType,
                                classifierInfo.MoneyManagement.GetVolume(testInstances.instance(i)),
                                testInstances.instance(i).classValue() == 2 ? -classifierInfo.Tp : classifierInfo.Sl,
                                WekaUtils.GetDateValueFromInstances(testInstances, 1, i));
                        }
                        else if (testInstances.instance(i).classValue() == 1)
                        {
                            double closePriceTp, closePriceSl;
                            if (classifierInfo.DealType == 'B')
                            {
                                closePriceTp = openPrice + classifierInfo.Tp * DealsInfo.GetPoint(0);
                                closePriceSl = openPrice - classifierInfo.Sl * DealsInfo.GetPoint(0);
                            }
                            else
                            {
                                closePriceTp = openPrice - classifierInfo.Tp * DealsInfo.GetPoint(0);
                                closePriceSl = openPrice + classifierInfo.Sl * DealsInfo.GetPoint(0);
                            }

                            classifierInfo.Deals.AddDeal(openTime,
                                openPrice,
                                classifierInfo.DealType,
                                classifierInfo.MoneyManagement.GetVolume(testInstances.instance(i)),
                                closePriceTp, closePriceSl);
                        }
                        else
                        {
                            throw new AssertException("classValue should be 0,1,2.");
                        }
                    }
                }
            }
        }

        private string NormalizeFileName(string s)
        {
            return s.Replace("T00:00:00", "").Replace(":00:00", "").Replace(":00", "").Replace(':', 'p');
        }

        public string GetArffFileName(bool isTrain, string append1, string append2)
        {
            if (append1 == null)
                return GetArffFileName(isTrain, append2);
            else if (append2 == null)
                return GetArffFileName(isTrain, append1);
            else
                return GetArffFileName(isTrain, append2 + "." + append1);
        }

        public string GetArffFileName(bool isTrain, string append = null)
        {
            string arffFileName = null;
            if (isTrain)
            {
                arffFileName = string.Format("{0}_{1}_{2}{3}{4}.arff",
                    m_cp.MainSymbol, 
                    m_trainTimeStart.ToString(Parameters.DateTimeFormat), m_trainTimeEnd.ToString(Parameters.DateTimeFormat),
                    string.IsNullOrEmpty(append) ? string.Empty : "." + append,
                    !TestParameters.EnablePerhourTrain ? string.Empty : "." + "H" + m_currentTestHour);
            }
            else
            {
                arffFileName = string.Format("{0}_{1}_{2}_{3}_{4}{5}{6}.arff",
                    m_cp.MainSymbol, 
                    m_trainTimeStart.ToString(Parameters.DateTimeFormat), m_trainTimeEnd.ToString(Parameters.DateTimeFormat),
                    m_testTimeStart.ToString(Parameters.DateTimeFormat), m_testTimeEnd.ToString(Parameters.DateTimeFormat),
                    string.IsNullOrEmpty(append) ? string.Empty : "." + append,
                    !TestParameters.EnablePerhourTrain ? string.Empty : "." + "H" + m_currentTestHour);
            }

            return string.Format("{0}\\{1}", TestParameters.BaseDir, NormalizeFileName(arffFileName));
        }

        //public void ChangeModelName()
        //{
        //    var dt = DbHelper.Instance.ExecuteDataTable("SELECT FileName FROM MODELDATA WHERE TYPE = -40");
        //    foreach (System.Data.DataRow row in dt.Rows)
        //    {
        //        string s = row[0].ToString();
        //        int idx = s.IndexOf('.');
        //        string s2 = s.Substring(0, idx) + "_-40" + s.Substring(idx);

        //        string sql = string.Format("UPDATE MODELDATA SET FileName = '{0}' WHERE FileName = '{1}'", s2, s);
        //        DbHelper.Instance.ExecuteNonQuery(sql);
        //    }
        //}
        public string GetModelFileName(string clsName)
        {
            string modelFileName = string.Format("{0}_{1}_C{2}_{3}_{4}.model",
                m_cp.MainSymbol,
                clsName,
                m_cp.ClassifierType,
                m_trainTimeStart.ToString(Parameters.DateTimeFormat), m_trainTimeEnd.ToString(Parameters.DateTimeFormat));

            return string.Format("{0}\\{1}", TestParameters.TmpDir, NormalizeFileName(modelFileName));
        }

        public string GetExcludeModelFileName(string clsName = null)
        {
            //if (clsName.Contains("_H"))
            //{
            //    int idx = clsName.LastIndexOf('_');
            //    clsName = clsName.Substring(0, idx);
            //}
            string modelFileName = string.Format("{0}_{1}.exclude.model",
                m_cp.MainSymbol,
                clsName,
                m_cp.ClassifierType,
                m_trainTimeStart.ToString(Parameters.DateTimeFormat), m_trainTimeEnd.ToString(Parameters.DateTimeFormat));

            return string.Format("{0}\\{1}", TestParameters.BaseDir + "\\ExcludeModel", NormalizeFileName(modelFileName));
        }

        private const string m_pricePrecision = "0.#####";
        public static void GenerateArffTemplate(bool generateTrainData, bool generateTestData,  CandidateParameter cp)
        {
            if (!m_trainInstancesTemplates.ContainsKey(cp.Name))
            {
                string arffFileName = string.Format("{0}\\mlea_header_{1}.arff", TestParameters.CommonDir, cp.Name);
                if (System.IO.File.Exists(arffFileName))
                {
                    System.IO.File.Delete(arffFileName);
                }
                using (StreamWriter sw = new StreamWriter(arffFileName))
                {
                    sw.WriteLine(GetArffHeader(System.DateTime.Today, System.DateTime.Today, cp));
                }

                m_trainInstancesTemplates[cp.Name] = WekaUtils.LoadInstances(arffFileName);
                m_testInstancesTemplates[cp.Name] = WekaUtils.LoadInstances(arffFileName);
            }
            Instances trainInstancesTemplate = m_trainInstancesTemplates[cp.Name];
            Instances testInstancesTemplate = m_testInstancesTemplates[cp.Name];

            for (int k = 0; k < 2; ++k)
            {
                if (k == 0 && !generateTrainData)
                    continue;
                if (k == 1 && !generateTestData)
                    continue;

                bool isTrain = (k == 0);

                DateTime dt1 = isTrain ? m_trainTimeStart : m_testTimeStart;
                DateTime dt2 = isTrain ? m_trainTimeEnd : m_testTimeEnd;

                Instances hereInstances;
                if (isTrain)
                {
                    hereInstances = trainInstancesTemplate;
                }
                else
                {
                    hereInstances = testInstancesTemplate;
                }

                if (!TestParameters.EnablePerhourTrain)
                {
                    while (hereInstances.numInstances() > 0)
                    {
                        if (WekaUtils.GetDateValueFromInstances(hereInstances, 0, 0) < dt1)
                        {
                            hereInstances.delete(0);
                        }
                        else
                        {
                            break;
                        }
                    }
                }
                else
                {
                    hereInstances.delete();
                }

                hereInstances.setRelationName(string.Format("{0}_{1}", dt1.ToString(Parameters.DateTimeFormat), dt2.ToString(Parameters.DateTimeFormat)));

                ForexDataRows[, ,] dvs = new ForexDataRows[cp.SymbolCount, cp.PeriodCount, cp.PeriodTimeCount + 1];
                int[, ,] dvsIdx = new int[cp.SymbolCount, cp.PeriodCount, cp.PeriodTimeCount + 1];
                for (int s = 0; s < cp.SymbolCount; ++s)
                {
                    for (int i = 0; i < cp.PeriodCount; ++i)
                    {
                        for (int j = -1; j < Math.Max(0, Math.Min(cp.PeriodTimeCount - i, Parameters.PeriodTimeNames[i].Length)); ++j)
                        {
                            string tableName = cp.AllSymbols[s + cp.SymbolStart] + "_" +
                                cp.AllPeriods[i + cp.PeriodStart] +
                                (j < 0 ? string.Empty : "_" + Parameters.PeriodTimeNames[i + cp.PeriodStart][j]);
                            dvs[s, i, j + 1] = DbData.Instance.GetDbData(dt1, dt2, tableName, s == 0 && i == 0 && j == -1 ? 0 : 1, isTrain, cp);

                            dvsIdx[s, i, j + 1] = 0;
                        }
                    }
                }

                ForexDataRows mainDv = dvs[0, 0, 0];
                if (mainDv.Length == 0)
                    continue;
                if (dvs[0, cp.PeriodCount - 1, 0].Length <= cp.PrevTimeCount - 1)
                    continue;

                int startRowIdx = 0;
                startRowIdx = 0;// FindRowByTime(mainDv, (long)dvs[0, PeriodCount - 1, 0][PrevTimeCount - 1]["Time"], ref startRowIdx);

                DateTime nowInstanceMaxDate = DateTime.MinValue;
                if (!TestParameters.EnablePerhourTrain && hereInstances.numInstances() > 0)
                {
                    nowInstanceMaxDate = WekaUtils.GetDateValueFromInstances(hereInstances, 0, hereInstances.numInstances() - 1);
                }

                for (int rowIdx = startRowIdx; rowIdx < mainDv.Length; ++rowIdx)
                {
                    ForexData mainDrv = mainDv[rowIdx];
                    //DateTime row_date = (DateTime)mainDrv[1];   // "Date"
                    //long mainTime = (long)mainDrv[0];    // "Time"
                    long mainTime = mainDrv.Time;
                    DateTime row_date = WekaUtils.GetDateFromTime(mainTime);

                    if (row_date <= nowInstanceMaxDate)
                        continue;

                    if (row_date < dt1)
                        continue;
                    if (row_date >= dt2)
                        break;
                    if (TestParameters.EnablePerhourTrain)
                    {
                        if (m_currentTestHour != row_date.Hour)
                            continue;
                    }

                    int hp = 1;

                    double[] instanceValue = new double[hereInstances.numAttributes()];

                    //instanceValue[0] = hereInstances.attribute(0).parseDate(row_date.ToString(Parameters.DateTimeFormat));
                    //instanceValue[1] = hereInstances.attribute(1).parseDate(hp_date.ToString(Parameters.DateTimeFormat));
                    //instance.setValue(1, hereInstances.attribute(1).indexOfValue(mainDrv["hour"].ToString()));
                    //instance.setValue(2, hereInstances.attribute(2).indexOfValue(mainDrv["dayofweek"].ToString()));
                    instanceValue[0] = (row_date - Parameters.MtStartTime).TotalMilliseconds; // if not set to gmt, should -8 * 60 * 60 * 1000;  // utc8
                    instanceValue[1] = (Parameters.MaxDate - Parameters.MtStartTime).TotalMilliseconds;
                    instanceValue[2] = Convert.ToDouble(mainDrv["spread"]);
                    instanceValue[3] = (double)mainDrv["mainClose"];

                    instanceValue[4] = (int)mainDrv["hour"] / 24.0;
                    instanceValue[5] = (int)mainDrv["dayofweek"] / 5.0;

                    //if (mainDrv["AskVolume"] != System.DBNull.Value && mainDrv["BidVolume"] != System.DBNull.Value)
                    //{
                    //    instanceValue[4] = ((((double)mainDrv["AskVolume"]) - (double)mainDrv["BidVolume"]) / 100000);
                    //}
                    //else
                    {
                        instanceValue[6] = 0;
                    }

                    int start = 7;
                    try
                    {
                        for (int s = 0; s < cp.SymbolCount; ++s)
                        {
                            //double mainClose = (double)mainDrv["close"];
                            int nowRowIdx_s = FindRowByTime(dvs[s, 0, 0], mainTime, ref dvsIdx[s, 0, 0]);
                            WekaUtils.DebugAssert((long)dvs[s, 0, 0][nowRowIdx_s].Time == mainTime, "(long)dvs[s, 0, 0][nowRowIdx_s].Time == mainTime");
                            double mainClose = 0;
                            if (cp.AllIndNames2.ContainsKey("close"))
                            {
                                mainClose = (double)dvs[s, 0, 0][nowRowIdx_s]["close"];
                            }

                            for (int i = 0; i < cp.PeriodCount; ++i)
                            {
                                int periodSeconds = 60 * WekaUtils.GetMinuteofPeriod(cp.AllPeriods[i + cp.PeriodStart]);
                                int nowRowIdx = FindRowByTime(dvs[s, i, 0], mainTime / periodSeconds * periodSeconds, ref dvsIdx[s, i, 0]);

                                for (int p = 0; p < cp.PrevTimeCount; ++p)
                                {
                                    if (nowRowIdx - p < 0)
                                    {
                                        throw new ArgumentException("No prev data!");
                                    }
                                    ForexData nowDrv = dvs[s, i, 0][nowRowIdx - p];

                                    foreach (var kvp in cp.AllIndNames2)
                                    {
                                        double v = Convert.ToDouble(nowDrv[kvp.Key]);
                                        double ind = WekaUtils.NormalizeValue(kvp.Key, kvp.Value, v, mainClose, WekaUtils.GetSymbolPoint(cp.AllSymbols[s]));

                                        instanceValue[start] = ind;
                                        start++;
                                    }

                                    for (int j = -1; j < Math.Max(0, Math.Min(cp.PeriodTimeCount - i, Parameters.PeriodTimeNames[i].Length)); ++j)
                                    {
                                        int nowRowIdx2;
                                        if (j == -1)
                                            nowRowIdx2 = nowRowIdx;
                                        else
                                            nowRowIdx2 = FindRowByTime(dvs[s, i, j + 1], mainTime / periodSeconds * periodSeconds, ref dvsIdx[s, i, j + 1]);
                                        if (nowRowIdx2 - p < 0)
                                        {
                                            throw new ArgumentException("No prev data!");
                                        }
                                        ForexData nowDrv2 = dvs[s, i, j + 1][nowRowIdx2 - p];

                                        foreach (var kvp in cp.AllIndNames)
                                        {
                                            double v = (double)nowDrv2[kvp.Key];
                                            double ind = WekaUtils.NormalizeValue(kvp.Key, kvp.Value, v, mainClose, WekaUtils.GetSymbolPoint(cp.AllSymbols[s]));

                                            instanceValue[start] = ind;
                                            start++;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    catch (ArgumentException)
                    {
                        continue;
                    }

                    if (m_useClassAsAttribute)
                    {
                        instanceValue[hereInstances.numAttributes() - 2] = hp;
                    }
                    instanceValue[hereInstances.numAttributes() - 1] = hp;

                    Instance instance = new weka.core.DenseInstance(1, instanceValue);
                    //if (!hereInstances.checkInstance(instance))
                    //{
                    //    throw new ArgumentException("Imcompatible instance!");
                    //}
                    hereInstances.add(instance);
                }
            }
        }

        private void GetHpData(ForexData forexData, char dealType, int tp, int sl, out int? hp, out long? hp_date)
        {
            int tpMinDelta = TestParameters.GetTpSlMinDelta(m_cp.MainSymbol);
            int slMinDelta = TestParameters.GetTpSlMinDelta(m_cp.MainSymbol);

            int d = dealType == 'B' ? 0 : 1;
            var hps = (sbyte?[, ,])forexData[0];
            var hp_dates = (long?[, ,])forexData[1];

            //WekaUtils.Instance.WriteLog(string.Format("{0}, {1}, {2}, {3}", tp, sl, hps.GetLength(1), hps.GetLength(2)));

            int tpIdx = tp / tpMinDelta - 1;
            int slIdx = sl / slMinDelta - 1;
            if (tpIdx < 0 || tpIdx > hps.GetLength(1)
                || slIdx < 0 || slIdx > hps.GetLength(2))
            {
                throw new AssertException(string.Format("hps length is {0}*{1}, get tp={2}, sl={3}", hps.GetLength(1), hps.GetLength(2), tp, sl));
            }
            hp = hps[d, tpIdx, slIdx];
            hp_date = hp_dates[d, tp / tpMinDelta - 1, sl / slMinDelta - 1];
        }

        public bool UseNullHp = false;

        public void GenerateArff(bool generateTrainData, bool generateTestData)
        {
            Instances trainInstancesTemplate = m_trainInstancesTemplates[this.m_cp.Name];
            Instances testInstancesTemplate = m_testInstancesTemplates[this.m_cp.Name];

            for (int k = 0; k < 2; ++k)
            {
                if (k == 0 && !generateTrainData)
                    continue;
                if (k == 1 && !generateTestData)
                    continue;

                bool isTrain = (k == 0);

                string arffFileName = null;
                if (TestParameters.SaveDataFile)
                {
                    arffFileName = GetArffFileName(isTrain, m_currentDealType.ToString());
                    if (System.IO.File.Exists(arffFileName))
                    {
                        if (isTrain)
                        {
                            m_trainInstances = WekaUtils.LoadInstances(arffFileName);
                        }
                        else
                        {
                            m_testInstances = WekaUtils.LoadInstances(arffFileName);
                        }
                        continue;
                    }
                }

                DateTime dt1 = isTrain ? m_trainTimeStart : m_testTimeStart;
                DateTime dt2 = isTrain ? m_trainTimeEnd : m_testTimeEnd;

                Instances hereInstances;
                if (isTrain)
                {
                    m_trainInstances = new Instances(trainInstancesTemplate, 0, trainInstancesTemplate.numInstances());
                    hereInstances = m_trainInstances;
                }
                else
                {
                    m_testInstances = new Instances(testInstancesTemplate, 0, testInstancesTemplate.numInstances());
                    hereInstances = m_testInstances;
                }

                hereInstances.setRelationName(string.Format("{0}_{1}", dt1.ToString(Parameters.DateTimeFormat), dt2.ToString(Parameters.DateTimeFormat)));

                ForexDataRows hpdv = null;
                if (!UseNullHp)
                {
                    hpdv = DbData.Instance.GetDbData(dt1, dt2, m_cp.MainSymbol + "_HP", 2, isTrain, m_cp);
                }

                for(int i=0; i<hereInstances.numInstances(); ++i)
                {
                    int hp = 1;
                    DateTime hp_date = Parameters.MaxDate;
                    hereInstances.instance(i).setValue(1, (hp_date - Parameters.MtStartTime).TotalMilliseconds);
                    hereInstances.instance(i).setClassValue(hp);

                    long mainTime = (long)hereInstances.instance(i).value(0) / 1000;

                    if (!UseNullHp)
                    {
                        int nowRowIdx_hp = 0;
                        try
                        {
                            nowRowIdx_hp = FindRowByTime(hpdv, mainTime, ref nowRowIdx_hp);
                        }
                        catch (ArgumentException)
                        {
                            continue;
                        }
                        if ((long)hpdv[nowRowIdx_hp].Time != mainTime)
                            continue;

                        int? nhp;
                        long? nhp_date;
                        GetHpData(hpdv[nowRowIdx_hp], m_currentDealType, m_currentTp, m_currentSl, out nhp, out nhp_date);
                        if (!nhp.HasValue)
                        {
                            //continue;
                            hp = 1;
                            hp_date = Parameters.MaxDate;
                        }
                        else
                        {
                            hp = nhp.Value;
                            hp_date = WekaUtils.GetDateFromTime(nhp_date.Value);

                            if (hp == 1)
                                hp = 2;
                            else if (hp == 0)
                                hp = 0;
                            else if (hp == -1)
                                hp = 1;

                            if (isTrain)
                            {
                                if (hp_date >= m_trainTimeEnd)
                                {
                                    hp = 1;
                                    //continue;
                                }
                            }
                        }

                        if (m_generateOneClassHp.HasValue)
                        {
                            if (hp == 1)
                                continue;
                            if (hp != m_generateOneClassHp.Value)
                                continue;

                            hp = 0;
                        }
                    }

                    hereInstances.instance(i).setValue(1, (hp_date - Parameters.MtStartTime).TotalMilliseconds);

                    if (m_useClassAsAttribute)
                    {
                        hereInstances.instance(i).setValue(hereInstances.numAttributes() - 2, hp);
                    }
                    hereInstances.instance(i).setClassValue(hp);
                }

                if (TestParameters.SaveDataFile && !System.IO.File.Exists(arffFileName))
                {
                    WekaUtils.SaveInstances(hereInstances, arffFileName);
                }
            }

            #region "GenerateArffFile"
            //else
            //{
            //    for (int k = 0; k < (m_enableTest ? 2 : 1); ++k)
            //    {
            //        SetTraining(k == 0);

            //        int jj = m_currentDealTypeIdx;
            //        {
            //            string arffFileName = GetArffFileName(m_dealType[jj]);
            //            if (System.IO.File.Exists(arffFileName))
            //                continue;

            //            DateTime dt1 = m_isTrain ? m_trainTimeStart : m_testTimeStart;
            //            DateTime dt2 = m_isTrain ? m_trainTimeEnd : m_testTimeEnd;

            //            string header = GetArffHeader(dt1, dt2);

            //            #region "NotRandom"
            //            if (!m_useRandomData)
            //            {
            //                System.Data.DataRow[, ,][] dvs = new System.Data.DataRow[SymbolCount, PeriodCount, PeriodTimeCount + 1][];
            //                int[, , ,] dvsIdx = new int[SymbolCount, PeriodCount, PeriodTimeCount + 1, PrevTimeCount];
            //                for (int s = 0; s < SymbolCount; ++s)
            //                {
            //                    for (int i = 0; i < PeriodCount; ++i)
            //                    {
            //                        for (int j = -1; j < Math.Max(0, Math.Min(PeriodTimeCount - i, m_periodTimeNames[i].Length)); ++j)
            //                        {
            //                            string tableName = Parameters.AllSymbols[s] + "_" + Parameters.AllPeriods[i] + (j < 0 ? string.Empty : "_" + m_periodTimeNames[i][j]);
            //                            dvs[s, i, j + 1] = GetDbData(dt1, dt2, jj, tableName, s == 0 && i == 0 && j == -1);

            //                            for (int p = 0; p < PrevTimeCount; ++p)
            //                            {
            //                                dvsIdx[s, i, j + 1, p] = 0;
            //                            }
            //                        }
            //                    }
            //                }

            //                System.Data.DataRow[] mainDv = dvs[0, 0, 0];
            //                if (mainDv.Length == 0)
            //                    continue;
            //                if (dvs[0, PeriodCount - 1, 0].Length <= PrevTimeCount - 1)
            //                    continue;

            //                using (StreamWriter sw = new StreamWriter(arffFileName, false))
            //                {
            //                    sw.WriteLine(header.ToString());

            //                    int startRowIdx = 0;
            //                    startRowIdx = FindRowByTime(mainDv, (long)dvs[0, PeriodCount - 1, 0][PrevTimeCount - 1]["Time"], ref startRowIdx);

            //                    for (int rowIdx = startRowIdx; rowIdx < mainDv.Length; ++rowIdx)
            //                    {
            //                        System.Data.DataRow mainDrv = mainDv[rowIdx];

            //                        double hp = (double)mainDrv[m_hpColumn];
            //                        if (hp == 1)
            //                            hp = 2;
            //                        else if (hp == 0)
            //                            hp = 0;

            //                        DateTime hp_date = (DateTime)mainDrv[m_hpColumn + "_date"];
            //                        DateTime row_date = (DateTime)mainDrv["Date"];
            //                        if (TestParameters.EnablePerhourTrain)
            //                        {
            //                            if (m_currentTestHour != row_date.Hour)
            //                                continue;
            //                        }

            //                        if (m_isTrain)
            //                        {
            //                            if (hp_date >= m_trainTimeEnd)
            //                            {
            //                                hp = 1;
            //                                //continue;
            //                            }
            //                        }

            //                        sw.Write("\"");
            //                        sw.Write(row_date.ToString(Parameters.DateTimeFormat));
            //                        sw.Write("\",");
            //                        sw.Write("\"");
            //                        sw.Write(hp_date.ToString(Parameters.DateTimeFormat));
            //                        sw.Write("\",");
            //                        sw.Write(((int)mainDrv["hour"] / 24.0).ToString(m_pricePrecision));
            //                        sw.Write(",");
            //                        sw.Write(((int)mainDrv["dayofweek"] / 5.0).ToString(m_pricePrecision));
            //                        sw.Write(",");
            //                        if (mainDrv["AskVolume"] != System.DBNull.Value && mainDrv["BidVolume"] != System.DBNull.Value)
            //                        {
            //                            sw.Write(((((double)mainDrv["AskVolume"]) - (double)mainDrv["BidVolume"]) / 100000).ToString(m_pricePrecision));
            //                        }
            //                        else
            //                        {
            //                            sw.Write("0.00");
            //                        }
            //                        sw.Write(",");

            //                        long mainTime = (long)mainDrv["time"];
            //                        int aa = 0;
            //                        for (int s = 0; s < SymbolCount; ++s)
            //                        {
            //                            //double mainClose = (double)mainDrv["close"];
            //                            int nowRowIdx_s = FindRowByTime(dvs[s, 0, 0], mainTime, ref dvsIdx[s, 0, 0, 0]);
            //                            WekaUtils.DebugAssert((long)dvs[s, 0, 0][nowRowIdx_s]["Time"] == mainTime);
            //                            double mainClose = (double)dvs[s, 0, 0][nowRowIdx_s]["close"];

            //                            for (int p = 0; p < PrevTimeCount; ++p)
            //                            {
            //                                for (int i = 0; i < PeriodCount; ++i)
            //                                {
            //                                    int periodSeconds = 60 * WekaUtils.GetMinuteofPeriod(Parameters.AllPeriods[i]);
            //                                    int nowRowIdx = FindRowByTime(dvs[s, i, 0], mainTime / periodSeconds * periodSeconds - p * periodSeconds, ref dvsIdx[s, i, 0, p]);
            //                                    System.Data.DataRow nowDrv = dvs[s, i, 0][nowRowIdx];

            //                                    foreach (var kvp in m_indNames2)
            //                                    {
            //                                        double v = (double)nowDrv[kvp.Key];
            //                                        double ind = NormalizeValue(kvp.Key, kvp.Value, v, mainClose, WekaUtils.GetSymbolPoint(cp.AllSymbols[s]));

            //                                        sw.Write(ind.ToString(m_pricePrecision));
            //                                        sw.Write(",");
            //                                    }

            //                                    for (int j = -1; j < Math.Max(0, Math.Min(PeriodTimeCount - i, m_periodTimeNames[i].Length)); ++j)
            //                                    {
            //                                        int nowRowIdx2 = FindRowByTime(dvs[s, i, j + 1], mainTime / periodSeconds * periodSeconds - p * periodSeconds, ref dvsIdx[s, i, j + 1, p]);
            //                                        System.Data.DataRow nowDrv2 = dvs[s, i, j + 1][nowRowIdx2];

            //                                        foreach (var kvp in m_indNames)
            //                                        {
            //                                            double v = (double)nowDrv2[kvp.Key];
            //                                            double ind = NormalizeValue(kvp.Key, kvp.Value, v, mainClose, WekaUtils.GetSymbolPoint(cp.AllSymbols[s]));

            //                                            sw.Write(ind.ToString(m_pricePrecision));
            //                                            sw.Write(",");
            //                                        }
            //                                    }
            //                                }
            //                            }
            //                        }

            //                        sw.Write(hp);
            //                        sw.WriteLine();
            //                    }
            //                }
            //            }
            //            #endregion
            //            #region "Random"
            //            else
            //            {
            //                string period = "M5";
            //                System.Random randomGenerator = new System.Random((int)System.DateTime.Now.Ticks);
            //                using (StreamWriter sw = new StreamWriter(arffFileName, false))
            //                {
            //                    sw.WriteLine(header.ToString());

            //                    int rowNumber = (int)(dt2 - dt1).TotalDays / 7 * 5 * 24 * 60 / WekaUtils.GetMinuteofPeriod(period);
            //                    for (int rowIdx = 0; rowIdx < rowNumber; ++rowIdx)
            //                    {
            //                        var rand = randomGenerator.NextDouble();
            //                        double hp = rand > 0.75 ? 1 : 0;

            //                        sw.Write("\"");
            //                        sw.Write(System.DateTime.Now.ToString(Parameters.DateTimeFormat));
            //                        sw.Write("\",");
            //                        sw.Write(1.ToString(m_pricePrecision));
            //                        sw.Write(",");
            //                        sw.Write(1.ToString(m_pricePrecision));
            //                        sw.Write(",");
            //                        sw.Write("0.00");
            //                        sw.Write(",");

            //                        for (int s = 0; s < SymbolCount; ++s)
            //                        {
            //                            for (int p = 0; p < PrevTimeCount; ++p)
            //                            {
            //                                for (int i = 0; i < PeriodCount; ++i)
            //                                {
            //                                    foreach (var kvp in m_indNames2)
            //                                    {
            //                                        double ind = randomGenerator.NextDouble() * 2 - 1;

            //                                        sw.Write(ind.ToString(m_pricePrecision));
            //                                        sw.Write(",");
            //                                    }

            //                                    for (int j = -1; j < Math.Max(0, Math.Min(PeriodTimeCount - i, m_periodTimeNames[i].Length)); ++j)
            //                                    {
            //                                        foreach (var kvp in m_indNames)
            //                                        {
            //                                            double ind = randomGenerator.NextDouble() * 2 - 1;

            //                                            sw.Write(ind.ToString(m_pricePrecision));
            //                                            sw.Write(",");
            //                                        }
            //                                    }
            //                                }
            //                            }
            //                        }

            //                        sw.Write(hp);
            //                        sw.WriteLine();
            //                    }
            //                }
            //            }
            //            #endregion
            //        }
            //    }
            //}
            #endregion
        }

        private static int FindRowByTime(ForexDataRows dv, long time, ref int prevIdx)
        {
            if ((long)dv[prevIdx].Time == time)
                return prevIdx;

            //ForexDataTimeComparer c = new ForexDataTimeComparer(time);
            int idx = dv.BinarySearch(prevIdx, dv.Length - prevIdx, time);
            if (idx < 0)
            {
                //prevIdx = ~prevIdx - 1;
            }

            //long t = (long)dv[prevIdx]["Time"];
            //while (t < time && prevIdx + 1 < dv.Length)
            //{
            //    prevIdx++;
            //    t = (long)dv[prevIdx]["Time"];
            //}
            if (idx >= 0 && idx < dv.Length)
            {
                WekaUtils.DebugAssert((long)dv[idx].Time <= time, "(long)dv[idx].Time <= time");
                prevIdx = idx;
            }
            else
            {
                idx = 0;
                prevIdx = idx;
                throw new ArgumentException("There is no data");
            }
            return prevIdx;
        }

        public void ScaleArff()
        {
            string arffFileName = GetArffFileName(true);
            Instances origInstances = WekaUtils.LoadInstances(arffFileName);
            origInstances.setClassIndex(origInstances.numAttributes() - 1);

            using (StreamWriter sw = new StreamWriter(arffFileName.Replace(".arff", ".range")))
            {
                for (int i = 0; i < origInstances.numAttributes(); ++i)
                {
                    double min = double.MaxValue;
                    double max = double.MinValue;
                    for (int j = 0; j < origInstances.numInstances(); ++j)
                    {
                        min = Math.Min(min, origInstances.instance(j).value(i));
                        max = Math.Max(max, origInstances.instance(j).value(i));
                    }
                    sw.WriteLine(string.Format("{0} {1} {2}", i, min.ToString(Parameters.DoubleFormatString), max.ToString(Parameters.DoubleFormatString)));
                }
            }
        }

        public void NormailizeArff()
        {
            int attrNum = 30 * m_cp.PeriodCount + 2;
            double[,] m_ranges = new double[attrNum, 2];
            using (System.IO.StreamReader sr = new System.IO.StreamReader(string.Format("{0}\\{1}_{2}.range", 
                TestParameters.BaseDir, m_trainTimeStart.ToString(Parameters.DateTimeFormat), m_trainTimeEnd.ToString(Parameters.DateTimeFormat))))
            {
                int i = 0;
                while (true)
                {
                    string s = sr.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        break;
                    string[] ss = s.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                    if (ss.Length != 3)
                        continue;
                    m_ranges[i, 0] = Convert.ToDouble(ss[1]);
                    m_ranges[i, 1] = Convert.ToDouble(ss[2]);
                    i++;
                }
                if (i != attrNum)
                {
                    throw new InvalidOperationException("Invalid range file!");
                }
            }

            for (int k = 0; k < (m_enableTest ? 2 : 1); ++k)
            {
                bool isTrain = (k == 0);

                Instances allInstances = WekaUtils.LoadInstances(GetArffFileName(isTrain));
                allInstances.setClassIndex(allInstances.numAttributes() - 1);

                for (int i = 0; i < allInstances.numInstances(); ++i)
                {
                    for (int j = 2; j < allInstances.numAttributes() - 1; ++j)
                    {
                        double p = allInstances.instance(i).value(j);
                        p = (p - m_ranges[j, 0]) / (m_ranges[j, 1] - m_ranges[j, 0]) * 2 - 1;
                        allInstances.instance(i).setValue(j, p);
                    }
                }

                WekaUtils.SaveInstances(allInstances, GetArffFileName(isTrain, Parameters.NewFileAppend));
            }
        }

        private weka.filters.Filter m_filter;
        public void FilterArff(weka.filters.Filter filter, string append = Parameters.NewFileAppend)
        {
            if (TestParameters.UseFilter)
            {
                Instances origInstances = m_trainInstances;
                filter.setInputFormat(origInstances);
                if (origInstances != null && origInstances.numInstances() > 0)
                {
                    m_trainInstancesNew = weka.filters.Filter.useFilter(origInstances, filter);
                }

                origInstances = m_testInstances;
                if (origInstances != null && origInstances.numInstances() > 0)
                {
                    m_testInstancesNew = weka.filters.Filter.useFilter(origInstances, filter);
                }

                if (TestParameters.SaveDataFile)
                {
                    string newFileName = GetArffFileName(true, m_currentDealType.ToString(), append);
                    string testNewFileName = GetArffFileName(false, m_currentDealType.ToString(), append);

                    if (!System.IO.File.Exists(newFileName)
                        && m_trainInstancesNew != null && m_trainInstancesNew.numInstances() > 0)
                    {
                        WekaUtils.SaveInstances(m_trainInstancesNew, newFileName);
                    }
                    if (!System.IO.File.Exists(testNewFileName)
                        && m_testInstancesNew != null && m_testInstancesNew.numInstances() > 0)
                    {
                        WekaUtils.SaveInstances(m_testInstancesNew, testNewFileName);
                    }
                }
            }
            else
            {
                m_trainInstancesNew = m_trainInstances;
                m_testInstancesNew = m_testInstances;
            }
        }

        public void FilterAccordProb()
        {
            var orig = "\"weka.filters.unsupervised.attribute.Remove -R 1,2,3,4,6 \"";
            weka.filters.MultiFilter filter = new weka.filters.MultiFilter();

            filter.setOptions(weka.core.Utils.splitOptions(string.Format("-F {0} -F {1}", orig, "\"weka.filters.unsupervised.instance.RemoveWithValues -S 1.0 -C last -L last -V \"")));
            FilterArff(filter, "1");

            filter.setOptions(weka.core.Utils.splitOptions(string.Format("-F {0} -F {1}", orig, "\"weka.filters.unsupervised.instance.RemoveWithValues -S 1.0 -C last -L last \"")));
            FilterArff(filter, "0");
        }

        public void ConvertToLibSVM(string append = null)
        {
            weka.core.converters.LibSVMSaver saver = new weka.core.converters.LibSVMSaver();
            for (int k = 0; k < 2; ++k)
            {
                bool isTrain = (k == 0);

                string arffFileName = GetArffFileName(isTrain, m_currentDealType.ToString(), append);
                string libsvmFileName = System.IO.Path.ChangeExtension(arffFileName, "libsvm");
                if (System.IO.File.Exists(libsvmFileName))
                    continue;

                //Instances origInstances = WekaUtils.LoadInstances(arffFileName);
                //origInstances.setClassIndex(origInstances.numAttributes() - 1);
                Instances origInstances = k == 0 ? m_trainInstancesNew : m_testInstancesNew;
                if (origInstances != null && origInstances.numInstances() > 0)
                {
                    saver.setInstances(origInstances);
                    saver.setFile(new java.io.File(libsvmFileName));
                    //saver.setDestination(new java.io.File(libsvmFileName));
                    saver.writeBatch();
                }

            }
        }
    

        //public void TestWithHp(DateTime start, DateTime end, string symbol, string period)
        //{
        //    string symbolPeriod = symbol + "_" + period;

        //    SetTraining(true);

        //    System.Data.DataTable dt = DbHelper.Instance.ExecuteDataTable(string.Format("SELECT Date, {5}, {6} FROM {0} WHERE Date >= '{1}' AND Date < '{2}' {3} {4}",
        //        symbolPeriod, start.ToString(Parameters.DateTimeFormat), end.ToString(Parameters.DateTimeFormat), 
        //        (string.IsNullOrEmpty(m_selectWhere) ? string.Empty : string.Format(" AND {0}", m_selectWhere)),
        //        m_selectOrder, WekaUtils.GetHpColumn(Parameters.AllDealTypes[0], m_currentTp, m_currentSl), WekaUtils.GetHpColumn(Parameters.AllDealTypes[1], m_currentTp, m_currentSl)));
        //    using (StreamWriter sw = new StreamWriter(string.Format("{0}\\ea_order.txt", TestParameters.BaseDir), false))
        //    {
        //        foreach (System.Data.DataRow i in dt.Rows)
        //        {
        //            string action;
        //            if (i[1] != System.DBNull.Value && (double)i[1] == 1)
        //                action = "Buy";
        //            else if (i[2] != System.DBNull.Value && (double)i[2] == 1)
        //                action = "Sell";
        //            else
        //                action = "Hold";

        //            sw.WriteLine(string.Format("{0}, {1}, {2}, {3}, 0, 0",
        //                action, ((DateTime)i["date"]).ToString(Parameters.DateTimeFormat), m_currentTp, m_currentSl));
        //        }
        //    }
        //}

        //private class OIS2 : ObjectInputStream
        //{
        //    public OIS2(InputStream inputStream) :
        //        base(inputStream)
        //    {
        //    }
        //    protected override java.lang.Class resolveClass(ObjectStreamClass desc)
        //    {
        //        if (desc.getName() == "libsvm.svm_model")
        //            return ikvm.runtime.Util.getFriendlyClassFromType(typeof(libsvm.svm_model));
        //        return base.resolveClass(desc);
        //    }
        //}

        //public void TrainWithWekaObsolete()
        //{
        //    string instanceFileName = string.Format("{0}\\instance.txt", m_baseDir);
        //    System.IO.File.Delete(instanceFileName);
        //    SetTraining(true);

        //    Instances allInstances = new Instances(new BufferedReader(new FileReader(GetArffFileName())));
        //    allInstances.setClassIndex(allInstances.numAttributes() - 1);

        //    List<int> used = new List<int>();
        //    List<int> curUsed = new List<int>();
        //    for (int i = 0; i < allInstances.numInstances(); ++i)
        //    {
        //        curUsed.Clear();

        //        Instances currentInstances = new Instances(allInstances, 0);

        //        if (!used.Contains(i))
        //        {
        //            currentInstances.add(allInstances.instance(i));
        //            used.Add(i);
        //            curUsed.Add(i);
        //        }
        //        else
        //        {
        //            continue;
        //        }

        //        string comment = string.Empty;
        //        AbstractClassifier cls = null;
        //        cls = new weka.classifiers.meta.CostSensitiveClassifier();
        //        cls.setOptions(weka.core.Utils.splitOptions(@"-cost-matrix ""[-7.0 0.0 3.5; 3.5 0.0 3.5; 3.5 0.0 -7.0]"" -S 1 -W weka.classifiers.functions.LibSVM -- -S 0 -K 0 -D 3 -G 0.0 -R 0.0 -N 0.5 -M 40.0 -C 1.0 -E 0.0010 -P 0.1"));
        //        for (int j = i + 1; j < allInstances.numInstances(); ++j)
        //        {
        //            if (!used.Contains(j))
        //            {
        //                currentInstances.add(allInstances.instance(j));
        //            }
        //            else
        //            {
        //                continue;
        //            }
        //            if (currentInstances.numInstances() < 10)
        //            {
        //                used.Add(j);
        //                curUsed.Add(j);
        //                continue;
        //            }

        //            WekaUtils.TrainInstances(cls, trainInstances);

        //            Evaluation eval = new Evaluation(currentInstances, new CostMatrix(new BufferedReader(new FileReader(m_costFileName))));
        //            eval.evaluateModel(cls, currentInstances);

        //            //WriteLog(string.Format("{0}, {1:N2}, {2:N2}, {3}, {4}, {5}", currentInstances.numInstances(), eval.correlationCoefficient(), eval.rootMeanSquaredError(), j, i, allInstances.numInstances()));
        //            //if (eval.correlationCoefficient() > 0.95 && eval.rootMeanSquaredError() < 1)
        //            WriteLog(string.Format("{0}, {1:N2}, {2:N2}, {3}, {4}, {5}", currentInstances.numInstances(), eval.incorrect(), eval.totalCost(), j, i, allInstances.numInstances()));
        //            if (eval.incorrect() < 5 && eval.totalCost() < 0)
        //            {
        //                used.Add(j);
        //                curUsed.Add(j);
        //                //comment = eval.correlationCoefficient().ToString(Parameters.DoubleFormatString);
        //            }
        //            else
        //            {
        //                currentInstances.delete(currentInstances.numInstances() - 1);
        //            }
        //        }

        //        ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(string.Format("{0}\\{1}.model", m_baseDir, i)));
        //        oos.writeObject(cls);
        //        oos.flush();
        //        oos.close();

        //        using (StreamWriter sw = new StreamWriter(instanceFileName, true))
        //        {
        //            sw.Write(i);
        //            sw.Write(":\t");
        //            foreach (int k in curUsed)
        //            {
        //                sw.Write(k);
        //                sw.Write(",");
        //            }
        //            sw.WriteLine(comment);
        //        }

        //    }
        //}
        
    }

}
