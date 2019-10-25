Shader "MyShader/Procedual/RayMarching"
{
    Properties
    {
        _RayHitBias("Ray Hit Bias", Float) = 0.1
        _TerrainScale("Terrain Scale", Float) = 1
        _HeightScale("Terrain Height Scale", Float) = 1
        _Color ("Terrain Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
    }

    CGINCLUDE

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

    float4x4 _WorldProjection;
    float4x4 _ViewProjectionInverseMatrix;
    float3 _CameraPos;
    float3 _CameraClipPlane; // (near, far, near - far)
    float2 _PixelAngle; // Tangent of angle-of-view with one pixel height in world space (tan, 1/tan)

    float4 _Color;
    sampler2D _MainTex;

    Texture2D _TerrainTex;
    SamplerState terrain_linear_repeat_sampler;
    float4 _TerrainTex_TexelSize;
    float _TerrainScale;
    float _HeightScale;

    float _RayHitBias;

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

    float terrain(float2 pos)
    {
        pos /= _TerrainScale;
        float height = _TerrainTex.Sample(terrain_linear_repeat_sampler, pos).r;
        height = 1 - height;
        height *= _HeightScale;
        return height;
    }

    float3 terrainNormal(float2 pos)
    {
        float2 delta = _TerrainTex_TexelSize.xy * _TerrainScale;
        float centerHeight = terrain(pos);
        float2 dy = float2(terrain(pos + delta * float2(1, 0)), terrain(pos + delta * float2(0, 1)));
        dy -= centerHeight.xx;
        dy /= delta.xy;
        return normalize(float3(dy.x, 1, dy.y));
    }

    inline float3 diffuseLambert(float3 albedo){
        return albedo / PI;
    }

    float3 terrainColor(float2 pos, float3 ray)
    {
        float height = terrain(pos);
        float3 normal = terrainNormal(pos);

        float3 albedo = _Color.rgb;
        float3 ambient = unity_AmbientSky.rgb * albedo.rgb;
        float3 light = _LightColor0.rgb;

        float3 viewDir = normalize(-ray);
        float3 lightDir = normalize(UnityWorldSpaceLightDir(float3(pos.x, height, pos.y)));

        float nl = saturate(dot(normal, lightDir));

        float3 diffuse = diffuseLambert(albedo.rgb) * light * nl + ambient;

        return diffuse;
    }

    float sdf_sphere(float3 pos)
    {
        float3 center = float3(0,0,0);
        float r = 5;
        return distance(center, pos) - r;
    }

    struct fragOutput
    {
        float4 color : SV_TARGET0;
        float depth : SV_TARGET1;
    };

    float3 rayMarching(float3 startPos, float3 ray, out int hit)
    {
        float3 pos = startPos;
        float dist = 0;
        while (1)
        {
            float d = pos.y - terrain(pos.xz);
            if(d <= _PixelAngle.x * dist)
            {
                hit = 1;
                return pos + ray * d;
            }
            if(dist > _CameraClipPlane.y)
            {
                hit = 0;
                return startPos;
            }
            pos += ray * d;
            dist += d;
        }
    }

    fixed4 frag (v2f i, out float depthOut : SV_DEPTH) : SV_Target
    {
        float3 ray = normalize(i.ray);
        int hit;
        float3 pos = _CameraPos;
        float dist = 0;
        while (1)
        {
            float d = pos.y - terrain(pos.xz);
            if(d <= _PixelAngle.x * dist)
            {
                float4 projection = mul(_WorldProjection , float4(pos.xyz, 1));
                depthOut = projection.z / projection.w;
                return fixed4(terrainColor(pos.xz, ray),1);
            }
            if(dist > _CameraClipPlane.y)
                return fixed4(0,0,0,1);
            pos += ray * d;
            dist += d;
        }

        return fixed4 (0, 0, 0, 1);
    }

    float renderDepth (v2f i) : SV_TARGET
    {
        float3 ray = normalize(i.ray);
        int hit;
        float3 pos = _CameraPos;
        float dist = 0;
        while (1)
        {
            float d = pos.y - terrain(pos.xz);
            if(d <= _PixelAngle.x * dist)
            {
                float4 projection = mul(_WorldProjection , float4(pos.xyz, 1));
                return projection.z / projection.w;
            }
            if(dist > _CameraClipPlane.y)
                return 0;
            pos += ray * d;
            dist += d; 
        }

        return 0;
    }

    ENDCG

    SubShader
    {
        // No culling or depth
        Cull Off 
        ZWrite On 
        ZTest Off

        // #0 color
        Pass 
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            
            ENDCG
        }
        // #1 depth
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment renderDepth

            ENDCG
        }
    }
}
