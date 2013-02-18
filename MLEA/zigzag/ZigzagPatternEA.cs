using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace MLEA
{
    public class ZigzagPatternEA : AbstractEA
    {
        private int m_length = 3;

        public void LoadPatternAndGenerateSimilar()
        {
            Dictionary<string, List<string>> dictHigh = new Dictionary<string, List<string>>();
            Dictionary<string, List<string>> dictLow = new Dictionary<string, List<string>>();

            using (StreamReader sr = new StreamReader("c:\\forex\\ZigzagPatterns.txt"))
            {
                string s1 = null;
                string s = null;
                while (true)
                {
                    if (string.IsNullOrEmpty(s1))
                    {
                        s  = sr.ReadLine();
                        if (string.IsNullOrEmpty(s))
                            break;
                    }
                    else
                    {
                        s = s1;
                    }
                    string[] ss = s.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

                    string a = ss[1].Substring(0, m_length);

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
                        string a1 = ss1[1].Substring(0, m_length);
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

            TryCreateDirectory("c:\\forex\\patternSimilar\\High\\");
            foreach (var key in dictHigh)
            {
                using (StreamWriter sw = new StreamWriter("c:\\forex\\patternSimilar\\High\\" + key.Key.ToString() + ".txt"))
                {
                    foreach (var i in key.Value)
                    {
                        sw.WriteLine(i);
                    }
                }
            }


            using (StreamReader sr = new StreamReader("c:\\forex\\ZigzagPatterns.txt"))
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

                    string b = ss[1].Substring(ss[1].Length / 2, m_length);

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
                        string b1 = ss1[1].Substring(ss[1].Length / 2, m_length);
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
            TryCreateDirectory("c:\\forex\\patternSimilar\\Low\\");
            foreach (var key in dictLow)
            {
                using (StreamWriter sw = new StreamWriter("c:\\forex\\patternSimilar\\Low\\" + key.Key.ToString() + ".txt"))
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
            double actionDelta = 0.0010;
            using (StreamWriter sw = new StreamWriter("c:\\forex\\zigzagPatternAction.txt"))
            {
                foreach (string fileName in Directory.GetFiles("c:\\forex\\patternSimilar\\High"))
                {
                    string shortFileName = System.IO.Path.GetFileNameWithoutExtension(fileName);

                    using (StreamReader sr = new StreamReader(fileName))
                    {
                        double allDelta = 0;
                        int deltaCnt = 0;
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

                            if (Convert.ToDateTime(ss1[0]) > Parameters.TrainEndTime
                                || Convert.ToDateTime(ss2[0]) > Parameters.TrainEndTime)
                                continue;

                            double delta = Convert.ToDouble(ss2[2]) - Convert.ToDouble(ss1[2]);
                            if (Math.Abs(delta) > actionDelta)
                            {
                                allDelta += Math.Sign(delta);
                                deltaCnt ++;
                            }
                            allCnt++;
                        }

                        //if (allDelta > 0)
                        //{
                            sw.WriteLine(string.Format("{0}\tBuy\t{1}\t{2}", shortFileName.Trim(), (int)(allDelta * 1), deltaCnt, allCnt));
                        //}
                        //else if(allDelta < -0)
                        //{
                        //    sw.WriteLine(string.Format("{0}\tSell\t{1}\t{2}", shortFileName.Trim(), (int)(allDelta * 1), deltaCnt, allCnt));
                        //}
                    }
                }

                foreach (string fileName in Directory.GetFiles("c:\\forex\\patternSimilar\\Low"))
                {
                    string shortFileName = System.IO.Path.GetFileNameWithoutExtension(fileName);

                    using (StreamReader sr = new StreamReader(fileName))
                    {
                        double allDelta = 0;
                        int deltaCnt = 0;
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

                            if (Convert.ToDateTime(ss1[0]) > Parameters.TrainEndTime
                                || Convert.ToDateTime(ss2[0]) > Parameters.TrainEndTime)
                                continue;

                            double delta = Convert.ToDouble(ss2[2]) - Convert.ToDouble(ss1[2]);
                            if (Math.Abs(delta) > actionDelta)
                            {
                                allDelta += -Math.Sign(delta);
                                deltaCnt++;
                            }
                            allCnt++;
                        }

                        //if (allDelta > 0)
                        //{
                        //    sw.WriteLine(string.Format("{0}\tBuy\t{1}\t{2}", shortFileName.Trim(), (int)(allDelta * 1), deltaCnt, allCnt));
                        //}
                        //if (allDelta < -0)
                        //{
                            sw.WriteLine(string.Format("{0}\tSell\t{1}\t{2}", shortFileName.Trim(), (int)(allDelta * 1), deltaCnt, allCnt));
                        //}
                    }
                }
            }
        }
    }
}
