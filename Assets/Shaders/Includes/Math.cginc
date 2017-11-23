


// Rotation Matrix
float2x2 rotate(float a) { 
    return float2x2( cos(a), sin(a), -sin(a), cos(a) );
}