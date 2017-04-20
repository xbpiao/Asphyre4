unit MainFm;

//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AsphyreDevices, AsphyreTorusKnot, BumpMappingFx, Matrices3, Vectors2;

//---------------------------------------------------------------------------
type
  TMainForm = class(TForm)
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    GameTicks: Integer;

    Shader: TBumpMappingFx;
    Mesh  : TAsphyreTorusKnot;

    ShowWire: Boolean;

    procedure ConfigureDevice(Sender: TAsphyreDevice; Tag: TObject;
     var Config: TScreenConfig);
    procedure OnDeviceCreate(Sender: TObject; EventParam: Pointer;
     var Success: Boolean);
    procedure TimerEvent(Sender: TObject);
    procedure ProcessEvent(Sender: TObject);
    procedure RenderPrimary(Sender: TAsphyreDevice; Tag: TObject);
  public
    { Public declarations }
  end;

//---------------------------------------------------------------------------
var
  MainForm: TMainForm;

//---------------------------------------------------------------------------
implementation
uses
 Direct3D9, Vectors3, Matrices4, AsphyreTimer, AsphyreImages,
 AsphyreSystemFonts, AsphyreEvents, MediaImages, AsphyreColors, AsphyreScene,
 AsphyreMeshes, AsphyreShaderFX;
{$R *.dfm}

//---------------------------------------------------------------------------
var
 ImageSkin: Integer = -1;
 ImageBump: Integer = -1;

//---------------------------------------------------------------------------
procedure TMainForm.FormCreate(Sender: TObject);
begin
 ImageGroups.ParseLink('/images.xml');

 if (not Devices.Initialize(ConfigureDevice, Self)) then
  begin
   MessageDlg('Failed to initialize Asphyre device.', mtError, [mbOk], 0);
   Close();
   Exit;
  end;

 DefDevice.SysFonts.CreateFont('s/tahoma', 'tahoma', 9, False, fwtBold,
  fqtClearType, fctAnsi);

 // Create bump-mapping shader and load it from disk
 Shader:= TBumpMappingFx.Create(DefDevice);
 if (not Shader.LoadFromFile('BumpMapping.fx')) then
  begin
   Devices.Finalize();
   ShowMessage('Failed to load shader effect!');
   Close();
   Exit;
  end;

 // Create 3-4 torus knot
 Mesh:= TAsphyreTorusKnot.Create(DefDevice);
 Mesh.Generate(0.4, 0.1, 3, 4, 256, 24, 16.0, 1.0);
 // -> shader requires tanget and binormal vectors
 Mesh.ComputeTangetBinormal();

 Timer.Enabled  := True;
 Timer.OnTimer  := TimerEvent;
 Timer.OnProcess:= ProcessEvent;
 Timer.MaxFPS   := 200;

 ShowWire:= False;
end;

//---------------------------------------------------------------------------
procedure TMainForm.FormDestroy(Sender: TObject);
begin
 if (Mesh <> nil) then Mesh.Free();
 if (Shader <> nil) then Shader.Free();
 Devices.Finalize();
end;

//---------------------------------------------------------------------------
procedure TMainForm.ConfigureDevice(Sender: TAsphyreDevice; Tag: TObject;
 var Config: TScreenConfig);
begin
 Config.WindowHandle:= Self.Handle;
 Config.HardwareTL  := True;
 Config.DepthStencil:= dsDepthOnly;

 Config.Width   := ClientWidth;
 Config.Height  := ClientHeight;
 Config.Windowed:= False;
 Config.VSync   := False;
 Config.BitDepth:= bd24bit;

 Config.MultiSamples:= 8;

 EventDeviceCreate.Subscribe(OnDeviceCreate, Sender);
end;

//---------------------------------------------------------------------------
procedure TMainForm.OnDeviceCreate(Sender: TObject; EventParam: Pointer;
 var Success: Boolean);
begin
 with Sender as TAsphyreDevice do
  begin
   // Preload skins used with 3D mesh.
   ImageSkin:= Images.ResolveImage('metal');
   ImageBump:= Images.ResolveImage('metal_normal');
  end;
end;

