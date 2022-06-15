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
    float4 pos [[position]];
    float4 color;
};

struct FrameData {
    float distance;
    //float angle;
};

vertex VertexOut vertexShader(device const VertexIn *in [[buffer(0)]], constant FrameData* frameData [[buffer(1)]], uint vertexID [[vertex_id]])
{
    float dist = frameData->distance;
    VertexIn vin = in[vertexID];
    VertexOut out;
    out.pos = float4(vin.position.x + dist, vin.position.y + dist, 0, 1);
    out.color = vin.color;
    return out;
}

fragment float4 fragmentShader(VertexOut interpolated [[stage_in]])
{
    return interpolated.color;
}
