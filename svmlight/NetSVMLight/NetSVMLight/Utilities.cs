using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace NetSVMLight
{
    public class Utilities
    {
        private Random positiveInstanceRNG = new Random(10);
        private Random negativeInstanceRNG = new Random(9);

        /// <summary>
        /// Returns whether a file exists on disk in the system path.
        /// </summary>
        /// <param name="file">File that we are looking for</param>
        /// <returns>True if found</returns>
        internal static bool ExistsInPath(String file)
        {
            if (File.Exists(Path.GetFullPath(file)))
            {
                return true;
            }

            String paths = Environment.GetEnvironmentVariable("PATH");
            if (String.IsNullOrEmpty(paths))
            {
                return false;
            }

            foreach (String path in paths.Split(';'))
            {
                if (File.Exists(Path.Combine(path, file)))
                {
                    return true;
                }
            }

            return false;
        }


        /// <summary>
        /// Perform Fisher-Yates shuffle on the input list. Performs in place shuffle in O(n)
        /// </summary>
        /// <param name="inputList">List to be shuffled</param>
        private void ShuffleList(List<CheapFeatureVector> inputList)
        {
            Random random = new Random();
            int n = inputList.Count;
            while (n > 1)
            {
                //get a random index and swap
                int randomIndex = random.Next(n--);
                CheapFeatureVector temp = inputList[randomIndex];
                inputList[randomIndex] = inputList[n];
                inputList[n] = temp;
            }
        }

        /// <summary>
        /// Gets the number of positive and negative training examples in the file
        /// </summary>
        /// <param name="exampleFile">The file that is to be used</param>
        /// <param name="numPositiveExamples">Will contain the number of -ve examples after the function returns</param>
        /// <param name="numNegtiveExamples">Will contain the number of +ve examples after the function returns</param>
        public static void GetNumberOfTrainingExamples(String exampleFile, out int numPositiveExamples,
            out int numNegtiveExamples, Predicate<String> isNegativeLabel)
        {
            numPositiveExamples = numNegtiveExamples = 0;
            using (StreamReader reader = new StreamReader(exampleFile))
            {
                while (!reader.EndOfStream)
                {
                    if (isNegativeLabel(reader.ReadLine()))
                    {
                        numNegtiveExamples++;
                    }

                    else
                    {
                        numPositiveExamples++;
                    }

                }
            }
        }

        /// <summary>
        /// Loads the entire example file into memory. DO NOT TRY WITH A LARGE EXAMPLE FILE.
        /// </summary>
        /// <param name="exampleFile">File to be split into training and test</param>
        /// <param name="trainingFile">Training file to be created</param>
        /// <param name="testFile">Test file to be created</param>
        /// <param name="trainingFraction">Proportion of instances in training set</param>
        /// <param name="shuffle">Whether to shuffle the dataset before splitting into training and test</param>
        /// <param name="skip">A test for whether a particular line from the file is to be skipped</param>
        /// <param name="isPositiveLabel">A test for whether this particular line represents
        /// a negatively labeled feature vector</param>
        public void ConstructTrainingAndTestSets(String exampleFile, String trainingFile,
            String testFile, double trainingFraction, bool shuffle, Predicate<String> skip,
            Predicate<String> isNegativeLabel)
        {
            StreamWriter trainingWriter = new StreamWriter(trainingFile);
            StreamWriter testWriter = new StreamWriter(testFile);

            if (!File.Exists(exampleFile))
            {
                throw new Exception("Could not find example file");
            }

            List<CheapFeatureVector> examples = new List<CheapFeatureVector>();
            int numPositiveExamples = 0, numNegativeExamples = 0;

            using (StreamReader reader = new StreamReader(exampleFile))
            {

                try
                {
                    String line;
                    while (!reader.EndOfStream)
                    {
                        line = reader.ReadLine();

                        if (skip(line)) //if the line is to be skipped, then forgo this loop
                            continue;

                        bool label;
                        if (isNegativeLabel(line))
                        {
                            label = false;
                            numNegativeExamples++;
                        }

                        else
                        {
                            label = true;
                            numPositiveExamples++;
                        }

                        examples.Add(new CheapFeatureVector 
                        { 
                            instance = line,
                            label = label
                            
                        });
                    }

                    reader.Close();

                    //shuffle the list
                    if (shuffle)
                    {
                        this.ShuffleList(examples); 
                    }
                    
                    int numPositiveTrainingExamples = (int)(trainingFraction * numPositiveExamples);
                    int numNegativeTrainingExamples = (int)(trainingFraction * numNegativeExamples);

                    //assuming that the relative ordering of the positive and negative examples is also
                    //randomized due to the sort

                    //first write the training instances
                    int counter = 0, positiveCounter = 0;
                    for (; counter < examples.Count
                        && positiveCounter < numPositiveTrainingExamples; counter++)
                    {
                        if (examples[counter].label == true && examples[counter].flag == false)
                        {
                            trainingWriter.WriteLine(examples[counter].instance);
                            examples[counter].flag = true;  //mark that it has already been taken
                            positiveCounter++;
                        }
                    }

                    if (positiveCounter < numPositiveTrainingExamples)
                    {
                        throw new Exception("Something went wrong in the counts of positive examples");
                    }

                    counter = 0;
                    int negativeCounter = 0;

                    for (; counter < examples.Count
                        && negativeCounter < numNegativeTrainingExamples; counter++)
                    {
                        if (examples[counter].label == false && examples[counter].flag == false)
                        {
                            trainingWriter.WriteLine(examples[counter].instance);
                            examples[counter].flag = true;  //mark that it has been taken
                            negativeCounter++;
                        }
                    }

                    if (negativeCounter < numNegativeTrainingExamples)
                    {
                        throw new Exception("Something went wrong in the counts of negative examples");
                    }

                    int positiveTestInstances = 0;
                    int negativeTestInstances = 0;
                    //write positive test instances. these are all the remaining positive instances in the
                    //example file. use all of them
                    foreach (var cheapFeatureVector in examples.
                        Where(example => example.flag == false && example.label == true))
                    {
                        testWriter.WriteLine(cheapFeatureVector.instance);
                        positiveTestInstances++;
                    }

                    //write negative test instances
                    foreach (var cheapFeatureVector in examples.
                        Where(example => example.flag == false && example.label == false))
                    {
                        testWriter.WriteLine(cheapFeatureVector.instance);
                        negativeTestInstances++;
                    }

                    Console.WriteLine("Positive examples: {0}, Positive training examples: {1} " +
                    ", Positive test examples: {2}", numPositiveExamples, numPositiveTrainingExamples, 
                    positiveTestInstances);

                    Console.WriteLine("Negative examples: {0}, Negative training examples: {1} " +
                    ", Negative test examples: {2}", numNegativeExamples, numNegativeTrainingExamples,
                    negativeTestInstances);

                }
                catch (Exception ex)
                {

                    throw;
                }

                finally
                {
                    trainingWriter.Close();
                    testWriter.Close();
                }
            }
        }

        /// <summary>
        /// Perform n-fold cross validation
        /// </summary>
        /// <param name="cvFolder">folder that contains the folds</param>
        /// <param name="silent">whether or not to be silent on the screen</param>
        /// <param name="learner">The svm learner with the relevant parameters</param>
        /// <returns>results</returns>
        public Results PerformCrossValidation(String cvFolder, bool silent, SVMLearn learner)
        {
            String[] foldDirectories = Directory.GetDirectories(cvFolder);
            double[] precisions = new double[foldDirectories.Length];
            double[] recalls = new double[foldDirectories.Length];
            double[] accuracies = new double[foldDirectories.Length];

            for (int counter = 0; counter < foldDirectories.Length; counter++)
            {
                String concatenatedFile = Path.Combine(foldDirectories[counter], "combined" + counter + ".data");
                
                using(StreamWriter writer = new StreamWriter(concatenatedFile, false))
                {
                    for (int innerCounter = 0; innerCounter < foldDirectories.Length; innerCounter++)
                    {
                        if (innerCounter != counter)
                        {
                            using (StreamReader reader =
                                new StreamReader(Path.Combine(foldDirectories[innerCounter], innerCounter + ".data")))
                            {
                                while (!reader.EndOfStream)
                                {
                                    writer.WriteLine(reader.ReadLine());
                                }
                            }
                        }
                    }
                }

                //concatenated file created. now train and test. delete concatenated file

                this.TrainFold(foldDirectories, counter, concatenatedFile, silent, learner);
                File.Delete(concatenatedFile);
                SVMClassify classifier = this.TestFold(foldDirectories, counter);

                precisions[counter] = classifier.Precision;
                recalls[counter] = classifier.Recall;
                accuracies[counter] = classifier.Accuracy;
            }

            double accuracy = accuracies.Average(),
            precision = precisions.Average(),
            recall = recalls.Average();

            Console.WriteLine("Accuracy: {0}, Precision: {1}, Recall: {2}", accuracy, precision, recall);

            return new Results
            {
                accuracy = accuracy,
                precision = precision,
                recall = recall
            };
        }

        /// <summary>
        /// Private method that tests a fold
        /// </summary>
        /// <param name="foldDirectories">directory in which the folds are placed</param>
        /// <param name="fold">the current fold being tested</param>
        /// <returns>the classifier containing accuracy, precision and recall</returns>
        private SVMClassify TestFold(string[] foldDirectories, int fold)
        {
            SVMClassify classifier = new SVMClassify();
            classifier.ExecuteClassifier("svm_classify.exe", Path.Combine(foldDirectories[fold], fold + ".data"),
                Path.Combine(foldDirectories[fold], fold + ".model"), Path.Combine(foldDirectories[fold], fold + ".output"),
                Path.Combine(foldDirectories[fold], fold + ".test.log.txt"), Path.Combine(foldDirectories[fold], fold + ".incorrect.txt"),
                false);

            return classifier;
        }

        /// <summary>
        /// Private method that trains a model on the current fold
        /// </summary>
        /// <param name="foldDirectories">Directory in which all the folds are placed</param>
        /// <param name="fold">the current fold under computation</param>
        /// <param name="concatenatedFile">training file that was created for this fold</param>
        /// <param name="silent">whether or not to be silent on the screen</param>
        /// <param name="learner">The svm learner with the relevant parameters</param>
        private void TrainFold(String[] foldDirectories, int fold, String concatenatedFile, bool silent,
            SVMLearn learner)
        {
            learner.ExecuteLearner("svm_learn.exe", concatenatedFile, Path.Combine(foldDirectories[fold], fold + ".model"),
                null, Path.Combine(foldDirectories[fold], fold + ".log.txt"), silent);
        }

        /// <summary>
        /// Take the input file and construct N folds out of it
        /// </summary>
        /// <param name="exampleFile">The file that needs to be split. Will ensure that each fold
        /// contains roughly the same proportion of positive and negative labels as the original</param>
        /// <param name="numberOfFolds">Number of folds in the cross validation</param>
        /// <param name="outputFolder">Will be created to store the cross validation results</param>
        /// <param name="isNegativeExample">Predicate to determine whether a feature vector has a 
        /// negative label</param>
        public void ConstructNFolds(String exampleFile, int numberOfFolds, String outputFolder,
            Predicate<String> isNegativeExample)
        {

            int numPositiveExamples, numNegativeExamples;
            Utilities.GetNumberOfTrainingExamples(exampleFile, out numPositiveExamples, out numNegativeExamples, 
                isNegativeExample);

            if (numberOfFolds > numPositiveExamples + numNegativeExamples)
            {
                throw new Exception("Number of folds must be less than the number of instances. Try using"
                    + " the leave one out cross validation option in SVMLearn.");
            }

            String[] folders = new String[numberOfFolds];
            if (Directory.Exists(outputFolder))
            {
                throw new Exception("Cannot create directory " + outputFolder + ". It already exists");
            }

            if (!Utilities.ExistsInPath(exampleFile))
            {
                throw new Exception("Could not find input file");
            }


            StreamWriter[] files = new StreamWriter[numberOfFolds];
            int[] positiveInstances = new int[numberOfFolds];
            int[] negativeInstances = new int[numberOfFolds];

            using (StreamReader reader = new StreamReader(exampleFile))
            {
                Directory.CreateDirectory(outputFolder);
                //now create N directories...one for each fold
                for (int counter = 0; counter < numberOfFolds; counter++)
                {
                    folders[counter] = Path.Combine(outputFolder, "fold" + counter);
                    Directory.CreateDirectory(folders[counter]);
                    files[counter] = new StreamWriter(Path.Combine(folders[counter], counter + ".data"));
                }
                
                while (!reader.EndOfStream)
                {
                    String line = reader.ReadLine();
                    if (isNegativeExample(line))
                    {
                        int fold = this.GetFairFold(numberOfFolds, numNegativeExamples, negativeInstances, false);
                        
                        files[fold].WriteLine(line);
                        negativeInstances[fold]++;
                    }

                    else
                    {
                        int fold = this.GetFairFold(numberOfFolds, numPositiveExamples, positiveInstances, true);

                        files[fold].WriteLine(line);
                        positiveInstances[fold]++;
                    }
                }

                foreach (var writer in files)
                {
                    writer.Flush();
                    writer.Close();
                }

                Console.WriteLine("Verifying counts...");
                
                int positiveRunning = 0, negativeRunning = 0;
                for(int counter = 0; counter < numberOfFolds; counter++)
                {
                    Console.WriteLine("Fold " + counter + ": [" + positiveInstances[counter] +
                        "+, " + negativeInstances[counter] + "-]" + " Ratio: " +
                        ((double)(negativeInstances[counter]) / (double)(positiveInstances[counter])));
                    positiveRunning += positiveInstances[counter];
                    negativeRunning += negativeInstances[counter];
                }

                Console.WriteLine("Overall ratio: " + ((double)(negativeRunning) / (double)(positiveRunning)));

                if (positiveRunning == numPositiveExamples && negativeRunning == numNegativeExamples)
                {
                    Console.WriteLine("OK");
                }

                else
                {
                    throw new Exception("Problem with counts");
                }
            }
        }

        /// <summary>
        /// Gets a fair fold such that all instances are equitably distributed
        /// </summary>
        /// <param name="numberOfFolds">number of folds</param>
        /// <param name="numExamples">total number of positive (or negative) examples</param>
        /// <param name="instances">array that represents how many instances are contained in each fold</param>
        /// <returns>a fold such that the distribution remains fairly uniform</returns>
        private int GetFairFold(int numberOfFolds, int numExamples, int[] instances, bool positive)
        {
            int fold = Int32.MinValue;
            Random rng = positive ? this.positiveInstanceRNG : this.negativeInstanceRNG;

            do
            {
                fold = rng.Next(numberOfFolds);

            } while (IsUnfairDistribution(instances, numExamples, numberOfFolds, fold));

            return fold;
        }

        /// <summary>
        /// Checks whether the distribution will be unfair if this fold is selected next. Conditions checked:
        /// That the current fold has atleast the minimum number of elements: i.e. #instances/#folds, AND
        /// that there is atleast one other fold with less than the minimum number of instances
        /// </summary>
        /// <param name="instances">an array that holds the distrbution of instances (positive or negative)</param>
        /// <param name="examples">total number of instances (positive or negative)</param>
        /// <param name="numberOfFolds">number of folds</param>
        /// <param name="currentFold">The fold that has been chosen currently</param>
        /// <returns>whether this fold is fair or not</returns>
        private bool IsUnfairDistribution(int[] instances, int examples, int numberOfFolds, int currentFold)
        {
            int minimum = examples / numberOfFolds;
            bool currentFoldHasAtleastMinimum = (instances[currentFold] >= minimum);
            if (!currentFoldHasAtleastMinimum) return false;

            bool atleastOneFoldWithLessThanMinimum = false;

            for (int counter = 0; (counter < numberOfFolds); counter++)
            {
                if (counter != currentFold)
                {
                    if (instances[counter] < minimum)
                    {
                        return (currentFoldHasAtleastMinimum && true);
                    } 
                }
            }

            return (currentFoldHasAtleastMinimum && atleastOneFoldWithLessThanMinimum);
        }
        
    }
}
