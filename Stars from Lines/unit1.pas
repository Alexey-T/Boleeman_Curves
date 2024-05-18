unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Spin, Math, StdCtrls, Buttons;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnSave: TButton;
    cbLineColor: TColorButton;
    cbFillColor1: TColorButton;
    chkCircAtVert: TCheckBox;
    chkVertexLines: TCheckBox;
    chkFilled: TCheckBox;
    cbColorofVLines: TColorButton;
    cbBackcolor: TColorButton;
    cbCircBordercolor: TColorButton;
    cbCircFillcolor: TColorButton;
    Label10: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    seLineWidth: TSpinEdit;
    seCircSize: TSpinEdit;
    seCircBorderwidth: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    se_N: TSpinEdit;
    se_n1: TSpinEdit;
    seVLineWidth: TSpinEdit;
    procedure btnSaveClick(Sender: TObject);
    procedure cbCircBordercolorColorChanged(Sender: TObject);
    procedure cbCircFillcolorColorChanged(Sender: TObject);
    procedure cbFillColor1ColorChanged(Sender: TObject);
    procedure cbLineColorColorChanged(Sender: TObject);
    procedure chkFilledChange(Sender: TObject);
    procedure chkVertexLinesChange(Sender: TObject);
    procedure chkCircAtVertChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure seLineWidthChange(Sender: TObject);
    procedure se_n1Change(Sender: TObject);
    procedure se_NChange(Sender: TObject);
    procedure seVLineWidthChange(Sender: TObject);
    procedure cbColorofVLinesColorChanged(Sender: TObject);
    procedure cbBackcolorColorChanged(Sender: TObject);
    procedure seCircSizeChange(Sender: TObject);
    procedure seCircBorderwidthChange(Sender: TObject);
  private
    procedure DrawStars;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  se_N.Value := 23;
  se_n1.Value := 13;
  seLineWidth.Value := 10;
  seVLineWidth.Value := 2;
  seCircSize.Value := 18;
  seCircBorderwidth.Value := 2;
  cbLineColor.ButtonColor := clYellow;
  cbColorofVLines.ButtonColor := clMaroon;
  cbBackcolor.ButtonColor := TColor($00FFFF80);
  cbCircBordercolor.ButtonColor := clBlack;
  cbCircFillcolor.ButtonColor := clYellow;
  DrawStars;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  DrawStars;
end;

procedure TForm1.seLineWidthChange(Sender: TObject);
begin
  DrawStars;
end;

procedure TForm1.cbLineColorColorChanged(Sender: TObject);
begin
  DrawStars;
end;

procedure TForm1.chkFilledChange(Sender: TObject);
begin
  DrawStars;
end;

procedure TForm1.chkVertexLinesChange(Sender: TObject);
begin
  DrawStars;
end;

procedure TForm1.chkCircAtVertChange(Sender: TObject);
begin
  DrawStars;
end;

procedure TForm1.cbFillColor1ColorChanged(Sender: TObject);
begin
  DrawStars;
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

procedure TForm1.cbCircBordercolorColorChanged(Sender: TObject);
begin
    DrawStars;
end;

procedure TForm1.cbCircFillcolorColorChanged(Sender: TObject);
begin
    DrawStars;
end;

procedure TForm1.se_n1Change(Sender: TObject);
begin
  DrawStars;
end;

procedure TForm1.se_NChange(Sender: TObject);
begin
  DrawStars;
end;

procedure TForm1.seVLineWidthChange(Sender: TObject);
begin
  DrawStars;
end;

procedure TForm1.cbColorofVLinesColorChanged(Sender: TObject);
begin
  DrawStars;
end;

procedure TForm1.cbBackcolorColorChanged(Sender: TObject);
begin
  DrawStars;
end;

procedure TForm1.seCircSizeChange(Sender: TObject);
begin
  DrawStars;
end;

procedure TForm1.seCircBorderwidthChange(Sender: TObject);
begin
  DrawStars;
end;

procedure TForm1.DrawStars;
var
  a: Double;
  Center: TPoint;
  Radius: Integer;
  i, j: Integer;
  Points: array of TPoint;
begin
  PaintBox1.Canvas.Brush.Color := cbBackcolor.ButtonColor;
  PaintBox1.Canvas.FillRect(PaintBox1.ClientRect);

  a := -Pi / 2;
  Center := Point(PaintBox1.Width div 2, PaintBox1.Height div 2);
  Radius := Min(PaintBox1.Width, PaintBox1.Height) div 2 - 20;

  PaintBox1.Canvas.Pen.Width := seLineWidth.Value;
  PaintBox1.Canvas.Pen.Color := cbLineColor.ButtonColor;

  SetLength(Points, se_N.Value + 1);
  for i := 0 to se_N.Value do
  begin
    a += se_n1.Value * 2 * Pi / se_N.Value;
    Points[i].X := Round(Center.X + Radius * Cos(a));
    Points[i].Y := Round(Center.Y + Radius * Sin(a));
  end;

  PaintBox1.Canvas.Polyline(Points);

  if chkFilled.Checked then
  begin
    PaintBox1.Canvas.Brush.Color := cbFillColor1.ButtonColor;
    PaintBox1.Canvas.Polygon(Points);
  end;

  if chkVertexLines.Checked then
  begin
    PaintBox1.Canvas.Pen.Width := seVLineWidth.Value;
    PaintBox1.Canvas.Pen.Color := cbColorofVLines.ButtonColor;
    for i := 0 to High(Points) - 1 do
    begin
      for j := i + 1 to High(Points) - 1 do
      begin
        PaintBox1.Canvas.MoveTo(Points[i].X, Points[i].Y);
        PaintBox1.Canvas.LineTo(Points[j].X, Points[j].Y);
      end;
    end;
  end;

  if chkCircAtVert.Checked then
  begin
    PaintBox1.Canvas.Pen.Width := seCircBorderwidth.Value;
    PaintBox1.Canvas.Pen.Color := cbCircBordercolor.ButtonColor;
    PaintBox1.Canvas.Brush.Color := cbCircFillcolor.ButtonColor;
    for i := 0 to High(Points) - 1 do
    begin
      PaintBox1.Canvas.Ellipse(
        Points[i].X - seCircSize.Value div 2,
        Points[i].Y - seCircSize.Value div 2,
        Points[i].X + seCircSize.Value div 2,
        Points[i].Y + seCircSize.Value div 2
      );
    end;
  end;
end;

end.
