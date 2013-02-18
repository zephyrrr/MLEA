using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using TicTacTec.TA.Library;


namespace MLEA
{
    public class TaLibTest
    {
        private const double TA_REAL_DEFAULT = (-4e+37);

        public void Clear()
        {
            //m_minOutNBElements.Clear();
        }

        private void AddIndicatorValues(ForexDataRows hpdv, Dictionary<long, double> indValues, Core.RetCode ret, int outBegIdx, int outNBElement, double[] outDouble)
        {
            WekaUtils.DebugAssert(ret == Core.RetCode.Success, "TaRet should Success.");
            for (int i = 0; i < outNBElement; ++i)
            {
                indValues[hpdv[i + outBegIdx].Time] = outDouble[i];
            }
        }

        public Dictionary<string, Dictionary<long, double>> GnerateIndicators(string symbol, string period)
        {
            string symbolPeriod = string.Format("{0}_{1}", symbol, period);
            ForexDataRows hpdv = DbData.Instance.GetDbData(new DateTime(1900, 1, 1), new DateTime(2100, 1, 1), symbolPeriod, 0, true, TestParameters2.CandidateParameter);

            double[] inOpen = new double[hpdv.Length];
            double[] inHigh = new double[hpdv.Length];
            double[] inLow = new double[hpdv.Length];
            double[] inClose = new double[hpdv.Length];
            int outBegIdx, outNBElement;
            double[] outDouble = new double[hpdv.Length];
            double[] outDouble2 = new double[hpdv.Length];
            double[] outDouble3 = new double[hpdv.Length];
            for (int i = 0; i < hpdv.Length; ++i)
            {
                inOpen[i] = (double)hpdv[i]["open"];
                inHigh[i] = (double)hpdv[i]["high"];
                inLow[i] = (double)hpdv[i]["low"];
                inClose[i] = (double)hpdv[i]["close"];
                outDouble[i] = -1;
                outDouble2[i] = -1;
                outDouble3[i] = -1;
            }

            Dictionary<string, Dictionary<long, double>> indValues = new Dictionary<string, Dictionary<long, double>>();
            Core.RetCode ret;
            ret = Core.Kama(0, hpdv.Length - 1, inClose, 9, out outBegIdx, out outNBElement, outDouble);
            indValues["AMA_9_2_30"] = new Dictionary<long, double>();
            AddIndicatorValues(hpdv, indValues["AMA_9_2_30"], ret, outBegIdx, outNBElement, outDouble);

            ret = Core.Atr(0, hpdv.Length - 1, inHigh, inLow, inClose, 14, out outBegIdx, out outNBElement, outDouble);
            indValues["ATR_14"] = new Dictionary<long, double>();
            AddIndicatorValues(hpdv, indValues["ATR_14"], ret, outBegIdx, outNBElement, outDouble);

            ret = Core.Bbands(0, hpdv.Length - 1, inClose, 20, 2, 2, Core.MAType.Sma, out outBegIdx, out outNBElement, outDouble, outDouble2, outDouble3);
            indValues["Bands_20_2"] = new Dictionary<long, double>();
            AddIndicatorValues(hpdv, indValues["Bands_20_2"], ret, outBegIdx, outNBElement, outDouble);

            ret = Core.Macd(0, hpdv.Length - 1, inClose, 12, 26, 9, out outBegIdx, out outNBElement, outDouble, outDouble2, outDouble3);
            indValues["MACD_12_26_9_M"] = new Dictionary<long, double>();
            AddIndicatorValues(hpdv, indValues["MACD_12_26_9_M"], ret, outBegIdx, outNBElement, outDouble);
            indValues["MACD_12_26_9_S"] = new Dictionary<long, double>();
            AddIndicatorValues(hpdv, indValues["MACD_12_26_9_S"], ret, outBegIdx, outNBElement, outDouble2);

            ret = Core.Sma(0, hpdv.Length - 1, inClose, 10, out outBegIdx, out outNBElement, outDouble);
            indValues["MA_10"] = new Dictionary<long, double>();
            AddIndicatorValues(hpdv, indValues["MA_10"], ret, outBegIdx, outNBElement, outDouble);

            ret = Core.Rsi(0, hpdv.Length - 1, inClose, 14, out outBegIdx, out outNBElement, outDouble);
            indValues["RSI_14"] = new Dictionary<long, double>();
            AddIndicatorValues(hpdv, indValues["RSI_14"], ret, outBegIdx, outNBElement, outDouble);
            
            return indValues;
        }

        public const int minOutBegIdx = 15;
        //public Dictionary<string, int> minOutNBElements = new Dictionary<string, int> { { "D1", 2957/*3105*/ }, { "H4", 18667 } }; // H4:18668; // D:3106;
        //public Dictionary<string, int> m_minOutNBElements = new Dictionary<string, int>();

