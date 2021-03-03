/**
* material.hlsl
*/


#ifndef UNITY_MATERIAL
#define UNITY_MATERIAL

uniform float4 _Color;

#ifdef SELF_TRIPLE_COLOR
uniform float4 _ColorR;
uniform float4 _ColorG;
uniform float4 _ColorB;
#endif

uniform sampler2D _MainTex; 
uniform float4 _MainTex_ST;
uniform sampler2D _NormalMap; 
uniform float4 _NormalMap_ST;

#ifdef USE_PBR_MAP
uniform sampler2D _Metal;
uniform sampler2D _Roughness;
#else
uniform float4 _Properties;
#endif

#ifdef USE_AO_MAP
uniform sampler2D _AO;
uniform float4 _AO_ST;
#endif

#if USE_SPECIAL_RIM_COLOR
uniform float4 _RimColor;
#endif

#if OPEN_SHADER_DEBUG
uniform float4 _DebugColor;
#endif


#endif //UNITY_MATERIAL