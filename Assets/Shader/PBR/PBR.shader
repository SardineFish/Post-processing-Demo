Shader "MyShader/PBR/BRDF"{
	Properties{
		_Color("Color Tint", Color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white"{}
		_Normal ("Normal Textire", 2D) = "bump"{}
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Roughness("Roughness", Range(0,1)) = 0.5
	}
	SubShader{
		Tags {
            "RenderType"="Opaque"
        }
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

            inline float3 specularBlinnPhong(float roughness, float nh){
				float alpha_2 = pow(roughness, 4);
				float a = 2 / alpha_2 - 2;
				return 1 / (PI * alpha_2) * pow(nh, a);
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


				float3 diffuseTerm = diffuseLambert(albedo.rgb) * PI * _LightColor0.rgb * nl;
				float3 specularTerm = specularBlinnPhong(roughness, nh) * PI * _LightColor0.rgb * spacularColor * nl;
				float3 color = specularTerm + specularTerm;
				return fixed4(color , 1.0);
			}

			ENDCG
		}

	}
	Fallback "VertexLit"
}