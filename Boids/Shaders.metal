//
//  Shaders.metal
//  Boids
//
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct VertexIn {
    float2 vert    [[attribute(0)]];
    float4 color   [[attribute(1)]];
    float angle  [[attribute(6)]];
    float posX   [[attribute(7)]];
    float posY   [[attribute(8)]];
};

struct VertexOut {
    float4 color;
    float4 pos [[position]];
};

struct PerInstanceUniforms {
    simd_float4x4 transform;
};

vertex VertexOut vertex_main(VertexIn in [[stage_in]])
{
    
    simd_float4x4 R = simd_float4x4(float4(cos(in.angle), -sin(in.angle), 0, 0),
                                    float4(sin(in.angle),  cos(in.angle), 0, 0),
                                    float4(0, 0, 1, 0),
                                    float4(0, 0, 0, 1));
    
    simd_float4x4 T = simd_float4x4(float4(1, 0, 0, in.posX),
                                    float4(0, 1, 0, in.posY),
                                    float4(0, 0, 1, 0),
                                    float4(0, 0, 0, 1));
    
    VertexOut out;
    out.pos = float4(in.vert.x , in.vert.y, 0.0, 1.0) * R * T;
    out.color = in.color;
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return in.color;
}
 
