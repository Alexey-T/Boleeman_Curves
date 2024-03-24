unit Unitcirclefractal;

{$mode objfpc}{$H+}

interface

uses
 Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
 Spin, ComCtrls, Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    cbBackcolor: TColorButton;
    cbBorderpencolor: TColorButton;
    cbFillcolor: TColorButton;
    DrawPanel: TPanel;
    lblFillcolor: TLabel;
    lblBordercolor: TLabel;
    lblBackcolor: TLabel;
    lblRadialshift: TLabel;
    lblNumcircs: TLabel;
    lblRecLevel: TLabel;
    SERecursion: TSpinEdit;
    se_NumCircles: TSpinEdit;
    TrackBar1: TTrackBar;
    procedure cbBackcolorColorChanged(Sender: TObject);
    procedure cbBorderpencolorColorChanged(Sender: TObject);
    procedure cbFillcolorColorChanged(Sender: TObject);
    procedure FormResize(Sender: TObject);
  procedure Fractal();
  procedure DrawCircle(X, Y, R: Integer; n: Integer; k: Single);
  procedure SERecursionChange(Sender: TObject);
  procedure se_NumCirclesChange(Sender: TObject);
  procedure TrackBar1Change(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormResize(Sender: TObject);
begin
 Fractal();
end;

procedure TForm1.Fractal;
var
	m, n: Integer;
begin
 n := SERecursion.Value;
 DrawPanel.Canvas.AntialiasingMode := amOn;
 //Backcolour
 DrawPanel.Canvas.Brush.Color := cbBackcolor.ButtonColor;
 m := min(DrawPanel.ClientWidth, DrawPanel.ClientHeight) div 6 ;
 DrawPanel.Canvas.FillRect(DrawPanel.ClientRect);
 DrawCircle(DrawPanel.ClientWidth div 2, DrawPanel.ClientHeight div 2, m, n - 1, 1);
end;

procedure TForm1.DrawCircle(X, Y, R: Integer; n: Integer; k: Single);
var
  int1: Integer;
begin


  if n < 1 then
  begin
    DrawPanel.Canvas.Pen.Color := clBlack;
    DrawPanel.Canvas.Brush.Color := TColor($FF1493);
    DrawPanel.Canvas.Pen.Width := 2;
    DrawPanel.Canvas.Ellipse(X - R, Y - R, X + R, Y + R);

  end
  else
  begin
    DrawPanel.Canvas.Pen.Width := 3;
    DrawPanel.Canvas.Pen.Color := cbBorderpencolor.ButtonColor;
    //DrawPanel.Canvas.Brush.Color := TColor($FFD700);
    DrawPanel.Canvas.Brush.Color := cbFillcolor.ButtonColor;
    DrawPanel.Canvas.Ellipse(X - R, Y - R, X + R, Y + R);
    for int1 := 1 to se_NumCircles.value do
      DrawCircle(Round(X + (TrackBar1.Position / 100) * R * Cos((int1 - 1) * Pi / (0.5*se_NumCircles.value))),
                 Round(Y + (TrackBar1.Position / 100) * R * Sin((int1 - 1) * Pi / (0.5*se_NumCircles.value))),
                 Round(R / 3.8), n - 1, k);
  end;
end;

procedure TForm1.SERecursionChange(Sender: TObject);
begin
 Fractal();
end;

procedure TForm1.se_NumCirclesChange(Sender: TObject);
begin
 Fractal();
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
 Fractal();
end;

procedure TForm1.cbBackcolorColorChanged(Sender: TObject);
begin
 Fractal();
end;

procedure TForm1.cbBorderpencolorColorChanged(Sender: TObject);
begin
 Fractal();
end;

procedure TForm1.cbFillcolorColorChanged(Sender: TObject);
begin
 Fractal();
end;

end.

