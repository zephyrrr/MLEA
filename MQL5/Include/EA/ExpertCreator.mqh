//+------------------------------------------------------------------+
//|                                                ExpertCreator.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

#include <ExpertModel\ExpertModel.mqh>

//#include <ExpertModel\ExpertModelMoney.mqh>
#include <ExpertModel\Money\MoneyFixedLot.mqh>
#include <ExpertModel\Money\MoneyFixedMargin.mqh>
#include <ExpertModel\Money\MoneyFixedPosition.mqh>
#include <ExpertModel\Money\MoneyFixedRisk.mqh>

#include <ExpertModel\Trailing\TrailingNone.mqh>
#include <ExpertModel\Trailing\TrailingFixedPips.mqh>

#include <EA\FXCOMBOScalpingSignal.mqh>
#include <EA\FXCOMBOBreakoutSignal.mqh>
#include <EA\FXCOMBOBreakoutTrailing.mqh>
#include <EA\FXCOMBOReversalSignal.mqh>
#include <EA\FXCOMBOReversalTrailing.mqh>

#include <EA\ForexMorningSignal.mqh>
#include <EA\ForexMorningTrailing.mqh>

#include <EA\FapTuoboScalperSignal.mqh>
#include <EA\FapTuoboScalperTrailing.mqh>

#include <EA\20-200Signal.mqh>

#include <EA\PipesMinerEESignal.mqh>
#include <EA\PipesMinerEETrailing.mqh>
#include <EA\PipesMinerEEMoney.mqh>

#include <EA\SafeDroidSignal.mqh>

#include <EA\MegaDroidSignal1.mqh>
#include <EA\MegaDroidTrailing1.mqh>

#include <EA\MegaDroidSignal2.mqh>
#include <EA\MegaDroidTrailing2.mqh>

#include <EA\ForexGrowthBotSignal.mqh>
#include <EA\ForexGrowthBotTrailing.mqh>

//#include <EA\WekaExpertSignal.mqh>

#include <EA\OrderTxtSignal.mqh>
#include <EA\MLEASignal.mqh>

#include <EA\Championship_2010.mqh>

int ForexMorningExpert_momentumPeriod = 60;
int ForexMorningExpert_cciPeriod = 60;
int ForexMorningExpert_atrPeriod = 20;
int ForexMorningExpert_momentumLimit = 80;
bool ForexMorningExpert_enableCheckLongCandle = true;
int ForexMorningExpert_brokerStopLossPips = 55;
int ForexMorningExpert_brokerProfitTargetPips = 55;
int ForexMorningExpert_hiddenStopLossPips = 40;
int ForexMorningExpert_hiddenProfitTargetPips = 35;
int ForexMorningExpert_checkHour = 7;
int ForexMorningExpert_checkMinute = 30;
int ForexMorningExpert_breakEvenAtPipsProfit = 20;
int ForexMorningExpert_breakEvenAddPips = 0;
int ForexMorningExpert_trailingStopPips = 0;
// 70,95,7,10,10

// Modify bool CExpert::Init() to remove symbol and period check
class ExpertFactory
{
private:
    CExpertModelMoney* CreateDefaultExpertMoney();
    CExpertModel* CreateFapTuoboScalperExpert(string symbol, int magic);
    void DeleteExpert(CExpertModel* expert);
    
public:
    CExpertModel* CreateMLEAExpert();
    CExpertModel* CreateOrderTxtExpert();
    CExpertModel* CreateWekaExpert();
    CExpertModel* CreateSafeDroidExpert();
    CExpertModel* CreatePipersMinerEEExpert();
    CExpertModel* Create20200Expert();
    CExpertModel* CreateFapTuoboScalperExpertEURCHF();
    CExpertModel* CreateFapTuoboScalperExpertEURGBP();
    CExpertModel* CreateFapTuoboScalperExpertGBPCHF();
    CExpertModel* CreateFapTuoboScalperExpertUSDCHF();
    CExpertModel* CreateFapTuoboScalperExpertGBPUSD();
    CExpertModel* CreateFapTuoboScalperExpertEURUSD();
    CExpertModel* CreateFapTuoboScalperExpertUSDCAD();
    CExpertModel* CreateForexMorningExpert();
    CExpertModel* CreateFXCOMBOScalpingExpert();
    CExpertModel* CreateFXCOMBOBreakoutExpert();
    CExpertModel* CreateFXCOMBOReversalExpert();
    CExpertModel* CreateMegaDroidExpert1();
    CExpertModel* CreateMegaDroidExpert2();
    CExpertModel* CreateForexGrowthBotExpert();
};


