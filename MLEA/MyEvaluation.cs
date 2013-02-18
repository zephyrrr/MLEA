using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public class MyEvaluation
    {
        //      0   1
        // 0    TN  FP
        // 1    FN  TP
        private int[,] m_matrix = new int[2, 2];
        private weka.classifiers.CostMatrix m_costMatrix;
        public MyEvaluation()
        {
            m_costMatrix = new weka.classifiers.CostMatrix(2);
            m_costMatrix.setElement(0, 0, -1);
            m_costMatrix.setElement(1, 1, -1);
            m_costMatrix.setElement(0, 1, 1);
            m_costMatrix.setElement(1, 0, 1);
        }
        public MyEvaluation(weka.classifiers.CostMatrix costMatrix)
        {
            m_costMatrix = costMatrix;
        }
        public double totalCost()
        {
            double sum = 0;
            for (int i = 0; i < 2; ++i)
                for (int j = 0; j < 2; ++j)
                    sum += m_matrix[i, j] * m_costMatrix.getElement(i, j);
            return sum;
        }
        public double numTruePositives(int classIndex)
        {
            return m_matrix[1, classIndex];
        }
        public double numFalsePositives(int classIndex)
        {
            return m_matrix[0, classIndex];
        }
        public double numTrueNegatives(int classIndex)
        {
            return m_matrix[1, 1 - classIndex];
        }
        public double numFalseNegatives(int classIndex)
        {
            return m_matrix[0, 1 - classIndex];
        }
        public double numInstances()
        {
            return m_matrix[0, 0] + m_matrix[0, 1] + m_matrix[1, 0] + m_matrix[1, 1];
        }

        //private weka.core.Instances m_instances;
        public void evaluateModel(double[] v, weka.core.Instances instances)
        {
            double[] c = new double[instances.numInstances()];
            for (int i = 0; i < c.Length; ++i)
            {
                c[i] = instances.instance(i).classValue();
            }
            evaluateModel(v, c);
        }

        public void evaluateModel(double[] v, double[] c)
        {
            //m_instances = instances;
            for (int i = 0; i < 2; ++i)
                for (int j = 0; j < 2; ++j)
                    m_matrix[i, j] = 0;

            for (int i = 0; i < v.Length; ++i)
            {
                if (v[i] == 1)
                {
                    if (c[i] == 1)
                    {
                        m_matrix[1, 1]++;
                    }
                    else if (c[i] == 0)
                    {
                        m_matrix[0, 1]++;
                    }
                    else if (c[i] == 2)
                    {
                    }
                    else
                    {
                        throw new AssertException("invalid classvalue");
                    }
                }
                else if (v[i] == 0)
                {
                    if (c[i] == 1)
                    {
                        m_matrix[1, 0]++;
                    }
                    else if (c[i] == 0)
                    {
                        m_matrix[0, 0]++;
                    }
                    else if (c[i] == 2)
                    {
                    }
                    else
                    {
                        throw new ArgumentException("invalid classvalue");
                    }
                }
                else if (v[i] == 2)
                {
                }
                else
                {
                    throw new AssertException("invalid v");
                }
            }
        }

        public void evaluateModel(weka.classifiers.Classifier classifier, weka.core.Instances instances)
        {
            double[] v = WekaUtils.ClassifyInstances(instances, classifier);

            //weka.classifiers.Evaluation eval = new weka.classifiers.Evaluation(instances, m_costMatrix);
            //v = eval.evaluateModel(classifier, instances);
            evaluateModel(v, instances);

            //int n = 0;
            //for (int i = 0; i < v.Length; ++i)
            //    if (v[i] != 0)
            //        n++;
        }
    }
}
