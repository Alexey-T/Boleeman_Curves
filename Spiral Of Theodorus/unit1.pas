unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Spin,
  StdCtrls, Math, LCLIntf;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnSave: TButton;
    chkAltOrFill: TCheckBox;
    chkFill: TCheckBox;
    cbFromFill: TColorButton;
    cbToFill: TColorButton;
    cbBackcolor: TColorButton;
    Label1: TLabel;
    SaveDialog1: TSaveDialog;
    sbPencolor: TColorButton;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    seNumTriangs: TSpinEdit;
    seMybasesize: TSpinEdit;
    sePenwidth: TSpinEdit;
    seRotate: TSpinEdit;
    procedure btnSaveClick(Sender: TObject);
    procedure cbBackcolorColorChanged(Sender: TObject);
    procedure cbFromFillColorChanged(Sender: TObject);
    procedure cbToFillColorChanged(Sender: TObject);
    procedure chkAltOrFillChange(Sender: TObject);
    procedure chkFillChange(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure sbPencolorColorChanged(Sender: TObject);
    procedure seMybasesizeChange(Sender: TObject);
    procedure seNumTriangsChange(Sender: TObject);
    procedure sePenwidthChange(Sender: TObject);
    procedure seRotateChange(Sender: TObject);
  private
    rotpoint: TPoint;
    endpt: array of TPoint;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  adjLength: array of Integer;
  hypotenuse: array of Integer;
  NumTriangles: Integer;
  i, j, basesize: Integer;
  Angles, RotateAngle: Double;
  FromColor, ToColor, BackColor: TColor;
  CurrentColor: TColor;
  LineEndX, LineEndY: Integer;
begin
  rotpoint := Point(350, 350);
  NumTriangles := seNumTriangs.Value;
  basesize := seMybasesize.Value;
  RotateAngle := DegToRad(seRotate.Value);
  SetLength(endpt, NumTriangles + 1);
  SetLength(adjLength, NumTriangles);
  SetLength(hypotenuse, NumTriangles);
  PaintBox1.Canvas.Pen.Width := sePenwidth.Value;
  PaintBox1.Canvas.Pen.Color := sbPencolor.ButtonColor;
  PaintBox1.Canvas.Brush.Style := bsSolid;

  hypotenuse[0] := Round(Sqrt((basesize**2) + (basesize**2)));
  for i := 1 to NumTriangles - 1 do
    hypotenuse[i] := Round(Sqrt((hypotenuse[i - 1]**2) + (basesize**2)));


  LineEndX := Round(rotpoint.x + basesize * Cos(RotateAngle));
  LineEndY := Round(rotpoint.y - basesize * Sin(RotateAngle));
  endpt[0] := Point(LineEndX, LineEndY);

  LineEndX := Round(rotpoint.x + basesize * Cos(RotateAngle));
  LineEndY := Round(rotpoint.y + basesize * Sin(RotateAngle));
  endpt[1] := Point(LineEndX, LineEndY);

  FromColor := cbFromFill.ButtonColor;
  ToColor := cbToFill.ButtonColor;
  BackColor := cbBackcolor.ButtonColor;

  for i := 1 to NumTriangles do
  begin
    Angles := 0;
    for j := 1 to i do
      Angles := Angles + ArcTan(1/Sqrt(j));

    endpt[i] := Point(
      Round(rotpoint.x + hypotenuse[i - 1] * Cos(Angles + RotateAngle)),
      Round(rotpoint.y - hypotenuse[i - 1] * Sin(Angles + RotateAngle))
    );
  end;

  PaintBox1.Canvas.Brush.Color := BackColor;
  PaintBox1.Canvas.FillRect(PaintBox1.ClientRect);

  for i := NumTriangles - 1 downto 0 do
  begin
    adjLength[i] := Round(Sqrt((endpt[i].x - rotpoint.x)**2 + (endpt[i].y - rotpoint.y)**2));

    with PaintBox1.Canvas do
    begin
      MoveTo(rotpoint.x, rotpoint.y);
      LineTo(endpt[i].x, endpt[i].y);
      LineTo(endpt[i + 1].x, endpt[i + 1].y);
      LineTo(rotpoint.x, rotpoint.y);

      if chkFill.Checked then
      begin
        if chkAltOrFill.Checked and Odd(NumTriangles - i) then
          CurrentColor := cbFromFill.ButtonColor
        else
          CurrentColor := RGBToColor(
            Red(FromColor) + Round((i + 1) * (Red(ToColor) - Red(FromColor)) / NumTriangles),
            Green(FromColor) + Round((i + 1) * (Green(ToColor) - Green(FromColor)) / NumTriangles),
            Blue(FromColor) + Round((i + 1) * (Blue(ToColor) - Blue(FromColor)) / NumTriangles)
          );

        Brush.Color := CurrentColor;
        Polygon([rotpoint, endpt[i], endpt[i + 1]]);
      end;
    end;
  end;
end;

procedure TForm1.chkFillChange(Sender: TObject);
begin
  Paintbox1.Invalidate;
end;

procedure TForm1.cbToFillColorChanged(Sender: TObject);
begin
  Paintbox1.Invalidate;
end;

procedure TForm1.chkAltOrFillChange(Sender: TObject);
begin
  Paintbox1.Invalidate;
end;

procedure TForm1.cbFromFillColorChanged(Sender: TObject);
begin
  Paintbox1.Invalidate;
end;

procedure TForm1.cbBackcolorColorChanged(Sender: TObject);
begin
      Paintbox1.Invalidate;
end;

procedure TForm1.btnSaveClick(Sender: TObject);
var
  Picture: TPicture;
begin

  if SaveDialog1.Execute then
  begin

    Picture := TPicture.Create;
    try
      Picture.Bitmap.Width := PaintBox1.Width;
      Picture.Bitmap.Height := PaintBox1.Height;
      Picture.Bitmap.Canvas.CopyRect(PaintBox1.ClientRect, PaintBox1.Canvas, PaintBox1.ClientRect);
      Picture.SaveToFile(SaveDialog1.FileName);
    finally
      Picture.Free;
    end;
  end;
end;

procedure TForm1.sbPencolorColorChanged(Sender: TObject);
begin
    Paintbox1.Invalidate;
end;

procedure TForm1.seMybasesizeChange(Sender: TObject);
begin
    Paintbox1.Invalidate;
end;

procedure TForm1.seNumTriangsChange(Sender: TObject);
begin
  Paintbox1.Invalidate;
end;

procedure TForm1.sePenwidthChange(Sender: TObject);
begin
  Paintbox1.Invalidate;
end;

procedure TForm1.seRotateChange(Sender: TObject);
begin
      Paintbox1.Invalidate;
end;

end.

