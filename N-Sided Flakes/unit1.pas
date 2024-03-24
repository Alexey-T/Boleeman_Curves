unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Spin, StdCtrls, Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    CheckBoxFill: TCheckBox;
    ColorButtonbackcolor: TColorButton;
    FillColorButton: TColorButton;
    lblNumSides: TLabel;
    lblRotate: TLabel;
    lblBackcolor: TLabel;
    lblFillcolor: TLabel;
    lblLinecolor: TLabel;
    lblLinewidth: TLabel;
    lblflakesize: TLabel;
    lbl_recursionlevel: TLabel;
    LabelDepth: TLabel;
    LabelSize: TLabel;
    LineColorButton: TColorButton;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    SpinEditNumSides: TSpinEdit;
    SpinEditRotate: TSpinEdit;
    SpinEditDepth: TSpinEdit;
    SpinEditLineWidth: TSpinEdit;
    SpinEditSize: TSpinEdit;
    procedure ColorButtonbackcolorColorChanged(Sender: TObject);
    procedure FillColorButtonColorChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LineColorButtonColorChanged(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure SpinEditDepthChange(Sender: TObject);
    procedure SpinEditLineWidthChange(Sender: TObject);
    procedure SpinEditNumSidesChange(Sender: TObject);
    procedure SpinEditRotateChange(Sender: TObject);
    procedure SpinEditSizeChange(Sender: TObject);
    procedure CheckBoxFillChange(Sender: TObject);
  private
    FFillit: Boolean;
    procedure DrawNFlake(x, y, size, depth: Double; numsides: Integer; Filled: Boolean);
    function ToRadians(degrees: Double): Double;
  public

    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.DrawNFlake(x, y, size, depth: Double; numsides: Integer; Filled: Boolean);
var
  angle, ROTATION, internalangle: Double;
  distance: Double;
  j: Integer;
  newX, newY: Double;
  polygonPoints: array of TPoint;
begin
  internalangle := (180 - (numsides - 2) * 180 / numsides);
  ROTATION := ToRadians(-SpinEditRotate.Value + 90 - internalangle);
  angle := (numsides - 2) * ToRadians(internalangle) + ROTATION; // starting angle

  if depth = 1 then
  begin
    SetLength(polygonPoints, numsides);
    PaintBox1.Color := ColorButtonbackcolor.ButtonColor;
    PaintBox1.Canvas.Pen.Color := LineColorButton.ButtonColor;
    PaintBox1.Canvas.Pen.Width := SpinEditLineWidth.Value; // Set the line width
    PaintBox1.Canvas.MoveTo(Round(x), Round(y));

    // draw from the top
    for j := 0 to (numsides - 1) do
    begin
      newX := x + size * Cos(angle);
      newY := y - size * Sin(angle);
      polygonPoints[j] := Point(Round(newX), Round(newY));
      angle += ToRadians(internalangle);
    end;

    PaintBox1.Canvas.Polygon(polygonPoints);

    if Filled then
    begin
      PaintBox1.Color := ColorButtonbackcolor.ButtonColor;
      PaintBox1.Canvas.Brush.Color := FillColorButton.ButtonColor;
      PaintBox1.Canvas.Pen.Width := SpinEditLineWidth.Value; // Set the line width
      PaintBox1.Canvas.Pen.Color := LineColorButton.ButtonColor;
      PaintBox1.Canvas.Brush.Style := bsSolid; // Set the brush style
      PaintBox1.Canvas.Polygon(polygonPoints);
    end;
  end
  else
  begin
    PaintBox1.Canvas.Pen.Color := LineColorButton.ButtonColor;
    size *= 1 / (2 + Cos(ToRadians(internalangle)) * 2);

    distance := size + size * Cos(ToRadians(internalangle)) * 2;
    SetLength(polygonPoints, numsides); // Adjust the length before using

    for j := 0 to (numsides - 1) do
    begin
      newX := x + distance * Cos(angle);
      newY := y - distance * Sin(angle);
      DrawNFlake(newX, newY, size, depth - 1, numsides, Filled);
      angle += ToRadians(internalangle);
    end;

    SetLength(polygonPoints, 0); // Clear the array explicitly
  end;
end;


function TForm1.ToRadians(degrees: Double): Double;
begin
  Result := degrees * (Pi / 180);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SpinEditNumSides.Value := 8;
  PaintBox1.Color:= clDefault;
  SpinEditLineWidth.Value := 2; // Initial line width value
  SpinEditDepth.Value := 4; // Initial depth value
  SpinEditSize.Value := 420; // Initial size value
  FFillit := True; // Initial fill state

end;

procedure TForm1.LineColorButtonColorChanged(Sender: TObject);
begin
     PaintBox1.Invalidate;
end;

procedure TForm1.FillColorButtonColorChanged(Sender: TObject);
begin
   PaintBox1.Invalidate;
end;

procedure TForm1.ColorButtonbackcolorColorChanged(Sender: TObject);
begin
  PaintBox1.Color:= ColorButtonbackcolor.ButtonColor;
  PaintBox1.Invalidate;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Clear;
  DrawNFlake(PaintBox1.Width / 2, (PaintBox1.Height - SpinEditSize.Value + 2* Panel1.Height) / 2 + (SpinEditNumSides.Value - 2) * (180 - (SpinEditNumSides.Value - 2) * 180 / (SpinEditNumSides.Value -1 )),
    SpinEditSize.Value, SpinEditDepth.Value, SpinEditNumSides.Value, CheckBoxFill.Checked);
end;

procedure TForm1.SpinEditDepthChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.SpinEditLineWidthChange(Sender: TObject);
begin
  PaintBox1.Canvas.Pen.Width := SpinEditLineWidth.Value;
  PaintBox1.Invalidate;
end;

procedure TForm1.SpinEditNumSidesChange(Sender: TObject);
begin
   PaintBox1.Invalidate;
end;

procedure TForm1.SpinEditRotateChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.SpinEditSizeChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.CheckBoxFillChange(Sender: TObject);
begin
  FFillit := CheckBoxFill.Checked;
  PaintBox1.Invalidate;
end;

end.
