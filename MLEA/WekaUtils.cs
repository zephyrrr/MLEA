using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Linq;
using System.Data.SqlClient;
using weka.core;
using weka.classifiers;

namespace MLEA
{
    public class WekaUtils : Feng.Singleton<WekaUtils>
    {
        public static void AddInstanceQuickly(weka.core.Instances instances, IList<weka.core.Instance> listInstances)
        {
            java.util.ArrayList arrayListTrainInstances = Feng.Utils.ReflectionHelper.GetObjectValue(instances, "m_Instances") as java.util.ArrayList;
            foreach (var i in listInstances)
            {
                i.setDataset(instances);
                arrayListTrainInstances.add(i);
            }
        }
        public static string GetSubstring(string s, string tofind)
        {
            int idx = s.IndexOf(tofind);
            if (idx == -1)
                return null;
            int idx2 = s.IndexOf(',', idx + 1);
            if (idx2 == -1)
                return s.Substring(idx + tofind.Length);
            else
                return s.Substring(idx + tofind.Length, idx2 - idx - tofind.Length);
        }

        public static bool AndAll(bool[] bs)
        {
            foreach (var b in bs)
                if (!b)
                    return false;
            return true;
        }

        public static int GetSymbolPoint(string symbol)
        {
            if (symbol == "USDJPY" || symbol == "USDX")
                return 1;
            else
                return 100;
        }

        // InUSDJPY, digitalNorm = 1
        public static double NormalizeValue(string indName, int type, double v, double close, int digitalNorm = 100)
        {
            if (type < 0)
                type = -type;

            double ind = 0;
            if (TestParameters.IndicatorUseNumeric)
            {
                switch (type)
                {
                    case 1:
                        ind = (v - 50) * 2 * 0.01;
                        break;
                    case 2:
                        ind = (v - close) * digitalNorm;
                        break;
                    case 3:
                        ind = (v * digitalNorm - 0.5) * 2;
                        break;
                    case 4:
                        ind = v * digitalNorm;
                        break;
                    case 5:
                        ind = v * 0.002;
                        break;
                    case 6:
                        ind = (v - 0.5) * 2;
                        break;
                    case 7:
                        ind = (v + 50) * 2 * 0.01;
                        break;
                    case 8:
                        ind = v;
                        break;
                    case 9:
                        ind = v * digitalNorm;
                        break;
                    default:
                        throw new ArgumentException("invalid type of indicator!");
                }
            }
            else
            {
                switch (type)
                {
                    case 1:
                        ind = v > 70 ? 2 : (v < 30 ? 0 : 1);
                        break;
                    case 2:
                        ind = v > close ? 2 : (v < close ? 0 : 1);
                        break;
                    case 3:
                        throw new ArgumentException("invalid type of indicator!");
                    case 4:
                        ind = v > 0 ? 2 : (v < 0 ? 0 : 1);
                        break;
                    case 5:
                        ind = v > 0 ? 2 : (v < 0 ? 0 : 1);
                        break;
                    case 6:
                        ind = v > 0.5 ? 2 : (v < 0.5 ? 0 : 1);
                        break;
                    case 7:
                        ind = v > -20 ? 2 : (v < -80 ? 0 : 1);
                        break;
                    case 8:
                        ind = v > 0 ? 2 : (v < 0 ? 0 : 1);
                        break;
                    case 9:
                        ind = v > 0.02 ? 2 : 0;
                        break;
                    default:
                        throw new ArgumentException("invalid type of indicator!");
                }
            }
            return ind;
        }

        public static string GetHpColumn(char dealType, int tp, int sl, string append = null)
        {
            string postFix = "_" + tp.ToString() + "_" + sl.ToString();
            if (string.IsNullOrEmpty(append))
                return dealType + "_hp" + postFix;
            else
                return dealType + "_hp_" + append + postFix;
        }

