//
//  Boid.swift
//  Boids
//
//

import Foundation
import MetalKit

struct PerInstanceUniforms {
    var transform: simd_float4x4
}

class Boid {
    
    var position: SIMD2<Float>
    var angle: Float
    var speed: Float
    
    init() {
        position = SIMD2<Float>(Float.random(in: -0.9 ... 0.9), Float.random(in: -0.9 ... 0.9))
        print(position)
        angle = Float.random(in: 0 ..< (2 * .pi))
        print(angle)
        speed = Float.random(in: 0...0.5)
        print("----")
    }
    
    static func makeBoidVertices(x: Float, y:Float) -> [Float] {
        // make triangle vertices
        let width: Float = 0.07
        let height: Float = 1.5 * width
        let color = SIMD4<Float>(0.6, 0.9, 0.1, 1.0) // neon green
        
        let a = SIMD4<Float>(x - (height/2), y + (width/2), 0, 1)
        let b = SIMD4<Float>(x - (height/2), y - (width/2), 0, 1)
        let c = SIMD4<Float>(x + (height/2), y, 0, 1)
        
        return [a.x, a.y, color.x, color.y, color.z, color.w,
                b.x, b.y, color.x, color.y, color.z, color.w,
                c.x, c.y, color.x, color.y, color.z, color.w]
    }
    
}
