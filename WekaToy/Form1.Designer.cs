namespace WekaToy
{
    partial class Form1
    {
        /// <summary>
        /// 必需的设计器变量。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 清理所有正在使用的资源。
        /// </summary>
        /// <param name="disposing">如果应释放托管资源，为 true；否则为 false。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows 窗体设计器生成的代码

        /// <summary>
        /// 设计器支持所需的方法 - 不要
        /// 使用代码编辑器修改此方法的内容。
        /// </summary>
        private void InitializeComponent()
        {
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tabPage1 = new System.Windows.Forms.TabPage();
            this.ckbClassIsNominal = new System.Windows.Forms.CheckBox();
            this.btnTest = new System.Windows.Forms.Button();
            this.txtEval = new System.Windows.Forms.TextBox();
            this.label4 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.btnLoadStep = new System.Windows.Forms.Button();
            this.progressBar1 = new System.Windows.Forms.ProgressBar();
            this.txtWeka = new System.Windows.Forms.ComboBox();
            this.lblValue = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.btnSave = new System.Windows.Forms.Button();
            this.btnLoad = new System.Windows.Forms.Button();
            this.btnClear = new System.Windows.Forms.Button();
            this.btnRun = new System.Windows.Forms.Button();
            this.btnChange = new System.Windows.Forms.Button();
            this.tabPage2 = new System.Windows.Forms.TabPage();
            this.txtLog = new System.Windows.Forms.TextBox();
            this.backgroundWorker1 = new System.ComponentModel.BackgroundWorker();
            this.tabControl1.SuspendLayout();
            this.tabPage1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.tabPage2.SuspendLayout();
            this.SuspendLayout();
            // 
            // tabControl1
            // 
            this.tabControl1.Controls.Add(this.tabPage1);
            this.tabControl1.Controls.Add(this.tabPage2);
            this.tabControl1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabControl1.Location = new System.Drawing.Point(0, 0);
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(952, 561);
            this.tabControl1.TabIndex = 0;
            // 
            // tabPage1
            // 
            this.tabPage1.Controls.Add(this.ckbClassIsNominal);
            this.tabPage1.Controls.Add(this.btnTest);
            this.tabPage1.Controls.Add(this.txtEval);
            this.tabPage1.Controls.Add(this.label4);
            this.tabPage1.Controls.Add(this.label3);
            this.tabPage1.Controls.Add(this.label2);
            this.tabPage1.Controls.Add(this.btnLoadStep);
            this.tabPage1.Controls.Add(this.progressBar1);
            this.tabPage1.Controls.Add(this.txtWeka);
            this.tabPage1.Controls.Add(this.lblValue);
            this.tabPage1.Controls.Add(this.label1);
            this.tabPage1.Controls.Add(this.pictureBox1);
            this.tabPage1.Controls.Add(this.btnSave);
            this.tabPage1.Controls.Add(this.btnLoad);
            this.tabPage1.Controls.Add(this.btnClear);
            this.tabPage1.Controls.Add(this.btnRun);
            this.tabPage1.Controls.Add(this.btnChange);
            this.tabPage1.Location = new System.Drawing.Point(4, 22);
            this.tabPage1.Name = "tabPage1";
            this.tabPage1.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage1.Size = new System.Drawing.Size(944, 535);
            this.tabPage1.TabIndex = 0;
            this.tabPage1.Text = "Main";
            this.tabPage1.UseVisualStyleBackColor = true;
            // 
            // ckbClassIsNominal
            // 
            this.ckbClassIsNominal.AutoSize = true;
            this.ckbClassIsNominal.Checked = true;
            this.ckbClassIsNominal.CheckState = System.Windows.Forms.CheckState.Checked;
            this.ckbClassIsNominal.Location = new System.Drawing.Point(528, 175);
            this.ckbClassIsNominal.Name = "ckbClassIsNominal";
            this.ckbClassIsNominal.Size = new System.Drawing.Size(126, 16);
            this.ckbClassIsNominal.TabIndex = 28;
            this.ckbClassIsNominal.Text = "Class is Norminal";
            this.ckbClassIsNominal.UseVisualStyleBackColor = true;
            // 
            // btnTest
            // 
            this.btnTest.Location = new System.Drawing.Point(609, 55);
            this.btnTest.Name = "btnTest";
            this.btnTest.Size = new System.Drawing.Size(75, 23);
            this.btnTest.TabIndex = 27;
            this.btnTest.Text = "Test";
            this.btnTest.UseVisualStyleBackColor = true;
            this.btnTest.Click += new System.EventHandler(this.btnTest_Click);
            // 
            // txtEval
            // 
            this.txtEval.Location = new System.Drawing.Point(528, 218);
            this.txtEval.Multiline = true;
            this.txtEval.Name = "txtEval";
            this.txtEval.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.txtEval.Size = new System.Drawing.Size(408, 256);
            this.txtEval.TabIndex = 26;
            this.txtEval.WordWrap = false;
            // 
            // label4
            // 
            this.label4.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(200)))), ((int)(((byte)(0)))), ((int)(((byte)(200)))));
            this.label4.Location = new System.Drawing.Point(730, 28);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(27, 23);
            this.label4.TabIndex = 25;
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(200)))), ((int)(((byte)(200)))), ((int)(((byte)(0)))));
            this.label3.Location = new System.Drawing.Point(697, 28);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(27, 23);
            this.label3.TabIndex = 24;
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(200)))), ((int)(((byte)(200)))));
            this.label2.Location = new System.Drawing.Point(664, 28);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(27, 23);
            this.label2.TabIndex = 23;
            // 
            // btnLoadStep
            // 
            this.btnLoadStep.Location = new System.Drawing.Point(609, 115);
            this.btnLoadStep.Name = "btnLoadStep";
            this.btnLoadStep.Size = new System.Drawing.Size(75, 23);
            this.btnLoadStep.TabIndex = 22;
            this.btnLoadStep.Text = "LoadStep";
            this.btnLoadStep.UseVisualStyleBackColor = true;
            this.btnLoadStep.Click += new System.EventHandler(this.btnLoadStep_Click);
            // 
            // progressBar1
            // 
            this.progressBar1.Location = new System.Drawing.Point(690, 55);
            this.progressBar1.MarqueeAnimationSpeed = 0;
            this.progressBar1.Name = "progressBar1";
            this.progressBar1.Size = new System.Drawing.Size(96, 23);
            this.progressBar1.Style = System.Windows.Forms.ProgressBarStyle.Marquee;
            this.progressBar1.TabIndex = 21;
            // 
            // txtWeka
            // 
            this.txtWeka.FormattingEnabled = true;
            this.txtWeka.Location = new System.Drawing.Point(4, 3);
            this.txtWeka.Name = "txtWeka";
            this.txtWeka.Size = new System.Drawing.Size(500, 20);
            this.txtWeka.TabIndex = 20;
            // 
            // lblValue
            // 
            this.lblValue.AutoSize = true;
            this.lblValue.Location = new System.Drawing.Point(647, 28);
            this.lblValue.Name = "lblValue";
            this.lblValue.Size = new System.Drawing.Size(17, 12);
            this.lblValue.TabIndex = 19;
            this.lblValue.Text = "0";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(624, 28);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(17, 12);
            this.label1.TabIndex = 18;
            this.label1.Text = "V:";
            // 
            // pictureBox1
            // 
            this.pictureBox1.BackColor = System.Drawing.Color.Black;
            this.pictureBox1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.pictureBox1.Location = new System.Drawing.Point(4, 28);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(500, 500);
            this.pictureBox1.TabIndex = 17;
            this.pictureBox1.TabStop = false;
            // 
            // btnSave
            // 
            this.btnSave.Location = new System.Drawing.Point(528, 145);
            this.btnSave.Name = "btnSave";
            this.btnSave.Size = new System.Drawing.Size(75, 23);
            this.btnSave.TabIndex = 16;
            this.btnSave.Text = "Save";
            this.btnSave.UseVisualStyleBackColor = true;
            // 
            // btnLoad
            // 
            this.btnLoad.Location = new System.Drawing.Point(528, 115);
            this.btnLoad.Name = "btnLoad";
            this.btnLoad.Size = new System.Drawing.Size(75, 23);
            this.btnLoad.TabIndex = 15;
            this.btnLoad.Text = "Load";
            this.btnLoad.UseVisualStyleBackColor = true;
            // 
            // btnClear
            // 
            this.btnClear.Location = new System.Drawing.Point(528, 85);
            this.btnClear.Name = "btnClear";
            this.btnClear.Size = new System.Drawing.Size(75, 23);
            this.btnClear.TabIndex = 14;
            this.btnClear.Text = "Clear";
            this.btnClear.UseVisualStyleBackColor = true;
            // 
            // btnRun
            // 
            this.btnRun.Location = new System.Drawing.Point(528, 55);
            this.btnRun.Name = "btnRun";
            this.btnRun.Size = new System.Drawing.Size(75, 23);
            this.btnRun.TabIndex = 13;
            this.btnRun.Text = "Run";
            this.btnRun.UseVisualStyleBackColor = true;
            // 
            // btnChange
            // 
            this.btnChange.Location = new System.Drawing.Point(528, 25);
            this.btnChange.Name = "btnChange";
            this.btnChange.Size = new System.Drawing.Size(75, 23);
            this.btnChange.TabIndex = 12;
            this.btnChange.Text = "Change";
            this.btnChange.UseVisualStyleBackColor = true;
            // 
            // tabPage2
            // 
            this.tabPage2.Controls.Add(this.txtLog);
            this.tabPage2.Location = new System.Drawing.Point(4, 22);
            this.tabPage2.Name = "tabPage2";
            this.tabPage2.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage2.Size = new System.Drawing.Size(944, 535);
            this.tabPage2.TabIndex = 1;
            this.tabPage2.Text = "Log";
            this.tabPage2.UseVisualStyleBackColor = true;
            // 
            // txtLog
            // 
            this.txtLog.Dock = System.Windows.Forms.DockStyle.Fill;
            this.txtLog.Location = new System.Drawing.Point(3, 3);
            this.txtLog.Multiline = true;
            this.txtLog.Name = "txtLog";
            this.txtLog.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.txtLog.Size = new System.Drawing.Size(938, 529);
            this.txtLog.TabIndex = 0;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(952, 561);
            this.Controls.Add(this.tabControl1);
            this.MaximizeBox = false;
            this.Name = "Form1";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Form1";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.tabControl1.ResumeLayout(false);
            this.tabPage1.ResumeLayout(false);
            this.tabPage1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.tabPage2.ResumeLayout(false);
            this.tabPage2.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TabControl tabControl1;
        private System.Windows.Forms.TabPage tabPage1;
        private System.Windows.Forms.ProgressBar progressBar1;
        private System.Windows.Forms.ComboBox txtWeka;
        private System.Windows.Forms.Label lblValue;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.Button btnSave;
        private System.Windows.Forms.Button btnLoad;
        private System.Windows.Forms.Button btnClear;
        private System.Windows.Forms.Button btnRun;
        private System.Windows.Forms.Button btnChange;
        private System.Windows.Forms.TabPage tabPage2;
        private System.Windows.Forms.TextBox txtLog;
        private System.ComponentModel.BackgroundWorker backgroundWorker1;
        private System.Windows.Forms.Button btnLoadStep;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.TextBox txtEval;
        private System.Windows.Forms.Button btnTest;
        private System.Windows.Forms.CheckBox ckbClassIsNominal;

    }
}