        private static Dictionary<DateTime, long> s_GetTimeFromDateBuffer = new Dictionary<DateTime, long>();
        public static long GetTimeFromDate(DateTime date)
        {
            long ret = (long)(date - Parameters.MtStartTime).TotalSeconds;
            return ret;

            if (!s_GetTimeFromDateBuffer.ContainsKey(date))
                s_GetTimeFromDateBuffer[date] = ret;
            return s_GetTimeFromDateBuffer[date];
        }
        public static Dictionary<long, DateTime> s_GetDateFromTimeBuffer = new Dictionary<long, DateTime>();
        public static DateTime GetDateFromTime(long time)
        {
            DateTime ret = Parameters.MtStartTime.AddSeconds(time);
            return ret;
            if (!s_GetDateFromTimeBuffer.ContainsKey(time))
                s_GetDateFromTimeBuffer[time] = ret;
            return s_GetDateFromTimeBuffer[time];
        }

        public static int GetDealTypeIdx(char dealType)
        {
            return dealType == 'B' ? 0 : (dealType == 'S' ? 1 : -1);
        }

        #region"ModelData"
        public static void SaveAllModelsInDirectory()
        {
            //var fileNames = System.IO.Directory.GetFiles(TestParameters.BaseDir, "*.model");
            //int i = 0;

            //Func<bool> f2 = () => i >= fileNames.Length;
            //Func<SqlCommand[]> f1 = () =>
            //{
            //    string fileName = fileNames[i];
            //    SqlCommand cmd = new SqlCommand("INSERT INTO ModelData ([FileName],[Type],[Data]) VALUES (@FileName, @Type, @Data)");
            //    cmd.Parameters.AddWithValue("@FileName", System.IO.Path.GetFileNameWithoutExtension(fileName));
            //    cmd.Parameters.AddWithValue("@Type", TestParameters.ClassifierType);
            //    cmd.Parameters.AddWithValue("@Data", System.IO.File.ReadAllBytes(fileName));

            //    i++;
            //    return new SqlCommand[] { cmd };
            //};
            //DbUtils.BatchDb(f1, f2);
        }

        //private bool m_enableModelDataInDb = false;
        public byte[] LoadModelData(string fileName)
        {
            //if (!m_enableModelDataInDb)
            //    return null;

            //SqlCommand cmd = new SqlCommand("SELECT [Data] FROM ModelData WHERE [FileName] = @FileName AND [Type] = @Type");
            //cmd.Parameters.AddWithValue("@FileName", System.IO.Path.GetFileNameWithoutExtension(fileName));
            //cmd.Parameters.AddWithValue("@Type", TestParameters.ClassifierType);
            //var ret = Feng.Data.DbHelper.Instance.ExecuteScalar(cmd);
            //if (ret != System.DBNull.Value)
            //    return (byte[])ret;
            //else
                return null;
        }
        public void SaveModelData(string fileName)
        {
            //if (!m_enableModelDataInDb)
            //    return;

            //SqlCommand cmd = new SqlCommand("IF NOT EXISTS (SELECT * FROM ModelData WHERE [FileName] = @FileName AND [Type] = @Type) INSERT INTO ModelData ([FileName],[Type],[Data]) VALUES (@FileName, @Type, @Data)");
            //cmd.Parameters.AddWithValue("@FileName", System.IO.Path.GetFileNameWithoutExtension(fileName));
            //cmd.Parameters.AddWithValue("@Type", TestParameters.ClassifierType);
            //cmd.Parameters.AddWithValue("@Data", System.IO.File.ReadAllBytes(fileName));
            //Feng.Data.DbHelper.Instance.ExecuteNonQuery(cmd);
        }
        public void DeleteModelData(string fileName)
        {
            //if (!m_enableModelDataInDb)
            //    return;
            //SqlCommand cmd = new SqlCommand("DELETE FROM ModelData WHERE [FileName] = @FileName AND [Type] = @Type");
            //cmd.Parameters.AddWithValue("@FileName", System.IO.Path.GetFileNameWithoutExtension(fileName));
            //cmd.Parameters.AddWithValue("@Type", TestParameters.ClassifierType);
            //Feng.Data.DbHelper.Instance.ExecuteNonQuery(cmd);
        }
        #endregion

