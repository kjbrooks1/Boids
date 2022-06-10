//
//  Shaders.metal
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 vertex_main(device float2 const* positions [[buffer(0)]], uint vertexID [[vertex_id]])
{
    float2 position = positions[vertexID];
    return float4(position, 0.0, 1.0);
}

fragment float4 fragmentShader(VertexOut interpolated [[stage_in]])
{
    return interpolated.color;
}
