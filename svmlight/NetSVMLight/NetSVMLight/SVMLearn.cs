using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.IO;
using System.Reflection;

namespace NetSVMLight
{
    ///// <summary>
    ///// The mode in which svm_learn is to be run. Default: classification
    ///// </summary>
    //public enum Mode {Classification = 'c', Regression = 'r', PreferenceRanking = 'p'}

    ///// <summary>
    ///// Which kernel to use. Default: linear
    ///// </summary>
    //public enum Kernel {Linear, Polynomial, RBF, SigmoidTanH, UserDefinedFromKernelH}
    public class SVMLearn
    {
        private StringBuilder svmLearnOutput = new StringBuilder();
        ///// <summary>
        ///// Set verbosity of svm_learn
        ///// </summary>
        //public int Verbosity { get; set; }

        //#region Learning Options
        ///// <summary>
        ///// svm_learn mode: classification, regression, or preference ranking
        ///// </summary>
        //public Mode mode { get; set; }
        ///// <summary>
        ///// The parameter that represents the tradeoff between training error and margin: C
        ///// (default [avg. x*x]^-1)
        ///// </summary>
        //public Double TrainingErrorAndMarginTradeoff { get; set; }
        ///// <summary>
        ///// Epsilon width of tube for regression
        ///// </summary>
        //public Double EpsilonWidth { get; set; }
        ///// <summary>
        ///// cost-factor, by which training errors on positive examples outweight errors on negative
        ///// default 0.1
        ///// </summary>
        //public Double Cost { get; set; }
        ///// <summary>
        ///// use biased hyperplane (i.e. x*w+b0) instead of unbiased hyperplane (i.e. x*w0) (default 1)
        ///// </summary>
        //public Boolean UseBiasedHyperPlane { get; set; }
        ///// <summary>
        ///// remove inconsistent training examples and retrain (default 0)
        ///// </summary>
        //public Boolean RemoveInconsistentTrainingExamples { get; set; }
        ///// <summary>
        ///// Whether to compute leave one out estimates during training. default false
        ///// </summary>
        //public Boolean LeaveOneOutCrossValidation { get; set; }
        //#endregion

        //#region Kernel Options

        ///// <summary>
        ///// Type of kernel to use: Enumeration
        ///// </summary>
        //public Kernel kernelType;
        ///// <summary>
        ///// parameter d in polynomial kernel
        ///// </summary>
        //public int ParamD { get; set; }

        ///// <summary>
        ///// parameter gamma in rbf kernel
        ///// </summary>
        //public Double ParamG { get; set; }

        ///// <summary>
        ///// parameter s in sigmoid/poly kernel
        ///// </summary>
        //public Double ParamS { get; set; }

        ///// <summary>
        ///// Param C in sigmoid/poly kernel
        ///// </summary>
        //public Double ParamC { get; set; }

        ///// <summary>
        ///// parameter of user defined kernel
        ///// </summary>
        //public String ParamU { get; set; }

        //#endregion

        public SVMLearn()
        {
            //this.TrainingErrorAndMarginTradeoff = double.MinValue;
            //this.EpsilonWidth = double.MinValue;
            //this.Cost = double.MinValue;
            //this.mode = Mode.Classification;
            //this.ParamC = double.MinValue;
            //this.ParamD = Int32.MinValue;
            //this.ParamG = double.MinValue;
            //this.ParamS = double.MinValue;
            //this.ParamU = String.Empty;
            //this.LeaveOneOutCrossValidation = false;
            //this.RemoveInconsistentTrainingExamples = false;
        }

        public string Output
        {
            get { return svmLearnOutput.ToString(); }
        }

