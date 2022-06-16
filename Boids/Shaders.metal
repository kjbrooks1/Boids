//
//  Shaders.metal
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

#include <metal_stdlib>
#include "ShaderDefinitions.h"
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

struct FrameData {
    float distanceX;
    float distanceY;
    float angleRad;
};

vertex VertexOut vertexShader(device const VertexIn *in [[buffer(0)]], constant FrameData* frameData [[buffer(1)]], uint vertexID [[vertex_id]])
{
    float distX = frameData->distanceX;
    float distY = frameData->distanceY;
    float angle = frameData->angleRad;
    
    VertexIn vin = in[vertexID];
    VertexOut out;
    out.pos = float4((vin.position.x + distX * cos(angle)), (vin.position.y + distY * sin(angle)), 0, 1);
    out.color = vin.color;
    return out;
}

fragment float4 fragmentShader(VertexOut interpolated [[stage_in]])
{
    return interpolated.color;
}
