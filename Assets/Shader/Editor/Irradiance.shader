Shader "PBR/Irradiance"
{
    Properties
    {
        _Skybox("skybox",CUBE) = ""{}
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

            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : TEXCOORD0;
                float4 clipPos: POSITION;
            };


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = v.vertex;
                o.clipPos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            samplerCUBE _Skybox;

            float3 CulIrradiance(v2f f)
            {
                float3 irradiance = float3(0, 0, 0);
                const float delta = 0.1; 
                float nr_sample = 0;

                const float3 N = normalize(f.vertex);
                float3 up = float3(0, 1, 0);
                const float3 right = cross(up, N);
                up = cross(N, right);

                for (float phi = 0; phi < 2 * PI; phi += delta)
                {
                    for (float theta = 0; theta < 0.5 * PI; theta += delta)
                    {
                        const float3 tangSample = float3(sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta));
                        const float3 sampleVec = tangSample.x * right + tangSample.y * up + tangSample.z * N;
                        irradiance += texCUBE(_Skybox, sampleVec) * cos(theta) * sin(theta);
                        nr_sample++;
                    }
                }
                irradiance = PI * irradiance / float(nr_sample);
                return irradiance;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 irradiance = CulIrradiance(i);
                return fixed4(irradiance, 1);
            }
            ENDCG
        }
    }
}