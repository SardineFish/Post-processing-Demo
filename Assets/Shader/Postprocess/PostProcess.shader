Shader "MyShader/Postprocess/Blank"
{
    CGINCLUDE

    #include "./Lib.hlsl"

    sampler2D _MainTex;

    fixed4 frag(v2f i) : SV_TARGET
    {
        return tex2D(_MainTex, i.uv);
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
            #pragma fragment frag

            ENDCG
        }

    }
}
