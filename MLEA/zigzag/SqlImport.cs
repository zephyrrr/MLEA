using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using Feng.Data;

namespace MLEA
{
    public class SqlTest
    {
        public static void GetOptimizedTpsl()
        {
            try
            {
                System.Data.DataTable dt = DbHelper.Instance.ExecuteDataTable("SELECT top 200000 * FROM TICKSIMU WHERE BUY = 1");
                long maxSum = long.MinValue;
                int maxtp = 0, maxsl = 0;
                for (int tp = 0; tp < 202; ++tp)
                    for (int sl = 0; sl < 202; ++sl)
                    {
                        long sum = 0;
                        int start = -1, end = -1;
                        long nowTime = -1;
                        for (int i = 0; i < dt.Rows.Count; ++i)
                        {
                            long itime = (long)dt.Rows[i]["time"];

                            if (start == -1)
                            {
                                nowTime = itime;
                                start = i;
                                continue;
                            }
                            if (nowTime != itime)
                            {
                                end = i;

                                int profit = int.MinValue;
                                for (int j = start; j < end; ++j)
                                {
                                    int itp = (int)dt.Rows[j]["tp"];
                                    int isl = -(int)dt.Rows[j]["sl"];

                                    if (sl > isl)
                                    {
                                        if (tp <= itp)
                                        {
                                            profit = Math.Max(profit, tp);
                                        }
                                    }
                                    else
                                    {
                                        profit = Math.Max(profit, -sl);
                                        break;
                                    }
                                }

                                if (profit == int.MinValue)
                                {
                                    profit = 0;
                                }
                                sum += profit;

                                nowTime = itime;
                                start = i;
                            }
                        }

                        if (sum > maxSum)
                        {
                            maxSum = sum;
                            maxtp = tp;
                            maxsl = sl;
                        }
                    }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }
    }
    public class SqlImport
    {
        public static void ImportSimu(int openIdx, bool isBuy, System.Data.Common.DbTransaction txn)
        {
            double openPrice = isBuy ? s_simu.Ticks[openIdx].ask : s_simu.Ticks[openIdx].bid;

            int tp = 0, sl = 0;
            bool notSaved = true;
            for (int i = openIdx + 1; i < s_simu.Ticks.Length; ++i)
            {
                double nowPrice = isBuy ? s_simu.Ticks[i].bid : s_simu.Ticks[i].ask;
                int delta = (int)Math.Round((nowPrice - openPrice) * 10000);
                if (!isBuy)
                    delta = -delta;

                if (delta > tp)
                {
                    tp = delta;
                    notSaved = true;

                    if (tp > 200)
                        break;
                }
                else if (delta < sl)
                {
                    // Save
                    if (notSaved && tp != 0 && sl != 0)
                    {
                        if (tp > 10 && sl < -10)
                        {
                            SaveTickSimu(openIdx, isBuy, tp, sl, txn);
                            notSaved = false;
                        }
                    }

                    sl = delta;

                    if (sl < -200)
                        break;
                }
            }

            if (notSaved)
            {
                SaveTickSimu(openIdx, isBuy, tp, sl, txn);
            }
        }
        private static void SaveTickSimu(int openIdx, bool isBuy, int tp, int sl, System.Data.Common.DbTransaction txn)
        {
            SqlCommand cmd = new SqlCommand("INSERT INTO [TickSimu] ([time], [buy], [tp],[sl]) VALUES (@time, @buy, @tp, @sl)");
            cmd.Parameters.AddWithValue("@time", s_simu.Ticks[openIdx].time);
            cmd.Parameters.AddWithValue("@buy", isBuy);
            cmd.Parameters.AddWithValue("@tp", tp);
            cmd.Parameters.AddWithValue("@sl", sl);
            cmd.Transaction = txn as SqlTransaction;
            DbHelper.Instance.ExecuteNonQuery(cmd);
        }

        private static TickSimulator s_simu = new TickSimulator(new AbstractEA());

        public static void ImportTick()
        {
            s_simu.OnLoad();

            try
            {
                int bufferCnt = 10000;
                int n = 0;
                var txn = DbHelper.Instance.BeginTransaction();

                int begin = 36445740;
                Console.WriteLine(begin);
                for (int i = begin; i < s_simu.Ticks.Length; ++i)
                {
                    SqlCommand cmd = new SqlCommand("INSERT INTO [Tick] ([time],[bid],[ask]) VALUES (@time, @bid, @ask)");
                    cmd.Parameters.AddWithValue("@time", s_simu.Ticks[i].time);
                    cmd.Parameters.AddWithValue("@bid", s_simu.Ticks[i].bid);
                    cmd.Parameters.AddWithValue("@ask", s_simu.Ticks[i].ask);
                    cmd.Transaction = txn as SqlTransaction;
                    DbHelper.Instance.ExecuteNonQuery(cmd);

                    ImportSimu(i, true, txn);
                    ImportSimu(i, false, txn);

                    n++;

                    if (n >= bufferCnt)
                    {
                        try
                        {
                            Console.WriteLine(" - " + i);
                            DbHelper.Instance.CommitTransaction(txn);
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine(ex.Message);
                            DbHelper.Instance.RollbackTransaction(txn);

                            i -= n;
                        }
                        Console.WriteLine(i);
                        txn = DbHelper.Instance.BeginTransaction();
                        n = 0;
                    }
                }
                //DbHelper.Instance.CommitTransaction(txn);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }
    }
}