//---------------------------------------------------------------------------
procedure TMainForm.TimerEvent(Sender: TObject);
begin
 DefDevice.Render(RenderPrimary, Self, $4E4438, 1.0, 0);

 Timer.Process();
end;

//---------------------------------------------------------------------------
procedure TMainForm.ProcessEvent(Sender: TObject);
begin
 Inc(GameTicks);
end;

//---------------------------------------------------------------------------
procedure TMainForm.RenderPrimary(Sender: TAsphyreDevice; Tag: TObject);
var
 Shift: TPoint2;
begin
 if (Failed(DefDevice.Dev9.TestCooperativeLevel())) then Exit;
 

 with DefDevice.Dev9 do
  begin
   SetRenderState(D3DRS_ZENABLE, D3DZB_TRUE);

   if (ShowWire) then
    begin
     SetRenderState(D3DRS_FILLMODE, D3DFILL_WIREFRAME);
     SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
    end else
    begin
     SetRenderState(D3DRS_FILLMODE, D3DFILL_SOLID);
     SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);
    end;
  end;

 // -> Viewing Camera
 ViewMtx.LoadIdentity();
 ViewMtx.LookAt(Vector3(5.0, 15.0, -15.0), ZeroVec3, AxisYVec3);

 // -> Projection Matrix
 ProjMtx.LoadIdentity();
 ProjMtx.PerspectiveFovY(Pi / 4.0, ClientWidth / ClientHeight, 0.5, 100.0);

 // -> Object transformation matrix
 WorldMtx.LoadIdentity();
 WorldMtx.Scale(12.0);
 WorldMtx.RotateX(GameTicks * 0.01);
 WorldMtx.RotateY(-GameTicks * 0.0067);
 WorldMtx.RotateZ(GameTicks * 0.0053);

 // -> Shader parameters
 Shader.AmbientColor := cColor(32);
 Shader.DiffuseColor := $FFFFFFFF;
 Shader.SpecularColor:= $808080;
 Shader.LightVector:= Vector3(1.0, -1.0, 1.0);

 // -> Transform texture coordinates to simulate motion
 if (not ShowWire) then
  begin
   Shift.x:= -GameTicks * 0.01;
   Shift.x:= Shift.x - Trunc(Shift.x);

   Shift.y:= GameTicks * 0.002;
   Shift.y:= Shift.y - Trunc(Shift.y);

   Shader.SkinMtx:= TranslateMtx3(Shift);
   Shader.BumpMtx:= Shader.SkinMtx;
  end else
  begin
   Shader.SkinMtx:= IdentityMtx3;
   Shader.BumpMtx:= IdentityMtx3;
  end;

 // Reset vertex and face drawing count.
 ResetDrawInfo();

 // Start rendering 3D scene.
 Shader.BeginAll();

 Shader.Draw(Mesh, WorldMtx.RawMtx^, Sender.Images[ImageSkin],
  Sender.Images[ImageBump]);

 // Finish rendering 3D scene.
 Shader.EndAll();

 // Output some text.
 with Sender.SysFonts.Font['s/tahoma'] do
  begin
   TextOut('Drawing ' + IntToStr(TotalFacesNo) + ' faces and ' +
    IntToStr(TotalVerticesNo) + ' vertices.', 4, 4, $FFEFDEB5);
   TextOut('Hit SPACE to switch between solid/wireframe mode.', 4, 24,
    $FFE1E9B0);

   case Sender.Params.MultiSampleType of
    D3DMULTISAMPLE_NONE,
    D3DMULTISAMPLE_NONMASKABLE:
     TextOut('No multisampling support.', 4, 44, $FFC9A0F1);

    D3DMULTISAMPLE_2_SAMPLES..D3DMULTISAMPLE_16_SAMPLES:
     TextOut(IntToStr(Integer(Sender.Params.MultiSampleType)) +
      'x multisampling used.', 4, 44, $FFC9A0F1);
   end;

   TextOut('Frame rate: ' + IntToStr(Timer.FrameRate), 4, 64, $FFE1E9B0);
  end;
end;

//---------------------------------------------------------------------------
procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
 Shift: TShiftState);
begin
 if (Key = VK_ESCAPE) then Close();
 if (Key = VK_SPACE) then ShowWire:= not ShowWire;
end;

//---------------------------------------------------------------------------
end.
