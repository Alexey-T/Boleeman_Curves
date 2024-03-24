unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ColorBox;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnSavePic: TButton;
    cbEndcolor: TColorButton;
    Fader_curvedoffset: TTrackBar;
    Fader_multiplier: TTrackBar;
    Fader_sum_rotator: TTrackBar;
    gbColours: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Panel1: TPanel;
    cbBladecolor: TColorButton;
    RadioGroup1: TRadioGroup;
    SaveDialog1: TSaveDialog;
    //procedure btnSavePicClick(Sender: TObject);
    procedure cbBladecolorColorChanged(Sender: TObject);
    procedure cbEndcolorColorChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MakeCurve(Sender: TObject);
    procedure Fader_curvedoffsetChange(Sender: TObject);
    procedure Fader_multiplierChange(Sender: TObject);
    procedure Fader_sum_rotatorChange(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);


  private
    procedure CreateBlades(Image: TImage; myWidth, myHeight: Integer; PercentCoeff: Single;
      SumRotator, CurvedOffset: Integer; CurveType: Integer; BladeColor: TColor);
    function InterpolateColor(Color1, Color2: TColor; Intensity: Single): TColor;
    procedure btnSavePicClick(Sender: TObject);
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

function TForm1.InterpolateColor(Color1, Color2: TColor; Intensity: Single): TColor;
var
  R1, G1, B1, R2, G2, B2: Byte;
begin
  R1 := Red(Color1);
  G1 := Green(Color1);
  B1 := Blue(Color1);

  R2 := Red(Color2);
  G2 := Green(Color2);
  B2 := Blue(Color2);

  Result := RGBToColor(
    Round(R1 + (R2 - R1) * Intensity),
    Round(G1 + (G2 - G1) * Intensity),
    Round(B1 + (B2 - B1) * Intensity)
  );
end;

procedure TForm1.CreateBlades(Image: TImage; myWidth, myHeight: Integer; PercentCoeff: Single;
  SumRotator, CurvedOffset: Integer; CurveType: Integer; BladeColor: TColor);
var
  x, y, x2: Integer;
  patternColor, endColor: TColor;
begin
  Image.Canvas.Brush.Color := clWhite;
  Image.Canvas.FillRect(0, 0, myWidth, myHeight);

    // Get the color selected in cbEndcolor
  endColor := cbEndcolor.ButtonColor;

  case CurveType of
    0: begin
         for y := 0 to myHeight - 1 do
         begin
           x := y;
           patternColor := InterpolateColor(BladeColor, endColor, Frac(PercentCoeff * y / myHeight));
           Image.Canvas.Pen.Color := patternColor;
           Image.Canvas.Line(0, y + SumRotator, myWidth, y + SumRotator);
         end;
       end;

    1: begin
         for x := 0 to myWidth - 1 do
         begin
           y := x;  // Vertical blades
           patternColor := InterpolateColor(BladeColor, endColor, Frac(PercentCoeff * x / myWidth));
           Image.Canvas.Pen.Color := patternColor;
           Image.Canvas.Line(x + SumRotator, 0, x + SumRotator, myHeight);
         end;
       end;
    2: begin
       for x := 0 to myWidth - 1 do
       begin
         y := x;
         patternColor := InterpolateColor(BladeColor, endColor, Frac(PercentCoeff * x / myWidth));
         Image.Canvas.Pen.Color := patternColor;
         Image.Canvas.Line(x, 0, myWidth - x - 1, myHeight - 1);
       end;

       for y := 0 to myHeight - 2 do
       begin
         x := y;
         patternColor := InterpolateColor(BladeColor, endColor, Frac(PercentCoeff * y / myHeight));
         Image.Canvas.Pen.Color := patternColor;
         Image.Canvas.Line(0, y, myWidth - 1, myHeight - y - 1);
       end;
     end;
      3: begin
         for x := 0 to myWidth - 1 do
         begin
           y := x;
           patternColor := InterpolateColor(BladeColor, endColor, Frac((PercentCoeff * x / myWidth)));
           Image.Canvas.Pen.Color := patternColor;
           Image.Canvas.Line(0, x, 2 * myWidth - x, 2 * myHeight);
         end;

         for y := 0 to myHeight - 1 do
         begin
           x := y;
            patternColor := InterpolateColor(BladeColor, endColor, Frac(PercentCoeff * y / myHeight));
            Image.Canvas.Pen.Color := patternColor;
           Image.Canvas.Line(y, 0, 2 * myWidth, 2 * myHeight - y);
         end;

         for x := 0 to myWidth - 1 do
         begin
           y := x;
            patternColor := InterpolateColor(BladeColor, endColor, Frac(PercentCoeff * x / myWidth));
            Image.Canvas.Pen.Color := patternColor;
           Image.Canvas.Line(0, x, 2 * myWidth - x, 2 * myHeight);
         end;

         for y := 0 to myHeight - 1 do
         begin
           x := y;
            patternColor := InterpolateColor(BladeColor, endColor, Frac(PercentCoeff * y / myHeight));
            Image.Canvas.Pen.Color := patternColor;
           Image.Canvas.Line(y, 0, 2 * myWidth, 2 * myHeight - y);
         end;
       end;

      4: begin
         for x := 0 to myWidth - 1 do
          begin
           y := x;
           patternColor := InterpolateColor(BladeColor, endColor, Frac(PercentCoeff * x / myWidth));
           Image.Canvas.Pen.Color := patternColor;
           Image.Canvas.Line(0, x, 2 * myWidth - x, 2 * myHeight);
         end;

         for y := 0 to myHeight - 1 do
         begin
           x := y;
           patternColor := InterpolateColor(BladeColor, endColor, Frac(PercentCoeff * y / myHeight));
           Image.Canvas.Pen.Color := patternColor;
           Image.Canvas.Line(y, 0, 2 * myWidth, 2 * myHeight - y);
         end;

         for x := 0 to myWidth - 1 do
         begin
           y := x;
           patternColor := InterpolateColor(BladeColor, endColor, Frac(PercentCoeff * x / myWidth));
           Image.Canvas.Pen.Color := patternColor;
           Image.Canvas.Line(x, 0, 2 * myWidth - x, 2 * myHeight);
         end;

         for y := 0 to myHeight - 1 do
         begin
           x := y;
           patternColor := InterpolateColor(BladeColor, endColor, Frac(PercentCoeff * y / myHeight));
           Image.Canvas.Pen.Color := patternColor;
           Image.Canvas.Line(0, y, 2 * myWidth, 2 * myHeight - y);
         end;
       end;
      5: begin
         for x := 0 to myWidth - 1 do
          begin
           y := x;
            patternColor := InterpolateColor(BladeColor, endColor, Frac(PercentCoeff * x / myWidth));
            Image.Canvas.Pen.Color := patternColor;
           Image.Canvas.Line(0, x, CurvedOffset * x, myHeight);
         end;

         for X2 := 0 to myWidth - 1 do
          begin
           y := X2;
           patternColor := InterpolateColor(BladeColor, endColor, Frac(PercentCoeff * X2 / myWidth));
           Image.Canvas.Pen.Color := patternColor;
           Image.Canvas.Line(X2, 0, myHeight, CurvedOffset * X2);
         end;

         for x := 0 to myWidth - 1 do
         begin
           y := x;
           patternColor := InterpolateColor(BladeColor, endColor, Frac(PercentCoeff * x / myWidth));
           Image.Canvas.Pen.Color := patternColor;
           Image.Canvas.Line(0, x, CurvedOffset * x, myHeight);
         end;

         for X2 := 0 to myWidth - 1 do
         begin
           y := X2;
           patternColor := InterpolateColor(BladeColor, endColor, Frac(PercentCoeff * X2 / myWidth));
           Image.Canvas.Pen.Color := patternColor;
           Image.Canvas.Line(X2, 0, myHeight, CurvedOffset * X2);
         end;
       end;
  end;
   // Image.Repaint;
   Image1.Invalidate;
