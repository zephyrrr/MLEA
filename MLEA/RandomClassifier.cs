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
      
    public class RandomClassifier : weka.classifiers.AbstractClassifier, weka.core.WeightedInstancesHandler, weka.classifiers.Sourcable
    {
        public RandomClassifier(int tp, int sl)
        {
            m_tp = tp;
            m_sl = sl;
        }
        private double m_tp, m_sl;

        /// <summary> for serialization  </summary>
        internal const long serialVersionUID = 48055541465867955L;

        private double[] m_counts;
        private double[] m_normalCounts;

        ///            
        ///             <summary> * Returns a string describing classifier </summary>
        ///             * <returns> a description suitable for
        ///             * displaying in the explorer/experimenter gui </returns>
        ///             
        public virtual string globalInfo()
        {
            return "RandomClassifier";
        }

        ///            
        ///             <summary> * Returns default capabilities of the classifier.
        ///             * </summary>
        ///             * <returns>      the capabilities of this classifier </returns>
        ///             
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

            // instances
            result.setMinimumNumberInstances(0);

            return result;
        }

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
            instances = new Instances(instances);
            instances.deleteWithMissingClass();

            double sumOfWeights = 0;

            WekaUtils.DebugAssert(instances.numClasses() == 3, "instance's numClasses should be 3.");
            m_counts = new double[instances.numClasses()];
            m_normalCounts = new double[instances.numClasses()];
            for (int i = 0; i < m_counts.Length; i++)
            {
                m_counts[i] = 0;
                m_normalCounts[i] = 0;
            }
            
            double c = m_tp / m_sl;
            foreach (Instance instance in instances)
            {
                int v = (int)instance.classValue();
                if (v == 2)
                {
                    m_counts[v] += instance.weight() * c;
                    sumOfWeights += instance.weight() * c;
                }
                else
                {
                    m_counts[v] += instance.weight();
                    sumOfWeights += instance.weight();
                }
            }

            double start = 0;
            for (int i = 0; i < m_counts.Length; ++i)
            {
                m_normalCounts[i] = (double)m_counts[i] / sumOfWeights + start;
                start = m_normalCounts[i];
            }
        }

        System.Random randomGenerator;
        ///            
        ///             <summary> * Classifies a given instance.
        ///             * </summary>
        ///             * <param name="instance"> the instance to be classified </param>
        ///             * <returns> index of the predicted class </returns>
        ///             
        public override double classifyInstance(Instance instance)
        {
            if (randomGenerator == null)
            {
                randomGenerator = new System.Random((int)System.DateTime.Now.Ticks);
            }
            var rand = randomGenerator.NextDouble();

            for (int i = 0; i < m_normalCounts.Length; ++i)
            {
                if (rand < m_normalCounts[i])
                    return i == 1 ? 0 : i;
            }
            return 0;
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

        ///            
        ///             <summary> * Returns a description of the classifier.
        ///             * </summary>
        ///             * <returns> a description of the classifier as a string. </returns>
        ///             
        public override string toString()
        {
            return m_counts[2].ToString("N1") + "/" + (m_counts[0] + m_counts[1] + m_counts[2]).ToString("N1");
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
            runClassifier(new RandomClassifier(20, 20), argv);
        }
    }
}