unit Unit1;

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Math, Spin,
  ColorBox, StdCtrls, BGRABitmap, BGRABitmapTypes, BGRAGraphicControl;

type
  TForm1 = class(TForm)
    BGRAGraphicControl1: TBGRAGraphicControl;
    Panel1: TPanel;
    btnSave: TButton;
    cbBackColor: TColorButton;
    chkMod2Select: TCheckBox;
    cbMod2SelColor1: TColorButton;
    cbMod2SelColor2: TColorButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    SaveDialog1: TSaveDialog;
    seLinewidth: TSpinEdit;
    seScaleFactor: TSpinEdit;
    seC: TSpinEdit;
    seRec: TSpinEdit;
    seK: TSpinEdit;
    procedure btnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BGRAGraphicControl1Paint(Sender: TObject);
    procedure cbBackColorColorChanged(Sender: TObject);
    procedure seKChange(Sender: TObject);
    procedure seLinewidthChange(Sender: TObject);
    procedure seScaleFactorChange(Sender: TObject);
    procedure seCChange(Sender: TObject);
    procedure seRecChange(Sender: TObject);
    procedure chkMod2SelectChange(Sender: TObject);
    procedure cbMod2SelColor1ColorChanged(Sender: TObject);
    procedure cbMod2SelColor2ColorChanged(Sender: TObject);
  private
    Colors: array of TColor;
    bmp: TBGRABitmap;
    procedure UpdateColors;
    procedure DrawChrysanthemum;
    function GetColor(t: Double; Coeff: Double; Recip: Double): TColor;
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

procedure TForm1.FormCreate(Sender: TObject);
begin
  UpdateColors;

  seLinewidth.Value := 2;
  seScaleFactor.Value := 39;
  cbBackColor.ButtonColor := clBlack;

  seC.Value := 1;
  seRec.Value := 1;
  chkMod2Select.Checked := False;

  bmp := TBGRABitmap.Create(BGRAGraphicControl1.Width, BGRAGraphicControl1.Height, BGRA(0, 0, 0, 0));
end;

procedure TForm1.btnSaveClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    bmp.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TForm1.BGRAGraphicControl1Paint(Sender: TObject);
begin
  bmp.SetSize(BGRAGraphicControl1.Width, BGRAGraphicControl1.Height);
  DrawChrysanthemum;
  bmp.Draw(BGRAGraphicControl1.Canvas, 0, 0, True);
end;

procedure TForm1.cbBackColorColorChanged(Sender: TObject);
begin
  BGRAGraphicControl1.Invalidate;
end;

procedure TForm1.seKChange(Sender: TObject);
begin
  BGRAGraphicControl1.Invalidate;
end;

procedure TForm1.seLinewidthChange(Sender: TObject);
begin
  BGRAGraphicControl1.Invalidate;
end;

procedure TForm1.seScaleFactorChange(Sender: TObject);
begin
  BGRAGraphicControl1.Invalidate;
end;

procedure TForm1.seCChange(Sender: TObject);
begin
  BGRAGraphicControl1.Invalidate;
end;

procedure TForm1.seRecChange(Sender: TObject);
begin
  BGRAGraphicControl1.Invalidate;
end;

procedure TForm1.chkMod2SelectChange(Sender: TObject);
begin
  UpdateColors;
  BGRAGraphicControl1.Invalidate;
end;

procedure TForm1.cbMod2SelColor1ColorChanged(Sender: TObject);
begin
  if chkMod2Select.Checked then
  begin
    UpdateColors;
    BGRAGraphicControl1.Invalidate;
  end;
end;

procedure TForm1.cbMod2SelColor2ColorChanged(Sender: TObject);
begin
  if chkMod2Select.Checked then
  begin
    UpdateColors;
    BGRAGraphicControl1.Invalidate;
  end;
end;

procedure TForm1.UpdateColors;
begin
  if chkMod2Select.Checked then
  begin
    SetLength(Colors, 2);
    Colors[0] := cbMod2SelColor1.ButtonColor;
    Colors[1] := cbMod2SelColor2.ButtonColor;
  end
  else
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
    Colors[21] := clAqua;   // Cyan
    Colors[22] := clBlue;
    Colors[23] := TColor($00FF0080);  // Violet
  end;
end;

function TForm1.GetColor(t: Double; Coeff: Double; Recip: Double): TColor;
var
  index: Integer;
begin
  index := Trunc((Coeff * t) / (Recip * PI));
  if chkMod2Select.Checked then
    Result := Colors[index mod 2]
  else
    Result := Colors[index mod Length(Colors)];
end;

procedure TForm1.DrawChrysanthemum;
var
  i, k, ScalingFactor: Integer;
  u, r, p4, p8: Double;
  p, plast: TPoint3D;
  CenterX, CenterY: Integer;
  Coeff, Recip: Double;
  pt0, pt1: TPointF;
begin
  CenterX := bmp.Width div 2;
  CenterY := bmp.Height div 2;

  bmp.Fill(ColorToBGRA(cbBackColor.ButtonColor));

  bmp.Canvas2D.lineWidth := seLinewidth.Value;
  bmp.Canvas2D.antialiasing:= True;
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

    pt1 := PointF(CenterX + p.X * ScalingFactor, CenterY - p.Y * ScalingFactor);

    if i > 0 then
    begin
      bmp.Canvas2D.strokeStyle(ColorToBGRA(GetColor(u, Coeff, Recip)));
      bmp.Canvas2D.beginPath;
      bmp.Canvas2D.moveTo(pt0.X, pt0.Y);
      bmp.Canvas2D.lineTo(pt1.X, pt1.Y);
      bmp.Canvas2D.stroke;
    end;

    pt0 := pt1;
    plast := p;
  end;
end;

end.
