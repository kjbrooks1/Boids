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
    static let instanceDataSize = 3 * MemoryLayout<Vertex>.stride
    
    init(instanceCount: Int){
        boids = []
        for _ in 0..<instanceCount {
            boids.append(Boid())
        }
    }
    
    func copyInstanceData(to buffer: MTLBuffer) {
        // get the vertex data from each boid
        var test: [Vertex] = []
        for b in boids {
            test.append(Vertex(color: b.color, pos: b.vertices[0]))
            test.append(Vertex(color: b.color, pos: b.vertices[1]))
            test.append(Vertex(color: b.color, pos: b.vertices[2]))
        }
        // copy over to vertex buffer
        let instanceData = buffer.contents().bindMemory(to: Float.self, capacity: boids.count * Scene.instanceDataSize)
        memcpy(instanceData, test, boids.count * Scene.instanceDataSize)
    }
    
    func update(with timestep: TimeInterval) {
        for b in boids {
            b.center.x = b.center.x + (Float(timestep) * b.velocity.x)
            b.center.y = b.center.y + (Float(timestep) * b.velocity.y)
            b.vertices = b.makeVertices(centerX: b.center.x, centerY: b.center.y, angleRad: b.angle)
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
        }
    }
    
}