        public static long GetTimeValueFromInstances(Instances instances, int attrIdx, int instIdx)
        {
            try
            {
                //return Convert.ToDateTime(instances.attribute(attrIdx).formatDate(instances.instance(instIdx).value(attrIdx)));
                long time = (long)instances.instance(instIdx).value(attrIdx) / 1000;
                return time;
            }
            catch (Exception ex)
            {
                WekaUtils.Instance.WriteLog("Error when parse datetime of " + instances.instance(instIdx).value(attrIdx) + ", " + ex.Message);
            }
            return Parameters.MaxTime;
        }

        public static DateTime GetDateValueFromInstances(Instances instances, int attrIdx, int instIdx)
        {
            return GetDateFromTime(GetTimeValueFromInstances(instances, attrIdx, instIdx));
        }

        public static double GetValueFromInstance(Instances instances, int attrIdx, int instIdx)
        {
            return instances.instance(instIdx).value(attrIdx);
        }
        public static double GetValueFromInstance(Instances instances, string attrName, int instIdx)
        {
            return instances.instance(instIdx).value(instances.attribute(attrName));
        }
        // -40: 6 symbol, H4, p5
        // -41: 1 symbol
        // -42: 2
        // -43: 3
        //private static Type m_classifierType;
        //private static Type ClassifierType
        //{
        //    get
        //    {
        //        if (m_classifierType == null)
        //            m_classifierType = CreateClassifier().GetType();
        //        return m_classifierType;
        //    }
        //}

        public static IMoneyManagement CreateMoneyManagement(Type mmType, int tp = 0, int sl = 0)
        {
            if (mmType != null)
            {
                return Feng.Utils.ReflectionHelper.CreateInstanceFromType(mmType, new object[] { tp, sl }) as IMoneyManagement;
            }
            //return new KellyMoneyManagement();
            //return new ProbMoneyManagement(tp, sl);
            //return new FixedMoneyManagement();
            return new RiskMoneyManagement(tp, sl);
        }

        public static weka.classifiers.Classifier CreateClassifier(Type clsType, int tp = 0, int sl = 0, string option = null)
        {
            Dictionary<Type, string> parameters = new Dictionary<Type, string>(){
                { typeof(SvmLightClassifier), "-c 20 -l 4 -w 1 --p 1 --b 1"},
                { typeof(weka.classifiers.functions.LibSVM), "-Q -S 0 -K 2 -D 3 -R 0.0 -N 0.5 -M 40.0 -E 0.1 -P 0.1 -B -C 1 -G 1"},
                { typeof(weka.classifiers.functions.VotedPerceptron), "-I 1 -E 1.0 -S 1 -M 10000"},
                { typeof(weka.classifiers.functions.LibLINEAR), "-S 7 -C 1 -B 1 "},  // -W \"1 1\"
                { typeof(MyLibLinear), "-S 2 -C 1 -B 1 "},  // S 7???
                { typeof(weka.classifiers.functions.MultilayerPerceptron), "-L 0.3 -M 0.2 -N 500 -V 0 -S 0 -E 20 -H a"},
                { typeof(weka.classifiers.lazy.IBk), "-K 1 -W 0 -A \"weka.core.neighboursearch.LinearNNSearch -A \\\"weka.core.EuclideanDistance -R first-last\\\"\""},
                { typeof(MincostLiblinearClassifier), ""},
                { typeof(GaussianAnomalyDetection), ""},
                { typeof(AllTrueClassifier), ""}
            };

            AbstractClassifier cls;
            if (clsType != null)
            {
                if (clsType.AssemblyQualifiedName.Contains("MLEA"))
                {
                    cls = Feng.Utils.ReflectionHelper.CreateInstanceFromType(clsType, new object[] { tp, sl }) as AbstractClassifier;
                }
                else
                {
                    cls = Feng.Utils.ReflectionHelper.CreateInstanceFromType(clsType) as AbstractClassifier;
                }
                if (!string.IsNullOrEmpty(option))
                {
                    cls.setOptions(weka.core.Utils.splitOptions(option));
                }
                else if (parameters.ContainsKey(clsType) && !string.IsNullOrEmpty(parameters[clsType]))
                {
                    cls.setOptions(weka.core.Utils.splitOptions(parameters[clsType]));
                }
                return cls;
            }

            cls = new AllTrueClassifier();
            return cls;
        }

