using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public class MyLibLinear : weka.classifiers.functions.LibLINEAR
    {
        public MyLibLinear()
            : base()
        {
        }

        public MyLibLinear(int tp, int sl)
            : base()
        {
        }

        public override double classifyInstance(weka.core.Instance instance)
        {
            var d = base.classifyInstance(instance);
            if (d == 3)
                return 2;
            return d;
        }
    }
}
