using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using QExport.Client;
using System.ServiceModel;
using System.Threading;
using Timer = System.Windows.Forms.Timer;

namespace WindowsClient
{
    public partial class MainForm : Form
    {
        private ExportClient _Client = new ExportClient("mt5");

        private QuotationCollection _QuotationTable = new QuotationCollection();

        private Timer _ConnectionTimer = new Timer() { Interval = 2000 };

        public MainForm()
        {
            InitializeComponent();
            dgvQuotations.DataSource = _QuotationTable;
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            _Client.TickRecieved += new EventHandler<TickRecievedEventArgs>(_Client_TickRecieved);
            _Client.ActiveSymbolsChanged += new EventHandler(_Client_ActiveSymbolsChanged);

            _ConnectionTimer.Tick += new EventHandler(_ConnectionTimer_Tick);
            _ConnectionTimer.Start();
        }

        void _ConnectionTimer_Tick(object sender, EventArgs e)
        {
            try
            {
                _Client.Open();
                _ConnectionTimer.Stop();

                Text = "Quotes table";
                UpdateSymbols();
            }
            catch
            {
            }
        }

        private void UpdateSymbols()
        {
            String[] symbols = _Client.Service.GetActiveSymbols();

            for (int i = 0; i < symbols.Length; i++)
                if (_QuotationTable[symbols[i]] == null)
                    _QuotationTable.Add(new Quotation(symbols[i]));


            for (int i = 0; i < _QuotationTable.Count; i++)
                if (!symbols.Contains(_QuotationTable[i].Symbol))
                    _QuotationTable.RemoveAt(i);
        }

        void _Client_ActiveSymbolsChanged(object sender, EventArgs e)
        {
            if (InvokeRequired)
                Invoke(new EventHandler(_Client_ActiveSymbolsChanged), sender, e);
            else UpdateSymbols();
        }

        void _Client_TickRecieved(object sender, TickRecievedEventArgs e)
        {
            if (InvokeRequired)
                Invoke(new EventHandler<TickRecievedEventArgs>(_Client_TickRecieved), sender, e);
            else
            {
                Quotation q = _QuotationTable[e.Symbol];
                if (q != null)
                {
                    q.Ask = e.Tick.Ask;
                    q.Bid = e.Tick.Bid;
                }
            }
        }

        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            _Client.TickRecieved -= new EventHandler<TickRecievedEventArgs>(_Client_TickRecieved);
            _Client.ActiveSymbolsChanged -= new EventHandler(_Client_ActiveSymbolsChanged);

            _Client.Close();
        }
    }
}
