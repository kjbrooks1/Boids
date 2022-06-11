//
//  Swarm.swift
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

import Foundation
import MetalKit

class Scene {
    
    var boids: [Boid]
    var circle: VisionCircle
    static let instanceDataSize = 3 * MemoryLayout<Vertex>.stride
    
    init(instanceCount: Int){
        boids = []
        for _ in 0..<instanceCount {
            boids.append(Boid())
        }
        circle = VisionCircle(mainGuy: boids[0])
    }
    
    func copyInstanceData(to buffer: MTLBuffer) {
        // get the vertex data from each boid
        var j = 0
        var test: [Vertex] = []
        
        let deltaTheta = (Float.pi * 2) / Float(VisionCircle.sideCount)
        for t in 0..<VisionCircle.sideCount {
            let t0 = Float(t) * deltaTheta
            let t1 = Float(t + 1) * deltaTheta
            test.append(Vertex(color: circle.color, pos: SIMD2<Float>(circle.position.x, circle.position.y) ))
            test.append(Vertex(color: circle.color, pos: SIMD2<Float>(circle.position.x+cos(t0)*0.25, circle.position.y+sin(t0)*0.25) ))
            test.append(Vertex(color: circle.color, pos: SIMD2<Float>(circle.position.x+cos(t1)*0.25, circle.position.y+sin(t1)*0.25) ))
        }
        
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
            b.center.x = b.center.x + (Float(timestep) * b.velocity.x)
            b.center.y = b.center.y + (Float(timestep) * b.velocity.y)
            b.vertices = b.makeVertices(centerX: b.center.x, centerY: b.center.y, angleRad: b.angle)
            if (i == 0) {
                b.color = SIMD4<Float>(1.0, 0.0, 0.0, 1.0)
                circle.position = b.vertices[2]
            }
            if b.center.x <= -1.2 {
                b.center.x = 1.0
            }
            if b.center.y <= -1.2 {
                b.center.y = 1.0
            }
            if b.center.x >= 1.2 {
                b.center.x = -1.0
            }
            if b.center.y >= 1.2 {
                b.center.y = -1.0
            }
            i += 1
        }
    }
    
}
