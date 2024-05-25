unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Spin,
  StdCtrls, Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    cbLinecolor: TColorButton;
    cbCircFillcolor: TColorButton;
    cbCircBordercolor: TColorButton;
    chkHideCircles: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    seLinewidth: TSpinEdit;
    seCircBordWidth: TSpinEdit;
    procedure cbCircBordercolorClick(Sender: TObject);
    procedure cbCircBordercolorColorChanged(Sender: TObject);
    procedure cbCircFillcolorColorChanged(Sender: TObject);
    procedure cbLinecolorColorChanged(Sender: TObject);
    procedure chkHideCirclesChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure seLinewidthChange(Sender: TObject);
    procedure seCircBordWidthChange(Sender: TObject);
  private
    procedure DrawPattern(ACanvas: TCanvas; AWidth, AHeight: Integer);
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Initialize the form and force a repaint.
  PaintBox1.Invalidate;
end;

procedure TForm1.cbCircBordercolorColorChanged(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.cbCircBordercolorClick(Sender: TObject);
begin
   PaintBox1.Invalidate;
end;

procedure TForm1.cbCircFillcolorColorChanged(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.cbLinecolorColorChanged(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.chkHideCirclesChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  DrawPattern(PaintBox1.Canvas, PaintBox1.Width, PaintBox1.Height);
end;

procedure TForm1.seLinewidthChange(Sender: TObject);
begin
   PaintBox1.Invalidate;
end;

procedure TForm1.seCircBordWidthChange(Sender: TObject);
begin
   PaintBox1.Invalidate;
end;

procedure TForm1.DrawPattern(ACanvas: TCanvas; AWidth, AHeight: Integer);
var
  Margin, Diameter1, Diameter2, Diameter, Radius, Cx, Cy: Single;
  Centers: array of TPoint;
  RingNum, I, J, NumCircles: Integer;
  RingRadius, Theta, DTheta: Double;
  X, Y: Single;
  Center: TPoint;
begin
  // Set up drawing parameters.
  Margin := 10;
  Diameter1 := (AHeight - Margin) / 5.0;
  Diameter2 := (AWidth - Margin) / (1 + 2 * Sqrt(3));
  Diameter := Min(Diameter1, Diameter2);
  Radius := Diameter / 2.0;
  Cx := AWidth / 2.0;
  Cy := AHeight / 2.0;

  // Find the center circle's center.
  SetLength(Centers, 1);
  Centers[0] := Point(Round(Cx), Round(Cy));

  // Add the other circles.
  for RingNum := 0 to 1 do
  begin
    RingRadius := Diameter * (RingNum + 1);
    Theta := Pi / 2.0;
    DTheta := Pi / 3.0;
    for I := 0 to 5 do
    begin
      X := Cx + RingRadius * Cos(Theta);
      Y := Cy + RingRadius * Sin(Theta);
      SetLength(Centers, Length(Centers) + 1);
      Centers[High(Centers)] := Point(Round(X), Round(Y));
      Theta := Theta + DTheta;
    end;
  end;

  // Fill and outline the circles if they are not hidden.
  if not chkHideCircles.Checked then
  begin
    ACanvas.Brush.Color := cbCircFillcolor.ButtonColor;
    ACanvas.Pen.Color := cbCircBordercolor.ButtonColor;
    ACanvas.Pen.Width := seCircBordWidth.Value;
    for Center in Centers do
    begin
      X := Center.X - Radius;
      Y := Center.Y - Radius;
      ACanvas.Ellipse(Round(X), Round(Y), Round(X + Diameter), Round(Y + Diameter));
    end;
  end;

  // Draw lines connecting the circle centers.
  ACanvas.Pen.Color := cbLinecolor.ButtonColor;
  ACanvas.Pen.Width := seLinewidth.Value;
  NumCircles := Length(Centers);
  for I := 0 to NumCircles - 1 do
  begin
    for J := I + 1 to NumCircles - 1 do
    begin
      ACanvas.MoveTo(Centers[I].X, Centers[I].Y);
      ACanvas.LineTo(Centers[J].X, Centers[J].Y);
    end;
  end;
end;

end.
