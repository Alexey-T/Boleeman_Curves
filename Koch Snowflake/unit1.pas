unit Unit1;

{$mode objfpc}{$H+}
//{$MODE Delphi}
interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, Buttons,
  Spin, ExtCtrls, StdCtrls, ExtDlgs, Menus, Math, Clipbrd;

type

  { TForm1 }

  TForm1 = class(TForm)
    cb_linecolour: TColorButton;
    cb_backcolour: TColorButton;
    Copierlimage1: TMenuItem;
    Enregistrerlimage1: TMenuItem;
    Image1: TImage;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    SavePictureDialog1: TSavePictureDialog;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpinEdit1: TSpinEdit;
    se_linethickness: TSpinEdit;
    Timer1: TTimer;
    ToolBar1: TToolBar;
    procedure cb_backcolourColorChanged(Sender: TObject);
    procedure cb_linecolourColorChanged(Sender: TObject);
    procedure Label2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Label2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Label3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Label3MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure se_linethicknessChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure TracerKoch(xA, yA, xB, yB, p : Integer);
    procedure Label1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Label1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure Enregistrerlimage1Click(Sender: TObject);
    procedure Copierlimage1Click(Sender: TObject);
    procedure FormConstrainedResize(Sender: TObject; var MinWidth,
      MinHeight, MaxWidth, MaxHeight: Integer);
    procedure SpinEdit1KeyPress(Sender: TObject; var Key: Char);
    procedure Placement;
  private

  public

    var
  Form1: TForm1;
  bmp : TBitmap;
  Lbl : TLabel;

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.TracerKoch(xA, yA, xB, yB, p : Integer);
var xC, yC, xD, yD, xE, yE : Integer;
begin
  if p = 0 then bmp.Canvas.LineTo(xB, yB)
  else begin
    xC := round(xA + (xB - xA)/3);
    yC := round(yA + (yB - yA)/3);
    xD := round(xB - (xB - xA)/3);
    yD := round(yB - (yB - yA)/3);
    xE := round(xC + (xD - xC)/2 + (yD - yC)*sqrt(3)/2);
    yE := round(yC + (yD - yC)/2 - (xD - xC)*sqrt(3)/2);
    Dec(p);
    TracerKoch(xA, yA, xC, yC, p);
    TracerKoch(xC, yC, xE, yE, p);
    TracerKoch(xE, yE, xD, yD, p);
    TracerKoch(xD, yD, xB, yB, p);
  end;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
var t0, t, f : Int64;
begin
  if ActiveControl = SpinEdit1 then ActiveControl := nil;
  PopupMenu1.AutoPopup := false;
  bmp := TBitmap.Create;
  try
    bmp.PixelFormat := pf24bit;
    bmp.Width := Image1.Width;
    bmp.Height := Image1.Height;
    bmp.Canvas.Pen.Color := cb_linecolour.ButtonColor;
    bmp.Canvas.Pen.Width := se_linethickness.Value;
    Bmp.Canvas.Brush.Color := cb_backcolour.ButtonColor;
    Bmp.Canvas.FillRect(Rect(0,0,Image1.Width,Image1.Height));
    //Image1.Canvas.Draw(0,0,Bmp);
    bmp.Canvas.PenPos := Point(Label1.Left+3, Label1.Top+7);
    if SpeedButton4.Down then begin
      TracerKoch(Label1.Left+3, Label1.Top+7, Label2.Left+3, Label2.Top+7, SpinEdit1.Value);
      TracerKoch(Label2.Left+3, Label2.Top+7, Label3.Left+3, Label3.Top+7, SpinEdit1.Value);
      TracerKoch(Label3.Left+3, Label3.Top+7, Label1.Left+3, Label1.Top+7, SpinEdit1.Value);
    end
    else if SpeedButton5.Down then begin
      TracerKoch(Label1.Left+3, Label1.Top+7, Label3.Left+3, Label3.Top+7, SpinEdit1.Value);
      TracerKoch(Label3.Left+3, Label3.Top+7, Label2.Left+3, Label2.Top+7, SpinEdit1.Value);
      TracerKoch(Label2.Left+3, Label2.Top+7, Label1.Left+3, Label1.Top+7, SpinEdit1.Value);
    end
    else TracerKoch(Label1.Left+3, Label1.Top+7, Label2.Left+3, Label2.Top+7, SpinEdit1.Value);
    Image1.Picture.Assign(bmp);
    Image1.Invalidate;
  finally
    bmp.Free;
  end;

  Caption := 'Koch Snowflake Curve';
  PopupMenu1.AutoPopup := true;
