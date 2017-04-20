unit MainFm;

//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
  Windows, SysUtils, Classes, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  AsphyreDevices, AsphyreTimer, AsphyrePalettes, AsphyreFonts;

//---------------------------------------------------------------------------
type
  TMainForm = class(TForm)
    PrimaryPanel: TPanel;
    Label1: TLabel;
    AuxiliaryPanel: TPanel;
    Label2: TLabel;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    Ticks: Integer;
    Chain: array[0..3] of Integer;

    DrawIndex: Integer;
    MixIndex : Integer;
    Palette  : TAsphyrePalette;

    DrawTicks: Integer;

    procedure SetupDevice(Sender: TAsphyreDevice; Tag: TObject;
     var Config: TScreenConfig);
    procedure OnDeviceCreate(Sender: TObject; EventParam: Pointer;
     var Success: Boolean);
    procedure OnDeviceReset(Sender: TObject; EventParam: Pointer;
     var Success: Boolean);
    procedure OnResolveFailed(Sender: TObject; EventParam: Pointer;
     var Success: Boolean);
    procedure TimerEvent(Sender: TObject);
    procedure ProcessEvent(Sender: TObject);
    procedure RenderPrimary(Sender: TAsphyreDevice; Tag: TObject);
    procedure RenderSecondary(Sender: TAsphyreDevice; Tag: TObject);
    procedure DrawMotion(Sender: TAsphyreDevice; Tag: TObject);
    procedure MixDrawings(Sender: TAsphyreDevice; Tag: TObject);
  public
    { Public declarations }
  end;

//---------------------------------------------------------------------------
var
  MainForm: TMainForm;

//---------------------------------------------------------------------------
implementation
uses
 AsphyreTypes, AsphyreEffects, MediaImages, MediaFonts, AsphyreEvents,
 AsphyreSystemFonts;
{$R *.dfm}

//---------------------------------------------------------------------------
const
 OrigPx: TPoint4px = (
  (x:   0 + 4; y: 0 + 4),
  (x: 256 - 1; y: 0 + 3),
  (x: 256 - 3; y: 256 - 1),
  (x:   0 + 1; y: 256 - 4));

//---------------------------------------------------------------------------
procedure TMainForm.FormCreate(Sender: TObject);
begin
 Palette:= TAsphyrePalette.Create();
 Palette.Add($FF9100FF, 0.0);
 Palette.Add($FF617BFF, 0.25);
 Palette.Add($FFFF6F00, 0.5);
 Palette.Add($FFFFB700, 0.75);
 Palette.Add($FFFFFFFF, 1.0);

 // retreive image and font descriptions
 ImageGroups.ParseLink('/media.xml');
 FontGroups.ParseLink('/media.xml');

 // configure Asphyre device(s)
 Devices.Count:= 1;
 if (not Devices.Initialize(SetupDevice, Self)) then
  begin
   MessageDlg('Failed to initialize Asphyre device', mtError, [mbOk], 0);
   Close();
   Exit;
  end;

 // configure Asphyre timer
 Timer.Enabled  := True;
 Timer.OnTimer  := TimerEvent;
 Timer.OnProcess:= ProcessEvent;
 Timer.MaxFPS   := 4000;

 DrawIndex:= 0;
 MixIndex := 0;
end;

//---------------------------------------------------------------------------
procedure TMainForm.FormDestroy(Sender: TObject);
begin
 Devices.Finalize();
 Palette.Free();
end;

//---------------------------------------------------------------------------
procedure TMainForm.SetupDevice(Sender: TAsphyreDevice; Tag: TObject;
 var Config: TScreenConfig);
begin
 // configure Asphyre device
 Config.Width   := 256;
 Config.Height  := 256;
 Config.Windowed:= True;

 Config.WindowHandle:= Self.Handle;
 Config.HardwareTL  := False;
 Config.DepthStencil := dsNone;

 EventDeviceCreate.Subscribe(OnDeviceCreate, Sender);
 EventDeviceReset.Subscribe(OnDeviceReset, Sender);
 EventResolveFailed.Subscribe(OnResolveFailed, Sender);
end;

//---------------------------------------------------------------------------
procedure TMainForm.OnDeviceCreate(Sender: TObject; EventParam: Pointer;
 var Success: Boolean);
begin
 // Here we create all static resources.
 if (Sender is TAsphyreDevice) then
   TAsphyreDevice(Sender).SysFonts.CreateFont('s/tahoma', 'tahoma', 14, False,
    fwtBold);
end;

//---------------------------------------------------------------------------
procedure TMainForm.OnDeviceReset(Sender: TObject; EventParam: Pointer;
 var Success: Boolean);
const
 ChainNames: array[0..3] of string = ('draw-1',
  'draw-2', 'mix-1', 'mix-2');
var
 i: Integer;
begin
 // Here we create all dynamic resources, which need to be recreated each
 // time the device is reset.
 if (Sender is TAsphyreDevice) then
  with Sender as TAsphyreDevice do
   begin
    for i:= 0 to High(ChainNames) do
     Chain[i]:=  Images.ResolveImage(ChainNames[i]);
   end;
end;

//---------------------------------------------------------------------------
procedure TMainForm.OnResolveFailed(Sender: TObject; EventParam: Pointer;
 var Success: Boolean);
begin
 Timer.Enabled:= False;

 MessageDlg('Failed to resolve symbol ' + PChar(EventParam), mtError,
  [mbOk], 0);

 Close();
end;

