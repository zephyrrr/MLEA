using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;
using QExport.Communication;
using QExport.Client;

namespace ConsoleClient
{
    class Program
    {
        static void Main(string[] args)
        {
            ExportClient client = new ExportClient("mt5");

            client.TickRecieved += client_TickRecieved;

            client.Open();

            Console.WriteLine("Connected to server... Press ant key to exit");
            Console.ReadKey();

            client.Close();
        }

        static void client_TickRecieved(object sender, TickRecievedEventArgs e)
        {
            Console.WriteLine("{0} {1:dd.MM.yyyy HH:mm:ss} {2}",
                e.Symbol,
                new DateTime(1970, 1, 1).AddSeconds(e.Tick.Time),
                e.Tick.Bid);
        }
    }
}
