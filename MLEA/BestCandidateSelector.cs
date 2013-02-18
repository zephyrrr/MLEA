using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public interface IBestCandidateSelector
    {
        List<CandidateClassifier> GetBestClassifierInfo(ParameterdCandidateStrategy parent);
    }

    public class BestCandidateSelector1 : IBestCandidateSelector
    {
        public BestCandidateSelector1(int choiceType)
        {
            m_choiceType = choiceType;
        }
        private int m_choiceType;
        public List<CandidateClassifier> GetBestClassifierInfo(ParameterdCandidateStrategy parent)
        {
            double[] sum = new double[Parameters.AllDealTypes.Length];
            double[] oscsum = new double[Parameters.AllDealTypes.Length];

            for (int k = 0; k < Parameters.AllDealTypes.Length; ++k)
            {
                sum[k] = 0;
                oscsum[k] = 0;
            }
            parent.IterateClassifierInfos2( (cc) =>
            {
                sum[WekaUtils.GetDealTypeIdx(cc.DealType)] += cc.Deals.NowScore;
            });

            int oscCnt = 0;

            parent.IterateClassifierInfos((k, i, j, h) =>
            {
                if (TestParameters.EnablePerhourTrain)
                {
                    if (h != parent.CurrentTestHour)
                        return true;
                }
                if (k > 0)
                    return true;

                if (parent.m_classifierInfoIdxs[0, i, j, h].Deals.NowScore <= 0 && parent.m_classifierInfoIdxs[1, i, j, h].Deals.NowScore <= 0)
                {
                    oscsum[0] += parent.m_classifierInfoIdxs[0, i, j, h].Deals.NowScore;
                    oscsum[1] += parent.m_classifierInfoIdxs[1, i, j, h].Deals.NowScore;
                    oscCnt++;
                }
                return true;
            });

            //for (int k = 0; k < Parameters.AllDealTypes.Length; ++k)
            //{
            //    sum[k] -= oscsum[k];
            //}
            //double oscsums = oscsum[0] + oscsum[1];

            int selectedDeal = -1;
            if (sum[0] < sum[1] && sum[0] < 0)
            {
                selectedDeal = 0;
            }
            else if (sum[1] < sum[0] && sum[1] < 0)
            {
                selectedDeal = 1;
            }
            if (selectedDeal == -1)
                return null;

            if (oscCnt > 400)
                return null;

            //selectedDeal = 1 - selectedDeal;

            List<CandidateClassifier> ret = new List<CandidateClassifier>();
            parent.IterateClassifierInfos((k, i, j, h) =>
            {
                if (k != selectedDeal)
                    return;

                if (TestParameters.EnablePerhourTrain)
                {
                    if (h != parent.CurrentTestHour)
                        return;
                }

                switch (m_choiceType)
                {
                    case 0:
                        //if (parent.m_classifierInfoIdxs[k, i, j, h].Deals.NowScore < 0)// && parent.m_classifierInfoIdxs[1 - k, i, j, h].Deals.NowScore > 0)
                        {
                            ret.Add(parent.m_classifierInfoIdxs[k, i, j, h]);
                        }
                        break;
                    //case 1:
                    //    if (parent.m_classifierInfoIdxs[k, i, j, h].Deals.NowScore > 0 && parent.m_classifierInfoIdxs[1 - k, i, j, h].Deals.NowScore > 0)
                    //    {
                    //        ret.Add(parent.m_classifierInfoIdxs[k, i, j, h]);
                    //    }
                    //    break;
                    //case 2:
                    //    if (parent.m_classifierInfoIdxs[k, i, j, h].Deals.NowScore < 0 && parent.m_classifierInfoIdxs[1 - k, i, j, h].Deals.NowScore > 0)
                    //    {
                    //        ret.Add(parent.m_classifierInfoIdxs[k, i, j, h]);
                    //    }
                    //    break;
                    //case 3:
                    //    if (parent.m_classifierInfoIdxs[k, i, j, h].Deals.NowScore > 0 && parent.m_classifierInfoIdxs[1 - k, i, j, h].Deals.NowScore < 0)
                    //    {
                    //        ret.Add(parent.m_classifierInfoIdxs[k, i, j, h]);
                    //    }
                    //    break;

                    case 4:
                        if (parent.m_classifierInfoIdxs[k, i, j, h].Deals.NowScore < 0 && parent.m_classifierInfoIdxs[1 - k, i, j, h].Deals.NowScore > 0)
                        {
                            ret.Add(parent.m_classifierInfoIdxs[1 - k, i, j, h]);
                        }
                        break;
                    //case 5:
                    //    if (parent.m_classifierInfoIdxs[k, i, j, h].Deals.NowScore > 0 && parent.m_classifierInfoIdxs[1 - k, i, j, h].Deals.NowScore > 0)
                    //    {
                    //        ret.Add(parent.m_classifierInfoIdxs[1 - k, i, j, h]);
                    //    }
                    //    break;
                    //case 6:
                    //    if (parent.m_classifierInfoIdxs[k, i, j, h].Deals.NowScore < 0 && parent.m_classifierInfoIdxs[1 - k, i, j, h].Deals.NowScore > 0)
                    //    {
                    //        ret.Add(parent.m_classifierInfoIdxs[1 - k, i, j, h]);
                    //    }
                    //    break;
                    //case 7:
                    //    if (parent.m_classifierInfoIdxs[k, i, j, h].Deals.NowScore > 0 && parent.m_classifierInfoIdxs[1 - k, i, j, h].Deals.NowScore < 0)
                    //    {
                    //        ret.Add(parent.m_classifierInfoIdxs[1 - k, i, j, h]);
                    //    }
                    //    break;
                }
            });
            return ret;
        }

        public override string ToString()
        {
            return "BestCandidateSelector: type = " + m_choiceType.ToString();
        }
    }
}


