unit SpiralDrawU;

{$mode objfpc}{$H+}

interface

uses
	Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
	Spin,
 BGRABitmap, BGRABitmapTypes, BGRAVirtualScreen;

type

	{ TSpiralForm }

 TSpiralForm = class(TForm)
		BStart: TButton;
		BExit: TButton;
		CBPause: TCheckBox;
		LSpeed: TLabel;
		Picture: TBGRAVirtualScreen;
		SESpeed: TSpinEdit;
		SpiralTimer: TTimer;
		procedure BExitClick(Sender: TObject);
  procedure BStartClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);

		procedure PictureRedraw(Sender: TObject; Bitmap: TBGRABitmap);
		procedure PictureResize(Sender: TObject);
		procedure SESpeedChange(Sender: TObject);
		procedure SpiralTimerTimer(Sender: TObject);

  procedure RedrawSpiral(Spiral: TBGRABitmap);

	private
  SpiralColor: TBGRAPixel;
  CurrentPalette: array[0..255] of TBGRAPixel;
  ColIndx: Integer;
	public

	end;

var
	SpiralForm: TSpiralForm;
 isPaused: Boolean = False;

const
 	cs = Cos(pi / 3);
 	co = Cos(pi / 36);
 	sn = Sin(pi / 3);
 	si = Sin(pi / 36);
 	ad = 1.16;
 	sf = 1.06;

implementation

{$R *.lfm}

{ TSpiralForm }

procedure TSpiralForm.BStartClick(Sender: TObject);
begin
 if(BStart.Caption = 'Start') then
 begin
   BStart.Caption := 'Stop';
   SpiralTimer.Interval := SESpeed.Value;
   SpiralTimer.Enabled := True;
	end
 else
 begin
   BStart.Caption := 'Start';
   SpiralTimer.Enabled := False;
	end;
end;

procedure TSpiralForm.FormCreate(Sender: TObject);
var
 i: Integer;
begin
 for i := 0 to 255 do
  CurrentPalette[i] := HSLA(i*256, 65535, 32768);
 ColIndx := 0;
end;

procedure TSpiralForm.PictureRedraw(Sender: TObject; Bitmap: TBGRABitmap);
var
 TimerEnabled: Boolean;
begin
 TimerEnabled := SpiralTimer.Enabled;
 if TimerEnabled then SpiralTimer.Enabled := False;
 RedrawSpiral(Bitmap);
 if TimerEnabled then SpiralTimer.Enabled := True;
end;

procedure TSpiralForm.PictureResize(Sender: TObject);
begin
 Picture.RedrawBitmap;
end;

procedure TSpiralForm.BExitClick(Sender: TObject);
begin
 SpiralTimer.Enabled := False;
 Close;
end;

procedure TSpiralForm.SESpeedChange(Sender: TObject);
begin
 SpiralTimer.Interval := SESpeed.Value;
end;

procedure TSpiralForm.RedrawSpiral(Spiral: TBGRABitmap);
var
 cx, cy, x, y, xo: Real;
	j, i: byte;
	xp, yp: Integer;
begin
	cx := Round(Spiral.Width/2);
	cy := Round(Spiral.Height/2);

 Spiral.Fill(clBlackOpaque);

 SpiralTimer.Enabled := False;
	x := 12;
	y := 0;
	for j := 0 to 70 do
	begin
	 for i := 0 to 6 do
	 begin

			SpiralColor := CurrentPalette[ColIndx];
			ColIndx := (ColIndx + 1) Mod 255;
   with Spiral.Canvas do
   begin
    Pen.Width := 2;
  		Pen.Color := SpiralColor;

		  xp := trunc(cx + x * ad);
		  yp := trunc(cy + y);

		  If (i = 0) Then MoveTo(xp, yp);
		  LineTo(xp, yp);
		  xo := x * cs - y * sn;
		  y := x * sn + y * cs;
		  x := xo;
			end;
		end;
	 xo := sf * (x * co - y * si);
	 y := sf * (x * si + y * co);
	 x := xo;
	end;
end;

procedure TSpiralForm.SpiralTimerTimer(Sender: TObject);
begin
 if (CBPause.Checked) then exit;
 SpiralTimer.Enabled := False;
 Picture.RedrawBitmap;
	SpiralTimer.Enabled := True;
end;

end.

