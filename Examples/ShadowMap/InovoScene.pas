unit InovoScene;
//---------------------------------------------------------------------------
// InovoScene.pas                                       Modified: 28-Apr-2007
// A small 3D graphics engine for Asphyre                         Version 1.0
//---------------------------------------------------------------------------
// Important Notice:
//
// If you modify/use this code or one of its parts either in original or
// modified form, you must comply with Mozilla Public License v1.1,
// specifically section 3, "Distribution Obligations". Failure to do so will
// result in the license breach, which will be resolved in the court.
// Remember that violating author's rights is considered a serious crime in
// many countries. Thank you!
//
// !! Please *read* Mozilla Public License 1.1 document located at:
//  http://www.mozilla.org/MPL/
//
// If you require any clarifications about the license, feel free to contact
// us or post your question on our forums at: http://www.afterwarp.net
//---------------------------------------------------------------------------
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
// License for the specific language governing rights and limitations
// under the License.
//
// The Original Code is InovoScene.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// M. Sc. Yuriy Kotsarenko. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 d3dx9, Vectors3, Matrices3, Matrices4, AsphyreColors, AsphyreMatrices,
 AsphyreMeshes, AsphyreDevices, InovoFluxFx;

//---------------------------------------------------------------------------
type
 PInovoLight = ^TInovoLight;
 TInovoLight = record
  Position : TVector3;
  Direction: TVector3;

  FieldOfView: Single;
  NearPlane  : Single;
  FarPlane   : Single;
  AspectRatio: Single;
 end;

//---------------------------------------------------------------------------
 PInovoMaterial = ^TInovoMaterial;
 TInovoMaterial = record
  Ambient  : Single;
  Specular : TAsphyreColor;
  SpecPower: Single;
  SkinIndex: Integer;
  BumpIndex: Integer;
  TexTrans : TMatrix3;
 end;

//---------------------------------------------------------------------------
 PInovoInstance = ^TInovoInstance;
 TInovoInstance = record
  Mesh    : TAsphyreCustomMesh;
  Material: TInovoMaterial;

  MeshW   : TMatrix4; // Local-to-world transform
  MeshWV  : TMatrix4; // Local-to-view transform
  
  OriginV : TVector3; // Position in view space
 end;

//---------------------------------------------------------------------------
 TInovoScene = class
 private
  Instances: array of TInovoInstance;
  DrawOrder: array of PInovoInstance;
  DataCount: Integer;
  Capacity : Integer;

  FView : TAsphyreMatrix;
  FProj : TAsphyreMatrix;
  TempM : TAsphyreMatrix;

  FLight: TInovoLight;

  FDevice: TAsphyreDevice;
  FShader: TInovoFluxFx;
  FShadowMap: Integer;
  FScreenShadow: Integer;

  function GetLight(): PInovoLight;
  procedure Grow();

  // Updates MeshWV (Local-to-view) transform of meshes, as well as their
  // position in view space.
  procedure UpdateMeshesWVH(const View: TMatrix4);

  // Initializes the draw order of meshes.
  procedure InitDrawOrder();

  // Sorts meshes by their position in view space.
  procedure SortByOriginV(Left, Right: Integer);

  // Walks through the list sending meshes for shadow rendering to shader.
  procedure ShadeMeshShadows(const Proj: TMatrix4);

  // Prepares the shadow rendering and calls ShadeMeshShadows().
  procedure RenderMeshShadows(Sender: TAsphyreDevice; Tag: TObject);

  // Calculates the view and projection matrices for light source.
  procedure ComputeLightViewProj(out View, Proj: TMatrix4); overload;

  // Calculates the combined matrix View * Projection for the light source.
  function ComputeLightViewProj(): TMatrix4; overload;

  procedure DrawNormal(const View, Proj: TMatrix4);
 public
  property Device: TAsphyreDevice read FDevice;
  property Shader: TInovoFluxFx read FShader;

  // The light used to project shadow maps and illuminate the scene.
  property Light: PInovoLight read GetLight;

  property View : TAsphyreMatrix read FView;
  property Proj : TAsphyreMatrix read FProj;

  // Index to the image holding the shadow map (should be a valid and ready to
  // use Render Target). The depth information will be rendered here.
  property ShadowMap: Integer read FShadowMap write FShadowMap;

  // Index to the image holding screen shadow (should be a valid and ready to
  // use Render Target). The shadow mapped scene will be rendered here.
  property ScreenShadow: Integer read FScreenShadow write FScreenShadow;

  // The following method resets the scene, so a new scene can be rendered.
  // This is usually called at the beginning of rendering phase, before
  // further calls to AddScene.
  procedure ResetScene();

  // Adds a new mesh instance to the scene with the given attributes.
  procedure AddScene(Mesh: TAsphyreCustomMesh; const World: TMatrix4;
   Ambient: Single; Specular: Cardinal; SpecPower: Single; Skin,
   Bump: Integer; const TexTrans: TMatrix3);

  // Renders depth values to shadow map texture from the light perspective.
  procedure RenderShadowMap();

  // Renders the scene normally.
  procedure Render(UseProj: Boolean);

  constructor Create(ADevice: TAsphyreDevice);
  destructor Destroy(); override;
 end;


