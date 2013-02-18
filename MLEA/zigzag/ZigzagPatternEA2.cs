using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace MLEA
{
    public class ZigzagPatternEA2 : AbstractEA
    {
        public void LoadPatternAndGenerateSimilar()
        {
            Dictionary<string, List<string>> dictHigh = new Dictionary<string, List<string>>();
            Dictionary<string, List<string>> dictLow = new Dictionary<string, List<string>>();

            using (StreamReader sr = new StreamReader("c:\\forex\\ZigzagPatterns_M1.txt"))
            {
                string s1 = null;
                string s = null;
                while (true)
                {
                    if (string.IsNullOrEmpty(s1))
                    {
                        s = sr.ReadLine();
                        if (string.IsNullOrEmpty(s))
                            break;
                    }
                    else
                    {
                        s = s1;
                    }
                    string[] ss = s.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

                    string a = ss[1];

                    if (!dictHigh.ContainsKey(a))
                    {
                        dictHigh[a] = new List<string>();
                    }
                    dictHigh[a].Add(s);

                    // find next pattern
                    while (true)
                    {
                        s1 = sr.ReadLine();
                        if (string.IsNullOrEmpty(s1))
                            break;
                        string[] ss1 = s1.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                        string a1 = ss1[1];
                        if (a1 == a)
                        {
                            s1 = null;
                            continue;
                        }
                        else
                        {
                            break;
                        }
                    }
                    if (string.IsNullOrEmpty(s1))
                        break;

                    dictHigh[a].Add(s1);
                }
            }

            TryCreateDirectory("c:\\forex\\patternSimilar2\\High\\");
            foreach (var key in dictHigh)
            {
                using (StreamWriter sw = new StreamWriter("c:\\forex\\patternSimilar2\\High\\" + key.Key.ToString() + ".txt"))
                {
                    foreach (var i in key.Value)
                    {
                        sw.WriteLine(i);
                    }
                }
            }


            using (StreamReader sr = new StreamReader("c:\\forex\\ZigzagPatterns_M1.txt"))
            {
                string s1 = null;
                string s = null;
                while (true)
                {
                    if (string.IsNullOrEmpty(s1))
                    {
                        s = sr.ReadLine();
                        if (string.IsNullOrEmpty(s))
                            break;
                    }
                    else
                    {
                        s = s1;
                    }
                    string[] ss = s.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

                    string b = ss[2];

                    if (!dictLow.ContainsKey(b))
                    {
                        dictLow[b] = new List<string>();
                    }
                    dictLow[b].Add(s);

                    // find next pattern
                    while (true)
                    {
                        s1 = sr.ReadLine();
                        if (string.IsNullOrEmpty(s1))
                            break;
                        string[] ss1 = s1.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                        string b1 = ss1[2];
                        if (b1 == b)
                        {
                            s1 = null;
                            continue;
                        }
                        else
                        {
                            break;
                        }
                    }
                    if (string.IsNullOrEmpty(s1))
                        break;

                    dictLow[b].Add(s1);
                }
            }
            TryCreateDirectory("c:\\forex\\patternSimilar2\\Low\\");
            foreach (var key in dictLow)
            {
                using (StreamWriter sw = new StreamWriter("c:\\forex\\patternSimilar2\\Low\\" + key.Key.ToString() + ".txt"))
                {
                    foreach (var i in key.Value)
                    {
                        sw.WriteLine(i);
                    }
                }
            }
        }

        public void FindPatternAction()
        {
            using (StreamWriter sw = new StreamWriter("c:\\forex\\zigzagPattern2High.txt"))
            {
                foreach (string fileName in Directory.GetFiles("c:\\forex\\patternSimilar2\\High"))
                {
                    string shortFileName = System.IO.Path.GetFileNameWithoutExtension(fileName);

                    Dictionary<string, int> dict = new Dictionary<string, int>();
                    Dictionary<string, double> dict2 = new Dictionary<string, double>();

                    using (StreamReader sr = new StreamReader(fileName))
                    {
                        int allCnt = 0;
                        while (true)
                        {
                            string s1 = sr.ReadLine();
                            if (string.IsNullOrEmpty(s1))
                                break;
                            string s2 = sr.ReadLine();
                            if (string.IsNullOrEmpty(s2))
                                break;

                            string[] ss1 = s1.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                            string[] ss2 = s2.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

                            //if (Convert.ToDateTime(ss1[0]) > Parameters.TrainEndTime
                            //    || Convert.ToDateTime(ss2[0]) > Parameters.TrainEndTime)
                            //    continue;

                            string nextPattern = ss1[1] + "," + ss2[1];
                            if (!dict.ContainsKey(nextPattern))
                            {
                                dict[nextPattern] = 0;
                                dict2[nextPattern] = 0;
                            }
                            dict[nextPattern]++;
                            dict2[nextPattern] += Convert.ToDouble(ss2[3]) - Convert.ToDouble(ss1[3]);

                            allCnt++;
                        }

                        foreach (var key in dict)
                        {
                            sw.WriteLine(key.Key + "\t" + key.Value + "\t" + allCnt + "\t" + dict2[key.Key]);
                        }
                    }
                }
            }
             using (StreamWriter sw = new StreamWriter("c:\\forex\\zigzagPattern2Low.txt"))
             {
                foreach (string fileName in Directory.GetFiles("c:\\forex\\patternSimilar2\\Low"))
                {
                    string shortFileName = System.IO.Path.GetFileNameWithoutExtension(fileName);

                    Dictionary<string, int> dict = new Dictionary<string, int>();
                    Dictionary<string, double> dict2 = new Dictionary<string, double>();

                    using (StreamReader sr = new StreamReader(fileName))
                    {
                        int allCnt = 0;
                        while (true)
                        {
                            string s1 = sr.ReadLine();
                            if (string.IsNullOrEmpty(s1))
                                break;
                            string s2 = sr.ReadLine();
                            if (string.IsNullOrEmpty(s2))
                                break;

                            string[] ss1 = s1.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                            string[] ss2 = s2.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

                            //if (Convert.ToDateTime(ss1[0]) > Parameters.TrainEndTime
                            //    || Convert.ToDateTime(ss2[0]) > Parameters.TrainEndTime)
                            //    continue;

                            string nextPattern = ss1[1] + "," + ss2[1];
                            if (!dict.ContainsKey(nextPattern))
                            {
                                dict[nextPattern] = 0;
                                dict2[nextPattern] = 0;
                            }
                            dict[nextPattern]++;
                            dict2[nextPattern] += Convert.ToDouble(ss2[3]) - Convert.ToDouble(ss1[3]);

                            allCnt++;
                        }

                        foreach (var key in dict)
                        {
                            sw.WriteLine(key.Key + "\t" + key.Value + "\t" + allCnt + "\t" + dict2[key.Key]);
                        }
                    }
                }
            }
        }

        public void FindPatternAction2()
        {
            using (StreamReader sr = new StreamReader("c:\\forex\\zigzagPattern2High.txt"))
            {
                SortedDictionary<int, double> dict = new SortedDictionary<int, double>();
                Dictionary<int, int> dict2 = new Dictionary<int, int>();
                while (true)
                {
                    string s1 = sr.ReadLine();
                    if (string.IsNullOrEmpty(s1))
                        break;
                    string[] ss1 = s1.Split(new char[] { '\t', ',' }, StringSplitOptions.RemoveEmptyEntries);
                    int key = Convert.ToInt32(ss1[0]);
                    if (!dict.ContainsKey(key))
                    {
                        dict[key] = 0;
                        dict2[key] = 0;
                    }
                    dict[key] += Convert.ToDouble(ss1[4]);
                    dict2[key] += Convert.ToInt32(ss1[2]);
                }

                using (StreamWriter sw = new StreamWriter("c:\\forex\\zigzagPattern2HighSum.txt"))
                {
                    foreach (var kvp in dict)
                    {
                        sw.WriteLine(kvp.Key + "\t" + kvp.Value + "\t" + kvp.Value / dict2[kvp.Key]);
                    }
                }
            }

            using (StreamReader sr = new StreamReader("c:\\forex\\zigzagPattern2Low.txt"))
            {
                SortedDictionary<int, double> dict = new SortedDictionary<int, double>();
                Dictionary<int, int> dict2 = new Dictionary<int, int>();
                while (true)
                {
                    string s1 = sr.ReadLine();
                    if (string.IsNullOrEmpty(s1))
                        break;
                    string[] ss1 = s1.Split(new char[] { '\t', ',' }, StringSplitOptions.RemoveEmptyEntries);
                    int key = Convert.ToInt32(ss1[0]);
                    if (!dict.ContainsKey(key))
                    {
                        dict[key] = 0;
                        dict2[key] = 0;
                    }
                    dict[key] += Convert.ToDouble(ss1[4]);
                    dict2[key] += Convert.ToInt32(ss1[2]);
                }

                using (StreamWriter sw = new StreamWriter("c:\\forex\\zigzagPattern2LowSum.txt"))
                {
                    foreach (var kvp in dict)
                    {
                        sw.WriteLine(kvp.Key + "\t" + kvp.Value + "\t" + kvp.Value / dict2[kvp.Key]);
                    }
                }
            }
        }
    }
}
