unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Spin,
  ColorBox, StdCtrls, Math, BGRABitmap, BGRABitmapTypes, BGRAGraphicControl;

type

  { TForm1 }

  TForm1 = class(TForm)
    BGRAGraphicControl1: TBGRAGraphicControl;
    chkBorder: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    seScaleFactor: TSpinEdit;
    seMaxIter: TSpinEdit;
    cbBackColor: TColorButton;
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure seScaleFactorChange(Sender: TObject);
    procedure seMaxIterChange(Sender: TObject);
    procedure cbBackColorColorChanged(Sender: TObject);
    procedure chkBorderChange(Sender: TObject);
  private
    procedure DrawApollonianGasket(Bmp: TBGRABitmap);
    function DescartesTheorem(k1, k2, k3: Double): Double;
    function LargestCircleRadius(k1, k2, k3: Double): Double;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  PaintBox1.Align := alClient;
  seScaleFactor.Value := 100;
  seMaxIter.Value := 5000000;
  cbBackColor.ButtonColor := $009DFFFF;

  seScaleFactor.OnChange := @seScaleFactorChange;
  seMaxIter.OnChange := @seMaxIterChange;
  cbBackColor.OnColorChanged := @cbBackColorColorChanged;
  chkBorder.OnChange := @chkBorderChange;
end;

procedure TForm1.seScaleFactorChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.seMaxIterChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.cbBackColorColorChanged(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.chkBorderChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  Bmp: TBGRABitmap;
begin
  Bmp := TBGRABitmap.Create(PaintBox1.Width, PaintBox1.Height, cbBackColor.ButtonColor);
  try
    DrawApollonianGasket(Bmp);
    Bmp.Draw(PaintBox1.Canvas, 0, 0);
  finally
    Bmp.Free;
  end;
end;

function TForm1.DescartesTheorem(k1, k2, k3: Double): Double;
begin
  Result := 2 * Sqrt(k1 * k2 + k2 * k3 + k3 * k1);
end;

function TForm1.LargestCircleRadius(k1, k2, k3: Double): Double;
begin
  Result := 1 / (k1 + k2 + k3 - 2 * Sqrt(k1 * k2 + k2 * k3 + k3 * k1));
end;

procedure TForm1.DrawApollonianGasket(Bmp: TBGRABitmap);
const
  r = sqrt(3);
var
  x, y, a, b, s1, s2: Double;
  n, maxIterations: Integer;
  a0, b0, a1, b1, a2, b2, f1x, f1y, x1, y1: Double;
  canvasWidth, canvasHeight: Integer;
  px, py: Integer;
  Acolor: TBGRAPixel;
  borderRadius: Double;
  k1, k2, k3: Double;
begin
  x := 0.2;
  y := 0.3;
  s1 := seScaleFactor.Value;
  maxIterations := seMaxIter.Value;
  canvasWidth := Bmp.Width;
  canvasHeight := Bmp.Height;
  s2 := s1 * canvasHeight / canvasWidth;
  Randomize;

  k1 := 1 / (2 * r);
  k2 := 1 / 2;
  k3 := 1 / (2 * r);

  for n := 1 to maxIterations do
  begin
    a := Random;

    // Circle inversion around first point
    a0 := 3 * (1 + r - x) / (Sqr(1 + r - x) + Sqr(y)) - (1 + r) / (2 + r);
    b0 := 3 * y / (Sqr(1 + r - x) + Sqr(y));

    if (a <= 1 / 3) and (a >= 0) then
    begin
      x1 := 3 * (1 + r - x) / (Sqr(1 + r - x) + Sqr(y)) - (1 + r) / (2 + r);
      y1 := 3 * y / (Sqr(1 + r - x) + Sqr(y));
      Acolor := BGRA(255, 0, 0, 32); // Red color with alpha for blending
    end;

    // Z^3-1=0 centers for second and third point
    a1 := -1 / 2;
    b1 := r / 2;
    a2 := -1 / 2;
    b2 := -r / 2;

    f1x := a0 / (Sqr(a0) + Sqr(b0));
    f1y := -b0 / (Sqr(a0) + Sqr(b0));

    if (a <= 2 / 3) and (a > 1 / 3) then
    begin
      x1 := f1x * a1 - f1y * b1;
      y1 := f1x * b1 + f1y * a1;
      Acolor := BGRA(0, 0, 0, 32); // Black color with alpha for blending
    end;

    if (a <= 1) and (a > 2 / 3) then
    begin
      x1 := f1x * a2 - f1y * b2;
      y1 := f1x * b2 + f1y * a2;
      Acolor := BGRA(0, 0, 255, 32); // Blue color with alpha for blending
    end;

    x := x1;
    y := y1;

    if n > 10 then
    begin
      px := Round(canvasWidth / 2 + s1 * x);
      py := Round(canvasHeight / 2 + s2 * y);

      if (px >= 0) and (px < canvasWidth) and (py >= 0) and (py < canvasHeight) then
      begin
        Bmp.FastBlendPixel(px, py, Acolor);
      end;
    end;
  end;

  if chkBorder.Checked then
  begin
    // Calculate the radius of the border to encompass the entire gasket
    borderRadius := LargestCircleRadius(k1, k2, k3) + 1 / k1 + 7.28;
    Bmp.EllipseAntialias(canvasWidth div 2, canvasHeight div 2, borderRadius * s1, borderRadius * s2, BGRA(0, 0, 0), 1);
  end;
end;

end.

