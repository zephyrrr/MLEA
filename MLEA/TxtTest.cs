using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using weka.core;

namespace MLEA
{
    public class TxtTest
    {
        #region "support"
        
        

        //private static void GetSelectedDeals()
        //{
        //    Dictionary<DateTime, int[,]> selectedDeals = new Dictionary<DateTime, int[,]>();

        //    for (int s = 0; s < symbols.Length; ++s)
        //    {
        //        //int needContinue = 0;
        //        //int nowContinue = 0;
        //        //int nowDealType = -1;
        //        for (int j = 0; j < months.Length; ++j)
        //        {
        //            if (dealsList[s, j] == null)
        //                continue;

        //            foreach (var i in dealsList[s, j])
        //            {
        //                var ccScores = i.Value.Item6;

        //                double[] sum = new double[2];
        //                double[] sumNeg = new double[2];
        //                double[] sumosc = new double[2];
        //                double[] sumosc2 = new double[2];
        //                for (int k = 0; k < 2; ++k)
        //                    for (int tp = 0; tp < tpCount; ++tp)
        //                        for (int sl = 0; sl < slCount; ++sl)
        //                        {
        //                            sum[k] += ccScores[k, tp, sl];

        //                            if (ccScores[k, tp, sl] < 0)
        //                            {
        //                                sumNeg[k] += ccScores[k, tp, sl];
        //                            }
        //                        }

        //                int oscCnt = 0, osc2Cnt = 0;
        //                for (int tp = 0; tp < tpCount; ++tp)
        //                    for (int sl = 0; sl < slCount; ++sl)
        //                    {
        //                        if (ccScores[0, tp, sl] < 0 && ccScores[1, tp, sl] < 0)
        //                        {
        //                            sumosc[0] += ccScores[0, tp, sl];
        //                            sumosc[1] += ccScores[1, tp, sl];

        //                            oscCnt++;
        //                        }
        //                        if (ccScores[0, tp, sl] > 0 && ccScores[1, tp, sl] > 0)
        //                        {
        //                            sumosc2[0] += ccScores[0, tp, sl];
        //                            sumosc2[1] += ccScores[1, tp, sl];
        //                            osc2Cnt++;
        //                        }
        //                    }

        //                int selectedDeal = -1;
        //                //if (sum[0] < sum[1])
        //                //{
        //                //    selectedDeal = 0;
        //                //}
        //                //else if (sum[1] < sum[0])
        //                //{
        //                //    selectedDeal = 1;
        //                //}

        //                if (sum[0] < sum[1] && sum[0] < 0 && sum[1] > 0)
        //                {
        //                    selectedDeal = 0;
        //                }
        //                else if (sum[1] < sum[0] && sum[1] < 0 && sum[0] > 0)
        //                {
        //                    selectedDeal = 1;
        //                }

        //                //if (oscCnt > 100)
        //                //    selectedDeal = -1;
        //                if (!selectedDeals.ContainsKey(i.Key))
        //                {
        //                    selectedDeals[i.Key] = new int[symbols.Length, months.Length];
        //                    for (int ss = 0; ss < symbols.Length; ++ss)
        //                        for (int jj = 0; jj < symbols.Length; ++jj)
        //                            selectedDeals[i.Key][ss, jj] = -1;
        //                    selectedDeals[i.Key][s, j] = selectedDeal;
        //                }
        //                else
        //                {
        //                    selectedDeals[i.Key][s, j] = selectedDeal;
        //                }
        //            }
        //        }
        //    }


        //    Dictionary<int, int> dealChoices = new Dictionary<int, int>();
        //    dealChoices[0] = dealChoices[1] = dealChoices[2] = 0;

        //    if (!selectedDeals.ContainsKey(dealListNow.Key))
        //        continue;
        //    var d1 = selectedDeals[dealListNow.Key];
        //    var d = new int[symbols.Length];
        //    for (int s = 0; s < symbols.Length; ++s)
        //    {
        //        bool same = true;
        //        for (int j = 1; j < months.Length; ++j)
        //        {
        //            if (d1[s, j] != d1[s, 0])
        //            {
        //                same = false;
        //                break;
        //            }
        //        }
        //        if (!same)
        //            d[s] = -1;
        //        else
        //            d[s] = d1[s, 0];
        //    }
        //    List<Tuple<int, int>> dealSymbolChoice = new List<Tuple<int, int>>();

        //    if (d.Length == 3)
        //    {
        //        if (d[0] == 0 && d[1] == 0 && d[2] == 0)
        //        {
        //            // 2B0
        //            dealSymbolChoice.Add(new Tuple<int, int>(0, 0));
        //            //dealSymbolChoice.Add(new Tuple<int, int>(0, 1));
        //            //dealSymbolChoice.Add(new Tuple<int, int>(0, 2));
        //        }
        //        else if (d[0] == 0 && d[1] == 0 && d[2] == 1)
        //        {
        //            // 2B1
        //            dealSymbolChoice.Add(new Tuple<int, int>(0, 1));
        //            //dealSymbolChoice.Add(new Tuple<int, int>(0, 0));
        //            //dealSymbolChoice.Add(new Tuple<int, int>(1, 2));
        //        }
        //        else if (d[0] == 0 && d[1] == 1 && d[2] == 0)
        //        {
        //            // 2B2
        //            dealSymbolChoice.Add(new Tuple<int, int>(0, 2));
        //            //dealSymbolChoice.Add(new Tuple<int, int>(0, 0));
        //            //dealSymbolChoice.Add(new Tuple<int, int>(1, 1));
        //        }
        //        else if (d[0] == 0 && d[1] == 1 && d[2] == 1)
        //        {
        //            // 0
        //            //dealSymbolChoice.Add(new Tuple<int, int>(0, 0));
        //            //dealSymbolChoice.Add(new Tuple<int, int>(1, 1));
        //            //dealSymbolChoice.Add(new Tuple<int, int>(1, 2));
        //        }
        //        else if (d[0] == 1 && d[1] == 1 && d[2] == 1)
        //        {
        //            // 2S0
        //            dealSymbolChoice.Add(new Tuple<int, int>(1, 0));
        //            //dealSymbolChoice.Add(new Tuple<int, int>(1, 1));
        //            //dealSymbolChoice.Add(new Tuple<int, int>(1, 2));
        //        }
        //        else if (d[0] == 1 && d[1] == 1 && d[2] == 0)
        //        {
        //            // 2S1
        //            dealSymbolChoice.Add(new Tuple<int, int>(1, 1));
        //            //dealSymbolChoice.Add(new Tuple<int, int>(1, 0));
        //            //dealSymbolChoice.Add(new Tuple<int, int>(0, 2));
        //        }
        //        else if (d[0] == 1 && d[1] == 0 && d[2] == 1)
        //        {
        //            // 2S2
        //            dealSymbolChoice.Add(new Tuple<int, int>(1, 2));
        //            //dealSymbolChoice.Add(new Tuple<int, int>(1, 0));
        //            //dealSymbolChoice.Add(new Tuple<int, int>(0, 1));
        //        }
        //        else if (d[0] == 1 && d[1] == 0 && d[2] == 0)
        //        {
        //            // 0
        //            //dealSymbolChoice.Add(new Tuple<int, int>(1, 0));
        //            //dealSymbolChoice.Add(new Tuple<int, int>(0, 1));
        //            //dealSymbolChoice.Add(new Tuple<int, int>(0, 2));
        //        }
        //        if (dealSymbolChoice.Count == 0)
        //        {
        //            dealSymbolChoice.Add(new Tuple<int, int>(-1, 0));
        //        }
        //    }
        //    else if (d.Length == 1)
        //    {
        //        if (d[0] == 0)
        //        {
        //            dealSymbolChoice.Add(new Tuple<int, int>(0, 0));
        //        }
        //        else if (d[0] == 1)
        //        {
        //            dealSymbolChoice.Add(new Tuple<int, int>(1, 0));
        //        }
        //        else
        //        {
        //            dealSymbolChoice.Add(new Tuple<int, int>(-1, 0));
        //        }
        //    }

        //    //if (type == 4)
        //    //{
        //    //    if (sum[0] < sum[1])
        //    //    {
        //    //        selectedDeal = 0;
        //    //    }
        //    //    else if (sum[1] < sum[0])
        //    //    {
        //    //        selectedDeal = 1;
        //    //    }
        //    //    if (selectedDeal == -1)
        //    //        continue;