        private string m_currentPeriod;
        private void CheckCandlePatternResult(Core.RetCode ret, int outBegIdx, int outNBElement, int[] outInteger, string candlePatternFile)
        {
            //if (!m_minOutNBElements.ContainsKey(m_currentPeriod))
            //{
            //    m_minOutNBElements[m_currentPeriod] = outNBElement - (minOutBegIdx - outBegIdx);
            //}
            //int minOutNBElement = m_minOutNBElements[m_currentPeriod];
            int minOutNBElement = outInteger.Length - minOutBegIdx;

            WekaUtils.DebugAssert(ret == Core.RetCode.Success, "ret == Core.RetCode.Success");
            WekaUtils.DebugAssert(outBegIdx <= minOutBegIdx, "outBegIdx <= minOutBegIdx");
            WekaUtils.DebugAssert(outNBElement >= minOutNBElement + (minOutBegIdx - outBegIdx), "outNBElement >= minOutNBElement + (minOutBegIdx - outBegIdx)");

            using (StreamWriter sw = new StreamWriter(candlePatternFile, true))
            {
                for (int i = 0; i < minOutNBElement; ++i)
                {
                    WekaUtils.DebugAssert(outInteger[minOutBegIdx - outBegIdx + i] != -1, "outInteger[minOutBegIdx - outBegIdx + i] != -1");

                    sw.Write(outInteger[minOutBegIdx - outBegIdx + i]);
                    sw.Write(",");
                }
                sw.WriteLine();
            }
            //WekaUtils.DebugAssert(outInteger[minOutBegIdx - outBegIdx + minOutNBElement - 1 + 1] == -1);
            for (int i = 0; i < outInteger.Length; ++i)
                outInteger[i] = -1;
        }

