// Created by Seyed Morteza Kamaly - SMK/2017

//http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
//http://www.iquilezles.org/www/articles/morenoise/morenoise.htm
//https://www.shadertoy.com/view/XttSz2

Shader "Smkgames/Abstract/FractalBrownianMotion"
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

            struct VertexInput{
                float2 uv:TEXCOORD0;
                float4 vertex:POSITION;
            };

            struct VertexOutput
            {
                float2 uv : TEXCOORD0;
                float4 screen_vertex : SV_POSITION;
                float3 world_vertex : TEXCOORD1;
            };

fixed2x2 rotate(fixed a) { 
    return fixed2x2( cos(a), sin(a), -sin(a), cos(a) );
}


fixed hash( fixed n ) { return frac(sin(n)*753.5453123); }


//---------------------------------------------------------------
// value noise, and its analytical derivatives
//---------------------------------------------------------------

fixed4 noised( in fixed3 x )
{
    fixed3 p = floor(x);
    fixed3 w = frac(x);
	fixed3 u = w*w*(3.0-2.0*w);
    fixed3 du = 6.0*w*(1.0-w);
    
    fixed n = p.x + p.y*157.0 + 113.0*p.z;
    
    fixed a = hash(n+  0.0);
    fixed b = hash(n+  1.0);
    fixed c = hash(n+157.0);
    fixed d = hash(n+158.0);
    fixed e = hash(n+113.0);
	fixed f = hash(n+114.0);
    fixed g = hash(n+270.0);
    fixed h = hash(n+271.0);
	
    fixed k0 =   a;
    fixed k1 =   b - a;
    fixed k2 =   c - a;
    fixed k3 =   e - a;
    fixed k4 =   a - b - c + d;
    fixed k5 =   a - c - e + g;
    fixed k6 =   a - b - e + f;
    fixed k7 = - a + b + c - d + e - f - g + h;

    return fixed4( k0 + k1*u.x + k2*u.y + k3*u.z + k4*u.x*u.y + k5*u.y*u.z + k6*u.z*u.x + k7*u.x*u.y*u.z, 
                 du * (fixed3(k1,k2,k3) + u.yzx*fixed3(k4,k5,k6) + u.zxy*fixed3(k6,k4,k5) + k7*u.yzx*u.zxy ));
}

//---------------------------------------------------------------

fixed4 sdBox( fixed3 p, fixed3 b ) // distance and normal
{
    fixed3 d = abs(p) - b;
    fixed x = min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
    fixed3  n = step(d.yzx,d.xyz)*step(d.zxy,d.xyz)*sign(p);
    return fixed4( x, n );
}


fixed4 fbmd( in fixed3 x )
{
    const fixed scale  = 1.5;

    fixed a = 0.0;
    fixed b = 0.5;
	fixed f = 1.0;
    fixed3  d = fixed3(0.0,0.0,0.0);
    [unroll(100)]
for( int i=0; i<8; i++ )
    {
        fixed4 n = noised(f*x*scale);
        a += b*n.x;           // accumulate values		
        d += b*n.yzw*f*scale; // accumulate derivatives
        b *= 0.5;             // amplitude decrease
        f *= 1.8;             // frequency increase
    }

	return fixed4( a, d );
}

// Function of distance.
fixed map( in fixed3 p )
{
	fixed4 d1 = fbmd( p );
    d1.x -= 0.37;
	d1.x *= 0.7;
    d1.yzw = normalize(d1.yzw);

    // clip to box
    fixed4 d2 = sdBox( p, fixed3(1.5,1.5,1.5) );
    return (d1.x>d2.x) ? d1 : d2;
}

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float sdTorus( float3 p, float2 t )
            {
            float2 q = float2(length(p.xz)-t.x,p.y);
            return length(q)-t.y;
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
                for (int i=0; i<64; i++)
                {
                    float ray = map(ro);
                    if (distance(ro,ray*rd)>250) break;
                    if (ray < 0.001) return float4 (lighting(ro),1.0); else ro+=ray*rd; 
                }
                return float4 (0.0,0.0,0.0,0.0);
            }

            VertexOutput vertex_shader (VertexInput v)
            {
                VertexOutput o;
                o.screen_vertex = UnityObjectToClipPos (v.vertex);
                o.world_vertex = mul (unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX (v.uv, _MainTex);
                return o;
            }

            float4 pixel_shader (VertexOutput i) : SV_TARGET
            {
                float3 worldPosition = i.world_vertex;
                float3 viewDirection = normalize(i.world_vertex - _WorldSpaceCameraPos.xyz);
				float4 tex = tex2D(_MainTex,i.uv);
                return raymarch (worldPosition,viewDirection);
            }

            ENDCG

        }
    }
}

