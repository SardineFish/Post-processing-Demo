Shader "MyShader/Postprocess/Wave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
                float t = _Time.y;
                float h = 
                    sin(dot(i.uv, float2(1, 0)) * 37 + 7 * t)
                  + sin(dot(i.uv, float2(1, 0.1)) * 17 + 5 * t)
                  + sin(dot(i.uv, float2(1, .3)) * 23 + 3 * t);
                  + sin(dot(i.uv, float2(1, .57)) * 16 + 11 * t);
                return fixed4(h.xxx, 1);
            }
            ENDCG
        }
    }
}
