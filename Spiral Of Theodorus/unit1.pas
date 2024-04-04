unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Spin, Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    cbFillcolor1: TColorButton;
    cbFillcolor2: TColorButton;
    cbPencolor: TColorButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    se_Linewidth: TSpinEdit;
    seScalefactor: TSpinEdit;
    seNumTriangles: TSpinEdit;
    procedure cbFillcolor1ColorChanged(Sender: TObject);
    procedure cbFillcolor2Click(Sender: TObject);
    procedure cbFillcolor2ColorChanged(Sender: TObject);
    procedure cbPencolorColorChanged(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure seNumTrianglesChange(Sender: TObject);
    procedure seScalefactorChange(Sender: TObject);
    procedure se_LinewidthChange(Sender: TObject);
  private
   procedure DrawSpiralOfTheodorus(DrawCanvas: TCanvas; prevx, prevy, n, scl: Integer);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.DrawSpiralOfTheodorus(DrawCanvas: TCanvas; prevx, prevy, n, scl: Integer);
var
  angle, t: Double;
  i: Integer;
  TrianglePoints: array[0..2] of TPoint;
  FillColor: TColor;
begin
  angle := 0;
  t := ArcTan(1/Sqrt(n));
  FillColor := cbFillcolor1.ButtonColor;

  for i := 0 to n - 1 do
  begin
    DrawCanvas.Brush.Color := FillColor;
    DrawCanvas.Pen.Color:= cbPencolor.ButtonColor;

    TrianglePoints[0] := Point(400, 300);
    TrianglePoints[1] := Point(prevx + 400, prevy + 300);
    TrianglePoints[2] := Point(Round(Cos(angle)*scl*Sqrt(i)) + 400, Round(Sin(angle)*scl*Sqrt(i)) + 300);


    DrawCanvas.Polygon(TrianglePoints);

    prevx := Round(Cos(angle)*scl*Sqrt(i));
    prevy := Round(Sin(angle)*scl*Sqrt(i));

    if FillColor = cbFillcolor2.ButtonColor then
      FillColor := cbFillcolor1.ButtonColor
    else
      FillColor := cbFillcolor2.ButtonColor;

    angle -= t;

    if n < 1000 then
      n += 1;
  end;
end;

procedure TForm1.cbFillcolor2Click(Sender: TObject);
begin
    Paintbox1.invalidate;
end;

procedure TForm1.cbFillcolor1ColorChanged(Sender: TObject);
begin
    Paintbox1.invalidate;
end;

procedure TForm1.cbFillcolor2ColorChanged(Sender: TObject);
begin
   Paintbox1.invalidate;
end;

procedure TForm1.cbPencolorColorChanged(Sender: TObject);
begin
     Paintbox1.invalidate;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
     DrawSpiralOfTheodorus(PaintBox1.Canvas, 0, 0, seNumTriangles.Value + 2, seScalefactor.Value);
end;

procedure TForm1.seNumTrianglesChange(Sender: TObject);
begin
   Paintbox1.invalidate;
end;

procedure TForm1.seScalefactorChange(Sender: TObject);
begin
  Paintbox1.invalidate;
end;

procedure TForm1.se_LinewidthChange(Sender: TObject);
begin
    Paintbox1.invalidate;
end;

end.

