using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WekaToy
{
    public partial class Form1 : Form
    {
        public struct valuePoint
        {
            public valuePoint(double x, double y, int value)
            {
                this.x = x;
                this.y = y;
                this.value = value;
            }
            public double x, y;
            public int value;
        };

        private const int Multi = 5;
        private const int XLEN = WXLEN / Multi;
        private const int YLEN = WYLEN / Multi;
        private const int WXLEN = 500;
        private const int WYLEN = 500;
        private const int MAXCLASSNUM = 2;
        public Form1()
        {
            InitializeComponent();

            this.pictureBox1.Size = new Size(WXLEN, WYLEN);

            this.txtWeka.Items.AddRange(new object[] {
                "MLEA.SvmLightClassifier,MLEA -c 20 -l 4 -w 1 --p 1 --b 1",
                "MLEA.MincostClassifier,MLEA -D 0.5 -W weka.classifiers.functions.LibLINEAR -- -S 0 -P -C 1 -B 1",
                "MLEA.MincostClassifier,MLEA -W weka.classifiers.functions.LibSVM -- -S 0 -K 2 -G 2 -C 1000 -B",
                "weka.classifiers.functions.LibLINEAR -S 1 -C 1.0 -E 0.01 -B 1.0",
                "weka.classifiers.functions.LibSVM -S 0 -K 2 -G 1 -C 1000 -B",
                "weka.classifiers.meta.AdaBoostM1 -P 100 -S 1 -I 10 -W weka.classifiers.functions.LibSVM -- -S 0 -K 2 -G 2 -C 1000 -B"});
            txtWeka.SelectedIndex = 0;
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            pictureBox1.MouseClick += new MouseEventHandler(pictureBox1_MouseClick);

            backgroundWorker1.DoWork += new DoWorkEventHandler(backgroundWorker1_DoWork);
            backgroundWorker1.RunWorkerCompleted += new RunWorkerCompletedEventHandler(backgroundWorker1_RunWorkerCompleted);

            this.btnSave.Click += new System.EventHandler(this.btnSave_Click);
            this.btnClear.Click += new System.EventHandler(this.btnClear_Click);
            this.btnLoad.Click += new System.EventHandler(this.btnLoad_Click);
            this.btnRun.Click += new System.EventHandler(this.btnRun_Click);
            this.btnChange.Click += new System.EventHandler(this.btnChange_Click);

            this.pictureBox1.Paint += new PaintEventHandler(pictureBox1_Paint);
        }

        private int current_value = 0;
        private void pictureBox1_MouseClick(object sender, MouseEventArgs e)
        {
            valuePoint p = new valuePoint((double)e.X / WXLEN, (double)e.Y / WYLEN, current_value);
            point_list.Add(p);
            draw_point(p);
            pictureBox1.Invalidate();
        }

        private void btnChange_Click(object sender, EventArgs e)
        {
            ++current_value;
            if (current_value >= MAXCLASSNUM)
                current_value = 0;
            //current_value = -current_value;
            lblValue.Text = current_value.ToString();
        }

        private void btnRun_Click(object sender, EventArgs e)
        {
            m_cls = null;
            backgroundWorker1.RunWorkerAsync(txtWeka.Text);
            progressBar1.MarqueeAnimationSpeed = 100;
            btnRun.Enabled = false;
        }
        private void btnTest_Click(object sender, EventArgs e)
        {
            backgroundWorker1.RunWorkerAsync();
            progressBar1.MarqueeAnimationSpeed = 100;
            btnTest.Enabled = false;
        }

        void backgroundWorker1_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            pictureBox1.Invalidate();
            btnRun.Enabled = true;
            btnTest.Enabled = true;
            progressBar1.MarqueeAnimationSpeed = 0;
        }

        private void pictureBox1_Paint(object sender, PaintEventArgs e)
        {
            //draw_all_points();
            e.Graphics.DrawImage(m_pictureBoxBitmap, new Point(0, 0));
        }

        private void backgroundWorker1_DoWork(object sender, DoWorkEventArgs e)
        {
            string s = (string)e.Argument;
            if (!string.IsNullOrEmpty(s))
            {
                Train((string)e.Argument);
            }
            else
            {
                Test();
            }
        }
        private void btnClear_Click(object sender, EventArgs e)
        {
            clear_all();
            current_value = 0;
            lblValue.Text = current_value.ToString();
            txtLog.Clear();
        }

        private void btnLoad_Click(object sender, EventArgs e)
        {
            using (OpenFileDialog d = new OpenFileDialog())
            {
                d.Filter = "Arff File|*.arff";
                if (d.ShowDialog() == System.Windows.Forms.DialogResult.OK)
                {
                    var fileReader = new java.io.FileReader(d.FileName);
                    var instances = new weka.core.Instances(new java.io.BufferedReader(fileReader));
                    instances.setClassIndex(instances.numAttributes() - 1);
                    fileReader.close();

                    clear_all();
                    foreach (weka.core.Instance i in instances)
                    {
                        var p = new valuePoint(i.value(0), i.value(1), (int)i.classValue());
                        if (p.x < 0 || p.x >= 1 || p.y < 0 || p.y >= 1)
                            continue;
                        point_list.Add(p);
                    }
                    draw_all_points();
                    this.pictureBox1.Invalidate();
                }
            }
        }

        private weka.core.Instances m_loadStepInstances;
        private int m_loadStepIdx = 0;
        private void btnLoadStep_Click(object sender, EventArgs e)
        {
            if (m_loadStepInstances == null)
            {
                using (OpenFileDialog d = new OpenFileDialog())
                {
                    d.Filter = "Arff File|*.arff";
                    if (d.ShowDialog() == System.Windows.Forms.DialogResult.OK)
                    {
                        m_loadStepInstances = new weka.core.Instances(new java.io.BufferedReader(new java.io.FileReader(d.FileName)));
                        m_loadStepInstances.setClassIndex(m_loadStepInstances.numAttributes() - 1);

                        clear_all();
                    }
                }
            }
            else
            {
                for (int i = m_loadStepIdx; i < m_loadStepInstances.numInstances(); ++i)
                {
                    var ins = m_loadStepInstances.instance(i);
                    var p = new valuePoint(ins.value(0), ins.value(1), (int)ins.classValue());
                    if (p.x < 0 || p.x >= 1 || p.y < 0 || p.y >= 1)
                        continue;

                    point_list.Add(p);

                    draw_point(p);

                    m_loadStepIdx = i + 1;
                    if (i % 1000 == 0)
                    {
                        break;
                    }
                }

                pictureBox1.Invalidate();
                if (m_loadStepIdx == m_loadStepInstances.numInstances())
                {
                    m_loadStepIdx = 0;
                    m_loadStepInstances = null;
                }
            }
        }

        private weka.core.converters.ArffSaver m_arffSaver = new weka.core.converters.ArffSaver();
        private void btnSave_Click(object sender, EventArgs e)
        {
            using (SaveFileDialog d = new SaveFileDialog())
            {
                d.Filter = "Arff File|*.arff";
                if (d.ShowDialog() == System.Windows.Forms.DialogResult.OK)
                {
                    if (System.IO.File.Exists(d.FileName))
                    {
                        System.IO.File.Delete(d.FileName);
                    }
                    var instances = CreateCurrentInstances();
                    m_arffSaver.setInstances(instances);
                    m_arffSaver.setFile(new java.io.File(d.FileName));
                    m_arffSaver.writeBatch();
                }
            }
        }

        private List<valuePoint> point_list = new List<valuePoint>();

        private void clear_all()
        {
            draw_all_points(true);
            point_list.Clear();
            if (m_pictureBoxBitmap != null)
            {
                m_pictureBoxBitmap.Dispose();
                m_pictureBoxBitmap = new Bitmap(WXLEN, WYLEN);
            }
            pictureBox1.Invalidate();
        }

        private static Color[] colors =
                {
	                //Color.FromArgb(0,0,0),
	                Color.FromArgb(0,120,120),
	                Color.FromArgb(120,120,0),
	                Color.FromArgb(120,0,120),
	                Color.FromArgb(0,200,200),
	                Color.FromArgb(200,200,0),
	                Color.FromArgb(200,0,200)
                };

        //private Brush brush1 = new SolidBrush(colors[3]);
        //private Brush brush2 = new SolidBrush(colors[4]);
        //private Brush brush3 = new SolidBrush(colors[5]);
        //private Brush choose_brush(int v)
        //{
        //    if (v == 1) return brush1;
        //    else if (v == 2) return brush2;
        //    else return brush3;
        //}

        private Color GetValueColor(int value, bool asPoint)
        {
            if (value == -1 || value == 0)
                return asPoint ? colors[3] : colors[0];
            else if (value == 1)
                return asPoint ? colors[4] : colors[1];
            else
                return Color.Red;
        }
        private void draw_point(valuePoint p, Color? c = null)
        {
            //Graphics g = pictureBox1.CreateGraphics();
            //Rectangle rect = new System.Drawing.Rectangle((int)(p.x * WXLEN), (int)(p.y * WYLEN), WXLEN / XLEN, WYLEN / YLEN);
            //g.FillRectangle(choose_brush(p.value), rect);

            for (int ii = 0; ii < WXLEN / XLEN; ++ii)
                for (int jj = 0; jj < WYLEN / YLEN; ++jj)
                    m_pictureBoxBitmap.SetPixel((int)(p.x * WXLEN) + ii, (int)(p.y * WYLEN + jj), c.HasValue ? c.Value : GetValueColor(p.value, true));
         }

        private void draw_all_points(bool remove = false)
        {
            foreach (var p in point_list)
            {
                if (remove)
                {
                    draw_point(p, Color.Black);
                }
                else
                {
                    draw_point(p);
                }
            }
            //pictureBox1.Invalidate();
        }

        private weka.classifiers.Classifier m_cls;
        private void Train(string str)
        {
            if (string.IsNullOrEmpty(str))
                return;
            m_cls = CreateClassifier(str);
            if (m_cls == null)
            {
                MessageBox.Show("Can't Create Classifier!");
                return;
            }

            var trainInstances = CreateCurrentInstances();
            m_cls.buildClassifier(trainInstances);

            // TEST
            var data = CreateEmptyInstances();
            StringBuilder sb = new StringBuilder();

            if (m_cls is MLEA.IBatchClassifier)
            {
                MLEA.IBatchClassifier batchClassifier = m_cls as MLEA.IBatchClassifier;
                for (int i = 0; i < XLEN; i++)
                {
                    for (int j = 0; j < YLEN; j++)
                    {
                        var vals = new double[data.numAttributes()];
                        vals[0] = (double)i / XLEN;
                        vals[1] = (double)j / YLEN;

                        var instance = new weka.core.DenseInstance(1.0, vals);
                        data.add(instance);
                        instance.setDataset(data);
                    }
                }

                double[] ds = batchClassifier.classifyInstances(data);
                for (int i = 0; i < XLEN; i++)
                {
                    for (int j = 0; j < YLEN; j++)
                    {
                        double d = ds[i * XLEN + j];

                        if (m_enableLog)
                        {
                            string s = string.Format("{0}, {1}: {2}", data.instance(i * XLEN + j).value(0).ToString("N2"), data.instance(i * XLEN + j).value(1).ToString("N2"), d.ToString("N0"));
                            sb.AppendLine(s);
                        }

                        for (int ii = 0; ii < WXLEN / XLEN; ++ii)
                            for (int jj = 0; jj < WYLEN / YLEN; ++jj)
                                m_pictureBoxBitmap.SetPixel(i * WXLEN / XLEN + ii, j * WYLEN / YLEN + jj, GetValueColor((int)d, false));
                    }
                }
            }
            else
            {
                for (int i = 0; i < XLEN; i++)
                {
                    for (int j = 0; j < YLEN; j++)
                    {
                        var vals = new double[data.numAttributes()];
                        vals[0] = (double)i / XLEN;
                        vals[1] = (double)j / YLEN;

                        var instance = new weka.core.DenseInstance(1.0, vals);
                        data.add(instance);
                        instance.setDataset(data);

                        double d = m_cls.classifyInstance(instance);

                        if (m_enableLog)
                        {
                            string s = string.Format("{0}, {1}: {2}", vals[0].ToString("N2"), vals[1].ToString("N2"), d.ToString("N0"));
                            sb.AppendLine(s);
                        }

                        for (int ii = 0; ii < WXLEN / XLEN; ++ii)
                            for (int jj = 0; jj < WYLEN / YLEN; ++jj)
                                m_pictureBoxBitmap.SetPixel(i * WXLEN / XLEN + ii, j * WYLEN / YLEN + jj, GetValueColor((int)d, false));
                    }
                }
            }
            draw_all_points();

            this.Invoke(new Action(() =>
                {
                    if (m_enableLog)
                    {
                        txtLog.AppendText(sb.ToString());
                    }
                }));

            if (m_enableEvaluation)
            {
                Test(trainInstances);
            }
        }
        private bool m_enableEvaluation = true;

        public void Test(weka.core.Instances testInstances = null)
        {
            if (testInstances == null)
            {
                testInstances = CreateCurrentInstances();
            }

            //if (m_cls is MLEA.IBatchClassifier)
            //{
            //    StringBuilder sb = new StringBuilder();
            //    MLEA.IBatchClassifier batchClassifier = m_cls as MLEA.IBatchClassifier;
            //    double[] d = batchClassifier.classifyInstances(testInstances);
            //    for (int i = 0; i < d.Length; ++i)
            //    {
            //        string s = string.Format("{0}, {1}: {2}", testInstances.instance(i).value(0).ToString("N2"), testInstances.instance(i).value(1).ToString("N2"), d[i].ToString("N0"));
            //        sb.AppendLine(s);
            //    }

            //    this.Invoke(new Action(() =>
            //    {
            //        txtEval.Text = sb.ToString();
            //    }));
            //}
            //else
            {
                MLEA.MyEvaluation eval = null;
                if (testInstances.classAttribute().isNominal())
                {
                    var costMatrix = MLEA.TestParameters.CostMatrix;
                    eval = new MLEA.MyEvaluation(costMatrix);

                    eval.evaluateModel(m_cls, testInstances);

                    this.Invoke(new Action(() =>
                    {
                        txtEval.Text = string.Format("TP:{0}, FP:{1}, Cost:{2}", eval.numTruePositives(1), eval.numFalsePositives(1), eval.totalCost().ToString());
                    }));
                }
                else
                {
                    //eval = new MLEA.MyEvaluation(costMatrix);

                    //eval.evaluateModel(m_cls, testInstances);

                    //this.Invoke(new Action(() =>
                    //{
                    //    txtEval.Text = eval.toSummaryString().Replace("\n", System.Environment.NewLine)
                    //        + System.Environment.NewLine;
                    //}));
                }
            }
        }

        private Bitmap m_pictureBoxBitmap = new Bitmap(WXLEN, WYLEN);
        private bool m_enableLog = false;

        private weka.classifiers.Classifier CreateClassifier(string str)
        {
            try
            {
                int idx = str.IndexOf(' ');
                string className = idx != -1 ? str.Substring(0, idx) : str;
                if (!className.Contains(","))
                {
                    className += ",weka";
                }
                string option = str.Substring(idx + 1);
                weka.classifiers.AbstractClassifier cls = Feng.Utils.ReflectionHelper.CreateInstanceFromName(className) as weka.classifiers.AbstractClassifier;
                cls.setOptions(weka.core.Utils.splitOptions(option));
                return cls;
            }
            catch (Exception)
            {
                return null;
            }
        }

        private weka.core.Instances CreateEmptyInstances()
        {
            var atts = new java.util.ArrayList();
            atts.add(new weka.core.Attribute("x"));
            atts.add(new weka.core.Attribute("y"));

            if (!ckbClassIsNominal.Checked)
            {
                atts.add(new weka.core.Attribute("v"));
            }
            else
            {
                // - nominal
                var attVals = new java.util.ArrayList();
                //for(int i=0; i<MAXCLASSNUM; ++i)
                //    attVals.add(i.ToString());
                attVals.add("0");
                attVals.add("1");
                atts.add(new weka.core.Attribute("v", attVals));
            }

            weka.core.Instances data = new weka.core.Instances("MyRelation", atts, 0);
            data.setClassIndex(data.numAttributes() - 1);

            return data;
        }
        private weka.core.Instances CreateCurrentInstances()
        {
            var data = CreateEmptyInstances();

            foreach (var i in point_list)
            {
                var vals = new double[data.numAttributes()];
                vals[0] = i.x;
                vals[1] = i.y;
                vals[2] = !ckbClassIsNominal.Checked ? i.value : data.classAttribute().indexOfValue(i.value.ToString());
                data.add(new weka.core.DenseInstance(1.0, vals));
            }

            return data;
        }

        

        
    }
}
