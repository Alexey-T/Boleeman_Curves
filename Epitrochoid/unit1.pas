unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Spin, Math,
  StdCtrls, ComCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    cbLinecolor: TColorButton;
    cbBackcolor: TColorButton;
    chkBoxB: TCheckBox;
    chkBoxA: TCheckBox;
    chkMerge: TCheckBox;
    chkBoxH: TCheckBox;
    chkBoxDT: TCheckBox;
    chkBoxCycleColor: TCheckBox;
    chkDrawCenterLine: TCheckBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    seLinewidth: TSpinEdit;
    seFloatDT: TFloatSpinEdit;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    seA: TSpinEdit;
    seB: TSpinEdit;
    seH: TSpinEdit;
    animBorder: TShape;
    pnlBorder: TShape;
    Timer1: TTimer;
    trkBUpdateSpeed: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure cbBackcolorColorChanged(Sender: TObject);
    procedure chkBoxCycleColorChange(Sender: TObject);
    procedure chkDrawCenterLineChange(Sender: TObject);
    procedure chkMergeChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure seAChange(Sender: TObject);
    procedure seBChange(Sender: TObject);
    procedure seFloatDTChange(Sender: TObject);
    procedure seHChange(Sender: TObject);
    procedure cbLinecolorColorChanged(Sender: TObject);
    procedure seLinewidthChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure trkBUpdateSpeedChange(Sender: TObject);
  private
    procedure DrawEpitrochoid(ACanvas: TCanvas; a, b, h, dt: Double);
    function X(a, b, h, t: Double): Double;
    function Y(a, b, h, t: Double): Double;
    procedure generatecolors;
  public

  end;

var
  Form1: TForm1;
  colors: array of tcolor;
  numberofcolors:integer=117;
  colorcounter:integer=0;
  Animate:Boolean=False;
  PaintingFinished:Boolean=True;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.generatecolors;
var i:integer;

begin
  SetLength(colors, numberofcolors+1);
  for i := 0 to numberofcolors  do
  begin
    colors[i] := RGBToColor(
    Trunc(255 * (1 - i / numberofcolors)),   // Red component
    Trunc(255 * Abs(Sin(i))),                // Green component
    Trunc(255 * (i / numberofcolors))        // Blue component
    );
  end;
end;

function TForm1.X(a, b, h, t: Double): Double;
begin
  Result := ((a + b) * Cos(t) - h * Cos(t * (a + b) / b)) / (a + b + h);
end;

function TForm1.Y(a, b, h, t: Double): Double;
begin
  Result := ((a + b) * Sin(t) - h * Sin(t * (a + b) / b)) / (a + b + h);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  if Sender is TForm then
  begin
    generatecolors;
    DrawEpitrochoid(PaintBox1.Canvas, 19, 11, 13, 0.05);
  end;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  a, b, h, dt: Double;
begin
  if sender is TPaintBox then
  begin
    If Not PaintingFinished then exit;
    PaintingFinished:=False;
    a := seA.Value;
    b := seB.Value;
    h := seH.Value;
    dt := seFloatDT.Value;
    with PaintBox1.Canvas do
    begin
      Brush.Color := cbBackcolor.ButtonColor;
      FillRect(0, 0, PaintBox1.Width, PaintBox1.Height);
      Pen.Color := cbLinecolor.ButtonColor;
      Pen.Width := seLinewidth.Value;
      DrawEpitrochoid(PaintBox1.Canvas, a, b, h, dt);
    end;
    PaintingFinished:=true;
  end;
end;

procedure TForm1.seAChange(Sender: TObject);
begin
  if Sender is TSpinEdit then PaintBox1.Invalidate;
end;

procedure TForm1.seBChange(Sender: TObject);
begin
  if Sender is TSpinEdit then PaintBox1.Invalidate;
end;

procedure TForm1.seFloatDTChange(Sender: TObject);
begin
  if Sender is TFloatSpinEdit then PaintBox1.Invalidate;
end;

procedure TForm1.seHChange(Sender: TObject);
begin
   if Sender is TSpinEdit then PaintBox1.Invalidate;
end;

procedure TForm1.cbLinecolorColorChanged(Sender: TObject);
begin
  if Sender is TColorButton then PaintBox1.Invalidate;
end;

procedure TForm1.cbBackcolorColorChanged(Sender: TObject);
begin
  if Sender is TColorButton then PaintBox1.Invalidate;
