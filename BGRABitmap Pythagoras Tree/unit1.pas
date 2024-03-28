unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, PairSplitter, ExtCtrls,
  StdCtrls, ExtDlgs, ComCtrls, Menus, BGRABitmap, BGRABitmapTypes,
  BGRAGraphicControl, Types;

type

  { TForm1 }

  TForm1 = class(TForm)
    BGRAGraphicControl1: TBGRAGraphicControl;
    BPythagorasTree: TButton;
    BExit: TButton;
    BSavePicture: TButton;
    BLoadPicture: TButton;
    CBFilled: TCheckBox;
    cbBackColour: TColorButton;
    DOpenPicture: TOpenDialog;
    DSavePicture: TSaveDialog;
    Image1: TImage;
    MainMenu: TMainMenu;
    MenuIFile: TMenuItem;
    MenuLoadFile: TMenuItem;
    MenuSaveFile: TMenuItem;
    MStatus: TStatusBar;
    Panel1: TPanel;
    ScrollBox1: TScrollBox;
    chkOpaqOrTrans: TCheckBox;
    procedure BExitClick(Sender: TObject);
    procedure BLoadPictureClick(Sender: TObject);
    procedure BPythagorasTreeClick(Sender: TObject);
    procedure BSavePictureClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure MenuLoadFileClick(Sender: TObject);
    procedure MenuSaveFileClick(Sender: TObject);
    procedure RedrawOrig();
    procedure DrawPythagorasTree(x1, y1, x2, y2: Double; depth: Integer);
    procedure LoadPicture();
    procedure SavePicture(UseOpaqueBackground: Boolean);
    procedure ChangeScrollBoxColor;

  private
    PictOrig, PictOrigResized, PBOrig: TBGRABitmap;
    MPosXOrig, MPosYOrig: Integer;

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.BPythagorasTreeClick(Sender: TObject);
var
  w, h, w2, diff: Integer;
  TempBitmap: TBGRABitmap;
begin
  if Assigned(PBOrig) then
    PBOrig.Free;

  Image1.Refresh;
  MStatus.SimpleText := 'Width: ' + Image1.Width.ToString + ' Height: ' + Image1.Height.ToString;
  w := Image1.Width;
  h := w * 11 div 16;
  w2 := w div 2;
  diff := w div 12;

  PBOrig := TBGRABitmap.Create(w, h, BGRAPixelTransparent);

  DrawPythagorasTree(w2 - diff, h - 10, w2 + diff, h - 10, 0);

  TempBitmap := TBGRABitmap.Create(w, h, cbBackColour.ButtonColor);

  TempBitmap.PutImage(0, 0, PBOrig, dmSet);

  Image1.Picture.Assign(TempBitmap);
  Image1.Repaint;

  ChangeScrollBoxColor;

  TempBitmap.Free;
end;

procedure TForm1.ChangeScrollBoxColor;
begin
  if Assigned(ScrollBox1) and Assigned(cbBackColour) then
    ScrollBox1.Color := cbBackColour.ButtonColor;
end;

procedure TForm1.BSavePictureClick(Sender: TObject);
begin
  SavePicture(chkOpaqOrTrans.Checked);
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if PictOrig <> nil then
    FreeAndNil(PictOrig);
  if PictOrigResized <> nil then
    FreeAndNil(PictOrigResized);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  //ZoomOrig := 1.0;
end;

procedure TForm1.RedrawOrig();
begin
  if PictOrig = nil then
    Exit;
  if PictOrigResized <> nil then
    FreeAndNil(PictOrigResized);
  PictOrigResized := PBOrig.Resample(Trunc(PBOrig.Width), Trunc(PBOrig.Height));
  Image1.Picture.Assign(PictOrigResized);
  Image1.Repaint;
end;

procedure TForm1.DrawPythagorasTree(x1, y1, x2, y2: Double; depth: Integer);
var
  Pt: array[0..4] of TPointF;
  dx, dy, x3, y3, x4, y4, x5, y5: Double;
  Col: TBGRAPixel;
begin
  if depth > 10 then
    Exit;

  dx := x2 - x1;
  dy := y1 - y2;
  x3 := x2 - dy;
  y3 := y2 - dx;
  x4 := x1 - dy;
  y4 := y1 - dx;
  x5 := x4 + (dx - dy) / 2;
  y5 := y4 - (dx + dy) / 2;

  Col.red := 255 - ((depth * 75) mod 255);
  Col.green := 255 - ((depth * 25) mod 255);
  Col.blue := 130;
  Col.alpha := 120;

  Pt[0].X := x1;
  Pt[0].Y := y1;
  Pt[1].X := x2;
  Pt[1].Y := y2;
  Pt[2].X := x3;
  Pt[2].Y := y3;
  Pt[3].X := x4;
  Pt[3].Y := y4;
  Pt[4].X := x1;
  Pt[4].Y := y1;

  if CBFilled.Checked then
  begin
    PBOrig.FillPoly(Pt, Col, dmDrawWithTransparency, True);
  end
  else
  begin
    PBOrig.DrawPolyLineAntialias(Pt, Col, 2, BGRAPixelTransparent);
  end;
  DrawPythagorasTree(x4, y4, x5, y5, depth + 1);
  DrawPythagorasTree(x5, y5, x3, y3, depth + 1);
end;

procedure TForm1.LoadPicture;
var
  PictName: String;
begin
  if DOpenPicture.Execute then
  begin
    PictName := DOpenPicture.FileName;
    if PictName <> '' then
    begin
      if PictOrig <> nil then
        FreeAndNil(PictOrig);
      PictOrig := TBGRABitmap.Create;
      PictOrig.LoadFromFile(PictName);
      Image1.Picture.Assign(PictOrig);
      Image1.Repaint;
      MStatus.SimpleText := 'Width: ' + PictOrig.Width.ToString + ' Height: ' + PictOrig.Height.ToString;
    end;
  end;
end;

procedure TForm1.MenuLoadFileClick(Sender: TObject);
begin
  LoadPicture();
end;

procedure TForm1.BLoadPictureClick(Sender: TObject);
begin
  LoadPicture();
end;

procedure TForm1.SavePicture(UseOpaqueBackground: Boolean);
var
  PictName: String;
  SaveBitmap: TBGRABitmap;
begin
  if PBOrig = nil then
    Exit;

  if UseOpaqueBackground then
    SaveBitmap := TBGRABitmap.Create(Image1.Width, Image1.Height)
  else
    SaveBitmap := TBGRABitmap.Create(PBOrig.Width, PBOrig.Height);

  if UseOpaqueBackground then
    SaveBitmap.FillRect(0, 0, SaveBitmap.Width, SaveBitmap.Height, cbBackColour.ButtonColor);

  SaveBitmap.PutImage(0, 0, PBOrig, dmDrawWithTransparency);

  if DSavePicture.Execute then
  begin
    PictName := DSavePicture.FileName;
    if PictName <> '' then
      SaveBitmap.SaveToFile(PictName);
  end;

  SaveBitmap.Free;
end;

procedure TForm1.MenuSaveFileClick(Sender: TObject);
begin
  SavePicture(chkOpaqOrTrans.Checked);
end;

procedure TForm1.BExitClick(Sender: TObject);
begin
  Self.Close;
end;

end.
