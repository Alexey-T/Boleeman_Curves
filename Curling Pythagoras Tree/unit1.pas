unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, ExtCtrls, Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    angleSlider: TSpinEdit;
    CheckboxFill: TCheckBox;
    FillColorButton2: TColorButton;
    FillColorButton1: TColorButton;
    ColorButtonbackcolor: TColorButton;
    lblExtraOffset: TLabel;
    lblTrianglecolor: TLabel;
    lblSquarecolor: TLabel;
    lblBaselength: TLabel;
    lblBackcolor: TLabel;
    lblLinewidth: TLabel;
    lblLinecolor: TLabel;
    lblDepth: TLabel;
    lblAngle: TLabel;
    LineColorButton: TColorButton;
    depthSlider: TSpinEdit;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    resetButton: TButton;
    seBasechanger: TSpinEdit;
    SpinEditAngleOffset: TSpinEdit;
    SpinEditLineWidth: TSpinEdit;

    procedure angleSliderChange(Sender: TObject);
    procedure CheckboxFillChange(Sender: TObject);
    procedure ColorButtonbackcolorColorChanged(Sender: TObject);
    procedure depthSliderChange(Sender: TObject);
    procedure FillColorButton1ColorChanged(Sender: TObject);
    procedure FillColorButton2ColorChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LineColorButtonColorChanged(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure resetButtonClick(Sender: TObject);
    procedure seBasechangerChange(Sender: TObject);
    procedure SpinEditAngleOffsetChange(Sender: TObject);
    procedure SpinEditLineWidthChange(Sender: TObject);
  private
    angle, angleOffset: Double;
    FLength: Integer;
    FDepth: Integer;
    FLineColor: TColor;
    origin: TPoint;
    root: array[0..3] of TPoint;
    procedure DrawTree(p0, p1, p2, p3: TPoint; ALength: Integer; ADepth: Integer; a, b: Double);
    procedure Initialize;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  Initialize;
end;

procedure TForm1.LineColorButtonColorChanged(Sender: TObject);
begin
  FLineColor := LineColorButton.ButtonColor;
  PaintBox1.Invalidate;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Clear;
  FLineColor := LineColorButton.ButtonColor;
  DrawTree(root[0], root[1], root[2], root[3], FLength, FDepth, angle, 90 - angle);
end;

procedure TForm1.angleSliderChange(Sender: TObject);
begin
  angle := angleSlider.Value;
  PaintBox1.Invalidate;
end;

procedure TForm1.CheckboxFillChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.ColorButtonbackcolorColorChanged(Sender: TObject);
begin
    PaintBox1.Invalidate;
end;

procedure TForm1.depthSliderChange(Sender: TObject);
begin
  FDepth := depthSlider.Value;
  PaintBox1.Invalidate;
end;

procedure TForm1.FillColorButton1ColorChanged(Sender: TObject);
begin
    PaintBox1.Invalidate;
end;

procedure TForm1.FillColorButton2ColorChanged(Sender: TObject);
begin
    PaintBox1.Invalidate;
end;

procedure TForm1.resetButtonClick(Sender: TObject);
begin
  Initialize;
  PaintBox1.Invalidate;
end;

procedure TForm1.seBasechangerChange(Sender: TObject);
begin
  FLength := seBasechanger.Value;
  root[0] := Point(origin.X, origin.Y - FLength);
  root[1] := Point(origin.X + FLength, origin.Y - FLength);
  root[2] := Point(origin.X + FLength, origin.Y);
  root[3] := Point(origin.X, origin.Y);

  PaintBox1.Invalidate;
end;

procedure TForm1.SpinEditAngleOffsetChange(Sender: TObject);
begin
  angleOffset := SpinEditAngleOffset.Value;
  PaintBox1.Invalidate;
end;

procedure TForm1.SpinEditLineWidthChange(Sender: TObject);
begin
    PaintBox1.Invalidate;
end;

procedure TForm1.DrawTree(p0, p1, p2, p3: TPoint; ALength: Integer; ADepth: Integer; a, b: Double);
var
  t, tc, lengthA, lengthB: Double;
  leftPoints, rightPoints: array[0..3] of TPoint;
  polygonPoints: array of TPoint;

begin
  // Draw the initial square
  if ADepth = FDepth then
  begin
    if CheckboxFill.Checked then
    begin
      PaintBox1.Canvas.Brush.Color := FillColorButton1.ButtonColor;
      polygonPoints := [p0, p1, p2, p3];
      PaintBox1.Canvas.Polygon(polygonPoints);
    end
    else
    begin
      PaintBox1.Canvas.Polyline([p0, p1, p2, p3, p0]);
    end;
  end;

  if ADepth = 0 then
    Exit;

  PaintBox1.Canvas.Pen.Color := FLineColor;
  PaintBox1.Canvas.Pen.Width := SpinEditLineWidth.Value; // Set the line width
  PaintBox1.Color := ColorButtonbackcolor.ButtonColor;

  t := (a / 180) * Pi;
  tc := (b / 180) * Pi;

  lengthA := ALength * Cos((angle / 180) * Pi);
  lengthB := ALength * Cos(((90 - angle) / 180) * Pi);

  // Initialize the arrays
  FillChar(leftPoints, SizeOf(leftPoints), 0);
  FillChar(rightPoints, SizeOf(rightPoints), 0);
  SetLength(polygonPoints, 0);

  leftPoints[0].X := p0.X - round(lengthA * Cos(tc));
  leftPoints[0].Y := p0.Y - round(lengthA * Sin(tc));

  leftPoints[1].X := p0.X + round(lengthA * Cos(t) - lengthA * Sin(t));
  leftPoints[1].Y := p0.Y - round(lengthA * Sin(t) + lengthA * Cos(t));

  leftPoints[2].X := p0.X + round(lengthA * Cos(t));
  leftPoints[2].Y := p0.Y - round(lengthA * Sin(t));

  leftPoints[3] := p0;

  rightPoints[3].X := p1.X - round(lengthB * Cos(tc));
  rightPoints[3].Y := p1.Y - round(lengthB * Sin(tc));

  rightPoints[2] := p1;

  rightPoints[1].X := p1.X + round(lengthB * Cos(t));
  rightPoints[1].Y := p1.Y - round(lengthB * Sin(t));

  rightPoints[0].X := p1.X - round(lengthB * Cos(tc) - lengthB * Sin(tc));
  rightPoints[0].Y := p1.Y - round(lengthB * Sin(tc) + lengthB * Cos(tc));

  // Draw squares
  if CheckboxFill.Checked then
  begin
    PaintBox1.Canvas.Brush.Color := FillColorButton1.ButtonColor;
    polygonPoints := [leftPoints[0], leftPoints[1], leftPoints[2], leftPoints[3]];
    PaintBox1.Canvas.Polygon(polygonPoints);

    polygonPoints := [rightPoints[0], rightPoints[1], rightPoints[2], rightPoints[3]];
    PaintBox1.Canvas.Polygon(polygonPoints);
  end
  else
  begin
    PaintBox1.Canvas.Polyline([leftPoints[0], leftPoints[1], leftPoints[2], leftPoints[3], leftPoints[0]]);
    PaintBox1.Canvas.Polyline([rightPoints[0], rightPoints[1], rightPoints[2], rightPoints[3], rightPoints[0]]);
  end;

  // Draw the triangle formed by p2, p3, and the next p0
  SetLength(polygonPoints, 3);
  polygonPoints[0] := rightPoints[2];
  polygonPoints[1] := rightPoints[3];
  polygonPoints[2] := p0;

  if CheckboxFill.Checked then
  begin
    PaintBox1.Canvas.Brush.Color := FillColorButton2.ButtonColor;
    PaintBox1.Canvas.Polygon(polygonPoints);
  end
  else
  begin
    PaintBox1.Canvas.Polyline([p0, rightPoints[2], rightPoints[3], p0]);
  end;

  PaintBox1.Canvas.Polyline([p0, p1, p2, p3, p0]);

  // Recursive calls with adjusted lengths
  DrawTree(leftPoints[0], leftPoints[1], leftPoints[2], leftPoints[3], round(lengthA), ADepth - 1, a + angle + angleOffset, b - angle - angleOffset);
  DrawTree(rightPoints[0], rightPoints[1], rightPoints[2], rightPoints[3], round(lengthB), ADepth - 1, angle - b + angleOffset, b + (90 - angle) - angleOffset);
end;

procedure TForm1.Initialize;
begin
  angle := 45;
  angleOffset:= 0;
  FLength := (PaintBox1.Height - Panel1.Height) div 4;

  FDepth := 5;
  origin := Point(PaintBox1.Width div 2 - FLength div 2, 4 * FLength);

  root[0] := Point(origin.X, origin.Y - FLength);
  root[1] := Point(origin.X + FLength, origin.Y - FLength);
  root[2] := Point(origin.X + FLength, origin.Y);
  root[3] := Point(origin.X, origin.Y);

  angleSlider.Value := angle;
  depthSlider.Value := FDepth;
  SpinEditAngleOffset.Value := angleOffset;

  // Draw the initial root square
  PaintBox1.Canvas.Brush.Color := FillColorButton1.ButtonColor;
  PaintBox1.Canvas.Polygon([root[0], root[1], root[2], root[3], root[0]]);

  DrawTree(root[0], root[1], root[2], root[3], FLength, FDepth, angle + angleOffset, 90 - angle + angleOffset);
end;

end.
