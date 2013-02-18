using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public class SimulationData : Feng.Singleton<SimulationData>, IIncrementalObject
    {
        public SimulationData()
        {
        }

        public SimulationData Init(string symbol)
        {
            m_symbol = symbol;
            if (m_times == null)
            {
                LoadRates();
            }
            return this;
        }
        private string m_symbol;

        private List<MqlRates> m_rates;
        private List<long> m_times;

        public List<MqlRates> Rates
        {
            get { return m_rates; }
        }
        public List<long> Times
        {
            get { return m_times; }
        }

        public void Clear()
        {
            m_rates = null;
            m_times = null;
        }

        private void LoadRates()
        {
            m_rates = DbData.Instance.ReadRates(string.Format("{0}_M1", m_symbol)).ToList<MqlRates>();
            //for (int i = 0; i < m_rates.Length; ++i)
            //{
            //    if (m_rates[i].high != rates2[i].high || m_rates[i].close != rates2[i].close
            //        || m_rates[i].low != rates2[i].low || m_rates[i].open != rates2[i].open
            //        || m_rates[i].time != (rates2[i].time + 60))
            //    {
            //        throw new AssertException("");
            //    }
            //}
            m_times = new List<long>();
            for (int i = 0; i < m_rates.Count; ++i)
            {
                //m_rates[i].time += 60 * 1;
                m_times.Add(m_rates[i].time);
            }
        }

        private int m_newDataStart = 0;
        public void OnNewData(long nowTime)
        {
            if (m_times == null)
            {
                LoadRates();
            }

            long lastTime = m_times.Count > 0 ? m_times[m_times.Count - 1] : 0;
            //m_newDataStart = m_times.Count > 0 ? m_times.Count - 1 : 0;
            //WekaUtils.Instance.WriteLog(string.Format("Now m_newDataStart = {0}", m_newDataStart));

            var newRates = DbData.Instance.ReadRates(string.Format("{0}_M1", m_symbol), string.Format(" WHERE TIME >= {0} ", lastTime));
            
            foreach (var i in newRates)
            {
                if (i.time > lastTime)
                {
                    m_rates.Add(i);
                    m_times.Add(i.time);
                }
            }
        }

        public int NewDataStart
        {
            get { return m_newDataStart; }
        }
    }

    public class TpSlM1SimulateStrategy : ISimulateStrategy
    {
        private int m_useSpread = -1;
        private SimulationData m_simulationData;

        public TpSlM1SimulateStrategy(string symbol, double tp, double sl, SimulationData simulationData)
        {
            m_simulationData = simulationData;

            m_symbol = symbol;
            if (WekaUtils.GetSymbolPoint(symbol) == 1)
            {
                point = 0.001;
            }
            else
            {
                point = 0.00001;
            }
            eps = point * 0.01;

            m_tp = tp * point;
            m_sl = sl * point;
        }
        private double m_tp, m_sl;
        private string m_symbol;


        private int? GetIdx(DateTime openDate, double openPrice)
        {
            long openTime = (long)(openDate - Parameters.MtStartTime).TotalSeconds;

            int idx = m_simulationData.Times.BinarySearch(openTime);// Array.BinarySearch(m_times, openTime);
            if (idx < 0)
                idx = ~idx;
            if (idx < 0 || idx >= m_simulationData.Rates.Count)
                return null;

            if (idx > 0 && Math.Abs(m_simulationData.Rates[idx - 1].time - openTime) < Math.Abs(m_simulationData.Rates[idx].time - openTime))
                idx -= 1;

            if (openTime != m_simulationData.Rates[idx].time || (openPrice != -1 && openPrice != m_simulationData.Rates[idx].close))
            {
                if (Math.Abs(openTime - m_simulationData.Rates[idx].time) > 60 * 5)
                    return null;

                if (openPrice != -1)
                {
                    if (Math.Abs(openPrice - m_simulationData.Rates[idx].close) >= 50 * point)
                        return null;
                }
            }
            return idx;
        }
        private double point;
        private double eps;
        public bool? DoBuy(DateTime openDate, double openPrice, out DateTime? closeDate)
        {
            closeDate = null;

            int? idx2 = GetIdx(openDate, openPrice);
            if (idx2 == null)
                return null;
            int idx = idx2.Value;

            bool? buyRet = null;
            // try buy
            double buyOpen = m_simulationData.Rates[idx].close;
            if (m_useSpread < 0)
                buyOpen += m_simulationData.Rates[idx].spread * point;  //ask
            else
                buyOpen += m_useSpread * point;

            double buyTp = buyOpen + m_tp;
            double buySl = buyOpen - m_sl;

            if (m_simulationData.NewDataStart != 0)
            {
                idx = Math.Max(m_simulationData.NewDataStart, idx);
            }
            for (int j = idx; j < m_simulationData.Rates.Count; ++j)
            {
                if (m_simulationData.Rates[j].low <= buySl + eps)    // bid
                {
                    buyRet = false;
                    closeDate = Parameters.MtStartTime.AddSeconds(m_simulationData.Rates[j].time);
                    break;
                }
                else if (m_simulationData.Rates[j].high >= buyTp - eps)
                {
                    buyRet = true;
                    closeDate = Parameters.MtStartTime.AddSeconds(m_simulationData.Rates[j].time);
                    break;
                }
            }

            if (buyRet.HasValue)
            {
                return buyRet.Value;
            }
            else
            {
                return null;
            }
        }

        public bool? DoSell(DateTime openDate, double openPrice, out DateTime? closeDate)
        {
            closeDate = null;

            int? idx2 = GetIdx(openDate, openPrice);
            if (idx2 == null)
                return null;
            int idx = idx2.Value;

            bool? sellRet = null;
            // try sell
            double sellOpen = m_simulationData.Rates[idx].close;   // bid
            double sellTp = sellOpen - m_tp;
            double sellSl = sellOpen + m_sl;

            if (m_simulationData.NewDataStart != 0)
            {
                idx = Math.Max(m_simulationData.NewDataStart, idx);
            }
            for (int j = idx; j < m_simulationData.Rates.Count; ++j)
            {
                double spread = 0;
                if (m_useSpread < 0)
                    spread = m_simulationData.Rates[j].spread * point;
                else
                    spread = m_useSpread * point;

                if (m_simulationData.Rates[j].high + spread >= sellSl - eps)      // ask
                {
                    sellRet = false;
                    closeDate = Parameters.MtStartTime.AddSeconds(m_simulationData.Rates[j].time);
                    break;
                }
                else if (m_simulationData.Rates[j].low + spread <= sellTp + eps)
                {
                    sellRet = true;
                    closeDate = Parameters.MtStartTime.AddSeconds(m_simulationData.Rates[j].time);
                    break;
                }
            }

            if (sellRet.HasValue)
            {
                return sellRet.Value;
            }
            else
            {
                return null;
            }
        }
    }
}
