using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NetSVMLight;
using System.IO;

namespace NetSVMLightConsoleApplication1
{
    class Program
    {
        static void Main(string[] args)
        {
            //ENTER FULL PATH OF EXECUTABLES.

            SVMLearn learner = new SVMLearn();
            learner.mode = Mode.Classification;
            learner.kernelType = Kernel.Linear ;
            //learner.ParamC = 2;
            //learner.ParamD = 2;
            //learner.LeaveOneOutCrossValidation = true;
            //learner.ParamG = 5;
            //learner.TrainingErrorAndMarginTradeoff = 10;
            learner.Cost = 0.55; //high cost model
            learner.RemoveInconsistentTrainingExamples = true;
            
            Utilities u = new Utilities();
            
            SVMLearn[] learners = new SVMLearn[10];
            Dictionary<double, Results> cvResults = new Dictionary<double, Results>(10);
            String outputFolder = @"";

            u.ConstructNFolds(@"", 10, outputFolder, r => r.StartsWith("-"));

            for (int counter = 0; counter < 10; counter++)
            {
                learners[counter] = new SVMLearn();
                learners[counter].mode = Mode.Classification;
                learners[counter].kernelType = Kernel.Linear;
                learners[counter].Cost = 0.35 + counter * 0.20;
                learners[counter].RemoveInconsistentTrainingExamples = true;

                cvResults.Add(learners[counter].Cost, u.PerformCrossValidation(outputFolder, false, learners[counter]));
            }


            StreamWriter learningRate = new StreamWriter(Path.Combine(outputFolder, "learning.txt"));

            foreach (KeyValuePair<double, Results> entry in cvResults)
            {
                Console.WriteLine("Cost: {0}: Accuracy {1}, Precision {2}, Recall {3}",
                    entry.Key, entry.Value.accuracy, entry.Value.precision, entry.Value.recall);

                learningRate.WriteLine(entry.Key + ", " + entry.Value.accuracy + ", " + 
                    entry.Value.precision + ", " + entry.Value.recall);
            }

            Console.ReadLine();
        }
    }
}
