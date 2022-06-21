//
//  Shaders.metal
//  Boids
//
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct VertexIn {
    float2 position [[attribute(0)]];
    float4 color    [[attribute(1)]];
};

struct VertexOut {
    float4 pos [[position]];
    float4 color;
};

struct PerInstanceUniforms {
    simd_float4x4 transform;
};

vertex VertexOut vertex_main(VertexIn in [[stage_in]], constant PerInstanceUniforms *transformation [[buffer(1)]], uint instanceID [[instance_id]])
{
    constant PerInstanceUniforms &trans = transformation[instanceID];
    VertexOut out;
    out.pos = float4(in.position, 0.0, 1.0) * trans.transform;
    out.color = in.color;
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return in.color;
}
 
