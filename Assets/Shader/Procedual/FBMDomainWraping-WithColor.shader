Shader "MyShader/Procedual/FBM Domain Wraping with Color"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Iteration ("Iteration", Range(1, 8)) = 1
        _AmplitudeScale ("Amplitude Scale", Range(0, 1)) = 0.5
        _Color1("Color 1", Color) = (1,1,1,1)
        _Color2("Color 2", Color) = (1,1,1,1)
        _Color3("Color 3", Color) = (1,1,1,1)
        _Color4("Color 4", Color) = (1,1,1,1)
        _Color5("Color 5", Color) = (1,1,1,1)
        _Color6("Color 6", Color) = (1,1,1,1)
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

            float4 _Color1;
            float4 _Color2;
            float4 _Color3;
            float4 _Color4;
            float4 _Color5;
            float4 _Color6;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 p = i.uv;
                
                float q = fbm(p + sin(fbm(p) + 0.05 * _Time.y));

                float3 color = lerp(_Color2, _Color1, q + 1);

                q = fbm(p + cos(q + 0.05 * _Time.y));

                color = lerp(color, _Color3, q);

                q = fbm(p + q);

                color = lerp(color, _Color4, q);

                q = fbm(p + sin(q + 0.1 * _Time.y));

                color = lerp(color, _Color5, q);

                q = fbm(p + q);

                color = lerp(color, _Color6, q);

                //float value = fbm(p + fbm(p + fbm(p)));

                fixed4 col = fixed4(color , 1);
                return col;
            }
            ENDCG
        }
    }
}
