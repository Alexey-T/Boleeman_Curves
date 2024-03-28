unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Spin, Types;

type
  TStar = record
    p: array [0..2] of TPoint;
    sides: Byte;
    fillColor: TColor;
    borderColor: TColor;
    PenStyle: TPenStyle;
    lineWidth: Integer;
  end;

  TDrawing = array of TStar;

  { TForm1 }

  TForm1 = class(TForm)
    btnClear: TButton;
    btnSave: TButton;
    cbFillcolor: TColorButton;
    cbBordercolor: TColorButton;
    comboLinestyles: TComboBox;
    lblColors: TLabel;
    lblLinewidth: TLabel;
    lblpoints: TLabel;
    Label_pos: TLabel;
    Label9: TLabel;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    Panel2: TPanel;
    SaveDialog1: TSaveDialog;
    seNumbersides: TSpinEdit;
    se_Linewidth: TSpinEdit;
    procedure btnClearClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure cbBordercolorColorChanged(Sender: TObject);
    procedure cbFillcolorColorChanged(Sender: TObject);
    procedure comboLinestylesDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
    procedure seNumbersidesChange(Sender: TObject);
  private
    procedure DrawStar(star: TStar);
    procedure DrawRegPoly(star: TStar);
  public
    temp: TStar;
    pos: TPoint;
    drawing: TDrawing;
    pt_count: Byte;
    num_sides: Byte;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  pt_count := 0;
  num_sides := seNumbersides.Value;
  SetLength(drawing, 0);

  comboLinestyles.Items.Clear;
  comboLinestyles.Style := csOwnerDrawVariable;
  comboLinestyles.Items.Add('Solid');
  comboLinestyles.Items.Add('Dash');
  comboLinestyles.Items.Add('DashDot');
  comboLinestyles.Items.Add('DashDotDot');
  comboLinestyles.Items.Add('Dot');
  comboLinestyles.Items.Add('Pattern');
  comboLinestyles.Items.Add('Clear');
  comboLinestyles.ItemIndex := 0;

end;

procedure TForm1.cbFillcolorColorChanged(Sender: TObject);
begin
     PaintBox1.Invalidate;
end;

procedure TForm1.comboLinestylesDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  PenStyle: TPenStyle;
begin
  case Index of
    0: PenStyle := psSolid;
    1: PenStyle := psDash;
    2: PenStyle := psDashDot;
    3: PenStyle := psDashDotDot;
    4: PenStyle := psDot;
    5: PenStyle := psPattern;
    6: PenStyle := psClear;
    else PenStyle := psSolid;
  end;

  temp.PenStyle := PenStyle;

  (Control as TComboBox).Canvas.Pen.Width := 3;
  (Control as TComboBox).Canvas.Pen.Style := PenStyle; // Set the line style
  (Control as TComboBox).Canvas.Pen.Color := clBlack;
  (Control as TComboBox).Canvas.Line(ARect.Left, ARect.Top + (ARect.Height div 2), ARect.Left + 50, ARect.Top + (ARect.Height div 2));


  (Control as TComboBox).Canvas.TextOut(ARect.Left + 60, ARect.Top, (Control as TComboBox).Items[Index]);
end;

procedure TForm1.cbBordercolorColorChanged(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.btnClearClick(Sender: TObject);
begin
  SetLength(drawing, 0);
  PaintBox1.Invalidate;
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

procedure TForm1.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  pos := Point(x, y);
  PaintBox1.Refresh;
end;

procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Inc(pt_count);
  case pt_count of
    1: begin
         temp.sides := seNumbersides.Value;
         temp.lineWidth := se_Linewidth.Value;
       end;
    2: temp.p[1] := Point(x, y);
    3: begin
         temp.p[2] := Point(x, y);
         SetLength(drawing, Length(drawing) + 1);
         drawing[High(drawing)] := temp;

         drawing[High(drawing)].fillColor := cbFillColor.ButtonColor;
         drawing[High(drawing)].borderColor := cbBorderColor.ButtonColor;

         pt_count := 0;
       end;
  end;

  PaintBox1.Refresh;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  a: Integer;
begin
  Label_pos.Caption := pos.x.ToString + ',' + pos.y.ToString;

  PaintBox1.Canvas.Brush.Style := bsSolid;

  for a := Low(drawing) to High(drawing) do
  begin

    PaintBox1.Canvas.Pen.Width := drawing[a].lineWidth;
    PaintBox1.Canvas.Pen.Style := drawing[a].PenStyle;
    DrawStar(drawing[a]);
  end;

  PaintBox1.Canvas.Brush.Style := bsClear;
  PaintBox1.Canvas.Brush.Color := clGreen;
  temp.p[pt_count] := pos;
  if pt_count = 1 then
    DrawRegPoly(temp)
  else if pt_count = 2 then
  begin
    PaintBox1.Canvas.Pen.Style := temp.PenStyle;
    DrawStar(temp);
  end;
end;

procedure TForm1.DrawRegPoly(star: TStar);
var
  pts: array of TPoint;
  radius: Integer;
  d: TPoint;
  angle, a_inc, rads: Single;
  a: Byte;
begin
  with star do
  begin
    d := Point(p[1].x - p[0].x, p[1].y - p[0].y);
    radius := Round(Sqrt(Sqr(d.x) + Sqr(d.y)));
    if d.x = 0 then
      d.x := 1;

    angle := ArcTan(d.y / d.x);
    if d.x > 0 then
      angle += Pi / 2
    else
      angle += 3 * Pi / 2;

    SetLength(pts, sides);
    a_inc := 2 * Pi / sides;
    for a := 0 to sides - 1 do
    begin
      rads := angle + a * a_inc;
      pts[a] := Point(p[0].x + Round(radius * Sin(rads)),
                      p[0].y - Round(radius * Cos(rads)));
    end;

    PaintBox1.Canvas.Polygon(pts);
  end;
end;

procedure TForm1.DrawStar(star: TStar);
var
  pts: array of TPoint;
  r1, r2, radius: Integer;
  d: TPoint;
  angle, a_inc, rads: Single;
  a: Byte;
begin
  with star do
  begin
    d := Point(p[2].x - p[0].x, p[2].y - p[0].y);
    r2 := Round(Sqrt(Sqr(d.x) + Sqr(d.y)));
    d := Point(p[1].x - p[0].x, p[1].y - p[0].y);
    r1 := Round(Sqrt(Sqr(d.x) + Sqr(d.y)));
    if d.x = 0 then
      d.x := 1;

    angle := ArcTan(d.y / d.x);
    if d.x > 0 then
      angle += Pi / 2
    else
      angle += 3 * Pi / 2;

    SetLength(pts, sides * 2);
    a_inc := Pi / sides;
    for a := 0 to sides * 2 - 1 do
    begin
      if Odd(a) then
        radius := r2
      else
        radius := r1;

      rads := angle + a * a_inc;
      pts[a] := Point(p[0].x + Round(radius * Sin(rads)),
                      p[0].y - Round(radius * Cos(rads)));
    end;
    // Set the fill and border colors to the stored colors from the TStar record
    PaintBox1.Canvas.Brush.Color := fillColor;
    PaintBox1.Canvas.Pen.Color := borderColor;

    PaintBox1.Canvas.Polygon(pts);
  end;
end;

procedure TForm1.seNumbersidesChange(Sender: TObject);
begin
  PaintBox1.Refresh;
end;

end.
