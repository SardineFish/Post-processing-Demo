Shader "MyShader/BasicShader"
{
	Properties
	{
		_NormalMap ("Normal Map", 2D) = "" {}
	}

	SubShader
	{
		Tags {
            "RenderType"="Opaque"
        }
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			struct a2v
			{
				float4 pos: POSITION;
				float4 normal: NORMAL;
				fixed4 color: COLOR0;
				float4 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				fixed4 color: COLOR0;
				float4 normal: NORMAL;
				float4 uv: TEXCOORD0;
			};

			void f()
			{
				int i;
				unsigned int ui;
				unsigned int4 v;
			}

			v2f vert(a2v v)
			{
				int t = (int)v;
				v2f output;
				output.pos = UnityObjectToClipPos(v.pos);
				output.color = v.color;
				output.normal = v.normal;
				output.uv = v.uv;
				return output;
			}

			fixed4 frag(v2f input): SV_TARGET
			{
				return input.uv;
			}


			ENDCG
		}
	}
	Fallback "VertexLit"
}
