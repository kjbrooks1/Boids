//
//  Boid.swift
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

import Foundation
import MetalKit

class Boid {
    
    var vertices: [Vertex]!
    static let instanceDataLength = 3 * MemoryLayout<Vertex>.stride
    private var velocity: Velocity!
    
    init() {
        // follow rules in makeVertices func
        vertices = makeVertices()
        
        // starting velocity is randomly selected
        let angle = Float.random(in: 0.0..<(Float.pi * 2))
        let speed = Float.random(in: 1.0...5.0)
        velocity = Velocity(pos: [speed*cos(angle), speed*sin(angle)])
    }
    
    func makeVertices() -> [Vertex] {
        let startx: Float = Float.random(in: -1 ..< 1)
        let starty: Float = Float.random(in: -1 ..< 1)
        
        let width: Float = 0.075
        let height: Float = 2 * width
        
        let ax = startx - (width/2)
        let ay = starty + (height/2)
        let bx = startx + (width/2)
        let by = starty + (height/2)
        let cx = startx
        let cy = starty - (width/2)
        
        return [Vertex(color: [0.6, 0.9, 0.1, 1.0], pos: [cx, cy]),
                Vertex(color: [0.6, 0.9, 0.1, 1.0], pos: [bx, by]),
                Vertex(color: [0.6, 0.9, 0.1, 1.0], pos: [ax, ay])]
    }
    
    func copyInstanceData(to buffer: MTLBuffer) {
        let instanceData = buffer.contents().bindMemory(to: Float.self, capacity: Boid.instanceDataLength)
        for i in 0 ... 2{
            instanceData[i] = vertices[i].color.x
            instanceData[i] = vertices[i].color.y
            instanceData[i] = vertices[i].color.z
            instanceData[i] = vertices[i].color.w
            instanceData[i] = vertices[i].pos.x
            instanceData[i] = vertices[i].pos.y
        }
    }
    
    func update(with timestep: TimeInterval) {
        vertices[0].pos.x += Float(timestep) * velocity.pos.x
        vertices[0].pos.y += Float(timestep) * velocity.pos.y
        
        vertices[1].pos.x += Float(timestep) * velocity.pos.x
        vertices[1].pos.y += Float(timestep) * velocity.pos.y
        
        vertices[2].pos.x += Float(timestep) * velocity.pos.x
        vertices[2].pos.y += Float(timestep) * velocity.pos.y
        
    }
    
}
