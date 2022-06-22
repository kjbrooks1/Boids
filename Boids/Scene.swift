//
//  Swarm.swift
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

import Foundation
import MetalKit

/*
class Scene {
    
    var boids: [Boid]
    static let instanceDataSize = 3 * MemoryLayout<Vertex>.stride
    
    init(instanceCount: Int){
        boids = []
        for _ in 0..<instanceCount {
            boids.append(Boid())
        }
    }
    
    func copyInstanceData(to buffer: MTLBuffer) {
        // get the vertex data from each boid
        var j = 0
        var test: [Vertex] = []
        
        for b in boids {
            if (j == 0) { b.color = SIMD4<Float>(1.0, 0.0, 0.0, 1.0) }
            test.append(Vertex(color: b.color, pos: b.vertices[0]))
            test.append(Vertex(color: b.color, pos: b.vertices[1]))
            test.append(Vertex(color: b.color, pos: b.vertices[2]))
            j += 1
        }
        
        // copy over to vertex buffer
        let instanceData = buffer.contents().bindMemory(to: Float.self, capacity: boids.count * Scene.instanceDataSize + VisionCircle.circleDataSize)
        memcpy(instanceData, test, boids.count * Scene.instanceDataSize + VisionCircle.circleDataSize)
    }
    
    func update(with timestep: TimeInterval) {
        
        var i = 0
        for b in boids {
            b.vertices[2].x = b.vertices[2].x + (Float(timestep) * b.velocity.x)
            b.vertices[2].y = b.vertices[2].y + (Float(timestep) * b.velocity.y)
            let translationOriginMatrix = simd_float3x3( SIMD3<Float>( 1, 0, -b.vertices[2].x),
                                                         SIMD3<Float>( 0, 1, -b.vertices[2].y),
                                                         SIMD3<Float>( 0, 0,       1)  )
            
            let rotationMatrix = simd_float3x3( SIMD3<Float>(cos(b.theta + 90 * (.pi / 180)), -sin(b.theta + 90 * (.pi / 180)), 0),
                                                SIMD3<Float>(sin(b.theta + 90 * (.pi / 180)),  cos(b.theta + 90 * (.pi / 180)), 0),
                                                SIMD3<Float>(         0,           0, 1)  )
            
            let translationBackMatrix = simd_float3x3( SIMD3<Float>( 1, 0, b.vertices[2].x),
                                                       SIMD3<Float>( 0, 1, b.vertices[2].y),
                                                       SIMD3<Float>( 0, 0,       1)  )
            let transformationMatrix = translationOriginMatrix * rotationMatrix * translationBackMatrix
            
            if (i == 0) {
                b.color = SIMD4<Float>(1.0, 0.0, 0.0, 1.0)
            }
            if b.vertices[2].x <= -1.1 {
                b.vertices[2].x = 1.09
            }
            else if b.vertices[2].y <= -1.1 {
                b.vertices[2].y = 1.09
            }
            else if b.vertices[2].x >= 1.1 {
                b.vertices[2].x = -1.09
            }
            else if b.vertices[2].y >= 1.1 {
                b.vertices[2].y = -1.09
            }
            b.vertices = b.makeVertices(centerX: b.vertices[2].x, centerY: b.vertices[2].y, angleRad: b.theta ,transMatrix: transformationMatrix)
            i += 1
        }
    }
    
}
 */
