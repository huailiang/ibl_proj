Shader "PBR/BrdfLut"
{
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "../common/stdlib.hlsl"
            #include "../common/brdf.hlsl"

            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            
            float4 frag(v2f i) : SV_Target
            {
                float2 brdf = IntegrateBRDF(i.uv.x,i.uv.y);
                return float4(brdf,0,1);
            }
            ENDCG
        }
    }
}