end;

procedure TForm1.Label2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Lbl := TLabel(Sender);
  Timer1.Enabled := true;
end;

procedure TForm1.cb_linecolourColorChanged(Sender: TObject);
begin
    image1.Canvas.Pen.Color := cb_linecolour.ButtonColor;
    SpeedButton1Click(self);
end;

procedure TForm1.cb_backcolourColorChanged(Sender: TObject);
begin
  image1.Canvas.Brush.Color := cb_backcolour.ButtonColor;
  SpeedButton1Click(self);
end;

procedure TForm1.Label2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Timer1.Enabled := false;
end;

procedure TForm1.Label3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Lbl := TLabel(Sender);
  Timer1.Enabled := true;
end;

procedure TForm1.Label3MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Timer1.Enabled := false;
end;

procedure TForm1.se_linethicknessChange(Sender: TObject);
begin
        image1.Canvas.Pen.Width := se_linethickness.Value;
        SpeedButton1Click(self);
end;

procedure TForm1.Label1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Lbl := TLabel(Sender);
  Timer1.Enabled := true;
end;

procedure TForm1.Label1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Timer1.Enabled := false;
end;

procedure TForm1.Placement;
var
  O : Real;
  r : Integer;
begin
  try
    r := round(Hypot(Lbl.Left-Image1.Width/2, Lbl.Top-Image1.Height/2));
    O := ArcSin((Lbl.Top-Image1.Height/2)/r);
    if Lbl.Left < Panel1.Width/2 then O := -O + Pi;
    if Lbl = Label1 then begin
      Label2.Left := round(Image1.Width/2+r*Cos(O+Pi*2/3));
      Label2.Top := round(Image1.Height/2+r*Sin(O+Pi*2/3));
      Label3.Left := round(Image1.Width/2+r*Cos(O+Pi*4/3));
      Label3.Top := round(Image1.Height/2+r*Sin(O+Pi*4/3));
    end
    else if Lbl = Label2 then begin
      Label3.Left := round(Image1.Width/2+r*Cos(O+Pi*2/3));
      Label3.Top := round(Image1.Height/2+r*Sin(O+Pi*2/3));
      Label1.Left := round(Image1.Width/2+r*Cos(O+Pi*4/3));
      Label1.Top := round(Image1.Height/2+r*Sin(O+Pi*4/3));
    end
    else begin
      Label1.Left := round(Image1.Width/2+r*Cos(O+Pi*2/3));
      Label1.Top := round(Image1.Height/2+r*Sin(O+Pi*2/3));
      Label2.Left := round(Image1.Width/2+r*Cos(O+Pi*4/3));
      Label2.Top := round(Image1.Height/2+r*Sin(O+Pi*4/3));
    end;
  except
    on EInvalidOp do exit;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if SpeedButton2.Down then begin
    Lbl.Left := Mouse.CursorPos.X - Left - 8;
    Lbl.Top := Mouse.CursorPos.Y - Top - 62;
  end
  else begin
    Lbl.Left := Mouse.CursorPos.X - Left - 8;
    Lbl.Top := Mouse.CursorPos.Y - Top - 62;
    Placement;
  end;
end;

procedure TForm1.FormConstrainedResize(Sender: TObject; var MinWidth,
  MinHeight, MaxWidth, MaxHeight: Integer);
begin
  MinWidth := 241;
  MinHeight := 270;
end;

procedure TForm1.SpinEdit1KeyPress(Sender: TObject; var Key: Char);
begin
  if (Key in ['-', '+', '.']) then begin
    Key := #0;
    Beep;
  end;
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
  Lbl := Label2;
  Placement;
  Label3.Show;
  SpeedButton1Click(self);
end;

procedure TForm1.SpeedButton5Click(Sender: TObject);
begin
    Placement;
    SpeedButton1Click(self);
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
     SpeedButton1Click(self);
end;

procedure TForm1.Enregistrerlimage1Click(Sender: TObject);
begin
  if SavePictureDialog1.Execute then Image1.Picture.SaveToFile(SavePictureDialog1.FileName);
end;

procedure TForm1.Copierlimage1Click(Sender: TObject);
begin
  ClipBoard.Assign(Image1.Picture);
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
  Label3.Hide;
  SpeedButton1Click(self);
end;

end.

