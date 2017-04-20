
//---------------------------------------------------------------------------
#define SMAP_SIZE 512
//#define SHADOW_EPSILON 0.00115f
#define SHADOW_EPSILON 0.00005f
#define ShadowBilinearFilter

//---------------------------------------------------------------------------
float4x4 LightWVP;

//---------------------------------------------------------------------------
float4x4 WorldInverseTranspose;
float4x4 WorldViewProjection;
float4x4 World;
float3   EyePos;
float3x3 TexMtx;

//---------------------------------------------------------------------------
float3 LightPos = {1.0f, 1.0f, 1.0f};
float3 LightDir = {0.0f, -1.0f, 0.0f};

//---------------------------------------------------------------------------
float  Ambient;
float3 Specular;
float1 SpecPower;

//---------------------------------------------------------------------------
texture SkinTex;
texture BumpTex;
texture SMapTex;

//------------------------------------
sampler SkinSampler = sampler_state 
{
  texture   = <SkinTex>;
  AddressU  = WRAP;
  AddressV  = WRAP;
  AddressW  = WRAP;
  MIPFILTER = LINEAR;
  MINFILTER = LINEAR;
  MAGFILTER = LINEAR;
};

//------------------------------------
sampler BumpSampler = sampler_state 
{
  texture   = <BumpTex>;
  AddressU  = WRAP;
  AddressV  = WRAP;
  AddressW  = WRAP;
  MIPFILTER = LINEAR;
  MINFILTER = LINEAR;
  MAGFILTER = LINEAR;
};

//---------------------------------------------------------------------------
sampler ShadowSampler = sampler_state
{
  Texture   = <SMapTex>;
  MinFilter = Point;
  MagFilter = Point;
  MipFilter = Point;
  AddressU  = Clamp;
  AddressV  = Clamp;
};

//---------------------------------------------------------------------------
// ApplyShadowMap()
//
// Projects the shadow map to the scene and calculates if the pixel is inside
// or outside the shadow. The resulting value is in [0..1] range.
//---------------------------------------------------------------------------
float ApplyShadowMap(float4 ProjTex)
{
  // Project the texture coords and scale/offset to [0, 1].
  ProjTex.xy /= ProjTex.w;            
  ProjTex.x =  0.5f * ProjTex.x + 0.5f; 
  ProjTex.y = -0.5f * ProjTex.y + 0.5f;
  
  // Compute pixel depth for shadowing.
  float Depth = ProjTex.z / ProjTex.w;
 
  // Transform to texel space.
  float2 TexelPos = SMAP_SIZE * ProjTex.xy;  

  // Apply bilinear multisampling to shadow map.
  #ifdef ShadowBilinearFilter
  float dx = 1.0f / SMAP_SIZE;
  
  // -> Retreive individual shadow map samples.
  float s0 = (tex2D(ShadowSampler, ProjTex.xy).r + 
   SHADOW_EPSILON < Depth) ? 0.3f : 1.0f;
  float s1 = (tex2D(ShadowSampler, ProjTex.xy + 
   float2(dx, 0.0f)).r + SHADOW_EPSILON < Depth) ? 0.3f : 1.0f;
  float s2 = (tex2D(ShadowSampler, ProjTex.xy + 
   float2(0.0f, dx)).r + SHADOW_EPSILON < Depth) ? 0.3f : 1.0f;
  float s3 = (tex2D(ShadowSampler, ProjTex.xy + 
   float2(dx, dx)).r + SHADOW_EPSILON < Depth) ? 0.3f : 1.0f;
	
  // Determine the lerp amounts.           
  float2 Lerps = frac(TexelPos);
  	
  return lerp(lerp(s0, s1, Lerps.x), lerp(s2, s3, Lerps.x ), Lerps.y);
  #else
  // Retreive a single sample from shadow map
  return (tex2D(ShadowSampler, ProjTex.xy).r + SHADOW_EPSILON < Depth) ? 0.3f : 1.0f;
  #endif
}

//---------------------------------------------------------------------------
float4 ApplyPhong(float2 InTex, float3 ToEye, float3 LightDir, 
 float3 NormalT, float ShadowCoef)
{
  float4 TexPixel = tex2D(SkinSampler, InTex);
  
  float SelfShadow = saturate(4.0f * LightDir.z);
  
  float3 Reflection = normalize(2.0f * NormalT * dot(NormalT, 
   LightDir) - LightDir);
   
  float3 Diffuse = TexPixel.rgb * SelfShadow * saturate(dot(LightDir, NormalT));
  
  float3 SpecularTerm = Specular * SelfShadow * (pow(saturate(dot(Reflection, 
   ToEye)), SpecPower));
  
  float3 AmbientTerm = Ambient * TexPixel.rgb; 
    
  return float4(AmbientTerm + (Diffuse + SpecularTerm) * ShadowCoef, 
   TexPixel.a);
}

