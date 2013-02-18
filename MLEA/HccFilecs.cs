using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public class HccFilecs
    {
        /* http://bugfound.blogspot.com/2010/12/forex-metatrader-5-hcc-to-cvs.html
         * 4 byte, seperator , little endian encoding 18385028, hex(84 88 18 01)
4 byte, time, int divisible by 60
8 byte, double open
8 byte, double high
8 byte, double low
8 byte, double close
1 byte, char | small int spread
1 byte, char | small int tick volume*/

        public struct Rate
        {
            public Int32 seperator;
            public Int32 time;
            public double open;
            public double high;
            public double low;
            public double close;
            public byte spread;
            public byte volume;
        }
    }
}
