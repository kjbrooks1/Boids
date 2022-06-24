//
//  Boid.swift
//  Boids
//
//

import Foundation
import MetalKit

class Boid {
    
    var color = SIMD4<Float>(0.6, 0.9, 0.1, 1.0) // neon green
    var position: SIMD2<Float>
    var velocity: SIMD2<Float>
    var angle: Float
    
    init() {
        position = SIMD2<Float>(Float.random(in: -0.9 ... 0.9), Float.random(in: -0.9 ... 0.9))
        angle = atan(position.y / position.x) //Float.random(in: 0 ..< (2 * .pi))
        velocity = SIMD2<Float>(cos(angle), sin(angle))
    }
    
    static func triangleVertices() -> [Float] {
        let width: Float = 0.04
        let height: Float = 1.2 * width
        
        let a = SIMD4<Float>(0 - (height/2), 0 + (width/2), 0, 1)
        let b = SIMD4<Float>(0 - (height/2), 0 - (width/2), 0, 1)
        let c = SIMD4<Float>(0 + (height/2), 0, 0, 1)
        
        return [a.x, a.y, b.x, b.y, c.x, c.y,]
    }
}

class VisionCircle {
    
    static let color = SIMD4<Float>(236/255, 236/255, 236/255, 1)
    var position: SIMD2<Float>
    
    init(mainGuy: Boid){
        position = mainGuy.position
    }
    
    static func circleVertices() -> [Float] {
        var vertices: [Float] = []
        let sideCount = 28
        let deltaTheta = (2 * Float.pi) / Float(sideCount)
        for t in 0..<sideCount {
            let t0 = Float(t) * deltaTheta
            let t1 = Float(t + 1) * deltaTheta
            
            vertices.append(contentsOf: [0,0, color.x, color.y, color.z, color.w])
            vertices.append(contentsOf: [0+0.3*cos(t0),0+0.3*sin(t0), color.x, color.y, color.z, color.w])
            vertices.append(contentsOf: [0+0.3*cos(t1),0+0.3*sin(t1), color.x, color.y, color.z, color.w])
        }
        return vertices;
    }
}
