unit MainFm;

//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AsphyreDevices, AsphyreTorusKnot, AsphyreSuperEllipsoid,
  AsphyrePlaneMesh, AsphyreMeshes, InovoScene, Matrices3, Vectors2,
  AsphyreMatrices;

//---------------------------------------------------------------------------
type
  TMainForm = class(TForm)
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    GameTicks: Integer;

    MeshPlane: TAsphyrePlaneMesh;
    MeshKnot : TAsphyreTorusKnot;
    MeshSuper: TAsphyreSuperEllipsoid;

    UseProj: Boolean;

    World: TAsphyreMatrix;
    Scene: TInovoScene;

    procedure ConfigureDevice(Sender: TAsphyreDevice; Tag: TObject;
     var Config: TScreenConfig);
    procedure OnDeviceCreate(Sender: TObject; EventParam: Pointer;
     var Success: Boolean);
    procedure OnDeviceReset(Sender: TObject; EventParam: Pointer;
     var Success: Boolean);
    procedure TimerEvent(Sender: TObject);
    procedure ProcessEvent(Sender: TObject);

    procedure RenderPrimary(Sender: TAsphyreDevice; Tag: TObject);
    procedure MakeScene();
  public
    { Public declarations }
  end;

//---------------------------------------------------------------------------
var
  MainForm: TMainForm;

//---------------------------------------------------------------------------
implementation
uses
 Direct3D9, Vectors3, AsphyreTimer, AsphyreSystemFonts, AsphyreEvents,
 MediaImages;
{$R *.dfm}

//---------------------------------------------------------------------------
var
 ImageFloor : Integer = -1;
 ImageFloorN: Integer = -1;
 ImageKnot  : Integer = -1;
 ImageKnotN : Integer = -1;
 ImageSmiley: Integer = -1;
 ImageShadow: Integer = -1;

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

 Scene:= TInovoScene.Create(DefDevice);
 if (not Scene.Shader.LoadFromFile('InovoFlux.fx')) then
  begin
   Devices.Finalize();
   ShowMessage('Failed to load InovoFlux.fx');
   Close();
   Exit;
  end;

 World:= TAsphyreMatrix.Create();

 // Create meshes that will be used in our scene.
 MeshKnot:= TAsphyreTorusKnot.Create(DefDevice);
 MeshKnot.Generate(0.4, 0.08, 3, 2, 256, 24, 16.0, 1.0);
 MeshKnot.ComputeTangetBinormal();

 MeshSuper:= TAsphyreSuperEllipsoid.Create(DefDevice);
 MeshSuper.Generate(80, 5.0, 5.0);
 MeshSuper.ComputeTangetBinormal();

 MeshPlane:= TAsphyrePlaneMesh.Create(DefDevice);
 MeshPlane.Generate(1, 1, 1.0, 1.0, 8.0, 8.0);

 // Configure the scene light.
 Scene.Light.Position := Vector3(10.0, 20.0, -30.0);
 Scene.Light.Direction:= Norm3(ZeroVec3 - Scene.Light.Position);

 Scene.Light.FieldOfView:= Pi * 0.25;
 Scene.Light.NearPlane  := 0.5;
 Scene.Light.FarPlane   := 400.0;
 Scene.Light.AspectRatio:= 1.0;

 // Setup application timer.
 Timer.Enabled  := True;
 Timer.OnTimer  := TimerEvent;
 Timer.OnProcess:= ProcessEvent;
 Timer.MaxFPS   := 200;

 UseProj:= False;
end;

//---------------------------------------------------------------------------
procedure TMainForm.FormDestroy(Sender: TObject);
begin
 World.Free();
 Scene.Free();

 MeshPlane.Free();
 MeshSuper.Free();
 MeshKnot.Free();

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
 EventDeviceReset.Subscribe(OnDeviceReset, Sender);
end;

//---------------------------------------------------------------------------
procedure TMainForm.OnDeviceCreate(Sender: TObject; EventParam: Pointer;
 var Success: Boolean);
begin
 with Sender as TAsphyreDevice do
  begin
   ImageFloor := Images.ResolveImage('Floor');
   ImageFloorN:= Images.ResolveImage('FloorNormal');
   ImageKnot  := Images.ResolveImage('Knot');
   ImageKnotN := Images.ResolveImage('KnotNormal');
   ImageSmiley:= Images.ResolveImage('Smiley');
  end;
end;

//---------------------------------------------------------------------------
procedure TMainForm.OnDeviceReset(Sender: TObject; EventParam: Pointer;
 var Success: Boolean);
begin
 with Sender as TAsphyreDevice do
  begin
   ImageShadow:= Images.ResolveImage('shadowmap');
  end;
