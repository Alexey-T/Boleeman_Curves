unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Spin,
  StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnSavePng: TButton;
    cbBackcolor: TColorButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    lblBackcolor: TLabel;
    lblLinewidth: TLabel;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    seLinewidth: TSpinEdit;
    procedure btnSavePngClick(Sender: TObject);
    procedure cbBackcolorColorChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure seLinewidthChange(Sender: TObject);
  private
    ColorsEnabled: array[1..8] of Boolean;
    enabledColors: array of Integer;
    procedure BuildWindow;
    procedure Peano(x, y, kk, i1, i2: Integer);
    procedure CheckBoxClick(Sender: TObject);
    function ColorByIndex(index: Integer): TColor;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.BuildWindow;
begin
  ClientWidth := 1150;
  ClientHeight := 980;
  Caption := 'Rainbow Peano Curve In Lazarus';
end;

function TForm1.ColorByIndex(index: Integer): TColor;
begin
  case index of
    1: Result := TColor($91C23D);
    2: Result := TColor($3DC2B0);
    3: Result := TColor($6E3DC2);
    4: Result := TColor($422CD3);
    5: Result := TColor($D32C6A);
    6: Result := clYellow;
    7: Result := TColor($2CD395);
    8: Result := clRed;
  else
    Result := clBlack; // Default color
  end;
end;

procedure TForm1.Peano(x, y, kk, i1, i2: Integer);
var
  thecolor: TColor;
  index, colorIndex, count: Integer;
  AtLeastOneEnabled: Boolean;
begin

  SetLength(enabledColors, 8);
  count := 0;
  // Check if at least one color is enabled
  AtLeastOneEnabled := False;
  for index := 1 to 8 do
  begin
    if ColorsEnabled[index] then
    begin
      Inc(count);
      enabledColors[count - 1] := index;
      AtLeastOneEnabled := True;
    end;
  end;

  // If no colors are selected, set the default color and show a message
 if not AtLeastOneEnabled then
begin
  ShowMessage('Cannot uncheck all checkboxes');
  // Set default color and other properties as needed
  ColorsEnabled[6] := True;
  //CheckBox6.Checked := ColorsEnabled[CheckBox6.Tag];   does not work with Tag
  CheckBox6.Checked := true ;
  Canvas.Pen.Color := ColorByIndex(6);
  Exit;
end;

  // Randomly select a color index from enabledColors array
  colorIndex := Random(count);
  // Set the color based on the selected color index
  thecolor := ColorByIndex(enabledColors[colorIndex]);

  if kk = 1 then
  begin
    Form1.Color := cbBackcolor.ButtonColor;
    Canvas.Pen.Width := 3;
    //.pen.Width := seLinewidth.Value;    Program has error when seLinewidth.Value is used. Why?
    Canvas.Pen.Color := thecolor;
    Canvas.LineTo(x * 12, y * 12);
    Exit;
  end;

  kk := kk div 3;

  Canvas.Pen.Width := 2;
  Canvas.Pen.Color := thecolor;

  Peano(x + 2 * i1 * kk, y + 2 * i1 * kk, kk, i1, i2);
  Peano(x + (i1 - i2 + 1) * kk, y + (i1 + i2) * kk, kk, i1, 1 - i2);
  Peano(x + kk, y + kk, kk, i1, 1 - i2);
  Peano(x + (i1 + i2) * kk, y + (i1 - i2 + 1) * kk, kk, 1 - i1, 1 - i2);
  Peano(x + 2 * i2 * kk, y + 2 * (1 - i2) * kk, kk, i1, i2);
  Peano(x + (1 + i2 - i1) * kk, y + (2 - i1 - i2) * kk, kk, i1, i2);
  Peano(x + 2 * (1 - i1) * kk, y + 2 * (1 - i1) * kk, kk, i1, i2);
  Peano(x + (2 - i1 - i2) * kk, y + (1 + i2 - i1) * kk, kk, 1 - i1, i2);
  Peano(x + 2 * (1 - i2) * kk, y + 2 * i2 * kk, kk, 1 - i1, i2);
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  Peano(0, 0, 3 * 3 * 3 * 3, 0, 0);
end;

