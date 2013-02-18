using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;

namespace QExport.Communication
{
    [ServiceContract(CallbackContract = typeof(IExportClient))]
    public interface IExportService
    {
        /// <summary>
        /// Subscribe to ticks
        /// </summary>
        [OperationContract]
        void Subscribe();

        /// <summary>
        /// Unsubscribe to ticks
        /// </summary>
        [OperationContract]
        void Unsubscribe();

        /// <summary>
        /// Returns list of exported symbols
        /// </summary>
        [OperationContract]
        String[] GetActiveSymbols();
    }
}
