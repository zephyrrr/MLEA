using System;
using System.Collections.Generic;
using System.Text;
using weka.core;

namespace MLEA
{
    // http://en.wikipedia.org/wiki/Kelly_criterion
    public class KellyMoneyManagement : IMoneyManagement
    {
        public KellyMoneyManagement(int tp, int sl)
        {
            m_tp = tp;
            m_sl = sl;
        }
        private int[] m_counts;
        private double m_tp;
        private double m_sl;
        public void Build(weka.core.Instances instances)
        {
            WekaUtils.DebugAssert(instances.numClasses() == 3, "instance's numClasses should be 3.");
            m_counts = new int[instances.numClasses()];

            for (int i = 0; i < m_counts.Length; i++)
            {
                m_counts[i] = 0;
            }

            foreach (Instance instance in instances)
            {
                int v = (int)instance.classValue();
                m_counts[v]++;
            }
        }

        public double GetVolume(weka.core.Instance instance)
        {
            double sum = m_counts[0] + m_counts[1] + m_counts[2];
            if (sum == 0)
                return 0;

            double kelly_b = -m_tp / m_sl;
            double kelly_p = (double)m_counts[2] / sum;
            double kelly_f = (kelly_p * (kelly_b + 1) - 1) / kelly_b;
            // f=0.2, sl=20 =>0.01
            double v = 2 * (kelly_f / 0.2) / (m_sl / 10);
            if (v <= 0)
                return 0;
            return v;
        }

        public override string ToString()
        {
            return ((int)m_tp).ToString() + "/" + ((int)m_sl).ToString() + "/" + m_counts[2].ToString("N1") + "/" + (m_counts[1] + m_counts[2] + m_counts[0]).ToString("N1");
        }
    }
}
