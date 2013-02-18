using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public static class Parameters
    {
        public static double DoubleEqualDelta = 0.000001;

        public static string DoubleFormatString = "+#.#;-#.#;0";

        public const string DateTimeFormat = "yyyy-MM-ddTHH:mm:ss";

        public static double[] DoubleArrayEmpty = new double[0];
        public static int[] IntArrayEmpty = new int[0];

        public static DateTime TrainStartTime = new DateTime(2000, 1, 1);
        public static DateTime TrainEndTime = new DateTime(2012, 12, 31);

        public static DateTime TestStartTime = new DateTime(2009, 10, 1);
        public static DateTime TestEndTime = new DateTime(2012, 12, 31);

        public static string[] AllWeeksFull = new string[] { "1", "2", "4", "8" };
        public static string[] AllSymbolsFull = new string[] { "EURUSD", "GBPUSD", "USDCHF", "USDCAD","USDJPY", "USDSEK", "AUDUSD", "EURUSDR"};
        public static string[] AllPeriodsFull = new string[] { "M1", "M5", "M15", "M30", "H1", "H4", "D1" }; //"M5", 
        public static char[] AllDealTypes = new char[] { 'B', 'S' };
        public const int AllHour = 24;

        public static string[][] PeriodTimeNames = new string[][] 
            { new string[] {"5", "15", "60", "240", "1440"},
            new string[] { "3", "12", "48", "176", "704" }, 
            new string[] { "4", "16", "64", "256" }, 
            new string[] { "4", "16", "64" },
            new string[] { "4", "16"},
            new string[] { "4"}};

        public const string NewFileAppend = "new";

        public static long TotalCanUseMemory = 6500L * 1000 * 1000;
        public static long TotalCanUseBuffer = 1600L * 1000 * 1000;


        static Parameters()
        {
            if (!Environment.Is64BitOperatingSystem)
            {
                TotalCanUseMemory = 1800L * 1000 * 1000;
                TotalCanUseBuffer = 1600L * 1000 * 1000;
            }
        }
        

        public static DateTime MtStartTime = new DateTime(1970, 1, 1, 0, 0, 0);

        public static DateTime MaxDate = new DateTime(2050, 1, 1, 0, 0, 0);
        public static long MaxTime = WekaUtils.GetTimeFromDate(MaxDate);
    }
}
