

Shader "Abstract"
{
	Properties{
			_MinDistance("Min Distance",Float) = 0
	}
	Subshader
	{

Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Pass
		{
			CGPROGRAM
			#pragma vertex vertex_shader
			#pragma fragment pixel_shader

			struct custom_type
			{
				float4 screen_vertex : SV_POSITION;
				float3 world_vertex : TEXCOORD1;
			};
			#define DISTANCE_FUNCTION DistanceFunction			
			#include "Assets/Shaders/Includes/Shapes.cginc"	
						
			float DistanceFunction (float3 p)
			{
				return sdTorus(p,float2(1.0,0.5));
			}

			#include "Assets/Shaders/Includes/Raymarching.cginc"

			ENDCG

		}
	}
}