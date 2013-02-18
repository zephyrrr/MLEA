using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public class CandidateParameter
    {
        public CandidateParameter Clone()
        {
            CandidateParameter that = this.MemberwiseClone() as CandidateParameter;
            that.BatchTps = new int[this.BatchTps.Length];
            this.BatchTps.CopyTo(that.BatchTps, 0);
            that.BatchSls = new int[this.BatchSls.Length];
            this.BatchSls.CopyTo(that.BatchSls, 0);

            that.AllIndNames = new Dictionary<string, int>();
            foreach (var i in this.AllIndNames)
                that.AllIndNames.Add(i.Key, i.Value);
            that.AllIndNames2 = new Dictionary<string, int>();
            foreach (var i in this.AllIndNames2)
                that.AllIndNames2.Add(i.Key, i.Value);

            that.AllSymbols = new string[this.AllSymbols.Length];
            for (int i = 0; i < that.AllSymbols.Length; ++i)
                that.AllSymbols[i] = this.AllSymbols[i];
            that.AllPeriods = new string[this.AllPeriods.Length];
            for (int i = 0; i < that.AllPeriods.Length; ++i)
                that.AllPeriods[i] = this.AllPeriods[i];

            return that;
        }
        public string Name
        {
            get;
            set;
        }

        public int DealInfoLastMinutes = 2 * 4 * 7 * 24 * 12 * 5;

        public CandidateParameter(string name)
        {
            this.Name = name;

            this.AllSymbols = new string[Parameters.AllSymbolsFull.Length];
            for(int i=0; i<this.AllSymbols.Length; ++i)
                this.AllSymbols[i] = Parameters.AllSymbolsFull[i];
            this.AllPeriods = new string[Parameters.AllPeriodsFull.Length];
            for (int i = 0; i < this.AllPeriods.Length; ++i)
                this.AllPeriods[i] = Parameters.AllPeriodsFull[i];

            InitTpsls(10, TestParameters.TpMaxCount, TestParameters.SlMaxCount);

            InitIndicators();
        }

        public int Group
        {
            get;
            set;
        }

        public void InitTpsls(int delta, int count1, int count2)
        {
            InitTpsls(0, delta, count1, 0, delta, count2);
        }
        public void InitTpsls(int tpStart, int tpDelta, int tpCount, int slStart, int slDelta, int slCount)
        {
            BatchTps = new int[tpCount];
            for (int j = 0; j < BatchTps.Length; ++j)
            {
                BatchTps[j] = tpDelta * (j + 1);
            }

            BatchSls = new int[slCount];
            for (int j = 0; j < BatchSls.Length; ++j)
            {
                BatchSls[j] = slDelta * (j + 1);
            }
        }

        public int[] BatchSls;
        public int[] BatchTps;


        public Dictionary<string, int> AllIndNames = new Dictionary<string, int>();
        public Dictionary<string, int> AllIndNames2 = new Dictionary<string, int>();

        public void InitIndicators()
        {
            // 1: 0~100: (v - 50) * 2 * 0.01
            // 2: (-price):-0.01~0.01:(v - price) * 100
            // 3: 0~0.01: (v * 100 - 0.5) * 2
            // 4: -0.01~0.01: v * 100
            // 5: -500~500: v * 0.002
            // 6: 0~1: (v - 0.5) * 2
            // 7: -100~0: (v + 50) * 2 * 0.01
            // 8: -1~1: nothing
            // 9: 0~0.01: v * 100

            AllIndNames2["close"] = 2;
            AllIndNames2["open"] = 2;
            AllIndNames2["high"] = 2;
            AllIndNames2["low"] = 2;

            AllIndNames["ADXWilder_14"] = -1;   // 3line
            AllIndNames["ADXWilder_14_P"] = -1;
            AllIndNames["ADXWilder_14_M"] = -1;
            AllIndNames["ADX_14"] = -1;         // 3line
            AllIndNames["ADX_14_P"] = -1;
            AllIndNames["ADX_14_M"] = -1;
            AllIndNames["AMA_9_2_30"] = 2;
            AllIndNames["ATR_14"] = 9;
            AllIndNames["Bands_20_2"] = 2;     //3line
            AllIndNames["BearsPower_13"] = -4;
            AllIndNames["BullsPower_13"] = -4;
            AllIndNames["CCI_14"] = -5;
            AllIndNames["Demarker_14"] = -6;
            AllIndNames["DEMA_14"] = -2;
            AllIndNames["FrAMA_14"] = -2;
            AllIndNames["MACD_12_26_9_M"] = 4;
            AllIndNames["MACD_12_26_9_S"] = 4;
            AllIndNames["MA_10"] = 2;
            //inds["Momentum_14"] = 0.01;  //97-103?    // ind25
            //inds["OsMA_12_26_9"] = double.MinValue; // MACD - SIGNAL  // ind26
            AllIndNames["RSI_14"] = 1;
            AllIndNames["RVI_10_M"] = -8;         // 2Line
            AllIndNames["RVI_10_S"] = -8;
            //AllIndNames["SAR_002_02"] = 2;
            //AllIndNames["StdDev_20"] = -3;
            AllIndNames["Stochastic_5_3_3_M"] = -1;
            AllIndNames["Stochastic_5_3_3_S"] = -1;
            AllIndNames["TEMA_14"] = -2;
            AllIndNames["Trix_14"] = -4;
            AllIndNames["VIDyA_9_12"] = -2;
            AllIndNames["WPR_14"] = -7;
            WekaUtils.DebugAssert(AllIndNames.Count == 27, "AllIndNames.Count == 27");

            ////All
            //AllIndNames2["open"] = 2;
            //AllIndNames2["close"] = 2;
            //AllIndNames2["high"] = 2;
            //AllIndNames2["low"] = 2;

            //AllIndNames["ADXWilder_14"] = 1;   // 3line
            //AllIndNames["ADXWilder_14_P"] = 1;
            //AllIndNames["ADXWilder_14_M"] = 1;
            //AllIndNames["ADX_14"] = 1;         // 3line
            //AllIndNames["ADX_14_P"] = 1;
            //AllIndNames["ADX_14_M"] = 1;
            //AllIndNames["AMA_9_2_30"] = 2;
            //AllIndNames["ATR_14"] = 9;
            //AllIndNames["Bands_20_2"] = 2;     //3line
            //AllIndNames["BearsPower_13"] = 4;
            //AllIndNames["BullsPower_13"] = 4;
            //AllIndNames["CCI_14"] = 5;
            //AllIndNames["Demarker_14"] = 6;
            //AllIndNames["DEMA_14"] = 2;
            //AllIndNames["FrAMA_14"] = 2;
            //AllIndNames["MACD_12_26_9_M"] = 4;
            //AllIndNames["MACD_12_26_9_S"] = 4;
            //AllIndNames["MA_10"] = 2;
            ////inds["Momentum_14"] = 0.01;  //97-103?    // ind25
            ////inds["OsMA_12_26_9"] = double.MinValue; // MACD - SIGNAL  // ind26
            //AllIndNames["RSI_14"] = 1;
            //AllIndNames["RVI_10_M"] = 8;         // 2Line
            //AllIndNames["RVI_10_S"] = 8;
            ////AllIndNames["SAR_002_02"] = 2;
            //AllIndNames["StdDev_20"] = -3;
            //AllIndNames["Stochastic_5_3_3_M"] = 1;
            //AllIndNames["Stochastic_5_3_3_S"] = 1;
            //AllIndNames["TEMA_14"] = 2;
            //AllIndNames["Trix_14"] = 4;
            //AllIndNames["VIDyA_9_12"] = 2;
            //AllIndNames["WPR_14"] = 7;

            if (this.MainPeriod == "M1")
            {
                List<string> allIndNames = new List<string>();
                foreach (var kvp in AllIndNames)
                    allIndNames.Add(kvp.Key);
                foreach (var s in allIndNames)
                    AllIndNames[s] = -1;
            }
        }

        public void DeleteUnusedIndicators()
        {
            List<string> deletedIndNames = new List<string>();
            foreach (var kvp in AllIndNames)
            {
                if (kvp.Value < 0)
                    deletedIndNames.Add(kvp.Key);
            }
            foreach (string s in deletedIndNames)
            {
                AllIndNames.Remove(s);
            }

            deletedIndNames.Clear();
            foreach (var kvp in AllIndNames2)
            {
                if (kvp.Value < 0)
                    deletedIndNames.Add(kvp.Key);
            }
            foreach (string s in deletedIndNames)
            {
                AllIndNames2.Remove(s);
            }
        }

        public string MainPeriod
        {
            get { return PeriodStart == -1 ? null : this.AllPeriods[PeriodStart]; }
        }
        public string MainSymbol
        {
            get { return SymbolStart == -1 ? null : this.AllSymbols[SymbolStart]; }
        }

        public int SymbolCount = -1;      // 6
        public int SymbolStart = -1;

        public int PeriodCount = -1;     // "M5", "M15", "H1"
        public int PeriodStart = -1;
        //private string m_symbolPeriod2 = m_symbol + (m_symbolPeriod2_cnt > 0 ? "_M5" : string.Empty) + (m_symbolPeriod2_cnt > 1 ? "_M15" : string.Empty) + (m_symbolPeriod2_cnt > 2 ? "_H1" : string.Empty) + (m_symbolPeriod2_cnt > 3 ? "_H4" : string.Empty);

        public int PeriodTimeCount = 0; // m_periodTimeNames
        //private string m_symbolPeriodTime2 = m_symbol + (PeriodTimeCount > 0 ? "_3" : string.Empty) + (PeriodTimeCount > 1 ? "_12" : string.Empty);

        public int PrevTimeCount = 1;    // Prev: 5

        public string[] AllSymbols = null;
        public string[] AllPeriods = null;

        public Type MoneyManagementType = null;

        public Type ClassifierType = null;
    }
}
