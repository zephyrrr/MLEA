using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    //public class ForexDataTimeComparer : IComparer<ForexData>
    //{
    //    public ForexDataTimeComparer(long time)
    //    {
    //        m_time = time;
    //    }
    //    private long m_time;
    //    public int Compare(ForexData x, ForexData y)
    //    {
    //        return (x.Time).CompareTo(m_time);
    //    }
    //}

    public class ForexDataRows
    {
        public ForexDataRows(ForexDataTable dt, int startIdx, int endIdx)
        {
            m_parentDataTable = dt;
            m_startIdx = startIdx;
            m_endIdx = endIdx;
            m_length = m_endIdx - m_startIdx;
        }
        private ForexDataTable m_parentDataTable;
        private int m_startIdx, m_endIdx, m_length;

        public int Length
        {
            get { return m_length; }
        }

        public ForexData this[int index]
        {
            get 
            { 
                int idx = m_startIdx + index;
#if DEBUG1
                if (idx >= 0 && idx < m_endIdx)
                {
                    return m_parentDataTable[idx];
                }
                else
                {
                    throw new AssertException("invalid idx");
                }
#else
                return m_parentDataTable.m_data[idx];
#endif
            }
        }

        public int BinarySearch(int index, int length, long toSearchTime)
        {
            int r = m_parentDataTable.BinarySearch(index + m_startIdx, length, toSearchTime);
            if (r >= m_startIdx)
                return r - m_startIdx;
            else if (r < 0)
                return r + m_startIdx;
            else
                throw new AssertException("r is invalid in BinarySearch");
        }
    }

    public class ForexDataTable
    {
        internal ForexData[] m_data;
        internal Dictionary<String, int> m_columns = new Dictionary<string, int>();

        public ForexDataTable(System.Data.DataTable dt, bool isHpData = false)
        {
            m_data = new ForexData[dt.Rows.Count];
            for (int i = 0; i < m_data.Length; ++i)
            {
                m_data[i] = new ForexData(this, dt.Rows[i], isHpData);
            }
            for (int i = 1; i < dt.Columns.Count; ++i)
            {
                m_columns[dt.Columns[i].ColumnName] = i-1;
            }
        }

        private ForexData this[int index]
        {
            get { return m_data[index]; }
        }

        public int BinarySearch(int index, int length, long toSearchTime)
        {
            return Array.BinarySearch<ForexData>(m_data, index, length, new ForexData(toSearchTime));
        }

        public ForexDataRows SelectByDate(long startTime, long endTime)
        {
            int idx1 = Array.BinarySearch<ForexData>(m_data, new ForexData(startTime));
            if (idx1 < 0)
            {
                idx1 = ~idx1;
                if (idx1 == m_data.Length)
                    return new ForexDataRows(this, idx1, idx1);
            }

            int idx2 = Array.BinarySearch<ForexData>(m_data, new ForexData(endTime));
            if (idx2 < 0)
            {
                idx2 = ~idx2;
            }

            return new ForexDataRows(this, idx1, idx2);
        }
    }

    public class ForexData : IComparable<ForexData>
    {
        internal ForexData(long t)
        {
            this.Time = t;
        }
        private bool m_isHpData = false;
        public ForexData(ForexDataTable dt, System.Data.DataRow row, bool isHpData)
        {
            m_isHpData = isHpData;
            m_parentDataTable = dt;
            m_values = new object[row.Table.Columns.Count-1];
            if (!isHpData)
            {
                for (int i = 0; i < m_values.Length; ++i)
                {
                    m_values[i] = row[i + 1];
                }
            }
            else
            {
                WekaUtils.DebugAssert(m_values.Length == 2, "hp data length is 2");

                m_values[0] = row[1];
                m_values[1] = row[2];
            }
            this.Time = (long)row[0];
        }
        private ForexDataTable m_parentDataTable;

        public long Time;
        //public long Time
        //{
        //    get { return m_time; }
        //}

        private object[] m_values;
        public object this[int index]
        {
            get
            {
                if (m_isHpData)
                {
                    if (index == 0)
                    {
                        if (m_values[0] is byte[])
                        {
                            m_values[0] = HpData.DeserializeHp((byte[])m_values[0]);
                        }
                        return m_values[0];
                    }
                    else if (index == 1)
                    {
                        if (m_values[1] is byte[])
                        {
                            m_values[1] = HpData.DeserializeHpTimes((byte[])m_values[1]);
                        }
                        return m_values[1];
                    }
                    else
                    {
                        throw new AssertException("hp data has only 2 data");
                    }
                }
                else
                {
                    return m_values[index];
                }
            }
        }
        public object this[string name]
        {
            get { return m_values[m_parentDataTable.m_columns[name]]; }
        }

        public override string ToString()
        {
            return this.Time.ToString();
        }

        public int CompareTo(ForexData obj)
        {
            return this.Time.CompareTo(obj.Time);
        }
    }

    //public class ForexHpData : ForexData
    //{
    //    private DateTime m_hpTime;
    //    private int m_hp;
    //}

    //public class ForexIndicatorData : ForexData
    //{
    //    private double[] m_values;
    //}
}
