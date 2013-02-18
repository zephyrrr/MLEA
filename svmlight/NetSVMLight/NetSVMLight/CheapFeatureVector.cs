using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NetSVMLight
{
    public class CheapFeatureVector
    {
        public String instance = String.Empty;
        public bool label = false;
        /// <summary>
        /// to figure out whether this instance has already been used while building training set
        /// </summary>
        public bool flag = false;

        /// <summary>
        /// Custom field to store the output assigned to this feature vector by svmlight
        /// </summary>
        public Double svmLightOutput;

        /// <summary>
        /// Custom field to store metadata
        /// </summary>
        public String metadata = String.Empty;
    }
}
