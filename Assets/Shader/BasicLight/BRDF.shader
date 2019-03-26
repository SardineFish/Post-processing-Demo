// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "MyShader/Texure/BRDF"{
	Properties{
		_Color("Color Tint", Color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white"{}
		_Normal ("Normal Textire", 2D) = "bump"{}
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(0, 1024)) = 20
		_Roughness("Roughness", Range(0,1)) = 0.5
	}
	SubShader{
		Pass{
			Tags {"LightMode"="ForwardBase"}

			
			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			#define PI 3.14159265358979323846264338327950288419716939937510

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Normal;
			float4 _Normal_ST;
			float4 _Specular;
			float _Gloss;
			float _Roughness;

			struct a2v{
				float4 vertex: POSITION;
				float3 normal: NORMAL;
				float4 texcoord: TEXCOORD0;
				float4 tangent: TANGENT;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float2 uv: TEXCOORD0;
				float3 worldPos: TEXCOORD1;
				float3 t2w0: TEXCOORD2;
				float3 t2w1: TEXCOORD3;
				float3 t2w2: TEXCOORD4;
				float2 v:TEXCOORD5;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent);
				float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
				o.t2w0 = float3(worldTangent.x, worldBinormal.x, worldNormal.x);
				o.t2w1 = float3(worldTangent.y, worldBinormal.y, worldNormal.y);
				o.t2w2 = float3(worldTangent.z, worldBinormal.z, worldNormal.z);
				o.v = v.vertex;
				return o;
			}

			inline float3 diffuse(float3 color, float roughness, float nl, float nv, float hl){
				float fd90 = 0.5 + 2 * roughness * pow(hl, 2);
				return (color / PI) * (1 + (fd90 - 1) * pow(1 - nl, 5)) * (1 + (fd90 - 1) * pow(1 - nv, 5));
			}

			inline float3 diffuseLambert(float3 color){
				return color / PI;
			}

			inline float3 schlick(float3 color, float hl){
				return color + (1 - color) * pow(1 - hl, 5);
			}

			inline float3 blinnNormalDistr(float roughness, float nh){
				float alpha = pow(roughness, 2);
				return 1 / (PI * pow(alpha, 2)) * pow(nh, 2 / pow(alpha, 2) - 2);
			}

			inline float3 smithBlinn(float3 roughness, float nv){
				float alpha = pow(roughness, 2);
				float c = nv / (alpha * sqrt(1 - pow(nv, 2)));
				if (c < 1.6)
					return (3.535 * c + 2.181 * pow(c, 2)) / (1 + 2.276 * c + 2.577 * pow(c, 2));
				else 
					return 1;
			}

			inline float3 normalDistrGGX(float roughness, float nh){
				float alpha = pow(roughness, 2);
				//float d = (nh * alpha - nh) * nh + 1.0f;
				return /*alpha / PI / (d * d + 1e-7f);*/ pow(alpha, 2) / (PI * pow(pow(nh, 2) * (pow(alpha, 2) - 1) + 1, 2));
			}

			inline float3 smithGGX(float roughness, float nv){
				float alpha = pow(roughness, 2);
				return 2 / (nv + sqrt(pow(alpha, 2) + (1 - pow(alpha, 2)) * pow(nv, 2)));
			}

			inline float3 smithSchlickBackmann(float roughness, float nv){
				float alpha = pow(roughness, 2);
				float k = alpha * sqrt(2 / PI);
				k = alpha / 2;
				return 1 / (nv * (1 - k) + k);
			}

			inline float3 geometricShadow(float roughness, float nl, float nv){
				float alpha = pow(roughness, 2);
				float lambdaV = 1*(nv*(1-alpha) + alpha);
				float lambdaL = 1 * (nl * (1 - alpha) + alpha);
				//return 0.5f / (lambdaL + lambdaV + 1e-5f);
				return smithGGX(roughness, nl) * smithGGX(roughness, nv);
				//return smithSchlickBackmann(roughness, nl) * smithSchlickBackmann(roughness, nv);

			}

			inline float blinn(float roughness, float nh){
				float alpha = pow(roughness, 2);
				float a = 2 / pow(alpha, 2) - 2;
				return pow(max(0, nh), a);
			}

			inline float3 disney(float3 baseColor, float roughness, float hl, float nl, float nv){
				float fd90 = 0.5 + 2 * pow(hl, 2) * roughness;
				return  baseColor / PI * (1 + (fd90 - 1) * pow(1 - nl, 5)) * (1 + (fd90 - 1) * pow(1 - nv, 5)); 
			}

			inline half3 CustomDisneyDiffuseTerm(half NdotV, half NdotL, half LdotH, half roughness, half3 baseColor) {
				half fd90 = 0.5 + 2 * LdotH * LdotH * roughness;
				// Two schlick fresnel term
				half lightScatter = (1 + (fd90 - 1) * pow(1 - NdotL, 5));
				half viewScatter = (1 + (fd90 - 1) * pow(1 - NdotV, 5));
				return baseColor * UNITY_INV_PI * lightScatter * viewScatter;
			}

			inline half3 diffuseOrenNayar(float3 albedo, float sigma, float vl, float nl, float nv){
				float sigma_2 = pow(sigma, 2);
				float A = 1 - 0.5 * sigma_2 / (sigma_2 + 0.33);
				float B = 0.45 * sigma_2 / (sigma_2 + 0.09);
				//float alpha = 
				return 0;//albedo / PI * 
			}

			fixed4 frag(v2f i):SV_TARGET{
				
				float roughness = _Roughness;
				float3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;
				fixed4 packNormal = tex2D(_Normal, i.uv);

				float3 normal = UnpackNormal(packNormal);
				normal = normalize(float3(dot(normal, i.t2w0.xyz), dot(normal, i.t2w1.xyz), dot(normal, i.t2w2.xyz)));
				float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				float3 reflectDir = reflect(-viewDir, normal);
			
				float3 spacularColor = _LightColor0.rgb * _Specular.rgb;

				float3 halfDir = normalize(lightDir + viewDir);
				float nv = saturate(dot(normal, viewDir));
				float nl = saturate(dot(normal, lightDir));
				float nh = saturate(dot(normal, halfDir));
				float lv = saturate(dot(lightDir, viewDir));
				float hl = saturate(dot(halfDir, lightDir));


				float3 diffuseTerm = diffuseLambert(albedo.rgb) * PI * _LightColor0.rgb * nl;
				float3 specularTerm = schlick(_Specular.rgb, hl) * geometricShadow(roughness, nl, nv) * normalDistrGGX(roughness, nh) / 4;
				float3 color = specularTerm;//  ambient + saturate(diffuseTerm + specularTerm) * _LightColor0.rgb * PI * nl;
				return fixed4(color , 1.0);
			}

			ENDCG
		}

	}
}