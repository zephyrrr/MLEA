using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NetSVMLight;

namespace MLEA
{
    using Classifier = weka.classifiers.Classifier;
    using AbstractClassifier = weka.classifiers.AbstractClassifier;
    using Sourcable = weka.classifiers.Sourcable;
    using Attribute = weka.core.Attribute;
    using Capabilities = weka.core.Capabilities;
    using Instance = weka.core.Instance;
    using Instances = weka.core.Instances;
    using RevisionUtils = weka.core.RevisionUtils;
    using Utils = weka.core.Utils;
    using WeightedInstancesHandler = weka.core.WeightedInstancesHandler;
    using Capability = weka.core.Capabilities.Capability;

    public interface IBatchClassifier
    {
        double[] classifyInstances(Instances instances);
    }
    public class SvmLightClassifier : weka.classifiers.AbstractClassifier, weka.core.WeightedInstancesHandler, weka.classifiers.Sourcable, IBatchClassifier
    {
        private static SVMLearn learner = new SVMLearn();
        private static SVMClassify classifier = new SVMClassify();

        private string m_baseDir;
        private static string[] m_baseDirs = new string[] {  "c:\\", "d:\\", "e:\\" };

        private const string s_learnerPath = "svm_perf_learn.exe";
        private const string m_trainingFileName = "svmlight_train.dat";
        private const string m_modelFileName = "svmlight_model.dat";
        private const string s_classifierPath = "svm_perf_classify.exe";
        private const string m_testFileName = "svmlight_test.dat";
        private const string m_testOutputFileName = "svmlight_output.dat";

        private string m_trainingFile;
        private string m_modelFile;
        private string m_testFile;
        private string m_testOutputFile;
        private string m_trainArgs;
        private static LibSVMSaver4SvmLight libsvmSaver = new LibSVMSaver4SvmLight();
        private static Instances m_sampleInstances;

        public SvmLightClassifier(int tp, int sl)
        {
            m_tp = tp;
            m_sl = sl;

            InitFileNames();
        }
        private double m_tp, m_sl;

        private string m_randomFileName;
        private void InitFileNames()
        {
            if (!string.IsNullOrEmpty(m_baseDir))
                return;

            for (int i = 0; i < m_baseDirs.Length; ++i)
            {
                if (System.IO.Directory.Exists(m_baseDirs[i]))
                {
                    m_baseDir = m_baseDirs[i];
                    break;
                }
            }

            if (string.IsNullOrEmpty(m_randomFileName))
            {
                m_randomFileName = System.IO.Path.GetRandomFileName();
                m_randomFileName = m_randomFileName.Replace('.', 'a');
            }

            m_trainingFile = System.IO.Path.Combine(m_baseDir, m_randomFileName + "_" + m_trainingFileName);
            m_modelFile = System.IO.Path.Combine(m_baseDir, m_randomFileName + "_" + m_modelFileName);
            m_testFile = System.IO.Path.Combine(m_baseDir, m_randomFileName + "_" + m_testFileName);
            m_testOutputFile = System.IO.Path.Combine(m_baseDir, m_randomFileName + "_" + m_testOutputFileName);

            if (System.IO.File.Exists(m_modelFile))
            {
                System.IO.File.Delete(m_modelFile);
            }
        }

        private byte[] m_modelData;
        private double? m_delta = null;

        protected SvmLightClassifier(System.Runtime.Serialization.SerializationInfo info1, System.Runtime.Serialization.StreamingContext context1)
            : base(info1, context1)
        {
            InitFileNames();
        }

