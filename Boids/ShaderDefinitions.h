//
//  ShaderDefinitions.h
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

#ifndef ShaderDefinitions_h
#define ShaderDefinitions_h

#include <simd/simd.h>

struct Velocity {
    vector_float2 pos;
};

struct WindowSize {
    vector_float2 size;
};

#endif /* ShaderDefinitions_h */
