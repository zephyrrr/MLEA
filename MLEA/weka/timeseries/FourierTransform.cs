using System;
using System.Collections;

/*
 * Created on Mar 13, 2004
 */
namespace weka.filters.unsupervised.attribute
{

	using weka.core;
	using Filter = weka.filters.Filter;
	using UnsupervisedFilter = weka.filters.UnsupervisedFilter;
    using java.util;

///
/// <summary> * Fourier Transform filter - takes an n attribute dataset (all numeric)
/// * and return an 2*n attribute dataset with real and imaginary components
/// * of Fourier Transform of the original attributes
/// * @author anilkpatro </summary>
/// 
	public class FourierTransform : Filter, UnsupervisedFilter, OptionHandler
	{
	/// <summary> Number of coeeficients to keep after transformation  </summary>
		private int m_numCoeffs = 5;
	/// <summary> Use FFT/DFT for Fourier Transformations  </summary>
		private bool m_useFFT = false;
	/// <summary> Complex number helper for FTs  </summary>
		private AttFTHolder[] m_attsFT;

	// ---- ACCESSOR FUNCTIONS ----

		public virtual int getNumCoeffs()
		{
			return m_numCoeffs;
		}

		public virtual void setNumCoeffs(int numCoeffs)
		{
			m_numCoeffs = numCoeffs;
		}

		public virtual bool getUseFFT()
		{
			return m_useFFT;
		}

		public virtual void setUseFFT(bool use)
		{
			m_useFFT = use;
		}

