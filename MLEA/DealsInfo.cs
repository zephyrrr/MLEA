using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    [Serializable]
    public class RealDealsInfo
    {
        public RealDealsInfo()
        {
            spread = 5 * DealsInfo.GetPoint(0);
        }

        private List<DealInfo> m_deals = new List<DealInfo>();
        private DateTime m_nowTime;
        private MqlRates m_nowPrice;
        private float spread;

        public void AddDeal(DealInfo dealInfo)
        {
            m_deals.Add(dealInfo);
        }
        public void AddDeal(DateTime openTime, double openPrice, char dealType, double volume, double cost, DateTime closeTime)
        {
            m_deals.Add(new DealInfo(openTime, (float)openPrice, dealType, (float)volume, (float)cost, closeTime));
        }
        private void RemoveOldDeals()
        {
            m_deals.RemoveAll(new System.Predicate<DealInfo>(i =>
            {
                WekaUtils.DebugAssert(i.CloseTime.HasValue, "Deal should has closeTime.");
                if (i.CloseTime.HasValue)
                {
                    if (i.CloseTime < m_nowTime)
                    {
                        if (i.Cost < 0)
                            m_nowTp++;
                        else
                            m_nowFp++;
                        m_nowCost += i.Cost * i.Volume;
                        m_nowVolume += i.Volume;
                        return true;
                    }
                }
                else
                {

                }
                return false;
            }));
        }
        public void Now(DateTime nowTime, double? nowPrice)
        {
            m_nowTime = nowTime;
            if (nowPrice.HasValue)
            {
                m_nowPrice.close = nowPrice.Value;
            }
            m_nowPrice.time = WekaUtils.GetTimeFromDate(nowTime);

            RemoveOldDeals();

            //CloseAll();

            CalculateCurrent();
        }
        public void Reset()
        {
            m_nowCost = 0;
            m_nowTp = 0; m_nowFp = 0; m_nowCloseManually = 0;
            m_nowVolume = 0;

            m_currentProfit = 0;
            m_currentVolume = 0;
            m_currentCost = 0;
        }

        private void CalculateCurrent()
        {
            m_currentProfit = 0;
            m_currentCost = 0;
            m_currentVolume = 0;

            

            foreach (var i in m_deals)
            {
                m_currentVolume += i.Volume;
                m_currentCost += i.Cost * i.Volume;

                if (m_nowPrice.close > 0)
                {
                    if (i.DealType == 'B')
                    {
                        float cost = ((float)m_nowPrice.close - i.OpenPrice - spread) * DealsInfo.GetPointInv(m_nowPrice.close);
                        m_currentProfit -= cost * i.Volume;
                    }
                    else if (i.DealType == 'S')
                    {
                        float cost = (i.OpenPrice - (float)m_nowPrice.close - spread) * DealsInfo.GetPointInv(m_nowPrice.close);
                        m_currentProfit -= cost * i.Volume;
                    }
                }
            }
        }

        public void CloseAll()
        {
            m_nowCloseManually = m_deals.Count;
            foreach (var i in m_deals)
            {
                if (i.DealType == 'B')
                {
                    float cost = ((float)m_nowPrice.close - i.OpenPrice - spread) * DealsInfo.GetPointInv(m_nowPrice.close);
                    m_nowCost -= cost * i.Volume;
                }
                else if (i.DealType == 'S')
                {
                    float cost = (i.OpenPrice - (float)m_nowPrice.close - spread) * DealsInfo.GetPointInv(m_nowPrice.close);
                    m_nowCost -= cost * i.Volume;
                }
                m_nowVolume += i.Volume;
            }

            m_deals.Clear();
        }

        private float m_nowCost = 0;
        private int m_nowTp = 0, m_nowFp = 0, m_nowCloseManually = 0;
        private float m_nowVolume = 0;

        private float m_currentProfit = 0;
        private float m_currentVolume = 0;
        private float m_currentCost = 0;
        public int NowDeal
        {
            get { return m_nowTp + m_nowFp; }
        }
        public int NowTp
        {
            get { return m_nowTp; }
        }
        public int NowFp
        {
            get { return m_nowFp; }
        }
        public float NowCost
        {
            get { return m_nowCost; }
        }
        public float NowVolume
        {
            get { return m_nowVolume; }
        }
        
        public float CurrentProfit
        {
            get { return m_currentProfit; }
        }
        public int CurrentDeal
        {
            get { return m_deals.Count; }
        }
        public float CurrentVolume
        {
            get { return m_currentVolume; }
        }

        public float TotalVolume
        {
            get
            {
                return m_currentVolume + m_nowVolume;
            }
        }

        public float TotalCost
        {
            get
            {
                return m_currentCost + m_nowCost;
            }
        }
        
        
    }

    [Serializable]
    public class DealInfo
    {
        public override string ToString()
        {
            if (m_closeTime.HasValue)
            {
                return string.Format("{0}-{1}:{2}", m_openTime, m_closeTime, m_cost);
            }
            else
            {
                return string.Format("{0},{1}:{2},{3}", m_openTime, m_openPrice, m_closePriceTp, m_closePriceSl);
            }
        }
        private DateTime m_openTime;
        private DateTime? m_closeTime;
        private float m_openPrice;
        private char m_dealType;
        private float m_cost;
        private float m_volume = 1;

        private float m_closePriceTp, m_closePriceSl;
        public DealInfo(DateTime openTime, float openPrice, char dealType, float volume, float closePriceTp, float closePriceSl)
        {
            m_openTime = openTime;
            m_openPrice = openPrice;
            m_dealType = dealType;
            m_volume = volume;

            m_closePriceTp = closePriceTp;
            m_closePriceSl = closePriceSl;
        }

        public DealInfo(DateTime openTime, float openPrice, char dealType, float volume, float cost, DateTime closeTime)
        {
            m_openTime = openTime;
            m_openPrice = openPrice;
            m_dealType = dealType;
            m_volume = volume;

            m_closeTime = closeTime;
            m_cost = cost;
        }
        public DateTime OpenTime
        {
            get { return m_openTime; }
        }
        public float OpenPrice
        {
            get { return m_openPrice; }
        }
        public float ClosePriceTp
        {
            get { return m_closePriceTp; }
        }
        public float ClosePriceSl
        {
            get { return m_closePriceSl; }
        }
        public char DealType
        {
            get { return m_dealType; }
        }

        public DateTime? CloseTime
        {
            get { return m_closeTime; }
            set { m_closeTime = value; }
        }
        public float Cost
        {
            get { return m_cost; }
            set { m_cost = value; }
        }
        public float Volume
        {
            get { return m_volume; }
        }

        public string PrintAll()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendFormat("m_openTime = {0}, ", m_openTime);
            sb.AppendFormat("m_closeTime = {0}, ", m_closeTime);
            sb.AppendFormat("m_openPrice = {0}, ", m_openPrice);
            sb.AppendFormat("m_dealType = {0}, ", m_dealType);
            sb.AppendFormat("m_cost = {0}, ", m_cost);
            sb.AppendFormat("m_closePriceTp = {0}, ", m_closePriceTp);
            sb.AppendFormat("m_closePriceSl = {0}, ", m_closePriceSl);
            sb.AppendFormat("m_volume = {0}", m_volume);
            return sb.ToString();
        }
    }

    [Serializable]
    public class DealsInfo
    {
        public DealsInfo(int lastMinutes)
        {
            m_lastMinutes = lastMinutes;

            spread = 5 *  GetPoint(0);
        }

        private float spread;
        [NonSerialized]
        private List<DealInfo> m_deals = new List<DealInfo>();
        internal List<DealInfo> Deals
        {
            get { return m_deals; }
            set { m_deals = value; }
        }

        private int m_lastMinutes;
        private DateTime m_nowTime;
        private MqlRates m_nowPrice;
        private bool m_isLastForPeriod = false;
        private DateTime? m_firstLastDate = null;

        private int m_nowTp = 0, m_nowFp = 0;
        private float m_nowCost = 0, m_currentProfit = 0;

        private float m_totalVolume = 0;
        private int m_totalDeal = 0;

        public void AddDeal(DateTime openTime, double openPrice, char dealType, double volume, double closePriceTp, double closePriceSl)
        {
            if (!TestParameters2.RealTimeMode)
            {
                WekaUtils.Instance.WriteLog(string.Format("in not realTimeMode, closeTime must set. deal is {0}, {1}, {2}, {3}", openTime, dealType, closePriceTp, closePriceSl));
                return;
            }

            m_deals.Add(new DealInfo(openTime, (float)openPrice, dealType, (float)volume, (float)closePriceTp, (float)closePriceSl));
        }
        public void AddDeal(DateTime openTime, double openPrice, char dealType, double volume, double cost, DateTime closeTime)
        {
            m_deals.Add(new DealInfo(openTime, (float)openPrice, dealType, (float)volume, (float)cost, closeTime));
        }

        private void RemoveOldDeals()
        {
            DateTime lastTime = m_nowTime.AddMinutes(-m_lastMinutes);
            m_deals.RemoveAll(new System.Predicate<DealInfo>(p =>
            {
                //return p.OpenTime < lastTime;
                return p.CloseTime < lastTime;
            }));
        }

        public bool IsAvailableNow
        {
            get { return m_isLastForPeriod; }
        }

        public void NowDeals(DateTime nowTime, MqlRates nowRate)
        {
            if (!TestParameters2.RealTimeMode)
            {
                WekaUtils.Instance.WriteLog("in not realTimeMode, NowDeals should not be called.");
                return;
            }

            m_nowTime = nowTime;

            m_nowPrice = nowRate;

            foreach (var i in m_deals)
            {
                if (i.OpenTime >= m_nowTime)
                    continue;

                if (!i.CloseTime.HasValue)
                {
                    CalculateDealCloseTimeOnly(i);
                }
            }
        }
        public void Now(DateTime nowTime, double? nowPrice)
        {
            m_nowTime = nowTime;
            if (nowPrice.HasValue)
            {
                m_nowPrice.close = nowPrice.Value;
                m_nowPrice.time = WekaUtils.GetTimeFromDate(nowTime);
            }

            if (!m_isLastForPeriod)
            {
                if (m_firstLastDate == null)
                {
                    m_firstLastDate = nowTime.AddMinutes(m_lastMinutes);
                }
                if (m_firstLastDate <= m_nowTime)
                {
                    m_isLastForPeriod = true;
                }
            }
            else
            {
                RemoveOldDeals();
            }

            //CloseAll();

            CalculateTotal();
            CalculateNow();
        }
        public void CalculateTotal()
        {
            m_totalVolume = 0;
            m_totalDeal = 0;

            foreach (var i in m_deals)
            {
                if (i.OpenTime >= m_nowTime)
                    continue;

                m_totalVolume += i.Volume;
                m_totalDeal++;
            }
        }
        private void CalculateNow()
        {
            m_nowCost = 0;
            m_currentProfit = 0;
            m_nowTp = 0;
            m_nowFp = 0;

            List<double> dealLastTime = new List<double>();
            foreach (var i in m_deals)
            {
                if (i.OpenTime >= m_nowTime)
                    continue;

                if (i.CloseTime.HasValue)
                {
                    if (i.CloseTime <= m_nowTime)
                    {
                        if (i.Cost < 0)
                            m_nowTp++;
                        else
                            m_nowFp++;

                        m_nowCost += i.Cost * i.Volume;

                        dealLastTime.Add((i.CloseTime.Value - i.OpenTime).TotalSeconds);
                    }
                    else
                    {
                        if (i.DealType == 'B')
                        {
                            float cost = (float)(m_nowPrice.close - i.OpenPrice - spread) * GetPointInv(m_nowPrice.close);
                            m_currentProfit -= cost * i.Volume;
                        }
                        else if (i.DealType == 'S')
                        {
                            float cost = (float)(i.OpenPrice - m_nowPrice.close - spread) * GetPointInv(m_nowPrice.close);
                            m_currentProfit -= cost * i.Volume;
                        }
                    }
                }
                else
                {
                    if (!TestParameters2.RealTimeMode)
                    {
                        WekaUtils.Instance.WriteLog("in realTimeMode mode, every deal should have closeTime");
                        return;
                    }
                }
            }

            m_lastTimeAvg = (long)Maths.Average(dealLastTime.ToArray());
            m_lastTimeStd = (long)Maths.StandardDeviation(dealLastTime.ToArray());
        }

        private void CalculateDealCloseTimeOnly(DealInfo i)
        {
            if (m_nowPrice.low == 0 || m_nowPrice.high == 0)
            {
                throw new AssertException("nowPrice low or high is not set.");
            }
            if (i.DealType == 'B')
            {
                if (m_nowPrice.low <= i.ClosePriceSl + spread)
                {
                    float cost = (i.ClosePriceSl - i.OpenPrice - spread) * GetPointInv(m_nowPrice.close);
                    i.CloseTime = m_nowTime;
                    i.Cost = -cost;
                }
                else if (m_nowPrice.high >= i.ClosePriceTp - spread)
                {
                    float cost = (i.ClosePriceTp - i.OpenPrice - spread) * GetPointInv(m_nowPrice.close);
                    i.CloseTime = m_nowTime;
                    i.Cost = -cost;
                }
                else
                {
                }
            }
            else
            {
                if (m_nowPrice.high + spread > i.ClosePriceSl)
                {
                    float cost = ((i.OpenPrice - i.ClosePriceSl) - spread) * GetPointInv(m_nowPrice.close);
                    i.CloseTime = m_nowTime;
                    i.Cost = -cost;
                }
                else if (m_nowPrice.low + spread < i.ClosePriceTp)
                {
                    float cost = ((i.OpenPrice - i.ClosePriceTp) - spread) * GetPointInv(m_nowPrice.close);
                    i.CloseTime = m_nowTime;
                    i.Cost = -cost;
                }
                else
                {
                }
            }
        }
        //private void CalculateDealClose(DealInfo i)
        //{
        //    if (m_nowPrice.low == 0 || m_nowPrice.high == 0)
        //    {
        //        throw new AssertException("nowPrice low or high is not set.");
        //    }
        //    if (i.DealType == 'B')
        //    {
        //        if (m_nowPrice.low <= i.ClosePriceSl + spread)
        //        {
        //            m_nowFp++;
        //            float cost = (i.ClosePriceSl - i.OpenPrice - spread) * GetPointInv(m_nowPrice.close);
        //            m_nowCost -= cost * i.Volume;
        //            i.CloseTime = m_nowTime;
        //            i.Cost = -cost;
        //        }
        //        else if (m_nowPrice.high >= i.ClosePriceTp - spread)
        //        {
        //            m_nowTp++;
        //            float cost = (i.ClosePriceTp - i.OpenPrice - spread) * GetPointInv(m_nowPrice.close);
        //            m_nowCost -= cost * i.Volume;
        //            i.CloseTime = m_nowTime;
        //            i.Cost = -cost;
        //        }
        //        else
        //        {
        //            float cost = (float)(m_nowPrice.close - i.OpenPrice - spread) * GetPointInv(m_nowPrice.close);
        //            m_currentProfit -= cost * i.Volume;
        //        }
        //    }
        //    else
        //    {
        //        if (m_nowPrice.high + spread > i.ClosePriceSl)
        //        {
        //            m_nowFp++;
        //            float cost = ((i.OpenPrice - i.ClosePriceSl) - spread) * GetPointInv(m_nowPrice.close);
        //            m_nowCost -= cost * i.Volume;
        //            i.CloseTime = m_nowTime;
        //            i.Cost = -cost;
        //        }
        //        else if (m_nowPrice.low + spread < i.ClosePriceTp)
        //        {
        //            m_nowTp++;
        //            float cost = ((i.OpenPrice - i.ClosePriceTp) - spread) * GetPointInv(m_nowPrice.close);
        //            m_nowCost -= cost * i.Volume;
        //            i.CloseTime = m_nowTime;
        //            i.Cost = -cost;
        //        }
        //        else
        //        {
        //            float cost = (float)((i.OpenPrice - m_nowPrice.close) - spread) * GetPointInv(m_nowPrice.close);
        //            m_currentProfit -= cost * i.Volume;
        //        }
        //    }
        //}
        public void CloseAll()
        {
            m_nowCost = 0;
            m_currentProfit = 0;
            m_nowTp = 0;
            m_nowFp = 0;

            m_totalVolume = 0;
            m_totalDeal = 0;

            foreach (var i in m_deals)
            {
                if (i.CloseTime.HasValue)
                {
                    if (i.CloseTime <= m_nowTime)
                    {
                        if (i.Cost < 0)
                            m_nowTp++;
                        else
                            m_nowFp++;

                        m_nowCost += i.Cost * i.Volume;
                    }
                    else
                    {
                        if (i.DealType == 'B')
                        {
                            float cost = (float)(m_nowPrice.close - i.OpenPrice - spread) * DealsInfo.GetPointInv(m_nowPrice.close);
                            m_nowCost -= cost * i.Volume;
                            if (cost < 0)
                                m_nowTp++;
                            else
                                m_nowFp++;
                        }
                        else if (i.DealType == 'S')
                        {
                            float cost = (float)(i.OpenPrice - m_nowPrice.close - spread) * DealsInfo.GetPointInv(m_nowPrice.close);
                            m_nowCost -= cost * i.Volume;
                            if (cost < 0)
                                m_nowTp++;
                            else
                                m_nowFp++;
                        }
                    }
                }
            }
           

            m_deals.Clear();
        }
        public float TotalVolume
        {
            get  { return m_totalVolume; }
        }
        public int TotalDeal
        {
            get { return m_totalDeal; }
        }

        public int NowDeal
        {
            get { return m_nowTp + m_nowFp; }
        }
        public int NowTp
        {
            get { return m_nowTp; }
        }
        public int NowFp
        {
            get { return m_nowFp; }
        }

        private long m_lastTimeAvg, m_lastTimeStd;
        public long DealLastTimeAvg
        {
            get { return m_lastTimeAvg; }
        }

        public long DealLastTimeStd
        {
            get { return m_lastTimeStd; }
        }
        //internal float NowCost
        //{
        //    get { return m_nowCost; }
        //}
        //internal float NowProfit
        //{
        //    get { return m_nowProfit; }
        //}

        public float NowScore
        {
            get { return m_nowCost; }
        }
        public float NowPrecision
        {
            get
            {
                if (m_nowTp + m_nowFp == 0)
                    return 0;

                return (float)m_nowTp / (m_nowTp + m_nowFp);
            }
        }

        internal static int GetPointInv(double price)
        {
            //return (price > 20 ? 100 : 10000);
            return WekaUtils.GetSymbolPoint(TestParameters2.CandidateParameter.MainSymbol) * 100;
        }
        internal static float GetPoint(double price)
        {
            //return (price > 20 ? 0.01f : 0.0001f);
            return 1.0f / GetPointInv(price);
        }

        public string PrintAll(bool printDeal = false)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendFormat("m_lastMinutes = {0}, ", m_lastMinutes);
            sb.AppendFormat("m_nowTime = {0}, ", m_nowTime);
            sb.AppendFormat("m_lastTime = {0}, ", m_nowTime.AddMinutes(m_lastMinutes));
            sb.AppendFormat("m_nowPrice = {0}, ", m_nowPrice.close);
            sb.AppendFormat("m_isLastForPeriod = {0}, ", m_isLastForPeriod);
            sb.AppendFormat("m_firstDate = {0}, ", m_firstLastDate);
            sb.AppendFormat("m_totalTp = {0}, ", m_nowTp);
            sb.AppendFormat("m_totalFp = {0}, ", m_nowFp);
            sb.AppendFormat("m_totalCost = {0}, ", m_nowCost);
            sb.AppendFormat("m_totalNowCost = {0}", m_currentProfit);
            sb.AppendLine();
            sb.AppendFormat("DealCount = {0}", m_deals.Count);
            sb.AppendLine();
            if (printDeal)
            {
                foreach (var i in m_deals)
                {
                    sb.AppendLine(i.PrintAll());
                }
            }
            return sb.ToString();
        }
    }
}
