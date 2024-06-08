unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Spin, ucomplex, GraphUtil, Math, BGRABitmapTypes, BGRABitmap,
  BGRAGraphicControl;

type
  TForm1 = class;

  { TFractalSegmentThread }

  TFractalSegmentThread = class(TThread)
  private
    FBitmap: TBGRABitmap;
    FColors: array of TBGRAPixel;
    FStartRow, FEndRow, FN: Integer;
    FCenterX, FCenterY, FRange: Double;
    FMaxIterations: Integer;
    FForm: TForm1;
  protected
    procedure Execute; override;
  public
    constructor Create(ABitmap: TBGRABitmap; const colors: array of TBGRAPixel;
      StartRow, EndRow, N: Integer; centerX, centerY, range: Double;
      maxIterations: Integer; Form: TForm1);
  end;

  { TForm1 }

  TForm1 = class(TForm)
    BGRAGraphicControl1: TBGRAGraphicControl;
    btnGenerate: TButton;
    FloatseCenterX: TFloatSpinEdit;
    FloatseCenterY: TFloatSpinEdit;
    seRange: TFloatSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    seIterations: TSpinEdit;
    procedure btnGenerateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure seIterationsChange(Sender: TObject);
    procedure seRangeChange(Sender: TObject);
  private
    function IterateBurningShip(const c: complex; maxIterations: Integer): Integer;
    function IterationColor(iterations, maxIterations: Integer): TBGRAPixel;
    procedure DrawFractalSegment(ABitmap: TBGRABitmap; const colors: array of TBGRAPixel;
      StartRow, EndRow, N: Integer; centerX, centerY, range: Double;
      maxIterations: Integer);
    procedure DrawFractalThreaded(ACanvas: TCanvas; const ARect: TRect;
      maxIterations: Integer; centerX, centerY, range: Double);
  public


  end;

  { TForm1 }


var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Initialize default values
  FloatseCenterX.Value := 0;
  FloatseCenterY.Value := 0;
  seRange.Value := 2;
  seIterations.Value := 120;
end;

procedure TForm1.btnGenerateClick(Sender: TObject);
begin
  PaintBox1.Invalidate; // Trigger a repaint
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  range, iteratemax: Double;
begin
  iteratemax := seIterations.Value;
  range := seRange.Value;
  DrawFractalThreaded(PaintBox1.Canvas, PaintBox1.ClientRect, Round(iteratemax),
    FloatseCenterX.Value, FloatseCenterY.Value, range);
end;

procedure TForm1.seIterationsChange(Sender: TObject);
begin
    PaintBox1.Invalidate;
end;

procedure TForm1.seRangeChange(Sender: TObject);
begin
    PaintBox1.Invalidate;
end;

function TForm1.IterateBurningShip(const c: complex; maxIterations: Integer): Integer;
var
  z, ztemp: complex;
  n: Integer;
begin
  z.Re := 0;
  z.Im := 0;
  n := 0;

  while (n < maxIterations) and (z.Re * z.Re + z.Im * z.Im < 4) do
  begin
    ztemp.Re := z.Re * z.Re - z.Im * z.Im + c.Re;
    ztemp.Im := 2 * Abs(z.Re * z.Im) + c.Im;
    z := ztemp;
    Inc(n);
  end;

  Result := n;
end;

function TForm1.IterationColor(iterations, maxIterations: Integer): TBGRAPixel;
var
  hue: Integer;
  red, green, blue: Byte;
begin
  if iterations = maxIterations then
    Result := BGRAPixelTransparent
  else
  begin
    hue := Round(240 * Sqrt(iterations / maxIterations));
    HLStoRGB(hue, 127, 255, red, green, blue);
    Result := BGRA(red, green, blue);
  end;
end;

constructor TFractalSegmentThread.Create(ABitmap: TBGRABitmap;
  const colors: array of TBGRAPixel; StartRow, EndRow, N: Integer;
  centerX, centerY, range: Double; maxIterations: Integer; Form: TForm1);
var
  i: Integer;
begin
  inherited Create(True);
  FBitmap := ABitmap;
  SetLength(FColors, Length(colors));
  for i := 0 to High(colors) do
    FColors[i] := colors[i];
  FStartRow := StartRow;
  FEndRow := EndRow;
  FN := N;
  FCenterX := centerX;
  FCenterY := centerY;
  FRange := range;
  FMaxIterations := maxIterations;
  FForm := Form;
  FreeOnTerminate := False;
end;

procedure TFractalSegmentThread.Execute;
begin
  FForm.DrawFractalSegment(FBitmap, FColors, FStartRow, FEndRow, FN,
    FCenterX, FCenterY, FRange, FMaxIterations);
end;

procedure TForm1.DrawFractalSegment(ABitmap: TBGRABitmap;
  const colors: array of TBGRAPixel; StartRow, EndRow, N: Integer;
  centerX, centerY, range: Double; maxIterations: Integer);
var
  i, j, iterations: Integer;
  c: complex;
begin
  for i := StartRow to EndRow do
  begin
    for j := 0 to N - 1 do
    begin
      // Calculate the coordinates after rotating 90 degrees to the right and flipping horizontally
      c.Re := centerX - 2 * range * (j / N - 0.5); // Rotate 90 degrees to the right
      c.Im := centerY - 2 * range * ((N - 1 - i) / N - 0.5); // Flip horizontally and keep it right-side up

      iterations := IterateBurningShip(c, maxIterations);

      ABitmap.SetPixel(j, i, colors[iterations]);
    end;
  end;
end;

procedure TForm1.DrawFractalThreaded(ACanvas: TCanvas; const ARect: TRect;
    maxIterations: Integer; centerX, centerY, range: Double);
  var
    N, i, ThreadCount, RowsPerThread, ExtraRows, RowStart, RowEnd: Integer;
    colors: array of TBGRAPixel;
    Threads: array of TFractalSegmentThread;
    myBitmap: TBGRABitmap;
  begin
    N := ARect.Bottom - ARect.Top;
    myBitmap := TBGRABitmap.Create(N, N);
    try
      SetLength(colors, maxIterations + 1);
      for i := 0 to maxIterations do
        colors[i] := IterationColor(i, maxIterations);

      ThreadCount := CPUCount;
      RowsPerThread := N div ThreadCount;
      ExtraRows := N mod ThreadCount;

      SetLength(Threads, ThreadCount);

      RowStart := 0;
      for i := 0 to ThreadCount - 1 do
      begin
        if i < ExtraRows then
          RowEnd := RowStart + RowsPerThread
        else
          RowEnd := RowStart + RowsPerThread - 1;

        Threads[i] := TFractalSegmentThread.Create(myBitmap, colors, RowStart, RowEnd, N,
  centerX, centerY, range, maxIterations, Self);

        RowStart := RowEnd + 1;
      end;

      for i := 0 to ThreadCount - 1 do
        Threads[i].Start;

      for i := 0 to ThreadCount - 1 do
        Threads[i].WaitFor;
      myBitmap.Draw(ACanvas, ARect.Left, ARect.Top, True);
    finally
      myBitmap.Free;
    end;
  end;

end.

