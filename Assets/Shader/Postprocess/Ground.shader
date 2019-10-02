Shader "MyShader/Postprocess/InfiniteGround"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Texture ("Texture", 2D) = "white" {}
        _Height ("Height", Float) = 0
        _UVOffset ("UV Offset", Vector) = (0,0,0,0)
        _UVScale ("UV Scale", Float) = 1
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
            float3 _CameraClipPlane; // (near, far, near - far)
            float _UVScale;
            float2 _UVOffset;
            float _Height;

            sampler2D _Texture;
            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;

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

            fixed4 frag (v2f i) : SV_Target
            {
                float3 color = tex2D(_MainTex, i.uv).rgb;
                
                float depth = tex2D(_CameraDepthTexture, i.uv).r;
                depth = LinearEyeDepth(depth);
                float3 worldPos = _CameraPos + depth * normalize(i.ray).xyz;

                if(worldPos.y < _Height)
                {
                    return 1;
                    float3 ray = worldPos - _CameraPos;
                    float t = (_Height - _CameraPos.z) / ray.z;
                    float2 uv = (_CameraPos + ray * t).xy;
                    color = tex2D(_Texture, uv * _UVScale + _UVOffset).rgb;
                }

                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
