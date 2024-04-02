unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Spin,
  StdCtrls, Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnSave: TButton;
    cbBackcolor: TColorButton;
    cbLinecolor: TColorButton;
    lblRecursLevel: TLabel;
    lblBackcolor: TLabel;
    lblLinewidth: TLabel;
    lblLineColor: TLabel;
    lblZoom: TLabel;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    seLevel: TSpinEdit;
    seScale: TSpinEdit;
    seLinewidth: TSpinEdit;
    procedure btnSaveClick(Sender: TObject);
    procedure cbBackcolorClick(Sender: TObject);
    procedure cbBackcolorColorChanged(Sender: TObject);
    procedure cbLinecolorColorChanged(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure seLevelChange(Sender: TObject);
    procedure seLinewidthChange(Sender: TObject);
    procedure seScaleChange(Sender: TObject);
  private
    procedure MakeHilbert(PaintBox: TPaintBox);
    procedure Hilbert(levelNumber: Integer; xStep, yStep: Single);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.Hilbert(levelNumber: Integer; xStep, yStep: Single);
begin
  if levelNumber > 1 then
    Hilbert(levelNumber - 1, yStep, xStep);
  PaintBox1.Canvas.LineTo(PaintBox1.Canvas.PenPos.X + Round(xStep), PaintBox1.Canvas.PenPos.Y + Round(yStep));
  if levelNumber > 1 then
    Hilbert(levelNumber - 1, xStep, yStep);
  PaintBox1.Canvas.LineTo(PaintBox1.Canvas.PenPos.X + Round(yStep), PaintBox1.Canvas.PenPos.Y + Round(xStep));
  if levelNumber > 1 then
    Hilbert(levelNumber - 1, xStep, yStep);
  PaintBox1.Canvas.LineTo(PaintBox1.Canvas.PenPos.X - Round(xStep), PaintBox1.Canvas.PenPos.Y - Round(yStep));
  if levelNumber > 1 then
    Hilbert(levelNumber - 1, -yStep, -xStep);
end;

procedure TForm1.MakeHilbert(PaintBox: TPaintBox);
var
  levelNumber: Integer;
  scaleSize, beginSize: Single;
begin
  PaintBox.Canvas.FillRect(PaintBox.ClientRect);
  PaintBox.Canvas.Pen.Width:= seLinewidth.Value;
  PaintBox.Canvas.Pen.Color:= cbLinecolor.ButtonColor;
  PaintBox.Color:= cbBackcolor.ButtonColor;
  levelNumber := seLevel.Value;

  if levelNumber <= 8 then
  begin
    if PaintBox.Height < PaintBox.Width then
      scaleSize := seScale.Value * PaintBox.Height / 100
    else
      scaleSize := seScale.Value * PaintBox.Width / 100;

    beginSize := scaleSize / (Power(2, levelNumber) - 1);

    PaintBox.Canvas.PenPos := Point(Round(0.5 * (PaintBox.Width - scaleSize)), Round(0.5 * (PaintBox.Height - scaleSize)));
    Hilbert(levelNumber, beginSize, 0);
  end
  else
    ShowMessage('Enter a smaller whole number');
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
    MakeHilbert(TPaintBox(Sender));
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

procedure TForm1.cbBackcolorClick(Sender: TObject);
begin
    paintbox1.Invalidate;
end;

procedure TForm1.cbBackcolorColorChanged(Sender: TObject);
begin
  paintbox1.Invalidate;
end;

procedure TForm1.cbLinecolorColorChanged(Sender: TObject);
begin
  paintbox1.Invalidate;
end;

procedure TForm1.seLevelChange(Sender: TObject);
begin
  paintbox1.Invalidate;
end;

procedure TForm1.seLinewidthChange(Sender: TObject);
begin
  paintbox1.Invalidate;
end;

procedure TForm1.seScaleChange(Sender: TObject);
begin
     paintbox1.Invalidate;
end;


end.

