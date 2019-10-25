Shader "MyShader/Procedual/FBM Domain Wraping"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Iteration ("Iteration", Range(1, 8)) = 1
        _AmplitudeScale ("Amplitude Scale", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "PreviewType"="Plane" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            int _Iteration;
            float _AmplitudeScale;

            inline float noise(float2 pos)
            {
                // [0, 1] -> [-1, 1]
                return tex2D(_MainTex, pos.xy).r * 2 - 1;
            }

            inline float fbm(float2 uv)
            {
                float value = 0;
                float amplitude = _AmplitudeScale;
                float frequency = 0;
                
                for(int i = 0; i < _Iteration; i++)
                {
                    value += amplitude * noise(uv);
                    uv *= 2;
                    amplitude *= .5;
                }
                return value;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 p = i.uv;

                float value = fbm(p + fbm(p + fbm(p)));

                fixed4 col = fixed4(value.rrr + .5 , 1);
                return col;
            }
            ENDCG
        }
    }
}
