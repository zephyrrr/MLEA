using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace MLEA
{
    public static class DukasData
    {
        public static MqlRates[] ReadRates(string symbolPeriod)
        {
            string[] ss1 = symbolPeriod.Split('_');
            string symbol = ss1[0];
            string period = ss1[1] == "M1" ? "min_1" : ss1[1];
            string rateFileName = string.Format("E:\\Forex\\Dukas\\{0}_BID_candles_{1}.csv", symbol, period);

            List<MqlRates> rates = new List<MqlRates>();
            using (System.IO.StreamReader sr = new StreamReader(rateFileName))
            {
                while (true)
                {
                    if (sr.EndOfStream)
                        break;

                    // Date Time, Open, Close, Low, High, Volume
                    string s = sr.ReadLine();
                    string[] ss = s.Split(new char[] { ',' });
                    long v = (long)Convert.ToDouble(ss[5]);

                    DateTime date;

                    //date = Convert.ToDateTime(ss[0]);
                    bool r = DateTime.TryParseExact(ss[0], new string[] {"dd.MM.yyyy HH:mm:ss.000", "yyyy.MM.dd HH:mm:ss"}, null, System.Globalization.DateTimeStyles.None, out date);
                    if (!r)
                        throw new InvalidCastException(string.Format("{0} is invalid as datetime", ss[0]));


                    if (date.DayOfWeek == DayOfWeek.Saturday || date.DayOfWeek == DayOfWeek.Sunday)
                        continue;

                    ////if (date.DayOfWeek == DayOfWeek.Saturday || date.DayOfWeek == DayOfWeek.Sunday)
                    //{
                    //    if (v == 0)
                    //    {
                    //        if (ss[1] == ss[2] && ss[2] == ss[3] && ss[3] == ss[4])
                    //        {
                    //            DateTime d1 = date.AddHours(5);
                    //            DateTime d2 = date.AddHours(-5);
                    //            if ((d1.DayOfWeek == DayOfWeek.Saturday || d1.DayOfWeek == DayOfWeek.Sunday)
                    //                && (d2.DayOfWeek == DayOfWeek.Saturday || d2.DayOfWeek == DayOfWeek.Sunday))
                    //                continue;
                    //        }
                    //        else
                    //        {
                    //            System.Console.WriteLine(s);
                    //        }
                    //    }
                    //    else
                    //    {

                    //    }
                    //}
                    rates.Add(new MqlRates
                    {
                        time = WekaUtils.GetTimeFromDate(date),
                        open = Convert.ToDouble(ss[1]),
                        high = Convert.ToDouble(ss[4]),
                        low = Convert.ToDouble(ss[3]),
                        close = Convert.ToDouble(ss[2]),
                        tick_volume = 0,
                        spread = 50,
                        real_volume = (long)Convert.ToDouble(ss[5]),
                    });
                }
            }

            return rates.ToArray();
        }
    }
}
