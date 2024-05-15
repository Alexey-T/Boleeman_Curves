unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Math,
  StdCtrls, ComCtrls, Spin,bgrabitmap,BGRABitmapTypes;

const res=21;

type

  { TForm1 }

  TForm1 = class(TForm)
    chkCyclecolors: TCheckBox;
    chkInOut: TCheckBox;
    chkEnableanimation: TCheckBox;
    lblInOut1: TLabel;
    chkStagger: TCheckBox;
    ColorDialog1: TColorDialog;
    lblAnimate: TLabel;
    lblInOut: TLabel;
    lblCycleColorss: TLabel;
    lblLineWidth: TLabel;
    lblCycleSpeed: TLabel;
    lblSpeed: TLabel;
    lbl_Segments: TLabel;
    lblColor: TLabel;
    lblfps: TLabel;
    cntrsPanel: TPanel;
    dispScrollBox: TScrollBox;
    seLinewidth: TSpinEdit;
    seSegments: TSpinEdit;
    seCycleSlow: TSpinEdit;
    shpSetColor: TShape;
    shpcntrols: TShape;
    tbSpeedcontrol: TTrackBar;
    Timer1: TTimer;
    procedure cbSinglecolorColorChanged(Sender: TObject);
    procedure chkCyclecolorsChange(Sender: TObject);
    procedure chkInOutChange(Sender: TObject);
    procedure chkStaggerChange(Sender: TObject);
    procedure dispScrollBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure dispScrollBoxPaint(Sender: TObject);
    procedure chkEnableAnimationChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure seCycleSlowChange(Sender: TObject);
    procedure seSegmentsChange(Sender: TObject);
    procedure seLinewidthChange(Sender: TObject);
    procedure shpSetColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tbSpeedcontrolChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    PaintingFinished:Boolean;
    S, N, W,C,co: Integer;
    currentColorIndex: Integer;
    x, y, tx, ty, d, len, k: Real;
    kIncrement: Real;
    sp:array of integer;
    a: array of Real;
    colors: array of TBGRAPixel;
    masterbmp,bmp:tbgrabitmap;
    ti,fps:int64;
    procedure generatecolors;
    procedure AnimatedCurvyLines;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.generatecolors;
var i:integer;

function fadecolor(f,t:tcolor;d:single):tcolor;
begin
  f:=ColorToRGB(f);
  t:=ColorToRGB(t);
  result:=RGBToColor(Round(red(f)+(red(t)-red(f))*d),Round(green(f)+(green(t)-green(f))*d),Round(blue(f)+(blue(t)-blue(f))*d));
end;

begin
  SetLength(colors, N+1);
  SetLength(sp, N+1);
  if chkCyclecolors.Checked then
  begin;
    for i := 0 to N  do
    begin
      colors[i] := RGBToColor(
      Trunc(255 * (1 - i / N)),   // Red component
      Trunc(255 * Abs(Sin(i))),   // Green component
      Trunc(255 * (i / N))        // Blue component
      );
      if chkStagger.checked then sp[i]:=i else sp[i]:=0;
    end;
  end
  else
  begin
    for i:=0 to n do
    begin
      colors[i]:=fadecolor(shpSetColor.Brush.Color,dispScrollBox.Color,(i+1)/(n+6));
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var i:integer;
begin
  if sender is tform then
  begin
    Randomize;
    seSegments.Value:=res;
    c:=0;
    co:=0;
    S := res;
    N := res;
    W := 2;
    setlength(sp,n+1);
    for i:=0 to high(sp) do sp[i]:=0;
    PaintingFinished:=true;
    bmp:=tbgrabitmap.Create(dispScrollBox.Width,dispScrollBox.height,dispScrollBox.Brush.Color);
    masterbmp:=tbgrabitmap.Create(dispScrollBox.Width,dispScrollBox.height,dispScrollBox.Brush.Color);
    chkEnableAnimation.Checked := False;
    chkEnableAnimation.Refresh;
    tbSpeedControl.Position := 54;
    tbSpeedControl.Refresh;
    ti:=gettickcount64;
    fps:=0;
    setlength(a,s+1);
    k := Random(360) * Pi / 180;
    generatecolors;
    AnimatedCurvyLines;
  end;
end;



procedure TForm1.chkCyclecolorsChange(Sender: TObject);
begin
  if sender is tcheckbox then
  begin
    if not chkCyclecolors.Checked then currentColorIndex := 0;
    generatecolors;
    dispScrollBox.Repaint;
  end;
end;

procedure TForm1.chkInOutChange(Sender: TObject);
begin
  if sender is tcheckbox then dispScrollBox.rePaint;
end;

procedure TForm1.chkStaggerChange(Sender: TObject);
begin
  if sender is tcheckbox then generatecolors;
end;

procedure TForm1.dispScrollBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if sender is TScrollBox then
  begin
    if button=mbright then
    begin
      if colordialog1.Execute then
      begin
        MasterBmp.FillRect(0,0,MasterBmp.Width,MasterBmp.Height,colordialog1.Color,dmset);
        dispScrollBox.Color:=colordialog1.Color;
        dispScrollBox.Invalidate;
      end;
    end;
  end;