end;

procedure TForm1.chkBoxCycleColorChange(Sender: TObject);
begin
  if Sender is TCheckBox then PaintBox1.Invalidate;
end;

procedure TForm1.chkDrawCenterLineChange(Sender: TObject);
begin
  if Sender is TCheckBox then PaintBox1.Invalidate;
end;

procedure TForm1.chkMergeChange(Sender: TObject);
begin
  if Sender is TCheckBox then PaintBox1.Invalidate;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  If Sender is TButton then Animate:=Not Animate;
end;

procedure TForm1.seLinewidthChange(Sender: TObject);
begin
  if Sender is TSpinEdit then PaintBox1.Invalidate;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
procedure CycleCtrl(C:TObject);
begin
  if c is TSpinEdit then
  begin
    with c as TSpinEdit do
    begin
      if Value=MaxValue then Value:=MinValue
      else Value:=Value+1;
    end;
  end;
  if c is TFloatSpinEdit then
  begin
    with c as TFloatSpinEdit do
    begin
      if Value=MaxValue then Value:=MinValue
      else Value:=Value+Increment;
    end;
  end;
end;

begin
  If Sender is TTimer then
  begin
    if PaintingFinished then
    begin
      If Animate then
      begin
        if chkBoxA.Checked then CycleCtrl(seA);
        if chkBoxB.Checked then CycleCtrl(seB);
        if chkBoxH.Checked then CycleCtrl(seH);
        if chkBoxDT.Checked then CycleCtrl(seFloatDT);
        PaintBox1.Repaint;
      end;
    end;
  end;
end;

procedure TForm1.trkBUpdateSpeedChange(Sender: TObject);
begin
  if Sender is TTrackBar then timer1.Interval:=trkBUpdateSpeed.Position;
end;

procedure TForm1.DrawEpitrochoid(ACanvas: TCanvas; a, b, h, dt: Double);
var
  scale, stop_t, t: Double;
  pt0, pt1,fp: TPoint;

procedure DrawIt(CenterLineOnly:Boolean);
begin
   // Calculate the stop value for t.
  stop_t := b * 2 * Pi;
  // Scale.
  scale := Min(PaintBox1.ClientWidth * 0.45, PaintBox1.ClientHeight * 0.45);
  // Find the first point on the curve.
  t := 0;
  repeat
    pt0 := Point(Round(X(a, b, h, t) * scale) + Round(PaintBox1.ClientWidth / 2),
                 Round(Y(a, b, h, t) * scale) + Round(PaintBox1.ClientHeight / 2));
    t := t + dt;
  until (t > stop_t) or ((pt0.X >= 0) and (pt0.Y >= 0) and (pt0.X < PaintBox1.ClientWidth) and (pt0.Y < PaintBox1.ClientHeight));
  fp:=pt0;
  ACanvas.Pen.Color:=cblinecolor.ButtonColor;
  if ((Not CenterLineOnly) and (chkBoxCycleColor.Checked)) then ACanvas.Pen.Color:=colors[colorcounter];
  ACanvas.MoveTo(fp.X, fp.Y);
  while t <= stop_t do
  begin
    acanvas.Pen.Mode:=pmCopy;
    if ((Not CenterLineOnly) and (chkMerge.Checked)) then acanvas.Pen.Mode:=pmMerge;
    pt1 := Point(Round(X(a, b, h, t) * scale) + Round(PaintBox1.ClientWidth / 2),
                 Round(Y(a, b, h, t) * scale) + Round(PaintBox1.ClientHeight / 2));

    if CenterLineOnly then ACanvas.Pen.Width:=trunc(seLineWidth.Value*0.175)
    else ACanvas.Pen.Width:=seLineWidth.Value;
    ACanvas.LineTo(pt1.X, pt1.Y);
    ACanvas.Pen.Color:=cblinecolor.ButtonColor;
    if Not CenterLineOnly then
    begin
      if chkBoxCycleColor.Checked then
      begin
        inc(colorcounter);
        if colorcounter>numberofcolors then colorcounter:=0;
        ACanvas.Pen.Color:=colors[colorcounter];
      end;
    end;
    pt0 := pt1;
    t := t + dt;
  end;
  ACanvas.LineTo(fp.X, fp.Y);
end;

begin
  DrawIt(False);
  if ((seLineWidth.Value>10) and (chkDrawCenterLine.Checked)) then DrawIt(True);
end;

end.
