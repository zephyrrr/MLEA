using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MLEA
{
    public class AssertException : Exception
    {
        public AssertException(string message)
            : base(message)
        {
        }
    }
}
