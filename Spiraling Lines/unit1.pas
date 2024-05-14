unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Math,
  StdCtrls, ComCtrls, Spin,bgrabitmap,BGRABitmapTypes;

const res=21;

type

//  TPointArray = array of TPointF;
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
    seLinewidth: TSpinEdit;
    AShape: TShape;
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
    procedure FormCreate(Sender: TObject);
    procedure AShapePaint(Sender: TObject);
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
    sp:array[0..50] of integer;
    a: array of Real;
    colors: array of TBGRAPixel;
    masterbmp,bmp:tbgrabitmap;
    ti,fps:int64;
    procedure generatecolors;
    procedure AnimatedCurvyLines(Const TC:TCanvas);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.generatecolors;
var i:integer;
begin
  SetLength(colors, N+1);
  for i := 0 to N  do
  begin
    colors[i] := RGBToColor(
      Trunc(255 * (1 - i / N)),   // Red component
      Trunc(255 * Abs(Sin(i))),   // Green component
      Trunc(255 * (i / N))        // Blue component
    );
    if chkStagger.checked then sp[i]:=i else sp[i]:=0;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var i:integer;
begin
  if sender is tform then
  begin
    Randomize;
    for i:=0 to res do sp[i]:=i;//random(res);//i;
    c:=0;
    S := res;
    N := res;
    W := 2;
    PaintingFinished:=true;
    bmp:=tbgrabitmap.Create(ashape.Width,ashape.height,AShape.Brush.Color);
    masterbmp:=tbgrabitmap.Create(ashape.Width,ashape.height,AShape.Brush.Color);
    chkEnableAnimation.Checked := False;
    chkEnableAnimation.Refresh;
    tbSpeedControl.Position := 54;
    tbSpeedControl.Refresh;
    ti:=gettickcount64;
    fps:=0;
    setlength(a,s+1);
    k := Random(360) * Pi / 180;
    generatecolors;
    AnimatedCurvyLines(AShape.Canvas);
  end;
end;



procedure TForm1.chkCyclecolorsChange(Sender: TObject);
begin
  if sender is tcheckbox then
  begin
    if not chkCyclecolors.Checked then currentColorIndex := 0;
    AShape.Paint;
  end;
end;

procedure TForm1.chkInOutChange(Sender: TObject);
begin
  if sender is tcheckbox then AShape.Paint;
end;

procedure TForm1.chkStaggerChange(Sender: TObject);
begin
  if sender is tcheckbox then generatecolors;
end;

procedure TForm1.cbSinglecolorColorChanged(Sender: TObject);
begin
  if sender is tcolorbutton then AShape.Paint;
end;

procedure TForm1.AShapePaint(Sender: TObject);
begin
  if sender is tshape then AnimatedCurvyLines(AShape.Canvas);
end;

procedure TForm1.chkEnableAnimationChange(Sender: TObject);
begin
  if sender is tcheckbox then AShape.Paint;
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
  if sender is tspinedit then AShape.paint;
end;

procedure TForm1.seSegmentsChange(Sender: TObject);
begin
  if sender is TSpinEdit then
  begin
    N:= seSegments.Value;
    s:=n;
    setlength(a,s+1);
    generatecolors;
    AShape.paint;
  end;
end;

procedure TForm1.seLinewidthChange(Sender: TObject);
begin
  if sender is TSpinEdit then  AShape.paint;
end;

procedure TForm1.shpSetColorMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if colordialog1.Execute then shpSetColor.Brush.Color:=colordialog1.Color;
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
  if sender is TTimer then if ((chkEnableAnimation.Checked) and (PaintingFinished)) then AShape.Paint;
end;

procedure TForm1.AnimatedCurvyLines(Const TC:TCanvas);
var
  i, j: Integer;
  upd:boolean;
begin
  // check to stop recurring
  if not PaintingFinished then exit;
  PaintingFinished:=false;
  if chkEnableAnimation.Checked then k := k + kIncrement * Pi / 180;
  if (bmp.Width<>AShape.Width) or (bmp.Height<>AShape.Height) then
  begin
    bmp.Free;
    masterbmp.Free;
    bmp:=tbgrabitmap.Create(ashape.Width,ashape.height,AShape.Brush.Color);
    bmp:=tbgrabitmap.Create(ashape.Width,ashape.height,AShape.Brush.Color);
  end;
  masterbmp.Draw(bmp.Canvas,0,0);
  // adjust len to better fit screen
  len := Min(AShape.Width, AShape.Height)/n/(2.0-(1.0*((n-7)/27)));
  bmp.Canvas.Pen.Width := seLinewidth.Value;
  bmp.Canvas.Brush.Color := clBlack;
  bmp.Canvas.AntialiasingMode:=amOn;
  a[1] := a[1] + Sin(k) / 15;
  for i := 2 to N do a[i] := a[i] + (a[i - 1] - a[i]) * 0.1;
  d := 2 * Pi / S;
  c:=0;
  for j := 0 to S - 1 do
  begin
    c:=sp[j];
    x := 0.5 * AShape.Width;
    y := 0.5 * AShape.Height;
    for i := 2 to N do
    begin
      if chkInOut.checked then inc(c) else dec(c);
      if c>high(colors) then c:=low(colors);
      if c<low(colors) then c:=high(colors);
      if chkCyclecolors.Checked then bmp.Canvas.Pen.Color:= colors[C]
      else bmp.Canvas.Pen.Color:= shpSetColor.Brush.Color;
      sincos(j * d + a[i],ty,tx);    // twice as fast
      tx := x + tx * len;
      ty := y + ty * len;
      bmp.Canvas.Line(Round(x), Round(y), Round(tx), Round(ty));
      x := tx;
      y := ty;
    end;
    upd:=seCycleSlow.Value=0;
    if not upd then upd:=co mod seCycleSlow.Value=0;
    if upd then
    begin
      if chkInOut.checked then sp[j]:=sp[j]+1
      else sp[j]:=c-1;
      if sp[j]<low(colors) then sp[j]:=high(colors);
      if sp[j]>high(colors) then sp[j]:=low(colors);
    end;
  end;

  inc(co);
  if co>100 then
  begin
    // keep alive;
    application.ProcessMessages;
    co:=0;
  end;
  bmp.Draw(tc,0,0);
  PaintingFinished:=true;
  inc(fps);
  if gettickcount64-ti>1000 then
  begin
    lblfps.caption:='FPS: '+inttostr(fps);
    lblfps.Invalidate;
    fps:=0;
    ti:=gettickcount64;
  end;
end;

end.
