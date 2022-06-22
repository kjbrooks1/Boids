//
//  Boid.swift
//  Boids
//
//

import Foundation
import MetalKit

class Boid {
    
    var position: SIMD2<Float>
    var angle: Float
    
    init() {
        position = SIMD2<Float>(Float.random(in: -0.9 ... 0.9), Float.random(in: -0.9 ... 0.9))
        angle = Float.random(in: 0 ..< (2 * .pi))
    }
    
    static func shapeVertices() -> [Float] {
        let width: Float = 0.07
        let height: Float = 1.5 * width
        
        let a = SIMD4<Float>(0 - (height/2), 0 + (width/2), 0, 1)
        let b = SIMD4<Float>(0 - (height/2), 0 - (width/2), 0, 1)
        let c = SIMD4<Float>(0 + (height/2), 0, 0, 1)
        
        return [a.x, a.y,
                b.x, b.y,
                c.x, c.y]
    }
    
    static func shapeColors() -> [Float] {
        let color = SIMD4<Float>(0.6, 0.9, 0.1, 1.0) // neon green
        return [color.x, color.y, color.z, color.w,
                color.x, color.y, color.z, color.w,
                color.x, color.y, color.z, color.w]
    }
}
