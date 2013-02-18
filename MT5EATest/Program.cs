using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Runtime.InteropServices;

namespace MT5EATest
{
    static class Program
    {
        [DllImport("MT5EA.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern long HelloDllTest(string say);

        [DllImport("MT5EA.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern void HelloServiceTest(long hHandle, string say);

        [DllImport("MT5EA.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern long CreateEAService(string symbol);

        [DllImport("MT5EA.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern void DestroyEAService(long hHandle);

        //[DllImport("MT5EA.dll", CharSet = CharSet.Auto, SetLastError = true)]
        //private static extern void Train(long hHandle, long nowTime, int numInst, int numAttr, double[] p, int numHp, int[] r, int numInst2, double[] p2, int[] r2);

        //[DllImport("MT5EA.dll", CharSet = CharSet.Auto, SetLastError = true)]
        //private static extern int Test(long hHandle, long nowTime, int numAttr, double[] p);

        //[DllImport("MT5EA.dll", CharSet = CharSet.Auto, SetLastError = true)]
        //private static extern void Now(long hHandle, long nowTime, double nowPrice);

        /// <summary>
        /// 应用程序的主入口点。
        /// </summary>
        [STAThread]
        static void Main()
        {
            // Test Dll
            HelloDllTest("HelloDllTest is OK.");

            long l = CreateEAService("EURUSD");
            HelloServiceTest(l, "HelloServiceTest is OK.");

            //// Get Sample Data
            //string sDate = null;
            //using (System.IO.StreamReader sr = new System.IO.StreamReader("E:\\Forex\\Common\\EURUSD_2011-01-01_2011-01-10.B.arff"))
            //{
            //    while (true)
            //    {
            //        if (sr.EndOfStream)
            //            break;
            //        string s = sr.ReadLine();
            //        if (s == "@data")
            //        {
            //            sDate = sr.ReadLine();
            //            break;
            //        }
            //    }
            //}
            //if (string.IsNullOrEmpty(sDate))
            //{
            //    throw new ArgumentException("sData is null!");
            //}
            //string[] ss = sDate.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            //double[] p = new double[ss.Length - 1];
            //for (int i = 0; i < p.Length; ++i)
            //{
            //    if (i == 0 || i == 1)
            //        p[i] = MLEA.WekaUtils.GetTimeFromDate(Convert.ToDateTime(ss[i]));
            //    else
            //        p[i] = Convert.ToDouble(ss[i]);
            //}
            //double desiredResult = Convert.ToInt32(ss[ss.Length - 1]);

            //int[] r = new int[MLEA.Parameters.AllDealTypes.Length * MLEA.TestParameters.BatchTps.Length * MLEA.TestParameters.BatchSls.Length];
            //for(int i=0; i<r.Length; ++i)
            //{
            //    r[i] = Convert.ToInt32(ss[ss.Length - 1]);
            //}

            ////double[] p = new double[] { 12, 1, -0.00470, 0.00018, -0.00599, 32.94248, 27.89818, 0.00340, 0.00309, 0.00950, -0.01259, -0.00642, -194.92856, 0.25506, 0.00284, 0.00825, -0.00323, -0.00116, 0.00793, 99.07912, -0.00207, 18.39803, -0.38480, 0.01379, 0.00516, 6.19189, 5.35095, 0.00024, -0.00015, 0.00832, -94.01392, 0.01095, -0.00470, 0.01219, -0.00599, 28.75189, 17.80081, 0.01043, 0.00461, 0.01526, -0.01740, 0.00078, -272.97846, 0.15990, 0.00678, 0.01132, -0.00439, -0.00303, 0.01080, 98.22785, -0.00136, 22.44501, -0.16444, 0.02010, 0.00620, 28.60198, 45.45041, 0.00470, -0.00030, 0.01581, -95.53479, 0.00924, -0.00470, 0.01556, -0.00599, 48.74191, 51.67761, 0.01474, 0.00816, 0.02578, -0.02411, -0.00256, -220.01392, 0.10490, 0.00843, -0.00204, -0.00956, -0.00752, 0.01701, 97.52870, -0.00204, 18.97786, -0.13998, 0.02554, 0.01173, 9.90923, 25.26659, 0.00527, -0.00073, 0.02337, -96.81324, 0.01301, -0.00470, 0.01789, -0.00599, 32.76760, 41.81406, 0.02389, 0.01248, 0.04359, -0.03671, -0.01283, -203.61735, 0.11834, 0.01552, 0.01913, -0.01525, -0.01182, 0.02978, 95.95653, -0.00343, 21.01851, -0.19909, 0.04495, 0.01957, 15.25073, 19.41129, 0.01062, -0.00114, 0.04393, -98.18131 };

            //Train(l, (long)(new DateTime(2010, 2, 1) - new DateTime(1970, 1, 1)).TotalSeconds, 
            //    1, p.Length, p, r.Length, r, 1, p, r);

            //double[] rp = p;
            //int rr = Test(l, (long)(new DateTime(2010, 3, 2) - new DateTime(1970, 1, 1)).TotalSeconds, p.Length, rp);

            //MessageBox.Show("Example result is " + rr.ToString());
            //if (rr != (int)desiredResult)
            //{
            //    throw new ArgumentException("result is not same!");
            //}
            
            DestroyEAService(l);
        }
    }
}
