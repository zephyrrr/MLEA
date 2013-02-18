using System;
using System.Collections.Generic;
using System.Text;
using Feng.Data;

namespace MLEA
{
    public static class TickDataHelper
    {
        public const string Symbol = "EURUSD";
        public const long s_dataCnt = 1000000;
        private const long s_dataCnt2 = 100000;

        private static System.Data.DataTable s_dt;
        private static long[] s_times;
        public static System.Data.DataTable GetTickData(long time, bool cache, out int idx)
        {
            idx = 0;
            bool newData = false;

            if (s_dt == null)
            {
                newData = true;
            }
            else
            {
                int ret = System.Array.BinarySearch(s_times, time);
                int r2 = 0;
                if (ret < 0)
                    r2 = ~ret;
                if (ret > s_dataCnt / 2 || (ret < 0 && (r2 > s_dataCnt / 2)))
                {
                    newData = true;
                }
                else
                {
                    idx = ret > 0 ? ret : r2;
                }
            }

            if (newData)
            {
                idx = 0;
                var dt = DbHelper.Instance.ExecuteDataTable(string.Format("SELECT TOP {0} * FROM {1}_TICK WHERE Time >= {2} ORDER BY Time", cache ? s_dataCnt : s_dataCnt2, Symbol, time));
                if (cache)
                {
                    s_dt = dt;
                    s_times = new long[s_dt.Rows.Count];
                    for (int i = 0; i < s_times.Length; ++i)
                        s_times[i] = (long)s_dt.Rows[i]["Time"];

                }
                return dt;
            }
            else
            {
                return s_dt;
            }
        }
    }

    public class TpSlSimulateStrategy //: ISimulateStrategy
    {
        public TpSlSimulateStrategy(double tp, double sl)
        {
            m_tp = tp;
            m_sl = sl;
        }
        private double m_tp, m_sl;

        public int? Do(DateTime openDate, double openPrice, out DateTime? closeDate)
        {
            closeDate = null;

            long openTime = (long)(openDate - Parameters.MtStartTime).TotalSeconds;
            openTime -= 60 * 60 * 2;    // 时差，mt+2，tick0

            int startTickIdx;
            var ticks = TickDataHelper.GetTickData(openTime, true, out startTickIdx);
            if (ticks.Rows.Count == 0)
                return null;

            DateTime tickStart = (DateTime)ticks.Rows[startTickIdx]["Date"];
            tickStart = tickStart.AddHours(2);
            if (Math.Abs((openDate - tickStart).TotalSeconds) > 60)
                return null;
            if (Math.Abs(openPrice - (float)ticks.Rows[startTickIdx]["Ask"]) > 0.0010)
                return null;

            bool? buyRet = null;
            // try buy
            double buyOpen = (float)ticks.Rows[startTickIdx]["Ask"];
            double buyTp = buyOpen + m_tp;
            double buySl = buyOpen - m_sl;
            while (true)
            {
                for (int j = startTickIdx; j < ticks.Rows.Count; ++j)
                {
                    double buyClose = (float)ticks.Rows[j]["Bid"];
                    if (buyClose >= buyTp)
                    {
                        buyRet = true;
                        closeDate = (DateTime)ticks.Rows[j]["Date"];
                        break;
                    }
                    else if (buyClose <= buySl)
                    {
                        buyRet = false;
                        closeDate = (DateTime)ticks.Rows[j]["Date"];
                        break;
                    }
                }
                if (buyRet.HasValue)
                    break;

                ticks = TickDataHelper.GetTickData((long)ticks.Rows[ticks.Rows.Count - 1]["Time"] + 1, false, out startTickIdx);
                if (ticks.Rows.Count == 0)
                {
                    break;
                }
            }

            ticks = TickDataHelper.GetTickData(openTime, true, out startTickIdx);
            bool? sellRet = null;
            // try sell
            double sellOpen = (float)ticks.Rows[startTickIdx]["Bid"];
            double sellTp = sellOpen - m_tp;
            double sellSl = sellOpen + m_sl;
            while (true)
            {
                for (int j = startTickIdx; j < ticks.Rows.Count; ++j)
                {
                    double sellClose = (float)ticks.Rows[j]["Ask"];
                    if (sellClose <= sellTp)
                    {
                        sellRet = true;
                        closeDate = (DateTime)ticks.Rows[j]["Date"];
                        break;
                    }
                    else if (sellClose >= sellSl)
                    {
                        sellRet = false;
                        closeDate = (DateTime)ticks.Rows[j]["Date"];
                        break;
                    }
                }
                if (sellRet.HasValue)
                    break;

                ticks = TickDataHelper.GetTickData((long)ticks.Rows[ticks.Rows.Count - 1]["Time"] + 1, false, out startTickIdx);
                if (ticks.Rows.Count == 0)
                {
                    break;
                }
            }

            if (buyRet.HasValue || sellRet.HasValue)
            {
                if (buyRet.Value)
                    return 1;
                else if (sellRet.Value)
                    return -1;
                else
                    return 0;
            }
            else
            {
                return null;
            }
        }
    }
}
