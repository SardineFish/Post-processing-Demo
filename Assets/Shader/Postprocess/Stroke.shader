Shader "MyShader/Postprocess/Stroke"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _StrokeColor ("Stroke Color", Color) = (0,0,0,1)
        _StrokeOnly ("Stroke Only", Range(0, 1)) = 0
        _SampleDist ("Sample Distance", Range(0, 16)) = 1
        _Sensitivity ("Sensitivity", Range(0, 1)) = 1
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
                float4 vertex : SV_POSITION;
                half2 uv[5]: texcoord0;
            };

            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            sampler2D _CameraDepthNormalsTexture;
            float _StrokeOnly;
            float4 _StrokeColor;
            float _SampleDist;
            float _Sensitivity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv[0] = v.uv;

                o.uv[1] = v.uv + _MainTex_TexelSize.xy * half2(1, 1) * _SampleDist;
                o.uv[2] = v.uv + _MainTex_TexelSize.xy * half2(-1, -1) * _SampleDist;
                o.uv[3] = v.uv + _MainTex_TexelSize.xy * half2(-1, 1) * _SampleDist;
                o.uv[4] = v.uv + _MainTex_TexelSize.xy * half2(1, -1) * _SampleDist;
                return o;
            }

            half CheckSame(half4 center, half4 sample)
            {
                half2 centerNormal = center.xy;
                float centerDepth = DecodeFloatRG(center.zw);
                half2 sampleNormal = sample.xy;
                float sampleDepth = DecodeFloatRG(sample.zw);

                half2 diffNormal = abs(centerNormal - sampleNormal) * _Sensitivity;
                int isSampleNormal = (diffNormal.x + diffNormal.y) < 0.1f;
                float diffDepth = abs(centerDepth - sampleDepth) * _Sensitivity;
                int isSampleDepth = diffDepth < 0.1f * centerDepth;

                return isSampleNormal * isSampleDepth ? 1 : 0;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 color = tex2D(_MainTex, i.uv[0]).rgb;
                half4 sample1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
                half4 sample2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
                half4 sample3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
                half4 sample4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);

                half edge = 1;

                edge *= CheckSame(sample1, sample2);
                edge *= CheckSame(sample3, sample4);

                fixed4 strokeColor = lerp(_StrokeColor, tex2D(_MainTex, i.uv[0]), edge);
                fixed4 strokeOnlyColor = lerp(_StrokeColor, fixed4(1,1,1,1), edge);
                return lerp(strokeColor, strokeOnlyColor, _StrokeOnly);
            }
            ENDCG
        }
    }
}
