using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public class MinDistanceClassifier: weka.classifiers.AbstractClassifier
    {
        public MinDistanceClassifier()
            :base()
        {
        }

        public MinDistanceClassifier(int tp, int sl)
            : base()
        {
        }
        //private int m_tp, m_fp;

        private weka.core.Instances m_instances;
        public override void buildClassifier(weka.core.Instances insts)
        {
            m_instances = insts;
        }

        public override double classifyInstance(weka.core.Instance instance)
        {
            if (m_instances.numInstances() == 0)
                return 2;

            if (m_instances.numAttributes() != instance.numAttributes())
            {
                throw new AssertException("different attribute.");
            }
            int n = (instance.numAttributes() - 1) / 2;
            List<Tuple<int, int>> dist = new List<Tuple<int, int>>();
            for (int i = 0; i < m_instances.numInstances(); ++i)
            {
                int d1 = 0, d2 = 0;
                weka.core.Instance instanceI = m_instances.instance(i);
                for (int j = 0; j < n; ++j)
                {
                    //d += (int)((instanceI.value(j) - instance.value(j)) * (instanceI.value(j) - instance.value(j)));
                    if (instanceI.value(j) != instance.value(j))
                    {
                        if (instance.value(j) == 2 || instanceI.value(j) == 2)
                            d1++;
                        else
                            d1 += 4;
                    }
                }
                for (int j = n; j < 2*n; ++j)
                {
                    //d += (int)((instanceI.value(j) - instance.value(j)) * (instanceI.value(j) - instance.value(j)));
                    if (instanceI.value(j) != instance.value(j))
                        if (instance.value(j) == 2 || instanceI.value(j) == 2)
                            d2++;
                        else
                            d2 += 4;
                }
                int c = (int)instanceI.classValue();
                //if (c == 0)
                //{
                //    if (d1 < n / 4 && d1 < d2)
                //    {
                //        dist.Add(new Tuple<int, int>(d1, c));
                //    }
                //}
                //else if (c == 1)
                //{
                //    if (d2 < n / 4 && d2 < d1)
                //    {
                //        dist.Add(new Tuple<int, int>(d2, c));
                //    }
                //}
                //else
                //{
                //    throw new AssertException("");
                //}
                dist.Add(new Tuple<int, int>(d1 + d2, c));
            }
            if (dist.Count == 0)
                return 2;

            dist.Sort(new Comparison<Tuple<int, int>>((x, y) =>
            {
                return x.Item1.CompareTo(y.Item1);
            }));

            int sum = 0, count = 0;
            for (int i = 0; i < dist.Count; ++i)
            {
                if (dist[i].Item1 < n / 4 * 2 * 4)
                {
                    if (dist[i].Item2 != 2 && dist[i].Item2 != 3)
                    {
                        sum += dist[i].Item2;
                        count++;
                    }
                    else
                    {
                    }
                }
                else
                    break;
            }
            if (count == 0)
                return 2;
            if (count < m_instances.numInstances() / 30)
                return 2;
            return (int)Math.Round((double)sum / count);
        }
        //public override string toString()
        //{
        //    return string.Format("{0}/{1}", m_tp, m_fp);
        //}
    }

    public class MinDistanceClassifier2 : weka.classifiers.AbstractClassifier
    {
        public MinDistanceClassifier2()
            : base()
        {
        }

        public MinDistanceClassifier2(int tp, int sl)
            : base()
        {
        }
        //private int m_tp, m_fp;

        private weka.core.Instances m_instances;
        public override void buildClassifier(weka.core.Instances insts)
        {
            m_instances = insts;
        }

        public override double classifyInstance(weka.core.Instance instance)
        {
            if (m_instances.numInstances() == 0)
                return 2;

            if (m_instances.numAttributes() != instance.numAttributes())
            {
                throw new AssertException("different attribute.");
            }
            int n = instance.numAttributes();
            List<Tuple<int, int>> dist = new List<Tuple<int, int>>();
            for (int i = 0; i < m_instances.numInstances(); ++i)
            {
                int d1 = 0, d2 = 0;
                weka.core.Instance instanceI = m_instances.instance(i);
                for (int j = 0; j < n; ++j)
                {
                    //d += (int)((instanceI.value(j) - instance.value(j)) * (instanceI.value(j) - instance.value(j)));
                    if (instanceI.value(j) != instance.value(j))
                    {
                        d1++;
                    }
                    if (instance.value(j) != 0)
                    {
                        d2++;
                    }
                }
                int c = (int)instanceI.classValue();
                
                dist.Add(new Tuple<int, int>(d1, c));
            }
            if (dist.Count == 0)
                return 2;

            dist.Sort(new Comparison<Tuple<int, int>>((x, y) =>
            {
                return x.Item1.CompareTo(y.Item1);
            }));

            int sum = 0, count = 0;
            for (int i = 0; i < dist.Count; ++i)
            {
                if (dist[i].Item1 < 4)
                {
                    sum += dist[i].Item2;
                    count++;
                }
                else
                    break;
            }
            if (count == 0)
                return 2;
            if (count < m_instances.numInstances() / 70)
                return 2;
            return (int)Math.Round((double)sum / count);
        }
        //public override string toString()
        //{
        //    return string.Format("{0}/{1}", m_tp, m_fp);
        //}
    }
}
