Shader "MyShader/Postprocess/Bloom"
{
    CGINCLUDE

    #include "./Lib.hlsl"

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;
    float _PreFilter_Thredshold;
    float _PreFilter_SoftThreshold;


    inline float4 lightPreFilter(float4 color)
    {
        float softThredshold = _PreFilter_SoftThreshold;
        float thredshold = _PreFilter_Thredshold;

        float brightness = max(color.r, max(color.g, color.b));
        float knee = thredshold * softThredshold;
        float soft = brightness - thredshold + knee;
        soft = clamp(soft, 0, 2 * knee);
        soft = soft * soft / (4 * knee + 0.0001);

        float contribution = max(soft, brightness - thredshold);
        contribution /= max(brightness, 0.00001);
        return color * saturate(contribution);
    }

    float4 LightPreFilter(v2f i) : SV_TARGET
    {
        
    }

    inline float4 boxSample(sampler2D tex, float2 delta, float2 texcoord)
    {
        float4 color = 0;
        float4 d = delta.xyxy * float4(1,1,-1,-1);
        color += tex2D(tex, texcoord.xy + d.xy).rgba;
        color += tex2D(tex, texcoord.xy + d.xw).rgba;
        color += tex2D(tex, texcoord.xy + d.zy).rgba;
        color += tex2D(tex, texcoord.xy + d.zw).rgba;
        return color / 4;
    }

    float4 PreFilterWithDownSample(v2f i) : SV_TARGET
    {
        float4 color = boxSample(_MainTex, _MainTex_TexelSize.xy, i.uv.xy);
        color = lightPreFilter(color);
        return color;
    }

    float4 DownSample(v2f i) : SV_TARGET
    {
        return boxSample(_MainTex, _MainTex_TexelSize.xy * 1, i.uv.xy);
    }

    float4 UpSample(v2f i) : SV_TARGET
    {
        return boxSample(_MainTex, _MainTex_TexelSize.xy * 0.5, i.uv.xy);
    }

    sampler2D _BlurTex;
    float _Intensity;
    float4 ApplyBloom(v2f i) : SV_TARGET
    {
        float4 color = tex2D(_MainTex, i.uv).rgba;
        float4 blurLight = tex2D(_BlurTex, i.uv).rgba;
        return color + blurLight * _Intensity;
    }

    ENDCG
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        // #0 Light prefilter & down sample
        pass
        {
            CGPROGRAM

            #pragma vertex default_vert
            #pragma fragment PreFilterWithDownSample

            ENDCG
        }

        // #1 down sample
        Pass
        {
            CGPROGRAM
            
            #pragma vertex default_vert
            #pragma fragment DownSample

            ENDCG
        }

        // #2 up sample
        Pass
        {
            CGPROGRAM
            
            #pragma vertex default_vert
            #pragma fragment UpSample

            ENDCG
        }

        // #3 apply bloom
        Pass
        {
            CGPROGRAM
            
            #pragma vertex default_vert
            #pragma fragment ApplyBloom

            ENDCG
        }

    }
}
