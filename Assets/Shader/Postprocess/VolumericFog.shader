Shader "MyShader/Postprocess/Volumeric"{
	Properties{
        _MainTex ("Texture", any) = "" {}
        _DepthTex ("Texture", any) = "" {}
        _Color("Multiplicative color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader{
		Tags {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
        }

		Pass {
            ZWrite On
            Blend One Zero
            Cull Off
            ZTest On
			
			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			#define PI 3.14159265358979323846264338327950288419716939937510
            
            float3 _CameraPos;
            sampler2D _DepthTex;

			struct a2v{
				float4 vertex: POSITION;
                float3 normal: NORMAL;
                float3 color: COLOR;
			};
			struct v2f {
				float4 pos:SV_POSITION;
                float3 color: COLOR;
                float3 normal: NORMAL;
                float3 worldPos: TEXCOORD0;
                float3 screenPos : TEXCOORD1;
			};
            struct FragmentOutput {
                fixed4 dest0 : SV_TARGET0;
                float dest1 : SV_TARGET1;
            };

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = v.normal;
                o.screenPos = ComputeScreenPos(o.pos);
                o.color = v.color;
				return o;
			}

			FragmentOutput frag(v2f i) : SV_TARGET
            {
                FragmentOutput output;
                float3 color = i.color;
                float3 normal = normalize(i.normal);
                float3 viewDir = normalize(_CameraPos - i.worldPos);
                float n = step(0, dot(viewDir, normal));

                output.dest0 = fixed4(color, 1);
                output.dest1 = i.pos.z;
				return output;
			}

			ENDCG
		}

        // #1 Back only rendering
        Pass {
            ZWrite On
            Blend One Zero
            Cull Front
            ZTest On
			
			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			#define PI 3.14159265358979323846264338327950288419716939937510
            
            float3 _CameraPos;
            sampler2D _DepthTex;

			struct a2v{
				float4 vertex: POSITION;
                float3 normal: NORMAL;
                float3 color: COLOR;
			};
			struct v2f {
				float4 pos:SV_POSITION;
                float3 color: COLOR;
                float3 normal: NORMAL;
                float3 worldPos: TEXCOORD0;
                float3 screenPos : TEXCOORD1;
			};
            struct FragmentOutput {
                fixed4 dest0 : SV_TARGET0;
                float dest1 : SV_TARGET1;
            };

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = v.normal;
                o.screenPos = ComputeScreenPos(o.pos);
                o.color = v.color;
				return o;
			}

			FragmentOutput frag(v2f i) : SV_TARGET
            {
                FragmentOutput output;
                float3 color = i.color;
                float3 normal = normalize(i.normal);
                float3 viewDir = normalize(_CameraPos - i.worldPos);
                float n = step(0, dot(viewDir, normal));

                output.dest0 = fixed4(1, 0, 0, 1);
                output.dest1 = i.pos.z;
				return output;
			}

			ENDCG
		}
        
        // #2 Blit with DepthBuffer
        Pass {
            ZTest Always Cull Off ZWrite On 

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            UNITY_DECLARE_DEPTH_TEXTURE(_DepthTex);

            uniform float4 _MainTex_ST;
            uniform float4 _Color;

            
            struct appdata_t {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                return o;
            }

            fixed4 frag(v2f i, out float oDepth : SV_DEPTH) : SV_Target
            {
                oDepth = SAMPLE_RAW_DEPTH_TEXTURE(_DepthTex, i.texcoord);
                return fixed4(0, 0, 0, 1);
            }
            ENDCG
        }

        // #2 Atmospheric scattering with volumn shadow
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            #define PI (3.14159265358979323846264338327950288419716939937510)

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 screenWorldPos: TEXCOORD1;
                float3 ray: TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            sampler2D _VolumericDepthMap;
            sampler2D _VolumericLightMap;

            float4x4 _ViewProjectionInverseMatrix;
            float3 _CameraPos;
            float3 _ViewRange; // (near, far, near - far)
            float3 _CameraClipPlane; // (near, far, near - far)
            float3 _FogColor;
            float _Density;
            float _FogScale;
            float _ScatterFactor;
            float _ScatterIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                float4 p = float4(o.vertex.x, o.vertex.y, -1, 1);
                p = p * _CameraClipPlane.x;
                o.screenWorldPos = mul(_ViewProjectionInverseMatrix, p);
                o.ray = o.screenWorldPos - _CameraPos;
                o.ray = normalize(o.ray) * (length(o.ray) / _CameraClipPlane.x);
                return o;
            }

            #define FOG(FOG_COLOR, ORIGIN_COLOR, F) (FOG_COLOR * F + (1 - F) * ORIGIN_COLOR)

            inline float3 getWorldPos(float depth, float3 ray)
            {
                return (_CameraPos + LinearEyeDepth(depth) * ray.xyz);
            }

            inline float phase(float vl)
            {
                return 1 / (4*PI) * (1 - pow(_ScatterFactor, 2)) / pow(1 + pow(_ScatterFactor, 2) - 2 * _ScatterFactor * vl, 3/2);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float d = _Density;
                float3 color = 1 * tex2D(_MainTex, i.uv).rgb;
                float depth = tex2D(_CameraDepthTexture, i.uv).r;
                float3 volumeMask = tex2D(_VolumericLightMap, i.uv);
                float volumeDepth = tex2D(_VolumericDepthMap, i.uv).r;

                float3 volumePos = getWorldPos(volumeDepth, i.ray);
                float3 worldPos = getWorldPos(depth, i.ray);
                float3 ray = worldPos - _CameraPos;
                float3 viewDir = normalize(-ray);
                float3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                float t = (0 - _CameraPos.y) / ray.y;
                if(0 < t && t < 1)
                {
                    float3 waterPos = _CameraPos + ray * t;
                    if(distance(_CameraPos, waterPos) < distance(_CameraPos, worldPos))
                        worldPos = waterPos;
                }
                if(distance(_CameraPos, worldPos) < distance(_CameraPos, volumePos))
                {
                    volumePos = worldPos;
                    volumeMask = float3(0,0,1);
                }

                
                float z = saturate((length(volumePos - _CameraPos) - _ViewRange.x) / _ViewRange.z);
                float f = (abs(z) - _ViewRange.x) / (_ViewRange.y - _ViewRange.x);
                f = 1 - exp(-pow(d * abs(z), 1));
                f *= _FogScale;
                
                float3 scatterLight = _LightColor0.rgb * phase(dot(lightDir, viewDir));
                scatterLight = FOG(scatterLight, float3(0,0,0), f);
                scatterLight = scatterLight * _ScatterIntensity;
                scatterLight = 0 * volumeMask.r + scatterLight * volumeMask.g + scatterLight * volumeMask.b;

                //scatterLight = scatterLight * (1 - volumeMask);
                return fixed4 (color + scatterLight, 1);
            }
            ENDCG
        }
	}
}