        internal const long serialVersionUID = 48055541465867957L;
        private void writeObject(java.io.ObjectOutputStream oos)
        {
            if (m_modelData != null)
            {
                oos.writeInt(3);
                oos.writeInt(m_modelData.Length);
                oos.write(m_modelData, 0, m_modelData.Length);
                oos.writeBoolean(m_mustValue.HasValue);
                oos.writeInt(m_mustValue.HasValue ? m_mustValue.Value : 0);
                oos.writeDouble(m_delta.Value);
            }
        }
        private void readObject(java.io.ObjectInputStream ois)
        {
            try
            {
                m_modelData = null;
                InitFileNames();

                int version = ois.readInt();
                if (version == 2)
                {
                    int n = ois.readInt();
                    m_modelData = new byte[n];
                    int m = 0;
                    while (true)
                    {
                        int mm = ois.read(m_modelData, m, n - m);
                        m += mm;
                        if (m >= n)
                            break;
                    }
                    ois.readBoolean();
                    m_delta = ois.readDouble();

                    System.IO.File.WriteAllBytes(m_modelFile, m_modelData);
                }
                else if (version == 3)
                {
                    int n = ois.readInt();
                    m_modelData = new byte[n];
                    int m = 0;
                    while (true)
                    {
                        int mm = ois.read(m_modelData, m, n - m);
                        m += mm;
                        if (m >= n)
                            break;
                    }
                    Boolean b = ois.readBoolean();
                    if (b)
                    {
                        m_mustValue = ois.readInt();
                    }
                    else
                    {
                        ois.readInt();
                    }
                    m_delta = ois.readDouble();

                    System.IO.File.WriteAllBytes(m_modelFile, m_modelData);
                }
            }
            catch (Exception)
            {
                throw;
            }
        }

        //public bool LoadModelFile(string modelFileName)
        //{
        //    if (System.IO.File.Exists(m_modelFile))
        //    {
        //        System.IO.File.Delete(m_modelFile);
        //    }
        //    if (System.IO.File.Exists(modelFileName))
        //    {
        //        System.IO.File.Copy(modelFileName, m_modelFile);
        //        return true;
        //    }
        //    return false;
        //}
        //public void SaveModelFile(string modelFileName)
        //{
        //    System.IO.File.Copy(m_modelFile, modelFileName, true);
        //}

        public virtual string globalInfo()
        {
            return "SvmLightClassifier";
        }

        public override Capabilities getCapabilities()
        {
            Capabilities result = base.getCapabilities();
            result.disableAll();

            result.disableAllClasses();               // disable all class types
            result.disableAllClassDependencies();     // no dependencies!

            // attributes
            result.enable(Capabilities.Capability.NOMINAL_ATTRIBUTES);
            result.enable(Capabilities.Capability.NUMERIC_ATTRIBUTES);

            // class
            result.enable(Capabilities.Capability.NOMINAL_CLASS);
            //result.enable(Capabilities.Capability.NUMERIC_CLASS);

            // instances
            result.setMinimumNumberInstances(0);

            return result;
        }

        //private void ConvertNorminalToString(string fileName)
        //{
        //    List<string> list = new List<string>();
        //    using (System.IO.StreamReader sr = new System.IO.StreamReader(fileName))
        //    {
        //        while (true)
        //        {
        //            if (sr.EndOfStream)
        //                break;

        //            string s = sr.ReadLine();
        //            if (string.IsNullOrEmpty(s))
        //                continue;

        //            int idx = s.IndexOf(' ');
        //            string c = idx == -1 ? s : s.Substring(0, idx);
        //            if (Convert.ToDouble(c) == 0)
        //            {
        //                list.Add("-1.0 " + (idx == -1 ? string.Empty : s.Substring(idx + 1)));
        //            }
        //            else if (Convert.ToDouble(c) == 1)
        //            {
        //                list.Add("0.0 " + (idx == -1 ? string.Empty : s.Substring(idx + 1)));
        //            }
        //            else if (Convert.ToDouble(c) == 2)
        //            {
        //                list.Add("+1.0 " + (idx == -1 ? string.Empty : s.Substring(idx + 1)));
        //            }
        //            else
        //            {
        //                list.Add(s);
        //            }
        //        }
        //    }
        //    using (System.IO.StreamWriter sw = new System.IO.StreamWriter(fileName))
        //    {
        //        foreach (string s in list)
        //        {
        //            sw.WriteLine(s);
        //        }
        //    }
        //}

