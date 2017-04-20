//---------------------------------------------------------------------------
// Cook-Torrance reflection model
// Original code by Jack Hoxley posted at http://www.GameDev.Net
// Modifications by Yuriy Kotsarenko (ykot@inbox.com)
//---------------------------------------------------------------------------
uniform extern float4x4 WorldInverseTranspose : WorldInverseTranspose;
uniform extern float4x4 WorldViewProjection : WorldViewProjection;
uniform extern float4x4 World  : World;
uniform extern float3   EyePos : CameraPosition;

//---------------------------------------------------------------------------
uniform extern float Ambient
<
  string UIWidget = "slider";
  float  UIMin  = -0.5;
  float  UIMax  = 1.5;
  float  UIStep = 0.01;
  string UIName = "Ambient";
> = 0.1;

//---------------------------------------------------------------------------
uniform extern float3 Diffuse : Diffuse
<
  string UIName   = "DiffuseColor";
  string UIWidget = "Color";
> = {0.0f, 0.0f, 1.0f};

//---------------------------------------------------------------------------
uniform extern float Specular
<
  string UIWidget = "slider";
  float  UIMin  = -1.0;
  float  UIMax  = 5.0;
  float  UIStep = 0.01;
  string UIName = "Specular";
> = 1.5;

//---------------------------------------------------------------------------
uniform extern float RoughnessX
<
  string UIWidget = "slider";
  float  UIMin  = 0.0;
  float  UIMax  = 2.0;
  float  UIStep = 0.01;
  string UIName = "RoughnessX";
> = 0.85;

//---------------------------------------------------------------------------
uniform extern float RoughnessY
<
  string UIWidget = "slider";
  float  UIMin  = 0.0;
  float  UIMax  = 2.0;
  float  UIStep = 0.01;
  string UIName = "RoughnessY";
> = 0.9;

//---------------------------------------------------------------------------
uniform extern float3 LightDir : Direction
<
  string Object = "DirectionalLight";
  string Space = "World";
> = {1.0f, -1.0f, 1.0f};

//---------------------------------------------------------------------------
float4 ApplyCookTorrance(float3 NormalW, float3 PosW)
{
  float3 RoughnessParams = {0.5f, 0.5f, 0.5f};
		
  float3 ViewDir        = normalize(EyePos - PosW);
  float3 vHalf          = normalize(LightDir + ViewDir);
  float  NormalDotHalf  = dot(NormalW, vHalf);
  float  ViewDotHalf    = dot(vHalf,  ViewDir);
  float  NormalDotView  = dot(NormalW, ViewDir);
  float  NormalDotLight = dot(NormalW, LightDir);
  
  // Compute the geometric term
  float  G1 = (2.0f * NormalDotHalf * NormalDotView) / ViewDotHalf;
  float  G2 = (2.0f * NormalDotHalf * NormalDotLight) / ViewDotHalf;
  float  G  = min(1.0f, max(0.0f, min(G1, G2)));
  
  // Compute the fresnel term
  float  F = RoughnessY + (1.0f - RoughnessY) * 
   pow(1.0f - NormalDotView, 5.0f);
  
  // Compute the roughness term
  float  R_2     = RoughnessX * RoughnessX;
  float  NDotH_2 = NormalDotHalf * NormalDotHalf;
  float  A       = 1.0f / (4.0f * R_2 * NDotH_2 * NDotH_2);
  float  B       = exp(-(1.0f - NDotH_2) / (R_2 * NDotH_2));
  float  R       = A * B;

  float Irradiance = max(0.0f, NormalDotLight);
  
  // Compute the final term
  float SpecularTerm = Specular * Irradiance * G * F * R / 
   (NormalDotLight * NormalDotView);
   
  float3 DiffuseTerm = Diffuse * (Ambient + Irradiance);
   
  return float4(DiffuseTerm + SpecularTerm, 1.0f);
}

//---------------------------------------------------------------------------
void PerfVS(
 float3 PosL   : POSITION0, 
 float3 NormalL: NORMAL0,
 out float4 PosH: POSITION, 
 out float4 Col : COLOR)
{
  float3 NormalW = mul(float4(NormalL, 0.0f), WorldInverseTranspose).xyz;
  NormalW = normalize(NormalW);
  
  float3 PosW = mul(float4(PosL, 1.0f), World);
  /*float3 LightToPos = normalize(LightPos - PosW);
  
  float Spot = saturate(pow(saturate(dot(LightToPos, -LightVector)), 4.0) * 4);*/
  
  PosH = mul(float4(PosL, 1.0f), WorldViewProjection);
//  Col  = ApplyCookTorrance(NormalW, PosW, LightToPos) * Spot;
  Col  = ApplyCookTorrance(NormalW, PosW);
}

//---------------------------------------------------------------------------
void QualityVS(
 float3 PosL    : POSITION0, 
 float3 NormalL : NORMAL0,
 out float4 PosH       : POSITION, 
 out float3 NormalW    : TEXCOORD0, 
 out float3 PosW       : TEXCOORD1
// out float3 LightToPos : TEXCOORD2
// out float2  Spot       : TEXCOORD3
 )
{
  NormalW    = mul(float4(NormalL, 0.0f), WorldInverseTranspose).xyz;
  PosW       = mul(float4(PosL, 1.0f), World);
//  LightToPos = normalize(LightPos - PosW);

  //Spot = pow(saturate(dot(LightToPos, -LightVector)), 4.0) * 4;

  PosH = mul(float4(PosL, 1.0f), WorldViewProjection);
}

//---------------------------------------------------------------------------
float4 QualityPS(
 float3 NormalW : TEXCOORD0, 
 float3 PosW    : TEXCOORD1
// float3 LightToPos : TEXCOORD2
 /*float2  Spot : TEXCOORD3*/
 ): COLOR
{
//  float Spot = pow(saturate(dot(normalize(LightToPos), -LightVector)), 4.0) * 4;

/*  return ApplyCookTorrance(normalize(NormalW), PosW, normalize(LightToPos)) * 
   saturate(Spot);*/
  return ApplyCookTorrance(normalize(NormalW), PosW);
   
}

//---------------------------------------------------------------------------
technique CompatTech
{
  pass p0 
  {	
    VertexShader = compile vs_1_1 PerfVS();
  }
}

//---------------------------------------------------------------------------
technique PerfTech
{
  pass p0 
  {		
    VertexShader = compile vs_2_0 PerfVS();
  }
}

//---------------------------------------------------------------------------
technique QualityTech
{
  pass p0 
  {		
    VertexShader = compile vs_2_0 QualityVS();
    PixelShader  = compile ps_2_0 QualityPS();
  }
}