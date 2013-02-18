using System;
using System.Collections;

namespace MLEA
{
    ///<Summary>
    ///C# Math Class for Computing Standard Deviation, Normal Distribution, Probability Density
    ///Will Be Used In C# Naive Bayes Data Mining Algorithm for Classifying Numeric or Continuous Data
    ///</Summary>
    ///<Remarks>
    ///C# Probability Density Function or Normal Distrubution from 
    ///http://www.experts-exchange.com/Programming/Programming_Languages/C_Sharp/Q_20936306.html 
    ///C# Mean and C# Standard Deviation Functions from Daniel Olson at
    ///http://authors.aspalliance.com/olson/
    ///</Remarks>
    public class Maths
    {
        ///<Summary>
        ///Main function used to test or execute class functions from the command prompt
        ///</Summary>
        public static void Mainx()
        {
            //Test Standard Deviation Computation
            double[] arrayOfDoubles = { 2.5, 2.6, 2.8, 3.2, 3.8, 3.9, 4.0, 4.3, 4.4, 4.8 };

            double stdDev = StandardDeviation(arrayOfDoubles);

            Console.WriteLine("Standard Deviation Of Array Of Doubles Is : {0}", stdDev.ToString());

            //Test Probability Density or Normal Distribution Computation
            Console.WriteLine("Normal Distribution or Probability Density Is : {0}", NormalDistribution(42, 40, 1.5));

            Console.ReadLine();
        }

        ///<Summary>
        ///Calculates standard deviation of numbers in an ArrayList
        ///</Summary>       
        public static double StandardDeviation(ArrayList num)
        {
            if (num.Count == 0 || num.Count == 1)
                return 0;

            double SumOfSqrs = 0;
            double avg = Average(num);
            for (int i = 0; i < num.Count; i++)
            {
                SumOfSqrs += Math.Pow(((double)num[i] - avg), 2);
            }
            double n = (double)num.Count;
            return Math.Sqrt(SumOfSqrs / (n - 1));
        }

        ///<Summary>
        ///Calculates standard deviation of numbers of doubles data type in an array
        ///</Summary>  
        public static double StandardDeviation(double[] num)
        {
            if (num.Length == 0 || num.Length == 1)
                return 0;

            double Sum = 0.0, SumOfSqrs = 0.0;
            for (int i = 0; i < num.Length; i++)
            {
                Sum += num[i];
                SumOfSqrs += Math.Pow(num[i], 2);
            }
            double topSum = (num.Length * SumOfSqrs) - (Math.Pow(Sum, 2));
            double n = (double)num.Length;
            return Math.Sqrt(topSum / (n * (n - 1)));
        }

        ///<Summary>
        ///Calculates standard deviation of numbers of doubles data type in a column of an array
        ///</Summary>  
        public static double StandardDeviation(double[,] num, int col)
        {
            if (num.Length == 0 || num.Length == 1)
                return 0;

            double Sum = 0.0, SumOfSqrs = 0.0;
            int len = num.GetLength(0);
            for (int i = 0; i < len; i++)
            {
                Sum += num[i, col];
                SumOfSqrs += Math.Pow(num[i, col], 2);
            }
            double topSum = (len * SumOfSqrs) - (Math.Pow(Sum, 2));
            double n = System.Convert.ToDouble(len);
            return Math.Sqrt(topSum / (n * (n - 1)));
        }

        ///<Summary>
        ///Calculates average of numbers of doubles data type in an array 
        ///</Summary>  
        public static double Average(double[] num)
        {
            if (num.Length == 0)
                return 0;
            double sum = 0.0;
            for (int i = 0; i < num.Length; i++)
            {
                sum += num[i];
            }
            double avg = sum / System.Convert.ToDouble(num.Length);

            return avg;
        }

        ///<Summary>
        ///Calculates average of numbers of integer data type in an array 
        ///</Summary>    
        public static double Average(int[] num)
        {
            if (num.Length == 0)
                return 0;
            double sum = 0.0;
            for (int i = 0; i < num.Length; i++)
            {
                sum += num[i];
            }
            double avg = sum / System.Convert.ToDouble(num.Length);

            return avg;
        }

        ///<Summary>
        ///Calculates average of numbers of integer data type in an ArrayList
        ///</Summary>  
        public static double Average(ArrayList num)
        {
            if (num.Count == 0)
                return 0;
            double sum = 0.0;
            for (int i = 0; i < num.Count; i++)
            {
                sum += (double)num[i];
            }
            double avg = sum / System.Convert.ToDouble(num.Count);

            return avg;
        }

        /// <summary> 
        /// Calculates Normal Distribution or Probability Density given the mean, and standard deviation 
        /// </summary> 
        /// <param name="x">The value for which you want the distribution.</param> 
        /// <param name="mean">The arithmetic mean of the distribution.</param> 
        /// <param name="deviation">The standard deviation of the distribution.</param> 
        /// <returns>Returns the normal distribution for the specified mean and standard deviation.</returns> 
        public static double NormalDistribution(double x, double mean, double deviation)
        {
            return NormalDensity(x, mean, deviation);
        }
        private static double NormalDensity(double x, double mean, double deviation)
        {
            return Math.Exp(-(Math.Pow((x - mean) / deviation, 2) / 2)) / Math.Sqrt(2 * Math.PI) / deviation;
        }
    }
}
