//using System;
//using System.Collections.Generic;
//using System.Text;
//using System.IO;
//using weka.core;
//using weka.classifiers;
//using java.io;
//using MLEA;

//namespace WekaEA
//{
//    public class WekaEA1
//    {
//        [System.Runtime.InteropServices.DllImport("kernel32.dll")]
//        private static extern int AllocConsole();
//        [System.Runtime.InteropServices.DllImport("kernel32.dll")]
//        private static extern int FreeConsole();

//        private weka.core.Instances m_trainInstances, m_trainInstancesNew;
//        private weka.core.Instances m_testInstances, m_testInstancesNew;

//        public void Init(string symbol)
//        {
//            return;
//            //AllocConsole();

//            java.lang.System.setOut(new PrintStream(new ByteArrayOutputStream()));
//            java.util.TimeZone.setDefault(java.util.TimeZone.getTimeZone("GMT"));
//        }

//        public void Deinit()
//        {
//            //FreeConsole();
//            WekaUtils.DeInit();
//        }

//        private bool m_isDebug = true;

//        public void Train(long nowTime, double[] dpTrain, int[] drTrain, double[] dpTest, int[] drTest)
//        {
//            return;

//            int numAttr = m_trainInstances.numAttributes() - 1;
//            if ((Parameters.AllIndNames.Count + Parameters.AllIndNames2.Count) * TestParameters.PeriodCount * TestParameters.SymbolCount * TestParameters.PrevTimeCount + 6 != numAttr)
//            {
//                throw new ArgumentException(string.Format("Invalid Parameter of numAttr!"));
//            }
//            if (dpTrain.Length % numAttr != 0 || dpTest.Length % numAttr != 0)
//            {
//                throw new ArgumentException(string.Format("Invalid Parameter of dp!"));
//            }
//            int numInstTrain = dpTrain.Length / numAttr;
//            if (drTrain.Length != numInstTrain * Parameters.AllDealTypes.Length * TestParameters.BatchTps.Length * TestParameters.BatchSls.Length)
//            {
//                throw new ArgumentException(string.Format("Invalid Parameter of dr!"));
//            }
//            int numInstTest = dpTest.Length / numAttr;
//            if (drTest.Length != numInstTest * Parameters.AllDealTypes.Length * TestParameters.BatchTps.Length * TestParameters.BatchSls.Length)
//            {
//                throw new ArgumentException(string.Format("Invalid Parameter of dr!"));
//            }

//            if (m_isDebug)
//            {
//                string debugFile = string.Format("{0}\\Train_Input.txt", TestParameters.BaseDir);
//                using (StreamWriter sw = new StreamWriter(debugFile))
//                {
//                    sw.WriteLine("Now is " + Parameters.MtStartTime.AddSeconds(nowTime));
//                    sw.WriteLine("Train Instances:");
//                    for (int i = 0; i < numInstTrain; ++i)
//                    {
//                        for (int j = 0; j < numAttr; ++j)
//                        {
//                            sw.Write(dpTrain[i * numAttr + j]);
//                            sw.Write(",");
//                        }
//                        sw.WriteLine();
//                    }
//                    sw.WriteLine(drTrain.Length + ":");
//                    for (int i = 0; i < drTrain.Length; ++i)
//                    {
//                        sw.Write(drTrain[i]);
//                        sw.Write(",");
//                    }
//                    sw.WriteLine();

//                    sw.WriteLine("Test Instances:");
//                    for (int i = 0; i < numInstTest; ++i)
//                    {
//                        for (int j = 0; j < numAttr; ++j)
//                        {
//                            sw.Write(dpTest[i * numAttr + j]);
//                            sw.Write(",");
//                        }
//                        sw.WriteLine();
//                    }
//                    sw.WriteLine(drTest.Length + ":");
//                    for (int i = 0; i < drTest.Length; ++i)
//                    {
//                        sw.Write(drTest[i]);
//                        sw.Write(",");
//                    }
//                    sw.WriteLine();
//                }
//            }

//            DateTime nowDate = Parameters.MtStartTime.AddSeconds(nowTime);
//            m_currentTestHour = nowDate.Hour;

//            WekaUtils.Instance.WriteLog(string.Format("Now is {0}", nowDate.ToString(Parameters.DateTimeFormat)));

