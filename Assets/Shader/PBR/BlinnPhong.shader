Shader "MyShader/PBR/Blinn-Phong"{
	Properties{
		_Color("Color Tint", Color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white"{}
		_Normal ("Normal Textire", 2D) = "bump"{}
		_Specular("Specular", Color) = (1, 1, 1, 1)
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

            inline float3 diffuseLambert(float3 albedo){
                return albedo / PI;
            }

			inline float3 disney(float3 baseColor, float roughness, float hl, float nl, float nv){
				float fd90 = 0.5 + 2 * pow(hl, 2) * roughness;
				return  baseColor / PI * (1 + (fd90 - 1) * pow(1 - nl, 5)) * (1 + (fd90 - 1) * pow(1 - nv, 5)); 
			}

			// --------- Specular ---------

			inline float3 schlick(float3 color, float hl){
				return color + (1 - color) * pow(1 - hl, 5);
			}

			inline float3 blinnNormalDistr(float roughness, float nh){
				float alpha = pow(roughness, 2);
				return 1 / (PI * pow(alpha, 2)) * pow(nh, 2 / pow(alpha, 2) - 2);
			}

			inline float3 smithBlinn(float3 roughness, float nv){
				float alpha = pow(roughness, 2);
				float c = 1 / (alpha * sqrt(1 - pow(nv, 2)));
				if (c < 1.6)
					return (3.535 * c + 2.181 * pow(c, 2)) / (1 + 2.276 * c + 2.577 * pow(c, 2));
				else 
					return 1;
			}

            inline float3 specularBlinnPhong(float3 albedo, float roughness, float nh, float nl, float nv, float hl){
				float3 F = schlick(albedo, hl);
				float3 D = blinnNormalDistr(roughness, nh);
				float3 G = smithBlinn(roughness, nl) * smithBlinn(roughness, nv);
				return F * D * G / 4;
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
			
				float3 spacularColor = _Specular.rgb;

				float3 halfDir = normalize(lightDir + viewDir);
				float nv = saturate(dot(normal, viewDir));
				float nl = saturate(dot(normal, lightDir));
				float nh = saturate(dot(normal, halfDir));
				float lv = saturate(dot(lightDir, viewDir));
				float hl = saturate(dot(halfDir, lightDir));


				float3 diffuseTerm = disney(albedo.rgb, roughness, hl, nl, nv) * PI * _LightColor0.rgb * nl;
				float3 specularTerm = specularBlinnPhong(albedo, roughness, nh, nl, nv, hl) * PI * _LightColor0.rgb * spacularColor * nl;
				float3 color = specularTerm + diffuseTerm + ambient;
				return fixed4(color , 1.0);
			}

			ENDCG
		}

	}
	Fallback "VertexLit"
}