        /// <summary>
        /// Execute the svm_learn module
        /// </summary>
        /// <param name="svmLearnPath">Path to the svm_learn executable. MUST INCLUDE FULL PATH
        /// INCLUDING THE .EXE EXTENSION</param>
        /// <param name="trainingFile">The training dataset</param>
        /// <param name="modelFile">Model file to be created. Must have write permissions at this location
        /// </param>
        /// <param name="logFile">Log file to be created</param>
        /// <param name="silent">Whether no output should be displayed on the console. Set this to true if you want silent.</param>
        public void ExecuteLearner(String svmLearnPath, String trainingFile, String modelFile, string trainArgument = null, String logFile = null, bool silent = true)
        {
            this.svmLearnOutput.Clear();

            if (!string.IsNullOrEmpty(logFile))
            {
                Trace.Listeners.Clear();
                if (!silent)
                {
                    Trace.Listeners.Add(new TextWriterTraceListener(Console.Out));
                }

                if (File.Exists(logFile))
                {
                    Console.WriteLine("\n\nLog file " + logFile + " already exists. Deleting");
                    try
                    {
                        File.Delete(logFile);
                    }
                    catch (Exception)
                    {
                        Console.WriteLine("Failed to delete file");
                    }
                }

                Trace.Listeners.Add(new TextWriterTraceListener(logFile));
                Trace.AutoFlush = true;
            }

            if (!Utilities.ExistsInPath(svmLearnPath) || !Utilities.ExistsInPath(trainingFile))
            {
                Console.WriteLine("Invalid file path");
                Environment.Exit(0);
            }

            Process svmLearnProcess = CreateLearnerProcess(svmLearnPath, trainingFile, modelFile, trainArgument);

            if (!string.IsNullOrEmpty(logFile))
            {
                Trace.WriteLine("\n\nLearning model using svmlight...");
                Trace.WriteLine("svm_learn " + svmLearnProcess.StartInfo.Arguments);
            }

            svmLearnProcess.Start();
            svmLearnProcess.BeginErrorReadLine();
            svmLearnProcess.BeginOutputReadLine();

            svmLearnProcess.WaitForExit(1000 * 60 * 1);
            if (!svmLearnProcess.HasExited)
            {
                svmLearnProcess.Kill();
            }
            svmLearnProcess.Close();

            if (!string.IsNullOrEmpty(logFile))
            {
                Trace.WriteLine(this.svmLearnOutput.ToString());
            }
        }

        /// <summary>
        /// Set the appropriate parameters for the process to be executed
        /// </summary>
        /// <param name="svmLearnPath">path to the svm_learn exe</param>
        /// <param name="trainingFile">training file</param>
        /// <param name="modelFile">model file to be created. make sure you have write permissions</param>
        /// <returns></returns>
        private Process CreateLearnerProcess(String svmLearnPath, String trainingFile, String modelFile, string trainArgument)
        {
            Process svmLearnProcess = new Process();
            svmLearnProcess.StartInfo.FileName = svmLearnPath;

            string svmLearnArgs;
            if (string.IsNullOrEmpty(trainArgument))
            {
                svmLearnArgs = SetLearnerParams(trainingFile, modelFile).ToString();
            }
            else
            {
                svmLearnArgs = string.Format("{0} \"{1}\" \"{2}\"", trainArgument, trainingFile, modelFile);
            }
            svmLearnProcess.StartInfo.Arguments = svmLearnArgs.ToString();

            svmLearnProcess.StartInfo.UseShellExecute = false;
            svmLearnProcess.StartInfo.RedirectStandardError = true;
            svmLearnProcess.StartInfo.RedirectStandardOutput = true;
            svmLearnProcess.OutputDataReceived += new DataReceivedEventHandler(svmLearnProcess_OutputDataReceived);
            svmLearnProcess.ErrorDataReceived += new DataReceivedEventHandler(svmLearnProcess_ErrorDataReceived);
            return svmLearnProcess;
        }

