using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace MLEA
{
    public static class MTReportAnalyze
    {
        public static void GetMtReportBalance(string inputFile, string outputFile)
        {
            DateTime dtStart = new DateTime(2000, 1, 1);
            int v = 0;
            using (StreamReader sr = new StreamReader(inputFile))
            using (StreamWriter sw = new StreamWriter(outputFile))
            {
                DateTime currentDate = dtStart;
                while (true)
                {
                    if (sr.EndOfStream)
                        break;
                    if (currentDate > System.DateTime.Now)
                        break;

                    string s = sr.ReadLine().Trim();
                    if (string.IsNullOrEmpty(s))
                        continue;

                    System.Text.RegularExpressions.Regex r = new System.Text.RegularExpressions.Regex(
                        "<tr bgcolor=\"(#F7F7F7|#FFFFFF)\" align=right><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td colspan=\"2\">(.*?)</td><td>(.*?)</td><td>(.*?)</td><td colspan=\"2\">(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td></tr>");
                    var match = r.Match(s);
                    if (match.Success)
                    {
                        currentDate = Convert.ToDateTime(match.Groups[2].Value);
                        double balance = Convert.ToDouble(match.Groups[13].Value.Replace(" ", ""));
                        string inout = match.Groups[6].Value;
                        if (inout == "in")
                            v++;
                        else if (inout == "out")
                            v--;
                        else
                            throw new AssertException("invalid inout type.");
                        sw.WriteLine(string.Format("{0}, {1}, {2}", currentDate.ToString(Parameters.DateTimeFormat), balance.ToString(Parameters.DoubleFormatString), v));
                    }
                }
            }
        }

        [Serializable]
        public class MtReportDeal
        {
            public DateTime Time;
            public int Deal;
            public int Order;
            public string Symbol;
            public string Type;
            public string Direction;
            public double Volume;
            public double Price;
            public double Commission;
            public double Swap;
            public double Profit;
            public double Balance;
            public string Comment;
            public int CorrespondDeal;
        }

        public static Dictionary<int, MtReportDeal> ParseMtReport(string inputFile)
        {
            Dictionary<int, MtReportDeal> ret = new Dictionary<int, MtReportDeal>();
            DateTime currentDate = new DateTime(2009, 1, 1);
            string startDealString = "<th colspan=\"13\" style=\"height: 25px\"><div style=\"font: 10pt Tahoma\"><b>Deals</b></div></th>";
            bool startDeal = false;
            System.Text.RegularExpressions.Regex r = new System.Text.RegularExpressions.Regex(
                "^<tr bgcolor=\"(#F7F7F7|#FFFFFF)\" align=right>(.*?)</tr>$",
                System.Text.RegularExpressions.RegexOptions.Compiled);
            // <td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td>
            System.Text.RegularExpressions.Match match = null;
            using (StreamReader sr = new StreamReader(inputFile))
            {
                while (true)
                {
                    if (sr.EndOfStream)
                        break;
                    if (currentDate > System.DateTime.Now)
                        break;

                    string s = sr.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        continue;
                    if (!startDeal)
                    {
                        startDeal = s.Contains(startDealString);
                        if (!startDeal)
                            continue;
                    }
                    //if (match == null || !match.Success)
                    match = r.Match(s.Trim());
                    if (match.Success)
                    {
                        try
                        {
                            MtReportDeal i = new MtReportDeal();

                            string con = match.Groups[2].Value;
                            string[] ss = con.Split(new string[] { "<td>", "</td>" }, StringSplitOptions.RemoveEmptyEntries);
                            if (ss.Length != 13)
                                continue;

                            i.Time = Convert.ToDateTime(ss[0]);
                            i.Deal = Convert.ToInt32(ss[1].Replace(" ", ""));
                            i.Symbol = ss[2].Replace(" ", "");
                            i.Type = ss[3].Replace(" ", "");
                            if (i.Type == "balance")
                                continue;
                            i.Direction = ss[4].Replace(" ", "");
                            i.Volume = Convert.ToDouble(ss[5].Replace(" ", ""));
                            i.Price = Convert.ToDouble(ss[6].Replace(" ", ""));
                            i.Order = Convert.ToInt32(ss[7].Replace(" ", ""));
                            i.Commission = Convert.ToDouble(ss[8].Replace(" ", ""));
                            i.Swap = Convert.ToDouble(ss[9].Replace(" ", ""));
                            i.Profit = Convert.ToDouble(ss[10].Replace(" ", ""));
                            i.Balance = Convert.ToDouble(ss[11].Replace(" ", ""));
                            i.Comment = ss[12].Replace(" ", "");

                            ret[i.Deal] = i;

                            string[] ss2 = i.Comment.Split(':');
                            if (ss2.Length == 3)
                            {
                                i.CorrespondDeal = Convert.ToInt32(ss2[2]);
                                ret[i.CorrespondDeal].CorrespondDeal = i.Deal;
                            }
                            else if (ss2.Length == 2)
                            {
                            }
                            else
                                throw new AssertException("ss2's Length is invalid.");
                        }
                        catch (Exception)
                        {
                        }
                    }
                }
            }
            return ret;
        }

        public static void ParseMtReport4Consecutive()
        {
            Dictionary<int, MtReportDeal> list;
            string serializeFile = "d:\\ReportTester.ser";
            if (!System.IO.File.Exists(serializeFile))
            {
                list = ParseMtReport("d:\\ReportTester-1030021.html");
                //Feng.Utils.SerializeHelper.Serialize(serializeFile, list);
            }
            else
            {
                list = Feng.Windows.Utils.SerializeHelper.Deserialize<Dictionary<int, MtReportDeal>>(serializeFile);
            }

            double p = 0;
            foreach (var i in list.Values)
            {
                p += i.Profit + i.Swap + i.Commission;
                WekaUtils.DebugAssert(Math.Abs(p + 100000 - i.Balance) < 0.001, "Math.Abs(p + 100000 - i.Balance) < 0.001");
            }

            p = 0;
            bool trade = true;

            Dictionary<int, int> noDeals = new Dictionary<int, int>();
            foreach (var kvp in list)
            {
                if (kvp.Key > kvp.Value.CorrespondDeal)
                {
                    if (kvp.Value.Comment.StartsWith("OrTxt:sl:"))
                        trade = false;
                    else if (kvp.Value.Comment.StartsWith("OrTxt:tp:"))
                        trade = true;

                    if (noDeals.ContainsKey(kvp.Value.CorrespondDeal))
                        continue;

                    if (kvp.Value.Type == "buy")
                    {
                        p += (list[kvp.Value.CorrespondDeal].Price - kvp.Value.Price) * 1000;
                    }
                    else if (kvp.Value.Type == "sell")
                    {
                        p += (-list[kvp.Value.CorrespondDeal].Price + kvp.Value.Price) * 1000;
                    }
                    continue;
                }
                if (trade)
                {
                }
                else
                {
                    noDeals.Add(kvp.Key, kvp.Key);
                }
            }
            double pc = 0;
            foreach (var i in list.Values)
            {
                pc += i.Swap + i.Commission;
            }
            p += pc;
        }
    }
}