//            for (int k = 0; k < Parameters.AllDealTypes.Length; ++k)
//            {
//                for (int tpi = 0; tpi < TestParameters.BatchTps.Length; ++tpi)
//                {
//                    for (int sli = 0; sli < TestParameters.BatchSls.Length; ++sli)
//                    {
//                        double tp = TestParameters.BatchTps[tpi];
//                        double sl = TestParameters.BatchSls[sli];

//                        m_trainInstances.clear();
//                        m_trainInstances.setRelationName(string.Format("{0}_{1}", nowDate.ToString(Parameters.DateTimeFormat), nowDate.ToString(Parameters.DateTimeFormat)));
//                        m_testInstances.clear();
//                        m_testInstances.setRelationName(string.Format("{0}_{1}", nowDate.ToString(Parameters.DateTimeFormat), nowDate.ToString(Parameters.DateTimeFormat)));

//                        for (int n = 0; n < numInstTrain; ++n)
//                        {
//                            int start = n * numAttr;
//                            DateTime date = Parameters.MtStartTime.AddSeconds(dpTrain[start + 0]);
//                            //if (m_currentTestHour != date.Hour)
//                            //    continue;

//                            int hp = drTrain[tpi * TestParameters.BatchSls.Length * Parameters.AllDealTypes.Length * numInstTrain +
//                                sli * Parameters.AllDealTypes.Length * numInstTrain +
//                                k * numInstTrain +
//                                n];

//                            AddInstance(m_trainInstances, dpTrain, hp, numAttr, n);
//                        }
//                        for (int n = 0; n < numInstTest; ++n)
//                        {
//                            int start = n * numAttr;
//                            DateTime date = Parameters.MtStartTime.AddSeconds(dpTest[start + 0]);
//                            //if (m_currentTestHour != date.Hour)
//                            //    continue;

//                            int hp = drTest[tpi * TestParameters.BatchSls.Length * Parameters.AllDealTypes.Length * numInstTest +
//                                     sli * Parameters.AllDealTypes.Length * numInstTest +
//                                     k * numInstTest +
//                                     n];
//                            AddInstance(m_testInstances, dpTest, hp, numAttr, n);
//                        }

//                        FilterArff(WekaUtils.CreateNormalFilter());

//                        if (m_isDebug)
//                        {
//                            WekaUtils.SaveInstances(m_trainInstances, string.Format("{0}\\TrainInstances.arff", TestParameters.BaseDir));
//                            WekaUtils.SaveInstances(m_trainInstancesNew, string.Format("{0}\\TrainInstancesNew.arff", TestParameters.BaseDir));
//                            WekaUtils.SaveInstances(m_testInstances, string.Format("{0}\\TestInstances.arff", TestParameters.BaseDir));
//                            WekaUtils.SaveInstances(m_testInstancesNew, string.Format("{0}\\TestInstancesNew.arff", TestParameters.BaseDir));
//                        }

//                        var clsInfo = m_classifierInfoIdxs[k, tpi, sli, m_currentTestHour];
//                        TrainandTest(clsInfo);

//                        WekaUtils.Instance.WriteLog(string.Format("Candidate Classifier: N={0}, TrN = {1}, TeN = {4}, TC={7}, TD={8}", clsInfo.Name,
//                                numInstTrain, 0, 0,
//                                clsInfo.CurrentClassValue.Length, 0, 0,
//                                clsInfo.Deals.NowScore.ToString(Parameters.DoubleFormatString), clsInfo.Deals.NowDeal));
//                        if (m_isDebug)
//                        {
//                            WekaUtils.Instance.WriteLog(clsInfo.Deals.PrintAll(true));
//                        }
//                    }
//                }
//            }

//            WekaUtils.Instance.DeInit();
//        }

//        public void Now(long nowTime, double nowPrice)
//        {
//            foreach (var kvp in m_classifierInfos)
//            {
//                kvp.Value.Deals.Now(WekaUtils.GetDateFromTime(nowTime), nowPrice);
//            }
//        }

//        public int Test(long nowTime, double[] dp)
//        {
//            int numAttr = m_testInstances.numAttributes() - 1;

