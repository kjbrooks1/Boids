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
    float2 position [[attribute(0)]];
    float4 color    [[attribute(1)]];
};

struct VertexOut {
    float4 color;
    float4 pos [[position]];
};


vertex VertexOut vertex_main(VertexIn in [[stage_in]])
{
    VertexOut out;
    out.pos = float4(in.position, 0.0, 1.0);
    out.color = in.color;
    return out;
}

vertex VertexOut vertexShader(const device Vertex *vertexArray [[buffer(0)]], unsigned int vid [[vertex_id]])
{
    // Get the data for the current vertex.
    Vertex in = vertexArray[vid];
    VertexOut out;

    // Pass the vertex color directly to the rasterizer
    out.color = in.color;
    // Pass the already normalized screen-space coordinates to the rasterizer
    out.pos = float4(in.pos.x, in.pos.y, 0, 1);

    return out;
}

fragment float4 fragmentShader(VertexOut interpolated [[stage_in]])
{
    return interpolated.color;
}
