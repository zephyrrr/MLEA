namespace WindowsClient
{
    partial class MainForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.dgvQuotations = new System.Windows.Forms.DataGridView();
            ((System.ComponentModel.ISupportInitialize)(this.dgvQuotations)).BeginInit();
            this.SuspendLayout();
            // 
            // dgvQuotations
            // 
            this.dgvQuotations.AllowUserToAddRows = false;
            this.dgvQuotations.AllowUserToDeleteRows = false;
            this.dgvQuotations.AllowUserToOrderColumns = true;
            this.dgvQuotations.AllowUserToResizeRows = false;
            this.dgvQuotations.BackgroundColor = System.Drawing.Color.WhiteSmoke;
            this.dgvQuotations.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvQuotations.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvQuotations.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvQuotations.Location = new System.Drawing.Point(0, 0);
            this.dgvQuotations.Margin = new System.Windows.Forms.Padding(10);
            this.dgvQuotations.MultiSelect = false;
            this.dgvQuotations.Name = "dgvQuotations";
            this.dgvQuotations.ReadOnly = true;
            this.dgvQuotations.RowHeadersVisible = false;
            this.dgvQuotations.RowTemplate.DefaultCellStyle.SelectionBackColor = System.Drawing.Color.Gray;
            this.dgvQuotations.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvQuotations.Size = new System.Drawing.Size(517, 288);
            this.dgvQuotations.TabIndex = 0;
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(517, 288);
            this.Controls.Add(this.dgvQuotations);
            this.Name = "MainForm";
            this.Text = "Quotes table - connecting....";
            this.Load += new System.EventHandler(this.MainForm_Load);
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.MainForm_FormClosing);
            ((System.ComponentModel.ISupportInitialize)(this.dgvQuotations)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.DataGridView dgvQuotations;
    }
}

