using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public class BreakEvenM1SimulateStrategy// : ISimulateStrategy
    {
        public BreakEvenM1SimulateStrategy(string symbol, double tp, double sl, double be)
        {
            m_tp = tp;
            m_sl = sl;
            m_be = be;  // break Even

            m_rates = DbData.Instance.ReadRates("EURUSD_M1");

            m_times = new long[m_rates.Length];
            for (int i = 0; i < m_rates.Length; ++i)
            {
                m_times[i] = m_rates[i].time;
            }
        }
        private double m_tp, m_sl, m_be;
        private MqlRates[] m_rates;
        private long[] m_times;
        public int? Do(DateTime openDate, double openPrice, out DateTime? closeDate)
        {
            closeDate = null;

            long openTime = (long)(openDate - Parameters.MtStartTime).TotalSeconds;

            int idx = Array.BinarySearch(m_times, openTime);
            if (idx < 0)
                idx = ~idx;
            if (idx < 0 || idx >= m_rates.Length)
                return null;

            if (Math.Abs(openTime - m_rates[idx].time) > 60 * 5)
                return null;

            if (Math.Abs(openPrice - m_rates[idx].close) >= 0.0005)
                return null;

            bool? buyRet = null;
            // try buy
            double buyOpen = m_rates[idx].close;
            double buyTp = buyOpen + m_tp;
            double buySl = buyOpen - m_sl;
            double buyBe = buyOpen + m_be;
            bool buyInBe = false;
            for (int j = idx; j < m_rates.Length; ++j)
            {
                if (m_rates[j].low <= buySl)
                {
                    buyRet = false;
                    closeDate = Parameters.MtStartTime.AddSeconds(m_rates[j].time);
                    break;
                }
                else if (m_rates[j].high >= buyTp)
                {
                    buyRet = true;
                    closeDate = Parameters.MtStartTime.AddSeconds(m_rates[j].time);
                    break;
                }
                else if (m_rates[j].high >= buyBe)
                {
                    buyInBe = true;
                    buySl = buyOpen;
                }
            }

            bool? sellRet = null;
            // try sell
            double sellOpen = m_rates[idx].close;
            double sellTp = sellOpen - m_tp;
            double sellSl = sellOpen + m_sl;
            double sellBe = sellOpen - m_be;
            bool sellInBe = false;
            for (int j = idx; j < m_rates.Length; ++j)
            {
                if (m_rates[j].high >= sellSl)
                {
                    sellRet = false;
                    closeDate = Parameters.MtStartTime.AddSeconds(m_rates[j].time);
                    break;
                }
                else if (m_rates[j].low <= sellTp)
                {
                    sellRet = true;
                    closeDate = Parameters.MtStartTime.AddSeconds(m_rates[j].time);
                    break;
                }
                else if (m_rates[j].low <= sellBe)
                {
                    sellInBe = true;
                    sellSl = sellOpen;
                }
            }

            if (buyRet.HasValue || sellRet.HasValue)
            {
                if (buyRet.Value)
                    return 1;
                else if (sellRet.Value)
                    return -1;
                else if (buyInBe || sellInBe)
                    return 2;
                else
                    return 0;
            }
            else
            {
                return 0;
            }
        }
    }
}
