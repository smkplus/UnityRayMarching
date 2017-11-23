// Created by Seyed Morteza Kamaly - SMK/2017

//http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm

Shader "Smkgames/Repetition"
{
	Properties
	{
		_Size("Size",Float) = 15
	}
	SubShader
	{
		// No culling
		Blend SrcAlpha OneMinusSrcAlpha
Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		Pass
		{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		
		#include "UnityCG.cginc"
		#include "Assets/Shaders/Includes/Shapes.cginc"
		#include "Assets/Shaders/Includes/Math.cginc"
		

		struct v2f {
		float4 pos : SV_POSITION;	// Clip space
		float3 wPos : TEXCOORD1;	// World position
		};
#define DISTANCE_FUNCTION DistanceFunction
// Constants
#define STEPS 64
#define MIN_DISTANCE 1.0

// Variables
float _Size;

// Function of distance.
fixed DistanceFunction( fixed3 p ) {
    p += fixed3(0,-1,0); 
    //p.xz = mul(p.xz,rotate(_Time.y)); 
    return sdBox(opRep(p,fixed3(20.0,20.0,20.0)),fixed3(1.1,1.1,1.1));
   }
#include "Assets/Shaders/Includes/SimpleRaymarching.cginc"

			ENDCG
		}
	}
}
