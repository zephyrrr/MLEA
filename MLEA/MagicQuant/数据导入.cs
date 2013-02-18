using System;
using Ats.Core;
using Ats.Indicators;
using System.Data.SqlClient;

namespace MLEA.MagicQuant
{
    public class 数据导入 : Strategy
    {
        public override void Init()
        {
            //策略开始时执行  
        }

        public static DateTime MtStartTime = new DateTime(1970, 1, 1, 0, 0, 0);
        public static long GetTimeFromDate(DateTime date)
        {
            return (long)(date - MtStartTime).TotalSeconds;
        }
        public override void Run()
        {
            //数据到来时执行  
            // Imprt To DB
            Future future = DefaultFuture;
            var bars = GetFutureBarSeries(DefaultFutureCode, 1, EnumBarType.分钟, 2);
            var lastBar = bars.Last;
            var sql = string.Format("INSERT INTO [{0}_M1] ([Time],[Date],[hour],[dayofweek],[open],[close],[high],[low],[spread]) VALUES ({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9})",
                DefaultFutureCode,
                GetTimeFromDate(lastBar.EndTime), "'" + lastBar.EndTime.ToString("yyyy-MM-dd HH:mm:ss") + "'", lastBar.EndTime.Hour, (int)lastBar.EndTime.DayOfWeek,
                lastBar.Open, lastBar.Close, lastBar.High, lastBar.Low, 0);
            //Print(sql);
            try
            {
                using (var conn = new SqlConnection("Data Source=192.168.0.10, 8033;Initial Catalog=Forex;User ID=sa;Password=qazwsxedc"))
                {
                    var cmd = new SqlCommand(sql, conn);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                Print(ex.Message);
            }
        }

        public override void Exit()
        {
            //策略退出时执行 
        }

        //[Task(Time="10:00")]
        //void MyTask()
        //{
        //    //10:00准时执行
        //}

        public override void OnOrder(FutureOrder order)
        {
            //委托状态变化时执行
        }

        public override void OnTrade(FutureTrade trade)
        {
            ////成交回报时执行
            //GetFuturePositions();
            //double a = 3.14;
            //int b = int.Parse( Math.Round(a,0).ToString() );
        }
    }
}