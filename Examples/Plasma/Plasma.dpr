program Plasma;

uses
  Forms,
  MainFm in 'MainFm.pas' {MainForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
