using System;
using System.Collections.Generic;
using System.Windows.Forms;
using ikvm.runtime;

namespace WekaGUI
{
    static class Program
    {
        /// <summary>
        /// 应用程序的主入口点。
        /// </summary>
        [STAThread]
        public static int Main(string[] args)
        {
            int num = 0;
            try
            {
                Startup.enterMainThread();

                RunWeka.main(args);

                //weka.Run.main(args);
                //weka.gui.GUIChooser.main(Startup.glob());
            }
            catch (Exception exception1)
            {
                Exception exception = Util.mapException(exception1);
                java.lang.Thread thread = java.lang.Thread.currentThread();
                thread.getThreadGroup().uncaughtException(thread, exception);
                num = 1;
            }
            finally
            {
                Startup.exitMainThread();
            }
            return num;
        }

 

    }
}
