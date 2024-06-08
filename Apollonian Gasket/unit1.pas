unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  BGRAGraphicControl, Math;

type
  TMyCircle = class
  public
    X, Y, Radius: Single;
    procedure Initialize(new_X, new_Y, new_Radius: Single);
    procedure Draw(aCanvas: TCanvas; aColor: TColor);
    function ToString: String;
  end;

  type
  TDoubleValue = record
    Value: Double;
  end;

  TDoubleValueList = array of TDoubleValue;

type

  { TForm1 }

  TForm1 = class(TForm)
    BGRAGraphicControl1: TBGRAGraphicControl;
    PaintBox1: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
  private
    procedure MakeImage;
    procedure FindApollonianPacking(aCanvas: TCanvas; aWidth: Integer);
    procedure FindCircleOutsideAll(level: Integer; aCanvas: TCanvas; circle0, circle1, circle2: TMyCircle);
    procedure FindCircleOutsideTwo(level: Integer; aCanvas: TCanvas; circle0, circle1, circle_contains: TMyCircle);
    function FindApollonianCircle(c1, c2, c3: TMyCircle; s1, s2, s3: Integer): TMyCircle;
    function QuadraticSolutions(a, b, c: Double): TDoubleValueList;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  MakeImage;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  MakeImage;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  MakeImage;
end;

procedure TForm1.MakeImage;
var
  aWidth: Integer;
begin
  if PaintBox1.Width < PaintBox1.Height then
    aWidth := PaintBox1.Width
  else
    aWidth := PaintBox1.Height;

  PaintBox1.Canvas.Brush.Color := clWhite;
  PaintBox1.Canvas.FillRect(0, 0, PaintBox1.Width, PaintBox1.Height);

  FindApollonianPacking(PaintBox1.Canvas, aWidth);
end;

procedure TForm1.FindApollonianPacking(aCanvas: TCanvas; aWidth: Integer);
var
  Radius, X, gasket_height, Y: Single;
  circle0, circle1, circle2, big_circle: TMyCircle;
  level: Integer;
  solutions: TDoubleValueList;
  a, b, c: Double;
begin
  // Calculate initial parameters
  Radius := aWidth * 0.225;
  X := aWidth / 2;
  gasket_height := 2 * (Radius + 2 * Radius / Sqrt(3));
  Y := (aWidth - gasket_height) / 2 + Radius;

  // Calculate coefficients for the quadratic equation
  a := 1; // You need to calculate this based on the circles involved
  b := 2; // You need to calculate this based on the circles involved
  c := 3; // You need to calculate this based on the circles involved

  // Call QuadraticSolutions with the calculated coefficients
  solutions := TDoubleValueList(QuadraticSolutions(a, b, c));

  // Create and initialize circle0
  circle0 := TMyCircle.Create;
  circle0.Initialize(X, Y, Radius);

  // Create and initialize circle1
  X := X - Radius;
  Y := Y + Radius * Sqrt(3);
  circle1 := TMyCircle.Create;
  circle1.Initialize(X, Y, Radius);

  // Create and initialize circle2
  X := X + 2 * Radius;
  circle2 := TMyCircle.Create;
  circle2.Initialize(X, Y, Radius);

  // Draw the initial circles
  circle0.Draw(aCanvas, clBlue);
  circle1.Draw(aCanvas, clBlue);
  circle2.Draw(aCanvas, clBlue);

  // Find and draw the big circle that contains all three circles
  big_circle := FindApollonianCircle(circle0, circle1, circle2, -1, -1, -1);
  if Assigned(big_circle) then
    big_circle.Draw(aCanvas, clBlue);

  // Set the level for recursion
  level := 10000;

  // Find circles outside all three circles
  FindCircleOutsideAll(level, aCanvas, circle0, circle1, circle2);

  // Find circles tangent to the big circle and outside two circles
  FindCircleOutsideTwo(level, aCanvas, circle0, circle1, big_circle);
  FindCircleOutsideTwo(level, aCanvas, circle1, circle2, big_circle);
  FindCircleOutsideTwo(level, aCanvas, circle2, circle0, big_circle);
end;

procedure TForm1.FindCircleOutsideAll(level: Integer; aCanvas: TCanvas; circle0, circle1, circle2: TMyCircle);
var
  new_circle: TMyCircle;
begin
  new_circle := FindApollonianCircle(circle0, circle1, circle2, 1, 1, 1);
  if not Assigned(new_circle) or (new_circle.Radius < 0.1) then
    Exit;

  new_circle.Draw(aCanvas, clBlue);

  Dec(level);
  if level > 0 then
  begin
    FindCircleOutsideAll(level, aCanvas, circle0, circle1, new_circle);
    FindCircleOutsideAll(level, aCanvas, circle0, circle2, new_circle);
    FindCircleOutsideAll(level, aCanvas, circle1, circle2, new_circle);
  end;
end;

procedure TForm1.FindCircleOutsideTwo(level: Integer; aCanvas: TCanvas; circle0, circle1, circle_contains: TMyCircle);
var
  new_circle: TMyCircle;
