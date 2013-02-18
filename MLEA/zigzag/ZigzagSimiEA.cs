using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace MLEA
{
    public class ZigzagSimiEA : AbstractEA
    {
        public ZigzagSimiEA()
        {
            m_simulator = new RateSimulator(this);
        }
        #region "Data Generator"
        /// <summary>
        /// 根据相似的图形，产生可供Excel看的数据。前10个是Zigzag点，后120个是实际价格
        /// </summary>
        public void GenerateSimiRatesExcel()
        {
            using (StreamReader sr = new StreamReader("c:\\forex\\simiLike.txt"))
            {
                int n = 0;
                while (true)
                {
                    string s = sr.ReadLine();
                    if (s == null)
                        break;
                    if (string.IsNullOrEmpty(s))
                        continue;

                    string[] ss = s.Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);
                    if (ss.Length <= 1)
                        continue;

                    int[] m = new int[ss.Length];
                    for (int i = 0; i < ss.Length; ++i)
                        m[i] = Convert.ToInt32(ss[i]);

                    //GenerateExcel("c:\\forex\\simiLikeExcel\\zigzag.cvs." + m[0].ToString(), m, 10);

                    n++;
                }
            }
        }

        /// <summary>
        /// 根据已经生成的Zigzag距离，寻找相似的曲线
        /// </summary>
        public static void GetSimiLikes()
        {
            double e = 3;

            //int length = 10;
            //var mqlRate = MqlRateHelper.ReadZigzag("c:\\forex\\zigzag.dat");
            //int count = Math.Min(mqlRate.Count, 500000);

            //double[][] data = new double[count - length][];
            //for (int i = 0; i < data.Length; ++i)
            //{
            //    data[i] = new double[length];
            //}

            int dataLength = 5000;
            double[, ,] simi = new double[dataLength, dataLength, 2];
            //Dictionary<Tuple<int, int>, double[]> simi = new Dictionary<Tuple<int, int>, double[]>();

            using (StreamReader sr = new StreamReader("c:\\forex\\simi_cache.dat"))
            {
                while (true)
                {
                    string s = sr.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        break;

                    string[] ss = s.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                    if (ss.Length != 4)
                    {
                        throw new ArgumentException("Invalid length!");
                    }
                    //simi[new Tuple<int, int>(Convert.ToInt32(ss[0]), Convert.ToInt32(ss[1]))] =
                    //    new double[] { Convert.ToDouble(ss[2]), Convert.ToDouble(ss[3]) };
                    simi[Convert.ToInt32(ss[0]), Convert.ToInt32(ss[1]), 0] = Convert.ToDouble(ss[2]);
                    simi[Convert.ToInt32(ss[0]), Convert.ToInt32(ss[1]), 1] = Convert.ToDouble(ss[3]);
                }
            }

            //Dictionary<int, List<Tuple<int, double>>> simiLikes = new Dictionary<int, List<Tuple<int, double>>>();

            //foreach(var i in simi)
            //{
            //    if (!simiLikes.ContainsKey(i.Key.First))
            //    {
            //        simiLikes[i.Key.First] = new List<Tuple<int, double>>();
            //    }
            //    if (!simiLikes.ContainsKey(i.Key.Second))
            //    {
            //        simiLikes[i.Key.Second] = new List<Tuple<int, double>>();
            //    }

            //    if (i.Value[0] != 0 && i.Value[0] < e)
            //    {
            //        simiLikes[i.Key.First].Add(new Tuple<int, double>(i.Key.Second, i.Value[0]));

            //        simiLikes[i.Key.Second].Add(new Tuple<int, double>(i.Key.First, i.Value[0]));
            //    }
            //}

            //foreach (var i in simiLikes)
            //{
            //    i.Value.Sort(new Comparison<Tuple<int, double>>((x, y) =>
            //    {
            //        return x.Second.CompareTo(y.Second);
            //    }));
            //}

            //using (StreamWriter sw = new StreamWriter("c:\\forex\\simi_pos.txt"))
            //{
            //    foreach (var i in simiLikes)
            //    {
            //        sw.WriteLine(i.Key);
            //        sw.Write("\t");

            //        foreach (var j in i.Value)
            //        {
            //            sw.Write(j.First);
            //            sw.Write("\t");
            //        }
            //        sw.WriteLine();
            //    }
            //}

            List<Tuple<int, double>>[] simiLikes = new List<Tuple<int, double>>[dataLength];
            for (int i = 0; i < dataLength; ++i)
            {
                simiLikes[i] = new List<Tuple<int, double>>();
                simiLikes[i].Add(new Tuple<int, double>(i, 0));

                for (int j = 0; j < i; ++j)
                {
                    if (simi[i, j, 0] != 0 && simi[i, j, 0] < e)
                    {
                        simiLikes[i].Add(new Tuple<int, double>(j, simi[i, j, 0]));
                    }
                }

                simiLikes[i].Sort(new Comparison<Tuple<int, double>>((x, y) =>
                {
                    return x.Item2.CompareTo(y.Item2);
                }));
            }

            using (StreamWriter sw = new StreamWriter("c:\\forex\\simiLike.txt"))
            {
                foreach (var i in simiLikes)
                {
                    if (i == null)
                        continue;

                    foreach (Tuple<int, double> j in i)
                    {
                        sw.Write(j.Item1);
                        sw.Write("\t");
                    }
                    sw.WriteLine();
                }
            }
        }
        #endregion

        private RateSimulator m_simulator;

        private static string CacheFileName = "c:\\forex\\simi_cache.dat";

        public override void OnLoad()
        {
            base.OnLoad();

            //using (StreamReader sr = new StreamReader(CacheFileName))
            //{
            //    while (true)
            //    {
            //        string s = sr.ReadLine();
            //        if (string.IsNullOrEmpty(s))
            //            break;

            //        string[] ss = s.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            //        if (ss.Length != 4)
            //        {
            //            throw new ArgumentException("Invalid length!");
            //        }
            //        m_simiCache[Convert.ToInt32(ss[0]), Convert.ToInt32(ss[1]), 0] = Convert.ToDouble(ss[2]);
            //        m_simiCache[Convert.ToInt32(ss[0]), Convert.ToInt32(ss[1]), 1] = Convert.ToDouble(ss[3]);
            //    }
            //}
        }

        public override void OnUnload()
        {
            //Save();
            //weka.timeseries.SimilarityAnalysis.SaveCache();
            //using (var file = System.IO.File.Open(CacheFileName, System.IO.FileMode.Create))
            //{
            //    var bf = new System.Runtime.Serialization.Formatters.Binary.BinaryFormatter();
            //    bf.Serialize(file, m_simiCache);
            //}
            using (StreamWriter sw = new StreamWriter(CacheFileName))
            {
                for (int i = 0; i < dataLength; ++i)
                {
                    for (int j = 0; j < dataLength; ++j)
                    {
                        if (m_simiCache[i, j, 0] != 0)
                        {
                            string s = string.Format("{0}, {1}, {2}, {3}", i, j, m_simiCache[i, j, 0], m_simiCache[i, j, 1]);
                            sw.WriteLine(s);
                        }
                    }
                }
            }

            base.OnUnload();
        }

        private void Normalize(double[] d)
        {
            for (int i = 1; i < d.Length; ++i)
            {
                d[i] = (int)Math.Round((d[i] - d[0]) * 10000);
            }
            d[0] = 0;
        }

        private const int dataLength = 5000;

        double[, ,] m_simiCache = new double[dataLength, dataLength, 2];

        private double m_lastTime, m_lastZigzag;
        private bool m_isCalculating = false;
        private int m_lastZigzagPos;
        public void OnTick(MqlRates mqlRate, double zigzag, ReturnActionInfo returnAction)
        {
            //if (mqlRate.time != (new DateTime(2010, 5, 3, 16, 25, 0) - this.MtStartTime).TotalSeconds)
            //    return;

            //if (mqlRate.time < (new DateTime(2009, 08, 10, 07, 25, 0) - this.MtStartTime).TotalSeconds)
            //    return;
            //if (mqlRate.time > (new DateTime(2010, 08, 10, 07, 25, 0) - this.MtStartTime).TotalSeconds)
            //    return;

            if (zigzag == 0)
                return;

            if (m_lastTime == mqlRate.time && m_lastZigzag == zigzag)
                return;

            if (m_isCalculating)
                return;

            m_isCalculating = true;
            m_lastTime = mqlRate.time;
            m_lastZigzag = zigzag;

            try
            {
                int nowRatePos = m_simulator.Rates.Count - 1;
                int nowZigzagPos = this.ZigzagValues.Count - 1;

                // Add Data
                if ((m_simulator.Rates[m_simulator.Rates.Count - 1].time - Parameters.MtStartTime).TotalSeconds < mqlRate.time)
                {
                    m_simulator.Rates.Add(new ZigzagRate
                    {
                        time = Parameters.MtStartTime.AddSeconds(mqlRate.time),
                        open = mqlRate.open,
                        high = mqlRate.high,
                        low = mqlRate.low,
                        close = mqlRate.close,
                        tick_volume = mqlRate.tick_volume,
                        spread = mqlRate.spread,
                        real_volume = mqlRate.real_volume,
                        zigzag = zigzag
                    });
                    nowRatePos++;

                    if (zigzag != 0)
                    {
                        this.ZigzagValues.Add(zigzag);
                        this.ZigzagToRatePos.Add(m_simulator.Rates.Count - 1);

                        nowZigzagPos++;
                    }
                }
                else if ((m_simulator.Rates[m_simulator.Rates.Count - 1].time - Parameters.MtStartTime).TotalSeconds == mqlRate.time)
                {
                    var v = m_simulator.Rates[m_simulator.Rates.Count - 1];
                    v.open = mqlRate.open;
                    v.high = mqlRate.high;
                    v.low = mqlRate.low;
                    v.close = mqlRate.close;
                    v.tick_volume = mqlRate.tick_volume;
                    v.spread = mqlRate.spread;
                    v.real_volume = mqlRate.real_volume;
                    v.zigzag = zigzag;

                    if (zigzag != this.ZigzagValues[this.ZigzagValues.Count - 1])
                    {
                        this.ZigzagValues[this.ZigzagValues.Count - 1] = zigzag;
                    }
                }
                else
                {
                    for (int i = 0; i < m_simulator.Rates.Count; ++i)
                    {
                        if ((m_simulator.Rates[i].time - Parameters.MtStartTime).TotalSeconds == mqlRate.time)
                        {
                            nowRatePos = i;
                            break;
                        }
                    }

                    for (int i = 0; i < this.ZigzagToRatePos.Count; ++i)
                    {
                        if (this.ZigzagToRatePos[i] > nowRatePos)
                        {
                            nowZigzagPos = i - 1;
                            break;
                        }
                    }
                    //throw new ArgumentException("Invalid mqlRate's Time in OnTick!");
                }

                if (nowZigzagPos < m_zigzagPatternLength)
                {
                    return;
                }

                if (nowZigzagPos == m_lastZigzagPos)
                {
                    return;
                }

                m_lastZigzagPos = nowZigzagPos;

                Dictionary<int, int> priceStatIn = new Dictionary<int, int>();
                Dictionary<int, int> priceStatOut = new Dictionary<int, int>();
                List<List<ZigzagRate>> likeRatesList = new List<List<ZigzagRate>>();

                double[] nowZigzag = new double[m_zigzagPatternLength];
                double[] prevZigzag = new double[m_zigzagPatternLength];

                for (int i = 0; i < m_zigzagPatternLength; ++i)
                {
                    nowZigzag[i] = this.ZigzagValues[nowZigzagPos + i + 1 - m_zigzagPatternLength]; // 
                }
                Normalize(nowZigzag);


                for (int j = m_zigzagPatternLength - 1; j < nowZigzagPos; ++j)
                {
                    // 加 1 - m_zigzagPatternLength为朝后看
                    for (int i = 0; i < m_zigzagPatternLength; ++i)
                    {
                        prevZigzag[i] = this.ZigzagValues[j + i + 1 - m_zigzagPatternLength];
                    }
                    Normalize(prevZigzag);

                    double[] ret;
                    if (m_simiCache[nowZigzagPos, j, 0] != 0)
                    {
                        ret = new double[] { m_simiCache[nowZigzagPos, j, 0], m_simiCache[nowZigzagPos, j, 1] };
                    }
                    else
                    {
                        //ret = weka.timeseries.SimilarityAnalysis.GetSimilarity(nowZigzag, prevZigzag);
                        //m_simiCache[nowZigzagPos, j, 0] = ret[0];
                        //m_simiCache[nowZigzagPos, j, 1] = ret[1];
                        ret = new double[1] { 0 };
                    }

                    if (ret[0] < m_zigzagSimilarityFreqE && ret[1] < m_zigzagSimilarityTimeE)
                    {
                        //GetPriceStat(this.ZigzagToRatePos[j], 0, 50, priceStatIn);
                        //GetPriceStat(this.ZigzagToRatePos[j], 50, 200, priceStatOut);

                        var l = new List<ZigzagRate>();
                        likeRatesList.Add(l);
                        for (int i = 0; i < 120; ++i)
                        {
                            l.Add(m_simulator.Rates[this.ZigzagToRatePos[j] + i]);
                        }
                    }
                }

                if (likeRatesList.Count == 0)
                    return;

                double maxP = double.MinValue;
                int maxDealType = 0, maxBl = 0, maxTp = 0, maxSl = 0;

                for (int i = 0; i <= 20; i += 5)
                {
                    for (int tp = 20; tp <= 100; tp += 5)
                    {
                        for (int sl = 10; sl < 50; sl += 5)
                        {
                            double profit = 0;
                            foreach (List<ZigzagRate> l in likeRatesList)
                            {
                                bool hasPosition = false;
                                double dealPrice = 0;
                                double nowPrice = l[0].open;
                                foreach (ZigzagRate r in l)
                                {
                                    if (!hasPosition)
                                    {
                                        double price = nowPrice - i * 0.0001;
                                        if (price >= r.low && price < r.high)
                                        {
                                            hasPosition = true;
                                            dealPrice = price;
                                        }
                                    }
                                    else
                                    {
                                        if (dealPrice + tp * 0.0001 >= r.low && dealPrice + tp * 0.0001 < r.high)
                                        {
                                            profit += tp;
                                            break;
                                        }
                                        else if (dealPrice - sl * 0.0001 + this.Spread * 0.0001 >= r.low && dealPrice - sl * 0.0001 + this.Spread * 0.0001 < r.high)
                                        {
                                            profit -= sl;
                                            break;
                                        }
                                    }
                                }
                            }

                            if (profit > 0 && profit > maxP)
                            {
                                maxDealType = 1;
                                maxP = profit;
                                maxBl = i;
                                maxTp = tp;
                                maxSl = sl;
                            }

                            // sell
                            profit = 0;
                            foreach (List<ZigzagRate> l in likeRatesList)
                            {
                                bool hasPosition = false;
                                double dealPrice = 0;
                                double nowPrice = l[0].open;
                                foreach (ZigzagRate r in l)
                                {
                                    if (!hasPosition)
                                    {
                                        double price = nowPrice + i * 0.0001;
                                        if (price + this.Spread * 0.0001 >= r.low && price + this.Spread * 0.0001 < r.high)
                                        {
                                            hasPosition = true;
                                            dealPrice = price;
                                        }
                                    }
                                    else
                                    {
                                        if (dealPrice - tp * 0.0001 - this.Spread * 0.0001 >= r.low && dealPrice - tp * 0.0001 - this.Spread * 0.0001 < r.high)
                                        {
                                            profit += tp;
                                            break;
                                        }
                                        else if (dealPrice + sl * 0.0001 >= r.low && dealPrice + sl * 0.0001 < r.high)
                                        {
                                            profit -= sl;
                                            break;
                                        }
                                    }
                                }
                            }

                            if (profit > 0 && profit > maxP)
                            {
                                maxDealType = -1;
                                maxP = profit;
                                maxBl = i;
                                maxTp = tp;
                                maxSl = sl;
                            }
                        }
                    }
                }

                using (StreamWriter sw = new StreamWriter("c:\\forex\\ea_order_detail.txt", true))
                {
                    sw.WriteLine(string.Format("{0}, {1}, {2}, {3}, {4}, {5}, {6}", nowZigzagPos, maxDealType, maxBl, maxTp, maxSl, maxP, Parameters.MtStartTime.AddSeconds(mqlRate.time).ToString("yyyy.MM.dd HH:mm")));
                }

                using (StreamWriter sw = new StreamWriter("c:\\forex\\ea_order.txt", true))
                {
                    if (maxDealType == 1)
                    {
                        sw.WriteLine(string.Format("Buy, {0}, {1}, {2}, {3}, {4}", Parameters.MtStartTime.AddSeconds(mqlRate.time).ToString("yyyy.MM.dd HH:mm"), maxBl, maxTp, maxSl, maxP));
                    }
                    else if (maxDealType == -1)
                    {
                        sw.WriteLine(string.Format("Sell, {0}, {1}, {2}, {3}, {4}", Parameters.MtStartTime.AddSeconds(mqlRate.time).ToString("yyyy.MM.dd HH:mm"), maxBl, maxTp, maxSl, maxP));
                    }
                }

                //if (priceStatIn.Count == 0 && priceStatOut.Count == 0)
                //    return;

                //double count = 0, count2 = 0;
                //foreach (var dealIn in priceStatIn)
                //    count += dealIn.Value;
                //foreach (var dealOut in priceStatOut)
                //    count2 += dealOut.Value;

                //double maxPSell = double.MinValue, minPSell = double.MaxValue, allPSell = 0;
                //double maxPBuy = double.MinValue, minPBuy = double.MaxValue, allPBuy = 0;
                //int maxDealInBuy = 0, maxDealOutBuy = 0;
                //int maxDealInSell = 0, maxDealOutSell = 0;
                //foreach (var dealIn in priceStatIn)
                //{
                //    foreach (var dealOut in priceStatOut)
                //    {
                //        int profitSell = 0, profitBuy = 0;
                //        profitBuy = dealOut.Key - dealIn.Key - this.Spread;
                //        profitSell = dealIn.Key - dealOut.Key - this.Spread;

                //        double prob = (dealIn.Value / count) * (dealOut.Value / count2);
                //        double p1 = prob * profitBuy;
                //        double p2 = prob * profitSell;
                //        if (p1 > maxPBuy)
                //        {
                //            maxPBuy = p1;
                //            maxDealInBuy = dealIn.Key;
                //            maxDealOutBuy = dealOut.Key;
                //        }
                //        if (p1 < minPBuy)
                //        {
                //            minPBuy = p1;
                //        }

                //        if (p2 > maxPSell)
                //        {
                //            maxPSell = p2;
                //            maxDealInSell = dealIn.Key;
                //            maxDealOutSell = dealOut.Key;
                //        }
                //        if (p2 < minPSell)
                //        {
                //            minPSell = p2;
                //        }

                //        allPBuy += p1;
                //        allPSell += p2;
                //    }
                //}

                //if (allPBuy > allPSell && allPBuy > 0)
                ////if (maxPBuy > maxPSell && maxPBuy > 0)
                //{
                //    returnAction.DealType = 1;
                //    returnAction.DealIn = maxDealInBuy;
                //    returnAction.DealOut = maxDealOutBuy;
                //    returnAction.WinProb = allPBuy;
                //    returnAction.LoseProb = minPBuy;

                //    using (StreamWriter sw = new StreamWriter("c:\\forex\\ea_order.txt", true))
                //    {
                //        sw.WriteLine(string.Format("Buy, {0}, {1}, {2}, {3}, {4}", this.MtStartTime.AddSeconds(mqlRate.time).ToString("yyyy.MM.dd HH:mm"), maxDealInBuy, maxDealOutBuy, allPBuy.ToString("N2"), minPBuy.ToString("N2")));
                //    }
                //}
                //else if (allPSell > allPBuy && allPSell > 0)
                ////else if (maxPSell > maxPBuy && maxPSell > 0)
                //{
                //    returnAction.DealType = -1;
                //    returnAction.DealIn = maxDealInSell;
                //    returnAction.DealOut = maxDealOutSell;
                //    returnAction.WinProb = allPSell;
                //    returnAction.LoseProb = minPSell;

                //    using (StreamWriter sw = new StreamWriter("c:\\forex\\ea_order.txt", true))
                //    {
                //        sw.WriteLine(string.Format("Sell, {0}, {1}, {2}, {3}, {4}", this.MtStartTime.AddSeconds(mqlRate.time).ToString("yyyy.MM.dd HH:mm"), maxDealInSell, maxDealOutSell, allPSell.ToString("N2"), minPSell.ToString("N2")));
                //    }
                //}
                //else
                //{
                //    returnAction.DealType = 0;
                //}
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
            finally
            {
                m_isCalculating = false;
            }
        }

        private void GetPriceStat(int start, int offset, int length, Dictionary<int, int> priceStat)
        {
            int s = (int)Math.Round(m_simulator.Rates[start].low * 10000);
            for (int i = offset; i < offset + length; ++i)
            {
                for (int k = (int)Math.Round(m_simulator.Rates[start + i + 1].open * 10000); k < (int)Math.Round(m_simulator.Rates[start + i + 1].high * 10000); ++k)
                {
                    int l = k - s;
                    if (!priceStat.ContainsKey(l))
                        priceStat[l] = 1;
                    else
                        priceStat[l]++;
                }

                for (int k = (int)Math.Round(m_simulator.Rates[start + i + 1].high * 10000); k > (int)Math.Round(m_simulator.Rates[start + i + 1].low * 10000); --k)
                {
                    int l = k - s;
                    if (!priceStat.ContainsKey(l))
                        priceStat[l] = 1;
                    else
                        priceStat[l]++;
                }

                for (int k = (int)Math.Round(m_simulator.Rates[start + i + 1].low * 10000); k <= (int)Math.Round(m_simulator.Rates[start + i + 1].close * 10000); ++k)
                {
                    int l = k - s;
                    if (!priceStat.ContainsKey(l))
                        priceStat[l] = 1;
                    else
                        priceStat[l]++;
                }
            }
        }

        private const int m_zigzagPatternLength = 10;
        private const double m_zigzagSimilarityFreqE = 3;
        private const double m_zigzagSimilarityTimeE = 50;

        
    }
}
