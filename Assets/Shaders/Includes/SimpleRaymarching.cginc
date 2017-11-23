//Raymarching CGINCLUDE

#include "UnityCG.cginc"

// Constants
#define STEPS 64
#define MIN_DISTANCE 0.01

#ifndef DISTANCE_FUNCTION
inline float _DefaultDistanceFunction(float3 pos)
{
    return pos;
}
#define DISTANCE_FUNCTION _DefaultDistanceFunction
#endif

inline float _DistanceFunction(float3 pos)
{
    return DISTANCE_FUNCTION(pos);
}

fixed4 raymarch (float3 position, float3 direction)
{
	// Loop do raymarcher.
	for (int i = 0; i < STEPS; i++)
	{
		float distance = _DistanceFunction(position);
		if (distance < 0.01)
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