        //    //    int dealChoice = -1;
        //    //    for (int j = 0; j < tpCount; ++j)
        //    //        for (int k = 0; k < slCount; ++k)
        //    //        {
        //    //            dealChoice = -1;

        //    //            if (ccScores[selectedDeal, j, k] < 0 && ccScores[1 - selectedDeal, j, k] < 0)
        //    //            {
        //    //                dealChoice = 0;
        //    //            }
        //    //            else if (ccScores[selectedDeal, j, k] > 0 && ccScores[1 - selectedDeal, j, k] > 0)
        //    //            {
        //    //                dealChoice = 1;
        //    //            }
        //    //            else if (ccScores[selectedDeal, j, k] > 0 && ccScores[1 - selectedDeal, j, k] < 0)
        //    //            {
        //    //                dealChoice = 2;
        //    //            }
        //    //            else if (ccScores[selectedDeal, j, k] < 0 && ccScores[1 - selectedDeal, j, k] > 0)
        //    //            {
        //    //                dealChoice = 3;
        //    //            }

        //    //            //dealChoice = 1;
        //    //            if (dealChoice == -1)
        //    //                continue;

        //    //            int tp = 20 * (j + 1);
        //    //            int sl = 20 * (k + 1);

        //    //            //if (oscCnt > 100)
        //    //            //    continue;
        //    //            //if (oscCnt > 100)
        //    //            //    dealChoice = dealChoice + 8;

        //    //            int v = -(int)ccScores[0, j, k];

        //    //            for (int x = 0; x < 2; ++x)
        //    //            {
        //    //                int lodealChoice = dealChoice;
        //    //                if (x != selectedDeal)
        //    //                {
        //    //                    lodealChoice = dealChoice + 4;
        //    //                }

        //    //                v = 1;
        //    //                v *= hps[x, j, k, 0];
        //    //                costs[lodealChoice] -= tp * v;
        //    //                dealCnts[lodealChoice] += v;

        //    //                v = 1;
        //    //                v *= hps[x, j, k, 1];
        //    //                costs[lodealChoice] += sl * v;
        //    //                dealCnts[lodealChoice] += v;
        //    //            }
        //    //        }

        //    //    long[] costs2 = new long[costs.Length];
        //    //    for (int m = 0; m < costs.Length; ++m)
        //    //    {
        //    //        costs2[m] = dealCnts[m] == 0 ? 0 : costs[m] / dealCnts[m];
        //    //        costs2[m] = costs[m];
        //    //    }
        //    //    savedData.Add(new Tuple<DateTime, long[]>(i.Item1, costs2));

        //    //    //if (i.Item1.Month == 12 && i.Item1.Day >= 28)
        //    //    //{
        //    //    //    for (int m = 0; m < costs.Length; ++m)
        //    //    //    {
        //    //    //        costs[m] = 0;
        //    //    //        dealCnts[m] = 0;
        //    //    //    }
        //    //    //}
        //    //    continue;
        //    //}
        //    //if (type == 5)
        //    //{

        //    //    if (selectedDeal == -1)
        //    //        continue;
        //    //    //if (oscCnt > 100)
        //    //    //    continue;

        //    //    for (int j = 0; j < tpCount; ++j)
        //    //        for (int k = 0; k < slCount; ++k)
        //    //        {
        //    //            if (ccScores[selectedDeal, j, k] < 0 && ccScores[1 - selectedDeal, j, k] > 0)
        //    //            {
        //    //                int tp = 20 * (j + 1);
        //    //                int sl = 20 * (k + 1);

        //    //                int v = -(int)ccScores[0, j, k];

        //    //                for (int x = 0; x < 2; ++x)
        //    //                {
        //    //                    if (x != selectedDeal)
        //    //                        continue;

        //    //                    v = 1;
        //    //                    v *= hps[x, j, k, 0];
        //    //                    costs[0] -= tp * v;
        //    //                    dealCnts[0] += v;

        //    //                    v = 1;
        //    //                    v *= hps[x, j, k, 1];
        //    //                    costs[0] += sl * v;
        //    //                    dealCnts[0] += v;
        //    //                }

        //    //                for (int x = 0; x < 2; ++x)
        //    //                {
        //    //                    if (x == selectedDeal)
        //    //                        continue;

        //    //                    v = 1;
        //    //                    v *= hps[x, j, k, 0];
        //    //                    costs[1] -= tp * v;
        //    //                    truep += v;
        //    //                    dealCnts[1] += v;

        //    //                    v = 1;
        //    //                    v *= hps[x, j, k, 1];
        //    //                    costs[1] += sl * v;
        //    //                    falsep += v;
        //    //                    dealCnts[1] += v;
        //    //                }
        //    //            }
        //    //        }
        //    //    long[] costs2 = new long[costs.Length];
        //    //    for (int m = 0; m < costs.Length; ++m)
        //    //    {
        //    //        costs2[m] = dealCnts[m] == 0 ? 0 : costs[m] / dealCnts[m];
        //    //        costs2[m] = costs[m];
        //    //    }
        //    //    savedData.Add(new Tuple<DateTime, long[]>(i.Item1, costs2));

        //    //    if (i.Item1.Month == 12 && i.Item1.Day >= 28)
        //    //    {
        //    //        for (int m = 0; m < costs.Length; ++m)
        //    //        {
        //    //            costs[m] = 0;
        //    //            dealCnts[m] = 0;
        //    //        }
        //    //    }

        //    //    continue;
        //    //}

        //    //if (needContinue > 0)
        //    //{
        //    //    if (nowDealType != selectedDeal)
        //    //    {
        //    //        nowDealType = selectedDeal;
        //    //        nowContinue = 0;
        //    //        continue;
        //    //    }
        //    //    nowContinue++;
        //    //    if (nowContinue < needContinue)
        //    //        continue;
        //    //}

        //    //bool testWithDb = false;
        //    //if (testWithDb)
        //    //{
        //    //    long cost11 = 0, cost22 = 0;
        //    //    long dealCnt11 = 0, dealCnt22 = 0;

        //    //    // Test with db
        //    //    System.Data.DataTable[] dts = new System.Data.DataTable[2];
        //    //    string sql1 = string.Format("SELECT * FROM EURUSD_HP WHERE TIME >= '{0}' AND TIME < '{1}' AND TIME % 1800 = 0 AND TP % 20 = 0 AND SL % 20 = 0 AND DEALTYPE = 'B'",
        //    //            WekaUtils.GetTimeFromDate(i.Item1), WekaUtils.GetTimeFromDate(i.Item1.AddDays(1)));
        //    //    dts[0] = Feng.Data.DbHelper.Instance.ExecuteDataTable(sql1);
        //    //    string sql2 = string.Format("SELECT * FROM EURUSD_HP WHERE TIME >= '{0}' AND TIME < '{1}' AND TIME % 1800 = 0 AND TP % 20 = 0 AND SL % 20 = 0 AND DEALTYPE = 'S'",
        //    //        WekaUtils.GetTimeFromDate(i.Item1), WekaUtils.GetTimeFromDate(i.Item1.AddDays(1)));
        //    //    dts[1] = Feng.Data.DbHelper.Instance.ExecuteDataTable(sql2);

        //    //    foreach (System.Data.DataRow row in dts[selectedDeal].Rows)
        //    //    {
        //    //        int tp = (short)(row["Tp"]);
        //    //        int sl = (short)(row["Sl"]);
        //    //        if (ccScores[selectedDeal, tp / 20 - 1, sl / 20 - 1] > 0)
        //    //            continue;

        //    //        if (row["hp"] == System.DBNull.Value)
        //    //            continue;

        //    //        int v = -(int)ccScores[selectedDeal, tp / 20 - 1, sl / 20 - 1];
        //    //        v = 1;
        //    //        if (row["hp"].ToString() == "1")
        //    //        {
        //    //            cost11 -= tp * v;
        //    //        }
        //    //        else
        //    //        {
        //    //            cost11 += sl * v;
        //    //        }
        //    //        dealCnt11 += v;
        //    //    }

        //    //    foreach (System.Data.DataRow row in dts[1 - selectedDeal].Rows)
        //    //    {
        //    //        int tp = (short)(row["Tp"]);
        //    //        int sl = (short)(row["Sl"]);
        //    //        if (ccScores[1 - selectedDeal, tp / 20 - 1, sl / 20 - 1] > 0)
        //    //            continue;