        public static weka.filters.Filter CreateNormalFilter()
        {
            var filter = new weka.filters.MultiFilter();
            //filter.setOptions(weka.core.Utils.splitOptions("-F \"weka.filters.unsupervised.attribute.Remove -R 1,4\" -F \"weka.filters.unsupervised.attribute.Discretize -B 10 -M -1.0 -R first-last\""));
            filter.setOptions(weka.core.Utils.splitOptions("-F \"weka.filters.unsupervised.attribute.Remove -R 1,2,3,4,5,6 \""));

            //filter.setOptions(weka.core.Utils.splitOptions("-F \"weka.filters.unsupervised.attribute.Remove -R 1,4\" -F \"weka.filters.unsupervised.attribute.Normalize -S 1.0 -T 0.0\""));

            return filter;
        }

        public static weka.clusterers.Clusterer CreateCluster()
        {
            weka.clusterers.RandomizableClusterer cluster = new weka.clusterers.SimpleKMeans();
            cluster.setOptions(weka.core.Utils.splitOptions("-V -M -N 10 -A \"weka.core.EuclideanDistance -R first-last\" -I 500 -O -S 10"));

            return cluster;
        }
        public static Instances RemoveClassAttribute(Instances origInstances)
        {
            var filter = new weka.filters.unsupervised.attribute.Remove();
            filter.setOptions(weka.core.Utils.splitOptions(string.Format("-R {0}", origInstances.classIndex() + 1)));
            filter.setInputFormat(origInstances);
            Instances newInstances = weka.filters.Filter.useFilter(origInstances, filter);
            return newInstances;
        }

        private static weka.core.converters.ArffSaver m_arffSaver = new weka.core.converters.ArffSaver();
        public static void SaveInstances(weka.core.Instances instances, string fileName)
        {
            var file = new java.io.File(fileName);
            //m_arffSaver.setDestination(file);
            m_arffSaver.setInstances(instances);
            m_arffSaver.setFile(file);
            m_arffSaver.writeBatch();
        }
        private static object m_lockObject = new object();
        public static Instances LoadInstances(string fileName)
        {
            lock (m_lockObject)
            {
                if (!fileName.Contains("\\"))
                {
                    fileName = string.Format("{0}\\{1}", TestParameters.BaseDir, fileName);
                }
                var fr = new java.io.FileReader(fileName);
                var br = new java.io.BufferedReader(fr);
                Instances instances = new Instances(br);
                br.close();
                fr.close();
                instances.setClassIndex(instances.numAttributes() - 1);

                return instances;
            }
        }

        public static double[] ClassifyInstances(Instances testInstances, Classifier cls)
        {
            double[] cv2;
            if (cls is IBatchClassifier)
            {
                cv2 = (cls as IBatchClassifier).classifyInstances(testInstances);
            }
            else
            {
                cv2 = new double[testInstances.numInstances()];
                for (int i = 0; i < testInstances.numInstances(); i++)
                {
                    cv2[i] = cls.classifyInstance(testInstances.instance(i));
                }
            }
            return cv2;
        }

        public static MyEvaluation TestInstances(Instances testInstances, Classifier cls, CostMatrix costMatrix = null)
        {
            //Evaluation eval = new Evaluation(testInstances, new CostMatrix(new BufferedReader(new FileReader(m_costFileName))));
            MyEvaluation eval;
            if (costMatrix != null)
            {
                eval = new MyEvaluation(costMatrix);
            }
            else
            {
                eval = new MyEvaluation();
            }
            //eval.crossValidateModel(cls, origInstances, 5, new java.util.Random(1));
            //WriteLog(eval.toSummaryString());
            //WriteLog("Confusion matrix is " + eval.toMatrixString());
            //WriteLog("total cose is " + eval.totalCost());
            //WriteLog("Crossvalidate is done.");
            //using (System.IO.StreamWriter sw = new StreamWriter(string.Format("{0}\\crossValidateResult.txt", m_baseDir), true))
            //{
            //    sw.WriteLine(string.Format("CrossValidate Data from {0} to {1}", m_trainTimeStart.ToString(m_dateTimeFormat), m_trainTimeEnd.ToString(m_dateTimeFormat)));
            //    sw.WriteLine(eval.toSummaryString());
            //    sw.WriteLine("Confusion matrix is " + eval.toMatrixString());
            //}

            //eval.evaluateModel(cls, origInstances);
            //WriteEvalSummary(eval, string.Format("Train Data from {0} to {1}", m_trainTimeStart.ToString(m_dateFormat), m_trainTimeEnd.ToString(m_dateFormat)));

            eval.evaluateModel(cls, testInstances);

            return eval;
        }

