unit MainFm;

// ---------------------------------------------------------------------------
interface

// ---------------------------------------------------------------------------
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, XPMan, ExtCtrls, ToolWin, StdCtrls,
  AsphyreSystemFonts, AsphyreDevices,
{$IFDEF AsphyreUseDx8}
  Direct3D8
{$ELSE}
  Direct3D9
{$ENDIF};

// ---------------------------------------------------------------------------
type
  TMainForm = class(TForm)
    XPManifest1: TXPManifest;
    StatusBar1: TStatusBar;
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
    Ticks: Integer;
    FIsStaickNeedRePaint: boolean;

    procedure ConfigureDevice(Sender: TAsphyreDevice; Tag: TObject;
      var Config: TScreenConfig);
    procedure DeviceReset(Sender: TAsphyreDevice; Tag: TObject;
      var Params: TD3DPresentParameters);
    procedure TimerEvent(Sender: TObject);
    procedure ProcessEvent(Sender: TObject);
    procedure DrawView(Sender: TAsphyreDevice; Tag: TObject);

    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);

    procedure WMEnterSizeMove(var msg: TMessage); message WM_ENTERSIZEMOVE;
    procedure WMExitSizeMove(var msg: TMessage); message WM_EXITSIZEMOVE;

  public
    { Public declarations }
  end;

  // ---------------------------------------------------------------------------
var
  MainForm: TMainForm;

  // ---------------------------------------------------------------------------
implementation

uses
  Vectors2px, MediaImages, MediaFonts, AsphyreTimer, GuiHelpers,
  GuiTypes, GuiShapeRep, GuiEdit, GuiButton, GuiForms, Vectors3;
{$R *.dfm}

// ---------------------------------------------------------------------------
procedure TMainForm.FormCreate(Sender: TObject);
begin
  ImageGroups.ParseLink('/images.xml');
  FontGroups.ParseLink('/fonts.xml');

  GuiShapes.ParseLink('/guidesc.xml');

  if (not Devices.Initialize(ConfigureDevice, Self)) then
  begin
    MessageDlg('Failed to initialize Asphyre device!', mtError, [mbOk], 0);
    Close();
    Exit;
  end;

  Timer.Enabled := True;
  Timer.OnTimer := TimerEvent;
  Timer.OnProcess := ProcessEvent;
  Timer.MaxFPS := 100;

  GuiUseDevice(DefDevice);
  GuiHelper.EventForm := Self;

  DefDevice.SysFonts.CreateFont('sys:tahoma', 'tahoma', 9, False, fwtHeavy,
    fqtClearType, fctAnsi);

  GuiHelper.Workspace.ParseLink('/guidesc.xml');

  TGuiButton(GuiHelper.Ctrl['Button1']).OnClick := Button1Click;
  TGuiButton(GuiHelper.Ctrl['Button2']).OnClick := Button2Click;
  // TGuiButton(GuiHelper.Ctrl['Button2']).CaptFont

  TGuiForm(GuiHelper.Ctrl['Form1']).Origin := Point2px(40, 40);
end;

// ---------------------------------------------------------------------------
procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Devices.Finalize();
end;

procedure TMainForm.FormPaint(Sender: TObject);
begin
  if FIsStaickNeedRePaint then
  begin // Õœ∂Ø ±ªÊ÷∆
    DefDevice.Render(DrawView, Self, $2680BA);
  end; // if
end;

// ---------------------------------------------------------------------------
procedure TMainForm.ConfigureDevice(Sender: TAsphyreDevice; Tag: TObject;
  var Config: TScreenConfig);
begin
  Config.WindowHandle := Self.Handle;
  Config.HardwareTL := False;
  Config.DepthStencil := dsNone;

  Config.Width := ClientWidth;
  Config.Height := ClientHeight;
  Config.Windowed := True;
  Config.VSync := False;
  Config.BitDepth := bd24bit;
end;

// ---------------------------------------------------------------------------
procedure TMainForm.FormResize(Sender: TObject);
begin
  DefDevice.Reset(DeviceReset, Self);
end;

// ---------------------------------------------------------------------------
procedure TMainForm.DeviceReset(Sender: TAsphyreDevice; Tag: TObject;
  var Params: TD3DPresentParameters);
begin
  Params.BackBufferWidth := ClientWidth;
  Params.BackBufferHeight := ClientHeight;
end;

// ---------------------------------------------------------------------------
procedure TMainForm.TimerEvent(Sender: TObject);
begin
  DefDevice.Render(DrawView, Self, $2680BA);
  Timer.Process();
end;

procedure TMainForm.WMEnterSizeMove(var msg: TMessage);
begin
  FIsStaickNeedRePaint := True;
end;

procedure TMainForm.WMExitSizeMove(var msg: TMessage);
begin
  FIsStaickNeedRePaint := False;
end;

// ---------------------------------------------------------------------------
procedure TMainForm.ProcessEvent(Sender: TObject);
begin
  Inc(Ticks);
  GuiHelper.Update();
end;

// ---------------------------------------------------------------------------
procedure TMainForm.DrawView(Sender: TAsphyreDevice; Tag: TObject);
begin
  GuiHelper.Draw();

  with Sender.SysFonts.Font['sys:tahoma'] do
  begin
    TextOut('FPS: ' + IntToStr(Timer.FrameRate) + ' ' + Format
        ('%1.2f %1.2f %1.2f', [Timer.Delta, Timer.Latency, Timer.Speed]), 4,
      ClientHeight - 40, $FF3F0BA2);
    TextOut(Format('Ticks=%d  %d, %d', [Ticks, Sizeof(TVector3),
        Sizeof(TD3DVector)]), 4, ClientHeight - 60, $FF3F0BA2);
{$IFDEF AsphyreUseDx8}
    TextOut('Use Dx8', 4, ClientHeight - 46, $FFFF0000);
{$ELSE}
    TextOut('Use Dx9', 4, ClientHeight - 46, $FFFF0000);
{$ENDIF}
  end; // with

end;

// ---------------------------------------------------------------------------
procedure TMainForm.Button1Click(Sender: TObject);
begin
  // Copy text from Edit1 to Edit2
  TGuiEdit(GuiHelper.Ctrl['Edit2']).Text := TGuiEdit(GuiHelper.Ctrl['Edit1'])
    .Text;

  // Change the string in Edit1
  TGuiEdit(GuiHelper.Ctrl['Edit1']).Text := 'Type text here';
end;

// ---------------------------------------------------------------------------
procedure TMainForm.Button2Click(Sender: TObject);
begin
  TGuiEdit(GuiHelper.Ctrl['Edit1']).Text := 'Cancelled!';
  TGuiEdit(GuiHelper.Ctrl['Edit2']).Text := 'Cancelled!';
end;

// ---------------------------------------------------------------------------
end.
