using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public class FixedMoneyManagement : IMoneyManagement
    {
        public FixedMoneyManagement()
            : this(1)
        {
        }
        public FixedMoneyManagement(double volume)
        {
            m_volume = volume;
        }
        private double m_volume;
        public void Build(weka.core.Instances instances)
        {
        }

        public double GetVolume(weka.core.Instance instance)
        {
            return m_volume;
        }
        public override string ToString()
        {
            return m_volume.ToString("N0");
        }
    }
}
