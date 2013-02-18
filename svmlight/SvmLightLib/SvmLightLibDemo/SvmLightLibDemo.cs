/*==========================================================================;
 *
 *  (c) 2009 mIHA.  All rights reserved.
 *
 *  File:          SvmLightLibDemo.cs
 *  Version:       1.0
 *  Desc:		   SVM^light and SVM^multiclass C# demo
 *  Author:        Miha Grcar 
 *  Created on:    Apr-2009
 *  Last modified: Apr-2009 
 *  Revision:      Apr-2009
 * 
 ***************************************************************************/

using System;
using System.IO;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Diagnostics;

namespace SvmLightLibDemo
{
    /* .-----------------------------------------------------------------------
       |		 
       |  Class SvmLightLibDemo 
       |
       '-----------------------------------------------------------------------
    */
    public static class SvmLightLibDemo
    {
        private static List<int> ReadFeatureVectors(StreamReader reader)
        {
            string line;
            List<int> feature_vectors = new List<int>();
            while ((line = reader.ReadLine()) != null)
            {
                if (!line.StartsWith("#"))
                {
                    Match label_match = new Regex(@"^(?<label>[+-]?\d+([.]\d+)?)(\s|$)").Match(line);
                    Debug.Assert(label_match.Success);
                    int label = Convert.ToInt32(label_match.Result("${label}"));
                    Match match = new Regex(@"(?<feature>\d+):(?<weight>[-]?[\d\.]+)").Match(line);                    
                    List<int> features = new List<int>();
                    List<float> weights = new List<float>();
                    while (match.Success)
                    {
                        int feature = Convert.ToInt32(match.Result("${feature}"));
                        float weight = Convert.ToSingle(match.Result("${weight}"), System.Globalization.CultureInfo.InvariantCulture);
                        match = match.NextMatch();
                        features.Add(feature);
                        weights.Add(weight);
                    }
                    int vec_id = SvmLightLib.NewFeatureVector(features.Count, features.ToArray(), weights.ToArray(), label);
                    feature_vectors.Add(vec_id);
                }
            }
            return feature_vectors;
        }

        public static void Main(string[] args)
        {
            // *** Test SVM^light inductive mode ***
            Console.WriteLine("Testing SVM^light inductive mode ...");
            Console.WriteLine("Training ...");
            StreamReader reader = new StreamReader(@"..\..\..\Examples\Inductive\train.dat");
            List<int> train_set = ReadFeatureVectors(reader);
            reader.Close();
            int model_id = SvmLightLib.TrainModel("", train_set.Count, train_set.ToArray());
            Console.WriteLine("Classifying ...");
            reader = new StreamReader(@"..\..\..\Examples\Inductive\test.dat");
            List<int> test_set = ReadFeatureVectors(reader);
            reader.Close();
            int correct = 0;
            foreach (int vec_id in test_set)
            {
                int true_lbl = (int)SvmLightLib.GetFeatureVectorLabel(vec_id);
                SvmLightLib.Classify(model_id, 1, new int[] { vec_id });
                Debug.Assert(SvmLightLib.GetFeatureVectorClassifScoreCount(vec_id) == 1);
                double result = SvmLightLib.GetFeatureVectorClassifScore(vec_id, 0);
                int predicted_lbl = result > 0 ? 1 : -1;
                if (true_lbl == predicted_lbl) { correct++; }
            }
            Console.WriteLine("Accuracy: {0:0.00}%", (double)correct / (double)test_set.Count * 100.0);
            // cleanup
            SvmLightLib.DeleteModel(model_id);
            foreach (int vec_id in train_set) { SvmLightLib.DeleteFeatureVector(vec_id); }
            foreach (int vec_id in test_set) { SvmLightLib.DeleteFeatureVector(vec_id); }
            // *** Test SVM^light transductive mode ***
            Console.WriteLine("Testing SVM^light transductive mode ...");
            Console.WriteLine("Training ...");
            reader = new StreamReader(@"..\..\..\Examples\Transductive\train_transduction.dat");
            train_set = ReadFeatureVectors(reader);
            reader.Close();
            model_id = SvmLightLib.TrainModel("", train_set.Count, train_set.ToArray());
            Console.WriteLine("Classifying ...");
            reader = new StreamReader(@"..\..\..\Examples\Transductive\test.dat");
            test_set = ReadFeatureVectors(reader);
            reader.Close();
            correct = 0;
            foreach (int vec_id in test_set)
            {
                int true_lbl = (int)SvmLightLib.GetFeatureVectorLabel(vec_id);
                SvmLightLib.Classify(model_id, 1, new int[] { vec_id });
                Debug.Assert(SvmLightLib.GetFeatureVectorClassifScoreCount(vec_id) == 1);
                double result = SvmLightLib.GetFeatureVectorClassifScore(vec_id, 0);
                int predicted_lbl = result > 0 ? 1 : -1;
                if (true_lbl == predicted_lbl) { correct++; }
            }
            Console.WriteLine("Accuracy: {0:0.00}%", (double)correct / (double)test_set.Count * 100.0);            
            // cleanup
            SvmLightLib.DeleteModel(model_id);
            foreach (int vec_id in train_set) { SvmLightLib.DeleteFeatureVector(vec_id); }
            foreach (int vec_id in test_set) { SvmLightLib.DeleteFeatureVector(vec_id); }
            // *** Test SVM^multiclass ***
            Console.WriteLine("Testing SVM^multiclass ...");
            Console.WriteLine("Training ...");
            reader = new StreamReader(@"..\..\..\Examples\Multiclass\train.dat");
            train_set = ReadFeatureVectors(reader);
            reader.Close();
            model_id = SvmLightLib.TrainMulticlassModel("-c 5000", train_set.Count, train_set.ToArray());
            Console.WriteLine("Classifying ...");
            reader = new StreamReader(@"..\..\..\Examples\Multiclass\test.dat");
            test_set = ReadFeatureVectors(reader);
            reader.Close();
            correct = 0;
            foreach (int vec_id in test_set)
            {
                int true_lbl = (int)SvmLightLib.GetFeatureVectorLabel(vec_id);
                SvmLightLib.MulticlassClassify(model_id, 1, new int[] { vec_id });
                int n = SvmLightLib.GetFeatureVectorClassifScoreCount(vec_id);
                double max_score = double.MinValue;
                int predicted_lbl = -1;
                for (int i = 0; i < n; i++)
                {
                    double score = SvmLightLib.GetFeatureVectorClassifScore(vec_id, i);
                    if (score > max_score) { max_score = score; predicted_lbl = i + 1; }
                }
                if (true_lbl == predicted_lbl) { correct++; }
            }
            Console.WriteLine("Accuracy: {0:0.00}%", (double)correct / (double)test_set.Count * 100.0);
            // cleanup
            SvmLightLib.DeleteMulticlassModel(model_id);
            foreach (int vec_id in train_set) { SvmLightLib.DeleteFeatureVector(vec_id); }
            foreach (int vec_id in test_set) { SvmLightLib.DeleteFeatureVector(vec_id); }
        }
    }
}
