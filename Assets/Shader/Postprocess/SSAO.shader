Shader "MyShader/Postprocess/SSAO"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Strength ("Strength", Float) = 1
        _Sensitivity ("Sensitivity", Range(0, 1)) = 1
        _Radius ("Radius", Float) = 16
        _DepthThreshold ("Depth Threshold", Float) = 0.1
        _OcclusionDepth ("Occlusion Depth", Float) = 1
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float _Strength;
            float _Sensitivity;
            float _Radius;
            float _DepthThreshold;
            float _OcclusionDepth;

            
            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            sampler2D _CameraDepthNormalsTexture;
            half4 _CameraDepthNormalsTexture_TexelSize;
            sampler2D _CameraDepthTexture;
            float4 _CameraClipPlane;

            inline float cross2(float2 a, float2 b)
            {
                return cross(float3(a.xy, 0), float3(b.xy, 0)).z;
            }
            
            inline float calculateOcclusionAt(float2 uv, int i, int j, float3 centerNormal, float centerDepth)
            {
                float2 delta = float2(i, j);
                
                float3 tangent = float3(delta.xy, -dot(centerNormal.xy, delta.xy)/centerNormal.z);
                tangent = normalize(tangent);
                float2 sampleUV = uv + delta * _Radius * _CameraDepthNormalsTexture_TexelSize.xy;
                float3 sampleNormal;
                float sampleDepth;
                DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, sampleUV.xy), sampleDepth, sampleNormal);
                sampleDepth = _CameraClipPlane.x + sampleDepth * _CameraClipPlane.z;
                sampleNormal = normalize(sampleNormal);

                if(centerDepth - sampleDepth > _DepthThreshold)
                    return 0;
                if(sampleDepth - centerDepth > _OcclusionDepth)
                    return 0;
                if(dot(centerNormal, sampleNormal) > 0.9)
                    return 0;

                float2 n = normalize(float2(dot(sampleNormal, tangent), dot(sampleNormal, centerNormal)));

                
                if(cross2(float2(0, 1), n) > 0)
                {
                    return saturate(_Sensitivity * smoothstep(-1, 1, dot(n, float2(0, 1))));
                }
                return 0;
            }

            #define SAMPLE_N 4

            inline float AO(float2 uv)
            {
                float3 centerNormal;
                float centerDepth;
                DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, uv.xy), centerDepth, centerNormal);
                centerNormal = normalize(centerNormal);
                centerDepth = _CameraClipPlane.x + centerDepth * _CameraClipPlane.z;
                //centerDepth = Linear01Depth(centerDepth);
                float occlusion = 0;
                float weights[SAMPLE_N] = {0.382925, 0.24173, 0.0605975, 0.00597704};
                float scale = 0.523233;
                for(int i = 0; i < SAMPLE_N; i++)
                {
                    for(int j = 0; j < SAMPLE_N; j++)
                    {
                        float weight = weights[i] * weights[j];
                        occlusion += weight * calculateOcclusionAt(uv, i+1, j+1, centerNormal, centerDepth);
                        occlusion += weight * calculateOcclusionAt(uv, -i-1, j+1, centerNormal, centerDepth);
                        occlusion += weight * calculateOcclusionAt(uv, i+1, -j-1, centerNormal, centerDepth);
                        occlusion += weight * calculateOcclusionAt(uv, -i-1, -j-1, centerNormal, centerDepth);
                    }
                }
                return occlusion * scale * _Strength;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 color = tex2D(_MainTex, i.uv).rgb;

                float occlusion = AO(i.uv);
                
                return fixed4(occlusion.xxx, 1);
            }
            ENDCG
        }

        // #1 Apply SSAO
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _ScreenImage;
            sampler2D _SSAO_Texture;

            fixed4 frag (v2f i) : SV_Target
            {
                float3 color = tex2D(_ScreenImage, i.uv).rgb;
                float ssao = tex2D(_SSAO_Texture, i.uv).r;
                ssao = saturate(1 - ssao);
                
                return fixed4(ssao * color, 1);
            }
            ENDCG
        }
    }
}
