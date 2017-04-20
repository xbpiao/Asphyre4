unit ExampleObjects;

//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Vectors3, Matrices4, AsphyreMeshes, AsphyreBasicShaders, AsphyreMinimalShader,
 AsphyrePhysics, CookTorranceFx;

//---------------------------------------------------------------------------
type
 TExampleBox = class(TNewtonCustomBox)
 private
  FSpecular: Single;
 protected
  procedure DoDraw(const DrawMtx: TMatrix4); override;
 public
  property Specular: Single read FSpecular write FSpecular;
 end;

//---------------------------------------------------------------------------
 TExampleSphere = class(TNewtonCustomSphere)
 private
 protected
  procedure DoDraw(const DrawMtx: TMatrix4); override;
 end;

//---------------------------------------------------------------------------
var
 Shader : TCookTorranceFx;
// Shader    : TAsphyreBasicShader = nil;
// Shader    : TAsphyreMinimalShader = nil;
 MeshBox   : TAsphyreCustomMesh = nil;
 MeshSphere: TAsphyreCustomMesh = nil;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
procedure TExampleBox.DoDraw(const DrawMtx: TMatrix4);
begin
 Shader.Draw(MeshBox, DrawMtx, Color, 0.1, FSpecular, 0.85, 0.9);
end;

//---------------------------------------------------------------------------
procedure TExampleSphere.DoDraw(const DrawMtx: TMatrix4);
begin
 Shader.Draw(MeshSphere, ScaleMtx4(Vector3(2.0, 2.0, 2.0)) * DrawMtx, Color,
  0.2, 1.0, 0.85, 0.9);
end;

//---------------------------------------------------------------------------
end.
