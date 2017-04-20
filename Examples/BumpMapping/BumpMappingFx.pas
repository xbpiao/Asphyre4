unit BumpMappingFx;
//---------------------------------------------------------------------------
// BumpMappingFx.pas                                    Modified: 30-Apr-2007
// Shader interface for bump-mapping with phong reflection        Version 1.0
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
// The Original Code is BumpMappingFx.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// M. Sc. Yuriy Kotsarenko. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Direct3D9, d3dx9, Vectors2, Vectors3, Matrices4, AsphyreColors,
 AsphyreDevices, AsphyreShaderFX, AsphyreMeshes, AsphyreTextures,
 AsphyreImages, Matrices3;

//---------------------------------------------------------------------------
type
 TBumpMappingFx = class(TAsphyreShaderEffect)
 private
  TempColor : TD3DColorValue;
  TempVector: TD3DXVector3;

  FShaderMode   : TShaderEffectMode;
  FAmbientColor : TAsphyreColor;
  FDiffuseColor : TAsphyreColor;
  FSpecularColor: TAsphyreColor;
  FSpecularPower: Single;
  FLightVector  : TVector3;

  FSkinTexture: TAsphyreCustomTexture;
  FBumpTexture : TAsphyreCustomTexture;

  FSkinMtx: TMatrix3;
  FBumpMtx: TMatrix3;
 protected
  procedure Describe(); override;
  procedure UpdateParam(Code: Integer; out DataPtr: Pointer;
   out DataSize: Integer); override;
  procedure UpdateTexture(Code: Integer;
   out ParamTex: IDirect3DTexture9); override;
 public
  // The working mode of effect shader.
  property ShaderMode: TShaderEffectMode read FShaderMode write FShaderMode;

  // The light and illumination colors.
  property AmbientColor : TAsphyreColor read FAmbientColor write FAmbientColor;
  property DiffuseColor : TAsphyreColor read FDiffuseColor write FDiffuseColor;
  property SpecularColor: TAsphyreColor read FSpecularColor write FSpecularColor;

  // Texture transformation matrices.
  property SkinMtx: TMatrix3 read FSkinMtx write FSkinMtx;
  property BumpMtx: TMatrix3 read FBumpMtx write FBumpMtx;

  // Anisotropic roughness of specular term.
  property SpecularPower: Single read FSpecularPower write FSpecularPower;

  // The light direction vector.
  property LightVector: TVector3 read FLightVector write FLightVector;

  // The diffuse texture to skin the mesh with.
  property SkinTexture: TAsphyreCustomTexture read FSkinTexture write FSkinTexture;

  // The bump-mapping texture containing normal information.
  property BumpTexture: TAsphyreCustomTexture read FBumpTexture write FBumpTexture;

  procedure Draw(Mesh: TAsphyreCustomMesh); overload;

  procedure Draw(Mesh: TAsphyreCustomMesh; const World: TMatrix4;
   SkinTex, BumpTex: TAsphyreCustomImage); overload;

  constructor Create(ADevice: TAsphyreDevice);
 end;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
uses
 AsphyreScene;

//---------------------------------------------------------------------------
const
 ShdrAmbientColor  = 1;
 ShdrDiffuseColor  = 2;
 ShdrSpecularColor = 3;
 ShdrSpecularPower = 4;
 ShdrLightVector   = 5;

 ShdrSkinMtx       = 6;
 ShdrBumpMtx       = 7;

 ShdrSkinTexture   = 8;
 ShdrBumpTexture   = 9;

//---------------------------------------------------------------------------
constructor TBumpMappingFx.Create(ADevice: TAsphyreDevice);
begin
 inherited;

 FShaderMode   := semQuality;
 FAmbientColor := $202020;
 FDiffuseColor := $FFFFFFFF;
 FSpecularColor:= $FFFFFF;
 FSpecularPower:= 8.0;
 FLightVector  := Norm3(Vector3(1.0, 1.0, 1.0));

 FSkinMtx:= IdentityMtx3;
 FBumpMtx:= IdentityMtx3;
