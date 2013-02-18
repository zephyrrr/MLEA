using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace weka.timeseries
{

	using weka.core;
	using Filter = weka.filters.Filter;
	using FourierTransform = weka.filters.unsupervised.attribute.FourierTransform;
    using java.util;
    using java.io;

///
/// <summary> * Implementation of class SimilarityAnalysis
/// * @author anilkpatro </summary>
/// 
	public class SimilarityAnalysis : TimeSeries, OptionHandler
	{
	/// <summary> tolerance value for similarity  </summary>
		private double m_epsilon = 10;
	/// <summary> number of coefficients to use after FT  </summary>
		private int m_numCoeffs = 3;
	/// <summary> use FFT/DFT for FT  </summary>
		private bool m_useFFT = false;
	/// <summary> range of values considred as template  </summary>
		private Range m_rangeTemplates = new Range("first-5");

	/// <summary> similarity matrices  </summary>
		private double[][] m_distancesFreq;
		private double[][] m_distancesTime;
	/// <summary> the actual data  </summary>
		private Instances m_data;

	/// <summary> timing information  </summary>
        //private Date m_DFTTime;
        //private Date m_FTEuclideanTime;
        //private Date m_EuclideanTime;

///    
///     <summary> * Constructor </summary>
///     
		public SimilarityAnalysis()
		{
			m_rangeTemplates.setUpper(100);
		}

	// ---- ACCESSORS ----

		public virtual bool getUseFFT()
		{
			return m_useFFT;
		}

		public virtual void setUseFFT(bool useFFT)
		{
			m_useFFT = useFFT;
		}

		public virtual string getTemplateRange()
		{
			return m_rangeTemplates.getRanges();
		}

		public virtual void setTemplateRange(string rangeTemplates)
		{
			m_rangeTemplates.setRanges(rangeTemplates);
		}

		public virtual double getEpsilon()
		{
			return m_epsilon;
		}

		public virtual void setEpsilon(double epsilon)
		{
			m_epsilon = epsilon;
		}

		public virtual int getNumCoeffs()
		{
			return m_numCoeffs;
		}

		public virtual void setNumCoeffs(int numCoeffs)
		{
			m_numCoeffs = numCoeffs;
		}

	// ---- OPERATIONS ----

///    
///     <summary> * Analyze the time series data. The similarity matrices are created
///     * and filled with euclidean distances based on the tolerance values
///     * for similarity.
///     * </summary>
///     * <param name="data"> data to be analyzed </param>
		public override void analyze(Instances data)
		{
            data.setClassIndex(data.numAttributes() - 1);

			m_data = data;
			m_rangeTemplates.setUpper(data.numAttributes());

            //Date startFT = new Date();

		// compute fourier transform
			FourierTransform dftFilter = new FourierTransform();
			dftFilter.setInputFormat(data);
			dftFilter.setNumCoeffs(getNumCoeffs());
			dftFilter.setUseFFT(getUseFFT());
			Instances fourierdata = Filter.useFilter(data, dftFilter);

            Date endFT = new Date();

		// time taken for FT
			//m_DFTTime = new Date(endFT.getTime() - startFT.getTime());

			int numdim = data.numAttributes();
//ORIGINAL LINE: m_distancesFreq = new double[numdim][numdim];
//JAVA TO VB & C# CONVERTER NOTE: The following call to the 'RectangularArrays' helper class reproduces the rectangular array initialization that is automatic in Java:
			m_distancesFreq = RectangularArrays.ReturnRectangularDoubleArray(numdim, numdim);
//ORIGINAL LINE: m_distancesTime = new double[numdim][numdim];
//JAVA TO VB & C# CONVERTER NOTE: The following call to the 'RectangularArrays' helper class reproduces the rectangular array initialization that is automatic in Java:
			m_distancesTime = RectangularArrays.ReturnRectangularDoubleArray(numdim, numdim);

            //long ftDistTime = 0;
            //long tDistTime = 0;

		// compute similarity matrices
			for (int i = 0; i < data.numAttributes(); ++i)
			{
				for (int j = 0; j < i; j++)
				{
				// not for template sequences
					if (m_rangeTemplates.isInRange(i) && m_rangeTemplates.isInRange(j))
					{
						continue;
					}

                    //Date startFTDist = new Date();

				// Compute the Euclidean distance between 2 dims using FT
					double[] reCT = fourierdata.attributeToDoubleArray(2 * i);
					double[] imCT = fourierdata.attributeToDoubleArray(2 * i + 1);

					double[] reCS = fourierdata.attributeToDoubleArray(2 * j);
					double[] imCS = fourierdata.attributeToDoubleArray(2 * j + 1);

					m_distancesFreq[i][j] = computeEuclidean(reCT, imCT, reCS, imCS);

				// if found similar using FT
					if (m_distancesFreq[i][j] <= m_epsilon)
					{
					// then compute normal Euclidean distances between the 2 dims
						double[] x = data.attributeToDoubleArray(i);
						double[] y = data.attributeToDoubleArray(j);

						m_distancesTime[i][j] = computeEuclidean(x, y);
					}

                    //Date endFTDist = new Date();

				// time taken for computing similarity based on FT
					//ftDistTime += (endFTDist.getTime() - startFTDist.getTime());


                //    Date startDist = new Date();

                //// compute similarity matrices (brute force)
                //    double[] x1 = data.attributeToDoubleArray(i);
                //    double[] y1 = data.attributeToDoubleArray(j);

                //    computeEuclidean(x1, y1);

                //    Date endDist = new Date();
                //// time taken for computing similarity based brute force method
                //    tDistTime += (endDist.getTime() - startDist.getTime());

				}
			}

            //m_FTEuclideanTime = new Date(ftDistTime);
            //m_EuclideanTime = new Date(tDistTime);
		}

///    
///     <summary> * Compute Euclidean distance between two sequences having complex
///     * numbers
///     * </summary>
///     * <param name="reCT"> real part of first sequence </param>
///     * <param name="imCT"> imaginary part of first sequence </param>
///     * <param name="reCS"> real part of second sequence </param>
///     * <param name="imCS"> imaginary part of second sequence </param>
///     
		private double computeEuclidean(double[] reCT, double[] imCT, double[] reCS, double[] imCS)
		{
			double sum = 0;
			for (int i = 0; i < reCT.Length; ++i)
			{
				double diffre = reCT[i] - reCS[i];
				double diffim = imCT[i] - imCS[i];
				double mod = Math.Sqrt(diffre*diffre + diffim*diffim);
				sum += mod * mod;
			}
			return Math.Sqrt(sum);
		}

///    
///     <summary> * Compute Euclidean distance between two sequences
///     * </summary>
///     * <param name="x"> first sequence </param>
///     * <param name="y"> second sequence </param>
///     
		private double computeEuclidean(double[] x, double[] y)
		{
			double sum = 0;
			for (int i = 0; i < x.Length; ++i)
			{
				sum += (x[i] - y[i]) * (x[i] - y[i]);
			}
			return Math.Sqrt(sum);
		}

///   
///    <summary> * Returns an enumeration of all the available options..
///    * </summary>
///    * <returns> an enumeration of all available options. </returns>
///    
		public virtual java.util.Enumeration listOptions()
		{
            Vector newVector = new Vector(6);

			newVector.Add(new Option("\tSpecify a set of attributes which form the template." + "\n\tEg. 1,3,5-7.", "T", 1, "-T <start set>"));
			newVector.Add(new Option("\tEpsilon.\n" + "\t(default = 10)", "e", 1, "-e <num>"));
			newVector.Add(new Option("\tSpecifies the number of coefficients to use.\n" + "\t(default = 3)", "r", 1, "-r <num>"));
			newVector.Add(new Option("\tUse FFT for calculation of DFTs\n" + "\t(default = false)", "f", 0, "-f <true|false>"));

			return newVector.elements();
		}

///   
///    <summary> * Sets the OptionHandler's options using the given list. All options
///    * will be set (or reset) during this call (i.e. incremental setting
///    * of options is not possible).
///    * </summary>
///    * <param name="options"> the list of options as an array of strings </param>
///    * <exception cref="Exception"> if an option is not supported </exception>
///    
//JAVA TO VB & C# CONVERTER WARNING: Method 'throws' clauses are not available in .NET:
//ORIGINAL LINE: public void setOptions(String[] options) throws Exception
		public virtual void setOptions(string[] options)
		{
			string optionString = Utils.getOption('T', options);
			if (optionString.Length != 0)
			{
				setTemplateRange(optionString);
			}

			string epsilon = Utils.getOption('e', options);
			if (epsilon.Length != 0)
			{
				setEpsilon(Convert.ToInt32(epsilon));
			}
			else
			{
				setEpsilon(10);
			}

			string numCoeffs = Utils.getOption('r', options);
			if (numCoeffs.Length != 0)
			{
				setNumCoeffs(Convert.ToInt32(numCoeffs));
			}
			else
			{
				setNumCoeffs(3);
			}

			string useFFT = Utils.getOption('f', options);
			if (epsilon.Length != 0)
			{
				setUseFFT(useFFT == "True");
			}
			else
			{
				setUseFFT(false);
			}
		}

///   
///    <summary> * Gets the current option settings for the OptionHandler.
///    * </summary>
///    * <returns> the list of current option settings as an array of strings </returns>
///    
		public virtual string[] getOptions()
		{
			string[] options = new string[8];
			int current = 0;

			options[current++] = "-T";
			options[current++] = "" + getTemplateRange();
			options[current++] = "-e";
			options[current++] = "" + getEpsilon();
			options[current++] = "-r";
			options[current++] = "" + getNumCoeffs();
			options[current++] = "-f";
			options[current++] = "" + getUseFFT();
			return options;
		}

///    
///     <summary> * Output
///     * </summary>
///     * <returns> generated output </returns>
///     
		public override string ToString()
		{
			StringBuilder text = new StringBuilder();

			text.Append("\nTime Series Similarity Analysis\n=======\n\n");
			text.Append("Tolerance: " + m_epsilon + '\n');
			text.Append("Number of coefficients after DFT: " + m_numCoeffs + '\n');

			text.Append("\nFreq-domain Distance Matrix:\n");

			text.Append("            ");
			for (int i=0; i<m_data.numAttributes(); ++i)
			{
				int spc = 12-m_data.attribute(i).name().Length;
				for (int j=0; j<spc/2; ++j)
				{
					text.Append(" ");
				}
				text.Append(m_data.attribute(i).name());
			//for (int j=0; j<spc/2; ++j) text.append(" ");
				text.Append("\t");
			}
			text.AppendLine();
			for (int i=0; i<m_data.numAttributes(); ++i)
			{
				for (int j=-1; j<i; ++j)
				{
					if (j == -1)
					{
						text.Append(m_data.attribute(i).name() + "\t");
					}
					else
					{
						text.Append(Utils.doubleToString(m_distancesFreq[i][j], 12, 4) + "\t");
					}
				}
				text.AppendLine();
			}

			text.Append("\nActual Distance Matrix:\n");

			text.Append("            ");
			for (int i=0; i<m_data.numAttributes(); ++i)
			{
				int spc = 12-m_data.attribute(i).name().Length;
				for (int j=0; j<spc/2; ++j)
				{
					text.Append(" ");
				}
				text.Append(m_data.attribute(i).name());
			//for (int j=0; j<spc/2; ++j) text.append(" ");
				text.Append("\t");
			}
			text.AppendLine();
			for (int i=0; i<m_distancesTime.Length; ++i)
			{
				for (int j=-1; j<i; ++j)
				{
					if (j == -1)
					{
						text.Append(m_data.attribute(i).name() + "\t");
					}
					else
					{
						text.Append(Utils.doubleToString(m_distancesTime[i][j], 12, 4) + "\t");
					}
				}
				text.AppendLine();
			}
			text.AppendLine();

			text.Append("\nTemplate Similarity:\n======\n");
			int[] range = m_rangeTemplates.getSelection();
			for (int i=0; i<range.Length; ++i)
			{
				int row = range[i];
				for (int col=range[range.Length-1]+1; col<m_data.numAttributes(); ++col)
				{
					if (m_distancesFreq[col][row] <= m_epsilon)
					{
						if (m_distancesTime[col][row] <= m_epsilon)
						{
							text.Append("Sequence '" + m_data.attribute(col).name() + "' seems to be similar to template sequence '" + m_data.attribute(row).name() + "'\n");
						}
					}
				}
			}

			text.Append("\nSeries Similarity:\n======\n");
			for (int row=range[range.Length-1]+1; row<m_data.numAttributes(); ++row)
			{
				for (int col=range[range.Length-1]+1; col<row; ++col)
				{
					if (m_distancesFreq[row][col] <= m_epsilon)
					{
						if (m_distancesTime[row][col] <= m_epsilon)
						{
							text.Append("Sequence '" + m_data.attribute(col).name() + "' seems to be similar to sequence '" + m_data.attribute(row).name() + "'\n");
						}
					}
				}
			}

            //text.Append("\nTiming:\n======\n");
            //text.Append("Time taken to compute DFTs: " + m_DFTTime.getTime() + "\n");
            //text.Append("Time taken to compute distances using DFTs: " + m_FTEuclideanTime.getTime() + "\n");
            //text.Append("Time taken to compute distances: " + m_EuclideanTime.getTime() + "\n");


			return text.ToString();
		}

///    
///     <summary> * Main method for testing this class. </summary>
///     
		public static void Main1(string[] options)
		{

			string trainFileString;
			StringBuilder text = new StringBuilder();
			SimilarityAnalysis simi = new SimilarityAnalysis();
			Reader reader;

			try
			{
				text.Append("\n\nTime Series Similarity Analysis options:\n\n");
				text.Append("-t <training file>\n");
				text.Append("\tThe name of the training file.\n");
				java.util.Enumeration @enum = simi.listOptions();
				while (@enum.hasMoreElements())
				{
					Option option = (Option) @enum.nextElement();
					text.Append(option.synopsis() + '\n');
					text.Append(option.description() + '\n');
				}
				trainFileString = Utils.getOption('t', options);
				if (trainFileString.Length == 0)
				{
					throw new Exception("No training file given!");
				}
				simi.setOptions(options);
				reader = new BufferedReader(new FileReader(trainFileString));
				simi.analyze(new Instances(reader));
			    System.Console.WriteLine(simi.ToString());
			}
			catch (java.lang.Exception e)
			{
				e.printStackTrace();
                System.Console.WriteLine("\n" + e.Message + text);
			}
		}

        public static Dictionary<double[], double[]> m_cache; 
        public static SimilarityAnalysis s_simi;
        public static double[] GetSimilarity(double[] a, double[] b)
        {
            if (s_simi == null)
            {
                s_simi = new SimilarityAnalysis();
                s_simi.setOptions(new string[] { "-T", "first-1", "-e", "20", "-r", "3", "-f", "false" });

                if (System.IO.File.Exists(CacheFileName))
                {
                    using (var file = System.IO.File.Open(CacheFileName, System.IO.FileMode.Open))
                    {
                        var bf = new System.Runtime.Serialization.Formatters.Binary.BinaryFormatter();
                        m_cache = bf.Deserialize(file) as Dictionary<double[], double[]>;
                    }
                }
                else
                {
                    m_cache = new Dictionary<double[], double[]>();
                }
            }

            //double[] c = new double[a.Length + b.Length];
            //a.CopyTo(c, 0);
            //b.CopyTo(c, a.Length);
            //if (m_cache.ContainsKey(c))
            //    return m_cache[c];

            Instances instance = CreateInstanceOnFly(a, b);
            s_simi.analyze(instance);

            double[] ret = new double[] { s_simi.m_distancesFreq[1][0], s_simi.m_distancesTime[1][0] };
            //m_cache[c] = ret;

            return ret;
        }
        private static string CacheFileName = "c:\\forex\\simi_cache.dat";
        public static void SaveCache()
        {
            //using (var file = System.IO.File.Open(CacheFileName, System.IO.FileMode.Create))
            //{
            //    var bf = new System.Runtime.Serialization.Formatters.Binary.BinaryFormatter();
            //    bf.Serialize(file, m_cache);
            //}
        }

        private static Instances CreateInstanceOnFly(double[] a, double[] b)
        {
            FastVector atts;
            Instances data;
            double[] vals;

            // 1. set up attributes
            atts = new FastVector();
            // - numeric
            atts.addElement(new Attribute("att1"));
            atts.addElement(new Attribute("att2"));

            // 2. create Instances object
            data = new Instances("MyRelation", atts, 0);

            for (int i = 0; i < a.Length; ++i)
            {
                // 3. fill with data
                // first instance
                vals = new double[data.numAttributes()];
                // - numeric
                vals[0] = a[i];
                // - nominal
                vals[1] = b[i];
                data.add(new weka.core.DenseInstance(1.0, vals));
            }

            return data;
        }
	}

}

//----------------------------------------------------------------------------------------
//	Copyright ? 2008 - 2010 Tangible Software Solutions Inc.
//	This class can be used by anyone provided that the copyright notice remains intact.
//
//	This class provides the logic to simulate Java rectangular arrays, which are jagged
//	arrays with inner arrays of the same length.
//----------------------------------------------------------------------------------------
internal static partial class RectangularArrays
{
    internal static double[][] ReturnRectangularDoubleArray(int Size1, int Size2)
    {
        double[][] Array = new double[Size1][];
        for (int Array1 = 0; Array1 < Size1; Array1++)
        {
            Array[Array1] = new double[Size2];
        }
        return Array;
    }
}