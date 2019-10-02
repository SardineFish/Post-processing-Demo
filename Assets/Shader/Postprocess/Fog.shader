Shader "MyShader/Postprocess/Fog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FogColor ("Fog Color", Color) = (1,1,1,1)
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
            float3 _ViewRange; // (near, far, near - far)
            float3 _CameraClipPlane; // (near, far, near - far)

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

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float3 _FogColor;
            float _Density;

            #define FOG(FOG_COLOR, ORIGIN_COLOR, F) (FOG_COLOR * F + (1 - F) * ORIGIN_COLOR)

            fixed4 frag (v2f i) : SV_Target
            {
                float d = _Density;
                float3 color = tex2D(_MainTex, i.uv).rgb;
                float depth = tex2D(_CameraDepthTexture, i.uv).r;
                depth = LinearEyeDepth(depth);
                float3 worldPos = _CameraPos + depth * normalize(i.ray).xyz;

                float z = _CameraClipPlane.x + depth * _CameraClipPlane.z;
                z = saturate( (length(worldPos - _CameraPos) - _ViewRange.x) / _ViewRange.z);
                
                float f = (abs(z) - _ViewRange.x) / (_ViewRange.y - _ViewRange.x);
                f = 1 - exp(-pow(d * abs(z), 1));
                f = saturate((2 - worldPos.y) / (2));
                // f = pow(f, 2);
                //f = 1 - exp(-pow(d * abs(f), 1));
                // depth = (depth + 1) / 2;
                // just invert the colors
                // col.rgb = 1 - col.rgb;
                return fixed4 (FOG(_FogColor, color, f), 1);
            }
            ENDCG
        }
    }
}
