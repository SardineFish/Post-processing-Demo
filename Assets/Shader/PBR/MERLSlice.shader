Shader "MyShader/PBR/MERL Slice"{
	Properties{
        _BRDF("BRDF", 3D) = "white"{}
		_PhiDiff("Phi Diff", Range(0, 180)) = 90
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

			struct a2v{
				float4 vertex: POSITION;
				float3 normal: NORMAL;
				float4 tangent: TANGENT;
				float4 texcoord: TEXCOORD0;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float2 uv: TEXCOORD0;
				float3 worldPos: TEXCOORD1;
				float2 v:TEXCOORD5;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.v = v.vertex;
				return o;
			}

			fixed4 frag(v2f i):SV_TARGET{
                float thetaHalf = i.uv.x;
                float thetaDiff = i.uv.y;
                float phiDiff = _PhiDiff / 180;

				thetaHalf = pow(thetaHalf, 0.5);
                
                float3 brdf = tex3D(_BRDF,float3(thetaHalf, thetaDiff, phiDiff));
                brdf = pow(brdf, 1/2.2);
                float3 color = brdf;
				return fixed4(color , 1.0);
			}

			ENDCG
		}

	}
	Fallback "VertexLit"
}