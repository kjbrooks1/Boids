//
//  Shaders.metal
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float4 center   [[attribute(1)]];
    float radius    [[attribute(2)]];
    float4 color    [[attribute(3)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

vertex VertexOut vertex_main(VertexIn in [[stage_in]],
                             constant float4x4 &transform [[buffer(2)]])
{
    VertexOut out;
    out.position = transform * float4(in.center.xy + in.radius * in.position.xy, 0.0f, 1.0f);
    out.color = in.color;
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return in.color;
}
