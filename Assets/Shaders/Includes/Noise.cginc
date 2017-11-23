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
