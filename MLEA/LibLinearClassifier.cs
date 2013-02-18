//using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Text;

//namespace MLEA
//{
//    public class LibLinearClassifier : weka.classifiers.functions.LibLINEAR
//    {
//        public LibLinearClassifier()
//            :base()
//        {
//        }

//        public LibLinearClassifier(int tp, int sl)
//            : base()
//        {
//        }
//        private int m_tp, m_fp;
//        public override void buildClassifier(weka.core.Instances insts)
//        {
//            weka.core.Instances trainInstances = new weka.core.Instances(insts, 0, insts.numInstances());

//            for (int i = 0; i < trainInstances.numInstances(); ++i)
//            {
//                if (trainInstances.instance(i).classValue() == 1)
//                {
//                    trainInstances.instance(i).setClassMissing();
//                }
//            }
//            trainInstances.deleteWithMissingClass();
//            if (trainInstances.numInstances() > 0)
//            {
//                base.buildClassifier(trainInstances);
//                m_error = false;

//                m_tp = 0;
//                m_fp = 0;
//                foreach (weka.core.Instance i in trainInstances)
//                {
//                    double r = base.classifyInstance(i);
//                    if (r == i.classValue())
//                    {
//                        m_tp++;
//                    }
//                    else
//                    {
//                        m_fp++;
//                    }
//                }
//            }
//            else
//            {
//                m_error = true;
//            }
//        }
//        private bool m_error;
//        public override double classifyInstance(weka.core.Instance instance)
//        {
//            if (m_error)
//                return 0;

//            return base.classifyInstance(instance);
//        }
//        public override string toString()
//        {
//            return string.Format("{0}/{1}", m_tp, m_fp);
//        }
//    }
//}
