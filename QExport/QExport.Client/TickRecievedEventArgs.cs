using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace QExport.Client
{
    public class TickRecievedEventArgs : EventArgs
    {
        public String Symbol { get; set; }
        public MqlTick Tick { get; set; }

        public TickRecievedEventArgs(String symbol, MqlTick tick)
        {
            Symbol = symbol;
            Tick = tick;
        }
    }
}