CExpertModelMoney* ExpertFactory::CreateDefaultExpertMoney()
{
    CMoneyFixedLot *money = new CMoneyFixedLot;
    money.Percent(100);
    money.Lots(0.01);
    
    //CMoneyFixedMargin *money = new CMoneyFixedMargin();
    //money.Percent(1);
    
    //CMoneyFixedPosition* money = new CMoneyFixedPosition();
    //money.Percent(50);
    //money.Lots(5);
    //money.MaxPositionLot(15);
    
    //CTurtleMoney *money = new CTurtleMoney();
   
    return money;
}

CExpertModel* ExpertFactory::CreateMLEAExpert()
{
    CExpertModel* expert = new CExpertModel;
    if(!expert.Init(Symbol(), Period(), true, 11111, "MLEA"))
    {
        printf(__FUNCTION__+": error initializing expert");
        DeleteExpert(expert);
        return NULL;
    }

    CMLEASignal *signal = new CMLEASignal;
    if(signal==NULL || !expert.InitSignal(signal) || !signal.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating signal");
        DeleteExpert(expert);
        return NULL;
    }
    signal.InitParameters();
    
    //CExpertModelTrailing *trailing = new CTrailingFixedPips(600, 1000); 
    CExpertModelTrailing *trailing = new CTrailingNone();
    if(trailing==NULL || !expert.InitTrailing(trailing) || !trailing.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating trailing");
        DeleteExpert(expert);
        return NULL;
    }
    //trailing.InitParameters();

    CExpertModelMoney* money = new CMoneyFixedLot(0.01);// CMoneyFixedMargin(); //();// CMoneyFixedRisk();
    //CExpertModelMoney* money = new CMoneyFixedMargin();
    money.Percent(0.002);
    
    if(money==NULL || !expert.InitMoney(money) || !money.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating money");
        DeleteExpert(expert);
        return NULL;
    }

    if(!expert.InitIndicators())
    {
        printf(__FUNCTION__+": error initializing indicators");
        DeleteExpert(expert);
        return NULL;
    }
    
    return expert;
}

CExpertModel* ExpertFactory::CreateOrderTxtExpert()
{
    CExpertModel* expert = new CExpertModel;
    if(!expert.Init(Symbol(), Period(), true, 11111, "OrTxt"))
    {
        printf(__FUNCTION__+": error initializing expert");
        DeleteExpert(expert);
        return NULL;
    }

    COrderTxtSignal *signal = new COrderTxtSignal;
    //CChampionship_2010 *signal = new CChampionship_2010();
    
    if(signal==NULL || !expert.InitSignal(signal) || !signal.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating signal");
        DeleteExpert(expert);
        return NULL;
    }
    signal.InitParameters();
    
    //CExpertModelTrailing *trailing = new CTrailingFixedPips(100, 300); 
    CExpertModelTrailing *trailing = new CTrailingNone();
    //CExpertModelTrailing *trailing = new CTrailingFixedPips(600, 1000); 

    if(trailing==NULL || !expert.InitTrailing(trailing) || !trailing.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating trailing");
        DeleteExpert(expert);
        return NULL;
    }
    //trailing.InitParameters();

    CExpertModelMoney* money = new CMoneyFixedLot(0.01);// CMoneyFixedMargin(); //();// CMoneyFixedRisk();
    //CExpertModelMoney* money = new CMoneyFixedMargin();
    money.Percent(0.002);
    
    if(money==NULL || !expert.InitMoney(money) || !money.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating money");
        DeleteExpert(expert);
        return NULL;
    }

    if(!expert.InitIndicators())
    {
        printf(__FUNCTION__+": error initializing indicators");
        DeleteExpert(expert);
        return NULL;
    }
    
    return expert;
}
CExpertModel* ExpertFactory::CreateWekaExpert()
{
    CExpertModel* expert = new CExpertModel;
    /*if(!expert.Init("EURUSD", PERIOD_M5, true, 66666, "WekaExpert"))
    {
        printf(__FUNCTION__+": error initializing expert");
        DeleteExpert(expert);
        return NULL;
    }

    CWekaExpertSignal *signal = new CWekaExpertSignal;
    if(signal==NULL || !expert.InitSignal(signal) || !signal.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating signal");
        DeleteExpert(expert);
        return NULL;
    }
    signal.InitParameters();
    
    CTrailingNone *trailing = new CTrailingNone();
    if(trailing==NULL || !expert.InitTrailing(trailing) || !trailing.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating trailing");
        DeleteExpert(expert);
        return NULL;
    }
    //trailing.InitParameters();
    
    CExpertModelMoney* money = CreateDefaultExpertMoney();
    if(money==NULL || !expert.InitMoney(money) || !money.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating money");
        DeleteExpert(expert);
        return NULL;
    }

    if(!expert.InitIndicators())
    {
        printf(__FUNCTION__+": error initializing indicators");
        DeleteExpert(expert);
        return NULL;
    }*/
    
    return expert;
}

