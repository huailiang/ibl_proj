Shader "PBR/Prefilter"
{
    Properties
    {
        _skybox("skybox",CUBE) = ""{}
        _roughness("roughness",Range(0,1)) = 0.2
    }
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
            };

            struct v2f
            {
                float3 vertex : NORMAL;
                float4 clipPos : SV_POSITION;
            };

            samplerCUBE _skybox;
            float _roughness;
            
            v2f vert(const appdata v)
            {
                v2f o;
                o.clipPos = UnityObjectToClipPos(v.vertex);
                o.vertex = v.vertex.xyz;
                return o;
            }

            float4 frag(v2f v) : SV_Target
            {
                float3 N = normalize(v.vertex);
    
                // make the simplyfying assumption that V equals R equals the normal 
                const float3 R = N;
                const float3 V = R;

                const uint SAMPLE_COUNT = 512u;
                float3 prefilteredColor = float3(0,0,0);
                float totalWeight = 0.0;
                
                for(uint i = 0u; i < SAMPLE_COUNT; ++i)
                {
                    // generates a sample vector that's biased towards the preferred alignment direction (importance sampling).
                    float2 xi = Hammersley(i, SAMPLE_COUNT);
                    const float3 h = ImportanceSampleGGX(xi, N, _roughness);
                    float3 L = normalize(2.0 * dot(V, h) * h - V);

                    const float NdotL = max(dot(N, L), 0.0);
                    if(NdotL > 0.0)
                    {
                        // sample from the environment's mip level based on roughness/pdf
                        const float D = DistributionGGX(N, h, _roughness);
                        const float NdotH = max(dot(N, h), 0.0);
                        const float HdotV = max(dot(h, V), 0.0);
                        const float pdf = D * NdotH / (4.0 * HdotV) + 0.0001;

                        const float resolution = 512.0; // resolution of source cubemap (per face)
                        const float saTexel  = 4.0 * PI / (6.0 * resolution * resolution);
                        const float saSample = 1.0 / (float(SAMPLE_COUNT) * pdf + 0.0001);

                        float mip_level = _roughness == 0.0 ? 0.0 : 0.5 * log2(saSample / saTexel); 
                        
                        prefilteredColor += texCUBElod(_skybox, half4(L, mip_level)).rgb * NdotL;
                        totalWeight      += NdotL;
                    }
                }

                prefilteredColor = prefilteredColor / totalWeight;
                return float4(prefilteredColor,1);
            }
            ENDCG
        }
    }
}