Shader "MyShader/Postprocess/ColorAdjustment"
{
    Properties {
        _MainTex("MainTex", 2D) = "white" {}
    }
    CGINCLUDE

    #include "./Lib.hlsl"

    // https://docs.unity3d.com/Packages/com.unity.shadergraph@6.9/manual/Colorspace-Conversion-Node.html
    inline float3 rgb_to_hsv(float3 In)
    {
        float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
        float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
        float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
        float D = Q.x - min(Q.w, Q.y);
        float  E = 1e-10;
        return float3(abs(Q.z + (Q.w - Q.y)/(6.0 * D + E)), D / (Q.x + E), Q.x);
    }
    // https://docs.unity3d.com/Packages/com.unity.shadergraph@6.9/manual/Colorspace-Conversion-Node.html
    inline float3 hsv_to_rgb(float3 In)
    {
        float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
        float3 P = abs(frac(In.xxx + K.xyz) * 6.0 - K.www);
        return In.z * lerp(K.xxx, saturate(P - K.xxx), In.y);
    }

    inline float3 rgb_to_hsl(float3 In)
    {
        In = saturate(In);
        float MAX = max(In.r, max(In.g, In.b));
        float MIN = min(In.r, min(In.g, In.b));
        float hue = 0;
        if(MAX == MIN)
            hue = 0;
        else if (MAX == In.r)
            hue = 60 * (0 + (In.g - In.b) / (MAX - MIN));
        else if (MAX == In.g)
            hue = 60 * (2 + (In.b - In.r) / (MAX - MIN));
        else if (MAX == In.b)
            hue = 60 * (4 + (In.r - In.g) / (MAX - MIN));

        hue /= 360;
        hue = frac(hue + 1);

        float saturation = (MAX - MIN) / (1 - abs(MAX + MIN - 1) + 0.00001);
        float lightness = (MAX + MIN) / 2;
        return float3(hue, saturation, lightness);
    }
    inline float3 hsl_to_rgb(float3 In)
    {
        float hue = frac(In.x) * 360;
        float S = saturate(In.y);
        float L = saturate(In.z);

        float3 N = float3(0, 8, 4);
        float3 K = frac((N + hue / 30) / 12) * 12;
        float A = S * min(L, 1 - L);
        return L - A * max(min(K - 3, min(9 - K, 1)), -1);
    }

    sampler2D _MainTex;

    float _Brightness;
    float _Contrast;
    float _Hue;
    float _Saturation;
    float4 ColorAdjustment(v2f i) : SV_TARGET
    {
        float4 color = tex2D(_MainTex, i.uv).rgba;
        float3 hsl = rgb_to_hsl(color.rgb);

        // Brightness
        hsl.z += _Brightness;
        hsl.x += _Hue;
        hsl.y += pow(_Saturation, 3);


        // Contrast
        color.rgb = hsl_to_rgb(hsl);
        float k = (_Contrast + 1) / (1 - _Contrast + 0.00001);
        color.rgb = k * (color.rgb - 0.5) + 0.5;

        return color;
    }

    ENDCG

    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        // #0 Light prefilter & down sample
        pass
        {
            CGPROGRAM

            #pragma vertex default_vert
            #pragma fragment ColorAdjustment

            ENDCG
        }

    }
}
