unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Math,
  Spin, ColorBox;

type
  { TForm1 }

  TForm1 = class(TForm)
    btnClear: TButton;
    ButtonAbort: TButton;
    ButtonGo: TButton;
    cbPixelColor: TColorButton;
    cbBackColor: TColorButton;
    FloatseValA: TFloatSpinEdit;
    FloatseValB: TFloatSpinEdit;
    FloatseValX: TFloatSpinEdit;
    FloatseValY: TFloatSpinEdit;
    FloatseScalePic: TFloatSpinEdit;
    FloatseSpan: TFloatSpinEdit;
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
    seValK: TSpinEdit;
    procedure btnClearClick(Sender: TObject);
    procedure ButtonAbortClick(Sender: TObject);
    procedure ButtonGoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure cbBackColorColorChanged(Sender: TObject);
    procedure cbPixelColorColorChanged(Sender: TObject);
  private
    Xs, Ys: Double;
    N, K: LongInt;
    A, B, X, Y, W, Z, Span, ScalePic: Double;
    bAbort: Boolean;
    PixelColor, BackColor: TColor;
    procedure Draw;
    procedure NextOrbit;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.ButtonGoClick(Sender: TObject);
begin
  Xs := PaintBox1.Width / 2;
  Ys := PaintBox1.Height / 2;
  N := 0;
  W := 0;
  Z := 0;
  bAbort := False;
  ButtonGo.Enabled := False;

  A := FloatseValA.Value;
  B := FloatseValB.Value;
  X := FloatseValX.Value;
  Y := FloatseValY.Value;
  Span := FloatseSpan.Value;
  ScalePic := FloatseScalePic.Value;
  K := seValK.Value;

  while (N < K) and (not bAbort) do
  begin
    Inc(N);
    Caption := 'Wait ... Rendering ' + IntToStr(N) + ' / ' + IntToStr(K);
    Draw;
    Application.ProcessMessages;
  end;

  ButtonGo.Enabled := True;
  Caption := 'Rendering Completed';
end;

procedure TForm1.ButtonAbortClick(Sender: TObject);
begin
  bAbort := True;
end;

procedure TForm1.btnClearClick(Sender: TObject);
begin
  PaintBox1.Canvas.Brush.Color := BackColor;
  PaintBox1.Canvas.FillRect(PaintBox1.ClientRect);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Randomize;

  PixelColor := clBlack;
  BackColor := $0080FFFF;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Brush.Color := BackColor;
  PaintBox1.Canvas.FillRect(PaintBox1.ClientRect);
end;

procedure TForm1.cbBackColorColorChanged(Sender: TObject);
begin

  BackColor := cbBackColor.ButtonColor;
  PaintBox1.Invalidate;
  ButtonGoClick(self);
end;

procedure TForm1.cbPixelColorColorChanged(Sender: TObject);
begin
  PixelColor := cbPixelColor.ButtonColor;
  ButtonGoClick(self);
end;

procedure TForm1.Draw;
var
  i: Integer;
  XCoord, YCoord: Integer;
begin

  for i := 1 to 2500 do
  begin
    Z := X;
    X := Y + W;
    NextOrbit;
    Y := W - Z;

    XCoord := Round(Xs + X * ScalePic);
    YCoord := Round(Ys + Y * ScalePic);

    XCoord := Min(Max(0, XCoord), PaintBox1.Width - 1);
    YCoord := Min(Max(0, YCoord), PaintBox1.Height - 1);

    PaintBox1.Canvas.Pixels[XCoord, YCoord] := PixelColor;
  end;
end;

procedure TForm1.NextOrbit;
begin
  if X > Span then
    W := A * X + B * (X - 1)
  else if X < -Span then
    W := A * X + B * (X + 1)
  else if (X < Span) and (X > -Span) then
    W := A * X;
end;

end.