//            if ((Parameters.AllIndNames.Count + Parameters.AllIndNames2.Count) * TestParameters.PeriodCount * TestParameters.SymbolCount * TestParameters.PrevTimeCount + 6 != numAttr)
//            {
//                throw new ArgumentException(string.Format("Invalid Parameter of numAttr!"));
//            }
//            if (dp.Length % numAttr != 0)
//            {
//                throw new ArgumentException(string.Format("Invalid Parameter of dp!"));
//            }
//            int numInst = dp.Length / numAttr;
//            if (numInst != 1)
//            {
//                throw new ArgumentException(string.Format("Invalid Parameter of numInst!"));
//            }

//            DateTime nowDate = Parameters.MtStartTime.AddSeconds(nowTime);
//            m_currentTestHour = nowDate.Hour;

//            if (m_isDebug)
//            {
//                string debugFile = string.Format("{0}\\Test_Input.txt", TestParameters.BaseDir);
//                using (StreamWriter sw = new StreamWriter(debugFile, true))
//                {
//                    sw.WriteLine("Now is " + nowDate);
//                    sw.WriteLine("Test Instances:");
//                    for (int j = 0; j < numAttr; ++j)
//                    {
//                        sw.Write(dp[j]);
//                        sw.Write(",");
//                    }
//                    sw.WriteLine();
//                }
//            }

//            m_testInstances.clear();
//            m_testInstances.setRelationName(string.Format("{0}_{1}", nowDate.ToString(Parameters.DateTimeFormat), nowDate.ToString(Parameters.DateTimeFormat)));

//            for (int n = 0; n < numInst; ++n)
//            {
//                int start = n * numAttr;
//                DateTime date = Parameters.MtStartTime.AddSeconds(dp[start + 0]);
//                //if (m_currentTestHour != date.Hour)
//                //    continue;

//                int hp = 1;
//                AddInstance(m_testInstances, dp, hp, numAttr, n);
//            }
//            FilterArff(WekaUtils.CreateNormalFilter());

//            TpslClassifierInfo ret = null;
//            var minScoreInfo = GetMinScoreClassifierInfo();
//            if (minScoreInfo != null)
//            {
//                double r = minScoreInfo.Classifier.classifyInstance(m_testInstancesNew.instance(0));
//                if (r == 2)
//                {
//                    ret = minScoreInfo;
//                }
//            }
//            if (m_isDebug)
//            {
//                string debugFile = string.Format("{0}\\Test_Output.txt", TestParameters.BaseDir);
//                using (StreamWriter sw = new StreamWriter(debugFile, true))
//                {
//                    sw.Write(nowDate.ToString(Parameters.DateTimeFormat));
//                    sw.Write(" : ");
//                    sw.WriteLine(ret.Name);
//                }
//            }

//            //debugFile = string.Format("{0}\\PredictByModel_Input.arff.txt", m_baseDir);
//            //using (StreamWriter sw = new StreamWriter(debugFile, true))
//            //{
//            //    sw.WriteLine(instance.ToString());
//            //}

//            return ret == null ? 0 : ( (ret.DealType == 'B' ? 1000000 : 200000) + ret.Tp * 1000 + ret.Sl);
//        }

//        public void FilterArff(weka.filters.Filter filter)
//        {
//            Instances origInstances = m_trainInstances;
//            filter.setInputFormat(origInstances);
//            if (origInstances != null && origInstances.numInstances() > 0)
//            {
//                m_trainInstancesNew = weka.filters.Filter.useFilter(origInstances, filter);
//            }

//            origInstances = m_testInstances;
//            if (origInstances != null && origInstances.numInstances() > 0)
//            {
//                m_testInstancesNew = weka.filters.Filter.useFilter(origInstances, filter);
//            }
//        }

//        public void TrainandTest(MLEA.TpslClassifierInfo classifierInfo)
//        {
//            Classifier cls = WekaUtils.TrainInstances(m_trainInstancesNew, null);
//            classifierInfo.Classifier = cls;

//            double[] cv = WekaUtils.ClassifyInstances(m_testInstancesNew, cls);

