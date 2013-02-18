using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace MLEA
{
    public class CaptchaTest
    {
        public static void GenerateTrainTest()
        {
            using (StreamWriter sw = new StreamWriter("d:\\test.arff"))
            {
                sw.WriteLine("@relation 'Captcha'");
                for (int i = 0; i < 150; ++i)
                {
                    sw.WriteLine(string.Format("@attribute p{0}", i.ToString()) + " {0, 1}");
                }
                sw.WriteLine("@attribute prop {0,1}");
                sw.WriteLine("@data");
                sw.WriteLine();
                using (StreamReader sr = new StreamReader("d:\\downloads\\reference\\train_EntWeb_1a.txt"))
                {
                    while (!sr.EndOfStream)
                    {
                        string s1 = sr.ReadLine();
                        string s2 = sr.ReadLine();

                        string[] sp = s1.Split(new char[] {' '}, StringSplitOptions.RemoveEmptyEntries);
                        WekaUtils.DebugAssert(sp.Length == 150, "");
                        for(int i=0; i<sp.Length; ++i)
                            sw.Write(sp[i].Trim() + " ");

                        if (s2 == "1 0")
                            sw.WriteLine("1");
                        else if (s2 == "0 1")
                            sw.WriteLine("0");
                        else
                            WekaUtils.DebugAssert(false, "");
                    }
                }
            }
        }
    }
}
