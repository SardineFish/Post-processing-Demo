Shader "MyShader/Procedual/Wave" {
    Properties {
    }

    SubShader {
        Tags {
            "Queue"="Transparent"
            "RenderType"="Opaque"
        }

        GrabPass { "_ScreenTex" }

        Pass{
            CGPROGRAM

            #include "UnityCG.cginc"
            
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _ScreenTex;
            float4 _ScreenTex_TexelSize;

            struct v2f {
                float4 vert: SV_POSITION;
                float4 screenPos: TEXCOORD0;
            };

            v2f vert(appdata_base v) {
                v2f o;
                o.vert = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeGrabScreenPos(o.vert);
                return o;
            }

            fixed4 frag(v2f i): SV_TARGET {
                float4 color = tex2D(_ScreenTex, i.screenPos.xy / i.screenPos.w);
                return fixed4(color);
            }

            ENDCG
        }
    }
}