unit InovoFluxFx;
//---------------------------------------------------------------------------
// InovoFluxFx.pas                                      Modified: 28-Apr-2007
// Interface for "InovoFlux.fx" shader effect                     Version 1.0
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
// The Original Code is InovoFluxFx.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// M. Sc. Yuriy Kotsarenko. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Direct3D9, d3dx9, Vectors2, Vectors3, Matrices3, Matrices4, AsphyreColors,
 AsphyreDevices, AsphyreShaderFX, AsphyreMeshes, AsphyreTextures,
 AsphyreImages;

//---------------------------------------------------------------------------
type
 TInovoTechnique = (itBuildShadowMap, itShadowBumpPhong, itProjBumpPhong);

//---------------------------------------------------------------------------
 TInovoFluxFx = class(TAsphyreShaderEffect)
 private
  FTechnique    : TInovoTechnique;
  FLightWVP     : TMatrix4;
  FWorldInvT    : TMatrix4;
  FWorldViewProj: TMatrix4;
  FWorld        : TMatrix4;
  FEyePos       : TVector3;
  FLightPos     : TVector3;
  FLightDir     : TVector3;
  FAmbient      : Single;
  FSpecular     : TAsphyreColor;
  FSpecPower    : Single;
  FTexMtx       : TMatrix3;
  FSMapTex      : TAsphyreCustomTexture;
  FSkinTex      : TAsphyreCustomTexture;
  FBumpTex      : TAsphyreCustomTexture;
  TempColor     : TD3DColorValue;

  procedure SetTechnique(const Value: TInovoTechnique);
 protected
  procedure Describe(); override;
  procedure UpdateParam(Code: Integer; out DataPtr: Pointer;
   out DataSize: Integer); override;
  procedure UpdateTexture(Code: Integer;
   out ParamTex: IDirect3DTexture9); override;
 public
  // World(Object) * View(Light) * Projection(Light)
  property LightWVP: TMatrix4 read FLightWVP write FLightWVP;

  // Transpose of Inverse of World(Object)
  property WorldInvT: TMatrix4 read FWorldInvT write FWorldInvT;

  // World(Object) * View(Eye) * Projection(Eye)
  property WorldViewProj: TMatrix4 read FWorldViewProj write FWorldViewProj;

  // World(Object)
  property World: TMatrix4 read FWorld write FWorld;

  // Eye Position
  property EyePos: TVector3 read FEyePos write FEyePos;

  // Light Position
  property LightPos: TVector3 read FLightPos write FLightPos;

  // Light Direction
  property LightDir: TVector3 read FLightDir write FLightDir;

  // Shader material properties
  property Ambient  : Single read FAmbient write FAmbient;
  property Specular : TAsphyreColor read FSpecular write FSpecular;
  property SpecPower: Single read FSpecPower write FSpecPower;

  property TexMtx   : TMatrix3 read FTexMtx write FTexMtx;

  // Shader textures
  property SMapTex: TAsphyreCustomTexture read FSMapTex write FSMapTex;
  property SkinTex: TAsphyreCustomTexture read FSkinTex write FSkinTex;
  property BumpTex: TAsphyreCustomTexture read FBumpTex write FBumpTex;

  // Rendering technique
  property Technique: TInovoTechnique read FTechnique write SetTechnique;

  // Updates the specified textures
  procedure UpdateTex(SMap, Skin, Bump: TAsphyreCustomImage);

  procedure UpdateParams();

  procedure DrawMesh(Mesh: TAsphyreCustomMesh); overload;
  procedure DrawShadow(Mesh: TAsphyreCustomMesh); overload;

  constructor Create(ADevice: TAsphyreDevice);
 end;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
uses
 AsphyreScene;

//---------------------------------------------------------------------------
const
 RawLightWVP      = $01;
 RawWorldInvT     = $02;
 RawWorldViewProj = $03;
 RawWorld         = $04;
 RawEyePos        = $05;
 RawLightPos      = $06;
 RawLightDir      = $07;
 RawAmbient       = $08;
 RawSpecular      = $09;
 RawSpecPower     = $0A;
 RawTexMtx        = $0B;

 RawSMapTex       = $0C;
 RawSkinTex       = $0D;
 RawBumpTex       = $0E;

 TechBuildShadowMap  = $20;
 TechShadowBumpPhong = $21;
 TechProjBumpPhong   = $22;

//---------------------------------------------------------------------------
constructor TInovoFluxFx.Create(ADevice: TAsphyreDevice);
begin
 inherited;

 FTechnique    := itBuildShadowMap;
 FLightWVP     := IdentityMtx4;
 FWorldInvT    := IdentityMtx4;
 FWorldViewProj:= IdentityMtx4;
 FWorld        := IdentityMtx4;
 FEyePos       := UnityVec3;
 FLightPos     := UnityVec3;
 FLightDir     := -UnityVec3;
 FAmbient      := 0.2;
 FSpecular     := $FFFFFF;
 FSpecPower    := 8.0;
 FTexMtx       := IdentityMtx3;
 FSMapTex      := nil;
 FSkinTex      := nil;
 FBumpTex      := nil;
end;