        public bool GenerateCandlePatterns(string candlePatternFile)
        {
            var dataDates = TestManager.GetDataDateRange();

            var cp = TestParameters2.CandidateParameter;
            for (int s = 0; s < cp.SymbolCount; ++s)
                for (int p = 0; p < cp.PeriodCount; ++p)
                {
                    string symbol = cp.AllSymbols[cp.SymbolStart + s];
                    string period = cp.AllPeriods[cp.PeriodStart + p];

                    m_currentPeriod = period;

                    if (System.IO.File.Exists(candlePatternFile))
                        System.IO.File.Delete(candlePatternFile);

                    string symbolPeriod = string.Format("{0}_{1}", symbol, period);
                    ForexDataRows hpdv = DbData.Instance.GetDbData(dataDates[0], dataDates[1], symbolPeriod, 0, true, cp);

                    if (hpdv.Length < 2 * minOutBegIdx)
                    {
                        WekaUtils.Instance.WriteLog("No enough data for candle pattern.");
                        return false;
                    }

                    double[] inOpen = new double[hpdv.Length];
                    double[] inHigh = new double[hpdv.Length];
                    double[] inLow = new double[hpdv.Length];
                    double[] inClose = new double[hpdv.Length];
                    int outBegIdx, outNBElement;
                    int[] outInteger = new int[hpdv.Length];
                    for (int i = 0; i < hpdv.Length; ++i)
                    {
                        inOpen[i] = (double)hpdv[i]["open"];
                        inHigh[i] = (double)hpdv[i]["high"];
                        inLow[i] = (double)hpdv[i]["low"];
                        inClose[i] = (double)hpdv[i]["close"];
                        outInteger[i] = -1;
                    }

                    Core.RetCode ret;

                    ret = Core.Cdl2Crows(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.Cdl3BlackCrows(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.Cdl3Inside(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.Cdl3LineStrike(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.Cdl3Outside(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.Cdl3StarsInSouth(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.Cdl3WhiteSoldiers(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlAbandonedBaby(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, TA_REAL_DEFAULT, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlAdvanceBlock(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlBeltHold(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlBreakaway(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlClosingMarubozu(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlConcealBabysWall(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlCounterAttack(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlDarkCloudCover(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, TA_REAL_DEFAULT, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlDoji(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlDojiStar(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlDragonflyDoji(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlEngulfing(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlEveningDojiStar(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, TA_REAL_DEFAULT, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlEveningStar(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, TA_REAL_DEFAULT, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlGapSideSideWhite(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlGravestoneDoji(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlHammer(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlHangingMan(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlHarami(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlHaramiCross(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlHignWave(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlHikkake(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlHikkakeMod(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlHomingPigeon(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlIdentical3Crows(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlInNeck(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlInvertedHammer(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlKicking(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlKickingByLength(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlLadderBottom(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlLongLeggedDoji(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlLongLine(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlMarubozu(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlMatchingLow(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlMatHold(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, TA_REAL_DEFAULT, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlMorningDojiStar(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, TA_REAL_DEFAULT, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlMorningStar(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, TA_REAL_DEFAULT, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlOnNeck(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlPiercing(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlRickshawMan(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlRiseFall3Methods(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlSeperatingLines(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlShootingStar(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlShortLine(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlSpinningTop(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlStalledPattern(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlStickSandwhich(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlTakuri(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlTasukiGap(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlThrusting(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlTristar(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlUnique3River(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlUpsideGap2Crows(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                    ret = Core.CdlXSideGap3Methods(0, hpdv.Length - 1, inOpen, inHigh, inLow, inClose, out outBegIdx, out outNBElement, outInteger);
                    CheckCandlePatternResult(ret, outBegIdx, outNBElement, outInteger, candlePatternFile);
                }

            return true;
        }

        public static void FilterInstances(weka.core.Instances allInstances)
        {
            DateTime nextHpDate = DateTime.MinValue;
            java.util.LinkedList deleteList = new java.util.LinkedList();
            for (int i = 0; i < allInstances.numInstances(); ++i)
            {
                DateTime nowDate = WekaUtils.GetDateValueFromInstances(allInstances, 0, i);

                if (TestParameters2.RealTimeMode && i == allInstances.numInstances() - 1)
                {
                    allInstances.instance(i).setClassValue(0);
                    allInstances.instance(i).setValue(1, WekaUtils.GetTimeFromDate(Parameters.MaxDate) * 1000);
                }
                else
                {
                    if (nowDate < nextHpDate)
                    {
                        deleteList.Add(allInstances.instance(i));
                    }
                    else
                    {
                        DateTime hpDate = WekaUtils.GetDateValueFromInstances(allInstances, 1, i);
                        nextHpDate = hpDate;
                    }
                }
            }
            allInstances.removeAll(deleteList);
        }

        public string BuildCandlePatternDeals()
        {
            WekaUtils.Instance.WriteLog("Now BuildCandlePatternDeals");

            var cp = TestParameters2.CandidateParameter;
            string resultFile = TestParameters.GetBaseFilePath(string.Format("IncrementTest_{0}_{1}_{2}.txt",
                 cp.MainSymbol, "CandlePattern", cp.MainPeriod));
            if (File.Exists(resultFile))
                return string.Empty;

            string txtFileName = TestParameters.GetBaseFilePath(string.Format("{0}_{1}_{2}.txt",
                cp.MainSymbol, "CandlePattern", cp.MainPeriod));
            System.IO.File.Delete(txtFileName);
            if (!File.Exists(txtFileName))
            {
                bool ret = GenerateCandlePatterns(txtFileName);
                if (!ret)
                    return string.Empty;
            }

            string arffFileName = TestParameters.GetBaseFilePath(string.Format("{0}_{1}_{2}.arff",
                cp.MainSymbol, "CandlePattern", cp.MainPeriod));

            if (!System.IO.File.Exists(arffFileName))
            {
                GenerateArff(arffFileName, txtFileName);
            }

            weka.core.Instances allInstances = WekaUtils.LoadInstances(arffFileName);

            //FilterInstances(allInstances);
            WekaUtils.SaveInstances(allInstances, arffFileName);

            int n = (int)(24 / TestParameters2.MainPeriodOfHour);
            n = TestParameters2.nPeriod;
            return TestManager.IncrementTest(allInstances, () => 
                {
                    return WekaUtils.CreateClassifier(typeof(MinDistanceClassifier)); 
                    //return WekaUtils.CreateClassifier(typeof(weka.classifiers.lazy.IBk));
                }, "1,2,3,4", resultFile, n);
        }

        private void CreateCds(ref int[, , ,] cds, CandidateParameter cp, int count)
        {
            cds = new int[cp.SymbolCount, cp.PeriodCount, count, 61];
            for (int s = 0; s < cp.SymbolCount; ++s)
                for (int p = 0; p < cp.PeriodCount; ++p)
                    for (int i = 0; i < cds.GetLength(3); ++i)
                        for (int j = 0; j < cds.GetLength(2); ++j)
                            cds[s, p, j, i] = -1;
        }
        public void GenerateArff(string arffFileName, string candlePatternFile)
        {
            int preLength = TestParameters2.PreLength;

            int tpStart = TestParameters2.tpStart;
            int slStart = TestParameters2.slStart;
            int tpCount = TestParameters2.tpCount;
            int slCount = TestParameters2.slCount;

            var dataDates = TestManager.GetDataDateRange();

            int minOutBegIdx = TaLibTest.minOutBegIdx;

            var cp = TestParameters2.CandidateParameter;
            int[, , ,] cds = null;

            ForexDataRows[,] hpdvs = new ForexDataRows[cp.SymbolCount, cp.PeriodCount];

            for (int s = 0; s < cp.SymbolCount; ++s)
                for (int p = 0; p < cp.PeriodCount; ++p)
                {
                    string symbol = cp.AllSymbols[s + cp.SymbolStart];
                    string period = cp.AllPeriods[p + cp.PeriodStart];
                    string symbolPeriod = string.Format("{0}_{1}", symbol, period);
                    hpdvs[s, p] = DbData.Instance.GetDbData(dataDates[0], dataDates[1], symbolPeriod, 0, true, cp);

                    m_currentPeriod = period;
                    //int minOutNBElement = m_minOutNBElements[m_currentPeriod];
                    int minOutNBElement = hpdvs[s, p].Length - minOutBegIdx;

                    if (cds == null)
                    {
                        CreateCds(ref cds, cp, minOutNBElement + 100);
                    }

                    using (StreamReader sr = new StreamReader(candlePatternFile))
                    {
                        int n = 0;
                        while (!sr.EndOfStream)
                        {
                            string line = sr.ReadLine();
                            string[] ss = line.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                            WekaUtils.DebugAssert(ss.Length == minOutNBElement, "ss.Length == minOutNBElement");
                            for (int i = 0; i < minOutNBElement; ++i)
                                cds[s, p, i, n] = Convert.ToInt32(ss[i]);
                            n++;
                        }
                    }
                }

            if (File.Exists(arffFileName))
            {
                System.IO.File.Delete(arffFileName);
            }

            string wekaFileName = string.Format(arffFileName);
            using (StreamWriter sw = new StreamWriter(wekaFileName))
            {
                sw.WriteLine("@relation 'candlePatterns'");
                sw.WriteLine("@attribute timestamp date \"yyyy-MM-dd\'T\'HH:mm:ss\"");
                sw.WriteLine("@attribute hpdate date \"yyyy-MM-dd\'T\'HH:mm:ss\"");
                sw.WriteLine("@attribute spread numeric");
                sw.WriteLine("@attribute mainClose numeric");

                for(int pre = 0; pre<preLength; ++pre)
                    for (int s = 0; s < cp.SymbolCount; ++s)
                        for (int p = 0; p < cp.PeriodCount; ++p)
                            for (int i = 0; i < 61; ++i)
                            {
                                sw.WriteLine(string.Format("@attribute {0}_{1}_{2}_p{3} {4}", cp.AllSymbols[s + cp.SymbolStart],
                                    cp.AllPeriods[p + cp.PeriodStart], i.ToString(), pre.ToString(), "{0,100,200,-100,-200}"));
                            }
                sw.WriteLine("@attribute prop " + " {0,1,2,3}");
                sw.WriteLine("@data");
                sw.WriteLine();

                var hps = HpData.Instance.GetHpSum(cp.MainSymbol, cp.MainPeriod);
                var hpdv = hpdvs[0, 0];
                for (int i = minOutBegIdx + preLength - 1; i < hpdv.Length; ++i)
                {
                    DateTime nowDate = WekaUtils.GetDateFromTime((long)hpdv[i].Time);
                    //if (nowDate.Hour % TestParameters2.MainPeriodOfHour != 0)
                    //    continue;

                    if (!hps.ContainsKey(nowDate) && !(TestParameters2.RealTimeMode && i == hpdv.Length-1))
                        continue;

                    long hpTime = WekaUtils.GetTimeFromDate(Parameters.MaxDate);
                    int hp = 0;
                    if (!(TestParameters2.RealTimeMode && i == hpdv.Length - 1))
                    {
                        hpTime = hps[nowDate].Item2;
                        hp = hps[nowDate].Item1;
                    }

                    sw.Write(nowDate.ToString(Parameters.DateTimeFormat));
                    sw.Write(",");

                    // hp
                    sw.Write(WekaUtils.GetDateFromTime(hpTime).ToString(Parameters.DateTimeFormat));
                    sw.Write(",");

                    sw.Write((int)hpdv[i]["spread"]);
                    sw.Write(",");

                    sw.Write(((double)hpdv[i]["close"]).ToString());
                    sw.Write(",");

                    for (int pre = 0; pre < preLength; ++pre)
                        for (int s = 0; s < cp.SymbolCount; ++s)
                            for (int p = 0; p < cp.PeriodCount; ++p)
                                for (int j = 0; j < 61; ++j)
                                {
                                    int candlePattern = cds[s, p, i - minOutBegIdx - preLength + pre + 1, j];
                                    if (candlePattern == -1)
                                    {
                                        throw new AssertException(string.Format("candle pattern should not be -1.idx={0}", i - minOutBegIdx - preLength + pre + 1));
                                    }
                                    sw.Write(candlePattern);
                                    sw.Write(",");
                                }

                    sw.WriteLine(hp.ToString());
                }
            }
        }
    }
}