        //private Random m_randomGenerator;
        private void AddInstancesAccordWeight(Instances instances)
        {
            // 0, 2
            double[] weights = MincostLiblinearClassifier.GetCount(instances);
            if (weights == null)
                return;

            double c = m_tp / m_sl;
            if (c == 1 && weights[0] == weights[1])
                return;

            int n = 0;
            int toCopyClass = 0;
            if (c >= 1)
            {
                int shouldWeight1 = (int)(c * weights[1]);
                n = (int)(shouldWeight1 - weights[1]);
                toCopyClass = 2;
            }
            else
            {
                int shouldShouldWeight0 = (int)(1 / c * weights[0]);
                n = (int)(weights[1] - weights[0]);
                toCopyClass = 0;
            }
            //m_randomGenerator = new Random((int)System.DateTime.Now.Ticks);


            List<Instance> copyInstances = new List<Instance>();
            for (int i = 0; i < instances.numInstances(); ++i)
            {
                if (instances.instance(i).classValue() == toCopyClass)
                {
                    copyInstances.Add(instances.instance(i));
                }
            }

            int nAll = n / copyInstances.Count;
            for (int j = 0; j < nAll; ++j)
            {
                for (int i = 0; i < copyInstances.Count; ++i)
                {
                    Instance newInstance = new weka.core.DenseInstance(copyInstances[i]);
                    instances.add(newInstance);
                    newInstance.setDataset(instances);
                }
            }
            //for (int j = 0; j < n - nAll * copyInstances.Count; ++j)
            //{
            //    int idx = (int)(m_randomGenerator.NextDouble() * copyInstances.Count);
            //    idx = Math.Min(idx, copyInstances.Count - 1);
            //    Instance newInstance = new weka.core.DenseInstance(copyInstances[idx]);
            //    instances.add(newInstance);
            //    newInstance.setDataset(instances);
            //}

            if (n - nAll * copyInstances.Count > 0)
            {
                Instance avgInstance = new weka.core.DenseInstance(instances.numAttributes());
                for (int i = 0; i < avgInstance.numAttributes(); ++i)
                {
                    double sum = 0;
                    for (int j = 0; j < copyInstances.Count; ++j)
                    {
                        sum += copyInstances[j].value(i);
                    }
                    avgInstance.setValue(i, sum / copyInstances.Count);
                }
                for (int j = 0; j < n - nAll * copyInstances.Count; ++j)
                {
                    Instance newInstance = new weka.core.DenseInstance(avgInstance);
                    instances.add(newInstance);
                }
            }
        }

        private int? m_mustValue = null;
        public override void buildClassifier(Instances instances)
        {
            m_mustValue = null;
            var weights = MincostLiblinearClassifier.GetCount(instances);
            if (weights[0] == 0)
            {
                m_mustValue = 2;
                m_delta = 0;
                return;
            }
            else if (weights[2] == 0)
            {
                m_mustValue = 0;
                m_delta = 0;
                return;
            }

            m_sampleInstances = new Instances(instances, 0);

            // can classifier handle the data?
            getCapabilities().testWithFail(instances);

            Instances trainInstances = new Instances(instances, 0, instances.numInstances());
            AddInstancesAccordWeight(trainInstances);

            if (System.IO.File.Exists(m_trainingFile))
            {
                System.IO.File.Delete(m_trainingFile);
            }
            libsvmSaver.setInstances(trainInstances);
            libsvmSaver.setFile(new java.io.File(m_trainingFile));
            libsvmSaver.writeBatch();

            //ConvertNorminalToString(m_trainingFile);

            if (System.IO.File.Exists(m_modelFile))
            {
                System.IO.File.Delete(m_modelFile);
            }

            string[] options = Utils.splitOptions(m_trainArgs);
            int idx = Utils.getOptionPos('c', options);
            if (idx != -1)
            {
                double c = Convert.ToDouble(options[idx + 1]);
                c = c * trainInstances.numInstances() / 100.0;
                options[idx + 1] = c.ToString();
                m_trainArgs = Utils.joinOptions(options);
            }

            learner.ExecuteLearner(s_learnerPath, m_trainingFile, m_modelFile, m_trainArgs);
            if (!System.IO.File.Exists(m_modelFile))
            {
                throw new InvalidOperationException(learner.Output);
            }
            m_modelData = System.IO.File.ReadAllBytes(m_modelFile);

            GetBestDelta(instances);

            if (System.IO.File.Exists(m_trainingFile))
            {
                System.IO.File.Delete(m_trainingFile);
            }
        }

