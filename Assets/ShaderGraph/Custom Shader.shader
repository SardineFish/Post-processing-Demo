// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MAJIKA/Slot"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        [PerRendererData] _InnerShadow ("Inner Shadow", 2D) = "white" {}
        _Mask ("Mask", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
    }

    SubShader
    {
        Tags
        { 
            "Queue"="Transparent" 
            "IgnoreProjector"="True" 
            "RenderType"="Transparent" 
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Fog { Mode Off }
        Blend One OneMinusSrcAlpha

        Pass
        {
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile DUMMY PIXELSNAP_ON
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                half2 texcoord  : TEXCOORD0;
            };

            fixed4 _Color;
            

            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.color = IN.color;
                #ifdef PIXELSNAP_ON
                OUT.vertex = UnityPixelSnap (OUT.vertex);
                #endif

                return OUT;
            }

            sampler2D _MainTex;
            sampler2D _InnerShadow;
            sampler2D _Mask;

            inline fixed4 cover(fixed4 base, fixed4 blend)
            {
                return blend.a * blend + (1 - blend.a) * base;
            }

            #define OVERLAY(BASE, BLEND) BASE <= 0.5 ? 2 * BASE * BLEND : 1 - 2 * (1 - BASE) * (1 - BLEND) 

            inline fixed4 overlay(fixed4 base, fixed4 blend)
            {
                return fixed4(OVERLAY(base.r, blend.r), OVERLAY(base.g, blend.g), OVERLAY(base.b, blend.b), base.a);
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                fixed4 c = fixed4(cover(overlay(tex2D(_InnerShadow, IN.texcoord) * IN.color, _Color), tex2D(_MainTex, IN.texcoord)).rgb, IN.color.a) * tex2D(_Mask, IN.texcoord);
                c.rgb *= c.a;
                return c;
            }
        ENDCG
        }
    }
}