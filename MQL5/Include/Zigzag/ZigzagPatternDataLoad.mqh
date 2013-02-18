#include <Files/FileTxt.mqh>
#include <Utils\Utils.mqh>

string m_historyDealsTxt[];

bool readAllDealTxt = false;

bool Load(int ProfitTarget, int StopLoss)
{
    if (readAllDealTxt)
    {
        return true;
    }
    
    CFileTxt file;
        string fileName = Symbol() + "_" + GetPeriodName(Period()) + "_Pattern3DetailMerge" + IntegerToString(ProfitTarget / 10) + "-" + IntegerToString(StopLoss / 10) + ".txt";
    
        if (!file.IsExist(fileName))
        {
            // C:\Users\All Users\MetaQuotes\Terminal\Common\Files
            file.SetCommon(true);
        }
    
        if(file.Open(fileName, FILE_READ) == INVALID_HANDLE)
        {
            Alert("Error in Opening ",fileName, "! Error code is ", GetLastError());
            readAllDealTxt = true;
            return false;
        }
    
        file.Seek(0, SEEK_SET);
        
        ArrayResize(m_historyDealsTxt, 10000);
        int lineIdx = 0;
        while(!file.IsEnding())
        {
            string s = file.ReadString();
            if (s == NULL || StringLen(s) == 0)
                continue;
            m_historyDealsTxt[lineIdx] = s;
            lineIdx++;
            
            if (lineIdx == ArraySize(m_historyDealsTxt))
            {
                ArrayResize(m_historyDealsTxt, lineIdx + 10000);
            }
         }
         file.Close();
         readAllDealTxt = true;
         
         Print("loaded History Deal Count is ", lineIdx);
    return true;
}