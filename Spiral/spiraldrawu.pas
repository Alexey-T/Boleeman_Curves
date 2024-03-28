unit SpiralDrawU;

{$mode objfpc}{$H+}

interface

uses
	Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
	Spin, Math;

type

	{ TSpiralForm }

 TSpiralForm = class(TForm)
		BStart: TButton;
		BExit: TButton;
		CBPause: TCheckBox;
		LSpeed: TLabel;
		Picture: TPanel;
		SESpeed: TSpinEdit;
		SpiralTimer: TTimer;
		procedure BExitClick(Sender: TObject);
  procedure BStartClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure SESpeedChange(Sender: TObject);
		procedure SpiralTimerTimer(Sender: TObject);

  function HsvToRgb(h, s, v: Double): TColor;
  function GetRgb(r, g, b: Double): TColor;
	private
//		Count:Integer;
  SpiralColor: TColor;
  CurrentPalette: array[0..255] of TColor;
  ColIndx: Integer;
	public

	end;

var
	SpiralForm: TSpiralForm;
 isPaused: Boolean = False;
 Delay:    Integer = 500;
implementation

{$R *.lfm}

{ TSpiralForm }

procedure TSpiralForm.BStartClick(Sender: TObject);
begin
 if(BStart.Caption = 'Start') then
 begin
   BStart.Caption := 'Stop';
   Picture.Refresh;
//   Count := 100;
   SpiralColor := 20200;
   SpiralTimer.Interval := SESpeed.Value;
   SpiralTimer.Enabled := True;
	end
 else
 begin
   BStart.Caption := 'Start';
   SpiralTimer.Enabled := False;
	end;
end;

function TSpiralForm.GetRgb(r, g, b: Double): TColor;
var
  Col: TColor;
begin
 Col := RGBToColor(byte(Round(r * 255.0)), byte(Round(g * 255.0)), byte(Round(b * 255.0)));
 exit(Col);
end;

function TSpiralForm.HsvToRgb(h, s, v: Double): TColor;
var
  hi: Integer;
  f, p, q, t: Double;
  Col: TColor;
begin
 hi := Round((Floor(h / 60.0) mod 6));
 f := (h / 60.0) - Floor(h / 60.0);

 p := v * (1.0 - s);
 q := v * (1.0 - (f * s));
 t := v * (1.0 - ((1.0 - f) * s));

 Col := GetRgb(0.0, 0.0, 0.0);
 case (hi) of
     0:
         Col := GetRgb(v, t, p);
     1:
         Col := GetRgb(q, v, p);
     2:
         Col := GetRgb(p, v, t);
     3:
         Col := GetRgb(p, q, v);
     4:
         Col := GetRgb(t, p, v);
     5:
         Col := GetRgb(v, p, q);
	end;

 exit(Col);
end;


procedure TSpiralForm.FormCreate(Sender: TObject);
var
 i: Integer;
 h: Double;
begin
 for i := 0 to 255 do
 begin
     h := (i /256.0 ) * 360.0;
     CurrentPalette[i] := HsvToRgb(h, 1.0, 1.0);
 end;
 ColIndx := 0;
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

procedure TSpiralForm.SpiralTimerTimer(Sender: TObject);
var
	cs, co, sn, si, cx, cy, x, y, ad, sf, xo: real;
	j, i: byte;
	xp, yp: Integer;
begin
 if (CBPause.Checked) then exit;
	cs := Cos(pi / 3);
	co := Cos(pi / 36);
	sn := Sin(pi / 3);
	si := Sin(pi / 36);
	cx := Round(Picture.Width/2);
	cy := Round(Picture.Height/2);
	ad := 1.16;
	sf := 1.06;
	xp := trunc(cx + 12 * ad);
	yp := trunc(cy + 0);
	Picture.Canvas.MoveTo(Xp,Yp);
 Picture.Canvas.Pen.Width := 2;
 SpiralTimer.Enabled := False;
//	SpiralForm.Caption := Count.ToString;
	x := 12;
	y := 0;
	for j := 0 to 70 do
	begin
	 for i := 0 to 6 do
	 begin
	  if(BStart.Caption = 'Start') then exit;
   SpiralColor := CurrentPalette[ColIndx];
			ColIndx := (ColIndx + 1) Mod 255;
	  Picture.Canvas.Pen.Color := SpiralColor;

	  xp := trunc(cx + x * ad);
	  yp := trunc(cy + y);

	  If (i = 0) Then Picture.Canvas.MoveTo(xp, yp);
	  Picture.Canvas.LineTo(xp, yp);
	  xo := x * cs - y * sn;
	  y := x * sn + y * cs;
	  x := xo;
	 end;
	 xo := sf * (x * co - y * si);
	 y := sf * (x * si + y * co);
	 x := xo;
	end;
 // for a limited count
{
 Dec(Count);
 if(Count = 0) then
 begin
  	SpiralTimer.Enabled := False;
   BStart.Caption := 'Start';
	end;
 }
	SpiralTimer.Enabled := True;
end;

end.

