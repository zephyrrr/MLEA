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

    public class GaussianAnomalyDetection : weka.classifiers.AbstractClassifier, weka.core.WeightedInstancesHandler, weka.classifiers.Sourcable
    {

        /// <summary> for serialization  </summary>
        internal const long serialVersionUID = 48055541465867956L;

        public virtual string globalInfo()
        {
            return "GaussianAnomalyDetection";
        }

        public override Capabilities getCapabilities()
        {
            Capabilities result = base.getCapabilities();
            result.disableAll();

            // attributes
            result.enable(Capabilities.Capability.NOMINAL_ATTRIBUTES);
            result.enable(Capabilities.Capability.NUMERIC_ATTRIBUTES);
            result.enable(Capabilities.Capability.DATE_ATTRIBUTES);
            result.enable(Capabilities.Capability.STRING_ATTRIBUTES);
            result.enable(Capabilities.Capability.RELATIONAL_ATTRIBUTES);
            result.enable(Capabilities.Capability.MISSING_VALUES);

            // class
            result.enable(Capabilities.Capability.NOMINAL_CLASS);
            result.enable(Capabilities.Capability.NUMERIC_CLASS);
            result.enable(Capabilities.Capability.DATE_CLASS);
            result.enable(Capabilities.Capability.MISSING_CLASS_VALUES);

            // instances
            result.setMinimumNumberInstances(0);

            return result;
        }

        private int idxAttribute = 3;
        private double mean = 0, sigma2 = 0;
        private double epsilon = 0.05;
        public override void buildClassifier(Instances instances)
        {
            // can classifier handle the data?
            getCapabilities().testWithFail(instances);

            // remove instances with missing class
            instances = new Instances(instances);
            instances.deleteWithMissingClass();

            double sum = 0;
            int cnt = 0;
            foreach (Instance instance in instances)
            {
                if (!instance.classIsMissing())
                {
                    sum += instance.value(idxAttribute);
                    cnt++;
                }
            }
            mean = sum / cnt;

            sum = 0;
            foreach (Instance instance in instances)
            {
                if (!instance.classIsMissing())
                {
                    sum += (instance.value(idxAttribute) - mean) * (instance.value(idxAttribute) - mean);
                }
            }
            sigma2 = sum / cnt;

            epsilon = SelectBestEpsilon(instances, mean, sigma2);
        }
        private double SelectBestEpsilon(Instances instances, double mean, double sigma2)
        {
            List<double> pList = new List<double>();
            foreach (Instance instance in instances)
            {
                double x = instance.value(idxAttribute);
                double p = GetP(x);
                pList.Add(p);
            }
            //pList.Sort();
            //return pList[5000];

            double bestScore = double.MinValue;
            double bestEp = double.MinValue;
            double maxP = pList.Max();
            double minP = pList.Min();
            double step = (maxP - minP) / 1000.0;
            for (double pi = minP; pi <= maxP; pi += step)
            {
                int tp = 0, fp = 0, fn = 0;
                foreach(Instance i in instances)
                {
                    int c = (int)i.classValue();
                    double x = i.value(idxAttribute);
                    int cc = GetP(x) < pi ? 1 : 0;
                    if (cc == 1)
                    {
                        if (c == 1)
                            tp++;
                        else
                            fp++;
                    }
                    else
                    {
                        if (c == 1)
                            fn++;
                    }
                }
                if (tp + fp == 0 || tp + fn == 0)
                    continue;

                double prec = (double)tp / (tp + fp);
                double rec = (double)tp / (tp + fn);
                double F1score = 2 * prec * rec / (prec + rec);
                if (F1score > bestScore)
                {
                    bestScore = F1score;
                    bestEp = pi;
                }
            }
            return bestEp;
        }

        public override double classifyInstance(Instance instance)
        {
            double x = instance.value(idxAttribute);
            double p = GetP(x);
            if (p < epsilon)
                return 1;
            else
                return 0;
        }
        private double GetP(double x)
        {
            return 1.0 / Math.Sqrt(2 * Math.PI * sigma2) * Math.Exp(-(x - mean) * (x - mean) / (2 * sigma2));
        }

        //public override double[] distributionForInstance(Instance instance)
        //{
        //    return null;
        //}
       
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

        ///            
        ///             <summary> * Returns a description of the classifier.
        ///             * </summary>
        ///             * <returns> a description of the classifier as a string. </returns>
        ///             
        public override string toString()
        {
            return "GaussianAnomalyDetection";
        }

        ///            
        ///             <summary> * Returns the revision string.
        ///             * 
        ///             * @return		the revision </summary>
        ///             
        public override string getRevision()
        {
            return RevisionUtils.extract("$Revision: 1 $");
        }

        ///            
        ///             <summary> * Main method for testing this class.
        ///             * </summary>
        ///             * <param name="argv"> the options </param>
        ///             
        static void Main(string[] argv)
        {
            runClassifier(new GaussianAnomalyDetection(), argv);
        }
    }
}