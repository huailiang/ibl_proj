Shader "PBR/PBS_LP" {
    Properties {        
        _MainTex ("Base Color", 2D) = "white" {}
        _Color ("Color", Color) = (0.0,0.0,0.0,1)
        _NormalMap ("Normal Map", 2D) = "bump" {}
        
        _Metal ("metal", 2D) = "white" {}
        _Roughness("roughness",2D) = "white" {}
        _AO("ao",2D) = "white" {}

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

    SubShader {
        Tags { "RenderType"="Opaque" }
        Pass {
            Name "FORWARD"
            Tags { "LightMode"="ForwardBase" }
            Blend  [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]

            CGPROGRAM
            
            #pragma target 3.0

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

            #include "common/vert.hlsl"
            #include "common/piexl.hlsl"
            #pragma vertex vertPBRForwardBase
            #pragma fragment fragPBRForwardBase

            ENDCG
        }
        Pass
        {
            Name "ShadowCaster"
            Tags{ "LightMode" = "ShadowCaster" }
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
    CustomEditor "PBRShaderGUI"
}