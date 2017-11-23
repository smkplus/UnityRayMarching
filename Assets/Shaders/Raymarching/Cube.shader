// Created by Seyed Morteza Kamaly - SMK/2017

//http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm

Shader "Smkgames/Raymarcher"
{
	Properties
	{
		_Size("Size",Float) = 15
	}
	SubShader
	{
		// No culling
		Cull Off  ZTest Always
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

// Variables
float _Size;

#define DISTANCE_FUNCTION DistanceFunction
// Function of distance.
float DistanceFunction( fixed3 p ) {
    p += float3(0,-1,0); 
    p.xz = mul(p.xz,rotate(_Time.y));
    float Sphere = sdSphere(p,_Size*1.2);
        float Box = sdBox(p,float3(_Size,_Size,_Size));
    return opS(Sphere,Box) ;
   }

   #include "Assets/Shaders/Includes/SimpleRaymarching.cginc"

			ENDCG
		}
	}
}
