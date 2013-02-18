using System;
using System.Collections.Generic;
using System.Text;

namespace MLEA
{
    public class AllTrueClassifier : weka.classifiers.AbstractClassifier, weka.core.WeightedInstancesHandler
    {
        public override void buildClassifier(weka.core.Instances value)
        {
        }
        public override double classifyInstance(weka.core.Instance instance)
        {
            return 2;
        }
        public override string toString()
        {
            return "1";
        }
    }
}
