using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace MLEA
{
    public struct ZigzagRate
    {
        public DateTime time { get; set; }        // Period start time
        public double open { get; set; }        // Open price
        public double high { get; set; }         // The highest price of the period
        public double low { get; set; }         // The lowest price of the period
        public double close { get; set; }       // Close price
        public long tick_volume { get; set; } // Tick volume
        public int spread { get; set; }       // Spread
        public long real_volume { get; set; }  // Trade volume

        public double zigzag;
    }

    [Serializable]
    [System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)]
    public struct MqlRates : IComparable<MqlRates>
    {
        public Int64 time { get; set; }
        public double open { get; set; }
        public double high { get; set; }
        public double low { get; set; }
        public double close { get; set; }
        public long tick_volume { get; set; }
        public int spread { get; set; }
        public long real_volume { get; set; }

        public int CompareTo(MqlRates obj)
        {
            return this.time.CompareTo(obj.time);
        }

        public override string ToString()
        {
            return WekaUtils.GetDateFromTime(time).ToString();
        }
    }

    [System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)]
    public struct MqlTick
    {
        public Int64 time { get; set; }
        public double bid { get; set; }
        public double ask { get; set; }
    }

    [System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)]
    public struct ReturnActionInfo
    {
        public int DealType { get; set; }
        public int DealIn { get; set; }
        public int DealOut { get; set; }
        public double WinProb { get; set; }
        public double LoseProb { get; set; }
    }

    //[System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)]
    //public struct MqlTick
    //{
    //    public Int64 time;          // Time of the last prices update
    //    public double bid;           // Current Bid price
    //    public double ask;           // Current Ask price
    //    public double last;          // Price of the last deal (Last)
    //    public ulong volume;        // Volume for the current Last price
    //};

    public class AbstractEA
    {
        public string DateTimeFormat = "yyyy.MM.dd HH:mm";
        public string PriceFormat = "N5";

        private const string m_dataDirName = "E:\\Dropbox\\ForexData";
        private const string m_resultDirName = "E:\\ForexDataCalc";

        private string m_symbol = "EURUSD";
        public string Symbol
        {
            get { return m_symbol; }
            set { m_symbol = value; }
        }

        private string m_period = "M5";
        public string Period
        {
            get { return m_period; }
            set { m_period = value; }
        }

        public string GetDataPath(string fileName)
        {
            if (!string.IsNullOrEmpty(Path.GetDirectoryName(fileName)))
            {
                throw new ArgumentException(fileName + " has already a absolute path!");
            }
            //string f1 = Path.GetFileNameWithoutExtension(fileName);
            //string f2 = Path.GetExtension(fileName);
            return string.Format("{0}\\{1}\\{1}_{3}", m_dataDirName, this.Symbol, this.Period, fileName);
        }

        public string GetResultPath(string fileName)
        {
            if (!string.IsNullOrEmpty(Path.GetDirectoryName(fileName)))
            {
                throw new ArgumentException(fileName + " has already a absolute path!");
            }
            //string f1 = Path.GetFileNameWithoutExtension(fileName);
            //string f2 = Path.GetExtension(fileName);
            string ret = string.Format("{0}\\{1}\\{2}\\{1}_{2}_{3}", m_resultDirName, this.Symbol, this.Period, fileName);

            TryCreateDirectory(ret);
            return ret;
        }

        public void TryCreateDirectory(string dirName)
        {
            if (!Directory.Exists(Path.GetDirectoryName(dirName)))
            {
                Directory.CreateDirectory(Path.GetDirectoryName(dirName));
            }
        }


        //public void GenerateExcel(string destFileName, int[] selectedPos, List<double[]> zigzagValues)
        //{
        //    int rateWriteLength = 360;

        //    if (!Directory.Exists(Path.GetDirectoryName(destFileName)))
        //    {
        //        Directory.CreateDirectory(Path.GetDirectoryName(destFileName));
        //    }

        //    using (StreamWriter sw = new StreamWriter(destFileName))
        //    {
        //        for (int i = 0; i < zigzagValues[0].Length; ++i)
        //        {
        //            for (int j = 0; j < selectedPos.Length; ++j)
        //            {
        //                double d0 = zigzagValues[j][0];
        //                double d = zigzagValues[j][i];

        //                sw.Write((int)Math.Round((d - d0) * 10000));
        //                //sw.Write(d.ToString("N4"));
        //                sw.Write("\t");
        //            }
        //            sw.WriteLine();
        //        }

        //        for (int i = 0; i < rateWriteLength; ++i)
        //        {
        //            for (int j = 0; j < selectedPos.Length; ++j)
        //            {
        //                double d0 = zigzagValues[j][0];

        //                int n = selectedPos[j] + i + 1;
        //                if (n >= m_rates.Count)
        //                {
        //                    n = m_rates.Count - 1;
        //                }
        //                double d = m_rates[n].close;

        //                sw.Write((int)Math.Round((d - d0) * 10000));
        //                //sw.Write(d.ToString("N4"));
        //                sw.Write("\t");
        //            }
        //            sw.WriteLine();
        //        }
        //    }
        //}

        ///// <summary>
        /////  生成多个曲线。selectedPos为zigzag位置
        ///// </summary>
        ///// <param name="destFielName"></param>
        ///// <param name="selectedPos"></param>
        ///// <param name="zigzagWriteLength"></param>
        //public void GenerateExcel(string destFielName, int[] selectedPos, int zigzagWriteLength)
        //{
        //    int rateWriteLength = 3600;

        //    int allZigzagCount = m_zigzagValues.Count;

        //    if (!Directory.Exists(Path.GetDirectoryName(destFielName)))
        //    {
        //        Directory.CreateDirectory(Path.GetDirectoryName(destFielName));
        //    }

        //    using (StreamWriter sw = new StreamWriter(destFielName))
        //    {
        //        //double[,] data = new double[allZigzagCount - zigzagWriteLength, zigzagWriteLength];
        //        //for (int i = 0; i < allZigzagCount - zigzagWriteLength; ++i)
        //        //{
        //        //    for (int j = 0; j < zigzagWriteLength; ++j)
        //        //    {
        //        //        data[i, j] = m_zigzagValues[i + j];
        //        //    }
        //        //    for (int j = 0; j < zigzagWriteLength; ++j)
        //        //    {
        //        //        data[i, j] -= m_zigzagValues[i];
        //        //    }
        //        //}

        //        for (int i = 0; i < zigzagWriteLength; ++i)
        //        {
        //            for (int j = 0; j < selectedPos.Length; ++j)
        //            {
        //                double d0 = m_zigzagValues[selectedPos[j] - zigzagWriteLength + 1];
        //                double d = m_zigzagValues[selectedPos[j] - zigzagWriteLength + 1 + i];

        //                sw.Write((int)Math.Round((d - d0) * 10000));
        //                //sw.Write(d.ToString("N4"));
        //                sw.Write("\t");
        //            }
        //            sw.WriteLine();
        //        }

        //        for (int j = 0; j < rateWriteLength; ++j)
        //        {
        //            for (int i = 0; i < selectedPos.Length; ++i)
        //            {
        //                double d0 = m_zigzagValues[selectedPos[i] - zigzagWriteLength + 1];

        //                int n = m_zigzagToRatePos[selectedPos[i]] + j + 1;
        //                if (n >= m_rates.Count)
        //                {
        //                    n = m_rates.Count - 1;
        //                }
        //                double d = m_rates[n].close;

        //                sw.Write((int)Math.Round((d - d0) * 10000));
        //                //sw.Write(d.ToString("N4"));
        //                sw.Write("\t");
        //            }
        //            sw.WriteLine();
        //        }
        //    }
        //}

        ///// <summary>
        ///// 写到下一个Zigzag位置
        ///// </summary>
        ///// <param name="destFielName"></param>
        ///// <param name="selectedPos"></param>
        ///// <param name="zigzagWriteLength"></param>
        //public void GenerateExcel2(string destFielName, int[] selectedPos, int zigzagWriteLength)
        //{
        //    int allZigzagCount = m_zigzagValues.Count;

        //    if (!Directory.Exists(Path.GetDirectoryName(destFielName)))
        //    {
        //        Directory.CreateDirectory(Path.GetDirectoryName(destFielName));
        //    }

        //    using (StreamWriter sw = new StreamWriter(destFielName))
        //    {
        //        for (int i = 0; i < zigzagWriteLength; ++i)
        //        {
        //            for (int j = 0; j < selectedPos.Length; ++j)
        //            {
        //                double d0 = m_zigzagValues[selectedPos[j] - zigzagWriteLength + 1];
        //                double d = m_zigzagValues[selectedPos[j] - zigzagWriteLength + 1 + i];

        //                sw.Write((int)Math.Round((d - d0) * 10000));
        //                //sw.Write(d.ToString("N4"));
        //                sw.Write("\t");
        //            }
        //            sw.WriteLine();
        //        }

        //        int maxRateCount = -1;
        //        int[] rateCount = new int[selectedPos.Length];
        //        for (int i = 0; i < selectedPos.Length; ++i)
        //        {
        //            int k = 0;
        //            for (int j = 0; j < m_rates.Count; ++j)  
        //            {
        //                int n = m_zigzagToRatePos[selectedPos[i]] + j + 1;
        //                if (n >= m_rates.Count)
        //                {
        //                    n = m_rates.Count - 1;
        //                }
        //                if (m_rates[n].zigzag != 0)
        //                {
        //                    k++;
        //                    if (k == 2)
        //                    {
        //                        maxRateCount = Math.Max(maxRateCount, j);
        //                        rateCount[i] = j;
        //                        break;
        //                    }
        //                }
        //            }
        //        }

        //        for (int j = 0; j < maxRateCount; ++j)
        //        {
        //            for (int i = 0; i < selectedPos.Length; ++i)
        //            {
        //                if (j > rateCount[i])
        //                {
        //                    sw.Write(0);
        //                }
        //                else
        //                {
        //                    double d0 = m_zigzagValues[selectedPos[i] - zigzagWriteLength + 1];

        //                    int n = m_zigzagToRatePos[selectedPos[i]] + j + 1;
        //                    if (n >= m_rates.Count)
        //                    {
        //                        n = m_rates.Count - 1;
        //                    }
        //                    double d = m_rates[n].close;

        //                    sw.Write((int)Math.Round((d - d0) * 10000));
        //                    //sw.Write(d.ToString("N4"));
        //                }
        //                sw.Write("\t");
        //            }
        //            sw.WriteLine();
        //        }
        //    }
        //}

        public virtual void OnLoad()
        {
            //for (int i = 0; i < m_rates.Count; ++i)
            //{
            //    if (m_rates[i].zigzag != 0)
            //    {
            //        m_zigzagValues.Add(m_rates[i].zigzag);
            //        m_zigzagToRatePos.Add(i);
            //    }
            //}
        }

        
        public virtual void OnUnload()
        {
            //m_zigzagValues.Clear();
            //m_zigzagToRatePos.Clear();
        }

        private List<double> m_zigzagValues = new List<double>();
        private List<int> m_zigzagToRatePos = new List<int>();
        public List<double> ZigzagValues
        {
            get { return m_zigzagValues; }
        }
        public IList<int> ZigzagToRatePos
        {
            get { return m_zigzagToRatePos; }
        }

        private int m_spread = 3;
        public int Spread
        {
            get { return m_spread; }
            set { m_spread = value; }
        }

        public double Points
        {
            get 
            {
                if (WekaUtils.GetSymbolPoint(this.Symbol) == 1)
                    return 0.01;
                else
                    return 0.0001; 
            }
        }

        public bool IsTraining
        {
            get;
            set;
        }

        //public long GetDataLastTime()
        //{
        //    long n = (long)(m_rates[m_rates.Count].time - m_mtStartTime).TotalSeconds;
        //    return n;
        //}
        //public void Sync()
        //{
        //    IList<ZigzagRate> deltaRates = ReadRates(this.DeltaRateDataFilePath);
        //    if (deltaRates.Count > 0)
        //    {
        //        if (deltaRates[0].time <= m_rates[m_rates.Count - 1].time)
        //        {
        //            throw new ArgumentException("Invalid Delta Rates!");
        //        }

        //        for (int i = 0; i < deltaRates.Count; ++i)
        //        {
        //            m_rates.Add(deltaRates[i]);
        //        }
        //    }
        //}

        //private string m_deltaRateDataFileName ;
        //private string DeltaRateDataFilePath
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(m_deltaRateDataFileName))
        //        {
        //            m_deltaRateDataFileName = GetDataPath(string.Format("Z_Delta.dat"));
        //        }

        //        return m_rateDataFileName;
        //    }
        //}

        //public void Save()
        //{
        //    lock (m_lockObject)
        //    {
        //        using (System.IO.BinaryWriter br = new BinaryWriter(new FileStream(this.RateDataFilePath, FileMode.Create)))
        //        {
        //            for (int i = 0; i < m_rates.Count; ++i)
        //            {
        //                br.Write((long)(m_rates[i].time - m_mtStartTime).TotalSeconds);
        //                br.Write(m_rates[i].open);
        //                br.Write(m_rates[i].high);
        //                br.Write(m_rates[i].low);
        //                br.Write(m_rates[i].close);
        //                br.Write(m_rates[i].tick_volume);
        //                br.Write(m_rates[i].spread);
        //                br.Write(m_rates[i].real_volume);

        //                br.Write(m_rates[i].zigzag);
        //            }
        //        }
        //    }
        //}
    }
}
