//---------------------------------------------------------------------------
// BumpMapping.fx                                       Modified: -Apr-2007
// Bump-mapping shader with phong reflection model                Version 1.0
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
// The Original Code is BumpMapping.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// M. Sc. Yuriy Kotsarenko. All Rights Reserved.
//---------------------------------------------------------------------------
uniform extern float4x4 WorldInverseTranspose : WorldInverseTranspose;
uniform extern float4x4 WorldViewProjection   : WorldViewProjection;
uniform extern float4x4 World  : World;
uniform extern float3   EyePos : CameraPosition;
uniform extern float4x4 WorldInverse : WorldInverse;
uniform extern float3x3 SkinMtx;
uniform extern float3x3 BumpMtx;

//---------------------------------------------------------------------------
uniform extern float3 AmbientColor : Ambient
<
  string UIName   = "AmbientColor";
  string UIWidget = "Color";
> = {0.0f, 0.0f, 0.1f};

//---------------------------------------------------------------------------
uniform extern float4 DiffuseColor : Diffuse
<
  string UIName   = "DiffuseColor";
  string UIWidget = "Color";
> = {0.0f, 0.0f, 1.0f, 1.0f};

//---------------------------------------------------------------------------
uniform extern float3 SpecularColor : Specular
<
  string UIName   = "SpecularColor";
  string UIWidget = "Color";
> = {1.0f, 1.0f, 1.0f};

//---------------------------------------------------------------------------
uniform extern float SpecularPower
<
  string UIWidget = "slider";
  float  UIMin    = 0.0;
  float  UIMax    = 50.0;
  float  UIStep   = 1.0;
  string UIName   = "SpecularPower";
> = 8.0;

//---------------------------------------------------------------------------
uniform extern float3 LightVector : Direction
<
  string Object = "DirectionalLight";
  string Space = "World";
> = {1.0f, -1.0f, 1.0f};

//---------------------------------------------------------------------------
texture SkinTexture
<
  string ResourceName = "metal.dds";
>;

//------------------------------------
sampler SkinSampler = sampler_state 
{
  texture   = <SkinTexture>;
  AddressU  = WRAP;
  AddressV  = WRAP;
  AddressW  = WRAP;
  MIPFILTER = LINEAR;
  MINFILTER = LINEAR;
  MAGFILTER = LINEAR;
};

//---------------------------------------------------------------------------
texture BumpTexture
<
  string ResourceName = "metal_normal.dds";
>;

//------------------------------------
sampler BumpSampler = sampler_state 
{
  texture   = <BumpTexture>;
  AddressU  = WRAP;
  AddressV  = WRAP;
  AddressW  = WRAP;
  MIPFILTER = LINEAR;
  MINFILTER = LINEAR;
  MAGFILTER = LINEAR;
};

//---------------------------------------------------------------------------
void VS(
 float3 PositionOS: POSITION0, 
 float3 TangentOS : TANGENT0,
 float3 BinormalOS: BINORMAL0,
 float3 NormalOS  : NORMAL0,
 float2 InTex     : TEXCOORD0,
 out float4 OutPos     : POSITION, 
 out float4 OutTex     : TEXCOORD0,
 out float3 OutToEye   : TEXCOORD1,
 out float3 OutLightVec: TEXCOORD2
)
{
  // Transform normal, binormal and tangent vectors to world space.
  float3 NormalWS   = mul(float4(NormalOS, 0.0f), WorldInverseTranspose).xyz;
  float3 TangentWS  = mul(float4(TangentOS, 0.0f), WorldInverseTranspose).xyz;
  float3 BinormalWS = mul(float4(BinormalOS, 0.0f), WorldInverseTranspose).xyz;
  
  NormalWS   = normalize(NormalWS);
  TangentWS  = normalize(TangentWS);
  BinormalWS = normalize(BinormalWS);
  
  // Compute matrix for transforming from world space to tangent space.
  float3x3 WorldToTangent = transpose(float3x3(TangentWS, BinormalWS, NormalWS));
  
  // Transform light direction and vertex-to-eye vector to tangent space.
  OutLightVec = mul(LightVector, WorldToTangent);
    
  float3 PosWS = mul(float4(PositionOS, 1.0f), WorldToTangent).xyz;
  OutToEye = mul(EyePos - PosWS, WorldToTangent);
  
  OutPos = mul(float4(PositionOS, 1.0f), WorldViewProjection);
  
  // Transform texture coordinates.
  OutTex.xy = mul(float3(InTex, 1.0f),  SkinMtx).xy;
  OutTex.zw = mul(float3(InTex, 1.0f), BumpMtx).xy;
}

//---------------------------------------------------------------------------
float4 PS(
 float4 InTex: TEXCOORD0,
 float3 ToEye: TEXCOORD1,
 float3 LightVec: TEXCOORD2 
): COLOR
{
  // Normalize vertex-to-eye and light direction vectors.
  ToEye    = normalize(ToEye);
  LightVec = -normalize(LightVec);
    
  // Retreive surface normal from bump texture.
  float3 NormalT = tex2D(BumpSampler, InTex.zw);
  NormalT = normalize(2.0f * NormalT - 1.0f);
  
  // Retreive skin pixel from skin texture.
  float4 TexPixel = tex2D(SkinSampler, InTex.xy);
  
  // Calculate self-shadow component.
  float Shadow = saturate(4.0f * LightVec.z);
  
  // Compute diffuse color component.
  float3 Diffuse = TexPixel.rgb * DiffuseColor.rgb * 
   Shadow * saturate(dot(LightVec, NormalT));
    
  // Compute specular color component.
  float3 Reflection = normalize(2.0f * NormalT * dot(NormalT, 
   LightVec) - LightVec);
      
  float3 Specular = SpecularColor * Shadow * (pow(saturate(dot(Reflection, 
   ToEye)), SpecularPower));
  
  // Compute ambient color component.
  float3 Ambient = AmbientColor * TexPixel.rgb; 
  
  return float4(Ambient + Diffuse + Specular, TexPixel.a * DiffuseColor.a);  
}

//---------------------------------------------------------------------------
technique BumpMapping
{
  pass p0 
  {		
    VertexShader = compile vs_2_0 VS();
    PixelShader  = compile ps_2_0 PS();
  }
}