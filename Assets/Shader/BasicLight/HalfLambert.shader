// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "MyShader/HalfLambert"
{
    Properties
    {
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
		_Alpha ("Alpha", Range(0,1)) = 0.5
		_Beta ("Beta", Range(0,1)) = 0.5
    }
    SubShader
    {

        Pass
        {
			Tags{"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float4 normal: NORMAL;
				float4 color: COLOR0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float4 color: COLOR;
				float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _Diffuse;
			float _Alpha;
			float _Beta;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				float4 diffuse = _LightColor0.rgba * _Diffuse*(_Alpha*(dot(worldLight, i.normal) + _Beta));
				float4 ambient = UNITY_LIGHTMODEL_AMBIENT;
                // sample the texture
				return ambient + diffuse;
            }
            ENDCG
        }
    }
}
