unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Spin, Types,
  ComCtrls, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnSave: TButton;
    cbFillingcolor: TColorButton;
    cbFillingcolor2: TColorButton;
    cbLineColour: TColorButton;
    cbBackColor: TColorButton;
    comboLinestyles: TComboBox;
    Image1: TImage;
    lblMidsectionlength: TLabel;
    lblCentralPetalLength: TLabel;
    lblBackcolor: TLabel;
    lblVertShift: TLabel;
    lblTipOffset: TLabel;
    lblPetalwidth: TLabel;
    lblNumber: TLabel;
    lblFill: TLabel;
    lblLine: TLabel;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    seLineWidth: TSpinEdit;
    tbVerCent: TTrackBar;
    TrackBar1: TTrackBar;
    TrackBar5: TTrackBar;
    TrackBar4: TTrackBar;
    TrackBar3: TTrackBar;
    TrackBar2: TTrackBar;
    procedure btnSaveClick(Sender: TObject);
    procedure cbBackColorColorChanged(Sender: TObject);
    procedure cbFillingcolor2ColorChanged(Sender: TObject);
    procedure cbLineColourColorChanged(Sender: TObject);
    procedure cbFillingcolorColorChanged(Sender: TObject);
    procedure comboLinestylesChange(Sender: TObject);
    procedure comboLinestylesDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure Image1Paint(Sender: TObject);
    procedure seLineWidthChange(Sender: TObject);
    procedure tbVerCentChange(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure TrackBar4Change(Sender: TObject);
    procedure TrackBar5Change(Sender: TObject);

  private
    procedure DrawThePetals(TargetCanvas: TCanvas);
    procedure RPoint(Rotation: Single; CentreX: Single; CentreY: Single; X1: Single; Y1: Single; var X2: Single; var Y2: Single; var LineSegmentDistance: Single; Ratio: Single);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}


procedure TForm1.cbFillingcolorColorChanged(Sender: TObject);
begin
  Image1.Invalidate;
end;

procedure TForm1.comboLinestylesChange(Sender: TObject);
begin
  Image1.Invalidate;
end;

procedure TForm1.comboLinestylesDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
begin
  case (Control as TComboBox).Items[Index] of
    'Solid': (Control as TComboBox).Canvas.Pen.Style := psSolid;
    'Dash': (Control as TComboBox).Canvas.Pen.Style := psDash;
    'DashDot': (Control as TComboBox).Canvas.Pen.Style := psDashDot;
    'DashDotDot': (Control as TComboBox).Canvas.Pen.Style := psDashDotDot;
    'Dot': (Control as TComboBox).Canvas.Pen.Style := psDot;
    'Pattern': (Control as TComboBox).Canvas.Pen.Style := psPattern;
    'Clear': (Control as TComboBox).Canvas.Pen.Style := psClear;
  end;
  (Control as TComboBox).Canvas.Pen.Width := 3;
  (Control as TComboBox).Canvas.Pen.Color := clBlack;
  (Control as TComboBox).Canvas.Line(ARect.Left, ARect.Top + (ARect.Height div 2), ARect.Left + 50, ARect.Top + (ARect.Height div 2));
  (Control as TComboBox).Canvas.TextOut(ARect.Left + 60, ARect.Top, (Control as TComboBox).Items[Index]);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
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
  Image1Paint(Image1);
end;

procedure TForm1.Image1Paint(Sender: TObject);
begin
  // Set the background color of Image1
  Image1.Canvas.Brush.Color := cbBackColor.ButtonColor;
  Image1.Canvas.FillRect(0, 0, Image1.Width, Image1.Height);

  // Draw the petals
  DrawThePetals(Image1.Canvas);

  // Repaint the Image1 control to immediately update the displayed image
  Image1.Repaint;
end;

procedure TForm1.cbLineColourColorChanged(Sender: TObject);
begin
  Image1.Invalidate;
end;

