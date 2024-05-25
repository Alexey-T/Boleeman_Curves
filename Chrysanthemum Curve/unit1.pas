unit Unit1;

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Math, Spin,
  ColorBox, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnSave: TButton;
    cbBackColor: TColorButton;
    chkMod2Select: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    seLinewidth: TSpinEdit;
    seScaleFactor: TSpinEdit;
    seC: TSpinEdit;
    seRec: TSpinEdit;
    seK: TSpinEdit;
    procedure btnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure cbBackColorColorChanged(Sender: TObject);
    procedure seKChange(Sender: TObject);
    procedure seLinewidthChange(Sender: TObject);
    procedure seScaleFactorChange(Sender: TObject);
    procedure seCChange(Sender: TObject);
    procedure seRecChange(Sender: TObject);
    procedure chkMod2SelectChange(Sender: TObject);
  private
    Colors: array of TColor;
    function GetColor(t: Double; Coeff: Double; Recip: Double): TColor;
    procedure DrawChrysanthemum;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

const
  N = 4000;
  PI = 3.14159265358979323846;
  TWOPI = 2 * PI;

type
  TPoint3D = record
    X, Y, Z: Double;
  end;

function TForm1.GetColor(t: Double; Coeff: Double; Recip: Double): TColor;
var
  index: Integer;
begin
  index := Trunc((Coeff * t) / (Recip * PI));
  if chkMod2Select.Checked then
    //Result := Colors[(index mod 2) * Length(Colors)]
      Result := Colors[index mod 2 * (Length(Colors)-1)]
  else
    Result := Colors[index mod Length(Colors)];
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SetLength(Colors, 24);
  Colors[0] := TColor($008000FF);   // Pink
  Colors[1] := clRed;
  Colors[2] := TColor($000080FF);   // Orange
  Colors[3] := clYellow;
  Colors[4] := clLime;
  Colors[5] := clAqua;   // Cyan
  Colors[6] := clBlue;
  Colors[7] := TColor($00FF0080);  // Violet
  Colors[8] := TColor($008000FF);  // Pink
  Colors[9] := clRed;
  Colors[10] := TColor($000080FF); // Orange
  Colors[11] := clYellow;
  Colors[12] := clLime;
  Colors[13] := clAqua;   // Cyan
  Colors[14] := clBlue;
  Colors[15] := TColor($00FF0080);  // Violet
  Colors[16] := TColor($008000FF);  // Pink
  Colors[17] := clRed;
  Colors[18] := TColor($000080FF); // Orange
  Colors[19] := clYellow;
  Colors[20] := clLime;
  Colors[21] := clAqua;   // subst. Cyan
  Colors[22] := clBlue;
  Colors[23] := TColor($00FF0080);  // Violet

  seLinewidth.Value := 2;
  seScaleFactor.Value := 39;
  cbBackColor.ButtonColor := clBlack;

  // Initialize new SpinEdits and CheckBox
  seC.Value := 1;
  seRec.Value := 1;
  chkMod2Select.Checked := False;
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

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  DrawChrysanthemum;
end;

procedure TForm1.cbBackColorColorChanged(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.seKChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.seLinewidthChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.seScaleFactorChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.seCChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.seRecChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.chkMod2SelectChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm1.DrawChrysanthemum;
var
  i,k, ScalingFactor: Integer;
  u, r, p4, p8: Double;
  p, plast: TPoint3D;
  CenterX, CenterY: Integer;
  Coeff, Recip: Double;
begin
  CenterX := PaintBox1.Width div 2;
  CenterY := PaintBox1.Height div 2;

  PaintBox1.Canvas.Brush.Color := cbBackColor.ButtonColor;
  PaintBox1.Canvas.FillRect(0, 0, PaintBox1.Width, PaintBox1.Height);

  PaintBox1.Canvas.Pen.Width := seLinewidth.Value;
  ScalingFactor := seScaleFactor.Value;
  Coeff := seC.Value;
  Recip := seRec.Value;
  k := seK.Value;

  for i := 0 to N do
  begin
    u := i * k * 21.0 * PI / N;
    p4 := Sin(17 * u / 3);
    p8 := Sin(2 * Cos(3 * u) - 28 * u);
    r := 5 * (1 + Sin(11 * u / 5)) - 4 * Power(p4, 4) * Power(p8, 8);
    p.X := r * Cos(u);
    p.Y := r * Sin(u);
    p.Z := (r / 20 + 0.2) * Sin(r * TWOPI / 7);

    if i > 0 then
    begin
      PaintBox1.Canvas.Pen.Color := GetColor(u, Coeff, Recip);
      PaintBox1.Canvas.LineTo(CenterX + Round(p.X * ScalingFactor), CenterY - Round(p.Y * ScalingFactor));
    end
    else
    begin
      PaintBox1.Canvas.MoveTo(CenterX + Round(p.X * ScalingFactor), CenterY - Round(p.Y * ScalingFactor));
    end;

    plast := p;
  end;
end;

end.
