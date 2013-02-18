using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NetSVMLight;
using System.IO;

namespace NetSVMLightConsoleApplication1
{
    public class IncorrectFileParser
    {
        public static void ParseIncorrectFile(String incorrectFile)
        {
            StreamReader reader = new StreamReader(incorrectFile);
            List<CheapFeatureVector> vectors = new List<CheapFeatureVector>();
            while (!reader.EndOfStream)
            {
                String line = reader.ReadLine();
                if (!line.StartsWith("#"))
                {
                    bool assignedLabel = line[0].Equals('-') ? false : true;
                    String[] fvParts = line.Split('#');
                    Double svmlightValue = Double.Parse(fvParts[2]);
                    String fbTwitterNames = fvParts[1];
                    vectors.Add(new CheapFeatureVector
                                {
                                    instance = fvParts[0],
                                    label = assignedLabel,
                                    metadata = fbTwitterNames,
                                    svmLightOutput = svmlightValue
                                }); 
                }
            }

            
            foreach (var item in vectors)
            {
                Console.WriteLine(item.label.ToString() + " " + item.svmLightOutput);
            }

            Console.ReadLine();
        }
    }
}
