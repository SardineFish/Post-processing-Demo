
Shader "MyShader/Blinn"
{
    Properties
    {
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
		_Specular ("Specular", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(0,1024)) = 64
        _MainTex ("Texture", 2D) = "white" {}
	
	}
		SubShader
	{

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			float4 _Diffuse;
			float4 _Specular;
			float _Gloss;

            struct a2v
			{
				float3 vertex: POSITION;
				float3 normal: NORMAL;
				float4 color: COLOR0;
			};
			struct v2f
			{
				float4 vertex: SV_POSITION;
				float3 normal: NORMAL;
				float3 worldPos: TEXCOORD1;
				float3 color: COLOR0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = mul(v.normal, unity_WorldToObject);
				o.color = v.color;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{

				float3 ambient = UNITY_LIGHTMODEL_AMBIENT;

				float3 worldNormal = normalize(i.normal);
				float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				// Compute diffuse term
				float3 diffuse = _LightColor0.rgb*_Diffuse.rgb*max(0, dot(i.normal, worldLightDir.xyz));

				// Get the view direction in world space
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				// Get the half direction in world space
				float3 halfDir = normalize(worldLightDir + viewDir);
				// Compute specular term
				float3 specular = _LightColor0.rgb*_Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
			}
            ENDCG
        }
    }
}