end;

//---------------------------------------------------------------------------
procedure TMainForm.TimerEvent(Sender: TObject);
begin
 // Reset drawing primitive counters.
 ResetDrawInfo();

 // Set some relevant Direct3D states
 with DefDevice.Dev9 do
  begin
   SetRenderState(D3DRS_ZENABLE, D3DZB_TRUE);
   SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);
  end;

 // Begin drawing a new 3D scene.
 Scene.ResetScene();

 // Build the 3D scene.
 MakeScene();

 // Render the scene from light's perspective that will be used for shadow
 // mapping, if necessary.
 if (not UseProj) then
  begin
   Scene.ShadowMap:= ImageShadow;
   Scene.RenderShadowMap();
  end else Scene.ShadowMap:= ImageSmiley;

 DefDevice.Render(RenderPrimary, Self, 0, 1.0, 0);

 Timer.Process();
end;

//---------------------------------------------------------------------------
procedure TMainForm.ProcessEvent(Sender: TObject);
begin
 Inc(GameTicks);
end;

//---------------------------------------------------------------------------
procedure TMainForm.RenderPrimary(Sender: TAsphyreDevice; Tag: TObject);
begin
 // Render the scene from camera's perspective.
 with Scene do
  begin
   View.LoadIdentity();
   View.LookAt(Vector3(11.0, 16.0, -11.0), Vector3(-5.0, 1.0, 5.0), AxisYVec3);

   Proj.LoadIdentity();
   Proj.PerspectiveFovY(Pi / 4.0, ClientWidth / ClientHeight, 0.5, 200.0);

   Render(UseProj);
  end;

 // Output some text.
 with Sender.SysFonts.Font['s/tahoma'] do
  begin
   TextOut('FPS: ' + IntToStr(Timer.FrameRate), 4, 4, $FFC6ACE5);
   TextOut('Drawing ' + IntToStr(TotalFacesNo) + ' faces and ' +
    IntToStr(TotalVerticesNo) + ' vertices.', 4, 44, $FFFFDA93);
   TextOut('Hit SPACE to switch between debug projection and shadow mapping.',
    4, 24, $FFAED7E3);

  case Sender.Params.MultiSampleType of
    D3DMULTISAMPLE_NONE,
    D3DMULTISAMPLE_NONMASKABLE:
     TextOut('No multisampling support.', 4, 64, $FFC1FF93);

    D3DMULTISAMPLE_2_SAMPLES..D3DMULTISAMPLE_16_SAMPLES:
     TextOut(IntToStr(Integer(Sender.Params.MultiSampleType)) +
      'x multisampling used.', 4, 64, $FFC1FF93);
   end;
  end;
end;

//---------------------------------------------------------------------------
procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
 Shift: TShiftState);
begin
 if (Key = VK_ESCAPE) then Close();
 if (Key = VK_SPACE) then UseProj:= not UseProj;
end;

//---------------------------------------------------------------------------
procedure TMainForm.MakeScene();
var
 Shift: TPoint2;
begin
 // Put the floor scaled by 100x100
 World.LoadIdentity();
 World.Scale(100.0, 1.0, 100.0);

 Scene.AddScene(MeshPlane, World.RawMtx^, 0.2, $808080, 8.0, ImageFloor,
  ImageFloorN, IdentityMtx3);

 // Put superellipsoid and rotate it around.
 World.LoadIdentity();
 World.Scale(16.0, 16.0, 16.0);
 World.RotateY(-GameTicks * 0.0214);
 World.RotateX(GameTicks * 0.0134);
 World.RotateY(GameTicks * 0.0351);
 World.Translate(0.0, 7.0, 0.0);

 Scene.AddScene(MeshSuper, World.RawMtx^, 0.1, $FFFFFF, 7.0, ImageKnot,
  ImageKnotN, ScaleMtx3(Point2(8.0, 8.0)));

 // Put our torus knot and make some animation with it. 
 Shift.x:= -GameTicks * 0.02;
 Shift.x:= Shift.x - Trunc(Shift.x);

 Shift.y:= GameTicks * 0.002;
 Shift.y:= Shift.y - Trunc(Shift.y);

 World.LoadIdentity();
 World.Scale(8.0, 8.0, 8.0);
 World.Translate(0.0, 6.0, 0.0);
 World.RotateY(GameTicks * 0.03);

 Scene.AddScene(MeshKnot, World.RawMtx^, 0.1, $FFFFFF, 7.0, ImageKnot,
  ImageKnotN, TranslateMtx3(Shift));
end;

//---------------------------------------------------------------------------
end.
