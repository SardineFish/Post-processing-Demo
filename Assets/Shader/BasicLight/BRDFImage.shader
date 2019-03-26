// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "MyShader/Texure/BRDF Image"{
	Properties{
		_Color("Color Tint", Color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white"{}
		_Normal ("Normal Textire", 2D) = "bump"{}
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(0, 1024)) = 20
		_Roughness("Roughness", Range(0,1)) = 0.5
		_PhiD("Theta D", Range(0, 90)) = 0
	}
	SubShader{
		Pass{
			Tags {"LightMode"="ForwardBase"}

			
			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#pragma enable_d3d11_debug_symbols

			#define PI 3.14159265358979323846264338327950288419716939937510

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Normal;
			float4 _Normal_ST;
			float4 _Specular;
			float _Gloss;
			float _Roughness;
			float _PhiD;

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

			inline float3 diffuse(float3 color, float roughness, float nl, float nv, float hl){
				float fd90 = 0.5 + 2 * roughness * pow(hl, 2);
				return (color / PI) * (1 + (fd90 - 1) * pow(1 - nl, 5)) * (1 + (fd90 - 1) * pow(1 - nv, 5));
			}

			inline float3 diffuseLambert(float3 color){
				return color / PI;
			}

			inline float3 schlick(float3 color, float vh){
				return color + (1 - color) * pow(1 - vh, 5);
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
				return /*alpha / PI / (d * d + 1e-7f);*/ pow(alpha, 2) / (PI * pow(pow(nh, 2) * (pow(alpha, 2) - 1) + 1, 2) + 1e-7f);
			}

			inline float3 smithGGX(float roughness, float nv){
				float alpha = pow(roughness, 2);
				return 2 / (nv + sqrt(pow(alpha, 2) + (1 - pow(alpha, 2)) * pow(nv, 2)));
			}

			inline float3 geometricShadow(float3 roughness, float nl, float nv){
				float alpha = pow(roughness, 2);
				float lambdaV = nl*(nv*(1-alpha) + alpha);
				float lambdaL = nv * (nl * (1 - alpha) + alpha);
				return smithGGX(roughness, nl) * smithGGX(roughness, nv);
			}

			inline float blinn(float roughness, float nh, float nv, float nl, float vh){
				float alpha = pow(roughness, 2);
				float a = 2 / pow(alpha, 2) - 2;
				// return pow(saturate(nh), a);
				float x = acos(nh) * a;
    			float D = exp( -x*x);
    			float G = (nv < nl) ? 
    			    ((2*nv*nh < vh) ?
    			     2*nh / vh :
    			     1.0 / nv)
    			    :
    			    ((2*nl*nh < vh) ?
    			     2*nh*nl / (vh*nv) :
    			     1.0 / nv);
				return nh < 0 ? 0 : D * G;
			}

			inline float3 disney(float3 baseColor, float roughness, float hl, float nl, float nv){
				float fd90 = 0.5 + 2 * pow(hl, 2) * roughness;
				return  baseColor / PI * (1 + (fd90 - 1) * pow(1 - nl, 5)) * (1 + (fd90 - 1) * pow(1 - nv, 5)); 
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

			inline float3 rotateVector(float4 q, float3 v){
				float4 v4 = float4(v.x, v.y, v.z, 0);
				float4 tmp = quaternionMulti(q, v4);
				return normalize(quaternionMulti(tmp, reverseQuaternion(q)).xyz);
			}	

			fixed4 frag(v2f i):SV_TARGET{
				float roughness = _Roughness;
				float3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;

				float3 normal = normalize(float3(0,0,1));
				float3 tangent = normalize(float3(1,0,0));
			
				float3 spacularColor = _LightColor0.rgb * _Specular.rgb;

				float phi = (90 - _PhiD) / 180 * PI;
				float cosPhiD = cos(phi);
				float angPhiD = phi;

				float nh = cos((i.uv.x) * (PI / 2));
				float hlAng = i.uv.y * (PI / 2);

				float sinNH = sqrt(1 - pow(nh, 2));
				float3 halfDir = float3(saturate(sqrt(1 - pow(cosPhiD * sinNH, 2) - pow(nh, 2))), cosPhiD * sinNH, nh); // (sqrt(1 - cosPhiD^2 - nh^2), cosPhiD, nh)
				float3 rotateAxis = normalize(cross(normalize(float3(0, halfDir.y, halfDir.z)), tangent));
				float3 lightDir = rotateVector(quaternion(rotateAxis, hlAng), halfDir);
				float3 viewDir = rotateVector(quaternion(rotateAxis, -hlAng), halfDir);


				float vh = saturate(dot(viewDir, halfDir));
				float hl = saturate(dot(lightDir, halfDir));
				float nv = saturate(dot(normal, viewDir));
				float nl = saturate(dot(normal, lightDir));

				float3 diffuseTerm = diffuseLambert(albedo.rgb) * PI * _LightColor0.rgb * nl;
				float3 specularTerm = schlick(_Specular.rgb, vh) * geometricShadow(roughness, nl, nv) * normalDistrGGX(roughness, nh) / 4;
				float3 color = diffuseLambert(albedo.rgb);// ambient + saturate(diffuseTerm + specularTerm) * _LightColor0.rgb * PI * nl;
				return fixed4(color , 1.0);
			}

			ENDCG
		}

	}
}