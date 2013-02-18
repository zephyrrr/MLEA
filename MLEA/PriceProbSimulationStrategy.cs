using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public class PriceProbSimulationStrategy : ISimulateStrategy
    {
        //public void CalcHighProb()
        //{
        //    string rateFileName = string.Format("D:\\Program Files\\MetaTrader 5\\MQL5\\Files\\{0}_M1.dat", m_symbol);
        //    var rate = ReadRates(rateFileName);

        //    try
        //    {
        //        int bufferCnt = 10000;
        //        int n = 0;
        //        var txn = DbHelper.Instance.BeginTransaction();

        //        int begin = 0;
        //        WriteLog(begin);
        //        for (int i = begin; i < rate.Length; ++i)
        //        {
        //            SqlCommand cmd = new SqlCommand(string.Format("UPDATE [{0}] SET hp = @hp where [time]=@time", m_symbolPeriod));
        //            //if (dt < new DateTime(2010, 1, 1))
        //            //    continue;

        //            double hp = 0;

        //            double open = rate[i].close;
        //            for (int j = i + 1; j < rate.Length; ++j)
        //            {
        //                if (rate[j].high > open + 0.0080)
        //                {
        //                    hp = 1;
        //                    for (int k = i + 1; k <= j; ++k)
        //                    {
        //                        if (rate[k].low < open - 0.0030)
        //                        {
        //                            hp = 0;
        //                        }
        //                    }
        //                    break;
        //                }
        //                else if (rate[j].low < open - 0.0080)
        //                {
        //                    hp = -1;
        //                    for (int k = i + 1; k <= j; ++k)
        //                    {
        //                        if (rate[k].high > open + 0.0030)
        //                        {
        //                            hp = 0;
        //                        }
        //                    }
        //                    break;
        //                }
        //            }

        //            //const int calcHour = 6;
        //            //double h = 0, l = 0,m = 0;
        //            //for (int j = i + 1; j <= i + 60 * calcHour && j < rate.Length; ++j)
        //            //{
        //            //    if (rate[j].time > rate[i].time + 60 * 60 * calcHour)
        //            //        break;
        //            //    if (rate[j].close > rate[i].close)
        //            //        h += (rate[j].close - rate[i].close);
        //            //    else if (rate[j].close < rate[i].close)
        //            //        l += -(rate[j].close - rate[i].close);
        //            //    else
        //            //        m += 0;
        //            //}


        //            ////if ((int)Math.Round((double)h/(h+l+m) * 10) > 5)
        //            ////    hp = (int)Math.Round((double)h/(h+l+m) * 10) - 5;
        //            ////else if ((int)Math.Round((double)l/(h+l+m) * 10) > 5)
        //            ////    hp = -((int)Math.Round((double)l/(h+l+m) * 10) - 5);
        //            ////else
        //            ////    hp = 0;

        //            //hp = 5;
        //            //double r = Math.Round((double)h / (h + l + m) * 10, 1);
        //            //if (r > 5)
        //            //{
        //            //    hp = r;
        //            //}
        //            //else
        //            //{
        //            //    r = Math.Round((double)l / (h + l + m) * 10, 1);
        //            //    if (r > 5)
        //            //    {
        //            //        hp = 10 - r;
        //            //    }
        //            //}

        //            cmd.Parameters.AddWithValue("@time", rate[i].time);
        //            cmd.Parameters.AddWithValue("@hp", hp);

        //            cmd.Transaction = txn as SqlTransaction;
        //            DbHelper.Instance.ExecuteNonQuery(cmd);

        //            n++;

        //            if (n >= bufferCnt || i == rate.Length - 1)
        //            {
        //                try
        //                {
        //                    WriteLog(" - " + i);
        //                    DbHelper.Instance.CommitTransaction(txn);
        //                }
        //                catch (Exception ex)
        //                {
        //                    WriteLog(ex.Message);
        //                    DbHelper.Instance.RollbackTransaction(txn);

        //                    i -= n;
        //                }
        //                WriteLog(i);

        //                if (i != rate.Length - 1)
        //                {
        //                    txn = DbHelper.Instance.BeginTransaction();
        //                }
        //                n = 0;
        //            }
        //        }
        //        //DbHelper.Instance.CommitTransaction(txn);
        //    }
        //    catch (Exception ex)
        //    {
        //        WriteLog(ex.Message);
        //    }
        //}
        public PriceProbSimulationStrategy(string symbol, int simuMinutes, double threshold)
        {
            m_simuTime = simuMinutes;
            m_threshold = threshold;

            m_rates = DbData.Instance.ReadRates("EURUSD_M1");

            m_times = new long[m_rates.Length];
            for (int i = 0; i < m_rates.Length; ++i)
            {
                m_times[i] = m_rates[i].time;
            }
        }
        private int m_simuTime;
        private double m_threshold;
        private MqlRates[] m_rates;
        private long[] m_times;
        public bool? DoBuy(DateTime openDate, double openPrice, out DateTime? closeDate)
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

            const double point = 0.00001;

            double buyOpen = m_rates[idx].close + m_rates[idx].spread * point;  //ask
            double sum = 0;
            for (int j = idx; j < Math.Min(idx + m_simuTime, m_rates.Length); ++j)
            {
                sum += m_rates[j].close - buyOpen;
            }
            closeDate = Parameters.MtStartTime.AddSeconds(m_rates[Math.Min(idx + m_simuTime, m_rates.Length) - 1].time);

            if (sum > m_threshold)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public bool? DoSell(DateTime openDate, double openPrice, out DateTime? closeDate)
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

            const double point = 0.00001;

            double sellOpen = m_rates[idx].close - m_rates[idx].spread * point;  //ask
            double sum = 0;
            for (int j = idx; j < Math.Min(idx + m_simuTime, m_rates.Length); ++j)
            {
                sum += m_rates[j].close - sellOpen;
            }
            closeDate = Parameters.MtStartTime.AddSeconds(m_rates[Math.Min(idx + m_simuTime, m_rates.Length) - 1].time);

            if (sum < -m_threshold)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
    }
}
