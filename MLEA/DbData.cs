using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public class DbData : Feng.Singleton<DbData>
    {
        public DbData()
        {
        }

        private Dictionary<string, MqlRates[]> m_rates = new Dictionary<string, MqlRates[]>();
        public MqlRates[] ReadRates(string symbolPeriod, string where = null)
        {
            if (string.IsNullOrEmpty(where) && m_rates.ContainsKey(symbolPeriod))
                return m_rates[symbolPeriod];

            lock (m_lockObject)
            {
                List<MqlRates> rates = new List<MqlRates>();
                string sql;
                if (string.IsNullOrEmpty(where))
                {
                    sql = string.Format("SELECT * FROM {0} ORDER BY TIME", symbolPeriod);
                }
                else
                {
                    sql = string.Format("SELECT * FROM {0} {1} ORDER BY TIME", symbolPeriod, where);
                }
                var dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(sql);

                foreach (System.Data.DataRow row in dt.Rows)
                {
                    long datetime = (long)row["Time"];
                    double open = (double)row["open"];
                    double high = (double)row["high"];
                    double low = (double)row["low"];
                    double close = (double)row["close"];
                    long tick_volume = 0;
                    int spread = (int)row["spread"];
                    long real_volume = 0;

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

                if (string.IsNullOrEmpty(where))
                {
                    m_rates[symbolPeriod] = rates.ToArray();
                    return m_rates[symbolPeriod];
                }
                else
                {
                    return rates.ToArray();
                }
            }
        }

        private string m_selectOrder = "ORDER BY Time";

        public void Clear()
        {
            if (m_allData != null)
            {
                m_allData.Clear();
            }
            m_allDataDates.Clear();
            m_batchBufferMinutes = -1;
            System.GC.Collect();
        }

        private Tuple<long, long> GetDbDateFilter(DateTime dt1, DateTime dt2, int tableType)
        {
            if (tableType == 0)
            {
                return new Tuple<long, long>(WekaUtils.GetTimeFromDate(dt1.AddDays(-1)), WekaUtils.GetTimeFromDate(dt2));
            }
            else
            {
                return new Tuple<long, long>(WekaUtils.GetTimeFromDate(dt1.AddDays(-3)), WekaUtils.GetTimeFromDate(dt2));
            }
        }

        private string GetDbDateFilter4Db(DateTime dt1, DateTime dt2, int tableType)
        {
            string filter;
            if (tableType == 0)
            {
                filter = string.Format("Time >= {0} AND Time < {1}", WekaUtils.GetTimeFromDate(dt1.AddDays(-1)), WekaUtils.GetTimeFromDate(dt2));
            }
            else
            {
                filter = string.Format("Time >= {0} AND Time < {1}", WekaUtils.GetTimeFromDate(dt1.AddDays(-3)), WekaUtils.GetTimeFromDate(dt2));
            }
            return filter;
        }

        private object m_lockObject = new object();
        private bool m_useBufferReadData = true;
        private bool m_cacheData = true;
        private Dictionary<string, ForexDataTable> m_allData;
        private Dictionary<string, Tuple<DateTime, DateTime>> m_allDataDates = new Dictionary<string, Tuple<DateTime, DateTime>>();
        private const string m_allDataCacheFile = "allDataCache_*.db";
        private bool m_serializeAllData = false;
        private double m_batchBufferMinutes = -1;
        // tableType = 0: MainTable; 1: OtherDataTable; 2:HpTable
        public ForexDataRows GetDbData(DateTime dt1, DateTime dt2, string tableName, int tableType, bool isTrain, CandidateParameter cp)
        {
            lock (m_lockObject)
            {
                //int dealTypeIdx1 = dealType == 'B' ? 0 : 1;

                DateTime prevDate = dt1.AddMinutes(-2 * cp.PrevTimeCount * WekaUtils.GetMinuteofPeriod(cp.AllPeriods[cp.PeriodCount - 1]));
                DateTime nextDate = dt2;

                if (m_useBufferReadData && m_batchBufferMinutes < 0)
                {
                    int n1 = cp.SymbolCount * cp.PeriodCount * (cp.PeriodTimeCount + 1)
                        * (cp.AllIndNames.Count + cp.AllIndNames2.Count + 5) / WekaUtils.GetMinuteofPeriod(cp.MainPeriod);
                    n1 = Math.Max(n1, 1);

                    int n2 = 1;
                    //n2 = 3 * TestParameters.BatchTps.Length * TestParameters.BatchSls.Length * Parameters.AllDealTypes.Length / WekaUtils.GetMinuteofPeriod(TestParameters.MainPeriod);
                    //n2 /= 6;
                    n2 = 10000 / WekaUtils.GetMinuteofPeriod(cp.MainPeriod);
                    n2 = Math.Max(n2, 1);

                    m_batchBufferMinutes = (Parameters.TotalCanUseBuffer - System.GC.GetTotalMemory(false)) / (n1 + n2) * WekaUtils.GetMinuteofPeriod(cp.MainPeriod);   // / 240

                    int min = (int)(nextDate - prevDate).TotalMinutes + 24 * TestParameters.BatchTestMinutes;
                    int max = (int)(1.1 * TestParameters.BatchTrainMinutes);

                    if (m_batchBufferMinutes < min)
                    {
                        //m_useBufferReadData = false;
                        WekaUtils.Instance.WriteLog(string.Format("Partial buffer. batchGetTime = {0}, min = {1}", m_batchBufferMinutes, min));
                        m_batchBufferMinutes = min;
                    }
                    else
                    {
                        //m_useBufferReadData = true;
                        WekaUtils.Instance.WriteLog(string.Format("Use buffer. batchGetTime = {0}, max = {1}", m_batchBufferMinutes, max));
                        m_batchBufferMinutes = Math.Min(m_batchBufferMinutes, max);
                    }
                }

                if (m_useBufferReadData)
                {
                    DateTime bufferDateStart = prevDate;
                    DateTime bufferDateEnd = bufferDateStart.AddMinutes(m_batchBufferMinutes);

                    if (TestParameters2.RealTimeMode)
                    {
                        if (isTrain)
                        {
                            bufferDateStart = dt1.AddDays(-7);
                            bufferDateEnd = dt2.AddDays(7);
                        }
                        else
                        {
                            bufferDateStart = dt1;
                            bufferDateEnd = dt2;
                        }
                    }
                    //System.Console.WriteLine("{0}, {1}, {2}, {3}", bufferDateStart, bufferDateEnd, prevDate, nextDate);
                    if (bufferDateEnd >= nextDate)
                    {
                        string allDataKey = tableName;
                        //if (tableType == 2)
                        //{
                        //    allDataKey += "_" + Parameters.AllDealTypes[dealTypeIdx] + "_" + tp.ToString() + "_" + sl.ToString();
                        //}

                        if (m_allData == null)
                        {
                            if (m_serializeAllData)
                            {
                                foreach (string s in System.IO.Directory.GetFiles(".", m_allDataCacheFile))
                                {
                                    string[] ss = System.IO.Path.GetFileNameWithoutExtension(s).Split(new char[] { '_' }, StringSplitOptions.RemoveEmptyEntries);
                                    DateTime d1 = Convert.ToDateTime(ss[1]);
                                    DateTime d2 = Convert.ToDateTime(ss[2]);
                                    if (bufferDateStart >= d1 && bufferDateEnd <= d2)
                                    {
                                        m_allData = Feng.Windows.Utils.SerializeHelper.Deserialize<Dictionary<string, ForexDataTable>>(s);
                                        break;
                                    }
                                }
                            }

                            if (m_allData == null)
                            {
                                m_allData = new Dictionary<string, ForexDataTable>();
                                //m_allDateDates = new DateTime[m_dealType.Length][];
                            }
                        }

                        if (m_allData.ContainsKey(allDataKey))
                        {
                            Tuple<DateTime, DateTime> ds = m_allDataDates[allDataKey];

                            bool expired = false;
                            if (!isTrain)
                            {
                                if (ds.Item2 < nextDate || ds.Item1 > prevDate)
                                {
                                    //System.Console.WriteLine("{0}, {1}, {2}, {3}", ds.Item1.ToString(), ds.Item2, prevDate, nextDate);
                                    expired = true;
                                }
                            }
                            else
                            {
                                if (ds.Item2 <= nextDate.AddMinutes(TestParameters.EnablePerhourTrain ?
                                    2 * Parameters.AllHour * TestParameters.BatchTestMinutes :
                                    2 * TestParameters.BatchTestMinutes) || ds.Item1 > prevDate)
                                    expired = true;
                            }
                            if (expired)
                            {
                                m_allData.Remove(allDataKey);
                                m_allDataDates.Remove(allDataKey);
                            }
                        }

                        //long usedMemory = System.GC.GetTotalMemory(false);
                        //if (m_cacheData && usedMemory >= Parameters.TotalCanUseMemory)
                        //{
                        //    WekaUtils.Instance.WriteLog(string.Format("Use too many memory. now total memory = {0}", usedMemory));
                        //    m_cacheData = false;
                        //}
                        //else if (!m_cacheData && usedMemory < Parameters.TotalCanUseMemory)
                        //{
                        //    WekaUtils.Instance.WriteLog(string.Format("reset to cache data. now total memory = {0}", usedMemory));
                        //    m_cacheData = true;
                        //}

                        if (m_cacheData && !m_allData.ContainsKey(allDataKey))
                        {
                            StringBuilder sql = new StringBuilder();
                            if (tableType == 0)
                            {
                                sql.Append(string.Format("SELECT [Time], [Date], [hour], [dayofweek], [spread], [close] as mainClose"));  // , [AskVolume], [BidVolume]
                            }
                            else if (tableType == 1)
                            {
                                sql.Append(string.Format("SELECT [Time], [Date]"));
                            }
                            else if (tableType == 2)
                            {
                                sql.Append(string.Format("SELECT [Time], [hp], [hp_date]"));
                            }
                            if (tableType == 0 || tableType == 1)
                            {
                                foreach (var kvp in cp.AllIndNames2)
                                {
                                    sql.Append(string.Format(",[{0}]", kvp.Key));
                                }
                                foreach (var kvp in cp.AllIndNames)
                                {
                                    sql.Append(string.Format(",[{0}]", kvp.Key));
                                }
                            }

                            sql.Append(string.Format(" FROM {0} WHERE Time >= '{1}' AND Time < '{2}' ",
                                    tableName, WekaUtils.GetTimeFromDate(bufferDateStart), WekaUtils.GetTimeFromDate(bufferDateEnd)));
                            //if (tableType == 0 || tableType == 1)
                            //{
                            //    sql.Append(" AND IsActive = 1 ");
                            //}
                            //if (tableType == 2)
                            //{
                            //    sql.Append(string.Format(" AND DealType = '{0}' AND Tp = {1} AND Sl = {2}", Parameters.AllDealTypes[dealTypeIdx], tp, sl));
                            //}
                            if (!string.IsNullOrEmpty(TestParameters.DbSelectWhere))
                            {
                                sql.Append(string.Format(" AND {0}", TestParameters.DbSelectWhere));
                            }

                            sql.Append(string.Format(" {0}", m_selectOrder));

                            string cmd = sql.ToString();

                            //m_allData[allDataKey] = DbHelper.Instance.ExecuteDataTable(cmd);
                            //m_allData[allDataKey].PrimaryKey = new System.Data.DataColumn[] { m_allData[allDataKey].Columns["Time"] };
                            m_allData[allDataKey] = new ForexDataTable(Feng.Data.DbHelper.Instance.ExecuteDataTable(cmd), tableType == 2);
                            m_allDataDates[allDataKey] = new Tuple<DateTime, DateTime>(bufferDateStart, bufferDateEnd);

                            WekaUtils.Instance.WriteLog(string.Format("Buffer Get Data From {0} to {1} of {2}", bufferDateStart, bufferDateEnd, allDataKey));
                            if (m_serializeAllData)
                            {
                                string allDataCacheFile = m_allDataCacheFile.Replace("*",
                                    TestParameters.BatchDateStart.ToString(Parameters.DateTimeFormat) + "_"
                                    + TestParameters.BatchDateEnd.ToString(Parameters.DateTimeFormat));
                                Feng.Windows.Utils.SerializeHelper.Serialize(allDataCacheFile, m_allData);
                            }
                        }

                        if (m_allData.ContainsKey(allDataKey))
                        {
                            //string filter = GetDbDateFilter(dt1, dt2, tableType);
                            //return m_allData[allDataKey].Select(filter);
                            Tuple<long, long> filter = GetDbDateFilter(dt1, dt2, tableType);
                            return m_allData[allDataKey].SelectByDate(filter.Item1, filter.Item2);
                        }
                    }
                }


                // no get from cache
                {
                    StringBuilder sql = new StringBuilder();
                    if (tableType == 0)
                    {
                        sql.Append(string.Format("SELECT [Time], [Date], [hour], [dayofweek], [spread], [close] as mainClose"));  // , [AskVolume], [BidVolume]
                    }
                    else if (tableType == 1)
                    {
                        sql.Append(string.Format("SELECT [Time], [Date]"));
                    }
                    else if (tableType == 2)
                    {
                        sql.Append(string.Format("SELECT [Time], [hp], [hp_date]"));
                    }

                    if (tableType == 0 || tableType == 1)
                    {
                        foreach (var kvp in cp.AllIndNames2)
                        {
                            sql.Append(string.Format(",[{0}]", kvp.Key));
                        }
                        foreach (var kvp in cp.AllIndNames)
                        {
                            sql.Append(string.Format(",[{0}]", kvp.Key));
                        }
                    }

                    string filter = GetDbDateFilter4Db(dt1, dt2, tableType);
                    sql.Append(string.Format(" FROM {0} WHERE {1}",
                            tableName, filter));

                    //if (tableType == 2)
                    //{
                    //    sql.Append(string.Format(" AND DealType = '{0}' AND Tp = {1} AND Sl = {2}", Parameters.AllDealTypes[dealTypeIdx], tp, sl));
                    //}
                    if (!string.IsNullOrEmpty(TestParameters.DbSelectWhere))
                    {
                        sql.Append(string.Format(" AND {0}", TestParameters.DbSelectWhere));
                    }

                    sql.Append(string.Format(" {0}", m_selectOrder));

                    string cmd = sql.ToString();

                    WekaUtils.Instance.WriteLog(string.Format("NoBuffer Get Date From {0} to {1} of {2}", prevDate, nextDate, tableName));

                    System.Data.DataTable dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(cmd);

                    //return dt.Select();
                    return new ForexDataRows(new ForexDataTable(dt, tableType == 2), 0, dt.Rows.Count);
                }
            }
        }
    }
}
