using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using System.Runtime.Serialization;

namespace QExport
{
    /// <summary>
    /// Similar to MT structure 
    /// </summary>
    [StructLayout(LayoutKind.Sequential)]
    [DataContract]
    public struct MqlTick
    {
        [DataMember] 
        public Int64 Time { get; set; }
        [DataMember]
        public Double Bid { get; set; }
        [DataMember]
        public Double Ask { get; set; }
        [DataMember]
        public Double Last { get; set; }
        [DataMember]
        public UInt64 Volume { get; set; }
    }
}
