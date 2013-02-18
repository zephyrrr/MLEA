using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace MLEA
{
    public static class MT5Data
    {
        private static object m_lockObject = new object();
        private static string[] mqlFilePaths = new string[] { "C:\\Users\\All Users\\MetaQuotes\\Terminal\\Common\\Files",
            "C:\\ProgramData\\MetaQuotes\\Terminal\\Common\\Files",
            "D:\\Program Files\\MetaTrader 5\\MQL5\\Files"};
        public static MqlRates[] ReadRates(string symbolPeriod)
        {
            string rateFileName = null;
            foreach (var s in mqlFilePaths)
            {
                rateFileName = string.Format("{0}\\{1}.dat", s, symbolPeriod);
                if (File.Exists(rateFileName))
                    break;
            }
            if (!File.Exists(rateFileName))
                return new MqlRates[0];

            lock (m_lockObject)
            {
                List<MqlRates> rates = new List<MqlRates>();
                using (System.IO.BinaryReader br = new BinaryReader(new FileStream(rateFileName, FileMode.Open)))
                {
                    while (br.BaseStream.Length > br.BaseStream.Position)
                    {
                        long datetime = br.ReadInt64();
                        double open = br.ReadDouble();
                        double high = br.ReadDouble();
                        double low = br.ReadDouble();
                        double close = br.ReadDouble();
                        long tick_volume = br.ReadInt64();
                        int spread = br.ReadInt32();
                        long real_volume = br.ReadInt64();

                        rates.Add(new MqlRates
                        {
                            time = datetime,
                            open = open,
                            high = high,
                            low = low,
                            close = close,
                            tick_volume = tick_volume,
                            spread = spread,
                            real_volume = real_volume,
                        });
                    }
                }

                return rates.ToArray();
            }
        }

        public static Dictionary<long, double> ReadIndicators(string symbolPeriodTime, string indName)
        {
            string fileName = null;
            foreach (var s in mqlFilePaths)
            {
                fileName = string.Format("{0}\\{1}_{2}.dat", s, symbolPeriodTime, indName);
                if (File.Exists(fileName))
                    break;
            }
            if (!System.IO.File.Exists(fileName))
            {
                throw new ArgumentException("There is no indicator file of " + fileName);
            }

            Dictionary<long, double> rates = new Dictionary<long, double>();
            using (System.IO.BinaryReader br = new BinaryReader(new FileStream(fileName, FileMode.Open)))
            {
                while (br.BaseStream.Length > br.BaseStream.Position)
                {
                    long datetime = br.ReadInt64();
                    double v1 = br.ReadDouble();

                    rates[datetime] = v1;
                }
            }

            return rates;
        }
    }
}