        //    //        if (row["hp"] == System.DBNull.Value)
        //    //            continue;

        //    //        int v = -(int)ccScores[1 - selectedDeal, tp / 20 - 1, sl / 20 - 1];
        //    //        v = 1;
        //    //        if (row["hp"].ToString() == "1")
        //    //        {
        //    //            cost22 -= tp * v;
        //    //        }
        //    //        else
        //    //        {
        //    //            cost22 += sl * v;
        //    //        }
        //    //        dealCnt22 += v;
        //    //    }

        //    //    WekaUtils.DebugAssert(costs[0] == cost11);
        //    //    WekaUtils.DebugAssert(costs[1] == cost22);
        //    //    WekaUtils.DebugAssert(dealCnts[0] == dealCnt11);
        //    //    WekaUtils.DebugAssert(dealCnts[1] == dealCnt22);
        //    //}
        //    //continue;

        //    //double[,] sumRow = new double[2,30];
        //    //double[,] sumColumn = new double[2,30];

        //    //for (int k = 0; k < 2; ++k)
        //    //    for (int tp = 0; tp < 30; ++tp)
        //    //        for (int sl = 0; sl < 30; ++sl)
        //    //        {
        //    //            sumRow[k, tp] += ccScores[k, tp, sl];
        //    //            sumColumn[k, sl] += ccScores[k, tp, sl];
        //    //        }

        //    //int dealType = i.Item2;
        //    //bool fail = false;
        //    //for (int tp = 0; tp < 30; ++tp)
        //    //{
        //    //    if (sumRow[dealType, tp] > 0)
        //    //    {
        //    //        fail = true;
        //    //        break;
        //    //    }
        //    //}
        //    //if (fail)
        //    //    continue;
        //    //int[] delta = new int[20];
        //    //for (int tp = 1; tp < 20; ++tp)
        //    //{
        //    //    delta[tp] = sumRow[dealType, tp] > sumRow[dealType, tp - 1] ? 1 : -1; 
        //    //}
        //    //int[] delta2 = new int[20];
        //    //for (int tp = 2; tp < 20; ++tp)
        //    //{
        //    //    delta2[tp] = delta[tp] - delta[tp - 1];
        //    //}
        //    //int notZeroCount = 0;
        //    //for (int tp = 2; tp < 20; ++tp)
        //    //{
        //    //    if (delta2[tp] != 0)
        //    //        notZeroCount++;
        //    //}
        //    //if (notZeroCount >= 2)
        //    //    continue;

        //    //for (int sl = 0; sl < 20; ++sl)
        //    //{
        //    //    if (sumColumn[dealType, sl] > 0)
        //    //    {
        //    //        fail = true;
        //    //        break;
        //    //    }
        //    //}
        //    //if (fail)
        //    //    continue;

        //    //if (nowDealType != i.Item2 || i.Item6 == 0)
        //    //{
        //    //    nowDealType = i.Item2;
        //    //    nowContinue = 0;
        //    //    continue;
        //    //}
        //    //nowContinue++;
        //    //if (nowContinue < needContinue)
        //    //    continue;

        //    //if (i.Item1.DayOfWeek == DayOfWeek.Thursday)
        //    //    continue;
        //    //if (i.Item1.Hour != h)
        //    //    continue;

        //    //if (i.Item3 <= 50)
        //    //    continue;
        //    //if (i.Item3 >= 180)
        //    //    continue;
        //    //if (i.Item4 <= 60)
        //    //    continue;
        //    //if (i.Item4 >= 340)
        //    //    continue;

        //    //if (i.Item5 > -4000)
        //    //    continue;
        //    //if (i.Item5 < -9000)
        //    //    continue;

        //    //costs[0] += i.Item5 / 10;
        //    //dealCnts[0] += i.Item6;

        //    //timedCost.Add(new Tuple<DateTime, int, int>(i.Item1, costs[0], dealCnt));
        //}
        #endregion

        public Dictionary<DateTime, Tuple<int, long>> ReadTestResult(string fileName, int n, int minPeriod)
        {
            Dictionary<DateTime, Tuple<int, long>> dictIncrementTest = new Dictionary<DateTime, Tuple<int, long>>();
            if (!System.IO.File.Exists(fileName))
                return dictIncrementTest;
            
            using (StreamReader sr = new StreamReader(fileName))
            {
                while (!sr.EndOfStream)
                {
                    string s = sr.ReadLine();
                    string[] ss = s.Split(',');

                    DateTime date = Convert.ToDateTime(ss[0]);
                    if (date == Parameters.MtStartTime)
                        continue;
                    int r = Convert.ToInt32(ss[1]);
                    double v = Convert.ToDouble(ss[4]);
                    long lastTime = Convert.ToInt64(ss[2]);
                    for (int i = 0; i < n; ++i)
                    {
                        dictIncrementTest[date.AddMinutes(i * minPeriod)] = new Tuple<int, long>(r, lastTime);
                    }
                }
            }

            return dictIncrementTest;
        }

        public void GenerateCCScoreArff(string arffFileName)
        {
            if (System.IO.File.Exists(arffFileName))
            {
                System.IO.File.Delete(arffFileName);
            }

            int nTpsl = TestParameters2.nTpsl;
            var cp = TestParameters2.CandidateParameter;
            var symbols = new string[cp.SymbolCount];
            for (int i = 0; i < cp.SymbolCount; ++i)
                symbols[i] = cp.AllSymbols[i + cp.SymbolStart];

            var weeks = new string[] { TestParameters2.lastWeek };

            SortedDictionary<DateTime, Tuple<int, int, int, int, int, double[, ,]>>[,] dealsList = new SortedDictionary<DateTime, Tuple<int, int, int, int, int, double[, ,]>>[symbols.Length, weeks.Length];
            for (int s = 0; s < symbols.Length; ++s)
            {
                //hpDatas[s] = GetHpDateFromTxt(string.Format("f:\\forex\\hpdata.{0}.txt", symbols[s]), nTpSl);
                for (int j = 0; j < weeks.Length; ++j)
                {
                    //dealsList[s, j] = GetDetailDeals(string.Format("f:\\forex\\deal.2000-2012.{0}.w{1}.txt", symbols[s], weeks[j]), nTpsl);
                    dealsList[s, j] = CCScoreData.GetDetailDeals(TestParameters.GetBaseFilePath(string.Format("{0}_ccScores_w{2}_{1}.txt", 
                        symbols[s], TestParameters2.CandidateParameter.MainPeriod, weeks[j])), nTpsl);
                }
            }

            int symbolIdx = 0;

            int tpStart = TestParameters2.tpStart;
            int slStart = TestParameters2.slStart;
            int tpCount = TestParameters2.tpCount;
            int slCount = TestParameters2.slCount;

            int preLength = TestParameters2.PreLength;
            int attrLength = preLength * (tpCount - tpStart) * (slCount - slStart) * 2 * weeks.Length * symbols.Length;

            string symbol = symbols[symbolIdx];
            // DateTime, DealType, Tp, Sl, Cost, num, ccScores

            bool useNumeric = false;
            bool usePropNumeric = false;

            string wekaFileName = string.Format(arffFileName);
            using (StreamWriter sw = new StreamWriter(wekaFileName))
            {
                sw.WriteLine("@relation 'ccScores'");
                sw.WriteLine("@attribute timestamp date \"yyyy-MM-dd\'T\'HH:mm:ss\"");
                sw.WriteLine("@attribute hpdate date \"yyyy-MM-dd\'T\'HH:mm:ss\"");
                for (int i = 0; i < attrLength; ++i)
                {
                    sw.WriteLine(string.Format("@attribute p{0}", i.ToString()) + (useNumeric ? " numeric" : " {0,1,2,3}"));
                }
                sw.WriteLine("@attribute prop " + (usePropNumeric ? " numeric" : " {0,1,2,3}"));
                sw.WriteLine("@data");
                sw.WriteLine();

                var dealsListArray = new KeyValuePair<DateTime, Tuple<int, int, int, int, int, double[, ,]>>[dealsList[0, 0].Count];
                dealsList[0, 0].CopyTo(dealsListArray, 0);

                var hps = HpData.Instance.GetHpSum(cp.MainSymbol, cp.MainPeriod);
                for (int i = preLength; i < dealsListArray.Length; ++i)
                {
                    var dealListNow = dealsListArray[i];
                    var nowDate = dealListNow.Key;

                    //if (nowDate.Hour % TestParameters2.MainPeriodOfHour != 0)
                    //    continue;

                    if (!hps.ContainsKey(nowDate) && !(TestParameters2.RealTimeMode && i == dealsListArray.Length - 1))
                        continue;

                    long hpTime = WekaUtils.GetTimeFromDate(Parameters.MaxDate);
                    int hp = 0;
                    if (!(TestParameters2.RealTimeMode && i == dealsListArray.Length - 1))
                    {
                        hpTime = hps[nowDate].Item2;
                        hp = hps[nowDate].Item1;
                    }

                    int[] instanceValue = new int[attrLength];
                    int n = 0;

                    try
                    {
                        for (int k = 0; k < 2; ++k)
                            for (int tp = tpStart; tp < tpCount; ++tp)
                                for (int sl = slStart; sl < slCount; ++sl)
                                    for (int p = 0; p < preLength; ++p)
                                        for (int s = 0; s < symbols.Length; ++s)
                                            for (int m = 0; m < weeks.Length; ++m)
                                            {
                                                var dealTrain = dealsListArray[i - preLength + p + 1];
                                                var ccScores = dealsList[s, m][dealTrain.Key].Item6;

                                                //instanceValue[n] = ccScores[k, tp, sl];
                                                instanceValue[n] = ccScores[k, tp, sl] < 0 ? 0 : (ccScores[k, tp, sl] == 0 ? 2 : 1);
                                                n++;
                                            }
                    }
                    catch (KeyNotFoundException)
                    {
                        continue;
                    }

                    sw.Write(nowDate.ToString(Parameters.DateTimeFormat));
                    sw.Write(",");

                    // hp
                    sw.Write(WekaUtils.GetDateFromTime(hpTime).ToString(Parameters.DateTimeFormat));
                    sw.Write(",");

                    for (int j = 0; j < instanceValue.Length; ++j)
                    {
                        sw.Write(instanceValue[j].ToString());
                        sw.Write(",");
                    }

                    sw.WriteLine(hp.ToString());

                    //// bitmap
                    //string fileName = string.Format("d:\\bitmap\\{0}_{1}.bmp", i.Key.ToString("yyyy-MM-dd"), ret);
                    //System.Drawing.Bitmap bitmap = new System.Drawing.Bitmap(30 * 2, 30 * months.Length);
                    //if (System.IO.File.Exists(fileName))
                    //{
                    //    var b = new System.Drawing.Bitmap(fileName);
                    //    for (int w = 0; w < b.Width; ++w)
                    //        for (int h = 0; h < b.Height; ++h)
                    //            bitmap.SetPixel(w, h, b.GetPixel(w, h));
                    //    b.Dispose();
                    //}

                    //for (int k = 0; k < 2; ++k)
                    //    for (int tp = 0; tp < tpCount; ++tp)
                    //        for (int sl = 0; sl < slCount; ++sl)
                    //        {
                    //            bitmap.SetPixel(k * tpCount + tp, m * slCount + sl, ccScores[k, tp, sl] > 0 ? System.Drawing.Color.Black : System.Drawing.Color.Red);
                    //        }

                    //try
                    //{
                    //    System.IO.File.Delete(fileName);
                    //    bitmap.Save(fileName, System.Drawing.Imaging.ImageFormat.Bmp);
                    //}
                    //catch (Exception ex)
                    //{
                    //}

                }
            }
        }

