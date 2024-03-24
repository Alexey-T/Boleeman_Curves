program MazeMaker;

{$MODE Delphi}

uses
  Forms, Interfaces,
  ScreenMazeMaker in 'ScreenMazeMaker.pas' {FormMazeMaker},
  SpectraLibrary in 'SpectraLibrary.pas',
  ScreenPrintMaze in 'ScreenPrintMaze.pas' {FormPrintMaze},
  MazeLibrary in 'MazeLibrary.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMazeMaker, FormMazeMaker);
  Application.CreateForm(TFormPrintMaze, FormPrintMaze);
  Application.Run;
end.
