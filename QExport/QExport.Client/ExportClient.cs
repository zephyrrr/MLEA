using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using QExport.Communication;
using System.ServiceModel;

namespace QExport.Client
{
    [CallbackBehavior(ConcurrencyMode = ConcurrencyMode.Multiple,
        UseSynchronizationContext = false)]
    public class ExportClient : IExportClient, IDisposable
    {
        #region Variables

        // full service address
        private readonly String _ServiceAddress;

        // object of connected service
        private IExportService _ExportService;

        /// <summary>
        /// Returns service instance
        /// </summary>
        public IExportService Service
        {
            get
            {
                return _ExportService;
            }
        }

        /// <summary>
        /// Returns communication channel
        /// </summary>
        public IClientChannel Channel
        {
            get
            {
                return (IClientChannel)_ExportService;
            }
        }

        #endregion

        #region Events

        public event EventHandler<TickRecievedEventArgs> TickRecieved;

        private void OnTickRecieved(String symbol, MqlTick tick)
        {
            TickRecievedEventArgs e = new TickRecievedEventArgs(symbol, tick);
            EventHandler<TickRecievedEventArgs> temp = TickRecieved;
            if (temp != null) temp(this, e);
        }

        public event EventHandler ActiveSymbolsChanged;

        private void OnActiveSymbolsChanged()
        {
            EventHandler temp = ActiveSymbolsChanged;
            if (temp != null) temp(this, EventArgs.Empty);
        }

        #endregion

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="serverName">Server name to connect</param>
        public ExportClient(String serverName)
        {
            _ServiceAddress = String.Format("net.pipe://localhost/{0}", serverName);
        }

        ~ExportClient()
        {
            Dispose(false);
        }

        public void Open()
        {
            if (_IsDisposed)
                throw new ObjectDisposedException("ExportService");

            // Creating channel factory
            var factory = new DuplexChannelFactory<IExportService>(
                new InstanceContext(this),
                new NetNamedPipeBinding());

            // Creating server channel
            _ExportService = factory.CreateChannel(new EndpointAddress(_ServiceAddress));

            IClientChannel channel = (IClientChannel)_ExportService;
            channel.Open();
            _ExportService.Subscribe();
        }

        public void Close()
        {
            Dispose(true);
        }

        #region IExportClient Members

        public void SendTick(string symbol, MqlTick tick)
        {
            OnTickRecieved(symbol, tick);
        }

        public void ReportSymbolsChanged()
        {
            OnActiveSymbolsChanged();
        }

        #endregion

        #region IDisposable Members

        private Boolean _IsDisposed;

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
                _ExportService.Unsubscribe();
                Channel.Close();
            }
            catch { }
            finally
            {
                _ExportService = null;
            }

            _IsDisposed = true;

            if (disposing)
                GC.SuppressFinalize(this);
        }

        #endregion


    }
}
