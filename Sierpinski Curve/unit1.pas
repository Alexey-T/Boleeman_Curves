unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Spin, Math,
  StdCtrls, Buttons;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    cbLineColor: TColorButton;
    cbBackColor: TColorButton;
    chkCycleColors: TCheckBox;
    chkMerge: TCheckBox;
    chkSquare: TCheckBox;
    ColorDialog1: TColorDialog;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    seDepth: TSpinEdit;
    seLineWidth: TSpinEdit;
    seDrawDelay: TSpinEdit;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Timer1: TTimer;
    procedure Button1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cbBackColorColorChanged(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure PaintBox1Resize(Sender: TObject);
    procedure seDepthChange(Sender: TObject);
    procedure seDrawDelayChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure Sierpinski(depth: Integer; dx, dy: Double);
    procedure SierpA(depth: Integer; dx, dy: Double; var x, y: Double);
    procedure SierpB(depth: Integer; dx, dy: Double; var x, y: Double);
    procedure SierpC(depth: Integer; dx, dy: Double; var x, y: Double);
    procedure SierpD( depth: Integer; dx, dy: Double; var x, y: Double);
    procedure DrawRel(var x, y: Double; dx, dy: Double);
    procedure generatecolors;
    procedure DrawTheCurve;
  public

  end;

var
  RequiresRedraw:Boolean=True;
  spworking:boolean=false;
  keepAliveCounter:Integer=0;
  Form1: TForm1;
  tmpbmp:TBitmap;
  colors: array of TColor;
  NumberOfColors:Integer=89;
  ColorCounter:Integer=0;
  msDelay:Integer=0;

implementation

{$R *.lfm}

procedure TForm1.generatecolors;
var i:integer;
begin
  SetLength(colors, NumberOfColors+1);
  for i := 0 to NumberOfColors  do
  begin
    colors[i] := RGBToColor(
    Trunc(255 * (1 - i / NumberOfColors)),   // Red component
    Trunc(255 * Abs(Sin(i))),                // Green component
    Trunc(255 * (i / NumberOfColors))        // Blue component
    );
  end
end;

procedure waitforinterval(ms:Integer);
var t:qword;
begin
  inc(keepAliveCounter);
  if keepAliveCounter>100 then
  begin
    keepAliveCounter:=0;
    Application.ProcessMessages;
  end;
  if ms<1 then exit;
  t:=gettickcount64;
  while gettickcount64-t<ms do
  begin
    inc(keepAliveCounter);
    if keepAliveCounter>100 then
    begin
      keepAliveCounter:=0;
      Application.ProcessMessages;
    end;
  end;
  form1.PaintBox1.Canvas.Draw(0,0,tmpbmp);
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  form1.PaintBox1.Canvas.Draw(0,0,tmpbmp);
end;

procedure TForm1.PaintBox1Resize(Sender: TObject);
begin
  tmpbmp.SetSize(PaintBox1.Width,PaintBox1.Height);
  RequiresRedraw:=True;
  msDelay:=0;
end;

procedure TForm1.seDepthChange(Sender: TObject);
begin
  RequiresRedraw:=true;
  msDelay:=0;
end;

procedure TForm1.seDrawDelayChange(Sender: TObject);
begin
  msDelay:=seDrawDelay.Value;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  If ((RequiresRedraw) and (spworking=False)) then DrawTheCurve;
end;


procedure TForm1.Button1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  msDelay:=0;
end;

procedure TForm1.DrawTheCurve;
var
  depth: Integer;
  dx, dy: Double;
begin
  depth := seDepth.Value;
  dx := PaintBox1.Width / Power(2, depth - 1) / 8;
  dy := PaintBox1.Height / Power(2, depth - 1) / 8;
  // Draw the curve
  Sierpinski(depth, dx, dy);
end;

procedure TForm1.Button1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  sleep(100);   // allow curve to finish ust in case
  DrawTheCurve;
end;

procedure TForm1.cbBackColorColorChanged(Sender: TObject);
begin
  Paintbox1.Color:=cbBackColor.ButtonColor;
  RequiresRedraw:=true;
  msDelay:=0;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  RequiresRedraw:=False;
  msDelay:=0;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Paintbox1.Color:=cbBackColor.ButtonColor;
  generatecolors;
  tmpbmp:=tbitmap.Create;
  tmpbmp.Canvas.Brush.Color:=PaintBox1.Color;
  tmpbmp.Canvas.Brush.Style:=bsSolid;
  tmpbmp.SetSize(PaintBox1.Width,PaintBox1.Height);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  tmpbmp.Free;
end;

procedure TForm1.Sierpinski( depth: Integer; dx, dy: Double);
var
  x, y: Double;
begin
  if spworking then exit;
  RequiresRedraw:=false;
  msDelay:=seDrawDelay.Value;
  tmpbmp.Canvas.Brush.Color:=PaintBox1.Color;
  tmpbmp.Canvas.Brush.Style:=bsSolid;
  tmpbmp.Canvas.FillRect(0,0,PaintBox1.Width,PaintBox1.Height);
  x := 2 * dx;
  y := dy;
  spworking:=true;
  SierpA( depth, dx, dy, x, y);
  DrawRel( x, y, dx, dy);
  SierpB( depth, dx, dy, x, y);
  DrawRel( x, y, -dx, dy);
  SierpC( depth, dx, dy, x, y);
  DrawRel( x, y, -dx, -dy);
  SierpD( depth, dx, dy, x, y);
  DrawRel( x, y, dx, -dy);
  PaintBox1.Canvas.Draw(0,0,tmpbmp);
  spworking:=false;
end;

procedure TForm1.SierpA( depth: Integer; dx, dy: Double; var x, y: Double);
begin
  if depth > 0 then
  begin
    Dec(depth);
    SierpA( depth, dx, dy, x, y);
    DrawRel( x, y, dx, dy);
    SierpB( depth, dx, dy, x, y);
    DrawRel( x, y, 2 * dx, 0);
    SierpD( depth, dx, dy, x, y);
    DrawRel( x, y, dx, -dy);
    SierpA( depth, dx, dy, x, y);
  end;
end;

procedure TForm1.SierpB( depth: Integer; dx, dy: Double; var x, y: Double);
begin
  if depth > 0 then
  begin
    Dec(depth);
    SierpB( depth, dx, dy, x, y);
    DrawRel( x, y, -dx, dy);
    SierpC( depth, dx, dy, x, y);
    DrawRel( x, y, 0, 2 * dy);
    SierpA( depth, dx, dy, x, y);
    DrawRel( x, y, dx, dy);
    SierpB( depth, dx, dy, x, y);
  end;
end;

procedure TForm1.SierpC(depth: Integer; dx, dy: Double; var x, y: Double);
begin
  if depth > 0 then
  begin
    Dec(depth);
    SierpC( depth, dx, dy, x, y);
    DrawRel( x, y, -dx, -dy);
    SierpD( depth, dx, dy, x, y);
    DrawRel( x, y, -2 * dx, 0);
    SierpB( depth, dx, dy, x, y);
    DrawRel( x, y, -dx, dy);
    SierpC( depth, dx, dy, x, y);
  end;
end;

procedure TForm1.SierpD(depth: Integer; dx, dy: Double; var x, y: Double);
begin
  if depth > 0 then
  begin
    Dec(depth);
    SierpD( depth, dx, dy, x, y);
    DrawRel( x, y, dx, -dy);
    SierpA( depth, dx, dy, x, y);
    DrawRel( x, y, 0, -2 * dy);
    SierpC( depth, dx, dy, x, y);
    DrawRel(x, y, -dx, -dy);
    SierpD( depth, dx, dy, x, y);
  end;
end;

procedure TForm1.DrawRel(var x, y: Double; dx, dy: Double);
begin
  tmpbmp.Canvas.Pen.Width := seLineWidth.Value;
  if chkCycleColors.Checked then tmpbmp.Canvas.Pen.Color :=colors[ColorCounter]
    else tmpbmp.Canvas.Pen.Color := cbLineColor.ButtonColor;
  Inc(ColorCounter);If ColorCounter>NumberOfColors then ColorCounter:=0;
  if chkSquare.checked then tmpbmp.Canvas.Pen.EndCap:=pecSquare
    else tmpbmp.Canvas.Pen.EndCap:=pecRound;//Square;
  if chkMerge.Checked then tmpbmp.Canvas.Pen.Mode:=pmMerge
    else tmpbmp.Canvas.Pen.Mode:=pmCopy;
  tmpbmp.Canvas.Line(Round(x), Round(y), Round(x + dx), Round(y + dy));
  x := x + dx;
  y := y + dy;
  waitforinterval(msDelay);
  if msDelay<> 0 then form1.PaintBox1.Canvas.Draw(0,0,tmpbmp);
end;

end.
