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
        let width: Float = 0.05
        let height: Float = 1.5 * width
        let color = SIMD4<Float>(0.6, 0.9, 0.1, 1.0) // neon green
        
        let a = SIMD4<Float>(0 - (height/2), 0 + (width/2), 0, 1)
        let b = SIMD4<Float>(0 - (height/2), 0 - (width/2), 0, 1)
        let c = SIMD4<Float>(0 + (height/2), 0, 0, 1)
        
        return [a.x, a.y, color.x, color.y, color.z, color.w,
                b.x, b.y, color.x, color.y, color.z, color.w,
                c.x, c.y, color.x, color.y, color.z, color.w]
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
