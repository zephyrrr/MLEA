using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using QExport.Service;
using System.Diagnostics;
using QExport;

namespace ConsoleService
{
    class Program
    {
        static void Main(string[] args)
        {
            ExportService host = new ExportService("mt5");
            host.Open();

            Console.WriteLine("Press any key to start tick export");
            Console.ReadKey();

            int total = 0;

            Stopwatch sw = new Stopwatch();

            for (int c = 0; c < 10; c++)
            {
                int counter = 0;
                sw.Reset();
                sw.Start();

                while (sw.ElapsedMilliseconds < 1000)
                {
                    for (int i = 0; i < 100; i++)
                    {
                        MqlTick tick = new MqlTick { Time = 640000, Bid = 1.2345 };
                        host.SendTick("GBPUSD", tick);
                    }
                    counter++;
                }

                sw.Stop();
                total += counter * 100;

                Console.WriteLine("{0} ticks per second", counter * 100);
            }

            Console.WriteLine("Average {0:F2} ticks per second", total / 10);
            
            host.Close();

            Console.ReadKey();
        }
    }
}
