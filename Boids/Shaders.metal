//
//  Shaders.metal
//  Boids
//
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct VertexIn {
    float2 vert  [[attribute(0)]];
    float4 color [[attribute(1)]];
    float angle  [[attribute(2)]];
    float posX   [[attribute(3)]];
    float posY   [[attribute(4)]];
    float time   [[attribute(5)]];
};

struct VertexOut {
    float4 pos [[position]];
    float4 color;
};

struct PerInstanceUniforms {
    simd_float4x4 transform;
};

/*
let T1 = simd_float4x4(SIMD4<Float>(1, 0, 0, -position.x),
                       SIMD4<Float>(0, 1, 0, -position.y),
                       SIMD4<Float>(0, 0, 1, 0),
                       SIMD4<Float>(0, 0, 0, 1))

let R = simd_float4x4(SIMD4<Float>(cos(angle), -sin(angle), 0, 0),
                       SIMD4<Float>(sin(angle),  cos(angle), 0, 0),
                       SIMD4<Float>(0, 0, 1, 0),
                       SIMD4<Float>(0, 0, 0, 1))

let T2 = simd_float4x4(SIMD4<Float>(1, 0, 0, position.x),
                       SIMD4<Float>(0, 1, 0, position.y),
                       SIMD4<Float>(0, 0, 1, 0),
                       SIMD4<Float>(0, 0, 0, 1))
*/

vertex VertexOut vertex_main(VertexIn in [[stage_in]])
{
    
    simd_float4x4 R = simd_float4x4(float4(cos(in.angle), -sin(in.angle), 0, 0),
                                    float4(sin(in.angle),  cos(in.angle), 0, 0),
                                    float4(0, 0, 1, 0),
                                    float4(0, 0, 0, 1));
    
    simd_float4x4 T = simd_float4x4(float4(1, 0, 0, in.posX + in.time*cos(in.angle)),
                                    float4(0, 1, 0, in.posY + in.time*sin(in.angle)),
                                    float4(0, 0, 1, 0),
                                    float4(0, 0, 0, 1));
    
    VertexOut out;
    out.pos = float4(in.vert, 0.0, 1.0) * R * T;
    out.color = in.color;
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return in.color;
}
 