//---------------------------------------------------------------------------
// ShadowBumpPhongVS()
//
// Vertex shader for Shadow Mapping + Bump Mapping + Phong illumination.
//---------------------------------------------------------------------------
void ShadowBumpPhongVS( 
 float3 PositionOS: POSITION0, 
 float3 TangentOS : TANGENT0,
 float3 BinormalOS: BINORMAL0,
 float3 NormalOS  : NORMAL0,
 float2 InTex     : TEXCOORD0,
 out float4 OutPos   : POSITION, 
 out float2 OutTex   : TEXCOORD0,
 out float4 ProjTex  : TEXCOORD1,
 out float3 OutToEye   : TEXCOORD2,
 out float3 OutLightDir: TEXCOORD3)
{
  // Compute projected texture coordinates.
  float4 PosWS = mul(float4(PositionOS, 1.0f), World);
  ProjTex = mul(PosWS, LightWVP);
  
  //float3 LightVecW = normalize(LightPos - PosWS);
  //float SpotCoef = 1.0f;//pow(saturate(dot(LightVecW, LightDir)), SpotPower);
  //Out
    
  // Transform normal, binormal and tangent vectors to world space.
  float3 NormalWS   = mul(float4(NormalOS, 0.0f), WorldInverseTranspose).xyz;
  float3 TangentWS  = mul(float4(TangentOS, 0.0f), WorldInverseTranspose).xyz;
  float3 BinormalWS = mul(float4(BinormalOS, 0.0f), WorldInverseTranspose).xyz;
  
  NormalWS   = normalize(NormalWS);
  TangentWS  = normalize(TangentWS);
  BinormalWS = normalize(BinormalWS);
  
  // Compute matrix for transforming from world space to tangent space.
  float3x3 ToTangent = transpose(float3x3(TangentWS, BinormalWS, NormalWS));
      
  // Transform light direction and vertex-to-eye vector to tangent space.
  float3 LightDir = normalize(PosWS - LightPos);
  
  OutLightDir = mul(LightDir, ToTangent);
  OutToEye    = mul(EyePos - PosWS, ToTangent);  
 
  // Transform vertex position. 
  OutPos = mul(float4(PositionOS, 1.0f), WorldViewProjection);
  
  // Pass skin texture coordinates.
  OutTex = mul(float3(InTex, 1.0f), TexMtx).xy;
}

//---------------------------------------------------------------------------
// ShadowBumpPhongPS()
//
// Pixel shader for Shadow Mapping + Bump Mapping + Phong illumination.
//---------------------------------------------------------------------------
float4 ShadowBumpPhongPS(
 float2 InTex   : TEXCOORD0,
 float4 ProjTex : TEXCOORD1,
 float3 ToEye   : TEXCOORD2,
 float3 LightDir: TEXCOORD3) : COLOR
{
  float ShadowCoef = ApplyShadowMap(ProjTex);  

  float3 NormalT = tex2D(BumpSampler, InTex);
  NormalT = normalize(2.0f * NormalT - 1.0f);
  
  return ApplyPhong(InTex, normalize(ToEye), -normalize(LightDir),
   NormalT, ShadowCoef);   
}

//---------------------------------------------------------------------------
float4 ProjBumpPhongPS(
 float2 InTex   : TEXCOORD0,
 float4 ProjTex : TEXCOORD1,
 float3 ToEye   : TEXCOORD2,
 float3 LightDir: TEXCOORD3) : COLOR
{
  float3 NormalT = tex2D(BumpSampler, InTex);
  NormalT = normalize(2.0f * NormalT - 1.0f);
     
  // Project the texture coords and scale/offset to [0, 1].
  ProjTex.xy /= ProjTex.w;            
  ProjTex.x =  0.5f * ProjTex.x + 0.5f; 
  ProjTex.y = -0.5f * ProjTex.y + 0.5f;

  float4 ShadowCol = tex2D(ShadowSampler, ProjTex.xy);
  
  return ApplyPhong(InTex, normalize(ToEye), -normalize(LightDir), 
   NormalT, 1.0f) * ShadowCol;  
}

//---------------------------------------------------------------------------
void BuildShadowMapVS(
 float3 PosL : POSITION0,
 out float4 PosH  : POSITION,
 out float2 Depth : TEXCOORD0
 )
{
  PosH  = mul(float4(PosL, 1.0f), LightWVP);
  Depth = PosH.zw;
}

//---------------------------------------------------------------------------
float4 BuildShadowMapPS(float2 Depth : TEXCOORD0) : COLOR
{
  return Depth.x / Depth.y;
}

//---------------------------------------------------------------------------
technique BuildShadowMap
{
  pass p0
  {
    VertexShader = compile vs_2_0 BuildShadowMapVS();
    PixelShader  = compile ps_2_0 BuildShadowMapPS();
  }
}

//---------------------------------------------------------------------------
technique ShadowBumpPhong
{
  pass p0
  {
    VertexShader = compile vs_2_0 ShadowBumpPhongVS();
    PixelShader  = compile ps_2_0 ShadowBumpPhongPS();
  }
}

//---------------------------------------------------------------------------
technique ProjBumpPhong
{
  pass p0
  {
    VertexShader = compile vs_2_0 ShadowBumpPhongVS();
    PixelShader  = compile ps_2_0 ProjBumpPhongPS();
  }
}