//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
const
 MinGrow  = 4;
 GrowUnit = 8;

//---------------------------------------------------------------------------
constructor TInovoScene.Create(ADevice: TAsphyreDevice);
begin
 inherited Create();

 FDevice:= ADevice;

 Capacity := 0;
 DataCount:= 0;

 FView:= TAsphyreMatrix.Create();
 FProj:= TAsphyreMatrix.Create();
 TempM:= TAsphyreMatrix.Create();

 FShader:= TInovoFluxFx.Create(FDevice);

 FShadowMap:= -1;
 FScreenShadow:= -1;
end;

//---------------------------------------------------------------------------
destructor TInovoScene.Destroy();
begin
 FShader.Free();
 TempM.Free();
 FProj.Free();
 FView.Free();

 inherited;
end;

//---------------------------------------------------------------------------
function TInovoScene.GetLight(): PInovoLight;
begin
 Result:= @FLight;
end;

//---------------------------------------------------------------------------
procedure TInovoScene.Grow();
var
 Delta: Integer;
begin
 Delta:= MinGrow + (Capacity div GrowUnit);
 Inc(Capacity, Delta);

 SetLength(Instances, Capacity);
 SetLength(DrawOrder, Capacity);
end;

//---------------------------------------------------------------------------
procedure TInovoScene.AddScene(Mesh: TAsphyreCustomMesh;
 const World: TMatrix4; Ambient: Single; Specular: Cardinal; SpecPower: Single;
 Skin, Bump: Integer; const TexTrans: TMatrix3);
var
 Index: Integer;
begin
 // (1) Make sure the capacity requirements are met for storing new instance.
 if (DataCount >= Capacity) then Grow();

 // (2) Increment number of instances.
 Index:= DataCount;
 Inc(DataCount);

 // (3) Insert instance data
 Instances[Index].Mesh:= Mesh;
 Instances[Index].Material.Ambient  := Ambient;
 Instances[Index].Material.Specular := Specular;
 Instances[Index].Material.SpecPower:= SpecPower;
 Instances[Index].Material.SkinIndex:= Skin;
 Instances[Index].Material.BumpIndex:= Bump;
 Instances[Index].Material.TexTrans := TexTrans;

 Instances[Index].MeshW  := World;
 Instances[Index].MeshWV := IdentityMtx4;
 Instances[Index].OriginV:= ZeroVec3;
end;

//---------------------------------------------------------------------------
procedure TInovoScene.UpdateMeshesWVH(const View: TMatrix4);
var
 i: Integer;
begin
 for i:= 0 to DataCount - 1 do
  with Instances[i] do
   begin
    MeshWV := MeshW * View;
    OriginV:= MeshWV.GetPos();
  end;
end;

//---------------------------------------------------------------------------
procedure TInovoScene.InitDrawOrder();
var
 i: Integer;
begin
 for i:= 0 to DataCount - 1 do
  DrawOrder[i]:= @Instances[i];
end;

//---------------------------------------------------------------------------
procedure TInovoScene.SortByOriginV(Left, Right: Integer);
var
 Lo, Hi  : Integer;
 TempElem: PInovoInstance;
 MidValue: Single;
begin
 Lo:= Left;
 Hi:= Right;
 MidValue:= DrawOrder[(Left + Right) div 2].OriginV.z;

 repeat
  while (DrawOrder[Lo].OriginV.z < MidValue) do Inc(Lo);
  while (DrawOrder[Hi].OriginV.z > MidValue) do Dec(Hi);

  if (Lo <= Hi) then
   begin
    TempElem:= DrawOrder[Lo];
    DrawOrder[Lo]:= DrawOrder[Hi];
    DrawOrder[Hi]:= TempElem;

    Inc(Lo);
    Dec(Hi);
   end;
 until (Lo > Hi);

 if (Left < Hi) then SortByOriginV(Left, Hi);
 if (Lo < Right) then SortByOriginV(Lo, Right);
