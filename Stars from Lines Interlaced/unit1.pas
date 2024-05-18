unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Spin, Math, StdCtrls, Buttons;

type

  { TForm1 }

  TForm1 = class(TForm)
    cbLineColor: TColorButton;
    Label4: TLabel;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    seLineWidth: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    se_N: TSpinEdit;
    se_n1: TSpinEdit;
    procedure cbLineColorColorChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure seLineWidthChange(Sender: TObject);
    procedure se_n1Change(Sender: TObject);
    procedure se_NChange(Sender: TObject);
  private
    procedure DrawStars;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  se_N.Value := 26;
  se_n1.Value := 12;
  seLineWidth.Value := 3;
  cbLineColor.ButtonColor := clBlue;
  DrawStars;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  DrawStars;
end;

procedure TForm1.seLineWidthChange(Sender: TObject);
begin
  DrawStars;
end;

procedure TForm1.cbLineColorColorChanged(Sender: TObject);
begin
  DrawStars;
end;

procedure TForm1.se_n1Change(Sender: TObject);
begin
  DrawStars;
end;

procedure TForm1.se_NChange(Sender: TObject);
begin
  DrawStars;
end;

procedure TForm1.DrawStars;
const
  Colors: array[0..3] of TColor = (clYellow, clAqua, clRed, clBlue);
var
  a: Double;
  Center: TPoint;
  Radius, InnerRadius1, InnerRadius2: Integer;
  i: Integer;
  PointsOuter, PointsInner1, PointsInner2: array of TPoint;
begin
  PaintBox1.Canvas.Brush.Color := clWhite;
  PaintBox1.Canvas.FillRect(PaintBox1.ClientRect);

  a := -Pi / 2;
  Center := Point(PaintBox1.Width div 2, PaintBox1.Height div 2);
  Radius := Min(PaintBox1.Width, PaintBox1.Height) div 2 - 20;
  InnerRadius1 := Radius div 2;
  InnerRadius2 := InnerRadius1 div 2;

  SetLength(PointsOuter, se_N.Value + 1);
  SetLength(PointsInner1, se_N.Value + 1);
  SetLength(PointsInner2, se_N.Value + 1);

  for i := 0 to se_N.Value do
  begin
    PointsOuter[i] := Point(Round(Center.X + Radius * Cos(a)), Round(Center.Y + Radius * Sin(a)));
    PointsInner1[i] := Point(Round(Center.X + InnerRadius1 * Cos(a)), Round(Center.Y + InnerRadius1 * Sin(a)));
    PointsInner2[i] := Point(Round(Center.X + InnerRadius2 * Cos(a)), Round(Center.Y + InnerRadius2 * Sin(a)));
    a += se_n1.Value * 2 * Pi / se_N.Value;
  end;

  // Draw and fill middle polygons
  for i := 0 to se_N.Value - 1 do
  begin
    PaintBox1.Canvas.Brush.Color := Colors[1];
    PaintBox1.Canvas.Pen.Color := cbLineColor.ButtonColor;
    PaintBox1.Canvas.Pen.Width := seLineWidth.Value;
    PaintBox1.Canvas.Polygon([PointsInner2[i], PointsInner1[i], PointsInner1[(i + 1) mod se_N.Value], PointsInner2[(i + 1) mod se_N.Value]]);
  end;

  // Draw and fill outer polygons
  for i := 0 to se_N.Value - 1 do
  begin
    PaintBox1.Canvas.Brush.Color := Colors[2];
    PaintBox1.Canvas.Pen.Color := cbLineColor.ButtonColor;
    PaintBox1.Canvas.Pen.Width := seLineWidth.Value;
    PaintBox1.Canvas.Polygon([PointsInner1[i], PointsOuter[i], PointsOuter[(i + 1) mod se_N.Value], PointsInner1[(i + 1) mod se_N.Value]]);
  end;
end;

end.