CExpertModel* ExpertFactory::CreateForexGrowthBotExpert()
{
    CExpertModel* expert = new CExpertModel;
    if(!expert.Init("EURUSD", PERIOD_M15, true, 88810, "ForexGrowthBot"))
    {
        printf(__FUNCTION__+": error initializing expert");
        DeleteExpert(expert);
        return NULL;
    }

    CForexGrowthBotSignal *signal = new CForexGrowthBotSignal;
    if(signal==NULL || !expert.InitSignal(signal) || !signal.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating signal");
        DeleteExpert(expert);
        return NULL;
    }
    signal.InitParameters();
    
    CForexGrowthBotTrailing *trailing = new CForexGrowthBotTrailing();
    if(trailing==NULL || !expert.InitTrailing(trailing) || !trailing.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating trailing");
        DeleteExpert(expert);
        return NULL;
    }
    trailing.InitParameters();
    
    CExpertModelMoney* money = CreateDefaultExpertMoney();
    if(money==NULL || !expert.InitMoney(money) || !money.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating money");
        DeleteExpert(expert);
        return NULL;
    }

    if(!expert.InitIndicators())
    {
        printf(__FUNCTION__+": error initializing indicators");
        DeleteExpert(expert);
        return NULL;
    }
    
    return expert;
}

CExpertModel* ExpertFactory::CreateMegaDroidExpert1()
{
    CExpertModel* expert = new CExpertModel;
    if(!expert.Init("EURUSD", PERIOD_H1, true, 88820, "MegaDroid1"))
    {
        printf(__FUNCTION__+": error initializing expert");
        DeleteExpert(expert);
        return NULL;
    }

    CMegaDroidSignal1 *signal = new CMegaDroidSignal1;
    if(signal==NULL || !expert.InitSignal(signal) || !signal.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating signal");
        DeleteExpert(expert);
        return NULL;
    }
    signal.InitParameters();
    
    CMegaDroidTrailing1 *trailing = new CMegaDroidTrailing1();
    if(trailing==NULL || !expert.InitTrailing(trailing) || !trailing.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating trailing");
        DeleteExpert(expert);
        return NULL;
    }
    trailing.InitParameters();
    
    CExpertModelMoney* money = CreateDefaultExpertMoney();
    if(money==NULL || !expert.InitMoney(money) || !money.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating money");
        DeleteExpert(expert);
        return NULL;
    }

    if(!expert.InitIndicators())
    {
        printf(__FUNCTION__+": error initializing indicators");
        DeleteExpert(expert);
        return NULL;
    }
    
    return expert;
}

CExpertModel* ExpertFactory::CreateMegaDroidExpert2()
{
    CExpertModel* expert = new CExpertModel;
    if(!expert.Init("EURUSD", PERIOD_H1, true, 88821, "MegaDroid2"))
    {
        printf(__FUNCTION__+": error initializing expert");
        DeleteExpert(expert);
        return NULL;
    }

    CMegaDroidSignal2 *signal = new CMegaDroidSignal2;
    if(signal==NULL || !expert.InitSignal(signal) || !signal.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating signal");
        DeleteExpert(expert);
        return NULL;
    }
    signal.InitParameters();
    
    CMegaDroidTrailing2 *trailing = new CMegaDroidTrailing2();
    if(trailing==NULL || !expert.InitTrailing(trailing) || !trailing.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating trailing");
        DeleteExpert(expert);
        return NULL;
    }
    trailing.InitParameters();
    
    CExpertModelMoney* money = CreateDefaultExpertMoney();
    if(money==NULL || !expert.InitMoney(money) || !money.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating money");
        DeleteExpert(expert);
        return NULL;
    }

    if(!expert.InitIndicators())
    {
        printf(__FUNCTION__+": error initializing indicators");
        DeleteExpert(expert);
        return NULL;
    }
    
    return expert;
}


