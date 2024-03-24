unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Math, LCLType, Spin;

type
  { TForm1 }

  TForm1 = class(TForm)
    btnShow: TButton;
    Image1: TImage;
    Panel1: TPanel;
    SpinEditDepth: TSpinEdit;
    SpinEditAngle: TSpinEdit;
    lbl_angle: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure SpinEditAngleChange(Sender: TObject);
    procedure SpinEditDepthChange(Sender: TObject);
  private
    procedure DrawTree(Angle: double; Depth: integer);
    procedure DrawTreeRecursive(X1, Y1: integer; Angle: double; Depth: integer);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

const ColorMap47: array [0..46] of TColor = (
	0 or (0 shl 8) or (0 shl 16),
	255 or (224 shl 8) or (224 shl 16),
	255 or (212 shl 8) or (212 shl 16),
	255 or (169 shl 8) or (169 shl 16),
	255 or (127 shl 8) or (127 shl 16),
	255 or (84 shl 8) or (84 shl 16),
	255 or (42 shl 8) or (42 shl 16),
	255 or (0 shl 8) or (0 shl 16),
	255 or (13 shl 8) or (0 shl 16),
	255 or (26 shl 8) or (0 shl 16),
	255 or (40 shl 8) or (0 shl 16),
	255 or (53 shl 8) or (0 shl 16),
	255 or (67 shl 8) or (0 shl 16),
	255 or (80 shl 8) or (0 shl 16),
	255 or (93 shl 8) or (0 shl 16),
	255 or (107 shl 8) or (0 shl 16),
	255 or (120 shl 8) or (0 shl 16),
	255 or (134 shl 8) or (0 shl 16),
	255 or (147 shl 8) or (0 shl 16),
	255 or (161 shl 8) or (0 shl 16),
	255 or (174 shl 8) or (0 shl 16),
	255 or (187 shl 8) or (0 shl 16),
	255 or (201 shl 8) or (0 shl 16),
	255 or (214 shl 8) or (0 shl 16),
	255 or (228 shl 8) or (0 shl 16),
	255 or (241 shl 8) or (0 shl 16),
	255 or (255 shl 8) or (0 shl 16),
	236 or (248 shl 8) or (0 shl 16),
	218 or (242 shl 8) or (0 shl 16),
	200 or (235 shl 8) or (0 shl 16),
	183 or (229 shl 8) or (0 shl 16),
	167 or (223 shl 8) or (0 shl 16),
	151 or (216 shl 8) or (0 shl 16),
	136 or (210 shl 8) or (0 shl 16),
	122 or (204 shl 8) or (0 shl 16),
	108 or (197 shl 8) or (0 shl 16),
	95 or (191 shl 8) or (0 shl 16),
	83 or (185 shl 8) or (0 shl 16),
	71 or (178 shl 8) or (0 shl 16),
	60 or (172 shl 8) or (0 shl 16),
	49 or (166 shl 8) or (0 shl 16),
	39 or (159 shl 8) or (0 shl 16),
	30 or (153 shl 8) or (0 shl 16),
	22 or (147 shl 8) or (0 shl 16),
	14 or (140 shl 8) or (0 shl 16),
	6 or (134 shl 8) or (0 shl 16),
	0 or (128 shl 8) or (0 shl 16));

procedure TForm1.FormCreate(Sender: TObject);
begin
  SpinEditAngle.Value := 22; // Initial angle value
  SpinEditDepth.Value := 11;  // Initial depth value
  DrawTree(SpinEditAngle.Value, SpinEditDepth.value);
end;

procedure TForm1.SpinEditAngleChange(Sender: TObject);
begin
  Image1.Picture := nil; // Clear the image
  DrawTree(SpinEditAngle.Value, SpinEditDepth.value);
end;

procedure TForm1.SpinEditDepthChange(Sender: TObject);
begin
  Image1.Picture := nil; // Clear the image
  DrawTree(SpinEditAngle.Value, SpinEditDepth.value);
end;

procedure TForm1.DrawTree(Angle: double; Depth: integer);
var
  X1, Y1: integer;
begin
  if Depth <= 0 then
    Exit;

  X1 := Image1.Width div 2;
  Y1 := Image1.Height - 60; // Adjust as needed

  DrawTreeRecursive(X1, Y1, 90+Angle, Depth);
  DrawTreeRecursive(X1, Y1, 90-Angle, Depth);
end;

procedure TForm1.DrawTreeRecursive(X1, Y1: integer; Angle: double; Depth: integer);
var
  X2, Y2: integer;
  ColorIndex: Integer;

begin
  if Depth <= 0 then
    Exit;

  X2 := X1 + Trunc(cos(DegToRad(Angle)) * Depth * 11);
  Y2 := Y1 - Trunc(sin(DegToRad(Angle)) * Depth * 11);

  ColorIndex := Depth mod Length(ColorMap47);
  Image1.Canvas.Pen.Color := ColorMap47[MulDiv(High(ColorMap47), Depth, 11)];
  Image1.Canvas.Pen.Width := MulDiv(Depth, 5, 10);

  Image1.Canvas.MoveTo(X1, Y1);
  Image1.Canvas.LineTo(X2, Y2);

  DrawTreeRecursive(X2, Y2, Angle - SpinEditAngle.Value, Depth - 1);
  DrawTreeRecursive(X2, Y2, Angle + SpinEditAngle.Value, Depth - 1);
end;


end.
