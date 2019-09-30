Shader "MyShader/Postprocess/MotionBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Scale ("Scale", Float) = 1
        _Iteration ("Iteration", Int) = 3
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

            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            sampler2D _CameraMotionVectorsTexture;
            float _Scale;
            int _Iteration;

            fixed4 frag (v2f i) : SV_Target
            {
                float3 color = tex2D(_MainTex, i.uv).rgb;
                float2 motionVector = tex2D(_CameraMotionVectorsTexture, i.uv);
                float3 c;
                for(int it=0;it<_Iteration;it++)
                {
                    c += tex2D(_MainTex, i.uv + (_MainTex_TexelSize.xy * motionVector * it * _Scale));
                }
                c /= (int)_Iteration;
                
                return fixed4(c, 1);
            }
            ENDCG
        }
    }
}
