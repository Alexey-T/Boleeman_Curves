unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  fpImage, IntfGraphics, ExtCtrls, Graph;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnMakeFern: TButton;
    btnSave: TButton;
    Image1: TImage;
    lbl_loopsize: TLabel;
    lblSize: TLabel;
    lblRGB: TLabel;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    seRed: TSpinEdit;
    seGreen: TSpinEdit;
    seBlue: TSpinEdit;
    seSizeFactor: TSpinEdit;
    seRenderNumbTimes: TSpinEdit;
    procedure btnMakeFernClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure seBlueChange(Sender: TObject);
    procedure seGreenChange(Sender: TObject);
    procedure seRedChange(Sender: TObject);
    procedure seRenderNumbTimesChange(Sender: TObject);
    procedure seSizeFactorChange(Sender: TObject);
  private
    procedure DrawFern(const RenderTimes: Integer; const SizeFactor: Double; const RgbVary: array of Integer);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnMakeFernClick(Sender: TObject);
var
  RenderTimes: Integer;
  SizeFactor: Double;
  RgbVary: array[0..2] of Integer;
begin
  Randomize;
  try
    RenderTimes := seRenderNumbTimes.Value;
    SizeFactor := seSizeFactor.Value;
    RgbVary[0] := seRed.Value;
    RgbVary[1] := seGreen.Value;
    RgbVary[2] := seBlue.Value;
    DrawFern(RenderTimes, SizeFactor, RgbVary);
  except
    on E: Exception do
      ShowMessage('Error: ' + E.Message);
  end;
end;

procedure TForm1.btnSaveClick(Sender: TObject);
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

procedure TForm1.FormCreate(Sender: TObject);
begin
  Randomize;
  DoubleBuffered := True;
  Image1.Canvas.Brush.Color := clBlack;
  btnMakeFernClick(self);
end;

procedure TForm1.seBlueChange(Sender: TObject);
begin
  btnMakeFernClick(self);
end;

procedure TForm1.seGreenChange(Sender: TObject);
begin
  btnMakeFernClick(self);
end;

procedure TForm1.seRedChange(Sender: TObject);
begin
  btnMakeFernClick(self);
end;

procedure TForm1.seRenderNumbTimesChange(Sender: TObject);
begin
  btnMakeFernClick(self);
end;

procedure TForm1.seSizeFactorChange(Sender: TObject);
begin
  btnMakeFernClick(self);
end;

procedure TForm1.DrawFern(const RenderTimes: Integer; const SizeFactor: Double; const RgbVary: array of Integer);
var
  x_value, y_value: Double;
  randomness, coeff_x_of_newX, coeff_y_of_newX, coeff_x_of_newY, coeff_y_of_newY, const_term_newX, const_term_newY,
  newX, newY: Double;
  inner_loop_variable, loop_extender, leaf_sub_level: Integer;
  FernImage: TBitmap;
  VertOffset: Integer; // Vertical offset for centering the image
begin
  // Create a bitmap to draw the fern on
  FernImage := TBitmap.Create;
  try
    // Set the size of the bitmap to match the TImage component
    FernImage.SetSize(Image1.Width, Image1.Height);

    // Create a canvas to draw on the bitmap
    FernImage.Canvas.Brush.Color := clBlack; // Set the background color
    FernImage.Canvas.FillRect(0, 0, FernImage.Width, FernImage.Height); // Clear the bitmap

    Randomize;
    leaf_sub_level := 1;

    for loop_extender := 1 to RenderTimes do
    begin
      x_value := 0;
      y_value := 0;

      for inner_loop_variable := 1 to 3000 do
      begin
        randomness := Random;

        if randomness <= 0.1 then
        begin
          coeff_x_of_newX := 0;
          coeff_y_of_newX := 0;
          coeff_x_of_newY := 0;
          coeff_y_of_newY := 0.26;
          const_term_newX := 0;
          const_term_newY := 0;
        end
        else if (randomness > 0.1) and (randomness <= 0.86) then
        begin
          coeff_x_of_newX := 0.85;
          coeff_y_of_newX := 0.04;
          coeff_x_of_newY := -0.04;
          coeff_y_of_newY := 0.85;
          const_term_newX := 0;
          const_term_newY := 1.59;
        end
        else if (randomness > 0.86) and (randomness <= 0.93) then
        begin
          coeff_x_of_newX := 0.2;
          coeff_y_of_newX := -0.26;
          coeff_x_of_newY := 0.23;
          coeff_y_of_newY := 0.22;
          const_term_newX := 0;
          const_term_newY := 1.59;
        end
        else
        begin
          coeff_x_of_newX := -0.15;
          coeff_y_of_newX := 0.28;
          coeff_x_of_newY := 0.26;
          coeff_y_of_newY := 0.24;
          const_term_newX := 0;
          const_term_newY := 0.44;
        end;

        newX := coeff_x_of_newX * x_value + coeff_y_of_newX * y_value + const_term_newX;
        newY := coeff_x_of_newY * x_value + coeff_y_of_newY * y_value + const_term_newY;
        x_value := newX;
        y_value := newY;

        case leaf_sub_level of
          1: FernImage.Canvas.Pixels[Round(16 + SizeFactor * y_value), Round(280 + SizeFactor * x_value)] :=
               (RgbVary[0] + Round(inner_loop_variable / 6000)) or ((RgbVary[1] - Round(inner_loop_variable / 4000)) shl 8) or (RgbVary[2] shl 16);
          2: FernImage.Canvas.Pixels[Round(16 + SizeFactor * y_value), Round(280 + SizeFactor * x_value)] :=
               (RgbVary[0] + Round(inner_loop_variable / 6000)) or ((RgbVary[1] - Round(inner_loop_variable / 4000)) shl 8) or (RgbVary[2]  shl 16);
          3: FernImage.Canvas.Pixels[Round(16 + SizeFactor * y_value), Round(280 + SizeFactor * x_value)] :=
               (RgbVary[0] + Round(inner_loop_variable / 6000)) or ((RgbVary[1] - Round(inner_loop_variable / 4000)) shl 8) or (RgbVary[2]  shl 16);
          4: FernImage.Canvas.Pixels[Round(16 + SizeFactor * y_value), Round(280 + SizeFactor * x_value)] :=
              (RgbVary[0] + 50) or ((RgbVary[1] + 255 - Round(inner_loop_variable / 4000)) shl 8) or (RgbVary[2] + Round(inner_loop_variable / 4000) shl 16);
          5: FernImage.Canvas.Pixels[Round(16 + SizeFactor * y_value), Round(280 + SizeFactor * x_value)] :=
              (RgbVary[0] + 125 - Round(inner_loop_variable / 4000)) or (RgbVary[1] shl 8) or (RgbVary[2] + Round(inner_loop_variable / 4000) shl 16);
          6: FernImage.Canvas.Pixels[Round(16 + SizeFactor * y_value), Round(280 + SizeFactor * x_value)] :=
              (RgbVary[0] + 125 - Round(inner_loop_variable / 4000)) or (RgbVary[1] + Round(inner_loop_variable / 4000) shl 8) or (RgbVary[2]  shl 16);
        end;
      end;

      Inc(leaf_sub_level);
      if leaf_sub_level = 6 then
        leaf_sub_level := 1;
    end;

    // Calculate the vertical offset to center the image
    VertOffset := Panel1.Height + Panel1.Height + (Image1.Height - FernImage.Height) div 2;

    // Draw the bitmap onto the TImage component with the calculated vertical offset
    Image1.Picture.Bitmap := FernImage;
     finally
       // Free the bitmap
       FernImage.Free;
     end;
   end;
end.

