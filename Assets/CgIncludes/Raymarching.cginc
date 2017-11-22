

#include "UnityCG.cginc"

#ifndef DISTANCE_FUNCTION
inline float _DefaultDistanceFunction(float3 pos)
{
    return pos;
}
#define DISTANCE_FUNCTION _DefaultDistanceFunction
#endif