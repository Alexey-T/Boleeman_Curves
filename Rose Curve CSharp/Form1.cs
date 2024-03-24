using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using System.Drawing.Drawing2D;

namespace howto_rose_curves
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void btnDraw_Click(object sender, EventArgs e)
        {
            float A = float.Parse(txtA.Text);
            int n = int.Parse(txtN.Text);
            int d = int.Parse(txtD.Text);

            // Make the Bitmap and associated Graphics object.
            Bitmap bm = new Bitmap(300, 300);
            using (Graphics gr = Graphics.FromImage(bm))
            {
                gr.Clear(Color.White);
                gr.SmoothingMode = SmoothingMode.AntiAlias;

                // Set up a transformation to map the region
                // x/y = A +/- 0.1 onto the Bitmap.
                RectangleF rect = new RectangleF(
                    -A - 0.1f, -A - 0.1f, 2 * A + 0.2f, 2 * A + 0.2f);
                PointF[] pts =
                {
                    new PointF(0, bm.Height),
                    new PointF(bm.Width, bm.Height),
                    new PointF(0, 0),
                };
                gr.Transform = new Matrix(rect, pts);

                // Draw the curve.
                DrawCurve(gr, A, n, d);

                // Draw the axes.
                DrawAxes(gr, rect.Right);

                // Display the result and size the form to fit.
                picCurve.Image = bm;
                picCurve.SizeMode = PictureBoxSizeMode.AutoSize;
                this.ClientSize = new Size(
                    picCurve.Right + picCurve.Top,
                    picCurve.Bottom + picCurve.Top);
            }
        }

        private void DrawAxes(Graphics gr, float wxmax)
        {
            int xmax = (int)wxmax;
            using (Pen pen = new Pen(Color.Black, 0))
            {
                // Draw the X and Y axes.
                gr.DrawLine(pen, -wxmax, 0, wxmax, 0);
                gr.DrawLine(pen, 0, -wxmax, 0, wxmax);

                float tic = 0.1f;
                for (int x = -xmax; x <= xmax; x++)
                {
                    gr.DrawLine(pen, x, -tic, x, tic);
                    gr.DrawLine(pen, -tic, x, tic, x);
                }
            }
        }

        // Draw the curve.
        // n and d should be relatively prime.
        private void DrawCurve(Graphics gr, float A, int n, int d)
        {
            const int num_points = 1000;

            // Period is Pi * d if n and d are both odd. 2 * Pi * d otherwise.
            double period = Math.PI * d;
            if ((n % 2 == 0) || (d % 2 == 0)) period *= 2;

            double dtheta = period / num_points;
            List<PointF> points = new List<PointF>();
            double k = (double)n / d;
            for (int i = 0; i < num_points; i++)
            {
                double theta = i * dtheta;
                double r = A * Math.Cos(k * theta);
                float x = (float)(r * Math.Cos(theta));
                float y = (float)(r * Math.Sin(theta));

                points.Add(new PointF(x, y));
            }

            gr.FillPolygon(Brushes.LightBlue, points.ToArray());

            // Draw the curve.
            using (Pen pen = new Pen(Color.Red, 0))
            {
                gr.DrawLines(pen, points.ToArray());
            }
        }
    }
}
