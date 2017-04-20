program Landscape;

uses
  Forms,
  MainFm in 'MainFm.pas' {MainForm},
  IsoUtil in 'IsoUtil.pas',
  IsoLandscape in 'IsoLandscape.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
