program BasicShdr;

uses
  Forms,
  MainFm in 'MainFm.pas' {MainForm},
  ExampleObjects in 'ExampleObjects.pas',
  CookTorranceFx in 'CookTorranceFx.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
