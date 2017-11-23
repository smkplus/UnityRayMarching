//Raymarching CGINCLUDE

#include "UnityCG.cginc"

float _Limit = 1;
float _MinDistance = 0.001;

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

float ambient_occlusion( float3 pos, float3 nor )
			{
				float occ = 0.0;
				float sca = 1.0;
				for( int i=0; i<5; i++ )
				{
					float hr = 0.01 + 0.12*float(i)/4.0;
					float3 aopos =  nor * hr + pos;
					float dd = _DistanceFunction( aopos );
					occ += -(dd-hr)*sca;
					sca *= 0.95;
				}
				return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
			}
						
			float3 set_normal (float3 p)
			{
				float3 x = float3 (0.001,0.00,0.00);
				float3 y = float3 (0.00,0.001,0.00);
				float3 z = float3 (0.00,0.00,0.001);
				return normalize(float3(_DistanceFunction(p+x)-_DistanceFunction(p-x), _DistanceFunction(p+y)-_DistanceFunction(p-y), _DistanceFunction(p+z)-_DistanceFunction(p-z))); 
			}
			
			float3 lighting (float3 p)
			{
				float3 AmbientLight = float3 (0.1,0.1,0.1);
				float3 LightDirection = normalize(float3 (4.0,10.0,-10.0));
				float3 LightColor = float3 (1.0,1.0,1.0);
				float3 NormalDirection = set_normal(p);
				return (max(dot(LightDirection, NormalDirection),0.0) * LightColor + AmbientLight)*ambient_occlusion(p,NormalDirection);
			}

			float4 raymarch (float3 ro, float3 rd)
			{
				for (int i=0; i<128; i++)
				{
					float ray = _DistanceFunction(ro);
					if(_Limit != 0){
					if (distance(ro,ray*rd)>250) break;
					}
					if (ray < _MinDistance) return float4 (lighting(ro)*float3(1.0,0.0,0.0),1.0); else ro+=ray*rd; 
				}
				return float4 (0.0,0.0,0.0,0.0);
			}

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