CExpertModel* ExpertFactory::CreateSafeDroidExpert()
{
    CExpertModel* expert = new CExpertModel;
    if(!expert.Init("EURUSD", PERIOD_M30, true, 88830, "SafeDroid"))
    {
        printf(__FUNCTION__+": error initializing expert");
        DeleteExpert(expert);
        return NULL;
    }

    CSafeDroidSignal *signal = new CSafeDroidSignal;
    if(signal==NULL || !expert.InitSignal(signal) || !signal.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating signal");
        DeleteExpert(expert);
        return NULL;
    }
    signal.InitParameters();
    
    CTrailingNone *trailing = new CTrailingNone();
    if(trailing==NULL || !expert.InitTrailing(trailing) || !trailing.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating trailing");
        DeleteExpert(expert);
        return NULL;
    }
    //trailing.InitParameters();
    
    CExpertModelMoney* money = CreateDefaultExpertMoney();
    if(money==NULL || !expert.InitMoney(money) || !money.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating money");
        DeleteExpert(expert);
        return NULL;
    }
    
    if(!expert.InitIndicators())
    {
        printf(__FUNCTION__+": error initializing indicators");
        DeleteExpert(expert);
        return NULL;
    }
    
    return expert;
}


CExpertModel* ExpertFactory::CreatePipersMinerEEExpert()
{
    CExpertModel* expert = new CExpertModel;
    if(!expert.Init("EURUSD", PERIOD_M5, true, 88840, "PipersMinerEE"))
    {
        printf(__FUNCTION__+": error initializing expert");
        DeleteExpert(expert);
        return NULL;
    }

    CPipesMinerEESignal *signal = new CPipesMinerEESignal;
    if(signal==NULL || !expert.InitSignal(signal) || !signal.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating signal");
        DeleteExpert(expert);
        return NULL;
    }
    signal.InitParameters();
    
    CPipesMinerEETrailing *trailing = new CPipesMinerEETrailing();
    if(trailing==NULL || !expert.InitTrailing(trailing) || !trailing.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating trailing");
        DeleteExpert(expert);
        return NULL;
    }
    trailing.InitParameters();
    
    //CPipesMinerEEMoney* money = new CPipesMinerEEMoney();
    CExpertModelMoney* money = CreateDefaultExpertMoney();
    if(money==NULL || !expert.InitMoney(money) || !money.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating money");
        DeleteExpert(expert);
        return NULL;
    }
    //money.Lots(0.1);
    //money.Martingale(1);
    
    if(!expert.InitIndicators())
    {
        printf(__FUNCTION__+": error initializing indicators");
        DeleteExpert(expert);
        return NULL;
    }
    
    return expert;
}

CExpertModel* ExpertFactory::Create20200Expert()
{
    CExpertModel* expert = new CExpertModel;
    if(!expert.Init("EURUSD", PERIOD_H1, true, 88850, "20-200"))
    {
        printf(__FUNCTION__+": error initializing expert");
        DeleteExpert(expert);
        return NULL;
    }
    
    C20200Signal *signal = new C20200Signal;
    if(signal==NULL || !expert.InitSignal(signal) || !signal.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating signal");
        DeleteExpert(expert);
        return NULL;
    }
    signal.InitParameters();
    
    CTrailingNone *trailing = new CTrailingNone();
    if(trailing==NULL || !expert.InitTrailing(trailing) || !trailing.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating trailing");
        DeleteExpert(expert);
        return NULL;
    }
    //trailing.InitParameters();
    
    CExpertModelMoney* money = CreateDefaultExpertMoney();
    if(money==NULL || !expert.InitMoney(money) || !money.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating money");
        DeleteExpert(expert);
        return NULL;
    }

    if(!expert.InitIndicators())
    {
        printf(__FUNCTION__+": error initializing indicators");
        DeleteExpert(expert);
        return NULL;
    }
    
    return expert;
}