        /// <summary>
        /// Set the parameters for the svm_learn executable
        /// </summary>
        /// <param name="trainingFile"></param>
        /// <param name="modelFile"></param>
        /// <returns></returns>
        private StringBuilder SetLearnerParams(String trainingFile, String modelFile)
        {
            StringBuilder svmLearnArgs = new StringBuilder();

            //if (this.mode != Mode.Classification)
            //{
            //    svmLearnArgs.Append(" -z " + (char)this.mode);
            //}

            //if (this.TrainingErrorAndMarginTradeoff != double.MinValue)
            //{
            //    svmLearnArgs.Append(" -c " + this.TrainingErrorAndMarginTradeoff);
            //}

            //if (this.EpsilonWidth != double.MinValue)
            //{
            //    svmLearnArgs.Append(" -w " + this.EpsilonWidth);
            //}

            //if (this.Cost != double.MinValue)
            //{
            //    svmLearnArgs.Append(" -j " + this.Cost);
            //}

            //if (this.LeaveOneOutCrossValidation == true)
            //{
            //    svmLearnArgs.Append(" -x 1");
            //}

            //if (this.RemoveInconsistentTrainingExamples == true)
            //{
            //    svmLearnArgs.Append(" -i 1");
            //}

            //this.SetKernelParams(svmLearnArgs);

            svmLearnArgs.Append(" \"" + trainingFile + "\" \"" + modelFile + "\"");
            return svmLearnArgs;
        }

        ///// <summary>
        ///// Set the kernel parameters
        ///// </summary>
        ///// <param name="svmLearnArgs"></param>
        //private void SetKernelParams(StringBuilder svmLearnArgs)
        //{
        //    if (this.kernelType != Kernel.Linear)
        //    {
        //        switch (this.kernelType)
        //        {
        //            case Kernel.Polynomial:
        //                svmLearnArgs.Append(" -t 1");
        //                break;

        //            case Kernel.RBF:
        //                svmLearnArgs.Append(" -t 2");
        //                break;

        //            case Kernel.SigmoidTanH:
        //                svmLearnArgs.Append("-t 3");
        //                break;

        //            case Kernel.UserDefinedFromKernelH:
        //                svmLearnArgs.Append("-t 4");
        //                break;

        //            default:
        //                //do nothing. it is linear by default
        //                break;
        //        }
        //    }

        //    if (this.ParamC != double.MinValue)
        //    {
        //        svmLearnArgs.Append(" -r " + this.ParamC);
        //    }

        //    if (this.ParamD != Int32.MinValue)
        //    {
        //        svmLearnArgs.Append(" -d " + this.ParamD);
        //    }

        //    if (this.ParamG != double.MinValue)
        //    {
        //        svmLearnArgs.Append(" -g " + this.ParamG);
        //    }

        //    if (this.ParamS != double.MinValue)
        //    {
        //        svmLearnArgs.Append(" -s " + this.ParamS);
        //    }

        //    if (!String.IsNullOrEmpty(this.ParamU))
        //    {
        //        svmLearnArgs.Append(" -u " + this.ParamU);
        //    }
        //}

        /// <summary>
        /// Event-handler for when error data is received from an invoked process
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="errLine"></param>
        private void svmLearnProcess_ErrorDataReceived(object sender, DataReceivedEventArgs errLine)
        {
            if (!String.IsNullOrEmpty(errLine.Data) && !errLine.Data.StartsWith("...."))
            {
                this.svmLearnOutput.Append(errLine.Data + Environment.NewLine);
            }
        }

        /// <summary>
        /// Event-handler for when data is received from the process that has been initiated
        /// </summary>
        /// <param name="sendingProcess"></param>
        /// <param name="outLine"></param>
        private void svmLearnProcess_OutputDataReceived(object sendingProcess, DataReceivedEventArgs outLine)
        {
            if (!String.IsNullOrEmpty(outLine.Data) && !outLine.Data.StartsWith("optimizing", true, System.Globalization.CultureInfo.CurrentCulture))
            {
                this.svmLearnOutput.Append(outLine.Data + Environment.NewLine);
            }
        }
    }
}