	// ---- OPERATIONS ----

///    
///     <summary> * Sets the format of the input instances. If the filter is able to
///     * determine the output format before seeing any input instances, it
///     * does so here. This default implementation clears the output format
///     * and output queue, and the new batch flag is set. Overriders should
///     * call <code>super.setInputFormat(Instances)</code>
///     * </summary>
///     * <param name="instanceInfo"> an Instances object containing the input instance
///     * structure (any instances contained in the object are ignored - only the
///     * structure is required). </param>
///     * <returns> true if the outputFormat may be collected immediately </returns>
///     * <exception cref="Exception"> if the inputFormat can't be set successfully  </exception>
///     
//JAVA TO VB & C# CONVERTER WARNING: Method 'throws' clauses are not available in .NET:
//ORIGINAL LINE: public boolean setInputFormat(Instances instanceInfo) throws Exception
		public override bool setInputFormat(Instances instanceInfo)
		{
			base.setInputFormat(instanceInfo);

			for (int i = 0; i < instanceInfo.numAttributes(); ++i)
			{
				if (!instanceInfo.attribute(i).isNumeric())
				{
					throw new UnsupportedAttributeTypeException("All attributes must be numeric");
				}
			}

		// Create the output buffer
			setOutputFormat();
			return true;
		}

///    
///     <summary> * Sets the format of output instances. </summary>
///     
		private void setOutputFormat()
		{
		// give names to the new attributes
			FastVector newAtts = new FastVector();
			string foName = null;
			for (int i = 0; i < getInputFormat().numAttributes(); i++)
			{
				string attName = getInputFormat().attribute(i).name();
				foName = "'FT " + attName.Replace('\'', ' ').Trim() + " (re)\'";
				Attribute newAttribX = new Attribute(foName);
				newAtts.addElement(newAttribX);

				foName = "'FT " + attName.Replace('\'', ' ').Trim() + " (im)\'";
				Attribute newAttribY = new Attribute(foName);
				newAtts.addElement(newAttribY);
			}

			setOutputFormat(new Instances(getInputFormat().relationName(), newAtts, getNumCoeffs()));
		}

///   
///    <summary> * Signify that this batch of input to the filter is finished. If
///    * the filter requires all instances prior to filtering, output()
///    * may now be called to retrieve the filtered instances. Any
///    * subsequent instances filtered should be filtered based on setting
///    * obtained from the first batch (unless the inputFormat has been
///    * re-assigned or new options have been set). This default
///    * implementation assumes all instance processing occurs during
///    * inputFormat() and input().
///    * </summary>
///    * <returns> true if there are instances pending output </returns>
///    * <exception cref="NullPointerException"> if no input structure has been defined, </exception>
///    * <exception cref="Exception"> if there was a problem finishing the batch. </exception>
///    
		public override bool batchFinished()
		{
			if (getInputFormat() == null)
			{
				throw new java.lang.IllegalStateException("No input instance format defined");
			}

		// throw if all attributes are not numeric
			Instances instances = getInputFormat();
			if (instances.numInstances() < getNumCoeffs())
			{
                throw new java.lang.IllegalStateException("Number of coeffs cannot be greater " + "than the total number of instances");
			}

			m_attsFT = new AttFTHolder [instances.numAttributes()];

			int nearestPower2;
			for (int attr = 0; attr < instances.numAttributes(); ++attr)
			{
				m_attsFT[attr] = new AttFTHolder();

				double[] array = instances.attributeToDoubleArray(attr);
			// get the nearest power of 2 for the FT
				for (nearestPower2 = 1; array.Length > nearestPower2; nearestPower2 <<= 1)
				{
					;
				}

			// initialize the complex numbers
				m_attsFT[attr].re = new double[nearestPower2];
				m_attsFT[attr].im = new double[nearestPower2];
				int j = 0;
				for (int i=0; i<nearestPower2; ++i, ++j)
				{
					m_attsFT[attr].re[i] = (j < array.Length) ? array[i] : 0;
					m_attsFT[attr].im[i] = 0;
				}

			// inplace FT
				if (m_useFFT)
				{
					computeFFT(m_attsFT[attr].re, m_attsFT[attr].im);
				}
				else
				{
					computeDFT(m_attsFT[attr].re, m_attsFT[attr].im);
				}
			}

		// set instances of the new dataset
			for (int i=0; i<getNumCoeffs(); ++i)
			{
				double[] vals = new double[instances.numAttributes() * 2];
				for (int j=0; j<instances.numAttributes(); ++j)
				{
					vals[2*j] = m_attsFT[j].re[i];
					vals[2*j+1] = m_attsFT[j].im[i];
				}
                
				Instance inst = new weka.core.DenseInstance(instances.instance(i).weight(), vals);

                // Modified
				//inst.setDataset(instances.instance(i).dataset());
				push(inst);
			}

			flushInput();
			m_NewBatch = true;
			return (numPendingOutput() != 0);
		}

///    
///     <summary> * This computes an in-place complex-to-complex FFT x and y are the real
///     * and imaginary arrays of 2^m points.
///     *  </summary>
///     * <param name="x"> real array </param>
///     * <param name="y"> imaginary array </param>
///     
		private void computeFFT(double[] x, double[] y)
		{
			int numPoints = x.Length;
			int logPoints = (int)(Math.Log(numPoints) / Math.Log(2));

		// Do the bit reversal
			int halfPoints = numPoints / 2;
			int rev = 0;
			for (int i = 0; i < numPoints - 1; i++)
			{
				if (i < rev)
				{
				// swap the numbers
					double tx = x[i];
					double ty = y[i];
					x[i] = x[rev];
					y[i] = y[rev];
					x[rev] = tx;
					y[rev] = ty;
				}
				int mask = halfPoints;
				while (mask <= rev)
				{
					rev -= mask;
					mask >>= 1;
				}
				rev += mask;
			}

		// Compute the FFT
			double c1 = -1.0;
			double c2 = 0.0;
			int step = 1;
			for (int level = 0; level < logPoints; level++)
			{
				int increm = step * 2;
				double u1 = 1.0;
				double u2 = 0.0;
				for (int j = 0; j < step; j++)
				{
					for (int i = j; i < numPoints; i += increm)
					{
					// Butterfly
						double t1 = u1 * x[i + step] - u2 * y[i + step];
						double t2 = u1 * y[i + step] + u2 * x[i + step];
						x[i + step] = x[i] - t1;
						y[i + step] = y[i] - t2;
						x[i] += t1;
						y[i] += t2;
					}
				// U = exp ( - 2 PI j / 2 ^ level )
					double z = u1 * c1 - u2 * c2;
					u2 = u1 * c2 + u2 * c1;
					u1 = z;
				}
				c2 = Math.Sqrt((1.0 - c1) / 2.0);
				c1 = Math.Sqrt((1.0 + c1) / 2.0);

				step *= 2;
			}

		// Scaling for forward transform
			for (int i = 0; i < numPoints; i++)
			{
				x[i] /= numPoints;
				y[i] /= numPoints;
			}
		}

///    
///     <summary> * This computes an in-place complex-to-complex DFT x and y are the real
///     * and imaginary arrays of 2^m points.
///     *  </summary>
///     * <param name="x"> real array </param>
///     * <param name="y"> imaginary array </param>
///     
		private void computeDFT(double[] x, double[] y)
		{
			double arg;
			double cosarg, sinarg;
			double[] x2;
			double[] y2;

			int m = x.Length;
			x2 = new double[m];
			y2 = new double[m];

		// Compute correlation
			for (int i = 0; i < m; i++)
			{
				x2[i] = 0;
				y2[i] = 0;
				arg = 2.0 * Math.PI * (double) i / (double) m;
				for (int k = 0; k < m; k++)
				{
					cosarg = Math.Cos(k * arg);
					sinarg = Math.Sin(k * arg);
					x2[i] += (x[k] * cosarg - y[k] * sinarg);
					y2[i] += (x[k] * sinarg + y[k] * cosarg);
				}
			}

		// Copy and scale the data back
			for (int i = 0; i < m; i++)
			{
				x[i] = x2[i] / (double) m;
				y[i] = y2[i] / (double) m;
			}
		}

///   
///    <summary> * Returns an enumeration of all the available options..
///    * </summary>
///    * <returns> an enumeration of all available options. </returns>
///    
        public virtual java.util.Enumeration listOptions()
		{
            Vector newVector = new Vector(2);

			newVector.Add(new Option("\tSpecifies the number of coefficients to use.\n" + "\t(default = 5)", "r", 1, "-r <num>"));
			newVector.Add(new Option("\tUse FFT.\n" + "\t(default = false)", "F", 1, "-F <num>"));

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
			string numCoeffs = Utils.getOption('r', options);
			if (numCoeffs.Length != 0)
			{
				setNumCoeffs(Convert.ToInt32(numCoeffs));
			}
			else
			{
				setNumCoeffs(10);
			}

			string useFFT = Utils.getOption('F', options);
			if (useFFT.Length != 0)
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
			string[] options = new string [4];
			int current = 0;

			options[current++] = "-r";
			options[current++] = "" + getNumCoeffs();
			options[current++] = "-F";
			options[current++] = "" + getUseFFT();
			return options;
		}

///    
///     <summary> * Entry point for testing filter </summary>
///     
		public static void Main1(string[] args)
		{
			try
			{
				if (Utils.getFlag('b', args))
				{
					Filter.batchFilterFile(new FourierTransform(), args);
				}
				else
				{
					Filter.filterFile(new FourierTransform(), args);
				}
			}
			catch (Exception ex)
			{
				Console.WriteLine(ex.Message);
			}
		}

///    
///     <summary> * Helper class </summary>
///     
		private class AttFTHolder
		{
			public double[] re;
			public double[] im;
		}
	}

}