using System;
using System.Collections;
using System.Text;
using System.IO;

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

    public class InstancesProb : weka.classifiers.AbstractClassifier, weka.core.WeightedInstancesHandler
    {
        private int x = 0, y = 0, z = 0, w = 0;
        public double GetProb(weka.core.Instances instances)
        {
            x = 0; y = 0; z = 0;
            for (int i = 0; i < instances.numInstances(); ++i)
            {
                double v = instances.instance(i).classValue();
                if (v == 0)
                    x++;
                else if (v == 1)
                    y++;
                else if (v == 2)
                    z++;
                else if (v == 3)
                    w++;
                else
                    throw new ArgumentException("invalid v");
            }

            int n = x + y + z + w;
            double tp = (TestParameters2.tpStart + 1 + TestParameters2.tpCount) / 2.0;
            double sl = (TestParameters2.slStart + 1 + TestParameters2.slCount) / 2.0;

            double r1 = (x * tp - y * sl + w / 2 * tp - w / 2 * sl) * x
                + (y * tp - x * sl + w / 2 * tp - w / 2 * sl) * y
                - (x * sl + y * sl + w * sl) * z
                + tp * w * n;
            r1 = r1 / n / n;

            double r;
            if (x > y)
                r = x * tp - y * sl - z * sl + w * tp;
            else if (x < y)
                r = -x * sl + y * tp - z * sl + w * tp;
            else
                r = 0;
            r = r / n;

            //DateTime date = WekaUtils.GetDateTimeValueFromInstances(instances, 0, 0);
            //DateTime hpdate = WekaUtils.GetDateTimeValueFromInstances(instances, 1, 0);
            //using (StreamWriter sw = new StreamWriter("d:\\p.txt", true))
            //{
            //    sw.Write(string.Format("{2}, {3}, {4}, {5}, ",
            //        date.ToString(Parameters.DateTimeFormat), hpdate.ToString(Parameters.DateTimeFormat),
            //        x, y, z, w, r));
            //}

            return r1;
        }

        public InstancesProb(int tp, int sl)
        {
            m_tp = tp;
            m_sl = sl;

            //m_innerClassifier = new weka.classifiers.functions.LibLINEAR();
            //string option = "-S 7 -C 1 -B 1";
            //m_innerClassifier.setOptions(weka.core.Utils.splitOptions(option));

            //m_innerClassifier = new ProbClassifier(tp, sl);
        }
        private double m_tp, m_sl;

        private weka.classifiers.AbstractClassifier m_innerClassifier;

        public override void buildClassifier(Instances instances)
        {
            m_prop = GetProb(instances);
            //m_innerClassifier.buildClassifier(instances);
        }

        private double m_prop;
        private int lastR = 2;
        public override double classifyInstance(Instance instance)
        {
            int r = 2;
            if (m_prop <= 0)
            {
                r = 2;
            }
            else
            {
                if (x == y)
                {
                    if (w > z)
                        r = lastR;
                    else
                        r = 2;
                }
                else if (x > y)
                {
                    return 0;
                }
                else if (y > x)
                {
                    return 1;
                }
                else
                {
                    return 2;
                }
            }
            //lastR = r;
            return r;
            //return (new Random()).NextDouble() > 0.5 ? 1 : 0;
            //double v = m_innerClassifier.classifyInstance(instance);
            //if (v == 0)
            //    return 0;
            //else if (v == 1)
            //    return 1;
            //else
            //    return 2;
        }

        public override double[] distributionForInstance(Instance instance)
        {
            double n = x + y + z + w;
            return new double[] { (x + w / 2) / n, (y + w / 2) / n, z / n, 0 };
        }

    }
}
