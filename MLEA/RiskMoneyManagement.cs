using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public class RiskMoneyManagement : IMoneyManagement
    {
        public RiskMoneyManagement(int tp, int sl)
        {
            m_tp = tp;
            m_sl = sl;
        }
        private double m_tp, m_sl;
        public void Build(weka.core.Instances instances)
        {
        }

        public double GetVolume(weka.core.Instance instance)
        {
            double v = 100.0 / m_sl;
            return Math.Round(v, 2);
        }
        public override string ToString()
        {
            return GetVolume(null).ToString("N2");
        }
    }

    public class RiskMoneyManagement2 : IMoneyManagement
    {
        public RiskMoneyManagement2(int tp, int sl)
        {
            m_tp = tp;
            m_sl = sl;
        }
        private double m_tp, m_sl;
        public void Build(weka.core.Instances instances)
        {
        }

        public double GetVolume(weka.core.Instance instance)
        {
            double v = 100.0 / m_tp;
            return Math.Round(v, 2);
        }
        public override string ToString()
        {
            return GetVolume(null).ToString("N2");
        }
    }
}
