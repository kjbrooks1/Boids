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
    
    init(instanceCount: Int){
        boids = []
        for _ in 0..<instanceCount {
            boids.append(Boid())
        }
    }
    
    func copyInstanceData(to buffer: MTLBuffer) {
        
        var test: [Vertex] = []
        for b in boids {
            test.append(Vertex(color: b.color, pos: b.vertices[0]))
            test.append(Vertex(color: b.color, pos: b.vertices[1]))
            test.append(Vertex(color: b.color, pos: b.vertices[2]))
        }
        print(test)
        
        let instanceData = buffer.contents().bindMemory(to: Float.self, capacity: test.count * MemoryLayout<Vertex>.stride)
        memcpy(instanceData, test, test.count * MemoryLayout<Vertex>.stride)
        
    }
    
}
