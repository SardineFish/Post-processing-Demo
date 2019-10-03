Shader "MyShader/Postprocess/InfiniteGround"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Texture ("Texture", 2D) = "white" {}   
        _UVOffset ("UV Offset", Vector) = (0,0,0,0)
        _UVScale ("UV Scale", Float) = 1
        _ReflectTex ("Reflection Texture", Cube) = "_Skybox" {}
        _WaveScale ("Wave Scale", Float) = 1
        _WaveSpeed ("Wave Speed", Float) = 1
        _WaveStrength ("Wave Strength", Float) = 1
        _P ("P", Float) = 1
        _F0 ("F0", Range(0, 1)) = 0.16
        _ReflectFog ("Reflect Fog", Color) = (1, 1, 1, 1)
        _RefractFog ("Refract Fog", Color) = (1, 1, 1, 1)
        _DiffuseColor ("Diffuse Color", Color) = (1, 1, 1, 1)
        _RefractStrength ("Refract Strength", Float) = 1
        _SubsurfaceDistortion("Subsurface Distortion", Range(0, 1)) = 1
        _SubsurfaceScale("Subsurface Scale", Range(0, 1)) = 1
        _SubsurfacePower("Subsurface Power", Float) = 5

    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

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

            float4x4 _ViewProjectionInverseMatrix;
            float3 _CameraPos;
            float3 _CameraClipPlane; // (near, far, near - far)
            float _UVScale;
            float2 _UVOffset;
            float _Height;
            float _WaveScale;
            float _WaveSpeed;
            float _WaveStrength;
            float _P;
            float _F0;
            float4 _DiffuseColor;
            float4 _ReflectFog;
            float4 _RefractFog;
            float _RefractStrength;
            float _SubsurfaceDistortion;
            float _SubsurfacePower;
            float _SubsurfaceScale;

            sampler2D _Texture;
            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            sampler2D _CameraDepthTexture;
            samplerCUBE _ReflectTex;
            sampler2D _ScreenSpaceShadow;

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

            inline float3 getWorldPos(float depth, float3 ray)
            {
                return (_CameraPos + LinearEyeDepth(depth) * ray.xyz);
            }

            inline float wave(float2 pos)
            {
                float t = _Time.y;
                return sin(dot(pos, float2(1, 0)) * 37 + 7 * t)
                  + sin(dot(pos, float2(1, 0.1)) * 17 + 5 * t)
                  + sin(dot(pos, float2(1, .3)) * 23 + 3 * t);
                  + sin(dot(pos, float2(1, .57)) * 16 + 11 * t);
            }

            inline float3 waveNormal(float2 pos, float dist)
            {
                float omega[4] = {37, 17, 23, 16};
                float phi[4] = {7, 5, 3, 11};
                float2 dir[4] = {
                    float2(1, 0),
                    float2(1, 0.1),
                    float2(1, 0.3),
                    float2(1, 0.57)
                };
                float t = _Time.y * _WaveSpeed;
                float3 normal = 0;
                for(int i=0;i<4;i++)
                {
                    omega[i] *= _WaveScale;
                    normal += float3(
                        omega[i] * dir[i].x * 1 * cos(dot(dir[i], pos) * omega[i] + t * phi[i]),
                        1,
                        omega[i] * dir[i].y * 1 * cos(dot(dir[i], pos) * omega[i] + t * phi[i])
                    );
                }
                normal.xz = normal.xz * _WaveStrength * exp(-1 / _P * dist);
                return normalize(normal);
            }

            inline float3 fresnelFunc(float f0, float nv, float p) {
				return f0 + (1 - f0) * pow(1 - nv, p);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float depth01 = Linear01Depth(tex2D(_CameraDepthTexture, i.uv).r);
                float depth = tex2D(_CameraDepthTexture, i.uv).r;
                float3 worldPos = getWorldPos(depth, i.ray);
                float3 ray = worldPos - _CameraPos;
                float t = (_Height - _CameraPos.y) / ray.y;

                if(0 < t && t < 1 || depth01 >= 1 && t > 0)
                {
                    float3 groundPos = _CameraPos + ray * t;
                    float3 viewDir = normalize(_CameraPos - groundPos);
                    float2 uv = groundPos.xz;
                    float3 normal = waveNormal(uv, length(groundPos - _CameraPos));
                    float3 reflectDir = reflect(ray, normal);
                    float3 lightDir = normalize(UnityWorldSpaceLightDir(groundPos));

                    // Reflection
                    float3 reflection = texCUBElod(_ReflectTex, float4(reflectDir, 0)).rgb;
                    reflection = _ReflectFog.rgb * _ReflectFog.a + reflection.rgb * (1 - _ReflectFog.a);

                    // Refraction
                    float depth = length(worldPos - groundPos);
                    float density = 1 / 1 - pow(_RefractFog.a, 0.5f) + 0.00001f;
                    float f = 1 - exp(-pow(density * abs(depth), 1));
                    float3 color = tex2D(_MainTex, i.uv + normal.xz * _RefractStrength * _MainTex_TexelSize.xy);
                    color = _RefractFog.rgb * f + color * (1 - f);
                    
                    // Diffuse
                    float3 diffuse = _DiffuseColor.rgb * saturate(dot(normal, lightDir)) * _LightColor0.rgb;
                    // Subsurface 
                    float3 lightBack = pow(saturate(dot(viewDir, -normalize(lightDir + normal * _SubsurfaceDistortion))), _SubsurfacePower) * _SubsurfaceScale;
                    lightBack = lightBack * _LightColor0.rgb * _RefractFog.rgb;

                    // Shadow
                    float shadow = tex2D(_ScreenSpaceShadow, i.uv);

                    float fresnel = fresnelFunc(_F0, dot(normal, viewDir), 5);

                    uv = uv*_UVScale + _UVOffset.xy;
                    // color = wave(uv); //tex2D(_Texture, uv);
                    color = reflection * fresnel + (1-fresnel) * ((color) + (lightBack + diffuse) * shadow);
                    return fixed4(color, 1);
                }
                else
                {
                    float3 color = 1 * tex2D(_MainTex, i.uv).rgb;
                    return fixed4(color, 1);
                }
            }
            ENDCG
        }
    }
}