CExpertModel* ExpertFactory::CreateFapTuoboScalperExpertEURCHF()
{
    return CreateFapTuoboScalperExpert("EURCHF", 88860);
}
CExpertModel* ExpertFactory::CreateFapTuoboScalperExpertEURGBP()
{
    return CreateFapTuoboScalperExpert("EURGBP", 88861);
}
CExpertModel* ExpertFactory::CreateFapTuoboScalperExpertGBPCHF()
{
    return CreateFapTuoboScalperExpert("GBPCHF", 88862);
}
CExpertModel* ExpertFactory::CreateFapTuoboScalperExpertUSDCHF()
{
    return CreateFapTuoboScalperExpert("USDCHF", 88863);
}
CExpertModel* ExpertFactory::CreateFapTuoboScalperExpertGBPUSD()
{
    return CreateFapTuoboScalperExpert("GBPUSD", 88864);
}
CExpertModel* ExpertFactory::CreateFapTuoboScalperExpertEURUSD()
{
    return CreateFapTuoboScalperExpert("EURUSD", 88865);
}
CExpertModel* ExpertFactory::CreateFapTuoboScalperExpertUSDCAD()
{
    return CreateFapTuoboScalperExpert("USDCAD", 88866);
}
CExpertModel* ExpertFactory::CreateFapTuoboScalperExpert(string symbol, int magic)
{
    CExpertModel* expert = new CExpertModel;
    if(!expert.Init(symbol, PERIOD_M15, true, magic, "FapTuobo"))
    {
        printf(__FUNCTION__+": error initializing expert");
        DeleteExpert(expert);
        return NULL;
    }

    CFapTuoboScalperSignal *signal = new CFapTuoboScalperSignal;
    if(signal==NULL || !expert.InitSignal(signal) || !signal.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating signal");
        DeleteExpert(expert);
        return NULL;
    }
    signal.InitParameters();
    
    CFapTuoboScalperTrailing *trailing = new CFapTuoboScalperTrailing();
    if(trailing==NULL || !expert.InitTrailing(trailing) || !trailing.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating trailing");
        DeleteExpert(expert);
        return NULL;
    }
    trailing.InitParameters();
    
    CExpertModelMoney* money = CreateDefaultExpertMoney();
    if(money==NULL || !expert.InitMoney(money) || !money.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating money");
        DeleteExpert(expert);
        return NULL;
    }

    if(!expert.InitIndicators())
    {
        printf(__FUNCTION__+": error initializing indicators");
        DeleteExpert(expert);
        return NULL;
    }
    
    return expert;
}

CExpertModel* ExpertFactory::CreateForexMorningExpert()
{
    CExpertModel* expert = new CExpertModel;
    if(!expert.Init("GBPUSD", PERIOD_M15, true, 88870, "ForexMorning"))
    {
        printf(__FUNCTION__+": error initializing expert");
        DeleteExpert(expert);
        return NULL;
    }

    CForexMorningSignal *signal = new CForexMorningSignal;
    if(signal==NULL || !expert.InitSignal(signal) || !signal.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating signal");
        DeleteExpert(expert);
        return NULL;
    }
    signal.InitParameters(ForexMorningExpert_momentumPeriod, ForexMorningExpert_cciPeriod, ForexMorningExpert_atrPeriod, 
        ForexMorningExpert_momentumLimit, ForexMorningExpert_enableCheckLongCandle,
        ForexMorningExpert_brokerStopLossPips, ForexMorningExpert_brokerProfitTargetPips, 
        ForexMorningExpert_hiddenStopLossPips, ForexMorningExpert_hiddenProfitTargetPips,
        ForexMorningExpert_checkHour, ForexMorningExpert_checkMinute);
    
    CForexMorningTrailing *trailing = new CForexMorningTrailing;
    if(trailing==NULL || !expert.InitTrailing(trailing) || !trailing.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating trailing");
        DeleteExpert(expert);
        return NULL;
    }
    trailing.InitParameters(ForexMorningExpert_breakEvenAtPipsProfit, ForexMorningExpert_breakEvenAddPips, 
    ForexMorningExpert_trailingStopPips);
    
    CExpertModelMoney* money = CreateDefaultExpertMoney();
    if(money==NULL || !expert.InitMoney(money) || !money.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating money");
        DeleteExpert(expert);
        return NULL;
    }

    if(!expert.InitIndicators())
    {
        printf(__FUNCTION__+": error initializing indicators");
        DeleteExpert(expert);
        return NULL;
    }
    
    return expert;
}


