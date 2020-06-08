#ifndef DROPPLETSHADER_INCLUDED
#define DROPPLETSHADER_INCLUDED
#include "Assets/Assets/Shaders/DroppletShader.hlsl"

float2 N21_float(float2 p)
{
    p = frac(p * float2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return frac(p.x * p.y);
}

float3 Layer_float(float2 UV, float time)
{
    float2 aspect = float2(2,1);
    float2 uv = UV;
    uv.y += time * 0.25;
    float2 gv = frac(uv)-0.5;
    //This is to know which cell we're in to properly
    // offset dropplet positions
    float2 id = floor(uv);
    float n = N21_float(id);
    time += n * 6.2831;
    //x, y for movement of the dropplets;
    float w = UV.y * 10;
    float x = (n - 0.5) * 0.8;
    // this sine wave makes the dropplets goes left-right
    // in a pattern if its not too close to the cell border
    x += (0.4 - abs(x)) * sin(3 * w) * pow(sin(w), 6) * 0.45;
    float y = -sin(time + sin(time + sin(time) * 0.5)) * 0.45;
    y -= (gv.x-x) * (gv.x-x);
    //This draws the dropplets animate it downwards
    float2 dropPos = (gv - float2(x, y)) / aspect;
    float drop = smoothstep(0.05, 0.03, length(dropPos));
    //This draws multiple trail drops that depending on where
    // the main dropplet is will fades in and out.
    float2 trailPos = (gv - float2(x, time * 0.25)) / aspect;
    trailPos.y = (frac(trailPos.y * 8) - 0.5) / 8;
    float trail = smoothstep(0.03, 0.01, length(trailPos));
    //only draw if the position of the trail is above the drop
    float fogTrail = smoothstep(-0.05, 0.05, dropPos.y);
    //fades the trails depending on the drop's position
    fogTrail *= smoothstep(0.5, y, gv.y);
    trail *= fogTrail;
    //this makes the drop leave a fogtrail while going down
    fogTrail *= smoothstep(0.05, 0.04, abs(dropPos.x));
    float2 offset = drop*dropPos + trail*trailPos;

    return float3(offset, fogTrail);
}

void Dropplet_float(float2 A, float1 Size, out float2 Out, out float1 z)
{
    //Out = 0;
    float time = fmod(_Time.y, 7200);
    float2 aspect = float2(2,1);
    float3 drops = Layer_float(A * Size * aspect, time);
    Out = drops.xy;
    Out *= -5;
    z = drops.z;
}
#endif