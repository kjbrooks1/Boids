//
//  Shaders.metal
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

#include <metal_stdlib>
#include "ShaderDefinitions.h"

using namespace metal;

struct VertexIn {
    // tell Metal which vertex struct members match which attributes
    float2 position [[attribute(0)]];
    float4 color    [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

vertex VertexOut vertex_main(VertexIn in [[stage_in]], constant float2 &positionOffset [[buffer(1)]])
{
    // stage_in indicates that we expect Metal to fetch vertices on our behalf
    VertexOut out;
    out.position = float4(in.position + positionOffset, 0.0, 1.0);
    out.color = in.color;
    return out;
}

fragment float4 fragmentShader(VertexOut interpolated [[stage_in]])
{
    return interpolated.color;
}
