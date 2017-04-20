unit CookTorranceFx;
//---------------------------------------------------------------------------
// CookTorranceFx.pas                                   Modified: 28-Apr-2007
// Cook-Torrance reflectance shader interface                     Version 1.0
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
// The Original Code is CookTorranceFx.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// M. Sc. Yuriy Kotsarenko. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Direct3D9, d3dx9, Vectors2, Vectors3, Matrices4, AsphyreColors,
 AsphyreDevices, AsphyreShaderFX, AsphyreMeshes;

//---------------------------------------------------------------------------
type
 TCookTorranceFx = class(TAsphyreShaderEffect)
 private
  TempColor : TD3DColorValue;
  TempVector: TD3DXVector3;

  FShaderMode: TShaderEffectMode;
  FAmbient   : Single;
  FDiffuse   : TAsphyreColor;
  FSpecular  : Single;
  FRoughness : TPoint2;
  FLightDir  : TVector3;
 protected
  procedure Describe(); override;
  procedure UpdateParam(Code: Integer; out DataPtr: Pointer;
   out DataSize: Integer); override;
 public
  // The working mode of effect shader.
  property ShaderMode: TShaderEffectMode read FShaderMode write FShaderMode;

  property Ambient : Single read FAmbient write FAmbient;
  property Diffuse : TAsphyreColor read FDiffuse write FDiffuse;
  property Specular: Single read FSpecular write FSpecular;

  // Anisotropic roughness of specular term.
  property Roughness: TPoint2 read FRoughness write FRoughness;

  // The light direction vector.
  property LightDir: TVector3 read FLightDir write FLightDir;

  procedure Draw(Mesh: TAsphyreCustomMesh); overload;

  procedure Draw(Mesh: TAsphyreCustomMesh; const World: TMatrix4;
   Color: Cardinal; Ambient, Specular, RoughX, RoughY: Single); overload;

  procedure UpdateTech();

  constructor Create(ADevice: TAsphyreDevice);
 end;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
uses
 AsphyreScene;

//---------------------------------------------------------------------------
const
 ShdrAmbient     = 1;
 ShdrDiffuse     = 2;
 ShdrSpecular    = 3;
 ShdrRoughnessX  = 4;
 ShdrRoughnessY  = 5;
 ShdrLightDir    = 6;
 ShdrModeCompat  = 7;
 ShdrModePerf    = 8;
 ShdrModeQuality = 9;

//---------------------------------------------------------------------------
constructor TCookTorranceFx.Create(ADevice: TAsphyreDevice);
begin
 inherited;

 FShaderMode := semQuality;
 FAmbient    := 0.1;
 FDiffuse    := $FFFFFF;
 FSpecular   := 1.0;
 FRoughness  := Point2(0.85, 0.90);
 FLightDir:= Norm3(Vector3(1.0, 1.0, 1.0));
end;

//---------------------------------------------------------------------------
procedure TCookTorranceFx.Describe();
begin
 DescParam(sptWorldViewProjection,   'WorldViewProjection');
 DescParam(sptWorldInverseTranspose, 'WorldInverseTranspose');
 DescParam(sptCameraPosition,        'EyePos');
 DescParam(sptWorld,                 'World');

 DescParam(sptCustom, 'Ambient',  ShdrAmbient);
 DescParam(sptCustom, 'Diffuse',  ShdrDiffuse);
 DescParam(sptCustom, 'Specular', ShdrSpecular);

 DescParam(sptCustom, 'RoughnessX', ShdrRoughnessX);
 DescParam(sptCustom, 'RoughnessY', ShdrRoughnessY);

 DescParam(sptCustom, 'LightDir', ShdrLightDir);

 DescTechnique('CompatTech',  ShdrModeCompat);
 DescTechnique('PerfTech',    ShdrModePerf);
 DescTechnique('QualityTech', ShdrModeQuality);
end;

//---------------------------------------------------------------------------
procedure TCookTorranceFx.UpdateParam(Code: Integer; out DataPtr: Pointer;
 out DataSize: Integer);
begin
 case Code of
  ShdrAmbient:
   begin
    DataPtr := @FAmbient;
    DataSize:= SizeOf(Single);
   end;

  ShdrDiffuse:
   begin
    TempColor:= FDiffuse;

    DataPtr := @TempColor;
    DataSize:= SizeOf(TD3DColorValue) - SizeOf(Single);
   end;

  ShdrSpecular:
   begin
    DataPtr := @FSpecular;
    DataSize:= SizeOf(Single);
   end;

  ShdrRoughnessX:
   begin
    DataPtr := @FRoughness.x;
    DataSize:= SizeOf(Single);
   end;

  ShdrRoughnessY:
   begin
    DataPtr := @FRoughness.y;
    DataSize:= SizeOf(Single);
   end;

  ShdrLightDir:
   begin
    TempVector:= TD3DXVector3(-Norm3(FLightDir));

    DataPtr := @TempVector;
    DataSize:= SizeOf(TD3DXVector3);
   end;
 end;
end;

//---------------------------------------------------------------------------
procedure TCookTorranceFx.UpdateTech();
begin
 case FShaderMode of
  semCompatibility:
   UseTechnique(ShdrModeCompat);

  semPerformance:
   UseTechnique(ShdrModePerf);

  semQuality:
   UseTechnique(ShdrModeQuality);
 end;
end;

//---------------------------------------------------------------------------
procedure TCookTorranceFx.Draw(Mesh: TAsphyreCustomMesh);
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
procedure TCookTorranceFx.Draw(Mesh: TAsphyreCustomMesh;
 const World: TMatrix4; Color: Cardinal; Ambient, Specular, RoughX,
 RoughY: Single);
begin
 FRoughness.x:= RoughX;
 FRoughness.y:= RoughY;

 FAmbient := Ambient;
 FDiffuse := Color;
 FSpecular:= Specular;

 WorldMtx.LoadMtx(@World);

 UpdateAll();

 Draw(Mesh);
end;

//---------------------------------------------------------------------------
end.
