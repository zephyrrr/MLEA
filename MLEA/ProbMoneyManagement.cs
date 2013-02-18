using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public class ProbMoneyManagement : IMoneyManagement
    {
        public ProbMoneyManagement(int tp, int sl)
        {
            m_tp = tp;
            m_sl = sl;
        }

        private double[] m_counts = new double[3];
        private double m_tp, m_sl;
        public void Build(weka.core.Instances instances)
        {
            WekaUtils.DebugAssert(instances.numClasses() == 3, "instance's numClasses should be 3.");
            for (int i = 0; i < m_counts.Length; i++)
            {
                m_counts[i] = 0;
            }

            double c = m_tp / m_sl;
            foreach (weka.core.Instance instance in instances)
            {
                int v = (int)instance.classValue();
                if (v == 2)
                {
                    m_counts[2] += c;
                }
                else if (v == 0)
                {
                    m_counts[0]++;
                }
                else
                {
                    m_counts[1]++;
                }
            }
        }

        public double GetVolume(weka.core.Instance instance)
        {
            //double v = m_counts[2] * m_tp - m_counts[0] * m_sl + (m_tp - 1.5 * m_sl) * m_counts[1] / 5;
            //if (v < 0)
            //    return 0;
            //v /= 1000;
            double sum = (m_counts[0] + m_counts[1] + m_counts[2]);
            if (sum == 0)
                return 0;
            double v = m_counts[2] / sum;
            return Math.Round(v, 2);
        }
        public override string ToString()
        {
            return GetVolume(null).ToString("N2") + "/" + m_counts[2].ToString("N1") + "/" + m_counts[0].ToString("N1") + "/" + m_counts[1].ToString("N1");
        }
    }
}
