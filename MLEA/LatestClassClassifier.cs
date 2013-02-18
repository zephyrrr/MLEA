using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public class LatestClassClassifier : weka.classifiers.AbstractClassifier
    {
        public LatestClassClassifier()
            : base()
        {
        }

        public LatestClassClassifier(int tp, int sl)
            : base()
        {
        }

        private double m_latestClass;
        public override void buildClassifier(weka.core.Instances insts)
        {
            m_latestClass = insts.instance(0).classValue();
        }

        public override double classifyInstance(weka.core.Instance instance)
        {
            return m_latestClass;
        }
    }
}