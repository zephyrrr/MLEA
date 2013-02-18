using System.Collections;
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

    public class ProbClassifier : weka.classifiers.AbstractClassifier, weka.core.WeightedInstancesHandler
    {
        public ProbClassifier(int tp, int sl)
        {
            m_tp = tp;
            m_sl = sl;
        }
        private double m_tp, m_sl;

        private double[] m_counts;
        private double sumOfWeights = 0;

        ///            
        ///             <summary> * Generates the classifier.
        ///             * </summary>
        ///             * <param name="instances"> set of instances serving as training data  </param>
        ///             * <exception cref="Exception"> if the classifier has not been generated successfully </exception>
        ///             
        public override void buildClassifier(Instances instances)
        {
            // can classifier handle the data?
            getCapabilities().testWithFail(instances);

            // remove instances with missing class
            var trainInstances = new Instances(instances);
            trainInstances.deleteWithMissingClass();

            WekaUtils.DebugAssert(instances.numClasses() == 3, "instance's numClasses should be 3.");
            m_counts = new double[instances.numClasses()];
            for (int i = 0; i < m_counts.Length; i++)
            {
                m_counts[i] = 0;
            }

            //double c = m_tp / m_sl;
            foreach (Instance instance in instances)
            {
                int v = (int)instance.classValue();
                m_counts[v] += 1;
                sumOfWeights += 1;
            }
        }

        private double m_delta = 0;
        ///            
        ///             <summary> * Classifies a given instance.
        ///             * </summary>
        ///             * <param name="instance"> the instance to be classified </param>
        ///             * <returns> index of the predicted class </returns>
        ///             
        public override double classifyInstance(Instance instance)
        {
            //if (m_counts[1] == 0 && m_counts[2] == 0)
            //    return 0;
            //else if (m_counts[0] == 0 && m_counts[2] == 0)
            //    return 1;
            //else
            //    return 2;

            double a = m_counts[0] / sumOfWeights;
            double b = m_counts[1] / sumOfWeights;

            if (a >= b && a >= m_delta)
                return 0;
            else if (b >= a && b >= m_delta)
                return 1;
            else
                return 2;
        }


        ///            
        ///             <summary> * Returns a description of the classifier.
        ///             * </summary>
        ///             * <returns> a description of the classifier as a string. </returns>
        ///             
        public override string toString()
        {
            return m_counts[0].ToString("N1") + "/" + m_counts[1].ToString("N1") + "/" + m_counts[2].ToString("N1"); ;
        }
    }
}