procedure TForm1.cbFillingcolor2ColorChanged(Sender: TObject);
begin
  Image1.Invalidate;
end;

procedure TForm1.btnSaveClick(Sender: TObject);
var
  Png: TPortableNetworkGraphic;
begin
  Png := TPortableNetworkGraphic.Create;
  try
    // Set the dimensions of the PNG to match Image1
    Png.Width := Image1.Width;
    Png.Height := Image1.Height;

    // Create a temporary canvas to draw on the PNG
    Png.Canvas.Brush.Color := cbBackColor.ButtonColor;
    Png.Canvas.FillRect(0, 0, Png.Width, Png.Height);

    // Draw the petals on the PNG canvas
    DrawThePetals(Png.Canvas);

    // Save the contents of Png to a PNG file using SaveDialog
    if SaveDialog1.Execute then
      Png.SaveToFile(SaveDialog1.FileName);
  finally
    Png.Free;
  end;
end;

procedure TForm1.cbBackColorColorChanged(Sender: TObject);
begin
  Image1.Invalidate;
end;

procedure TForm1.seLineWidthChange(Sender: TObject);
begin
  Image1.Invalidate;
end;

procedure TForm1.tbVerCentChange(Sender: TObject);
begin
  Image1.Invalidate;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  Image1.Invalidate;
end;

procedure TForm1.TrackBar2Change(Sender: TObject);
begin
  Image1.Invalidate;
end;

procedure TForm1.TrackBar3Change(Sender: TObject);
begin
  Image1.Invalidate;
end;

procedure TForm1.TrackBar4Change(Sender: TObject);
begin
  Image1.Invalidate;
end;

procedure TForm1.TrackBar5Change(Sender: TObject);
begin
  Image1.Invalidate;
end;

procedure TForm1.DrawThePetals(TargetCanvas: TCanvas);
var
  Rotation: Single;
  CentreX, CentreY: Single;
  XPointArray, YPointArray: array[0..3] of Single;
  FillXPointCoordArray, FillYPointCoordArray: array[0..3] of Single;
  LineSegmentDistance: Single;
  PI: Double;
  FillingColorIndex: Integer;
  PenStyle: TPenStyle; // Add this variable to hold the pen style

  i, j, k: Integer;
