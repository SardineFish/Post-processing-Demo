Shader "MyShader/PBR/BRDF Slice"{
	Properties{
		_PhiDiff("Phi Diff", Range(0, 180)) = 90
		_Diffuse("Diffuse Color", Color) = (1, 1, 1, 1)
		_Roughness("Roughness", Range(0, 1)) = 0.4
		_F0("F0", Range(0, 1)) = 0.02
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

            sampler3D _BRDF;
			float _PhiDiff;
			float4 _Diffuse;
			float _Roughness;
			float _F0;

			struct a2v{
				float4 vertex: POSITION;
				float4 texcoord: TEXCOORD0;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float2 uv: TEXCOORD0;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			// ------------- Utility -------------

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

			// ------------- Implement BRDF Here -------------

			inline float3 schlick(float f0, float hl){
				return f0 + (1 - f0) * pow(1 - hl, 5);
			}

			inline float3 normalDistrGGX(float roughness, float nh){
				float alpha_2 = pow(roughness, 4); // alpha = roughness^2
				return alpha_2 / (PI * pow(pow(nh, 2) * (alpha_2 - 1) + 1, 2));
			}

			inline float3 smithGGX(float roughness, float nv){
				float alpha_2 = pow(roughness, 4); // alpha = roughness^2
				return 2 / (nv + sqrt(alpha_2 + (1 - alpha_2) * pow(nv, 2)));
			}

            inline float3 specularGGX(float3 albedo, float roughness, float nh, float nl, float nv, float hl){
				float3 F = schlick(_F0, hl);
				float3 D = normalDistrGGX(roughness, nh);
				float3 G = smithGGX(roughness, nl) * smithGGX(roughness, nv);
				return max(0,  F * G * D / 4);
            }


			inline float3 disney(float3 baseColor, float roughness, float hl, float nl, float nv){
				float fd90 = 0.5 + 2 * pow(hl, 2) * roughness;
				return  baseColor / PI * (1 + (fd90 - 1) * pow(1 - nl, 5)) * (1 + (fd90 - 1) * pow(1 - nv, 5)); 
			}

			inline float3 brdf(float4 albedo, float3 normal, float3 lightDir, float3 viewDir, float3 halfDir)
			{
				float nv = saturate(dot(normal, viewDir));
				float nl = saturate(dot(normal, lightDir));
				float nh = saturate(dot(normal, halfDir));
				float lv = saturate(dot(lightDir, viewDir));
				float hl = saturate(dot(halfDir, lightDir));

				float3 diffuseTerm = disney(albedo.rgb, _Roughness, hl, nl, nv);
				float3 specularTerm = specularGGX(albedo, _Roughness, nh, nl, nv, hl);

				return diffuseTerm + specularTerm;
			}

			fixed4 frag(v2f i):SV_TARGET{
				float3 normal = float3(0, 1, 0);
				float3 tangent = float3(1, 0, 0);
				float3 binormal = float3(0, 0, 1);

                float thetaHalf = i.uv.x;
                float thetaDiff = i.uv.y;
                float phiDiff = _PhiDiff / 180;

				thetaHalf *= PI / 2;
				thetaDiff *= PI / 2;
				phiDiff *= PI;

				float3 halfDir = normalize(float3(sin(thetaHalf), cos(thetaHalf), 0));
				
				float3 lightDir = rotateVector(binormal, halfDir, thetaDiff);
				float3 viewDir = rotateVector(binormal, halfDir, -thetaDiff);
				lightDir = rotateVector(halfDir, lightDir, phiDiff);
				viewDir = rotateVector(halfDir, viewDir, phiDiff);

				
				float3 color = brdf(_Diffuse, normal, lightDir, viewDir, halfDir);
				
				return fixed4(color , 1.0);
			}

			ENDCG
		}

	}
	Fallback "VertexLit"
}