unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Spin,
  ExtCtrls, StdCtrls;

type
  { TForm1 }

  TForm1 = class(TForm)
    btnRefresh: TButton;
    lblFillTo: TLabel;
    lblTotRec: TLabel;
    lblTreesize: TLabel;
    lblLumThresh: TLabel;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    seRecursionLevel: TSpinEdit;
    seFilltoLevel: TSpinEdit;
    seChangeTreeSize: TSpinEdit;
    seLumLimit: TFloatSpinEdit; // Changed to TFloatSpinEdit for Luminance Threshold
    procedure btnRefreshClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure seFilltoLevelChange(Sender: TObject);
    procedure seRecursionLevelChange(Sender: TObject);
    procedure seChangeTreeSizeChange(Sender: TObject);
    procedure seLumLimitChange(Sender: TObject); // Added seLumLimitChange
    procedure PaintBox1Paint(Sender: TObject);
  private
    Colors: array of TColor;
    TreeSize: Integer;
    LumLimit: Double; // Changed to Double for Luminance Threshold
    procedure GenerateRandomColors;
    procedure PythagorasTree(DestCanvas: TCanvas; x1, y1, x2, y2: Double; depth, fillLevel: Integer);
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

function GetLuminance(color: TColor): Double;
var
  r, g, b: Byte;
begin
  // Extract RGB components from the color
  r := Red(color);
  g := Green(color);
  b := Blue(color);

  // Calculate luminance using the ITU-R BT.709 formula
  Result := 0.2126 * r / 255 + 0.7152 * g / 255 + 0.0722 * b / 255;
end;

procedure TForm1.GenerateRandomColors;
var
  i: Integer;
begin
  SetLength(Colors, 20);
  for i := 0 to High(Colors) do
  begin
    repeat
      Colors[i] := RGBToColor(Random(256), Random(256), Random(256));
    until GetLuminance(Colors[i]) > LumLimit; // Use LumLimit as the threshold
  end;
end;

procedure TForm1.PythagorasTree(DestCanvas: TCanvas; x1, y1, x2, y2: Double; depth, fillLevel: Integer);
var
  dx, dy, x3, y3, x4, y4, x5, y5: Double;
  ColorIndex: Integer;
begin
  if depth >= seRecursionLevel.Value then
    Exit;

  dx := x2 - x1;
  dy := y1 - y2;
  x3 := x2 - dy;
  y3 := y2 - dx;
  x4 := x1 - dy;
  y4 := y1 - dx;
  x5 := x4 + (dx - dy) / 2;
  y5 := y4 - (dx + dy) / 2;

  ColorIndex := depth mod Length(Colors);
  if (depth <= seFilltoLevel.Value - 1) and (ColorIndex = 0) then
    GenerateRandomColors;

  if depth <= seFilltoLevel.Value - 1 then
  begin
    DestCanvas.Brush.Color := Colors[ColorIndex];
    DestCanvas.Pen.Color := DestCanvas.Brush.Color;
    DestCanvas.Polygon([Point(Round(x1), Round(y1)), Point(Round(x2), Round(y2)),
                        Point(Round(x3), Round(y3)), Point(Round(x4), Round(y4))]);
  end
  else
  begin
    DestCanvas.Pen.Color := Colors[ColorIndex];
    DestCanvas.Pen.Width := 2;
    DestCanvas.Line(Round(x1), Round(y1), Round(x2), Round(y2));
    DestCanvas.Line(Round(x2), Round(y2), Round(x3), Round(y3));
    DestCanvas.Line(Round(x3), Round(y3), Round(x4), Round(y4));
    DestCanvas.Line(Round(x4), Round(y4), Round(x1), Round(y1));
  end;

  PythagorasTree(DestCanvas, x4, y4, x5, y5, depth + 1, fillLevel);
  PythagorasTree(DestCanvas, x5, y5, x3, y3, depth + 1, fillLevel);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Randomize;
  seRecursionLevel.MinValue := 0; // Set MinValue to 0
  seFilltoLevel.MinValue := 0;    // Set MinValue to 0
  seChangeTreeSize.MinValue := 50; // Set MinValue to 1 for tree size
  seLumLimit.MinValue := 0;       // Set MinValue for Luminance Threshold
  seLumLimit.MaxValue := 1;       // Set MaxValue for Luminance Threshold
  seRecursionLevel.Value := 11;   // Default recursion level
  seFilltoLevel.Value := 7;       // Default fill level (adjusted by 1)
  seChangeTreeSize.Value := 90;     // Default tree size
  seLumLimit.Value := 0.325;        // Default Luminance Threshold
  seRecursionLevel.OnChange := @seRecursionLevelChange;
  seFilltoLevel.OnChange := @seFilltoLevelChange;
  seChangeTreeSize.OnChange := @seChangeTreeSizeChange;
  seLumLimit.OnChange := @seLumLimitChange; // Assign the OnChange event for seLumLimit
  GenerateRandomColors;
end;

procedure TForm1.btnRefreshClick(Sender: TObject);
begin
    Invalidate;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  TempBitmap: TBitmap;
begin
  TempBitmap := TBitmap.Create;
  try
    TempBitmap.SetSize(PaintBox1.Width, PaintBox1.Height);
    TempBitmap.Canvas.Brush.Color := clWhite;
    TempBitmap.Canvas.FillRect(TempBitmap.Canvas.ClipRect);

    // Paint the Pythagoras tree on the PaintBox
    PythagorasTree(TempBitmap.Canvas, PaintBox1.Width / 2 - TreeSize, PaintBox1.Height - 10,
                   PaintBox1.Width / 2 + TreeSize, PaintBox1.Height - 10, 0, seFilltoLevel.Value);

    // Draw the bitmap onto PaintBox1.Canvas
    PaintBox1.Canvas.Draw(0, 0, TempBitmap);
  finally
    TempBitmap.Free;
  end;
end;

procedure TForm1.seRecursionLevelChange(Sender: TObject);
begin
  Invalidate;
end;

procedure TForm1.seFilltoLevelChange(Sender: TObject);
begin
  Invalidate;
end;

procedure TForm1.seChangeTreeSizeChange(Sender: TObject);
begin
  TreeSize := seChangeTreeSize.Value;
  PaintBox1.Invalidate;
end;

procedure TForm1.seLumLimitChange(Sender: TObject);
begin
  LumLimit := seLumLimit.Value;
  GenerateRandomColors;
  PaintBox1.Invalidate;
end;

end.
