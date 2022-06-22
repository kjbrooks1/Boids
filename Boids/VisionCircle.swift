//
//  VisionCircle.swift
//  Boids
//
//

import Foundation
import MetalKit

class VisionCircle {
    
    static let sideCount = 40
    
    static let verticiesSize = 3 * MemoryLayout<Vertex>.stride
    static let colorSize = MemoryLayout<SIMD3<Float>>.stride
    static let circleDataSize = sideCount * 3 * MemoryLayout<Vertex>.stride
    
    var position: SIMD2<Float>
    var vertices: [SIMD2<Float>]!    // [x,y] * sideCount
    var velocity: SIMD2<Float>
    var color: SIMD4<Float>
    var radius: Float
    var mainGuy: Boid
    
    init(mainGuy: Boid) {
        self.mainGuy = mainGuy
        position = mainGuy.center
        velocity = mainGuy.velocity
        color = SIMD4<Float>(0.86, 0.86, 0.86, 0.5)
        radius = 2
        vertices = makeVertices(mainGuy: mainGuy, transMatrix: mainGuy.transformationMatrix)
    }
    
    func makeVertices(mainGuy: Boid, transMatrix: simd_float3x3) -> [SIMD2<Float>] {
        var allVert: [SIMD2<Float>] = []
        position = mainGuy.center
        velocity = mainGuy.velocity
        let angle = mainGuy.angleC
        let deltaTheta = (2 * Float.pi - angle) / Float(VisionCircle.sideCount)
        for t in 0..<VisionCircle.sideCount {
            let t0 = Float(t) * deltaTheta
            let t1 = Float(t + 1) * deltaTheta
                 
            let temp = [
                simd_mul( SIMD3<Float>(position.x, position.y, 1), transMatrix),
                simd_mul( SIMD3<Float>(position.x+cos(t0 + .pi / 2 + angle / 2)*0.35, position.y+sin(t0 + .pi / 2 + angle / 2)*0.35, 1), transMatrix),
                simd_mul( SIMD3<Float>(position.x+cos(t1 + .pi / 2 + angle / 2)*0.35, position.y+sin(t1 + .pi / 2 + angle / 2)*0.35, 1), transMatrix)
            ]
            allVert.append(SIMD2<Float>(temp[0].x, temp[0].y))
            allVert.append(SIMD2<Float>(temp[1].x, temp[1].y))
            allVert.append(SIMD2<Float>(temp[2].x, temp[2].y))
        }
        return allVert
    }
}