CExpertModel* ExpertFactory::CreateFXCOMBOScalpingExpert()
{
    CExpertModel* expert = new CExpertModel;
    if(!expert.Init("EURUSD", PERIOD_M5, true, 88881, "FXCOMBOScalping"))
    {
        printf(__FUNCTION__+": error initializing expert");
        DeleteExpert(expert);
        return NULL;
    }

    CFXCOMBOScalpingSignal *signal = new CFXCOMBOScalpingSignal;
    if(signal==NULL || !expert.InitSignal(signal) || !signal.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating signal");
        DeleteExpert(expert);
        return NULL;
    }
     
    CTrailingNone *trailing=new CTrailingNone;
    if(trailing==NULL || !expert.InitTrailing(trailing) || !trailing.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating trailing");
        DeleteExpert(expert);
        return NULL;
    }
     
    CExpertModelMoney* money = CreateDefaultExpertMoney();
    if(money==NULL || !expert.InitMoney(money) || !money.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating money");
        DeleteExpert(expert);
        return NULL;
    }

    if(!expert.InitIndicators())
    {
        printf(__FUNCTION__+": error initializing indicators");
        DeleteExpert(expert);
        return NULL;
    }
    
    return expert;
}

CExpertModel* ExpertFactory::CreateFXCOMBOBreakoutExpert()
{
    CExpertModel* expert = new CExpertModel;
    if(!expert.Init("EURUSD", PERIOD_M5, true, 88882, "FXCOMBOBreakout"))
    {
        printf(__FUNCTION__+": error initializing expert");
        DeleteExpert(expert);
        return NULL;
    }

    CFXCOMBOBreakoutSignal *signal = new CFXCOMBOBreakoutSignal;
    if(signal==NULL || !expert.InitSignal(signal) || !signal.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating signal");
        DeleteExpert(expert);
        return NULL;
    }
     
    CFXCOMBOBreakoutTrailing *trailing = new CFXCOMBOBreakoutTrailing;
    if(trailing==NULL || !expert.InitTrailing(trailing) || !trailing.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating trailing");
        DeleteExpert(expert);
        return NULL;
    }
     
    CExpertModelMoney* money = CreateDefaultExpertMoney();
    if(money==NULL || !expert.InitMoney(money) || !money.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating money");
        DeleteExpert(expert);
        return NULL;
    }

    if(!expert.InitIndicators())
    {
        printf(__FUNCTION__+": error initializing indicators");
        DeleteExpert(expert);
        return NULL;
    }
    
    return expert;
}

CExpertModel* ExpertFactory::CreateFXCOMBOReversalExpert()
{
    CExpertModel* expert = new CExpertModel;
    if(!expert.Init("EURUSD", PERIOD_M5, true, 88883, "FXCOMBOReversal"))
    {
        printf(__FUNCTION__+": error initializing expert");
        DeleteExpert(expert);
        return NULL;
    }

    CFXCOMBOReversalSignal *signal = new CFXCOMBOReversalSignal;
    if(signal==NULL || !expert.InitSignal(signal) || !signal.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating signal");
        DeleteExpert(expert);
        return NULL;
    }
    
    CFXCOMBOReversalTrailing *trailing = new CFXCOMBOReversalTrailing;
    if(trailing==NULL || !expert.InitTrailing(trailing) || !trailing.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating trailing");
        DeleteExpert(expert);
        return NULL;
    }
     
    CExpertModelMoney* money = CreateDefaultExpertMoney();
    if(money==NULL || !expert.InitMoney(money) || !money.ValidationSettings())
    {
        printf(__FUNCTION__+": error creating money");
        DeleteExpert(expert);
        return NULL;
    }

    if(!expert.InitIndicators())
    {
        printf(__FUNCTION__+": error initializing indicators");
        DeleteExpert(expert);
        return NULL;
    }
    
    return expert;
}

void ExpertFactory::DeleteExpert(CExpertModel* expert)
{
    expert.Deinit();
    delete expert;
}