procedure TForm1.seLinewidthChange(Sender: TObject);
begin
  invalidate;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
begin

  for i := Low(ColorsEnabled) to High(ColorsEnabled) do
      ColorsEnabled[i] := False;

   // Enable specific colors at startup
  ColorsEnabled[1] := True; // Enable color 1
  ColorsEnabled[3] := True;
  ColorsEnabled[5] := True;
  ColorsEnabled[7] := True;
  ColorsEnabled[8] := True;
    // Check the corresponding checkboxes
  CheckBox1.Checked := ColorsEnabled[CheckBox1.Tag];
  CheckBox3.Checked := ColorsEnabled[CheckBox3.Tag];
  CheckBox5.Checked := ColorsEnabled[CheckBox5.Tag];
  CheckBox7.Checked := ColorsEnabled[CheckBox7.Tag];
  CheckBox8.Checked := ColorsEnabled[CheckBox8.Tag];
     // Other initialization code...
  BuildWindow;
  Randomize;

  // Assign CheckBoxClick event handler to each checkbox
  CheckBox1.OnClick := @CheckBoxClick;
  CheckBox2.OnClick := @CheckBoxClick;
  CheckBox3.OnClick := @CheckBoxClick;
  CheckBox4.OnClick := @CheckBoxClick;
  CheckBox5.OnClick := @CheckBoxClick;
  CheckBox6.OnClick := @CheckBoxClick;
  CheckBox7.OnClick := @CheckBoxClick;
  CheckBox8.OnClick := @CheckBoxClick;
end;

procedure TForm1.cbBackcolorColorChanged(Sender: TObject);
begin
  invalidate;
end;

procedure TForm1.btnSavePngClick(Sender: TObject);
var
  Picture: TPicture;
begin

  if SaveDialog1.Execute then
  begin

    Picture := TPicture.Create;
    try
      Picture.Bitmap.Width := ClientWidth - Panel1.Width;
      Picture.Bitmap.Height := ClientHeight;
      Picture.Bitmap.Canvas.CopyRect(ClientRect, Canvas, ClientRect);
      Picture.SaveToFile(SaveDialog1.FileName);
    finally
      Picture.Free;
    end;
  end;
end;

procedure TForm1.CheckBoxClick(Sender: TObject);
var
  CheckBox: TCheckBox;
  Index, Count: Integer;
  AtLeastOneChecked: Boolean;
begin
  CheckBox := Sender as TCheckBox;
  Index := CheckBox.Tag;
  ColorsEnabled[Index] := CheckBox.Checked;

  // Check if at least one checkbox is checked
  AtLeastOneChecked := False;
  for Index := 1 to 8 do
  begin
    if ColorsEnabled[Index] then
    begin
      AtLeastOneChecked := True;
      Break;
    end;
  end;

  // Update ColorsEnabled based on the state of each checkbox
  if AtLeastOneChecked then
  begin
    if CheckBox = CheckBox1 then
      ColorsEnabled[1] := CheckBox.Checked
    else if CheckBox = CheckBox2 then
      ColorsEnabled[2] := CheckBox.Checked
    else if CheckBox = CheckBox3 then
      ColorsEnabled[3] := CheckBox.Checked
    else if CheckBox = CheckBox4 then
      ColorsEnabled[4] := CheckBox.Checked
    else if CheckBox = CheckBox5 then
      ColorsEnabled[5] := CheckBox.Checked
    else if CheckBox = CheckBox6 then
      ColorsEnabled[6] := CheckBox.Checked
    else if CheckBox = CheckBox7 then
      ColorsEnabled[7] := CheckBox.Checked
    else if CheckBox = CheckBox8 then
      ColorsEnabled[8] := CheckBox.Checked;

    // Re-populate enabledColors array
    Count := 0;
    SetLength(enabledColors, 0); // Clear the array
    for Index := 1 to 8 do
    begin
      if ColorsEnabled[Index] then
      begin
        Inc(Count);
        SetLength(enabledColors, Count);
        enabledColors[Count - 1] := Index;
      end;
    end;
  end
  else
  begin
    CheckBox.Checked := True; // Keep at least one checkbox checked
    Exit;
  end;
  Invalidate;
end;

end.

