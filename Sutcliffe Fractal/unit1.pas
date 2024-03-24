unit Unit1;

{$mode objfpc}{$H+}

{
  Name   : Sutcliffe Pentagon
  Desc   : example rendering a Sutcliffe Pentagon using the TFPCustomCanvas class helper changed to TPaintbox
  by     : TRon 2023 (Pay It Forward) changed to TPaintbox by Boleeman
  origin : code based on https://github.com/tex2e/p5js-pentagon
  thread : https://forum.lazarus.freepascal.org/index.php/topic,64632.0.html
}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Spin, StdCtrls, SutcliffePentagonHelper;

type

  { TForm1 }

  TForm1 = class(TForm)
    ColorButtonpencolor: TColorButton;
    ColorButtonbrushcolor: TColorButton;
    lblbrushcolor: TLabel;
    lblpencolor: TLabel;
    lblNest: TLabel;
    lblRadius: TLabel;
    lblStrutFactor: TLabel;
    lblStrutTarget: TLabel;
    lblSubStrutTarget: TLabel;
    lblNumSides: TLabel;
    SpinEditStrutFactor: TFloatSpinEdit;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    SpinEditNest: TSpinEdit;
    SpinEditRadius: TSpinEdit;
    SpinEditStrutTarget: TSpinEdit;
    SpinEditSubStrutTarget: TSpinEdit;
    SpinEditNumSides: TSpinEdit;
    procedure ColorButtonbrushcolorColorChanged(Sender: TObject);
    procedure ColorButtonpencolorColorChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure SpinEditNestChange(Sender: TObject);
    procedure SpinEditNumSidesChange(Sender: TObject);
    procedure SpinEditRadiusChange(Sender: TObject);
    procedure SpinEditStrutFactorChange(Sender: TObject);
    procedure SpinEditStrutTargetChange(Sender: TObject);
    procedure SpinEditSubStrutTargetChange(Sender: TObject);
  private
    { private declarations }
    myBitmap: TBitmap;
    procedure UpdateParamsAndRedraw(Sender: TObject);
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  myBitmap := TBitmap.Create;
  myBitmap.SetSize(PaintBox1.Width, PaintBox1.Height);

  // Set initial values for the spin edits
  SpinEditNest.Value := 5;
  SpinEditRadius.Value := 350;
  SpinEditStrutFactor.Value := 0.30;
  SpinEditStrutTarget.Value := 4;
  SpinEditSubStrutTarget.Value := 3;
  SpinEditNumSides.Value := 7;

end;

procedure TForm1.ColorButtonpencolorColorChanged(Sender: TObject);
begin
  PaintBox1.Invalidate; // Trigger a repaint when the pen color changes
  //ColorButtonpencolor.OnColorChanged := @ColorButtonpencolorColorChanged;
end;

procedure TForm1.ColorButtonbrushcolorColorChanged(Sender: TObject);
begin
  PaintBox1.Invalidate; // Trigger a repaint when the brush color changes
  //ColorButtonbrushcolor.OnColorChanged := @ColorButtonbrushcolorColorChanged;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  PaintBoxCanvas: TCanvas;
begin
  PaintBoxCanvas := PaintBox1.Canvas;

  //PaintBoxCanvas.Brush.Color := RGBToColor(255, 255, 255);
  PaintBoxCanvas.Brush.Color := ColorButtonbrushcolor.ButtonColor;
  PaintBoxCanvas.FillRect(0, 0, PaintBox1.Width, PaintBox1.Height);

  //PaintBoxCanvas.Pen.Color := RGBToColor($bd, $4f, $1d);
  PaintBoxCanvas.Pen.Color := ColorButtonpencolor.ButtonColor;

  // render Sutcliffe pentagon to canvas
  PaintBoxCanvas.RenderSutcliffePentagon(
    SpinEditNest.Value,
    SpinEditRadius.Value,
    SpinEditStrutFactor.Value,
    SpinEditStrutTarget.Value,
    SpinEditSubStrutTarget.Value,
    SpinEditNumSides.Value
  );
  // render Sutcliffe pentagon to canvas
  //PaintBoxCanvas.RenderSutcliffePentagon(
  //  5,      // aNest
  //  350,    // aRadius
  //  0.30,   // aStrutFactor
  //  4,      // aStrutTarget
  //  3,      // aSubStrutTarget
  //  7       // aNumSides

end;

procedure TForm1.SpinEditNestChange(Sender: TObject);
begin
   SpinEditNest.OnChange := @UpdateParamsAndRedraw;
end;

procedure TForm1.SpinEditNumSidesChange(Sender: TObject);
begin
  SpinEditNumSides.OnChange := @UpdateParamsAndRedraw;
end;

procedure TForm1.SpinEditRadiusChange(Sender: TObject);
begin
  SpinEditRadius.OnChange := @UpdateParamsAndRedraw;
end;

procedure TForm1.SpinEditStrutFactorChange(Sender: TObject);
begin
  SpinEditStrutFactor.OnChange := @UpdateParamsAndRedraw;
end;

procedure TForm1.SpinEditStrutTargetChange(Sender: TObject);
begin
   SpinEditStrutTarget.OnChange := @UpdateParamsAndRedraw;
end;

procedure TForm1.SpinEditSubStrutTargetChange(Sender: TObject);
begin
   SpinEditSubStrutTarget.OnChange := @UpdateParamsAndRedraw;
end;

procedure TForm1.UpdateParamsAndRedraw(Sender: TObject);
begin
  // Redraw the PaintBoxCanvas whenever any spin edit value changes
  PaintBox1.Invalidate;
end;

end.
