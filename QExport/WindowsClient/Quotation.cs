using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;

namespace WindowsClient
{
    sealed class Quotation : INotifyPropertyChanged
    {
        private String _Symbol;

        [DisplayName("Symbol")]
        public String Symbol
        {
            get
            {
                return _Symbol;
            }
            set
            {
                _Symbol = value;
                OnPropertyChanged("Symbol");
            }
        }

        private Double _Bid;

        public Double Bid
        {
            get
            {
                return _Bid;
            }
            set
            {
                _Bid = value;
                OnPropertyChanged("Bid");
            }
        }

        private Double _Ask;

        public Double Ask
        {
            get
            {
                return _Ask;
            }
            set
            {
                _Ask = value;
                OnPropertyChanged("Ask");
            }
        }

        public Quotation(String symbol) 
            : this(symbol, 0d, 0d) 
        { }

        public Quotation(String symbol, Double bid, Double ask)
        {
            _Symbol = symbol;
            _Bid = bid;
            _Ask = ask;
        }

        #region INotifyPropertyChanged Members

        public event PropertyChangedEventHandler PropertyChanged;

        private void OnPropertyChanged(String property)
        {
            PropertyChangedEventArgs e = new PropertyChangedEventArgs(property);
            PropertyChangedEventHandler temp = PropertyChanged;
            if (temp != null) temp(this, e);
        }

        #endregion
    }
}
