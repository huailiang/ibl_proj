Shader "PBR/PBS_LP2"
{
    Properties
    {
        _MainTex ("Base Color", 2D) = "white" {}
        _Color ("Color", Color) = (0.0,0.0,0.0,1)
        _NormalMap ("Normal Map", 2D) = "bump" {}

        _Metal ("metal", 2D) = "white" {}
        _Roughness("roughness",2D) = "white" {}
        _AO("ao",2D) = "white" {}

        _IrradianceMap("irradiance",CUBE) = ""{}
        _PrefilterMap("prefilter",CUBE) = ""{}
        _brdfLut ("brdfLut", 2D) = "white" {}

        [HideInInspector]
        _DebugMode("debugMode", float) = 0.0

        [HideInInspector]
        _RimColor("RimColor",Color)=(1,1,1,1)

        [HideInInspector]
        _DebugColor("DebugColor",Color)=(1,1,1,1)

        [HideInInspector]
        _SrcBlend("src", Float) = 1.0

        [HideInInspector]
        _DstBlend("dst", Float) = 0.0

        [HideInInspector]
        _ZWrite("zwrite", Float) = 1.0
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        Pass
        {
            Name "FORWARD"
            Tags
            {
                "LightMode"="ForwardBase"
            }
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]

            CGPROGRAM
            #pragma target 3.0

            
            //#define UNITY_NO_DXT5nm
            #define USE_METAL_MAP 
            #define USE_ROUGHNESS_MAP
            #define USE_AO_MAP
            #define USE_PBR_MAP (defined (USE_METAL_MAP) && defined(USE_ROUGHNESS_MAP))

            #pragma shader_feature OPEN_SHADER_DEBUG
            #pragma shader_feature USE_SPECIAL_RIM_COLOR
            #pragma shader_feature ALPHA_TEST
            #pragma shader_feature ALPHA_PREMULT

            #define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
            #pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
            #pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog

            #include "Lighting.cginc"
            #include "UnityCG.cginc"
            #include "common/brdf.hlsl"
            #include "common/material.hlsl"

            uniform samplerCUBE _IrradianceMap;
            uniform samplerCUBE _PrefilterMap;
            uniform samplerCUBE _PrefilterMap2;
            uniform sampler2D _brdfLut;

            struct appdata
            {
                float2 texcoord0 : TEXCOORD0;
                
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                
                half3 normalDir : TEXCOORD2; 
                half3 tangentDir : TEXCOORD3; 
                half3 bitangentDir : TEXCOORD4; 
                float3 normal : NORMAL;
            };

            float3 BRDFOutout(v2f i)
            {
                const float3 tanNormal = UnpackNormal(tex2D(_NormalMap, TRANSFORM_TEX(i.uv0,_NormalMap)));
                const float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
                const half3 worldNorlmal  = normalize(mul(tanNormal, tangentTransform));

				const float3 V = normalize(_WorldSpaceCameraPos.xyz -i.posWorld.xyz);
                const float3 R = reflect(-V, worldNorlmal);
                const float3 metallic = tex2D(_Metal,  i.uv0);
                const float3 albedo = tex2D(_MainTex, TRANSFORM_TEX(i.uv0, _MainTex));
                float roughness = tex2D(_Roughness,  i.uv0).x;
                const float ao = tex2D(_AO, TRANSFORM_TEX(i.uv0, _AO)).x;
 
                float3 F0 = float3(0.04, 0.04, 0.04);
                F0 = lerp(F0, albedo, metallic);

                // direct light
				const float3 L = normalize(_WorldSpaceLightPos0.xyz -i.posWorld.xyz);
                const float3 H = normalize(V + L);
                const float distance = length(_WorldSpaceLightPos0 - i.posWorld);
                const float attenuation = 1.0 / (distance * distance);
                const float3 radiance = _LightColor0.rgb * attenuation;

                // Cook-Torrance BRDF
                const float NDF = DistributionGGX(worldNorlmal, H, roughness);
                const float G = GeometrySmith2(worldNorlmal, V, L, roughness);
                float3 F = fresnelSchlick(max(dot(H, V), 0.0), F0);

                const float3 nominator = NDF * G * F;
                const float denominator = 4 * max(dot(worldNorlmal, V), 0.0) * max(dot(worldNorlmal, L), 0.0) + 0.001;
                float3 specular = nominator / denominator;

                float3 kS = F;
                float3 kD = float3(1, 1, 1) - kS;
                kD *= 1.0 - metallic;
                const float NdotL = max(dot(worldNorlmal, L), 0.0);
               float3 directColor = (kD * albedo / PI + specular) * radiance * NdotL;

                // ambient lighting (we now use IBL as the ambient term)
                F = fresnelSchlickRoughness(max(dot(worldNorlmal, V), 0.0), F0, roughness);
                kS = F;
                kD = 1.0 - kS;
                kD *= 1.0 - metallic;

                const float3 irradiance = texCUBE(_IrradianceMap, worldNorlmal).rgb;
                const float3 diffuse = irradiance * albedo;

                // const float max_reflect_lod = 4.0;
                 // const float3 prefilteredColor = texCUBElod(_PrefilterMap, float4(R, roughness * max_reflect_lod)).rgb;
				const float3 prefilteredColor = texCUBE(_PrefilterMap, R).rgb;

                float NdotV = max(dot(worldNorlmal, V), 0);
                const float2 brdf = tex2D(_brdfLut, float2(NdotV, roughness)).rg;
                specular = prefilteredColor * (F * brdf.x + brdf.y);
                const float3 indirectColor = (kD * diffuse + specular) * ao;
				float3 color = indirectColor + directColor;
                // HDR tonemapping
                color = color / (color + float3(1, 1, 1));
                // gamma correct
                // color = pow(color, float3(0.44, 0.44, 0.44)); // 0.45 = 1.0/2.2
                return color;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.uv0 = v.texcoord0;

                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize(mul(unity_ObjectToWorld, float4( v.tangent.xyz, 0.0)).xyz);
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 o = BRDFOutout(i);
                return fixed4(o, 1);
            }

            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
            ZWrite On ZTest LEqual

            CGPROGRAM
            #pragma target 3.0
            #include "UnityStandardShadow.cginc"
            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster
            ENDCG
        }
    }
    FallBack "Diffuse"
}