// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "MyShader/Texure/TextureNormal"{
	Properties{
		_Color("Color Tint", Color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white"{}
		_Normal ("Normal Textire", 2D) = "bump"{}
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(0, 1024)) = 20
	}
	SubShader{
		Pass{
			Tags {"LightMode"="ForwardBase"}

			
			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Normal;
			float4 _Normal_ST;
			float4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertex: POSITION;
				float3 normal: NORMAL;
				float4 texcoord: TEXCOORD0;
				float4 tangent: TANGENT;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float2 uv: TEXCOORD0;
				float3 lightDir:TEXCOORD1;
				float3 viewDir:TEXCOORD2;
				float2 normalUV: TEXCOORD3;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.normalUV = TRANSFORM_TEX(v.texcoord, _Normal);

				float3 binomal = normalize(cross(v.normal, v.tangent));
				float3x3 obj2tan = float3x3(normalize(v.tangent).xyz, binomal, normalize(v.normal));
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.lightDir = mul(obj2tan, ObjSpaceLightDir(v.vertex));
				o.viewDir = mul(obj2tan, ObjSpaceViewDir(v.vertex));
				return o;
			}

fixed4 frag(v2f i):SV_TARGET{
	float3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
	float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;
	fixed4 packNormal = tex2D(_Normal, i.normalUV);
	float3 normal = UnpackNormal(packNormal);
	float3 lightDir = normalize(i.lightDir);
	float3 viewDir = normalize(i.viewDir);
	// Compute diffuse term
	float3 diffuse = _LightColor0.rgb*albedo.rgb*max(0, dot(normal, i.lightDir));
	// Get the half direction in world space
	float3 halfDir = normalize(lightDir + viewDir);
	// Compute specular term 
	float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(normal, halfDir)), _Gloss);
	return fixed4(ambient + diffuse + specular, 1.0);
}
			ENDCG
		}

	}
}