//+------------------------------------------------------------------+
//|                                                MyExpertModel.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Arrays\List.mqh>
#include <EA\ExpertCreator.mqh>

CList list_model;
ExpertFactory expertFactory;

enum ExpertType
{
    None = 0,
    ForexMorning = 1,
    FxComboBreakout = 2,
    FxComboReversal = 4,
    FxComboScalping = 8,
    FapTuoboEURCHF = 16,
    FapTuoboEURGBP = 32,
    FapTuoboGBPCHF = 64,
    FapTuoboUSDCHF = 128,
    FapTuoboGBPUSD = 256,
    FapTuoboEURUSD = 512,
    FapTuoboUSDCAD = 1024,  //10
    TwentyTwoHundred = 2048,
    PipersMinerEE = 4096,
    SafeDroid = 8192,
    MegaDroid1 = 16384,
    MegaDroid2 = 32768,
    ForexGrowthBot = 65536
};

int UseExpert = None
    //| ForexMorning;
    | FxComboBreakout | FxComboReversal | FxComboScalping;
    //| FapTuoboGBPUSD;// | FapTuoboEURCHF | FapTuoboGBPCHF | FapTuoboUSDCHF | FapTuoboEURGBP | FapTuoboEURUSD | FapTuoboUSDCAD;
    //| TwentyTwoHundred
    //| PipersMinerEE;
    //| SafeDroid;    // no
    //| MegaDroid1;// | MegaDroid2;
    //| ForexGrowthBot;


int OnInit()
{
    /*int pow2 = false;
    for(int i=0; i<20; ++i)
        if (UseExpert == MathPow(2, i))
        {
            pow2 = true;
            break;
        }
    if (!pow2)
        return -1;*/
        
    //int UseExpert = (int)MathPow(2, UseExpertPow);
       
    /*CList listmodel;
    CObject a, b, c, d;
    listmodel.Insert(GetPointer(a), 0);
    listmodel.Insert(GetPointer(b), 0);
    listmodel.Insert(GetPointer(c), 0);
    listmodel.Insert(GetPointer(d), 0);
    Print("Aaa");*/
    
    CExpertModel* expert;

    // ForexMorning
    if ( (UseExpert & ForexMorning) == ForexMorning)
    {
        expert = expertFactory.CreateForexMorningExpert();
        TryAddExpert(expert);
    }
    
    // FxCombo
    if ( (UseExpert & FxComboBreakout) == FxComboBreakout)
    {
        expert = expertFactory.CreateFXCOMBOBreakoutExpert();
        TryAddExpert(expert);
    }
    if ( (UseExpert & FxComboReversal) == FxComboReversal)
    {
        expert = expertFactory.CreateFXCOMBOReversalExpert();
        TryAddExpert(expert);
    }
    if ( (UseExpert & FxComboScalping) == FxComboScalping)
    {
        expert = expertFactory.CreateFXCOMBOScalpingExpert();
        TryAddExpert(expert);
    }
    
        
    //FapTuobo
    if ( (UseExpert & FapTuoboEURCHF) == FapTuoboEURCHF)
    {
        expert = expertFactory.CreateFapTuoboScalperExpertEURCHF();
        TryAddExpert(expert);
    }
    if ( (UseExpert & FapTuoboEURGBP) == FapTuoboEURGBP)
    {
        expert = expertFactory.CreateFapTuoboScalperExpertEURGBP();
        TryAddExpert(expert);
    }
    if ( (UseExpert & FapTuoboGBPCHF) == FapTuoboGBPCHF)
    {
        expert = expertFactory.CreateFapTuoboScalperExpertGBPCHF();
        TryAddExpert(expert);
    }
    if ( (UseExpert & FapTuoboUSDCHF) == FapTuoboUSDCHF)
    {
        expert = expertFactory.CreateFapTuoboScalperExpertUSDCHF();
        TryAddExpert(expert);
    }
    if ( (UseExpert & FapTuoboGBPUSD) == FapTuoboGBPUSD)
    {
        expert = expertFactory.CreateFapTuoboScalperExpertGBPUSD();
        TryAddExpert(expert);
    }
    if ( (UseExpert & FapTuoboEURUSD) == FapTuoboEURUSD)
    {
        expert = expertFactory.CreateFapTuoboScalperExpertEURUSD();
        TryAddExpert(expert);
    }
    if ( (UseExpert & FapTuoboUSDCAD) == FapTuoboUSDCAD)
    {
        expert = expertFactory.CreateFapTuoboScalperExpertUSDCAD();
        TryAddExpert(expert);
    }
        
    //20-200
    if ( (UseExpert & TwentyTwoHundred) == TwentyTwoHundred)
    {
        expert = expertFactory.Create20200Expert();
        TryAddExpert(expert);
    }
    /*    
    //PipersMinerEE
    if ( (UseExpert & PipersMinerEE) == PipersMinerEE)
    {
        expert = expertFactory.CreatePipersMinerEEExpert();
        TryAddExpert(expert);
    }
        
    //SafeDroid
    if ( (UseExpert & SafeDroid) == SafeDroid)
    {
        expert = expertFactory.CreateSafeDroidExpert();
        TryAddExpert(expert);
    }
    */
    
    //MegaDroid
    if ( (UseExpert & MegaDroid1) == MegaDroid1)
    {
        expert = expertFactory.CreateMegaDroidExpert1();
        TryAddExpert(expert);
    }
    if ( (UseExpert & MegaDroid2) == MegaDroid2)
    {
        expert = expertFactory.CreateMegaDroidExpert2();
        TryAddExpert(expert);
    }
    
    //ForexGrowthBot
    if ( (UseExpert & ForexGrowthBot) == ForexGrowthBot)
    {
        expert = expertFactory.CreateForexGrowthBotExpert();
        TryAddExpert(expert);
    }
    return(0);
}

//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    CExpertModel *ExtExpert = list_model.GetFirstNode();
    while (ExtExpert != NULL)
    {    
        CExpertModel *ExtExpertNext = list_model.GetNextNode();
        ExtExpert.Deinit();
        ExtExpert = ExtExpertNext;
    }
}
//+------------------------------------------------------------------+
//| Function-event handler "tick"                                    |
//+------------------------------------------------------------------+
void OnTick()
{
    CExpertModel *ExtExpert = list_model.GetFirstNode();
    while (ExtExpert != NULL)
    {    
        ExtExpert.OnTick();
        ExtExpert = list_model.GetNextNode();
    }
}
//+------------------------------------------------------------------+
//| Function-event handler "trade"                                   |
//+------------------------------------------------------------------+
void OnTrade()
{
    CExpertModel *ExtExpert = list_model.GetFirstNode();
    while (ExtExpert != NULL)
    {    
        ExtExpert.OnTrade();
        ExtExpert = list_model.GetNextNode();
    }
}
//+------------------------------------------------------------------+
//| Function-event handler "timer"                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    CExpertModel *ExtExpert = list_model.GetFirstNode();
    while (ExtExpert != NULL)
    {    
        ExtExpert.OnTimer();
        ExtExpert = list_model.GetNextNode();
    }
}
//+------------------------------------------------------------------+

void TryAddExpert(CExpertModel* expert)
{
    if (expert != NULL) 
    {
        list_model.Add(expert);
        
        Print(expert.Name(), "(", expert.Symbol(), ", ", GetPeriodName(expert.Period()), ", ", expert.Magic(), ") has been added to the expert collection");
    }
    else
    {
        Print(__FUNCTION__+": error when add expert!");
    }
}
