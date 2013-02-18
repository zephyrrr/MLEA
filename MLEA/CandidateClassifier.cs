using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public class CandidateClassifier
    {
        public CandidateClassifier(string name, int tp, int sl, char dealType, int hour, CandidateParameter cp)
        {
            this.Name = name;
            this.Tp = tp;
            this.Sl = sl;
            this.DealType = dealType;
            this.Hour = hour;
            this.Deals = new DealsInfo(cp.DealInfoLastMinutes);

            this.WekaData = new WekaData(dealType, tp, sl, cp);
        }

        private weka.classifiers.CostMatrix m_costMatrix;
        public weka.classifiers.CostMatrix CostMatrix
        {
            get
            {
                if (m_costMatrix == null)
                {
                    m_costMatrix = new weka.classifiers.CostMatrix(2);
                    m_costMatrix.setElement(0, 0, 0);
                    m_costMatrix.setElement(0, 1, 1);
                    m_costMatrix.setElement(1, 0, 0);
                    m_costMatrix.setElement(1, 1, -1);
                }
                return m_costMatrix;
            }
        }
        public void SetCost(double tp, double sl)
        {
            CostMatrix.setElement(0, 1, sl);
            CostMatrix.setElement(1, 1, -tp);
        }

        public double GetCost()
        {
            return this.CostMatrix.getElement(1, 1) / CostMatrix.getElement(0, 1);
        }

        public string Name { get; private set; }
        public int Tp { get; private set; }
        public int Sl { get; private set; }
        public char DealType { get; private set; }
        public int Hour { get; private set; }

        public weka.classifiers.Classifier Classifier;
        public weka.classifiers.Classifier ExcludeClassifier;

        public IMoneyManagement MoneyManagement;

        public bool Initialized = false;

        public DealsInfo Deals { get; private set; }
        public double[] CurrentClassValue;
        public double[] CurrentTestRet;

        public WekaData WekaData;
        

        public void SetData(string str, string scv, byte[] dealsInfo, byte[] dealsData)
        {
            this.CurrentTestRet = WekaUtils.StringToDoubleArray(str);
            this.CurrentClassValue = WekaUtils.StringToDoubleArray(scv);

            var deals = Feng.Windows.Utils.SerializeHelper.Deserialize<DealsInfo>(dealsInfo);
            if (dealsData != null)
            {
                System.IO.MemoryStream outStream = new System.IO.MemoryStream();
                var inStream = new System.IO.MemoryStream(dealsData);
                System.IO.Compression.GZipStream zipStream = new System.IO.Compression.GZipStream(inStream, System.IO.Compression.CompressionMode.Decompress);
                zipStream.CopyTo(outStream);

                deals.Deals = Feng.Windows.Utils.SerializeHelper.Deserialize<List<DealInfo>>(outStream.ToArray());
            }
            else
            {
                deals.Deals = new List<DealInfo>();
            }
            if (deals != null)
            {
                this.Deals = deals;
                Initialized = true;
            }
        }

        public override string ToString()
        {
            return this.Name;
        }
    }

    
}
