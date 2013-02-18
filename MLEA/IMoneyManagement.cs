using System;
using System.Collections.Generic;
using System.Text;
using weka.core;

namespace MLEA
{
    public interface IMoneyManagement
    {
        void Build(Instances instances);
        double GetVolume(Instance instance);
    }
}
