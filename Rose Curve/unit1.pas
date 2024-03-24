unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnDraw: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    procedure btnDrawClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure DrawAxes(gr: Graphics; wxmax: Single);
var
  xmax: Integer;
  pen: Pen;
  tic: Single;
  x: Integer;
begin
  xmax := Trunc(wxmax);
  pen := Pen.Create(Color.Black, 0);
  try
    // Draw the X and Y axes.
    gr.DrawLine(pen, -wxmax, 0, wxmax, 0);
    gr.DrawLine(pen, 0, -wxmax, 0, wxmax);
    tic := 0.1;
    for x := -xmax to xmax do
    begin
      gr.DrawLine(pen, x, -tic, x, tic);
      gr.DrawLine(pen, -tic, x, tic, x);
    end;
  finally
    pen.Free;
  end;
end;

procedure DrawCurve(gr: Graphics; A: Single; n: Integer; d: Integer);
const
  num_points: Integer = 1000;
var
  period: Double;
  dtheta: Double;
  points: TList<PointF>;
  k: Double;
  i: Integer;
  theta: Double;
  r: Double;
  x: Single;
  y: Single;
  pen: TPen;
begin
  period := Math.PI * d;
  if (n mod 2 = 0) or (d mod 2 = 0) then
    period := period * 2;
  dtheta := period / num_points;
  points := TList<PointF>.Create;
  k := n / d;
  for i := 0 to num_points - 1 do
  begin
    theta := i * dtheta;
    r := A * Cos(k * theta);
    x := r * Cos(theta);
    y := r * Sin(theta);
    points.Add(PointF(x, y));
  end;
  gr.FillPolygon(Brushes.LightBlue, points.ToArray);
  pen := TPen.Create(Color.Red, 0);
  try
    gr.DrawLines(pen, points.ToArray);
  finally
    pen.Free;
  end;
  points.Free;
end;

procedure TForm1.btnDrawClick(Sender: TObject);
var
  A: Single;
  n, d: Integer;
  bmp: TBitmap;
  gr: TGraphic;
  rect: TRectF;
  pts: array[0..2] of TPointF;
begin
  A := StrToFloat(Edit1.Text);
  n := StrToInt(Edit2.Text);
  d := StrToInt(Edit3.Text);

  bmp := TBitmap.Create;
  try
    bmp.SetSize(300, 300);
    gr := bmp.Canvas;
    gr.Clear(clWhite);
    gr.SmoothingMode := SmoothingModeAntiAlias;

    rect := TRectF.Create(-A - 0.1, -A - 0.1, 2 * A + 0.2, 2 * A + 0.2);
    pts[0] := TPointF.Create(0, bmp.Height);
    pts[1] := TPointF.Create(bmp.Width, bmp.Height);
    pts[2] := TPointF.Create(0, 0);
    gr.Transform := TMatrix.Create(rect, pts);

    DrawCurve(gr, A, n, d);
    DrawAxes(gr, rect.Right);

    picCurve.Picture.Assign(bmp);
    picCurve.AutoSize := True;
    ClientWidth := picCurve.Right + picCurve.Top;
    ClientHeight := picCurve.Bottom + picCurve.Top;
  finally
    bmp.Free;
  end;
end;

end.