begin
  new_circle := FindApollonianCircle(circle0, circle1, circle_contains, 1, 1, -1);
  if not Assigned(new_circle) or (new_circle.Radius < 0.1) then
    Exit;

  new_circle.Draw(aCanvas, clBlue);

  Dec(level);
  if level > 0 then
  begin
    FindCircleOutsideTwo(level, aCanvas, new_circle, circle0, circle_contains);
    FindCircleOutsideTwo(level, aCanvas, new_circle, circle1, circle_contains);
    FindCircleOutsideAll(level, aCanvas, circle0, circle1, new_circle);
  end;
end;

function TForm1.FindApollonianCircle(c1, c2, c3: TMyCircle; s1, s2, s3: Integer): TMyCircle;
const
  tiny = 0.0001;
var
  temp_circle: TMyCircle;
  temp_s: Integer;
  x1, y1, r1, x2, y2, r2, x3, y3, r3: Single;
  v11, v12, v13, v14, v21, v22, v23, v24: Single;
  w12, w13, w14, w22, w23, w24: Single;
  P, Q, M, N, a, b, c: Single;
  solutions: TDoubleValueList;
  rs, xs, ys: Single;
  new_circle: TMyCircle;
begin
  Result := nil;

  if (Abs(c2.X - c1.X) < tiny) or (Abs(c2.Y - c1.Y) < tiny) then
  begin
    temp_circle := c2;
    c2 := c3;
    c3 := temp_circle;
    temp_s := s2;
    s2 := s3;
    s3 := temp_s;
  end;
  if (Abs(c2.X - c3.X) < tiny) or (Abs(c2.Y - c3.Y) < tiny) then
  begin
    temp_circle := c2;
    c2 := c1;
    c1 := temp_circle;
    temp_s := s2;
    s2 := s1;
    s1 := temp_s;
  end;

  x1 := c1.X;
  y1 := c1.Y;
  r1 := c1.Radius;
  x2 := c2.X;
  y2 := c2.Y;
  r2 := c2.Radius;
  x3 := c3.X;
  y3 := c3.Y;
  r3 := c3.Radius;

  v11 := 2 * x2 - 2 * x1;
  v12 := 2 * y2 - 2 * y1;
  v13 := x1 * x1 - x2 * x2 + y1 * y1 - y2 * y2 - r1 * r1 + r2 * r2;
  v14 := 2 * s2 * r2 - 2 * s1 * r1;

  v21 := 2 * x3 - 2 * x2;
  v22 := 2 * y3 - 2 * y2;
  v23 := x2 * x2 - x3 * x3 + y2 * y2 - y3 * y3 - r2 * r2 + r3 * r3;
  v24 := 2 * s3 * r3 - 2 * s2 * r2;

  w12 := v12 / v11;
  w13 := v13 / v11;
  w14 := v14 / v11;

  w22 := v22 / v21 - w12;
  w23 := v23 / v21 - w13;
  w24 := v24 / v21 - w14;

  P := -w23 / w22;
  Q := w24 / w22;
  M := -w12 * P - w13;
  N := w14 - w12 * Q;

  a := N * N + Q * Q - 1;
  b := 2 * M * N - 2 * N * x1 + 2 * P * Q - 2 * Q * y1 + 2 * s1 * r1;
  c := x1 * x1 + M * M - 2 * M * x1 + P * P + y1 * y1 - 2 * P * y1 - r1 * r1;
  solutions := TDoubleValueList(QuadraticSolutions(a, b, c));

  if solutions = nil then
    Exit;

  rs := TDoubleValue(solutions[0]).Value;
  xs := M + N * rs;
  ys := P + Q * rs;
  new_circle := TMyCircle.Create;
  new_circle.Initialize(xs, ys, rs);
  Result := new_circle;
end;

function TForm1.QuadraticSolutions(a, b, c: Double): TDoubleValueList;
const
  tiny = 0.000001;
var
  discriminant: Double;
  results: TDoubleValueList;
begin
  SetLength(results, 0); // Initialize the list

  discriminant := b * b - 4 * a * c;

  if discriminant < 0 then
    Exit;

  if discriminant < tiny then
  begin
    SetLength(results, 1);
    results[0].Value := -b / (2 * a);
    Result := results;
    Exit;
  end;

  SetLength(results, 2);
  results[0].Value := (-b + Sqrt(discriminant)) / (2 * a);
  results[1].Value := (-b - Sqrt(discriminant)) / (2 * a);
  Result := results;
end;

procedure TMyCircle.Initialize(new_X, new_Y, new_Radius: Single);
begin
  X := new_X;
  Y := new_Y;
  Radius := Abs(new_Radius);
end;

procedure TMyCircle.Draw(aCanvas: TCanvas; aColor: TColor);
begin
  if Radius > 0 then
  begin
    aCanvas.Pen.Color := aColor;
    aCanvas.Brush.Style := bsClear;
    aCanvas.Ellipse(Round(X - Radius), Round(Y - Radius), Round(X + Radius), Round(Y + Radius));
  end;
end;

function TMyCircle.ToString: String;
begin
  Result := '(' + FloatToStr(X) + ', ' + FloatToStr(Y) + '), ' + FloatToStr(Radius);
end;

end.

