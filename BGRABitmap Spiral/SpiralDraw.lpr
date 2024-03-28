program SpiralDraw;

{$mode objfpc}{$H+}

uses
	{$IFDEF UNIX}
	cthreads,
	{$ENDIF}
	{$IFDEF HASAMIGA}
	athreads,
	{$ENDIF}
	Interfaces, // this includes the LCL widgetset
	Forms, SpiralDrawU
	{ you can add units after this };

{$R *.res}

begin
	RequireDerivedFormResource := True;
	Application.Scaled := True;
	Application.Initialize;
	Application.CreateForm(TSpiralForm, SpiralForm);
	Application.Run;
end.

