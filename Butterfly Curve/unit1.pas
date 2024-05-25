unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Spin,
  StdCtrls, Math;

type
  TXYZ = record
    x, y, z: Double;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    btnSave: TButton;
    btnRefresh: TButton;
    cbBackColor: TColorButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    seScalefactor: TSpinEdit;
    seLinewidth: TSpinEdit;
    seInterp: TSpinEdit;
    procedure btnRefreshClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure cbBackColorColorChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure seInterpChange(Sender: TObject);
    procedure seScalefactorChange(Sender: TObject);
    procedure seLinewidthChange(Sender: TObject);
  private
    procedure DrawButterflyCurve;
    function InterpolateColor(Color1, Color2: TColor; Factor: Double): TColor;
    function IsBrightColor(Acolor: TColor): Boolean;
    procedure InitializeColors;
  public
    Colors: array[0..23] of TColor;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

const
  N = 2000;

procedure TForm1.FormCreate(Sender: TObject);
begin
  seScalefactor.Value := 100;
  seLinewidth.Value := 2;
  InitializeColors;
end;

procedure TForm1.btnSaveClick(Sender: TObject);
var
  Png: TPortableNetworkGraphic;
begin
  Png := TPortableNetworkGraphic.Create;
  try
    Png.Width := PaintBox1.Width;
    Png.Height := PaintBox1.Height;

    Png.Canvas.FillRect(0, 0, Png.Width, Png.Height);

    Png.Canvas.CopyRect(PaintBox1.ClientRect, PaintBox1.Canvas, PaintBox1.ClientRect);

    if SaveDialog1.Execute then
      Png.SaveToFile(SaveDialog1.FileName);
  finally
    Png.Free;
  end;
end;

procedure TForm1.btnRefreshClick(Sender: TObject);
begin
    PaintBox1.Invalidate;
end;

procedure TForm1.cbBackColorColorChanged(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  DrawButterflyCurve;
end;

procedure TForm1.seInterpChange(Sender: TObject);
begin
   PaintBox1.Invalidate;
end;

procedure TForm1.seScalefactorChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.seLinewidthChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

function TForm1.IsBrightColor(Acolor: TColor): Boolean;
var
  r, g, b: Byte;
begin
  r := Red(Acolor);
  g := Green(Acolor);
  b := Blue(Acolor);
  Result := (r > 127) or (g > 127) or (b > 127);
end;

function TForm1.InterpolateColor(Color1, Color2: TColor; Factor: Double): TColor;
var
  r1, g1, b1: Byte;
  r2, g2, b2: Byte;
  r, g, b: Byte;
begin
  r1 := Red(Color1);
  g1 := Green(Color1);
  b1 := Blue(Color1);

  r2 := Red(Color2);
  g2 := Green(Color2);
  b2 := Blue(Color2);

  r := Round(r1 + Factor * (r2 - r1));
  g := Round(g1 + Factor * (g2 - g1));
  b := Round(b1 + Factor * (b2 - b1));

  Result := RGBToColor(r, g, b);
end;

procedure TForm1.InitializeColors;
begin
  Colors[0] := RGBToColor(255, 100, 0);
  Colors[1] := RGBToColor(0, 255, 0);
  Colors[2] := RGBToColor(0, 40, 200);
  Colors[3] := RGBToColor(255, 255, 0);
  Colors[4] := RGBToColor(210, 55, 155);
  Colors[5] := RGBToColor(255, 0, 255);
  Colors[6] := RGBToColor(255, 165, 0);
  Colors[7] := RGBToColor(0, 128, 0);
  Colors[8] := RGBToColor(0, 0, 128);
  Colors[9] := RGBToColor(255, 255, 255);
  Colors[10] := RGBToColor(128, 0, 128);
  Colors[11] := RGBToColor(255, 192, 203);
  Colors[12] := RGBToColor(128, 128, 0);
  Colors[13] := RGBToColor(64, 224, 208);
  Colors[14] := RGBToColor(0, 128, 128);
  Colors[15] := RGBToColor(245, 245, 220);
  Colors[16] := RGBToColor(255, 20, 147);
  Colors[17] := RGBToColor(0, 255, 255);
  Colors[18] := RGBToColor(255, 215, 0);
  Colors[19] := RGBToColor(30, 144, 255);
  Colors[20] := RGBToColor(173, 216, 230);
  Colors[21] := RGBToColor(255, 69, 0);
  Colors[22] := RGBToColor(144, 238, 144);
  Colors[23] := RGBToColor(75, 0, 130);
end;

procedure TForm1.DrawButterflyCurve;
var
  i, k, ColorIndex: Integer;
  u: Double;
  p, plast: TXYZ;
  x1, y1, x2, y2: Integer;
  scaleFactor: Double;
  penWidth: Integer;
  Color1, Color2, InterpolatedColor: TColor;
  Factor: Double;
begin
  PaintBox1.Canvas.Brush.Color := cbBackColor.ButtonColor;
  PaintBox1.Canvas.FillRect(0, 0, PaintBox1.Width, PaintBox1.Height);

  plast.x := 0;
  plast.y := 0;

  k := seInterp.Value;
  scaleFactor := seScalefactor.Value;
  penWidth := seLinewidth.Value;
  PaintBox1.Canvas.Pen.Width := penWidth;

  ColorIndex := Random(High(Colors));
  Color1 := Colors[ColorIndex];
  Color2 := Colors[(ColorIndex + 1) mod Length(Colors)];

  for i := 0 to N - 1 do
  begin
    u := i * 24.0 * Pi / N;
    p.x := cos(u) * (exp(cos(u)) - 2 * cos(4 * u) - Power(sin(u / 12), 5.0));
    p.y := sin(u) * (exp(cos(u)) - 2 * cos(4 * u) - Power(sin(u / 12), 5.0));
    p.z := abs(p.y) / 2;

    if i > 0 then
    begin
      x1 := Round(PaintBox1.Width / 2 - 100 + plast.x * scaleFactor);
      y1 := Round(PaintBox1.Height / 2 - plast.y * scaleFactor);
      x2 := Round(PaintBox1.Width / 2 - 100 + p.x * scaleFactor);
      y2 := Round(PaintBox1.Height / 2 - p.y * scaleFactor);
      PaintBox1.Canvas.MoveTo(x1, y1);

      Factor := k * i / N;
      InterpolatedColor := InterpolateColor(Color1, Color2, Factor);
      PaintBox1.Canvas.Pen.Color := InterpolatedColor;

      PaintBox1.Canvas.LineTo(x2, y2);
    end;

    plast := p;
  end;
end;

end.
