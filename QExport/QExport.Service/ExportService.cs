using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using QExport.Communication;
using System.ServiceModel;
using System.ServiceModel.Description;
using System.Collections.ObjectModel;

namespace QExport.Service
{
    /// <summary>
    /// Service
    /// </summary>
    [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single,
        ConcurrencyMode = ConcurrencyMode.Multiple,
        UseSynchronizationContext = false,
        IncludeExceptionDetailInFaults = true)]
    public class ExportService : IExportService, IDisposable
    {
        #region Variables

        // Full service address
        private readonly String _ServiceAddress;

        private ServiceHost _ExportHost;

        // Object for locking
        private object lockClients = new object();

        // Active clients callbacks collection
        private Collection<IExportClient> _Clients = new Collection<IExportClient>();

        private List<String> _ActiveSymbols = new List<string>();
        
        #endregion

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="serverName">Server name</param>
        public ExportService(String serverName) 
        {
            _ServiceAddress = String.Format("net.pipe://localhost/{0}", serverName); 
        }

        ~ExportService()
        {
            Dispose(false);
        }

        /// <summary>
        /// Runs Service
        /// </summary>
        public void Open()
        {
            if (_IsDisposed)
                throw new ObjectDisposedException("ExportService");
  
            _ExportHost = new ServiceHost(this);

            // service point
            _ExportHost.AddServiceEndpoint(typeof(IExportService),  // Contract
                new NetNamedPipeBinding(),                          // Binding
                new Uri(_ServiceAddress));                          // Address

            // disable 16 concurrent calls restriction in queue 
            ServiceThrottlingBehavior bhvThrot = new ServiceThrottlingBehavior();
            bhvThrot.MaxConcurrentCalls = Int32.MaxValue;
            _ExportHost.Description.Behaviors.Add(bhvThrot);

            _ExportHost.Open();
        }

        /// <summary>
        /// Stops Service
        /// </summary>
        public void Close()
        {
            Dispose(true);
        }

        public void RegisterSymbol(String symbol)
        {
            if (!_ActiveSymbols.Contains(symbol))
                _ActiveSymbols.Add(symbol);

            lock (lockClients)
                for (int i = 0; i < _Clients.Count; i++)
                    try
                    {
                        _Clients[i].ReportSymbolsChanged();
                    }
                    catch (CommunicationException)
                    {
                        // it seems that connection with client has lost - let's delete him
                        _Clients.RemoveAt(i);
                        i--;
                    }
        }

        public void UnregisterSymbol(String symbol)
        {
            _ActiveSymbols.Remove(symbol);

            lock (lockClients)
                for (int i = 0; i < _Clients.Count; i++)
                    try
                    {
                        _Clients[i].ReportSymbolsChanged();
                    }
                    catch (CommunicationException)
                    {
                        // it seems that connection with client has lost - let's delete him
                        _Clients.RemoveAt(i);
                        i--;
                    }
        }

        /// <summary>
        /// Sends tick to all clients
        /// </summary>
        public void SendTick(String symbol, MqlTick tick)
        {
            lock (lockClients)
                for (int i = 0; i < _Clients.Count; i++)
                    try
                    {
                        _Clients[i].SendTick(symbol, tick);
                    }
                    catch (CommunicationException)
                    {
                        // it seems that connection with client has lost - let's delete him
                        _Clients.RemoveAt(i);
                        i--;
                    }
        }

        #region IExportService Members

        public void Subscribe()
        {
            // Get callback channel
            IExportClient cl = OperationContext.Current.GetCallbackChannel<IExportClient>();
            lock (lockClients)
                _Clients.Add(cl);
        }

        public void Unsubscribe()
        {
            // Get callback channel
            IExportClient cl = OperationContext.Current.GetCallbackChannel<IExportClient>();
            lock (lockClients)
                _Clients.Remove(cl);
        }

        public String[] GetActiveSymbols()
        {
            return _ActiveSymbols.ToArray();
        }

        #endregion


        #region IDisposable Members

        private Boolean _IsDisposed = false;

        public void Dispose()
        {
            Dispose(true);
        }

        private void Dispose(bool disposing)
        {
            if (_IsDisposed)
                throw new ObjectDisposedException("ExportService");

            try
            {
                lock (lockClients)
                    for (int i = 0; i < _Clients.Count; i++)
                        try
                        {
                            ((IClientChannel)_Clients[i]).Close();
                        }
                        catch (CommunicationException)
                        {
                            _Clients.RemoveAt(i);
                            i--;
                        }

                _ExportHost.Close();
            }
            finally
            {
                _ExportHost = null;
                _IsDisposed = true;
            }

            if (disposing)
                GC.SuppressFinalize(this);
        }

        #endregion

    }
}
