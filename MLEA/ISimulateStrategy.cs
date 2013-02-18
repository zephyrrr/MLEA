using System;
using System.Collections.Generic;
using System.Text;
using Feng.Data;

namespace MLEA
{
    public interface ISimulateStrategy
    {
        bool? DoBuy(DateTime openDate, double openPrice, out DateTime? closeDate);
        bool? DoSell(DateTime openDate, double openPrice, out DateTime? closeDate);
    }

    public interface IIncrementalObject
    {
        void OnNewData(long time);
    }
}
