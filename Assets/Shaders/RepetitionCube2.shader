// Created by Seyed Morteza Kamaly - SMK/2017

//http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm

Shader "Smkgames/Abstract/Tours"
{
	Subshader
	{

        // No culling
       // Cull Off
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
						
float repeatedBox( float3 p, float3 c, float b, float r )
{
  return length(max(abs(fmod(p,c)-0.5*c)-b,0.0))-r;
}

float repeatedGrid( float3 p, float3 c, float b )
{
  float3 d = abs(fmod(p,c)-0.5*c)-b;
  return min(min(max(d.x,d.y), max(d.x,d.z)), max(d.y,d.z));
}

float hash( float n ) { return frac(sin(n)*43758.5453); }

float map( float3 p)
{                        
   float Cubes = repeatedBox(p, float3(1.2,1.2,1.2)*40, 0.071*20, 0.031);                    
float GridsV = repeatedGrid(p+0.05, float3(1.2,1.2,1.2)*40, 0.0271*2);                        
  float ret = min(Cubes, GridsV);
  return ret;
}
			
			float ambient_occlusion( float3 pos, float3 nor )
			{
				float occ = 0.0;
				float sca = 1.0;
				for( int i=0; i<5; i++ )
				{
					float hr = 0.01 + 0.12*float(i)/4.0;
					float3 aopos =  nor * hr + pos;
					float dd = map( aopos );
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
				return normalize(float3(map(p+x)-map(p-x), map(p+y)-map(p-y), map(p+z)-map(p-z))); 
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
				for (int i=0; i<500; i++)
				{
					float ray = map(ro);
					//if (distance(ro,ray*rd)>1000) break;
					float3 golden = lerp(float3(hash(i),0,0),float3(1,hash(i),0),0.6);
					if (ray < 0.5) return float4 (lighting(ro),1.0)*float4(golden,1); else ro+=ray*rd; 
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

			ENDCG

		}
	}
}