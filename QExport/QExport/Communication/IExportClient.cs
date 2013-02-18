using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;

namespace QExport.Communication
{
    [ServiceContract]
    public interface IExportClient
    {
        /// <summary>
        /// Sends tick to client
        /// </summary>
        /// <param name="symbol">Symbol</param>
        /// <param name="tick">Tick structure</param>
        [OperationContract(IsOneWay = true)]
        void SendTick(String symbol, MqlTick tick);

        /// <summary>
        /// Informs the client that symbol list has changed
        /// </summary>
        [OperationContract(IsOneWay = true)]
        void ReportSymbolsChanged();
    }
}