/*
 * private List<CandidateClassifier> GetOscClassifiedClassifierInfo()
        {
            double[] sum = new double[Parameters.AllDealTypes.Length];
            double[] oscsum = new double[Parameters.AllDealTypes.Length];

            for (int k = 0; k < Parameters.AllDealTypes.Length; ++k)
            {
                sum[k] = 0;
                oscsum[k] = 0;
            }
            IterateClassifierInfos((k, i, j, h) =>
            {
                if (TestParameters.EnablePerhourTrain)
                {
                    if (h != m_currentTestHour)
                        return;
                }
                sum[k] += m_classifierInfoIdxs[k, i, j, h].Deals.NowScore;
            });

            IterateClassifierInfos((k, i, j, h) =>
            {
                if (TestParameters.EnablePerhourTrain)
                {
                    if (h != m_currentTestHour)
                        return true;
                }
                if (k > 0)
                    return true;

                if (m_classifierInfoIdxs[0, i, j, h].Deals.NowScore <= 0 && m_classifierInfoIdxs[1, i, j, h].Deals.NowScore <= 0)
                {
                    oscsum[0] += m_classifierInfoIdxs[0, i, j, h].Deals.NowScore;
                    oscsum[1] += m_classifierInfoIdxs[1, i, j, h].Deals.NowScore;
                }
                return true;
            });

            for (int k = 0; k < Parameters.AllDealTypes.Length; ++k)
            {
                sum[k] -= oscsum[k];
            }
            double oscsums = oscsum[0] + oscsum[1];

            int selectedDeal = -1;
            double min = -1;
            if (sum[0] < sum[1] && sum[0] < 0)
            {
                selectedDeal = 0;
                min = sum[0];
            }
            if (sum[1] < sum[0] && sum[1] < 0)
            {
                selectedDeal = 1;
                min = sum[1];
            }
            if (selectedDeal == -1)
                return null;

            bool reverse = false;
            if (oscsums < min)
            {
                reverse = true;
                selectedDeal = 1 - selectedDeal;
            }

            if (reverse)
                return null;

            List<CandidateClassifier> ret = new List<CandidateClassifier>();
            IterateClassifierInfos((k, i, j, h) =>
            {
                if (k != selectedDeal)
                    return;

                if (TestParameters.EnablePerhourTrain)
                {
                    if (h != m_currentTestHour)
                        return;
                }

                if (m_classifierInfoIdxs[k, i, j, h].Deals.NowScore >= 0)
                    return;

                if (!reverse)
                {
                    if (m_classifierInfoIdxs[k, i, j, h].Deals.NowScore <= 0 && m_classifierInfoIdxs[1-k, i, j, h].Deals.NowScore <= 0)
                        return;
                }
                else
                {
                    if (m_classifierInfoIdxs[k, i, j, h].Deals.NowScore <= 0 && m_classifierInfoIdxs[1 - k, i, j, h].Deals.NowScore >= 0)
                        return;
                }
                ret.Add(m_classifierInfoIdxs[k, i, j, h]);
            });
            return ret;
        }

        private List<CandidateClassifier> GetOscEnabledClassifierInfo()
        {
            double[] sum = new double[Parameters.AllDealTypes.Length];
            for (int k = 0; k < Parameters.AllDealTypes.Length; ++k)
            {
                sum[k] = 0;
            }
            int oscCnt = 0;
            IterateClassifierInfos((k, i, j, h) =>
            {
                if (TestParameters.EnablePerhourTrain)
                {
                    if (h != m_currentTestHour)
                        return;
                }
                sum[k] += m_classifierInfoIdxs[k, i, j, h].Deals.NowScore;
            });

            IterateClassifierInfos((k, i, j, h) =>
            {
                if (TestParameters.EnablePerhourTrain)
                {
                    if (h != m_currentTestHour)
                        return true;
                }
                if (k > 0)
                    return false;

                if (m_classifierInfoIdxs[0, i, j, h].Deals.NowScore < 0 && m_classifierInfoIdxs[1, i, j, h].Deals.NowScore < 0)
                {
                    oscCnt++;
                }
                return true;
            });

            int selectedDeal = -1;
            if (sum[0] < sum[1] && sum[0] < 0)
            {
                selectedDeal = 0;
            }
            if (sum[1] < sum[0] && sum[1] < 0)
            {
                selectedDeal = 1;
            }
            if (selectedDeal == -1)
                return null;

            if (oscCnt > 100)
            {
                selectedDeal = 1 - selectedDeal;
                return null;
            }

            List<CandidateClassifier> ret = new List<CandidateClassifier>();
            IterateClassifierInfos((k, i, j, h) =>
            {
                if (k != selectedDeal)
                    return;

                if (TestParameters.EnablePerhourTrain)
                {
                    if (h != m_currentTestHour)
                        return;
                }

                if (m_classifierInfoIdxs[k, i, j, h].Deals.NowScore >= 0)
                    return;

                ret.Add(m_classifierInfoIdxs[k, i, j, h]);
            });
            return ret;
        }

        private List<CandidateClassifier> GetAvgClassifierInfo()
        {
            double[] avg1 = new double[Parameters.AllDealTypes.Length];
            double[] avg2 = new double[Parameters.AllDealTypes.Length];
            double[] sum = new double[Parameters.AllDealTypes.Length];
            for (int k = 0; k < Parameters.AllDealTypes.Length; ++k)
            {
                avg1[k] = avg2[k] = sum[k] = 0;
            }
            IterateClassifierInfos((k, i, j, h) =>
                {
                    if (TestParameters.EnablePerhourTrain)
                    {
                        if (h != m_currentTestHour)
                            return;
                    }

                    //avg1[k] += m_classifierInfoIdxs[k, i, j, h].Tp * m_classifierInfoIdxs[k, i, j, h].Deals.NowScore;
                    //avg2[k] += m_classifierInfoIdxs[k, i, j, h].Sl * m_classifierInfoIdxs[k, i, j, h].Deals.NowScore;

                    sum[k] += m_classifierInfoIdxs[k, i, j, h].Deals.NowScore;
                });
            for (int k = 0; k < Parameters.AllDealTypes.Length; ++k)
            {
                avg1[k] /= sum[k];
                avg2[k] /= sum[k];
            }

            int selectDeal = -1;
            if (sum[0] < sum[1] && sum[0] < 0)
                selectDeal = 0;
            else if (sum[1] < sum[0] && sum[1] < 0)
                selectDeal = 1;
            if (selectDeal == -1)
                return null;

            //int tp = (int)Math.Round(avg1[selectDeal]);
            //int sl = (int)Math.Round(avg2[selectDeal]);
            //int tpslDelta = int.MaxValue;
            //TpslClassifierInfo ret = null;
            //IterateClassifierInfos((k, i, j, h) =>
            //{
            //    if (TestParameters.EnablePerhourTrain)
            //    {
            //        if (h != m_currentTestHour)
            //            return;
            //    }

            //    if (k != selectDeal)
            //        return;

            //    int delta = Math.Abs(m_classifierInfoIdxs[k, i, j, h].Tp - tp) + Math.Abs(m_classifierInfoIdxs[k, i, j, h].Sl - sl);
            //    if (delta < tpslDelta)
            //    {
            //        tpslDelta = delta;
            //        ret = m_classifierInfoIdxs[k, i, j, h];
            //    }
            //});

            List<CandidateClassifier> ret = new List<CandidateClassifier>();
            IterateClassifierInfos((k, i, j, h) =>
            {
                if (k != selectDeal)
                    return;

                if (TestParameters.EnablePerhourTrain)
                {
                    if (h != m_currentTestHour)
                        return;
                }

                if (m_classifierInfoIdxs[k, i, j, h].Deals.NowScore >= 0)
                    return;

                ret.Add(m_classifierInfoIdxs[k, i, j, h]);
            });
            return ret;
        }
 
  private CandidateClassifier GetMinClassifierInfo()
        {
            double minScore = double.MaxValue;
            int minNum = 0;
            CandidateClassifier minScoreInfo = null;

            foreach (var kvp in m_classifierInfos)
            {
                if (TestParameters.EnablePerhourTrain)
                {
                    if (kvp.Value.Hour != m_currentTestHour)
                        continue;
                }

                double cost = kvp.Value.Deals.NowScore;
                int num = kvp.Value.Deals.NowDeal;
                //double score = num == 0 ? 0 : cost / num;
                double score = cost;
                if ((score < minScore) || (score == minScore && num > minNum)) // num == 0 && minTc >= 0) || 
                {
                    minScore = score;
                    minNum = num;
                    minScoreInfo = kvp.Value;
                }
            }
            if (minScoreInfo == null || minScore == double.MaxValue)
            {
                WekaUtils.Instance.WriteLog("No Candidate Classifier.");
                return null;
            }

            // Check other conditions
            if (minScore < 0)
            {
                // 和B，S中Score小的一致
                if (m_classifierInfoIdxs.GetLength(0) == 2)
                {
                    double[] costPerDeal = GetTotalCostByDealType();
                    if (costPerDeal[0] <= costPerDeal[1])
                    {
                        if (minScoreInfo.DealType != Parameters.AllDealTypes[0] || costPerDeal[0] >= 0)
                        {
                            minScore = 0;
                        }
                    }
                    else
                    {
                        if (minScoreInfo.DealType != Parameters.AllDealTypes[1] || costPerDeal[1] >= 0)
                        {
                            minScore = 0;
                        }
                    }
                }
            }

            if (minScore < 0)
            {
                return minScoreInfo;
            }
            else
            {
                return null;
            }
        }      
        
 */