        public static IMoneyManagement TrainInstances4MM(Instances trainInstances, string modelFileName, IMoneyManagement mm)
        {
            mm.Build(trainInstances);
            return mm;
        }

        public static bool TrainInstances(Classifier cls, Instances trainInstances)
        {
            try
            {
                cls.buildClassifier(trainInstances);
                return true;
            }
            catch (Exception ex)
            {
                WekaUtils.Instance.WriteLog(ex.Message);
                return false;
            }
        }
        public static Classifier TrainInstances(Instances trainInstances, string modelFileName, Classifier cls)
        {
            WekaUtils.TrainInstances(cls, trainInstances);

            if (!string.IsNullOrEmpty(modelFileName))
            {
                if (cls.GetType().Name.Contains("MLEA111"))
                {
                    Feng.Windows.Utils.SerializeHelper.Serialize(modelFileName, cls);
                }
                else
                {
                    //var fos = new java.io.FileOutputStream(modelFileName);
                    //java.io.ObjectOutputStream oos = new java.io.ObjectOutputStream(fos);
                    //oos.writeObject(cls);
                    //oos.flush();
                    //oos.close();
                    //fos.close();

                    weka.core.SerializationHelper.write(modelFileName, cls);
                }

                Instance.SaveModelData(modelFileName);
            }
            return cls;
        }

        public static Classifier TryLoadClassifier(string modelFileName)
        {
            if (!System.IO.File.Exists(modelFileName))
            {
                byte[] d = Instance.LoadModelData(modelFileName);
                if (d != null)
                {
                    System.IO.File.WriteAllBytes(modelFileName, d);
                }
            }
            
            if (System.IO.File.Exists(modelFileName))
            {
                java.io.FileInputStream fis = null;
                try
                {
                    Classifier cls = null;
                    if (modelFileName.Contains("MLEA111"))
                    {
                        cls = Feng.Windows.Utils.SerializeHelper.Deserialize<MincostLiblinearClassifier>(modelFileName);
                    }
                    else
                    {
                        //fis = new java.io.FileInputStream(modelFileName);
                        //var ois = new java.io.ObjectInputStream(fis);
                        //var cls = (Classifier)ois.readObject();
                        //ois.close();
                        //fis.close();

                        cls = (Classifier)weka.core.SerializationHelper.read(modelFileName);
                    }

                    //if (cls.GetType() != ClassifierType)
                    //{
                    //    throw new ArgumentException("Classifier Type is wrong!");
                    //}
                    return cls;
                }
                catch (Exception)
                {
                    if (fis != null)
                    {
                        fis.close();
                    }
                    System.IO.File.Delete(modelFileName);
                    Instance.DeleteModelData(modelFileName);
                }
            }
            return null;
        }

        //public static void WriteData(string str)
        //{
        //    using (System.IO.StreamWriter sw = new StreamWriter(string.Format("{0}\\testData.txt", TestParameters.BaseDir), true))
        //    {
        //        sw.WriteLine(str);
        //    }
        //}

        static string tabString = "\t";
        static string doubleTabString = "\t\t";

        private System.IO.StreamWriter m_swLog;
        public static string GetCommaString(string s)
        {
            return s + ", ";
        }
        public static string GetTabbledString(string s, int tabLength = 4)
        {
            if (s.Length < tabLength)
                return s + doubleTabString;
            else
                return s + tabString;
        }

