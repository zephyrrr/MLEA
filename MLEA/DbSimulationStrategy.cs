using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public class DbSimulationStrategy
    {
        public DbSimulationStrategy(string symbol, double tp, double sl)
        {
            m_tp = (int)(tp);
            m_sl = (int)(sl);
            m_symbol = symbol;
        }
        private string m_symbol;
        private int m_tp, m_sl;

        private bool? Do(DateTime openDate, double openPrice, out DateTime? closeDate, int dealType)
        {
            closeDate = DateTime.MinValue;
            var dt = Feng.Data.DbHelper.Instance.ExecuteDataTable(string.Format("SELECT * FROM {0}_HP WHERE Time = {1}", m_symbol, WekaUtils.GetTimeFromDate(openDate)));
            if (dt.Rows.Count == 0)
                return null;
            sbyte?[, ,] hp = HpData.DeserializeHp((byte[])dt.Rows[0]["hp"]);
            long?[, ,] hpTime = HpData.DeserializeHpTimes((byte[])dt.Rows[0]["hp_date"]);

            int ix = (int)m_tp / TestParameters.GetTpSlMinDelta(m_symbol) - 1;
            int iy = (int)m_sl / TestParameters.GetTpSlMinDelta(m_symbol) - 1;
            if (hp[dealType, ix, iy].HasValue)
            {
                closeDate = WekaUtils.GetDateFromTime(hpTime[dealType, ix, iy].Value);
                return hp[dealType, ix, iy].Value == 1;
            }
            return null;
        }
        public bool? DoBuy(DateTime openDate, double openPrice, out DateTime? closeDate)
        {
            return Do(openDate, openPrice, out closeDate, 0);
        }

        public bool? DoSell(DateTime openDate, double openPrice, out DateTime? closeDate)
        {
            return Do(openDate, openPrice, out closeDate, 1);
        }
    }
}
