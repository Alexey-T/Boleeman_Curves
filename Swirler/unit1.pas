unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Spin, Math,
  ColorBox, LCLIntf, StdCtrls, FPImage, IntfGraphics, ComCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnSavePng: TButton;
    Button1: TButton;
    cbSwirlercolor: TColorButton;
    chbReverse: TCheckBox;
    chkCycle: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    seNvalue: TSpinEdit;
    seScale: TSpinEdit;
    Shape1: TShape;
    Shape2: TShape;
    Timer1: TTimer;
    trbColorSpeed: TTrackBar;
    trkAnimSpeed: TTrackBar;
    procedure btnSavePngClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure seNvalueChange(Sender: TObject);
    procedure seScaleChange(Sender: TObject);
    procedure cbSwirlercolorColorChanged(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure trkAnimSpeedChange(Sender: TObject);
  private
    procedure Swirler;
  public

  end;

var
  Form1: TForm1;
  add:double=0;
  colors: array of tcolor;
  colorcount:integer=127;
  colorcounter:integer=0;
  cyc:integer=0;
  Animate:boolean=false;
  painting:boolean=false;

implementation

{$R *.lfm}

{ TForm1 }

procedure generatecolors;
var i:integer;

function fadecolor(f,t:tcolor;d:single):tcolor;
begin
  f:=ColorToRGB(f);
  t:=ColorToRGB(t);
  result:=RGBToColor(Round(red(f)+(red(t)-red(f))*d),Round(green(f)+(green(t)-green(f))*d),Round(blue(f)+(blue(t)-blue(f))*d));
end;

begin
  SetLength(colors, colorcount+1);
//  if chkCyclecolors.Checked then
  begin;
    for i := 0 to colorcount  do
    begin
      colors[i] := RGBToColor(
      Trunc(255 * (1 - i / colorcount)),   // Red component
      Trunc(255 * Abs(Sin(i))),   // Green component
      Trunc(255 * (i / colorcount))        // Blue component
      );
   //   if chkStagger.checked then sp[i]:=i else sp[i]:=0;
    end;
  end
{  else
  begin
    for i:=0 to n do
    begin
      colors[i]:=fadecolor(shpSetColor.Brush.Color,dispScrollBox.Color,(i+1)/(n+6));
    end;
  end};
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  colorcounter:=0;
  Generatecolors;
  seNvalue.Value := 5;
  seScale.Value := 10;
  cbSwirlercolor.ButtonColor := $0080FF00;
end;

procedure TForm1.btnSavePngClick(Sender: TObject);
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

procedure TForm1.Button1Click(Sender: TObject);
begin
  Animate:=Not Animate;
  if Animate Then button1.Caption:='Stop' else button1.Caption:='Start';
end;

procedure TForm1.Swirler;
var
  n, scale: Single;
  cx, cy: Single;
  r, theta, dx, dy, dy2, f: Single;
  x, y, b: Integer;
  Bitmap: TBitmap;
  Acolor: TColor;
  red, green, blue: Byte;
  Line: PByteArray;
begin
  try
    n := seNvalue.Value;
    scale := seScale.Value;
  except
    Exit;
  end;
  if painting then exit;
  painting:=true;
  Acolor := cbSwirlercolor.ButtonColor;
  red := GetRValue(Acolor);
  green := GetGValue(Acolor);
  blue := GetBValue(Acolor);

  Bitmap := TBitmap.Create;
  try
    Bitmap.PixelFormat := pf24bit;
    Bitmap.SetSize(PaintBox1.Width, PaintBox1.Height);
    cx := Bitmap.Width / 2;
    cy := Bitmap.Height / 2;

    for y := 0 to Bitmap.Height - 1 do
    begin
      If Animate then
      begin
        if chkCycle.Checked then Acolor:=colors[colorcounter] else Acolor := cbSwirlercolor.ButtonColor;
        red := GetRValue(Acolor);
        green := GetGValue(Acolor);
        blue := GetBValue(Acolor);
      end;
      dy := (y - cy) / scale;
      dy2 := dy * dy;
      Line := Bitmap.ScanLine[y];
      for x := 0 to Bitmap.Width - 1 do
      begin
        dx := (x - cx) / scale;
        r := Sqrt(dx * dx + dy2);
        if (dx = 0) and (dy = 0) then
          theta := 0
        else
          theta := ArcTan2(dy, dx);
        f := Sin(6 * Cos(r) - n * theta)+add;
        b := Round(128 + 127 * f);
        Line^[3 * x] := blue * b div 255;
        Line^[3 * x + 1] := green * b div 255;
        Line^[3 * x + 2] := red * b div 255;
      end;

    end;
    inc(cyc);
    if cyc>trbColorSpeed.Position then
    begin
      inc(colorcounter);
      if colorcounter>colorcount then colorcounter:=0;
      cyc:=0;
    end;
    PaintBox1.Canvas.Draw(0, 0, Bitmap);
  finally
    Bitmap.Free;
  end;
  painting:=false;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  Swirler;
end;

procedure TForm1.seNvalueChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.seScaleChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.cbSwirlercolorColorChanged(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if painting then exit;
  If Animate then
  begin
    if chbReverse.Checked then add:=add-0.1 else add:=add+0.1;
    swirler;
  end;
end;

procedure TForm1.trkAnimSpeedChange(Sender: TObject);
begin
  timer1.Interval:=trkAnimSpeed.Position;
end;

end.