end;

//---------------------------------------------------------------------------
procedure TBumpMappingFx.Describe();
begin
 DescParam(sptWorldViewProjection,   'WorldViewProjection');
 DescParam(sptWorldInverseTranspose, 'WorldInverseTranspose');
 DescParam(sptWorldInverse,          'WorldInverse');
 DescParam(sptWorld,                 'World');
 DescParam(sptCameraPosition,        'EyePos');

 DescParam(sptCustom, 'AmbientColor',  ShdrAmbientColor);
 DescParam(sptCustom, 'DiffuseColor',  ShdrDiffuseColor);
 DescParam(sptCustom, 'SpecularColor', ShdrSpecularColor);
 DescParam(sptCustom, 'SpecularPower', ShdrSpecularPower);
 DescParam(sptCustom, 'LightVector',   ShdrLightVector);

 DescParam(sptCustom, 'SkinMtx', ShdrSkinMtx);
 DescParam(sptCustom, 'BumpMtx', ShdrBumpMtx);

 DescParam(sptTexture, 'SkinTexture',  ShdrSkinTexture);
 DescParam(sptTexture, 'BumpTexture',  ShdrBumpTexture);
end;

//---------------------------------------------------------------------------
procedure TBumpMappingFx.UpdateParam(Code: Integer; out DataPtr: Pointer;
 out DataSize: Integer);
begin
 case Code of
  ShdrAmbientColor:
   begin
    TempColor:= FAmbientColor;

    DataPtr := @TempColor;
    DataSize:= SizeOf(TD3DColorValue) - SizeOf(Single);
   end;

  ShdrDiffuseColor:
   begin
    TempColor:= FDiffuseColor;

    DataPtr := @TempColor;
    DataSize:= SizeOf(TD3DColorValue);
   end;

  ShdrSpecularColor:
   begin
    TempColor:= FSpecularColor;

    DataPtr := @TempColor;
    DataSize:= SizeOf(TD3DColorValue) - SizeOf(Single);
   end;

  ShdrSpecularPower:
   begin
    DataPtr := @FSpecularPower;
    DataSize:= SizeOf(Single);
   end;

  ShdrLightVector:
   begin
    TempVector:= TD3DXVector3(Norm3(FLightVector));

    DataPtr := @TempVector;
    DataSize:= SizeOf(TD3DXVector3);
   end;

  ShdrSkinMtx:
   begin
    DataPtr := @FSkinMtx;
    DataSize:= SizeOf(TMatrix3);
   end;

  ShdrBumpMtx:
   begin
    DataPtr := @FBumpMtx;
    DataSize:= SizeOf(TMatrix3);
   end;
 end;
end;

//---------------------------------------------------------------------------
procedure TBumpMappingFx.UpdateTexture(Code: Integer;
 out ParamTex: IDirect3DTexture9);
begin
 ParamTex:= nil;

 case Code of
  ShdrSkinTexture:
   if (FSkinTexture <> nil) then ParamTex:= FSkinTexture.Tex9;

  ShdrBumpTexture:
   if (FBumpTexture <> nil) then ParamTex:= FBumpTexture.Tex9;
 end;
end;

//---------------------------------------------------------------------------
procedure TBumpMappingFx.Draw(Mesh: TAsphyreCustomMesh);
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
procedure TBumpMappingFx.Draw(Mesh: TAsphyreCustomMesh;
 const World: TMatrix4; SkinTex, BumpTex: TAsphyreCustomImage);
begin
 FSkinTexture:= nil;
 if (SkinTex <> nil) then FSkinTexture:= SkinTex.Texture[0];

 FBumpTexture:= nil;
 if (BumpTex <> nil) then FBumpTexture:= BumpTex.Texture[0];
 
 WorldMtx.LoadMtx(@World);

 UpdateAll();

 Draw(Mesh);
end;

//---------------------------------------------------------------------------
end.
