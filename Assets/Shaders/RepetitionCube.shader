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
		Blend SrcAlpha OneMinusSrcAlpha
Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		Pass
		{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		
		#include "UnityCG.cginc"

		struct v2f {
		float4 pos : SV_POSITION;	// Clip space
		float3 wPos : TEXCOORD1;	// World position
		};


// Constants
#define STEPS 64
#define MIN_DISTANCE 1.0

// Variables
float _Size;


// Rotation Matrix
float2x2 rotate(float a) { 
    return float2x2( cos(a), sin(a), -sin(a), cos(a) );
}
fixed sdBox( fixed3 p, fixed3 b )
{
  fixed3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

fixed3 opRep( fixed3 p, fixed3 c )
{
    fixed3 q = fmod(p,c)-0.5*c;
    return q;
}

// Function of distance.
fixed map( fixed3 p ) {
    p += fixed3(0,-1,0); 
    //p.xz = mul(p.xz,rotate(_Time.y)); 
    return sdBox(opRep(p,fixed3(20.0,20.0,20.0)),fixed3(1.1,1.1,1.1));
   }

fixed4 raymarch (float3 position, float3 direction)
{
	// Loop do raymarcher.
	for (int i = 0; i < STEPS; i++)
	{
		float distance = map(position);
		if (distance < 1)
			return i / (float) STEPS;

		position += distance * direction;
	}
	return 0;
}

		// Vertex function
		v2f vert (appdata_full v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz; 
			return o;
		}



		// Fragment function
		fixed4 frag (v2f i) : SV_Target
		{
			float3 worldPosition = i.wPos;
			float3 viewDirection = normalize(i.wPos - _WorldSpaceCameraPos);
			return raymarch (worldPosition, viewDirection) * float4(1,1,1,10);
		}
			
			ENDCG
		}
	}
}