//---------------------------------------------------------------------------
procedure TMainForm.TimerEvent(Sender: TObject);
begin
 Devices[0].RenderTo(Chain[DrawIndex xor 1], DrawMotion, Self, $000000, 1.0, 0);
 Devices[0].RenderTo(Chain[2 + (MixIndex xor 1)], MixDrawings, Self);

 if (DrawTicks and $03 = 0) then
  Devices[0].Render(PrimaryPanel.Handle, RenderPrimary, Self, $000080);

 Devices[0].Render(AuxiliaryPanel.Handle, RenderSecondary, Self, $000000);

 DrawIndex:= DrawIndex xor 1;
 MixIndex := MixIndex xor 1;

 Timer.Process();

 Inc(DrawTicks);

 Caption:= 'Targets''n''Panels, FPS: ' + IntToStr(Timer.FrameRate);
end;

//---------------------------------------------------------------------------
procedure TMainForm.ProcessEvent(Sender: TObject);
begin
 Inc(Ticks);
end;

//---------------------------------------------------------------------------
procedure TMainForm.RenderPrimary(Sender: TAsphyreDevice; Tag: TObject);
begin
 with Sender.Canvas do
  begin
   // Draw some random primitives.
   FillQuad(pBounds4(2, 2, 50, 50), cColor4($FF00FF00, $FFFF0000, $FF0000FF,
    $FFFFFFFF), fxuNoBlend);

   FillQuad(pBounds4(54, 2, 50, 50), cColor4($FF000000, $FFFF00FF, $FFFFFF00,
    $FF00FFFF), fxuNoBlend);

   FillQuadEx(pBounds4(2, 54, 50, 50), cColor4($FF00FF00, $FFFF0000, $FF0000FF,
    $FFFFFFFF), fxuNoBlend);

   FillQuadEx(pBounds4(54, 54, 50, 50), cColor4($FF000000, $FFFF00FF,
    $FFFFFF00, $FF00FFFF), fxuNoBlend);

   FillArc(150, 150, 80, 70, Pi / 8, (Pi / 4) + Pi, 24, cColor4($FF00FF00,
    $FFFF0000, $FF0000FF, $FFFFFFFF), fxuNoBlend);

   // Draw the "motion" scene with alpha-channel on top of everything.
   UseImage(Sender.Images[Chain[DrawIndex]], pFlip4(pBounds4(0.0, 0.0, 1.0,
    1.0)));
   TexMap(pBounds4(0, 0, 256, 256), clWhite4, fxuBlend);
  end;

 Sender.SysFonts.Font['s/tahoma'].TextOut('System Font!', 4, 230, $FFFFFFFF);
 Sender.SysFonts.Font['s/tahoma'].TextOut('Unicode string :-)', 4, 210,
  $FF9745FF);
end;

//---------------------------------------------------------------------------
procedure TMainForm.RenderSecondary(Sender: TAsphyreDevice; Tag: TObject);
begin
 with Sender.Canvas do
  begin
   // Just render the "mixed" scene on the second panel.
   UseImage(Sender.Images[Chain[2 + MixIndex]], TexFull4);
   TexMap(pBounds4(0, 0, 256, 256), clWhite4, fxuBlend);

   with Sender.Fonts.Font['x/warmachine'] do
    begin
     Options.Kerning:= -6;
     TextOut('Future is here!', -2, 230, $FFFFFFFF);
    end;
  end;

 with Sender.Fonts.Font['x/acidreamer'] do
  begin
   Options.Kerning:= -8;
   TextOut('Some weird fonts can also be displayed', 0, 100, cColor2($FF7E00FF,
    $FFFFFFFF));
  end;

 with Sender.Fonts.Font['x/smallpaulo'] do
  begin
   Options.Kerning:= 1;
   TextOut('This very tiny font has no antialiasing!', 4, 30, $FFFFFFFF);
  end;
end;

//---------------------------------------------------------------------------
procedure TMainForm.DrawMotion(Sender: TAsphyreDevice; Tag: TObject);
var
 Theta, RibbonLength: Real;
begin
 // Draw some motion - moving ribbons and two soldiers moving from separate
 // directions.
 with Sender.Canvas do
  begin
   Theta:= (Ticks mod 200) * Pi / 100;
   RibbonLength:= (1.0 + Sin(Ticks / 50.0)) * Pi * 2 / 3 + (Pi / 3);

   FillRibbon(128, 128 - 32, 16.0, 24.0, 48.0, 32.0, Theta, Theta +
    RibbonLength, 24, Palette, fxuBlend or fxfDiffuse);

   Theta:= (-Ticks mod 100) * Pi / 50;
   RibbonLength:= (1.0 + Cos(Ticks / 37.0)) * Pi * 2 / 3 + (Pi / 3);

   FillRibbon(128, 128 + 32, 24.0, 16.0, 32.0, 48.0, Theta, Theta +
    RibbonLength, 24, Palette, fxuAdd or fxfDiffuse);

   Sender.SysFonts.Font['s/tahoma'].TextOut('Welcome!', -32 + (Ticks mod 288),
    180, $FFFFFFFF);
  end;
end;

//---------------------------------------------------------------------------
procedure TMainForm.MixDrawings(Sender: TAsphyreDevice; Tag: TObject);
begin
 with Sender.Canvas do
  begin
   // Copy previous scene, englarged and slightly rotated.
   UseImage(Sender.Images[Chain[2 + MixIndex]], OrigPx);
   TexMap(pBounds4(0, 0, 256, 256), clWhite4, fxuNoBlend);

   // Darken the area slightly, to avoid color mess :)
   // Replace color parameter to $FFF0F0F0 to reduce the effect.
   FillRect(0, 0, 256, 256, $FFF8F8F8, fxuMultiply);

   // Add the "motion scene" on our working surface. 
   UseImage(Sender.Images[Chain[DrawIndex]], TexFull4);
   TexMap(pBounds4(0, 0, 256, 256), cAlpha4(32), fxuAdd or fxfDiffuse);
  end;
end;

//---------------------------------------------------------------------------
end.