//            //if (m_enableExcludeClassifier)
//            //{
//            //    bool hasPositive = false;
//            //    for (int i = 0; i < cv.Length; ++i)
//            //    {
//            //        if (cv[i] == 2)
//            //        {
//            //            hasPositive = true;
//            //            break;
//            //        }
//            //    }
//            //    if (hasPositive)
//            //    {
//            //        // Exclude
//            //        string modelFileName4Exclude = GetExcludeModelFileName(classifierInfo.Name);
//            //        classifierInfo.ExcludeClassifier = WekaUtils.TryLoadClassifier(modelFileName4Exclude);
//            //        if (classifierInfo.ExcludeClassifier != null)
//            //        {
//            //            double[] cv2 = WekaUtils.ClassifyInstances(testInstancesNew, classifierInfo.ExcludeClassifier);
//            //            // cv2 == 0 -> is class, otherwise = double.NaN;
//            //            for (int i = 0; i < cv.Length; ++i)
//            //            {
//            //                cv[i] = cv[i] == 2 && cv2[i] != 0 ? 2 : 0;
//            //            }
//            //        }
//            //    }
//            //}

//            classifierInfo.CurrentTestRet = cv;

//            Instances testInstances = m_testInstances;
//            classifierInfo.CurrentClassValue = new double[testInstances.numInstances()];
//            for (int i = 0; i < testInstances.numInstances(); ++i)
//            {
//                classifierInfo.CurrentClassValue[i] = testInstances.instance(i).classValue();
//            }

//            for (int i = 0; i < testInstances.numInstances(); i++)
//            {
//                if (cv[i] == 2)
//                {
//                    double openPrice = testInstances.instance(i).value(testInstances.attribute("mainClose"));
//                    double closePriceTp, closePriceSl;
//                    if (classifierInfo.DealType == 'B')
//                    {
//                        closePriceTp = openPrice + classifierInfo.Tp * 0.0001;
//                        closePriceSl = openPrice - classifierInfo.Sl * 0.0001;
//                    }
//                    else
//                    {
//                        closePriceTp = openPrice - classifierInfo.Tp * 0.0001;
//                        closePriceSl = openPrice + classifierInfo.Sl * 0.0001;
//                    }
//                    classifierInfo.Deals.AddDeal(WekaUtils.GetDateTimeValueFromInstances(testInstances, 0, i),
//                        openPrice,
//                        classifierInfo.DealType,
//                        closePriceTp, closePriceSl);
//                }
//            }
//        }

//        private void AddInstance(Instances hereInstances, double[] dp, int hp, int numAttr, int n)
//        {
//            int posDp = n * numAttr;
//            double mainClose = dp[posDp + 5];
//            int posInst = 0;

//            double[] instanceValue = new double[hereInstances.numAttributes()];
//            for (int i = 0; i < 6; ++i)
//            {
//                if (i == 0 || i == 1)
//                    instanceValue[posInst] = dp[posDp + i] * 1000;
//                else
//                    instanceValue[posInst] = dp[posDp + i];
//                posInst++;
//            }

//            posDp += 6;
//            for (int s = 0; s < TestParameters.SymbolCount; ++s)
//            {
//                for (int i = 0; i < TestParameters.PeriodCount; ++i)
//                {
//                    for (int p = 0; p < TestParameters.PrevTimeCount; ++p)
//                    {
//                        foreach (var kvp in Parameters.AllIndNames2)
//                        {
//                            double v = (double)dp[posDp];
//                            double ind = WekaUtils.NormalizeValue(kvp.Key, kvp.Value, v, mainClose, Parameters.AllSymbols[s] == "USDJPY" ? 1 : 100);
//                            instanceValue[posInst] = ind;
//                            posDp++; posInst++;
//                        }

//                        for (int j = -1; j < Math.Max(0, Math.Min(TestParameters.PeriodTimeCount - i, TestParameters.PeriodTimeNames[i].Length)); ++j)
//                        {
//                            foreach (var kvp in Parameters.AllIndNames)
//                            {
//                                double v = (double)dp[posDp];
//                                double ind = WekaUtils.NormalizeValue(kvp.Key, kvp.Value, v, mainClose, Parameters.AllSymbols[s] == "USDJPY" ? 1 : 100);
//                                instanceValue[posInst] = ind;
//                                posDp++; posInst++;
//                            }
//                        }
//                    }
//                }
//            }
//            System.Diagnostics.Debug.Assert(posDp == (n + 1) * numAttr);
//            System.Diagnostics.Debug.Assert(posInst == numAttr);

//            //int hp = 1;
//            instanceValue[posInst] = hp;

//            Instance instance = new weka.core.DenseInstance(1, instanceValue);
//            instance.setDataset(hereInstances);
//            hereInstances.add(instance);
//        }
//    }
//}
