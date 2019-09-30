Shader "MyShader/Expert/Mirror" {
    Properties {
        _MainTex("Texture", 2D) = "white" {}
    }

    SubShader {

        Tags { "RenderType"="Opaque" }

        Pass {
            CGPROGRAM

            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;

            struct v2f {
                float4 vert: SV_POSITION;
                float2 uv: TEXCOORD0;
            };

            v2f vert(appdata_base v) {
                v2f o;
                o.vert = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET {
                float4 color = tex2D(_MainTex, i.uv);
                return fixed4(color);
            }


            ENDCG
        }
    }
}