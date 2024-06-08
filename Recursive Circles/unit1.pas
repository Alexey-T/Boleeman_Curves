unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Spin,
  ColorBox, StdCtrls, Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    cbBordercolor: TColorButton;
    cbLargest: TColorButton;
    cbVertCircleBottom: TColorButton;
    cbHorizCircleRight: TColorButton;
    chkFiller: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    PaintBox1: TPaintBox;
    seDepth: TSpinEdit;
    seInitialSize: TSpinEdit;
    cbVertCircleTop: TColorButton;
    cbHorizCircleLeft: TColorButton;
    seBorderLineWidth: TSpinEdit;
    procedure cbBordercolorColorChanged(Sender: TObject);
    procedure cbHorizCircleLeftColorChanged(Sender: TObject);
    procedure cbHorizCircleRightColorChanged(Sender: TObject);
    procedure cbLargestColorChanged(Sender: TObject);
    procedure cbVertCircleTopColorChanged(Sender: TObject);
    procedure cbVertCircleBottomColorChanged(Sender: TObject);
    procedure chkFillerChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure ControlChange(Sender: TObject);
    procedure seDepthChange(Sender: TObject);
    procedure seInitialSizeChange(Sender: TObject);
    procedure seBorderLineWidthChange(Sender: TObject);
  private
    procedure DrawCircle(g: TCanvas; x, y, r: Double; BorderColor, FillColor: TColor; NoFill: Boolean);
    procedure DrawRecursiveCircle(g: TCanvas; x, y, r: Double; depth: Integer);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  seDepth.MinValue := 1;
  seDepth.MaxValue := 10;
  seDepth.Value := 3;

  seInitialSize.MinValue := 10;
  seInitialSize.MaxValue := 500;
  seInitialSize.Value := 350;

  seBorderLineWidth.MinValue := 1;
  seBorderLineWidth.MaxValue := 10;
  seBorderLineWidth.Value := 4;

  cbVertCircleTop.ButtonColor := clRed;         // Default top vertical circle color
  cbVertCircleBottom.ButtonColor := clYellow;   // Default bottom vertical circle color
  cbHorizCircleLeft.ButtonColor := clAqua;      // Default left horizontal circle color
  cbHorizCircleRight.ButtonColor := $00FF8000;  // Default right horizontal circle color
  cbBordercolor.ButtonColor := clBlack;         // Default border color
  cbLargest.ButtonColor := $0080FF80;           // Default largest circle fill color
end;

procedure TForm1.cbBordercolorColorChanged(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.cbHorizCircleLeftColorChanged(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.cbHorizCircleRightColorChanged(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.cbLargestColorChanged(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.cbVertCircleTopColorChanged(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.cbVertCircleBottomColorChanged(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.chkFillerChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  DrawRecursiveCircle(PaintBox1.Canvas, PaintBox1.Width div 2, PaintBox1.Height div 2, seInitialSize.Value, seDepth.Value);
end;

procedure TForm1.ControlChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.seDepthChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.seInitialSizeChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.seBorderLineWidthChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.DrawCircle(g: TCanvas; x, y, r: Double; BorderColor, FillColor: TColor; NoFill: Boolean);
begin
  g.Pen.Color := BorderColor;
  g.Pen.Width := seBorderLineWidth.Value;
  if NoFill then
    g.Brush.Style := bsClear
  else
  begin
    g.Brush.Color := FillColor;
    g.Brush.Style := bsSolid;
  end;
  g.Ellipse(Round(x - r), Round(y - r), Round(x + r), Round(y + r));
end;

procedure TForm1.DrawRecursiveCircle(g: TCanvas; x, y, r: Double; depth: Integer);
var
  new_r: Double;
begin
  if depth = 0 then
    Exit;

  DrawCircle(g, x, y, r, cbBordercolor.ButtonColor, cbLargest.ButtonColor, chkFiller.Checked);

  new_r := r / 2;

  DrawCircle(g, x - new_r, y, new_r, cbBordercolor.ButtonColor, cbHorizCircleLeft.ButtonColor, False);
  DrawCircle(g, x + new_r, y, new_r, cbBordercolor.ButtonColor, cbHorizCircleRight.ButtonColor, False);

  DrawCircle(g, x, y - new_r, new_r, cbBordercolor.ButtonColor, cbVertCircleTop.ButtonColor, False);
  DrawCircle(g, x, y + new_r, new_r, cbBordercolor.ButtonColor, cbVertCircleBottom.ButtonColor, False);

  DrawRecursiveCircle(g, x - new_r, y, new_r, depth - 1);
  DrawRecursiveCircle(g, x + new_r, y, new_r, depth - 1);
  DrawRecursiveCircle(g, x, y - new_r, new_r, depth - 1);
  DrawRecursiveCircle(g, x, y + new_r, new_r, depth - 1);
end;

end.

