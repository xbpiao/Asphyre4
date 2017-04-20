program Physic;

uses
  Forms,
  AdPhysics in 'AdPhysics.pas',
  MainFm in 'MainFm.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Andorra 2D Physics Demo';
  Application.CreateForm(TMainForm, MainForm);
  //  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
