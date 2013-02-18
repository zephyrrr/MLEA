using System;

namespace weka.timeseries
{

	using Instances = weka.core.Instances;
	using SerializedObject = weka.core.SerializedObject;
	using Utils = weka.core.Utils;


///
/// <summary> * Implementation of class TimeSeries
/// * 
/// * @author anilkpatro
/// * @date Mar 22, 2004 </summary>
/// 
	[Serializable]
	public abstract class TimeSeries : java.io.Serializable.__Interface//.  ICloneable
	{
///    
///     <summary> * Analyzes time series data. Must initialize all fields of the timeseries
///     * that are not being set via options (ie. multiple calls of analyze
///     * must always lead to the same result). Must not change the dataset
///     * in any way.
///     * </summary>
///     * <param name="data"> set of instances serving as training data </param>
///     * <exception cref="Exception"> if the analysis has not been
///     *                   done successfully </exception>
///     
//JAVA TO VB & C# CONVERTER WARNING: Method 'throws' clauses are not available in .NET:
//ORIGINAL LINE: public abstract void analyze(Instances data) throws Exception;
		public abstract void analyze(Instances data);

///    
///     <summary> * Creates a new instance of a timeseries analyzer given it's class name and
///     * (optional) arguments to pass to it's setOptions method. If the
///     * associator implements OptionHandler and the options parameter is
///     * non-null, the associator will have it's options set.
///     * </summary>
///     * <param name="analyzerName"> the fully qualified class name of the timeseries analyzer </param>
///     * <param name="options">        an array of options suitable for passing to setOptions. May
///     *                       be null. </param>
///     * <returns> the newly created associator, ready for use. </returns>
///     * <exception cref="Exception"> if the associator name is invalid, or the options
///     *                   supplied are not acceptable to the associator </exception>
///     
//JAVA TO VB & C# CONVERTER WARNING: Method 'throws' clauses are not available in .NET:
//ORIGINAL LINE: public static TimeSeries forName(String analyzerName, String[] options) throws Exception
		public static TimeSeries forName(string analyzerName, string[] options)
		{
			return (TimeSeries) Utils.forName(typeof(TimeSeries), analyzerName, options);
		}

///    
///     <summary> * Creates copies of the current associator. Note that this method
///     * now uses Serialization to perform a deep copy, so the Associator
///     * object must be fully Serializable. Any currently built model will
///     * now be copied as well.
///     * </summary>
///     * <param name="model"> an example associator to copy </param>
///     * <param name="num">   the number of associators copies to create. </param>
///     * <returns> an array of associators. </returns>
///     * <exception cref="Exception"> if an error occurs </exception>
///     
//JAVA TO VB & C# CONVERTER WARNING: Method 'throws' clauses are not available in .NET:
//ORIGINAL LINE: public static TimeSeries[] makeCopies(TimeSeries model, int num) throws Exception
		public static TimeSeries[] makeCopies(TimeSeries model, int num)
		{
			if (model == null)
			{
				throw new Exception("No model time series analysis set");
			}
			TimeSeries[] analyzers = new TimeSeries[num];
			SerializedObject so = new SerializedObject(model);
			for (int i = 0; i < analyzers.Length; i++)
			{
				analyzers[i] = (TimeSeries) so.getObject();
			}
			return analyzers;
		}
	}

}