begin
  PI := 3.14159265358979;
  FillingColorIndex := 0; // Start with the first filling color

  CentreX := Image1.Width / 2;
  CentreY := Image1.Height / 2 - tbVerCent.Position;
  lblVertShift.Caption:= 'Vertical Shift: ' + InttoStr(abs(tbVerCent.Position)) + ' px' ;
  TargetCanvas.Pen.Width := seLineWidth.Value;

  // Get the selected pen style
  case comboLinestyles.ItemIndex of
    0: PenStyle := psSolid;
    1: PenStyle := psDash;
    2: PenStyle := psDashDot;
    3: PenStyle := psDashDotDot;
    4: PenStyle := psDot;
    5: PenStyle := psPattern;
    6: PenStyle := psClear;
  else
    PenStyle := psSolid; // Default to solid if nothing is selected
  end;

  TargetCanvas.Pen.Style := PenStyle; // Set the pen style
  TargetCanvas.Pen.Color := cbLineColour.ButtonColor;
  TargetCanvas.Brush.Style := bsSolid;

  Rotation := 0;

  XPointArray[0] := CentreX + TrackBar5.Position;
  YPointArray[0] := CentreY + TrackBar3.Position;
  XPointArray[1] := CentreX + TrackBar4.Position;
  YPointArray[1] := CentreY - TrackBar2.Position + TrackBar3.Position;
  XPointArray[2] := CentreX + 2;
  YPointArray[2] := CentreY + TrackBar3.Position;
  XPointArray[3] := CentreX + TrackBar4.Position;
  YPointArray[3] := CentreY + TrackBar2.Position + TrackBar3.Position;
  lblPetalwidth.Caption:= 'Petal Width: ' + InttoStr(2*TrackBar2.Position) + ' px' ;
  lblTipOffset.Caption:= 'Inner Tip Offset:: ' + InttoStr(2*TrackBar3.Position) + ' px' ;
  lblMidsectionlength.Caption:= 'Mid-section Length: ' + InttoStr(2*TrackBar4.Position) + ' px' ;
  lblCentralPetalLength.Caption:= 'Mid-Petal Length: ' + InttoStr(TrackBar5.Position) + ' px' ;

  for j := 0 to 60 do
  begin
    for i := 0 to 3 do
    begin
      RPoint(Rotation, CentreX, CentreY, XPointArray[i], YPointArray[i], FillXPointCoordArray[i], FillYPointCoordArray[i], LineSegmentDistance, 1.0);
      if i > 0 then
        TargetCanvas.Line(Round(FillXPointCoordArray[i - 1]), Round(FillYPointCoordArray[i - 1]), Round(FillXPointCoordArray[i]), Round(FillYPointCoordArray[i]));
      if i = 3 then
      begin
        TargetCanvas.Line(Round(FillXPointCoordArray[3]), Round(FillYPointCoordArray[3]), Round(FillXPointCoordArray[0]), Round(FillYPointCoordArray[0]));
        // Toggle between filling colors
        if FillingColorIndex mod 2 = 0 then
          TargetCanvas.Brush.Color := cbFillingcolor.ButtonColor
        else
          TargetCanvas.Brush.Color := cbFillingcolor2.ButtonColor;
        TargetCanvas.Polygon([Point(Round(FillXPointCoordArray[0]), Round(FillYPointCoordArray[0])),
                                   Point(Round(FillXPointCoordArray[1]), Round(FillYPointCoordArray[1])),
                                   Point(Round(FillXPointCoordArray[2]), Round(FillYPointCoordArray[2])),
                                   Point(Round(FillXPointCoordArray[3]), Round(FillYPointCoordArray[3]))]);
        Inc(FillingColorIndex);
      end;
    end;

    Rotation := Rotation + (PI / TrackBar1.Position);
    lblNumber.Caption:= 'Number of Petals: ' + InttoStr(2*TrackBar1.Position) ;
  end;
end;

procedure TForm1.RPoint(Rotation: Single; CentreX: Single; CentreY: Single; X1: Single; Y1: Single; var X2: Single; var Y2: Single; var LineSegmentDistance: Single; Ratio: Single);
var
  AngleR: Double;
  TheGradient: Double;
  DistanceX, DistanceY: Single;
  PI: Double;
begin
  PI := 3.14159265358979;

  DistanceX := X1 - CentreX;
  if Ratio > 1 then
    DistanceX := DistanceX * Ratio;

  DistanceY := Y1 - CentreY;
  if Ratio < 1 then
    DistanceY := DistanceY * (1 / Ratio);

  if (DistanceX = 0) and (DistanceY = 0) then
  begin
    LineSegmentDistance := 0;
    X2 := X1;
    Y2 := Y1;
    Exit;
  end;

  LineSegmentDistance := Sqrt(DistanceX * DistanceX + DistanceY * DistanceY);

  if DistanceX <> 0 then
    TheGradient := DistanceY / DistanceX
  else
    TheGradient := PI * 96;

  AngleR := ArcTan(TheGradient) + Rotation;

  if (DistanceX < 0) or ((DistanceX = 0) and (DistanceY < 0)) then
    AngleR := AngleR + PI;

  X2 := Cos(AngleR) * LineSegmentDistance;
  if Ratio > 1 then
    X2 := X2 * (1 / Ratio);
  X2 := X2 + CentreX;

  Y2 := Sin(AngleR) * LineSegmentDistance;
  if Ratio < 1 then
    Y2 := Y2 * Ratio;
  Y2 := Y2 + CentreY;
end;

end.

end.

