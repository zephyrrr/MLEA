using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

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

    [Serializable]
    public class MincostLiblinearClassifier : weka.classifiers.SingleClassifierEnhancer, weka.core.WeightedInstancesHandler, weka.classifiers.Sourcable
    {
        public MincostLiblinearClassifier(int tp, int sl)
        {
            m_tp = tp;
            m_sl = sl;
        }
        private double m_tp, m_sl;

        public MincostLiblinearClassifier()
        {
            var linear = new weka.classifiers.functions.LibLINEAR();
            linear.setOptions(Utils.splitOptions("-S 0 -P -C 1 -B 1"));
            base.m_Classifier = linear;
        }

        protected override string defaultClassifierString()
        {
            return "weka.classifiers.functions.LibLINEAR";
        }

        public virtual string globalInfo()
        {
            return "MincostLiblinearClassifier";
        }

        protected MincostLiblinearClassifier(System.Runtime.Serialization.SerializationInfo info, System.Runtime.Serialization.StreamingContext context1)
            : base(info, context1)
        {
            m_delta = info.GetDouble("delta");
            m_mustValue = info.GetInt32("mustValue");

            string modelFileName = info.GetString("BaseCls");
            base.m_Classifier = (Classifier)weka.core.SerializationHelper.read(modelFileName);
        }

        protected override void GetObjectData(System.Runtime.Serialization.SerializationInfo info, System.Runtime.Serialization.StreamingContext context)
        {
            base.GetObjectData(info, context);

            info.AddValue("delta", m_delta);
            info.AddValue("mustValue", m_mustValue);

            string modelFileName = System.IO.Path.GetRandomFileName();
            modelFileName = string.Format("{0}\\{1}", TestParameters.BaseDir + "\\ExcludeModel", modelFileName);
            info.AddValue("BaseCls", modelFileName);
            weka.core.SerializationHelper.write(modelFileName, base.m_Classifier);
        }

        internal const long serialVersionUID = 48055541465967957L;
        //private int m_version = 1;
        //private void writeObject(java.io.ObjectOutputStream oos)
        //{
        //    oos.writeInt(m_version);
        //    oos.writeDouble(m_delta.Value);
        //}
        //private void readObject(java.io.ObjectInputStream ois)
        //{
        //    try
        //    {
        //        int version = ois.readInt();
        //        if (version == 1)
        //        {
        //            m_delta = ois.readDouble();
        //        }
        //    }
        //    catch (Exception)
        //    {
        //        throw;
        //    }
        //}

        public override Capabilities getCapabilities()
        {
            Capabilities result = base.getCapabilities();
            return result;
        }

        private weka.classifiers.Classifier TrainOnce(Instances trainInstances, double delta)
        {
            var cls = weka.classifiers.AbstractClassifier.makeCopy(m_Classifier);
            bool changed = false;

            for (int i = 0; i < trainInstances.numInstances(); ++i)
            {
                if (trainInstances.instance(i).classValue() == 1)
                {
                    trainInstances.instance(i).setClassMissing();
                }
            }
            for (int i = 0; i < trainInstances.numInstances(); ++i)
            {
                if (trainInstances.instance(i).classValue() == 2)
                {
                    trainInstances.instance(i).setClassValue(1);
                }
            }

            while (true)
            {
                changed = false;

                double[] w = GetCount(trainInstances);
                //string ws = string.Empty;
                //if (w != null)
                //{
                //    ws = w[1].ToString(Parameters.DoubleFormatString) + " " + w[0].ToString(Parameters.DoubleFormatString);
                //}
                double cost = m_tp / m_sl;
                string ws;
                if (w[1] == 0 || w[0] == 0)
                {
                    ws = string.Empty;
                }
                else
                {
                    ws = cost.ToString("N2") + " 1";
                }
                
                var linear = cls as weka.classifiers.functions.LibLINEAR;
                if (linear != null)
                {
                    linear.setWeights(ws);
                }
                else
                {
                    var svm = cls as weka.classifiers.functions.LibSVM;
                    if (svm != null)
                    {
                        svm.setWeights(ws);
                    }
                }

                cls.buildClassifier(trainInstances);

                foreach (Instance i in trainInstances)
                {
                    if (i.classValue() == 0)
                        continue;

                    double v = cls.classifyInstance(i);
                    if (v == 0 || cls.distributionForInstance(i)[1] < delta)
                    {
                        i.setClassValue(0);
                        changed = true;
                    }
                    if (v == 1)
                    {
                    }
                }
                if (!changed)
                    break;
            }
            return cls;
        }

        private int m_mustValue = -1;
        public override void buildClassifier(Instances instances)
        {
            m_mustValue = -1;
            var weights = GetCount(instances);
            if (weights[0] == 0)
            {
                m_mustValue = 2;
                return;
            }
            else if (weights[2] == 0)
            {
                m_mustValue = 0;
                return;
            }

            // can classifier handle the data?
            getCapabilities().testWithFail(instances);

            //instances.deleteWithMissingClass();
            Instances trainInstances = null;

            if (m_delta == -1)
            {
            //    double delta = 0.5;
            //    double maxDelta = 1;
            //    double minDelta = 0.5;
            //    for (int it = 0; it < 10; ++it)
            //    {
            //        delta = (minDelta + maxDelta) / 2.0;

            //        trainInstances = new Instances(instances, 0, instances.numInstances());

            //        var cls = TrainOnce(trainInstances, delta);

            //        double a = 0, b = 0;
            //        foreach (Instance i in trainInstances)
            //        {
            //            var v = cls.classifyInstance(i);
            //            if (v == 0)
            //                continue;

            //            if (i.classValue() == 0)
            //                a++;
            //            else if (i.classValue() == 2)
            //                b++;
            //        }

            //        if (b == 0)
            //        {
            //            maxDelta = delta;
            //        }
            //        else
            //        {
            //            minDelta = delta;
            //        }
            //    }
            //    delta = Math.Max(0.5, delta - 0.02);

            //    double bestDelta = delta;
            //    double bestCost = double.MaxValue;
            //    weka.classifiers.Classifier bestCls = null;
            //    for (int it = 0; it < 20; ++it)
            //    {
            //        trainInstances = new Instances(instances, 0, instances.numInstances());

            //        var cls = TrainOnce(trainInstances, delta);

            //        MyEvaluation eval = new MyEvaluation(TestParameter.CostMatrix);
            //        m_Classifier = cls;
            //        m_delta = delta;
            //        eval.evaluateModel(this, instances);

            //        if (eval.totalCost() < bestCost)
            //        {
            //            bestDelta = delta;
            //            bestCost = eval.totalCost();
            //            bestCls = cls;
            //        }

            //        delta += 0.002;
            //    }
            //    this.m_Classifier = bestCls;
            //    this.m_delta = bestDelta;
                trainInstances = new Instances(instances, 0, instances.numInstances());
                var cls = TrainOnce(trainInstances, 0.5);
                this.m_Classifier = cls;
                GetBestDelta(instances);
            }
            else
            {
                trainInstances = new Instances(instances, 0, instances.numInstances());
                var cls = TrainOnce(trainInstances, m_delta);
                this.m_Classifier = cls;
            }
        }

        private void GetBestDelta(Instances instances)
        {
            if (m_delta != -1)
                return;

            double[] v = distributionForInstances(instances);

            double bestDelta = 0;
            double bestScore = double.MinValue;
            int bestNum = 0;

            for (int i = 0; i < 20; ++i)
            {
                double delta = i / 20.0;
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
                        throw new NotSupportedException("invalid class value of " + instances.instance(j).classValue());
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
        public static double[] GetCount(Instances instances)
        {
            double a = 0, b = 0, c = 0;
            foreach (Instance i in instances)
            {
                if (i.classValue() == 2)
                    c++;
                else if (i.classValue() == 0)
                    a++;
                else
                    b++;
            }
            //if (a == 0 || b == 0)
            //    return null;

            //double c = a + b;
            //a = a / c;
            //b = b / c;
            //if (a > b)
            //{
            //    a = a / b;
            //    b = 1;
            //}
            //else
            //{
            //    b = b / a;
            //    a = 1;
            //}
            return new double[] { a, b, c };
        }

        public double[] distributionForInstances(Instances instances)
        {
            double[] v = new double[instances.numInstances()];
            for(int i=0; i<v.Length; ++i)
                v[i] = m_Classifier.distributionForInstance(instances.instance(i))[1];
            return v;
        }

        private double m_delta = -1;
        public override double classifyInstance(Instance instance)
        {
            if (m_mustValue != -1)
                return m_mustValue;

            double delta = m_delta;
            if (delta == -1)
            {
                delta = 0.5;
            }
            return m_Classifier.distributionForInstance(instance)[1] < m_delta ? 0 : 2;
        }

        public override void setOptions(string[] options)
        {
            string str = Utils.getOption('D', options);
            if (!string.IsNullOrEmpty(str))
            {
                m_delta = Convert.ToDouble(str);
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
            return "MincostLiblinearClassifier";
        }

        public override string getRevision()
        {
            return RevisionUtils.extract("$Revision: 1 $");
        }
    }
}