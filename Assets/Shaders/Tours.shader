// Created by Seyed Morteza Kamaly - SMK/2017

Shader "Smkgames/Abstract/Tours"
{
	Subshader
	{

        // No culling
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha
Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		Pass
		{
			CGPROGRAM
			#pragma vertex vertex_shader
			#pragma fragment pixel_shader
			#pragma target 3.0

			#include "UnityCG.cginc"

			#define DISTANCE_FUNCTION DistanceFunction

			struct custom_type
			{
				float4 screen_vertex : SV_POSITION;
				float3 world_vertex : TEXCOORD1;
			};
			#include "Assets/CgIncludes/Shapes.cginc"	
						
			float DistanceFunction (float3 p)
			{
				return sdTorus(p,float2(1.0,0.5));
			}
			
			#include "Assets/CgIncludes/Raymarching.cginc"
			
			custom_type vertex_shader (float4 vertex : POSITION)
			{
				custom_type vs;
				vs.screen_vertex = UnityObjectToClipPos (vertex);
				vs.world_vertex = mul (unity_ObjectToWorld, vertex);
				return vs;
			}

			float4 pixel_shader (custom_type ps ) : SV_TARGET
			{
				float3 worldPosition = ps.world_vertex;
				float3 viewDirection = normalize(ps.world_vertex - _WorldSpaceCameraPos.xyz);
				return raymarch (worldPosition,viewDirection);
			}

			ENDCG

		}
	}
}