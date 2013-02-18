using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace MLEA
{
    public class ZigzagPatternEA3 : AbstractEA
    {
        public ZigzagPatternEA3()
        {
            m_simulator = new TickSimulator(this); //new RateSimulator()
        }
        public override void OnLoad()
        {
            m_simulator.OnLoad();
            base.OnLoad();
        }

        public override void OnUnload()
        {
            m_simulator.OnUnload();
            base.OnUnload();
        }

        private ISimulator m_simulator;

        public void GeneratePatternSimi2(int tp, int sl, bool isBuy)
        {
            Dictionary<string, List<string>> dict = new Dictionary<string, List<string>>();
            using (StreamReader sr = new StreamReader(base.GetResultPath(string.Format("Pattern3Detail{0}-{1}-{2}.txt", tp, sl, isBuy))))
            {
                string s = null;
                while (true)
                {
                    s = sr.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        break;

                    string[] ss = s.Split(new char[] { '\t' });
                    if (!dict.ContainsKey(ss[1]))
                        dict[ss[1]] = new List<string>();
                    dict[ss[1]].Add(s);
                }
            }

            Dictionary<string, List<double>> ret = new Dictionary<string, List<double>>();
            foreach (var kvp in dict)
            {
                List<double> prob = new List<double>();
                int ta = 0, tb = 0;
                int win = 0, lose = 0;
                double t1 = tb != 0 ? (double)ta / tb : 1;
                foreach (var s in kvp.Value)
                {
                    string[] ss = s.Split(new char[] { '\t' });
                    if ((tb == 0 && ta > 1) || (t1 > ProbLimit)
                        && ta + tb > CountLimit)
                    {
                        if (ss[4] == "True")
                            win++;
                        else
                            lose++;

                        prob.Add((double)win / (win + lose));
                    }

                    if (ss[4] == "True")
                        ta++;
                    else
                        tb++;
                }

                ret[kvp.Key] = prob;
            }

            using (StreamWriter sw = new StreamWriter(base.GetResultPath(string.Format("Pattern3SumProb{0}-{1}-{2}.txt", tp, sl, isBuy))))
            {
                for (int i = 0; i < 10000; ++i)
                {
                    bool writeOne = false;
                    foreach (var kvp in ret)
                    {
                        if (kvp.Key == "H,0,0" || kvp.Key == "L,0,0")
                            continue;

                        if (i == 0)
                        {
                            sw.Write(kvp.Key);
                            writeOne = true;
                        }
                        else
                        {
                            if (i - 1 < kvp.Value.Count)
                            {
                                sw.Write(kvp.Value[i - 1].ToString("N2"));
                                writeOne = true;
                            }
                            else
                            {
                                sw.Write(" ");
                            }
                        }
                        sw.Write("\t");
                    }
                    if (!writeOne)
                        break;
                    sw.WriteLine();
                }
            }
        }

        public void GeneratePatternSimi()
        {
            Dictionary<string, List<int>> dict = new Dictionary<string, List<int>>();
            List<string> patterns = new List<string>();
            using (StreamReader sr = new StreamReader(base.GetDataPath(string.Format("ZigzagPatterns.txt"))))
            {
                string s = null;
                while (true)
                {
                    s = sr.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        break;

                    patterns.Add(s);

                    string[] ss = s.Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);
                    if (!dict.ContainsKey(ss[1]))
                        dict[ss[1]] = new List<int>();
                    dict[ss[1]].Add(patterns.Count - 1);
                }
            }

            foreach (var kvp in dict)
            {
                using (StreamWriter sw = new StreamWriter(base.GetResultPath("Pattern_" + kvp.Key + ".txt")))
                {
                    for (int j = 0; j < 15; ++j)
                    {
                        StringBuilder sb1 = new StringBuilder();
                        StringBuilder sb2 = new StringBuilder();
                        StringBuilder sb3 = new StringBuilder();
                        foreach (var i in kvp.Value)
                        {
                            if (i + j < patterns.Count)
                            {
                                string[] ss0 = patterns[i].Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);
                                string[] ss = patterns[i + j].Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);
                                sb1.Append(ss[0]);
                                sb2.Append(ss[1]);
                                sb3.Append((Convert.ToDouble(ss[2]) - Convert.ToDouble(ss0[2])).ToString());
                            }
                            else
                            {
                                sb1.Append("None");
                                sb2.Append("None");
                                sb3.Append("0.00");
                            }
                            sb1.Append("\t");
                            sb2.Append("\t");
                            sb3.Append("\t");
                        }
                        sw.Write(sb1.ToString());
                        sw.Write("\t");
                        sw.Write(sb2.ToString());
                        sw.Write("\t");
                        sw.Write(sb3.ToString());
                        sw.WriteLine();
                    }
                }
            }
        }

        public void ConvertDataToMql(int tp, int sl)
        {
            List<String> pattern = new List<string>();
            Dictionary<string, int> dict = new Dictionary<string, int>();
            using (StreamReader sr = new StreamReader(base.GetDataPath(string.Format("ZigzagPatterns.txt"))))
            {
                string s = null;
                while (true)
                {
                    s = sr.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        break;
                    pattern.Add(s);

                    string[] ss = s.Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);
                    dict[ss[0] + "," + Convert.ToDouble(ss[2]).ToString(base.PriceFormat)] = pattern.Count - 1;
                }
            }

            using (StreamReader sr = new StreamReader(base.GetResultPath(string.Format("Pattern3DetailMerge{0}-{1}.txt", tp, sl))))
            using(StreamWriter sw = new StreamWriter(string.Format("d:\\ZigzagPatternData_{0}_{1}.mq5", tp, sl)))
            {
                List<string> list = new List<string>();
                string s = null;
                while (true)
                {
                    s = sr.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        break;

                    list.Add(s);
                }
                sw.WriteLine("string m_historyDealsTxt[] = {");
                for (int i = 0; i < list.Count; ++i)
                {
                    string[] ss = list[i].Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);

                    DateTime openTime = Convert.ToDateTime(ss[3]);
                    if (openTime == DateTime.MaxValue || openTime == DateTime.MinValue)
                        continue;

                    sw.Write("\"");
                    sw.Write(list[i]);
                    
                    int lastIdx = dict[ss[0] + "," + ss[2]] - 1;
                    if (lastIdx < 0)
                    {
                        sw.Write("\t");
                        sw.Write("L,0,0");
                    }
                    else
                    {
                        string last = pattern[lastIdx];
                        string[] ssLast = last.Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);
                        sw.Write("\t");
                        sw.Write(ssLast[1]);
                    }

                    sw.Write("\"");
                    if (i != list.Count - 1)
                        sw.Write(",");
                    sw.WriteLine();
                }

                sw.WriteLine("};");
            }
        }

        public void DoAll(int tp, int sl)
        {
            int bs = 1;
            LoadPatternAndSimulate(tp * bs, sl * bs, true);
            LoadPatternAndSimulate(tp * bs, sl * bs, false);
            MergeDetail(tp * bs, sl * bs);
            ConvertDataToMql(tp * bs, sl * bs);
        }

        public void DoAll()
        {
            
            for (int tp = 20; tp <= 100; tp += 10)
            {
                for (int sl = 10; sl <= 50; sl += 5)
                {
                    //if (tp == 70 && sl == 35)
                    //    continue;

                    DoAll(tp, sl);
                }
            }
        }
        public void LoadPatternAndSimulate(int tp, int sl, bool isBuy)
        {
            Dictionary<string, List<Tuple<DateTime, DateTime, bool?, double, double>>> dict = new Dictionary<string, List<Tuple<DateTime, DateTime, bool?, double, double>>>();

            string lastKey = null;
            using (StreamReader sr = new StreamReader(base.GetDataPath(string.Format("ZigzagPatterns.txt"))))
            {
                string s = null;
                while (true)
                {
                    s = sr.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        break;

                    string[] ss = s.Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);

                    string key = ss[1];
                    if (key == lastKey)
                        continue;

                    if (!dict.ContainsKey(key))
                    {
                        dict[key] = new List<Tuple<DateTime, DateTime, bool?, double, double>>();
                    }
                    DateTime openTime = Convert.ToDateTime(ss[0]);
                    //if (openTime > new DateTime(2009, 12, 31))
                    //    break;

                    double openPrice = Convert.ToDouble(ss[2]);
                    DateTime closeTime;
                    double closePrice;

                    //if (openTime != new DateTime(2000, 01, 03, 12, 55, 0))
                    //    continue;

                    bool? ret = m_simulator.Simulate(openTime, openPrice, isBuy, tp, sl, out closeTime, out closePrice);

                    //if (closeTime > new DateTime(2009, 12, 31))
                    //    continue;

                    dict[key].Add(new Tuple<DateTime, DateTime, bool?, double, double>(openTime, closeTime, ret, openPrice, closePrice));

                    lastKey = key;
                }
            }


            using (StreamWriter sw = new StreamWriter(base.GetResultPath(string.Format("Pattern3Sum{0}-{1}-{2}.txt", tp, sl, isBuy))))
            {
                foreach (var kvp in dict)
                {
                    sw.Write(kvp.Key);
                    sw.Write("\t");

                    int cnt1 = 0, cnt2 = 0, cnt3 = 0;

                    foreach (var i in kvp.Value)
                    {
                        bool? r = i.Item3;
                        if (!r.HasValue)
                            cnt3++;
                        else if (r.Value)
                            cnt1++;
                        else
                            cnt2++;
                    }
                    sw.Write(string.Format("{0}\t{1}\t{2}\t{3}", cnt1, cnt2, cnt3, cnt1 + cnt2 + cnt3));
                    sw.WriteLine();
                }
            }

            using (StreamWriter sw = new StreamWriter(base.GetResultPath(string.Format("Pattern3Detail{0}-{1}-{2}.txt", tp, sl, isBuy))))
            {
                foreach (var kvp in dict)
                {
                    foreach (var i in kvp.Value)
                    {
                        // <DateTime, DateTime, bool?, double, double>
                        sw.WriteLine(string.Format("{0}\t{1}\t{2}\t{3}\t{4}\t{5}", i.Item1.ToString(DateTimeFormat), kvp.Key, i.Item4.ToString(PriceFormat),
                            i.Item2.ToString(DateTimeFormat), (i.Item3.HasValue ? (object)i.Item3.Value : "None"), i.Item5.ToString(PriceFormat)));
                    }
                }
            }
        }

        public void MergeDetail(int tp, int sl)
        {
            List<Tuple<DateTime, string>> dictClose = new List<Tuple<DateTime, string>>();
            List<Tuple<DateTime, string>> dictOpen = new List<Tuple<DateTime, string>>();

            for (int i = 0; i < 2; ++i)
            {
                using (StreamReader sr = new StreamReader(base.GetResultPath(string.Format("Pattern3Detail{0}-{1}-{2}.txt", tp, sl, i == 0))))
                {
                    string s = null;
                    while (true)
                    {
                        s = sr.ReadLine();
                        if (string.IsNullOrEmpty(s))
                            break;

                        string[] ss = s.Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);
                        DateTime closeTime = Convert.ToDateTime(ss[3]);
                        DateTime openTime = Convert.ToDateTime(ss[0]);
                        if (ss[4] == "None")
                            continue;
                        dictClose.Add(new Tuple<DateTime, string>(closeTime, s + "\t" + (i == 0 ? "Buy" : "Sell")));
                        dictOpen.Add(new Tuple<DateTime, string>(openTime, s + "\t" + (i == 0 ? "Buy" : "Sell")));
                    }
                }
            }
            dictClose.Sort(new Comparison<Tuple<DateTime, string>>((x, y) =>
            {
                return x.Item1.CompareTo(y.Item1);
            }));
            dictOpen.Sort(new Comparison<Tuple<DateTime, string>>((x, y) =>
            {
                return x.Item1.CompareTo(y.Item1);
            }));

            using (StreamWriter sw = new StreamWriter(base.GetResultPath(string.Format("Pattern3DetailMerge{0}-{1}.txt", tp, sl))))
            {
                foreach (var i in dictClose)
                {
                    sw.WriteLine(i.Item2);
                }
            }

            {
                int idx = 0;
                using (StreamWriter sw = new StreamWriter(base.GetResultPath(string.Format("Pattern3DetailMerge{0}-{1}-2.txt", tp, sl))))
                {
                    foreach (var i in dictOpen)
                    {
                        string[] ss = i.Item2.Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);
                        if (idx % 2 == 0)
                        {
                            sw.Write(ss[0]);
                            sw.Write("\t");
                            sw.Write(ss[1]);
                            sw.Write("\t");
                            if (ss[4] == "True")
                            {
                                sw.Write(ss[6]);
                                sw.Write("\t");
                                sw.Write(ss[3]);
                                sw.Write("\t");
                            }
                        }
                        else
                        {
                            if (ss[4] == "True")
                            {
                                sw.Write(ss[6]);
                                sw.Write("\t");
                                sw.Write(ss[3]);
                                sw.Write("\t");
                            }
                        }

                        if (idx % 2 == 1)
                            sw.WriteLine();

                        idx++;
                    }
                }
            }

            {
                double[] buyProb = new double[2 * (maxPatternCnt + 1) * (maxPatternCnt + 1) * 2];
                double[] sellProb = new double[2 * (maxPatternCnt + 1) * (maxPatternCnt + 1) * 2];

                using (StreamReader sr = new StreamReader(base.GetResultPath(string.Format("Pattern3DetailMerge{0}-{1}.txt", tp, sl))))
                {
                    string s = null;
                    while (true)
                    {
                        s = sr.ReadLine();
                        if (string.IsNullOrEmpty(s))
                            break;

                        string[] ss = s.Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);
                        if (ss[4] == "None")
                            continue;


                        DateTime closeTime = Convert.ToDateTime(ss[3]);

                        if (closeTime >= new DateTime(2000, 1, 1))
                        {
                            //int i1 = StringSubstr(s1, 0, 1) == "H" ? 0 : 1;
                            //string i2s = StringSubstr(s1, 2, StringSubstr(s1, 3, 1) == "," ? 1 : 2);
                            //string i3s = StringSubstr(s1, 2 + StringLen(i2s) + 1);
                            //int i2 = (int)StringToInteger(i2s);
                            //int i3 = (int)StringToInteger(i3s);
                            //i2 = (int)MathMin(i2, maxPatternCnt - 1);
                            //i3 = (int)MathMin(i3, maxPatternCnt - 1);
                            int i4 = ss[4] == "True" ? 0 : 1;

                            int pii = GetPatternInt(ss[1]);
                            int pi = i4 == 1 ? pii + 1 : pii;

                            //int lastPi = GetPatternInt(ss[7]);
                            //lastPi = 0;

                            if (ss[6] == "Buy")
                            {
                                //buyProb[lastPi0][pi0] *= 1;
                                //buyProb[lastPi0 + 1][pi0 + 1] *= 1;
                                buyProb[pi]++;
                            }
                            else
                            {
                                //sellProb[lastPi0][pi0] *= 1;
                                //sellProb[lastPi0 + 1][pi0 + 1] *= 1;
                                sellProb[pi]++;
                            }
                        }
                    }
                }

                int idx = 0;
                using (StreamWriter sw = new StreamWriter(base.GetResultPath(string.Format("Pattern3DetailMerge{0}-{1}-3.txt", tp, sl))))
                {
                    foreach (var i in dictOpen)
                    {
                        string[] ss = i.Item2.Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);
                        if (idx % 2 == 0)
                        {
                            sw.Write(ss[0]);
                            sw.Write("\t");
                            sw.Write(ss[1]);
                            sw.Write("\t");
                            if (ss[4] == "True")
                            {
                                sw.Write(ss[6]);
                                sw.Write("\t");
                                sw.Write(ss[3]);
                                sw.Write("\t");
                            }
                        }
                        else
                        {
                            if (ss[4] == "True")
                            {
                                sw.Write(ss[6]);
                                sw.Write("\t");
                                sw.Write(ss[3]);
                                sw.Write("\t");
                            }
                        }

                        if (idx % 2 == 1)
                        {
                            string p = ss[1];
                            int pi0 = GetPatternInt(p);
                            double ta = buyProb[pi0];
                            double tb = buyProb[pi0 + 1];
                            double t1 = tb != 0 ? ta / tb : 1;
                            if ((tb == 0 && ta > 1) || (t1 > ProbLimit))
                            {
                                if (ta + tb > CountLimit)
                                {
                                    sw.Write("Buy\t");
                                }
                            }

                            ta = sellProb[pi0];
                            tb = sellProb[pi0 + 1];
                            double t2 = tb != 0 ? ta / tb : 1;
                            if ((tb == 0 && ta > 1) || (t2 > ProbLimit))
                            {
                                if (ta + tb > CountLimit)
                                {
                                    sw.Write("Sell\t");
                                }
                            }

                            sw.WriteLine();
                        }

                        idx++;
                    }
                }
            }

            {
                using (StreamWriter sw = new StreamWriter(base.GetResultPath(string.Format("Pattern3DetailMerge{0}-{1}-4.txt", tp, sl))))
                using (StreamReader sr = new StreamReader(base.GetResultPath(string.Format("Pattern3DetailMerge{0}-{1}-3.txt", tp, sl))))
                {
                    string s = null;
                    while (true)
                    {
                        s = sr.ReadLine();
                        if (string.IsNullOrEmpty(s))
                            break;

                        string[] ss = s.Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);
                        if (ss.Length > 4 && ss[ss.Length - 1].Length <= 4)
                        {
                            sw.WriteLine(s);
                        }
                    }

                }

            }
        }

        int GetPatternInt(int i1, int i2, int i3, int i4)
        {
            return i1 * ((maxPatternCnt + 1) * (maxPatternCnt + 1) * 2) + i2 * ((maxPatternCnt + 1) * 2) + i3 * 2 + i4;
        }
        int maxPatternCnt = 50;
        double ProbLimit = 0.93;
        int CountLimit = 6;
        int GetPatternInt(string p)
        {
            string[] ss = p.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            int ip1 = (int)Convert.ToInt32(ss[1]);
            int ip2 = (int)Convert.ToInt32(ss[2]);

            ip1 = (int)Math.Min(ip1, maxPatternCnt - 1);
            ip2 = (int)Math.Min(ip2, maxPatternCnt - 1);
            int hl = ss[0] == "H" ? 0 : 1;

            return GetPatternInt(hl, ip1, ip2, 0);
        }

        public void ParseSumGetWin(int tp, int sl)
        {
            List<string> conflict = new List<string>();
            var a = ParseSumGetWin(tp, sl, true);
            var b = ParseSumGetWin(tp, sl, false);
            foreach(var i in a)
            {
                if (b.IndexOf(i) != -1)
                {
                    conflict.Add(i);
                }
            }
            using (StreamWriter sw = new StreamWriter(base.GetResultPath(string.Format("Pattern3SumConflict{0}-{1}.txt", tp, sl))))
            {
                foreach (var i in conflict)
                {
                    sw.Write(i);
                    sw.Write(",");
                }
            }
        }

        public List<string> ParseSumGetWin(int tp, int sl, bool isBuy)
        {
            List<string> ret = new List<string>();
            using (StreamReader sr = new StreamReader(base.GetResultPath(string.Format("Pattern3Sum{0}-{1}-{2}.txt", tp, sl, isBuy))))
            {
                string s = null;
                while (true)
                {
                    s = sr.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        break;

                    string[] ss = s.Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);
                    int a = Convert.ToInt32(ss[1]);
                    int b = Convert.ToInt32(ss[2]);
                    if ((b == 0 && a > 1) || ((double)a / b > 0.7))
                    {
                        ret.Add(ss[0]);
                    }
                }
            }
            using (StreamWriter sw = new StreamWriter(base.GetResultPath(string.Format("Pattern3Ret{0}-{1}-{2}.txt", tp, sl, isBuy))))
            {
                foreach (var i in ret)
                {
                    sw.Write(i.Replace("L", "1").Replace("H", "0"));
                    sw.Write(", ");
                }
            }

            return ret;
        }

        public void ReGenerateSum()
        {
            Dictionary<string, List<bool?>> dict = new Dictionary<string, List<bool?>>();

            Dictionary<DateTime, string> dict2 = new Dictionary<DateTime, string>();
            using (StreamReader sr = new StreamReader(base.GetDataPath(string.Format("ZigzagPatterns_{0}.txt", this.Symbol))))
            {
                string s = null;
                while (true)
                {
                    s = sr.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        break;

                    string[] ss = s.Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);
                    dict2[Convert.ToDateTime(ss[0])] = ss[1];
                }
            }

            using (StreamReader sr = new StreamReader(base.GetResultPath(string.Format("Pattern3Detail_{0}.txt", this.Symbol))))
            {
                string s = null;
                while (true)
                {
                    s = sr.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        break;

                    string[] ss = s.Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);
                    DateTime dt = Convert.ToDateTime(ss[1]);
                    //if (Convert.ToDateTime(ss[2]) > new DateTime(2002, 3, 29))
                    //    continue;
                    string key = dict2.ContainsKey(dt) ? dict2[dt] : null;
                    if (!string.IsNullOrEmpty(key))
                    {
                        if (!dict.ContainsKey(key))
                            dict[key] = new List<bool?>();
                        if (ss[3] == "False")
                            dict[key].Add(false);
                        else if (ss[3] == "True")
                            dict[key].Add(true);
                        else
                            dict[key].Add(null);
                    }
                }
            }

            using (StreamWriter sw = new StreamWriter(base.GetResultPath(string.Format("Pattern3Sum3_{0}.txt", this.Symbol))))
            {
                foreach (var kvp in dict)
                {
                    string[] ss = kvp.Key.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

                    sw.Write(ss[0] + ",");
                    sw.Write(Convert.ToInt32(ss[1]).ToString("00") + ",");
                    sw.Write(Convert.ToInt32(ss[2]).ToString("00"));
                    sw.Write("\t");

                    int cnt1 = 0, cnt2 = 0, cnt3 = 0;

                    foreach (var i in kvp.Value)
                    {
                        bool? r = i;
                        if (!r.HasValue)
                            cnt3++;
                        else if (r.Value)
                            cnt1++;
                        else
                            cnt2++;
                    }
                    sw.Write(string.Format("{0}\t{1}\t{2}\t{3}", cnt1, cnt2, cnt3, cnt1 + cnt2 + cnt3));
                    sw.WriteLine();
                }
            }
        }
    }
}
