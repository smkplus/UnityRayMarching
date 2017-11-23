// Created by Seyed Morteza Kamaly - SMK/2017

//http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm

Shader "Smkgames/Repetition2"
{
	Properties{
	_Distance("Distance",Float) = 70
	_MinDistance("Min Distance",Float) = 0
	[Toggle(Limit)]
	_Limit("Limit Area",Float) = 0
	}
	Subshader
	{
        Blend SrcAlpha OneMinusSrcAlpha
Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		Pass
		{
			CGPROGRAM
			#pragma vertex vertex_shader
			#pragma fragment pixel_shader
			#pragma target 3.0



			struct custom_type
			{
				float4 screen_vertex : SV_POSITION;
				float3 world_vertex : TEXCOORD1;
			};

			float _Distance;


			#define DISTANCE_FUNCTION DistanceFunction

			float repeatedGrid( float3 p, float3 c, float b )
			{
			float3 d = abs(fmod(p,c)-0.5*c)-b;
			return min(min(max(d.x,d.y), max(d.x,d.z)), max(d.y,d.z));
			}

			#include "Assets/Shaders/Includes/Shapes.cginc"	
			float DistanceFunction( float3 p)
			{                        
			float Cubes = sdBox(opRep(p+0.05, float3(1.2,1.2,1.2)*_Distance),0.071*30);
			float Grids = repeatedGrid(p+0.05, float3(1.2,1.2,1.2)*_Distance, 0.0271);                        
			float result = min(Cubes, Grids);
			return result;
			}

			#include "Assets/Shaders/Includes/Raymarching.cginc"
			
			ENDCG

		}
	}
}