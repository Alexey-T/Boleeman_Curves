unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Spin, ExtCtrls, ComCtrls, Math,
  LCLIntf, LCLType, StdCtrls;

type
  { TForm1 }
  TForm1 = class(TForm)
    lbl_BranchAngle: TLabel;
    lbl_LineThickness: TLabel;
    lbl_RecursionLevel: TLabel;
    lbl_trackbarvalue: TLabel;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    ScrollBox1: TScrollBox;
    SpinEditAngle: TSpinEdit;
    SpinEditLineThickness: TSpinEdit;
    SpinEditRecursion: TSpinEdit;
    TrackBarScale: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure SpinEditAngleChange(Sender: TObject);
    procedure SpinEditLineThicknessChange(Sender: TObject);
    procedure SpinEditRecursionChange(Sender: TObject);
    procedure ScrollBox1Resize(Sender: TObject);
    procedure TrackBarScaleChange(Sender: TObject);
  private
    ScalingFactor: Double;
    procedure Draw(x1, y1: Integer; angle, branchAngle: Double; depth, lineWidth: Integer; ACanvas: TCanvas; ScaleFactor: Double);
    function HSBToColor(Hue, Saturation, Brightness: Double): TColor;
  public
  end;

var
  Form1: TForm1;

const
  DEPTH = 9;

implementation

{$R *.lfm}

{ TForm1 }



procedure TForm1.ScrollBox1Resize(Sender: TObject);
begin
  // Resize PaintBox to match the size of ScrollBox
  PaintBox1.Width := ScrollBox1.ClientWidth;
  PaintBox1.Height := ScrollBox1.ClientHeight;
  PaintBox1.Invalidate;  // Force PaintBox repaint
end;

procedure TForm1.TrackBarScaleChange(Sender: TObject);
begin
  // Adjust the ScalingFactor based on TrackBar position
  ScalingFactor := Power(1.135, DEPTH - SpinEditRecursion.Value) * TrackBarScale.Position / 50;
  lbl_trackbarvalue.Caption:= 'Tracbar Scale Value = ' + inttostr(TrackBarScale.Position);
  PaintBox1.Invalidate;
end;



procedure TForm1.SpinEditAngleChange(Sender: TObject);
begin
  PaintBox1.Invalidate;  // Force PaintBox repaint
end;

procedure TForm1.SpinEditLineThicknessChange(Sender: TObject);
begin
  PaintBox1.Invalidate;  // Force PaintBox repaint
end;



function TForm1.HSBToColor(Hue, Saturation, Brightness: Double): TColor;
var
  r, g, b: Byte;
  i: Integer;
  f, p, q, t: Double;
begin
  if Saturation = 0 then
  begin
    r := Round(Brightness * 255);
    g := r;
    b := r;
  end
  else
  begin
    if Hue = 360 then
      Hue := 0;
    Hue := Hue / 60;
    i := Trunc(Hue);
    f := Hue - i;
    p := Brightness * (1 - Saturation);
    q := Brightness * (1 - Saturation * f);
    t := Brightness * (1 - Saturation * (1 - f));

    case i of
      0: begin r := Round(Brightness * 255); g := Round(t * 255); b := Round(p * 255); end;
      1: begin r := Round(q * 255); g := Round(Brightness * 255); b := Round(p * 255); end;
      2: begin r := Round(p * 255); g := Round(Brightness * 255); b := Round(t * 255); end;
      3: begin r := Round(p * 255); g := Round(q * 255); b := Round(Brightness * 255); end;
      4: begin r := Round(t * 255); g := Round(p * 255); b := Round(Brightness * 255); end;
      5: begin r := Round(Brightness * 255); g := Round(p * 255); b := Round(q * 255); end;
    else
      r := 0; g := 0; b := 0;
    end;
  end;

  Result := RGBToColor(r, g, b);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin


  TrackBarScale.Min := 1;
  TrackBarScale.Max := 100;
  TrackBarScale.Frequency := 1;
  TrackBarScale.Position := 65; // Set an initial position
  lbl_trackbarvalue.Caption:= 'Tracbar Scale Value = ' + inttostr(TrackBarScale.Position);
  // Set default values for the SpinEdits
  SpinEditAngle.Value := 20;
  SpinEditRecursion.Value := 12;  // Set initial recursion value to 12
  SpinEditLineThickness.Value := 1;

  // Set initial size for PaintBox
  PaintBox1.Width := ScrollBox1.Width;
  PaintBox1.Height := ScrollBox1.Height;

  // Ensure entire tree is visible by setting the initial scaling factor
    ScalingFactor := Power(1.135, DEPTH - SpinEditRecursion.Value) * TrackBarScale.Position / 50;

  // Force initial PaintBox repaint
  PaintBox1.Invalidate;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  center: TPoint;
begin
  center := Point(PaintBox1.Width div 2, PaintBox1.Height);

  // Adjust the center based on scrollbar visibility
  if ScrollBox1.VertScrollBar.Visible then
    center.X := center.X - GetSystemMetrics(SM_CXVSCROLL);

  Draw(center.X - ScrollBox1.HorzScrollBar.Position, center.Y - ScrollBox1.VertScrollBar.Position, -90, SpinEditAngle.Value,
    SpinEditRecursion.Value, SpinEditLineThickness.Value, PaintBox1.Canvas, ScalingFactor);
end;

procedure TForm1.SpinEditRecursionChange(Sender: TObject);
begin
  // Adjust the ScalingFactor when recursion level changes
  ScalingFactor := Power(1.135, DEPTH - SpinEditRecursion.Value) * TrackBarScale.Position / 50;

  // Calculate a fixed scaling factor based on your requirements
  // You may need to adjust this based on how you want the scaling to behave
  // ScalingFactor := 1 / SpinEditRecursion.Value;

  PaintBox1.Invalidate;  // Force PaintBox repaint
end;

procedure TForm1.Draw(x1, y1: Integer; angle, branchAngle: Double; depth, lineWidth: Integer; ACanvas: TCanvas; ScaleFactor: Double);
var
  x2, y2: Integer;
  hue: Double;
begin
  if depth > 0 then
  begin
    // Scale the length of each branch
    x2 := x1 + Round(Cos(DegToRad(angle)) * depth * 10 * ScaleFactor);
    y2 := y1 + Round(Sin(DegToRad(angle)) * depth * 10 * ScaleFactor);

    hue := 90 - depth * 10; // Adjust the starting hue and rate of change as needed

    ACanvas.Pen.Color := HSBToColor(hue, 0.5, 0.4);

    // Scale factor to keep the tree size consistent when recursion is increased
    ACanvas.Pen.Width := Round((depth + lineWidth div 2 - 1));

    ACanvas.AntialiasingMode := amOn;

    // Adjust coordinates based on the scroll position
    x2 := x2 - ScrollBox1.HorzScrollBar.Position;
    y2 := y2 - ScrollBox1.VertScrollBar.Position;

    ACanvas.Line(x1, y1, x2, y2);

    // Use branchAngle for recursion
    Draw(x2, y2, angle + branchAngle, branchAngle, depth - 1, lineWidth, ACanvas, ScaleFactor);
    Draw(x2, y2, angle - branchAngle, branchAngle, depth - 1, lineWidth, ACanvas, ScaleFactor);
  end;
end;

end.
