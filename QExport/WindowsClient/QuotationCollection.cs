using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;

namespace WindowsClient
{
    sealed class QuotationCollection : BindingList<Quotation>
    {
        public Quotation this[String symbol]
        {
            get
            {
                return this.SingleOrDefault(q => q.Symbol == symbol);
            }
        }
    }
}
