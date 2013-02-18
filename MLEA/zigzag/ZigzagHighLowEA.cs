using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace MLEA
{
    public class ZigzagHighLowEA : AbstractEA
    {
        public ZigzagHighLowEA()
        {
            for (int i = 0; i < 2 * m_length; ++i)
            {
                m_patterModel += "0";
            }
            m_simulator = new RateSimulator(this);
        }

        private static double m_highLowDelta = 0.0005;
        private double sl = 35;
        private double tp = 70;

        private const int m_length = 5;
        private const int m_zigzagLength = 2 * m_length;
        private string m_patterModel;

        private RateSimulator m_simulator;

        public void GenerateHighLowEveryRate()
        {
            Dictionary<long, List<int>> patterns = new Dictionary<long, List<int>>();

            Dictionary<long, List<double[]>> patternsValue = new Dictionary<long, List<double[]>>();
            List<double> zigzagValues = new List<double>();
            for (int i = 0; i < m_simulator.Rates.Count; ++i)
            {
                zigzagValues.Add(m_simulator.Rates[i].close);

                long p = GetHighLowPatternLast(zigzagValues, m_length);
                if (p != -1)
                {
                    GetHighLowPatternLast(zigzagValues, m_length);
                    if (!patterns.ContainsKey(p))
                    {
                        patterns[p] = new List<int>();
                        patternsValue[p] = new List<double[]>();
                    }
                    patterns[p].Add(i);
                    patternsValue[p].Add(new double[m_zigzagLength]);

                    for (int j = 0; j < patternsValue[p][patternsValue[p].Count - 1].Length; ++j)
                    {
                        patternsValue[p][patternsValue[p].Count - 1][j] = zigzagValues[zigzagValues.Count - patternsValue[p][patternsValue[p].Count - 1].Length + j];
                    }
                }

                zigzagValues.RemoveAt(zigzagValues.Count - 1);

                if (m_simulator.Rates[i].zigzag != 0)
                {
                    zigzagValues.Add(m_simulator.Rates[i].zigzag);
                }

                if (zigzagValues.Count > 50)
                {
                    zigzagValues.RemoveAt(0);
                }
            }

            foreach (KeyValuePair<long, List<int>> kvp in patterns)
            {
                if (kvp.Value.Count == 1)
                    continue;

                int[] m = kvp.Value.ToArray();

                //GenerateExcel("c:\\forex\\highLowLikeExcel\\zigzag.cvs." + kvp.Key.ToString(m_patterModel), m, patternsValue[kvp.Key]);
            }

        }

        public void GenerateHighLow()
        {
            Dictionary<long, List<int>> patterns = new Dictionary<long, List<int>>();

            long[] p = GetHighLowPatterns(this.ZigzagValues, m_length);
            for (int i = 0; i < p.Length; ++i)
            {
                long n = p[i];
                if (n == -1)
                    continue;

                if (!patterns.ContainsKey(n))
                    patterns[n] = new List<int>();
                patterns[n].Add(i);
            }

            foreach (KeyValuePair<long, List<int>> kvp in patterns)
            {
                if (kvp.Value.Count == 1)
                    continue;

                int[] m = kvp.Value.ToArray();

                //GenerateExcel("c:\\forex\\highLowLikeExcel\\zigzag.cvs." + kvp.Key.ToString(m_patterModel), m, 2 * m_length);
            }
        }

        public void GenerateHighLowAction()
        {
            using (StreamWriter sw = new StreamWriter("c:\\forex\\highLowAction.txt"))
            {
                foreach (string fileName in Directory.GetFiles("c:\\forex\\highLowLikeExcel"))
                {
                    string pattern = fileName.Substring(fileName.LastIndexOf('.') + 1);

                    List<List<int>> data = new List<List<int>>();

                    int n = 0;
                    using (StreamReader sr = new StreamReader(fileName))
                    {
                        while (true)
                        {
                            string s = sr.ReadLine();
                            if (string.IsNullOrEmpty(s))
                                break;

                            if (n > m_zigzagLength)
                            {
                                string[] ss = s.Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);
                                List<int> l = new List<int>();
                                foreach (string sss in ss)
                                {
                                    l.Add(Convert.ToInt32(sss));
                                }
                                data.Add(l);
                            }

                            n++;
                        }
                    }

                    int p1 = 0, p2 = 0;
                    for (int i = 0; i < data[0].Count; ++i)
                    {
                        for (int j = 0; j < data.Count; ++j)
                        {
                            if (data[j][i] - data[0][i] >= tp + this.Spread)
                            {
                                p1 += 2;
                                break;
                            }
                            if (data[j][i] - data[0][i] <= -sl + this.Spread)
                            {
                                p1 -= 1;
                                break;
                            }
                        }

                        for (int j = 0; j < data.Count; ++j)
                        {
                            if (data[j][i] - data[0][i] <= -tp - this.Spread)
                            {
                                p2 += 2;
                                break;
                            }
                            if (data[j][i] - data[0][i] >= sl - this.Spread)
                            {
                                p2 -= 1;
                                break;
                            }
                        }
                    }

                    if (p1 > 0 && p2 <= 0)
                        sw.WriteLine(string.Format("{0}\tBuy\t{1}\t{2}\t{3}", pattern, p1, p2, data[0].Count));
                    else if (p1 <= 0 && p2 > 0)
                        sw.WriteLine(string.Format("{0}\tSell\t{1}\t{2}\t{3}", pattern, p1, p2, data[0].Count));
                    else if (p1 <= 0 && p2 <= 0)
                        sw.WriteLine(string.Format("{0}\tQuit\t{1}\t{2}\t{3}", pattern, p1, p2, data[0].Count));
                    else
                        sw.WriteLine(string.Format("{0}\tHold\t{1}\t{2}\t{3}", pattern, p1, p2, data[0].Count));
                }
            }
        }

        private static long GetHighLowPatternLast(IList<double> zigzagValues, int length)
        {
            int start = zigzagValues.Count - 2 * length - 2;
            if (start < 0)
                return -1;

            bool firstHigh = true;
            if (zigzagValues[start] < zigzagValues[start + 1])
                firstHigh = false;

            int highStart = firstHigh ? start : start + 1;
            int[] highLowCount = new int[zigzagValues.Count];
            for (int i = highStart; i < zigzagValues.Count; i += 2)
            {
                int n = 0;
                for (int j = i - 2; j >= 0; j -= 2)
                {
                    if (zigzagValues[i] >= zigzagValues[j] + m_highLowDelta)
                        n++;
                    else
                        break;
                }
                if (n >= 10)
                    n = 9;

                highLowCount[i] = n;
            }

            int lowStart = firstHigh ? start + 1 : start;
            for (int i = lowStart; i < zigzagValues.Count; i += 2)
            {
                int n = 0;
                for (int j = i - 2; j >= 0; j -= 2)
                {
                    if (zigzagValues[i] <= zigzagValues[j] - m_highLowDelta)
                        n++;
                    else
                        break;
                }
                if (n >= 10)
                    n = 9;

                highLowCount[i] = n;
            }

            long ret = 0;
            {
                int i = 2 * length + highStart;

                long n = 0;
                for (int j = 0; j < length; ++j)
                {
                    n += highLowCount[i - 2 * j] * (int)Math.Pow(10, length - j - 1);
                }

                n *= 100000;
                for (int j = 0; j < length; ++j)
                {
                    n += highLowCount[i - 2 * j - 1] * (int)Math.Pow(10, length - j - 1);
                }
                ret = n;
            }
            return ret;
        }

        private static long[] GetHighLowPatterns(IList<double> zigzagValues, int length)
        {
            bool firstHigh = true;
            if (zigzagValues[0] < zigzagValues[1])
                firstHigh = false;

            int highStart = firstHigh ? 0 : 1;
            int[] highLowCount = new int[zigzagValues.Count];
            for (int i = highStart; i < zigzagValues.Count; i += 2)
            {
                int n = 0;
                for (int j = i - 2; j >= 0; j -= 2)
                {
                    if (zigzagValues[i] >= zigzagValues[j] + m_highLowDelta)
                        n++;
                    else
                        break;
                }
                if (n >= 10)
                    n = 9;

                highLowCount[i] = n;
            }

            int lowStart = firstHigh ? 1 : 0;
            for (int i = lowStart; i < zigzagValues.Count; i += 2)
            {
                int n = 0;
                for (int j = i - 2; j >= 0; j -= 2)
                {
                    if (zigzagValues[i] <= zigzagValues[j] - m_highLowDelta)
                        n++;
                    else
                        break;
                }
                if (n >= 10)
                    n = 9;

                highLowCount[i] = n;
            }

            long[] ret = new long[zigzagValues.Count];
            for (int i = 0; i < 2 * length + highStart; ++i)
                ret[i] = -1;

            for (int i = 2 * length + highStart; i < highLowCount.Length; i += 2)
            {
                long n = 0;
                for (int j = 0; j < length; ++j)
                {
                    n += highLowCount[i - 2 * j] * (int)Math.Pow(10, length - j - 1);
                }

                n *= (int)Math.Pow(10, length);
                for (int j = 0; j < length; ++j)
                {
                    n += highLowCount[i - 2 * j - 1] * (int)Math.Pow(10, length - j - 1);
                }

                ret[i] = n;
            }
            return ret;
        }

        public void GenerateOrderByHighLowAction()
        {
            Dictionary<string, string> patterns = new Dictionary<string, string>();
            Dictionary<string, string> patternsInfo = new Dictionary<string, string>();

            {
                int n = 0;
                using (StreamReader sr = new StreamReader("c:\\forex\\highLowAction.txt"))
                {
                    while (true)
                    {
                        string s = sr.ReadLine();
                        if (string.IsNullOrEmpty(s))
                            break;

                        string[] ss = s.Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);
                        patterns[ss[0]] = ss[1];
                        patternsInfo[ss[0]] = ss[2] + ", " + ss[3] + ", " + ss[4];
                        n++;
                    }
                }
            }

            using (StreamWriter sw = new StreamWriter("c:\\forex\\ea_order.txt"))
            {
                List<double> zigzagValues = new List<double>();
                for (int i = 0; i < m_simulator.Rates.Count; ++i)
                {
                    zigzagValues.Add(m_simulator.Rates[i].close);

                    long p = GetHighLowPatternLast(zigzagValues, m_length);
                    if (p != -1 && p != 0)
                    {
                        string ac = p.ToString(m_patterModel);
                        if (patterns.ContainsKey(ac))
                        {
                            sw.WriteLine(string.Format("{0}, {1}, {2}", patterns[ac], m_simulator.Rates[i].time.ToString("yyyy.MM.dd HH:mm"), patternsInfo[ac]));
                        }
                    }

                    zigzagValues.RemoveAt(zigzagValues.Count - 1);

                    if (m_simulator.Rates[i].zigzag != 0)
                    {
                        zigzagValues.Add(m_simulator.Rates[i].zigzag);
                    }
                }
            }

            //long[] p = GetHighLowPatterns(this.ZigzagValues, this.m_length);

            //using (StreamWriter sw = new StreamWriter("c:\\forex\\ea_order.txt"))
            //{
            //    for (int i = 0; i < p.Length; ++i)
            //    {
            //        if (p[i] == -1 && p[i] == 0)
            //            continue;

            //        string ac = p[i].ToString(m_patterModel);

            //        if (ac != m_patterModel && patterns.ContainsKey(ac))
            //        {
            //            string action = patterns[ac];

            //            //if (patternsInfo[ac] == "748, -4584, 22393")
            //            //{
            //            //}
            //            sw.WriteLine(string.Format("{0}, {1}, {2}", action, this.Rates[this.ZigzagToRatePos[i]].time.ToString("yyyy.MM.dd HH:mm"), patternsInfo[ac] + "," + ac));
            //        }
            //    }
            //}
        }
    }
}
