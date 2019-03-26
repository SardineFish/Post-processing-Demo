// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "MyShader/Specular"
{
    Properties
    {
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
		_Specular ("Specular", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(0,2048)) = 64
        _MainTex ("Texture", 2D) = "white" {}
        _Roughness ("Roughness", Range(0,1)) = 0.5
	
    }
    SubShader
    {

        Pass
        {
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
		// make fog work
		#pragma multi_compile_fog

		#include "UnityCG.cginc"
		#include "Lighting.cginc"

            #define PI 3.14159265358979323846264338327950288419716939937510

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
				float4 worldPos : COLOR1;
				float4 color: COLOR;
				float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _Diffuse;
			float4 _Specular;
			float _Gloss;
            float _Roughness;

            v2f vert (appdata v)
            {
                v2f o;
				o.worldPos = mul(v.vertex, unity_ObjectToWorld);
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				float3 diffuse = _LightColor0.rgba * _Diffuse*saturate(dot(worldLight, i.normal));
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT;
				float3 reflectDir = normalize(reflect(-worldLight, i.normal));
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

                /*if(_Roughness < 1/0.02)
                    _Roughness = 1/0.02;*/
                float roughness = pow(_Roughness, 2);
                float alpha = 2 / pow(roughness, 2) - 2;
                float specular = 1 / (PI * pow(roughness, 2)) * pow(saturate(dot(reflectDir, viewDir)), alpha);
				float3 specularColor = _LightColor0.rgb * _Specular.rgb * specular;
                // sample the texture
				return fixed4(ambient + diffuse + specularColor, 1.0);
            }
            ENDCG
        }
    }
}
