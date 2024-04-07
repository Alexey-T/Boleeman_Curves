unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Spin,
  StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnSave: TButton;
    csLineColor: TColorButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    seLevel: TSpinEdit;
    seLinewidth: TSpinEdit;
    procedure btnSaveClick(Sender: TObject);
    procedure csLineColorColorChanged(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure seLevelChange(Sender: TObject);
    procedure seLinewidthChange(Sender: TObject);
  private
    procedure SierpArrowhead(Order: Integer; Length: Single; Angle: Single; var posX, posY: Integer);
  public

  end;

var
  Form1: TForm1;
  Dir: Single;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.SierpArrowhead(Order: Integer; Length: Single; Angle: Single; var posX, posY: Integer);
begin
  if Order = 0 then
  begin
    posX += Trunc(Length * Cos(Dir));
    posY -= Trunc(Length * Sin(Dir));
    PaintBox1.Canvas.LineTo(posX, posY);
  end
  else
  begin
    SierpArrowhead(Order-1, Length/2, -Angle, posX, posY);
    Dir += Angle;
    SierpArrowhead(Order-1, Length/2, +Angle, posX, posY);
    Dir += Angle;
    SierpArrowhead(Order-1, Length/2, -Angle, posX, posY);
  end;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  posX, posY: Integer;
  Order: Integer;
  Length: Single;
  Sixtydegrees: Single;
  ScaleFactor: Single;
begin
  PaintBox1.Canvas.Brush.Color := clWhite;
  PaintBox1.Canvas.FillRect(0, 0, PaintBox1.Width, PaintBox1.Height);

  posX := -10 + PaintBox1.Width;
  posY := 100 + 3 * PaintBox1.Height div 4;
  Order := seLevel.Value;
  Length := 400.0;
  Sixtydegrees := Pi / 3.0;
  ScaleFactor := 1.97;

  Length := Length * ScaleFactor;

  PaintBox1.Canvas.Pen.Width:= seLinewidth.Value;
  PaintBox1.Canvas.Pen.Color := csLineColor.ButtonColor;
  PaintBox1.Canvas.MoveTo(posX, posY);

  Dir := 0.0;

  Dir += 2*Pi / 3.0;

  if (Order and 1) = 0 then
    Dir += Sixtydegrees;

  SierpArrowhead(Order, Length, Sixtydegrees, posX, posY);
end;

procedure TForm1.csLineColorColorChanged(Sender: TObject);
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

procedure TForm1.seLevelChange(Sender: TObject);
begin
    Paintbox1.Invalidate;
end;

procedure TForm1.seLinewidthChange(Sender: TObject);
begin
  Paintbox1.Invalidate;
end;



end.