        public void BuildCCScoreDeals()
        {
            WekaUtils.Instance.WriteLog("Now BuildCCScoreDeals");
            var cp = TestParameters2.CandidateParameter;
            string resultFile = TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_ccScores_w{2}_{1}.txt",
                cp.MainSymbol, cp.MainPeriod, TestParameters2.lastWeek));
            if (File.Exists(resultFile))
                return;

            string arffFileName = TestParameters.GetBaseFilePath(string.Format("{0}_ccScores_w{2}_{1}.arff",
                cp.MainSymbol, cp.MainPeriod, TestParameters2.lastWeek));
            if (!System.IO.File.Exists(arffFileName))
            {
                GenerateCCScoreArff(arffFileName);
            }

            Instances allInstances = WekaUtils.LoadInstances(arffFileName);

            int n = (int)(24 / TestParameters2.MainPeriodOfHour);
            n = TestParameters2.nPeriod;
            TestManager.IncrementTest(allInstances, () => 
                { 
                    //return WekaUtils.CreateClassifier(typeof(MinDistanceClassifier)); 
                    return WekaUtils.CreateClassifier(typeof(weka.classifiers.lazy.IBk));  
                }, "1,2", resultFile, n);
        }

        public void MergeAllBuildResult()
        {
            SimulateAccordDealLog(true, false);
        }

        private Dictionary<DateTime, int> InvertIncrementTest(Dictionary<DateTime, int> d)
        {
            Dictionary<DateTime, int> ret = new Dictionary<DateTime, int>();
            foreach (var kvp in d)
            {
                if (kvp.Value == 0)
                    ret[kvp.Key] = 1;
                else if (kvp.Value == 1)
                    ret[kvp.Key] = 0;
                else
                    throw new AssertException("invalid kvp.Value");
            }
            return ret;
        }

        private void AddToIncrementTests(List<Dictionary<DateTime, Tuple<int, long>>> incrementTests, string fileName, int n, int minPeriod)
        {
            var x = ReadTestResult(TestParameters.GetBaseFilePath(fileName), n, minPeriod);
            if (x.Count > 0)
            {
                incrementTests.Add(x);
            }
        }

        public static double GetNumericCLC(List<double> d)
        {
            //d = new List<double> { 2, 3, 4, 5, 6, 7, 8 };

            List<double> xs = new List<double>();
            for (int i = 0; i < d.Count; ++i)
                xs.Add(i + 1);
            var X = MathNet.Numerics.LinearAlgebra.Double.DenseMatrix.CreateFromColumns(
                new[] { new MathNet.Numerics.LinearAlgebra.Double.DenseVector(xs.Count, 1), 
                    new MathNet.Numerics.LinearAlgebra.Double.DenseVector(xs.ToArray<double>()) });
            var y = new MathNet.Numerics.LinearAlgebra.Double.DenseVector(d.ToArray<double>());
            var p = MathNet.Numerics.LinearAlgebra.Double.ExtensionMethods.QR(X).Solve(y);
            var a = p[0];
            var b = p[1];

            double sum = 0;
            for (int i = 0; i < d.Count; ++i)
            {
                double yy = xs[i] * a + b;
                sum += Math.Abs(yy - d[i]);
            }
            return sum / d.Count;
        }

        public static double GetMaximumDrawdown(List<double> d)
        {
            int n = d.Count;
            double min = 0;
            for (int i = 0; i < n; ++i)
            {
                for (int j = i; j < n; ++j)
                {
                    double t = d[j] - d[i];
                    if (t < min)
                    {
                        min = t;
                    }
                }
            }
            return -min;
        }

        public string SimulateAccordDealLog(bool writeEaOrderFileName = true, bool testMode = true)
        {
            string ret = string.Empty;
            WekaUtils.Instance.WriteLog("Now SimulateAccordDealLog");

            int nTpsl = TestParameters2.nTpsl;
            int tpStart = TestParameters2.tpStart;
            int slStart = TestParameters2.slStart;
            int tpCount = TestParameters2.tpCount;
            int slCount = TestParameters2.slCount;

            int symbolIdx = 0;
            var symbols = new string[] { TestParameters2.CandidateParameter.MainSymbol };
            var weeks = new string[] { TestParameters2.lastWeek };

            string eaOrderFileName = null;

            StreamWriter swEaOrderFile = null;
            if (writeEaOrderFileName)
            {
                eaOrderFileName = string.Format("{0}\\ea_order_{1}.txt", TestParameters.BaseDir, TestParameters2.CandidateParameter.MainSymbol);
                swEaOrderFile = new StreamWriter(eaOrderFileName, true);
            }

            // DateTime, DealType, Tp, Sl, Cost, num, ccScores
            //Dictionary<DateTime, Tuple<int[, , ,], long[, ,]>>[] hpDatas = new Dictionary<DateTime, Tuple<int[, , ,], long[, ,]>>[symbols.Length];
            IHpData hpDatas = null;
            SortedDictionary<DateTime, Tuple<int, int, int, int, int, double[, ,]>>[,] dealsList = new SortedDictionary<DateTime, Tuple<int, int, int, int, int, double[, ,]>>[symbols.Length, weeks.Length];

            List<Dictionary<DateTime, Tuple<int, long>>> incrementTests = new List<Dictionary<DateTime, Tuple<int, long>>>();
            //incrementTests.Add(ReadTestResult(TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_CCScores_w8.txt", symbols[symbolIdx]))));
            //incrementTests.Add(ReadTestResult(TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_CCScores_w6.txt", symbols[symbolIdx]))));
            //incrementTests.Add(ReadTestResult(TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_CCScores_w4.txt", symbols[symbolIdx]))));
            //incrementTests.Add(ReadTestResult(TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_CCScores_w2.txt", symbols[symbolIdx]))));
            //incrementTests.Add(ReadTestResult(TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_CCScores_w1.txt", symbols[symbolIdx]))));

            //incrementTests.Add(ReadTestResult(TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_CandlePattern_D1.txt", symbols[symbolIdx])), 6));
            //incrementTests.Add(ReadTestResult(TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_CandlePattern_H4.txt", symbols[symbolIdx])), 1));

            //incrementTests.Add(ReadTestResult(TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_Price_D1.txt", symbols[symbolIdx])), 6));
            //incrementTests.Add(ReadTestResult(TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_Price_H4.txt", symbols[symbolIdx])), 1));

            //incrementTests.Add(ReadTestResult(TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_ccScores_D1_w4.txt", symbols[symbolIdx])), 6));
            //incrementTests.Add(ReadTestResult(TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_ccScores_H4_w4.txt", symbols[symbolIdx])), 1));

            //incrementTests.Add(ReadTestResult(TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_ccScores_D1_w8.txt", symbols[symbolIdx])), 6));
            //incrementTests.Add(ReadTestResult(TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_ccScores_D1_w2.txt", symbols[symbolIdx])), 6));
            //incrementTests.Add(ReadTestResult(TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_ccScores_D1_w1.txt", symbols[symbolIdx])), 6));

            //incrementTests.Add(InvertIncrementTest(ReadTestResult(TestParameters.GetBaseFilePath(string.Format("IncrementTest_USDX_Price_D1.txt", symbols[symbolIdx])), 6)));
            //incrementTests.Add(InvertIncrementTest(ReadTestResult(TestParameters.GetBaseFilePath(string.Format("IncrementTest_USDX_CandlePattern_D1.txt", symbols[symbolIdx])), 6)));

            //AddToIncrementTests(incrementTests, string.Format("IncrementTest_{0}_Price_{1}.txt", symbols[symbolIdx], TestParameters2.CandidateParameter.MainPeriod));
            //AddToIncrementTests(incrementTests, string.Format("IncrementTest_{0}_CandlePattern_{1}.txt", symbols[symbolIdx], TestParameters2.CandidateParameter.MainPeriod));
            //AddToIncrementTests(incrementTests, string.Format("IncrementTest_{0}_ccScores_{1}_w{2}.txt", symbols[symbolIdx], TestParameters2.CandidateParameter.MainPeriod, TestParameters2.lastWeek));

            //incrementTests[0] = InvertIncrementTest(incrementTests[0]);

            string herePeriod = "";
            int minPeriod = int.MaxValue;
            foreach (string incrementFile in Directory.GetFiles(TestParameters.BaseDir, string.Format("IncrementTest_{0}_*.txt", TestParameters2.CandidateParameter.MainSymbol)))
            {
                string file = Path.GetFileName(incrementFile);
                foreach (string p in Parameters.AllPeriodsFull)
                {
                    if (file.Contains(string.Format("_{0}.txt", p)))
                    {
                        if (WekaUtils.GetMinuteofPeriod(p) < minPeriod)
                        {
                            minPeriod = WekaUtils.GetMinuteofPeriod(p);
                            herePeriod = p;
                        }
                    }
                }
            }

            foreach (string incrementFile in Directory.GetFiles(TestParameters.BaseDir, string.Format("IncrementTest_{0}_*.txt", TestParameters2.CandidateParameter.MainSymbol)))
            {
                string file = Path.GetFileName(incrementFile);
                int n = 0;
                foreach (string p in Parameters.AllPeriodsFull)
                {
                    if (p != TestParameters2.CandidateParameter.MainPeriod)
                        continue;

                    if (file.Contains(string.Format("_{0}.txt", p)))
                    {
                        n = WekaUtils.GetMinuteofPeriod(p) / minPeriod;
                        incrementTests.Add(ReadTestResult(incrementFile, n, minPeriod));
                    }
                }
            }

            if (incrementTests.Count == 0)
            {
                if (swEaOrderFile != null)
                    swEaOrderFile.Close();
                return ret;
            }

            string ccScoreFileName = TestParameters.GetBaseFilePath(string.Format("{0}_ccScores_w{2}_{1}.txtnnn",
                symbols[symbolIdx], herePeriod, weeks[0]));
            if (System.IO.File.Exists(ccScoreFileName))
            {
                dealsList[symbolIdx, 0] = CCScoreData.GetDetailDeals(ccScoreFileName, nTpsl);
            }
            else
            {
                dealsList[symbolIdx, 0] = new SortedDictionary<DateTime, Tuple<int, int, int, int, int, double[, ,]>>();
            }

            if (testMode)
            {
                hpDatas = new HpDbData(symbols[symbolIdx]);
                //hpDatas[symbolIdx] = HpData.Instance.GetHpDateFromTxt(TestParameters.GetBaseFilePath(
                //    string.Format("{0}_{1}_hpdata.txt", symbols[symbolIdx], herePeriod)), nTpsl);
            }

            List<Tuple<DateTime, long[]>> historyCostTF2 = new List<Tuple<DateTime, long[]>>();
            List<Tuple<DateTime, long[]>> historyCostBS2 = new List<Tuple<DateTime, long[]>>();
            List<Tuple<DateTime, int, int>> timedCost = new List<Tuple<DateTime, int, int>>();

            DateTime nextDealDate = DateTime.MinValue;

            long[, , ,] costs = new long[2, TestParameters.TpMaxCount, TestParameters.SlMaxCount, 2];
            long[, , ,] dealCnts = new long[2, TestParameters.TpMaxCount, TestParameters.SlMaxCount, 2];
            long[, , ,] dealTimes = new long[2, TestParameters.TpMaxCount, TestParameters.SlMaxCount, 2];

            foreach (var nowDate in incrementTests[0].Keys)
            {
                if (nowDate < nextDealDate)
                    continue;

                Tuple<int[, , ,], long[, ,]> hps = null;
                if (testMode)
                {
                    hps = hpDatas.GetHpData(nowDate);
                    if (hps == null)
                        continue;
                }

                int selectedSl = -1;
                int selectedDeal = -1;
                double selectedDealVol = 0;

                int selectedDeal1 = -1;
                {
                    if (dealsList[symbolIdx, 0].ContainsKey(nowDate))
                    {
                        var ccScores = dealsList[symbolIdx, 0][nowDate].Item6;

                        double[] sum = new double[Parameters.AllDealTypes.Length];
                        double[] oscsum = new double[Parameters.AllDealTypes.Length];
                        int oscCnt = 0;
                        for (int k = 0; k < 2; ++k)
                            for (int i = 0; i < ccScores.GetLength(1); ++i)
                                for (int j = 0; j < ccScores.GetLength(2); ++j)
                                {
                                    sum[k] += ccScores[k, i, j];
                                }
                        for (int i = 0; i < ccScores.GetLength(1); ++i)
                            for (int j = 0; j < ccScores.GetLength(2); ++j)
                            {
                                if (ccScores[0, i, j] < 0 && ccScores[1, i, j] < 0)
                                {
                                    oscsum[0] += ccScores[0, i, j];
                                    oscsum[1] += ccScores[1, i, j];
                                    oscCnt++;
                                }
                            }

                        if (sum[0] < sum[1] && sum[0] < 0)
                        {
                            selectedDeal1 = 0;
                        }
                        else if (sum[1] < sum[0] && sum[1] < 0)
                        {
                            selectedDeal1 = 1;
                        }
                        //if (oscCnt > 400 / 16)
                        //{
                        //    selectedDeal1 = -1;
                        //}
                    }
                }

                int selectedDeal2 = -1;
                {
                    int clsRet = incrementTests[0][nowDate].Item1;
                    bool incrementTestAllSame = true;
                    foreach (var iii in incrementTests)
                    {
                        if (!iii.ContainsKey(nowDate) || clsRet != iii[nowDate].Item1)
                        {
                            incrementTestAllSame = false;
                            break;
                        }
                    }
                    if (incrementTestAllSame)
                    {
                        selectedDeal2 = clsRet;
                        selectedDealVol = 1;
                    }
                }

                int selectedDeal3 = -1;
                {
                    double minCount = incrementTests.Count / 2.0;
                    int[] clsResults = new int[3];
                    foreach (var iii in incrementTests)
                    {
                        if (iii.ContainsKey(nowDate))
                        {
                            clsResults[iii[nowDate].Item1]++;
                        }
                    }
                    if (clsResults[0] >= minCount)
                        selectedDeal3 = 0;
                    else if (clsResults[1] >= minCount)
                        selectedDeal3 = 1;
                }


                selectedDeal = selectedDeal2;
                if (selectedDeal == -1 || selectedDeal == 2)
                    continue;

                // Select min sl
                {
                    if (dealsList[symbolIdx, 0].ContainsKey(nowDate))
                    {
                        var ccScores = dealsList[symbolIdx, 0][nowDate].Item6;

                        for (int m = 0; m < weeks.Length; ++m)
                        {
                            int selectedSl1 = -1;
                            double[] tpSumccScores = new double[slCount];

                            for (int tp1 = tpStart; tp1 < tpCount; ++tp1)
                                for (int sl1 = slStart; sl1 < slCount; ++sl1)
                                {
                                    tpSumccScores[sl1] += ccScores[selectedDeal, tp1, sl1];
                                }
                            for (int sl1 = slStart; sl1 < slCount; ++sl1)
                            {
                                if (tpSumccScores[sl1] < 0)
                                {
                                    selectedSl1 = sl1;
                                    break;
                                }
                            }

                            if (selectedSl1 == -1)
                                break;
                            selectedSl = Math.Max(selectedSl, selectedSl1);
                        }

                        //if (selectedSl == -1)
                        //    continue;
                        //selectedSl = 0;
                    }
                }

                bool isFiltered = false;
                isFiltered = TestManager.Filter(nowDate);
                if (isFiltered)
                    continue;

                //selectedDeal = 1 - selectedDeal;

                //var atr = Feng.Data.DbHelper.Instance.ExecuteScalar("SELECT ATR_14 FROM USDJPY_D1 WHERE TIME = " + WekaUtils.GetTimeFromDate(new DateTime(nowDate.Year, nowDate.Month, nowDate.Day)));
                //if (atr == null)
                //    continue;
                //int x = (int)((double)atr * 10000 * 4);
                //x /= 100;
                //x = x / 40 - 1;
                //selectedSl = x;

                selectedSl = Math.Max(selectedSl, tpStart);
                selectedSl = Math.Min(selectedSl, tpCount - 1);
                selectedSl = 5;
                selectedSl = -1;

                int selectedTp = -1;

                int maxPoint = TestParameters.TpMaxCount * TestParameters.GetTpSlMinDelta(symbols[symbolIdx]);
                long nowTime = WekaUtils.GetTimeFromDate(nowDate);

                int allDealCnt = 1;
                if (selectedTp == -1)
                    allDealCnt *= (tpCount - tpStart);
                if (selectedSl == -1)
                    allDealCnt *= (slCount - slStart);
                double stepHour = 6;
                stepHour = Math.Min(stepHour, WekaUtils.GetMinuteofPeriod(herePeriod) / 60.0);
                int secondPerDeal = (int)(3600 * stepHour / allDealCnt);
                for (double tt = 0; tt < WekaUtils.GetMinuteofPeriod(herePeriod) / 60.0; tt += stepHour)
                {
                    int n = 0;
                    for (int tp = tpStart; tp < tpCount; ++tp)
                    {
                        if (selectedTp != -1 && tp != selectedTp)
                            continue;
                        for (int sl = slStart; sl < slCount; ++sl)
                        {
                            if (selectedSl != -1 && sl != selectedSl)
                                continue;

                            int tpp = TestParameters.GetTpSlMinDelta(symbols[symbolIdx]) * nTpsl;

                            int tp1 = tpp * (tp + 1);
                            int sl1 = tpp * (sl + 1);

                            DateTime closeDate = nowDate.AddSeconds(incrementTests[0][nowDate].Item2);
                            long closeTime = WekaUtils.GetTimeFromDate(closeDate);

                            if (testMode)
                            {
                                int v = (int)(selectedDealVol * 100);
                                //v = maxPoint / sl1;
                                v = 1;

                                if (closeTime >= hps.Item2[selectedDeal, tp, sl] || true)
                                {
                                    int cv = v * hps.Item1[selectedDeal, tp, sl, 0];
                                    int tpv = tp1 * cv;
                                    costs[selectedDeal, tp, sl, 0] -= tpv;
                                    dealCnts[selectedDeal, tp, sl, 0] += cv;
                                    dealTimes[selectedDeal, tp, sl, 0] += cv * (hps.Item2[selectedDeal, tp, sl] - nowTime);

                                    cv = v * hps.Item1[selectedDeal, tp, sl, 1];
                                    int slv = sl1 * cv;
                                    costs[selectedDeal, tp, sl, 1] += slv;
                                    dealCnts[selectedDeal, tp, sl, 1] += cv;
                                    dealTimes[selectedDeal, tp, sl, 1] += cv * (hps.Item2[selectedDeal, tp, sl] - nowTime);

                                    if (swEaOrderFile != null)
                                    {
                                        swEaOrderFile.WriteLine(string.Format("{0}, {1}, {2}, {3}, {4}, 0, 0, {5}, {6}",
                                                TestParameters2.CandidateParameter.MainSymbol,
                                                selectedDeal == 0 ? "Buy" : "Sell",
                                                nowDate.AddMinutes(WekaUtils.GetMinuteofPeriod(TestParameters2.CandidateParameter.MainPeriod))
                                                    .AddHours(tt).AddSeconds(n * secondPerDeal).ToString(Parameters.DateTimeFormat),
                                                tp1, sl1,
                                                WekaUtils.GetDateFromTime(hps.Item2[selectedDeal, tp, sl]).ToString(Parameters.DateTimeFormat),
                                                tpv > slv ? "Right" : "Wrong"));
                                    }
                                }
                                else
                                {
                                    //continue;

                                    double? openPrice = (double?)Feng.Data.DbHelper.Instance.ExecuteScalar(string.Format(
                                        "SELECT TOP 1 [CLOSE] FROM {0}_M1 WHERE TIME = {1} ORDER BY TIME", symbols[symbolIdx], WekaUtils.GetTimeFromDate(nowDate)));
                                    double? closePrice = (double?)Feng.Data.DbHelper.Instance.ExecuteScalar(string.Format(
                                        "SELECT TOP 1 [CLOSE] FROM {0}_M1 WHERE TIME = {1} ORDER BY TIME", symbols[symbolIdx], closeTime));
                                    if (!openPrice.HasValue || !closePrice.HasValue)
                                        continue;

                                    double delta = closePrice.Value - openPrice.Value;
                                    if (delta == 0)
                                        continue;

                                    int t = (int)(Math.Abs(delta) * 10000);
                                    if ((selectedDeal == 0 && delta > 0)
                                        || (selectedDeal == 1 && delta < 0))
                                    {
                                        System.Diagnostics.Debug.Assert(t < tp1);

                                        int cv = v * 1;
                                        int tpv = t * cv - 2;
                                        costs[selectedDeal, tp, sl, 0] -= tpv;
                                        dealCnts[selectedDeal, tp, sl, 0] += cv;
                                        dealTimes[selectedDeal, tp, sl, 0] += cv * (closeTime - nowTime);
                                    }
                                    else if ((selectedDeal == 1 && delta > 0)
                                        || (selectedDeal == 0 && delta < 0))
                                    {
                                        System.Diagnostics.Debug.Assert(t < sl1);

                                        int cv = v * 1;
                                        int slv = t * cv + 2;
                                        costs[selectedDeal, tp, sl, 1] += slv;
                                        dealCnts[selectedDeal, tp, sl, 1] += cv;
                                        dealTimes[selectedDeal, tp, sl, 1] += cv * (closeTime - nowTime);
                                    }
                                    else
                                    {
                                        throw new ArgumentException("");
                                    }
                                }

                                //nextDealDate = WekaUtils.GetDateFromTime(hps.Item2[selectedDeal, tp, sl]);
                            }
                            else
                            {
                                if (swEaOrderFile != null)
                                {
                                    swEaOrderFile.WriteLine(string.Format("{0}, {1}, {2}, {3}, {4}, 0, 0, {5}, {6}",
                                            TestParameters2.CandidateParameter.MainSymbol,
                                            selectedDeal == 0 ? "Buy" : "Sell",
                                            nowDate.AddMinutes(WekaUtils.GetMinuteofPeriod(TestParameters2.CandidateParameter.MainPeriod))
                                                .AddHours(tt).AddSeconds(n * secondPerDeal).ToString(Parameters.DateTimeFormat),
                                            tp1, sl1,
                                            "Unknown", "Unknown"));
                                }
                            }

                            n++;
                        }
                    }
                }

                if (testMode)
                {
                    long[] costsTF2 = new long[2];
                    long[] dealCntTF2 = new long[2];
                    long[] dealTimeTF2 = new long[2];

                    long[] costsBS2 = new long[2];
                    long[] dealCntBS2 = new long[2];

                    for (int t = 0; t < 2; ++t)
                        for (int m = 0; m < 2; ++m)
                        {
                            for (int tp1 = 0; tp1 < TestParameters.TpMaxCount; ++tp1)
                                for (int sl1 = 0; sl1 < TestParameters.SlMaxCount; ++sl1)
                                {
                                    costsTF2[t] += costs[m, tp1, sl1, t];
                                    dealCntTF2[t] += dealCnts[m, tp1, sl1, t];
                                    dealTimeTF2[t] += dealTimes[m, tp1, sl1, t];

                                    costsBS2[m] += costs[m, tp1, sl1, t];
                                    dealCntBS2[m] += dealCnts[m, tp1, sl1, t];
                                }
                        }

                    ret = string.Format("{0}, {1},{2},{3}\t{4},{5},{6}\t{7},{8},{9}\t{10},{11},{12}\t{13},{14},{15}\t{16}",
                        nowDate.ToString(Parameters.DateTimeFormat),
                        (costsTF2[0] / 1e4).ToString("F2"), (costsTF2[1] / 1e4).ToString("F2"), ((costsTF2[0] + costsTF2[1]) / 1e4).ToString("F2"),
                        (costsBS2[0] / 1e4).ToString("F2"), (costsBS2[1] / 1e4).ToString("F2"), ((costsBS2[0] + costsBS2[1]) / 1e4).ToString("F2"),
                        dealCntBS2[0] == 0 ? "0" : (costsBS2[0] / dealCntBS2[0]).ToString("F0"),
                        dealCntBS2[1] == 0 ? "0" : (costsBS2[1] / dealCntBS2[1]).ToString("F0"),
                        (dealCntBS2[0] + dealCntBS2[1]) == 0 ? "0" : ((costsBS2[0] + costsBS2[1]) / (dealCntBS2[0] + dealCntBS2[1])).ToString("F0"),
                        dealCntTF2[0], dealCntTF2[1], (dealCntTF2[0] + dealCntTF2[1]) == 0 ? "0" : ((double)dealCntTF2[0] / (dealCntTF2[0] + dealCntTF2[1])).ToString("F2"),
                        dealTimeTF2[0] == 0 ? "0" : (costsTF2[0] * 1e8 / dealTimeTF2[0]).ToString("F0"),
                        dealTimeTF2[1] == 0 ? "0" : (costsTF2[1] * 1e8 / dealTimeTF2[1]).ToString("F0"),
                        (dealTimeTF2[0] + dealTimeTF2[1]) == 0 ? "0" : ((costsTF2[0] + costsTF2[1]) * 1e8 / (dealTimeTF2[0] + dealTimeTF2[1])).ToString("F0"),
                        selectedDeal);
                    //if (nowDate.Hour == 10)
                    {
                        WekaUtils.Instance.WriteLog(ret);
                    }
                    historyCostTF2.Add(new Tuple<DateTime, long[]>(nowDate, costsTF2));
                    historyCostBS2.Add(new Tuple<DateTime, long[]>(nowDate, costsBS2));
                }
            }
            if (swEaOrderFile != null)
                swEaOrderFile.Close();

            string figureFileName = TestParameters.GetBaseFilePath("figure.txt");
            if (System.IO.File.Exists(figureFileName))
            {
                System.IO.File.Delete(figureFileName);
            }
            List<double> allCosts = new List<double>();
            int nnn = historyCostBS2.Count / 2000;
            nnn = Math.Max(1, nnn);
            using (StreamWriter sw = new StreamWriter(figureFileName))
            {
                for (int j = 0; j < historyCostBS2.Count; ++j)
                {
                    sw.Write(historyCostBS2[j].Item1.ToString(Parameters.DateTimeFormat));
                    sw.Write(", ");
                    double sum = 0;
                    for (int i = 0; i < 2; ++i)
                    {
                        sw.Write(historyCostBS2[j].Item2[i]);
                        sw.Write(", ");
                        sum += historyCostBS2[j].Item2[i];
                    }
                    sw.WriteLine(sum);

                    if (j % nnn == 0)
                    {
                        allCosts.Add(-sum);
                    }
                }
            }

            var maxDrawdown = GetMaximumDrawdown(allCosts);
            var linearCLC = GetNumericCLC(allCosts);

            string summary = string.Format("TotalProfit = {0}, MaxDrawdown = {1}, ProfitFactor = {2}, CLC = {3}",
                allCosts.Count == 0 ? 0 : allCosts[allCosts.Count - 1], maxDrawdown, 
                historyCostTF2.Count <= 1 ? 0 : (double)historyCostTF2[historyCostTF2.Count - 1].Item2[0] / -historyCostTF2[historyCostTF2.Count - 1].Item2[1],
                linearCLC);
            WekaUtils.Instance.WriteLog(summary);
            return ret + System.Environment.NewLine + summary;
        }

        public static string SimulateEaOrders()
        {
            string eaOrderFileName = eaOrderFileName = string.Format("{0}\\ea_order_{1}.txt", TestParameters.BaseDir, TestParameters2.CandidateParameter.MainSymbol);
            
            int nTpsl = TestParameters2.nTpsl;
            long[, , ,] costs = new long[2, TestParameters.TpMaxCount, TestParameters.SlMaxCount, 2];
            long[, , ,] dealCnts = new long[2, TestParameters.TpMaxCount, TestParameters.SlMaxCount, 2];
            long[, , ,] dealTimes = new long[2, TestParameters.TpMaxCount, TestParameters.SlMaxCount, 2];
            List<Tuple<DateTime, long[]>> historyCostTF2 = new List<Tuple<DateTime, long[]>>();
            List<Tuple<DateTime, long[]>> historyCostBS2 = new List<Tuple<DateTime, long[]>>();

            IHpData hpDatas = new HpDbData(TestParameters2.CandidateParameter.MainSymbol);
            long nowMoney = 3000000000;

            using (StreamReader sr1 = new StreamReader(eaOrderFileName))
            {
                while (true)
                {
                    if (sr1.EndOfStream)
                        break;
                    string s = sr1.ReadLine();
                    string[] ss = s.Split(new char[] { ',' });

                    DateTime nowDate = Convert.ToDateTime(ss[2]).AddMinutes(-WekaUtils.GetMinuteofPeriod(TestParameters2.CandidateParameter.MainPeriod));
                    //nowDate = nowDate.AddMinutes((new Random()).Next(15) * 15);
                    
                    var hps = hpDatas.GetHpData(nowDate);
                    if (hps == null)
                        continue;
                    long nowTime = WekaUtils.GetTimeFromDate(nowDate);
                    int selectedDeal = 2;
                    if (ss[1].Trim() == "Sell")
                        selectedDeal = 1;
                    else if (ss[1].Trim() == "Buy")
                        selectedDeal = 0;
                    else
                        throw new ArgumentException("invalid deal type.");

                    {
                        int tpp = TestParameters.GetTpSlMinDelta(TestParameters2.CandidateParameter.MainSymbol) * nTpsl;

                        int tp1 = Convert.ToInt32(ss[3]);
                        int sl1 = Convert.ToInt32(ss[4]);
                        
                        int selectedDealVol = 1;
                        int tp = tp1 / tpp - 1;
                        int sl = sl1 / tpp - 1;
                        int v = (int)(selectedDealVol * 100);
                        //v = maxPoint / sl1;
                        v = 1;
                        //v = (int)(nowMoney / 300000);
                        //v = v / Math.Min(tp, sl); //sl

                        int cv = v * hps.Item1[selectedDeal, tp, sl, 0];
                        int tpv = tp1 * cv;
                        costs[selectedDeal, tp, sl, 0] -= tpv;
                        dealCnts[selectedDeal, tp, sl, 0] += cv;
                        dealTimes[selectedDeal, tp, sl, 0] += cv * (hps.Item2[selectedDeal, tp, sl] - nowTime);

                        cv = v * hps.Item1[selectedDeal, tp, sl, 1];
                        int slv = sl1 * cv;
                        costs[selectedDeal, tp, sl, 1] += slv;
                        dealCnts[selectedDeal, tp, sl, 1] += cv;
                        dealTimes[selectedDeal, tp, sl, 1] += cv * (hps.Item2[selectedDeal, tp, sl] - nowTime);

                        nowMoney = nowMoney + tpv - slv;
                    }

                    // Stat
                    {
                        long[] costsTF2 = new long[2];
                        long[] dealCntTF2 = new long[2];
                        long[] dealTimeTF2 = new long[2];

                        long[] costsBS2 = new long[2];
                        long[] dealCntBS2 = new long[2];

                        for (int t = 0; t < 2; ++t)
                            for (int m = 0; m < 2; ++m)
                            {
                                for (int tp1 = 0; tp1 < TestParameters.TpMaxCount; ++tp1)
                                    for (int sl1 = 0; sl1 < TestParameters.SlMaxCount; ++sl1)
                                    {
                                        costsTF2[t] += costs[m, tp1, sl1, t];
                                        dealCntTF2[t] += dealCnts[m, tp1, sl1, t];
                                        dealTimeTF2[t] += dealTimes[m, tp1, sl1, t];

                                        costsBS2[m] += costs[m, tp1, sl1, t];
                                        dealCntBS2[m] += dealCnts[m, tp1, sl1, t];
                                    }
                            }

                        string ret = string.Format("{0}, {1},{2},{3}\t{4},{5},{6}\t{7},{8},{9}\t{10},{11},{12}\t{13},{14},{15}\t{16}",
                            nowDate.ToString(Parameters.DateTimeFormat),
                            (costsTF2[0] / 1e4).ToString("F2"), (costsTF2[1] / 1e4).ToString("F2"), ((costsTF2[0] + costsTF2[1]) / 1e4).ToString("F2"),
                            (costsBS2[0] / 1e4).ToString("F2"), (costsBS2[1] / 1e4).ToString("F2"), ((costsBS2[0] + costsBS2[1]) / 1e4).ToString("F2"),
                            dealCntBS2[0] == 0 ? "0" : (costsBS2[0] / dealCntBS2[0]).ToString("F0"),
                            dealCntBS2[1] == 0 ? "0" : (costsBS2[1] / dealCntBS2[1]).ToString("F0"),
                            (dealCntBS2[0] + dealCntBS2[1]) == 0 ? "0" : ((costsBS2[0] + costsBS2[1]) / (dealCntBS2[0] + dealCntBS2[1])).ToString("F0"),
                            dealCntTF2[0], dealCntTF2[1], (dealCntTF2[0] + dealCntTF2[1]) == 0 ? "0" : ((double)dealCntTF2[0] / (dealCntTF2[0] + dealCntTF2[1])).ToString("F2"),
                            dealTimeTF2[0] == 0 ? "0" : (costsTF2[0] * 1e8 / dealTimeTF2[0]).ToString("F0"),
                            dealTimeTF2[1] == 0 ? "0" : (costsTF2[1] * 1e8 / dealTimeTF2[1]).ToString("F0"),
                            (dealTimeTF2[0] + dealTimeTF2[1]) == 0 ? "0" : ((costsTF2[0] + costsTF2[1]) * 1e8 / (dealTimeTF2[0] + dealTimeTF2[1])).ToString("F0"),
                            selectedDeal);
                        //if (nowDate.Hour == 10)
                        {
                            WekaUtils.Instance.WriteLog(ret);
                        }

                        historyCostTF2.Add(new Tuple<DateTime, long[]>(nowDate, costsTF2));
                        historyCostBS2.Add(new Tuple<DateTime, long[]>(nowDate, costsBS2));
                    }
                }
            }

            string figureFileName = TestParameters.GetBaseFilePath("figure.txt");
            if (System.IO.File.Exists(figureFileName))
            {
                System.IO.File.Delete(figureFileName);
            }
            List<double> allCosts = new List<double>();
            int nnn = historyCostBS2.Count / 2000;
            nnn = Math.Max(1, nnn);
            using (StreamWriter sw = new StreamWriter(figureFileName))
            {
                for (int j = 0; j < historyCostBS2.Count; ++j)
                {
                    sw.Write(historyCostBS2[j].Item1.ToString(Parameters.DateTimeFormat));
                    sw.Write(", ");
                    double sum = 0;
                    for (int i = 0; i < 2; ++i)
                    {
                        sw.Write(historyCostBS2[j].Item2[i]);
                        sw.Write(", ");
                        sum += historyCostBS2[j].Item2[i];
                    }
                    sw.WriteLine(sum);
                    if (j % nnn == 0)
                    {
                        allCosts.Add(-sum);
                    }
                }
            }

            var maxDrawdown = GetMaximumDrawdown(allCosts);
            var linearCLC = GetNumericCLC(allCosts);
            string summary = string.Format("TotalProfit = {0}, MaxDrawdown = {1}, ProfitFactor = {2}, CLC = {3}",
                allCosts[allCosts.Count - 1], maxDrawdown, (double)historyCostTF2[historyCostTF2.Count - 1].Item2[0] / -historyCostTF2[historyCostTF2.Count - 1].Item2[1],
                linearCLC);
            WekaUtils.Instance.WriteLog(summary);
            return summary;
        }
        public static void SortEaOrders()
        {
            string eaOrderFileName = eaOrderFileName = string.Format("{0}\\ea_order_{1}.txt", TestParameters.BaseDir, TestParameters2.CandidateParameter.MainSymbol);
            if (!System.IO.File.Exists(eaOrderFileName))
                return;

            //SortedDictionary<DateTime, string> actions = new SortedDictionary<DateTime, string>();
            //using (StreamReader sr1 = new StreamReader(eaOrderFileName))
            //{
            //    while (true)
            //    {
            //        if (sr1.EndOfStream)
            //            break;
            //        string s = sr1.ReadLine();
            //        if (string.IsNullOrEmpty(s))
            //            continue;
            //        string[] ss = s.Split(new char[] { ',' });

            //        DateTime nowDate = Convert.ToDateTime(ss[2]);
            //        if (!actions.ContainsKey(nowDate))
            //        {
            //            actions[nowDate] = s;
            //        }
            //        else
            //        {
            //            DateTime nextDate = nowDate;
            //            while (true)
            //            {
            //                nextDate = nextDate.AddSeconds(30);
            //                if (!actions.ContainsKey(nextDate))
            //                    break;
            //            }
            //            actions[nextDate] = s.Replace(nowDate.ToString(Parameters.DateTimeFormat), nextDate.ToString(Parameters.DateTimeFormat));
            //        }
            //    }
            //}
            //using (StreamWriter sw = new StreamWriter(eaOrderFileName))
            //{
            //    foreach (var kvp in actions)
            //    {
            //        sw.WriteLine(kvp.Value);
            //    }
            //}

            SortedDictionary<DateTime, List<string>> actions = new SortedDictionary<DateTime, List<string>>();
            using (StreamReader sr1 = new StreamReader(eaOrderFileName))
            {
                while (true)
                {
                    if (sr1.EndOfStream)
                        break;
                    string s = sr1.ReadLine();
                    if (string.IsNullOrEmpty(s))
                        continue;
                    string[] ss = s.Split(new char[] { ',' });

                    DateTime nowDate = Convert.ToDateTime(ss[2]);
                    if (!actions.ContainsKey(nowDate))
                    {
                        actions[nowDate] = new List<string>();
                    }
                    actions[nowDate].Add(s);
                }
            }

            using (StreamWriter sw = new StreamWriter(eaOrderFileName))
            {
                foreach (var kvp in actions)
                {
                    foreach (var s in kvp.Value)
                    {
                        sw.WriteLine(s);
                    }
                }
            }
        }
    }
}
