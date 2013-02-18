import clr;
clr.AddReference("MLEA");
import MLEA;
MLEA.WekaUtils.ConvertDataToMql("c:\\ea_order.txt", "D:\\Program Files\\MetaTrader 5\\MQL5\\Include\\Data\\ea_order.mqh");
MLEA.TestTool.GetResultCost("E:\\Forex\\Forex3\\100_50\\W4D2\\console.txt","c:\\100_50_3.txt");