end;

//---------------------------------------------------------------------------
procedure TInovoScene.ComputeLightViewProj(out View, Proj: TMatrix4);
begin
 View:= LookAtMtx4(FLight.Position, FLight.Position + Norm3(FLight.Direction),
  AxisYVec3);

 Proj:= PerspectiveFovYMtx4(FLight.FieldOfView, FLight.AspectRatio,
  FLight.NearPlane, FLight.FarPlane);
end;

//---------------------------------------------------------------------------
function TInovoScene.ComputeLightViewProj(): TMatrix4;
var
 View, Proj: TMatrix4;
begin
 ComputeLightViewProj(View, Proj);
 Result:= View * Proj;
end;

//---------------------------------------------------------------------------
procedure TInovoScene.ShadeMeshShadows(const Proj: TMatrix4);
var
 i: Integer;
begin
 for i:= 0 to DataCount - 1 do
  begin
   Shader.LightWVP:= Instances[i].MeshWV * Proj;
   Shader.DrawShadow(Instances[i].Mesh);
  end;
end;

//---------------------------------------------------------------------------
procedure TInovoScene.RenderMeshShadows(Sender: TAsphyreDevice; Tag: TObject);
var
 View, Proj: TMatrix4;
begin
 // (1) Retreive View and Projection matrices for light source.
 ComputeLightViewProj(View, Proj);

 // (2) Update World->View transformation for all meshes and calculate their
 // position in view space.
 UpdateMeshesWVH(View);

 // (3) Order the meshes by view depth.
 InitDrawOrder();
 SortByOriginV(0, DataCount - 1);

 // (4) Select technique for building the shadow map.
 FShader.Technique:= itBuildShadowMap;

 // (5) Render the meshes using selected technique.
 FShader.BeginAll();
 ShadeMeshShadows(Proj);
 FShader.EndAll();
end;

//---------------------------------------------------------------------------
procedure TInovoScene.RenderShadowMap();
begin
 if (DataCount > 0)and(FDevice <> nil) then
  FDevice.RenderTo(FShadowMap, RenderMeshShadows, Self, 0, 1.0, 0);
end;

//---------------------------------------------------------------------------
procedure TInovoScene.ResetScene();
begin
 DataCount:= 0;
end;

//---------------------------------------------------------------------------
procedure TInovoScene.DrawNormal(const View, Proj: TMatrix4);
var
 LightViewProj: TMatrix4;
 i: Integer;
begin
 LightViewProj:= ComputeLightViewProj();

 // Eye Position
 Shader.EyePos:= View.GetPos();

 // Light Position
 Shader.LightPos:= FLight.Position;

 // Light Direction
 Shader.LightDir:= FLight.Direction;

 for i:= 0 to DataCount - 1 do
  begin
   Shader.WorldViewProj:= Instances[i].MeshWV * Proj;
   Shader.LightWVP     := LightViewProj;
   Shader.WorldInvT    := TransposeMtx4(InvertMtx4(Instances[i].MeshW));
   Shader.World        := Instances[i].MeshW;

   Shader.Ambient  := Instances[i].Material.Ambient;
   Shader.Specular := Instances[i].Material.Specular;
   Shader.SpecPower:= Instances[i].Material.SpecPower;
   Shader.TexMtx   := Instances[i].Material.TexTrans;

   Shader.UpdateParams();

   with Instances[i].Material do
    begin
     Shader.UpdateTex(FDevice.Images[FShadowMap], FDevice.Images[SkinIndex],
      FDevice.Images[BumpIndex]);
    end;

   Shader.DrawMesh(Instances[i].Mesh);
  end;
end;

//---------------------------------------------------------------------------
procedure TInovoScene.Render(UseProj: Boolean);
begin
 UpdateMeshesWVH(FView.RawMtx^);
 InitDrawOrder();
 SortByOriginV(0, DataCount - 1);

 if (UseProj) then FShader.Technique:= itProjBumpPhong
  else FShader.Technique:= itShadowBumpPhong;

 FShader.BeginAll();
 DrawNormal(FView.RawMtx^, FProj.RawMtx^);
 FShader.EndAll();
end;

//---------------------------------------------------------------------------
end.
