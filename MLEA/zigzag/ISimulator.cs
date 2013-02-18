using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace MLEA
{
    public interface ISimulator
    {
        //void Init(AbstractEA ea);
        bool? Simulate(DateTime openTime, double openPrice, bool isBuy, int tp, int sl, out DateTime closeTime, out double closePrice);
        void OnLoad();
        void OnUnload();
    }

    public class RateSimulator : ISimulator
    {
        public RateSimulator(AbstractEA ea)
        {
            Init(ea);
        }

        private AbstractEA m_ea;
        private void Init(AbstractEA ea)
        {
            m_ea = ea;
        }

        // buy + spread
        // sell price+spread
        public bool? Simulate(DateTime openTime, double openPrice, bool isBuy, int tp, int sl, out DateTime closeTime, out double closePrice)
        {
            closeTime = DateTime.MinValue;
            closePrice = double.MinValue;

            int idx = GetRateIndex(openTime);
            if (idx < 0)
                return null;

            if (this.Rates[idx].low > openPrice || this.Rates[idx].high < openPrice)
            {
                throw new ArgumentException("invalid openprice!");
            }

            // openPrice = this.Rates[idx].open;

            //double openPrice;
            double tpPrice, slPrice;

            if (isBuy)
            {
                //openPrice = this.Rates[idx].open + this.Spread * this.Points;
                tpPrice = openPrice + m_ea.Spread * m_ea.Points + tp * m_ea.Points;
                slPrice = openPrice + m_ea.Spread * m_ea.Points - sl * m_ea.Points;
            }
            else
            {
                //openPrice = this.Rates[idx].open;
                tpPrice = openPrice - tp * m_ea.Points;
                slPrice = openPrice + sl * m_ea.Points;
            }


            //this.Spread = this.Rates[idx].spread / 10;

            for (int i = idx + 1; i < this.Rates.Count; ++i)
            {
                if (isBuy)
                {
                    if (this.Rates[i].high > tpPrice || Math.Abs(this.Rates[i].high - tpPrice) < Parameters.DoubleEqualDelta)
                    {
                        closeTime = this.Rates[i].time;
                        closePrice = this.Rates[i].close;
                        return true;
                    }
                    if (this.Rates[i].low < slPrice || Math.Abs(this.Rates[i].low - slPrice) < Parameters.DoubleEqualDelta)
                    {
                        closeTime = this.Rates[i].time;
                        closePrice = this.Rates[i].close;
                        return false;
                    }
                }
                else
                {
                    if (this.Rates[i].low + m_ea.Spread * m_ea.Points < tpPrice || Math.Abs(this.Rates[i].low + m_ea.Spread * m_ea.Points - tpPrice) < Parameters.DoubleEqualDelta)
                    {
                        closeTime = this.Rates[i].time;
                        closePrice = this.Rates[i].close;
                        return true;
                    }
                    if (this.Rates[i].high + m_ea.Spread * m_ea.Points > slPrice || Math.Abs(this.Rates[i].high + m_ea.Spread * m_ea.Points - slPrice) < Parameters.DoubleEqualDelta)
                    {
                        closeTime = this.Rates[i].time;
                        closePrice = this.Rates[i].close;
                        return false;
                    }
                }
            }

            return null;
        }

        public class ZigzagRateTimeComparer : Comparer<ZigzagRate>
        {
            // Compares by Length, Height, and Width.
            public override int Compare(ZigzagRate x, ZigzagRate y)
            {
                return x.time.CompareTo(y.time);
            }
        }

        private int GetRateIndex(DateTime openTime)
        {
            return this.Rates.BinarySearch(new ZigzagRate { time = openTime }, new ZigzagRateTimeComparer());
        }

        public virtual void OnLoad()
        {
            m_rates = ReadRates(RateDataFilePath);

            //for (int i = 0; i < m_rates.Count; ++i)
            //{
            //    if (m_rates[i].zigzag != 0)
            //    {
            //        m_zigzagValues.Add(m_rates[i].zigzag);
            //        m_zigzagToRatePos.Add(i);
            //    }
            //}
        }


        public virtual void OnUnload()
        {
            //m_zigzagValues.Clear();
            //m_zigzagToRatePos.Clear();
            m_rates.Clear();
        }

        private string m_rateDataFileName;

        private string RateDataFilePath
        {
            get
            {
                string t = m_ea.Period;
                m_ea.Period = "M1";
                if (string.IsNullOrEmpty(m_rateDataFileName))
                {
                    m_rateDataFileName = m_ea.GetDataPath(string.Format("Z.dat"));
                }
                m_ea.Period = t;
                return m_rateDataFileName;
            }
        }

        private List<ZigzagRate> m_rates;
        public List<ZigzagRate> Rates
        {
            get { return m_rates; }
        }

        private static object m_lockObject = new object();

        public List<ZigzagRate> ReadRates(string fileName)
        {
            lock (m_lockObject)
            {
                List<ZigzagRate> rates = new List<ZigzagRate>();
                using (System.IO.BinaryReader br = new BinaryReader(new FileStream(fileName, FileMode.Open)))
                {
                    while (true)
                    {
                        try
                        {
                            long datetime = br.ReadInt64();
                            double open = br.ReadDouble();
                            double high = br.ReadDouble();
                            double low = br.ReadDouble();
                            double close = br.ReadDouble();
                            long tick_volume = br.ReadInt64();
                            int spread = br.ReadInt32();
                            long real_volume = br.ReadInt64();

                            double zigzag = br.ReadDouble();

                            if (Parameters.MtStartTime.AddSeconds(datetime) <= (m_ea.IsTraining ? Parameters.TrainStartTime : Parameters.TestStartTime))
                                continue;
                            if (Parameters.MtStartTime.AddSeconds(datetime) >= (m_ea.IsTraining ? Parameters.TrainEndTime : Parameters.TestEndTime))
                                break;

                            rates.Add(new ZigzagRate
                            {
                                time = Parameters.MtStartTime.AddSeconds(datetime),
                                open = open,
                                high = high,
                                low = low,
                                close = close,
                                tick_volume = tick_volume,
                                spread = spread,
                                real_volume = real_volume,
                                zigzag = zigzag
                            });
                        }
                        catch (System.IO.EndOfStreamException)
                        {
                            break;
                        }
                    }
                }

                return rates;
            }
        }
    }

    public class TickSimulator : ISimulator
    {
        public TickSimulator(AbstractEA ea)
        {
            Init(ea);
        }

        public virtual void OnLoad()
        {
            ReadTicks(TickDataFilePath);
        }

        public virtual void OnUnload()
        {
        }

        private AbstractEA m_ea;
        private void Init(AbstractEA ea)
        {
            m_ea = ea;
        }

        // buy + spread
        // sell price+spread
        public bool? Simulate(DateTime openTime, double openPrice, bool isBuy, int tp, int sl, out DateTime closeTime, out double closePrice)
        {
            closeTime = DateTime.MaxValue;
            closePrice = -1;
            int idx = GetTickIndex(openTime, openPrice);
            if (idx < 0)
            {
                idx = ~idx;
                //throw new ArgumentException("invalid openprice!");
            }
            if (idx >= this.Ticks.Length)
                return null;

            for (int i = 0; i < 10; ++i)
            {
                if (idx + i < this.Ticks.Length && openPrice == this.Ticks[idx + i].bid)
                {
                    idx = idx + i;
                    break;
                }
                if (idx - i >= 0 && openPrice == this.Ticks[idx - i].bid)
                {
                    idx = idx - i;
                    break;
                }
            }

            //double openPrice;
            double tpPrice, slPrice;

            if (isBuy)
            {
                openPrice = this.Ticks[idx].ask;
                tpPrice = openPrice + tp * m_ea.Points;
                slPrice = openPrice - sl * m_ea.Points;
            }
            else
            {
                openPrice = this.Ticks[idx].bid;
                tpPrice = openPrice - tp * m_ea.Points;
                slPrice = openPrice + sl * m_ea.Points;
            }

            for (int i = idx + 1; i < this.Ticks.Length; ++i)
            {
                if (isBuy)
                {
                    if (this.Ticks[i].bid > tpPrice || Math.Abs(this.Ticks[i].bid - tpPrice) < Parameters.DoubleEqualDelta)
                    {
                        closeTime = Parameters.MtStartTime.AddSeconds(this.Ticks[i].time);
                        closePrice = this.Ticks[i].bid;
                        return true;
                    }
                    if (this.Ticks[i].bid < slPrice || Math.Abs(this.Ticks[i].bid - slPrice) < Parameters.DoubleEqualDelta)
                    {
                        closeTime = Parameters.MtStartTime.AddSeconds(this.Ticks[i].time);
                        closePrice = this.Ticks[i].bid;
                        return false;
                    }
                }
                else
                {
                    if (this.Ticks[i].ask < tpPrice || Math.Abs(this.Ticks[i].ask - tpPrice) < Parameters.DoubleEqualDelta)
                    {
                        closeTime = Parameters.MtStartTime.AddSeconds(this.Ticks[i].time);
                        closePrice = this.Ticks[i].ask;
                        return true;
                    }
                    if (this.Ticks[i].ask > slPrice || Math.Abs(this.Ticks[i].ask - slPrice) < Parameters.DoubleEqualDelta)
                    {
                        closeTime = Parameters.MtStartTime.AddSeconds(this.Ticks[i].time);
                        closePrice = this.Ticks[i].ask;
                        return false;
                    }
                }
            }

            closeTime = DateTime.MinValue;
            return null;
        }

        private string m_tickDataFileName;

        private string TickDataFilePath
        {
            get
            {
                if (string.IsNullOrEmpty(m_tickDataFileName))
                {
                    m_tickDataFileName = m_ea.GetDataPath(string.Format("Tick.dat"));
                }
                return m_tickDataFileName;
            }
        }

        private MqlTick[] m_ticks;
        public MqlTick[] Ticks
        {
            get { return m_ticks; }
        }

        private class TickTimeComparer : Comparer<MqlTick>
        {
            public override int Compare(MqlTick x, MqlTick y)
            {
                return x.time.CompareTo(y.time);
            }
        }
        private int GetTickIndex(DateTime openTime, double openPrice)
        {
            return Array.BinarySearch<MqlTick>(this.Ticks, new MqlTick { time = (long)(openTime - Parameters.MtStartTime).TotalSeconds, bid = openPrice }, 
                new TickTimeComparer());
        }


        private static object m_lockObject = new object();
        public void ReadTicks(string fileName)
        {
            lock (m_lockObject)
            {
                int idx = 0;
                m_ticks = new MqlTick[54000000];

                using (System.IO.BinaryReader br = new BinaryReader(new FileStream(fileName, FileMode.Open)))
                {
                    while (true)
                    {
                        try
                        {
                            long datetime = br.ReadInt64();
                            double bid = br.ReadDouble();
                            double ask = br.ReadDouble();
                            //double last = br.ReadDouble();
                            //ulong volume = br.ReadUInt64();

                            m_ticks[idx] = new MqlTick
                            {
                                time = datetime,
                                bid = bid,
                                ask = ask,
                                //last = last,
                                //volume = volume
                            };
                            idx++;
                        }
                        catch (System.IO.EndOfStreamException)
                        {
                            break;
                        }
                    }
                }
            }
        }
    }
}