end;

{ TForm1 }

procedure TForm1.MakeCurve(Sender: TObject);
var
  myWidth, myHeight, SumRotator, CurvedOffset, CurveType: Integer;
  PercentCoeff: Single;
begin
  myWidth := Image1.Width;
  myHeight := Image1.Height;
  PercentCoeff := Fader_multiplier.Position / 100;
  SumRotator := Fader_sum_rotator.Position;
  CurvedOffset := Fader_curvedoffset.Position;

  CurveType := Radiogroup1.ItemIndex;

  Image1.Picture := nil; // Clear existing picture
  Image1.Picture.Bitmap.Width := myWidth;
  Image1.Picture.Bitmap.Height := myHeight;

  CreateBlades(Image1, myWidth, myHeight, PercentCoeff, SumRotator, CurvedOffset, CurveType, cbBladecolor.ButtonColor);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Set the default color for cbBladecolor
  cbBladecolor.ButtonColor := clRed;
  Fader_multiplier.Position := 800;
  RadioGroup1.ItemIndex := 0;

  // Set the OnClick event handler for btnSavePic
  btnSavePic.OnClick := @btnSavePicClick;

  MakeCurve(Sender);
end;

procedure TForm1.cbBladecolorColorChanged(Sender: TObject);
begin
  MakeCurve(Sender);
end;

procedure TForm1.btnSavePicClick(Sender: TObject);
var
  SaveDialog: TSaveDialog;
begin
  SaveDialog := TSaveDialog.Create(Self);
  try
    SaveDialog.Filter := 'PNG Files|*.png';
    SaveDialog.DefaultExt := 'png';
    SaveDialog.Title := 'Save Image As';

    if SaveDialog.Execute then
      Image1.Picture.SaveToFile(SaveDialog.FileName);
  finally
    SaveDialog.Free;
  end;
end;

procedure TForm1.cbEndcolorColorChanged(Sender: TObject);
begin
  MakeCurve(Sender);
end;

procedure TForm1.Fader_curvedoffsetChange(Sender: TObject);
begin
  MakeCurve(Sender);
end;

procedure TForm1.Fader_multiplierChange(Sender: TObject);
begin
  MakeCurve(Sender);
end;

procedure TForm1.Fader_sum_rotatorChange(Sender: TObject);
begin
  MakeCurve(Sender);
end;

procedure TForm1.RadioGroup1Click(Sender: TObject);
begin
  MakeCurve(Sender);
end;

end.