end;

procedure TForm1.cbSinglecolorColorChanged(Sender: TObject);
begin
  if sender is tcolorbutton then dispScrollBox.rePaint;
end;

procedure TForm1.dispScrollBoxPaint(Sender: TObject);
begin
  if sender is tscrollbox then AnimatedCurvyLines;
end;

procedure TForm1.chkEnableAnimationChange(Sender: TObject);
begin
  if sender is tcheckbox then dispScrollBox.rePaint;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if sender is tform then
  begin
    masterbmp.Free;
    bmp.free;
  end;
end;

procedure TForm1.seCycleSlowChange(Sender: TObject);
begin
  if sender is tspinedit then dispScrollBox.repaint;
end;

procedure TForm1.seSegmentsChange(Sender: TObject);
begin
  if sender is TSpinEdit then
  begin
    N:= seSegments.Value;
    s:=n;
    setlength(a,s+1);
    generatecolors;
    dispScrollBox.repaint;
  end;
end;

procedure TForm1.seLinewidthChange(Sender: TObject);
begin
  if sender is TSpinEdit then  dispScrollBox.repaint;
end;

procedure TForm1.shpSetColorMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if colordialog1.Execute then
  begin
    shpSetColor.Brush.Color:=colordialog1.Color;
    generatecolors;
  end;
end;

procedure TForm1.tbSpeedControlChange(Sender: TObject);
begin
  if sender is TTrackBar then
  begin
    kIncrement := (tbSpeedControl.Max - tbSpeedControl.Position + 1) / 100;
    timer1.Interval:=max(5,tbSpeedControl.Position*2);
  end;
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if sender is TTimer then if ((chkEnableAnimation.Checked) and (PaintingFinished)) then dispScrollBox.rePaint;
end;

procedure TForm1.AnimatedCurvyLines;
var
  i, j, r: Integer;
  f: Single;
  upd: Boolean;
begin
  // Check to stop recurring
  if not PaintingFinished then Exit;
  PaintingFinished := False;
  // Adjust parameters for animation
  if chkEnableAnimation.Checked then k:=k+kIncrement*Pi/180;
  // Recreate bitmap if size changed
  if (bmp.Width<>dispScrollBox.Width) or (bmp.Height<>dispScrollBox.Height) then
  begin
    bmp.SetSize(dispScrollBox.Width, dispScrollBox.Height);
    masterbmp.SetSize(dispScrollBox.Width, dispScrollBox.Height);
  end
  else bmp.Assign(masterbmp);
  // Adjust len to better fit screen dimensions
  r:=seSegments.MaxValue-seSegments.MinValue;
  f:=1/r;
  len:=Min(dispScrollBox.Width,dispScrollBox.Height)/n/(1.8-(1.0*(f+(n-seSegments.MinValue+1)/r)));
  bmp.Canvas.Pen.Width:=seLinewidth.Value;
  a[1]:=a[1]+Sin(k)/15;
  for i:=2 to N do a[i]:=a[i]+(a[i-1]-a[i])*0.1;
  d:=2*Pi/S;
 // co:=0;
  for j:=0 to S-1 do
  begin
    c:=sp[j];
    x:=0.5*dispScrollBox.Width;
    y:=0.5*dispScrollBox.Height;
    for i:=2 to N do
    begin
      //draw a line
      if chkInOut.Checked then Inc(c) else Dec(c);
      c:=(c+Length(Colors)) mod Length(Colors);
      if chkCyclecolors.Checked then bmp.Canvas.Pen.Color:= colors[C]
      else bmp.Canvas.Pen.Color:= shpSetColor.Brush.Color;
      bmp.Canvas.Pen.Color:=Colors[c];
      tx:=x+cos(j*d+a[i])*len;
      ty:=y+sin(j*d+a[i])*len;
      bmp.Canvas.Line(Round(x),Round(y),Round(tx),Round(ty));
      x:=tx;
      y:=ty;
    end;
    // Update colors
    upd:=seCycleSlow.Value=0;
    if not upd then upd:=co mod seCycleSlow.Value=0;
    if upd then
    begin
      if chkInOut.Checked then sp[j]:=sp[j]+1 else sp[j]:=c-1;
      if sp[j]<Low(Colors) then sp[j]:=High(Colors);
      if sp[j]>High(Colors) then sp[j]:=Low(Colors);
    end;
  end;
  Inc(co);
  if co>20 then
  begin
    // Keep Alive
    Application.ProcessMessages;
    co:=0;
  end;
  bmp.Draw(dispScrollBox.Canvas,0,0);
  PaintingFinished:=True;
  Inc(fps);
  if GetTickCount64-ti>1000 then
  begin
    lblfps.Caption:='FPS: '+IntToStr(fps);
    lblfps.Invalidate;
    fps:=0;
    ti:=GetTickCount64;
  end;
end;


end.
