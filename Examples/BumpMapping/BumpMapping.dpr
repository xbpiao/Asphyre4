program BumpMapping;

uses
  Forms,
  MainFm in 'MainFm.pas' {MainForm},
  BumpMappingFx in 'BumpMappingFx.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
