unit MainFm;

//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AsphyreDevices, AsphyreTorusKnot, AsphyreSuperEllipsoid,
  AsphyrePlaneMesh, AsphyreMeshes, InovoScene, Matrices3, Vectors2,
  AsphyreMatrices, Vectors3;

//---------------------------------------------------------------------------
type
  TMainForm = class(TForm)
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
    GameTicks: Integer;

    MeshPlane: TAsphyrePlaneMesh;
    MeshKnot : TAsphyreTorusKnot;
    MeshSuper: TAsphyreSuperEllipsoid;
    CubeMesh: TAsphyreMeshX;

    UseProj: Boolean;

    World: TAsphyreMatrix;
    Scene: TInovoScene;

    FVOrigin: TVector3;
    FVTarget: TVector3;
    FIsStaickNeedRePaint: boolean;
    FFieldOfView: single;
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

    procedure WMEnterSizeMove(var msg: TMessage); message WM_ENTERSIZEMOVE;
    procedure WMExitSizeMove(var msg: TMessage); message WM_EXITSIZEMOVE;
    
  public
    { Public declarations }
  end;

//---------------------------------------------------------------------------
var
  MainForm: TMainForm;

//---------------------------------------------------------------------------
implementation
uses
 AsphyreTimer, AsphyreSystemFonts, AsphyreEvents,
 MediaImages,
 {$IFDEF AsphyreUseDx8}
   Direct3D8
 {$ELSE}
   Direct3D9
 {$ENDIF};
 
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

  FVOrigin := Vector3(11.0, 16.0, -11.0);
  FVTarget := Vector3(-5.0, 1.0, 5.0);
  FIsStaickNeedRePaint := False;

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
 //MeshSuper.Generate(80, 6.0, 6.0);
 MeshSuper.ComputeTangetBinormal();

 MeshPlane:= TAsphyrePlaneMesh.Create(DefDevice);
 MeshPlane.Generate(10, 10, 1.0, 1.0, 8.0, 8.0);

// CubeMesh := TAsphyreMeshX.Create(DefDevice);
// if not CubeMesh.LoadFromFile('cube.mesh') then
//   ShowMessage('加载cube.mesh失败！');

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
 FFieldOfView := Pi / 4.0;
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
 Config.Windowed:= True;
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
 if FIsStaickNeedRePaint then Exit;
 // Reset drawing primitive counters.
 ResetDrawInfo();

 // Set some relevant Direct3D states
 {$IFDEF AsphyreUseDx8}
  with DefDevice.Dev8 do
 {$ELSE}
  with DefDevice.Dev9 do
  {$ENDIF}
  begin
   SetRenderState(D3DRS_ZENABLE, D3DZB_TRUE);
   SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);
  end;

 // Begin drawing a new 3D scene.
 Scene.ResetScene();

// // Build the 3D scene.
// MakeScene();
//
// // Render the scene from light's perspective that will be used for shadow
// // mapping, if necessary.
// if (not UseProj) then
//  begin
//   Scene.ShadowMap:= ImageShadow;
//   Scene.RenderShadowMap();
//  end else Scene.ShadowMap:= ImageSmiley;

 DefDevice.Render(RenderPrimary, Self, 0, 1.0, 0);


 Timer.Process();
end;

procedure TMainForm.WMEnterSizeMove(var msg: TMessage);
begin
  FIsStaickNeedRePaint := True;
  Timer.Enabled := False;
end;

procedure TMainForm.WMExitSizeMove(var msg: TMessage);
begin
  FIsStaickNeedRePaint := False;
  Timer.Enabled := True;
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
   //View.LookAt(Vector3(11.0, 16.0, -11.0), Vector3(-5.0, 1.0, 5.0), AxisYVec3);
   View.LookAt(FVOrigin, FVTarget, AxisYVec3);

   Proj.LoadIdentity();
   Proj.PerspectiveFovY(FFieldOfView, ClientWidth / ClientHeight, 0.5, 200.0);

 // Build the 3D scene.
 MakeScene();

 // Render the scene from light's perspective that will be used for shadow
 // mapping, if necessary.
 if (not UseProj) then
  begin
   Scene.ShadowMap:= ImageShadow;
   Scene.RenderShadowMap();
  end else Scene.ShadowMap:= ImageSmiley;

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
    {$IFDEF AsphyreUseDx8}
    D3DMULTISAMPLE_NONE:
    {$ELSE}
    D3DMULTISAMPLE_NONE,
    D3DMULTISAMPLE_NONMASKABLE:
    {$ENDIF}
    begin
     TextOut('No multisampling support.', 4, 64, $FFC1FF93);
    end;

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
// if (Key = VK_ESCAPE) then Close();
// if (Key = VK_SPACE) then UseProj:= not UseProj;
  case Key of
    VK_ESCAPE:
    begin
      FVOrigin := Vector3(11.0, 16.0, -11.0);
      FVTarget := Vector3(-5.0, 1.0, 5.0);
    end;// VK_ESCAPE
    VK_SPACE: UseProj:= not UseProj;
    VK_UP:
    begin
      FVOrigin.y := FVOrigin.y + 0.1;
    end;// VK_UP
    VK_DOWN:
    begin
      FVOrigin.y := FVOrigin.y - 0.1;
    end;// VK_DOWN
    VK_LEFT:
    begin
      FVOrigin.x := FVOrigin.x - 0.1;
    end;// VK_LEFT
    VK_RIGHT:
    begin
      FVOrigin.x := FVOrigin.x + 0.1;
    end;// VK_RIGHT
    VK_PRIOR:
    begin
      FVOrigin.z := FVOrigin.z + 0.1;
    end;// VK_PRIOR
    VK_NEXT:
    begin
      FVOrigin.z := FVOrigin.z - 0.1;
    end;// VK_NEXT
    Ord('1'):
    begin
     {$IFDEF AsphyreUseDx8}
      with DefDevice.Dev8 do
     {$ELSE}
      with DefDevice.Dev9 do
      {$ENDIF}
      begin
        SetRenderState(D3DRS_FILLMODE, D3DFILL_WIREFRAME);
      end;// with
    end;// 1
    Ord('2'):
    begin
     {$IFDEF AsphyreUseDx8}
      with DefDevice.Dev8 do
     {$ELSE}
      with DefDevice.Dev9 do
      {$ENDIF}
      begin
        SetRenderState(D3DRS_FILLMODE, D3DFILL_SOLID);
      end;// with
    end;// 2

  end;// case
end;

procedure TMainForm.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if WheelDelta > 0 then
    FFieldOfView := FFieldOfView + 0.1
  else
    FFieldOfView := FFieldOfView - 0.1;
end;

procedure TMainForm.FormPaint(Sender: TObject);
begin
  if FIsStaickNeedRePaint then
  begin// 拖动时绘制
    ResetDrawInfo();
    DefDevice.Render(RenderPrimary, Self, 0, 1.0, 0);
  end;// if
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

// World.LoadIdentity();
// World.Scale(10.0, 10.0, 10.0);
// World.Translate(7.0, 7.0, 0.0);
// Scene.AddScene(CubeMesh, World.RawMtx^, 0.2, $808080, 8.0, ImageFloor,
//  ImageFloorN, IdentityMtx3);

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