//---------------------------------------------------------------------------
procedure TInovoFluxFx.Describe();
begin
 DescParam(sptCustom, 'LightWVP',              RawLightWVP);
 DescParam(sptCustom, 'WorldInverseTranspose', RawWorldInvT);
 DescParam(sptCustom, 'WorldViewProjection',   RawWorldViewProj);
 DescParam(sptCustom, 'World',                 RawWorld);
 DescParam(sptCustom, 'EyePos',                RawEyePos);
 DescParam(sptCustom, 'LightPos',              RawLightPos);
 DescParam(sptCustom, 'Ambient',               RawAmbient);
 DescParam(sptCustom, 'Specular',              RawSpecular);
 DescParam(sptCustom, 'SpecPower',             RawSpecPower);
 DescParam(sptCustom, 'TexMtx',                RawTexMtx);

 DescParam(sptTexture, 'SkinTex', RawSkinTex);
 DescParam(sptTexture, 'BumpTex', RawBumpTex);
 DescParam(sptTexture, 'SMapTex', RawSMapTex);

 DescTechnique('BuildShadowMap',  TechBuildShadowMap);
 DescTechnique('ShadowBumpPhong', TechShadowBumpPhong);
 DescTechnique('ProjBumpPhong',   TechProjBumpPhong);
end;

//---------------------------------------------------------------------------
procedure TInovoFluxFx.UpdateParam(Code: Integer; out DataPtr: Pointer;
 out DataSize: Integer);
begin
 case Code of
  RawLightWVP:
   begin
    DataPtr := @FLightWVP;
    DataSize:= SizeOf(TMatrix4);
   end;

  RawWorldInvT:
   begin
    DataPtr := @FWorldInvT;
    DataSize:= SizeOf(TMatrix4);
   end;

  RawWorldViewProj:
   begin
    DataPtr := @FWorldViewProj;
    DataSize:= SizeOf(TMatrix4);
   end;

  RawWorld:
   begin
    DataPtr := @FWorld;
    DataSize:= SizeOf(TMatrix4);
   end;

  RawEyePos:
   begin
    DataPtr := @FEyePos;
    DataSize:= SizeOf(TVector3);
   end;

  RawLightPos:
   begin
    DataPtr := @FLightPos;
    DataSize:= SizeOf(TVector3);
   end;

  RawLightDir:
   begin
    DataPtr := @FLightDir;
    DataSize:= SizeOf(TVector3);
   end;

  RawAmbient:
   begin
    DataPtr := @FAmbient;
    DataSize:= SizeOf(Single);
   end;

  RawSpecular:
   begin
    TempColor:= FSpecular;

    DataPtr := @TempColor;
    DataSize:= SizeOf(TD3DColorValue) - SizeOf(Single);
   end;

  RawSpecPower:
   begin
    DataPtr := @FSpecPower;
    DataSize:= SizeOf(Single);
   end;

  RawTexMtx:
   begin
    DataPtr := @FTexMtx;
    DataSize:= SizeOf(TMatrix3);
   end;
 end;
end;

//---------------------------------------------------------------------------
procedure TInovoFluxFx.UpdateTexture(Code: Integer;
 out ParamTex: IDirect3DTexture9);
begin
 ParamTex:= nil;

 case Code of
  RawSMapTex:
   if (FSMapTex <> nil) then ParamTex:= FSMapTex.Tex9;

  RawSkinTex:
   if (FSkinTex <> nil) then ParamTex:= FSkinTex.Tex9;

  RawBumpTex:
   if (FBumpTex <> nil) then ParamTex:= FBumpTex.Tex9;
 end;
end;

//---------------------------------------------------------------------------
procedure TInovoFluxFx.DrawMesh(Mesh: TAsphyreCustomMesh);
var
 PassNo: Integer;
begin
 for PassNo:= 0 to NumPasses - 1 do
  begin
   if (not BeginPass(PassNo)) then Break;

   Mesh.Draw();

   EndPass();
  end;
end;

//---------------------------------------------------------------------------
procedure TInovoFluxFx.DrawShadow(Mesh: TAsphyreCustomMesh);
begin
 UpdateByCode(RawLightWVP);

 DrawMesh(Mesh);
end;

//---------------------------------------------------------------------------
procedure TInovoFluxFx.SetTechnique(const Value: TInovoTechnique);
begin
 if (FTechnique <> Value) then
  begin
   FTechnique:= Value;

   if (Effect <> nil) then
    case FTechnique of
     itBuildShadowMap:
      UseTechnique(TechBuildShadowMap);

     itShadowBumpPhong:
      UseTechnique(TechShadowBumpPhong);

     itProjBumpPhong:
      UseTechnique(TechProjBumpPhong);
    end;
  end;
end;

//---------------------------------------------------------------------------
procedure TInovoFluxFx.UpdateTex(SMap, Skin, Bump: TAsphyreCustomImage);
var
 NewTex: TAsphyreCustomTexture;
begin
 // -> ShadowMap Texture
 FSMapTex:= nil;
 if (SMap <> nil) then FSMapTex:= SMap.Texture[0];
 UpdateByCode(RawSMapTex);

 // -> Skin Texture
 NewTex:= nil;
 if (Skin <> nil) then NewTex:= Skin.Texture[0];
 if (NewTex <> FSkinTex) then
  begin
   FSkinTex:= NewTex;
   UpdateByCode(RawSkinTex);
  end;

 // -> Bump Texture
 NewTex:= nil;
 if (Bump <> nil) then NewTex:= Bump.Texture[0];
 if (NewTex <> FBumpTex) then
  begin
   FBumpTex:= NewTex;
   UpdateByCode(RawBumpTex);
  end;
end;

//---------------------------------------------------------------------------
procedure TInovoFluxFx.UpdateParams();
begin
 UpdateByCode(RawLightWVP);
 UpdateByCode(RawWorldInvT);
 UpdateByCode(RawWorldViewProj);
 UpdateByCode(RawWorld);
 UpdateByCode(RawEyePos);
 UpdateByCode(RawLightPos);
 UpdateByCode(RawLightDir);
 UpdateByCode(RawAmbient);
 UpdateByCode(RawSpecular);
 UpdateByCode(RawSpecPower);
 UpdateByCode(RawTexMtx);
end;

//---------------------------------------------------------------------------
end.
