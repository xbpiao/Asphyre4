unit MainFm;

//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AsphyreDevices, AsphyreScene, AsphyreBasicShaders, Vectors3,
  Direct3D9, AsphyreSuperEllipsoid, AsphyreMinimalShader, AsphyreImages,
  Matrices4, CookTorranceFx;

//---------------------------------------------------------------------------
type
  TMainForm = class(TForm)
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    GameTicks: Integer;

    procedure ConfigureDevice(Sender: TAsphyreDevice; Tag: TObject;
     var Config: TScreenConfig);
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
 AsphyreTimer, AsphyreSystemFonts, AsphyrePhysics, ExampleObjects, MediaImages,
 AsphyreShaderFX, AsphyreMeshes;
{$R *.dfm}

//---------------------------------------------------------------------------
const
 Colors: array[0..6] of Cardinal = ($FF34FF00, $FFFF0000, $FF0000FF, $FFFF00FF,
  $FFFFFF00, $FF00FFFF, $FF808080);

//---------------------------------------------------------------------------
procedure TMainForm.FormCreate(Sender: TObject);
var
 Floor : TExampleBox;
 Box   : TExampleBox;
 Sphere: TNewtonCustomSphere;
 i: Integer;
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

 // Create the default shader for illuminating the physical objects
 Shader:= TCookTorranceFx.Create(DefDevice);
 if (not Shader.LoadFromFile('CookTorrance.fx')) then
  begin
   Devices.Finalize();
   ShowMessage('Failed to load shader effect!');
   Close();
   Exit;
  end;

 // Create meshes that will be used to render physical objects
 MeshBox:= TAsphyreSuperEllipsoid.Create(DefDevice);
 TAsphyreSuperEllipsoid(MeshBox).Generate(64, 0.1, 0.1);

 MeshSphere:= TAsphyreSuperEllipsoid.Create(DefDevice);
 TAsphyreSuperEllipsoid(MeshSphere).Generate(32, 1.0, 1.0);

 // Create physical world
 CreateNewtonWorld(Vector3(100.0, 100.0, 100.0));

 // The floor is stationary phsyical object that cannot be moved.
 Floor:= TExampleBox.Create(NewtonObjects, Vector3(50.0, 1.0, 50.0));
 Floor.Color:= $FF707070;
 Floor.Specular:= 0.0;

 // Create some boxes and spheres to fall down on the floor.
 for i:= 0 to 7 do
  begin
   Box:= TExampleBox.Create(NewtonObjects, Vector3(2.0, 2.0, 2.0));
   Box.Position:= Vector3(0.0, 4.0 + (i * 3.0), 0.0);

   Box.Mass := 10.0;
   Box.Omega:= Vector3(Random(15), Random(15), Random(15));
   Box.Color:= Colors[i mod 7];
   Box.Specular:= 1.0;
  end;

 for i:= 0 to 7 do
  begin
   Sphere:= TExampleSphere.Create(NewtonObjects, 1.0);
   Sphere.Position:= Vector3(0.0, 15.0 + (i * 2.0), 0.0);

   Sphere.Mass := 10.0;
   Sphere.Omega:= Vector3(Random(15), Random(15), Random(15));
   Sphere.Color:= Colors[i mod 7];
  end;

 Timer.Enabled  := True;
 Timer.OnTimer  := TimerEvent;
 Timer.OnProcess:= ProcessEvent;
 Timer.MaxFPS   := 4000;
end;

//---------------------------------------------------------------------------
procedure TMainForm.FormDestroy(Sender: TObject);
begin
 MeshSphere.Free();
 MeshBox.Free();
 Shader.Free();

 Devices.Finalize();

 NewtonObjects.RemoveAll();
 DestroyNewtonWorld();
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if (Key = VK_ESCAPE) then Close();
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
end;

//---------------------------------------------------------------------------
procedure TMainForm.TimerEvent(Sender: TObject);
begin
 // Reset vertex and face drawing count.
 ResetDrawInfo();

 DefDevice.Render(RenderPrimary, Self, $000000, 1.0, 0);
 UpdateNewtonWorld(Timer.Latency);
 Timer.Process();
end;

//---------------------------------------------------------------------------
procedure TMainForm.ProcessEvent(Sender: TObject);
begin
 NewtonObjects.Update();
 Inc(GameTicks);
end;

//---------------------------------------------------------------------------
procedure TMainForm.RenderPrimary(Sender: TAsphyreDevice; Tag: TObject);
begin
 with DefDevice.Dev9 do
  begin
   SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);
   SetRenderState(D3DRS_ZENABLE, D3DZB_TRUE);
  end;

 // Configure the viewing camera so it rotates around the world.
 ViewMtx.LoadIdentity();
 Viewmtx.RotateY(GameTicks / 100.0);
 ViewMtx.LookAt(Vector3(5.0, 15.0,
  -15.0), ZeroVec3, AxisYVec3);

 // The projection matrix is used to project the scene on 2D screen.
 ProjMtx.LoadIdentity();
 ProjMtx.PerspectiveFovY(Pi / 4.0, 640.0 / 480.0, 1.0, 1000.0);

 // Configure some relevant shader parameters.
 Shader.LightDir:= Vector3(1.0, -1.0, -1.0);
 Shader.ShaderMode:= semQuality;
 Shader.UpdateTech();

 // Begin shading the 3D scene.
 Shader.BeginAll();

 // Render all physical objects.
 NewtonObjects.Draw();

 // Finish shading the scene.
 Shader.EndAll();

 // Output frame-rate information.
 with Sender.SysFonts.Font['s/tahoma'] do
  begin
   TextOut('FPS: ' + IntToStr(Timer.FrameRate), 4, 4, $FFC7FF57);

   TextOut('Drawing ' + IntToStr(TotalFacesNo) + ' faces and ' +
    IntToStr(TotalVerticesNo) + ' vertices.', 4, 24, $FFD6B7FF);

   case Sender.Params.MultiSampleType of
    D3DMULTISAMPLE_NONE,
    D3DMULTISAMPLE_NONMASKABLE:
     TextOut('No multisampling support.', 4, 44, $FFE7E8A9);

    D3DMULTISAMPLE_2_SAMPLES..D3DMULTISAMPLE_16_SAMPLES:
     TextOut(IntToStr(Integer(Sender.Params.MultiSampleType)) +
      'x multisampling used.', 4, 44, $FFE7E8A9);
   end;
  end;
end;

//---------------------------------------------------------------------------
end.
