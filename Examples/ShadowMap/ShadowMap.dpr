program ShadowMap;

{%File 'InovoFlux.fx'}

uses
  Forms,
  MainFm in 'MainFm.pas' {MainForm},
  InovoFluxFx in 'InovoFluxFx.pas',
  InovoScene in 'InovoScene.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
