Shader "MyShader/PBR/MERL"{
	Properties{
        _BRDF("BRDF", 3D) = "white"{}
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
            sampler3D _BRDF;

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

			inline float4 quaternion(float3 axis, float angle)
			{
				axis = normalize(axis);
				float halfAngle = angle / 2;
				return normalize(float4(axis.x * sin(halfAngle), axis.y * sin(halfAngle), axis.z * sin(halfAngle), cos(halfAngle)));
			}

			inline float4 reverseQuaternion(float4 q){
				return normalize(float4(-q.x, -q.y, -q.z, q.w));
			}

			inline float4 quaternionMulti(float4 q1, float4 q2){
				return float4(
					(q1.w * q2.x) + (q1.x * q2.w) + (q1.y * q2.z) - (q1.z * q2.y),
  					(q1.w * q2.y) - (q1.x * q2.z) + (q1.y * q2.w) + (q1.z * q2.x),
  					(q1.w * q2.z) + (q1.x * q2.y) - (q1.y * q2.x) + (q1.z * q2.w),
  					(q1.w * q2.w) - (q1.x * q2.x) - (q1.y * q2.y) - (q1.z * q2.z));
			}

			inline float3 rotateVector(float3 axis, float3 v, float angle){
				float4 q = quaternion(axis, angle);
				float4 v4 = float4(v.x, v.y, v.z, 0);
				float4 tmp = quaternionMulti(q, v4);
				return normalize(quaternionMulti(tmp, reverseQuaternion(q)).xyz);
			}

			fixed4 frag(v2f i):SV_TARGET{
				
				float roughness = _Roughness;
				float3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;
				fixed4 packNormal = tex2D(_Normal, i.uv);
				float3 normal = UnpackNormal(packNormal);
				float3 tangent = cross(float3(0,0,1), normal);
				normal = normalize(float3(dot(normal, i.t2w0.xyz), dot(normal, i.t2w1.xyz), dot(normal, i.t2w2.xyz)));
				tangent = normalize(float3(dot(tangent, i.t2w0.xyz), dot(tangent, i.t2w1.xyz), dot(tangent, i.t2w2.xyz)));
				float3 binormal = cross(normal, tangent);
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

                float thetaHalf = acos(nh);
                float thetaDiff = acos(hl);
                float phiDiff = 0;

                float3 u = -normalize(normal - dot(normal, halfDir) * halfDir);
                float3 v = normalize(cross(halfDir, u));
                phiDiff = atan2(dot(lightDir, v), dot(lightDir, u));
				
				if (thetaDiff < 1e-3) {
        			// phi_diff indeterminate, use phi_half instead
       				phiDiff = atan2(-dot(lightDir, binormal), dot(lightDir, tangent));
    			}
				else if (thetaHalf > 1e-3){
                	phiDiff = atan2(dot(lightDir, v), dot(lightDir, u));
				}
				else 
					thetaHalf = 0;

				float3 d = rotateVector(binormal, rotateVector(normal, lightDir, -thetaHalf), -phiDiff);
				//phiDiff = atan2(d.z, d.x);
				
				
				if(phiDiff < 0)
                    phiDiff += PI * 2;
				if(phiDiff > PI)
					phiDiff -= PI;
				
				//return fixed4(v,1) * 0.5 + 0.5;
				float t = phiDiff;// clamp(dot(lightDir, v), -1, 1) / clamp(dot(lightDir, u), 0, 1);
				//return pow(fixed4(t, t, t, 1),1) + 0.5;
                
                /*if(phiDiff > PI)
                    phiDiff -= PI;*/

                thetaHalf /= PI / 2;
                thetaDiff /= PI / 2;
                phiDiff /= PI;

				

				thetaHalf = pow(thetaHalf, 0.5);
				//return fixed4(phiDiff, phiDiff, phiDiff, 1);
                
                float3 brdf = tex3D(_BRDF,float3(thetaHalf, thetaDiff, phiDiff));
                brdf = pow(brdf, 1/2.2);

				float3 diffuseTerm = diffuseLambert(albedo.rgb) * PI * _LightColor0.rgb * nl;
				float3 specularTerm = specularBlinnPhong(roughness, nh) * PI * _LightColor0.rgb * spacularColor * nl;

                float3 color = brdf * PI * _LightColor0.rgb * nl + ambient;
				return fixed4(color , 1.0);
			}

			ENDCG
		}

	}
	Fallback "VertexLit"
}