        private void GetBestDelta(Instances instances)
        {
            if (m_delta.HasValue)
                return;

            double[] v = distributionForInstances(instances);

            double bestDelta = 0;
            double bestScore = double.MinValue;
            int bestNum = 0;

            for (int i = -50; i < 50; ++i)
            {
                double delta = i / 10.0;
                double dist = 0;

                int tp = 0, fp = 0;
                for (int j = 0; j < v.Length; ++j)
                {
                    if (v[j] <= delta)
                        continue;
                    if (instances.instance(j).classValue() == 0)
                    {
                        fp++;
                    }
                    else if (instances.instance(j).classValue() == 2)
                    {
                        tp++;
                        dist += v[j] - delta;
                    }
                    else if (instances.instance(j).classValue() == 1)
                    {
                    }
                    else
                    {
                        throw new ArgumentException("invalid class value of " + instances.instance(j).classValue());
                    }
                }
                double cost = m_tp * tp + m_sl * fp;
                //cost = -dist / tp;
                double precision = tp + fp == 0 ? 0 : (double)tp / (tp + fp);

                //if (cost <= bestCost)
                if (precision > bestScore || (precision == bestScore && tp >= bestNum))
                {
                    bestScore = precision;
                    bestDelta = delta;
                    bestNum = tp;
                }
            }

            m_delta = bestDelta;
        }

        public double[] distributionForInstances(Instances instances)
        {
            double[] ret = new double[instances.numInstances()];
            if (m_mustValue.HasValue)
            {
                for (int i = 0; i < ret.Length; ++i)
                    ret[i] = m_mustValue == 0 ? m_delta.Value - 1 : m_delta.Value + 1;
                return ret;
            }

            if (System.IO.File.Exists(m_testFile))
            {
                System.IO.File.Delete(m_testFile);
            }
            libsvmSaver.setInstances(instances);
            libsvmSaver.setFile(new java.io.File(m_testFile));
            libsvmSaver.writeBatch();
            //ConvertNorminalToString(m_testFile);

            if (System.IO.File.Exists(m_testOutputFile))
            {
                System.IO.File.Delete(m_testOutputFile);
            }

            classifier.ExecuteClassifier(s_classifierPath, m_testFile, m_modelFile, m_testOutputFile);
            if (!System.IO.File.Exists(m_testOutputFile))
            {
                throw new InvalidOperationException(classifier.Output);
            }
            using (System.IO.StreamReader sr = new System.IO.StreamReader(m_testOutputFile))
            {
                for (int i = 0; i < ret.Length; ++i)
                {
                    string s = sr.ReadLine();
                    ret[i] = Double.Parse(s);
                }
            }

            if (System.IO.File.Exists(m_testFile))
            {
                System.IO.File.Delete(m_testFile);
            }
            if (System.IO.File.Exists(m_testOutputFile))
            {
                System.IO.File.Delete(m_testOutputFile);
            }

            return ret;
        }

        public double[] classifyInstances(Instances instances)
        {
            double[] ret = new double[instances.numInstances()];
            double[] v = distributionForInstances(instances);

            for (int i = 0; i < ret.Length; ++i)
            {
                ret[i] = v[i] > m_delta ? 2 : 0;
            }
            return ret;
        }

        public override double classifyInstance(Instance instance)
        {
            if (m_mustValue.HasValue)
                return m_mustValue.Value;

            instance.setDataset(m_sampleInstances);
            instance.setClassValue(0);
            m_sampleInstances.clear();
            m_sampleInstances.add(instance);

            double[] d = classifyInstances(m_sampleInstances);
            return d[0];
        }

        public override void setOptions(string[] options)
        {
            int idx = Utils.getOptionPos('D', options);
            if (idx != -1)
            {
                m_delta = Convert.ToDouble(options[idx + 1]);
                List<string> list = new List<string>();
                for (int i = 0; i < options.Length; ++i)
                {
                    if (i != idx && i != idx + 1)
                    {
                        list.Add(options[i]);
                    }
                }
                m_trainArgs = Utils.joinOptions(list.ToArray());
            }
            else
            {
                m_trainArgs = Utils.joinOptions(options);
            }

            base.setOptions(options);
        }

        public virtual string toSource(string className)
        {
            StringBuilder result;

            result = new StringBuilder();

            result.Append("class " + className + " {\n");
            result.Append("  public static double classify(Object[] i) {\n");
            result.Append("    return " + "1" + ";\n");
            result.Append("  }\n");
            result.Append("}\n");

            return result.ToString();
        }

        public override string toString()
        {
            return "SvmLightClassifier";
        }

        public override string getRevision()
        {
            return RevisionUtils.extract("$Revision: 1 $");
        }
    }
}