        public void FlushLog()
        {
            if (m_swLog != null)
            {
                m_swLog.Flush();
            }
        }
        public void WriteHorizontalLine()
        {
            WekaUtils.Instance.WriteLog("----------------------------------------------------------------------");
        }
        public void WriteLog(string str, bool addNewLine = true, ConsoleColor color = ConsoleColor.Gray)
        {
            lock (m_lockObject)
            {
                if (color != ConsoleColor.Gray)
                {
                    System.Console.ForegroundColor = color;
                    if (addNewLine)
                    {
                        System.Console.WriteLine(str);
                    }
                    else
                    {
                        System.Console.Write(str);
                    }
                    System.Console.ForegroundColor = ConsoleColor.Gray;
                }
                else
                {
                    if (addNewLine)
                    {
                        System.Console.WriteLine(str);
                    }
                    else
                    {
                        System.Console.Write(str);
                    }
                }
                if (m_swLog == null)
                {
                    int idx = 0;
                    while (true)
                    {
                        try
                        {
                            m_swLog = new StreamWriter(string.Format("{0}\\console{1}.txt", TestParameters.BaseDir, idx == 0 ? "" : idx.ToString()), true);
                            break;
                        }
                        catch (Exception)
                        {
                            idx++;
                        }
                    }
                    m_swLog.AutoFlush = !TestParameters2.RealTimeMode;
                }
                if (addNewLine)
                {
                    m_swLog.WriteLine(str);
                }
                else
                {
                    m_swLog.Write(str);
                }
            }
        }

        public void DeInit()
        {
            if (m_swLog != null)
            {
                try
                {
                    m_swLog.Close();
                }
                catch (Exception)
                {
                }
                m_swLog = null;
            }
            //EndTransaction();
        }

        //private void WriteEvalSummary(Evaluation eval, string title)
        //{
        //    System.Console.WriteLine(title);
        //    System.Console.WriteLine(eval.toSummaryString());
        //    System.Console.WriteLine("Confusion matrix is " + eval.toMatrixString());
        //    System.Console.WriteLine("Cost is " + eval.totalCost());
        //    //WriteLog("Eval test is done.");
        //    using (System.IO.StreamWriter sw = new StreamWriter(string.Format("{0}\\testResult.txt", m_baseDir), true))
        //    {
        //        sw.WriteLine(title);
        //        sw.WriteLine(eval.toSummaryString());
        //        sw.WriteLine("Confusion matrix is " + eval.toMatrixString());
        //    }
        //}
        public static int GetMinuteofPeriod(string period)
        {
            if (period == "M5")
                return 5;
            else if (period == "M15")
                return 15;
            else if (period == "M30")
                return 30;
            else if (period == "H1")
                return 60;
            else if (period == "H4")
                return 60 * 4;
            else if (period == "D1")
                return 60 * 24;
            else if (period == "M4")
                return 4;
            else if (period == "M1")
                return 1;
            else
                throw new ArgumentException("Invalid period!");
        }

        public static double[] StringToDoubleArray(string str)
        {
            if (string.IsNullOrEmpty(str))
            {
                return Parameters.DoubleArrayEmpty;
            }
            return StringToArray<double>(str);
        }
        public static int[] StringToIntArray(string str)
        {
            if (string.IsNullOrEmpty(str))
            {
                return Parameters.IntArrayEmpty;
            }
            return StringToArray<int>(str);
        }
        public static T[] StringToArray<T>(string str)
        {
            string[] ss = str.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            T[] tr = new T[ss.Length];
            for (int i = 0; i < ss.Length; ++i)
                tr[i] = (T)Convert.ChangeType(ss[i], typeof(T));
            return tr;
        }

        public static string ArrayToString<T>(T[] d)
        {
            if (d == null || d.Length == 0)
                return string.Empty;

            StringBuilder sb = new StringBuilder();
            foreach (var i in d)
            {
                sb.Append(((T)i).ToString());
                sb.Append(" ");
            }
            string str = sb.ToString();
            return str;
        }

        public static string DoubleArrayToIntString(double[] d)
        {
            if (d == null || d.Length == 0)
                return string.Empty;

            StringBuilder sb = new StringBuilder();
            foreach (var i in d)
            {
                sb.Append(((int)i).ToString());
                sb.Append(" ");
            }
            string str = sb.ToString();
            return str;
        }

        public static void DebugAssert(bool condition, string message)
        {
#if DEBUG
            System.Diagnostics.Debug.Assert(condition, message);
#else
            if (!condition)
            {
                throw new AssertException(message);
            }
#endif
        }
    }
}
